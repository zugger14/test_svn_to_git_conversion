using FARRMSGenericCLR;
using FARRMSUtilities;
using FAARMSFileTransferCLR;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            string msg = "";
            string s;
            FAARMSFileTransferCLR.StoredProcedure.TestEndpointConnection(27, out s);
            //FAARMSFileTransferCLR.StoredProcedure.ListFtpContents(26, null, out s);
            //FARRMSExcelServerCLR.StoredProcedure.SynchronizeExcelWithSpire("2294", "y", "y", "farrms_admin", "n", "PDF", "EFD4A339_8F7F_485C_935C_C646FF17DAE8", out s);
            //FARRMSExcelServerCLR.StoredProcedure.SynchronizeExcelWithSpire("2294", "y", "y", "farrms_admin", "n", "pdf", "EFD4A339_8F7F_485C_935C_C646FF17DAE8", out s);
            //FARRMSGenericCLR.StoredProcedure.CreateFolder(@"\\PSDL20\shared_docs_TRMTracker_Release\temp_Note\Import\Trader\Error\", out s);
            //FARRMSGenericCLR.StoredProcedure.MoveFileToFolder(@"D:\Temp\test\surya.txt", @"D:\temp\Error\", out s);
            //StoredProcedure.ExecuteSSISPackage("", "", "", "13", 64, "n", out msg);
            //StoredProcedure.GenerateDocFromRDL(@"http://psdb2016/ReportServer_INSTANCE2016","USER","U$er","DPCS", "FASTracker_Master_RWE_DE/Book Mapping Report_Book Mapping Report", "paramset_id:15138,ITEM_BookMappingReport_tablix:15420,report_filter:'',is_refresh:0,report_region:en-US,runtime_user:snakarmi,global_currency_format:$,global_date_format:dd.M.yyyy,global_thousand_format:,#,global_rounding_format:#0.00,global_science_rounding_format:2,global_negative_mark_format:1,is_html:n","CSV", @"\\APP03\shared_docs_FASTracker_Master_RWE_DE\temp_Note\16.csv",",","y","41241", out msg );
            //StoredProcedure.ImportWithCLRRule(@"<Root><PSRecordset paramName=""PS_StartDate"" paramValue =""today""/></Root>", 12879, "3423423423423");
            #region FILE TRANSFER TEST CASES, DO NOT DELETE 
            //string localSourceFiles = @"D:\Temp\Sample _ImportFile.xlsx,D:\Temp\Import Using Excel Addin.xlsx";
            //string specifiedFilesOnly = @"Import Using Excel Addin.xlsx,Sample _ImportFile.xlsx";
            //const int FTP_WITH_OUT_REMOTE_DIRECTORY = 1;
            //const int FTP_WITH_REMOTE_DIRECTORY = 5;

            //const int SFTP_WITH_OUT_REMOTE_DIRECTORY = 3;
            //const int SFTP_WITH_REMOTE_DIRECTORY = 10;

            //      1. Upload file to remote directory
            //StoredProcedure.UploadToFtp(5, localSourceFiles, out  s);

            //      2.  Upload file to root directory, remote directory is empty
            //StoredProcedure.UploadToFtp(1, localSourceFiles, out  s);

            //      3.  Downalod ALL File from ftp
            //StoredProcedure.DownloadFromFtp(1, null, @"D:\temp\", null, out s);

            //      4.  Download Spceified from without remote directory
            //StoredProcedure.DownloadFromFtp(1, specifiedFilesOnly, @"D:\temp\", null , out s);

            ////    5.  Download Spceified from remote directory
            //StoredProcedure.DownloadFromFtp(5, specifiedFilesOnly, @"D:\temp\", null, out s);

            //      6.  List Ftp files without remote directory
            //StoredProcedure.ListFtpContents(1, out s);

            //      7.  List FTP files with remote directory
            //StoredProcedure.ListFtpContents(1,null, out s);

            //      8.  Move All FTP Files with out remote directory
            //StoredProcedure.FtpMoveFileToFolder(1, null, "D1/D2/D3", out s);

            //      9.  Move All FTP Files with out remote directory
            //StoredProcedure.FtpMoveFileToFolder(1, specifiedFilesOnly, "D1/D2/D3", out s);

            //      10.  Move Alll FTP Files with remote directory
            //StoredProcedure.FtpMoveFileToFolder(5, null, "D1/D2/D3", out s);

            //      11.  Move specified FTP Files with remote directory
            //StoredProcedure.FtpMoveFileToFolder(5, specifiedFilesOnly, "D1/D2/D3", out s);

            //      12. Delete All files with out remote directory
            //StoredProcedure.FtpDeleteFile(FTP_WITH_OUT_REMOTE_DIRECTORY, null, out s);

            ////    13. Delete All files from FTP_WITH_REMOTE_DIRECTORY
            //StoredProcedure.FtpDeleteFile(FTP_WITH_REMOTE_DIRECTORY, null, out s);

            ////    14. Delete Specific with out remote directory
            //StoredProcedure.FtpDeleteFile(FTP_WITH_OUT_REMOTE_DIRECTORY, specifiedFilesOnly, out s);

            ////    15. Delete Specific from FTP_WITH_REMOTE_DIRECTORY
            //StoredProcedure.FtpDeleteFile(FTP_WITH_REMOTE_DIRECTORY, specifiedFilesOnly, out s);

            //******    SFTP TEST ********

            //      1. Upload file to remote directory
            //StoredProcedure.UploadToFtp(SFTP_WITH_REMOTE_DIRECTORY, localSourceFiles, out  s);

            //      2.  Upload file to root directory, remote directory is empty
            //StoredProcedure.UploadToFtp(SFTP_WITH_OUT_REMOTE_DIRECTORY, localSourceFiles, out  s);

            //      3.  Downalod ALL File from ftp
            //StoredProcedure.DownloadFromFtp(SFTP_WITH_REMOTE_DIRECTORY, null, @"D:\Temp\Downloads\D\", null, out s);

            //      4.  Download Spceified files from without remote directory
            //StoredProcedure.DownloadFromFtp(SFTP_WITH_OUT_REMOTE_DIRECTORY, specifiedFilesOnly, @"D:\Temp\Downloads", null, out s);

            ////    5.  Download Spceified from remote directory
            //StoredProcedure.DownloadFromFtp(SFTP_WITH_REMOTE_DIRECTORY, specifiedFilesOnly, @"D:\temp\", null, out s);

            //      6.  List Ftp files without remote directory
            //StoredProcedure.ListFtpContents(SFTP_WITH_OUT_REMOTE_DIRECTORY, out s);

            //      7.  List FTP files with remote directory
            //StoredProcedure.ListFtpContents(SFTP_WITH_REMOTE_DIRECTORY, out s);

            //      8.  Move All FTP Files with out remote directory
            //StoredProcedure.FtpMoveFileToFolder(SFTP_WITH_OUT_REMOTE_DIRECTORY, null, "D1/D2/D3", out s);

            //      9.  Move All FTP Files with out remote directory
            //StoredProcedure.FtpMoveFileToFolder(SFTP_WITH_OUT_REMOTE_DIRECTORY, specifiedFilesOnly, "D1/D2/D3", out s);

            //      10.  Move All FTP Files with remote directory
            //StoredProcedure.FtpMoveFileToFolder(SFTP_WITH_REMOTE_DIRECTORY, null, "/D1/D2/D3", out s);

            //      11.  Move specified FTP Files with remote directory
            //StoredProcedure.FtpMoveFileToFolder(SFTP_WITH_REMOTE_DIRECTORY, specifiedFilesOnly, "D1/D2/D3", out s);

            //      12. Delete All files with out remote directory
            //StoredProcedure.FtpDeleteFile(SFTP_WITH_OUT_REMOTE_DIRECTORY, null, out s);

            ////    13. Delete All files from SFTP_WITH_REMOTE_DIRECTORY
            //StoredProcedure.FtpDeleteFile(SFTP_WITH_REMOTE_DIRECTORY, null, out s);
            //StoredProcedure.FtpDeleteFile(SFTP_WITH_REMOTE_DIRECTORY, null, out s);

            ////    14. Delete Specific with out remote directory
            //StoredProcedure.FtpDeleteFile(SFTP_WITH_OUT_REMOTE_DIRECTORY, specifiedFilesOnly, out s);

            ////    15. Delete Specific from SFTP_WITH_REMOTE_DIRECTORY
            //StoredProcedure.FtpDeleteFile(SFTP_WITH_REMOTE_DIRECTORY, specifiedFilesOnly, out s);

            //  INTEGRATION TEST
            //StoredProcedure.UploadToFtp(1, "Surya", @"D:\FARRMS\TRMTracker_Release\FARRMS\trm\adiha.php.scripts\dev\shared_docs\temp_Note\BatchReport - Holiday Calendar Report_farrms_admin_2020_06_23_142326.xlsx", out s);

            //StoredProcedure.UploadToFtp(1, "", @"D:\FARRMS\TRMTracker_Release\FARRMS\trm\adiha.php.scripts\dev\shared_docs\temp_Note\BatchReport - Holiday Calendar Report_farrms_admin_2020_06_23_142326.xlsx", out s);

            //  URL Build Test with hostname/directory
            //StoredProcedure.DownloadFromFtp(4, null, null,@"D:\temp\", null, out s);
            //  Override with input
            //StoredProcedure.DownloadFromFtp(4, "TraderDefinition", null, @"D:\temp\", null, out s);

            //  SFTP
            //StoredProcedure.DownloadFromFtp(3, "Commodity Definition", null, @"D:\temp\", null, out s);
            //  Remote directory in endpoint is empty
            //StoredProcedure.FtpMoveFileToFolder(3, "Commodity Definition", "Error", null, out s);                     //  Moves to root/Commodity Definition/Error
            //StoredProcedure.FtpMoveFileToFolder(3, "Commodity Definition", "/Error", null, out s);                    //  Moves to root/Error
            //StoredProcedure.FtpMoveFileToFolder(3, "Commodity Definition", "/Error/Data", null, out s);               //  Moves to root/Error/Data
            //StoredProcedure.FtpMoveFileToFolder(3, "Commodity Definition", "../../../../Error/Processed", null, out s); //  Moves to root/Error/Processed

            ////  Sftp with remote dir in hostname url : uat02.farrms.us/Pioneer/Import/Input/ImportFiles/Commodity
            //StoredProcedure.FtpMoveFileToFolder(6, null, "Error", null, out s); //  Moves to uat02.farrms.us/Pioneer/Import/Input/ImportFiles/Commodity/Error
            //StoredProcedure.FtpMoveFileToFolder(6, null, "/Error", null, out s); //  Moves to uat02.farrms.us/Error
            //StoredProcedure.FtpMoveFileToFolder(6, null, "../../Error", null, out s); //  Moves to uat02.farrms.us/Pioneer/Import/Input/Error
            //StoredProcedure.FtpMoveFileToFolder(6, "SourceFiles", "../../Error", null, out s); //  Moves to uat02.farrms.us/Pioneer/Import/Error
            //StoredProcedure.FtpMoveFileToFolder(6, null, "../../../../Error/Processed", null, out s); //  Moves to root/Error/Processed
            //StoredProcedure.FtpMoveFileToFolder(3, "Commodity Definition", "Error", null, out s); //  Moves to uat02.farrms.us/Pioneer/Import/Error

            //StoredProcedure.UploadToFtp1(1, "testexport", @"D:\FARRMS\TRMTracker_Release\FARRMS\trm\adiha.php.scripts\dev\shared_docs\temp_Note\BatchReport - Holiday Calendar Report_farrms_admin_2020_07_01_125743.xlsx", out s);

            //StoredProcedure.UploadToFtp(4, "surya/test/reports", @"D:\FARRMS\TRMTracker_Release\FARRMS\trm\adiha.php.scripts\dev\shared_docs\temp_Note\BatchReport - Holiday Calendar Report_farrms_admin_2020_07_01_125743.xlsx", out s);
            //StoredProcedure.FtpMoveFileToFolder(1, "TraderDefinition", "Surya", "", out s);
            #endregion
            //Utility.MoveFileToFolder(@"D:\Temp\test\surya.txt", @"D:\temp\Error\", out s);

        }
    }
}