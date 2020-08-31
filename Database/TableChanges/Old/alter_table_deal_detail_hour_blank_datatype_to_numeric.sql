DECLARE @query VARCHAR(1000)
DECLARE @cn INT
SET @cn = 1
WHILE @cn <= 25 
BEGIN
	
	SET @query = 'IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = ''deal_detail_hour_blank'' 
				  AND c.COLUMN_NAME = ''Hr' + CAST(@cn AS VARCHAR(2)) + ''' AND c.DATA_TYPE <> ''NUMERIC'')
				  BEGIN
					ALTER TABLE deal_detail_hour_blank ALTER COLUMN [Hr' + CAST(@cn AS VARCHAR(2)) + '] [numeric](38,20) NULL
				  END'
	PRINT @query
	EXEC(@query)
	SET @cn = @cn + 1	
END
