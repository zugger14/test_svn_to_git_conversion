using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace FARRMSGenericCLR
{
    /// <summary>
    /// Json field class
    /// </summary>
    class JsonField
    {
        public string Name { get; set; }
        public System.Type Type { get; set; }
    }

    /// <summary>
    /// This class has methods to export sql data reader to json
    /// </summary>
    class PsJson
    {
        private SqlDataReader sqlDataReader { get; set; }
        private List<JsonField> jsonFields { get; set; }
        private List<string> customFieldList { get; set; } 

        public PsJson(SqlDataReader _reader, string _jsonFieldList)
        {
            jsonFields = new List<JsonField>();
            sqlDataReader = _reader;
            List<JsonField> jsonFieldList = new List<JsonField>();
            for (int i = 0; i < sqlDataReader.FieldCount; i++)
            {
                jsonFieldList.Add(new JsonField() { Name = (sqlDataReader.GetName(i).Trim() == "") ? "Column" +i : sqlDataReader.GetName(i), Type = sqlDataReader.GetFieldType(i) });
            }

            if (_jsonFieldList != null)
            {
                customFieldList = _jsonFieldList.Split(',').ToList();

                foreach (string field in customFieldList)
                {
                    //  Skip invalid column if not present reader output fields list
                    if (jsonFieldList.FirstOrDefault(x => x.Name.ToLower() == field.ToLower()) == null) continue;

                    var fieldJson = jsonFieldList.FirstOrDefault(x => x.Name.ToLower() == field.ToLower());
                    if (fieldJson != null)
                        jsonFields.Add(fieldJson);
                }
            }
            else
            {
                jsonFields.AddRange(jsonFieldList);
            }
        }

        public string ConvertToJson()
        {
            //{"type_id":"38500","type_name":"Contract Group"}
            string json = "";
            while (sqlDataReader.Read())
            {
                json += "{";
                string jsonRow = "";
                int i = 0;
                foreach (JsonField jfield in jsonFields)
                {
                    jsonRow += "\"" + jfield.Name + "\":\"" + (sqlDataReader[i].GetType().ToString() == "System.DateTime" ? Convert.ToDateTime(sqlDataReader[i]).ToString("yyyy-MM-dd") : sqlDataReader[i].ToString().Trim().Replace("\"", "\\\"")) + "\",";
                    i++;
                }

                json += jsonRow.TrimEnd(',') + "},";
            }
            json = "[" + json.TrimEnd(',') + "]";
            return CleanJson(json);
        }

        private string CleanJson(string rawJsonContent)
        {
            return rawJsonContent.Replace(@"\", @"\\")  //  Back slash
                .Replace(@"/", @"\/")   //  Front slash
                .Replace(Environment.NewLine, "\\n")    //  New Line
                .Replace("\n", "\\n")   //  New Line
                .Replace("\f", "\\f")   //  Form Feed
                .Replace("\r", "\\r")   //  Carrige return
                .Replace("\t", "\\t")   //  Tab
                .Replace("\\\"", "\""); //  doublequotes with slash

        }


    }
}
