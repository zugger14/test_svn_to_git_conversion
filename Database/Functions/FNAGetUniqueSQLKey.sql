IF OBJECT_ID(N'dbo.FNAGetUniqueSQLKey', N'FN') IS NOT NULL
    DROP FUNCTION dbo.FNAGetUniqueSQLKey
 GO 
/*
	Generate identity id for given value. current database name is added as prefix.
	SELECT dbo.FNAGetUniqueSQLKey('EXEC spa_gl_system_mapping ''g''','test')
*/
CREATE FUNCTION [dbo].[FNAGetUniqueSQLKey]
(
	@source VARCHAR(4000),
	@prefix	VARCHAR(20) = NULL
)
RETURNS VARCHAR(1000)
AS
BEGIN
	DECLARE @result VARCHAR(4000),@dbname VARCHAR(50) = db_name()
	SET @source = REPLACE(@source,' ','')

	SET @prefix = NULLIF(@prefix,'') + '_'
	
	SELECT @result = @dbname  + '_' + ISNULL(@prefix,'') + CAST(CHECKSUM(@source, '') AS VARCHAR(MAX))
	
	RETURN @result
END 
 
  
  
  
  
  
  






  
  
  
  
  
  





