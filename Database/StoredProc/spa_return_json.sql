IF OBJECT_ID(N'[dbo].[spa_return_json]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_return_json]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2014-12-31
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_return_json]
    @from_clause VARCHAR(5000),
    @column_list VARCHAR(5000)
AS

BEGIN
	DECLARE @sql NVARCHAR(4000)
	DECLARE @xml XML
	DECLARE @param NVARCHAR(100)
	SET @param = N'@xml XML OUTPUT';

	SET @sql = ' SET @xml = (SELECT ' + @column_list + '
				 FROM ' + REPLACE(@from_clause, '''', '''''') + ' 
				 FOR XML RAW (''row''), ROOT (''root''), ELEMENTS)'
	
	EXECUTE sp_executesql @sql, @param,  @xml = @xml OUTPUT;
	
	SELECT dbo.FNAFlattenedJSON(@xml) json_string
END

--EXEC spa_return_json 'static_data_type', 'type_id,type_name'	 