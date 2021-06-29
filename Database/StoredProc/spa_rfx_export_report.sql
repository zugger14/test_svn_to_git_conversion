IF OBJECT_ID(N'[dbo].[spa_rfx_export_report]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_rfx_export_report]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Export/Copy logic for report
	Parameters
	@report_name	:	Name of the report to be exported or copied
	@mode			:	Export mode (e = Export , c = Copy)
	@paramset_names	:	CSV values of names of paramset to be exported
	@process_id		:	Process ID
*/
CREATE PROCEDURE [dbo].[spa_rfx_export_report]
	@report_name	VARCHAR(100),
	@mode					CHAR(2) = 'e', 
	--@page_names			VARCHAR(MAX)= NULL,
	@paramset_names 		VARCHAR(MAX)= NULL,	
	@process_id				VARCHAR(100) = NULL
AS
SET NOCOUNT ON 
/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*

	   SET NOCOUNT ON 
	DECLARE
 	@report_name		VARCHAR(100),
 	@mode				VARCHAR(2),
	@page_names			VARCHAR(MAX) = NULL,
	@paramset_names 	VARCHAR(MAX) = NULL,
	@process_id			VARCHAR(100) = NULL
	
	--SET @report_name = 'counter party'
	--SET @page_names	 = 'counter party ,counter Party page 2'
	--SET @paramset_names = 'counter party  parameter, counter party parameter2, counter party parameter3,Counterparty param page2'
	
	SET @mode = 'e'
	SET @report_name = 'SQL Report  Import test'
	--SET @page_names	 = 'Grouped by Commodity'
	--SET @paramset_names = 'Dashboard,Dashboard with between operator,Default'
	
	IF OBJECT_ID('tempdb..#final_query', 'U') IS NOT NULL
		DROP TABLE #final_query
	IF OBJECT_ID('tempdb..#pages', 'U') IS NOT NULL
		DROP TABLE #pages
	IF OBJECT_ID('tempdb..#paramset', 'U') IS NOT NULL
		DROP TABLE #paramset
--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/
IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()
	    
DECLARE @user_name                        VARCHAR(50) = dbo.FNADBUser()
DECLARE @sql							  VARCHAR(MAX)	    
DECLARE @rfx_report						  VARCHAR(200)
DECLARE @rfx_report_page                  VARCHAR(200)
DECLARE @rfx_report_dataset               VARCHAR(200)
DECLARE @rfx_report_page_chart            VARCHAR(200)
DECLARE @rfx_report_chart_column          VARCHAR(200)
DECLARE @rfx_report_page_tablix           VARCHAR(200)
DECLARE @rfx_report_tablix_column         VARCHAR(200)
DECLARE @rfx_report_tablix_header         VARCHAR(200)
DECLARE @rfx_report_paramset              VARCHAR(200)
DECLARE @rfx_report_dataset_paramset      VARCHAR(200)
DECLARE @rfx_report_param                 VARCHAR(200)
DECLARE @rfx_report_page_textbox          VARCHAR(200)
DECLARE @rfx_report_page_image            VARCHAR(200)
DECLARE @rfx_report_page_line             VARCHAR(200)
DECLARE @rfx_report_page_gauge            VARCHAR(200)
DECLARE @rfx_report_gauge_column          VARCHAR(200)
DECLARE @rfx_report_gauge_column_scale    VARCHAR(200)

IF @mode = 'p'
BEGIN
-- set names at first as eveery process seems to utilise the adiha_process table names
	SET @rfx_report                      = dbo.FNAProcessTableName('report', @user_name, @process_id)
	SET @rfx_report_page                 = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
	SET @rfx_report_dataset              = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
    
    SET @rfx_report_page_tablix          = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
    SET @rfx_report_tablix_column        = dbo.FNAProcessTableName('report_tablix_column', @user_name, @process_id)
    SET @rfx_report_tablix_header        = dbo.FNAProcessTableName('report_tablix_header', @user_name, @process_id)    
    
    SET @rfx_report_page_chart           = dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
    SET @rfx_report_chart_column         = dbo.FNAProcessTableName('report_chart_column', @user_name, @process_id)
    
    SET @rfx_report_paramset             = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id)
    SET @rfx_report_dataset_paramset     = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
    SET @rfx_report_param                = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
    
    SET @rfx_report_page_textbox         = dbo.FNAProcessTableName('report_page_textbox', @user_name, @process_id)
    SET @rfx_report_page_image           = dbo.FNAProcessTableName('report_page_image', @user_name, @process_id)
    SET @rfx_report_page_line            = dbo.FNAProcessTableName('report_page_line', @user_name, @process_id)
    
    SET @rfx_report_page_gauge           = dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)
    SET @rfx_report_gauge_column         = dbo.FNAProcessTableName('report_gauge_column', @user_name, @process_id)
    SET @rfx_report_gauge_column_scale   = dbo.FNAProcessTableName('report_gauge_column_scale', @user_name, @process_id)
END
ELSE 
BEGIN
	SET @rfx_report                      = 'report'
	SET @rfx_report_page                 = 'report_page'    
    SET @rfx_report_dataset              = 'report_dataset'
    
    SET @rfx_report_page_tablix          = 'report_page_tablix'
    SET @rfx_report_tablix_column        = 'report_tablix_column'
    SET @rfx_report_tablix_header        = 'report_tablix_header'
    
    SET @rfx_report_page_chart           = 'report_page_chart'
    SET @rfx_report_chart_column         = 'report_chart_column'
    
    SET @rfx_report_paramset             = 'report_paramset'
    SET @rfx_report_dataset_paramset     = 'report_dataset_paramset'
    SET @rfx_report_param                = 'report_param'
    
    SET @rfx_report_page_textbox         = 'report_page_textbox'
    SET @rfx_report_page_image           = 'report_page_image'
    SET @rfx_report_page_line            = 'report_page_line'
    
    SET @rfx_report_page_gauge           = 'report_page_gauge'
    SET @rfx_report_gauge_column         = 'report_gauge_column'
    SET @rfx_report_gauge_column_scale   = 'report_gauge_column_scale'
END		    

BEGIN 
	DECLARE @report_id_src INT
	
	IF OBJECT_ID('tempdb..#temp_report_id', 'U') IS NOT NULL
		DROP TABLE #temp_report_id
		
	CREATE TABLE #temp_report_id(report_id INT)		
	
	SET @sql = 'INSERT INTO #temp_report_id(report_id)
				SELECT report_id 
				FROM report r
				WHERE r.[name] = ''' + @report_name + ''''
	EXEC(@sql)
	
	SELECT @report_id_src = report_id FROM #temp_report_id	
	
	CREATE TABLE #final_query
	(
		row_id      INT IDENTITY(1, 1),
		line_query  VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
	)
	
	--splitting comma seperated values of page.
	CREATE TABLE #pages(page_name VARCHAR(200) COLLATE DATABASE_DEFAULT)
	
	SET @sql = 'INSERT  INTO #pages(page_name)
				--load all pages of the report if no specific set of pages to export is provided
				SELECT rp.[name]
				FROM report_page rp
				INNER JOIN report r 
					ON r.report_id = rp.report_id
				WHERE r.report_id = ' + CAST(@report_id_src AS VARCHAR(10))+'
				'
	EXEC(@sql)	
			
	--splitting comma seperated values of paramset names.
	CREATE TABLE #paramset(paramset_name VARCHAR(200) COLLATE DATABASE_DEFAULT)
	
	SET @sql = 'INSERT INTO #paramset(paramset_name)
				SELECT item FROM dbo.splitcommaseperatedvalues(''' + ISNULL(@paramset_names,'') +''')
				UNION
				--load all paramset of the combination (report,page) if no specific set of paramsets to export is provided
				SELECT rp.[name] 
				FROM report_paramset rp
				INNER JOIN report_page rpage 
					ON rp.page_id = rpage.report_page_id
				INNER JOIN report r 
					ON r.report_id = rpage.report_id
				INNER JOIN #pages tp ON tp.page_name = rpage.[name]
				WHERE r.report_id = ' + CAST(@report_id_src AS VARCHAR(10))				 
				+' AND ''' + ISNULL(@paramset_names,-1) + ''' = ''-1'''
	EXEC(@sql)
				
	INSERT INTO #final_query (line_query)
	SELECT 'BEGIN TRY
		BEGIN TRAN

		DECLARE @report_id_dest INT 
	'
	DECLARE @temp_report_id VARCHAR(max)
	declare @report_hash varchar(50) 
	
	SELECT @temp_report_id=report_id,@report_hash=report_hash FROM dbo.report WHERE name=@report_name
	/*
	Added delete logic if there consists already the report in where we are trying to import.
	*/
	IF @mode = 'e'
	BEGIN
		INSERT INTO #final_query (line_query)
		SELECT '
		--RETAIN APPLICATION FILTER DETAILS START (PART1)
		DROP TABLE IF EXISTS #paramset_map
		CREATE TABLE #paramset_map (
			deleted_paramset_id INT NULL, 
			paramset_hash VARCHAR(36) COLLATE DATABASE_DEFAULT NULL, 
			inserted_paramset_id INT NULL

		)

		--store mapping information for filter detail column ids and data source column id for sql datasource
		DROP TABLE IF EXISTS #sql_source_filter_detail_column_mapping
		CREATE TABLE #sql_source_filter_detail_column_mapping (
			paramset_hash VARCHAR(36),
			column_id INT,
			column_name VARCHAR(1000),
			application_ui_filter_details_id INT NULL
		)

		IF EXISTS (SELECT 1 FROM dbo.report WHERE report_hash=''' + @report_hash + ''')
		BEGIN
			DECLARE @report_id_to_delete INT
			SELECT @report_id_to_delete = report_id FROM report WHERE report_hash = ''' + @report_hash + '''

			INSERT INTO #paramset_map(deleted_paramset_id, paramset_hash)
			SELECT rp.report_paramset_id, rp.paramset_hash
			FROM report_paramset rp
			INNER JOIN report_page pg ON pg.report_page_id = rp.page_id
			WHERE pg.report_id = @report_id_to_delete

			INSERT INTO #sql_source_filter_detail_column_mapping(paramset_hash, column_id, column_name, application_ui_filter_details_id)
			SELECT DISTINCT rpm.paramset_hash, aufd.report_column_id, dsc.name, aufd.application_ui_filter_details_id
			FROM application_ui_filter_details aufd
			INNER JOIN application_ui_filter auf
				ON auf.application_ui_filter_id = aufd.application_ui_filter_id
			INNER JOIN report_paramset rpm
				ON rpm.report_paramset_id = auf.report_id
			INNER JOIN report_page pg ON pg.report_page_id = rpm.page_id
			INNER JOIN data_source_column dsc
				ON dsc.data_source_column_id = aufd.report_column_id
			INNER JOIN data_source ds
				ON ds.data_source_id = source_id
			WHERE pg.report_id = @report_id_to_delete
				AND ds.type_id = 2

			EXEC spa_rfx_report @flag=''d'', @report_id=@report_id_to_delete, @retain_privilege=1, @process_id=NULL

		
		END
		--RETAIN APPLICATION FILTER DETAILS END (PART1)
		'
	END	
		
	/* 
	* In the export logic the id values are resolved by the name value of the of the field. 
	*  SOURCE					DESTINATION
	*	ID			 NAME			ID
	* Insert into report table if the report is deleted or for a new report 
	*  then capture the new report_id in @report_id_dest.
	*  */
	
	IF @mode <> 'p'
	BEGIN
		/*
		Since it is possible that the exported report owner may not be available in the system where it is imported, using the original
		report owner doesn't make sense. Using FNAAppAdminID also doesn't help as it returns superuser in case of WinAuth, which also
		may not be present in the other system where it is imported. So using farrms_admin is safe here as it is available in all system.
		Plus, it also makes easy to identify that such exported report ownership are by default assigned to farrms_admin (system user) and -
		can be changed when required.
		*/

		--GET UNIQUE COPY NAME OF REPORT INCASE OF REPORT COPY.
		INSERT INTO #final_query (line_query)
		select '
		declare @report_copy_name varchar(200)
		' + iif(@mode='c','EXEC spa_GetUniqueCopyName ''' + @report_name + ''',''name'',''report'',null,@report_copy_name output','') + '
		set @report_copy_name = isnull(@report_copy_name, ''Copy of '' + ''' + @report_name + ''')
		'
		
		INSERT INTO #final_query (line_query)
		SELECT
		'
		INSERT INTO report ([name], [owner], is_system, is_excel, is_mobile, report_hash, [description], category_id)
		SELECT TOP 1 ' + CASE WHEN @mode  = 'e' THEN '''' + r.[name] + '''' ELSE '@report_copy_name' END 
			+ ' [name], '''+ @user_name +''' [owner], ' + CASE WHEN @mode  = 'c' THEN '0'  ELSE CAST(r.is_system AS VARCHAR(1)) END + ' is_system, '
			+ CAST(r.is_excel AS VARCHAR(1)) + ' is_excel, ' + CAST(r.is_mobile AS VARCHAR(1)) + ' is_mobile, '
			+ '''' + CASE WHEN @mode  = 'e' THEN r.report_hash ELSE dbo.FNAGetNewID() END  + '''' + ' report_hash, ' 
			+ ISNULL('''' + r.[description] + '''', 'NULL') + ' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
		FROM sys.objects o
		LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = ' + ISNULL('''' + sdv_cat.code + '''', 'NULL') + ' AND sdv_cat.type_id = ' + ISNULL(CAST(sdv_cat.type_id AS VARCHAR(10)), '-1')
		+ 
		' 
		SET @report_id_dest = SCOPE_IDENTITY()
		
		'
		FROM report r
		LEFT JOIN static_data_value sdv_cat ON r.category_id = sdv_cat.value_id
		WHERE r.report_id = @report_id_src
	
		--migrate SQL data sources used by report
		--check if report has any sql data source, if yes call data source export else skip
		if exists(
			select top 1 1 
			from data_source ds
			where ds.report_id = @report_id_src
		)
		begin
			INSERT INTO #final_query (line_query)
			EXEC dbo.spa_rfx_export_data_source NULL, @report_name, @mode, 'y'
		end
			
		--migrate report_dataset
		/*Insert into report_dataset only if the combination of report_id and dataset alias doesnt exists*/
		INSERT INTO #final_query (line_query)
		SELECT 
		'
		INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
		SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, ''' + rd.[alias]  + ''' [alias], rd_root.report_dataset_id AS root_dataset_id,'
		+ ISNULL(CAST(rd.is_free_from AS VARCHAR(10)), 'NULL') + ' AS is_free_from, ''' + ISNULL(rd.relationship_sql , 'NULL') + ''' AS relationship_sql
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = ''' + ds.[name] + '''
			AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
		LEFT JOIN report_dataset rd_root ON rd_root.[alias] = ' + ISNULL('''' + rd_root.[alias] + '''', 'NULL') + '
			AND rd_root.report_id = @report_id_dest		
		'
		FROM report_dataset rd 
		INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
		INNER JOIN report r ON r.report_id = rd.report_id
		LEFT JOIN report_dataset rd_root ON rd_root.report_dataset_id = rd.root_dataset_id
		WHERE r.report_id = @report_id_src
		ORDER BY ISNULL(rd.root_dataset_id, -1) ASC	--sorting is important here to allow insertion of root datasets first, so that they can be referenced by their child datasets
		
		--migrate report_dataset_relationship
		--IMPORTANT: report_dataset [alias] is unique per report only
		/*Insert into report_dataset_relationship when the combination of dataset_id,from_dataset_id,to_dataset_id,from_column_id and to_column_id doesnt exists*/
		INSERT INTO #final_query (line_query)
		SELECT 
		'IF NOT EXISTS(SELECT 1  
					   FROM report_dataset_relationship rdr
					   INNER JOIN report_dataset rd ON  rd.report_dataset_id = rdr.dataset_id
							AND rd.[alias] = ''' + rd.[alias] + '''' + '
							AND rd.report_id = @report_id_dest
						INNER JOIN report_dataset rd_from on rd_from.[alias] = ''' + rd_from.[alias] + ''' 
							AND rd_from.report_id = @report_id_dest
						INNER JOIN report_dataset rd_to on rd_to.[alias] = ''' + rd_to.[alias] + ''' 
							AND rd_to.report_id = @report_id_dest
						INNER JOIN data_source ds_from ON ds_from.[name] = ''' + ds_from.[name] + '''
							AND ds_from.data_source_id = rd_from.source_id
							AND ds_from.report_id = @report_id_dest
						INNER JOIN data_source ds_to ON ds_to.[name] = ''' + ds_to.[name] + '''
							AND ds_to.data_source_id = rd_to.source_id
							AND ds_to.report_id = @report_id_dest
						INNER JOIN data_source_column dsc_from ON dsc_from.[name]  = ''' + dsc_from.[name] + ''' ' + '
							AND dsc_from.source_id = ds_from.data_source_id
							AND dsc_from.data_source_column_id  = rdr.from_column_id
						INNER JOIN data_source_column dsc_to ON dsc_to.[name]  = ''' + dsc_to.[name] + '''
							AND dsc_to.source_id = ds_to.data_source_id
							AND dsc_to.data_source_column_id  = rdr.to_column_id
					   )
		BEGIN
			INSERT INTO report_dataset_relationship(dataset_id, from_dataset_id, to_dataset_id, from_column_id, to_column_id, join_type)
			SELECT TOP 1 rd.report_dataset_id, rd_from.report_dataset_id, rd_to.report_dataset_id
				, dsc_from.data_source_column_id, dsc_to.data_source_column_id , ' + ISNULL(CAST(rdr.join_type AS NVARCHAR(4)), 'NULL') + ' AS join_type
			FROM sys.objects o
			INNER JOIN report_dataset rd ON rd.[alias] = ''' + rd.[alias] + '''' + '
				AND rd.report_id = @report_id_dest
			INNER JOIN report_dataset rd_from on rd_from.[alias] = ''' + rd_from.[alias] + ''' 
				AND rd_from.report_id = @report_id_dest
			INNER JOIN report_dataset rd_to on rd_to.[alias] = ''' + rd_to.[alias] + ''' 
				AND rd_to.report_id = @report_id_dest
			INNER JOIN data_source ds_from ON ds_from.[name] = ''' + ds_from.[name] + '''
				AND ds_from.data_source_id = rd_from.source_id ' 
				+ CASE WHEN ds_from.[type_id] <> 2 THEN '' ELSE ' AND ds_from.report_id = @report_id_dest' END + '
			INNER JOIN data_source ds_to ON ds_to.[name] = ''' + ds_to.[name] + '''
				AND ds_to.data_source_id = rd_to.source_id'
				+ CASE WHEN ds_to.[type_id] <> 2 THEN '' ELSE ' AND ds_to.report_id = @report_id_dest' END + '	
			INNER JOIN data_source_column dsc_from ON dsc_from.[name]  = ''' + dsc_from.[name] + ''' ' + '
				AND dsc_from.source_id = ds_from.data_source_id
			INNER JOIN data_source_column dsc_to ON dsc_to.[name]  = ''' + dsc_to.[name] + '''
				AND dsc_to.source_id = ds_to.data_source_id 
		END 
		' 
		FROM report_dataset_relationship rdr 
		INNER JOIN report_dataset rd ON rd.report_dataset_id = rdr.dataset_id
		INNER JOIN report_dataset rd_from ON rd_from.report_dataset_id = rdr.from_dataset_id
		INNER JOIN report_dataset rd_to ON rd_to.report_dataset_id = rdr.to_dataset_id
		INNER JOIN data_source_column dsc_from ON rdr.from_column_id = dsc_from.data_source_column_id
		INNER JOIN data_source_column dsc_to ON rdr.to_column_id = dsc_to.data_source_column_id
		INNER JOIN data_source ds_from ON ds_from.data_source_id = dsc_from.source_id
		INNER JOIN data_source ds_to ON ds_to.data_source_id = dsc_to.source_id 
		INNER JOIN report r ON r.report_id = rd.report_id 
		WHERE r.report_id = @report_id_src
	END	
	
	--migrate report_page
	SET @sql = '			
	INSERT INTO #final_query (line_query)	
	SELECT 
	''
	INSERT INTO ' + @rfx_report_page + '(report_id, [name], report_hash, width, height)
	SELECT @report_id_dest AS report_id, ' + CASE WHEN @mode  = 'e' THEN ''''''' + rpage.[name] + ''''''' ELSE '@report_copy_name' END 
			+ ' [name], '''''' 
	+ CASE WHEN ''' + @mode +''' = ''e''
		THEN rpage.report_hash 
		ELSE dbo.FNAGetNewID() 
		END + '''''' report_hash, '' 
	+ CAST(rpage.width AS VARCHAR(10)) + '' width,'' + CAST(rpage.height AS VARCHAR(10)) + '' height
	''
	FROM ' + @rfx_report_page + ' rpage 
	INNER JOIN #pages tp 
		ON rpage.[name] = tp.page_name
	WHERE rpage.report_id = ' + CAST(@report_id_src AS VARCHAR)		
	EXEC (@sql)
	--print (@sql)
	--select line_query from  #final_query return
	
	--migrate report_paramset
	SET @sql = '	
	INSERT INTO #final_query (line_query)
	SELECT 
	''
		INSERT INTO '+ @rfx_report_paramset + '(page_id, [name], paramset_hash, report_status_id, export_report_name, export_location, output_file_format, delimiter, xml_format, report_header, compress_file, category_id)
		SELECT TOP 1 rpage.report_page_id, '' + CASE WHEN ''' + @mode + '''= ''e'' THEN '''''''' + rp.[name] + '''''''' ELSE ''''''Copy'''' + 
			--left(@report_copy_name,6) 
			iif(isnumeric(ltrim(rtrim(SUBSTRING(@report_copy_name,6,2))))=1,'''' '''' + ltrim(rtrim(SUBSTRING(@report_copy_name,6,2))),'''''''')
			+ '''' of '' + rp.[name] + '''''''' END +'', '''''' 
		+ CASE WHEN ''' + @mode + '''= ''e'' 
				THEN rp.paramset_hash 
				ELSE dbo.FNAGetNewID() 
		  END + '''''', '' + ISNULL(CAST(rp.report_status_id AS VARCHAR(10)), ''NULL'') + '','' + 
		ISNULL('''''''' + rp.export_report_name + '''''''', ''NULL'') + '','' + 
		ISNULL('''''''' + rp.export_location + '''''''', ''NULL'') + '','' + 
		ISNULL('''''''' + rp.output_file_format + '''''''', ''NULL'') + '','' + 
		ISNULL('''''''' + rp.delimiter + '''''''', ''NULL'') + '', 
		'' + ISNULL(CAST(rp.xml_format AS VARCHAR(10)), ''NULL'') + '','' +
		ISNULL('''''''' + CAST(rp.report_header AS VARCHAR(10)) + '''''''', ''NULL'') + '','' + 
		ISNULL('''''''' + CAST(rp.compress_file AS VARCHAR(10)) + '''''''', ''NULL'') + '','' +		
		ISNULL(CAST(rp.category_id AS VARCHAR(20)), ''NULL'') + ''	
		FROM sys.objects o
		INNER JOIN ' + @rfx_report_page + ' rpage 
			on rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r 
		ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
	''
	FROM '+ @rfx_report_paramset + ' rp
	INNER JOIN #paramset tparam 
		ON tparam.paramset_name = rp.[name]
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rp.page_id = rpage.report_page_id
	INNER JOIN #pages tp
		ON tp.page_name = rpage.[name]
	INNER JOIN ' + @rfx_report + ' r 
		ON r.report_id = rpage.report_id
	WHERE r.report_id = '+ CAST(@report_id_src AS VARCHAR(10))		
	--PRINT ISNULL(@sql, '@sql is null')
	EXEC (@sql)		
	--select line_query from #final_query
	--return
		
	--migrate report_dataset_paramset
	--paramset [name] is unique per page only
	SET @sql = '	
	INSERT INTO #final_query (line_query)
	SELECT 
	''
		INSERT INTO '+ @rfx_report_dataset_paramset + '(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, '' + ISNULL('''''''' + REPLACE(rdp.where_part, '''''''', '''''''''''') + '''''''', ''NULL'') + '' AS where_part, '' 
		+ ISNULL(CAST(rdp.advance_mode AS VARCHAR(10)), ''NULL'') + ''
		FROM sys.objects o
		INNER JOIN '+ @rfx_report_paramset + ' rp 
			ON rp.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rp.[name] + ''''''''
										ELSE ''''''Copy'''' +
										iif(isnumeric(ltrim(rtrim(SUBSTRING(@report_copy_name,6,2))))=1,'''' '''' + ltrim(rtrim(SUBSTRING(@report_copy_name,6,2))),'''''''')
										+ '''' of '' + rp.[name] + ''''''''
			                        END + ''
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report_dataset + ' rd 
			ON rd.report_id = @report_id_dest
			AND rd.[alias] = '''''' + rd.[alias] + ''''''
	''
	FROM '+ @rfx_report_dataset_paramset + ' rdp
	INNER JOIN '+ @rfx_report_paramset + ' rp 
		ON rp.report_paramset_id = rdp.paramset_id
	INNER JOIN #paramset ps 
		ON ps.paramset_name = rp.[name]
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rp.page_id 
	INNER JOIN #pages p 
		ON p.page_name = rpage.[name] 
	INNER JOIN ' + @rfx_report_dataset + ' rd 
		ON rd.report_dataset_id = rdp.root_dataset_id
	INNER JOIN ' + @rfx_report + ' r 
		ON r.report_id = rpage.report_id
	WHERE r.report_id = ' + CAST(@report_id_src AS VARCHAR(10))
	--print (@sql)
	EXEC (@sql)		
	--select line_query from #final_query return
	
	--migrate report_param
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT
	''
		INSERT INTO '+ @rfx_report_param + '(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, '' + ISNULL(CAST(rparam.operator AS VARCHAR(50)), '''')
		 + '' AS operator, '' + ISNULL('''''''' + replace(rparam.initial_value,'''''''','''''''''''') + '''''''', ''NULL'') + '' AS initial_value, '' + ISNULL('''''''' + replace(rparam.initial_value2,'''''''','''''''''''') + '''''''', ''NULL'') 
		 + '' AS initial_value2, '' + ISNULL(CAST(rparam.optional AS VARCHAR(4)), ''NULL'') + '' AS optional, '' + ISNULL(CAST(rparam.hidden AS VARCHAR(4)), ''NULL'') + '' AS hidden,''
		 + ISNULL(CAST(rparam.logical_operator AS VARCHAR(4)), ''NULL'') + '' AS logical_operator, '' + ISNULL(CAST(rparam.param_order AS VARCHAR(4)), ''NULL'') + '' AS param_order, ''
		 + ISNULL(CAST(rparam.param_depth AS VARCHAR(4)), ''NULL'') + '' AS param_depth, ''
		 + ISNULL('''''''' + NULLIF(rparam.label, '''')+ '''''''' , ''NULL'') + '' AS label
		FROM sys.objects o
		INNER JOIN '+ @rfx_report_paramset + ' rp 
			ON rp.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rp.[name] + ''''''''
										ELSE ''''''Copy'''' +
										iif(isnumeric(ltrim(rtrim(SUBSTRING(@report_copy_name,6,2))))=1,'''' '''' + ltrim(rtrim(SUBSTRING(@report_copy_name,6,2))),'''''''')
										+ '''' of '' + rp.[name] + ''''''''
			                        END + ''
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report_dataset + ' rd_root 
			ON rd_root.report_id = '' + ''@report_id_dest'' + '' 
			AND rd_root.[alias] = '''''' + rd_root.[alias] + ''''''
		INNER JOIN '+ @rfx_report_dataset_paramset + ' rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN ' + @rfx_report_dataset + ' rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = '''''' + rd.[alias] + ''''''
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '''''' + ds.[name] + '''''' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = '''''' + dsc.[name] + ''''''	
	''	
	FROM ' + @rfx_report_param + ' rparam
	INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp 
		ON rdp.report_dataset_paramset_id = rparam.dataset_paramset_id
	INNER JOIN ' + @rfx_report_paramset + ' rp 
		ON rp.report_paramset_id = rdp.paramset_id
	INNER JOIN #paramset ps 
		ON ps.paramset_name = rp.[name]
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rp.page_id 
	INNER JOIN #pages p 
		ON p.page_name = rpage.[name] 
	INNER JOIN ' + @rfx_report_dataset + ' rd_root 
		ON rd_root.report_dataset_id = rdp.root_dataset_id
	INNER JOIN ' + @rfx_report + ' r 
		ON r.report_id = rpage.report_id
	INNER JOIN ' + @rfx_report_dataset + ' rd 
		ON rd.report_dataset_id = rparam.dataset_id
	INNER JOIN data_source_column dsc 
		ON dsc.data_source_column_id = rparam.column_id
	INNER JOIN data_source ds 
		ON ds.data_source_id = dsc.source_id
	WHERE r.report_id = ' + CAST(@report_id_src AS VARCHAR(10))	
	EXEC (@sql)		
	
	--migrate report_page_tablix
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT 
	''
		INSERT INTO '+  @rfx_report_page_tablix + '(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, '''''' + rpt.[name]+ '''''' [name], '' 
				+ ISNULL('''''''' + rpt.width + '''''''', ''NULL'') + '' width, '' + ISNULL('''''''' + rpt.height + '''''''', ''NULL'') + '' height, '' 
				+ ISNULL('''''''' + rpt.[top] + '''''''', ''NULL'') + '' [top], '' + ISNULL('''''''' + rpt.[left] + '''''''', ''NULL'') + '' [left],''
				+ ISNULL(CAST(rpt.group_mode AS VARCHAR(4)), ''NULL'') + '' AS group_mode,''
				+ ISNULL(CAST(rpt.border_style AS VARCHAR(4)), ''NULL'') + '' AS border_style,''
				+ ISNULL(CAST(rpt.page_break AS VARCHAR(4)), ''NULL'') + '' AS page_break,''
				+ ISNULL(CAST(rpt.type_id AS VARCHAR(4)), ''NULL'') + '' AS type_id,''
				+ ISNULL(CAST(rpt.cross_summary AS VARCHAR(4)), ''NULL'') + '' AS cross_summary,''
				+ ISNULL(CAST(rpt.no_header AS VARCHAR(4)), ''NULL'') + '' AS no_header,''
				+ ISNULL('''''''' + rpt.export_table_name + '''''''', ''NULL'') + '' export_table_name, '' 
				+ ISNULL(CAST(rpt.is_global AS VARCHAR(4)), ''1'') + '' AS is_global
		FROM sys.objects o
		INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report_dataset + ' rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = '''''' + rd.[alias] + '''''' 
	''
	FROM '+ @rfx_report_page_tablix + ' rpt
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpt.page_id
		AND rpage.report_id = ' + CAST(@report_id_src AS VARCHAR(10))
	+ ' INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
		AND r.report_id = ' + CAST(@report_id_src AS VARCHAR(10))	
	+ ' INNER JOIN #pages p 
			ON p.page_name = rpage.[name] 
	INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rpt.root_dataset_id'
	EXEC (@sql)
		
	--migrate report_tablix_column
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT 
	''
		INSERT INTO '+ @rfx_report_tablix_column + '(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, '' +
		--Assign NULL to the dataset and column_id of Custom columns.
			CASE WHEN rtc.dataset_id IS NULL THEN ''NULL dataset_id,'' ELSE ''rd.report_dataset_id dataset_id,'' END +
			CASE WHEN rtc.column_id IS NULL THEN ''NULL column_id,'' ELSE '' dsc.data_source_column_id column_id,'' END 
			+ ISNULL(CAST(rtc.placement AS VARCHAR(4)), ''NULL'') + '' placement, '' + ISNULL(CAST(rtc.column_order AS VARCHAR(4)), ''NULL'') + '' column_order,'' 
			+ ISNULL(CAST(rtc.aggregation AS VARCHAR(25)), ''NULL'') + '' aggregation, '' + 
			+ ISNULL('''''''' + REPLACE (rtc.functions, '''''''', '''''''''''') + '''''''', ''NULL'') + '' functions, ''
			 + ISNULL('''''''' + REPLACE (rtc.[alias], '''''''', '''''''''''') + '''''''', ''NULL'') + '' [alias], '' 
			+ ISNULL(CAST(rtc.sortable AS VARCHAR(4)), ''NULL'') + '' sortable, '' + ISNULL(CAST(rtc.rounding AS VARCHAR(4)), ''NULL'') + '' rounding, '' 
			+ ISNULL(CAST(rtc.thousand_seperation AS VARCHAR(25)), ''NULL'') + '' thousand_seperation, '' 
			+ ISNULL ('''''''' + rtc.font + '''''''', ''NULL'') + '' font, '' + ISNULL('''''''' + rtc.font_size + '''''''', ''NULL'') + '' font_size, '' 
			+ ISNULL('''''''' + rtc.font_style + '''''''', ''NULL'') + '' font_style, '' + ISNULL('''''''' + rtc.text_align + '''''''', ''NULL'') + '' text_align, '' 
			+ ISNULL('''''''' + rtc.text_color + '''''''', ''NULL'') + '' text_color, '' + ISNULL('''''''' + rtc.background + '''''''', ''NULL'') + '' background, '' 
			+ ISNULL(CAST(rtc.default_sort_order AS VARCHAR(5)), ''NULL'') + '' default_sort_order, '' 
			+ ISNULL(CAST(rtc.default_sort_direction AS VARCHAR(5)), ''NULL'') + '' sort_direction, '' 
			+ ISNULL(CAST(rtc.custom_field AS VARCHAR(4)), ''NULL'') + '' custom_field, ''
			+ ISNULL(CAST(rtc.render_as AS VARCHAR(4)), ''NULL'') + '' render_as,''
			+ ISNULL(CAST(rtc.column_template AS VARCHAR(4)), ''NULL'') + '' column_template,''
			+ ISNULL(CAST(rtc.negative_mark AS VARCHAR(4)), ''NULL'') + '' negative_mark,''
			+ ISNULL(CAST(rtc.currency AS VARCHAR(4)), ''NULL'') + '' currency,''
			+ ISNULL(CAST(rtc.date_format AS VARCHAR(4)), ''NULL'') + '' date_format,''
			+ ISNULL(CAST(rtc.cross_summary_aggregation AS VARCHAR(4)), ''NULL'') + '' cross_summary_aggregation,''
			+ ISNULL(CAST(rtc.mark_for_total AS VARCHAR(4)), ''NULL'') + '' mark_for_total,''
			+ ISNULL(CAST(rtc.sql_aggregation AS VARCHAR(4)), ''NULL'') + '' sql_aggregation,''
			+ ISNULL(CAST(rtc.subtotal AS VARCHAR(4)), ''NULL'') + '' subtotal
			
		FROM sys.objects o
		INNER JOIN '+ @rfx_report_page_tablix + ' rpt 
			ON rpt.[name] = '''''' + rpt.[name] + ''''''
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report_dataset + ' rd 
			ON rd.report_id = r.report_id '' +
			CASE WHEN rtc.dataset_id IS NULL 
				THEN '''' 
				ELSE ''AND rd.[alias] = '''''' + rd.[alias] + '''''' ''
			END + ''	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	'' +
			CASE WHEN ds.data_source_id IS NULL 
				THEN '''' 
				ELSE ''AND ds.[name] = '''''' + ds.[name] + '''''' ''
			END + ''	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id ''+
			CASE WHEN rtc.column_id IS NULL 
				THEN '''' 
				ELSE ''AND dsc.[name] = '''''' + dsc.[name] + '''''' ''
			END ''			
	''
	FROM '+ @rfx_report_tablix_column + ' rtc
	INNER JOIN '+  @rfx_report_page_tablix + ' rpt 
		ON rpt.report_page_tablix_id = rtc.tablix_id
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpt.page_id
		AND rpage.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) +'
	INNER JOIN ' + @rfx_report + ' r 
		ON r.report_id = rpage.report_id
		AND r.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) +'		
	INNER JOIN #pages p 
		ON p.page_name = rpage.[name] 
	-- use left join as the dataset_id and column_id of Custom columns will be NULL 
	LEFT JOIN ' + @rfx_report_dataset + ' rd 
		ON rd.report_dataset_id = rtc.dataset_id
	LEFT JOIN data_source_column dsc 
		ON rtc.column_id = dsc.data_source_column_id
	LEFT JOIN data_source ds 
		ON ds.data_source_id = dsc.source_id'
	--print (@sql)		
	EXEC (@sql)		
	--select line_query from #final_query return
	
	--migrate report_tablix_header
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT 
	'' INSERT INTO '+ @rfx_report_tablix_header + '(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id,''+
			CASE WHEN rth.column_id IS NULL THEN ''NULL column_id,'' ELSE '' dsc.data_source_column_id column_id,'' END +''
			'' + ISNULL ('''''''' + rth.font + '''''''', ''NULL'') + '' font,
			'' + ISNULL('''''''' + rth.font_size + '''''''', ''NULL'') + '' font_size,
			'' + ISNULL('''''''' + rth.font_style + '''''''', ''NULL'') + '' font_style,
			'' + ISNULL('''''''' + rth.text_align + '''''''', ''NULL'') + '' text_align,
			'' + ISNULL('''''''' + rth.text_color + '''''''', ''NULL'') + '' text_color,
			'' + ISNULL('''''''' + rth.background + '''''''', ''NULL'') + '' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN '+  @rfx_report_page_tablix + ' rpt 
			ON  rpt.[name] = '''''' + rpt.[name] + ''''''
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	'' +
			CASE WHEN ds.data_source_id IS NULL 
				THEN '''' 
				ELSE ''AND ds.[name] = '''''' + ds.[name] + '''''' ''
			END + ''	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id '' +
			CASE WHEN rth.column_id IS NULL 
				THEN '''' 
				ELSE ''AND dsc.[name] = '''''' + dsc.[name] + '''''' ''
			END + ''
		INNER JOIN '+ @rfx_report_tablix_column + ' rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = '''''' + REPLACE(rtc.[alias], '''''''', '''''''''''') + '''''' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	''
	FROM '+ @rfx_report_tablix_header + ' rth
	INNER JOIN ' + @rfx_report_tablix_column + ' rtc
		ON rth.report_tablix_column_id = rtc.report_tablix_column_id 
	INNER JOIN '+ @rfx_report_page_tablix + ' rpt 
		ON rpt.report_page_tablix_id = rtc.tablix_id
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpt.page_id 
		AND rpage.report_id =  ' + CAST(@report_id_src AS VARCHAR(10)) +'
	INNER JOIN ' + @rfx_report + ' r 
		ON r.report_id = rpage.report_id 
		AND r.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) +'		
	INNER JOIN #pages p 
		ON p.page_name = rpage.[name] 
	LEFT  JOIN data_source_column dsc 
		ON rtc.column_id = dsc.data_source_column_id
	LEFT  JOIN data_source ds 
		ON ds.data_source_id = dsc.source_id'
	EXEC (@sql)
	
	--migrate report_page_chart
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT 
	''
		INSERT INTO '+ @rfx_report_page_chart + '(page_id, root_dataset_id, [name], [type_id], width, height, [top], [left], [x_axis_caption], [y_axis_caption], [page_break], [chart_properties])
		SELECT TOP 1 rpage.report_page_id page_id, rd.report_dataset_id root_dataset_id, '''''' + rpc.[name]+ '''''' [name], '' 
				+ ISNULL(CAST(rpc.[type_id] AS VARCHAR(10)), '''') + '' [type_id], '' 
		+ ISNULL('''''''' + rpc.width + '''''''', ''NULL'') + '' width, '' 
		+ ISNULL('''''''' + rpc.height + '''''''', ''NULL'') + '' height, '' 
		+ ISNULL('''''''' + rpc.[top] + '''''''', ''NULL'') + '' [top], '' 
		+ ISNULL('''''''' + rpc.[left] + '''''''', ''NULL'') + '' [left], ''
		+ ISNULL('''''''' + rpc.[x_axis_caption] + '''''''', ''NULL'') + '' [x_axis_caption], '' 
		+ ISNULL('''''''' + rpc.[y_axis_caption] + '''''''', ''NULL'') + '' [y_axis_caption],''
		+ ISNULL(CAST(rpc.[page_break] AS VARCHAR(4)), ''NULL'') + '' [page_break],''
		+ ISNULL('''''''' + rpc.[chart_properties] + '''''''', ''NULL'') + '' [chart_properties] 
		FROM sys.objects o
		INNER JOIN ' + @rfx_report_page + ' rpage
			ON rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''			
		INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report_dataset + ' rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = '''''' + rd.[alias] + '''''' 
	''
	FROM '+ @rfx_report_page_chart + ' rpc
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpc.page_id
		AND rpage.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) +'
	INNER JOIN ' + @rfx_report + ' r ON r.report_id = rpage.report_id
		AND r.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) +'
	INNER JOIN #pages p 
		ON p.page_name = rpage.[name] 
	INNER JOIN ' + @rfx_report_dataset + ' rd 
		ON rd.report_dataset_id = rpc.root_dataset_id'
	EXEC (@sql)	
	
	--migrate report_chart_column
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT  
	''
		INSERT INTO '+ @rfx_report_chart_column + '(chart_id, dataset_id, column_id, placement, column_order, [alias], functions, aggregation, default_sort_order, default_sort_direction, custom_field, render_as_line)
		SELECT TOP 1 rpc.report_page_chart_id chart_id, rd.report_dataset_id dataset_id,
		
		 ''+ CASE WHEN rcc.column_id IS NULL THEN ''NULL column_id,'' ELSE '' dsc.data_source_column_id column_id,'' END 
			+ ISNULL(CAST(rcc.placement AS VARCHAR(4)), ''NULL'') + '' placement,'' 
			+ ISNULL(CAST(rcc.column_order AS VARCHAR(4)), ''NULL'') + '' column_order, '' 
			+ ISNULL('''''''' + rcc.[alias] + '''''''', ''NULL'') + '' [alias], ''
			+ ISNULL('''''''' + rcc.functions + '''''''', ''NULL'') + '' [functions], ''
			+ ISNULL(CAST(rcc.aggregation AS VARCHAR(4)), ''NULL'') + '' aggregation,''
			+ ISNULL(CAST(rcc.default_sort_order AS VARCHAR(5)), ''NULL'') + '' default_sort_order, '' 
			+ ISNULL(CAST(rcc.default_sort_direction AS VARCHAR(5)), ''NULL'') + '' default_sort_direction, '' 
			+ ISNULL(CAST(rcc.custom_field AS VARCHAR(4)), ''NULL'') + '' custom_field, ''
			+ ISNULL(CAST(rcc.render_as_line AS VARCHAR(4)), ''NULL'') + '' render_as_line
		FROM sys.objects o
		INNER JOIN ' + @rfx_report_page_chart + ' rpc 
			ON rpc.[name] = '''''' + rpc.[name] + ''''''
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON rpage.report_page_id = rpc.page_id 
			AND rpage.[name] ='' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''			
		INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report_dataset + ' rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = '''''' + rd.[alias] + ''''''	
		INNER JOIN data_source ds 
		ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id'' +
		CASE WHEN ds.data_source_id IS NULL 
			THEN '''' 
			ELSE '' AND ds.[name] = '''''' + ds.[name] + '''''' ''
		END + ''	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id ''+
			CASE WHEN rcc.column_id IS NULL 
				THEN '''' 
				ELSE '' AND dsc.[name] = '''''' + dsc.[name] + '''''' ''
			END 		
		FROM '+ @rfx_report_chart_column + ' rcc
	INNER JOIN '+ @rfx_report_page_chart + ' rpc 
		ON rpc.report_page_chart_id = rcc.chart_id
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpc.page_id
		AND rpage.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) +'
	INNER JOIN ' + @rfx_report + ' r 
		ON r.report_id = rpage.report_id
		AND r.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) +'
	INNER JOIN #pages p 
		ON p.page_name = rpage.[name] 
	INNER JOIN ' + @rfx_report_dataset + ' rd 
		ON rd.report_dataset_id = rcc.dataset_id
	LEFT JOIN data_source_column dsc 
		ON rcc.column_id = dsc.data_source_column_id
	LEFT JOIN data_source ds 
		ON ds.data_source_id = dsc.source_id'
	EXEC (@sql)
	
	--migrate report_page_gauge
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT 
		''
	INSERT INTO '+ @rfx_report_page_gauge + '(page_id, root_dataset_id, name, [type_id], width, height, [top], [left], gauge_label_column_id)
		SELECT TOP 1 rpage.report_page_id page_id, rd.report_dataset_id root_dataset_id, '''''' + rpg.[name]+ '''''' [name], '' 
			+ ISNULL(CAST(rpg.[type_id] AS VARCHAR(10)), '''') + '' [type_id], '' 
			+ ISNULL('''''''' + rpg.width + '''''''', ''NULL'') + '' width, '' 
			+ ISNULL('''''''' + rpg.height + '''''''', ''NULL'') + '' height, '' 
			+ ISNULL('''''''' + rpg.[top] + '''''''', ''NULL'') + '' [top], '' 
			+ ISNULL('''''''' + rpg.[left] + '''''''', ''NULL'') + '' [left], ''
			+ CASE WHEN rpg.gauge_label_column_id IS NULL THEN ''NULL [gauge_label_column_id]'' ELSE '' dsc.data_source_column_id [gauge_label_column_id]'' END  + ''
		FROM sys.objects o
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_id = r.report_id 
			AND rd.[alias] = '''''' + rd.[alias] + '''''' 
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id'' +
		CASE WHEN ds.data_source_id IS NULL 
			THEN '''' 
			ELSE '' AND ds.[name] = '''''' + ds.[name] + '''''' ''
		END + ''	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id ''+
			CASE WHEN rpg.gauge_label_column_id IS NULL 
				THEN '''' 
				ELSE '' AND dsc.[name] = '''''' + dsc.[name] + '''''' ''
			END 
	FROM '+ @rfx_report_page_gauge + ' rpg
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpg.page_id
		AND rpage.report_id =  ' + CAST(@report_id_src AS VARCHAR(10)) +'
	INNER JOIN ' + @rfx_report + ' r 
		ON r.report_id = rpage.report_id
		AND r.report_id =  ' + CAST(@report_id_src AS VARCHAR(10)) +'
	INNER JOIN #pages p 
		ON p.page_name = rpage.[name] 
	INNER JOIN ' + @rfx_report_dataset + ' rd 
		ON rd.report_dataset_id = rpg.root_dataset_id
	LEFT JOIN data_source_column dsc 
		ON rpg.gauge_label_column_id = dsc.data_source_column_id
	LEFT JOIN data_source ds 
		ON ds.data_source_id = dsc.source_id' 
	EXEC (@sql)		
	
	--migrate report_gauge_column
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT  
		''
		INSERT INTO '+ @rfx_report_gauge_column + '(gauge_id, column_id, column_order, dataset_id, scale_minimum, scale_maximum, scale_interval, alias, functions, aggregation, font, font_size, font_style, text_color, custom_field, render_as, column_template, currency, rounding, thousand_seperation)
		SELECT TOP 1 rpg.report_page_gauge_id gauge_id,
		  ''+ CASE WHEN NULLIF(rgc.column_id, 0) IS NULL THEN ''NULL column_id,'' ELSE '' dsc.data_source_column_id column_id,'' END 
			+ ISNULL(CAST(rgc.column_order AS VARCHAR(4)), ''NULL'') + '' column_order, rd.report_dataset_id dataset_id ,'' 
			+ ISNULL('''''''' + rgc.scale_minimum + '''''''', ''NULL'') + '' [scale_minimum],'' 
			+ ISNULL('''''''' + rgc.scale_maximum + '''''''', ''NULL'') + '' [scale_maximum],'' 
			+ ISNULL('''''''' + rgc.scale_interval + '''''''', ''NULL'') + '' [scale_interval],'' 
			+ ISNULL('''''''' + rgc.[alias] + '''''''', ''NULL'') + '' [alias],''
			+ ISNULL('''''''' + rgc.functions + '''''''', ''NULL'') + '' [functions],''
			+ ISNULL(CAST(rgc.aggregation AS VARCHAR(4)), ''NULL'') + '' aggregation,''
			+ ISNULL ('''''''' + rgc.font + '''''''', ''NULL'') + '' font, '' 
			+ ISNULL('''''''' + rgc.font_size + '''''''', ''NULL'') + '' font_size, '' 
			+ ISNULL('''''''' + rgc.font_style + '''''''', ''NULL'') + '' font_style, '' 
			+ ISNULL('''''''' + rgc.text_color + '''''''', ''NULL'') + '' text_color, ''
			+ ISNULL(CAST(rgc.custom_field AS VARCHAR(4)), ''NULL'') + '' custom_field, '' 
			+ ISNULL(CAST(rgc.render_as AS VARCHAR(4)), ''NULL'') + '' render_as, '' 
			+ ISNULL(CAST(rgc.column_template AS VARCHAR(4)), ''NULL'') + '' column_template, '' 
			+ ISNULL(CAST(rgc.currency AS VARCHAR(4)), ''NULL'') + '' currency, '' 
			+ ISNULL(CAST(rgc.rounding AS VARCHAR(4)), ''NULL'') + '' rounding, ''   
			+ ISNULL(CAST(rgc.thousand_seperation AS VARCHAR(4)), ''NULL'') + '' thousand_seperation
		FROM sys.objects o
		INNER JOIN '+ @rfx_report_page_gauge + ' rpg 
			ON rpg.[name] = '''''' + rpg.[name] + ''''''
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON rpage.report_page_id = rpg.page_id 
			AND rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report_dataset + ' rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = '''''' + rd.[alias] + ''''''	
		INNER JOIN data_source ds 
		ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id'' +
		CASE WHEN ds.data_source_id IS NULL 
			THEN '''' 
			ELSE '' AND ds.[name] = '''''' + ds.[name] + '''''' ''
		END + ''	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id ''+
			CASE WHEN NULLIF(rgc.column_id, 0) IS NULL 
				THEN '''' 
				ELSE '' AND dsc.[name] = '''''' + dsc.[name] + '''''' ''
			END 	
	FROM  ' + @rfx_report_gauge_column + ' rgc
	INNER JOIN ' + @rfx_report_page_gauge + ' rpg 
		ON rpg.report_page_gauge_id = rgc.gauge_id
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpg.page_id
		AND rpage.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) + '
	INNER JOIN ' + @rfx_report + ' r 
		ON r.report_id = rpage.report_id
		AND r.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) + '
	INNER JOIN #pages p 
		ON p.page_name = rpage.[name] 
	INNER JOIN ' + @rfx_report_dataset + ' rd 
		ON rd.report_dataset_id = rgc.dataset_id
	LEFT JOIN data_source_column dsc 
		ON rgc.column_id = dsc.data_source_column_id
	LEFT JOIN data_source ds
		ON ds.data_source_id = dsc.source_id' 
	EXEC (@sql)	
	
--migrate report_gauge_column_scale
SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT  
		''
		INSERT INTO '+ @rfx_report_gauge_column_scale + ' (report_gauge_column_id, scale_start, scale_end, scale_range_color, column_id, placement)
		SELECT TOP 1 rgc.report_gauge_column_id, ''
			+ ISNULL('''''''' + rgcs.scale_start  + '''''''', ''NULL'') + '' scale_start,''
			+ ISNULL('''''''' + rgcs.scale_end  + '''''''', ''NULL'') + '' scale_end,''
			+ ISNULL('''''''' + rgcs.scale_range_color + '''''''', ''NULL'') + '' scale_range_color
		, rgc.column_id ,''
		+ ISNULL(CAST(rgcs.placement AS VARCHAR(4)), ''NULL'') + '' placement
		FROM sys.objects o
		INNER JOIN ' + @rfx_report_page_gauge + ' rpg 
			ON  rpg.[name] = '''''' + rpg.[name] + ''''''
		INNER JOIN ' + @rfx_report_gauge_column  + ' rgc
			ON  rgc.gauge_id = rpg.report_page_gauge_id 	
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON rpage.report_page_id = rpg.page_id 
			AND rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report_dataset + ' rd
			 ON rd.report_id = r.report_id 
			AND rd.[alias] = '''''' + rd.[alias] + ''''''	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '''''' + ds.[name] + '''''' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = '''''' + dsc.[name] + ''''''	
		''
	FROM ' + @rfx_report_gauge_column_scale + ' rgcs 
	INNER JOIN ' + @rfx_report_gauge_column + ' rgc 
		ON rgcs.report_gauge_column_id = rgc.report_gauge_column_id
	INNER JOIN ' + @rfx_report_page_gauge + ' rpg 
		ON rpg.report_page_gauge_id = rgc.gauge_id
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpg.page_id
		AND rpage.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) + '
	INNER JOIN ' + @rfx_report + ' r ON r.report_id = rpage.report_id
		AND r.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) + '
	INNER JOIN #pages p 
		ON p.page_name = rpage.[name] 
	INNER JOIN ' + @rfx_report_dataset + ' rd 
		ON rd.report_dataset_id = rgc.dataset_id
	INNER JOIN data_source_column dsc 
		ON rgc.column_id = dsc.data_source_column_id
	INNER JOIN data_source ds 
		ON ds.data_source_id = dsc.source_id'    
	EXEC (@sql)	
	
	--migrate report_page_image
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT 
	''
		INSERT INTO ' + @rfx_report_page_image + '(page_id,name,[filename],width,height,[top],[left],[hash])
		SELECT TOP 1 rpage.report_page_id page_id, '''''' + rpi.[name]+ '''''' [name], '''''' + rpi.[filename]+ '''''' [filename], '' 
			+ ISNULL('''''''' + rpi.width + '''''''', ''NULL'') + '' width, '' + ISNULL('''''''' + rpi.height + '''''''', ''NULL'') + '' height, '' 
			+ ISNULL('''''''' + rpi.[top] + '''''''', ''NULL'') + '' [top], '' + ISNULL('''''''' + rpi.[left] + '''''''', ''NULL'') + '' [left],''
			+ '''''''' + CASE WHEN ''' + @mode + '''= ''e''  
							  THEN rpi.[hash] 
							  ELSE dbo.FNAGetNewID() 
			             END  + '''''''' + '' [hash] 		
		FROM sys.objects o
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
	''
	FROM ' + @rfx_report_page_image + ' rpi
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpi.page_id
		AND rpage.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) + '
	INNER JOIN ' + @rfx_report + ' r ON r.report_id = rpage.report_id
		AND r.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) + '
	INNER JOIN #pages p ON p.page_name = rpage.[name]'	
	EXEC (@sql)	

	--migrate report_page_textbox
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT 
	''
		INSERT INTO ' + @rfx_report_page_textbox + '(page_id,content,font,font_size,font_style,width,height,[top],[left],[hash])
		SELECT TOP 1 rpage.report_page_id page_id, '''''' + rpt.[content]+ '''''' [content], '''''' + rpt.[font]+ '''''' [font], '' 
			+ ISNULL('''''''' + rpt.font_size + '''''''', ''NULL'') + '' font_size, '' + ISNULL('''''''' + rpt.font_style + '''''''', ''NULL'') + '' font_style, '' 
			+ ISNULL('''''''' + rpt.width + '''''''', ''NULL'') + '' width, '' + ISNULL('''''''' + rpt.height + '''''''', ''NULL'') + '' height, '' 
			+ ISNULL('''''''' + rpt.[top] + '''''''', ''NULL'') + '' [top], '' + ISNULL('''''''' + rpt.[left] + '''''''', ''NULL'') + '' [left],''
			+ '''''''' + CASE WHEN ''' + @mode + '''= ''e'' 
							  THEN rpt.[hash]
							  ELSE dbo.FNAGetNewID() 
			             END  + '''''''' + '' [hash] 		
		FROM sys.objects o
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
	''
	FROM ' + @rfx_report_page_textbox + ' rpt
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpt.page_id
		AND rpage.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) + '
	INNER JOIN ' + @rfx_report + ' r ON r.report_id = rpage.report_id
		AND r.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) + '
	INNER JOIN #pages p ON p.page_name = rpage.[name]'
	EXEC (@sql) 
	
	--migrate report_page_line
	SET @sql = '
	INSERT INTO #final_query (line_query)
	SELECT 
	''
		INSERT INTO ' + @rfx_report_page_line + '(page_id, color, size, style, width, height, [top], [left], hash)
		SELECT TOP 1 rpage.report_page_id page_id, '''''' + rpl.[color]+ '''''' [color], '''''' + rpl.[size]+ '''''' [size],  '''''' + rpl.[style]+ '''''' [style], '' 
			+ ISNULL('''''''' + rpl.width + '''''''', ''NULL'') + '' width, '' + ISNULL('''''''' + rpl.height + '''''''', ''NULL'') + '' height, '' 
			+ ISNULL('''''''' + rpl.[top] + '''''''', ''NULL'') + '' [top], '' + ISNULL('''''''' + rpl.[left] + '''''''', ''NULL'') + '' [left],''
			+ '''''''' + CASE WHEN ''' + @mode + '''= ''e'' THEN rpl.[hash] ELSE dbo.FNAGetNewID() END  + '''''''' + '' [hash] 		
		FROM sys.objects o
		INNER JOIN ' + @rfx_report_page + ' rpage 
			ON rpage.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + rpage.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
		INNER JOIN ' + @rfx_report + ' r ON r.report_id = rpage.report_id
			AND r.[name] = '' + CASE WHEN ''' + @mode + '''= ''e'' 
										THEN '''''''' + r.[name] + ''''''''
										ELSE ''@report_copy_name''
			                        END + ''
	''
	FROM ' + @rfx_report_page_line + ' rpl
	INNER JOIN ' + @rfx_report_page + ' rpage 
		ON rpage.report_page_id = rpl.page_id
		AND rpage.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) + '
	INNER JOIN ' + @rfx_report + ' r ON r.report_id = rpage.report_id
		AND r.report_id = ' + CAST(@report_id_src AS VARCHAR(10)) + '
	INNER JOIN #pages p ON p.page_name = rpage.[name]'   
	EXEC (@sql)

	--RETAIN APPLY FILTER PART2
	SET @sql = iif(@mode='c','','
	INSERT INTO #final_query (line_query)
	SELECT 
	''
		--RETAIN APPLICATION FILTER DETAILS START (PART2)
		UPDATE pm
		SET inserted_paramset_id = rp.report_paramset_id
		FROM #paramset_map pm
		INNER JOIN ' + @rfx_report_paramset + ' rp
			ON rp.paramset_hash = pm.paramset_hash
		
		UPDATE f set f.report_id = pm.inserted_paramset_id
		FROM application_ui_filter f
		INNER JOIN #paramset_map pm 
			ON pm.deleted_paramset_id = ISNULL(f.report_id, -1)
		WHERE f.application_function_id IS NULL
	
		--delete filter details only for view datasource columns
		DELETE fd
		FROM application_ui_filter_details fd
		INNER JOIN application_ui_filter f 
			ON f.application_ui_filter_id = fd.application_ui_filter_id
		INNER JOIN #paramset_map pm 
			ON pm.inserted_paramset_id = ISNULL(f.report_id, -1)
		LEFT JOIN #sql_source_filter_detail_column_mapping map
			ON map.column_id = ABS(fd.report_column_id)
		WHERE ABS(fd.report_column_id) NOT IN (
			SELECT DISTINCT rp.column_id
			FROM report_param rp
			INNER JOIN report_dataset_paramset rdp 
				ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
			INNER JOIN report_paramset rpm 
				ON rpm.report_paramset_id = rdp.paramset_id
			WHERE rpm.report_paramset_id = f.report_id
		)
		AND map.column_id IS NULL

		
		--store data to update and delete application filter details row for sql datasource only
		DROP TABLE IF EXISTS #filter_details_to_update_sql_datasource

		SELECT fd.application_ui_filter_details_id, fd.report_column_id, dsc.data_source_column_id, fd.field_value
		INTO #filter_details_to_update_sql_datasource
		FROM application_ui_filter_details fd
		INNER JOIN application_ui_filter f 
			ON f.application_ui_filter_id = fd.application_ui_filter_id
		INNER JOIN report_paramset rp 
			ON rp.report_paramset_id = f.report_id
		INNER JOIN #sql_source_filter_detail_column_mapping map 
			ON map.paramset_hash = rp.paramset_hash
			AND map.column_id = ABS(fd.report_column_id) --used ABS for browser columns label row.
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
		INNER JOIN report_param rpr
			ON rpr.dataset_paramset_id = rdp.report_dataset_paramset_id
		INNER JOIN report_dataset rd 
			ON rd.report_dataset_id = rdp.root_dataset_id
		INNER JOIN data_source ds 
			ON ds.data_source_id = rd.source_id
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
		WHERE dsc.name = map.column_name
			AND rpr.column_id = dsc.data_source_column_id

		DROP TABLE IF EXISTS #filter_details_to_delete_sql_datasource

		SELECT fdmap.application_ui_filter_details_id
		INTO #filter_details_to_delete_sql_datasource
		FROM #sql_source_filter_detail_column_mapping fdmap
		EXCEPT
		SELECT fdup.application_ui_filter_details_id
		FROM #filter_details_to_update_sql_datasource fdup
		
		--update filters for sql datasource columns
		UPDATE fd
			SET fd.report_column_id = IIF(fd.report_column_id < 0, -1, 1) * fdup.data_source_column_id		
		FROM application_ui_filter_details fd
		INNER JOIN #filter_details_to_update_sql_datasource fdup
			ON fdup.application_ui_filter_details_id = fd.application_ui_filter_details_id

		--delete unmatched columns from filter detail for sql data source
		DELETE fd
		FROM application_ui_filter_details fd
		INNER JOIN #filter_details_to_delete_sql_datasource fddel
			ON fddel.application_ui_filter_details_id = fd.application_ui_filter_details_id

		--RETAIN APPLICATION FILTER DETAILS END (PART2)
	''
	')
	EXEC (@sql)
END
	
INSERT INTO #final_query (line_query)
SELECT 'COMMIT ' + CHAR(10) + '
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;
		
	DECLARE @error_message VARCHAR(MAX) = ERROR_MESSAGE()
	RAISERROR(@error_message,16,1)
END CATCH
'

/*
	SSMS Grid view limits character upto 65535 chars only, thus truncating the display when this limit is exceeded even
	if the data itself isn't truncated. Using XML type doesn't have such limit if property 
	Query Results > SQL Server > Result to Grid > XML Data = Unlimited
	Clicking the xml data will open the actual data in the new window.

	Used XML PATH('') with TYPE so that no encoding is made
	Actual Data is wrapped with xml tag <? .. ?>
	*/


IF @mode = 'e'
BEGIN
	--SELECT line_query FROM #final_query fq ORDER BY fq.row_id
	IF EXISTS (SELECT 1 FROM #final_query WHERE LEN(line_query) > 8000)
	BEGIN
		
		SELECT STUFF(
			(
				SELECT '' + line_query
				FROM   #final_query fq
				ORDER BY
						fq.row_id 
						FOR XML PATH(''),
						TYPE
			).value('.[1]', 'VARCHAR(MAX)'),
			1,
			0,
			''
		) AS [processing-instruction(x)] FOR XML PATH(''), TYPE;
		
	END
	ELSE
	BEGIN
		SELECT line_query FROM #final_query AS query
		ORDER BY row_id 
	END

END 
ELSE 
BEGIN
	DECLARE @sql_query VARCHAR(MAX)
	SELECT @sql_query = STUFF(
			   (
				   SELECT ' ' + line_query
				   FROM   #final_query fq
				   ORDER BY
						  fq.row_id 
						  FOR XML PATH(''),
						  TYPE
			   ).value('.[1]', 'VARCHAR(MAX)'),
			   1,
			   1,
			   ''
		   )
	--PRINT(@sql_query)	
	--select @sql_query for xml path('') return
	EXEC (@sql_query)
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR,
			 "report",
			 "spa_rfx_export_report",
			 "DB Error",
			 "Error on Inserting on Report paramset.",
			 ''
	ELSE
		EXEC spa_ErrorHandler 0,
			 "report",
			 "spa_rfx_export_report",
			 "Success",
			 "Report Copy Success.",
			 ''
END

