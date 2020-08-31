
IF OBJECT_ID(N'[dbo].[spa_delete_import_loadforcast_price]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_delete_import_loadforcast_price]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: dmanandhar@pioneersolutionsglobal.com/rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-11-09
-- Description: Remove Data 
-- Params:
-- @flag CHAR(1) - Operation flag
--						  -- 'm' - For Meter Data Removal 
--						  -- 'p' - For Price Curve Data Removal 	
--						  -- 'l' - For Load Forecast Data Removal 
-- @as_of_date DATETIME   -- Needed just for flag 'p'
-- @term_start DATETIME   -- Compulsory for all flag ('p', 'm', 'l')
-- @term_end DATETIME	  -- Compulsory for all flag ('p', 'm', 'l')	
-- @profile_id INT		  -- Needed for flag 'l'	
-- @meter_id INT		  -- Needed for flag 'm'	
-- @index VARCHAR(MAX)	  -- Needed for flag 'p' (It supports comma(,) separated mulitple indexes) 
-- @hr_from TINYINT       -- Hour From
-- @hr_to TINYINT		  -- Hour To	
-- @batch_process_id      -- Batch process ID (Auto generated parameter)
-- @batch_report_param    -- Batch Report Parameter (Auto generated parameter)

/*
 EXEC spa_delete_import_loadforcast_price 'm', NULL, '2011-10-01', '2011-11-09', NULL, 26, NULL, 1, 12 
 EXEC spa_delete_import_loadforcast_price 'p', '2011-10-25', '2011-10-25', '2011-10-25', NULL, 13, '9,11,12', 1, 23
*/
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_delete_import_loadforcast_price]
	@flag CHAR(1),
    @as_of_date DATETIME = NULL,
    @term_start DATETIME,
    @term_end DATETIME,
    @profile_id INT = NULL,
    @meter_id INT = NULL,
    @index VARCHAR(MAX) = NULL,
	@hr_from TINYINT = NULL,
	@hr_to TINYINT = NULL,
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(1000) = NULL
AS
 
DECLARE @sql              	VARCHAR(MAX)
DECLARE @error            	VARCHAR(25)
DECLARE @sp_name          	VARCHAR(100)
DECLARE @report_name      	VARCHAR(100)
DECLARE @str_batch_table  	VARCHAR(8000)
DECLARE @is_batch         	BIT
DECLARE @sql_paging       	VARCHAR(8000)
DECLARE @user_login_id    	VARCHAR(50)
DECLARE @list_str			VARCHAR(MAX)
DECLARE @curve_id_in_deal	VARCHAR(MAX)

SET @str_batch_table = ''
SET @error = ''
SET @user_login_id = dbo.FNADBUser()
DECLARE @desc VARCHAR(MAX) 

/*******************************************1st Paging Batch START**********************************************/
DECLARE @begin_time DATETIME
SET @begin_time = GETDATE()

SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

IF @batch_process_id IS NULL
	SET @batch_process_id = dbo.FNAGetNewID()	
/*******************************************1st Paging Batch END**********************************************/	

CREATE TABLE #tmp_archive (tbl_name VARCHAR(500) COLLATE DATABASE_DEFAULT, max_date DATETIME, min_date DATETIME)

IF @flag = 'm' --Meter Data remove
BEGIN
	IF (SELECT 1
	    FROM   mv90_data md
	    INNER JOIN meter_id m ON  m.meter_id = md.meter_id
	    WHERE  m.meter_id = @meter_id
	           AND md.from_date BETWEEN @term_start AND @term_end) IS NULL
	BEGIN
		SET @desc = 'Data not found for Meter Data for ' + CONVERT(VARCHAR(10), @term_start, 120) + ' to ' +  CONVERT(VARCHAR(10), @term_end, 120)
	END
	ELSE
	BEGIN
		BEGIN TRY
			BEGIN TRAN		
			IF (@hr_from IS NULL AND @hr_to IS NULL) OR (@hr_from = 1 AND @hr_to = 24)
			BEGIN
				EXEC spa_print 'DELETE mv90_data_hour'
				DELETE mv90_data_hour				
				FROM mv90_data_hour mdh
				INNER JOIN mv90_data md ON md.meter_data_id = mdh.meter_data_id
				INNER JOIN meter_id m ON m.meter_id = md.meter_id  
				WHERE m.meter_id = @meter_id				   
					AND mdh.prod_date BETWEEN @term_start AND @term_end
				
				EXEC spa_print 'DELETE mv90_data_mins'			
				DELETE mv90_data_mins				
				FROM mv90_data_mins mdm
				INNER JOIN mv90_data md ON md.meter_data_id = mdm.meter_data_id
				INNER JOIN meter_id m ON m.meter_id = md.meter_id  
				WHERE m.meter_id = @meter_id
					AND mdm.prod_date BETWEEN @term_start AND @term_end
				
				EXEC spa_print 'DELETE mv90_data' 
				DELETE 				
				FROM mv90_data WHERE meter_id = @meter_id 
					AND from_date >= @term_start 
					AND to_date <= @term_end
			END
			ELSE
			BEGIN
				DECLARE @final_sql VARCHAR(MAX)
				--FOR NON DST
				EXEC spa_print 'DELETE mv90_data_hour'
				SET @sql = 'UPDATE mv90_data_hour SET '
				SELECT @list_str = COALESCE(@list_str + ', ', '') + 'Hr' + CAST(n AS VARCHAR(2)) + ' = NULL'
				FROM dbo.seq WHERE n BETWEEN @hr_from AND @hr_to
														   
				SET @final_sql = @sql + @list_str + ' FROM mv90_data_hour mdh
																INNER JOIN mv90_data md 
																	ON md.meter_data_id = mdh.meter_data_id
																INNER JOIN meter_id m 
																	ON m.meter_id = md.meter_id 
																WHERE m.meter_id = ' + CAST(@meter_id AS VARCHAR(30)) 
																+ ' AND mdh.prod_date BETWEEN ''' + CAST(@term_start AS VARCHAR(30)) + ''' AND ''' + CAST(@term_end AS VARCHAR(30)) + ''''
				EXEC spa_print @final_sql
				EXEC (@final_sql)
				
				EXEC spa_print 'DELETE mv90_data_mins'
				SET @list_str = NULL
				SET @sql = 'UPDATE mv90_data_mins set '
				SELECT @list_str = COALESCE(@list_str + ',', '') + 'Hr' + CAST(hr.n AS VARCHAR(10)) + '_' + CAST(mn.n as varchar(10))  + ' = NULL'
				FROM  (SELECT n FROM dbo.seq WHERE n BETWEEN @hr_from AND @hr_to) hr
						CROSS JOIN (SELECT n * 15 AS n FROM dbo.seq WHERE n BETWEEN 1 AND 4) mn
				ORDER BY hr.n, mn.n
				
				SET @final_sql = @sql + @list_str + ' FROM mv90_data_mins mdm
																INNER JOIN mv90_data md 
																	ON md.meter_data_id = mdm.meter_data_id
																INNER JOIN meter_id m 
																	ON m.meter_id = md.meter_id
																WHERE m.meter_id = ' + CAST(@meter_id AS VARCHAR(30)) 
																+ ' AND mdm.prod_date BETWEEN ''' + CAST(@term_start AS VARCHAR(30)) + ''' AND ''' + CAST(@term_end AS VARCHAR(30)) + ''''
				EXEC spa_print @final_sql
				EXEC (@final_sql)
				
				--DST DATA
				EXEC spa_print 'DELETE mv90_data_hour'
				SET @sql = 'UPDATE mv90_data_hour SET '
				SET @list_str = NULL
				SELECT @list_str = COALESCE(@list_str + ', ', '') + 'Hr' + CAST(n AS VARCHAR(2)) + ' = NULL'
				FROM dbo.seq
				WHERE n BETWEEN @hr_from AND @hr_to
														   
				SET @final_sql = @sql + @list_str + ', Hr25 = NULL FROM mv90_data_hour mdh
																INNER JOIN mv90_data md 
																	ON md.meter_data_id = mdh.meter_data_id
																INNER JOIN meter_id m 
																	ON m.meter_id = md.meter_id 
																INNER JOIN mv90_DST mvdst ON mvdst.date = mdh.prod_date
																WHERE m.meter_id = ' + CAST(@meter_id AS VARCHAR(30)) 
																+ ' AND mdh.prod_date BETWEEN ''' + CAST(@term_start AS VARCHAR(30)) + ''' AND ''' + CAST(@term_end AS VARCHAR(30)) + '''' 
																+ ' AND mvdst.insert_delete = ''i'' AND mvdst.hour BETWEEN ' + CAST(@hr_from AS VARCHAR(10)) + ' AND ' + CAST(@hr_to AS VARCHAR(10))
				EXEC spa_print @final_sql
				EXEC (@final_sql)
				
				EXEC spa_print 'DELETE mv90_data_mins'
				SET @list_str = NULL
				SET @sql = 'UPDATE mv90_data_mins set '
				SELECT @list_str = COALESCE(@list_str + ',', '') + 'Hr' + CAST(hr.n AS VARCHAR(10)) + '_' + CAST(mn.n as varchar(10))  + ' = NULL'
				FROM 
				(SELECT n FROM dbo.seq WHERE n BETWEEN @hr_from AND @hr_to) hr
				CROSS JOIN (SELECT n * 15 AS n FROM dbo.seq WHERE n BETWEEN 1 AND 4) mn
				ORDER BY hr.n, mn.n
				
				SET @final_sql = @sql + @list_str + + ', Hr25_15 = NULL, Hr25_30 = NULL, Hr25_45 = NULL, Hr25_60 = NULL FROM mv90_data_mins mdm
																INNER JOIN mv90_data md 
																	ON md.meter_data_id = mdm.meter_data_id
																INNER JOIN meter_id m 
																	ON m.meter_id = md.meter_id
																INNER JOIN mv90_DST mvdst ON mvdst.date = mdm.prod_date
																WHERE m.meter_id = ' + CAST(@meter_id AS VARCHAR(30)) 
																+ ' AND mdm.prod_date BETWEEN ''' + CAST(@term_start AS VARCHAR(30)) + ''' AND ''' + CAST(@term_end AS VARCHAR(30)) + ''''
																+ ' AND mvdst.insert_delete = ''i'' AND mvdst.hour BETWEEN ' + CAST(@hr_from AS VARCHAR(10)) + ' AND ' + CAST(@hr_to AS VARCHAR(10))
				EXEC spa_print @final_sql
				EXEC (@final_sql)
			
				--CHECK IF mv90_min TABLE IS empty
				IF EXISTS(SELECT 1 FROM mv90_data_hour mdh
					INNER JOIN mv90_data md ON md.meter_data_id = mdh.meter_data_id
					INNER JOIN meter_id m ON m.meter_id = md.meter_id  
					WHERE m.meter_id = @meter_id				   
						AND mdh.prod_date BETWEEN @term_start AND @term_end)
				BEGIN
					EXEC spa_print 'calculating total'
					--DROP  TABLE #temp_table
					SELECT DISTINCT md.meter_data_id, 
						ISNULL(SUM(Hr1), '') + ISNULL(SUM(Hr2), '') + ISNULL(SUM(Hr3), '') + ISNULL(SUM(Hr4), '') + ISNULL(SUM(Hr5), '') 
					   + ISNULL(SUM(Hr6), '') + ISNULL(SUM(Hr7), '') + ISNULL(SUM(Hr8), '') + ISNULL(SUM(Hr9), '') + ISNULL(SUM(Hr10), '') 
					   + ISNULL(SUM(Hr11), '') + ISNULL(SUM(Hr12), '') + ISNULL(SUM(Hr13), '') + ISNULL(SUM(Hr14), '') + ISNULL(SUM(Hr15), '') 
					   + ISNULL(SUM(Hr16), '') + ISNULL(SUM(Hr17), '') + ISNULL(SUM(Hr18), '') + ISNULL(SUM(Hr19), '') + ISNULL(SUM(Hr20), '')
					   + ISNULL(SUM(Hr21), '') + ISNULL(SUM(Hr22), '') + ISNULL(SUM(Hr23), '') + ISNULL(SUM(Hr24), '') + ISNULL(SUM(Hr25), '') AS total 
					   INTO #temp_table
				FROM   mv90_data_hour mdh
					   INNER JOIN mv90_data md
							ON  md.meter_data_id = mdh.meter_data_id
							AND mdh.prod_date BETWEEN md.from_date AND md.to_date
					   INNER JOIN meter_id mi
							ON  mi.meter_id = md.meter_id
				WHERE mi.meter_id = @meter_id
				GROUP BY md.meter_data_id

				--SELECT * FROM   #temp_table
				EXEC spa_print 'Updating total'
				UPDATE mv90_data
				SET volume = tmp.total
				FROM mv90_data md
				INNER JOIN #temp_table tmp ON md.meter_data_id = tmp.meter_data_id	
				END
				ELSE
				BEGIN
					DELETE 				
					FROM mv90_data WHERE meter_id = @meter_id 
						AND from_date >= @term_start 
						AND to_date <= @term_end
				END
			END
			COMMIT		
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK
			INSERT INTO source_system_data_import_status
			(
				process_id,
				code, 
				module, 
				[source], 
				[type], 
				[description], 
				recommendation
			) 		
			VALUES
			(
				@batch_process_id, 
				'Error', 
				'Remove Data', 
				'MV90_data/Mv90_data_hour/Mv90_data_mins', 
				'Error', 
				'Meter Data cannot be deleted. ERROR: ' + ERROR_MESSAGE(), 
				'Please check the data.'	
			)				
			
			SET @error = 'ERROR'
		END CATCH
	END
END	
/*
 EXEC spa_delete_import_loadforcast_price 'p', '2011-10-25', '2011-10-25', '2011-10-25', NULL, 13, '23', 1, 1
*/
ELSE IF @flag = 'p' --Price Curve data remove
BEGIN	
	BEGIN TRY	
		DECLARE @arch_table AS VARCHAR(500)
		DECLARE @needed_hr_curve_id AS VARCHAR(MAX)
		DECLARE @not_needed_hr_curve_id AS VARCHAR(MAX)
		
		SET @needed_hr_curve_id = NULL
		SET @not_needed_hr_curve_id = NULL
		SET @arch_table = dbo.FNAGetProcessTableName(@as_of_date, 'source_price_curve')
		
		IF @arch_table = 'source_price_curve' 
		BEGIN				
			SELECT  @needed_hr_curve_id = COALESCE(@needed_hr_curve_id + ',', '') +  CAST (spc.source_curve_def_id AS VARCHAR(12))
			FROM source_price_curve spc 
				INNER JOIN source_price_curve_def spcd ON spc.source_curve_def_id = spcd.source_curve_def_id
				INNER JOIN dbo.SplitCommaSeperatedValues(@index) i ON i.Item = spc.source_curve_def_id 
			WHERE spcd.Granularity IN (982,989,987) 
			GROUP BY spc.source_curve_def_id
							
			SELECT  @not_needed_hr_curve_id = COALESCE(@not_needed_hr_curve_id + ',', '') +  CAST (spc.source_curve_def_id AS VARCHAR(12))
			FROM source_price_curve spc 
				INNER JOIN source_price_curve_def spcd ON spc.source_curve_def_id = spcd.source_curve_def_id
				INNER JOIN dbo.SplitCommaSeperatedValues(@index) i ON i.Item = spc.source_curve_def_id 
			WHERE spcd.Granularity NOT IN (982,989,987) 
			GROUP BY spc.source_curve_def_id
			
			
			IF @needed_hr_curve_id IS NOT NULL  
			BEGIN                                
				SET @sql = 'DELETE FROM source_price_curve' + 
							' WHERE as_of_date = ''' + CONVERT(VARCHAR(20), @as_of_date, 120) + ''' 
							AND maturity_date >= ''' + CONVERT(VARCHAR(20), @term_start, 120) + ''' 
							AND maturity_date < ''' + CONVERT(VARCHAR(20), DATEADD(DAY, 1, @term_end), 120) + ''' 
							AND source_curve_def_id IN (' + @needed_hr_curve_id + ')'
				 
				SET @sql = @sql	+ CASE WHEN @hr_from IS NULL THEN '' ELSE ' AND DATEPART(HOUR, maturity_date) >= ''' + CAST((@hr_from - 1) AS VARCHAR(2)) + '''' END
								+ CASE WHEN @hr_to IS NULL THEN '' ELSE ' AND DATEPART(HOUR, maturity_date) <= ''' + CAST((@hr_to - 1) AS VARCHAR(2)) + '''' END			
			    
				EXEC (@sql)	    
				EXEC spa_print @sql
			END
			IF @not_needed_hr_curve_id IS NOT NULL  
			BEGIN     
				SET @sql = 'DELETE FROM source_price_curve' + 
							' WHERE as_of_date = ''' + CONVERT(VARCHAR(20), @as_of_date, 120) + ''' 
							AND maturity_date >= ''' + CONVERT(VARCHAR(20), @term_start, 120) + ''' 
							AND maturity_date < ''' + CONVERT(VARCHAR(20), DATEADD(DAY, 1, @term_end), 120) + ''' 
							AND source_curve_def_id IN (' + @not_needed_hr_curve_id + ')'
				 
				EXEC (@sql)	    
				EXEC spa_print @sql
			END		
		END
		ELSE
		BEGIN
			INSERT INTO source_system_data_import_status
			(
				process_id,
				code, 
				module, 
				[source], 
				[type], 
				[description], 
				recommendation
			) 
			SELECT 
				@batch_process_id, 
				'Error', 
				'Remove Data', 
				'Source_price_curve', 
				'Error', 
				'Price: ' + spcd.curve_name + 
				' for as of Date: ' + CONVERT(VARCHAR(10), @as_of_date, 121) +
				' has already been archived thus cannot be deleted.', 
				'Please archive the price to main table.'
			FROM source_price_curve_def spcd 
			INNER JOIN dbo.SplitCommaSeperatedValues(@index) i ON i.Item = spcd.source_curve_def_id 
			
			EXEC spa_print 'archived'
			SET @error = 'DATA_ARCHIVED'
		END
	END TRY
	BEGIN CATCH
		INSERT INTO source_system_data_import_status
		(
			process_id,
			code, 
			module, 
			[source], 
			[type], 
			[description], 
			recommendation
		) 
		VALUES 
		(
			@batch_process_id, 
			'Error', 
			'Remove Data', 
			'Source_price_curve', 
			'Error', 
			'Price Curve cannot be deleted. ERROR: ' + ERROR_MESSAGE(), 
			'Please check the data.'
		)
		EXEC spa_print 'error'
		SET @error = 'ERROR'		
	END CATCH
END
/*
EXEC spa_delete_import_loadforcast_price 'l', '2011-10-25', '2011-1-1', '2011-1-5', 3, 13, NULL, 1,1
*/
ELSE IF @flag = 'l' --Load Forcast Data Remove
BEGIN
	BEGIN TRY	
		IF @hr_from IS NULL OR (@hr_from = 1 AND @hr_to = 24)  --whole row delete
		BEGIN		
			EXEC spa_print 'Start load forcast delete'
			SET @list_str = 'DELETE FROM deal_detail_hour' + 
								' WHERE term_date BETWEEN ''' + CONVERT(VARCHAR(20), @term_start, 120) + ''' 
								AND ''' + CONVERT(VARCHAR(20), @term_end, 120) + ''' 
								AND profile_id = ' + CAST(@profile_id AS VARCHAR(10))	
			
			EXEC spa_print @list_str	
			EXEC (@list_str)
			SET @sql = ''
			--SELECT @sql = @sql + (CASE WHEN @sql = '' THEN '' ELSE ' UNION ALL ' END) + 
			--				  'SELECT 1 FROM  ' + ISNULL(dbase_name + '.dbo.', '') + tbl_name + ISNULL(prefix_location_table, '')
			--				  + ' WHERE profile_id = ' + CAST(@profile_id AS VARCHAR(10)) 
			--				 FROM process_table_archive_policy ptap
			--				  WHERE ptap.tbl_name = 'deal_detail_hour'
			--				  GROUP BY ptap.prefix_location_table, ptap.dbase_name, ptap.tbl_name
			--				  ORDER BY ptap.tbl_name, ptap.prefix_location_table
			SELECT @sql = @sql + (CASE WHEN @sql = '' THEN '' ELSE ' UNION ALL ' END) + 
							  'SELECT 1 FROM  ' + ISNULL(adpd.archive_db + '.dbo.', '') + adpd.table_name --+ ISNULL(prefix_location_table, '')
							  + ' WHERE profile_id = ' + CAST(@profile_id AS VARCHAR(10)) 
			FROM archive_data_policy_detail adpd 
			INNER JOIN archive_data_policy adp ON  adpd.archive_data_policy_id = adp.archive_data_policy_id
				AND  adp.main_table_name  = 'deal_detail_hour'
			GROUP BY adpd.table_name, adpd.archive_db, adp.main_table_name, adpd.sequence
			ORDER BY adpd.sequence
							 
							 --process_table_archive_policy ptap
							 -- WHERE ptap.tbl_name = 'deal_detail_hour'
							 -- GROUP BY ptap.prefix_location_table, ptap.dbase_name, ptap.tbl_name
							 -- ORDER BY ptap.tbl_name, ptap.prefix_location_table
			EXEC spa_print @sql
			CREATE TABLE #temp (data_name VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
			INSERT INTO #temp(data_name)
			EXEC(@sql)
			IF NOT EXISTS(SELECT TOP 1 data_name FROM #temp) 
			BEGIN
				EXEC spa_print 'Update forecast_profile to null'
				UPDATE forecast_profile SET available = NULL WHERE profile_id = @profile_id
			END
			
		END
		ELSE  --Delete Specific Hour Data Only
		BEGIN	
			DECLARE @column VARCHAR(MAX)
			DECLARE @hr_from_copy TINYINT
			SET @column = ''
			SET @hr_from_copy = @hr_from
			
			WHILE (@hr_from_copy <= @hr_to)
			BEGIN
				SET @column = @column + ' Hr' + CAST(@hr_from_copy AS VARCHAR(2)) + ' = NULL,' 				
				SET @hr_from_copy = @hr_from_copy + 1 				
			END
			
			SET @column = LEFT(@column, LEN(@column) - 1)
			
			SET @list_str = 'UPDATE deal_detail_hour SET ' + @column +
							' WHERE term_date BETWEEN ''' + CONVERT(VARCHAR(20), @term_start, 120) + ''' 
							AND ''' + CONVERT(VARCHAR(20), @term_end, 120) + '''	
							AND profile_id = ' + CAST(@profile_id AS VARCHAR(10))				
			
			EXEC (@list_str)			
			EXEC spa_print @hr_from 
			EXEC spa_print  @hr_to
			IF (3 BETWEEN @hr_from AND @hr_to) -- Deleting DST Hour Data 
			BEGIN				
				EXEC spa_print '25'
				SET @list_str = 'UPDATE deal_detail_hour SET Hr25 = NULL 
								WHERE (Hr25 IS NOT NULL) AND term_date >= ''' + CONVERT(VARCHAR(20), @term_start, 120) + 
								''' AND term_date <= ''' + CONVERT(VARCHAR(20), @term_end, 120) + 
								''' AND profile_id = ' + CAST(@profile_id AS VARCHAR(10))				
			
			END				
			EXEC spa_print @list_str		
			EXEC (@list_str)							
		END
		-----------------check if archive table contains data for given range of term date----------------------
		IF EXISTS
		(
				SELECT 1 
				FROM process_table_location ptl 
				WHERE ptl.tbl_name = 'deal_detail_hour' 					
				AND (ptl.prefix_location_table IS NOT NULL AND  ptl.prefix_location_table <> '')
				AND ptl.as_of_date BETWEEN @term_start AND @term_end
		)
		BEGIN					
			BEGIN TRY					
				DECLARE @current_as_of_date DATETIME
				DECLARE @current_arch_table VARCHAR(200)
				DECLARE @prev_as_of_date DATETIME
				DECLARE @prev_arch_table VARCHAR(200)
				DECLARE @status BIT
				DECLARE @rank AS TINYINT				    
			    
				SET @rank = 1
				--SET @term_start = '2011-1-1'
				--SET @term_end = '2015-12-12'
				
				IF OBJECT_ID('tempdb..#tmp_date_range') IS NOT NULL
				DROP TABLE #tmp_date_range
				
				CREATE TABLE #tmp_date_range(tbl_name VARCHAR(300) COLLATE DATABASE_DEFAULT, as_of_date DATETIME, [rank] TINYINT, [status] BIT)
				
				DECLARE cur_status CURSOR LOCAL FOR		
				SELECT 
					CASE WHEN ISNULL(main_arch.prefix_location_table, '') = '' THEN 'deal_detail_hour' ELSE 'deal_detail_hour_arch' END arch_table,  
					main_arch.as_of_date, 
					CASE WHEN ISNULL(main_arch.prefix_location_table, '') = '' THEN 1 ELSE 0 END [status]
				FROM
				(
					SELECT as_of_date, prefix_location_table FROM process_table_location 
					WHERE tbl_name = 'deal_detail_hour' 
					AND as_of_date BETWEEN @term_start AND @term_end
					UNION ALL
					SELECT DISTINCT term_date AS [as_of_date], '' AS [prefix_location_table] 
					FROM deal_detail_hour 
					WHERE term_date BETWEEN @term_start AND @term_end
				) AS main_arch
				ORDER BY main_arch.as_of_date
				
				OPEN cur_status;
				FETCH NEXT FROM cur_status INTO @current_arch_table, @current_as_of_date, @status
				WHILE @@FETCH_STATUS = 0	
				BEGIN
					
					IF (@current_arch_table <> @prev_arch_table AND @prev_arch_table IS NOT NULL) 
					BEGIN
						SET @rank = @rank + 1
					END
					
					SET @prev_arch_table =  @current_arch_table
					SET @prev_as_of_date = @current_as_of_date
					
					INSERT INTO #tmp_date_range VALUES (@prev_arch_table, @prev_as_of_date, @rank, @status)
					
					FETCH NEXT FROM cur_status INTO @current_arch_table, @current_as_of_date, @status
				END;
				
				CLOSE cur_status;
				DEALLOCATE cur_status;	
			END TRY
			BEGIN CATCH
				IF CURSOR_STATUS('local', 'cur_status') >= 0 
				BEGIN
					CLOSE cur_status
					DEALLOCATE cur_status;
				END
				EXEC spa_print 'Error in Cursor'
			END CATCH
			
			IF EXISTS(SELECT 1 FROM #tmp_date_range) 
			BEGIN					
				INSERT INTO source_system_data_import_status
				(
					process_id,
					code, 
					module, 
					[source], 
					[type], 
					[description], 
					recommendation
				) 		
				SELECT 
					@batch_process_id, 
					CASE WHEN [status] = 1 THEN 'success' ELSE 'Error' END, 
					'Remove Data', 
					'Deal_Detail_Hour', 
					 CASE WHEN [status] = 1 THEN 'success' ELSE 'Error' END, 
					'Profile ''' + (SELECT fp.profile_name FROM forecast_profile fp WHERE fp.profile_id = @profile_id)
					+ ''' for Forecast Term: ' + CONVERT(VARCHAR(10), MIN(as_of_date), 121)  + ' to ' + CONVERT(VARCHAR(10), MAX(as_of_date), 121) +
					+ CASE WHEN [status] = 1 THEN ' has been removed.' ELSE ' has already been archived hence cannot be deleted.' END,
					+ CASE WHEN [status] = 1 THEN 'Please check data.' ELSE 'Please transfer the forecast data from archived table to main table.' END 
							
				FROM  #tmp_date_range arch 
				GROUP BY [rank], tbl_name, [status]
				ORDER BY  MIN(as_of_date)
				
				SELECT * FROM #tmp_date_range
				
				EXEC spa_print 'data archived'
				SET @error = 'DATA_ARCHIVED'
			END				
		END	
		--------------------checking in archive table ends here-------------------------------------------------
	END TRY
	BEGIN CATCH
		INSERT INTO source_system_data_import_status
		(
			process_id,
			code, 
			module, 
			[source], 
			[type], 
			[description], 
			recommendation
		) 		
		VALUES
		( 
			@batch_process_id, 
			'Error', 
			'Remove Data', 
			'Deal_Detail_Hour', 
			'Error', 
			'Load Forecast Data cannot be deleted. ERROR: ' + ERROR_MESSAGE(), 
			'Please check the data.'			
		)
		EXEC spa_print 'ERROR can not delete'
		SET @error = 'ERROR'		
	END CATCH	
END	
	
IF @is_batch = 1
BEGIN
	DECLARE @user_name VARCHAR(100)
	DECLARE @today VARCHAR(MAX)
	DECLARE @e_time INT
	DECLARE @e_time_text VARCHAR(100)
	
	SET @today = GETDATE()
	SET @e_time = DATEDIFF(ss, @today, @begin_time)

	SET @e_time_text = CAST(CAST(@e_time/60 AS INT) AS VARCHAR) + ' Mins ' + CAST(@e_time - CAST(@e_time/60 AS INT) * 60 AS VARCHAR) + ' Secs'
	
	SET @user_name = dbo.FNADBUser()
	
	IF ISNULL(@error, '') = ''
	BEGIN
		IF @desc IS NULL
		BEGIN
			SET @desc = 
					'Remove Data process completed for ' 
					+ CASE 
						WHEN @flag = 'm' THEN 'Meter Data for Term: ' 
						WHEN @flag = 'p' THEN 'Price Curve for as of Date: ' + CONVERT(VARCHAR(10), @as_of_date, 121) + ', Term: '  
						ELSE 'Load Forcast Data for Term:' 
					  END 	
					+ CONVERT(VARCHAR(10), @term_start, 121) 				
					+ ' to '
					+ CONVERT(VARCHAR(10), @term_end, 121) 				
					+ CASE WHEN CAST(@hr_from AS VARCHAR(10)) IS NULL THEN '' ELSE ' and Hr' + CAST(@hr_from AS VARCHAR(10)) + ' - ' + 'Hr' + CAST(@hr_to AS VARCHAR(10))  END				
					+ '. [Elapse Time ' + @e_time_text + ']'
		END

	END	
	ELSE 
	BEGIN
		DECLARE @elapsed_sec FLOAT
		DECLARE @url VARCHAR(MAX)

		SET @elapsed_sec = DATEDIFF(SECOND, @begin_time, GETDATE())

		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
					'&spa=exec spa_get_import_process_status ''' + @batch_process_id + ''',''' + @user_login_id + ''''
		
	
		SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
					'Remove Data process completed for ' + 
					CASE 
						WHEN @flag = 'm' THEN 'Meter Data'
						WHEN @flag = 'p' THEN 'Price Curve'
						WHEN @flag = 'l' THEN 'Load Forecast Data'
					END						
					+ ' (ERRORS found). [Elapsed time:' + 
					CAST(@elapsed_sec AS VARCHAR(100)) + ' sec]</a>'
		
	END
	
	DECLARE @job_name VARCHAR(200)
	SET @job_name = 'report_batch_' + @batch_process_id
	SET @error = CASE WHEN @error = '' THEN 's' ELSE 'e' END
	
	EXEC spa_message_board 'u', @user_name, NULL, 'Remove data', @desc, '', '' ,@error, @job_name, NULL, @batch_process_id, @today, 'n', '', 'y'
END
