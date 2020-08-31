using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;

namespace FARRMSGenericCLR
{
    /// <summary>
    /// Helper extension for excel import functionalities
    /// </summary>
    public class ExcelHelper
    {
        static uint[] builtInDateTimeNumberFormatIDs = new uint[] { 14, 15, 16, 17, 18, 19, 20, 21, 22, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 45, 46, 47, 50, 51, 52, 53, 54, 55, 56, 57, 58 };
        static Dictionary<uint, NumberingFormat> builtInDateTimeNumberFormats = builtInDateTimeNumberFormatIDs.ToDictionary(id => id, id => new NumberingFormat { NumberFormatId = id });
        static Regex dateTimeFormatRegex = new Regex(@"((?=([^[]*\[[^[\]]*\])*([^[]*[ymdhs]+[^\]]*))|.*\[(h|mm|ss)\].*)", RegexOptions.Compiled);

        public static Dictionary<uint, NumberingFormat> GetDateTimeCellFormats(WorkbookPart workbookPart)
        {
            if (workbookPart.WorkbookStylesPart.Stylesheet.NumberingFormats == null)
                return null;
            var dateNumberFormats = workbookPart.WorkbookStylesPart.Stylesheet.NumberingFormats
                .Descendants<NumberingFormat>()
                .Where(nf => dateTimeFormatRegex.Match(nf.FormatCode.Value).Success)
                .ToDictionary(nf => nf.NumberFormatId.Value);

            var cellFormats = workbookPart.WorkbookStylesPart.Stylesheet.CellFormats
                .Descendants<CellFormat>();

            var dateCellFormats = new Dictionary<uint, NumberingFormat>();
            uint styleIndex = 0;
            foreach (var cellFormat in cellFormats)
            {
                if (cellFormat.ApplyNumberFormat != null && cellFormat.ApplyNumberFormat.Value)
                {
                    if (dateNumberFormats.ContainsKey(cellFormat.NumberFormatId.Value))
                    {
                        dateCellFormats.Add(styleIndex, dateNumberFormats[cellFormat.NumberFormatId.Value]);
                    }
                    else if (builtInDateTimeNumberFormats.ContainsKey(cellFormat.NumberFormatId.Value))
                    {
                        dateCellFormats.Add(styleIndex, builtInDateTimeNumberFormats[cellFormat.NumberFormatId.Value]);
                    }
                }

                styleIndex++;
            }

            return dateCellFormats;
        }

        // Usage Example
        public static bool IsDateTimeCell(WorkbookPart workbookPart, Cell cell)
        {
            if (cell.StyleIndex == null)
                return false;

            var dateTimeCellFormats = ExcelHelper.GetDateTimeCellFormats(workbookPart);
            if (dateTimeCellFormats == null)
                return false;
            return dateTimeCellFormats.ContainsKey(cell.StyleIndex);
        }
    }
}
