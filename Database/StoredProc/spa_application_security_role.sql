
IF OBJECT_ID('dbo.spa_application_security_role','p') IS NOT NULL
	DROP PROC dbo.spa_application_security_role
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Used for CRUD operation of table application_security_role.

	Parameters
	@flag : Flag operations
	@role_id : Primary key of table application_security_role.
	@role_name : Name of the role.
	@role_description : Description of the role.
	@role_type_value_id : role_type_value_id of table application_security_role.
	@process_map_file_name : process_map_file_name of table application_security_role.
	@farrms_module : 11000000 for compliance
	@process_id : Unique identifier to create process table.
	@user_login_id : To filter role by user name.
	@type_id : Type_id of table static_data_privilege.
	@value_id : Value_id of table static_data_privilege.
	@del_role_id : Role_id of table static_data_privilege and deal_lock_setup.
	@ixp_rules_id : rule_id of table ixp_import_data_source.

*/

CREATE PROC [dbo].[spa_application_security_role]
	@flag CHAR(1),
	@role_id INT = NULL,
	@role_name VARCHAR(50) = NULL,
	@role_description VARCHAR(250) = NULL,
	@role_type_value_id INT = NULL,
	@process_map_file_name VARCHAR(1000) = NULL,
	@farrms_module INT = NULL,	-- @farrms_module = 11000000 for compliance
	@process_id VARCHAR(50) = NULL,
	@user_login_id VARCHAR(50) = NULL, -- ADDED TO FILTER ROLE BY USER NAME
	@type_id INT = NULL,
	@value_id INT = NULL,
	@del_role_id VARCHAR(500) = NULL,
	@ixp_rules_id INT = NULL
AS

SET NOCOUNT ON

DECLARE @sql_stmt VARCHAR(1000)

/* Hide SaaS Administrative forms for all users except for Application Admin*/
DECLARE @is_admin BIT
SELECT @is_admin = CASE WHEN [dbo].[FNAAppAdminRoleCheck](dbo.FNADBUser()) = 1 THEN 1
						WHEN [dbo].[FNASecurityAdminRoleCheck](dbo.FNADBUser()) = 1 THEN 1
						ELSE 0 
					END

IF @flag = 's' 
BEGIN 
	SET @sql_stmt = 'SELECT  role_id AS [Role Id], role_name AS [Role Name]
					, role_description AS [Role Description], 
					role_type_value_id--, process_map_file_name--, create_user, create_ts, update_user, update_ts
					FROM application_security_role  
					WHERE 1 = 1 AND role_id NOT IN (SELECT 
											role_id
										FROM  
											batch_process_notifications
										WHERE 1 = 1 
											AND process_id=''' + ISNULL(@process_id, '') + '''
											AND role_id IS NOT NULL)'
	IF @role_id IS NOT NULL 
		SET @sql_stmt = @sql_stmt + ' AND role_id = ' + CAST(@role_id AS VARCHAR) 
	
	IF @farrms_module IS NOT NULL AND @farrms_module = 11000000
		SET @sql_stmt = @sql_stmt + ' AND role_type_value_id = 4 '
	
		SET @sql_stmt = @sql_stmt +  'ORDER BY role_name asc'	
	
	EXEC (@sql_stmt)	
END
ELSE IF @flag = 'i'
BEGIN

	IF NOT EXISTS (SELECT 1 FROM application_security_role WHERE role_name = @role_name)
	BEGIN 		
		INSERT INTO application_security_role (
			role_name,
			role_description,
			role_type_value_id, 
			process_map_file_name
		)
		VALUES (
			@role_name,
			@role_description,
			@role_type_value_id, @process_map_file_name
		)
		
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, 'application_security_role', 
					'spa_application_security_role', 'DB Error', 
					'Insert of application security Role failed.', ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Application Security Role', 
					'spa_application_security_role', 'Success', 
					'Application Security Roles successfully Inserted', ''
	END 
	ELSE 
		EXEC spa_ErrorHandler -1, 'application_security_role', 
					'spa_application_security_role', 'DB Error', 
					'This role name already exists!', ''

END	
ELSE IF @flag = 'u'
BEGIN
	UPDATE application_security_role
	SET	role_name = @role_name,
		role_description = @role_description,
		role_type_value_id = @role_type_value_id,
		process_map_file_name = @process_map_file_name
	WHERE role_id = @role_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'application_security_role', 
				'spa_application_security_role', 'DB Error', 
				'UPDATE of application security Role failed.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Application Security Role', 
				'spa_application_security_role', 'Success', 
				'Application Security Roles successfully updated.', ''

END	
ELSE IF @flag = 'd'
BEGIN
	IF EXISTS(
		SELECT 1 
		FROM deal_lock_setup dls
		INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = dls.role_id
	)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Application Security Role', 
			'spa_application_security_role', 'DB Error', 
			'The selected role is in use in Logical Trade Lock.', ''
	END
	ELSE IF EXISTS(
		SELECT 1
		FROM application_role_user aru
		INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = aru.role_id
	)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Application Security Role', 
			'spa_application_security_role', 'DB Error', 
			'The selected role is mapped with User.', ''
	END
	--ELSE IF EXISTS(SELECT 1 FROM application_functional_users WHERE role_id = @role_id)
	--BEGIN
	--	EXEC spa_ErrorHandler -1, 'Application Security Role', 
	--			'spa_application_security_role', 'DB Error',	
	--			'The selected role has assigned privilege.', ''
	--END
	ELSE IF EXISTS(
		SELECT 1
		FROM process_requirements_assignment pra
		INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = pra.approve_role
			OR pra.perform_role = di.item
	)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Application Security Role', 
			'spa_application_security_role', 'DB Error', 
			'The selected role is mapped with process requirements assignment.', ''
	END
	ELSE IF EXISTS(
		SELECT 1
		FROM process_requirements_assignment_trigger prat
		INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = prat.approve_role
			OR prat.perform_role = di.item
	)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Application Security Role', 
			'spa_application_security_role', 'DB Error', 
			'The selected role is mapped with process requirements assignment trigger.', ''
	END
	ELSE IF EXISTS(
		SELECT 1
		FROM process_requirements_revisions prr
		INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = prr.approve_role
			OR prr.perform_role = di.item
	)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Application Security Role', 
			'spa_application_security_role', 'DB Error', 
			'The selected role is mapped with process requirements revisions.', ''
	END
	ELSE
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			DELETE aru
			FROM application_role_user aru
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = aru.role_id
			-- Added since role_id is referenced to application_security_role role_id

			DELETE mi
			FROM menu_item mi
			INNER JOIN menu_group mg ON mg.menu_group_id = mi.menu_group_id
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = mg.role_id

			DELETE mg
			FROM menu_group mg
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = mg.role_id

			DELETE prce
			FROM process_risk_controls_email prce
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = prce.inform_role

			DELETE rmvu
			FROM report_manager_view_users rmvu
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = rmvu.role_id

			DELETE rwvu
			FROM report_writer_view_users rwvu
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = rwvu.role_id

			DELETE spcdp
			FROM source_price_curve_def_privilege spcdp
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = spcdp.role_id

			DELETE asr
			FROM application_security_role asr
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = asr.role_id

			DELETE bpn
			FROM batch_process_notifications bpn
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = bpn.role_id

			DELETE au
			FROM alert_users au
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = au.role_id

			DELETE ipp
			FROM ipx_privileges ipp
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = ipp.role_id

			DELETE sw
			FROM setup_workflow sw
			INNER JOIN dbo.FNASplit(@del_role_id, ',') di ON di.item = sw.role_id

			COMMIT TRANSACTION

			EXEC spa_ErrorHandler 0, 'Application Security Role', 
				'spa_application_security_role', 'Success', 
				'Application Security Roles successfully deleted.', ''
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			EXEC spa_ErrorHandler @@ERROR, 'application_security_role', 
				'spa_application_security_role', 'DB Error', 
				'delete of application security Role failed.', ''
		END CATCH
	END
END
ELSE IF @flag = 'c' AND @role_id IS NOT NULL
BEGIN
	SELECT user_login_id,
		   user_login_id
	FROM   application_role_user
	WHERE  role_id = @role_id
END       
ELSE IF @flag = 'c' AND @role_id IS NULL
BEGIN
	SELECT user_login_id,
		   user_login_id
	FROM   application_users 
END
ELSE IF @flag = 'g'
BEGIN
	DECLARE @sql VARCHAR(8000)
	SET @sql = 'SELECT role_id, code [role_name], role_name [role_description]
				FROM application_security_role asr
				INNER JOIN static_data_value sdv 
					ON asr.role_type_value_id = sdv.value_id'

	IF @user_login_id IS NOT NULL
	SET @sql = @sql + ' WHERE asr.role_id IN  (SELECT role_id FROM application_role_user
						 WHERE user_login_id = ''' + CAST(@user_login_id AS VARCHAR) + ''')'
	EXEC (@sql)
END

ELSE IF @flag = 'p'
BEGIN
	DECLARE @sql_role VARCHAR(8000)
	SET @sql_role = 'SELECT asr.role_id [Role ID], code [role_name], role_name [role_description]
					FROM application_security_role asr
						INNER JOIN static_data_value sdv 
							ON asr.role_type_value_id = sdv.value_id'

	IF @user_login_id IS NOT NULL
	SET @sql_role = @sql_role + ' WHERE asr.role_id NOT IN  (SELECT role_id FROM application_role_user
						 WHERE user_login_id = ''' + @user_login_id + ''')'

	IF @is_admin <> 1
	BEGIN
		SET @sql_role += ' AND sdv.value_id NOT IN (1,7,23)'
	END

	EXEC (@sql_role)
END
IF @flag = 'f' 
BEGIN 	
	SELECT  aru.user_login_id,
			(ap.user_f_name + ' ' +  ISNULL(ap.user_m_name, '') + ' ' + ap.user_l_name) AS [name],
			ap.application_users_id [System ID]
	FROM application_role_user aru 
		LEFT JOIN application_users ap 
			ON aru.user_login_id = ap.user_login_id 
	WHERE aru.role_id = @role_id
END 

IF @flag = 't'
BEGIN
	SELECT role_id AS [role_id], sdv.code AS [role_type], role_name AS [role_description] 
	FROM application_security_role AS asr
		INNER JOIN static_data_value AS sdv 
			ON sdv.value_id = asr.role_type_value_id
	ORDER BY role_type, role_name ASC
END

IF @flag = 'z'
BEGIN
	IF @is_admin = 1
	BEGIN
		SELECT sdv.code [role_type], role_name AS [Role Name] , role_id AS [Role Id] 
		FROM application_security_role AS asr
			INNER JOIN static_data_value AS sdv 
				ON sdv.value_id = asr.role_type_value_id
	END
	ELSE
	BEGIN
		SELECT sdv.code [role_type], role_name AS [Role Name] , role_id AS [Role Id]
		FROM application_security_role AS asr
			INNER JOIN static_data_value AS sdv 
				ON sdv.value_id = asr.role_type_value_id
		WHERE sdv.value_id NOT IN (1,7)
	END
END

IF @flag = 'y'
BEGIN
	IF @is_admin = 1
	BEGIN
		SELECT NULL AS [role_type], NULL AS [Role Id], NULL as [Role Name] 
		UNION ALL 
		SELECT sdv.code [role_type], role_id AS [Role Id] , role_name AS [Role Name] 
		FROM application_security_role AS asr
			INNER JOIN static_data_value AS sdv 
				ON sdv.value_id = asr.role_type_value_id
	END
	ELSE
	BEGIN
		SELECT NULL AS [role_type], NULL AS [Role Id], NULL as [Role Name] 
		UNION ALL 
		SELECT sdv.code [role_type], role_id AS [Role Id] , role_name AS [Role Name] 
		FROM application_security_role AS asr
		INNER JOIN static_data_value AS sdv 
			ON sdv.value_id = asr.role_type_value_id
		WHERE sdv.value_id NOT IN (1,7) 
	END
END

IF @flag = 'v'
BEGIN
	IF OBJECT_ID('tempdb..#menu_role') IS NOT NULL
		DROP TABLE #menu_role
	
	IF @user_login_id IS NULL
		SET  @user_login_id = dbo.FNADBUser()

	CREATE TABLE #menu_role(
		role_id			INT,
		role_name		VARCHAR(200) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #menu_role
	SELECT -100, 'System Defined'

	IF EXISTS (SELECT 1 FROM setup_workflow WHERE user_id = @user_login_id) 
	BEGIN
		INSERT INTO #menu_role
		SELECT -200, 'My Workflow'
	END

	IF dbo.FNAIsUserOnAdminGroup(@user_login_id, 0) = 1
	BEGIN
		INSERT INTO #menu_role
		SELECT a.role_id
			, 'Role Workflow - '+ a.role_name
		FROM  application_security_Role a 
		WHERE a.role_id <> -1
	
	END 
	ELSE
	BEGIN
		INSERT INTO #menu_role
		SELECT a.role_id
			, 'Role Workflow - '  + a.role_name
		FROM  application_security_Role a 
			INNER JOIN application_role_user aru
				ON a.role_id = aru.role_id
		WHERE aru.user_login_id = @user_login_id
			AND a.role_id <> -1
	END

	SELECT 
		role_id,
		role_name		
	FROM #menu_role
	ORDER BY 
		CASE role_name 
			WHEN 'System Defined' THEN
				'aaaaaaa' + role_name 
			WHEN 'My Workflow' THEN
				'aaaaaab' + role_name
		ELSE 
			role_name
		END 
END

ELSE IF @flag = 'm'
BEGIN 
	SELECT  asr.role_id AS [Role Id], role_name AS [Role Name]
	FROM application_security_role asr
	LEFT JOIN static_data_privilege sdp 
		ON sdp.role_id = asr.role_id
		AND sdp.type_id = @type_id
		AND sdp.value_id = @value_id
	WHERE static_data_privilege_id IS NULL
		
END
ELSE IF @flag = 'n'
BEGIN 
	SET @sql_stmt = 'SELECT  asr.role_id AS [Role Id], role_name AS [Role Name]
					FROM application_security_role asr'
					IF (@type_id IS NOT NULL AND @value_id IS NOT NULL)
						SET @sql_stmt = @sql_stmt + ' INNER JOIN static_data_privilege sdp ON sdp.role_id = asr.role_id
						WHERE  type_id =''' + CAST(@type_id AS VARCHAR(10)) + ''' AND value_id = ''' + CAST(@value_id AS VARCHAR(10)) + ''''
					SET @sql_stmt = @sql_stmt + ' ORDER BY role_name ASC'
	
	EXEC (@sql_stmt)
END
Else IF @flag = 'k'
BEGIN 
	SET @sql_stmt = 'Select NULL as role_id, NULL as role_name, NULL as role_description, NULL as role_type_value_id
					UNION ALL 
					SELECT  role_id AS [Role Id], role_name AS [Role Name]
					, role_description AS [Role Description], 
					role_type_value_id--, process_map_file_name--, create_user, create_ts, update_user, update_ts
					FROM application_security_role  
					WHERE 1 = 1 AND role_id NOT IN (SELECT 
											role_id
										FROM  
											batch_process_notifications
										WHERE 1 = 1 
											AND process_id=''' + ISNULL(@process_id, '') + '''
											AND role_id IS NOT NULL)'
	IF @role_id IS NOT NULL 
		SET @sql_stmt = @sql_stmt + ' AND role_id = ' + CAST(@role_id AS VARCHAR) 
	
	IF @farrms_module IS NOT NULL AND @farrms_module = 11000000
		SET @sql_stmt = @sql_stmt + ' AND role_type_value_id = 4 '
	
		SET @sql_stmt = @sql_stmt +  'ORDER BY role_name asc'	
	
	EXEC (@sql_stmt)	
END
IF @flag = 'q'
BEGIN
	SELECT asr.role_id, asr.role_name FROM workflow_event_user_role inn 
	INNER JOIN application_security_role asr ON asr.role_id = inn.role_id
	INNER JOIN ixp_import_data_source imds ON imds.message_id = inn.event_message_id
	where imds.rules_id= @ixp_rules_id
END

IF @flag = 'l'
BEGIN
	SELECT asr.role_id, asr.role_name FROM application_security_role asr 
	LEFT JOIN workflow_event_user_role inn ON asr.role_id = inn.role_id
	LEFT JOIN ixp_import_data_source imds ON imds.message_id = inn.event_message_id AND imds.rules_id != @ixp_rules_id 
	WHERE  inn.role_id IS NULL
END

IF (@flag = 'b' and @role_name is not NULL)
BEGIN
	SELECT
		Distinct
		   	stuff((
				select ',' + cast(asr.role_id as varchar(500))
				from application_security_role asr
       			INNER JOIN dbo.SplitCommaSeperatedValues(@role_name) tn ON LTRIM(RTRIM(asr.role_name)) = LTRIM(RTRIM(tn.item))
				order by asr.role_name
				for xml path('')
			),1,1,'') as rolelist
		from application_security_role
END
