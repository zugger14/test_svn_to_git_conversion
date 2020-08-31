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
    #region AFASFIEntriesExporter Business logic for AFASFIEntriesExporter
    /// <summary>
    /// Class to export Data to AFAS Web Service 
    /// </summary>
    class AFASFIEntriesExporter : IWebServiceDataDispatcher
    {
        /// <summary>
        /// Implentation of exporting data to web service
        /// </summary>
        /// <param name="exportWebServiceInfo">Information of Webservices </param>
        /// <param name="tableNameorQuery">Table name or query to get data from</param>
        /// <param name="exportFileFullPath">Not Used</param>
        /// <param name="processID">Unique Id for the process</param>
        /// <returns>Returns Export status</returns>
        public ExportStatus DispatchData(ExportWebServiceInfo exportWebServiceInfo, string tableNameorQuery, string exportFileFullPath, string processID)
        {
            ExportStatus exportStatus = new ExportStatus();
            exportStatus.ProcessID = processID;
			string response = null;
            string dataValue = null;
            //string filePath = null;
            //string fileName = null;
            try
            {
                //SqlConnection cn = new SqlConnection("Context Connection=true");
                //SqlConnection cn = new SqlConnection(@"Data Source=PSDD10\INSTANCE2016;Initial Catalog=TRMTracker_GreenChoice;Persist Security Info=True;User ID=farrms_admin;password=Admin2929");
               /* Drop table while debugging
                string tableNameo = "DROP TABLE adiha_process.dbo.batch_report_farrms_admin_07A7D948_FB8F_4B7A_8466_50D5C38D5EAB_5bc46d6161b75";
                SqlCommand cmd2 = new SqlCommand(tableNameo, exportWebServiceInfo.Connection);

                SqlDataReader queryRead1 = cmd2.ExecuteReader();
                queryRead1.Close();
                */
                SqlCommand cmd = new SqlCommand(tableNameorQuery, exportWebServiceInfo.Connection);

                SqlDataReader queryRead = cmd.ExecuteReader();
                queryRead.Close();
                
                string tableName = "";                
                string table = "SELECT dbo.FNAProcessTableName('batch_report', NULL, '" + processID + "') [process_table]";
               
                using (cmd = new SqlCommand(table, exportWebServiceInfo.Connection))
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
                
                SqlCommand cmd1 = new SqlCommand("spa_convert_to_afas_json", exportWebServiceInfo.Connection);
                cmd1.CommandType = CommandType.StoredProcedure;
                cmd1.Parameters.Add(new SqlParameter("@process_table_name", tableName));
               
                using (SqlDataReader rd =cmd1.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        dataValue = rd["json_data"].ToString();
                    }
                    rd.Close();
                }
                
                StreamWriter streamWriter;                
                cmd = new SqlCommand("SELECT document_path FROM connection_string", exportWebServiceInfo.Connection);
                using (SqlDataReader rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        exportStatus.FilePath = rd["document_path"].ToString();
                    }
                    rd.Close();
                }
                
                exportStatus.FileName = "AFASFIEntries_" + DateTime.Now.ToString("yyyyddM_HHmmss") + ".txt";
                exportStatus.FilePath = System.IO.Path.Combine(exportStatus.FilePath, "temp_Note", exportStatus.FileName);

                using (streamWriter = File.CreateText(exportStatus.FilePath))
                {
                    streamWriter.WriteLine(dataValue);
                    streamWriter.Close();
                }

                ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
                var httpWebRequest = (HttpWebRequest)WebRequest.Create(exportWebServiceInfo.webServiceURL);
                httpWebRequest.Headers.Add("Authorization", "AfasToken " + exportWebServiceInfo.authToken);
                httpWebRequest.ContentType = "application/json";
                httpWebRequest.PreAuthenticate = true; // indicates to send Authorization header with request.
                httpWebRequest.Method = "POST";

                using (streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
                {
                    streamWriter.Write(dataValue);
                    streamWriter.Close();
                }

                using (var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse())
                {
                    using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
                    {
                        response = streamReader.ReadToEnd();
                    }
                }

                exportStatus.ResponseMessage = response;
                exportStatus.Status = "Success";
                BuildAFASFIEntriesMessaging(exportStatus, exportWebServiceInfo.Connection);
                AFASAudit(exportStatus, exportWebServiceInfo.Connection);
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
                //throw new Exception(errorResponseMessage, webEx);
                //response = errorResponseMessage.Replace("{", string.Empty).Replace("}", string.Empty) + exportStatus.FilePath;
                exportStatus.ResponseMessage = errorResponseMessage;
                exportStatus.Status = "Failed";
                exportStatus.Exception = webEx;
                BuildAFASFIEntriesMessaging(exportStatus, exportWebServiceInfo.Connection);
                AFASAudit(exportStatus, exportWebServiceInfo.Connection);
            }
            catch (Exception ex)
            {
                //handle other exeception (like IOException [path not accessible])
                exportStatus.ResponseMessage = ex.Message;
                exportStatus.Status = "Failed";
                exportStatus.Exception = ex;
                BuildAFASFIEntriesMessaging(exportStatus, exportWebServiceInfo.Connection);
            }          
            return exportStatus;
        }
        /// <summary>
        /// Function to insert message in Message Board
        /// </summary>
        /// <param name="exportStatus">Status after exporting to Web Services</param>
        /// <param name="cn">SQL Connection</param>
        private void BuildAFASFIEntriesMessaging(ExportStatus exportStatus, SqlConnection cn)
        {
            using (SqlCommand cmd = new SqlCommand("spa_build_afas_messaging", cn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new SqlParameter("@flag", "m"));
                cmd.Parameters.Add(new SqlParameter("@type", exportStatus.Status));
                cmd.Parameters.Add(new SqlParameter("@process_id", exportStatus.ProcessID));
                cmd.Parameters.Add(new SqlParameter("@file_name",exportStatus.FileName));
                cmd.Parameters.Add(new SqlParameter("@file_location",exportStatus.FilePath));
                cmd.Parameters.Add(new SqlParameter("@message", exportStatus.ResponseMessage));
                cmd.ExecuteNonQuery();
            }
        }
        /// <summary>
        /// Function to add audit information
        /// </summary>
        /// <param name="exportStatus">Status after exporting to Web Services</param>
        /// <param name="cn">SQL Connection</param>
        private void AFASAudit(ExportStatus exportStatus, SqlConnection cn)
        {
            using (SqlCommand cmd = new SqlCommand("spa_build_afas_messaging", cn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new SqlParameter("@flag", "a"));
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

    //new exporter implementation example (to be put in its own file)
    //class XYZExporter : IWebServiceDataDispatcher
    //{

    //    public string DispatchData(ExportWebServiceInfo exportWebServiceInfo, string dataTableName, string query)
    //    {
    //    }
    //}

}
