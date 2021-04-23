IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_UpdateHolidayXml]')
			AND TYPE IN (N'P',N'PC')
		)
	DROP PROCEDURE [dbo].[spa_UpdateHolidayXml]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_UpdateHolidayXml] @flag CHAR(1)
	,@xmlValue TEXT
	,@xmlValue2 TEXT
AS
/* Debugg Query
DECLARE @flag CHAR(1),
	@xmlValue VARCHAR(MAX),
	@xmlValue2 VARCHAR(MAX)
	--@holiday_calendar_id INT 

	select @flag='i',@xmlValue='<Root><PSRecordset type_id = "10017" value_id= "403239" code = "APX/Endex" description = "APX/Endex" category_id = "38701" holiday_calendar_id = "" ></PSRecordset></Root>',@xmlValue2='<GridGroup><Grid grid_id = "holiday_group_calendar_grid"></Grid><GridCalendarExp><GridRow  expiration_calendar_id="" calendar_id="" holiday_calendar="" delivery_period="2018-10-01" expiration_from="2018-10-01" expiration_to="2018-10-31"></GridRow><GridRow  expiration_calendar_id="" calendar_id="" holiday_calendar="" delivery_period="2018-11-01" expiration_from="2018-11-01" expiration_to="2018-12-05"></GridRow></GridCalendarExp></GridGroup>'

	drop table #ztbl_xmlvalue
	drop table #ztbl_xmlvalue2
	drop table #delete_xmlvalue	
	drop table #del_grid_cal_exp
	drop table #temp_del_cal_exp
	drop table #temp_finilized_data

--*/
SET NOCOUNT ON

DECLARE @sqlStmt VARCHAR(MAX)
DECLARE @sqlStmt2 VARCHAR(MAX)
DECLARE @tempdetailtable VARCHAR(128)
DECLARE @temphourtable VARCHAR(128)
DECLARE @user_login_id VARCHAR(100)
DECLARE @process_id VARCHAR(50)

SET @user_login_id = dbo.FNADBUser()
--select @process_id
SET @process_id = REPLACE(NEWID(), '-', '_')

DECLARE @block_value_id INT
DECLARE @report_position_process_id VARCHAR(100)
DECLARE @job_name VARCHAR(100)
DECLARE @report_position_deals VARCHAR(300)
DECLARE @sql VARCHAR(8000)

SET @report_position_process_id = REPLACE(NEWID(), '-', '_')
SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @report_position_process_id)

EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

SET @tempdetailtable = dbo.FNAProcessTableName('hourly_process', @user_login_id, @process_id)
SET @temphourtable = dbo.FNAProcessTableName('holiday', @user_login_id, @process_id)

BEGIN TRY
	DECLARE @idoc INT
	DECLARE @doc VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@xmlValue2

	SELECT *
	INTO #ztbl_xmlvalue
	FROM OPENXML(@idoc, '/GridGroup/Grid/GridRow', 2) WITH (
			hol_group_ID INT '@hol_group_ID'
			,hol_group_value_id INT '@hol_group_value_id'
			,hol_date VARCHAR(200) '@hol_date'
			,[description] VARCHAR(50) '@description'
			,exp_date VARCHAR(200) '@exp_date'
			,settlement_date VARCHAR(200) '@settlement_date'
			,hol_date_to VARCHAR(200) '@hol_date_to'
			)

	DECLARE @idoc2 INT
	DECLARE @doc2 VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc2 OUTPUT
		,@xmlValue

	SELECT *
	INTO #ztbl_xmlvalue2
	FROM OPENXML(@idoc2, '/Root/PSRecordset', 2) WITH (
			[type_id] VARCHAR(50) '@type_id'
			,[value_id] VARCHAR(50) '@value_id'
			,[code] VARCHAR(50) '@code'
			,[description] VARCHAR(100) '@description'
			,[category_id] VARCHAR(50) '@category_id'
			,[holiday_calendar_id] VARCHAR(50) '@holiday_calendar_id'
			)

	DECLARE @idoc3 INT
	DECLARE @doc3 VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc3 OUTPUT
		,@xmlValue2

	SELECT *
	INTO #delete_xmlvalue
	FROM OPENXML(@idoc3, '/GridGroup/Grid/GridDelete', 2) WITH (
			hol_group_ID VARCHAR(50) '@hol_group_ID'
			,hol_group_value_id VARCHAR(50) '@hol_group_value_id'
			)

	EXEC sp_xml_removedocument @idoc3;

	EXEC sp_xml_preparedocument @idoc3 OUTPUT
		,@xmlValue2

	SELECT *
	INTO #del_grid_cal_exp
	FROM OPENXML(@idoc3, '/GridGroup/GridCalendarExp/GridHolidayCalDelete', 2) WITH (expiration_calendar_id VARCHAR(50) '@expiration_calendar_id')

	--Collect all the data for deleting data from holiday_calendar table
	SELECT ec.calendar_id
		,ec.delivery_period
		,ec.expiration_from
		,ec.expiration_to
	INTO #temp_del_cal_exp
	FROM #del_grid_cal_exp dgce
	INNER JOIN expiration_calendar ec ON ec.expiration_calendar_id = dgce.expiration_calendar_id

	IF OBJECT_ID('tempdb..#temp_expiration_calendar') IS NOT NULL
		DROP TABLE #temp_expiration_calendar

	DECLARE @calendar_id INT
		,@expiration_calendar_id INT
		,@cat_id INT

	SELECT @calendar_id = value_id
		,@expiration_calendar_id = holiday_calendar_id
		,@cat_id = category_id
	FROM #ztbl_xmlvalue2

	SELECT @calendar_id AS holiday_calendar_id
		,@cat_id AS calendar_id
		,*
	INTO #temp_expiration_calendar
	FROM OPENXML(@idoc3, '/GridGroup/GridCalendarExp/GridRow', 2) WITH (
			expiration_calendar_id VARCHAR(50) '@expiration_calendar_id',
			delivery_period DATETIME '@delivery_period'
			,expiration_from DATETIME '@expiration_from'
			,expiration_to DATETIME '@expiration_to'
			)

	EXEC sp_xml_removedocument @idoc3;

	IF @flag IN (
			'i'
			,'u'
			)
	BEGIN
		BEGIN TRAN

		MERGE dbo.static_data_value AS sdv
		USING (
			SELECT [type_id]
				,[code]
				,[description]
				,[value_id]
				,[category_id]
			FROM #ztbl_xmlvalue2
			) zxv2
			ON sdv.[value_id] = zxv2.[value_id]
		WHEN NOT MATCHED BY TARGET
			THEN
				INSERT (
					[type_id]
					,code
					,[description]
					,[category_id]
					)
				VALUES (
					zxv2.[type_id]
					,zxv2.[code]
					,zxv2.[description]
					,zxv2.[category_id]
					)
		WHEN MATCHED
			THEN
				UPDATE
				SET code = zxv2.code
					,[description] = zxv2.[description]
					,[category_id] = zxv2.[category_id];

		--select * from #ztbl_xmlvalue2
		DECLARE @static_data_value_id INT

		SET @static_data_value_id = (
				SELECT tsdv.[value_id]
				FROM #ztbl_xmlvalue2 tsdv
				)

		IF (@static_data_value_id = '')
			SET @static_data_value_id = SCOPE_IDENTITY()

		
		IF( SELECT top 1 COUNT(hol_group_id)
			FROM #ztbl_xmlvalue
			GROUP BY [hol_group_value_id], [hol_date], [exp_date], [hol_date_to]
			HAVING COUNT(hol_group_id) > 1
		) > 1
		BEGIN 
			EXEC spa_ErrorHandler -1
					, 'Source Deal Detail'
					, 'spa_UpdateHolidayXml'
					, 'DB Error'
					, 'Dupliclate value in Date From, Date To and Expiration Calendar.'
					, 'Failed Inserting Record'
			ROLLBACK TRAN
			RETURN;
		END

		MERGE holiday_group AS hb
		USING (
			SELECT [hol_group_ID]
				,[hol_group_value_id]
				,[dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF([hol_date], ''), NULL)) [hol_date]
				,[description]
				,[dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(exp_date, ''), NULL)) exp_date
				,[dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(settlement_date, ''), NULL)) settlement_date
				,[dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(hol_date_to, ''), NULL)) hol_date_to
			FROM #ztbl_xmlvalue
			) zxv
			ON hb.[hol_group_ID] = zxv.[hol_group_ID]
				AND hb.[hol_group_value_id] = zxv.[hol_group_value_id]
		WHEN NOT MATCHED BY TARGET
			THEN
				INSERT (
					hol_group_value_id
					,hol_date
					,[description]
					,exp_date
					,settlement_date
					,hol_date_to
					)
				VALUES (
					@static_data_value_id
					,[dbo].[FNAGetSQLStandardDateTime](zxv.hol_date)
					,zxv.[description]
					,[dbo].[FNAGetSQLStandardDateTime](zxv.exp_date)
					,[dbo].[FNAGetSQLStandardDateTime](zxv.settlement_date)
					,[dbo].[FNAGetSQLStandardDateTime](zxv.hol_date_to)
					)
		WHEN MATCHED
			THEN
				UPDATE
				SET hol_date = [dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(zxv.hol_date, ''), NULL))
					,[description] = zxv.[description]
					,exp_date = [dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(zxv.exp_date, ''), NULL))
					,settlement_date = [dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(zxv.settlement_date, ''), NULL))
					,hol_date_to = [dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(zxv.hol_date_to, ''), NULL));

		DELETE
		FROM holiday_group
		WHERE hol_group_ID IN (
				SELECT [hol_group_ID]
				FROM #delete_xmlvalue
				)

		MERGE expiration_calendar AS ec
		USING (
			SELECT 
				 expiration_calendar_id,
				 @static_data_value_id [calendar_id]
				,@expiration_calendar_id [holiday_calendar_id]
				,[dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(delivery_period, ''), NULL)) [delivery_period]
				,[dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(expiration_from, ''), NULL)) expiration_from
				,[dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(expiration_to, ''), NULL)) expiration_to
			FROM #temp_expiration_calendar
			) tec
			ON ec.expiration_calendar_id = tec.expiration_calendar_id AND
			ec.[calendar_id] = tec.[calendar_id]
				--AND ec.[delivery_period] = tec.[delivery_period]
		WHEN NOT MATCHED BY TARGET
			THEN
				INSERT (
					calendar_id
					,holiday_calendar
					,delivery_period
					,expiration_from
					,expiration_to
					)
				VALUES (
					@static_data_value_id
					,@expiration_calendar_id
					,[dbo].[FNAGetSQLStandardDateTime](tec.delivery_period)
					,[dbo].[FNAGetSQLStandardDateTime](tec.expiration_from)
					,[dbo].[FNAGetSQLStandardDateTime](tec.expiration_to)
					)
		WHEN MATCHED
			THEN
				UPDATE
				SET holiday_calendar = tec.[holiday_calendar_id]
					,delivery_period = [dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(tec.delivery_period, ''), NULL))
					,expiration_from = [dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(tec.expiration_from, ''), NULL))
					,expiration_to = [dbo].[FNAGetSQLStandardDateTime](ISNULL(NULLIF(tec.expiration_to, ''), NULL));

		DELETE expc
		FROM expiration_calendar expc
		INNER JOIN #del_grid_cal_exp dgce ON expc.expiration_calendar_id = dgce.expiration_calendar_id

		------------------------new logic 
		IF @cat_id = 38701 -- type expiration
		BEGIN
			--getting default timezone id 
			DECLARE @time_zone_id VARCHAR(100),@weekend_first_day TINYINT,@weekend_second_day TINYINT
			
			SELECT @time_zone_id=var_value   --26
			FROM dbo.adiha_default_codes_values(nolock)
			WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
			--select @time_zone_id

			SELECT @weekend_first_day = ISNULL(NULLIF(weekend_first_day,''),1), @weekend_second_day = ISNULL(NULLIF(weekend_second_day,''),7)
			FROM time_zones WHERE TIMEZONE_ID = @time_zone_id

			DELETE hg FROM  holiday_group hg INNER JOIN #temp_del_cal_exp tce 
			ON hg.hol_group_value_id = tce.calendar_id 
			WHERE hg.hol_date = tce.delivery_period
			AND hg.exp_date BETWEEN CAST(tce.expiration_from AS DATETIME) AND CAST(tce.expiration_to AS DATETIME)

		-- insert data into holiday calendar
		;WITH CTE
		AS (
			SELECT holiday_calendar_id
				,calendar_id
				,delivery_period
				,CAST(expiration_from AS DATETIME) expiration_from
				,CAST(expiration_to AS DATETIME) expiration_to
				,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, delivery_period) + 1, 0)) last_day_of_month
			FROM #temp_expiration_calendar
	
			UNION ALL
	
			SELECT holiday_calendar_id
				,calendar_id
				,delivery_period
				,DATEADD(day, 1, expiration_from) expiration_from
				,expiration_to
				,DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, delivery_period) + 1, 0)) last_day_of_month
			FROM CTE
			WHERE expiration_from < expiration_to
			)
		SELECT a.*
		INTO #temp_finilized_data
		FROM CTE a
		LEFT JOIN holiday_group hg ON hg.hol_date = a.expiration_from
			AND hg.hol_group_value_id = @expiration_calendar_id
		WHERE hg.hol_date IS NULL
			AND (
				(DATEPART(dw, expiration_from)) <> @weekend_first_day
				AND DATEPART(dw, expiration_from) <> @weekend_second_day
				)
		ORDER BY expiration_from
		OPTION (MAXRECURSION 0)

		MERGE holiday_group AS hb
		USING (
			SELECT *
			FROM #temp_finilized_data
			) tfd
			ON hb.hol_group_value_id = @static_data_value_id
				AND tfd.delivery_period = hb.hol_date
				AND tfd.expiration_from = hb.exp_date
		WHEN NOT MATCHED BY TARGET
			THEN
				INSERT (
					hol_group_value_id
					,hol_date
					,exp_date
					,hol_date_to
					)
				VALUES (
					@static_data_value_id
					,[dbo].[FNAGetSQLStandardDateTime](tfd.delivery_period)
					,[dbo].[FNAGetSQLStandardDateTime](tfd.expiration_from)
					,[dbo].[FNAGetSQLStandardDateTime](tfd.last_day_of_month)
					)
		WHEN MATCHED
			THEN
				UPDATE
				SET hol_date = [dbo].[FNAGetSQLStandardDateTime](tfd.delivery_period)
					,exp_date = [dbo].[FNAGetSQLStandardDateTime](tfd.expiration_from)
					,hol_date_to = [dbo].[FNAGetSQLStandardDateTime](tfd.last_day_of_month);

		END
		EXEC spa_ErrorHandler 0
			, 'Source Deal Detail'
			, 'spa_UpdateHolidayXml'
			, 'Success'
			, 'Changes have been saved successfully.'
			, @static_data_value_id				

		COMMIT
	END
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
	DECLARE @msg VARCHAR(5000)
	SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	DECLARE @err_num INT = ERROR_NUMBER()
	IF @err_num = 2601
		 SELECT @msg = 'Duplicate data in Date From.'
	ELSE IF @err_num = 2627
		SELECT @msg = 'Duplicate data in (Data Type and <b>Name</b>).'
	ELSE IF @err_num = 241
		SELECT @msg = 'Invalid date format in grid'
	
	EXEC spa_ErrorHandler -1
		, 'Source Deal Detail'
		, 'spa_UpdateHolidayXml'
		, 'DB Error'
		, @msg
		, 'Failed Inserting Record'
END CATCH


