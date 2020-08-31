IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_rfx_run_sql_dhx]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_rfx_run_sql_dhx]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---- ============================================================================================================================
-- Create date: 2012-09-06 14:46
-- Author : ssingh@pioneersolutionsglobal.com
-- Description: Pagiing page for Builds a runnable SQL query  
               
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
--@batch_process_id 	VARCHAR(75)		: Process id for Batch processing	
--@batch_report_param	VARCHAR(1000)	: Batch_Report_parameter
---- ============================================================================================================================

CREATE PROCEDURE [dbo].[spa_rfx_run_sql_dhx]
	@paramset_id			VARCHAR(10) = NULL
	, @component_id			VARCHAR(10) = NULL
	, @criteria				VARCHAR(MAX) = NULL
	, @temp_table_name		VARCHAR(100)  = NULL
	, @display_type			CHAR(1)		  = 't' 
    , @runtime_user			VARCHAR(100)  = NULL
	, @is_html				CHAR(1)		  = 'y'
	, @is_refresh			BIT			  = 0
	, @batch_process_id 	VARCHAR(75)   = NULL	
	, @batch_report_param	VARCHAR(1000) = NULL
	, @process_id			VARCHAR(50)	  = NULL
	
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
	@paramset_id			VARCHAR(10) = NULL
	, @component_id			VARCHAR(10) = NULL
	, @criteria				VARCHAR(5000) = NULL
	, @temp_table_name		VARCHAR(100)  = NULL
	, @display_type			CHAR(1)		  = 't' 
    , @runtime_user			VARCHAR(100)  = NULL
	, @is_html				CHAR(1)		  = 'y'
	, @is_refresh			BIT			  = 0
	, @batch_process_id 	VARCHAR(75)   = NULL	
	, @batch_report_param	VARCHAR(1000) = NULL
	, @process_id			VARCHAR(50)	  = NULL

	select @paramset_id=1,@component_id=1,@criteria='sub_id=122,stra_id=123,book_id=124,sub_book_id=23',@process_id='DD2CB3AB_75D4_40FC_8063_6066DEAD109F'
--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/

DECLARE @sql NVARCHAR(MAX)
DECLARE @str_batch_table VARCHAR(MAX)

SET @criteria = dbo.FNAURLDecode(@criteria) --decode escaped characters
DECLARE @sqln NVARCHAR(MAX), @report_def_exist INT = 0

DECLARE @user_name				VARCHAR(50) = dbo.FNADBUser()
DECLARE @rfx_report				VARCHAR(200) = dbo.FNAProcessTableName('report', @user_name, @process_id)
DECLARE @rfx_report_page		VARCHAR(200) = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
DECLARE @rfx_report_paramset	VARCHAR(200) = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id)

--BEGIN TRY
/*
--@bbajracharya: 2017-03-17
Transaction has been turned off for following reasons:

1. Since it is reporting query only and doesn't alter database state, transaction is not much necessary.
2. More than that, few view gave issues while previewing (e.g. Standard Deal Audit Detail View). The view uses spa_Create_Deal_Audit_Report, which has following queries for UDF

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
		SET @sqln = '
		SELECT  @report_def_exist = 1 FROM ' + @rfx_report + ' r
		INNER JOIN ' + @rfx_report_page + ' rpage ON r.report_id = rpage.report_id
		INNER JOIN ' + @rfx_report_paramset + ' rp ON rpage.report_page_id = rp.page_id
		WHERE rp.report_paramset_id = ' + @paramset_id + '
		'
		EXEC sp_executesql @sqln, N'@report_def_exist INT OUTPUT', @report_def_exist OUT
		
		IF @report_def_exist = 0		
		BEGIN
			SELECT 'No report definition found to run! Please contact technical support.' [ERROR]	
			--ROLLBACK TRAN
			RETURN
		END
		--run the actaul report FOR HTML mode
		EXEC dbo.spa_rfx_build_query_dhx @paramset_id, @component_id, @criteria, @temp_table_name, @display_type, @is_html, @batch_process_id, @batch_report_param, @sql OUTPUT, @process_id 
			
		--SET Value to ON to fix incorrect setting 'QUOTED_IDENTIFIER'
		SET @sql = 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + @sql
			
			
		BEGIN
			EXEC(@sql)
		END
		
	--COMMIT TRAN
--END TRY
--BEGIN CATCH
--	IF @@TRANCOUNT > 0
--			ROLLBACK TRAN
--	--PRINT 'ERROR: ' + ERROR_MESSAGE()
	
--	--Raise error to let the SQL Agent job that this job failed. The failed job triggers another job which updates the 
--	--message board error message.
--	RAISERROR ('Error executing SQL.', 16, 1);
--END CATCH