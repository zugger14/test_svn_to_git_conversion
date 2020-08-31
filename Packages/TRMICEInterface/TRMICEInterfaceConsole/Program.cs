using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using TRMICEInterface;

namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {

                TradeClientApp application = new TradeClientApp();
                //application.ImportICEDeal("2017-01-12", "tradeclient.cfg", "mlight-dcfx", "Starts123", "adiha_process.dbo.IceInterface", "D:\\Temp\\FIX\\logfile\\","1");
                application.ImportICEDeal("2017-03-22", "D:\\Temp\\FIX\\TRMICEInterface\\tradeclient.cfg", "piotcvend_dcfx1", "Starts123", "adiha_process.dbo.IceInterface", "D:\\Temp\\FIX\\TRMICEInterface\\logfile\\", "1");
                //application.ImportSecurityDefinition("305", "tradeclient.cfg", "mem-dcfx", "Memphis.23", "adiha_process.dbo.IceInterface", "D:\\Temp\\FIX\\TRMICEInterface\\logfile\\", "1");
                //application.ImportSecurityDefinition("305", "tradeclient.cfg", "mlight-dcfx", "Starts123", "adiha_process.dbo.IceInterface", "D:\\Temp\\FIX\\TRMICEInterface\\logfile\\", "1");
                //Console.ReadKey();
            }
            catch (System.Exception e)
            {
                Console.WriteLine(e.Message);
                Console.WriteLine(e.StackTrace);
            }
            Console.ReadKey();
        }
    }
}
