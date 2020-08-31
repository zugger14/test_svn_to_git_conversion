
IF OBJECT_ID(N'spa_import_expiration_calendar', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_import_expiration_calendar]
 GO 

CREATE PROCEDURE [dbo].[spa_import_expiration_calendar]
	@temp_table_name VARCHAR(100),
	@table_id VARCHAR(100),
	@job_name VARCHAR(100),
	@process_id VARCHAR(100),
	@user_login_id VARCHAR(50)
AS
	DECLARE @sql                     VARCHAR(8000),
	        @url_desc                VARCHAR(250),
	        @url                     VARCHAR(250),
	        @error_count             INT,
	        @type                    CHAR,
	        @tempTable               VARCHAR(128),
	        @sqlStmt                 VARCHAR(5000),
	        @total_count             INT
	
	CREATE TABLE [#tmp_staging_table]
	(
		[holiday_group]       VARCHAR(200) COLLATE DATABASE_DEFAULT,
		[description]         VARCHAR(400) COLLATE DATABASE_DEFAULT,
		[maturity_date_from]  VARCHAR(20) COLLATE DATABASE_DEFAULT,	--[hol_date]
		[maturity_date_to]    VARCHAR(20) COLLATE DATABASE_DEFAULT,
		[expiration_date]     VARCHAR(20) COLLATE DATABASE_DEFAULT,
		[settlement_date]     VARCHAR(20) COLLATE DATABASE_DEFAULT
	)
	
	CREATE TABLE #tmp_incorrect_data
	(
		[holiday_group]       VARCHAR(200) COLLATE DATABASE_DEFAULT,
		[description]         VARCHAR(400) COLLATE DATABASE_DEFAULT,
		[maturity_date_from]  VARCHAR(20) COLLATE DATABASE_DEFAULT,	--[hol_date]
		[maturity_date_to]    VARCHAR(20) COLLATE DATABASE_DEFAULT,
		[expiration_date]     VARCHAR(20) COLLATE DATABASE_DEFAULT,
		[settlement_date]     VARCHAR(20) COLLATE DATABASE_DEFAULT
	)
	
	EXEC('INSERT INTO #tmp_incorrect_data
			SELECT * FROM ' + @temp_table_name +'
			WHERE holiday_group IS NULL
			OR maturity_date_from IS NULL
			OR expiration_date IS NULL
		') 
	
	--Insert data into temporary from staging table
	EXEC ('INSERT INTO #tmp_staging_table 
				SELECT sdv.value_id,
				       t.[description],
				       [maturity_date_from] AS [hol_date],
				       [maturity_date_to],
				       [expiration_date],
				       [settlement_date] 
					FROM ' + @temp_table_name + ' t
				INNER JOIN static_data_value sdv ON sdv.[description] = t.holiday_group
				WHERE t.holiday_group IS NOT NULL
				AND t.maturity_date_from IS NOT NULL
				AND t.expiration_date IS NOT NULL
			')
	--EXEC ('SELECT * FROM #tmp_incorrect_data')
	--EXEC ('SELECT * FROM #tmp_staging_table')
	
	--SELECT hg.* FROM holiday_group hg
	DELETE hg
	FROM holiday_group hg
		INNER JOIN #tmp_staging_table tst ON hg.hol_group_value_id = tst.holiday_group
		AND hg.hol_date = tst.maturity_date_from
		AND hg.exp_date = tst.expiration_date		  
	
	INSERT INTO holiday_group
	(
		hol_group_value_id,
		hol_date,
		[description],
		exp_date,
		settlement_date,
		hol_date_to
	)
	SELECT tst.holiday_group,
	       tst.maturity_date_from,
	       tst.description,
	       tst.expiration_date,
	       tst.settlement_date,
	       tst.maturity_date_to
	FROM #tmp_staging_table tst
	
	--SELECT hg.* FROM holiday_group hg
	--	INNER JOIN #tmp_staging_table tst ON hg.hol_group_value_id = tst.holiday_group
	--	AND hg.hol_date = tst.maturity_date_from
	--	AND hg.exp_date = tst.expiration_date	
				
	IF @@ERROR <> 0
	BEGIN
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [module], [source], [type], [description], [nextsteps])
		SELECT @process_id,
		       'Error',
		       'Import Data',
		       'Import Expiration Calendar',
		       'Data Errors',
		       'It is possible that the Data may be incorrect',
		       'Correct the error and reimport.'
	END

	-- check for data. if no data exists then give error  
	IF NOT EXISTS(SELECT 1 FROM #tmp_staging_table)
	BEGIN
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [module], [source], [type], [description], [nextsteps])
		SELECT @process_id,
		       'Error',
		       'Import Data',
		       'Import Expiration Calendar',
		       'Data Errors',
		       'It is possible that the file format may be incorrect',
		       'Correct the error and reimport.'
	END  

	--Check for errors           
	
	SET @type = 's'
	SET @url_desc = 'Detail...'        
	SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_transactions_log ''' + @process_id + ''''        
	     
	SELECT @error_count = COUNT(*) FROM   Import_Transactions_Log WHERE  process_id = @process_id AND code = 'Error'        
	
	IF EXISTS(SELECT * FROM #tmp_incorrect_data)
	BEGIN
		SET @type = 'e'
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [module], [source], [type], [description], [nextsteps])
		SELECT @process_id, 'Error', 'Import Data', 'Import Expiration Calendar', 'Data Error', 'Holiday Group missing.', ''
			FROM #tmp_incorrect_data WHERE holiday_group IS NULL
		UNION
		SELECT @process_id, 'Error', 'Import Data', 'Import Expiration Calendar', 'Data Error', 'Maturity Date From missing.', ''
			FROM #tmp_incorrect_data WHERE maturity_date_from IS NULL
		UNION
		SELECT @process_id, 'Error', 'Import Data', 'Import Expiration Calendar', 'Data Error', 'Expiration Date From missing.', ''
			FROM #tmp_incorrect_data WHERE expiration_date IS NULL
		
	END
	    
	IF @error_count > 0         
	BEGIN        
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [module], [source], [type], [description], [nextsteps])        
		SELECT @process_id,
		       'Error',
		       'Import Transactions',
			   'Import Expiration Calendar',
		       'Results',
		       'Import/Update Data completed with error(s).',
		       'Correct error(s) and reimport.'
		       
		SET @type = 'e'        
	END        
	ELSE        
	BEGIN
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [module], [source], [type], [description], [nextsteps])
		SELECT @process_id,
		       'Success',
		       'Import Data',
		       'Import Expiration Calendar',
		       'Results',
		       'Import/Update Data completed without error for  Hourly Group ID: '+ holiday_group +', Maturity Date From : ' + maturity_date_from + ', Expiration Date: '+expiration_date+'',
		       ''
		FROM   #tmp_staging_table
		GROUP BY
		       holiday_group,
		       maturity_date_from,
		       expiration_date
	END
	
	DECLARE @total_count_v  VARCHAR(50)   

	SET @total_count = 0        
	SELECT @total_count = COUNT(*) FROM [#tmp_staging_table]        

	SET @total_count_v = CAST(ISNULL(@total_count, 0) AS VARCHAR)        
	SET @url_desc = '<a target="_blank" href="' + @url + '">' +
					'Expiration Calendar data import process completed on as of date ' 
					+ dbo.FNAUserDateFormat(GETDATE(), @user_login_id) 
					+ CASE WHEN (@type = 'e') THEN ' (ERRORS found)' ELSE '' END 
					+ '.</a>'        

	EXEC spa_message_board 'i', @user_login_id, NULL, ' Import Expiration Calendar', @url_desc, '', '', @type, @job_name
