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
		WHERE r.[name] = 'WACOG reports'
		
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
			SELECT TOP 1 'WACOG reports' [name], 'farrms_admin' [owner], 0 is_system, 'E02473E5_D0CE_4BA8_8043_43DD1AB112EA' report_hash, 'WACOG reports' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
			FROM sys.objects o
			LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = 'MLGW' AND sdv_cat.type_id = 10008 
			SET @report_id_dest = SCOPE_IDENTITY()
		END
BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = 'WACOG reports'

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'WACOG CALCS SQL'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'wcsql', description = NULL
		, [tsql] = CAST('' AS VARCHAR(MAX)) + '--############ WORKING PIECE ####################### singapore version' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--STORE TOTAL VOLUME AND TOTAL SETTLEMENT BY PIPELINE' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#total_by_pipeline'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#wacog_calc'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #wacog_calc' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select ca.udf_value [pipeline], dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', null term_start, null term_end' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) total_settlement' + CHAR(13) + '' + CHAR(10) + 'into #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca2' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.deal_type_name = ''physical'' --and dsv.source_deal_header_id = 5201' + CHAR(13) + '' + CHAR(10) + 'group by ca.udf_value, dsv.as_of_date, dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#rate_schedule'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #rate_schedule ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT [rate_contract_name],' + CHAR(13) + '' + CHAR(10) + 'base, sur, aca, gri --INTO #rate_schedule --GIVEN ALREADY KNOWN RATES AS COLUMNS FOR PIVOT SINCE DYNAMIC SQL NOT SUPPORTED ON REPORT MANAGER SQL BUILT' + CHAR(13) + '' + CHAR(10) + 'into #rate_schedule' + CHAR(13) + '' + CHAR(10) + 'FROM ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    SELECT cg.contract_name [rate_contract_name], rate_type.code, abs(trs.rate) rate' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'FROM   contract_group cg' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join transportation_rate_schedule trs on trs.rate_schedule_id = cg.maintain_rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join static_data_value rate_type on rate_type.value_id = trs.rate_type_id' + CHAR(13) + '' + CHAR(10) + ') x' + CHAR(13) + '' + CHAR(10) + 'PIVOT ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    max(rate)' + CHAR(13) + '' + CHAR(10) + '    FOR code IN (base, sur, aca, gri)' + CHAR(13) + '' + CHAR(10) + ') p' + CHAR(13) + '' + CHAR(10) + '--select * from #rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#detail_info'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + 'dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id, null term_start, null term_end, null logical_name' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value [pipeline]' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value [contract_name]' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) deal_volume' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) [settlement_amount]' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_settlement) total_set' + CHAR(13) + '' + CHAR(10) + ', case sum(dsv.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'when 0 then 0' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'else abs(sum(dsv.settlement_value) / sum(dsv.deal_volume)) ' + CHAR(13) + '' + CHAR(10) + '  end [wellhead] --wellhead = total_set/total_volume' + CHAR(13) + '' + CHAR(10) + ', MAX(dp.loss_factor) loss_factor' + CHAR(13) + '' + CHAR(10) + ', abs(MAX(dp.loss_factor) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '* ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'case sum(dsv.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else abs(sum(dsv.settlement_value) / sum(dsv.deal_volume)) ' + CHAR(13) + '' + CHAR(10) + '    end) [fuel]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'into #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select *' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value, udfv.field_label ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id  --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null  ' + CHAR(13) + '' + CHAR(10) + ') udfv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') udfv_ct ' + CHAR(13) + '' + CHAR(10) + 'cross apply(' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select tbp.total_volume, tbp.total_settlement' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from #total_by_pipeline tbp --select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where tbp.as_of_date = dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.sub_id = dsv.sub_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.stra_id = dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.pipeline = udfv.udf_value' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + ') ca_total' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN contract_group cg ON cg.contract_name = udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN delivery_path dp on dp.CONTRACT = cg.contract_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + 'GROUP BY dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', dp.loss_factor' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select di.*, rs.*' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', (ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0)) [cg_gate]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then di.settlement_amount ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else di.wellhead * di.deal_volume ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wh_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then di.settlement_amount ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(9) + '(ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [cg_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs((di.wellhead * di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_wh]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs(((ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_cg]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'into #wacog_calc' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + 'from #detail_info di' + CHAR(13) + '' + CHAR(10) + 'left join #rate_schedule rs on rs.rate_contract_name = di.contract_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--WACOG CALC PORTION' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.pipeline, wc.contract_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.deal_volume deal_volume, wc.wellhead wellhead' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.cg_gate cg_gate, wc.wh_dollar wh_dollar,wc.cg_dollar cg_dollar, wc.wacog_wh, wc.wacog_cg' + CHAR(13) + '' + CHAR(10) + '--[__batch_report__]' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + ' from #wacog_calc wc' + CHAR(13) + '' + CHAR(10) + '--group by wc.pipeline, wc.contract_name' + CHAR(13) + '' + CHAR(10) + 'UNION ALL' + CHAR(13) + '' + CHAR(10) + 'select' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.pipeline, wc.pipeline + '' WACOG'' contract_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null buy_sell_flag' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', sum(wc.deal_volume) deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null wellhead' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null cg_gate' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', sum(wc.wh_dollar) wh_dollar, sum(wc.cg_dollar) cg_dollar' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case sum(wc.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else abs(sum(wc.wh_dollar) / sum(wc.deal_volume))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wacog_wh]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case sum(wc.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else abs(sum(wc.cg_dollar) / sum(wc.deal_volume))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wacog_cg]' + CHAR(13) + '' + CHAR(10) + 'from #wacog_calc wc' + CHAR(13) + '' + CHAR(10) + 'group by wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--update wc1 set wc1.pipeline = ''PEPL'' from #wacog_calc2 wc1 where wc1.contract_name = ''NNS 0115''' + CHAR(13) + '' + CHAR(10) + 'UNION ALL' + CHAR(13) + '' + CHAR(10) + 'select' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label  ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', ''Total WACOG'' pipeline, null contract_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null buy_sell_flag' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', sum(wc.deal_volume) deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null wellhead' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null cg_gate' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', sum(wc.wh_dollar) wh_dollar, sum(wc.cg_dollar) cg_dollar' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case sum(wc.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else abs(sum(wc.wh_dollar) / sum(wc.deal_volume))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wacog_wh]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case sum(wc.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else abs(sum(wc.cg_dollar) / sum(wc.deal_volume))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wacog_cg]' + CHAR(13) + '' + CHAR(10) + 'from #wacog_calc wc' + CHAR(13) + '' + CHAR(10) + 'group by wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label' + CHAR(13) + '' + CHAR(10) + 'ORDER BY ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.pipeline, wc.contract_name', report_id = @report_id_data_source_dest 
		WHERE [name] = 'WACOG CALCS SQL'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 2 AS [type_id], 'WACOG CALCS SQL' AS [name], 'wcsql' AS ALIAS, NULL AS [description],'--############ WORKING PIECE ####################### singapore version' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--STORE TOTAL VOLUME AND TOTAL SETTLEMENT BY PIPELINE' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#total_by_pipeline'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#wacog_calc'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #wacog_calc' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select ca.udf_value [pipeline], dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', null term_start, null term_end' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) total_settlement' + CHAR(13) + '' + CHAR(10) + 'into #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca2' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.deal_type_name = ''physical'' --and dsv.source_deal_header_id = 5201' + CHAR(13) + '' + CHAR(10) + 'group by ca.udf_value, dsv.as_of_date, dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#rate_schedule'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #rate_schedule ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT [rate_contract_name],' + CHAR(13) + '' + CHAR(10) + 'base, sur, aca, gri --INTO #rate_schedule --GIVEN ALREADY KNOWN RATES AS COLUMNS FOR PIVOT SINCE DYNAMIC SQL NOT SUPPORTED ON REPORT MANAGER SQL BUILT' + CHAR(13) + '' + CHAR(10) + 'into #rate_schedule' + CHAR(13) + '' + CHAR(10) + 'FROM ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    SELECT cg.contract_name [rate_contract_name], rate_type.code, abs(trs.rate) rate' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'FROM   contract_group cg' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join transportation_rate_schedule trs on trs.rate_schedule_id = cg.maintain_rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join static_data_value rate_type on rate_type.value_id = trs.rate_type_id' + CHAR(13) + '' + CHAR(10) + ') x' + CHAR(13) + '' + CHAR(10) + 'PIVOT ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    max(rate)' + CHAR(13) + '' + CHAR(10) + '    FOR code IN (base, sur, aca, gri)' + CHAR(13) + '' + CHAR(10) + ') p' + CHAR(13) + '' + CHAR(10) + '--select * from #rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#detail_info'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + 'dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id, null term_start, null term_end, null logical_name' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value [pipeline]' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value [contract_name]' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) deal_volume' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) [settlement_amount]' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_settlement) total_set' + CHAR(13) + '' + CHAR(10) + ', case sum(dsv.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'when 0 then 0' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'else abs(sum(dsv.settlement_value) / sum(dsv.deal_volume)) ' + CHAR(13) + '' + CHAR(10) + '  end [wellhead] --wellhead = total_set/total_volume' + CHAR(13) + '' + CHAR(10) + ', MAX(dp.loss_factor) loss_factor' + CHAR(13) + '' + CHAR(10) + ', abs(MAX(dp.loss_factor) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '* ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'case sum(dsv.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else abs(sum(dsv.settlement_value) / sum(dsv.deal_volume)) ' + CHAR(13) + '' + CHAR(10) + '    end) [fuel]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'into #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select *' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value, udfv.field_label ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id  --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null  ' + CHAR(13) + '' + CHAR(10) + ') udfv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') udfv_ct ' + CHAR(13) + '' + CHAR(10) + 'cross apply(' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select tbp.total_volume, tbp.total_settlement' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from #total_by_pipeline tbp --select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where tbp.as_of_date = dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.sub_id = dsv.sub_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.stra_id = dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.pipeline = udfv.udf_value' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + ') ca_total' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN contract_group cg ON cg.contract_name = udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN delivery_path dp on dp.CONTRACT = cg.contract_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + 'GROUP BY dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', dp.loss_factor' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select di.*, rs.*' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', (ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0)) [cg_gate]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then di.settlement_amount ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else di.wellhead * di.deal_volume ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wh_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then di.settlement_amount ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(9) + '(ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [cg_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs((di.wellhead * di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_wh]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs(((ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_cg]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'into #wacog_calc' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + 'from #detail_info di' + CHAR(13) + '' + CHAR(10) + 'left join #rate_schedule rs on rs.rate_contract_name = di.contract_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--WACOG CALC PORTION' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.pipeline, wc.contract_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.deal_volume deal_volume, wc.wellhead wellhead' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.cg_gate cg_gate, wc.wh_dollar wh_dollar,wc.cg_dollar cg_dollar, wc.wacog_wh, wc.wacog_cg' + CHAR(13) + '' + CHAR(10) + '--[__batch_report__]' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + ' from #wacog_calc wc' + CHAR(13) + '' + CHAR(10) + '--group by wc.pipeline, wc.contract_name' + CHAR(13) + '' + CHAR(10) + 'UNION ALL' + CHAR(13) + '' + CHAR(10) + 'select' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.pipeline, wc.pipeline + '' WACOG'' contract_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null buy_sell_flag' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', sum(wc.deal_volume) deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null wellhead' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null cg_gate' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', sum(wc.wh_dollar) wh_dollar, sum(wc.cg_dollar) cg_dollar' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case sum(wc.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else abs(sum(wc.wh_dollar) / sum(wc.deal_volume))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wacog_wh]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case sum(wc.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else abs(sum(wc.cg_dollar) / sum(wc.deal_volume))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wacog_cg]' + CHAR(13) + '' + CHAR(10) + 'from #wacog_calc wc' + CHAR(13) + '' + CHAR(10) + 'group by wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--update wc1 set wc1.pipeline = ''PEPL'' from #wacog_calc2 wc1 where wc1.contract_name = ''NNS 0115''' + CHAR(13) + '' + CHAR(10) + 'UNION ALL' + CHAR(13) + '' + CHAR(10) + 'select' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label  ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', ''Total WACOG'' pipeline, null contract_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null buy_sell_flag' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', sum(wc.deal_volume) deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null wellhead' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', null cg_gate' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', sum(wc.wh_dollar) wh_dollar, sum(wc.cg_dollar) cg_dollar' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case sum(wc.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else abs(sum(wc.wh_dollar) / sum(wc.deal_volume))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wacog_wh]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case sum(wc.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else abs(sum(wc.cg_dollar) / sum(wc.deal_volume))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wacog_cg]' + CHAR(13) + '' + CHAR(10) + 'from #wacog_calc wc' + CHAR(13) + '' + CHAR(10) + 'group by wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label' + CHAR(13) + '' + CHAR(10) + 'ORDER BY ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end, wc.logical_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.field_label ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.pipeline, wc.contract_name' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'WACOG purchase SQL'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'wps', description = NULL
		, [tsql] = CAST('' AS VARCHAR(MAX)) + '--############ WORKING PIECE ####################### singapore version' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--STORE TOTAL VOLUME AND TOTAL SETTLEMENT BY PIPELINE' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#total_by_pipeline'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select ca.udf_value [pipeline], dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', null term_start, null term_end' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) total_settlement' + CHAR(13) + '' + CHAR(10) + 'into #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca2' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.deal_type_name = ''physical'' --and dsv.source_deal_header_id = 5201' + CHAR(13) + '' + CHAR(10) + 'group by ca.udf_value, dsv.as_of_date, dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#rate_schedule'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #rate_schedule ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT [rate_contract_name],' + CHAR(13) + '' + CHAR(10) + 'base, sur, aca, gri --INTO #rate_schedule --GIVEN ALREADY KNOWN RATES AS COLUMNS FOR PIVOT SINCE DYNAMIC SQL NOT SUPPORTED ON REPORT MANAGER SQL BUILT' + CHAR(13) + '' + CHAR(10) + 'into #rate_schedule' + CHAR(13) + '' + CHAR(10) + 'FROM ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    SELECT cg.contract_name [rate_contract_name], rate_type.code, abs(trs.rate) rate' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'FROM   contract_group cg' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join transportation_rate_schedule trs on trs.rate_schedule_id = cg.maintain_rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join static_data_value rate_type on rate_type.value_id = trs.rate_type_id' + CHAR(13) + '' + CHAR(10) + ') x' + CHAR(13) + '' + CHAR(10) + 'PIVOT ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    max(rate)' + CHAR(13) + '' + CHAR(10) + '    FOR code IN (base, sur, aca, gri)' + CHAR(13) + '' + CHAR(10) + ') p' + CHAR(13) + '' + CHAR(10) + '--select * from #rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#detail_info'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + 'dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id, null term_start, null term_end, null logical_name' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value [contract_name]' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) deal_volume' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) [settlement_amount]' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_settlement) total_set' + CHAR(13) + '' + CHAR(10) + ', case sum(dsv.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'else' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'abs(sum(dsv.settlement_value) / sum(dsv.deal_volume))' + CHAR(13) + '' + CHAR(10) + '  end [wellhead] --wellhead = total_set/total_volume' + CHAR(13) + '' + CHAR(10) + ', MAX(dp.loss_factor) loss_factor' + CHAR(13) + '' + CHAR(10) + ', abs(MAX(dp.loss_factor) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '* ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'case sum(dsv.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(9) + 'abs(sum(dsv.settlement_value) / sum(dsv.deal_volume))' + CHAR(13) + '' + CHAR(10) + '    end) [fuel]' + CHAR(13) + '' + CHAR(10) + '--, sum(dsv.deal_volume) * max(ca_total.total_settlement) / case max(ca_total.total_volume) when 0 then 1 else max(ca_total.total_volume) end [wellhead_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'into #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select *' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value, udfv.field_label ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id  --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null  ' + CHAR(13) + '' + CHAR(10) + ') udfv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') udfv_ct ' + CHAR(13) + '' + CHAR(10) + 'cross apply(' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select tbp.total_volume, tbp.total_settlement' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from #total_by_pipeline tbp --select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where tbp.as_of_date = dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.sub_id = dsv.sub_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.stra_id = dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.pipeline = udfv.udf_value' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + ') ca_total' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN contract_group cg ON cg.contract_name = udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN delivery_path dp on dp.CONTRACT = cg.contract_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + 'GROUP BY dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', dp.loss_factor' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select di.*, rs.*' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', (ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0)) [cg_gate]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume when 0 then di.settlement_amount' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else di.wellhead * di.deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wh_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume when 0 then di.settlement_amount' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(9) + '(ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [cg_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs((di.wellhead * di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_wh]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs(((ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_cg]' + CHAR(13) + '' + CHAR(10) + '--[__batch_report__]' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + 'from #detail_info di' + CHAR(13) + '' + CHAR(10) + 'left join #rate_schedule rs on rs.rate_contract_name = di.contract_name', report_id = @report_id_data_source_dest 
		WHERE [name] = 'WACOG purchase SQL'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 2 AS [type_id], 'WACOG purchase SQL' AS [name], 'wps' AS ALIAS, NULL AS [description],'--############ WORKING PIECE ####################### singapore version' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--STORE TOTAL VOLUME AND TOTAL SETTLEMENT BY PIPELINE' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#total_by_pipeline'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select ca.udf_value [pipeline], dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', null term_start, null term_end' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) total_settlement' + CHAR(13) + '' + CHAR(10) + 'into #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca2' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.deal_type_name = ''physical'' --and dsv.source_deal_header_id = 5201' + CHAR(13) + '' + CHAR(10) + 'group by ca.udf_value, dsv.as_of_date, dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#rate_schedule'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #rate_schedule ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT [rate_contract_name],' + CHAR(13) + '' + CHAR(10) + 'base, sur, aca, gri --INTO #rate_schedule --GIVEN ALREADY KNOWN RATES AS COLUMNS FOR PIVOT SINCE DYNAMIC SQL NOT SUPPORTED ON REPORT MANAGER SQL BUILT' + CHAR(13) + '' + CHAR(10) + 'into #rate_schedule' + CHAR(13) + '' + CHAR(10) + 'FROM ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    SELECT cg.contract_name [rate_contract_name], rate_type.code, abs(trs.rate) rate' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'FROM   contract_group cg' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join transportation_rate_schedule trs on trs.rate_schedule_id = cg.maintain_rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join static_data_value rate_type on rate_type.value_id = trs.rate_type_id' + CHAR(13) + '' + CHAR(10) + ') x' + CHAR(13) + '' + CHAR(10) + 'PIVOT ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    max(rate)' + CHAR(13) + '' + CHAR(10) + '    FOR code IN (base, sur, aca, gri)' + CHAR(13) + '' + CHAR(10) + ') p' + CHAR(13) + '' + CHAR(10) + '--select * from #rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#detail_info'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + 'dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id, null term_start, null term_end, null logical_name' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value [contract_name]' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) deal_volume' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) [settlement_amount]' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_settlement) total_set' + CHAR(13) + '' + CHAR(10) + ', case sum(dsv.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'else' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'abs(sum(dsv.settlement_value) / sum(dsv.deal_volume))' + CHAR(13) + '' + CHAR(10) + '  end [wellhead] --wellhead = total_set/total_volume' + CHAR(13) + '' + CHAR(10) + ', MAX(dp.loss_factor) loss_factor' + CHAR(13) + '' + CHAR(10) + ', abs(MAX(dp.loss_factor) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '* ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'case sum(dsv.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(9) + 'abs(sum(dsv.settlement_value) / sum(dsv.deal_volume))' + CHAR(13) + '' + CHAR(10) + '    end) [fuel]' + CHAR(13) + '' + CHAR(10) + '--, sum(dsv.deal_volume) * max(ca_total.total_settlement) / case max(ca_total.total_volume) when 0 then 1 else max(ca_total.total_volume) end [wellhead_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'into #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select *' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value, udfv.field_label ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id  --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null  ' + CHAR(13) + '' + CHAR(10) + ') udfv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') udfv_ct ' + CHAR(13) + '' + CHAR(10) + 'cross apply(' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select tbp.total_volume, tbp.total_settlement' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from #total_by_pipeline tbp --select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where tbp.as_of_date = dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.sub_id = dsv.sub_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.stra_id = dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.pipeline = udfv.udf_value' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + ') ca_total' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN contract_group cg ON cg.contract_name = udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN delivery_path dp on dp.CONTRACT = cg.contract_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + 'GROUP BY dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', dp.loss_factor' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select di.*, rs.*' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', (ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0)) [cg_gate]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume when 0 then di.settlement_amount' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else di.wellhead * di.deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wh_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume when 0 then di.settlement_amount' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(9) + '(ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [cg_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs((di.wellhead * di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_wh]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs(((ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_cg]' + CHAR(13) + '' + CHAR(10) + '--[__batch_report__]' + CHAR(13) + '' + CHAR(10) + ' ' + CHAR(13) + '' + CHAR(10) + 'from #detail_info di' + CHAR(13) + '' + CHAR(10) + 'left join #rate_schedule rs on rs.rate_contract_name = di.contract_name' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'WACOG SUMMARY SQL'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'wsum', description = NULL
		, [tsql] = CAST('' AS VARCHAR(MAX)) + '--############ WORKING PIECE ####################### singapore version' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--STORE TOTAL VOLUME AND TOTAL SETTLEMENT BY PIPELINE' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#total_by_pipeline'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select ca.udf_value [pipeline], dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', null term_start, null term_end' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) total_settlement' + CHAR(13) + '' + CHAR(10) + 'into #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca2' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.deal_type_name = ''physical'' --and dsv.source_deal_header_id = 5201' + CHAR(13) + '' + CHAR(10) + 'group by ca.udf_value, dsv.as_of_date, dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#rate_schedule'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #rate_schedule ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT [rate_contract_name],' + CHAR(13) + '' + CHAR(10) + 'base, sur, aca, gri --INTO #rate_schedule --GIVEN ALREADY KNOWN RATES AS COLUMNS FOR PIVOT SINCE DYNAMIC SQL NOT SUPPORTED ON REPORT MANAGER SQL BUILT' + CHAR(13) + '' + CHAR(10) + 'into #rate_schedule' + CHAR(13) + '' + CHAR(10) + 'FROM ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    SELECT cg.contract_name [rate_contract_name], rate_type.code, abs(trs.rate) rate' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'FROM   contract_group cg' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join transportation_rate_schedule trs on trs.rate_schedule_id = cg.maintain_rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join static_data_value rate_type on rate_type.value_id = trs.rate_type_id' + CHAR(13) + '' + CHAR(10) + ') x' + CHAR(13) + '' + CHAR(10) + 'PIVOT ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    max(rate)' + CHAR(13) + '' + CHAR(10) + '    FOR code IN (base, sur, aca, gri)' + CHAR(13) + '' + CHAR(10) + ') p' + CHAR(13) + '' + CHAR(10) + '--select * from #rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#detail_info'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + 'dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id, null term_start, null term_end, null logical_name' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value [contract_name]' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) deal_volume' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) [settlement_amount]' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_settlement) total_set' + CHAR(13) + '' + CHAR(10) + ', case sum(dsv.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'else' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'abs(sum(dsv.settlement_value) / sum(dsv.deal_volume))' + CHAR(13) + '' + CHAR(10) + '  end [wellhead] --wellhead = total_set/total_volume' + CHAR(13) + '' + CHAR(10) + ', MAX(dp.loss_factor) loss_factor' + CHAR(13) + '' + CHAR(10) + ', abs(MAX(dp.loss_factor) * max(ca_total.total_settlement) / case max(ca_total.total_volume) when 0 then 1 else max(ca_total.total_volume) end) [fuel]' + CHAR(13) + '' + CHAR(10) + '--, sum(dsv.deal_volume) * max(ca_total.total_settlement) / case max(ca_total.total_volume) when 0 then 1 else max(ca_total.total_volume) end [wellhead_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'into #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select *' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value, udfv.field_label ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id  --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null  ' + CHAR(13) + '' + CHAR(10) + ') udfv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') udfv_ct ' + CHAR(13) + '' + CHAR(10) + 'cross apply(' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select tbp.total_volume, tbp.total_settlement' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from #total_by_pipeline tbp --select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where tbp.as_of_date = dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.sub_id = dsv.sub_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.stra_id = dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.pipeline = udfv.udf_value' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + ') ca_total' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN contract_group cg ON cg.contract_name = udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN delivery_path dp on dp.CONTRACT = cg.contract_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + 'GROUP BY dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', dp.loss_factor' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#wacog_calc'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #wacog_calc' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select di.*, rs.*' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', (ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0)) [cg_gate]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume when 0 then di.settlement_amount' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else di.wellhead * di.deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wh_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume when 0 then di.settlement_amount' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(9) + '(ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [cg_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs((di.wellhead * di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_wh]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs(((ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_cg]' + CHAR(13) + '' + CHAR(10) + ' into #wacog_calc' + CHAR(13) + '' + CHAR(10) + ' from #detail_info di' + CHAR(13) + '' + CHAR(10) + 'left join #rate_schedule rs on rs.rate_contract_name = di.contract_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.contract_name, sum(wc.wellhead) wellhead, sum(wc.cg_gate) cg_gate' + CHAR(13) + '' + CHAR(10) + '--[__batch_report__]' + CHAR(13) + '' + CHAR(10) + 'from #wacog_calc wc' + CHAR(13) + '' + CHAR(10) + 'group by wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.contract_name', report_id = @report_id_data_source_dest 
		WHERE [name] = 'WACOG SUMMARY SQL'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 2 AS [type_id], 'WACOG SUMMARY SQL' AS [name], 'wsum' AS ALIAS, NULL AS [description],'--############ WORKING PIECE ####################### singapore version' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--STORE TOTAL VOLUME AND TOTAL SETTLEMENT BY PIPELINE' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#total_by_pipeline'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select ca.udf_value [pipeline], dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', null term_start, null term_end' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) total_settlement' + CHAR(13) + '' + CHAR(10) + 'into #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') ca2' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.deal_type_name = ''physical'' --and dsv.source_deal_header_id = 5201' + CHAR(13) + '' + CHAR(10) + 'group by ca.udf_value, dsv.as_of_date, dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#rate_schedule'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #rate_schedule ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'SELECT [rate_contract_name],' + CHAR(13) + '' + CHAR(10) + 'base, sur, aca, gri --INTO #rate_schedule --GIVEN ALREADY KNOWN RATES AS COLUMNS FOR PIVOT SINCE DYNAMIC SQL NOT SUPPORTED ON REPORT MANAGER SQL BUILT' + CHAR(13) + '' + CHAR(10) + 'into #rate_schedule' + CHAR(13) + '' + CHAR(10) + 'FROM ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    SELECT cg.contract_name [rate_contract_name], rate_type.code, abs(trs.rate) rate' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'FROM   contract_group cg' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join transportation_rate_schedule trs on trs.rate_schedule_id = cg.maintain_rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'left join static_data_value rate_type on rate_type.value_id = trs.rate_type_id' + CHAR(13) + '' + CHAR(10) + ') x' + CHAR(13) + '' + CHAR(10) + 'PIVOT ' + CHAR(13) + '' + CHAR(10) + '(' + CHAR(13) + '' + CHAR(10) + '    max(rate)' + CHAR(13) + '' + CHAR(10) + '    FOR code IN (base, sur, aca, gri)' + CHAR(13) + '' + CHAR(10) + ') p' + CHAR(13) + '' + CHAR(10) + '--select * from #rate_schedule' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#detail_info'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + 'select ' + CHAR(13) + '' + CHAR(10) + 'dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id, null book_id, null sub_book_id, null term_start, null term_end, null logical_name' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value [contract_name]' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.deal_volume) deal_volume' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_volume) total_volume' + CHAR(13) + '' + CHAR(10) + ', sum(dsv.settlement_value) [settlement_amount]' + CHAR(13) + '' + CHAR(10) + ', max(ca_total.total_settlement) total_set' + CHAR(13) + '' + CHAR(10) + ', case sum(dsv.deal_volume) ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'when 0 then 0 ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'else' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'abs(sum(dsv.settlement_value) / sum(dsv.deal_volume))' + CHAR(13) + '' + CHAR(10) + '  end [wellhead] --wellhead = total_set/total_volume' + CHAR(13) + '' + CHAR(10) + ', MAX(dp.loss_factor) loss_factor' + CHAR(13) + '' + CHAR(10) + ', abs(MAX(dp.loss_factor) * max(ca_total.total_settlement) / case max(ca_total.total_volume) when 0 then 1 else max(ca_total.total_volume) end) [fuel]' + CHAR(13) + '' + CHAR(10) + '--, sum(dsv.deal_volume) * max(ca_total.total_settlement) / case max(ca_total.total_volume) when 0 then 1 else max(ca_total.total_volume) end [wellhead_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'into #detail_info' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + '--select *' + CHAR(13) + '' + CHAR(10) + 'from {dsv} dsv ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value, udfv.field_label ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id  --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline'' and udfv.udf_value is not null  ' + CHAR(13) + '' + CHAR(10) + ') udfv ' + CHAR(13) + '' + CHAR(10) + 'cross apply (' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select distinct udfv.source_deal_header_id, udfv.udf_value ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from {udfv} udfv' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where udfv.source_deal_header_id = dsv.source_deal_header_id --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'and udfv.field_label = ''pipeline contract'' and udfv.udf_value is not null ' + CHAR(13) + '' + CHAR(10) + ') udfv_ct ' + CHAR(13) + '' + CHAR(10) + 'cross apply(' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'select tbp.total_volume, tbp.total_settlement' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'from #total_by_pipeline tbp --select * from #total_by_pipeline' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + 'where tbp.as_of_date = dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.sub_id = dsv.sub_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.stra_id = dsv.stra_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'and tbp.pipeline = udfv.udf_value' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + ') ca_total' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN contract_group cg ON cg.contract_name = udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + 'LEFT JOIN delivery_path dp on dp.CONTRACT = cg.contract_id' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'where 1 = 1 --and dsv.source_deal_header_id = 5220' + CHAR(13) + '' + CHAR(10) + 'GROUP BY dsv.as_of_date' + CHAR(13) + '' + CHAR(10) + ', dsv.sub_id, dsv.stra_id' + CHAR(13) + '' + CHAR(10) + ', udfv.field_label' + CHAR(13) + '' + CHAR(10) + ', udfv.udf_value' + CHAR(13) + '' + CHAR(10) + ', udfv_ct.udf_value' + CHAR(13) + '' + CHAR(10) + ', dsv.charge_type' + CHAR(13) + '' + CHAR(10) + '--, dsv.source_deal_header_id' + CHAR(13) + '' + CHAR(10) + ', dsv.buy_sell_flag' + CHAR(13) + '' + CHAR(10) + ', dp.loss_factor' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'if OBJECT_ID(N''tempdb..#wacog_calc'') is not null' + CHAR(13) + '' + CHAR(10) + 'drop table #wacog_calc' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select di.*, rs.*' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', (ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0)) [cg_gate]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume when 0 then di.settlement_amount' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else di.wellhead * di.deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [wh_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', case di.deal_volume when 0 then di.settlement_amount' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + 'else ' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(9) + '(ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '  end [cg_dollar]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs((di.wellhead * di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_wh]' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', abs(((ISNULL(di.wellhead,0) + ISNULL(di.fuel,0) + ISNULL(rs.base,0) + ISNULL(rs.aca,0) + ISNULL(rs.sur,0) + ISNULL(rs.gri,0))' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + '' + CHAR(9) + '* di.deal_volume) / case di.deal_volume when 0 then 1 else di.deal_volume end) [wacog_cg]' + CHAR(13) + '' + CHAR(10) + ' into #wacog_calc' + CHAR(13) + '' + CHAR(10) + ' from #detail_info di' + CHAR(13) + '' + CHAR(10) + 'left join #rate_schedule rs on rs.rate_contract_name = di.contract_name' + CHAR(13) + '' + CHAR(10) + '' + CHAR(13) + '' + CHAR(10) + 'select wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.contract_name, sum(wc.wellhead) wellhead, sum(wc.cg_gate) cg_gate' + CHAR(13) + '' + CHAR(10) + '--[__batch_report__]' + CHAR(13) + '' + CHAR(10) + 'from #wacog_calc wc' + CHAR(13) + '' + CHAR(10) + 'group by wc.as_of_date' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.sub_id, wc.stra_id, wc.book_id, wc.sub_book_id, wc.term_start, wc.term_end' + CHAR(13) + '' + CHAR(10) + '' + CHAR(9) + ', wc.contract_name' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'cg_dollar'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'CG Dollar'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'cg_dollar'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cg_dollar' AS [name], 'CG Dollar' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'cg_gate'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'City Gate'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'cg_gate'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cg_gate' AS [name], 'City Gate' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'contract_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'contract_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_name' AS [name], 'Contract' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'deal_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'deal_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_volume' AS [name], 'Deal Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'field_label'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Field Label'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'field_label'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'field_label' AS [name], 'Field Label' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'logical_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Logical Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'logical_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'logical_name' AS [name], 'Logical Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'pipeline'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'pipeline'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'pipeline'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pipeline' AS [name], 'pipeline' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = 1, widget_id = 6, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 1, widget_id = 6, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'wacog_cg'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'WACOG CG'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'wacog_cg'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'wacog_cg' AS [name], 'WACOG CG' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'wacog_wh'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'WACOG WH'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'wacog_wh'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'wacog_wh' AS [name], 'WACOG WH' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'wellhead'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Wellhead'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'wellhead'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'wellhead' AS [name], 'Wellhead' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'wh_dollar'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'WH Dollar'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'wh_dollar'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'wh_dollar' AS [name], 'WH Dollar' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG CALCS SQL'
	            AND dsc.name =  'buy_sell_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Buy Sell Flag'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG CALCS SQL'
			AND dsc.name =  'buy_sell_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'buy_sell_flag' AS [name], 'Buy Sell Flag' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'buy_sell_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Buy/Sell'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'buy_sell_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'buy_sell_flag' AS [name], 'Buy/Sell' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'charge_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Charge Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'charge_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'charge_type' AS [name], 'Charge Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'contract_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'contract_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_name' AS [name], 'Contract' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'deal_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'deal_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_volume' AS [name], 'Deal Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = 1, widget_id = 6, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 1, widget_id = 6, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'udf_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract Pipeline'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'udf_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'udf_value' AS [name], 'Contract Pipeline' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'total_set'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Total Set'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'total_set'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'total_set' AS [name], 'Total Set' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'field_label'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pipeline'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'field_label'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'field_label' AS [name], 'Pipeline' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'logical_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Logical Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'logical_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'logical_name' AS [name], 'Logical Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'total_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Total Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'total_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'total_volume' AS [name], 'Total Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'fuel'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Fuel'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'fuel'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'fuel' AS [name], 'Fuel' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'loss_factor'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Loss Factor'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'loss_factor'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'loss_factor' AS [name], 'Loss Factor' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'settlement_amount'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Settlement Amount'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'settlement_amount'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'settlement_amount' AS [name], 'Settlement Amount' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'wellhead'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Wellhead'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'wellhead'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'wellhead' AS [name], 'Wellhead' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'aca'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'ACA'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'aca'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'aca' AS [name], 'ACA' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'base'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'BASE'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'base'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'base' AS [name], 'BASE' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'cg_gate'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'CG Gate'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'cg_gate'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cg_gate' AS [name], 'CG Gate' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'gri'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'GRI'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'gri'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'gri' AS [name], 'GRI' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'sur'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'SUR'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'sur'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sur' AS [name], 'SUR' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'cg_dollar'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'CG Dollar'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'cg_dollar'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cg_dollar' AS [name], 'CG Dollar' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'wacog_cg'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'WACOG CG'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'wacog_cg'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'wacog_cg' AS [name], 'WACOG CG' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'wacog_wh'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'WACOG WH'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'wacog_wh'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'wacog_wh' AS [name], 'WACOG WH' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'wh_dollar'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'WH Dollar'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'wh_dollar'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'wh_dollar' AS [name], 'WH Dollar' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG purchase SQL'
	            AND dsc.name =  'rate_contract_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Rate Contract Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG purchase SQL'
			AND dsc.name =  'rate_contract_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'rate_contract_name' AS [name], 'Rate Contract Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG SUMMARY SQL'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'as_of_date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG SUMMARY SQL'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'as_of_date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG SUMMARY SQL'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'book_id'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG SUMMARY SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG SUMMARY SQL'
	            AND dsc.name =  'cg_gate'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'cg_gate'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG SUMMARY SQL'
			AND dsc.name =  'cg_gate'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cg_gate' AS [name], 'cg_gate' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG SUMMARY SQL'
	            AND dsc.name =  'contract_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'contract_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG SUMMARY SQL'
			AND dsc.name =  'contract_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_name' AS [name], 'contract_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG SUMMARY SQL'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'stra_id'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG SUMMARY SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG SUMMARY SQL'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_book_id'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG SUMMARY SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG SUMMARY SQL'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_id'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG SUMMARY SQL'
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
		INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG SUMMARY SQL'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'term_end'
			   , reqd_param = 1, widget_id = 6, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG SUMMARY SQL'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'term_end' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG SUMMARY SQL'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'term_start'
			   , reqd_param = 1, widget_id = 6, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG SUMMARY SQL'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'term_start' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'WACOG SUMMARY SQL'
	            AND dsc.name =  'wellhead'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'wellhead'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'WACOG SUMMARY SQL'
			AND dsc.name =  'wellhead'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'wellhead' AS [name], 'wellhead' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'WACOG CALCS SQL'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'WACOG purchase SQL'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'WACOG SUMMARY SQL'
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
	

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'dsv')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'dsv' [alias], rd_root.report_dataset_id AS root_dataset_id
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'Deal Settlement View'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'wps')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'wps' [alias], rd_root.report_dataset_id AS root_dataset_id
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'WACOG purchase SQL'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'udfv')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'udfv' [alias], rd_root.report_dataset_id AS root_dataset_id
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'UDF View'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'wcsql')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'wcsql' [alias], rd_root.report_dataset_id AS root_dataset_id
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'WACOG CALCS SQL'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'wsum')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'wsum' [alias], rd_root.report_dataset_id AS root_dataset_id
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'WACOG SUMMARY SQL'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

	IF NOT EXISTS(SELECT 1 FROM report_page rp 
	              WHERE rp.report_id = CASE WHEN 'e ' = 'p' 
											Then 7272 
											ELSE @report_id_dest 
						               END 
					AND rp.name =  'WACOG Purchase'  
	)
	BEGIN
		INSERT INTO report_page(report_id, [name], report_hash, width, height)
		SELECT CASE WHEN 'e ' = 'p' 
					Then 7272 
					ELSE @report_id_dest 
		       END  AS report_id, 'WACOG Purchase' [name], 'E02473E5_D0CE_4BA8_8043_43DD1AB112EA' report_hash, 12 width,7 height
	END 
	

		INSERT INTO report_paramset(page_id, [name], paramset_hash)
		SELECT TOP 1 rpage.report_page_id, 'WACOG Purchase', 'F00B427C_B8E2_4F4F_9AFF_1AE4A91C9667' 
		FROM sys.objects o
		INNER JOIN report_page rpage 
			on rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
		ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
	

		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, '(  wps.[charge_type] = ''@charge_type'')' AS where_part
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = CASE WHEN 'e ' = 'p' 
									Then 7272 
									ELSE @report_id_dest 
			                  END
			AND rd.[alias] = 'wps'
	

		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, NULL AS where_part
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = CASE WHEN 'e ' = 'p' 
									Then 7272 
									ELSE @report_id_dest 
			                  END
			AND rd.[alias] = 'wcsql'
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '7/31/2013' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 6 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wps'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wps'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG purchase SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'as_of_date'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '235,204' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wps'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wps'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG purchase SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, 'commodity' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 7 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wps'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wps'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG purchase SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'charge_type'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 5 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wps'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wps'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG purchase SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'stra_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wps'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wps'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG purchase SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wps'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wps'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG purchase SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '7/31/2013' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wps'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wps'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG purchase SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_end'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '7/1/2013' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wps'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wps'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG purchase SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_start'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '7/31/2013' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 6 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wcsql'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wcsql'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG CALCS SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'as_of_date'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wcsql'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wcsql'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG CALCS SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '201' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 5 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wcsql'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wcsql'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG CALCS SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'stra_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wcsql'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wcsql'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG CALCS SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wcsql'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wcsql'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG CALCS SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '7/31/2013' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wcsql'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wcsql'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG CALCS SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_end'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '7/1/2013' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'WACOG Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'wcsql'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'wcsql'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'WACOG CALCS SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'term_start'	
	

		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary,no_header)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'Wacog Purchase' [name], '11.4' width, '1.8666666666666667' height, '0.32' [top], '0.09333333333333334' [left],2 AS group_mode,1 AS border_style,0 AS page_break,1 AS type_id,1 AS cross_summary,2 AS no_header
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'wps' 
	

		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary,no_header)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'wacog calc' [name], '11.413333333333334' width, '1.8666666666666667' height, '2.1866666666666665' [top], '0.06666666666666666' [left],2 AS group_mode,1 AS border_style,0 AS page_break,1 AS type_id,1 AS cross_summary,2 AS no_header
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'wcsql' 
	

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 1 column_order,NULL aggregation, NULL functions, 'Buy Sell' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'buy_sell_flag' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,2 placement, 2 column_order,NULL aggregation, NULL functions, 'Contract' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'contract_name' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 2 column_order,NULL aggregation, NULL functions, 'TOTAL VOLUME' [alias], 1 sortable, -1 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,13 sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'deal_volume' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,2 placement, 1 column_order,NULL aggregation, NULL functions, 'Pipeline' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'udf_value' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 6 column_order,NULL aggregation, 'ABS(wps.wellhead)' functions, 'WELLHEAD' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'wellhead' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 5 column_order,NULL aggregation, NULL functions, 'Pipeline Fuel %' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'loss_factor' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 7 column_order,NULL aggregation, 'ABS(wps.fuel)' functions, 'FUEL' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'fuel' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 3 column_order,NULL aggregation, 'case when wps.deal_volume > 0 or wps.deal_volume = 0 then abs(wps.settlement_amount) else abs(wps.settlement_amount) * -1 end' functions, 'TOTAL $' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'settlement_amount' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 4 column_order,NULL aggregation, NULL functions, 'Charge Type' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'charge_type' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 9 column_order,NULL aggregation, NULL functions, 'ACA' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'aca' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 11 column_order,NULL aggregation, NULL functions, 'GRI' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'gri' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 8 column_order,NULL aggregation, NULL functions, 'Base' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'base' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 10 column_order,NULL aggregation, NULL functions, 'SUR' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'sur' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 12 column_order,NULL aggregation, 'ABS(wps.cg_gate)' functions, 'City Gate' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wps' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'cg_gate' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 1 column_order,NULL aggregation, NULL functions, 'Contract' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wcsql' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'contract_name' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 2 column_order,NULL aggregation, NULL functions, 'Buy Sell Flag' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wcsql' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'buy_sell_flag' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 3 column_order,NULL aggregation, NULL functions, 'Deal Volume' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wcsql' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'deal_volume' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 4 column_order,NULL aggregation, NULL functions, 'Wellhead' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wcsql' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'wellhead' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 5 column_order,NULL aggregation, NULL functions, 'City Gate' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wcsql' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'cg_gate' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 6 column_order,NULL aggregation, NULL functions, 'WH $' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wcsql' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'wh_dollar' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 7 column_order,NULL aggregation, NULL functions, 'CG $' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wcsql' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'cg_dollar' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 8 column_order,NULL aggregation, NULL functions, 'WACOG WH' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wcsql' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'wacog_wh' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 9 column_order,NULL aggregation, NULL functions, 'WACOG CG' [alias], 1 sortable, 4 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wcsql' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'wacog_cg' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,2 placement, 1 column_order,NULL aggregation, NULL functions, 'pipeline' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,NULL cross_summary_aggregation,NULL mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'wcsql' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'pipeline' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'buy_sell_flag' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'charge_type' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'contract_name' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'deal_volume' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'udf_value' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'fuel' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'loss_factor' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'settlement_amount' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'wellhead' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'aca' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'base' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'cg_gate' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'gri' 
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
			ON  rpt.[name] = 'Wacog Purchase'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG purchase SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'sur' 
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
			ON  rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'cg_dollar' 
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
			ON  rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'cg_gate' 
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
			ON  rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'contract_name' 
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
			ON  rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'deal_volume' 
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
			ON  rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'pipeline' 
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
			ON  rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'wacog_cg' 
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
			ON  rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'wacog_wh' 
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
			ON  rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'wellhead' 
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
			ON  rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'wh_dollar' 
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
			ON  rpt.[name] = 'wacog calc'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'WACOG reports'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'WACOG CALCS SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'buy_sell_flag' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	

		INSERT INTO report_page_textbox(page_id,content,font,font_size,font_style,width,height,[top],[left],[hash])
		SELECT TOP 1 rpage.report_page_id page_id, 'WACOG PURCHASE' [content], 'Verdana' [font], '8' font_size, '1,0,0' font_style, '2.6666666666666665' width, '0.26666666666666666' height, '0.05333333333333334' [top], '0.10666666666666667' [left],'57290058_3A06_4D82_AAB9_7A0ECA0DB2EB' [hash] 		
		FROM sys.objects o
		INNER JOIN report_page rpage 
			ON rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
	

		INSERT INTO report_page_textbox(page_id,content,font,font_size,font_style,width,height,[top],[left],[hash])
		SELECT TOP 1 rpage.report_page_id page_id, 'WACOG CALC' [content], 'Verdana' [font], '8' font_size, '1,0,0' font_style, '2.6666666666666665' width, '0.26666666666666666' height, '1.8933333333333333' [top], '0.10666666666666667' [left],'BFCBBFEA_0B21_40AA_BA45_1518A4C414B1' [hash] 		
		FROM sys.objects o
		INNER JOIN report_page rpage 
			ON rpage.[name] = 'WACOG Purchase'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'WACOG reports'
	
COMMIT 

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;
		
	PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
END CATCH
