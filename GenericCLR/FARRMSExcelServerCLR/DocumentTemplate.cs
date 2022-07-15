namespace FARRMSExcelServerCLR
{
    public class DocumentTemplate
    {
        /// <summary>
        /// Document dataset id
        /// </summary>
        public int Id { get; set; }
        /// <summary>
        /// Excel sheet id template used for generating document
        /// </summary>
        public int ExcelSheetId { get; set; }
        /// <summary>
        /// Unique process id to track the individual document generation process
        /// </summary>
        public string ProcessId { get; set; }
        /// <summary>
        /// XML Criterai in case of excel template, for RDL sql command string
        /// </summary>
        public string CriteriaOrSQl { get; set; }
        /// <summary>
        /// Document Export Format eg. PDF, 
        /// </summary>
        public string ExportFormat { get; set; }
        /// <summary>
        /// Template type to distinguish the operation eg. Excel, Rdl
        /// </summary>
        public string TemplateType { get; set; }
        /// <summary>
        /// Document Final Path
        /// </summary>
        public string OutputFilePath { get; set; }
        /// <summary>
        /// Username
        /// </summary>
        public string UserName { get; internal set; }
        /// <summary>
        /// Document generation status
        /// </summary>
        public bool Status { get; set; }
        /// <summary>
        /// Exported file name
        /// </summary>
        public string ExportFileName { get; internal set; }
    }
}
