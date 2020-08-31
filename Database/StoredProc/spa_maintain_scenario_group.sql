IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_maintain_scenario_group]')
              AND TYPE IN (N'P', N'PC')
)
DROP PROCEDURE [dbo].[spa_maintain_scenario_group]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_maintain_scenario_group]
    @flag CHAR(1)
    , @group_id INT = NULL
    , @group_name VARCHAR(100) = NULL
    , @group_description VARCHAR(100) = NULL
    , @user VARCHAR(100) = NULL
    , @role VARCHAR(100) = NULL
    , @active CHAR(1) = NULL
    , @public CHAR(1) = NULL
    , @source VARCHAR(50) = NULL
	, @volatility_source INT = NULL
    
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
    --SELECT ALL ROWS FROM THE TABLE
    SET @sql = 'SELECT	msg.scenario_group_id
						, msg.scenario_group_name AS [Scenario Name]
						, msg.scenario_group_description AS [Scenario Description]
						, msg.[user] AS [User]
						, msg.[role] AS [Role]
						, msg.[active] AS [Active]
						, msg.[public] AS [Public]
						, msg.[source] AS [Source]
				FROM maintain_scenario_group msg'
	EXEC(@sql)
END
ELSE IF @flag = 'i'
BEGIN
	IF NOT EXISTS(	SELECT 1 FROM dbo.maintain_scenario_group
					WHERE [scenario_group_name] = @group_name
					)
	BEGIN TRY
		INSERT INTO dbo.maintain_scenario_group
		(
			[scenario_group_name]
			, [scenario_group_description]
			, [user]
			, [role]
			, [active]
			, [public]
			, [source]
			, [volatility_source]
		) 
		VALUES 
		(	@group_name
			, @group_description
			, @user
			, @role
			, @active
			, @public
			, @source
			, @volatility_source
		)
		
		SET @group_id = SCOPE_IDENTITY()
		
		EXEC spa_ErrorHandler 0
			, 'maintain_scenario_group'
			, 'spa_maintain_scenario_group'
			, 'Success'
			, 'Successfully inserted group new record.'
			, @group_id
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'maintain_scenario_group'
			, 'spa_maintain_scenario_group'
			, 'DB ERROR'
			, 'Insert group new record failed.'
			, ''
	END CATCH
	ELSE
	BEGIN
		EXEC spa_print 'Group Name: ', @group_name, ' ALREADY EXISTS.'
		EXEC spa_ErrorHandler -1
			, 'maintain_scenario_group'
			, 'spa_maintain_scenario_group'
			, 'DB ERROR'
			, 'Group name already exists.'
			, ''
	END
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		UPDATE  maintain_scenario_group
		SET scenario_group_name = @group_name, 
			scenario_group_description = @group_description, 
			[user] = @user, 
			[role] = @role,
			[active] = @active, 
			[public] = @public,
			[source] = @source,
			[volatility_source] = @volatility_source
		WHERE scenario_group_id = @group_id
		
		UPDATE maintain_scenario SET source = @source WHERE scenario_group_id = @group_id
		
		EXEC spa_ErrorHandler 0
			, 'maintain_scenario_group'
			, 'spa_maintain_scenario_group'
			, 'Success'
			, 'Successfully updated group new record.'
			, @group_id
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'maintain_scenario_group'
			, 'spa_maintain_scenario_group'
			, 'DB ERROR'
			, 'Update group new record failed.'
			, ''
	END CATCH
END
ELSE IF @flag = 'g'
BEGIN
	--SELECT A MATCHED ROW FROM THE TABLE FOR GRID DISPLAY AND REPORT
	SET @sql = 'SELECT	msg.scenario_group_id AS [ID]
						,  msg.scenario_group_name AS [Group Name]
						, msg.scenario_group_description AS [Group Description]
						, msg.[user] AS [User]
						, asr.role_name AS [Role]
						, CASE WHEN msg.[active] = ''y'' THEN ''Yes'' ELSE ''No'' END [Active]
						, CASE WHEN msg.[public] = ''y'' THEN ''Yes'' ELSE ''No'' END [Public]
						, sdv.code AS [Source]
						, vs.code AS [Volatility Source]
				FROM maintain_scenario_group msg
				LEFT JOIN application_security_role asr ON asr.role_id= msg.[role]
				LEFT JOIN static_data_value sdv ON sdv.value_id = msg.source 
				LEFT JOIN static_data_value vs ON vs.value_id = msg.volatility_source 
				WHERE msg.[active] = ''' + @active + ''' AND msg.[public] = ''' + @public + ''''
	IF (@user IS NOT NULL)
		SET @sql += ' AND msg.[user] = ''' + @user + ''''          
	IF (@role IS NOT NULL)
		SET @sql += ' AND msg.[role] = ''' + @role + ''''
	EXEC(@sql)
END
ELSE IF @flag = 'a'
BEGIN
	SET @sql = 'SELECT	msg.scenario_group_id
						, msg.scenario_group_name AS [Group Name]
						, msg.scenario_group_description AS [Group Description]
						, msg.[user] AS [User]
						, msg.[role] AS [Role]
						, msg.[active] AS [Active]
						, msg.[public] AS [Public]
						, msg.[source] AS [Source]
						, msg.volatility_source
				FROM maintain_scenario_group msg 
				WHERE msg.[scenario_group_id] = ' + CAST(@group_id AS VARCHAR(10))
	EXEC(@sql)
END
ELSE IF @flag = 'd'
BEGIN
    --DELETE STATEMENT GOES HERE
    BEGIN TRY
		BEGIN TRAN
    		DELETE FROM maintain_scenario_group
    		WHERE scenario_group_id = @group_id
    	COMMIT
		EXEC spa_ErrorHandler 0
			, 'maintain_scenario'
			, 'spa_maintain_scenario'
			, 'Success'
			, 'Successfully deleted group record.'
			, ''
    END TRY
    BEGIN CATCH
    	ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'maintain_scenario'
			, 'spa_maintain_scenario'
			, 'DB ERROR'
			, 'Delete group record failed.'
			, ''
    END CATCH
END