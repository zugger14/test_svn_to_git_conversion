
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_rfx_export_report_data]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_rfx_export_report_data]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: Bidur, Sajag, Samikhsya
-- Create date: 2012-04-13
-- Description: Exports Report Manager report data into process table, data_source table and data_source_column table.
 
-- Params:
-- @batch_unique_id VARCHAR(20) - dynamic paraam:
--								  1. PROCESS_ID:
--								  Will be replaced by newly generated process_id, 
--								  This will help not to repeat the same process_id for recurring job.
-- @export_process_id VARCHAR(100) - Report table process ID
-- @export_table_name_suffix VARCHAR(200)- Table suffix name 
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_rfx_export_report_data]
   @batch_unique_id				VARCHAR(20) = NULL
   , @export_process_id			VARCHAR(100) = NULL
   , @export_table_name_suffix	VARCHAR(200) = NULL
   , @report_export_table_name  VARCHAR(200) = NULL
   , @report_export_paramset_id INT = NULL
   , @report_export_component_id INT = NULL
AS
SET NOCOUNT ON
BEGIN
	--SET NOCOUNT ON;
	
	DECLARE @user_login_id				VARCHAR(100)
	DECLARE @export_table_name			VARCHAR(200)
	DECLARE @export_table_alias_name	VARCHAR(75)
	DECLARE @export_table_full_name		VARCHAR(250)
	DECLARE @batch_process_table_name	VARCHAR(250)
	DECLARE @sql						VARCHAR(MAX)
				
	SELECT @user_login_id = user_login_id, @export_table_name = export_table_name 
	FROM batch_process_notifications 
	WHERE [process_id] = @batch_unique_id
	
	SET @export_table_alias_name = REPLACE(@export_table_name, ' ', '_')
	SET @export_table_full_name = '[adiha_process].[dbo].'+ QUOTENAME('batch_export_' + @export_table_name + ISNULL(' - ' + NULLIF(@export_table_name_suffix, ''), ''))
	SET @batch_process_table_name = dbo.FNAProcessTableName('batch_report', @user_login_id, @export_process_id)
		
	--check if the table to export already exists and used by any reports
	
	IF EXISTS (SELECT 1, dsc.data_source_column_id,rtc.report_tablix_column_id
			   FROM data_source ds
			   INNER JOIN data_source_column dsc ON dsc.source_id = ds.data_source_id
			   LEFT  JOIN report_tablix_column rtc ON rtc.column_id = dsc.data_source_column_id
			   LEFT JOIN report_chart_column rcc ON rcc.column_id = dsc.data_source_column_id
					--uncoment if the report gauge has been applied
					--LEFT JOIN report_gauge_column rtc ON rtc.column_id = dsc.data_source_column_id 
			   WHERE ds.[type_id] = 3 AND ds.name = @export_table_full_name
					AND (rtc.report_tablix_column_id IS NOT NULL OR rcc.report_chart_column_id IS NOT NULL)					
	)
	
	BEGIN
		--write in msgboard	
		DECLARE @new_report_name VARCHAR(100)			
		SET @new_report_name = ISNULL(@new_report_name, 'BatchReport')	
		DECLARE @msg VARCHAR(500)
		SET @msg = 'The exported table <b>''' +  @export_table_name + ISNULL(' - ' + NULLIF(@export_table_name_suffix, ''), '') + '''</b> could not be saved as it has dependent reports.'
		EXEC spa_message_board 'i', @user_login_id, NULL, @new_report_name, @msg, NULL, NULL, 's', NULL, NULL, @export_process_id, DEFAULT, 'n'			
		--return to avoid further processing
		RETURN
	END
	
	-- delete the existing process table
	SET @sql = 'IF OBJECT_ID(N''' + @batch_process_table_name + ''', N''U'') IS NOT NULL 
				BEGIN
					--drop table before creating export table
					IF OBJECT_ID(N''' + @export_table_full_name + ''', N''U'') IS NOT NULL
						DROP TABLE ' + @export_table_full_name + '
						 
					--copy from batch process table to export table
					SELECT * INTO ' + @export_table_full_name + ' FROM ' + @batch_process_table_name + '
				END' 		
	EXEC spa_print @sql	
	EXEC(@sql)
	
	--Insert the report_export_table into  data_source and data_source_columns table 
	IF @report_export_table_name IS NOT NULL AND @report_export_paramset_id IS NOT NULL AND @report_export_component_id IS NOT NULL
	BEGIN
		SET @export_table_full_name = @report_export_table_name
		SET @export_process_id = dbo.FNAGetNewID()
		
		SELECT  @export_table_name = rpt.export_table_name
			FROM report_paramset rp
			INNER JOIN report_page_tablix rpt ON  rpt.page_id = rp.page_id 
			WHERE report_paramset_id = @report_export_paramset_id
				AND rpt.report_page_tablix_id = @report_export_component_id
	END
	
	/*  --Used for Batch table export
	--delete from report_dataset_relationship
	DELETE rdr 
	FROM data_source ds
	INNER JOIN report_dataset rd ON rd.source_id = ds.data_source_id
	INNER JOIN report_dataset_relationship rdr ON (rdr.from_dataset_id = rd.report_dataset_id 
		OR rdr.to_dataset_id = rd.report_dataset_id)
	WHERE ds.name = @export_table_full_name
		AND ds.[type_id] = 3
		
	 --delete from report_dataset table
	DELETE rd 
	FROM report_dataset rd
	INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
	WHERE ds.name = @export_table_full_name
		AND ds.[type_id] = 3
		
	 --delete from data_source_column table
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON dsc.source_id = ds.data_source_id
	WHERE ds.name = @export_table_full_name
		AND ds.[type_id] = 3
	 
	--delete from data_source table 
	DELETE FROM data_source
	WHERE name = @export_table_full_name
		AND [TYPE_ID] = 3	
	*/			
	
	DECLARE @export_table_alias_seq		VARCHAR(25)	
	DECLARE @export_table_alias			VARCHAR(250)
	
	--generates the abbreviation of the table name for the alias
	SET @export_table_alias = dbo.FNARFXGenerateAliasFromName(@export_table_name + ISNULL('_' + NULLIF(@export_table_name_suffix, ''), ''))
				
	--generate unique alias
	--normalize string value to fixed 10 length, so that they can be sorted in numeric fashion
	--finds the MAX alias sequence number
	SELECT @export_table_alias_seq = MAX(RIGHT('0000000000' + (REPLACE(ALIAS, @export_table_alias, '')), 10))
		-- AS search, (REPLACE(alias, @export_table_name, '')) after_replace, (RIGHT ('0000000000' + (REPLACE(alias, @export_table_name_clean, '')), 10)) extracted_seq 
	FROM data_source ds
	WHERE 1 = 1 --[type_id] = 3		
		AND ISNUMERIC(RIGHT('0000000000' + (REPLACE(ALIAS, @export_table_alias, '')), 10)) > 0	--filter non-numeric extracted seq	
				
	--increments +1 if there exists same named alias				 
	IF ISNUMERIC(@export_table_alias_seq) > 0
		SELECT @export_table_alias_seq = CAST(CAST(@export_table_alias_seq AS INT) + 1 AS VARCHAR(25))			
	
	SET @export_table_alias = @export_table_alias + ISNULL(@export_table_alias_seq, '')
	
	--select @export_table_alias 
	--RETURN
	
	IF OBJECT_ID('tempdb..#temp_export_data_source') IS NOT NULL
	DROP TABLE #temp_export_data_source

	IF OBJECT_ID('tempdb..#temp_export_table_column') IS NOT NULL
	DROP TABLE #temp_export_table_column
					
	CREATE TABLE #temp_export_data_source([TYPE_ID] INT
	, [name] VARCHAR(500) COLLATE DATABASE_DEFAULT 
	, ALIAS VARCHAR(500) COLLATE DATABASE_DEFAULT 
	, [description]VARCHAR(500) COLLATE DATABASE_DEFAULT 
	, [tsql] VARCHAR(500) COLLATE DATABASE_DEFAULT 
	, report_id INT )

	INSERT INTO #temp_export_data_source
	([TYPE_ID], name, ALIAS, [description], [tsql], report_id)
	VALUES (
		3,
		@export_table_full_name,
		@export_table_alias,
		@export_table_full_name,
		'SELECT * FROM ' +  @export_table_full_name,
		NULL
	)

--Merge data source details
	MERGE data_source AS ds
	USING (SELECT * FROM #temp_export_data_source WHERE NAME = @export_table_full_name) AS ds_new
	ON ds.name = ds_new.name 
	WHEN MATCHED THEN UPDATE SET 
		ds.[type_id] = ds_new.[type_id] 
		, ds.[name] = ds_new.[name]
		, ds.alias = ds_new.alias
		, ds.[description] = ds_new.[description]
		, ds.[tsql] = ds_new.[tsql]
		, ds.report_id = ds_new.report_id
	WHEN NOT MATCHED BY target THEN
		INSERT([TYPE_ID], name, ALIAS, [description], [tsql], report_id)
		VALUES (
		3,
		ds_new.name ,
		ds_new.alias ,
		ds_new.[description],
		ds_new.[tsql],
		ds_new.report_id
		);

	DECLARE @current_data_source_id INT
	SET @current_data_source_id = SCOPE_IDENTITY()
	
	DECLARE @data_source_id INT
	SELECT @data_source_id = data_source_id FROM data_source WHERE [name] = @export_table_full_name
	
	/*
	* In case of export from report the filters along with their properties of the parent report must be preserved for the dependent report
	* such that they are auto populated in the parameters of dependent report
	* The comparision of the exported table is done for this with the column name.
	*/
	IF OBJECT_ID('tempdb..#temp_export_reqd_filters') IS NOT NULL
	DROP TABLE #temp_export_reqd_filters	
	
	CREATE TABLE #temp_export_reqd_filters(
	report_paramset_id		INT ,
	paramset_name			VARCHAR(500) COLLATE DATABASE_DEFAULT ,
	datasource_column_id	INT ,
	datasource_column_name	VARCHAR(500) COLLATE DATABASE_DEFAULT ,
	reqd_param				BIT, 
	append_filter       	BIT,
	datatype_id          	INT NULL,
	widget_id            	INT NULL,
	param_default_value  	VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
	param_data_source    	VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
	tooltip              	VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
	column_template	     	INT,
	key_column			 	INT
	)		

	INSERT INTO #temp_export_reqd_filters
	SELECT rps.report_paramset_id,
	rps.[name],
	rp.column_id,
	dsc.[name],
	1 [reqd_param],
	dsc.append_filter,       
	dsc.datatype_id ,        
	dsc.widget_id ,           
	--NULLIF(rp.initial_value, ''),
	dsc.param_default_value,
	dsc.param_data_source ,  
	dsc.tooltip ,            
	dsc.column_template,	    
	dsc.key_column			
	FROM   report_paramset  rps
	LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
	LEFT JOIN report_param rp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
	LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rp.column_id
	LEFT JOIN report_widget rw ON  rw.report_widget_id = dsc.widget_id
	WHERE rps.report_paramset_id = @report_export_paramset_id
	 --SELECT * FROM 	#temp_export_reqd_filters

	CREATE TABLE #temp_export_table_column
	(
		column_id            INT NULL,
		source_id			 INT NULL,
		column_name          VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
		ALIAS                VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
		reqd_param           VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
		append_filter        VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
		data_type            VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
		datatype_id          INT NULL,
		widget_id            INT NULL,
		param_default_value  VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
		param_data_source    VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
		tooltip              VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
		column_template	     INT,
		key_column			 INT
	)	
	INSERT INTO #temp_export_table_column
	SELECT 
		   ds_saved.[column_id],
		   @data_source_id,
		   c.column_name,
		   ISNULL(ds_saved.[alias], c.column_name) [ALIAS],
		   CASE WHEN @report_export_paramset_id IS NOT NULL THEN ISNULL(erf.reqd_param, 0) ELSE ds_saved.[reqd_param] END ,
		  -- ISNULL(erf.reqd_param, ds_saved.[reqd_param]),
		   ISNULL(erf.append_filter, ds_saved.[append_filter]),
		   c.DATA_TYPE [data_type],
		   ISNULL(erf.datatype_id, rdt.report_datatype_id) [datatype_id],
		   ISNULL(erf.widget_id, ds_saved.[widget_id]),
		   ISNULL(erf.param_default_value, ds_saved.[param_default_value]),
		   --CASE WHEN @report_export_paramset_id IS NOT NULL THEN erf.param_default_value ELSE ds_saved.[param_default_value] END ,
		   ISNULL(erf.param_data_source, ds_saved.[param_data_source]),
		   ISNULL(erf.tooltip, ds_saved.tooltip),
		   ISNULL(erf.column_template, ds_saved.column_template),
		   ISNULL(erf.key_column, ds_saved.key_column)
	FROM (
		SELECT COLUMN_NAME,
			   DATA_TYPE
		FROM   adiha_process.INFORMATION_SCHEMA.[COLUMNS]
		WHERE  TABLE_NAME = REPLACE(REPLACE(@export_table_full_name, '[adiha_process].[dbo].[', '') , ']' , '')
	) c 
	INNER JOIN report_datatype rdt ON rdt.name = 
		CASE c.DATA_TYPE
			WHEN 'NCHAR' THEN 'CHAR'
			WHEN 'NVARCHAR' THEN 'VARCHAR'
			WHEN 'TEXT' THEN 'VARCHAR'
			WHEN 'NTEXT' THEN 'VARCHAR'
			WHEN 'XML' THEN 'VARCHAR'
			WHEN 'BIT' THEN 'INT'
			WHEN 'TINYINT' THEN 'INT'
			WHEN 'SMALLINT' THEN 'INT'
			WHEN 'BIGINT' THEN 'INT'
			WHEN 'BINARY' THEN 'INT'
			WHEN 'VARBINARY' THEN 'INT'
			WHEN 'REAL' THEN 'INT'
			WHEN 'DATETIME2' THEN 'DATETIME'
			WHEN 'DATETIMEOFFSET' THEN 'DATETIME'
			WHEN 'SMALLDATETIME' THEN 'DATETIME'
			WHEN 'TIME' THEN 'DATETIME'
			WHEN 'TIMESTAMP' THEN 'DATETIME'
			WHEN 'NUMERIC' THEN 'FLOAT'
			WHEN 'DECIMAL' THEN 'FLOAT'
			WHEN 'MONEY' THEN 'FLOAT'
			WHEN 'SMALLMONEY' THEN 'FLOAT'
			ELSE c.DATA_TYPE			
		END
	LEFT JOIN #temp_export_reqd_filters erf ON erf.datasource_column_name = c.COLUMN_NAME
	LEFT JOIN (
		SELECT dsc.data_source_column_id [column_id],
			   dsc.source_id [source_id],
			   dsc.name [column_name],
			   dsc.alias [ALIAS],
			   dsc.reqd_param [reqd_param],
			   dsc.append_filter [append_filter],
			   dsc.widget_id [widget_id],
			   dsc.param_default_value [param_default_value],
			   dsc.param_data_source [param_data_source],
			   ds.alias AS [source_alias],
			   dsc.tooltip,
			   dsc.column_template,
			   dsc.key_column
		FROM   data_source ds
		INNER JOIN data_source_column dsc ON  ds.data_source_id = dsc.source_id
		WHERE  ds.data_source_id = @data_source_id
	) ds_saved ON ds_saved.column_name = c.COLUMN_NAME
	ORDER BY ds_saved.[alias], c.column_name	
	
	--SELECT * FROM #temp_export_table_column
	--RETURN

--Merge datasource columns 
	MERGE data_source_column AS dsc
	USING (SELECT * FROM #temp_export_table_column) AS dsc_new
	ON dsc.name = dsc_new.column_name 
	AND dsc.source_id = dsc_new.source_id
	WHEN MATCHED THEN UPDATE SET 
		source_id = dsc_new.source_id,
		[name] = dsc_new.column_name,
		[ALIAS] = dsc_new.[alias],
		reqd_param = dsc_new.reqd_param,
		widget_id = dsc_new.widget_id,
		datatype_id = dsc_new.datatype_id,
		param_data_source = dsc_new.param_data_source,
		param_default_value = dsc_new.param_default_value ,
		append_filter = dsc_new.append_filter,
		tooltip = dsc_new.tooltip,
		column_template = dsc_new.column_template,
		key_column = dsc_new.key_column
	WHEN NOT MATCHED BY target THEN
		INSERT(		
		source_id,
		name,
		ALIAS,
		reqd_param,
		widget_id,
		datatype_id,
		param_data_source,
		param_default_value,
		append_filter,
		tooltip,
		column_template,
		key_column
		)	
		VALUES (
		ISNULL(@data_source_id, @current_data_source_id),
		dsc_new.column_name,
		dsc_new.ALIAS,
		ISNULL(dsc_new.reqd_param, '0') ,
		ISNULL(dsc_new.widget_id, 1 ),
		dsc_new.datatype_id,
		dsc_new.param_data_source,
		dsc_new.param_default_value,
		ISNULL(dsc_new.append_filter, 1),
		dsc_new.tooltip,
		dsc_new.column_template,
		dsc_new.key_column
		)
	--WHEN NOT MATCHED BY source AND dsc.source_id = @data_source_id THEN
	--DELETE
	; 
END 
		

--/*	
--	--insert into data_source_column
--	INSERT INTO data_source(			
--		[TYPE_ID],
--		[name],
--		ALIAS,
--		[description],
--		[tsql],
--		report_id
--		)
--	VALUES (
--		3,
--		@export_table_full_name,
--		@export_table_alias,
--		@export_table_full_name,
--		'SELECT * FROM ' + @export_table_full_name,
--		NULL
--	)
	
--	SET @current_data_source_id = SCOPE_IDENTITY()
	
--	DECLARE @export_table_columns VARCHAR(MAX)
	
--	IF OBJECT_ID('tempdb..#temp_export_table_column') IS NOT NULL
--		DROP TABLE #temp_export_table_column
	
--	CREATE TABLE #temp_export_table_column
--	(
--		column_id            INT NULL,
--		column_name          VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
--		ALIAS                VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
--		reqd_param           VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
--		append_filter        VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
--		data_type            VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
--		datatype_id          INT NULL,
--		widget_id            INT NULL,
--		param_default_value  VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
--		param_data_source    VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
--		tooltip              VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
--		column_template	     INT,
--		key_column			 INT
--	)
	
--	--Insert the data source columns into temporary table
--	SET @export_table_columns = 'INSERT INTO #temp_export_table_column EXEC spa_rfx_grab_data_source_columns 0, ''' + @export_process_id + ''' , '''', ''SELECT * FROM ' + @export_table_full_name + ''''
	
--	exec spa_print ISNULL(@export_table_columns, '@export_table_columns IS NULL')
--	EXEC(@export_table_columns)
		
--	--Insert the column info into into data_source_column table
--	INSERT INTO data_source_column 
--	(		
--		source_id,
--		name,
--		ALIAS,
--		reqd_param,
--		widget_id,
--		datatype_id,
--		param_data_source,
--		param_default_value,
--		append_filter,
--		tooltip,
--		column_template
--	)	
--	SELECT @current_data_source_id,
--	       column_name,
--	       ALIAS,
--	       0 [reqd_param],
--		   1 [widget_id],
--		   datatype_id,
--		   param_data_source,
--	       param_default_value,
--	       1 [append_filter],	  
--	       tooltip,
--	       column_template
--	FROM   #temp_export_table_column
--END
--GO
--*/

