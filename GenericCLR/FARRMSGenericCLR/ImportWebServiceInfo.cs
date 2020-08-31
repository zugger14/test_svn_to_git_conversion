using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSGenericCLR
{
    /// <summary>
    /// Information of web services to be used for Data Import
    /// </summary>
    public class ImportWebServiceInfo
    {
        public string WebServiceURL { get; set; }
        public string Token { get; set; }
        public string RequestBody { get; set; }
        public string RequestParams { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public string AuthUrl { get; set; }
        public string ClientId { get; set; }
        public string ClientSecret { get; set; }
        public string CertificatePath { get; set; }
        public DateTime PasswordUpdatedDate { get; set; }
    }
}
