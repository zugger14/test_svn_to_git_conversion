using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSImportCLR
{   
    /// <summary>
    /// Interface used for Data Import
    /// every implementation of web service data exporter should implement this interface
    /// </summary>
    public interface ICLRImporter 
    {
        ImportStatus ImportData(CLRImportInfo clrImportInfo);
    }
}
