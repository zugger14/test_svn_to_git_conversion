using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
namespace FARRMSGenericCLR
{
    #region Data Transfer object
    /// <summary>
    /// Information of Web Service in which data is to be exported
    /// </summary>
    public class ExportWebServiceInfo
    {
       public string webServiceURL { get; set; }
       public string authToken { get; set; }
       public string handlerClassName { get; set; }
       public SqlConnection Connection { get; set; }
       public string userName { get; set; }
       public string requestParam { get; set; }
       public string authUrl { get; set; }
       public string password { get; set; }

    }
    #endregion 
}
