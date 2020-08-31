
IF OBJECT_ID(N'spa_source_legal_entity_maintain', N'P') IS NOT NULL
DROP PROCEDURE spa_source_legal_entity_maintain
 GO 
CREATE proc [dbo].[spa_source_legal_entity_maintain]	@flag as Char(1),					
						@source_legal_entity_id int=null,				
						@source_System_id int=null,
						@legal_entity_id varchar(50)=null,
						@legal_entity_Name varchar(100)=null,
						@legal_entity_desc varchar(500)=null,
						@user_Name varchar(50)=null

AS 
Declare @Sql_Select varchar(5000)

if @flag='i'
BEGIN
	declare @cont1 varchar(100)
	select @cont1= count(*) from source_legal_entity where legal_entity_id =@legal_entity_id AND source_System_id=@source_System_id
	if (@cont1>0)
	BEGIN
		SELECT 'Error', 'Can not insert duplicate ID :'+@legal_entity_id, 
			'spa_application_security_role', 'DB Error', 
			'Can not insert duplicate ID :'+@legal_entity_id, ''
		RETURN
	END
INSERT INTO source_legal_entity
		(
		source_System_id,
		legal_entity_id,
		legal_entity_Name,
		legal_entity_desc,
		create_user,
		create_ts,
		update_user,
		update_ts
		)
	values
		(				
		@source_System_id,
		@legal_entity_id,		
		@legal_entity_Name,
		@legal_entity_desc,
		@user_Name,
		getdate(),
		@user_Name,
		getdate()
		)
		
		SET @source_legal_entity_id = SCOPE_IDENTITY()

		IF @@Error <> 0
		    EXEC spa_ErrorHandler @@Error,
		         'MaintainDefination',
		         'spa_source_legal_entity_maintain',
		         'DB Error',
		         'Failed to insert defination value.',
		         ''
		ELSE
		    EXEC spa_ErrorHandler 0,
		         'MaintainDefination',
		         'spa_source_legal_entity_maintain',
		         'Success',
		         'Defination data value inserted.',
		         @source_legal_entity_id
end

ELSE IF @flag = 'a'
BEGIN
	SELECT source_legal_entity.source_legal_entity_id,
	       source_System_Description.source_System_Name,
	       source_legal_entity.legal_entity_id,
	       source_legal_entity.legal_entity_Name,
	       source_legal_entity.legal_entity_desc
	FROM   source_legal_entity
	       INNER JOIN source_System_Description ON  source_System_Description.source_System_id = source_legal_entity.source_System_id
	WHERE  source_legal_entity_id = @source_legal_entity_id
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'source_legal_entity table',
	         'spa_source_legal_entity_maintain',
	         'DB Error',
	         'Failed to select maintain defiantion detail record of Item type.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'source_legal_entity table',
	         'spa_source_legal_entity_maintain',
	         'Success',
	         'source_legal_entity detail record of Item Type successfully selected.',
	         ''
END

ELSE IF @flag = 's' -- Modified with privilege for Legal Entity Dropdown
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'legal_entity'

	SET @Sql_Select='SELECT sle.source_legal_entity_id,
	                        sle.legal_entity_Name + CASE WHEN ssd.source_System_id = 2 THEN ''''
	                                                 ELSE ''.'' + ssd.source_System_Name
	                                            END AS Name,
							MIN(fpl.is_enable) [status]
	                 FROM #final_privilege_list fpl
					' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
						source_legal_entity sle ON sle.source_legal_entity_id = fpl.value_id
	                        INNER JOIN source_System_Description ssd
	                             ON  ssd.source_System_id = sle.source_System_id'
	IF @source_System_id IS NOT NULL
	    SET @Sql_Select = @Sql_Select + ' WHERE sle.source_System_id=' + CONVERT(VARCHAR(20), @source_System_id) + ''
	SET @Sql_Select += ' GROUP BY sle.source_legal_entity_id, sle.legal_entity_Name, ssd.source_System_id, ssd.source_System_Name'
	EXEC (@SQL_select)
END
ELSE IF @flag = 'l' --list in grid .. without suffixing source System id.
BEGIN
	SET @Sql_Select = 
	    'SELECT source_legal_entity.source_legal_entity_id,
	            legal_entity_Name AS Name,
	            source_legal_entity.legal_entity_desc AS Description,
	            source_System_Description.source_System_Name AS System
	     FROM   source_legal_entity
	            INNER JOIN source_System_Description ON source_System_Description.source_System_id = source_legal_entity.source_System_id'
	
	IF @source_System_id IS NOT NULL
	    SET @Sql_Select = @Sql_Select + ' where source_legal_entity.source_System_id=' + CONVERT(VARCHAR(20), @source_System_id) + ''
	
	EXEC (@SQL_select)
END

ELSE IF @flag = 'u'
BEGIN
	DECLARE @cont VARCHAR(100)
	
	SELECT @cont = COUNT(*)
	FROM   source_legal_entity
	WHERE  legal_entity_id = @legal_entity_id
	       AND source_System_id = @source_System_id
	       AND source_legal_entity_id <> @source_legal_entity_id
	
	IF (@cont > 0)
	BEGIN
		SELECT 'Error',
		       'Can not update duplicate ID :' + @legal_entity_id,
		       'spa_application_security_role',
		       'DB Error',
		       'Can not update duplicate ID :' + @legal_entity_id,
		       ''
		RETURN
	END
	UPDATE source_legal_entity
	SET    source_System_id = @source_System_id,
	       legal_entity_id = @legal_entity_id,
	       legal_entity_Name = @legal_entity_Name,
	       legal_entity_desc = @legal_entity_desc,
	       update_user = @user_Name,
	       update_ts = GETDATE()
	WHERE  source_legal_entity_id = @source_legal_entity_id

	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'MaintainDefination',
	         'spa_source_legal_entity_maintain',
	         'DB Error',
	         'Failed to update defination value.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'MaintainDefination',
	         'spa_source_legal_entity_maintain',
	         'Success',
	         'Defination data value updated.',
	         @source_legal_entity_id
END

ELSE IF @flag = 'd'
BEGIN
	DELETE 
	FROM   source_legal_entity
	WHERE  source_legal_entity_id = @source_legal_entity_id
	
	EXEC spa_maintain_udf_header 'd', NULL, @source_legal_entity_id
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         "MaintainDefination",
	         "spa_source_legal_entity_maintain",
	         "DB Error",
	         "Delete of Maintain Defination Data failed.",
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'MaintainDefination',
	         'spa_source_legal_entity_maintain',
	         'Success',
	         'Maintain Defination Data sucessfully deleted',
	         ''
END
ELSE IF @flag = 'g'
BEGIN
	SET @Sql_Select='SELECT source_legal_entity.source_legal_entity_id,
	                        legal_entity_Name + CASE WHEN source_System_Description.source_System_id = 2 THEN ''''
	                                                 ELSE ''.'' + source_System_Description.source_System_Name
	                                            END AS Name
	                 FROM   source_legal_entity
	                        INNER JOIN source_System_Description
	                             ON  source_System_Description.source_System_id = source_legal_entity.source_System_id'
	IF @source_System_id IS NOT NULL
	    SET @Sql_Select = @Sql_Select + ' where source_legal_entity.source_System_id=' + CONVERT(VARCHAR(20), @source_System_id) + ''
	EXEC (@SQL_select)
END

ELSE IF @flag = 'k' 
BEGIN
	set @Sql_Select='SELECT source_legal_entity.source_legal_entity_id,
	                        legal_entity_Name + CASE WHEN source_System_Description.source_System_id = 2 THEN ''''
	                                                 ELSE '''' + source_System_Description.source_System_Name
	                                            END AS Name
	                 FROM   source_legal_entity
	                        INNER JOIN source_System_Description
	                             ON  source_System_Description.source_System_id = source_legal_entity.source_System_id'
	IF @source_System_id IS NOT NULL
	    SET @Sql_Select = @Sql_Select + ' where source_legal_entity.source_System_id=' + CONVERT(VARCHAR(20), @source_System_id) + ''
	EXEC (@SQL_select)
END



