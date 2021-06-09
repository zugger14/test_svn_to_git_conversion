BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'ct'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'ct' and name <> 'CalculateTax')
	begin
		select top 1 @new_ds_alias = 'ct' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'ct' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'CalculateTax'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'CalculateTax' AND '106501' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'CalculateTax' AS [name], @new_ds_alias AS ALIAS, 'CalculateTax' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'0' AS [system_defined]
			,'106501' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'CalculateTax'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE 
----User Parameter:
	@_price VARCHAR(100),
	@_charge_type VARCHAR(100),
	@_tax_type VARCHAR(100)
	----System Paramer:
	,@_calc_type VARCHAR(10)
	,@_as_of_date varchar(10)
	,@_farrms_calc_process_table VARCHAR(250) --=''adiha_process.dbo.UDV_func_input_table_DEBUG_MODE_ON_2A41E6F9_6B13_4630_B48A_4BEB64931F73__1787__1__1''  --''adiha_process.dbo.curve_formula_table3_DEBUG_MODE_ON_BC52B9D9_1AB5_423D_B78B_B39D2834B8A7'' -- The required granularity of data should be in this process table with function required columns as system parameter.
SET @_price = NULLIF(ISNULL(@_price, NULLIF(''@price'', REPLACE(''@_price'', ''@_'', ''@''))), ''NULL'')
SET @_charge_type = NULLIF(ISNULL(@_charge_type, NULLIF(''@charge_type'', REPLACE(''@_charge_type'', ''@_'', ''@''))), ''NULL'')
SET @_tax_type = NULLIF(ISNULL(@_tax_type, NULLIF(''@tax_type'', REPLACE(''@_tax_type'', ''@_'', ''@''))), ''NULL'')
SET @_calc_type = NULLIF(ISNULL(@_calc_type, NULLIF(''@calc_type'', REPLACE(''@_calc_type'', ''@_'', ''@''))), ''NULL'')
SET @_as_of_date = nullif(isnull(@_as_of_date, nullif(''@as_of_date'', replace(''@_as_of_date'', ''@_'', ''@''))), ''null'')
SET @_farrms_calc_process_table = NULLIF(ISNULL(@_farrms_calc_process_table, NULLIF(''@farrms_calc_process_table'', REPLACE(''@_farrms_calc_process_table'', ''@_'', ''@''))), ''NULL'')

--SET @_calc_type = ''s''
--SET @_farrms_calc_process_table = ''adiha_process.dbo.UDV_func_input_table_dev_admin_4EEA2195_FEA5_4AF9_960A_932289__236__1__1''
--SET @_charge_type = -10019
--SET @_tax_type = ''v''
--SET @_price = ''P''

DECLARE @_sql VARCHAR(MAX),@_table_name VARCHAR(250)
IF @_farrms_calc_process_table = ''1900''  goto level_end_function
--------------------- Debug Mode-------------------------------------------------------------------------------
IF OBJECT_ID(@_farrms_calc_process_table) IS NULL 
BEGIN
-- Most of these columns are exist in process table.
	SET @_sql=''
		select  func_rowid=identity(int,1,1), 
		cast(''''2020-01-01'''' as date) as_of_date,
		4500 curve_source_value_id, 
		cast(sdd.term_start as date) prod_date,
		cast(sdd.term_end as date) prod_date_to,
		cast(sdd.formula_id as int) formula_id,
		cast(null as int) granularity,
		cast(sdh.contract_id as int) contract_id,
		cast(sdd.source_deal_detail_id as int) source_deal_detail_id,
		cast(null as int) [Hours],
		cast(null as int) is_dst,
		cast(null as int) [period],
		cast(null as int) [mins],
		cast(null as  numeric(20,8)) volume,
		cast(sdh.counterparty_id as int) counterparty_id ,
		cast(sdd.curve_id as int) curve_id,
		cast(null as numeric(20,8)) onPeakVolume,
		cast(null as int) invoice_Line_item_id,			
		cast(null as int) invoice_line_item_seq_id,
		cast(null as float)	price,			
		cast(null as int) volume_uom_id,
		cast(null as int) generator_id,
		cast(null as int) commodity_id,
		cast(null as int) meter_id,
		cast(sdh.source_deal_header_id as int) source_deal_header_id,
		''''n'''' calc_aggregation,
		cast(null as int) internal_field_type,
		cast(null as int) sequence_order,
		cast(null as int) udf_template_id,
		cast(null as int) ticket_detail_id ,
		cast(null as int) shipment_id,
		cast(null as int) deal_price_type_id
		into '' + @_farrms_calc_process_table
		+'' 
		from source_deal_header sdh inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		where sdh.source_deal_header_id = 33188
			-- and sdh.source_deal_detail_id = 33188
	''
	EXEC spa_print @_sql
END
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
----------------Start Function Logic -------------------------------------------------------------
IF OBJECT_ID(''tempdb..#ud_function_evaluation'') IS NULL
CREATE TABLE #ud_function_evaluation(
	func_rowid INT, 
	tax_value INT,
	contract_id INT,
	source_deal_header_id INT,
	source_deal_detail_id INT,
	data_source_id INT,
	formula_id INT,
	nested_id INT,
	level_func_sno INT,
	prod_date DATETIME,
	hour INT,
	mins INT,
	value NUMERIC(28,10)
)
IF OBJECT_ID(''tempdb..#table_tax_rules'') IS NOT NULL
    DROP TABLE #table_tax_rules  
IF OBJECT_ID(''tempdb..#table_cpty_tax_info'') IS NOT NULL
    DROP TABLE #table_cpty_tax_info  
SELECT generic_mapping_values_id,
	CAST(clm1_value AS VARCHAR(MAX)) effective_date, 
	CAST(clm2_value AS VARCHAR(MAX)) region,
	CAST(clm3_value AS VARCHAR(MAX)) counterparty_type,
	CAST(clm4_value AS VARCHAR(MAX)) commodity,
	CAST(clm5_value AS VARCHAR(MAX)) reseller_certificate,
	CAST(clm6_value AS VARCHAR(MAX)) energy_tax_exemption,
	CAST(clm7_value AS VARCHAR(MAX)) document_type,
	CAST(clm8_value AS VARCHAR(MAX)) price,
	CAST(clm9_value AS VARCHAR(MAX)) charge_type,
	CAST(clm10_value AS VARCHAR(MAX)) tax_type,
	CAST(clm11_value AS VARCHAR(MAX)) tax_unit,
	CAST(clm12_value AS VARCHAR(MAX)) tax_percentage
INTO #table_tax_rules
FROM generic_mapping_header gmh
INNER JOIN generic_mapping_values gmv 
	ON gmv.mapping_table_id=gmh.mapping_table_id 
AND gmh.mapping_name = ''Tax Rules''
SELECT DISTINCT CAST(clm1_value AS VARCHAR(MAX)) counterparty_id, 
	CAST(clm2_value AS VARCHAR(MAX)) [commodity],
	CAST(clm5_value AS VARCHAR(MAX)) [value],
	CAST(clm6_value AS VARCHAR(MAX)) [yes_no]
INTO #table_cpty_tax_info
FROM generic_mapping_header gmh
INNER JOIN generic_mapping_values gmv 
	ON gmv.mapping_table_id=gmh.mapping_table_id 
AND gmh.mapping_name = ''Counterparty Tax Info''

SET @_sql = ''
SELECT a.source_deal_header_id, fb.eval_value tax_value 
	INTO #temp_tax_value
FROM #formula_breakdown fb
INNER JOIN '' + @_farrms_calc_process_table + '' a
	ON a.source_deal_header_id = fb.source_deal_header_id
OUTER APPLY (
	SELECT MAX(field_name) field_name 
		FROM user_defined_deal_fields_template uddft 
	INNER JOIN static_data_value sdv 
		ON sdv.value_id = uddft.field_name
	WHERE udf_template_id = fb.udf_template_id
) b
INNER JOIN static_data_value sdv 
	ON sdv.value_id = b.field_name
WHERE sdv.code =  ''''Commodity Energy Tax''''

SELECT MAX(f.func_rowid) func_rowid,
	CASE WHEN '''''' + @_tax_type + '''''' = ''''v'''' 
		THEN MAX(CAST(ttr.tax_percentage AS FLOAT)) 
	ELSE 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = ''''s'''' THEN 1 ELSE -1 END * ABS(MAX(CAST(ttr.tax_unit AS FLOAT))) 
	END * 
	(CASE WHEN '''''' + @_tax_type + '''''' = ''''v'''' THEN 
		CASE WHEN '''''' + @_price + '''''' = ''''n'''' THEN (MAX(fees_negative.[value])) 
			WHEN '''''' + @_price + '''''' = ''''p'''' THEN (MAX(fees_positive.[value])) 
			ELSE ISNULL(MAX(fees_positive.[value]),0) + ISNULL(MAX(fees_negative.[value]), 0)
		END + ISNULL(MAX(ttv.tax_value), 0)
	ELSE 
		ABS(CASE WHEN '''''' + @_price + '''''' = ''''n'''' THEN (MAX(fees_negative.volume)) 
			WHEN '''''' + @_price + '''''' = ''''p'''' THEN (MAX(fees_positive.volume)) 
		ELSE ISNULL(MAX(fees_positive.volume), 0) + ISNULL(MAX(fees_negative.volume), 0) END)
	END) eval_value
INTO #func_output_value
FROM '' + @_farrms_calc_process_table + '' f 
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = f.source_deal_header_id
INNER JOIN source_counterparty sc 
	ON sc.source_counterparty_id = sdh.counterparty_id
LEFT JOIN #temp_tax_value ttv ON ttv.source_deal_header_id = f.source_deal_header_id
OUTER APPLY (
	SELECT MAX(cc.region) region 
		FROM counterparty_contract_address cca 
	INNER JOIN counterparty_contacts cc
		ON cc.counterparty_id = sc.source_counterparty_id 
		AND cca.receivables = cc.counterparty_contact_id
	WHERE cca.contract_id = sdh.contract_id AND cca.counterparty_id = sdh.counterparty_id
) r
OUTER APPLY (
	SELECT ifbs.value FROM index_fees_breakdown_settlement ifbs
		INNER JOIN user_defined_fields_template udft 
	ON udft.field_label = ifbs.field_name AND udft.udf_category = 101902
	WHERE source_deal_header_id = sdh.source_deal_header_id
	AND term_start =f.prod_date 
) tax_amt
CROSS APPLY(
	SELECT MAX(ISNULL(effective_date,''''9999-01-01'''')) effective_date 
		FROM #table_tax_rules ttr2
	INNER JOIN #table_cpty_tax_info ti1 
		ON ti1.counterparty_id = sdh.counterparty_id 
		AND ti1.[yes_no] = ttr2.reseller_certificate
		AND ti1.[value] = ''''reseller_certificate''''
		AND ti1.commodity = ttr2.commodity
	INNER JOIN #table_cpty_tax_info ti2 
		ON ti2.counterparty_id = sdh.counterparty_id 
		AND ti2.[yes_no] = ttr2.energy_tax_exemption
		AND ti2.[value] = ''''energy_tax_exemption''''
		AND ti2.commodity = ttr2.commodity
	WHERE region = r.region
	AND  counterparty_type =sc.int_ext_flag 
	AND sdh.commodity_id = sdh.commodity_id
	AND effective_date<=sdh.entire_term_start 
	AND price = '''''' + @_price + ''''''
) ttr1
INNER JOIN #table_tax_rules ttr
	ON ISNULL(ttr.effective_date,''''9999-01-01'''') = ttr1.effective_date 
	AND r.region = ttr.region
	AND sc.int_ext_flag = ttr.counterparty_type
	AND ttr.commodity = sdh.commodity_id
OUTER APPLY (
	SELECT SUM(volume) volume, SUM(value) value 
		FROM index_fees_breakdown_settlement 
	INNER JOIN static_data_value sdv ON sdv.value_id = field_id
	WHERE source_deal_header_id = sdh.source_deal_header_id
	AND term_start = f.prod_date
	AND sdv.code = ''''Negative Price Commodity''''  HAVING SUM(value) <> 0
) fees_negative
OUTER APPLY (
	SELECT SUM(volume) volume, SUM(value) value 
		FROM index_fees_breakdown_settlement 
	INNER JOIN static_data_value sdv ON sdv.value_id = field_id
	WHERE source_deal_header_id = sdh.source_deal_header_id 
	AND term_start = f.prod_date
	AND sdv.code = ''''Positive Price Commodity'''' HAVING SUM(value) <> 0
) fees_positive
OUTER APPLY (
	SELECT MAX(b.document_type) document_type FROM (
		SELECT a.document_type
			FROM #table_tax_rules a 
		WHERE a.effective_date = ttr.effective_date
		AND a.region = ttr.region
		AND a.counterparty_type = ttr.counterparty_type
		AND a.commodity = ttr.commodity
		AND a.charge_type = ttr.charge_type
		AND a.tax_type = ttr.tax_type 
		AND a.price = ttr.price
		AND a.reseller_certificate = ttr.reseller_certificate
		AND a.energy_tax_exemption = ttr.energy_tax_exemption
		AND a.document_type = ''''b''''
		UNION ALL 
		SELECT NULL
	) b
) ttr_both
LEFT JOIN source_Deal_settlement sds 
	ON sdh.source_deal_header_id = sds.source_deal_header_id
INNER JOIN #table_cpty_tax_info ti
	ON ti.commodity = ttr.commodity
INNER JOIN #table_cpty_tax_info ti1 
	ON ti1.counterparty_id = sdh.counterparty_id 
	AND ti1.[yes_no] = ttr.reseller_certificate
	AND ti1.[value] = ''''reseller_certificate''''
	AND ti1.commodity = ttr.commodity
INNER JOIN #table_cpty_tax_info ti2 
	ON ti2.counterparty_id = sdh.counterparty_id 
	AND ti2.[yes_no] = ttr.energy_tax_exemption
	AND ti2.[value] = ''''energy_tax_exemption''''
	AND ti2.commodity = ttr.commodity
LEFT JOIN #table_tax_rules ttr_inv_rem 
	ON ttr_inv_rem.generic_mapping_values_id = ttr.generic_mapping_values_id 
	AND ttr_inv_rem.document_type = 
	CASE
		WHEN ttr_inv_rem.document_type <> ''''b'''' AND '''''' + @_price + '''''' = ''''n'''' AND  fees_negative.[value] < 0 THEN ''''r''''
		WHEN ttr_inv_rem.document_type <> ''''b'''' AND '''''' + @_price + '''''' = ''''p'''' AND  fees_positive.[value] < 0 THEN ''''r''''
		WHEN ttr_inv_rem.document_type <> ''''b'''' AND '''''' + @_price + '''''' = ''''n'''' AND  fees_negative.[value] > 0 THEN ''''i''''
		WHEN ttr_inv_rem.document_type <> ''''b'''' AND '''''' + @_price + '''''' = ''''p'''' AND  fees_positive.[value] > 0 THEN ''''i''''
	END
WHERE  ttr.charge_type = '''''' + @_charge_type + ''''''
AND ttr.tax_type = '''''' + @_tax_type + ''''''
AND ttr.price = ISNULL('''''' + @_price + '''''', ttr.price)
AND ttr.document_type = ISNULL(NULLIF(ttr_both.document_type, ''''a''''), ttr_inv_rem.document_type)
''
--exec spa_print @_sql
--exec(@_sql)
--return
----------------End Function Logic -----------------------------------------------------------------
--------------------------------------------------------------------------------------------------
-- Final Evaluation in process table
SET @_sql = @_sql + ''
	--SELECT * FROM #func_output_value
	UPDATE p SET temp_eval_value = fov.eval_value
	FROM '' + @_farrms_calc_process_table + '' p
		INNER JOIN #func_output_value fov 
			ON fov.func_rowid=p.func_rowid 
''	
EXEC spa_print @_sql
EXEC(@_sql)
level_end_function:
--Select user input parameters only
SELECT 
	@_price price,@_charge_type charge_type, @_tax_type tax_type
--[__batch_report__]
From seq WHERE n=1
', report_id = @report_id_data_source_dest,
	system_defined = '0'
	,category = '106501' 
	WHERE [name] = 'CalculateTax'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'CalculateTax'
	            AND dsc.name =  'charge_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Charge Type'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT value_id  AS id, code AS value FROM static_data_value where [type_id] = 10019 ORDER BY 2', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 1, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'charge_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'charge_type' AS [name], 'Charge Type' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT value_id  AS id, code AS value FROM static_data_value where [type_id] = 10019 ORDER BY 2' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 1 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'CalculateTax'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'CalculateTax'
	            AND dsc.name =  'tax_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Tax Type'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''v'' AS id, ''Vat'' AS value UNION ALL SELECT ''e'' AS id, ''Energy'' AS value', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 1, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'tax_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'tax_type' AS [name], 'Tax Type' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''v'' AS id, ''Vat'' AS value UNION ALL SELECT ''e'' AS id, ''Energy'' AS value' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 1 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'CalculateTax'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'CalculateTax'
	            AND dsc.name =  'price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Price'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''p'' AS id, ''Positive'' AS value UNION ALL SELECT ''n'' AS id, ''Negative'' AS value UNION ALL SELECT ''b'' AS id, ''Both'' AS value', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 1, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'price' AS [name], 'Price' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''p'' AS id, ''Positive'' AS value UNION ALL SELECT ''n'' AS id, ''Negative'' AS value UNION ALL SELECT ''b'' AS id, ''Both'' AS value' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 1 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'CalculateTax'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'CalculateTax'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	