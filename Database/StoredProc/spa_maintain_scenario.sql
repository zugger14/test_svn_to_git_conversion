IF OBJECT_ID(N'[dbo].[spa_maintain_scenario]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_maintain_scenario]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 6/18/2012
-- Description: CRUD operations for table maintain_scenario

-- Params:
-- @flag CHAR(1) - Operation flag
-- @scenraio_name VARCHAR(100)
-- @scenario_description VARCHAR(100)
-- @user VARCHAR(100) 
-- @role VARCHAR(100)
-- @active CHAR(1)
-- @public CHAR(1)
-- @shift_by VARCHAR(100) - price shift by
-- @shift_value DECIMAL(20,10) - price shift value
-- @source VARCHAR(100) - price source
-- @use_existing_values CHAR(1) 
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_maintain_scenario]
    @flag CHAR(1)
    , @scenario_id INT = NULL
    , @scenario_name VARCHAR(100) = NULL
    , @scenario_description VARCHAR(100) = NULL
    , @user VARCHAR(100) = NULL
    , @role VARCHAR(100) = NULL
    , @active CHAR(1) = NULL
    , @public CHAR(1) = NULL
    , @shift_by CHAR(1) = NULL
    , @shift_value NUMERIC(20, 10) = NULL
    , @source VARCHAR(100) = NULL
    , @use_existing_values CHAR(1) = NULL
    , @group_id INT 
    , @shift VARCHAR(100) = NULL 
    , @shift_item VARCHAR(100) = NULL 
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
    --SELECT ALL ROWS FROM THE TABLE
    SET @sql = 'SELECT	ms.scenario_id
						, ms.scenario_name AS [Scenario Name]
						, ms.scenario_description AS [Scenario Description]
						, ms.[user] AS [User]
						, ms.[role] AS [Role]
						, ms.[active] AS [Active]
						, ms.[public] AS [Public]
						, ms.shift_by AS [Shift By]
						, dbo.FNARemoveTrailingZero(ms.shift_value) AS [Shift Value]
						, ms.[source] AS [Source]
						, ms.use_existing_values AS [Use Existing Values]
				FROM maintain_scenario ms'
	EXEC(@sql)
END
ELSE IF @flag = 'a'
BEGIN
	SET @sql = 'SELECT	ms.scenario_id
						, ms.scenario_name AS [Scenario Name]
						, ms.scenario_description AS [Scenario Description]
						, ms.[user] AS [User]
						, ms.[role] AS [Role]
						, ms.[active] AS [Active]
						, ms.[public] AS [Public]
						, ms.shift_by AS [Shift By]
						, dbo.FNARemoveTrailingZero(ms.shift_value) AS [Shift Value]
						, ms.[source] AS [Source]
						, ms.use_existing_values AS [Use Existing Values]
						, ms.shift_group AS [Shift]
						, ms.shift_item AS [Shift Item]
				FROM maintain_scenario ms 
				WHERE ms.[scenario_id] = ' + CAST(@scenario_id AS VARCHAR(10))
	EXEC(@sql)
END
ELSE IF @flag = 'g'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE FOR GRID DISPLAY AND REPORT
	SET @sql = 'SELECT	ms.scenario_id AS [ID]
						, dbo.FNAHyperlinkText3(10183310, ms.scenario_name, ms.scenario_id,' + CAST(@group_id AS VARCHAR(10)) + ') AS [Scenario Name]
						, ms.scenario_description AS [Scenario Description]
						, sdv.code AS [Shift]
						, CASE 
							WHEN ms.shift_group = 24003
								THEN sc.commodity_name
							WHEN ms.shift_group = 24002
								THEN sdv1.code
							WHEN ms.shift_group = 24001
								THEN spcd.curve_name
							END  [Shift Item]
						, CASE WHEN ms.shift_by = ''v'' THEN ''Value'' ELSE ''Percentage'' END [Shift By]
						, dbo.FNARemoveTrailingZero(ms.shift_value) AS [Shift Value]
						, CASE WHEN ms.use_existing_values = ''y'' THEN ''Yes'' ELSE ''No'' END [Use Existing Values]
				FROM maintain_scenario ms	
				LEFT JOIN application_security_role asr ON asr.role_id= ms.[role]
				LEFT JOIN static_data_value sdv2 ON sdv2.value_id = ms.source
				LEFT JOIN static_data_value sdv1 ON sdv1.value_id = ms.shift_item
				LEFT JOIN static_data_value sdv ON sdv.value_id = ms.shift_group
				LEFT JOIN source_commodity sc ON ms.shift_item = sc.source_commodity_id
				LEFT JOIN source_price_curve_def spcd ON ms.shift_item = spcd.source_curve_def_id
				WHERE ms.[scenario_group_id] = ' + CAST(@group_id AS VARCHAR(10)) + ''
				
	EXEC(@sql)
END
ELSE IF @flag = 'i'
BEGIN
	--INSERT STATEMENT GOES HERE
	IF NOT EXISTS(	SELECT 1 FROM dbo.maintain_scenario 
					WHERE [scenario_name] = @scenario_name AND [scenario_group_id] = @group_id
					)
		
		IF NOT EXISTS( SELECT 1 FROM dbo.maintain_scenario	
		               WHERE [shift_group] = @shift AND [shift_item] = @shift_item AND scenario_group_id = @group_id )
		BEGIN TRY
			IF @shift IS NULL 
			BEGIN
				IF EXISTS (SELECT 1 FROM maintain_scenario WHERE shift_group IS NULL AND scenario_group_id = @group_id )
				BEGIN
					EXEC spa_ErrorHandler -1
					, 'maintain_scenario'
					, 'spa_maintain_scenario'
					, 'DB ERROR'
					, 'This combination of shift and shift item already exists.'
					, ''
					
					RETURN
				END	
			END
		
			SELECT @source = source FROM maintain_scenario_group WHERE scenario_group_id = @group_id
			INSERT INTO dbo.maintain_scenario
			(
				[scenario_name]
				, [scenario_description]
				, [user]
				, [role]
				, [active]
				, [public]
				, [shift_by]
				, [shift_value]
				, [source]
				, [use_existing_values]
				, [scenario_group_id]
				, [shift_group]
				, [shift_item]
			) 
			VALUES 
			(	@scenario_name
				, @scenario_description
				, @user
				, @role
				, @active
				, @public
				, @shift_by
				, @shift_value
				, @source
				, @use_existing_values
				, @group_id
				, @shift
				, @shift_item
				
			)
			
			EXEC spa_ErrorHandler 0
				, 'maintain_scenario'
				, 'spa_maintain_scenario'
				, 'Success'
				, 'Successfully inserted scenario new record.'
				, ''
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler -1
				, 'maintain_scenario'
				, 'spa_maintain_scenario'
				, 'DB ERROR'
				, 'Insert scenario new record failed.'
				, ''
		END CATCH
		ELSE 
		BEGIN
			EXEC spa_ErrorHandler -1
			, 'maintain_scenario'
			, 'spa_maintain_scenario'
			, 'DB ERROR'
			, 'This combination of shift and shift item already exists.'
			, ''
		END
	ELSE
	BEGIN
		EXEC spa_print 'Scenario Name: ', @scenario_name, ' ALREADY EXISTS.'
		EXEC spa_ErrorHandler -1
			, 'maintain_scenario'
			, 'spa_maintain_scenario'
			, 'DB ERROR'
			, 'Scenario name already exists.'
			, ''
	END
END

ELSE IF @flag = 'u'
BEGIN
    --UPDATE STATEMENT GOES HERE
    IF NOT EXISTS(	SELECT 1 FROM dbo.maintain_scenario 
					WHERE [scenario_name] = @scenario_name AND scenario_id != @scenario_id)
		IF NOT EXISTS( SELECT 1 FROM dbo.maintain_scenario	
						   WHERE [shift_group] = @shift AND [shift_item] = @shift_item AND scenario_group_id = @group_id 
						   AND scenario_id <> @scenario_id)
		BEGIN TRY
			IF @shift IS NULL 
			BEGIN
				IF EXISTS (SELECT 1 FROM maintain_scenario WHERE shift_group IS NULL AND scenario_group_id = @group_id AND scenario_id <> @scenario_id)
				BEGIN
					EXEC spa_ErrorHandler -1
					, 'maintain_scenario'
					, 'spa_maintain_scenario'
					, 'DB ERROR'
					, 'This combination of shift and shift item already exists.'
					, ''
					
					RETURN
				END
			END
			BEGIN TRAN
				SELECT @source = source FROM maintain_scenario_group WHERE scenario_group_id = @group_id
				
				UPDATE  ms
				SET		ms.scenario_name = @scenario_name 
						, ms.scenario_description = @scenario_description
						, ms.[user] = @user
						, ms.[role] = @role
						, ms.[active] = @active
						, ms.[public] = @public
						, ms.shift_by = @shift_by
						, ms.shift_value = @shift_value 
						, ms.[source] = @source
						, ms.use_existing_values = @use_existing_values
						, ms.shift_group = @shift
						, ms.shift_item = @shift_item
						  
				FROM maintain_scenario ms 
				WHERE ms.[scenario_id] = @scenario_id
			COMMIT
			EXEC spa_ErrorHandler 0
				, 'maintain_scenario'
				, 'spa_maintain_scenario'
				, 'Success'
				, 'Successfully updated scenario record.'
				, ''
		END TRY
		BEGIN CATCH
			ROLLBACK
			EXEC spa_ErrorHandler -1
				, 'maintain_scenario'
				, 'spa_maintain_scenario'
				, 'DB ERROR'
				, 'Update scenario record failed.'
				, ''
		END CATCH
		ELSE 
		BEGIN
			EXEC spa_ErrorHandler -1
			, 'maintain_scenario'
			, 'spa_maintain_scenario'
			, 'DB ERROR'
			, 'This combination of shift and shift item already exists.'
			, ''
		END
	ELSE
	BEGIN
		EXEC spa_print 'Scenario Name: ', @scenario_name, ' ALREADY EXISTS.'
		EXEC spa_ErrorHandler -1
			, 'maintain_scenario'
			, 'spa_maintain_scenario'
			, 'DB ERROR'
			, 'Scenario name already exists.'
			, ''
	END
END
ELSE IF @flag = 'h'
BEGIN
select ms.scenario_id, ms.scenario_name,  ms.scenario_description,dbo.FNARemoveTrailingZero(ms.shift_value), sdv.code AS [Shift],
CASE 	WHEN ms.shift_group = 24003
			THEN sc.commodity_name
		WHEN ms.shift_group = 24002
			THEN sdv1.code
		WHEN ms.shift_group = 24001
			THEN spcd.curve_name
		END  [Shift Item], 
CASE WHEN shift_by = 'v' THEN 'Value' ELSE 'Percentage' END [Shift By]
, CASE WHEN use_existing_values = 'y' THEN 'Yes' ELSE 'No' END [Use Existing Values] 
from maintain_scenario ms 
LEFT JOIN static_data_value sdv ON sdv.value_id = ms.shift_group
LEFT JOIN application_security_role asr ON asr.role_id= ms.[role]
LEFT JOIN static_data_value sdv2 ON sdv2.value_id = ms.source
LEFT JOIN static_data_value sdv1 ON sdv1.value_id = ms.shift_item
LEFT JOIN source_commodity sc ON ms.shift_item = sc.source_commodity_id
LEFT JOIN source_price_curve_def spcd ON ms.shift_item = spcd.source_curve_def_id
where scenario_group_id = @group_id
END


ELSE IF @flag = 'd'
BEGIN
    --DELETE STATEMENT GOES HERE
    BEGIN TRY
		BEGIN TRAN
    		DELETE FROM maintain_scenario
    		WHERE scenario_id = @scenario_id
    	COMMIT
		EXEC spa_ErrorHandler 0
			, 'maintain_scenario'
			, 'spa_maintain_scenario'
			, 'Success'
			, 'Successfully deleted scenario record.'
			, ''
    END TRY
    BEGIN CATCH
    	ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'maintain_scenario'
			, 'spa_maintain_scenario'
			, 'DB ERROR'
			, 'Delete scenario record failed.'
			, ''
    END CATCH
END