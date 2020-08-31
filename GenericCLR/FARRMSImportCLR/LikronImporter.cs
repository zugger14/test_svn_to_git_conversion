using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.IO;
using System.Data.SqlClient;
using System.Data;
using FARRMSUtilities;

namespace FARRMSImportCLR
{
    #region CLR Import
    /// <summary>
    /// Class LikronImporter derive from CLRWebImporterBase.
    /// </summary>
    class LikronImporter : CLRWebImporterBase
    {
        /// <summary>
        /// Import tradelist data response from Likron API(REST API). 
        /// </summary>
        /// <param name="clrImportInfo"></param>
        /// <returns></returns>
        public override ImportStatus ImportData(CLRImportInfo clrImportInfo)
        {
            string processTable = "adiha_process.dbo.likron_import_" + clrImportInfo.ProcessID;
            var responseString = "";
            ImportStatus importStatus = new ImportStatus();
            try
            {
                //Basis authentication header generator
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
                request.Headers.Add("Authorization", "Basic " + credentialsValue);

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

               //using (SqlConnection cn = new SqlConnection("Data Source=SG-D-SQL01.FARRMS.US,2033;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    using (SqlCommand cmd = new SqlCommand("spa_import_epex_web_service", cn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("flag", "likron");
                        cmd.Parameters.AddWithValue("process_id", clrImportInfo.ProcessID);
                        cmd.Parameters.AddWithValue("process_table", processTable);
                        cmd.Parameters.AddWithValue("response_data", (statusResult == "Success" ? responseString : "[]"));
                        cn.Open();
                        cmd.ExecuteNonQuery();
                        cn.Close();
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
                webEx.LogError("LikronImport", clrImportInfo.WebServiceInfo.WebServiceURL + "|" + responseString + "|" + processTable + "|" + "|" + webEx.Message);
            }
            catch (Exception ex)
            {
                importStatus.ProcessTableName = processTable;
                importStatus.Status = "Failed";
                importStatus.Exception = ex;
                importStatus.ResponseMessage = ex.Message;
                ex.LogError("LikronImport", clrImportInfo.WebServiceInfo.WebServiceURL + "|" + responseString + "|" + processTable + "|" + "|" + ex.Message);
            }
            return importStatus;
        }
    }
    #endregion
}
