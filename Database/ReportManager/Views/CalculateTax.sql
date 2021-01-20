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
	, [tsql] = CAST('' AS VARCHAR(MAX)) + '
--SET nocount off	
--DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), ''DEBUG_MODE_ON'')
--SET CONTEXT_INFO @contextinfo
SET nocount on

DECLARE 
		-- user variables for debug function
		@_source_deal_header_id VARCHAR(100),
		@_price VARCHAR(100),
		@_charge_type VARCHAR(100),
		@_tax_type VARCHAR(100),
		@_tax_value VARCHAR(100),

		-- system variables for evaluation function
		@_farrms_calc_process_table varchar(250), 
		@_farrms_formula_id VARCHAR(100),
		@_farrms_nested_id VARCHAR(100),
		@_farrms_level_func_sno VARCHAR(100)


/*

select
	-- variables for debug function
		@_source_deal_header_id=null ,
		@_price=''p'',
		@_charge_type=-10019,
		@_tax_type=''v'',
		@_tax_value=null,

		-- variables for evaluation function
		@_farrms_calc_process_table=''adiha_process.dbo.udf_formula_tax_DEBUG_MODE_ON_6C73503D_CF1A_4794_B4E8_469A7B8AB324'', 
		@_farrms_formula_id=209

	--alter table adiha_process.dbo.udf_formula_tax_DEBUG_MODE_ON_6C73503D_CF1A_4794_B4E8_469A7B8AB324 add	temp_eval_value varchar(10)

--*/

Declare @sql varchar(max)

SET @_source_deal_header_id = nullif(isnull(@_source_deal_header_id, nullif(''@source_deal_header_id'', replace(''@_source_deal_header_id'', ''@_'', ''@''))), ''null'')
SET @_price = nullif(isnull(@_price, nullif(''@price'', replace(''@_price'', ''@_'', ''@''))), ''null'')
SET @_charge_type = nullif(isnull(@_charge_type, nullif(''@charge_type'', replace(''@_charge_type'', ''@_'', ''@''))), ''null'')
SET @_tax_type = nullif(isnull(@_tax_type, nullif(''@tax_type'', replace(''@_tax_type'', ''@_'', ''@''))), ''null'')
SET @_tax_value = nullif(isnull(@_tax_value, nullif(''@tax_value'', replace(''@_tax_value'', ''@_'', ''@''))), ''null'')
SET @_farrms_calc_process_table = nullif(isnull(@_farrms_calc_process_table, nullif(''@farrms_calc_process_table'', replace(''@_farrms_calc_process_table'', ''@_'', ''@''))), ''null'')
SET @_farrms_formula_id = nullif(isnull(@_farrms_formula_id, nullif(''@farrms_formula_id'', replace(''@_farrms_formula_id'', ''@_'', ''@''))), ''null'')


-----------------------------------------------------------------------------------------
---- Fuction logic-------------------------------------------------------------------------

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


set @sql=
case when OBJECT_ID(''tempdb..#formula_breakdown'') IS NULL then 
	''
	select distinct source_deal_header_id,''+isnull(@_tax_value+ '' value'', ''null value'')+''
	into #formula_tax_value
	FROM ''+ @_farrms_calc_process_table +'';''

else
''
	select a.source_deal_header_id,a.[value]
	into #formula_tax_value
	from (
	SELECT distinct p.source_deal_header_id, p.udf_template_id, f.eval_value [value]
	FROM ''+ @_farrms_calc_process_table+'' p
	inner join #formula_breakdown f on p.rowid=f.source_id
		--	and f.formula_id=''+@_farrms_formula_id+''
		) a
	OUTER APPLY (
		SELECT MAX(field_name) field_name FROM user_defined_deal_fields_template uddft 
			INNER JOIN static_data_value sdv ON sdv.value_id = uddft.field_name
		WHERE udf_template_id = a.udf_template_id
	) b
	INNER JOIN static_data_value sdv ON sdv.value_id = b.field_name 
	WHERE sdv.code =  ''''Commodity Energy Tax'''' ;
	
	''
end 
+''
	update p set temp_eval_value= ''
	+	CASE WHEN @_tax_type = ''v'' THEN ''CAST(ttr.tax_percentage AS FLOAT)''
		ELSE 
			''CASE WHEN sdh.header_buy_sell_flag = ''''s'''' THEN 1 ELSE -1 END * ABS(CAST(ttr.tax_unit AS FLOAT)) ''
		END +'' * (''
		+CASE WHEN @_tax_type = ''v'' THEN 
			CASE WHEN @_price = ''n'' THEN ''fees_negative.[value]'' 
				WHEN @_price = ''p'' THEN ''fees_positive.[value]''
			ELSE 
				''ISNULL(fees_positive.[value],0) + ISNULL(fees_negative.[value], 0)'' END 
			+ ''+ISNULL(tax.value, 0)''
		ELSE 
			CASE WHEN @_price = ''n'' THEN ''abs(fees_negative.volume)''
					WHEN @_price = ''p'' THEN ''abs(fees_positive.volume)''
				ELSE ''abs(ISNULL(fees_positive.volume, 0) + ISNULL(fees_negative.volume, 0))'' END
		END +'')
	FROM ''+ @_farrms_calc_process_table+'' p
	inner join source_deal_header sdh on p.source_deal_header_id=sdh.source_deal_header_id ''+isnull('' and sdh.source_deal_header_id in (''+@_source_deal_header_id+'')'','''')+''
		and p.formula_id=''+@_farrms_formula_id+''
	left join #formula_tax_value tax on tax.source_deal_header_id=p.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	OUTER APPLY (
		SELECT MAX(cc.region) region FROM counterparty_contract_address cca 
		INNER JOIN counterparty_contacts cc
			ON cc.counterparty_id = sc.source_counterparty_id 
			AND cca.receivables = cc.counterparty_contact_id
		WHERE cca.contract_id = sdh.contract_id AND cca.counterparty_id = sdh.counterparty_id
	) r
	OUTER APPLY (
		SELECT ifbs.value FROM index_fees_breakdown_settlement ifbs
			INNER JOIN user_defined_fields_template udft 
		ON udft.field_label = ifbs.field_name AND udft.udf_category = 101902
		WHERE source_deal_header_id = p.source_deal_header_id
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
		--AND commodity_id = sdh.commodity_id
		AND effective_date<=sdh.entire_term_start 
		AND price =''''''+ @_price+''''''
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
		WHERE source_deal_header_id = p.source_deal_header_id AND sdv.code = ''''Negative Price Commodity''''  HAVING SUM(value)<>0
	) fees_negative
	OUTER APPLY (
		SELECT SUM(volume) volume, SUM(value) value 
			FROM index_fees_breakdown_settlement 
		INNER JOIN static_data_value sdv ON sdv.value_id = field_id
		WHERE source_deal_header_id = p.source_deal_header_id AND sdv.code = ''''Positive Price Commodity'''' HAVING SUM(value)<>0
	) fees_positive
	OUTER APPLY (
		SELECT MAX(b.document_type) document_type FROM (
			SELECT a.document_type FROM #table_tax_rules a  WHERE a.effective_date = ttr.effective_date
				AND a.region = ttr.region
				AND a.counterparty_type = ttr.counterparty_type
				AND a.commodity = ttr.commodity
				AND a.charge_type = ttr.charge_type
				AND a.tax_type = ttr.tax_type 
				AND a.price = ttr.price
				AND a.reseller_certificate = ttr.reseller_certificate
				AND a.energy_tax_exemption = ttr.energy_tax_exemption
				AND a.document_type = ''''b''''
		) b
	) ttr_both
	INNER JOIN #table_cpty_tax_info ti ON ti.commodity = ttr.commodity
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
			WHEN ttr_inv_rem.document_type <> ''''b'''' AND CAST(ttr_inv_rem.tax_percentage AS FLOAT) < 0 THEN ''''r''''
			WHEN ttr_inv_rem.document_type <> ''''b'''' AND CAST(ttr_inv_rem.tax_percentage AS FLOAT) > 0 THEN ''''i'''' 
		END
	WHERE  ttr.charge_type =''''''+ @_charge_type+''''''
	AND ttr.tax_type =''''''+ @_tax_type+''''''''+
	case when @_price is not null then '' AND ttr.price = ttr.price'' else '''' end +''
		AND ttr.document_type = ISNULL(NULLIF(ttr_both.document_type, ''''a''''), ttr_inv_rem.document_type)
	''



	--exec spa_print @sql
	exec(@sql)


---- Fuction logic----------------------------------------------------------
-------------------------------------------------------------------------------------------

if OBJECT_ID(''tempdb..#formula_breakdown'') IS NULL  
select 
		@_source_deal_header_id source_deal_header_id,
		@_price price,
		@_charge_type harge_type,
		@_tax_type tax_type,
		@_tax_value tax_value
--[__batch_report__]


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
	            AND dsc.name =  'hour'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hour'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'hour'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'hour' AS [name], 'Hour' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
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
	            AND dsc.name =  'mins'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Mins'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'mins'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'mins' AS [name], 'Mins' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
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
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'CalculateTax'
	            AND dsc.name =  'prod_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Prod Date'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'prod_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'prod_date' AS [name], 'Prod Date' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
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
	            AND dsc.name =  'prod_date_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Prod Date To'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'prod_date_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'prod_date_to' AS [name], 'Prod Date To' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
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
	            AND dsc.name =  'value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Value'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'value' AS [name], 'Value' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
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
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
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
	            AND dsc.name =  'contract_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'contract_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_id' AS [name], 'Contract ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
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
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'Counterparty ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
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
	            AND dsc.name =  'source_deal_detail_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Source Deal Detail Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'CalculateTax'
			AND dsc.name =  'source_deal_detail_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_detail_id' AS [name], 'Source Deal Detail Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
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
