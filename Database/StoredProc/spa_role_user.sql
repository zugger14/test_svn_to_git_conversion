

IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_role_user]') AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_role_user]

GO

CREATE PROC [dbo].[spa_role_user]
	@flag CHAR(1)
	, @role_id VARCHAR(1000) = NULL
	, @user_login_id VARCHAR(2000) = NULL
	, @user_type VARCHAR(1) = NULL
	, @from_maintain_user VARCHAR(1)= NULL -- for Maintain User UI
AS

SET NOCOUNT ON

DECLARE @sql_stmt VARCHAR(8000)
DECLARE @role_name VARCHAR(1000)					
				
--SELECT @role_name = role_name FROM application_security_role WHERE role_id = @role_id

DECLARE @is_admin BIT
SELECT @is_admin = CASE WHEN [dbo].[FNAAppAdminRoleCheck](dbo.FNADBUser()) = 1 THEN 1
						WHEN [dbo].[FNASecurityAdminRoleCheck](dbo.FNADBUser()) = 1 THEN 1
						ELSE 0 
					END

IF @flag = 's' AND @role_id IS NOT NULL 
BEGIN
	SELECT a.user_login_id [Login ID], 
			a.user_l_name 'Last Name', 
			a.user_f_name 'First Name', 
			a.user_m_name 'Middle Name',
			CASE b.user_type WHEN 'p' THEN 'Primary' WHEN 's' THEN 'Secondary' ELSE 'Other' END 'Role Assign Type'
	FROM  application_role_user b, application_users a 
	WHERE b.role_id = @role_id
 		AND a.user_login_id = b.user_login_id
	ORDER BY CASE b.user_type WHEN 'p' THEN 1 WHEN 's' THEN 2 ELSE 3 END 

END

IF @flag = 's' AND @user_login_id IS NOT NULL AND (@from_maintain_user = 'n' OR @from_maintain_user IS NULL OR @from_maintain_user NOT LIKE 'y')
BEGIN 
	DECLARE @app_admin_role_check INT
	SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(dbo.FNADBUser())
			
	IF @app_admin_role_check = 1 
		BEGIN 
			SELECT DISTINCT a.role_id, a.role_name 'Role Name', a.role_description 'Role Description', a.role_type_value_id,b.user_type 'Role Assign Type'
			FROM application_role_user b, application_security_Role a
		END	
	ELSE
		BEGIN
			SELECT DISTINCT a.role_id, a.role_name 'Role Name', a.role_description 'Role Description', a.role_type_value_id,b.user_type 'Role Assign Type'
			FROM application_role_user b, application_security_Role a
			WHERE a.role_id = b.role_id
			AND b.user_login_id = @user_login_id	
		END
END

IF @flag = 's' AND @from_maintain_user = 'y' AND @user_login_id IS NOT NULL 
BEGIN
	SELECT DISTINCT a.role_id, 
		a.role_name 'Role Name', 
		a.role_description 'Role Description', 
		a.role_type_value_id,
		b.user_type 'Role Assign Type'
	FROM application_role_user b, application_security_Role a
	WHERE a.role_id = b.role_id
		AND b.user_login_id = @user_login_id
END

IF @flag = 's' AND @user_login_id IS NULL AND @role_id IS NULL
BEGIN
	SELECT *
	FROM application_role_user 
END 


ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY	
		INSERT INTO application_role_user (
			role_id
			, user_login_id
			, user_type
		)
		SELECT
			r.item
			, @user_login_id
			, @user_type
		FROM application_role_user aru 
			RIGHT JOIN dbo.SplitCommaSeperatedValues(@role_id) r  
				ON r.item = aru.role_id
				AND aru.user_login_id = @user_login_id
		WHERE aru.role_id IS NULL
					
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='Privilege', @source_object = 'spa_role_user @flag=i'
		END			
					
		EXEC spa_ErrorHANDler 0, 
							'Application User', 
							'spa_role_User', 
							'Success', 
							'Changes have been saved successfully.', ''
			
	END TRY
	BEGIN CATCH
		DECLARE @err_num INT
		SET @err_num = ERROR_NUMBER()
		EXEC spa_ErrorHANDler @err_num, 
								'Role User', 
								'spa_role_user', 
								'DB Error', 
								'Insert of Role to User mapping data failed.', ''
	END CATCH	
END 
ELSE IF @flag = 'u'
BEGIN
	UPDATE application_role_user
	SET	role_id = @role_id,
		user_login_id = @user_login_id,
		user_type = @user_type

	IF @@ERROR <> 0
		EXEC spa_ErrorHANDler @@ERROR, 'Role User', 
				'spa_Role_user', 'DB Error', 
			'Update of Role to User mapping data failed.', ''
	ELSE
	BEGIN
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='Privilege', @source_object = 'spa_role_user @flag=u'
		END	

		EXEC spa_ErrorHANDler 0, 'Application User', 
				'spa_role_User', 'Success', 
				'Changes have been saved successfully.', ''
	END
END	
ELSE IF @flag = 'd'
BEGIN
	--Delete function_ids FROM workflow which are present only in the deleted role
	DELETE sw
	FROM  setup_workflow sw
		INNER JOIN application_role_user aru
			ON sw.user_id = aru.user_login_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@role_id) r 
			ON aru.role_id = r.Item
		INNER JOIN application_functional_users afu
			ON afu.role_id = r.item
			AND afu.function_id = sw.function_id
		LEFT JOIN (
				SELECT function_id 
				FROM application_functional_users 
				WHERE login_id = @user_login_id
				UNION 
				SELECT afu.function_id 
				FROM application_role_user aru 
					INNER JOIN application_functional_users afu
						ON aru.role_id = afu.role_id
					LEFT JOIN dbo.SplitCommaSeperatedValues(@role_id) t
						 ON aru.role_id = t.item
				WHERE aru.user_login_id = @user_login_id
					AND t.item IS NULL
		
			) a
			ON a.function_id = afu.function_id
	WHERE  sw.user_id = @user_login_id
		AND a.function_id IS NULL

	DELETE aru 
	FROM  application_role_user aru
		INNER JOIN dbo.SplitCommaSeperatedValues(@role_id) r 
			ON aru.role_id = r.Item
			AND aru.user_login_id = @user_login_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHANDler @@ERROR, 'Role User', 
				'spa_Role_user', 'DB Error', 
				'Delete of Role to User mapping data failed.', ''
	ELSE
	BEGIN
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='Privilege', @source_object = 'spa_role_user @flag=d'
		END	

		EXEC spa_ErrorHANDler 0, 'Application User', 
				'spa_role_User', 'Success', 
				'Changes have been saved successfully.', ''
	END
END
ELSE IF @flag = 'e'
BEGIN

	DECLARE @login_id VARCHAR(50)

	DECLARE delete_workflow CURSOR FOR  
	SELECT  item user_login_id  
	FROM dbo.SplitCommaSeperatedValues(@user_login_id)

	OPEN delete_workflow   
	FETCH NEXT FROM delete_workflow INTO @login_id   

	WHILE @@FETCH_STATUS = 0   
	BEGIN   	

		DELETE sw
		FROM  application_role_user aru
			INNER JOIN dbo.SplitCommaSeperatedValues(@login_id) r 
				ON  aru.user_login_id = r.Item
				AND aru.role_id = @role_id
			INNER JOIN application_functional_users afu
				ON afu.role_id = aru.role_id
			INNER JOIN setup_workflow sw
				ON sw.function_id = afu.function_id 
				AND sw.user_id = aru.user_login_id
			LEFT JOIN (
						SELECT function_id 
						FROM application_functional_users 
						WHERE login_id = @login_id
						UNION 
						SELECT afu.function_id 
						FROM application_role_user aru 
							INNER JOIN application_functional_users afu
								ON aru.role_id = afu.role_id
						WHERE aru.user_login_id = @login_id
							AND aru.role_id <> @role_id
		
					) a
					ON a.function_id = afu.function_id
		WHERE  sw.user_id = @login_id
			AND a.function_id IS NULL

		FETCH NEXT FROM delete_workflow INTO @login_id   
	END   

	CLOSE delete_workflow   
	DEALLOCATE delete_workflow

	DELETE aru 
	FROM  application_role_user aru
		INNER JOIN dbo.SplitCommaSeperatedValues(@user_login_id) r 
			ON  aru.user_login_id = r.Item
			AND aru.role_id = @role_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHANDler @@ERROR, 'Role User', 
				'spa_Role_user', 'DB Error', 
				'Delete of role to user mapping data failed.', ''
	ELSE
	BEGIN
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='Privilege', @source_object = 'spa_role_user @flag=e'
		END	

		EXEC spa_ErrorHANDler 0, 'Application User', 
				'spa_role_User', 'Success', 
				'Changes have been saved successfully.', ''
	END

END
ELSE IF @flag = 'j'
BEGIN
	BEGIN TRY
		IF @is_admin <> 1 AND EXISTS ( SELECT 1
									   FROM application_security_role asr
									   INNER JOIN static_data_value sdv 
									   	ON asr.role_type_value_id = sdv.value_id
									   WHERE asr.role_type_value_id IN (1,7) AND asr.role_id = @role_id)
		BEGIN
			EXEC spa_ErrorHandler 1, 'Role User', 
				'spa_role_user', 'DB Error', 
				'You do not have privilege to add user to this role.', ''

			RETURN
		END


		INSERT INTO application_role_user
			(
				role_id
				, user_login_id
				, user_type
			)
		SELECT
			@role_id
			, r.item
			, @user_type
		FROM application_role_user aru 
			RIGHT JOIN dbo.SplitCommaSeperatedValues(@user_login_id) r  
				ON r.item = aru.user_login_id
				AND aru.role_id = @role_id
		WHERE aru.role_id IS NULL
			
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='Privilege', @source_object = 'spa_role_user @flag=j'
		END	
			
		EXEC spa_ErrorHANDler 0, 'Application User', 
			'spa_role_User', 'Success', 
			'Changes have been saved successfully.', ''
				
	END TRY
	BEGIN CATCH
		DECLARE @err_num_2 INT
		SET @err_num = ERROR_NUMBER()
		EXEC spa_ErrorHANDler @err_num_2, 'Role User', 
				'spa_role_user', 'DB Error', 
				'Insert of Role to user mapping data failed.', ''
	END CATCH
		
END	
ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
		IF @is_admin <> 1 AND EXISTS ( SELECT 1
									   FROM application_security_role asr
									   INNER JOIN static_data_value sdv 
									   	ON asr.role_type_value_id = sdv.value_id
									   WHERE asr.role_type_value_id IN (1,7) AND asr.role_id = @role_id)
		BEGIN
			EXEC spa_ErrorHandler 1, 'Role User', 
				'spa_role_user', 'DB Error', 
				'You do not have privilege to add user to this role.', ''

			RETURN
		END

		INSERT INTO application_role_user (
				user_login_id, 
				role_id, 
				user_type
			)
		SELECT
			@user_login_id, 
			r.item, 
			@user_type
		FROM application_role_user aru 
			RIGHT JOIN dbo.SplitCommaSeperatedValues(@role_id) r  
				ON r.item = aru.role_id
				AND aru.user_login_id = @user_login_id
		WHERE aru.role_id IS NULL
	
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='Privilege', @source_object = 'spa_role_user @flag=r'
		END	
	
		EXEC spa_ErrorHANDler 0, 'Application User', 
				'spa_role_User', 'Success', 
				'Changes have been saved successfully.', ''
	END TRY
	BEGIN CATCH
		DECLARE @err_num_3 INT
		SET @err_num = ERROR_NUMBER()
		EXEC spa_ErrorHANDler @err_num_3, 'Role User', 
				'spa_role_user', 'DB Error', 
				'Insert of Role to User mapping data failed.', ''
	END CATCH
END
ELSE IF @flag = 'g'
BEGIN
	IF OBJECT_ID('tempdb..#accordion_data_grid') IS NOT NULL
		DROP TABLE #accordion_data_grid
	
	SET @user_login_id = dbo.FNADBUser()

	CREATE TABLE #accordion_data_grid(
		accordion_name			NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
		id						INT,
		name					NVARCHAR(50) COLLATE DATABASE_DEFAULT 
	)

	IF dbo.FNAAppAdminRoleCheck(@user_login_id) = 1 OR dbo.FNAIsUserOnAdminGroup(@user_login_id, 0) = 1
	BEGIN
		INSERT INTO #accordion_data_grid(accordion_name, id, name)
		SELECT 'User Workflow', 0, 'My WorkFlow'
		UNION
		SELECT  'Role Workflow'
			, a.role_id
			, a.role_name
		FROM  application_security_Role a 
	
	END 
	ELSE
	BEGIN
		INSERT INTO #accordion_data_grid(accordion_name, id, name)
		SELECT 'User Workflow', 0, 'My WorkFlow'
		UNION
		SELECT  'Role Workflow'
			, a.role_id
			, a.role_name
		FROM  application_security_Role a 
			INNER JOIN application_role_user aru
				ON a.role_id = aru.role_id
		WHERE aru.user_login_id = @user_login_id
	END

	SELECT accordion_name,
			id,			
			UPPER(LEFT(name, 1)) + RIGHT(name, LEN(name) - 1) name
	FROM #accordion_data_grid
	ORDER BY accordion_name DESC, name 
		   
END
ELSE IF @flag = 't'
BEGIN
	IF @is_admin = 1
	BEGIN
		SELECT value_id [value],code [text] FROM static_data_value WHERE [type_id] = 1
	END
	ELSE
	BEGIN
		SELECT value_id [value],code [text] FROM static_data_value WHERE [type_id] = 1 AND value_id NOT IN (1,7)
	END
END		   		
