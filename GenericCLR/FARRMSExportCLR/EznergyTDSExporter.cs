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

                string responseToken = "";
                string tokenId = "";
                string ContractGUID = exportWebServiceInfo.authToken;

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
                                    tokenId = x.InnerText.ToString();

                                }
                            }
                        }
                    }
                }
                #endregion

                #region post Logic
                if (tokenId != "")
                {
                    var getReportDataItems = timeSeriesInfo.getItemsTimeSeriesInfo();

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

                        for (int y = 0; y < getReportDataItems.Count(); y++)
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
                            requestToPush.Headers.Add("X-Auth-Token", tokenId);

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
                                    BuildMessagesLog("Numeric segments edited", exportStatus.ProcessID, exportStatus.FileName, "Success", tds.newProcessID, tds.jobName);
                                    exportStatus.Status = "Success";
                                }
                                else if (statusCode == 400)
                                {
                                    BuildMessagesLog("Miss segments parameter", exportStatus.ProcessID, exportStatus.FileName, "Error", tds.newProcessID, tds.jobName);
                                    exportStatus.Status = "Error";
                                }
                            }
                        }
                        catch (WebException webExs)
                        {
                            BuildMessagesLog("Failed to post data", exportStatus.ProcessID, exportStatus.FileName, "Error", tds.newProcessID, tds.jobName);
                            webExs.LogError("TimeSeries Decimal Segment", webExs.Message);
                        }
                        finally
                        {

                        }
                    }
                    MessageBoard("TimeSeries Decimal Segment", exportStatus.ProcessID, exportStatus.FileName, "Success", tds.newProcessID, tds.jobName, flag);

                }
                #endregion 
            }

            catch (WebException webEx)
            {
                exportStatus.Status = "Error";
                BuildMessagesLog("Failed to post data", exportStatus.ProcessID, exportStatus.FileName, "Error", tds.newProcessID, tds.jobName);
                webEx.LogError("TimeSeries Decimal Segment", webEx.Message);
            }
            catch (Exception ex)
            {
                exportStatus.Status = "Error";
                BuildMessagesLog("Failed to post data", exportStatus.ProcessID, exportStatus.FileName, "Error", tds.newProcessID, tds.jobName);
                ex.LogError("TimeSeries Decimal Segment", ex.Message);
            }

            return exportStatus;
        }

        #region Messaging board
        public void MessageBoard(string msg, string ProcessId, string fileName, string Status, string newProcessID, String jobName, string flag)
        {

            //using (SqlConnection con = new SqlConnection(@"Data Source=SG-D-SQL02.farrms.us,2034;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
            using (SqlConnection con = new SqlConnection("Context Connection=true"))
            {
                try
                {
                    using (SqlCommand cmdm = new SqlCommand("spa_remote_service_response_log", con))
                    {
                        cmdm.CommandType = CommandType.StoredProcedure;
                        cmdm.Parameters.Add(new SqlParameter("@flag", flag));
                        cmdm.Parameters.Add(new SqlParameter("@response_status", Status));
                        cmdm.Parameters.Add(new SqlParameter("@response_message", msg));
                        cmdm.Parameters.Add(new SqlParameter("@request_msg_detail", null));
                        cmdm.Parameters.Add(new SqlParameter("@process_id", ProcessId));
                        cmdm.Parameters.Add(new SqlParameter("@type", "s"));
                        cmdm.Parameters.Add(new SqlParameter("@job_name", jobName));
                        cmdm.Parameters.Add(new SqlParameter("@source", "Timeseries Decimal Segments"));
                        cmdm.Parameters.Add(new SqlParameter("@new_process_id", newProcessID));
                        con.Open();
                        cmdm.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    ex.LogError("TimeSeries Decimal Segment", ex.Message);
                }
                finally
                {
                    con.Close();
                }
            }

        }

        #endregion 

        #region Messaging Logging part
        public void BuildMessagesLog(string msg, string ProcessId, string fileName, string Status, string newProcessID, string jobName)
        {

            fileName = @"temp_Note/" + fileName;
            string urlDesc = (Status == "Success") ? "<b>" + msg + "</b>.Please <a target='_blank' href='../../adiha.php.scripts/force_download.php?path=dev/shared_docs/" + fileName + "'><b>Click Here</a></b> to download the XML file." :
                "<b>" + msg + "</b>.Please <a target='_blank' href='../../adiha.php.scripts/force_download.php?path=dev/shared_docs/" + fileName + "'><b>Click Here</a></b> to download the XML file." + "<font color='red'>(Error(s) Found).</font>";
            urlDesc = urlDesc.Replace("'", @"""");
            string type = (Status == "Success") ? "s" : "e";
            //using (SqlConnection con = new SqlConnection(@"Data Source=SG-D-SQL02.farrms.us,2034;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
            using (SqlConnection con = new SqlConnection("Context Connection=true"))
            {
                try
                {
                    using (SqlCommand cmdn = new SqlCommand("spa_remote_service_response_log", con))
                    {
                        cmdn.CommandType = CommandType.StoredProcedure;
                        cmdn.Parameters.Add(new SqlParameter("@flag", "i"));
                        cmdn.Parameters.Add(new SqlParameter("@response_status", Status));
                        cmdn.Parameters.Add(new SqlParameter("@response_message", msg));
                        cmdn.Parameters.Add(new SqlParameter("@request_msg_detail", urlDesc));
                        cmdn.Parameters.Add(new SqlParameter("@new_process_id", newProcessID));
                        cmdn.Parameters.Add(new SqlParameter("@type", type));
                        cmdn.Parameters.Add(new SqlParameter("@job_name", jobName));
                        cmdn.Parameters.Add(new SqlParameter("@source", "Timeseries Decimal Segments"));
                        con.Open();
                        cmdn.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    ex.LogError("TimeSeries Decimal Segment", ex.Message);
                }
                finally
                {
                    con.Close();
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
                //using (SqlConnection con = new SqlConnection(@"Data Source=SG-D-SQL02.farrms.us,2034;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
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
                ex.LogError("TimeSeries Decimal Segment", ex.Message);
            }
            finally
            {

            }
            return lst;
        }
    }
    #endregion
}
#endregion