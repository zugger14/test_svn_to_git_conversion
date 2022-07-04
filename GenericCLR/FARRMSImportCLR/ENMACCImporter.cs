using System;
using System.Data.SqlClient;
using System.Net;
using System.IO;
using FARRMSUtilities;
using Newtonsoft.Json.Linq;
using System.Data;

namespace FARRMSImportCLR
{
    /// <summary>
    /// Get trade and shape detail from ENMACC interface
    /// </summary>
    class ENMACCImporter : CLRWebImporterBase
    {
        string ws_name;
        string responseFromServer;
        string url;

        /// <summary>
        /// Generate Token to be used while calling different method in API
        /// </summary>
        /// <param name="clrImportInfo"></param>
        /// <returns>bool true/false</returns>
        public bool GenerateToken(CLRImportInfo clrImportInfo)
        {
            bool status = true;
            try
            {
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);
                HttpWebRequest webRequest = (HttpWebRequest)HttpWebRequest.Create(clrImportInfo.WebServiceInfo.AuthUrl);
                webRequest.Method = "POST";
                webRequest.ContentType = "application/json";
                webRequest.Headers.Add("x-api-key", clrImportInfo.WebServiceInfo.ApiKey);
                string request = clrImportInfo.WebServiceInfo.RequestBody.Replace("<__client_id__>", clrImportInfo.WebServiceInfo.ClientId).Replace("<__client_secret__>", clrImportInfo.WebServiceInfo.ClientSecret);

                using (var writeStream = new StreamWriter(webRequest.GetRequestStream()))
                {
                    writeStream.Write(request);
                    writeStream.Flush();
                    writeStream.Close();
                }

                WebResponse response = webRequest.GetResponse();
                Stream stream = response.GetResponseStream();

                StreamReader reader = new StreamReader(stream);
                responseFromServer = reader.ReadToEnd();
                if (responseFromServer.Contains("access_token"))
                {
                    string new_token = JsonHelper.GetValue(responseFromServer, "access_token");
                    clrImportInfo.WebServiceInfo.Token = new_token;
                    
                    using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                    //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                    {
                        status = true;
                        cn.Open();
                        ws_name = "enmacc";
                        SqlCommand updcmd = new SqlCommand("UPDATE import_web_service SET auth_token = '" + new_token + "' WHERE ws_name = '" + ws_name + "'", cn);
                        SqlDataReader r = updcmd.ExecuteReader();
                        cn.Close();
                    }
                }
                else
                {
                    status = false;
                    throw new Exception(responseFromServer);
                }
            }
            catch (Exception ex)
            {
                status = false;
                ex.LogError("ENMACC Generate Token", ex.Message);
            }
            return status;
        }

        /// <summary>
        /// Get trades from ENMACC interface
        /// </summary>
        /// <param name="clrImportInfo"></param>
        /// <returns>EPEXImportStatus class</returns>
        public ENMACCImportStatus GetTrades(CLRImportInfo clrImportInfo)
        {
            ENMACCImportStatus status = null;

            var responseString = "";
            string commodity = clrImportInfo.Params[0].paramValue;

            if (commodity == "null")
            {
                commodity = "";
            }

            string venue = clrImportInfo.Params[1].paramValue;
            if (venue == "null")
            {
                venue = "";
            }

            string traded_start = clrImportInfo.Params[2].paramValue;
            if (traded_start == "null")
            {
                traded_start = "";
            }
            else
            {
                traded_start = (!string.IsNullOrEmpty(traded_start) ? (traded_start.Contains("Z") ? traded_start : System.Convert.ToDateTime(traded_start).ToString("yyyy-MM-dd HH:mm:ss").Replace(" ", "T") + ".000Z") : "");
            }

            string traded_end = clrImportInfo.Params[3].paramValue;
            if (traded_end == "null")
            {
                traded_end = "";
            }
            else
            {
                traded_end = (!string.IsNullOrEmpty(traded_end) ? (traded_end.Contains("Z") ? traded_end : System.Convert.ToDateTime(traded_end).ToString("yyyy-MM-dd HH:mm:ss").Replace(" ", "T") + ".000Z") : "");
            }

            string skip = clrImportInfo.Params[4].paramValue;
            if (skip == "null")
            {
                skip = "";
            }
            //default value of limit is set to 50 
            string limit = clrImportInfo.Params[5].paramValue;
            if (limit == "null" || string.IsNullOrEmpty(limit) ||limit == "0")
            {
                limit = "50";
            }

            string traded_at = "";
            if(traded_start != "" && traded_end !="")
            {
                traded_at = traded_start + "_" + traded_end;               
            }
            else if(traded_start != "" && traded_end == "")
            {
                //if traded_end is blank then add 7 days to traded start date
                traded_at = traded_start + "_" + System.Convert.ToDateTime(traded_start).AddDays(7).ToString("yyyy-MM-dd HH:mm:ss").Replace(" ", "T") + ".000Z";
            }
            else if (traded_start == "" && traded_end != "")
            {
                //if traded start is blank then reduce traded_end date by 7
                traded_at = System.Convert.ToDateTime(traded_end).AddDays(-7).ToString("yyyy-MM-dd HH:mm:ss").Replace(" ", "T") + ".000Z" + "_" + traded_end;
            }

            url = clrImportInfo.WebServiceInfo.WebServiceURL + "/trades?limit=" + limit;

            //add commodity
            if (!string.IsNullOrEmpty(commodity))
            {
                url = (commodity != "") ? url + "&commodity=" + commodity : url;
            }
            //add venue
            if (!string.IsNullOrEmpty(venue) )
            {
                url = (venue != "") ? url + "&venue=" + venue : url;
            }
            //add traded_at
            if (!string.IsNullOrEmpty(traded_at))
            {
                url = (traded_at != "") ? url + "&traded-at=" + traded_at : url;
            }
            //add skip
            if (!string.IsNullOrEmpty(skip) )
            {
                url = (skip != "") ? url + "&skip=" + skip : url;
            }

            try
            {                
                responseString = GetWebResponse(url, clrImportInfo);

                status = new ENMACCImportStatus { Status = "Success", ResponseMessage = responseString, Exception = null };
            }
            catch (WebException webex)
            {
                if (webex.Status == WebExceptionStatus.ProtocolError)
                {
                    if ((webex.Response as HttpWebResponse).StatusCode == HttpStatusCode.Unauthorized)
                    {
                        status = new ENMACCImportStatus { Status = "Unauthorized", ResponseMessage = responseString, Exception = null };
                    }
                    else
                    {
                        webex.LogError("ENMACC Generate Token Error ", webex.Message);
                    }
                }
            }
            catch (Exception ex)
            {
                ex.LogError("ENMACC Error getting trades ", ex.Message);
            }
            return status;
        }

        /// <summary>
        /// To create a web channel to hit the request and get its reponse
        /// </summary>
        /// <param name="url"></param>
        /// <param name="clrImportInfo"></param>
        /// <returns></returns>
        public string GetWebResponse(string url, CLRImportInfo clrImportInfo)
        {
            WebResponse httpResponse;
            Stream stream;
            StreamReader reader;
            //Proper Secure Sockets Layer (SSL) or Transport Layer Security (TLS) protocol to use for new connections 
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);

            var request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = "GET";
            request.ContentType = "application/json; charset=utf-8";
            request.Headers.Add("Authorization", "Bearer " + clrImportInfo.WebServiceInfo.Token);
            request.Headers.Add("x-api-key", clrImportInfo.WebServiceInfo.ApiKey);

            using (httpResponse = (HttpWebResponse)request.GetResponse())
            {
                using (stream = httpResponse.GetResponseStream())
                {
                    using (reader = new StreamReader(stream))
                    {
                        responseFromServer = reader.ReadToEnd();
                    }
                }
            }
            return responseFromServer;
        }

        public override ImportStatus ImportData(CLRImportInfo clrImportInfo)
        {
            ImportStatus status = null;
            ImportStatus importStatus = new ImportStatus();
            string dataSourceAlias = "enmacc";
            string processTableName = "adiha_process.dbo.temp_import_data_table_" + dataSourceAlias + "_" + clrImportInfo.ProcessID;

            try
            {
                //get trades list as per the parameters passed.
                ENMACCImportStatus WebResponse = GetTrades(clrImportInfo);

                //generate token if token expired and get trades list 
                if (WebResponse.Status == "Unauthorized")
                { 
                    bool token = GenerateToken(clrImportInfo);
                    if (token == false) throw new Exception("Failed to Generate Token.");
                    WebResponse = GetTrades(clrImportInfo);
                }
                
                if (WebResponse.Status == "Success")
                {
                    var response = WebResponse.ResponseMessage;
                    JObject tradeids = JsonHelper.GetJObject(response);
                    
                    using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                    //using (SqlConnection cn = new SqlConnection(@"Data Source=EU-U-SQL03.farrms.us,2033;Initial Catalog=TRMTracker_Enercity_UAT;Persist Security Info=True;User ID=dev_admin;password=Admin2929"))
                    {
                        cn.Open();
                        var finalTable = new string[] { "id", "short_id", "action", "email", "settlement", "term_start", "term_end", "commodity", "load", "market_area", "reference_market", "value", "unit", "pricing_type", "price_value", "price_currency", "counterparty_name", "traded_at", "interval_start", "interval_value" };

                        //  Create process table                         
                        var finalDataTable = Utility.CreateProcessTable(processTableName, finalTable, cn);
                       
                        //loop through all id in items
                        foreach (var result in tradeids["items"])
                        {
                            url = (string)result["_links"]["trade"]["href"];
                       
                            string tdetail = GetWebResponse(url, clrImportInfo);
                        
                            JObject trade_detail = JsonHelper.GetJObject(tdetail);
                            
                            //get href to request load shape details
                            string load_shape_url = (string)trade_detail["quantity"]["ref"];
                            //Console.WriteLine(trade_detail);
                            if (!string.IsNullOrEmpty(load_shape_url))
                            {
                                var loadShapeDetails = GetWebResponse(load_shape_url, clrImportInfo);
                                                             
                                JObject load_shape_detail = JsonHelper.GetJObject(loadShapeDetails);                               
                                
                                foreach( var load_data in load_shape_detail["data"])
                                {
                                    DataRow dtrow = finalDataTable.NewRow();

                                    dtrow["id"] = trade_detail["id"];
                                    dtrow["short_id"] = trade_detail["short-id"];
                                    dtrow["action"] = trade_detail["action"];
                                    dtrow["email"] = trade_detail["execution"]["authority"]["user"]["email"];
                                    dtrow["settlement"] = trade_detail["instrument"]["settlement"];
                                    dtrow["term_start"] = trade_detail["instrument"]["maturity"]["start"];
                                    dtrow["term_end"] = trade_detail["instrument"]["maturity"]["end"];
                                    dtrow["commodity"] = trade_detail["instrument"]["commodity"];
                                    dtrow["load"] = trade_detail["instrument"]["load"];
                                    dtrow["market_area"] = trade_detail["instrument"]["market-area"];
                                    dtrow["reference_market"] = trade_detail["instrument"]["reference-market"];
                                    dtrow["value"] = trade_detail["quantity"]["amount"]["value"];
                                    dtrow["unit"] = trade_detail["quantity"]["amount"]["unit"];
                                    dtrow["pricing_type"] = trade_detail["pricing"]["pricing-type"];
                                    dtrow["price_value"] = trade_detail["pricing"]["price"]["value"];
                                    dtrow["price_currency"] = trade_detail["pricing"]["price"]["currency"];
                                    dtrow["counterparty_name"] = trade_detail["counterparty"]["company"]["name"];
                                    dtrow["traded_at"] = trade_detail["traded-at"];

                                    dtrow["interval_start"] = load_data["interval-start"];
                                    dtrow["interval_value"] = load_data["quantity"]["value"];
                                    finalDataTable.Rows.Add(dtrow);
                                }
                            }
                            else
                            {
                                DataRow dtrow = finalDataTable.NewRow();

                                dtrow["id"] = trade_detail["id"];
                                dtrow["short_id"] = trade_detail["short-id"];
                                dtrow["action"] = trade_detail["action"];
                                dtrow["email"] = trade_detail["execution"]["authority"]["user"]["email"];
                                dtrow["settlement"] = trade_detail["instrument"]["settlement"];
                                dtrow["term_start"] = trade_detail["instrument"]["maturity"]["start"];
                                dtrow["term_end"] = trade_detail["instrument"]["maturity"]["end"];
                                dtrow["commodity"] = trade_detail["instrument"]["commodity"];
                                dtrow["load"] = trade_detail["instrument"]["load"];
                                dtrow["market_area"] = trade_detail["instrument"]["market-area"];
                                dtrow["reference_market"] = trade_detail["instrument"]["reference-market"];
                                dtrow["value"] = trade_detail["quantity"]["amount"]["value"];
                                dtrow["unit"] = trade_detail["quantity"]["amount"]["unit"];
                                dtrow["pricing_type"] = trade_detail["pricing"]["pricing-type"];
                                dtrow["price_value"] = trade_detail["pricing"]["price"]["value"];
                                dtrow["price_currency"] = trade_detail["pricing"]["price"]["currency"];
                                dtrow["counterparty_name"] = trade_detail["counterparty"]["company"]["name"];
                                dtrow["traded_at"] = trade_detail["traded-at"];

                                finalDataTable.Rows.Add(dtrow);
                            }
                        }//foreach close                          

                        // insert data from datatable into process table
                        using (SqlDataAdapter adapter = new SqlDataAdapter("SELECT * FROM " + processTableName, cn))
                        {
                            using (SqlCommandBuilder builder = new SqlCommandBuilder(adapter))
                            {
                                builder.GetInsertCommand();
                                adapter.Update(finalDataTable );                                                               
                            }
                        }
                        
                        importStatus.ProcessTableName = processTableName;
                        importStatus.Status = "Success";
                        importStatus.ResponseMessage = "Data inserted in Process table successfully";
                        cn.Close();
                    }
                }
            }
            catch (WebException webEx)
            {
                importStatus.ProcessTableName = processTableName;
                importStatus.Status = "Failed";
                importStatus.Exception = webEx;
                importStatus.ResponseMessage = webEx.Message;
                webEx.LogError("ENMACC",  processTableName + "|" + webEx.Message);
            }
            catch (Exception ex)
            {
                importStatus.ProcessTableName = processTableName;
                importStatus.Status = "Failed";
                importStatus.Exception = ex;
                importStatus.ResponseMessage = ex.Message;
                ex.LogError("ENMACC",  processTableName + "|" + ex.Message);
            }
            
            return importStatus;
        }
        public class ENMACCImportStatus
        {
            public string Status { get; set; }
            public string ResponseMessage { get; set; }
            public Exception Exception { get; set; }
        }
    }
}
