
IF OBJECT_ID('spa_update_invoice_number') IS NOT NULL
    DROP PROCEDURE spa_update_invoice_number
GO

-- Description: Updates invoice number based finalized and unfinalized status for various calc id .
--EXEC  spa_update_invoice_number @flag = 'f', @xml XML = '<Root><PSRecordSet calc_id = "33621" finalized_date = "2016-02-03"></PSRecordSet><PSRecordSet calc_id = "33626" finalized_date = "2016-02-03"></PSRecordSet></Root>'
CREATE PROCEDURE spa_update_invoice_number
		@flag CHAR(1),
		@xml XML
	
AS

DECLARE @idoc INT 
EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
IF OBJECT_ID('tempdb..#temp_finalize_unfinalize_invoices_list') IS NOT NULL
	DROP TABLE #temp_finalize_unfinalize_invoices_list

-- Execute a SELECT statement that uses the OPENXML rowset provider.
SELECT calc_id [calc_id],
		finalized_date finalized_date
INTO #temp_finalize_unfinalize_invoices_list
FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
WITH (	
	calc_id VARCHAR(10),
	finalized_date DATETIME
)

IF OBJECT_ID('tempdb..#invoice_status') IS NOT NULL
	DROP TABLE #invoice_status
	
--CREATE TABLE #invoice_status
--(
--	calc_id INT,
--	previous_status CHAR(1) COLLATE DATABASE_DEFAULT,	
--	current_status CHAR(1) COLLATE DATABASE_DEFAULT
--)
	
SELECT t.calc_id , ISNULL(civv.finalized,'n') [previous_status], CASE WHEN @flag = 'f' THEN 'y' ELSE 'n' END current_status
INTO #invoice_status
	FROM #temp_finalize_unfinalize_invoices_list t
INNER JOIN Calc_invoice_Volume_variance civv ON t.calc_id = civv.calc_id
		

		
DECLARE @sql VARCHAR(1024)

--EXEC ('SELECT * FROM  #invoice_status')

--RETURN
IF OBJECT_ID('tempdb..#calc_serial_number') IS NOT NULL
	DROP TABLE #calc_serial_number
	
CREATE TABLE #calc_serial_number
(
	calc_id INT,
	invoice_number VARCHAR(255) COLLATE DATABASE_DEFAULT	
)


	
SET @sql = '
	INSERT INTO  #calc_serial_number
	SELECT calc.calc_id, 
	CAST(YEAR(calc.settlement_date) AS CHAR(4)) + ''-I'' + REPLICATE(''0'',7- LEN(CAST((calc.invoice_index + calc.last_invoice_number) AS VARCHAR(255))))  + CAST((calc.invoice_index + calc.last_invoice_number) AS VARCHAR(255)) 
	FROM (		
		SELECT ROW_NUMBER() OVER(ORDER BY civv.calc_id) invoice_index,
			civv.calc_id,
			civv2.invoice_number,
			civv2.settlement_date,				  
			is1.last_invoice_number
		FROM #invoice_status civv
		INNER JOIN calc_invoice_volume_variance civv2 on civv.calc_id = civv2.calc_id
			CROSS APPLY invoice_seed is1
		WHERE civv.previous_status <> civv.current_status
	) calc'

--PRINT @sql	
EXEC (@sql)

--SELECT * FROM #calc_serial_number
--RETURN

SET @sql = '
	UPDATE civv WITH(UPDLOCK) SET civv.invoice_number =  CASE WHEN p.previous_status = ''n'' AND p.current_status = ''y'' THEN ISNULL(csn.invoice_number,CAST(civv.calc_id as VARCHAR(50))) WHEN p.previous_status = ''y'' AND p.current_status = ''y'' THEN CAST(civv.invoice_number as VARCHAR(50)) ELSE CAST(p.calc_id as VARCHAR(50)) END   FROM Calc_invoice_Volume_variance civv
	INNER JOIN #invoice_status p ON civv.calc_id = p.calc_id
	LEFT JOIN #calc_serial_number csn ON p.calc_id = csn.calc_id'
EXEC (@sql)

SET @sql = '
	DELETE sn FROM #calc_serial_number sn
	INNER JOIN #invoice_status p ON sn.calc_id = p.calc_id
	WHERE p.previous_status= ''y'' AND p.current_status = ''n'''
EXEC (@sql)

-- Update to calc invoice true up table
SET @sql = '
	UPDATE citu WITH(UPDLOCK) SET citu.invoice_number = civv.invoice_number FROM calc_invoice_true_up citu
	INNER JOIN Calc_invoice_Volume_variance civv ON citu.calc_id = civv.calc_id
	INNER JOIN #invoice_status p ON civv.calc_id = p.calc_id'
EXEC (@sql)

DECLARE @last_invoice_number INT 
DECLARE @current_invoice_count INT 
SELECT @current_invoice_count = COUNT(1) FROM #calc_serial_number
SELECT @last_invoice_number = is1.last_invoice_number + @current_invoice_count FROM invoice_seed is1

--sSELECT @last_invoice_number
SET @sql ='UPDATE invoice_seed WITH(UPDLOCK) SET last_invoice_number = ' + CAST(ISNULL(@last_invoice_number,0) AS  VARCHAR(50)) 
EXEC(@sql)
