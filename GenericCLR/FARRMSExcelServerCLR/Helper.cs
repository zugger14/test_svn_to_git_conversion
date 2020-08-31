using Spire.Xls;
using Spire.Xls.Core;
using Spire.Xls.Core.Spreadsheet;
using Spire.Xls.Core.Spreadsheet.PivotTables;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    public static class Helper
    {
        /// <summary>
        ///     get Row index by cell reference
        /// </summary>
        /// <param name="cell"></param>
        /// <returns></returns>
        public static int GetRowIndex(this CellRange cell)
        {
            return cell.Row;
        }

        /// <summary>
        ///     Given just the column name (no row index), it will return the zero based column index.
        ///     Note: This method will only handle columns with a length of up to two (ie. A to Z and AA to ZZ).
        ///     A length of three can be implemented when needed.
        /// </summary>
        /// <param name="columnName">Column Name (ie. A or AB)</param>
        /// <returns>Zero based index if the conversion was successful; otherwise null</returns>
        public static int GetColumnIndex(this CellRange cell)
        {
            return cell.Column;
        }

        public static int ToInt(this object obj)
        {
            try
            {
                return Convert.ToInt32(obj);
            }
            catch (Exception)
            {
                return 0;
            }
        }

        public static bool ToBool(this Object value)
        {
            try
            {
                return Convert.ToBoolean(value);
            }
            catch (Exception)
            {
                return false;
            }
        }

        public static bool ToBool(this string value)
        {
            try
            {
                if (value.ToLower() == "true" || value.ToLower() == "1")
                    return true;
                return false;
            }
            catch (Exception)
            {
                return false;
            }
        }

        /// <summary>
        ///     Validates if sheet is part of spreadsheet
        /// </summary>
        /// <param name="workbook">SpreadSheet</param>
        /// <param name="sheetName">SheetName</param>
        /// <returns>Returns true if sheet is valid</returns>
        public static bool SheetIsValid(this Workbook workbook, string sheetName)
        {
            IWorksheet sheet =
                workbook.Worksheets.FirstOrDefault(x => x.Name.ToString().ToLower() == sheetName.ToLower());
            if (sheet != null)
                return true;
            return false;
        }

        /// <summary>
        /// Get Worksheet from workbook
        /// </summary>
        /// <param name="workbook">Workbook</param>
        /// <param name="sheetName">Sheet Name</param>
        /// <returns>Worksheet</returns>
        public static Worksheet GetWorksheet(this Workbook workbook, string sheetName)
        {
            try
            {
                Worksheet sheet = workbook.Worksheets[sheetName];
                if (sheet != null)
                    return sheet;
            }
            catch (Exception)
            {
                return null;
            }
            return null;
        }

        /// <summary>
        ///     Get collection of sheets in spreadsheet
        /// </summary>
        /// <returns></returns>
        public static List<Worksheet> GetSheets(this Workbook workbook)
        {
            return workbook.Worksheets.Cast<Worksheet>().ToList();
        }

        /// <summary>
        ///     Get single sheet from spreadsheet
        /// </summary>
        /// <param name="workbook">SpreadSheet</param>
        /// <param name="sheetName">Sheet Name</param>
        /// <returns></returns>
        public static Worksheet GetSheet(this Workbook workbook, string sheetName)
        {
            return workbook.Worksheets[sheetName];
        }

        public static string ProcessId()
        {
            return Guid.NewGuid().ToString().ToUpper().Replace("-", "_");
        }

        /// <summary>
        ///     Clear spread sheet contents
        /// </summary>
        /// <param name="workbook"></param>
        /// <param name="sheetName">ReportSheet Name</param>
        /// <param name="excludeHeaderRow">Exlude header row, Row 1</param>
        public static void Clear(this Workbook workbook, string sheetName, bool excludeHeaderRow = false)
        {
            int startIndex = 1;
            if (excludeHeaderRow) startIndex = 2;
            Worksheet sheet = workbook.Worksheets[sheetName];
            sheet.Clear();
            sheet.ClearData();
            workbook.Save();
        }

        /// <summary>
        /// Clear data import sheet with preserving its header row
        /// </summary>
        /// <param name="worksheet">Worksheet</param>
        public static void ClearRows(this Worksheet worksheet, bool deleteHeader = true)
        {
            string cellAddress = deleteHeader ? "A1:{0}{1}" : "A2:{0}{1}";

            cellAddress = string.Format(cellAddress, GetExcelColumnName(worksheet.Columns.Count()), worksheet.Rows.Count());
            CellRange rangeToDelete = worksheet.Range[cellAddress];
            worksheet.DeleteRange(rangeToDelete, DeleteOption.MoveUp);
        }

        public static IEnumerable<CellRange> GetSpreadSheetRows(this Workbook workbook, string sheetName)
        {
            Worksheet sheet = workbook.Worksheets[sheetName];
            if (sheet != null)
            {
                return sheet.Rows;
            }
            return null;
        }


        /// <summary>
        ///     Returns excel column cell reference
        /// </summary>
        /// <param name="cell"></param>
        /// <returns></returns>
        public static string GetColumnReference(this CellRange cell)
        {
            return cell.RangeAddress;
        }

        /// <summary>
        ///     Return Excel like column name based on its column index
        /// </summary>
        /// <param name="columnNumber">1</param>
        /// <returns>A</returns>
        public static string GetExcelColumnName(int columnNumber)
        {
            int dividend = columnNumber;
            string columnName = String.Empty;

            while (dividend > 0)
            {
                int modulo = (dividend - 1) % 26;
                columnName = Convert.ToChar(65 + modulo) + columnName;
                dividend = (dividend - modulo) / 26;
            }

            return columnName;
        }

        public static CellRange GetCellRange(this Worksheet worksheet, Tablix tablix)
        {
            string cellAddress = "{0}{1}:{2}{3}";
            cellAddress = string.Format(cellAddress, GetExcelColumnName(tablix.Position.C1), tablix.Position.R1 + 1, GetExcelColumnName(tablix.Position.C2), tablix.Position.R1 + 1);
            return worksheet.Range[cellAddress];
        }

        public static string ConvertToFormula(this string formula, Position position)
        {
            try
            {
                //return formula.Replace("{R1}", position.R1.ToString(CultureInfo.InvariantCulture))
                //.Replace("{R2}", position.R2.ToString(CultureInfo.InvariantCulture))
                //.Replace("{C1}", position.C1.ToString(CultureInfo.InvariantCulture))
                //.Replace("{C2}", position.C2.ToString(CultureInfo.InvariantCulture));
                return formula.Replace("{R1}", position.C1.ToString(CultureInfo.InvariantCulture))
                .Replace("{R2}", position.C2.ToString(CultureInfo.InvariantCulture));
            }
            catch (Exception)
            {
                return formula;
            }

        }

        public static CellRange GetCellRange(this Worksheet worksheet, Tablix tablix, int rowIndex)
        {
            string cellAddress = "{0}{1}:{2}{3}";
            cellAddress = string.Format(cellAddress, GetExcelColumnName(tablix.Position.C1), rowIndex, GetExcelColumnName(tablix.Position.C2), rowIndex);
            return worksheet.Range[cellAddress];
        }

        public static CellRange GetCellRange(this Worksheet worksheet, int column1, int column2, int row1, int row2)
        {
            string cellAddress = "{0}{1}:{2}{3}";
            cellAddress = string.Format(cellAddress, GetExcelColumnName(column1), row1, GetExcelColumnName(column2), row2);
            return worksheet.Range[cellAddress];
        }

        /// <summary>
        ///     Get report sheet columns and it cell data type based on its 2nd row, This cell data type will be used later while
        ///     plotting the data again.
        /// </summary>
        public static List<SpreadSheetColumn> GetSpreadSheetColumns(this Workbook workbook, string sheetName)
        {
            var spreadSheetColumns = new List<SpreadSheetColumn>();
            Worksheet sheet = workbook.Worksheets[sheetName];
            if (sheet != null)
            {
                CellRange headerRow = sheet.Rows[0];
                if (headerRow.Cells != null)
                    spreadSheetColumns.AddRange(headerRow.Cells.Select(range => new SpreadSheetColumn(range)));
            }
            //  Assign data type & style index based template file second row
            if (sheet.Rows.Count() > 1)
                spreadSheetColumns.SetColumnAttributes(sheet.Rows[1]);
            return spreadSheetColumns;
        }

        /// <summary>
        ///     Set few attributes based on second row fore spread sheet column, Eg. formula
        /// </summary>
        /// <param name="detailRow"></param>
        public static void SetColumnAttributes(this List<SpreadSheetColumn> spreadSheetColumns, CellRange detailRow)
        {
            //  Data row may be blank
            if (detailRow != null)
            {
                foreach (CellRange cell in detailRow.Cells)
                {
                    SpreadSheetColumn spreadSheetColumn =
                        spreadSheetColumns.FirstOrDefault(x => x.Index == cell.GetColumnIndex());
                    if (spreadSheetColumn == null) continue;
                    if (!string.IsNullOrEmpty(cell.Formula))
                        spreadSheetColumn.Formula = cell.Formula.TrimStart('{').TrimEnd('}');   //  if expression were enclosed with {} in formula text
                }
            }
        }

        // Retrieve the value of a cell, given a file name, sheet name, column, row
        public static string GetCellValue(this Workbook workbook, string sheetName, int column, int row)
        {
            Worksheet sheet = workbook.Worksheets[sheetName];
            return sheet.Range[row, column].Text;
        }

        /// <summary>
        ///     Dump datatable to process table, process table schema should be exact according to datatable columns colllection
        /// </summary>
        /// <param name="dataTable">System.Data.DataTable</param>
        /// <param name="processTableName">Valid process table with columns</param>
        /// <param name="sqlConnection">Valid opened sqlconnection</param>
        /// <param name="selectColumns">Column list that will be included while dumping the records</param>
        public static void Dump(this DataTable dataTable, string processTableName, SqlConnection sqlConnection,
            string selectColumns = null)
        {
            string sql = "SELECT * FROM " + processTableName;
            if (!string.IsNullOrEmpty(selectColumns))
                sql = "SELECT " + selectColumns + " FROM " + processTableName;
            //  Mark datatable rows added, added if datatable has been dervied sql datareader
            //  If rows are not marked as added rows will not be copied to process table.
            foreach (DataRow row in dataTable.Rows)
                if (row.RowState != DataRowState.Added) row.SetAdded();

            //  Copy data table
            using (var adapter = new SqlDataAdapter(sql, sqlConnection))
            using (var builder = new SqlCommandBuilder(adapter))
            {
                adapter.InsertCommand = builder.GetInsertCommand();
                adapter.Update(dataTable);
            }
        }

        /// <summary>
        ///     Execute SQL query
        /// </summary>
        /// <param name="sqlConnection">Any open SqlConnection</param>
        /// <param name="sql">SQL Query / SP</param>
        public static void ExecuteQuery(this SqlConnection sqlConnection, string sql)
        {
            using (var cmd = new SqlCommand(sql, sqlConnection))
            {
                cmd.ExecuteNonQuery();
            }
        }

        public static void ChangePivotDataSourceCache(this Workbook workbook)
        {
            //  Get pivots available in worksheet
            var sheets = workbook.GetSheets();

            foreach (var sheet in sheets)
            {
                var pivotTable = sheet.PivotTables;
                if (pivotTable.Count > 0)
                {
                    foreach (XlsPivotTable pt in pivotTable)
                    {
                        pt.CalculateData();
                        pt.Cache.IsRefreshOnLoad = true;
                    }
                }
            }
            workbook.CalculateAllValue();
            //workbook.Save();
        }

        public static void UpdateCharts(this Workbook workbook)
        {
            foreach (Worksheet worksheet in workbook.Worksheets)
            {
                foreach (Chart ct in worksheet.Charts)
                {
                    ct.DataRange = worksheet.AllocatedRange;
                }
            }
            workbook.Save();
        }

        public static void RefreshCharts(this Workbook workbook)
        {
            foreach (Worksheet worksheet in workbook.Worksheets)
            {
                foreach (Chart ct in worksheet.Charts)
                {
                    ct.RefreshChart();
                }
            }
        }


        /// <summary>
        /// Update excel name range
        /// </summary>
        /// <param name="workbook">Workbook</param>
        /// <param name="reportSheets">list of report sheet present in workbook to validate name range</param>
        public static void UpdateNameRange(this Workbook workbook, List<ReportSheet> reportSheets)
        {
            //  Suppressed error some time spire returns invalid named ranges.
            try
            {
                foreach (XlsName nameRange in workbook.NameRanges)
                {
                    if (nameRange.Name.Contains("_xlnm.")) continue;
                    string sheetName = nameRange.RangeGlobalAddress.Substring(1, nameRange.RangeGlobalAddress.IndexOf('!') - 2);
                    if (reportSheets != null)
                    {
                        //  if name range reference sheet name doesnt matches the trm report sheet dont update the name range,
                        //  it will preserve the name range created by user beside trm report sheet. 
                        if (reportSheets.FirstOrDefault(x => x.SheetName.ToLower() == sheetName.ToLower()) == null) continue;
                    }
                    var sheet = workbook.Worksheets[sheetName];
                    string colName = GetExcelColumnName(sheet.Columns.Count());
                    //  Pivot data requires at least header / 1 row
                    int rowCount = 2;
                    if (sheet.Rows.Count() != 1)
                        rowCount = sheet.Rows.Count();
                    workbook.NameRanges[nameRange.Name].RefersToRange = sheet.Range["A1:" + colName + rowCount];
                    workbook.Save();
                }
            }
            catch (Exception)
            {
            }

        }

        /// <summary>
        /// Get dynamic date
        /// </summary>
        /// <param name="overrideType">overrideType</param>
        /// <param name="adjustmentDays">adjustmentDays</param>
        /// <param name="adjustmentType">adjustmentType</param>
        /// <param name=""businessDay>businessDay</param>
        public static string GetDynamicDate(string overrideType, string adjustmentDays, string adjustmentType, string businessDay, SqlConnection sqlConnection)
        {
            try
            {
                string sql = "SELECT dbo.FNAResolveDynamicDate('{0}|{1}|{2}|{3}')";

                sql = string.Format(sql, overrideType, adjustmentDays, adjustmentType, businessDay);
                using (var cmd = new SqlCommand(sql, sqlConnection))
                {
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        rd.Read();
                        return Convert.ToDateTime(rd[0]).ToString("yyyy-MM-dd");
                    }
                }
            }
            catch (Exception)
            {
                return null;
            }
        }

        #region DataReaderExtension

        public static IEnumerable<T> FromDataReader<T>(this IEnumerable<T> list, DbDataReader dr)
        {
            //Instance reflec object from Reflection class coded above
            var reflec = new Reflection();
            //Declare one "instance" object of Object type and an object list
            var lstObj = new List<Object>();

            //dataReader loop
            while (dr.Read())
            {
                //Create an instance of the object needed.
                //The instance is created by obtaining the object type T of the object
                //list, which is the object that calls the extension method
                //Type T is inferred and is instantiated
                object instance = Activator.CreateInstance(list.GetType().GetGenericArguments()[0]);

                // Loop all the fields of each row of dataReader, and through the object
                // reflector (first step method) fill the object instance with the datareader values
                DataTable schemaTable = dr.GetSchemaTable();
                if (schemaTable != null)
                    foreach (DataRow drow in schemaTable.Rows)
                    {
                        reflec.FillObjectWithProperty(ref instance,
                            drow.ItemArray[0].ToString(), dr[drow.ItemArray[0].ToString()], null);
                    }

                //Add object instance to list
                lstObj.Add(instance);
            }

            var lstResult = new List<T>();
            foreach (object item in lstObj)
            {
                lstResult.Add((T)Convert.ChangeType(item, typeof(T)));
            }
            dr.Close();
            return lstResult;
        }

        public static IEnumerable<T> FromOleReader<T>(this IEnumerable<T> list, SqlDataReader dr)
        {
            //Instance reflec object from Reflection class coded above
            var reflec = new Reflection();
            //Declare one "instance" object of Object type and an object list
            var lstObj = new List<Object>();

            //dataReader loop
            while (dr.Read())
            {
                //Create an instance of the object needed.
                //The instance is created by obtaining the object type T of the object
                //list, which is the object that calls the extension method
                //Type T is inferred and is instantiated
                object instance = Activator.CreateInstance(list.GetType().GetGenericArguments()[0]);

                // Loop all the fields of each row of dataReader, and through the object
                // reflector (first step method) fill the object instance with the datareader values
                DataTable schemaTable = dr.GetSchemaTable();
                if (schemaTable != null)
                    foreach (DataRow drow in schemaTable.Rows)
                    {
                        reflec.FillObjectWithProperty(ref instance,
                            drow.ItemArray[0].ToString(), dr[drow.ItemArray[0].ToString()], null);
                    }

                //Add object instance to list
                lstObj.Add(instance);
            }

            var lstResult = new List<T>();
            foreach (object item in lstObj)
            {
                lstResult.Add((T)Convert.ChangeType(item, typeof(T)));
            }

            return lstResult;
        }

        public static IEnumerable<T> FromOleReader<T>(this IEnumerable<T> list, OleDbDataReader dr)
        {
            //Instance reflec object from Reflection class coded above
            var reflec = new Reflection();
            //Declare one "instance" object of Object type and an object list
            var lstObj = new List<Object>();

            //dataReader loop
            while (dr.Read())
            {
                //Create an instance of the object needed.
                //The instance is created by obtaining the object type T of the object
                //list, which is the object that calls the extension method
                //Type T is inferred and is instantiated
                object instance = Activator.CreateInstance(list.GetType().GetGenericArguments()[0]);

                // Loop all the fields of each row of dataReader, and through the object
                // reflector (first step method) fill the object instance with the datareader values
                DataTable schemaTable = dr.GetSchemaTable();
                if (schemaTable != null)
                    foreach (DataRow drow in schemaTable.Rows)
                    {
                        reflec.FillObjectWithProperty(ref instance,
                            drow.ItemArray[0].ToString(), dr[drow.ItemArray[0].ToString()], null);
                    }

                //Add object instance to list
                lstObj.Add(instance);
            }

            var lstResult = new List<T>();
            foreach (object item in lstObj)
            {
                lstResult.Add((T)Convert.ChangeType(item, typeof(T)));
            }

            return lstResult;
        }

        #endregion
    }

    public class Reflection
    {
        public void FillObjectWithProperty(ref object objectTo, string propertyName, object propertyValue,
            Object[] index)
        {
            Type tOb2 = objectTo.GetType();
            tOb2.GetProperty(propertyName).SetValue(objectTo, propertyValue, null);
        }
    }
}
