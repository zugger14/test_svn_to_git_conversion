IF OBJECT_ID(N'[dbo].[spa_maintain_whatif_criteria]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_maintain_whatif_criteria]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 6/28/2012
-- Description: CRUD operations for table time_zone

-- Params:
-- @flag CHAR(1) - Operation flag
-- @criteria_id INT
-- @criteria_name VARCHAR(100)
-- @criteria_description VARCHAR(500)
-- @user VARCHAR(100)
-- @role VARCHAR(100)
-- @scenario_criteria_group INT - static data value
-- @active CHAR(1)
-- @public CHAR(1)
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_maintain_whatif_criteria]
    @flag CHAR(1)
    , @criteria_id INT = NULL
    , @criteria_name VARCHAR(100) = NULL
    , @criteria_description VARCHAR(500) = NULL
    , @user VARCHAR(100) = NULL
    , @role VARCHAR(100) = NULL
    , @scenario_criteria_group INT = NULL
    , @active CHAR(1) = NULL
    , @public CHAR(1) = NULL
    
    -- PARAMS FOR PORTFOLIO TAB
    , @portfolio_group_id INT = NULL
    
    -- PARAMS FOR SCENARIO TAB
    , @scenario_id INT = NULL
    --, @scenario_copy CHAR(1) = NULL
    , @shift_by CHAR(1) = NULL
    , @source VARCHAR(50) = NULL
    , @shift_value NUMERIC(20, 10) = NULL
    , @use_existing_values CHAR(1) = NULL
    
    -- PARAMS FOR MEASURE TAB
    , @MTM CHAR(1) = NULL
    , @position CHAR(1) = NULL
    , @Var  CHAR(1) = NULL
    , @Cfar CHAR(1) = NULL
    , @Ear CHAR(1) = NULL
    , @var_approach INT = NULL
    , @confidence_interval INT = NULL
    , @holding_days INT = NULL
    , @no_of_simulations INT = NULL
    , @PFE CHAR(1) = NULL
    , @tenor_type CHAR(1) = NULL
    , @tenor_from VARCHAR(10) = NULL
    , @tenor_to VARCHAR(10) = NULL    
    , @hold_to_maturity CHAR(1) = NULL  
    , @term_start DATETIME = NULL
    , @term_end DATETIME = NULL
	, @volatility_source int = NULL              
                       
AS

DECLARE @sql VARCHAR(MAX)
		, @max_criteria_id INT 
		, @scenario_name_for_scenario VARCHAR(100)
		, @scenario_name VARCHAR(100)
		
SELECT @scenario_name = ms.scenario_name FROM maintain_scenario ms WHERE ms.scenario_id = @scenario_id

IF @flag = 's'
BEGIN
    --SELECT ALL ROWS FROM THE TABLE
    SELECT mwc.criteria_id AS [ID]
			, mwc.criteria_name AS [Criteria NAME]
			, mwc.criteria_description AS [Criteria Description]
			, mwc.[user] AS [User]
			, mwc.[role] AS [Role]
			, mwc.[active] AS [Active]
			, mwc.[public] AS [Public] 
    FROM maintain_whatif_criteria mwc
END
ELSE IF @flag = 'a'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE
    SELECT
    	mwc.criteria_id,
    	mwc.criteria_name,
    	mwc.criteria_description,
    	mwc.[user],
    	mwc.[role],
    	mwc.scenario_criteria_group,
    	mwc.[active],
    	mwc.[public],
    	
    	mwc.portfolio_group_id,
    	mwc.scenario_group_id,
    	
    	--wcs.scenario_name,
    	--wcs.scenario_copy,
    	--wcs.shift_by,
    	--wcs.shift_value,
    	mwc.[source],
    	--wcs.use_existing_values,
    	wcm.MTM,
    	wcm.position,
    	wcm.[Var],
    	wcm.Cfar,
    	wcm.Ear,
    	wcm.var_approach,
    	wcm.confidence_interval,
    	wcm.holding_days,
    	wcm.no_of_simulations,
    	wcm.PFE,
    	mwc.tenor_type, 
    	mwc.tenor_from, 
    	mwc.tenor_to,
    	mwc.hold_to_maturity,
    	CAST(mwc.term_start AS date) [term_start],
		CAST(mwc.term_end AS date) [term_end],
		mwc.volatility_source
    	
    FROM maintain_whatif_criteria mwc
    INNER JOIN whatif_criteria_measure wcm ON mwc.criteria_id = wcm.criteria_id 
    WHERE mwc.criteria_id = @criteria_id
END
ELSE IF @flag = 'i'
BEGIN
    
    IF EXISTS(	SELECT 1 FROM dbo.maintain_whatif_criteria mwc 
                  	WHERE mwc.criteria_name = @criteria_name
    )
    BEGIN
    	EXEC spa_print 'Criteria Name: ', @criteria_name, ' ALREADY EXISTS.'
		EXEC spa_ErrorHandler -1
			, 'maintain_whatif_criteria'
			, 'spa_maintain_whatif_criteria'
			, 'DB ERROR'
			, 'Criteria name already exists.'
			, ''
    END
    ELSE
	BEGIN TRY
		BEGIN TRAN
		
		IF @scenario_id IS NOT NULL
		BEGIN
			SELECT @source = source FROM maintain_scenario_group WHERE scenario_group_id = @scenario_id
		END
		--INSERT STATEMENT GENERAL TAB
		INSERT INTO maintain_whatif_criteria
		(
			-- criteria_id -- this column value is auto-generated,
			[criteria_name],
			[criteria_description],
			[portfolio_group_id],
			[scenario_group_id],
			[user],
			[role],
			[scenario_criteria_group],
			[active],
			[public],
			tenor_type, 
			tenor_from, 
			tenor_to,
			hold_to_maturity,
			term_start, 
			term_end
		)
		VALUES
		(
			@criteria_name,
			@criteria_description,
			@portfolio_group_id,
			@scenario_id,
			@user,
			@role,
			@scenario_criteria_group,
			@active,
			@public,
			@tenor_type,
			@tenor_from,
			@tenor_to,
			@hold_to_maturity,
			@term_start,
			@term_end
		)
		
		SET @max_criteria_id = SCOPE_IDENTITY()
			
		--INSERT STATEMENT SCENARIO TAB
		--EXEC spa_whatif_criteria_scenario
		--	@flag,
		--	@max_criteria_id,
		--	--@scenario_id,
		--	--@scenario_name_for_scenario,
		--	--@scenario_copy,
		--	@shift_by,
		--	@source,
		--	@shift_value,
		--	@use_existing_values
		
		
		--INSERT STATEMENT MEASURE TAB
		EXEC spa_whatif_criteria_measure
			@flag,
			@max_criteria_id,
			@MTM,
			@position,
			@Var,
			@Cfar,
			@Ear,
			@var_approach,
			@confidence_interval,
			@holding_days,
			@no_of_simulations,
			@PFE
		
		INSERT INTO portfolio_mapping_source
		  (
		    mapping_source_value_id,
		    mapping_source_usage_id,
		    portfolio_group_id
		  )
		VALUES
		  (
		    23201,	-- source whatif (static data value)
		    @max_criteria_id,
		    @portfolio_group_id
		  )
		
		COMMIT
		
		EXEC spa_ErrorHandler 0
			, 'maintain_whatif_criteria'
			, 'spa_maintain_whatif_criteria'
			, 'Success'
			, 'Successfully inserted what-if criteria new record.'
			, @max_criteria_id
	END TRY
	BEGIN CATCH
		ROLLBACK
		---EXEC spa_print ERROR_LINE()
		--EXEC spa_print ERROR_MESSAGE()
		--EXEC spa_print ERROR_NUMBER()
		EXEC spa_ErrorHandler -1
			, 'maintain_whatif_criteria'
			, 'spa_maintain_whatif_criteria'
			, 'DB ERROR'
			, 'Insert what-if criteria new record failed.'
			, ''
	END CATCH
	
END

ELSE IF @flag = 'u'
BEGIN
    --UPDATE STATEMENT GOES HERE
    IF EXISTS(	SELECT 1 FROM dbo.maintain_whatif_criteria mwc 
                  	WHERE mwc.criteria_name = @criteria_name AND mwc.criteria_id != @criteria_id
    )
    BEGIN
    	EXEC spa_print 'Criteria Name: ', @criteria_name, ' ALREADY EXISTS.'
		EXEC spa_ErrorHandler -1
			, 'maintain_whatif_criteria'
			, 'spa_maintain_whatif_criteria'
			, 'DB ERROR'
			, 'Criteria name already exists.'
			, ''
    END
    ELSE
    BEGIN TRY
    	BEGIN TRAN
    	-- UPDATE FOR whatif_criteria_scenario
    	--EXEC spa_whatif_criteria_scenario
    	--	'u',
    	--	@criteria_id ,
    	--	@shift_by,
    	--	@source ,
    	--	@shift_value,
    	--	@use_existing_values
    	
    	-- UPDATE FOR whatif_criteria_measure
    	EXEC spa_whatif_criteria_measure
    		'u',
    		@criteria_id ,
    		@MTM ,
    		@position ,
    		@Var ,
    		@Cfar ,
    		@Ear ,
    		@var_approach,
    		@confidence_interval ,
    		@holding_days ,
    		@no_of_simulations,
    		@PFE
    		
    	-- UPDATE FOR maintain_whatif_criteria
    	IF @scenario_id IS NOT NULL
		BEGIN
			SELECT @source = source FROM maintain_scenario_group WHERE scenario_group_id = @scenario_id
		END
		
    	UPDATE maintain_whatif_criteria
    	SET
    		criteria_name = @criteria_name ,
    		criteria_description = @criteria_description ,
    		portfolio_group_id = @portfolio_group_id,
    		scenario_group_id = @scenario_id,
    		[user] = @user ,
    		[role] = @role ,
    		scenario_criteria_group = @scenario_criteria_group,
    		active = @active,
    		[public] = @public,
    		tenor_type = @tenor_type,
    		tenor_from = @tenor_from,
    		tenor_to = @tenor_to,
    		hold_to_maturity = @hold_to_maturity,
    		[source] = @source,
    		term_start = @term_start,
    		term_end = @term_end,
			volatility_source = @volatility_source
    	WHERE criteria_id = @criteria_id
    	
    	-- if data on portfolio_mapping_source does not exist then insert else update
		IF NOT EXISTS(SELECT 1 FROM portfolio_mapping_source pms 
		              WHERE mapping_source_value_id = 23201 AND mapping_source_usage_id = @criteria_id
		)
		BEGIN
			INSERT INTO portfolio_mapping_source
			(
				mapping_source_value_id,
				mapping_source_usage_id,
				portfolio_group_id
			)
			VALUES
			(
				23201,-- source limit (static data value)
				@criteria_id,
				@portfolio_group_id
			)
		END
		ELSE
		BEGIN
			UPDATE portfolio_mapping_source
			SET portfolio_group_id = @portfolio_group_id
			WHERE mapping_source_value_id = 23201 AND mapping_source_usage_id = @criteria_id
		END
    		
    	COMMIT
		
		EXEC spa_ErrorHandler 0
			, 'maintain_whatif_criteria'
			, 'spa_maintain_whatif_criteria'
			, 'Success'
			, 'Successfully updated what-if criteria record.'
			, @criteria_id
    END TRY
    BEGIN CATCH
    	ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'maintain_whatif_criteria'
			, 'spa_maintain_whatif_criteria'
			, 'DB ERROR'
			, 'Update what-if criteria record failed.'
			, ''
    END CATCH
END
ELSE IF @flag = 'd'
BEGIN
    --DELETE STATEMENT GOES HERE
    BEGIN TRY
    	BEGIN TRAN
    	-- DELETE FROM whatif_criteria_measure
    	DELETE FROM whatif_criteria_measure
    	WHERE criteria_id = @criteria_id
    	
    	-- DELETE FROM whatif_criteria_scenario
    	DELETE FROM whatif_criteria_scenario
    	WHERE criteria_id = @criteria_id
    	
    	-- DELTE FROM whatif_criteria_deal
    	DELETE FROM whatif_criteria_deal
    	WHERE criteria_id = @criteria_id
    	
    	-- DELETE FROM whatif_criteria_book
    	DELETE FROM whatif_criteria_book
    	WHERE criteria_id = @criteria_id
    	
    	-- DELETE FROM whatif_criteria_other
    	DELETE FROM whatif_criteria_other
    	WHERE criteria_id = @criteria_id
    	
    	--DELETE FROM maintain_whatif_criteria
    	DELETE FROM maintain_whatif_criteria
    	WHERE criteria_id = @criteria_id
    	
    	EXEC spa_ErrorHandler 0
			, 'maintain_whatif_criteria'
			, 'spa_maintain_whatif_criteria'
			, 'Success'
			, 'Successfully deleted what-if criteria record.'
			, ''
    	
    	COMMIT
    END TRY
    BEGIN CATCH
    	ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'maintain_whatif_criteria'
			, 'spa_maintain_whatif_criteria'
			, 'DB ERROR'
			, 'Delete what-if criteria record failed.'
			, ''
    END CATCH
END
ELSE IF @flag = 'g'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE FOR GRID DISPLAY AND REPORT
	SET @sql = 'SELECT	mwc.criteria_id AS [ID]
						, dbo.FNAHyperlinkText(10183410, mwc.criteria_name, mwc.criteria_id) AS [Criteria Name]
						, mwc.criteria_description AS [Criteria Description]
						, sdv.code as [What-If Criteria Group]
						, mwc.[user] AS [User]
						, asr.role_name AS [Role]
						, CASE WHEN mwc.[active] = ''y'' THEN ''Yes'' ELSE ''No'' END [Active]
						, CASE WHEN mwc.[public] = ''y'' THEN ''Yes'' ELSE ''No'' END [Public]
				FROM maintain_whatif_criteria mwc
				LEFT JOIN dbo.static_data_value sdv ON mwc.scenario_criteria_group = sdv.value_id
				LEFT JOIN dbo.application_security_role asr ON mwc.[role] = asr.role_id 
				WHERE mwc.[active] = ''' + @active + ''' AND mwc.[public] = ''' + @public + ''''
	IF (@user IS NOT NULL)
		SET @sql += ' AND mwc.[user] = ''' + @user + ''''          
	IF (@role IS NOT NULL)
		SET @sql += ' AND mwc.[role] = ''' + @role + ''''
	IF (@scenario_criteria_group IS NOT NULL)
		SET @sql += ' AND mwc.[scenario_criteria_group] = ''' + CAST(@scenario_criteria_group AS VARCHAR(50)) + ''''
	EXEC(@sql)
END
ELSE IF @flag = 'm'
BEGIN
	-- SELECT MAX CRITERIA ID FROM TABLE
	SELECT criteria_id FROM maintain_whatif_criteria
	WHERE criteria_name = @criteria_name
END