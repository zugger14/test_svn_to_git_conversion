using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace FARRMSGenericCLR
{
    public class TSqlScriptParser
    {
        public int GetIndexOfFromOfReportMagerView(string reportManangerViewQuery)
        {
            try
            {
                TSql130Parser SqlParser = new TSql130Parser(false);

                IList<ParseError> parseErrors;
                TSqlFragment result = SqlParser.Parse(new StringReader(reportManangerViewQuery), out parseErrors);
                if (parseErrors.Count > 0)
                    return -1;
                TSqlScript tSqlScript = result as TSqlScript;

                SelectStatement selectStatement = (tSqlScript.Batches.FirstOrDefault().Statements.LastOrDefault()) as SelectStatement;
                QuerySpecification querySpecification = selectStatement.QueryExpression as QuerySpecification;
                TSqlFragment fromClauseFragment = querySpecification.FromClause as TSqlFragment;
                return fromClauseFragment.StartOffset;
            }
            catch (Exception)
            {
                return -1;
            }
        }

        /// <summary>
        /// Remove Set clause expression from udpate query based on columns to exclude list
        /// </summary>
        /// <param name="updateQuery">Valid update query script</param>
        /// <param name="columnsToExclude">Set clause column name list separated by comma.</param>
        /// <returns>Returns updated query with columns stripped from set clause</returns>
        /* Example :
            string excludes = "term_start,source_deal_header_id";
            
            string updateQuery = @"UPDATE t1
            SET t1.CalculatedColumn = t2.[Calculated Column], source_deal_header_id = 4055, term_start = NULL, term_end = NULL
            FROM dbo.Table1 AS t1
            INNER JOIN dbo.Table2 AS t2
            ON t1.CommonField = t2.[Common Field]
            WHERE t1.BatchNo = '110'";

            updateQuery = @"UPDATE source_deal_detail 
            SET source_deal_header_id = 4055, term_start = NULL, term_end = NULL , deal_date = t.term_start,deal_date = ab.term_start, term_start = t.term_start 
            where source_deal_header_id = 4055";

            updateQuery = @"UPDATE source_deal_detail 
            SET source_deal_header_id = 4055, term_start = NULL, term_end = NULL ";

            RemoveColumnsFromUpdate2(updateQuery, excludes);
         */
        public string RemoveColumnsFromUpdate(string updateQuery, string columnsToExclude, out string parseError)
        {
            parseError = "Success";
            string[] arrExcludeSet = columnsToExclude.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
            TSql130Parser SqlParser = new TSql130Parser(false);

            IList<ParseError> parseErrors;
            TSqlFragment result = SqlParser.Parse(new StringReader(updateQuery), out parseErrors);
            //  if any error is found with input query return the same input as output
            if (parseErrors.Count > 0)
            {
                parseError = parseErrors[0].Message;
                return updateQuery;
            }

            TSqlScript tSqlScript = result as TSqlScript;

            List<SetClauseFragment> fragmentsToRemove = new List<SetClauseFragment>();

            foreach (TSqlBatch sqlBatch in tSqlScript.Batches)
            {
                foreach (UpdateStatement stmt in sqlBatch.Statements)
                {
                    int index = 0;
                    foreach (SetClause setClause in stmt.UpdateSpecification.SetClauses)
                    {
                        AssignmentSetClause assignmentSetClause = setClause as AssignmentSetClause;
                        TSqlFragment tSqlFragment = setClause as TSqlFragment;
                        string value = "";
                        for (int i = tSqlFragment.FirstTokenIndex; i <= tSqlFragment.LastTokenIndex; i++)
                        {
                            value += tSqlFragment.ScriptTokenStream[i].Text;
                        }
                        SetClauseFragment setClauseFragment = new SetClauseFragment() { FragmentString = value, Strip = false, Index = index };
                        fragmentsToRemove.Add(setClauseFragment);
                        string setColumnName = assignmentSetClause.Column.MultiPartIdentifier.Identifiers.Last().Value;
                        //  Check if column is to be excluded 
                        if (!string.IsNullOrEmpty(arrExcludeSet.FirstOrDefault(x => x.Replace("[", "").Replace("]", "").Split('.').Last().ToLower().Trim() == setColumnName.ToLower().Trim())))
                        {
                            setClauseFragment.Strip = true;
                            //Console.WriteLine(setColumnName);
                        }
                        index++;
                    }
                }
            }

            //  Get SET offset index from update query
            int setTokenIndex = 0;
            foreach (TSqlParserToken t in result.ScriptTokenStream.Where(t => t.TokenType == TSqlTokenType.Set))
            {
                setTokenIndex = t.Offset;
            }

            //  Check occurance of FROM or WHERE this will handle simple update or with JOIN
            int endOffset = result.FragmentLength;
            foreach (TSqlParserToken t in result.ScriptTokenStream.Where(t => t.TokenType == TSqlTokenType.Where || t.TokenType == TSqlTokenType.From))
            {
                endOffset = t.Offset;
                //  If update statement is using FROM keyword dont check other where
                if (t.TokenType == TSqlTokenType.From) break;
            }
            //  Update set clause statement
            string updcolumns = updateQuery.Substring(setTokenIndex, endOffset - setTokenIndex);

            //  Start replacing
            foreach (SetClauseFragment f in fragmentsToRemove.OrderByDescending(x => x.Index).Where(x => x.Strip))
            {
                int invalidCommaIndex = updcolumns.Substring(0, updcolumns.IndexOf(f.FragmentString)).LastIndexOf(',');
                if (f.Index != 0)
                    updcolumns =
                        updcolumns.Remove(invalidCommaIndex, 1) //  Replace trailling comma
                            .Insert(invalidCommaIndex, "")  //  replace trailling comma with empty string
                            .Replace(f.FragmentString, ""); //  replace set clause with empty string    
                else
                {
                    updcolumns = updcolumns.Replace(f.FragmentString, "");  //  replace set clause with empty string
                    invalidCommaIndex = updcolumns.IndexOf(',');            //  Get the index of invalid leading comma index
                    updcolumns = updcolumns.Remove(invalidCommaIndex, 1).Insert(invalidCommaIndex, ""); //  Replace leading comma with empty string
                }
            }

            //  Final query => update query string up to set keyword + set clauses + other joins / where conditions
            string endQry = updateQuery.Substring(0, setTokenIndex) + updcolumns + updateQuery.Substring(endOffset);
            return endQry;
        }

        public string StripCommentsFromSQL(string SQL)
        {

            TSql130Parser parser = new TSql130Parser(true);
            IList<ParseError> errors;
            var fragments = parser.Parse(new System.IO.StringReader(SQL), out errors);

            // clear comments
            string result = string.Join(
              string.Empty,
              fragments.ScriptTokenStream
                  .Where(x => x.TokenType != TSqlTokenType.MultilineComment)
                  .Where(x => x.TokenType != TSqlTokenType.SingleLineComment)
                  .Select(x => x.Text));

            return result;

        }
    }

    /// <summary>
    /// Set Clause object stores information about the upate set clause expression
    /// </summary>
    class SetClauseFragment
    {
        /// <summary>
        /// Udpate set clause expression with value
        /// </summary>
        public string FragmentString { get; set; }
        /// <summary>
        /// Set clause removal identitfier
        /// </summary>
        public bool Strip { get; set; }
        /// <summary>
        /// Set clause index in udpate sql script
        /// </summary>
        public int Index { get; set; }
    }
}
