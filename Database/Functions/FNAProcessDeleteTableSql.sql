SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNAProcessDeleteTableSql', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNAProcessDeleteTableSql
GO

/**
	Function to delete process table

	Parameters
	@table_name	:	Process table to delete.
*/

CREATE FUNCTION [dbo].[FNAProcessDeleteTableSql](
	@table_name VARCHAR(150)
)
RETURNS VARCHAR(500)
AS
BEGIN
	
	DECLARE @FNAProcessDeleteTableSql VARCHAR(500)
	DECLARE @debug_mode VARCHAR(128)
              
	SET @debug_mode = REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, '')


	IF ISNULL(@debug_mode, '') <> 'DEBUG_MODE_ON'
	BEGIN
		SET @FNAProcessDeleteTableSql = 'IF EXISTS (SELECT 1 FROM adiha_process.dbo.sysobjects WHERE id = OBJECT_ID(''' +  @table_name + ''') )
											DROP TABLE ' + @table_name
	END 
	ELSE 
	BEGIN
		SET @FNAProcessDeleteTableSql = ''
	END

    RETURN(@FNAProcessDeleteTableSql)

END



GO
