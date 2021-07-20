using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.IO;
using System.Data.SqlClient;
using System.Data;
using FARRMSUtilities;
// Version information for an assembly consists of the following four values:
//
//      Major Version
//      Minor Version 
//      Build Number
//      Revision
//

namespace FARRMSImportCLR
{
    #region CLR Import

    class PrismaImporter : CLRWebImporterBase
        {
        public override ImportStatus ImportData(CLRImportInfo clrImportInfo)
            {
                string processTable = "adiha_process.dbo.prisma_import_" + clrImportInfo.ProcessID;
                ImportStatus importStatus = new ImportStatus();
                var responseString = "";
                    string auctionId =  clrImportInfo.Params[0].paramValue;
                    if (auctionId == "null"){
                        auctionId = "";
                      }
                    string bookedAt =   clrImportInfo.Params[1].paramValue;
                        if (bookedAt == "null")
                        {
                            bookedAt = "";
                        }
                    string bookedSince = clrImportInfo.Params[2].paramValue;
                        if (bookedSince == "null")
                        {
                             bookedSince = "";
                        }
                    string bookedBefore = clrImportInfo.Params[3].paramValue;
                        if (bookedBefore == "null")
                        {
                            bookedBefore = "";
                        }
                    bookedSince = (bookedSince != "") ? System.Convert.ToDateTime(bookedSince).ToString("yyyy-MM-dd HH:mm:ss").Replace(" ", "T") + ".000Z" : "";
                    bookedBefore = (bookedBefore != "") ? System.Convert.ToDateTime(bookedBefore).ToString("yyyy-MM-dd HH:mm:ss").Replace(" ", "T") + ".000Z" : "";
                    clrImportInfo.WebServiceInfo.WebServiceURL = (bookedAt != "") ? clrImportInfo.WebServiceInfo.WebServiceURL + "?bookedAt=" + bookedAt : clrImportInfo.WebServiceInfo.WebServiceURL;
                  
                    if (!string.IsNullOrEmpty(bookedAt)){
                        clrImportInfo.WebServiceInfo.WebServiceURL = (auctionId != "") ? clrImportInfo.WebServiceInfo.WebServiceURL + "&auctionId=" + auctionId : clrImportInfo.WebServiceInfo.WebServiceURL;
                    } else {
                        clrImportInfo.WebServiceInfo.WebServiceURL = (auctionId != "") ? clrImportInfo.WebServiceInfo.WebServiceURL + "?auctionId=" + auctionId : clrImportInfo.WebServiceInfo.WebServiceURL;
                    }
                    if (!string.IsNullOrEmpty(bookedAt) || !string.IsNullOrEmpty(auctionId)){
                        clrImportInfo.WebServiceInfo.WebServiceURL = (bookedSince != "") ? clrImportInfo.WebServiceInfo.WebServiceURL + "&bookedSince=" + bookedSince : clrImportInfo.WebServiceInfo.WebServiceURL;
                    } else {
                        clrImportInfo.WebServiceInfo.WebServiceURL = (bookedSince != "") ? clrImportInfo.WebServiceInfo.WebServiceURL + "?bookedSince=" + bookedSince : clrImportInfo.WebServiceInfo.WebServiceURL;
                    }
                    if (!string.IsNullOrEmpty(bookedAt) || !string.IsNullOrEmpty(auctionId)|| !string.IsNullOrEmpty(bookedSince))
                    {
                        clrImportInfo.WebServiceInfo.WebServiceURL = (bookedBefore != "") ? clrImportInfo.WebServiceInfo.WebServiceURL + "&bookedBefore=" + bookedBefore : clrImportInfo.WebServiceInfo.WebServiceURL;
                    }
                    else
                    {
                        clrImportInfo.WebServiceInfo.WebServiceURL = (bookedBefore != "") ? clrImportInfo.WebServiceInfo.WebServiceURL + "?bookedBefore=" + bookedBefore : clrImportInfo.WebServiceInfo.WebServiceURL;
                    }
                    try
                    {
                    string credentialsValue = Convert.ToBase64String(Encoding.Default.GetBytes(clrImportInfo.WebServiceInfo.UserName + ":" + clrImportInfo.WebServiceInfo.Password));
                    //Proper Secure Sockets Layer (SSL) or Transport Layer Security (TLS) protocol to use for new connections 
                    ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);

                    var request = (HttpWebRequest)WebRequest.Create(clrImportInfo.WebServiceInfo.WebServiceURL);
                    request.Timeout = -1;
                    request.UseDefaultCredentials = true;
                    request.PreAuthenticate = true;
                    request.Credentials = CredentialCache.DefaultCredentials;
                    request.Method = "GET";
                    request.ContentType = "application/json; charset=utf-8";
                    request.Headers.Add("Authorization", "Bearer " + clrImportInfo.WebServiceInfo.Password);

                    string statusResult = "";
                    using (var httpResponse = (HttpWebResponse)request.GetResponse())
                    {
                        if (httpResponse.StatusCode == HttpStatusCode.OK)
                        {
                            responseString = new StreamReader(httpResponse.GetResponseStream()).ReadToEnd();
                            statusResult = "Success";
                        }
                        else
                        {
                            responseString = new StreamReader(httpResponse.GetResponseStream()).ReadToEnd();
                            statusResult = "Failed";
                        }
                    }

               
                string dataSourceAlias = "prisma_interface";
                string processTableName = "";
                processTableName = "adiha_process.dbo.prisma_data_json_" + dataSourceAlias + "_" + clrImportInfo.ProcessID;

                //using (SqlConnection cn = new SqlConnection("Data Source=EU-D-SQL01.farrms.us,2033;Initial Catalog=TRMTracker_Enercity;Persist Security Info=True;User ID=Dev_Admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                {
                    cn.Open();
                    using (SqlCommand insertCmd = new SqlCommand("Select '" + responseString + "' as response into " + processTableName, cn))
                    {
                        insertCmd.ExecuteNonQuery();
                    }
                    //using (SqlConnection cn = new SqlConnection("Data Source=EU-D-SQL01.farrms.us,2033;Initial Catalog=TRMTracker_Enercity;Persist Security Info=True;User ID=Dev_Admin;password=Admin2929"))
                    using (SqlCommand cmd = new SqlCommand("spa_prisma_interface", cn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("flag", "prisma");
                        cmd.Parameters.AddWithValue("response_data", responseString);
                        cmd.Parameters.AddWithValue("process_id", clrImportInfo.ProcessID);
                        cmd.ExecuteNonQuery();
                    }
                }
                   
                importStatus.Status = (statusResult == "Success") ? "Success" : "Failed";
                    importStatus.ProcessTableName = processTable;
                    importStatus.ResponseMessage = "Data Dumped To Process Table";

                }
                catch (WebException webEx)
                {
                    importStatus.ProcessTableName = processTable;
                    importStatus.Status = "Failed";
                    importStatus.Exception = webEx;
                    importStatus.ResponseMessage = webEx.Message;
                    webEx.LogError("PrismaImport", clrImportInfo.WebServiceInfo.WebServiceURL + "|" + responseString + "|" + processTable + "|" + "|" + webEx.Message);
                }
                catch (Exception ex)
                {
                    importStatus.ProcessTableName = processTable;
                    importStatus.Status = "Failed";
                    importStatus.Exception = ex;
                    importStatus.ResponseMessage = ex.Message;
                    ex.LogError("PrismaImport", clrImportInfo.WebServiceInfo.WebServiceURL + "|" + responseString + "|" + processTable + "|" + "|" + ex.Message);
                }
                return importStatus;
            }
        }
        #endregion
    }