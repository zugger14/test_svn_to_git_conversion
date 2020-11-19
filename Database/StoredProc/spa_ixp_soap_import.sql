

IF OBJECT_ID(N'[dbo].[spa_ixp_soap_import]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_soap_import]
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
-- exec spa_ixp_soap_import 't', 'adiha_process.dbo.xml_data_table_farrms_admin_EFC2CA4F_AD03_4061_8355_03EC749501C0', 'Generic Deal Import Rule', 'ixp_source_deal_template'
-- ===============================================================================================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_ixp_soap_import]
    @flag CHAR(1),
    @process_table VARCHAR(500) = NULL,
    @rule_name VARCHAR(500) = NULL,
    @rule_table VARCHAR(500) = NULL,
    @soap_function_name VARCHAR(400) = NULL
AS

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @err_code INT
DECLARE @column_lists VARCHAR(MAX)
DECLARE @desc VARCHAR(MAX)

SET @err_code = 0
 
IF @flag = 's' -- error handler
BEGIN
	--DECLARE @process_table VARCHAR(200)
	--SET @process_table = 'adiha_process.dbo.xml_data_table_farrms_admin_083458B7_4BEB_49EF_BB83_001D4F4E6420'
	
    IF OBJECT_ID(@process_table) IS NULL OR @process_table IS NULL
    BEGIN
    	EXEC spa_ErrorHandler -1,  
			'Deal Interface',  
			'spa_ixp_soap_error_handler',  
			'Error',  
			'Process table is null or invalid.',  
			'Please provide valid process tabel name.' 
		--SET @err_code = 1
		RETURN
    END
    
    IF NOT EXISTS (SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = @rule_name)
    BEGIN
    	SET @desc = 'Rule:-' + @rule_name + ' is not present in system' 
    	EXEC spa_ErrorHandler -1,  
			'Deal Interface',  
			'spa_ixp_soap_error_handler',  
			'Error',  
			'Rule not presnet in system.',  
			@desc 
		SET @err_code = 1
		RETURN
    END
    
    SELECT @column_lists = COALESCE(@column_lists + ',', '') + c.name
    FROM adiha_process.sys.columns c WITH(NOLOCK)
    INNER JOIN adiha_process.sys.objects o WITH(NOLOCK) ON  c.object_id = o.object_id    
    LEFT JOIN (
           SELECT REPLACE(REPLACE(REPLACE(iidm.source_column_name, SUBSTRING(iidm.source_column_name, 0, CHARINDEX('.', iidm.source_column_name)+1), ''), '[', ''), ']', '') [column_name]
           FROM  ixp_import_data_mapping iidm
           INNER JOIN ixp_rules ir ON  ir.ixp_rules_id = iidm.ixp_rules_id
           WHERE  ir.ixp_rules_name = @rule_name
    ) temp ON temp.column_name = c.[name]
    WHERE  o.[name] = REPLACE(@process_table, 'adiha_process.dbo.', '') AND temp.column_name IS NULL
    
    IF @column_lists IS NOT NULL
    BEGIN
    	SET @desc = 'Columns :- ' + @column_lists + ' are not present in rule.' 
    	EXEC spa_ErrorHandler -1,  
			'Deal Interface',  
			'spa_ixp_soap_error_handler',  
			'Error',  
			'Process table contains invalid columns.',  
			@desc
		SET @err_code = 1
		RETURN
    END
    
    IF @err_code = 0
    BEGIN
    	EXEC spa_ErrorHandler 0,  
			'Deal Interface',  
			'spa_ixp_soap_error_handler',  
			'Success',  
			'Process table valid.',  
			''
		RETURN
    END
END
ELSE IF @flag = 't' -- transfer temp table values to new process table created wrt rule
BEGIN
	BEGIN TRY
		DECLARE @ixp_table_id INT
		DECLARE @process_id VARCHAR(300)
		DECLARE @new_process_table VARCHAR(600)
		DECLARE @rule_id VARCHAR(10)
		
		SET @process_id = dbo.FNAGetNewID()

		SELECT @ixp_table_id = it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = @rule_table
		
		IF OBJECT_ID('tempdb..#temp_soap_table_name') IS NOT NULL
			DROP TABLE #temp_soap_table_name
		CREATE TABLE #temp_soap_table_name (table_name VARCHAR(600) COLLATE DATABASE_DEFAULT )
		
		INSERT INTO #temp_soap_table_name (table_name)
		EXEC spa_import_table_template 's', @ixp_table_id, @process_id, 0, @rule_name	
		
		SELECT @new_process_table = table_name FROM #temp_soap_table_name
		
		SELECT @column_lists = COALESCE(@column_lists + ',', '') + '['+c.name+']'
		FROM adiha_process.sys.columns c WITH(NOLOCK)
		INNER JOIN adiha_process.sys.objects o WITH(NOLOCK) ON  c.object_id = o.object_id 
		WHERE o.[name] = REPLACE(@process_table, 'adiha_process.dbo.', '')
		
		SET @sql = 'INSERT INTO ' + @new_process_table + '(' + @column_lists + ')
					SELECT ' + @column_lists + ' FROM ' + @process_table 
					
		exec spa_print @sql
		EXEC(@sql)
		
		SELECT @rule_id = ixp_rules_id FROM ixp_rules ir WHERE ir.ixp_rules_name = @rule_name
		
		SET @desc = @rule_id + ',' + dbo.FNAGetNewID()
		
		EXEC spa_ErrorHandler 0,  
				'Deal Interface',  
				'spa_ixp_soap_error_handler',  
				'Success',  
				@new_process_table,  
				@desc
	END TRY
	BEGIN CATCH
		DECLARE @err_no INT
	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to transfer data. ( Errr Description:' + ERROR_MESSAGE() + ').'
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler -1,  
			 'Deal Interface',  
			 'spa_ixp_soap_error_handler',  
			 'Success',  
			 @desc,  
			 ''
	END CATCH
END
ELSE IF @flag = 'r' -- return rule name and table name for operation
BEGIN
	
	IF OBJECT_ID('tempdb..#privileged_rule') IS NOT NULL
		DROP TABLE #privileged_rule
	CREATE TABLE #privileged_rule (
		import_function VARCHAR(2000)
	)

	INSERT INTO #privileged_rule (import_function)
	EXEC spa_ixp_rules @flag = '1'
	
	SELECT DISTINCT MAX(ir.ixp_rules_name) [RuleName], MAX(it.ixp_tables_name) [TableName],
		MIN(ir.is_active) [IsActive],
		CASE WHEN MAX(tmp.import_function) IS NULL THEN 0 ELSE 1 END [HasPrivilege]
    FROM  ixp_import_data_source iids
    INNER JOIN ixp_rules ir ON iids.rules_id = ir.ixp_rules_id
    INNER JOIN ixp_export_tables iet ON iet.ixp_rules_id = ir.ixp_rules_id   
    INNER JOIN ixp_tables it ON it.ixp_tables_id = iet.table_id
	LEFT JOIN #privileged_rule tmp ON tmp.import_function = iids.ws_function_name
    WHERE iids.ws_function_name = @soap_function_name   
END

--DECLARE @ixp_table_id INT
--DECLARE @process_id VARCHAR(300)
--DECLARE @process_table VARCHAR(400)

--SET @process_id = dbo.FNAGetNewID()

--SELECT  @ixp_table_id = it.ixp_tables_id
--FROM   ixp_tables it
--WHERE  it.ixp_tables_name = 'ixp_source_deal_template'

--EXEC spa_import_table_template 'c', @ixp_table_id, @process_id, 0

