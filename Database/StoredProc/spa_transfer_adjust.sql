--IF OBJECT_ID(N'dbo.spa_transfer_adjust') IS NOT NULL
--    DROP PROCEDURE dbo.spa_transfer_adjust
--GO
 
--SET ANSI_NULLS ON
--GO

 
--SET QUOTED_IDENTIFIER ON 
--GO

--/**
--	Adjust transfer deal accorder to the physical deal

--	Parameters 
--	@source_deal_header_id: Deal id according to which transfer deal needs to be adjusted
--*/


----exec spa_transfer_adjust 101014


----SET @deal_term_start = '2012-01-01'
----SET @deal_term_end = '2012-01-01'


--CREATE PROCEDURE [dbo].[spa_transfer_adjust]
--	@source_deal_header_id INT
--	,@term DATETIME = NULL
--	,@is_deal_created BIT = NULL OUTPUT
--AS

--/* DEBUG

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


--select top 10 * from source_deal_header order by 1 desc
--103488

-- DECLARE @source_deal_header_id INT = 108076
 

--EXEC [dbo].[spa_transfer_adjust] @source_deal_header_id = 120208, @term = '2010-06-16'

DECLARE @source_deal_header_id INT = 106493 
DECLARE @term DATETIME = '2010-01-01'
DECLARE @is_deal_created BIT

--DECLARE @source_deal_header_id INT = 104615 



--DECLARE @source_deal_header_id INT = 103165 --102283 --s -- 103165 --
--DECLARE @source_deal_header_id INT = 100903 --b
--DECLARE @source_deal_header_id INT = 100573 -- 100582 --s(1) -- 100573 --s (22) --100546 -b (1)
 
--DECLARE @source_deal_header_id INT = 100582 -- 100582 --s(1) -- 100573 --s (22) --100546 -b (1)

--DECLARE @source_deal_header_id INT = 100633 -- 100582 --s(1) -- 100573 --s (22) --100546 -b (1)

--*/

--select top 10 * from  source_deal_header order by 1 desc


--capacity release: 106173; EEX Deals: 106351,108076



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
		, @all_physical_deals VARCHAR(2000)
		, @should_auto_path_calc BIT = 0
		, @all_physical_deals_capacity VARCHAR(2000)
		, @capacity_lto VARCHAR(2000)
		, @contract_id INT

SELECT @product_group = sdv.code 
	, @product_group_id = internal_portfolio_id
FROM source_deal_header
INNER JOIN static_data_value sdv
	ON sdv.value_id = internal_portfolio_id
WHERE source_deal_header_id =  @source_deal_header_id --  8774

IF EXISTS (
	SELECT 1 FROM source_deal_header sdh
	INNER JOIN source_deal_type sdt
		ON sdt.source_deal_Type_id = sdh.source_deal_Type_id
	WHERE deal_type_id IN ( 'physical', 'storage')
)
BEGIN
	SET @should_auto_path_calc = 1
END




--SET @deal_term_start = '2012-01-01'
--SET @deal_term_end = '2012-01-01'

IF @term IS NULL 
BEGIN
	SELECT  @deal_term_start = MIN(term_start)
		, @deal_term_end = MAX(term_end)
	FROM source_deal_detail 
	WHERE source_Deal_header_id = @source_deal_header_id   --8407 -- @source_deal_header_id  
	GROUP BY source_deal_header_id 
END 
ELSE 
BEGIN
	 SET @deal_term_start = @term
	 SET @deal_term_end = @term
END

-- This is for capacity deal only
-- This may have performance issue 
-- need to check if we have other better
-- solutions like using first/last day of month
DECLARE @capacity_term_start DATETIME
DECLARE @capacity_term_end DATETIME

SELECT  @capacity_term_start = MIN(term_start)
	, @capacity_term_end = MAX(term_end)
FROM source_deal_detail 
WHERE source_Deal_header_id = @source_deal_header_id   --8407 -- @source_deal_header_id  
GROUP BY source_deal_header_id 

SELECT @deal_location_id = MIN(location_id)
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


SET @capacity_lto = @all_physical_deals 

SET @all_physical_deals = @source_deal_header_id

SELECT  @all_physical_deals_capacity = ISNULL(@all_physical_deals_capacity + ',', '') + CAST(a.source_deal_header_id AS VARCHAR(10))
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
		--AND sdh.header_buy_sell_flag = @header_buy_sell_flag
		AND sdt.deal_type_id = 'Physical' 
) a


SELECT  @contract_id = st.agreement
FROM source_deal_header sdh
INNER JOIN user_defined_deal_fields_template_main uddft
	ON uddft.template_id = sdh.template_id
INNER JOIN user_defined_deal_fields uddf
	ON uddf.source_deal_header_id = sdh.source_deal_header_id 
	AND uddf.udf_template_id = uddft.udf_template_id
INNER JOIN user_defined_fields_template udft
	ON udft.field_id = uddft.field_id
--INNER JOIN contract_group cg
--	ON CAST(cg.contract_id AS NVARCHAR(10)) = uddf.udf_value
INNER JOIN general_assest_info_virtual_storage gs
	ON CAST(gs.agreement AS VARCHAR(10)) =  uddf.udf_value
LEFT JOIN general_assest_info_virtual_storage st 
	on st.general_assest_id = gs.general_assest_id
WHERE sdh.source_deal_header_id = @source_deal_header_id --7385 --
	AND udft.Field_label = 'storage contract'

--select @all_physical_deals return;

CREATE TABLE #temp_updated_deals (
	source_deal_header_id INT
)

CREATE TABLE #temp_transport_deal (
	source_deal_header_id INT,
	type VARCHAR(50)  COLLATE DATABASE_DEFAULT NULL,
	flow_date DATETIME NULL
)
		
CREATE TABLE #temp_mdq_avail(dummy_column INT)

CREATE TABLE #temp_volume (
	term_date DATETIME
	, hr VARCHAR(10) COLLATE DATABASE_DEFAULT
	, is_dst INT
	, granularity INT
	, volume NUMERIC(38,20)
)


CREATE TABLE #temp_volume_capacity (
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

	DECLARE @has_deal_scheduled BIT = 0


	WHILE (@flow_date_from <= @flow_date_to)
	BEGIN


		IF EXISTS(
			SELECT source_deal_header_id FROM optimizer_detail WHERE flow_date = @flow_date_from AND source_deal_header_id = @source_deal_header_id
			UNION ALL
			SELECT source_deal_header_id FROM optimizer_detail_downstream WHERE flow_date = @flow_date_from  AND source_deal_header_id = @source_deal_header_id
			UNION ALL
			SELECT source_deal_header_id FROM optimizer_detail_hour WHERE flow_date = @flow_date_from  AND source_deal_header_id = @source_deal_header_id
			UNION ALL
			SELECT source_deal_header_id FROM optimizer_detail_downstream_hour WHERE flow_date = @flow_date_from  AND source_deal_header_id = @source_deal_header_id
		)
		BEGIN
			EXEC spa_print 'Deal has aleady been scheduled';
			RETURN;
		END

		SET @process_id = dbo.FNAGetNewID()
		
		SET @reschedule = 0

		--select @source_deal_header_id,
		--	 @reschedule,
		--	 @flow_date_from,
		--	 @transport_deal_id,
		--	 @process_id

		

		EXEC [dbo].[spa_auto_deal_schedule]
			@source_deal_header_id = @source_deal_header_id,
			@reschedule = @reschedule,
			@flow_date = @flow_date_from,
			@transport_deal_id = @transport_deal_id,
			@process_id = @process_id

		SET @inserted_updated_deals = dbo.FNAProcessTableName('inserted_updated_deals', @user_name, @process_id)

		--START OF CHECK IF DEAL SAME DEAL UPDATED BY OTHER PROCESS
		SET @sql = '
			INSERT INTO #temp_transport_deal(source_deal_header_id)
			SELECT source_deal_header_id 
			FROM '+ @inserted_updated_deals + ' 
			WHERE source_deal_header_id = -9999
			'
		EXEC(@sql)


		IF EXISTS (SELECT 1 FROM  #temp_transport_deal WHERE source_deal_header_id = -9999) 
		BEGIN
			WAITFOR DELAY '00:00:15';

			-- RESTART AUTO SCHEDULE AFTER 15 SECONDS OF IT IS RUNNING BY OTHER PROCESS
			EXEC spa_transfer_adjust @source_deal_header_id, @is_deal_created= @is_deal_created			

			RETURN;
		END

		--END OF CHECK IF DEAL SAME DEAL UPDATED BY OTHER PROCESS


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

	UPDATE sdh
		SET sdh.deal_date = sdh_m.deal_date
	FROM #temp_transport_deal ttd
	INNER JOIN source_deal_header sdh 
		ON ttd.source_deal_header_id = sdh.source_deal_header_id
	CROSS JOIN source_deal_header sdh_m
	WHERE sdh_m.source_deal_header_id = @source_deal_header_id

	--IF @header_buy_sell_flag = 's'
	--BEGIN
	--	DELETE t from #temp_transport_deal t
	--	WHERE t.source_deal_header_id not in (
	--		SELECT DISTINCT sdd.source_deal_header_id 
	--		FROM #temp_transport_deal ttd
	--		INNER JOIN source_deal_detail sdd
	--			ON ttd.source_deal_header_id = sdd.source_deal_header_id
	--		WHERE sdd.leg = 1 AND buy_sell_flag = 's'
	--	)
	--END
	--ELSE 
	--BEGIN
	--	DELETE t from #temp_transport_deal t
	--	WHERE t.source_deal_header_id not in (
	--		SELECT DISTINCT sdd.source_deal_header_id 
	--		FROM #temp_transport_deal ttd
	--		INNER JOIN source_deal_detail sdd
	--			ON ttd.source_deal_header_id = sdd.source_deal_header_id
	--		WHERE sdd.leg = 1 AND buy_sell_flag = 'b'
	--	)

		
	--END 

	--select * from #temp_transport_deal
	
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


	--UPDATE uddf
	--	SET uddf.udf_value = @source_deal_header_id	
	--FROM #temp_transport_deal ttd
	--INNER JOIN user_defined_deal_fields uddf
	--	ON ttd.source_deal_header_id = uddf.source_deal_header_id
	--INNER JOIN source_deal_header sdh
	--	ON sdh.source_deal_header_id = uddf.source_deal_header_id
	--INNER JOIN user_defined_deal_fields_template uddft
	--	ON sdh.template_id = uddft.template_id 
	--	AND uddf.udf_template_id = uddft.udf_template_id	
	--	AND uddft.field_label = 'From Deal'
	
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
	--IF @header_buy_sell_flag = 'b'
	--BEGIN

		INSERT INTO  #temp_volume_capacity
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
		INNER JOIN SplitCommaSeperatedValues (@all_physical_deals_capacity) t
			ON d.source_deal_header_id = t.item
		UNION ALL
		SELECT p.source_deal_header_id, term_start, granularity
			, hr1, hr2, hr3, hr4, hr5, hr6, hr7
			, hr8, hr9, hr10, hr11, hr12, hr13
			, hr14, hr15, hr16, hr17, hr18, hr19
			, hr20, hr21, hr22, hr23, hr24
		FROM report_hourly_position_profile p
		INNER JOIN SplitCommaSeperatedValues (@all_physical_deals_capacity) t
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

		SELECT @capacity_deal_id = sdh.source_deal_header_id
		FROM source_deal_header sdh
		INNER JOIN source_deal_header_template sdht
			ON sdh.template_id = sdht.template_id 
			AND sdh.contract_id = @path_contract_id 
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN static_data_value sdv
			ON sdv.value_id = sdh.internal_portfolio_id
			AND sdv.type_id = 39800
		WHERE template_name = 'capacity bund'
			AND sdv.code = 'Complex-EEX'
			AND sdh.header_buy_sell_flag = 's'		
			AND @deal_term_start BETWEEN sdd.term_start AND sdd.term_end


			
			
		IF @capacity_deal_id IS NOT NULL
		BEGIN
			DELETE sddh	
			FROM [FNAGetPathMDQHourly] (@path_id, @capacity_term_start, @capacity_term_end, '') pmh --(330, '2020-09-25', '2020-09-25', '')pmh --
			INNER JOIN source_deal_detail sdd
				ON pmh.term_start BETWEEN sdd.term_start  AND sdd.term_end
				AND sdd.source_deal_header_id = @capacity_deal_id -- 106173 -- 
			INNER JOIN #temp_volume_capacity tvc
				ON tvc.term_date = pmh.term_start	
				AND RIGHT('0' + CAST(pmh.hour AS VARCHAR(5)), 2) + ':00'  = tvc.hr
			INNER JOIN source_deal_detail_hour sddh
				ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
				AND tvc.hr = sddh.hr
			WHERE pmh.is_complex = 'y'
				AND  sddh.term_date BETWEEN  @capacity_term_start AND @capacity_term_end


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
				,  IIF(ISNULL(tvc.volume, 0) <= 0, 0, pmh.rmdq)
				, 982 			
			FROM [FNAGetPathMDQHourly](@path_id, @capacity_term_start, @capacity_term_end, '') pmh
			INNER JOIN source_deal_detail sdd
				ON pmh.term_start BETWEEN sdd.term_start  AND sdd.term_end
				AND sdd.source_deal_header_id = @capacity_deal_id
			INNER JOIN #temp_volume_capacity tvc
				ON tvc.term_date = pmh.term_start	
				AND RIGHT('0' + CAST(pmh.hour AS VARCHAR(5)), 2) + ':00'  = tvc.hr
			WHERE pmh.is_complex = 'y'
				AND  pmh.term_start BETWEEN  @capacity_term_start AND @capacity_term_end

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


--select @flow_date_from , @flow_date_to, @product_group, @header_buy_sell_flag return;
	
	WHILE (@flow_date_from <= @flow_date_to)
	BEGIN
		SET @process_id = dbo.FNAGetNewID()
		
		IF EXISTS (SELECT  sdh.source_deal_header_id
					FROM user_defined_deal_fields uddf	
					INNER JOIN source_deal_header sdh
						ON sdh.source_deal_header_id = uddf.source_deal_header_id
					INNER JOIN user_defined_deal_fields_template uddft
						ON sdh.template_id = uddft.template_id 
						AND uddf.udf_template_id = uddft.udf_template_id	
						AND uddft.field_label = 'From Deal'
					INNER JOIN source_deal_header_template sdht
						ON sdht.template_id = sdh.template_id 
					INNER JOIN static_data_value sdv
						ON sdv.value_id = sdh.internal_portfolio_id
						AND sdv.type_id = 39800
					INNER JOIN source_deal_detail sdd
						ON sdd.source_deal_header_id = sdh.source_deal_header_id
					WHERE udf_value = CAST(@source_deal_header_id AS NVARCHAR(10))
						AND sdht.template_name = 'Transportation NG'
						AND sdv.code = 'Complex-LTO'
						AND YEAR(sdd.term_start) =  YEAR(@flow_date_from)
						AND MONTH(sdd.term_start) =  MONTH(@flow_date_from)
					GROUP BY sdh.source_deal_header_id
					-- HAVING MIN (sdd.term_start) BETWEEN @flow_date_from AND [dbo].[FNAGetFirstLastDayOfMonth](@flow_date_from, 'l')

					)
		BEGIN
			SET @reschedule = 1
		END
		ELSE 
		BEGIN
			SET @reschedule = 0
		END

		--set @reschedule = 0

		--select @reschedule,@flow_date_from, @flow_date_to

		--if @flow_date_from = '2002-01-01'
		--BEGIN
		--	select  @source_deal_header_id, @reschedule,@flow_date_from,@transport_deal_id,@process_id  return;
		--END


		EXEC [dbo].[spa_auto_deal_schedule]
			@source_deal_header_id = @source_deal_header_id,
			@reschedule = @reschedule,
			@flow_date = @flow_date_from,
			@transport_deal_id = @transport_deal_id,
			@process_id = @process_id


		SET @inserted_updated_deals = dbo.FNAProcessTableName('inserted_updated_deals', @user_name, @process_id)

		--START OF CHECK IF DEAL SAME DEAL UPDATED BY OTHER PROCESS
		SET @sql = '
			INSERT INTO #temp_transport_deal(source_deal_header_id)
			SELECT source_deal_header_id 
			FROM '+ @inserted_updated_deals + ' 
			WHERE source_deal_header_id = -9999
			'
		EXEC(@sql)


		IF EXISTS (SELECT 1 FROM  #temp_transport_deal WHERE source_deal_header_id = -9999) 
		BEGIN
			WAITFOR DELAY '00:00:15';

			-- RESTART AUTO SCHEDULE AFTER 15 SECONDS OF IT IS RUNNING BY OTHER PROCESS
			EXEC spa_transfer_adjust @source_deal_header_id, @is_deal_created= @is_deal_created	

			RETURN;
		END

		--END OF CHECK IF DEAL SAME DEAL UPDATED BY OTHER PROCESS


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


	

		--SELECT *
		--FROM user_defined_deal_fields uddf    
		--INNER JOIN source_deal_header sdh
		--	ON sdh.source_deal_header_id = uddf.source_deal_header_id
		--INNER JOIN  #temp_transport_deal ttd
		--	ON ttd.source_deal_header_id = sdh.source_deal_header_id

		--INNER JOIN user_defined_deal_fields_template uddft
		--	ON sdh.template_id = uddft.template_id 
		--	AND uddf.udf_template_id = uddft.udf_template_id    
		--	AND uddft.field_label = 'From Deal'    
		--WHERE udf_value = 103165


		--	print @sql


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


		--start of should remove this block
		IF @header_buy_sell_flag = 'b'
		BEGIN

	
			DELETE ttd
			FROM #temp_transport_deal ttd
			INNER JOIN source_deal_detail sdd
				ON ttd.source_deal_header_id = sdd.source_deal_header_id
			WHERE leg = 1 
				AND	sdd.buy_sell_flag = 's'
		END
		ELSE
		BEGIN
			
			DELETE ttd
			FROM #temp_transport_deal ttd
			INNER JOIN source_deal_detail sdd
				ON ttd.source_deal_header_id = sdd.source_deal_header_id
			WHERE leg = 1 
				AND	sdd.buy_sell_flag = 'b'
		END 
		--end of should remove this block

		SET @flow_date_from =  [dbo].[FNAGetFirstLastDayOfMonth](DATEADD(MONTH, 1, @flow_date_from), 'f')
		
	END;

	UPDATE sdh
		SET sdh.deal_date = sdh_m.deal_date
	FROM #temp_transport_deal ttd
	INNER JOIN source_deal_header sdh 
		ON ttd.source_deal_header_id = sdh.source_deal_header_id
	CROSS JOIN source_deal_header sdh_m
	WHERE sdh_m.source_deal_header_id = @source_deal_header_id

	DELETE ttd
	FROM user_defined_deal_fields uddf    
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = uddf.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft
		ON sdh.template_id = uddft.template_id 
		AND uddf.udf_template_id = uddft.udf_template_id    
		AND uddft.field_label = 'From Deal'   
	INNER JOIN  #temp_transport_deal ttd
		ON ttd.source_deal_header_id = uddf.source_deal_header_id
	WHERE udf_value <>  @source_deal_header_id

	--return;

	IF EXISTS(SELECT 1 FROM #temp_transport_deal WHERE type = 'Transport')	
	BEGIN

		--UPDATE uddf
		--	SET uddf.udf_value = @source_deal_header_id	
		--FROM #temp_transport_deal ttd
		--INNER JOIN user_defined_deal_fields uddf
		--	ON ttd.source_deal_header_id = uddf.source_deal_header_id
		--INNER JOIN source_deal_header sdh
		--	ON sdh.source_deal_header_id = uddf.source_deal_header_id
		--INNER JOIN user_defined_deal_fields_template uddft
		--	ON sdh.template_id = uddft.template_id 
		--	AND uddf.udf_template_id = uddft.udf_template_id	
		--	AND uddft.field_label = 'From Deal' 

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
			--AND sdd.location_id = CASE WHEN leg = 1 
			--						THEN @from_location 
			--						ELSE @to_location 						
			--						END 
		WHERE template_name = 'capacity bund'
			AND sdh.header_buy_sell_flag = 's'
			--AND sdd.term_start BETWEEN @deal_term_start AND @deal_term_end
			AND @deal_term_start BETWEEN sdd.term_start AND sdd.term_end
			AND sdh.description1 = 'LTO Buy'


		IF @capacity_deal_id IS NOT NULL
		BEGIN

			DELETE sddh
			FROM source_deal_detail_hour sddh
			INNER JOIN source_deal_detail sdd
				ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE sdd.source_deal_header_id = @capacity_deal_id
			AND sddh.term_date BETWEEN @capacity_term_start and @capacity_term_end

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
				, MAX(pmh.rmdq) rmdq
				, 982 								
			FROM [FNAGetPathMDQHourly]( @path_id, @capacity_term_start, @capacity_term_end, '') pmh
			INNER JOIN source_deal_detail sdd
				ON pmh.term_start BETWEEN sdd.term_start  AND sdd.term_end
				--AND sdd.term_start = pmh.term_start
				AND sdd.source_deal_header_id = @capacity_deal_id --99311 -- 9846 -		
			INNER JOIN source_deal_detail_hour sddh	
				ON sddh.term_date = pmh.term_start
				AND RIGHT('0' + CAST(pmh.hour AS VARCHAR(5)), 2) + ':00'  = sddh.hr
			INNER JOIN source_deal_detail sdd_m
				ON sddh.source_deal_detail_id = sdd_m.source_deal_detail_id
				--AND sdd_m.source_deal_header_id = @source_deal_header_id --100766 -- 9846 -	
			INNER JOIN SplitCommaSeperatedValues(@capacity_lto) t
				ON sdd_m.source_deal_header_id = t.item
			WHERE pmh.is_complex = 'y' 
				 AND sdd.leg = 1
				 AND NULLIF(sddh.volume, 0) IS NOT NULL
				 AND pmh.term_start BETWEEN @capacity_term_start and @capacity_term_end
			GROUP BY  sdd.source_deal_detail_id
				, pmh.term_start
				, pmh.hour
			UNION ALL
			SELECT sdd.source_deal_detail_id
				, pmh.term_start
				, RIGHT('0' + CAST(pmh.hour AS VARCHAR(5)), 2) + ':00' 
				, 0
				, MAX(pmh.rmdq) rmdq
				, 982 								
			FROM [FNAGetPathMDQHourly]( @path_id, @capacity_term_start,@capacity_term_end, '') pmh
			INNER JOIN source_deal_detail sdd
				ON pmh.term_start BETWEEN sdd.term_start  AND sdd.term_end
				--AND sdd.term_start = pmh.term_start
				AND sdd.source_deal_header_id = @capacity_deal_id -- 9846 -		
			INNER JOIN source_deal_detail_hour sddh	
				ON sddh.term_date = pmh.term_start
				AND RIGHT('0' + CAST(pmh.hour AS VARCHAR(5)), 2) + ':00'  = sddh.hr
			INNER JOIN source_deal_detail sdd_m
				ON sddh.source_deal_detail_id = sdd_m.source_deal_detail_id
			--	AND sdd_m.source_deal_header_id = @source_deal_header_id -- 9846 -	
			INNER JOIN SplitCommaSeperatedValues(@capacity_lto) t
				ON sdd_m.source_deal_header_id = t.item
			WHERE pmh.is_complex = 'y' 
				 AND sdd.leg = 2
				 AND NULLIF(sddh.volume, 0) IS NOT NULL
				 AND pmh.term_start BETWEEN @capacity_term_end and @capacity_term_end
			GROUP BY  sdd.source_deal_detail_id
				, pmh.term_start
				, pmh.hour
				
				--select @path_id, @deal_term_start,@deal_term_end, @capacity_deal_id

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
	ELSE IF @header_buy_sell_flag = 's'
	BEGIN

		SELECT @capacity_deal_id = 	sdh.source_deal_header_id
		FROM source_deal_header sdh
		INNER JOIN source_deal_header_template sdht
			ON sdh.template_id = sdht.template_id 
			AND sdh.contract_id = @path_contract_id 
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
		WHERE template_name = 'capacity bund'
			AND sdh.header_buy_sell_flag = 'b'
			--AND sdd.term_start BETWEEN @deal_term_start AND @deal_term_end
			AND @deal_term_start BETWEEN sdd.term_start AND sdd.term_end
			AND sdh.description1 = 'LTO Sell'


		IF @capacity_deal_id IS NOT NULL
		BEGIN
			DELETE sddh
			FROM source_deal_detail_hour sddh
			INNER JOIN source_deal_detail sdd
				ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE sdd.source_deal_header_id = @capacity_deal_id
			AND sddh.term_date BETWEEN @capacity_term_start and @capacity_term_end

			INSERT INTO source_deal_detail_hour (
							source_deal_detail_id
							, term_date
							, hr
							, is_dst
							, volume
							, granularity
						)

			SELECT sdd.source_deal_detail_id,
				sddh_m.term_date,
				sddh_m.hr,
				MAX(cast(sddh_m.is_dst as int)) is_dst,
				SUM(sddh_m.volume) volume,
				MAX(sddh_m.granularity) granularity
			FROM source_deal_detail_hour sddh_m
			INNER JOIN source_deal_detail sdd_m
				ON sdd_m.source_deal_detail_id = sddh_m.source_deal_detail_id
			INNER JOIN source_deal_detail sdd 
				ON sdd.term_start BETWEEN sdd_m.term_start  AND sdd_m.term_end
			INNER JOIN SplitCommaSeperatedValues(@capacity_lto) t
				ON sdd_m.source_deal_header_id = t.item
			WHERE  --sdd_m.source_deal_header_id = 102283 AND --@source_deal_header_id
				 NULLIF(sddh_m.volume, 0) IS NOT NULL
				AND sdd.source_deal_header_id =  @capacity_deal_id
				AND sddh_m.term_date BETWEEN @capacity_term_start and @capacity_term_end
			GROUP BY sdd.source_deal_detail_id,
				sddh_m.term_date,
				sddh_m.hr


				--100890	102283
				--select @capacity_deal_id, @source_deal_header_id

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


	SELECT  @path_contract_id = contract
	FROM delivery_path 
	WHERE path_id = @path_id

	
	SET @flow_date_from = @deal_term_start -- [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'f')
	SET @flow_date_to = @deal_term_end -- [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_end, 'f')

	--SET @flow_date_from = [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_start, 'f')
	--SET @flow_date_to = [dbo].[FNAGetFirstLastDayOfMonth](@deal_term_end, 'f')


	WHILE (@flow_date_from <= @flow_date_to)
	BEGIN
		SET @process_id = dbo.FNAGetNewID()

		IF @header_buy_sell_flag = 's'
		BEGIN
			IF EXISTS (SELECT  sdh.source_deal_header_id
						FROM user_defined_deal_fields uddf	
						INNER JOIN source_deal_header sdh
							ON sdh.source_deal_header_id = uddf.source_deal_header_id
						INNER JOIN user_defined_deal_fields_template uddft
							ON sdh.template_id = uddft.template_id 
							AND uddf.udf_template_id = uddft.udf_template_id	
							AND uddft.field_label = 'From Deal'
						INNER JOIN source_deal_header_template sdht
							ON sdht.template_id = sdh.template_id 
						INNER JOIN static_data_value sdv
							ON sdv.value_id = sdh.internal_portfolio_id
							AND sdv.type_id = 39800
						INNER JOIN source_deal_detail sdd
							ON sdd.source_deal_header_id = sdh.source_deal_header_id
						WHERE udf_value = CAST(@source_deal_header_id AS NVARCHAR(10))
							AND sdht.template_name = 'Transportation NG'
							AND sdv.code = 'Complex-ROD'							
							AND YEAR(sdd.term_start) =  YEAR(@flow_date_from)
							AND MONTH(sdd.term_start) =  MONTH(@flow_date_from) 
						GROUP BY sdh.source_deal_header_id
						-- HAVING MIN (sdd.term_start) BETWEEN @flow_date_from AND [dbo].[FNAGetFirstLastDayOfMonth](@flow_date_from, 'l')
						)
			BEGIN
				SET @reschedule = 1
			END
			ELSE 
			BEGIN
				SET @reschedule = 0
			END
			
		END


		--SELECT 	@source_deal_header_id,
		--	@reschedule,
		--	@flow_date_from,
		--	@transport_deal_id,
		--	@process_id
		--	return;

		
			
		EXEC [dbo].[spa_auto_deal_schedule]
			@source_deal_header_id = @source_deal_header_id,
			@reschedule = @reschedule,
			@flow_date = @flow_date_from,
			@transport_deal_id = @transport_deal_id,
			@process_id = @process_id

		SET @inserted_updated_deals = dbo.FNAProcessTableName('inserted_updated_deals', @user_name, @process_id)


		--START OF CHECK IF DEAL SAME DEAL UPDATED BY OTHER PROCESS
		SET @sql = '
			INSERT INTO #temp_transport_deal(source_deal_header_id)
			SELECT source_deal_header_id 
			FROM '+ @inserted_updated_deals + ' 
			WHERE source_deal_header_id = -9999
			'
		EXEC(@sql)


		IF EXISTS (SELECT 1 FROM  #temp_transport_deal WHERE source_deal_header_id = -9999) 
		BEGIN
			WAITFOR DELAY '00:00:15';

			-- RESTART AUTO SCHEDULE AFTER 15 SECONDS OF IT IS RUNNING BY OTHER PROCESS
			EXEC spa_transfer_adjust @source_deal_header_id, @is_deal_created= @is_deal_created	

			RETURN;
		END

		--END OF CHECK IF DEAL SAME DEAL UPDATED BY OTHER PROCESS


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


	DELETE ttd
	FROM user_defined_deal_fields uddf    
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = uddf.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft
		ON sdh.template_id = uddft.template_id 
		AND uddf.udf_template_id = uddft.udf_template_id    
		AND uddft.field_label = 'From Deal'   
	INNER JOIN  #temp_transport_deal ttd
		ON ttd.source_deal_header_id = uddf.source_deal_header_id
	WHERE udf_value <>  @source_deal_header_id


	--UPDATE uddf
	--	SET uddf.udf_value = @source_deal_header_id	
	--FROM #temp_transport_deal ttd
	--INNER JOIN user_defined_deal_fields uddf
	--	ON ttd.source_deal_header_id = uddf.source_deal_header_id
	--INNER JOIN source_deal_header sdh
	--	ON sdh.source_deal_header_id = uddf.source_deal_header_id
	--INNER JOIN user_defined_deal_fields_template uddft
	--	ON sdh.template_id = uddft.template_id 
	--	AND uddf.udf_template_id = uddft.udf_template_id	
	--	AND uddft.field_label = 'From Deal'
	
	UPDATE sdh
		SET sdh.deal_date = sdh_m.deal_date,
		 sdh.contract_id = IIF(ttd.type = 'Withdrawal', @contract_id, sdh.contract_id)
	FROM #temp_transport_deal ttd
	INNER JOIN source_deal_header sdh 
		ON ttd.source_deal_header_id = sdh.source_deal_header_id
	CROSS JOIN source_deal_header sdh_m
	WHERE sdh_m.source_deal_header_id = @source_deal_header_id

	--DELETE FROM #temp_transport_deal 
	--WHERE type = 'Withdrawal' 
	--	AND @header_buy_sell_flag = 'b'

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

	SELECT @capacity_deal_id = sdh.source_deal_header_id
	FROM source_deal_header sdh
	INNER JOIN source_deal_header_template sdht
		ON sdh.template_id = sdht.template_id 
		AND sdh.contract_id = @path_contract_id 
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN static_data_value sdv
		ON sdv.value_id = sdh.internal_portfolio_id
		AND sdv.type_id = 39800
	WHERE template_name = 'capacity unbund-Entry'
		AND sdv.code = 'Complex-ROD'
		AND sdh.header_buy_sell_flag = 'b'		
		AND @deal_term_start BETWEEN sdd.term_start AND sdd.term_end

	IF @capacity_deal_id IS NOT NULL
	BEGIN
		DELETE sddh
		FROM source_deal_detail_hour sddh
		INNER JOIN source_deal_detail sdd
			ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE sdd.source_deal_header_id = @capacity_deal_id
		AND sddh.term_date BETWEEN @capacity_term_start and @capacity_term_end

		INSERT INTO source_deal_detail_hour (
						source_deal_detail_id
						, term_date
						, hr
						, is_dst
						, volume
						, granularity
					)			
		SELECT  sdd.source_deal_detail_id,
			sddh_m.term_date,
			sddh_m.hr,
			MAX(CAST(sddh_m.is_dst AS INT)) is_dst,
			SUM(sddh_m.volume) volume,
			MAX(sddh_m.granularity) granularity
		FROM source_deal_detail_hour sddh_m
		INNER JOIN source_deal_detail sdd_m
			ON sdd_m.source_deal_detail_id = sddh_m.source_deal_detail_id
		INNER JOIN source_deal_detail sdd 
			ON sdd.term_start BETWEEN sdd_m.term_start  AND sdd_m.term_end
		INNER JOIN SplitCommaSeperatedValues(@capacity_lto) t
			ON sdd_m.source_deal_header_id = t.item
		WHERE --sdd_m.source_deal_header_id = 102283 AND --@source_deal_header_id
			NULLIF(sddh_m.volume, 0) IS NOT NULL
			AND sdd.source_deal_header_id =  @capacity_deal_id
			AND sddh_m.term_date BETWEEN @capacity_term_start and @capacity_term_end
		GROUP BY sdd.source_deal_detail_id,
			sddh_m.term_date,
			sddh_m.hr

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
ELSE IF @product_group = 'Autopath Only' AND @should_auto_path_calc = 1
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

		IF EXISTS(
			SELECT  sdh.source_deal_header_id
						FROM user_defined_deal_fields uddf	
						INNER JOIN source_deal_header sdh
							ON sdh.source_deal_header_id = uddf.source_deal_header_id
						INNER JOIN user_defined_deal_fields_template uddft
							ON sdh.template_id = uddft.template_id 
							AND uddf.udf_template_id = uddft.udf_template_id	
							AND uddft.field_label = 'From Deal'
						INNER JOIN source_deal_header_template sdht
							ON sdht.template_id = sdh.template_id 
						INNER JOIN static_data_value sdv
							ON sdv.value_id = sdh.internal_portfolio_id
							AND sdv.type_id = 39800
						INNER JOIN source_deal_detail sdd
							ON sdd.source_deal_header_id = sdh.source_deal_header_id
						WHERE udf_value = CAST(@source_deal_header_id AS NVARCHAR(10))
							AND sdht.template_name = 'Transportation NG'
							AND sdv.code = @product_group
							AND YEAR(sdd.term_start) =  YEAR(@flow_date_from)
							AND MONTH(sdd.term_start) =  MONTH(@flow_date_from) 
						GROUP BY sdh.source_deal_header_id	)
		BEGIN
			SET @reschedule = 1
		END
		ELSE
		BEGIN
			SET @reschedule = 0
		END


		--	select 
		--	 @source_deal_header_id,
		--	 @reschedule,
		--	 @flow_date_from,
		--	@transport_deal_id,
		--	@process_id
		
		--return;

		EXEC [dbo].[spa_auto_deal_schedule]
			@source_deal_header_id = @source_deal_header_id,
			@reschedule = @reschedule,
			@flow_date = @flow_date_from,
			@transport_deal_id = @transport_deal_id,
			@process_id = @process_id
		

		SET @inserted_updated_deals = dbo.FNAProcessTableName('inserted_updated_deals', @user_name, @process_id)

		
		--START OF CHECK IF DEAL SAME DEAL UPDATED BY OTHER PROCESS
		SET @sql = '
			INSERT INTO #temp_transport_deal(source_deal_header_id)
			SELECT source_deal_header_id 
			FROM '+ @inserted_updated_deals + ' 
			WHERE source_deal_header_id = -9999
			'
		EXEC(@sql)


		IF EXISTS (SELECT 1 FROM  #temp_transport_deal WHERE source_deal_header_id = -9999) 
		BEGIN
			WAITFOR DELAY '00:00:15';

			-- RESTART AUTO SCHEDULE AFTER 15 SECONDS OF IT IS RUNNING BY OTHER PROCESS
			EXEC spa_transfer_adjust @source_deal_header_id, @is_deal_created= @is_deal_created	
			
			RETURN;
		END

		--END OF CHECK IF DEAL SAME DEAL UPDATED BY OTHER PROCESS


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

	END

	INSERT INTO #temp_updated_deals(source_deal_header_id)
	SELECT source_deal_header_id
	FROM #temp_transport_deal
	--WHERE type IN ('Transport', 'Withdrawal')

	DELETE ttd
	FROM user_defined_deal_fields uddf    
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = uddf.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft
		ON sdh.template_id = uddft.template_id 
		AND uddf.udf_template_id = uddft.udf_template_id    
		AND uddft.field_label = 'From Deal'   
	INNER JOIN  #temp_transport_deal ttd
		ON ttd.source_deal_header_id = uddf.source_deal_header_id
	WHERE udf_value <>  @source_deal_header_id
	
	--UPDATE uddf
	--	SET uddf.udf_value = @source_deal_header_id	
	--FROM #temp_transport_deal ttd
	--INNER JOIN user_defined_deal_fields uddf
	--	ON ttd.source_deal_header_id = uddf.source_deal_header_id
	--INNER JOIN source_deal_header sdh
	--	ON sdh.source_deal_header_id = uddf.source_deal_header_id
	--INNER JOIN user_defined_deal_fields_template uddft
	--	ON sdh.template_id = uddft.template_id 
	--	AND uddf.udf_template_id = uddft.udf_template_id	
	--	AND uddft.field_label = 'From Deal' 

	UPDATE sdh
		SET sdh.deal_date = sdh_m.deal_date
	FROM #temp_transport_deal ttd
	INNER JOIN source_deal_header sdh 
		ON ttd.source_deal_header_id = sdh.source_deal_header_id
	CROSS JOIN source_deal_header sdh_m
	WHERE sdh_m.source_deal_header_id = @source_deal_header_id


	--DELETE FROM #temp_transport_deal 
	--WHERE type IN( 'Withdrawal' , 'Injection')
	--	AND @header_buy_sell_flag = 'b'
		

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

IF EXISTS (SELECT 1 FROM #temp_transport_deal)
BEGIN
	SET @is_deal_created = 1
END