using System;
using System.Data.SqlClient;
using FARRMSUtilities;

namespace FARRMSExcelServerCLR
{
    public class StoredProcedure
    {
        [Microsoft.SqlServer.Server.SqlProcedure]

        /// <summary>
        /// Synchronize excel add-in report / data import / document generation
        /// </summary>
        /// <param name="excelSheetId">Published excel sheet id</param>
        /// <param name="userName">user name</param>
        /// <param name="settlementCalc">run settlement calc y/n</param>
        /// <param name="exportFormat">export format eg. PNG, PDF, HTML, EXCEL</param>
        /// <param name="processId">Unique process id</param>
        /// <param name="outputResult">output result</param>
        public static void SynchronizeExcelWithSpire(string excelSheetId, string userName, string exportFormat, string processId, out string outputResult)
        {
            try
            {
                //using (SqlConnection sqlConnection = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT_Mkt_Merge;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                //using (var sqlConnection = new SqlConnection(@"Data Source=CTRMSGDB-D5003.ctrmdevwin.hasops.com,2033;Initial Catalog=TRMTracker_Release;User ID=dev_admin;password=Admin2929"))
                using (var sqlConnection = new SqlConnection("Context Connection=True"))
                {
                    var excelDocument = new DocumentTemplate() { ExcelSheetId = excelSheetId.ToInt(), ExportFormat = exportFormat, ProcessId = processId, UserName = userName};
                    sqlConnection.Open();
                    using (var snapshotInfo = new SnapshotInfo(sqlConnection, excelDocument))
                    {
                        snapshotInfo.Synchronize();
                        snapshotInfo.ReplicaWorkbook.Save();

                    }
                    sqlConnection.Close();
                    outputResult = "success";
                }
            }
            catch (Exception ex)
            {
                outputResult = ex.Message;
                ex.LogError("SynchronizeExcelWithSpire", excelSheetId + "|" + userName + "|" +  exportFormat + "|" + processId);
            }
        }

        [Microsoft.SqlServer.Server.SqlProcedure]
        public static void BulkDocumentGeneration(string batchProcessId)
        {
            try
            {
                var process = new BulkDocumentGeneration(batchProcessId);
                process.RunProcesss();
            }
            catch (Exception ex)
            {
                ex.LogError("BulkExcelDocumentGeneration", "");
            }
        }
    }
}

