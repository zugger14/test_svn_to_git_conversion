BEGIN TRY
		BEGIN TRAN

		DECLARE @report_id_dest INT 
		
		IF 'e ' = 'p'
		BEGIN
			Set @report_id_dest = NULL
		END
	
IF EXISTS (SELECT 1 FROM dbo.report WHERE name='Deal Position Report by Commodity')
		BEGIN
		EXEC spa_rfx_report 'd', NULL,41866, NULL, NULL, NULL, NULL, NULL
		END

		DECLARE @report_id_dest_old INT 

		SELECT @report_id_dest_old = report_id
		FROM report r
		WHERE r.[name] = 'Deal Position Report by Commodity'
		
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
			SELECT TOP 1 'Deal Position Report by Commodity' [name], 'farrms_admin' [owner], 0 is_system, '8525A13F_CDFD_4074_AB74_01653FC9999B' report_hash, 'Deal Position Report by Commodity ' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
			FROM sys.objects o
			LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = NULL AND sdv_cat.type_id = -1 
			SET @report_id_dest = SCOPE_IDENTITY()
		END
BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = 'Deal Position Report by Commodity'

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
	

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'SPDV1')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'SPDV1' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'Position Detail View'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

	IF NOT EXISTS(SELECT 1 FROM report_page rp 
	              WHERE rp.report_id = CASE WHEN 'e ' = 'p' 
											Then 41866 
											ELSE @report_id_dest 
						               END 
					AND rp.name =  'Deal Position Report by Commodity'  
	)
	BEGIN
		INSERT INTO report_page(report_id, [name], report_hash, width, height)
		SELECT CASE WHEN 'e ' = 'p' 
					Then 41866 
					ELSE @report_id_dest 
		       END  AS report_id, 'Deal Position Report by Commodity' [name], '8525A13F_CDFD_4074_AB74_01653FC9999B' report_hash, 11.5 width,5.5 height
	END 
	

		INSERT INTO report_paramset(page_id, [name], paramset_hash, report_status_id)
		SELECT TOP 1 rpage.report_page_id, 'Deal Position Report by Commodity', 'AFA7FA23_7204_45A2_B0E0_A97E6DEEFB62', 2
		FROM sys.objects o
		INNER JOIN report_page rpage 
			on rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
		ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
	

		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, '(  SPDV1.[Trader_id] IN ( @Trader_id ) 
AND SPDV1.[convert_uom_id] = ''@convert_uom_id'')' AS where_part, 0
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = CASE WHEN 'e ' = 'p' 
									Then 41866 
									ELSE @report_id_dest 
			                  END
			AND rd.[alias] = 'SPDV1'
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'as_of_date'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'block_type_group_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'commodity_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'confirm_status_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 5 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'counterparty_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 6 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'country_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 7 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'deal_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 8 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'deal_status_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 9 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'deal_sub_type_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 10 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'deal_type_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 11 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'grid_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 12 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'index_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 13 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'location_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 14 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'parent_counterparty'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 15 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'period_from'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 16 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'period_to'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 17 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'physical_financial_flag'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 18 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'profile_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 19 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'region_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 20 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'source_deal_header_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 21 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'stra_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 22 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 23 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 24 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'tenor_option'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 26 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_end'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 25 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_start'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 27 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'Trader_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 28 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'summary_option'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 29 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'location_group_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 30 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'deal_date_from'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 31 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'deal_date_to'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 32 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'convert_uom_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 33 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'include_actuals_from_shape'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 34 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'convert_to_uom_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 35 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'SPDV1'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'SPDV1'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'Position Detail View' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'buy_sell_flag'	
	

		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'Deal Position Report by Commodity' [name], '4.933333333333334' width, '2.4' height, '2.8266666666666666' [top], '0.05333333333333334' [left],2 AS group_mode,1 AS border_style,0 AS page_break,2 AS type_id,4 AS cross_summary,2 AS no_header,'' export_table_name, 0 AS is_global
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'SPDV1' 
	

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,3 placement, 0 column_order,NULL aggregation, NULL functions, 'Term Year Month' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Deal Position Report by Commodity'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SPDV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'term_year_month' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,4 placement, 1 column_order,NULL aggregation, NULL functions, 'Commodity' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,0 subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Deal Position Report by Commodity'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SPDV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'commodity' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,4 placement, 2 column_order,NULL aggregation, NULL functions, 'Physical/Financial' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,0 subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Deal Position Report by Commodity'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SPDV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'physical_financial_flag' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,4 placement, 3 column_order,NULL aggregation, NULL functions, 'Location' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,0 subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Deal Position Report by Commodity'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SPDV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'location' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,4 placement, 4 column_order,NULL aggregation, NULL functions, 'Index' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,0 subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Deal Position Report by Commodity'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SPDV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'index' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,4 placement, 5 column_order,NULL aggregation, NULL functions, 'Position UOM' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Right' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,0 subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Deal Position Report by Commodity'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SPDV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'postion_uom' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 0 column_order,13 aggregation, NULL functions, 'Position' [alias], 1 sortable, 2 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,13 cross_summary_aggregation,NULL mark_for_total,13 sql_aggregation,NULL subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Deal Position Report by Commodity'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SPDV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Position' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,4 placement, 0 column_order,NULL aggregation, NULL functions, 'Deal ID' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Right' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation,0 subtotal
			
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Deal Position Report by Commodity'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'SPDV1' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'source_deal_header_id' 
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
			ON  rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'commodity' 
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
			ON  rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'index' 
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
			ON  rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'location' 
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
			ON  rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'physical_financial_flag' 
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
			ON  rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Position' 
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
			ON  rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'postion_uom' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	
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
			ON  rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'source_deal_header_id' 
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
			ON  rpt.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'term_year_month' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	

		INSERT INTO report_page_chart(page_id, root_dataset_id, [name], [type_id], width, height, [top], [left], [x_axis_caption], [y_axis_caption], [page_break], [chart_properties])
		SELECT TOP 1 rpage.report_page_id page_id, rd.report_dataset_id root_dataset_id, 'Position and Deal Report Mobile _chart' [name], 3 [type_id], '4.906666666666666' width, '2.96' height, '0' [top], '0' [left], 'Months' [x_axis_caption], 'Volume ' [y_axis_caption],0 [page_break],'{"axes":{"y":{"render_as":"0","column_template":"-1","currency":"","thousand_list":"","rounding":"","date_format":"","font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_color":"#000000"},"z":{"render_as":"0","column_template":"-1","currency":"","thousand_list":"","rounding":"","date_format":"","font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_align":"Left","text_color":"#000000"},"x":{"render_as":"4","column_template":"-1","currency":"","thousand_list":"","rounding":"","date_format":"1","font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_color":"#000000"}},"axes_caption":{"y":{"font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_align":"Left","text_color":"#000000"},"x":{"font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_align":"Left","text_color":"#000000"}}}' [chart_properties] 
		FROM sys.objects o
		INNER JOIN report_page rpage
			ON rpage.[name] = 'Deal Position Report by Commodity'			
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'SPDV1' 
	

		INSERT INTO report_chart_column(chart_id, dataset_id, column_id, placement, column_order, [alias], functions, aggregation, default_sort_order, default_sort_direction, custom_field, render_as_line)
		SELECT TOP 1 rpc.report_page_chart_id chart_id, rd.report_dataset_id dataset_id,
		
		  dsc.data_source_column_id column_id,1 placement,1 column_order, 'Position' [alias], NULL [functions], NULL aggregation,NULL default_sort_order, NULL default_sort_direction, 0 custom_field, 0 render_as_line
		FROM sys.objects o
		INNER JOIN report_page_chart rpc 
			ON rpc.[name] = 'Position and Deal Report Mobile _chart'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpc.page_id 
			AND rpage.[name] = 'Deal Position Report by Commodity'			
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'SPDV1'	
		INNER JOIN data_source ds 
		ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id  AND dsc.[name] = 'Position' 

		INSERT INTO report_chart_column(chart_id, dataset_id, column_id, placement, column_order, [alias], functions, aggregation, default_sort_order, default_sort_direction, custom_field, render_as_line)
		SELECT TOP 1 rpc.report_page_chart_id chart_id, rd.report_dataset_id dataset_id,
		
		  dsc.data_source_column_id column_id,2 placement,1 column_order, 'Commodity' [alias], NULL [functions], NULL aggregation,NULL default_sort_order, NULL default_sort_direction, 0 custom_field, 0 render_as_line
		FROM sys.objects o
		INNER JOIN report_page_chart rpc 
			ON rpc.[name] = 'Position and Deal Report Mobile _chart'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpc.page_id 
			AND rpage.[name] = 'Deal Position Report by Commodity'			
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'SPDV1'	
		INNER JOIN data_source ds 
		ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id  AND dsc.[name] = 'commodity' 

		INSERT INTO report_chart_column(chart_id, dataset_id, column_id, placement, column_order, [alias], functions, aggregation, default_sort_order, default_sort_direction, custom_field, render_as_line)
		SELECT TOP 1 rpc.report_page_chart_id chart_id, rd.report_dataset_id dataset_id,
		
		  dsc.data_source_column_id column_id,3 placement,1 column_order, 'Term Year Month' [alias], NULL [functions], NULL aggregation,NULL default_sort_order, NULL default_sort_direction, 0 custom_field, 0 render_as_line
		FROM sys.objects o
		INNER JOIN report_page_chart rpc 
			ON rpc.[name] = 'Position and Deal Report Mobile _chart'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpc.page_id 
			AND rpage.[name] = 'Deal Position Report by Commodity'			
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Deal Position Report by Commodity'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'SPDV1'	
		INNER JOIN data_source ds 
		ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id AND ds.[name] = 'Position Detail View' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id  AND dsc.[name] = 'term_year_month' 
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
	