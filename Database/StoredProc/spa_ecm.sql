IF OBJECT_ID (N'[dbo].[spa_ecm]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_ecm]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Used for ecm reporting

	Parameters
	@flag	                   :  Flag
								 - 'i' Insert data
								 -  'r' Capture feedback for ECM and remit
    @create_date_from		   : Create Date From
    @create_date_to			   : Create Date To
    @process_id				   : Process ID
    @include_bfi			   : Include BFI
    @filter_table_process_id   : Filter Table Process ID
*/

CREATE PROC [dbo].[spa_ecm]
	@flag CHAR(1) = NULL,
	@create_date_from VARCHAR(100) = NULL,
	@create_date_to VARCHAR(100) = NULL,
	@process_id VARCHAR(MAX) = NULL,
	@include_bfi BIT = NULL,
	@filter_table_process_id VARCHAR(1000) = NULL,
	@file_transfer_endpoint_name NVARCHAR(2000) = NULL
AS

/*------------------Debug Section------------------
DECLARE @flag CHAR(1) = NULL,
		@create_date_from VARCHAR(100) = NULL,
		@create_date_to VARCHAR(100) = NULL,
		@process_id VARCHAR(MAX) = NULL,
		@include_bfi BIT = NULL,
		@filter_table_process_id VARCHAR(1000) = NULL,
		@file_transfer_endpoint_name NVARCHAR(2000) = NULL


SELECT @flag = 'r', @file_transfer_endpoint_name = 'ECM Feedback'
-------------------------------------------------*/
SET NOCOUNT ON
DECLARE @create_ts DATETIME = GETDATE()

IF @create_date_from IS NULL
BEGIN
    SET @create_date_from = CONVERT(VARCHAR(10), DATEADD(MONTH, -1, @create_ts), 120)
END

IF @create_date_to IS NULL
BEGIN
    SET @create_date_to = CONVERT(VARCHAR(10), @create_ts, 120)
END

DECLARE @ssbm_table_name VARCHAR(120),
		@deal_header_table_name VARCHAR(120),
		@deal_detail_table_name VARCHAR(120),
		@show_data INT = 0,
		@xml XML,
		@sql2 VARCHAR(MAX),
		@_sql VARCHAR(MAX),
		@output_result NVARCHAR(MAX),
	    @download_files NVARCHAR(MAX),
	    @xml_file_content VARCHAR(MAX),
	    @remote_location NVARCHAR(2000),
	    @server_location NVARCHAR(1000),
	    @file_transfer_endpoint_id INT,
        @user_name VARCHAR(50),
	    @desc_success VARCHAR(MAX),
	    @url VARCHAR(MAX),
	    @process_table VARCHAR(200),
	    @full_file_path VARCHAR(200),
	    @file_name VARCHAR(200),
	    @email_description VARCHAR(MAX),
		@success_files VARCHAR(MAX) = '',
		@error_files VARCHAR(MAX) = ''

SET @ssbm_table_name = dbo.FNAProcessTableName('ssbm', dbo.FNADBUser(), @filter_table_process_id)
SET @deal_header_table_name = dbo.FNAProcessTableName('deal_header', dbo.FNADBUser(), @filter_table_process_id)
SET @deal_detail_table_name = dbo.FNAProcessTableName('deal_detail', dbo.FNADBUser(), @filter_table_process_id)

IF @flag = 'i'
BEGIN
	DECLARE @_cpty_udf_cpty_id VARCHAR(100) = 'Counterparty ID',
			@_cpty_udf_source_code VARCHAR(100) = 'Source Code',
			@err_msg VARCHAR(200) = ''
	
	IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL
		DROP TABLE #temp_deals

	CREATE TABLE #temp_deals (
		source_deal_header_id INT,
		deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		template_id INT,
		counterparty_id INT,
		sub_book_id INT,
		deal_date DATETIME,
		physical_financial_flag CHAR(10) COLLATE DATABASE_DEFAULT,
		entire_term_start DATETIME,
		entire_term_end DATETIME,
		source_deal_type_id INT,
		deal_sub_type_type_id INT,
		option_flag CHAR(1) COLLATE DATABASE_DEFAULT,
		option_type CHAR(1) COLLATE DATABASE_DEFAULT,
		option_excercise_type CHAR(1) COLLATE DATABASE_DEFAULT,
		header_buy_sell_flag VARCHAR(1) COLLATE DATABASE_DEFAULT,
		create_ts DATETIME,
		update_ts DATETIME,
		internal_desk_id INT,
		product_id INT,
		commodity_id INT,
		block_define_id INT,
		deal_status INT,
		description1 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		description2 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		source_trader_id INT,
		contract_id INT,
		deal_group_id INT,
		ext_deal_id VARCHAR(512) COLLATE DATABASE_DEFAULT,
		confirm_status VARCHAR(512) COLLATE DATABASE_DEFAULT,
		[commodity_name] VARCHAR(1000) COLLATE DATABASE_DEFAULT
	)

	SET @_sql = '
		INSERT INTO #temp_deals
		SELECT * FROM ' + @deal_header_table_name + '
	'

	EXEC(@_sql)
  	

	IF OBJECT_ID('tempdb..#temp_cpty_udf_values') IS NOT NULL
		DROP TABLE #temp_cpty_udf_values
	 CREATE TABLE #temp_cpty_udf_values (
        source_deal_header_id INT,
        [Deal EIC] NVARCHAR(500) COLLATE DATABASE_DEFAULT,
        [Sub EIC] NVARCHAR(500) COLLATE DATABASE_DEFAULT,
		[Broker EIC] NVARCHAR(500) COLLATE DATABASE_DEFAULT
    )
	
	DECLARE @_pivot_header VARCHAR(1000) = '[Deal EIC], [Sub EIC], [Broker EIC]'
	SET @_sql = ' INSERT INTO #temp_cpty_udf_values (
			source_deal_header_id, [Deal EIC], [Sub EIC], [Broker EIC]
		)
	
	SELECT source_deal_header_id, [Deal EIC], [Sub EIC], [Broker EIC]
		 FROM (
			SELECT cpty.source_deal_header_id,
					CASE cpty.cpty_type WHEN 1 THEN ''Sub ''
										WHEN 2 THEN ''Deal ''
										WHEN 3 THEN ''Broker ''
										ELSE ''''
										END + ISNULL(udft.field_label, '''') field_label,
					NULLIF(musddv.static_data_udf_values, ''NULL'') udf_values
			FROM (
						SELECT td.source_deal_header_id,
								fs.counterparty_id,
								1 cpty_type
						FROM #temp_deals td
						INNER JOIN ' + @ssbm_table_name + ' book ON td.sub_book_id = book.sub_book_id
						INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = book.sub_id
						UNION
						SELECT td.source_deal_header_id, td.counterparty_id, 2 cpty_type
						FROM #temp_deals td
						UNION
						SELECT td.source_deal_header_id, sdh.broker_id, 3 cpty_type
						FROM #temp_deals td
						INNER JOIN source_deal_header sdh
							ON sdh.source_deal_header_id = td.source_deal_header_id
					) cpty
			INNER JOIN maintain_udf_static_data_detail_values musddv
				ON musddv.primary_field_object_id = cpty.counterparty_id
			INNER JOIN application_ui_template_fields autf
				ON autf.application_field_id = musddv.application_field_id
			INNER JOIN user_defined_fields_template udft
				ON udft.udf_template_id = autf.udf_template_id
			) AS a
		PIVOT(MAX(udf_values) FOR a.Field_label IN (' + @_pivot_header + ')) AS P
		'
	EXEC(@_sql)

	DECLARE @udf_broker_fee INT

	SELECT @udf_broker_fee = value_id
	FROM static_data_value
	WHERE [type_id] = 5500
		AND code = 'Broker Fee'	

    IF OBJECT_ID('tempdb..#temp_deal_details') IS NOT NULL
		DROP TABLE #temp_deal_details
	
	CREATE TABLE #temp_deal_details (
		[source_deal_header_id] INT NULL,
		[source_deal_detail_id] INT NULL,
		[term_start] DATETIME NOT NULL,
		[term_end] DATETIME NOT NULL,
		[leg] INT NOT NULL,
		[fixed_float_leg] CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,
		[buy_sell_flag] CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,
		[curve_id] INT NULL,
		[location_id] INT NULL,
		[physical_financial_flag] CHAR(1) COLLATE DATABASE_DEFAULT NULL,
		[deal_volume] NUMERIC(38, 20) NULL,
		[total_volume] NUMERIC(38, 20) NULL,
		[standard_yearly_volume] NUMERIC(22, 8) NULL,
		[deal_volume_frequency] CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,
		[deal_volume_uom_id] INT NOT NULL,
		[multiplier] NUMERIC(38, 20) NULL,
		[volume_multiplier2] NUMERIC(38, 20) NULL,
		[fixed_price] NUMERIC(38, 20) NULL,
		[fixed_price_currency_id] INT NULL,
		[option_strike_price] NUMERIC(38, 20) NULL,
		[fixed_cost] NUMERIC(38, 20) NULL,
		[formula_id] INT NULL,
		[formula_curve_id] INT NULL,
		[price_adder] NUMERIC(38, 20) NULL,
		[price_multiplier] NUMERIC(38, 20) NULL,
		[adder_currency_id] INT NULL,
		[fixed_cost_currency_id] INT NULL,
		[formula_currency_id] INT NULL,
		[price_adder2] NUMERIC(38, 20) NULL,
		[price_adder_currency2] INT NULL,
		[price_uom_id] INT NULL,
		[contract_expiration_date] DATETIME,
		position_uom INT NULL
	)

	EXEC ('
		INSERT INTO #temp_deal_details
		SELECT * FROM ' + @deal_detail_table_name + '
	')

    IF @process_id IS NULL
        SET @process_id = LOWER(NEWID())

	DECLARE @document_usage NVARCHAR(100)
	SELECT @document_usage = gmv.clm1_value
	FROM generic_mapping_header gmh
	INNER JOIN generic_mapping_values gmv
		ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE gmh.mapping_name = 'Document Usage'
	
	IF OBJECT_ID('tempdb..#temp_ecm') IS NOT NULL
		DROP TABLE #temp_ecm

    SELECT DISTINCT
		   td.source_deal_header_id source_deal_header_id,
		   td.deal_id deal_id,
		   MAX(td.sub_book_id) sub_book_id,
		   MAX(td.physical_financial_flag) physical_financial_flag,
		   'CNF_' + CONVERT(VARCHAR(10), MAX(td.deal_date), 112) + '_' + REPLICATE('0', 10 - LEN(RTRIM(td.source_deal_header_id))) + RTRIM(td.source_deal_header_id) + '@' + MAX(tcuv.[Sub EIC]) document_id,
		   ISNULL(@document_usage, 'Test') document_usage,
		    IIF(MAX(ssr.rule_id) IS NOT NULL,MAX(tcuv.[Sub EIC]),MAX(tcuv.[Broker EIC])) sender_id,
		    MAX(tcuv.[Deal EIC]) receiver_id,
		   IIF(MAX(ssr.rule_id) IS NOT NULL,'Trader','Broker') receiver_role,
		   CASE WHEN MAX(ecm.document_version) IS NULL THEN ROW_NUMBER() OVER(PARTITION BY td.deal_id ORDER BY td.deal_id, MAX(ecm.ecm_document_type))
				ELSE MAX(ecm.document_version) + 1
		   END  document_version,
		   MAX(sdv_cntry.code) market,
		   MAX(scom.commodity_id) commodity,
		   'FOR' transaction_type,
		   MAX(tbl_delivery_point_area.delivery_point_area) delivery_point_area,
		   CASE 
				WHEN MAX(td.header_buy_sell_flag) = 'b' THEN MAX(tcuv.[Sub EIC])
				ELSE MAX(tcuv.[Deal EIC])
		   END [buyer_party],
		   CASE
				WHEN MAX(td.header_buy_sell_flag) = 'b' THEN MAX(tcuv.[Deal EIC])
				ELSE MAX(tcuv.[Sub EIC])
		   END [seller_party],
		   CASE	
				WHEN MAX(scom.commodity_id) = 'Gas' THEN 'Base'
				WHEN MAX(scom.commodity_id) = 'Power' THEN 'Custom'
		   END [load_type],
		   'EFET' [agreement],
		   MAX(CASE scur_fixed.currency_name WHEN 'Euro' THEN 'EUR'
		                                     WHEN 'Ect' THEN 'EUX'
											 WHEN 'GPC' THEN 'GBX'
											 ELSE UPPER(scur_fixed.currency_name)
			   END
		   ) [currency],
		   CASE 
				WHEN MAX(td.physical_financial_flag) = 'p' THEN SUM(tdd.total_volume) 
				ELSE ROUND(SUM(tdd.total_volume),2) 
		   END * MAX(ISNULL(conv.conversion_factor, 1 )) [total_volume],
		   CASE 
				WHEN MAX(tsu.uom_name)='mwh' THEN 'MWh'
				WHEN MAX(tsu.uom_name)='kwh' THEN 'KWh'
				WHEN MAX(tsu.uom_name)='gwh' THEN 'GWh'
				WHEN MAX(tsu.uom_name)='therm' THEN 'Therm'
				WHEN MAX(tsu.uom_name)='mmbtu' THEN 'MMBtu'
				WHEN MAX(tsu.uom_name)='gj' THEN 'GJ'
				WHEN MAX(tsu.uom_name)='m3' THEN 'cm'
				WHEN MAX(tsu.uom_name)='m3/hr' THEN 'cm'
				WHEN MAX(tsu.uom_name)='m3(n,35.17)' THEN 'cm'
				WHEN MAX(tsu.uom_name)='Metric Tons' THEN 'cm'
				WHEN MAX(tsu.uom_name)='MT' THEN 'cm'
				WHEN MAX(tsu.uom_name)='mw' THEN 'MWh'
				ELSE NULL
		   END [total_volume_unit],
		   CONVERT(VARCHAR(10), MAX(td.deal_date), 120) [trade_date],
		   CASE
				WHEN MAX(tsu.uom_name)='mwh' THEN 'MWh'
			    WHEN MAX(tsu.uom_name)='kwh' THEN 'KWh'
			    WHEN MAX(tsu.uom_name)='gwh' THEN 'GWh'
			    WHEN MAX(tsu.uom_name)='therm' THEN 'Therm'
			    WHEN MAX(tsu.uom_name)='mmbtu' THEN 'MMBtu'
			    WHEN MAX(tsu.uom_name)='gj' THEN 'GJ'
			    WHEN MAX(tsu.uom_name)='m3' THEN 'cm'
			    WHEN MAX(tsu.uom_name)='m3/hr' THEN 'cm'
			    WHEN MAX(tsu.uom_name)='m3(n,35.17)' THEN 'cm'
			    WHEN MAX(tsu.uom_name)='Metric Tons' THEN 'cm'
			    WHEN MAX(tsu.uom_name)='MT' THEN 'cm'
			    WHEN MAX(tsu.uom_name)='mw' THEN 'MWh'
				ELSE NULL
		   END [capacity_unit],
		   MAX(CASE scur_fixed.currency_name WHEN 'Euro' THEN 'EUR'
											 WHEN 'Ect' THEN 'EUX'
											 WHEN 'GPC' THEN 'GBX'
											 ELSE UPPER(scur_fixed.currency_name)
			   END
		   ) [price_unit_currency],
		   CASE WHEN MAX(tsu.uom_name)='mwh' THEN 'MWh'
			    WHEN MAX(tsu.uom_name)='kwh' THEN 'KWh'
				WHEN MAX(tsu.uom_name)='gwh' THEN 'GWh'
				WHEN MAX(tsu.uom_name)='therm' THEN 'Therm'
				WHEN MAX(tsu.uom_name)='mmbtu' THEN 'MMBtu'
				WHEN MAX(tsu.uom_name)='gj' THEN 'GJ'
				WHEN MAX(tsu.uom_name)='m3' THEN 'cm'
				WHEN MAX(tsu.uom_name)='m3/hr' THEN 'cm'
				WHEN MAX(tsu.uom_name)='m3(n,35.17)' THEN 'cm'
				WHEN MAX(tsu.uom_name)='Metric Tons' THEN 'cm'
				WHEN MAX(tsu.uom_name)='MT' THEN 'cm'
				WHEN MAX(tsu.uom_name)='mw' THEN 'MWh'
				ELSE NULL
		   END [price_unit_capacity_unit],
		   ABS(SUM(tdd.total_volume * ISNULL(conv.conversion_factor, 1) * (tdd.fixed_price + ISNULL(ABS(CAST(uddf.udf_value AS FLOAT)), 0)) )) * CASE WHEN MAX(sdht.template_name) LIKE '%Zeebrugge%' THEN 100 ELSE 1 END [total_contract_value],
		   CASE 
				WHEN MAX(scom.commodity_id) = 'Gas' THEN CONVERT(VARCHAR(19), DATEADD(hh, CASE WHEN ISNULL(MAX(sdv_block.value_id),-10000298) = -10000298 THEN 6
																							   ELSE ISNULL(TRY_CAST(MAX(tbl_ecm_time_interval.start_hour) AS INT), 0)
																						  END
														, CASE WHEN MAX(tbl_ecm_time_interval.business_day) = 'y'  AND DATEPART(dw, MAX(td.entire_term_start)) IN (1,7)
																	THEN CAST(dbo.FNAGetBusinessDay('n', CAST(MAX(td.entire_term_start) AS DATETIME),NULL) AS DATETIME)			     
																		 + CASE WHEN MAX(sdv_block.code) IN ('WD 00-06','WD 01-06','WD 02-06'
																															,'WD 03-06','WD 04-06','WD 05-06','00-01'
																															,'01-02','02-03','03-04','04-05','05-06') THEN 1
																											   ELSE 0 
																										  END
														       ELSE CAST(MAX(td.entire_term_start) AS DATETIME) 
																    + CASE WHEN MAX(sdv_block.code) IN ('WD 00-06','WD 01-06','WD 02-06','WD 03-06','WD 04-06'
																				,'WD 05-06','00-01','01-02','02-03','03-04','04-05','05-06') THEN 1
																		   ELSE 0 
																	  END
														  END		
														)
														
														, 126)
				ELSE CONVERT(VARCHAR(19), DATEADD(hh, CASE WHEN ISNULL(MAX(sdv_block.value_id),-10000298) = -10000298 THEN 0
															ELSE ISNULL(TRY_CAST(MAX(tbl_ecm_time_interval.start_hour) AS INT), 0)
													  END
										  ,CASE WHEN MAX(tbl_ecm_time_interval.business_day) = 'y' AND DATEPART(dw, MAX(td.entire_term_start)) IN (1,7)  THEN dbo.FNAGetBusinessDay('n', CAST(MAX(td.entire_term_start) AS DATETIME),NULL) 
												ELSE CAST(MAX(td.entire_term_start) AS DATETIME)
										   END

					 ), 126)
		   END [delivery_start],
		   CASE WHEN MAX(scom.commodity_id) = 'Gas' THEN CONVERT(VARCHAR(19), DATEADD(hh, CASE WHEN ISNULL(MAX(sdv_block.value_id),-10000298) = -10000298 THEN 6
																							   ELSE ISNULL(TRY_CAST(MAX(tbl_ecm_time_interval.end_hour) AS INT), 0)
																						  END
														,  CASE WHEN MAX(tbl_ecm_time_interval.business_day) = 'y' AND DATEPART(dw, MAX(td.entire_term_end)) IN (1,7) 
																	 THEN CAST(dbo.FNAGetBusinessDay('p', CAST(MAX(td.entire_term_end) AS DATETIME),NULL) AS DATETIME)
																		+ CASE WHEN ISNULL(MAX(sdv_block.value_id), -10000298) = -10000298 THEN 1 
																										 WHEN MAX(sdv_block.code) IN ('00-01','01-02','02-03','03-04'
																															 ,'04-05','05-06') THEN 1
																										 WHEN MAX(sdv_block.code) LIKE '%WD %' THEN 1
																										 ELSE 0 
																									END
																 ELSE CAST(MAX(td.entire_term_end) AS DATETIME) 
																	  + CASE WHEN ISNULL(MAX(sdv_block.value_id), -10000298) = -10000298 THEN 1 
																			 WHEN MAX(sdv_block.code) IN ('00-01','01-02','02-03','03-04','04-05','05-06') THEN 1
																			 WHEN MAX(sdv_block.code) LIKE '%WD %' THEN 1
																			 ELSE 0 
																		END
														   END

														)
													, 126) 
														
													
			    ELSE CONVERT(VARCHAR(19),  DATEADD(hh, CASE WHEN ISNULL(MAX(sdv_block.value_id),-10000298) = -10000298 THEN 0
															ELSE ISNULL(TRY_CAST(MAX(tbl_ecm_time_interval.end_hour) AS INT), 0)
														END
										  , CASE WHEN MAX(tbl_ecm_time_interval.business_day) = 'y'  AND DATEPART(dw, MAX(td.entire_term_end)) IN (1,7)
													  THEN CAST(dbo.FNAGetBusinessDay('p', CAST(MAX(td.entire_term_end) AS DATETIME) ,NULL) AS DATETIME)
																					+ CASE WHEN ISNULL(TRY_CAST(MAX(tbl_ecm_time_interval.end_hour) AS INT), 0) = 0 THEN 1
																							ELSE 0
																					  END 													 
												 ELSE CAST(MAX(td.entire_term_end) AS DATETIME)
													+ CASE WHEN ISNULL(TRY_CAST(MAX(tbl_ecm_time_interval.end_hour) AS INT), 0) = 0 THEN 1
															ELSE 0
														END 
											END  

										  ) 
										 , 126) 
			 END [delivery_end],
		   MAX(tdd.deal_volume) [contract_capacity],
		   (AVG(tdd.fixed_price) + ISNULL(MAX(ABS(CAST(uddf.udf_value AS FLOAT))), 0)) * CASE WHEN MAX(sdht.template_name) LIKE '%Zeebrugge%' THEN 100 ELSE 1 END [price],
		   CASE WHEN MAX(scom.commodity_id) IN ('ELectricity', 'Power') THEN NULL
			    WHEN MAX(scom.commodity_id) = 'Gas' THEN CASE 
														WHEN MAX(td.header_buy_sell_flag) = 'b' THEN MAX(tbl_ecm_hub.[Hub])
														ELSE MAX(tbl_ecm_hub_counterparty.[hub])
													END
		   END [buyer_hubcode],
		   CASE WHEN MAX(scom.commodity_id) IN ('ELectricity', 'Power') THEN NULL
			    WHEN MAX(scom.commodity_id) = 'Gas' THEN CASE 
														WHEN MAX(td.header_buy_sell_flag) = 's' THEN MAX(tbl_ecm_hub.[Hub])
														ELSE MAX(tbl_ecm_hub_counterparty.[hub])
													END
		   END [seller_hubcode],
		   ISNULL(MAX(st.trader_name), '') [trader_name],
		   'CNF' ecm_document_type,
		   NULL [report_type],
		   @create_date_from [create_date_from],
		   @create_date_to [create_date_to],
		   @create_ts [create_ts],
		   39500 [submission_status],
		   NULL [submission_date],
		   NULL [confirmation_date],
		   @process_id [process_id],
		   NULL [error_validation_message],
		   NULL [file_export_name],
		   CASE WHEN MAX(ssr.rule_id) IS  NULL THEN CAST(CASE MAX(sdv_r.code) WHEN 'PTTA' THEN 0
										WHEN 'PTTP' THEN 0
										ELSE 0 END AS FLOAT)
		   ELSE NULL
		   END  broker_fee
	INTO #temp_ecm
	FROM #temp_deals td
	INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = td.source_deal_header_id
	INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id = tdd.source_deal_header_id
	LEFT JOIN setup_submission_rule ssr
		ON ssr.counterparty_id = td.counterparty_id
		AND ISNULL(ssr.commodity_id,td.commodity_id) = td.commodity_id
		AND ssr.submission_type_id = 44705
	LEFT JOIN #temp_cpty_udf_values tcuv 
		ON tcuv.source_deal_header_id = td.source_deal_header_id
	OUTER APPLY(
		SELECT TOP 1 cs.[type]
		FROM confirm_status cs
		WHERE cs.source_deal_header_id = td.source_deal_header_id
		ORDER BY cs.confirm_status_id DESC
	) cs
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = td.template_id
	LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = td.template_id
		AND uddft.field_id = @udf_broker_fee
	LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = td.source_deal_header_id
		AND uddf.udf_template_id = uddft.udf_template_id
	LEFT JOIN source_traders st ON st.source_trader_id = td.source_trader_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tdd.curve_id
	LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)
		AND conv.to_source_uom_id = tdd.deal_volume_uom_id
	LEFT JOIN source_commodity scom ON scom.source_commodity_id = ISNULL(spcd.commodity_id, td.commodity_id)
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = tdd.location_id
	LEFT JOIN static_data_value sdv_cntry ON sdv_cntry.type_id = 14000
		AND sdv_cntry.value_id = sml.country
	OUTER APPLY(
		SELECT TOP 1 
			   ecm.ecm_document_type,
			   ecm.document_version
		FROM source_ecm ecm
		WHERE ecm.source_deal_header_id = td.source_deal_header_id
			AND ecm.ecm_document_type = 'CNF'
		ORDER BY ecm.document_version DESC
	) ecm
	LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = td.deal_status
	LEFT JOIN source_uom tsu ON tdd.deal_volume_uom_id = tsu.source_uom_id
	LEFT JOIN source_currency scur_fixed ON scur_fixed.source_currency_id = tdd.fixed_price_currency_id
	LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = td.block_define_id
	LEFT JOIN source_deal_type sd_type ON sd_type.source_deal_type_id = td.source_deal_type_id
		AND sd_type.sub_type = 'n'
	LEFT JOIN static_data_value sdv_r
			ON sdv_r.value_id = sdh.reporting_group1
			AND sdv_r.type_id = 113000
	OUTER APPLY( SELECT gmv.clm3_value delivery_point_area
				 FROM generic_mapping_header gmh
				 INNER JOIN generic_mapping_values gmv
					ON gmv.mapping_table_id = gmh.mapping_table_id
				 WHERE gmh.mapping_name = 'ECM /Remit Delivery Point'
				 AND gmv.clm1_value = CAST(tdd.location_id AS VARCHAR(20))
				 AND gmv.clm2_value = CAST(scom.source_commodity_id AS VARCHAR(20))
	) tbl_delivery_point_area
	OUTER APPLY( SELECT gmv.clm4_value [hub]
				 FROM generic_mapping_header gmh
				 INNER JOIN generic_mapping_values gmv
					ON gmv.mapping_table_id = gmh.mapping_table_id
				 WHERE gmh.mapping_name = 'ECM HUB Mapping'
				 AND ISNULL(gmv.clm1_value,'-1') = CASE WHEN scom.commodity_id = 'Power' THEN ISNULL(gmv.clm1_value,'-1') ELSE tcuv.[Sub EIC]  END
				 AND gmv.clm2_value = CAST(tdd.location_id AS VARCHAR(20))
				 AND gmv.clm3_value = CAST(scom.source_commodity_id AS VARCHAR(20))
	) tbl_ecm_hub 
	OUTER APPLY( SELECT gmv.clm4_value [hub]
				 FROM generic_mapping_header gmh
				 INNER JOIN generic_mapping_values gmv
					ON gmv.mapping_table_id = gmh.mapping_table_id
				 WHERE gmh.mapping_name = 'ECM HUB Mapping'
				 AND gmv.clm1_value = tcuv.[Deal EIC]
				 AND gmv.clm2_value = CAST(tdd.location_id AS VARCHAR(20))
				 AND gmv.clm3_value = CAST(scom.source_commodity_id AS VARCHAR(20))
	) tbl_ecm_hub_counterparty 
	OUTER APPLY( SELECT gmv.clm2_value [start_hour], gmv.clm3_value [end_hour], ISNULL(gmv.clm4_value, 'n') [business_day]
				 FROM generic_mapping_header gmh
				 INNER JOIN generic_mapping_values gmv
					ON gmv.mapping_table_id = gmh.mapping_table_id
				 WHERE gmh.mapping_name = 'ECM Time Interval'
				 AND gmv.clm1_value = CAST(td.block_define_id AS VARCHAR(20))
	) tbl_ecm_time_interval
	WHERE td.deal_status <> 5607
		AND ISNULL(cs.[type], 17200) <> 17202
	GROUP BY  td.source_deal_header_id, td.deal_id

	IF OBJECT_ID('tempdb..#collect_deals') IS NOT NULL
		DROP TABLE #collect_deals
	
	CREATE TABLE #collect_deals (
		source_deal_header_id INT,
		allow_insert BIT
	)
	
	INSERT INTO #collect_deals(source_deal_header_id, allow_insert)
	SELECT sdh.source_deal_header_id,
		   CASE WHEN MAX(erl.[state]) = 'MATCHED' THEN 0 ELSE 1 END
	FROM #temp_deals sdh
	OUTER APPLY(
		SELECT TOP 1
			   s.source_deal_header_id,
			   s.document_id,
			   s.acer_submission_status
		FROM source_ecm s
		WHERE s.source_deal_header_id = sdh.source_deal_header_id
		ORDER BY create_ts DESC
	) src_ecm
	OUTER APPLY(
		SELECT TOP 1
			   s.document_id,
			   s.[state]
		FROM ecm_response_log s
		WHERE s.document_id = src_ecm.document_id
		ORDER BY create_ts DESC
	) erl
	WHERE sdh.deal_status <> 5607
	GROUP BY sdh.source_deal_header_id
 
	IF EXISTS (SELECT 1 FROM #collect_deals WHERE allow_insert = 0)
	BEGIN
		UPDATE c
		SET c.allow_insert = CASE WHEN cur.sender_id = pre.sender_id AND cur.receiver_id = pre.receiver_id AND cur.market = pre.market AND cur.commodity = pre.commodity AND cur.transaction_type = pre.transaction_type AND cur.delivery_point_area = pre.delivery_point_area AND cur.buyer_party = pre.buyer_party AND cur.seller_party = pre.seller_party AND cur.load_type = pre.load_type AND cur.agreement = pre.agreement AND cur.currency = pre.currency AND cur.total_volume = pre.total_volume AND cur.total_volume_unit = pre.total_volume_unit AND CAST(cur.trade_date AS DATE) = CAST(pre.trade_date AS DATE) AND cur.capacity_unit = pre.capacity_unit AND cur.price_unit_currency = pre.price_unit_currency AND CAST(cur.delivery_start AS DATETIME) = CAST(pre.delivery_start AS DATETIME) AND CAST(cur.delivery_end AS DATETIME) = CAST(pre.delivery_end AS DATETIME) AND CAST(cur.contract_capacity AS FLOAT) = CAST(pre.contract_capacity AS FLOAT) AND cur.price = pre.price AND ISNULL(cur.buyer_hubcode, '-1') = ISNULL(pre.buyer_hubcode, '-1') AND ISNULL(cur.seller_hubcode, '-1') = ISNULL(pre.seller_hubcode , '-1') THEN 0 ELSE 1 END
		FROM #collect_deals c
		CROSS APPLY (
			SELECT TOP 1 *
			FROM source_ecm s
			WHERE s.source_deal_header_id = c.source_deal_header_id
			ORDER BY create_ts DESC
		) pre
		INNER JOIN #temp_ecm cur ON cur.source_deal_header_id = pre.source_deal_header_id
		WHERE c.allow_insert = 0
	END

	IF EXISTS (SELECT 1 FROM #collect_deals WHERE allow_insert = 0) AND
	   NOT EXISTS (SELECT 1 FROM #collect_deals WHERE allow_insert = 1)
	BEGIN
		SET @err_msg = 'Selected deal(s) are already Matched.'
		
		EXEC spa_ErrorHandler -1, 'Source Remit table', 'spa_ecm', 'Error', @err_msg, 'Error' 
		RETURN
	END

	INSERT INTO #collect_deals(source_deal_header_id, allow_insert)
	SELECT DISTINCT c.source_deal_header_id, 1
	FROM #collect_deals c
	LEFT JOIN source_ecm ecm ON ecm.source_deal_header_id = c.source_deal_header_id
	LEFT JOIN ecm_response_log erl ON erl.document_id = ecm.document_id
		AND erl.[state] <> 'MATCHED'
	WHERE erl.id IS NULL

	IF EXISTS (SELECT 1 FROM #collect_deals WHERE allow_insert = 0) AND
	   EXISTS (SELECT 1 FROM #collect_deals WHERE allow_insert = 1)
	BEGIN
		SET @err_msg = 'Few deal(s) are already submitted. Only remaining deals will be submitted.'
		EXEC spa_ErrorHandler -1,'Source ECM table', 'spa_ecm', 'Error', @err_msg, 'Error'                
	END
	
	DELETE td
	FROM #temp_deals td
	INNER JOIN #collect_deals csd ON td.source_deal_header_id = csd.source_deal_header_id
	WHERE allow_insert = 0
		AND td.deal_status <> 5607
	
	DELETE te
	FROM #temp_ecm te
	LEFT JOIN #temp_deals td ON td.source_deal_header_id = te.source_deal_header_id
	WHERE td.source_deal_header_id IS NULL
     
    BEGIN TRY
		BEGIN TRANSACTION

		IF OBJECT_ID ('tempdb..#temp_messages') IS NOT NULL
			DROP TABLE #temp_messages

		CREATE TABLE #temp_messages (
        	source_deal_header_id INT,
        	[column] VARCHAR(100) COLLATE DATABASE_DEFAULT,
        	[messages] VARCHAR(5000) COLLATE DATABASE_DEFAULT
        )
		
		INSERT INTO [source_ecm] (
			[source_deal_header_id], [deal_id], [sub_book_id], [physical_financial_flag], [document_id], [document_usage], [sender_id],
			[receiver_id], [receiver_role], [document_version], [market], [commodity], [transaction_type], [delivery_point_area], [buyer_party],
			[seller_party], [load_type], [agreement], [currency], [total_volume], [total_volume_unit], [trade_date], [capacity_unit],
			[price_unit_currency], [price_unit_capacity_unit], [total_contract_value], [delivery_start], [delivery_end], [contract_capacity],
			[price], [buyer_hubcode], [seller_hubcode], [trader_name], [ecm_document_type], [report_type], [create_date_from], [create_date_to],
			[create_ts], [acer_submission_status], [acer_submission_date], [acer_confirmation_date], [process_id], [error_validation_message], [file_export_name], [broker_fee]
		)
		SELECT [source_deal_header_id], [deal_id], [sub_book_id], [physical_financial_flag], [document_id], [document_usage], [sender_id], [receiver_id],
			   [receiver_role], [document_version], [market], [commodity], [transaction_type], [delivery_point_area], [buyer_party], [seller_party],
			   [load_type], [agreement], [currency], [total_volume], [total_volume_unit], [trade_date], [capacity_unit], [price_unit_currency],
			   [price_unit_capacity_unit], [total_contract_value], [delivery_start], [delivery_end], [contract_capacity], [price], [buyer_hubcode],
			   [seller_hubcode], [trader_name], [ecm_document_type], [report_type], [create_date_from], [create_date_to], [create_ts], [submission_status],
			   [submission_date], [confirmation_date], [process_id], [error_validation_message], [file_export_name], [broker_fee]
		FROM #temp_ecm

		IF OBJECT_ID('tempdb..#not_null') IS NOT NULL
			DROP TABLE #not_null

		CREATE TABLE #not_null (
			column_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
			msg VARCHAR(1000) COLLATE DATABASE_DEFAULT
		)
				
		INSERT INTO #not_null(column_name, msg) 
		VALUES ('document_id', 'document ID Must not be NULL'),
			   ('document_version', 'document version Must not be NULL'),
			   ('buyer_party', 'buyer party must not be NULL'),
			   ('seller_party', 'seller party must not be NULL'),
			   ('currency', 'Currency must not be NULL'),
			   ('total_volume', 'total volume must not be NULL'),
			   ('total_volume_unit', 'total volume unit must not be NULL'),
			   ('price_unit_currency', 'price unit currency must not be NULL'),
			   ('trade_date', 'trade date must not be NULL'),
			   ('delivery_start','delivery start must not be NULL'),
			   ('delivery_end', 'delivery end must not be NULL'),
			   --('contract_capacity', 'contract capacity must not be NULL'),
			   ('ecm_document_type', 'ecm document type must not be NULL')

		DECLARE @column_name VARCHAR(200), @msg VARCHAR(1000)
		DECLARE c CURSOR FOR 
			SELECT column_name,
				   msg
			FROM #not_null
		OPEN c 
		FETCH NEXT FROM c INTO @column_name, @msg
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC ('
				INSERT INTO #temp_messages (source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, ''' + @column_name + ''', ''' + @msg + '''
				FROM source_ecm
				WHERE NULLIF(' + @column_name + ', '''') IS NULL
					AND ecm_document_type = ''CNF''
					AND process_id= ''' + @process_id + ''''
			)

			FETCH NEXT FROM c INTO @column_name, @msg 
		END
		CLOSE c
		DEALLOCATE c 

		IF OBJECT_ID('tempdb..#financial_null') IS NOT NULL
			DROP TABLE #financial_null

		CREATE TABLE #financial_null (
			column_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
			msg VARCHAR(1000) COLLATE DATABASE_DEFAULT
		)
		
		INSERT INTO #financial_null(column_name, msg)
		VALUES ('market', 'Market must be NULL for financial deal'),
			   ('commodity', 'commodity must be NULL for financial deal'),
			   ('delivery_point_area', 'delivery_point_area Must be NULL for financial deal'),
			   ('load_type', 'Load type must be NULL for financial deal'),
			   ('price_unit_currency', 'Price unit currency must be NULL for financial deal'),
			   ('price_unit_capacity_unit', 'Price unit capacity unit must be NULL for financial deal')

		DECLARE c CURSOR FOR 
			SELECT column_name,
				   msg
			FROM #financial_null
		OPEN c 
		FETCH NEXT FROM c INTO @column_name, @msg
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC ('
				INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, ''' + @column_name + ''', ''' + @msg + '''
				FROM source_ecm
				WHERE physical_financial_flag = ''f''
					AND ecm_document_type = ''CNF''
					AND ' + @column_name + ' IS NOT NULL
					AND process_id= ''' + @process_id + '''
			')

			FETCH NEXT FROM c INTO @column_name, @msg 
		END
		CLOSE c
		DEALLOCATE c

		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT se.source_deal_header_id, 'contract_capacity','contract capacity must not be NULL'
		FROM source_ecm se
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = se.source_deal_header_id
		WHERE sdh.internal_desk_id = 17300
			AND se.process_id = @process_id
			AND NULLIF(se.contract_capacity,0) IS NULL
		
		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'document_id','document ID Must not exceed 255 characters'
		FROM source_ecm
		WHERE LEN(document_id) > 255
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id
				
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'market','Market Must be NL, BE or DE'
		FROM source_ecm
		WHERE market NOT IN ('NL', 'BE', 'DE')
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id				

 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'currency','Currency is invalid'
		FROM source_ecm
		WHERE currency NOT IN ('BGN','CHF','CZK','DKK','EUR','EUX','GBX','GBP','HRK','HUF','ISK','NOK','PCT','PLN','RON','SEK','USD','OTH')
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id	
				
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'total_volume_unit','total volume unit is invalid'
		FROM source_ecm
		WHERE total_volume_unit NOT IN ('KWh','MWh','GWh','Therm','cm','mcm','MMBtu')
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id	

 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'price_unit_currency','Price unit currency is invalid'
		FROM source_ecm
		WHERE price_unit_currency NOT IN ('BGN','CHF','CZK','DKK','EUR','EUX','GBX','GBP','HRK','HUF','ISK','NOK','PCT','PLN','RON','SEK','USD','OTH')
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id	
				
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'price_unit_capacity_unit','Price unit currency is invalid'
		FROM source_ecm
		WHERE price_unit_capacity_unit NOT IN ('KWh','MWh','GWh','Therm','cm','mcm','MMBtu')
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id	
								
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'total_contract_value','Total contract value must not be null for transaction type ''FOR'' or ''OPT'' '
		FROM source_ecm
		WHERE transaction_type IN ('FOR', 'OPT')
			AND total_contract_value IS NULL
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id					
	
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'buyer_hubcode','Buyer Hubcode must not be null for gas commodity '
		FROM source_ecm
		WHERE commodity = 'Gas'
			AND buyer_hubcode IS NULL
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id					
	
 		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'seller_hubcode','Seller Hubcode must not be null for gas commodity '
		FROM source_ecm
		WHERE commodity = 'Gas'
			AND seller_hubcode IS NULL
			AND ecm_document_type = 'CNF'
			AND process_id = @process_id

		UPDATE srns
		SET srns.[error_validation_message] = s.msg 
		FROM source_ecm srns
		INNER JOIN source_ecm vt_outer ON vt_outer.source_deal_header_id = srns.source_deal_header_id
			AND srns.ecm_document_type = 'CNF'
			AND srns.process_id = @process_id
		CROSS APPLY (
			SELECT STUFF((SELECT DISTINCT ','  + ISNULL((tm.[messages]), '')
						  FROM source_ecm vt
						  INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
						  WHERE tm.messages IS NOT NULL
							AND vt.ecm_document_type = 'CNF'
							AND vt_outer.source_deal_header_id = vt.source_deal_header_id
						  FOR XML PATH('')), 1, 1, ''
						) AS msg
			FROM source_ecm vt
			INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
			WHERE tm.messages IS NOT NULL
				AND vt.ecm_document_type = 'CNF'
				AND vt_outer.source_deal_header_id = vt.source_deal_header_id
			GROUP BY vt.source_deal_header_id
		) s

		IF @include_bfi = 1
		BEGIN
			INSERT INTO [source_ecm] (
				[source_deal_header_id], [deal_id], [sub_book_id], [physical_financial_flag], [document_id], [broker_fee], [document_usage], [sender_id],
				[receiver_id], [receiver_role], [document_version], [currency], [ecm_document_type], [report_type], [create_date_from], [create_date_to],
				[create_ts], [acer_submission_status], [process_id]
			)
			SELECT DISTINCT
				   td.source_deal_header_id source_deal_header_id,
				   td.deal_id deal_id,
				   MAX(td.sub_book_id) sub_book_id,
				   MAX(td.physical_financial_flag) physical_financial_flag,
				   'BFI_' + CONVERT(VARCHAR(10), MAX(td.deal_date), 112) + '_' + REPLICATE('0', 10 - LEN(RTRIM(td.source_deal_header_id))) + RTRIM(td.source_deal_header_id) + '@' + MAX(tcuv.[Sub EIC]) document_id,
				   CAST(CASE MAX(sdv_r.code) WHEN 'PTTA' THEN 0
										WHEN 'PTTP' THEN 0
				   ELSE 0
				   END AS FLOAT) broker_fee,
				   ISNULL(@document_usage, 'Test') document_usage,
				   MAX(tcuv.[Sub EIC]) sender_id,
				   MAX(tcuv.[Broker EIC]) receiver_id,
				   'Broker' receiver_role,
				   CASE WHEN MAX(ecm.document_version) IS NULL THEN ROW_NUMBER() OVER(PARTITION BY td.deal_id ORDER BY td.deal_id, MAX(ecm.ecm_document_type)) ELSE MAX(ecm.document_version) + 1 END document_version,
				   MAX(CASE scur_fixed.currency_name WHEN 'Euro' THEN 'EUR'WHEN 'Ect' THEN 'EUX' WHEN 'GPC' THEN 'GBX' ELSE UPPER(scur_fixed.currency_name) END) [currency],
				   'BFI' ecm_document_type,
				   NULL [report_type],
				   @create_date_from [create_date_from],
				   @create_date_to [create_date_to],
				   @create_ts [create_ts],
				   39500 [submission_status],
				   @process_id [process_id]
			FROM #temp_deals td
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = td.source_deal_header_id
			INNER JOIN setup_submission_rule ssr
				ON ssr.submission_type_id = 44705
				AND ssr.broker_id = sdh.broker_id
				AND ISNULL(ssr.commodity_id,td.commodity_id) = td.commodity_id
			INNER JOIN maintain_udf_static_data_detail_values musddv
				ON musddv.primary_field_object_id = sdh.broker_id
			INNER JOIN application_ui_template_fields autf
				ON autf.application_field_id = musddv.application_field_id
			INNER JOIN user_defined_fields_template udft
				ON udft.udf_template_id = autf.udf_template_id
			INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id = tdd.source_deal_header_id
			INNER JOIN source_ecm ecm_cnf ON td.source_deal_header_id = ecm_cnf.source_deal_header_id
				AND ecm_cnf.ecm_document_type = 'CNF'
			LEFT JOIN #temp_cpty_udf_values tcuv 
				ON tcuv.source_deal_header_id = td.source_deal_header_id
			LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = td.template_id
				AND uddft.field_id = @udf_broker_fee
			LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = td.source_deal_header_id
				AND uddf.udf_template_id = uddft.udf_template_id
			LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = tdd.curve_id
        	LEFT JOIN source_commodity scom ON scom.source_commodity_id = ISNULL(spcd.commodity_id, td.commodity_id)
        	LEFT JOIN source_minor_location sml ON  sml.source_minor_location_id = tdd.location_id
        	LEFT JOIN static_data_value sdv_cntry ON sdv_cntry.type_id = 14000 AND sdv_cntry.value_id = sml.country
        	LEFT JOIN source_ecm ecm ON td.source_deal_header_id = ecm.source_deal_header_id
				AND ecm.ecm_document_type = 'BFI'
        	LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = td.deal_status
        	LEFT JOIN source_uom tsu ON tdd.deal_volume_uom_id = tsu.source_uom_id
        	LEFT JOIN source_currency scur_fixed ON scur_fixed.source_currency_id = tdd.fixed_price_currency_id
        	LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = td.block_define_id
        	LEFT JOIN source_deal_type sd_type ON sd_type.source_deal_type_id = td.source_deal_type_id
				AND sd_type.sub_type = 'n'
			LEFT JOIN static_data_value sdv_r
				ON sdv_r.value_id = sdh.reporting_group1
				AND sdv_r.type_id = 113000
			WHERE td.deal_status <> 5607
				--AND uddf.udf_value IS NOT NULL
				AND udft.Field_label = 'ECM Reportable'
				AND ISNULL(musddv.static_data_udf_values, 'n') = 'y'
			GROUP BY  td.source_deal_header_id, td.deal_id

			TRUNCATE TABLE #not_null
			TRUNCATE TABLE #temp_messages

			INSERT INTO #not_null(column_name, msg)
			VALUES ('document_id', 'document ID Must not be NULL')
				   ,('document_version', 'document version Must not be NULL')
				   --,('broker_fee', 'broker fee must not be NULL')
				   ,('currency', 'Currency must not be NULL')
				   ,('ecm_document_type', 'ecm document type must not be NULL')

			DECLARE c CURSOR FOR 
				SELECT column_name,
					   msg
				FROM #not_null
			OPEN c 
			FETCH NEXT FROM c INTO @column_name, @msg
			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC('
					INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
					SELECT source_deal_header_id, ''' + @column_name + ''', ''' + @msg + '''
					FROM source_ecm
					WHERE NULLIF(' + @column_name + ', '''') IS NULL
						AND ecm_document_type = ''BFI''
						AND process_id = ''' + @process_id +'''
				')

				FETCH NEXT FROM c INTO @column_name, @msg 
			END
			CLOSE c
			DEALLOCATE c 
			

 			INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
			SELECT source_deal_header_id, 'document_id','document ID Must not exceed 255 characters'
			FROM source_ecm
			WHERE LEN(document_id) > 255
				AND ecm_document_type = 'BFI'
				AND process_id = @process_id
				
 			INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
			SELECT source_deal_header_id, 'currency','Currency is invalid'
			FROM source_ecm
			WHERE currency NOT IN ('BGN','CHF','CZK','DKK','EUR','EUX','GBX','GBP','HRK','HUF','ISK','NOK','PCT','PLN','RON','SEK','USD','OTH')
				AND ecm_document_type = 'BFI'
				AND process_id = @process_id	
								 
			UPDATE srns 
			SET srns.[error_validation_message] = s.msg
			FROM source_ecm srns
			INNER JOIN source_ecm vt_outer ON vt_outer.source_deal_header_id = srns.source_deal_header_id
				AND srns.ecm_document_type = 'BFI'
				AND srns.process_id = @process_id
			CROSS APPLY (
				SELECT STUFF((SELECT DISTINCT ','  + ISNULL((tm.[messages]), '')
							  FROM source_ecm vt
							  INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
							  WHERE tm.messages IS NOT NULL
								AND vt.ecm_document_type = 'BFI'
								AND vt_outer.source_deal_header_id = vt.source_deal_header_id
							  FOR XML PATH('')), 1, 1, '') AS msg
				FROM source_ecm vt
				INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
				WHERE tm.messages IS NOT NULL
					AND vt.ecm_document_type = 'BFI'
					AND vt_outer.source_deal_header_id = vt.source_deal_header_id
				GROUP BY vt.source_deal_header_id
			) s
		END  
 
		INSERT INTO [source_ecm] (
			[source_deal_header_id], [deal_id], [sub_book_id], [physical_financial_flag], [document_id], [document_usage], [sender_id],
			[receiver_id], [receiver_role], [reference_document_id], [reference_document_version], [ecm_document_type], [report_type],
			[create_date_from], [create_date_to], [create_ts], [acer_submission_status], [acer_submission_date], [acer_confirmation_date],
			[process_id], [error_validation_message], [file_export_name]
		)
		SELECT DISTINCT 
			   td.source_deal_header_id source_deal_header_id,
			   td.deal_id deal_id,
			   MAX(td.sub_book_id) sub_book_id,
			   MAX(td.physical_financial_flag) physical_financial_flag,
			   'CAN_' + CONVERT(VARCHAR(10), MAX(td.deal_date), 112) + '_' + REPLICATE('0', 10-LEN(RTRIM(td.source_deal_header_id))) + RTRIM(td.source_deal_header_id) + '@' + MAX(tcuv.[Sub EIC]) document_id,
			   ISNULL(@document_usage, 'Test') document_usage,
			   MAX(tcuv.[Sub EIC]) sender_id,
			   MAX(tcuv.[Deal EIC]) receiver_id,
			   'Trader' receiver_role,
			   MAX(ecm.document_id) reference_document_id,
			   MAX(ecm.document_version) reference_document_version,
			   'CAN' ecm_document_type,
			   NULL [report_type],
			   @create_date_from [create_date_from],
			   @create_date_to [create_date_to],
			   @create_ts [create_ts],
			   39500 [submission_status],
			   NULL [submission_date],
			   NULL [confirmation_date],
			   @process_id [process_id],
			   NULL [error_validation_message],
			   NULL [file_export_name]
		FROM #temp_deals td
        INNER JOIN #temp_deal_details tdd ON td.source_deal_header_id = tdd.source_deal_header_id
		LEFT JOIN #temp_cpty_udf_values tcuv 
			ON tcuv.source_deal_header_id = td.source_deal_header_id
        LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = tdd.curve_id
        LEFT JOIN source_commodity scom ON scom.source_commodity_id = ISNULL(spcd.commodity_id, td.commodity_id)
        LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = tdd.location_id
        LEFT JOIN static_data_value sdv_cntry ON sdv_cntry.type_id = 14000
			AND sdv_cntry.value_id = sml.country
		OUTER APPLY (
			SELECT TOP 1 * 
			FROM source_ecm e
			WHERE e.source_deal_header_id = td.source_deal_header_id
				AND e.ecm_document_type = 'CNF'
			ORDER BY create_ts DESC
		) ecm
        LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = td.deal_status
        LEFT JOIN source_uom tsu ON tdd.deal_volume_uom_id = tsu.source_uom_id
        LEFT JOIN source_currency scur_fixed ON scur_fixed.source_currency_id = tdd.fixed_price_currency_id
        LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = td.block_define_id
        LEFT JOIN source_deal_type sd_type ON sd_type.source_deal_type_id = td.source_deal_type_id
			AND sd_type.sub_type = 'n'
		WHERE td.deal_status = 5607
		GROUP BY  td.source_deal_header_id, td.deal_id

		TRUNCATE TABLE #not_null
		TRUNCATE TABLE #temp_messages

		INSERT INTO #not_null(column_name, msg)
		VALUES ('document_id', 'document ID Must not be NULL'),
			   ('ecm_document_type', 'ecm document type must not be NULL')

		DECLARE c CURSOR FOR 
			SELECT column_name,
				   msg
			FROM #not_null
		OPEN c 
		FETCH NEXT FROM c INTO @column_name, @msg
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC ('
				INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
				SELECT source_deal_header_id, ''' + @column_name + ''', ''' + @msg + '''
				FROM source_ecm
				WHERE NULLIF(' + @column_name + ', '''') IS NULL
					AND ecm_document_type = ''CAN''
					AND process_id= ''' + @process_id + '''
			')

			FETCH NEXT FROM c INTO @column_name, @msg 
		END
		CLOSE c
		DEALLOCATE c
		
		INSERT INTO #temp_messages(source_deal_header_id, [column], [messages])
		SELECT source_deal_header_id, 'document_id','document ID Must not exceed 255 characters'
		FROM source_ecm
		WHERE LEN(document_id) > 255
			AND ecm_document_type = 'CAN'
			AND process_id = @process_id
			
		UPDATE srns
		SET srns.[error_validation_message] = s.msg
		FROM source_ecm srns
		INNER JOIN source_ecm vt_outer ON vt_outer.source_deal_header_id = srns.source_deal_header_id
			AND srns.ecm_document_type = 'CAN'
			AND srns.process_id = @process_id
		CROSS APPLY (
			SELECT STUFF((SELECT DISTINCT ','  + ISNULL((tm.[messages]),'')
						  FROM source_ecm vt
						  INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
						  WHERE tm.messages IS NOT NULL
							AND vt.ecm_document_type = 'CAN'
							AND vt_outer.source_deal_header_id = vt.source_deal_header_id
						  FOR XML PATH('')
					), 1, 1, '') AS msg
			FROM source_ecm vt
			INNER JOIN #temp_messages tm ON vt.source_deal_header_id = tm.source_deal_header_id
			WHERE tm.messages IS NOT NULL
				AND vt.ecm_document_type = 'CAN'
				AND vt_outer.source_deal_header_id = vt.source_deal_header_id
			GROUP BY vt.source_deal_header_id
		) s

		EXEC spa_ErrorHandler 0, 'Regulatory Submission', 'spa_ecm', 'Success', 'Data saved successfully.', @process_id
		COMMIT
	END TRY
    BEGIN CATCH
        DECLARE @err_no INT,
				@err VARCHAR(MAX)
        SET @err = 'Failed to save data. Error:' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
            	ROLLBACK	
        
		EXEC spa_ErrorHandler -1, 'Ecm', 'spa_ecm', 'Error', @err, ''
    END CATCH
END
ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
		DECLARE @result VARCHAR(MAX),
				@output_folder VARCHAR(1000),
				@archive_folder VARCHAR(1000)
	
		SELECT TOP (1)
			   @output_folder = gmv.clm2_value,
			   @archive_folder = gmv.clm3_value
		FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
		WHERE gmh.mapping_name = 'Ecm_Config'
	
		SELECT @server_location = document_path + '\temp_note\ECM'
		FROM connection_string 

		SELECT @file_transfer_endpoint_id = file_transfer_endpoint_id
			  ,@remote_location = remote_directory
		FROM file_transfer_endpoint
		WHERE [name] = @file_transfer_endpoint_name

		IF OBJECT_ID('tempdb..#temp_ftp_files') IS NOT NULL
			DROP TABLE #temp_ftp_files
		CREATE TABLE #temp_ftp_files(ftp_url NVARCHAR(1000), dir_file NVARCHAR(2000))
		INSERT INTO #temp_ftp_files
		EXEC spa_list_ftp_contents_using_clr @file_transfer_endpoint_id, @remote_location , @output_result OUTPUT

		DELETE FROM #temp_ftp_files 
		WHERE dir_file not like '%.xml%'

		SELECT @download_files = STUFF((SELECT DISTINCT ',' +  dir_file 
										FROM #temp_ftp_files
										WHERE (CHARINDEX('payload-id',dir_file) > 0 
										)
								FOR XML PATH('')), 1, 1, '')
		--SELECT @download_files
		IF @download_files IS NOT NULL
		BEGIN
			EXEC spa_download_file_from_ftp_using_clr @file_transfer_endpoint_id, @remote_location, @download_files, @server_location, '.xml', @output_result OUTPUT
		
			IF OBJECT_ID('tempdb..#temp_ecm_payload_xml_data') IS NOT NULL
				DROP TABLE #temp_ecm_payload_xml_data

			CREATE TABLE #temp_ecm_payload_xml_data(
				document_id  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				document_type  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				document_version  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				ebXML_message_id  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[state]  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[time_stamp]  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[reason_code]  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[reason_text]  NVARCHAR(4000) COLLATE DATABASE_DEFAULT,
				[broker_state]  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[transfer_id]  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[transmission_timestamp]  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[conversation_id]  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[sender_organisation]  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[receiver_organisation]  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
				download_file_name  NVARCHAR(100) COLLATE DATABASE_DEFAULT
	
			)

			DECLARE @dir_file NVARCHAR(1000), @target_remote_directory VARCHAR(MAX)
			SELECT @success_files = '', @error_files = ''
			DECLARE db_cursor CURSOR FOR  
				SELECT dir_file 
				FROM #temp_ftp_files
			OPEN db_cursor   
			FETCH NEXT FROM db_cursor INTO @dir_file
			WHILE @@FETCH_STATUS = 0   
			BEGIN   
				SELECT @xml_file_content = dbo.FNAReadFileContents(@server_location + '\' + @dir_file)
				IF @xml_file_content IS NOT NULL
				BEGIN
					INSERT INTO #temp_ecm_payload_xml_data(document_id,document_type,document_version,ebXML_message_id,[state],[time_stamp],[reason_code],[reason_text],[broker_state]
							,[transfer_id],[transmission_timestamp],[conversation_id],[sender_organisation],[receiver_organisation],download_file_name)
					SELECT x.xml_col.value('(Payload/Message/BoxResult/DocumentID)[1]','VARCHAR(1000)') as [document_id]
						  ,x.xml_col.value('(Payload/Message/BoxResult/DocumentType)[1]','VARCHAR(1000)') as [document_type]
						  ,x.xml_col.value('(Payload/Message/BoxResult/DocumentVersion)[1]','VARCHAR(1000)') as [document_version]
						  ,x.xml_col.value('(Payload/Message/BoxResult/ebXMLMessageId)[1]','VARCHAR(1000)') as [ebXML_message_id]
						  ,x.xml_col.value('(Payload/Message/BoxResult/State)[1]','VARCHAR(1000)') as [state]
						  ,x.xml_col.value('(Payload/Message/BoxResult/Timestamp)[1]','VARCHAR(1000)') as [time_stamp]
						  ,x.xml_col.value('(Payload/Message/BoxResult/Reason/ReasonCode)[1]','VARCHAR(1000)') as [reason_code]
						  ,x.xml_col.value('(Payload/Message/BoxResult/Reason/ReasonText)[1]','VARCHAR(4000)') as [reason_text]
						  ,x.xml_col.value('(Payload/Message/BoxResult/BrokerState)[1]','VARCHAR(1000)') as [broker_state]
						  ,x.xml_col.value('(TransmissionInformation/TransmissionCharacteristics/TransferID)[1]','VARCHAR(1000)') as [transfer_id]
						  ,x.xml_col.value('(TransmissionInformation/TransmissionCharacteristics/TransmissionTimeStamp)[1]','VARCHAR(1000)') as [transmission_timestamp]
						  ,x.xml_col.value('(TransmissionInformation/TransmissionCharacteristics/ConversationID)[1]','VARCHAR(1000)') as [conversation_id]
						  ,x.xml_col.value('(TransmissionInformation/TransmissionOrganisationIdentifiers/SenderOrganisation)[1]','VARCHAR(1000)') as [sender_organisation]
						  ,x.xml_col.value('(TransmissionInformation/TransmissionOrganisationIdentifiers/ReceiverOrganisation)[1]','VARCHAR(1000)') as [receiver_organisation]
						  ,@dir_file
					FROM ( SELECT  CAST(@xml_file_content AS xml) RawXml) b
					CROSS APPLY b.RawXml.nodes('/Envelope') x(xml_col)

					IF EXISTS(SELECT 1 FROM #temp_ecm_payload_xml_data  WHERE (ISNULL([state],'-1') IN ('MATCHED', 'PENDING', 'PRELIMINARY_MATCHED') OR ISNULL([broker_state],'-1') IN ('MATCHED', 'PENDING', 'PRELIMINARY_MATCHED')) AND download_file_name = @dir_file)
					BEGIN
						SELECT @success_files += IIF(NULLIF(@success_files,'') IS NULL, @dir_file, ',' + @dir_file)
		
					END
					ELSE IF EXISTS(SELECT 1 FROM #temp_ecm_payload_xml_data WHERE (ISNULL([state],'-1') IN ('FAILED') OR ISNULL([broker_state],'-1') IN ('FAILED')) AND download_file_name = @dir_file)
					BEGIN
						SELECT @error_files += IIF(NULLIF(@error_files,'') IS NULL, @dir_file, ',' + @dir_file)
					END
				END
				FETCH NEXT FROM db_cursor INTO @dir_file
			END   

			CLOSE db_cursor   
			DEALLOCATE db_cursor

			IF EXISTS(SELECT 1 FROM #temp_ecm_payload_xml_data temp
					WHERE (ISNULL([state],'-1') IN ('MATCHED', 'PENDING', 'PRELIMINARY_MATCHED') OR ISNULL([broker_state],'-1') IN ('MATCHED', 'PENDING', 'PRELIMINARY_MATCHED')) 
					OR (ISNULL([state],'-1') IN ('FAILED') OR ISNULL([broker_state],'-1') IN ('FAILED'))
			)
			BEGIN
				IF NULLIF(@success_files,'') IS NOT NULL
				BEGIN
					SET @target_remote_directory = @remote_location + '/Processed/' + CONVERT(VARCHAR(7), GETDATE(), 120) + '/'
					EXEC spa_move_ftp_file_to_folder_using_clr @file_transfer_endpoint_id, @remote_location , @target_remote_directory, @success_files, @output_result OUTPUT
				END

				IF NULLIF(@error_files, '') IS NOT NULL
				BEGIN
					SET @target_remote_directory = @remote_location + '/Error/' + CONVERT(VARCHAR(7), GETDATE(), 120) + '/'
					EXEC spa_move_ftp_file_to_folder_using_clr @file_transfer_endpoint_id, @remote_location , @target_remote_directory, @error_files, @output_result OUTPUT
				END

				INSERT INTO ecm_response_log(document_id, document_type, document_version, ebXML_message_id, [state], [timestamp], transfer_id, transmission_timestamp, conversation_id, sender_organisation, receiver_organisation, reason_code, reason_text)
				SELECT document_id
					 , document_type
					 , document_version
					 , ebXML_message_id
					 , ISNULL([state],[broker_state])
					 , time_stamp
					 , transfer_id
					 , transmission_timestamp
					 , conversation_id
					 , sender_organisation
					 , receiver_organisation
					 , reason_code
					 , reason_text
				FROM #temp_ecm_payload_xml_data
				WHERE (ISNULL([state],'-1') IN ('MATCHED', 'PENDING', 'PRELIMINARY_MATCHED') OR ISNULL([broker_state],'-1') IN ('MATCHED', 'PENDING', 'PRELIMINARY_MATCHED')) 
				OR (ISNULL([state],'-1') IN ('FAILED') OR ISNULL([broker_state],'-1') IN ('FAILED'))

				SELECT @process_id = dbo.FNAGETNEWID()
				SELECT @user_name  = dbo.FNAdbuser()
				SELECT @file_name = 'ECM_Feedback_' + CONVERT(VARCHAR(30), GETDATE(),112) + REPLACE(CONVERT(VARCHAR(30), GETDATE(),108),':','') + '.csv'

				SELECT @process_table = dbo.FNAProcessTableName('ecm_remit_feedback_', dbo.FNADBUser(), @process_id) 
				SELECT @server_location = document_path
				FROM connection_string 
				SELECT @full_file_path = @server_location + '\temp_Note\' + @file_name

				EXEC('SELECT [document_id] ,[document_type] ,[document_version] ,[ebXML_message_id] ,[state] ,[time_stamp] ,[reason_code] 
					  ,REPLACE(REPLACE(REPLACE([reason_text],'','','' ''), CHAR(13), ''''), CHAR(10), '''') [reason_text] 
					  ,[broker_state] ,[transfer_id] ,[transmission_timestamp] ,[conversation_id] ,[sender_organisation] ,[receiver_organisation] ,[download_file_name]
					  INTO ' + @process_table + ' FROM #temp_ecm_payload_xml_data
					  WHERE (ISNULL([state],''-1'') IN (''FAILED'') OR ISNULL([broker_state],''-1'') IN (''FAILED''))
					  OR (ISNULL([state],''-1'') IN (''MATCHED'', ''PENDING'', ''PRELIMINARY_MATCHED'') OR ISNULL([broker_state],''-1'') IN (''MATCHED'', ''PENDING'', ''PRELIMINARY_MATCHED''))
					  ')


				IF EXISTS(SELECT 1 FROM #temp_ecm_payload_xml_data temp
						WHERE (ISNULL([state],'-1') IN ('FAILED') OR ISNULL([broker_state],'-1') IN ('FAILED'))
				)
				BEGIN
					EXEC spa_export_to_csv @process_table, @full_file_path, 'y', ',', 'n','y','n','n',@output_result OUTPUT
					INSERT INTO source_system_data_import_status (process_id, code, module, source, type, description)
					SELECT @process_id, temp.[state], 'ECM Feedback', 'ECM Feedback', ISNULL([state],[broker_state]), temp.[reason_code]
					FROM #temp_ecm_payload_xml_data temp
					WHERE (ISNULL([state],'-1') IN ('FAILED') OR ISNULL([broker_state],'-1') IN ('FAILED'))
					  OR (ISNULL([state],'-1') IN ('MATCHED', 'PENDING', 'PRELIMINARY_MATCHED') OR ISNULL([broker_state],'-1') IN ('MATCHED', 'PENDING', 'PRELIMINARY_MATCHED'))
					SELECT @url = '../../adiha.php.scripts/dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
					SELECT @desc_success = 'ECM Feedback captured with error. <a target="_blank" href="' + @url + '">Click here.</a>'
				END
				ELSE
				BEGIN
					EXEC spa_export_to_csv @process_table, @full_file_path, 'y', ',', 'n','y','n','n',@output_result OUTPUT
					SET @desc_success = 'ECM Feedback captured successfully.<br>'
										+  '<b>Response :</b> ' + 'Success'
				END

				INSERT INTO message_board(user_login_id, source, [description], url_desc, url, [type], job_name, as_of_date, process_id, process_type)
				SELECT DISTINCT au.user_login_id, 'ECM Feedback' , ISNULL(@desc_success, 'Description is null'), NULL, NULL, 's',NULL, NULL,@process_id,NULL
				FROM dbo.application_role_user aru
				INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
				INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
				WHERE (au.user_active = 'y') AND (asr.role_type_value_id = 22) AND au.user_emal_add IS NOT NULL
				GROUP BY au.user_login_id, au.user_emal_add	

				INSERT INTO email_notes
					(
						notes_subject,
						notes_text,
						send_from,
						send_to,
						send_status,
						active_flag,
						attachment_file_name
					)		
				SELECT DB_NAME() + ': ECM Feedback',
					'Dear <b>' + MAX(au.user_l_name) + '</b><br><br>

					 ECM Feedback has been captured. Please check the Summary Report attached in email.',
					'noreply@pioneersolutionsglobal.com',
					au.user_emal_add,
					'n',
					'y',
					@full_file_path
				FROM dbo.application_role_user aru
				INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
				INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
				WHERE (au.user_active = 'y') AND (asr.role_type_value_id = 22) AND au.user_emal_add IS NOT NULL
				GROUP BY au.user_login_id, au.user_emal_add

				SET @result = '1'
			END
		END
		
		DECLARE @response_deal_id VARCHAR(MAX), @response_status NVARCHAR(100)
		
		IF ISNULL(NULLIF(@result, ''), '0') <> '0'
		BEGIN
			
			IF OBJECT_ID('tempdb..#temp_deal_status') IS NOT NULL
					DROP TABLE #temp_deal_status
			SELECT DISTINCT se.source_deal_header_id, r.state [response_status]
			INTO #temp_deal_status
			FROM source_ecm se		   
			INNER JOIN #temp_ecm_payload_xml_data doc ON doc.document_id = se.document_id
			CROSS APPLY (
				SELECT [time_stamp] [time_stamp]
				FROM #temp_ecm_payload_xml_data
				WHERE document_id = se.document_id
					AND document_version = se.document_version
					AND COALESCE([state], [broker_state]) IN ('Matched', 'PENDING', 'PRELIMINARY_MATCHED' )
			) temp
			CROSS APPLY (
				SELECT ISNULL([state],[broker_state]) [state]
				FROM #temp_ecm_payload_xml_data
				WHERE document_id = se.document_id
					AND document_version = se.document_version
					AND [time_stamp] = temp.[time_stamp]
					AND COALESCE([state], [broker_state]) IN ('Matched', 'PENDING', 'PRELIMINARY_MATCHED' )
			) r GROUP BY r.state, temp.time_stamp , se.source_deal_header_id
		
			IF OBJECT_ID('tempdb..#temp_update_confirm_status') IS NOT NULL
					DROP TABLE #temp_update_confirm_status

			CREATE TABLE #temp_update_confirm_status (
				id VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				deal_id INT,
				as_of_date DATETIME,
				confirm_status INT,
				comment1 VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
				comment2 VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
				confirm_id VARCHAR(200) COLLATE DATABASE_DEFAULT 
			)

			IF EXISTS ( SELECT 1 FROM #temp_deal_status WHERE response_status IN ('Matched', 'PRELIMINARY_MATCHED' ))
			BEGIN
				INSERT INTO #temp_update_confirm_status (id, deal_id, as_of_date, confirm_status, comment1, comment2, confirm_id)
				SELECT DISTINCT '', CAST(source_deal_header_id AS VARCHAR(10)), CONVERT(VARCHAR(10), @create_ts, 120), IIF(response_status IN('Matched', 'PRELIMINARY_MATCHED'),17202,17215), '', '', ''
				FROM #temp_deal_status WHERE  response_status IN ('Matched', 'PRELIMINARY_MATCHED')
			END
			ELSE 
			BEGIN
				INSERT INTO #temp_update_confirm_status (id, deal_id, as_of_date, confirm_status, comment1, comment2, confirm_id)
				SELECT '', CAST(source_deal_header_id AS VARCHAR(10)), CONVERT(VARCHAR(10), @create_ts, 120), IIF(response_status IN('Matched', 'PRELIMINARY_MATCHED'),17202,17215), '', '', ''
			    FROM #temp_deal_status WHERE  response_status IN ('PENDING')
			END
			
			INSERT INTO confirm_status (source_deal_header_id, type, as_of_date)
			SELECT t.deal_id, t.confirm_status, t.as_of_date
			FROM #temp_update_confirm_status t

			INSERT INTO confirm_status_recent (source_deal_header_id, type, as_of_date)
			SELECT t.deal_id, t.confirm_status, t.as_of_date
			FROM #temp_update_confirm_status t 
			LEFT JOIN confirm_status_recent csr ON csr.source_deal_header_id = t.deal_id
			WHERE csr.source_deal_header_id IS NULL

			UPDATE csr
			SET [type] = t.confirm_status
			FROM #temp_update_confirm_status t 
			LEFT JOIN confirm_status_recent csr ON csr.source_deal_header_id = t.deal_id
			WHERE csr.source_deal_header_id IS NOT NULL
				
			UPDATE source_deal_header
			SET confirm_status_type = t.confirm_status,
				update_ts = GETDATE(),
				update_user = dbo.FNADBUSer()
			FROM #temp_update_confirm_status t
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = t.deal_id
			
				
			SELECT @response_deal_id = STUFF((SELECT DISTINCT ',' +  CAST(source_deal_header_id AS NVARCHAR(20))
											  FROM #temp_deal_status
									   FOR XML PATH('')), 1, 1, '') 	
			EXEC spa_insert_update_audit 'u', @response_deal_id

			
		END	   
	END TRY
	BEGIN CATCH
		PRINT 'Catch Error:' + ERROR_MESSAGE()
		IF @@TRANCOUNT > 0
			ROLLBACK	
	END CATCH 
END
ELSE IF @flag = 'x'
BEGIN
	SELECT id [ID],
		   source_deal_header_id [Source Deal Header ID],
		   deal_id [Deal ID],
		   sub_book_id [Sub Book ID],
		   physical_financial_flag [Physical Financial Flag],
		   document_id [Document ID],
		   document_usage [Document Usage],
		   sender_id [Sender ID],
		   receiver_id [Receiver ID],
		   receiver_role [Receiver Role],
		   document_version [Document Version],
		   market [Market],
		   commodity [Commodity],
		   transaction_type [Transaction Type],
		   delivery_point_area [Delivery Point Area],
		   buyer_party [Buyer Party],
		   seller_party [Seller Party],
		   load_type [Load Type],
		   agreement [Agreement],
		   currency [Currency],
		   total_volume [Total Volume],
		   total_volume_unit [Total Volume Unit],
		   trade_date [Trade Date],
		   capacity_unit [Capacity Unit],
		   price_unit_currency [Price Unit Currency],
		   price_unit_capacity_unit [Price Unit Capacity Unit],
		   total_contract_value [Total Contract Value],
		   delivery_start [Delivery Start],
		   delivery_end [Delivery End],
		   contract_capacity [Contract Capacity],
		   price [Price],
		   buyer_hubcode [Buyer Hubcode],
		   seller_hubcode [Seller Hubcode],
		   trader_name [Trader Name],
		   ecm_document_type [Ecm Document Type],
		   broker_fee [Broker Fee],
		   reference_document_id [Reference Document ID],
		   reference_document_version [Reference Document Version],
		   report_type [Report Type],
		   create_date_from [Create Date From],
		   create_date_to [Create Date To],
		   acer_submission_status [Acer Submission Status],
		   acer_submission_date [Acer Submission Date],
		   acer_confirmation_date [Acer Confirmation Date],
		   process_id [Process ID],
		   file_export_name [File Export Name],
		   error_validation_message [Error ValiDation Message]		   
	FROM source_ecm 
	WHERE process_id = @process_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT @server_location = document_path + '\temp_note\ECM'
	FROM connection_string 

	SELECT @file_transfer_endpoint_id = file_transfer_endpoint_id
		  ,@remote_location = remote_directory
	FROM file_transfer_endpoint
	WHERE [name] = @file_transfer_endpoint_name

	IF OBJECT_ID('tempdb..#temp_ftp_files_feedback') IS NOT NULL
		DROP TABLE #temp_ftp_files_feedback
	CREATE TABLE #temp_ftp_files_feedback(ftp_url NVARCHAR(1000), dir_file NVARCHAR(2000))
	INSERT INTO #temp_ftp_files_feedback
	EXEC spa_list_ftp_contents_using_clr @file_transfer_endpoint_id, @remote_location , @output_result OUTPUT

	DELETE FROM #temp_ftp_files_feedback 
	WHERE dir_file not like '%.xml%'

	SELECT @download_files = STUFF((SELECT DISTINCT ',' +  dir_file 
									FROM #temp_ftp_files_feedback
									WHERE (CHARINDEX('ACK-BFI_',dir_file) > 0 
										  OR CHARINDEX('ACK-CNF_',dir_file) > 0 
										  OR CHARINDEX('ACK-BCN_',dir_file) > 0
										  OR CHARINDEX('ACK-remit_',dir_file) > 0
									)
							FOR XML PATH('')), 1, 1, '')
	--SELECT @download_files
	IF @download_files IS NOT NULL
	BEGIN
		EXEC spa_download_file_from_ftp_using_clr @file_transfer_endpoint_id, @remote_location, @download_files, @server_location, '.xml', @output_result OUTPUT

		IF OBJECT_ID('tempdb..#temp_ack_xml_data') IS NOT NULL
			DROP TABLE #temp_ack_xml_data

		CREATE TABLE #temp_ack_xml_data(
			message_id  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
			message_time  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			reference_id  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			remote_reception_time  NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			code  NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
			[description]  NVARCHAR(2000) COLLATE DATABASE_DEFAULT,
			overall_result_code  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			download_file_name  NVARCHAR(100) COLLATE DATABASE_DEFAULT
		)
		SELECT @success_files = '', @error_files = ''
		DECLARE db_cursor CURSOR FOR  
			SELECT dir_file 
			FROM #temp_ftp_files_feedback
		OPEN db_cursor   
		FETCH NEXT FROM db_cursor INTO @dir_file
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
			SELECT @xml_file_content = dbo.FNAReadFileContents(@server_location + '\' + @dir_file)
			IF @xml_file_content IS NOT NULL
			BEGIN
				INSERT INTO #temp_ack_xml_data(message_id,message_time,reference_id,remote_reception_time,code,[description],overall_result_code,download_file_name)
				SELECT x.xml_col.value('(MessageId)[1]','VARCHAR(1000)') as [message_id]
					  ,x.xml_col.value('(MessageTime)[1]','VARCHAR(100)') as [message_time]
					  ,x.xml_col.value('(ReferenceId)[1]','VARCHAR(100)') as [reference_id]
					  ,x.xml_col.value('(RemoteReceptionTime)[1]','VARCHAR(200)') as [remote_reception_time]
					  ,x.xml_col.value('(Results/Code)[1]','VARCHAR(1000)') as [code]
					  ,x.xml_col.value('(Results/Description)[1]','VARCHAR(2000)') as [description]
					  ,x.xml_col.value('(OverallResultCode)[1]','VARCHAR(100)') as [overall_result_code]
					  , IIF(CHARINDEX('error',@dir_file) > 0,LEFT(REPLACE(REPLACE(@dir_file,'ACK-',''),'.xml',''), CHARINDEX('error', REPLACE(REPLACE(@dir_file,'ACK-',''),'.xml','')) - 1),REPLACE(REPLACE(@dir_file,'ACK-',''),'.xml',''))
				FROM ( SELECT  CAST(@xml_file_content AS XML) RawXml) b
				CROSS APPLY b.RawXml.nodes('/XpAcknowledgment') x(xml_col)

				IF EXISTS(SELECT 1 FROM #temp_ack_xml_data WHERE overall_result_code IN ('Success') AND download_file_name = @dir_file)
				BEGIN
					SELECT @success_files += IIF(NULLIF(@success_files,'') IS NULL, @dir_file, ',' + @dir_file)
		
				END
				ELSE IF EXISTS(SELECT 1 FROM #temp_ack_xml_data WHERE overall_result_code IN ('Error') AND download_file_name = @dir_file)
				BEGIN
					SELECT @error_files += IIF(NULLIF(@error_files,'') IS NULL, @dir_file, ',' + @dir_file)
				END
			END
			FETCH NEXT FROM db_cursor INTO @dir_file
		END   

		CLOSE db_cursor   
		DEALLOCATE db_cursor

		IF @success_files IS NOT NULL
		BEGIN
			SET @target_remote_directory = @remote_location + '/Processed/' + CONVERT(VARCHAR(7), GETDATE(), 120) + '/'
			EXEC spa_move_ftp_file_to_folder_using_clr @file_transfer_endpoint_id, @remote_location , @target_remote_directory, @success_files, @output_result OUTPUT
		END

		IF @error_files IS NOT NULL
		BEGIN
			SET @target_remote_directory = @remote_location + '/Error/' + CONVERT(VARCHAR(7), GETDATE(), 120) + '/'
			EXEC spa_move_ftp_file_to_folder_using_clr @file_transfer_endpoint_id, @remote_location , @target_remote_directory, @error_files, @output_result OUTPUT
		END

		INSERT INTO ecm_response_log(document_id,transmission_timestamp,conversation_id,[timestamp],reason_code,reason_text, [state])
		SELECT IIF(CHARINDEX('error',download_file_name) > 0,LEFT(REPLACE(REPLACE(download_file_name,'ACK-',''),'.xml',''), CHARINDEX('error', REPLACE(REPLACE(download_file_name,'ACK-',''),'.xml','')) - 1),REPLACE(REPLACE(download_file_name,'ACK-',''),'.xml',''))
			  , message_time
			  , reference_id
			  , remote_reception_time
			  , code
			  , [description]
			  , overall_result_code
		FROM #temp_ack_xml_data
		WHERE (CHARINDEX('BFI_',download_file_name) > 0 OR CHARINDEX('CNF_',download_file_name) > 0)


		INSERT INTO source_remit_audit(message_id,message_received_timestamp,uti_id, processed_timestamp, error_code, error_description, [status], [type], [source_file_name])
		SELECT message_id,  GETDATE(), reference_id, remote_reception_time, [code], [description], overall_result_code
			 , CASE WHEN CHARINDEX('remit_execution_',download_file_name) > 0 THEN 39405
					WHEN CHARINDEX('remit_non_standard_',download_file_name) > 0 THEN 39400
					WHEN CHARINDEX('remit_standard_',download_file_name) > 0 THEN 39401
					ELSE 39400
			  END
			, download_file_name
		FROM #temp_ack_xml_data
		WHERE CHARINDEX('remit_',download_file_name) > 0

		SELECT @process_id = dbo.FNAGETNEWID()
		SELECT @user_name  = dbo.FNAdbuser()
		SELECT @file_name = 'ECM_Remit_ACK_Feedback_' + CONVERT(VARCHAR(30), GETDATE(),112) + REPLACE(CONVERT(VARCHAR(30), GETDATE(),108),':','') + '.csv'

		SELECT @process_table = dbo.FNAProcessTableName('ecm_remit_ack_feedback_', dbo.FNADBUser(), @process_id) 
		SELECT @server_location = document_path
		FROM connection_string 
		SELECT @full_file_path = @server_location + '\temp_Note\' + @file_name

		EXEC('SELECT [message_id] ,[reference_id]  ,[code] ,REPLACE(REPLACE(REPLACE([description],'','','' ''), CHAR(13), ''''), CHAR(10), '''')  [description] ,[overall_result_code]
			  INTO ' + @process_table + ' FROM #temp_ack_xml_data')

		IF EXISTS(SELECT 1 FROM #temp_ack_xml_data temp
				WHERE temp.overall_result_code = 'Error'
		)
		BEGIN
			EXEC spa_export_to_csv @process_table, @full_file_path, 'y', ',', 'n','y','n','n',@output_result OUTPUT
			INSERT INTO source_system_data_import_status (process_id, code, module, source, type, description)
			SELECT @process_id, temp.overall_result_code, 'ECM Remit ACK Feedback', 'ECM Remit ACK Feedback', 'Error', temp.description
			FROM #temp_ack_xml_data temp
			WHERE temp.overall_result_code = 'Error'
			SELECT @url = '../../adiha.php.scripts/dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
			SELECT @desc_success = 'ECM Remit ACK Feedback captured with error. <a target="_blank" href="' + @url + '">Click here.</a>'
		END
		ELSE
		BEGIN
			EXEC spa_export_to_csv @process_table, @full_file_path, 'y', ',', 'n','y','n','n',@output_result OUTPUT
			SET @desc_success = 'ECM Remit ACK Feedback  captured successfully.<br>'
								+  '<b>Response :</b> ' + 'Success'
		END

		INSERT INTO message_board(user_login_id, source, [description], url_desc, url, [type], job_name, as_of_date, process_id, process_type)
		SELECT DISTINCT au.user_login_id, 'ECM Remit ACK Feedback' , ISNULL(@desc_success, 'Description is null'), NULL, NULL, 's',NULL, NULL,@process_id,NULL
		FROM dbo.application_role_user aru
		INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
		INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
		WHERE (au.user_active = 'y') AND (asr.role_type_value_id = 22) AND au.user_emal_add IS NOT NULL
		GROUP BY au.user_login_id, au.user_emal_add	

		INSERT INTO email_notes
			(
				notes_subject,
				notes_text,
				send_from,
				send_to,
				send_status,
				active_flag,
				attachment_file_name
			)		
		SELECT DB_NAME() + ': ECM Remit ACK Feedback',
			'Dear <b>' + MAX(au.user_l_name) + '</b><br><br>

			 ECM Remit ACK Feedback has been captured. Please check the Summary Report attached in email.',
			'noreply@pioneersolutionsglobal.com',
			au.user_emal_add,
			'n',
			'y',
			@full_file_path
		FROM dbo.application_role_user aru
		INNER JOIN dbo.application_security_role asr ON aru.role_id = asr.role_id 
		INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
		WHERE (au.user_active = 'y') AND (asr.role_type_value_id = 22) AND au.user_emal_add IS NOT NULL
		GROUP BY au.user_login_id, au.user_emal_add
	END
END
GO