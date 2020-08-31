using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSExportCLR
{
    public class WebServiceDataDispatcherFactory
    {
        /// <summary>
        /// Factory method for collection of export function subclasses
        /// </summary>
        public static IWebServiceDataDispatcher GetWebServiceDispatcher(ExportWebServiceInfo exportWebServiceInfo)
        {  
            //Data access object
            switch (exportWebServiceInfo.handlerClassName)
            {
                case "AFASFIEntriesExporter":
                    return new AFASFIEntriesExporter();
                case "EgssisEntriesExporter":
                    return new EgssisEntriesExporter();
                case "RegisTrExporter":
                    return new RegisTrExporter();
                case "EgssisCapacityBooking":
                    return new EgssisCapacityBooking();
                case "NordpoolExporter":
                    return new NordpoolExporter();
                case "GatsPjmTransferRecsExporter":
                    return new GatsPjmTransferRecsExporter();
                case "NepoolTransferRequestExporter":
                    return new NepoolTransferRequestExporter();
                case "EznergyTDSExporter":
                    return new EznergyTDSExporter();
                //add here for new implementation
               // case "XYZExporter":
                //    return new XYZExporter();
                    
                default:
                    throw new InvalidOperationException(String.Format("Class {0} not found", exportWebServiceInfo.handlerClassName));
            }
        }

    }
}
