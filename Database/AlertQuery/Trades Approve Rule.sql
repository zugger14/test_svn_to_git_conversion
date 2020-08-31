IF OBJECT_ID('tempdb..#temp_holiday') IS NOT NULL
DROP TABLE #temp_holiday
IF OBJECT_ID('tempdb..#permitted_tenor') IS NOT NULL
DROP TABLE #permitted_tenor
IF OBJECT_ID('tempdb..#permitted_combinations') IS NOT NULL
DROP TABLE #permitted_combinations
IF OBJECT_ID('tempdb..#permitted_templates') IS NOT NULL
DROP TABLE #permitted_templates
IF OBJECT_ID('tempdb..#permitted_deal_types') IS NOT NULL
DROP TABLE #permitted_deal_types

CREATE TABLE #permitted_combinations(temp_id INT IDENTITY (1,1), trader_id INT, template_id INT, deal_type_id INT, tenor_id INT)
CREATE TABLE #permitted_tenor (temp_id INT IDENTITY (1,1), deal_id INT, [max_permitted_date] DATETIME, [check_date] CHAR(1))
CREATE TABLE #permitted_templates (temp_id INT IDENTITY (1,1), deal_id INT, template_id INT)
CREATE TABLE #permitted_deal_types (temp_id INT IDENTITY (1,1), deal_id INT, source_deal_type_id INT)
CREATE TABLE staging_table.alert_invalid_trade_process_id_ait ([Deal Id] VARCHAR(5000), [Reference Id] VARCHAR(500), [Trader] VARCHAR(300),  [Template] VARCHAR(500), [Deal Type] VARCHAR(500), [Deal Date]  VARCHAR(500), [Term Start] VARCHAR(500), [Term End] VARCHAR(500), [Remarks] VARCHAR(2000))

INSERT INTO #permitted_combinations(trader_id, template_id, deal_type_id, tenor_id)
SELECT sdh.trader_id, gmv.clm3_value, gmv.clm2_value, gmv.clm4_value
FROM staging_table.alert_deal_process_id_ad temp
INNER JOIN source_deal_header AS sdh ON sdh.source_deal_header_id = temp.source_deal_header_id 
INNER JOIN generic_mapping_header AS gmh ON gmh.mapping_name = 'Approved Trades Matrix'
INNER JOIN generic_mapping_values AS gmv ON gmh.mapping_table_id = gmv.mapping_table_id AND CAST(gmv.clm1_value AS VARCHAR(500)) = CAST(sdh.trader_id AS VARCHAR(20))
INNER JOIN (
	SELECT gmv1.clm1_value template_id
	FROM   generic_mapping_header AS gmh1
	INNER JOIN generic_mapping_definition AS gmd1 ON  gmd1.mapping_table_id = gmh1.mapping_table_id
	INNER JOIN generic_mapping_values AS gmv1 ON  gmv1.mapping_table_id = gmd1.mapping_table_id
	WHERE  gmh1.mapping_name = 'Valid Templates'
) approve_templates ON approve_templates.template_id = gmv.clm3_value

IF EXISTS (SELECT 1 FROM #permitted_combinations)
BEGIN
	INSERT INTO #permitted_templates (deal_id, template_id)
	SELECT DISTINCT sdh.source_deal_header_id, sdh.template_id
	FROM staging_table.alert_deal_process_id_ad temp
	INNER JOIN source_deal_header AS sdh ON sdh.source_deal_header_id = temp.source_deal_header_id 
	LEFT JOIN #permitted_combinations pc ON sdh.template_id = pc.template_id
	WHERE pc.temp_id IS NULL

	IF NOT EXISTS (SELECT 1 FROM #permitted_templates)
	BEGIN
		INSERT INTO #permitted_deal_types (deal_id, source_deal_type_id)
		SELECT DISTINCT sdh.source_deal_header_id, sdh.source_deal_type_id
		FROM staging_table.alert_deal_process_id_ad temp
		INNER JOIN source_deal_header AS sdh ON sdh.source_deal_header_id = temp.source_deal_header_id 
		LEFT JOIN #permitted_combinations pc  ON sdh.template_id = pc.template_id AND sdh.source_deal_type_id = pc.deal_type_id
		WHERE pc.temp_id IS NULL

		IF NOT EXISTS (SELECT 1 FROM #permitted_deal_types)
		BEGIN
			SELECT hg.hol_date, DATENAME(weekday, hg.hol_date) [day], CASE DATEPART(dw, hg.hol_date) WHEN 6 THEN DATEADD(dd, 3, hg.hol_date) ELSE DATEADD(dd, 1, hg.hol_date) END [next_day]
			INTO #temp_holiday
			FROM holiday_group AS hg
			INNER JOIN static_data_value AS sdv ON sdv.value_id = hg.hol_group_value_id
			WHERE sdv.code = 'NERC' AND DATEPART(dw, hg.hol_date) NOT IN (1,7)

			INSERT INTO #permitted_tenor (deal_id, [max_permitted_date], [check_date])
			SELECT DISTINCT sdh.source_deal_header_id, 
			CASE pc.tenor_id WHEN CAST(2 as varchar(10)) THEN DATEADD(YEAR, 2, sdh.deal_date)  
			  WHEN CAST(3 as varchar(10)) THEN DATEADD(YEAR, 4, sdh.deal_date) 
			  WHEN CAST(4 as varchar(10)) THEN DATEADD(MONTH, 1, sdh.deal_date)
			  WHEN CAST(5 as varchar(10)) THEN CASE DATEPART(dw, sdh.deal_date)
					   WHEN 6 THEN ISNULL(hg_monday.[next_day], DATEADD(DAY, 3, sdh.deal_date)) 
					   WHEN 5 THEN ISNULL(hg_firday.[next_day], DATEADD(DAY, 1, sdh.deal_date)) 
					   ELSE ISNULL(hg_next_day.[next_day], DATEADD(DAY, 1, sdh.deal_date)) END
			 END [max_permitted_date], CASE pc.tenor_id WHEN CAST(1 as varchar(10)) THEN 'n' ELSE 'y' END [check_date]
			FROM staging_table.alert_deal_process_id_ad temp 
			INNER JOIN source_deal_header AS sdh ON sdh.source_deal_header_id = temp.source_deal_header_id 
			INNER JOIN #permitted_combinations pc
				ON sdh.template_id = pc.template_id
				AND sdh.source_deal_type_id = pc.deal_type_id
				AND sdh.trader_id = pc.trader_id
			LEFT JOIN #temp_holiday as hg_monday ON hg_monday.hol_date = DATEADD(DAY, 3, sdh.deal_date) AND DATEPART(dw, sdh.deal_date) = 6
			LEFT JOIN #temp_holiday as hg_firday ON hg_firday.hol_date = DATEADD(DAY, 1, sdh.deal_date) AND DATEPART(dw, sdh.deal_date) = 5
			LEFT JOIN #temp_holiday as hg_next_day ON hg_next_day.hol_date = DATEADD(DAY, 1, sdh.deal_date) AND DATEPART(dw, sdh.deal_date) <> 5 AND DATEPART(dw, sdh.deal_date) <> 6
			

			INSERT INTO staging_table.alert_invalid_trade_process_id_ait ([Deal Id], [Reference Id],[Trader], [Deal Date] ,[Term Start],[Term End],[Template],[Deal Type],[Remarks])
			SELECT DISTINCT 
			dbo.FNATrmHyperlink('i', 10131010, sdh.source_deal_header_id, sdh.source_deal_header_id, 'n', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
			sdh.deal_id [Reference Id], st.trader_id,
			CASE WHEN pdc.[check_date] = 'y' THEN CASE WHEN dbo.FNADateFormat(sdh.entire_term_end) > dbo.FNADateFormat(pdc.[max_permitted_date]) THEN '<font color="red">' +  dbo.FNADateFormat(sdh.deal_date) + '</font>' ELSE dbo.FNADateFormat(sdh.deal_date) END ELSE dbo.FNADateFormat(sdh.deal_date) END,
			CASE WHEN pdc.[check_date] = 'y' THEN CASE WHEN dbo.FNADateFormat(sdh.entire_term_end) > dbo.FNADateFormat(pdc.[max_permitted_date]) THEN '<font color="red">' +  dbo.FNADateFormat(sdh.entire_term_start) + '</font>' ELSE dbo.FNADateFormat(sdh.entire_term_start) END ELSE dbo.FNADateFormat(sdh.entire_term_start) END,
			CASE WHEN pdc.[check_date] = 'y' THEN CASE WHEN dbo.FNADateFormat(sdh.entire_term_end) > dbo.FNADateFormat(pdc.[max_permitted_date]) THEN '<font color="red">' +  dbo.FNADateFormat(sdh.entire_term_end) + '</font>' ELSE dbo.FNADateFormat(sdh.entire_term_end) END ELSE dbo.FNADateFormat(sdh.entire_term_end) END,
			sdht.template_name, sdt.deal_type_id, 'Invalid tenor.'
			FROM staging_table.alert_deal_process_id_ad temp
			INNER JOIN source_deal_header AS sdh ON sdh.source_deal_header_id = temp.source_deal_header_id 
			INNER JOIN source_traders AS st ON st.source_trader_id = sdh.trader_id
			INNER JOIN source_deal_type AS sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id 
			INNER JOIN source_deal_header_template AS sdht ON sdht.template_id = sdh.template_id
			INNER JOIN #permitted_tenor pdc ON pdc.deal_id = sdh.source_deal_header_id
			WHERE (dbo.FNADateFormat(sdh.entire_term_end) > CASE WHEN pdc.[check_date] = 'y' THEN dbo.FNADateFormat(pdc.[max_permitted_date]) ELSE dbo.FNADateFormat(DATEADD(dd, 1, sdh.entire_term_end)) END)
		END
		ELSE 
		BEGIN
			INSERT INTO staging_table.alert_invalid_trade_process_id_ait ([Deal Id], [Reference Id],[Trader], [Deal Date] ,[Term Start],[Term End],[Template],[Deal Type],[Remarks])
			SELECT DISTINCT 
			dbo.FNATrmHyperlink('i', 10131010, sdh.source_deal_header_id, sdh.source_deal_header_id, 'n', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT) [Deal Id],
			sdh.deal_id, st.trader_id, dbo.FNADateFormat(sdh.entire_term_end), dbo.FNADateFormat(sdh.entire_term_start), dbo.FNADateFormat(sdh.entire_term_end),
			sdht.template_name, '<font color="red">' + sdt.deal_type_id + '</font>', 'Deal type ' + sdt.deal_type_id + ' is not allowed for trader.'
			FROM staging_table.alert_deal_process_id_ad temp
			INNER JOIN source_deal_header AS sdh ON sdh.source_deal_header_id = temp.source_deal_header_id 
			INNER JOIN source_traders AS st ON st.source_trader_id = sdh.trader_id
			INNER JOIN source_deal_type AS sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id 
			INNER JOIN source_deal_header_template AS sdht ON sdht.template_id = sdh.template_id
			INNER JOIN #permitted_deal_types pdt ON pdt.deal_id = sdh.source_deal_header_id		
		END
	END
	ELSE 
	BEGIN
		INSERT INTO staging_table.alert_invalid_trade_process_id_ait ([Deal Id], [Reference Id],[Trader], [Deal Date] ,[Term Start],[Term End],[Template],[Deal Type],[Remarks])
		SELECT DISTINCT 
		dbo.FNATrmHyperlink('i', 10131010, sdh.source_deal_header_id, sdh.source_deal_header_id, 'n', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
		sdh.deal_id, st.trader_id, dbo.FNADateFormat(sdh.entire_term_end), dbo.FNADateFormat(sdh.entire_term_start), dbo.FNADateFormat(sdh.entire_term_end),
		'<font color="red">' + sdht.template_name + '</font>', sdt.deal_type_id, 'Template ' + sdht.template_name + ' is not allowed for trader.'
		FROM staging_table.alert_deal_process_id_ad temp
		INNER JOIN source_deal_header AS sdh ON sdh.source_deal_header_id = temp.source_deal_header_id 
		INNER JOIN source_traders AS st ON st.source_trader_id = sdh.trader_id
		INNER JOIN source_deal_type AS sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id 
		INNER JOIN source_deal_header_template AS sdht ON sdht.template_id = sdh.template_id
		INNER JOIN #permitted_templates pt ON pt.deal_id = sdh.source_deal_header_id		
	END
END

IF EXISTS (SELECT 1 FROM staging_table.alert_invalid_trade_process_id_ait)
BEGIN
UPDATE staging_table.alert_deal_process_id_ad
SET hyperlink1 = a.[trader],
hyperlink2 = ''
FROM staging_table.alert_invalid_trade_process_id_ait a
 
EXEC spa_insert_alert_output_status var_alert_sql_id, 'process_id', NULL, NULL, NULL
END