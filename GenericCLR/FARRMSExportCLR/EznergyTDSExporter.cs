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
            this.timeSeriesInfo = new TimeSeriesInfo();
            #region Run spa_rfx_run_sql to dump data in process table
            SqlCommand cmd = new SqlCommand(tableNameorQuery, exportWebServiceInfo.Connection);
            SqlDataReader queryRead = cmd.ExecuteReader();
            queryRead.Close();
            exportWebServiceInfo.Connection.Close();
            #endregion

            string responseToken = "";
            string tokenId = "";
            string ContractGUID = "EZ50bc6269ac";

            try
            {
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

                    timeSeriesInfo.timeSerieId = getReportDataItems.ToList().FirstOrDefault().timeSerieId;
                    timeSeriesInfo.xmlDecimalSegments = new XElement("decimalSegments",
                        from vals in getReportDataItems
                        select new XElement("decimalSegment",
                            new XElement("startDate", vals.startDate),
                            new XElement("endDate", vals.endDate),
                            new XElement("value", vals.value))).ToString();

                    exportStatus.FileName = "DecimalSegments" + timeSeriesInfo.timeSerieId + DateTime.Now.ToString("yyyyMMddHHmmss") + ".xml";
                    exportStatus.FilePath = System.IO.Path.Combine(exportStatus.FilePath, "temp_Note", exportStatus.FileName);
                    string outputFile = "";
                    Utility.WriteToFile(timeSeriesInfo.xmlDecimalSegments, "y", exportStatus.FilePath, out outputFile);
                    if (outputFile != "1") 
                    { 
                    
                    }
                    
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
                            MessageBoard("Numeric segments edited", exportStatus.ProcessID, exportStatus.FileName, "Success");
                            exportStatus.Status = "Success";
                        }
                        else if (statusCode == 400)
                        {
                            MessageBoard("Miss segments parameter", exportStatus.ProcessID, exportStatus.FileName, "Error");
                            exportStatus.Status = "Error";
                        }
                    }

                }
                #endregion 
            }

            catch (WebException webEx)
            {
                exportStatus.Status = "Error";
                MessageBoard("Failed to post data", exportStatus.ProcessID, exportStatus.FileName, "Error");
                webEx.LogError("TimeSeriesDecimalSegment", webEx.Message);
            }
            catch (Exception ex)
            {
                exportStatus.Status = "Error";
                MessageBoard("Failed to post data", exportStatus.ProcessID, exportStatus.FileName, "Error");
                ex.LogError("TimeSeriesDecimalSegment", ex.Message);
            }

            return exportStatus;
        }

        #region Messaging part
        public void MessageBoard(string msg, string ProcessId, string fileName, string Status)
        {
            fileName = @"temp_Note\" + fileName;
            string urlDesc = (Status == "Success") ? "<b>" + msg + "</b>.Please <a target='_blank' href='../../adiha.php.scripts/force_download.php?path=dev/shared_docs/" + fileName + "'><b>Click Here</a></b> to download the XML file." :
                "<b>" + msg + "</b>.Please <a target='_blank' href='../../adiha.php.scripts/dev/shared_docs/" + fileName + "'><b>Click Here</a></b> to download the XML file."+ "<font color='red'>(Error(s) Found).</font>";
            urlDesc = urlDesc.Replace("'", @"""");
            string type = (Status == "Success") ? "y" : "n";
            string jobName = "report_batch" + "_" + ProcessId;
            //using (SqlConnection con = new SqlConnection(@"Data Source=SG-D-SQL01.farrms.us,2033;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=trm_release_db_user;password=TRM@201912040234"))
            using (SqlConnection con = new SqlConnection("Context Connection=true"))
            {
                using (SqlCommand cmd = new SqlCommand("spa_message_board", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@flag", "u"));
                    cmd.Parameters.Add(new SqlParameter("@user_login_id", null));
                    cmd.Parameters.Add(new SqlParameter("@message_id", null));
                    cmd.Parameters.Add(new SqlParameter("@source", "TimeSeries Decimal Segments"));
                    cmd.Parameters.Add(new SqlParameter("@description", urlDesc));
                    cmd.Parameters.Add(new SqlParameter("@url", null));
                    cmd.Parameters.Add(new SqlParameter("@type", type));
                    cmd.Parameters.Add(new SqlParameter("@job_name", jobName));
                    cmd.Parameters.Add(new SqlParameter("@as_of_date", null));
                    cmd.Parameters.Add(new SqlParameter("@process_id", ProcessId));
                    cmd.Parameters.Add(new SqlParameter("@process_type", null));
                    cmd.Parameters.Add(new SqlParameter("@returnOutput", "n"));
                    con.Open();
                    cmd.ExecuteNonQuery();
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

        public List<TimeSeriesInfo> getItemsTimeSeriesInfo()
        {
            List<TimeSeriesInfo> lst = new List<TimeSeriesInfo>();
            //using(SqlConnection con = new SqlConnection(@"Data Source=SG-D-SQL01.farrms.us,2033;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=trm_release_db_user;password=TRM@201912040234"))
            using (SqlConnection con = new SqlConnection("Context Connection=true"))
            {
                con.Open();
                var cmd = new SqlCommand("SELECT * from " + ProcessTable, con);
                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dtResult = new DataTable();
                sda.Fill(dtResult);

                if (dtResult.Rows.Count > 0)
                {
                    for (int i = 0; i < dtResult.Rows.Count; i++)
                    {
                        lst.Add(new TimeSeriesInfo
                        {
                            timeSerieId = Convert.ToInt64(dtResult.Rows[i]["time serie id"]),
                            startDate = dtResult.Rows[i]["term start"].ToString(),
                            endDate = dtResult.Rows[i]["term end"].ToString(),
                            value = Convert.ToDecimal(dtResult.Rows[i]["value"])
                        });
                    }
                }
                con.Close();
            }
            return lst;
        }
    }
   #endregion  
}
#endregion 