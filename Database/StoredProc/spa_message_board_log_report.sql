

/************************************************************
 * Code formatted by SoftTree SQL Assistant ¬ v6.3.153
 * Time: 6/13/2014 1:16:54 AM
 ************************************************************/

IF OBJECT_ID(N'[dbo].[spa_message_board_log_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_message_board_log_report]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: bbishural@pioneersolutionsglobal.com
-- Create date: 2014-05-26
-- Description: Selection of the data from table message_board_log_report
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @user varchar(100) - Application users
-- @as_of_date_from - As of date from
-- @as_of_date_to  - As of date to
-- @source - source name
-- @type - type

-- EXEC spa_message_board_log_report 's', 'farrms_admin', '2014-04-26', '2014-05-30', 'Batch Report', 's'
-- SELECT * FROM message_board_audit
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_message_board_log_report]
	@flag CHAR(1),
	@user VARCHAR(200) = NULL,
	@as_of_date_from DATETIME = NULL,
	@as_of_date_to DATETIME = NULL,
	@source VARCHAR(200) = NULL,
	@type CHAR(1) = NULL,
	@detail CHAR(1) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL,
	@enable_paging INT = 0,
	@page_size INT = NULL,
	@page_no INT = NULL

AS
	SET NOCOUNT ON
	DECLARE @sql VARCHAR(MAX)
	DECLARE @str_batch_table VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @sql_paging VARCHAR(8000)
	DECLARE @is_batch bit
	
	SET @str_batch_table = ''
	SET @user_login_id = dbo.FNADBUser() 

	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

	IF @is_batch = 1
		SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	
	CREATE TABLE #temp_table_report (username VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,	[source] VARCHAR(MAX) COLLATE DATABASE_DEFAULT , [description] VARCHAR(MAX) COLLATE DATABASE_DEFAULT , [type] VARCHAR(MAX) COLLATE DATABASE_DEFAULT , [create_ts] VARCHAR(MAX) COLLATE DATABASE_DEFAULT )

	IF @enable_paging = 1 --paging processing
	BEGIN
	    IF @batch_process_id IS NULL
	        SET @batch_process_id = dbo.FNAGetNewID()
	    
	    SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
	    
	    --retrieve data from paging table instead of main table
	    IF @page_no IS NOT NULL
	    BEGIN
	        SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
	        EXEC (@sql_paging) 
	        RETURN
	    END
	END


	DECLARE @pre_report_table VARCHAR(5000) = dbo.FNAProcessTableName('pre_report', dbo.FNADBUser() , dbo.FNAGetNewID())

	IF @flag = 's'
	BEGIN
	    IF @detail = 'y'
	    BEGIN
	        IF @source = 'Settlement Reconciliation ' --when the data source is settlement reconciliation
			BEGIN
	        	SET @sql = 
					' SELECT psil.code AS Code,
							 psil.module AS Module,
							 psil.[description] AS [Description],
							 psil.nextsteps AS [Next Steps],
							 dbo.FNADateTimeFormat(psil.[create_ts], 1) AS [Time],
							 psil.process_id [Process ID],
							 psil.create_user as [User]
						   
					INTO ' + @pre_report_table +  '
					FROM  process_settlement_invoice_log psil WHERE 1 = 1 '
	        
					IF @as_of_date_from IS NOT NULL
					BEGIN
						SET @sql = @sql + ' AND (CONVERT(VARCHAR(10), psil.create_ts, 120) >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120) + ''')'
					END 
	        
					IF @as_of_date_to IS NOT NULL
					BEGIN
						SET @sql = @sql + ' AND (CONVERT(VARCHAR(10), psil.create_ts, 120) <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + ''')'
					END
					IF @user IS NOT NULL
						SET @sql = @sql + ' AND psil.create_user = ''' + @user + ''''
	            
					IF @type IS NOT NULL
					BEGIN
						SET @sql = @sql  + ' AND psil.code = CASE WHEN ''' + @type + '''= ''e'' THEN  ''Error''
																  WHEN ''' + @type + ''' = ''s'' THEN ''Success''
																  WHEN ''' + @type + ''' = ''w'' THEN  ''Warning''
															 END '
					END
					
					IF @source IS NOT NULL
						SET @sql = @sql + ' AND psil.module = ''' + @source + ''''
						
					SET @sql = @sql + ' ORDER BY psil.create_user,  psil.create_ts desc'
	        
				--PRINT (@sql)
				EXEC (@sql)
			END
			
			IF @source = 'Deal Settlement' -- when the data source is deal settlement --table mtm_test_run_log
			BEGIN
				SET @sql = 
					' SELECT mtrl.code AS Code,
							mtrl.module AS Module,
							mtrl.source AS Source,
							mtrl.type AS Type,  
							mtrl.[description] AS [Description],
							mtrl.nextsteps AS [Next Steps],
							mtrl.process_id AS [Process ID],
							mtrl.create_user AS [User],
							dbo.FNADateTimeFormat(mtrl.[create_ts], 1) AS [Time]
						   
					INTO ' + @pre_report_table +  '
					FROM  mtm_test_run_log mtrl WHERE 1=1 '
					
					IF @user IS NOT NULL
						SET @sql = @sql + ' AND mtrl.create_user = ''' + @user + ''''
						
					IF @source IS NOT NULL
						SET @sql = @sql + ' AND mtrl.source = ''Deal Settlement Calc'''
					
					IF @as_of_date_from IS NOT NULL
					BEGIN
						SET @sql = @sql + ' AND (CONVERT(VARCHAR(10), mtrl.create_ts, 120) >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120) + ''''
						SET @sql = @sql + ' OR CONVERT(VARCHAR(10), mtrl.update_ts, 120)  >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120) + ''')'
					END 
	        
					IF @as_of_date_to IS NOT NULL
					BEGIN
						SET @sql = @sql + ' AND (CONVERT(VARCHAR(10), mtrl.create_ts, 120) <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + ''''
						SET @sql = @sql + ' OR CONVERT(VARCHAR(10), mtrl.update_ts, 120) <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + ''')'
					END
					
					IF @type IS NOT NULL
					BEGIN
						SET @sql = @sql  + ' AND mtrl.code = CASE WHEN ''' + @type + '''= ''e'' THEN  ''Error''
																  WHEN ''' + @type + ''' = ''s'' THEN ''Success''
																  WHEN ''' + @type + ''' = ''w'' THEN  ''Warning''
															 END '
					END
	        
					SET @sql = @sql + ' ORDER BY mtrl.create_user,  mtrl.create_ts desc'
					
				--PRINT (@sql)
				EXEC (@sql)
			END	
			
			IF (@source = 'ImportData' OR @source = 'Import Data') -- when the data source is import data table name : source_system_data_import_status
			BEGIN
				SET @sql = 
					' SELECT ssd.code            AS [Code],
							 ssd.module          AS [Import From],
							 ssd.source          AS [Source],
							 ssd.[type]          AS [Type],
							 ssd.[description]   AS [Description],
							 ssd.recommendation  AS [Recommendation],
							 ssd.create_user	 AS [User],
							 dbo.FNADateTimeFormat(ssd.[create_ts], 1) AS [Time]
							    
					INTO ' + @pre_report_table +  '			    
					FROM source_system_data_import_status ssd WHERE 1 = 1 '
					
					IF @user IS NOT NULL
						SET @sql = @sql + ' AND ssd.create_user = ''' + @user + ''''
						
					IF @source IS NOT NULL
						SET @sql = @sql + ' AND ssd.module = ''Import Data'''
					
					IF @as_of_date_from IS NOT NULL
					BEGIN
						SET @sql = @sql + ' AND (CONVERT(VARCHAR(10), ssd.create_ts, 120) >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120) + ''''
						SET @sql = @sql + ' OR CONVERT(VARCHAR(10), ssd.update_ts, 120)  >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120) + ''')'
					END 
	        
					IF @as_of_date_to IS NOT NULL
					BEGIN
						SET @sql = @sql + ' AND (CONVERT(VARCHAR(10), ssd.create_ts, 120) <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + ''''
						SET @sql = @sql + ' OR CONVERT(VARCHAR(10), ssd.update_ts, 120) <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + ''')'
					END
					
					IF @type IS NOT NULL
					BEGIN
						SET @sql = @sql  + ' AND ssd.code = CASE WHEN ''' + @type + '''= ''e'' THEN  ''Error''
																 WHEN ''' + @type + ''' = ''s'' THEN ''Success''
																 WHEN ''' + @type + ''' = ''w'' THEN  ''Warning''
															END '
					END
	        
					SET @sql = @sql + ' ORDER BY ssd.create_user,  ssd.create_ts desc'
					
					--PRINT (@sql)
					EXEC (@sql)
			END
			
			IF (@source = 'Email Invoices' OR @source = 'Send Invoices')  --when the data source is Email Invoices
			BEGIN
	        	SET @sql = 
					' SELECT psil.code AS Code,
							 psil.module AS Module,
							 psil.[description] AS [Description],
							 psil.nextsteps AS [Next Steps],
							 dbo.FNADateTimeFormat(psil.create_ts, 1) [Time],
							 psil.process_id AS [Process ID],
							 psil.create_user as [User]
						   
					INTO ' + @pre_report_table +  '
					FROM  process_settlement_invoice_log psil WHERE 1 = 1 '
	        
					IF @as_of_date_from IS NOT NULL
					BEGIN
						SET @sql = @sql + ' AND (CONVERT(VARCHAR(10), psil.create_ts, 120) >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120) + ''')'
					END 
	        
					IF @as_of_date_to IS NOT NULL
					BEGIN
						SET @sql = @sql + ' AND (CONVERT(VARCHAR(10), psil.create_ts, 120) <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + ''')'
					END
					IF @user IS NOT NULL
						SET @sql = @sql + ' AND psil.create_user = ''' + @user + ''''
	            
					IF @type IS NOT NULL
					BEGIN
						SET @sql = @sql  + ' AND psil.code = CASE WHEN ''' + @type + '''= ''e'' THEN  ''Error''
																  WHEN ''' + @type + ''' = ''s'' THEN ''Success''
																  WHEN ''' + @type + ''' = ''w'' THEN  ''Warning''
															 END '
					END
					
					IF @source IS NOT NULL
						SET @sql = @sql + ' AND psil.module = ''Send Invoices'''
						
					SET @sql = @sql + ' ORDER BY psil.create_user,  psil.create_ts desc'
	        
				--PRINT (@sql)
				EXEC (@sql)
			END
	    END 
	    ELSE
	    BEGIN
	        SET @sql = 
	            'SELECT (au.user_f_name + '' '' + isnull(au.user_m_name, '''')  +  '' '' + au.user_l_name + '' ('' + au.user_login_id + '')'') [User Name],
							mba.source [Source],
							mba.[description] [Description], 
							CASE mba.[type] WHEN ''s'' then ''Success''
											WHEN ''w'' then ''Warning''
											WHEN ''c'' then ''Success''
											ELSE ''Error'' 
							END [Type],
							dbo.FNAUserDateFormat(mba.create_ts, dbo.FNADBUser()) [Create TS]
			    
				INTO ' + @pre_report_table + 
	            '
				FROM   message_board_audit mba
				LEFT JOIN application_users au ON au.user_login_id = mba.user_login_id
				WHERE 1=1 '
	        
				IF @user IS NOT NULL
					SET @sql = @sql + ' AND mba.user_login_id = ''' + @user + ''''
	        
				IF @type IS NOT NULL
					SET @sql = @sql + ' AND ISNULL(NULLIF(mba.type, ''c''), ''s'') = ''' + @type +''''
	        
				IF @source IS NOT NULL
					SET @sql = @sql + ' AND REPLACE(REPLACE(mba.source, ''Import Data'', ''ImportData''), ''Email Invoices'', ''Send Invoices'') = ''' + @source + ''''
	        
				IF @as_of_date_from IS NOT NULL
				BEGIN
					SET @sql = @sql + ' AND (CONVERT(VARCHAR(10), mba.create_ts, 120) >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120) + ''''
					SET @sql = @sql + ' OR CONVERT(VARCHAR(10), mba.update_ts, 120)  >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120) + ''')'
				END 
	        
				IF @as_of_date_to IS NOT NULL
				BEGIN
					SET @sql = @sql + ' AND (CONVERT(VARCHAR(10), mba.create_ts, 120) <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + ''''
					SET @sql = @sql + ' OR CONVERT(VARCHAR(10), mba.update_ts, 120) <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + ''')'
				END
	        
				SET @sql = @sql + ' AND mba.user_action NOT IN (''delete'') ORDER BY message_board_audit_id DESC, [User Name],  mba.create_ts desc' 
	        
	       -- exec spa_print @sql
	        EXEC (@sql)

			
	    END

		SET @sql = 'SELECT  ' + CASE WHEN @detail = 'y' THEN ' * ' ELSE '
						[User Name],	
								[Source],	
								REPLACE([Description], ''./dev/spa_html.php'', ''spa_html.php'') Description,	
								[Type],	
						[Create TS] ' END 
						+ @str_batch_table + 
						 ' FROM ' + @pre_report_table
			--print (@sql)
			 EXEC (@sql)
	    
	    /*******************************************2nd Paging Batch START**********************************************/
IF @is_batch = 1
		BEGIN
			SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
			EXEC(@str_batch_table)                   

			SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_message_board_log_report', 'Message Board Log Report')         
			EXEC(@str_batch_table)        
			RETURN
		END


	    --if it is first call from paging, return total no. of rows and process id instead of actual data
	    IF @enable_paging = 1
	       AND @page_no IS NULL
	    BEGIN
	        SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	        EXEC (@sql_paging)
	    END/*******************************************2nd Paging Batch END**********************************************/
	END
