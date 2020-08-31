

/****** Object:  StoredProcedure [dbo].[spa_privilege_report]    Script Date: 09/03/2009 10:48:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_privilege_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_privilege_report]
GO

-- exec spa_privilege_report 'f'
CREATE PROCEDURE [dbo].[spa_privilege_report]
	@flag char(1),
	@user_login_id varchar(50)=NULL,
	@role_id int=NULL,
	@product_id INT = 10000000,
	@batch_process_id varchar(50)=NULL,
	@batch_report_param varchar(500)=NULL   ,
	@enable_paging INT = NULL,   --'1'=enable, '0'=disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS	

SET NOCOUNT on
DECLARE @sql VARCHAR(MAX)


/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR(MAX)
DECLARE @sql_paging VARCHAR(MAX)
DECLARE @is_batch BIT
DECLARE @user_login_id1 varchar(50)=NULL 

SET @str_batch_table = ''
SET @user_login_id1 = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id1, @batch_process_id)
 
IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()
 
   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
 
   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END
 
/*******************************************1st Paging Batch END**********************************************/


IF @flag = 'a'
BEGIN
    SET @sql = 
        ' SELECT role_id as [Role ID]
						,role_name as [Role Name]
						,role_description as [Role Description]
						,static_data_value.code as [Role Type]
						' + @str_batch_table + '
						FROM application_security_role 
						INNER JOIN static_data_value ON application_security_role.role_type_value_id = static_data_value.value_id'
    
    IF @role_id IS NOT NULL
    BEGIN
        SET @sql = @sql + ' WHERE application_security_role.role_id=' + CONVERT(VARCHAR(20), @role_id)  + ''
    END
    
    SET @sql = @sql + ' ORDER BY application_security_role.role_name ASC'
    
    EXEC (@sql)
END

ELSE IF @flag = 'b'
BEGIN
    SET @sql = 
        ' SELECT CASE WHEN (user_active = ''y'') THEN ''Yes'' ELSE ''No'' END as [Active]
				,ISNULL(user_l_name,'''') + '', '' + user_f_name + '' '' + ISNULL(user_m_name,'''') as [User]
				,user_login_id as [Login ID]
				,user_off_tel as [Office Telephone]
				,user_emal_add as [Email Address] ' + @str_batch_table + ' 
				From application_users'
         
    IF @user_login_id IS NOT NULL
        SET @sql = @sql + ' where application_users.user_login_id=''' + @user_login_id + ''''
                 
    SET @sql = @sql + ' order by application_users.user_l_name asc'
         
    EXEC (@sql)
END

ELSE IF @flag = 'c'
BEGIN
	SET @sql = 
	    ' SELECT application_security_role.role_name as [Role Name]
						,static_data_value.code as [Role Type]
						,ISNULL(application_users.user_l_name,'''') + '', '' + ISNULL(application_users.user_f_name,'''') + '' '' + ISNULL(application_users.user_m_name,'''') as [User]
 						,application_users.user_off_tel as [Office Telephone]
						,application_users.user_emal_add as [Email Address] 
						' + @str_batch_table + '
						FROM application_security_role inner join application_role_user ON application_security_role.role_id = application_role_user.role_id
						INNER JOIN static_data_value ON application_security_role.role_type_value_id = static_data_value.value_id
						INNER JOIN application_users ON application_users.user_login_id=application_role_user.user_login_id'
	
	IF @role_id IS NOT NULL
	   AND @user_login_id IS NOT NULL
	    SET @sql = @sql + ' WHERE application_security_role.role_id=' + CONVERT(VARCHAR(20), @role_id) + ' AND application_role_user.user_login_id=''' + @user_login_id +''''
	
	IF @role_id IS NOT NULL
	   AND @user_login_id IS NULL
	    SET @sql = @sql + ' WHERE application_security_role.role_id=' + CONVERT(VARCHAR(20), @role_id) + ''
	
	IF @user_login_id IS NOT NULL  AND @role_id IS NULL
	    SET @sql = @sql + ' WHERE application_role_user.user_login_id=''' + @user_login_id + ''''
	
	SET @sql = @sql + ' ORDER BY application_security_role.role_name ASC'
	
	EXEC (@sql)
END

ELSE IF @flag = 'd'
BEGIN
	SET @sql = 
	    ' SELECT CASE WHEN (user_active = ''y'') THEN ''Yes'' ELSE ''No'' END as [Active]
				,ISNULL(user_l_name,'''') + '', '' + user_f_name + '' '' + ISNULL(user_m_name,'''') as [User]
				,application_users.user_login_id as [Login ID]
				,user_off_tel as [Office Telephone], user_emal_add as [Email Address]
				,application_security_role.role_id as [Role ID]
				,application_security_role.role_name as [Role Name] 
				,application_security_role.role_description as [Role Description]
				, static_data_value.code as [Role Type]
				' + @str_batch_table + '
				From application_users inner join application_role_user on application_users.user_login_id = application_role_user.user_login_id
				inner join application_security_role on application_role_user.role_id = application_security_role.role_id inner join static_data_value on										application_security_role.role_type_value_id = static_data_value.value_id'
	
	IF @role_id IS NOT NULL
	   AND @user_login_id IS NOT NULL
	    SET @sql = @sql + ' where application_security_role.role_id=' + CONVERT(VARCHAR(20), @role_id) + ' and application_users.user_login_id=''' + @user_login_id + ''''
	
	IF @role_id IS NOT NULL
	   AND @user_login_id IS NULL
	    SET @sql = @sql + ' where application_security_role.role_id=' + CONVERT(VARCHAR(20), @role_id) + ''
	
	IF @user_login_id IS NOT NULL
	   AND @role_id IS NULL
	    SET @sql = @sql + ' where application_users.user_login_id=''' + @user_login_id  + ''''
	
	SET @sql = @sql + ' order by application_users.user_l_name asc'
	
	EXEC (@sql)
END

ELSE IF @flag = 'e'
BEGIN
--Block of code added from spa_AccessRights flag n
	IF OBJECT_ID('tempdb..#role_privilege') IS NOT NULL
		DROP TABLE #role_privilege
		
	CREATE TABLE #role_privilege
	(
		function_id1  INT ,
		function_name1 NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id2	INT	,
		function_name2  NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id3		INT,
		function_name3  NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id4		INT,
		function_name4  NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id5		INT,
		function_name5  NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id6		INT,
		function_name6  NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id7		INT,
		function_name7  NVARCHAR(200) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #role_privilege(
		function_id1,
		function_name1,
		function_id2,
		function_name2,
		function_id3,
		function_name3,
		function_id4,
		function_name4,
		function_id5,
		function_name5,
		function_id6,
		function_name6,
		function_id7,
		function_name7
	)
	EXEC spa_setup_menu @flag = 'b', @product_category = @product_id
	
	SET @sql = 
		 '  SELECT DISTINCT application_security_role.role_name as [Role Name]
				,static_data_value.code as [Role Type]
				,application_functions.function_id as [Function ID]
				,aft.function_path [Function Name]
				,ISNULL(portfolio_hierarchy.entity_name,''ALL'') as [Entity Name]
				' + @str_batch_table + '
				FROM  application_functions 
				INNER JOIN  #role_privilege priv ON application_functions.function_id = 
					COALESCE(priv.function_id6,priv.function_id5,priv.function_id4,priv.function_id3,priv.function_id2,priv.function_id1)
				LEFT JOIN dbo.FNAApplicationFunctionsHierarchy(' + CAST(@product_id AS NVARCHAR(8)) +') aft ON aft.function_id = application_functions.function_id
				INNER JOIN	application_functional_users on application_functions.function_id=application_functional_users.function_id 
				INNER JOIN application_security_role on application_security_role.role_id=application_functional_users.role_id
				INNER JOIN static_data_value on application_security_role.role_type_value_id = static_data_value.value_id
				LEFT OUTER  join portfolio_hierarchy on application_functional_users.entity_id = portfolio_hierarchy.entity_id
				WHERE aft.function_path IS NOT NULL'
	
	IF @role_id IS NOT NULL
	    SET @sql = @sql + ' AND application_security_role.role_id=' + CONVERT(VARCHAR(20), @role_id) + ''	
	
	SET @sql = @sql + ' order by application_security_role.role_name asc'
	
	EXEC (@sql)
END

ELSE IF @flag = 'f'
BEGIN
	CREATE TABLE #temp_store_F(
			[User] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[Role Name] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[Function Name] VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
			[Entity Name] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL
	)
	EXEC spa_print 'temp table created'
	
	SET @sql = 
			'insert into #temp_store_F Select [User],[Role Name],[Function Name],[Entity Name] from
			((select ISNULL(user_l_name,'''') + '', '' + user_f_name + '' '' + ISNULL(user_m_name,'''') as [User],
			application_users.user_login_id,	
			application_security_role.role_name as [Role Name],
			aft.function_path [Function Name],
			ISNULL(portfolio_hierarchy.entity_name, ''ALL'') as [Entity Name]
			From application_security_role 
			INNER join application_role_user on application_security_role.role_id=application_role_user.role_id 
			INNER join application_users on application_role_user.user_login_id=application_users.user_login_id 
			INNER join static_data_value on	application_security_role.role_type_value_id = static_data_value.value_id 
			left outer  join application_functional_users on application_functional_users.role_id=application_security_role.role_id
			left outer join application_functions on  application_functions.function_id = application_functional_users.function_id
			LEFT OUTER  join portfolio_hierarchy on application_functional_users.entity_id = portfolio_hierarchy.entity_id
			LEFT JOIN dbo.FNAApplicationFunctionsHierarchy(' + CAST(@product_id AS NVARCHAR(8)) + ') aft ON aft.function_id = application_functions.function_id
			WHERE aft.function_path IS NOT NULL) 
			UNION 
			(select ISNULL(user_l_name,'''') + '', '' + user_f_name + '' '' + ISNULL(user_m_name,'''') as [User],
			application_users.user_login_id,
			''Additional'' as [Role Name],
			aft.function_path [Function Name],
			ISNULL(portfolio_hierarchy.entity_name, ''ALL'') as [Entity Name]
			From application_functions 
			inner join application_functional_users on application_functions.function_id=application_functional_users.function_id 
			INNER join application_users on application_functional_users.login_id=application_users.user_login_id 
			LEFT OUTER  join portfolio_hierarchy on application_functional_users.entity_id = portfolio_hierarchy.entity_id
			LEFT JOIN dbo.FNAApplicationFunctionsHierarchy(' + CAST(@product_id AS NVARCHAR(8)) + ') aft ON aft.function_id = application_functions.function_id
			WHERE aft.function_path IS NOT NULL
			) ) a'
			
	IF @user_login_id is not NULL
		SET @sql = @sql + ' where user_login_id='''+ @user_login_id +''''
	
	SET @sql = @sql + ' order by [user] asc, [Role Name]'
	EXEC spa_print @sql
	EXEC(@sql)
	
	SET @sql='SELECT * ' + @str_batch_table +  ' FROM #temp_store_F'
	EXEC(@sql)
END

ELSE IF @flag = 'g'
BEGIN
    SET @sql = 
        ' SELECT application_functions.function_id AS [Function ID]
		,aft.function_path [Function Name]
		,application_functions.function_desc AS [Function Description]
		' + @str_batch_table + '
		FROM application_functions
		LEFT JOIN dbo.FNAApplicationFunctionsHierarchy(' + CAST(@product_id AS NVARCHAR(8)) + ') aft ON aft.function_id = application_functions.function_id'
         
    SET @sql = @sql +  ' WHERE aft.function_path IS NOT NULL ORDER BY application_functions.function_id ASC'
         
    EXEC (@sql)
END

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_privilege_report', 'Privilege Report')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END

GO

