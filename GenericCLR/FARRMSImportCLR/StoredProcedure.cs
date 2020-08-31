using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Xml;
using Microsoft.SqlServer.Server;
using FARRMSUtilities;

namespace FARRMSImportCLR
{

    public class StoredProcedure
    {
        public static List<string> stackProcess = new List<string>();

        /// <summary>
        /// Import CLR method
        /// </summary>
        /// <param name="parameterXml">Parameter xml</param>
        /// <param name="ixpRuleId">Import rule id</param>
        /// <param name="processId">Process Id</param>
        [Microsoft.SqlServer.Server.SqlProcedure]
        //TODO: Suggest better name
        public static void ImportWithCLRRule(string parameterXml, int ixpRuleId, string processId)
        {
            string processTable = "";
            ImportStatus importStatus = null;
            try
            {
                CLRImportInfo clrImportInfo = new CLRImportInfo();
                if (parameterXml != "")
                {
                    XmlDocument doc = new XmlDocument();
                    doc.LoadXml(parameterXml);

                    XmlNodeList oXmlNodeList = doc.SelectNodes("Root/PSRecordset");


                    foreach (XmlNode x in oXmlNodeList)
                    {
                        string paramName = x.Attributes["paramName"].Value;
                        string paramValue = x.Attributes["paramValue"].Value;
                        clrImportInfo.Params.Add(new CLRParameter { paramName = paramName, paramValue = paramValue });
                    }
                }

                clrImportInfo.RuleID = ixpRuleId;
                clrImportInfo.ProcessID = processId;

                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL20\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=sa;password=pioneer"))
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    try
                    {
                        cn.Open();
                        SqlDataReader rd = cn.ExecuteStoredProcedureWithReturn("spa_ixp_clr_functions", "flag:m,rules_id:" + ixpRuleId.ToString());
                        if (rd.HasRows)
                        {
                            clrImportInfo.MethodName = rd[0].ToString();
                            rd.Close();
                        }
                        cn.Close();
                    }
                    catch (Exception dbEx)
                    {
                        if (cn != null && cn.State == ConnectionState.Open)
                            cn.Close();

                        throw dbEx;
                    }
                }

                ICLRImporter clrImporter = CLRImporterFactory.GetCLRImporter(clrImportInfo);
                importStatus = clrImporter.ImportData(clrImportInfo);
                processTable = importStatus.ProcessTableName;
                SendImportStatusResult(importStatus);

            }
            catch (Exception ex)
            {
                processTable = null;
                string outputResult = ex.Message;
                if (importStatus == null)
                {

                    importStatus = new ImportStatus { Status = "Error", ResponseMessage = outputResult, ProcessID = processId };

                }

                SendImportStatusResult(importStatus);

                ex.LogError("Import from CLR", parameterXml + "|" + ixpRuleId + "|" + processId + "|" + processTable + "|" + outputResult, stackProcess, processId);
            }
        }

        /// <summary>
        /// Send import status class result set (select stmt.) to sql server.
        /// </summary>
        /// <param name="importStatus"></param>
        private static void SendImportStatusResult(ImportStatus importStatus)
        {
            // define table structure
            SqlDataRecord rec = new SqlDataRecord(new SqlMetaData[] {
                    new SqlMetaData("ErrorCode", SqlDbType.NVarChar, 1000),
                    new SqlMetaData("Module", SqlDbType.NVarChar, 1000),
                    new SqlMetaData("Area", SqlDbType.NVarChar, 1000),
                    new SqlMetaData("Status", SqlDbType.NVarChar, 1000),
                    new SqlMetaData("Message", SqlDbType.NVarChar, 1000),
                    new SqlMetaData("Supress", SqlDbType.NVarChar, 1000),
                    new SqlMetaData("ProcessTable", SqlDbType.NVarChar, 1000)});

            SqlContext.Pipe.SendResultsStart(rec);
            rec.SetSqlString(0, importStatus.Status);
            rec.SetSqlString(1, importStatus.Status);
            rec.SetSqlString(2, "ImportWithCLRRule");
            rec.SetSqlString(3, importStatus.Status);
            rec.SetSqlString(4, importStatus.ResponseMessage);
            rec.SetSqlString(5, importStatus.Supress.ToString());
            rec.SetSqlString(6, importStatus.ProcessTableName);
            SqlContext.Pipe.SendResultsRow(rec);

            SqlContext.Pipe.SendResultsEnd();    // finish sending
        }

    }
}

