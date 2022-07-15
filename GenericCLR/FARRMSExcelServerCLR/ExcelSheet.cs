using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using Spire.Xls;
using Spire.Xls.Core.Spreadsheet;

namespace FARRMSExcelServerCLR
{
    public class ExcelSheet
    {
        private string _exportFileName;

        public ExcelSheet()
        {
        }

        public ExcelSheet(int excelSheetId)
        {
            Id = excelSheetId;
        }

        public SnapshotInfo SnapshotInfo { get; set; }

        public int Id { get; set; }
        public string FileName { get; set; }
        public string SheetName { get; set; }
        public bool Publish { get; set; }
        public bool MaintainHistory { get; set; }
        public DocumentType DocumentType { get; set; }
        public bool ShowDataTabs { get; set; }

        public SqlConnection SqlConnection { get; set; }

        /// <summary>
        ///     Get Excel sheet definition
        /// </summary>
        /// <returns></returns>
        public ExcelSheet GetExcelSheet()
        {
            using (var cmd = new SqlCommand("spa_excel_snapshots @flag='e',@sheet_id='" + Id + "'", SqlConnection))
            {
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    reader.Read();
                    var sheet = new ExcelSheet
                    {
                        Id = reader["Id"].ToInt(),
                        FileName = reader["FileName"].ToString(),
                        SheetName = reader["SheetName"].ToString(),
                        Publish = reader["Publish"].ToBool(),
                        MaintainHistory = reader["MaintainHistory"].ToBool(),
                        DocumentType = (DocumentType)reader["DocumentType"].ToInt(),
                        ShowDataTabs = reader["ShowDataTabs"].ToBool(),
                    };
                    return sheet;
                }
            }
        }

        /// <summary>
        ///     Export Excel sheet to different format Eg. PNG, PDF
        /// </summary>
        /// <param name="exportFormat">PNG, PDF</param>
        public void Export(string exportFormat)
        {
            var fi = new FileInfo(SnapshotInfo.ReplicaFileName);
            //_exportFileName = fi.DirectoryName + "\\" + SheetName + "_" + SnapshotInfo.UserName + "_" +
            //                  DateTime.Now.ToString("yyyyMMdd_HHmmssff") + "." + exportFormat.ToLower();
            _exportFileName = fi.DirectoryName + "\\" + SheetName + "_" + SnapshotInfo.UserName + "_" +
                              SnapshotInfo.ProcessId + "." + exportFormat.ToLower();
            this.SnapshotInfo.DocumentTemplate.ExportFileName = _exportFileName;
            //  Find and replace signature if excel sheet is defined as document generation.
            if (this.DocumentType == DocumentType.DocumentGeneration)
                FindAndReplaceSignatureImage();

            switch (exportFormat.ToLower())
            {
                case "pdf":
                    ExportToPdf();
                    break;
                case "html":
                    ExportToHtml();
                    break;
                case "png":
                    ExportToPng();
                    break;
                default:
                    break;
            }
            //  Save log
            SaveSnapshotHistoryLog();
        }

        /// <summary>
        /// Finds signature placeholder, replace with singnature image based on its referenced cell. Placeholder Eg. <Signature:Sheet1!A1>, If singnature image is not found it will clear the placeholder contents.
        /// </summary>
        private void FindAndReplaceSignatureImage()
        {


            try
            {
                Worksheet worksheet = this.SnapshotInfo.ReplicaWorkbook.Worksheets[SheetName];

                CellRange[] ranges = worksheet.FindAllString("<Signature:", false, false);
                //Traverse the found ranges
                foreach (CellRange range in ranges)
                {
                    string placeHolderFormula = range.Text.Split(':')[1].Replace(">", "");
                    Worksheet extWorksheet = this.SnapshotInfo.ReplicaWorkbook.Worksheets[placeHolderFormula.Split('!')[0]];
                    var signatureUser = extWorksheet.Range[placeHolderFormula.Split('!')[1]];
                    //  Get image file for this reference cell (reffered to user)
                    string signatureFileName = GetUserSignature(signatureUser.Text);
                    //Replace it with empty
                    range.Text = "";
                    if (!string.IsNullOrEmpty(signatureFileName))
                    {
                        Image image = Image.FromFile(signatureFileName);
                        worksheet.Pictures.Add(range.Row, range.Column, image);
                    }
                }
            }
            catch (Exception)
            {

            }
        }
        /// <summary>
        /// Reterives an user signature filename based on referenced cell value (containing username)
        /// </summary>
        /// <returns>Image filename</returns>
        private string GetUserSignature(string userName)
        {
            try
            {
                if (!string.IsNullOrEmpty(this.SnapshotInfo.UserName))
                {
                    using (var cmd = new SqlCommand("spa_excel_snapshots @flag='y',@user_name='" + userName + "'", this.SnapshotInfo.SqlConnection))
                    {
                        using (var rd = cmd.ExecuteReader())
                        {
                            while (rd.Read())
                                return rd[0].ToString();
                        }
                    }
                }
                return null;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        /// <summary>
        ///     Export worksheet to pdf
        /// </summary>
        private void ExportToPdf()
        {
            Worksheet sheet = SnapshotInfo.ReplicaWorkbook.Worksheets[SheetName];
            sheet.SaveToPdf(_exportFileName);
            //PublishExcelFile(SnapshotInfo.ReplicaWorkbook);
        }

        /// <summary>
        /// Export worksheet to PNG image
        /// </summary>
        private void ExportToPng()
        {
            Worksheet sheet = SnapshotInfo.ReplicaWorkbook.Worksheets[SheetName];
            sheet.SaveToImage(_exportFileName);
            //PublishExcelFile(SnapshotInfo.ReplicaWorkbook);
        }

        /// <summary>
        ///     Export worksheet to html output, embeded images are placed in folder
        /// </summary>
        private void ExportToHtml()
        {
            using (var wb = new Workbook())
            {
                wb.LoadFromFile(SnapshotInfo.ReplicaFileName);
                //  if we do not calculate cell values with formula export to html will failed.
                wb.CalculateAllValue();
                Worksheet sheet = wb.Worksheets[SheetName];
                var options = new HTMLOptions { ImageEmbedded = true };
                sheet.SaveToHtml(_exportFileName);
                //PublishExcelFile(wb);
            }
        }

        /// <summary>
        ///     Replicat Excel workbook, all the tabs (sheet) will be strongly hidden except published tab
        /// </summary>
        /// <param name="workbook"></param>
        public void ShowHideDataTabs(Workbook workbook)
        {
            foreach (Worksheet ws in workbook.Worksheets)
            {
                //  Hide other worksheet except publish tab
                if (ws.Name != SheetName && !ShowDataTabs)
                    ws.Visibility = WorksheetVisibility.StrongHidden;
            }
        }

        /// <summary>
        ///     Save published excel sheet snapshot history to Table
        /// </summary>
        private void SaveSnapshotHistoryLog()
        {
            string sheetFileName = Path.GetFileName(_exportFileName);
            string sql = "spa_excel_snapshots @flag='h',@sheet_id='" + Id + "' ,@snapshot_sheet_name='" +
                         SheetName + "', @snapshot_filename='" + sheetFileName + "', @applied_filter='" +
                         SnapshotInfo.AppliedFiltersLabel + "', @refreshed_on='" +
                         DateTime.Now.ToString("yyyy MMMM dd HH:mm:ss") + "',@process_id='" +
                         SnapshotInfo.ProcessId + "'";

            SnapshotInfo.SqlConnection.ExecuteQuery(sql);
        }
    }
}
