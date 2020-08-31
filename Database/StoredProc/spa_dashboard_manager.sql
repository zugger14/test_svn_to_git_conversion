
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_dashboard_manager]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_dashboard_manager]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE PROCEDURE [dbo].[spa_dashboard_manager]
	@flag					NCHAR(1),
	@dashboard_template_id	INT,
	@term_start				DATETIME,
	@current_hour			INT,
	@next_hour				INT,
	@template_detail_id		INT = NULL
AS
SET NOCOUNT ON
DECLARE @user_name						NVARCHAR(200)
DECLARE @sql							NVARCHAR(MAX),
		@create_sql						NVARCHAR(MAX),
		@sql1							NVARCHAR(MAX)
DECLARE @hour_for_declare				NVARCHAR(MAX),
		@hour_for_select				NVARCHAR(MAX),
		@hour_for_insert				NVARCHAR(MAX)
DECLARE @filter							NVARCHAR(MAX),
		@datatype_code					NVARCHAR(100)
DECLARE	@dashboard_template_detail_id	INT,
		@source_deal_header_id			NVARCHAR(MAX),
		@deal_date						DATETIME,
		@term_date						DATETIME,
		@term_end						DATETIME,
		@hour_string					NVARCHAR(MAX),
        @hours_pvt						NVARCHAR(MAX),
        @process_id						NVARCHAR(300),
        @process_table					NVARCHAR(500)
DECLARE @index_no						INT,
		@grouping_headers				NVARCHAR(MAX) 
DECLARE @template_data_type_name		NVARCHAR(100)
DECLARE @meter_ids						NVARCHAR(MAX),
		@new_filer						NVARCHAR(MAX),
		@capacity						INT
        
SET @user_name = dbo.FNADBUser()

IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#temp_dashboard_template') IS NOT NULL
		DROP TABLE #temp_dashboard_template
	
	SELECT	dtd.dashboard_template_detail_id,
			dtd.category,
			dtd.template_data_type,
			dtd.template_data_type_name, 
			dtd.filter,
			dtd.option_editable,
			dtd.option_formula,
			dtd.template_data_type_order, 
			dtd.category_order,
			dtd.dashboard_template_id
	INTO #temp_dashboard_template
	FROM dashboard_template_detail dtd
	WHERE dtd.dashboard_template_id = @dashboard_template_id
	
	/* Listing the hours as applied in the filter for multiple date */
	IF OBJECT_ID('tempdb..#temp_date_table') IS NOT NULL
		DROP TABLE #temp_date_table
	CREATE TABLE #temp_date_table (term_date DATETIME, hr INT, [hour] NVARCHAR(10) COLLATE DATABASE_DEFAULT, date_hour NVARCHAR(100) COLLATE DATABASE_DEFAULT)
	
	SET @term_end = (DATEADD(hh, @current_hour-1, DATEADD(hh, @next_hour, @term_start)))
	
	;WITH CTE AS ( 
		SELECT DATEADD(hh, @current_hour, @term_start) [term]
		UNION ALL
		SELECT DATEADD(hh, 1, [term]) FROM CTE	
		WHERE [term] < @term_end	
	)
	INSERT INTO #temp_date_table
	SELECT CONVERT(NVARCHAR(10), [term], 120) term, DATEPART(hh, [term]), 'hr' + CAST((DATEPART(hh, [term]) +1) AS NVARCHAR), CAST(dbo.FNADateFormat(term) AS NVARCHAR) + ' hr' + CAST((DATEPART(hh, [term]) +1) AS NVARCHAR)  FROM CTE
	OPTION (MAXRECURSION 0);
	
	/*Cursor to find all the dynmic column name*/
	SET @hour_for_insert = COALESCE(@hour_for_insert + ',', '') + '[index] '
	
	SET @index_no = 1
	DECLARE date_cursor CURSOR FOR
	SELECT DISTINCT term_date FROM #temp_date_table
	
	OPEN date_cursor
	FETCH NEXT FROM date_cursor
	INTO @term_date
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @hour_for_declare = COALESCE(@hour_for_declare + ',', '') + '[index' + CASE WHEN @index_no > 1 THEN CAST(@index_no AS VARCHAR) ELSE '' END + '] VARCHAR(100), [term' + CASE WHEN @index_no > 1 THEN CAST(@index_no AS VARCHAR) ELSE '' END + '] DATETIME '
		
		SELECT @hour_for_declare = COALESCE(@hour_for_declare + ',', '') + '[' + CAST(dbo.FNADateFormat(term_date) AS NVARCHAR(100))+ ' ' + RIGHT('0' + CAST(hr+1 AS NVARCHAR(10)) + ':00', 5) + '] FLOAT',
			   @hour_for_insert = COALESCE(@hour_for_insert + ',', '') + '[' + CAST(dbo.FNADateFormat(term_date) AS NVARCHAR(100))+ ' ' + RIGHT('0' + CAST(hr+1 AS NVARCHAR(10)) + ':00', 5) + ']',
			   @hour_for_select = COALESCE(@hour_for_select + ',', '') + '[' + CAST(dbo.FNADateFormat(term_date) AS NVARCHAR(100))+ ' ' + RIGHT('0' + CAST(hr+1 AS NVARCHAR(10)) + ':00', 5) + ']',
			   @hour_string = COALESCE(@hour_string + ',', '') + '[' + CAST([date_hour] AS NVARCHAR(100)) + ']'
		FROM #temp_date_table WHERE term_date = @term_date
		
		SET @index_no = @index_no + 1
		FETCH NEXT FROM date_cursor
		INTO @term_date
	END
	CLOSE date_cursor
	DEALLOCATE date_cursor
	
	/*End of Inner Cursor*/
	/* 
	Sample output of variable
	@grouping_header  - 05/01/2014,05/02/2014,05/03/2014
	@hour_for_declare - [index] VARCHAR(100), [term] DATETIME ,[01/01/2014 21:00] INT,[01/01/2014 22:00] INT,[01/01/2014 23:00] INT,[01/01/2014 24:00] INT,[index2] VARCHAR(100), [term2] DATETIME ,[01/02/2014 01:00] INT 
	@hour_for_insert  - [index], [term] ,[01/01/2014 21:00],[01/01/2014 22:00],[01/01/2014 23:00],[01/01/2014 24:00],[index2], [term2] ,[01/02/2014 01:00]
	@hour_for_select  - [01/01/2014 21:00],[01/01/2014 22:00],[01/01/2014 23:00],[01/01/2014 24:00],[01/02/2014 01:00]
	@hour_string - [01/01/2014 hr1],[01/01/2014 hr2],[01/01/2014 hr3]
	*/
	
	/* Creating the table dynamically according to @hours_for_declare*/
	IF OBJECT_ID('tempdb..#dashboard_manager_datalist') IS NOT NULL
		DROP TABLE #dashboard_manager_datalist
		
	CREATE TABLE #dashboard_manager_datalist (
		dashboard_template_detail_id INT, 
		category NVARCHAR(100) COLLATE DATABASE_DEFAULT, 
		template_data_type INT, 
		template_data_type_name NVARCHAR(100) COLLATE DATABASE_DEFAULT, 
		filter NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, 
		option_editable NCHAR(1) COLLATE DATABASE_DEFAULT,
		option_formula NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		template_data_type_order INT, 
		category_order INT, 
		dashboard_template_id INT
	)
	
	SET @create_sql = 'ALTER TABLE #dashboard_manager_datalist '
	SET @create_sql = @create_sql + 'ADD ' + @hour_for_declare
	EXEC(@create_sql)
				
	/*Start of Cursor - To move across all the datatype of the template*/
	DECLARE dashboard_cursor CURSOR FOR
	SELECT DISTINCT dashboard_template_detail_id FROM #temp_dashboard_template
	
	OPEN dashboard_cursor
	FETCH NEXT FROM dashboard_cursor
	INTO @dashboard_template_detail_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT	@filter = filter, 
				@datatype_code = template_data_type,  
				@template_data_type_name = template_data_type_name
		FROM #temp_dashboard_template 
		WHERE dashboard_template_detail_id = @dashboard_template_detail_id
		
		IF (@filter IS NULL)
		BEGIN
			EXEC spa_dashboard_manager 'x', NULL, NULL, NULL, NULL, @dashboard_template_detail_id
		END
		ELSE
		BEGIN
			/* Logic for Deal Based Position Datatype */
			IF (@datatype_code = '27301')
			BEGIN
				/* Start for Finding Hourly Position Data 
				IF OBJECT_ID('tempdb..#temp_source_deal_header') IS NOT NULL
					DROP TABLE #temp_source_deal_header
				
				CREATE TABLE #temp_source_deal_header
				(	
					ID						INT,
					Ref_ID					NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Deal_Date				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Sub_book				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Physical_Financial_Flag	NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Counterparty			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					trader					NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					[broker]				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Entire_Term_Start		NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Entire_Term_End			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Deal_Type				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Deal_Sub_Type			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Commodity				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Option_Flag				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Option_Type				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Excercise_Type			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Deal_Category			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Hedge_Item_Flag			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Hedge_Type				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Legal_Entity			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Deal_Locked				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Pricing					NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Confirm_Status			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Signed_Off_By			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Verified_Date			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Comments				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					deal_rules				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					confirm_rule			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					header_buy_sell_flag	NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					close_reference_id		NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					Create_TS				DATETIME
				)
				
				SET @sql = 'INSERT INTO #temp_source_deal_header ' + @filter
				EXEC(@sql)
				
				SET @source_deal_header_id = NULL
				SELECT @source_deal_header_id = COALESCE(@source_deal_header_id + ',', '') + CAST(id AS VARCHAR(100))
				FROM #temp_source_deal_header
				
				SELECT	@deal_date = Deal_Date
				FROM #temp_source_deal_header
				
				IF OBJECT_ID('tempdb..#temp_hourly_position') IS NOT NULL
					DROP TABLE #temp_hourly_position
				
				CREATE TABLE #temp_hourly_position
				(
					[index]					NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					[Physiscal/Financial]	NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					[term]					DATETIME,
					[Hr1]					NUMERIC(38, 2),
					[Hr2]					NUMERIC(38, 2),
					[Hr3]					NUMERIC(38, 2),
					[Hr4]					NUMERIC(38, 2),
					[Hr5]					NUMERIC(38, 2),
					[Hr6]					NUMERIC(38, 2),
					[Hr7]					NUMERIC(38, 2),
					[Hr8]					NUMERIC(38, 2),
					[Hr9]					NUMERIC(38, 2),
					[Hr10]					NUMERIC(38, 2),
					[Hr11]					NUMERIC(38, 2),
					[Hr12]					NUMERIC(38, 2),
					[Hr13]					NUMERIC(38, 2),
					[Hr14]					NUMERIC(38, 2),
					[Hr15]					NUMERIC(38, 2),
					[Hr16]					NUMERIC(38, 2),
					[Hr17]					NUMERIC(38, 2),
					[Hr18]					NUMERIC(38, 2),
					[Hr19]					NUMERIC(38, 2),
					[Hr20]					NUMERIC(38, 2),
					[Hr21]					NUMERIC(38, 2),
					[Hr22]					NUMERIC(38, 2),
					[Hr23]					NUMERIC(38, 2),
					[Hr24]					NUMERIC(38, 2),
					[UOM]					NVARCHAR(100) COLLATE DATABASE_DEFAULT
				)
				
				INSERT INTO #temp_hourly_position
				EXEC spa_create_hourly_position_report 'h', NULL, NULL, NULL, NULL, @deal_date, NULL, NULL, 982, 'i', NULL, NULL, NULL, NULL, @source_deal_header_id, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, 'b', 'a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'm'
				*/
				/*checks if the filter consist of hourly position data or not*/
				/*Unpivoting the Hourly Position Data */
				
				IF OBJECT_ID('tempdb..#temp_hourly_position_data') IS NOT NULL
					DROP TABLE #temp_hourly_position_data
					
				CREATE TABLE #temp_hourly_position_data
				(
					[index]					NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					[term]					DATETIME,	
					[hour]					NVARCHAR(10) COLLATE DATABASE_DEFAULT,
					[data]					NUMERIC(38, 2)
				)
				
				SET @source_deal_header_id = @filter
				SET @deal_date = @term_start	
					
				INSERT INTO #temp_hourly_position_data
				SELECT [curve_id], [term_start], [hour], [data]
				FROM
					(SELECT [curve_id], [term_start], [hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12],
								[hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], [hr23], [hr24]
						FROM report_hourly_position_deal WHERE source_deal_header_id = @source_deal_header_id) AS pvt
				UNPIVOT
					([data] FOR [hour] IN ([hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12],
								[hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], [hr23], [hr24]) 
				) AS unpvt;
					
				IF EXISTS (SELECT * FROM #temp_hourly_position_data) 
				BEGIN
					IF OBJECT_ID('tempdb..#temp_pvt_table') IS NOT NULL
						DROP TABLE #temp_pvt_table
					IF OBJECT_ID('tempdb..#temp_data_table') IS NOT NULL
						DROP TABLE #temp_data_table
					
					SELECT tdt.term_date, tdt.hr, thpd.[data], tdt.date_hour, thpd.[index] 
					INTO #temp_pvt_table
					FROM #temp_date_table tdt LEFT JOIN #temp_hourly_position_data thpd 
					ON tdt.term_date = thpd.term AND tdt.[hour] = thpd.[hour]
					WHERE thpd.[index] IS NOT NULL
					  
					SET @sql = 'SELECT [index] AS [index], '
					SET @sql = @sql + ' ' + @hour_string + ' INTO #temp_data_table FROM (						
										SELECT tdt.[index], tdt.[date_hour], tdt.[data]
										FROM #temp_pvt_table tdt
									) up
									PIVOT (SUM(data) FOR [date_hour] IN ('
					SET @sql = @sql + ' ' + @hour_string + ' ' + '
									)) AS pvt '
						
					SET @sql = @sql + ' INSERT INTO #dashboard_manager_datalist (dashboard_template_detail_id, category, template_data_type, template_data_type_name, filter, option_editable, option_formula, template_data_type_order, category_order, dashboard_template_id, ' + @hour_for_insert +')'
					SET @sql = @sql + ' SELECT * FROM #temp_dashboard_template td OUTER APPLY #temp_data_table WHERE template_data_type_name = ''' + @template_data_type_name + ''' AND REPLACE(filter, '''''''', '''') = ''' + REPLACE(@filter, '''', '') + ''''
					EXEC(@sql)
					
				/* End for Finding Hourly Position Data */
				END
				ELSE
				BEGIN
					EXEC spa_dashboard_manager 'x', NULL, NULL, NULL, NULL, @dashboard_template_detail_id
				END
			END
			
			/* Logic for Actual */
			ELSE IF (@datatype_code = '27302')
			BEGIN
				IF OBJECT_ID('tempdb..#temp_meter_data') IS NOT NULL
						DROP TABLE #temp_meter_data
				
				CREATE TABLE #temp_meter_data
				(
					[meter_id]			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					UOM				VARCHAR(50) COLLATE DATABASE_DEFAULT,
					[term]			DATETIME,
					[hour]			NVARCHAR(10) COLLATE DATABASE_DEFAULT,
					[data]			NUMERIC(38, 2)
				)
				
				SET @sql = 'SELECT mi.recorderid,mdh.* 
								INTO #temp_meter
							FROM mv90_data md
							INNER JOIN mv90_data_hour mdh ON md.meter_data_id = mdh.meter_data_id
							INNER JOIN meter_id mi ON md.meter_id = mi.meter_id
							WHERE md.meter_id IN (' + @filter + ')'

				SET @sql += 'INSERT INTO #temp_meter_data  
								select a.recorderid [meter_id], '''' [UOM], a.prod_date [term], REPLACE(a.#temp_meter, ''Hr'', '''') AS [hour], a.[data] from #temp_meter mdh
								Unpivot
								(
								  data for #temp_meter in (hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24)

								) as a'
				EXEC(@sql)
				
				IF EXISTS (SELECT * FROM #temp_meter_data) 
				BEGIN
					
					IF OBJECT_ID('tempdb..#temp_pvt_table1') IS NOT NULL
						DROP TABLE #temp_pvt_table1
					IF OBJECT_ID('tempdb..#temp_data_table1') IS NOT NULL
						DROP TABLE #temp_data_table1
					
					SELECT tdt.term_date, tdt.hr, tmd.[data], tdt.date_hour, tmd.[meter_id] 
					INTO #temp_pvt_table1
					FROM #temp_date_table tdt LEFT JOIN #temp_meter_data tmd
					ON tdt.term_date = tmd.term AND tdt.[hr] + 1 = tmd.[hour]
					WHERE tmd.meter_id IS NOT NULL
					
					SET @sql = 'SELECT meter_id AS [meter_id], ' 
					SET @sql = @sql + @hour_string + ' INTO #temp_data_table1 FROM (						
										SELECT tpt1.[meter_id], tpt1.[date_hour], tpt1.[data]
										FROM #temp_pvt_table1 tpt1
									) up
									PIVOT (SUM(data) FOR [date_hour] IN ('
					SET @sql = @sql + ' ' + @hour_string + ' ' + '
									)) AS pvt '
						
					SET @sql = @sql + ' INSERT INTO #dashboard_manager_datalist (dashboard_template_detail_id, category, template_data_type, template_data_type_name, filter, option_editable, option_formula, template_data_type_order, category_order, dashboard_template_id, ' + @hour_for_insert +')'
					SET @sql = @sql + ' SELECT * FROM #temp_dashboard_template td OUTER APPLY #temp_data_table1 WHERE template_data_type_name = ''' + @template_data_type_name + ''' AND REPLACE(filter, '''''''', '''') = ''' + REPLACE(@filter, '''', '') + ''''
					EXEC(@sql)
				END
				ELSE
				BEGIN
					EXEC spa_dashboard_manager 'x', NULL, NULL, NULL, NULL, @dashboard_template_detail_id
				END
			END
			
			/* Logic for Time Series Data */
			ELSE IF (@datatype_code = '27304')
			BEGIN
				IF OBJECT_ID('tempdb..#temp_time_series') IS NOT NULL
						DROP TABLE #temp_time_series
				
				CREATE TABLE #temp_time_series
				(
					[time_series]	NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					[term]			DATETIME,
					[hour]			NVARCHAR(15) COLLATE DATABASE_DEFAULT,
					[data]			NUMERIC(38, 2)
				)

				INSERT INTO #temp_time_series
				SELECT tsde.time_series_name, tdt.term_date, CAST(dbo.FNAdateformat(tdt.term_date) AS VARCHAR) + ' hr' + CAST(tdt.hr+1 AS VARCHAR), tsda.value FROM time_series_definition tsde
				INNER JOIN time_series_data tsda ON tsde.time_series_definition_id = tsda.time_series_definition_id
				INNER JOIN #temp_date_table tdt ON DATEADD(hh, tdt.hr, tdt.term_date) = tsda.maturity
				WHERE tsde.time_series_definition_id = @filter

				SET @sql = 'SELECT time_series AS [time_series], ' 
				SET @sql = @sql + @hour_string + ' INTO #temp_data_table2 FROM (						
									SELECT tts.[time_series], tts.[hour], tts.[data]
									FROM #temp_time_series tts
								) up
								PIVOT (SUM(data) FOR [hour] IN ('
				SET @sql = @sql + ' ' + @hour_string + ' ' + '
								)) AS pvt '
						
				SET @sql = @sql + ' 
				INSERT INTO #dashboard_manager_datalist (dashboard_template_detail_id, category, template_data_type, template_data_type_name, filter, option_editable, option_formula, template_data_type_order, category_order, dashboard_template_id, ' + @hour_for_insert +')'
				SET @sql = @sql + ' SELECT * FROM #temp_dashboard_template td OUTER APPLY #temp_data_table2 WHERE template_data_type_name = ''' + @template_data_type_name + ''' AND REPLACE(filter, '''''''', '''') = ''' + REPLACE(@filter, '''', '') + ''''
				EXEC(@sql)
			END
			
			/* Logic for Forecast */
			ELSE IF (@datatype_code = '27303')
			BEGIN
				IF OBJECT_ID('tempdb..#temp_profile_data') IS NOT NULL
						DROP TABLE #temp_profile_data
				
				CREATE TABLE #temp_profile_data
				(
					[profile_name]	NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					[EAN]			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
					[term]			DATETIME,
					[hour]			NVARCHAR(10) COLLATE DATABASE_DEFAULT,
					[data]			NUMERIC(38, 2)
				)
				
				INSERT INTO #temp_profile_data
				EXEC(@filter)
				
				IF EXISTS (SELECT * FROM #temp_profile_data) 
				BEGIN
					IF OBJECT_ID('tempdb..#temp_pvt_table2') IS NOT NULL
						DROP TABLE #temp_pvt_table2
					IF OBJECT_ID('tempdb..#temp_data_table2') IS NOT NULL
						DROP TABLE #temp_data_table2
					
					SELECT tdt.term_date, tdt.hr, tpd.[data], tdt.date_hour, tpd.[profile_name] 
					INTO #temp_pvt_table2
					FROM #temp_date_table tdt LEFT JOIN #temp_profile_data tpd
					ON tdt.term_date = tpd.term AND tdt.[hr] + 1 = tpd.[hour]
					WHERE tpd.[profile_name] IS NOT NULL
					
					SET @sql = 'SELECT profile_name AS [profile_name], ' 
					SET @sql = @sql + @hour_string + ' INTO #temp_data_table2 FROM (						
										SELECT tpd2.[profile_name], tpd2.[date_hour], tpd2.[data]
										FROM #temp_pvt_table2 tpd2
									) up
									PIVOT (SUM(data) FOR [date_hour] IN ('
					SET @sql = @sql + ' ' + @hour_string + ' ' + '
									)) AS pvt '
						
					SET @sql = @sql + ' INSERT INTO #dashboard_manager_datalist (dashboard_template_detail_id, category, template_data_type, template_data_type_name, filter, option_editable, option_formula, template_data_type_order, category_order, dashboard_template_id, ' + @hour_for_insert +')'
					SET @sql = @sql + ' SELECT * FROM #temp_dashboard_template td OUTER APPLY #temp_data_table2 WHERE template_data_type_name = ''' + @template_data_type_name + ''' AND REPLACE(filter, '''''''', '''') = ''' + REPLACE(@filter, '''', '') + ''''
					EXEC(@sql)
				END
				ELSE
				BEGIN
					EXEC spa_dashboard_manager 'x', NULL, NULL, NULL, NULL, @dashboard_template_detail_id
				END
			END
			
			/* For Sub Total Row - Only generate the sub total row, Sub total calculation is done is the grid */
			/* For What If - Only showing what if header, doesnot require to show data*/
			/* For Custom - Only showing Custom header, doesnot require to show data*/
			ELSE IF (@datatype_code = '27307' OR @datatype_code = '27305' OR @datatype_code = '27306')
			BEGIN
				SET @sql = ' SELECT * FROM #temp_dashboard_template '
				SET @sql = @sql + ' WHERE dashboard_template_detail_id = ' + CAST(@dashboard_template_detail_id AS VARCHAR)
				
				SET @sql = 'INSERT INTO #dashboard_manager_datalist (dashboard_template_detail_id, category, template_data_type, template_data_type_name, filter, option_editable, option_formula, template_data_type_order, category_order, dashboard_template_id)' + @sql
				EXEC(@sql)
			END
			
			/* For Generation data*/
			ELSE IF (@datatype_code = '27308')
			BEGIN
				
				SET @meter_ids = NULL
				SELECT @meter_ids = COALESCE(@meter_ids + ',', '') + CAST(meter_id AS VARCHAR(100))
				FROM rec_generator rg
				INNER JOIN recorder_generator_map rgm ON rg.generator_id = rgm.generator_id
				WHERE rg.generator_id = @filter
				
				SELECT @capacity = nameplate_capacity FROM rec_generator rg
				WHERE rg.generator_id = @filter
				
				IF (@meter_ids IS NOT NULL)
				BEGIN 
					IF OBJECT_ID('tempdb..#temp_meter_data1') IS NOT NULL
						DROP TABLE #temp_meter_data1
				
					CREATE TABLE #temp_meter_data1
					(
						[meter_id]			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
						UOM				VARCHAR(50) COLLATE DATABASE_DEFAULT,
						[term]			DATETIME,
						[hour]			NVARCHAR(10) COLLATE DATABASE_DEFAULT,
						[data]			NUMERIC(38, 2)
					)
				
					SET @sql = 'SELECT mi.recorderid,mdh.* 
									INTO #temp_meter
								FROM mv90_data md
								INNER JOIN mv90_data_hour mdh ON md.meter_data_id = mdh.meter_data_id
								INNER JOIN meter_id mi ON md.meter_id = mi.meter_id
								WHERE md.meter_id IN (' + @meter_ids + ')'

					SET @sql += 'INSERT INTO #temp_meter_data1  
									select a.recorderid [meter_id], '''' [UOM], a.prod_date [term], REPLACE(a.#temp_meter, ''Hr'', '''') AS [hour], a.[data] from #temp_meter mdh
									Unpivot
									(
									  data for #temp_meter in (hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24)

									) as a'
					EXEC(@sql)
				
					IF EXISTS (SELECT * FROM #temp_meter_data1) 
					BEGIN
					
						IF OBJECT_ID('tempdb..#temp_pvt_table3') IS NOT NULL
							DROP TABLE #temp_pvt_table3
						IF OBJECT_ID('tempdb..#temp_data_table3') IS NOT NULL
							DROP TABLE #temp_data_table3
					
						SELECT tdt.term_date, tdt.hr, tmd.[data], tdt.date_hour, tmd.[meter_id] 
						INTO #temp_pvt_table3
						FROM #temp_date_table tdt LEFT JOIN #temp_meter_data1 tmd
						ON tdt.term_date = tmd.term AND tdt.[hr] + 1 = tmd.[hour]
						WHERE tmd.meter_id IS NOT NULL
					
						SET @sql = 'SELECT meter_id AS [meter_id], ' 
						SET @sql = @sql + @hour_string + ' INTO #temp_data_table1 FROM (						
											SELECT tpt1.[meter_id], tpt1.[date_hour], tpt1.[data]
											FROM #temp_pvt_table3 tpt1
										) up
										PIVOT (SUM(data) FOR [date_hour] IN ('
						SET @sql = @sql + ' ' + @hour_string + ' ' + '
										)) AS pvt '
						
						SET @sql = @sql + ' INSERT INTO #dashboard_manager_datalist (dashboard_template_detail_id, category, template_data_type, template_data_type_name, filter, option_editable, option_formula, template_data_type_order, category_order, dashboard_template_id, ' + @hour_for_insert +')'
						SET @sql = @sql + ' SELECT * FROM #temp_dashboard_template td OUTER APPLY #temp_data_table1 WHERE template_data_type_name = ''' + @template_data_type_name + ''' AND REPLACE(filter, '''''''', '''') = ''' + REPLACE(@filter, '''', '') + ''''
						EXEC(@sql)
					END
					ELSE
					BEGIN
						EXEC spa_dashboard_manager 'x', NULL, NULL, NULL, NULL, @dashboard_template_detail_id
					END
				END
				ELSE
				BEGIN
					IF OBJECT_ID('tempdb..#temp_pvt_table_capacity') IS NOT NULL
						DROP TABLE #temp_pvt_table_capacity
					IF OBJECT_ID('tempdb..#temp_data_table_capacity') IS NOT NULL
						DROP TABLE #temp_data_table_capacity
					
					SELECT tdt.term_date, tdt.hr, @capacity AS [Data], tdt.date_hour, @capacity AS [Generator]
					INTO #temp_pvt_table_capacity
					FROM #temp_date_table tdt
					
					SET @sql = 'SELECT generator AS [generator], ' 
					SET @sql = @sql + @hour_string + ' INTO #temp_data_table_capacity FROM (						
										SELECT tptc.[generator], tptc.[date_hour], tptc.[data] 
										FROM #temp_pvt_table_capacity tptc
									) up
									PIVOT (SUM(data) FOR [date_hour] IN ('
					SET @sql = @sql + ' ' + @hour_string + ' ' + '
									)) AS pvt '
									
					SET @sql = @sql + ' INSERT INTO #dashboard_manager_datalist (dashboard_template_detail_id, category, template_data_type, template_data_type_name, filter, option_editable, option_formula, template_data_type_order, category_order, dashboard_template_id, ' + @hour_for_insert +')'
					SET @sql = @sql + ' SELECT * FROM #temp_dashboard_template td OUTER APPLY #temp_data_table_capacity WHERE template_data_type_name = ''' + @template_data_type_name + ''' AND REPLACE(filter, '''''''', '''') = ''' + REPLACE(@filter, '''', '') + ''''
					EXEC(@sql)	
				END
			END
		END
		
		FETCH NEXT FROM dashboard_cursor
		INTO @dashboard_template_detail_id
	END
	CLOSE dashboard_cursor
	DEALLOCATE dashboard_cursor
	/*End of Outer Cursor*/ 
	
	SET @sql = 'SELECT category, template_data_type_name [Data], template_data_type [code], option_editable [editable], option_formula [formula], [index], ' + @hour_for_select + ' FROM #dashboard_manager_datalist ORDER BY category_order, template_data_type_order'
	--SET @sql = 'SELECT * FROM #dashboard_manager_datalist  ORDER BY category_order, template_data_type_order'
	EXEC(@sql)	
END

/* Find the Grouping Headers */
IF @flag = 'g'
BEGIN
	IF OBJECT_ID('tempdb..#temp_date') IS NOT NULL
		DROP TABLE #temp_date
	CREATE TABLE #temp_date (term_date DATETIME, hr INT)
	
	SET @term_end = (DATEADD(hh, @current_hour-1, DATEADD(hh, @next_hour, @term_start)))
	
	;WITH CTE AS ( 
		SELECT DATEADD(hh, @current_hour, @term_start) [term]
		UNION ALL
		SELECT DATEADD(hh, 1, [term]) FROM CTE	
		WHERE [term] < @term_end	
	)
	INSERT INTO #temp_date
	SELECT CONVERT(NVARCHAR(10), [term], 120) term, DATEPART(hh, [term]) FROM CTE
	OPTION (MAXRECURSION 0);
	
	DECLARE group_header_cursor CURSOR FOR
	SELECT DISTINCT term_date FROM #temp_date
	
	OPEN group_header_cursor
	FETCH NEXT FROM group_header_cursor
	INTO @term_date
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @grouping_headers = COALESCE(@grouping_headers + ',', '') + CAST(dbo.FNADateFormat(@term_date) AS NVARCHAR(100))
		
		FETCH NEXT FROM group_header_cursor
		INTO @term_date
	END
	CLOSE group_header_cursor
	DEALLOCATE group_header_cursor
	
	SELECT @grouping_headers
	
END

IF @flag = 'x'
BEGIN
	SET @sql = ' SELECT * FROM #temp_dashboard_template '
	SET @sql = @sql + ' WHERE dashboard_template_detail_id = ' + CAST(@template_detail_id AS VARCHAR)

	SET @sql = 'INSERT INTO #dashboard_manager_datalist (dashboard_template_detail_id, category, template_data_type, template_data_type_name, filter, option_editable, option_formula, template_data_type_order, category_order, dashboard_template_id)' + @sql
	EXEC(@sql)
END

