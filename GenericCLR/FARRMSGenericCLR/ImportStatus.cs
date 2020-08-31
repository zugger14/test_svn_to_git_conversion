using System;

/// <summary>
/// Summary description for Class1
/// </summary>
namespace FARRMSGenericCLR
{
    public class ImportStatus
    {
        public string Status { get; set; }
        public string ResponseMessage { get; set; }
        public string ProcessID { get; set; }
        public Exception Exception { get; set; }
        public string FilePath { get; set; }
        public string FileName { get; set; }
        public string ProcessTableName { get; set; }
        public bool Supress { get; set; }
    }
}
