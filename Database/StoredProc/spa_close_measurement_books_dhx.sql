IF OBJECT_ID(N'[dbo].[spa_close_measurement_books_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_close_measurement_books_dhx]
GO

-- ===========================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2016-03-07
-- Description: CRUD operation for Close Accounting Period
 
-- Params:
-- @flag     CHAR - Operation flag

-- ===========================================================================================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROC [dbo].[spa_close_measurement_books_dhx]
	@flag CHAR(1),
	@xml xml = NULL,
	@as_of_date DATETIME = NULL, 
	@contract_id VARCHAR(MAX) = NULL

AS

SET NOCOUNT ON
DECLARE @idoc INT
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT 

IF @flag = 'g'
BEGIN
	SELECT	close_measurement_books_id,
			NULLIF(sub_id, 0),
			as_of_date [close_date],
			create_user [closed_by],
			dbo.FNADateFormat(create_ts) [closed_on]
	FROM close_measurement_books
	ORDER BY as_of_date DESC
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		SELECT 
			NULLIF(close_measurement_books_id, 0) close_measurement_books_id,
			NULLIF(sub_id, 0) sub_id,
			as_of_date
		INTO #temp_close_measurement_books
		FROM   OPENXML(@idoc, '/Root/GridGroup/GridRow', 1)
			WITH (
				close_measurement_books_id INT '@close_measurement_books_id',
				sub_id INT '@sub_id',
				as_of_date DATETIME '@close_date'
			)
		
		IF EXISTS(SELECT 1 FROM #temp_close_measurement_books GROUP BY as_of_date,sub_id HAVING COUNT(1) > 1)
		BEGIN
			EXEC spa_ErrorHandler -1,
					'Close Measurement Books',
					'spa_close_measurement_books',
					'Error'
					, 'Duplicate entry found'
					, ''
			RETURN
		END
		
		BEGIN TRAN
		MERGE close_measurement_books AS cmb
		USING 
			(
				SELECT
					close_measurement_books_id, 
					sub_id,	
					as_of_date
				FROM #temp_close_measurement_books
			) AS tbl
		ON (cmb.close_measurement_books_id = tbl.close_measurement_books_id) 
		WHEN NOT MATCHED BY TARGET 
		THEN 
			INSERT(sub_id,as_of_date) 
			VALUES(tbl.sub_id,tbl.as_of_date)
		WHEN MATCHED 
		THEN 
			UPDATE 
			SET sub_id = tbl.sub_id,
				as_of_date = tbl.as_of_date
		WHEN NOT MATCHED BY SOURCE  THEN
		DELETE;

		COMMIT

		EXEC spa_ErrorHandler 0
				, 'close_measurement_books'
				, 'spa_close_measurement_books_dhx'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @DESC = 'Fail to save Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'close_measurement_books'
			, 'spa_close_measurement_books_dhx'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

IF @flag = 'v'
BEGIN
	/* Checking the Closed Accounting Period */		
	DECLARE @sql VARCHAR(MAX)
	
	SET @sql = '
	IF NOT EXISTS(SELECT 1 FROM contract_group cg 
	INNER JOIN close_measurement_books c ON ISNULL(c.sub_id,1) = ISNULL(cg.sub_id,1) AND YEAR(c.as_of_date) = '+CAST(YEAR(@as_of_date) AS VARCHAR(30))+' AND MONTH(c.as_of_date) = '+CAST(MONTH(@as_of_date) AS VARCHAR(30))+'
	WHERE cg.contract_id IN ('+@contract_id+'))
		SELECT ''true'' as [validation]
	ELSE
		SELECT ''flase'' as [validation]
		'
	EXEC(@sql)	
END

IF @flag = 'l' -- Validation for closed accounting period while invoice lock/unlock/finalize/unfinalize/update_status/delete
BEGIN
	DECLARE @close_accounting_period VARCHAR(MAX) = NULL, @action VARCHAR(20)
	
	EXEC sp_xml_preparedocument @idoc OUTPUT,@xml
	
	IF OBJECT_ID('tempdb..#temp_closed_accounting_period') IS NOT NULL
		DROP TABLE #temp_closed_accounting_period
		
	SELECT invoice_id,
			contract_id,
			as_of_date,
			[action]
	INTO #temp_closed_accounting_period
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		invoice_id VARCHAR(50),
		contract_id VARCHAR(20),
		as_of_date VARCHAR(20),
		[action] VARCHAR(30)
	)

	SET @action = (SELECT TOP 1 action FROM #temp_closed_accounting_period)

	IF EXISTS (
		SELECT CAST((tcap.invoice_id) AS VARCHAR(50)) + ',' 
			  FROM #temp_closed_accounting_period tcap 
			  WHERE EXISTS (
				SELECT 1 FROM close_measurement_books c
				WHERE YEAR(c.as_of_date) = YEAR(tcap.as_of_date) AND MONTH(c.as_of_date) = MONTH(tcap.as_of_date) AND c.sub_id IS NULL
			)
	)
	BEGIN
		SET @close_accounting_period = (SELECT CAST((tcap.invoice_id) AS VARCHAR(50)) + ',' 
			  FROM #temp_closed_accounting_period tcap 
			  WHERE EXISTS (
				SELECT 1 FROM close_measurement_books c
				WHERE YEAR(c.as_of_date) = YEAR(tcap.as_of_date) AND MONTH(c.as_of_date) = MONTH(tcap.as_of_date) AND c.sub_id IS NULL
			)  FOR XML PATH(''))
		SELECT 'false' [validation], @close_accounting_period [invoice_id], @action AS [action]
	END
	ELSE 
	BEGIN
		SET @close_accounting_period = (SELECT CAST((tcap.invoice_id) AS VARCHAR(50)) + ','  
											FROM #temp_closed_accounting_period tcap 
											WHERE EXISTS (SELECT 1 FROM contract_group cg 
															INNER JOIN close_measurement_books c ON c.sub_id = cg.sub_id AND YEAR(c.as_of_date) = YEAR(tcap.as_of_date) AND MONTH(c.as_of_date) = MONTH(tcap.as_of_date)
															WHERE cg.contract_id = tcap.contract_id) FOR XML PATH(''))
		
		IF @close_accounting_period IS NULL
		BEGIN
			SELECT 'true' AS [validation], NULL AS [invoice_id] , @action AS [action]
		END
		ELSE
		BEGIN
			SELECT 'false' AS [validation] , @close_accounting_period [invoice_id], @action AS [action]
		END
	END
END
ELSE IF @flag = 't' -- Subsidiary Dropdown Options
BEGIN
	SELECT DISTINCT sub.entity_id [value],sub.entity_name [text] 
    FROM portfolio_hierarchy book
    INNER JOIN    Portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id  
    INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.entity_id  
    WHERE sub.parent_entity_id IS NULL
END