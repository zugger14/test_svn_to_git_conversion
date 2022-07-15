using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    class Calculation : SnapshotBase
    {
        private SnapshotInfo _snapshotInfo;

        public override void Process(SnapshotInfo snapshotInfo)
        {
            _snapshotInfo = snapshotInfo;
            foreach (ReportSheet reportSheet in _snapshotInfo.ReportSheets)
            {
                reportSheet.BindData(_snapshotInfo);
            }

            RunProcess();
            _snapshotInfo.ExcelSheet.ShowHideDataTabs(_snapshotInfo.ReplicaWorkbook);
        }

        /// <summary>
        ///     Run excel snapshot process by determining the excel sheet
        /// </summary>
        public void RunProcess()
        {
            if (_snapshotInfo.SqlConnection.State == ConnectionState.Closed)
                _snapshotInfo.SqlConnection.Open();

            //  Check if data import calculation to be performed. if excel sheet is part of data import configuration run data import process
            DataImport dataImport =
                _snapshotInfo.DataImports.FirstOrDefault(x => x.ImportSheet == _snapshotInfo.ExcelSheet.SheetName);
            if (dataImport != null)
            {
                dataImport.Execute();
            }
        }
    }
}
