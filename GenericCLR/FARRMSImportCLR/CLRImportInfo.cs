using System.Collections.Generic;
using System.Data.SqlClient;
using FARRMSUtilities;
using System;

namespace FARRMSImportCLR
{
    /// <summary>
    /// Contains information needed for Data Import
    /// </summary>
    public class CLRImportInfo
    {
        private int _ruleID;
        public int RuleID
        {
            get
            {
                return this._ruleID;
            }
            set
            {

                this._ruleID = value;
                //TODO: load ImportWebServiceInfo
                this.WebServiceInfo  = new ImportWebServiceInfo();

                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                {
                    cn.Open();

                    SqlDataReader rd = cn.ExecuteStoredProcedureWithReturn("spa_import_web_service", "flag:w,rules_id:" + this._ruleID);
                    if (rd != null)
                    {
                        if (rd.HasRows)
                        {
                            WebServiceInfo.WebServiceURL = rd["web_service_url"].ToString();
                            WebServiceInfo.UserName = rd["user_name"].ToString();
                            WebServiceInfo.Password = rd["password"].ToString();
                            WebServiceInfo.Token = rd["auth_token"].ToString();
                            WebServiceInfo.RequestBody = rd["request_body"].ToString();
                            WebServiceInfo.RequestParams = rd["request_params"].ToString();
                            WebServiceInfo.AuthUrl = rd["auth_url"].ToString();
                            WebServiceInfo.ClientId = rd["client_id"].ToString();
                            WebServiceInfo.ClientSecret = rd["client_secret"].ToString();
                            WebServiceInfo.CertificatePath = rd["certificate_path"].ToString();
                            WebServiceInfo.ApiKey = rd["api_key"].ToString();
                            if (rd["password_updated_date"].ToString() != "")
                            {
                                WebServiceInfo.PasswordUpdatedDate = DateTime.Parse(rd["password_updated_date"].ToString());
                            }
                            rd.Close();
                        }

                    }
                    cn.Close();
                }
            }
        }
        public string ProcessID { get; set; }
        public string MethodName { get; set; }
        public List<CLRParameter> Params = new List<CLRParameter>();
        public ImportWebServiceInfo WebServiceInfo { get; set; }
    }
    /// <summary>
    /// Parameters to be used while importing data, if any
    /// </summary>
    public class CLRParameter
    {
        public string paramName { get; set; }
        public string paramValue { get; set; }
    }
}
