IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ICE_interface]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ICE_Interface]
GO
SET ANSI_NULLS ON
GO
  
SET QUOTED_IDENTIFIER ON
GO
  
-- ===============================================================================================================
-- Author: ashrestha@pioneersolutionsglobal.com
-- Create date: 2017-01-03
-- Description: Calls ICE Interface CLR to import Deal and Security definition
  
-- Params:
-- @import_type CHAR(1)         - 1>Deal, 2>Security Definition
-- @as_of_date DATETIME			- Date
-- EXEC spa_ICE_Interface '1', '2017-01-01'
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_ICE_Interface]
	@flag CHAR(1) = 'g', -- 'g'-> Show in grid, 'i'-> import
	@import_type CHAR(1) = '1',
	@as_of_date DATETIME = NULL,
	@xml TEXT = NULL,
	@import_rule_id INT = NULL,
	@date_from DATETIME = NULL,
	@date_to DATETIME = NULL,
	@security_def_id VARCHAR(100)= NULL,
	@import_data_list VARCHAR(500) = NULL,
	@staging_deal_id VARCHAR(500) = NULL,
	@batch_process_id VARCHAR(250) ='assdasdasd123123123123qwd_afsasdasdasd',
	@batch_report_param VARCHAR(500) = NULL
AS

DECLARE @idoc INT

SET NOCOUNT ON

	DECLARE @process_id VARCHAR(100)
	DECLARE @process_table VARCHAR(500)
	DECLARE @user_id VARCHAR(100)
	DECLARE @sql VARCHAR(MAX)
	DECLARE @config_path VARCHAR(200)
	DECLARE @config_path1 VARCHAR(200)
	DECLARE @config_path2 VARCHAR(200)
	DECLARE @password VARCHAR(200)
	DECLARE @username VARCHAR(200)
	DECLARE @debug_mode CHAR(1)
--	DECLARE @security_def_id VARCHAR(100)
	DECLARE @rule_id INT 
	DECLARE @run_date VARCHAR(10)
	DECLARE @assembly_method VARCHAR(200)
	DECLARE @desc VARCHAR(500)
	DECLARE @job_name VARCHAR(250)

	DECLARE @url VARCHAR(8000)
	DECLARE @start_time DATETIME,@end_time  DATETIME
	---SET @security_def_id = '314'
	SET @debug_mode = '0'
	IF @batch_process_id IS NULL 
	BEGIN
		SET @process_id = REPLACE(newid(),'-','_')
	END
	ELSE 
		SET @process_id = @batch_process_id

	SET @user_id = dbo.FNADBUser()

	SELECT @username = [user_id] FROM ice_interface_settings ice
	SELECT @password = dbo.[FNADecrypt](user_password) FROM ice_interface_settings ice
	SELECT @config_path1 = REPLACE(ice.config_file,'\','\\') FROM ice_interface_settings ice
	SELECT @config_path2 = REPLACE(ice.log_file_path,'\','\\')  FROM ice_interface_settings ice

IF @flag = 'g'
BEGIN
	SELECT ice_interface_data_id, data_type, [description], import_rule_id FROM ice_interface_data
END
ELSE IF @flag = 'i' -- send request and import directly. 
BEGIN
	BEGIN TRY
		SELECT @start_time = GETDATE()
		IF @import_type = '1'
		BEGIN
		--
			SET @process_table = 'adiha_process.dbo.ICInterface_Staging'
		IF OBJECT_ID('adiha_process..ICInterface_Staging') IS NOT NULL
			DROP TABLE adiha_process.dbo.ICInterface_Staging
	
		SET @sql = '
			CREATE TABLE '+@process_table+' (
					trade_date VARCHAR(200)
					,trade_time VARCHAR(200)
					,deal_id VARCHAR(200)
					,leg VARCHAR(200)
					,orig_id VARCHAR(200)
					,buy_sell_flag VARCHAR(200)
					,product VARCHAR(200)
					,hub VARCHAR(200)
					,Strip VARCHAR(200)
					,term_start VARCHAR(200)
					,term_end  VARCHAR(200)
					,option_price VARCHAR(200)
					,strike_price VARCHAR(200)
					,strike2_price VARCHAR(200)
					,style VARCHAR(200)
					,counterparty VARCHAR(200)
					,price VARCHAR(200)
					,price_unit VARCHAR(200)
					,volume VARCHAR(200)
					,periods VARCHAR(200)
					,total_volume VARCHAR(200)
					,volume_uom VARCHAR(200)
					,trader VARCHAR(200)
					,memo VARCHAR(200)
					,clearing_venue VARCHAR(200)
					,user_id VARCHAR(200)
					,source VARCHAR(200)
					,usi VARCHAR(200)
					,authorized_trader_id VARCHAR(200)
					,pipeline VARCHAR(200)
					,state VARCHAR(200)
					,deal_status VARCHAR(200)
				)
			'
	
		EXEC(@sql)
			SELECT  @run_date = ISNULL(@run_date,CAST(GETDATE() AS DATE))
			EXEC [spa_TRMICEInterface] @run_date,@config_path1,@username,@password,@process_table,@config_path2,@debug_mode
			EXEC('DELETE b FROM '+@process_table +' a INNER JOIN  ice_deal_interface_staging b ON a.deal_id = b.deal_id ')
			EXEC('INSERT INTO ice_deal_interface_staging(trade_date,trade_time,deal_id,leg,orig_id,buy_sell_flag,product,hub,Strip,term_start,term_end,option_price,strike_price,strike2_price,style,counterparty,price,price_unit,volume,periods,total_volume,volume_uom,trader,memo,clearing_venue,user_id,source,usi,authorized_trader_id,pipeline,state,deal_status
) SELECT * FROM '+ @process_table )
			SET @process_table = 'ice_deal_interface_staging'
			EXEC spa_ixp_rules  @flag='t', @process_id=@process_id, @ixp_rules_id=@import_rule_id, @run_table=@process_table, @source = '21400', @run_with_custom_enable = 'n',@run_in_debug_mode='y'
		END
		ELSE IF @import_type = '2'
		BEGIN
		--SET @process_table = 'adiha_process.dbo.ICInterface_Staging'
		--	IF OBJECT_ID('adiha_process..ICInterface_Staging') IS NOT NULL
		--		DROP TABLE adiha_process.dbo.ICInterface_Staging
			
		-- SET @sql = ' CREATE TABLE '+@process_table+'(
		--		product_id VARCHAR(500), 
		--		exchange_name VARCHAR(500), 
		--		product_name VARCHAR(500), 
		--		granularity VARCHAR(500), 
		--		tick_value VARCHAR(500), 
		--		UOM VARCHAR(500), 
		--		hub_name VARCHAR(5000), 
		--		currency VARCHAR(500),
		--		cfi_code VARCHAR(500),
		--		hub_alias VARCHAR(500)
		--	) '
		--	EXEC('DELETE a FROM  ice_security_definition_staging a WHERE a.
			SET @process_table = 'ice_security_definition_staging'
			EXEC [spa_TRMICESecurityDefinition] @security_def_id,@config_path1,@username,@password,@process_table,@config_path2,@debug_mode
			EXEC spa_ixp_rules  @flag='t', @process_id=@process_id, @ixp_rules_id=@import_rule_id, @run_table=@process_table, @source = '21400', @run_with_custom_enable = 'n',@run_in_debug_mode='y'
		END
			
			INSERT INTO source_system_data_import_status(Process_id, code, module, source, type, description, recommendation, create_ts, create_user, rules_name,master_process_id) 
 						SELECT @process_id,
 							   'Success',
 							   'ICE Interface',
 							   CASE WHEN @import_type = 1 THEN ' ICE deal Interface ' ELSE ' ICE security Definition ' END ,
 							   'Success',
 								@desc,
 							   '',
							   GETDATE(),
							   dbo.FNAdbuser()
							   ,'ICE data information received.'
							   ,@batch_process_id

 					SET @job_name = 'Ice_'+@process_table + @process_id
 					SELECT @desc =  'ICE Interface - ' + CASE WHEN @import_type = 1 THEN ' ICE deal Interface ' ELSE ' ICE security Definition ' END + ' has been imported successfully.'
 				
					
					
					INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description])
					SELECT @batch_process_id, 'ICE Interface', 'Success', @desc 	

					SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_get_import_process_status ''' + @batch_process_id + ''','''+@user_id+''''
 					SELECT @end_time = GETDATE()
					SELECT @desc = '<a target="_blank" href="' + @url + '"><ul style="padding:0px;margin:0px;list-style-type:none;">' 
 							+ '<li style="border:none">Ice data import completed sucessfully.<br /> Ice Import Rule Executed:<ul style="padding:0px 0px 0px 10px;margin:0px 0px 0px 10px;list-style-type:square;"><ul/></li><li style="border:none">Elasped Time(s): ' + CAST(DATEDIFF(s,@start_time,@end_time) AS VARCHAR(100)) + '.</li>'
 					
					EXEC spa_message_board 'u', @user_id,  NULL, 'Ice Interface', @desc, '', '', 's',  @job_name, NULL, @batch_process_id, '', '', '', 'y'
					EXEC spa_ErrorHandler 0
						, 'spa_ICE_Interface'
						, 'spa_ICE_Interface'
						, 'Success'
						, 'Command executed Successfully.'
						, ''
	END TRY 
	BEGIN CATCH 
			EXEC spa_ErrorHandler 0
				, 'spa_ICE_Interface'
				, 'spa_ICE_Interface'
				, 'error'
				, 'Error while executing data.'
				, ''
	END CATCH	
END

-- Insert/Update ICE Interface Config
ELSE IF @flag = 'c'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#tmp_ice_interface_config') IS NOT NULL
			DROP TABLE #tmp_ice_interface_config
		
		SELECT	ID				[ID],
				environment		[environment],
				host			[host],
				port			[port],
				sender_comp_id	[sender_comp_id],
				sender_sub_id	[sender_sub_id],
				target_comp_id	[target_comp_id],
				[user_id]		[user_id],
				user_password	[user_password],
				config_file		[config_file],
				log_file_path	[log_file_path]
		INTO #tmp_ice_interface_config
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			ID				INT,
			environment		VARCHAR(500),
			host			VARCHAR(500),
			port			VARCHAR(100),
			sender_comp_id	VARCHAR(100),
			sender_sub_id	VARCHAR(100),
			target_comp_id	VARCHAR(100),
			[user_id]		VARCHAR(100),
			user_password	VARBINARY(5000),
			config_file		VARCHAR(500),
			log_file_path	VARCHAR(500)
		)
		
		
		INSERT INTO ice_interface_settings (
				environment,
				host,
				port,
				sender_comp_id,
				sender_sub_id,
				target_comp_id,
				[user_id],
				user_password,
				config_file,
				log_file_path
		)
		SELECT	environment,
				host,
				port,
				sender_comp_id,
				sender_sub_id,
				target_comp_id,
				[user_id],
				[dbo].[FNAEncrypt](user_password),
				config_file,
				log_file_path
		FROM #tmp_ice_interface_config
		WHERE ID = 0
		

		UPDATE iis
		SET	iis.environment = tmp.environment,
			iis.host = tmp.host,
			iis.port = tmp.port,
			iis.sender_comp_id = tmp.sender_comp_id,
			iis.sender_sub_id = tmp.sender_sub_id,
			iis.target_comp_id = tmp.target_comp_id,
			iis.[user_id] = tmp.[user_id],
			iis.user_password = CASE WHEN tmp.user_password = '' THEN iis.user_password ELSE [dbo].[FNAEncrypt](tmp.user_password) END,
			iis.config_file = tmp.config_file,
			iis.log_file_path = tmp.log_file_path

		FROM ice_interface_settings iis
		INNER JOIN #tmp_ice_interface_config tmp ON iis.ID = tmp.ID

	EXEC spa_ErrorHandler 0,
             'spa_ICE_interface',
             'spa_ICE_interface',
             'Success',
             'Changes has been succesfully saved.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'spa_ICE_interface',
             'spa_ICE_interface',
             'DB Error',
             'Failed to save.',
             ''
	END CATCH
END

-- Update the Import Rule
ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
		UPDATE ice_interface_data
		SET import_rule_id = @import_rule_id
		WHERE ice_interface_data_id = @import_type

	EXEC spa_ErrorHandler 0,
             'spa_ICE_interface',
             'spa_ICE_interface',
             'Success',
             'Changes has been succesfully saved.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'spa_ICE_interface',
             'spa_ICE_interface',
             'DB Error',
             'Failed to save.',
             ''
	END CATCH
END

-- Load the data in Process Grid for ICE Trade
ELSE IF @flag = 'p'
BEGIN
	
	IF @import_type = 1 
	BEGIN 
		SELECT  ID,CAST(REPLACE(trade_date,'-',' ') AS DATE)trade_date
				,CAST(REPLACE(trade_date,'-',' ') AS TIME)trade_time
				,deal_id
				,leg
				,product
				,term_start
				,term_end
				,option_price
				,total_volume
				,trader
				FROM ice_deal_interface_staging 
				WHERE create_ts  >=	ISNULL(NULLIF(@date_from,''),'1900-01-01')  AND create_ts < = ISNULL(NULLIF(@date_to,''),'3060-01-01') 
	END
END

-- Load the data in Process Grid for ICE Security Definition
ELSE IF @flag = 's'
BEGIN
	SELECT id,product_id,exchange_name,product_name,granularity,tick_value,hub_name,currency FROM ice_security_definition_staging 
	WHERE create_ts  >=	ISNULL(NULLIF(@date_from,''),'1900-01-01')  AND create_ts < = ISNULL(NULLIF(@date_to,''),'3060-01-01') 
END

-- Load the data in Error Grid
ELSE IF @flag = 'e'
BEGIN
IF @import_type = 1 
	SET @assembly_method = 'ImportIceDeal'
ELSE IF @import_type = 2 
	SET @assembly_method = 'ImportSecurityDefinition'
ELSE 
	SET @assembly_method = ''
SELECT clr_error_log_id,event_log_description,message,CAST(log_date AS DATE)log_date FROM clr_error_log WHERE assembly_method = @assembly_method  AND message like '%Exception%' AND
log_date  >=	ISNULL(NULLIF(@date_from,''),'1900-01-01')  AND log_date < = ISNULL(NULLIF(@date_to,''),'3060-01-01') 
ORDER BY 1 Desc 
	
END

ELSE IF @flag = 't' -- Select ICE security market type value
BEGIN
	SELECT sdv.code
		,sdv.description
	FROM Static_data_value sdv
	INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id
	WHERE sdt.type_id = '100800'
END
ELSE IF @flag = 'u'
BEGIN  
	SELECT @start_time = GETDATE()
	SELECT @import_rule_id = import_rule_id  FROM ice_interface_data WHERe ice_interface_data_id = @import_type
	IF NULLIF(@import_rule_id,0) IS NULL
	BEGIN 
		EXEC spa_ErrorHandler 0
						, 'spa_ICE_Interface'
						, 'spa_ICE_Interface'
						, 'Error'
						, 'Import rule should not be null or empty.'
						, ''
	END     
	IF OBJECT_ID('tempdb..#import_data_list') IS NOT NULL
		DROP TABLE #import_data_list
		CREATE TABLE #import_data_list(item INT)

	IF (@import_data_list IS NOT NULL OR @import_data_list !='')
	BEGIN
		INSERT INTO #import_data_list(item)
		SELECT item
			 FROM dbo.SplitCommaSeperatedValues(@import_data_list)
	END 
	ELSE 
	BEGIN
		IF @import_type = '1' 
		BEGIN
			INSERT INTO #import_data_list(item)
				SELECT id as item FROM  ice_deal_interface_staging
		END
		ELSE IF @import_type = '2'
		BEGIN	
			INSERT INTO #import_data_list(item)	
			SELECT id as item FROM  ice_security_definition_staging
		END
	END
	IF OBJECT_ID('adiha_process..ICInterface_Staging_import') IS NOT NULL
			DROP TABLE adiha_process.dbo.ICInterface_Staging_import
	
	IF @import_type = '1' 
	BEGIN
			SELECT * INTO  adiha_process.dbo.ICInterface_Staging_import 
				 FROM ice_deal_interface_staging a 
				INNER JOIN  #import_data_list b ON a.id = b.item 
	END
	ELSE IF @import_type = '2'
	BEGIN 
				SELECT * INTO  adiha_process.dbo.ICInterface_Staging_import  
					FROM ice_security_definition_staging a 
				INNER JOIN  #import_data_list b ON a.id = b.item 
	END
	SET  @process_table = 'adiha_process.dbo.ICInterface_Staging_import'
	
		EXEC spa_ixp_rules  @flag='t', @process_id=@process_id, @ixp_rules_id=@import_rule_id, @run_table=@process_table, @source = '21400', @run_with_custom_enable = 'n',@run_in_debug_mode='y'
			
		INSERT INTO source_system_data_import_status(Process_id, code, module, source, type, description, recommendation, create_ts, create_user, rules_name,master_process_id) 
 						SELECT @process_id,
 							   'Success',
 							   'ICE Interface',
 							   CASE WHEN @import_type = 1 THEN ' ICE deal Interface ' ELSE ' ICE security Definition ' END ,
 							   'Success',
 								@desc,
 							   '',
							   GETDATE(),
							   dbo.FNAdbuser()
							   ,'ICE data information received.'
							   ,@batch_process_id

 					SET @job_name = 'Ice_'+@process_table + @process_id
					
 					SELECT @desc =  'ICE Interface - ' + CASE WHEN @import_type = 1 THEN ' ICE deal Interface ' ELSE ' ICE security Definition ' END + ' has been imported successfully.'
 				
					
					
					INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description])
					SELECT @batch_process_id, 'ICE Interface', 'Success', @desc 	

					SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_get_import_process_status ''' + @batch_process_id + ''','''+@user_id+''''
 					SELECT @end_time = GETDATE()
					SELECT @desc = '<a target="_blank" href="' + @url + '"><ul style="padding:0px;margin:0px;list-style-type:none;">' 
 							+ '<li style="border:none">Ice data import completed sucessfully.<br /> Ice Import Rule Executed:<ul style="padding:0px 0px 0px 10px;margin:0px 0px 0px 10px;list-style-type:square;"><ul/></li><li style="border:none">Elasped Time(s): ' + CAST(DATEDIFF(s,@start_time,@end_time) AS VARCHAR(100)) + '.</li>'
 					
					EXEC spa_message_board 'u', @user_id,  NULL, 'Ice Interface', @desc, '', '', 's',  @job_name, NULL, @batch_process_id, '', '', '', 'y'
					EXEC spa_ErrorHandler 0
						, 'spa_ICE_Interface'
						, 'spa_ICE_Interface'
						, 'Success'
						, 'Command executed Successfully.'
						, ''
END
ELSE IF @flag = 'd'  -- Delete from ice_deal_interface_staging
BEGIN 
	BEGIN TRY
		If OBJECT_ID('tempdb..#deal_list') IS NOT NULL 
			DROP TABLE tempdb..#deal_list
		SELECT *
		INTO #delete_list
		FROM dbo.SplitCommaSeperatedValues(@staging_deal_id) a

		IF (@import_type = 1)  
		BEGIN
			DELETE ice
			FROM ice_deal_interface_staging ice
			INNER JOIN #delete_list dl ON dl.item = ice.id
		END 
		ELSE IF(@import_type  = 2)  
		BEGIN 
			DELETE ice
			FROM ice_security_definition_staging ice
			INNER JOIN #delete_list dl ON dl.item = ice.id
		END
		EXEC spa_ErrorHandler 0,
				 'spa_ICE_interface',
				 'spa_ICE_interface',
				 'Success',
				 'Data from staging table has been sucessfully deleted.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'spa_ICE_interface',
             'spa_ICE_interface',
             'DB Error',
             'Failed to Delete.',
             ''
	END CATCH
END
