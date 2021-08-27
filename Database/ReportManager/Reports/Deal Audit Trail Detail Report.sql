BEGIN TRY
		BEGIN TRAN

		DECLARE @report_id_dest INT 
	

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

		IF EXISTS (SELECT 1 FROM dbo.report WHERE report_hash='47413D6C_CE9B_47D6_AF30_FE4FFAADDCD5')
		BEGIN
			DECLARE @report_id_to_delete INT
			SELECT @report_id_to_delete = report_id FROM report WHERE report_hash = '47413D6C_CE9B_47D6_AF30_FE4FFAADDCD5'

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

			EXEC spa_rfx_report @flag='d', @report_id=@report_id_to_delete, @retain_privilege=1, @process_id=NULL

		
		END
		--RETAIN APPLICATION FILTER DETAILS END (PART1)
		

		declare @report_copy_name varchar(200)
		
		set @report_copy_name = isnull(@report_copy_name, 'Copy of ' + 'Deal Audit Trail Detail Report')
		

		INSERT INTO report ([name], [owner], is_system, is_excel, is_mobile, report_hash, [description], category_id)
		SELECT TOP 1 'Deal Audit Trail Detail Report' [name], 'farrms_admin' [owner], 0 is_system, 1 is_excel, 0 is_mobile, '47413D6C_CE9B_47D6_AF30_FE4FFAADDCD5' report_hash, 'Standard Deal Audit Trail Detail Report' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
		FROM sys.objects o
		LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = 'Deal' AND sdv_cat.type_id = 10008 
		SET @report_id_dest = SCOPE_IDENTITY()
		
		

		INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
		SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'SDAV1' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Deal Audit View'
			AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
		LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
			AND rd_root.report_id = @report_id_dest		
		

	INSERT INTO report_page(report_id, [name], report_hash, width, height)
	SELECT @report_id_dest AS report_id, 'Deal Audit Trail Detail Report' [name], '47413D6C_CE9B_47D6_AF30_FE4FFAADDCD5' report_hash, 12 width,11.69 height
	

		INSERT INTO report_paramset(page_id, [name], paramset_hash, report_status_id, export_report_name, export_location, output_file_format, delimiter, xml_format, report_header, compress_file, category_id)
		SELECT TOP 1 rpage.report_page_id, 'Deal Audit Trail Detail Report', '1277DBD3_444C_4DE9_B1A2_1831275CC7CC', 3,'','','.xlsx',',', 
		-100000,'n','n',NULL	
		FROM sys.objects o
		INNER JOIN report_page rpage 
			on rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
		ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
	

		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, NULL AS where_part, 0
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = @report_id_dest
			AND rd.[alias] = 'SDAV1'
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 10 AS param_order, 0 AS param_depth, 'Field Name' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'field'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 7 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'flow_end'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 6 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'flow_start'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 8 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'source_deal_header_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'update_date_from'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 5 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'update_date_to'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 9 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'user_action'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'stra_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SDAV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SDAV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Deal Audit View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_id'	
	

		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'Deal Audit Trail Detail Report' [name], '9.36' width, '3.0533333333333332' height, '0' [top], '0' [left],2 AS group_mode,1 AS border_style,0 AS page_break,1 AS type_id,1 AS cross_summary,2 AS no_header,'' export_table_name, 0 AS is_global
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'SDAV1' 
	

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 4 column_order,NULL aggregation, NULL functions, 'User Action' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'user_action' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 0 column_order,NULL aggregation, NULL functions, 'Deal ID' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, 1 default_sort_order, 2 sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Deal ID' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 6 column_order,NULL aggregation, NULL functions, 'Leg' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'leg' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 7 column_order,NULL aggregation, NULL functions, 'Header/Detail' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Header Detail' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 9 column_order,NULL aggregation, NULL functions, 'Prior Value' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'prior value' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 10 column_order,NULL aggregation, NULL functions, 'Current Value' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'current value' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 8 column_order,NULL aggregation, NULL functions, 'Field' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'field' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 3 column_order,NULL aggregation, NULL functions, 'Updated By' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Update User' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 2 column_order,NULL aggregation, NULL functions, 'Updated Date' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, 2 default_sort_order, 2 sort_direction, 0 custom_field, 4 render_as,-1 column_template,NULL negative_mark,NULL currency,3 date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'update_timestamp' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 5 column_order,NULL aggregation, NULL functions, 'Term Start' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'flow_start' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 1 column_order,NULL aggregation, NULL functions, 'Deal Reference ID' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SDAV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Ref ID' 
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'current value' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Current Value' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Deal ID' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Deal ID' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'field' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Field' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'flow_start' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Term Start' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Header Detail' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Header/Detail' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'leg' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Leg' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'prior value' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Prior Value' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Ref ID' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Deal Reference ID' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Update User' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Updated By' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'user_action' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'User Action' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Audit Trail Detail Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Deal Audit View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'update_timestamp' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Updated Date' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	

		--RETAIN APPLICATION FILTER DETAILS START (PART2)
		UPDATE pm
		SET inserted_paramset_id = rp.report_paramset_id
		FROM #paramset_map pm
		INNER JOIN report_paramset rp
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
	
COMMIT 

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;
		
	DECLARE @error_message VARCHAR(MAX) = ERROR_MESSAGE()
	RAISERROR(@error_message,16,1)
END CATCH
