
IF OBJECT_ID(N'[dbo].[spa_transportation_contract_capacity]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_transportation_contract_capacity]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_transportation_contract_capacity]
@flag CHAR(1),
@id INT = NULL,
@contract_id INT = NULL,
@effective_date DATETIME = NULL,
@field_id INT = NULL,
@value FLOAT = NULL,
@uom_id INT = NULL

AS

DECLARE @sql VARCHAR(8000)

IF @flag = 's' 
BEGIN
	SET @sql = 
		'SELECT tcc.id [ID],
		       tcc.contract_id [Contract ID],
		       dbo.FNADateFormat(tcc.effective_date) [Effective Date],
		       sdv.code [Field Name],
		       tcc.value [Value],
		       su.uom_desc [UOM]
		FROM   transportation_contract_capacity tcc
		INNER JOIN static_data_value sdv ON tcc.field_id = sdv.value_id
		INNER JOIN source_uom su ON tcc.uom_id = su.source_uom_id 
		WHERE tcc.contract_id = ' + CAST(@contract_id AS VARCHAR(100)) + 'AND 1 = 1 '
		
	IF @effective_date IS NOT NULL
	BEGIN
		SET @sql = @sql + 'AND tcc.effective_date = ' + dbo.FNASingleQuote(@effective_date)
	END
	
	IF @field_id IS NOT NULL
	BEGIN
		SET @sql = @sql + 'AND tcc.field_id = ' + CAST(@field_id AS VARCHAR(100))
	END
	
	EXEC(@sql)
END

ELSE IF @flag = 'a'
BEGIN
	SELECT tcc.id,
		       tcc.contract_id,
		       dbo.FNADateFormat(tcc.effective_date),
		       tcc.field_id ,
		       tcc.value ,
		       tcc.uom_id 
	FROM transportation_contract_capacity tcc
		WHERE tcc.id = @id

	EXEC(@sql)
END

ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		
		INSERT INTO transportation_contract_capacity
		(
			contract_id,
			effective_date,
			field_id,
			[value],
			uom_id	
		) VALUES
		(
			@contract_id,
			@effective_date,
			@field_id,
			@value,
			@uom_id 
		)
	
		EXEC spa_ErrorHandler 0,
			 'transportation_contract_capacity',
			 'spa_transportation_contract_capacity',
			 'Success',
			 'Transportation Contract Capacity successfully inserted.',
			 ''
	END TRY 
    BEGIN CATCH 
		DECLARE @err_no3 INT
		SELECT @err_no3 = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no3,
			 'transportation_contract_capacity',
			 'spa_transportation_contract_capacity',
			 'DB Error',
			 'Error on inserting Transportation Contract Capacity.',
			 ''	
	END CATCH	
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		UPDATE transportation_contract_capacity
		SET    effective_date = @effective_date,
			   field_id = @field_id,
			   [value] = @value,
			   uom_id = @uom_id
		WHERE  id = @id
	    
	    EXEC spa_ErrorHandler 0,
				 'transportation_contract_capacity',
				 'spa_transportation_contract_capacity',
				 'Success',
				 'Transportation Contract Capacity successfully updated.',
				 '' 
	       
	END TRY	
	BEGIN CATCH
		IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR,
			 'transportation_contract_capacity',
			 'spa_transportation_contract_capacity',
			 'DB Error',
			 'Error on updating Transportation Contract Capacity.',
			 ''
	END CATCH		
	
END

ELSE IF @flag = 'd'
BEGIN
	DELETE 
	FROM   transportation_contract_capacity
	WHERE  id = @id
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'transportation_contract_capacity',
	         'spa_transportation_contract_capacity',
	         'DB Error',
	         'Error on deleting Transportation Contract Capacity.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'transportation_contract_capacity',
	         'spa_transportation_contract_capacity',
	         'Success',
	         'Transportation Contract Capacity successfully deleted.',
	         ''
END
 