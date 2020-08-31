IF OBJECT_ID(N'dbo.FNAProcessTableName', N'FN') IS NOT NULL
    DROP FUNCTION dbo.FNAProcessTableName
 GO 
 /*
====================================================================================

Execute below EXEC statement to list parameters with detail. If description column is blank for any parameter then goto to end of this script and add description for missing parameter.
----------------------------------------------
Possible values for @object_type: 'PROCEDURE','FUNCTION','TABLE','VIEW'

EXEC [spa_object_documentation] @flag = 'a',  @object_type = 'FUNCTION', @object_name = 'FNAProcessTableName'
======================================================================================
*/

CREATE FUNCTION dbo.FNAProcessTableName
(
	@table_name  VARCHAR(150),
	@u_id        VARCHAR(50),
	@process_id  VARCHAR(150)
)
RETURNS VARCHAR(250) --128 is the max length of table name supported by SQL Server 2005
AS
BEGIN
	DECLARE @FNAProcessTableName VARCHAR(250)  

	IF @u_id IS NULL 
	BEGIN
		SET @u_id = dbo.FNADBUser()   
	END
	--SET @FNAProcessTableName = 'adiha_process.dbo.' + QUOTENAME(@table_name + '_' + @u_id + '_' + @process_id) \
	SET @FNAProcessTableName = 'adiha_process.dbo.' + @table_name + '_' + REPLACE(REPLACE(@u_id, '.', '_'),'-', '_') + '_' + @process_id  
	
	RETURN(@FNAProcessTableName)
END  
GO

/* Add or update extended property value of Function and its parameters. To add extended property value for Function put 'name' blank */
IF  EXISTS (SELECT 1 FROM sys.objects WHERE name = 'spa_object_documentation' AND TYPE IN (N'P', N'PC'))
BEGIN
	EXECUTE [spa_object_documentation] @json_string =
				N'
				{
					"object_type":"FUNCTION","object_name":"FNAProcessTableName",
					"parameter": 
								[
									{"name":"","desc":"Function to generate unique process table name with user id and process id suffix."},
									{"name":"@process_id","desc":"Unique process id"},
									{"name":"@table_name","desc":"Proposed table name"},
									{"name":"@u_id","desc":"User id to append in proposed table name. If null then context user is used."}
								]
				}'
END
  
  
  
  
  
  





