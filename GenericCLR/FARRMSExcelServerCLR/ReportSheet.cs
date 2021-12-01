using Spire.Xls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using FARRMSUtilities;

namespace FARRMSExcelServerCLR
{
    public class ReportSheet
    {
        private string myVar;

        public ReportSheet()
        {
        }

        public ReportSheet(Workbook workbook)
        {
            Workbook = workbook;
            this.ReportParameters = new List<ReportParameter>();
        }


        public Workbook Workbook { get; set; }

        public string SheetName
        {
            get { return myVar; }
            set
            {
                myVar = value;
                //SpreadSheetColumns = Workbook.GetSpreadSheetColumns(myVar);
                Worksheet = Workbook.Worksheets[myVar];
            }
        }

        public void SetReportSheetColumns()
        {
            SpreadSheetColumns = Workbook.GetSpreadSheetColumns(myVar);
        }

        public string ReportName { get; set; }
        public string SpaRfxQuery { get; set; }
        public string ParameterSheet { get; set; }
        public string ParamsetHash { get; set; }
        public List<SpreadSheetColumn> SpreadSheetColumns { get; set; }
        public List<ReportParameter> ReportParameters { get; set; }

        public Worksheet Worksheet { get; set; }
        public int ParamsetId { get; private set; }
        public int TablixId { get; private set; }

        public int GetColumnIndex(string columnName)
        {
            SpreadSheetColumn column = SpreadSheetColumns.FirstOrDefault(x => x.Name.ToLower() == columnName.ToLower());
            if (column != null)
                return column.Index;
            return 0;
        }

        /// <summary>
        ///     Bind data to work sheet if it is part of report manager report
        /// </summary>
        /// <param name="snapshotInfo">SnapshotInfo</param>
        internal void BindData(SnapshotInfo snapshotInfo)
        {
            Worksheet sheet =
                snapshotInfo.ReplicaWorkbook.GetSheets()
                    .FirstOrDefault(x => x.Name.ToString().ToLower() == SheetName.ToLower());
            if (sheet != null)
            {
                string spaRfxQuery = OverRideViewFilter(snapshotInfo);
                //  Clear content from worksheet
                snapshotInfo.ReplicaWorkbook.Clear(SheetName);
                try
                {
                    using (var cmd = new SqlCommand(spaRfxQuery, snapshotInfo.SqlConnection))
                    {
                        cmd.CommandTimeout = 36000;     //  Timeout to 10 Hours
                        using (SqlDataReader rd = cmd.ExecuteReader())
                        {
                            var dataTable = new DataTable();
                            dataTable.Load(rd);
                            sheet.InsertDataTable(dataTable, true, 1, 1);
                        }
                    }
                }
                catch (Exception e)
                {
                    e.LogError("Bind data", null);
                }
            }
        }



        /// <summary>
        /// Override report filter
        /// </summary>
        /// <param name="snapshotInfo">SnapshotInfo</param>
        /// <returns></returns>
        private string OverRideViewFilter(SnapshotInfo snapshotInfo)
        {
            //  Get default paramset id & tablix id this will be used while building spa rfx query
            //  it will reterive always valid paramset id based on hash
            //  it will help to work report from different environment as well
            using (var cmd = new SqlCommand("[spa_excel_snapshots] @flag = 'z', @paramset_hash = '" + this.ParamsetHash + "'", snapshotInfo.SqlConnection))
            {
                using (var rd1 = cmd.ExecuteReader())
                {
                    rd1.Read();
                    this.ParamsetId = rd1[0].ToInt();
                    this.TablixId = rd1[1].ToInt();
                }
            }
            string reportSpaRfxQuery = "";
            string[] allParameters = SpaRfxQuery.Split(',');

            //  Browse parameters to match rfx parameters
            foreach (string s in allParameters)
            {
                //  detect parameter
                if (s.Contains("="))
                {
                    //  if parameter starts/ends with single quote then replace it
                    string pName = s.Split('=').First().TrimStart('\'').TrimEnd('\'');
                    if (snapshotInfo.ViewReportFilters != null)
                    {
                        ReportFilter reportFilter = snapshotInfo.ViewReportFilters.FirstOrDefault(x => x.Name == pName);
                        //  Get individual parameters from _param sheet, used while overriding calculation  
                        var reportParam = this.ReportParameters.Where(x => x.Name == pName).FirstOrDefault();
                        //  override it from 
                        if (reportFilter != null)
                            if (reportParam != null && reportParam.Enabled && reportFilter.Value.ToUpper() == "NULL")
                                reportSpaRfxQuery += reportFilter.Name + "=" + reportParam.Value + ",";
                            else
                                reportSpaRfxQuery += reportFilter.Name + "=" + reportFilter.Value + ",";
                        else
                        {
                            //  when report filter is not passed set it as null , there might be default value when preparing report from excel addin
                            if (!string.IsNullOrEmpty(s.Substring(0, s.LastIndexOf('='))))
                                reportSpaRfxQuery += s.Substring(0, s.LastIndexOf('=')).TrimStart('\'') + "=NULL" + ",";
                            else
                                reportSpaRfxQuery += s + ",";
                        }
                    }
                    else
                    {
                        reportSpaRfxQuery += s + ",";
                    }
                }
            }
            reportSpaRfxQuery = "spa_rfx_run_sql " + this.ParamsetId + "," + this.TablixId + ",'" + reportSpaRfxQuery.TrimEnd(',') + "',NULL,'t'";

            return reportSpaRfxQuery;
        }
        /// <summary>
        /// Get report parameters set in individual report filter
        /// </summary>
        internal void GetIndividualParameters(SqlConnection sqlConnection)
        {
            Worksheet _paramSheet = this.Workbook.Worksheets[this.SheetName + "_Param"];
            if (_paramSheet != null)
            {
                foreach (CellRange row in _paramSheet.Rows)
                {
                    //  Skip first row
                    if (row.Row < 3) continue;
                    //  Each row represents one report definition binded with sheets
                    var reportParameter = new ReportParameter();
                    //  skip invalid rows
                    if (string.IsNullOrEmpty(_paramSheet.Range[row.Row, 1].Value)) continue;

                    reportParameter.Name = _paramSheet.Range[row.Row, 2].Value;
                    reportParameter.Value = _paramSheet.Range[row.Row, 3].Value.Replace(",", "!");
                    reportParameter.Label = _paramSheet.Range[row.Row, 4].Value;
                    reportParameter.WidgetName = _paramSheet.Range[row.Row, 7].Value;
                    reportParameter.Enabled = _paramSheet.Range[row.Row, 8].Value.ToBool();
                    reportParameter.EvaluateDateValue(sqlConnection);
                    this.ReportParameters.Add(reportParameter);

                }
            }
        }
    }

    public class SpreadSheetColumn
    {
        public SpreadSheetColumn()
        {
        }

        public SpreadSheetColumn(CellRange cell)
        {
            Index = cell.Column;
            Name = cell[cell.Row, cell.Column].Text;
            Reference = cell.RangeAddressLocal;
            Formula = cell.Formula;
        }

        public int Index { get; set; }
        public string Name { get; set; }
        public string Reference { get; set; }
        public string Formula { get; set; }
    }
}
