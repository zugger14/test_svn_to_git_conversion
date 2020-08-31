using System;
using System.Data;
using System.Data.SqlClient;
using FARRMSUtilities;
namespace FARRMSExportCLR
{
    public class StoredProcedure
    {
        [Microsoft.SqlServer.Server.SqlProcedure]
        #region Created method for webservice

        /// <summary>
        /// Post data to different web services
        /// </summary>
        /// <param name="exportWebServiceID">Exportwebservice id</param>
        /// <param name="tableNameorQuery">Process table with data to push to web service</param>
        /// <param name="exportFileFullPath">Export file parh</param>
        /// <param name="processID">Process Id</param>
        /// <param name="outmsg">returns success or failed message in case of exception</param>
        public static void PostDataToWebService(int exportWebServiceID, string tableNameorQuery, string exportFileFullPath, string processID, out string outmsg)
        {
            outmsg = "Failed";
            ExportStatus exportStatus = new ExportStatus();
            try
            {
                //using (SqlConnection cn = new SqlConnection(@"Data Source=SG-D-SQL01.farrms.us,2033;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    SqlCommand cmd = new SqlCommand("spa_export_web_service", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@flag", "s"));
                    cmd.Parameters.Add(new SqlParameter("@id", exportWebServiceID));

                    ExportWebServiceInfo webserviceExportInfo = new ExportWebServiceInfo();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows)
                        {
                            reader.Read();
                            webserviceExportInfo = new ExportWebServiceInfo()
                            {
                                webServiceURL = reader["web_service_url"].ToString(),
                                authToken = reader["auth_token"].ToString(),
                                handlerClassName = reader["handler_class_name"].ToString(),
                                Connection = cn,
                                userName = reader["user_name"].ToString(),
                                requestParam = reader["request_param"].ToString(),
                                authUrl = reader["auth_url"].ToString(),
                                password = reader["password"].ToString()
                            };
                        }
                    }
                    //resolve correct data dispatcher class
                    IWebServiceDataDispatcher webServiceDataDispatcher = WebServiceDataDispatcherFactory.GetWebServiceDispatcher(webserviceExportInfo);
                    exportStatus = webServiceDataDispatcher.DispatchData(webserviceExportInfo, tableNameorQuery, exportFileFullPath, processID);
                    outmsg = exportStatus.Status;
                    cn.Close();
                }

            }
            catch (Exception ex)
            {
                outmsg = "Failed";
                exportStatus.Exception.LogError("IWebServiceDataDispatcher", exportStatus.ResponseMessage);
                ex.LogError("Create Web Request", ex.Message);
            }
        }

        #endregion
    }
}
 
