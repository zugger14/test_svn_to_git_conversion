IF OBJECT_ID('spa_exchange_api_configuration') IS NOT NULL
    DROP PROC dbo.[spa_exchange_api_configuration]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC dbo.[spa_exchange_api_configuration]
@flag VARCHAR(100),
@interface_id INT = NULL,
@xml text = NULL
AS 

DECLARE @sql varchar(8000),
        @idoc int

SET NOCOUNT ON
BEGIN
	IF @flag = 'g'
	BEGIN
		SELECT  value_id [TRMTracker_DEV], code, description
		FROM static_data_value sdv
		WHERE sdv.[type_id] = 109900
	END

	ELSE IF @flag = 'l'
	BEGIN
		SELECT [code], [description]
		FROM static_data_value
		WHERE [type_id] = 110100
	END

	ELSE IF @flag = 'm'
	BEGIN
		SELECT '[DEFAULT]' [value], '[DEFAULT]' [code] UNION
		SELECT '[SESSION]', '[SESSION]' UNION
		SELECT '[SYSTEM]', '[SYSTEM]' 
	END

	ELSE IF @flag = 'n'
	BEGIN
		SELECT 'QUICK FIX' [value], 'QUICK FIX' [code] UNION
		SELECT 'EPEX SPOT', 'EPEX SPOT' UNION
		SELECT 'TRAYPORT', 'TRAYPORT'
	END

	ELSE IF @flag = 'o'
	BEGIN
		SELECT ixp_rule_hash,ixp_rules_name
		FROM ixp_rules
		ORDER BY ixp_rules_name
	END

	ELSE IF @flag = 'r'
	BEGIN
		SELECT role_id, role_name 
		FROM application_security_role 
		ORDER BY role_name
	END

	ELSE IF @flag = 'p'
	BEGIN
		IF EXISTS(SELECT 1 
				  FROM interface_configuration
				  WHERE interface_id = @interface_id 
				)
		BEGIN
			SELECT  id
			   ,interface_id
			   ,configuration_type
			   ,variable_name
			   ,variable_value
			FROM interface_configuration
			WHERE interface_id = @interface_id
		END
		
	END

	ELSE IF @flag = 'q'
	BEGIN
		SELECT  id
               ,interface_id
               ,interface_name
               ,interface_type
               ,is_active
               ,import_rule_hash
               ,user_login_id
               ,dbo.FNADECRYPT([password]) [password]
               ,sender_comp_id
               ,sender_sub_id
               ,target_comp_id
               ,target_sub_id
               ,session_qualifier
               ,reject_duplicate_trade
			   ,security_import_rule_hash
			   ,user_role_ids
		FROM interface_configuration_detail
		WHERE interface_id = @interface_id
	END

	ELSE IF @flag = 'i'
	BEGIN
		BEGIN TRY
			EXEC sp_xml_preparedocument @idoc OUTPUT,
                                @xml

			IF OBJECT_ID('tempdb..#temp_interface_configuration') IS NOT NULL
				DROP TABLE #temp_interface_configuration

			IF OBJECT_ID('tempdb..#temp_interface_configuration_delete') IS NOT NULL
				DROP TABLE #temp_interface_configuration_delete

			IF OBJECT_ID('tempdb..#temp_interface_configuration_detail') IS NOT NULL
				DROP TABLE #temp_interface_configuration_detail

			IF OBJECT_ID('tempdb..#temp_interface_configuration_detail_delete') IS NOT NULL
				DROP TABLE #temp_interface_configuration_detail_delete

			SELECT
				id
				,interface_id
				,configuration_type
				,variable_name
				,variable_value
			INTO #temp_interface_configuration
			FROM OPENXML(@idoc, '/Root/GridXML/GridRow', 1)
			WITH (
				id VARCHAR(10)
				,interface_id  VARCHAR(10)
				,configuration_type VARCHAR(1000)
				,variable_name NVARCHAR(2000)
				,variable_value nvarchar(MAX)
			)

			SELECT
				id
				,interface_id
				,configuration_type
				,variable_name
				,variable_value
			INTO #temp_interface_configuration_delete
			FROM OPENXML(@idoc, '/Root/GridXMLDel/GridRow', 1)
			WITH (
				id VARCHAR(10)
				,interface_id  VARCHAR(10)
				,configuration_type VARCHAR(1000)
				,variable_name NVARCHAR(2000)
				,variable_value nvarchar(MAX)
			)

			SELECT
				id
				,interface_id
				,interface_name
				,interface_type
				,is_active
				,import_rule_hash
				,user_login_id
				,dbo.FNADecodeXML([password]) [password]
				,sender_comp_id
				,sender_sub_id
				,target_comp_id
				,target_sub_id
				,session_qualifier
				,reject_duplicate_trade
				,security_import_rule_hash
				,NULLIF(user_role_ids,0) user_role_ids
			INTO #temp_interface_configuration_detail
			FROM OPENXML(@idoc, '/Root/GridXMLDetail/GridRow', 1)
			WITH (
				id VARCHAR(10)
				,interface_id VARCHAR(10)
				,interface_name NVARCHAR(510)
				,interface_type VARCHAR(100)
				,is_active BIT
				,import_rule_hash VARCHAR(1000)
				,user_login_id VARCHAR(1000)
				,[password] VARCHAR(1000)
				,sender_comp_id VARCHAR(1000)
				,sender_sub_id VARCHAR(1000)
				,target_comp_id VARCHAR(1000)
				,target_sub_id VARCHAR(1000)
				,session_qualifier BIT
				,reject_duplicate_trade BIT
				,security_import_rule_hash VARCHAR(1000)
				,user_role_ids INT
			)

			SELECT
				id
				,interface_id
				,interface_name
				,interface_type
				,is_active
				,import_rule_hash
				,user_login_id
				,[password] [password]
				,sender_comp_id
				,sender_sub_id
				,target_comp_id
				,target_sub_id
				,session_qualifier
				,reject_duplicate_trade
				,security_import_rule_hash
				,user_role_ids
			INTO #temp_interface_configuration_detail_delete
			FROM OPENXML(@idoc, '/Root/GridXMLDelDetail/GridRow', 1)
			WITH (
				id VARCHAR(10)
				,interface_id VARCHAR(10)
				,interface_name NVARCHAR(510)
				,interface_type VARCHAR(100)
				,is_active BIT
				,import_rule_hash VARCHAR(1000)
				,user_login_id VARCHAR(1000)
				,[password] VARBINARY(MAX)
				,sender_comp_id VARCHAR(1000)
				,sender_sub_id VARCHAR(1000)
				,target_comp_id VARCHAR(1000)
				,target_sub_id VARCHAR(1000)
				,session_qualifier BIT
				,reject_duplicate_trade BIT
				,security_import_rule_hash VARCHAR(1000)
				,user_role_ids INT
			)

			 /*
				select * from #temp_interface_configuration
				select * from #temp_interface_configuration_delete
				select * from #temp_interface_configuration_detail
				select * #temp_interface_configuration_detail_delete
				return
			*/

			IF EXISTS(
				SELECT 1 
				FROM #temp_interface_configuration_detail
				GROUP BY interface_name
				HAVING COUNT(*) > 1
			) BEGIN
				EXEC spa_ErrorHandler -1,
								  'spa_exchange_api_configuration',
								  'spa_exchange_api_configuration',
								  'DB Error',
								  'Interface name should be unique.',
								  ''
			END

			UPDATE ic
			SET ic.configuration_type = tic.configuration_type
				,ic.variable_name = tic.variable_name
				,ic.variable_value = tic.variable_value
			FROM #temp_interface_configuration tic
			LEFT JOIN interface_configuration ic
				ON ic.id = tic.id
			WHERE ic.id IS NOT NULL
			AND ic.interface_id = @interface_id

			INSERT INTO interface_configuration(interface_id,configuration_type,variable_name,variable_value)
			SELECT @interface_id, tic.configuration_type, tic.variable_name, tic.variable_value
			FROM #temp_interface_configuration tic
				LEFT JOIN interface_configuration ic
					ON ic.id = tic.id
			WHERE ic.id IS NULL

			DELETE ic
			FROM #temp_interface_configuration_delete ticd
			LEFT JOIN interface_configuration ic
				ON ic.id = ticd.id
			WHERE ic.id IS NOT NULL
			AND ic.interface_id = @interface_id

			UPDATE icd
			SET icd.interface_id = ticd.interface_id
				,icd.interface_name = ticd.interface_name
				,icd.interface_type = ticd.interface_type
				,icd.is_active = ticd.is_active
				,icd.import_rule_hash = ticd.import_rule_hash
				,icd.user_login_id = ticd.user_login_id
				,icd.[password] = dbo.FNAENCRYPT(ticd.[password])
				,icd.sender_comp_id = ticd.sender_comp_id  
				,icd.sender_sub_id = ticd.sender_sub_id
				,icd.target_comp_id = ticd.target_comp_id
				,icd.target_sub_id = ticd.target_sub_id
				,icd.session_qualifier	 = ticd.session_qualifier	
				,icd.reject_duplicate_trade = ticd.reject_duplicate_trade
				,icd.security_import_rule_hash = ticd.security_import_rule_hash
				,icd.user_role_ids = ticd.user_role_ids
			FROM #temp_interface_configuration_detail ticd
			LEFT JOIN interface_configuration_detail icd
				ON icd.id = ticd.id
			WHERE icd.id IS NOT NULL
			AND icd.interface_id = @interface_id

			INSERT INTO interface_configuration_detail(interface_id,interface_name,interface_type,is_active,import_rule_hash,user_login_id,[password],sender_comp_id,sender_sub_id,target_comp_id,target_sub_id,session_qualifier,reject_duplicate_trade,security_import_rule_hash,user_role_ids)
			SELECT ticd.interface_id
					,ticd.interface_name
					,ticd.interface_type
					,ticd.is_active
					,ticd.import_rule_hash
					,ticd.user_login_id
					,dbo.FNAENCRYPT(ticd.[password])
					,ticd.sender_comp_id
					,ticd.sender_sub_id
					,ticd.target_comp_id
					,ticd.target_sub_id
					,ticd.session_qualifier
					,ticd.reject_duplicate_trade
					,ticd.security_import_rule_hash
					,ticd.user_role_ids
			FROM #temp_interface_configuration_detail ticd
			LEFT JOIN interface_configuration_detail icd
				ON icd.id = ticd.id
			WHERE icd.id IS NULL

			DELETE icd
			FROM #temp_interface_configuration_detail_delete ticdd
			LEFT JOIN interface_configuration_detail icd
				ON icd.id = ticdd.id
			WHERE icd.id IS NOT NULL
			AND icd.interface_id = @interface_id

			EXEC spa_ErrorHandler 0,
							  'spa_exchange_api_configuration',
							  'spa_exchange_api_configuration',
							  'Success',
							  'Changes have been saved successfully.',
							  ''
		END TRY
	    BEGIN CATCH
			IF @@TRANCOUNT > 0
			  ROLLBACK
			--PRINT error_message()
			EXEC spa_ErrorHandler -1,
								  'spa_exchange_api_configuration',
								  'spa_exchange_api_configuration',
								  'DB Error',
								  'Error while updating.',
								  ''
		END CATCH
	END
		
END