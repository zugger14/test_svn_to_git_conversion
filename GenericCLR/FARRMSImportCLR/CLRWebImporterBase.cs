using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;

namespace FARRMSImportCLR
{
    public abstract class CLRWebImporterBase : ICLRImporter
    {
        public abstract ImportStatus ImportData(CLRImportInfo clrImportInfo);

        public virtual ImportStatus WebFileDownload(ImportWebServiceInfo importWebServiceInfo, string downloadFolder, string downloadFileName)
        {
            ImportStatus webServiceDownloadStatus = null;
            try
            {
                using (var client = new WebClient())
                {
                    //TODO: Handle authentication, downloadFileName NULL
                    downloadFolder += downloadFileName;
                    client.DownloadFile(importWebServiceInfo.WebServiceURL, downloadFolder);
                    webServiceDownloadStatus = new ImportStatus { Status = "Success", ResponseMessage = "File downloaded successfully." , Exception = null };
                }
            }
            catch (Exception ex)
            {                
                string outputResult = ex.Message;
               // ex.LogError("Web File Download", importWebServiceInfo + "|" + downloadFolder + "|" + downloadFileName + "|" + outputResult);

                webServiceDownloadStatus = new ImportStatus { Status = "Fail", ResponseMessage = ex.Message, Exception = ex };
            }

            return webServiceDownloadStatus;
        }
    }
}
