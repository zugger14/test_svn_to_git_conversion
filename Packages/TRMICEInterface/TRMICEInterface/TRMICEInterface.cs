using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using QuickFix;
using QuickFix.Fields;
using System.Collections.Generic;
using Microsoft.SqlServer.Server;
using System.Xml.Linq;
using System.Diagnostics;

namespace TRMICEInterface
{
    public class TradeClientApp : QuickFix.MessageCracker, QuickFix.IApplication
    {
        Session _session = null;
        public static List<string> stackProcess = new List<string>();
        public IInitiator MyInitiator = null;
        static DateTime request_date = new DateTime();
        static string user_name = null;
        static string user_password = null;
        public static string fix_message = "";
        static string config_file = null;
        static string market_type = null;
        static string config_log_file_path = null;
        static string process_table = null;
        static string debug_mode = "0";
        static string final_sql = null;

        static List<TradeData> lstTradeData = new List<TradeData>();
        static List<SecurityDefinitionData> lstSecurityDefinitionData = new List<SecurityDefinitionData>();

        #region IApplication interface overrides

        public static void ImportICEDeal(string as_of_date, string confile_file_path, string username, string password, string processTableName, string log_file_path, string debugmode)
        {
            try
            {
                user_name = username;
                user_password = password;
                config_file = confile_file_path;
                config_log_file_path = log_file_path;
                process_table = processTableName;
                debug_mode = debugmode;
                fix_message = "";
                final_sql = "";
                TradeClientApp application = new TradeClientApp();
                application.Run("Deal");

                System.Threading.Thread.Sleep(30000);
                if (config_log_file_path != "")
                {
                    string log_file_name = DateTime.Now.ToString("yyyyMMddHHmmssfff");
                    System.IO.File.WriteAllText(@"" + config_log_file_path + log_file_name + ".txt", fix_message);
                }

                ProcessDealinStaging();
                using (SqlConnection sqlConnection = new SqlConnection("Context Connection=true"))
                {
                    sqlConnection.Open();
                    ExecuteQuery(final_sql, sqlConnection);
                }

                lstTradeData.Clear();
                //System.IO.File.WriteAllText(@"D:\Temp\FIX\Writequery.txt", final_sql);
                //application._session.Disconnect("Close");
            }
            catch (Exception ex)
            {
                LogError(ex, "Deal Import from ICE", stackProcess);
            }
        }

        public static void ImportSecurityDefinition(string security_id, string confile_file_path, string username, string password, string processTableName, string log_file_path, string debugmode)
        {
            try
            {
                user_name = username;
                user_password = password;
                config_file = confile_file_path;
                config_log_file_path = log_file_path;
                market_type = security_id;
                process_table = processTableName;
                debug_mode = debugmode;
                fix_message = "";
                final_sql = "";
                TradeClientApp application = new TradeClientApp();
                application.Run("SD");

                

                if (config_log_file_path != "")
                {
                    string log_file_name = DateTime.Now.ToString("yyyyMMddHHmmssfff");
                    System.IO.File.WriteAllText(@"" + config_log_file_path + log_file_name + ".txt", fix_message);
                }
                
                ProcessSecurityDefinitioninStaging();
                using (SqlConnection sqlConnection = new SqlConnection("Context Connection=true"))
                {
                    sqlConnection.Open();
                    ExecuteQuery(final_sql, sqlConnection);
                }

                //System.IO.File.WriteAllText(@"D:\Temp\FIX\Writequery.txt", final_sql);
                lstSecurityDefinitionData.Clear();
            }
            catch (Exception ex)
            {
                LogError(ex, "Security Definition Import from ICE", stackProcess);
            }
        }


        private void Run(string run_type)
        {

            try
            {

                QuickFix.SessionSettings settings = new QuickFix.SessionSettings(config_file);
                TradeClientApp application = new TradeClientApp();

                QuickFix.IMessageStoreFactory storeFactory = new QuickFix.FileStoreFactory(settings);

                if (debug_mode == "0")
                {
                    FileLogFactory logfactory = new FileLogFactory(settings);
                    QuickFix.Transport.SocketInitiator initiator = new QuickFix.Transport.SocketInitiator(application, storeFactory, settings, logfactory);
                    InitiateSession(application, initiator, run_type);

                }
                else
                {
                    QuickFix.ILogFactory logfactory = new QuickFix.ScreenLogFactory(settings);
                    QuickFix.Transport.SocketInitiator initiator = new QuickFix.Transport.SocketInitiator(application, storeFactory, settings, logfactory);
                    InitiateSession(application, initiator, run_type);
                }

            }
            catch (Exception ex)
            {
                LogError(ex, "Run Application", stackProcess);
            }

        }

        private void InitiateSession(TradeClientApp application, QuickFix.Transport.SocketInitiator initiator, string run_type)
        {

            try
            {

                initiator.Start();
                application._session.CheckLatency = false;
                //application._session.MaxLatency = 2000;
                System.Threading.Thread.Sleep(5000);

                if (run_type == "Deal")
                {
                    application.QueryTradeCaptureReport();
                }
                else if (run_type == "SD")
                {
                    application.QuerysecurityDefinition(market_type);
                }
                //application._session.Disconnect("Close");
                //application._session.Dispose();
                System.Threading.Thread.Sleep(30000);
                initiator.Stop();
                

            }
            catch (Exception ex)
            {
                LogError(ex, "Initiate Session", stackProcess);
            }

        }

        private void QueryTradeCaptureReport()
        {

            QuickFix.FIX44.TradeCaptureReportRequest tradeReport = new QuickFix.FIX44.TradeCaptureReportRequest();
            tradeReport.SetField(new TradeRequestID("100"));
            tradeReport.SetField(new TradeRequestType(0));
            tradeReport.SetField(new SubscriptionRequestType('0'));
            tradeReport.SetField(new NoDates(1));
            tradeReport.SetField(new TransactTime(request_date));
            tradeReport.SetField(new TradeDate(request_date.ToString("yyyyMMdd")));
            tradeReport.SubscriptionRequestType = new SubscriptionRequestType(SubscriptionRequestType.SNAPSHOT_PLUS_UPDATES);
            Session.SendToTarget(tradeReport, _session.SessionID);
        }


        private void QuerysecurityDefinition(string security_id)
        {
            string newID = Guid.NewGuid().ToString("N");
            System.Threading.Thread.Sleep(5000);
            QuickFix.FIX44.SecurityDefinitionRequest sdr = new QuickFix.FIX44.SecurityDefinitionRequest();
            sdr.SetField(new SecurityReqID(newID));
            sdr.SetField(new SecurityRequestType(3));
            sdr.SetField(new SecurityID(security_id));
            //sdr.SetField(new CFICode("OXXXXX"));
            Session.SendToTarget(sdr, _session.SessionID);


        }


        #endregion


        #region FIX Session handler

        public void OnCreate(SessionID sessionID)
        {
            _session = Session.LookupSession(sessionID);
        }

        public void OnLogon(SessionID sessionID)
        {
            Console.WriteLine("Logon - " + sessionID.ToString());
        }

        public void OnLogout(SessionID sessionID)
        {
            Session.LookupSession(sessionID).Logout();
            Console.WriteLine("Logout - " + sessionID.ToString());
        }

        public void FromAdmin(Message message, SessionID sessionID)
        {
            Console.WriteLine("From Admin:  " + message.ToString());
            try
            {
                Crack(message, sessionID);
            }
            catch (Exception ex)
            {
                Console.WriteLine("==Cracker exception==");
                Console.WriteLine(ex.ToString());
                Console.WriteLine(ex.StackTrace);

            }
        }

        public void ToAdmin(Message message, SessionID sessionID)
        {
            message.SetField(new StringField(9006, "0"));
            message.SetField(new QuickFix.Fields.Username(user_name));
            message.SetField(new QuickFix.Fields.Password(user_password));
            //message.SetField(new EncryptMethod(EncryptMethod.NONE));

        }

        public void FromApp(Message message, SessionID sessionID)
        {

            MsgType msgType = new MsgType();
            message.Header.GetField(msgType);
            string msgTypeValue = msgType.getValue();
            Console.WriteLine("From App:  " + message.ToString());
            fix_message = fix_message + message.ToString();
           

            try
            {
                Crack(message, sessionID);
            }
            catch (Exception ex)
            {
                Console.WriteLine("==Cracker exception==");
                Console.WriteLine(ex.ToString());
                Console.WriteLine(ex.StackTrace);
                //LogError(ex, "==Cracker exception==", stackProcess);
            }
        }

        public void ToApp(Message message, SessionID sessionID)
        {
            try
            {
                bool possDupFlag = false;
                if (message.Header.IsSetField(QuickFix.Fields.Tags.PossDupFlag))
                {
                    possDupFlag = QuickFix.Fields.Converters.BoolConverter.Convert(
                        message.Header.GetField(QuickFix.Fields.Tags.PossDupFlag)); /// FIXME
                }
                if (possDupFlag)
                    throw new DoNotSend();
            }
            catch (FieldNotFoundException)
            { }

            Console.WriteLine();
            Console.WriteLine("OUT: " + message.ToString());
        }
        #endregion


        #region MessageCracker handlers

        public void OnMessage(QuickFix.FIX44.ExecutionReport m, SessionID s)
        {
            Console.WriteLine("Received execution report");
        }

        public void OnMessage(QuickFix.FIX44.OrderCancelReject m, SessionID s)
        {
            Console.WriteLine("Received order cancel reject");
        }


        public void OnMessage(QuickFix.FIX44.TradeCaptureReportRequestAck m, SessionID s)
        {

            string TradeRequestID = m.GetField(new TradeRequestID()).ToString();
            Console.WriteLine(TradeRequestID);

        }

        public void OnMessage(QuickFix.FIX44.TradeCaptureReportAck m, SessionID s)
        {
            Console.WriteLine("Received Trade Capture Report ACK:" + m.TradeReportID.ToString());

        }

        public void OnMessage(QuickFix.FIX44.TradeCaptureReport m, SessionID s)
        {
            try
            {
                string TradeReportID = null;
                string OrigTradeID = null;
                if (m.IsSetField(new OrigTradeID()))
                {
                    TradeReportID = m.GetField(new TradeRequestID()).ToString();
                }
                //string TradeReportTransType = m.GetField(new TradeReportTransType()).ToString();
                string TradeReportType = "0";
                //string TrdType = m.GetField(new TrdType()).ToString();
                string Symbol = m.GetField(new Symbol()).ToString();
                string StartDate = m.GetField(new StartDate()).ToString();
                string EndDate = m.GetField(new EndDate()).ToString();
                string LastQty = m.GetField(new LastQty()).ToString();
                string ExecID = m.GetField(new ExecID()).ToString();
                string CFICode = m.GetField(new CFICode()).ToString();
                //string SecurityID = m.GetField(new SecurityID()).ToString();
                //string SecuritySubType = m.GetField(new SecuritySubType()).ToString();

                string SecurityExchange = m.GetField(new SecurityExchange()).ToString();
                string LastPx = m.GetField(new LastPx()).ToString();
                string TradeDate = m.GetField(new TransactTime()).ToString();
                string OrdStatus = m.GetField(new OrdStatus()).ToString();
                if (m.IsSetField(new OrigTradeID()))
                {
                    OrigTradeID = m.GetField(new OrigTradeID()).ToString();
                }

                string Trader = "";
                string PartyRole = "";
                string sideID = "";
                string OrderID = "";
                string ClOrdID = "";
                string NoPartyIDs = "";
                string Counterparty = "";


                QuickFix.FIX44.TradeCaptureReport.NoSidesGroup sidesGroup = new QuickFix.FIX44.TradeCaptureReport.NoSidesGroup();
                m.GetGroup(1, sidesGroup);


                for (int grpIndex = 1; grpIndex <= m.GetInt(Tags.NoSides); grpIndex += 1)
                {
                    m.GetGroup(grpIndex, sidesGroup);
                    sideID = sidesGroup.Get(new Side()).ToString();
                    OrderID = sidesGroup.Get(new OrderID()).ToString();
                    ClOrdID = sidesGroup.Get(new ClOrdID()).ToString();
                    NoPartyIDs = sidesGroup.Get(new NoPartyIDs()).ToString();
                }

                if (Int32.Parse(NoPartyIDs) > 0)
                {
                    QuickFix.FIX44.TradeCaptureReport.NoSidesGroup.NoPartyIDsGroup PartyIDsGroup = new QuickFix.FIX44.TradeCaptureReport.NoSidesGroup.NoPartyIDsGroup();
                    for (int grpIndex = 1; grpIndex <= Int32.Parse(NoPartyIDs); grpIndex += 1)
                    {
                        sidesGroup.GetGroup(grpIndex, PartyIDsGroup);
                        PartyRole = PartyIDsGroup.Get(new PartyRole()).ToString();
                        if (PartyRole == "11")
                        {
                            Trader = PartyIDsGroup.Get(new PartyID()).ToString();
                        }
                        else if (PartyRole == "17")
                        {
                            Counterparty = PartyIDsGroup.Get(new PartyID()).ToString();
                        }
                    }
                }

                lstTradeData.Add(new TradeData { RequestID = TradeReportID, DealID = ExecID, TermStart = StartDate, TermEnd = EndDate, TradeType = TradeReportType, ProductID = Symbol, TradePrice = LastPx, TradeVolume = LastQty, Trader = Trader, Counterparty = Counterparty, TradeDate = TradeDate, b_s = sideID, OrigDealID = OrigTradeID, DealStatus = OrdStatus });
                

            }
            catch (Exception ex)
            {
                LogError(ex, "Trade Capture Message", stackProcess);
            }

        }

        public void OnMessage(QuickFix.FIX44.SecurityDefinition secDef, SessionID s)
        {

            try
            {
                string ExchangeSilo = secDef.GetString(9064);
                //string Symbol = secDef.GetField(new Symbol()).ToString();

                QuickFix.FIX44.SecurityDefinition.NoUnderlyingsGroup UnderlyingsGroup = new QuickFix.FIX44.SecurityDefinition.NoUnderlyingsGroup();
                
                for (int grpIndex = 1; grpIndex <= secDef.GetInt(Tags.NoUnderlyings); grpIndex += 1)
                {
                    secDef.GetGroup(grpIndex, UnderlyingsGroup);
                    string SecurityID = UnderlyingsGroup.GetString(311);
                    string ProductName = UnderlyingsGroup.GetString(9062);
                    string Granularity = UnderlyingsGroup.GetString(9085);
                    string TickValue = UnderlyingsGroup.GetString(9032);
                    string UnitOfMeasure = UnderlyingsGroup.GetString(998);
                    string Currency = UnderlyingsGroup.GetString(9100);
                    string HubName = UnderlyingsGroup.GetString(9301);
                    string CFICode = UnderlyingsGroup.GetString(463);
                    string HubAlias = UnderlyingsGroup.GetString(9302);
                    string file_name = Guid.NewGuid().ToString("N");
                    lstSecurityDefinitionData.Add(new SecurityDefinitionData { ProductID = SecurityID, ExchangeName = ExchangeSilo, ProductName = ProductName, Granularity = Granularity, TickValue = TickValue, UOM = UnitOfMeasure, HubName = HubName, Currency = Currency, CFICode = CFICode, HubAlias = HubAlias });
                }

                //System.IO.File.WriteAllText(@"D:\\Temp\\FIX\\TRMICEInterface\\logfile\\file.txt", fix_message);
                //

            }
            catch (Exception ex)
            {
                LogError(ex, "Security Definition Message", stackProcess);
            }

        }



        #endregion


        #region Data Processing

        private static void ProcessDealinStaging()
        {

            try
            {

                string RequestID = null;
                string DealID = null;
                string TermStart = null;
                string TermEnd = null;
                string TradeVolume = null;
                string TradePrice = null;
                string TradeType = null;
                string ProductID = null;
                string Counterparty = null;
                string Trader = null;
                string TradeDate = null;
                string query = null;

                string leg_id = null;
                string b_s = null;
                string hub = null;
                string strike = null;
                string option = null;
                string strike2 = null;
                string style = null;
                string qty_unit = null;
                string periods = null;
                string price_unit = null;
                //string total_qty = null;
                string trader_id = null;
                string pipeline = null;
                string state = null;
                string strip = null;
                string DealStatus = null;
                string OrigDealID = null;


                foreach (var TradeData in lstTradeData)
                {
                    RequestID = TradeData.RequestID;
                    DealID = TradeData.DealID;
                    TermStart = TradeData.TermStart;
                    TermEnd = TradeData.TermEnd;
                    TradeVolume = TradeData.TradeVolume;
                    TradePrice = TradeData.TradePrice;
                    TradeType = TradeData.TradeType;
                    ProductID = TradeData.ProductID;
                    Counterparty = TradeData.Counterparty;
                    Trader = TradeData.Trader;
                    TradeDate = TradeData.TradeDate;
                    b_s = TradeData.b_s;
                    OrigDealID = TradeData.OrigDealID;
                    DealStatus = TradeData.DealStatus;
                   // query = @"Insert into " + process_table + "(Trade_date, Trade_time, deal_id,leg, Orig_ID, b_s, Product, Hub, Strip,[Begin date],[End date],[OPTION], Strike, Strike2, Style, Counterparty, Price, Price_unit, periods,[total quantity],[qty units], trader,[authorized trader id], Pipeline, STATE,deal_status) values('" + TradeDate + "', '" + TradeDate + "', '" + DealID + "', '" + leg_id + "', '" + OrigDealID + "', '" + b_s + "', '" + ProductID + "', '" + hub + "', '" + strip + "', '" + TermStart + "', '" + TermEnd + "', '" + option + "', '" + strike + "', '" + strike2 + "', '" + style + "', '" + Counterparty + "', '" + TradePrice + "', '" + price_unit + "', '" + periods + "', '" + TradeVolume + "', '" + qty_unit + "', '" + Trader + "', '" + trader_id + "', '" + pipeline + "', '" + state + "', '" + DealStatus + "')";
                     query = @"Insert into " + process_table + "(Trade_date, Trade_time, deal_id,leg, Orig_ID, buy_sell_flag, Product, Hub, Strip,term_start,term_end,option_price, strike_price, strike2_price, Style, Counterparty, Price, Price_unit,periods,total_volume,volume_uom, trader,[authorized_trader_id], Pipeline, STATE,deal_status) values('" + TradeDate + "', '" + TradeDate + "', '" + DealID + "', '" + leg_id + "', '" + OrigDealID + "', '" + b_s + "', '" + ProductID + "', '" + hub + "', '" + strip + "', '" + TermStart + "', '" + TermEnd + "', '" + option + "', '" + strike + "', '" + strike2 + "', '" + style + "', '" + Counterparty + "', '" + TradePrice + "', '" + price_unit + "', '" + periods + "', '" + TradeVolume + "', '" + qty_unit + "', '" + Trader + "', '" + trader_id + "', '" + pipeline + "', '" + state + "', '" + DealStatus + "')";

                    final_sql = final_sql + "\n" + query;
                }



            }
            catch (Exception ex)
            {

                LogError(ex, "Deal Process in staging Table", stackProcess);
            }

        }


        private static void ProcessSecurityDefinitioninStaging()
        {

            try
            {
                string ProductID = null;
                string ExchangeName = null;
                string ProductName = null;
                string Granularity = null;
                string TickValue = null;
                string UOM = null;
                string HubName = null;
                string HubAlias = null;
                string Currency = null;
                string CFICode = null;
                string query = null;
                final_sql = "";
                int count = 0;

                foreach (var SecurityDefinitionData in lstSecurityDefinitionData)
                {
                    ProductID = SecurityDefinitionData.ProductID;
                    ExchangeName = SecurityDefinitionData.ExchangeName;
                    ProductName = SecurityDefinitionData.ProductName;
                    Granularity = SecurityDefinitionData.Granularity;
                    TickValue = SecurityDefinitionData.TickValue;
                    UOM = SecurityDefinitionData.UOM;
                    HubName = SecurityDefinitionData.HubName;
                    Currency = SecurityDefinitionData.Currency;
                    CFICode = SecurityDefinitionData.CFICode;
                    HubAlias = SecurityDefinitionData.HubAlias;
                    HubName = HubName.Replace("'", "");
                    HubAlias = HubAlias.Replace("'", "");

                    query = @"Insert into " + process_table + "(product_id, exchange_name, product_name, granularity, tick_value, uom, hub_name, currency,cfi_code,hub_alias) values('" + ProductID + "', '" + ExchangeName + "', '" + ProductName + "', '" + Granularity + "', '" + TickValue + "','" + UOM + "', '" + HubName + "', '" + Currency + "', '" + CFICode + "', '" + HubAlias + "')";
                    final_sql = final_sql + "\n" + query;
                    count = count + 1;
                }

                //System.IO.File.WriteAllText(@"D:\Temp\FIX\countdata.txt", count.ToString());
                //lstSecurityDefinitionData.Clear();                   

            }
            catch (Exception ex)
            {
                LogError(ex, "Security Definition Process in staging Table", stackProcess);

            }

        }



        private static void ExecuteQuery(string query, SqlConnection sqlConnection)
        {
            SqlCommand cmd = new SqlCommand(query, sqlConnection);
            cmd.ExecuteNonQuery();
        }

        #endregion


        #region Error Logging

        public static void LogError(Exception ex, string eventLogDescription, List<string> stackProcess = null)
        {
            string processId = Guid.NewGuid().ToString().Replace("-", "").ToUpper();
            XDocument xDoc = new XDocument();
            if (stackProcess != null)
            {
                if (stackProcess.Count > 0)
                {
                    XElement element = new XElement("ProcessLog");
                    int i = 1;
                    foreach (string log in stackProcess)
                    {
                        XElement elementLog = new XElement(new XElement("Log", new XElement("Id", i), new XElement("Description", log)));
                        element.Add(elementLog);
                        i++;
                    }
                    xDoc.Add(element);
                }
            }

            StackTrace st = new StackTrace();
            StackFrame sf = st.GetFrame(1);

            string assemblyMethod = sf.GetMethod().Name;
            string sqlCmd = "";
            using (SqlConnection cn = new SqlConnection("Context Connection = True"))
            {
                cn.Open();

                using (SqlCommand cmd = new SqlCommand(sqlCmd, cn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "spa_clr_error_log";
                    cmd.Parameters.AddWithValue("flag", "i");
                    cmd.Parameters.AddWithValue("event_log_description", eventLogDescription);
                    cmd.Parameters.AddWithValue("assembly_method", assemblyMethod);
                    cmd.Parameters.AddWithValue("message", ex.Message);
                    cmd.Parameters.AddWithValue("inner_exception", ex.InnerException);
                    cmd.Parameters.AddWithValue("stack_trace", ex.StackTrace);
                    cmd.Parameters.AddWithValue("process_id", processId);
                    cmd.Parameters.AddWithValue("process_log", xDoc.ToString());
                    try
                    {
                        cmd.ExecuteNonQuery();
                    }
                    catch (Exception ex1)
                    {

                        throw ex1;
                    }

                }
            }
        }

        #endregion

    }


    public class TradeData
    {
        public string RequestID { set; get; }
        public string TradeType { set; get; }
        public string ProductID { set; get; }
        public string TermStart { set; get; }
        public string TermEnd { set; get; }
        public string TradeVolume { set; get; }
        public string TradePrice { set; get; }
        public string DealID { set; get; }
        public string Counterparty { set; get; }
        public string Trader { set; get; }
        public string TradeDate { set; get; }

        public string leg_id { set; get; }
        public string orig_id { set; get; }
        public string b_s { set; get; }
        public string hub { set; get; }
        public string strike { set; get; }
        public string option { set; get; }
        public string strike2 { set; get; }
        public string style { set; get; }
        public string qty_unit { set; get; }
        public string periods { set; get; }
        public string price_unit { set; get; }
        public string total_qty { set; get; }
        public string trader_id { set; get; }
        public string pipeline { set; get; }
        public string state { set; get; }
        public string strip { set; get; }
        public string OrigDealID { set; get; }
        public string DealStatus { set; get; }
    }

    public class SecurityDefinitionData
    {
        public string ProductID { set; get; }
        public string ExchangeName { set; get; }
        public string ProductName { set; get; }
        public string Granularity { set; get; }
        public string TickValue { set; get; }
        public string UOM { set; get; }
        public string Currency { set; get; }
        public string HubName { set; get; }
        public string CFICode { set; get; }
        public string HubAlias { set; get; }

    }
}