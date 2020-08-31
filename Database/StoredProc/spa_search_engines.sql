IF OBJECT_ID('[dbo].[spa_search_engines]') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[spa_search_engines]
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2011-11-17
-- Description: SP to run at the End of the day process 
-- parameters
-- @flag: specifies operation type. 't' -> selecting tables, 'c'-> selecting columns.
-- @table_name: table_name.
-- @column_name: column name
-- ===============================================================================================================================

CREATE PROC [dbo].[spa_search_engines]
@flag CHAR(1),
@table_name VARCHAR(100) = NULL,
@column_name VARCHAR(100) = NULL,
@search_text VARCHAR(MAX) = NULL,
@search_metadata CHAR(1) = NULL
AS
IF @flag = 't' -- for selecting tables from database
BEGIN
    SELECT NAME
    FROM   sys.tables
    ORDER BY
           NAME
END
ELSE 
IF @flag = 'c' -- selecting clumns from tables
BEGIN
    IF @table_name IS NULL
    BEGIN
        RETURN
    END
    ELSE
    BEGIN
        SELECT c.name AS column_name
        FROM   sys.tables AS t
               INNER JOIN sys.columns c
                    ON  t.OBJECT_ID = c.OBJECT_ID
        WHERE  t.[name] IN (SELECT a.Item FROM   dbo.SplitCommaSeperatedValues(@table_name) a)
    END
END
ELSE 
IF @flag = 's'
BEGIN
    IF (@table_name IS NOT NULL AND @column_name IS NOT NULL)
    BEGIN
        SELECT c.[name] AS [column],
               t.[name] AS [table] 
               INTO #temp
        FROM   sys.tables t
               INNER JOIN sys.[columns] c
                    ON  t.OBJECT_ID = c.OBJECT_ID
        WHERE  t.[name]  IN (SELECT a.Item FROM   dbo.SplitCommaSeperatedValues(@table_name) a)
               AND c.[name] IN (SELECT b.Item FROM   dbo.SplitCommaSeperatedValues(@column_name) b)
        
        DECLARE @table   VARCHAR(MAX)
        DECLARE @column  VARCHAR(MAX)
        
        SELECT @column = #temp.[column],
               @table = #temp.[table]
        FROM   #temp
        
        DECLARE @sql VARCHAR(MAX)
        SET @sql = 'SELECT * FROM ' + @table + ' WHERE ' + @column + ' LIKE ''%' 
            + @search_text + '%'''
        
        EXEC (@sql)
    END
    ELSE 
	BEGIN
		SELECT * FROM application_functions af WHERE af.function_name LIKE '%' + @search_text + '%'
	END
END 