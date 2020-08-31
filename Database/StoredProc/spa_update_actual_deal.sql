
IF OBJECT_ID(N'[dbo].[spa_update_actual_deal]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_update_actual_deal]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	SP used to process deal data and updated deal volume and actual volume while saving deal 
   
	Parameters:
		@flag					:	Operation flag that decides the action to be performed. Does not accept NULL.
		@source_deal_header_id 	:	Deal Header Id
		@source_deal_detail_id 	:	Deal Detail Id
		@term_start 			:	Term Start of Deal
		@term_end 				:	Term End of Deal
		@hour_from				:	Hour From
		@hour_to 				:	Hour To
		@process_id 			:	Process Id to create process table
		@leg 					:	Leg of Deal
		@xml 					:	Data to be processed 
*/

CREATE PROCEDURE [dbo].[spa_update_actual_deal]
    @flag NCHAR(1),	
	@source_deal_header_id INT,
	@source_deal_detail_id INT = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@process_id NVARCHAR(300) = NULL,
	@leg INT = NULL,
	@xml XML = NULL
AS
SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX),
		@desc NVARCHAR(500),
		@err_no INT,
		@actual_granularity INT,
		@frequency NCHAR(1),
		@max_leg INT,
		@column_list NVARCHAR(MAX),
		@column_label NVARCHAR(MAX),
		@column_type NVARCHAR(MAX),
		@column_width NVARCHAR(MAX),
		@column_visibility NVARCHAR(MAX),
		@pivot_columns NVARCHAR(MAX), 
		@pivot_columns_create NVARCHAR(MAX), 
		@pivot_columns_update NVARCHAR(MAX),
		@select_list NVARCHAR(MAX),
		@max_term_end DATETIME,
		@min_term_start DATETIME,
		@deal_type_id INT,
		@pricing_type INT,
		@commodity_id INT

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID() 
DECLARE @user_name NVARCHAR(100) = dbo.FNADBUser()
SELECT @max_term_end = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
SELECT @min_term_start = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id

DECLARE @process_table NVARCHAR(400) = dbo.FNAProcessTableName('actual_volume', @user_name, @process_id)

SELECT @deal_type_id = sdh.source_deal_type_id,
	   @pricing_type = sdh.pricing_type,
	   @commodity_id = sdh.commodity_id	   
FROM source_deal_header sdh
WHERE sdh.source_deal_header_id = @source_deal_header_id

--994 - 10Min, 987 - 15Min, 989 - 30Min, 993 - Annually, 981 - Daily, 982 - Hourly, 980 - Monthly, 991 - Quarterly, 992 - Semi-Annually, 990 - Weekly
SELECT @actual_granularity = sdht.actual_granularity
FROM source_deal_header sdh
INNER JOIN source_deal_header_template sdht On sdht.template_id = sdh.template_id
WHERE sdh.source_deal_header_id = @source_deal_header_id

IF EXISTS(SELECT 1 FROM deal_default_value WHERE deal_type_id = @deal_type_id AND commodity = @commodity_id AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type))
BEGIN
	SELECT @actual_granularity = ISNULL(actual_granularity, @actual_granularity)
	FROM deal_default_value 
	WHERE deal_type_id = @deal_type_id 
	AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)
	AND commodity = @commodity_id
END


IF @term_start IS NULL
BEGIN
	IF @source_deal_detail_id IS NOT NULL
		SELECT @term_start = term_start FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id
	ELSE
		SELECT @term_start = MIN(term_start) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
END

IF @term_end IS NULL
BEGIN
	IF @source_deal_detail_id IS NOT NULL
		SELECT @term_end = term_end FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id
	ELSE
		SELECT @term_end = MAX(term_end) FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id
END

IF @max_term_end < @term_end
	SET @term_end = @max_term_end
IF @min_term_start > @term_start
	SET @term_start = @min_term_start

--a	Annually, d	Daily, h - Hourly, m - Monthly, q - Quarterly, s - Semi-Annually
SELECT @frequency = ISNULL(sdh.term_frequency, sdht.term_frequency_type)
FROM source_deal_header sdh
INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
WHERE sdh.source_deal_header_id = @source_deal_header_id

DECLARE @limit_term_end DATETIME
	
--a	Annually, d	Daily, h - Hourly, m - Monthly, q - Quarterly, s - Semi-Annually
IF @frequency IN ('d', 'h')
	SET @limit_term_end = DATEADD(day, 30, @term_start)
IF @frequency = 'm'
	SET @limit_term_end = DATEADD(month, 30, @term_start)
IF @frequency = 'w'
	SET @limit_term_end = DATEADD(week, 30, @term_start)
IF @frequency = 'q'
	SET @limit_term_end = DATEADD(quarter, 15, @term_start)
IF @frequency = 's'
	SET @limit_term_end = DATEADD(year, 15, @term_start)

IF OBJECT_ID('tempdb..#temp_actual_terms') IS NOT NULL
	DROP TABLE #temp_actual_terms

CREATE TABLE #temp_actual_terms (term_start DATETIME, is_dst INT)

;WITH cte_terms AS (
 	SELECT @term_start [term_start]
 	UNION ALL
 	SELECT dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1)
 	FROM cte_terms cte 
 	WHERE dbo.FNAGetTermStartDate(@frequency, cte.[term_start], 1) <= @term_end
) 
INSERT INTO #temp_actual_terms(term_start)
SELECT term_start
FROM cte_terms cte
option (maxrecursion 0)

DECLARE @baseload_block_type       NVARCHAR(10),
		@baseload_block_define_id  NVARCHAR(10)
		
SET @baseload_block_type = '12000'	-- Internal Static Data

SELECT @baseload_block_define_id = CAST(value_id AS NVARCHAR(10))
FROM   static_data_value
WHERE  [type_id] = 10018
		AND code LIKE 'Base Load' -- External Static Data

IF OBJECT_ID('tempdb..#temp_detail_ids') IS NOT NULL 
	DROP TABLE #temp_detail_ids
CREATE TABLE #temp_detail_ids (detail_id INT)

IF @source_deal_detail_id IS NOT NULL
BEGIN
	INSERT INTO #temp_detail_ids
	SELECT @source_deal_detail_id
END
ELSE
BEGIN
	INSERT INTO #temp_detail_ids
	SELECT sdd.source_deal_detail_id 
	FROM source_deal_detail sdd
	WHERE sdd.source_deal_header_id = @source_deal_header_id
	AND ((@term_start IS NULL AND @term_end IS NULL) OR (sdd.term_start BETWEEN @term_start AND @term_end))
END

IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#temp_deal_acutal_data') IS NOT NULL 
		DROP TABLE #temp_deal_acutal_data

	CREATE TABLE #temp_deal_acutal_data(source_deal_header_id INT, source_deal_detail_id INT, leg INT, term_start DATETIME, volume NUMERIC(38, 20), actual_volume NUMERIC(38, 20), schedule_volume NUMERIC(38, 20), term_date_p NVARCHAR(8) COLLATE DATABASE_DEFAULT)
	
	INSERT INTO #temp_deal_acutal_data(source_deal_header_id, source_deal_detail_id, leg, term_start, volume, actual_volume, schedule_volume, term_date_p)
	SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.leg, sdd.term_start, sdd.deal_volume, sdd.actual_volume, sdd.schedule_volume, CONVERT(NVARCHAR(8), sdd.term_start, 112)
	FROM source_deal_detail sdd
	INNER JOIN #temp_detail_ids temp ON temp.detail_id = sdd.source_deal_detail_id

	CREATE NONCLUSTERED INDEX NCI_TDAD_DEAL ON #temp_deal_acutal_data (source_deal_detail_id)
	CREATE NONCLUSTERED INDEX NCI_TDAD_TERM ON #temp_deal_acutal_data (term_start)

	SELECT @pivot_columns = COALESCE(@pivot_columns + ',', '') + '[' + CONVERT(NVARCHAR(8), term_start, 112) + ']',
			@pivot_columns_create = COALESCE(@pivot_columns_create + ',', '') + '[' + CONVERT(NVARCHAR(8), term_start, 112) + '] NUMERIC(38, 20)  NULL',
			@pivot_columns_update = COALESCE(@pivot_columns_update + ',', '') + '[' + CONVERT(NVARCHAR(8), term_start, 112) + '] = a.[' + CONVERT(NVARCHAR(8), term_start, 112) + ']'
	FROM #temp_actual_terms
	ORDER BY term_start		
			
	SET @sql = '
		CREATE TABLE ' + @process_table + '(
				source_deal_header_id INT,
				source_deal_detail_id INT,
				leg INT,
				type NCHAR(1),
				type_name NVARCHAR(100),
				term_start DATETIME NULL,
				' + @pivot_columns_create + '
		)
			
		INSERT INTO ' + @process_table + ' (source_deal_header_id, leg, type, type_name)
		SELECT sdd.source_deal_header_id, sdd.leg, vol_type.type, vol_type.type_name
		FROM (
			SELECT source_deal_header_id, leg
			FROM #temp_deal_acutal_data	
			GROUP BY source_deal_header_id, leg
		) sdd
		OUTER APPLY (
			SELECT ''a'' [type], ''Actual Volume'' [type_name] UNION ALL
			SELECT ''s'', ''Schedule Volume'' UNION ALL
			SELECT ''v'', ''Deal Volume'' 
		) vol_type
		'
	--PRINT(@sql)
	EXEC(@sql)

	SET @sql = '
		UPDATE temp
		SET ' + @pivot_columns_update + '
		FROM ' + @process_table + ' temp
		INNER JOIN 
		(
			SELECT source_deal_header_id, ' + @pivot_columns + '
			FROM (
				SELECT source_deal_header_id, term_date_p, volume
				FROM  #temp_deal_acutal_data temp 
			) a			
			PIVOT (SUM(volume) FOR term_date_p IN (' + @pivot_columns + ') )unpvt
		) a ON temp.source_deal_header_id = a.source_deal_header_id AND temp.[type] = ''v''
		'
	--PRINT(@sql)
	EXEC(@sql)

	SET @sql = '
		UPDATE temp
		SET ' + @pivot_columns_update + '
		FROM ' + @process_table + ' temp
		INNER JOIN 
		(
			SELECT source_deal_header_id, ' + @pivot_columns + '
			FROM (
				SELECT source_deal_header_id, term_date_p, actual_volume
				FROM  #temp_deal_acutal_data temp 
			) a			
			PIVOT (SUM(actual_volume) FOR term_date_p IN (' + @pivot_columns + ') )unpvt
		) a ON temp.source_deal_header_id = a.source_deal_header_id AND temp.[type] = ''a''
		'
	--PRINT(@sql)
	EXEC(@sql)

	SET @sql = '
		UPDATE temp
		SET ' + @pivot_columns_update + '
		FROM ' + @process_table + ' temp
		INNER JOIN 
		(
			SELECT source_deal_header_id, ' + @pivot_columns + '
			FROM (
				SELECT source_deal_header_id, term_date_p, schedule_volume
				FROM  #temp_deal_acutal_data temp
			) a			
			PIVOT (SUM(schedule_volume) FOR term_date_p IN (' + @pivot_columns + ') )unpvt
		) a ON temp.source_deal_header_id = a.source_deal_header_id AND temp.[type] = ''s''
		'
	--PRINT(@sql)
	EXEC(@sql)
	
	DECLARE @is_locked NCHAR(1)
	SELECT @is_locked = ISNULL(deal_locked, 'n') FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id

	SELECT @max_leg = MAX(leg) FROM source_deal_detail where source_deal_header_id = @source_deal_header_id
	SELECT @actual_granularity [granularity],
		   @max_leg [max_leg],
		   @term_start [term_start],
		   CASE WHEN @limit_term_end < @term_end THEN @limit_term_end ELSE @term_end END [term_end],
		   @process_id [process_id],
		   dbo.FNADateFormat(@min_term_start) [min_term_start],
		   dbo.FNADateFormat(@max_term_end) [max_term_end],
		   @is_locked [is_locked]
	RETURN
END

-- Returns Grid Definitions
IF @flag = 't'
BEGIN
    SELECT @column_list = COALESCE(@column_list + ',', '') + CONVERT(NVARCHAR(8), term_start, 112),
			@column_label = COALESCE(@column_label + ',', '') + dbo.FNADateFormat(term_start),
			@column_type = COALESCE(@column_type + ',', '') + 'ed_no',
			@column_width = COALESCE(@column_width + ',', '') + '150',
			@column_visibility = COALESCE(@column_visibility + ',', '') + 'false'
	FROM #temp_actual_terms
	WHERE term_start <= @term_end

	SET @column_list = 'source_deal_header_id,leg,type,type_name,' + @column_list
	SET @column_label = 'Deal ID,Leg,Type,Type,' + @column_label
	SET @column_type = 'ro,ro,ro,ro,' + @column_type
	SET @column_width = '100,50,10,100,' + @column_width
	SET @column_visibility = 'false,false,true,false,' + @column_visibility

	SELECT @max_leg = MAX(leg) FROM source_deal_detail where source_deal_header_id = @source_deal_header_id

	SELECT @column_list [column_list],
		   @column_label [column_label],
		   @column_type [column_type],
		   @column_width [column_width],
		   @term_start [term_start],
		   @term_end [term_end],
		   @actual_granularity [granularity],
		   @max_leg [max_leg],
		   @column_visibility [visibility]
END
-- Returns data
IF @flag = 'a'
BEGIN
	SELECT @column_list = COALESCE(@column_list + ',', '') + 'dbo.FNARemoveTrailingZero([' + CONVERT(NVARCHAR(8), term_start, 112) + ']) [' + CONVERT(NVARCHAR(8), term_start, 112) + ']'
	FROM #temp_actual_terms
	WHERE term_start <= @term_end
	
	SET @column_list = 'source_deal_header_id,leg,type,type_name,' + @column_list
	--PRINT('SELECT ' + @column_list + ' FROM ' + @process_table)
	EXEC('SELECT ' + @column_list + ' FROM ' + @process_table + ' ORDER BY term_start')
END
IF @flag = 'u'
BEGIN
	BEGIN TRY
		IF @xml IS NOT NULL
 		BEGIN
 			DECLARE @xml_process_table NVARCHAR(200)
 			SET @xml_process_table = dbo.FNAProcessTableName('xml_table', @user_name, dbo.FNAGetNewID())
 		
 			EXEC spa_parse_xml_file 'b', NULL, @xml, @xml_process_table

			IF OBJECT_ID('tempdb..#temp_header_columns') IS NOT NULL
 				DROP TABLE #temp_header_columns
 		
 			CREATE TABLE #temp_header_columns (
 				columns_name NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
 				columns_value NVARCHAR(MAX) COLLATE DATABASE_DEFAULT 
 			)
 		
 			DECLARE @table_name NVARCHAR(200) = REPLACE(@xml_process_table, 'adiha_process.dbo.', '')
 		
 			INSERT INTO #temp_header_columns	
 			EXEC spa_Transpose @table_name, NULL, 1
		
			SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + CONVERT(NVARCHAR(8), term_start, 112) + '] = CAST(NULLIF(temp.[col_' + + CONVERT(NVARCHAR(8), term_start, 112) + '], '''') AS NUMERIC(38, 20))'
			FROM #temp_actual_terms tat
			INNER JOIN (SELECT DISTINCT columns_name FROM #temp_header_columns) temp ON temp.columns_name = 'col_' + + CONVERT(NVARCHAR(8), term_start, 112)

			SET @sql = '
				UPDATE pt 
				SET ' + @column_list + '
				FROM ' + @process_table + ' pt
				INNER JOIN ' + @xml_process_table + ' temp 
					ON pt.source_deal_header_id = temp.col_source_deal_header_id
					AND pt.[type] = temp.col_type			
			'
		END
		EXEC(@sql)
		EXEC('DROP TABLE ' + @xml_process_table)

		EXEC spa_ErrorHandler 0
			, 'source_deal_detail_hour'
			, 'spa_update_actual_deal'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to save Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'table_name'
		   , 'spa_name'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
	
END
IF @flag = 'v' -- save data from process table to main table
BEGIN
	BEGIN TRY
	BEGIN TRAN
		IF OBJECT_ID(@process_table) IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..#temp_source_deal_detail_update') IS NOT NULL
				DROP TABLE #temp_source_deal_detail_update

			CREATE TABLE #temp_source_deal_detail_update(source_deal_header_id INT, leg INT, term_date DATETIME, actual_volume NUMERIC(38, 20), schedule_volume NUMERIC(38, 20))

			IF OBJECT_ID('tempdb..#temp_inserted_updated_deal') IS NOT NULL
				DROP TABLE #temp_inserted_updated_deal
			CREATE TABLE #temp_inserted_updated_deal(source_deal_detail_id INT)

			DECLARE @select_statement NVARCHAR(MAX)
			DECLARE @select_statement2 NVARCHAR(MAX)
			DECLARE @for_statement NVARCHAR(MAX)
			DECLARE @on_statement NVARCHAR(MAX)

			SELECT @column_list = COALESCE(@column_list + ',', '') + '[' + CONVERT(NVARCHAR(8), term_start, 112) + ']',
					@select_list = COALESCE(@select_list + ',', '') + 'ISNULL([' + CONVERT(NVARCHAR(8), term_start, 112) + '], 0) [' + CONVERT(NVARCHAR(8), term_start, 112) + ']'
			FROM #temp_actual_terms tat

			SET @sql = '
					INSERT INTO #temp_source_deal_detail_update(source_deal_header_id, leg, term_date, actual_volume, schedule_volume)
					SELECT source_deal_header_id, leg, term_date2, NULLIF(actual_volume, 0) [actual_volume], NULL schedule_volume
					FROM (
						SELECT source_deal_header_id, term_start, leg, ' + @select_list + '
						FROM ' + @process_table + '  WHERE [type] = ''a''
					) tmp
					UNPIVOT (
						actual_volume
						FOR term_date2
						IN (
							' + @column_list + '
						) 
					) unpvt

					UPDATE temp
					SET schedule_volume = unpvt.schedule_volume
					FROM #temp_source_deal_detail_update temp
					INNER JOIN (
						SELECT source_deal_header_id, leg, term_date2 term_date, NULLIF(schedule_volume, 0) [schedule_volume]
						FROM (
							SELECT source_deal_header_id, term_start, leg,' + @select_list + '
							FROM ' + @process_table + ' WHERE [type] = ''s''
						) tmp
						UNPIVOT (
							schedule_volume
							FOR term_date2
							IN (
								' + @column_list + '
							) 
						) unpvt
					) unpvt
					ON unpvt.source_deal_header_id = temp.source_deal_header_id
					AND unpvt.term_date = temp.term_date
					AND unpvt.leg = temp.leg
				'
			--PRINT(@sql)
			EXEC(@sql)
			
			--SELECT * FROM #temp_source_deal_detail_update

			UPDATE sdd
			SET schedule_volume = temp.schedule_volume,
				actual_volume = temp.actual_volume
			FROM source_deal_detail sdd 
			INNER JOIN #temp_source_deal_detail_update temp 
				ON temp.source_deal_header_id = sdd.source_deal_header_id
				AND temp.term_date = sdd.term_start
				and temp.leg = sdd.leg
			
			/*
			IF EXISTS(SELECT 1 FROM #temp_inserted_updated_deal)
			BEGIN
				DECLARE @_process_id NVARCHAR(500) = dbo.FNAGetNewID()
				DECLARE @_report_position_deals NVARCHAR(600)

				SET @_report_position_deals = dbo.FNAProcessTableName('report_position', @user_name, @_process_id)

				DECLARE @_sql NVARCHAR(MAX)
				SET @_sql = '
					SELECT sdd.source_deal_header_id [source_deal_header_id], ''u'' [action]
					INTO ' + @_report_position_deals + '
					FROM source_deal_detail sdd
					INNER JOIN #temp_inserted_updated_deal temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
					GROUP BY sdd.source_deal_header_id
				'
				EXEC(@_sql)

				DECLARE @_pos_job_name NVARCHAR(200) =  'calc_position_breakdown_' + @_process_id
				SET @_sql = 'spa_calc_deal_position_breakdown NULL,''' + @_process_id + ''''
				EXEC spa_run_sp_as_job @_pos_job_name,  @_sql, 'Position Calculation', @user_name
			END
			*/
		END

		COMMIT
		EXEC spa_ErrorHandler 0
			, 'source_deal_detail_hour'
			, 'spa_update_actual_deal'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to save Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'source_deal_detail_hour'
		   , 'spa_update_actual_deal'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
	
END
