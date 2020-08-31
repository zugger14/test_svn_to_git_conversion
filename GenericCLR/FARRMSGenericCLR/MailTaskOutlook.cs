using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using Microsoft.SqlServer.Server;

using System.Threading;
using System.Threading.Tasks;

using MailKit.Net.Imap;
using MailKit.Search;
using MailKit;
using MimeKit;
using System.Security.Authentication;
using FARRMSUtilities;

namespace FARRMSGenericCLR
{
    #region Mail Settings
    /// <summary>
    /// This class holds configuration settings for mail retrival.
    /// </summary>
    public class MailSetting
    {
        public MailSetting() {}
        public MailSetting(string emailAddress, string emailPassword, string emailHost, int emailServerPort, bool emailRequireSsl, SqlConnection sqlConnection, string processId)
        {
            this.EmailAddress = emailAddress;
            this.EmailPassword = emailPassword;
            this.emailHost = emailHost;
            this.EmailServerPort = emailServerPort;
            this.EmailRequireSsl = emailRequireSsl;
            this.Connection = sqlConnection;
            this.processId = processId;
        }

        public string EmailAddress { get; set; }
        public string EmailPassword { get; set; }
        public string emailHost { get; set; }
        public int EmailServerPort { get; set; }
        public bool EmailRequireSsl { get; set; }
        public string processId { get; set; }
        public SqlConnection Connection { get; set; }
    }
    #endregion

    /// <summary>
    /// This class contents misc method to retrieve email , downloading attachment , delete email
    /// </summary>
    public class MailTaskOutlook
    {
        public MailTaskOutlook(MailSetting _MailSetting)
        {
            MailSetting = _MailSetting;
        }
        public MailSetting MailSetting{ get; set; }
        public string FileNameSeparator = "_-_";

        #region Save Attachment
        //save email attachment to physical location and also on sql table 'attachment_detail_info'
        private Exception SaveAttachment(MimeMessage message, string mailbox, string email_id)
        {
            
            try
            {
                string attFolder = string.Format("{0}\\inbox_attachments", mailbox);
                string inboxSavedAttachment = "";

                foreach (var att in message.Attachments)
                {
                    if (att is MimePart)
                    {
                        var part = (MimePart)att;
                        int attachment_file_size = 0;
                        byte[] buff;
                        
                        if (!System.IO.Directory.Exists(attFolder))
                            System.IO.Directory.CreateDirectory(attFolder);
                        //inboxSavedAttachment = string.Format("{0}\\{1}", attFolder, message.MessageId + FileNameSeparator + part.FileName);
                        //FileInfo fi = new FileInfo(part.FileName);
                        string file_ext = "." + part.FileName.Split('.').Last();
                        string file_name = part.FileName;
                        inboxSavedAttachment = string.Format("{0}\\{1}", attFolder, Guid.NewGuid().ToString().Replace("-", "_").ToUpper() + file_ext);
                        
                        using (FileStream fs = File.Create(inboxSavedAttachment))
                        {
                            part.ContentObject.DecodeTo(fs);
                            attachment_file_size = fs.Length.ToInt();
                        }
                        buff = File.ReadAllBytes(inboxSavedAttachment);

                        //save attachment details on sql table

                        SqlCommand cmdAtt = new SqlCommand("spa_attachment_detail_info", MailSetting.Connection);
                        cmdAtt.CommandType = CommandType.StoredProcedure;
                        cmdAtt.Parameters.Add(new SqlParameter("@flag", "i"));
                        cmdAtt.Parameters.Add(new SqlParameter("@email_id", email_id));
                        cmdAtt.Parameters.Add(new SqlParameter("@attachment_file_path", inboxSavedAttachment));
                        cmdAtt.Parameters.Add(new SqlParameter("@attachment_file_name", file_name));
                        cmdAtt.Parameters.Add(new SqlParameter("@attachment_file_size", attachment_file_size));
                        cmdAtt.Parameters.Add("@FS_Data", SqlDbType.VarBinary, -1).Value = buff;
                        cmdAtt.ExecuteNonQuery();
                       
                    }
                }
                return null;
            }
            catch (Exception ex)
            {
                return ex;
            }
            
        }
        #endregion

        #region Parse Email
        //parse email subject content
        private Exception ParseEmail(string email_id, string subject, string body)
        {

            try
            {
                
                //assuming pattern is [# object : value #]
                string pattern_start = "[#";
                if (subject.IndexOf(pattern_start) > -1)
                {
                    //pattern exists, need to parse
                    SqlCommand cmdParse = new SqlCommand("spa_manage_email", MailSetting.Connection);
                    cmdParse.CommandType = CommandType.StoredProcedure;
                    cmdParse.Parameters.Add(new SqlParameter("@flag", "p"));
                    cmdParse.Parameters.Add(new SqlParameter("@notes_id", email_id));
                    cmdParse.Parameters.Add(new SqlParameter("@email_subject", subject));
                    cmdParse.Parameters.Add(new SqlParameter("@parse_pattern", pattern_start));
                    cmdParse.Parameters.Add(new SqlParameter("@email_body", body));
                    cmdParse.ExecuteNonQuery();
                    
                }
                else
                {
                    //no patterns, no need to parse
              
                }
                return null;
            }
            catch (Exception ex)
            {
                return ex;
            }

        }
        #endregion

        #region Get Mails
        public Exception GetExchangeMail(string DocumentPath)
        {
            try
            {
                // Create a folder named "inbox" under current directory
                // to store the email file retrieved.
                string mailbox = String.Format("{0}\\attach_docs\\inbox", DocumentPath);


                if (!System.IO.Directory.Exists(mailbox))
                    System.IO.Directory.CreateDirectory(mailbox);

                using (var client = new ImapClient(new ProtocolLogger(String.Format("{0}\\imap.log", mailbox))))
                {
                    var credentials = new NetworkCredential(MailSetting.EmailAddress, MailSetting.EmailPassword);
                    //var uri = new Uri("imaps://outlook.office365.com");

                    using (var cancel = new CancellationTokenSource())
                    {
                        client.Connect(MailSetting.emailHost, MailSetting.EmailServerPort, MailSetting.EmailRequireSsl);

                        // Note: since we don't have an OAuth2 token, disable
                        // the XOAUTH2 authentication mechanism.
                        //client.AuthenticationMechanisms.Remove("XOAUTH");
                        //client.AuthenticationMechanisms.Remove("XOAUTH2");
                        //client.AuthenticationMechanisms.Remove("NTLM");

                        client.Authenticate(credentials, cancel.Token);

                        // The Inbox folder is always available on all IMAP servers...
                        var inbox = client.Inbox;
                        inbox.Open(FolderAccess.ReadWrite, cancel.Token);

                        foreach (var uid in inbox.Search(SearchQuery.NotSeen))
                        //foreach (var uid in inbox.Search(SearchQuery.DeliveredAfter(DateTime.Now.Date)))
                        {
                            var message = inbox.GetMessage(uid);
                            
                            //if (message.From.Mailboxes.First().Address == "sangam.ligal@gmail.com")
                            //{
                               
                                // Generate an email file name based on date time.
                                System.DateTime d = System.DateTime.Now;
                                System.Globalization.CultureInfo cur = new
                                    System.Globalization.CultureInfo("en-US");
                                string sdate = d.ToString("yyyyMMddHHmmss", cur);
                                string fileName = String.Format("{0}\\{1}({2}).eml",
                                    mailbox, message.MessageId + FileNameSeparator, message.From.Mailboxes.First().Name);
                                
                                message.WriteTo(fileName);

                                string Subject = message.Subject.Replace("'", "''");
                                //string Body = message.HtmlBody.Replace("'", "''");
                                var Body = message.BodyParts.OfType<TextPart>().FirstOrDefault();

                                string From = message.From.Mailboxes.First().Address;
                                string To = "";
                                foreach (MailboxAddress Ma in message.To.Mailboxes)
                                {
                                    To += (To == "" ? Ma.Address : "," + Ma.Address);
                                }

                                string Cc = "";
                                foreach (MailboxAddress Ma in message.Cc.Mailboxes)
                                {
                                    Cc += (Cc == "" ? Ma.Address : "," + Ma.Address);
                                }
                                string Bcc = "";
                                foreach (MailboxAddress Ma in message.Bcc.Mailboxes)
                                {
                                    Bcc += (Bcc == "" ? Ma.Address : "," + Ma.Address);
                                }

                                string new_email_id = "";
                                //string body_content = WebUtility.HtmlEncode(Body.Text.Replace("'", "''")).Replace(System.Environment.NewLine, "\\n");
                                string body_content = Body.Text.Replace("'", "''");
                                
                                SqlCommand cmd = new SqlCommand("spa_email_notes", MailSetting.Connection);
                                cmd.CommandType = CommandType.StoredProcedure;

                                cmd.Parameters.Add(new SqlParameter("@flag", "e"));
                                cmd.Parameters.Add(new SqlParameter("@email_subject", Subject.Replace("'", "''")));
                                cmd.Parameters.Add(new SqlParameter("@notes_text", body_content));
                                cmd.Parameters.Add(new SqlParameter("@send_from", From));
                                cmd.Parameters.Add(new SqlParameter("@send_to", To));
                                cmd.Parameters.Add(new SqlParameter("@send_cc", Cc));
                                cmd.Parameters.Add(new SqlParameter("@send_bcc", Bcc));
                                cmd.Parameters.Add(new SqlParameter("@send_status", "i"));
                                cmd.Parameters.Add(new SqlParameter("@active_flag", "y"));
                                cmd.Parameters.Add(new SqlParameter("@email_type", "i"));
                                cmd.Parameters.Add(new SqlParameter("@process_id", message.MessageId));
                                SqlParameter retval = cmd.Parameters.Add("@output_value", SqlDbType.VarChar);
                                retval.Direction = ParameterDirection.ReturnValue;


                                    
                                SqlDataReader reader = cmd.ExecuteReader();

                                if (!reader.IsClosed)
                                    reader.Close();

                                new_email_id = cmd.Parameters["@output_value"].Value.ToString();

                                Exception ex = SaveAttachment(message, mailbox, new_email_id);
                                if (ex != null)
                                    throw ex;
                                   
                                ex = ParseEmail(new_email_id, Subject, body_content);
                                if (ex != null)
                                    throw ex;
                                
                                inbox.AddFlags(uid, MessageFlags.Seen, true);
                                //inbox.AddFlags(new UniqueId[] { uid }, MessageFlags.Deleted, true);
                                
                            //}
                        }
                        client.Disconnect(true, cancel.Token);
                    }
                }
                return null;
            }
            catch (Exception ex)
            {
                return ex;
            }
        }
        #endregion

        #region Delete Mails
        public Exception DeleteExchangeMail(string DocumentPath, string messageId)
        {
            try
            {
                string mailbox = String.Format("{0}\\attach_docs\\inbox", DocumentPath);
                using (var client = new ImapClient(new ProtocolLogger(String.Format("{0}\\imap.log", mailbox))))
                {
                    var credentials = new NetworkCredential(MailSetting.EmailAddress, MailSetting.EmailPassword);
                    //var uri = new Uri("imaps://outlook.office365.com");

                    using (var cancel = new CancellationTokenSource())
                    {
                        client.Connect(MailSetting.emailHost, MailSetting.EmailServerPort, MailSetting.EmailRequireSsl);

                        // Note: since we don't have an OAuth2 token, disable
                        // the XOAUTH2 authentication mechanism.
                        //client.AuthenticationMechanisms.Remove("XOAUTH");
                        //client.AuthenticationMechanisms.Remove("XOAUTH2");
                        //client.AuthenticationMechanisms.Remove("NTLM");

                        client.Authenticate(credentials, cancel.Token);

                        // The Inbox folder is always available on all IMAP servers...
                        var inbox = client.Inbox;
                        inbox.Open(FolderAccess.ReadWrite, cancel.Token);

                        var uids = inbox.Search(SearchQuery.HeaderContains("Message-Id", messageId));
                        inbox.AddFlags(uids, MessageFlags.Deleted, true);

                        inbox.Expunge(uids);


                        client.Disconnect(true, cancel.Token);

                        return null;
                    }
                }
            }
            catch (SqlException ex)
            {
                return ex;
            }
        }
        #endregion

    }
}
