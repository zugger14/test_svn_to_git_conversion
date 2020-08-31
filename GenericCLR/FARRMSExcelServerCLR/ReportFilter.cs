using System;
using System.Data.SqlClient;

namespace FARRMSExcelServerCLR
{
    public class ReportFilter
    {
        public string Name { get; set; }
        public string DisplayLabel { get; set; }
        public string Value { get; set; }
        public string DisplayValue { get; set; }
        public int OverrideType { get; set; }
        public int AdjustmentDays { get; set; }
        public string AdjustmentType { get; set; }
        public string BusinessDay { get; set; }

        public void ResolveDynamicDate(SqlConnection sqlConnection)
        {
            try
            {
                if (OverrideType != 0)
                {
                    //SELECT  dbo.FNAResolveDynamicDate('45601|10|106400|n')
                    string sql = "SELECT dbo.FNAResolveDynamicDate('{0}|{1}|{2}|{3}')";

                    sql = string.Format(sql, OverrideType, AdjustmentDays, AdjustmentType, BusinessDay);
                    using (var cmd = new SqlCommand(sql, sqlConnection))
                    {
                        using (SqlDataReader rd = cmd.ExecuteReader())
                        {
                            rd.Read();
                            Value = Convert.ToDateTime(rd[0]).ToString("yyyy-MM-dd");
                            DisplayValue = Value;
                        }
                    }
                }
            }
            catch (Exception)
            {
            }
        }
    }
}
