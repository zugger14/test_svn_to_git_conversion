using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;

namespace FARRMSUtilities
{
    /// <summary>
    /// Column definition class
    /// </summary>
    class Column
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public string StartNode { get; set; }
        public string EndNode { get; set; }

    }
    /// <summary>
    /// This class contents methods to export SqlDataReader to node / attribute based xml file generation.
    /// </summary>
    class PsXml
    {
        private List<Column> Columns { get; set; }

        private string ReportName { get; set; }
        private string XmlNameSpace { get; set; }
        private StreamWriter Writer { get; set; }
        private SqlDataReader Reader { get; set; }
        private bool AttributeBased { get; set; }

        /// <summary>
        /// Initialization
        /// </summary>
        /// <param name="rd">SqlDataReader</param>
        /// <param name="attributeBased">Set as true for attribute based xml generation</param>
        /// <param name="sw">StreamWriter</param>
        /// <param name="reportName">Xml document name</param>
        /// <param name="xmlNameSpace">Xml namespace</param>
        public PsXml(SqlDataReader rd, bool attributeBased, StreamWriter sw, string reportName, string xmlNameSpace)
        {
            Reader = rd;
            AttributeBased = attributeBased;
            Writer = sw;
            ReportName = reportName;
            XmlNameSpace = xmlNameSpace; 

            Columns = new List<Column>();
            for (int i = 0; i < Reader.FieldCount; i++)
            {
                Column c = new Column() { Name = Reader.GetName(i), Description = Reader.GetName(i).ReplaceSpecialCharWithBlank() };
                Columns.Add(c);

                c.StartNode = Environment.NewLine + "<" + c.Description + ">";
                c.EndNode = "</" + c.Description + ">";
                if (AttributeBased)
                {
                    c.StartNode = " " + c.Description + "=\"";
                    c.EndNode = "\"";
                }
            }
        }

        public void Write()
        {
            string rec = Environment.NewLine + @"<Record>";
            if (AttributeBased)
                rec = Environment.NewLine + @"<Record";

            int i = 0;

            foreach (Column c in Columns)
            {
                rec += c.StartNode + System.Net.WebUtility.HtmlEncode(Reader[i].ToString()) + c.EndNode;
                i++;
            }
            if (!AttributeBased)
                rec += Environment.NewLine + @"</Record>";
            else
                rec += @" />";
            Writer.Write(rec);
        }

        private void StartHeader()
        {
            string header  = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
            if (!string.IsNullOrEmpty(XmlNameSpace) && !string.IsNullOrEmpty(ReportName))
            header += Environment.NewLine + "<Recordset xmlns=\"" + XmlNameSpace + "\" Name=\"" + ReportName + "\">";
            else
                header += Environment.NewLine + "<Recordset>";

            Writer.Write(header);
        }

        private void EndFooter()
        {
            string footer = Environment.NewLine + "</Recordset>";
            Writer.Write(footer);
        }

        public void CreateXml()
        {
            StartHeader();
            while (Reader.Read())
            {
                Write();
            }
            EndFooter();
        }
    }
}
