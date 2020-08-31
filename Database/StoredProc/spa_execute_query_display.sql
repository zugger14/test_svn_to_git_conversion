IF OBJECT_ID(N'[dbo].[spa_execute_query_display]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_execute_query_display
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].spa_execute_query_display  
	@query VARCHAR(MAX),
	@value VARCHAR(MAX) = NULL
AS  
  
/*
set @query = ' [i1,f1], [i2,f2],[i3,f3],[i4,f4],[i5,f5]'  
set @query = ' [''Index 1'',''Field f1''],[''Index i2'',''Field f2''],[''Index i3'',''Field f3''],[i4,f4],[i5,f5]'  
set @query = 'select * from static_data_value'  
EXEC spa_print @query   
SET @query = 'SELECT source_system_id, source_system_name FROM source_system_description'  
exec spa_execute_query_display 'SELECT ''p'' code,''Physical'' Data UNION  SELECT ''f'' code,''Financial'' Data', 'p'
exec spa_execute_query_display 'SELECT source_book_id,source_system_book_id FROM dbo.source_book', 72
exec spa_execute_query_display 'SELECT source_counterparty_id,counterparty_name FROM dbo.source_counterparty', 22
exec spa_execute_query_display 'exec spa_getsourceuom @flag=''s''','22'
exec spa_execute_query_display 'EXEC  spa_getVolumeFrequency NULL,NULL','m'
exec spa_execute_query_display '[''Index 1'',''Field f1''],[''Index i2'',''Field f2''],[''Index i3'',''Field f3''],[i4,f4],[i5,f5]', 'i5'
*/

DECLARE @type CHAR(1)  
DECLARE @temptablename VARCHAR(100), @cols AS VARCHAR(100),@check_sps INT 
DECLARE @sql VARCHAR(MAX)
	
--SET @temptablename = 'adiha_process.dbo.exequery_' + dbo.FNADBUser() + '_' + dbo.FNAGetNewID(); 
SET @temptablename = dbo.FNAProcessTableName('exequery', dbo.FNADBUser(), dbo.FNAGetNewID()); 
EXEC('CREATE TABLE ' +  @temptablename + ' (value_id VARCHAR(10), name VARCHAR(500))')
  
SET @query = LTRIM(@query)  
SET @type = SUBSTRING(@query,1,1)
SET @check_sps  = CHARINDEX('exec', @query)
  
IF @check_sps = 1 --for exec statements
BEGIN
	EXEC spa_print 'INSERT INTO ', @temptablename, ' ', @query
	EXEC('INSERT INTO ' + @temptablename + ' ' + @query)
	--EXEC('SELECT * FROM ' +  @temptablename)
	SET @sql = 'SELECT * FROM ' + @temptablename + ' WHERE 1 = 1 AND value_id = ''' + @value + ''''
	EXEC spa_print @sql
	EXEC(@sql)
	EXEC ( 'DROP TABLE ' + @temptablename)  
END
ELSE
BEGIN  
	IF @type = '['
		SET @query = [dbo].[FNAParseStringIntoTable](@query)
	EXEC spa_print @query
	EXEC ('INSERT INTO ' + @temptablename + ' (value_id, name) (' + @query + ')')  
	
	SET @sql = 'SELECT * FROM ' + @temptablename + ' WHERE 1 = 1 AND value_id = ''' + @value + ''''
	
	EXEC spa_print @sql
	EXEC(@sql)
	EXEC ('DROP TABLE ' + @temptablename)  
END  
GO


