using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Net;
using System.IO;
using Microsoft.SqlServer.Server;
using FARRMSUtilities;

namespace FARRMSImportCLR
{
    class LocusEnergyMntlyVolsImporter : CLRWebImporterBase
    {
       
        public override ImportStatus ImportData(CLRImportInfo clrImportInfo)
        {
            ImportStatus status = null;
            try
            {
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection("Data Source=SG-D-SQL01.FARRMS.US,2033;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                {
                    cn.Open();
                    SqlDataReader rd = cn.ExecuteStoredProcedureWithReturn("spa_import_web_service", "flag:w,rules_id:" + clrImportInfo.RuleID.ToString());
                    try
                    {
                        if (rd.HasRows)
                        {

                            clrImportInfo.WebServiceInfo.WebServiceURL = rd["web_service_url"].ToString();
                            clrImportInfo.WebServiceInfo.Password = rd["password"].ToString();                            
                            clrImportInfo.WebServiceInfo.UserName = rd["user_name"].ToString();
                            clrImportInfo.WebServiceInfo.AuthUrl = rd["auth_url"].ToString();
                            clrImportInfo.WebServiceInfo.ClientId = rd["client_id"].ToString();
                            clrImportInfo.WebServiceInfo.ClientSecret = rd["client_secret"].ToString();
                        }
                        rd.Close();

                    }
                    catch (Exception ex)
                    {
                        status = new ImportStatus { Status = "Fail", ResponseMessage = ex.Message, Exception = ex };
                        throw status.Exception;
                    }

                    //SqlContext.Pipe.ExecuteAndSend(new SqlCommand("SELECT '" + clrImportInfo.WebServiceInfo.WebServiceURL + "' as result, '" + clrImportInfo.WebServiceInfo.Token + "' AS message, '" + clrImportInfo.WebServiceInfo.RequestBody + "' AS destination, '" + clrImportInfo.WebServiceInfo.UserName + "' AS output_file_name, '" + clrImportInfo.WebServiceInfo.RequestParams+"' as RequestParams", cn));
                    cn.Close();
                }               

                //Proper Secure Sockets Layer (SSL) or Transport Layer Security (TLS) protocol to use for new connections 
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                HttpWebRequest webRequest = (HttpWebRequest)HttpWebRequest.Create(clrImportInfo.WebServiceInfo.AuthUrl);
                webRequest.Method = "POST";
                webRequest.ContentType = "application/x-www-form-urlencoded";

                string postData = "username=" + clrImportInfo.WebServiceInfo.UserName + "&password=" + clrImportInfo.WebServiceInfo.Password + "&client_id=" + clrImportInfo.WebServiceInfo.ClientId
                    + "&client_secret=" + clrImportInfo.WebServiceInfo.ClientSecret + "&grant_type=password";
                var data = Encoding.ASCII.GetBytes(postData);
                webRequest.ContentLength = data.Length;

                using (var writeStream = webRequest.GetRequestStream())
                {
                    writeStream.Write(data, 0, data.Length);
                    writeStream.Flush();
                    writeStream.Close();
                }           

                WebResponse response = webRequest.GetResponse();
                Stream stream = response.GetResponseStream();

                StreamReader reader = new StreamReader(stream);
                string responseFromServer = reader.ReadToEnd();

                string refineData = responseFromServer.Replace(":", ",").Replace("{", "").Replace("}", "");

                string[] arrayData = refineData.Split(',').Select(sValue => sValue.Trim()).ToArray();
                string accessToken = accessToken = arrayData[1].Replace(@"""", ""); ;
                
                //Console.WriteLine(responseFromServer);
                string dataSourceAlias = "";
                string processTableName = "";
                string url= "";

                string[] arr_plant_ids = clrImportInfo.Params[2].paramValue.Split(',');
                responseFromServer = "";

                foreach (var plant_id in arr_plant_ids)
                {
                    url = clrImportInfo.WebServiceInfo.WebServiceURL.Replace("<__site_id__>", plant_id);
                    url = url + "?fields=Wh_sum&start=" + clrImportInfo.Params[0].paramValue + "T00:00:00&end=" + clrImportInfo.Params[1].paramValue + "T00:00:00&tz=America/Los_Angeles&gran=monthly";
                    //Proper Secure Sockets Layer (SSL) or Transport Layer Security (TLS) protocol to use for new connections 
                    ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                    webRequest = (HttpWebRequest)HttpWebRequest.Create(url);
                    webRequest.Method = "GET";
                    webRequest.Headers.Add("Authorization", "Bearer " + accessToken);
                    webRequest.Accept = "application/json";
                    response = webRequest.GetResponse();
                    stream = response.GetResponseStream();
                    reader = new StreamReader(stream);
                    responseFromServer += reader.ReadToEnd() + ",";
                }

                responseFromServer = "[" + responseFromServer.Trim(',') + "]";

                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection("Data Source=SG-D-SQL01.FARRMS.US,2033;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                {
                    cn.Open();

                    SqlDataReader rd = cn.ExecuteStoredProcedureWithReturn("spa_ixp_import_data_source", "flag:x,rules_id:" + clrImportInfo.RuleID.ToString());
                    if (rd.HasRows)
                    {
                        dataSourceAlias = rd[0].ToString();
                        rd.Close();
                    }

                    processTableName = "adiha_process.dbo.temp_import_data_table_" + dataSourceAlias + "_" + clrImportInfo.ProcessID;

                    using (SqlCommand cmd = new SqlCommand("EXEC spa_process_rec_api_info 'locus_energy_volume', '" + clrImportInfo.RuleID.ToString() + "', '" + processTableName + "', '" + responseFromServer + "'", cn))
                    {
                        SqlDataReader read = cmd.ExecuteReader();
                        if (read.HasRows)
                        {
                            read.Read();
                            if (read[0].ToString().ToUpper() != "SUCCESS")
                            {
                                status = new ImportStatus { Status = "Fail", ResponseMessage = read[0] + ": " + read[4], Exception = new Exception() };
                                status.ProcessTableName = "adiha_process.dbo.temp_import_data_table_" + dataSourceAlias + "_" + clrImportInfo.ProcessID;
                                return status;
                            }
                        }
                    }

                    status = new ImportStatus { Status = "Success", ResponseMessage = "Data inserted in Process table successfully.", Exception = null };
                    status.ProcessTableName = "adiha_process.dbo.temp_import_data_table_" + dataSourceAlias + "_" + clrImportInfo.ProcessID;

                    cn.Close();
                }

                return status;
            }
            catch (Exception ex)
            {
                status = new ImportStatus { Status = "Fail", ResponseMessage = ex.Message, Exception = ex };
                throw status.Exception;
            }
        }
    }
}
