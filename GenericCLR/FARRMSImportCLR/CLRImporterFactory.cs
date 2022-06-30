using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSImportCLR
{
    /// <summary>
    /// Factory method for collection of Import function subclasses
    /// </summary>
    class CLRImporterFactory
    {
        /// <summary>
        /// Interface for Import Subclasses
        /// </summary>
        /// <param name="clrImportInfo">Information of Import Data Sources</param>
        /// <returns></returns>
        public static ICLRImporter GetCLRImporter(CLRImportInfo clrImportInfo)
        {
            
            //Data access object
            //to upper
            switch (clrImportInfo.MethodName)
            {
                case "TreasuryImporter":
                     return new TreasuryImporter(); 
                case  "EAODailyImbalancePriceImporter":
                    return new EAODailyImbalancePriceImporter();
                case "PlattsPriceImporter":
                    return new PlattsPriceImporter();
                case "PowerfactorMntlyVolsImporter":
                    return new PowerfactorMntlyVolsImporter();
                case "GatsPjmGetRecs":
                    return new GatsPjmGetRecs();
                case "LocusEnergyMntlyVolsImporter":
                    return new LocusEnergyMntlyVolsImporter();
                case "NepoolTransferablePosImporter":
                    return new NepoolDataImporter("GetTransferablePositions");
                case "PowerTrackMntlyVolsImporter":
                    return new PowerTrackMntlyVolsImporter();
                case "EPEXRetrieveMarketResultsForDayAheadImporter":
                    return new EPEXRetrieveMarketResultsForImporter("DayAhead");
                case "LikronImporter":
                    return new LikronImporter();
                case "PrismaImporter":
                    return new PrismaImporter();
                case "ENMACCImporter":
                    return new ENMACCImporter();
                default:
                    throw new InvalidOperationException(String.Format("Class {0} not found", clrImportInfo.MethodName));
            }
        }
    }
}
