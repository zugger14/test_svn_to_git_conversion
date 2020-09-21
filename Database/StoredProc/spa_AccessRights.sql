IF OBJECT_ID('dbo.spa_AccessRights') IS NOT NULL
DROP PROC [dbo].[spa_AccessRights]
GO

/**
	Used to perform select, insert, update and delete from application_fuctional_users table.

	Parameters 
	@flag : Flag oprations
	@functional_user_id : Primary Key of table application_functional_users
	@function_id_text : Function Ids seperated by comma
	@role_id : Role Id of report_manager_view_users
	@login_id : Login id of report_manager_view_users
	@role_user_flag : Value 'r' or 'u'. r defines role_id and u defines user login_id
	@entity_id: Primary Key of table portfolio_hierarchy
	@rw_view_id : Function Ids for insert or delte to report_writer_view_users
	@rm_view_id : Function Ids for insert or delte to report_manager_view_users
	@product_id : Product Category id
	@source_system_book_id1 : Book identifier 1
	@source_system_book_id2 : Book identifier 2
	@source_system_book_id3 : Book identifier 3
	@source_system_book_id4 : Book identifier 4
	@is_update : '1' if update mode '0' if insert mode.
	@accessright : Not in use

*/


CREATE PROC [dbo].spa_AccessRights
	@flag AS CHAR(1),
	@functional_user_id AS VARCHAR(MAX) = NULL,
	@function_id_text AS TEXT = NULL,
	@role_id AS INT = NULL,
	@login_id AS VARCHAR(30) = NULL,
	@role_user_flag AS CHAR(1) = NULL,
	@entity_id AS VARCHAR(500) = NULL,
	@accessright AS VARCHAR(30) = NULL,
	@rw_view_id AS VARCHAR(MAX) = NULL,
	@rm_view_id AS VARCHAR(MAX) = NULL,
	@product_id INT = 10000000,
	@source_system_book_id1 VARCHAR(MAX) = NULL,
	@source_system_book_id2 VARCHAR(MAX) = NULL,
	@source_system_book_id3 VARCHAR(MAX) = NULL,
	@source_system_book_id4 VARCHAR(MAX) = NULL,
	@application_function_id VARCHAR(MAX) = NULL,
	@is_update CHAR(1) = NULL
AS
/*
DECLARE @flag AS CHAR(1),
	@functional_user_id AS VARCHAR(MAX) = NULL,
	@function_id_text AS VARCHAR(MAX) = NULL,
	@role_id AS INT = NULL,
	@login_id AS VARCHAR(30) = NULL,
	@role_user_flag AS CHAR(1) = NULL,
	@entity_id AS VARCHAR(500) = NULL,
	@accessright AS VARCHAR(30) = NULL,
	@rw_view_id AS VARCHAR(MAX) = NULL,
	@rm_view_id AS VARCHAR(MAX) = NULL,
	@product_id INT = 10000000,
	@source_system_book_id1 VARCHAR(MAX) = NULL,
	@source_system_book_id2 VARCHAR(MAX) = NULL,
	@source_system_book_id3 VARCHAR(MAX) = NULL,
	@source_system_book_id4 VARCHAR(MAX) = NULL

SELECT @flag = 'n', @login_id = 'achewt', @product_id = '10000000'
--*/
SET NOCOUNT ON 

DECLARE @sql VARCHAR(MAX)
DECLARE @error_no INT
DECLARE @rw_function_id INT
DECLARE @rm_function_id INT					

SET @rw_function_id = 10201012 --function id for Report Writer View
SET @rm_function_id = 10201633 --function id for Report Manager View

DECLARE @function_id AS VARCHAR(max)
SET @function_id = CAST(@function_id_text AS VARCHAR(max)) 

DECLARE @is_admin BIT
SELECT @is_admin = CASE WHEN [dbo].[FNAAppAdminRoleCheck](dbo.FNADBUser()) = 1 THEN 1
						WHEN [dbo].[FNASecurityAdminRoleCheck](dbo.FNADBUser()) = 1 THEN 1
						ELSE 0 
					END

IF @flag IN ('m','n')
BEGIN
	/* extract multiple portfolio and functional users id for same datasource start */
	
	IF OBJECT_ID('tempdb..#tmp_t1') IS NOT NULL
		DROP TABLE #tmp_t1
	
	SELECT	ds.name [data_source_name], ds.data_source_id, rmvu.functional_users_id,
			IIF(ph.hierarchy_level = 2, ph.entity_id, NULL) [sub],
			IIF(ph.hierarchy_level = 1, ph.entity_id, NULL) [stra],
			IIF(ph.hierarchy_level = 0, ph.entity_id, NULL) [book],
			rmvu.source_system_book_id1,
			rmvu.source_system_book_id2,
			rmvu.source_system_book_id3,
			rmvu.source_system_book_id4
	INTO #tmp_t1
	FROM report_manager_view_users rmvu
	INNER JOIN data_source ds ON ds.data_source_id = rmvu.data_source_id
	LEFT JOIN portfolio_hierarchy AS ph ON ph.entity_id = rmvu.entity_id
	WHERE ISNULL(rmvu.login_id, '-1') = ISNULL(@login_id, '-1') AND ISNULL(rmvu.role_id, -1) = ISNULL(@role_id, -1)

	IF OBJECT_ID('tempdb..#tmp_rm_view_privilege_info') IS NOT NULL
		DROP TABLE #tmp_rm_view_privilege_info
	
	SELECT main_rs.data_source_name, main_rs.data_source_id, main_rs.functional_users_id, 
			CASE WHEN COALESCE(book_detail.entity_subsidary, stra_detail.entity_subsidary, sub_detail.entity_subsidary) IS NOT NULL 
				THEN COALESCE(book_detail.entity_subsidary, stra_detail.entity_subsidary, sub_detail.entity_subsidary) ELSE 'All' END [sub],	
			CASE WHEN COALESCE(book_detail.entity_strategy, stra_detail.entity_strategy, sub_detail.entity_strategy) IS NOT NULL 
				THEN COALESCE(book_detail.entity_strategy, stra_detail.entity_strategy, sub_detail.entity_strategy) ELSE 'All' END [stra],
			CASE WHEN COALESCE(book_detail.entity_book, stra_detail.entity_book, sub_detail.entity_book) IS NOT NULL 
				THEN COALESCE(book_detail.entity_book, stra_detail.entity_book, sub_detail.entity_book) ELSE 'All' END [book],
			main_rs.source_system_book_id1,
			main_rs.source_system_book_id2,
			main_rs.source_system_book_id3,
			main_rs.source_system_book_id4
	INTO #tmp_rm_view_privilege_info
	FROM #tmp_t1 main_rs
	OUTER APPLY (
		SELECT book.entity_name entity_book, stra.entity_name entity_strategy, sub.entity_name entity_subsidary   
		FROM portfolio_hierarchy book 
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
		WHERE book.entity_id = main_rs.book AND book.hierarchy_level = 0
	) book_detail
	OUTER APPLY (
		SELECT 'All' entity_book
			, stra.entity_name entity_strategy
			, sub.entity_name entity_subsidary   
		FROM portfolio_hierarchy stra 
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
		WHERE stra.entity_id = main_rs.stra AND stra.hierarchy_level = 1
	) stra_detail
	OUTER APPLY (
		SELECT 'All' entity_book
			, 'All' entity_strategy
			, sub.entity_name entity_subsidary   
		FROM  portfolio_hierarchy sub WHERE sub.entity_id = main_rs.sub AND sub.hierarchy_level = 2
	) sub_detail
	
	--SELECT * FROM #tmp_rm_view_privilege_info
	/* extract multiple portfolio and functional users id for same datasource end */
END

IF @flag = 's' AND @functional_user_id IS NULL
BEGIN
	SELECT  * FROM application_functional_users 
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR
			, 'Application Functional User'
			, 'spa_AddAccessRight'
			, 'DB Error'
			, 'Failed to Select the Application User Rights.'
			, ''
	ELSE
		EXEC spa_ErrorHandler 0
			, 'User Securiry Mgmt'
			, 'spa_GetAccessRight'
			, 'Success'
			, 'Application User Rights successfully Selected.'
			, ''
END
ELSE IF @flag='s' AND @functional_user_id IS NOT NULL
BEGIN
	SELECT  * FROM application_functional_users WHERE functional_users_id=@functional_user_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR
			, 'Application Functional User'
			, 'spa_AddAccessRight'
			, 'DB Error'
			, 'Failed to Select the Application User Rights for particular user.'
			, ''
	ELSE
		EXEC spa_ErrorHandler 0
			, 'User Securiry Mgmt'
			, 'spa_GetAccessRight'
			, 'Success'
			, 'Application User Rights successfully Selected for particular user.'
			, ''
END
IF @flag = 'i'
BEGIN
	BEGIN TRY
		IF @is_admin <> 1 AND EXISTS (
			SELECT 1 FROM dbo.SplitCommaSeperatedValues(@function_id) a
			WHERE a.item IN (
				SELECT function_id FROM application_functions WHERE is_sensitive = 1
				UNION
				SELECT function_id FROM application_functions WHERE func_ref_id IN (SELECT function_id FROM application_functions WHERE is_sensitive = 1)
			)
		)  
		BEGIN
			EXEC spa_ErrorHandler 1, 'Role User', 
				'spa_role_user', 'DB Error', 
				'You do not have privilege to give this privilege to other user.', ''

			RETURN
		END
		ELSE
		BEGIN		
		BEGIN TRAN
		-- In case of update deleting all existing record and inserting newly selected
		IF @is_update = 1
		BEGIN
			DELETE afu 
			FROM application_functional_users afu
			INNER JOIN dbo.SplitCommaSeperatedValues(@function_id) a
				ON CAST(a.item AS VARCHAR(10)) = afu.function_id
			WHERE afu.login_id = @Login_id
			AND afu.role_user_flag = @role_user_flag
		END
		--insert only if same record not existing (i.e same funtion id assigned for same user/role under same entity)
		--in case of Report Writer View Function ID (@rw_function_id), no check for entity id is required
		--as entity will be saved in report_writer_view_users for each view.
		
		INSERT INTO application_functional_users (function_id, role_id, login_id, role_user_flag, entity_id, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4)
		SELECT DISTINCT  a.item, @role_id, @Login_id, @role_user_flag, CASE WHEN af.book_required = 1 THEN IIF(a.item = @rm_function_id, NULL, b.item) ELSE NULL END book_required,
			IIF(a.item = @rm_function_id, NULL, @source_system_book_id1),
			IIF(a.item = @rm_function_id, NULL, @source_system_book_id2),
			IIF(a.item = @rm_function_id, NULL, @source_system_book_id3),
			IIF(a.item = @rm_function_id, NULL, @source_system_book_id4)
		FROM	dbo.SplitCommaSeperatedValues(@function_id) a
		LEFT JOIN dbo.SplitCommaSeperatedValues(@entity_id) b ON 1 = 1
		LEFT JOIN application_functions af ON af.function_id = a.item AND af.book_required = 1
		WHERE NOT EXISTS(SELECT 1 FROM application_functional_users afu 
							WHERE ISNULL(role_id, -1) = (CASE WHEN @role_user_flag = 'r' THEN @role_id ELSE ISNULL(role_id, -1) END)
								AND ISNULL(login_id, '-1') = (CASE WHEN @role_user_flag = 'u' THEN @login_id ELSE ISNULL(login_id, '-1') END)
								AND afu.function_id = a.item
								--AND ISNULL(afu.entity_id, -1) = (CASE WHEN a.item = @rw_function_id THEN ISNULL(afu.entity_id, -1) ELSE CASE WHEN af.book_required = 1 THEN b.item ELSE -1 END END)
								AND ISNULL(afu.entity_id, -1) = (CASE WHEN a.item = @rm_function_id THEN ISNULL(afu.entity_id, -1) ELSE CASE WHEN af.book_required = 1 THEN ISNULL(b.item, -1) ELSE -1 END END)
								AND ISNULL(afu.source_system_book_id1, '-1')  = (CASE WHEN a.item = @rm_function_id THEN ISNULL(afu.source_system_book_id1, -1) ELSE ISNULL(@source_system_book_id1, '-1') END)
								AND ISNULL(afu.source_system_book_id2, '-1')  = (CASE WHEN a.item = @rm_function_id THEN ISNULL(afu.source_system_book_id2, -1) ELSE ISNULL(@source_system_book_id2, '-1') END)
								AND ISNULL(afu.source_system_book_id3, '-1')  = (CASE WHEN a.item = @rm_function_id THEN ISNULL(afu.source_system_book_id3, -1) ELSE ISNULL(@source_system_book_id3, '-1') END)
								AND ISNULL(afu.source_system_book_id4, '-1')  = (CASE WHEN a.item = @rm_function_id THEN ISNULL(afu.source_system_book_id4, -1) ELSE ISNULL(@source_system_book_id4, '-1') END)
		) AND (a.item <> @rm_function_id OR (a.item = @rm_function_id AND @rm_view_id IS NOT NULL))
		AND a.item IN (
			SELECT function_id
			FROM application_functions
		)
		
		--insert only if same record not existing (i.e same funtion id assigned for same user/role under same entity)
		IF (@rw_view_id) IS NOT NULL
		BEGIN
			INSERT INTO report_writer_view_users (function_id, role_id, login_id, entity_id, create_user, create_ts) 
				SELECT a.item, @role_id, @login_id, b.item, dbo.FNADBUser(), GETDATE()
				FROM dbo.SplitCommaSeperatedValues(@rw_view_id) a
					LEFT JOIN dbo.SplitCommaSeperatedValues(@entity_id) b ON 1 = 1
				WHERE NOT EXISTS (SELECT 1 FROM report_writer_view_users rwvu
									WHERE ISNULL(role_id, -1) = (CASE WHEN @role_user_flag = 'r' THEN @role_id ELSE ISNULL(role_id, -1) END)
										AND ISNULL(login_id, '-1') = (CASE WHEN @role_user_flag = 'u' THEN @login_id ELSE ISNULL(login_id, '-1') END)
										AND rwvu.function_id = a.item
										AND ISNULL(rwvu.entity_id, -1) = ISNULL(b.item, -1))
										
		END								
		--insert into report manager view user only if same record not existing (i.e same funtion id assigned for same user/role under same entity)
		IF (NULLIF(@rm_view_id, '')) IS NOT NULL
		BEGIN
			INSERT INTO report_manager_view_users (data_source_id, role_id, login_id, entity_id, create_user, create_ts, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4) 
				SELECT a.item, @role_id, @login_id, b.item, dbo.FNADBUser(), GETDATE(), @source_system_book_id1, @source_system_book_id2, @source_system_book_id3, @source_system_book_id4
				FROM dbo.SplitCommaSeperatedValues(@rm_view_id) a
					LEFT JOIN dbo.SplitCommaSeperatedValues(@entity_id) b ON 1 = 1
				WHERE NOT EXISTS (SELECT 1 FROM report_manager_view_users rmvu
									WHERE ISNULL(role_id, -1) = (CASE WHEN @role_user_flag = 'r' THEN @role_id ELSE ISNULL(role_id, -1) END)
										AND ISNULL(login_id, '-1') = (CASE WHEN @role_user_flag = 'u' THEN @login_id ELSE ISNULL(login_id, '-1') END)
										AND rmvu.data_source_id = a.item
										AND ISNULL(rmvu.entity_id, -1) = ISNULL(b.item, -1)
										AND ISNULL(rmvu.source_system_book_id1, -1) = ISNULL(@source_system_book_id1, -1)
										AND ISNULL(rmvu.source_system_book_id2, -1) = ISNULL(@source_system_book_id2, -1)
										AND ISNULL(rmvu.source_system_book_id3, -1) = ISNULL(@source_system_book_id3, -1)
										AND ISNULL(rmvu.source_system_book_id4, -1) = ISNULL(@source_system_book_id4, -1)
										)		
		END
		
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='Privilege', @source_object = 'spa_AccessRights @flag=i'
		END	

		EXEC spa_ErrorHandler 0
			, 'User Securiry Mgmt'
			, 'spa_GetAccessRight'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''
	
		COMMIT TRAN
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		
		--EXEC spa_print ERROR_MESSAGE()
		SET @error_no = ERROR_NUMBER()
		EXEC spa_ErrorHandler @error_no, 'Application Functional User', 
				'spa_AddAccessRight', 'DB Error', 
				'Failed to Insert the Application User Rights.', ''
	END CATCH	
END
IF @flag = 'u'
BEGIN
	UPDATE	application_functional_users 
	SET		function_id = @function_id,
			role_id = @role_id,
			login_id = @Login_id,
			role_user_flag = @role_user_flag,
			entity_id = @entity_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR
			, 'Application Functional User'
			, 'spa_AddAccessRight'
			, 'DB Error'
			, 'Failed to Update the Application User Rights.'
			, ''
	ELSE
	BEGIN
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='Privilege', @source_object = 'spa_AccessRights @flag=u'
		END	

		EXEC spa_ErrorHandler 0
			, 'User Securiry Mgmt'
			, 'spa_GetAccessRight'
			, 'Success'
			, 'Application User Rights successfully Updated.'
			, ''
	END
END
ELSE IF @flag = 'd'
BEGIN

	BEGIN TRY
		BEGIN TRAN

		--For delete privilege from role
		IF @functional_user_id IS NOT NULL AND @login_id IS NULL
		BEGIN
			--Delete workflow mapping using deleted role for all users
			DECLARE  @cursor_query VARCHAR(MAX)
	
			SET @cursor_query = '
			DECLARE @login_id VARCHAR(50)

			DECLARE delete_workflow CURSOR FOR  

			SELECT DISTINCT aru.user_login_id  
				FROM  application_functional_users afu
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @functional_user_id + ''') t
						ON t.item = afu.functional_users_id
					INNER JOIN application_role_user aru
						ON aru.role_id = afu.role_id

			OPEN delete_workflow   
			FETCH NEXT FROM delete_workflow INTO @login_id   

			WHILE @@FETCH_STATUS = 0   
			BEGIN   	
					DELETE sw
					FROM  setup_workflow sw
						INNER JOIN application_role_user aru
							ON sw.user_id = aru.user_login_id
						INNER JOIN dbo.SplitCommaSeperatedValues(170) r 
							ON aru.role_id = r.Item
						INNER JOIN application_functional_users afu
							ON afu.role_id = r.item
							AND afu.function_id = sw.function_id
						INNER JOIN dbo.SplitCommaSeperatedValues('''+ @functional_user_id + ''' ) t
									ON t.item = afu.functional_users_id
						LEFT JOIN (
								SELECT function_id 
								FROM application_functional_users 
								WHERE login_id = @login_id
								UNION 
								SELECT afu.function_id 
								FROM application_role_user aru 
									INNER JOIN application_functional_users afu
										ON aru.role_id = afu.role_id
								WHERE aru.user_login_id =  @login_id
									AND afu.functional_users_id NOT IN (' + @functional_user_id + ')
		
							) a
							ON a.function_id = afu.function_id
					WHERE  sw.user_id = @login_id
						AND a.function_id IS NULL


				   FETCH NEXT FROM delete_workflow INTO @login_id   
			END   

			CLOSE delete_workflow   
			DEALLOCATE delete_workflow

			'

			EXEC(@cursor_query)

			
			--Delete workflow mapping for role
			DELETE sw
			FROM application_functional_users afu
				INNER JOIN setup_workflow sw
					ON sw.role_id = afu.role_id 
					AND sw.function_id = afu.function_id  
				INNER JOIN dbo.SplitCommaSeperatedValues(@functional_user_id) t
					ON t.item = afu.functional_users_id

			--Delete workflow mapping for role
			--DELETE afu
			--FROM application_functional_users afu				 
			--INNER JOIN dbo.SplitCommaSeperatedValues(@functional_user_id) t
			--	ON t.item = afu.functional_users_id
		END	  
		
		--For delete privilege from user
		IF @login_id IS NOT NULL AND @functional_user_id IS NOT NULL
		BEGIN
			DELETE sw
			FROM setup_workflow sw
				INNER JOIN 	application_functional_users afu				
					ON sw.function_id = afu.function_id
				INNER JOIN dbo.SplitCommaSeperatedValues(@functional_user_id) t
					ON t.item = afu.functional_users_id
			WHERE sw.user_id = @login_id
		END		

		SET @sql = 'DELETE FROM application_functional_users
					WHERE functional_users_id IN (' + @functional_user_id + ')
						and (function_id <> 10201633
							or not exists(
								select top 1 1 from report_manager_view_users r
								where 1=1 ' + case when @login_id is not null then ' and r.login_id = ''' + @login_id + '''' else '' end + '
							)
						)
					'
		
		IF @login_id IS NOT NULL 
			SET @sql = @sql + ' AND login_id = ''' + @login_id + ''''
		
		--PRINT(@sql)
		EXEC (@sql)

		SET @sql = 'DELETE FROM report_writer_view_users
					WHERE functional_users_id IN (' + @rw_view_id + ')'
		
		IF @login_id IS NOT NULL 
			SET @sql = @sql + ' AND login_id = ''' + @login_id + ''''
			
		--PRINT(@sql)
		EXEC (@sql)
		
		if nullif(@rm_view_id, '') is not null
			SET @sql = 'DELETE FROM report_manager_view_users
						WHERE functional_users_id IN (' + @rm_view_id + ')'
		
		IF @login_id IS NOT NULL and nullif(@rm_view_id, '') is not null
			SET @sql = @sql + ' AND login_id = ''' + @login_id + ''''
			
		--PRINT(@sql)
		EXEC (@sql)


		--delete from application functions when no more report writer views present
		DELETE FROM	application_functional_users
		WHERE function_id = @rw_function_id
		AND ISNULL(role_id, -1) = (CASE WHEN @role_user_flag = 'r' THEN @role_id ELSE ISNULL(role_id, -1) END)
		AND ISNULL(login_id, '-1') = (CASE WHEN @role_user_flag = 'u' THEN @login_id ELSE ISNULL(login_id, '-1') END)
		AND NOT EXISTS (SELECT 1 FROM report_writer_view_users
		                WHERE ISNULL(role_id, -1) = (CASE WHEN @role_user_flag = 'r' THEN @role_id ELSE ISNULL(role_id, -1) END)
							AND ISNULL(login_id, '-1') = (CASE WHEN @role_user_flag = 'u' THEN @login_id ELSE ISNULL(login_id, '-1') END))
							
		--delete from application functions when no more report manager views present
		DELETE FROM	application_functional_users
		WHERE function_id = @rm_function_id
		AND ISNULL(role_id, -1) = (CASE WHEN @role_user_flag = 'r' THEN @role_id ELSE ISNULL(role_id, -1) END)
		AND ISNULL(login_id, '-1') = (CASE WHEN @role_user_flag = 'u' THEN @login_id ELSE ISNULL(login_id, '-1') END)
		AND NOT EXISTS (SELECT 1 FROM report_manager_view_users
		                WHERE ISNULL(role_id, -1) = (CASE WHEN @role_user_flag = 'r' THEN @role_id ELSE ISNULL(role_id, -1) END)
							AND ISNULL(login_id, '-1') = (CASE WHEN @role_user_flag = 'u' THEN @login_id ELSE ISNULL(login_id, '-1') END))						
		
		
		

		COMMIT TRAN
		
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='Privilege', @source_object = 'spa_AccessRights @flag=d'
		END
		
		EXEC spa_ErrorHandler 0
			, 'User Securiry Mgmt'
			, 'spa_GetAccessRight'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		--EXEC spa_print ERROR_MESSAGE()
		
		SET @error_no = ERROR_NUMBER()
		EXEC spa_ErrorHandler @error_no
			, 'Application Functional User'
			, 'spa_AddAccessRight'
			, 'DB Error'
			, 'Failed to delete or remove application user rights.'
			, ''
	END CATCH
			
END
ELSE IF @flag = 'm'
BEGIN
	IF OBJECT_ID('tempdb..#role_privilege') IS NOT NULL
		DROP TABLE #role_privilege
	IF OBJECT_ID('tempdb..#Temp_entity') IS NOT NULL
		DROP TABLE #Temp_entity
	IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
		DROP TABLE #tmp

	CREATE TABLE #role_privilege
	(
		function_id1  INT ,
		function_name1 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id2	INT	,
		function_name2  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id3		INT,
		function_name3  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id4		INT,
		function_name4  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id5		INT,
		function_name5  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id6		INT,
		function_name6  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id7		INT,
		function_name7  VARCHAR(200) COLLATE DATABASE_DEFAULT
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

	CREATE TABLE #Temp_entity
	 (functional_user_id_temp INT,
	 function_id_temp INT,
	 entity_id_temp INT,
	 hierarchy_level_temp INT,
	 source_system_book_id1 VARCHAR(MAX),
	 source_system_book_id2 VARCHAR(MAX),
	 source_system_book_id3 VARCHAR(MAX),
	 source_system_book_id4 VARCHAR(MAX)
	 )
	INSERT INTO #Temp_entity 
	 SELECT afu.functional_users_id, 
			afu.function_id, 
			afu.entity_id, 
			ph.hierarchy_level,
			afu.source_system_book_id1,
			afu.source_system_book_id2,
			afu.source_system_book_id3,
			afu.source_system_book_id4
	 FROM application_functional_users afu
		 LEFT JOIN portfolio_hierarchy ph 
			ON ph.entity_id = afu.entity_id
	 WHERE role_user_flag = 'r'
		AND role_id = @role_id

	 SELECT DISTINCT (SELECT function_name FROM application_functions WHERE function_id = ISNULL(sm.parent_menu_id, af.func_ref_id)) [parent_name]
		, ISNULL(sm.display_name,af.function_name) [function_name]			
		, apu.functional_user_id_temp
		, ISNULL(sm.parent_menu_id, af.func_ref_id) [parent_id]
		, apu.function_id_temp [function_id]
		, ph_sub.entity_id subsidiary_id
		, ph_strat.entity_id strategy_id
		, ph_book.entity_id book
		, ISNULL(af.book_required,0) book_required
		, apu.source_system_book_id1
		, apu.source_system_book_id2
		, apu.source_system_book_id3
		, apu.source_system_book_id4
		, COALESCE(apu.source_system_book_id1, apu.source_system_book_id2, apu.source_system_book_id3, apu.source_system_book_id4) [source_system_book_id]
	INTO #tmp
	FROM #Temp_entity apu
		LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = apu.entity_id_temp
		LEFT JOIN portfolio_hierarchy ph_sub ON ph_sub.entity_id = ph.entity_id AND ph_sub.hierarchy_level = 2
		LEFT JOIN portfolio_hierarchy ph_strat ON ph_strat.entity_id = ph.entity_id AND ph_strat.hierarchy_level = 1
		LEFT JOIN portfolio_hierarchy ph_book ON ph_book.entity_id = ph.entity_id AND ph_book.hierarchy_level = 0
		LEFT JOIN setup_menu sm ON sm.function_id = apu.function_id_temp
		LEFT JOIN application_functions af ON af.function_id = apu.function_id_temp
	WHERE 1 = 1
		--af.function_id <= 12000000 and 
		AND (sm.parent_menu_id != @product_id OR af.func_ref_id != @product_id  ) --10000000
		AND ISNULL(sm.function_id, af.function_id) IS NOT NULL

	SELECT DISTINCT --priv.function_name1,
		priv.function_name2
		,priv.function_name3
		,function_name4
		,CASE WHEN main_rs.function_id = @rm_function_id 
			THEN priv.function_name5 + ISNULL(' - ' + rm_views.data_source_name + ' [' + CAST(rm_views.functional_users_id AS VARCHAR(10)) + ']', '') 
			ELSE priv.function_name5 
		 END [function_name5]
		,priv.function_name6
		,priv.function_name7
		--, main_rs.function_name
		, main_rs.functional_user_id_temp functional_user_id
		--s, main_rs.parent_id
		, main_rs.function_id
		, CASE WHEN ISNULL(main_rs.source_system_book_id, rm_views.source_system_book_id) IS NOT NULL THEN ''
			WHEN main_rs.function_id = @rm_function_id THEN 
			CASE WHEN COALESCE(rm_views.sub, rm_views.stra, rm_views.book) IS NOT NULL THEN rm_views.sub ELSE 'All' END
		ELSE 
			CASE WHEN main_rs.subsidiary_id IS NULL THEN 
				CASE WHEN main_rs.strategy_id IS NULL THEN 
					CASE WHEN main_rs.book IS NULL THEN  CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END  
						ELSE book_detail.entity_subsidary
					END 
				ELSE stra_detail.entity_subsidary 
			END
			ELSE sub_detail.entity_subsidary
			END 
		END [entity_subsidary]
		, CASE WHEN ISNULL(main_rs.source_system_book_id, rm_views.source_system_book_id) IS NOT NULL THEN ''
			WHEN main_rs.function_id = @rm_function_id THEN 
			CASE WHEN COALESCE(rm_views.stra, rm_views.book) IS NOT NULL THEN rm_views.stra ELSE 'All' END
		ELSE 
			CASE WHEN main_rs.strategy_id IS NULL THEN 
				CASE WHEN main_rs.book IS NULL THEN  CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END  
					ELSE book_detail.entity_strategy 
				END
				ELSE stra_detail.entity_strategy
			 END 
		 END [entity_strategy] 
		, CASE WHEN ISNULL(main_rs.source_system_book_id, rm_views.source_system_book_id) IS NOT NULL THEN ''
			WHEN main_rs.function_id = @rm_function_id THEN 
			CASE WHEN rm_views.book IS NOT NULL THEN rm_views.book ELSE 'All' END
		ELSE 
			CASE WHEN main_rs.book IS  NULL THEN  CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END 
				ELSE book_detail.entity_book 
			 END 
		 END [entity_book],
		 source_book1.source_book_name [group1],
		 source_book2.source_book_name [group2],
		 source_book3.source_book_name [group3],
		 source_book4.source_book_name [group4]
	FROM #tmp main_rs
	INNER JOIN #role_privilege priv ON main_rs.function_id = COALESCE(priv.function_id7,priv.function_id6,priv.function_id5,priv.function_id4,priv.function_id3,priv.function_id2,priv.function_id1)
	OUTER APPLY (
		SELECT book.entity_name entity_book, stra.entity_name entity_strategy, sub.entity_name entity_subsidary   
		FROM portfolio_hierarchy book 
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
		WHERE book.entity_id = main_rs.book AND book.hierarchy_level = 0
	) book_detail
	OUTER APPLY (
		SELECT CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END entity_book
			, stra.entity_name entity_strategy
			, sub.entity_name entity_subsidary   
		FROM portfolio_hierarchy stra 
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
		WHERE stra.entity_id = main_rs.strategy_id AND stra.hierarchy_level = 1
	) stra_detail
	OUTER APPLY (
		SELECT CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END entity_book
			, CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END entity_strategy
			, sub.entity_name entity_subsidary   
		FROM  portfolio_hierarchy sub WHERE sub.entity_id = main_rs.subsidiary_id AND sub.hierarchy_level = 2
	) sub_detail
	OUTER APPLY (
		SELECT	tvpi.data_source_name [data_source_name], tvpi.data_source_id, tvpi.functional_users_id
				, tvpi.sub, tvpi.stra, tvpi.book
				, tvpi.source_system_book_id1, tvpi.source_system_book_id2, tvpi.source_system_book_id3, tvpi.source_system_book_id4
				, COALESCE(tvpi.source_system_book_id1, tvpi.source_system_book_id2, tvpi.source_system_book_id3, tvpi.source_system_book_id4) [source_system_book_id]
		FROM #tmp_rm_view_privilege_info tvpi
		WHERE  main_rs.function_id = @rm_function_id
	) rm_views
	OUTER APPLY (
		SELECT STUFF(
			(
				SELECT ',' + source_book_name
				FROM source_book sb
				INNER JOIN dbo.SplitCommaSeperatedValues(ISNULL(main_rs.source_system_book_id1, rm_views.source_system_book_id1)) s ON s.item = sb.source_book_id
				WHERE sb.source_system_book_type_value_id = 50
				FOR XML PATH('')
			), 1, 1, '') source_book_name
	) source_book1
	OUTER APPLY (
		SELECT STUFF(
			(
				SELECT ',' + source_book_name
				FROM source_book sb
				INNER JOIN dbo.SplitCommaSeperatedValues(ISNULL(main_rs.source_system_book_id2, rm_views.source_system_book_id2)) s ON s.item = sb.source_book_id
				WHERE sb.source_system_book_type_value_id = 51
				FOR XML PATH('')
			), 1, 1, '') source_book_name
	) source_book2
	OUTER APPLY (
		SELECT STUFF(
			(
				SELECT ',' + source_book_name
				FROM source_book sb
				INNER JOIN dbo.SplitCommaSeperatedValues(ISNULL(main_rs.source_system_book_id3, rm_views.source_system_book_id3)) s ON s.item = sb.source_book_id
				WHERE sb.source_system_book_type_value_id = 52
				FOR XML PATH('')
			), 1, 1, '') source_book_name
	) source_book3
	OUTER APPLY (
		SELECT STUFF(
			(
				SELECT ',' + source_book_name
				FROM source_book sb
				INNER JOIN dbo.SplitCommaSeperatedValues(ISNULL(main_rs.source_system_book_id4, rm_views.source_system_book_id4)) s ON s.item = sb.source_book_id
				WHERE sb.source_system_book_type_value_id = 53
				FOR XML PATH('')
			), 1, 1, '') source_book_name
	) source_book4
	
	DROP TABLE #tmp
	DROP TABLE #role_privilege
	DROP TABLE #Temp_entity
END
ELSE IF @flag = 'n'
BEGIN
	IF OBJECT_ID('tempdb..#user_privilege') IS NOT NULL
		DROP TABLE #user_privilege

	CREATE TABLE #user_privilege
	(
		function_id1  INT ,
		function_name1 VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id2	INT	,
		function_name2  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id3		INT,
		function_name3  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id4		INT,
		function_name4  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id5		INT,
		function_name5  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id6		INT,
		function_name6  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		function_id7		INT,
		function_name7  VARCHAR(200) COLLATE DATABASE_DEFAULT
	)
	INSERT INTO #user_privilege(
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
	
	IF OBJECT_ID('tempdb..#user_temp_entity') IS NOT NULL
		DROP TABLE #user_temp_entity
	
	CREATE TABLE #user_temp_entity
	 (functional_user_id_temp INT,
	 function_id_temp INT,
	 entity_id_temp INT,
	 hierarchy_level_temp INT,
	 role_id	INT,
	 source_system_book_id1 VARCHAR(MAX),
	 source_system_book_id2 VARCHAR(MAX),
	 source_system_book_id3 VARCHAR(MAX),
	 source_system_book_id4 VARCHAR(MAX)
	 )
	INSERT INTO #user_temp_entity 
	SELECT DISTINCT afu.functional_users_id, afu.function_id, afu.entity_id, ph.hierarchy_level, afu.role_id,
			afu.source_system_book_id1,
			afu.source_system_book_id2,
			afu.source_system_book_id3,
			afu.source_system_book_id4
	FROM application_users au 
	LEFT JOIN application_role_user aru ON aru.user_login_id = au.user_login_id
	LEFT JOIN application_functional_users afu ON afu.login_id = au.user_login_id OR (afu.role_id = aru.role_id)
	LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = afu.entity_id
	 WHERE au.user_login_id = @login_id
	
	IF OBJECT_ID('tempdb..#user_tmp') IS NOT NULL
		DROP TABLE #user_tmp

	 SELECT DISTINCT (SELECT function_name FROM application_functions WHERE function_id = ISNULL(sm.parent_menu_id,af.func_ref_id)) [parent_name]
		, ISNULL(sm.display_name,af.function_name) [function_name]			
		, apu.functional_user_id_temp
		, apu.function_id_temp [function_id]
		, ph_sub.entity_id subsidiary_id
		, ph_strat.entity_id strategy_id
		, ph_book.entity_id book
		, ISNULL(af.book_required,0) book_required
		, apu.role_id
		, apu.source_system_book_id1
		, apu.source_system_book_id2
		, apu.source_system_book_id3
		, apu.source_system_book_id4
		, COALESCE(apu.source_system_book_id1, apu.source_system_book_id2, apu.source_system_book_id3, apu.source_system_book_id4) [source_system_book_id]
	INTO #user_tmp
	FROM #user_temp_entity apu
	LEFT JOIN setup_menu sm ON sm.function_id = apu.function_id_temp
	LEFT JOIN application_functions af ON af.function_id = apu.function_id_temp
	LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = apu.entity_id_temp
	LEFT JOIN portfolio_hierarchy ph_sub ON ph_sub.entity_id = ph.entity_id AND ph_sub.hierarchy_level = 2
	LEFT JOIN portfolio_hierarchy ph_strat ON ph_strat.entity_id = ph.entity_id AND ph_strat.hierarchy_level = 1
	LEFT JOIN portfolio_hierarchy ph_book ON ph_book.entity_id = ph.entity_id AND ph_book.hierarchy_level = 0	
	WHERE 1 = 1 
	--af.function_id <= 12000000 and	--function id fo generic mapping is above 12000000
	AND (sm.parent_menu_id != @product_id OR af.func_ref_id != @product_id  ) --10000000
	AND ISNULL(sm.function_id, af.function_id) IS NOT NULL

	IF OBJECT_ID('tempdb..#final_table') IS NOT NULL
		DROP TABLE #final_table

	SELECT DISTINCT --priv.function_name1,
		priv.function_name2
		,priv.function_name3
		,priv.function_name4
		,CASE WHEN main_rs.function_id = @rm_function_id 
			THEN priv.function_name5 + ISNULL(' - ' + rm_views.data_source_name + ' [' + CAST(rm_views.functional_users_id AS VARCHAR(10)) + ']', '') 
			ELSE priv.function_name5 
		 END [function_name5]
		,priv.function_name6
		,priv.function_name7
		, main_rs.functional_user_id_temp functional_user_id
		, main_rs.function_id
		, asr.role_name
		, CASE WHEN ISNULL(main_rs.source_system_book_id, rm_views.source_system_book_id) IS NOT NULL THEN ''
			WHEN main_rs.function_id = @rm_function_id THEN 
			CASE WHEN COALESCE(rm_views.sub, rm_views.stra, rm_views.book) IS NOT NULL THEN rm_views.sub ELSE 'All' END
		WHEN main_rs.source_system_book_id IS NOT NULL THEN '' 
		ELSE 
			CASE WHEN main_rs.subsidiary_id IS NULL THEN 
				CASE WHEN main_rs.strategy_id IS NULL THEN 
					CASE WHEN main_rs.book IS NULL THEN  CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END  
						ELSE book_detail.entity_subsidary
					END 
				ELSE stra_detail.entity_subsidary 
			END
			ELSE sub_detail.entity_subsidary
			END 
		END [entity_subsidary]
		, CASE WHEN ISNULL(main_rs.source_system_book_id, rm_views.source_system_book_id) IS NOT NULL THEN ''
			WHEN main_rs.function_id = @rm_function_id THEN 
			CASE WHEN COALESCE(rm_views.stra, rm_views.book) IS NOT NULL THEN rm_views.stra ELSE 'All' END
		WHEN main_rs.source_system_book_id IS NOT NULL THEN '' 
		ELSE 
			CASE WHEN main_rs.strategy_id IS NULL THEN 
				CASE WHEN main_rs.book IS NULL THEN  CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END  
					ELSE book_detail.entity_strategy 
				END
				ELSE stra_detail.entity_strategy
			 END 
		 END [entity_strategy] 
		, CASE WHEN ISNULL(main_rs.source_system_book_id, rm_views.source_system_book_id) IS NOT NULL THEN ''
			WHEN main_rs.function_id = @rm_function_id THEN
			CASE WHEN rm_views.book IS NOT NULL THEN rm_views.book ELSE 'All' END
		WHEN main_rs.source_system_book_id IS NOT NULL THEN '' 
		ELSE 
			CASE WHEN main_rs.book IS  NULL THEN  CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END 
				ELSE book_detail.entity_book 
			 END 
		 END [entity_book],
		 source_book1.source_book_name [group1],
		 source_book2.source_book_name [group2],
		 source_book3.source_book_name [group3],
		 source_book4.source_book_name [group4]
	INTO #final_table
	FROM #user_tmp main_rs
	INNER JOIN #user_privilege priv ON main_rs.function_id = COALESCE(priv.function_id7,priv.function_id6,priv.function_id5,priv.function_id4,priv.function_id3,priv.function_id2,priv.function_id1)
	LEFT JOIN application_security_role asr ON asr.role_id = main_rs.role_id
	OUTER APPLY (
		SELECT book.entity_name entity_book, stra.entity_name entity_strategy, sub.entity_name entity_subsidary   
		FROM portfolio_hierarchy book 
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
		WHERE book.entity_id = main_rs.book AND book.hierarchy_level = 0
	) book_detail
	OUTER APPLY (
		SELECT CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END entity_book
			, stra.entity_name entity_strategy
			, sub.entity_name entity_subsidary   
		FROM portfolio_hierarchy stra 
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
		WHERE stra.entity_id = main_rs.strategy_id AND stra.hierarchy_level = 1
	) stra_detail
	OUTER APPLY (
		SELECT CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END entity_book
			, CASE WHEN main_rs.book_required = 1 THEN 'All' ELSE NULL END entity_strategy
			, sub.entity_name entity_subsidary   
		FROM  portfolio_hierarchy sub WHERE sub.entity_id = main_rs.subsidiary_id AND sub.hierarchy_level = 2
	) sub_detail
	OUTER APPLY (
		SELECT	tvpi.data_source_name [data_source_name], tvpi.data_source_id, tvpi.functional_users_id
				, tvpi.sub, tvpi.stra, tvpi.book
				, tvpi.source_system_book_id1, tvpi.source_system_book_id2, tvpi.source_system_book_id3, tvpi.source_system_book_id4
				, COALESCE(tvpi.source_system_book_id1, tvpi.source_system_book_id2, tvpi.source_system_book_id3, tvpi.source_system_book_id4) [source_system_book_id]
		FROM #tmp_rm_view_privilege_info tvpi
		WHERE  main_rs.function_id = @rm_function_id
	) rm_views
	OUTER APPLY (
		SELECT STUFF(
			(
				SELECT ',' + source_book_name
				FROM source_book sb
				INNER JOIN dbo.SplitCommaSeperatedValues(ISNULL(main_rs.source_system_book_id1, rm_views.source_system_book_id1)) s ON s.item = sb.source_book_id
				WHERE sb.source_system_book_type_value_id = 50
				FOR XML PATH('')
			), 1, 1, '') source_book_name
	) source_book1
	OUTER APPLY (
		SELECT STUFF(
			(
				SELECT ',' + source_book_name
				FROM source_book sb
				INNER JOIN dbo.SplitCommaSeperatedValues(ISNULL(main_rs.source_system_book_id2, rm_views.source_system_book_id2)) s ON s.item = sb.source_book_id
				WHERE sb.source_system_book_type_value_id = 51
				FOR XML PATH('')
			), 1, 1, '') source_book_name
	) source_book2
	OUTER APPLY (
		SELECT STUFF(
			(
				SELECT ',' + source_book_name
				FROM source_book sb
				INNER JOIN dbo.SplitCommaSeperatedValues(ISNULL(main_rs.source_system_book_id3, rm_views.source_system_book_id3)) s ON s.item = sb.source_book_id
				WHERE sb.source_system_book_type_value_id = 52
				FOR XML PATH('')
			), 1, 1, '') source_book_name
	) source_book3
	OUTER APPLY (
		SELECT STUFF(
			(
				SELECT ',' + source_book_name
				FROM source_book sb
				INNER JOIN dbo.SplitCommaSeperatedValues(ISNULL(main_rs.source_system_book_id4, rm_views.source_system_book_id4)) s ON s.item = sb.source_book_id
				WHERE sb.source_system_book_type_value_id = 53
				FOR XML PATH('')
			), 1, 1, '') source_book_name
	) source_book4

	/* Hide SaaS Administrative forms for all users except for Application Admin*/
	IF @is_admin <> 1
	BEGIN
		DELETE ft
		FROM #final_table ft
		INNER JOIN application_functions af
			ON af.function_id = ft.function_id
		WHERE ft.function_id IN ( SELECT function_id FROM application_functions WHERE is_sensitive = 1
								  UNION
								  SELECT function_id FROM application_functions WHERE func_ref_id IN (SELECT function_id FROM application_functions WHERE is_sensitive = 1)
								)
	END

	SELECT * FROM #final_table

	DROP TABLE #user_tmp
	DROP TABLE #user_privilege
	DROP TABLE #final_table
END
ELSE IF @flag = 'e'
BEGIN
	SELECT DISTINCT afu.functional_users_id
			  , afu.function_id
			  , afu.entity_id
			  , CASE WHEN ph.hierarchy_level = 0 THEN 'book'
					 WHEN ph.hierarchy_level = 1 THEN 'strategy'
					 WHEN ph.hierarchy_level = 2 THEN 'subsidiary'
				ELSE 'subbook' END 'level'
			  ,afu.source_system_book_id1
			  ,afu.source_system_book_id2
			  ,afu.source_system_book_id3
			  ,afu.source_system_book_id4
	FROM application_users au 
	LEFT JOIN application_role_user aru ON aru.user_login_id = au.user_login_id
	LEFT JOIN application_functional_users afu ON afu.login_id = au.user_login_id OR (afu.role_id = aru.role_id)
	LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = afu.entity_id
	 WHERE au.user_login_id = @login_id
	 and afu.function_id = @application_function_id
END
GO

	
