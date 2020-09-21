IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_auto_deal_schedule]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_auto_deal_schedule]
	
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Auto schedule deal according to its delivery path
	
	Parameters
	@source_deal_header_id : Source Deal Header Id to be scheduled
	@reschedule: flag for reschedule 1 for reschedule AND 0 for schedule
	@flow_date: Deal term date
	@transport_deal_id: Transport_deal_id which needed to be adjusted.
	@process_id: Process ID

*/
CREATE PROC [dbo].[spa_auto_deal_schedule]
	@source_deal_header_id INT,
	@reschedule BIT = 0,
	@flow_date DATETIME,
	@transport_deal_id INT = NULL,
	@process_id VARCHAR(500) = NULL
AS

/** Debug

--SELECT top 10 * FROM source_deal_header order by source_deal_header_id desc

DECLARE @source_deal_header_id INT,
	@reschedule BIT = 0,
	@flow_date DATETIME,
	@transport_deal_id INT,
	@process_id VARCHAR(500)

	--Drops all temp tables created in this scope.
	EXEC [spa_drop_all_temp_table] 
	EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'dmanandhar'
	
		SELECT
			@source_deal_header_id = 101012,
			@reschedule = 0,
			@flow_date = '2011-01-01',
			@transport_deal_id = NULL,
			@process_id = 'D1C85BE3_853B_4838_A9AD_5624AACF4910'
			
	
	
--**/
SET NOCOUNT ON
DECLARE  @flow_date_from DATETIME
		, @flow_date_to DATETIME
		, @from_location INT
		, @to_location INT 
		, @uom INT		
		, @period_from NVARCHAR (500)
		, @path_id INT
		, @counterparty_id INT
		, @contract INT
		, @template_name VARCHAR(500) = 'Transportation NG'
		, @subbook_id INT
		, @path_priority INT  = -31400 --Point-Point
		, @opt_objective INT = 38301 -- Maximum Flow based ON Location Ranking
		, @xml_manual_vol NVARCHAR(MAX)
		, @hourly_pos_info NVARCHAR(500)
		, @opt_deal_detail_pos NVARCHAR(500)
		, @user_name NVARCHAR(200) = dbo.FNADBUser()
		, @mdq NUMERIC(38,20)
		, @loss_factor NUMERIC(38,20)
		, @sql NVARCHAR(MAX)
		, @buy_sell CHAR(1)
		, @receipt_deals_id VARCHAR(100)
		, @delivery_deals_id VARCHAR(100)
		, @location_id INT
		, @multiplier INT
		, @call_from VARCHAR(100)
		, @storage_asset_id INT
		, @granularity INT

CREATE TABLE #hourly_pos_info ( 
	source_deal_header_id INT
	, location_id INT
	, curve_id INT
	, term_start DATETIME
	, granularity INT
	, hour INT
	, position INT
	, source_deal_detail_id INT
)

CREATE TABLE #opt_deal_detail_pos ( 
	term_start DATETIME,
	position NUMERIC(38, 20)
)

SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())

SET @flow_date_from = @flow_date
SET @flow_date_to = @flow_date



SET @call_from = IIF(@transport_deal_id IS NULL, 'flow_auto', NULL);

SET @reschedule = IIF(@transport_deal_id IS NULL, @reschedule, 1);

SELECT @uom = deal_volume_uom_id 
FROM source_deal_header_template sdht
INNER JOIN source_deal_detail_template sddt
	ON sdht.template_id = sddt.template_id
WHERE template_name = 'Transportation NG'

SELECT @buy_sell = header_buy_sell_flag 
FROM source_deal_header 
WHERE source_deal_header_id = @source_deal_header_id --7385

SELECT @granularity = profile_granularity
FROM source_deal_header sdh
WHERE source_deal_header_id = @source_deal_header_id --7385 -- @source_deal_header_id

SELECT @path_id = uddf.udf_value
FROM source_deal_header sdh
INNER JOIN user_defined_deal_fields_template_main uddft
	ON uddft.template_id = sdh.template_id
INNER JOIN user_defined_deal_fields uddf
	ON uddf.source_deal_header_id = sdh.source_deal_header_id 
	AND uddf.udf_template_id = uddft.udf_template_id
INNER JOIN user_defined_fields_template udft
	ON udft.field_id = uddft.field_id
WHERE sdh.source_deal_header_id = @source_deal_header_id --7385 --
	AND udft.Field_label = 'Delivery Path'

SELECT @storage_asset_id = gs.general_assest_id
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
WHERE sdh.source_deal_header_id = @source_deal_header_id --7385 --
	AND udft.Field_label = 'storage contract'
	
SELECT @from_location = from_location, 
	@to_location = to_location ,
	@counterparty_id = counterparty,
	@contract = contract
FROM delivery_path 
WHERE path_id = @path_id --161 --

SELECT @mdq = mdq
FROM [delivery_path_mdq] dpm
CROSS APPLY(
	SELECT MAX(effective_date) effective_date
	FROM [dbo].[delivery_path_mdq]
	WHERE path_id = dpm.path_id
	AND effective_date <= @flow_date_from -- '2019-11-11'
) sub
WHERE dpm.path_id = @path_id --161 --@path_id
	AND dpm.effective_date = sub.effective_date

SELECT @mdq = ISNULL(mdq, 0)
	, @loss_factor = ISNULL(loss_factor, 0)
FROM delivery_path 
WHERE path_id = @path_id --161
	AND @mdq IS NULL

SELECT @loss_factor = ISNULL(loss_factor, 0)
FROM delivery_path 
WHERE path_id = @path_id --161

SELECT @subbook_id = clm2_value 
FROM generic_mapping_header gmh
INNER JOIN generic_mapping_definition gmd
	ON gmh.mapping_table_id = gmd.mapping_table_id
INNER JOIN [generic_mapping_values] gmv
	ON gmv.mapping_table_id = gmd.mapping_table_id 
WHERE mapping_name = 'Flow Optimization Mapping'
AND clm1_value = CAST(@counterparty_id AS VARCHAR(10)) --7943


IF @granularity = 981
BEGIN

	SET @receipt_deals_id = IIF(@transport_deal_id IS NULL, @source_deal_header_id, NULL)
	SET @delivery_deals_id = IIF(@transport_deal_id IS NULL, '-1', NULL)

	EXEC spa_flow_optimization  @flag = 'c', @sub = NULL, @str = NULL, @book = NULL, @sub_book_id = NULL, 
	@flow_date_from = @flow_date_from
	, @flow_date_to = @flow_date_to
	, @from_location = @from_location
	, @to_location = @to_location
	, @path_priority = @path_priority
	, @opt_objective = @opt_objective
	, @priority_from = NULL, @priority_to = NULL, @contract_id = NULL, @pipeline_ids = NULL
	, @uom = @uom
	, @process_id = @process_id
	, @delivery_path = NULL
	, @reschedule = @reschedule
	, @granularity = @granularity
	, @period_from = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24'
	, @call_from = @call_from
	, @receipt_deals_id = @receipt_deals_id
	, @delivery_deals_id = @delivery_deals_id
	
END 
ELSE IF @granularity = 982
BEGIN
	SET @receipt_deals_id = IIF(@transport_deal_id IS NULL, @source_deal_header_id, NULL)
	SET @delivery_deals_id = IIF(@transport_deal_id IS NULL, '-1', NULL)


	--select 	@flow_date_from
	--, @flow_date_to
	--, @from_location
	--, @to_location
	--, @path_priority
	--, @opt_objective	
	--, @uom
	--, @process_id
	--, @reschedule
	--, @granularity
	--, @call_from
	--, @receipt_deals_id
	--, @delivery_deals_id


	--return;

	EXEC spa_flow_optimization_hourly 
	@flag = 'c'
	, @sub = NULL
	, @str = NULL
	, @book = NULL
	, @sub_book_id = null --@subbook_id
	, @flow_date_from = @flow_date_from
	, @flow_date_to = @flow_date_to
	, @from_location = @from_location
	, @to_location = @to_location
	, @path_priority = @path_priority
	, @opt_objective = @opt_objective
	, @priority_from = NULL
	, @priority_to = NULL
	, @contract_id = NULL
	, @pipeline_ids = NULL
	, @uom = @uom
	, @process_id = @process_id
	, @delivery_path = NULL
	, @reschedule = @reschedule
	, @granularity = @granularity
	, @period_from = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24'
	, @call_from = @call_from
	, @receipt_deals_id = @receipt_deals_id
	, @delivery_deals_id = @delivery_deals_id

END

SET @hourly_pos_info = dbo.FNAProcessTableName('hourly_pos_info', @user_name, @process_id) 
SET @opt_deal_detail_pos = dbo.FNAProcessTableName('opt_deal_detail_pos', @user_name, @process_id) 

IF @granularity = 981
BEGIN
	SET @sql = N'INSERT INTO #opt_deal_detail_pos (term_start, position)
				SELECT term_start, position
				FROM  ' + @opt_deal_detail_pos + '
				WHERE source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10))+ '
					AND position <> 0
					AND term_start BETWEEN ''' + CONVERT(VARCHAR(10), @flow_date_from, 21) + ''' AND ''' + CONVERT(VARCHAR(10), @flow_date_to, 21) + '''
				'
	EXEC(@sql)
	
	SELECT @xml_manual_vol = (
		SELECT 1 AS '@box_id'
			, @path_id AS '@path_id'
			, - 1 AS '@single_path_id'
			, @contract AS '@contract_id'
			--, CAST(term_start AS DATE) AS '@term_start'
			, position AS '@rec_vol'
			, position AS '@del_vol'
			, @loss_factor AS '@loss_factor'
			, 'n' AS '@storage_deal_type'
			, 0 AS '@storage_asset_id'
			, 0 AS '@storage_volume'
	FROM #opt_deal_detail_pos
		FOR XML path('PSRecordset')
			,ROOT('Root')
	)
	--print @xml_manual_vol
	EXEC spa_flow_optimization  @flag = 'z', @process_id = @process_id , @xml_manual_vol = @xml_manual_vol, @call_from = @call_from

END
ELSE IF @granularity = 982
BEGIN

	SET @location_id = CASE WHEN @buy_sell = 'b' THEN @from_location ELSE @to_location END
	SET @multiplier = CASE WHEN @buy_sell = 'b' THEN 1 ELSE -1 END

	IF @transport_deal_id IS NULL
	BEGIN
		SET @sql = N'
			IF NOT EXISTS(
				SELECT 1 
				FROM ' + @hourly_pos_info + ' hpi
				INNER JOIN source_deal_header sdh
					ON sdh.source_deal_header_id = hpi.source_deal_header_id 
				INNER JOIN static_data_value sdv
					ON sdv.value_id = sdh.internal_portfolio_id
					AND type_id = 39800
				WHERE sdv.code IN (''Complex-LTO'', ''Complex-ROD'', ''Autopath Only'')
					AND position >0	
			)
			BEGIN

				DECLARE @term_date_with_value DATETIME
	
				SELECT @term_date_with_value = sddh.term_date
				FROM source_deal_detail_hour sddh
				INNER JOIN source_deal_detail sdd
					ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
				WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10)) + ' 
					AND YEAR(sddh.term_date) = YEAR(''' + CAST(@flow_date AS VARCHAR(50)) + ''' )
					AND MONTH(sddh.term_date) = MONTH(''' + CAST(@flow_date AS VARCHAR(50)) + ''' )	
					AND ISNULL(sddh.volume, 0) > 0 

				
				DELETE FROM ' + @hourly_pos_info + '

				IF @term_date_with_value IS NOT NULL
				BEGIN
					INSERT INTO ' + @hourly_pos_info + '
					SELECT sdd.source_deal_header_id
							, sdd.location_id
							, sdd.curve_id	
							, sdd.term_start
							, sdh.profile_granularity
							, CAST(LEFT( sddh.hr, 2) AS INT)
							, 0
							, sddh.volume
							, sdd.source_deal_detail_id
					FROM source_deal_header sdh
					INNER JOIN source_deal_detail sdd
						ON sdd.source_deal_header_id = sdh.source_deal_header_id
						AND sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10)) + ' 
					INNER JOIN source_deal_detail_hour sddh
						ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
					WHERE sddh.term_date = @term_date_with_value
				END

			END 
		'
			
		--print @sql
		EXEC(@sql)

		SET @sql = N'
		INSERT INTO #hourly_pos_info ( source_deal_header_id,location_id, curve_id, term_start, granularity, hour, position, source_deal_detail_id)
		SELECT source_deal_header_id
			, location_id
			, curve_id
			, term_start
			, granularity
			, hour
			, position
			, source_deal_detail_id
		FROM  ' + @hourly_pos_info + '
		WHERE source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10)) + '
			AND position <> 0
			AND YEAR(term_start) = YEAR(''' + CAST(@flow_date AS VARCHAR(50)) + ''' )
			AND MONTH(term_start) = MONTH(''' + CAST(@flow_date AS VARCHAR(50)) + ''' )	'
		--print @sql
		EXEC(@sql)

	END 
	ELSE 
	BEGIN

		SELECT source_deal_header_id,location_id, curve_id, term_start, 982 granularity,
			hr1, hr2, hr3, hr4, hr5,hr6, hr7, hr8
			,hr9, hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16
			,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22, hr23, hr24
		INTO #hourly_pos_info_pivoted
		FROM report_hourly_position_deal 
		WHERE source_deal_header_id = @source_deal_header_id --8407
			AND term_start = @flow_date --'2000-11-01'
			AND location_id = @to_location --2853 -- @to_location
		UNION ALL
		SELECT source_deal_header_id,location_id, curve_id,term_start, @granularity granularity,
			hr1, hr2, hr3, hr4, hr5,hr6, hr7, hr8
			,hr9, hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16
			,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22, hr23, hr24
		FROM report_hourly_position_profile 
		WHERE source_deal_header_id = @source_deal_header_id -- 8407
			AND term_start = @flow_date -- '2000-11-01'
			AND location_id = @to_location -- 2853 -- 

		SELECT source_deal_header_id,location_id, curve_id, term_start, 982 granularity,
			hr1, hr2, hr3, hr4, hr5,hr6, hr7, hr8
			,hr9, hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16
			,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22, hr23, hr24
		INTO #hourly_pos_info_trans_pivoted
		FROM report_hourly_position_deal 
		WHERE source_deal_header_id = @transport_deal_id --8406
			AND term_start = @flow_date -- '2000-11-01'
			AND location_id = @to_location --2853
		UNION ALL
		SELECT source_deal_header_id,location_id, curve_id,term_start, 982 granularity,
			hr1, hr2, hr3, hr4, hr5,hr6, hr7, hr8
			,hr9, hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16
			,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22, hr23, hr24
		FROM report_hourly_position_profile 
		WHERE source_deal_header_id = @transport_deal_id -- 8406
			AND term_start = @flow_date
			AND location_id = @to_location -- 2853
					
		SELECT NULL source_deal_header_id, 
				hpi.location_id, 
				hpi.curve_id,
				hpi.term_start,
				hpi.granularity,
				hpit.hr1 - hpi.hr1 hr1,
				hpit.hr2 - hpi.hr2 hr2,
				hpit.hr3 - hpi.hr3 hr3,
				hpit.hr4 - hpi.hr4 hr4,
				hpit.hr5 - hpi.hr5 hr5,
				hpit.hr6 - hpi.hr6 hr6,
				hpit.hr7 - hpi.hr7 hr7,
				hpit.hr8 - hpi.hr8 hr8,
				hpit.hr9 - hpi.hr9 hr9,
				hpit.hr10 - hpi.hr10 hr10,
				hpit.hr11 - hpi.hr11 hr11,
				hpit.hr12 - hpi.hr12 hr12,
				hpit.hr13 - hpi.hr13 hr13,
				hpit.hr14 - hpi.hr14 hr14,
				hpit.hr15 - hpi.hr15 hr15,
				hpit.hr16 - hpi.hr16 hr16,
				hpit.hr17 - hpi.hr17 hr17,
				hpit.hr18 - hpi.hr18 hr18,
				hpit.hr19 - hpi.hr19 hr19,
				hpit.hr20 - hpi.hr20 hr20,
				hpit.hr21 - hpi.hr21 hr21,
				hpit.hr22 - hpi.hr22 hr22,
				hpit.hr23 - hpi.hr23 hr23,
				hpit.hr24 - hpi.hr24 hr24
		INTO #hourly_pos_info_adjusted
		FROM #hourly_pos_info_trans_pivoted hpit
		INNER JOIN  #hourly_pos_info_pivoted hpi
			ON hpit.location_id = hpi.location_id
			AND hpit.curve_id = hpi.curve_id
			AND hpit.term_start = hpi.term_start
			AND hpit.granularity = hpi.granularity
		
		INSERT INTO #hourly_pos_info( 
			source_deal_header_id
			, location_id
			, curve_id
			, term_start
			, granularity
			, hour
			, position
		)
		SELECT NULL source_deal_header_id
			, location_id
			, curve_id
			, term_start
			, granularity
			, REPLACE(hr, 'hr', '')
			, position
		FROM
		(	
			SELECT * 
			FROM #hourly_pos_info_adjusted
		)p
		UNPIVOT
		 (position FOR hr IN 
		 (hr1, hr2, hr3, hr4, hr5,hr6, hr7, hr8
			,hr9, hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16
			,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22, hr23, hr24)
		 ) AS unpvt

	END

	SELECT @xml_manual_vol = (
		SELECT @from_location AS '@from_loc_id'
				, @to_location AS '@to_loc_id'
				, @path_id AS '@path_id'
				, @contract AS '@contract_id'
				--, CAST(term_start AS DATE) AS '@term_start'
				, [hour] AS '@hour'
				, position * @multiplier AS '@received'
				, position * (1 - @loss_factor)  * @multiplier AS '@delivered'
				, (@mdq - position) * @multiplier AS '@path_rmdq'
				, @storage_asset_id AS '@storage_asset_id' --
			FROM #hourly_pos_info
			FOR XML PATH('PSRecordset')
				, ROOT('Root')
	)

	EXEC spa_flow_optimization_hourly 
		@flag = 's2'
		, @process_id = @process_id
		, @xml_manual_vol = @xml_manual_vol
		, @call_from = @call_from
END 

IF @transport_deal_id IS NULL
BEGIN

	--IF (@buy_sell = 'b')
	--BEGIN	
	--	SET @receipt_deals_id  = @source_deal_header_id 
	--	SET @delivery_deals_id  = '-1'
	--END
	--ELSE
	--BEGIN
	--	SET @receipt_deals_id  =  '-1'
	--	SET @delivery_deals_id  = @source_deal_header_id 
	--END

	SET @receipt_deals_id  =  '-1'
	SET @delivery_deals_id  = @source_deal_header_id 

END
ELSE 
BEGIN
	SET @receipt_deals_id = NULL
	SET @delivery_deals_id = NULL
END 

SET @call_from = IIF(@transport_deal_id IS NULL, 'flow_auto', 'flow_opt');

--SELECT
--	@flow_date_from
--	, @flow_date_to
--	,  @process_id
	
--	,@call_from
--	,  @uom
--	, @reschedule
--	, @granularity
--	,  @receipt_deals_id 
--	,  @delivery_deals_id

--return;



EXEC spa_schedule_deal_flow_optimization  
	@flag = 'i'
	, @box_ids = '1'
	, @flow_date_from = @flow_date_from
	, @flow_date_to = @flow_date_to
	, @sub = NULL
	, @str = NULL
	, @book = NULL
	, @sub_book = NULL
	, @contract_process_id = @process_id
	, @from_priority = NULL
	, @to_priority = NULL
	, @call_from = @call_from
	, @target_uom = @uom
	, @reschedule = @reschedule
	, @granularity = @granularity
	, @receipt_deals_id  = @receipt_deals_id 
	, @delivery_deals_id  = @delivery_deals_id


	

GO


	
