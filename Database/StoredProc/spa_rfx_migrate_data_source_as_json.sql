IF OBJECT_ID(N'[dbo].[spa_rfx_migrate_data_source_as_json]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_migrate_data_source_as_json]
GO
  
SET ANSI_NULLS ON
GO
  
SET QUOTED_IDENTIFIER ON
GO

/**
	Export and Import User Defined Data Source in JSON Format

	Parameters 
	@flag			: Operation flag
	@data_source_id : Data Source ID
	@json_file_name	: JSON File Name
	@import_as_name	: Import Name
	@call_from		: Call From
	
*/

CREATE PROCEDURE [dbo].[spa_rfx_migrate_data_source_as_json]  
	@flag			CHAR(2),
	@data_source_id VARCHAR(100) = NULL,
	@json_file_name VARCHAR(2000) = NULL,
	@import_as_name VARCHAR(2000) = NULL,
	@call_from VARCHAR(100) = NULL
AS

SET NOCOUNT ON

/** * DEBUG QUERY START *
	
	declare	@flag char(2),
	@data_source_id varchar(100) = NULL,
	@json_file_name varchar(2000) = NULL,
	@import_as_name varchar(2000) = NULL,
	@call_from VARCHAR(100) = NULL
	
	--select @flag='u', @data_source_id = '2820', @call_from = 'UserDefinedView'
	--select @flag='w', @json_file_name='AR Aging View.json'
	--select @flag='y', @json_file_name='AR Aging View.json', @import_as_name='New AR Aging View'
-- * DEBUG QUERY END * */

BEGIN TRY

	--variable declaration
	DECLARE @document_path VARCHAR(2000)
	SELECT @document_path = document_path FROM connection_string
	DECLARE @json_file_path NVARCHAR(2000)

	IF @flag = 'u'
	BEGIN
		DECLARE @data_source_name VARCHAR(2000) 
		SELECT @data_source_name = [name] FROM data_source WHERE data_source_id = @data_source_id

		--variable declaration for storing json output, tablewise
		DECLARE @output_data_source NVARCHAR(MAX)
			,@output_data_source_column NVARCHAR(MAX)
		
		--data_source
		SET @output_data_source = (
		SELECT ds.[type_id] [data_source_type_id]
			, ds.[name] [data_source_name]
			, ds.alias [data_source_alias]
			, ds.[description] [description]
			, ds.[tsql] [tsql]
			, ds.[system_defined]
			, ds.[category]
		FROM [data_source] ds
		WHERE ds.data_source_id = @data_source_id
		FOR JSON PATH
		,INCLUDE_NULL_VALUES
		,WITHOUT_ARRAY_WRAPPER
		)

		--data_source_column
		SET @output_data_source_column = (
		SELECT ds.[name] [data_source_name]
			, dsc.[name] [column_name]
			, dsc.[alias] [column_alias]
			, dsc.[reqd_param]
			, dsc.[widget_id]
			, dsc.[datatype_id]
			, dsc.[param_data_source]
			, dsc.[param_default_value]
			, dsc.[append_filter]
			, dsc.[tooltip]
			, dsc.[column_template]
			, dsc.[key_column]
			, dsc.[required_filter]
		FROM data_source_column dsc
		INNER JOIN [data_source] ds ON ds.data_source_id = dsc.source_id
		WHERE ds.data_source_id = @data_source_id
		FOR JSON PATH
		,INCLUDE_NULL_VALUES
		)
				
		--build final json string and write to file 
		BEGIN
			DECLARE @output_data_source_export NVARCHAR(MAX)='{}'
	
			SELECT @output_data_source_export = 
			JSON_MODIFY(
			JSON_MODIFY(@output_data_source_export
			,'$.data_source'					,JSON_QUERY(@output_data_source)) --data_source
			,'$.data_source_column'				,JSON_QUERY(@output_data_source_column)) --data_source_column

			SET @json_file_name = @data_source_name + '.json'
			SET @json_file_path = @document_path + '\temp_Note\' + @json_file_name

			DECLARE @result NVARCHAR(MAX)
			EXEC spa_write_to_file @content=@output_data_source_export, @appendContent='n', @filename=@json_file_path, @result=@result output
	
			SET @result = ISNULL(@result, 'CLR Output NULL')
			--error handling part
			IF @result = '1'
			BEGIN
				EXEC spa_ErrorHandler 0,
					'Datasource Export',
					'spa_rfx_migrate_data_source_as_json',
					'Success',
					@json_file_path,
					@json_file_name
			END
			ELSE
			BEGIN
				;THROW 51000, @result, 1
			END
		END

	END
	
	ELSE IF @flag in ('w','y','z') --w=>datasource name existence check
	BEGIN
		SET @json_file_path = @document_path + '\temp_Note\' + @json_file_name
		--load json file content to variable
		BEGIN
			DECLARE @json_file_content VARCHAR(MAX)
			DECLARE @openrowset_command NVARCHAR(1000)

			SET @openrowset_command = N'SELECT @json_file_content1 = BULKCOLUMN	FROM OPENROWSET(BULK ''' + @json_file_path + ''', SINGLE_BLOB) JSON'

			EXEC sp_executesql @openrowset_command, N'@json_file_content1 varchar(MAX) OUTPUT', @json_file_content1 = @json_file_content OUTPUT
		END

		--check json format, if invalid throw error (will be caught in catch block)
		IF (ISJSON(@json_file_content) <> 1) 
		BEGIN 
			;THROW 51000, 'Invalid JSON Format.', 1
		END

		--compare name provided as import_as incase of import as condition.
		DECLARE @data_source_name_in_json NVARCHAR(2000) = ISNULL(NULLIF(@import_as_name,''),JSON_VALUE(@json_file_content, '$.data_source.data_source_name'))
		DECLARE @data_source_name_exists TINYINT = 0
		SET @data_source_name =  ISNULL(NULLIF(@import_as_name,''),@data_source_name_in_json)
		
		IF EXISTS(SELECT TOP 1 1 FROM data_source WHERE name = @data_source_name)
		BEGIN
			SET @data_source_name_exists = 1
		END

		IF @flag = 'z'
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM data_source WHERE name = @data_source_name)  --call from import as option only.
			BEGIN
					IF EXISTS (SELECT TOP 1 1
								FROM data_source ds
								INNER JOIN report_dataset rd ON rd.source_id = ds.data_source_id
								WHERE ds.name = @data_source_name)
					BEGIN
						EXEC spa_ErrorHandler -1,
						'Datasource Import',
						'spa_rfx_migrate_data_source_as_json',
						'Alert',
						'View already used in Report.',
						''
					END
					ELSE IF EXISTS (SELECT TOP 1 1
								FROM data_source ds
								INNER JOIN alert_table_definition atd ON atd.data_source_id = ds.data_source_id
								where ds.name = @data_source_name)
					BEGIN
						EXEC spa_ErrorHandler -1,
						'Datasource Import',
						'spa_rfx_migrate_data_source_as_json',
						'Alert',
						'View already used in Alert/Worflow.',
						''
					END
					ELSE
					BEGIN
						select 'r' [exists_check] ,@json_file_name [file_name], @data_source_name data_source_name,1 [data_source_exists], 'Data already exist. Are you sure you want to replace data? ' msg
					END
			END
			ELSE
			BEGIN
				SELECT 's' [exists_check] ,@json_file_name [file_name], @data_source_name data_source_name,0 [data_source_exists], '' msg
			END
			RETURN 
		END -- end of z flag
		
		
		--import tasks
		BEGIN 
			--drop temp tables for imported json
			BEGIN
			IF OBJECT_ID('tempdb..#data_source_ixp') IS NOT NULL DROP TABLE #data_source_ixp
			IF OBJECT_ID('tempdb..#data_source_column_ixp') IS NOT NULL DROP TABLE #data_source_column_ixp
			end

			--dump json data to respective temp tables
			BEGIN
			--data_source
				SELECT x.[data_source_type_id]
					,x.[data_source_name]
					,x.[data_source_alias]
					,x.[description]
					,x.[tsql]
					,x.[system_defined]
					,x.[category]
				INTO #data_source_ixp
				FROM OPENJSON(@json_file_content, '$.data_source')
				WITH(
					data_source_type_id		INT				'$.data_source_type_id'
					,data_source_name       NVARCHAR(200)	'$.data_source_name'
					,data_source_alias      NVARCHAR(20)	'$.data_source_alias'
					,[description]          NVARCHAR(1000)	'$.description'
					,[tsql]                 NVARCHAR(max)	'$.tsql'
					,system_defined         BIT				'$.system_defined'
					,category               INT				'$.category'
				) x

				--data_source_column
				SELECT x.[data_source_name]
					,x.[column_name]
					,x.[column_alias]
					,x.[reqd_param]
					,x.[widget_id]
					,x.[datatype_id]
					,x.[param_data_source]
					,x.[param_default_value]
					,x.[append_filter]
					,x.[tooltip]
					,x.[column_template]
					,x.[key_column]
					,x.[required_filter]
				INTO #data_source_column_ixp
				FROM OPENJSON(@json_file_content, '$.data_source_column')
				WITH(
					data_source_name		NVARCHAR(200)	'$.data_source_name'
					,column_name            NVARCHAR(200)	'$.column_name'
					,column_alias           NVARCHAR(20)	'$.column_alias'
					,reqd_param		        NVARCHAR(20)	'$.reqd_param'
					,reqd_para				NVARCHAR(20)	'$.reqd_para'
					,widget_id              INT				'$.widget_id'
					,datatype_id            INT				'$.datatype_id'
					,param_data_source      NVARCHAR(2000)	'$.param_data_source'
					,param_default_value    NVARCHAR(200)	'$.param_default_value'
					,append_filter			NVARCHAR(200)	'$.append_filter'
					,tooltip                NVARCHAR(500)	'$.tooltip'
					,column_template        INT				'$.column_template'
					,key_column             INT				'$.key_column'
					,required_filter        BIT				'$.required_filter'
				) x
			
			END
	
			--main import task
			BEGIN
				BEGIN TRANSACTION
					--import task for data source
					IF EXISTS(SELECT TOP 1 1 FROM #data_source_ixp)
					BEGIN
						DECLARE @new_ds_alias VARCHAR(10)
						SELECT @new_ds_alias = data_source_alias FROM #data_source_ixp

						/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
						IF EXISTS(SELECT TOP 1 1 FROM data_source WHERE alias = @new_ds_alias and NAME <> @data_source_name)
						BEGIN
							SELECT TOP 1 @new_ds_alias = @new_ds_alias + CAST(s.n AS VARCHAR(5))
							FROM seq s
							LEFT JOIN data_source ds ON ds.alias = @new_ds_alias + CAST(s.n AS VARCHAR(5))
							WHERE ds.data_source_id IS NULL
								AND s.n < 10

							--RAISERROR ('Datasource alias already exists on system.', 16, 1);
						END
						
						IF NOT EXISTS (SELECT 1 
								   FROM data_source 
								   WHERE [name] = @data_source_name
								   ) 
						BEGIN
							INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], system_defined,category)
							SELECT TOP 1 [data_source_type_id], @data_source_name, @new_ds_alias, [description],CAST('' AS VARCHAR(MAX)) + [tsql], [system_defined]
								,[category]
								FROM #data_source_ixp
						END
							
						IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
							DROP TABLE #data_source_column	
						CREATE TABLE #data_source_column(column_id INT)
						
						IF EXISTS (SELECT 1 
								   FROM data_source_column dsc 
								   INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
										AND ds.[name] = @data_source_name
									INNER JOIN #data_source_column_ixp dsi ON dsi.data_source_name = @data_source_name
										AND dsi.[column_name] = dsc.[name]
										)
						BEGIN
							UPDATE dsc  
							SET alias = dsi.column_alias
								   , reqd_param = dsi.reqd_param
								   , widget_id = dsi.widget_id
								   , datatype_id = dsi.datatype_id
								   , param_data_source = dsi.param_data_source
								   , param_default_value = dsi.param_default_value
								   , append_filter = dsi.append_filter
								   , tooltip = dsi.tooltip
								   , column_template = dsi.column_template
								   , key_column = dsi.key_column
								   , required_filter = dsi.required_filter
							OUTPUT INSERTED.data_source_column_id 
							INTO #data_source_column(column_id)
							FROM data_source_column dsc
							INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
												AND ds.[name] = @data_source_name
							INNER JOIN #data_source_column_ixp dsi ON dsi.data_source_name = @data_source_name
										AND dsi.column_name = dsc.[name]
						END	
						ELSE
						BEGIN
							INSERT INTO data_source_column(
											source_id
											, [name]
											, alias
											, reqd_param
											, widget_id
											, datatype_id
											, param_data_source
											, param_default_value
											, append_filter
											, tooltip
											, column_template
											, key_column
											, required_filter
											)
							OUTPUT INSERTED.data_source_column_id 
							INTO #data_source_column(column_id)
							SELECT ds.data_source_id AS source_id
									, dsi.column_name
									, dsi.column_alias
									, dsi.reqd_param
									, dsi.widget_id
									, dsi.datatype_id
									, dsi.param_data_source
									, dsi.param_default_value
									, dsi.append_filter
									, dsi.tooltip
									, dsi.column_template
									, dsi.key_column
									, dsi.required_filter				
							FROM #data_source_column_ixp dsi
							INNER JOIN data_source ds ON ds.[name] = @data_source_name
							LEFT JOIN data_source_column dsc ON ds.data_source_id = dsc.source_id
									AND ds.[name] = @data_source_name
									AND dsi.column_name = dsc.[name]
							WHERE dsc.data_source_column_id IS NULL
						END 
	
						DELETE dsc
						FROM data_source_column dsc 
						INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
							AND ds.[name] = @data_source_name
						LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
						WHERE tdsc.column_id IS NULL

					END

				COMMIT

				EXEC spa_ErrorHandler 0,
					'Datasource Import',
					'spa_rfx_migrate_data_source_as_json',
					'Success',
					'Successfully imported View.',
					''
			END
		END
	END
	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;
	DECLARE @err_msg VARCHAR(MAX) = ERROR_MESSAGE()
	EXEC spa_ErrorHandler -1,
		'Data Source Import/Export',
		'spa_rfx_migrate_data_source_as_json',
		'DB Error',
		@err_msg,
		''

	
END CATCH
GO