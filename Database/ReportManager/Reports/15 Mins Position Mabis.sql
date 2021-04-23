BEGIN TRY
		BEGIN TRAN

		DECLARE @report_id_dest INT 
	

		--RETAIN APPLICATION FILTER DETAILS START (PART1)
		if object_id('tempdb..#paramset_map') is not null drop table #paramset_map
		create table #paramset_map (
			deleted_paramset_id int null, 
			paramset_hash varchar(36) COLLATE DATABASE_DEFAULT NULL, 
			inserted_paramset_id int null

		)
		IF EXISTS (SELECT 1 FROM dbo.report WHERE report_hash='FE6BE19E_9CC5_4CE4_B754_4F700E4F99B7')
		BEGIN
			declare @report_id_to_delete int
			select @report_id_to_delete = report_id from report where report_hash = 'FE6BE19E_9CC5_4CE4_B754_4F700E4F99B7'

			insert into #paramset_map(deleted_paramset_id, paramset_hash)
			select rp.report_paramset_id, rp.paramset_hash
			from report_paramset rp
			inner join report_page pg on pg.report_page_id = rp.page_id
			where pg.report_id = @report_id_to_delete

			EXEC spa_rfx_report @flag='d', @report_id=@report_id_to_delete, @retain_privilege=1, @process_id=NULL

		
		END
		--RETAIN APPLICATION FILTER DETAILS END (PART1)
		

		declare @report_copy_name varchar(200)
		
		set @report_copy_name = isnull(@report_copy_name, 'Copy of ' + '15 Mins Position Mabis')
		

		INSERT INTO report ([name], [owner], is_system, is_excel, is_mobile, report_hash, [description], category_id)
		SELECT TOP 1 '15 Mins Position Mabis' [name], 'dev_admin' [owner], 0 is_system, 1 is_excel, 0 is_mobile, 'FE6BE19E_9CC5_4CE4_B754_4F700E4F99B7' report_hash, '15 Mins Position Grouped by Location Counterparty Shipper Codes' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
		FROM sys.objects o
		LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = 'Position' AND sdv_cat.type_id = 10008 
		SET @report_id_dest = SCOPE_IDENTITY()
		
		

		INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
		SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'fmpgbs1' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = '15 mins Position grouped by LCSC'
			AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
		LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
			AND rd_root.report_id = @report_id_dest		
		

	INSERT INTO report_page(report_id, [name], report_hash, width, height)
	SELECT @report_id_dest AS report_id, '15 Mins Position Mabis' [name], 'FE6BE19E_9CC5_4CE4_B754_4F700E4F99B7' report_hash, 11.5 width,5.5 height
	

		INSERT INTO report_paramset(page_id, [name], paramset_hash, report_status_id, export_report_name, export_location, output_file_format, delimiter, xml_format, report_header, compress_file, category_id)
		SELECT TOP 1 rpage.report_page_id, '15 Mins Position Mabis', '32699A53_F1D6_4302_8C92_DF3937D3A044', 3,'','','.csv',';', 
		-100000,'n','n',0	
		FROM sys.objects o
		INNER JOIN report_page rpage 
			on rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
		ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
	

		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, NULL AS where_part, 0
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = @report_id_dest
			AND rd.[alias] = 'fmpgbs1'
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'as_of_date'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '123' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 7 AS param_order, 0 AS param_depth, 'Commodity' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'commodity_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 8 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'counterparty'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 9 AS param_order, 0 AS param_depth, 'Location' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'location_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 10 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'shipper_code_id1'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 11 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'shipper_code_id2'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'stra_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 12 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'summary_option'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 6 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_end'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 5 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = '15 Mins Position Mabis'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'fmpgbs1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'fmpgbs1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = '15 mins Position grouped by LCSC' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_start'	
	

		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix' [name], '8.56' width, '4.1066666666666665' height, '0' [top], '0.02666666666666667' [left],2 AS group_mode,1 AS border_style,0 AS page_break,1 AS type_id,1 AS cross_summary,2 AS no_header,'' export_table_name, 0 AS is_global
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'fmpgbs1' 
	

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 0 column_order,NULL aggregation, NULL functions, 'Location' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, 1 default_sort_order, 1 sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'fmpgbs1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'location' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 1 column_order,NULL aggregation, NULL functions, 'Counterparty' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, 2 default_sort_order, 1 sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'fmpgbs1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Counterparty name' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 2 column_order,NULL aggregation, NULL functions, 'Shipper Code1' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'fmpgbs1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'shipper_code1' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 3 column_order,NULL aggregation, NULL functions, 'Shipper Code2' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'fmpgbs1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'shipper_code2' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 4 column_order,NULL aggregation, NULL functions, 'Term Start' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, 3 default_sort_order, 1 sort_direction, 0 custom_field, 4 render_as,-1 column_template,NULL negative_mark,NULL currency,0 date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'fmpgbs1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'term_start_disp' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 6 column_order,NULL aggregation, NULL functions, 'Period' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'fmpgbs1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'period_alias_name' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 7 column_order,NULL aggregation, NULL functions, 'Position' [alias], 1 sortable, 5 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Right' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,13 sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'fmpgbs1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Position' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 8 column_order,NULL aggregation, NULL functions, 'UOM' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Right' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'fmpgbs1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'postion_uom' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 5 column_order,NULL aggregation, NULL functions, 'Interval' [alias], 1 sortable, 0 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Right' text_align, '#000000' text_color, '#ffffff' background, 4 default_sort_order, 1 sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'fmpgbs1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'hr_rowid' 
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
			ON  rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Counterparty name' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Counterparty' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Right' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'hr_rowid' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Interval' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
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
			ON  rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'location' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Location' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
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
			ON  rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'period_alias_name' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Period' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Right' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Position' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Position' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Right' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'postion_uom' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'UOM' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
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
			ON  rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'shipper_code1' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Shipper Code1' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
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
			ON  rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'shipper_code2' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Shipper Code2' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	
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
			ON  rpt.[name] = 'fifteen Mins Position Grouped by Location Counterparty Shipper Codes_tablix'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = '15 Mins Position Mabis'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = '15 Mins Position Mabis'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = '15 mins Position grouped by LCSC' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'term_start_disp' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			--AND rtc.column_id = dsc.data_source_column_id  --This did not handle custom column, got duplicate custom columns during export
			AND rtc.alias = 'Term Start' --Added to handle custom column. Assumption: alias is unique and NOT NULL
	

		--RETAIN APPLICATION FILTER DETAILS START (PART2)
		update pm
		set inserted_paramset_id = rp.report_paramset_id
		from #paramset_map pm
		inner join report_paramset rp on rp.paramset_hash = pm.paramset_hash
		
		update f set f.report_id = pm.inserted_paramset_id
		from application_ui_filter f
		inner join #paramset_map pm on pm.deleted_paramset_id = isnull(f.report_id, -1)
		where f.application_function_id is null
	
		delete fd
		--select *
		from application_ui_filter_details fd
		inner join application_ui_filter f on f.application_ui_filter_id = fd.application_ui_filter_id
		inner join #paramset_map pm on pm.inserted_paramset_id = isnull(f.report_id, -1)
		where abs(fd.report_column_id) not in (
			select distinct rp.column_id
			from report_param rp
			inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
			inner join report_paramset rpm on rpm.report_paramset_id = rdp.paramset_id
			where rpm.report_paramset_id = f.report_id
		)
		--RETAIN APPLICATION FILTER DETAILS END (PART2)
	
COMMIT 

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;
		
	DECLARE @error_message VARCHAR(MAX) = ERROR_MESSAGE()
	RAISERROR(@error_message,16,1)
END CATCH
