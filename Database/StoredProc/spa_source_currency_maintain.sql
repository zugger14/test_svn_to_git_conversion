
IF OBJECT_ID(N'spa_source_currency_maintain', N'P') IS NOT NULL
DROP PROCEDURE spa_source_currency_maintain
 GO 

--EXEC spa_source_currency_maintain 's',NULL,NULL
CREATE PROCEDURE [dbo].[spa_source_currency_maintain]	
@flag AS CHAR(1),	
@source_currency_id INT = NULL,				
@source_system_id INT = NULL,
@currency_id VARCHAR(50) = V,
@currency_name VARCHAR(100) = NULL,
@currency_desc VARCHAR(500) = NULL,
@user_name VARCHAR(50) = NULL,
@strategy_id INT = NULL ,
@eff_test_profile_id INT = NULL

AS

SET NOCOUNT ON

IF @flag IN ('p', 'b', 'c', 'e')
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'currency'
END
 
DECLARE @Sql_SELECT VARCHAR(5000)

IF @flag = 'i'
BEGIN
	DECLARE @cont1 VARCHAR(100)
	SELECT @cont1 = COUNT(*) FROM source_currency WHERE currency_id = @currency_id AND source_system_id = @source_system_id
	IF (@cont1 > 0)
	BEGIN
		SELECT 'Error', 'Currency ID must be unique',
			'spa_application_security_role', 'DB Error', 
			'Currency ID must be unique', ''
		RETURN
	END
	INSERT INTO source_currency
			(
			source_system_id,
			currency_id,
			currency_name,
			currency_desc,
			create_user,
			create_ts,
			update_user,
			update_ts
			)
		VALUES
			(					
			@source_system_id,
			@currency_id,		
			@currency_name,
			@currency_desc,
			@user_name,
			getdate(),
			@user_name,
			getdate()
			)
			
			SET @source_currency_id = SCOPE_IDENTITY()
			
			IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
					'spa_source_currency_maintain', 'DB Error', 
					'Failed to insert defination value.', ''
			ELSE
			EXEC spa_ErrorHandler 0, 'MaintainDefination', 
					'spa_source_currency_maintain', 'Success', 
					'Defination data value inserted.', @source_currency_id
END

ELSE IF @flag = 'a' 
BEGIN
	SELECT source_currency.source_currency_id, source_system_description.source_system_name,
	source_currency.currency_id, source_currency.currency_name, source_currency.currency_desc
	FROM source_currency inner join source_system_description ON
	source_system_description.source_system_id = source_currency.source_system_id WHERE source_currency_id = @source_currency_id
	

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Source_Currency table', 
				'spa_source_currency_maintain', 'DB Error', 
				'Failed to SELECT maintain defiantion detail record of Item type.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Source_Currency table', 
				'spa_source_currency_maintain', 'Success', 
				'Source_Currency detail record of Item Type successfully SELECTed.', ''
END

ELSE IF @flag = 's' 
BEGIN
	SET @Sql_SELECT='SELECT DISTINCT source_currency.source_currency_id,
	source_currency.currency_name + CASE WHEN source_system_description.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END as Name,
	 source_currency.currency_desc as Description, 
	source_system_description.source_system_name as System, 
	source_currency.currency_id as currencyid,
		dbo.FNADateTimeFormat(source_currency.create_ts,1) [Created Date],
		source_currency.create_user [Created User],
		source_currency.update_user [Updated User],
		dbo.FNADateTimeFormat(source_currency.update_ts,1) [Updated Date] 
	 from source_currency inner join 
	source_system_description on
	source_system_description.source_system_id = source_currency.source_system_id
	LEFT JOIN fas_strategy fs ON fs.source_system_id = source_currency.source_system_id 
	 where 1 = 1
	'
	IF @strategy_id IS NOT NULL		
		SET @Sql_SELECT=@Sql_SELECT +  ' AND  fs.fas_strategy_id=' + CONVERT(VARCHAR(20),@strategy_id) + ''
		
	IF @source_system_id IS NOT NULL		
		SET @Sql_SELECT=@Sql_SELECT +  ' AND source_currency.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id) + ''
		 
	--PRINT @Sql_SELECT
	EXEC(@SQL_SELECT)

END

ELSE IF @flag = 'n' 
BEGIN
	SET @Sql_SELECT='SELECT DISTINCT source_currency.source_currency_id,
	source_currency.currency_name + CASE WHEN source_system_description.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END as Name
	 from source_currency inner join 
	source_system_description on
	source_system_description.source_system_id = source_currency.source_system_id
	LEFT JOIN fas_strategy fs ON fs.source_system_id = source_currency.source_system_id 
	 where 1 = 1
	'
	IF @strategy_id IS NOT NULL		
		SET @Sql_SELECT=@Sql_SELECT +  ' AND  fs.fas_strategy_id=' + CONVERT(VARCHAR(20),@strategy_id) + ''
		
	IF @source_system_id IS NOT NULL		
		SET @Sql_SELECT=@Sql_SELECT +  ' AND source_currency.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id) + ''
		 
	SET @Sql_SELECT = @Sql_SELECT +  ' ORDER BY Name ASC'
	--PRINT @Sql_SELECT
	EXEC(@SQL_SELECT)

END

ELSE IF @flag = 'u'
BEGIN
	DECLARE @cont VARCHAR(100)
	SELECT @cont= count(*) FROM source_currency WHERE currency_id =@currency_id AND source_system_id = @source_system_id AND source_currency_id <> @source_currency_id
	IF (@cont > 0)
	BEGIN
		SELECT 'Error', 'Currency ID must be unique', 
			'spa_application_security_role', 'DB Error', 
			'Currency ID must be unique', ''
		RETURN
	END
	UPDATE source_currency SET source_system_id = @source_system_id, currency_id=@currency_id, currency_name = @currency_name, currency_desc = @currency_desc, 
	update_user=@user_name, update_ts = getdate()
	WHERE source_currency_id = @source_currency_id

	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_currency_maintain', 'DB Error', 
				'Failed to update defination value.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_currency_maintain', 'Success', 
				'Defination data value updated.', @source_currency_id
END

ELSE IF @flag = 'p' --Modified to use for currency dropdown with privilege
BEGIN
	SET @Sql_SELECT='
		SELECT	sc.source_currency_id, 
				sc.currency_name,
				MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_currency sc ON sc.source_currency_id = fpl.value_id
		GROUP BY sc.source_currency_id, sc.currency_name
	'
	EXEC(@Sql_SELECT)
END


ELSE IF @flag = 'b' --added to use for currency dropdown with privilege
BEGIN
	SET @Sql_SELECT='
		SELECT	sc.source_currency_id, 
				sc.currency_name,
				MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_currency sc ON sc.source_currency_id = fpl.value_id
		INNER JOIN source_system_description ssd ON ssd.source_system_id = sc.source_system_id
		LEFT JOIN fas_strategy fs ON fs.source_system_id = sc.source_system_id 		
		GROUP BY sc.source_currency_id, sc.currency_name
		'
	EXEC(@Sql_SELECT)
END

ELSE IF @flag = 'c' --added to use for currency dropdown with privilege
BEGIN
	SET @Sql_SELECT='
		SELECT sc.source_currency_id, 
			   sc.currency_name + CASE WHEN ssd.source_system_name =''farrms'' THEN '''' ELSE ''.'' + ssd.source_system_name END AS currency_name,
			   MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_currency sc ON sc.source_currency_id = fpl.value_id
		INNER JOIN source_system_description ssd ON sc.source_system_id = ssd.source_system_id
		INNER JOIN	fas_strategy fs ON (sc.source_system_id = fs.source_system_id)		
		INNER JOIN	portfolio_hierarchy ph ON  ph.parent_entity_id = fs.fas_strategy_id 
		WHERE ph.entity_id = '+CAST(@eff_test_profile_id AS VARCHAR) +' 	 
		GROUP BY sc.source_currency_id, sc.currency_name, ssd.source_system_name '

	EXEC(@Sql_SELECT)
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
			BEGIN TRAN
				DELETE FROM source_currency
				WHERE source_currency_id = @source_currency_id
				
				EXEC spa_maintain_udf_header 'd', NULL, @source_currency_id
				
				EXEC spa_ErrorHandler 0
				, 'MaintainDefination'
				, 'spa_source_currency_maintain'
				, 'Success'
				, 'Maintain Defination Data sucessfully deleted'
				, ''
			COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0
			ROLLBACK
			DECLARE @error_no int
			SET @error_no = ERROR_NUMBER()
			EXEC spa_ErrorHandler -1
			, 'MaintainDefinition'
			, 'spa_source_currency_maintain'
			, 'DB Error'
			--, 'Currency cannot be deleted when already being used.'
			, 'Selected data is in use and cannot be deleted.'
			, 'Foreign key constrains'
	END CATCH
END

ELSE IF @flag = 'e' --added to use for currency dropdown in formula (Status not required)
BEGIN
	SET @Sql_SELECT='
		SELECT	sc.source_currency_id, 
				sc.currency_name
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_currency sc ON sc.source_currency_id = fpl.value_id
		GROUP BY sc.source_currency_id, sc.currency_name
	'
	EXEC(@Sql_SELECT)
END








