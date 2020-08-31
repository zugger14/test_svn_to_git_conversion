IF OBJECT_ID(N'[dbo].[spa_rfx_save_data_source_column]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_save_data_source_column]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: padhikari@pioneersolutionsglobal.com
-- Create date: 2012-09-10
-- Description: Add Data Source Columns
 
-- Params:
--	@flag					CHAR	- Operation flag
--	@process_id				Process ID
--  @data_source_id			Data Source ID
--	@xml					Data Source Columns Details

-- Sample Use:
-- EXEC spa_rfx_save_data_source_column 'i', 'PROCESS_ID', 1,'<Root><PSRecordset DataSourceColumnID="12" ColumnName="SomeName" Alias="sn" RequiredParam="1" Widget="7" DataType="71" ParamDataSource="" ParamDefaultValue="" AppendFilter=""></PSRecordset></Root>'
-- EXEC spa_rfx_save_data_source_column 'i', 'EF1F59E4_5A0A_4544_9CD4_2D9DA8C35F76', 231, '<Root><PSRecordset Name="type_id" Alias="fsdfsds" RequiredParam="1" Widget="" DataType="" ParamDataSource=""  ParamDefaultValue="" AppendFilter="1" ></PSRecordset><PSRecordset Name="name" Alias="sdfsdf" RequiredParam="0" Widget="" DataType="" ParamDataSource=""  ParamDefaultValue="" AppendFilter="0" ></PSRecordset></Root>'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_save_data_source_column]
	@flag				CHAR(1),
	@process_id			VARCHAR(50) = NULL,
	@data_source_id 	INT = NULL,
	@xml				VARCHAR(MAX) = NULL
AS
IF @process_id IS NULL
    SET @process_id = dbo.FNAGetNewID()

DECLARE @sql          VARCHAR(MAX)  
DECLARE @user_name    VARCHAR(50) = dbo.FNADBUser() 

IF @xml IS NOT NULL
BEGIN
	DECLARE @idoc  INT
			
	--Create an internal representation of the XML document.
	EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

	-- Create temp table to store the report_name and report_hash
	IF OBJECT_ID('tempdb..#rfx_data_source_column_staging') IS NOT NULL
		DROP TABLE #rfx_data_source_column_staging

	-- Execute a INSERT-SELECT statement that uses the OPENXML rowset provider.
	SELECT DataSourceColumnID [data_source_column_id],
	       @data_source_id [source_id],
	       [Name] [name],
	       Alias [alias],
	       Tooltip [tooltip],
	       --RequiredParam [reqd_param],
		   iif(RequiredFilter = -1, null, RequiredFilter) [required_filter], --by default keep optional view level filter
	       Widget [widget_id],
	       DataType [datatype_id],
	       ParamDataSource [param_data_source],
	       ParamDefaultValue [param_default_value],
	       --AppendFilter [append_filter],
	       ColumnTemplate [column_template],
	       KeyColumn [key_column]
	INTO #rfx_data_source_column_staging		       
	FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
	WITH (
		   DataSourceColumnID	INT,
		   [Name]				VARCHAR(100),
		   Alias				VARCHAR(100),
		   Tooltip				VARCHAR(100),
		   --RequiredParam		VARCHAR(100),
		   RequiredFilter		VARCHAR(100),
		   Widget				VARCHAR(100),
		   DataType				VARCHAR(100),
		   ParamDataSource		VARCHAR(8000),
		   ParamDefaultValue	VARCHAR(100),
		   --AppendFilter			VARCHAR(100),
		   ColumnTemplate		VARCHAR(100),
		   KeyColumn			VARCHAR(100)
	)	
	
	UPDATE #rfx_data_source_column_staging SET [tooltip] = NULL WHERE  [tooltip] = ''	
	UPDATE #rfx_data_source_column_staging SET [param_data_source] = NULL WHERE [param_data_source] = ''
	UPDATE #rfx_data_source_column_staging SET [param_default_value] = NULL WHERE [param_default_value] = ''

	IF @flag = 'u'
	DECLARE @output VARCHAR(8000)
	BEGIN
		IF EXISTS(	
			SELECT 1 FROM data_source_column dsc
			INNER JOIN report_tablix_column rtc ON rtc.column_id = dsc.data_source_column_id
			WHERE  dsc.source_id = @data_source_id
				AND dsc.data_source_column_id NOT IN (SELECT data_source_column_id FROM #rfx_data_source_column_staging)
		)
		BEGIN
			SELECT @output = COALESCE(@output + ', ', '') + dsc.[name] FROM data_source_column dsc
			INNER JOIN report_tablix_column rtc ON rtc.column_id = dsc.data_source_column_id
			WHERE  dsc.source_id = @data_source_id
				AND dsc.data_source_column_id NOT IN (SELECT data_source_column_id FROM #rfx_data_source_column_staging)
				
			SET @output =  @output + ' Columns used in Report Tablix.'			
			EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source_column', ' Columns used in Report Tablix.', @output, ''
			RETURN	
		END

		IF EXISTS(	
			SELECT * FROM data_source_column dsc
			INNER JOIN report_chart_column rcc ON rcc.column_id = dsc.data_source_column_id
			WHERE  dsc.source_id = @data_source_id
				AND dsc.data_source_column_id NOT IN (SELECT data_source_column_id FROM #rfx_data_source_column_staging)
		)
		BEGIN
			SELECT @output = COALESCE(@output + ', ', '') + dsc.[name] FROM data_source_column dsc
			INNER JOIN report_chart_column rcc ON rcc.column_id = dsc.data_source_column_id
			WHERE  dsc.source_id = @data_source_id
				AND dsc.data_source_column_id NOT IN (SELECT data_source_column_id FROM #rfx_data_source_column_staging)
				
			SET @output =  @output + ' Columns used in Report Charts.'		
			EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source_column', ' Columns used in Report Charts.', @output, ''
			RETURN	
		END

		IF EXISTS(	
			SELECT * FROM data_source_column dsc
			INNER JOIN report_param rp ON rp.column_id = dsc.data_source_column_id
			WHERE  dsc.source_id = @data_source_id
				AND dsc.data_source_column_id NOT IN (SELECT data_source_column_id FROM #rfx_data_source_column_staging)
		)
		BEGIN
			SELECT @output = COALESCE(@output + ', ', '') + dsc.[name] FROM data_source_column dsc
			INNER JOIN report_param rp ON rp.column_id = dsc.data_source_column_id
			WHERE  dsc.source_id = @data_source_id
				AND dsc.data_source_column_id NOT IN (SELECT data_source_column_id FROM #rfx_data_source_column_staging)
				
			SET @output =  @output + ' Columns used in Report Parameters.'		
			EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source_column', ' Columns used in Report Params.', @output, ''
			RETURN	
		END
	END
	
	BEGIN TRY
		BEGIN TRAN
		--delete removed columns from main table
		DELETE dsc
		FROM data_source_column dsc
		LEFT JOIN #rfx_data_source_column_staging rdscs ON dsc.data_source_column_id = rdscs.data_source_column_id
		WHERE dsc.source_id = @data_source_id
			AND rdscs.data_source_column_id IS NULL
		
		--SET NOCOUNT, XACT_ABORT ON;
	
		MERGE data_source_column AS d
		USING #rfx_data_source_column_staging AS dd ON d.data_source_column_id = ISNULL(dd.data_source_column_id, 0) 
		WHEN MATCHED THEN 
			UPDATE 
				SET d.source_id = dd.source_id ,
					d.[name] = dd.[name],
					d.alias = dd.alias,
					d.tooltip = dd.tooltip,
					--d.reqd_param = dd.reqd_param,
					d.required_filter = dd.required_filter,
					d.widget_id = dd.widget_id,
					d.datatype_id = dd.datatype_id,
					d.param_data_source = dd.param_data_source,
					d.param_default_value = dd.param_default_value,
					--d.append_filter = dd.append_filter,
					d.column_template = dd.column_template,
					d.key_column = dd.key_column
		WHEN NOT MATCHED THEN
			INSERT (	
				source_id,
				[name],
				alias,
				tooltip,
				--reqd_param,
				required_filter,
				widget_id,
				datatype_id,
				param_data_source,
				param_default_value,
				--append_filter,
				column_template,
				key_column
			)
			VALUES
			(
				dd.source_id,
				dd.[name],
				dd.alias,
				dd.tooltip,
				--dd.reqd_param,
				dd.required_filter,
				dd.widget_id,
				dd.datatype_id,
				dd.param_data_source,
				dd.param_default_value,
				--dd.append_filter,
				dd.column_template,
				dd.key_column
			);
	
		COMMIT;
		
		SELECT 'Success' [ErrorCode],
		       'Reporting FX' [Module],
		       'spa_rfx_save_data_source_column' [Area],
		       'Success' [Status],
		       'Data succesfully saved.' [Message],
		       @process_id [Recommendation]
	END TRY
	BEGIN CATCH
		ROLLBACK
		--print error_message()
		SELECT 'Error' [ErrorCode],
		       'Reporting FX' [Module],
		       'spa_rfx_save_data_source_column' [Area],
		       'DB Error' [Status],
		       'Failed to save data.' [Message],
		       '' [Recommendation]
	END CATCH
	RETURN	
END
ELSE
BEGIN
	EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_save_data_source_column', 'Error', 'Saved Data Source Columns.', 'XML not supplied.'		             
END           
