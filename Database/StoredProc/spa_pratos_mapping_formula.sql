IF OBJECT_ID(N'[dbo].[spa_pratos_mapping_formula]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_pratos_mapping_formula]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: dmanandhar@pioneersolutionsglobal.com
-- Create date: 2011-09-14
-- Description: Pratos Mapping for formula

-- Params:
--	@flag CHAR(1) - Operation flag
-- ===========================================================================================================


CREATE PROCEDURE [dbo].[spa_pratos_mapping_formula]
    @flag CHAR(1),
    @pratos_formula_mapping_id INT = NULL,
    @source_formula_mapping_id varchar(500) = NULL,
    @curve_id INT = NULL,
    @relative_year INT = NULL,
    @strip_month_from INT = NULL,
    @lag_month INT = NULL,
    @strip_month_to INT = NULL,
    @currency_id INT = NULL,
    @price_adder FLOAT = NULL,
    @exp_type VARCHAR(20) = NULL,
    @exp_value VARCHAR(40) = NULL,
    @curve_type VARCHAR(100) = NULL
       
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	SELECT 
	   pfm.id AS [ID],
	   pfm.source_formula AS [Formula],       
       spcd.curve_name AS [Price Curve],
       pfm.relative_year AS [Relative Year],
       pfm.strip_month_from AS [Strip Month From],
       pfm.lag_month AS [Lag Month], 
       pfm.strip_month_to AS [Strip Month To],
       sc.currency_name AS [Currency],
       pfm.price_adder AS [Price Adder],
       pfm.exp_type AS [Expiration Type],
       pfm.exp_value AS [Expiration Value],
       pfm.curve_type AS [Curve Type]       
	FROM   pratos_formula_mapping pfm
       left JOIN source_price_curve_def spcd
            ON  pfm.curve_id = spcd.source_curve_def_id
	   left JOIN source_currency sc
			ON pfm.currency_id = sc.source_currency_id  
END
ELSE IF @flag = 'a'
BEGIN
	SELECT
		pfm.id AS [ID],
		pfm.source_formula AS [Formula],
		spcd.curve_name AS [Price Curve],
		pfm.relative_year AS [Relative Year],
		pfm.strip_month_from AS [Strip Month From],
		pfm.lag_month AS [Lag Month],
		pfm.strip_month_to AS [Strip Month To],
		sc.currency_name AS [Currency],
		pfm.price_adder AS [Price Adder],
		pfm.exp_type AS [Expiration Type],
		pfm.exp_value AS [Expiration Value],
		pfm.curve_type AS [Curve Type],
		pfm.curve_id as [Curve ID]       
	FROM   pratos_formula_mapping pfm
       left JOIN source_price_curve_def spcd
            ON  pfm.curve_id = spcd.source_curve_def_id
	   left JOIN source_currency sc
			ON pfm.currency_id = sc.source_currency_id 
	WHERE pfm.id = @pratos_formula_mapping_id  
    
END


ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
		INSERT INTO pratos_formula_mapping
	(
		source_formula,
		curve_id,
		relative_year,
		strip_month_from,		
		lag_month,
		strip_month_to,
		currency_id,
		price_adder,
		exp_type,
		exp_value,
		curve_type
	)
	VALUES
	(
		@source_formula_mapping_id,
		@curve_id,
		@relative_year,
		@strip_month_from,
		@lag_month,
		@strip_month_to,
		@currency_id,
		@price_adder,
		@exp_type,
		@exp_value,
		@curve_type	
	)
		COMMIT 
		
		DECLARE @last_id INT 
		SELECT @last_id = SCOPE_IDENTITY()
		EXEC spa_ErrorHandler 0
			, 'pratos_formula_mapping table'--tablename
			, 'spa_pratos_mapping_formula'--sp
			, 'Success'--error type
			, 'Data insert successful Data.'
			, @last_id --personal msg
	END TRY
	BEGIN CATCH
		DECLARE @error VARCHAR(5000)
		SET @error = ERROR_MESSAGE()
		EXEC spa_ErrorHandler -1
			, 'pratos_formula_mapping table'--tablename
			, 'spa_pratos_mapping_formula'--sp
			, 'DB Error'--error type
			, 'Failed inserting Data.'
			, @error --personal msg
			
		ROLLBACK 		
	END CATCH
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
	UPDATE pratos_formula_mapping
	SET		
		source_formula = @source_formula_mapping_id,
		curve_id = @curve_id,
		relative_year = @relative_year,
		strip_month_from = @strip_month_from,
		lag_month = @lag_month,
		strip_month_to = @strip_month_to,
		currency_id = @currency_id,
		price_adder = @price_adder,
		exp_type = @exp_type,
		exp_value = @exp_value,
		curve_type = @curve_type
	WHERE 
		id = @pratos_formula_mapping_id
	COMMIT 
		EXEC spa_ErrorHandler 0
			, 'pratos_formula_mapping table'--tablename
			, 'spa_pratos_mapping_formula'--sp
			, 'Success'--error type
			, 'Data insert successful Data.'
			, @pratos_formula_mapping_id --personal msg
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE()
		EXEC spa_ErrorHandler -1
			, 'pratos_formula_mapping table'--tablename
			, 'spa_pratos_mapping_formula'--sp
			, 'DB Error'--error type
			, 'Failed Updating Data.'
			, @error --personal msg
			
		ROLLBACK 
	END CATCH

END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
			DELETE FROM pratos_formula_mapping WHERE id = @pratos_formula_mapping_id
		
		COMMIT 
		
		EXEC spa_ErrorHandler 0
			, 'pratos_formula_mapping table'--tablename
			, 'spa_pratos_mapping_formula'--sp
			, 'DB Error'--error type
			, 'Data Deleted Successfully.'
			, 'Data Deleted successfully.' --personal msg
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'pratos_formula_mapping table'--tablename
			, 'spa_pratos_mapping_formula'--sp
			, 'DB Error'--error type
			, 'The selected data cannot be deleted.'
			, 'Cannot Delete Data.' --personal msg 
			
		ROLLBACK 
	END CATCH	
	
END 

