IF OBJECT_ID(N'[dbo].[spa_wacog_group]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_wacog_group]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO


 /**
	Calculate WACOG price in group of deals in portfolio


	Parameters : 
	@flag : Flag
				's' - Only select calculated value without calculating
				'r' - Calculate WACOG
				'x' - Loads data in wacog group detail grid
				'e' - Loads data in Environmental grid
				'j' - Loads dependent tier for provided jurisdiction
	@wacog_group_id : Wacog Group Id filter to process
	@as_of_date : As Of Date to process
	@term_start : Term Start filter to process
	@term_end : Term End filter to process
	@return_output : Process status return output
	@process_id : Process Id for process table to output calculated result
	@jurisdiction_id: Jurisdiction ID

  */



CREATE PROCEDURE [dbo].[spa_wacog_group]
	@flag CHAR(1),
	@wacog_group_id VARCHAR(MAX) = NULL,
	@as_of_date DATETIME = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@return_output INT = 1,
	
	@process_id VARCHAR(100) = NULL,
	@jurisdiction_id INT = NULL
AS


/* DEBUG QUERY START *

DECLARE @flag CHAR(1),
	
	@wacog_group_id VARCHAR(MAX) = NULL,
	@as_of_date DATETIME = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@return_output INT = 1,
	@process_id VARCHAR(100) = NULL,
	@jurisdiction_id INT = NULL
	
SELECT @flag='r',@wacog_group_id='40',@as_of_date='2020-04-06',@term_start='2020-01-01',@term_end='2020-01-31'

-- * DEBUG QUERY END */

SET NOCOUNT ON

SET @term_start = NULLIF(@term_start, '')
SET @term_end = NULLIF(@term_end, '')

IF @flag ='s'
BEGIN
	IF OBJECT_ID (N'tempdb..#deal_type') IS NOT NULL
		DROP TABLE #deal_type
	
	SELECT DISTINCT 
	       d.source_deal_type_id,
	       d.source_deal_type_name + IIF(ssd.source_system_id = 2, '', '.' + ssd.source_system_name) source_system_name
	INTO #deal_type
	FROM portfolio_hierarchy b
	INNER JOIN fas_strategy c ON b.parent_entity_id = c.fas_strategy_id
		AND b.entity_id = b.entity_id
	INNER JOIN source_deal_type d ON d.source_system_id = c.source_system_id
		AND ISNULL(d.sub_type, 'n') = 'n'
	INNER JOIN source_system_description ssd ON d.source_system_id = ssd.source_system_id 
	ORDER BY source_system_name

	IF OBJECT_ID (N'tempdb..#location') IS NOT NULL
		DROP TABLE #location
		
	SELECT wg.wacog_group_id,
		   wg.wacog_group_name,
		   STUFF((
				SELECT ',' + sml.location_name 	   
				FROM wacog_group AS inner_wg
				OUTER APPLY (
					SELECT * 
					FROM dbo.FNASplit(inner_wg.location_id, ',') 
				) z
				LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = z.item
				WHERE inner_wg.wacog_group_id = wg.wacog_group_id
				FOR XML PATH('')
		   ), 1, 1, '') location_name
	INTO #location
	FROM wacog_group AS wg
	OUTER APPLY (
		SELECT * 
		FROM dbo.fnasplit(wg.location_id, ',')
	) z
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = z.item
	GROUP BY wg.wacog_group_id, wg.wacog_group_name

	--Counterparty
	IF OBJECT_ID (N'tempdb..#counterparty') IS NOT NULL
		DROP TABLE #counterpart

	SELECT wg.wacog_group_id
		, wg.wacog_group_name
		, STUFF((
			SELECT ',' + sc.counterparty_id 	   
			FROM wacog_group AS inner_wg
			OUTER APPLY (SELECT * FROM dbo.FNASplit(inner_wg.source_counterparty_id, ',') ) z
			LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = z.item
			WHERE inner_wg.wacog_group_id = wg.wacog_group_id
			FOR XML PATH('')
		), 1, 1, '') counterparty_id
	INTO #counterparty
	FROM wacog_group AS wg
	OUTER APPLY (SELECT * FROM dbo.fnasplit(wg.source_counterparty_id, ',') ) z
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = z.item
	GROUP BY wg.wacog_group_id, wg.wacog_group_name

	--Contract
	IF OBJECT_ID (N'tempdb..#contract') IS NOT NULL
		DROP TABLE #contract
		
	SELECT wg.wacog_group_id
		 , wg.wacog_group_name
		 , STUFF((
				SELECT ',' + cg.[contract_name] 	   
				FROM wacog_group AS inner_wg
				OUTER APPLY (SELECT * FROM dbo.FNASplit(inner_wg.contract_id, ',') ) z
				LEFT JOIN contract_group cg ON cg.contract_id = z.item
				WHERE inner_wg.wacog_group_id = wg.wacog_group_id
				FOR XML PATH('')
		   ), 1, 1, '') contract_id
	INTO #contract
	FROM wacog_group AS wg
	OUTER APPLY (SELECT * FROM dbo.fnasplit(wg.contract_id, ',') ) z
	LEFT JOIN contract_group cg ON cg.contract_id = z.item
	GROUP BY wg.wacog_group_id, wg.wacog_group_name
	
	IF OBJECT_ID (N'tempdb..#index') IS NOT NULL
		DROP TABLE #index
		
	SELECT wg.wacog_group_id,
		   wg.wacog_group_name,
		   STUFF((
				SELECT ',' + spcd.curve_name 	   
				FROM wacog_group AS inner_wg
				OUTER APPLY (
					SELECT * 
					FROM dbo.FNASplit(inner_wg.curve_id, ',') 
				) z
				LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = z.item
				WHERE inner_wg.wacog_group_id = wg.wacog_group_id
				FOR XML PATH('')
		   ), 1, 1, '') curve_name
	INTO #index
	FROM wacog_group AS wg
	OUTER APPLY (
		SELECT * 
		FROM dbo.FNAsplit(wg.curve_id, ',')
	) z
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = z.item
	GROUP BY wg.wacog_group_id, wg.wacog_group_name

	SELECT	wg.wacog_group_id,
			wg.wacog_group_name,
			sc.counterparty_id [counterparty_name],
			cg.contract_id [contract_name],
			st.trader_name trader_id,
			sdht.template_name template_id,
			dt.source_system_name deal_type,
			scd.commodity_name source_commodity_id,
			loc.location_name location_id,
			spcd.curve_name curve_id,
			CASE WHEN wg.physical_financial_flag = 'p' THEN 'Physical' ELSE 'Financial' END physical_financial_flag,
			CASE WHEN wg.buy_sell_flag = 'b' THEN 'Buy' ELSE 'Sell' END buy_sell_flag,
			CASE WHEN wg.frequency = 'a' THEN 'Annually'
		        WHEN wg.frequency = 'd' THEN 'Daily'
		        WHEN wg.frequency = 'h' THEN 'Hourly'
		        WHEN wg.frequency = 'm' THEN 'Monthly'
		        WHEN wg.frequency = 'q' THEN 'Quarterly'
		        WHEN wg.frequency = 's' THEN 'Semi-Annually'
		        WHEN wg.frequency = 't' THEN 'Term'
		   END frequency
	FROM wacog_group wg
	LEFT JOIN source_traders st ON st.source_trader_id = wg.trader_id
	LEFT JOIN source_commodity scd ON scd.source_commodity_id = wg.source_commodity_id
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = wg.template_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = wg.frequency
	LEFT JOIN #deal_type dt ON dt.source_deal_type_id = wg.deal_type
	LEFT JOIN #index spcd ON spcd.wacog_group_id = wg.wacog_group_id
	LEFT JOIN #location loc ON loc.wacog_group_id = wg.wacog_group_id
	LEFT JOIN #counterparty sc ON sc.wacog_group_id = wg.wacog_group_id
	LEFT JOIN #contract cg ON cg.wacog_group_id = wg.wacog_group_id
END

ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
		
		DECLARE @wacog FLOAT
			, @sql VARCHAR(MAX)
			, @all_subbook_id VARCHAR(MAX)
			, @db_user VARCHAR(100) = [dbo].FNADBUser()
			, @msg_description VARCHAR(100)
			, @sub_book_id VARCHAR(MAX)
			, @source_counterparty_id VARCHAR(MAX)
			, @contract_id VARCHAR(MAX)
			, @trader_id INT
			, @template_id VARCHAR(MAX)
			, @deal_type VARCHAR(MAX)
			, @source_commodity_id INT
			, @location_id VARCHAR(4000)
			, @curve_id VARCHAR(MAX)
			, @physical_financial_flag CHAR(1)
			, @buy_sell_flag CHAR(1)
			, @frequency CHAR(1)
			, @charge_type VARCHAR(MAX)
			, @include_financial CHAR(1)
		
		SET @as_of_date = ISNULL(@as_of_date, GETDATE())

		IF OBJECT_ID(N'tempdb..#temp_deal_settlement') IS NOT NULL
			DROP TABLE #temp_deal_settlement

		CREATE TABLE #temp_deal_settlement (
			as_of_date DATETIME,
			settlement_date DATETIME,
			payment_date DATETIME,
			source_deal_header_id INT,
			term_start DATETIME,
			term_end DATETIME,
			volume FLOAT,
			net_price FLOAT,
			settlement_amount FLOAT,
			settlement_currency_id INT,
			volume_uom INT,
			fin_volume FLOAT,
			fin_volume_uom INT,
			float_price FLOAT,
			deal_price FLOAT,
			price_currency INT,
			leg INT,
			market_value FLOAT,
			contract_value FLOAT,
			set_type CHAR COLLATE DATABASE_DEFAULT,
			allocation_volume FLOAT,
			settlement_amount_deal FLOAT,
			settlement_amount_inv FLOAT,
			deal_cur_id INT,
			inv_cur_id INT,
			wacog_group_id INT
		)

		DECLARE @wacog_group_id_new INT
	
		DECLARE wacog_group_cur CURSOR FOR
			SELECT item 
			FROM dbo.SplitCommaSeperatedValues(@wacog_group_id)
		OPEN wacog_group_cur
		
		FETCH NEXT FROM wacog_group_cur
		INTO @wacog_group_id_new
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @all_subbook_id = ISNULL(@all_subbook_id + ',', '') + subbook_id 
			FROM wacog_group wg
			WHERE wg.wacog_group_id = @wacog_group_id_new 

			DECLARE @is_group_environmental CHAR(1) = 'n'

			SELECT @is_group_environmental = enable_environmental 
			FROM wacog_group 
			WHERE wacog_group_id = @wacog_group_id_new

			IF OBJECT_ID(N'tempdb..#collect_dates') IS NOT NULL
				DROP TABLE #collect_dates
			IF OBJECT_ID(N'tempdb..#final_table') IS NOT NULL
				DROP TABLE #final_table
			IF OBJECT_ID(N'tempdb..#location_id') IS NOT NULL
				DROP TABLE #location_id
			IF OBJECT_ID(N'tempdb..#sub_book') IS NOT NULL
				DROP TABLE #sub_book
			IF OBJECT_ID(N'tempdb..#collection_dates1') IS NOT NULL
				DROP TABLE #collection_dates1	
		
			SELECT @source_counterparty_id = CONCAT(@source_counterparty_id, NULLIF(wg.source_counterparty_id, ''))
				 , @contract_id	= CONCAT(@contract_id, wg.contract_id)
				 , @trader_id =	wg.trader_id
				 , @source_commodity_id = wg.source_commodity_id
				 , @location_id	= wg.location_id
				 , @curve_id = @curve_id + wg.curve_id
				 , @physical_financial_flag = wg.physical_financial_flag
				 , @buy_sell_flag = wg.buy_sell_flag
				 , @frequency = wg.frequency				 
				 , @sub_book_id = wg.subbook_id
				 , @include_financial = wg.include_financial
			FROM wacog_group wg
			
			WHERE wg.wacog_group_id = CAST(@wacog_group_id_new AS INT)

			
			SELECT @template_id = ISNULL(@template_id + ',', '') + CAST(template_id AS VARCHAR(10))
			FROM wacog_group_detail
			WHERE wacog_group_id = CAST(@wacog_group_id_new AS INT)
			GROUP BY template_id

			SELECT @deal_type = ISNULL(@deal_type + ',', '') + CAST(source_deal_type_id AS VARCHAR(10))
			FROM wacog_group_detail
			WHERE wacog_group_id = CAST(@wacog_group_id_new AS INT)
			
			SELECT @charge_type = ISNULL(@charge_type + ',', '') + CAST(charge_type_id AS VARCHAR(10))
			FROM wacog_group_detail
			WHERE wacog_group_id = CAST(@wacog_group_id_new AS INT)
			GROUP BY charge_type_id

			IF OBJECT_ID(N'tempdb..#temp_template_deal_charge_type') IS NOT NULL
			
				DROP TABLE #temp_template_deal_charge_type

			CREATE TABLE #temp_template_deal_charge_type (
				wacog_group_id INT,
				template_id INT,
				deal_type INT,
				charge_type INT,
				leg INT
			)

			-- added to list all charge types with null as all, under deal type and template
			INSERT INTO #temp_template_deal_charge_type
			
			SELECT @wacog_group_id_new wacog_group_id
				, wgd.template_id template_id
				, wgd.source_deal_type_id deal_type
				, CASE 
					WHEN wgd.charge_type_id = -10019 THEN -10019 
					ELSE udft.field_name 
				END charge_type
				, NULLIF(wgd.leg, '') leg
			FROM wacog_group_detail wgd
			
			LEFT JOIN user_defined_fields_template udft 
				ON udft.udf_template_id = wgd.charge_type_id
			WHERE wgd.wacog_group_id = CAST(@wacog_group_id_new AS INT)
			
			GROUP BY wgd.template_id
				, wgd.source_deal_type_id
				, udft.field_name
				, wgd.leg
				, wgd.charge_type_id

		
			
			SELECT item AS subbook_id 
			INTO #sub_book 
			FROM dbo.FNASplit(@sub_book_id, ',')

			SELECT * 
			INTO #location_id
			FROM dbo.SplitCommaSeperatedValues(@location_id)

			--Collect all data having same book structure as in wacog_group table
			DECLARE @sql_where VARCHAR(MAX) = ''
			DECLARE @sql_where_term VARCHAR(MAX) = ''

			SET @sql = ' 
				INSERT INTO #temp_deal_settlement
				SELECT DISTINCT 
							
					sds.as_of_date
					, sds.settlement_date
					, sds.payment_date
					, sds.source_deal_header_id
					, sds.term_start
					, sds.term_end
					, CASE 
						WHEN t1.charge_type = -10019 THEN 0 
						WHEN t1.check_leg = 1 THEN sds.volume 
						ELSE 0 
					END volume
					, sds.net_price
					, CASE 
						WHEN  t1.charge_type = -10019 THEN 0 
						WHEN t1.check_leg = 1 THEN sds.settlement_amount 
						ELSE 0 END settlement_amount
					, sds.settlement_currency_id
					, sds.volume_uom
					, sds.fin_volume
					, sds.fin_volume_uom
					, sds.float_price
					, sds.deal_price
					, sds.price_currency
					, sds.leg
					, sds.market_value
					, sds.contract_value
					, sds.set_type
					, sds.allocation_volume
					, sds.settlement_amount_deal
					, sds.settlement_amount_inv
					, sds.deal_cur_id
					, sds.inv_cur_id
					, ' + CAST(@wacog_group_id_new AS VARCHAR(10)) + '			
				FROM source_deal_settlement sds
				
				INNER JOIN source_deal_header sdh 
					ON sdh.source_deal_header_id = sds.source_deal_header_id ' +
				IIF(@all_subbook_id IS NOT NULL, ' 
				AND sdh.sub_book IN (SELECT subbook_id FROM #sub_book)', '') + '
				INNER JOIN source_deal_detail sdd 
					ON sdh.source_deal_header_id = sdd.source_deal_header_id ' +
				IIF(@all_subbook_id IS NOT NULL, ' 
				INNER JOIN (SELECT item AS subbook_id FROM dbo.SplitCommaSeperatedValues(''' + @all_subbook_id + '''))  wg 
					ON wg.subbook_id = sdh.sub_book ', '') + '
				OUTER APPLY (
					SELECT 1 check_leg, MIN(charge_type) charge_type
					
					FROM #temp_template_deal_charge_type t1 
					WHERE t1.template_id = sdh.template_id 
						AND t1.deal_type = sdh.source_deal_type_id 
						AND ISNULL(t1.leg,sds.leg) = sds.leg 
				) t1
				WHERE sds.as_of_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
			'

			IF NULLIF(@physical_financial_flag, '') IS NOT NULL
			BEGIN
				SET @sql_where += ' AND sdh.physical_financial_flag = ''' + @physical_financial_flag + ''''
			END
		
			IF NULLIF(@buy_sell_flag, '') IS NOT NULL
			BEGIN
				SET @sql_where += ' AND sdd.buy_sell_flag = ''' + @buy_sell_flag + ''''
			END

			IF NULLIF(@term_start, '') IS NOT NULL
			BEGIN				
				SET @sql_where_term += CHAR(10) + ' AND ' + IIF(@is_group_environmental = 'y', 'COALESCE(sdd.actual_delivery_date, sdd.delivery_date, sdd.term_start)', 'sds.term_start') + ' >= ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''''
			END

			IF @term_end IS NOT NULL
			BEGIN
				
				SET @sql_where_term += CHAR(10) + ' AND ' + IIF(@is_group_environmental = 'y', 'COALESCE(sdd.actual_delivery_date, sdd.delivery_date, sdd.term_start)', 'sds.term_start') + '<= ''' + CONVERT(VARCHAR(10), @term_end, 120)  + ''''
			END

			IF NULLIF(@source_counterparty_id, '') IS NOT NULL
			BEGIN
				SET @sql_where += CHAR(10) + ' AND sdh.counterparty_id IN (' + CAST(@source_counterparty_id AS VARCHAR(100)) + ')'
			END

			IF NULLIF(@contract_id, '') IS NOT NULL
			BEGIN 
				SET @sql_where += CHAR(10) + ' AND sdh.contract_id IN (' + CAST(@contract_id AS VARCHAR(100)) + ')'
			END

			IF NULLIF(@trader_id, '') IS NOT NULL
			BEGIN 
				SET @sql_where += CHAR(10) + ' AND sdh.trader_id IN (' + CAST(@trader_id AS VARCHAR(100)) + ')'
			END

			IF NULLIF(@template_id, '') IS NOT NULL
			BEGIN 
				SET @sql_where += CHAR(10) + ' AND sdh.template_id IN (' + @template_id + ')'
			END

			IF NULLIF(@deal_type, '') IS NOT NULL
			BEGIN 
				SET @sql_where += CHAR(10) + ' AND sdh.source_deal_type_id IN (' + @deal_type + ')'
			END

			IF NULLIF(@source_commodity_id, '') IS NOT NULL
			BEGIN
				SET @sql_where += CHAR(10) + ' AND sdh.commodity_id IN (' + CAST(@source_commodity_id AS VARCHAR(100)) + ')'
			END

			IF ISNULL(@include_financial,'') = 'y' AND NULLIF(@location_id, '') IS NOT NULL
			BEGIN
				SET @sql_where += CHAR(10) + ' AND (sdd.location_id IN (' + @location_id + ') OR sdd.location_id IS NULL) '
			END
			ELSE IF NULLIF(@location_id, '') IS NOT NULL
			BEGIN
				SET @sql_where += CHAR(10) + ' AND sdd.location_id IN (' + @location_id + ') '
			END
			ELSE IF ISNULL(@include_financial,'') = 'y'
			BEGIN
				SET @sql_where += CHAR(10) + ' sdd.location_id IS NULL '
			END

			IF NULLIF(@curve_id, '') IS NOT NULL
			BEGIN
				SET @sql_where += CHAR(10) + ' AND sdd.curve_id IN (' + @curve_id + ')'
			END

			--PRINT (@sql)
			EXEC (@sql + @sql_where + @sql_where_term)
			
			-- collect data from index_fees_breakdown_settlement where no settlement process done
			SET @sql = ' 
				INSERT INTO #temp_deal_settlement(source_deal_header_id,as_of_date,term_start,term_end,settlement_date,settlement_amount,volume)
				SELECT DISTINCT 					
					sds.source_deal_header_id,	
					sds.as_of_date, 
					MAX(sds.term_start) term_start, 
					MAX(sds.term_start) term_end,
					NULL settlement_date,
					0 settlement_amount,
					CASE WHEN MIN(t2.charge_field_exist) = 1 THEN 1 ELSE MAX(sds.volume) END volume
				FROM index_fees_breakdown_settlement sds
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sds.source_deal_header_id ' +
				IIF(@all_subbook_id IS NOT NULL, ' AND sdh.sub_book IN (SELECT subbook_id FROM #sub_book)', '') + '
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id ' +
				IIF(@all_subbook_id IS NOT NULL, ' 
				INNER JOIN (SELECT item AS subbook_id FROM dbo.SplitCommaSeperatedValues(''' + @all_subbook_id + '''))  wg ON wg.subbook_id = sdh.sub_book ', '') + '
				OUTER APPLY (
					SELECT 1 check_leg, MIN(charge_type) charge_type
					FROM #temp_template_deal_charge_type t1 WHERE t1.template_id = sdh.template_id AND t1.deal_type = sdh.source_deal_type_id AND ISNULL(t1.leg,sds.leg) = sds.leg 
				) t1
				OUTER APPLY (
					SELECT TOP 1 1 charge_field_exist
					FROM index_fees_breakdown_settlement a1 
					WHERE a1.source_deal_header_id = sds.source_deal_header_id AND sds.as_of_date = a1.as_of_date
						AND a1.field_name IN (''Option'',''Option Premium'',''Commission'')
				) t2
				LEFT JOIN #temp_deal_settlement tds ON tds.source_deal_header_id = sds.source_deal_header_id 
				WHERE (sds.field_name IN (''Option'',''Option Premium'',''Commission'') OR (sds.field_name NOT IN (''Option'',''Option Premium'',''Commission'') ' + @sql_where_term + '))
					AND tds.source_deal_header_id IS NULL AND sds.as_of_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
			'
			--PRINT (@sql + @sql_where + ' GROUP BY sds.source_deal_header_id,sds.as_of_date')
			EXEC (@sql + @sql_where + ' GROUP BY sds.source_deal_header_id,sds.as_of_date')

			DECLARE @source_deal_header_ids VARCHAR(MAX)
			SELECT @source_deal_header_ids = STUFF((
				SELECT ',' + CAST(source_deal_header_id AS VARCHAR(10))
				FROM #temp_deal_settlement
				FOR XML PATH('')
		     ), 1, 1, '') 


			IF OBJECT_ID ('tempdb..#index_fees_breakdown_settlement_pre') IS NOT NULL
				DROP TABLE #index_fees_breakdown_settlement_pre


			CREATE TABLE #index_fees_breakdown_settlement_pre (
				as_of_date DATETIME,
				[value] NUMERIC(38, 6)
			)


			IF OBJECT_ID ('tempdb..#index_fees_breakdown_settlement') IS NOT NULL
				DROP TABLE #index_fees_breakdown_settlement

			CREATE TABLE #index_fees_breakdown_settlement (
				as_of_date DATETIME,
				[value] NUMERIC(38, 6)
			)
			
			SET @sql = '
				INSERT INTO #index_fees_breakdown_settlement_pre
				SELECT ifbs.as_of_date, (CASE WHEN ifbs.field_name IN (''Option'',''Option Premium'') THEN ifbs.value * ISNULL(sdd.term_ratio,1) ELSE ifbs.value END) value
				FROM index_fees_breakdown_settlement ifbs
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ifbs.source_deal_header_id
				OUTER APPLY (
					SELECT (DATEDIFF(month,''' + CONVERT(VARCHAR(10), @term_end, 120) + ''',''' + CONVERT(VARCHAR(10), @term_start, 120) + ''')+1)/(DATEDIFF(month, MAX(s1.term_end), MIN(term_start)) + 1) AS term_ratio
					FROM source_deal_detail s1
					WHERE s1.source_deal_header_id = sdh.source_deal_header_id
				) sdd
				'

			IF NULLIF(@deal_type, '') IS NOT NULL OR NULLIF(@template_id, '') IS NOT NULL
			BEGIN
				SET @sql += '
					INNER JOIN #temp_template_deal_charge_type t2 
						ON t2.template_id = sdh.template_id 
							AND t2.deal_type = sdh.source_deal_type_id 
							AND ifbs.leg = ISNULL(t2.leg,ifbs.leg)
					LEFT JOIN #temp_template_deal_charge_type t1 
						ON t1.template_id = sdh.template_id 
							AND t1.deal_type = sdh.source_deal_type_id
							AND ifbs.field_id = t1.charge_type
				'
				
			END
				
			SET @sql += ' WHERE 1 = 1 ' + IIF(NULLIF(@deal_type, '') IS NOT NULL OR NULLIF(@template_id, '') IS NOT NULL, ' AND t1.charge_type IS NULL ', '')
			
			IF NULLIF(@source_deal_header_ids, '') IS NOT NULL
			BEGIN
				SET @sql += ' AND ifbs.source_deal_header_id IN (' + @source_deal_header_ids + ')'
			END
			
			SET @sql += ' 
					
					INSERT INTO #index_fees_breakdown_settlement
					SELECT as_of_date, SUM(value) value
					FROM #index_fees_breakdown_settlement_pre
			'

			SET @sql += ' GROUP BY as_of_date'
			
			--PRINT (@sql)
			EXEC (@sql)
		
			IF @process_id IS NOT NULL
			BEGIN
				DECLARE @process_table VARCHAR(100)
				SET @process_table = dbo.FNAProcessTableName('wacog_report', dbo.FNADBUser(), @process_id)

				EXEC ('
					SELECT * 
					INTO ' + @process_table + '
					FROM #temp_deal_settlement 
				')

				RETURN
			END
			
			--Collect only data having required as_of_date, term_start and term_end
			
			SELECT MAX(tds.as_of_date) as_of_date
				, tds.source_deal_header_id
				, tds.term_start
				, tds.term_end
			INTO #collect_dates
			FROM #temp_deal_settlement tds
			OUTER APPLY (
				SELECT TOP 1 tds.as_of_date
				FROM #temp_deal_settlement tds
				WHERE as_of_date <= @as_of_date 
				ORDER BY tds.as_of_date DESC
			) z
			WHERE tds.as_of_date <= @as_of_date 
			
			GROUP BY tds.source_deal_header_id
				, tds.term_start
				, tds.term_end
			ORDER BY tds.source_deal_header_id
				
			--Make a table to perform calculation
			
			SELECT MAX(tds.as_of_date) as_of_date
				, MAX(tds.term_start) term_start
				, MAX(tds.term_end) term_end
				, ABS(SUM(tds.settlement_amount)) amount
				, SUM(tds.volume) volume
				, tds.source_deal_header_id
			INTO #final_table
			FROM #temp_deal_settlement tds
			
			INNER JOIN #collect_dates cd 
				ON cd.as_of_date = tds.as_of_date
					AND cd.term_start = tds.term_start
					AND cd.term_end = tds.term_end
					AND cd.source_deal_header_id = tds.source_deal_header_id
			GROUP BY tds.settlement_date
				, tds.source_deal_header_id
	
			
			SELECT as_of_date
				, b.term_start
				, b.term_end
				, amount / (DATEDIFF(DAY, a.term_start, a.term_end) + 1) amount
				, volume / (DATEDIFF(DAY, a.term_start, a.term_end) + 1) volume
				, source_deal_header_id
			INTO #collection_dates1
			FROM #final_table a
			CROSS APPLY (
				SELECT *
				FROM dbo.FNATermBreakdown('d', ISNULL(@term_start, a.term_start), ISNULL(@term_end, a.term_end))
			) b
			
			IF OBJECT_ID(N'tempdb..#collection_dates2') IS NOT NULL
				DROP TABLE #collection_dates2
		
			CREATE TABLE #collection_dates2 (
				as_of_date DATETIME,
				term_start DATETIME,
				term_end DATETIME,
				amount FLOAT,
				volume FLOAT,
				source_deal_header_id INT
			)

			IF @frequency = 'm'
			BEGIN
				INSERT INTO #collection_dates2
				
				SELECT as_of_date
					, MAX(term_start)
					, MIN(term_end)
					, SUM(Amount)
					, SUM(volume)
					, source_deal_header_id
				FROM #collection_dates1
				 
				GROUP BY as_of_date
					, source_deal_header_id 
			END
			ELSE
			BEGIN 
				INSERT INTO #collection_dates2
				SELECT * 
				FROM #collection_dates1 
			END

			
			IF @is_group_environmental = 'y'
			BEGIN

				IF OBJECT_ID('tempdb..#deals_product') IS NOT NULL
					DROP TABLE #deals_product

				SELECT DISTINCT sdh.source_deal_header_id
					, sdh.state_value_id
					, sdh.tier_value_id
					, COALESCE(sdh.reporting_jurisdiction_id, sdh.tier_value_id, rg.state_value_id) reporting_jurisdiction_id
					, COALESCE(sdh.reporting_tier_id, sdh.tier_value_id, rg.tier_type) reporting_tier_id
					, sdh.match_type
					, CASE 
						WHEN sdh.match_type = 'm' THEN 
							CASE  
								WHEN DATEFROMPARTS(YEAR(sdd.term_start), sp.calendar_from_month, 1) <= sdd.term_start 
									AND sdd.term_start <= EOMONTH(DATEFROMPARTS(YEAR(sdd.term_start) + 1, sp.calendar_to_month, 1)) THEN YEAR(sdd.term_start) 
								ELSE YEAR(sdd.term_start) - 1 
							END 
						ELSE sdd.vintage 
					END vintage
				INTO #deals_product
				FROM source_deal_header sdh
				INNER JOIN source_deal_detail sdd
					ON sdh.source_deal_header_id = sdd.source_deal_header_id
				LEFT JOIN rec_generator rg
					ON rg.generator_id = sdh.generator_id
				LEFT JOIN state_properties sp
					ON sp.state_value_id = sdh.state_value_id
				INNER JOIN STRING_SPLIT(@source_deal_header_ids, ',') csv
					ON csv.value = sdh.source_deal_header_id


				UPDATE dec 
					SET vintage = sdv.value_id
				FROM #deals_product dec
				LEFT join static_data_value sdv
					ON sdv.code = dec.vintage
					AND sdv.[type_id] = 10092
				WHERE match_type = 'm'

				IF OBJECT_ID('tempdb..#final_deals_product') IS NOT NULL
					DROP TABLE #final_deals_product

				SELECT DISTINCT dec.source_deal_header_id
					, wge.wacog_group_id
					, IIF(wge.wacog_group_environmental_id IS NULL, dec.state_value_id, IIF(wge.default_jurisdiction IS NULL, dec.state_value_id, NULL)) state_value_id
					, IIF(wge.wacog_group_environmental_id IS NULL, dec.tier_value_id, IIF(wge.default_tier IS NULL, dec.tier_value_id, NULL)) tier_value_id
					, IIF(wge.wacog_group_environmental_id IS NULL, NULL, wge.default_jurisdiction) reporting_jurisdiction_id
					, IIF(wge.wacog_group_environmental_id IS NULL, NULL, wge.default_tier) reporting_tier_id
					, dec.vintage
				INTO #final_deals_product
				FROM #deals_product dec
				LEFT JOIN wacog_group_environmental wge
					ON wge.wacog_group_id = @wacog_group_id_new
						AND ISNULL(dec.state_value_id, 1) = COALESCE(wge.jurisdiction, dec.state_value_id, 1)
						AND ISNULL(dec.tier_value_id, 1) = COALESCE(wge.tier, dec.tier_value_id, 1)
						AND ISNULL(dec.vintage, 1) = COALESCE(wge.vintage_year, dec.vintage, 1)
				WHERE wge.default_jurisdiction IS NULL
					AND wge.default_tier IS NULL
				UNION
				SELECT DISTINCT dec.source_deal_header_id
					, wge.wacog_group_id
					, IIF(wge.wacog_group_environmental_id IS NULL, dec.state_value_id, IIF(wge.default_jurisdiction IS NULL, dec.state_value_id, NULL)) state_value_id
					, IIF(wge.wacog_group_environmental_id IS NULL, dec.tier_value_id, IIF(wge.default_tier IS NULL, dec.tier_value_id, NULL)) tier_value_id
					, IIF(wge.wacog_group_environmental_id IS NULL, NULL, wge.default_jurisdiction) reporting_jurisdiction_id
					, IIF(wge.wacog_group_environmental_id IS NULL, NULL, wge.default_tier) reporting_tier_id
					, dec.vintage
				FROM #deals_product dec
				LEFT JOIN wacog_group_environmental wge
					ON wge.wacog_group_id = @wacog_group_id_new
						AND ISNULL(dec.reporting_jurisdiction_id, 1) = COALESCE(wge.default_jurisdiction, dec.reporting_jurisdiction_id, 1)
						AND ISNULL(dec.reporting_tier_id, 1) = COALESCE(wge.default_tier, dec.reporting_tier_id, 1)
						AND ISNULL(dec.vintage, 1) = COALESCE(wge.vintage_year, dec.vintage, 1)
				WHERE wge.jurisdiction IS NULL
					AND wge.tier IS NULL
		
				IF EXISTS(SELECT 1 FROM #final_deals_product where wacog_group_id IS NOT NULL)
				BEGIN
					DELETE FROM #final_deals_product where wacog_group_id IS NULL
				END

				IF OBJECT_ID ('tempdb..#temp_wacog_table') IS NOT NULL
					DROP TABLE #temp_wacog_table

				SELECT @wacog_group_id_new wacog_group_id
					, MAX(tds.as_of_date) as_of_date
					, MAX(tds.term_start) term_start
					, ABS(ABS(SUM(tds.settlement_amount)) / NULLIF(SUM(tds.volume), 0)) wacog
					, fdp.state_value_id
					, fdp.tier_value_id
					, fdp.reporting_jurisdiction_id
					, fdp.reporting_tier_id
					, fdp.vintage
					, MAX(CAST(@term_start AS DATE)) [delivery_month]
				INTO #temp_wacog_table
				FROM #final_deals_product fdp
				INNER JOIN #temp_deal_settlement tds
					ON fdp.source_deal_header_id = tds.source_deal_header_id
				GROUP BY fdp.wacog_group_id
					, fdp.state_value_id
					, fdp.tier_value_id
					, fdp.reporting_jurisdiction_id
					, fdp.reporting_tier_id
					, fdp.vintage

				DELETE cwg
				FROM #temp_wacog_table twt
				INNER JOIN calculate_wacog_group cwg
					ON twt.wacog_group_id = cwg.wacog_group_id
						AND twt.as_of_date = cwg.as_of_date
						AND twt.term_start = cwg.term
						AND ISNULL(twt.state_value_id, 1) = ISNULL(cwg.jurisdiction, 1)
						AND ISNULL(twt.tier_value_id, 1) = ISNULL(cwg.tier, 1)
						AND ISNULL(twt.reporting_jurisdiction_id, 1) = ISNULL(cwg.default_jurisdiction, 1)
						AND ISNULL(twt.reporting_tier_id, 1) = ISNULL(cwg.default_tier, 1)
						AND ISNULL(twt.vintage, 1) = ISNULL(cwg.vintage_year, 1)

				INSERT INTO calculate_wacog_group (
					wacog_group_id
					, as_of_date
					, term
					, wacog
					, jurisdiction
					, tier
					, default_jurisdiction
					, default_tier
					, vintage_year
					, delivery_month
				)
				SELECT * FROM #temp_wacog_table
			END
			ELSE
			BEGIN

				DELETE cwg
				FROM #collection_dates2 ft
				INNER JOIN calculate_wacog_group cwg 
					ON cwg.wacog_group_id = CAST(@wacog_group_id_new AS INT)
						AND cwg.term = ft.term_start
			
			
				DELETE cwg
				FROM calculate_wacog_group cwg
				WHERE CONVERT(VARCHAR(10), as_of_date, 120) = CONVERT(VARCHAR(10), @as_of_date, 120)
					AND cwg.wacog_group_id = @wacog_group_id_new	

			
				--Perform calulation and insert result into table
				INSERT INTO calculate_wacog_group (
					wacog_group_id
					, as_of_date
					, term
					, wacog
				)
				SELECT CAST(@wacog_group_id_new AS INT)
					, ft.as_of_date
					, ft.term_start
					, ABS(ABS(SUM(amount) + MAX(ISNULL(value, 0))) / NULLIF(SUM(volume), 0)) wacog
				FROM #collection_dates2 ft
				LEFT JOIN #index_fees_breakdown_settlement d 
					ON ft.as_of_date = d.as_of_date
				GROUP BY ft.as_of_date
					, ft.term_start
			END
	
	
			FETCH NEXT FROM wacog_group_cur
			INTO @wacog_group_id_new
		END
		
		CLOSE wacog_group_cur
		DEALLOCATE wacog_group_cur
	
	
		SET @msg_description = 'WACOG Calculation process completed for run date ' + '''' + dbo.FNADateFormat(@as_of_date) + ''''
		EXEC spa_message_board @flag = 'i', @user_login_id = @db_user, @source = 'WACOG Calculation', @description = @msg_description, @type= 's'


		IF @return_output = 1
		BEGIN
			EXEC spa_ErrorHandler 0, 'Setup WACOG Process', 'spa_wacog_group', 'Success', 'Changes have been saved successfully.', ''
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		 
		DECLARE @desc VARCHAR(200)
		SET @desc = 'Fail to insert Data ( Error Description:' + ERROR_MESSAGE() + ').'
		
		SET @msg_description = 'WACOG Calculation process failed for run date ' + '''' + dbo.FNADateFormat(@as_of_date) + ''''
		
		EXEC spa_message_board @flag='i', @user_login_id = @db_user, @source= 'WACOG Calculation', @description = 'WACOG Calculation process failed.', @type = 's'
		
		IF @return_output = 1
		BEGIN
			EXEC spa_ErrorHandler -1,
					
				'Setup WACOG Process',
				'spa_wacog_group',
				'Error'
				,@desc
				, NULL
		END
	END CATCH
END

ELSE IF @flag = 'x'
BEGIN
	SELECT wgd.wacog_group_detail_id [ID],
		   wgd.wacog_group_id [WACOG_Group],
		   wgd.template_id [Template],
		   wgd.source_deal_type_id [Deal_Type],
		   wgd.charge_type_id [Charge_Type],
		   wgd.leg
	FROM wacog_group_detail wgd
	WHERE wgd.wacog_group_id = @wacog_group_id
END

ELSE IF @flag = 'e'
BEGIN
	SELECT wge.wacog_group_environmental_id [ID]
		, wge.wacog_group_id [WACOG Group]
		, wge.jurisdiction [Jurisdiction]
		, wge.tier [Tier]
		, wge.default_jurisdiction [Default Jurisdiction]
		, wge.default_tier [Default Tier]
		, wge.vintage_year [Vintage Year]
	FROM wacog_group_environmental wge
	WHERE wge.wacog_group_id = @wacog_group_id
END

ELSE IF @flag = 'j'
BEGIN
    SELECT sdv.value_id AS id, sdv.code AS [value]
	FROM static_data_value sdv
	INNER JOIN state_properties_details spd ON spd.tier_id = sdv.value_id
	WHERE sdv.[type_id] = 15000
		AND spd.state_value_id = @jurisdiction_id
	GROUP BY sdv.value_id, sdv.code
END

ELSE IF @flag = 'a'-- For Run Invetory Process Report Wacog Drop down filter
BEGIN
	SELECT wacog_group_id, wacog_group_name FROM wacog_group

END
GO
