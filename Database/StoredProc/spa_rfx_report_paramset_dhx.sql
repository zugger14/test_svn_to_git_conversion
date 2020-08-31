
IF OBJECT_ID(N'[dbo].[spa_rfx_report_paramset_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_paramset_dhx]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	CRUD operations for report paramset. Created for new report manager dhx. Currently is in use.
	Parameters
	@flag					: 'i' insert operation for report paramset
							  'c' copy operation for report paramset
							  'u' update operation for report paramset
							  'a' select report paramset and columns information for matched paramset id
							  's' select report paramset header information for matched page id
							  'd' delete operation for report paramset
							  'x' populate the required parameter list
							  'q' process secondary filters with values and build  final parameter report filter string
	@process_id				: Process Id
	@report_paramset_id		: Report Paramset Id
	@page_id				: Page Id
	@name					: Paramset Name
	@xml					: Paramset column information in XML format
	@report_id				: Report Id
	@paramset_hash			: Paramset Hash
	@column_id				: Column Id
	@report_status			: Report Status
	@report_privilege_type	: Report Privilege Type
	@result_to_table		: Process table name to dump filter information
	@export_report_name		: Export Report Name
	@export_location		: Export Location
	@output_file_format		: Output File Format
	@delimiter				: Delimiter
	@xml_format				: Xml Format
	@report_header			: Report Header flag
	@compress_file			: Compress File flag
	@category_id			: Category Id
*/
CREATE PROCEDURE [dbo].[spa_rfx_report_paramset_dhx]
	@flag CHAR(1),
	@process_id VARCHAR(50) = NULL,
	@report_paramset_id VARCHAR(10) = NULL,
	@page_id INT = NULL,
	@name VARCHAR(100) = NULL,
	@xml TEXT = NULL,
	@report_id INT = NULL,
	@paramset_hash VARCHAR(50) = NULL,
	@column_id VARCHAR(100) = NULL,
	@report_status INT = NULL,
	@report_privilege_type CHAR(1) = NULL,
	@result_to_table varchar(1000) = NULL,
	@export_report_name VARCHAR(500) = NULL,
	@export_location VARCHAR(500) = NULL,
	@output_file_format VARCHAR(50) = NULL,
	@delimiter  VARCHAR(50) = NULL,
	@xml_format INT = NULL,
	@report_header CHAR(1) = NULL,
	@compress_file CHAR(1) = NULL,
	@category_id INT = NULL
AS
set nocount on

/*
declare @flag CHAR(1),
	@process_id VARCHAR(50) = NULL,
	@report_paramset_id VARCHAR(10) = NULL,
	@page_id INT = NULL,
	@name VARCHAR(100) = NULL,
	@xml VARCHAR(max) = NULL,
	@report_id INT = NULL,
	@paramset_hash VARCHAR(50) = NULL,
	@column_id VARCHAR(100) = NULL,
	@report_status INT = NULL,
	@report_privilege_type CHAR(1) = NULL,
	@result_to_table varchar(1000) = NULL

select @flag='o', @xml=null, @process_id='112175DE_45DC_4D28_A6E8_CD78B5ED7780', @report_paramset_id='46460'
--*/

DECLARE @user_name            VARCHAR(50) = dbo.FNADBUser() 
declare @sqln nvarchar(max)
declare @err_msg varchar(3000)

IF (@flag <> 'r' AND  @flag <> 'q' AND @flag <> 'z')
BEGIN
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()
   

	DECLARE @sql                  VARCHAR(MAX)  
	DECLARE @sql1                 VARCHAR(MAX)
	DECLARE @sql2                 VARCHAR(MAX)
	

	--Resolve Process Table Name
	DECLARE @rfx_report_dataset           VARCHAR(300) = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
	DECLARE @rfx_report_paramset          VARCHAR(300) = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id) 
	DECLARE @rfx_report_param             VARCHAR(300) = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
	DECLARE @rfx_report_dataset_paramset  VARCHAR(300) = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
	DECLARE @rfx_report_chart_column      VARCHAR(300) = dbo.FNAProcessTableName('report_chart_column', @user_name, @process_id)
	DECLARE @rfx_report_tablix_column     VARCHAR(300) = dbo.FNAProcessTableName('report_tablix_column', @user_name, @process_id)
	DECLARE @rfx_report_page_chart		  VARCHAR(300) = dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
	DECLARE @rfx_report_page_tablix       VARCHAR(300) = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
	DECLARE @rfx_report_page			  VARCHAR(300) = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
	DECLARE @rfx_report					  VARCHAR(300) = dbo.FNAProcessTableName('report', @user_name, @process_id)

	DECLARE @rfx_report_page_gauge            VARCHAR(200)
	DECLARE @rfx_report_gauge_column          VARCHAR(200)
	DECLARE @rfx_report_gauge_column_scale    VARCHAR(200)

	SET @rfx_report_page_gauge				= dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)
	SET @rfx_report_gauge_column			= dbo.FNAProcessTableName('report_gauge_column', @user_name, @process_id)
	SET @rfx_report_gauge_column_scale		= dbo.FNAProcessTableName('report_gauge_column_scale', @user_name, @process_id)


	-- setting @is_admin
	DECLARE @is_admin INT, @report_owner VARCHAR(50), @is_owner INT 
	SELECT @is_admin = dbo.FNAIsUserOnAdminGroup(@user_name, 1)
END

IF (@flag <> 'y' AND @flag <> 'm' AND  @flag <> 'r' AND  @flag <> 'q')
BEGIN
	--setting @report_owner from process_table
	set @sqln = 'SELECT @report_owner = owner FROM ' + @rfx_report
	EXECUTE sp_executesql @sqln, N'@report_owner VARCHAR(50) OUTPUT', @report_owner = @report_owner OUTPUT

	IF @report_owner = @user_name OR @report_privilege_type = 'e'
	BEGIN
		SET @is_owner = 1
	END
	ELSE 
		SET @is_owner = 0	
END

IF @flag = 's'
BEGIN
	--SELECT @report_owner
	
    SET @sql = 'SELECT rp.report_paramset_id [Paramset ID],
                       rp.[name] [Name],
                       rp.create_user [Create User],
                       ''' + @user_name + ''' [Application User],
                       ''' + @report_owner + ''' [Report Owner],
					    rs.name [Status]
                FROM ' + @rfx_report_paramset + ' rp
                LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rp.paramset_hash' + CASE WHEN @is_admin = 1 OR @is_owner = 1 THEN ' AND 1=2 ' ELSE '' END + '
				LEFT JOIN report_status rs on rs.report_status_id = rp.report_status_id
                WHERE rp.page_id = ' + CAST( ISNULL(@page_id, '') AS VARCHAR(50)) + '
                AND 1 = 1
                '    

				--CODE COMMENTED SINCE NEW REPORT MANAGER EXCLUDES FEATURE FOR EDITING ONLY PRIVILEGED PARAMSET.
                --+
    --            CASE WHEN @is_admin = 1 OR @is_owner = 1 THEN ''
				--	 ELSE 
				--	 ' --AND rpp.user_id = ''' + @user_name + '''
				--	   --AND rpp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(''' + @user_name + '''))
					   
				--	   --commented below code as no paramset was listed from other users while no report manager privilege is implemented yet, that gives issue for deploy of report, need to uncomment after rm privilege is implemented
				--	   --AND rp.create_user IS NULL OR rp.create_user = ''' + @user_name + '''
				--	 '
				--END                
    --print @sql
    EXEC (@sql)
END

IF @flag in ('i', 'o') --flag:o => for copy paramset
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF @xml IS NOT NULL or @flag = 'o'
			BEGIN
				
				

				-- Create temp table to store the report_name and report_hash
				IF OBJECT_ID('tempdb..#rfx_param') IS NOT NULL
					DROP TABLE #rfx_param
				create table #rfx_param (
					[paramset_id] int,
					[root_dataset_id] int,
					[dataset_id] int,
					[column_id] int,
					[operator] int,
					[initial_value] varchar(max) COLLATE DATABASE_DEFAULT,
					[initial_value2] varchar(5000) COLLATE DATABASE_DEFAULT,
					[optional] tinyint,
					[hidden] tinyint,
					[where_part] varchar(max) COLLATE DATABASE_DEFAULT,
					[logical_operator] tinyint,
					[param_order] tinyint,
					[param_depth] tinyint,
					[label] varchar(3000) COLLATE DATABASE_DEFAULT,
					[advance_mode] int
				)
				
				IF @flag = 'i'
				BEGIN
					DECLARE @idoc  INT
						
					--Create an internal representation of the XML document.
					EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

					-- Execute a SELECT statement that uses the OPENXML rowset provider.
					INSERT INTO #rfx_param
					SELECT Paramset [paramset_id],
						   RootDataset [root_dataset_id],
						   Dataset [dataset_id],
						   [Column] [column_id],
						   Operator [operator],
						   InitialValue [initial_value],
						   InitialValue2 [initial_value2],
						   Optional [optional],
						   Hidden [hidden],
						   dbo.FNADecodeXML(WherePart) [where_part],
						   LogicalOperator [logical_operator],
						   ParamOrder [param_order],
						   ParamDepth [param_depth],
						   Label [label],
						   AdvanceMode [advance_mode]
					
					FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
					WITH (
					   Paramset VARCHAR(10),
					   RootDataset VARCHAR(10),
					   Dataset VARCHAR(10),
					   [Column] VARCHAR(10),
					   Operator VARCHAR(10),
					   InitialValue VARCHAR(200),
					   InitialValue2 VARCHAR(200),
					   Optional VARCHAR(10),
					   Hidden VARCHAR(10),
					   WherePart VARCHAR(8000),
					   LogicalOperator VARCHAR(10),
					   ParamOrder VARCHAR(10),
					   ParamDepth VARCHAR(10),
					   Label VARCHAR(255),
					   AdvanceMode VARCHAR(10)
					)
				END
				ELSE --copy paramset
				BEGIN
					SET @sql = '
					INSERT INTO #rfx_param
					SELECT NULL [paramset_id],
						   rdp.root_dataset_id [root_dataset_id],
						   rp.dataset_id [dataset_id],
						   rp.column_id [column_id],
						   rp.operator [operator],
						   rp.initial_value [initial_value],
						   rp.initial_value2 [initial_value2],
						   rp.optional [optional],
						   rp.hidden [hidden],
						   rdp.where_part [where_part],
						   rp.logical_operator [logical_operator],
						   rp.param_order [param_order],
						   rp.param_depth [param_depth],
						   rp.label [label],
						   rdp.advance_mode [advance_mode]
					
					--select *
					FROM ' + @rfx_report_param + ' rp
					INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
					WHERE rdp.paramset_id = ' + @report_paramset_id + '
					'

					exec(@sql)
					
					SET @sqln = '
					DECLARE @name_original varchar(2000)

					SELECT top 1 
						@page_id =  pg.report_page_id, 
						@name_original = rps.name, 
						@report_status = rps.report_status_id,
						@export_report_name = rps.export_report_name,
						@export_location = rps.export_location,
						@output_file_format = rps.output_file_format,
						@delimiter = rps.delimiter,
						@xml_format = rps.xml_format,
						@compress_file = rps.compress_file,
						@report_header = rps.report_header
						, @category_id = rps.category_id
					--select *
					FROM ' + @rfx_report_page + ' pg
					INNER JOIN ' + @rfx_report_paramset + ' rps on rps.page_id = pg.report_page_id
					WHERE rps.report_paramset_id = ' + @report_paramset_id + ' 

					--get unique incremented copy name
					exec spa_GetUniqueCopyName
						@column_value=@name_original,
						@column_name=''name'',
						@table_name=''' + @rfx_report_paramset + ''',
						@unique_name=@name output
					'
					EXECUTE sp_executesql @sqln
						, N'@page_id INT OUTPUT,
							@name VARCHAR(500) OUTPUT,
							@report_status INT OUTPUT,
							@export_report_name VARCHAR(500) OUTPUT,
							@export_location VARCHAR(500) OUTPUT,
							@output_file_format VARCHAR(50) OUTPUT,
							@delimiter VARCHAR(50) OUTPUT,
							@xml_format VARCHAR(50) OUTPUT,
							@compress_file VARCHAR(50) OUTPUT,
							@report_header VARCHAR(50) OUTPUT
							,@category_id INT OUTPUT'
						, @page_id = @page_id OUTPUT
						, @name = @name OUTPUT
						, @report_status = @report_status OUTPUT
						, @export_report_name =	@export_report_name  OUTPUT
						, @export_location =	@export_location OUTPUT
						, @output_file_format = @output_file_format OUTPUT
						, @delimiter = @delimiter OUTPUT
						, @xml_format = @xml_format OUTPUT
						, @compress_file = @compress_file  OUTPUT
						, @report_header = @report_header OUTPUT
						, @category_id = @category_id OUTPUT
				END


				--select @page_id,@name,@report_status,@rfx_report_paramset
				--return
				
				UPDATE #rfx_param SET [where_part] = NULL WHERE [where_part] = ''				
				UPDATE #rfx_param SET [label] = NULL WHERE [label] = ''
				
				IF OBJECT_ID('tempdb..#temp_exist') is not null
					drop table #temp_exist

				CREATE TABLE #temp_exist ([name] TINYINT)
				SET @sql =  'INSERT INTO #temp_exist ([name]) SELECT TOP(1) 1 FROM ' + @rfx_report_paramset + ' WHERE page_id = ' + CAST(@page_id AS VARCHAR(100)) + ' AND  name = ''' + @name + ''''
				--print(@sql)
				EXEC(@sql)
				IF EXISTS (SELECT 1 FROM #temp_exist)
				BEGIN
					EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_paramset_dhx', 'DB Error', 'Parameset name already exists.', ''
					RETURN
				END
				
				SET @sql = 'DECLARE @paramset_id INT
							DECLARE @dataset_paramset_id INT
							
							INSERT INTO ' + @rfx_report_paramset + '(
								page_id, 
								[name],
								paramset_hash, 
								report_status_id, 
								export_report_name, 
								export_location, 
								output_file_format, 
								delimiter, 
								xml_format, 
								compress_file, 
								report_header,
								category_id,
								create_user, 
								create_ts)
							VALUES(
								' + CAST(@page_id AS VARCHAR(10)) + ',
								''' + CAST(@name AS VARCHAR(100)) + ''',
								''' + dbo.FNAGetNewID() + ''',
								' + CAST(@report_status AS VARCHAR(10)) + ',
								''' + ISNULL(@export_report_name, '') + ''',
								''' + ISNULL(@export_location, '') + ''',
								''' + ISNULL(@output_file_format, '')  + ''',
								''' + ISNULL(@delimiter, '') + ''',
								' + CAST(ISNULL(@xml_format, '') AS VARCHAR(10)) + ',
								''' + ISNULL(@compress_file, '')  + ''',
								''' + ISNULL(@report_header, '') + ''',
								' + CAST(ISNULL(@category_id, '') AS VARCHAR(10)) + ',
								''' + dbo.FNAAppAdminID() + ''',
								getdate()
							  )

							SET @paramset_id  = IDENT_CURRENT(''' + @rfx_report_paramset + ''')
							
							INSERT INTO ' + @rfx_report_dataset_paramset + ' (paramset_id, root_dataset_id, where_part,advance_mode)
							SELECT MAX(@paramset_id),
								   root_dataset_id,
								   where_part,
								   advance_mode
							FROM   #rfx_param GROUP BY root_dataset_id, where_part, advance_mode
							
							--SET @dataset_paramset_id  = IDENT_CURRENT(''' + @rfx_report_dataset_paramset + ''')
							
							INSERT INTO ' + @rfx_report_param + '(dataset_paramset_id, dataset_id, column_id, operator, initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
							SELECT rrdp.report_dataset_paramset_id,
								   dataset_id,
								   column_id,
								   MAX(operator),
								   MAX(initial_value),
								   MAX(initial_value2),
								   MAX(optional),
								   MAX(hidden),
								   MAX(logical_operator),
								   MAX(param_order),
								   MAX(param_depth),
								   MAX(label)
							FROM  #rfx_param rp_temp 
							INNER JOIN ' + @rfx_report_dataset + ' rd ON rp_temp.dataset_id = rd.report_dataset_id
							INNER JOIN ' + @rfx_report_dataset_paramset + ' rrdp ON rrdp.paramset_id = @paramset_id AND rrdp.root_dataset_id = rp_temp.root_dataset_id
							GROUP BY rrdp.report_dataset_paramset_id, dataset_id, column_id, operator' 
				--print(@sql)
				EXEC(@sql)
			END
			SET @err_msg = 'Data successfully ' + IIF(@flag = 'o', 'copied.', 'inserted.')
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_paramset_dhx', 'Success', @err_msg, @process_id
			
			--select *  from adiha_process.dbo.report_paramset_farrms_admin_112175DE_45DC_4D28_A6E8_CD78B5ED7780			--where report_paramset_id=46461
			--select *  from adiha_process.dbo.report_dataset_paramset_farrms_admin_112175DE_45DC_4D28_A6E8_CD78B5ED7780	--where report_dataset_paramset_id=48195
			--select *  from adiha_process.dbo.report_param_farrms_admin_112175DE_45DC_4D28_A6E8_CD78B5ED7780				--where dataset_paramset_id=48195
		COMMIT	
	END TRY
	BEGIN CATCH
		DECLARE @error_desc VARCHAR(1000)
		DECLARE @error_no INT
		SET @error_no = ERROR_NUMBER()		
		SET @error_desc = ERROR_MESSAGE()
		
		--print 'Error:' + @error_desc
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		EXEC spa_ErrorHandler @error_no, 'Reporting FX', 'spa_rfx_report_paramset_dhx', @error_desc, 'Failed to insert data.', ''
	END	CATCH
END
IF @flag = 'a'
BEGIN
	SET @sql = '
			/*----------Populate report_param properties Parent paramset if present START---------*/
			DECLARE @sql VARCHAR(MAX)
			IF OBJECT_ID(''tempdb..#dependent_report_parameters_returned'') IS NOT NULL
				DROP TABLE #dependent_report_parameters_returned		
			IF OBJECT_ID(''tempdb..#post_data_collection'') IS NOT NULL
				DROP TABLE #post_data_collection		
	
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
				, dependent_initial_value VARCHAR(max) COLLATE DATABASE_DEFAULT
				, dependent_initial_value2 VARCHAR(max) COLLATE DATABASE_DEFAULT
				, dependent_optional VARCHAR(100) COLLATE DATABASE_DEFAULT 
				, dependent_hidden VARCHAR(100) COLLATE DATABASE_DEFAULT
				, dependent_logical_operator VARCHAR(100) COLLATE DATABASE_DEFAULT
				, dependent_param_order VARCHAR(100) COLLATE DATABASE_DEFAULT
				, dependent_param_depth VARCHAR(100) COLLATE DATABASE_DEFAULT
				, dependent_label VARCHAR(255) COLLATE DATABASE_DEFAULT
			)
			
			EXEC spa_rfx_get_dependent_parameters ' + cast(@report_paramset_id AS VARCHAR(8000)) + ' ,''p'', ''' + cast(@process_id AS VARCHAR(200)) + ''', @sql OUTPUT
			INSERT INTO #dependent_report_parameters_returned
			EXEC(@sql)
			
			/*----------Populate report_param properties Parent paramset END ---------*/
	
			SELECT report_paramset_id,
	                   MAX(page_id) page_id,
	                   MAX([name]) [name],
	                   MAX(report_param_id) report_param_id,
	                   MAX(dataset_paramset_id) dataset_paramset_id,
	                   dataset_id,
	                   column_id,
	                   operator,
	                   MAX(initial_value) initial_value,
	                   MAX(initial_value2) initial_value2,
	                   MAX(optional + 0) optional,
	                   MAX(hidden + 0) hidden,
	                   MAX(logical_operator) logical_operator,
	                   MAX(param_order) param_order,
	                   MAX(param_depth) param_depth,
	                   MAX(where_part) where_part,
	                   root_dataset_id,
	                   MAX(required_filter+0) required_filter, --added zero since bit datatype cannot be used on max
	                   MAX(widget_type) widget_type,
	                   --append_filter,
	                   MAX(label) label,
					   MAX(report_status) [report_status],
					   MAX(export_report_name) [export_report_name],
					   MAX(export_location) [export_location],
					   MAX(output_file_format) [output_file_format],
					   MAX(delimiter) [delimiter],
					   MAX(xml_format) [xml_format],
					   MAX(compress_file) [compress_file],
					   MAX(report_header) [report_header],
					   MAX(advance_mode) [advance_mode],
					   MAX(unsaved_param)[unsaved_param],
					   MAX(param_data_source)	 param_data_source
					   ,MAX(category_id)  category_id
					   INTO #post_data_collection
	            FROM   
				(SELECT rps.report_paramset_id,
				        rps.page_id,
				        rps.[name],
				        rp.report_param_id,
				        rp.dataset_paramset_id,
				        rp.dataset_id,
				        rp.column_id,
				        ISNULL(NULLIF(drpr.dependent_operator, ''''), rp.operator ) operator,
				        CASE WHEN ISNULL(NULLIF(drpr.dependent_initial_value, ''''), NULLIF(rp.initial_value,'''')) IS null THEN dsc.param_default_value
							 ELSE ISNULL(NULLIF(drpr.dependent_initial_value, ''''), NULLIF(rp.initial_value,'''')) END initial_value,
				        ISNULL(NULLIF(drpr.dependent_initial_value2, ''''), rp.initial_value2) initial_value2,
				        ISNULL(NULLIF(drpr.dependent_optional, ''''), rp.optional) optional,
				        ISNULL(NULLIF(drpr.dependent_hidden, ''''), rp.hidden) hidden,
				        ISNULL(NULLIF(drpr.dependent_logical_operator, ''''), rp.logical_operator)logical_operator,
				        ISNULL(NULLIF(drpr.dependent_param_order, ''''), rp.param_order) param_order,
				        ISNULL(NULLIF(drpr.dependent_param_depth, ''''), rp.param_depth) param_depth,
				        rdp.where_part,
				        rdp.root_dataset_id root_dataset_id,
				        --CASE WHEN dsc.reqd_param = 1 THEN 1 ELSE 0 END required,
						dsc.required_filter required_filter,
				        rw.name [widget_type],
				        --dsc.append_filter,
				        rp.label,
						rps.report_status_id [report_status],
						rps.export_report_name [export_report_name],
						rps.export_location [export_location],
					    rps.output_file_format [output_file_format],
					    rps.delimiter [delimiter],
					    rps.xml_format [xml_format],
					    rps.compress_file [compress_file],
					    rps.report_header [report_header],
						rdp.advance_mode [advance_mode]		
						, 0 [unsaved_param]	
						, dsc.param_data_source
					, rps.category_id [category_id]
						
				 FROM   ' + @rfx_report_paramset + ' rps
				 --LEFT JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.paramset_id = rps.report_paramset_id --commented since one invalid row found, not sure the use of that row
				 LEFT JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.paramset_id = rps.report_paramset_id
				 LEFT JOIN ' + @rfx_report_param + ' rp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
				 LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rp.column_id
				 LEFT JOIN report_widget rw ON  rw.report_widget_id = dsc.widget_id
				 --LEFT JOIN report_status rs ON rs.report_status_id = rps.report_status_id
				 LEFT JOIN #dependent_report_parameters_returned drpr 
				 	 ON drpr.dependent_column_name = dsc.[name]
				 WHERE rps.report_paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + ' 
				 '
			set @sql1 = 
				 'UNION  

				--grab required columns to be shown by default for Default Paramset (one that is automatically added when adding page)
				 SELECT rps.report_paramset_id,
				        rps.page_id, 
				        rps.[name],
				        NULL report_param_id,
				        NULL dataset_paramset_id,
				        rd.report_dataset_id dataset_id,
				        dsc.data_source_column_id column_id
						-- changed here to make dropdown operator as IN because it is every time multiple checkbox combo
						, ISNULL(NULLIF(drpr.dependent_operator, ''''),  CASE WHEN dsc.widget_id IN (1, 6) THEN 1 ELSE 9 END) operator 
						, ISNULL(NULLIF(drpr.dependent_initial_value, ''''), NULL) initial_value
						, ISNULL(NULLIF(drpr.dependent_initial_value2, ''''), NULL) initial_value2
						, ISNULL(NULLIF(drpr.dependent_optional, ''''), 0) optional
						, ISNULL(NULLIF(drpr.dependent_hidden, ''''), 0) hidden
						, ISNULL(NULLIF(drpr.dependent_logical_operator, ''''), 1)logical_operator
						, ISNULL(NULLIF(drpr.dependent_param_order, ''''), RANK( )OVER(ORDER BY data_source_column_id)-1) param_order
						, ISNULL(NULLIF(drpr.dependent_param_depth, ''''), 0) param_depth,
				        rd.[alias] + ''.['' + dsc.[name] + '']=''''@'' + dsc.[name] + '''''''' where_part,
				        ISNULL(rd.root_dataset_id, rd.report_dataset_id) root_dataset_id,
				        --CASE WHEN dsc.reqd_param = 1 THEN 1 ELSE 0 END required,
						dsc.required_filter required_filter,
				        rw.name [widget_type],
				        --dsc.append_filter,
				        NULL as label,
						rps.report_status_id [report_status],
						rps.export_report_name [export_report_name],
						rps.export_location [export_location],
					    rps.output_file_format [output_file_format],
					    rps.delimiter [delimiter],
					    rps.xml_format [xml_format],
					    rps.compress_file [compress_file],
					    rps.report_header [report_header],
						0 [advance_mode]	
						, 1 [unsaved_param]	
						, dsc.param_data_source
					, rps.category_id [category_id]

				 FROM   ' + @rfx_report_paramset + ' rps
				 INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_page_id = rps.page_id
				 INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_id = rp.report_id
				 INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
				 INNER JOIN data_source_column dsc ON dsc.source_id = ds.data_source_id
				 LEFT JOIN report_widget rw on rw.report_widget_id = dsc.widget_id
				 LEFT JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.paramset_id = rps.report_paramset_id
					AND rdp.root_dataset_id  = ISNULL(rd.root_dataset_id, rd.report_dataset_id)
				 LEFT JOIN ' + @rfx_report_param + ' rparam ON rparam.column_id = dsc.data_source_column_id
					AND rparam.dataset_paramset_id = rdp.report_dataset_paramset_id
				 LEFT JOIN #dependent_report_parameters_returned drpr 
			 	 ON drpr.dependent_column_name = dsc.[name]	
				 WHERE rps.report_paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + '
					--AND dsc.reqd_param = 1 
					AND dsc.required_filter is not null 
					AND rparam.report_param_id IS NULL
				) params
			GROUP BY report_paramset_id, root_dataset_id, dataset_id, column_id, operator
			--, append_filter
			ORDER BY required_filter DESC
		'

	--add cursor to get names for browser		
	SET @sql2 = (' 
						IF COL_LENGTH(''#post_data_collection'', ''bcn'') IS NULL
						BEGIN
							ALTER TABLE #post_data_collection ADD bcn VARCHAR(max)
						END
						 
						 
						DECLARE @column_id VARCHAR(1000)
						DECLARE @initial_value VARCHAR(max)
						DECLARE @param_data_source VARCHAR(MAX)
						DECLARE @inner_sql VARCHAR(MAX)
						DECLARE @widget_type VARCHAR(1000)
						DECLARE @get_column_id_name CURSOR
						SET @get_column_id_name = CURSOR FOR
						SELECT column_id, param_data_source, initial_value, widget_type
						FROM #post_data_collection pdc WHERE widget_type IN (''DataBrowser'', ''BSTREE-Subsidiary'', ''BSTREE-Strategy'', ''BSTREE-Book'', ''BSTREE-SubBook'')
							AND initial_value IS NOT NULL
							
						OPEN @get_column_id_name
						FETCH NEXT
						FROM @get_column_id_name INTO @column_id, @param_data_source, @initial_value, @widget_type
						WHILE @@FETCH_STATUS = 0	
						BEGIN
							IF @widget_type = ''BSTREE-Subsidiary'' OR   @widget_type = ''BSTREE-Strategy'' OR  @widget_type = ''BSTREE-Book'' OR @widget_type = ''BSTREE-SubBook''
							BEGIN
								SET @inner_sql = ''UPDATE pdc 
													SET bcn = ''
												 
								IF @widget_type = ''BSTREE-Subsidiary'' OR   @widget_type = ''BSTREE-Strategy'' OR  @widget_type = ''BSTREE-Book''
								BEGIN 
									SET @inner_sql = @inner_sql +  '' sc.entity_name ''
								END
								ELSE IF @widget_type = ''BSTREE-SubBook''
								BEGIN 
									SET @inner_sql = @inner_sql + '' sc.logical_name ''
								END  
								ELSE
								BEGIN 
									SET @inner_sql = '' ''
								END


								SET @inner_sql = @inner_sql + '' FROM #post_data_collection pdc '' 

 
								IF @widget_type = ''BSTREE-Subsidiary'' OR   @widget_type = ''BSTREE-Strategy'' OR  @widget_type = ''BSTREE-Book''  
								BEGIN 
									SET @inner_sql = @inner_sql + '' CROSS APPLY (SELECT STUFF((
																				SELECT '''','''' + entity_name FROM portfolio_hierarchy sc WHERE sc.entity_id IN ('' + @initial_value + '')  FOR XML PATH('''''''')
																				), 1, 1, '''''''') entity_name) sc
																				''
								END
								ELSE IF @widget_type = ''BSTREE-SubBook''
								BEGIN 
									SET @inner_sql = @inner_sql + '' CROSS APPLY (SELECT STUFF((
																				SELECT '''','''' + logical_name FROM source_system_book_map sc WHERE sc.book_deal_type_map_id IN ('' + @initial_value + '')  FOR XML PATH('''''''')
																				), 1, 1, '''''''') logical_name) sc''
								END 
								ELSE
								BEGIN 
									SET @inner_sql = '' ''
								END

								SET @inner_sql = @inner_sql + '' WHERE pdc.column_id='' + @column_id
							 
								--PRINT @inner_sql
								EXEC(@inner_sql)
							END
							ELSE
							BEGIN
								DECLARE  @grid_sql	VARCHAR(500)
										, @grid_cols VARCHAR(1000)
										, @grid_name VARCHAR(100)
										, @grid_col1	VARCHAR(50)
										, @grid_col2	VARCHAR(50)
								
								SET @grid_cols = NULL
								SELECT  @grid_name = agd.grid_name,
										@grid_sql = agd.load_sql,
										@grid_cols = COALESCE(@grid_cols + '', '', '''') + CAST(agc.column_name AS VARCHAR(50)) + '' VARCHAR(500) ''
								FROM  adiha_grid_definition agd
								INNER JOIN adiha_grid_columns_definition agc on CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
								WHERE agd.grid_name = @param_data_source
								ORDER BY agc.column_order ASC
								
								SELECT @grid_col1 = c1.column_name
								FROM (SELECT ROW_NUMBER() 
										OVER (ORDER BY agc.column_order) AS Row,  agc.column_name
								FROM adiha_grid_definition agd
								INNER JOIN adiha_grid_columns_definition agc on CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
								WHERE agd.grid_name = @param_data_source) c1 WHERE c1.row = 1
						
								SELECT @grid_col2 = c2.column_name
								FROM (SELECT ROW_NUMBER() 
										OVER (ORDER BY agc.column_order) AS Row,  agc.column_name
								FROM adiha_grid_definition agd
								INNER JOIN adiha_grid_columns_definition agc on CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
								WHERE agd.grid_name = @param_data_source) c2 WHERE c2.row = 2

								DECLARE @t_sql VARCHAR(max)
								
								SET @t_sql = ''
									IF OBJECT_ID(''''tempdb..#grid_data'''') IS NOT NULL
										DROP TABLE #grid_data

									DECLARE @browser_label VARCHAR(MAX)
									CREATE TABLE #grid_data' + '(row_id INT IDENTITY(1,1),'' + @grid_cols + '')
									INSERT INTO #grid_data
									EXEC('''''' + REPLACE(@grid_sql,'''''''','''''''''''') + '''''')
									
									SELECT @browser_label = STUFF((
													SELECT '''',''''+'' +  @grid_col2 + '' FROM #grid_data WHERE ''+ @grid_col1+'' IN ('' + @initial_value + '')  FOR XML PATH('''''''')
													), 1, 1, '''''''')
									
									UPDATE pdc 
										SET bcn = @browser_label
									FROM #post_data_collection pdc
									WHERE pdc.column_id = '' + @column_id + ''
								''
								EXEC(@t_sql)
							END
						FETCH NEXT
						FROM @get_column_id_name INTO @column_id, @param_data_source, @initial_value, @widget_type
						END
						CLOSE @get_column_id_name
						DEALLOCATE @get_column_id_name
						SELECT report_paramset_id	
								, page_id	
								, name	
								, report_param_id	
								, dataset_paramset_id	
								, dataset_id	
								, column_id	
								, operator	
								, initial_value 
								, initial_value2	
								, optional	
								, hidden	
								, logical_operator	
								, param_order	
								, param_depth	
								, where_part	
								, root_dataset_id	
								, isnull(required_filter,-1) required_filter	
								, widget_type	
								--, append_filter	
								, label	
								, report_status	
								, export_report_name
								, export_location 
								,output_file_format 
								,delimiter 
								,xml_format
								,compress_file
								,report_header 
								, advance_mode	
								, unsaved_param	
								, ISNULL(bcn, initial_value) bcn
								, category_id [category_id]
							FROM #post_data_collection
							 
						'
						)
						--PRINT (len(@sql))
						--PRINT (len(@sql1))
						--PRINT (len(@sql2))PRINT @sql2
	EXEC (@sql+@sql1+@sql2)
END

IF @flag = 'u'
BEGIN
	SET XACT_ABORT ON
	BEGIN TRY
		BEGIN TRAN
		CREATE TABLE #temp_exist_u ([name] TINYINT)
		SET @sql =  'INSERT INTO #temp_exist_u ([name]) SELECT TOP(1) 1 FROM ' + @rfx_report_paramset + ' WHERE report_paramset_id <> ' + CAST(@report_paramset_id AS VARCHAR(50)) + ' AND page_id = ' + CAST(@page_id AS VARCHAR(50)) + ' AND name = ''' + @name + ''''
		--print(@sql)
		EXEC(@sql)
		IF EXISTS (SELECT 1 FROM #temp_exist_u)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_paramset_dhx', 'DB Error', 'Parameset name already exists.', ''
			RETURN
		END

		SET @sql = 'UPDATE ' + @rfx_report_paramset + '
						SET [name] = ''' + @name + ''',
							[report_status_id] = ' + CAST(@report_status AS VARCHAR(10)) + ',
							[export_report_name] = ''' +  @export_report_name + ''',
							[export_location] = ''' + @export_location +''',
							[output_file_format] = ''' + @output_file_format +''',
							[delimiter] = ''' + @delimiter +''',
							[xml_format] = ' + CAST(@xml_format AS VARCHAR(10)) + ',
							[report_header] = ''' + @report_header +''',
							[compress_file] = ''' + @compress_file +''',
						    [category_id]  = ' + CAST(@category_id AS VARCHAR(10)) + '
					WHERE report_paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50))
		--print @sql
		EXEC (@sql)
		
		SET @sql ='DELETE 
		           FROM   ' + @rfx_report_param + '
		           WHERE  dataset_paramset_id IN (SELECT report_dataset_paramset_id FROM ' + @rfx_report_dataset_paramset + ' WHERE paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + ')'
		--print @sql
		EXEC (@sql)
		
		SET @sql ='DELETE FROM ' + @rfx_report_dataset_paramset + '
					WHERE paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50))
		--print @sql
		EXEC (@sql)
		
		IF @xml IS NOT NULL
		BEGIN
			DECLARE @idoc1  INT
					
			--Create an internal representation of the XML document.
			EXEC sp_xml_preparedocument @idoc1 OUTPUT,@xml

			-- Create temp table to store the report_name and report_hash
			IF OBJECT_ID('tempdb..#rfx_param1') IS NOT NULL
				DROP TABLE #rfx_param1
								
			-- Execute a SELECT statement that uses the OPENXML rowset provider.
			SELECT Paramset [paramset_id],
				   RootDataset [root_dataset_id],
				   Dataset [dataset_id],
				   [Column] [column_id],
				   Operator [operator],
				   InitialValue [initial_value],
				   InitialValue2 [initial_value2],
				   Optional [optional],
				   Hidden [hidden],
				   WherePart [where_part],
				   LogicalOperator [logical_operator],
				   ParamOrder [param_order],
				   ParamDepth [param_depth],
				   Label [label],
				   AdvanceMode [advance_mode]				   
			INTO #rfx_param1
			FROM OPENXML(@idoc1, '/Root/PSRecordset', 1)
			WITH (
			   Paramset VARCHAR(10),
			   RootDataset VARCHAR(10),
			   Dataset VARCHAR(10),
			   [Column] VARCHAR(10),
			   Operator VARCHAR(10),
			   InitialValue VARCHAR(max),
			   InitialValue2 VARCHAR(max),
			   Optional VARCHAR(10),
			   Hidden VARCHAR(10),
			   WherePart VARCHAR(8000),
			   LogicalOperator VARCHAR(10),
			   ParamOrder VARCHAR(10),
			   ParamDepth VARCHAR(10),
			   Label VARCHAR(255),
			   AdvanceMode VARCHAR(10)
			)	
			
			UPDATE #rfx_param1 SET [where_part] = NULL WHERE [where_part] = ''
			UPDATE #rfx_param1 SET [label] = NULL WHERE [label] = ''
			--select * from #rfx_param1
							
			SET @sql = 'INSERT INTO ' + @rfx_report_dataset_paramset + ' (paramset_id, root_dataset_id, where_part,advance_mode)
						SELECT ' + MAX(CAST(@report_paramset_id AS VARCHAR(50))) + ',
							   root_dataset_id,
							   where_part,
							   advance_mode
						FROM   #rfx_param1 GROUP BY root_dataset_id, where_part, advance_mode' 
			--print @sql 
			EXEC (@sql)
			SET @sql = 'INSERT INTO ' + @rfx_report_param + '(dataset_paramset_id, dataset_id, column_id, operator, initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
						SELECT rrdp.report_dataset_paramset_id,
							   dataset_id,
							   column_id,
							   operator,
							   MAX(initial_value),
							   MAX(initial_value2),
							   MAX(optional),
							   MAX(hidden),
							   MAX(logical_operator),
							   MAX(param_order),
							   MAX(param_depth),
							   MAX(label)
						FROM  #rfx_param1 rp_temp 
						INNER JOIN ' + @rfx_report_dataset + ' rd ON rp_temp.dataset_id = rd.report_dataset_id
						INNER JOIN ' + @rfx_report_dataset_paramset + ' rrdp ON rrdp.paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + ' AND rrdp.root_dataset_id = rp_temp.root_dataset_id
						GROUP BY rrdp.report_dataset_paramset_id, dataset_id, column_id, operator' 
			--print @sql
			EXEC (@sql)
		END					
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_paramset_dhx', 'Success', 'Data successfully updated.', @process_id
		
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @edit_error_desc VARCHAR(1000)
		DECLARE @edit_error_no INT
		SET @edit_error_no = ERROR_NUMBER()		
		SET @edit_error_desc = ERROR_MESSAGE()
		
		--print 'Error:' + @edit_error_desc
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		EXEC spa_ErrorHandler @edit_error_no, 'Reporting FX', 'spa_rfx_report_paramset_dhx', @edit_error_desc, 'Failed to update data.', ''
	END CATCH
END
IF @flag = 'd'
BEGIN
	BEGIN TRY
		CREATE TABLE #temp_paramset (last_paramset TINYINT)
		SET @sql = 'DECLARE @report_page_id INT
					SELECT @report_page_id = rp.page_id FROM ' + @rfx_report_paramset + ' rp WHERE report_paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + 
					' INSERT INTO #temp_paramset ([last_paramset])
					  SELECT 1
					  FROM   ' + @rfx_report_paramset + '
					  WHERE  page_id = @report_page_id
					  HAVING COUNT(*) = 1
					 ' 
		--print @sql
		EXEC (@sql)
		
		IF EXISTS(SELECT 1 FROM #temp_paramset) 
		BEGIN
			EXEC spa_ErrorHandler -1, 'report_paramset', 'spa_rfx_report_paramset_dhx', 'DB Error', 'Cannot delete Paramset. Atleast one paramset should be present.', ''
			DROP TABLE #temp_paramset
			RETURN
		END
		ELSE
		BEGIN
			BEGIN TRAN
			SET @sql = 'DECLARE @dataset_paramset_id VARCHAR(500)
						SELECT @dataset_paramset_id = COALESCE(@dataset_paramset_id + '','' ,'''') + CAST(report_dataset_paramset_id AS VARCHAR)
						FROM   ' + @rfx_report_dataset_paramset + '
						WHERE  paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + '
						
						DELETE FROM ' + @rfx_report_dataset_paramset + '
						WHERE paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50)) + '
						
						DELETE FROM ' + @rfx_report_param + '
						WHERE dataset_paramset_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@dataset_paramset_id))'
			--print @sql
			EXEC (@sql)
			
			SET @sql = 'DELETE FROM ' + @rfx_report_paramset + '
						WHERE report_paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50))
			--print @sql
			EXEC (@sql) 
			
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_paramset_dhx', 'Success', 'Data succesfully deleted.', @process_id			
			COMMIT
		END
	END TRY
	BEGIN CATCH
		DECLARE @edit_error_desc1 VARCHAR(1000)
		DECLARE @edit_error_no1 INT
		SET @edit_error_no1 = ERROR_NUMBER()		
		SET @edit_error_desc1 = ERROR_MESSAGE()
		
		--print 'Error:' + @edit_error_desc1
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		EXEC spa_ErrorHandler @edit_error_no1, 'Reporting FX', 'spa_rfx_report_paramset_dhx', @edit_error_desc1, 'Failed to delete data.', ''		
	END CATCH
END
IF @flag = 'h'
BEGIN
	--one used report dataset per tab
	SET @sql = 'SELECT DISTINCT rd.report_dataset_id [Report Datasets ID],
					CASE WHEN CHARINDEX(''[adiha_process].[dbo].[batch_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[batch_export_'') 
						WHEN CHARINDEX(''[adiha_process].[dbo].[report_export_'', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], ''[report_export_'')
						ELSE ds.[name]
					END 
                    + '' ('' + rd.[alias] + '')'' [name],
                   rd.source_id
                FROM   ' + @rfx_report_dataset + ' rd
                INNER JOIN data_source ds ON ds.data_source_id = rd.source_id
                LEFT JOIN (
                	SELECT rpc.root_dataset_id 
					FROM ' + @rfx_report_page_chart + ' rpc
                	WHERE rpc.page_id = ' + CAST(@page_id AS VARCHAR(10))+ '
					
					UNION ALL				
					
					SELECT rpt.root_dataset_id 
					FROM ' + @rfx_report_page_tablix + ' rpt
                	WHERE rpt.page_id = ' + CAST(@page_id AS VARCHAR(10))+ '
                	
                	union all
                	
                	SELECT rpc.root_dataset_id 
					FROM ' + @rfx_report_page_gauge + ' rpc
                	WHERE rpc.page_id = ' + CAST(@page_id AS VARCHAR(10))+ '
                	
                	
                ) rd_used ON rd_used.root_dataset_id = rd.report_dataset_id
	            WHERE rd.root_dataset_id IS NULL
                '
    --print @sql 
    EXEC (@sql)
END
IF @flag = 'c'
BEGIN
    /*
    * Example dataset 
    * sdh
    *	sdd (child of sdh)
    *	sdp (child of sdh)
    *	
    * If only sdp.* columns are used in Tablix/Chart, we need to show columns of all connected dataset (sdh, sdd, sdp).
    * First set in CROSS Apply gives self, i.e. sdp
    * Second set gives parent set, i.e. sdh
    * Third set gives silblings (means child of sdh), means sdd and sdp
    * 
    * Unioning all gives the required result (sdh, sdd, sdp)
    *
    */

	IF OBJECT_ID('tempdb..#temp_custom_report') IS NOT NULL
		DROP TABLE #temp_custom_report
	CREATE TABLE #temp_custom_report (is_custom_report INT)
	EXEC('INSERT INTO #temp_custom_report SELECT is_custom_report FROM ' + @rfx_report)

	DECLARE @is_custom_report INT
	SELECT @is_custom_report = is_custom_report FROM #temp_custom_report

    SET @sql =
			'SELECT DISTINCT 
				' + CASE WHEN @is_custom_report = 1 THEN ' COALESCE(rd.root_dataset_id,rd.report_dataset_id,1) ' ELSE ' rd.root_dataset_id ' END + ' [root_dataset_id],
				dsc.[data_source_column_id],
				rd.[alias] + ''.'' + dsc.[alias] AS [name],' 
				+ CASE WHEN @is_custom_report = 1 THEN ' rd.report_dataset_id ' ELSE ' rd.dataset_id ' END + ' dataset_id,
				dsc.[name] column_name
				,rw.name [widget_type],
				dsc.append_filter,
				dsc.param_data_source,
				dsc.param_default_value	
			FROM '

	IF @is_custom_report = 1
	BEGIN
		SET @sql = @sql + @rfx_report + ' r
			INNER JOIN ' + @rfx_report_page + ' rp ON r.report_id = rp.report_id AND rp.report_page_id = ' + CAST(@page_id AS VARCHAR) + '
			INNER JOIN ' + @rfx_report_dataset + ' rd ON r.report_id = rd.report_id'
	END
	ELSE 
	BEGIN
		SET @sql = @sql + '	(
				SELECT rcc.dataset_id, rpc.root_dataset_id  
				FROM ' + @rfx_report_chart_column + ' rcc 
				INNER JOIN ' + @rfx_report_page_chart + ' rpc ON rcc.chart_id = rpc.report_page_chart_id 
					AND rpc.page_id = ' + CAST(@page_id AS VARCHAR)+ '
				
				UNION 				
				
				SELECT rtc.dataset_id, rpt.root_dataset_id 
				FROM  ' + @rfx_report_tablix_column + ' rtc
				INNER JOIN '  + @rfx_report_page_tablix + ' rpt ON rtc.tablix_id = rpt.report_page_tablix_id 
					AND rpt.page_id = ' + CAST(@page_id AS VARCHAR) + '
				
				UNION 				
				
				SELECT rtc.dataset_id, rpt.root_dataset_id 
				FROM  ' + @rfx_report_gauge_column + ' rtc
				INNER JOIN '  + @rfx_report_page_gauge + ' rpt ON rtc.gauge_id = rpt.report_page_gauge_id 
					AND rpt.page_id = ' + CAST(@page_id AS VARCHAR) + '

				
				UNION 
				
				SELECT 1, 1 
								
			) used_ds
			CROSS APPLY (
				--used dataset i.e. self (sdp)
				SELECT ISNULL(rd_used.root_dataset_id, report_dataset_id) root_dataset_id, report_dataset_id dataset_id, source_id, alias 
				FROM ' + @rfx_report_dataset + ' rd_used
				WHERE rd_used.report_dataset_id = used_ds.dataset_id
				
				UNION
				
				--root dataset (sdh)
				SELECT report_dataset_id, report_dataset_id dataset_id, source_id, alias 
				FROM  ' + @rfx_report_dataset + ' rd_root
				WHERE rd_root.report_dataset_id = used_ds.root_dataset_id
						
				UNION
				
				--child of parent of used dataset if it is a leaf dataset (i.e. sibling, which is sdd, sdp)
				--child of used dataset if it is a root dataset
				SELECT rd_child.root_dataset_id root_dataset_id, rd_child.report_dataset_id dataset_id, rd_child.source_id, rd_child.alias 
				FROM  ' + @rfx_report_dataset + ' rd_used
				LEFT JOIN ' + @rfx_report_dataset + ' rd_parent ON rd_parent.report_dataset_id = rd_used.root_dataset_id
				INNER JOIN ' + @rfx_report_dataset + ' rd_child ON rd_child.root_dataset_id = ISNULL(rd_parent.report_dataset_id, rd_used.report_dataset_id)
				WHERE rd_used.report_dataset_id = used_ds.dataset_id
			) rd '
	END	
	
	SET @sql = @sql + '	
			INNER JOIN data_source ds ON  rd.source_id = ds.data_source_id
			INNER JOIN data_source_column dsc ON  dsc.source_id = ds.data_source_id
			INNER JOIN report_widget rw on rw.report_widget_id = dsc.widget_id '
			
			IF @column_id IS NOT NULL
				SET @sql = @sql + ' where dsc.[data_source_column_id]=' + @column_id 
			 
			SET @sql = @sql + ' ORDER BY [name]'
	
    --print @sql 
    EXEC (@sql)
END
IF @flag = 'x' -- populate the required parameter list
BEGIN
    SET @sql = 'SELECT NULL report_paramset_id, NULL, NULL, NULL, NULL, rd.report_dataset_id dataset_id ,
                       dsc.[data_source_column_id] column_id,
                       NULL, NULL, NULL, NULL, NULL, rd.[alias] + ''.['' + dsc.[name] + '']=''''@'' + dsc.[name] + '''''''' where_part, 
                       CASE 
                            WHEN rd.root_dataset_id IS NULL THEN rd.[report_dataset_id]
                            ELSE rd.root_dataset_id
                       END root_dataset_id
					   --, 1 required
                       ,rw.name [widget_type]
                       --dsc.append_filter
                       ,NULL as label,
					   dsc.required_filter required_filter
                FROM   ' + @rfx_report_dataset + ' rd
                INNER JOIN data_source ds ON  rd.source_id = ds.data_source_id
                INNER JOIN data_source_column dsc ON  dsc.source_id = ds.data_source_id
                INNER JOIN report_widget rw on rw.report_widget_id = dsc.widget_id				
                WHERE  rd.report_id = ' + CAST(@report_id AS VARCHAR(10)) + '
                AND dsc.required_filter is not null ORDER BY rd.root_dataset_id ASC'
    --print @sql 
    EXEC (@sql)
END

IF @flag = 'y'
BEGIN
	declare @sec_filter_info varchar(max) = cast(@xml as varchar(max))

	--declare @sec_filter_info varchar(max) = 'as_of_date=NULL,block_define_id=NULL,block_type=NULL,commodity_id=NULL,counterparty_id=NULL,create_ts_from=NULL,create_ts_to=NULL,deal_id=NULL,deal_lock=NULL,detail_phy_fin_flag=NULL,formula_curve_id=NULL,legal_entity=NULL,source_deal_header_id=NULL,source_deal_type_id=NULL,template_id=NULL,term_end=NULL,term_start=NULL,update_ts_from=NULL,update_ts_to=NULL,counterparty_type=NULL,buy_sell_flag=NULL,confirm_status_id=NULL,contract_id=NULL,deal_date_from=NULL,deal_date_to=NULL,deal_status_id=NULL,deal_sub_type_type_id=NULL,index_id=NULL,location_id=NULL,period_from=NULL,period_to=NULL,physical_financial_flag=NULL,pnl_source_value_id=NULL,source_counterparty_id=NULL,sub_id=NULL,stra_id=NULL,book_id=NULL,sub_book_id=NULL,to_as_of_date=NULL,trader_id=NULL_-_88B0C7FB_CEE5_4431_81FF_F5A5100C72C4'
	
	declare @sec_filter_info2 varchar(max) = SUBSTRING(@sec_filter_info, CHARINDEX('_-_', @sec_filter_info, 0)+3, len(@sec_filter_info))
	declare @sec_filter_info1 varchar(max) = replace(@sec_filter_info, '_-_' + @sec_filter_info2, '')

	--select @sec_filter_info1, @sec_filter_info2

	
	DECLARE @rfx_report_filter_string VARCHAR(500) = dbo.FNAProcessTableName('rfx_report_filter_string', @user_name, @sec_filter_info2)

	--select '@flag'='q', '@xml'=@sec_filter_info1, '@process_id'=@sec_filter_info2

	EXEC spa_rfx_report_paramset_dhx @flag='q', @xml=@sec_filter_info1, @process_id=@sec_filter_info2, @result_to_table=@rfx_report_filter_string

	
	declare @report_filter_final varchar(max) = @sec_filter_info1
	SET @sqln = '
	SELECT @report_filter_final = rfs.report_filter  
	FROM ' + @rfx_report_filter_string + '  rfs
	'
	EXEC sp_executesql @sqln, N'@report_filter_final VARCHAR(max) OUTPUT', @report_filter_final OUT

	SET @sql = '
    SELECT rp.[name], ''' + @user_name + '''[user_name], dbo.FNAGetMSSQLVersion() [major_version_no], ''' + @report_filter_final + ''' [report_filter_final]
    FROM   ' + @rfx_report_paramset + ' rp
    WHERE  rp.report_paramset_id = ' + @report_paramset_id + '
	'
	EXEC(@sql)
END

IF @flag = 'm'
BEGIN
    SELECT dbo.FNAGetMSSQLVersion() [major_version_no]
END
IF @flag = 'r'
BEGIN

    SELECT REPLACE(name,' ', '_') name, item_id FROM (
		SELECT rpt.name AS name,rpt.report_page_tablix_id AS item_id FROM report_paramset rp 
		Left JOIN report_page_tablix rpt ON rp.page_id =rpt.page_id
		WHERE rp.report_paramset_id = @report_paramset_id
		UNION ALL 
		SELECT rpc.name AS name, rpc.report_page_chart_id AS item_id FROM report_paramset rp 
		Left JOIN report_page_chart rpc ON rp.page_id =rpc.page_id
		WHERE rp.report_paramset_id = @report_paramset_id
		UNION  ALL
		SELECT rpg.name AS name, rpg.report_page_gauge_id AS item_id FROM report_paramset rp 
		Left JOIN report_page_gauge rpg ON rp.page_id =rpg.page_id
		WHERE rp.report_paramset_id = @report_paramset_id
	) x WHERE item_id IS NOT null
END
-- process secondary filters with values and build  final parameter report filter string
IF @flag = 'q'
BEGIN
    /** ADD UP SECONDARY FILTERS AND ITS VALUES THAT ARE EXCLUDED DUE TO SAME ALIAS START **/
	declare @report_filter varchar(max) = cast(@xml as varchar(max))
	DECLARE @rfx_secondary_filters_info VARCHAR(500) = dbo.FNAProcessTableName('rfx_secondary_filters_info', @user_name, @process_id)
	
	if OBJECT_ID('tempdb..##secondary_filters_info') is not null
		drop table ##secondary_filters_info
	exec ('select * into ##secondary_filters_info from ' + @rfx_secondary_filters_info)

	declare @secondary_filters varchar(max) = ''

	if OBJECT_ID('tempdb..#tmp_filter_info') is not null
		drop table #tmp_filter_info
	select SUBSTRING(scsv.item, 0, charindex('=', scsv.item, 0)) filter_col, SUBSTRING(scsv.item, charindex('=', scsv.item, 0), len(scsv.item)) filter_value
	into #tmp_filter_info
	from dbo.SplitCommaSeperatedValues(@report_filter) scsv
	
	SELECT @secondary_filters = STUFF(
		(SELECT ','  + sfi.col_name + oa_fv.filter_value
		from ##secondary_filters_info sfi
		outer apply (
			select tfi.filter_value
			from #tmp_filter_info tfi
			where tfi.filter_col = sfi.filter_col
		) oa_fv
		FOR XML PATH(''))
	, 1, 1, '')

	--select * from ##secondary_filters_info
	--select * from #tmp_filter_info tfi
	
	if OBJECT_ID('tempdb..##secondary_filters_info') is not null
		drop table ##secondary_filters_info

	set @report_filter = @report_filter + isnull(',' + nullif(@secondary_filters, ''), '')

	-- if result to table, dump result to process table
	if nullif(@result_to_table,'') is not null
	begin
		set @sql = ' 
		if object_id(''' + @result_to_table + ''') is not null
			drop table ' + @result_to_table + '

		select ''' + @report_filter + ''' [report_filter] 
		into ' + @result_to_table + '
		' 
		exec(@sql)
	end
	else
	begin
		select @report_filter as [report_filter]
	end
	
	
	/** ADD UP SECONDARY FILTERS AND ITS VALUES THAT ARE EXCLUDED DUE TO SAME ALIAS END **/
END

IF @flag = 'z'
BEGIN
	SET @sql = '
    SELECT rp.export_report_name,
		   rp.export_location,
		   rp.output_file_format, 
		   rp.delimiter,
		   rp.xml_format,
		   rp.compress_file,
		   rp.report_header
    FROM  report_paramset rp
    WHERE  rp.report_paramset_id = ' + @report_paramset_id + '
	'
	EXEC(@sql)
END
