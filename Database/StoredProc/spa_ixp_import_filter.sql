IF OBJECT_ID(N'[dbo].[spa_ixp_import_filter]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_import_filter]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_ixp_import_filter]    
    @flag VARCHAR(100),
	@rules_id	INT = NULL,
	@process_id VARCHAR(300) = NULL,
	@data_source_type INT = NULL,
	@filter_group VARCHAR(200) = NULL,
	@xml_data XML = NULL,
	@pre_filter_group VARCHAR(200) = NULL


AS
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @ixp_import_filter VARCHAR(400)
DECLARE @user_name VARCHAR(100)
DECLARE @idoc INT

SET @user_name = dbo.FNADBUser() 
SET @ixp_import_filter = dbo.FNAProcessTableName('ixp_import_filter', @user_name, @process_id)

IF @flag = 'filter_json'
BEGIN
	DECLARE @final_json_string VARCHAR(MAX), @final_json_string1 VARCHAR(MAX)
	
	SELECT @final_json_string = STUFF((SELECT ',' + '{"type":"block","list": [{"type": "checkbox","name": "' + CAST(sdv.value_id AS VARCHAR) + '","label": "' + sdv.code + '  ","position": "label-right","labelWidth": "auto","tooltip":"' + sdv.code + '","checked":false, "disabled": true},{"type": "newcolumn"},{"type": "input","name": "' + 'Input_' + CAST(sdv.value_id AS VARCHAR) + '","label": "","offsetLeft":"5","position": "label-right","tooltip": "' + sdv.code + '","value":"","hidden":true,"rows":"2","inputWidth":250}]}'
			FROM static_data_value sdv
			WHERE sdv.[type_id] = '112200' AND sdv.[category_id] = @data_source_type 
			ORDER BY value_id
	FOR XML PATH('')), 1, 1, '')

	SET @final_json_string = '[{"type": "block","list": [' + @final_json_string + ']}]'
	SELECT @final_json_string [filter_json]
END

ELSE IF @flag = 'filter_list'
BEGIN
	SET @sql = 'SELECT	ixf.filter_group [f_id], 
				ixf.filter_group [f_value], 
				CAST(ixf.filter_id AS VARCHAR) + ''_'' + CAST(ixf.ixp_import_filter_id AS VARCHAR) [c_id], 
				sdv.code + '' : '' + ixf.filter_value [c_value]
		FROM ' + @ixp_import_filter + ' ixf
		INNER JOIN static_data_value sdv ON sdv.value_id = ixf.filter_id
		WHERE ixf.ixp_rules_id = ' + CAST(@rules_id AS VARCHAR) + ' AND ixf.ixp_import_data_source = ' + CAST(@data_source_type AS VARCHAR)
	EXEC(@sql)
END

ELSE IF @flag = 'filter_data'
BEGIN
	SET @sql = ' SELECT iifs.ixp_rules_id,
	                    iifs.filter_group,
	                    iifs.filter_id,
	                    iifs.filter_value,
	                    iifs.ixp_import_data_source
	             FROM ' +  @ixp_import_filter + ' iifs
				 WHERE iifs.ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20)) 
				 + ' AND iifs.filter_group = ''' + @filter_group + ''''
				 + ' AND iifs.ixp_import_data_source = ' + CAST(@data_source_type AS VARCHAR(20)) 
	--print(@sql)	 
	EXEC(@sql)    
END

ELSE IF @flag = 'load_process_table'
BEGIN
	SET @sql = 'DELETE FROM ' + @ixp_import_filter + ' 
	INSERT INTO ' + @ixp_import_filter + ' (
		ixp_rules_id,
		filter_group,
		filter_id,
		filter_value,
		ixp_import_data_source
	)
	SELECT ixp_rules_id,
		filter_group,
		filter_id,
		filter_value,
		ixp_import_data_source 
	FROM ixp_import_filter WHERE ixp_rules_id = ' + CAST(@rules_id AS VARCHAR)
	
	EXEC(@sql)

	SELECT 'Success' [result]
END

ELSE IF @flag = 'save_filter'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		IF OBJECT_ID('tempdb..#tmp_import_filter') IS NOT NULL
			DROP TABLE #tmp_import_filter
		
		SELECT	filter_id		[filter_id],
				filter_value	[filter_value]
		INTO #tmp_import_filter
		FROM OPENXML(@idoc, '/Root/Import_Filter', 1)
		WITH (
			filter_id		INT,
			filter_value		VARCHAR(MAX)
		)

		SET @sql = 'DELETE FROM ' + @ixp_import_filter 
			+ ' WHERE ixp_rules_id = ' + CAST(@rules_id AS VARCHAR)
			+ ' AND filter_group = ''' + @filter_group + ''''
			+ ' AND ixp_import_data_source = ' + CAST(@data_source_type AS VARCHAR)
		EXEC(@sql)

		SET @sql = '
			INSERT INTO ' + @ixp_import_filter + ' (
				ixp_rules_id,
				filter_group,
				filter_id,
				filter_value,
				ixp_import_data_source
			)
			SELECT ' + CAST(@rules_id AS VARCHAR) + ',
				''' + @filter_group + ''',
				filter_id,
				filter_value,
				' + CAST(@data_source_type AS VARCHAR) + ' 
			FROM #tmp_import_filter'
		EXEC(@sql)

		EXEC spa_ErrorHandler 0
					, 'import_filter'
					, 'spa_import_filter'
					, 'Success' 
					, 'Changes have been saved successfully.'
					, ''
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	 
		EXEC spa_ErrorHandler -1
			, 'import_filter'
			, 'spa_import_filter'
			, 'Error'
			, 'Fail to save.'
			, ''
	END CATCH
END

ELSE IF @flag = 'delete_filter_group'
BEGIN
	BEGIN TRY
		
		SET @sql = 'DELETE FROM ' + @ixp_import_filter 
			+ ' WHERE ixp_rules_id = ' + CAST(@rules_id AS VARCHAR)
			+ ' AND filter_group = ''' + @filter_group + ''''
			+ ' AND ixp_import_data_source = ' + CAST(@data_source_type AS VARCHAR)
		EXEC(@sql)

		EXEC spa_ErrorHandler 0
					, 'import_filter'
					, 'spa_import_filter'
					, 'Success' 
					, 'Changes have been saved successfully.'
					, ''
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	 
		EXEC spa_ErrorHandler -1
			, 'import_filter'
			, 'spa_import_filter'
			, 'Error'
			, 'Fail to save.'
			, ''
	END CATCH
END

ELSE IF @flag = 'number_of_filters'
BEGIN
	SET @sql = '
	SELECT sdv.value_id, CASE WHEN ISNULL(cnt.number_of_filter,0) =  0 THEN 0 ELSE 1 END [number_of_filter] 
	FROM (
		SELECT sdv.value_id [value_id] FROM static_data_value sdv WHERE sdv.[type_id] = 21400
		UNION 
		SELECT -1
	) sdv 
	OUTER APPLY (
		SELECT ixp_import_data_source, COUNT(ixp_import_filter_id) number_of_filter
		FROM ' + @ixp_import_filter + ' 
		WHERE ixp_rules_id = ' + CAST(@rules_id AS VARCHAR) + '
				AND sdv.value_id = ixp_import_data_source
		GROUP BY ixp_import_data_source
	) cnt'

	EXEC(@sql)
END

ELSE IF @flag = 'rename_filter_group'
BEGIN
	BEGIN TRY
		
		SET @sql = 'UPDATE ' + @ixp_import_filter 
			+ ' SET filter_group = ''' + @filter_group + ''''
			+ ' WHERE ixp_rules_id = ' + CAST(@rules_id AS VARCHAR)
			+ ' AND filter_group = ''' + @pre_filter_group + ''''
			+ ' AND ixp_import_data_source = ' + CAST(@data_source_type AS VARCHAR)
		EXEC(@sql)

		EXEC spa_ErrorHandler 0
					, 'import_filter'
					, 'spa_import_filter'
					, 'Success' 
					, 'Changes have been saved successfully.'
					, ''
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	 
		EXEC spa_ErrorHandler -1
			, 'import_filter'
			, 'spa_import_filter'
			, 'Error'
			, 'Fail to save.'
			, ''
	END CATCH
END
