using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    class ExcelFactory
    {
        public static ISnapshot GetSnapshot(DocumentType documentType)
        {
            switch (documentType)
            {
                case DocumentType.CalculationEngine:    //  Calcualtion Engine
                    return new Calculation();
                case DocumentType.DocumentGeneration:   //  DocumentGeneration
                    return new DocumentGeneration();
                case DocumentType.Report:               //  Report
                    return new ReportGeneration();
                default:
                    return new ReportGeneration();
            }
        }
    }
}
