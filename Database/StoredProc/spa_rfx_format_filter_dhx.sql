


IF OBJECT_ID(N'[dbo].[spa_rfx_format_filter_dhx]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_rfx_format_filter_dhx]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Formatting report filter on report manager module for Preview mode.

	Parameters
	@flag: Operation flag
	@paramset_id: Report Paramset ID
	@parameter_string: Report Filter String
	@process_id: Process ID used for process tables for preview mode
*/
CREATE PROCEDURE [dbo].[spa_rfx_format_filter_dhx]
	  @flag CHAR(1)
    , @paramset_id VARCHAR(10) = NULL
	, @parameter_string VARCHAR(MAX)
	, @process_id VARCHAR(50)
AS
SET NOCOUNT ON 
/*

DECLARE  @flag CHAR(1) = 'f'
, @paramset_id VARCHAR(10) = 22330
, @parameter_string VARCHAR(5000) = 'as_of_date=2015-06-01,curve_id=5071!4433'
, @process_id VARCHAR(50)='6705DF80_8FE9_49B8_BD15_5641DBA1B76C'

--*/
DECLARE @sql							VARCHAR(MAX)  
DECLARE @user_name						VARCHAR(50) = dbo.FNADBUser()
DECLARE @rfx_report_param				VARCHAR(300) = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
DECLARE @rfx_report_dataset_paramset	VARCHAR(300) = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
DECLARE @rfx_report_paramset			VARCHAR(300) = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id)

IF @flag = 'f'
BEGIN TRY

	IF OBJECT_ID(N'tempdb..#report_filter_list') IS NOT NULL
		DROP TABLE #report_filter_list
	
	IF OBJECT_ID(N'tempdb..#report_filter_parameter_list') IS NOT NULL
	DROP TABLE #report_filter_parameter_list

	CREATE TABLE #report_filter_list (
		filter_list_id INT IDENTITY(1,1) PRIMARY KEY
		, paramset_id INT
		, paramset_name VARCHAR(100) COLLATE DATABASE_DEFAULT 
		, filter_name VARCHAR(500) COLLATE DATABASE_DEFAULT 
		, filter_alias VARCHAR(500) COLLATE DATABASE_DEFAULT 
		, widget_id INT
		, hidden BIT
		, param_data_source VARCHAR(5000) COLLATE DATABASE_DEFAULT 
		, filter_value VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
		, filter_display_label NVARCHAR(500) COLLATE DATABASE_DEFAULT  
		, filter_display_value NVARCHAR(MAX) COLLATE DATABASE_DEFAULT 
		, param_order VARCHAR(3) COLLATE DATABASE_DEFAULT 

	)
	
	CREATE TABLE #report_filter_parameter_list (
		filter_id INT IDENTITY(1,1) PRIMARY KEY
		, filter_label VARCHAR(500) COLLATE DATABASE_DEFAULT 
		, filter_value VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
	)
	
	INSERT INTO #report_filter_parameter_list(filter_label, filter_value)
	SELECT 
		SUBSTRING(s.item, 1, CHARINDEX('=', s.item) - 1)
		, REPLACE(SUBSTRING(s.item, CHARINDEX('=', s.item) + 1, LEN(s.item)), '!', ',')
	FROM dbo.SplitCommaSeperatedValues('' + @parameter_string + '') s

	SET @sql = '
	INSERT INTO #report_filter_list
	(
		paramset_id,
		paramset_name,
		filter_name,
		filter_alias,
		widget_id,
		hidden,
		param_data_source,
		filter_value,
		filter_display_label,
		filter_display_value,
		param_order
	)
	SELECT DISTINCT rp2.report_paramset_id
		, rp2.name
		, dsc.name
		, COALESCE(rp.label, dsc.alias, dsc.name, ca.filter_label)
		, dsc.widget_id
		, rp.hidden
		, dsc.param_data_source
		, CASE WHEN ca.filter_value = ''NULL'' THEN NULL ELSE ca.filter_value END
		, REPLACE(COALESCE(rp.label, dsc.alias, dsc.name, ca.filter_label), '' ID'', '''')
		, NULL
		, ca.filter_id
	FROM #report_filter_parameter_list ca
	LEFT JOIN data_source_column dsc ON dsc.NAME = ca.filter_label
	LEFT JOIN ' + @rfx_report_param + ' rp ON dsc.data_source_column_id = rp.column_id
	LEFT JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
	LEFT JOIN ' + @rfx_report_paramset + ' rp2 ON rp2.report_paramset_id = rdp.paramset_id
	WHERE rp2.report_paramset_id = ' + @paramset_id + ' OR dsc.NAME IS NULL
	ORDER BY ca.filter_id
	'
	EXEC(@sql)

	UPDATE rfl
		SET rfl.filter_name = rfl.filter_alias,
			rfl.filter_display_label = rfl2.filter_display_label + ' To',
			rfl.filter_alias = rfl2.filter_alias + ' To',
			rfl.widget_id = rfl2.widget_id
	FROM #report_filter_list rfl
	INNER JOIN #report_filter_list rfl2 ON REPLACE(rfl.filter_display_label, '2_', '') = rfl2.filter_name
	WHERE rfl.filter_display_label LIKE '%2_%'
	
	--SELECT * FROM #report_filter_list rfl
	
	DECLARE @filter_list_id INT, @widget_id INT, @param_data_source VARCHAR(5000), @filter_value NVARCHAR(4000)
		, @filter_display_value NVARCHAR(MAX)=null
	
	IF CURSOR_STATUS('global','cursor_filter') >= -1
	BEGIN
		DEALLOCATE cursor_filter
	END

	DECLARE cursor_filter CURSOR FOR
	SELECT filter_list_id, widget_id, param_data_source, filter_value FROM #report_filter_list rfl

	OPEN cursor_filter
	FETCH NEXT FROM cursor_filter INTO @filter_list_id, @widget_id, @param_data_source, @filter_value

	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			SET @filter_display_value = NULL
			IF @widget_id = 8 --SUBBOOK
			BEGIN
				SELECT @filter_display_value = STUFF(
					(SELECT ',' + ssbm.logical_name
					from source_system_book_map ssbm
					INNER JOIN dbo.SplitCommaSeperatedValues(@filter_value) scsv ON scsv.item = ssbm.book_deal_type_map_id
					FOR XML PATH(''))
					, 1, 1, '')
			END
			ELSE IF @widget_id IN (3, 4, 5) --SUBSIDIARY, STRATEGY, BOOK
			BEGIN
				SELECT @filter_display_value = STUFF(
					(SELECT ',' + ph.entity_name
					FROM portfolio_hierarchy ph
					INNER JOIN dbo.SplitCommaSeperatedValues(@filter_value) scsv ON scsv.item = ph.entity_id
					FOR XML PATH(''))
					, 1, 1, '')
			END
			ELSE IF @widget_id IN (7) --DATABROWSER
			BEGIN
				IF @filter_value IS NOT NULL
				BEGIN
					DECLARE  @grid_sql	VARCHAR(500)=NULL
							, @grid_cols VARCHAR(1000)=NULL
							, @grid_name VARCHAR(100)=NULL
							, @grid_col1	VARCHAR(50)=NULL
							, @grid_col2	VARCHAR(50)=NULL
					SELECT  @grid_name = agd.grid_name,
							@grid_sql = agd.load_sql,
							@grid_cols = COALESCE(@grid_cols + ', ', '') + CAST(agc.column_name AS VARCHAR(50)) + ' NVARCHAR(500)  '
					FROM  adiha_grid_definition agd
					INNER JOIN adiha_grid_columns_definition agc ON CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
					WHERE agd.grid_name = @param_data_source
					ORDER BY agc.column_order ASC

					SELECT @grid_col1 = c1.column_name
					FROM (SELECT ROW_NUMBER() 
							OVER (ORDER BY agc.column_order) AS Row,  agc.column_name
					FROM  adiha_grid_definition agd
					INNER JOIN adiha_grid_columns_definition agc ON CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
					WHERE agd.grid_name = @param_data_source) c1 WHERE c1.row = 1
						
					SELECT @grid_col2 = c2.column_name
					FROM (SELECT ROW_NUMBER() 
							OVER (ORDER BY agc.column_order) AS ROW,  agc.column_name
					FROM  adiha_grid_definition agd
					INNER JOIN adiha_grid_columns_definition agc ON CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
					WHERE agd.grid_name = @param_data_source) c2 WHERE c2.row = 2
			
					DECLARE @t_sql NVARCHAR(1000)
					SET @t_sql = '
						IF OBJECT_ID(''tempdb..#grid_data'') IS NOT NULL
							DROP TABLE #grid_data

						CREATE TABLE #grid_data' + '(row_id INT IDENTITY(1,1),' + @grid_cols + ')
						INSERT INTO #grid_data
						EXEC(''' + REPLACE(@grid_sql,'''','''''')  + ''')
				
						SELECT @filter_display_value =  STUFF((
										SELECT '','' + ' + @grid_col2 + ' 
										FROM #grid_data 
										WHERE '+ @grid_col1+' IN (' + @filter_value + ')  FOR XML PATH('''')
									), 1, 1, '''')
					'
					EXECUTE sp_executesql @t_sql, N'@filter_display_value NVARCHAR(MAX) OUTPUT', @filter_display_value = @filter_display_value OUTPUT
				END
				ELSE
				BEGIN
					SELECT @filter_display_value = NULL
				END
			END
			ELSE IF @widget_id = 2--DROPDOWN
			BEGIN
				IF OBJECT_ID(N'tempdb..#tmp_dd_results') IS NOT NULL
				DROP TABLE #tmp_dd_results

				CREATE TABLE #tmp_dd_results (
					value VARCHAR(100) COLLATE DATABASE_DEFAULT 
					, label VARCHAR(500) COLLATE DATABASE_DEFAULT 
					, [state] VARCHAR(20) COLLATE DATABASE_DEFAULT 
				)

				INSERT INTO #tmp_dd_results
				EXEC spa_execute_query @query = @param_data_source, @call_from = 'rfx'

				SELECT @filter_display_value = STUFF(
						(SELECT ',' + dd.label 
						FROM #tmp_dd_results dd
						INNER JOIN dbo.SplitCommaSeperatedValues(@filter_value) scsv ON scsv.item = dd.value
						FOR XML PATH(''))
						, 1, 1, '')
			
			END
			ELSE IF @widget_id = 6 --DATETIME
			BEGIN
				SET @filter_display_value = dbo.FNADateFormat(@filter_value)
			END
			ELSE SET @filter_display_value = @filter_value
		END TRY
		BEGIN CATCH -- IF ANY UNHANDLED ERROR OCCURED SET AS FILTER DISPLAY VALUE AS PROVIDED FILTER VALUE
			SET @filter_display_value = @filter_value
		END CATCH
		
		UPDATE #report_filter_list
		SET filter_display_value = @filter_display_value
		WHERE filter_list_id = @filter_list_id

		FETCH NEXT FROM cursor_filter INTO @filter_list_id, @widget_id, @param_data_source, @filter_value
	END
	CLOSE cursor_filter
	DEALLOCATE cursor_filter

	SELECT * FROM #report_filter_list rfl

END TRY
BEGIN CATCH
	DECLARE @err_msg VARCHAR(2000) = ERROR_MESSAGE()
	EXEC spa_ErrorHandler
	@error = -1,
	@msgType1 = 'spa_rfx_format_filter_dhx',
	@msgType2 = 'DB Error',
	@msgType3 = 'Report Manager',
	@msg = 'Error in formatting report filter',
	@recommendation = @err_msg,
	@logFlag = NULL
END CATCH
