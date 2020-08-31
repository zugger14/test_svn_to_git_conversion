using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Net;
using System.IO;
using System.Data.SqlClient;
using System.Data;
namespace FARRMSGenericCLR
{
    #region NepoolTransferRequestExporter Business logic for NepoolTransferRequest
    /// <summary>
    /// Class to export RECs to Nepool Web Service 
    /// </summary>
    class NepoolTransferRequestExporter : IWebServiceDataDispatcher
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

            try
            {
                //tableNameorQuery = "[{\"buyerAccountId\": 14667,\"certificateSerialNumberRange\": \"4086133 - 24 to 137\",\"notes\": \"test transfer\",\"pricePerCertificate\":10.00,\"quantity\": 10,\"requestCorrelationId\": \"15999\"  }]";

                //Proper Secure Sockets Layer (SSL) or Transport Layer Security (TLS) protocol to use for new connections               
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                HttpWebRequest webRequest = (HttpWebRequest)HttpWebRequest.Create(exportWebServiceInfo.authUrl);
                webRequest.Method = "POST";
                webRequest.ContentType = "application/x-www-form-urlencoded";
                webRequest.Headers.Add("Authorization", "Basic TkVQT09MLUNsaWVudC1BUEk6cFleQ0FxSHVQeiZiN3olLXNISnAyPVF6M3EhV0FXWC10QnUmUGNwQQ==");

                string postData = "username=" + exportWebServiceInfo.userName + "&password=" + exportWebServiceInfo.password + "&grant_type=password";
                var data = Encoding.ASCII.GetBytes(postData);
                webRequest.ContentLength = data.Length;

                using (var writeStream = webRequest.GetRequestStream())
                {
                    writeStream.Write(data, 0, data.Length);
                    writeStream.Flush();
                    writeStream.Close();
                }

                WebResponse tokResponse = webRequest.GetResponse();
                Stream stream = tokResponse.GetResponseStream();

                StreamReader reader = new StreamReader(stream);
                string responseFromServer = reader.ReadToEnd();

                string refineData = responseFromServer.Replace(":", ",").Replace("{", "").Replace("}", "");

                string[] arrayData = refineData.Split(',').Select(sValue => sValue.Trim()).ToArray();
                string accessToken = "";
                accessToken = arrayData[1].Replace(@"""", "");

                HttpWebRequest webRequestTrans = (HttpWebRequest)HttpWebRequest.Create(exportWebServiceInfo.webServiceURL + "TransferRequests");
                webRequestTrans.Method = "POST";
                webRequestTrans.ContentType = "application/json";
                webRequestTrans.Headers.Add("Authorization", "Bearer " + accessToken);

                data = Encoding.ASCII.GetBytes(tableNameorQuery);
                webRequestTrans.ContentLength = data.Length;

                using (var writeStream = webRequestTrans.GetRequestStream())
                {
                    writeStream.Write(data, 0, data.Length);
                    writeStream.Flush();
                    writeStream.Close();
                }

                using (var httpResponse = (HttpWebResponse)webRequestTrans.GetResponse())
                {
                    using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
                    {
                        response = streamReader.ReadToEnd();
                    }
                }

                exportStatus.ResponseMessage = response;
                exportStatus.Status = response;// "Success";               
            }
            catch (WebException webEx)
            {
                //try to grab web response                
                string errorResponseMessage = null;
                if (webEx.Response == null)
                {
                    errorResponseMessage = webEx.Status.ToString();
                }
                else
                {
                    WebResponse errorResponse = webEx.Response;
                    using (var responseStream = errorResponse.GetResponseStream())
                    {
                        var reader = new StreamReader(responseStream);
                        errorResponseMessage = reader.ReadToEnd();
                    }
                }
                //throw new Exception(errorResponseMessage, webEx);
                //response = errorResponseMessage.Replace("{", string.Empty).Replace("}", string.Empty) + exportStatus.FilePath;
                exportStatus.ResponseMessage = "Failed";
                exportStatus.Status = errorResponseMessage;
                exportStatus.Exception = webEx;
            }          
            catch (Exception ex)
            {
                //handle other exeception (like IOException [path not accessible])
                exportStatus.ResponseMessage = "Failed";
                exportStatus.Status = ex.Message;
                exportStatus.Exception = ex;
            }
            return exportStatus;
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
