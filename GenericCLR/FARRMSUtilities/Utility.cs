using Ionic.Zip;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Schema;
using System.Xml.Xsl;

namespace FARRMSUtilities
{
    public class Reflection
    {
        public void FillObjectWithProperty(ref object objectTo, string propertyName, object propertyValue,
            Object[] index)
        {
            Type tOb2 = objectTo.GetType();
            tOb2.GetProperty(propertyName).SetValue(objectTo, propertyValue, null);
        }
    }

    /// <summary>
    /// Miscelleanous object method extension
    /// </summary>
    public static class Utility
    {
        #region File Handling Storedprocedures
        /// <summary>
        /// Moves folder and its contents to destination path
        /// </summary>
        /// <param name="sourceFolder">Source Folder to move</param>
        /// <param name="destinationPath">Full destination path where source folder will be moved</param>
        /// <param name="result">returs 1 or failure message</param>
        public static void MoveFolder(string sourceFolder, string destinationPath, out string result)
        {
            string[] folderName = sourceFolder.ToString().Split('\\');
            string f = folderName[folderName.Count() - 1];
            try
            {
                destinationPath = destinationPath + "\\" + f;
                System.IO.Directory.Move(sourceFolder.ToString(), destinationPath.ToString());
                result = "1";
            }
            catch (Exception ex)
            {
                ex.LogError("Move Folder", sourceFolder.ToString() + "|" + destinationPath.ToString());
                result = ex.Message;
            }
        }
        /// <summary>
        /// Move file to destination
        /// </summary>
        /// <param name="sourceFile">Source filename to move</param>
        /// <param name="destinationFile">Destination filename</param>
        /// <param name="result">returs 1 or failure message</param>
        public static void MoveFile(string sourceFile, string destinationFile, out string result)
        {
            if (!System.IO.File.Exists(sourceFile))
                result = "-1";
            try
            {
                if (System.IO.File.Exists(destinationFile))
                    System.IO.File.Delete(destinationFile);
                System.IO.File.Move(sourceFile, destinationFile);
                result = "1";
            }
            catch (Exception ex)
            {
                ex.LogError("Move File", sourceFile + "|" + destinationFile + "|" + ex.Message);
                result = ex.Message;
            }
        }
        /// <summary>
        /// Copy source file to destination
        /// </summary>
        /// <param name="sourceFile">Source filename</param>
        /// <param name="destinationFile">Destination filename</param>
        /// <param name="result">returs 1 or failure message</param>
        public static void CopyFile(string sourceFile, string destinationFile, out string result)
        {
            if (!System.IO.File.Exists(sourceFile))
                result = "-1";
            try
            {
                System.IO.File.Copy(sourceFile, destinationFile);
                result = "1";
            }
            catch (Exception ex)
            {
                ex.LogError("Copy File", sourceFile + "|" + destinationFile + "|" + ex.Message);
                result = ex.Message;
            }
        }
        /// <summary>
        /// Moves source file to folder
        /// </summary>
        /// <param name="sourceFile">Source filename to move</param>
        /// <param name="destinationFolderPath">Destination folder</param>
        /// <param name="result">returns -1 -> source file doesnt exist, -2 </param>
        public static void MoveFileToFolder(string sourceFile, string destinationFolderPath, out string result)
        {
            if (!System.IO.File.Exists(sourceFile))
                result = "-1";
            if (!System.IO.Directory.Exists(destinationFolderPath))
            {
                string[] pathParts = destinationFolderPath.Split(new string[] { "\\" }, StringSplitOptions.RemoveEmptyEntries);

                string path = pathParts[0];
                if (destinationFolderPath.StartsWith("\\"))
                    path = "\\\\" + pathParts[0];
                for (int i = 1; i < pathParts.Length; i++)
                {
                    path += "\\" + pathParts[i];
                    if (!Directory.Exists(path))
                        Directory.CreateDirectory(path);
                }
            }

            try
            {
                string fileName = Path.GetFileName(sourceFile);
                string destinationFile = destinationFolderPath + @"\" + fileName;
                if (destinationFolderPath.Substring(destinationFolderPath.Length - 1, 1) == @"\")
                    destinationFile = destinationFolderPath + fileName;

                System.IO.File.Move(sourceFile, destinationFile);
                result = "1";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Move File To Folder", sourceFile + "|" + destinationFolderPath + "|" + ex.Message);
            }
        }

        /// <summary>
        /// Create new folder
        /// </summary>
        /// <param name="folderPath">Folder path where new folder will be created.</param>
        /// <param name="result">1 or failure message</param>
        public static void CreateFolder(string folderPath, out string result)
        {
            try
            {

                if (!System.IO.Directory.Exists(folderPath))
                {
                    string[] pathParts = folderPath.Split(new string[] { "\\" }, StringSplitOptions.RemoveEmptyEntries);

                    string path = pathParts[0];
                    if (folderPath.StartsWith("\\"))
                        path = "\\\\" + pathParts[0];
                    for (int i = 1; i < pathParts.Length; i++)
                    {
                        path += "\\" + pathParts[i];
                        if (!Directory.Exists(path))
                            Directory.CreateDirectory(path);
                    }
                }

                result = "1";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Create Folder", folderPath + "|" + ex.Message);
            }

        }
        /// <summary>
        /// Create new file
        /// </summary>
        /// <param name="fileName">Filename to create</param>
        /// <param name="result">1 or failure message</param>
        public static void CreateFile(string fileName, out string result)
        {
            try
            {
                if (System.IO.File.Exists(fileName))
                {
                    DeleteFile(fileName, out result);
                }
                using (FileStream fs = System.IO.File.Create(fileName))
                    result = "1";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Create File", fileName + "|" + ex.Message);
            }

        }

        /// <summary>
        /// Write string contents to file
        /// </summary>
        /// <param name="content">Content to write</param>
        /// <param name="appendContent">y for appending content to file else write content omitting the old one</param>
        /// <param name="fileName">Full filename</param>
        /// <param name="result">returns 1 for success else failure </param>
        public static void WriteToFile(string content, string appendContent, string fileName, out string result)
        {
            bool append = appendContent.ToLower().Replace("y", "1") == "1";

            try
            {
                if (!append)
                {
                    if (System.IO.File.Exists(fileName))
                    {
                        System.IO.File.Delete(fileName);
                        using (System.IO.FileStream fs = new FileStream(fileName, FileMode.Create)) { }
                        using (StreamWriter sw = new StreamWriter(fileName, append))
                        {
                            sw.Write(content);
                        }
                    }
                    else
                    {
                        using (System.IO.FileStream fs = new FileStream(fileName, FileMode.Create)) { }
                        using (StreamWriter sw = new StreamWriter(fileName, append))
                        {
                            sw.Write(content);
                        }
                    }
                }
                else
                {
                    using (StreamWriter sw = new StreamWriter(fileName, append))
                    {
                        sw.Write(content);
                    }
                }
                result = "1";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Write To File", content + "|" + appendContent + "|" + fileName + "|" + ex.Message);
                throw;
            }
        }


        /// <summary>
        /// Delete file
        /// </summary>
        /// <param name="fileName">Filename to delete</param>
        /// <param name="result">returns 1 for success, -1 if file doesnt exist else failure</param>
        public static void DeleteFile(string fileName, out string result)
        {
            string file = fileName.ToString();
            if (!System.IO.File.Exists(file))
                result = "-1";
            try
            {
                System.IO.File.Delete(file);
                result = "1";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Delete File", fileName.ToString() + ";" + result);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="folderPath"></param>
        /// <param name="result"></param>
        public static void DeleteFolder(string folderPath, out string result)
        {
            string folder = folderPath.ToString();
            if (!System.IO.Directory.Exists(folder))
                result = "-1";
            try
            {
                System.IO.Directory.Delete(folder, true);
                result = "1";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Delete Folder", folderPath.ToString() + "|" + ex.Message);
            }
        }
        #endregion

        #region Compression
        /// <summary>
        /// Compress folder 
        /// </summary>
        /// <param name="folderPath">Source flder to compress</param>
        /// <param name="zipFileName">Compressed filename</param>
        /// <param name="result">returns 1 for success else failure</param>
        public static void CompressFolder(string folderPath, string zipFileName, out string result)
        {
            try
            {
                string[] files = System.IO.Directory.GetFiles(folderPath.ToString());
                using (ZipFile zip = new ZipFile())
                {
                    foreach (string file in files)
                    {
                        ZipEntry entry = zip.AddFile(file);
                    }
                    zip.Save(zipFileName.ToString());
                }
                result = "1";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Compress Folder", folderPath + "|" + zipFileName + "|" + ex.Message);
            }
        }

        /// <summary>
        /// Compress file
        /// </summary>
        /// <param name="filename">Source filename to compress</param>
        /// <param name="zipFileName">Compressed zip filename</param>
        /// <param name="result">returns 1 for success else failure</param>
        public static void CompressFile(string filename, string zipFileName, out string result)
        {
            try
            {
                using (ZipFile zip = new ZipFile(zipFileName))
                {
                    ZipEntry entry = zip.AddFile(filename, "");

                    zip.Save();
                    result = "1";
                }

            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Compress File", filename + "|" + zipFileName + "|" + ex.Message);
            }
        }
        #endregion


        public static List<string> stackProcess = new List<string>();
        /// <summary>
        /// Crete xml document table / select query / sp outpout
        /// </summary>
        /// <param name="tableName">Table name / Sql query</param>
        /// <param name="xmlNamespace">Xml namespace to  include in xml doc</param>
        /// <param name="reportName">report name included in xml doc</param>
        /// <param name="standardXml">-100000 for standard node based xml, -100001 for attribute baed xml</param>
        /// <param name="filename">xml file name</param>
        /// <param name="compressFile">y for compressing xml document else file wont be compressed</param>
        /// <param name="result">true for success else failur</param>
        public static void CreateXMLDocument(string tableOrSP, string xmlNamespace, string reportName, string standardXml, string filename, string compressFile, out string result)
        {
            try
            {
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL50\INSTANCE2016;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))

                {
                    cn.Open();
                    string query = tableOrSP;
                    if (!tableOrSP.ToLower().Trim().StartsWith("select"))
                        query = "SELECT * FROM " + tableOrSP;

                    if (tableOrSP.ToLower().Trim().StartsWith("exec"))
                        query = tableOrSP;

                    using (SqlCommand cmd = new SqlCommand(query, cn))
                    {
                        using (SqlDataReader rd = cmd.ExecuteReader())
                        {
                            using (StreamWriter sw = new StreamWriter(filename))
                            {
                                bool attributeBase = true;
                                if (standardXml.Trim() == "-100000")
                                    attributeBase = false;
                                else if (standardXml.Trim() == "-100001")
                                    attributeBase = true;

                                PsXml psXml = new PsXml(rd, attributeBase, sw, reportName, xmlNamespace);
                                psXml.CreateXml();
                                sw.Close();
                            }
                        }
                    }
                    cn.Close();
                }
                //  Compress File
                if (compressFile.ToString().ToLower() == "y")
                {
                    string extension = Path.GetExtension(filename);
                    FileCompression(filename, filename.ToLower().Replace(extension, ".zip"));
                }
                result = "true";
                return;
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Create XML Doucment", tableOrSP + "|" + xmlNamespace + "|" + reportName + "|" + standardXml + "|" + filename + "|" + "|" + compressFile + "|" + result);
            }
        }

        /// <summary>
        /// Create process table
        /// </summary>
        /// <returns></returns>
        public static DataTable CreateProcessTable(string processTableName, string[] columns, SqlConnection sqlConnection)
        {
            DataTable dt = new DataTable(processTableName.Split('.').Last());
            foreach (var item in columns)
            {
                dt.Columns.Add(new DataColumn(item));
            }

            string createTableSql = "IF OBJECT_ID('" + processTableName + "') IS NOT NULL DROP TABLE " +
                                    processTableName;

            Utility.ExecuteQuery(createTableSql, sqlConnection);

            createTableSql = "CREATE TABLE " + processTableName + "(";

            for (int i = 0; i < dt.Columns.Count; i++)
            {
                createTableSql += "[" + dt.Columns[i].ColumnName + "] NVARCHAR(1024),";
            }
            createTableSql = createTableSql.TrimEnd(',') + ")";
            Utility.ExecuteQuery(createTableSql, sqlConnection);

            return dt;
        }

        /*
         * Transform XML according to the xslt supplied        
         * effFilePath = File Path of Source XML file
         * xsltPath = Path of XSL file
         * filePath = Destination of Final XML file
         * compressFile = Set y To compress file
         * removeEmptyNodes = Remove empty nodes if the value is set to y
         */
        public static void TransformXML(string effFilePath, string xsltPath, string filePath, string compressFile, string removeEmptyNodes, out string result)
        {
            try
            {
                XslCompiledTransform xslt = new System.Xml.Xsl.XslCompiledTransform();
                xslt.Load(xsltPath);
                xslt.Transform(effFilePath, filePath);

                if (removeEmptyNodes.ToString().ToLower() == "y")
                {
                    XElement doc = XElement.Load(filePath);

                    foreach (XElement child in doc.Descendants().Reverse())
                    {
                        if (!child.HasElements && string.IsNullOrEmpty(child.Value))
                            child.Remove();
                    }

                    doc.Save(filePath);
                }

                string xsdFilePath = xsltPath.Replace(".xsl", ".xsd");

                if (File.Exists(xsdFilePath))
                {
                    string status = ValidateXmlAgaintSchema(filePath, xsdFilePath);
                    result = status;
                    //return;
                }
                else
                {
                    result = "true";
                }

                //  Compress File
                if (compressFile.ToString().ToLower() == "y")
                {
                    string extension = Path.GetExtension(filePath);
                    FileCompression(filePath, filePath.ToLower().Replace(extension, ".zip"));
                }

                if (result != "true")
                    throw new Exception(result);
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Transform XML", effFilePath + "|" + xsltPath + "|" + filePath + "|" + result);
            }
        }

        /// <summary>
        /// Validated xml contents against xml xsd
        /// </summary>
        /// <param name="xmlPath">Xml document</param>
        /// <param name="xsdPath">Xsd path</param>
        /// <returns></returns>
        public static string ValidateXmlAgaintSchema(string xmlPath, string xsdPath)
        {
            //Load the XmlSchemaSet.
            XmlSchemaSet schemaSet = new XmlSchemaSet();
            schemaSet.Add(null, xsdPath);

            //Validate the file using the schema stored in the schema set.
            //Any elements belonging to the namespace "urn:cd-schema" generate
            //a warning because there is no schema matching that namespace.

            XmlSchema compiledSchema = null;

            foreach (XmlSchema schema in schemaSet.Schemas())
            {
                compiledSchema = schema;
            }

            stackProcess.Add("");

            XmlReaderSettings settings = new XmlReaderSettings();
            settings.Schemas.Add(compiledSchema);
            settings.ValidationFlags |= XmlSchemaValidationFlags.ReportValidationWarnings;
            settings.ValidationEventHandler += new ValidationEventHandler(XmlValidationCallBack);
            settings.ValidationType = ValidationType.Schema;

            //Create the schema validating reader.
            XmlReader vreader = XmlReader.Create(xmlPath, settings);
            while (vreader.Read()) { }

            //Close the reader.
            vreader.Close();
            string result = stackProcess[0];
            stackProcess.RemoveAt(0);
            return result;
        }

        //Display any warnings or errors.
        private static void XmlValidationCallBack(object sender, ValidationEventArgs args)
        {
            if (args.Severity == XmlSeverityType.Warning)
                stackProcess[0] += args.Message + Environment.NewLine;
            //Console.WriteLine("\tWarning: Matching schema not found.  No validation occurred." + args.Message);
            else
                //Console.WriteLine("\tValidation error: " + args.Message);
                stackProcess[0] += args.Message + Environment.NewLine;
        }

        
        /// <summary>
        /// Compress file
        /// </summary>
        /// <param name="filename">Filename to compress</param>
        /// <param name="zipFileName">Output compressed zip filename</param>
        /// <returns>Success or failure message</returns>
        public static string FileCompression(string filename, string zipFileName)
        {
            try
            {
                using (ZipFile zip = new ZipFile(zipFileName))
                {
                    ZipEntry entry = zip.AddFile(filename, "");

                    zip.Save();
                }
                return "success";
            }
            catch (Exception ex)
            {
                ex.LogError("Compress File", filename + "|" + zipFileName);
                return ex.Message;
            }
        }

        /// <summary>
        /// Get list of serialized objects eqivalent to data reader output
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="list"></param>
        /// <param name="dr"></param>
        /// <returns></returns>
        public static IEnumerable<T> FromDataReader<T>(this IEnumerable<T> list, DbDataReader dr)
        {
            //Instance reflec object from Reflection class coded above
            var reflec = new Reflection();
            //Declare one "instance" object of Object type and an object list
            var lstObj = new List<Object>();

            //dataReader loop
            while (dr.Read())
            {
                //Create an instance of the object needed.
                //The instance is created by obtaining the object type T of the object
                //list, which is the object that calls the extension method
                //Type T is inferred and is instantiated
                Object instance = Activator.CreateInstance(list.GetType().GetGenericArguments()[0]);

                // Loop all the fields of each row of dataReader, and through the object
                // reflector (first step method) fill the object instance with the datareader values
                DataTable dataTable = dr.GetSchemaTable();
                if (dataTable != null)
                    foreach (DataRow drow in dataTable.Rows)
                    {
                        reflec.FillObjectWithProperty(ref instance,
                            drow.ItemArray[0].ToString(), dr[drow.ItemArray[0].ToString()], null);
                    }

                //Add object instance to list
                lstObj.Add(instance);
            }

            var lstResult = new List<T>();
            foreach (Object item in lstObj)
            {
                lstResult.Add((T)Convert.ChangeType(item, typeof(T)));
            }


            return lstResult;
        }
        /// <summary>
        /// Replace special characters with empty string
        /// </summary>
        /// <param name="value">string value to be replaced</param>
        /// <returns></returns>
        public static string ReplaceSpecialCharWithBlank(this string value)
        {
            string[] charStrings = (@"$,#,*,/,\,(,),%,&,@, ").Split(',');
            foreach (string s in charStrings)
            {
                value = value.Replace(s, "");
            }
            return value;
        }

        /// <summary>
        /// Convert object to int
        /// </summary>
        /// <param name="value">object to convert</param>
        /// <returns>int</returns>
        public static int ToInt(this Object value)
        {
            try
            {
                return Convert.ToInt32(value.ToString());
            }
            catch (Exception)
            {
                return 0;
            }
        }
        /// <summary>
        /// Convert object to decimal using decimal parse
        /// </summary>
        /// <param name="value">object to convert</param>
        /// <returns>decimal</returns>
        public static decimal DecimalParse(this Object value)
        {
            try
            {
                return Decimal.Parse(value.ToString(), System.Globalization.NumberStyles.Any);
            }
            catch (Exception)
            {
                return 0;
            }
        }
        /// <summary>
        /// Convert object to decimal
        /// </summary>
        /// <param name="value">object to convert</param>
        /// <returns>decimal</returns>
        public static decimal ToDecimal(this Object value)
        {
            try
            {
                return Convert.ToDecimal(value);
            }
            catch (Exception)
            {
                return 0;
            }
        }
        /// <summary>
        /// convert object to double
        /// </summary>
        /// <param name="value">object to convert</param>
        /// <returns>double</returns>
        public static double ToDouble(this Object value)
        {
            try
            {
                return Convert.ToDouble(value.ToString());
            }
            catch (Exception)
            {
                return 0;
            }
        }
        /// <summary>
        /// Override Session contenxt db user context info connection user. Because inner sp could not resovle session context user.
        /// </summary>
        /// <param name="sqlCommand">SqlCommand</param>
        /// <returns></returns>
        public static SqlDataReader ExecuteSessionReader(this SqlCommand sqlCommand)
        {
            string sessionContextUser = "";
            string sessionContextQuery = "";
            using (var cmd = new SqlCommand("SELECT SESSION_CONTEXT(N'DB_USER')", sqlCommand.Connection))
            {
                using (SqlDataReader rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        sessionContextUser = rd[0].ToString();
                        //StoredProcedure.SendMessage(sessionContextUser, true);
                    }
                }
                if (!string.IsNullOrEmpty(sessionContextUser))
                    sessionContextQuery = "DECLARE @BinaryUserId VARBINARY(128) = CAST(SESSION_CONTEXT(N'DB_USER') AS VARBINARY(128));SET CONTEXT_INFO @BinaryUserId;";
                //else
                //{
                //    StoredProcedure.SendMessage("sessionContextUser is nullorempty", true);
                //}
                sqlCommand.CommandText = sessionContextQuery + sqlCommand.CommandText;
                return sqlCommand.ExecuteReader();
            }

        }

        /// <summary>
        /// Dump datatable to process table, process table schema should be exact according to datatable columns colllection
        /// </summary>
        /// <param name="dataTable">System.Data.DataTable</param>
        /// <param name="processTableName">Valid process table with columns</param>
        /// <param name="sqlConnection">Valid opened sqlconnection</param>
        /// <param name="selectColumns">Column list that will be included while dumping the records</param>
        public static void DumpDataTableToProcessTable(this DataTable dataTable, string processTableName, SqlConnection sqlConnection, string selectColumns = null)
        {
            string sql = "SELECT * FROM " + processTableName;
            if (!string.IsNullOrEmpty(selectColumns))
                sql = "SELECT " + selectColumns + " FROM " + processTableName;
            //  Mark datatable rows added, added if datatable has been dervied sql datareader
            //  If rows are not marked as added rows will not be copied to process table.
            foreach (DataRow row in dataTable.Rows)
                row.SetAdded();

            //  Copy data table
            using (var adapter = new SqlDataAdapter(sql, sqlConnection))
            using (var builder = new SqlCommandBuilder(adapter))
            {
                adapter.InsertCommand = builder.GetInsertCommand();
                adapter.Update(dataTable);
            }
        }

        /// <summary>
        /// Get storedprocedure output as SqlDataReader
        /// </summary>
        /// <param name="connection">Valid SqlConnection</param>
        /// <param name="storedProcedureName">storedprocedure name</param>
        /// <param name="parameterWithValues">Parameter name value collection</param>
        /// <returns>SqlDataReader</returns>
        public static SqlDataReader ExecuteStoredProcedureWithReturn(this SqlConnection connection, string storedProcedureName, string parameterWithValues)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand(storedProcedureName, connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    
                    SqlParameter[] parameters = BuildParameterValues(parameterWithValues);
                    foreach (SqlParameter p in parameters)
                    {
                        cmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                    }

                    SqlDataReader rd = cmd.ExecuteReader();
                    if (rd.HasRows)
                    {
                        rd.Read();
                    }
                    return rd;

                }
            }
            catch
            {
                return null;
            }

        }

        /// <summary>
        /// Execute stored procedure
        /// </summary>
        /// <param name="storedProcedureName">Storedprocedure name</param>
        /// <param name="parameterWithValues">sp paramer name value</param>
        /// <param name="connection">Valid sqlconnection</param>
        public static void ExecuteStoredProcedure(this SqlConnection connection,  string storedProcedureName, string parameterWithValues)
        {
            using (SqlCommand cmd = new SqlCommand(storedProcedureName, connection))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                SqlParameter[] parameters = BuildParameterValues(parameterWithValues);
                foreach (SqlParameter p in parameters)
                {
                    cmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                }
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Execute sql quries/adhoc queries
        /// </summary>
        /// <param name="query">Query / AdHoc Query</param>
        /// <param name="sqlConnection">Valid SqlConnection</param>
        public static void ExecuteQuery(string query, SqlConnection sqlConnection)
        {
            SqlCommand cmd = new SqlCommand(query, sqlConnection);
            cmd.ExecuteNonQuery();
        }

        public static void ExecuteQuery(this SqlConnection sqlConnection, string query)
        {
            SqlCommand cmd = new SqlCommand(query, sqlConnection);
            cmd.ExecuteNonQuery();
        }

        /// <summary>
        /// Get ssrs parameter value array from report parameter
        /// </summary>
        /// <param name="reportParameter">ssrs report filter</param>
        /// <returns></returns>
        public static SqlParameter[] BuildParameterValues(string reportParameter)
        {

            string[] parameters = reportParameter.Split(',');
            int paramCount = reportParameter.Split(':').Count() - 1;

            string[] newparameters = new string[paramCount];
            int index = 0;
            foreach (string p in parameters)
            {
                if (p.Contains(':'))
                {
                    newparameters[index] = p;
                    index++;
                }
                else
                    newparameters[index - 1] += "," + p;
            }

            SqlParameter[] parameterValues = new SqlParameter[newparameters.Count()];
            for (int i = 0; i < newparameters.Count(); i++)
            {
                string[] paramValue = newparameters[i].Split(':');
                parameterValues[i] = new SqlParameter();
                parameterValues[i].ParameterName = paramValue[0];
                parameterValues[i].Value = paramValue[1];
            }

            return parameterValues;
        }

        /// <summary>
        /// Log exception message , stactrace information to clr_error_log table
        /// </summary>
        /// <param name="ex">Exception thrown from catch</param>
        /// <param name="eventLogDescription">Event description</param>
        /// <param name="parameterValues">Parameter name value splitted by pipe (|)</param>
        /// <param name="stackProcess">stack process list if available</param>
        /// <param name="processId">Process id</param>
        public static void LogError(this Exception ex, string eventLogDescription, string parameterValues, List<string> stackProcess = null, string processId = null)
        {
            if (processId == null)
            {
                processId = Guid.NewGuid().ToString().Replace("-", "").ToUpper();
            }
            XDocument xDoc = new XDocument();
            if (stackProcess != null)
            {
                if (stackProcess.Count > 0)
                {
                    XElement element = new XElement("ProcessLog");
                    int i = 1;
                    foreach (string log in stackProcess)
                    {
                        XElement elementLog = new XElement(new XElement("Log", new XElement("Id", i), new XElement("Description", log)));
                        element.Add(elementLog);
                        i++;
                    }
                    xDoc.Add(element);
                }
            }

            StackTrace st = new StackTrace();
            StackFrame sf = st.GetFrame(1);

            string assemblyMethod = sf.GetMethod().Name;

            System.Reflection.ParameterInfo[] parameters = sf.GetMethod().GetParameters(); // ex.TargetSite.GetParameters();

            string prametersWithValue = "";
            string param = "";
            foreach (System.Reflection.ParameterInfo p in parameters)
            {
                param = p.Name;
                //  Check parameter values is available according to parameter definition
                if (p.IsOut)
                    param = "out " + p.Name;
                if (parameterValues.Split('|').Count() >= (p.Position + 1))
                    prametersWithValue += param + "=" + parameterValues.Split('|')[p.Position] + ",";
                else
                    prametersWithValue += param + "=" + "<undefined>" + ",";

            }
            prametersWithValue = prametersWithValue.TrimEnd(',');


            string sqlCmd = "";
            //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDD10\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
            using (SqlConnection cn = new SqlConnection("Context Connection = True"))
            {
                cn.Open();

                using (SqlCommand cmd = new SqlCommand(sqlCmd, cn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "spa_clr_error_log";
                    cmd.Parameters.AddWithValue("flag", "i");
                    cmd.Parameters.AddWithValue("event_log_description", eventLogDescription);
                    cmd.Parameters.AddWithValue("assembly_method", assemblyMethod);
                    cmd.Parameters.AddWithValue("message", ex.Message);

                    if (ex.InnerException != null)
                    cmd.Parameters.AddWithValue("inner_exception", ex.InnerException.ToString());

                    cmd.Parameters.AddWithValue("stack_trace", ex.StackTrace);
                    cmd.Parameters.AddWithValue("param", prametersWithValue);
                    cmd.Parameters.AddWithValue("process_id", processId);
                    cmd.Parameters.AddWithValue("process_log", xDoc.ToString());
                    try
                    {
                        cmd.ExecuteNonQuery();
                    }
                    catch (Exception ex1)
                    {

                    }

                }
            }
        }

    }
}
