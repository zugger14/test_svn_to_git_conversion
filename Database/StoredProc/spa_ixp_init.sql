IF OBJECT_ID(N'[dbo].[spa_ixp_init]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_init]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Init Logic saves all the temporary information of the report to respective temporary tables named.
 
	Parameters
	@flag - Operation flag.
		'c' - Clone Import/Export schemas to Process DB :: Call This on Creating New Report.
		'u' - Update mode the data of each main table is copied into the temp table for the Import/Export rules.
	@process_id CHAR(1) - Operation ID
	@rules_id CHAR(1) - Report ID 
*/

CREATE PROCEDURE [dbo].[spa_ixp_init]
	@flag NCHAR(1),
	@process_id NVARCHAR(100) = NULL,
	@rules_id NVARCHAR(100) = NULL
AS
SET NOCOUNT ON
IF @process_id IS NULL
    SET @process_id = dbo.FNAGetNewID()
DECLARE @err_no                   INT
DECLARE @user_name                NVARCHAR(50) = dbo.FNADBUser()  
DECLARE @sql                      NVARCHAR(MAX)
DECLARE @ixp_rules                NVARCHAR(200)
DECLARE @ixp_data_mapping         NVARCHAR(200)
DECLARE @ixp_export_tables        NVARCHAR(200)
DECLARE @DESC                     NVARCHAR(500)
DECLARE @ixp_import_table         NVARCHAR(400)
DECLARE @ixp_import_data_mapping  NVARCHAR(400)
DECLARE @ixp_import_data_source   NVARCHAR(400)
DECLARE @ixp_import_relation      NVARCHAR(400)
DECLARE @ixp_import_where_clause  NVARCHAR(400)
DECLARE @ixp_export_data_source   NVARCHAR(400)
DECLARE @ixp_export_relation      NVARCHAR(400)
DECLARE @ixp_parameters	  NVARCHAR(400)
DECLARE @ixp_import_filter NVARCHAR(400)

DECLARE @ixp_import_query_builder_tables         NVARCHAR(500)
DECLARE @ixp_import_query_builder_relation       NVARCHAR(600)
DECLARE @ixp_custom_import_mapping               NVARCHAR(500)
DECLARE @ixp_import_query_builder_import_tables  NVARCHAR(600)



-- set names at first as eveery process seems to utilise the adiha_process table names
SET @ixp_rules = dbo.FNAProcessTableName('ixp_rules', @user_name, @process_id)
SET @ixp_data_mapping = dbo.FNAProcessTableName('ixp_data_mapping', @user_name, @process_id)
SET @ixp_export_tables = dbo.FNAProcessTableName('ixp_export_tables', @user_name, @process_id)
SET @ixp_import_data_mapping = dbo.FNAProcessTableName('ixp_import_data_mapping', @user_name, @process_id)
SET @ixp_import_table = dbo.FNAProcessTableName('ixp_import_table', @user_name, @process_id)
SET @ixp_import_data_source = dbo.FNAProcessTableName('ixp_import_data_source', @user_name, @process_id) 
SET @ixp_import_relation = dbo.FNAProcessTableName('ixp_import_relation', @user_name, @process_id)
SET @ixp_import_where_clause = dbo.FNAProcessTableName('ixp_import_where_clause', @user_name, @process_id)
SET @ixp_export_data_source = dbo.FNAProcessTableName('ixp_export_data_source', @user_name, @process_id) 
SET @ixp_export_relation = dbo.FNAProcessTableName('ixp_export_relation', @user_name, @process_id)  
SET @ixp_import_query_builder_tables = dbo.FNAProcessTableName('ixp_import_query_builder_tables', @user_name, @process_id)
SET @ixp_import_query_builder_relation = dbo.FNAProcessTableName('ixp_import_query_builder_relation', @user_name, @process_id)
SET @ixp_custom_import_mapping = dbo.FNAProcessTableName('ixp_custom_import_mapping', @user_name, @process_id) 
SET @ixp_import_query_builder_import_tables = dbo.FNAProcessTableName('ixp_import_query_builder_import_tables', @user_name, @process_id)
SET @ixp_parameters = dbo.FNAProcessTableName('ixp_parameters', @user_name, @process_id)
SET @ixp_import_filter = dbo.FNAProcessTableName('ixp_import_filter', @user_name, @process_id)

-- Clone Import/Export schemas to Process DB :: Call This on Creating New Report
IF @flag = 'c'
BEGIN
	BEGIN TRY
		SET @sql = 'SELECT * INTO ' + @ixp_rules + ' FROM   ixp_rules WHERE  1 = 2
		            SELECT * INTO ' + @ixp_data_mapping + ' FROM   ixp_data_mapping WHERE  1 = 2
		            SELECT * INTO ' + @ixp_export_tables + ' FROM   ixp_export_tables WHERE  1 = 2
		            SELECT * INTO ' + @ixp_import_data_mapping + ' FROM ixp_import_data_mapping WHERE 1 = 2
		            SELECT * INTO ' + @ixp_import_data_source + ' FROM ixp_import_data_source WHERE 1 = 2
		            SELECT * INTO ' + @ixp_import_relation + ' FROM ixp_import_relation WHERE 1 = 2
		            SELECT * INTO ' + @ixp_import_where_clause + ' FROM ixp_import_where_clause WHERE 1 = 2
		            SELECT * INTO ' + @ixp_export_data_source + ' FROM ixp_export_data_source WHERE 1 = 2
		            SELECT * INTO ' + @ixp_export_relation + ' FROM ixp_export_relation WHERE 1 = 2
		            SELECT * INTO ' + @ixp_import_query_builder_tables + ' FROM ixp_import_query_builder_tables WHERE 1 = 2
		            SELECT * INTO ' + @ixp_import_query_builder_relation + ' FROM ixp_import_query_builder_relation WHERE 1 = 2
		            SELECT * INTO ' + @ixp_import_query_builder_import_tables + ' FROM ixp_import_query_builder_import_tables WHERE 1 = 2
		            SELECT * INTO ' + @ixp_custom_import_mapping + ' FROM ixp_custom_import_mapping WHERE 1 = 2
		            SELECT * INTO ' + @ixp_parameters + ' FROM ixp_parameters WHERE 1 = 2
					SELECT * INTO ' + @ixp_import_filter + ' FROM ixp_import_filter WHERE 1 = 2
		            '
            
		--PRINT 'Clone Import/Export schemas to Process DB :: ' + @sql
		exec spa_print @sql
		EXEC (@sql)
		
		EXEC spa_ErrorHandler 0,
             'Import/Export FX',
             'spa_ixp_init',
             'Success',
             'Cloned Import/Export schemas to Process DB.',
             @process_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		IF ERROR_MESSAGE() = 'CatchError'
		   SET @DESC = 'Fail to insert data ( Errr Description:' + @DESC + ').'
		ELSE
		   SET @DESC = 'Fail to insert data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'Import/Export FX'
		   , 'spa_ixp_init'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH	        
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
		SET @sql =  CAST('' AS NVARCHAR(MAX)) + 
					'-----------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_rules + '
					SELECT * INTO ' + @ixp_rules + ' FROM ixp_rules WHERE ixp_rules_id = ' + @rules_id + '
					-----------------------------------------------------------------------------------------------
					
					-----------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_data_mapping + '
					SELECT * INTO ' + @ixp_data_mapping + ' FROM ixp_data_mapping WHERE ixp_rules_id = ' + @rules_id + '
					-----------------------------------------------------------------------------------------------
					
					-----------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_export_tables + '
					SELECT * INTO ' + @ixp_export_tables + ' FROM ixp_export_tables WHERE ixp_rules_id = ' + @rules_id + '
					-----------------------------------------------------------------------------------------------
					--
					-------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_import_data_mapping + '
					SELECT * INTO ' + @ixp_import_data_mapping + ' FROM ixp_import_data_mapping WHERE ixp_rules_id = ' + @rules_id + '
					-----------------------------------------------------------------------------------------------
					
					--------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_import_data_source + '
					SELECT * INTO ' + @ixp_import_data_source + ' FROM ixp_import_data_source WHERE rules_id = ' + @rules_id + '
					--------------------------------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_import_relation + '
					SELECT * INTO ' + @ixp_import_relation + ' FROM ixp_import_relation WHERE ixp_rules_id = ' + @rules_id + '
					----------------------------------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_import_where_clause + '
					SELECT * INTO ' + @ixp_import_where_clause + ' FROM ixp_import_where_clause WHERE rules_id = ' + @rules_id + '
					----------------------------------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_export_data_source + '
					SELECT * INTO ' + @ixp_export_data_source + ' FROM ixp_export_data_source WHERE ixp_rules_id = ' + @rules_id + '
					----------------------------------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_export_relation + '
					SELECT * INTO ' + @ixp_export_relation + ' FROM ixp_export_relation WHERE ixp_rules_id = ' + @rules_id + '
					----------------------------------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_import_query_builder_tables + '
					SELECT * INTO ' + @ixp_import_query_builder_tables + ' FROM ixp_import_query_builder_tables WHERE ixp_rules_id = ' + @rules_id + '
					----------------------------------------------------------------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_import_query_builder_relation + '
					SELECT * INTO ' + @ixp_import_query_builder_relation + ' FROM ixp_import_query_builder_relation WHERE ixp_rules_id = ' + @rules_id + '
					----------------------------------------------------------------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_import_query_builder_import_tables + '
					SELECT * INTO ' + @ixp_import_query_builder_import_tables + ' FROM ixp_import_query_builder_import_tables WHERE ixp_rules_id = ' + @rules_id + '
					----------------------------------------------------------------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_custom_import_mapping + '
					SELECT * INTO ' + @ixp_custom_import_mapping + ' FROM ixp_custom_import_mapping WHERE ixp_rules_id = ' + @rules_id + '
					----------------------------------------------------------------------------------------------------------------------------------------

					----------------------------------------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_import_filter + '
					SELECT * INTO ' + @ixp_import_filter + ' FROM ixp_import_filter WHERE ixp_rules_id = ' + @rules_id + '
					----------------------------------------------------------------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------------------------------------------------------------
					DROP TABLE ' + @ixp_parameters + '
					SELECT isp.* INTO ' + @ixp_parameters + ' 
					FROM ixp_parameters isp
					INNER JOIN ixp_import_data_source iids
						ON ISNULL(iids.ssis_package, -1) = ISNULL(isp.ssis_package, -1)
						AND ISNULL(iids.clr_function_id, -1) = ISNULL(isp.clr_function_id, -1)
					WHERE iids.rules_id = ' + @rules_id + '  AND (iids.ssis_package IS NOT NULL OR iids.clr_function_id IS NOT NULL)
					----------------------------------------------------------------------------------------------------------------------------------------
					'		
		--PRINT(@sql)
		EXEC(@sql)
		
		EXEC spa_ErrorHandler 0,
             'Import/Export FX',
             'spa_ixp_init',
             'Success',
             'Cloned Existing Report schemas and data to Process DB.',
             @process_id
             
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		IF ERROR_MESSAGE() = 'CatchError'
		   SET @DESC = 'Fail to insert data ( Errr Description:' + @DESC + ').'
		ELSE
		   SET @DESC = 'Fail to insert data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'Import/Export FX'
		   , 'spa_ixp_init'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
ELSE IF @flag = 'x'
BEGIN
	EXEC spa_ErrorHandler 0,
             'Import/Export FX',
             'spa_ixp_init',
             'Success',
             'Process Id generated.',
             @process_id
END

GO
