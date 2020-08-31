IF OBJECT_ID(N'[dbo].[spa_whatif_criteria_scenario]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_whatif_criteria_scenario]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_whatif_criteria_scenario]
    @flag CHAR(1)
    , @criteria_id INT 
    , @whatif_criteria_scenario_id INT = NULL
    , @scenario_name VARCHAR(100) = NULL
    , @scenario_description VARCHAR(100) = NULL
    , @shift_by CHAR(1) = NULL
    , @shift_value NUMERIC(20, 10) = NULL
    , @source VARCHAR(100) = NULL
    , @use_existing_values CHAR(1) = NULL
    , @shift VARCHAR(100) = NULL 
    , @shift_item VARCHAR(100) = NULL 
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 'i'
BEGIN
	--INSERT STATEMENT GOES HERE
	IF NOT EXISTS(	SELECT 1 FROM dbo.whatif_criteria_scenario 
					WHERE [scenario_name] = @scenario_name
					)
		IF NOT EXISTS( SELECT 1 FROM dbo.whatif_criteria_scenario	
		               WHERE [shift_group] = @shift AND [shift_item] = @shift_item AND criteria_id = @criteria_id)
		BEGIN TRY
			IF @shift IS NULL 
			BEGIN
				IF EXISTS (SELECT 1 FROM whatif_criteria_scenario WHERE shift_group IS NULL AND criteria_id = @criteria_id)
				BEGIN
					EXEC spa_ErrorHandler -1
					, 'whatif_criteria_scenario'
					, 'spa_whatif_criteria_scenario'
					, 'DB ERROR'
					, 'This combination of shift and shift item already exists.'
					, ''
					
					RETURN	
				END
			END
			
			INSERT INTO dbo.whatif_criteria_scenario
			(	[criteria_id]
				, [scenario_name]
				, [scenario_description]
				, [shift_by]
				, [shift_value]
				, [source]
				, [use_existing_values]
				, [shift_group]
				, [shift_item]
			) 
			VALUES 
			(	@criteria_id 
				, @scenario_name
				, @scenario_description
				, @shift_by
				, @shift_value
				, @source
				, @use_existing_values
				, @shift
				, @shift_item
				
			)
			
			EXEC spa_ErrorHandler 0
				, 'whatif_criteria_scenario'
				, 'spa_whatif_criteria_scenario'
				, 'Success'
				, 'Successfully inserted scenario new record.'
				, ''
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler -1
				, 'whatif_criteria_scenario'
				, 'spa_whatif_criteria_scenario'
				, 'DB ERROR'
				, 'Insert scenario new record failed.'
				, ''
		END CATCH
		ELSE 
		BEGIN
			EXEC spa_ErrorHandler -1
			, 'whatif_criteria_scenario'
			, 'spa_whatif_criteria_scenario'
			, 'DB ERROR'
			, 'This combination of shift and shift item already exists.'
			, ''
		END
	ELSE
	BEGIN
		EXEC spa_print 'Scenario Name: ', @scenario_name, ' ALREADY EXISTS.'
		EXEC spa_ErrorHandler -1
			, 'whatif_criteria_scenario'
			, 'spa_whatif_criteria_scenario'
			, 'DB ERROR'
			, 'Scenario name already exists.'
			, ''
	END
END
ELSE IF @flag = 'u'
BEGIN
    --UPDATE STATEMENT GOES HERE
    IF NOT EXISTS(	SELECT 1 FROM dbo.whatif_criteria_scenario 
					WHERE [scenario_name] = @scenario_name AND whatif_criteria_scenario_id != @whatif_criteria_scenario_id
    )
		IF NOT EXISTS( SELECT 1 FROM dbo.whatif_criteria_scenario	
						   WHERE [shift_group] = @shift AND [shift_item] = @shift_item AND criteria_id = @criteria_id
						AND whatif_criteria_scenario_id != @whatif_criteria_scenario_id)
		BEGIN TRY
		EXEC spa_print '1'
			IF @shift IS NULL 
			BEGIN
				IF EXISTS (SELECT * FROM whatif_criteria_scenario WHERE shift_group IS NULL AND criteria_id = @criteria_id AND whatif_criteria_scenario_id != @whatif_criteria_scenario_id)
				BEGIN
					EXEC spa_ErrorHandler -1
					, 'whatif_criteria_scenario'
					, 'spa_whatif_criteria_scenario'
					, 'DB ERROR'
					, 'This combination of shift and shift item already exists.'
					, ''
					
					RETURN
				END	
			END
			BEGIN TRAN
				UPDATE  wcs
				SET		wcs.scenario_name = @scenario_name 
						, wcs.scenario_description = @scenario_description
						, wcs.shift_by = @shift_by
						, wcs.shift_value = @shift_value 
						, wcs.[source] = @source
						, wcs.use_existing_values = @use_existing_values
						, wcs.shift_group = @shift
						, wcs.shift_item = @shift_item
						  
				FROM whatif_criteria_scenario wcs 
				WHERE wcs.[whatif_criteria_scenario_id] = @whatif_criteria_scenario_id
			COMMIT
			EXEC spa_ErrorHandler 0
				, 'whatif_criteria_scenario'
				, 'spa_whatif_criteria_scenario'
				, 'Success'
				, 'Successfully updated scenario record.'
				, ''
		END TRY
		BEGIN CATCH
			ROLLBACK
			EXEC spa_ErrorHandler -1
				, 'whatif_criteria_scenario'
				, 'spa_whatif_criteria_scenario'
				, 'DB ERROR'
				, 'Update scenario record failed.'
				, ''
		END CATCH
		ELSE 
		BEGIN
			EXEC spa_ErrorHandler -1
			, 'whatif_criteria_scenario'
			, 'spa_whatif_criteria_scenario'
			, 'DB ERROR'
			, 'This combination of shift and shift item already exists.'
			, ''
		END
	ELSE
	BEGIN
		EXEC spa_print 'Scenario Name: ', @scenario_name, ' ALREADY EXISTS.'
		EXEC spa_ErrorHandler -1
			, 'whatif_criteria_scenario'
			, 'spa_whatif_criteria_scenario'
			, 'DB ERROR'
			, 'Scenario name already exists.'
			, ''
	END
END
ELSE IF @flag = 'd'
BEGIN
    --DELETE STATEMENT GOES HERE
    BEGIN TRY
		BEGIN TRAN
    		DELETE FROM whatif_criteria_scenario
    		WHERE whatif_criteria_scenario_id = @whatif_criteria_scenario_id
    	COMMIT
		EXEC spa_ErrorHandler 0
			, 'whatif_criteria_scenario'
			, 'spa_whatif_criteria_scenario'
			, 'Success'
			, 'Successfully deleted scenario record.'
			, ''
    END TRY
    BEGIN CATCH
    	ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'whatif_criteria_scenario'
			, 'spa_whatif_criteria_scenario'
			, 'DB ERROR'
			, 'Delete scenario record failed.'
			, ''
    END CATCH
END
ELSE IF @flag = 'a'
BEGIN
	SET @sql = 'SELECT	wcs.whatif_criteria_scenario_id
						, wcs.scenario_name AS [Scenario Name]
						, wcs.scenario_description AS [Scenario Description]
						, wcs.shift_by AS [Shift By]
						, dbo.FNARemoveTrailingZero(wcs.shift_value) AS [Shift Value]
						, wcs.[source] AS [Source]
						, wcs.use_existing_values AS [Use Existing Values]
						, wcs.shift_group AS [Shift]
						, wcs.shift_item AS [Shift Item]
				FROM whatif_criteria_scenario wcs 
				WHERE wcs.[whatif_criteria_scenario_id] = ' + CAST(@whatif_criteria_scenario_id AS VARCHAR(10))
	EXEC(@sql)
END
ELSE IF @flag = 'g'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE FOR GRID DISPLAY AND REPORT
	SET @sql = 'SELECT	wcs.whatif_criteria_scenario_id AS [ID]
						, dbo.FNAHyperlinkText3(10183415, wcs.scenario_name, wcs.whatif_criteria_scenario_id,' +  CAST(@criteria_id AS VARCHAR(10)) + ') AS [Scenario Name]
						, wcs.scenario_description AS [Scenario Description]
						, sdv.code AS [Shift]
						, CASE 
							WHEN wcs.shift_group = 24003
								THEN sc.commodity_name
							WHEN wcs.shift_group = 24002
								THEN sdv1.code
							WHEN wcs.shift_group = 24001
								THEN spcd.curve_name
							END  [Shift Item]
						, CASE WHEN wcs.shift_by = ''y'' THEN ''Yes'' ELSE ''No'' END [Shift By]
						, dbo.FNARemoveTrailingZero(wcs.shift_value) AS [Shift Value]
						, CASE WHEN wcs.use_existing_values = ''y'' THEN ''Yes'' ELSE ''No'' END [Use Existing Values]
				FROM whatif_criteria_scenario wcs	
				LEFT JOIN static_data_value sdv2 ON sdv2.value_id = wcs.source
				LEFT JOIN static_data_value sdv1 ON sdv1.value_id = wcs.shift_item
				LEFT JOIN static_data_value sdv ON sdv.value_id = wcs.shift_group
				LEFT JOIN source_commodity sc ON wcs.shift_item = sc.source_commodity_id
				LEFT JOIN source_price_curve_def spcd ON wcs.shift_item = spcd.source_curve_def_id
				WHERE wcs.[criteria_id] = ' + CAST(@criteria_id AS VARCHAR(10)) + ''
				
	EXEC(@sql)
END