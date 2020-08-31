using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSGenericCLR
{
    //every implementation of web service data exporter should implement this interface
    public interface ICLRImporter 
    {
        ImportStatus ImportData(CLRImportInfo clrImportInfo);
    }
}
