using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Net;
using System.IO;
using System.Xml;
using System.Data;
using System.Xml.Linq;
using FARRMSUtilities;
namespace FARRMSExportCLR
{
    #region EznergyTDSExporter Business logic for EznergyTDSExporter
    /// <summary>
    /// Bussiness logic for Eznergy Time Decimal Segment.
    /// </summary>
    internal class EznergyTDSExporter : IWebServiceDataDispatcher
    {
        public TimeSeriesInfo timeSeriesInfo { get; set; }

        /// <summary>
        /// Authenticate user and get token for other requests
        /// </summary>
        /// <param name="exportWebServiceInfo"></param>
        /// <param name="exportStatus"></param>
        /// <param name="tds"></param>
        /// <returns>bool status</returns>
        #region GenerateToken
        public bool GenerateToken(ExportWebServiceInfo exportWebServiceInfo, ExportStatus exportStatus, TimeSeriesInfo tds)
        {
            string responseToken = "";
            bool status = true;
            try
            {
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                var RequestForToken = (HttpWebRequest)WebRequest.Create(exportWebServiceInfo.webServiceURL);
                var userCredentialsxml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<userCredentials>\r\n\t<login>" + exportWebServiceInfo.userName + "</login>\r\n\t<password>" + exportWebServiceInfo.password + "</password>\r\n</userCredentials>";
                var PostUserData = Encoding.ASCII.GetBytes(userCredentialsxml);
                RequestForToken.ContentLength = PostUserData.Length;
                RequestForToken.Timeout = -1;
                RequestForToken.UseDefaultCredentials = true;
                RequestForToken.PreAuthenticate = true;
                RequestForToken.Credentials = CredentialCache.DefaultCredentials;
                RequestForToken.Method = "POST";
                RequestForToken.ContentType = "application/xml";

                using (var RequestForTokenStream = RequestForToken.GetRequestStream())
                {
                    RequestForTokenStream.Write(PostUserData, 0, PostUserData.Length);
                    RequestForTokenStream.Flush();
                    RequestForTokenStream.Close();
                }

                using (var httpResponse = (HttpWebResponse)RequestForToken.GetResponse())
                {
                    using (var response = RequestForToken.GetResponse())
                    {
                        using (var stream = response.GetResponseStream())
                        {
                            using (var reader = new StreamReader(stream))
                            {
                                responseToken = reader.ReadToEnd();
                                XmlDocument doc = new XmlDocument();
                                doc.LoadXml(responseToken);
                                XmlNodeList oXmlNodeList = doc.SelectNodes("token/tokenId");

                                foreach (XmlNode x in oXmlNodeList)
                                {
                                    exportWebServiceInfo.authToken = x.InnerText.ToString();
                                }

                                #region Update token 
                                if (!string.IsNullOrEmpty(exportWebServiceInfo.authToken))
                                {
                                    exportWebServiceInfo.Connection.Open();
                                    SqlCommand cmd = new SqlCommand("UPDATE export_web_service SET auth_token = '" + exportWebServiceInfo.authToken + "',  token_updated_date = GETDATE() WHERE ws_name = '" + exportWebServiceInfo.wsName + "'", exportWebServiceInfo.Connection);
                                    SqlDataReader dataReader = cmd.ExecuteReader();

                                    exportWebServiceInfo.Connection.Close();
                                }
                                #endregion
                                status = true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                status = false;
                BuildMessagesLog("Failed to generate token", exportStatus.ProcessID, exportStatus.FileName, "Error", tds.newProcessID, tds.jobName, ex.Message);
                MessageBoard("TimeSeries Decimal Segment", exportStatus.ProcessID, exportStatus.FileName, "Error", tds.newProcessID, tds.jobName, "e");

            }

            return status;
        }
        #endregion

        /// <summary>
        /// Push data in API
        /// </summary>
        /// <param name="exportWebServiceInfo"></param>
        /// <param name="timeSeriesInfo"></param>
        /// <param name="getReportDataItems"></param>
        /// <param name="exportStatus"></param>
        /// <param name="flag"></param>
        /// <returns>status</returns>
        public TimeSeriesStatus PutTimeSeries(ExportWebServiceInfo exportWebServiceInfo, TimeSeriesInfo timeSeriesInfo, List<TimeSeriesInfo> getReportDataItems, ExportStatus exportStatus, String flag)
        {
            string ContractGUID = exportWebServiceInfo.authKey;
            TimeSeriesStatus status = null;
            try
            {
                var getUniqueTimeSerieIds = getReportDataItems.GroupBy(x => new
                {
                    x.timeSerieId
                }).Select(y => new TimeSeriesInfo()
                {
                    timeSerieId = y.Key.timeSerieId

                }).ToList();

                for (int x = 0; x < getUniqueTimeSerieIds.Count; x++)
                {
                    string appendXml = "";
                    timeSeriesInfo.timeSerieId = getUniqueTimeSerieIds[x].timeSerieId;
                    StringBuilder builder = new StringBuilder();

                    for (int y = 0; y < getReportDataItems.Count; y++)
                    {
                        if (timeSeriesInfo.timeSerieId == getReportDataItems[y].timeSerieId)
                        {
                            builder.Append("<decimalSegment><startDate>" + getReportDataItems[y].startDate +
                            "</startDate><endDate>" + getReportDataItems[y].endDate + "</endDate><value>"
                            + getReportDataItems[y].value + "</value></decimalSegment>");
                        }
                        appendXml = builder.ToString();
                    }

                    timeSeriesInfo.xmlDecimalSegments = XElement.Parse("<decimalSegments>" + appendXml + "</decimalSegments>").ToString();
                    exportStatus.FileName = "";
                    string resolveFilesPath = exportStatus.FilePath;
                    exportStatus.FileName = "DecimalSegments-timeSerieId-" + timeSeriesInfo.timeSerieId + "-" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".xml";
                    resolveFilesPath = System.IO.Path.Combine(resolveFilesPath, "temp_Note", exportStatus.FileName);

                    using (var streamWriter = File.CreateText(resolveFilesPath))
                    {
                        streamWriter.WriteLine(timeSeriesInfo.xmlDecimalSegments);
                        streamWriter.Close();
                    }

                    try
                    {
                        ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                        var requestToPush = (HttpWebRequest)WebRequest.Create(exportWebServiceInfo.webServiceURL.Replace("/tokens", "") + "/" + ContractGUID + "/timeseries/decimal/" + timeSeriesInfo.timeSerieId + "/segments");
                        var PostDSData = Encoding.ASCII.GetBytes(timeSeriesInfo.xmlDecimalSegments);

                        requestToPush.ContentLength = PostDSData.Length;
                        requestToPush.Timeout = -1;
                        requestToPush.UseDefaultCredentials = true;
                        requestToPush.PreAuthenticate = true;
                        requestToPush.Credentials = CredentialCache.DefaultCredentials;
                        requestToPush.Method = "PUT";
                        requestToPush.ContentType = "application/xml";
                        requestToPush.Headers.Add("X-Auth-Token", exportWebServiceInfo.authToken);

                        using (var requestToPushStream = requestToPush.GetRequestStream())
                        {
                            requestToPushStream.Write(PostDSData, 0, PostDSData.Length);
                            requestToPushStream.Flush();
                            requestToPushStream.Close();

                        }

                        using (var httprequestToPush = (HttpWebResponse)requestToPush.GetResponse())
                        {
                            var statusCode = (int)httprequestToPush.StatusCode;
                            if (statusCode == 204)
                            {
                                BuildMessagesLog("Numeric segments edited", exportStatus.ProcessID, exportStatus.FileName, "Success", timeSeriesInfo.newProcessID, timeSeriesInfo.jobName, "");
                                exportStatus.Status = "Success";
                            }
                            else if (statusCode == 400)
                            {
                                BuildMessagesLog("Miss segments parameter", exportStatus.ProcessID, exportStatus.FileName, "Error", timeSeriesInfo.newProcessID, timeSeriesInfo.jobName, "");
                                exportStatus.Status = "Error";
                            }
                        }
                    }
                    catch (WebException webExs)
                    {
                        if (webExs.Status == WebExceptionStatus.ProtocolError)
                        {
                            if ((webExs.Response as HttpWebResponse).StatusCode == HttpStatusCode.Unauthorized)
                            {
                                status = new TimeSeriesStatus { Status = "Unauthorized", ResponseMessage = webExs.Message, Exception = null };
                                return status;
                            }
                            else
                            {
                                BuildMessagesLog("Failed to post data", exportStatus.ProcessID, exportStatus.FileName, "Error", timeSeriesInfo.newProcessID, timeSeriesInfo.jobName, webExs.Message);
                                exportStatus.Status = "Error";
                                exportStatus.Exception = webExs;
                                status = new TimeSeriesStatus { Status = "Error", ResponseMessage = webExs.Message, Exception = null };
                            }
                        }
                    }
                }
                MessageBoard("TimeSeries Decimal Segment", exportStatus.ProcessID, exportStatus.FileName, "Success", timeSeriesInfo.newProcessID, timeSeriesInfo.jobName, flag);
                exportStatus.Status = "Success";
                status = new TimeSeriesStatus { Status = "Success", ResponseMessage = "TimeSeries Decimal Segment", Exception = null };

            }
            catch (WebException webEx)
            {
                BuildMessagesLog("Failed to post data", exportStatus.ProcessID, exportStatus.FileName, "Error", timeSeriesInfo.newProcessID, timeSeriesInfo.jobName, webEx.Message);
                exportStatus.Status = "Error";
                exportStatus.Exception = webEx;
                status = new TimeSeriesStatus { Status = "Error", ResponseMessage = webEx.Message, Exception = null };
            }
            catch (Exception ex)
            {
                BuildMessagesLog("Failed to post data", exportStatus.ProcessID, exportStatus.FileName, "Error", timeSeriesInfo.newProcessID, timeSeriesInfo.jobName, ex.Message);
                exportStatus.Status = "Error";
                exportStatus.Exception = ex;
                status = new TimeSeriesStatus { Status = "Error", ResponseMessage = ex.Message, Exception = null };

            }
            return status;
        }


        /// <summary>
        /// Used report exporter to push data in API
        /// </summary>
        /// <param name="exportWebServiceInfo"></param>
        /// <param name="tableNameorQuery"></param>
        /// <param name="exportFileFullPath"></param>
        /// <param name="processID"></param>
        /// <returns></returns>
        public ExportStatus DispatchData(ExportWebServiceInfo exportWebServiceInfo, string tableNameorQuery, string exportFileFullPath, string processID)
        {
            ExportStatus exportStatus = new ExportStatus();
            exportStatus.ProcessID = processID;

            TimeSeriesInfo tds = new TimeSeriesInfo();
            tds.newProcessID = Guid.NewGuid().ToString().Replace("-", "_").ToUpper() + "_" + Guid.NewGuid().ToString().Replace("-", "").Substring(0, 13).ToUpper();
            tds.jobName = "report_batch" + "_" + tds.newProcessID;

            try
            {
                this.timeSeriesInfo = new TimeSeriesInfo();
                #region Run spa_rfx_run_sql to dump data in process table
                SqlCommand cmd = new SqlCommand(tableNameorQuery, exportWebServiceInfo.Connection);
                SqlDataReader queryRead = cmd.ExecuteSessionReader();
                queryRead.Close();
                exportWebServiceInfo.Connection.Close();
                #endregion

                string flag = null;

                flag = (tableNameorQuery.IndexOf("spa_rfx_run_sql") > 0) ? "m" : "n";

                #region Report data table name
                exportWebServiceInfo.Connection.Open();
                using (cmd = new SqlCommand("SELECT dbo.FNAProcessTableName('batch_report', NULL, '" + processID + "') [process_table]", exportWebServiceInfo.Connection))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            timeSeriesInfo.ProcessTable = reader["process_table"].ToString();
                        }
                        reader.Close();
                    }
                }
                exportWebServiceInfo.Connection.Close();
                #endregion

                #region Document path
                exportWebServiceInfo.Connection.Open();
                using (cmd = new SqlCommand("SELECT document_path FROM connection_string", exportWebServiceInfo.Connection))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            exportStatus.FilePath = reader["document_path"].ToString();
                        }
                        reader.Close();
                    }
                }
                exportWebServiceInfo.Connection.Close();
                #endregion

                #region for Token
               //get new token if token is emty or last updated token date is or last updated token time is greater than 10 hrs
                if (string.IsNullOrEmpty(exportWebServiceInfo.authToken) || string.IsNullOrEmpty(exportWebServiceInfo.tokenUpdatedDate) || ((DateTime.Now.Subtract(DateTime.Parse(exportWebServiceInfo.tokenUpdatedDate)).TotalHours) > 10))
                {
                    bool token = GenerateToken(exportWebServiceInfo, exportStatus, tds);
                    if (!token)
                    {
                        exportStatus.Status = "Error";
                        return exportStatus;
                    }
                }
                #endregion

                #region post Logic
                var getReportDataItems = timeSeriesInfo.getItemsTimeSeriesInfo();
                TimeSeriesStatus response = PutTimeSeries(exportWebServiceInfo, tds, getReportDataItems, exportStatus, flag);
                if (response.Status == "Unauthorized")
                {
                    bool token = GenerateToken(exportWebServiceInfo, exportStatus, tds);
                    if (!token)
                    {
                        exportStatus.Status = "Error";
                        return exportStatus;
                    }
                    response = PutTimeSeries(exportWebServiceInfo, tds, getReportDataItems, exportStatus, flag);
                    exportStatus.Status = response.Status;                        
                }
                
                #endregion 
            }

            catch (WebException webEx)
            {
                BuildMessagesLog("Failed to post data", exportStatus.ProcessID, exportStatus.FileName, "Error", tds.newProcessID, tds.jobName, webEx.Message);
                MessageBoard("TimeSeries Decimal Segment", exportStatus.ProcessID, exportStatus.FileName, "Error", tds.newProcessID, tds.jobName, "e");
                exportStatus.Status = "Error";
                exportStatus.Exception = webEx;
            }
            catch (Exception ex)
            {
                BuildMessagesLog("Failed to post data", exportStatus.ProcessID, exportStatus.FileName, "Error", tds.newProcessID, tds.jobName, ex.Message);
                MessageBoard("TimeSeries Decimal Segment", exportStatus.ProcessID, exportStatus.FileName, "Error", tds.newProcessID, tds.jobName, "e");
                exportStatus.Status = "Error";
                exportStatus.Exception = ex;
            }

            return exportStatus;
        }

        
        #region Messaging board
        public void MessageBoard(string msg, string ProcessId, string fFileName, string Status, string newProcessID, String jobName, string flag)
        {

            //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
            using (SqlConnection con = new SqlConnection("Context Connection=true"))
            {
                using (SqlCommand cmdm = new SqlCommand("spa_remote_service_response_log", con))
                {
                    cmdm.CommandType = CommandType.StoredProcedure;
                    cmdm.Parameters.Add(new SqlParameter("@flag", flag));
                    cmdm.Parameters.Add(new SqlParameter("@response_status", Status));
                    cmdm.Parameters.Add(new SqlParameter("@response_message", msg));
                    cmdm.Parameters.Add(new SqlParameter("@request_msg_detail", ""));
                    cmdm.Parameters.Add(new SqlParameter("@process_id", ProcessId));
                    cmdm.Parameters.Add(new SqlParameter("@type", "s"));
                    cmdm.Parameters.Add(new SqlParameter("@job_name", jobName));
                    cmdm.Parameters.Add(new SqlParameter("@source", "Timeseries Decimal Segments"));
                    cmdm.Parameters.Add(new SqlParameter("@new_process_id", newProcessID));
                    con.Open();
                    cmdm.ExecuteNonQuery();
                }
            }

        }

        #endregion 

        #region Messaging Logging part
        public void BuildMessagesLog(string msg, string ProcessId, string fileName, string Status, string newProcessID, string jobName, string responseMesage)
        {

            fileName = @"temp_Note/" + fileName;
            string urlDesc = (Status == "Success") ? "<b>" + msg + "</b>.Please <a target='_blank' href='../../adiha.php.scripts/force_download.php?path=dev/shared_docs/" + fileName + "'><b>Click Here</a></b> to download the XML file." :
                "<b>" + msg + "</b>.Please <a target='_blank' href='../../adiha.php.scripts/force_download.php?path=dev/shared_docs/" + fileName + "'><b>Click Here</a></b> to download the XML file." + "<font color='red'>(Error(s) Found).</font>";
            urlDesc = urlDesc.Replace("'", @"""");
            string type = (Status == "Success") ? "s" : "e";

            //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
            using (SqlConnection con = new SqlConnection("Context Connection=true"))
            {
                
                using (SqlCommand cmdn = new SqlCommand("spa_remote_service_response_log", con))
                {
                    cmdn.CommandType = CommandType.StoredProcedure;
                    cmdn.Parameters.Add(new SqlParameter("@flag", "i"));
                    cmdn.Parameters.Add(new SqlParameter("@response_status", Status));
                    cmdn.Parameters.Add(new SqlParameter("@response_message", msg));
                    cmdn.Parameters.Add(new SqlParameter("@request_msg_detail", urlDesc));
                    if (!string.IsNullOrEmpty(responseMesage))
                    {
                        cmdn.Parameters.Add(new SqlParameter("@response_msg_detail", responseMesage));
                    }
                    cmdn.Parameters.Add(new SqlParameter("@new_process_id", newProcessID));
                    cmdn.Parameters.Add(new SqlParameter("@type", type));
                    cmdn.Parameters.Add(new SqlParameter("@job_name", jobName));
                    cmdn.Parameters.Add(new SqlParameter("@source", "Timeseries Decimal Segments"));
                    con.Open();
                    cmdn.ExecuteNonQuery();
                }
            }

        }
        #endregion

    }

    #region Time Series info 
    public class TimeSeriesInfo
    {
        public Int64 timeSerieId { get; set; }
        public string startDate { get; set; }
        public string endDate { get; set; }
        public decimal value { get; set; }
        public string xmlDecimalSegments { get; set; }
        public string ProcessTable { get; set; }
        public string UniqueProcessID { get; set; }
        public string newProcessID { get; set; }
        public string jobName { get; set; }
        public List<TimeSeriesInfo> getItemsTimeSeriesInfo()
        {
            List<TimeSeriesInfo> lst = new List<TimeSeriesInfo>();
            try
            {
                //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                using (SqlConnection con = new SqlConnection("Context Connection=true"))
                {
                    con.Open();
                    var cmd1 = new SqlCommand("SELECT  [time series ID] [time series id] , (CONVERT(VARCHAR(100), [startDate], 127) + 'Z') [term start], (CONVERT(VARCHAR(19), [endDate], 127) + 'Z') [term end], Position [value] from " + ProcessTable + " ORDER BY [time series ID],[startDate] ASC ", con);
                    SqlDataAdapter sda = new SqlDataAdapter(cmd1);
                    DataTable dtResult = new DataTable();
                    sda.Fill(dtResult);

                    if (dtResult.Rows.Count > 0)
                    {
                        for (int i = 0; i < dtResult.Rows.Count; i++)
                        {
                            lst.Add(new TimeSeriesInfo
                            {
                                timeSerieId = Convert.ToInt64(dtResult.Rows[i]["time series id"]),
                                startDate = dtResult.Rows[i]["term start"].ToString(),
                                endDate = dtResult.Rows[i]["term end"].ToString(),
                                value = Math.Round(Convert.ToDecimal(dtResult.Rows[i]["value"]), 3)
                            });
                        }
                    }
                    con.Close();
                }


            }
            catch (Exception ex)
            {
                ex.LogError("EznergyTDSExporter",  ex.Message);
            }
            return lst;
        }
    }
    #endregion
    public class TimeSeriesStatus
    {
        public string Status { get; set; }
        public string ResponseMessage { get; set; }
        public Exception Exception { get; set; }
    }
}
#endregion