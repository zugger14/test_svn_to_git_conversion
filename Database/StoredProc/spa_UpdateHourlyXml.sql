IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_UpdateHourlyXml]') AND [type] IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_UpdateHourlyXml]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_UpdateHourlyXml]
	@flag CHAR(1),
	@xmlValue NVARCHAR(MAX), -- for hourly block
	@xmlValue2 NVARCHAR(MAX), -- for holiday
	@xmlValue3 NVARCHAR(Max), -- for General tab
	@value_id VARCHAR(10) = NULL
AS

/*-------------------Debug Section-------------------
DECLARE @flag CHAR(1),
		@xmlValue NVARCHAR(MAX),
		@xmlValue2 NVARCHAR(MAX),
		@xmlValue3 NVARCHAR(Max),
		@value_id VARCHAR(10) = NULL
SELECT @flag = 'z',
	   @xmlValue = '<Root><PSRecordset block_value_id = "304625" holiday_value_id = "" week_day = "1" dst_applies="y" onpeak_offpeak="p"  edit_grid1 = " 1 "  edit_grid2 = " 1 "  edit_grid3 = " 1 "  edit_grid4 = " 1 "  edit_grid5 = " 1 "  edit_grid6 = " 1 "  edit_grid7 = " 1 "  edit_grid8 = " 1 "  edit_grid9 = " 1 "  edit_grid10 = " 1 "  edit_grid11 = " 1 "  edit_grid12 = " 1 "  edit_grid13 = " 1 "  edit_grid14 = " 1 "  edit_grid15 = " 1 "  edit_grid16 = " 1 "  edit_grid17 = " 1 "  edit_grid18 = " 1 "  
					edit_grid19 = " 1 "  edit_grid20 = " 1 "  edit_grid21 = " 1 "  edit_grid22 = " 1 "  edit_grid23 = " 1 "  edit_grid24 = " 1 "  ></PSRecordset><PSRecordset block_value_id = "304625" holiday_value_id = "" week_day = "2" dst_applies="y" onpeak_offpeak="p"  edit_grid1 = " 1 
					"  edit_grid2 = " 1 "  edit_grid3 = " 1 "  edit_grid4 = " 1 "  edit_grid5 = " 1 "  edit_grid6 = " 1 "  edit_grid7 = " 1 "  edit_grid8 = " 1 "  edit_grid9 = " 1 "  edit_grid10 = " 1 "  edit_grid11 = " 1 "  edit_grid12 = " 1 "  edit_grid13 = " 1 "  edit_grid14 = " 1 "  
					edit_grid15 = " 1 "  edit_grid16 = " 1 "  edit_grid17 = " 1 "  edit_grid18 = " 1 "  edit_grid19 = " 1 "  edit_grid20 = " 1 "  edit_grid21 = " 1 "  edit_grid22 = " 1 "  edit_grid23 = " 1 "  edit_grid24 = " 1 "  ></PSRecordset><PSRecordset block_value_id = "304625" 
					holiday_value_id = "" week_day = "3" dst_applies="y" onpeak_offpeak="p"  edit_grid1 = " 1 "  edit_grid2 = " 1 "  edit_grid3 = " 1 "  edit_grid4 = " 1 "  edit_grid5 = " 1 "  edit_grid6 = " 1 "  edit_grid7 = " 1 "  edit_grid8 = " 1 "  edit_grid9 = " 1 "  edit_grid10 = " 1 
					"  edit_grid11 = " 1 "  edit_grid12 = " 1 "  edit_grid13 = " 1 "  edit_grid14 = " 1 "  edit_grid15 = " 1 "  edit_grid16 = " 1 "  edit_grid17 = " 1 "  edit_grid18 = " 1 "  edit_grid19 = " 1 "  edit_grid20 = " 1 "  edit_grid21 = " 1 "  edit_grid22 = " 1 "  edit_grid23 = " 
					1 "  edit_grid24 = " 1 "  ></PSRecordset><PSRecordset block_value_id = "304625" holiday_value_id = "" week_day = "4" dst_applies="y" onpeak_offpeak="p"  edit_grid1 = " 1 "  edit_grid2 = " 1 "  edit_grid3 = " 1 "  edit_grid4 = " 1 "  edit_grid5 = " 1 "  edit_grid6 = " 1 
					"  edit_grid7 = " 1 "  edit_grid8 = " 1 "  edit_grid9 = " 1 "  edit_grid10 = " 1 "  edit_grid11 = " 1 "  edit_grid12 = " 1 "  edit_grid13 = " 1 "  edit_grid14 = " 1 "  edit_grid15 = " 1 "  edit_grid16 = " 1 "  edit_grid17 = " 1 "  edit_grid18 = " 1 "  edit_grid19 = " 1 
					"  edit_grid20 = " 1 "  edit_grid21 = " 1 "  edit_grid22 = " 1 "  edit_grid23 = " 1 "  edit_grid24 = " 1 "  ></PSRecordset><PSRecordset block_value_id = "304625" holiday_value_id = "" week_day = "5" dst_applies="y" onpeak_offpeak="p"  edit_grid1 = " 1 "  edit_grid2 = " 
					1 "  edit_grid3 = " 1 "  edit_grid4 = " 1 "  edit_grid5 = " 1 "  edit_grid6 = " 1 "  edit_grid7 = " 1 "  edit_grid8 = " 1 "  edit_grid9 = " 1 "  edit_grid10 = " 1 "  edit_grid11 = " 1 "  edit_grid12 = " 1 "  edit_grid13 = " 1 "  edit_grid14 = " 1 "  edit_grid15 = " 1 "  
					edit_grid16 = " 1 "  edit_grid17 = " 1 "  edit_grid18 = " 1 "  edit_grid19 = " 1 "  edit_grid20 = " 1 "  edit_grid21 = " 1 "  edit_grid22 = " 1 "  edit_grid23 = " 1 "  edit_grid24 = " 1 "  ></PSRecordset><PSRecordset block_value_id = "304625" holiday_value_id = "" 
					week_day = "6" dst_applies="y" onpeak_offpeak="p"  edit_grid1 = " 1 "  edit_grid2 = " 1 "  edit_grid3 = " 1 "  edit_grid4 = " 1 "  edit_grid5 = " 1 "  edit_grid6 = " 1 "  edit_grid7 = " 1 "  edit_grid8 = " 1 "  edit_grid9 = " 1 "  edit_grid10 = " 1 "  edit_grid11 = " 1 "  edit_grid12 = " 1 "  edit_grid13 = " 1 "  edit_grid14 = " 1 "  edit_grid15 = " 1 "  edit_grid16 = " 1 "  edit_grid17 = " 1 "  edit_grid18 = " 1 "  edit_grid19 = " 1 "  edit_grid20 = " 1 "  edit_grid21 = " 1 "  edit_grid22 = " 1 "  edit_grid23 = " 1 "  edit_grid24 = " 1 "  ></PSRecordset><PSRecordset block_value_id = "304625" holiday_value_id = "" week_day = "7" dst_applies="y" onpeak_offpeak="p"  edit_grid1 = " 1 "  edit_grid2 = " 1 "  edit_grid3 = " 1 "  edit_grid4 = " 1 "  edit_grid5 = " 1 "  edit_grid6 = " 1 "  edit_grid7 = " 1 "  edit_grid8 = " 1 "  edit_grid9 = " 1 "  edit_grid10 = " 1 "  edit_grid11 = " 1 "  edit_grid12 = " 1 "  edit_grid13 = " 1 "  edit_grid14 = " 1 "  edit_grid15 = " 1 "  edit_grid16 = " 1 "  edit_grid17 = " 1 "  edit_grid18 = " 1 "  edit_grid19 = " 1 "  edit_grid20 = " 1 "  edit_grid21 = " 1 "  edit_grid22 = " 1 "  edit_grid23 = " 1 "  edit_grid24 = " 1 "  ></PSRecordset></Root>
					',
 	   @xmlValue2 = '<Root><PSRecordset  block_value_id=" 304625 " onpeak_offpeak="o"  edit_grid1 = "0"  edit_grid2 = "0"  edit_grid3 = "0"  edit_grid4 = "0"  edit_grid5 = "0"  edit_grid6 = "0"  edit_grid7 = "0"  edit_grid8 = "0"  edit_grid9 = "0"  edit_grid10 = "0"  edit_grid11 = "0"  edit_grid12 = "0"  edit_grid13 = "0"  edit_grid14 = "0"  edit_grid15 = "0"  edit_grid16 = "0"  edit_grid17 = "0"  edit_grid18 = "0"  edit_grid19 = "0"  edit_grid20 = "0"  edit_grid21 = "0"  edit_grid22 = "0"  edit_grid23 = "0"  edit_grid24 = "0"  ></PSRecordset></Root >',
	   @xmlValue3 = '',
	   @value_id = 304625
----------------------------------------------------*/
SET NOCOUNT ON

DECLARE @sqlStmt VARCHAR(MAX), 
		@sqlStmt2 VARCHAR(MAX),
		@sqlStmt3 VARCHAR(MAX),
		@tempdetailtable VARCHAR(128), 
		@temphourtable VARCHAR(128),
		@sdvhour VARCHAR(128),
		@user_login_id VARCHAR(100),
		@process_id VARCHAR(50),
		@report_position_process_id VARCHAR(100),
		@job_name VARCHAR(100),
		@report_position_deals VARCHAR(300),
		@sql VARCHAR(8000),
		@block_value_id INT

SELECT @user_login_id = dbo.FNADBUser(), 
	   @process_id = REPLACE(NEWID(), '-', '_'),
	   @report_position_process_id = REPLACE(NEWID(), '-', '_')

SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @report_position_process_id)
SET @sqlStmt = '
	CREATE TABLE ' + @report_position_deals + ' (
		source_deal_header_id INT, action CHAR(1)
	)'

EXEC (@sqlStmt)

SET @sdvhour = dbo.FNAProcessTableName('sdv_hour', @user_login_id, @process_id)
SET @tempdetailtable = dbo.FNAProcessTableName('hourly_process', @user_login_id, @process_id)
SET @temphourtable = dbo.FNAProcessTableName('hourly', @user_login_id, @process_id)

DECLARE @idoc INT, @doc VARCHAR(1000)

EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue

IF OBJECT_ID ('tempdb..#ztbl_xmlvalue') IS NOT NULL
	DROP TABLE #ztbl_xmlvalue

SELECT * INTO #ztbl_xmlvalue
FROM OPENXML (@idoc, '/Root/PSRecordset', 2)
WITH (block_value_id  VARCHAR(255) '@block_value_id',
	  week_day VARCHAR(255) '@week_day',
	  dst_applies CHAR(1) '@dst_applies',
	  onpeak_offpeak VARCHAR(50) '@onpeak_offpeak',
	  holiday_value_id VARCHAR(50)'@holiday_value_id',
	  from_month VARCHAR(50)'@from_month',
	  to_month VARCHAR(50)'@to_month',
	  Hr1 INT '@edit_grid1',
	  Hr2 INT '@edit_grid2',
	  Hr3 INT '@edit_grid3',
	  Hr4 INT '@edit_grid4',
	  Hr5 INT '@edit_grid5',
	  Hr6 INT '@edit_grid6',
	  Hr7 INT '@edit_grid7',
	  Hr8 INT '@edit_grid8',
	  Hr9 INT '@edit_grid9',
	  Hr10 INT '@edit_grid10',
	  Hr11 INT '@edit_grid11',
	  Hr12 INT '@edit_grid12',
	  Hr13 INT '@edit_grid13',
	  Hr14 INT '@edit_grid14',
	  Hr15 INT '@edit_grid15',
	  Hr16 INT '@edit_grid16',
	  Hr17 INT '@edit_grid17',
	  Hr18 INT '@edit_grid18',
	  Hr19 INT '@edit_grid19',
	  Hr20 INT '@edit_grid20',
	  Hr21 INT '@edit_grid21',
	  Hr22 INT '@edit_grid22',
	  Hr23 INT '@edit_grid23',
	  Hr24 INT '@edit_grid24'
)

DECLARE @idoc2 INT,  @doc2 VARCHAR(1000)

EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xmlValue2

IF OBJECT_ID ('tempdb..#ztbl_xmlvalue2') IS NOT NULL
	DROP TABLE #ztbl_xmlvalue2

SELECT * INTO #ztbl_xmlvalue2
FROM OPENXML (@idoc2, '/Root/PSRecordset', 2)
WITH (block_value_id VARCHAR(50) '@block_value_id',
	  onpeak_offpeak VARCHAR(50) '@onpeak_offpeak',
	  Hr1 INT '@edit_grid1',
	  Hr2 INT '@edit_grid2',
	  Hr3 INT '@edit_grid3',
	  Hr4 INT '@edit_grid4',
	  Hr5 INT '@edit_grid5',
	  Hr6 INT '@edit_grid6',
	  Hr7 INT '@edit_grid7',
	  Hr8 INT '@edit_grid8',
	  Hr9 INT '@edit_grid9',
	  Hr10 INT '@edit_grid10',
	  Hr11 INT '@edit_grid11',
	  Hr12 INT '@edit_grid12',
	  Hr13 INT '@edit_grid13',
	  Hr14 INT '@edit_grid14',
	  Hr15 INT '@edit_grid15',
	  Hr16 INT '@edit_grid16',
	  Hr17 INT '@edit_grid17',
	  Hr18 INT '@edit_grid18',
	  Hr19 INT '@edit_grid19',
	  Hr20 INT '@edit_grid20',
	  Hr21 INT '@edit_grid21',
	  Hr22 INT '@edit_grid22',
	  Hr23 INT '@edit_grid23',
	  Hr24 INT '@edit_grid24'
)
	
IF @flag IN ('i', 'u')
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		
		DECLARE @idoc3 INT, @doc3 VARCHAR(1000)

		EXEC sp_xml_preparedocument @idoc3 OUTPUT, @xmlValue3
		
		IF OBJECT_ID ('tempdb..#ztbl_xmlvalue3') IS NOT NULL
			DROP TABLE #ztbl_xmlvalue3
		
		SELECT * INTO #ztbl_xmlvalue3
		FROM OPENXML (@idoc3, '/Root/PSRecordset', 2)
		WITH ([type_id] VARCHAR(50) '@type_id',
				[value_id] VARCHAR(50) '@value_id',
				[code] VARCHAR(50) '@code',
				[description] VARCHAR(100) '@description'
		)

		MERGE static_data_value AS sdv
		USING (
			SELECT [type_id], 
					[value_id],
					[code],
					[description]
			FROM #ztbl_xmlvalue3
		) zxv3 ON sdv.[value_id] = zxv3.[value_id]
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[type_id],
			[code],
			[description]
		)
		VALUES (
			zxv3.[type_id],
			zxv3.[code],
			zxv3.[description]
		)
		WHEN MATCHED THEN
		UPDATE SET code = zxv3.code,
					[description] = zxv3.[description];
		
		DECLARE @new_value_id INT, @insert_update_mode CHAR(1) = 'u'
		
		SELECT @value_id = [value_id]
		FROM #ztbl_xmlvalue3

		IF (@value_id = '' OR @value_id = NULL)
		BEGIN
			SET @insert_update_mode = 'i'
			SET @value_id = @@IDENTITY
		END
		
		INSERT INTO hourly_block_sdv_audit (
			value_id,
			[type_id],
			code,
			[description],
			create_user,
			create_ts,
			update_user,
			update_ts,
			user_action
		)
		SELECT value_id,
				[type_id],
				[code],
				[description],
				[create_user],
				[create_ts],
				dbo.FNADBUser(),
				GETDATE(),
				CASE WHEN @insert_update_mode = 'i' THEN 'insert' ELSE 'update' END [user_action]
		FROM static_data_value
		WHERE value_id = @value_id


		EXEC spa_ErrorHandler 0, 'Source Deal Detail', 'spa_UpdateHourlyXml', 'Success', 'Changed have been saved successfully.', @value_id
		COMMIT

		SET @user_login_id = ISNULL(@user_login_id, dbo.FNADBUser())
		SET @sql = 'spa_UpdateHourlyXml ''z'', ''' + @xmlValue + ''',''' + @xmlValue2 + ''','''', ' + @value_id + ''
		SET @job_name = 'UpdateHourlyXml' + @process_id
	
		EXEC spa_run_sp_as_job @job_name, @sql, 'UpdateHourlyXml', @user_login_id

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		DECLARE @err_num INT = ERROR_NUMBER(), @msg VARCHAR(5000)

		SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
		
		IF @err_num = 2601
				SELECT @msg = 'Duplicate data in Date From'
		ELSE IF @err_num = 2627
			SELECT @msg = 'Duplicate data in (Data Type and <b>Name</b>)'
	
		EXEC spa_ErrorHandler -1, 'Source Deal Detail', 'spa_UpdateHourlyXml', 'Error', @msg, 'Failed Inserting Record'
	END CATCH
END
ELSE IF @flag = 'z'
BEGIN
	--Hourly Block Start		
	MERGE hourly_block AS hb
	USING (
		SELECT block_value_id, week_day, dst_applies, onpeak_offpeak, NULLIF(holiday_value_id, 0) holiday_value_id, NULLIF(from_month, 0) from_month, NULLIF(to_month, 0) to_month,
				[Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12],
				[Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24]
		FROM #ztbl_xmlvalue
	) zxv ON hb.[block_value_id] = zxv.[block_value_id]
		AND hb.[onpeak_offpeak] = zxv.[onpeak_offpeak]
		AND hb.week_day = zxv.week_day
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (block_value_id, week_day, dst_applies, onpeak_offpeak, holiday_value_id, from_month, to_month,
				[Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12],
				[Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24]
		)
		VALUES (@value_id, zxv.week_day, zxv.dst_applies, zxv.onpeak_offpeak, zxv.holiday_value_id, zxv.from_month, zxv.to_month,
				zxv.[Hr1], zxv.[Hr2], zxv.[Hr3], zxv.[Hr4], zxv.[Hr5], zxv.[Hr6], zxv.[Hr7], zxv.[Hr8], zxv.[Hr9], zxv.[Hr10], zxv.[Hr11], zxv.[Hr12],
				zxv.[Hr13], zxv.[Hr14], zxv.[Hr15], zxv.[Hr16], zxv.[Hr17], zxv.[Hr18], zxv.[Hr19], zxv.[Hr20], zxv.[Hr21], zxv.[Hr22], zxv.[Hr23], zxv.[Hr24]
		)
	WHEN MATCHED THEN
		UPDATE
		SET dst_applies = zxv.dst_applies, holiday_value_id = zxv.holiday_value_id, from_month = zxv.from_month, to_month = zxv.to_month, Hr1 = zxv.Hr1,
			Hr2 = zxv.Hr2, Hr3 = zxv.Hr3, Hr4 = zxv.Hr4, Hr5 = zxv.Hr5, Hr6 = zxv.Hr6, Hr7 = zxv.Hr7,
			Hr8 = zxv.Hr8, Hr9 = zxv.Hr9, Hr10 = zxv.Hr10, Hr11 = zxv.Hr11, Hr12 = zxv.Hr12, Hr13 = zxv.Hr13,
			Hr14 = zxv.Hr14, Hr15 = zxv.Hr15, Hr16 = zxv.Hr16, Hr17 = zxv.Hr17, Hr18 = zxv.Hr18, Hr19 = zxv.Hr19,
			Hr20 = zxv.Hr20, Hr21 = zxv.Hr21, Hr22 = zxv.Hr22, Hr23 = zxv.Hr23, Hr24 = zxv.Hr24;
	--Hourly Block End

	--Holiday Block Start
	DECLARE @return_id INT
	SET @return_id = @value_id
		
	MERGE holiday_block hb
	USING (
		SELECT [block_value_id], [onpeak_offpeak], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7],
			   [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18],
			   [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24]
		FROM #ztbl_xmlvalue2
	) zxv ON hb.[block_value_id] = zxv.[block_value_id]
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		block_value_id, onpeak_offpeak, [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9],
		[Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21],
		[Hr22], [Hr23], [Hr24]
	) VALUES (
		@value_id, zxv.onpeak_offpeak, zxv.[Hr1], zxv.[Hr2], zxv.[Hr3], zxv.[Hr4], zxv.[Hr5], zxv.[Hr6],
		zxv.[Hr7], zxv.[Hr8], zxv.[Hr9], zxv.[Hr10], zxv.[Hr11], zxv.[Hr12], zxv.[Hr13], zxv.[Hr14],
		zxv.[Hr15], zxv.[Hr16], zxv.[Hr17], zxv.[Hr18], zxv.[Hr19], zxv.[Hr20], zxv.[Hr21], zxv.[Hr22],
		zxv.[Hr23], zxv.[Hr24]
	)
	WHEN MATCHED THEN
		UPDATE 
		SET Onpeak_offpeak = zxv.onpeak_offpeak, Hr1 = zxv.Hr1, Hr2 = zxv.Hr2, Hr3 = zxv.Hr3, Hr4 = zxv.Hr4,
			Hr5 = zxv.Hr5, Hr6 = zxv.Hr6, Hr7 = zxv.Hr7, Hr8 = zxv.Hr8, Hr9 = zxv.Hr9, Hr10 = zxv.Hr10,
			Hr11 = zxv.Hr11, Hr12 = zxv.Hr12, Hr13 = zxv.Hr13, Hr14 = zxv.Hr14, Hr15 = zxv.Hr15, Hr16 = zxv.Hr16,
			Hr17 = zxv.Hr17, Hr18 = zxv.Hr18, Hr19 = zxv.Hr19, Hr20 = zxv.Hr20, Hr21 = zxv.Hr21, Hr22 = zxv.Hr22,
			Hr23 = zxv.Hr23, Hr24 = zxv.Hr24;

	EXEC dbo.spa_generate_hour_block_term @return_id, NULL, NULL

	CREATE TABLE #deal_to_calc(source_deal_header_id INT)

	DECLARE @baseload_block_define_id VARCHAR(30)
		SELECT @baseload_block_define_id = CAST(value_id as VARCHAR(10)) FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load' 
	IF @baseload_block_define_id IS NULL 
		SET @baseload_block_define_id = 'NULL'

	SET @sql = 'INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id,create_user,create_ts,process_status,insert_type,deal_type,commodity_id,fixation,internal_deal_type_value_id)
					OUTPUT INSERTED.source_deal_header_id INTO #deal_to_calc(source_deal_header_id)
				SELECT sdh.source_deal_header_id, MAX(sdh.create_user), GETDATE(), 9 process_status, 0 deal_type, MAX(ISNULL(sdh.internal_desk_id, 17300)) deal_type, 
				MAX(ISNULL(spcd.commodity_id, -1)) commodity_id, MAX(ISNULL(sdh.product_id, 4101)) fixation, MAX(ISNULL(sdh.internal_deal_type_value_id, -999999))
				FROM source_deal_detail sdd 
				INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
				LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id and sdd.curve_id IS NOT NULL
				WHERE COALESCE(spcd.block_define_id, sdh.block_define_id, '+@baseload_block_define_id+') = ' + CAST(@return_id AS VARCHAR) + ' 
				GROUP BY sdh.source_deal_header_id '
	EXEC (@sql)

	IF EXISTS(SELECT 1 FROM #deal_to_calc)
		EXEC dbo.spa_calc_pending_deal_position @call_from = 1

END