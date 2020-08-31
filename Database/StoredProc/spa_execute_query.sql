IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_execute_query]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_execute_query]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spa_execute_query]  
	@query varchar(max)
	, @call_from varchar(100) = NULL    
as  

SET NOCOUNT ON
  
DECLARE @type CHAR(1)  
DECLARE @temptablename VARCHAR(100), @cols AS VARCHAR(100),@check_sps INT,@check_rfx INT;
DECLARE @order_by_loc INT   
DECLARE @order_by VARCHAR (5000)  
  
--SET @query = ' [i1,f1], [i2,f2],[i3,f3],[i4,f4],[i5,f5]'  
--SET @query = ' [''Index 1'',''Field f1''],[''Index i2'',''Field f2''],[''Index i3'',''Field f3''],[i4,f4],[i5,f5]'  
--SET @query = 'select * from static_data_value'  
--PRINT @query   
  
SET @query = LTRIM(@query)  
SET @type = SUBSTRING(@query, 1, 1)
SET @check_sps = CHARINDEX('exec', @query)

IF @call_from = 'rfx' AND @type = 's'   
BEGIN
	--Used By RFX Custom DropDowns
	SET @query = REPLACE(@query,'_ADD_','+')
	--PRINT @query
	EXEC(@query)  
END 
ELSE
BEGIN
	-- if the query string starts with a [, then parse into a table first  
	IF @type = '['
	BEGIN
		SET @query = REPLACE(@query, CHAR(13), '')
		SET @query = REPLACE(@query, CHAR(10), '')
		SET @query = REPLACE(@query, CHAR(32), '')	
		SET @query = [dbo].[FNAParseStringIntoTable](@query) 
		--PRINT @query; 
		--returns first 2 columns as (value_id,code), this assumes only two columns.  
		EXEC('SELECT value_id, code from (' + @query + ') a(value_id, code)');
	END 
	ELSE IF @check_sps = 1 
	BEGIN
		EXEC (@query)
	END
	ELSE  -- case fore @type other than '['
	BEGIN  		
		--PRINT @query	
		--insert the records in temp table.  
		--SET @temptablename = 'adiha_process.dbo.exequery_' + dbo.FNADBUser() + '_' + dbo.FNAGetNewID();  
		SET @temptablename = dbo.FNAProcessTableName('exequery', dbo.FNADBUser(), dbo.FNAGetNewID());

		SELECT  @order_by_loc = PATINDEX ('%order by%', @query)

		IF @order_by_loc = 0 
		BEGIN		
			SET @order_by = ''                    	
		END 
		ELSE 
		BEGIN
		  SELECT @order_by = SUBSTRING (@query, @order_by_loc, LEN(@query) )
		  SELECT @query = SUBSTRING (@query, 1, @order_by_loc - 1)
		END
		
		EXEC ('SELECT * INTO ' + @temptablename + ' FROM (' + @query + ') a' )  
	  
	  --retrieves first and 2nd column only as (value_id,code) and drops the temp table.  
	  SET @cols = '';  
	  SELECT  @cols = @cols + CASE WHEN column_id = 1 THEN name + ' as value_id, ' ELSE name + ' as code' END  
	  FROM adiha_process.sys.columns  
	  WHERE OBJECT_ID = OBJECT_ID(@temptablename) AND column_id IN ( 1, 2 );  
	  
	  EXEC ( 'SELECT ' + @cols + ' FROM ' + @temptablename + ' ' + @order_by ) ;     
	  EXEC ( 'DROP TABLE ' + @temptablename );  	  
	END  
END  
GO


