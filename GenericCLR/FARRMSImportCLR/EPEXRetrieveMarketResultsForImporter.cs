using System;
using System.Net;
using System.IO;
using System.Xml;
using System.Security.Cryptography.X509Certificates;
using System.Data.SqlClient;
using System.Data;
using FARRMSUtilities;

namespace FARRMSImportCLR
{
    class EPEXRetrieveMarketResultsForImporter : CLRWebImporterBase
    {
        public String type;
        string area;
        string resultStatus;

        public EPEXRetrieveMarketResultsForImporter(String type)
        {
            this.type = type;
        }
        /// <summary>
        /// Updates password of EPEX API user
        /// </summary>
        /// <param name="clrImportInfo"></param>
        /// <returns>bool true/false</returns>
        public bool UpdatePassword(CLRImportInfo clrImportInfo)
        {
            bool status;
            try 
            {
                string updatedPassword = "SWHNBCI" + DateTime.Now.ToString("ddMMMMyyyy") + "!";

                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                HttpWebRequest webRequest = (HttpWebRequest)HttpWebRequest.Create(clrImportInfo.WebServiceInfo.WebServiceURL);
                webRequest.Method = "POST";
                webRequest.ContentType = "text/xml";
                webRequest.ProtocolVersion = HttpVersion.Version10;
                webRequest.ClientCertificates.Add(new X509Certificate2(clrImportInfo.WebServiceInfo.CertificatePath, clrImportInfo.WebServiceInfo.ClientSecret));
                //webRequest.ClientCertificates.Add(new X509Certificate2(@"C:\Users\abhishek\OneDrive - PG\APIS\Enercity\EPEX\UAT\ets_cert.pfx", clrImportInfo.WebServiceInfo.ClientSecret));
                
                string passwordRequestBody = @"
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
                            <urn:SetNewPassword>
                                <aPassword>" + updatedPassword + @"</aPassword>
                            </urn:SetNewPassword>
                        </soapenv:Body>
                    </soapenv:Envelope>";

                using (var writeStream = new StreamWriter(webRequest.GetRequestStream()))
                {
                    writeStream.Write(passwordRequestBody);
                    writeStream.Flush();
                    writeStream.Close();
                }

                WebResponse response = webRequest.GetResponse();
                Stream stream = response.GetResponseStream();

                StreamReader reader = new StreamReader(stream);
                string responseFromServer = reader.ReadToEnd();
                      
                //  string responseFromServer = "<?xml version='1.0' encoding='UTF-8'?>\n<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:ns='urn:openaccess'><SOAP-ENV:Header><ns:SessionToken><ns:userLoginName>TSWHNBCDAPI50</ns:userLoginName><ns:sessionKey>30206410444687950893617550256649412468693834618229219086396964314422013513110785</ns:sessionKey></ns:SessionToken></SOAP-ENV:Header><SOAP-ENV:Body><ns:EstablishConnectionResponse><EstablishSessionResponse><ns:state>ACK</ns:state><ns:sessionToken><ns:userLoginName>TSWHNBCDAPI50</ns:userLoginName><ns:sessionKey>30206410444687950893617550256649412468693834618229219086396964314422013513110785</ns:sessionKey></ns:sessionToken></EstablishSessionResponse></ns:EstablishConnectionResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>";
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(responseFromServer);

                XmlNamespaceManager xmlnsManager = new System.Xml.XmlNamespaceManager(xmlDoc.NameTable);

                xmlnsManager.AddNamespace("SOAP-ENV", "http://schemas.xmlsoap.org/soap/envelope/");
                xmlnsManager.AddNamespace("ns", "urn:openaccess");

                XmlNode node = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:SetNewPasswordResponse/SetNewPasswordAcknowledgement", xmlnsManager);
                string state = node["ns:state"].InnerText;
                string ws_name;
                if (state == "ACK")
                {
                    string passwordInformation = node["ns:passwordInformation"].InnerText;
                    using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                    //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                    {
                        cn.Open();
                        ws_name = "EPEXRetrieveMarketResultsFor" + this.type;
                        SqlCommand updCmd = new SqlCommand("UPDATE import_web_service SET [password] = dbo.FNAEncrypt('" + updatedPassword + "'), password_updated_date = GETDATE() WHERE ws_name = '" + ws_name + "' ", cn);
                        updCmd.ExecuteReader();
                        clrImportInfo.WebServiceInfo.Password = updatedPassword;
                        cn.Close();
                    }

                    SendEmail(clrImportInfo, "Success", passwordInformation, updatedPassword);

                    status = true;
                }
                else
                {
                    XmlNode errors = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:SetNewPasswordResponse/SetNewPasswordAcknowledgement/ns:errors", xmlnsManager);
                    XmlNodeList list = errors.ParentNode.SelectNodes(errors.Name, xmlnsManager);
                    string error_message = "";

                    for (int i = 0; i < list.Count; i++)
                    {
                        error_message += "<li>" + list[i].LastChild.InnerText + "</li>";
                    }
                    SendEmail(clrImportInfo, "Fail", error_message, "");
                    
                    status = false;
                }     
            }
            catch (Exception ex)
            {
                status = false;
                SendEmail(clrImportInfo, "Fail", "Failed to update password. Please contact techincal support.", "");

                ex.LogError("Epex Update Password", ex.Message);                
            }

            return status;
        }

        public void SendEmail(CLRImportInfo clrImportInfo, string status, string message, string password) 
        {
            try
            {
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                {
                    cn.Open();
                    string sql = @"
                            DECLARE @role_id INT,  @template_params NVARCHAR(500) 
                            SELECT @role_id = role_id FROM application_security_role WHERE role_name = 'Enercity EPEX ETS'
                            SET @template_params = ''";

                    if (status == "Success")
                    {
                        sql += "SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<EPEX_USER_NAME>', '" + clrImportInfo.WebServiceInfo.UserName + @"')
                            SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<EPEX_PASSWORD>', '" + password + @"')";
                    }

                    string moduleType = (status == "Success") ? "17823" : "17824";
                    sql += "SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<EPEX_INFO>', '" + message + @"')
                                              
                            EXEC spa_email_notes
                            @flag = 'b',
                            @email_module_type_value_id = " + moduleType + @",
                            @send_status = 'n',
                            @active_flag = 'y',
                            @template_params = @template_params,
                            @role_ids = @role_id";

                    SqlCommand updCmd = new SqlCommand(sql, cn);
                    updCmd.ExecuteReader();
                    cn.Close();
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
        /// <returns>bool true/false</returns>
        public bool GenerateToken(CLRImportInfo clrImportInfo)
        {
            bool status = true;
            try 
            {         
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                HttpWebRequest webRequest = (HttpWebRequest)HttpWebRequest.Create(clrImportInfo.WebServiceInfo.WebServiceURL);
                webRequest.Method = "POST";
                webRequest.ContentType = "text/xml";
                webRequest.ProtocolVersion = HttpVersion.Version10;
                webRequest.ClientCertificates.Add(new X509Certificate2(clrImportInfo.WebServiceInfo.CertificatePath, clrImportInfo.WebServiceInfo.ClientSecret));
                //webRequest.ClientCertificates.Add(new X509Certificate2(@"C:\Users\abhishek\OneDrive - PG\APIS\Enercity\EPEX\UAT\ets_cert.pfx", clrImportInfo.WebServiceInfo.ClientSecret));

                string tokenRequestBody = @"<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:urn='urn:openaccess'>
                    <soapenv:Header/>
                    <soapenv:Body>
                    <urn:EstablishConnection>
                        <userLoginName>" + clrImportInfo.WebServiceInfo.UserName + @"</userLoginName>
                        <password>" + clrImportInfo.WebServiceInfo.Password + @"</password>
                    </urn:EstablishConnection>
                    </soapenv:Body>
                </soapenv:Envelope>";

                using (var writeStream = new StreamWriter(webRequest.GetRequestStream()))
                {
                    writeStream.Write(tokenRequestBody);
                    writeStream.Flush();
                    writeStream.Close();
                }

                WebResponse response = webRequest.GetResponse();
                Stream stream = response.GetResponseStream();

                StreamReader reader = new StreamReader(stream);
                string responseFromServer = reader.ReadToEnd();

                //  string responseFromServer = "<?xml version='1.0' encoding='UTF-8'?>\n<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:ns='urn:openaccess'><SOAP-ENV:Header><ns:SessionToken><ns:userLoginName>TSWHNBCDAPI50</ns:userLoginName><ns:sessionKey>30206410444687950893617550256649412468693834618229219086396964314422013513110785</ns:sessionKey></ns:SessionToken></SOAP-ENV:Header><SOAP-ENV:Body><ns:EstablishConnectionResponse><EstablishSessionResponse><ns:state>ACK</ns:state><ns:sessionToken><ns:userLoginName>TSWHNBCDAPI50</ns:userLoginName><ns:sessionKey>30206410444687950893617550256649412468693834618229219086396964314422013513110785</ns:sessionKey></ns:sessionToken></EstablishSessionResponse></ns:EstablishConnectionResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>";
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(responseFromServer);

                XmlNamespaceManager xmlnsManager = new System.Xml.XmlNamespaceManager(xmlDoc.NameTable);

                xmlnsManager.AddNamespace("SOAP-ENV", "http://schemas.xmlsoap.org/soap/envelope/");
                xmlnsManager.AddNamespace("ns", "urn:openaccess");

                XmlNode node = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:EstablishConnectionResponse/EstablishSessionResponse", xmlnsManager);
                string state = node["ns:state"].InnerText;
                string ws_name;
                if (state == "ACK")
                {
                    node = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:EstablishConnectionResponse/EstablishSessionResponse/ns:sessionToken", xmlnsManager);
                    string token = node["ns:sessionKey"].InnerText;

                    using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                    //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                    {
                        cn.Open();
                        ws_name = "EPEXRetrieveMarketResultsFor" + this.type;
                        SqlCommand updCmd = new SqlCommand("UPDATE import_web_service SET auth_token = '" + token + "' WHERE ws_name = '" + ws_name + "'", cn);
                        SqlDataReader r = updCmd.ExecuteReader();
                        clrImportInfo.WebServiceInfo.Token = token;
                        cn.Close();
                    }

                    status = true;
                }
                else
                {
                    status = false;
                }
            }
            catch (Exception ex)
            {
                status = false;
                ex.LogError("Epex Generate Token", ex.Message);
            }
            
            return status;
        }

        /// <summary>
        /// Generates response from EPEX API
        /// </summary>
        /// <param name="clrImportInfo"></param>
        /// <returns>EPEXImportStatus class</returns>
        public EPEXImportStatus GenerateResponse(CLRImportInfo clrImportInfo, String requestType)
        {
            EPEXImportStatus status = null;
            try
            {
                ServicePointManager.Expect100Continue = true;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                HttpWebRequest webRequest = (HttpWebRequest)HttpWebRequest.Create(clrImportInfo.WebServiceInfo.WebServiceURL);
                webRequest.Method = "POST";
                webRequest.ContentType = "text/xml";
                webRequest.ProtocolVersion = HttpVersion.Version10;
                webRequest.ClientCertificates.Add(new X509Certificate2(clrImportInfo.WebServiceInfo.CertificatePath, clrImportInfo.WebServiceInfo.ClientSecret));
                //webRequest.ClientCertificates.Add(new X509Certificate2(@"C:\Users\abhishek\OneDrive - PG\APIS\Enercity\EPEX\UAT\ets_cert.pfx", clrImportInfo.WebServiceInfo.ClientSecret));

                using (SqlConnection cn = new SqlConnection("Context Connection=true"))                
                //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                {
                    cn.Open();
                    try
                    {
                        SqlDataReader rd;
                        if (requestType == "DayAhead")
                        {
                            rd = cn.ExecuteStoredProcedureWithReturn("spa_import_epex_web_service", "flag:day_ahead,rules_id:" + clrImportInfo.RuleID.ToString() + ",auction_area_id:" + clrImportInfo.Params[0].paramValue.ToString() + ",auction_date:" + clrImportInfo.Params[1].paramValue.ToString().Replace(":",";") + ",auction_name_id:" + clrImportInfo.Params[2].paramValue.ToString());
                            if (rd.HasRows)
                            {
                                clrImportInfo.WebServiceInfo.RequestBody = rd[0].ToString();
                                rd.Close();
                            }
                        }                                               
                        
                    }
                    catch (Exception ex)
                    {
                        status = new EPEXImportStatus { Status = "Fail", ResponseMessage = ex.Message, Exception = ex };
                        throw status.Exception;
                    }
                    cn.Close();
                }
                using (var writeStream = new StreamWriter(webRequest.GetRequestStream()))
                {
                    writeStream.Write(clrImportInfo.WebServiceInfo.RequestBody);
                    writeStream.Flush();
                    writeStream.Close();
                }

                WebResponse response = webRequest.GetResponse();
                Stream stream = response.GetResponseStream();

                StreamReader reader = new StreamReader(stream);
                string responseFromServer = reader.ReadToEnd();
                
                /* error  
                string responseFromServer = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns=\"urn:openaccess\"><SOAP-ENV:Header><ns:AsynchronousResponseHeader SOAP-ENV:mustUnderstand=\"1\"><ns:asynchronousResponse>false</ns:asynchronousResponse><ns:responseToken></ns:responseToken></ns:AsynchronousResponseHeader><ns:ResponseLimitationHeader SOAP-ENV:mustUnderstand=\"1\"/></SOAP-ENV:Header><SOAP-ENV:Body><ns:RetrieveMarketResultsForResponse><RetrieveMarketResultAcknowledgement><ns:state>NAK</ns:state><ns:errors><ns:errorId>OA 001</ns:errorId><ns:errorText>Login Denied: Wrong session key</ns:errorText></ns:errors></RetrieveMarketResultAcknowledgement></ns:RetrieveMarketResultsForResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>";
                */

                /* sucess  
                string responseFromServer = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns=\"urn:openaccess\"><SOAP-ENV:Header><ns:AsynchronousResponseHeader SOAP-ENV:mustUnderstand=\"1\"><ns:asynchronousResponse>false</ns:asynchronousResponse><ns:responseToken></ns:responseToken></ns:AsynchronousResponseHeader><ns:ResponseLimitationHeader SOAP-ENV:mustUnderstand=\"1\"/></SOAP-ENV:Header><SOAP-ENV:Body><ns:RetrieveMarketResultsForResponse><RetrieveMarketResultAcknowledgement><ns:state>ACK</ns:state><ns:marketResults><ns:area>DE-TPS</ns:area><ns:ResultsStatus>Final</ns:ResultsStatus><ns:marketResultExport>Area set;CWE&#13;Auction name;PWR-MRC-D+1&#13;Auction date time;2020-05-06T10:00:00Z&#13;FX rates&#13;EUR;GBP;0,87290503&#13;Period duration;60&#13;Market area;AT;;BE;;DE-LU;;FR;;NL;;&#13;;Price Index (EUR/MWh);Volume Index (MW);Price Index (EUR/MWh);Volume Index (MW);Price Index (EUR/MWh);Volume Index (MW);Price Index (EUR/MWh);Volume Index (MW);Price Index (EUR/MWh);Volume Index (MW)&#13;2020-05-06T22:00:00Z;16,57;1276,5;30,00;1510,0;16,60;5028,0;12,63;1081,0;45,00;1117,8&#13;2020-05-06T23:00:00Z;16,57;1336,5;78,00;1750,0;16,60;5026,5;12,63;1081,0;45,00;1267,4&#13;2020-05-07T00:00:00Z;16,56;1334,6;10,00;1770,0;16,57;5001,0;16,55;1081,0;45,00;1404,2&#13;2020-05-07T01:00:00Z;18,52;1187,8;15,00;1772,3;18,52;5017,0;18,52;1081,0;45,00;1432,4&#13;2020-05-07T02:00:00Z;19,51;1186,9;29,00;1750,0;19,51;5018,0;19,51;1081,0;45,00;1395,4&#13;2020-05-07T03:00:00Z;22,58;1270,3;30,00;1750,0;22,53;3901,5;22,53;1081,0;45,00;1469,0&#13;2020-05-07T04:00:00Z;27,03;940,2;45,00;1990,0;26,99;3939,7;27,02;1082,9;45,00;1377,8&#13;2020-05-07T05:00:00Z;29,50;676,7;78,00;1990,0;29,49;3927,5;29,51;1088,8;45,00;1448,1&#13;2020-05-07T06:00:00Z;37,27;878,1;80,00;1990,0;37,22;4284,4;37,53;935,6;45,00;1280,0&#13;2020-05-07T07:00:00Z;45,46;1742,0;80,00;1990,0;45,45;7253,6;45,47;1623,6;45,00;1280,0&#13;2020-05-07T08:00:00Z;46,46;1767,0;80,00;1990,0;46,45;7315,9;46,45;1934,1;45,00;1439,0&#13;2020-05-07T09:00:00Z;47,46;1830,0;98,00;1990,0;47,45;7367,0;47,45;2038,9;42,00;1558,1&#13;2020-05-07T10:00:00Z;48,46;1830,0;98,00;1990,0;48,45;7446,1;48,45;2024,5;42,00;1775,0&#13;2020-05-07T11:00:00Z;52,21;1830,0;108,00;1990,0;52,16;7662,2;52,11;2044,4;42,00;1775,0&#13;2020-05-07T12:00:00Z;57,84;1830,0;108,00;1990,0;57,80;7897,5;57,78;2034,5;34,20;1785,0&#13;2020-05-07T13:00:00Z;68,25;1830,0;98,00;1990,0;68,09;7907,0;68,02;2017,1;34,20;1785,0&#13;2020-05-07T14:00:00Z;87,19;1830,0;80,00;1990,0;86,99;7905,4;86,92;2002,0;40,00;1775,3&#13;2020-05-07T15:00:00Z;98,92;1680,0;78,00;1990,0;98,90;7892,0;98,89;1997,1;42,00;1775,0&#13;2020-05-07T16:00:00Z;100,92;1680,0;30,00;1750,0;100,90;7900,7;100,89;1955,0;42,00;1775,0&#13;2020-05-07T17:00:00Z;105,69;1680,0;29,00;1750,0;105,60;7894,3;105,59;1924,4;42,00;1766,8&#13;2020-05-07T18:00:00Z;116,92;1560,0;15,00;1785,0;116,88;6446,0;116,86;1581,7;42,00;1688,6&#13;2020-05-07T19:00:00Z;129,60;1561,0;15,00;1778,4;129,58;6472,6;129,57;1577,3;45,00;1471,7&#13;2020-05-07T20:00:00Z;139,63;1441,0;10,00;1773,9;139,68;5052,8;139,67;1221,9;45,00;1272,0&#13;2020-05-07T21:00:00Z;146,39;1491,0;10,00;1772,2;146,40;5033,5;146,40;1237,9;45,00;1337,7&#13;Sum/Avg;62,31;35669,6;55,50;44791,8;62,28;148590,2;61,96;36807,7;43,02;36451,3&#13;DE-TPS;;;Participant: SWHANN;;;;;;;;;;;;Portfolio: SWHANN-T01;;;;;;;;;;;;Portfolio: SWHANN-T02;;;;;;;;;;;;Portfolio: SWHANN-SABT01;;;;;;;;;;;;Portfolio: SWHANN-PM1&#13;;;;Total Sched.;;;Linear Sched.;;;Block Sched.;;;Complex Sched.;;;Total Sched.;;;Linear Sched.;;;Block Sched.;;;Complex Sched.;;;Total Sched.;;;Linear Sched.;;;Block Sched.;;;Complex Sched.;;;Total Sched.;;;Linear Sched.;;;Block Sched.;;;Complex Sched.;;;Total Sched.;;;Linear Sched.;;;Block Sched.;;;Complex Sched.;;&#13;;MCP (EUR/MWh);MCV (MW);Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;Net;Purchase;Sale;&#13;2020-05-06T22:00:00Z;16,60;5028,0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-06T23:00:00Z;16,60;5026,5;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T00:00:00Z;16,57;5001,0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T01:00:00Z;18,52;5017,0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T02:00:00Z;19,51;5018,0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T03:00:00Z;22,53;3901,5;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T04:00:00Z;26,99;3939,7;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T05:00:00Z;29,49;3927,5;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T06:00:00Z;37,22;4284,4;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T07:00:00Z;45,45;7253,6;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T08:00:00Z;46,45;7315,9;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T09:00:00Z;47,45;7367,0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T10:00:00Z;48,45;7446,1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T11:00:00Z;52,16;7662,2;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T12:00:00Z;57,80;7897,5;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T13:00:00Z;68,09;7907,0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T14:00:00Z;86,99;7905,4;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T15:00:00Z;98,90;7892,0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T16:00:00Z;100,90;7900,7;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T17:00:00Z;105,60;7894,3;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T18:00:00Z;116,88;6446,0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T19:00:00Z;129,58;6472,6;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T20:00:00Z;139,68;5052,8;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;2020-05-07T21:00:00Z;146,40;5033,5;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;Sum/Avg;62,28;148590,2;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;01-24 (Baseload);62,28;148590,2;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;09-20 (Peakload);66,29;88726,1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;21-24 (Off-Peak 2);133,14;23004,9;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;01-08 &amp; 21-24 (Off-Peak);58,28;59864,1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;01-08 (Off-Peak 1);20,85;36859,2;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0&#13;</ns:marketResultExport></ns:marketResults></RetrieveMarketResultAcknowledgement></ns:RetrieveMarketResultsForResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>";
                */

                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(responseFromServer);

                XmlNamespaceManager xmlnsManager = new System.Xml.XmlNamespaceManager(xmlDoc.NameTable);
                string outputResponse;
               
                xmlnsManager.AddNamespace("SOAP-ENV", "http://schemas.xmlsoap.org/soap/envelope/");
                xmlnsManager.AddNamespace("ns", "urn:openaccess");
                XmlNode node = xmlDoc.SelectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/ns:RetrieveMarketResultsForResponse/RetrieveMarketResultAcknowledgement/ns:errors/ns:errorText", xmlnsManager);
                
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

                status = new EPEXImportStatus { Status = "Success", ResponseMessage = outputResponse, Exception = null, Area = area, ResultStatus = resultStatus };

            }
            catch (Exception ex)
            {
                status = new EPEXImportStatus { Status = "Fail", ResponseMessage = ex.Message, Exception = ex };
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
            bool updStatus;
            try
            {
                               
                //Validty of password is 90 days. So update password if less than 7 days remain
                if ((DateTime.Now.Date - clrImportInfo.WebServiceInfo.PasswordUpdatedDate.Date).Days > 83)
                {
                    bool token = GenerateToken(clrImportInfo);
                    if (token == false) throw new Exception("Failed to Generate Token while updating password.");
                    updStatus = UpdatePassword(clrImportInfo);
                    if (updStatus == false) throw new Exception("Failed to Update Password.");
                }

                //Generate response, if token has expired generate token and regenerate response               
                EPEXImportStatus WebResponse = GenerateResponse(clrImportInfo, this.type);
                if (WebResponse.ResponseMessage == "Login Denied: Wrong session key")
                {
                    bool token = GenerateToken(clrImportInfo);
                    if (token == false) throw new Exception("Failed to Generate Token.");
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
                //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                {
                    cn.Open();

                    SqlDataReader rd = cn.ExecuteStoredProcedureWithReturn("spa_ixp_import_data_source", "flag:x,rules_id:" + clrImportInfo.RuleID.ToString());
                    if (rd.HasRows)
                    {
                        dataSourceAlias = rd[0].ToString();
                        rd.Close();
                    }

                    processTableName = "adiha_process.dbo.temp_import_data_table_" + dataSourceAlias + "_" + clrImportInfo.ProcessID;
                    string createTableSql = "IF OBJECT_ID('" + processTableName + "') IS NOT NULL DROP TABLE " + processTableName;

                    var cmd = new SqlCommand(createTableSql, cn).ExecuteNonQuery();

                    createTableSql = "CREATE TABLE " + processTableName + "(" + "[" + dt.Columns[0].ColumnName + "] NVARCHAR(MAX), " + "[" + dt.Columns[1].ColumnName + "] INT)";

                    var cmd1 = new SqlCommand(createTableSql, cn).ExecuteNonQuery();
                    
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

        public class EPEXImportStatus
        {
            public string Status { get; set; }
            public string ResponseMessage { get; set; }
            public Exception Exception { get; set; }
            public string Area { get; set; }
            public string ResultStatus { get; set; }
        }
    }
}
