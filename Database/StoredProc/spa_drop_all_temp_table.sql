IF OBJECT_ID('spa_drop_all_temp_table') IS NOT NULL
	DROP PROC dbo.spa_drop_all_temp_table 
GO

--Drop all local temporary table in current session

CREATE PROCEDURE [dbo].[spa_drop_all_temp_table] 
	@temp_table_name VARCHAR(250) = NULL
AS

DECLARE @d_sql NVARCHAR(MAX)
SET @d_sql = ''

SELECT @d_sql = @d_sql + 'DROP TABLE ' + QUOTENAME(name) + '; '
FROM tempdb..sysobjects WITH (NOLOCK)
WHERE NAME LIKE '#[^#]%'
	AND OBJECT_ID('tempdb..' + QUOTENAME(name)) IS NOT NULL 
	AND (
			@temp_table_name IS NULL 
			OR [id] = object_id('tempdb..' + QUOTENAME(@temp_table_name))
		)

IF @d_sql <> ''
BEGIN
   -- PRINT @d_sql
    EXEC( @d_sql )
END