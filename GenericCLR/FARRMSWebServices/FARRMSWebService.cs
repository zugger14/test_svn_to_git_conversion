using System;
using System.IO;
using System.Linq;
using System.Text;
using Microsoft.SqlServer.Server;
using FARRMS.WebServices.ReportExecution2005;
using FARRMS.WebServices.ReportService2005;
using System.Data.SqlClient;
using DataSourceCredentials = FARRMS.WebServices.ReportExecution2005.DataSourceCredentials;
using ParameterValue = FARRMS.WebServices.ReportExecution2005.ParameterValue;
using System.Data;
using System.Xml;
using System.Xml.Linq;
using System.Web.Services.Protocols;
using System.Text.RegularExpressions;

namespace FARRMS.WebServices
{
    public class SSRS
    {

        private void SendMessage(string message, bool debugMode = true)
        {
            if (debugMode)
                SqlContext.Pipe.Send(message);
        }

        /// <summary>
        /// Deploy ssrs rdl
        /// </summary>
        /// <param name="userName">ssrs username</param>
        /// <param name="password">ssrs password</param>
        /// <param name="hostName">ssrs domain</param>
        /// <param name="serverURL">report service url</param>
        /// <param name="reportTempFolder">connection string document path temp note folder</param>
        /// <param name="reportTargetFolder">ssrs report folder where rdl will be deployed</param>
        /// <param name="dataSource">ssrs report data source</param>
        /// <param name="reportName">report name</param>
        /// <param name="reportDescription">report description</param>
        /// <param name="debugMode">y send print messages in sql server used for debugging purpose</param>
        /// <param name="output">1 for success else failure message</param>
        public void DeployRDL(string userName, string password, string hostName, string serverURL, string reportTempFolder, string reportTargetFolder, string dataSource, string reportName, string reportDescription, string debugMode, out string output)
        {
            bool _debugMode = debugMode.ToLower() == "y";
            SendMessage("UserName:" + userName + "\r\nPassword:" + password + "\r\nHostName \\ Domain:" + hostName + "\r\nReport Server:" +
                        serverURL + "\r\nTemp Folder:" + reportTempFolder + "\r\nReport Target Folder:" + reportTargetFolder + "\r\nData Source:" + dataSource + "\r\nReport Name:" +
                        reportName + "\r\nReport Description:" + reportDescription, _debugMode);
            try
            {
                ReportingService2005 rs = new ReportingService2005();

                if (userName == "")
                {
                    rs.Credentials = System.Net.CredentialCache.DefaultCredentials;
                    rs.UseDefaultCredentials = true;
                }
                else
                {
                    System.Net.NetworkCredential clientCredentials = new System.Net.NetworkCredential(userName.ToString(), password, hostName);
                    rs.Credentials = clientCredentials;
                }

                rs.Url = serverURL + "/reportservice2005.asmx";

                // Open rdl file
                SendMessage("Open / Read RDL File :" + reportTempFolder + "\\" + reportName + ".rdl", _debugMode);
                FileStream rdlFile = File.OpenRead(reportTempFolder + "\\" + reportName + ".rdl");

                Byte[] reportDefinition = null;
                //read report definition nasty fix : - 1
                reportDefinition = new Byte[rdlFile.Length];
                rdlFile.Read(reportDefinition, 0, (int)rdlFile.Length);
                rdlFile.Close();

                Property reportProperty = new Property();
                reportProperty.Name = "Description";
                reportProperty.Value = reportDescription;

                Property[] reportProperties = new Property[1];
                reportProperties[0] = reportProperty;


                //  remove extra slashes if used 
                reportTargetFolder = reportTargetFolder.TrimStart('/').TrimEnd('/');
                SendMessage("Start Creating Report on Report Server", _debugMode);
                rs.CreateReport(reportName, "/" + reportTargetFolder, true, reportDefinition, reportProperties);

                //Set data source based on DataSource parameter
                DataSourceReference item1 = new DataSourceReference();
                DataSource[] datasources = rs.GetItemDataSources("/" + reportTargetFolder + "/" + reportName);
                item1.Reference = "/Data Sources/" + dataSource;
                datasources[0].Item = item1;
                rs.SetItemDataSources("/" + reportTargetFolder + "/" + reportName, datasources);

                output = "1";
            }
            catch (Exception ex)
            {
                throw ex;
                //ex.LogError("Deploy RDL to Report Server", userName + "|" + password + "|" + hostName + "|" + serverURL + "|" + reportTempFolder + "|" + reportTargetFolder + "|" + dataSource + "|" + reportName + "|" + reportDescription + "|" + debugMode + "|" + ex.Message);
                //SendMessage("ERROR :: Report Creation Failed:" + ex.Message, _debugMode);
                //output = ex.Message;
            }

        }


        /// <summary>
        /// Export SSRS report to html format
        /// </summary>
        /// <param name="serverUrl">SSRS url</param>
        /// <param name="userName">SSRS username</param>
        /// <param name="password">SSRS password</param>
        /// <param name="domain">SSRS domain, if domain doesnt exist left blank</param>
        /// <param name="reportName">ssrs report name to export</param>
        /// <param name="reportParameters">Additinal report parameters that are part of report rdl</param>
        /// <param name="deviceInfo">Device info for report rendering</param>
        /// <param name="sortXml">Sort xml</param>
        /// <param name="toggleItem">Toggle item</param>
        /// <param name="documentPath">Document path</param>
        /// <param name="executionId">report Execution id</param>
        /// <param name="export_type">Export type default html</param>
        public void ExportRdlToHtml(string serverUrl, string userName, string password, string domain, string reportName, string reportParameters, string deviceInfo, string sortXml, string toggleItem, string documentPath, string executionId = "", string export_type = "HTML4.0")
        {
            SqlDataRecord rec;
            // define table structure
            rec = new SqlDataRecord(new SqlMetaData[] { new SqlMetaData("Html", SqlDbType.NVarChar, SqlMetaData.Max), new SqlMetaData("TotalPages", SqlDbType.NVarChar, SqlMetaData.Max), new SqlMetaData("Status", SqlDbType.NVarChar, SqlMetaData.Max), new SqlMetaData("ExecutionID", SqlDbType.NVarChar, SqlMetaData.Max), new SqlMetaData("Message", SqlDbType.NVarChar, SqlMetaData.Max) });

            try
            {
                ReportExecutionService rs = new ReportExecutionService();
                rs.Credentials = new System.Net.NetworkCredential(userName, password, domain);
                //rs.Credentials = System.Net.CredentialCache.DefaultCredentials;
                rs.Url = serverUrl.TrimEnd('/') + "/reportexecution2005.asmx";
                rs.Timeout = 7200000;
                // Render arguments
                string reportPath = "/" + reportName.TrimStart('/').TrimEnd('/');

                string historyID = null;
                ParameterValue[] parameters = BuildParameterValues(reportParameters);
                string encoding;
                string mimeType;
                string extension;
                FARRMS.WebServices.ReportExecution2005.Warning[] warnings = null;
                string[] streamIDs = null;
                //string devInfo = @"<DeviceInfo><Toolbar>False</Toolbar></DeviceInfo>";
                string devInfo = deviceInfo;
                ExecutionInfo2 execInfo = new ExecutionInfo2();
                ExecutionHeader execHeader = new ExecutionHeader();
                if (executionId.Trim() != "")
                {
                    execHeader.ExecutionID = executionId;
                    rs.ExecutionHeaderValue = execHeader;
                }
                else
                {
                    rs.ExecutionHeaderValue = execHeader;
                    execInfo = rs.LoadReport2(reportPath, historyID);
                    rs.SetExecutionParameters(parameters, "en-us");
                }

                if (sortXml != "" && sortXml != "NULL")
                {
                    SortReport(rs, sortXml);
                }

                if (toggleItem != "" && toggleItem != "NULL")
                {
                    string[] toggleItem_arr = toggleItem.Split(',');
                    foreach (string item in toggleItem_arr)
                    {
                        rs.ToggleItem(item);
                    }

                }

                //byte[] exportBytes = rs.Render("HTML4.0", devInfo, out extension, out encoding, out mimeType, out warnings, out streamIDs);
                byte[] exportBytes = rs.Render2(export_type, devInfo, PageCountMode.Actual, out extension, out mimeType, out encoding, out warnings, out streamIDs);


                /*if ((sortXml != "" && sortXml != "NULL") || (toggleItem != "" && toggleItem != "NULL")) 
                {
                    exportBytes = rs.Render2("HTML4.0", devInfo, PageCountMode.Actual, out extension, out encoding, out mimeType, out warnings, out streamIDs);
                }*/

                execInfo = rs.GetExecutionInfo2();
                var exportHtml = "";
                var executionID = "";
                if (export_type != "HTML4.0")
                {

                    DateTime localDate = DateTime.Now;
                    executionID = localDate.ToString("yyyyMMddHHmmss");
                    string path = documentPath + executionID + "." + extension;

                    using (FileStream stream = File.Create(path, exportBytes.Length))
                    {
                        stream.Write(exportBytes, 0, exportBytes.Length);
                    }
                    exportHtml = path;
                }
                else
                {
                    exportHtml = System.Text.Encoding.UTF8.GetString(exportBytes);

                    foreach (var stre in streamIDs)
                    {
                        var img = rs.RenderStream(export_type, stre, deviceInfo, out encoding, out mimeType);
                        using (FileStream fs = new FileStream(documentPath + stre + ".png", FileMode.Create))
                        {
                            exportHtml = exportHtml.Replace(stre, stre + ".png");
                            fs.Write(img, 0, img.Length);
                            fs.Close();
                        }
                    }

                    exportHtml = exportHtml.Replace("onclick=\"Sort(", "onclick=\"custom_sort(");
                    exportHtml = Regex.Replace(exportHtml, "href=\"(.*?)ShowHideToggle(.*?)\">", "class=\"show_hide_toggle\">");
                    executionID = execInfo.ExecutionID;
                }

                SqlContext.Pipe.SendResultsStart(rec);
                rec.SetSqlString(0, exportHtml.ToString());
                rec.SetSqlString(1, execInfo.NumPages.ToString());
                rec.SetSqlString(2, "Success");
                rec.SetSqlString(3, executionID);
                rec.SetSqlString(4, "Success");
                SqlContext.Pipe.SendResultsRow(rec);
                SqlContext.Pipe.SendResultsEnd();    // finish sending

            }
            catch (SoapException e)
            {

                //SqlContext.Pipe.SendResultsStart(rec);
                //rec.SetSqlString(0, e.Detail.FirstChild.InnerText);
                //rec.SetSqlString(1, "");
                //rec.SetSqlString(2, "Error");
                //rec.SetSqlString(4, e.Message);
                //SqlContext.Pipe.SendResultsRow(rec);
                //SqlContext.Pipe.SendResultsEnd();    // finish sending

                //e.LogError("Export RDL To HTML - ExportRdlToHtml", serverUrl + "|" + userName + "|" + password + "|" + domain + "|" + reportName + "|" + reportParameters);
                throw e;


            }
        }
        /// <summary>
        /// Download RDL files from report server based on report name , ssrs configuration defined in connection string
        /// </summary>
        /// <param name="reportName">Report Name</param>
        public void DownloadRdl(string reportName)
        {
            SqlDataRecord rec;
            // define table structure
            rec =
                new SqlDataRecord(new SqlMetaData[]
                {
                    new SqlMetaData("status", SqlDbType.NVarChar, SqlMetaData.Max),
                    new SqlMetaData("rdl_filename", SqlDbType.Text, SqlMetaData.Max)

                });
            string serverUrl = "";
            string userName = "";
            string password = "";
            string domain = "";
            string reportFolder = "";
            string documentPath = "";

            try
            {
                //using (SqlConnection cn = new SqlConnection(@"Data Source=SG-D-SQL02.FARRMS.US,2033;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=True"))
                {
                    cn.Open();
                    using (SqlCommand cmd = new SqlCommand("select report_server_url, report_server_user_name, dbo.FNADecrypt(report_server_password) report_server_password,report_server_domain, report_server_target_folder, document_path from connection_string", cn))
                    {
                        using (SqlDataReader rd = cmd.ExecuteReader())
                        {
                            while (rd.Read())
                            {
                                serverUrl = rd["report_server_url"].ToString();
                                userName = rd["report_server_user_name"].ToString();
                                password = rd["report_server_password"].ToString();
                                domain = rd["report_server_domain"].ToString();
                                reportFolder = rd["report_server_target_folder"].ToString();
                                documentPath = rd["document_path"].ToString();
                            }

                        }
                    }

                    using (ReportingService2005 rs = new ReportingService2005())
                    {
                        rs.Credentials = new System.Net.NetworkCredential(userName, password, domain);
                        //rs.Credentials = System.Net.CredentialCache.DefaultCredentials;
                        rs.Url = serverUrl.TrimEnd('/') + "/reportservice2005.asmx";

                        XmlDocument doc = new XmlDocument();
                        string tempReportName = reportName;
                        reportName = "/" + reportFolder + "/" + reportName;
                        byte[] reportDefinition = rs.GetReportDefinition(reportName);
                        using (MemoryStream stream = new MemoryStream(reportDefinition))
                        {
                            string docPath = documentPath.TrimEnd('\\') + "\\temp_note\\" + tempReportName + ".rdl";
                            doc.Load(stream);
                            doc.Save(docPath);

                            SqlContext.Pipe.SendResultsStart(rec);
                            rec.SetSqlString(0, "Success");
                            rec.SetSqlString(1, docPath);
                            SqlContext.Pipe.SendResultsRow(rec);
                            SqlContext.Pipe.SendResultsEnd();    // finish sending
                        }
                    }
                }


            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        /// <summary>
        /// Sort SSRS html report
        /// </summary>
        /// <param name="rs">ReportExecutionService used by export rdl</param>
        /// <param name="sortXml">SSRS Sort Xml criteria</param>
        private void SortReport(ReportExecutionService rs, string sortXml)
        {
            string reportItemm;
            ExecutionInfo2 execInfo = new ExecutionInfo2();

            try
            {
                XDocument xDoc;
                xDoc = XDocument.Parse(sortXml);
                string sortItem = "";
                SortDirectionEnum sortDirection = SortDirectionEnum.None;
                bool clearSort = false;

                foreach (XElement el in xDoc.Descendants())
                {
                    if (el.Name.ToString().ToLower() == "item")
                        sortItem = el.Value;
                    if (el.Name.ToString().ToLower() == "direction")
                    {
                        if (el.Value.ToLower() == "ascending") sortDirection = SortDirectionEnum.Ascending;
                        else if (el.Value.ToLower() == "descending") sortDirection = SortDirectionEnum.Descending;
                        else sortDirection = SortDirectionEnum.None;
                    }

                    if (el.Name.ToString().ToLower() == "clear")
                    {
                        if (el.Value.ToLower() == "true")
                            clearSort = true;
                    }
                }
                //rs.Sort(sortItem, sortDirection, clearSort, out reportItemm, out numPages);
                rs.Sort2(sortItem, sortDirection, clearSort, PageCountMode.Actual, out reportItemm, out execInfo);
            }
            catch (Exception e)
            {

            }

        }
        //// <summary>
        ///  This function Generates PDF document Reporting Services RDL.
        /// </summary>
        /// <param name="serverUrl"> URL of Report Server.</param>
        /// <param name="userName"> Report Server username.</param>
        /// <param name="password"> Report Server Password.</param>
        /// <param name="domain"> Report Server Domain.</param>
        /// <param name="reportName"> Report Name .</param>
        /// <param name="reportParameters"> Report Parameter string</param>
        ///  <param name="OutputFileName"> Output File Name.</param>
        public void GenerateDocFromRDL(string serverUrl, string userName, string password, string domain, string reportName, string reportParameters, string OutputFileFormat, string OutputFileName, string process_id, out string resultOutput)
        {
            try
            {
                ReportExecutionService rs = new ReportExecutionService();
                rs.Credentials = new System.Net.NetworkCredential(userName, password, domain);
                //rs.Credentials = System.Net.CredentialCache.DefaultCredentials;
                rs.Url = serverUrl.TrimEnd('/') + "/reportexecution2005.asmx";
                rs.Timeout = 7200000;
                // Render arguments
                byte[] result = null;
                string reportPath = "/" + reportName.TrimStart('/').TrimEnd('/');
                string format = OutputFileFormat;
                string historyID = null;
                string devInfo = @"<DeviceInfo><Toolbar>False</Toolbar></DeviceInfo>";

                ParameterValue[] parameters = BuildParameterValues(reportParameters);

                DataSourceCredentials[] credentials = null;
                string showHideToggle = null;
                string encoding;
                string mimeType;
                string extension;
                FARRMS.WebServices.ReportExecution2005.Warning[] warnings = null;
                ParameterValue[] reportHistoryParameters = null;
                string[] streamIDs = null;

                ExecutionInfo execInfo = new ExecutionInfo();
                ExecutionHeader execHeader = new ExecutionHeader();

                rs.ExecutionHeaderValue = execHeader;


                execInfo = rs.LoadReport(reportPath, historyID);

                rs.SetExecutionParameters(parameters, "en-us");
                String SessionId = rs.ExecutionHeaderValue.ExecutionID;


                result = rs.Render(format, devInfo, out extension, out encoding, out mimeType, out warnings, out streamIDs);

                execInfo = rs.GetExecutionInfo();
                string resultMsg = "";
                DeleteFile(OutputFileName, out resultMsg);
                string path = OutputFileName;

                using (FileStream stream = File.Create(path, result.Length))
                {
                    stream.Write(result, 0, result.Length);
                }

                resultOutput = "true";
            }
            catch (SoapException e)
            {
                //resultOutput = e.ToString();
                //e.LogError("Generate Document From RDL - SoapException", serverUrl + "|" + userName + "|" + password + "|" + domain + "|" + reportName + "|" + reportParameters + "|" + OutputFileFormat + "|" + OutputFileName + "|" + process_id + e.Message);
                throw e;
            }

        }


        /// <summary>
        /// Get report name report rfx parameter paramset id
        /// </summary>
        /// <param name="reportRfxParameter">Report rfx parameter</param>
        /// <returns>return report name string or null</returns>
        private static string GetReportName(string reportRfxParameter)
        {
            string[] arr = reportRfxParameter.Split(',');
            var paramset = arr.Where(x => x.ToLower().Contains("paramset_id")).FirstOrDefault();
            string paramset_id = "0";

            if (paramset != null)
            {
                paramset_id = paramset.Split(':')[1];
            }

            using (SqlConnection cn = new SqlConnection("Context Connection =true"))
            {
                cn.Open();
                string sql = "select [name] from report_paramset where report_paramset_id =" + paramset_id;
                using (SqlCommand cmd = new SqlCommand(sql, cn))
                {
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.HasRows)
                    {
                        dr.Read();
                        return dr[0].ToString();
                    }
                }
            }
            return null;
        }

        private ParameterValue[] BuildParameterValues(string reportParameter)
        {

            string[] parameters = reportParameter.Split(',');
            int paramCount = reportParameter.Split(':').Count() - 1;

            string[] newparameters = new string[paramCount];
            int index = 0;
            foreach (string p in parameters)
            {
                if (p.Contains(':'))
                {
                    newparameters[index] = p;
                    index++;
                }
                else
                    newparameters[index - 1] += "," + p;
            }

            ParameterValue[] parameterValues = new ParameterValue[newparameters.Count()];
            for (int i = 0; i < newparameters.Count(); i++)
            {
                string[] paramValue = newparameters[i].Split(':');
                parameterValues[i] = new ParameterValue();
                parameterValues[i].Name = paramValue[0];
                parameterValues[i].Value = paramValue[1];
            }

            return parameterValues;
        }

        /// <summary>
        /// Check if ssrs report rdl exist in report server
        /// </summary>
        /// <param name="reportName">SSRS report name</param>
        /// <returns>True / False</returns>
        public bool RdlExists(string reportName)
        {
            string serverUrl = "";
            string userName = "";
            string password = "";
            string domain = "";
            string reportFolder = "";

            try
            {
                //using (SqlConnection cn = new SqlConnection(@"Data Source=SG-D-SQL02.FARRMS.US,2033;Initial Catalog=TRMTracker_DEV;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=True"))
                {
                    cn.Open();
                    using (
                        SqlCommand cmd =
                            new SqlCommand(
                                "select report_server_url, report_server_user_name, dbo.FNADecrypt(report_server_password) report_server_password,report_server_domain, report_server_target_folder, document_path from connection_string",
                                cn))
                    {
                        using (SqlDataReader rd = cmd.ExecuteReader())
                        {
                            while (rd.Read())
                            {
                                serverUrl = rd["report_server_url"].ToString();
                                userName = rd["report_server_user_name"].ToString();
                                password = rd["report_server_password"].ToString();
                                domain = rd["report_server_domain"].ToString();
                                reportFolder = rd["report_server_target_folder"].ToString();
                            }

                        }
                    }

                    using (
                        ReportingService2005 rs = new ReportingService2005())
                    {
                        rs.Credentials = new System.Net.NetworkCredential(userName, password, domain);
                        //rs.Credentials = System.Net.CredentialCache.DefaultCredentials;
                        rs.Url = serverUrl.TrimEnd('/') + "/reportservice2005.asmx";

                        XmlDocument doc = new XmlDocument();
                        string tempReportName = reportName;
                        reportName = "/" + reportFolder + "/" + reportName;
                        byte[] reportDefinition = rs.GetReportDefinition(reportName);

                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        public string FormatDate(string value, string dateformat)
        {
            try
            {
                DateTime dt = Convert.ToDateTime(value);
                return dt.ToString(dateformat);
            }
            catch (Exception)
            {
                return value;
            }
        }

        private string StripHtml(string htmlContent)
        {
            char[] array = new char[htmlContent.Length];
            int arrayIndex = 0;
            bool inside = false;

            for (int i = 0; i < htmlContent.Length; i++)
            {
                char let = htmlContent[i];
                if (let == '<')
                {
                    inside = true;
                    continue;
                }
                if (let == '>')
                {
                    inside = false;
                    continue;
                }
                if (!inside)
                {
                    array[arrayIndex] = let;
                    arrayIndex++;
                }
            }
            return new string(array, 0, arrayIndex);
        }


        private string ColumnNamesFromReader(SqlDataReader rd, string delimiter)
        {

            string strOut = "";
            if (delimiter.ToLower() == "tab")
            {
                delimiter = "\t";
            }
            for (int i = 0; i < rd.FieldCount; i++)
            {
                strOut += rd.GetName(i);
                if (i < rd.FieldCount - 1)
                {
                    strOut += delimiter;
                }

            }
            return strOut;
        }

        private void DeleteFile(string fileName, out string result)
        {
            string file = fileName.ToString();
            if (!System.IO.File.Exists(file))
                result = "-1";
            try
            {
                System.IO.File.Delete(file);
                result = "1";
            }
            catch (Exception ex)
            {
                result = ex.Message;
            }
        }
    }


}
