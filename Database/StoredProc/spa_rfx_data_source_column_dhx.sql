IF OBJECT_ID(N'[dbo].[spa_rfx_data_source_column_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_data_source_column_dhx]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 2012-09-19
-- Description: Add/Update Operations for Datasource columns
 
-- Params:
--	@flag					CHAR	- Operation flag
--	@process_id
--	@data_source_column_id INT 
--	@source_id INT
--	@name VARCHAR(100)
--	@alias VARCHAR(500)

-- Sample Use:
-- 1. EXEC [spa_rfx_data_source_column_dhx] 's'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_data_source_column_dhx]
	@flag CHAR(1),
	@source_id INT = NULL,
	@xml TEXT = NULL,
	@column_id INT = NULL
AS
set nocount on
	DECLARE @sql VARCHAR(MAX)

IF @flag = 'i'
BEGIN
	
	IF @xml IS NOT NULL
	BEGIN
		DECLARE @idoc  INT
				
		--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

		-- Create temp table to store the report_name and report_hash
		IF OBJECT_ID('tempdb..#rfx_data_source_solumn') IS NOT NULL
			DROP TABLE #rfx_data_source_column
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT	DataSourceColumnID [data_source_column_id]
				, [Name] [name] 
				, Alias [alias] 
				, RequiredParam [reqd_param] 
				, Widget [widget_id] 
				, DataType [datatype_id] 
				, ParamDataSource [param_data_source]  
				, ParamDefaultValue [param_default_value] 
				, AppendFilter [append_filter]
		INTO #rfx_data_source_column
		FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH (
			DataSourceColumnID INT
			, [Name] VARCHAR(100)
			, Alias VARCHAR(100) 
			, RequiredParam INT
			, Widget INT
			, DataType INT 
			, ParamDataSource VARCHAR(255)   
			, ParamDefaultValue VARCHAR(100)  
			, AppendFilter INT
		)
		
	END
	BEGIN TRY
		BEGIN TRAN
			SET @sql = 'DELETE dsc
						FROM data_source_column dsc
						WHERE  dsc.source_id = ' + CAST(@source_id AS VARCHAR(10)) + '
						AND dsc.data_source_column_id NOT IN (SELECT data_source_column_id FROM #rfx_data_source_column)
			
						MERGE data_source_column AS dsc
						USING #rfx_data_source_column AS temp_dsc ON temp_dsc.data_source_column_id = dsc.data_source_column_id
						WHEN MATCHED THEN
							UPDATE SET dsc.source_id = ' + CAST(@source_id AS VARCHAR(30)) + ',
									 dsc.[name] = temp_dsc.[name]
									, dsc.alias = temp_dsc.alias
									, dsc.reqd_param = temp_dsc.reqd_param
									, dsc.widget_id = temp_dsc.widget_id
									, dsc.datatype_id = temp_dsc.datatype_id
									, dsc.param_data_source = temp_dsc.param_data_source
									, dsc.param_default_value = temp_dsc.param_default_value
									, dsc.append_filter = temp_dsc.append_filter
						WHEN NOT MATCHED THEN
							INSERT (source_id, [name], alias, reqd_param, widget_id, datatype_id, param_data_source, param_default_value, append_filter)
							VALUES( ' + CAST(@source_id AS VARCHAR(10)) + ' 
										, temp_dsc.[name]
										, temp_dsc.[alias]
										, temp_dsc.[reqd_param]
										, temp_dsc.[widget_id]
										, temp_dsc.[datatype_id]
										, temp_dsc.[param_data_source]
										, temp_dsc.[param_default_value]
										, temp_dsc.[append_filter] )
						;
						'
			EXEC spa_print @sql
			EXEC(@sql)
			EXEC spa_ErrorHandler 0,
             'Reporting FX',
             'spa_rfx_data_source_column_dhx',
             'Success',
             'Data successfully saved.',
             ''
		COMMIT          
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		EXEC spa_ErrorHandler @@ERROR,
             'Reporting FX',
             'spa_rfx_data_source_column_dhx',
             'DB Error',
             'Failed to save data.',
             ''
	END CATCH
END
ELSE IF @flag = 'g'
BEGIN
	SELECT dsc.[name], dsc.alias, dsc.reqd_param
	FROM data_source_column dsc
	WHERE dsc.source_id = @source_id 
END
ELSE IF @flag = 'z'
BEGIN
	SELECT dsc.source_id [source_id], dsc.data_source_column_id [column_id], dsc.[name], dsc.alias, dsc.reqd_param, dsc.datatype_id
	FROM data_source_column dsc
	WHERE dsc.source_id = @source_id 
END
ELSE IF @flag = 'o'
BEGIN
	DECLARE @dropdown_query VARCHAR(1000)
	SELECT @dropdown_query = param_data_source 
	FROM data_source_column dsc
	WHERE dsc.data_source_column_id = @column_id

	EXEC(@dropdown_query)
END