using Spire.Xls;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;

namespace FARRMSExcelServerCLR
{
    public enum DocumentType
    {
        DocumentGeneration = 106701,
        CalculationEngine = 106702,
        Report = 106700
    }

    public class SnapshotInfo : IDisposable
    {
        //  Collection report filter to be overrien when report query is run
        public SnapshotInfo()
        {
        }

        /// <summary>
        /// Intitalize snapshot process
        /// </summary>
        /// <param name="excelSheetId">Excel sheet id to publish</param>
        /// <param name="synchronizeReport">Run the synchronization process possible values y,n</param>
        /// <param name="imageSnapshot">Generate image snapshot possible values y,n</param>
        /// <param name="userName">Package execution username, This username will be used generat snapshot file name</param>
        /// <param name="settlementCalculation">Settlement calculation based trm contract template setup, possible values y,n</param>
        /// <param name="exportFormat">Export format of worksheet after synchronization process is completed, possible values PDF,HTML</param>
        /// <param name="processId">Unique GUID used through out the sync process</param>
        /// <param name="sqlConnection">Valid opened SqlConnection</param>
        public SnapshotInfo(int excelSheetId, string synchronizeReport, string imageSnapshot, string userName,
            string settlementCalculation, string exportFormat, string processId, SqlConnection sqlConnection)
        {
            SettlementCalculation = settlementCalculation.ToLower() == "y";
            SynchronizeReport = synchronizeReport.ToLower() == "y";
            ImageSnapshot = imageSnapshot.ToLower() == "y";
            UserName = userName;
            ExportFomat = exportFormat;
            if (string.IsNullOrEmpty(processId)) processId = Helper.ProcessId();
            ProcessId = processId;
            ExcelSheetId = excelSheetId;

            //SqlConnection =
            //    new SqlConnection(
            //        @"Data Source=PSDL20\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=sa;password=pioneer");
            //SqlConnection.Open();

            SqlConnection = sqlConnection;

            //  Excel report repository / temp note folder
            using (var cmd = new SqlCommand("spa_excel_snapshots 'c'", SqlConnection))
            {
                using (SqlDataReader rd = cmd.ExecuteReader())
                {
                    if (rd.HasRows)
                        rd.Read();

                    ReportRepository = rd[0].ToString(); //  excel_reports
                    DocumentPath = rd[1].ToString(); //  temp_note
                    LicenseKey = rd[2].ToString();  //  License Key
                }
            }
            LoadLicenseKey();
            //  Create replica of source file in temp note
            ReplicaFileName = DocumentPath.TrimEnd('\\') + "\\" + ProcessId + ".xlsx";

            ExcelSheet = new ExcelSheet(ExcelSheetId) { SqlConnection = SqlConnection }.GetExcelSheet();

            //  Sheet is valid
            if (ExcelSheet != null)
            {
                //  Parse view report filter xml to report filter collection
                ParseViewReportFilterXMl();

                ExcelSheet.SnapshotInfo = this;
                //  Create Replica Of Source File in temp note , this file will be used during whole synchronization process 
                CreateReplicaOfSourceFile();
                //  Override document type, user can change document type from excel add-in manager but it should be determined by sheet design
                ExcelSheet.DocumentType = (DocumentType)GetSheetDocumentType(ExcelSheet.SheetName);
                //  Get report sheets
                GetReports(ExcelSheet.DocumentType);
                //  Get data import
                if (ExcelSheet.DocumentType == DocumentType.CalculationEngine)
                    GetDataImportConfigurations();
            }
        }

        public List<ReportFilter> ViewReportFilters { get; set; }
        public DocumentType DocumentType { get; set; }
        private string SourceFileName { get; set; }
        public string ReplicaFileName { get; set; }
        public List<ReportSheet> ReportSheets { get; set; }
        public List<DataImport> DataImports { get; set; }
        public SqlConnection SqlConnection { get; set; }

        //private Workbook SourceWorkbook { get; set; }
        public Workbook ReplicaWorkbook { get; set; }
        public ExcelSheet ExcelSheet { get; set; }
        public string ReportRepository { get; set; }
        public string DocumentPath { get; set; }
        public string LicenseKey { get; set; }
        //  Parameters
        public int ExcelSheetId { get; set; }
        public bool SynchronizeReport { get; set; }
        public bool SettlementCalculation { get; set; }
        public bool ImageSnapshot { get; set; }
        public string UserName { get; set; }
        public string ExportFomat { get; set; }
        public string ProcessId { get; set; }

        public string AppliedFiltersLabel { get; set; }

        /// <summary>
        /// Load License information, otherwise it will display evaluation information
        /// </summary>
        void LoadLicenseKey()
        {
            try
            {
                Spire.License.LicenseProvider.SetLicenseKey(this.LicenseKey);
                Spire.License.LicenseProvider.LoadLicense();
            }
            catch (Exception)
            {

            }
        }

        private void CreateReplicaOfSourceFile()
        {
            SourceFileName = ExcelSheet.FileName;

            if (File.Exists(ReplicaFileName))
                File.Delete(ReplicaFileName);

            File.Copy(SourceFileName, ReplicaFileName);

            ReplicaWorkbook = new Workbook();
            ReplicaWorkbook.LoadFromFile(ReplicaFileName);

            //SourceWorkbook = new Workbook();
            //SourceWorkbook.LoadFromFile(SourceFileName);
        }

        /// <summary>
        /// get worksheet type based excel configuration 
        /// </summary>
        /// <param name="sheetName">Sheetname</param>
        /// <returns>return DocumentType</returns>
        public int GetSheetDocumentType(string sheetName)
        {
            try
            {
                //  Add logic to determine excel sheet type, Eg. confirmation letter can report but user will marked as document generation to map in contract report template
                //  If document generation is mapped content is cleared before preparing.
                //  Check if excel sheet is report
                Worksheet wsConfig = this.ReplicaWorkbook.GetWorksheet("Configurations");
                if (wsConfig != null)
                {
                    foreach (CellRange row in wsConfig.Rows)
                    {
                        if (row[row.Row, 2].Text.ToLower() == sheetName.ToLower())
                            return 106700;
                    }
                }

                //  Check if sheet is import
                wsConfig = this.ReplicaWorkbook.GetWorksheet("Import Settings");
                if (wsConfig != null)
                {
                    foreach (CellRange row in wsConfig.Rows)
                    {
                        if (row[row.Row, 5].Text.ToLower() == sheetName.ToLower())
                            return 106702;
                    }
                }
                //  Check if invoice template
                wsConfig = this.ReplicaWorkbook.GetWorksheet("Invoice Configuration");
                if (wsConfig != null)
                {
                    foreach (CellRange row in wsConfig.Rows)
                    {
                        if (row[row.Row, 1].Text.ToLower() == sheetName.ToLower())
                        {
                            this.TemplateWorksheet = row[row.Row, 3].Text;
                            return 106701;
                        }

                    }
                }
            }
            catch (Exception)
            {
                return 106700;
            }

            return 106700;
        }
        /// <summary>
        ///     Get List of report sheets used in excel file, this sheets are derived from configuration sheet
        /// </summary>
        private void GetReports(DocumentType documentType)
        {
            ReportSheets = new List<ReportSheet>();
            string reportConfigurationSheet = "Configurations";
            Worksheet sheet =
                ReplicaWorkbook.GetSheets()
                    .FirstOrDefault(x => x.Name.ToString().ToLower() == reportConfigurationSheet.ToLower());
            if (sheet != null)
            {
                foreach (CellRange row in sheet.Rows)
                {
                    //  Skip first row
                    if (row.Row == 1) continue;
                    //  Each row represents one report definition binded with sheets
                    var reportSheet = new ReportSheet(ReplicaWorkbook);

                    for (int i = 0; i < 8; i++)
                    {
                        switch (i)
                        {
                            case 1:
                                reportSheet.ReportName = sheet.Range[row.Row, 1].Text;
                                break;
                            case 2:
                                reportSheet.SheetName = sheet.Range[row.Row, 2].Text;
                                if (documentType == DocumentType.CalculationEngine)
                                    reportSheet.SetReportSheetColumns();
                                break;
                            case 3:
                                reportSheet.SpaRfxQuery = sheet.Range[row.Row, 3].Text;
                                break;
                            case 4:
                                reportSheet.ParameterSheet = sheet.Range[row.Row, 4].Text;
                                break;
                            case 7:
                                reportSheet.ParamsetHash = sheet.Range[row.Row, 7].Text;
                                break;
                            default:
                                break;
                        }
                    }

                    ReportSheets.Add(reportSheet);
                    //  get parameters from _param sheet
                    reportSheet.GetIndividualParameters(this.SqlConnection);
                }
            }
        }

        /// <summary>
        ///     get import configuration saved ImportSettings worksheet
        /// </summary>
        private void GetDataImportConfigurations()
        {
            DataImports = new List<DataImport>();
            const string importConfigurationSheet = "Import Settings";
            Worksheet sheet =
                ReplicaWorkbook.GetSheets()
                    .FirstOrDefault(x => x.Name.ToString().ToLower() == importConfigurationSheet.ToLower());
            if (sheet != null)
            {
                foreach (CellRange row in sheet.Rows)
                {
                    //  Skip first row
                    if (row.Row == 1) continue;
                    //  Each row represents one report definition binded with sheets
                    var di = new DataImport(this) { Rule = new Rule() };

                    for (int i = 1; i < 8; i++)
                    {
                        switch (i)
                        {
                            case 1:
                                di.Rule.Id = sheet.Range[row.Row, 1].Value.ToInt();
                                break;
                            case 2:
                                di.Rule.Name = sheet.Range[row.Row, 2].Value;
                                break;
                            case 4:
                                di.Rule.RuleColumnList = sheet.Range[row.Row, 4].Value.Split(',').ToList();
                                break;
                            case 5:
                                di.ImportSheet = sheet.Range[row.Row, 5].Value;
                                break;
                            case 6:
                                string xmlConfig = sheet.Range[row.Row, 6].Value;
                                if (!string.IsNullOrEmpty(xmlConfig))
                                {
                                    //  Catch invalid xml
                                    try
                                    {
                                        xmlConfig = xmlConfig.Replace("_x000D_", "");
                                        var xmlDoc = new XmlDocument();
                                        xmlDoc.LoadXml(xmlConfig);
                                        XmlNodeList importXml = xmlDoc.GetElementsByTagName("Tablix");
                                        XmlNode xNode = importXml[0];
                                        string datasetSheetName = xNode.Attributes["Name"].Value;


                                        di.Tablix = new Tablix
                                        {
                                            ReportSheetDataset = datasetSheetName,
                                            Columns = new List<Column>()
                                        };

                                        foreach (XmlElement xmlColumn in xNode.ChildNodes)
                                        {
                                            if (xmlColumn.HasAttributes)
                                                di.Tablix.Columns.Add(new Column
                                                {
                                                    Label = xmlColumn.GetAttributeNode("Header").Value,
                                                    Field = xmlColumn.GetAttributeNode("Field").Value
                                                });
                                        }
                                    }
                                    catch (Exception)
                                    {
                                    }
                                }
                                break;
                            case 7:

                                di.Rule.IxpRuleHash = sheet.Range[row.Row, 7].EnvalutedValue;
                                break;
                            default:
                                break;
                        }
                    }

                    if (ReplicaWorkbook.SheetIsValid(di.ImportSheet))
                        DataImports.Add(di);
                }
            }
        }

        public void Synchronize()
        {
            ISnapshot snapshot = ExcelFactory.GetSnapshot(ExcelSheet.DocumentType);
            snapshot.Process(this);
        }


        private void ParseViewReportFilterXMl()
        {
            ViewReportFilters = new List<ReportFilter>();
            try
            {
                using (
                    var cmd =
                        new SqlCommand("SELECT * FROM adiha_process.dbo.excel_add_in_view_report_filter_" + ProcessId,
                            SqlConnection))
                {
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            var rf = new ReportFilter();

                            for (int i = 0; i < rd.FieldCount; i++)
                            {
                                string fieldName = rd.GetName(i);
                                if (fieldName.ToLower() == "name") rf.Name = rd[fieldName].ToString();
                                if (fieldName.ToLower() == "value") rf.Value = rd[fieldName].ToString();
                                if (fieldName.ToLower() == "displaylabel") rf.DisplayLabel = rd[fieldName].ToString();
                                if (fieldName.ToLower() == "displayvalue") rf.DisplayValue = rd[fieldName].ToString();
                                if (fieldName.ToLower() == "overwritetype") rf.OverrideType = rd[fieldName].ToInt();
                                if (fieldName.ToLower() == "adjustmentdays") rf.AdjustmentDays = rd[fieldName].ToInt();
                                if (fieldName.ToLower() == "adjustmenttype")
                                    rf.AdjustmentType = rd[fieldName].ToString();
                                if (fieldName.ToLower() == "businessday") rf.BusinessDay = rd[fieldName].ToString();
                            }

                            if (rf.Value.Trim() == "")
                                rf.Value = "NULL";
                            ViewReportFilters.Add(rf);
                        }
                    }
                }

                AppliedFiltersLabel = "";
                foreach (ReportFilter rf in ViewReportFilters)
                {
                    //  Resolve dynamic date
                    rf.ResolveDynamicDate(SqlConnection);
                    if (string.IsNullOrEmpty(rf.DisplayLabel) && !string.IsNullOrEmpty(rf.Name))
                        rf.DisplayLabel = rf.Name;
                    if (string.IsNullOrEmpty(rf.DisplayValue) && !string.IsNullOrEmpty(rf.Value))
                        rf.DisplayValue = rf.Value;

                    if (!string.IsNullOrEmpty(rf.DisplayLabel) && !string.IsNullOrEmpty(rf.DisplayValue))
                    {
                        AppliedFiltersLabel += rf.DisplayLabel + "=" + rf.DisplayValue + " | ";
                    }
                }
                AppliedFiltersLabel = AppliedFiltersLabel.Trim().TrimEnd('|').Replace("0001-01-01", "");
            }
            catch (Exception)
            {
            }
        }

        public void Dispose()
        {
            GC.Collect();
        }

        public string TemplateWorksheet { get; set; }
    }
}

