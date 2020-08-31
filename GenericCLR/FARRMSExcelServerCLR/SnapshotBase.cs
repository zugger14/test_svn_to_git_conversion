using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    public abstract class SnapshotBase : ISnapshot
    {
        public virtual void Process(SnapshotInfo snapshotInfo)
        {
            throw new NotImplementedException();
        }
    }
}
