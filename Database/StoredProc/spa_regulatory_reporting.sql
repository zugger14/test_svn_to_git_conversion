IF OBJECT_ID (N'[dbo].[spa_regulatory_reporting]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_regulatory_reporting]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_regulatory_reporting]
	@flag CHAR(3) = 'GEN',
	@form_xml XML = NULL,
	@submission_type INT = NULL,
	@report_type INT = NULL,
	@mirror_reporting BIT = NULL,
	@intragroup BIT = NULL,
	@emir_level VARCHAR(10) = NULL,
	@mifid_level VARCHAR(10) = NULL,
	@process_id VARCHAR(100) = NULL
AS

/*----------------DEBUG SECTION-------------------
DECLARE @flag CHAR(3) = 'GEN',
		@form_xml XML = NULL,
		@submission_type INT = NULL,
		@report_type INT = NULL,
		@mirror_reporting BIT = NULL,
		@intragroup BIT = NULL,
		@emir_level VARCHAR(10) = NULL,
		@mifid_level VARCHAR(10) = NULL,
		@process_id VARCHAR(100) = NULL

SELECT @flag='GEN',@form_xml='<Root><FormXML  create_date_from="2019-06-02" create_date_to="2019-06-03" submission_type="44702" report_type="39405" deal_date_from="" deal_date_to="" generate_uti="y" action_type_error="n" level="" action_type="" valuation_date="" level_mifid="" action_type_mifid="" include_bfi="n" ></FormXML></Root>'
------------------------------------------------*/
SET NOCOUNT ON

IF @flag = 'GEN'
BEGIN
	DECLARE @idoc INT,
			@ssbm_table_name VARCHAR(120),
			@deal_header_table_name VARCHAR(120),
			@deal_detail_table_name VARCHAR(120),
			@exec_call VARCHAR(MAX),
			@filter_table_process_id VARCHAR(100) = dbo.FNAGetNewID(),
			@filter_counterparty_id VARCHAR(MAX),
			@filter_contract_id VARCHAR(MAX),
			@filter_commodity_id VARCHAR(MAX),
			@filter_sub_book_id VARCHAR(MAX)

	SET @ssbm_table_name = dbo.FNAProcessTableName('ssbm', dbo.FNADBUser(), @filter_table_process_id)
	SET @deal_header_table_name = dbo.FNAProcessTableName('deal_header', dbo.FNADBUser(), @filter_table_process_id)
	SET @deal_detail_table_name = dbo.FNAProcessTableName('deal_detail', dbo.FNADBUser(), @filter_table_process_id)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml

	IF OBJECT_ID ('tempdb..#form_data') IS NOT NULL
		DROP TABLE #form_data

	CREATE TABLE #form_data (
		create_date_from VARCHAR(200) COLLATE DATABASE_DEFAULT,
		create_date_to VARCHAR(200) COLLATE DATABASE_DEFAULT,
		submission_type VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_date_from VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_date_to VARCHAR(200) COLLATE DATABASE_DEFAULT,
		report_type VARCHAR(200) COLLATE DATABASE_DEFAULT,		
		generate_uti VARCHAR(200) COLLATE DATABASE_DEFAULT,
		action_type_error VARCHAR(200) COLLATE DATABASE_DEFAULT,
		level VARCHAR(200) COLLATE DATABASE_DEFAULT,
		action_type VARCHAR(200) COLLATE DATABASE_DEFAULT,
		valuation_date VARCHAR(200) COLLATE DATABASE_DEFAULT,
		level_mifid VARCHAR(200) COLLATE DATABASE_DEFAULT,
		action_type_mifid VARCHAR(200) COLLATE DATABASE_DEFAULT,
		include_bfi VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		commodity_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		counterparty_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		contract_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		subsidiary_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		strategy_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		book_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		subbook_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #form_data
	SELECT NULLIF(create_date_from, ''), NULLIF(create_date_to, ''), NULLIF(submission_type, ''), NULLIF(deal_date_from, ''),
		   NULLIF(deal_date_to, ''), NULLIF(report_type, ''), NULLIF(generate_uti, ''), NULLIF(action_type_error, ''),
		   NULLIF(level, ''), NULLIF(action_type, ''), NULLIF(valuation_date, ''),
		   NULLIF(level_mifid, ''), NULLIF(action_type_mifid, ''), NULLIF(include_bfi, ''), NULLIF(deal_id, ''), NULLIF(commodity_id, ''),
		   NULLIF(counterparty_id, ''), NULLIF(contract_id, ''),NULLIF(subsidiary_id, ''), NULLIF(strategy_id, ''), NULLIF(book_id, ''), NULLIF(subbook_id, '')
	FROM OPENXML(@idoc, '/Root/FormXML', 1)
	WITH #form_data

	SELECT @filter_counterparty_id = counterparty_id
			,@filter_contract_id = contract_id
			,@filter_commodity_id = commodity_id
			,@filter_sub_book_id = subbook_id
			,@report_type = report_type
			,@submission_type = ISNULL(@submission_type, submission_type)
	FROM #form_data

	IF OBJECT_ID('tempdb..#temp_submission_rule') IS NOT NULL
		DROP TABLE #temp_submission_rule
	CREATE TABLE #temp_submission_rule (
		rule_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		submission_type_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		confirmation_type VARCHAR(200) COLLATE DATABASE_DEFAULT,
		legal_entity_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		sub_book_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		contract_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		counterparty_id2 VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_type_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_sub_type_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_template_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		commodity_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		location_group_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		location_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		counterparty_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		counterpaty_type VARCHAR(200) COLLATE DATABASE_DEFAULT,
		index_group VARCHAR(200) COLLATE DATABASE_DEFAULT,
		entity_type VARCHAR(200) COLLATE DATABASE_DEFAULT,
		curve_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		buy_sell VARCHAR(200) COLLATE DATABASE_DEFAULT,
		confirm_status_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_status_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		physical_financial_flag VARCHAR(200) COLLATE DATABASE_DEFAULT,
		create_date_from VARCHAR(200) COLLATE DATABASE_DEFAULT,
		create_date_to VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_date_from VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_date_to VARCHAR(200) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #temp_submission_rule
	SELECT rule_id, submission_type_id, confirmation_type, legal_entity_id, ssr.sub_book_id, ssr.contract_id, counterparty_id2, deal_type_id,
		   deal_sub_type_id, deal_template_id, ssr.commodity_id, location_group_id, location_id, ssr.counterparty_id, counterpaty_type,
		   index_group, entity_type, curve_id, buy_sell, confirm_status_id, deal_status_id, fd.deal_id, physical_financial_flag, create_date_from,
		   create_date_to, deal_date_from, deal_date_to
	FROM setup_submission_rule ssr
	INNER JOIN #form_data fd ON fd.submission_type = ssr.submission_type_id
	
	IF NOT EXISTS (SELECT 1 FROM #temp_submission_rule)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Source Remit table', 'spa_regulatory_reporting', 'Error', 'No rules defined to generate report.', 'Error' 
		RETURN
	END

	IF OBJECT_ID('tempdb..#books') IS NOT NULL
		DROP TABLE #books

	CREATE TABLE #books(
		sub_id INT, 
		stra_id INT, 
		book_id INT, 
		sub VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		stra VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		book VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		source_system_book_id1 INT, 
		source_system_book_id2 INT, 
		source_system_book_id3 INT, 
		source_system_book_id4 INT, 
		logical_name VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		sub_book_id INT, 
		counterparty_id INT
	)

	IF EXISTS(SELECT 1 FROM #temp_submission_rule WHERE NULLIF(sub_book_id, '') IS NULL)
	BEGIN
		INSERT INTO #books
		SELECT sub.entity_id sub_id,
			   stra.entity_id stra_id,
			   book.entity_id book_id,
			   sub.entity_name AS sub,
			   stra.entity_name AS stra,
			   book.entity_name AS book,
			   ssbm.source_system_book_id1, 
			   ssbm.source_system_book_id2, 
			   ssbm.source_system_book_id3, 
			   ssbm.source_system_book_id4,
			   ssbm.logical_name,
			   ssbm.book_deal_type_map_id [sub_book_id],
			   ISNULL(fs1.counterparty_id,fs2.counterparty_id) counterparty_id
		FROM portfolio_hierarchy book
		INNER JOIN Portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id
		INNER JOIN portfolio_hierarchy sub ON stra.parent_entity_id = sub.entity_id
		INNER JOIN source_system_book_map ssbm ON  ssbm.fas_book_id = book.entity_id
		LEFT OUTER JOIN fas_subsidiaries fs1 ON fs1.fas_subsidiary_id =  stra.parent_entity_id
		LEFT OUTER JOIN fas_subsidiaries fs2 ON fs2.fas_subsidiary_id =  -1
	END
	ELSE
	BEGIN
		IF @filter_sub_book_id IS NOT NULL
		BEGIN
			SELECT @filter_sub_book_id = @filter_sub_book_id + ','  + STUFF((SELECT DISTINCT ',' +  sub_book_id FROM #temp_submission_rule
											FOR XML PATH('')), 1, 1, '') 
		END

		INSERT INTO #books
		SELECT sub.entity_id sub_id,
			   stra.entity_id stra_id,
			   book.entity_id book_id,
			   sub.entity_name AS sub,
			   stra.entity_name AS stra,
			   book.entity_name AS book,
			   ssbm.source_system_book_id1, 
			   ssbm.source_system_book_id2, 
			   ssbm.source_system_book_id3, 
			   ssbm.source_system_book_id4,
			   ssbm.logical_name,
			   ssbm.book_deal_type_map_id [sub_book_id],
			   ISNULL(fs1.counterparty_id,fs2.counterparty_id) counterparty_id
		FROM portfolio_hierarchy book
		INNER JOIN Portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id
		INNER JOIN portfolio_hierarchy sub ON stra.parent_entity_id = sub.entity_id
		INNER JOIN source_system_book_map ssbm ON  ssbm.fas_book_id = book.entity_id
		LEFT OUTER JOIN fas_subsidiaries fs1 ON fs1.fas_subsidiary_id =  stra.parent_entity_id
		LEFT OUTER JOIN fas_subsidiaries fs2 ON fs2.fas_subsidiary_id =  -1
		INNER JOIN (SELECT DISTINCT sub_book_id FROM #temp_submission_rule) s ON ssbm.book_deal_type_map_id = s.sub_book_id
	END
	
	IF OBJECT_ID ('tempdb..#source_deal_header') IS NOT NULL
		DROP TABLE #source_deal_header

	CREATE TABLE #source_deal_header (
		[source_deal_header_id] INT NOT NULL,
		[deal_id] VARCHAR(200) NOT NULL,
		[template_id] INT NULL,
		[counterparty_id] INT NOT NULL,
		[sub_book_id] INT NULL,
		[deal_date] DATETIME NOT NULL,
		[physical_financial_flag] CHAR(10) NOT NULL,
		[entire_term_start] DATETIME NOT NULL,
		[entire_term_end] DATETIME NOT NULL,
		[source_deal_type_id] INT NOT NULL,
		[deal_sub_type_type_id] INT NULL,
		[option_flag] CHAR(1) NOT NULL,
		[option_type] CHAR(1) NULL,
		[option_excercise_type] CHAR(1) NULL,
		[header_buy_sell_flag] VARCHAR(1) NULL,
		[create_ts] DATETIME NULL,
		[update_ts] DATETIME NULL,
		[internal_desk_id] INT NULL,
		[product_id] INT NULL,
		[commodity_id] INT NULL,
		[block_define_id] INT NULL,
		[deal_status] INT NULL,
		[description1] VARCHAR(2000) NULL,
		[description2] VARCHAR(100) NULL,
		[source_trader_id] INT NOT NULL,
		[contract_id] INT NULL,
		[deal_group_id] INT NOT NULL,
		[ext_deal_id] VARCHAR(50) NULL,
		[confirm_status] VARCHAR(500) NULL,
		[commodity_name] VARCHAR(1000) NULL,
		[term_frequency] NCHAR(2) COLLATE DATABASE_DEFAULT,
		[profile_granularity] INT

	) 
	
	DECLARE @rule_id INT, @submission_type_id INT, @confirmation_type INT, @legal_entity_id INT, @sub_book_id INT, @contract_id INT, @counterparty_id2 INT, @deal_type_id INT,
			@deal_sub_type_id INT, @deal_template_id INT, @commodity_id INT, @location_group_id INT, @location_id INT, @counterparty_id INT, @counterpaty_type CHAR(1),
			@index_group INT, @entity_type INT, @curve_id INT, @buy_sell CHAR(1), @confirm_status_id INT, @deal_status_id INT, @deal_id VARCHAR(1000) , @physical_financial_flag CHAR(1), @create_date_from VARCHAR(10), @create_date_to VARCHAR(10), @deal_date_from VARCHAR(10), @deal_date_to VARCHAR(10)

	DECLARE @insert_deal CURSOR
	SET @insert_deal = CURSOR FOR
	SELECT rule_id, submission_type_id, confirmation_type, legal_entity_id, sub_book_id, contract_id, counterparty_id2, deal_type_id, 
		   deal_sub_type_id, deal_template_id, commodity_id, location_group_id, location_id, counterparty_id, counterpaty_type, index_group,
		   entity_type, curve_id, buy_sell, confirm_status_id, deal_status_id, deal_id, physical_financial_flag, create_date_from, create_date_to,
		   deal_date_from, deal_date_to
 
	FROM #temp_submission_rule
	OPEN @insert_deal
	FETCH NEXT
	FROM @insert_deal INTO @rule_id, @submission_type_id, @confirmation_type, @legal_entity_id, @sub_book_id, @contract_id, @counterparty_id2, @deal_type_id, @deal_sub_type_id, @deal_template_id, @commodity_id, @location_group_id, @location_id, @counterparty_id, @counterpaty_type, @index_group, @entity_type, @curve_id, @buy_sell, @confirm_status_id, @deal_status_id, @deal_id, @physical_financial_flag, @create_date_from , @create_date_to , @deal_date_from , @deal_date_to 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @exec_call = '
			INSERT INTO #source_deal_header
			SELECT DISTINCT sdh.source_deal_header_id source_deal_header_id, sdh.deal_id deal_id, sdh.template_id template_id, sdh.counterparty_id counterparty_id, books.sub_book_id sub_book_id,
					sdh.deal_date deal_date, sdh.physical_financial_flag physical_financial_flag, sdh.entire_term_start entire_term_start, sdh.entire_term_end entire_term_end, sdh.source_deal_type_id source_deal_type_id,
					sdh.deal_sub_type_type_id deal_sub_type_type_id, sdh.option_flag option_flag, sdh.option_type option_type, sdh.option_excercise_type option_excercise_type, sdh.header_buy_sell_flag header_buy_sell_flag,
					sdh.create_ts create_ts, sdh.update_ts update_ts, sdh.internal_desk_id internal_desk_id, sdh.product_id product_id, sdh.commodity_id commodity_id, sdh.block_define_id block_define_id,
					sdh.deal_status deal_status, sdh.description1 description1, sdh.description2 description2, sdh.trader_id source_trader_id, sdh.contract_id contract_id, 0 deal_group_id, sdh.ext_deal_id ext_deal_id, sdv.code confirm_status, sc1.commodity_id commodity_name, sdh.term_frequency, sdh.profile_granularity
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
			LEFT JOIN static_data_value sdv ON sdv.value_id = sdh.confirm_status_type
			INNER JOIN #books books ON books.source_system_book_id1 = sdh.source_system_book_id1
				AND books.source_system_book_id2 = sdh.source_system_book_id2
				AND books.source_system_book_id3 = sdh.source_system_book_id3
				AND books.source_system_book_id4 = sdh.source_system_book_id4
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
			LEFT JOIN #source_deal_header td ON td.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN source_commodity sc1
				ON sc1.source_commodity_id = sdh.commodity_id
			' + 
			  CASE WHEN @submission_type IN (44702, 44705) 
				   THEN ' INNER JOIN deal_status_group dsg
							ON dsg.status_value_id = sdh.deal_status
							AND dsg.status = ''Official'' 
			  
			  ' ELSE '' END 
			+ '
			' + 
			  CASE WHEN @report_type = 39405 
				   THEN ' OUTER APPLY (
							SELECT DISTINCT term_start
							FROM index_fees_breakdown_settlement
							WHERE source_deal_header_id = sdh.source_deal_header_id
						  )tbl_index_fees 
						  OUTER APPLY (
							SELECT DISTINCT term_start
							FROM source_deal_settlement
							WHERE source_deal_header_id = sdh.source_deal_header_id
						  )tbl_settlement 
			  
			  ' ELSE '' END 
			+ '
			WHERE td.source_deal_header_id IS NULL
		'
		+ IIF(@legal_entity_id IS NOT NULL, ' AND sdh.legal_entity = ' + CAST(@legal_entity_id AS VARCHAR(10)), '')
		+ IIF(@contract_id IS NOT NULL, ' AND sdh.contract_id = ' + CAST(@contract_id AS VARCHAR(10)), '')
		+ IIF(@counterparty_id2 IS NOT NULL, ' AND sdh.counterparty_id2 = ' + CAST(@counterparty_id2 AS VARCHAR(10)), '')
		+ IIF(@deal_type_id IS NOT NULL, ' AND sdh.source_deal_type_id = ' + CAST(@deal_type_id AS VARCHAR(10)), '')
		+ IIF(@deal_sub_type_id IS NOT NULL, ' AND sdh.deal_sub_type_type_id = ' + CAST(@deal_sub_type_id AS VARCHAR(10)), '')
		+ IIF(@deal_template_id IS NOT NULL, ' AND sdh.template_id = ' + CAST(@deal_template_id AS VARCHAR(10)), '')
		+ IIF(@commodity_id IS NOT NULL, ' AND sdh.commodity_id = ' + CAST(@commodity_id AS VARCHAR(10)), '')
		+ IIF(@location_group_id IS NOT NULL, ' AND sml.source_major_location_ID = ' + CAST(@location_group_id AS VARCHAR(10)), '')
		+ IIF(@location_id IS NOT NULL, ' AND sdd.location_id = ' + CAST(@location_id AS VARCHAR(10)), '')
		+ IIF(@counterparty_id IS NOT NULL, ' AND sdh.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(10)), ' AND 1 = 2')
		+ IIF(@counterpaty_type IS NOT NULL, ' AND sc.int_ext_flag = ''' + CAST(@counterpaty_type AS VARCHAR(10)) + '''', '')
		+ IIF(@index_group IS NOT NULL, ' AND spcd.index_group = ' + CAST(@index_group AS VARCHAR(10)), '')
		+ IIF(@curve_id IS NOT NULL, ' AND sdd.curve_id = ' + CAST(@curve_id AS VARCHAR(10)), '')
		+ IIF(@buy_sell IS NOT NULL, ' AND sdh.header_buy_sell_flag = ''' + CAST(@buy_sell AS VARCHAR(10)) + '''', '')
		+ IIF(@entity_type IS NOT NULL, ' AND sc.type_of_entity = ' + CAST(@legal_entity_id AS VARCHAR(10)), '')
		+ IIF(@confirm_status_id IS NOT NULL, ' AND sdh.confirm_status_type = ' + CAST(@confirm_status_id AS VARCHAR(10)), '')
		+ IIF(@deal_status_id IS NOT NULL, ' AND sdh.deal_status = ' + CAST(@deal_status_id AS VARCHAR(10)), '')
		+ IIF(NULLIF(@deal_id,'') IS NOT NULL, ' AND sdh.source_deal_header_id IN (' + CAST(@deal_id AS VARCHAR(1000)) + ')', '')
		+ IIF(@filter_counterparty_id IS NOT NULL, ' AND sdh.counterparty_id IN (' + CAST(@filter_counterparty_id AS VARCHAR(MAX)) + ')', '')
		+ IIF(@filter_contract_id IS NOT NULL, ' AND sdh.contract_id IN (' + CAST(@filter_contract_id AS VARCHAR(MAX)) + ')', '')
		+ IIF(@filter_commodity_id IS NOT NULL, ' AND sdh.commodity_id IN (' + CAST(@filter_commodity_id AS VARCHAR(MAX)) + ')', '')
		+ IIF(@physical_financial_flag IS NOT NULL, ' AND sdh.physical_financial_flag = ''' + CAST(@physical_financial_flag AS CHAR(1)) + '''', '') 
		+ IIF(@deal_date_from IS NOT NULL, ' AND sdh.deal_date >= ''' + @deal_date_from + '''', '')
		+ IIF(@deal_date_to IS NOT NULL, ' AND sdh.deal_date <= ''' + @deal_date_to + '''', '')
		+ IIF(@create_date_from IS NOT NULL , ' AND ' + CASE WHEN @submission_type = 44702 AND @report_type = 39405 THEN 'CAST(COALESCE(tbl_index_fees.term_start,tbl_settlement.term_start,sdh.update_ts,sdh.create_ts) AS DATE)' ELSE 'CAST(COALESCE(sdh.update_ts,sdh.create_ts) AS DATE)' END  + ' >= ''' + @create_date_from + '''', '')
		+ IIF(@create_date_to IS NOT NULL ,' AND ' + CASE WHEN @submission_type = 44702 AND @report_type = 39405 THEN 'CAST(COALESCE(tbl_index_fees.term_start,tbl_settlement.term_start,sdh.update_ts,sdh.create_ts) AS DATE)' ELSE 'CAST(COALESCE(sdh.update_ts,sdh.create_ts) AS DATE)' END  + ' <= ''' + @create_date_to + '''', '')
		+ CASE WHEN @submission_type = 44702 AND @report_type = 39401 THEN ' AND sdd.fixed_price IS NOT NULL'
			   WHEN @submission_type = 44702 AND @report_type = 39400 THEN ' AND sdd.fixed_price IS NULL'
			   ELSE ' '
		  END

		EXEC(@exec_call)

		IF @submission_type = 44702 --REMIT
		BEGIN
			DELETE td
			FROM #source_deal_header td
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = td.source_deal_header_id
			LEFT JOIN maintain_udf_static_data_detail_values musddv
				ON musddv.primary_field_object_id = sdh.broker_id
			LEFT JOIN application_ui_template_fields autf
				ON autf.application_field_id = musddv.application_field_id
			LEFT JOIN user_defined_fields_template udft
				ON udft.udf_template_id = autf.udf_template_id
			WHERE udft.Field_label = 'Delegation Reporting'
			AND ISNULL(musddv.static_data_udf_values, 'n') = 'y'
		END

		FETCH NEXT
		FROM @insert_deal INTO @rule_id, @submission_type_id, @confirmation_type, @legal_entity_id, @sub_book_id, @contract_id, @counterparty_id2, @deal_type_id, 
							   @deal_sub_type_id, @deal_template_id, @commodity_id, @location_group_id, @location_id, @counterparty_id, @counterpaty_type, @index_group,
							   @entity_type, @curve_id, @buy_sell, @confirm_status_id, @deal_status_id, @deal_id, @physical_financial_flag,  @create_date_from , @create_date_to , @deal_date_from , @deal_date_to 
	END
	CLOSE @insert_deal
	DEALLOCATE @insert_deal
	
	EXEC ('
		IF OBJECT_ID(''' + @ssbm_table_name + ''') IS NOT NULL
			DROP TABLE ' + @ssbm_table_name + '

		SELECT * 
		INTO ' + @ssbm_table_name + '
		FROM #books
	')
	
	EXEC ('
		IF OBJECT_ID(''' + @deal_header_table_name + ''') IS NOT NULL
			DROP TABLE ' + @deal_header_table_name + '

		SELECT * 
		INTO ' + @deal_header_table_name + '
		FROM #source_deal_header

		CREATE INDEX indx_deal_id ON ' + @deal_header_table_name + ' (source_deal_header_id)
	')
	
	EXEC ('
		IF OBJECT_ID(''' + @deal_detail_table_name + ''') IS NOT NULL
			DROP TABLE ' + @deal_detail_table_name + '

		SELECT td.source_deal_header_id, sdd.source_deal_detail_id, sdd.term_start, sdd.term_end, sdd.leg, sdd.fixed_float_leg, sdd.buy_sell_flag, sdd.curve_id, sdd.location_id, sdd.physical_financial_flag, 
				IIF(sdh.internal_desk_id IN (17301,17302), sdd.total_volume, sdd.deal_volume) deal_volume, sdd.total_volume, sdd.standard_yearly_volume, sdd.deal_volume_frequency, sdd.deal_volume_uom_id, sdd.multiplier, sdd.volume_multiplier2, sdd.fixed_price, 
				sdd.fixed_price_currency_id, sdd.option_strike_price, sdd.fixed_cost, sdd.formula_id, sdd.formula_curve_id, sdd.price_adder, sdd.price_multiplier, sdd.adder_currency_id, 
				sdd.fixed_cost_currency_id, formula_currency_id, price_adder2, price_adder_currency2, sdd.price_uom_id, sdd.contract_expiration_date, sdd.position_uom
		INTO ' + @deal_detail_table_name + '
		FROM #source_deal_header td
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = td.source_deal_header_id
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = td.source_deal_header_id
		LEFT JOIN source_price_curve_def spcd_fixed
			ON spcd_fixed.source_curve_def_id = sdd.formula_curve_id
		LEFT JOIN static_data_value sdv_spcd_fixed_gran
			ON sdv_spcd_fixed_gran.value_id = spcd_fixed.Granularity
		LEFT JOIN source_uom su_deal_volume_uom
			ON su_deal_volume_uom.source_uom_id = sdd.deal_volume_uom_id

		CREATE INDEX indx_deal_detail_id ON ' + @deal_detail_table_name + ' (source_deal_header_id)
	')
	
	IF OBJECT_ID('tempdb..#deal_rows') IS NOT NULL
		DROP TABLE #deal_rows

	SELECT 1 [rows] INTO #deal_rows FROM static_data_value WHERE 1 = 2

	EXEC('
		IF EXISTS (SELECT 1 FROM ' + @deal_header_table_name + ')
		BEGIN
			INSERT INTO #deal_rows
			SELECT 1
		END
	')

	IF NOT EXISTS (SELECT 1 FROM #deal_rows)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Source Remit table', 'spa_remit', 'Error', 'No deals to generate report.', 'Error' 
		RETURN
	END

	IF @submission_type = 44702 --REMIT
	BEGIN
		EXEC ('
			TRUNCATE TABLE #deal_rows
			INSERT INTO #deal_rows
			SELECT COUNT(1) FROM ' + @deal_header_table_name + '
		')
	
		IF EXISTS (SELECT 1 FROM #deal_rows WHERE [rows] > 1) AND
		   EXISTS (SELECT 1 FROM #form_data WHERE report_type = 39402)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Source Remit table', 'spa_remit', 'Error', 'Please only select one deal to generate transport REMIT report.', 'Error'
			RETURN
		END

		SELECT @exec_call = ' 
			EXEC spa_remit @create_date_from=''' + create_date_from + ''', @create_date_to=''' + create_date_to + ''', @generate_uti=' + ISNULL(IIF(generate_uti = 'y', '1', '0'), '') + ',
						   @report_type=''' + ISNULL(report_type, '') + ''', @flag=''i'', @cancellation=' + ISNULL(IIF(action_type_error = 'y', '1', '0'), '') + ', @force_process=0,
						   @include_bfi=''' + ISNULL(IIF(include_bfi = 'y', '1', '0'), '') + ''', @submission_type=''' + ISNULL(submission_type, '') + ''', @filter_table_process_id=''' + @filter_table_process_id + '''
			'
		FROM #form_data
		
		EXEC (@exec_call)
	END
	ELSE IF @submission_type IN (44703, 44704) --EMIR and MiFID II
	BEGIN
		SELECT @exec_call = '
			EXEC spa_source_emir @create_date_from=''' + create_date_from + ''', @create_date_to=''' + create_date_to + ''', @flag=''i'', @submission_type=' + submission_type + ', @action_type=''' + ISNULL(action_type, '') + ''',
								 @level=''' + ISNULL([level], '') + ''', @action_type_mifid=''' + ISNULL(action_type_mifid, '') + ''', @level_mifid=''' + ISNULL([level_mifid], '') + ''',
								 @deal_date_from=''' + ISNULL(deal_date_from, '') + ''', @deal_date_to=''' + ISNULL(deal_date_to, '') + ''', @valuation_date=''' + ISNULL(valuation_date, '') + ''',
								 @filter_table_process_id=''' + @filter_table_process_id + ''''
		FROM #form_data
	
		EXEC (@exec_call)
	END
	ELSE IF @submission_type = 44705
	BEGIN
		SELECT @exec_call = '
			EXEC spa_ecm @flag=''i'', @create_date_from=''' + ISNULL(create_date_from, '') + ''', @create_date_to=''' + ISNULL(create_date_to, '') + ''',
						 @include_bfi=''' + ISNULL(IIF(include_bfi = 'y', '1', '0'), '0') + ''', @filter_table_process_id=''' + @filter_table_process_id + '''' 
		FROM #form_data

		EXEC(@exec_call)
	END
	ELSE IF @submission_type = 44701 -- ICE Trade Vault
	BEGIN
		SELECT @exec_call = 'EXEC spa_ice_trade_vault @flag = ''i'',
													  @create_date_from=''' + create_date_from + ''',
													  @create_date_to=''' + create_date_to + ''',
													  @filter_table_process_id=''' + @filter_table_process_id + '''' 
		FROM #form_data

		EXEC(@exec_call)
	END
END
ELSE IF @flag = 'XML'
BEGIN
	BEGIN TRY
		DECLARE @status VARCHAR(100),
				@export_xml VARCHAR(MAX),
				@xml_file_path VARCHAR(1000),
				@sql VARCHAR(MAX)

		SELECT @xml_file_path = document_path + '\temp_Note\' + @process_id + '.xml'
		FROM connection_string
		
		IF @submission_type = 44702
		BEGIN
			EXEC spa_convert_xml @process_id = @process_id,
								 @report_type = @report_type,
								 @mirror_reporting = @mirror_reporting,
								 @intragroup = @intragroup,
								 @call_from_export = 1,
								 @xml_out = @export_xml OUTPUT			
		END
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#xml_table') IS NOT NULL
				DROP TABLE #xml_table

			CREATE TABLE #xml_table (
				xml_data NVARCHAR(MAX)
			)

			SET @sql = '
				DECLARE @xml_data NVARCHAR(MAX)

				SET @xml_data = CAST((
					SELECT * 
					FROM ' + CASE WHEN @submission_type = 44701 THEN 'source_ice_trade_vault'
								  WHEN @submission_type = 44703 THEN IIF(@emir_level = 'C', 'source_emir_collateral', 'source_emir')
								  WHEN @submission_type = 44704 THEN IIF(@mifid_level = 'X', 'source_mifid', 'source_mifid_trade')
								  WHEN @submission_type = 44705 THEN 'source_ecm'
							 END +
					'
					WHERE process_id = ''' + @process_id + '''
					FOR XML PATH('''')
				) AS VARCHAR(MAX))

				INSERT INTO #xml_table
				SELECT ''<?xml version="1.0" encoding="UTF-8"?><Root>'' + @xml_data + ''</Root>''
			'
			
			EXEC (@sql)

			SELECT @export_xml = xml_data
			FROM #xml_table
		END
		
		EXEC spa_write_to_file @export_xml , 'n', @xml_file_path, @status OUTPUT

		IF @status = 1
		BEGIN
			EXEC spa_ErrorHandler 0, 'Regulatory Submission', 'spa_source_remit', 'Success', 'XML Generated.', @process_id
		END
		
	END TRY
	BEGIN CATCH
		DECLARE @err VARCHAR(MAX)
		SET @err = 'Error Occurred<a href="#" onclick="$(this).next(''div'').toggle();"><br/><font size=1>Technical Details.</font></a>'		
		SET @err += '<div style="font-size:10px;color:red;display:none;" id="target"><b><i>' + ERROR_MESSAGE() + '</i></b></div>'
		EXEC spa_ErrorHandler -1, 'Regulatory Submission', 'spa_remit', 'Error', @err, @process_id
	END CATCH
END

