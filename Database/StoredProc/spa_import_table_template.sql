IF OBJECT_ID(N'[dbo].[spa_import_table_template]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_table_template]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	 Generate import process table.
 
	 Parameters:
	 @flag : operational flag 'c' - create table 'r' - return table name only, 's' -> call from SOAP
	 @table_id : template table id
	 @process_id : process_id
	 
*/

CREATE PROCEDURE [dbo].[spa_import_table_template]
	@flag NCHAR(1),   
    @table_id INT,
    @process_id NVARCHAR(200),
    @repeat_number INT = 0,
	@rule_name NVARCHAR(500) = NULL
AS
SET NOCOUNT ON
 
DECLARE @table_name NVARCHAR(200)
DECLARE @column_list NVARCHAR(MAX)
DECLARE @user_login_id NVARCHAR(50)
DECLARE @process_object NVARCHAR(300)
DECLARE @process_table NVARCHAR(500)

SELECT  @table_name = it.ixp_tables_name
FROM   ixp_tables it
WHERE  it.ixp_tables_id = @table_id

SET @user_login_id = dbo.FNADBUser()
SET @process_table = dbo.FNAProcessTableName(@table_name + '_' + CAST(@repeat_number AS NVARCHAR(20)), @user_login_id, @process_id)
SET @process_object = @table_name + '_' + CAST(@repeat_number AS NVARCHAR(20)) + '_' + @user_login_id + '_' + @process_id

--PRINT @process_object
IF @flag = 'c' OR @flag = 'b'
BEGIN
	IF OBJECT_ID(@process_table) IS NOT NULL
		EXEC('DROP TABLE ' + @process_table)
	
	SELECT @column_list = COALESCE(@column_list + ', ', '') + '[' + ic.ixp_columns_name + '] ' + MAX(ic.column_datatype) 
	FROM ixp_columns ic
	WHERE ic.ixp_table_id = @table_id
	GROUP BY ic.ixp_columns_name
	
	--PRINT('CREATE TABLE  ' + @process_table + ' (  ' + @column_list + ' )')
	EXEC('CREATE TABLE  ' + @process_table + ' (  ' + @column_list + ' )')
END
IF @flag = 'd'
BEGIN
	SET @process_table = dbo.FNAProcessTableName(@table_name, @user_login_id , @process_id)
	
	IF OBJECT_ID(@process_table) IS NOT NULL
		EXEC('DROP TABLE ' + @process_table)
	
	SELECT @column_list = COALESCE(@column_list + ', ', '') + '[' + ic.ixp_columns_name + '] ' + ic.column_datatype 
	FROM ixp_columns ic
	WHERE ic.ixp_table_id = @table_id
	
	--PRINT('CREATE TABLE  ' + @process_table + ' (  ' + @column_list + ' )')
	EXEC('CREATE TABLE  ' + @process_table + ' (  ' + @column_list + ' )')
END

IF @flag = 's' 
BEGIN
	IF OBJECT_ID(@process_table) IS NOT NULL
		EXEC('DROP TABLE ' + @process_table)	
	
	IF OBJECT_ID('tempdb..#temp_columns') IS NOT NULL
		DROP TABLE #temp_columns

	SELECT REPLACE(REPLACE(REPLACE(iidm.source_column_name, SUBSTRING(iidm.source_column_name, 0, CHARINDEX('.', iidm.source_column_name)+1), ''), '[', ''), ']', '') [column_name], dest_column
	INTO #temp_columns
	FROM ixp_import_data_mapping iidm
	INNER JOIN ixp_rules ir ON ir.ixp_rules_id = iidm.ixp_rules_id
	WHERE ir.ixp_rules_name = @rule_name  
	ORDER BY 1
	
	SELECT @column_list = COALESCE(@column_list + ', ', '') + '[' + temp.[column_name] + '] ' + MAX(ic.column_datatype) 
	FROM #temp_columns temp
	INNER JOIN ixp_columns ic ON ic.ixp_columns_id = dest_column
	WHERE NULLIF(temp.[column_name], '') IS NOT NULL
	GROUP BY ic.ixp_columns_name,[column_name] ORDER BY [column_name]
		
	--PRINT('CREATE TABLE  ' + @process_table + ' (  ' + @column_list + ' )')
	EXEC('CREATE TABLE  ' + @process_table + ' (  ' + @column_list + ' )')
END

IF @flag NOT IN('b', 'd')
BEGIN
	SELECT @process_table
END
GO