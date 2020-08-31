IF EXISTS ( SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_send_confirmation]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_send_confirmation]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************
 * Author: Biju Maharjan
 * Descriptions: Send deal confirmation
 * Param :
 * @flag CHAR(1) - 's' for grid, 'f' for changing status to send, 'e' for sending confirmation, 'x' for changing status from update button	
  *******************************************/

CREATE PROC [dbo].[spa_send_confirmation]        
			@flag					CHAR(1),
			@deal_id_from			VARCHAR(100) = NULL,         
			@deal_id_to				VARCHAR(100) = NULL,         
			@deal_date_from			VARCHAR(10) = NULL,         
			@deal_date_to			VARCHAR(10) = NULL,        
			@counterparty_id		VARCHAR(MAX)=NULL, 
			@deal_category_value_id INT=NULL,        
			@source_deal_type_id	INT=NULL,        
			@deal_sub_type_type_id	INT=NULL,        
			@trader_id				INT=NULL,  
			@confirmation_status	VARCHAR(20) = NULL ,
			@source_deal_header_id	VARCHAR(MAX) = NULL,
			@reporting_param		VARCHAR(MAX) = NULL,
			@report_file_path		VARCHAR(5000) = NULL,
			@report_name			VARCHAR(MAX) = NULL,
			@notify_users			VARCHAR(MAX) = NULL,
			@notify_roles			VARCHAR(MAX) = NULL,
			@export_csv_path		VARCHAR(5000) = NULL,
			@non_system_users		VARCHAR(MAX) = NULL,
			@send_option			CHAR(1) = NULL,
			@delivery_method		INT = NULL,
			@holiday_calendar_id	INT = NULL,
			@freq_type				INT = NULL,
			@active_start_date		DATETIME = NULL,
			@active_start_time		VARCHAR(100) = NULL,
			@freq_interval			INT = NULL,
			@active_end_date		DATETIME = NULL,
			@freq_subday_type		INT = NULL,
			@freq_recurrence_factor INT = NULL,	
			@printer_name			VARCHAR(200) = NULL,
			@report_folder			VARCHAR(500) = NULL,
			@process_table_name		VARCHAR(200) = NULL,
			@batch_process_id		VARCHAR(50) = NULL,
			@batch_report_param		VARCHAR(1000) = NULL      
        
AS         
      
DECLARE	@sql_Select					VARCHAR(MAX),  
		@sql						VARCHAR(MAX),
		@print_confirmation_id      INT,
        @email_confirmation_id      INT,  
        @deal_counterparty_id		INT, 
        @deal_counterparty_name		VARCHAR(MAX),      
		@baseload_block_define_id	VARCHAR(100),
		@process_id					VARCHAR(200),
		@user_login_id              VARCHAR(100),
		@notification_type          INT,
		@email_address              VARCHAR(MAX),
		@email_description          VARCHAR(MAX),
		@user_date_time             DATETIME,
        @user_date                  DATETIME,
        @user_end_date_time         DATETIME,
        @active_end_time            INT,
		@filter                     VARCHAR(MAX),
		@parameter                  VARCHAR(MAX),
		@report_file                VARCHAR(MAX),
		@job_name                   VARCHAR(200),
		@unique_process_id          VARCHAR(50)
SET @user_login_id = dbo.FNADBUser()   
SET @process_id = dbo.FNAGetNewID() 
--TODO: Change Static data values
IF @delivery_method IS NULL
	SET @delivery_method = 21301

IF @delivery_method IS NOT NULL
BEGIN
	SET @notification_type = CASE @delivery_method
	                              WHEN 21301 THEN 750
                                  WHEN 21303 THEN 750
                                  WHEN 21304 THEN 751
                                  WHEN 21302 THEN 751
                                  WHEN 21305 THEN 751
                                  ELSE 751
	                         END
END

SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data
    
IF @flag = 's'        
BEGIN        
	SET @sql_Select =         
	   'SELECT DISTINCT dbo.FNAHyperLinkText(10131010, dh.source_deal_header_id, dh.source_deal_header_id) AS [Deal ID],        
			   CASE WHEN MAX(deal_status.Code) IS NULL THEN ''New'' ELSE MAX(deal_status.Code) END [Deal Status],        
			   MAX(sdv2.code) [Confirm Status],        
			   MAX(dbo.FNADateFormat(dh.deal_date)) AS [Deal Date],        
			   MAX(source_deal_type.source_deal_type_name) As [Deal Type], 
			   MAX(source_deal_type_1.source_deal_type_name) AS [Deal Sub Type],  
			   MAX(source_counterparty.counterparty_name) [Counterparty],        
			   MAX(sml.Location_Name) [Delivery Location],        
			   MAX(source_traders.trader_name) AS [Trader Name],        
			   MAX(sdv.code) AS [Deal Category],        
			   MAX(cg.contract_name) [Contract],
			   dh.source_deal_header_id       
	   FROM source_deal_header dh         
	   INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = dh.source_deal_header_id         
	   INNER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id         
	   INNER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id         
	   INNER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id         
	   LEFT join source_currency   ON sdd.fixed_price_currency_id=source_currency.source_currency_id        
	   LEFT join deal_confirmation_rule dcr ON dcr.counterparty_id = dh.counterparty_id        
		 AND isnull(dcr.buy_sell_flag,dh.header_buy_sell_flag) = dh.header_buy_sell_flag        
		 AND ISNULL(dcr.commodity_id, 0) = (CASE WHEN dcr.commodity_id IS NULL THEN 0 ELSE ISNULL(dh.commodity_id, 0) END)        
		 AND ISNULL(dcr.contract_id, 0) = (CASE WHEN dcr.contract_id IS NULL THEN 0 ELSE ISNULL(dh.contract_id, 0) END)        
		 AND ISNULL(dcr.deal_type_id, 0) = (CASE WHEN dcr.deal_type_id IS NULL THEN 0 ELSE ISNULL(dh.source_deal_type_id, 0) END)        
	   LEFT JOIN source_deal_header_template sdht on  sdht.template_id = dh.template_id        
	   LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
	   LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id         
	   LEFT OUTER JOIN (SELECT source_deal_header_id, type, as_of_date, confirm_status_id AS confirm_status_id, update_user,update_ts,is_confirm        
		 FROM         confirm_status_recent) confirm_status ON        
		dh.source_deal_header_id = confirm_status.source_deal_header_id        
	   LEFT JOIN static_data_value sdv2 ON sdv2.value_id = ISNULL(confirm_status.type, 17200)        
	   LEFT JOIN (        
		SELECT id, deal_type_id, hour, minute        
		FROM deal_lock_setup dl        
		INNER JOIN application_role_user aru ON dl.role_id = aru.role_id        
		WHERE aru.user_login_id = dbo.FNADBUser()        
	            
	   ) dls ON ((dls.deal_type_id = source_deal_type.source_deal_type_id AND ISNULL(dh.deal_locked, ''n'') <> ''y'') OR dls.deal_type_id IS NULL)        
	              
	   left outer join rec_generator rg on rg.generator_id=dh.generator_id        
	   LEFT JOIN static_data_value deal_status ON deal_status.value_id = dh.deal_status        
	   LEFT JOIN static_data_value sdv ON sdv.value_id = dh.deal_category_value_id        
	   LEFT JOIN source_uom uom ON uom.source_uom_id = sdd.deal_volume_uom_id        
	   LEFT JOIN source_uom pu ON sdd.price_uom_id = pu.source_uom_id        
	   LEFT JOIN contract_group cg ON cg.contract_id = dh.contract_id        
	   LEFT JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id        
	   LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id 
	   LEFT JOIN static_data_value block_definition ON block_definition.value_id = COALESCE(spcd.block_define_id,dh.block_define_id) AND block_definition.type_id = 10018         
	   
	   OUTER APPLY (SELECT MAX(hbt.volume_mult - CASE WHEN add_dst_hour>0 THEN 1 ELSE 0 END) volume_mult FROM hour_block_term hbt 
		WHERE hbt.block_define_id = COALESCE(spcd.block_define_id,dh.block_define_id,'+@baseload_block_define_id+') AND hbt.block_type = COALESCE(spcd.block_type,dh.block_type,12000)
		AND hbt.term_date BETWEEN sdd.term_start AND sdd.term_end ) hbt
	       
	   LEFT JOIN rec_volume_unit_conversion conv         
		  ON conv.from_source_uom_id = spcd.display_uom_id        
		  AND conv.to_source_uom_id = sdd.deal_volume_uom_id        
	   WHERE 1 = 1 '        
	
	IF @deal_id_to IS NULL
	    SET @deal_id_to = @deal_id_from        

	IF @deal_id_from is not NULL        
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from As varchar)  + ' AND ' + CAST(@deal_id_to AS varchar)         

	IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL)         
		SET @sql_Select = @sql_Select + ' AND dh.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''        
	         
	IF (@deal_id_from IS NULL) AND (@deal_id_to IS  NULL)         
	BEGIN        
		IF (@counterparty_id IS NOT NULL)        
			SET @sql_Select = @sql_Select + ' AND dh.counterparty_id IN ('+cast(@counterparty_id as varchar) + ')'       
	  
		IF (@deal_category_value_id IS NOT NULL)        
			SET @sql_Select = @sql_Select + ' AND dh.deal_category_value_id='+cast(@deal_category_value_id  as varchar)        
	         
		IF (@source_deal_type_id IS NOT NULL)        
			SET @sql_Select = @sql_Select + ' AND dh.source_deal_type_id='+cast(@source_deal_type_id  as varchar)        
	        
		IF (@deal_sub_type_type_id IS NOT NULL)        
			SET @sql_Select = @sql_Select + ' AND dh.deal_sub_type_type_id='+cast(@deal_sub_type_type_id  as varchar)        
	        
		IF (@trader_id IS NOT NULL)        
			SET @sql_Select = @sql_Select + ' AND dh.trader_id='+cast(@trader_id  as varchar)        
	END  
	
	IF (@confirmation_status IS NOT NULL)       
		SET @sql_Select = @sql_Select + ' AND sdv2.value_id = ' + cast(@confirmation_status  as varchar)        
	     
	SET @sql_Select = @sql_Select +         
		 ' Group By dh.source_deal_header_id ORDER BY  [Deal ID] '        
	       
	EXEC (@sql_Select)        
END    

IF @flag = 'f'
BEGIN	
	BEGIN TRY
		IF @process_table_name IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..#calc_id_for_sending_mail') IS NOT NULL
			    DROP TABLE #calc_id_for_sending_mail
			
			CREATE TABLE #calc_id_for_sending_mail (calc_id INT)
			EXEC ('INSERT INTO #calc_id_for_sending_mail (calc_id) SELECT calc_id FROM ' + @process_table_name)
			SELECT @source_deal_header_id = COALESCE(@source_deal_header_id + ', ' , '') + cast(calc_id AS VARCHAR(20)) FROM  #calc_id_for_sending_mail
		END
		
		--update status of deal confirmation - status updated only when its prior status is Ready To Send
		UPDATE dcs
		SET    dcs.status_id = 23901
		FROM   deal_confirmation_status dcs
		LEFT JOIN static_data_value sdv ON  sdv.value_id = dcs.status_id
		WHERE  deal_id IN (SELECT item FROM   dbo.SplitCommaSeperatedValues(@source_deal_header_id)) AND sdv.value_id = 23902
		
		EXEC spa_ErrorHandler 0
			, 'send_confirmation'
			, 'spa_send_confirmation'
			, 'Success'
			, 'Confirmation status updated.'
			, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'send_confirmation'
			, 'spa_send_confirmation'
			, 'Error'
			, 'Confirmation status update fail.'
			, ''
	END CATCH
END

IF @flag = 'g'
BEGIN
	BEGIN TRY
		IF @batch_process_id IS NOT NULL
			SET @process_id = @process_id + '_' + @batch_process_id
			
		SET @user_date_time = CAST(	CONVERT(VARCHAR(10), @active_start_date, 101) 
							 + ' ' + CAST(LEFT(@active_start_time, 2) AS VARCHAR) 
							 + ':' + CAST(SUBSTRING(@active_start_time, 3, 2) AS VARCHAR) 
							 + ':' +	CAST(RIGHT(@active_start_time, 2) AS VARCHAR) AS DATETIME)
	 
		SET @user_date = dbo.FNAConvertTimezone(@user_date_time, 1)
		SET @active_start_date = @user_date
		SET @active_start_time = RIGHT('0' + CAST(DATEPART(hh, @active_start_date) AS VARCHAR), 2)
								 + RIGHT('0' + CAST(DATEPART(mi, @active_start_date) AS VARCHAR), 2) 
								 + RIGHT('0' + CAST(DATEPART(ss, @active_start_date) AS VARCHAR), 2)
		--END Date should be till 23:59:59 time not 00:00:00. That should be converted to system timezone. 
		SET @user_end_date_time =  CAST(CONVERT(VARCHAR(10), @active_end_date, 101) + ' 23:59:59' AS DATETIME)
		SET @active_end_date = dbo.FNAConvertTimezone(@user_end_date_time, 1)
		SET @active_end_time = RIGHT('0' + CAST(DATEPART(hh, @active_end_date) AS VARCHAR), 2) 
							 + RIGHT('0' + CAST(DATEPART(mi, @active_end_date) AS VARCHAR), 2) 
							 + RIGHT('0' + CAST(DATEPART(ss, @active_end_date) AS VARCHAR), 2)
		
		DECLARE @build_sp               VARCHAR(MAX),
		        @time                   VARCHAR(8),
		        @active_start_date_int  INT,
		        @active_end_date_int    INT,
		        @diffwd                 INT,
		        @currenttime            DATETIME,
		        @currenthourminsec      INT,
		        @endofmonth             INT,
		        @new_report_name        VARCHAR(200),
		        @ReturnCode             TINYINT,	-- 0 (success) or 1 (failure)
		        @st                     VARCHAR(2000),
		        @hasadminrights         INT
		
		
		SET @build_sp = 'spa_send_confirmation ''''e'''',
						NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						' + ISNULL('''''' + @source_deal_header_id + '''''', 'NULL') + ',
						''''' + @reporting_param + ''''',
						''''' + @report_file_path + ''''',
						' + ISNULL('''''' + @report_name + '''''', 'NULL') + ',
						' + ISNULL('''''' + @notify_users + '''''', 'NULL') + ', 
						' + ISNULL('''''' + @notify_roles + '''''', 'NULL') + ',
						' + ISNULL('''''' + @export_csv_path + '''''', 'NULL') + ',
						' + ISNULL('''''' + @non_system_users + '''''', 'NULL') + ',
						' + ISNULL('''''' + @send_option + '''''', 'NULL') + ',
						' + ISNULL('' + CAST(@delivery_method AS VARCHAR(10)) + '', 'NULL') + ',
						' + ISNULL('' + CAST(@holiday_calendar_id AS VARCHAR(10)) + '', 'NULL') + ',
						' + ISNULL('' +  CAST(@freq_type AS VARCHAR(10)) + '', 'NULL') + ', NULL, NULL, NULL, NULL, NULL, NULL,
						' + ISNULL('''''' + @printer_name + '''''', 'NULL') + ',
						' + ISNULL('''''' + @report_folder + '''''', 'NULL') + ', NULL, NULL, 
						' + ISNULL('''''' + @process_table_name + '''''', 'NULL') + ''
		
		SET @job_name = 'send_confirmation_' + @process_id
				
		IF @freq_type IS NULL 
		BEGIN	
			SET @sql = 'exec spa_run_sp_as_job ''' + @job_name + ''', ''' + @build_sp + ''', ''Send Confirmation'', ''' + @user_login_id + ''''
			EXEC(@sql)
			
			EXEC spa_ErrorHandler 0
				, 'send_confirmation'
				, 'spa_send_confirmation'
				, 'Success'
				, 'Report Sending job started.'
				, ''
		END
		ELSE
		BEGIN
			SET @active_start_date_int = CAST(REPLACE(CONVERT(VARCHAR(10), @active_start_date, 21), '-', '') AS INT)
			SET @active_end_date_int = CAST(REPLACE(CONVERT(VARCHAR(10), @active_end_date, 21), '-', '') AS INT)
			
			--for weekly recurring, set the start_date to the weekday that has been set to start.
			IF @freq_type=8
			BEGIN
				SET @diffwd = LOG(@freq_interval)/LOG(2) + 1 - DATEPART(dw, @active_start_date)
				IF @diffwd < 0 
					SET  @diffwd = @diffwd + 7
				IF @diffwd <> 0 
					SET @active_start_date = DATEADD(DAY, @diffwd, @active_start_date)
			END
			
			--for monthly recurring, set the start_date to the month day that has been set to start.
		--check if that set day is greater than end day of month (for eg 28/29 for feb, 30 for april)
		--Job date wont be back date.
			ELSE IF @freq_type = 16
			BEGIN
				SET @currenttime = GETDATE()
				IF @active_start_date < @currenttime  --job date cannt be back date
					SET @active_start_date = @currenttime
				
				
				SET @currenthourminsec = CAST(DATEPART(HOUR, @currenttime) AS VARCHAR) + RIGHT('0' + CAST(DATEPART(MINUTE, @currenttime) AS VARCHAR), 2) + '00'
				
				--if yearmonth(startdate) > current date ,it is safe to run on same year month.
				IF (CAST(CAST(YEAR(@active_start_date) AS VARCHAR)+ CAST(MONTH(@active_start_date) AS VARCHAR) AS INT) 
					=
					CAST(CAST(YEAR(@currenttime) AS VARCHAR) + CAST(MONTH(@currenttime) AS VARCHAR) AS INT))
					
				IF (DAY(@active_start_date) > @freq_interval) OR (DAY(@active_start_date)= @freq_interval AND @currenthourminsec > CAST(@active_start_time AS INT) )
					SET @active_start_date = DATEADD(MONTH, 1, @active_start_date)

				SET @endofmonth = DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, 
								  CAST(YEAR(@active_start_date) AS VARCHAR) + '-' 
								  + CAST(MONTH(@active_start_date) AS VARCHAR) + '-01')))
								  
				IF DAY(@active_start_date) <> @freq_interval
					SET @active_start_date = CAST(YEAR(@active_start_date) AS VARCHAR) 
					+ '-' + CAST(MONTH(@active_start_date) AS VARCHAR) 
					+ '-' + CASE WHEN @freq_interval > @endofmonth 
								THEN CAST(@endofmonth AS VARCHAR)
								ELSE CAST(@freq_interval AS VARCHAR)
							 END
			END
			SET @time = CONVERT(VARCHAR(5), @user_date_time, 108)
			SET @sql = 'spa_run_sp_with_dynamic_params ''' + @build_sp + ''',''' + @batch_process_id + ''',' + ISNULL('''' + CAST(@holiday_calendar_id AS VARCHAR(10)) + '''', 'NULL')
			EXEC spa_run_sp_as_job_schedule 
						 @job_name,
						 @sql,
						 'Send Confirmation',
						 @user_login_id,
						 NULL,
						 @active_start_date_int,
						 @active_start_time,
						 @freq_type,
						 @freq_interval,
						 @freq_subday_type,
						 NULL,
						 NULL,
						 @freq_recurrence_factor,
						 @active_end_date_int,
						 @active_end_time
			EXEC spa_ErrorHandler 0
				, 'send_confirmation'
				, 'spa_send_confirmation'
				, 'Success'
				, 'Report Sending job started.'
				, ''
		END	
		
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'send_confirmation'
			, 'spa_send_confirmation'
			, 'Error'
			, 'Confirmation sending fail.'
			, ''
	END CATCH
END

IF @flag = 'e'
BEGIN
	BEGIN TRY
		IF @process_table_name IS NOT NULL 
		BEGIN
			IF OBJECT_ID('tempdb..#temp_calc_id_for_mail') IS NOT NULL
			    DROP TABLE #temp_calc_id_for_mail
			CREATE TABLE #temp_calc_id_for_mail (calc_id INT)
			SET @sql = 'insert into #temp_calc_id_for_mail (calc_id) select calc_id from ' + @process_table_name
			EXEC(@sql) 
			SELECT @source_deal_header_id = COALESCE(@source_deal_header_id + ', ' , '') + cast(calc_id AS VARCHAR(20)) FROM #temp_calc_id_for_mail
		END
		
		DECLARE @printing_source_deal_header_id		VARCHAR(MAX),
		        @print_flag							CHAR(1) = 'n',
		        @email_attachment					CHAR(1),
				@messaging_source_deal_header_id	VARCHAR(MAX),
				@bcc_emails							VARCHAR(5000),
				@cc_emails							VARCHAR(5000),
				@error_process_id					VARCHAR(200),
				@emailing_job						VARCHAR(200)
				
		SET @unique_process_id = CONVERT(varchar(13), right(REPLACE(newid(),'-', ''),13))	
		SET @printing_source_deal_header_id = @source_deal_header_id	
		SET @messaging_source_deal_header_id = @source_deal_header_id
		SET @error_process_id = dbo.FNAGetNewID()
	
		IF @delivery_method IN (21303, 21302) 
		BEGIN
			EXEC spa_print @delivery_method 
			SET @print_flag = 'y'
		END
		
		IF @print_flag = 'y' AND @printer_name IS NOT NULL 
		BEGIN
		
			DECLARE @root VARCHAR(1000),
					@report_parameter VARCHAR(MAX),
					@ssis_path VARCHAR(MAX),
					@proc_desc VARCHAR(100)
		
			SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_SSRSPrint', 'User::PS_PackageSubDir')
			SET @report_name = @report_folder + 'Deal Confirm Report Collection'
			exec spa_print @report_name
			--SET @printer_name= 'Canon LBP2900'
			SET @report_parameter = 'source_deal_header_id:''' + @source_deal_header_id + ''''

			SET @ssis_path = @root + 'Print_SSRS_Report_PKG.dtsx'
			SET @sql = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ReportName].Properties[Value]";"' + @report_name + '" /SET "\Package.Variables[User::PS_PrinterName].Properties[Value]";"' + @printer_name + '" /SET "\Package.Variables[User::PS_ReportParameter].Properties[Value]";"' + @report_parameter + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'
			SET @proc_desc = 'Print_SSRS'
			SET @job_name = @proc_desc + '_' + @process_id
			exec spa_print 'Printing Job - ', @job_name
		 
			EXEC dbo.spa_run_sp_as_job @job_name, @sql, 'SSIS_Print_SSRS', @user_login_id, 'SSIS', 2, 'y'		
		END
		
		IF ISNULL(@delivery_method, 21301) = 21302 OR ISNULL(@delivery_method, 21301) = 21305 OR ISNULL(@delivery_method, 21301) = 21303 OR (@send_option = 'y' AND @messaging_source_deal_header_id IS NOT NULL AND @messaging_source_deal_header_id <> '')
		BEGIN
			IF (ISNULL(@delivery_method, 21302) <> 21301)
			BEGIN
				SET @batch_process_id = dbo.FNAGetNewID() + '_' + @unique_process_id
				SET @job_name = 'report_batch' + '_' + @batch_process_id
			
				INSERT INTO batch_process_notifications (user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, holiday_calendar_id, non_sys_user_email)
				SELECT @user_login_id,
					   NULL,
					   @unique_process_id,
					   751,
					   'n',
					   CASE WHEN @freq_type IS NULL THEN 'n' ELSE 'y' END,
					   @export_csv_path,
					   @holiday_calendar_id,
					   NULL
				UNION
				SELECT a.item,
					   NULL,
					   @unique_process_id,
					   @notification_type,
					   @email_attachment,
					   CASE WHEN @freq_type IS NULL THEN 'n' ELSE 'y' END,
					   @export_csv_path,
					   @holiday_calendar_id,
					   NULL
				FROM dbo.SplitCommaSeperatedValues(@notify_users) a
				WHERE @notify_users IS NOT NULL
				UNION
				SELECT NULL,
					   a.item,
					   @unique_process_id,
					   @notification_type,
					   @email_attachment,
					   CASE WHEN @freq_type IS NULL THEN 'n' ELSE 'y' END,
					   @export_csv_path,
					   @holiday_calendar_id,
					   NULL
				FROM   dbo.SplitCommaSeperatedValues(@notify_roles) a
				WHERE  @notify_roles IS NOT NULL	
		
			   EXEC spa_message_board 'i', @user_login_id, NULL, 'Send Confirmation', 'Batch process scheduled.', NULL, NULL, 's', @job_name, NULL, @unique_process_id, NULL, 'n'
		
			   SET @report_file = 'Confirm Replacement Report Collection_' + @batch_process_id + '.pdf'
			   SET @filter = '"source_deal_header_id:' + @messaging_source_deal_header_id + '"'
			   SET @parameter = REPLACE(@reporting_param, 'Deal Confirm Report Template.pdf', @report_file)
			   SET @parameter = REPLACE(@parameter, 'Deal Confirm Report Template', 'Confirm Replacement Report Collection') + @filter
			   SET @sql = 'EXEC spa_rfx_export_report_job @report_param=''' + @parameter + ''', @proc_desc=''Send Confirmation'' , @user_login_id=''farrms_admin'', @report_RDL_name=''Confirm Replacement Report Collection'', @report_file_name=''' + @report_file+ ''',  @report_file_full_path=''' + REPLACE(@report_file_path, 'Deal Confirm Report Template.pdf', @report_file) + ''', @process_id=''' + @batch_process_id + ''''
		   
		   exec spa_print @sql
		   EXEC(@sql)
		
			   EXEC spa_ErrorHandler 0
				, 'send_confirmation_job'
				, 'spa_print_invoices'
				, 'Success'
				, 'Successfully sent invoice to counterparties.'
				, ''
			
				IF ((ISNULL(@delivery_method, 21301) = 21302 OR ISNULL(@delivery_method, 21301) = 21305) AND @send_option = 'n')
					RETURN
			END
		END
		
		DECLARE @attachment_folder VARCHAR(300),
				@attachment_file_name VARCHAR(300)
		SELECT	@attachment_folder = attachment_folder,
				@attachment_file_name = attachment_file_name
		FROM confirm_status cs
		INNER JOIN application_notes an ON cs.confirm_status_id = an.notes_object_id
		WHERE confirm_status_id = (SELECT MAX(confirm_status_id) FROM confirm_status WHERE source_deal_header_id = @source_deal_header_id)

		DECLARE @document_path VARCHAR(300)
		SELECT @document_path = document_path + '\' FROM connection_string
		SET @document_path = @document_path + @attachment_folder + '\'
		

		IF OBJECT_ID('tempdb..#temp_emailing_confirmation') IS NOT NULL
			DROP TABLE temp_emailing_confirmation		
		
		SELECT scsv.item, sdh.counterparty_id, sc.counterparty_name
		INTO #temp_emailing_confirmation
		FROM   dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item
		INNER JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
		WHERE @delivery_method NOT IN (21305, 21302) 
		
		IF EXISTS(SELECT 1 FROM #temp_emailing_confirmation)
		BEGIN
			SET @emailing_job = 'email_confirmation_' + @error_process_id 
			EXEC spa_message_board 'i', @user_login_id, NULL, 'Email Confirmation', 'Emailing job started for Confirmation.', NULL, NULL, 's', @emailing_job, NULL, @error_process_id, NULL, 'n'
		END	
	
		DECLARE email_confirmation CURSOR FOR
		SELECT item, counterparty_id, counterparty_name FROM #temp_emailing_confirmation
				
		OPEN email_confirmation
		FETCH NEXT FROM email_confirmation
		INTO @email_confirmation_id, @deal_counterparty_id, @deal_counterparty_name 
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @email_id VARCHAR(100),
					@email_cc VARCHAR(100),
					@email_bcc VARCHAR(100)
			
			SELECT @email_id = STUFF((SELECT ',' + email FROM counterparty_contacts WHERE counterparty_id = @deal_counterparty_id AND contact_type = -32201
									FOR XML PATH('')), 1, 1, '')
			SELECT @email_cc = STUFF((SELECT ',' + email_cc FROM counterparty_contacts WHERE counterparty_id = @deal_counterparty_id AND contact_type = -32201
									FOR XML PATH('')), 1, 1, '')
			SELECT @email_bcc = STUFF((SELECT ',' + email_bcc FROM counterparty_contacts WHERE counterparty_id = @deal_counterparty_id AND contact_type = -32201
									FOR XML PATH('')), 1, 1, '')

			SET @unique_process_id = CONVERT(varchar(13), right(REPLACE(newid(),'-', ''),13))
			SET @email_address = NULL
			
			SET @email_attachment = CASE WHEN @notification_type IN (750,752) THEN 'y' ELSE 'n' END
			SELECT * FROM dbo.SplitCommaSeperatedValues(@non_system_users) a
			
			SELECT @notification_type

			IF @email_id <> '' OR @email_id IS NOT NULL
			BEGIN
				INSERT INTO batch_process_notifications (user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, holiday_calendar_id, non_sys_user_email, cc_email, bcc_email)
				SELECT NULL,
					   NULL,
					   @unique_process_id,
					   @notification_type,
					   @email_attachment,
					   CASE WHEN @freq_type IS NULL THEN 'n' ELSE 'y' END,
					   @document_path,
					   @holiday_calendar_id,
					   @email_id,
					   @email_cc,
					   @email_bcc
			END
			
			INSERT INTO batch_process_notifications (user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, holiday_calendar_id, non_sys_user_email)
			SELECT NULL,
				   NULL,
				   @unique_process_id,
				   @notification_type,
				   @email_attachment,
				   CASE WHEN @freq_type IS NULL THEN 'n' ELSE 'y' END,
				   @export_csv_path,
				   @holiday_calendar_id,
				   a.item
			FROM  dbo.SplitCommaSeperatedValues(@non_system_users) a
			UNION
			SELECT a.item,
				   NULL,
				   @unique_process_id,
				   @notification_type,
				   @email_attachment,
				   CASE WHEN @freq_type IS NULL THEN 'n' ELSE 'y' END,
				   @export_csv_path,
				   @holiday_calendar_id,
				   NULL
			FROM dbo.SplitCommaSeperatedValues(@notify_users) a
			WHERE @notify_users IS NOT NULL
			UNION
			SELECT NULL,
				   a.item,
				   @unique_process_id,
				   @notification_type,
				   @email_attachment,
				   CASE WHEN @freq_type IS NULL THEN 'n' ELSE 'y' END,
				   @export_csv_path,
				   @holiday_calendar_id,
				   NULL
			FROM   dbo.SplitCommaSeperatedValues(@notify_roles) a
			WHERE  @notify_roles IS NOT NULL
			UNION
			SELECT @user_login_id,
				   NULL,
				   @unique_process_id,
				   @notification_type,
				   @email_attachment,
				   CASE WHEN @freq_type IS NULL THEN 'n' ELSE 'y' END,
				   @export_csv_path,
				   @holiday_calendar_id,
				   NULL	
			WHERE @notification_type <> 750
			
			EXEC spa_print '@@notification_type - ', @notification_type
			
			IF @send_option = 'n' AND @non_system_users IS NULL
			BEGIN
				INSERT INTO process_settlement_invoice_log(process_id, code, module, counterparty_id, prod_date, [description], nextsteps)
				SELECT @error_process_id, 'Error', 'Send Confirmation', @deal_counterparty_id, GETDATE(), 'Email address not defined.', 'Please define emaill adress to send email.'
			END
			
			DECLARE @email_footer VARCHAR(MAX)
			DECLARE @subject VARCHAR(2000)
		
			SET @batch_process_id = dbo.FNAGetNewID() + '_' + @unique_process_id
			SET @job_name = 'report_batch' + '_' + @batch_process_id
						
			EXEC spa_message_board 'i', @user_login_id, NULL, 'Send Confirmation', 'Batch process scheduled.', NULL, NULL, 's', @job_name, NULL, @unique_process_id, NULL, 'n'
			
			exec spa_print 'EXEC spa_message_board ''i'', ''', @user_login_id, ''', NULL, ''Send Invoice'', ''Batch process scheduled.'', NULL, NULL, ''s'',''', @job_name, ''', NULL, ''', @unique_process_id, ''', NULL, ''n'''
			
			SET @report_file = @deal_counterparty_name + '_' + CAST(@email_confirmation_id AS VARCHAR(20)) + '.pdf'
			--SET @email_description = 'Dear ' + ISNULL(@deal_counterparty_name, '') + ',<br /><br />Please find the attached confirmation for '  + CAST(@email_confirmation_id AS VARCHAR(20))
			--SET @subject = 'Confirmation of deal id ' + CAST(@email_confirmation_id AS VARCHAR(20))
			
			SELECT	@subject = email_subject,
					@email_description = dbo.FNAURLDecode(email_body) 
			FROM admin_email_configuration WHERE module_type = 17811 AND default_email = 'y'


			SELECT @email_footer = aec.email_footer FROM admin_email_configuration aec WHERE aec.module_type = 17804
			
			IF @email_footer IS NOT NULL
				SET @email_description = @email_description + '<br />' + @email_footer
			
			SET @report_name = 'Deal Confirm Report'
			SET @filter = '"source_deal_header_id:' + CAST(@email_confirmation_id AS VARCHAR(100)) + '"'
			SET @parameter = REPLACE(@reporting_param, 'Deal Confirm Report Template.pdf', @report_file)
			SET @parameter = REPLACE(@parameter, 'Deal Confirm Report Template', 'Confirm Replacement Report Collection') + @filter
			SET @sql = 'EXEC spa_rfx_export_report_job @report_param=''' + @parameter + ''', @proc_desc=''Send Confirmation'' , @user_login_id=''farrms_admin'', @report_RDL_name=''' + @report_name + ''', @report_file_name=''' + @report_file+ ''',  @report_file_full_path=''' + @document_path + @attachment_file_name + ''', @process_id=''' + @batch_process_id + ''', @email_description=''' + @email_description + ''', @email_subject=''' + @subject + '''' 
			EXEC(@sql)
			
			IF NOT EXISTS(SELECT 1 FROM process_settlement_invoice_log WHERE process_id = @error_process_id AND counterparty_id = @counterparty_id AND code = 'Error')
			BEGIN
				INSERT INTO process_settlement_invoice_log(process_id, code, module, counterparty_id, prod_date, [description], nextsteps)
				SELECT @error_process_id, 'Success', 'Send confirmation', @deal_counterparty_id, GETDATE(), 'Confirmation email sent successfully for Deal ID. ' + CAST(@email_confirmation_id AS VARCHAR(20)), 'N/A.'	
			END			
			
			FETCH NEXT FROM email_confirmation
			INTO @email_confirmation_id	, @deal_counterparty_id, @deal_counterparty_name
		END
		CLOSE email_confirmation
		DEALLOCATE email_confirmation
		
		
		DECLARE @error_warning VARCHAR(100)
		DECLARE @error_success CHAR(1)
		DECLARE @url VARCHAR(2000)
		DECLARE @description VARCHAR(3000)
		
		SET @error_success = 's'
		
		IF EXISTS(
			   SELECT 'X'
			   FROM   process_settlement_invoice_log
			   WHERE  process_id = @error_process_id AND code IN ('Error')
		   )
		BEGIN
			SET @error_warning = ' <font color="red">(Errors Found)</font>'
			SET @error_success = 'e'
		END	
		
		IF EXISTS (SELECT 1 FROM #temp_emailing_confirmation)
		BEGIN
			SET @url = './dev/spa_html.php?__user_name__=''' + @user_login_id + '''&spa=exec spa_get_settlement_invoice_log ''' + @error_process_id + ''''
			SET @description = '<a target="_blank" href="' + @url + '">Confirmation Emailed.' + ISNULL(@error_warning, '') + '.</a>'
			EXEC spa_message_board 'u', @user_login_id, NULL, 'Send Confirmation', @description, '', '', @error_success, @emailing_job 
		END
	
		EXEC spa_ErrorHandler 0
			, 'print_report_job'
			, 'spa_print_invoices'
			, 'Success'
			, 'Successfully sent invoice to counterparties.'
			, ''
	END TRY
	BEGIN CATCH
		DECLARE @DESC VARCHAR(5000)
		DECLARE @err_no INT
	 
		IF @@TRANCOUNT > 0
		   ROLLBACK

		SET @DESC = 'Fail to send invoice (Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler -1
			, 'print_report_job'
			, 'spa_print_invoices'
			, 'Error'
			, 'Invoice sending failed.'
			, ''
	END CATCH
END

/*
* This is not needed for now.
--To Update the deal confirmation status
IF @flag = 'x'
BEGIN
	BEGIN TRY
		IF OBJECT_ID('tempdb..#temp_deal_confirmation_id') IS NOT NULL
			DROP TABLE #temp_deal_confirmation_id
			
		CREATE TABLE #temp_deal_confirmation_id (deal_id INT)
		
		IF @process_table_name IS NOT NULL
		BEGIN
			DECLARE @strQuery VARCHAR(1000)			
			SET @strQuery = 'INSERT INTO #temp_deal_confirmation_id (deal_id)
			                 SELECT source_deal_header_id FROM  ' + @process_table_name
			exec spa_print @strQuery
			EXEC(@strQuery)
			
			SELECT @source_deal_header_id = COALESCE(@source_deal_header_id + ',', '') +  deal_id FROM #temp_deal_confirmation_id
		END
		ELSE
		BEGIN
			INSERT INTO #temp_deal_confirmation_id
			SELECT item FROM dbo.SplitCommaSeperatedValues(@source_deal_header_id)			
		END
			
		UPDATE cs
		SET cs.[type] = @confirmation_status
		FROM confirm_status cs
		INNER JOIN #temp_deal_confirmation_id tmp ON tmp.deal_id = cs.source_deal_header_id		

		INSERT INTO confirm_status(source_deal_header_id, [type], as_of_date) 
		SELECT tmp.deal_id,
		       @confirmation_status,
		       @as_of_date
		FROM #temp_deal_confirmation_id tmp
		LEFT JOIN confirm_status cs ON cs.source_deal_header_id = tmp.deal_id
		WHERE  cs.source_deal_header_id IS NULL
		
		UPDATE csr
        SET as_of_date = @as_of_date,
            [type] = @confirmation_status
        FROM confirm_status_recent csr
        INNER JOIN #temp_deal_confirmation_id temp ON temp.deal_id = csr.source_deal_header_id
        
        INSERT INTO confirm_status_recent(source_deal_header_id, [type], as_of_date) 
		SELECT tmp.deal_id,
		       @confirmation_status,
		       @as_of_date
		FROM #temp_deal_confirmation_id tmp
		LEFT JOIN confirm_status cs ON cs.source_deal_header_id = tmp.deal_id
		WHERE  cs.source_deal_header_id IS NULL
        
     --   UPDATE sdh
	    --SET    confirm_status_type = @confirmation_status,
	    --       update_ts = GETDATE(),
	    --       update_user = dbo.FNADBUser()
     --   FROM source_deal_header sdh
     --   INNER JOIN #temp_deal_confirmation_id temp ON temp.deal_id = sdh.source_deal_header_id       
	        
	    --EXEC spa_insert_update_audit 'u', @source_deal_header_id
	    
		EXEC spa_ErrorHandler 0, 'deal_confirmation_status', 'spa_send_confirmation', 'Success', 'Deal confirmation status has been successfully updated', ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK

		SET @DESC = 'Deal Confirmation Status update failed. ( Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler -1
			, 'deal_confirmation_status'
			, 'spa_send_confirmation'
			, 'Deal confirmation status update failed.'
			, @DESC
			,''
	END CATCH
END
*/