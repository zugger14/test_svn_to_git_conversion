using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
namespace FARRMSGenericCLR
{
    /// <summary>
    /// Transforms complex xml with data relation with its nodes data and import to sql data table. See supported xml sample
    /// </summary>
    /*
        <Deals>
            <Deal Id="1">
	            <counterparty>counterparty1</counterparty>
	            <trader>test</trader>
	            <Details>
		            <dealdetail>
			            <location>location1</location>
			            <curve>Index1</curve>
		            </dealdetail>
		            <dealdetail>
			            <location>location2</location>
			            <curve>Index2</curve>
		            </dealdetail>
		            <dealdetail>
			            <location>location3</location>
			            <curve>Index3</curve>
		            </dealdetail>
	            </Details>
            </Deal>
            <Deal Id="2">
	            <counterparty>counterparty1</counterparty>
	            <trader>test</trader>
	            <Details>
		            <dealdetail>
			            <location>location1</location>
			            <curve>Index1</curve>
		            </dealdetail>
		            <dealdetail>
			            <location>location2</location>
			            <curve>Index2</curve>
		            </dealdetail>
	            </Details>
            </Deal>
        </Deals>
     */

    class ImportXml:IDisposable
    {
        private string XmlContent { get; set; }
        private string XmlFileName { get; set; }
        private string ProcessTableName { get; set; }

        public ImportXml(string xmlContent, string xmlFileName, string processTableName)
        {
            this.XmlContent = xmlContent;
            this.XmlFileName = xmlFileName;
            this.ProcessTableName = processTableName;
        }

        public void Import()
        {
            ParsedXml xml = this.TransformXml();

            using (StringReader stringReader = new StringReader(xml.XmlContent))
            {
                using (DataSet xmlDataset = new DataSet())
                {
                    xmlDataset.ReadXml(stringReader);
                    //  Add those data table which has key field only
                    List<DataTable> dataTables = new List<DataTable>();
                    
                    bool hasKey = !string.IsNullOrEmpty(xml.PrimaryKey);

                    foreach (DataTable table in xmlDataset.Tables)
                    {
                        //if (table.Rows[0].ItemArray.Count() == 1) continue;
                        if (!hasKey)
                        {
                            xml.PrimaryKey = "KeyColumn";
                            var dataColumn = new DataColumn(xml.PrimaryKey);
                            dataColumn.DefaultValue = "1";
                            table.Columns.Add(dataColumn);
                        }

                        if (table.Columns[xml.PrimaryKey] != null)
                        {
                            table.TableName = "adiha_process.dbo.[" + table.TableName + "_" + Guid.NewGuid().ToString().ToUpper().Replace("-", "_") + "]";
                            dataTables.Add(table);
                        }
                    }

                    //  Dump data table to adiha_process
                    //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDD10\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                    using (SqlConnection cn = new SqlConnection(@"Context Connection=True"))
                    {
                        cn.Open();
                        List<string> dataColumnsList = new List<string>();

                        foreach (DataTable dataTable in dataTables)
                        {
                            this.CreateProcessTable(dataTable, cn);

                            //  List of columns that will be part of final process table selection
                            foreach (
                                DataColumn column in
                                    dataTable.Columns.Cast<DataColumn>()
                                        .Where(
                                            column =>
                                                dataColumnsList.FirstOrDefault(
                                                    x => x.ToLower().Split('.').Last() == column.ColumnName.ToLower()) == null))
                            {
                                dataColumnsList.Add(column.Table.TableName + "." + column.ColumnName);
                            }
                            //  Dumping each data table process table
                            using (SqlDataAdapter dataAdapter = new SqlDataAdapter("select TOP 1 * from " + dataTable.TableName, cn))
                            {
                                SqlCommandBuilder builder = new SqlCommandBuilder(dataAdapter);
                                dataAdapter.Fill(dataTable);
                                dataAdapter.Update(dataTable);
                            }
                        }

                        //  Next Builder based on auto increments column
                        List<AutoJoin> autoJoinColumns = new List<AutoJoin>();
                        foreach (DataTable dt in dataTables)
                        {
                            autoJoinColumns.AddRange(GetAutoGeneratedColumns(dt));
                        }

                        string sql = "IF OBJECT_ID('" + this.ProcessTableName + "') IS NOT NULL DROP TABLE " + this.ProcessTableName;
                        ExecuteQuery(sql, cn);

                        string sqlCmd = "select {0} INTO " + this.ProcessTableName + " FROM ";
                        string columns = dataColumnsList.Aggregate("", (current, col) => current + (col + ",")).TrimEnd(',');
                        sqlCmd = string.Format(sqlCmd, columns);
                        if (dataTables.Count > 1)
                        {
                            sqlCmd += dataTables[0].TableName;
                            DataTable baseTable = dataTables[0];
                            //  Build inner join selection based on key column
                            for (int i = 1; i < dataTables.Count; i++)
                            {
                                sqlCmd += Environment.NewLine + " LEFT JOIN " + dataTables[i].TableName + " ON " +
                                          baseTable.TableName + ".[" + xml.PrimaryKey + "] = " + dataTables[i].TableName + ".[" +
                                          xml.PrimaryKey + "]";

                            }

                            for (int i = 0; i < dataTables.Count; i++)
                            {
                                if ((i+1) == dataTables.Count) break;
                                sqlCmd += InnerJoinBasedOnKeys(autoJoinColumns, dataTables[i], dataTables[i + 1]);
                            }
                        }
                        else
                        {
                            sqlCmd = "select * INTO " + this.ProcessTableName + " FROM " + dataTables[0].TableName;
                        }
                        ExecuteQuery(sqlCmd, cn);

                        //  Drop Auto generated columns based on nodes
                        string columnsToDrop = "";
                        autoJoinColumns.Add(new AutoJoin() { Column = "KeyColumn",Table = this.ProcessTableName});
                        foreach (AutoJoin jointsKey in autoJoinColumns)
                        {
                            ExecuteQuery("IF COL_LENGTH('" + this.ProcessTableName + "','" + jointsKey.Column + "') IS NOT NULL ALTER TABLE " + this.ProcessTableName + " drop column [" + jointsKey.Column + "]", cn);
                        }
                        columnsToDrop = columnsToDrop.TrimEnd(',');
                    }   
                }
            }
        }

        private string InnerJoinBasedOnKeys(List<AutoJoin> tableKeys, DataTable srcDataTable, DataTable datatableToCompare)
        {
            string query = "";
            foreach (AutoJoin tableKey in tableKeys)
            {
                if (srcDataTable.Columns[tableKey.Column] != null && datatableToCompare.Columns[tableKey.Column] != null)
                    query += " AND " + srcDataTable.Columns[tableKey.Column].Table + "." + tableKey.Column + " = " +
                             datatableToCompare.Columns[tableKey.Column].Table + "." + tableKey.Column;
            }
            return query;
        }

        private List<AutoJoin> GetAutoGeneratedColumns(DataTable table)
        {
            List<AutoJoin> list = new List<AutoJoin>();
            foreach (DataColumn dc in table.Columns)
            {
                if (dc.ColumnMapping == MappingType.Hidden)
                    list.Add(new AutoJoin(){Table = table.TableName, Column = dc.ColumnName});
            }
            return list;
        }

        private void CreateProcessTable(DataTable dataTable, SqlConnection sqlConnection)
        {
            string sql = "IF OBJECT_ID('" + dataTable.TableName + "') IS NOT NULL DROP TABLE " + dataTable.TableName;
            ExecuteQuery(sql, sqlConnection);

            int index = 1;
            sql = "CREATE TABLE " + dataTable.TableName + "(";

            foreach (DataColumn column in dataTable.Columns)
            {
                sql += "[" + column.ColumnName + "] NVARCHAR(MAX),";
            }
            string sqlTable = sql.TrimEnd(',') + ")";
            ExecuteQuery(sqlTable, sqlConnection);
        }

        private void ExecuteQuery(string query, SqlConnection sqlConnection)
        {
            SqlCommand cmd = new SqlCommand(query, sqlConnection);
            cmd.ExecuteNonQuery();
        }

        private ParsedXml TransformXml()
        {
            XmlDocument xDoc = new XmlDocument();
            if (!string.IsNullOrEmpty(this.XmlContent)) xDoc.LoadXml(this.XmlContent);
            if (!string.IsNullOrEmpty(this.XmlFileName)) xDoc.Load(this.XmlFileName);

            
            //XmlNodeList xmlNodeList = xDoc.SelectNodes(rootNode);
            KeyColumn keyColumn = null;

            //  If root node has attribute Eg. Refere to Shape Deal XMl import

            if (xDoc.DocumentElement != null && xDoc.DocumentElement.HasAttributes)
            {
                keyColumn = new KeyColumn()
                {
                    Name = xDoc.DocumentElement.Attributes[0].Name,
                    Value = xDoc.DocumentElement.Attributes[0].Value
                };
                foreach (XmlNode xNode in xDoc.ChildNodes)
                {
                    //  Logic for adding attribute or Element to be added.
                    if (xNode.Attributes == null && xNode.HasChildNodes)
                    {
                        XmlNode newNode = xDoc.CreateElement(keyColumn.Name);
                        newNode.InnerText = keyColumn.Value;
                        xNode.AppendChild(newNode);
                    }
                    else
                    {
                        XmlAttribute newAttribute = xDoc.CreateAttribute(keyColumn.Name);
                        newAttribute.InnerText = keyColumn.Value;
                        xNode.Attributes.Append(newAttribute);
                    }
                }
            }

            foreach (XmlNode xNode in xDoc.DocumentElement.ChildNodes)
            {

                if (xNode.Attributes != null && xNode.Attributes.Count > 0)
                {
                    keyColumn = new KeyColumn()
                    {
                        Name = xNode.Attributes[0].Name,
                        Value = xNode.Attributes[0].Value
                    };
                    string xPath = xDoc.DocumentElement.Name + "/" + xNode.Name + "[@" + keyColumn.Name + "='" +
                                   keyColumn.Value + "']";
                    XmlNodeList xmlNodeList = xDoc.SelectNodes(xPath);

                    SetKeyForNode(xDoc, xNode, keyColumn, xPath);
                }
            }
            if (keyColumn != null)
                return new ParsedXml() { PrimaryKey = keyColumn.Name, XmlContent = xDoc.InnerXml };
            else
                return new ParsedXml() { PrimaryKey = null, XmlContent = xDoc.InnerXml };
        }

        /// <summary>
        /// Creates data relations within xml nodes including nested
        /// </summary>
        /// <param name="xDoc">XmlDocument</param>
        /// <param name="xmlNode">XmlNode</param>
        /// <param name="keyColumn">KeyColumn</param>
        /// <param name="xPath">XML Node Path</param>
        private void SetKeyForNode(XmlDocument xDoc, XmlNode xmlNode, KeyColumn keyColumn, string xPath)
        {
            foreach (XmlNode xNode in xmlNode.ChildNodes)
            {
                if (xNode.NodeType == XmlNodeType.Text) continue;

                XmlNodeList xmlNodeList = xmlNode.SelectNodes("/" + xPath + "/" + xNode.Name + "/*");
                foreach (XmlNode node in xmlNodeList)
                {
                    if (node.Attributes.Count == 0 && node.HasChildNodes)
                    {
                        //TODO:: DONT DELETE
                        //node.Attributes.Append(xDoc.CreateAttribute(keyColumn.Name, keyColumn.Value));

                        XmlNode newNode = xDoc.CreateElement(keyColumn.Name);
                        newNode.InnerText = keyColumn.Value;
                        node.AppendChild(newNode);
                        SetKeyForNode(xDoc, node, keyColumn, xPath + "/" + xNode.Name + "/" + node.Name);
                    }
                }
            }
        }

        public void Dispose()
        {
            GC.SuppressFinalize(this); 
        }
    }

    class AutoJoin
    {
        public string Table { get; set; }
        public string Column { get; set; }
    }

    class KeyColumn
    {
        public string Name { get; set; }
        public string Value { get; set; }
    }

    class ParsedXml
    {
        public string XmlContent { get; set; }
        public string PrimaryKey { get; set; }
    }
}
