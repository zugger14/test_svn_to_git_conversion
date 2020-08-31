using Spire.Xls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    public class DataImport
    {
        private readonly SnapshotInfo _snapshotInfo;
        private List<SpreadSheetColumn> _importSpreadSheetColumns;

        public DataImport(SnapshotInfo snapshotInfo)
        {
            _snapshotInfo = snapshotInfo;
        }

        public Rule Rule { get; set; }
        public string ImportSheet { get; set; }
        public virtual Tablix Tablix { get; set; }

        public void Execute()
        {
            if (Plot())
            {
                //  Plot has been completed
                //  Create required process table based on plotted sheet
                string processTable = ImportToProcessTable();
                if (!string.IsNullOrEmpty(processTable)) //  Run rule if process table has been prepared
                {
                    ExecuteImport(processTable);
                    _snapshotInfo.ExcelSheet.Export(_snapshotInfo.ExportFomat);
                }
            }
        }

        private void ExecuteImport(string processTableName)
        {
            //  Check if valid rule id selected in sheet, if excel file from different version is uploaded get rule id from its name
            //  Rule Name is unique always

            int ruleId = Rule.Id;
            if (ruleId != 0) Rule.Id = ruleId;

            string sql = "EXEC sys.sp_set_session_context @key = N'DB_USER', @value = '" + _snapshotInfo.UserName +
                         "';EXEC spa_ixp_rules @flag = 't',@process_id = '" + _snapshotInfo.ProcessId +
                         "',@ixp_rules_id =" +
                         Rule.Id + ",@run_table = '" + processTableName +
                         "',@source = '21400',@run_with_custom_enable = 'n'";
            _snapshotInfo.SqlConnection.ExecuteQuery(sql);
        }

        internal bool Plot()
        {
            try
            {
                ReportSheet datasetSheet =
                    _snapshotInfo.ReportSheets.FirstOrDefault(x => x.SheetName == Tablix.ReportSheetDataset);
                if (datasetSheet != null)
                {
                    Worksheet importSheet = _snapshotInfo.ReplicaWorkbook.GetSheet(ImportSheet);
                    //  get column configuration data sheet to import, column configuration should include formula and sample of 2nd row
                    _importSpreadSheetColumns = _snapshotInfo.ReplicaWorkbook.GetSpreadSheetColumns(ImportSheet);

                    //  Clear data from data import sheet, preserve header row
                    importSheet.ClearRows(deleteHeader: false);

                    //  Data set sheet rows mapped in import sheet
                    CellRange[] rows = _snapshotInfo.ReplicaWorkbook.Worksheets[datasetSheet.SheetName].Rows;

                    //  Total rows in dataset worksheet
                    int totalRows = rows.Count();
                    for (int i = 2; i <= totalRows; i++)
                    {
                        //  Columns
                        for (int j = 0; j < _importSpreadSheetColumns.Count; j++)
                        {
                            CellRange cell = importSheet.Range[i, j + 1];
                            if (Tablix == null) continue;
                            Column column =
                                Tablix.Columns.FirstOrDefault(x => x.Label == _importSpreadSheetColumns[j].Name);
                            if (column != null &&
                                (string.IsNullOrEmpty(_importSpreadSheetColumns[j].Formula) &&
                                 (!string.IsNullOrEmpty(column.Field))))
                            {
                                int sourceColumn = datasetSheet.GetColumnIndex(column.Field);
                                if (sourceColumn != 0)
                                    cell.Text = datasetSheet.Worksheet.Range[i, sourceColumn].Value;
                            }
                            else if (!string.IsNullOrEmpty(_importSpreadSheetColumns[j].Formula))
                            {
                                cell.Formula = _importSpreadSheetColumns[j].Formula;
                            }
                        }
                    }
                    _snapshotInfo.ReplicaWorkbook.Save();
                }
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        /// <summary>
        ///     Dump calculated worksheet to process table
        /// </summary>
        /// <returns>Returns process table or null string if failed</returns>
        private string ImportToProcessTable()
        {
            try
            {
                string processTableName = "[adiha_process].dbo.[excel_calculation_" + _snapshotInfo.ProcessId + "]";
                string createTable = "IF OBJECT_ID('" + processTableName + "') IS NOT NULL DROP TABLE " +
                                     processTableName + " CREATE TABLE " + processTableName + "(";
                createTable = _importSpreadSheetColumns.Aggregate(createTable,
                    (current, col) => current + ("[" + col.Name + "] VARCHAR(1000),"));
                createTable = createTable.TrimEnd(',') + ")";
                using (var cmd = new SqlCommand(createTable, _snapshotInfo.SqlConnection))
                {
                    cmd.ExecuteNonQuery();
                    using (var wb = new Workbook())
                    {
                        wb.LoadFromFile(_snapshotInfo.ReplicaFileName);
                        wb.CalculateAllValue();
                        Worksheet sheet = wb.Worksheets[ImportSheet];
                        DataTable proceDataTable = sheet.ExportDataTable(sheet.Range, true, true);
                        //  Dump data table with sql data adapter
                        proceDataTable.Dump(processTableName, _snapshotInfo.SqlConnection, null);
                    }
                }
                return processTableName;
            }
            catch (Exception)
            {
                return null;
            }
        }

        private void Run()
        {
        }
    }
}
