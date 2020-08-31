
IF OBJECT_ID('spa_source_traders_maintain') IS NOT null
DROP PROCEDURE [dbo].[spa_source_traders_maintain]
GO 

CREATE PROCEDURE [dbo].[spa_source_traders_maintain]
	@flag AS Char(1),					
	@source_trader_id INT = NULL,				
	@source_system_id INT = NULL,
	@trader_id VARCHAR(50) = NULL,
	@trader_name VARCHAR(100) = NULL,
	@trader_desc VARCHAR(500) = NULL,
	@user_name VARCHAR(50) = NULL,
	@user_login_id VARCHAR(50) = NULL,
	@filter_value VARCHAR(MAX) = NULL
AS 
DECLARE @Sql_Select VARCHAR(5000)
SET NOCOUNT ON

SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')

IF @flag IN ('x', 'y')
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'traders'
END

IF @flag = 'i'
BEGIN
	DECLARE @cont1 varchar(100)
	SELECT @cont1= COUNT(*) FROM source_traders WHERE trader_id =@trader_id AND source_system_id = @source_system_id
	IF (@cont1 > 0)
	BEGIN
		SELECT 'Error', 'Trader ID must be unique', 
			'spa_application_security_role', 'DB Error', 
			'Trader ID must be unique', ''
		RETURN
	END
	
INSERT INTO source_traders
		(
		source_system_id,
		trader_id,
		trader_name,
		trader_desc,
		update_user,
		update_ts,
		user_login_id
		)
	VALUES
		(				
		@source_system_id,
		@trader_id,		
		@trader_name,
		@trader_desc,
		@user_name,
		getdate(),
		@user_login_id
		)
		
		SET @source_trader_id = SCOPE_IDENTITY()
		
		IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_traders_maintain', 'DB Error', 
				'Failed to insert defination value.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_traders_maintain', 'Success', 
				'Defination data value inserted.', @source_trader_id
END

ELSE IF @flag='a' 
BEGIN
	SELECT 
		source_traders.source_trader_id, 
		source_system_description.source_system_name,
		source_traders.trader_id, 
		source_traders.trader_name, 
		source_traders.trader_desc, 
		user_login_id 
	FROM source_traders inner join source_system_description 
	ON source_system_description.source_system_id = source_traders.source_system_id 
	WHERE source_trader_id = @source_trader_id
	
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR,
		     'Source_Traders table',
		     'spa_source_traders_maintain',
		     'DB Error',
		     'Failed to select maintain defiantion detail record of Item type.',
		     ''
	ELSE
		EXEC spa_ErrorHandler 0,
		     'Source_Traders table',
		     'spa_source_traders_maintain',
		     'Success',
		     'Source_Traders detail record of Item Type successfully selected.',
		     @source_trader_id
END

ELSE IF @flag = 's' 
BEGIN
	SET @Sql_Select='SELECT source_traders.source_trader_id,
	trader_name + CASE WHEN source_system_description.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END as Name,
	source_traders.trader_desc as Description, 
	 source_system_description.source_system_name as System,
	dbo.FNADateTimeFormat(source_traders.create_ts,1) [Created Date],
		source_traders.create_user [Created User],
		source_traders.update_user [Updated User],
		dbo.FNADateTimeFormat(source_traders.update_ts,1) [Updated Date],user_login_id [User Login ID] 
	 from source_traders inner join source_system_description on
	source_system_description.source_system_id = source_traders.source_system_id'
	IF @source_system_id is not null 
		SET @Sql_Select=@Sql_Select +  ' where source_traders.source_system_id=' + CONVERT(varchar(20), @source_system_id)+''
		SET @Sql_Select=@Sql_Select +  ' order by Name asc'
	EXEC(@SQL_select)
END

ELSE IF @flag = 'l'  --list in grid .. without suffixing source system id. 
BEGIN
	SET @Sql_Select='SELECT source_traders.source_trader_id, trader_name as Name, source_traders.trader_desc as Description, 
	 source_system_description.source_system_name as System,
	source_traders.create_ts [Created Date],
		source_traders.create_user [Created User],
		source_traders.update_user [Updated User],
		source_traders.update_ts [Updated Date] 
		,user_login_id [User Login ID]
	 from source_traders inner join source_system_description on
	source_system_description.source_system_id = source_traders.source_system_id'
	IF @source_system_id is not null 
		SET @Sql_Select=@Sql_Select +  ' where source_traders.source_system_id=' + CONVERT(varchar(20), @source_system_id) + ''
	EXEC(@SQL_select)
END

ELSE IF @flag = 'u'
BEGIN
	
	DECLARE @cont VARCHAR(100)
	SELECT @cont= COUNT(*) FROM source_traders 
	WHERE trader_id =@trader_id AND source_system_id=@source_system_id AND source_trader_id <> @source_trader_id
	IF (@cont>0)
	BEGIN
		SELECT 'Error', 'Trader ID must be unique', 
			'spa_application_security_role', 'DB Error', 
			'Trader ID must be unique', ''
		RETURN
	END
	UPDATE source_traders 
	SET source_system_id = @source_system_id, trader_id=@trader_id, trader_name = @trader_name, trader_desc = @trader_desc, 
		update_user=@user_name, update_ts=getdate(), user_login_id = @user_login_id 
	WHERE source_trader_id = @source_trader_id

	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_traders_maintain', 'DB Error', 
				'Failed to update defination value.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_traders_maintain', 'Success', 
				'Defination data value updated.', ''
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DELETE FROM source_traders
			WHERE source_trader_id = @source_trader_id
			
			EXEC spa_maintain_udf_header 'd', NULL, @source_trader_id
			
			EXEC spa_ErrorHandler 0
			, 'MaintainDefination'
			, 'spa_source_traders_maintain'
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
			, 'spa_source_traders_maintain'
			, 'DB Error'
			, 'Selected data is in use and cannot be deleted.'
			, 'Foreign key constrains'
	END CATCH
END
ELSE IF @flag = 'x' --Modified to add privilege
BEGIN
	SET @Sql_Select = '
		SELECT st.source_trader_id,
			   CASE 
					WHEN ssd.source_system_id = 2 THEN ''''
					ELSE ''.'' + ssd.source_system_name
			   END + st.trader_name AS Name,
				MIN(fpl.is_enable) [status]
	    FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
		 source_traders st ON st.source_trader_id = fpl.value_id
		INNER JOIN source_system_description ssd ON  ssd.source_system_id = st.source_system_id'
		
	IF @filter_value IS NOT NULL AND @filter_value <> '-1'
	BEGIN
		SET @sql_select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = st.source_trader_id'
	END	
	SET @Sql_Select += ' GROUP BY st.source_trader_id, ssd.source_system_id, ssd.source_system_name, st.trader_name
		ORDER BY Name'
	EXEC(@Sql_Select)
END
ELSE IF @flag = 'y' -- Use as Traders Dropdown with privilege
BEGIN
	SET @Sql_Select = '
		SELECT st.source_trader_id,
			   st.trader_name,
				MIN(fpl.is_enable) [status]
	    FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
		 source_traders st ON st.source_trader_id = fpl.value_id
		GROUP BY st.source_trader_id, st.trader_name
		ORDER BY st.trader_name
	'
	EXEC(@Sql_Select)
END
-- Used in Generic Mapping
ELSE IF @flag = 'm'
BEGIN
	SELECT source_trader_id [value], trader_id [label]
	FROM source_traders
END