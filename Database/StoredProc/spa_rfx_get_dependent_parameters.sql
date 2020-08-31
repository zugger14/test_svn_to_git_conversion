
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].spa_rfx_get_dependent_parameters') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].spa_rfx_get_dependent_parameters
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Create date: 2012-09-06 14:46
-- Author : ssingh@pioneersolutionsglobal.com
-- Description: Builds a runnable SQL query from a Report Writer Report 
               
--Params:
--@paramset_id			INT			  : parameter set ID of the dependent report
--@flag			CHAR(2)= NULL : returns the paramset ID , component id of the Parent report
--							p : called to load the adiha process table instead of physical table and to get report_param properties
--								such as optional,hidden of the Parent paramset.
--@process_id	VARCHAR(200) = process_id
--@final_sql			VARCHAR(MAX) OUTPUT : final runnable sql query returned 
-- ============================================================================================================================

CREATE PROCEDURE [dbo].spa_rfx_get_dependent_parameters
	@paramset_id	INT
	, @flag			CHAR(2)= NULL
	, @process_id	VARCHAR(200) = NULL
	, @final_sql		VARCHAR(MAX) OUTPUT
AS

--/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
 DECLARE
	@paramset_id	INT
	, @flag			CHAR(2)= NULL
	, @process_id	VARCHAR(200) = NULL
	, @final_sql		VARCHAR(MAX) --OUTPUT
	
set @paramset_id	= 5021
--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/
BEGIN
	DECLARE @rfx_report_page                  VARCHAR(200)
	DECLARE @rfx_report_dataset               VARCHAR(200)
	DECLARE @rfx_report_page_tablix           VARCHAR(200)
	DECLARE @rfx_report_paramset              VARCHAR(200)
	DECLARE @rfx_report_dataset_paramset      VARCHAR(200)
	DECLARE @rfx_report_param                 VARCHAR(200)
	
	DECLARE @sql							  VARCHAR(MAX)
	DECLARE @user_name						  VARCHAR(200) = dbo.FNADBUser()

	IF @flag = 'p'
	BEGIN
	/*
	* Adiha process table are required to initialize the report manager tables when the report is being created.
	* while the @flag = p we need to extract the export table name that is going to be used for building the report.
	* 
	* */
		SET @rfx_report_page                 = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
		SET @rfx_report_dataset              = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
		SET @rfx_report_page_tablix          = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
		SET @rfx_report_paramset             = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id)
		SET @rfx_report_dataset_paramset     = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
		SET @rfx_report_param                = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
	END
	ELSE 
	BEGIN
	/*
	* For Actually running the dependent report we must extract data from the physical tables.
	* */
		SET @rfx_report_page                 = 'report_page'    
		SET @rfx_report_dataset              = 'report_dataset'
		SET @rfx_report_page_tablix          = 'report_page_tablix'
		SET @rfx_report_paramset             = 'report_paramset'
		SET @rfx_report_dataset_paramset     = 'report_dataset_paramset'
		SET @rfx_report_param                = 'report_param'
	END	
	
	SET @sql = '
	IF OBJECT_ID(''tempdb..#dependent_datasource_names'') IS NOT NULL
				DROP TABLE #dependent_datasource_names
				
	IF OBJECT_ID(''tempdb..#dependent_report_parameters'') IS NOT NULL
				DROP TABLE #dependent_report_parameters				
				
	CREATE TABLE #dependent_datasource_names
	( 
		data_source_id INT 
		, data_source_name VARCHAR(100) COLLATE DATABASE_DEFAULT
		, [TYPE_ID] INT
	)
	
	CREATE TABLE #dependent_report_parameters
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
	
	/*
	*Load all table type Dependencies of that paramset
	*/
	
	INSERT INTO  #dependent_datasource_names 
	SELECT 
	ds.data_source_id, ds.name, ds.[type_id]
	FROM ' + @rfx_report_paramset + ' rp
	INNER JOIN ' + @rfx_report_page_tablix + ' rpt ON rpt.page_id =  rp.page_id
	INNER JOIN ' + @rfx_report_page + ' rpage  ON rpage.report_page_id = rp.page_id
	INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_id = rpage.report_id
	AND rpt.root_dataset_id = ISNULL(rd.root_dataset_id, rd.report_dataset_id)
	INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
	AND ds.[type_id] = 3
	WHERE rp.report_paramset_id = ' + CAST(@paramset_id AS VARCHAR(8000)) + '
	UNION
	SELECT 
	ds.data_source_id, ds.name, ds.[type_id]
	FROM report_paramset rp
	INNER JOIN ' + @rfx_report_page_tablix + ' rpt ON rpt.page_id =  rp.page_id
	INNER JOIN ' + @rfx_report_page + ' rpage ON rpage.report_page_id = rp.page_id
	INNER JOIN ' + @rfx_report_dataset +' rd ON rd.report_id = rpage.report_id
	INNER JOIN ' + @rfx_report_dataset +' rd_sql_src ON rd_sql_src.report_id = rd.report_id	
	AND rpt.root_dataset_id = ISNULL(rd_sql_src.root_dataset_id, rd_sql_src.report_dataset_id)
	INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
	CROSS APPLY (
	/*
	* Search in sql sourceof SQL View for occurences of tables (e.g. SELEcT * FROM {tblname})
	*/
	SELECT ds_sql_src.*
	FROM data_source ds_sql_src
	WHERE ds_sql_src.[type_id] = 2
	AND rd.report_dataset_id <> rd_sql_src.report_dataset_id
	AND rd_sql_src.source_id = ds_sql_src.data_source_id
	AND CHARINDEX(''{'' + rd.alias + ''}'', ds_sql_src.tsql, 1) > 0 
	AND ds.[type_id] = 3
	) sql_table_src
	WHERE rp.report_paramset_id = ' + CAST(@paramset_id AS VARCHAR(8000)) + '

	INSERT  into #dependent_report_parameters
	SELECT TOP 1 
	rp.report_paramset_id
	, rpt.report_page_tablix_id
	, ''t'' AS component_type
	, rpt.export_table_name
	, rpt.is_global
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
	, NULL
	FROM #dependent_datasource_names dds
	INNER JOIN ' + @rfx_report_dataset +' rd ON rd.source_id = dds.data_source_id
	INNER JOIN report_page_tablix rpt ON rpt.export_table_name = REPLACE(
													REPLACE(dds.data_source_name, ''[adiha_process].[dbo].[report_export_'', '''')
												, '']''
												, '''')
	INNER JOIN report_paramset rp ON rp.page_id = rpt.page_id
	ORDER BY rp.report_paramset_id 
	'
	
	IF @flag = 'p'
	BEGIN
		/*
		* List out all the column along with their report_param properties of the top 1 report_paramset_id only
		* Here all the data is extracted from the physical tables as we need to extract data of the dependent report whose values are 
		* already stored.
		*/
		SET @sql = @sql + 
		'
		DECLARE @dependent_paramset_id INT 
		SELECT @dependent_paramset_id = dependent_report_paramset_id FROM #dependent_report_parameters
		
		INSERT INTO  #dependent_report_parameters
		SELECT 
		rp.report_paramset_id
		, rpt.report_page_tablix_id
		, ''t'' AS component_type
		, rpt.export_table_name
		, rpt.is_global
		, dsc.name 
		, dsc.data_source_column_id 
		, rparam.operator 
		, rparam.initial_value 
		, rparam.initial_value2 
		, rparam.optional  
		, rparam.hidden 
		, rparam.logical_operator 
		, rparam.param_order 
		, rparam.param_depth 
		, rparam.label 
		FROM #dependent_datasource_names dds
		INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.source_id = dds.data_source_id
		INNER JOIN report_page_tablix rpt ON rpt.export_table_name = REPLACE(
														REPLACE(dds.data_source_name, ''[adiha_process].[dbo].[report_export_'', '''')
													, '']''
													, '''')
		INNER JOIN report_paramset rp ON rp.page_id = rpt.page_id
		INNER JOIN  report_dataset_paramset rdp ON rdp.paramset_id = rp.report_paramset_id
		INNER JOIN report_param rparam ON rparam.dataset_paramset_id = rdp.report_dataset_paramset_id
		INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rparam.column_id 
		WHERE rp.report_paramset_id = @dependent_paramset_id
		ORDER BY rp.report_paramset_id '
	END
	

--Return all the report_paramset values 
	SELECT @final_sql = @sql 
	+ 
	'SELECT 
			dependent_report_paramset_id  
			,dependent_report_page_tablix_id  
			, dependent_component_type 
			, dependent_export_table_name 
			, dependent_is_global  
			, dependent_column_name 
			, dependent_column_id 
			, dependent_operator 
			, dependent_initial_value 
			, dependent_initial_value2 
			, dependent_optional 
			, dependent_hidden 
			, dependent_logical_operator 
			, dependent_param_order 
			, dependent_param_depth 
			, dependent_label 
	FROM  #dependent_report_parameters'
END			
