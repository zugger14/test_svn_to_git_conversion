BEGIN TRY
		BEGIN TRAN

		DECLARE @report_id_dest INT 
		
		IF 'e ' = 'p'
		BEGIN
			Set @report_id_dest = NULL
		END
	

		DECLARE @report_id_dest_old INT 

		SELECT @report_id_dest_old = report_id
		FROM report r
		WHERE r.[name] = 'Production Forecast Report'
		
		IF OBJECT_ID(N'tempdb..#pages_dest', 'U') IS NOT NULL DROP TABLE #pages_dest
		
		IF OBJECT_ID(N'tempdb..#paramset_dest', 'U') IS NOT NULL DROP TABLE #paramset_dest
		
		IF OBJECT_ID(N'tempdb..#del_report_page', 'U') IS NOT NULL DROP TABLE #del_report_page	
		
		IF OBJECT_ID(N'tempdb..#del_report_paramset', 'U') IS NOT NULL DROP TABLE #del_report_paramset	
		
		CREATE TABLE #pages_dest(page_name VARCHAR(500))
		
		INSERT INTO #pages_dest(page_name)
		SELECT item FROM dbo.splitcommaseperatedvalues('')	
		UNION 
		SELECT rp.[name]
		FROM report_page rp
		INNER JOIN report r ON r.report_id = rp.report_id
		WHERE r.report_id = @report_id_dest_old 
			AND '' = ''
			
		CREATE TABLE #paramset_dest(paramset_name VARCHAR(500))
		
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
		
		PRINT '@report_id_dest' + ISNULL(CAST (@report_id_dest AS VARCHAR(100)),'NULL')

		IF @report_id_dest IS NULL
		BEGIN
			INSERT INTO report ([name], [owner], is_system, report_hash, [description], category_id)
			SELECT TOP 1 'Production Forecast Report' [name], 'farrms_admin' [owner], 0 is_system, 'A02E3D01_C2C1_4ADD_8150_C3D404D07849' report_hash, 'Production Forecast' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
			FROM sys.objects o
			LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = NULL AND sdv_cat.type_id = -1 
			SET @report_id_dest = SCOPE_IDENTITY()
		END
BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = 'Production Forecast Report'

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'cumalitive sql'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'cs', description = NULL
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'IF OBJECT_ID(N''tempdb..#temp'') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE #temp' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + ' IF OBJECT_ID(N''tempdb..#tt2'') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE #tt2' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + '  IF OBJECT_ID(N''tempdb..#final '') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE  #final ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT  total_volume' + CHAR(13) + '' + CHAR(10) + ',sub_book' + CHAR(13) + '' + CHAR(10) + ',sub_book_id' + CHAR(13) + '' + CHAR(10) + ',term_start' + CHAR(13) + '' + CHAR(10) + ',sub_id' + CHAR(13) + '' + CHAR(10) + ',stra_id' + CHAR(13) + '' + CHAR(10) + ',book_id' + CHAR(13) + '' + CHAR(10) + ',sub' + CHAR(13) + '' + CHAR(10) + ',stra' + CHAR(13) + '' + CHAR(10) + ',volume_uom' + CHAR(13) + '' + CHAR(10) + ',deal_type' + CHAR(13) + '' + CHAR(10) + ',deal_status' + CHAR(13) + '' + CHAR(10) + ',buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ',source_deal_detail_id ' + CHAR(13) + '' + CHAR(10) + ',case when deal_type = ''Physical'' and buy_sell_flag = ''sell'' and deal_status = ''draft'' then ''SELL''' + CHAR(13) + '' + CHAR(10) + 'when deal_type = ''Physical'' and buy_sell_flag = ''sell'' then ''Naptha''' + CHAR(13) + '' + CHAR(10) + 'when deal_type = ''Physical'' and buy_sell_flag = ''buy'' and deal_status = ''in progress'' then ''Forecast'' end as [book_type]' + CHAR(13) + '' + CHAR(10) + 'into #temp' + CHAR(13) + '' + CHAR(10) + ' FROM {DDV1} d' + CHAR(13) + '' + CHAR(10) + 'where d.term_start > ''@term_start''' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + ' -- FROM #ddv d' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + ' SELECT ' + CHAR(13) + '' + CHAR(10) + 'MAX(sub_book_id)sub_book_id' + CHAR(13) + '' + CHAR(10) + ',CONVERT(DATETIME,term_start)term_start' + CHAR(13) + '' + CHAR(10) + ',MAX(sub_id)sub_id' + CHAR(13) + '' + CHAR(10) + ',MAX(stra_id)stra_id' + CHAR(13) + '' + CHAR(10) + ',MAX(book_id)book_id' + CHAR(13) + '' + CHAR(10) + ',MAX(volume_uom)volume_uom' + CHAR(13) + '' + CHAR(10) + ',MAX(Forecast)Forecast, ' + CHAR(13) + '' + CHAR(10) + 'max(Naptha)Naptha,' + CHAR(13) + '' + CHAR(10) + 'max(SELL)SELL' + CHAR(13) + '' + CHAR(10) + 'into #final' + CHAR(13) + '' + CHAR(10) + '--max(Balance)Balance' + CHAR(13) + '' + CHAR(10) + 'FROM (' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + ' total_volume' + CHAR(13) + '' + CHAR(10) + ',sub_book_id' + CHAR(13) + '' + CHAR(10) + ',term_start' + CHAR(13) + '' + CHAR(10) + ',sub_id' + CHAR(13) + '' + CHAR(10) + ',stra_id' + CHAR(13) + '' + CHAR(10) + ',book_id' + CHAR(13) + '' + CHAR(10) + ',volume_uom' + CHAR(13) + '' + CHAR(10) + ',book_type' + CHAR(13) + '' + CHAR(10) + 'from #temp' + CHAR(13) + '' + CHAR(10) + 'where [book_type] is not null) up' + CHAR(13) + '' + CHAR(10) + 'PIVOT (MAX(total_volume) FOR book_type IN (Forecast,Naptha, SELL)) AS pv' + CHAR(13) + '' + CHAR(10) + 'GROUP BY term_start' + CHAR(13) + '' + CHAR(10) + 'ORDER BY term_start' + CHAR(13) + '' + CHAR(10) + '--[__batch_report__]' + CHAR(13) + '' + CHAR(10) + 'SELECT f.term_start, MAX(f.sub_id) sub_id, MAX(f.stra_id) stra_id, MAX(f.book_id) book_id, MAX(f.sub_book_id) sub_book_id' + CHAR(13) + '' + CHAR(10) + ', MAX(f.volume_uom) volume_uom, MAX(f.Forecast) Forecast, MAX(f.Naptha) Naptha, MAX(f.Sell) Sell ' + CHAR(13) + '' + CHAR(10) + ', MAX(nrs.balance) Balance' + CHAR(13) + '' + CHAR(10) + '--into #tt2' + CHAR(13) + '' + CHAR(10) + 'from #final f' + CHAR(13) + '' + CHAR(10) + 'OUTER APPLY (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'SELECT SUM(ISNULL(f_nxt.Forecast, 0) - ISNULL(f_nxt.Naptha, 0) - ISNULL(f_nxt.Sell, 0)) balance ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'FROM #final f_nxt ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'WHERE f_nxt.term_start <= f.term_start ' + CHAR(13) + '' + CHAR(10) + ') nrs' + CHAR(13) + '' + CHAR(10) + 'GROUP BY  f.term_start' + CHAR(13) + '' + CHAR(10) + 'ORDER by f.term_start', report_id = @report_id_data_source_dest 
		WHERE [name] = 'cumalitive sql'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 2 AS [type_id], 'cumalitive sql' AS [name], 'cs' AS ALIAS, NULL AS [description],'IF OBJECT_ID(N''tempdb..#temp'') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE #temp' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + ' IF OBJECT_ID(N''tempdb..#tt2'') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE #tt2' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + '  IF OBJECT_ID(N''tempdb..#final '') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE  #final ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT  total_volume' + CHAR(13) + '' + CHAR(10) + ',sub_book' + CHAR(13) + '' + CHAR(10) + ',sub_book_id' + CHAR(13) + '' + CHAR(10) + ',term_start' + CHAR(13) + '' + CHAR(10) + ',sub_id' + CHAR(13) + '' + CHAR(10) + ',stra_id' + CHAR(13) + '' + CHAR(10) + ',book_id' + CHAR(13) + '' + CHAR(10) + ',sub' + CHAR(13) + '' + CHAR(10) + ',stra' + CHAR(13) + '' + CHAR(10) + ',volume_uom' + CHAR(13) + '' + CHAR(10) + ',deal_type' + CHAR(13) + '' + CHAR(10) + ',deal_status' + CHAR(13) + '' + CHAR(10) + ',buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ',source_deal_detail_id ' + CHAR(13) + '' + CHAR(10) + ',case when deal_type = ''Physical'' and buy_sell_flag = ''sell'' and deal_status = ''draft'' then ''SELL''' + CHAR(13) + '' + CHAR(10) + 'when deal_type = ''Physical'' and buy_sell_flag = ''sell'' then ''Naptha''' + CHAR(13) + '' + CHAR(10) + 'when deal_type = ''Physical'' and buy_sell_flag = ''buy'' and deal_status = ''in progress'' then ''Forecast'' end as [book_type]' + CHAR(13) + '' + CHAR(10) + 'into #temp' + CHAR(13) + '' + CHAR(10) + ' FROM {DDV1} d' + CHAR(13) + '' + CHAR(10) + 'where d.term_start > ''@term_start''' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + ' -- FROM #ddv d' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + ' SELECT ' + CHAR(13) + '' + CHAR(10) + 'MAX(sub_book_id)sub_book_id' + CHAR(13) + '' + CHAR(10) + ',CONVERT(DATETIME,term_start)term_start' + CHAR(13) + '' + CHAR(10) + ',MAX(sub_id)sub_id' + CHAR(13) + '' + CHAR(10) + ',MAX(stra_id)stra_id' + CHAR(13) + '' + CHAR(10) + ',MAX(book_id)book_id' + CHAR(13) + '' + CHAR(10) + ',MAX(volume_uom)volume_uom' + CHAR(13) + '' + CHAR(10) + ',MAX(Forecast)Forecast, ' + CHAR(13) + '' + CHAR(10) + 'max(Naptha)Naptha,' + CHAR(13) + '' + CHAR(10) + 'max(SELL)SELL' + CHAR(13) + '' + CHAR(10) + 'into #final' + CHAR(13) + '' + CHAR(10) + '--max(Balance)Balance' + CHAR(13) + '' + CHAR(10) + 'FROM (' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + ' total_volume' + CHAR(13) + '' + CHAR(10) + ',sub_book_id' + CHAR(13) + '' + CHAR(10) + ',term_start' + CHAR(13) + '' + CHAR(10) + ',sub_id' + CHAR(13) + '' + CHAR(10) + ',stra_id' + CHAR(13) + '' + CHAR(10) + ',book_id' + CHAR(13) + '' + CHAR(10) + ',volume_uom' + CHAR(13) + '' + CHAR(10) + ',book_type' + CHAR(13) + '' + CHAR(10) + 'from #temp' + CHAR(13) + '' + CHAR(10) + 'where [book_type] is not null) up' + CHAR(13) + '' + CHAR(10) + 'PIVOT (MAX(total_volume) FOR book_type IN (Forecast,Naptha, SELL)) AS pv' + CHAR(13) + '' + CHAR(10) + 'GROUP BY term_start' + CHAR(13) + '' + CHAR(10) + 'ORDER BY term_start' + CHAR(13) + '' + CHAR(10) + '--[__batch_report__]' + CHAR(13) + '' + CHAR(10) + 'SELECT f.term_start, MAX(f.sub_id) sub_id, MAX(f.stra_id) stra_id, MAX(f.book_id) book_id, MAX(f.sub_book_id) sub_book_id' + CHAR(13) + '' + CHAR(10) + ', MAX(f.volume_uom) volume_uom, MAX(f.Forecast) Forecast, MAX(f.Naptha) Naptha, MAX(f.Sell) Sell ' + CHAR(13) + '' + CHAR(10) + ', MAX(nrs.balance) Balance' + CHAR(13) + '' + CHAR(10) + '--into #tt2' + CHAR(13) + '' + CHAR(10) + 'from #final f' + CHAR(13) + '' + CHAR(10) + 'OUTER APPLY (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'SELECT SUM(ISNULL(f_nxt.Forecast, 0) - ISNULL(f_nxt.Naptha, 0) - ISNULL(f_nxt.Sell, 0)) balance ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'FROM #final f_nxt ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'WHERE f_nxt.term_start <= f.term_start ' + CHAR(13) + '' + CHAR(10) + ') nrs' + CHAR(13) + '' + CHAR(10) + 'GROUP BY  f.term_start' + CHAR(13) + '' + CHAR(10) + 'ORDER by f.term_start' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'cumalative sql chart'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'csc', description = NULL
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'IF OBJECT_ID(N''tempdb..#temp'') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE #temp' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + ' IF OBJECT_ID(N''tempdb..#tt2'') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE #tt2' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + '  IF OBJECT_ID(N''tempdb..#final '') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE  #final ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT  total_volume' + CHAR(13) + '' + CHAR(10) + ',sub_book' + CHAR(13) + '' + CHAR(10) + ',sub_book_id' + CHAR(13) + '' + CHAR(10) + ',term_start' + CHAR(13) + '' + CHAR(10) + ',sub_id' + CHAR(13) + '' + CHAR(10) + ',stra_id' + CHAR(13) + '' + CHAR(10) + ',book_id' + CHAR(13) + '' + CHAR(10) + ',sub' + CHAR(13) + '' + CHAR(10) + ',stra' + CHAR(13) + '' + CHAR(10) + ',volume_uom' + CHAR(13) + '' + CHAR(10) + ',deal_type' + CHAR(13) + '' + CHAR(10) + ',deal_status' + CHAR(13) + '' + CHAR(10) + ',buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ',source_deal_detail_id ' + CHAR(13) + '' + CHAR(10) + ',case when deal_type = ''Physical'' and buy_sell_flag = ''sell'' and deal_status = ''draft'' then ''SELL''' + CHAR(13) + '' + CHAR(10) + 'when deal_type = ''Physical'' and buy_sell_flag = ''sell''  then ''Naptha''' + CHAR(13) + '' + CHAR(10) + 'when deal_type = ''Physical'' and buy_sell_flag = ''buy'' and deal_status = ''in progress'' then ''Forecast'' end as [book_type]' + CHAR(13) + '' + CHAR(10) + '--, d.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + 'into #temp' + CHAR(13) + '' + CHAR(10) + ' FROM {DDV1} d' + CHAR(13) + '' + CHAR(10) + 'where d.term_start > ''2014-07-31''' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + ' -- FROM #ddv d select * from #temp' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + ' SELECT ' + CHAR(13) + '' + CHAR(10) + 'MAX(sub_book_id)sub_book_id' + CHAR(13) + '' + CHAR(10) + ',CONVERT(DATETIME,term_start)term_start' + CHAR(13) + '' + CHAR(10) + ',MAX(sub_id)sub_id' + CHAR(13) + '' + CHAR(10) + ',MAX(stra_id)stra_id' + CHAR(13) + '' + CHAR(10) + ',MAX(book_id)book_id' + CHAR(13) + '' + CHAR(10) + ',MAX(volume_uom)volume_uom' + CHAR(13) + '' + CHAR(10) + ',MAX(Forecast)Forecast, ' + CHAR(13) + '' + CHAR(10) + 'max(Naptha)Naptha,' + CHAR(13) + '' + CHAR(10) + 'max(SELL)SELL' + CHAR(13) + '' + CHAR(10) + 'into #final' + CHAR(13) + '' + CHAR(10) + '--max(Balance)Balance' + CHAR(13) + '' + CHAR(10) + 'FROM (' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + ' total_volume' + CHAR(13) + '' + CHAR(10) + ',sub_book_id' + CHAR(13) + '' + CHAR(10) + ',term_start' + CHAR(13) + '' + CHAR(10) + ',sub_id' + CHAR(13) + '' + CHAR(10) + ',stra_id' + CHAR(13) + '' + CHAR(10) + ',book_id' + CHAR(13) + '' + CHAR(10) + ',volume_uom' + CHAR(13) + '' + CHAR(10) + ',book_type' + CHAR(13) + '' + CHAR(10) + 'from #temp' + CHAR(13) + '' + CHAR(10) + 'where [book_type] is not null) up' + CHAR(13) + '' + CHAR(10) + 'PIVOT (MAX(total_volume) FOR book_type IN (Forecast, Naptha, SELL)) AS pv' + CHAR(13) + '' + CHAR(10) + 'GROUP BY term_start' + CHAR(13) + '' + CHAR(10) + 'ORDER BY term_start --select * from #final' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT f.term_start, MAX(f.sub_id) sub_id, MAX(f.stra_id) stra_id, MAX(f.book_id) book_id, MAX(f.sub_book_id) sub_book_id' + CHAR(13) + '' + CHAR(10) + ', MAX(f.volume_uom) volume_uom, MAX(f.Forecast) Forecast, MAX(f.naptha) Naptha, MAX(f.Sell) Sell ' + CHAR(13) + '' + CHAR(10) + ', MAX(nrs.balance) Balance' + CHAR(13) + '' + CHAR(10) + 'into #tt2' + CHAR(13) + '' + CHAR(10) + 'from #final f' + CHAR(13) + '' + CHAR(10) + 'OUTER APPLY (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'SELECT SUM(ISNULL(f_nxt.Forecast, 0) - ISNULL(f_nxt.Sell, 0) - ISNULL(f_nxt.naptha, 0)) balance ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'FROM #final f_nxt ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'WHERE f_nxt.term_start <= f.term_start ' + CHAR(13) + '' + CHAR(10) + ') nrs' + CHAR(13) + '' + CHAR(10) + 'GROUP BY  f.term_start' + CHAR(13) + '' + CHAR(10) + 'ORDER by f.term_start' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--[__batch_report__]' + CHAR(13) + '' + CHAR(10) + 'select term_start,sub_id,stra_id, book_id, sub_book_id, volume_uom, volume, book_type' + CHAR(13) + '' + CHAR(10) + 'from #tt2' + CHAR(13) + '' + CHAR(10) + 'unpivot' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '  volume' + CHAR(13) + '' + CHAR(10) + '  for book_type in (Forecast, Naptha, Sell, Balance)' + CHAR(13) + '' + CHAR(10) + ') u;', report_id = @report_id_data_source_dest 
		WHERE [name] = 'cumalative sql chart'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 2 AS [type_id], 'cumalative sql chart' AS [name], 'csc' AS ALIAS, NULL AS [description],'IF OBJECT_ID(N''tempdb..#temp'') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE #temp' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + ' IF OBJECT_ID(N''tempdb..#tt2'') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE #tt2' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + '  IF OBJECT_ID(N''tempdb..#final '') IS NOT NULL' + CHAR(13) + '' + CHAR(10) + ' DROP TABLE  #final ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT  total_volume' + CHAR(13) + '' + CHAR(10) + ',sub_book' + CHAR(13) + '' + CHAR(10) + ',sub_book_id' + CHAR(13) + '' + CHAR(10) + ',term_start' + CHAR(13) + '' + CHAR(10) + ',sub_id' + CHAR(13) + '' + CHAR(10) + ',stra_id' + CHAR(13) + '' + CHAR(10) + ',book_id' + CHAR(13) + '' + CHAR(10) + ',sub' + CHAR(13) + '' + CHAR(10) + ',stra' + CHAR(13) + '' + CHAR(10) + ',volume_uom' + CHAR(13) + '' + CHAR(10) + ',deal_type' + CHAR(13) + '' + CHAR(10) + ',deal_status' + CHAR(13) + '' + CHAR(10) + ',buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ',source_deal_detail_id ' + CHAR(13) + '' + CHAR(10) + ',case when deal_type = ''Physical'' and buy_sell_flag = ''sell'' and deal_status = ''draft'' then ''SELL''' + CHAR(13) + '' + CHAR(10) + 'when deal_type = ''Physical'' and buy_sell_flag = ''sell''  then ''Naptha''' + CHAR(13) + '' + CHAR(10) + 'when deal_type = ''Physical'' and buy_sell_flag = ''buy'' and deal_status = ''in progress'' then ''Forecast'' end as [book_type]' + CHAR(13) + '' + CHAR(10) + '--, d.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + 'into #temp' + CHAR(13) + '' + CHAR(10) + ' FROM {DDV1} d' + CHAR(13) + '' + CHAR(10) + 'where d.term_start > ''2014-07-31''' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + ' -- FROM #ddv d select * from #temp' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + ' SELECT ' + CHAR(13) + '' + CHAR(10) + 'MAX(sub_book_id)sub_book_id' + CHAR(13) + '' + CHAR(10) + ',CONVERT(DATETIME,term_start)term_start' + CHAR(13) + '' + CHAR(10) + ',MAX(sub_id)sub_id' + CHAR(13) + '' + CHAR(10) + ',MAX(stra_id)stra_id' + CHAR(13) + '' + CHAR(10) + ',MAX(book_id)book_id' + CHAR(13) + '' + CHAR(10) + ',MAX(volume_uom)volume_uom' + CHAR(13) + '' + CHAR(10) + ',MAX(Forecast)Forecast, ' + CHAR(13) + '' + CHAR(10) + 'max(Naptha)Naptha,' + CHAR(13) + '' + CHAR(10) + 'max(SELL)SELL' + CHAR(13) + '' + CHAR(10) + 'into #final' + CHAR(13) + '' + CHAR(10) + '--max(Balance)Balance' + CHAR(13) + '' + CHAR(10) + 'FROM (' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + ' total_volume' + CHAR(13) + '' + CHAR(10) + ',sub_book_id' + CHAR(13) + '' + CHAR(10) + ',term_start' + CHAR(13) + '' + CHAR(10) + ',sub_id' + CHAR(13) + '' + CHAR(10) + ',stra_id' + CHAR(13) + '' + CHAR(10) + ',book_id' + CHAR(13) + '' + CHAR(10) + ',volume_uom' + CHAR(13) + '' + CHAR(10) + ',book_type' + CHAR(13) + '' + CHAR(10) + 'from #temp' + CHAR(13) + '' + CHAR(10) + 'where [book_type] is not null) up' + CHAR(13) + '' + CHAR(10) + 'PIVOT (MAX(total_volume) FOR book_type IN (Forecast, Naptha, SELL)) AS pv' + CHAR(13) + '' + CHAR(10) + 'GROUP BY term_start' + CHAR(13) + '' + CHAR(10) + 'ORDER BY term_start --select * from #final' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT f.term_start, MAX(f.sub_id) sub_id, MAX(f.stra_id) stra_id, MAX(f.book_id) book_id, MAX(f.sub_book_id) sub_book_id' + CHAR(13) + '' + CHAR(10) + ', MAX(f.volume_uom) volume_uom, MAX(f.Forecast) Forecast, MAX(f.naptha) Naptha, MAX(f.Sell) Sell ' + CHAR(13) + '' + CHAR(10) + ', MAX(nrs.balance) Balance' + CHAR(13) + '' + CHAR(10) + 'into #tt2' + CHAR(13) + '' + CHAR(10) + 'from #final f' + CHAR(13) + '' + CHAR(10) + 'OUTER APPLY (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'SELECT SUM(ISNULL(f_nxt.Forecast, 0) - ISNULL(f_nxt.Sell, 0) - ISNULL(f_nxt.naptha, 0)) balance ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'FROM #final f_nxt ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'WHERE f_nxt.term_start <= f.term_start ' + CHAR(13) + '' + CHAR(10) + ') nrs' + CHAR(13) + '' + CHAR(10) + 'GROUP BY  f.term_start' + CHAR(13) + '' + CHAR(10) + 'ORDER by f.term_start' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--[__batch_report__]' + CHAR(13) + '' + CHAR(10) + 'select term_start,sub_id,stra_id, book_id, sub_book_id, volume_uom, volume, book_type' + CHAR(13) + '' + CHAR(10) + 'from #tt2' + CHAR(13) + '' + CHAR(10) + 'unpivot' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '  volume' + CHAR(13) + '' + CHAR(10) + '  for book_type in (Forecast, Naptha, Sell, Balance)' + CHAR(13) + '' + CHAR(10) + ') u;' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalitive sql'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalitive sql'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'Book ID' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalitive sql'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalitive sql'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'Strategy ID' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalitive sql'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalitive sql'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'Sub Book ID' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalitive sql'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalitive sql'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'Subsidiary ID' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalitive sql'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalitive sql'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalitive sql'
	            AND dsc.name =  'volume_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalitive sql'
			AND dsc.name =  'volume_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume_uom' AS [name], 'Volume UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalitive sql'
	            AND dsc.name =  'Balance'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Balance'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalitive sql'
			AND dsc.name =  'Balance'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Balance' AS [name], 'Balance' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalitive sql'
	            AND dsc.name =  'Forecast'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Forecast'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalitive sql'
			AND dsc.name =  'Forecast'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Forecast' AS [name], 'Forecast' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalitive sql'
	            AND dsc.name =  'Naptha'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Naptha'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalitive sql'
			AND dsc.name =  'Naptha'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Naptha' AS [name], 'Naptha' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalitive sql'
	            AND dsc.name =  'Sell'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'SELL'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalitive sql'
			AND dsc.name =  'Sell'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Sell' AS [name], 'SELL' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalative sql chart'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'book_id'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalative sql chart'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'book_id' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalative sql chart'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalative sql chart'
	            AND dsc.name =  'book_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'book_type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalative sql chart'
			AND dsc.name =  'book_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_type' AS [name], 'book_type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalative sql chart'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalative sql chart'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'stra_id'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalative sql chart'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'stra_id' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalative sql chart'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalative sql chart'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_book_id'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalative sql chart'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'sub_book_id' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalative sql chart'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalative sql chart'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_id'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalative sql chart'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'sub_id' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalative sql chart'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalative sql chart'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'term_start'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalative sql chart'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'term_start' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalative sql chart'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalative sql chart'
	            AND dsc.name =  'volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalative sql chart'
			AND dsc.name =  'volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume' AS [name], 'volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalative sql chart'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'cumalative sql chart'
	            AND dsc.name =  'volume_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'volume_uom'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'cumalative sql chart'
			AND dsc.name =  'volume_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume_uom' AS [name], 'volume_uom' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'cumalative sql chart'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'cumalitive sql'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'cumalative sql chart'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	
COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'DDV1')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'DDV1' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'Deal Detail View'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'cs')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'cs' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'cumalitive sql'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'csc')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'csc' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'cumalative sql chart'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

	IF NOT EXISTS(SELECT 1 FROM report_page rp 
	              WHERE rp.report_id = CASE WHEN 'e ' = 'p' 
											Then 6203 
											ELSE @report_id_dest 
						               END 
					AND rp.name =  'Production Forecast Report'  
	)
	BEGIN
		INSERT INTO report_page(report_id, [name], report_hash, width, height)
		SELECT CASE WHEN 'e ' = 'p' 
					Then 6203 
					ELSE @report_id_dest 
		       END  AS report_id, 'Production Forecast Report' [name], 'A02E3D01_C2C1_4ADD_8150_C3D404D07849' report_hash, 12 width,11.69 height
	END 
	

		INSERT INTO report_paramset(page_id, [name], paramset_hash, report_status_id)
		SELECT TOP 1 rpage.report_page_id, 'Production Forecast Report', '50DF74CA_DB89_4458_B5BC_FDB161769430', 2
		FROM sys.objects o
		INNER JOIN report_page rpage 
			on rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r 
		ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
	

		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, NULL AS where_part, 0
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = CASE WHEN 'e ' = 'p' 
									Then 6203 
									ELSE @report_id_dest 
			                  END
			AND rd.[alias] = 'cs'
	

		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, NULL AS where_part, 0
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = CASE WHEN 'e ' = 'p' 
									Then 6203 
									ELSE @report_id_dest 
			                  END
			AND rd.[alias] = 'csc'
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'cs'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'cs'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'cumalitive sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'cs'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'cs'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'cumalitive sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'stra_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'cs'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'cs'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'cumalitive sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'cs'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'cs'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'cumalitive sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '07/31/2014' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'cs'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'cs'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'cumalitive sql' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_start'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'csc'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'csc'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'cumalative sql chart' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'csc'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'csc'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'cumalative sql chart' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'stra_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'csc'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'csc'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'cumalative sql chart' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'csc'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'csc'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'cumalative sql chart' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, 'Term Start' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'Production Forecast Report'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'csc'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'csc'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'cumalative sql chart' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_start'	
	

		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'Naphtha Forecast Report at Cartagena' [name], '7.346666666666667' width, '4.933333333333334' height, '4.68' [top], '1.0666666666666666' [left],0 AS group_mode,1 AS border_style,0 AS page_break,1 AS type_id,1 AS cross_summary,2 AS no_header,NULL export_table_name, 1 AS is_global
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'cs' 
	

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 1 column_order,NULL aggregation, NULL functions, 'Term Start' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, 1 sort_direction, 0 custom_field, 4 render_as,-1 column_template,NULL negative_mark,NULL currency,1 date_format,-1 cross_summary_aggregation,0 mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Naphtha Forecast Report at Cartagena'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Production Forecast Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'cs' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'cumalitive sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'term_start' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 2 column_order,NULL aggregation, NULL functions, 'Forecast' [alias], 1 sortable, 0 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,0 mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Naphtha Forecast Report at Cartagena'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Production Forecast Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'cs' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'cumalitive sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Forecast' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 4 column_order,NULL aggregation, NULL functions, 'Balance' [alias], 1 sortable, 0 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,0 mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Naphtha Forecast Report at Cartagena'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Production Forecast Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'cs' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'cumalitive sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Balance' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 5 column_order,NULL aggregation, NULL functions, 'UOM' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,0 mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Naphtha Forecast Report at Cartagena'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Production Forecast Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'cs' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'cumalitive sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'volume_uom' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, NULL dataset_id,NULL column_id,1 placement, 3 column_order,NULL aggregation, 'CASE WHEN cs.naptha IS NULL and cs.sell IS NULL THEN NULL ELSE ISNULL(cs.naptha, 0) + ISNULL(cs.sell, 0) END' functions, 'Sell' [alias], 1 sortable, 0 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 1 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,0 mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Naphtha Forecast Report at Cartagena'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='Production Forecast Report'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id		
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id 
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id,NULL column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Left' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'Naphtha Forecast Report at Cartagena'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id		
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id 
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
			ON  rpt.[name] = 'Naphtha Forecast Report at Cartagena'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'cumalitive sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'term_start' 
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
			ON  rpt.[name] = 'Naphtha Forecast Report at Cartagena'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'cumalitive sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'volume_uom' 
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
			ON  rpt.[name] = 'Naphtha Forecast Report at Cartagena'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'cumalitive sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Balance' 
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
			ON  rpt.[name] = 'Naphtha Forecast Report at Cartagena'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'Production Forecast Report'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'cumalitive sql' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Forecast' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	

		INSERT INTO report_page_chart(page_id, root_dataset_id, [name], [type_id], width, height, [top], [left], [x_axis_caption], [y_axis_caption], [page_break], [chart_properties])
		SELECT TOP 1 rpage.report_page_id page_id, rd.report_dataset_id root_dataset_id, 'Naphtha Forecast Chart at Cartagena' [name], 32 [type_id], '7.36' width, '3.92' height, '0.3333333333333333' [top], '1.04' [left], 'Term' [x_axis_caption], 'Volume (MT)' [y_axis_caption],0 [page_break],'{"axes":{"y":{"render_as":"0","column_template":"-1","currency":"","thousand_list":"","rounding":"","date_format":"","font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_color":"#000000"},"z":{"render_as":"0","column_template":"-1","currency":"","thousand_list":"","rounding":"","date_format":"","font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_align":"Left","text_color":"#000000"},"x":{"render_as":"4","column_template":"-1","currency":"","thousand_list":"","rounding":"","date_format":"1","font":"Tahoma","font_size":"8","bold_style":0,"italic_style":0,"underline_style":0,"text_color":"#000000"}},"axes_caption":{}}' [chart_properties] 
		FROM sys.objects o
		INNER JOIN report_page rpage
			ON rpage.[name] = 'Production Forecast Report'			
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'csc' 
	

		INSERT INTO report_chart_column(chart_id, dataset_id, column_id, placement, column_order, [alias], functions, aggregation, default_sort_order, default_sort_direction, custom_field, render_as_line)
		SELECT TOP 1 rpc.report_page_chart_id chart_id, rd.report_dataset_id dataset_id,
		
		  dsc.data_source_column_id column_id,1 placement,1 column_order, 'volume' [alias], NULL [functions], NULL aggregation,NULL default_sort_order, NULL default_sort_direction, 0 custom_field, 0 render_as_line
		FROM sys.objects o
		INNER JOIN report_page_chart rpc 
			ON rpc.[name] = 'Naphtha Forecast Chart at Cartagena'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpc.page_id 
			AND rpage.[name] = 'Production Forecast Report'			
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'csc'	
		INNER JOIN data_source ds 
		ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id AND ds.[name] = 'cumalative sql chart' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id  AND dsc.[name] = 'volume' 

		INSERT INTO report_chart_column(chart_id, dataset_id, column_id, placement, column_order, [alias], functions, aggregation, default_sort_order, default_sort_direction, custom_field, render_as_line)
		SELECT TOP 1 rpc.report_page_chart_id chart_id, rd.report_dataset_id dataset_id,
		
		  dsc.data_source_column_id column_id,2 placement,1 column_order, 'book_type' [alias], NULL [functions], NULL aggregation,NULL default_sort_order, NULL default_sort_direction, 0 custom_field, 0 render_as_line
		FROM sys.objects o
		INNER JOIN report_page_chart rpc 
			ON rpc.[name] = 'Naphtha Forecast Chart at Cartagena'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpc.page_id 
			AND rpage.[name] = 'Production Forecast Report'			
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'csc'	
		INNER JOIN data_source ds 
		ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id AND ds.[name] = 'cumalative sql chart' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id  AND dsc.[name] = 'book_type' 

		INSERT INTO report_chart_column(chart_id, dataset_id, column_id, placement, column_order, [alias], functions, aggregation, default_sort_order, default_sort_direction, custom_field, render_as_line)
		SELECT TOP 1 rpc.report_page_chart_id chart_id, rd.report_dataset_id dataset_id,
		
		  dsc.data_source_column_id column_id,3 placement,1 column_order, 'term_start' [alias], NULL [functions], NULL aggregation,NULL default_sort_order, NULL default_sort_direction, 0 custom_field, 0 render_as_line
		FROM sys.objects o
		INNER JOIN report_page_chart rpc 
			ON rpc.[name] = 'Naphtha Forecast Chart at Cartagena'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpc.page_id 
			AND rpage.[name] = 'Production Forecast Report'			
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'Production Forecast Report'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'csc'	
		INNER JOIN data_source ds 
		ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id AND ds.[name] = 'cumalative sql chart' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id  AND dsc.[name] = 'term_start' 
COMMIT 

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;
		
	PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
END CATCH
