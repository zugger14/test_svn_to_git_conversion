
/****** Object:  StoredProcedure [dbo].[spa_source_deal_type_maintain]    Script Date: 12/23/2008 11:12:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_deal_type_maintain]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_source_deal_type_maintain]
GO

CREATE PROCEDURE [dbo].[spa_source_deal_type_maintain]	
@flag AS NCHAR(1),
@sub_type NVARCHAR(1) = NULL,	
@source_deal_type_id INT = NULL,				
@source_system_id INT = NULL,
@deal_type_id NVARCHAR(50) = NULL,
@source_deal_type_name NVARCHAR(100) = NULL,
@source_deal_desc NVARCHAR(500) = NULL,
@user_name NVARCHAR(50) = NULL,
@expiration_applies NCHAR(1) = NULL,
@fas_book_id INT = NULL,
@disable_gui_groups NCHAR(1) = NULL
AS 
DECLARE @Sql_Select NVARCHAR(MAX)

IF @flag IN('x', 'y')
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable NVARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'deal_type'
END

IF @flag = 'i'
BEGIN
	DECLARE @cont1 NVARCHAR(100)
	SELECT @cont1 = COUNT(*) FROM source_deal_type WHERE deal_type_id = @deal_type_id and source_system_id=@source_system_id
	IF (@cont1>0)
	BEGIN
		SELECT 'Error', 'Deal Type ID must be unique', 
			'spa_application_security_role', 'DB Error', 
			'Deal Type ID must be unique', ''
		RETURN
	END
INSERT INTO source_deal_type
		(
		source_system_id,
		deal_type_id,
		source_deal_type_name,
		source_deal_desc,
		sub_type,
		expiration_applies,
		disable_gui_groups,
		update_user,
		update_ts
		)
	VALUES
		(				
		@source_system_id,
		@deal_type_id,		
		@source_deal_type_name,
		@source_deal_desc,
		@sub_type,
		@expiration_applies,
		@disable_gui_groups,
		@user_name,
		getdate()
		)
		
		set @source_deal_type_id = SCOPE_IDENTITY()
		
		IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_deal_type_maintain', 'DB Error', 
				'Failed to insert defination value.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_deal_type_maintain', 'Success', 
				'Defination data value inserted.', 
				@source_deal_type_id
END

ELSE IF @flag = 'a' 
BEGIN
	SELECT source_deal_type.source_deal_type_id, source_system_description.source_system_name,
		source_deal_type.deal_type_id, source_deal_type.source_deal_type_name, 
		source_deal_type.source_deal_desc,source_deal_type.sub_type,expiration_applies,disable_gui_groups
	FROM source_deal_type inner join source_system_description 
	ON source_system_description.source_system_id = source_deal_type.source_system_id
	WHERE source_deal_type_id=@source_deal_type_id
	
END

ELSE IF @flag = 's' 
BEGIN
	SET @Sql_select = 'SELECT source_deal_type.source_deal_type_id [Deal ID],
	 source_deal_type_name + CASE WHEN source_system_description.source_system_id = 2 THEN '''' ELSE ''.'' + source_system_description.source_system_name  END as Name,
	 source_deal_type.source_deal_desc as Description,
	case sub_type when ''y'' then ''Yes'' else ''No'' End as [Sub Type] ,
	 source_system_description.source_system_name as System,  
	dbo.FNADateTimeFormat(source_deal_type.create_ts,1) [Created Date],
		source_deal_type.create_user [Created User],
		source_deal_type.update_user [Updated User],
		dbo.FNADateTimeFormat(source_deal_type.update_ts,1) [Updated Date] 
	from source_deal_type inner join source_system_description on
	source_system_description.source_system_id = source_deal_type.source_system_id'
	IF @source_system_id IS NOT NULL 
		SET @Sql_Select=@Sql_Select +  ' where source_deal_type.source_system_id=' + CONVERT(NVARCHAR(20), @source_system_id) + ''

	IF @sub_type <> 'a'
		SET @Sql_Select=@Sql_Select +  ' and isNull(sub_type,''n'')='''+isNull(@sub_type,'n') + ''''

	SET @Sql_Select=@Sql_Select +  ' ORDER BY Name ASC'

	EXEC(@SQL_select)
END

ELSE IF @flag = 'm' 
BEGIN
	SET @Sql_Select = 'SELECT source_deal_type_id
	from source_deal_type 
	where 1=1'
	
END

ELSE IF @flag = 'u'
BEGIN
	DECLARE @cont NVARCHAR(100)
	SELECT @cont= COUNT(*) FROM source_deal_type WHERE deal_type_id =@deal_type_id AND source_deal_type_id <> @source_deal_type_id 
	AND source_system_id = @source_system_id
	IF (@cont>0)
	BEGIN
		SELECT 'Error', 'Deal Type ID must be unique', 
			'spa_application_security_role', 'DB Error', 
			'Deal Type ID must be unique', ''
		RETURN
	END
	UPDATE source_deal_type 
	SET source_system_id = @source_system_id, deal_type_id=@deal_type_id, 
		source_deal_type_name = @source_deal_type_name, source_deal_desc = @source_deal_desc,
		sub_type=@sub_type ,
		disable_gui_groups=@disable_gui_groups,
		expiration_applies=@expiration_applies,
		update_user=@user_name, update_ts = getdate()
	WHERE source_deal_type_id = @source_deal_type_id

	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_deal_type_maintain', 'DB Error', 
				'Failed to update defination value.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_deal_type_maintain', 'Success', 
				'Defination data value updated.', @source_deal_type_id
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DELETE FROM source_deal_type
			WHERE source_deal_type_id = @source_deal_type_id		
			
			EXEC spa_ErrorHandler 0
			, 'MaintainDefination'
			, 'spa_source_deal_type_maintain'
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
			, 'spa_source_deal_type_maintain'
			, 'DB Error'
			, 'Selected data is in use and cannot be deleted.'
			, 'Foreign key constrains'
	END CATCH
END

ELSE IF @flag = 'e' --for callback function to get gis value
BEGIN
	 SELECT disable_gui_groups FROM source_deal_type WHERE source_deal_type_id = @source_deal_type_id
END

ELSE IF @flag = 'x' -- used to populate drop down
BEGIN
	SET @Sql_Select = 'SELECT sdt.source_deal_type_id,
	                          sdt.source_deal_type_name,
								MIN(fpl.is_enable) [status]
						FROM #final_privilege_list fpl
						' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
							source_deal_type sdt ON sdt.source_deal_type_id = fpl.value_id
	                   WHERE 1 = 1 '

	SET @Sql_Select += ' AND ISNULL(sdt.sub_type, ''n'') = ''' + ISNULL(@sub_type, 'n') + ''''
	
	SET @Sql_Select += ' GROUP BY sdt.source_deal_type_id, sdt.source_deal_type_name
							ORDER BY sdt.source_deal_type_name '
	EXEC(@Sql_Select)	
	
END
ELSE IF @flag ='y'
BEGIN
	SET @Sql_Select = '
		SELECT DISTINCT d.source_deal_type_id,
						d.source_deal_type_name + CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE ''.'' + ssd.source_system_name END source_system_name,
						MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_deal_type d ON d.source_deal_type_id = fpl.value_id
		INNER JOIN source_system_description ssd ON  d.source_system_id = ssd.source_system_id
		INNER JOIN fas_strategy c ON d.source_system_id = c.source_system_id 
		INNER JOIN portfolio_hierarchy b ON b.parent_entity_id = c.fas_strategy_id
			AND b.entity_id = ISNULL(' + ISNULL(CAST(@fas_book_id AS NVARCHAR), 'NULL') + ', b.entity_id)
		WHERE ISNULL(d.sub_type ,''n'') = ''' + ISNULL(@sub_type, 'n') + ''''

		IF @source_deal_type_id IS NOT NULL
			SET @Sql_Select = @Sql_Select + ' and d.source_deal_type_id = ' + CAST(@source_deal_type_id AS NVARCHAR)

		IF @source_system_id IS NOT NULL
			SET @Sql_Select = @Sql_Select + ' and d.source_system_id = ' + CAST(@source_system_id AS NVARCHAR)
		
		SET @Sql_Select += 'GROUP BY d.source_deal_type_id, d.source_deal_type_name, ssd.source_system_id, ssd.source_system_name
	'
	EXEC(@Sql_Select)
END
