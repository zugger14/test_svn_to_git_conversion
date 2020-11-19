IF OBJECT_ID(N'[dbo].[spa_create_html_table]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_create_html_table]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_create_html_table]
	@table NVARCHAR(MAX), --A query to turn into HTML format. It should not include an ORDER BY clause.
	@orderBy NVARCHAR(MAX) = NULL, --An optional ORDER BY clause. It should contain the words 'ORDER BY'.
	@html NVARCHAR(MAX) = NULL OUTPUT --The HTML output of the procedure.
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @orderBy IS NULL
	BEGIN
	    SET @orderBy = ''
	END
	
	SET @orderBy = REPLACE(@orderBy, '''', '''''');

	DECLARE @select_cols NVARCHAR(MAX); 

	SELECT @select_cols = COALESCE(@select_cols + ',', '') + CASE WHEN DATA_TYPE IN ('Numeric', 'FLOAT') THEN 'dbo.FNARemoveTrailingZero(['+ COLUMN_NAME + '])' ELSE '[' + COLUMN_NAME + ']' END + ' AS ['+ COLUMN_NAME + ']' 
    FROM adiha_process.INFORMATION_SCHEMA.COLUMNS WITH(NOLOCK)
	WHERE TABLE_NAME = REPLACE(@table, 'adiha_process.dbo.', '')
	
	DECLARE @realQuery NVARCHAR(MAX) = 
	        '
    DECLARE @headerRow NVARCHAR(MAX);
    DECLARE @cols NVARCHAR(MAX);    

    SELECT ' + @select_cols + ' INTO #dynSql FROM ' + @table + ' sub;

     SELECT @cols = COALESCE(@cols + '', '''''''', '', '''') + ''dbo.FNAStripHTML(['' + name + '']) AS ''''td''''''
    FROM tempdb.sys.columns  WITH(NOLOCK)
    WHERE object_id = object_id(''tempdb..#dynSql'');

    SET @cols = ''SET @html = CAST(( SELECT '' + @cols + '' FROM #dynSql ' + @orderBy + ' FOR XML PATH(''''tr''''), ELEMENTS XSINIL) AS nvarchar(max))''  

    EXEC sys.sp_executesql @cols, N''@html NVARCHAR(MAX) OUTPUT'', @html=@html OUTPUT

    SELECT @headerRow = COALESCE(@headerRow + '''', '''') + ''<th align ="left">'' + name + ''</th>'' 
    FROM tempdb.sys.columns  WITH(NOLOCK)
    WHERE object_id = object_id(''tempdb..#dynSql'');

    SET @headerRow = ''<tr style="background:#3498DB;font-weight:bold;color:#F4F6F7">'' + @headerRow + ''</tr>'';

    SET @html = ''<table border="1">'' + @headerRow + REPLACE(@html, ''<tr xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'', ''<tr style="background:#F4F6F7;font-style:normal;">'') + ''</table>'';    
    ';
	--PRINT @realQuery
	EXEC sys.sp_executesql @realQuery,
	     N'@html NVARCHAR(MAX) OUTPUT',
	     @html = @html OUTPUT
END
GO
