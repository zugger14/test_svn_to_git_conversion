
IF OBJECT_ID('[dbo].[spa_source_uom_maintain]','p') IS NOT NULL 
DROP PROCEDURE [dbo].[spa_source_uom_maintain]
 GO 

CREATE PROCEDURE [dbo].[spa_source_uom_maintain]
	@flag AS CHAR(1),
	@source_uom_id INT = NULL,				
	@source_system_id INT = NULL,
	@uom_id VARCHAR(50) = NULL,
	@uom_name VARCHAR(100) = NULL,
	@uom_desc VARCHAR(500) = NULL,
	@user_name VARCHAR(50) = NULL,
	@eff_test_profile_id INT = NULL,
	@uom_type INT = NULL

AS
/*
declare @flag AS CHAR(1) = 'c',
@source_uom_id INT = NULL,				
@source_system_id INT = NULL,
@uom_id VARCHAR(50) = NULL,
@uom_name VARCHAR(100) = NULL,
@uom_desc VARCHAR(500) = NULL,
@user_name VARCHAR(50) = NULL,
@eff_test_profile_id INT = NULL,
@uom_type INT = NULL


 drop table #final_privilege_list
 */
DECLARE @Sql_Select VARCHAR(5000)
	
IF @flag IN ('s', 'c')
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'uom'
END

IF @flag = 'i'
BEGIN
	DECLARE @count1 VARCHAR(100)
	SELECT @count1= COUNT(*) FROM source_uom WHERE uom_id = @uom_id AND source_system_id=@source_system_id
	IF (@count1 > 0)
	BEGIN
		SELECT 'Error', 'UOM ID must be unique', 
			'spa_source_uom_maintain', 'DB Error', 
			'UOM ID must be unique', ''
		RETURN
	END

INSERT INTO source_uom
		(
		source_system_id,
		uom_id,
		uom_name,
		uom_desc
		)
	VALUES
		(					
		@source_system_id,
		@uom_id,		
		@uom_name,
		@uom_desc
		)
		
		SET @source_uom_id = SCOPE_IDENTITY()

		IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_uom_maintain', 'DB Error', 
				'Failed to insert defination value.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_uom_maintain', 'Success', 
				'Defination data value inserted.', @source_uom_id
END

ELSE IF @flag = 'a' 
BEGIN
	SELECT source_uom.source_uom_id, source_system_description.source_system_name,
			source_uom.uom_id, source_uom.uom_name, 
			source_uom.uom_desc 
	FROM source_uom 
	INNER JOIN source_system_description 
	ON source_system_description.source_system_id = source_uom.source_system_id
	WHERE source_uom_id=@source_uom_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Source_UOM table', 
				'spa_source_uom_maintain', 'DB Error', 
				'Failed to select maintain defiantion detail record of Item type.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Source_UOM table', 
				'spa_source_uom_maintain', 'Success', 
				'Source_UOM detail record of Item Type successfully selected.', ''
END

ELSE IF @flag = 's' 
BEGIN
	SET @Sql_Select = '
		SELECT	su.source_uom_id, 
				(CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE ssd.source_system_name + ''.'' END + su.uom_name) uom_id,
				MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_uom su ON su.source_uom_id = fpl.value_id
		INNER JOIN source_system_description ssd ON ssd.source_system_id = su.source_system_id ' 
	IF @eff_test_profile_id IS NOT NULL 		
		SET @Sql_Select += 'INNER JOIN fas_strategy fs ON su.source_system_id = fs.source_system_id	
							INNER JOIN portfolio_hierarchy ph ON ph.parent_entity_id = fs.fas_strategy_id 
							AND ph.entity_id =' + CAST(@eff_test_profile_id AS VARCHAR(10))
	SET @Sql_Select +=  ' GROUP BY su.source_uom_id, su.uom_name, ssd.source_system_id, ssd.source_system_name
							ORDER BY uom_id ASC
							'
	EXEC(@Sql_Select)
END

ELSE IF @flag = 'u'
BEGIN
	DECLARE @count VARCHAR(100)
	SELECT @count1= COUNT(*) FROM source_uom WHERE uom_id=@uom_id AND source_system_id = @source_system_id  AND source_uom_id<>@source_uom_id
	IF (@count1 > 0)
	BEGIN
		SELECT 'Error', 'UOM ID must be unique', 
			'spa_source_uom_maintain', 'DB Error', 
			'UOM ID must be unique', ''
		RETURN
	END

	UPDATE source_uom
	SET    source_system_id = @source_system_id,
	       uom_id = @uom_id,
	       uom_name = @uom_name,
	       uom_desc = @uom_desc
	WHERE  source_uom_id = @source_uom_id

	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_uom_maintain', 'DB Error', 
				'Failed to update defination value.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_uom_maintain', 'Success', 
				'Defination data value updated.', @source_uom_id
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DELETE  FROM source_uom
			WHERE source_uom_id=@source_uom_id
			
			EXEC spa_maintain_udf_header 'd', NULL, @source_uom_id
		
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

IF @flag = 'z' -- for grid and dropdown
BEGIN 
	SELECT source_uom_id, uom_id + ' - ' + uom_name uom_id
	FROM source_uom
END
-- Query for UOM dropdown with privileges
IF @flag = 'c'
BEGIN
	SET @Sql_Select = '
		SELECT	su.source_uom_id,
				su.uom_name,
				MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_uom su ON su.source_uom_id = fpl.value_id
			
		WHERE 1 = 1 '
	
	IF EXISTS (SELECT 1 FROM source_uom AS su WHERE uom_type_id = @uom_type)
    BEGIN
    	SET @Sql_Select += ' and su.uom_type_id='+CAST(@uom_type AS VARCHAR(10))+' or su.uom_type_id is null'
    END
    ELSE 
    BEGIN
    	SET @Sql_Select += ' and su.uom_type_id IS NULL '
    END
	
	SET @Sql_Select +=	'  GROUP BY su.source_uom_id, su.uom_name
		ORDER BY uom_name ASC
	'

	EXEC(@Sql_Select)
END
