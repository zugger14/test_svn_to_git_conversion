
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[spa_source_book_maintain]', N'P') IS NOT NULL
    DROP PROC [dbo].[spa_source_book_maintain]
GO

--spa_source_book_maintain 's',null,1
CREATE PROC [dbo].[spa_source_book_maintain]	
	@flag AS CHAR(1),	
	@source_book_id INT = NULL,									
	@source_system_id INT = NULL,				
	@source_system_book_id VARCHAR(50) = NULL,
	@source_system_book_type_value_id INT = NULL,
	@source_book_name VARCHAR(100) = NULL,
	@source_book_desc VARCHAR(500) = NULL,
	@user_name VARCHAR(50) = NULL,
	@hedge_item_flag CHAR(1) = NULL
AS 
IF @flag IN ('x', 'y')
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'book'
END

DECLARE @Sql_Select VARCHAR(5000)

IF @flag = 'i'
BEGIN
    DECLARE @cont1 VARCHAR(100)
    
    SELECT @cont1 = COUNT(*) FROM source_book
    WHERE  source_system_book_id = @source_system_book_id AND source_system_id = @source_system_id
    
    IF (@cont1 > 0)
    BEGIN
        SELECT 'Error',
               'Can not insert duplicate ID :' + @source_system_book_id,
               'spa_application_security_role',
               'DB Error',
               'Can not insert duplicate ID :' + @source_system_book_id,
               ''
        
        RETURN
    END
    
    INSERT INTO source_book
      (
        source_system_id,
        source_system_book_id,
        source_system_book_type_value_id,
        source_book_name,
        source_book_desc,
        update_user,
        update_ts
      )
    VALUES
      (
        @source_system_id,
        @source_system_book_id,
        @source_system_book_type_value_id,
        @source_book_name,
        @source_book_desc,
        ISNULL(@user_name, dbo.FNADBUser()),
        GETDATE()
      )
      
    SET @source_book_id = SCOPE_IDENTITY()
    
    IF @@Error <> 0
        EXEC spa_ErrorHandler @@Error,
             'MaintainDefination',
             'spa_source_book_maintain',
             'DB Error',
             'Failed to insert defination value.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'MaintainDefination',
             'spa_source_book_maintain',
             'Success',
             'Defination data value inserted.',
             @source_book_id
END

ELSE IF @flag = 'a'
 BEGIN
     SELECT source_book.source_book_id,
            source_system_description.source_system_name,
            source_book.source_system_book_id,
            source_book.source_system_book_type_value_id,
            source_book.source_book_name AS Name,
            source_book.source_book_desc AS Description
     FROM   source_book
     INNER JOIN source_system_description ON  source_system_description.source_system_id = source_book.source_system_id
     WHERE  source_book_id = @source_book_id         
     
     IF @@ERROR <> 0
         EXEC spa_ErrorHandler @@ERROR,
              'Source_book table',
              'spa_source_book_maintain',
              'DB Error',
              'Failed to select maintain defiantion detail record of Item type.',
              ''
     ELSE
         EXEC spa_ErrorHandler 0,
              'Source_book table',
              'spa_source_book_maintain',
              'Success',
              'Source_book detail record of Item Type successfully selected.',
              ''
 END

ELSE IF @flag = 's'
 BEGIN
     SET @Sql_Select = 'SELECT source_book.source_book_id [Book ID],
                               source_book.source_book_name + CASE WHEN source_book.source_system_id = 2 THEN '''' 
																	ELSE ''.'' + source_system_description.source_system_name
                                                              END AS Name,
                               source_book.source_book_desc AS Description,
                               source_system_description.source_system_name AS SYSTEM,
                               source_system_book_id [Source System Book ID],
                               source_system_book_type_value_id [Type/Level ID],
                               dbo.FNADateFormat(source_book.create_ts) [Created Date],
                               source_book.create_user [Created User],
                               dbo.FNADateFormat(source_book.update_ts) [Updated Date],
                               source_book.update_user [Updated User]
                        FROM   source_book 
						INNER JOIN source_system_description 
							ON	source_system_description.source_system_id = source_book.source_system_id
						WHERE 1=1 '
     
     IF @source_system_id IS NOT NULL
         SET @Sql_Select = @Sql_Select + ' AND source_book.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id) + ''
     
     IF @source_system_book_type_value_id IS NOT NULL
         SET @Sql_Select = @Sql_Select + ' AND source_system_book_type_value_id=' + CONVERT(VARCHAR(20), @source_system_book_type_value_id) + ''
     
     SET @Sql_Select = @Sql_Select + ' order by source_book_name '
     
     --PRINT (@SQL_select)
     EXEC (@SQL_select)
 END

ELSE IF @flag = 'u'
 BEGIN
     DECLARE @cont VARCHAR(100)
     
     SELECT @cont = COUNT(*)
     FROM   source_book
     WHERE  source_system_book_id = @source_system_book_id
        AND source_book_id <> @source_book_id
        AND source_system_id = @source_system_id
     
     IF (@cont > 0)
     BEGIN
         SELECT 'Error',
                'Can not update duplicate ID :' + @source_system_book_id,
                'spa_application_security_role',
                'DB Error',
                'Can not update duplicate ID :' + @source_system_book_id,
                @source_book_id
         
         RETURN
     END
     
     UPDATE source_book
     SET    source_system_id = @source_system_id,
            source_book_name = @source_book_name,
            source_book_desc = @source_book_desc,
            source_system_book_id = @source_system_book_id,
            source_system_book_type_value_id = @source_system_book_type_value_id,
            update_user = ISNULL(@user_name, dbo.FNADBUser()),
            update_ts = GETDATE()
     WHERE  source_book_id = @source_book_id
     
     IF @@Error <> 0
         EXEC spa_ErrorHandler @@Error,
              'MaintainDefination',
              'spa_source_book_maintain',
              'DB Error',
              'Failed to update defination value.',
              ''
     ELSE
         EXEC spa_ErrorHandler 0,
              'MaintainDefination',
              'spa_source_book_maintain',
              'Success',
              'Defination data value updated.',
              @source_book_id
 END

ELSE IF @flag = 'd'
 BEGIN
     IF EXISTS (
            SELECT 1
            FROM   source_system_book_map WITH(NOLOCK)
            WHERE  source_system_book_id1 = @source_book_id
                   OR  source_system_book_id2 = @source_book_id
                   OR  source_system_book_id3 = @source_book_id
                   OR  source_system_book_id4 = @source_book_id
        )
        OR EXISTS (
               SELECT 1
               FROM   source_deal_header WITH(NOLOCK)
               WHERE  source_system_book_id1 = @source_book_id
                      OR  source_system_book_id2 = @source_book_id
                      OR  source_system_book_id3 = @source_book_id
                      OR  source_system_book_id4 = @source_book_id
           )
     BEGIN
         EXEC spa_ErrorHandler 1,
              'The selected source book can not be deleted.It is mapped into a source book mapping.',
              'spa_source_book_maintain',
              'DB Error'
              --, 'The selected source book can not be deleted.It is mapped into a source book mapping.'
              ,'Selected data is in use and cannot be deleted.'
              ,''
         
         RETURN
     END
     
     DELETE FROM source_book WHERE  source_book_id = @source_book_id
     EXEC spa_maintain_udf_header 'd', NULL, @source_book_id
     
     IF @@ERROR <> 0
         EXEC spa_ErrorHandler @@ERROR,
              "MaintainDefination",
              "spa_source_book_maintain",
              "DB Error",
              "Delete of Maintain Defination Data failed.",
              ''
     ELSE
         EXEC spa_ErrorHandler 0,
              'MaintainDefination',
              'spa_source_book_maintain',
              'Success',
              'Maintain Defination Data sucessfully deleted',
              ''
 END
 ELSE IF @flag = 'c'
 BEGIN
	SELECT book_deal_type_map_id, logical_name FROM source_system_book_map
 END 
 ELSE IF @flag = 'x' -- Modified to use in book attribute dropdown with privilege
 BEGIN
	SET @Sql_Select = '
 		SELECT	sb.source_book_id,
				sb.source_book_name,
				MIN(fpl.is_enable) [status] 
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_book sb ON sb.source_book_id = fpl.value_id
		WHERE 1 = 1'
	IF @source_system_book_type_value_id IS NOT NULL 
		SET @Sql_Select += ' AND sb.source_system_book_type_value_id = ' + CAST(@source_system_book_type_value_id AS VARCHAR(10))

	SET @Sql_Select += ' GROUP BY sb.source_book_id, sb.source_book_name
						ORDER BY sb.source_book_name'

	EXEC(@Sql_Select)
 END
 ELSE IF @flag = 'y' -- Added to use in book attribute dropdown with privilege
 BEGIN
	SET @Sql_Select = '
		SELECT  ssbm.book_deal_type_map_id AS ID, 
				ph.entity_name +'' | '' +sb.source_book_name +'' | ''+  
					sb1.source_book_name +'' | ''+ sb2.source_book_name +'' | ''+ sb3.source_book_name +'' | ''+ sdv.code as group1,
				MIN(fpl.is_enable) [status] 
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_book sb ON sb.source_book_id = fpl.value_id
			INNER JOIN source_system_book_map ssbm on ssbm.source_system_book_id1 = sb.source_book_id
			INNER JOIN source_book sb1 ON ssbm.source_system_book_id2 = sb1.source_book_id
			INNER JOIN source_book sb2 ON ssbm.source_system_book_id3 = sb2.source_book_id
			INNER JOIN source_book sb3 ON ssbm.source_system_book_id4 = sb3.source_book_id
			INNER JOIN static_data_value sdv ON ssbm.fas_deal_type_value_id = sdv.value_id
			INNER JOIN portfolio_hierarchy ph ON ph.entity_id = ssbm.fas_book_id
		WHERE  1=1 '+CASE WHEN @source_book_id IS NOT NULL THEN ' AND (ssbm.fas_book_id IN (' + CAST(@source_book_id AS VARCHAR) + ')) ' ELSE '' END
	
	IF @hedge_item_flag IS NOT NULL 
	BEGIN
		IF @hedge_item_flag = 'h'
			SET @Sql_Select = @Sql_Select + ' and ssbm.fas_deal_type_value_id = 400'
		ELSE IF @hedge_item_flag = 'i'
			SET @Sql_Select = @Sql_Select + ' and ssbm.fas_deal_type_value_id = 401'
		ELSE IF @hedge_item_flag = 'e'
			SET @Sql_Select = @Sql_Select + ' and ssbm.fas_deal_type_value_id not in (400,401,402,404,409)'
	END 
	ELSE
		SET @Sql_Select = @Sql_Select + ' and ssbm.fas_deal_type_value_id  in (400,401,402,404,409)'

	SET @Sql_Select += ' GROUP BY ssbm.book_deal_type_map_id, ph.entity_name, sb.source_book_name, sb1.source_book_name, sb2.source_book_name, sb3.source_book_name, sdv.code
						'
	EXEC(@Sql_Select)
 END
 ELSE IF @flag = 'z'
 BEGIN
	SELECT DISTINCT ssbm.book_deal_type_map_id,
				sub.entity_name subsidiary,				
				stra.entity_name strategy,
				book.entity_name book,
				ssbm.logical_name subbook      
	FROM   portfolio_hierarchy book(NOLOCK)
	INNER JOIN Portfolio_hierarchy stra(NOLOCK)
		ON  book.parent_entity_id = stra.entity_id
	INNER JOIN portfolio_hierarchy sub (NOLOCK)
		ON  stra.parent_entity_id = sub.entity_id
	INNER JOIN source_system_book_map ssbm
		ON  ssbm.fas_book_id = book.entity_id
 END
 
