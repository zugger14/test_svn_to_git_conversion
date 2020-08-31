using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Net;
using System.IO;
using System.Data.SqlClient;
using System.Data;
using System.Xml;
using FARRMSUtilities;

namespace FARRMSExportCLR
{
    #region RegisTrExporter Business logic for RegisTR
    /// <summary>
    /// For posting data using SOAP for RegisTR
    /// </summary>
    class RegisTrExporter : IWebServiceDataDispatcher
    {
        public string RequestXML { get; set; }
        public string ResponseXML { get; set; }
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
            string request_xml = null;
            string response = null;
            string response_xml = null;
            string process_table = null;
            string temp_xml_path = null;
            string xls_path = null;
            string xml_content = null;
            string request_url = null;
            string soap_action_url = null;
            string host_url = null;
            try
            {
                SqlCommand cmd_param = new SqlCommand("spa_registr_exporter", exportWebServiceInfo.Connection);
                cmd_param.CommandType = CommandType.StoredProcedure;
                cmd_param.Parameters.Add(new SqlParameter("@flag", "s"));
                cmd_param.Parameters.Add(new SqlParameter("@process_id", processID));
                using (SqlDataReader reader_param = cmd_param.ExecuteReader())
                {
                    if (reader_param.HasRows)
                    {
                        reader_param.Read();
                        process_table = reader_param["process_table"].ToString();
                    }
                    reader_param.Close();
                }
                
                //process_table = "adiha_process.dbo.batch_report_shikharbasnet_607FD771_8953_4E89_99BF_D80D2976CEB9_5d64072d49c8c";

                using (var cmd_dp = new SqlCommand("SELECT document_path FROM connection_string", exportWebServiceInfo.Connection))
                {
                    using (SqlDataReader reader_dp = cmd_dp.ExecuteReader())
                    {
                        while (reader_dp.Read())
                        {
                            exportStatus.FilePath = reader_dp["document_path"].ToString();
                        }
                        reader_dp.Close();
                    }
                }
                
                //exportStatus.FilePath = "\\\\PSDL02\\shared_docs_TRMTracker_Release";
                exportStatus.FileName = "RegisTR_" + DateTime.Now.ToString("yyyyddM_HHmmss") + ".xml";
                temp_xml_path = System.IO.Path.Combine(exportStatus.FilePath, "temp_Note", "RegisTR_temp_" + DateTime.Now.ToString("yyyyddM_HHmmss") + ".xml");
                xls_path = System.IO.Path.Combine(exportStatus.FilePath, "xml_docs", "RegisTR.xsl");
                exportStatus.FilePath = System.IO.Path.Combine(exportStatus.FilePath, "temp_Note", exportStatus.FileName);

                //Generate standard XML from system and convert it to client XML format.
                exportWebServiceInfo.Connection.Close();
                Utility.CreateXMLDocument(process_table, "http://pioneersolutionsglobal.com/xml/ns", "RegisTr", "-100000", temp_xml_path, "n", out response_xml);
                //exportStatus.FilePath = "\\\\SG-D-WEB01\\shared_docs_TRMTracker_Release\\temp_Note\\RegisTr_new.xml";
                //StoredProcedure.TransformXML("\\\\SG-D-WEB01\\shared_docs_TRMTracker_Release\\temp_Note\\EMIR Reportttt_shikharbasnet_2019_08_27_004409.xml", "\\\\SG-D-WEB01\\shared_docs_TRMTracker_Release\\xml_docs\\RegisTr.xsl", "\\\\SG-D-WEB01\\shared_docs_TRMTracker_Release\\temp_Note\\RegisTr_new.xml", "n", "n", out response_xml);
                Utility.TransformXML(temp_xml_path, xls_path, exportStatus.FilePath, "n", "y", out response_xml);
                exportWebServiceInfo.Connection.Open();
                using (StreamReader streamReader = new StreamReader(exportStatus.FilePath, Encoding.UTF8))
                {
                    xml_content = streamReader.ReadToEnd();
                }

                SqlCommand cmd_request = new SqlCommand("spa_registr_exporter", exportWebServiceInfo.Connection);
                cmd_request.CommandType = CommandType.StoredProcedure;
                cmd_request.Parameters.Add(new SqlParameter("@flag", "r"));
                cmd_request.Parameters.Add(new SqlParameter("@xml_string", xml_content));
                using (SqlDataReader reader_request = cmd_request.ExecuteReader())
                {
                    if (reader_request.HasRows)
                    {
                        reader_request.Read();
                        request_xml = reader_request["request_xml"].ToString();
                        request_url = reader_request["request_url"].ToString(); 
                        soap_action_url = reader_request["soap_action_url"].ToString(); 
                        host_url = reader_request["host_url"].ToString();
                    }
                    reader_request.Close();
                }
                this.RequestXML = request_xml;
                
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);//SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(request_url);
                req.Headers.Add("SOAPAction", soap_action_url);
                req.ContentType = "text/xml;charset=\"utf-8\"";
                req.Accept = "text/xml";
                req.Method = "POST";
                req.KeepAlive = true;
                req.Host = host_url;

                
                using (Stream stream = req.GetRequestStream())
                {
                    using (StreamWriter stmw = new StreamWriter(stream))
                    {
                        stmw.Write(request_xml);
                    }
                }

                using (WebResponse webResponse = req.GetResponse())
                {
                    using (StreamReader streamReader = new StreamReader(webResponse.GetResponseStream()))
                    {
                        response = streamReader.ReadToEnd();
                    }
                }
                this.ResponseXML = response;
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(response);
                XmlNamespaceManager xmlnsManager = new System.Xml.XmlNamespaceManager(xmlDoc.NameTable);
                xmlnsManager.AddNamespace("soap", "http://schemas.xmlsoap.org/soap/envelope/");
                xmlnsManager.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance");
                xmlnsManager.AddNamespace("xsd", "http://www.w3.org/2001/XMLSchema");
                xmlnsManager.AddNamespace("si", "http://example.com/SystemIntegration");

                XmlNode node = xmlDoc.SelectSingleNode("/soap:Envelope/soap:Body", xmlnsManager);
                string response1 = node.InnerText;
                if (String.IsNullOrEmpty(response1))
                    exportStatus.Status = "Success";
                else
                    exportStatus.Status = "Failed";
                exportStatus.ResponseMessage = response1;
                
                BuildRegisTrMessaging(exportStatus, exportWebServiceInfo.Connection);
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
                BuildRegisTrMessaging(exportStatus, exportWebServiceInfo.Connection);
            }
            catch (Exception ex)
            {
                //handle other exeception (like IOException [path not accessible])
                exportStatus.ResponseMessage = ex.Message;
                exportStatus.Status = "Failed";
                exportStatus.Exception = ex;
                BuildRegisTrMessaging(exportStatus, exportWebServiceInfo.Connection);
            }
            return exportStatus;
        }

        /// <summary>
        /// Calls SP to insert success/error message in the message board
        /// </summary>
        /// <param name="exportStatus">Variable to store information related to web service status</param>
        /// <param name="cn">DB connection</param>
        private void BuildRegisTrMessaging(ExportStatus exportStatus, SqlConnection cn)
        {
            using (SqlCommand cmd = new SqlCommand("spa_registr_exporter", cn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new SqlParameter("@flag", "m"));
                cmd.Parameters.Add(new SqlParameter("@type", exportStatus.Status));
                cmd.Parameters.Add(new SqlParameter("@process_id", exportStatus.ProcessID));
                cmd.Parameters.Add(new SqlParameter("@file_name", exportStatus.FileName));
                cmd.Parameters.Add(new SqlParameter("@file_location", exportStatus.FilePath));
                cmd.Parameters.Add(new SqlParameter("@message", exportStatus.ResponseMessage));
                cmd.Parameters.Add(new SqlParameter("@request_xml", this.RequestXML));
                cmd.Parameters.Add(new SqlParameter("@response_xml", this.ResponseXML));
                cmd.ExecuteNonQuery();
            }
        }
    }
    #endregion
}
