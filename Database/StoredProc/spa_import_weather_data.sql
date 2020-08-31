/****** Object:  StoredProcedure [dbo].[spa_import_weather_data]******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_weather_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_weather_data]
GO
/****** Object:  StoredProcedure [dbo].[spa_import_weather_data] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_import_weather_data]
	@flag CHAR(1),	-- c: create tables, p: process
	@process_id varchar(100),  
	@user_login_id varchar(50),
	@error_code INT = 0,
	@file_name VARCHAR(255) = NULL,
	@date_start VARCHAR(25) = NULL,
	@date_end VARCHAR(25) = NULL,
	@final_table VARCHAR(400) = NULL

AS 

DECLARE @sql VARCHAR(MAX), @type CHAR(1), @desc VARCHAR(8000) = 'Error Exist', @current_ts AS DATETIME = GETDATE()

DECLARE @final_staging_table VARCHAR(500)

SET @user_login_id = ISNULL(NULLIF(@user_login_id, ''), dbo.FNADBUser())

--IF @final_table IS NULL -- this condition is only for testing purpose, should never happen when running package
	--SELECT @final_staging_table = dbo.FNAProcessTableName('stage_weather', @user_login_id, @process_id)
	SELECT @final_staging_table = 'adiha_process.dbo.weather_' + @process_id
--ELSE 
--	SET @final_staging_table = @final_table

IF @flag = 'c'
BEGIN
		-- initiate import audit log,
	IF NOT EXISTS (SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
	BEGIN
		EXEC spa_import_data_files_audit 'i', @current_ts, NULL, @process_id, 'Weather Data Import', 'time_series_date', @current_ts, 'p', NULL
	END

	SET @sql = 'IF OBJECT_ID(''' + @final_staging_table + ''') IS NOT NULL
	                DROP TABLE ' + @final_staging_table
	EXEC(@sql)
	
	
	SET @sql = 'CREATE TABLE ' + @final_staging_table + ' (
					[stage_weather_id] [INT] IDENTITY(1,1) NOT NULL,
					[code] VARCHAR(50),
					[o_f] VARCHAR(50),
					[forecast_date] VARCHAR(50),
					[tmp] VARCHAR(50),
					[dpt] VARCHAR(50),
					[hum] VARCHAR(50),
					[hid] VARCHAR(50),
					[wcl] VARCHAR(50),
					[wdr] VARCHAR(50),
					[wsp] VARCHAR(50),
					[wet] VARCHAR(50),
					[cc] VARCHAR(50),
					[ssm] VARCHAR(50),
					[published_date] VARCHAR(50),
					[units] VARCHAR(50),
					[filename] VARCHAR(255) NULL,
					[file_date] DATETIME NULL,
					[create_ts] DATETIME DEFAULT CURRENT_TIMESTAMP
	            )
			'
	EXEC(@sql)
	
	SET @date_start = ISNULL(@date_start, CONVERT(VARCHAR(10), GETDATE(), 121))
	SET @date_end = ISNULL(@date_end, CONVERT(VARCHAR(10), GETDATE(), 121))
	
	-- selecting list of files to download
	;WITH DateRange(DateData) AS 
	(
		SELECT CAST(@date_start AS DATE)
		UNION ALL
		SELECT DATEADD(d, 1, DateData)
		FROM DateRange WHERE DateData < CAST(@date_end AS DATE) 
	)
	SELECT '/*' + REPLACE(CONVERT(VARCHAR(10), DateData, 10), '-', '') + '.TXT' [filename] FROM DateRange
	--OPTION (MAXRECURSION 0)

END

IF @flag = 'f'
BEGIN
	-- error code 0: no error, valid file exists
	-- error code 1: file does not exists in folder
	-- error code 2: error in file, DFT error
	-- error code 3: error in ftp download

	IF @error_code = 2 --DFT error
	BEGIN
		SET @type = 'e'
		SET @desc = 'Invalid File. Error importing: ' + @file_name
	END
	ELSE IF @error_code = 3 -- download error or file not found to download
	BEGIN
		SET @type = 'w'
		SET @desc = 'Weather Data not published for ' + dbo.FNADateFormat(SUBSTRING(@file_name, 3, 2) + '/'+SUBSTRING(@file_name, 5, 2) + '/'+ SUBSTRING(@file_name, 7, 2))
	END

	INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
	SELECT  @process_id,CASE @type WHEN 'e' THEN 'Error' WHEN 'w' THEN 'Warning' END , 'Import Data', 'time_series_data','Data Error',@desc,'n/a'
		
END

