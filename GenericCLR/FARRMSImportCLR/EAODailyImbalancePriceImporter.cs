using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Data.SqlClient;
using FARRMSUtilities;

namespace FARRMSImportCLR
{
    /// <summary>
    /// EAODailyImbalancePriceImporter contains method to import price from web service 
    /// </summary>
    class EAODailyImbalancePriceImporter : CLRWebImporterBase
    {

        public override ImportStatus ImportData(CLRImportInfo clrImportInfo)
        {
            DateTime downloadDate = Convert.ToDateTime(clrImportInfo.Params[0].paramValue);
            string month;
            string year;            
            string documentPath = "";
            string dataSourceAlias = "";

            month = downloadDate.Month.ToString();
            year = downloadDate.Year.ToString();

            clrImportInfo.WebServiceInfo.WebServiceURL += "&theFilterMonth=" + month + "&theFilterYear=" +  year;

            using (SqlConnection cn = new SqlConnection("Context Connection=true"))
            //using (SqlConnection cn = new SqlConnection("Data Source=PSDL17\\INSTANCE2016;Initial Catalog=TRMTracker_MMWEC;Persist Security Info=True;User ID=sa;password=pioneer"))
            {
                cn.Open();

                SqlDataReader rd = cn.ExecuteStoredProcedureWithReturn("spa_ixp_import_data_source", "flag:x,rules_id:" + clrImportInfo.RuleID.ToString());
                if (rd != null)
                {
                    dataSourceAlias = rd[0].ToString();
                    documentPath = rd[1].ToString();

                    rd.Close();
                }
                
                string processTable = "adiha_process.dbo.temp_import_data_table_" + dataSourceAlias + "_" + clrImportInfo.ProcessID;
                string downloadedFileName = "Daily Imbalance " + year + "_" + month + ".csv";

                ImportStatus fileDownloadStatus = base.WebFileDownload(clrImportInfo.WebServiceInfo, documentPath, downloadedFileName);

                if (fileDownloadStatus.Status == "Fail") 
                {
                    if (cn != null && cn.State == System.Data.ConnectionState.Open)
                        cn.Close();

                    throw fileDownloadStatus.Exception;
                } else 
                {
                    fileDownloadStatus.ProcessTableName = processTable;

                    cn.ExecuteStoredProcedure("spa_ixp_insert_data",
                                            "file_path:" + documentPath +
                                            ",file_name:" + downloadedFileName +
                                            ",temp_process_table:" + processTable +
                                            ",header:n,row_terminator:0x0A"
                                            );
                    cn.Close();
                }
                return fileDownloadStatus;             
            }
            
        }
    }
}
