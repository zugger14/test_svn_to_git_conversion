IF OBJECT_ID(N'[dbo].[spa_create_inventory_assignment_deals]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_create_inventory_assignment_deals]
GO

CREATE PROCEDURE [dbo].[spa_create_inventory_assignment_deals]  
	@temp_table_name VARCHAR(200) = NULL,
	@template_id VARCHAR(MAX) = NULL,
	@table_name VARCHAR(100) = NULL
AS 
	
/*----------------Debug Section------------------
DECLARE @temp_table_name VARCHAR(200) = 'adiha_process.dbo.rec_inventory_deal_4715DEB2_BAA8_4580_89D4_FF9F7E155C10',
		@template_id VARCHAR(MAX) = '2732,2757',
		@table_name VARCHAR(100) = 'ixp_rec_inventory'

--SELECT @temp_table_name = 'adiha_process.dbo.rec_inventory_deal_ABC9DBB5_F961_4F3A_8BED_01729FB6B3CB', @template_id = '2732,2757', @table_name = 'ixp_rec_inventory'
-----------------------------------------------*/
SET NOCOUNT ON
BEGIN
	DECLARE @temp_table VARCHAR(100), 
			@sql_stmt VARCHAR(MAX),
			@rule_id INT,
			@user_login_id VARCHAR(100),
			@process_id VARCHAR(200),
			@column_list VARCHAR(5000),
			@debug_mode CHAR(1)
	
	IF OBJECT_ID(@temp_table) IS NOT NULL
		EXEC('DROP TABLE ' + @temp_table)

	IF OBJECT_ID('tempdb..#meter_id') IS NOT NULL
		DROP TABLE #meter_id
	 
	SET @user_login_id = dbo.FNADBUser() 
	SET @process_id = REPLACE(NEWID(), '-', '_') 
	  
	SET @temp_table = dbo.FNAProcessTableName('deal_invoice', @user_login_id, @process_id)
	
	IF OBJECT_ID('tempdb..#temp_table') IS NOT NULL
		DROP TABLE #temp_table

	CREATE TABLE #temp_table(  
		temp_id INT IDENTITY(1,1),  
		meter_id INT,
		from_date DATETIME,  
		to_date DATETIME,  
		allocation_per FLOAT,
		vol_diff FLOAT,
		volume NUMERIC(38,20),  
		uom_id INT,  
		generator_id INT,
		template_id INT ,
		deal_id VARCHAR(200)  COLLATE DATABASE_DEFAULT,
		counterparty_id INT,
		ppa_contract_id INT,
		fas_sub_book_id INT
	)

	IF @table_name = 'ixp_import_rec_meters'
	BEGIN
		SET @debug_mode = 'n'

		CREATE TABLE #meter_id (
			recorderid VARCHAR(100) COLLATE DATABASE_DEFAULT, 
			channel INT, 
			prod_month DATETIME
		)
	
		 SET @sql_stmt = '
			INSERT INTO #meter_id(recorderid, channel, prod_month)
			SELECT DISTINCT t.meter_id, 
							t.channel,
							CONVERT(VARCHAR(7), dbo.FNAClientToSqlDate(t.[date]), 120) + ''-01'' AS prod_month
			FROM ' + @temp_table_name + ' t
			INNER JOIN meter_id mi
				ON mi.recorderid = t.meter_id
			INNER JOIN recorder_generator_map rgm
				ON rgm.meter_id = mi.meter_id
			 '
	 
		EXEC(@sql_stmt)	 
		
		INSERT INTO #temp_table
		SELECT MAX(mi.meter_id) meter_id,
			   MIN(CAST(mvd.from_date AS DATETIME)) from_date,
			   MAX(CAST(mvd.to_date AS DATETIME)) to_date,
			   rgm.allocation_per,
			   (rgm.to_vol - rgm.from_vol) + 1 vol_diff,
			   CASE WHEN rgm.allocation_per IS NULL THEN MAX(mvd.volume) ELSE SUM(mvd.volume * ISNULL(rgm.allocation_per, 1.0)) END,
			   MAX(ISNULL(rp.uom_id, mi.source_uom_id)) uom_id,
			   rgm.generator_id,
			   i.item template_id,
			   'Meter_' + REPLACE(rg.name, ' ', '_') + '_' + REPLACE(dbo.FNAContractMonthFormat(mvd.from_date), '-', '_') deal_id,
			   rg.ppa_counterparty_id,
			   rg.ppa_contract_id,
			   rg.fas_sub_book_id		
		FROM #meter_id m
		INNER JOIN meter_id mi
			ON mi.recorderid = m.recorderid
		INNER JOIN mv90_data mvd
			ON mvd.meter_id = mi.meter_id
				AND mvd.channel = m.channel
				AND m.prod_month = mvd.from_date
		INNER JOIN recorder_properties rp
			ON rp.meter_id = mi.meter_id
				AND rp.channel = m.channel
		LEFT JOIN recorder_generator_map rgm
			ON rgm.meter_id = mi.meter_id
		LEFT JOIN rec_generator rg
			ON rg.generator_id = rgm.generator_id
		LEFT JOIN meter_id_allocation mia
			ON mia.meter_id = mi.meter_id  
				AND mia.production_month = mvd.from_date  
		INNER JOIN dbo.SplitCommaSeperatedValues(@template_id) i
			ON rg.deal_template_id = i.item
		WHERE rgm.effective_date <= m.prod_month	
		GROUP BY rg.fas_sub_book_id, rg.ppa_counterparty_id, mi.meter_id, mvd.gen_date, rgm.allocation_per, rgm.to_vol, rgm.from_vol, dbo.FNAGetContractMonth(CAST(mvd.from_date AS DATETIME)), dbo.FNAGetContractMonth(CAST(mvd.to_date AS DATETIME)), rgm.generator_id, rg.name, dbo.FNAContractMonthFormat(mvd.from_date), i.item, rg.ppa_contract_id
		HAVING SUM(mvd.volume * ISNULL(rgm.allocation_per, 1) * ISNULL(rp.mult_factor, 1) * ISNULL(mia.gre_per, 1)) > 0
		ORDER BY mi.meter_id, rgm.from_vol
				
		DECLARE @meter_volume INT, @temp_id INT, @allocation_per FLOAT, @volume FLOAT, @vol_diff FLOAT, @meter_id INT

		DECLARE @get_meter_volume CURSOR
		SET @get_meter_volume = CURSOR FOR
		SELECT temp_id, allocation_per, volume, vol_diff, meter_id
		FROM #temp_table
		WHERE vol_diff IS NOT NULL
		OPEN @get_meter_volume
		FETCH NEXT
		FROM @get_meter_volume INTO @temp_id, @allocation_per, @volume, @vol_diff, @meter_id

		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE a 
			SET volume =  IIF(@allocation_per IS NOT NULL, @volume, @volume - @vol_diff)	
			FROM #temp_table a 
			WHERE temp_id = @temp_id + 1
				AND meter_id = @meter_id

			FETCH NEXT
			FROM @get_meter_volume INTO @temp_id, @allocation_per, @volume, @vol_diff, @meter_id		
		END
		CLOSE @get_meter_volume
		DEALLOCATE @get_meter_volume

		UPDATE #temp_table
		SET volume = IIF(allocation_per IS NOT NULL, volume, IIF(vol_diff <= volume, vol_diff, volume)) 
	
		IF NOT EXISTS (SELECT 1 FROM #temp_table)
		BEGIN
			EXEC spa_message_board 'i', @user_login_id, NULL, 'BatchReport', 'Meter/Deal Template not mapped in Generator.', '', '', 'e', NULL, '', @process_id, ''
			RETURN
		END
	END
	ELSE IF @table_name = 'ixp_rec_inventory'
	BEGIN		
		SET @debug_mode = 'y'

		IF OBJECT_ID('tempdb..#rec_inventory') IS NOT NULL
			DROP TABLE #rec_inventory

		CREATE TABLE #rec_inventory (
			certificate_seq_from VARCHAR(500) COLLATE DATABASE_DEFAULT,
			certificate_seq_to VARCHAR(500) COLLATE DATABASE_DEFAULT,
			certificate_serial_numbers_from VARCHAR(500) COLLATE DATABASE_DEFAULT,
			certificate_serial_numbers_to VARCHAR(500) COLLATE DATABASE_DEFAULT,
			expiry_date VARCHAR(10) COLLATE DATABASE_DEFAULT,
			generator_id INT,
			generator VARCHAR(500) COLLATE DATABASE_DEFAULT,
			issue_date VARCHAR(10) COLLATE DATABASE_DEFAULT,
			state_value_id INT,
			jurisdiction VARCHAR(500) COLLATE DATABASE_DEFAULT,
			tier_id INT,
			tier VARCHAR(500) COLLATE DATABASE_DEFAULT,
			term_start VARCHAR(10) COLLATE DATABASE_DEFAULT,
			term_end VARCHAR(10) COLLATE DATABASE_DEFAULT,
			vintage INT,
			actual_volume FLOAT,
			source_counterparty_id INT,
			source_certificate_number INT
		)

		EXEC ('
			INSERT INTO #rec_inventory
			SELECT certificate_seq_from, certificate_seq_to, certificate_serial_numbers_from, certificate_serial_numbers_to,
				   expiry_date, generator_id, generator, issue_date, state_value_id, jurisdiction, tier_id, tier, term_start,
				   term_end, vintage, actual_volume, source_counterparty_id, source_certificate_number
			FROM ' + @temp_table_name + '
		')

		INSERT INTO #temp_table		
		SELECT DISTINCT 
			   rgm.meter_id, 
			   ri.term_start, 
			   ri.term_end, 
			   rgm.allocation_per,
			   (rgm.to_vol - rgm.from_vol) + 1 vol_diff, 
			   actual_volume,
			   rg.contract_uom_id uom_id,
			   rg.generator_id,
			   i.item template_id,
			   'Inventory_' + REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(rg.code, sc.counterparty_id + '_' + ISNULL(CAST(ri.source_certificate_number AS VARCHAR(10)),'')), ' ', '_') + '_' + CAST(ri.certificate_seq_from AS VARCHAR(10)) + '_' + CAST(ri.certificate_seq_to AS VARCHAR(10)) + '_' + REPLACE(dbo.FNAContractMonthFormat(ri.term_start), '-', '_'), ' ', '_'), '-', '_'), '__', '_') deal_id,			   
			   ISNULL(ri.source_counterparty_id, rg.ppa_counterparty_id),
			   CASE WHEN ri.source_counterparty_id IS NULL THEN rg.ppa_contract_id ELSE -99999999 END,
			   ISNULL(sdt.sub_book, rg.fas_sub_book_id) fas_sub_book_id		  
	    FROM #rec_inventory ri
		LEFT JOIN recorder_generator_map rgm
			ON ri.generator_id = rgm.generator_id
		LEFT JOIN rec_generator rg
			ON rg.generator_id = ri.generator_id
		LEFT JOIN source_counterparty sc
			ON sc.source_counterparty_id = ri.source_counterparty_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@template_id) i
			ON i.item = IIF(CHARINDEX(',', @template_id) = 0, @template_id, rg.deal_template_id) --done for template_id passed in generic mapping and removed  from rec_generator			
		OUTER APPLY ( SELECT mftd.default_value sub_book
					  FROM maintain_field_template mft
					  INNER JOIN source_deal_header_template  sdht
					  	  ON mft.field_template_id = sdht.field_template_id 
					  INNER JOIN maintain_field_template_detail  mftd
					  	  ON mft.field_template_id = mftd.field_template_id
					  WHERE sdht.template_id = IIF(CHARINDEX(',', @template_id) = 0, @template_id, i.item)
					  	  AND mftd.field_caption  = 'Sub Book'
		) sdt
	END

	SELECT @rule_id = ir.ixp_rules_id
	FROM ixp_rules ir
	WHERE ir.ixp_rules_name = 'REC Deals'
	
	SELECT @column_list = ISNULL(@column_list + ', ', '') + '' + REPLACE(iidm.source_column_name, 'd.', '') + ' ' + ic.column_datatype + ' ' + IIF(column_datatype LIKE '%CHAR%', '  COLLATE DATABASE_DEFAULT', '')
	FROM ixp_tables it
	INNER JOIN ixp_columns ic 
		ON ic.ixp_table_id = it.ixp_tables_id
	INNER JOIN ixp_rules ir 
		ON ir.ixp_rules_name = 'REC Deals'
	INNER JOIN ixp_import_data_mapping iidm
		ON iidm.dest_column = ic.ixp_columns_id
			AND iidm.ixp_rules_id = ir.ixp_rules_id
	WHERE ixp_tables_name = 'ixp_source_deal_template'
		AND NULLIF(iidm.source_column_name, '') IS NOT NULL
		
	EXEC('
		CREATE TABLE ' + @temp_table + '(
			' + @column_list + ',
			import_file_name VARCHAR(1000) COLLATE DATABASE_DEFAULT
		)
	')
		
	SET @sql_stmt= '
		INSERT INTO ' + @temp_table + '(
			[deal id], [deal date], [counterparty], [trader], [template], [header buy/sell], [generator],
			[contract], [subbook], [Vintage From], [Vintage To], [market index], [fixed price], [currency],
			[index on], [REC Status], [pricing type], 
			' + IIF (@table_name = 'ixp_import_rec_meters', '[Actual Volume],', '[Certified Volume],') + ' 
			[Vintage Year], [Deal Type]
		)
		SELECT tt.deal_id [deal id],
			   CONVERT(VARCHAR(10), MAX(tt.from_date), 120) [deal date],
			   MAX(sc.counterparty_id) [counterparty],
			   MAX(st.trader_name) [trader],
			   MAX(sdht.template_name) [template],
			   IIF(MAX(sdht.header_buy_sell_flag) = ''b'', ''buy'', ''sell'') [header buy/sell],
			   MAX(rg.code) [generator],
			   MAX(case when tt.ppa_contract_id = -99999999 THEN ''Default_Contract'' ELSE cg.contract_name END) [contract],
			   MAX(ssbm.logical_name) [Sub Book],
			   CONVERT(VARCHAR(10), MAX(tt.from_date), 120) [vintage from], 
			   CONVERT(VARCHAR(10), MAX(tt.to_date), 120) [vintage to],
			   MAX(spcd.curve_name) [market index],
			   MAX(rg.rec_price) [fixed price],
			   MAX(cur.currency_name) [currency],
			   MAX(spcd1.curve_name) [index on],
			   ''Actual'' [REC Status],
			   MAX(pricing.code) [pricing type],
			   SUM(tt.Volume) * ISNULL(MAX(conv.conversion_factor), 1.0) ' + IIF (@table_name = 'ixp_import_rec_meters', '[Actual Volume],', '[Certified Volume],') + '
			   YEAR(MAX(tt.from_date)) [vintage Year],
			   MAX(sdt.source_deal_type_name) [Deal Type]			  
		FROM #temp_table tt
		INNER JOIN source_deal_header_template sdht
			ON sdht.template_id = tt.template_id
		INNER JOIN source_deal_detail_template sddt
			ON sddt.template_id = sdht.template_id
		OUTER APPLY ( SELECT mftd.default_value fas_sub_book_id
						 From maintain_field_template mft
						 INNER JOIN source_deal_header_template  sdht1
						 	ON mft.field_template_id = sdht1.field_template_id 
						 INNER JOIN maintain_field_template_detail  mftd
						 	ON mft.field_template_id = mftd.field_template_id
						 where sdht1.template_id = sdht.template_id
						 	AND mftd.field_caption  = ''Sub Book''
		) temp
		LEFT JOIN rec_volume_unit_conversion conv
			ON conv.from_source_uom_id = tt.uom_id
				AND conv.to_source_uom_id = sddt.deal_volume_uom_id
		LEFT JOIN source_traders st ON
			st.source_trader_id = sdht.trader_id
		OUTER APPLY (
			SELECT sc.source_counterparty_id, 
				   cg.contract_id,
				   spcd.source_curve_def_id
			FROM source_counterparty sc, 
				 contract_group cg,
				 source_price_curve_def spcd
			WHERE sc.counterparty_id = ''Default_Counterparty''
				AND cg.source_contract_id = ''Default_Contract''
				AND spcd.curve_id = ''Default_Curve''
		) def_val
		LEFT JOIN source_counterparty sc
			ON sc.source_counterparty_id = COALESCE(tt.counterparty_id, sdht.counterparty_id, def_val.source_counterparty_id)
		LEFT JOIN source_system_book_map ssbm
			ON ssbm.book_deal_type_map_id = ISNULL(tt.fas_sub_book_id, temp.fas_sub_book_id)
		LEFT JOIN contract_group cg
			ON cg.contract_id = COALESCE(tt.ppa_contract_id, sdht.contract_id, def_val.contract_id)
		LEFT JOIN static_data_value pricing
			ON pricing.value_id = sdht.pricing_type
				AND pricing.type_id = 46700
		LEFT JOIN rec_generator rg
			ON rg.generator_id = tt.generator_id
		LEFT JOIN source_price_curve_def spcd
			ON COALESCE(rg.source_curve_def_id, sddt.curve_id, def_val.source_curve_def_id) = spcd.source_curve_def_id
		LEFT JOIN source_price_curve_def spcd1
			ON ISNULL(sddt.formula_curve_id, def_val.source_curve_def_id) = spcd1.source_curve_def_id
		LEFT JOIN source_minor_location sml
			ON sml.source_minor_location_id = sddt.location_id
		LEFT JOIN source_currency cur
			ON cur.source_currency_id = ISNULL(sddt.currency_id, 1)
		LEFT JOIN source_deal_type sdt
			ON sdt.source_deal_type_id = sdht.source_deal_type_id
		GROUP BY tt.deal_id
		'

	EXEC(@sql_stmt)
	
	EXEC spa_ixp_rules @flag = 't', 
					   @process_id = @process_id,
					   @ixp_rules_id = @rule_id,
					   @run_table = @temp_table,
					   @source = '21400',
					   @run_with_custom_enable = 'n',
					   @server_path = NULL,
					   @run_in_debug_mode = @debug_mode
END
GO