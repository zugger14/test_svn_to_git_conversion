using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    class ReportGeneration : SnapshotBase
    {
        private SnapshotInfo _snapshotInfo;

        public override void Process(SnapshotInfo snapshotInfo)
        {
            _snapshotInfo = snapshotInfo;
            foreach (ReportSheet reportSheet in _snapshotInfo.ReportSheets)
            {
                reportSheet.BindData(_snapshotInfo);
            }
            //  Update name range data range, if excel file has some name range
            _snapshotInfo.ReplicaWorkbook.UpdateNameRange(_snapshotInfo.ReportSheets);
            _snapshotInfo.ExcelSheet.ShowHideDataTabs(_snapshotInfo.ReplicaWorkbook);
            _snapshotInfo.ReplicaWorkbook.ChangePivotDataSourceCache();
            _snapshotInfo.ReplicaWorkbook.RefreshCharts();
            _snapshotInfo.ReplicaWorkbook.CalculateAllValue();
            //_snapshotInfo.ReplicaWorkbook.Save();
            _snapshotInfo.ExcelSheet.Export(_snapshotInfo.ExportFomat);
        }
    }
}