IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_check_sql_syntax]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_check_sql_syntax]
    
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-11-21
-- Description: Syntax checking of sql statement
 
-- Params:
-- @sql VARCHAR(MAX) - sql statement
-- Returns 0 for valid statement and 1 for invalid
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_check_sql_syntax] (@sql VARCHAR(MAX))
AS
BEGIN
	BEGIN TRY
	SET @sql = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@sql,'adiha_add','+'),'adiha_lessthan','<'),'adiha_greaterthan','>'),'adiha_minus','-'), 'adiha_space', ' ')
		SET @sql = 'set parseonly on;' + @sql;
		EXEC (@sql);
		RETURN(0);
	END TRY
	BEGIN CATCH
		RETURN(1)
	END CATCH;
END 