using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;

namespace FARRMSExportCLR
{ 
    //every implementation of web service data exporter should implement this interface
    public interface IWebServiceDataDispatcher
    {
        ExportStatus DispatchData(ExportWebServiceInfo exportWebServiceInfo, string dataTableNameOrQuery, string exportFileFullPath, string processID);
    }
}
