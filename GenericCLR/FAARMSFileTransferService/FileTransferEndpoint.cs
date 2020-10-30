using FARRMSUtilities;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace FAARMSFileTransferService
{
    /// <summary>
    /// Initializes a new instance of the FileTransferEndpoint class.
    /// </summary>
    public class FileTransferEndpoint
    {
        /// <summary>
        /// Initializes a new instance of the FileTransferEndpoint class.
        /// </summary>
        public FileTransferEndpoint()
        {
            
        }

        /// <summary>
        /// Initializes a new instance of the FileTransferEndpoint class specified end point id
        /// </summary>
        /// <param name="fileTransferEndpointId"></param>
        public FileTransferEndpoint(int fileTransferEndpointId)
        {
            GetEndPointConfiguration(fileTransferEndpointId, null);
        }

        /// <summary>
        /// Initializes a new instance of the FileTransferEndpoint class specified end point id
        /// </summary>
        /// <param name="fileTransferEndpointId"></param>
        /// <param name="targetRemoteDirectory"></param>
        public FileTransferEndpoint(int fileTransferEndpointId, string targetRemoteDirectory)
        {
            GetEndPointConfiguration(fileTransferEndpointId, targetRemoteDirectory);
        }

        /// <summary>
        /// Initializes a new instance of the FileTransferEndpoint class specified end point id
        /// </summary>
        /// <param name="fileTransferEndpointId"></param>
        /// <param name="targetRemoteDirectory"></param>
        /// <param name="remoteWorkingDirectory">Remote working directory</param>
        public FileTransferEndpoint(int fileTransferEndpointId, string targetRemoteDirectory, string remoteWorkingDirectory)
        {
            GetEndPointConfiguration(fileTransferEndpointId, targetRemoteDirectory);
        }

        /// <summary>
        /// File transfer endpoint id
        /// </summary>
        public int FileTransferEndpointId { get; set; }
        /// <summary>
        /// Endpoint unique name
        /// </summary>
        public string Name { get; set; }
        //public FileProtocol FileProtocol { get; set; }
        private FileProtocol _myVarFileProtocol;

        /// <summary>
        /// File Protocol , based on protocol url is constructed
        /// </summary>
        public FileProtocol FileProtocol
        {
            get { return _myVarFileProtocol; }
            set
            {
                _myVarFileProtocol = value;
                if (_myVarFileProtocol == FileProtocol.SFTP && !string.IsNullOrEmpty(this.WorkingDirectory))
                {
                    this.WorkingDirectory = "/" + this.WorkingDirectory.TrimStart('/').TrimEnd('/') + "/";
                    //  Valid sftp host name if in case user have supplied sftp prefix with host name, replace it with blank
                    this.HostNameUrl = this.HostNameUrl.ToLower().Replace("sftp://", "");
                }


                //  Add ftp:// to correct ftp url, user miight have input ftp:// or host name only
                if (_myVarFileProtocol == FileProtocol.FTP)
                {
                    this.HostNameUrl = "ftp://" + this.HostNameUrl.Replace("ftp://", "");
                    if (!string.IsNullOrEmpty(this.WorkingDirectory))
                        this.HostNameUrl += "//" + this.WorkingDirectory + "//";
                    else
                        this.HostNameUrl += "//";
                }
            }
        }
        /// <summary>
        /// Endpoint host name url
        /// </summary>
        public string HostNameUrl { get; set; }
        /// <summary>
        /// End point port not , for ftp default port is 21 and for sftp 22
        /// </summary>
        public int PortNo { get; set; }
        /// <summary>
        /// Endpoint user name
        /// </summary>
        public string UserName { get; set; }
        /// <summary>
        /// Endpoint password
        /// </summary>
        public string Password { get; set; }

        private string _myVarRemoteDirectory;
        /// <summary>
        /// Remote working directory for endpoint , suffixed with hostname url if provided
        /// </summary>
        public string WorkingDirectory
        {
            get { return _myVarRemoteDirectory; }
            set
            {
                _myVarRemoteDirectory = value;
                List<string> subDirs = this.HostNameUrl.Replace("ftp://", "").Replace("sftp://", "").Split(new char[] { '/' }, StringSplitOptions.RemoveEmptyEntries).ToList();
                if (subDirs.Count > 1)
                    this.HostNameUrl = subDirs[0];

                this.HostNameUrl = this.HostNameUrl.TrimEnd('/');

                //subDirs.InsertRange(subDirs.Count, remoteDirectory.Split(new char[] { '/' }, StringSplitOptions.RemoveEmptyEntries).ToList());

                string remoteDirectoryPath = "";
                for (int i = 1; i < subDirs.Count; i++)
                {
                    remoteDirectoryPath += "/" + subDirs[i];
                }
                if (!string.IsNullOrEmpty(remoteDirectoryPath))
                    this.WorkingDirectory = "/" + remoteDirectoryPath.TrimStart('/').TrimEnd('/') + "/" + _myVarRemoteDirectory.TrimStart('/').TrimEnd('/') + "/";
            }
        }
        /// <summary>
        /// Private SSH key string used for SFTP connection private key authentication mode
        /// </summary>
        public string PrivateKeyString { get; set; }
        /// <summary>
        /// Passphrase key used for sftp connection if private key authentication mode is wrapped with paassphrase key
        /// </summary>
        public string PassPhraseKey { get; set; }


        /// <summary>
        /// Get configuration settings of endpoint
        /// </summary>
        /// <param name="fileTransferEndpointId">File transfer endpoint id</param>
        /// <param name="targetRemoteDirectory">Target remote direcotry, Overrides endpoint remote directory</param>
        private void GetEndPointConfiguration(int fileTransferEndpointId, string targetRemoteDirectory)
        {
            //  Get configuration of end point from db
            //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-D-SQL01.farrms.us,2033;Initial Catalog=TRMTracker_Enercity;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
            using (var cn = new SqlConnection("Context Connection=True"))
            {
                cn.Open();
                using (SqlCommand cmd = new SqlCommand("EXEC [spa_file_transfer_service] @flag = 'config', @file_transfer_endpoint_id =" + fileTransferEndpointId, cn))
                {
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            this.HostNameUrl = rd["HostNameUrl"].ToString().ToLower().Replace("sftp://", "").Replace("ftp://", "").TrimEnd('/');
                            this.UserName = rd["UserName"].ToString();
                            this.Password = rd["Password"].ToString();
                            if (string.IsNullOrEmpty(targetRemoteDirectory))
                                this.WorkingDirectory = rd["RemoteDirectory"].ToString().TrimStart('/').TrimEnd('/');
                            else
                                this.WorkingDirectory = targetRemoteDirectory.TrimStart('/').TrimEnd('/');
                            this.PortNo = rd["PortNo"].ToInt();
                            this.FileTransferEndpointId = rd["FileTransferEndpointId"].ToInt();
                            this.FileProtocol = (FileProtocol)rd["FileProtocol"].ToInt();
                            this.Name = rd["Name"].ToString();
                            this.PassPhraseKey = rd["PassPhraseKey"].ToString();
                            this.PrivateKeyString = rd["PrivateKey"].ToString();
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Get endpoint configuration, SQL CLR doesnt allow multiple context connection, use same connection instead
        /// </summary>
        /// <param name="fileTransferEndpointId"></param>
        /// <param name="targetRemoteDirectory"></param>
        /// <param name="sqlConnection"></param>
        public void GetEndPointConfiguration(int fileTransferEndpointId, string targetRemoteDirectory, SqlConnection sqlConnection)
        {
            try
            {
                //  Get configuration of end point from db
                using (SqlCommand cmd = new SqlCommand("EXEC [spa_file_transfer_service] @flag = 'config', @file_transfer_endpoint_id =" + fileTransferEndpointId, sqlConnection))
                {
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            this.HostNameUrl = rd["HostNameUrl"].ToString().ToLower().Replace("sftp://", "").Replace("ftp://", "").TrimEnd('/');
                            this.UserName = rd["UserName"].ToString();
                            this.Password = rd["Password"].ToString();
                            if (string.IsNullOrEmpty(targetRemoteDirectory))
                                this.WorkingDirectory = rd["RemoteDirectory"].ToString().TrimStart('/').TrimEnd('/');
                            else
                                this.WorkingDirectory = targetRemoteDirectory.TrimStart('/').TrimEnd('/');
                            this.PortNo = rd["PortNo"].ToInt();
                            this.FileTransferEndpointId = rd["FileTransferEndpointId"].ToInt();
                            this.FileProtocol = (FileProtocol)rd["FileProtocol"].ToInt();
                            this.Name = rd["Name"].ToString();
                            this.PassPhraseKey = rd["PassPhraseKey"].ToString();
                            this.PrivateKeyString = rd["PrivateKey"].ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ex.LogError("GetEndPointConfiguration", "");
            }

        }
    }
}
