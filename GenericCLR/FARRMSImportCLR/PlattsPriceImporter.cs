using FAARMSFileTransferService;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using FARRMSUtilities;

namespace FARRMSImportCLR
{
    internal class PlattsPriceImporter : ICLRImporter
    {
        public List<DownloadedFile> DownloadedFiles { get; set; }
        public CLRImportInfo ClrImportInfo { get; set; }
        public string RemoteDirectory { get; set; }
        public string ProcessTable { get; set; }
        public SqlConnection SqlConnection { get; set; }
        public RuleSetting RuleSetting { get; set; }

        #region CLR Import
        /// <summary>
        /// Import Data From Platts SFTP Based on import configuration
        /// </summary>
        /// <param name="clrImportInfo">CLRImportInfo</param>
        /// <returns></returns>
        public ImportStatus ImportData(CLRImportInfo clrImportInfo)
        {
            this.ClrImportInfo = clrImportInfo;
            this.DownloadedFiles = new List<DownloadedFile>();
            this.ProcessTable = "adiha_process.dbo.platts_import_" + clrImportInfo.ProcessID;
            this.RemoteDirectory = "/" + clrImportInfo.Params[0].paramValue.TrimStart('/').TrimEnd('/') + "/";
            this.SqlConnection = new SqlConnection("Context Connection=true");
            //this.SqlConnection = new SqlConnection(@"Data Source=PSDL20\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=sa;password=pioneer");
            this.SqlConnection.Open();
            //remoteDirectory = "/today/";

            //this.DestinationDirectory = @"E:\temp\";
            ImportStatus importStatus = new ImportStatus();
            try
            {
                DataTable dt = this.CreateProcessTable();

                try
                {

                    DownloadFiles();
                    Import(dt);
                    importStatus.Status = "Success";
                    importStatus.ProcessTableName = this.ProcessTable;
                    importStatus.ResponseMessage = "Data Dumped To Process Table";
                }
                catch (Exception ex)
                {
                    string statusResult = "";
                    //StoredProcedure.ImportFromXml(responseFromServer, "", processTable, "y", out statusResult);
                    importStatus.ProcessTableName = this.ProcessTable;
                    importStatus.Status = (statusResult != "failed") ? "Success" : "Failed";
                    importStatus.ResponseMessage = "Data Dumped To Process Table";
                }
            }

            catch (Exception ex)
            {
                importStatus.ProcessTableName = this.ProcessTable;
                importStatus.Status = "Failed";
                importStatus.Exception = ex;
                importStatus.ResponseMessage = ex.Message;
                ex.LogError("PlattsPriceImporter",
                    clrImportInfo.WebServiceInfo.WebServiceURL + "|" + "|" + this.ProcessTable + "|" + "|" + ex.Message);
            }

            return importStatus;
        }
        #endregion

        #region ProcessTable
        private DataTable CreateProcessTable()
        {
            DataTable dt = new DataTable("plattsData");
            dt.Columns.Add(new DataColumn("flag"));
            dt.Columns.Add(new DataColumn("details"));
            dt.Columns.Add(new DataColumn("Maturity Date"));

            dt.Columns.Add(new DataColumn("Curve Value"));
            dt.Columns.Add(new DataColumn("Bid Value"));
            dt.Columns.Add(new DataColumn("Ask Value"));
            

            dt.Columns.Add(new DataColumn("Curve ID"));
            dt.Columns.Add(new DataColumn("Source Curve Name"));
            dt.Columns.Add(new DataColumn("IS DST"));
            dt.Columns.Add(new DataColumn("Hour"));
            dt.Columns.Add(new DataColumn("Minute"));
            dt.Columns.Add(new DataColumn("As of Date"));

            string createTableSql = "IF OBJECT_ID('" + this.ProcessTable + "') IS NOT NULL DROP TABLE " +
                                    this.ProcessTable;

            Utility.ExecuteQuery(createTableSql, this.SqlConnection);

            createTableSql = "CREATE TABLE " + this.ProcessTable + "(";

            for (int i = 0; i < dt.Columns.Count; i++)
            {
                createTableSql += "[" + dt.Columns[i].ColumnName + "] NVARCHAR(1024),";
            }
            createTableSql = createTableSql.TrimEnd(',') + ")";
            Utility.ExecuteQuery(createTableSql, this.SqlConnection);

            return dt;
        }
        #endregion

        #region Downloads Files
        /// <summary>
        /// Downloads Files from sftp settings, sftp settings are derived from ixp import data source
        /// </summary>
        private void DownloadFiles()
        {
            GetFtpConfiguration();
            this.CreateLoggingDirectories();
            FileTransferEndpoint fte = new FileTransferEndpoint();
            fte.GetEndPointConfiguration(fileTransferEndpointId: this.RuleSetting.FileTransferEndpointId, targetRemoteDirectory: this.RemoteDirectory, this.SqlConnection);
            using (FileTransferService fts = new FileTransferService(fileTransferEndpoint: fte))
            {
                string[] files = fts.ListFiles(returnFileOnly:true);
                foreach (string sftpFile in files)
                {
                    string localFileName = DateTime.Today.ToString("yyyyMMdd_") + Guid.NewGuid().ToString().ToUpper().Replace("-", "_") + "." + sftpFile;
                    fts.Download(this.RuleSetting.DownloadDir, sftpFile, fileExtension: null);
                    //  Rename file
                    File.Move(sourceFileName:this.RuleSetting.DownloadDir + "\\" + sftpFile, destFileName: this.RuleSetting.DownloadDir + "\\" + localFileName);
                    this.DownloadedFiles.Add(new DownloadedFile() { FullFileName = this.RuleSetting.DownloadDir + localFileName, FileName = localFileName, Processed = false });
                }
            }

        }
        #endregion

        #region SFTP configuration
        /// <summary>
        /// Get SFTP configuration from ixp import data source
        /// </summary>
        /// <returns></returns>
        void GetFtpConfiguration()
        {
            this.RuleSetting = new RuleSetting();
            string sql =
                "select folder_location , file_transfer_endpoint_id from ixp_import_data_source where rules_id =" +
                this.ClrImportInfo.RuleID;

            using (SqlCommand cmd = new SqlCommand(sql, this.SqlConnection))
            {
                using (SqlDataReader rd = cmd.ExecuteReader())
                {
                    rd.Read();
                    this.RuleSetting = new RuleSetting()
                    {
                        DataSourceLocation = rd["folder_location"].ToString(),
                        FileTransferEndpointId = rd["file_transfer_endpoint_id"].ToInt()
                    };
                    this.RuleSetting.DataSourceLocation = this.RuleSetting.DataSourceLocation.TrimEnd('\\').TrimEnd('/') + "\\";
                }
            }
            //  Downloads
            this.RuleSetting.DownloadDir = this.RuleSetting.DataSourceLocation;
            //  Error
            this.RuleSetting.ErrorDir = this.RuleSetting.DataSourceLocation + "\\Error\\";
            //  Processed
            this.RuleSetting.ProcessedDir = this.RuleSetting.DataSourceLocation + "\\Processed\\";
        }

        /// <summary>
        /// Creates required directory folder for downloaded / processed / error files under import rule Folder Location
        /// </summary>
        /// <param name="ftpSetting">FtpSetting</param>
        void CreateLoggingDirectories()
        {
            //  Create primary data folder where error / processed / downloded files will stored
            if (!Directory.Exists(this.RuleSetting.DataSourceLocation))
                Directory.CreateDirectory(this.RuleSetting.DataSourceLocation);

            //  Downloaded files
            //  {dataSourceLocation}\Files
            if (!Directory.Exists(this.RuleSetting.DownloadDir))
                Directory.CreateDirectory(this.RuleSetting.DownloadDir);

            //  Processed folder
            //  {dataSourceLocation}\Processed
            if (!Directory.Exists(this.RuleSetting.ProcessedDir))
                Directory.CreateDirectory(this.RuleSetting.ProcessedDir);

            //  Error folder
            //  {dataSourceLocation}\Error
            if (!Directory.Exists(this.RuleSetting.ErrorDir))
                Directory.CreateDirectory(this.RuleSetting.ErrorDir);
        }

        void MoveFiles()
        {
            foreach (DownloadedFile downloadedFile in this.DownloadedFiles)
            {
                if (downloadedFile.Processed)
                    File.Move(downloadedFile.FullFileName, this.RuleSetting.ProcessedDir + downloadedFile.FileName);
                else
                    File.Move(downloadedFile.FullFileName, this.RuleSetting.ErrorDir + downloadedFile.FileName);
            }
        }

        #endregion

        #region Import / Dump / Transform data to process table
        /// <summary>
        /// Import / Dump / Transform data to process table required for price curve data import structure
        /// </summary>
        /// <param name="dt"></param>
        private void Import(DataTable dt)
        {
            MonthIndex monthIndex = new MonthIndex();
            string asofDate = DateTime.Today.ToString("yyyy-MM-dd");
            foreach (DownloadedFile downloadedFile in this.DownloadedFiles)
            {
                try
                {
                    using (StreamReader streamReader = new StreamReader(downloadedFile.FullFileName))
                    {
                        int index = 1;
                        string line;
                        while ((line = streamReader.ReadLine()) != null)
                        {

                            string[] arr = line.Split(' ');
                            if (arr.Count() > 8)
                                asofDate = arr.LastOrDefault().Substring(0, 4) + "-" + arr.LastOrDefault().Substring(4, 2) +
                                           "-" + arr.LastOrDefault().Substring(6, 2);
                            if (arr.Count() == 4)
                            {
                                arr[1] += "/" + monthIndex.GetMaturityYear(arr[1]);
                                dt.Rows.Add(arr);
                            }
                            index++;
                        }

                        using (
                            SqlDataAdapter adapter = new SqlDataAdapter("SELECT * from " + this.ProcessTable,
                                this.SqlConnection))
                        {
                            using (SqlCommandBuilder builder = new SqlCommandBuilder(adapter))
                            {
                                builder.GetInsertCommand();
                                adapter.Update(dt);
                            }

                        }
                        downloadedFile.Processed = true;
                    }
                }
                catch (Exception ex)
                {
                    ex.LogError("PlattsPriceImporter - Import", "");
                }
            }
            this.Update(asofDate);
            this.MoveFiles();
        }
        #endregion

        #region Transform extracted data
        /// <summary>
        /// Transform extracted data
        /// </summary>
        /// <param name="asofDate"></param>
        private void Update(string asofDate)
        {
            //  Delete invalid curve data
            string sql = "DELETE d FROM " + this.ProcessTable + " d " +
                         "LEFT JOIN source_price_curve_def s ON LEFT(d.details, 4) = s.curve_id " +
                         "WHERE s.curve_id IS NULL";
            this.SqlConnection.ExecuteQuery(sql);

            // Added logic to resolve as of date
            sql = @"UPDATE d 
                        SET  d.[As of Date] = LEFT(STUFF(STUFF(d.[Maturity Date],7,0,'-'),5,0,'-'),10)
                               " +
                        "FROM   " + this.ProcessTable + " d " +
                        "INNER JOIN source_price_curve_def s ON LEFT(d.details, 4) = s.curve_id " + Environment.NewLine;
            this.SqlConnection.ExecuteQuery(sql);

            sql = @"UPDATE d 
                        SET    d.[Source Curve Name] = 'MASTER', 
                                d.[Curve ID] =  LEFT(d.details, 4),
                                d.[Maturity Date] =  SUBSTRING(details,CHARINDEX('/',details) + 1,LEN(details)), 
                                d.[IS DST] = 0 " +
                         "FROM   " + this.ProcessTable + " d " +
                         "INNER JOIN source_price_curve_def s ON LEFT(d.details, 4) = s.curve_id " + Environment.NewLine;
            this.SqlConnection.ExecuteQuery(sql);

            //  Remove unused columns from process table
            sql += "ALTER TABLE " + this.ProcessTable + " drop column [flag], [details]";
            this.SqlConnection.ExecuteQuery(sql);

        }
        #endregion

        #region Monthindex
        /// <summary>
        /// Monthindex
        /// </summary>
        private class MonthIndex
        {
            public List<Month> Months { get; set; }

            public MonthIndex()
            {
                this.Months = new List<Month>();
                string[] keys = "A,B,C,D,E,F,G,H,I,J,K,L".Split(',');
                int index = 1;
                foreach (string key in keys)
                {
                    this.Months.Add(new Month() {Index = index.ToString("D2"), Key = key});
                    index++;
                }
            }
            /// <summary>
            /// Parse maturity year data from raw details Eg : NCRMA20u => Curve : Month 
            /// </summary>
            /// <param name="detailsData"></param>
            /// <returns></returns>
            public string GetMaturityYear(string detailsData)
            {
                string key = detailsData.Substring(4, 1);
                string maturity = "20" + detailsData.Substring(5, 2) + "-" +
                                  this.Months.FirstOrDefault(x => x.Key == key).Index + "-01";
                return maturity;
            }

        }

        
        #endregion
    }

    struct Month
    {
        public string Index { get; set; }
        public string Key { get; set; }
    }

    public class RuleSetting
    {
        public string DataSourceLocation { get; set; }
        public int FileTransferEndpointId { get; set; }
        //  File Locations
        public string DownloadDir { get; set; }
        public string ErrorDir { get; set; }
        public string ProcessedDir { get; set; }
    }

    public class DownloadedFile
    {
        public string FullFileName { get; set; }
        public string FileName { get; set; }
        public bool Processed { get; set; }
    }
}
