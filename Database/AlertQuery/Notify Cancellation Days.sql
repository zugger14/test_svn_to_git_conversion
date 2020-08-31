IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL
 	DROP TABLE #temp_deals

IF OBJECT_ID('tempdb..#temp_canc_message') IS NOT NULL
 	DROP TABLE #temp_canc_message
CREATE TABLE #temp_canc_message ([Report Message] VARCHAR(500))

SELECT  * INTO #temp_deals 
FROM (
SELECT source_deal_header_id,counterparty_id,  entire_term_End, renew_granularity, cancellation_notice_days,  evergreen_deal, cancel_date, cancellation_alert_days
FROM
(
  SELECT sdh.source_deal_header_id, sdh.counterparty_id, sdh.entire_term_End
  , CASE WHEN uddft.field_name = -10000185 THEN 'renew_granularity' 
	  WHEN uddft.field_name = -10000186 THEN 'cancellation_notice_days' 
	  WHEN uddft.field_name = -10000184 THEN 'evergreen_deal' 
	  WHEN uddft.field_name = -10000188 THEN 'cancel_date'
	  WHEN uddft.field_name = -10000187 THEN 'cancellation_alert_days'
	  END field_name
  , uddf.udf_value
FROM source_deal_header sdh 
INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_Id = sdh.template_id
INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
	AND sdh.source_deal_header_id = uddf.source_deal_header_id 
	
) d
PIVOT
(
  MAX(udf_value)
  FOR field_name IN ( renew_granularity, cancellation_notice_days, evergreen_deal, cancel_date, cancellation_alert_days)
) piv 
) aa  WHERE evergreen_deal = 'y'
AND cancellation_notice_days IS NOT NULL AND cancellation_alert_days IS NOT NULL
AND DATEDIFF(DAY, CURRENT_TIMESTAMP, entire_term_end) = CAST(cancellation_notice_days AS INT) + CAST(cancellation_alert_days AS INT) -- included deals whose difference from today and entire_term_end is equal to C.A.D + C.N.D
AND DATEADD(DAY, -1 * (CAST(cancellation_notice_days AS INT) + CAST(cancellation_alert_days AS INT)), entire_term_End) < ISNULL(cancel_date,'9999-01-01')

INSERT INTO #temp_canc_message
SELECT ' Deal <span style="cursor:pointer" onClick="TRMWinHyperlink(10131010,'+ CAST(td.source_Deal_header_id AS VARCHAR(10)) + ',''n'',''NULL'')"><font color=#0000ff><u><l>' + CAST(td.source_Deal_header_id AS VARCHAR(10)) + '<l></u></font></span> can be cancelled within ' + td.cancellation_alert_days + ' days and notified to the Counterparty ' + sc.counterparty_name + '.'  
FROM #temp_deals td 
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = td.counterparty_id	

IF NOT EXISTS (SELECT 1 FROM #temp_canc_message)
BEGIN
	RETURN
END
ELSE
BEGIN
	SELECT * INTO staging_table.evergreen_deals_cancel_process_id_ad FROM #temp_canc_message
END