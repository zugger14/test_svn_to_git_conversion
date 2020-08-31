using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
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
        /// <param name="synchronize">Synchronize y/n</param>
        /// <param name="imageSnapshot">Generate image snapshot y/n</param>
        /// <param name="userName">user name</param>
        /// <param name="settlementCalc">run settlement calc y/n</param>
        /// <param name="exportFormat">export format eg. PNG, PDF, HTML, EXCEL</param>
        /// <param name="processId">Unique process id</param>
        /// <param name="outputResult">output result</param>
        public static void SynchronizeExcelWithSpire(string excelSheetId, string synchronize, string imageSnapshot, string userName, string settlementCalc, string exportFormat, string processId, out string outputResult)
        {
            try
            {
                //using (SqlConnection sqlConnection = new SqlConnection(@"Data Source=PSDL20\INSTANCE2016;Initial Catalog=TRMTracker_DEV;Persist Security Info=True;User ID=sa;password=pioneer"))
                using (var sqlConnection = new SqlConnection("Context Connection=True"))
                {
                    sqlConnection.Open();
                    using (
                        var snapshotInfo = new SnapshotInfo(excelSheetId.ToInt(), synchronize, imageSnapshot,
                            userName, settlementCalc, exportFormat, processId, sqlConnection))
                    {
                        snapshotInfo.Synchronize();

                    }
                    outputResult = "success";
                }
            }
            catch (Exception ex)
            {
                outputResult = ex.Message;
                ex.LogError("SynchronizeExcelWithSpire", excelSheetId + "|" + synchronize + "|" + imageSnapshot + "|" + userName + "|" + settlementCalc + "|" + exportFormat + "|" + processId);
            }
        }
    }
}

