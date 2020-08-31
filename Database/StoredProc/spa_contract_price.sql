IF OBJECT_ID(N'[dbo].[spa_contract_price]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_contract_price]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: bbishural@pioneersolutionsglobal.com
-- Create date: 2012-08-23
-- Description: CRUD operations for table source_price_curve_def
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @source_curve_def_id - INT - integer value for the source contract price
-- @source_system_id - INT - Source system Id
-- @curve_id - VARCHAR - Curve Id
-- @curve_name - VARCHAR - Curve Name
-- @description - VARCHAR - Curve Description
-- @curve_type_value_id - Curve type value Id
-- @source_currency_id - INT - source currency Id  
-- @market_value_id - market_value_desc
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_contract_price]
    @flag VARCHAR(5) = NULL,
    @source_curve_def_id INT = NULL,
    @source_system_id INT = NULL,
    @curve_id VARCHAR(500) = NULL,
    @curve_name VARCHAR(500) = NULL,
    @description VARCHAR(500) = NULL,
    @curve_type_value_id INT = NULL,
    @source_currency_id INT = NULL,
    @commodity_id INT = NULL,
    @uom_id INT = NULL,
    @granularity INT = NULL,
    @contract_id INT = NULL,
    @index_group VARCHAR(100) = NULL    
AS
SET NOCOUNT ON
DECLARE @desc    VARCHAR(500)
DECLARE @sql     VARCHAR(MAX)
DECLARE @err_no  INT

IF @flag = 's' 
BEGIN
	SET @sql = 'SELECT source_curve_def_id AS [ID], 
					   curve_id AS [Curve ID],
					   curve_name AS [Curve Name], 
					   curve_des AS [Description]
	            FROM source_price_curve_def 
			    WHERE source_curve_type_value_id = 583 AND contract_id IS NULL '
	            IF(@curve_name IS NOT NULL OR @curve_name = '')
					SET @sql = @sql + 'AND curve_name like ''%' + @curve_name + '%'''
	--PRINT(@sql)
	EXEC(@sql)            
END
IF @flag = 'x' --for displaying the data in the privileges tab grid in the setup contract price menu.
BEGIN
	 SET @sql = 'SELECT source_curve_def_id AS [ID], 
					    curve_id AS [Curve ID],
					    curve_name AS [Curve Name], 
					    curve_des AS [Description]
	             FROM source_price_curve_def
	             WHERE contract_id IS NULL'
	 --PRINT(@sql)
	 EXEC(@sql)
END
ELSE IF @flag = 'i' 
BEGIN
	BEGIN TRY
	IF EXISTS(SELECT 'X' FROM [dbo].[source_price_curve_def] WHERE curve_id = @curve_id)
	BEGIN 
		EXEC spa_ErrorHandler -1,
		     'source_price_curve_def',
		     'spa_contract_price',
		     'DB Error',
		     'Cannot insert the duplicate curve Id value',
		     ''
	END
	ELSE
	BEGIN
		INSERT INTO source_price_curve_def (
			source_system_id,
			curve_id,
			curve_name,
			curve_des,
			source_curve_type_value_id,
			source_currency_id,
			uom_id,
			commodity_id,
			market_value_id,
			granularity,
			contract_id,
			is_active,
			index_group
		)
		VALUES (
			@source_system_id,
			@curve_id,
			@curve_name,
			@description,
			@curve_type_value_id,
			@source_currency_id,
			@uom_id,
			@commodity_id,
			@curve_id,
			@granularity,
			@contract_id,
			'y',
			@index_group
		)
		DECLARE @system_source_id INT
		SELECT  @system_source_id = SCOPE_IDENTITY();
		
		EXEC spa_ErrorHandler 0,
		     'source_price_curve_def',
		     'spa_contract_price',
		     'Success',
		     'Data saved successfully.',
		     @system_source_id		
	END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		    ROLLBACK
		
		IF ERROR_MESSAGE() = 'CatchError'
		    SET @desc = 'Fail to insert Data ( Errr Description:' + @desc + ').'
		ELSE
		    SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
		
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
		     'source_price_curve_def',
		     'spa_contract_price',
		     'Error',
		     @desc,
		     ''
	END CATCH	 
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		UPDATE source_price_curve_def 
		SET source_system_id = @source_system_id,
			curve_id = @curve_id,
			curve_name = @curve_name,
			curve_des = @description,
			source_curve_type_value_id = @curve_type_value_id,
			source_currency_id = @source_currency_id,
			commodity_id = @commodity_id,
			uom_id = @uom_id,
			market_value_id = @curve_id,
			granularity = @granularity,
			index_group = @index_group
		WHERE source_curve_def_id = @source_curve_def_id
		
		EXEC spa_ErrorHandler 0,
				 'source_price_curve_def',
				 'spa_contract_price',
				 'Success',
				 'Data updated successfully.',
				 ''	
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
				ROLLBACK
			
			IF ERROR_MESSAGE() = 'CatchError'
				SET @desc = 'Fail to update Data ( Errr Description:' + @desc + ').'
			ELSE
				SET @desc = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'
			
			SELECT @err_no = ERROR_NUMBER()
			
			EXEC spa_ErrorHandler @err_no,
				 'source_price_curve_def',
				 'spa_contract_price',
				 'Error',
				 @desc,
				 ''
	END CATCH
END

ELSE IF @flag = 'a'
BEGIN
	SELECT source_system_id,
		   curve_id,
		   curve_name,
		   curve_des,
		   source_curve_type_value_id,
		   source_currency_id,
		   uom_id,
		   commodity_id,
		   Granularity,index_group
	FROM source_price_curve_def
	WHERE source_curve_def_id = @source_curve_def_id
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE FROM source_price_curve_def WHERE source_curve_def_id = @source_curve_def_id
		EXEC spa_ErrorHandler 0,
		     'source_price_curve_def',
		     'spa_contract_price',
		     'Success',
		     'Successfully deleted data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		    ROLLBACK
		
		IF ERROR_MESSAGE() = 'CatchError'
		    SET @desc = 'Fail to delete Data ( Errr Description:' + @desc + ').'
		ELSE
		    SET @desc = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'
		
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
		     'source_price_curve_def',
		     'spa_contract_price',
		     'Error',
		     @desc,
		     ''
	END CATCH
END
ELSE IF @flag = 'c' -- call from contract detail page
BEGIN
	SELECT spcd.curve_name AS [Curve Name],
		   spcd.source_currency_id AS [source_currency_id],
	     --  spcd.curve_des AS [Description],
	       spcd.uom_id AS [Uom Id],
	       spcd.Granularity AS [Granularity],
		   spcd.contract_id AS [Contract Id],
		   spcd.commodity_id AS [Commodity Id],
		   spcd.curve_id AS [Curve ID],
		   spcd.market_value_id AS [Market Value Id],
		   spcd.source_curve_type_value_id AS [Sourcce Curve Type Value Id],
		   spcd.source_curve_def_id AS [source_curve_def_id]
	FROM   source_price_curve_def spcd
	WHERE spcd.contract_id = @contract_id
END