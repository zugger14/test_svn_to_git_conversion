using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    public interface ISnapshot
    {
        void Process(SnapshotInfo snapshotInfo);
    }
}
