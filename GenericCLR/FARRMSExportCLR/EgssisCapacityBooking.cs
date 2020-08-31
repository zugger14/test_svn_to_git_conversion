using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Net;
using System.IO;
using System.Data.SqlClient;
using System.Data;

namespace FARRMSExportCLR
{
    #region EgssisEntriesExporter Business logic for EgssisCapacityBooking
    /// <summary>
    /// Used for exporting (outbound) report in json format for Capacity Booking. Uses REST webservices.
    /// </summary>
    class EgssisCapacityBooking : IWebServiceDataDispatcher
    {
        /// <summary>
        /// Used for generating data in required json format and exporting it.
        /// </summary>
        /// <param name="exportWebServiceInfo">Object containing information related to web service</param>
        /// <param name="tableNameorQuery">SQL query (table or SP)</param>
        /// <param name="exportFileFullPath">File path for exporting file</param>
        /// <param name="processID">Batch process id</param>
        /// <returns></returns>
        public ExportStatus DispatchData(ExportWebServiceInfo exportWebServiceInfo, string tableNameorQuery, string exportFileFullPath, string processID)
        {
            ExportStatus exportStatus = new ExportStatus();
            exportStatus.ProcessID = processID;
            string response = null;
            string dataValue = null;
            string clientId = null;
            string clientSecret = null;
            string grantType = null;
            string scope = null;
            string url_token = null;
            string url = null;
            try
            {

                SqlCommand cmd_sql = new SqlCommand(tableNameorQuery, exportWebServiceInfo.Connection);

                SqlDataReader queryRead = cmd_sql.ExecuteReader();
                queryRead.Close();

                SqlCommand cmd_param = new SqlCommand("spa_generic_mapping_header", exportWebServiceInfo.Connection);
                cmd_param.CommandType = CommandType.StoredProcedure;
                cmd_param.Parameters.Add(new SqlParameter("@flag", "a"));
                cmd_param.Parameters.Add(new SqlParameter("@mapping_name", "Web Service"));
                cmd_param.Parameters.Add(new SqlParameter("@primary_column_value", "EgssisCapacityBooking"));
                using (SqlDataReader reader_param = cmd_param.ExecuteReader())
                {
                    if (reader_param.HasRows)
                    {
                        reader_param.Read();
                        url_token = reader_param["Web Service Token URL"].ToString();
                        url = reader_param["Web Service URL"].ToString();
                        clientId = reader_param["Client ID"].ToString();
                        clientSecret = reader_param["Client Secret"].ToString();
                        grantType = reader_param["Grant Type"].ToString();
                        scope = reader_param["Scope"].ToString();
                    }
                }


                string accessToken = "";
                var request = (HttpWebRequest)WebRequest.Create(url_token);
                request.Timeout = 30000;
                request.UseDefaultCredentials = true;
                request.PreAuthenticate = true;
                request.Credentials = CredentialCache.DefaultCredentials;
                string postData = "client_id=" + clientId + "&client_secret=" + clientSecret + "&grant_type=" + grantType + "&scope=" + scope;

                var data = Encoding.ASCII.GetBytes(postData);
                request.Method = "POST";
                request.ContentType = "application/x-www-form-urlencoded";
                request.ContentLength = data.Length;


                using (var stream = request.GetRequestStream())
                {
                    stream.Write(data, 0, data.Length);

                }

                var httpResponse = (HttpWebResponse)request.GetResponse();

                var responseString = new StreamReader(httpResponse.GetResponseStream()).ReadToEnd();

                string refineData = responseString.Replace(":", ",").Replace("{", "").Replace("}", "");

                string[] arrayData = refineData.Split(',').Select(sValue => sValue.Trim()).ToArray();
                accessToken = arrayData[1].Replace(@"""", "");
                StreamWriter streamWriter;
                if (accessToken != "")
                {
                    //using (SqlConnection cn = new SqlConnection(@"Data Source=sg-d-sql01,2033;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                    //using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                    //{
                    //cn.Open();
                    string tableName = "";
                    string table_query = "SELECT dbo.FNAProcessTableName('batch_report', NULL, '" + processID + "') [process_table]";
                    using (var cmd = new SqlCommand(table_query, exportWebServiceInfo.Connection))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                tableName = reader["process_table"].ToString();
                            }
                            reader.Close();
                        }
                    }



                    using (var cmd1 = new SqlCommand("spa_egssis_capacity_booking", exportWebServiceInfo.Connection))
                    {
                        cmd1.CommandType = CommandType.StoredProcedure;
                        cmd1.Parameters.Add(new SqlParameter("@flag", "j"));
                        cmd1.Parameters.Add(new SqlParameter("@process_table_name", tableName)); //*** needs to be changed
                        cmd1.Parameters.Add(new SqlParameter("@tableNameorQuery", tableNameorQuery)); //*** added for debugging purpose
                        using (SqlDataReader reader1 = cmd1.ExecuteReader())
                        {
                            while (reader1.Read())
                            {
                                dataValue = reader1["json_data"].ToString();
                            }
                            reader1.Close();
                        }
                    }

                    using (var cmd2 = new SqlCommand("SELECT document_path FROM connection_string", exportWebServiceInfo.Connection))
                    {
                        using (SqlDataReader reader2 = cmd2.ExecuteReader())
                        {
                            while (reader2.Read())
                            {
                                exportStatus.FilePath = reader2["document_path"].ToString();
                            }
                            reader2.Close();
                        }
                    }

                    exportStatus.FileName = "EgssisCapacityBooking_" + DateTime.Now.ToString("yyyyddM_HHmmss") + ".txt";
                    exportStatus.FilePath = System.IO.Path.Combine(exportStatus.FilePath, "temp_Note", exportStatus.FileName);

                    using (streamWriter = File.CreateText(exportStatus.FilePath))
                    {
                        streamWriter.WriteLine(dataValue);
                        streamWriter.Close();
                    }


                    //dataValue = "{\"creationDate\": \"2019-07-18T13:21:00Z\",\"from\": \"egssis_gasum\",\"contract\": [{\"grid\": \"Energinet\",\"contractType\": \"Hub\",\"zone\": \"DS000068\",\"location\": \"21Y---A001A003-5\",\"locationType\": \"HubOut\",\"internalShipper\": \"DS000068\",\"counterparty\": \"CE000001\",\"dailyTrade\": [{\"gasDay\": \"2019-08-01\",\"forecastOverridesQuantity\": \"false\",\"value\": \"0\"}]}]}";

                    var httpWebRequest = (HttpWebRequest)WebRequest.Create(url);
                    httpWebRequest.Method = "POST";
                    httpWebRequest.ContentType = "application/json";
                    httpWebRequest.Headers.Add("Authorization", "Bearer " + accessToken);

                    using (streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
                    {
                        streamWriter.Write(dataValue);
                        streamWriter.Close();
                    }

                    using (var httpResponse1 = (HttpWebResponse)httpWebRequest.GetResponse())
                    {
                        /*using (var streamReader = new StreamReader(httpResponse1.GetResponseStream()))
                        {
                            response = streamReader.ReadToEnd();
                        }*/
                        response = httpResponse1.StatusDescription;
                    }
                }
                exportStatus.ResponseMessage = response;
                exportStatus.Status = "Success";
                BuildCapacityBookingMessaging(exportStatus, exportWebServiceInfo.Connection);
            }
            catch (WebException webEx)
            {
                //try to grab web response
                WebResponse errorResponse = webEx.Response;
                string errorResponseMessage = null;
                using (var responseStream = errorResponse.GetResponseStream())
                {
                    var reader = new StreamReader(responseStream);
                    errorResponseMessage = reader.ReadToEnd();
                }
                exportStatus.ResponseMessage = errorResponseMessage;
                exportStatus.Status = "Failed";
                exportStatus.Exception = webEx;
                BuildCapacityBookingMessaging(exportStatus, exportWebServiceInfo.Connection);
            }
            catch (Exception ex)
            {
                //handle other exeception (like IOException [path not accessible])
                exportStatus.ResponseMessage = ex.Message;
                exportStatus.Status = "Failed";
                exportStatus.Exception = ex;
                BuildCapacityBookingMessaging(exportStatus, exportWebServiceInfo.Connection);
            }
            return exportStatus;
        }
        /// <summary>
        /// Calls SP to insert success/error message in the message board
        /// </summary>
        /// <param name="exportStatus">Variable to store information related to web service status</param>
        /// <param name="cn">DB connection</param>
        private void BuildCapacityBookingMessaging(ExportStatus exportStatus, SqlConnection cn)
        {
            using (SqlCommand cmd = new SqlCommand("spa_egssis_capacity_booking", cn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new SqlParameter("@flag", "m"));
                cmd.Parameters.Add(new SqlParameter("@type", exportStatus.Status));
                cmd.Parameters.Add(new SqlParameter("@process_id", exportStatus.ProcessID));
                cmd.Parameters.Add(new SqlParameter("@file_name", exportStatus.FileName));
                cmd.Parameters.Add(new SqlParameter("@file_location", exportStatus.FilePath));
                cmd.Parameters.Add(new SqlParameter("@message", exportStatus.ResponseMessage));
                cmd.ExecuteNonQuery();
            }
        }
    }
    #endregion
}
