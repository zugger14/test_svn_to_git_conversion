

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_rfx_run_sql]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_rfx_run_sql]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---- ============================================================================================================================
-- Create date: 2012-09-06 14:46
-- Author : ssingh@pioneersolutionsglobal.com
-- Description:  Pagiing page for Builds a runnable SQL query  
-- Description:  Pagiing page for Builds a runnable SQL query . Although _dhx version is created for this file, this is currently in use.
               
--Params:
--@paramset_id			INT			 : parameter set ID
--@root_dataset_id		INT			 : root_dataset ID
--@criteria				VARCHAR(MAX) : parmater with their values
--@temp_table_name		VARCHAR(100) : name of temp table
--@display_type			CHAR(1)		 : t = Tabular Display, c = Chart Display 
--@is_refresh			BIT			 : 0 = simply runs the final sql
--									   1 = exports table if export table name is provided 
--									   and run the dependent(parent) report when executing a report that uses 
--									   the exported table as data source
--@eod_call_table		VARCHAR(200)	: Table name to store dataset resultset for EOD call
--@batch_process_id 	VARCHAR(75)		: Process id for Batch processing	
--@batch_report_param	VARCHAR(1000)	: Batch_Report_parameter
---- ============================================================================================================================

CREATE PROCEDURE [dbo].[spa_rfx_run_sql]
	@paramset_id			INT = NULL
	, @component_id			INT = NULL
	, @criteria				VARCHAR(MAX) = NULL
	, @temp_table_name		VARCHAR(100)  = NULL
	, @display_type			CHAR(1)		  = 't' 
    , @runtime_user			VARCHAR(100)  = NULL
	, @is_html				CHAR(1)		  = 'y'
	, @is_refresh			BIT			  = 0
	, @eod_call_table		VARCHAR(200)  = NULL
	, @batch_process_id 	VARCHAR(75)   = NULL	
	, @batch_report_param	VARCHAR(1000) = NULL
	
AS
SET NOCOUNT ON -- NOCOUNT is set ON since returning row count has side effects on exporting table feature
	
IF ISNULL(@runtime_user, '') <> '' AND @runtime_user <> dbo.FNADBUser()   
BEGIN
	--EXECUTE AS USER = @runtime_user;
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), @runtime_user)
	SET CONTEXT_INFO @contextinfo
END

/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
 DECLARE
	@paramset_id			INT = 64111
	, @component_id			INT = 63093
	, @criteria				VARCHAR(MAX) = 'C0_INTERFACE=vvv'
	, @temp_table_name		VARCHAR(100)  = NULL
	, @display_type			CHAR(1)		  = 't' 
    , @runtime_user			VARCHAR(100)  = 'surendrabasnet'
	, @is_html				CHAR(1)		  = 'y'
	, @is_refresh			BIT			  = 1
	, @eod_call_table		VARCHAR(200)  = NULL
	, @batch_process_id 	VARCHAR(75)   = NULL	
	, @batch_report_param	VARCHAR(1000) = NULL

	
--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/

DECLARE @sql NVARCHAR(MAX)
DECLARE @str_batch_table VARCHAR(MAX)
DECLARE @sql1 VARCHAR(MAX)


/*
DETECTED UNSAVED COLUMNS THAT ARE ADDED ON VIEW AS FILTERS AND MAKE THEM PARTICIPATE ON REPORT FILTER STRING SO THAT REPORT COULD RUN SUCCESSFULLY.
-START
*/
declare @unsaved_cols_string varchar(5000)
SELECT @unsaved_cols_string = STUFF(
	(SELECT ','  + dsc.name + '=NULL'
	
from report_dataset_paramset rdp 
inner join report_dataset rd on rd.report_dataset_id = rdp.root_dataset_id
inner join data_source_column dsc on dsc.source_id = rd.source_id

inner join report_datatype rdt ON rdt.report_datatype_id = dsc.datatype_id
inner join report_widget rwt ON rwt.report_widget_id = dsc.widget_id
inner JOIN data_source ds on ds.data_source_id = dsc.source_id
left join report_param rp on rp.column_id = dsc.data_source_column_id and rp.dataset_paramset_id = rdp.report_dataset_paramset_id
where rdp.paramset_id = 40531
	and dsc.required_filter is not null --valid value for required filter are null,0,1 [null=normal column,0=filter column optional,1=filter column mandatory]
	and rp.column_id is null
	FOR XML PATH(''))
, 1, 1, '')
/*
-END
*/

set @criteria = @criteria + isnull(',' + @unsaved_cols_string,'')

SET @criteria = dbo.FNAURLDecode(@criteria) --decode escaped characters
SET @criteria = [dbo].FNAReplaceDYNDateParam(@criteria)
SET @is_refresh = 1 -- Always populate export table if export table is defined.

/*
--@navaraj: 2018-04-10
-- Added to enable call_from for power bi report
*/
DECLARE @call_from VARCHAR(10) = ''
IF @is_html = 'p'
BEGIN
	SET @call_from = 'powerbi'
	SET @is_html = 'y'
END

BEGIN TRY
/*
--@bbajracharya: 2017-03-10
Transaction has been turned off for following reasons:

1. Since it is reporting query only and doesn't alter database state, transaction is not much necessary.
2. More than that, few view gave issues (e.g. Standard Deal Audit Detail View). The view uses spa_Create_Deal_Audit_Report, which has following queries for UDF

FETCH NEXT FROM cur_status INTO @temp_udf_template_id, @sql_string
WHILE @@FETCH_STATUS = 0
BEGIN
		
	BEGIN TRY	
		INSERT INTO #map_table(id, VALUE) exec spa_execute_query @sql_string
	END TRY
	BEGIN CATCH
		INSERT INTO #map_table(id, VALUE, state) exec spa_execute_query @sql_string
	END CATCH
		
	UPDATE #map_table SET udf_template_id = @temp_udf_template_id WHERE udf_template_id IS NULL 
		
	FETCH NEXT FROM cur_status INTO @temp_udf_template_id, @sql_string
END;

Due to new feature of static data privilege, query of UDF fields supporting privilege will return 3 fields (id, label, privilege) while those without privilege will return only 2 fields (id, label). Since there wasn't an easy way to determine the no. of columns returned (without much code change), TRY-CATCH feature is used. First 2 field is assumed and if it fails, 3 fields is used in CATCH block.

As discussed in MSDN article #175976, if a TRY-CATCH block is present in a TRANSACTION and if that fails resulting to CATCH block, the transaction goes to uncommittable state and futher write operation or commit operation will fail. The only allowed operation is full ROLLBACK. Since above TRY-CATCH cannot be removed, we have removed TRANSACTION as a workaround.
*/

	--BEGIN TRAN
		IF NOT EXISTS (SELECT 1 FROM report r
						INNER JOIN report_page rpage ON r.report_id = rpage.report_id
						INNER JOIN report_paramset rp ON rpage.report_page_id = rp.page_id
						WHERE rp.report_paramset_id = @paramset_id
						)
		BEGIN
			SELECT 'No report definition found to run! Please contact technical support.' [ERROR]	
			--ROLLBACK TRAN
			RETURN
		END
		

		IF EXISTS (SELECT 1 FROM report_paramset rpm
				INNER JOIN report_page rp ON rpm.page_id = rp.report_page_id
				INNER JOIN report r ON r.report_id = rp.report_id
				WHERE report_paramset_id = @paramset_id AND ISNULL(is_custom_report,0) = 1)
		BEGIN
			
			SELECT @sql = ds.tsql FROM report_paramset rpm
			INNER JOIN report_page rp ON rpm.page_id = rp.report_page_id
			INNER JOIN report r ON r.report_id = rp.report_id
			INNER JOIN report_dataset rds ON rds.report_id = r.report_id
			INNER JOIN data_source ds ON ds.data_source_id = rds.source_id
			WHERE rpm.report_paramset_id = @paramset_id

			DECLARE @final_query VARCHAR(MAX)
			SET @final_query = dbo.FNARFXReplaceReportParams(@sql, @criteria, @paramset_id)
			EXEC(@final_query)

			RETURN
		END

		/*********Check dependencies & run them START******/
		IF @is_refresh = 1
		BEGIN
			DECLARE @user_login_id 	VARCHAR(500) = dbo.fnadbuser()
			DECLARE @dependent_paramset_id		INT 
			DECLARE @dependent_component_id		INT 
			DECLARE @dependent_component_type	CHAR(2) 	
			DECLARE @dependent_export_table_name VARCHAR(1000)
			DECLARE @dependent_final_export_table_name VARCHAR(1000)
			DECLARE @dependent_is_global BIT 
															
			IF OBJECT_ID('tempdb..#dependent_report_parameters_returned') IS NOT NULL
				DROP TABLE #dependent_report_parameters_returned		
	
			CREATE TABLE #dependent_report_parameters_returned
			( 
				dependent_report_paramset_id INT 
				,dependent_report_page_tablix_id INT 
				, dependent_component_type CHAR(2) COLLATE DATABASE_DEFAULT 
				, dependent_export_table_name VARCHAR(1000) COLLATE DATABASE_DEFAULT 
				, dependent_is_global BIT 
				, dependent_column_name VARCHAR(1000) COLLATE DATABASE_DEFAULT 
				, dependent_column_id INT
				, dependent_operator VARCHAR(100) COLLATE DATABASE_DEFAULT 
				, dependent_initial_value VARCHAR(4000) COLLATE DATABASE_DEFAULT 
				, dependent_initial_value2 VARCHAR(4000) COLLATE DATABASE_DEFAULT 
				, dependent_optional VARCHAR(100) COLLATE DATABASE_DEFAULT  
				, dependent_hidden VARCHAR(100) COLLATE DATABASE_DEFAULT 
				, dependent_logical_operator VARCHAR(100) COLLATE DATABASE_DEFAULT 
				, dependent_param_order VARCHAR(100) COLLATE DATABASE_DEFAULT 
				, dependent_param_depth VARCHAR(100) COLLATE DATABASE_DEFAULT 
				, dependent_label VARCHAR(255) COLLATE DATABASE_DEFAULT 
			)
			--dump parent(paramset_id ,component_id,export_table_name , is global) Of the paramset
			EXEC spa_rfx_get_dependent_parameters @paramset_id, NULL, NULL, @sql OUTPUT
			INSERT INTO #dependent_report_parameters_returned
			EXEC(@sql)

			
			
			DECLARE cur_run_sql_dependent_reports CURSOR LOCAL FOR 
			SELECT
					dependent_report_paramset_id
				,dependent_report_page_tablix_id 
				, dependent_component_type
				, dependent_export_table_name 
				, dependent_is_global 
			FROM #dependent_report_parameters_returned
			
			OPEN cur_run_sql_dependent_reports   
			FETCH NEXT FROM cur_run_sql_dependent_reports INTO @dependent_paramset_id, @dependent_component_id, @dependent_component_type, @dependent_export_table_name, @dependent_is_global

			WHILE @@FETCH_STATUS = 0   
			BEGIN
				----'report_export_' is appended to identify if the table is being exported within the report.
				SET @dependent_final_export_table_name = '[adiha_process].[dbo].'+ QUOTENAME('report_export_' + @dependent_export_table_name + CASE WHEN @dependent_is_global = 1 THEN ''
										ELSE '_' + ISNULL(@runtime_user, dbo.FNADBUser()) END)
										
				SET @sql = 'IF OBJECT_ID('''+ @dependent_final_export_table_name +''') IS NOT NULL
					DROP TABLE '+ @dependent_final_export_table_name	
				--PRINT @sql
				EXEC(@sql)
					
				EXEC dbo.spa_rfx_build_query @dependent_paramset_id, @dependent_component_id, @criteria, @dependent_final_export_table_name, @dependent_component_type, @is_html, NULL, '', @call_from, @sql OUTPUT 
				SET @sql = 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + @sql
				BEGIN
					EXEC(@sql)
				END	
				
				--Insert the report_export_table into  data_source and data_source_columns table 
				EXEC spa_rfx_export_report_data NULL, NULL, NULL, @dependent_final_export_table_name, @dependent_paramset_id, @dependent_component_id	
				
				
				FETCH NEXT FROM cur_run_sql_dependent_reports INTO @dependent_paramset_id, @dependent_component_id, @dependent_component_type, @dependent_export_table_name, @dependent_is_global
			END 
			CLOSE cur_run_sql_dependent_reports   
			DEALLOCATE cur_run_sql_dependent_reports	

			DECLARE @export_table_name VARCHAR(1000)
			DECLARE @final_export_table_name VARCHAR(1000)
			DECLARE @is_global BIT 
		
			SELECT  @export_table_name = rpt.export_table_name, @is_global = rpt.is_global
			FROM report_paramset rp
			INNER JOIN report_page_tablix rpt ON  rpt.page_id = rp.page_id 
			WHERE report_paramset_id = @paramset_id
				AND rpt.report_page_tablix_id = @component_id
			
			--'report_export_' is appended to identify if the table is being exported within the report.
			SELECT @final_export_table_name = '[adiha_process].[dbo].'+ QUOTENAME('report_export_' + @export_table_name + CASE WHEN @is_global = 1 THEN ''
									ELSE '_' + ISNULL(@runtime_user, dbo.FNADBUser()) END)
									
			SET @sql = 'IF OBJECT_ID('''+ @final_export_table_name +''') IS NOT NULL
				DROP TABLE '+ @final_export_table_name	
			--PRINT @sql
			EXEC(@sql)	
			
			--Export to TABLE 
			IF nullif(@export_table_name, '') IS NOT NULL
			BEGIN
				EXEC dbo.spa_rfx_build_query @paramset_id, @component_id, @criteria, @final_export_table_name, @display_type, @is_html, @batch_process_id, '',@call_from, @sql OUTPUT 
				SET @sql = 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + @sql
				BEGIN
					EXEC(@sql)
				END	
				
				--Insert the report_export_table into  data_source and data_source_columns table 
				EXEC spa_rfx_export_report_data NULL, NULL, NULL, @final_export_table_name, @paramset_id, @component_id	
			END
			
			
		END 
		
		/*********Check dependencies & run them END******/
		--ELSE
		--BEGIN
			
			--run the actaul report FOR HTML mode
			IF @paramset_id <> 54775
				EXEC dbo.spa_rfx_build_query @paramset_id, @component_id, @criteria, @temp_table_name, @display_type, @is_html, @batch_process_id, @batch_report_param,@call_from, @sql OUTPUT 
			
			--SET Value to ON to fix incorrect setting 'QUOTED_IDENTIFIER'
			IF @eod_call_table IS NOT NULL
			BEGIN
				SET @sql1 = 'IF OBJECT_ID('''+ @eod_call_table +''') IS NOT NULL
				DROP TABLE '+ @eod_call_table	
				EXEC(@sql1)
				
				SET @sql = REPLACE(@sql,'FROM adiha_process.dbo.report_dataset_', ' INTO ' + @eod_call_table + ' FROM adiha_process.dbo.report_dataset_')
				--EXEC spa_print @sql
				EXEC(@sql)
			END
			ELSE 
			BEGIN
				SET @sql = 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + @sql

				EXEC(@sql)
			END

			-- Deleting Process table which is used for displaying data in View Report. After data is shown this table can be deleted.
			BEGIN TRY
				DECLARE @process_table_final1 VARCHAR(200)
				DECLARE @process_table_final VARCHAR(1000) = SUBSTRING(@sql, CHARINDEX('FROM', @sql) + 4, ((CHARINDEX('WHERE', @sql) - 5) - CHARINDEX('FROM', @sql)))
				SELECT TOP 1 @process_table_final1 = item FROM dbo.FNASplit(@process_table_final, '[')
				--SELECT TOP 1 @process_table_final1 = item FROM dbo.FNASplit(@process_table_final1, 'dbo.') WHERE item NOT LIKE 'adiha_process%'

				SET @process_table_final1 = REPLACE(RTRIM(LTRIM(@process_table_final1)), 'adiha_process.dbo.', '')

				-- Clean up Process Tables Used after the scope is completed when Debug Mode is Off.
				DECLARE @debug_mode VARCHAR(128) = REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, '')

				IF ISNULL(@debug_mode, '') <> 'DEBUG_MODE_ON'
				BEGIN
					EXEC dbo.spa_clear_all_temp_table NULL, @process_table_final1
				END
			END TRY
			BEGIN CATCH
				EXEC spa_print @sql
			END CATCH
		
	--COMMIT TRAN
END TRY
BEGIN CATCH
	--IF @@TRANCOUNT > 0
	--		ROLLBACK TRAN
	--PRINT 'ERROR: ' + ERROR_MESSAGE()
	
	--Raise error to let the SQL Agent job that this job failed. The failed job triggers another job which updates the 
	--message board error message.
	RAISERROR ('Error executing SQL.', 16, 1);
END CATCH
GO