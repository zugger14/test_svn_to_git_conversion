IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL
	DROP TABLE #temp_deals

SELECT ROW_NUMBER() OVER(ORDER BY sdd.term_start) r_no,
	   dbo.FNATrmHyperlink('i', 10131010, sdh.source_deal_header_id, sdh.source_deal_header_id, 'n', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT) [Deal ID],
       sdh.deal_id [Reference ID],
	   st.trader_name [Trader],
       sc.counterparty_name [Counterparty],
       cg.contract_name [Contract],
       dbo.FNADateFormat(sdd.term_start) [Flow Date],
       sml.location_id [Location],
       udf_sc.counterparty_name [Upstream Cpty],
       udddf_duns.udf_value [Upstream Duns],
       REPLACE(CONVERT(VARCHAR, CAST(sdd.deal_volume AS MONEY), 1), '.00', '') [Volume]
INTO #temp_deals
FROM source_deal_header sdh 
OUTER APPLY (SELECT TOP(1) * FROM source_deal_detail sdd WHERE sdh.source_deal_header_id = sdd.source_deal_header_id ORDER BY sdd.leg, sdd.term_start) sdd
INNER JOIN source_minor_location sml ON  sdd.location_id = sml.source_minor_location_id
INNER JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
INNER JOIN contract_group cg ON sdh.contract_id = cg.contract_id
INNER JOIN source_deal_header_template sdht 
	ON sdht.template_id = sdh.template_id
	AND sdht.template_name IN ('Index Physical Gas', 'FP Physical Gas', 'Free Formula PHY NG', 'Formula Phy Gas')
INNER JOIN user_defined_deal_fields_template uddft_cpty
    ON  uddft_cpty.field_name = 307046
AND uddft_cpty.template_id = sdh.template_id
INNER JOIN user_defined_deal_detail_fields udddf_cpty
    ON  udddf_cpty.source_deal_detail_id = sdd.source_deal_detail_id
    AND uddft_cpty.udf_template_id = udddf_cpty.udf_template_id
INNER JOIN source_counterparty udf_sc ON CAST(udf_sc.source_counterparty_id AS VARCHAR(20)) = udddf_cpty.udf_value
INNER JOIN user_defined_deal_fields_template uddft_duns
    ON  uddft_duns.field_name = 307044
	AND uddft_duns.template_id = sdh.template_id
INNER JOIN user_defined_deal_detail_fields udddf_duns
    ON  udddf_duns.source_deal_detail_id = sdd.source_deal_detail_id
    AND uddft_duns.udf_template_id = udddf_duns.udf_template_id
INNER JOIN application_users au ON au.user_login_id = sdh.create_user
INNER JOIN source_traders st ON st.source_trader_id = sdh.trader_id
WHERE (sml.location_name = 'UNKNOWN_LOCATION' OR ISNULL(udddf_cpty.udf_value, '') IS NULL OR ISNULL(udddf_duns.udf_value, '') IS NULL)
AND DATEDIFF(day, GETDATE(), sdd.term_start) <= 10 


IF EXISTS (SELECT 1 FROM #temp_deals) 
BEGIN
	SELECT[Deal ID], [Reference ID], [Counterparty], [Trader], [Contract], [Flow Date], [Location], [Upstream Cpty], [Upstream Duns], [Volume]
    INTO staging_table.alert_incomplete_deal_process_id_aid 
	FROM #temp_deals
	
	IF EXISTS (SELECT * FROM adiha_process.sys.tables WHERE [name] = 'alert_deal_process_id_ad')
	BEGIN
		UPDATE staging_table.alert_deal_process_id_ad
		SET hyperlink1 = NULL,
		hyperlink2 = NULL
	END

	EXEC spa_insert_alert_output_status var_alert_sql_id, 'process_id', NULL, NULL, NULL
END