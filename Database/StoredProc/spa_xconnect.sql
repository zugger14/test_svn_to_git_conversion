IF OBJECT_ID('spa_xconnect') IS NOT NULL
    DROP PROC dbo.[spa_xconnect]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
 * Description : TRMTracker XConnect misc operations
 * Param Description :
		@flag : Possible values 
			  1. default_configuration	  => Retrive list of interface
			  2. exchange_configuration	  => Exchange specific configuration which will override default configuration, Reterived from interface configuration detail.
			  3. m						  => XConnect tag definition based on interface assembly type
			  4. i						  => Run import process
			  5. ixp_security_definition  => Run security definition import rule
			  6. l						  => Maintain log based trade rejection
			  7. get_exchange_list		  => Get list of active exchange from interface configuration detail
			  8. duplicate_trade		  => Identify if trade is duplicate or not
			  9. send_email				  => Send email

		@exchange_name				: Exchange name setup in interface configuration detail
		@exchange_type				: Exchange inter face type value 0 = QuickFix, 1 = EpexSpot, 2 = TrayPort 
		@process_id					: process id
		@message_log				: message log to be catpure in fix_message_log table
		@subject					: email subject
		@email_message_body			: email message body
		@unique_execution_id		: used for trade rejection : unique execution id based on interface type derived from XConnect
		@transaction_timestamp		: used for trade rejection : trade transaction time stamp based on interface type derived from XConnect
		@buy_sell_flag				: used for trade rejection : Trade Buy / Sell based on interface type derived from XConnect
		@term_start					: used for trade rejection : Trade Term Start based on interface type derived from XConnect
		@term_end					: used for trade rejection : Trade Term End based on interface type derived from XConnect

 */

CREATE PROC dbo.[spa_xconnect]
@flag VARCHAR(100),
@exchange_name VARCHAR(100) = NULL,
@exchange_type VARCHAR(100) = NULL,
@process_id VARCHAR(255) = NULL,
@message_log NVARCHAR(MAX) = NULL,
@subject VARCHAR(2000) = NULL,
@email_message_body NVARCHAR(MAX) = NULL,
@unique_execution_id VARCHAR(1000) = NULL,
@transaction_timestamp VARCHAR(50) = NULL,
@buy_sell_flag VARCHAR(50) = NULL,
@term_start VARCHAR(20) = NULL,
@term_end VARCHAR(20) = NULL
AS 
BEGIN
	SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())
	DECLARE @sql VARCHAR(MAX), @role_ids VARCHAR(1024) 
	IF @flag = 'default_configuration'
	BEGIN
		SELECT ic.configuration_type [Type], ic.variable_name [Key], ic.variable_value [Value] 
		FROM interface_configuration ic
		INNER JOIN static_data_value sdv ON ic.interface_id = sdv.value_id
		WHERE sdv.[type_id] = 109900 AND sdv.code = @exchange_type
	END
	--	Exchange specific configuration which will override default configuration.
	ELSE IF @flag = 'exchange_configuration'
	BEGIN
		SELECT 
			user_login_id
			, dbo.FNADecrypt([password]) [password]
			, sender_comp_id [SenderCompID]
			, sender_sub_id [SenderSubID]
			, target_comp_id [TargetCompID]
			, ISNULL(session_qualifier, 0) [SessionQualifier]
			--, ISNULL(reject_duplicate_trade, 0) [RejectDuplicateTrade]
		FROM interface_configuration_detail ic
		WHERE ic.interface_name = @exchange_name
	END
	ELSE IF @flag ='m'
	BEGIN
	--	Retrives fix tag mapping configuration for trade catpure report
		SET @sql = '
		SELECT gmv.clm1_value [TagId], gmv.clm2_value [TagFieldName], gmv.clm3_value [ConditionalTag], gmv.clm4_value [TableFieldName], gmv.clm5_value [Level] from generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id
		WHERE mapping_name = ''XConnect Tag Definition'''
		SET @sql += CASE 
						WHEN @exchange_type = '0' THEN ' AND gmv.clm5_value IN (''1'',''2'',''3'',''4'',''5'',''6'',''12'') ' -- Fix trade capture report tags
						WHEN @exchange_type = '2' THEN ' AND gmv.clm5_value IN (''7'') '  -- Trayport trades virtual tags
						WHEN @exchange_type = '3' THEN ' AND gmv.clm5_value IN (''8'',''9'',''10'',''11'',''13'') '-- ICE security definition tags
						ELSE '' 
					END

		EXEC (@sql)
		
	END
	ELSE IF @flag = 'tagmapping'
	BEGIN
		--	Query refers to generic mapping user defined fields template
		SELECT [id],[value]
		FROM
		  (SELECT 1 [id], 'Trade Capture Report' [Value]
			   UNION SELECT 2 [id], 'Sides' [Value]
			   UNION SELECT 3 [id], 'Party Id' [Value]
			   UNION SELECT 4 [id], 'Legs Group' [Value]
			   UNION SELECT 5 [id], 'Nested Party Id' [Value]
			   UNION SELECT 6 [id], 'Nested Party Role' [Value]
			   UNION SELECT 7 [id], 'Trayport Trades' [Value]
			   UNION SELECT 8 [id], 'SecurityDefinition' [Value]
			   UNION SELECT 9 [id], 'SecurityDefinition.NoUnderlyings' [Value]
			   UNION SELECT 10 [id], 'SecurityDefinition.NoUnderlyings.NoUnderlyingSecurityAltID' [Value]
			   UNION SELECT 11 [id], 'SecurityDefinition.NoUnderlyings.NoBlockDetails' [Value]
			   UNION SELECT 12 [id], 'NoNestedPartySubIDs' [Value]
			   UNION SELECT 13 [id], 'SecurityDefinition.NoLegs' [Value]
		   ) tbl
		ORDER BY 1
	END
	ELSE IF @flag IN('i','ixp_security_definition')
	BEGIN
		DECLARE @ixp_rules_id INT, @job_name NVARCHAR(255), @process_table_name VARCHAR(1000)

		SELECT @ixp_rules_id = ir.ixp_rules_id, @exchange_type = sdv.code, @role_ids = icd.user_role_ids FROM interface_configuration_detail icd
		INNER JOIN ixp_rules  ir ON icd.import_rule_hash = ir.ixp_rule_hash
		INNER JOIN static_data_value sdv ON sdv.value_id = icd.interface_id AND sdv.[type_id] = 109900
		WHERE icd.interface_name = @exchange_name

		SET @process_table_name =  '[adiha_process].dbo.[xconnect_' + @exchange_type + '_' + @process_id + ']'
		-- For security definition import rule 
		IF @flag = 'ixp_security_definition'
		BEGIN
			SELECT @ixp_rules_id = ir.ixp_rules_id FROM interface_configuration_detail icd
			INNER JOIN ixp_rules  ir ON icd.security_import_rule_hash = ir.ixp_rule_hash
			WHERE icd.interface_name = @exchange_name
		END
				
		SET @sql = ' spa_ixp_rules @flag = ''t'',@process_id = ''' + @process_id + ''',@ixp_rules_id =' + ISNULL(CAST(@ixp_rules_id AS VARCHAR), '0') + ',@run_table = ''' + @process_table_name + ''',@source = ''21400'',@run_with_custom_enable = ''n'',@run_in_debug_mode=''y'', @execute_in_queue=1'
		--print @sql
		SET @job_name = 'Import_' + REPLACE(@exchange_name, ' ', '_') + '_' +ISNULL(CAST(@ixp_rules_id AS VARCHAR), '0') + '_' + @process_id;
		DECLARE @user_login_id VARCHAR(255) = dbo.FNAAppAdminID()
		EXEC spa_run_sp_as_job  @job_name, @sql, @job_name,@user_login_id,NULL,NULL,'i'
	END
	ELSE IF @flag = 'l'
	BEGIN
		INSERT INTO fix_message_log (message_log, fix_type, unique_execution_id, transaction_timestamp, buy_sell_flag, term_start,term_end) VALUES (@message_log, @exchange_name, @unique_execution_id, @transaction_timestamp, @buy_sell_flag, @term_start, @term_end)

		--	Mark trade capture log as rejected
		DECLARE @fix_message_log_id NUMERIC(38, 0) = Ident_current('fix_message_log') 
		--	Check if trade has been already catpured 
		DECLARE @duplicate_rows BIGINT
		SELECT @duplicate_rows = COUNT(fml.fix_message_log_id) 
				  FROM   fix_message_log fml 
						 INNER JOIN interface_configuration_detail icd 
								 ON fml.fix_type = icd.interface_name 
				  WHERE  fml.unique_execution_id = @unique_execution_id 
						 AND fml.transaction_timestamp = @transaction_timestamp 
						 AND ISNULL(fml.buy_sell_flag, '') = @buy_sell_flag 
						 AND ISNULL(fml.term_start, '') = @term_start 
						 AND ISNULL(fml.term_end, '') = @term_end
						 AND fml.is_rejected IS NULL
						 AND ISNULL(icd.reject_duplicate_trade, 0) = 1

		IF (@duplicate_rows > 1) 
		  BEGIN 
			  UPDATE fml 
			  SET    is_rejected = 1 
			  FROM   fix_message_log fml 
					 INNER JOIN interface_configuration_detail icd 
							 ON fml.fix_type = icd.interface_name 
			  WHERE  fml.fix_message_log_id = @fix_message_log_id 
					 AND ISNULL(icd.reject_duplicate_trade, 1) = 1 
		  END 
	END
	ELSE IF @flag = 'get_exchange_list'
	BEGIN
		SELECT 
			sdv.code [Type]
			, icd.interface_name [Name]
			, CASE 
				WHEN icd.interface_type = 'QUICK FIX' THEN 0 
				WHEN icd.interface_type = 'EPEX SPOT' THEN 1 
				WHEN icd.interface_type = 'TRAYPORT' THEN 2 
				ELSE 3 
			END [AssemblyType]
			, ISNULL(reject_duplicate_trade, 0) [RejectDuplicateTrade]
		FROM interface_configuration_detail icd
			INNER JOIN static_data_value sdv ON icd.interface_id = sdv.value_id
		WHERE [type_id] = 109900 and is_active = 1
	END
	ELSE IF @flag = 'duplicate_trade'
	BEGIN
		SELECT TOP 1 fml.fix_message_log_id FROM fix_message_log fml
		INNER JOIN interface_configuration_detail icd ON fml.fix_type = icd.interface_name
		WHERE fml.unique_execution_id = @unique_execution_id 
			AND fml.transaction_timestamp = @transaction_timestamp 
			AND ISNULL(fml.buy_sell_flag, '') = @buy_sell_flag 
			AND ISNULL(fml.term_start, '') = @term_start 
			AND ISNULL(fml.term_end, '') = @term_end 
			AND ISNULL(icd.reject_duplicate_trade, 0) = 1
	END
	ELSE IF @flag = 'send_email'
	BEGIN
		DECLARE @trading_hours VARCHAR(100), @start_hour INT, @end_hour INT, @current_utc_hour INT, @email_sent_status VARCHAR(1) = 'y' 

		-- Get Trading hours configuration value for specific exchange 
		SELECT @trading_hours = ic.variable_value 
		FROM   interface_configuration ic 
			   INNER JOIN interface_configuration_detail icd 
					   ON ic.interface_id = icd.interface_id 
		WHERE  icd.interface_name = @exchange_name 
			   AND ic.variable_name LIKE '%TRADING_HOURS%' 
		
		SELECT @role_ids = icd.user_role_ids 
		FROM   interface_configuration_detail icd
		WHERE icd.interface_name = @exchange_name

		-- Parse Hours (Sample value 10-18) 
		SELECT @start_hour = TRY_CONVERT(int, dbo.Fnagetsplitpart(@trading_hours, '-', 1))
			   ,@end_hour = TRY_CONVERT(int, dbo.Fnagetsplitpart(@trading_hours, '-', 2)) 
			   ,@current_utc_hour = DATEPART(HOUR, GETUTCDATE()) 

		-- By Default email sent status will be y so these email will not processed 
		SET @email_sent_status = 'y'

		-- SELECT @start_hour [@start_hour], @end_hour [@end_hour] , @current_utc_hour [CurrentUTCHour] 
		-- Check for valid hour and check if current UTC hour is between the trading hours, these emails need to be processed
		-- Exchange name can be null when sevice spcefic email are sent later 
		-- If any configuration is missing related to trading start / end our ie. NULL , send the email 
		IF ((@start_hour IS NOT NULL AND @end_hour IS NOT NULL AND @current_utc_hour BETWEEN @start_hour AND @end_hour ) 
			  OR @exchange_name IS NULL 
			  OR @start_hour IS NULL 
			  OR @end_hour IS NULL ) 
		BEGIN 
			SET @email_sent_status = 'n' 
		END 
		-- Send email to Data Import Exception Group with Farrms fix protocol service email template
		SET @sql = 'spa_email_notes @flag =''b'', @email_module_type_value_id = 17813 , @send_status =''' + @email_sent_status + ''''
		SET @sql +=', @active_flag =''y'', @subject ='''+  @subject + ''', @template_params =''' + @email_message_body + ''''
		SET @sql += CASE WHEN @role_ids IS NOT NULL THEN ', @role_ids =''' + @role_ids + '''' ELSE ', @role_type_value_id =2' END
		--PRINT @sql
		EXEC(@sql)

	END	
END