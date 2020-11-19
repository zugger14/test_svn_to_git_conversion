/**
* for column generation on insert/update of report manager datasource( for table).
* sligal
* 10/17/2012
**/
IF OBJECT_ID(N'[dbo].[spa_rfx_column_generate]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_column_generate]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 10/17/2012
-- Description: Generates column names on insert/update of report manager datasource: datasource as table.
 
-- Params:
-- @flag							: Operation flag			           
-- @table_name						: list of user CSV
-- @source_id						: list of roles CSV
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_rfx_column_generate]
	@flag CHAR(1) = NULL,
	@table_name VARCHAR(500) = NULL,
	@source_id INT = NULL
AS
SET NOCOUNT ON -- NOCOUNT is set ON since returning row count has side effects on exporting table feature
	DECLARE @sql VARCHAR(8000)
	
	IF @flag = 's'
	BEGIN
	--To exclude the '[adiha_process].[dbo].'from the variable @table_name and replace '[' and ']' with blank space.
	IF CHARINDEX('.[dbo].', @table_name, 1) > 0
	BEGIN
		SET @table_name = dbo.[FNAGetUserTableName](@table_name, '.[dbo].')
	END 
	ELSE 
	BEGIN
		SET @table_name = @table_name
	END
	
	    SET @sql = 'SELECT '''' as Status, COLUMN_NAME Columns
					FROM   INFORMATION_SCHEMA.COLUMNS
					WHERE  TABLE_NAME = ''' + @table_name + '''
					UNION ALL
					SELECT '''' as Status, COLUMN_NAME Columns
					FROM   adiha_process.INFORMATION_SCHEMA.COLUMNS WITH(NOLOCK)
					WHERE  TABLE_NAME = ''' + @table_name + '''
					'
		EXEC spa_print @sql					
		EXEC (@sql) 
	END
	
	IF @flag = 'x' -- for generating columns for update in datasource form (view insert)
	BEGIN
		SET @sql = 'SELECT dsc.[name]
					FROM data_source_column dsc
					WHERE dsc.source_id = ' + CAST(@source_id AS VARCHAR(100))
		EXEC (@sql)
	END
	
	IF @flag = 't' -- for generating all table names for drop down in datasource form (view insert)
	BEGIN
		SELECT t.[name], t.[name] FROM sys.tables t
		UNION ALL 
		SELECT '[adiha_process]'+ '.[dbo].' + QUOTENAME(t.[name])  ,SUBSTRING(t.[name], LEN('batch_export_') + 1, LEN(t.[name]) - LEN('batch_export_')) 
		FROM adiha_process.sys.tables t WITH(NOLOCK)
		WHERE t.[name] LIKE '%batch_export%'
		UNION ALL 
		SELECT '[adiha_process]'+ '.[dbo].' + QUOTENAME(t.[name])  ,SUBSTRING(t.[name], LEN('report_export_') + 1, LEN(t.[name]) - LEN('report_export_')) 
		FROM adiha_process.sys.tables t WITH(NOLOCK)
		WHERE t.[name] LIKE '%report_export%'
		ORDER BY 2 ASC
	END
	
	
	