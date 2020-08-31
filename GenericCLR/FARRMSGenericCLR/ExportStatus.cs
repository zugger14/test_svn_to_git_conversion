using System;

namespace FARRMSGenericCLR
{
    /// <summary>
    /// Status details after data is exported
    /// </summary>
    public class ExportStatus
    {
        public string Status { get; set; }
        public string ResponseMessage { get; set; }
        public string ProcessID { get; set; }
        public Exception Exception { get; set; }
        public string FilePath { get; set; }
        public string FileName { get; set; }
    }
}