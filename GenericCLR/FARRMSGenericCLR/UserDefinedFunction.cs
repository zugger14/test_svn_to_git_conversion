using System;
using System.Collections;
using System.Globalization;
using System.Security.AccessControl;
using System.Text;
using System.IO;
using System.Data.SqlTypes;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using Jint;
using Microsoft.SqlServer.Server;
using DocumentFormat.OpenXml.Wordprocessing;
using System.Linq;

using A = DocumentFormat.OpenXml.Drawing;
using DW = DocumentFormat.OpenXml.Drawing.Wordprocessing;
using PIC = DocumentFormat.OpenXml.Drawing.Pictures;
using FARRMS.WebServices;
using System.Collections.Generic;

namespace FARRMSGenericCLR
{
    struct Update
    {
        public string Query { get; set; }
        public string ParseError { get; set; }
    }

    /// <summary>
    /// CLR methods colection scalar / tabular function
    /// </summary>
    public class UserDefinedFunction
    {
        /// <summary>
        /// Encrpyt string data
        /// </summary>
        /// <param name="plainText">string to encrypt</param>
        /// <param name="key">encryption key</param>
        /// <returns>Encrypted string</returns>
        public static string EncryptString(SqlString plainText, SqlString key)
        {
            byte[] encrypted;
            string cipherText;
            using (var rijAlg = new RijndaelManaged())
            {
                rijAlg.BlockSize = 128;
                rijAlg.Key = Encoding.UTF8.GetBytes(key.ToString());
                rijAlg.Mode = CipherMode.ECB;
                rijAlg.Padding = PaddingMode.Zeros;
                rijAlg.IV = new byte[] { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

                ICryptoTransform encryptor = rijAlg.CreateEncryptor(rijAlg.Key, rijAlg.IV);
                using (var msEncrypt = new MemoryStream())
                using (var csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write))
                {
                    using (var swEncrypt = new StreamWriter(csEncrypt))
                        swEncrypt.Write(plainText.ToString());
                    encrypted = msEncrypt.ToArray();
                }
            }
            cipherText = Convert.ToBase64String(encrypted);
            return cipherText;
        }
        /// <summary>
        /// Decrpyt string data
        /// </summary>
        /// <param name="cipherString">string to decrypt</param>
        /// <param name="key">deccryption key</param>
        /// <returns>Decrypted string</returns>
        public static string DecryptString(SqlString cipherString, SqlString key)
        {
            string plaintext;
            byte[] cipherText = Convert.FromBase64String(cipherString.ToString());
            using (var rijAlg = new RijndaelManaged())
            {
                rijAlg.BlockSize = 128;
                rijAlg.Key = Encoding.UTF8.GetBytes(key.ToString());
                rijAlg.Mode = CipherMode.ECB;
                rijAlg.Padding = PaddingMode.Zeros;
                rijAlg.IV = new byte[] { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

                ICryptoTransform decryptor = rijAlg.CreateDecryptor(rijAlg.Key, rijAlg.IV);
                using (var msDecrypt = new MemoryStream(cipherText))
                using (var csDecrypt = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Read))
                using (var srDecrypt = new StreamReader(csDecrypt))
                    plaintext = srDecrypt.ReadToEnd();
            }
            return plaintext;
        }
        /// <summary>
        /// Validates if provided string is date format
        /// </summary>
        /// <param name="text">string data</param>
        /// <returns>true/false</returns>
        public static SqlBoolean IsValidDatePattern(SqlString text)
        {
            string txtToMatch = text.ToString();
            MatchCollection mc = Regex.Matches(txtToMatch, @"\d\d\d\d-\d\d-\d\d");
            if (mc.Count > 0)
            {
                return true;
            }

            return false;
        }
        /// <summary>
        /// Validates suplied string is vaid deliver point
        /// </summary>
        /// <param name="text">String to validate</param>
        /// <returns>True/False</returns>
        public static SqlBoolean IsValidDeliveryPoint(SqlString text)
        {
            string txtToMatch = text.ToString();
            MatchCollection mc = Regex.Matches(txtToMatch, @"[0-9][0-9][XYZTWV].+");
            if (mc.Count > 0)
            {
                return true;
            }
            return false;
        }

        /// <summary>
        /// Encode string data to Base64SHA256
        /// </summary>
        /// <param name="data">Data to encode</param>
        /// <returns>Encoded string</returns>
        public static SqlString BASE64SHA256(SqlString data)
        {
            var encoding = new ASCIIEncoding();
            byte[] messageBytes = encoding.GetBytes(data.ToString());
            using (var hmacsha256 = new SHA256Managed())
            {
                byte[] hashmessage = hmacsha256.ComputeHash(messageBytes);
                return
                    Convert.ToString(Convert.ToBase64String(hashmessage))
                        .Replace("+", "A")
                        .Replace("/", "B")
                        .Replace("=", "C")
                        .Replace("-", "D");
            }
        }

        /// <summary>
        /// Format Float to string
        /// </summary>
        /// <param name="number"></param>
        /// <returns></returns>
        public static SqlString SpecialNumberFormat(string number)
        {
            double valueParsed;
            if (Double.TryParse(number.Trim(), NumberStyles.Any, CultureInfo.CurrentCulture, out valueParsed))
            {
                valueParsed = Math.Round(valueParsed, 4);
                return valueParsed.ToString("N4").Replace(",", "");
            }
            return number;
        }
        /// <summary>
        /// Replace openxml document with valid custom xml document
        /// </summary>
        /// <param name="fileName"></param>
        /// <param name="customXML"></param>
        private void ReplaceCustomXML(string fileName, string customXML)
        {
            using (WordprocessingDocument wordDoc = WordprocessingDocument.Open(fileName, true))
            {
                MainDocumentPart mainPart = wordDoc.MainDocumentPart;
                mainPart.DeleteParts<CustomXmlPart>(mainPart.CustomXmlParts);
                //Add a new customXML part and then add the content. 
                CustomXmlPart customXmlPart = mainPart.AddCustomXmlPart(CustomXmlPartType.CustomXml);
                //Copy the XML into the new part. 
                using (StreamWriter ts = new StreamWriter(customXmlPart.GetStream())) ts.Write(customXML);
            }
        }

        
        //public Microsoft.Office.Interop.Word.Document wordDocument { get; set; }
        /// <summary>
        /// Convert data pdf document using word interop
        /// </summary>
        /// <param name="input"></param>
        /// <param name="output"></param>
        public static void ConverttoPDF(string input, string output)
        {
            // Create an instance of Word.exe
           /*
            Word._Application oWord = new Word.Application();

            // Make this instance of word invisible (Can still see it in the taskmgr).
            oWord.Visible = false;

            // Interop requires objects.
            object oMissing = System.Reflection.Missing.Value;
            object isVisible = true;
            object readOnly = true;
            object oInput = input;
            object oOutput = output;
            object oFormat = WdSaveFormat.wdFormatPDF;

            // Load a document into our instance of word.exe
            Word._Document oDoc = oWord.Documents.Open(ref oInput, ref oMissing, ref readOnly, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref isVisible, ref oMissing, ref oMissing, ref oMissing, ref oMissing);

            // Make this document the active document.
            oDoc.Activate();

            // Save this document in Word 2003 format.
            oDoc.SaveAs(ref oOutput, ref oFormat, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing);

            // Always close Word.exe.
            oWord.Quit(ref oMissing, ref oMissing, ref oMissing);
            * */
        }




        #region File Handling Functions
        /// <summary>
        /// Validates if file is locked or used by another process
        /// </summary>
        /// <param name="fileName">Spurce filename</param>
        /// <returns>True/False</returns>
        public static bool IsFileLocked(string fileName)
        {
            FileInfo file = new FileInfo(fileName);
            FileStream stream = null;
            try
            {
                stream = file.Open(FileMode.Open, FileAccess.Read, FileShare.None);
            }
            catch (IOException)
            {
                //the file is unavailable because it is:
                //still being written to
                //or being processed by another thread
                //or does not exist (has already been processed)
                return true;
            }
            finally
            {
                if (stream != null)
                    stream.Close();
            }

            //file is not locked
            return false;
        }

        /// <summary>
        /// Read text file contents and send output to sqlserver
        /// </summary>
        /// <param name="fileName">Source filename</param>
        /// <returns>Text output of file</returns>
        public static string ReadFileContents(SqlString fileName)
        {
            string file = fileName.ToString();
            string contents;
            if (!File.Exists(file))
                return "-1";
            using (StreamReader reader = new StreamReader(file))
            {
                contents = reader.ReadToEnd();
            }
            return contents;
        }

        /// <summary>
        /// CLR table valued function for returning list of files from folder
        /// </summary>
        /// <param name="folderPath">Folder location</param>
        /// <param name="fileExtention">File extension to filter. eg. *.txt will list text files only.</param>
        /// <param name="allDirectories"></param>
        /// <returns></returns>
        [SqlFunction(FillRowMethodName = "FillRow", TableDefinition = "filename NVARCHAR(2048)")]
        public static IEnumerable ListFiles(SqlString folderPath, SqlString fileExtention, SqlString allDirectories)
        {
            string[] files = null;
            if (allDirectories.ToString().ToLower()== "y")
                files = Directory.GetFiles(folderPath.ToString(), fileExtention.ToString(),SearchOption.AllDirectories);
            else
                files = Directory.GetFiles(folderPath.ToString(), fileExtention.ToString(),
                    SearchOption.TopDirectoryOnly);
            return files;
        }

        public static void FillRow(object row, out SqlString str)
        {
            str = new SqlString((string)row);
        }

        /// <summary>
        /// Check file existence
        /// </summary>
        /// <param name="fileName">Filename</param>
        /// <returns>True / False</returns>
        public static SqlInt16 FileExists(SqlString fileName)
        {
            string file = fileName.ToString();
            if (File.Exists(file))
                return 1;
            return 0;
        }

        /// <summary>
        /// Validates if folder has write permission
        /// </summary>
        /// <param name="folderPath">Full Folder path </param>
        /// <returns>True / False</returns>
        public static SqlInt16 CheckWriteAccessToFolder(string folderPath)
        {
            try
            {
                if (!Directory.Exists(folderPath))
                    return -1;
                DirectorySecurity ds = Directory.GetAccessControl(folderPath);
                return 1;
            }
            catch (UnauthorizedAccessException)
            {
                return 0;
            }
        }
        /// <summary>
        /// Insert picture to document
        /// </summary>
        /// <param name="documentName"></param>
        /// <param name="imageName"></param>
        public static void InsertAPicture(string documentName, string imageName)
        {
            using (WordprocessingDocument wordprocessingDocument =
                WordprocessingDocument.Open(documentName, true))
            {
                MainDocumentPart mainPart = wordprocessingDocument.MainDocumentPart;

                ImagePart imagePart = mainPart.AddImagePart(ImagePartType.Jpeg);

                using (FileStream stream = new FileStream(imageName, FileMode.Open))
                {
                    imagePart.FeedData(stream);
                }

                AddImageToBody(wordprocessingDocument, mainPart.GetIdOfPart(imagePart));
            }
        }

        /// <summary>
        /// Add image
        /// </summary>
        /// <param name="wordDoc"></param>
        /// <param name="relationshipId"></param>
        /// <param name="picture_name"></param>
        private static void AddImageToBody(WordprocessingDocument wordDoc, string relationshipId,
            string picture_name = "Picture 2")
        {
            // Define the reference of the image.
            var element =
                 new Drawing(
                     new DW.Inline(
                         new DW.Extent() { Cx = 990000L, Cy = 792000L },
                         new DW.EffectExtent()
                         {
                             LeftEdge = 0L,
                             TopEdge = 0L,
                             RightEdge = 0L,
                             BottomEdge = 0L
                         },
                         new DW.DocProperties()
                         {
                             Id = (UInt32Value)1U,
                             Name = picture_name
                         },
                         new DW.NonVisualGraphicFrameDrawingProperties(
                             new A.GraphicFrameLocks() { NoChangeAspect = true }),
                         new A.Graphic(
                             new A.GraphicData(
                                 new PIC.Picture(
                                     new PIC.NonVisualPictureProperties(
                                         new PIC.NonVisualDrawingProperties()
                                         {
                                             Id = (UInt32Value)0U,
                                             Name = "New Bitmap Image.jpg"
                                         },
                                         new PIC.NonVisualPictureDrawingProperties()),
                                     new PIC.BlipFill(
                                         new A.Blip(
                                             new A.BlipExtensionList(
                                                 new A.BlipExtension()
                                                 {
                                                     Uri =
                                                       "{28A0092B-C50C-407E-A947-70E740481C1C}"
                                                 })
                                         )
                                         {
                                             Embed = relationshipId,
                                             CompressionState =
                                             A.BlipCompressionValues.Print
                                         },
                                         new A.Stretch(
                                             new A.FillRectangle())),
                                     new PIC.ShapeProperties(
                                         new A.Transform2D(
                                             new A.Offset() { X = 0L, Y = 0L },
                                             new A.Extents() { Cx = 990000L, Cy = 792000L }),
                                         new A.PresetGeometry(
                                             new A.AdjustValueList()
                                         ) { Preset = A.ShapeTypeValues.Rectangle }))
                             ) { Uri = "http://schemas.openxmlformats.org/drawingml/2006/picture" })
                     )
                     {
                         DistanceFromTop = (UInt32Value)0U,
                         DistanceFromBottom = (UInt32Value)0U,
                         DistanceFromLeft = (UInt32Value)0U,
                         DistanceFromRight = (UInt32Value)0U,
                         EditId = "50D07946"
                     });

            // Append the reference to body, the element should be in a Run.
            wordDoc.MainDocumentPart.Document.Body.AppendChild(new Paragraph(new Run(element)));
        }
        


        #endregion

        #region Created method to insert data for webservice to process table

        /// <summary>
        /// Build report manager query
        /// </summary>
        /// <param name="reportRfxParameter">report filter query</param>
        /// <param name="process_id">Process id</param>
        /// <param name="outputToProcTable">y=> adds batch process id</param>
        /// <returns></returns>
        public static string BuildRfxQueryFromReportParameter(string reportRfxParameter, string process_id, string outputToProcTable = "y")
        {
            string[] arr = reportRfxParameter.Split(',');
            var paramset = arr.Where(x => x.ToLower().Contains("paramset_id")).FirstOrDefault();
            string paramset_id = "0";

            if (paramset != null)
            {
                paramset_id = paramset.Split(':')[1];
            }
            string tablix_id = "0";
            var tablix = arr.Where(x => x.ToLower().Contains("item_")).FirstOrDefault();
            if (tablix != null)
            {
                tablix_id = tablix.Split(':')[1];
            }

            string sql = "EXEC spa_rfx_run_sql " + paramset_id + "," + tablix_id;

            int startIndex = 0;
            string filter = "";
            foreach (string s in arr)
            {
                if (s.ToLower().Contains("report_filter"))
                {
                    filter = s.Split(':')[1].TrimStart('\'');
                    break;
                }
                startIndex++;
            }

            for (int i = startIndex + 1; i < arr.Count(); i++)
            {
                if (arr[i].Contains("="))
                    filter += "," + arr[i];
            }
            filter = filter.TrimEnd('\'');
            if (filter == "")
            {
                sql += ",NULL, NULL, 't'";
            }
            else
            {
                sql += ",'" + filter + "', NULL, 't'";
            }

            if (outputToProcTable == "y")
            {
                sql += ", @batch_process_id = '" + process_id + "'";
            }

            return sql;
        }
        #endregion

        #region Jint
        /// <summary>
        /// Parse break down sql trm formula
        /// </summary>
        /// <param name="formula"></param>
        /// <returns></returns>
        public static string FNAParseFormula(string formula)
        {
            JintEngine jint = new JintEngine();
            jint.Run(GetJSCode());
            string result = UrlDecode(jint.CallFunction("parseFormula", formula).ToString());
            return result;
            
            // Below code works with new JINT version
            /*
            Engine jint = new Engine();
            jint.Execute(GetJSCode());
            string result = UrlDecode(jint.Invoke("parseFormula", formula).ToString());
            return result;
             */
        }

        public static string GetJSCode()
        {
            StringBuilder sb =
                new StringBuilder(
                    @"/****************************************Formula Parser JS Code START***********************************************/

        var TOK_TYPE_NOOP      = ""noop"";
        var TOK_TYPE_OPERAND   = ""operand"";
        var TOK_TYPE_FUNCTION  = ""function"";
        var TOK_TYPE_SUBEXPR   = ""subexpression"";
        var TOK_TYPE_ARGUMENT  = ""argument"";
        var TOK_TYPE_OP_PRE    = ""operator-prefix"";
        var TOK_TYPE_OP_IN     = ""operator-infix"";
        var TOK_TYPE_OP_POST   = ""operator-postfix"";
        var TOK_TYPE_WSPACE    = ""white-space"";
        var TOK_TYPE_UNKNOWN = ""unknown"";

        var TOK_SUBTYPE_START       = ""start"";
        var TOK_SUBTYPE_STOP        = ""stop"";

        var TOK_SUBTYPE_TEXT        = ""text"";
        var TOK_SUBTYPE_NUMBER      = ""number"";
        var TOK_SUBTYPE_LOGICAL     = ""logical"";
        var TOK_SUBTYPE_ERROR       = ""error"";
        var TOK_SUBTYPE_RANGE       = ""range"";

        var TOK_SUBTYPE_MATH        = ""math"";
        var TOK_SUBTYPE_CONCAT      = ""concatenate"";
        var TOK_SUBTYPE_INTERSECT   = ""intersect"";
        var TOK_SUBTYPE_UNION       = ""union"";

        function parseFormula(orgFormula) {

            var indentCount = 0;
            var indent = function() {
                var s = ""|"";
                for (var i = 0; i < indentCount; i++) {
                    s += ""&nbsp;&nbsp;&nbsp;|"";
                }  
                return s;
            };

            //IMPORTANT: This casting is very important to make the script runnable in Jint (Javascript interpreter of .Net)
            //, as DotNet provides SQLString object, which isn't implicitly converted to javascript String object.  
            var formula = String(orgFormula);
            //formula = formula.replace(/UDFValue\(-/g, ""UDFValue(adiha_minus"");
            //formula = formula.replace(/DealFees\(-/g, ""DealFees(adiha_minus"");
	
            //var formula1='IF(Row(10) > Row(8),Row(8) ,IF(Row(10) < Row(9), Row(9), Row(10))) - Row(2)';
            formula = formula.split(""'"").join('');  
            //formula=formula.split( "" "" ).join('');  
            var tokens = getTokens(formula);

            var tokensHtml = ""<Root>"";
	  
            tokensHtml += ""<PSRecordset>"";
            while (tokens.moveNext()) {
                var token = tokens.current();

                if (token.subtype == TOK_SUBTYPE_STOP) 
                    indentCount -= ((indentCount > 0) ? 1 : 0);
        
                // Replace UDF negative parameters with adia_minus
                var toke_value = token.value.replace(""+"", ""adiha_add"");
                toke_value = toke_value.replace(""<"", ""adiha_lessthan"");
                toke_value = toke_value.replace("">"", ""adiha_greaterthan"");
                //toke_value=toke_value.replace(""B4"",""adiha_pipe"");
        
                tokensHtml += ""<record>"";
                tokensHtml += ""<index>"" + (tokens.index + 1) + ""</index>"";
                tokensHtml += ""<type>"" + token.type + ""</type>"";
                tokensHtml += ""<subtype>"" + ((token.subtype.length == 0) ? """" : token.subtype) + ""</subtype>"";
                tokensHtml += ""<token>"" + (((token.value.length == 0) ? """" : toke_value).split("" "")) + ""</token>"";
                tokensHtml += ""<token_tree>"" + indent() + ((token.value.length == 0) ? ""&nbsp;"" : toke_value).split("" "") + ""</token_tree>"";
                tokensHtml += ""</record>"";

                if (token.subtype == TOK_SUBTYPE_START) 
                    indentCount += 1;
            }
		
            tokensHtml += ""</PSRecordset></Root>"";
            return((tokensHtml.replace(/&nbsp;/g,'')));
        }

        function f_token(value, type, subtype) {
            this.value = value;
            this.type = type;
            this.subtype = subtype;
        }

        function f_tokens() {
            this.items = new Array();
	  
            this.add = function(value, type, subtype) {
                if (!subtype) subtype = """";
                token = new f_token(value, type, subtype);
                this.addRef(token);
                return token;
            };
            this.addRef = function(token) {
                this.items.push(token);
            };
	  
            this.index = -1;
            this.reset = function() {
                this.index = -1;
            };
            this.BOF = function() {
                return (this.index <= 0);
            };
            this.EOF = function() {
                return (this.index >= (this.items.length - 1));
            };
            this.moveNext = function() {
                if (this.EOF()) return false;
                this.index++;
                return true;
            };
            this.current = function() {
                if (this.index == -1) return null;
                return (this.items[this.index]);
            };
            this.next = function() {
                if (this.EOF()) return null;
                return (this.items[this.index + 1]);
            };
            this.previous = function() {
                if (this.index < 1) return null;
                return (this.items[this.index - 1]);
            };
        }

        function f_tokenStack() {
            this.items = new Array();
	  
            this.push = function(token) {
                this.items.push(token);
            };
            this.pop = function() {
                var token = this.items.pop();
		
		        if(typeof(token) == 'undefined') {
			        return (new f_token('', '', TOK_SUBTYPE_ERROR));
		        } else {
			        return (new f_token("""", token.type, TOK_SUBTYPE_STOP));
		        }
            };
	
            this.token = function() {
                return ((this.items.length > 0) ? this.items[this.items.length - 1] : null);
            };
            this.value = function() {
                return ((this.token()) ? this.token().value : """");
            };
            this.type = function() {
                return ((this.token()) ? this.token().type : """");
            };
            this.subtype = function() {
                return ((this.token()) ? this.token().subtype : """");
            };
        }

        function getTokens(formula) {
            var tokens = new f_tokens();
            var tokenStack = new f_tokenStack();

            var offset = 0;

            var currentChar = function() {
                return formula.substr(offset, 1);
            };
            var doubleChar  = function() {
                //return formula.substr(offset, 2);
                //IMPORTANT: Jint throws error when length is out of range. So better make it under the limit
                return formula.substr(offset, ((formula.length - offset) > 1 ? 2 : 1));
            };
            var nextChar    = function() {
                return formula.substr(offset + 1, 1);
            };
            var EOF         = function() {
                return (offset >= formula.length);
            };
	        var prevChar    = function() { 
		        return formula.substr(offset - 1, 1); 
	        };
		
            var token = """";

            var inString = false;
            var inPath = false;
            var inRange = false;
            var inError = false;
	
            while (formula.length > 0) {
                if (formula.substr(0, 1) == "" "") 
                    formula = formula.substr(1);
                else {
                    if (formula.substr(0, 1) == ""="") 
                        formula = formula.substr(1);
                    break;    
                }
            }
    
            var regexSN = /^[1-9]{1}(\.[0-9]+)?E{1}$/;
	  
            while (!EOF()) {
	  
                // state-dependent character evaluation (order is important)
		
                // double-quoted strings
                // embeds are doubled
                // end marks token
		
                if (inString) {    
                    if (currentChar() == ""\"""") {
                        if (nextChar() == ""\"""") {
                            token += ""\"""";
                            offset += 1;
                        } else {
                            inString = false;
                            tokens.add(token, TOK_TYPE_OPERAND, TOK_SUBTYPE_TEXT);
                            token = """";
                        }      
                    } else {
                        token += currentChar();
                    }
                    offset += 1;
                    continue;    
                } 

                // single-quoted strings (links)
                // embeds are double
                // end does not mark a token

                if (inPath) {
                    if (currentChar() == ""'"") {
                        if (nextChar() == ""'"") {
                            token += ""'"";
                            offset += 1;
                        } else {
                            inPath = false;
                        }      
                    } else {
                        token += currentChar();
                    }
                    offset += 1;
                    continue;    
                }    

                // bracked strings (range offset or linked workbook name)
                // no embeds (changed to ""()"" by Excel)
                // end does not mark a token
		
                if (inRange) {
                    if (currentChar() == ""]"") {
                        inRange = false;
                    }
                    token += currentChar();
                    offset += 1;
                    continue;
                }
		
                // error values
                // end marks a token, determined from absolute list of values
		
                if (inError) {
                    token += currentChar();
                    offset += 1;
                    if (("",#NULL!,#DIV/0!,#VALUE!,#REF!,#NAME?,#NUM!,#N/A,"").indexOf("","" + token + "","") != -1) {
                        inError = false;
                        tokens.add(token, TOK_TYPE_OPERAND, TOK_SUBTYPE_ERROR);
                        token = """";
                    }
                    continue;
                }

                // scientific notation check

                if ((""+-"").indexOf(currentChar()) != -1) {
                    if (token.length > 1) {
                        if (token.match(regexSN)) {
                            token += currentChar();
                            offset += 1;
                            continue;
                        }
                    }
                }

                // independent character evaulation (order not important)

                // establish state-dependent character evaluations
			
                if (currentChar() == ""\"""") {  
                    if (token.length > 0) {
                        // not expected
                        tokens.add(token, TOK_TYPE_UNKNOWN);
                        token = """";
                    }
                    inString = true;
                    offset += 1;
                    continue;
                }

                if (currentChar() == ""'"") {
                    if (token.length > 0) {
                        // not expected
                        tokens.add(token, TOK_TYPE_UNKNOWN);
                        token = """";
                    }
                    inPath = true;
                    offset += 1;
                    continue;
                }

                if (currentChar() == ""["") {
                    inRange = true;
                    token += currentChar();
                    offset += 1;
                    continue;
                }

                if (currentChar() == ""#"") {
                    if (token.length > 0) {
                        // not expected
                        tokens.add(token, TOK_TYPE_UNKNOWN);
                        token = """";
                    }
                    inError = true;
                    token += currentChar();
                    offset += 1;
                    continue;
                }
		
                // mark start and end of arrays and array rows

                if (currentChar() == ""{"") {  
                    if (token.length > 0) {
                        // not expected
                        tokens.add(token, TOK_TYPE_UNKNOWN);
                        token = """";
                    }
                    tokenStack.push(tokens.add(""ARRAY"", TOK_TYPE_FUNCTION, TOK_SUBTYPE_START));
                    tokenStack.push(tokens.add(""ARRAYROW"", TOK_TYPE_FUNCTION, TOK_SUBTYPE_START));
                    offset += 1;
                    continue;
                }

                if (currentChar() == "";"") {  
                    if (token.length > 0) {
                        tokens.add(token, TOK_TYPE_OPERAND);
                        token = """";
                    }
                    tokens.addRef(tokenStack.pop());
                    tokens.add("","", TOK_TYPE_ARGUMENT);
                    tokenStack.push(tokens.add(""ARRAYROW"", TOK_TYPE_FUNCTION, TOK_SUBTYPE_START));
                    offset += 1;
                    continue;
                }

                if (currentChar() == ""}"") {  
                    if (token.length > 0) {
                        tokens.add(token, TOK_TYPE_OPERAND);
                        token = """";
                    }
                    tokens.addRef(tokenStack.pop());
                    tokens.addRef(tokenStack.pop());
                    offset += 1;
                    continue;
                }
		
                // trim white-space
		
                if (currentChar() == "" "") {
                    if (token.length > 0) {
                        tokens.add(token, TOK_TYPE_OPERAND);
                        token = """";
                    }
                    tokens.add("""", TOK_TYPE_WSPACE);
                    offset += 1;
                    while ((currentChar() == "" "") && (!EOF())) { 
                        offset += 1; 
                    }
                    continue;     
                }
		
                // multi-character comparators
		
                if (("",>=,<=,<>,"").indexOf("","" + doubleChar() + "","") != -1) {
                    if (token.length > 0) {
                        tokens.add(token, TOK_TYPE_OPERAND);
                        token = """";
                    }
                    tokens.add(doubleChar(), TOK_TYPE_OP_IN, TOK_SUBTYPE_LOGICAL);
                    offset += 2;
                    continue;     
                }

                // standard infix operators
		
                if ((""+-*/^&=><"").indexOf(currentChar()) != -1  && prevChar() !="","" && prevChar() !=""("" ) {
                    if (token.length > 0) {
                        tokens.add(token, TOK_TYPE_OPERAND);
                        token = """";
                    }
                    tokens.add(currentChar(), TOK_TYPE_OP_IN);
                    offset += 1;
                    continue;     
                }

                // standard postfix operators
		
                if ((""%"").indexOf(currentChar()) != -1) {
                    if (token.length > 0) {
                        tokens.add(token, TOK_TYPE_OPERAND);
                        token = """";
                    }
                    tokens.add(currentChar(), TOK_TYPE_OP_POST);
                    offset += 1;
                    continue;     
                }

                // start subexpression or function
		
                if (currentChar() == ""("") {
                    if (token.length > 0) {
                        tokenStack.push(tokens.add(token, TOK_TYPE_FUNCTION, TOK_SUBTYPE_START));
                        token = """";
                    } else {
                        tokenStack.push(tokens.add("""", TOK_TYPE_SUBEXPR, TOK_SUBTYPE_START));
                    }
                    offset += 1;
                    continue;
                }
		
                // function, subexpression, array parameters
		
                if (currentChar() == "","") {
                    if (token.length > 0) {
                        tokens.add(token, TOK_TYPE_OPERAND);
                        token = """";
                    }
                    if (!(tokenStack.type() == TOK_TYPE_FUNCTION)) {
                        tokens.add(currentChar(), TOK_TYPE_OP_IN, TOK_SUBTYPE_UNION);
                    } else {
                        tokens.add(currentChar(), TOK_TYPE_ARGUMENT);
                    }
                    offset += 1;
                    continue;
                }

                // stop subexpression
		
                if (currentChar() == "")"") {
                    if (token.length > 0) {
                        tokens.add(token, TOK_TYPE_OPERAND);
                        token = """";
                    }
                    tokens.addRef(tokenStack.pop());
                    offset += 1;
                    continue;
                }

                // token accumulation
		
                token += currentChar();
                offset += 1;
	  
            }

            // dump remaining accumulation
            if (token.length > 0) tokens.add(token, TOK_TYPE_OPERAND);
	  
            // move all tokens to a new collection, excluding all unnecessary white-space tokens
            var tokens2 = new f_tokens();
	  
            while (tokens.moveNext()) {

                token = tokens.current();
		
                if (token.type == TOK_TYPE_WSPACE) {
                    if ((tokens.BOF()) || (tokens.EOF())) {}
                    else if (!(
                        ((tokens.previous().type == TOK_TYPE_FUNCTION) && (tokens.previous().subtype == TOK_SUBTYPE_STOP)) || 
                        ((tokens.previous().type == TOK_TYPE_SUBEXPR) && (tokens.previous().subtype == TOK_SUBTYPE_STOP)) || 
					        (tokens.previous().type == TOK_TYPE_OPERAND))) {}
                    else if (!(
                        ((tokens.next().type == TOK_TYPE_FUNCTION) && (tokens.next().subtype == TOK_SUBTYPE_START)) || 
                        ((tokens.next().type == TOK_TYPE_SUBEXPR) && (tokens.next().subtype == TOK_SUBTYPE_START)) ||
					        (tokens.next().type == TOK_TYPE_OPERAND))) {}
                    else 
                        tokens2.add(token.value, TOK_TYPE_OP_IN, TOK_SUBTYPE_INTERSECT);
                    continue;
                }

                tokens2.addRef(token);
            }

            // switch infix ""-"" operator to prefix when appropriate, switch infix ""+"" operator to noop when appropriate, identify operand 
            // and infix-operator subtypes, pull ""@"" from in front of function names
            while (tokens2.moveNext()) {

                token = tokens2.current();
		
                if ((token.type == TOK_TYPE_OP_IN) && (token.value == ""-"")) {
                    if (tokens2.BOF())
                        token.type = TOK_TYPE_OP_PRE;
                    else if (
                        ((tokens2.previous().type == TOK_TYPE_FUNCTION) && (tokens2.previous().subtype == TOK_SUBTYPE_STOP)) || 
                        ((tokens2.previous().type == TOK_TYPE_SUBEXPR) && (tokens2.previous().subtype == TOK_SUBTYPE_STOP)) || 
                        (tokens2.previous().type == TOK_TYPE_OP_POST) || 
				        (tokens2.previous().type == TOK_TYPE_OPERAND))
                        token.subtype = TOK_SUBTYPE_MATH;
                    else
                        token.type = TOK_TYPE_OP_PRE;
                    continue;
                }

                if ((token.type == TOK_TYPE_OP_IN) && (token.value == ""+"")) {
                    if (tokens2.BOF())
                        token.type = TOK_TYPE_NOOP;
                    else if (
                        ((tokens2.previous().type == TOK_TYPE_FUNCTION) && (tokens2.previous().subtype == TOK_SUBTYPE_STOP)) || 
                        ((tokens2.previous().type == TOK_TYPE_SUBEXPR) && (tokens2.previous().subtype == TOK_SUBTYPE_STOP)) || 
                        (tokens2.previous().type == TOK_TYPE_OP_POST) || 
				        (tokens2.previous().type == TOK_TYPE_OPERAND))
                        token.subtype = TOK_SUBTYPE_MATH;
                    else
                        token.type = TOK_TYPE_NOOP;
                    continue;
                }

                if ((token.type == TOK_TYPE_OP_IN) && (token.subtype.length == 0)) {
                    if ((""<>="").indexOf(token.value.substr(0, 1)) != -1) 
                        token.subtype = TOK_SUBTYPE_LOGICAL;
                    else if (token.value == ""&"")
                        token.subtype = TOK_SUBTYPE_CONCAT;
                    else
                        token.subtype = TOK_SUBTYPE_MATH;
                    continue;
                }
		
                if ((token.type == TOK_TYPE_OPERAND) && (token.subtype.length == 0)) {
                    if (isNaN(parseFloat(token.value)))
                        if ((token.value == 'TRUE') || (token.value == 'FALSE'))
                            token.subtype = TOK_SUBTYPE_LOGICAL;
                        else
                            token.subtype = TOK_SUBTYPE_RANGE;
                    else
                        token.subtype = TOK_SUBTYPE_NUMBER;
                    continue;
                }

                if (token.type == TOK_TYPE_FUNCTION) {
                    if (token.value.substr(0, 1) == ""@"")
                        token.value = token.value.substr(1);
                    continue;
                }
			
            }
	  
            tokens2.reset();

            // move all tokens to a new collection, excluding all noops
            tokens = new f_tokens();
	  
            while (tokens2.moveNext()) {
                if (tokens2.current().type != TOK_TYPE_NOOP)
                    tokens.addRef(tokens2.current());
            }  
	  
            tokens.reset();
		
            return tokens;
        }

        /****************************************Formula Parser JS Code END***********************************************/");

            return sb.ToString();

        }

        //System.Web.HttpServerUtility.UrlDecode exists in .Net code, but SQL CRL didn't allow referencing System.Web.dll in an easy way.
        //So a similar code is used for the functionality.
        public static string UrlDecode(string str)
        {
            return UrlDecode (str, Encoding.UTF8 );
        }


        public static string UrlDecode(string s, Encoding e)
        {
            if (s == null)
                return null;

            if (e == null)
                e = Encoding.UTF8;

            System.Text.StringBuilder output = new System.Text.StringBuilder();
            int len = s.Length;
            System.Globalization.NumberStyles hexa = System.Globalization.NumberStyles.HexNumber;
            System.IO.MemoryStream bytes = new System.IO.MemoryStream();

            for (int i = 0; i < len - 1; i++)
            {
                if (s.Substring(i, 1) == "%" && i + 2 < len)
                {
                    if (s.Substring(i + 1, 1) == "u" && i + 5 < len)
                    {
                        if (bytes.Length > 0)
                        {
                            output.Append(GetChars(bytes, e));
                            bytes.SetLength(0);
                        }
                        output.Append(Int32.Parse(s.Substring(i + 2, 4), hexa).ToString());
                        i += 5;
                    }
                    else
                    {
                        bytes.WriteByte((Byte)(Int32.Parse(s.Substring(i + 1, 2), hexa)));
                        i += 2;
                    }
                    continue;
                }

                if (bytes.Length > 0)
                {
                    output.Append(GetChars(bytes, e));
                    bytes.SetLength(0);
                }


                if (s.Substring(i, 1) == "+")
                    output.Append(" ");
                else
                    output.Append(s.Substring(i, 1));

            }

            if (bytes.Length > 0)
                output.Append(GetChars(bytes, e));
            bytes = null;

            return output.ToString();
        }

        public static char[] GetChars(System.IO.MemoryStream b, Encoding e)
        {
            return e.GetChars(b.GetBuffer(), 0, Convert.ToInt32(b.Length));
        }

        #endregion
        /// <summary>
        /// Check if ssrs report rdl exist in report server
        /// </summary>
        /// <param name="reportName">SSRS report name</param>
        /// <returns></returns>
        [SqlFunction(SystemDataAccess = SystemDataAccessKind.Read, DataAccess = DataAccessKind.Read)]
        public static SqlBoolean RdlExists(string reportName)
        {
            try
            {
                SSRS ssrs = new SSRS();
                return ssrs.RdlExists(reportName);
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        /// <summary>
        /// Remove specified column name from update set clause
        /// </summary>
        /// <param name="updateQuery">Update statement query</param>
        /// <param name="setClauseColumnName">Column name defined in set clause update statement</param>
        /// <returns></returns>
        [SqlFunction(Name = "RemoveColumnsFromUpdate", FillRowMethodName = "FillRow1", TableDefinition = "update_query NVARCHAR(MAX), [output_status] NVARCHAR(MAX)")]
        public static IEnumerable RemoveColumnsFromUpdate(string updateQuery, string setClauseColumnName)
        {
            var p = new TSqlScriptParser();
            string parseError = "Success";
            List<Update> updates = new List<Update>();
            string query = p.RemoveColumnsFromUpdate(updateQuery, setClauseColumnName, out parseError);
            updates.Add(new Update() { Query = query, ParseError = parseError });
            return updates;
        }

        public static void FillRow1(object row, out string udpate_query, out string output_status)
        {
            Update upd = ((Update)row);
            udpate_query = upd.Query;
            output_status = upd.ParseError;
        }
    }
}