using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    /// <summary>
    /// Report parameter information of excel addin _param sheet
    /// </summary>
    public class ReportParameter
    {
        public string Name { get; set; }
        public string Value { get; set; }
        public string Label { get; set; }
        public virtual bool Enabled { get; set; }
        public string WidgetName { get; set; }

        /// <summary>
        /// Evaluates dynamic data calendar parameter value
        /// </summary>
        public void EvaluateDateValue(SqlConnection sqlConnection)
        {
            if (this.Enabled && this.WidgetName.ToLower() == "datetime")
            {
                //  check date is dynamic date , dynamic date contains | separator eg. 45604|-57|106400|y
                //  overide type | Adjustment days | Adjust type | business days
                string[] dynamicDate = Value.Split('|');
                if (dynamicDate.Length > 3) //  At least 4 parts are needed to get dynamic date
                {
                    string dynamicDateValue = Helper.GetDynamicDate(dynamicDate[0], dynamicDate[1], dynamicDate[2], dynamicDate[3], sqlConnection);
                    if (!string.IsNullOrEmpty(dynamicDateValue))
                        this.Value = dynamicDateValue;
                }

            }
        }
    }
}
