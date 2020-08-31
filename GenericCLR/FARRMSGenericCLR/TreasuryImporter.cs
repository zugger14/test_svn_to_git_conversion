using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Net;

namespace FARRMSGenericCLR
{
    class TreasuryImporter : CLRWebImporterBase
    {
        public override ImportStatus ImportData(CLRImportInfo clrImportInfo)
        {
            string processTable = "adiha_process.dbo.treasury_import_" + clrImportInfo.ProcessID;
            string responseFromServer = "";
            ImportStatus importStatus = new ImportStatus();
            try
            {
                WebRequest request = WebRequest.Create(clrImportInfo.WebServiceInfo.WebServiceURL);
                request.Method = "GET";
                WebResponse response = request.GetResponse();
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);
                responseFromServer = reader.ReadToEnd();

                string statusResult = "";
                StoredProcedure.ImportFromXml(responseFromServer, "", processTable, "y", out statusResult);
                importStatus.ProcessTableName = processTable;
                importStatus.Status = (statusResult != "failed") ? "Success" : "Failed";
                importStatus.ResponseMessage = "Data Dumped To Process Table";
            }

            catch (WebException webex)
            {
                importStatus.ProcessTableName = processTable;
                importStatus.Status = "Failed";
                importStatus.Exception = webex;
                importStatus.ResponseMessage = webex.Message;
                webex.LogError("TreasuryImporter", clrImportInfo.WebServiceInfo.WebServiceURL + "|" + responseFromServer + "|" + processTable + "|" + "|" + webex.Message);
            }

            catch (Exception ex)
            {
                importStatus.ProcessTableName = processTable;
                importStatus.Status = "Failed";
                importStatus.Exception = ex;
                importStatus.ResponseMessage = ex.Message;
                ex.LogError("TreasuryImporter", clrImportInfo.WebServiceInfo.WebServiceURL + "|" + responseFromServer + "|" + processTable + "|" + "|" + ex.Message);
            }

            return importStatus;
        }
    }
}
