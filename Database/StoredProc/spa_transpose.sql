IF OBJECT_ID(N'[dbo].[spa_Transpose]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Transpose]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	This procedure is used to transpose the columns of a table.

	Parameters
	@TableName		:	Name of the table.
	@where			:	Condition after a where clause.
	@is_adiha_table :	Determines whether the given table is adiha process table or not.
*/

CREATE PROC [dbo].[spa_Transpose] 
	@TableName VARCHAR(200),
	@where VARCHAR(200)=NULL,
	@is_adiha_table CHAR(1) = 0
AS

DECLARE @TableSchema SYSNAME

SET @TableSchema = 'dbo'
DECLARE @N INT
 
DECLARE @cols TABLE (
	idx INT NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	col VARCHAR(150) NOT NULL
)

IF @is_adiha_table = 1
BEGIN
    INSERT INTO @cols
    SELECT c.Name AS col
    FROM adiha_process.dbo.sysobjects o WITH(NOLOCK)
	INNER JOIN adiha_process.dbo.syscolumns c WITH(NOLOCK) ON  o.id = c.id
    WHERE o.NAME = @TableName
	ORDER BY c.colorder
END
ELSE
BEGIN
    INSERT INTO @cols
    SELECT COLUMN_NAME AS col
    FROM INFORMATION_SCHEMA.COLUMNS WITH(NOLOCK)
    WHERE TABLE_NAME = @TableName
END
 
SET @N = @@ROWCOUNT
    
DECLARE @collist NVARCHAR(MAX),@fieldlist NVARCHAR(MAX), @select_col_list NVARCHAR(MAX)
 
 SELECT @collist = COALESCE(@collist + ',', '') + QUOTENAME(col),
	@select_col_list = COALESCE(@select_col_list + ',', '') + 'ISNULL(' + QUOTENAME(col) + ', '''')' + QUOTENAME(col),
	@fieldlist = COALESCE(@fieldlist + ',', '') + QUOTENAME(col)  +' NVARCHAR(MAX)'
FROM @cols

--PRINT @collist
--PRINT @fieldlist
 
IF OBJECT_ID('tempdb..#tempTable') IS NOT NULL
	DROP TABLE #tempTable

CREATE TABLE #tempTable (
	idx INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
)
   
EXEC('ALTER TABLE #tempTable ADD ' + @fieldlist)

IF @where IS NOT NULL 
	SET @where = ' WHERE ' + @where 
ELSE 
	SET @where = ' '
		 
IF @is_adiha_table = 0
BEGIN
	EXEC('
		INSERT #tempTable(' + @collist + ')
		SELECT ' + @collist + ' FROM ' + @TableName + ' ' + @where + '
	')
END
ELSE
BEGIN
	-- exec spa_print 'INSERT  #tempTable('+ @collist +'
	--select '+@collist+' from adiha_process.dbo.'+@TableName+' '+ @where +'
	--')
	EXEC('
		INSERT #tempTable(' + @collist + ')
		SELECT ' + @collist + ' FROM adiha_process.dbo.' + @TableName + ' ' + @where + '
	')
	--PRINT '---------------------------------------------------------'
END

DECLARE @dynsql NVARCHAR(MAX)

SET @dynsql = '
	SELECT col,
		NULLIF(colval, '''') colval
	FROM (
		SELECT ' + @select_col_list + '
		FROM #tempTable
	) p
	UNPIVOT (
		ColVal FOR Col IN (' + @collist + ')
	) AS unpvt
'

--PRINT (@dynsql)
EXEC (@dynsql)

GO