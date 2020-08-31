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
    #region NordpoolExporter Business logic for Nordpool
    /// <summary>
    /// Used for exporting (outbound) report in xml format for Remit non standard report.
    /// </summary>
    class NordpoolExporter : IWebServiceDataDispatcher
    {
        public string ReportID { get; set; }
        public string RequestXML { get; set; }
        public string ResponseXML { get; set; }
        public string ReportType { get; set; }
        /// <summary>
        /// Used for generating data in required json format and exporting it.
        /// </summary>
        /// <param name="exportWebServiceInfo">Object</param>
        /// <param name="tableNameorQuery">Report query</param>
        /// <param name="exportFileFullPath"></param>
        /// <param name="processID">Batch process id</param>
        /// <returns></returns>
        public ExportStatus DispatchData(ExportWebServiceInfo exportWebServiceInfo, string tableNameorQuery, string exportFileFullPath, string processID)
        {
            ExportStatus exportStatus = new ExportStatus();
            string response = null;
            string clientId = null;
            string clientSecret = null;
            string grantType = null;
            string scope = null;
            string urlToken = null;
            string url = null;
            string secretKey = null;
            string authorization = null;
            string schema = null;
            string companyId = null;
            string reportXml = null;
            string reportId = null;
            try
            {
                StreamWriter streamWriter;
                using (var cmd_dp = new SqlCommand(tableNameorQuery, exportWebServiceInfo.Connection))
                {
                    using (SqlDataReader reader_dp = cmd_dp.ExecuteReader())
                    {
                        while (reader_dp.Read())
                        {
                            reportXml = reader_dp["source"].ToString();
                        }
                        reader_dp.Close();
                    }
                }

                this.RequestXML = reportXml;

                string[] queryParams = tableNameorQuery.Replace("'","").Split(',').Select(sValue => sValue.Trim()).ToArray();
                exportStatus.ProcessID = queryParams[6]; //7th parameter is the process id in SP

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

                exportStatus.FileName = "Nordpool_XML_" + DateTime.Now.ToString("yyyyddM_HHmmss") + ".xml";
                exportStatus.FilePath = System.IO.Path.Combine(exportStatus.FilePath, "temp_Note", exportStatus.FileName);

                using (streamWriter = File.CreateText(exportStatus.FilePath))
                {
                    streamWriter.WriteLine(reportXml);
                    streamWriter.Close();
                }

                SqlCommand cmd_param = new SqlCommand("spa_generic_mapping_header", exportWebServiceInfo.Connection);
                cmd_param.CommandType = CommandType.StoredProcedure;
                cmd_param.Parameters.Add(new SqlParameter("@flag", "a"));
                cmd_param.Parameters.Add(new SqlParameter("@mapping_name", "Web Service"));
                cmd_param.Parameters.Add(new SqlParameter("@primary_column_value", "NordpoolExporter"));
                using (SqlDataReader reader_param = cmd_param.ExecuteReader())
                {
                    if (reader_param.HasRows)
                    {
                        reader_param.Read();
                        urlToken = reader_param["Web Service Token URL"].ToString();
                        url = reader_param["Web Service URL"].ToString();
                        clientId = reader_param["Client ID"].ToString();
                        clientSecret = reader_param["Client Secret"].ToString();
                        grantType = reader_param["Grant Type"].ToString();
                        scope = reader_param["Scope"].ToString();
                        authorization = reader_param["Authorization"].ToString();
                        secretKey = reader_param["Secret Key"].ToString();
                        //schema = reader_param["Schema"].ToString();
                        companyId = reader_param["Company"].ToString();
                    }
                }

                this.ReportType = queryParams[7];
                switch (ReportType) {
                    case "39400": // Non Standard
                        schema = "REMITTable2_V1";
                        break;
                    case "39401": //Standard
                    case "39405": // Execution
                        schema = "REMITTable1_V2";
                        break;
                    default:
                        schema = "REMITTable2_V1";
                        break;
                }

                string accessToken = "";
                var request = (HttpWebRequest)WebRequest.Create(urlToken);
                request.Timeout = 30000;
                request.UseDefaultCredentials = true;
                request.PreAuthenticate = true;
                request.Credentials = CredentialCache.DefaultCredentials;
                string postData = "username=" + clientId + "&password=" + clientSecret + "&grant_type=" + grantType + "&scope=" + scope;

                var data = Encoding.ASCII.GetBytes(postData);
                request.Method = "POST";
                request.ContentType = "application/x-www-form-urlencoded";
                request.ContentLength = data.Length;
                request.Headers.Add("Authorization", "Basic " + authorization);


                using (var stream = request.GetRequestStream())
                {
                    stream.Write(data, 0, data.Length);
                    stream.Close();
                }

                var httpResponse = (HttpWebResponse)request.GetResponse();

                var responseString = new StreamReader(httpResponse.GetResponseStream()).ReadToEnd();
                string refineData = responseString.Replace(":", ",").Replace("{", "").Replace("}", "");
                string[] arrayData = refineData.Split(',').Select(sValue => sValue.Trim()).ToArray();
                accessToken = arrayData[1].Replace(@"""", "");
                if (accessToken != "") {
                     url = url.Replace(":companyId", companyId);
                     url = url.Replace(":remitSchema", schema);
                     ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                     var httpWebRequest = (HttpWebRequest)WebRequest.Create(url);
                     httpWebRequest.Method = "POST";
                     httpWebRequest.ContentType = "application/xml";
                     httpWebRequest.Headers.Add("Authorization", "Bearer " + accessToken);
                     using (streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
                     {
                         streamWriter.Write(reportXml);
                         streamWriter.Close();
                     }

                     using (var httpResponse1 = (HttpWebResponse)httpWebRequest.GetResponse())
                     {
                         using (var streamReader = new StreamReader(httpResponse1.GetResponseStream()))
                         {
                             response = streamReader.ReadToEnd();
                             //response = "{\"ReportId\":\"78369742-e359-4af1-9de4-4e3b1f6651fe\"}";
                         }
                         //response = httpResponse1.StatusDescription;
                     }
                     this.ResponseXML = response;
                     refineData = response.Replace(":", ",").Replace("{", "").Replace("}", "");
                     string[] arrayDataResponse = refineData.Split(',').Select(sValue => sValue.Trim()).ToArray();
                     reportId = arrayDataResponse[1].Replace(@"""", "");
                     this.ReportID = reportId;
                }
                


                exportStatus.Status = "Success";
                exportStatus.ResponseMessage = "Report has been successfully submitted."
                                                + "Report ID :- " + reportId;
                                                
                BuildNordpoolMessaging(exportStatus, exportWebServiceInfo.Connection);
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
                if (exportStatus.ResponseMessage == "") 
                {
                    try
                    {
                        exportStatus.ResponseMessage = ((HttpWebResponse)webEx.Response).StatusDescription;
                    }
                    catch (Exception e)
                    {
                        exportStatus.ResponseMessage = "The request cannot be fulfilled due to incorrect format. ";
                    }
                }
                exportStatus.Status = "Failed";
                exportStatus.Exception = webEx;
                BuildNordpoolMessaging(exportStatus, exportWebServiceInfo.Connection);
            }
            catch (Exception ex)
            {
                //handle other exeception (like IOException [path not accessible])
                exportStatus.ResponseMessage = ex.Message;
                exportStatus.Status = "Failed";
                exportStatus.Exception = ex;
                BuildNordpoolMessaging(exportStatus, exportWebServiceInfo.Connection);
            }
            return exportStatus;
        }
        /// <summary>
        /// Calls SP to insert success/error message in the message board
        /// </summary>
        /// <param name="exportStatus"></param>
        /// <param name="cn"></param>
        
        private void BuildNordpoolMessaging(ExportStatus exportStatus, SqlConnection cn)
        {
            using (SqlCommand cmd = new SqlCommand("spa_nordpool_exporter", cn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new SqlParameter("@flag", "m"));
                cmd.Parameters.Add(new SqlParameter("@type", exportStatus.Status));
                cmd.Parameters.Add(new SqlParameter("@remit_process_id", exportStatus.ProcessID));
                cmd.Parameters.Add(new SqlParameter("@file_name", exportStatus.FileName));
                cmd.Parameters.Add(new SqlParameter("@file_location", exportStatus.FilePath));
                cmd.Parameters.Add(new SqlParameter("@message", exportStatus.ResponseMessage));
                cmd.Parameters.Add(new SqlParameter("@report_id", this.ReportID));
                cmd.Parameters.Add(new SqlParameter("@request_xml", this.RequestXML));
                cmd.Parameters.Add(new SqlParameter("@response_xml", this.ResponseXML));
                cmd.Parameters.Add(new SqlParameter("@report_type", this.ReportType));
                cmd.ExecuteNonQuery();
            }
        }

    }
    #endregion
}
