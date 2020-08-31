IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_all_function_id]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_all_function_id]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.spa_get_all_function_id
	@flag CHAR(1)					,   -- 'm' : Loading of the combo, 's' : on page load 
	@function_id INT 			= NULL,
	@role_id INT				= NULL, -- This is the filter in the Screen.
	@role_user_id VARCHAR(50)	= NULL, -- This will come depending on what user/role has been selected.
	@role_user_flag CHAR(1)		= NULL,  -- This will come depending on User/Role selected for privilege.
	@show_menu_flag CHAR(1)			= NULL,   -- This will display only the menus in the product
	@product_id		INT = 10000000
AS
BEGIN
	
	SET NOCOUNT ON

	DECLARE @function_id_tmp VARCHAR(4),@sqlStmt VARCHAR(8000), @case VARCHAR(200)
	DECLARE @rw_view_id VARCHAR(1000)
	
	SET @rw_view_id = '10201012,10201633' --ADDED 10201016 FOR NEW REPORT MANAGER VIEW 8/30/2012
	
	IF @flag IS NULL AND @function_id IS NOT NULL
		SELECT @function_id_tmp = SUBSTRING(CAST(@function_id AS VARCHAR),1,4)
	
	IF @flag = 's'
		--SELECT function_id FROM application_functions_trm WHERE Depth > 2 ORDER BY function_id 
		--List all function_ids under all modules of a product.
		--SELECT function_id FROM dbo.FNAApplicationFunctionsHierarchy(@product_id) WHERE depth > 2 ORDER BY function_id
		
		-- product,module,menu,submenu are deleted from application functions. these are maintained in setup menu but form and form specific function ids which participates in privilege are still maintain in application_functions. So only these ids are collected.
		SELECT function_id FROM application_functions

	ELSE IF @flag = 'm'
		--Collects modules of product.
		SELECT function_id,display_name from setup_menu where parent_menu_id = @product_id
	ELSE IF @flag='a'
	BEGIN
		IF @function_id IS NULL 
			SET @case='func_ref_id IS null'
		ELSE 
			SET @case='function_id=' + cast(@function_id as VARCHAR)
			
		SET @sqlStmt = 'WITH List (function_id,function_path,function_ref_id,Lvl)
					AS
					(
						SELECT a.function_id,CONVERT(VARCHAR(8000),a.function_name) ,func_ref_id,1 as Lvl 
						FROM application_functions a WHERE '+@case +'
						UNION all
						SELECT a.function_id,function_path + ''=>''+ CONVERT(VARCHAR(8000),a.function_name) ,func_ref_id,Lvl + 1
						FROM application_functions a INNER JOIN List l ON  a.func_ref_id = l.function_id 
					)
						SELECT aft.function_id, CAST(aft.function_id AS varchar)+''.)'' + function_path, Lvl ''Depth'' 
						FROM List aft WHERE Lvl > 1'
					
		IF @role_user_id IS NOT NULL AND @role_user_flag = 'u'
		BEGIN
			SELECT @sqlStmt = @sqlStmt + ' AND NOT EXISTS (SELECT afu.function_id FROM application_functional_users afu WHERE afu.function_id <> 536 AND aft.function_id =afu.function_id and login_id = '''+@role_user_id+''' and role_user_flag = ''u'' )'
			
			SELECT @sqlStmt = @sqlStmt + ' AND NOT EXISTS (SELECT function_id FROM application_role_user aru
			JOIN application_functional_users afu2
			ON afu2.role_id = aru.role_id
			WHERE afu2.function_id NOT IN (' + @rw_view_id + ') AND user_login_id = ''' + @role_user_id + ''' and afu2.role_user_flag = ''r'' AND afu2.function_id = aft.function_id )'
		END
			
		IF @role_user_id IS NOT NULL AND @role_user_flag = 'r'
			SELECT @sqlStmt = @sqlStmt + ' AND NOT EXISTS (SELECT afu.function_id FROM application_functional_users afu WHERE afu.function_id NOT IN (' + @rw_view_id + ') AND aft.function_id =afu.function_id and role_id = '''+@role_user_id+''' and role_user_flag = ''r'' )'

		SELECT @sqlStmt = @sqlStmt + ' ORDER BY function_id'	
					
		EXEC spa_print @sqlStmt
		EXECUTE(@sqlStmt)
	END
	ELSE
	BEGIN		
		SELECT @sqlStmt = 'SELECT  DISTINCT aft.function_id [Function ID],cast(aft.function_id as varchar(8))+ '' : ''+substring(aft.function_path,14,len(aft.function_path))[Privileges] 
						from dbo.FNAApplicationFunctionsHierarchy(' + CAST(@product_id AS VARCHAR(8)) + ') aft 
						LEFT OUTER JOIN application_functional_users afu on afu.function_id=aft.function_id where depth>2' 

		
		IF @function_id IS NOT NULL
			SELECT @sqlStmt = @sqlStmt +' and aft.function_id like ('''+@function_id_tmp+'%'')'
		
		IF @role_id is not null
			SELECT @sqlStmt=@sqlStmt + ' and role_id='+ CAST(@role_id as varchar) 

		
		--show all privileges
		IF @role_user_id IS NOT NULL and @role_user_flag = 'u'
			SELECT @sqlStmt = @sqlStmt +' AND NOT EXISTS (SELECT afu.function_id FROM application_functional_users afu WHERE afu.function_id NOT IN (' + @rw_view_id + ') AND aft.function_id =afu.function_id and login_id = '''+@role_user_id+''' and role_user_flag = ''u'' )'

		IF @role_user_id IS NOT NULL and @role_user_flag = 'r'
			SELECT @sqlStmt = @sqlStmt +' AND NOT EXISTS (SELECT afu.function_id FROM application_functional_users afu WHERE afu.function_id NOT IN (' + @rw_view_id + ') AND aft.function_id =afu.function_id and role_id = '''+@role_user_id+''' and role_user_flag = ''r'' )'

		IF @role_user_id IS NOT NULL and @role_user_flag = 'u'
		BEGIN
			SELECT @sqlStmt = @sqlStmt + 'AND NOT EXISTS (SELECT function_id FROM application_role_user aru
			JOIN application_functional_users afu2
			ON afu2.role_id = aru.role_id
			WHERE afu2.function_id NOT IN (' + @rw_view_id + ') AND user_login_id = '''+@role_user_id+''' and afu2.role_user_flag = ''r'' AND afu2.function_id = afu.function_id )'
		END
		IF @show_menu_flag = 't'
			SELECT @sqlStmt=@sqlStmt + 'AND aft.function_id LIKE ''%______00%'''
			
		--For 'FAS' module, dont display "Administration", "Run Disclosure Report", "Run Exception Report" parent menu nodes.
		--IF @module='FAS' OR @root=13000000 
		SELECT @sqlStmt=@sqlStmt + ' AND aft.function_id NOT IN(13101000,13121000,13121100)	'

		SELECT @sqlStmt=@sqlStmt + ' ORDER BY aft.function_id '
		
		exec spa_print @sqlStmt

		EXEC(@sqlStmt)
	END
	
END
GO


--exec spa_get_all_function_id 'm',NULL
--exec spa_get_all_function_id NULL, NULL, NULL, NULL, 'r', 't'
--select * from application_functional_users