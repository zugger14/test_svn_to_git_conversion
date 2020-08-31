
/****** Object:  StoredProcedure [dbo].[spa_source_product]    Script Date: 05/08/2009 12:54:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_product]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_source_product]
GO 

/*



[spa_source_product] 's'
[spa_source_product] 'a',10
[spa_source_product] 'u',10,2,'test','test','test'
[spa_source_product] 'a',10
[spa_source_product] 'i',null,2,'test1','test1','test1'
[spa_source_product] 's'

*/

CREATE PROCEDURE [dbo].[spa_source_product]	
	@flag AS CHAR(1),					
	@source_product_id INT = NULL,
	@source_system_id INT = NULL,
	@product_id VARCHAR(50) = NULL,
	@product_name VARCHAR(100) = NULL,
	@product_desc VARCHAR(250) = NULL,
	@strategy_id INT = NULL
AS 
SET NOCOUNT ON
DECLARE @Sql_Select VARCHAR(5000)

IF @flag='i'
BEGIN
	DECLARE @cont1 VARCHAR(100)
	SELECT @cont1 = COUNT(*)
	FROM   source_product
	WHERE  product_id = @product_id
	       AND source_system_id = @source_system_id
	
	IF (@cont1 > 0)
	BEGIN
		SELECT 'Error', 'Product ID must be unique', 
			'spa_application_security_role', 'DB Error', 
			'Product ID must be unique', ''
		RETURN
	END
	INSERT INTO source_product
		(
			source_system_id
			,product_id
			,product_name
			,product_desc
			,create_user
			,create_ts
			,update_user
			,update_ts
		)
	VALUES
		(				
			@source_system_id
			,@product_id
			,@product_name
			,@product_desc
			,dbo.FNADBUser()
			,GETDATE()
			,dbo.FNADBUser()
			,GETDATE()
		)
		
		SET @source_product_id = SCOPE_IDENTITY()
		 
		IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error,
		     'source_product',
		     'spa_source_product',
		     'DB Error',
		     'Failed to insert value.',
		     ''
		ELSE
		EXEC spa_ErrorHandler 0,
		     'source_product',
		     'spa_source_product',
		     'Success',
		     'source_product data value inserted.',
		     @source_product_id
END

ELSE IF @flag = 'a'
     BEGIN
         SELECT source_product_id,
                source_system_description.source_system_name,
                product_id,
                product_name,
                product_desc
         FROM   source_product s
                INNER JOIN source_system_description
                     ON  source_system_description.source_system_id = s.source_system_id
         WHERE  source_product_id = @source_product_id
	

	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'source_product table',
	         'spa_source_product',
	         'DB Error',
	         'Failed to select source_product detail record.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'source_product table',
	         'spa_source_product',
	         'Success',
	         'source_product detail record successfully selected.',
	         ''
     END
ELSE IF  @flag='s' 
BEGIN
SET @Sql_Select=' select
		source_product_id ID,
		product_name + CASE WHEN source_system_description.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END AS Name,
		product_desc Description,
		source_system_description.source_system_name System,
		dbo.FNADateTimeFormat(s.create_ts,1) [Created Date],
		s.create_user [Created User],
		s.update_user [Updated User]  ,
		dbo.FNADateTimeFormat(s.update_ts,1) [Updated Date]
			from source_product s
			 inner join source_system_description on
				source_system_description.source_system_id = s.source_system_id 
	
'
	IF @strategy_id IS NOT NULL
	    SET @Sql_Select = @Sql_Select + 
	        ' inner join fas_strategy fs on fs.source_system_id = source_system_description.source_system_id where fs.fas_strategy_id='
	        + CAST(@strategy_id AS VARCHAR)
	
	IF @source_system_id IS NOT NULL
	   AND @strategy_id IS NOT NULL
	    SET @Sql_Select = @Sql_Select + ' and s.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)
	
	IF @source_system_id IS NOT NULL
	   AND @strategy_id IS NULL
	    SET @Sql_Select = @Sql_Select + ' where s.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)
	
	SET @Sql_Select = @Sql_Select + ' order by product_name'
	exec spa_print @SQL_select
	EXEC (
	         @SQL_select)
END

ELSE IF @flag = 'l' --list in grid .. without suffixing source system id.
BEGIN
SET @Sql_Select=' select
		source_product_id ID,
		product_name AS Name,
		product_desc Description,
			source_system_description.source_system_name System,
		s.create_ts [Created Date],
		s.create_user [Created User],
		s.update_user [Updated User]  ,
		dbo.FNADateTimeFormat(s.update_ts,1) [Updated Date]
	from source_product s
	 inner join source_system_description on
		source_system_description.source_system_id = s.source_system_id 
	order by product_name
'
	IF @source_system_id IS NOT NULL
	    SET @Sql_Select = @Sql_Select + ' where s.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)
	
	exec spa_print @SQL_select
	EXEC (@SQL_select)
END

ELSE IF @flag = 'u'

BEGIN
	DECLARE @cont VARCHAR(100)
	SELECT @cont = COUNT(*)
	FROM   source_product
	WHERE  product_id = @product_id
	       AND source_system_id = @source_system_id
	       AND source_product_id <> @source_product_id
	
	IF (@cont > 0)
	BEGIN
		SELECT 'Error', 'Product ID must be unique', 
			'spa_application_security_role', 'DB Error', 
			'Product ID must be unique', ''
		RETURN
	END

	UPDATE source_product
	SET    product_id = @product_id,
	       product_name = @product_name,
	       product_desc = @product_desc,
	       update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	WHERE  source_product_id = @source_product_id

	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'source_product',
	         'spa_source_product',
	         'DB Error',
	         'Failed to update source_product.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'source_product',
	         'spa_source_product',
	         'Success',
	         'source_product data value updated.',
	         @source_product_id
END

ELSE IF @flag = 'd'
     BEGIN
         DELETE 
         FROM   source_product
         WHERE  source_product_id = @source_product_id

		 EXEC spa_maintain_udf_header 'd', NULL, @source_product_id
		 
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         "source_product",
	         "spa_source_product",
	         "DB Error",
	         "Delete of source_product Data failed.",
	         ''
	ELSE
		EXEC spa_ErrorHandler 0,
		     'source_product',
		     'spa_source_product',
		     'Success',
		     'source_product Data sucessfully deleted',
		     ''
END
ELSE IF @flag = 'g' -- Modified to use as Product Dropdown with privilege
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'product'

	SET @Sql_Select = '
		SELECT	spr.source_product_id ID, 
				spr.product_name Name,
				MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_product spr ON spr.source_product_id = fpl.value_id
		GROUP BY spr.source_product_id, spr.product_name
		ORDER BY spr.product_name
	'
	EXEC(@Sql_Select)
END
