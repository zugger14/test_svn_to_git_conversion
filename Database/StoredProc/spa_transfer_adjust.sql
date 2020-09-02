IF OBJECT_ID(N'dbo.spa_transfer_adjust') IS NOT NULL
    DROP PROCEDURE dbo.spa_transfer_adjust
GO
 
SET ANSI_NULLS ON
GO

 
SET QUOTED_IDENTIFIER ON 
GO

/**
	Adjust transfer deal accorder to the physical deal

	Parameters 
	@source_deal_header_id: Deal id according to which transfer deal needs to be adjusted
*/

CREATE PROCEDURE spa_transfer_adjust
	@source_deal_header_id INT
AS

/* DEBUG

IF OBJECT_ID('tempdb..#temp_mdq_avail') IS NOT NULL
DROP TABLE #temp_mdq_avail
go

--Sets session DB users 
EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'dmanandhar'

--Sets contextinfo to debug mode so that spa_print will prints data
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'
		
--Drops all temp tables created in this scope.
EXEC [spa_drop_all_temp_table] 

DECLARE @source_deal_header_id INT =  12269 --11553  --11166  --8738 

--pegas sell

--*/
SET NOCOUNT ON

DECLARE 
		 @path_id VARCHAR(20)
		, @deal_location_id INT
		, @deal_term_start DATETIME
		, @deal_term_end DATETIME
		, @transport_deal_id INT
		, @capacity_deal_id INT
		, @withdrawal_deal_id INT
		, @from_location INT
		, @to_location INT
		, @path_contract_id INT
		, @sql NVARCHAR(MAX)
		, @header_buy_sell_flag CHAR(1)
		, @after_insert_process_table NVARCHAR(1000)
		, @user_name NVARCHAR(100) = dbo.FNADBUser()
		, @job_process_id NVARCHAR(200) = dbo.FNAGETNEWID()
		, @job_name NVARCHAR(200) 
		, @product_group NVARCHAR(500)
		, @product_group_id INT
		, @col INT
		, @process_id VARCHAR(500)
		, @inserted_updated_deals VARCHAR(500) 
		, @reschedule BIT
		, @flow_date_from DATETIME
		, @flow_date_to DATETIME  
		, @all_physical_deals VARCHAR(200)

SELECT @product_group = sdv.code 
	, @product_group_id = internal_portfolio_id
FROM source_deal_header
INNER JOIN static_data_value sdv
	ON sdv.value_id = internal_portfolio_id
WHERE source_deal_header_id =  @source_deal_header_id --  8774

SELECT @deal_location_id = MIN(location_id)
	, @deal_term_start = MIN(term_start)
	, @deal_term_end = MAX(term_end)
FROM source_deal_detail 
WHERE source_Deal_header_id = @source_deal_header_id   --8407 -- @source_deal_header_id  
GROUP BY source_deal_header_id 

SELECT @header_buy_sell_flag = header_buy_sell_flag
FROM source_deal_header 
WHERE source_deal_header_id = @source_deal_header_id 

SELECT @all_physical_deals = ISNULL(@all_physical_deals + ',', '') + CAST(a.source_deal_header_id AS VARCHAR(10))
FROM(
	SELECT DISTINCT sdd.source_deal_header_id
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN source_deal_type sdt
		ON sdt.source_deal_type_id = sdh.source_deal_type_id
	WHERE internal_portfolio_id = @product_group_id
		AND sdd.location_id = @deal_location_id
		AND sdd.term_start BETWEEN [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'f')  AND [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'l')
		--AND sdd.term_start BETWEEN @deal_term_start AND @deal_term_end
		AND sdh.header_buy_sell_flag = @header_buy_sell_flag
		AND sdt.deal_type_id = 'Physical' 
) a

CREATE TABLE #temp_updated_deals (
	source_deal_header_id INT
)

CREATE TABLE #temp_transport_deal (
	source_deal_header_id INT,
	type VARCHAR(50) COLLATE DATABASE_DEFAULT,
	flow_date DATETIME
)
		
CREATE TABLE #temp_mdq_avail(dummy_column INT)

CREATE TABLE #temp_volume (
	term_date DATETIME
	, hr VARCHAR(10) COLLATE DATABASE_DEFAULT
	, is_dst INT
	, granularity INT
	, volume NUMERIC(38,20)
)



IF @product_group = 'Complex-EEX'
BEGIN
	SELECT @path_id = uddf.udf_value
	FROM source_deal_header sdh
	INNER JOIN user_defined_deal_fields_template_main uddft
		ON uddft.template_id = sdh.template_id
	INNER JOIN user_defined_deal_fields uddf
		ON uddf.source_deal_header_id = sdh.source_deal_header_id 
		AND uddf.udf_template_id = uddft.udf_template_id
	INNER JOIN user_defined_fields_template udft
		ON udft.field_id = uddft.field_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
		AND udft.Field_label = 'Delivery Path'
		AND NULLIF(uddf.udf_value, '') IS NOT NULL
		--AND ISNULL(sdh.description4, '') <> 'HAS_BEEN_ADJUSTED'

	SELECT  @from_location = from_location
			, @to_location = to_location
			, @path_contract_id = contract
	FROM delivery_path 
	WHERE path_id = @path_id

	SET @flow_date_from = @deal_term_start -- [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'f')
	SET @flow_date_to = @deal_term_end -- [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_end, 'f')
	
	WHILE (@flow_date_from <= @flow_date_to)
	BEGIN
		SET @process_id = dbo.FNAGetNewID()

		
		
		IF EXISTS (SELECT 1
					FROM optimizer_detail_downstream odd
					INNER JOIN SplitCommaSeperatedValues(@all_physical_deals) t
						ON t.item = odd.source_deal_header_id
						AND flow_date BETWEEN [dbo].[FNAGetFirstLastDayOfMonth](@flow_date_from, 'f')
							AND [dbo].[FNAGetFirstLastDayOfMonth](@flow_date_from, 'l')
						
					)
		BEGIN
			SET @reschedule = 1
		END
		ELSE 
		BEGIN
			SET @reschedule = 0
		END	

		--select top 2* from source_deal_header order by 1 desc 

		
		--EXEC [dbo].[spa_auto_deal_schedule]
		--	@source_deal_header_id = 12227,
		--	@reschedule = 0,
		--	@flow_date = '2000-09-01',
		--	@transport_deal_id = NULL,
		--	@process_id = '2A497721_932D_46BA_9BF7_A1B923A594E4'


		EXEC [dbo].[spa_auto_deal_schedule]
			@source_deal_header_id = @source_deal_header_id,
			@reschedule = @reschedule,
			@flow_date = @flow_date_from,
			@transport_deal_id = @transport_deal_id,
			@process_id = @process_id

		SET @inserted_updated_deals = dbo.FNAProcessTableName('inserted_updated_deals', @user_name, @process_id)

		SET @sql = '
			INSERT INTO #temp_transport_deal
			SELECT sdh.source_deal_header_id 
					, CASE LEFT(deal_id, 4) 
						WHEN ''schd'' THEN ''Transport''
							WHEN ''WTHD'' THEN ''Withdrawal''
							WHEN ''INJC'' THEN ''Injection''
					END,
					''' + CAST(@flow_date_from AS VARCHAR(50)) + '''
			FROM '+ @inserted_updated_deals + ' iud
			INNER JOIN source_deal_header sdh
				ON iud.source_deal_header_id = sdh.source_deal_header_id
			WHERE is_inserted = 1 
				OR  (	is_inserted = 0  
						AND internal_portfolio_id = ' + CAST(@product_group_id AS VARCHAR(10)) + 
					')'
		EXEC(@sql)

		IF @header_buy_sell_flag = 'b'
		BEGIN
			SET @sql = '
				UPDATE sdd
					SET buy_sell_flag = CASE WHEN leg = 1 THEN ''b'' ELSE ''s'' END
				FROM '+ @inserted_updated_deals + ' iud
				INNER JOIN source_deal_header sdh
					ON iud.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
				WHERE is_inserted = 1 
					'
			EXEC(@sql)

		END 

		--SET @flow_date_from = DATEADD(MONTH, 1, @flow_date_from);
		SET @flow_date_from =  [dbo].[FNAGetFirstLastDayOfMonth](DATEADD(MONTH, 1, @flow_date_from), 'f')
		
	END;

	IF EXISTS(SELECT 1 FROM #temp_transport_deal WHERE type = 'Transport')	
	BEGIN

		INSERT INTO  #temp_volume
		SELECT term_start
			, RIGHT( '0' + SUBSTRING(hr, 3, LEN(hr)), 2) + ':00'  hr
			, 0 AS is_dst 
			, MIN(granularity) granularity			
			, NULLIF(SUM(volume),0) volume
		FROM 
		(
		SELECT d.source_deal_header_id, term_start, granularity
			, hr1, hr2, hr3, hr4, hr5, hr6, hr7
			, hr8, hr9, hr10, hr11, hr12, hr13
			, hr14, hr15, hr16, hr17, hr18, hr19
			, hr20, hr21, hr22, hr23, hr24
		FROM report_hourly_position_deal d
		INNER JOIN SplitCommaSeperatedValues (@all_physical_deals) t
			ON d.source_deal_header_id = t.item
		UNION ALL
		SELECT p.source_deal_header_id, term_start, granularity
			, hr1, hr2, hr3, hr4, hr5, hr6, hr7
			, hr8, hr9, hr10, hr11, hr12, hr13
			, hr14, hr15, hr16, hr17, hr18, hr19
			, hr20, hr21, hr22, hr23, hr24
		FROM report_hourly_position_profile p
		INNER JOIN SplitCommaSeperatedValues (@all_physical_deals) t
			ON p.source_deal_header_id = t.item
		) p
		UNPIVOT
		(
			volume FOR hr IN (
				hr1, hr2, hr3, hr4, hr5, hr6, hr7
				, hr8, hr9, hr10, hr11, hr12, hr13
				, hr14, hr15, hr16, hr17, hr18, hr19
				, hr20, hr21, hr22, hr23, hr24
			)
		) unpvt
		GROUP BY term_start, hr

		UPDATE sddh
		SET volume = ABS(tv.volume)
		FROM #temp_transport_deal ttd
		INNER JOIN source_deal_detail sdd
			ON ttd.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd.term_start BETWEEN ttd.flow_date AND EOMONTH(ttd.flow_date)
		INNER JOIN 	#temp_volume tv
			ON tv.term_date = sdd.term_start 
			AND sdd.source_deal_header_id = ttd.source_deal_header_id
		INNER JOIN source_deal_detail_hour sddh 
			ON tv.term_date = sddh.term_date
			AND tv.hr = sddh.hr
			AND tv.is_dst = sddh.is_dst
			AND tv.granularity = sddh.granularity
			AND sddh.source_deal_detail_id = sdd.source_deal_detail_id

		INSERT INTO source_deal_detail_hour (
			source_deal_detail_id
			, term_date
			, hr
			, is_dst
			, volume
			, granularity
		)
		SELECT sdd.source_deal_detail_id
			, tv.term_date
			, tv.hr
			, tv.is_dst
			, ABS(tv.volume)
			, tv.granularity		
		FROM #temp_transport_deal ttd
		INNER JOIN source_deal_detail sdd
			ON ttd.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd.term_start BETWEEN ttd.flow_date AND EOMONTH(ttd.flow_date)
		INNER JOIN 	#temp_volume tv
			ON tv.term_date = sdd.term_start 
			AND sdd.source_deal_header_id = ttd.source_deal_header_id
		LEFT JOIN source_deal_detail_hour sddh 
			ON tv.term_date = sddh.term_date
			AND tv.hr = sddh.hr
			AND tv.is_dst = sddh.is_dst
			AND tv.granularity = sddh.granularity
			AND sddh.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE sddh.source_deal_detail_id IS NULL
		
		UPDATE sdh 
			SET internal_portfolio_id = @product_group_id
		FROM source_deal_header sdh
		INNER JOIN #temp_transport_deal ttd
			ON sdh.source_deal_header_id = ttd.source_deal_header_id	

	END 

	INSERT INTO #temp_updated_deals(source_deal_header_id)
	SELECT source_deal_header_id
	FROM #temp_transport_deal
	WHERE type = 'Transport'
	
	IF EXISTS(SELECT 1 FROM #temp_updated_deals)
	BEGIN

		SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
		IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_insert_process_table)
		END
	
		EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
					SELECT source_deal_header_id FROM #temp_updated_deals
					'
		EXEC(@sql)

		EXEC spa_deal_insert_update_jobs 'i', @after_insert_process_table
	
	END

	IF @header_buy_sell_flag = 'b'
	BEGIN
		SELECT @capacity_deal_id = sdh.source_deal_header_id
		FROM source_deal_header sdh
		INNER JOIN source_deal_header_template sdht
			ON sdh.template_id = sdht.template_id 
			AND sdh.contract_id = @path_contract_id
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
			AND sdd.location_id = CASE WHEN leg = 1 
									THEN @from_location 
									ELSE @to_location 							
									END 
		WHERE template_name = 'capacity bund'
			AND sdh.header_buy_sell_flag = 's'
			
		IF @capacity_deal_id IS NOT NULL
		BEGIN
			DELETE sddh
			FROM source_deal_detail_hour sddh
			INNER JOIN source_deal_detail sdd
				ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE sdd.source_deal_header_id = @capacity_deal_id
				
			INSERT INTO source_deal_detail_hour (
				source_deal_detail_id
				, term_date
				, hr
				, is_dst
				, volume
				, granularity
			)	
			SELECT sdd.source_deal_detail_id
				, pmh.term_start
				, RIGHT('0' + CAST(pmh.hour AS VARCHAR(5)), 2) + ':00' 
				, 0
				, pmh.rmdq
				, 982 			
			FROM [FNAGetPathMDQHourly](@path_id, @deal_term_start,@deal_term_end, '') pmh
			INNER JOIN source_deal_detail sdd
				ON pmh.term_start BETWEEN sdd.term_start  AND sdd.term_end
				AND sdd.source_deal_header_id = @capacity_deal_id
			WHERE pmh.is_complex = 'y'

		END


		INSERT INTO #temp_updated_deals(source_deal_header_id)
		SELECT @capacity_deal_id

		IF EXISTS(SELECT 1 FROM #temp_updated_deals)
		BEGIN

			SET  @job_process_id = dbo.FNAGETNEWID()

			SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
			IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
			BEGIN
				EXEC('DROP TABLE ' + @after_insert_process_table)
			END
	
			EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

			SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
						SELECT source_deal_header_id FROM #temp_updated_deals
						'
			EXEC(@sql)

			EXEC spa_deal_insert_update_jobs 'i', @after_insert_process_table	
		END
	END 
END
ELSE IF @product_group = 'Complex-LTO'
BEGIN

	SELECT @path_id = uddf.udf_value
	FROM source_deal_header sdh
	INNER JOIN user_defined_deal_fields_template_main uddft
		ON uddft.template_id = sdh.template_id
	INNER JOIN user_defined_deal_fields uddf
		ON uddf.source_deal_header_id = sdh.source_deal_header_id 
		AND uddf.udf_template_id = uddft.udf_template_id
	INNER JOIN user_defined_fields_template udft
		ON udft.field_id = uddft.field_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id 
		AND udft.Field_label = 'Delivery Path'
		AND NULLIF(uddf.udf_value, '') IS NOT NULL
		--AND ISNULL(sdh.description4, '') <> 'HAS_BEEN_ADJUSTED'

	SELECT  @from_location = from_location
			, @to_location = to_location
			, @path_contract_id = contract
	FROM delivery_path 
	WHERE path_id = @path_id

	--SET @flow_date_from = [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'f')
	--SET @flow_date_to = [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_end, 'f')

	SET @flow_date_from = @deal_term_start -- [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'f')
	SET @flow_date_to = @deal_term_end -- [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_end, 'f')

	
	WHILE (@flow_date_from <= @flow_date_to)
	BEGIN
		SET @process_id = dbo.FNAGetNewID()
		
		IF EXISTS (SELECT 1
					FROM optimizer_detail_downstream odd
					INNER JOIN SplitCommaSeperatedValues(@all_physical_deals) t
						ON t.item = odd.source_deal_header_id
						AND flow_date BETWEEN [dbo].[FNAGetFirstLastDayOfMonth](@flow_date_from, 'f')
							AND [dbo].[FNAGetFirstLastDayOfMonth](@flow_date_from, 'l')
					)
		BEGIN
			SET @reschedule = 1
		END
		ELSE 
		BEGIN
			SET @reschedule = 0
		END

		EXEC [dbo].[spa_auto_deal_schedule]
			@source_deal_header_id = @source_deal_header_id,
			@reschedule = @reschedule,
			@flow_date = @flow_date_from,
			@transport_deal_id = @transport_deal_id,
			@process_id = @process_id

		SET @inserted_updated_deals = dbo.FNAProcessTableName('inserted_updated_deals', @user_name, @process_id)

		SET @sql = '
			INSERT INTO #temp_transport_deal
			SELECT sdh.source_deal_header_id 
					, CASE LEFT(deal_id, 4) 
						WHEN ''schd'' THEN ''Transport''
							WHEN ''WTHD'' THEN ''Withdrawal''
							WHEN ''INJC'' THEN ''Injection''
					END,
					''' + CAST(@flow_date_from AS VARCHAR(50)) + '''
			FROM '+ @inserted_updated_deals + ' iud
			INNER JOIN source_deal_header sdh
				ON iud.source_deal_header_id = sdh.source_deal_header_id
			WHERE is_inserted = 1 
				OR  (	is_inserted = 0  
						AND internal_portfolio_id = ' + CAST(@product_group_id AS VARCHAR(10)) + 
					')'
		EXEC(@sql)

		IF @header_buy_sell_flag = 'b'
		BEGIN
			SET @sql = '
				UPDATE sdd
					SET buy_sell_flag = CASE WHEN leg = 1 THEN ''b'' ELSE ''s'' END
				FROM '+ @inserted_updated_deals + ' iud
				INNER JOIN source_deal_header sdh
					ON iud.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
				WHERE is_inserted = 1 
					'
			EXEC(@sql)

		END 

		SET @flow_date_from =  [dbo].[FNAGetFirstLastDayOfMonth](DATEADD(MONTH, 1, @flow_date_from), 'f')
		
	END;

	IF EXISTS(SELECT 1 FROM #temp_transport_deal WHERE type = 'Transport')	
	BEGIN
		INSERT INTO #temp_volume
		SELECT term_start
			, RIGHT( '0' + SUBSTRING(hr, 3, LEN(hr)), 2) + ':00'  hr
			, 0 AS is_dst 
			, MIN(granularity) granularity			
			, NULLIF(SUM(volume),0) volume
		FROM 
		(
		SELECT d.source_deal_header_id, term_start, granularity
			, hr1, hr2, hr3, hr4, hr5, hr6, hr7
			, hr8, hr9, hr10, hr11, hr12, hr13
			, hr14, hr15, hr16, hr17, hr18, hr19
			, hr20, hr21, hr22, hr23, hr24
		FROM report_hourly_position_deal d
		INNER JOIN SplitCommaSeperatedValues (@all_physical_deals) t
			ON d.source_deal_header_id = t.item
		UNION ALL
		SELECT p.source_deal_header_id, term_start, granularity
			, hr1, hr2, hr3, hr4, hr5, hr6, hr7
			, hr8, hr9, hr10, hr11, hr12, hr13
			, hr14, hr15, hr16, hr17, hr18, hr19
			, hr20, hr21, hr22, hr23, hr24
		FROM report_hourly_position_profile p
		INNER JOIN SplitCommaSeperatedValues (@all_physical_deals) t
			ON p.source_deal_header_id = t.item
		) p
		UNPIVOT
		(
			volume FOR hr IN (
				hr1, hr2, hr3, hr4, hr5, hr6, hr7
				, hr8, hr9, hr10, hr11, hr12, hr13
				, hr14, hr15, hr16, hr17, hr18, hr19
				, hr20, hr21, hr22, hr23, hr24
			)
		) unpvt
		GROUP BY term_start, hr
			
		UPDATE sddh
		SET volume = ABS(tv.volume)
		FROM #temp_transport_deal ttd
		INNER JOIN source_deal_detail sdd
			ON ttd.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd.term_start BETWEEN ttd.flow_date AND EOMONTH(ttd.flow_date)
		INNER JOIN 	#temp_volume tv
			ON tv.term_date = sdd.term_start 
			AND sdd.source_deal_header_id = ttd.source_deal_header_id
		INNER JOIN source_deal_detail_hour sddh 
			ON tv.term_date = sddh.term_date
			AND tv.hr = sddh.hr
			AND tv.is_dst = sddh.is_dst
			AND tv.granularity = sddh.granularity
			AND sddh.source_deal_detail_id = sdd.source_deal_detail_id
	
		INSERT INTO source_deal_detail_hour (
								source_deal_detail_id
								, term_date
								, hr
								, is_dst
								, volume
								, granularity
							)
		SELECT sdd.source_deal_detail_id
			, tv.term_date
			, tv.hr
			, tv.is_dst
			, ABS(tv.volume)
			, tv.granularity		
		FROM #temp_transport_deal ttd
		INNER JOIN source_deal_detail sdd
			ON ttd.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd.term_start BETWEEN ttd.flow_date AND EOMONTH(ttd.flow_date)
		INNER JOIN 	#temp_volume tv
			ON tv.term_date = sdd.term_start 
			AND sdd.source_deal_header_id = ttd.source_deal_header_id
		LEFT JOIN source_deal_detail_hour sddh 
			ON tv.term_date = sddh.term_date
			AND tv.hr = sddh.hr
			AND tv.is_dst = sddh.is_dst
			AND tv.granularity = sddh.granularity
			AND sddh.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE sddh.source_deal_detail_id IS NULL
		
		UPDATE sdh 
			SET internal_portfolio_id = @product_group_id
		FROM source_deal_header sdh
		INNER JOIN #temp_transport_deal ttd
			ON sdh.source_deal_header_id = ttd.source_deal_header_id	

	END 

	INSERT INTO #temp_updated_deals(source_deal_header_id)
	SELECT source_deal_header_id
	FROM #temp_transport_deal
	WHERE type = 'Transport'

	IF EXISTS(SELECT 1 FROM #temp_updated_deals)
	BEGIN

		SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
		IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_insert_process_table)
		END
	
		EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
					SELECT source_deal_header_id FROM #temp_updated_deals
					'
		EXEC(@sql)

		EXEC spa_deal_insert_update_jobs 'i', @after_insert_process_table
	
	END
	   
	IF @header_buy_sell_flag = 'b'
	BEGIN
		SELECT @capacity_deal_id = sdh.source_deal_header_id
		FROM source_deal_header sdh
		INNER JOIN source_deal_header_template sdht
			ON sdh.template_id = sdht.template_id 
			AND sdh.contract_id = @path_contract_id 
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
			AND sdd.location_id = CASE WHEN leg = 1 
									THEN @from_location 
									ELSE @to_location 						
									END 
		WHERE template_name = 'capacity bund'
			AND sdh.header_buy_sell_flag = 's'
			AND sdd.term_start BETWEEN @deal_term_start AND @deal_term_end
	
		IF @capacity_deal_id IS NOT NULL
		BEGIN

			DELETE sddh
			FROM source_deal_detail_hour sddh
			INNER JOIN source_deal_detail sdd
				ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE sdd.source_deal_header_id = @capacity_deal_id
			
			INSERT INTO source_deal_detail_hour 
			(
				source_deal_detail_id
				, term_date
				, hr
				, is_dst
				, volume
				, granularity
			)	
			SELECT sdd.source_deal_detail_id
				, pmh.term_start
				, RIGHT('0' + CAST(pmh.hour AS VARCHAR(5)), 2) + ':00' 
				, 0
				, pmh.rmdq
				, 982 			
			FROM [FNAGetPathMDQHourly](@path_id, @deal_term_start,@deal_term_end, '') pmh
			INNER JOIN source_deal_detail sdd
				ON pmh.term_start BETWEEN sdd.term_start  AND sdd.term_end
				AND sdd.source_deal_header_id =  @capacity_deal_id -- 9846 --
			WHERE pmh.is_complex = 'y'

			INSERT INTO #temp_updated_deals(source_deal_header_id)
			SELECT @capacity_deal_id

			IF EXISTS(SELECT 1 FROM #temp_updated_deals)
			BEGIN

				SET  @job_process_id = dbo.FNAGETNEWID()

				SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
				IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
				BEGIN
					EXEC('DROP TABLE ' + @after_insert_process_table)
				END
	
				EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

				SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
							SELECT source_deal_header_id FROM #temp_updated_deals
							'
				EXEC(@sql)

				EXEC spa_deal_insert_update_jobs 'i', @after_insert_process_table	
			END
		END 
	
	END

END 
ELSE IF @product_group = 'Complex-ROD'
BEGIN
	
	SET @flow_date_from = @deal_term_start -- [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'f')
	SET @flow_date_to = @deal_term_end -- [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_end, 'f')

	--SET @flow_date_from = [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'f')
	--SET @flow_date_to = [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_end, 'f')

	WHILE (@flow_date_from <= @flow_date_to)
	BEGIN
		SET @process_id = dbo.FNAGetNewID()

		IF @header_buy_sell_flag = 's'
		BEGIN
			IF EXISTS (SELECT 1
						FROM optimizer_detail_downstream odd
						INNER JOIN SplitCommaSeperatedValues(@all_physical_deals) t
							ON t.item = odd.source_deal_header_id
							AND flow_date BETWEEN [dbo].[FNAGetFirstLastDayOfMonth](@flow_date_from, 'f')
							AND [dbo].[FNAGetFirstLastDayOfMonth](@flow_date_from, 'l')
						)
			BEGIN
				SET @reschedule = 1
			END
			ELSE 
			BEGIN
				SET @reschedule = 0
			END
			
		END

		EXEC [dbo].[spa_auto_deal_schedule]
			@source_deal_header_id = @source_deal_header_id,
			@reschedule = @reschedule,
			@flow_date = @flow_date_from,
			@transport_deal_id = @transport_deal_id,
			@process_id = @process_id

		SET @inserted_updated_deals = dbo.FNAProcessTableName('inserted_updated_deals', @user_name, @process_id)

		SET @sql = '
			INSERT INTO #temp_transport_deal
			SELECT sdh.source_deal_header_id 
					, CASE LEFT(deal_id, 4) 
						WHEN ''schd'' THEN ''Transport''
							WHEN ''WTHD'' THEN ''Withdrawal''
							WHEN ''INJC'' THEN ''Injection''
					END,
					''' + CAST(@flow_date_from AS VARCHAR(50)) + '''
			FROM '+ @inserted_updated_deals + ' iud
			INNER JOIN source_deal_header sdh
				ON iud.source_deal_header_id = sdh.source_deal_header_id
			WHERE is_inserted = 1 
				OR  (	is_inserted = 0  
						AND internal_portfolio_id = ' + CAST(@product_group_id AS VARCHAR(10)) + 
					')'
			EXEC(@sql)
			
		SET @flow_date_from =  [dbo].[FNAGetFirstLastDayOfMonth](DATEADD(MONTH, 1, @flow_date_from), 'f')
	END;

	DELETE FROM #temp_transport_deal 
	WHERE type = 'Withdrawal' 
		AND @header_buy_sell_flag = 'b'

	IF EXISTS(SELECT 1 FROM #temp_transport_deal WHERE type = 'Transport')
	BEGIN

		INSERT INTO #temp_volume
		SELECT term_start
			, RIGHT( '0' + SUBSTRING(hr, 3, LEN(hr)), 2) + ':00'  hr
			, 0 AS is_dst 
			, MIN(granularity) granularity			
			, NULLIF(SUM(volume),0) volume
		FROM 
		(
		SELECT d.source_deal_header_id, term_start, granularity
			, hr1, hr2, hr3, hr4, hr5, hr6, hr7
			, hr8, hr9, hr10, hr11, hr12, hr13
			, hr14, hr15, hr16, hr17, hr18, hr19
			, hr20, hr21, hr22, hr23, hr24
		FROM report_hourly_position_deal d
		INNER JOIN SplitCommaSeperatedValues (@all_physical_deals) t
			ON d.source_deal_header_id = t.item
		UNION ALL
		SELECT p.source_deal_header_id, term_start, granularity
			, hr1, hr2, hr3, hr4, hr5, hr6, hr7
			, hr8, hr9, hr10, hr11, hr12, hr13
			, hr14, hr15, hr16, hr17, hr18, hr19
			, hr20, hr21, hr22, hr23, hr24
		FROM report_hourly_position_profile p
		INNER JOIN SplitCommaSeperatedValues (@all_physical_deals) t
			ON p.source_deal_header_id = t.item
		) p
		UNPIVOT
		(
			volume FOR hr IN (
				hr1, hr2, hr3, hr4, hr5, hr6, hr7
				, hr8, hr9, hr10, hr11, hr12, hr13
				, hr14, hr15, hr16, hr17, hr18, hr19
				, hr20, hr21, hr22, hr23, hr24
			)
		) unpvt
		GROUP BY term_start, hr
		
		UPDATE sddh
		SET volume = ABS(tv.volume)
		FROM #temp_transport_deal ttd
		INNER JOIN source_deal_detail sdd
			ON ttd.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd.term_start BETWEEN ttd.flow_date AND EOMONTH(ttd.flow_date)
		INNER JOIN 	#temp_volume tv
			ON tv.term_date = sdd.term_start 
			AND sdd.source_deal_header_id = ttd.source_deal_header_id
		INNER JOIN source_deal_detail_hour sddh 
			ON tv.term_date = sddh.term_date
			AND tv.hr = sddh.hr
			AND tv.is_dst = sddh.is_dst
			AND tv.granularity = sddh.granularity
			AND sddh.source_deal_detail_id = sdd.source_deal_detail_id

		INSERT INTO source_deal_detail_hour (
										source_deal_detail_id
										, term_date
										, hr
										, is_dst
										, volume
										, granularity
									)
		SELECT sdd.source_deal_detail_id
			, tv.term_date
			, tv.hr
			, tv.is_dst
			, ABS(tv.volume)
			, tv.granularity		
		FROM #temp_transport_deal ttd
		INNER JOIN source_deal_detail sdd
			ON ttd.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd.term_start BETWEEN ttd.flow_date AND EOMONTH(ttd.flow_date)
		INNER JOIN 	#temp_volume tv
			ON tv.term_date = sdd.term_start 
			AND sdd.source_deal_header_id = ttd.source_deal_header_id
		LEFT JOIN source_deal_detail_hour sddh 
			ON tv.term_date = sddh.term_date
			AND tv.hr = sddh.hr
			AND tv.is_dst = sddh.is_dst
			AND tv.granularity = sddh.granularity
			AND sddh.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE sddh.source_deal_detail_id IS NULL

		UPDATE sdh 
			SET internal_portfolio_id = @product_group_id
		FROM source_deal_header sdh
		INNER JOIN #temp_transport_deal ttd
			ON sdh.source_deal_header_id = ttd.source_deal_header_id	
	END 

	INSERT INTO #temp_updated_deals(source_deal_header_id)
	SELECT source_deal_header_id
	FROM #temp_transport_deal
	WHERE type IN ('Transport', 'Withdrawal')
	
	IF EXISTS(SELECT 1 FROM #temp_updated_deals)
	BEGIN

		SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
		IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_insert_process_table)
		END
	
		EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
					SELECT source_deal_header_id FROM #temp_updated_deals
					'
		EXEC(@sql)

		EXEC spa_deal_insert_update_jobs 'i', @after_insert_process_table

	END

END 
ELSE IF  @product_group IS NULL
BEGIN
	SELECT @path_id = uddf.udf_value
	FROM source_deal_header sdh
	INNER JOIN user_defined_deal_fields_template_main uddft
		ON uddft.template_id = sdh.template_id
	INNER JOIN user_defined_deal_fields uddf
		ON uddf.source_deal_header_id = sdh.source_deal_header_id 
		AND uddf.udf_template_id = uddft.udf_template_id
	INNER JOIN user_defined_fields_template udft
		ON udft.field_id = uddft.field_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id 
		AND udft.Field_label = 'Delivery Path'
		AND NULLIF(uddf.udf_value, '') IS NOT NULL
		--AND ISNULL(sdh.description4, '') <> 'HAS_BEEN_ADJUSTED'

	SELECT  @from_location = from_location
			, @to_location = to_location
			, @path_contract_id = contract
	FROM delivery_path 
	WHERE path_id = @path_id

	--SET @flow_date_from = [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'f')
	--SET @flow_date_to = [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_end, 'f')

	SET @flow_date_from = @deal_term_start -- [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'f')
	SET @flow_date_to = @deal_term_end -- [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_end, 'f')



	WHILE (@flow_date_from <= @flow_date_to)
	BEGIN
		SET @process_id = dbo.FNAGetNewID()
		
		IF EXISTS (SELECT 1
					FROM optimizer_detail_downstream odd
					INNER JOIN SplitCommaSeperatedValues(@all_physical_deals) t
						ON t.item = odd.source_deal_header_id
						AND flow_date BETWEEN [dbo].[FNAGetFirstLastDayOfMonth](@flow_date_from, 'f')
							AND [dbo].[FNAGetFirstLastDayOfMonth](@flow_date_from, 'l')
					)
		BEGIN
			SET @reschedule = 1
		END
		ELSE 
		BEGIN
			SET @reschedule = 0
		END

		EXEC [dbo].[spa_auto_deal_schedule]
			@source_deal_header_id = @source_deal_header_id,
			@reschedule = @reschedule,
			@flow_date = @flow_date_from,
			@transport_deal_id = @transport_deal_id,
			@process_id = @process_id

		SET @flow_date_from =  [dbo].[FNAGetFirstLastDayOfMonth](DATEADD(MONTH, 1, @flow_date_from), 'f')
	END

	
END

--12269

--select * from  source_Deal_header order by source_Deal_header_id desc