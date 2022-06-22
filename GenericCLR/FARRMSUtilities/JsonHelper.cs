using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace FARRMSUtilities
{

    public static class JsonHelper
    {
        public static string GetValue(string json, string keyField)
        {
            JObject details = JObject.Parse(json);
            return (string)details[keyField];
        }

        public static JObject GetJObject(string json)
        {
            JObject details = JObject.Parse(json);
            return details;
        }

        public static T Deserialize<T>(string jsonContent)
        {
            try
            {
                return JsonConvert.DeserializeObject<List<T>>(jsonContent).FirstOrDefault(); ;
            }
            catch (Exception)
            {
                return default(T);
            }
        }

        public static List<T> DeserializeCollection<T>(this string jsonContent)
        {
            try
            {
                return JsonConvert.DeserializeObject<List<T>>(jsonContent);
            }
            catch (Exception ex) 
            {
                return null;
            }
        }

        /// <summary>
        /// Converts sql query ouput to JSON
        /// </summary>
        /// <param name="sqlQuery">SQL Query</param>
        /// <param name="formatting">Formatting options</param>
        /// <returns></returns>
        public static string TableToJSON(string sqlQuery)
        {
            //using (SqlConnection cn = new SqlConnection(@"Data Source=GUNJESH-SAINJU-\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=sa;password=pioneer"))
            using (SqlConnection cn = new SqlConnection(@"Context Connection=True"))
            {
                cn.Open();
                using (SqlCommand cmd = new SqlCommand(sqlQuery, cn))
                {
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        DataTable dataTable = new DataTable();
                        dataTable.Load(rd);
                        DataSet dataSet = new DataSet();
                        dataSet.Tables.Add(dataTable);
                        string json = JsonConvert.SerializeObject(dataSet);
                        return json;
                    }
                }
            }
        }

        /// <summary>
        /// Serialized object to JSON
        /// </summary>
        /// <param name="obj">object</param>
        /// <param name="formatting">Formatting options</param>
        /// <returns></returns>
        public static string CollectionToJson(object obj, Formatting formatting)
        {
            string json = JsonConvert.SerializeObject(obj, formatting);
            return json;
        }


        /// <summary>
        /// Import json data to sql process table
        /// </summary>
        /// <param name="jsonContent">JSON data that can be represented as table</param>
        public static List<Table> InsertJsonToTable(string jsonContent, string processId = null)
        {
            DataSet dataSet = JsonConvert.DeserializeObject<DataSet>(jsonContent);
            //using (SqlConnection cn = new SqlConnection(@"Data Source=GUNJESH-SAINJU-\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=sa;password=pioneer"))
            using (SqlConnection cn = new SqlConnection(@"Context Connection=True"))
            {
                cn.Open();
                return dataSet.CreateProcessTables(cn, processId);
            }
        }

        /// <summary>
        /// Import json data based on specific node name to sql process table
        /// </summary>
        /// <param name="jsonContent">JSON Data</param>
        /// <param name="nodeName">Node Name</param>
        public static Table InsertJsonToTable(string jsonContent, string nodeName, string processId = null)
        {
            DataSet dataSet = JsonConvert.DeserializeObject<DataSet>(jsonContent);
            //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL20\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=sa;password=pioneer"))
            using (SqlConnection cn = new SqlConnection(@"Context Connection=True"))
            {
                cn.Open();
                return dataSet.CreateProcessTableFromNode(cn, nodeName, processId);
            }
        }

        /// <summary>
        /// Get Collection of data tables from json
        /// </summary>
        /// <param name="jsonContent"></param>
        /// <returns>DataTableCollection</returns>
        public static DataTableCollection GetDataTables(string jsonContent)
        {
            DataSet dataSet = JsonConvert.DeserializeObject<DataSet>(jsonContent);
            return dataSet.Tables;
        }

        /// <summary>
        /// Get specific node data table from json
        /// </summary>
        /// <param name="jsonContent">JSON Data</param>
        /// <param name="nodeName">Node Name</param>
        /// <returns>DataTable</returns>
        public static DataTable GetDataTable(string jsonContent, string nodeName)
        {
            DataSet dataSet = JsonConvert.DeserializeObject<DataSet>(jsonContent);
            return dataSet.Tables[nodeName];
        }


        /// <summary>
        /// Dump JSON data to process table
        /// </summary>
        /// <param name="dataSet">DataSet, Loaded from json converter, this dataset will dumped to process table.</param>
        /// <param name="sqlConnection">Valid active sql connection</param>
        /// <returns></returns>
        public static List<Table> CreateProcessTables(this DataSet dataSet, SqlConnection sqlConnection, string processId)
        {
            var list = new List<Table>();
            foreach (DataTable dt in dataSet.Tables)
            {
                list.Add(CreateTable(dt, sqlConnection, processId));
            }

            return list;
        }

        /// <summary>
        /// Import specific Node collection to process table
        /// </summary>
        /// <param name="dataSet"></param>
        /// <param name="sqlConnection"></param>
        /// <param name="jsonNodeName"></param>
        /// <returns></returns>
        private static Table CreateProcessTableFromNode(this DataSet dataSet, SqlConnection sqlConnection, string jsonNodeName, string processId)
        {
            DataTable dt = dataSet.Tables[jsonNodeName];
            if (dt != null)
            {
                return CreateTable(dt, sqlConnection, processId);
            }
            return null;
        }

        private static Table CreateTable(DataTable dt, SqlConnection sqlConnection, string processId)
        {
            
            if (string.IsNullOrEmpty(processId))
                processId = Guid.NewGuid().ToString().ToUpper().Replace("-", "_");

            var table = new Table() { TableName = "[adiha_process].dbo.[" + dt.TableName + "_" + processId + "]", ProcessId = processId };

            string columns = "";

            string sql = "IF OBJECT_ID('" + table.TableName + "') IS NOT NULL DROP TABLE " + table.TableName;
            sqlConnection.ExecuteQuery(sql);
            sql = "CREATE TABLE " + table.TableName + "(";
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                columns += "[" + dt.Columns[i].ColumnName + "],";
                sql += "[" + dt.Columns[i].ColumnName + "] NVARCHAR(MAX),";
            }
            sql = sql.TrimEnd(',') + ") ";
            sqlConnection.ExecuteQuery(sql);

            using (SqlDataAdapter sqlDataAdapter = new SqlDataAdapter("SELECT * FROM " + table.TableName, sqlConnection))
            {
                SqlCommandBuilder builder = new SqlCommandBuilder(sqlDataAdapter);
                sqlDataAdapter.Fill(dt);
                sqlDataAdapter.Update(dt);
            }
            return table;
        }
    }

    public class Table
    {
        public string TableName { get; set; }
        public string ProcessId { get; set; }
    }

}
