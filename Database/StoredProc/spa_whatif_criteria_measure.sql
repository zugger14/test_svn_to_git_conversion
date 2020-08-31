IF OBJECT_ID(N'[dbo].[spa_whatif_criteria_measure]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_whatif_criteria_measure]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 7/3/2012
-- Description: CRUD operations for table time_zone

-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_whatif_criteria_measure]
    @flag CHAR(1)
    , @criteria_id INT = NULL
    , @MTM CHAR(1) = NULL
    , @position CHAR(1) = NULL
    , @Var  CHAR(1) = NULL
    , @Cfar CHAR(1) = NULL
    , @Ear  CHAR(1) = NULL
    , @var_approach INT = NULL
    , @confidence_interval INT = NULL
    , @holding_days  INT = NULL
    , @no_of_simulations INT = NULL
    , @PFE CHAR(1) = NULL
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
    --SELECT ALL ROWS FROM THE TABLE
    EXEC spa_print 's'
END
ELSE IF @flag = 'a'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE
    EXEC spa_print 'a'
END
ELSE IF @flag = 'i'
BEGIN
    --INSERT STATEMENT GOES HERE
    BEGIN TRY
    	INSERT INTO whatif_criteria_measure
    	(
    		criteria_id,
    		MTM,
    		position,
    		[Var],
    		Cfar,
    		Ear,
    		var_approach,
    		confidence_interval,
    		holding_days,
    		no_of_simulations,
    		PFE
    	)
    	VALUES
    	(
    		@criteria_id,
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
    	)
    
    END TRY
    BEGIN CATCH
    	EXEC spa_ErrorHandler -1
			, 'whatif_criteria_measure'
			, 'spa_whatif_criteria_measure'
			, 'DB ERROR'
			, 'Insert what-if criteria measure new record failed.'
			, ''
    END CATCH
END

ELSE IF @flag = 'u'
BEGIN
    --UPDATE STATEMENT GOES HERE
    BEGIN TRY
    	UPDATE whatif_criteria_measure
    	SET
    		MTM = @MTM,
    		position = @position,
    		[Var] = @Var,
    		Cfar = @Cfar,
    		Ear = @Ear,
    		var_approach = @var_approach,
    		confidence_interval = @confidence_interval,
    		holding_days = @holding_days,
    		no_of_simulations = @no_of_simulations,
    		PFE = @PFE
    	WHERE criteria_id = @criteria_id
    END TRY
    BEGIN CATCH
    	ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'whatif_criteria_measure'
			, 'spa_whatif_criteria_measure'
			, 'DB ERROR'
			, 'Update what-if criteria measure record failed.'
			, ''
    END CATCH
END
ELSE IF @flag = 'd'
BEGIN
    --DELETE STATEMENT GOES HERE
    BEGIN TRY
    	DELETE FROM whatif_criteria_measure
    	WHERE criteria_id = @criteria_id
    	
    	EXEC spa_ErrorHandler 0
			, 'whatif_criteria_measure'
			, 'spa_whatif_criteria_measure'
			, 'Success'
			, 'Successfully deleted what-if criteria measure record.'
			, ''
    END TRY
    BEGIN CATCH
    	ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'whatif_criteria_measure'
			, 'spa_whatif_criteria_measure'
			, 'DB ERROR'
			, 'Delete what-if criteria measure record failed.'
			, ''
    END CATCH
END