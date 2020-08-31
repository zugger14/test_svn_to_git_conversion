IF OBJECT_ID('spa_exposed_excel_addin_reports') IS NOT NULL
	DROP PROC spa_exposed_excel_addin_reports
GO

CREATE PROC spa_exposed_excel_addin_reports
	@option CHAR(1) = NULL,
	@report_paramset_name VARCHAR(1024) = NULL,
	@report_paramset_id VARCHAR(1024)  = NULL ,
	@saved_filter_name VARCHAR(1024) = NULL,
	@ixp_rule_hash VARCHAR(1024) = NULL,
	@databrowser_name VARCHAR(1024) = NULL,
	@databrowser_values VARCHAR(MAX) = NULL
AS

IF @option IS NULL
BEGIN
	IF OBJECT_ID('tempdb..#exposed_reports') IS NOT NULL
    DROP TABLE tempdb..#exposed_reports

	CREATE TABLE #exposed_reports
	(
		report_category        VARCHAR(512) COLLATE DATABASE_DEFAULT,
		report_name         VARCHAR(512) COLLATE DATABASE_DEFAULT,
		--paramset_name		VARCHAR(512) COLLATE DATABASE_DEFAULT,
		report_id           INT,
		report_type         INT,
		paramset_id			NVARCHAR(MAX)
	)
	INSERT INTO #exposed_reports
	EXEC spa_view_report @flag = 'x'

	-- Removed duplicate report with same name while there is same report in multiple group
	SELECT t.paramset_id [Id],
		   rp.name [Name],
		   rp.paramset_hash [ParamsetHash]
	FROM   (
			   SELECT DISTINCT er.report_id,
					  paramset_id
	FROM   #exposed_reports er
		   )t
		   INNER JOIN report r
				ON  r.report_id = t.report_id
		   INNER JOIN report_paramset rp
				ON  t.paramset_id = rp.report_paramset_id
	WHERE ISNULL(r.is_excel, 0) = 1
	ORDER BY rp.name
END	
ELSE IF @option = 'P'	-- List Parameter
BEGIN
	SELECT DISTINCT dsc.name [Name],
       MAX(rpm.operator) [OperatorId],
       MAX(COALESCE(rpm.label, dsc.alias, dsc.name)) [Label],
       MAX(dsc.alias) [Alias],
       CAST(rpm.optional AS VARCHAR) [Optional],
       MAX(dsc.widget_id) [WidgetId],
       MAX(dsc.datatype_id) [DatatypeId],
       MAX(ISNULL(dsc.param_data_source, '')) [DataSource],
       --MAX(ISNULL(dsc.param_default_value, 'NULL')) [DefaultValue],
	   MAX(ISNULL(NULLIF(rpm.initial_value,''), 'NULL')) [DefaultValue],
	   MAX(ISNULL(NULLIF(rpm.initial_value2,''), 'NULL')) [DefaultValue2],
       MAX(rw.name) [WidgetName],
       MAX(rpm.param_order) [Order]
	FROM   report r
		   INNER JOIN report_page rp
				ON  rp.report_id = r.report_id
		   INNER JOIN report_paramset rps
				ON  rps.page_id = rp.report_page_id
		   INNER JOIN report_dataset_paramset rdp
				ON  rdp.paramset_id = rps.report_paramset_id
		   INNER JOIN report_param rpm
				ON  rdp.report_dataset_paramset_id = rpm.dataset_paramset_id
		   LEFT JOIN data_source_column dsc
				ON  dsc.data_source_column_id = rpm.column_id
		   LEFT JOIN report_datatype rdt
				ON  rdt.report_datatype_id = dsc.datatype_id
		   LEFT JOIN report_widget rwt
				ON  rwt.report_widget_id = dsc.widget_id
		   LEFT JOIN dbo.report_widget rw
				ON  dsc.widget_id = rw.report_widget_id
		   LEFT JOIN data_source ds
				ON  ds.data_source_id = dsc.source_id
	WHERE  rps.paramset_hash = @report_paramset_id
		   AND rpm.hidden <> 1 --WHERE rps.report_paramset_id = @report_paramset_id
		   AND rpm.hidden <> 1
	GROUP BY
		   dsc.name,rpm.optional
	ORDER BY
		   MAX(rpm.param_order)

END 
ELSE IF @option = 'f'	-- List Saved filter name
BEGIN
	IF OBJECT_ID('tempdb..#saved_report_filters') IS NOT NULL 
		DROP TABLE tempdb..#saved_report_filters
	CREATE TABLE #saved_report_filters ([Values] INT, [Text] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, [Order] INT  )
	
	DECLARE @xml as xml = '<ApplicationFilter report_id="' + CAST(@report_paramset_id as varchar) + '"></ApplicationFilter>'
	INSERT INTO #saved_report_filters ([Values], [Text] , [Order])
	EXEC spa_application_ui_filter @flag='s', @xml_string= @xml

	SELECT [Values] [Id], [Text] [Name] , [Order] FROM #saved_report_filters
END

ELSE IF @option = 'g' -- Load filter values.
BEGIN 
	IF OBJECT_ID('tempdb..#saved_report_filters_values') IS NOT NULL 
		DROP TABLE tempdb..#saved_report_filters_values

	CREATE TABLE #saved_report_filters_values ([FarrmsFieldId] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, [FieldValue] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  )
	
	DECLARE @xml2 as xml = '<ApplicationFilter name="'+ @saved_filter_name +'" report_id="' + CAST(@report_paramset_id AS VARCHAR) + '"/>'
	INSERT INTO #saved_report_filters_values ([FarrmsFieldId] , [FieldValue])
	EXEC spa_application_ui_filter @flag = 'a', @xml_string = @xml2

	SELECT [FarrmsFieldId], [FieldValue] [Value] FROM #saved_report_filters_values
END
ELSE IF @option = 'h' -- Databrowser intial values
BEGIN
	DECLARE @columns VARCHAR(MAX)
	DECLARE @key_column VARCHAR(100)
	DECLARE @load_sql VARCHAR(MAX)

	DECLARE @column_label_name VARCHAR(100)
	SELECT TOP 1 @key_column = agcd.column_name, @load_sql = agd.load_sql, @column_label_name = rs1.[ColumnName]
	FROM   adiha_grid_columns_definition agcd
		   INNER JOIN adiha_grid_definition agd
				ON  agcd.grid_id = agd.grid_id
		   CROSS APPLY (SELECT TOP 1
							   agcd1.column_name [ColumnName]
						FROM   adiha_grid_columns_definition agcd1
						WHERE  agcd1.grid_id = agd.grid_id
						AND  agd.grid_name = @databrowser_name
							   AND agcd1.column_order > 1
						ORDER BY
							   agcd.column_order) rs1
	WHERE  agd.grid_name = @databrowser_name
	ORDER BY
		   agcd.column_order
       
	SELECT @columns = COALESCE(@columns + ',', '') + agcd.column_name + 
		   ' VARCHAR(2000) '
	FROM   adiha_grid_columns_definition agcd
		   INNER JOIN adiha_grid_definition agd
				ON  agcd.grid_id = agd.grid_id
	WHERE  agd.grid_name = @databrowser_name
	ORDER BY
		   agcd.column_order

	DECLARE @process_id NVARCHAR(100) = REPLACE(NEWID(), '-', '_')
	DECLARE @sql VARCHAR(MAX)
	DECLARE @table_name VARCHAR(1000) = 'adiha_process.dbo.' + @databrowser_name + '_' + @process_id

	SET @sql = 'CREATE TABLE ' + @table_name + '(' + @columns + 
		') 
	INSERT INTO ' + @table_name + '
	 ' + @load_sql + ' '

	EXEC (@sql)
	SET @sql = 'select DISTINCT ' + @column_label_name + ' From ' + @table_name + CASE WHEN ISNULL(@databrowser_values,'') <> '' THEN ' WHERE ' + @key_column +  ' IN (' + @databrowser_values + ')' ELSE '' END 
	EXEC(@sql)


END
ELSE IF @option = 'r' -- List Import Rules
BEGIN
	IF OBJECT_ID('tempdb..#available_import_rules') IS NOT NULL
		DROP TABLE tempdb..#available_import_rules
	
	CREATE TABLE #available_import_rules
	(
		category           NVARCHAR(1024) COLLATE DATABASE_DEFAULT,
		ixp_rules_name     NVARCHAR(1024) COLLATE DATABASE_DEFAULT,
		ixp_rules_id       INT,
		rule_type          NVARCHAR(50) COLLATE DATABASE_DEFAULT,
		updatetable        NCHAR(50)COLLATE DATABASE_DEFAULT,
		system_rule        NVARCHAR(10)COLLATE DATABASE_DEFAULT,
		[owner]            NVARCHAR(200)COLLATE DATABASE_DEFAULT,
		ixp_rule_hash		NVARCHAR(1024) COLLATE DATABASE_DEFAULT
	)
	INSERT INTO #available_import_rules	
	EXEC spa_ixp_rules @flag = 'e'
	
	SELECT ixp_rules_id [Id],
	       ISNULL([category], 'N/A') [Category],
	       ixp_rules_name [Name],
	       ixp_rule_hash [IxpRuleHash]
	FROM   #available_import_rules
	WHERE  rule_type = 'import'
	       --AND data_source IN ('Excel', 'Flat File')
	ORDER BY [category],ixp_rules_name
END
ELSE IF @option = 's' -- List columns of rules
BEGIN
	SELECT iidm.source_column_name [Column]
	FROM   ixp_rules AS ir
	       INNER JOIN ixp_import_data_mapping AS iidm
	            ON  ir.ixp_rules_id = iidm.ixp_rules_id
			INNER JOIN ixp_columns ic
				ON iidm.dest_table_id = ic.ixp_table_id AND ic.ixp_columns_id =  iidm.dest_column
	WHERE  ir.ixp_rule_hash = @ixp_rule_hash 
	AND iidm.source_column_name <> ''
	GROUP BY iidm.source_column_name, ic.seq, iidm.ixp_import_data_mapping_id
	ORDER BY ISNULL(ic.seq,(999999 + iidm.ixp_import_data_mapping_id)),  MIN(iidm.ixp_import_data_mapping_id)
END

GO