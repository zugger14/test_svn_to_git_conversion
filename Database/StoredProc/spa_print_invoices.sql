 IF OBJECT_ID(N'[dbo].[spa_print_invoices]', N'P') IS NOT NULL
     DROP PROCEDURE [dbo].[spa_print_invoices]
 GO
  
 SET ANSI_NULLS ON
 GO
  
 SET QUOTED_IDENTIFIER ON
 GO
  
 -- ===========================================================================================================
 -- Author: rajiv@pioneersolutionsglobal.com
 -- Create date: GETDATE()
 -- Description: CRUD operations for table time_zone
  
 -- Params:
 -- @flag CHAR(1) - Operation flag
 -- ===========================================================================================================
 CREATE PROCEDURE [dbo].[spa_print_invoices]
     @flag CHAR(1),
     @invoice_ids VARCHAR(MAX) = NULL,
     @counterparty_id INT = NULL,
     @contract_id INT = NULL,
     @as_of_date_from DATETIME = NULL,
     @as_of_date_to DATETIME = NULL,
     @settlement_date_from DATETIME = NULL,
     @settlement_date_to DATETIME = NULL,
     @remittance_invoice_status INT = NULL,
     @invoice_status CHAR(1) = NULL,
     @invoice_number VARCHAR(MAX) = NULL,
     @reporting_param VARCHAR(MAX) = NULL,
     @report_file_path VARCHAR(5000) = NULL,
     @report_name VARCHAR(MAX) = NULL,
 	@notify_users VARCHAR(MAX) = NULL,
 	@notify_roles VARCHAR(MAX) = NULL,
 	@export_csv_path VARCHAR(5000) = NULL,
 	@non_system_users VARCHAR(MAX) = NULL,
 	@send_option CHAR(1) = NULL,
 	@delivery_method INT = NULL,
 	@holiday_calendar_id INT = NULL,
 	@freq_type INT = NULL,
 	@active_start_date DATETIME = NULL,
 	@active_start_time VARCHAR(100) = NULL,
 	@freq_interval INT = NULL,
 	@active_end_date DATETIME = NULL,
 	@freq_subday_type INT = NULL,
 	@freq_recurrence_factor INT = NULL,	
 	@printer_name VARCHAR(200) = NULL,
 	@report_folder VARCHAR(500) = NULL,
 	@calc_type CHAR(1) = NULL,
 	@statement_type INT = NULL, -- statement type(invoice,remittance,netting statmenet Filters)
 	@process_table_name varchar(200) = NULL,
	@save_invoice char(1) = 'n',
     @batch_process_id VARCHAR(50) = NULL,
     @batch_report_param  VARCHAR(1000) = NULL 
 AS
 DECLARE @sql                         VARCHAR(MAX),
         @print_invoice_id            INT,
         @email_invoice_id            INT,
         @selected_counterparty_id    INT,
         @selected_contract_id        INT,
         @as_of_date                  VARCHAR(10),
         @prod_date                   VARCHAR(10),
         @filter                      VARCHAR(MAX),
         @report_type                 VARCHAR(20),
         @report_file                 VARCHAR(MAX),
         @parameter                   VARCHAR(MAX),
         @email_address               VARCHAR(MAX),
		 @unique_process_id           VARCHAR(50),
         @user_login_id               VARCHAR(100),
         @job_name                    VARCHAR(200),
         @user_date_time              DATETIME,
         @user_date                   DATETIME,
         @user_end_date_time          DATETIME,
         @active_end_time             INT,
         @notification_type           INT,
         @process_id                  VARCHAR(200),
         @invoice_type                CHAR(1),
         @selected_counterparty_name  VARCHAR(200),
         @selected_contract_name      VARCHAR(200),
         @email_description           VARCHAR(MAX),
         @netting_group_id            VARCHAR(100),
         @self_biling                 CHAR(1),
         @settlement_date             VARCHAR(10),
         @is_netting					 CHAR(1),
         @invoice_contact			 VARCHAR(200),
		 @invoice_file_name			 VARCHAR(2000),
		 @netting_file_name			 VARCHAR(2000)

     
         
         
 SET @user_login_id = dbo.FNADBUser()       
 IF @delivery_method IS NOT NULL
 BEGIN
 	SET @notification_type = CASE @delivery_method
 	                              WHEN 21301 THEN 750
                                   WHEN 21303 THEN 750
                                   WHEN 21304 THEN 751
                                   WHEN 21302 THEN 751
                                   WHEN 21305 THEN 751
								   WHEN 21306 THEN 750
                                   ELSE 751
 	                         END
 END
 SET @process_id = dbo.FNAGetNewID()
 

 IF @flag = 's'
 BEGIN
 
     SET @sql = 'SELECT calc_id [Invoice ID],
                        invoice_number [Invoice Number],
                        sc.counterparty_name [Counterparty],
                        ISNULL(ng.netting_group_name,contract_name) [Contract],
                        dbo.FNADateFormat(as_of_date) [As Of Date],
                        dbo.FNADateFormat(prod_date) [Production Month],
                        sdv.code [Status],
                        CASE WHEN ci.invoice_type = ''i'' THEN ''Invoice'' ELSE ''Remittance'' END [Invoice Type],
                        CASE 
                             WHEN [status] = ''v'' THEN ''Voided''
                             WHEN ISNULL(civ_status.finalized, ''n'') = ''y'' THEN 
                                  ''Final''
                             ELSE ''Initial''
                        END [Calculation Status],
                        (CASE WHEN invoice_lock = ''y'' THEN ''Yes'' ELSE ''No'' END) [Invoice Locked],
                        ci.counterparty_id,ci.contract_id,ci.prod_date,ci.as_of_date,
                        sdv.value_id invoice_status
                 INTO #calc_summary
                 FROM   calc_invoice_volume_variance ci
                 LEFT JOIN dbo.static_data_value sdv ON  sdv.value_id = ci.invoice_status
                 CROSS APPLY(
                     SELECT MAX([status]) [status],
                            MAX(finalized) finalized
                     FROM   calc_invoice_volume
                     WHERE  calc_id = ci.calc_id
                 ) civ_status
                 LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = ci.counterparty_id
                 LEFT JOIN contract_group cg ON cg.contract_id = ci.contract_id
                 LEFT JOIN netting_group ng ON ng.netting_group_id = ci.netting_group_id
                 WHERE  1 = 1 '
     
     IF @counterparty_id IS NOT NULL
         SET @sql = @sql + ' AND ci.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR)
         
     IF @contract_id IS NOT NULL
 		SET @sql = @sql + ' AND ci.contract_id = ' + CAST(@contract_id AS VARCHAR)   
 		     
     IF @as_of_date_from IS NOT NULL
 		SET @sql = @sql + ' AND ci.as_of_date >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120)+ ''''
 		
     IF @as_of_date_to IS NOT NULL
 		SET @sql = @sql + ' AND ci.as_of_date <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + ''''
 		
     IF @settlement_date_from IS NOT NULL
 		SET @sql = @sql + ' AND ci.prod_date >= ''' + CONVERT(VARCHAR(10), @settlement_date_from, 120) + ''''
 		
     IF @settlement_date_to IS NOT NULL
 		SET @sql = @sql + ' AND ci.prod_date <= ''' + CONVERT(VARCHAR(10), @settlement_date_to, 120) + ''''
 		
   
 	IF @invoice_number IS NOT NULL
 		SET @sql = @sql + ' AND ci.invoice_number = ' + @invoice_number
 	
 	IF @invoice_status IS NOT NULL	
 	BEGIN
 		IF @invoice_status = 'v'
 			SET @sql = @sql + ' AND civ_status.[status] = ''v'''
 		ELSE IF @invoice_status = 'f'
 			SET @sql = @sql + ' AND ISNULL(civ_status.[status], ''n'') <> ''v'' AND civ_status.[finalized] = ''y'''
 		ELSE 
 			SET @sql = @sql + ' AND ISNULL(civ_status.[status], ''n'') = ''n'' and ISNULL(civ_status.finalized, ''n'') = ''n'''
 	END
 	
 	IF @calc_type IS NOT NULL
 		SET @sql = @sql + ' AND sc.int_ext_flag = ''' + @calc_type + ''''
 		
 	
 	SET @sql = @sql + 
 			' 
 			SELECT [Invoice ID],[Invoice Number],[Counterparty],[Contract],[As Of Date],[Production Month],[Status],[Invoice Type],[Calculation Status],[Invoice Locked] FROM #calc_summary WHERE 1=1 '
 			+ CASE WHEN @statement_type =21500 THEN ' AND [Invoice Type] = ''Invoice''' WHEN @statement_type =21501 THEN ' AND [Invoice Type] = ''Remittance''' WHEN @statement_type =21502 THEN ' AND 1 = 2' ELSE '' END
 			+ CASE WHEN @remittance_invoice_status IS NOT NULL THEN 'AND invoice_status = ' + CAST(@remittance_invoice_status AS VARCHAR(10)) ELSE '' END+
 			+ CASE WHEN @statement_type =21502 OR @statement_type IS NULL THEN 
 			 ' UNION ALL '+
 			 '
 			 SELECT [Invoice ID],[Invoice Number],[Counterparty],[Contract],[As Of Date],[Production Month],sdv.code AS [Status],[Invoice Type], [Calculation Status],[Invoice Locked]
 			 FROM(
 				  SELECT MAX([Invoice ID])*-1 [Invoice ID],NULL [Invoice Number],[Counterparty],[Contract],[As Of Date],[Production Month],''Net'' AS [Invoice Type], '''' AS [Calculation Status], '''' AS [Invoice Locked]
 				  FROM #calc_summary cs WHERE  [Calculation Status] <> ''Voided'' GROUP BY [Counterparty],[Contract],[As Of Date],[Production Month])a
 				LEFT JOIN counterpartyt_netting_stmt_status cnss ON cnss.calc_id = [Invoice ID]
 			    LEFT JOIN static_data_value sdv ON sdv.value_id = cnss.[status_id]	
 			  WHERE 1=1 '+
 			  CASE WHEN @remittance_invoice_status IS NOT NULL THEN ' AND cnss.[status_id]	 = ' + CAST(@remittance_invoice_status AS VARCHAR(10)) ELSE '' END
 			 ELSE '' END
 			+ ' Order by [Invoice ID] desc'
     --PRINT(@sql)
     EXEC (@sql)
 END
 IF @flag = 'b'
 BEGIN	        
 	IF @batch_process_id IS NULL
 		SET @batch_process_id = dbo.FNAGetNewID()
 				
 	DECLARE print_invoice CURSOR FOR
 	SELECT scsv.item FROM dbo.SplitCommaSeperatedValues(@invoice_ids) scsv
 	


 	OPEN print_invoice
 	FETCH NEXT FROM print_invoice
 	INTO @print_invoice_id 
 	WHILE @@FETCH_STATUS = 0
 	BEGIN
 		SELECT @selected_counterparty_id = ci.counterparty_id,
 		       @selected_contract_id = ci.contract_id,
 		       @as_of_date = CONVERT(VARCHAR(10),ci.as_of_date,120),
 		       @prod_date = CONVERT(VARCHAR(10),ci.prod_date,120),
 		       @report_type = CASE WHEN civ_status.[status] = 'v' THEN 'Credit Note' WHEN ci.invoice_type = 'i' THEN 'Invoice' ELSE 'Remittance' END,
 		       @report_name = ISNULL(crt.template_name, 'Invoice Report A'),
 		       @invoice_type = ci.invoice_type,
 		       @netting_group_id = ci.netting_group_id
 		FROM   calc_invoice_volume_variance ci
 		LEFT JOIN contract_group cg on ci.contract_id = cg.contract_id
 		LEFT JOIN calc_Invoice_volume cv on cv.calc_id = ci.calc_id
 		LEFT JOIN Contract_report_template crt ON cg.contract_report_template = crt.template_id
 	    CROSS APPLY(
             SELECT MAX([status])[status]
             FROM   calc_invoice_volume
             WHERE  calc_id = ci.calc_id
           ) civ_status
 		WHERE  ci.calc_id = @print_invoice_id
 		GROUP BY ci.counterparty_id, ci.contract_id, ci.as_of_date, ci.prod_date, cg.[type], crt.template_name,ci.invoice_type, ci.netting_group_id,civ_status.[status]
 		SET @report_file = @report_name + '_' + dbo.FNAGetNewID() +  '.pdf'
 		SET @filter = '"source_deal_header_id:NULL,deal_date_from:' + @as_of_date + 
 						',deal_date_to:' + @as_of_date + ',counterparty_id:' + CAST(@selected_counterparty_id AS VARCHAR(10)) 
 						+ ',prod_month:' + @prod_date + ',contract_id:' + CAST(@selected_contract_id AS VARCHAR(10)) + ',save_invoice_id:' + CAST(@print_invoice_id AS VARCHAR(10)) + ',report_type:' + @report_type + ',invoice_type:' + @invoice_type+ ',netting_group_id:' + @netting_group_id + '"'
 		SET @parameter = REPLACE(@reporting_param, 'Invoice Report Template.pdf', @report_file)
 		SET @parameter = REPLACE(@parameter, 'Invoice Report Template', @report_name) + @filter
 		SET @sql = 'EXEC spa_rfx_export_report_job @report_param=''' + @parameter + ''', @proc_desc=''Send Invoice'' , @user_login_id=''farrms_admin'', @report_RDL_name=''' + @report_name + ''', @report_file_name=''' + @report_file+ ''', @report_file_full_path=''' + REPLACE(@report_file_path, 'Invoice Report Template.pdf', @report_file) + ''', @process_id=''' + @batch_process_id + ''''
 		
 		--PRINT(@sql)
 		EXEC(@sql)
 		
 		FETCH NEXT FROM print_invoice
 		INTO @print_invoice_id
 	END
 	CLOSE print_invoice
 	DEALLOCATE print_invoice
 END
 IF @flag = 'e'
 BEGIN
 --21305		Download
 --21301		Email Separate
 --21303		Email and EXEC spa_print
 --21304		Fax
 --21302		EXEC spa_print
 --21306		Email Aggregate
 
	BEGIN TRY
		IF @process_table_name IS NOT NULL 
		BEGIN
			IF OBJECT_ID('tempdb..#temp_calc_id_for_mail') IS NOT NULL
			    DROP TABLE #temp_calc_id_for_mail
			
			CREATE TABLE #temp_calc_id_for_mail (calc_id INT)
			SET @sql = 'insert into #temp_calc_id_for_mail (calc_id) select calc_id from ' + @process_table_name
			EXEC(@sql) 
			SELECT @invoice_ids = COALESCE(@invoice_ids + ', ' , '') + cast(calc_id AS VARCHAR(20)) FROM #temp_calc_id_for_mail
		END
		
		DECLARE @printing_invoice_ids  VARCHAR(MAX),
		        @print_flag    CHAR(1) = 'n',
		        @email_attachment CHAR(1),
				@messaging_invoice_ids  VARCHAR(MAX),
				@bcc_emails VARCHAR(5000),
				@cc_emails VARCHAR(5000),
				@error_process_id VARCHAR(200),
				@emailing_job VARCHAR(200)
				
		SET @unique_process_id = CONVERT(varchar(13), right(REPLACE(newid(),'-', ''),13))	
		SET @printing_invoice_ids = @invoice_ids	
		SET @messaging_invoice_ids = @invoice_ids
		SET @error_process_id = dbo.FNAGetNewID()
	
		IF @send_option = 'n' AND @delivery_method IN (21303, 21302) 
		BEGIN
			--PRINT @delivery_method 
			SET @print_flag = 'y'
		END
		ELSE IF @send_option = 'y'
		BEGIN
			SET @printing_invoice_ids = NULL
			
			SELECT @printing_invoice_ids = COALESCE(@printing_invoice_ids + ',', '') + scsv.item
			FROM   dbo.SplitCommaSeperatedValues(@invoice_ids) scsv
			INNER JOIN calc_invoice_volume_variance civv ON  civv.calc_id = scsv.item
			INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = civv.counterparty_id
			WHERE sc.delivery_method IN (21303, 21302)
			--PRINT @printing_invoice_ids 
			
			SET @messaging_invoice_ids = NULL
			SELECT @messaging_invoice_ids = COALESCE(@messaging_invoice_ids + ',', '') + scsv.item
			FROM   dbo.SplitCommaSeperatedValues(@invoice_ids) scsv
			INNER JOIN calc_invoice_volume_variance civv ON  civv.calc_id = scsv.item
			INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = civv.counterparty_id
			WHERE sc.delivery_method IN (21303, 21302, 21305)
			
			IF OBJECT_ID('tempdb..#temp_delivery_methods_missing_counterparties') IS NOT NULL
			    DROP TABLE #temp_delivery_methods_missing_counterparties
			
			SELECT sc.source_counterparty_id, sc.counterparty_name, civv.calc_id
			INTO #temp_delivery_methods_missing_counterparties
			FROM   dbo.SplitCommaSeperatedValues(@invoice_ids) scsv
			INNER JOIN calc_invoice_volume_variance civv ON  civv.calc_id = scsv.item
			INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = civv.counterparty_id
			WHERE sc.delivery_method IS NULL OR sc.delivery_method = ''
			
			IF EXISTS (SELECT 1 FROM #temp_delivery_methods_missing_counterparties)
			BEGIN
				INSERT INTO process_settlement_invoice_log(process_id, code, module, counterparty_id, prod_date, [description], nextsteps, invoice_id)
				SELECT @error_process_id, 'Error', 'Send Invoices', source_counterparty_id, GETDATE(), 'Delivery Method not defined for <b>' + counterparty_name + '</b>', 'Please define delivery method.', calc_id
				FROM #temp_delivery_methods_missing_counterparties
			END
			
			IF OBJECT_ID('tempdb..#temp_delivery_methods_download') IS NOT NULL
			    DROP TABLE #temp_delivery_methods_download
			
			SELECT sc.source_counterparty_id, sc.counterparty_name, civv.calc_id
			INTO #temp_delivery_methods_download
			FROM   dbo.SplitCommaSeperatedValues(@invoice_ids) scsv
			INNER JOIN calc_invoice_volume_variance civv ON  civv.calc_id = scsv.item
			INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = civv.counterparty_id
			WHERE sc.delivery_method IN (21302, 21305)
			
			IF EXISTS (SELECT 1 FROM #temp_delivery_methods_download)
			BEGIN
				INSERT INTO process_settlement_invoice_log(process_id, code, module, counterparty_id, prod_date, [description], nextsteps, invoice_id)
				SELECT @unique_process_id, 'Download', 'Send Invoices', source_counterparty_id, GETDATE(), 'Invoice download for <b>' + counterparty_name + '</b>', 'Please define delivery method.', calc_id
				FROM #temp_delivery_methods_download
			END
			
			
			IF @printing_invoice_ids IS NOT NULL
				SET @print_flag = 'y'
		END
		--print_flag = 'n'
		IF @print_flag = 'y' AND @printer_name IS NOT NULL 
		BEGIN
		
			DECLARE @root VARCHAR(1000),
					@report_parameter VARCHAR(MAX),
					@ssis_path VARCHAR(MAX),
					@proc_desc VARCHAR(100)
		
			SELECT @root = dbo.FNAGetSSISPkgFullPath('PRJ_SSRSPrint', 'User::PS_PackageSubDir')
			SET @report_name = @report_folder + 'Invoice Report Collection'
			--PRINT @report_name
			--SET @printer_name= 'Canon LBP2900'
			SET @report_parameter = 'invoice_ids:''' + @printing_invoice_ids + ''''

			SET @ssis_path = @root + 'Print_SSRS_Report_PKG.dtsx'
			SET @sql = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ReportName].Properties[Value]";"' + @report_name + '" /SET "\Package.Variables[User::PS_PrinterName].Properties[Value]";"' + @printer_name + '" /SET "\Package.Variables[User::PS_ReportParameter].Properties[Value]";"' + @report_parameter + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'
			SET @proc_desc = 'Print_SSRS'
			SET @job_name = @proc_desc + '_' + @process_id
			--PRINT('Printing Job - ' + @job_name)
		 
			EXEC dbo.spa_run_sp_as_job @job_name, @sql, 'SSIS_Print_SSRS', @user_login_id, 'SSIS', 2, 'y'
		
		END
		
		IF ISNULL(@delivery_method, 21301) = 21302 OR ISNULL(@delivery_method, 21301) = 21305 OR ISNULL(@delivery_method, 21301) = 21303 OR (@send_option = 'y' AND @messaging_invoice_ids IS NOT NULL AND @messaging_invoice_ids <> '')
		BEGIN
			--SET @batch_process_id = dbo.FNAGetNewID() + '_' + @unique_process_id
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
			IF @save_invoice <> 'y'
		   EXEC spa_message_board 'i', @user_login_id, NULL, 'Send Invoice', 'Batch process scheduled.', NULL, NULL, 's', @job_name, NULL, @unique_process_id, NULL, 'n'
		
		   --SET @report_file = @selected_counterparty_name +'_'+ @prod_date_month + @prod_date_year +'_'+CASE WHEN @is_netting = 'n' THEN CASE WHEN @invoice_type = 'i' THEN 'Invoice' ELSE 'Remittance ' END ELSE 'Netting' END +'_'+ CASE WHEN @is_netting = 'n' THEN CAST(@invoice_number AS VARCHAR(20)) ELSE '-' + CAST(@invoice_number AS VARCHAR(20)) END  + '.pdf'
			DECLARE @inv_counterparty_name VARCHAR(100)
			DECLARE @inv_prod_date_year VARCHAR(15)
			DECLARE @inv_prod_date_month VARCHAR(15)
			DECLARE @inv_is_netting CHAR(1)
			DECLARE @inv_invoice_type CHAR(1)
			DECLARE @inv_invoice_number VARCHAR(20)

			IF @save_invoice = 'y'
			BEGIN
				SELECT  @inv_counterparty_name = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(sc.counterparty_name, '"',''), '\', ''), '/', ''), ':', ''), '*', ''), '?', ''), '<', ''), '>', ''), '|', ''),
						@inv_prod_date_year = DATEPART(YYYY,civv.prod_date),
						@inv_prod_date_month = convert(CHAR(3), DATENAME(MONTH, civv.prod_date), 0),
						@inv_is_netting = CASE WHEN cg.netting_statement = 'y' THEN CASE WHEN CAST(@invoice_ids AS INT) < 0 THEN 'y' ELSE 'n' END ELSE 'n' END,
						@inv_invoice_type = civv.invoice_type,
						@inv_invoice_number = civv.invoice_number
				FROM Calc_invoice_Volume_variance civv	
				INNER JOIN source_counterparty sc ON civv.counterparty_id = sc.source_counterparty_id
				INNER JOIN contract_group cg ON civv.contract_id = cg.contract_id
				WHERE calc_id = CASE WHEN @invoice_ids < 0 THEN @invoice_ids * -1 ELSE @invoice_ids END
				SET @report_file = @inv_counterparty_name +'_'+ @inv_prod_date_month + @inv_prod_date_year +'_'+ CASE WHEN @inv_is_netting = 'n' THEN CASE WHEN @inv_invoice_type = 'i' THEN 'Invoice' ELSE 'Remittance' END ELSE 'Netting' END +'_'+ CASE WHEN @inv_is_netting = 'n' THEN CAST(@inv_invoice_number AS VARCHAR(20)) ELSE '-' + CAST(@inv_invoice_number AS VARCHAR(20)) END  + '.pdf'
				SET @report_file = REPLACE(@report_file, '/','_')
		   END
		   ELSE
		   BEGIN
				SET @report_file = 'Invoice Report Collection_' + @batch_process_id + '.pdf'
		   END
		   SET @filter = 'invoice_ids:' + @messaging_invoice_ids
		   SET @parameter = REPLACE(@reporting_param, 'Invoice Report Template.pdf', @report_file)
		   --PRINT('filter ' + ISNULL(@filter, 'isnull'))
		   EXEC spa_export_invoice @invoice_ids, @filter, @report_file,  @batch_process_id
		   
			IF @save_invoice = 'y'
			BEGIN
				IF (CAST(@invoice_ids AS INT) > 0) 
				BEGIN
					UPDATE Calc_invoice_Volume_variance
					SET invoice_file_name = @report_file
					WHERE calc_id = @invoice_ids
				END 
				ELSE 
				BEGIN
					UPDATE Calc_invoice_Volume_variance
					SET netting_file_name = @report_file
					WHERE calc_id = CAST(@invoice_ids AS INT) * -1
				END
			END

			IF @save_invoice = 'n'
 			EXEC spa_ErrorHandler 0
			, 'print_report_job'
			, 'spa_print_invoices'
			, 'Success'
			, 'Successfully sent invoice to counterparties.'
			, ''
			
			IF ((ISNULL(@delivery_method, 21301) = 21302 OR ISNULL(@delivery_method, 21301) = 21305) AND @send_option = 'n')
				RETURN
		END
				
		
		IF OBJECT_ID('tempdb..#temp_emailing_invoices_ctpty_list') IS NOT NULL
			    DROP TABLE #temp_emailing_invoices_ctpty_list	
		IF OBJECT_ID('tempdb..#temp_emailing_invoices_ctpty') IS NOT NULL
			    DROP TABLE #temp_emailing_invoices_ctpty	
		IF OBJECT_ID('tempdb..#temp_emailing_invoices') IS NOT NULL
			    DROP TABLE #temp_emailing_invoices	
		
		/* Added backing sheets calc ids if it is netting */
			DECLARE @netting_calc_id VARCHAR(MAX)
			SELECT @netting_calc_id = ISNULL(@netting_calc_id,'') + ',' + CAST(ci.calc_id AS VARCHAR)
			FROM
				calc_invoice_volume_variance ci
				inner join dbo.SplitCommaSeperatedValues(@invoice_ids) tmp on tmp.item = ci.netting_calc_id
				inner join calc_invoice_volume_variance ci2 on ci2.calc_id = tmp.item
				inner join source_counterparty sc on sc.source_counterparty_id = ci2.counterparty_id AND sc.delivery_method = 21306
		
			IF @netting_calc_id IS NOT NULL
				SET @invoice_ids = @invoice_ids + @netting_calc_id
		/* Added backing sheets calc ids if it is netting END */
		
		SELECT TOP 0 0 AS ctpty,  CAST('' AS DATETIME) AS prod_month
		INTO #temp_emailing_invoices_ctpty_list
		FROM dbo.SplitCommaSeperatedValues(@invoice_ids)
						
		SELECT TOP 0 item
		INTO #temp_emailing_invoices
		FROM dbo.SplitCommaSeperatedValues(@invoice_ids)

			
		INSERT INTO #temp_emailing_invoices_ctpty_list
			SELECT sc.source_counterparty_id, ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, civv.prod_date), 0),0) prod_month
			FROM   dbo.SplitCommaSeperatedValues(@invoice_ids) scsv
			INNER JOIN calc_invoice_volume_variance civv ON  civv.calc_id = CASE WHEN scsv.item < 0 THEN scsv.item * -1 ELSE scsv.item END
			INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = civv.counterparty_id			
			WHERE (sc.delivery_method NOT IN (21305, 21302) AND @send_option = 'y') OR (@send_option = 'n')
			GROUP BY sc.source_counterparty_id, ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, civv.prod_date), 0),0)

		--select * from #temp_emailing_invoices_ctpty_list
		--return 

		SELECT ROW_NUMBER() OVER (ORDER BY a.ctpty,a.[prod_month]) AS ctpty_row_no, a.ctpty, a.items, a.[prod_month]
		INTO #temp_emailing_invoices_ctpty
		FROM
		(
		SELECT sc.ctpty AS [ctpty], sc.prod_month AS [prod_month],
            STUFF((    SELECT ',' + scsv.item AS [text()]
                       -- Add a comma (,) before each value
                        FROM   dbo.SplitCommaSeperatedValues(@invoice_ids) scsv
						INNER JOIN calc_invoice_volume_variance civv ON  civv.calc_id = CASE WHEN scsv.item < 0 THEN scsv.item * -1 ELSE scsv.item END
                        WHERE
                        sc.ctpty = civv.counterparty_id AND scsv.item IS NOT NULL AND ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, civv.prod_date), 0),0) = sc.prod_month
                        FOR XML PATH('')-- Select it as XML
                        ), 1, 1, '' )
                        --This is done to remove the first character (,)
                       -- from the result
            AS [items]
			FROM  #temp_emailing_invoices_ctpty_list sc
		) a

		--select * from #temp_emailing_invoices_ctpty
		--return

		IF OBJECT_ID('tempdb..#tmp_list_email_agg') IS NOT NULL
 			    DROP TABLE #tmp_list_email_agg
 			
 		CREATE TABLE #tmp_list_email_agg (invoice_id INT, process_id VARCHAR(100) COLLATE DATABASE_DEFAULT, email_address VARCHAR(100) COLLATE DATABASE_DEFAULT, cc_emails VARCHAR(500) COLLATE DATABASE_DEFAULT, bcc_emails VARCHAR(500) COLLATE DATABASE_DEFAULT, file_path VARCHAR(500) COLLATE DATABASE_DEFAULT, sql_string VARCHAR(4000) COLLATE DATABASE_DEFAULT)
		

		DECLARE @ctpty_id INT = NULL
		DECLARE @delivery_month DATETIME = NULL
		DECLARE @email_agg_exists INT = 0
		DECLARE @for_message_board INT = 0
		
		--- START mark 1 ---
		DECLARE @ctpty_email_invoice_rowid INT
		DECLARE ctpty_email_invoice CURSOR FOR
		SELECT ctpty_row_no FROM #temp_emailing_invoices_ctpty
		
		OPEN ctpty_email_invoice
		FETCH NEXT FROM ctpty_email_invoice
		INTO @ctpty_email_invoice_rowid 
		WHILE @@FETCH_STATUS = 0
		BEGIN			    
					--SELECT @ctpty_id = ISNULL(sc.source_counterparty_id, 0), @delivery_month = ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, civv.prod_date), 0),0)
					--  FROM   dbo.SplitCommaSeperatedValues(@invoice_ids) scsv
					--	INNER JOIN calc_invoice_volume_variance civv ON  civv.calc_id = CASE WHEN scsv.item < 0 THEN scsv.item * -1 ELSE scsv.item END
					--	INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = civv.counterparty_id
					--	WHERE sc.delivery_method = 21306 AND 'y' = 'y'
					DELETE FROM #temp_emailing_invoices
					
					SELECT @ctpty_id = ctpty, @delivery_month = prod_month, @invoice_ids = items
						FROM #temp_emailing_invoices_ctpty where ctpty_row_no = @ctpty_email_invoice_rowid

					IF EXISTS (SELECT 1 FROM source_counterparty WHERE source_counterparty_id = @ctpty_id AND delivery_method = 21306 AND @send_option = 'y')
					BEGIN
				
						INSERT INTO #temp_emailing_invoices
						SELECT scsv.item
						FROM   dbo.SplitCommaSeperatedValues(@invoice_ids) scsv
						INNER JOIN calc_invoice_volume_variance civv ON  civv.calc_id = CASE WHEN scsv.item < 0 THEN scsv.item * -1 ELSE scsv.item END
				
						SET @email_agg_exists = 1
						--SELECT * FROM #temp_emailing_invoices
						--SELECT @delivery_month [dt1], @ctpty_id [ct1]
					END
					ELSE
					BEGIN
				
						INSERT INTO #temp_emailing_invoices
						SELECT scsv.item
						FROM   dbo.SplitCommaSeperatedValues(@invoice_ids) scsv
						INNER JOIN calc_invoice_volume_variance civv ON  civv.calc_id = CASE WHEN scsv.item < 0 THEN scsv.item * -1 ELSE scsv.item END
						INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = civv.counterparty_id
						WHERE (sc.delivery_method NOT IN (21305, 21302) AND @send_option = 'y') OR (@send_option = 'n')		
				
						SET @email_agg_exists = 0
					END
				
				--SELECT * FROM #temp_emailing_invoices
		
		
				IF EXISTS(SELECT 1 FROM #temp_emailing_invoices)
				BEGIN
					IF @for_message_board = 0
					BEGIN
						SET @emailing_job = 'email_invoices_' + @error_process_id 
						IF @save_invoice <> 'y'
						EXEC spa_message_board 'i', @user_login_id, NULL, 'Email Invoices', 'Emailing job started for invoices.', NULL, NULL, 's', @emailing_job, NULL, @error_process_id, NULL, 'n'
					END
				END		
				DECLARE  @process_id_for_log varchar(200)
				SET @process_id_for_log = CONVERT(varchar(13), right(REPLACE(newid(),'-', ''),13))
				DECLARE @email_calc_id INT = NULL
		
				DECLARE @email_address_condition INT = NULL
		
		        DECLARE @delivery_method_cpty INT
				DECLARE @cursor_count INT = 0
				DECLARE @cursor_totalcount INT = 0
				SELECT @cursor_totalcount = COUNT(1) FROM #temp_emailing_invoices
		
				DECLARE @report_file_paths_for_agg VARCHAR(MAX) = ''
				DECLARE email_invoice CURSOR FOR
				SELECT item FROM #temp_emailing_invoices
			
				OPEN email_invoice
				FETCH NEXT FROM email_invoice
				INTO @email_invoice_id 
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @email_address_condition = 0
					SET @unique_process_id = CONVERT(VARCHAR(13), right(REPLACE(newid(),'-', ''),13))	
					SELECT @selected_counterparty_id = ci.counterparty_id,
						   @selected_contract_id = ci.contract_id,
						   @as_of_date = CONVERT(VARCHAR(10),ci.as_of_date,120),
						   @prod_date = CONVERT(VARCHAR(10),ci.prod_date,120),
						   @report_type = CASE WHEN civ_status.[status] = 'v' THEN 'Credit Note' WHEN ci.invoice_type = 'i' THEN 'Invoice' ELSE 'Remittance' END,
						   @report_name = 'Invoice Report Collection',
						   @invoice_type = ci.invoice_type,
						   @invoice_number = ci.invoice_number,
						   @selected_counterparty_name = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(MAX(sc.counterparty_name), '"',''), '\', ''), '/', ''), ':', ''), '*', ''), '?', ''), '<', ''), '>', ''), '|', ''),
						   @selected_contract_name = ISNULL(MAX(cg.contract_name), MAX(ng.netting_group_name)),
						   @netting_group_id = MAX(ci.netting_group_id),
						   @self_biling = MAX(cg.self_billing),
						   @settlement_date = CONVERT(VARCHAR(10),ci.settlement_date,120),
						   @is_netting = CASE WHEN @email_invoice_id > 0 THEN 'n' ELSE 'y' END,
						   @invoice_contact = ISNULL(MAX(cca.counterparty_full_name), MAX(sc.counterparty_contact_name)),
						   @email_calc_id = ci.calc_id,
						   @invoice_file_name = MAX(ci.invoice_file_name),
						   @netting_file_name = MAX(ci.netting_file_name),
						   @delivery_method_cpty = sc.delivery_method
					FROM  calc_invoice_volume_variance ci
					--LEFT JOIN counterpartyt_netting_stmt_status cnss ON cnss.calc_id = @email_invoice_id
					LEFT JOIN contract_group cg on ci.contract_id = cg.contract_id
					LEFT JOIN calc_Invoice_volume cv on cv.calc_id = ci.calc_id
					LEFT JOIN Contract_report_template crt ON crt.template_id = CASE WHEN @email_invoice_id > 0 THEN CASE WHEN ci.invoice_type = 'i' THEN cg.invoice_report_template ELSE cg.contract_report_template END ELSE cg.netting_template END 
					INNER JOIN source_counterparty sc ON sc.source_counterparty_id = ci.counterparty_id
					LEFT JOIN netting_group ng ON ng.netting_group_id = ci.netting_group_id
					LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.source_counterparty_id AND cca.contract_id = cg.contract_id
					CROSS APPLY(
						SELECT MAX([status]) [status]
						FROM   calc_invoice_volume
						WHERE  calc_id = ci.calc_id
					) civ_status			
					WHERE  ci.calc_id = CASE WHEN @email_invoice_id < 0 THEN @email_invoice_id * -1 ELSE @email_invoice_id END
					GROUP BY ci.counterparty_id, ci.contract_id, ci.as_of_date, ci.prod_date, cg.[type], crt.filename,ci.invoice_type,ci.invoice_number,civ_status.[status], ci.settlement_date, ci.calc_id, sc.delivery_method
			
					DECLARE @is_email_counterparty_contract BIT = 0
					--SELECT @is_email_counterparty_contract = CASE WHEN NULLIF(cca.email, '') IS NOT NULL OR NULLIF(cca.bcc_mail, '') IS NOT NULL OR NULLIF(cca.cc_mail, '') IS NOT NULL OR  NULLIF(cca.remittance_to, '') IS NOT NULL OR NULLIF(cca.bcc_remittance, '') IS NOT NULL OR NULLIF(cca.cc_remittance, '') IS NOT NULL  THEN 1 ELSE 0 END
					--FROM counterparty_contract_address cca
					--WHERE  cca.counterparty_id = @selected_counterparty_id AND cca.contract_id = @selected_contract_id


					--change to pick payables and receiveables address
					SELECT @is_email_counterparty_contract = 
						CASE WHEN nullif(cc.email,'') IS NOT NULL OR nullif(cc.email_bcc,'') IS NOT NULL OR nullif(cc.email_cc,'') IS NOT NULL 
							--OR  NULLIF(cca.remittance_to, '') IS NOT NULL OR NULLIF(cca.bcc_remittance, '') IS NOT NULL OR NULLIF(cca.cc_remittance, '') IS NOT NULL  
							THEN 1 ELSE 0 
						END
					FROM counterparty_contract_address cca
					
					left join source_counterparty sc on sc.source_counterparty_id = @selected_counterparty_id
					left join counterparty_contacts cc on cc.counterparty_id = @selected_counterparty_id
						and cc.counterparty_contact_id = IIF(@invoice_type = 'i', isnull(cca.payables,sc.payables), isnull(cca.receivables,sc.receivables))
					WHERE  cca.counterparty_id = @selected_counterparty_id AND cca.contract_id = @selected_contract_id

					--null,i,n
					SET @email_address = NULL
					IF @send_option = 'y'
					BEGIN
						IF @self_biling = 'y' AND @invoice_type = 'r' AND @is_netting = 'n'
							SELECT	@email_address = CASE @is_email_counterparty_contract WHEN 1 THEN  ISNULL(cc_receivables.email,primary_receivables.email) ELSE cca.email END,
									@cc_emails = CASE @is_email_counterparty_contract WHEN 1 THEN  ISNULL(cc_receivables.email_cc,primary_receivables.email_cc)  ELSE cca.cc_mail END,
									@bcc_emails = CASE @is_email_counterparty_contract WHEN 1 THEN  ISNULL(cc_receivables.email_bcc,primary_receivables.email_bcc) ELSE cca.bcc_mail END
							FROM   source_counterparty sc
							LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id AND cca.contract_id = @selected_contract_id
							LEFT JOIN counterparty_contacts cc_receivables ON sc.source_counterparty_id = cc_receivables.counterparty_id 
								AND cc_receivables.counterparty_contact_id = ISNULL(cca.receivables, sc.receivables)
							LEFT JOIN counterparty_contacts primary_receivables ON sc.source_counterparty_id = primary_receivables.counterparty_id AND primary_receivables.is_primary = 'y'
							WHERE  sc.source_counterparty_id = @selected_counterparty_id
						--ELSE IF @self_biling = 'n' AND @invoice_type = 'r' AND @is_netting = 'n'
						--	BEGIN
						--		SET @email_address_condition = 1
						--		SELECT @email_address = NULL,
						--			   @bcc_emails = NULL,
						--			   @cc_emails = NULL
						--		FROM   source_counterparty sc
						--		LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id AND cca.contract_id = @selected_contract_id
						--		LEFT JOIN counterparty_contacts cc ON cc.counterparty_id = sc.source_counterparty_id 
						--			and cc.counterparty_contact_id = IIF(@invoice_type='r',sc.payables, sc.receivables)
						--		WHERE  sc.source_counterparty_id = @selected_counterparty_id 
						--	END
						ELSE IF @self_biling = 'n' AND @invoice_type = 'r' AND @is_netting = 'y'
							SELECT	@email_address = CASE @is_email_counterparty_contract WHEN 1 THEN  ISNULL(cc_receivables.email,primary_receivables.email) ELSE cca.email END,
									@cc_emails = CASE @is_email_counterparty_contract WHEN 1 THEN  ISNULL(cc_receivables.email_cc,primary_receivables.email_cc)  ELSE cca.cc_mail END,
									@bcc_emails = CASE @is_email_counterparty_contract WHEN 1 THEN  ISNULL(cc_receivables.email_bcc,primary_receivables.email_bcc) ELSE cca.bcc_mail END
							FROM   source_counterparty sc
							LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id AND cca.contract_id = @selected_contract_id
							LEFT JOIN counterparty_contacts cc_receivables ON sc.source_counterparty_id = cc_receivables.counterparty_id 
								AND cc_receivables.counterparty_contact_id = ISNULL(cca.receivables, sc.receivables)
							LEFT JOIN counterparty_contacts primary_receivables ON sc.source_counterparty_id = primary_receivables.counterparty_id AND primary_receivables.is_primary = 'y'
							WHERE  sc.source_counterparty_id = @selected_counterparty_id 
						ELSE 
							SELECT	@email_address = CASE @is_email_counterparty_contract WHEN 1 THEN CASE WHEN @invoice_type = 'i' THEN ISNULL(cc_payables.email,primary_contact.email) ELSE ISNULL(cc_receivables.email,primary_contact.email) END ELSE cca.email END,
									@cc_emails = CASE @is_email_counterparty_contract WHEN 1 THEN CASE WHEN @invoice_type = 'i' THEN ISNULL(cc_payables.email_cc,primary_contact.email_cc) ELSE ISNULL(cc_receivables.email_cc,primary_contact.email_cc) END ELSE cca.cc_mail END,
									@bcc_emails = CASE @is_email_counterparty_contract WHEN 1 THEN CASE WHEN @invoice_type = 'i' THEN ISNULL(cc_payables.email_bcc,primary_contact.email_bcc) ELSE ISNULL(cc_receivables.email_bcc,primary_contact.email_bcc) END ELSE cca.bcc_mail END
							FROM   source_counterparty sc
							LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id AND cca.contract_id = @selected_contract_id
							LEFT JOIN counterparty_contacts cc_payables ON sc.source_counterparty_id = cc_payables.counterparty_id 
								AND cc_payables.counterparty_contact_id = ISNULL(cca.payables, sc.payables)
							LEFT JOIN counterparty_contacts cc_receivables ON sc.source_counterparty_id = cc_receivables.counterparty_id 
								AND cc_receivables.counterparty_contact_id = ISNULL(cca.receivables, sc.receivables)
							LEFT JOIN counterparty_contacts primary_contact ON sc.source_counterparty_id = primary_contact.counterparty_id AND primary_contact.is_primary = 'y'
							WHERE  sc.source_counterparty_id = @selected_counterparty_id
						
						IF @email_address = '' OR @email_address = ' '
							SET @email_address = NULL

						IF @email_address IS NULL
						BEGIN
							INSERT INTO process_settlement_invoice_log(process_id, code, module, counterparty_id, prod_date, [description], nextsteps, invoice_id)
							SELECT @error_process_id, 'Error', 'Send Invoices', @selected_counterparty_id, GETDATE(), 'Invoice nr.<b>' + @invoice_number + '</b> Email address not defined for <b>' + sc.counterparty_name + '</b>', 'Please define Email address for counterparty.', @email_calc_id
							FROM source_counterparty sc 
							WHERE sc.source_counterparty_id = @selected_counterparty_id
					
						END
				
						--IF @self_biling = 'n' AND @invoice_type = 'r' AND @email_address IS NULL AND @is_netting = 'n'
						--BEGIN
					
						--	INSERT INTO process_settlement_invoice_log(process_id, code, module, counterparty_id, prod_date, [description], nextsteps, invoice_id)
						--	SELECT @error_process_id, 'Error', 'Send Invoices', @selected_counterparty_id, GETDATE(), 'Invoice nr.<b>' + @invoice_number + '</b> Remittance Email cannot be send for <b>' + sc.counterparty_name +  '</b>', 'Please define self billing for contract.', @email_calc_id
						--	FROM source_counterparty sc 
						--	WHERE sc.source_counterparty_id = @selected_counterparty_id
						--END
				
						SELECT @notification_type = CASE sc.delivery_method
														 WHEN 21301 THEN 750
														 WHEN 21303 THEN 750
														 WHEN 21304 THEN 751
														 WHEN 21302 THEN 751
														 WHEN 21305 THEN 751
														 WHEN 21306 THEN 750
														 ELSE 751
													END,
								@delivery_method = sc.delivery_method
						FROM   source_counterparty sc
						WHERE  sc.source_counterparty_id = @selected_counterparty_id
					END
					ELSE
					BEGIN
						SELECT DISTINCT @email_address = STUFF((Select ','+user_emal_add
						FROM 
								(SELECT user_emal_add FROM application_users au
								INNER JOIN dbo.SplitCommaSeperatedValues(@notify_users) a ON au.user_login_id = a.item
								UNION ALL
								SELECT user_emal_add FROM application_role_user aru
								INNER JOIN application_users au ON au.user_login_id = aru.user_login_id
								INNER JOIN dbo.SplitCommaSeperatedValues(@notify_roles) a ON aru.role_id = a.item) a
						FOR XML PATH('')),1,1,'') 
						
					END
			
					SET @email_attachment = CASE WHEN @notification_type IN (750,752) THEN 'y' ELSE 'n' END
					--IF @delivery_method <> 21302
					--BEGIN
			
						IF @send_option = 'y' AND @email_address IS NOT NULL
						BEGIN
									
							INSERT INTO batch_process_notifications (user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, holiday_calendar_id, non_sys_user_email, bcc_email, cc_email)	
							SELECT NULL,
								   NULL,
								   @unique_process_id,
								   @notification_type,
								   @email_attachment,
								   CASE WHEN @freq_type IS NULL THEN 'n' ELSE 'y' END,
								   @export_csv_path,
								   @holiday_calendar_id,
								   @email_address,
								   @bcc_emails,
								   @cc_emails
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
						LEFT JOIN application_users au ON au.user_login_id = a.item
						WHERE @notify_users IS NOT NULL AND au.user_active = 'y'
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
					--END
					IF @send_option = 'n' AND @non_system_users IS NULL
					BEGIN
						INSERT INTO process_settlement_invoice_log(process_id, code, module, counterparty_id, prod_date, [description], nextsteps, invoice_id)
						SELECT @error_process_id, 'Error', 'Send Invoices', @selected_counterparty_id, GETDATE(), 'Invoice nr.<b>' + @invoice_number + '</b> Email address not defined.', 'Please define email address to send email.', @email_calc_id
					END
			
					--PRINT '@@notification_type - ' + CAST(@notification_type AS VARCHAR)
					--IF @delivery_method = 21305 OR @delivery_method = 21302
					--BEGIN
					--	INSERT INTO batch_process_notifications (user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, holiday_calendar_id, non_sys_user_email)
					--	SELECT @user_login_id,
					--		   NULL,
					--		   @unique_process_id,
					--		   @notification_type,
					--		   @email_attachment,
					--		   CASE WHEN @freq_type IS NULL THEN 'n' ELSE 'y' END,
					--		   @export_csv_path,
					--		   @holiday_calendar_id,
					--		   NULL	
					--END		
					DECLARE @email_footer VARCHAR(MAX)
					DECLARE @subject VARCHAR(2000)
										
					SET @batch_process_id = dbo.FNAGetNewID() + '_' + @unique_process_id
					SET @job_name = 'report_batch' + '_' + @batch_process_id
					
					IF @for_message_board = 0
					BEGIN
						EXEC spa_message_board 'i', @user_login_id, NULL, 'Send Invoice', 'Batch process scheduled.', NULL, NULL, 's', @job_name, NULL, @unique_process_id, NULL, 'n'
			
						--PRINT('EXEC spa_message_board ''i'', ''' + @user_login_id + ''', NULL, ''Send Invoice'', ''Batch process scheduled.'', NULL, NULL, ''s'',''' + @job_name + ''', NULL, ''' + @unique_process_id + ''', NULL, ''n''')
					END
					
					DECLARE @email_configuration_id INT

					SELECT @email_configuration_id = aec.admin_email_configuration_id
					FROM admin_email_configuration aec
					LEFT JOIN contract_group cg ON cg.contract_email_template = aec.admin_email_configuration_id
					LEFT JOIN calc_invoice_volume_variance civv ON civv.contract_id = cg.contract_id
					WHERE civv.calc_id = @email_invoice_id
					
					DECLARE @prod_date_month VARCHAR(100)
					DECLARE @prod_date_year VARCHAR(100)
					SET @prod_date_year = DATEPART(yyyy,@prod_date)
					SET @prod_date_month = SUBSTRING(DATENAME(mm,@prod_date),1,3)

					IF @email_configuration_id IS NULL
						SELECT @email_configuration_id = admin_email_configuration_id FROM admin_email_configuration WHERE module_type = 17804 --AND default_email = 'y'

					--SET @report_file = @selected_counterparty_name +'_'+ @prod_date_month + @prod_date_year +'_'+CASE WHEN @is_netting = 'n' THEN CASE WHEN @invoice_type = 'i' THEN 'Invoice' ELSE 'Payment advice' END ELSE 'Netting' END +'_'+ CAST(@invoice_number AS VARCHAR(20)) + '.pdf'
					SET @report_file = @selected_counterparty_name +'_'+ @prod_date_month + @prod_date_year +'_'+CASE WHEN @is_netting = 'n' THEN CASE WHEN @invoice_type = 'i' THEN 'Invoice' ELSE 'Remittance ' END ELSE 'Netting' END +'_'+ CASE WHEN @is_netting = 'n' THEN CAST(@invoice_number AS VARCHAR(20)) ELSE '-' + CAST(@invoice_number AS VARCHAR(20)) END  + '.pdf'
					SELECT  @subject = email_subject, @email_description = email_body from admin_email_configuration aec  WHERE aec.module_type = 17804 AND admin_email_configuration_id = @email_configuration_id
					SET  @subject = replace(@subject,'[invoice_number]', CAST(@invoice_number AS VARCHAR(20)))
					SET  @subject = replace(@subject,'[prod_date]', @prod_date )
					IF @is_netting = 'y'
						SET  @subject = @subject + '-Netting'
					SET @email_description = dbo.FNAURLDecode(@email_description)
					SET  @email_description = replace(@email_description, '[invoice_contact]', ISNULL(@invoice_contact, ''))
					SET  @email_description = replace(@email_description, '[invoice_type]', CASE WHEN @is_netting = 'n' THEN CASE WHEN @invoice_type = 'i' THEN 'Invoice statement' ELSE 'Payment advice' END ELSE 'Netting statement' END )
					SET  @email_description = replace(@email_description,'[prod_date]', @prod_date )
					SET  @email_description = replace(@email_description,'[invoice_number]', CAST(@invoice_number AS VARCHAR(20)))
			
					SELECT @email_footer = aec.email_footer FROM admin_email_configuration aec WHERE aec.module_type = 17804 AND admin_email_configuration_id = @email_configuration_id
			
					IF @email_footer IS NOT NULL
						SET @email_description = @email_description + '<br />' + @email_footer
			
					/*SET @filter = '"source_deal_header_id:NULL;deal_date_from:' + @as_of_date + 
								  ';deal_date_to:' + @as_of_date + ';counterparty_id:' + CAST(@selected_counterparty_id AS VARCHAR(10)) + 
								  ';prod_month:' + @prod_date + ';contract_id:' + CAST(@selected_contract_id AS VARCHAR(10)) + 
								  ';save_invoice_id:' + CAST(@email_invoice_id AS VARCHAR(10)) + ';report_type:' + @report_type + ';invoice_type:' + @invoice_type + ';netting_group_id:' + ISNULL(@netting_group_id, 'NULL')+ ';settlement_date:' + ISNULL(@settlement_date, 'NULL') + CASE WHEN @is_netting = 'y' THEN ';statement_type:21502' ELSE '' END +'"'
					*/
					/***Added file creation datetime for consistency and made callfrom at spa_export_report_job only to be used for email separate and email aggregate.*****/
					DECLARE @file_creation_datatime VARCHAR(200)
					DECLARE @export_extension VARCHAR(10)
					SET @export_extension = '.' + REVERSE(LEFT(REVERSE(@report_file),CHARINDEX('.',REVERSE(@report_file))-1))
					
					SET @file_creation_datatime = '_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 120), ':', ''), ' ', '_'), '-', '_') + @export_extension
					
					--SET @report_file	= REPLACE(@report_file, @export_extension, @file_creation_datatime)
					
					/*********/
					
					SET @filter = 'invoice_ids:' + CAST(@email_invoice_id AS VARCHAR(10))
					SET @parameter = REPLACE(@reporting_param, 'Invoice Report Template.pdf', @report_file)
					SET @parameter = REPLACE(@parameter, 'Invoice Report Template', @report_name) + @filter

					/**********/
					
					declare @exist_invoice_file_path varchar(2000)
					declare @exist_netting_file_path varchar(2000)
					SET @exist_invoice_file_path = REPLACE(@report_file_path, '\temp_Note/', '\invoice_docs\');
					SET @exist_invoice_file_path = REPLACE(@exist_invoice_file_path, 'Invoice Report Template.pdf', @invoice_file_name);
										
					SET @exist_netting_file_path = REPLACE(@report_file_path, '\temp_Note/', '\invoice_docs\');
					SET @exist_netting_file_path = REPLACE(@exist_netting_file_path, 'Invoice Report Template.pdf', @netting_file_name);
										
					DECLARE @output_file_not INT
					DECLARE @output_file_netting_not INT
					DECLARE @new_report_file_paths_for_agg VARCHAR(2000)
					--DECLARE @cmdstr VARCHAR(4000)
					--SET @cmdstr = 'dir "' + @exist_invoice_file_path + '" /B'					
					--EXEC @output_file_not = MASTER..xp_cmdshell @cmdstr, NO_OUTPUT
					
					--SET @cmdstr = 'dir "' + @exist_netting_file_path + '" /B'					
					--EXEC @output_file_netting_not = MASTER..xp_cmdshell @cmdstr, NO_OUTPUT
					
					SELECT @output_file_not = dbo.FNAFileExists(@exist_invoice_file_path)
					SELECT @output_file_netting_not = dbo.FNAFileExists(@exist_netting_file_path)
					
					SET @exist_invoice_file_path = ISNULL(@exist_invoice_file_path, '')
					SET @exist_netting_file_path = ';' + @exist_netting_file_path
					SET @exist_netting_file_path = ISNULL(@exist_netting_file_path, '')
					
					IF @output_file_not = 0
					BEGIN
						IF @output_file_netting_not = 0 AND @delivery_method = 21306
							SET @new_report_file_paths_for_agg = @exist_invoice_file_path + @exist_netting_file_path
						ELSE 
							SET @new_report_file_paths_for_agg = @exist_invoice_file_path
					END
					ELSE
						SET @new_report_file_paths_for_agg = NULL
					/**********/
										
					SET @cursor_count = @cursor_count + 1;
					--SELECT @cursor_count 't1', @cursor_totalcount 't2' 
					IF (@email_agg_exists = 1)
					BEGIN
						IF @new_report_file_paths_for_agg IS NOT NULL
						begin
							SET @report_file_paths_for_agg = @new_report_file_paths_for_agg + ';'
							SET @report_file = @invoice_file_name
						end
						ELSE	
						begin
							IF @output_file_netting_not = 0	 AND @delivery_method = 21306					
								SET @report_file_paths_for_agg =  REPLACE(@report_file_path, 'Invoice Report Template.pdf', @report_file) + @exist_netting_file_path + ';'
							ELSE
								SET @report_file_paths_for_agg =  REPLACE(@report_file_path, 'Invoice Report Template.pdf', @report_file) + ';'
						end
						SET @sql = 'EXEC spa_rfx_export_report_job @report_param=''' + @parameter + ''', @proc_desc=''Send Invoice'' , @user_login_id=''farrms_admin'', @report_RDL_name=''' + @report_folder + @report_name + ''', @report_file_name=''' + @report_file+ ''', @report_file_full_path=''%REPORT_FILE%'', @process_id=''' + @batch_process_id + ''', @email_description=''' + @email_description + ''',@email_subject=''' + @subject + ''',@is_aggregate=%IS_AGGREGATE%,@call_from_invoice=''call_from_invoice''' 
						insert into #tmp_list_email_agg (invoice_id, process_id, email_address, cc_emails, bcc_emails, file_path, sql_string)
							select @email_invoice_id, @batch_process_id, @email_address, isnull(@cc_emails, ''), isnull(@bcc_emails,''), @report_file_paths_for_agg, @sql

						SET @sql = ''
					END			
					ELSE
					BEGIN
						IF @new_report_file_paths_for_agg IS NOT NULL AND @new_report_file_paths_for_agg <> ''
						begin
							SET @report_file = @invoice_file_name
							SET @sql = 'EXEC spa_rfx_export_report_job @report_param=''' + @parameter + ''', @proc_desc=''Send Invoice'' , @user_login_id=''farrms_admin'', @report_RDL_name=''' + @report_folder + @report_name + ''', @report_file_name=''' + @report_file+ ''', @report_file_full_path=''' + REPLACE(@new_report_file_paths_for_agg, 'Invoice Report Template.pdf', @report_file) + ''', @process_id=''' + @batch_process_id + ''', @email_description=''' + @email_description + ''', @email_subject=''' + @subject + ''',@is_aggregate=2, @call_from_invoice=''call_from_invoice'', @output_file_format=''PDF'''
						end
						ELSE
						BEGIN
							IF @output_file_netting_not = 0 AND @delivery_method = 21306
								SET @sql = 'EXEC spa_rfx_export_report_job @report_param=''' + @parameter + ''', @proc_desc=''Send Invoice'' , @user_login_id=''farrms_admin'', @report_RDL_name=''' + @report_folder + @report_name + ''', @report_file_name=''' + @report_file+ ''', @report_file_full_path=''' + REPLACE(@report_file_path, 'Invoice Report Template.pdf', @report_file) + @exist_netting_file_path + ''', @process_id=''' + @batch_process_id + ''', @email_description=''' + @email_description + ''', @email_subject=''' + @subject + ''',@is_aggregate=0,@call_from_invoice=''call_from_invoice'', @output_file_format=''PDF'''
							ELSE
								SET @sql = 'EXEC spa_rfx_export_report_job @report_param=''' + @parameter + ''', @proc_desc=''Send Invoice'' , @user_login_id=''farrms_admin'', @report_RDL_name=''' + @report_folder + @report_name + ''', @report_file_name=''' + @report_file+ ''', @report_file_full_path=''' + REPLACE(@report_file_path, 'Invoice Report Template.pdf', @report_file) + ''', @process_id=''' + @batch_process_id + ''', @email_description=''' + @email_description + ''', @email_subject=''' + @subject + ''',@is_aggregate=0,@call_from_invoice=''call_from_invoice'', @output_file_format=''PDF'''
						end 	
					END
					--PRINT(ISNULL(@sql, 'isnull'))
					EXEC(@sql)
												
					--IF NOT EXISTS(SELECT 1 FROM process_settlement_invoice_log WHERE process_id = @error_process_id AND counterparty_id = @selected_counterparty_id AND code = 'Error')
			
					IF  @email_address IS NOT NULL  OR @send_option = 'n'
					BEGIN
						DECLARE  @detail_url varchar(8000)
						DECLARE  @detail_description varchar(8000)
						DECLARE @invoice_netting VARCHAR(10) = 'Invoice'
						IF @is_netting = 'y' AND @delivery_method = 21306
						BEGIN
							SET @invoice_number = @invoice_number * -1
							SET @invoice_netting = 'Netting'
							SET @email_calc_id = @email_calc_id * -1
						END
						SET @detail_url = './spa_html.php?__user_name__=''' + @user_login_id + '''&spa=exec spa_invoice_email_log ''' + @error_process_id + ''',''' + @user_login_id + ''', ''d'', ''' + @subject +''''
						SET @detail_description = '<a target="_blank" href="' + @detail_url + '">Invoice email sent successfully for ' + @invoice_netting + ' nr. ' + + CAST(@invoice_number AS VARCHAR(20)) + '.</a>'
						
						IF @delivery_method_cpty <> 0
						BEGIN	
							INSERT INTO process_settlement_invoice_log(process_id, code, module, counterparty_id, prod_date, [description], nextsteps, invoice_id)
							SELECT @error_process_id, 'Success', 'Send Invoices', @selected_counterparty_id, GETDATE(), @detail_description, 'N/A.', @email_calc_id
				        END
						
						INSERT INTO  invoice_email_log(process_id, mail_to, cc_mail, bcc_mail, email_subject, invoice_number, email_description)
						SELECT  @error_process_id, case when NULLIF(@non_system_users, '') IS NULL then @email_address ELSE @non_system_users END, @cc_emails, @bcc_emails, @subject, @email_calc_id, @email_description
						
					END	
													
					FETCH NEXT FROM email_invoice
					INTO @email_invoice_id	
				END
				CLOSE email_invoice
				DEALLOCATE email_invoice
		
			SET @for_message_board = 1
		
		FETCH NEXT FROM ctpty_email_invoice
			INTO @ctpty_email_invoice_rowid	
		END
		CLOSE ctpty_email_invoice
		DEALLOCATE ctpty_email_invoice

		/********For Email Aggregate*****/
		if exists(select 1 from #tmp_list_email_agg)
		begin
			DECLARE cur_email_agg CURSOR FOR
			SELECT email_address, cc_emails, bcc_emails FROM #tmp_list_email_agg group by email_address, cc_emails, bcc_emails

			DECLARE @agg_email_address varchar(100)
			DECLARE @agg_cc_emails varchar(500)
			DECLARE @agg_bcc_emails varchar(500)
			DECLARE @inner_invoice_id INT
			DECLARE @inner_cursor_count INT = 0
			DECLARE @inner_cursor_totalcount INT = 0
			DECLARE @inner_report_file_paths_for_agg VARCHAR(2000) = ''
			DECLARE @inner_report_file_path VARCHAR(1000) = ''

			OPEN cur_email_agg
			FETCH NEXT FROM cur_email_agg
			INTO @agg_email_address,  @agg_cc_emails, @agg_bcc_emails
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @inner_cursor_totalcount = COUNT(1) FROM #tmp_list_email_agg WHERE email_address = @agg_email_address  AND isnull(cc_emails,'') = @agg_cc_emails AND isnull(bcc_emails,'') = @agg_bcc_emails			
				--SELECT * FROM #tmp_list_email_agg WHERE email_address = @agg_email_address AND isnull(cc_emails,'') = @agg_cc_emails AND isnull(bcc_emails,'') = @agg_bcc_emails

				DECLARE inner_cur_email_agg CURSOR FOR
				SELECT invoice_id FROM #tmp_list_email_agg WHERE email_address = @agg_email_address AND isnull(cc_emails,'') = @agg_cc_emails AND isnull(bcc_emails,'') = @agg_bcc_emails
				
				SET @inner_report_file_paths_for_agg = '';
				SET @inner_cursor_count = 0;
				
				OPEN inner_cur_email_agg
				FETCH NEXT FROM inner_cur_email_agg
				INTO @inner_invoice_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @inner_cursor_count = @inner_cursor_count + 1;
					IF (@inner_cursor_count = @inner_cursor_totalcount)
					BEGIN
						SELECT @inner_report_file_path = file_path from #tmp_list_email_agg WHERE invoice_id  = @inner_invoice_id
						SET @inner_report_file_paths_for_agg = @inner_report_file_paths_for_agg + @inner_report_file_path	
						SET @inner_report_file_paths_for_agg = LEFT(@inner_report_file_paths_for_agg, LEN(@inner_report_file_paths_for_agg) - 1)					
						SELECT @sql = REPLACE(REPLACE(sql_string,'%REPORT_FILE%',@inner_report_file_paths_for_agg), '%IS_AGGREGATE%','2') from #tmp_list_email_agg where invoice_id = @inner_invoice_id						
					END
					ELSE
					BEGIN
						SELECT @inner_report_file_path = file_path from #tmp_list_email_agg WHERE invoice_id  = @inner_invoice_id
						SET @inner_report_file_paths_for_agg = @inner_report_file_paths_for_agg + @inner_report_file_path
						SELECT @sql = REPLACE(REPLACE(sql_string,'%REPORT_FILE%',@inner_report_file_path), '%IS_AGGREGATE%','1') from #tmp_list_email_agg where invoice_id = @inner_invoice_id
					END
					--select @inner_report_file_path
					EXEC(@sql)
					FETCH NEXT FROM inner_cur_email_agg
					INTO @inner_invoice_id	
				END
				CLOSE inner_cur_email_agg
				DEALLOCATE inner_cur_email_agg

				FETCH NEXT FROM cur_email_agg
				INTO @agg_email_address,  @agg_cc_emails, @agg_bcc_emails	
			END
			CLOSE cur_email_agg
			DEALLOCATE cur_email_agg
		end
		-- END mark 1----	


				--Update Invoice Status
				UPDATE  civv
				SET civv.invoice_status = 20700
				FROM Calc_invoice_Volume_variance civv
				INNER JOIN dbo.SplitCommaSeperatedValues(@invoice_ids) a ON a.item = civv.calc_id		
				WHERE civv.invoice_status = 20706
		
				UPDATE  civv
				SET civv.status_id = 20700
				FROM counterpartyt_netting_stmt_status civv
				INNER JOIN dbo.SplitCommaSeperatedValues(@invoice_ids) a ON a.item = civv.calc_id		
				WHERE civv.status_id = 20706
		
				INSERT INTO counterpartyt_netting_stmt_status(calc_id, status_id) 
				SELECT a.item, 20700
				FROM dbo.SplitCommaSeperatedValues(@invoice_ids) a
				LEFT JOIN counterpartyt_netting_stmt_status civv ON civv.calc_id = a.item
				WHERE civv.calc_id IS NULL AND civv.status_id = 20706
				-- End Update Invoice Status
		
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
				IF EXISTS (SELECT 1 FROM #temp_emailing_invoices)
				BEGIN
					SET @url = './dev/spa_html.php?__user_name__=''' + @user_login_id + '''&spa=exec spa_get_settlement_invoice_log ''' + @error_process_id + ''''
					SET @description = '<a target="_blank" href="' + @url + '">Invoice Emailed.' + ISNULL(@error_warning, '') + '</a>'
					IF @save_invoice <> 'y'
					EXEC spa_message_board 'u', @user_login_id, NULL, 'Email Invoices', @description, '', '', @error_success, @emailing_job  	
				END
				ELSE IF EXISTS(SELECT 1 FROM #temp_delivery_methods_missing_counterparties)
				BEGIN
					SET @emailing_job = 'send_invoices_' + @error_process_id
					SET @url = './dev/spa_html.php?__user_name__=''' + @user_login_id + '''&spa=exec spa_get_settlement_invoice_log ''' + @error_process_id + ''''
					SET @description = '<a target="_blank" href="' + @url + '">Invoice sent.' + ISNULL(@error_warning, '') + '</a>'
					EXEC spa_message_board 'i', @user_login_id, NULL, 'Send Invoices', @description, '', '', @error_success, @emailing_job 
				END			 
		
		
		IF @save_invoice = 'n'
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
 IF @flag = 'f'
 BEGIN	
 	BEGIN TRY
 		IF @process_table_name IS NOT NULL
 		BEGIN
 			IF OBJECT_ID('tempdb..#calc_id_for_sending_mail') IS NOT NULL
 			    DROP TABLE #calc_id_for_sending_mail
 			
 			CREATE TABLE #calc_id_for_sending_mail (calc_id INT)
 			EXEC ('INSERT INTO #calc_id_for_sending_mail (calc_id) SELECT calc_id FROM ' + @process_table_name)
 			SELECT @invoice_ids = COALESCE(@invoice_ids + ', ' , '') + cast(calc_id AS VARCHAR(20)) FROM  #calc_id_for_sending_mail
 		END
 		
 		--update status of invoice - status updated only when its prior status is Ready To Send
 		UPDATE civv2
 		SET    civv2.invoice_status = 20700
 		FROM   Calc_invoice_Volume_variance civv2
 		LEFT JOIN static_data_value sdv ON  sdv.value_id = civv2.invoice_status
 		WHERE  calc_id IN (SELECT item FROM   dbo.SplitCommaSeperatedValues(@invoice_ids)) AND sdv.value_id = 20706
 
 		--update status of netting - status updated only when its prior status is Ready To Send
 		UPDATE cnss
 		SET    cnss.status_id = 20700
 		FROM   counterpartyt_netting_stmt_status cnss
 		LEFT JOIN static_data_value sdv ON  sdv.value_id = cnss.status_id
 		WHERE  calc_id IN (SELECT item FROM   dbo.SplitCommaSeperatedValues(@invoice_ids)) AND sdv.value_id = 20706
 		
 		EXEC spa_ErrorHandler 0
 			, 'print_invoice'
 			, 'spa_print_invoices'
 			, 'Success'
 			, 'Invoice status updated.'
 			, ''
 	END TRY
 	BEGIN CATCH
 		EXEC spa_ErrorHandler -1
 			, 'print_invoice'
 			, 'spa_print_invoices'
 			, 'Error'
 			, 'Invoice status update fail.'
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
 		--SET @job_name = 'report_batch_' + @process_id
 		
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
 		
 		
 		SET @build_sp = 'spa_print_invoices ''''e'''',
 						' + ISNULL('''''' + @invoice_ids + '''''', 'NULL') + ',NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 						''''' + @reporting_param + ''''',
 						''''' + @report_file_path + ''''',NULL,
 						' + ISNULL('''''' + @notify_users + '''''', 'NULL') + ', 
 						' + ISNULL('''''' + @notify_roles + '''''', 'NULL') + ',
 						' + ISNULL('''''' + @export_csv_path + '''''', 'NULL') + ',
 						' + ISNULL('''''' + @non_system_users + '''''', 'NULL') + ',
 						' + ISNULL('''''' + @send_option + '''''', 'NULL') + ',
 						' + ISNULL('' + CAST(@delivery_method AS VARCHAR(10)) + '', 'NULL') + ',NULL,
 						' + ISNULL('' + CAST(@holiday_calendar_id AS VARCHAR(10)) + '', 'NULL') + ',
 						' + ISNULL('' +  CAST(@freq_type AS VARCHAR(10)) + '', 'NULL') + ', NULL, NULL, NULL, NULL, NULL,
 						' + ISNULL('''''' + @printer_name + '''''', 'NULL') + ',
 						' + ISNULL('''''' + @report_folder + '''''', 'NULL') + ', NULL, NULL, 
 						' + ISNULL('''''' + @process_table_name + '''''', 'NULL') + ',' + ISNULL('''''' + @save_invoice + '''''', 'NULL') + ', ' + ISNULL('''''' + @batch_process_id + '''''', 'NULL') + ''
 		
 		SET @job_name = 'print_invoice_' + @process_id
 		
 		IF @freq_type IS NULL 
 		BEGIN	
 			SET @sql = 'exec spa_run_sp_as_job ''' + @job_name + ''', ''' + @build_sp + ''', ''Print Invoices'', ''' + @user_login_id + ''''
 			--PRINT ISNULL(@sql, '@sql IS NULL')
 			EXEC(@sql)
 			
			EXEC spa_ErrorHandler 0
 				, 'print_invoice'
 				, 'spa_print_invoices'
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
 						 'Print Invoice',
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
 				, 'print_invoice'
 				, 'spa_print_invoices'
 				, 'Success'
 				, 'Report Sending job started.'
 				, ''
 		END	
 		
 	END TRY
 	BEGIN CATCH
		IF @save_invoice = 'n'
 		EXEC spa_ErrorHandler -1
 			, 'print_invoice'
			, 'spa_print_invoices'
			, 'Error'
			, 'Invoice status update fail.'
			, ''
	END CATCH
END
