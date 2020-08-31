using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    public class Column
    {
        public string Label { get; set; }
        public string Field { get; set; }

        //  If any grouping aggregation field has been bound
        public virtual List<Row> AggregationRows { get; set; }
        public virtual int GroupingIndex { get; set; }
    }
}
