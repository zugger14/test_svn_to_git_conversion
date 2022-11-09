using System;
using System.Net;
using System.IO;
using System.Xml;
using System.Security.Cryptography.X509Certificates;
using System.Data.SqlClient;
using System.Data;
using FARRMSUtilities;
using System.Text;

namespace FARRMSImportCLR
{
    /// <summary>
    /// Service Handler for retrieving Market Results from EPEX
    /// </summary>
    internal class EpexRetrieveMarketResultsForImporter : CLRWebImporterBase
    {
        public String type;
        string area;
        string resultStatus;      
        XmlDocument xmlDoc;
        XmlNamespaceManager xmlnsManager;
       
        /// <summary>
        /// Initilize EPEX webservice based on the type.
        /// </summary>
        /// <param name="type">DayAhead</param>
        public EpexRetrieveMarketResultsForImporter(string type)
        {
            this.type = type;
        }

        /// <summary>
        /// To create a web channel to hit the request and get its reponse
        /// </summary>
        /// <param name="request"></param>
        /// <param name="clrImportInfo"></param>
        /// <returns></returns>
        public string GetWebResponse(string request, CLRImportInfo clrImportInfo, string action)
        {
            string responseFromServer;
            ServicePointManager.Expect100Continue = true;
#pragma warning disable S4423 // Added Strong protocols including ssl3
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
            HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(clrImportInfo.WebServiceInfo.WebServiceURL);
            webRequest.Method = "POST";
            webRequest.ContentType = "text/xml;charset=UTF-8";
            webRequest.Headers.Add("SOAPAction", action);
            webRequest.ProtocolVersion = HttpVersion.Version10;
            webRequest.ClientCertificates.Add(new X509Certificate2(clrImportInfo.WebServiceInfo.CertificatePath, clrImportInfo.WebServiceInfo.ClientSecret));

            using (var writeStream = new StreamWriter(webRequest.GetRequestStream()))
            {
                writeStream.Write(request);
                writeStream.Flush();
                writeStream.Close();
            }

            using (WebResponse webResponse = webRequest.GetResponse())
            {
                Stream stream = webResponse.GetResponseStream();
                StreamReader reader = new StreamReader(stream);
                responseFromServer = reader.ReadToEnd();
            }
            return responseFromServer;
        }
        /// <summary>
        /// Updates password of EPEX API user
        /// </summary>
        /// <param name="clrImportInfo"></param>
        /// <returns>string success\fail</returns>
        public string UpdatePassword(CLRImportInfo clrImportInfo)
        {
            string status;
            string ws_name;
            string responseFromServer;
            XmlNode node;
            string state;           
            string passwordRequestBody;
            try 
            {
                string updatedPassword = clrImportInfo.WebServiceInfo.UserName.Substring(0, 7) + DateTime.Now.ToString("ddMMMMyyyy") + "!";              
               
                passwordRequestBody = @"                        
                <soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:urn='urn:openaccess'>
                    <soapenv:Header>
                        <urn:SessionToken>
                            <urn:userLoginName>" + clrImportInfo.WebServiceInfo.UserName + @"</urn:userLoginName>
                            <urn:sessionKey>" + clrImportInfo.WebServiceInfo.Token + @"</urn:sessionKey>
                        </urn:SessionToken>
                        <urn:AsynchronousResponseHeader>
                            <urn:asynchronousResponse>1</urn:asynchronousResponse>
                        </urn:AsynchronousResponseHeader>
                    </soapenv:Header>
                    <soapenv:Body>
                        <urn:UpdatePassword>
                            <newPassword>" + updatedPassword + @"</newPassword>
                            <oldPassword>" + clrImportInfo.WebServiceInfo.Password + @"</oldPassword>
                        </urn:UpdatePassword>
                    </soapenv:Body>
                </soapenv:Envelope>";
               
                responseFromServer = GetWebResponse(passwordRequestBody, clrImportInfo, "UpdatePassword");
                xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(responseFromServer);

                xmlnsManager = new XmlNamespaceManager(xmlDoc.NameTable);
                #pragma warning disable S1075 // URL path won't change
                xmlnsManager.AddNamespace("SOAP-ENV", "http://schemas.xmlsoap.org/soap/envelope/");
                xmlnsManager.AddNamespace("ns", "urn:openaccess");

                node = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:UpdatePasswordResponse/UpdatePasswordAcknowledgement", xmlnsManager);

                state = node["ns:state"].InnerText;

                if (state == "ACK")
                {
                    string passwordInformation = node["ns:passwordInformation"].InnerText;
                    using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                    {
                        cn.Open();
                        ws_name = "EPEXRetrieveMarketResultsFor" + type;

                        using (SqlCommand cmd = new SqlCommand("spa_import_web_service", cn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("flag", "a");
                            cmd.Parameters.AddWithValue("password", updatedPassword);
                            cmd.Parameters.AddWithValue("ws_name", ws_name);
                            cmd.Parameters.AddWithValue("password_updated_date", "GETDATE()");
                            
                            cn.Open();
                            cmd.ExecuteNonQuery();
                            cn.Close();
                        }      
                        
                        clrImportInfo.WebServiceInfo.Password = updatedPassword;
                        cn.Close();
                    }

                    SendEmail(clrImportInfo, "Success", passwordInformation, updatedPassword);

                    status = "success";
                }
                else
                {
                    XmlNode errors = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:SetNewPasswordResponse/SetNewPasswordAcknowledgement/ns:errors", xmlnsManager);
                    XmlNode error = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:SetNewPasswordResponse/SetNewPasswordAcknowledgement/ns:error", xmlnsManager);

                    XmlNodeList list = null;
                    
                    if (errors != null)
                    {
                        list = errors.ParentNode.SelectNodes(errors.Name, xmlnsManager);
                    }
                    else if (error != null)
                    {
                        list = error.ParentNode.SelectNodes(error.Name, xmlnsManager);
                    }

                    string error_message = string.Empty;
                    StringBuilder bld = new StringBuilder();

                    if (list != null && list.Count > 0)
                    {
                        for (int i = 0; i < list.Count; i++)
                        {
                            bld.Append("<li>" + list[i].LastChild.InnerText + "</li>");                            
                        }
                        error_message = bld.ToString();
                        SendEmail(clrImportInfo, "Fail", error_message, "");
                    }

                    status = "fail";
                }
            }
            catch (Exception ex)
            {
                status = "fail";
                SendEmail(clrImportInfo, "Fail", "Failed to update password. Please contact techincal support.", "");

                ex.LogError("Epex Update Password", ex.Message);                
            }

            return status;
        }

        /// <summary>
        /// Send email to a role about password change
        /// </summary>
        /// <param name="clrImportInfo"></param>
        /// <param name="status"></param>
        /// <param name="message"></param>
        /// <param name="password"></param>
        public void SendEmail(CLRImportInfo clrImportInfo, string status, string message, string password) 
        {
            try
            { 
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    using (SqlCommand cmd = new SqlCommand("spa_import_epex_web_service", cn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("flag", "send_email");
                        cmd.Parameters.AddWithValue("status", status);
                        cmd.Parameters.AddWithValue("message", message);
                        cmd.Parameters.AddWithValue("user_name", clrImportInfo.WebServiceInfo.UserName);
                        cmd.Parameters.AddWithValue("password ", password);
                        cn.Open();
                        cmd.ExecuteNonQuery();
                        cn.Close();
                    }
                    
                }
            }            
            catch (Exception ex)
            {
                ex.LogError("Epex Update Password Email", ex.Message);               
            }
        }

        /// <summary>
        /// Generate Token to be used while calling different method in API
        /// </summary>
        /// <param name="clrImportInfo"></param>
        /// <returns>string success/fail</returns>
        public string GenerateToken(CLRImportInfo clrImportInfo)
        {
            if (clrImportInfo is null)
            {
                throw new ArgumentNullException(nameof(clrImportInfo));
            }

            string ws_name;
            XmlNode node;
            string state;

            string status;
            try
            {
                string tokenRequestBody = @"<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:urn='urn:openaccess'>
                    <soapenv:Header/>
                    <soapenv:Body>
                    <urn:EstablishConnection>
                        <userLoginName>" + clrImportInfo.WebServiceInfo.UserName + @"</userLoginName>
                        <password>" + clrImportInfo.WebServiceInfo.Password + @"</password>
                    </urn:EstablishConnection>
                    </soapenv:Body>
                    </soapenv:Envelope>";
                string responseFromServer = GetWebResponse(tokenRequestBody, clrImportInfo, "EstablishConnection");
                xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(responseFromServer);

                xmlnsManager = new System.Xml.XmlNamespaceManager(xmlDoc.NameTable);

#pragma warning disable S1075 // This URL does not change in XML
                xmlnsManager.AddNamespace("SOAP-ENV", "http://schemas.xmlsoap.org/soap/envelope/");
#pragma warning restore S1075 // This URL does not change in XML
                xmlnsManager.AddNamespace("ns", "urn:openaccess");

                node = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:EstablishConnectionResponse/EstablishSessionResponse", xmlnsManager);
                state = node["ns:state"].InnerText;

                if (state == "ACK")
                {
                    node = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:EstablishConnectionResponse/EstablishSessionResponse/ns:sessionToken", xmlnsManager);
                    string token = node["ns:sessionKey"].InnerText;

                    using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                    {
                        cn.Open();
                        ws_name = "EPEXRetrieveMarketResultsFor" + type;
                        using (SqlCommand cmd = new SqlCommand("spa_import_web_service", cn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("flag", "a");
                            cmd.Parameters.AddWithValue("auth_token", token);
                            cmd.Parameters.AddWithValue("ws_name", ws_name);
                            cn.Open();
                            cmd.ExecuteNonQuery();
                            cn.Close();
                        }
                    }                    
                    status = "success";
                }
                else
                {
                    status = "fail";
                }
            }
            catch (Exception ex)
            {
                status = "fail";
                ex.LogError("Epex Generate Token", ex.Message);
            }

            return status;
        }

        /// <summary>
        /// Generates response from EPEX API
        /// </summary>
        /// <param name="clrImportInfo"></param>
        /// <returns>EpexImportStatus class</returns>
        public EpexImportStatus GenerateResponse(CLRImportInfo clrImportInfo, String requestType)
        {
            string responseFromServer;
            XmlNode node;
            EpexImportStatus status;
            try
            {
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    try
                    {
                        SqlDataReader rd;
                        if (requestType == "DayAhead")
                        {
                            rd = cn.ExecuteStoredProcedureWithReturn("spa_import_epex_web_service", "flag:day_ahead,rules_id:" + clrImportInfo.RuleID.ToString() + ",auction_area_id:" + clrImportInfo.Params[0].paramValue.ToString() + ",auction_date:" + clrImportInfo.Params[1].paramValue.ToString().Replace(":", ";") + ",auction_name_id:" + clrImportInfo.Params[2].paramValue.ToString());
                            if (rd.HasRows)
                            {
                                clrImportInfo.WebServiceInfo.RequestBody = rd[0].ToString();
                                rd.Close();
                            }
                        }

                    }
                    catch (Exception ex)
                    {
                        status = new EpexImportStatus { Status = "Fail", ResponseMessage = ex.Message, Exception = ex };
                        throw status.Exception;
                    }
                    cn.Close();
                }

                responseFromServer = GetWebResponse(clrImportInfo.WebServiceInfo.RequestBody, clrImportInfo, "RetrieveMarketResultsFor");

                xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(responseFromServer);

                xmlnsManager = new System.Xml.XmlNamespaceManager(xmlDoc.NameTable);
                string outputResponse;

                #pragma warning disable S1075 // URL won't change in XML
                xmlnsManager.AddNamespace("SOAP-ENV", "http://schemas.xmlsoap.org/soap/envelope/");
                xmlnsManager.AddNamespace("ns", "urn:openaccess");
                XmlNode errors = xmlDoc.SelectSingleNode(xpath: "/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:RetrieveMarketResultsForResponse/RetrieveMarketResultAcknowledgement/ns:errors/ns:errorText", xmlnsManager);
                XmlNode error = xmlDoc.SelectSingleNode(xpath: "/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:RetrieveMarketResultsForResponse/RetrieveMarketResultAcknowledgement/ns:error/ns:errorText", xmlnsManager);

                node = errors ?? error;
                if (node != null)
                {
                    outputResponse = node.InnerText;
                    area = "";
                    resultStatus = "";
                }
                else
                {
                    node = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:RetrieveMarketResultsForResponse/RetrieveMarketResultAcknowledgement/ns:marketResults", xmlnsManager);
                    resultStatus = node["ns:ResultsStatus"].InnerText;
                    area = node["ns:area"].InnerText;
                    outputResponse = node["ns:marketResultExport"].InnerText;
                }

                status = new EpexImportStatus { Status = "Success", ResponseMessage = outputResponse, Exception = null, Area = area, ResultStatus = resultStatus };

            }
            catch (Exception ex)
            {
                status = new EpexImportStatus { Status = "Fail", ResponseMessage = ex.Message, Exception = ex };
                throw status.Exception;
            }

            return status;
        }

        /// <summary>
        /// Get data from EPEX Web service and insert into process table
        /// </summary>
        /// <param name="clrImportInfo"></param>
        /// <returns>ImportStatus class</returns>
        public override ImportStatus ImportData(CLRImportInfo clrImportInfo)
        {
            ImportStatus status = null;
            string dataSourceAlias = "";
            string processTableName = "";
            string updStatus;
            try
            {                               
                //Validty of password is 90 days. So update password if less than 7 days remain
                if ((DateTime.Now.Date - clrImportInfo.WebServiceInfo.PasswordUpdatedDate.Date).Days > 83)
                {
                    string token = GenerateToken(clrImportInfo);
                    #pragma warning disable S112 // To show exact message in clr_error_log
                    if (token == "fail") throw new Exception("Failed to Generate Token while updating password.");                 
                    updStatus = UpdatePassword(clrImportInfo);
                    #pragma warning disable S112 // To show exact message in clr_error_log
                    if (updStatus == "fail")
                    {
                        throw new Exception("Failed to Update Password.");
                    }

                }

                //Generate response, if token has expired generate token and regenerate response               
                EpexImportStatus WebResponse = GenerateResponse(clrImportInfo, this.type);
                if (WebResponse.ResponseMessage == "Login Denied: Wrong session key")
                {
                    string token = GenerateToken(clrImportInfo);
                    #pragma warning disable S112 // To show exact message in clr_error_log
                    if (token == "fail") throw new Exception("Failed to Generate Token.");
                    WebResponse = GenerateResponse(clrImportInfo, this.type);
                }

                string response = WebResponse.ResponseMessage;
                string[] datarows;
                DataTable dt = new DataTable("dtTable");                
                dt.Columns.Add(new DataColumn("column1"));
                DataColumn dc = dt.Columns.Add("ixp_source_unique_id", typeof(int));
                dc.AutoIncrement = true;
                dc.AutoIncrementSeed = 1;
                dc.AutoIncrementStep = 1;

                datarows = response.Split(new string[] { "\r" }, StringSplitOptions.RemoveEmptyEntries);
                foreach (var row in datarows)
                {
                    dt.Rows.Add(row,null);
                }

                using (SqlConnection cn = new SqlConnection("Context Connection=true")) 
                {
                    cn.Open();
                    SqlDataReader rd = cn.ExecuteStoredProcedureWithReturn("spa_ixp_import_data_source", "flag:x,rules_id:" + clrImportInfo.RuleID.ToString());
                    if (rd.HasRows)
                    {
                        dataSourceAlias = rd[0].ToString();
                        rd.Close();
                    }

                    processTableName = $"adiha_process.dbo.temp_import_data_table_{dataSourceAlias}_{clrImportInfo.ProcessID}";
                    string createTableSql = $"IF OBJECT_ID('{processTableName}') IS NOT NULL DROP TABLE {processTableName}";

                    new SqlCommand(createTableSql, cn).ExecuteNonQuery();

                    createTableSql = "CREATE TABLE " + processTableName + "(" + "[" + dt.Columns[0].ColumnName + "] NVARCHAR(MAX), " + "[" + dt.Columns[1].ColumnName + "] INT)";

                    new SqlCommand(createTableSql, cn).ExecuteNonQuery();
                    
                    if (resultStatus == "Final")
                    {
                        using (SqlDataAdapter adapter = new SqlDataAdapter("SELECT * FROM " + processTableName, cn))
                        {
                            using (SqlCommandBuilder builder = new SqlCommandBuilder(adapter))
                            {
                                builder.GetInsertCommand();
                                adapter.Update(dt);
                            }
                        }

                        status = new ImportStatus { Status = "Success", ResponseMessage = "Data inserted in Process table successfully.", Exception = null };
                    
                    }
                    else
                    {
                        status = new ImportStatus { Status = "Success", ResponseMessage = "Data not inserted in Process table.", Exception = null };
                    }

                    cn.Close();
                }

                status.ProcessTableName = processTableName;
                return status;
               
            }
            catch (Exception ex)
            {
                status = new ImportStatus { Status = "Fail", ResponseMessage = ex.Message, Exception = ex };
                throw status.Exception;
            }
        }
        /// <summary>
        /// Class to set Import status within EpexRetrieveMarketResultsForImporter
        /// </summary>
        public class EpexImportStatus
        {
            public string Status { get; set; }
            public string ResponseMessage { get; set; }
            public Exception Exception { get; set; }
            public string Area { get; set; }
            public string ResultStatus { get; set; }
        }
    }
}
