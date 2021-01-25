BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '9DB48870_5BA4_47A3_B100_2512AD19A3CE'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Trayport-Enercity Deal Import Final'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				-- Added to preserve rule detail like folder location, File endpoint details.
				IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
					DROP TABLE #pre_ixp_import_data_source

				SELECT rules_id
					, folder_location
					, file_transfer_endpoint_id
					, remote_directory 
				INTO #pre_ixp_import_data_source
				FROM ixp_import_data_source 
				WHERE rules_id = @old_ixp_rule_id

				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Trayport-Enercity Deal Import Final' ,
					'N' ,
					NULL ,
					'DECLARE @set_process_id VARCHAR(40)
	, @row_count INT
	, @mapping_table_id INT
SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[final_process_table]''), 0,37))

DECLARE @temp_process_table NVARCHAR(1000) = dbo.FNAProcessTableName(''temp_pre_import_data'', dbo.FNADBUser(), @set_process_id)
EXEC(''IF OBJECT_ID('''''' + @temp_process_table + '''''') IS NOT NULL
				DROP TABLE '' + @temp_process_table + ''
	  SELECT * INTO '' + @temp_process_table + ''
	  FROM [temp_process_table]
'')

SELECT @row_count = count(*) FROM [final_process_table]

UPDATE t
	SET t.[DateTime] = CAST(t.[DateTime] AS VARCHAR(23))
FROM [temp_process_table] t

UPDATE t
SET t.[broker_id] = sc.counterparty_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[broker_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_counterparty sc
	ON sc.source_counterparty_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport Broker Mapping''

UPDATE t
    SET t.[trader_id] = st.trader_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[trader_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_traders st
	ON st.source_trader_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport Trader Mapping''

DECLARE @cpty_mapping_id INT 
SELECT  @cpty_mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = ''Trayport Counterparty Mapping'' 


UPDATE t
SET t.[counterparty_id] = ISNULL(sc.counterparty_id, ''Default_Counterparty'')
FROM [final_process_table] t
LEFT JOIN generic_mapping_values gmv ON ISNULL(t.[counterparty_id], ''-1'') = ISNULL(gmv.clm1_value, ''-2'')
	AND gmv.mapping_table_id = @cpty_mapping_id
LEFT JOIN generic_mapping_values gmv1 ON ISNULL(t.[curve_id], ''-1'') = ISNULL(gmv1.clm3_value, ''-2'')
	AND gmv1.mapping_table_id = @cpty_mapping_id
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = COALESCE(gmv.clm2_value,gmv1.clm2_value)

SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Block Definition Product Mapping''

INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Invalid Data''
	, ''Invalid data for DateTime: '' + temp.[deal_date] + '' for Deal : '' + temp.deal_id
	, ''Error''
FROM [final_process_table] temp
WHERE ISDATE(temp.[deal_date]) = 0

DELETE t
FROM [final_process_table] t
WHERE ISDATE(t.[deal_date]) = 0

INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Generic mapping not found for TermCodes: '' + CASE WHEN MAX(temp.curve_id) IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END + '' AND DealTimeHour: '' + CAST(DATEPART(HH, dbo.FNAGetLOCALTime(temp.[deal_date],15)) AS VARCHAR(10)) + '' for Deal : '' + temp.deal_id
	, ''Error''
FROM [final_process_table] temp
INNER JOIN generic_mapping_values gmv0 ON gmv0.mapping_table_id = @mapping_table_id AND gmv0.clm1_value = CASE WHEN temp.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END
INNER JOIN mv90_dst d1 ON d1.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d1.insert_delete = ''d'' AND d1.dst_group_value_id = 102201
INNER JOIN mv90_dst d2 ON d2.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d2.insert_delete = ''i'' AND d2.dst_group_value_id = 102201
LEFT JOIN generic_mapping_values gmv 
	ON gmv.mapping_table_id = @mapping_table_id 
	AND gmv.clm1_value = CASE WHEN temp.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END
	AND gmv.clm3_value = CAST(DATEPART(HH, dbo.FNAGetLOCALTime(CAST(temp.[deal_date] AS DATETIME),15)) AS VARCHAR(10)) 
	--AND gmv.clm5_value = CAST(CASE WHEN CAST(temp.[deal_date] AS DATETIME) >= d1.date AND CAST(temp.[deal_date] AS DATETIME) < d2.date THEN 1 ELSE 0 END AS VARCHAR(10)) 
WHERE ISDATE(temp.[deal_date]) = 1
AND gmv.generic_mapping_values_id IS NULL
AND NULLIF(gmv0.clm2_value,'''') IS NULL
AND gmv0.[clm1_value] NOT IN (''Saturday'', ''Sunday'')
GROUP BY temp.deal_id, temp.term_start, temp.[deal_date]

DELETE temp
FROM [final_process_table] temp
INNER JOIN generic_mapping_values gmv0 ON gmv0.mapping_table_id = @mapping_table_id AND gmv0.clm1_value = CASE WHEN temp.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END
INNER JOIN mv90_dst d1 ON d1.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d1.insert_delete = ''d'' AND d1.dst_group_value_id = 102201
INNER JOIN mv90_dst d2 ON d2.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d2.insert_delete = ''i'' AND d2.dst_group_value_id = 102201
LEFT JOIN generic_mapping_values gmv 
	ON gmv.mapping_table_id = @mapping_table_id 
	AND gmv.clm1_value = CASE WHEN temp.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END
	AND gmv.clm3_value = CAST(DATEPART(HH, dbo.FNAGetLOCALTime(CAST(temp.[deal_date] AS DATETIME),15)) AS VARCHAR(10)) 
	--AND gmv.clm5_value = CAST(CASE WHEN CAST(temp.[deal_date] AS DATETIME) >= d1.date AND CAST(temp.[deal_date] AS DATETIME) < d2.date THEN 1 ELSE 0 END AS VARCHAR(10)) 
WHERE ISDATE(temp.[deal_date]) = 1
AND NULLIF(gmv0.clm2_value,'''') IS NULL
AND gmv.generic_mapping_values_id IS NULL
AND gmv0.[clm1_value] NOT IN (''Saturday'', ''Sunday'')

UPDATE temp
	SET temp.[block_define_id] = sdv.code
FROM [final_process_table] temp
INNER JOIN mv90_dst d1 ON d1.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d1.insert_delete = ''d'' AND d1.dst_group_value_id = 102201
INNER JOIN mv90_dst d2 ON d2.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d2.insert_delete = ''i'' AND d2.dst_group_value_id = 102201
INNER JOIN generic_mapping_values gmv 
	ON gmv.mapping_table_id = @mapping_table_id 
	AND gmv.clm1_value = CASE WHEN temp.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END 
	AND gmv.clm3_value = CAST(DATEPART(HH, dbo.FNAGetLOCALTime(CAST(temp.[deal_date] AS DATETIME),15)) AS VARCHAR(10)) 
	--AND gmv.clm5_value = CAST(CASE WHEN CAST(temp.[deal_date] AS DATETIME) >= d1.date AND CAST(temp.[deal_date] AS DATETIME) < d2.date THEN 1 ELSE 0 END AS VARCHAR(10)) 
INNER JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm4_value
WHERE ISDATE(temp.[deal_date]) = 1

UPDATE t
    SET t.[block_define_id] = sdv.code
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
	ON gmv.mapping_table_id = @mapping_table_id
	AND t.[block_define_id] = gmv.clm2_value
    AND gmv.clm1_value = CASE WHEN t.[term_start] like ''%weekend%'' 
							      OR t.[term_start] like ''%Wk1-%'' 
							      OR t.[term_start] like ''%WkEnd%''
							  THEN ''WkEnd''
							  WHEN t.[term_start] like ''%sun%'' THEN ''SUN''
						  	  WHEN t.[term_start] like ''%sat%'' THEN ''SAT''					 
					     ELSE CASE WHEN t.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(t.term_start))) = 0, RTRIM(LTRIM(t.term_start)),SUBSTRING(RTRIM(LTRIM(t.term_start)), CHARINDEX('' '',RTRIM(LTRIM(t.term_start))) + 1 , LEN(RTRIM(LTRIM(t.term_start))))) ELSE t.term_start END END
INNER JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm4_value
WHERE t.[term_start] NOT IN (''Saturday'', ''Sunday'')

UPDATE t
    SET t.[block_define_id] = sdv.code
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
	ON gmv.mapping_table_id = @mapping_table_id
    AND gmv.clm1_value = t.[term_start]
INNER JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm4_value
WHERE t.[term_start] IN (''Saturday'', ''Sunday'')

UPDATE t
    SET t.[block_define_id] = sdv.code
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
	ON gmv.mapping_table_id = @mapping_table_id
    AND t.[block_define_id] = gmv.clm2_value
INNER JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm4_value
WHERE NULLIF(gmv.clm1_value,'''') IS NULL

UPDATE [final_process_table]
SET term_start = IIF(CHARINDEX('' '',term_start) = 0,term_start,SUBSTRING(term_start,0, CHARINDEX('' '',term_start)))
	,term_end = IIF(CHARINDEX('' '',term_end) = 0, term_end,SUBSTRING(term_end,0, CHARINDEX('' '',term_end)))
WHERE curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'')

INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Data '''''' + t.[term_start] + '''''' not found for Column: FirstSequenceItemName. <span style=''''cursor:pointer'''' onClick=''''window.top.TRMWinHyperlink(20013000, "'' + t.[term_start] + ''")''''><font color=#0000ff><u><l> Create '' + t.[term_start] + ''<l></u></font></span>''
	, ''Error''
FROM [final_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.term_start = tmd.term_code
WHERE tmd.term_map_id IS NULL

INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Data '''''' + t.[term_end] + '''''' not found for Column: SecondSequenceItemName. <span style=''''cursor:pointer'''' onClick=''''window.top.TRMWinHyperlink(20013000, "'' + t.[term_end] + ''")''''><font color=#0000ff><u><l> Create '' + t.[term_end] + ''<l></u></font></span>''
	, ''Error''
FROM [final_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.term_end = tmd.term_code
WHERE tmd.term_map_id IS NULL
AND NULLIF(t.term_end,'''') IS NOT NULL

DELETE t
FROM [final_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.term_start = tmd.term_code
WHERE tmd.term_map_id IS NULL

DELETE t
FROM [final_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.term_end = tmd.term_code
WHERE tmd.term_map_id IS NULL
AND NULLIF(t.term_end,'''') IS NOT NULL

EXEC spa_trayport_deal_term_mapping @process_table = ''[final_process_table]''


UPDATE a
SET a.term_start = CAST(tmd.term_start AS DATE)
	, a.term_end = CAST(tmd.term_end AS DATE)
FROM [final_process_table] a
INNER JOIN term_map_detail tmd
	ON a.udf_value1 = tmd.term_code

UPDATE t
	SET t.template_id = ISNULL(sdht.template_name,t.template_id)
		,deal_volume_frequency = COALESCE( CASE gmv.clm6_value WHEN ''x'' THEN ''15 Minutes''
															   WHEN ''y'' THEN ''30 Minutes''
															   WHEN ''a'' THEN ''Annually''
															   WHEN ''d'' THEN ''Daily''
															   WHEN ''h'' THEN ''Hourly''
															   WHEN ''m'' THEN ''Monthly''
															   WHEN ''t'' THEN ''Term''
										   ELSE NULL END,NULLIF(t.deal_volume_frequency,''''))
		,multiplier = gmv.clm7_value
		,deal_volume_uom_id = COALESCE(su.uom_id,NULLIF(t.deal_volume_uom_id,''''))
		,position_uom = COALESCE(su1.uom_id,NULLIF(t.position_uom,''''))
		, commodity_id = sc.commodity_id
		, source_deal_type_id = COALESCE(sdt.deal_type_id, NULLIF(t.source_deal_type_id,''''))
FROM [final_process_table] t
INNER JOIN [temp_process_table] t1
	ON t1.[tradeid] = t.deal_id
LEFT JOIN term_map_detail tmd 
	ON tmd.term_code =  t1.[FirstSequenceItemName]
INNER JOIN generic_mapping_values gmv
    ON gmv.clm1_value = t.[curve_id]
	AND ISNULL(gmv.clm4_value,''-1'') = CASE WHEN gmv.clm4_value IS NULL THEN ''-1'' ELSE ISNULL(tmd.sequence,gmv.clm4_value) END
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
LEFT JOIN source_deal_header_template sdht
	ON sdht.template_id = gmv.clm5_value
LEFT JOIN source_uom su
	ON CAST(su.source_uom_id AS VARCHAR(10)) = gmv.clm8_value
LEFT JOIN source_commodity sc
	ON sc.source_commodity_id = gmv.clm3_value
LEFT JOIN source_uom su1
	ON CAST(su1.source_uom_id AS VARCHAR(10)) = gmv.clm9_value
LEFT JOIN source_deal_type sdt
	ON CAST(sdt.source_deal_type_id AS VARCHAR(10)) = gmv.clm10_value
WHERE gmh.mapping_name = ''Trayport product Mapping''

SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Book Mapping''

UPDATE t
SET t.sub_book = ssbm.logical_name
FROM [final_process_table] t
INNER JOIN [temp_process_table] t1
	ON t1.[tradeid] = t.deal_id
INNER JOIN source_commodity sc
	ON sc.commodity_id = t.commodity_id
LEFT JOIN generic_mapping_values gmv
    ON gmv.mapping_table_id = @mapping_table_id
	AND ISNULL(t.sub_book, '''') = ISNULL(gmv.clm3_value, '''')
	AND ISNULL(CAST(sc.source_commodity_id AS VARCHAR(10)), '''') = ISNULL(gmv.clm2_value, '''')
	AND ISNULL(CASE WHEN t1.AggressorCompany = ''Stadtwerke Hannover AG''
					THEN t1.[AggressorTrader]
					ELSE
						t1.[InitiatorTrader]
				END, '''') = ISNULL(gmv.clm1_value, '''')
LEFT JOIN generic_mapping_values gmv1
    ON gmv1.mapping_table_id = @mapping_table_id
	AND ISNULL(CAST(sc.source_commodity_id AS VARCHAR(10)), '''') = ISNULL(gmv1.clm2_value, '''')
	AND ISNULL(CASE WHEN t1.AggressorCompany = ''Stadtwerke Hannover AG''
					THEN t1.[AggressorTrader]
					ELSE
						t1.[InitiatorTrader]
				END, '''') = ISNULL(gmv1.clm1_value, '''')
INNER JOIN source_system_book_map ssbm
	ON ssbm.book_deal_type_map_id = COALESCE(gmv.clm4_value,gmv1.clm4_value)


SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Location Mapping''
UPDATE temp
	SET location_id = ISNULL(sml.location_id,temp.location_id)
FROM [final_process_table] temp
INNER JOIN [temp_process_table] t1
	ON t1.[tradeid] = temp.deal_id
INNER JOIN source_counterparty sc
	ON sc.counterparty_id = temp.counterparty_id
INNER JOIN source_commodity scm
	ON scm.commodity_id = temp.commodity_id
LEFT JOIN generic_mapping_values gmv 
	ON  mapping_table_id = @mapping_table_id
	AND  gmv.clm2_value = scm.source_commodity_id
    AND  ISNULL(gmv.clm3_value,1) = CASE WHEN scm.commodity_id = ''Power'' THEN sc.source_counterparty_id ELSE ISNULL(gmv.clm3_value,1) END
	AND  ISNULL(gmv.clm1_value,1) = CASE WHEN scm.commodity_id = ''Power'' THEN ISNULL(gmv.clm1_value,1) ELSE temp.curve_id END
LEFT JOIN source_minor_location sml
	ON sml.source_minor_location_id = gmv.clm4_value


UPDATE t
	SET t.curve_id = ISNULL(spcd.curve_id,t.curve_id)
FROM [final_process_table] t
INNER JOIN [temp_process_table] t1
	ON t1.[tradeid] = t.deal_id
LEFT JOIN term_map_detail tmd 
	ON tmd.term_code =  t1.[FirstSequenceItemName]
INNER JOIN generic_mapping_values gmv
    ON gmv.clm1_value = t.[curve_id]
	AND ISNULL(gmv.clm4_value,''-1'') = CASE WHEN gmv.clm4_value IS NULL THEN ''-1'' ELSE ISNULL(tmd.sequence,gmv.clm4_value) END
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
LEFT JOIN source_price_curve_def spcd
	ON spcd.source_curve_def_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport product Mapping''

UPDATE temp
	SET physical_financial_flag = sdht.physical_financial_flag
	, physical_financial_flag_detail = sddt.physical_financial_flag
	, fixed_price_currency_id = sc.currency_id
	, deal_volume_frequency = COALESCE(NULLIF(temp.deal_volume_frequency,''''),sddt.deal_volume_frequency)
	, deal_volume_uom_id = COALESCE(NULLIF(temp.deal_volume_uom_id,''''),su.uom_id)
	, multiplier = COALESCE(NULLIF(temp.multiplier,''''),CAST(sddt.multiplier AS VARCHAR(20)))
	, position_uom = COALESCE(NULLIF(temp.position_uom,''''),su1.uom_id)
FROM [final_process_table] temp
INNER JOIN source_deal_header_template sdht
	ON sdht.template_name = temp.template_id
LEFT JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id --AND sddt.leg = ISNULL(temp.leg, 1) 
LEFT JOIN source_currency sc
	ON sc.source_currency_id = sddt.fixed_price_currency_id
LEFT JOIN source_uom su
	ON su.source_uom_id = sddt.deal_volume_uom_id
LEFT JOIN source_uom su1
	ON su1.source_uom_id = sddt.position_uom
	
SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Contract Mapping''

UPDATE s2
	SET contract_id = cg.contract_name
FROM [final_process_table] s2
INNER JOIN source_counterparty sc ON sc.counterparty_id = s2.counterparty_id
INNER JOIN source_commodity com ON com.commodity_id = s2.commodity_id
INNER JOIN generic_mapping_values gmv ON  mapping_table_id = @mapping_table_id
     AND gmv.clm1_value = CAST(sc.source_counterparty_id AS VARCHAR(20))
    AND  gmv.clm2_value = CAST(com.source_commodity_id  AS VARCHAR(20))
INNER JOIN contract_group cg
	ON CAST(cg.contract_id AS VARCHAR(20)) = gmv.clm3_value

UPDATE temp	
	SET shipper_code1 = scmd1.shipper_code1
	,	shipper_code2 = scmd2.shipper_code
FROM [final_process_table] temp
INNER JOIN source_counterparty sc
	ON sc.counterparty_id = temp.counterparty_id
INNER JOIN source_minor_location sml
	ON sml.location_id = temp.location_id
INNER JOIN shipper_code_mapping scm
	ON scm.counterparty_id = sc.source_counterparty_id
OUTER APPLY (
	SELECT MAX(effective_date) effective_date
	FROM shipper_code_mapping_detail
	WHERE location_id = sml.source_minor_location_id
	AND ISNULL(is_default,''n'') = ''y''
	AND ISNULL(is_active,''n'') = ''y''
	AND shipper_code_id = scm.shipper_code_id
) shipper_code2_max_date
OUTER APPLY (
	SELECT MAX(effective_date) effective_date
	FROM shipper_code_mapping_detail
	WHERE location_id = sml.source_minor_location_id
	AND ISNULL(shipper_code1_is_default,''n'') = ''y''
	AND ISNULL(is_active,''n'') = ''y''
	AND shipper_code_id = scm.shipper_code_id
) shipper_code1_max_date
LEFT JOIN shipper_code_mapping_detail scmd2
	ON scmd2.location_id = sml.source_minor_location_id
	AND scmd2.effective_date = shipper_code2_max_date.effective_date
	AND ISNULL(scmd2.is_default,''n'') = ''y''
	AND ISNULL(scmd2.is_active,''n'') = ''y'' 
	AND scmd2.shipper_code_id = scm.shipper_code_id
LEFT JOIN shipper_code_mapping_detail scmd1
	ON scmd1.location_id = sml.source_minor_location_id
	AND scmd1.effective_date = shipper_code1_max_date.effective_date
	AND ISNULL(scmd1.is_default,''n'') = ''y''
	AND ISNULL(scmd1.is_active,''n'') = ''y'' 
	AND scmd1.shipper_code_id = scm.shipper_code_id

UPDATE temp
	SET deal_date = CAST(deal_date AS DATE),
		term_start = CAST(CASE WHEN ISNULL(t1.FirstSequenceItemName,t1.SecondSequenceItemName) = ''Saturday'' THEN DATEADD(dd, 7-(DATEPART(dw, deal_date)), deal_date)
							   WHEN ISNULL(t1.FirstSequenceItemName,t1.SecondSequenceItemName) = ''Sunday'' THEN DATEADD(dd, 8-(DATEPART(dw, deal_date)), deal_date)
						  ELSE term_start END
					 AS DATE),
		term_end = CAST(CASE WHEN ISNULL(t1.FirstSequenceItemName,t1.SecondSequenceItemName) = ''Saturday'' THEN DATEADD(dd, 7-(DATEPART(dw, deal_date)), deal_date)
							   WHEN ISNULL(t1.FirstSequenceItemName,t1.SecondSequenceItemName) = ''Sunday'' THEN DATEADD(dd, 8-(DATEPART(dw, deal_date)), deal_date)
						  ELSE term_end END
					 AS DATE)
FROM [final_process_table] temp
INNER JOIN [temp_process_table] t1
	ON t1.[tradeid] = temp.deal_id

DECLARE @ixp_import_rules_name NVARCHAR(1000)
SELECT @ixp_import_rules_name = REPLACE(dir_path,''Rules:'','''')
FROM import_data_files_audit
WHERE process_id = @set_process_id

IF OBJECT_ID(''tempdb..#temp_udf_data'') IS NOT NULL
		DROP TABLE #temp_udf_data

CREATE TABLE #temp_udf_data (
	[Delivery Path] VARCHAR(150) COLLATE DATABASE_DEFAULT
)

INSERT INTO #temp_udf_data([Delivery Path])
SELECT [Delivery Path]
FROM (
	SELECT ic.ixp_columns_name, udft.field_label
	FROM ixp_rules ir
	INNER JOIN ixp_import_data_mapping iidm ON iidm.ixp_rules_id = ir.ixp_rules_id
	INNER JOIN ixp_tables it ON iidm.dest_table_id = it.ixp_tables_id
	INNER JOIN ixp_columns ic ON it.ixp_tables_id = ic.ixp_table_id AND ic.ixp_columns_id = iidm.dest_column
	INNER JOIN user_defined_fields_template udft
		ON udft.field_id = iidm.udf_field_id
	WHERE ir.ixp_rules_name = @ixp_import_rules_name
	AND iidm.udf_field_id IS NOT NULL
	AND udft.field_label IN (''Delivery Path'')
	) AS a
PIVOT(MAX(a.ixp_columns_name) FOR a.Field_label IN ([Delivery Path])) AS P

SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Autopath Mapping''

DECLARE @udf_update_query NVARCHAR(MAX), @sql_query NVARCHAR(MAX)
SELECT @udf_update_query = [Delivery Path] + ''= dp.path_code''
FROM #temp_udf_data

SET @sql_query = ''
	UPDATE temp
	SET shipper_code1 = gmv.clm6_value
	,	shipper_code2 = gmv.clm7_value
	, internal_portfolio_id = sdv_product.code
	'' + CASE WHEN @udf_update_query IS NOT NULL THEN '', '' + @udf_update_query ELSE '''' END + ''
	FROM [final_process_table] temp
	INNER JOIN [temp_process_table] t1
		ON t1.[tradeid] = temp.deal_id
	LEFT JOIN generic_mapping_values gmv 
		ON  mapping_table_id =   '''''' + CAST(@mapping_table_id AS VARCHAR(10)) + ''''''
		AND  gmv.clm1_value = t1.[InstName]
		AND  COALESCE(gmv.clm2_value,t1.[Book],''''-1'''') = ISNULL(t1.[Book], ''''-1'''')
		AND  COALESCE(gmv.clm3_value,CASE temp.header_buy_sell_flag WHEN ''''Buy'''' THEN ''''b'''' WHEN ''''Sell'''' THEN ''''s'''' ELSE temp.header_buy_sell_flag END,''''-1'''') = ISNULL(CASE temp.header_buy_sell_flag WHEN ''''Buy'''' THEN ''''b'''' WHEN ''''Sell'''' THEN ''''s'''' ELSE temp.header_buy_sell_flag END, ''''-1'''')
	LEFT JOIN delivery_path dp
		ON CAST(dp.path_id AS VARCHAR(10)) = gmv.clm4_value
	LEFT JOIN static_data_value sdv_product
		ON CAST(sdv_product.value_id  AS VARCHAR(10)) = gmv.clm5_value
		AND sdv_product.[type_id] = 39800
	WHERE gmv.clm1_value in ( ''''NCG L - WEST EEX'''',''''NCG L - EAST EEX'''')
''
EXEC(@sql_query)


INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Data Warning''
	, ''Shipper code mapping not found for''  + CASE WHEN temp.shipper_code1 IS NULL AND temp.shipper_code2 IS NULL THEN '' shipper code 1 and shipper code 2''
											  ELSE IIF(temp.shipper_code1 IS NULL, '' shipper code 1'', '' shipper code 2'') END
		
		+ '' for Deal : '' + temp.deal_id
	, ''Warning''
FROM [final_process_table] temp
WHERE temp.shipper_code1 IS NULL OR temp.shipper_code2 IS NULL',
					'DECLARE @mapping_table_id INT
DECLARE @set_process_id VARCHAR(40)
	, @hyperlink_row_count INT
	, @row_count VARCHAR(10)
	,@total_deal INT, @imported_deal INT
	,@book_update_deals NVARCHAR(MAX) = ''''
	,@desc NVARCHAR(MAX)
	,@user_login_id NVARCHAR(100) = dbo.FNADBUSER()

SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[temp_process_table]''), 0,37))

DECLARE @temp_process_table NVARCHAR(1000) = dbo.FNAProcessTableName(''temp_pre_import_data'', dbo.FNADBUser(), @set_process_id)
IF OBJECT_ID(''tempdb..#temp_deal_import_count'') IS NOT NULL
	DROP TABLE #temp_deal_import_count

CREATE TABLE #temp_deal_import_count(
	pre_deal_id VARCHAR(100),
	post_deal_id VARCHAR(100)
)

EXEC(''INSERT INTO #temp_deal_import_count
	SELECT temp.[tradeid],tbl.deal_id
	FROM '' + @temp_process_table + '' temp
	OUTER APPLY( SELECT DISTINCT deal_id
					FROM [temp_process_table]
					WHERE deal_id = temp.[tradeid]
	) tbl
'')

SELECT @total_deal = COUNT(pre_deal_id)
FROM #temp_deal_import_count

SELECT @imported_deal = COUNT(pre_deal_id)
FROM #temp_deal_import_count
WHERE post_deal_id IS NOT NULL


IF EXISTS(SELECT 1 FROM source_system_data_import_status
	  WHERE process_id = @set_process_id
	  AND description like ''%Data imported Successfully out of%''
	  )
BEGIN
	UPDATE source_system_data_import_status
		SET description = CAST(@imported_deal AS VARCHAR(10)) + '' Data imported Successfully out of '' + CAST(@total_deal AS VARCHAR(10)) + '' rows.''
	WHERE process_id = @set_process_id
	AND description like ''%Data imported Successfully out of%''
END
ELSE 
BEGIN
	INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
	SELECT DISTINCT @set_process_id,
		''Error'',
		''Import Data'',
		''ixp_source_deal_template'',
		''Error'',
		CAST(@imported_deal AS VARCHAR(10)) + '' Data imported Successfully out of '' + CAST(@total_deal AS VARCHAR(10)) + '' rows.'',
		''Please verify data.'',
		''Trayport''
END

IF OBJECT_ID(''tempdb..#temp_deal_udf_values'') IS NOT NULL
		DROP TABLE #temp_deal_udf_values

CREATE TABLE #temp_deal_udf_values (
	[source_deal_header_id] INT, 
	[deal_id] NVARCHAR(400),
	[Trayport Date Time] NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
	[Trayport Last Update] NVARCHAR(1000) COLLATE DATABASE_DEFAULT
)

INSERT INTO #temp_deal_udf_values (source_deal_header_id,deal_id, [Trayport Date Time], [Trayport Last Update])
SELECT source_deal_header_id,deal_id, [Trayport Date Time], [Trayport Last Update]
FROM (
	SELECT sdh.source_deal_header_id, sdh.deal_id, udft.field_label, uddf.udf_value
	FROM [temp_process_table] temp
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = temp.deal_id
	INNER JOIN user_defined_deal_fields uddf
		ON uddf.source_deal_header_id = sdh.source_deal_header_id
			AND NULLIF(uddf.udf_value, '''') IS NOT NULL
	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.udf_template_id = uddf.udf_template_id
	INNER JOIN user_defined_fields_template udft
		ON udft.field_id = uddft.field_id
	) AS a
PIVOT (MAX(a.udf_value) FOR a.Field_label IN ([Trayport Date Time], [Trayport Last Update])) AS p


SELECT @book_update_deals = STUFF((SELECT DISTINCT '', '' +  dbo.FNATRMWinHyperlink(''a'', 10131010, deal_id,source_deal_header_id,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
							FROM #temp_deal_udf_values
							WHERE DATEDIFF(MINUTE, CAST([Trayport Date Time] AS DATETIME), CAST([Trayport Last Update] AS DATETIME)) > 30
					 FOR XML PATH('''')), 1, 1, '''')
					 
SELECT @book_update_deals = dbo.FNADECODEXML(@book_update_deals)

IF NULLIF(@book_update_deals,'''') IS NOT NULL
BEGIN
	SET @desc = ''Trayport Book has been updated for Deal ID : '' + @book_update_deals
	
    INSERT INTO message_board(user_login_id, source, [description], url_desc, url, [type], job_name, as_of_date, process_id, process_type,is_alert)
    SELECT DISTINCT au.user_login_id, ''Trayport Deal Import'' , @desc, NULL, NULL, ''w'',NULL, NULL,@set_process_id,NULL, ''y''
    FROM dbo.application_role_user aru
    INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
    INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
    WHERE (au.user_active = ''y'') AND (asr.role_type_value_id = 4) AND au.user_emal_add IS NOT NULL
    GROUP BY au.user_login_id, au.user_emal_add	
END



    

--insert into sk(type,name) values(''after_temp'', ''[temp_process_table]'')
--insert into sk(type,name) values(''after_final'', ''[final_process_table]'')



SELECT @row_count = [description] 
FROM source_system_data_import_status 
WHERE process_id = @set_process_id
	AND rules_name = ''Trayport''

SELECT @hyperlink_row_count = count(*) 
FROM source_system_data_import_status_detail 
WHERE process_id = @set_process_id 
	AND description like ''%Create %''

	UPDATE sdh
    SET sdh.reporting_group1 = IIF(bkr.counterparty_id IN (''EEX_broker'', ''ICE_Broker'', ''EEX_SPOT_BROKER'',''ICAP''), NULL, ''50000361'')
FROM source_deal_header sdh
INNER JOIN [temp_process_table] t
    ON t.deal_id = sdh.deal_id
INNER JOIN source_counterparty sc
    ON sc.source_counterparty_id = sdh.counterparty_id
LEFT JOIN source_counterparty bkr
    ON bkr.source_counterparty_id = sdh.broker_id
WHERE sc.counterparty_id in(''ICE'',''EEX'')',
					'i' ,
					'n' ,
					@admin_user ,
					23502,
					1,
					'9DB48870_5BA4_47A3_B100_2512AD19A3CE'
					 )

				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				EXEC spa_print 	@ixp_rules_id_new

				UPDATE ixp
				SET import_export_id = @ixp_rules_id_new
				FROM ipx_privileges ixp
				WHERE ixp.import_export_id = @old_ixp_rule_id
		END
				
				

		ELSE 
		BEGIN
			SET @ixp_rules_id_new = @old_ixp_rule_id
			EXEC spa_print 	@ixp_rules_id_new
			
			UPDATE
			ixp_rules
			SET ixp_rules_name = 'Trayport-Enercity Deal Import Final'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'DECLARE @set_process_id VARCHAR(40)
	, @row_count INT
	, @mapping_table_id INT
SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[final_process_table]''), 0,37))

DECLARE @temp_process_table NVARCHAR(1000) = dbo.FNAProcessTableName(''temp_pre_import_data'', dbo.FNADBUser(), @set_process_id)
EXEC(''IF OBJECT_ID('''''' + @temp_process_table + '''''') IS NOT NULL
				DROP TABLE '' + @temp_process_table + ''
	  SELECT * INTO '' + @temp_process_table + ''
	  FROM [temp_process_table]
'')

SELECT @row_count = count(*) FROM [final_process_table]

UPDATE t
	SET t.[DateTime] = CAST(t.[DateTime] AS VARCHAR(23))
FROM [temp_process_table] t

UPDATE t
SET t.[broker_id] = sc.counterparty_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[broker_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_counterparty sc
	ON sc.source_counterparty_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport Broker Mapping''

UPDATE t
    SET t.[trader_id] = st.trader_id
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
    ON t.[trader_id] = gmv.clm1_value
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
INNER JOIN source_traders st
	ON st.source_trader_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport Trader Mapping''

DECLARE @cpty_mapping_id INT 
SELECT  @cpty_mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = ''Trayport Counterparty Mapping'' 


UPDATE t
SET t.[counterparty_id] = ISNULL(sc.counterparty_id, ''Default_Counterparty'')
FROM [final_process_table] t
LEFT JOIN generic_mapping_values gmv ON ISNULL(t.[counterparty_id], ''-1'') = ISNULL(gmv.clm1_value, ''-2'')
	AND gmv.mapping_table_id = @cpty_mapping_id
LEFT JOIN generic_mapping_values gmv1 ON ISNULL(t.[curve_id], ''-1'') = ISNULL(gmv1.clm3_value, ''-2'')
	AND gmv1.mapping_table_id = @cpty_mapping_id
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = COALESCE(gmv.clm2_value,gmv1.clm2_value)

SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Block Definition Product Mapping''

INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Invalid Data''
	, ''Invalid data for DateTime: '' + temp.[deal_date] + '' for Deal : '' + temp.deal_id
	, ''Error''
FROM [final_process_table] temp
WHERE ISDATE(temp.[deal_date]) = 0

DELETE t
FROM [final_process_table] t
WHERE ISDATE(t.[deal_date]) = 0

INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Generic mapping not found for TermCodes: '' + CASE WHEN MAX(temp.curve_id) IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END + '' AND DealTimeHour: '' + CAST(DATEPART(HH, dbo.FNAGetLOCALTime(temp.[deal_date],15)) AS VARCHAR(10)) + '' for Deal : '' + temp.deal_id
	, ''Error''
FROM [final_process_table] temp
INNER JOIN generic_mapping_values gmv0 ON gmv0.mapping_table_id = @mapping_table_id AND gmv0.clm1_value = CASE WHEN temp.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END
INNER JOIN mv90_dst d1 ON d1.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d1.insert_delete = ''d'' AND d1.dst_group_value_id = 102201
INNER JOIN mv90_dst d2 ON d2.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d2.insert_delete = ''i'' AND d2.dst_group_value_id = 102201
LEFT JOIN generic_mapping_values gmv 
	ON gmv.mapping_table_id = @mapping_table_id 
	AND gmv.clm1_value = CASE WHEN temp.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END
	AND gmv.clm3_value = CAST(DATEPART(HH, dbo.FNAGetLOCALTime(CAST(temp.[deal_date] AS DATETIME),15)) AS VARCHAR(10)) 
	--AND gmv.clm5_value = CAST(CASE WHEN CAST(temp.[deal_date] AS DATETIME) >= d1.date AND CAST(temp.[deal_date] AS DATETIME) < d2.date THEN 1 ELSE 0 END AS VARCHAR(10)) 
WHERE ISDATE(temp.[deal_date]) = 1
AND gmv.generic_mapping_values_id IS NULL
AND NULLIF(gmv0.clm2_value,'''') IS NULL
AND gmv0.[clm1_value] NOT IN (''Saturday'', ''Sunday'')
GROUP BY temp.deal_id, temp.term_start, temp.[deal_date]

DELETE temp
FROM [final_process_table] temp
INNER JOIN generic_mapping_values gmv0 ON gmv0.mapping_table_id = @mapping_table_id AND gmv0.clm1_value = CASE WHEN temp.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END
INNER JOIN mv90_dst d1 ON d1.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d1.insert_delete = ''d'' AND d1.dst_group_value_id = 102201
INNER JOIN mv90_dst d2 ON d2.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d2.insert_delete = ''i'' AND d2.dst_group_value_id = 102201
LEFT JOIN generic_mapping_values gmv 
	ON gmv.mapping_table_id = @mapping_table_id 
	AND gmv.clm1_value = CASE WHEN temp.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END
	AND gmv.clm3_value = CAST(DATEPART(HH, dbo.FNAGetLOCALTime(CAST(temp.[deal_date] AS DATETIME),15)) AS VARCHAR(10)) 
	--AND gmv.clm5_value = CAST(CASE WHEN CAST(temp.[deal_date] AS DATETIME) >= d1.date AND CAST(temp.[deal_date] AS DATETIME) < d2.date THEN 1 ELSE 0 END AS VARCHAR(10)) 
WHERE ISDATE(temp.[deal_date]) = 1
AND NULLIF(gmv0.clm2_value,'''') IS NULL
AND gmv.generic_mapping_values_id IS NULL
AND gmv0.[clm1_value] NOT IN (''Saturday'', ''Sunday'')

UPDATE temp
	SET temp.[block_define_id] = sdv.code
FROM [final_process_table] temp
INNER JOIN mv90_dst d1 ON d1.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d1.insert_delete = ''d'' AND d1.dst_group_value_id = 102201
INNER JOIN mv90_dst d2 ON d2.year = YEAR(CAST(temp.[deal_date] AS DATE)) AND d2.insert_delete = ''i'' AND d2.dst_group_value_id = 102201
INNER JOIN generic_mapping_values gmv 
	ON gmv.mapping_table_id = @mapping_table_id 
	AND gmv.clm1_value = CASE WHEN temp.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) = 0, RTRIM(LTRIM(temp.term_start)),SUBSTRING(RTRIM(LTRIM(temp.term_start)), CHARINDEX('' '',RTRIM(LTRIM(temp.term_start))) + 1 , LEN(RTRIM(LTRIM(temp.term_start))))) ELSE temp.term_start END 
	AND gmv.clm3_value = CAST(DATEPART(HH, dbo.FNAGetLOCALTime(CAST(temp.[deal_date] AS DATETIME),15)) AS VARCHAR(10)) 
	--AND gmv.clm5_value = CAST(CASE WHEN CAST(temp.[deal_date] AS DATETIME) >= d1.date AND CAST(temp.[deal_date] AS DATETIME) < d2.date THEN 1 ELSE 0 END AS VARCHAR(10)) 
INNER JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm4_value
WHERE ISDATE(temp.[deal_date]) = 1

UPDATE t
    SET t.[block_define_id] = sdv.code
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
	ON gmv.mapping_table_id = @mapping_table_id
	AND t.[block_define_id] = gmv.clm2_value
    AND gmv.clm1_value = CASE WHEN t.[term_start] like ''%weekend%'' 
							      OR t.[term_start] like ''%Wk1-%'' 
							      OR t.[term_start] like ''%WkEnd%''
							  THEN ''WkEnd''
							  WHEN t.[term_start] like ''%sun%'' THEN ''SUN''
						  	  WHEN t.[term_start] like ''%sat%'' THEN ''SAT''					 
					     ELSE CASE WHEN t.curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'') THEN IIF(CHARINDEX('' '',RTRIM(LTRIM(t.term_start))) = 0, RTRIM(LTRIM(t.term_start)),SUBSTRING(RTRIM(LTRIM(t.term_start)), CHARINDEX('' '',RTRIM(LTRIM(t.term_start))) + 1 , LEN(RTRIM(LTRIM(t.term_start))))) ELSE t.term_start END END
INNER JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm4_value
WHERE t.[term_start] NOT IN (''Saturday'', ''Sunday'')

UPDATE t
    SET t.[block_define_id] = sdv.code
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
	ON gmv.mapping_table_id = @mapping_table_id
    AND gmv.clm1_value = t.[term_start]
INNER JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm4_value
WHERE t.[term_start] IN (''Saturday'', ''Sunday'')

UPDATE t
    SET t.[block_define_id] = sdv.code
FROM [final_process_table] t
INNER JOIN generic_mapping_values gmv
	ON gmv.mapping_table_id = @mapping_table_id
    AND t.[block_define_id] = gmv.clm2_value
INNER JOIN static_data_value sdv
	ON sdv.value_id = gmv.clm4_value
WHERE NULLIF(gmv.clm1_value,'''') IS NULL

UPDATE [final_process_table]
SET term_start = IIF(CHARINDEX('' '',term_start) = 0,term_start,SUBSTRING(term_start,0, CHARINDEX('' '',term_start)))
	,term_end = IIF(CHARINDEX('' '',term_end) = 0, term_end,SUBSTRING(term_end,0, CHARINDEX('' '',term_end)))
WHERE curve_id IN (''NCG L - WEST EEX'',''NCG L - EAST EEX'')

INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Data '''''' + t.[term_start] + '''''' not found for Column: FirstSequenceItemName. <span style=''''cursor:pointer'''' onClick=''''window.top.TRMWinHyperlink(20013000, "'' + t.[term_start] + ''")''''><font color=#0000ff><u><l> Create '' + t.[term_start] + ''<l></u></font></span>''
	, ''Error''
FROM [final_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.term_start = tmd.term_code
WHERE tmd.term_map_id IS NULL

INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Missing Value''
	, ''Data '''''' + t.[term_end] + '''''' not found for Column: SecondSequenceItemName. <span style=''''cursor:pointer'''' onClick=''''window.top.TRMWinHyperlink(20013000, "'' + t.[term_end] + ''")''''><font color=#0000ff><u><l> Create '' + t.[term_end] + ''<l></u></font></span>''
	, ''Error''
FROM [final_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.term_end = tmd.term_code
WHERE tmd.term_map_id IS NULL
AND NULLIF(t.term_end,'''') IS NOT NULL

DELETE t
FROM [final_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.term_start = tmd.term_code
WHERE tmd.term_map_id IS NULL

DELETE t
FROM [final_process_table] t
LEFT JOIN term_map_detail tmd
	ON t.term_end = tmd.term_code
WHERE tmd.term_map_id IS NULL
AND NULLIF(t.term_end,'''') IS NOT NULL

EXEC spa_trayport_deal_term_mapping @process_table = ''[final_process_table]''


UPDATE a
SET a.term_start = CAST(tmd.term_start AS DATE)
	, a.term_end = CAST(tmd.term_end AS DATE)
FROM [final_process_table] a
INNER JOIN term_map_detail tmd
	ON a.udf_value1 = tmd.term_code

UPDATE t
	SET t.template_id = ISNULL(sdht.template_name,t.template_id)
		,deal_volume_frequency = COALESCE( CASE gmv.clm6_value WHEN ''x'' THEN ''15 Minutes''
															   WHEN ''y'' THEN ''30 Minutes''
															   WHEN ''a'' THEN ''Annually''
															   WHEN ''d'' THEN ''Daily''
															   WHEN ''h'' THEN ''Hourly''
															   WHEN ''m'' THEN ''Monthly''
															   WHEN ''t'' THEN ''Term''
										   ELSE NULL END,NULLIF(t.deal_volume_frequency,''''))
		,multiplier = gmv.clm7_value
		,deal_volume_uom_id = COALESCE(su.uom_id,NULLIF(t.deal_volume_uom_id,''''))
		,position_uom = COALESCE(su1.uom_id,NULLIF(t.position_uom,''''))
		, commodity_id = sc.commodity_id
		, source_deal_type_id = COALESCE(sdt.deal_type_id, NULLIF(t.source_deal_type_id,''''))
FROM [final_process_table] t
INNER JOIN [temp_process_table] t1
	ON t1.[tradeid] = t.deal_id
LEFT JOIN term_map_detail tmd 
	ON tmd.term_code =  t1.[FirstSequenceItemName]
INNER JOIN generic_mapping_values gmv
    ON gmv.clm1_value = t.[curve_id]
	AND ISNULL(gmv.clm4_value,''-1'') = CASE WHEN gmv.clm4_value IS NULL THEN ''-1'' ELSE ISNULL(tmd.sequence,gmv.clm4_value) END
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
LEFT JOIN source_deal_header_template sdht
	ON sdht.template_id = gmv.clm5_value
LEFT JOIN source_uom su
	ON CAST(su.source_uom_id AS VARCHAR(10)) = gmv.clm8_value
LEFT JOIN source_commodity sc
	ON sc.source_commodity_id = gmv.clm3_value
LEFT JOIN source_uom su1
	ON CAST(su1.source_uom_id AS VARCHAR(10)) = gmv.clm9_value
LEFT JOIN source_deal_type sdt
	ON CAST(sdt.source_deal_type_id AS VARCHAR(10)) = gmv.clm10_value
WHERE gmh.mapping_name = ''Trayport product Mapping''

SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Book Mapping''

UPDATE t
SET t.sub_book = ssbm.logical_name
FROM [final_process_table] t
INNER JOIN [temp_process_table] t1
	ON t1.[tradeid] = t.deal_id
INNER JOIN source_commodity sc
	ON sc.commodity_id = t.commodity_id
LEFT JOIN generic_mapping_values gmv
    ON gmv.mapping_table_id = @mapping_table_id
	AND ISNULL(t.sub_book, '''') = ISNULL(gmv.clm3_value, '''')
	AND ISNULL(CAST(sc.source_commodity_id AS VARCHAR(10)), '''') = ISNULL(gmv.clm2_value, '''')
	AND ISNULL(CASE WHEN t1.AggressorCompany = ''Stadtwerke Hannover AG''
					THEN t1.[AggressorTrader]
					ELSE
						t1.[InitiatorTrader]
				END, '''') = ISNULL(gmv.clm1_value, '''')
LEFT JOIN generic_mapping_values gmv1
    ON gmv1.mapping_table_id = @mapping_table_id
	AND ISNULL(CAST(sc.source_commodity_id AS VARCHAR(10)), '''') = ISNULL(gmv1.clm2_value, '''')
	AND ISNULL(CASE WHEN t1.AggressorCompany = ''Stadtwerke Hannover AG''
					THEN t1.[AggressorTrader]
					ELSE
						t1.[InitiatorTrader]
				END, '''') = ISNULL(gmv1.clm1_value, '''')
INNER JOIN source_system_book_map ssbm
	ON ssbm.book_deal_type_map_id = COALESCE(gmv.clm4_value,gmv1.clm4_value)


SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Location Mapping''
UPDATE temp
	SET location_id = ISNULL(sml.location_id,temp.location_id)
FROM [final_process_table] temp
INNER JOIN [temp_process_table] t1
	ON t1.[tradeid] = temp.deal_id
INNER JOIN source_counterparty sc
	ON sc.counterparty_id = temp.counterparty_id
INNER JOIN source_commodity scm
	ON scm.commodity_id = temp.commodity_id
LEFT JOIN generic_mapping_values gmv 
	ON  mapping_table_id = @mapping_table_id
	AND  gmv.clm2_value = scm.source_commodity_id
    AND  ISNULL(gmv.clm3_value,1) = CASE WHEN scm.commodity_id = ''Power'' THEN sc.source_counterparty_id ELSE ISNULL(gmv.clm3_value,1) END
	AND  ISNULL(gmv.clm1_value,1) = CASE WHEN scm.commodity_id = ''Power'' THEN ISNULL(gmv.clm1_value,1) ELSE temp.curve_id END
LEFT JOIN source_minor_location sml
	ON sml.source_minor_location_id = gmv.clm4_value


UPDATE t
	SET t.curve_id = ISNULL(spcd.curve_id,t.curve_id)
FROM [final_process_table] t
INNER JOIN [temp_process_table] t1
	ON t1.[tradeid] = t.deal_id
LEFT JOIN term_map_detail tmd 
	ON tmd.term_code =  t1.[FirstSequenceItemName]
INNER JOIN generic_mapping_values gmv
    ON gmv.clm1_value = t.[curve_id]
	AND ISNULL(gmv.clm4_value,''-1'') = CASE WHEN gmv.clm4_value IS NULL THEN ''-1'' ELSE ISNULL(tmd.sequence,gmv.clm4_value) END
INNER join generic_mapping_header gmh
	ON gmv.mapping_table_id = gmh.mapping_table_id
LEFT JOIN source_price_curve_def spcd
	ON spcd.source_curve_def_id = gmv.clm2_value
WHERE gmh.mapping_name = ''Trayport product Mapping''

UPDATE temp
	SET physical_financial_flag = sdht.physical_financial_flag
	, physical_financial_flag_detail = sddt.physical_financial_flag
	, fixed_price_currency_id = sc.currency_id
	, deal_volume_frequency = COALESCE(NULLIF(temp.deal_volume_frequency,''''),sddt.deal_volume_frequency)
	, deal_volume_uom_id = COALESCE(NULLIF(temp.deal_volume_uom_id,''''),su.uom_id)
	, multiplier = COALESCE(NULLIF(temp.multiplier,''''),CAST(sddt.multiplier AS VARCHAR(20)))
	, position_uom = COALESCE(NULLIF(temp.position_uom,''''),su1.uom_id)
FROM [final_process_table] temp
INNER JOIN source_deal_header_template sdht
	ON sdht.template_name = temp.template_id
LEFT JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id --AND sddt.leg = ISNULL(temp.leg, 1) 
LEFT JOIN source_currency sc
	ON sc.source_currency_id = sddt.fixed_price_currency_id
LEFT JOIN source_uom su
	ON su.source_uom_id = sddt.deal_volume_uom_id
LEFT JOIN source_uom su1
	ON su1.source_uom_id = sddt.position_uom
	
SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Contract Mapping''

UPDATE s2
	SET contract_id = cg.contract_name
FROM [final_process_table] s2
INNER JOIN source_counterparty sc ON sc.counterparty_id = s2.counterparty_id
INNER JOIN source_commodity com ON com.commodity_id = s2.commodity_id
INNER JOIN generic_mapping_values gmv ON  mapping_table_id = @mapping_table_id
     AND gmv.clm1_value = CAST(sc.source_counterparty_id AS VARCHAR(20))
    AND  gmv.clm2_value = CAST(com.source_commodity_id  AS VARCHAR(20))
INNER JOIN contract_group cg
	ON CAST(cg.contract_id AS VARCHAR(20)) = gmv.clm3_value

UPDATE temp	
	SET shipper_code1 = scmd1.shipper_code1
	,	shipper_code2 = scmd2.shipper_code
FROM [final_process_table] temp
INNER JOIN source_counterparty sc
	ON sc.counterparty_id = temp.counterparty_id
INNER JOIN source_minor_location sml
	ON sml.location_id = temp.location_id
INNER JOIN shipper_code_mapping scm
	ON scm.counterparty_id = sc.source_counterparty_id
OUTER APPLY (
	SELECT MAX(effective_date) effective_date
	FROM shipper_code_mapping_detail
	WHERE location_id = sml.source_minor_location_id
	AND ISNULL(is_default,''n'') = ''y''
	AND ISNULL(is_active,''n'') = ''y''
	AND shipper_code_id = scm.shipper_code_id
) shipper_code2_max_date
OUTER APPLY (
	SELECT MAX(effective_date) effective_date
	FROM shipper_code_mapping_detail
	WHERE location_id = sml.source_minor_location_id
	AND ISNULL(shipper_code1_is_default,''n'') = ''y''
	AND ISNULL(is_active,''n'') = ''y''
	AND shipper_code_id = scm.shipper_code_id
) shipper_code1_max_date
LEFT JOIN shipper_code_mapping_detail scmd2
	ON scmd2.location_id = sml.source_minor_location_id
	AND scmd2.effective_date = shipper_code2_max_date.effective_date
	AND ISNULL(scmd2.is_default,''n'') = ''y''
	AND ISNULL(scmd2.is_active,''n'') = ''y'' 
	AND scmd2.shipper_code_id = scm.shipper_code_id
LEFT JOIN shipper_code_mapping_detail scmd1
	ON scmd1.location_id = sml.source_minor_location_id
	AND scmd1.effective_date = shipper_code1_max_date.effective_date
	AND ISNULL(scmd1.is_default,''n'') = ''y''
	AND ISNULL(scmd1.is_active,''n'') = ''y'' 
	AND scmd1.shipper_code_id = scm.shipper_code_id

UPDATE temp
	SET deal_date = CAST(deal_date AS DATE),
		term_start = CAST(CASE WHEN ISNULL(t1.FirstSequenceItemName,t1.SecondSequenceItemName) = ''Saturday'' THEN DATEADD(dd, 7-(DATEPART(dw, deal_date)), deal_date)
							   WHEN ISNULL(t1.FirstSequenceItemName,t1.SecondSequenceItemName) = ''Sunday'' THEN DATEADD(dd, 8-(DATEPART(dw, deal_date)), deal_date)
						  ELSE term_start END
					 AS DATE),
		term_end = CAST(CASE WHEN ISNULL(t1.FirstSequenceItemName,t1.SecondSequenceItemName) = ''Saturday'' THEN DATEADD(dd, 7-(DATEPART(dw, deal_date)), deal_date)
							   WHEN ISNULL(t1.FirstSequenceItemName,t1.SecondSequenceItemName) = ''Sunday'' THEN DATEADD(dd, 8-(DATEPART(dw, deal_date)), deal_date)
						  ELSE term_end END
					 AS DATE)
FROM [final_process_table] temp
INNER JOIN [temp_process_table] t1
	ON t1.[tradeid] = temp.deal_id

DECLARE @ixp_import_rules_name NVARCHAR(1000)
SELECT @ixp_import_rules_name = REPLACE(dir_path,''Rules:'','''')
FROM import_data_files_audit
WHERE process_id = @set_process_id

IF OBJECT_ID(''tempdb..#temp_udf_data'') IS NOT NULL
		DROP TABLE #temp_udf_data

CREATE TABLE #temp_udf_data (
	[Delivery Path] VARCHAR(150) COLLATE DATABASE_DEFAULT
)

INSERT INTO #temp_udf_data([Delivery Path])
SELECT [Delivery Path]
FROM (
	SELECT ic.ixp_columns_name, udft.field_label
	FROM ixp_rules ir
	INNER JOIN ixp_import_data_mapping iidm ON iidm.ixp_rules_id = ir.ixp_rules_id
	INNER JOIN ixp_tables it ON iidm.dest_table_id = it.ixp_tables_id
	INNER JOIN ixp_columns ic ON it.ixp_tables_id = ic.ixp_table_id AND ic.ixp_columns_id = iidm.dest_column
	INNER JOIN user_defined_fields_template udft
		ON udft.field_id = iidm.udf_field_id
	WHERE ir.ixp_rules_name = @ixp_import_rules_name
	AND iidm.udf_field_id IS NOT NULL
	AND udft.field_label IN (''Delivery Path'')
	) AS a
PIVOT(MAX(a.ixp_columns_name) FOR a.Field_label IN ([Delivery Path])) AS P

SELECT @mapping_table_id = mapping_table_id 
FROM generic_mapping_header 
WHERE mapping_name = ''Trayport Autopath Mapping''

DECLARE @udf_update_query NVARCHAR(MAX), @sql_query NVARCHAR(MAX)
SELECT @udf_update_query = [Delivery Path] + ''= dp.path_code''
FROM #temp_udf_data

SET @sql_query = ''
	UPDATE temp
	SET shipper_code1 = gmv.clm6_value
	,	shipper_code2 = gmv.clm7_value
	, internal_portfolio_id = sdv_product.code
	'' + CASE WHEN @udf_update_query IS NOT NULL THEN '', '' + @udf_update_query ELSE '''' END + ''
	FROM [final_process_table] temp
	INNER JOIN [temp_process_table] t1
		ON t1.[tradeid] = temp.deal_id
	LEFT JOIN generic_mapping_values gmv 
		ON  mapping_table_id =   '''''' + CAST(@mapping_table_id AS VARCHAR(10)) + ''''''
		AND  gmv.clm1_value = t1.[InstName]
		AND  COALESCE(gmv.clm2_value,t1.[Book],''''-1'''') = ISNULL(t1.[Book], ''''-1'''')
		AND  COALESCE(gmv.clm3_value,CASE temp.header_buy_sell_flag WHEN ''''Buy'''' THEN ''''b'''' WHEN ''''Sell'''' THEN ''''s'''' ELSE temp.header_buy_sell_flag END,''''-1'''') = ISNULL(CASE temp.header_buy_sell_flag WHEN ''''Buy'''' THEN ''''b'''' WHEN ''''Sell'''' THEN ''''s'''' ELSE temp.header_buy_sell_flag END, ''''-1'''')
	LEFT JOIN delivery_path dp
		ON CAST(dp.path_id AS VARCHAR(10)) = gmv.clm4_value
	LEFT JOIN static_data_value sdv_product
		ON CAST(sdv_product.value_id  AS VARCHAR(10)) = gmv.clm5_value
		AND sdv_product.[type_id] = 39800
	WHERE gmv.clm1_value in ( ''''NCG L - WEST EEX'''',''''NCG L - EAST EEX'''')
''
EXEC(@sql_query)


INSERT INTO source_system_data_import_status_detail(
	process_id
	, source
	, [type]
	, description
	, type_error
)
SELECT DISTINCT @set_process_id
	, ''ixp_source_deal_template''
	, ''Data Warning''
	, ''Shipper code mapping not found for''  + CASE WHEN temp.shipper_code1 IS NULL AND temp.shipper_code2 IS NULL THEN '' shipper code 1 and shipper code 2''
											  ELSE IIF(temp.shipper_code1 IS NULL, '' shipper code 1'', '' shipper code 2'') END
		
		+ '' for Deal : '' + temp.deal_id
	, ''Warning''
FROM [final_process_table] temp
WHERE temp.shipper_code1 IS NULL OR temp.shipper_code2 IS NULL'
				, after_insert_trigger = 'DECLARE @mapping_table_id INT
DECLARE @set_process_id VARCHAR(40)
	, @hyperlink_row_count INT
	, @row_count VARCHAR(10)
	,@total_deal INT, @imported_deal INT
	,@book_update_deals NVARCHAR(MAX) = ''''
	,@desc NVARCHAR(MAX)
	,@user_login_id NVARCHAR(100) = dbo.FNADBUSER()

SELECT @set_process_id = REVERSE(SUBSTRING(REVERSE(''[temp_process_table]''), 0,37))

DECLARE @temp_process_table NVARCHAR(1000) = dbo.FNAProcessTableName(''temp_pre_import_data'', dbo.FNADBUser(), @set_process_id)
IF OBJECT_ID(''tempdb..#temp_deal_import_count'') IS NOT NULL
	DROP TABLE #temp_deal_import_count

CREATE TABLE #temp_deal_import_count(
	pre_deal_id VARCHAR(100),
	post_deal_id VARCHAR(100)
)

EXEC(''INSERT INTO #temp_deal_import_count
	SELECT temp.[tradeid],tbl.deal_id
	FROM '' + @temp_process_table + '' temp
	OUTER APPLY( SELECT DISTINCT deal_id
					FROM [temp_process_table]
					WHERE deal_id = temp.[tradeid]
	) tbl
'')

SELECT @total_deal = COUNT(pre_deal_id)
FROM #temp_deal_import_count

SELECT @imported_deal = COUNT(pre_deal_id)
FROM #temp_deal_import_count
WHERE post_deal_id IS NOT NULL


IF EXISTS(SELECT 1 FROM source_system_data_import_status
	  WHERE process_id = @set_process_id
	  AND description like ''%Data imported Successfully out of%''
	  )
BEGIN
	UPDATE source_system_data_import_status
		SET description = CAST(@imported_deal AS VARCHAR(10)) + '' Data imported Successfully out of '' + CAST(@total_deal AS VARCHAR(10)) + '' rows.''
	WHERE process_id = @set_process_id
	AND description like ''%Data imported Successfully out of%''
END
ELSE 
BEGIN
	INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation, rules_name) 
	SELECT DISTINCT @set_process_id,
		''Error'',
		''Import Data'',
		''ixp_source_deal_template'',
		''Error'',
		CAST(@imported_deal AS VARCHAR(10)) + '' Data imported Successfully out of '' + CAST(@total_deal AS VARCHAR(10)) + '' rows.'',
		''Please verify data.'',
		''Trayport''
END

IF OBJECT_ID(''tempdb..#temp_deal_udf_values'') IS NOT NULL
		DROP TABLE #temp_deal_udf_values

CREATE TABLE #temp_deal_udf_values (
	[source_deal_header_id] INT, 
	[deal_id] NVARCHAR(400),
	[Trayport Date Time] NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
	[Trayport Last Update] NVARCHAR(1000) COLLATE DATABASE_DEFAULT
)

INSERT INTO #temp_deal_udf_values (source_deal_header_id,deal_id, [Trayport Date Time], [Trayport Last Update])
SELECT source_deal_header_id,deal_id, [Trayport Date Time], [Trayport Last Update]
FROM (
	SELECT sdh.source_deal_header_id, sdh.deal_id, udft.field_label, uddf.udf_value
	FROM [temp_process_table] temp
	INNER JOIN source_deal_header sdh
		ON sdh.deal_id = temp.deal_id
	INNER JOIN user_defined_deal_fields uddf
		ON uddf.source_deal_header_id = sdh.source_deal_header_id
			AND NULLIF(uddf.udf_value, '''') IS NOT NULL
	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.udf_template_id = uddf.udf_template_id
	INNER JOIN user_defined_fields_template udft
		ON udft.field_id = uddft.field_id
	) AS a
PIVOT (MAX(a.udf_value) FOR a.Field_label IN ([Trayport Date Time], [Trayport Last Update])) AS p


SELECT @book_update_deals = STUFF((SELECT DISTINCT '', '' +  dbo.FNATRMWinHyperlink(''a'', 10131010, deal_id,source_deal_header_id,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
							FROM #temp_deal_udf_values
							WHERE DATEDIFF(MINUTE, CAST([Trayport Date Time] AS DATETIME), CAST([Trayport Last Update] AS DATETIME)) > 30
					 FOR XML PATH('''')), 1, 1, '''')
					 
SELECT @book_update_deals = dbo.FNADECODEXML(@book_update_deals)

IF NULLIF(@book_update_deals,'''') IS NOT NULL
BEGIN
	SET @desc = ''Trayport Book has been updated for Deal ID : '' + @book_update_deals
	
    INSERT INTO message_board(user_login_id, source, [description], url_desc, url, [type], job_name, as_of_date, process_id, process_type,is_alert)
    SELECT DISTINCT au.user_login_id, ''Trayport Deal Import'' , @desc, NULL, NULL, ''w'',NULL, NULL,@set_process_id,NULL, ''y''
    FROM dbo.application_role_user aru
    INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
    INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
    WHERE (au.user_active = ''y'') AND (asr.role_type_value_id = 4) AND au.user_emal_add IS NOT NULL
    GROUP BY au.user_login_id, au.user_emal_add	
END



    

--insert into sk(type,name) values(''after_temp'', ''[temp_process_table]'')
--insert into sk(type,name) values(''after_final'', ''[final_process_table]'')



SELECT @row_count = [description] 
FROM source_system_data_import_status 
WHERE process_id = @set_process_id
	AND rules_name = ''Trayport''

SELECT @hyperlink_row_count = count(*) 
FROM source_system_data_import_status_detail 
WHERE process_id = @set_process_id 
	AND description like ''%Create %''

	UPDATE sdh
    SET sdh.reporting_group1 = IIF(bkr.counterparty_id IN (''EEX_broker'', ''ICE_Broker'', ''EEX_SPOT_BROKER'',''ICAP''), NULL, ''50000361'')
FROM source_deal_header sdh
INNER JOIN [temp_process_table] t
    ON t.deal_id = sdh.deal_id
INNER JOIN source_counterparty sc
    ON sc.source_counterparty_id = sdh.counterparty_id
LEFT JOIN source_counterparty bkr
    ON bkr.source_counterparty_id = sdh.broker_id
WHERE sc.counterparty_id in(''ICE'',''EEX'')'
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23502
				, is_system_import = 'n'
				, is_active = 1
			WHERE ixp_rules_id = @ixp_rules_id_new
				
		END

				
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  0,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_source_deal_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\EU-U-SQL03\shared_docs_TRMTracker_Enercity_UAT\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'tdi',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   'Sheet1',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   icf.ixp_clr_functions_id,
						   '', 
						   '0',
						   '0',
						   NULL,
						   NULL
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new
						IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
						BEGIN
							UPDATE iids
							SET folder_location = piids.folder_location
								, file_transfer_endpoint_id = piids.file_transfer_endpoint_id
								, remote_directory = piids.remote_directory
							FROM ixp_import_data_source iids
							INNER JOIN #pre_ixp_import_data_source piids 
							ON iids.rules_id = piids.rules_id
						END
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[TradeID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[DateTime]', ic.ixp_columns_id, 'CAST(tdi.[DateTime] AS VARCHAR(23))', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, NULL, ic.ixp_columns_id, '''p''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'physical_financial_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorCompany]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN MAX(tdi.[InitiatorCompany])
    ELSE
        tdi.[AggressorCompany]
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorBrokerID]', ic.ixp_columns_id, '''Physical''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_deal_type_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorOwnedSpread]', ic.ixp_columns_id, 'CASE WHEN tdi.[InitiatorOwnedSpread]=''TRUE'' THEN ''1''
ELSE ''0'' END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorOwnedSpread]', ic.ixp_columns_id, 'CASE WHEN tdi.[AggressorOwnedSpread]=''TRUE'' THEN ''1''
ELSE ''0'' END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggSleeve]', ic.ixp_columns_id, 'CASE WHEN tdi.[AggSleeve]=''TRUE'' THEN ''1''
ELSE ''0'' END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, NULL, ic.ixp_columns_id, '''Real''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_category_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorTrader]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN tdi.[AggressorTrader]
    ELSE
        MAX(tdi.[InitiatorTrader])
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trader_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorTraderID]', ic.ixp_columns_id, '''Physical''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'template_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorAction]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN tdi.[AggressorAction]
    ELSE
        tdi.[InitiatorAction]
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'header_buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorBroker]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN tdi.[AggressorBroker]
    ELSE
        MAX(tdi.[InitiatorBroker])
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'broker_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[initiatorBroker]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'aggregate_envrionment_comment' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorUser]', ic.ixp_columns_id, '''Default_contract''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, NULL, ic.ixp_columns_id, '''deal volume''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_desk_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[CPTY_Commodity]', ic.ixp_columns_id, 'CASE WHEN tdi.[instname]=''Germany Baseload EEX'' THEN ''POWER''
WHEN tdi.[instname]=''Germany Baseload'' THEN ''POWER''
WHEN tdi.[instname]=''Germany 20-24'' THEN ''POWER''
WHEN tdi.[instname]=''Germany 16-20'' THEN ''POWER''
WHEN tdi.[instname]=''Germany 12-16'' THEN ''POWER''
WHEN tdi.[instname]=''Germany 0-6'' THEN ''POWER''
WHEN tdi.[instname]=''Germany Off-Peaks'' THEN ''POWER''
WHEN tdi.[instname]=''Germany Peaks'' THEN ''POWER''
WHEN tdi.[instname]=''NCG EEX'' THEN ''GAS'' 
WHEN tdi.[instname]=''TTF Hi Cal 51.6 ICE ENDEX'' THEN ''GAS''
WHEN tdi.[instname]=''TTF Hi Cal 51.6'' THEN ''GAS''
WHEN tdi.[instname]=''NCG ICE BLOCK'' THEN ''GAS''
WHEN tdi.[instname]=''GASPOOL'' THEN ''GAS''
WHEN tdi.[instname]=''Germany Baseload EEX'' THEN ''POWER''
WHEN tdi.[instname]=''EUA ECX'' THEN ''EUA''
WHEN tdi.[instname]=''CER ECX'' THEN ''CER''
WHEN tdi.[instname]=''CER EEX'' THEN ''CER''
WHEN tdi.[instname]=''EUA EEX'' THEN ''EUA''
ELSE ''GAS'' END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'commodity_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorTrader]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN tdi.[InitiatorTrader]
    ELSE
        MAX(tdi.[AggressorTrader])
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reference' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InstName]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'block_define_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[Action]', ic.ixp_columns_id, 'CASE WHEN tdi.[action]=''Query'' THEN ''New'' 
WHEN tdi.[action]=''Insert'' THEN ''New''
WHEN tdi.[action]=''Update'' THEN ''Amended'' 
ELSE ''Void''
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorUserID]', ic.ixp_columns_id, '''Not Confirmed''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'confirm_status_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[Book]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_book' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitSleeve]', ic.ixp_columns_id, 'CASE WHEN tdi.[InitSleeve]=''TRUE'' THEN ''1''
ELSE ''0'' END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[FirstSequenceItemName]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_start' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[SecondSequenceItemName]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_end' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[TradeID]', ic.ixp_columns_id, '''1''', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, NULL, ic.ixp_columns_id, '''t''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_float_leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorAction]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN tdi.[AggressorAction]
    ELSE
        tdi.[InitiatorAction]
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InstName]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[price]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, NULL, ic.ixp_columns_id, '''EUR''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price_currency_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[Unit]', ic.ixp_columns_id, 'CASE WHEN tdi.[Unit]=''Mwh/h'' THEN ''MWh'' 
WHEN tdi.[Unit]=''000''''MT'' THEN ''MT'' 
else tdi.[Unit] END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_uom_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[initiatorCompany]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_detail_description' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[IsMarketData]', ic.ixp_columns_id, '''default_location''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'location_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, NULL, ic.ixp_columns_id, '''Fixed Priced''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'pricing_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, NULL, ic.ixp_columns_id, '''Hourly''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'profile_granularity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggSleeve]', ic.ixp_columns_id, 'CASE WHEN tdi.[AggressorCompany] = ''Stadtwerke Hannover AG'' AND tdi.[AggSleeve]=''TRUE'' THEN ''PTTA''
	 WHEN tdi.[AggressorCompany] = ''Stadtwerke Hannover AG'' AND tdi.[InitSleeve]=''TRUE'' THEN ''PTTP''
	 WHEN tdi.[initiatorCompany] = ''Stadtwerke Hannover AG'' AND tdi.[AggSleeve]=''TRUE'' THEN ''PTTP''
	 WHEN tdi.[initiatorCompany] = ''Stadtwerke Hannover AG'' AND tdi.[InitSleeve]=''TRUE'' THEN ''PTTA''
    ELSE
        ''''
END', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, NULL, ic.ixp_columns_id, '''''', 'Max', 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Delivery Path' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Delivery Path'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, NULL, ic.ixp_columns_id, '''''', 'Max', 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Product group' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Product group'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[InitiatorOwnedSpread]', ic.ixp_columns_id, 'CASE
    WHEN tdi.[InitiatorCompany] = ''Stadtwerke Hannover AG'' AND tdi.[InitiatorOwnedSpread]=''TRUE''
        THEN ''Yes''
    WHEN tdi.[InitiatorCompany] = ''Stadtwerke Hannover AG'' AND tdi.[InitiatorOwnedSpread]=''FALSE''
        THEN (CASE WHEN NULLIF(NULLIF(tdi.[ForeignRelationshipID], ''''), 0) IS NOT NULL THEN ''Yes'' ELSE ''No'' END)
    WHEN tdi.[AggressorCompany] = ''Stadtwerke Hannover AG'' AND tdi.[AggressorOwnedSpread]=''TRUE''
        THEN ''Yes''
    ELSE (CASE WHEN NULLIF(NULLIF(tdi.[ForeignRelationshipID], ''''), 0) IS NOT NULL THEN ''Yes'' ELSE ''No'' END)
END', NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Spread' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Spread'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[LastUpdate]', ic.ixp_columns_id, 'CONVERT(VARCHAR(30),dbo.FNAGetLOCALTime(CAST(tdi.[LastUpdate] AS VARCHAR(23)),15), 127)', NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Trayport Last Update' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Trayport Last Update'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[DateTime]', ic.ixp_columns_id, 'CONVERT(VARCHAR(30),dbo.FNAGetLOCALTime(CAST(tdi.[DateTime] AS VARCHAR(23)),15), 127)', NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Trayport Date Time' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value5' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Trayport Date Time'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[ExecutionDT]', ic.ixp_columns_id, 'CONVERT(VARCHAR(30),dbo.FNAGetLOCALTime(CAST(tdi.[ExecutionDT] AS VARCHAR(23)),15), 127)', NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Execution Timestamp' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value6' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Execution Timestamp'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[AggressorUserID]', ic.ixp_columns_id, 'CASE WHEN tdi.AggressorCompany = ''Stadtwerke Hannover AG''
    THEN ''No''
    ELSE
        ''Yes''
END', NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Initiator/Aggressor' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value7' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Initiator/Aggressor'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, NULL, ic.ixp_columns_id, 'CASE WHEN tdi.[InitiatorCompany] = ''Stadtwerke Hannover AG'' AND tdi.[InitSleeve]=''TRUE''  THEN ''Yes''
	 WHEN tdi.[InitiatorCompany] = ''Stadtwerke Hannover AG'' AND tdi.[InitSleeve]=''FALSE''  THEN ''No''
	 WHEN tdi.[AggressorCompany] = ''Stadtwerke Hannover AG'' AND tdi.[AggSleeve]=''TRUE''  THEN ''Yes''
ELSE ''No''
END', NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Sleeve' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value8' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Sleeve'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[VoiceDeal]', ic.ixp_columns_id, 'CASE WHEN tdi.[VoiceDeal] = ''YES''   THEN ''Broker_Voice''
ELSE ''Broker''
END', NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Broker Contract' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value9' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Broker Contract'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'tdi.[ForeignRelationshipID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'ForeignRelationshipID' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value10' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'ForeignRelationshipID'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template'

COMMIT 

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
				DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
				DECLARE @msg_severity INT = ERROR_SEVERITY();
				DECLARE @msg_state INT = ERROR_STATE();
					
				RAISERROR(@msg, @msg_severity, @msg_state)
			
				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
END
