using Spire.Xls;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace FARRMSExcelServerCLR
{
    internal class DocumentGeneration : SnapshotBase
    {
        private SnapshotInfo _snapshotInfo;
        private Worksheet _documentWorksheet;
        private Worksheet _templateWorksheet;
        private List<Tablix> _tablixes;
        public override void Process(SnapshotInfo snapshotInfo)
        {
            _snapshotInfo = snapshotInfo;
            foreach (ReportSheet reportSheet in _snapshotInfo.ReportSheets)
                reportSheet.BindData(_snapshotInfo);
            _snapshotInfo.ReplicaWorkbook.UpdateNameRange(_snapshotInfo.ReportSheets);
            
            _documentWorksheet = _snapshotInfo.ReplicaWorkbook.GetSheet(_snapshotInfo.ExcelSheet.SheetName);
            _templateWorksheet = _snapshotInfo.ReplicaWorkbook.GetSheet(_snapshotInfo.TemplateWorksheet);
            _snapshotInfo.ReplicaWorkbook.ChangePivotDataSourceCache();
            //  List of dataset used
            _tablixes = this.GetListOfDataSetsUsedByInvoiceSheet();

            CopyTemplateWorksheet();
            PrepareInvoice();
            _snapshotInfo.ExcelSheet.ShowHideDataTabs(_snapshotInfo.ReplicaWorkbook);            
            _snapshotInfo.ExcelSheet.Export(_snapshotInfo.ExportFomat);
        }


        /// <summary>
        /// Copy content from document template to document worksheet that will be published
        /// </summary>
        void CopyTemplateWorksheet()
        {

            if (_templateWorksheet != null && _documentWorksheet != null)
            {
                //  delete document worksheet, it should be created new one always from template, We assume changes are done in _template.
                _documentWorksheet.CopyFrom(_templateWorksheet);
                //  Source range
                //CellRange sourceRange = _templateWorksheet.AllocatedRange;
                ////Copy the template worksheet to the document worksheet.
                //_templateWorksheet.Copy(sourceRange, _documentWorksheet, _templateWorksheet.FirstRow, _templateWorksheet.FirstColumn, true);
            }
        }
        /// <summary>
        /// 
        /// </summary>
        void PrepareInvoice()
        {
            if (_tablixes == null) return;

            #region Build Data Tables
            int index = 1;
            _tablixes[0].RowIndex = _tablixes[0].Position.R1 + 1;
            //foreach (Tablix tablix in Tablixes)

            for (int t = 0; t < _tablixes.Count; t++)
            {
                Tablix tablix = _tablixes[t];
                //  Dataset worksheet to be used for wip tablix table
                Worksheet reportWorksheet = _snapshotInfo.ReplicaWorkbook.Worksheets[tablix.ReportSheetDataset];
                tablix.DataTable = reportWorksheet.ExportDataTable();
                //  Group by Columns
                string aggregationColumns = tablix.AggregationList.Where(x => x.Field != "").Aggregate("", (current, psColumn) => current + (psColumn.Field + ",")).TrimEnd(',');
                //  Calculate Offset between previous tablix & current table
                int rowOffset = 0;
                if (t != 0 && (_tablixes[t - 1] != null))
                {
                    //  current tablix header row index index - previous tablix table end position
                    rowOffset = tablix.Position.R1 - _tablixes[t - 1].Position.R2;
                    tablix.RowIndex += _tablixes[t - 1].RowIndex + rowOffset;
                }
                //  Start of the tablix, this can be vary when multiple table is present
                int tablixRowStart = tablix.RowIndex;
                //  Clear data rows drawn from template
                this.ClearDataRows(tablix);

                //  Datarow sample template row to copy
                int dataRow = tablix.Position.R1 + 1;
                CellRange sourceRange = _templateWorksheet.GetCellRange(tablix);// _templateWorksheet.Range["A11:G11"];
                //  Normal Table
                if (string.IsNullOrEmpty(aggregationColumns))
                {
                    for (int i = 0; i < tablix.DataTable.Rows.Count; i++)
                    {
                        int currentRow = tablix.RowIndex;
                        //  insert a blank row
                        _documentWorksheet.InsertRow(currentRow);
                        //Set the destination range
                        CellRange destRange = _documentWorksheet.GetCellRange(tablix, tablix.RowIndex);// "A" + (tablix.RowIndex + 1) + ":G" + (tablix.RowIndex + 1);
                        //Copy the range data with style
                        CopyRangeOptions copyOptions = CopyRangeOptions.All;
                        sourceRange.Copy(destRange, copyOptions);

                        for (int j = tablix.Position.C1; j <= tablix.Position.C2; j++)
                        {
                            //  Excel sheet Table column header
                            string fieldName = this._templateWorksheet.Range[tablix.Position.R1, j].Value;
                            string field = tablix.Columns.Where(x => x.Label == fieldName).Select(y => y.Field).FirstOrDefault();
                            if (string.IsNullOrEmpty(field))
                            {
                                //  table column is unmapped to worksheet table
                                continue;

                            }
                            else
                                this._documentWorksheet.Range[tablix.RowIndex, j].Value = tablix.DataTable.Rows[i][field].ToString();
                        }
                        tablix.Position.EndRange = tablix.RowIndex;
                        tablix.RowIndex++;
                    }
                    //  Unwanted row
                    //_documentWorksheet.DeleteRow(tablix.Position.EndRange -1);
                    CellRange range = _documentWorksheet.GetCellRange(tablix, tablix.RowIndex);// _documentWorksheet.Range["A24:G24"];
                    //_documentWorksheet.DeleteRange(range, DeleteOption.MoveUp);
                }

                #region End Of Table Aggregation
                //  End Of Table Aggregation
                foreach (Row row in tablix.EndAggregationList.OrderBy(x => x.Index))
                {
                    CellRange aggregateRange = _templateWorksheet.GetCellRange(tablix, row.Index);
                    _documentWorksheet.InsertRow(tablix.RowIndex);
                    CellRange destRange = _documentWorksheet.GetCellRange(tablix, tablix.RowIndex);// "A" + (tablix.RowIndex + 1) + ":G" + (tablix.RowIndex + 1);
                    //Copy the range data with style
                    CopyRangeOptions copyOptions = CopyRangeOptions.All;
                    aggregateRange.Copy(destRange, copyOptions);

                    foreach (CellRange range1 in aggregateRange.Cells)
                    {
                        if (!string.IsNullOrEmpty(range1.DisplayedText))
                        {
                            string value = range1.DisplayedText.ToString();
                            string formula =
                                value.ConvertToFormula(new Position()
                                {
                                    C1 = tablixRowStart,
                                    C2 = tablix.RowIndex - 1// tablix.Position.EndRange //+ groupeDt.Rows.Count - 1
                                });
                            if (value.StartsWith("="))
                            {
                                this._documentWorksheet.Range[tablix.RowIndex, range1.Column].Value = formula;
                            }
                        }
                    }
                    tablix.RowIndex++;
                    tablix.Position.EndRange += 1;
                }
                #endregion
            }


            #endregion
            _snapshotInfo.ReplicaWorkbook.CalculateAllValue();
        }

        private void ClearDataRows(Tablix tablix)
        {
            //  Skip 1 sample data row
            if (tablix != null)
            {
                //Range start = this.InvoiceWorksheet.Cells[tablix.RowIndex, tablix.Position.C2];
                //Range end = this.InvoiceWorksheet.Cells[tablix.RowIndex + tablix.Rows.Count, tablix.Position.C2];

                //Range deleteRange = this.InvoiceWorksheet.get_Range(start, end);
                //deleteRange.EntireRow.Delete(XlDeleteShiftDirection.xlShiftUp);

                CellRange xLSRanges = this._documentWorksheet.GetCellRange(1, tablix.Position.C2, tablix.RowIndex, (tablix.RowIndex - 1) + tablix.Rows.Count);
                if (xLSRanges.RowCount > 1)
                    _documentWorksheet.DeleteRange(xLSRanges, DeleteOption.MoveUp);
            }
        }


        /// <summary>
        /// Get list of dataset (Tablix) for used by document worksheet
        /// </summary>
        /// <returns></returns>
        private List<Tablix> GetListOfDataSetsUsedByInvoiceSheet()
        {
            //  Load xml configuration for this invoice sheet
            string invoiceStructureXml = this.GetInvoiceXMLByInvoiceSheet();
            if (invoiceStructureXml == null)
                return null;

            List<Tablix> listDataSets = new List<Tablix>();

            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.LoadXml(invoiceStructureXml);
            XmlNodeList xmlInvoiceItems = xmlDoc.GetElementsByTagName("InvoiceItems");

            foreach (XmlNode childrenNode in xmlInvoiceItems)
            {
                foreach (XmlElement xmlElementTablix in childrenNode.ChildNodes)
                {
                    Tablix data = new Tablix()
                    {
                        Columns = new List<Column>(),
                        Rows = new List<Row>(),
                        AggregationList = new List<Column>(),
                        EndAggregationList = new List<Row>()
                    };

                    var name = xmlElementTablix.GetAttributeNode("Name");
                    data.ReportSheetDataset = name.Value;
                    data.Position = new Position()
                    {
                        R1 = xmlElementTablix.GetAttributeNode("R1").Value.ToInt(),
                        R2 = xmlElementTablix.GetAttributeNode("R2").Value.ToInt(),
                        C1 = xmlElementTablix.GetAttributeNode("C1").Value.ToInt(),
                        C2 = xmlElementTablix.GetAttributeNode("C2").Value.ToInt(),
                        EndRange = xmlElementTablix.GetAttributeNode("EndRange").Value.ToInt()
                    };

                    //  Column List
                    foreach (XmlElement xmlColumn in xmlElementTablix.ChildNodes)
                    {
                        if (xmlColumn.HasAttributes)
                            data.Columns.Add(new Column() { Label = xmlColumn.GetAttributeNode("Header").Value, Field = xmlColumn.GetAttributeNode("Field").Value });

                    }

                    //  Rows
                    //XmlNodeList rowNodeList = xmlDoc.SelectNodes("Invoice/InvoiceItems/Tablix/Rows/Row");
                    XmlNodeList rowNodeList = xmlElementTablix.SelectNodes("Rows/Row");
                    foreach (XmlElement rowNode in rowNodeList)
                    {
                        var rowIndexNode = rowNode.GetAttributeNode("Index");
                        var rowName = rowNode.GetAttributeNode("Name");
                        data.Rows.Add(new Row() { Index = rowIndexNode.Value.ToInt(), Name = rowName.Value });
                    }

                    //  Grouping and Aggregation Used

                    //XmlNodeList groupNodeList = xmlDoc.SelectNodes("Invoice/InvoiceItems/Tablix/Groups/Group");
                    XmlNodeList groupNodeList = xmlElementTablix.SelectNodes("Groups/Group");
                    foreach (XmlElement groupNode in groupNodeList)
                    {
                        var groupIndex = groupNode.GetAttributeNode("Index");
                        var groupName = groupNode.GetAttributeNode("Name");
                        var type = groupNode.GetAttributeNode("Type");
                        if (type.Value.ToInt() == 0)
                        {
                            //  Aggregation fields in column
                            Column col = data.Columns.FirstOrDefault(x => x.Field == groupName.Value);
                            if (col != null)
                            {
                                col.GroupingIndex = groupIndex.Value.ToInt();
                                col.AggregationRows = new List<Row>();
                                data.AggregationList.Add(col);
                                //  Aggregations
                                foreach (XmlElement aggElement in groupNode.ChildNodes)
                                {
                                    var aggIndex = aggElement.GetAttributeNode("TemplateIndex");
                                    var aggName = aggElement.GetAttributeNode("Name");
                                    var row = data.Rows.FirstOrDefault(x => x.Name == aggName.Value);
                                    if (row != null)
                                        col.AggregationRows.Add(row);
                                }
                            }
                        }
                        else
                        {
                            foreach (XmlElement aggElement in groupNode.ChildNodes)
                            {
                                var aggIndex = aggElement.GetAttributeNode("TemplateIndex");
                                var aggName = aggElement.GetAttributeNode("Name");
                                var row = data.Rows.FirstOrDefault(x => x.Name == aggName.Value);
                                if (row != null)
                                    data.EndAggregationList.Add(row);
                            }
                        }

                    }

                    listDataSets.Add(data);
                }
            }
            return listDataSets;
        }

        /// <summary>
        /// Get XML Configuration of document worksheet
        /// </summary>
        /// <returns>XML</returns>
        public string GetInvoiceXMLByInvoiceSheet()
        {
            Worksheet invoiceConfig = _snapshotInfo.ReplicaWorkbook.Worksheets["Invoice Configuration"];
            if (invoiceConfig != null)
            {
                foreach (CellRange row in invoiceConfig.Rows)
                {
                    if (row[row.Row, 1].Text.ToLower() == this._documentWorksheet.Name.ToLower())
                        return row[row.Row, 2].Text;
                }
            }
            return null;
        }
    }
}
