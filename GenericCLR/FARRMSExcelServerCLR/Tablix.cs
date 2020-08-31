using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    public class Tablix
    {
        public string ReportSheetDataset { get; set; }
        public string Description { get; set; }
        public List<Column> Columns { get; set; }
        public List<Row> Rows { get; set; }

        public DataTable DataTable { get; set; }
        public Position Position { get; set; }
        public List<Column> AggregationList { get; set; }

        //  For End of Grouping
        public virtual List<Row> EndAggregationList { get; set; }
        public virtual int RowIndex { get; set; }
    }
}
