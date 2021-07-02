using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using FARRMSUtilities;
using Renci.SshNet;
using Renci.SshNet.Sftp;

namespace FAARMSFileTransferService
{
    /// <summary>
    /// Endpoint file protocol enum
    /// </summary>
    public enum FileProtocol
    {
        FTP = 1, SFTP = 2, FTPS = 3
    }

    
    /// <summary>
    /// File transfer service operations
    /// </summary>
    public class FileTransferService : IDisposable
    {
        /// <summary>
        /// File transfer endpoint definition
        /// </summary>
        public FileTransferEndpoint FileTransferEndpoint { get; set; }
        /// <summary>
        /// Local download directory location
        /// </summary>
        private string _downloadDirectory { get; set; }
        /// <summary>
        /// File extension for filtering the contents of file transfer endpoint
        /// </summary>
        public string FileExtension { get; set; }
        /// <summary>
        /// Local source file to be uploaded or Moved to endpoint. In case of multiple files, files must be separated with (,)
        /// </summary>
        private string SourceFile { get; set; }
        /// <summary>
        /// SFTP Client
        /// </summary>
        private SftpClient _sftpClient { get; set; }
        /// <summary>
        /// FtpWebRequest client
        /// </summary>
        private FtpWebRequest _ftpClient;
        /// <summary>
        /// Target remote directory where file transfer / move activity will be performed
        /// </summary>
        private string _targetRemoteDirectory;


        /// <summary>
        /// Initializes a new instance of the FileTransferService
        /// </summary>
        public FileTransferService()
        { }

        /// <summary>
        /// Initializes a new instance of the FileTransferService with endpoint definition
        /// </summary>
        /// <param name="fileTransferEndpoint">FileTransferEndpoint</param>
        public FileTransferService(FileTransferEndpoint fileTransferEndpoint)
        {
            this.FileTransferEndpoint = fileTransferEndpoint;
            //  Connect to SFTP 
            this.GetSftpConnectionInfo();
        }

        /// <summary>
        /// Initializes a new instance of the FileTransferService class when giving file transfer endpoint id, Used for uploading contents to ftp/sftp 
        /// </summary>
        /// <param name="fileTransferEndpointId">fileTransferEndpointId</param>
        /// <param name="sourceFile">Local file path to upload, multiple files feed seperated by (,) </param>
        public FileTransferService(int fileTransferEndpointId)
        {
            //  Endpoint configuration settings
            this.FileTransferEndpoint = new FileTransferEndpoint(fileTransferEndpointId);
            //  Connect to SFTP 
            this.GetSftpConnectionInfo();
        }

        /// <summary>
        /// Initializes a new instance of the FileTransferService class when giving file transfer endpoint id, Used for downloading contents from ftp/sftp
        /// </summary>
        /// <param name="fileTransferEndpointId">fileTransferEndpointId</param>
        /// <param name="targetRemoteDirectory">targetRemoteDirectory</param>
        public FileTransferService(int fileTransferEndpointId, string targetRemoteDirectory)
        {
            this._targetRemoteDirectory = targetRemoteDirectory;
            //  Endpoint configuration settings
            this.FileTransferEndpoint = new FileTransferEndpoint(fileTransferEndpointId, targetRemoteDirectory);
            //  Connect to SFTP 
            this.GetSftpConnectionInfo();
        }

        /// <summary>
        /// Initializes a new instance of the FileTransferService class when giving file transfer endpoint id, Used for moving contents of ftp/sftp to different remote folder
        /// </summary>
        /// <param name="fileTransferEndpointId">fileTransferEndpointId</param>
        /// <param name="remoteWorkingDirectory">Remove source file location directory, this will override endpoint remote directory</param>
        /// <param name="targetRemoteDirectory">FTP Remote directory where source file will be moved. This dir name should be path from working directory</param>
        /// <param name="sourceFile">File to upload from local</param>
        public FileTransferService(int fileTransferEndpointId, string remoteWorkingDirectory, string targetRemoteDirectory, string sourceFile = null)
        {
            this._targetRemoteDirectory = targetRemoteDirectory;
            if (!string.IsNullOrEmpty(remoteWorkingDirectory))
                remoteWorkingDirectory = ("/" + remoteWorkingDirectory.TrimStart('/').TrimEnd('/') + '/').Replace("//", "/");

            this.SourceFile = sourceFile;

            //  Endpoint configuration settings
            this.FileTransferEndpoint = new FileTransferEndpoint(fileTransferEndpointId, remoteWorkingDirectory);
            //  Connect to SFTP 
            this.GetSftpConnectionInfo();
        }

        /// <summary>
        /// Build SFTP connection info to handle multiple authentication modes
        /// </summary>
        private void GetSftpConnectionInfo()
        {
            if (this.FileTransferEndpoint.FileProtocol == FileProtocol.SFTP)
            {
                var methods = new List<AuthenticationMethod>();
                //  Collect keys , check for sftp username null empty create auth manager etc.
                //if (string.IsNullOrEmpty(this.EndPoint.PrivateKeyString))
                //{
                //    methods.Add(new PasswordAuthenticationMethod(this.EndPoint.UserName, this.EndPoint.Password));
                //}
                methods.Add(new PasswordAuthenticationMethod(this.FileTransferEndpoint.UserName, this.FileTransferEndpoint.Password));

                if (!string.IsNullOrEmpty(this.FileTransferEndpoint.PrivateKeyString))
                {
                    var stream = new MemoryStream(Encoding.UTF8.GetBytes(this.FileTransferEndpoint.PrivateKeyString));
                    var privateKeyFile = new PrivateKeyFile(stream, this.FileTransferEndpoint.PassPhraseKey);

                    methods.Add(new PrivateKeyAuthenticationMethod(this.FileTransferEndpoint.UserName, privateKeyFile));
                }
                var connectionInfo = new ConnectionInfo(this.FileTransferEndpoint.HostNameUrl, this.FileTransferEndpoint.PortNo, this.FileTransferEndpoint.UserName, methods.ToArray());
                //_sftpClient = new SftpClient(this.EndPoint.HostNameUrl, this.EndPoint.PortNo, this.EndPoint.UserName, this.EndPoint.Password);
                _sftpClient = new SftpClient(connectionInfo);
                _sftpClient.Connect();
            }
        }

        #region FTP Operations

        /// <summary>
        /// Creates a ftp web request with appending file
        /// </summary>
        /// <param name="fileName">Filename</param>
        /// <param name="webRequestMethodsFtp">FTP WebRequestMethods.FTP Methods</param>
        /// <returns>FtpWebRequest</returns>
        private FtpWebRequest CreateFtpWebRequestWithFileName(string fileName, string webRequestMethodsFtp)
        {
            if (!string.IsNullOrEmpty(fileName))
                _ftpClient = (FtpWebRequest)FtpWebRequest.Create(this.FileTransferEndpoint.HostNameUrl.TrimEnd('/') + "/" + Path.GetFileName(fileName));
            else
                _ftpClient = (FtpWebRequest)FtpWebRequest.Create(this.FileTransferEndpoint.HostNameUrl);

            _ftpClient.UsePassive = true;

            if (!string.IsNullOrEmpty(this.FileTransferEndpoint.UserName))
                _ftpClient.Credentials = new NetworkCredential(this.FileTransferEndpoint.UserName, this.FileTransferEndpoint.Password);
            AddClientCetificates(_ftpClient);
            _ftpClient.UseBinary = true;
            _ftpClient.KeepAlive = true;
            //  In case of moving the file from ftp (Renaming) this option will be set as null
            if (!string.IsNullOrEmpty(webRequestMethodsFtp))
                _ftpClient.Method = webRequestMethodsFtp;
            return _ftpClient;
        }

        /// <summary>
        /// Creates a ftp web request to provided ftp url
        /// </summary>
        /// <param name="ftpUrl"></param>
        /// <param name="webRequestMethodsFtp">WebRequestMethods.Ftp</param>
        /// <returns>FtpWebRequest</returns>
        private FtpWebRequest CreateFtpWebRequestWithUrl(string ftpUrl, string webRequestMethodsFtp)
        {
            _ftpClient = (FtpWebRequest)FtpWebRequest.Create(ftpUrl);

            _ftpClient.UsePassive = true;

            if (!string.IsNullOrEmpty(this.FileTransferEndpoint.UserName))
                _ftpClient.Credentials = new NetworkCredential(this.FileTransferEndpoint.UserName, this.FileTransferEndpoint.Password);
            AddClientCetificates(_ftpClient);
            _ftpClient.UseBinary = true;
            _ftpClient.KeepAlive = true;
            _ftpClient.Method = webRequestMethodsFtp;
            return _ftpClient;
        }


        /// <summary>
        /// Add client certificate, For FTPS file protocol only
        /// </summary>
        /// <param name="ftpClient">FtpWebRequest Client</param>
        private void AddClientCetificates(FtpWebRequest ftpClient)
        {
            if (this.FileTransferEndpoint.FileProtocol == FileProtocol.FTPS)
                ftpClient.EnableSsl = true;

        }

        /// <summary>
        /// Download files from FTP
        /// </summary>
        /// <returns>True / False</returns>
        private bool DownloadFromFtp()
        {
            try
            {
                if (string.IsNullOrEmpty(this.SourceFile))
                {
                    string[] files = this.GetFilesFromFtpFolder(returnFileOnly: true);
                    foreach (string file in files)
                    {
                        if (file == "") continue;
                        this.DownloadFile(file);
                    }
                }
                else
                {
                    string[] arrFiles = this.SourceFile.Split(',');
                    foreach (string file in arrFiles)
                    {
                        DownloadFile(file);
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Upload local files to FTP
        /// </summary>
        /// <returns>True / False</returns>
        private bool UploadToFtp()
        {
            try
            {
                string ftpurl;
                string[] remoteDirectories = this.BuildRemoteTargetDirectories(out ftpurl);
                if (!string.IsNullOrEmpty(_targetRemoteDirectory))
                {
                    var segments = ftpurl.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
                    ftpurl = segments[0] + "//" + segments[1];
                }
                this.CreateFtpDirectories(ftpurl, remoteDirectories);

                //this.FileTransferEndpoint.HostNameUrl += "/" + this.FileTransferEndpoint.RemoteDirectory.TrimStart('/').TrimEnd('/') + "/";
                //  Added support for multiple files uploaded separated by ,
                string[] filesToUpload = this.SourceFile.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string file in filesToUpload)
                {
                    _ftpClient = this.CreateFtpWebRequestWithFileName(file, WebRequestMethods.Ftp.UploadFile);

                    System.IO.FileInfo fi = new System.IO.FileInfo(file);
                    _ftpClient.ContentLength = fi.Length;
                    byte[] buffer = new byte[_ftpClient.ContentLength];
                    int bytes = 0;
                    System.IO.FileStream fs = fi.OpenRead();
                    System.IO.Stream rs = _ftpClient.GetRequestStream();
                    bytes = fs.Read(buffer, 0, buffer.Length);
                    rs.Write(buffer, 0, bytes);
                    fs.Close();
                    rs.Close();
                    FtpWebResponse uploadResponse = (FtpWebResponse)_ftpClient.GetResponse();
                    uploadResponse.Close();
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Move ftp file to target remote directory
        /// </summary>
        /// <returns>True / False</returns>
        private bool MoveFtpFile()
        {
            try
            {
                string ftpurl;
                string[] remoteDirectories =  this.BuildRemoteTargetDirectories(out ftpurl);
                this.CreateFtpDirectories(ftpurl, remoteDirectories);
                //  Files feed sparated by comma
                string[] arrFiles;

                if (string.IsNullOrEmpty(this.SourceFile))
                    arrFiles = this.GetFilesFromFtpFolder(returnFileOnly: true);
                else
                    arrFiles = this.SourceFile.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);

                foreach (string file in arrFiles)
                {
                    //  web request method set to be null, there is no rename or move methods, we will use ftp client rename method instead
                    _ftpClient = this.CreateFtpWebRequestWithFileName(file, null);
                    //  added to suppress error if file not found
                    try
                    {
                        //  Dont carry the operation if target remote directory is empty
                        if (!string.IsNullOrEmpty(_targetRemoteDirectory))
                        {
                            _ftpClient.Method = WebRequestMethods.Ftp.Rename;
                            _ftpClient.RenameTo = this._targetRemoteDirectory + "/" + Path.GetFileName(file);

                            using (FtpWebResponse response = (FtpWebResponse)_ftpClient.GetResponse()) ;
                        }
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return false;
        }

        /// <summary>
        /// Get array remote directory based on FTP protocol, target directory with handling of directory browsing Eg. ../../error
        /// </summary>
        private string[] BuildRemoteTargetDirectories(out string outFtpUrl)
        {
            //  Root directory folder segement can be varied because of protocol url used
            int rootDirectoryLevel = 2;

            //  Create directory if it doesnt exists
            List<string> directories = this._targetRemoteDirectory.Split(new char[] { '/' }, StringSplitOptions.RemoveEmptyEntries).ToList();
            List<string> ftpUrlSegments = null;
            if (this.FileTransferEndpoint.FileProtocol == FileProtocol.FTP ||
                this.FileTransferEndpoint.FileProtocol == FileProtocol.FTPS)
            {
                rootDirectoryLevel = 2;
                ftpUrlSegments = this.FileTransferEndpoint.HostNameUrl.Split(new char[]{'/'}, StringSplitOptions.RemoveEmptyEntries).ToList();
            }
            else if (this.FileTransferEndpoint.FileProtocol == FileProtocol.SFTP)
            {
                rootDirectoryLevel = 1;
                ftpUrlSegments =(this.FileTransferEndpoint.HostNameUrl + "/" + this.FileTransferEndpoint.WorkingDirectory).Split(new char[] {'/'}, StringSplitOptions.RemoveEmptyEntries).ToList();
            }

            
            
            if (this._targetRemoteDirectory.Contains(".."))
            {

                for (int i = 0; i < directories.Count(x => x == ".."); i++)
                {
                    ftpUrlSegments.RemoveAt(ftpUrlSegments.Count - 1);
                    //  if reaches to parent root folder skip 
                    if (ftpUrlSegments.Count == rootDirectoryLevel) break;
                }
                //  append directory name
                ftpUrlSegments.AddRange(directories.Where(x => x != ".."));
                this._targetRemoteDirectory = "";
                for (int i = rootDirectoryLevel; i < ftpUrlSegments.Count; i++)
                {
                    this._targetRemoteDirectory += ftpUrlSegments[i] + "/";
                }
                this._targetRemoteDirectory = '/' + this._targetRemoteDirectory.TrimEnd('/').TrimStart('/') + '/';
                directories = this._targetRemoteDirectory.Split(new string[] {"/"}, StringSplitOptions.RemoveEmptyEntries).ToList();
            }

            
            string ftpUrl = "";
            if (!string.IsNullOrEmpty(_targetRemoteDirectory) &&
                    _targetRemoteDirectory.StartsWith(".."))
            {
                foreach (string ftpUrlSegment in ftpUrlSegments)
                {
                    ftpUrl += ftpUrlSegment + "/";
                }
            }
            else if (!string.IsNullOrEmpty(_targetRemoteDirectory) &&
                     _targetRemoteDirectory.StartsWith("/"))
            {
                ftpUrl = ftpUrlSegments[0] + "//" + ftpUrlSegments[1];
            }
            else
            {
                ftpUrl = ftpUrlSegments[0] + "//" + ftpUrlSegments[1] + "/" + this.FileTransferEndpoint.WorkingDirectory + "/";
            }

            //if (this.FileTransferEndpoint.FileProtocol == FileProtocol.SFTP)
            //    ftpUrl = ftpUrlSegments[0] + "/";

            outFtpUrl = ftpUrl;
            return directories.ToArray();
        }

        /// <summary>
        /// Create remote directory relative to ftp working directory & target remote directory
        /// </summary>
        private void CreateFtpDirectories(string ftpUrl, string[] directories)
        {
            if (directories != null)
            {
                foreach (string t in directories)
                {
                    ftpUrl += "/" + t + "/";
                    _ftpClient = this.CreateFtpWebRequestWithUrl(ftpUrl, WebRequestMethods.Ftp.MakeDirectory);
                    try
                    {
                        using (FtpWebResponse response = (FtpWebResponse) _ftpClient.GetResponse()) ;
                    }
                    catch (Exception ex)
                    {
                        
                    }
                }
            }
        }
        
        /// <summary>
        /// Delete remote files from ftp
        /// </summary>
        /// <returns>True / False</returns>
        private bool DeleteFtpFile()
        {
            try
            {
                string[] arrFiles;

                if (!string.IsNullOrEmpty(this.SourceFile))
                    arrFiles = this.SourceFile.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                else
                    arrFiles = GetFilesFromFtpFolder(returnFileOnly: true);

                foreach (string file in arrFiles)
                {
                    _ftpClient = this.CreateFtpWebRequestWithFileName(Path.GetFileName(file), WebRequestMethods.Ftp.DeleteFile);
                    using (FtpWebResponse response = (FtpWebResponse)_ftpClient.GetResponse()) ;
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }

        }

        /// <summary>
        /// Get files array from remote ftp dir
        /// </summary>
        /// <returns></returns>
        private string[] GetFilesFromFtpFolder(bool returnFileOnly)
        {
            string[] directoryInfo = GetFtpDirectoryList(withDetails: false);

            List<string> filesOnlyList = new List<string>();
            if (returnFileOnly)
            {
                string[] directoryDetails = GetFtpDirectoryList(withDetails: true);

                for (int i = 0; i < directoryDetails.Count(); i++)
                {
                    if (!directoryDetails[i].StartsWith("d"))
                        filesOnlyList.Add(directoryInfo[i]);
                }
                return filesOnlyList.ToArray();
            }

            return directoryInfo;
        }

        /// <summary>
        /// Get directort list information array
        /// </summary>
        /// <returns></returns>
        private string[] GetFtpDirectoryList(bool withDetails)
        {
            if (withDetails)
                _ftpClient = this.CreateFtpWebRequestWithFileName(null, WebRequestMethods.Ftp.ListDirectoryDetails);
            else
                _ftpClient = this.CreateFtpWebRequestWithFileName(null, WebRequestMethods.Ftp.ListDirectory); ;

            FtpWebResponse response = (FtpWebResponse)_ftpClient.GetResponse();
            Stream responseStream = response.GetResponseStream();
            StreamReader reader = new StreamReader(responseStream);
            string[] directoryInfo = reader.ReadToEnd().Split(new string[] { Environment.NewLine }, StringSplitOptions.None);
            return directoryInfo.Where(x => !string.IsNullOrEmpty(x)).ToArray();
        }

        /// <summary>
        /// Download file from ftp server
        /// </summary>
        /// <param name="fileName">remote filename to download</param>
        private void DownloadFile(string fileName)
        {
            if (!string.IsNullOrEmpty(this.FileExtension))
            {
                if (!fileName.EndsWith(this.FileExtension.Replace("*", ""))) return;
            }
            try
            {
                fileName = Path.GetFileName(fileName);

                _ftpClient = this.CreateFtpWebRequestWithFileName(fileName, WebRequestMethods.Ftp.DownloadFile);
                using (FtpWebResponse response = (FtpWebResponse)_ftpClient.GetResponse()) // Error here
                using (Stream responseStream = response.GetResponseStream())

                using (Stream targetStream = File.Create(this._downloadDirectory + @"\" + fileName))
                {
                    byte[] buffer = new byte[10240];
                    int read;
                    while ((read = responseStream.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        targetStream.Write(buffer, 0, read);
                    }
                }
            }
            catch (Exception ex)
            {
                //ex.LogError("Download File", fileName + "|" + ex.Message);
                throw ex;
            }
        }
        #endregion




        /// <summary>
        /// Download file from EndPoint
        /// </summary>
        /// <param name="downloadDirectory">Local download directory location</param>
        /// <param name="sourceFile">Remote source files tod download, multiple files feed seperated by (,)</param>
        /// <param name="fileExtension">Remote file extension to filter download contents</param>
        /// <returns>True / False</returns>
        public bool Download(string downloadDirectory, string sourceFile = null, string fileExtension = null)
        {
            if (!string.IsNullOrEmpty(downloadDirectory))
                this._downloadDirectory = downloadDirectory.TrimEnd('\\') + "\\";
            this.FileExtension = fileExtension;
            this.SourceFile = sourceFile;

            if (this.FileTransferEndpoint.FileProtocol == FileProtocol.SFTP)
                return this.DownloadFromSftp();
            else if (this.FileTransferEndpoint.FileProtocol == FileProtocol.FTP || this.FileTransferEndpoint.FileProtocol == FileProtocol.FTPS)
                return this.DownloadFromFtp();
            return false;
        }

        /// <summary>
        /// Upload file to EndPoint
        /// </summary>
        /// <returns>True / False</returns>
        public bool Upload(string sourceFiles)
        {
            this.SourceFile = sourceFiles;
            if (this.FileTransferEndpoint.FileProtocol == FileProtocol.SFTP)
                return this.UploadToSftp();
            else if (this.FileTransferEndpoint.FileProtocol == FileProtocol.FTP || this.FileTransferEndpoint.FileProtocol == FileProtocol.FTPS)
                return this.UploadToFtp();
            return false;
        }

        /// <summary>
        /// Move EndPoint File file
        /// </summary>
        /// <returns></returns>
        public bool Move(string sourceFiles)
        {
            this.SourceFile = sourceFiles;
            if (this.FileTransferEndpoint.FileProtocol == FileProtocol.SFTP)
                return this.MoveSftpFile();
            else if (this.FileTransferEndpoint.FileProtocol == FileProtocol.FTP || this.FileTransferEndpoint.FileProtocol == FileProtocol.FTPS)
                return this.MoveFtpFile();

            return false;
        }

        /// <summary>
        /// Delete File From Endpoint
        /// </summary>
        /// <returns></returns>
        public bool Delete(string sourceFile)
        {
            this.SourceFile = sourceFile;
            if (this.FileTransferEndpoint.FileProtocol == FileProtocol.SFTP)
                return this.DeleteSftpFile();
            else if (this.FileTransferEndpoint.FileProtocol == FileProtocol.FTP || this.FileTransferEndpoint.FileProtocol == FileProtocol.FTPS)
                return this.DeleteFtpFile();

            return false;
        }

        /// <summary>
        /// List EndPoint contents (Files / Directory Listing)
        /// </summary>
        /// <returns></returns>
        public string[] ListFiles()
        {
            if (this.FileTransferEndpoint.FileProtocol == FileProtocol.FTP)
                return GetFilesFromFtpFolder(returnFileOnly: false);
            else if (this.FileTransferEndpoint.FileProtocol == FileProtocol.SFTP)
                return GetFilesFromSftpFolder(returnFileOnly:false);
            return null;
        }

        /// <summary>
        /// List files or all contents from endpoint
        /// </summary>
        /// <param name="returnFileOnly">True to list files only, false will display all content from endpoint</param>
        /// <returns>Array of file string</returns>
        public string[] ListFiles(bool returnFileOnly)
        {
            if (this.FileTransferEndpoint.FileProtocol == FileProtocol.FTP)
                return GetFilesFromFtpFolder(returnFileOnly);
            else if (this.FileTransferEndpoint.FileProtocol == FileProtocol.SFTP)
                return GetFilesFromSftpFolder(returnFileOnly);
            return null;
        }

        #region SFTP Operation
        /// <summary>
        /// Delete SFTP Remote file
        /// </summary>
        /// <returns>True / False</returns>
        private bool DeleteSftpFile()
        {
            string[] arrFiles;

            if (!string.IsNullOrEmpty(this.SourceFile))
                arrFiles = this.SourceFile.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
            else
                arrFiles = GetFilesFromSftpFolder(returnFileOnly: true);
            _sftpClient.ChangeDirectory(this.FileTransferEndpoint.WorkingDirectory);
            foreach (string file in arrFiles)
            {
                _sftpClient.DeleteFile(Path.GetFileName(file));   
            }
            return false;
        }

        /// <summary>
        /// Move SFTP Remote File
        /// </summary>
        /// <returns>True / False</returns>
        private bool MoveSftpFile()
        {
            try
            {
                string ftpurl;
                string[] remoteDirectories = this.BuildRemoteTargetDirectories(out ftpurl);

                //  Files feed sparated by comma
                string[] arrFiles;
                if (!string.IsNullOrEmpty(this.SourceFile))
                    arrFiles = this.SourceFile.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries).ToArray();
                else
                    arrFiles = this.GetFilesFromSftpFolder(returnFileOnly:true);
                if (_targetRemoteDirectory.StartsWith("..") || _targetRemoteDirectory.StartsWith("/"))
                    _sftpClient.ChangeDirectory("/");
                else
                    _sftpClient.ChangeDirectory(this.FileTransferEndpoint.WorkingDirectory);
                //  Create directory if it doesnt exists
                //string[] directories = _targetRemoteDirectory.Split(new char[] { '/' }, StringSplitOptions.RemoveEmptyEntries);
                for (int i = 0; i < remoteDirectories.Length; i++)
                {
                    string dirName = string.Join("/", remoteDirectories, 0, i + 1);
                    if (!_sftpClient.Exists(dirName))
                        _sftpClient.CreateDirectory(dirName);
                }


                //  Change current working directory
                _sftpClient.ChangeDirectory(this.FileTransferEndpoint.WorkingDirectory);
                foreach (string file in arrFiles)
                {
                    if (string.IsNullOrEmpty(Path.GetExtension(file))) continue;
                    //  Move
                    try
                    {
                        if (_sftpClient.Exists(_targetRemoteDirectory + "/" + file))
                            _sftpClient.DeleteFile( _targetRemoteDirectory + "/" + file);
                        _sftpClient.RenameFile(file, _targetRemoteDirectory + "/" + file);
                    }
                    catch (Exception ex)
                    {
                        ex.LogError("MoveSftpFile", ex.Message);
                    }
                    
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return true;
        }

        /// <summary>
        /// Get list of contents from sftp folder
        /// </summary>
        /// <returns></returns>
        private string[] GetFilesFromSftpFolder(bool returnFileOnly)
        {
            SftpFile[] files;
            if (returnFileOnly)
                files = _sftpClient.ListDirectory(this.FileTransferEndpoint.WorkingDirectory).Where(x => !x.IsDirectory).ToArray();
            else
                files = _sftpClient.ListDirectory(this.FileTransferEndpoint.WorkingDirectory).ToArray();

            return files.Select(s => s.Name).ToArray();
        }

        /// <summary>
        /// Download file from sftp
        /// </summary>
        /// <returns>True / False</returns>
        private bool DownloadFromSftp()
        {
            try
            {
                if (!string.IsNullOrEmpty(this.SourceFile))
                {
                    //  Added to support multiple file download
                    string[] arrFiles = this.SourceFile.Split(new string[] {","}, StringSplitOptions.RemoveEmptyEntries);

                    foreach (string file in arrFiles)
                    {
                        using (Stream stream = File.OpenWrite(_downloadDirectory + file))
                        {
                            //  Capture error if remote file name is not found
                            try
                            {
                                _sftpClient.BufferSize = 1024;
                                _sftpClient.DownloadFile(this.FileTransferEndpoint.WorkingDirectory + file, stream);
                            }
                            catch (Exception ex)
                            {
                                ex.LogError("DownloadFromSftp", ex.Message);
                            }
                        }
                    }
                    return true;
                }
                else
                {
                    var files = _sftpClient.ListDirectory(this.FileTransferEndpoint.WorkingDirectory);
                    //  Download All Files
                    foreach (var file in files)
                    {
                        if (!string.IsNullOrEmpty(this.FileExtension))
                        {
                            if (!file.Name.ToLower().EndsWith(this.FileExtension.Replace("*", "").ToLower())) continue;
                        }
                        string remoteFileName = file.Name;
                        if (file.IsDirectory) continue;
                        if (!file.Name.StartsWith("."))
                        {
                            using (Stream stream = File.OpenWrite(this._downloadDirectory + remoteFileName))
                            {
                                //  Capture error if remote file name is not found
                                try
                                {
                                    _sftpClient.BufferSize = 1024;
                                    _sftpClient.DownloadFile(this.FileTransferEndpoint.WorkingDirectory + remoteFileName, stream);
                                }
                                catch (Exception ex)
                                {
                                    ex.LogError("DownloadFromSftp",ex.Message);
                                }
                            }
                        }
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Upload files to sftp
        /// </summary>
        /// <returns></returns>
        private bool UploadToSftp()
        {
            try
            {
                try
                {
                    if (!string.IsNullOrEmpty(this._targetRemoteDirectory))
                    {
                        string ftpurl;
                        string[] remoteDirectories = this.BuildRemoteTargetDirectories(out ftpurl);

                        //  Create directory if it doesnt exists
                        for (int i = 0; i < remoteDirectories.Length; i++)
                        {
                            string dirName = string.Join("/", remoteDirectories, 0, i + 1);
                            if (!_sftpClient.Exists(dirName))
                                _sftpClient.CreateDirectory(dirName);
                        }
                    }
                }
                catch (Exception)
                {

                }

                _sftpClient.ChangeDirectory(this.FileTransferEndpoint.WorkingDirectory);
                //  Added to support upload multiple files
                string[] arrFiles = this.SourceFile.Split(new string[] {","}, StringSplitOptions.RemoveEmptyEntries);

                foreach (string file in arrFiles)
                {
                    //  skip uploading file if it doesnt exists in local
                    if (!File.Exists(file)) continue;
                    using (FileStream fileStream = new FileStream(file, FileMode.Open))
                    {
                        _sftpClient.UploadFile(fileStream, Path.GetFileName(file));
                    }   
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion

        public void Dispose()
        {
            if (this._sftpClient != null)
            {
                if (this._sftpClient.IsConnected)
                {
                    this._sftpClient.Disconnect();
                }
                this._sftpClient.Dispose();
            }   
            GC.Collect();
        }
    }
}
