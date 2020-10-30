using System;
using System.Data;
using Microsoft.SqlServer.Server;
using FARRMSUtilities;
using FAARMSFileTransferService;
using System.IO;

namespace FAARMSFileTransferCLR
{
    public class StoredProcedure
    {
        [Microsoft.SqlServer.Server.SqlProcedure]
        #region FTP, FTPS, SFTP File Transfer Service

        /// <summary>
        /// Upload file(s) to endpoint
        /// </summary>
        /// <param name="fileTransferEndpointId">fileTransferEndpointId</param>
        /// <param name="targetRemoteDirectory">targetRemoteDirectory</param>
        /// <param name="sourceFile">Source file name or multiple filenames separated with (,)</param>
        /// <param name="result">Success or exception message</param>
        public static void UploadToFtp(int fileTransferEndpointId, string targetRemoteDirectory, string sourceFile, out string result)
        {
            try
            {
                using (var client = new FileTransferService(fileTransferEndpointId, targetRemoteDirectory))
                {
                    client.Upload(sourceFile);
                }
                result = "success";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Upload file to ftp", fileTransferEndpointId + "|" + targetRemoteDirectory + "|" + sourceFile + "|" + ex.Message);
            }
        }

        /// <summary>
        /// Download file(s) from endpoint
        /// </summary>
        /// <param name="fileTransferEndpointId">fileTransferEndpointId</param>
        /// <param name="targetRemoteDirectory"></param>
        /// <param name="sourceFile">Source file name or multiple filenames separated with (,)</param>
        /// <param name="destination">Local destination directory for downloaded files</param>
        /// <param name="extension">File extension to filter download contents ef. *.csv</param>
        /// <param name="result">Success or exception message</param>
        public static void DownloadFromFtp(int fileTransferEndpointId, string targetRemoteDirectory, string sourceFile, string destination, string extension, out string result)
        {
            //  Create download directory if not found
            //  Suppress error if service account doesnt have permission to create folder
            try
            {
                if (!Directory.Exists(destination))
                    Directory.CreateDirectory(destination);
            }
            catch (Exception)
            {
            }

            try
            {
                using (var client = new FileTransferService(fileTransferEndpointId, targetRemoteDirectory))
                {
                    client.Download(destination, sourceFile, extension);
                }
                result = "success";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Upload file to ftp", fileTransferEndpointId + "|" + targetRemoteDirectory + "|" + sourceFile + "|" + ex.Message);
            }
        }

        /// <summary>
        /// List Contents of endpoint
        /// </summary>
        /// <param name="fileTransferEndpointId">fileTransferEndpointId</param>
        /// <param name="result">Success or exception message</param>
        public static void ListFtpContents(int fileTransferEndpointId, string targetRemoteDirectory, out string result)
        {
            // define table structure
            SqlDataRecord rec = new SqlDataRecord(new SqlMetaData[] { new SqlMetaData("ftp_url", SqlDbType.NVarChar, 1024), new SqlMetaData("dir_file", SqlDbType.NVarChar, 1024) });
            string ftpUrl = "";
            try
            {
                using (var client = new FileTransferService(fileTransferEndpointId, targetRemoteDirectory))
                {
                    ftpUrl = client.FileTransferEndpoint.HostNameUrl;
                    string[] files = client.ListFiles();
                    SqlContext.Pipe.SendResultsStart(rec);
                    foreach (string s in files)
                    {
                        if (s.Trim() == "") continue;
                        rec.SetSqlString(0, ftpUrl);
                        rec.SetSqlString(1, s);
                        SqlContext.Pipe.SendResultsRow(rec);
                    }
                    SqlContext.Pipe.SendResultsEnd();    // finish sending
                }
                result = "success";
            }
            catch (Exception ex)
            {
                SqlContext.Pipe.SendResultsStart(rec);
                rec.SetSqlString(0, ftpUrl);
                rec.SetSqlString(1, "ERROR OCCURRED");
                SqlContext.Pipe.SendResultsRow(rec);
                SqlContext.Pipe.SendResultsEnd();    // finish sending
                result = ex.Message;
                ex.LogError("List Ftp Contents", fileTransferEndpointId + "|" + ex.Message);
            }
        }

        /// <summary>
        /// Test Endpoint connection
        /// </summary>
        /// <param name="fileTransferEndpointId">fileTransferEndpointId</param>
        /// <param name="result">sucess or failure message</param>
        public static void TestFileTransferEndpointConnection(int fileTransferEndpointId, out string result)
        {
            try
            {
                using (var client = new FileTransferService(fileTransferEndpointId))
                {
                    client.FileTransferEndpoint.WorkingDirectory = "";
                    if (client.FileTransferEndpoint.FileProtocol == FileProtocol.FTP)
                        client.FileTransferEndpoint.HostNameUrl = "ftp://" + client.FileTransferEndpoint.HostNameUrl;
                    string[] files = client.ListFiles();
                }
                result = "success";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("TestEndpointConnection", fileTransferEndpointId + "|" + ex.Message);
            }
        }
        /// <summary>
        /// Move remote file from endpoint
        /// </summary>
        /// <param name="fileTransferEndpointId">fileTransferEndpointId</param>
        /// <param name="sourceFile">Source file name or multiple filenames separated with (,)</param>
        /// <param name="targetRemoteDirectory">Target remote directory</param>
        /// <param name="result">Success or exception message</param>


        /// <summary>
        /// Move remote file from endpoint
        /// </summary>
        /// <param name="fileTransferEndpointId">fileTransferEndpointId</param>
        /// <param name="remoteWorkingDirectory">Remote working directory where files will be searched for moving to target remote directory</param>
        /// <param name="targetRemoteDirectory">Target remote directory, where folder will be moved</param>
        /// <param name="sourceFile">Source file name or multiple filenames separated with (,)</param>
        /// <param name="result">Success or exception message</param>
        public static void FtpMoveFileToFolder(int fileTransferEndpointId, string remoteWorkingDirectory, string targetRemoteDirectory, string sourceFile, out string result)
        {

            try
            {
                using (var client = new FileTransferService(fileTransferEndpointId, remoteWorkingDirectory, targetRemoteDirectory))
                {
                    client.Move(sourceFile);
                }
                result = "success";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Ftp Move File To Folder", fileTransferEndpointId + remoteWorkingDirectory + "|" + targetRemoteDirectory + "|" + sourceFile + "|" + ex.Message);
            }
        }

        /// <summary>
        /// Delete specified remote files from file transfer endpoint
        /// </summary>
        /// <param name="fileTransferEndpointId">fileTransferEndpointId</param>
        /// <param name="sourceFileName">Source file name or multiple filenames separated with (,) </param>
        /// <param name="result">Success or exception message</param>
        public static void FtpDeleteFile(int fileTransferEndpointId, string sourceFileName, out string result)
        {
            try
            {
                using (var client = new FileTransferService(fileTransferEndpointId: fileTransferEndpointId))
                {
                    client.Delete(sourceFileName);
                }
                result = "success";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("FtpDeleteFile", fileTransferEndpointId + "|" + sourceFileName + "|" + ex.Message);
            }
        }

        #endregion
    }
}

