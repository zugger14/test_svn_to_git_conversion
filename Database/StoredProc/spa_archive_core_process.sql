IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_archive_core_process]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_archive_core_process]
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
Performs actual data movement for archive process

Parameters:

@tbl_name : Table Name of source archiving table
@aod_from : Term date from where the data archiving starts
@tbl_from : Source table to move data from
@tbl_to : Destination table to move data to
@call_from : Archive Call From process; 1 - Closing Process, 2 - Archive Process
@job_name : Job Name
@user_login_id : User Login that initiate the process
@process_id : Unique Process Id

*/
CREATE PROC [dbo].[spa_archive_core_process]
	@tbl_name		VARCHAR(100), 
	@aod_from		VARCHAR(30),
	@tbl_from		VARCHAR(100) = '',
	@tbl_to			VARCHAR(100) = '',
	@call_from		INT,
	@job_name		VARCHAR(100),
	@user_login_id	VARCHAR(50),
	@process_id		VARCHAR(100) = NULL,
	@aod_to			VARCHAR(30) = NULL
AS 


DECLARE @sql_stmt				VARCHAR(8000)
DECLARE @url             		VARCHAR(500)
DECLARE @desc            		VARCHAR(500)
DECLARE @db_from         		VARCHAR(100)
DECLARE @db_to           		VARCHAR(100)
DECLARE @fq_table_from			VARCHAR(200)	--fully qualified table (same db or external archive via linked server) name from which data will be migrated)
DECLARE @fq_table_to			VARCHAR(200)	--fully qualified table (same db or external archive via linked server) name to which data will be migrated)
DECLARE @error_code       		VARCHAR(200)
--DECLARE @archive_start_date	VARCHAR(20)
--DECLARE @archive_end_date 	VARCHAR(20)
DECLARE @archive_start_date		DATETIME
DECLARE @archive_end_date 		DATETIME
DECLARE @field_list      		VARCHAR(8000)
DECLARE @where_field     		VARCHAR(100)
DECLARE @frequency_type  		VARCHAR(1)
DECLARE @date_part				VARCHAR(10)
DECLARE @is_external_db			BIT
DECLARE @partition_status		BIT
DECLARE @is_arch_table			VARCHAR(5)
DECLARE @existence_fields		VARCHAR(1500)
DECLARE @existence_fields_normal VARCHAR(2000)
DECLARE @inserted_col			VARCHAR(1000)
DECLARE @formula_table			VARCHAR(1000)
DECLARE @sql					VARCHAR(MAX)

IF object_id('tempdb..#data_status') IS NOT NULL 
	DROP TABLE #data_status

SET @desc = ''
PRINT @tbl_from
IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()
	
IF @user_login_id IS NULL
	SET @user_login_id = dbo.FNADBUser()
	
IF @job_name IS NULL
	SET @job_name = 'archive_data_' + @process_id
	
IF @tbl_from IS NULL
	SET @tbl_from = ''
IF @tbl_to IS NULL
	SET @tbl_to = ''

SELECT @frequency_type = archive_frequency,@db_from = archive_db, @field_list = field_list, @where_field = where_field
		FROM archive_data_policy_detail adpd 
		INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id 
		AND adp.main_table_name  = @tbl_name AND adpd.is_arch_table = 0 
------ EXISTENCE CHECK  
	
SELECT @db_to = archive_db
		FROM archive_data_policy_detail adpd 
		INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id 
		AND adpd.table_name  = @tbl_to AND adpd.is_arch_table = 1 

--SELECT @db_to = archive_db
--		FROM archive_data_policy_detail adpd 
--		INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id 
--		AND adpd.table_name  = @tbl_to AND adpd.is_arch_table = 0 
		
SELECT @db_from  = archive_db
		FROM archive_data_policy_detail adpd 
		INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id 
		AND adpd.table_name  = @tbl_from AND adpd.is_arch_table = 1
SELECT @is_arch_table = adpd.is_arch_table, @existence_fields = adp.existence_check_fields
		FROM archive_data_policy_detail adpd 
		INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id 
		AND adpd.table_name  = @tbl_to
PRINT 'TABLE TO:' + @tbl_to 

IF  ISNULL(CHARINDEX('.', @db_to), 0) <> 0
	SET @is_external_db = 1
ELSE
	SET @is_external_db = 0

IF ISNULL(@db_from, '') = '' 
    SET @db_from = 'dbo'
ELSE IF @db_from <> 'dbo'
    SET @db_from = @db_from + '.dbo'

IF ISNULL(@db_to, '') = '' 
    SET @db_to = 'dbo'
ELSE IF @db_to <> 'dbo'
    SET @db_to = @db_to + '.dbo'

SET @fq_table_to = @db_to + '.' +  @tbl_to	
SET @fq_table_from = @db_from + '.'  + @tbl_from


IF @aod_from IS NOT NULL AND @aod_to IS NOT NULL
BEGIN
	--if both dates are available, then no calculation for archive data is necessary
	SET @archive_start_date = @aod_from
	SET @archive_end_date = @aod_to
END     
ELSE IF @aod_to IS NOT NULL AND @aod_from IS NULL
BEGIN
	--if only @aod_to is available, then its scheduled archiving, called by a job
	SET @archive_end_date = @aod_to
	
	--get the min available date less than or equals to @archive_end_date as a start date (as all date upto @archive_end_data will be archived)
--	CREATE TABLE #archive_dates (min_date VARCHAR(20))
CREATE TABLE #archive_dates (min_date DATETIME)
PRINT '@tbl_from ' + @tbl_from 
	--IF @tbl_from LIKE 'Stage%'
	IF  EXISTS (SELECT 1 FROM archive_data_policy adp WHERE  adp.staging_table_name = @tbl_from )
 		BEGIN 
 		PRINT 'This is stage table - Insert in temp table #archive_dates '
 		SET @sql_stmt = 'INSERT INTO #archive_dates (min_date)
			SELECT MIN(CONVERT(VARCHAR(10), ' + @where_field + ', 120)) 
			FROM ' + @fq_table_from + '
			'
			--WHERE ' + @where_field + ' < = ''' + CAST( @archive_end_date AS VARCHAR) + '''
 		END 
 	ELSE 
 		BEGIN
 			PRINT 'This is not stage table - Insert in temp table #archive_dates'	
			SET @sql_stmt = 'INSERT INTO #archive_dates (min_date)
			SELECT MIN(CONVERT(VARCHAR(10), ' + @where_field + ', 120)) 
			FROM ' + @fq_table_from + '
			WHERE ' + @where_field + ' < = ''' + CAST( @archive_end_date AS VARCHAR) + ''''
 		END
 		


	PRINT ISNULL(@sql_stmt, 'NULL')
	PRINT @sql_stmt
	EXEC(@sql_stmt)

	SELECT @archive_start_date = min_date FROM #archive_dates
	
END
ELSE IF @aod_from IS NOT NULL AND @aod_to IS NULL
BEGIN
	PRINT 'Frequency type' 
	PRINT @frequency_type
	--if only @aod_from is available, then its call from Setup > Archive Data
	IF @frequency_type = 'a' --annually
	BEGIN
		SET @archive_start_date = CAST(CAST(YEAR(CAST(@aod_from AS DATETIME)) AS VARCHAR) + '-01-01' AS DATETIME)
		SET @archive_end_date = DATEADD(d, -1, DATEADD(YEAR, 1, @archive_start_date))
	END
	ELSE IF @frequency_type = 'm' --monthly
	BEGIN
		SET @archive_start_date = CAST(CAST(YEAR(CAST(@aod_from AS DATETIME)) AS VARCHAR) + '-' + CAST(MONTH(CAST(@aod_from AS DATETIME)) AS VARCHAR)+ '-01' AS DATETIME)
		SET @archive_end_date = DATEADD(d, -1, DATEADD(MONTH, 1, @archive_start_date))
	PRINT @archive_start_date
	PRINT @archive_end_date
	END
	ELSE IF @frequency_type = 'd' --daily
	BEGIN
		SET @archive_start_date = @aod_from
		SET @archive_end_date = @aod_from
	END
END
--SET @archive_start_date = CONVERT(VARCHAR(20), @archive_start_date, 120)
--SET @archive_end_date = CONVERT(VARCHAR(20), @archive_end_date, 120)
PRINT 'Archive Start Date: ' + ISNULL(CAST(@archive_start_date AS VARCHAR(20)), 'NULL')
PRINT 'Archive End Date: ' + ISNULL(CAST(@archive_end_date AS VARCHAR(20)), 'NULL')
       
SET @date_part = CASE @frequency_type WHEN 'a' THEN 'year' WHEN 'm' THEN 'month' WHEN 'd' THEN 'day' END
       
BEGIN TRY

	PRINT 'Start Data tranfer from source(' + @fq_table_from + ') to destination(' + @fq_table_to + ')'
	
	-- don't proceed the archival process if the source doesn't have data, otherwise data from destination will be removed (as a part of cleanup process
	-- before inserting the new), thus causing data loss.
	CREATE TABLE #data_status (data_exists TINYINT)
	--SET @sql_stmt = 'IF EXISTS(SELECT 1 FROM ' + @fq_table_from + ' WHERE CONVERT(VARCHAR(10), ' + @where_field + ', 120) BETWEEN ''' + CAST(@archive_start_date AS VARCHAR(20)) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR(20)) + ''') 
	--		INSERT INTO #data_status (data_exists) SELECT 1;'
	IF  EXISTS (SELECT 1 FROM archive_data_policy adp WHERE  adp.staging_table_name = @tbl_from )
 		BEGIN 
 		PRINT 'This is stage table - Insert in temp table #archive_dates '
 		SET @sql_stmt = 'IF EXISTS(SELECT 1 FROM ' + @fq_table_from  + ') 
			INSERT INTO #data_status (data_exists) VALUES(1);'
			
			PRINT @sql_stmt
			EXEC(@sql_stmt)
 		END 
 	ELSE 
 		BEGIN
 			
 			PRINT 'This is not stage table - Insert in temp table #archive_dates'	
			SET @sql_stmt = 'IF EXISTS(SELECT 1 FROM ' + @fq_table_from + ' WHERE  ' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR(20)) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR(20)) + ''') 
			INSERT INTO #data_status (data_exists) VALUES (1); '
			
			PRINT @sql_stmt
			EXEC(@sql_stmt)
 		END
	

	
	--PRINT   @fq_table_from
	
		
	PRINT 'tst'	
	IF NOT EXISTS (SELECT 1 FROM #data_status)
	BEGIN
		PRINT 'Archive halted. No data found in the source table.'
		SET @desc = 'Archive Failed. No data has been found in source table "'+  @tbl_from + '" to archive to "' +  @tbl_to + '".'
		IF @call_from NOT IN (1) --from Setup > Archive Data or from Job
		BEGIN
			EXEC spa_ErrorHandler -1									--error no
							, 'Archive Data'							--module
							, 'spa_archive_core_process'				--area
							, 'Warning'									--status
							, @desc										--message
							, 'Please check the date range provided.'	--recommendation
		END
		RETURN
	END
	
	--IF @call_from NOT IN (1)
	--BEGIN
	--	PRINT 'SET XACT_ABORT ON'
	--	SET XACT_ABORT ON

	--	IF @is_external_db = 1
	--	BEGIN 
	--		BEGIN DISTRIBUTED TRAN
	--	END
	--	ELSE
	--	BEGIN
	--		BEGIN TRAN
	--	END
	--END
	
	CREATE TABLE #existing_source_data(archive_where_date VARCHAR(20))
	
	--SET @sql_stmt = 'INSERT INTO #existing_source_data(archive_where_date)
	--					SELECT DISTINCT CONVERT(VARCHAR(10), ' + @where_field + ', 120)
	--					FROM ' + @fq_table_from + '
	--					WHERE CONVERT(VARCHAR(10), ' + @where_field + ', 120) BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + ''''
	
		
		IF  EXISTS (SELECT 1 FROM archive_data_policy adp WHERE  adp.staging_table_name = @tbl_from )
 			BEGIN 
 				PRINT 'This is stage table '
	 			SET @sql_stmt = 'INSERT INTO #existing_source_data(archive_where_date)
							SELECT DISTINCT  ' + @where_field + '
							FROM ' + @fq_table_from + '
							'
					--WHERE ' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + '''
				PRINT 'Inserting in #existing_source_data table'
 			END 
 		ELSE 
 			BEGIN
 				PRINT 'This is not stage table'
 				SET @sql_stmt = 'INSERT INTO #existing_source_data(archive_where_date)
							SELECT DISTINCT  ' + @where_field + '
							FROM ' + @fq_table_from + '
							WHERE ' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + ''''
				PRINT 'Inserting in #existing_source_data table'
 			END
 		
		
		
		
		PRINT @sql_stmt
		EXEC(@sql_stmt)	
	

	
	
	
		
	IF @is_arch_table = 1
		BEGIN
		
		PRINT 'TODO CHANGE section'
		PRINT @tbl_name
		IF @tbl_name = 'source_price_curve' OR @tbl_name = 'cached_curves_value'
		--Delete data from destination table if already exists for the range, but make sure to delete only those data that are available in source
		--otherwise data loss may occur.
			BEGIN 
				IF  EXISTS (SELECT 1 FROM archive_data_policy adp WHERE  adp.staging_table_name = @tbl_from )
 					BEGIN 
 						PRINT 'This is stage table '
	 					SELECT @existence_fields_normal  = STUFF((
						SELECT ' AND ' +    't.' + item + CAST(' =	' AS VARCHAR) +  'B.' + item FROM dbo.SplitCommaSeperatedValues(@existence_fields) scsv  FOR XML PATH('')), 1, 0, '')
						
						SET @sql_stmt = '
								DELETE t from ' + @fq_table_to + ' t 
								INNER JOIN #existing_source_data esd ON  t.' + @where_field + ' = esd.archive_where_date' + 
								CASE @tbl_name
									WHEN 'source_deal_pnl' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.source_deal_header_id = f.source_deal_header_id AND t.pnl_as_of_date = f.pnl_as_of_date and t.term_start = f.term_start and t.term_end = f.term_end'
									WHEN 'calcprocess_deals' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.fas_subsidiary_id = f.fas_subsidiary_id AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ',120)'
									WHEN 'calcprocess_aoci_release' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.link_id = f.link_id and CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ', 120)'  WHEN 'report_measurement_values' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.sub_entity_id = f.sub_entity_id AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), t.' + @where_field + ', 120)'
									WHEN 'report_netted_gl_entry' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.netting_parent_group_id = f.netting_parent_group_id  AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ', 120)'
									ELSE ''
								END 
							--+ ' WHERE CONVERT(VARCHAR(10), t.' + @where_field + ', 120) BETWEEN ''' + @archive_start_date + ''' AND ''' + @archive_end_date + ''''
							+ ' WHERE NOT EXISTS (SELECT 1 FROM  ' + @fq_table_to + ' B WHERE 1 = 1 '
						
						--' WHERE  t.' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) +
						--	 ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + ''
						SET @sql_stmt = @sql_stmt + @existence_fields_normal + ')'
 					END 
 				ELSE 
 					BEGIN
 						PRINT 'This is not stage table'
 						SELECT @existence_fields_normal  = STUFF((
						SELECT ' AND ' +    't.' + item + CAST(' =	' AS VARCHAR) +  'B.' + item FROM dbo.SplitCommaSeperatedValues(@existence_fields) scsv  FOR XML PATH('')), 1, 0, '')
						
						SET @sql_stmt = '
								FROM ' + @fq_table_to + ' t 
								INNER JOIN #existing_source_data esd ON  t.' + @where_field + ' = esd.archive_where_date' + 
								CASE @tbl_name
									WHEN 'source_deal_pnl' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.source_deal_header_id = f.source_deal_header_id AND t.pnl_as_of_date = f.pnl_as_of_date and t.term_start = f.term_start and t.term_end = f.term_end'
									WHEN 'calcprocess_deals' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.fas_subsidiary_id = f.fas_subsidiary_id AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ',120)'
									WHEN 'calcprocess_aoci_release' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.link_id = f.link_id and CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ', 120)'  WHEN 'report_measurement_values' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.sub_entity_id = f.sub_entity_id AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), t.' + @where_field + ', 120)'
									WHEN 'report_netted_gl_entry' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.netting_parent_group_id = f.netting_parent_group_id  AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ', 120)'
									ELSE ''
								END 
							--+ ' WHERE CONVERT(VARCHAR(10), t.' + @where_field + ', 120) BETWEEN ''' + @archive_start_date + ''' AND ''' + @archive_end_date + ''''
							+ ' 
							INNER JOIN ' + @fq_table_from + ' B ON 1 = 1 ' + @existence_fields_normal + '
							WHERE  t.' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) +
							 ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + ''''

 					SET @sql_stmt = 'IF EXISTS( SELECT 1 ' + @sql_stmt + ' )
									BEGIN
										DELETE t ' + @sql_stmt + '
									END
					'
					
					END
				
				PRINT 'hello 1'
				PRINT @sql_stmt
				EXEC(@sql_stmt)
			END 	
		ELSE
			BEGIN 
			PRINT 'DOUBT 1'
			
			IF  EXISTS (SELECT 1 FROM archive_data_policy adp WHERE  adp.staging_table_name = @tbl_from )
 				BEGIN 
 					PRINT 'This is stage table '
	 				SET @sql_stmt = '
					DELETE t from ' + @fq_table_to + ' t 
					INNER JOIN #existing_source_data esd ON  t.' + @where_field + ' = esd.archive_where_date' + 
					CASE @tbl_name
						WHEN 'source_deal_pnl' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.source_deal_header_id = f.source_deal_header_id AND t.pnl_as_of_date = f.pnl_as_of_date and t.term_start = f.term_start and t.term_end = f.term_end'
						WHEN 'calcprocess_deals' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.fas_subsidiary_id = f.fas_subsidiary_id AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ',120)'
						WHEN 'calcprocess_aoci_release' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.link_id = f.link_id and CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ', 120)'  WHEN 'report_measurement_values' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.sub_entity_id = f.sub_entity_id AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), t.' + @where_field + ', 120)'
						WHEN 'report_netted_gl_entry' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.netting_parent_group_id = f.netting_parent_group_id  AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ', 120)'
						ELSE ''
					END 
				--+ ' WHERE CONVERT(VARCHAR(10), t.' + @where_field + ', 120) BETWEEN ''' + @archive_start_date + ''' AND ''' + @archive_end_date + ''''
				--+ ' WHERE  t.' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) +
				-- ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + ''''
 				END 
 			ELSE 
 				BEGIN
 					PRINT 'This is not stage table'
 					SET @sql_stmt = '
					FROM ' + @fq_table_to + ' t 
					INNER JOIN #existing_source_data esd ON  t.' + @where_field + ' = esd.archive_where_date' + 
					CASE @tbl_name
						WHEN 'source_deal_pnl' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.source_deal_header_id = f.source_deal_header_id AND t.pnl_as_of_date = f.pnl_as_of_date and t.term_start = f.term_start and t.term_end = f.term_end'
						WHEN 'calcprocess_deals' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.fas_subsidiary_id = f.fas_subsidiary_id AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ',120)'
						WHEN 'calcprocess_aoci_release' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.link_id = f.link_id and CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ', 120)'  WHEN 'report_measurement_values' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.sub_entity_id = f.sub_entity_id AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), t.' + @where_field + ', 120)'
						WHEN 'report_netted_gl_entry' THEN ' INNER JOIN ' + @fq_table_from + ' f ON t.netting_parent_group_id = f.netting_parent_group_id  AND CONVERT(VARCHAR(10), t.' + @where_field + ', 120) = CONVERT(VARCHAR(10), f.' + @where_field + ', 120)'
						ELSE ''
					END 
				--+ ' WHERE CONVERT(VARCHAR(10), t.' + @where_field + ', 120) BETWEEN ''' + @archive_start_date + ''' AND ''' + @archive_end_date + ''''
				+ ' WHERE  t.' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) +
				 ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + ''''

				 	SET @sql_stmt = 'IF EXISTS( SELECT 1 ' + @sql_stmt + ' )
					BEGIN
						DELETE t ' + @sql_stmt + '
					END
					'
 				END

			PRINT 'hello 2'
			PRINT @sql_stmt
			EXEC(@sql_stmt)							
							
			END
		END 
		PRINT '@is_arch_table =' + @is_arch_table 
		IF @is_arch_table = 0 
			
			BEGIN
			PRINT 'This is Arch table = 0 '
			PRINT 'DOUBT 2'	
				SELECT @existence_fields_normal  = STUFF((
				SELECT ' AND ' +    'A.' + item + CAST(' =	' AS VARCHAR) +  'B.' + item FROM dbo.SplitCommaSeperatedValues(@existence_fields) scsv  FOR XML PATH('')), 1, 0, '')
				
				SET @sql_stmt  = 'INSERT INTO ' +  @fq_table_to +  '
					SELECT  * 
					FROM ' + @fq_table_from + ' A 
					WHERE ' + @where_field + ' BETWEEN  ' + CAST(@archive_start_date AS VARCHAR) + ' AND ' + CAST(@archive_end_date AS VARCHAR) +'
					AND NOT EXISTS (SELECT 1 FROM  ' + @fq_table_to + ' B WHERE 1 = 1 '-- AND  spc.maturity_date = spc1.maturity_date AND ..)

					SET @sql_stmt = @sql_stmt + @existence_fields_normal + ')'
					--EXEC (@sql_stmt)
					--PRINT @sql_stmt
					
			END
	
	----ELSE
	----	BEGIN
	----	SET @sql_stmt = 'INSERT INTO #existing_source_data(archive_where_date)
	----						SELECT DISTINCT  ' + @where_field + '
	----						FROM ' + @fq_table_from + '
	----						WHERE ' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + ''''
	----			SELECT @existence_fields_normal  = STUFF((
	----			SELECT ' AND ' + @fq_table_from +  '.' + item + ' <> ' + @fq_table_to + '.' + item FROM dbo.SplitCommaSeperatedValues(@existence_fields) scsv  FOR XML PATH('')

	----		), 1, 0, '')
	----	SET @sql_stmt = @sql_stmt + @existence_fields_normal
		
	----	EXEC(@sql_stmt)						
	----	END
		
	
	
	
	
/*
	--support for IDENTITY columns
	set @sql_stmt='
			IF EXISTS(SELECT * FROM sys.objects WHERE OBJECTPROPERTY(object_id,''TableHasIdentity'')=1 AND NAME='''+@tbl_name+@tbl_to+''')
			BEGIN
				SET IDENTITY_INSERT '+@tbl_name+@tbl_to+' ON
					INSERT INTO '+@db_to+'.'+@tbl_name+@tbl_to+ CASE WHEN @field_list='*' THEN '' ELSE ' ('+@field_list+')'	END +
						' SELECT '+@field_list+ ' 
							FROM '+@db_from+'.'+@tbl_name+@tbl_from+' 
						WHERE ' + @where_field + ' BETWEEN '''+CAST(@archive_start_date AS VARCHAR)+''' AND '''+CAST(@archive_end_date AS VARCHAR)+''';
					
				SET IDENTITY_INSERT '+@tbl_name+@tbl_to+' OFF
			END
			ELSE
				INSERT INTO '+@db_to+'.'+@tbl_name+@tbl_to+ CASE WHEN @field_list='*' THEN '' ELSE ' ('+@field_list+')'	END +	
					' SELECT '+@field_list+ ' 
						FROM '+@db_from+'.'+@tbl_name+@tbl_from+' 
					WHERE ' + @where_field + ' BETWEEN '''+cast(@archive_start_date AS VARCHAR)+''' AND '''+CAST(@archive_end_date AS VARCHAR)+''';'

*/
	
	--Copy from source table into destination
	IF EXISTS(SELECT * FROM sys.objects WHERE OBJECTPROPERTY(object_id,'TableHasIdentity') = 1 AND NAME = @tbl_to)
	BEGIN
		
		DECLARE @ColumnList VARCHAR(MAX)
		
		 --SET @ColumnList = 'A.' + @ColumnList
		 --RETURN 
		 
		IF @is_arch_table = 1 
		BEGIN
			SELECT @ColumnList = COALESCE(@ColumnList + ',', '') + COLUMN_NAME
		FROM information_schema.columns WHERE table_name = @tbl_to
		AND COLUMN_NAME NOT IN (SELECT NAME FROM sys.identity_columns WHERE sys.identity_columns.[object_id] = OBJECT_ID (@tbl_to))
		
		 ORDER BY ORDINAL_POSITION
		 PRINT 'santosh'
		 PRINT @ColumnList
		--SET IDENTITY_INSERT ' + @fq_table_to + ' ON;
		--SET IDENTITY_INSERT ' + @fq_table_to +  ' OFF;
			PRINT 'DOUBT 3'
			SET @sql_stmt = '  
					INSERT INTO ' + @fq_table_to + ' (' +  CASE WHEN @field_list = '*' THEN @ColumnList + ' )'  ELSE ' (' + @field_list + ')' END +	
						' SELECT ' + @ColumnList + ' 
							FROM ' + @fq_table_from + ' 
						WHERE ' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + '''; 
						'
			PRINT ('INSERT:' + ISNULL(@sql_stmt, 'NULL'))
			PRINT @sql_stmt
			EXEC(@sql_stmt);	
		END
		ELSE
			BEGIN
				--SET IDENTITY_INSERT ' + @fq_table_to  + ' ON;
				------- CHANGES done for constraint / refrential integrity. 
				PRINT  @tbl_to
				IF  EXISTS (SELECT 1 FROM archive_dependency ad WHERE  ad.main_table = @tbl_to )  
 				BEGIN 
 					--SET @ColumnList = ' '
				PRINT  @tbl_to
				PRINT @ColumnList
				SELECT   @ColumnList =   COALESCE(@ColumnList + ',A.', '') +  COLUMN_NAME
					FROM information_schema.columns WHERE table_name = @tbl_to
					AND COLUMN_NAME NOT IN (SELECT NAME FROM sys.identity_columns WHERE sys.identity_columns.[object_id] = OBJECT_ID (@tbl_to))
					ORDER BY ORDINAL_POSITION
				 print @ColumnList
		 --SET @ColumnList = 'A.' + @ColumnList
				SET @formula_table=dbo.FNAProcessTableName(@tbl_to, @user_login_id, @process_id)
				PRINT @formula_table
				--EXEC ('SELECT * FROM ' + @formula_table + '')
				PRINT 'DOUBT 44'
				SELECT @inserted_col = existence_chk_cols FROM archive_dependency WHERE main_table = @tbl_to
				SELECT @inserted_col  = STUFF((
				SELECT ', inserted.'  + item FROM dbo.SplitCommaSeperatedValues(@inserted_col) scsv  FOR XML PATH('')), 1, 0, ' ')
				SET @inserted_col = substring(@inserted_col, 3 , LEN(@inserted_col))
				PRINT @inserted_col 
				SET @inserted_col = @inserted_col + ' into ' + @formula_table
				SET @inserted_col = 'NULL, ' + @inserted_col
				
				SET @sql_stmt  = '  
					INSERT INTO ' + @fq_table_to + ' (' +  CASE WHEN @field_list = '*' THEN @ColumnList + ' )'  ELSE ' (' + @field_list + ')' END +	
					' output ' + @inserted_col + '  
					 SELECT ' + @ColumnList + ' 
					FROM ' + @fq_table_from + ' A  
					WHERE ' + @where_field + ' BETWEEN  ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) +'''
					AND NOT EXISTS (SELECT 1 FROM  ' + @fq_table_to + ' B WHERE 1 = 1 '-- AND  spc.maturity_date = spc1.maturity_date AND ..)

					SET @sql_stmt = @sql_stmt + @existence_fields_normal + ')'
					PRINT @sql_stmt
					EXEC (@sql_stmt)
				
				
			
				
				-- updating old calc_id with new one 
				DECLARE @pcol VARCHAR(100)
				SELECT @inserted_col = update_cols FROM archive_dependency WHERE main_table = @tbl_to
				SELECT @existence_fields_normal  = STUFF((
				SELECT ' AND ' +    @formula_table +  '.' + item + CAST(' =	' AS VARCHAR) +   'B.' + item FROM dbo.SplitCommaSeperatedValues(@inserted_col) scsv  FOR XML PATH('')), 1, 0, '')
				
				
				PRINT @existence_fields_normal
				
				SELECT @pcol = parent_column FROM archive_dependency WHERE main_table = @tbl_to
				SET @sql = 'UPDATE ' + @formula_TABLE + ' set old_id = b.' +@pcol + ' from ' + @tbl_from + ' B where 1= 1 '   + @existence_fields_normal
				PRINT @sql 
				EXEC (@sql)  
				
			
				
				--RETURN;
 				END 
 				
				ELSE IF EXISTS (SELECT 1 FROM archive_dependency ad WHERE  ad.dependent_table = @tbl_to )
				BEGIN 
					SELECT   @ColumnList =   COALESCE(@ColumnList + ',A.', '') +  COLUMN_NAME
					FROM information_schema.columns WHERE table_name = @tbl_to
					AND COLUMN_NAME NOT IN (SELECT NAME FROM sys.identity_columns WHERE sys.identity_columns.[object_id] = OBJECT_ID (@tbl_to))
					ORDER BY ORDINAL_POSITION
					PRINT @ColumnList
					 SET @ColumnList = 'A.' + @ColumnList
					PRINT 'DOUBT 444'
					DECLARE @tbl_org VARCHAR(128)
					SELECT @tbl_org = main_table FROM archive_dependency ad WHERE  ad.dependent_table = @tbl_to 
					SET @formula_table=dbo.FNAProcessTableName(@tbl_org, @user_login_id, @process_id)
					PRINT 'skg'
					PRINT @process_id
					PRINT @formula_table
					PRINT @ColumnList
					DECLARE @tcol VARCHAR(100)
					SELECT @tcol = child_column FROM archive_dependency WHERE dependent_table = @tbl_to
					PRINT @tcol
					
					
				SELECT @existence_fields_normal  = STUFF((
				SELECT ' AND ' +     'A.' + item + CAST(' =	' AS VARCHAR) +   'B.' + item FROM dbo.SplitCommaSeperatedValues(@existence_fields) scsv  FOR XML PATH('')), 1, 0, '')
				SELECT @pcol = parent_column FROM archive_dependency WHERE dependent_table = @tbl_to
				SET @ColumnList = REPLACE (@ColumnList, 'A.'+@tcol,'B.'+ @tcol)
					PRINT @ColumnList
				SET @sql_stmt  = '  
					INSERT INTO ' + @fq_table_to + ' (' +  CASE WHEN @field_list = '*' THEN @ColumnList + ' )'  ELSE ' (' + @field_list + ')' END +	
					' SELECT ' + @ColumnList + ' 
					FROM ' + @fq_table_from + ' A 
					INNER JOIN ' + @formula_table+' B on B.old_id =  A.' +@pcol +'  
					WHERE A.' + @where_field + ' BETWEEN  ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) +'''
					AND NOT EXISTS (SELECT 1 FROM  ' + @fq_table_to + ' B WHERE 1 = 1 '-- AND  spc.maturity_date = spc1.maturity_date AND ..)

					SET @sql_stmt = @sql_stmt + @existence_fields_normal + ')'
					PRINT @sql_stmt
					EXEC (@sql_stmt)
					
					END 
				ELSE
					
					BEGIN 
							SELECT   @ColumnList =   COALESCE(@ColumnList + ',A.', '') +  COLUMN_NAME
							FROM information_schema.columns WHERE table_name = @tbl_to
							AND COLUMN_NAME NOT IN (SELECT NAME FROM sys.identity_columns WHERE sys.identity_columns.[object_id] = OBJECT_ID (@tbl_to))
							ORDER BY ORDINAL_POSITION
						 print @ColumnList
						PRINT 'DOUBT 4'
						SELECT @existence_fields_normal  = STUFF((
						SELECT ' AND ' +     'A.' + item + CAST(' =	' AS VARCHAR) +   'B.' + item FROM dbo.SplitCommaSeperatedValues(@existence_fields) scsv  FOR XML PATH('')), 1, 0, '')
						
						SET @sql_stmt  = '  
							INSERT INTO ' + @fq_table_to + ' (' +  CASE WHEN @field_list = '*' THEN @ColumnList + ' )'  ELSE ' (' + @field_list + ')' END +	
							' SELECT ' + @ColumnList + ' 
							FROM ' + @fq_table_from + ' A  
							WHERE ' + @where_field + ' BETWEEN  ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) +'''
							AND NOT EXISTS (SELECT 1 FROM  ' + @fq_table_to + ' B WHERE 1 = 1 '-- AND  spc.maturity_date = spc1.maturity_date AND ..)

							SET @sql_stmt = @sql_stmt + @existence_fields_normal + ')'
							PRINT 'is problem here'
							PRINT @existence_fields_normal
							PRINT @fq_table_to
							PRINT @ColumnList
							PRINT @field_list
							PRINT @sql_stmt
							EXEC (@sql_stmt)
					END 
			END	
	END
	
	--INSERT INTO ' +  @fq_table_to +  '
		--			SELECT  * 
					
	IF NOT EXISTS(SELECT * FROM sys.objects WHERE OBJECTPROPERTY(object_id,'TableHasIdentity') = 1 AND NAME = @tbl_to)
	BEGIN
		IF @is_arch_table = 1 
		BEGIN
			PRINT 'DOUBT 5'	
			
			IF  EXISTS (SELECT 1 FROM archive_data_policy adp WHERE  adp.staging_table_name = @tbl_from )
 				BEGIN 
 					PRINT 'This is stage table - Archive records from Source to Destination '
 					SET @sql_stmt = '  
						INSERT INTO ' + @fq_table_to + CASE WHEN @field_list = '*' THEN '' ELSE ' (' + @field_list + ')' END +	
							' SELECT ' + @field_list + ' 
								FROM ' + @fq_table_from + ' 
							'; 
							
							--WHERE ' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + ''
					PRINT ('INSERT:' + ISNULL(@sql_stmt, 'NULL'))
 				END 
 			ELSE 
 				BEGIN
 					PRINT 'This is not stage table - Archive records from Source to Destination'
 					SET @sql_stmt = '  
						INSERT INTO ' + @fq_table_to + CASE WHEN @field_list = '*' THEN '' ELSE ' (' + @field_list + ')' END +	
							' SELECT ' + @field_list + ' 
								FROM ' + @fq_table_from + ' 
							WHERE ' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + '''; 
							'
					PRINT ('INSERT:' + ISNULL(@sql_stmt, 'NULL'))
 				END
 			
		
			PRINT @sql_stmt
			EXEC(@sql_stmt)
		END	
		ELSE
			BEGIN
			PRINT 'DOUBT 6'
			PRINT 'Insert for IDENTITY'
				SELECT @existence_fields_normal  = STUFF((
				SELECT ' AND ' +    'A.' + item + CAST(' =	' AS VARCHAR) +   'B.' + item FROM dbo.SplitCommaSeperatedValues(@existence_fields) scsv  FOR XML PATH('')), 1, 0, '')
				
				SET @sql_stmt  = 'INSERT INTO ' +  @fq_table_to +  '
					SELECT  * 
					FROM ' + @fq_table_from + '  A
					WHERE ' + @where_field + ' BETWEEN  ''' + cast (@archive_start_date AS VARCHAR) + ''' AND ''' + cast (@archive_end_date AS VARCHAR) +'''
					AND NOT EXISTS (SELECT 1 FROM  ' + @fq_table_to + ' B WHERE 1 = 1 '-- AND  spc.maturity_date = spc1.maturity_date AND ..)

					SET @sql_stmt = @sql_stmt + @existence_fields_normal + ')'
					EXEC (@sql_stmt)
					PRINT @sql_stmt
			END
	END
	
	----- Adding new logic to archive records from those tables which are related with some IDs instead of date. 
----Issue noticed while settlement archival in REC Tracker where calc_invoice_volume_variance needs to archived on the basis of date 
--while other tables needs to be archived on the basis of calc_id lying between those date range 
--
-- check in archive_dependency table either such case exists or not
	
	PRINT 'SAN ARCH'
	PRINT @is_arch_table
	--IF @is_arch_table = 1 
	
		DECLARE @ad_id INT , @p_table VARCHAR(128)
		SELECT @ad_id = archive_data_policy_id FROM archive_data_policy_detail WHERE TABLE_name = @tbl_from
		SELECT @p_table = main_table_name FROM archive_data_policy adp WHERE archive_data_policy_id = @ad_id
		
		
		
		
		IF  EXISTS (SELECT 1 FROM archive_dependency adp WHERE  adp.main_table = @p_table )
			BEGIN 
				PRINT 'Archive dependency started'
				--SELECT * INTO adiha_process.dbo.aaa FROM #existing_source_data
				DECLARE @dependent_table VARCHAR(128)
				
				SET @dependent_table=dbo.FNAProcessTableName(@p_table + '_', @user_login_id, @process_id)
					
				
					SET @sql='
						CREATE TABLE '+@dependent_table+'( d_id int)'
					PRINT @sql
					EXEC (@sql)		 
				DECLARE @parent_col VARCHAR(100)
				SELECT @parent_col = parent_column FROM archive_dependency ad WHERE ad.main_table = @p_table
				SET @sql_stmt = 'INSERT INTO ' + @dependent_table + '(d_id) 
							SELECT DISTINCT  ' + @parent_col + '
							FROM ' + @tbl_from + '
							WHERE ' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + ''''
				PRINT 'Inserting in #dependent_ids table'
				PRINT @sql_stmt
				EXEC (@sql_stmt)
				PRINT @p_table
				--RETURN 
				EXEC spa_archive_dependent_data @p_table, @process_id, @is_arch_table
				
				
			END 
	--Delete migrated data from source
	
	IF  EXISTS (SELECT 1 FROM archive_data_policy adp WHERE  adp.staging_table_name = @tbl_from  )
 		BEGIN 
 		PRINT 'This is stage table --Delete records from Source '
 			SET @sql_stmt = '
			DELETE FROM ' + @fq_table_from
			PRINT @sql_stmt
			EXEC(@sql_stmt)
 		END 
 	ELSE 
 		BEGIN 
 			PRINT 'This is not stage table -Delete records from Source'
 			SET @sql_stmt = '
			DELETE ' + @fq_table_from +
				' WHERE  ' + @where_field + ' BETWEEN ''' + CAST(@archive_start_date AS VARCHAR) + ''' AND ''' + CAST(@archive_end_date AS VARCHAR) + ''''
			PRINT @sql_stmt
			EXEC(@sql_stmt)
 		END 
 		
	
	
	--Update log in process_table_location, delete first and insert new

	IF  EXISTS (SELECT 1 FROM archive_data_policy adp WHERE  adp.staging_table_name = @tbl_from )
 		BEGIN 
 			PRINT 'This is stage table -Delete records from process_table'
 			DELETE process_table_location
			FROM process_table_location ptl
			INNER JOIN #existing_source_data esd ON ptl.as_of_date = esd.archive_where_date
			--WHERE as_of_date BETWEEN @archive_start_date AND @archive_end_date AND tbl_name = @tbl_name
 		END 
 	ELSE 
 		BEGIN
 			PRINT 'This is not stage table -Delete records from process_table'
 			DELETE process_table_location
			FROM process_table_location ptl
			INNER JOIN #existing_source_data esd ON ptl.as_of_date = esd.archive_where_date
			WHERE as_of_date BETWEEN @archive_start_date AND @archive_end_date AND tbl_name = @tbl_name
 		END
 		
	
	
	
	--TODO: To be finalized
	SET @date_part = 'dd'
	--		SELECT date_breakdown.archive_where_date, ''' + @tbl_to + ''' prefix_location_table, ''' + @db_to + ''' dbase_name, ''' + @tbl_name + ''' tbl_name
	DECLARE @frm_date DATETIME
	DECLARE @to_date DATETIME
	IF @archive_start_date < @archive_end_date 
		BEGIN 
		SET  @frm_date = @archive_start_date
		SET @to_date = @archive_end_date
		END 
	ELSE 
		BEGIN 
		SET @frm_date = @archive_end_date 
		SET @to_date = @archive_start_date
		END 
	
	PRINT 'IS ARCH Table'+ @is_arch_table
	PRINT 'confusion'
	PRINT @tbl_to
	PRINT @tbl_name
	IF @is_arch_table = 0 AND (@tbl_name = 'source_price_curve' OR @tbl_name = 'cached_curves_value' )
		PRINT 'Price Curve - Archive to Main - No entry in Process table '
	ELSE
		BEGIN
			SET @sql_stmt = '
			INSERT INTO process_table_location (as_of_date, prefix_location_table, dbase_name, tbl_name)		
			SELECT date_breakdown.archive_where_date, ''' + REPLACE(@tbl_to, @tbl_name, '')  + ''' prefix_location_table, ''' + @db_to + ''' dbase_name, ''' + @tbl_name + ''' tbl_name
			FROM
			(   
			--breakdown date range into parts defined by frequency (daily, monthly etc).
			--go on adding each unit (day, month...defined by frequency) to archival start date until we get to the archival end date   
			SELECT TOP(DATEDIFF(' + @date_part + ',''' + CAST(@frm_date AS VARCHAR(20)) + ''', ''' + CAST(@to_date AS VARCHAR(20)) + ''') + 1)
			DATEADD(' + @date_part + ', ROW_NUMBER() OVER (ORDER BY n) - 1, ''' + CAST(@archive_start_date AS VARCHAR(20)) + ''') archive_where_date
			FROM dbo.seq
			) date_breakdown
			INNER JOIN #existing_source_data esd ON date_breakdown.archive_where_date = esd.archive_where_date;'
	
			PRINT @sql_stmt	
	
			EXEC(@sql_stmt)
		END
	
			
	--IF @call_from NOT IN (1)
	--	COMMIT TRAN
	
	PRINT 'End Data tranfer from source(' + @fq_table_from + ') to destination(' + @fq_table_to + ')'

	SET @error_code = 's'
	SET @desc = 'Successfully archived the data from "' +  @tbl_from + '" to "' +  @tbl_to + '".'
	IF @call_from NOT IN (1) --from Setup > Archive Data and from job
	BEGIN
		--EXEC spa_ErrorHandler 0							--error no
		--					, 'Archive Data'				--module
		--					, 'spa_archive_core_process'	--area
		--					, 'Success'						--status
		--					, @desc							--message
		--					, ''							--recommendation
		/*
		* Calling spa_ErrorHandler will return 'Success' as ErrorCode which makes the messagebox disappear quickly. So to persist it,
		* use Select statement and pass ErrorCode any value other than Success or Error. Make sure to change the php code as well,
		* if ErrorCode is read in php.
		*/
	--PRINT 'san'
		SELECT 'Saved' AS ErrorCode, 'Archive Data' Module, 'spa_archive_core_process' Area, 'Success' [Status], @desc [Message], '' Recommendation
	END
	PRINT 'End:' + @tbl_name
END TRY
BEGIN CATCH
	PRINT 'Archive Error:' + ERROR_MESSAGE()

	--IF @call_from NOT IN (1) AND @@TRANCOUNT > 0
	--	ROLLBACK TRAN
		
	SET @error_code = 'e'
	SELECT @desc = 'Archival of data failed from ' +  @tbl_from + ' to ' +  @tbl_to 
		+ ' (From: ' + dbo.FNAUserDateFormat(@archive_start_date, @user_login_id) + ' To: ' + dbo.FNAUserDateFormat(@archive_end_date, @user_login_id) 
		+ '). [' + ERROR_MESSAGE() + '].'
	
	IF @call_from NOT IN (1) --from Setup > Archive Data
	BEGIN
		EXEC spa_ErrorHandler -1							--error no
							, 'Archive Data'				--module
							, 'spa_archive_core_process'	--area
							, 'Error'						--status
							, @desc							--message
							, ''							--recommendation
	END
	ELSE --from close accounting period
	BEGIN
		INSERT INTO source_system_data_import_status(process_id, code, module, [source], [type], [description], recommendation) 
		SELECT @process_id, 'Error', 'Archive Data', 'Archive Data', 'Archive Error', @desc, 'Please contact support.'
		
		INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description]) 
		SELECT @process_id, 'Archive Data', 'Archive Data', @desc

		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
				'&spa=exec spa_get_import_process_status ''' + @process_id + ''', ''' + @user_login_id + ''''

		SELECT @url = '<a target="_blank" href="' + @url + '">' + 
					'Archive process is Completed for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) +	'.</a>'
		
		EXEC  spa_message_board 'i', @user_login_id, NULL, 'Archive.Data', @url, '', '', 's', @job_name, NULL, @process_id
				
		RAISERROR (@desc, -- Message id.
				   11, -- Severity,
				   1 -- State)
				   )
	END
	
END CATCH
GO


