SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_commodity_maintain]') AND TYPE IN (N'P', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[spa_source_commodity_maintain]
END
GO 

CREATE PROCEDURE [dbo].[spa_source_commodity_maintain]	
	@flag  CHAR(1),	
	@source_commodity_id INT = NULL,				
	@source_system_id INT = NULL,
	@commodity_id VARCHAR(50) = NULL,
	@commodity_name VARCHAR(100) = NULL,
	@commodity_desc VARCHAR(500) = NULL,
	@user_name VARCHAR(50) = NULL,
	@strategy_id INT = NULL, 
	@commodity_group VARCHAR(500) = NULL,
	@row_id VARCHAR(50) = NULL,
	@location_id INT = NULL
AS 

SET NOCOUNT ON
DECLARE @Sql_Select VARCHAR(5000)

/*
*	Preliminaries for the Commodity Privileges
*	Will be used where required.
*/
IF @flag IN('a', 'b', 'k')
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'commodity'
END

IF @flag = 'g'
BEGIN
	SELECT	commodity_quality_id [ID],
			cq.quality [Quality],
			CASE
				WHEN sdv.category_id = 1 THEN 'Numeric'
				WHEN sdv.category_id = 2 THEN 'Percentage'
				WHEN sdv.category_id = 3 THEN 'Text'
				WHEN sdv.category_id = 4 THEN 'Range'
			END AS [Type],
			cq.from_value [From Value],
			cq.to_value [To Value],
			cq.uom [UOM],
			source_commodity_id
	FROM commodity_quality cq
	INNER JOIN static_data_value sdv ON sdv.value_id = cq.quality
	WHERE source_commodity_id = @source_commodity_id	
END

IF @flag = 'i'
BEGIN
	DECLARE @cont1 VARCHAR(100)
	SELECT @cont1 = COUNT(*) FROM source_commodity
	WHERE commodity_id = @commodity_id AND source_system_id = @source_system_id
	IF (@cont1 > 0)
	BEGIN
		SELECT 'Error'
			, 'Commodity ID must be unique'
			, 'spa_application_security_role'
			, 'DB Error'
			, 'Commodity ID must be unique'
			, ''
		RETURN
	END
	
INSERT INTO source_commodity
		(
		source_system_id,
		commodity_id,
		commodity_name,
		commodity_desc,
		create_user,
		create_ts,
		update_user,
		update_ts
		)
	VALUES
		(										
		@source_system_id,
		@commodity_id,		
		@commodity_name,
		@commodity_desc,
		@user_name,
		getdate(),
		@user_name,
		getdate()
		)
		
		SET @source_commodity_id = SCOPE_IDENTITY()
		
		IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error
			, 'MaintainDefination'
			, 'spa_source_commodity_maintain'
			, 'DB Error'
			, 'Failed to insert defination value.'
			, ''
		ELSE
		EXEC spa_ErrorHandler 0
			, 'MaintainDefination'
			, 'spa_source_commodity_maintain'
			, 'Success'
			, 'Defination data value inserted.'
			, @source_commodity_id
END
/*
*	Flag = 'a'
*	Commodity Dropdown with privilege handling
*/
ELSE IF @flag = 'a' 
BEGIN
	SET @Sql_Select = '
		SELECT DISTINCT sc.source_commodity_id,
			   sc.commodity_name,
			   MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_commodity sc ON sc.source_commodity_id = fpl.value_id
		' + CASE WHEN NULLIF(@commodity_group, 'NULL') IS NOT NULL THEN ' INNER JOIN dbo.FNASplit(''' + @commodity_group + ''', '','') i ON  i.item = sc.commodity_group1 ' ELSE '' END + '
		GROUP BY sc.source_commodity_id, sc.commodity_name
		ORDER by sc.commodity_name
	'

	EXEC(@Sql_Select)
END
ELSE IF @flag = 'b'
BEGIN
	SET @Sql_Select = '
		SELECT	sc.source_commodity_id, 
				sc.commodity_name + CASE WHEN sc.source_system_id = 2 THEN '''' ELSE ''.'' + ssd.source_system_name END AS Name,
				MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
		 source_commodity sc ON sc.source_commodity_id = fpl.value_id
		INNER JOIN source_system_description ssd ON ssd.source_system_id = sc.source_system_id
		GROUP BY sc.source_commodity_id, sc.commodity_name, sc.source_system_id, ssd.source_system_name
		ORDER BY Name
		'
	EXEC(@Sql_Select)
END
ELSE IF @flag = 's' 
BEGIN
	SET @Sql_Select = 'SELECT source_commodity.source_commodity_id,
					  source_commodity.commodity_name + CASE WHEN source_commodity.source_system_id = 2 
					  THEN '''' ELSE ''.'' + source_system_description.source_system_name END AS Name,
					  source_commodity.commodity_desc AS Description, 
					  source_system_description.source_system_name AS System, source_commodity.commodity_id 
	                  FROM source_commodity 
	                  INNER JOIN source_system_description 
	                  ON
					  source_system_description.source_system_id = source_commodity.source_system_id '
	IF @strategy_id IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' 
							INNER JOIN fas_strategy fs 
							ON fs.source_system_id = source_system_description.source_system_id 
							WHERE fs.fas_strategy_id = ' + CAST(@strategy_id AS VARCHAR(100))

	IF @source_system_id IS NOT NULL AND @strategy_id IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND source_commodity.source_system_id = ' + CONVERT(VARCHAR(20), @source_system_id)

	IF @source_system_id IS NOT NULL AND  @strategy_id IS NULL
		SET @Sql_Select = @Sql_Select + ' WHERE source_commodity.source_system_id = ' + CONVERT(VARCHAR(20), @source_system_id)
	SET @Sql_Select = @Sql_Select + ' ORDER BY Name ASC '
	EXEC(@SQL_select)

END

ELSE IF @flag = 'l' --list in grid .. without suffixing source system id. 
BEGIN
	SET @Sql_Select = 'SELECT source_commodity.source_commodity_id, source_commodity.commodity_name AS Name, source_commodity.commodity_desc AS Description, 
					  source_system_description.source_system_name AS System, source_commodity.commodity_id
					  FROM source_commodity 
					  INNER JOIN source_system_description 
					  ON source_system_description.source_system_id = source_commodity.source_system_id'
	IF @source_system_id IS NOT NULL 
		SET @Sql_Select = @Sql_Select +  ' WHERE source_commodity.source_system_id = ' + CONVERT(VARCHAR(20), @source_system_id) + ''
	EXEC(@SQL_select)

END

ELSE IF @flag = 'c' --for editable grid column combo
BEGIN
	SELECT source_commodity.source_commodity_id, 
			source_commodity.commodity_name
	FROM source_commodity 
	INNER JOIN source_system_description ON source_system_description.source_system_id = source_commodity.source_system_id
END

ELSE IF @flag = 'u'
BEGIN
	DECLARE @cont VARCHAR(100)
	SELECT @cont = COUNT(*) FROM source_commodity 
					WHERE commodity_id = @commodity_id AND source_system_id = @source_system_id AND source_commodity_id <> @source_commodity_id
	IF (@cont>0)
	BEGIN
		SELECT 'Error'
				, 'Commodity ID must be unique'
				, 'spa_application_security_role'
				, 'DB Error'
				, 'Commodity ID must be unique'
				, ''
		RETURN
	END
	UPDATE source_commodity 
	SET source_system_id = @source_system_id, commodity_id = @commodity_id, commodity_name = @commodity_name, commodity_desc = @commodity_desc,
							update_user = @user_name, update_ts = getdate()
	WHERE source_commodity_id = @source_commodity_id
	
	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error
			, 'MaintainDefination'
			, 'spa_source_commodity_maintain'
			, 'DB Error'
			, 'Failed to update defination value.'
			, ''
		ELSE
		EXEC spa_ErrorHandler 0
			, 'MaintainDefination'
			, 'spa_source_commodity_maintain'
			, 'Success'
			, 'Defination data value updated.'
			, @source_commodity_id

END

ELSE IF @flag = 'd'
BEGIN
	IF EXISTS(SELECT 1 FROM source_price_curve_def WHERE commodity_id = @source_commodity_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'source_price_curve_def, MaintainDefination'
			, 'spa_source_commodity_maintain'
			, 'DB Error'
			--, 'Commodity cannot be deleted when already being used.'
			, 'Selected data is in use and cannot be deleted.'
			, ''
		RETURN
	END
	
	DELETE FROM source_commodity
	WHERE source_commodity_id = @source_commodity_id
	
	EXEC spa_maintain_udf_header 'd', NULL, @source_commodity_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR
			, 'MaintainDefination'
			, 'spa_source_commodity_maintain'
			, 'DB Error'
			, 'Delete of Maintain Defination Data failed.'
			, ''
	ELSE
		EXEC spa_ErrorHandler 0
			, 'MaintainDefination'
			, 'spa_source_commodity_maintain'
			, 'Success'
			, 'Maintain Defination Data sucessfully deleted'
			, ''
END
ELSE IF @flag = 'z'--filter commity by group1 
BEGIN
	SET @Sql_Select = '
					SELECT source_commodity_id id,	commodity_name name FROM source_commodity sc
					' + CASE WHEN NULLIF(@commodity_group, 'NULL') IS NOT NULL THEN ' INNER JOIN dbo.FNASplit(''' + @commodity_group + ''', '','') i ON  i.item = sc.commodity_group1 ' ELSE '' END + '
					ORDER BY name '

	EXEC (@Sql_Select)
END
ELSE IF @flag = 'q' 
BEGIN
	SELECT CASE WHEN sdv.category_id = 1 THEN 'Numeric'
				 WHEN sdv.category_id = 2 THEN 'Percentage'
				 WHEN sdv.category_id = 3 THEN 'Text'
				 WHEN sdv.category_id = 4 THEN 'Range'
			END	 [Type],
			@row_id [Row ID]
	from static_data_value sdv where value_id = @source_commodity_id
END
ELSE IF @flag = 'r'
BEGIN
	SELECT	commodity_recipe_product_mix_id,
			source_commodity_id,
			recipe_commodity_id,
			dbo.FNARemoveTrailingZero(blend_contribution) blend_contribution,
			dbo.FNARemoveTrailingZero(loss_shrinkage) loss_shrinkage
	FROM commodity_recipe_product_mix
	WHERE source_commodity_id = @source_commodity_id
END

ELSE IF @flag = 'k'
BEGIN
	IF EXISTS(SELECT 1 FROM location_price_index WHERE location_id = @location_id)
	BEGIN
		SET @Sql_Select = '
		SELECT DISTINCT sc.source_commodity_id,
			   CASE WHEN sc.commodity_name = sc.commodity_id THEN sc.commodity_name ELSE concat(sc.commodity_id,'' - '',sc.commodity_name) END commodity_name,
			   MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		INNER JOIN location_price_index lpi
			ON lpi.commodity_id = fpl.value_id 
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_commodity sc ON sc.source_commodity_id = fpl.value_id
		' + CASE WHEN NULLIF(@commodity_group, 'NULL') IS NOT NULL THEN ' INNER JOIN dbo.FNASplit(''' + @commodity_group + ''', '','') i ON  i.item = sc.commodity_group1 ' ELSE '' END + '
		WHERE lpi.location_id = ''' + CAST(@location_id AS varchar(20)) +''' 
		GROUP BY sc.source_commodity_id, sc.commodity_name,sc.commodity_id
		ORDER by commodity_name
	'
	END
	ELSE
	BEGIN
	SET @Sql_Select = '
		SELECT DISTINCT sc.source_commodity_id,
			   CASE WHEN sc.commodity_name = sc.commodity_id THEN sc.commodity_name ELSE concat(sc.commodity_id,'' - '',sc.commodity_name) END commodity_name,
			   MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_commodity sc ON sc.source_commodity_id = fpl.value_id
		' + CASE WHEN NULLIF(@commodity_group, 'NULL') IS NOT NULL THEN ' INNER JOIN dbo.FNASplit(''' + @commodity_group + ''', '','') i ON  i.item = sc.commodity_group1 ' ELSE '' END + '
		GROUP BY sc.source_commodity_id, sc.commodity_name,sc.commodity_id
		ORDER by commodity_name
	'
	END
	EXEC(@Sql_Select)
END	