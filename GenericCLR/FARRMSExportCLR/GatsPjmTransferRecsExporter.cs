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
    #region GatsPjmTransferRecsExporter Business logic for TransferRECsExporter

    class GatsPjmTransferRecsExporter : IWebServiceDataDispatcher
    {
        public ExportStatus DispatchData(ExportWebServiceInfo exportWebServiceInfo, string tableNameorQuery, string exportFileFullPath, string processID)
        {
            ExportStatus exportStatus = new ExportStatus();
            exportStatus.ProcessID = processID;
            string response = null;

            try
            {
                StreamWriter streamWriter;
                //tableNameorQuery = "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:agg='http://pjm-eis.com/Aggregator'>   <soapenv:Header/>   <soapenv:Body>   <agg:TransferRec>         <agg:aggName>Test1</agg:aggName>         <agg:aggToken>1FA1074A-A6D4-4522-A77E-D38F73D8798E</agg:aggToken>         <agg:RECRecords>             <!--Zero or more repetitions:-->            <agg:RECtransfer>               <agg:RowID>22222</agg:RowID>               <agg:GATSUnitID>MSET53813137</agg:GATSUnitID>               <agg:RECSerialNumber>1771330 1-10</agg:RECSerialNumber>               <agg:MonthYear>12/2015</agg:MonthYear>               <agg:Quantity>10</agg:Quantity>               <!--Optional:-->               <agg:Price>3.5</agg:Price>               <agg:AccountID>14191</agg:AccountID>               <agg:AccountName>14191 ACC</agg:AccountName>               <agg:TransferType>Spot</agg:TransferType>            </agg:RECtransfer>         </agg:RECRecords>      </agg:TransferRec></soapenv:Body></soapenv:Envelope>";

                //Proper Secure Sockets Layer (SSL) or Transport Layer Security (TLS) protocol to use for new connections 
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                var webRequest = (HttpWebRequest)WebRequest.Create(exportWebServiceInfo.webServiceURL);
                webRequest.Method = "POST";
                webRequest.ContentType = "text/xml";
                webRequest.Headers.Add("SOAPAction", exportWebServiceInfo.requestParam);

                using (streamWriter = new StreamWriter(webRequest.GetRequestStream()))
                {
                    streamWriter.Write(tableNameorQuery);
                    streamWriter.Close();
                }

                using (var httpResponse = (HttpWebResponse)webRequest.GetResponse())
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
