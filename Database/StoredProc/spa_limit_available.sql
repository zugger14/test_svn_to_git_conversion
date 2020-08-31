/*
* sligal
* sp for table limit_available
* date: 11/22/2012
* purpose: insert, update, delete, select operation for table.
* params:
	@flag char(1) : Operation flag
	
*/

IF OBJECT_ID(N'[dbo].[spa_limit_available]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_limit_available]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_limit_available]
    @flag				CHAR(1),
    @limit_available_id	INT = NULL,
    @limit_id			INT = NULL,
	@counterparty_id	INT = NULL,
	@effective_date		DATETIME = NULL,
	@limit_type			INT = NULL,
	@limit_available	FLOAT = NULL,
	@currency			INT = NULL,
	@comment			VARCHAR(500) = NULL

AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
    --SELECT ALL ROWS FROM THE TABLE
    --SET @SQL = 'SELECT la.limit_available_id AS [ID],
				--	   la.limit_id AS [Limit ID],
				--	   sc.counterparty_name AS [Counterparty],
				--	   dbo.FNADateFormat(la.effective_date) AS [Effective Date],
				--	   sdv.code AS [Limit Type],
				--	   la.limit_available AS [Limit Available],
				--	   sc2.currency_name AS [Currency],
				--	   la.comment AS [Comment]
				--FROM   limit_available la
				--LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = la.counterparty_id
				--LEFT JOIN static_data_value sdv ON sdv.value_id = la.limit_type
				--LEFT JOIN source_currency sc2 ON sc2.source_currency_id = la.currency
				--WHERE 1 = 1 '
    
    IF @limit_id IS NOT NULL
		SET @SQL = 'SELECT la.limit_available_id AS [ID],
						   la.limit_id AS [Limit ID],
						   --sc.counterparty_name AS [Counterparty],
						   dbo.FNADateFormat(la.effective_date) AS [Effective Date],
						   sdv.code AS [Limit Type],
						   la.limit_available AS [Limit Available],
						   sc2.currency_name AS [Currency],
						   la.comment AS [Comment]
					FROM   limit_available la
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = la.counterparty_id
					LEFT JOIN static_data_value sdv ON sdv.value_id = la.limit_type
					LEFT JOIN source_currency sc2 ON sc2.source_currency_id = la.currency
					WHERE 1 = 1
					AND la.limit_id = ' + CAST(@limit_id AS VARCHAR(10))
	ELSE IF @counterparty_id IS NOT NULL
		SET @SQL = 'SELECT la.limit_available_id AS [ID],
						   --la.limit_id AS [Limit ID],
						   sc.counterparty_name AS [Counterparty],
						   dbo.FNADateFormat(la.effective_date) AS [Effective Date],
						   sdv.code AS [Limit Type],
						   la.limit_available AS [Limit Available],
						   sc2.currency_name AS [Currency],
						   la.comment AS [Comment]
					FROM   limit_available la
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = la.counterparty_id
					LEFT JOIN static_data_value sdv ON sdv.value_id = la.limit_type
					LEFT JOIN source_currency sc2 ON sc2.source_currency_id = la.currency
					WHERE 1 = 1
					AND la.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(10))
	
	EXEC(@SQL)
    
END
ELSE IF @flag = 'a'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE
    SELECT la.limit_available_id, la.limit_id, la.counterparty_id,
           dbo.FNADateFormat(la.effective_date), la.limit_type, la.limit_available, la.currency,
           la.comment
    FROM limit_available la
    WHERE la.limit_available_id = @limit_available_id
END
ELSE IF @flag = 'i'
BEGIN
    --INSERT STATEMENT GOES HERE
    IF NOT EXISTS (SELECT 1 FROM limit_available lh WHERE 1 = 2)
    BEGIN
    	BEGIN TRY
    		INSERT INTO limit_available
			(
    			-- limit_available_id -- this column value is auto-generated,
    			limit_id,
    			counterparty_id,
    			effective_date,
    			limit_type,
    			limit_available,
    			currency,
    			comment
			)
			VALUES
			(
    			@limit_id,
    			@counterparty_id,
    			@effective_date,
    			@limit_type,
    			@limit_available,
    			@currency,
    			@comment
			)
			
			DECLARE @new_id INT
			SET @new_id = SCOPE_IDENTITY()
			
			EXEC spa_ErrorHandler 0, 'Limit Available', 
				'spa_limit_available', 'Success', 
				'Data inserted successfully.',@new_id
    	END TRY
    	BEGIN CATCH
    		EXEC spa_ErrorHandler 1, 'Limit Available', 
				'spa_limit_available', 'DB Error', 
				'Failed to insert limit Available data.',''
    	END CATCH
			
    END
    ELSE
    	BEGIN
    		EXEC spa_ErrorHandler 1, 'Limit Available', 
				'spa_limit_available', 'Error', 
				'Limit already exists.',''
    	END
    
END
 
ELSE IF @flag = 'u'
BEGIN
    --UPDATE STATEMENT GOES HERE
    IF NOT EXISTS (SELECT 1 FROM limit_available la WHERE 1 = 2 AND la.limit_available_id <> @limit_available_id)
    BEGIN
    	BEGIN TRY
    		UPDATE limit_available
			SET
    			-- limit_available_id = ? -- this column value is auto-generated,
    			limit_id = @limit_id,
    			counterparty_id = @counterparty_id,
    			effective_date = @effective_date,
    			limit_type = @limit_type,
    			limit_available = @limit_available,
    			currency = @currency,
    			comment = @comment
			WHERE limit_available_id = @limit_available_id
			
			EXEC spa_ErrorHandler 0, 'Limit Available', 
				'spa_limit_available', 'Success', 
				'Data updated successfully.', @limit_available_id
    	END TRY
    	BEGIN CATCH
    		EXEC spa_ErrorHandler 1, 'Maintain Limit', 
				'spa_maintain_limit', 'DB Error', 
				'Failed to update maintain limit data.',''
    	END CATCH
			
    END
    ELSE
	BEGIN
		EXEC spa_ErrorHandler 1, 'Limit Available', 
			'spa_limit_available', 'Error', 
			'Limit available already exists.',''
	END
    
END
ELSE IF @flag = 'd'
BEGIN TRY
	DELETE FROM limit_available WHERE limit_available_id = @limit_available_id
	
	EXEC spa_ErrorHandler 0, 'Limit Available', 
		'spa_limit_available', 'Success', 
		'Data deleted successfully.', @limit_available_id
END TRY
BEGIN CATCH
	EXEC spa_ErrorHandler 1, 'Limit Available', 
		'spa_limit_available', 'DB Error', 
		'Failed to delete limit available data.',''
END CATCH
