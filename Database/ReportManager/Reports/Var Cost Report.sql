BEGIN TRY
		BEGIN TRAN

		DECLARE @report_id_dest INT 
		
		IF 'e ' = 'p'
		BEGIN
			Set @report_id_dest = NULL
		END
	
IF EXISTS (SELECT 1 FROM dbo.report WHERE name='Var Cost Report')
		BEGIN
		EXEC spa_rfx_report 'd', NULL,41903, NULL, NULL, NULL, NULL, NULL
		END

		DECLARE @report_id_dest_old INT 

		SELECT @report_id_dest_old = report_id
		FROM report r
		WHERE r.[name] = 'Var Cost Report'
		
		IF OBJECT_ID(N'tempdb..#pages_dest', 'U') IS NOT NULL DROP TABLE #pages_dest
		
		IF OBJECT_ID(N'tempdb..#paramset_dest', 'U') IS NOT NULL DROP TABLE #paramset_dest
		
		IF OBJECT_ID(N'tempdb..#del_report_page', 'U') IS NOT NULL DROP TABLE #del_report_page	
		
		IF OBJECT_ID(N'tempdb..#del_report_paramset', 'U') IS NOT NULL DROP TABLE #del_report_paramset	
		
		CREATE TABLE #pages_dest(page_name VARCHAR(500) COLLATE DATABASE_DEFAULT)
		
		INSERT INTO #pages_dest(page_name)
		SELECT item FROM dbo.splitcommaseperatedvalues('')	
		UNION 
		SELECT rp.[name]
		FROM report_page rp
		INNER JOIN report r ON r.report_id = rp.report_id
		WHERE r.report_id = @report_id_dest_old 
			AND '' = ''
			
		CREATE TABLE #paramset_dest(paramset_name VARCHAR(500) COLLATE DATABASE_DEFAULT)
		
		INSERT INTO #paramset_dest(paramset_name)
		SELECT item FROM dbo.splitcommaseperatedvalues('')
		UNION
		SELECT rp.[name] 
		FROM report_paramset rp
		INNER JOIN report_page rpage ON rp.page_id = rpage.report_page_id
		INNER JOIN report r ON r.report_id = rpage.report_id
		WHERE r.report_id = @report_id_dest_old 
			AND'' = ''
		
		SELECT rp.report_page_id,
			   rp.[name] 
			   INTO #del_report_page
		FROM   report_page rp
		INNER JOIN report r ON r.report_id = rp.report_id
		INNER JOIN #pages_dest tpd ON tpd.page_name = rp.name
		WHERE r.report_id = @report_id_dest_old

		SELECT rp.report_paramset_id,
			   rp.[name] 
			   INTO #del_report_paramset
		FROM   report_paramset rp
		INNER JOIN #paramset_dest dpd ON dpd.paramset_name = rp.name
		INNER JOIN #del_report_page drp ON drp.report_page_id = rp.page_id	
		
		/*********************************************Table and Chart Deletion START *********************************************/
		/*
		* The data of the tables(report_page_tablix, report_tablix_column, report_page_chart, report_chart_column) relating to the pages present in the #del_report_page
		* are deleted unconditionally as well ,as there might be changes made in these table in the new report that is exported.
		* */
		DELETE rtc 
		FROM report_tablix_column rtc
		INNER JOIN report_page_tablix rpt ON rpt.report_page_tablix_id = rtc.tablix_id
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpt.page_id 
		
		DELETE rth 
		FROM report_tablix_header rth
		INNER JOIN report_page_tablix rpt ON rpt.report_page_tablix_id = rth.tablix_id
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpt.page_id		  

		DELETE rpt 
		FROM report_page_tablix rpt 
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpt.page_id

		DELETE rcc
		FROM report_chart_column rcc
		INNER JOIN report_page_chart rpc ON rpc.report_page_chart_id = rcc.chart_id
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpc.page_id
			
		DELETE rpc 
		FROM report_page_chart rpc	
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpc.page_id  
		
		DELETE rgcs
		FROM report_gauge_column_scale rgcs
		INNER JOIN report_gauge_column rgc ON rgc.report_gauge_column_id = rgcs.report_gauge_column_id
		INNER JOIN report_page_gauge rpg ON rpg.report_page_gauge_id = rgc.gauge_id
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpg.page_id
		
		
		DELETE rgc
		FROM report_gauge_column rgc
		INNER JOIN report_page_gauge rpg ON rpg.report_page_gauge_id = rgc.gauge_id
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpg.page_id
			
		DELETE rpg 
		FROM report_page_gauge rpg	
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpg.page_id  
		
		DELETE rpi 
		FROM report_page_image rpi	
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpi.page_id
		
		DELETE rpt 
		FROM report_page_textbox rpt	
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpt.page_id  
		
		DELETE rpl 
		FROM report_page_line rpl	
		INNER JOIN #del_report_page drp ON drp.report_page_id = rpl.page_id  
		/*********************************************Table and Chart Deletion END *********************************************/

		
	
		/*********************************************Paramter Deletion START*********************************************/
		/* The parameters are deleted unconditionally. (i.e data of the report_param. report_dataset_paramset, report_paramset) */
		
		DELETE rp 
		FROM report_param rp
		INNER JOIN report_dataset_paramset rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
		INNER JOIN #del_report_paramset drp ON drp.report_paramset_id = rdp.paramset_id
			
		DELETE rdp
		FROM report_dataset_paramset rdp 
		INNER JOIN #del_report_paramset drp ON drp.report_paramset_id = rdp.paramset_id
					 
		DELETE rp
		FROM report_paramset rp 
		INNER JOIN #del_report_paramset drp ON drp.report_paramset_id = rp.report_paramset_id
		
		/*********************************************Paramter Deletion END*********************************************/
		
		
		
		/*********************************************Page Deletion START*********************************************/
		/*Delete pages from #del_report_page, that have other paramset defined. These pages shouldnt be deleted*/
		DELETE #del_report_page
		FROM #del_report_page drp
		WHERE EXISTS (SELECT 1 FROM report_paramset WHERE page_id = drp.report_page_id)
		
		DELETE rp
		FROM report_page rp 
		INNER JOIN #del_report_page drp ON drp.report_page_id = rp.report_page_id
		WHERE report_id = @report_id_dest_old
		
		/*********************************************Page Deletion END*********************************************/
		
	
		
		/*Delete report only if doesnt have any page left Else set the destination report_id to the old report_id */
		IF EXISTS (SELECT 1 FROM report r
				   WHERE r.report_id = @report_id_dest_old
				   AND NOT EXISTS (SELECT 1 FROM report_page WHERE report_id = r.report_id))
		BEGIN			
			DELETE rdr 
			FROM report_dataset_relationship rdr
			INNER JOIN report_dataset rd ON rd.report_dataset_id = rdr.dataset_id
			WHERE rd.report_id = @report_id_dest_old
			
		
			DELETE FROM 
			report_dataset WHERE report_id = @report_id_dest_old	 
			
			DELETE FROM 
			report WHERE report_id = @report_id_dest_old
			
			DELETE dsc
			FROM data_source_column dsc
			INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id
			WHERE ds.[type_id] = 2
				AND ds.report_id = @report_id_dest_old
				 
			DELETE ds
			FROM data_source ds
			WHERE ds.[type_id] = 2
				AND ds.report_id = @report_id_dest_old	
		END
		ELSE
		BEGIN
			SET @report_id_dest = @report_id_dest_old
		END
		
		EXEC spa_print '@report_id_dest', @report_id_dest

		IF @report_id_dest IS NULL
		BEGIN
			INSERT INTO report ([name], [owner], is_system, report_hash, [description], category_id)
			SELECT TOP 1 'Var Cost Report' [name], 'farrms_admin' [owner], 0 is_system, '47E316DE_163E_42B7_9F25_6B0D1317D4FB' report_hash, 'Var Cost Report' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
			FROM sys.objects o
			LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = 'Power Generation' AND sdv_cat.type_id = 10008 
			SET @report_id_dest = SCOPE_IDENTITY()
		END
BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = 'Var Cost Report'

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'VCMV1')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'VCMV1' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'Var Cost View'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

	IF NOT EXISTS(SELECT 1 FROM report_page rp 
	              WHERE rp.report_id = CASE WHEN 'e ' = 'p' 
											Then 41903 
											ELSE @report_id_dest 
						               END 
					AND rp.name =  'Var Cost Report'  
	)
	BEGIN
		INSERT INTO report_page(report_id, [name], report_hash, width, height)
		SELECT CASE WHEN 'e ' = 'p' 
					Then 41903 
					ELSE @report_id_dest 
		       END  AS report_id, 'Var Cost Report' [name], '47E316DE_163E_42B7_9F25_6B0D1317D4FB' report_hash, 12 width,11.69 height
	END 
	

		INSERT INTO report_paramset(page_id, [name], paramset_hash, report_status_id)
		SELECT TOP 1 rpage.report_page_id, 'Var Cost Report', '946D4ABD_94CF_4AF5_86E2_EC45FC55F454', 2
		FROM sys.objects o
		INNER JOIN report_page rpage 
			on rpage.[name] = 'Var Cost Report'
		INNER JOIN report r 
		ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
	

		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, NULL AS where_part, 0
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Var Cost Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = CASE WHEN 'e ' = 'p' 
									Then 41903 
									ELSE @report_id_dest 
			                  END
			AND rd.[alias] = 'VCMV1'
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Var Cost Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'VCMV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'VCMV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Var Cost View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'fuel_value_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Var Cost Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'VCMV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'VCMV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Var Cost View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'generator_config_value_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 5 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Var Cost Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'VCMV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'VCMV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Var Cost View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'hr_from'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 6 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Var Cost Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'VCMV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'VCMV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Var Cost View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'hr_to'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, 'Generator' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Var Cost Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'VCMV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'VCMV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Var Cost View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'location_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, 'Term To' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Var Cost Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'VCMV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'VCMV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Var Cost View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_end'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, 'Term From' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Var Cost Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'VCMV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'VCMV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Var Cost View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_start'	
	

		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'Operation Cost Postion Report 2_page1' [name], '4' width, '2.493333333333333' height, '0' [top], '0' [left],2 AS group_mode,1 AS border_style,0 AS page_break,2 AS type_id,1 AS cross_summary,2 AS no_header,'' export_table_name, 0 AS is_global
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = 'Var Cost Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'VCMV1' 
	

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,3 placement, 0 column_order,NULL aggregation, NULL functions, 'Generator' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, 1 sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Operation Cost Postion Report 2_page1'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Var Cost Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'VCMV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Var Cost View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Generator' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 0 column_order,1 aggregation, NULL functions, 'Avgcost' [alias], 1 sortable, 3 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Operation Cost Postion Report 2_page1'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Var Cost Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'VCMV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Var Cost View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'AvgCost' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,4 placement, 0 column_order,NULL aggregation, NULL functions, 'Mw' [alias], 1 sortable, 0 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,0 subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Operation Cost Postion Report 2_page1'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Var Cost Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'VCMV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Var Cost View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'MW' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,3 placement, 1 column_order,NULL aggregation, NULL functions, 'Generator Name' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Operation Cost Postion Report 2_page1'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Var Cost Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Var Cost Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'VCMV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Var Cost View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Gen_Name' 
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
			ON  rpt.[name] = 'Operation Cost Postion Report 2_page1'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Var Cost Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Var Cost View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'AvgCost' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	
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
			ON  rpt.[name] = 'Operation Cost Postion Report 2_page1'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Var Cost Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Var Cost View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Gen_Name' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	
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
			ON  rpt.[name] = 'Operation Cost Postion Report 2_page1'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Var Cost Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Var Cost View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Generator' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	
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
			ON  rpt.[name] = 'Operation Cost Postion Report 2_page1'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Var Cost Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Var Cost Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Var Cost View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'MW' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	
COMMIT 

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;
		
	--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
END CATCH
	
		IF OBJECT_ID(N'tempdb..#pages_dest', 'U') IS NOT NULL DROP TABLE #pages_dest
		
		IF OBJECT_ID(N'tempdb..#paramset_dest', 'U') IS NOT NULL DROP TABLE #paramset_dest
		
		IF OBJECT_ID(N'tempdb..#del_report_page', 'U') IS NOT NULL DROP TABLE #del_report_page	
		
		IF OBJECT_ID(N'tempdb..#del_report_paramset', 'U') IS NOT NULL DROP TABLE #del_report_paramset	
	