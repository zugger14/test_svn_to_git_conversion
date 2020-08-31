BEGIN TRY
		BEGIN TRAN

		DECLARE @report_id_dest INT 
		
		IF 'e ' = 'p'
		BEGIN
			Set @report_id_dest = NULL
		END
	
IF EXISTS (SELECT 1 FROM dbo.report WHERE name='MTM Assets and Liabilities Report by Counterparty')
		BEGIN
		EXEC spa_rfx_report 'd', NULL,11680, NULL, NULL, NULL, NULL, NULL
		END

		DECLARE @report_id_dest_old INT 

		SELECT @report_id_dest_old = report_id
		FROM report r
		WHERE r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		
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
			SELECT TOP 1 'MTM Assets and Liabilities Report by Counterparty' [name], 'farrms_admin' [owner], 0 is_system, '05F74409_B8BF_4199_BD0F_672B3C98EA41' report_hash, 'MTM Assets and Liabilities Report by Counterparty' [description], CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
			FROM sys.objects o
			LEFT JOIN static_data_value sdv_cat ON sdv_cat.code = 'MTM' AND sdv_cat.type_id = 10008 
			SET @report_id_dest = SCOPE_IDENTITY()
		END
BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = 'MTM Assets and Liabilities Report by Counterparty'

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'MTM Assets and Liabilities Couterparty SQL'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'MTMAL', description = NULL
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_transaction_type VARCHAR(100) = ''@transaction_type''
IF @_transaction_type = ''NULL''
	SET @_transaction_type = NULL
SELECT 
	MAX(mtm1.as_of_date) as_of_date
	, MAX(mtm1.to_as_of_date) to_as_of_date
	, MAX(mtm1.book_id) book_id
	, MAX(mtm1.stra_id) stra_id
	, MAX(mtm1.sub_book_id) sub_book_id
	, MAX(mtm1.sub_id) sub_id
	, MAX(mtm1.period_from) period_from
	, MAX(mtm1.period_to) period_to
	, mtm1.source_counterparty_id
	, @_transaction_type transaction_type
	, mtm1.current_non_current
	, MAX(mtm1.commodity) commodity
	, MAX(mtm1.physical_financial) physical_financial
	, MAX(mtm1.counterparty_name) counterparty_name
	, SUM(mtm1.fair_value) fair_value
	, MAX(mtm1.deal_id) deal_id
	, SUM(mtm1.dis_fair_value) dis_fair_value
	,CASE 
		WHEN SUM(mtm1.dis_fair_value) < 0
			THEN SUM(mtm1.dis_fair_value)
		ELSE 0
		END [Liability]
	,CASE 
		WHEN SUM(mtm1.dis_fair_value) >= 0
			THEN SUM(mtm1.dis_fair_value)
		ELSE 0
		END [Asset]
FROM {MTMDEV1} mtm1
WHERE (@_transaction_type IS NULL OR mtm1.transaction_type = @_transaction_type)
GROUP BY mtm1.source_counterparty_id
		,mtm1.current_non_current', report_id = @report_id_data_source_dest 
		WHERE [name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'MTM Assets and Liabilities Deal SQL'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'MTMAL1', description = NULL
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'SELECT MAX(mtm1.as_of_date) as_of_date
	,MAX(mtm1.to_as_of_date) to_as_of_date
	,mtm1.book_id
	,mtm1.stra_id
	,mtm1.sub_book_id
	,mtm1.sub_id
	,MAX(mtm1.period_from) period_from
	,MAX(mtm1.period_to) period_to
	,mtm1.source_counterparty_id
	,MAX(mtm1.transaction_type) transaction_type
	,mtm1.current_non_current
	,mtm1.commodity
	,MAX(mtm1.physical_financial) physical_financial
	,mtm1.counterparty_name
	,SUM(mtm1.fair_value) fair_value
	,mtm1.deal_id
	,SUM(mtm3.dis_fair_value) dis_fair_value
	,(
		CASE 
			WHEN SUM(mtm3.dis_fair_value) < 0
				THEN SUM(mtm3.dis_fair_value)
			ELSE 0
			END
		) [Liability]
	,(
		CASE 
			WHEN SUM(mtm3.dis_fair_value) >= 0
				THEN SUM(mtm3.dis_fair_value)
			ELSE 0
			END
		) [Asset]
	,coalesce(deal_level.code, curve_level.code, ''Level 3'') group_level
FROM {MTMDEV1} mtm1
INNER JOIN (
	SELECT SUM(mtm2.dis_fair_value) [dis_fair_value]
		,mtm2.source_counterparty_id
		,mtm2.current_non_current
		,mtm2.source_deal_header_id
		,mtm2.term_start
	FROM {MTMDEV1} mtm2
	GROUP BY mtm2.source_counterparty_id
		,mtm2.current_non_current
		,mtm2.source_deal_header_id
		,mtm2.term_start
	) mtm3 ON mtm3.source_counterparty_id = mtm1.source_counterparty_id
	AND mtm3.current_non_current = mtm1.current_non_current
	AND mtm3.source_deal_header_id = mtm1.source_deal_header_id
	AND mtm3.term_start = mtm1.term_start
OUTER APPLY (
	SELECT fv_level_value_id
		,MAX(effective_date) effective_date
	FROM fv_report_group_deal
	WHERE source_deal_header_id = mtm1.source_deal_header_id
		AND mtm1.term_start = term_start
		AND effective_date <= mtm1.as_of_date
		AND effective_date = (
			SELECT MAX(effective_date)
			FROM fv_report_group_deal
			WHERE source_deal_header_id = mtm1.source_deal_header_id
				AND mtm1.term_start = term_start
				AND effective_date <= mtm1.as_of_date
			)
	GROUP BY fv_level_value_id
	) frgd
LEFT JOIN static_data_value deal_level ON deal_level.value_id = frgd.fv_level_value_id
OUTER APPLY (
	SELECT fv_reporting_group_id
		,MAX(effective_date) effective_date
	FROM price_curve_fv_mapping
	WHERE source_curve_def_id = mtm1.curve_id
		AND mtm1.term_start BETWEEN DATEADD(MM, from_no_of_months, effective_date)
			AND DATEADD(MM, to_no_of_months, effective_date)
		AND effective_date <= mtm1.as_of_date
		AND effective_date = (
			SELECT MAX(effective_date)
			FROM price_curve_fv_mapping
			WHERE source_curve_def_id = mtm1.curve_id
				AND mtm1.term_start BETWEEN DATEADD(MM, from_no_of_months, effective_date)
					AND DATEADD(MM, to_no_of_months, effective_date)
				AND effective_date <= mtm1.as_of_date
			)
	GROUP BY fv_reporting_group_id
	) pcfm1
LEFT JOIN static_data_value curve_level ON curve_level.value_id = pcfm1.fv_reporting_group_id
WHERE mtm1.leg = 1
GROUP BY mtm1.book_id
	,mtm1.stra_id
	,mtm1.sub_book_id
	,mtm1.sub_id
	,mtm1.current_non_current
	,mtm1.counterparty_name
	,mtm1.source_counterparty_id
	,mtm1.commodity
	,mtm1.deal_id
	,coalesce(deal_level.code, curve_level.code, ''Level 3'')', report_id = @report_id_data_source_dest 
		WHERE [name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'MTM Assets and Liabilities Net SQL'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'DALS', description = NULL
		, [tsql] = CAST('' AS VARCHAR(MAX)) + '--combined
DECLARE @_transaction_type VARCHAR(100) = ''@transaction_type''
IF @_transaction_type = ''NULL''
	SET @_transaction_type = NULL

IF OBJECT_ID(N''tempdb..#mtm_asset_liab'') IS NOT NULL
	DROP TABLE #mtm_asset_liab

CREATE TABLE #mtm_asset_liab
(
	as_of_date DATETIME
	, Liability float
	, Asset float
	, item VARCHAR(100) COLLATE DATABASE_DEFAULT
	, source_counterparty_id INT
	, transaction_type VARCHAR(250) COLLATE DATABASE_DEFAULT
	, current_non_current VARCHAR(100) COLLATE DATABASE_DEFAULT
	, period_from VARCHAR(50) COLLATE DATABASE_DEFAULT
	, period_to VARCHAR(50) COLLATE DATABASE_DEFAULT
	, sub_id INT
	, stra_id INT
	, book_id INT
	, sub_book_id INT
)

INSERT INTO #mtm_asset_liab (as_of_date, Liability, Asset, item, source_counterparty_id, current_non_current, period_from, period_to, sub_id, stra_id, book_id, sub_book_id)
SELECT MAX(rs_deal.as_of_date) as_of_date
	,SUM(rs_deal.Liability) [Liability]
	,SUM(rs_deal.Asset) [Asset]
	,''By Deal'' item
	,MAX(rs_deal.source_counterparty_id) source_counterparty_id
	,MAX(rs_deal.current_non_current) current_non_current
	,MAX(rs_deal.period_from) period_from
	,MAX(rs_deal.period_to) period_to
	,MAX(rs_deal.sub_id) sub_id
	,MAX(rs_deal.stra_id) stra_id
	,MAX(rs_deal.book_id) book_id
	,MAX(rs_deal.sub_book_id) sub_book_id
FROM 
(
	SELECT MAX(mtm1.as_of_date) as_of_date
		,MAX(mtm1.to_as_of_date) to_as_of_date
		,mtm1.book_id
		,mtm1.stra_id
		,mtm1.sub_book_id
		,mtm1.sub_id
		,MAX(mtm1.period_from) period_from
		,MAX(mtm1.period_to) period_to
		,mtm1.source_counterparty_id
		,mtm1.current_non_current
		,mtm1.commodity
		,MAX(mtm1.physical_financial) physical_financial
		,mtm1.counterparty_name
		,SUM(mtm1.fair_value) fair_value
		,mtm1.deal_id
		,SUM(mtm3.dis_fair_value) dis_fair_value
		,(
			CASE 
				WHEN SUM(mtm3.dis_fair_value) < 0
					THEN SUM(mtm3.dis_fair_value)
				ELSE 0
				END
			) [Liability]
		,(
			CASE 
				WHEN SUM(mtm3.dis_fair_value) >= 0
					THEN SUM(mtm3.dis_fair_value)
				ELSE 0
				END
			) [Asset]
		,coalesce(deal_level.code, curve_level.code, ''Level 3'') group_level
	FROM {MTMDEV1} mtm1
	INNER JOIN (
		SELECT SUM(mtm2.dis_fair_value) [dis_fair_value]
			,mtm2.source_counterparty_id
			,mtm2.current_non_current
			,mtm2.source_deal_header_id
			,mtm2.term_start
		FROM {MTMDEV1} mtm2
WHERE (@_transaction_type IS NULL OR mtm2.transaction_type = @_transaction_type)
		GROUP BY mtm2.source_counterparty_id
			,mtm2.current_non_current
			,mtm2.source_deal_header_id
			,mtm2.term_start
		) mtm3 ON mtm3.source_counterparty_id = mtm1.source_counterparty_id
		AND mtm3.current_non_current = mtm1.current_non_current
		AND mtm3.source_deal_header_id = mtm1.source_deal_header_id
		AND mtm3.term_start = mtm1.term_start
	OUTER APPLY (
		SELECT fv_level_value_id
			,MAX(effective_date) effective_date
		FROM fv_report_group_deal
		WHERE source_deal_header_id = mtm1.source_deal_header_id
			AND mtm1.term_start = term_start
			AND effective_date <= mtm1.as_of_date
			AND effective_date = (
				SELECT MAX(effective_date)
				FROM fv_report_group_deal
				WHERE source_deal_header_id = mtm1.source_deal_header_id
					AND mtm1.term_start = term_start
					AND effective_date <= mtm1.as_of_date
				)
		GROUP BY fv_level_value_id
		) frgd
	LEFT JOIN static_data_value deal_level ON deal_level.value_id = frgd.fv_level_value_id
	OUTER APPLY (
		SELECT fv_reporting_group_id
			,MAX(effective_date) effective_date
		FROM price_curve_fv_mapping
		WHERE source_curve_def_id = mtm1.curve_id
			AND mtm1.term_start BETWEEN DATEADD(MM, from_no_of_months, effective_date)
				AND DATEADD(MM, to_no_of_months, effective_date)
			AND effective_date <= mtm1.as_of_date
			AND effective_date = (
				SELECT MAX(effective_date)
				FROM price_curve_fv_mapping
				WHERE source_curve_def_id = mtm1.curve_id
					AND mtm1.term_start BETWEEN DATEADD(MM, from_no_of_months, effective_date)
						AND DATEADD(MM, to_no_of_months, effective_date)
					AND effective_date <= mtm1.as_of_date
				)
		GROUP BY fv_reporting_group_id
		) pcfm1
	LEFT JOIN static_data_value curve_level ON curve_level.value_id = pcfm1.fv_reporting_group_id
	WHERE mtm1.leg = 1 AND (@_transaction_type IS NULL OR mtm1.transaction_type = @_transaction_type)
	GROUP BY mtm1.book_id
		,mtm1.stra_id
		,mtm1.sub_book_id
		,mtm1.sub_id
		,mtm1.current_non_current
		,mtm1.counterparty_name
		,mtm1.source_counterparty_id
		,mtm1.commodity
		,mtm1.deal_id
		,coalesce(deal_level.code, curve_level.code, ''Level 3'')
) rs_deal

UNION ALL

SELECT MAX(rs_cp.as_of_date) as_of_date
	,SUM(rs_cp.Liability) [Liability]
	,SUM(rs_cp.Asset) [Asset]
	,'' By Counterparty'' item
	 ,MAX(rs_cp.source_counterparty_id) source_counterparty_id
	,MAX(rs_cp.current_non_current) current_non_current
	,MAX(rs_cp.period_from) period_from
	,MAX(rs_cp.period_to) period_to
	,MAX(rs_cp.sub_id) sub_id
	,MAX(rs_cp.stra_id) stra_id
	,MAX(rs_cp.book_id) book_id
	,MAX(rs_cp.sub_book_id) sub_book_id
FROM 
(
		SELECT 
	MAX(mtm1.as_of_date) as_of_date
	, MAX(mtm1.to_as_of_date) to_as_of_date
	, MAX(mtm1.book_id) book_id
	, MAX(mtm1.stra_id) stra_id
	, MAX(mtm1.sub_book_id) sub_book_id
	, MAX(mtm1.sub_id) sub_id
	, MAX(mtm1.period_from) period_from
	, MAX(mtm1.period_to) period_to
	, mtm1.source_counterparty_id
	, @_transaction_type transaction_type
	, mtm1.current_non_current
	, MAX(mtm1.commodity) commodity
	, MAX(mtm1.physical_financial) physical_financial
	, MAX(mtm1.counterparty_name) counterparty_name
	, SUM(mtm1.fair_value) fair_value
	, MAX(mtm1.deal_id) deal_id
	, SUM(mtm1.dis_fair_value) dis_fair_value
	,CASE 
		WHEN SUM(mtm1.dis_fair_value) < 0
			THEN SUM(mtm1.dis_fair_value)
		ELSE 0
		END [Liability]
	,CASE 
		WHEN SUM(mtm1.dis_fair_value) >= 0
			THEN SUM(mtm1.dis_fair_value)
		ELSE 0
		END [Asset]
FROM {MTMDEV1} mtm1
WHERE (@_transaction_type IS NULL OR mtm1.transaction_type = @_transaction_type)
GROUP BY mtm1.source_counterparty_id
		,mtm1.current_non_current
) rs_cp

--[__batch_report__]
SELECT * FROM
(
SELECT as_of_date, Liability, Asset, item, source_counterparty_id, @_transaction_type transaction_type, current_non_current, period_from, period_to, sub_id, stra_id, book_id, sub_book_id 
FROM #mtm_asset_liab m

UNION ALL

SELECT m1.as_of_date, (m1.Liability - m2.Liability) Liability, (m1.Asset - m2.Asset) Asset, ''Net'' item, m1.source_counterparty_id, @_transaction_type transaction_type, NULL AS current_non_current, m1.period_from, m1.period_to, m1.sub_id, m1.stra_id, m1.book_id, m1.sub_book_id 
FROM #mtm_asset_liab m1
INNER JOIN #mtm_asset_liab m2 ON ISNULL(m2.item, '''') = ''By Deal'' AND ISNULL(m1.item, '''') = '' By Counterparty''
) rs', report_id = @report_id_data_source_dest 
		WHERE [name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'MTM Assets and Liabilities Couterparty SQL'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 2 AS [type_id], 'MTM Assets and Liabilities Couterparty SQL' AS [name], 'MTMAL' AS ALIAS, NULL AS [description],'DECLARE @_transaction_type VARCHAR(100) = ''@transaction_type''
IF @_transaction_type = ''NULL''
	SET @_transaction_type = NULL
SELECT 
	MAX(mtm1.as_of_date) as_of_date
	, MAX(mtm1.to_as_of_date) to_as_of_date
	, MAX(mtm1.book_id) book_id
	, MAX(mtm1.stra_id) stra_id
	, MAX(mtm1.sub_book_id) sub_book_id
	, MAX(mtm1.sub_id) sub_id
	, MAX(mtm1.period_from) period_from
	, MAX(mtm1.period_to) period_to
	, mtm1.source_counterparty_id
	, @_transaction_type transaction_type
	, mtm1.current_non_current
	, MAX(mtm1.commodity) commodity
	, MAX(mtm1.physical_financial) physical_financial
	, MAX(mtm1.counterparty_name) counterparty_name
	, SUM(mtm1.fair_value) fair_value
	, MAX(mtm1.deal_id) deal_id
	, SUM(mtm1.dis_fair_value) dis_fair_value
	,CASE 
		WHEN SUM(mtm1.dis_fair_value) < 0
			THEN SUM(mtm1.dis_fair_value)
		ELSE 0
		END [Liability]
	,CASE 
		WHEN SUM(mtm1.dis_fair_value) >= 0
			THEN SUM(mtm1.dis_fair_value)
		ELSE 0
		END [Asset]
FROM {MTMDEV1} mtm1
WHERE (@_transaction_type IS NULL OR mtm1.transaction_type = @_transaction_type)
GROUP BY mtm1.source_counterparty_id
		,mtm1.current_non_current' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'MTM Assets and Liabilities Deal SQL'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 2 AS [type_id], 'MTM Assets and Liabilities Deal SQL' AS [name], 'MTMAL1' AS ALIAS, NULL AS [description],'SELECT MAX(mtm1.as_of_date) as_of_date
	,MAX(mtm1.to_as_of_date) to_as_of_date
	,mtm1.book_id
	,mtm1.stra_id
	,mtm1.sub_book_id
	,mtm1.sub_id
	,MAX(mtm1.period_from) period_from
	,MAX(mtm1.period_to) period_to
	,mtm1.source_counterparty_id
	,MAX(mtm1.transaction_type) transaction_type
	,mtm1.current_non_current
	,mtm1.commodity
	,MAX(mtm1.physical_financial) physical_financial
	,mtm1.counterparty_name
	,SUM(mtm1.fair_value) fair_value
	,mtm1.deal_id
	,SUM(mtm3.dis_fair_value) dis_fair_value
	,(
		CASE 
			WHEN SUM(mtm3.dis_fair_value) < 0
				THEN SUM(mtm3.dis_fair_value)
			ELSE 0
			END
		) [Liability]
	,(
		CASE 
			WHEN SUM(mtm3.dis_fair_value) >= 0
				THEN SUM(mtm3.dis_fair_value)
			ELSE 0
			END
		) [Asset]
	,coalesce(deal_level.code, curve_level.code, ''Level 3'') group_level
FROM {MTMDEV1} mtm1
INNER JOIN (
	SELECT SUM(mtm2.dis_fair_value) [dis_fair_value]
		,mtm2.source_counterparty_id
		,mtm2.current_non_current
		,mtm2.source_deal_header_id
		,mtm2.term_start
	FROM {MTMDEV1} mtm2
	GROUP BY mtm2.source_counterparty_id
		,mtm2.current_non_current
		,mtm2.source_deal_header_id
		,mtm2.term_start
	) mtm3 ON mtm3.source_counterparty_id = mtm1.source_counterparty_id
	AND mtm3.current_non_current = mtm1.current_non_current
	AND mtm3.source_deal_header_id = mtm1.source_deal_header_id
	AND mtm3.term_start = mtm1.term_start
OUTER APPLY (
	SELECT fv_level_value_id
		,MAX(effective_date) effective_date
	FROM fv_report_group_deal
	WHERE source_deal_header_id = mtm1.source_deal_header_id
		AND mtm1.term_start = term_start
		AND effective_date <= mtm1.as_of_date
		AND effective_date = (
			SELECT MAX(effective_date)
			FROM fv_report_group_deal
			WHERE source_deal_header_id = mtm1.source_deal_header_id
				AND mtm1.term_start = term_start
				AND effective_date <= mtm1.as_of_date
			)
	GROUP BY fv_level_value_id
	) frgd
LEFT JOIN static_data_value deal_level ON deal_level.value_id = frgd.fv_level_value_id
OUTER APPLY (
	SELECT fv_reporting_group_id
		,MAX(effective_date) effective_date
	FROM price_curve_fv_mapping
	WHERE source_curve_def_id = mtm1.curve_id
		AND mtm1.term_start BETWEEN DATEADD(MM, from_no_of_months, effective_date)
			AND DATEADD(MM, to_no_of_months, effective_date)
		AND effective_date <= mtm1.as_of_date
		AND effective_date = (
			SELECT MAX(effective_date)
			FROM price_curve_fv_mapping
			WHERE source_curve_def_id = mtm1.curve_id
				AND mtm1.term_start BETWEEN DATEADD(MM, from_no_of_months, effective_date)
					AND DATEADD(MM, to_no_of_months, effective_date)
				AND effective_date <= mtm1.as_of_date
			)
	GROUP BY fv_reporting_group_id
	) pcfm1
LEFT JOIN static_data_value curve_level ON curve_level.value_id = pcfm1.fv_reporting_group_id
WHERE mtm1.leg = 1
GROUP BY mtm1.book_id
	,mtm1.stra_id
	,mtm1.sub_book_id
	,mtm1.sub_id
	,mtm1.current_non_current
	,mtm1.counterparty_name
	,mtm1.source_counterparty_id
	,mtm1.commodity
	,mtm1.deal_id
	,coalesce(deal_level.code, curve_level.code, ''Level 3'')' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'MTM Assets and Liabilities Net SQL'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 2 AS [type_id], 'MTM Assets and Liabilities Net SQL' AS [name], 'DALS' AS ALIAS, NULL AS [description],'--combined
DECLARE @_transaction_type VARCHAR(100) = ''@transaction_type''
IF @_transaction_type = ''NULL''
	SET @_transaction_type = NULL

IF OBJECT_ID(N''tempdb..#mtm_asset_liab'') IS NOT NULL
	DROP TABLE #mtm_asset_liab

CREATE TABLE #mtm_asset_liab
(
	as_of_date DATETIME
	, Liability float
	, Asset float
	, item VARCHAR(100) COLLATE DATABASE_DEFAULT
	, source_counterparty_id INT
	, transaction_type VARCHAR(250) COLLATE DATABASE_DEFAULT
	, current_non_current VARCHAR(100) COLLATE DATABASE_DEFAULT
	, period_from VARCHAR(50) COLLATE DATABASE_DEFAULT
	, period_to VARCHAR(50) COLLATE DATABASE_DEFAULT
	, sub_id INT
	, stra_id INT
	, book_id INT
	, sub_book_id INT
)

INSERT INTO #mtm_asset_liab (as_of_date, Liability, Asset, item, source_counterparty_id, current_non_current, period_from, period_to, sub_id, stra_id, book_id, sub_book_id)
SELECT MAX(rs_deal.as_of_date) as_of_date
	,SUM(rs_deal.Liability) [Liability]
	,SUM(rs_deal.Asset) [Asset]
	,''By Deal'' item
	,MAX(rs_deal.source_counterparty_id) source_counterparty_id
	,MAX(rs_deal.current_non_current) current_non_current
	,MAX(rs_deal.period_from) period_from
	,MAX(rs_deal.period_to) period_to
	,MAX(rs_deal.sub_id) sub_id
	,MAX(rs_deal.stra_id) stra_id
	,MAX(rs_deal.book_id) book_id
	,MAX(rs_deal.sub_book_id) sub_book_id
FROM 
(
	SELECT MAX(mtm1.as_of_date) as_of_date
		,MAX(mtm1.to_as_of_date) to_as_of_date
		,mtm1.book_id
		,mtm1.stra_id
		,mtm1.sub_book_id
		,mtm1.sub_id
		,MAX(mtm1.period_from) period_from
		,MAX(mtm1.period_to) period_to
		,mtm1.source_counterparty_id
		,mtm1.current_non_current
		,mtm1.commodity
		,MAX(mtm1.physical_financial) physical_financial
		,mtm1.counterparty_name
		,SUM(mtm1.fair_value) fair_value
		,mtm1.deal_id
		,SUM(mtm3.dis_fair_value) dis_fair_value
		,(
			CASE 
				WHEN SUM(mtm3.dis_fair_value) < 0
					THEN SUM(mtm3.dis_fair_value)
				ELSE 0
				END
			) [Liability]
		,(
			CASE 
				WHEN SUM(mtm3.dis_fair_value) >= 0
					THEN SUM(mtm3.dis_fair_value)
				ELSE 0
				END
			) [Asset]
		,coalesce(deal_level.code, curve_level.code, ''Level 3'') group_level
	FROM {MTMDEV1} mtm1
	INNER JOIN (
		SELECT SUM(mtm2.dis_fair_value) [dis_fair_value]
			,mtm2.source_counterparty_id
			,mtm2.current_non_current
			,mtm2.source_deal_header_id
			,mtm2.term_start
		FROM {MTMDEV1} mtm2
WHERE (@_transaction_type IS NULL OR mtm2.transaction_type = @_transaction_type)
		GROUP BY mtm2.source_counterparty_id
			,mtm2.current_non_current
			,mtm2.source_deal_header_id
			,mtm2.term_start
		) mtm3 ON mtm3.source_counterparty_id = mtm1.source_counterparty_id
		AND mtm3.current_non_current = mtm1.current_non_current
		AND mtm3.source_deal_header_id = mtm1.source_deal_header_id
		AND mtm3.term_start = mtm1.term_start
	OUTER APPLY (
		SELECT fv_level_value_id
			,MAX(effective_date) effective_date
		FROM fv_report_group_deal
		WHERE source_deal_header_id = mtm1.source_deal_header_id
			AND mtm1.term_start = term_start
			AND effective_date <= mtm1.as_of_date
			AND effective_date = (
				SELECT MAX(effective_date)
				FROM fv_report_group_deal
				WHERE source_deal_header_id = mtm1.source_deal_header_id
					AND mtm1.term_start = term_start
					AND effective_date <= mtm1.as_of_date
				)
		GROUP BY fv_level_value_id
		) frgd
	LEFT JOIN static_data_value deal_level ON deal_level.value_id = frgd.fv_level_value_id
	OUTER APPLY (
		SELECT fv_reporting_group_id
			,MAX(effective_date) effective_date
		FROM price_curve_fv_mapping
		WHERE source_curve_def_id = mtm1.curve_id
			AND mtm1.term_start BETWEEN DATEADD(MM, from_no_of_months, effective_date)
				AND DATEADD(MM, to_no_of_months, effective_date)
			AND effective_date <= mtm1.as_of_date
			AND effective_date = (
				SELECT MAX(effective_date)
				FROM price_curve_fv_mapping
				WHERE source_curve_def_id = mtm1.curve_id
					AND mtm1.term_start BETWEEN DATEADD(MM, from_no_of_months, effective_date)
						AND DATEADD(MM, to_no_of_months, effective_date)
					AND effective_date <= mtm1.as_of_date
				)
		GROUP BY fv_reporting_group_id
		) pcfm1
	LEFT JOIN static_data_value curve_level ON curve_level.value_id = pcfm1.fv_reporting_group_id
	WHERE mtm1.leg = 1 AND (@_transaction_type IS NULL OR mtm1.transaction_type = @_transaction_type)
	GROUP BY mtm1.book_id
		,mtm1.stra_id
		,mtm1.sub_book_id
		,mtm1.sub_id
		,mtm1.current_non_current
		,mtm1.counterparty_name
		,mtm1.source_counterparty_id
		,mtm1.commodity
		,mtm1.deal_id
		,coalesce(deal_level.code, curve_level.code, ''Level 3'')
) rs_deal

UNION ALL

SELECT MAX(rs_cp.as_of_date) as_of_date
	,SUM(rs_cp.Liability) [Liability]
	,SUM(rs_cp.Asset) [Asset]
	,'' By Counterparty'' item
	 ,MAX(rs_cp.source_counterparty_id) source_counterparty_id
	,MAX(rs_cp.current_non_current) current_non_current
	,MAX(rs_cp.period_from) period_from
	,MAX(rs_cp.period_to) period_to
	,MAX(rs_cp.sub_id) sub_id
	,MAX(rs_cp.stra_id) stra_id
	,MAX(rs_cp.book_id) book_id
	,MAX(rs_cp.sub_book_id) sub_book_id
FROM 
(
		SELECT 
	MAX(mtm1.as_of_date) as_of_date
	, MAX(mtm1.to_as_of_date) to_as_of_date
	, MAX(mtm1.book_id) book_id
	, MAX(mtm1.stra_id) stra_id
	, MAX(mtm1.sub_book_id) sub_book_id
	, MAX(mtm1.sub_id) sub_id
	, MAX(mtm1.period_from) period_from
	, MAX(mtm1.period_to) period_to
	, mtm1.source_counterparty_id
	, @_transaction_type transaction_type
	, mtm1.current_non_current
	, MAX(mtm1.commodity) commodity
	, MAX(mtm1.physical_financial) physical_financial
	, MAX(mtm1.counterparty_name) counterparty_name
	, SUM(mtm1.fair_value) fair_value
	, MAX(mtm1.deal_id) deal_id
	, SUM(mtm1.dis_fair_value) dis_fair_value
	,CASE 
		WHEN SUM(mtm1.dis_fair_value) < 0
			THEN SUM(mtm1.dis_fair_value)
		ELSE 0
		END [Liability]
	,CASE 
		WHEN SUM(mtm1.dis_fair_value) >= 0
			THEN SUM(mtm1.dis_fair_value)
		ELSE 0
		END [Asset]
FROM {MTMDEV1} mtm1
WHERE (@_transaction_type IS NULL OR mtm1.transaction_type = @_transaction_type)
GROUP BY mtm1.source_counterparty_id
		,mtm1.current_non_current
) rs_cp

--[__batch_report__]
SELECT * FROM
(
SELECT as_of_date, Liability, Asset, item, source_counterparty_id, @_transaction_type transaction_type, current_non_current, period_from, period_to, sub_id, stra_id, book_id, sub_book_id 
FROM #mtm_asset_liab m

UNION ALL

SELECT m1.as_of_date, (m1.Liability - m2.Liability) Liability, (m1.Asset - m2.Asset) Asset, ''Net'' item, m1.source_counterparty_id, @_transaction_type transaction_type, NULL AS current_non_current, m1.period_from, m1.period_to, m1.sub_id, m1.stra_id, m1.book_id, m1.sub_book_id 
FROM #mtm_asset_liab m1
INNER JOIN #mtm_asset_liab m2 ON ISNULL(m2.item, '''') = ''By Deal'' AND ISNULL(m1.item, '''') = '' By Counterparty''
) rs' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'as_of_date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'as_of_date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'Asset'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Asset'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'Asset'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Asset' AS [name], 'Asset' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'book_id'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'book_id' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'commodity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity' AS [name], 'commodity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'counterparty_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'counterparty_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'current_non_current'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'current_non_current'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'select ''Current'' [key], ''Current'' [text]' + CHAR(10) + 'union' + CHAR(10) + 'select ''Non-Current'' [key], ''Non-Current'' [text]', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'current_non_current'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'current_non_current' AS [name], 'current_non_current' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'select ''Current'' [key], ''Current'' [text]' + CHAR(10) + 'union' + CHAR(10) + 'select ''Non-Current'' [key], ''Non-Current'' [text]' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'deal_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'deal_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_id' AS [name], 'deal_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'dis_fair_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'dis_fair_value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'dis_fair_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dis_fair_value' AS [name], 'dis_fair_value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'fair_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'fair_value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'fair_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'fair_value' AS [name], 'fair_value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'Liability'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Liability'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'Liability'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Liability' AS [name], 'Liability' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'period_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'period_from'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'period_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_from' AS [name], 'period_from' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'period_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'period_to'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'period_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_to' AS [name], 'period_to' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'physical_financial'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'physical_financial'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'physical_financial'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial' AS [name], 'physical_financial' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'source_counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'source_counterparty_id'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = '10191000', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'source_counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_counterparty_id' AS [name], 'source_counterparty_id' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, '10191000' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'stra_id'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'stra_id' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_book_id'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'sub_book_id' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_id'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'sub_id' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'to_as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'to_as_of_date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'to_as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'to_as_of_date' AS [name], 'to_as_of_date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
	            AND dsc.name =  'transaction_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'transaction_type'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 400', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND dsc.name =  'transaction_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'transaction_type' AS [name], 'transaction_type' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 400' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'as_of_date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'as_of_date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'Asset'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Asset'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'Asset'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Asset' AS [name], 'Asset' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'book_id'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'book_id' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'commodity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity' AS [name], 'commodity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'counterparty_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'counterparty_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'current_non_current'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'current_non_current'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'select ''Current'' [key], ''Current'' [text]' + CHAR(10) + 'union' + CHAR(10) + 'select ''Non-Current'' [key], ''Non-Current'' [text]', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'current_non_current'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'current_non_current' AS [name], 'current_non_current' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'select ''Current'' [key], ''Current'' [text]' + CHAR(10) + 'union' + CHAR(10) + 'select ''Non-Current'' [key], ''Non-Current'' [text]' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'deal_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'deal_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_id' AS [name], 'deal_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'dis_fair_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'dis_fair_value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'dis_fair_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'dis_fair_value' AS [name], 'dis_fair_value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'fair_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'fair_value'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'fair_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'fair_value' AS [name], 'fair_value' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'Liability'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Liability'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'Liability'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Liability' AS [name], 'Liability' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'period_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'period_from'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'period_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_from' AS [name], 'period_from' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'period_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'period_to'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'period_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_to' AS [name], 'period_to' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'physical_financial'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'physical_financial'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'physical_financial'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial' AS [name], 'physical_financial' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'source_counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'source_counterparty_id'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = '10191000', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'source_counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_counterparty_id' AS [name], 'source_counterparty_id' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, '10191000' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'stra_id'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'stra_id' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_book_id'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'sub_book_id' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_id'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'sub_id' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'to_as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'to_as_of_date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'to_as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'to_as_of_date' AS [name], 'to_as_of_date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'transaction_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'transaction_type'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 400', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'transaction_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'transaction_type' AS [name], 'transaction_type' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 400' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
	            AND dsc.name =  'group_level'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'group_level'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND dsc.name =  'group_level'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'group_level' AS [name], 'group_level' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'as_of_date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'as_of_date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'Asset'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Asset'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'Asset'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Asset' AS [name], 'Asset' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'book_id'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'book_id' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'current_non_current'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'current_non_current'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'select ''Current'' [key], ''Current'' [text]' + CHAR(10) + 'union' + CHAR(10) + 'select ''Non-Current'' [key], ''Non-Current'' [text]', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'current_non_current'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'current_non_current' AS [name], 'current_non_current' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'select ''Current'' [key], ''Current'' [text]' + CHAR(10) + 'union' + CHAR(10) + 'select ''Non-Current'' [key], ''Non-Current'' [text]' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'item'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'item'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'item'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'item' AS [name], 'item' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'Liability'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Liability'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'Liability'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Liability' AS [name], 'Liability' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'period_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'period_from'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'period_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_from' AS [name], 'period_from' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'period_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'period_to'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'period_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_to' AS [name], 'period_to' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'source_counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'source_counterparty_id'
			   , reqd_param = 1, widget_id = 7, datatype_id = 4, param_data_source = '10191000', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'source_counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_counterparty_id' AS [name], 'source_counterparty_id' AS ALIAS, 1 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, '10191000' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'stra_id'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'stra_id' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_book_id'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'sub_book_id' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_id'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'sub_id' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
	            AND dsc.name =  'transaction_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'transaction_type'
			   , reqd_param = 1, widget_id = 2, datatype_id = 5, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 400', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND dsc.name =  'transaction_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'transaction_type' AS [name], 'transaction_type' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 400' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'MTM Assets and Liabilities Deal SQL'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'MTM Assets and Liabilities Net SQL'
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
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'MTMDEV1')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'MTMDEV1' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'MTM Asset and Liability View'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'MTMAL')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'MTMAL' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Couterparty SQL'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'MTMAL1')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'MTMAL1' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Deal SQL'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

		IF NOT EXISTS(SELECT 1 FROM report_dataset rd WHERE rd.report_id = @report_id_dest AND rd.[alias] =  'DALS')
		BEGIN
			INSERT INTO report_dataset (source_id, report_id, [alias], root_dataset_id, is_free_from, relationship_sql)
			SELECT TOP 1 ds.data_source_id AS source_id, @report_id_dest AS report_id, 'DALS' [alias], rd_root.report_dataset_id AS root_dataset_id,0 AS is_free_from, 'NULL' AS relationship_sql
			FROM sys.objects o
			INNER JOIN data_source ds ON ds.[name] = 'MTM Assets and Liabilities Net SQL'
				AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
			LEFT JOIN report_dataset rd_root ON rd_root.[alias] = NULL
				AND rd_root.report_id = @report_id_dest
		END			
		

	IF NOT EXISTS(SELECT 1 FROM report_page rp 
	              WHERE rp.report_id = CASE WHEN 'e ' = 'p' 
											Then 11680 
											ELSE @report_id_dest 
						               END 
					AND rp.name =  'MTM Assets and Liabilities Report by Counterparty'  
	)
	BEGIN
		INSERT INTO report_page(report_id, [name], report_hash, width, height)
		SELECT CASE WHEN 'e ' = 'p' 
					Then 11680 
					ELSE @report_id_dest 
		       END  AS report_id, 'MTM Assets and Liabilities Report by Counterparty' [name], '05F74409_B8BF_4199_BD0F_672B3C98EA41' report_hash, 9 width,3 height
	END 
	

		INSERT INTO report_paramset(page_id, [name], paramset_hash, report_status_id)
		SELECT TOP 1 rpage.report_page_id, 'MTM Assets and Liabilities Report by Counterparty', '9E337C65_44CF_49D7_BB9E_5EBA9193B2ED', 3
		FROM sys.objects o
		INNER JOIN report_page rpage 
			on rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
		ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
	

		INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)
		SELECT TOP 1 rp.report_paramset_id AS paramset_id, rd.report_dataset_id AS root_dataset_id, '(  MTMAL.[as_of_date] = ''@as_of_date'' AND MTMAL.[book_id] IN ( @book_id ) AND MTMAL.[period_from] = ''@period_from'' AND MTMAL.[period_to] = ''@period_to'' AND MTMAL.[stra_id] IN ( @stra_id ) AND MTMAL.[sub_book_id] IN ( @sub_book_id ) AND MTMAL.[sub_id] IN ( @sub_id ) AND MTMAL.[to_as_of_date] = ''@to_as_of_date'' AND MTMAL.[source_counterparty_id] = ''@source_counterparty_id'' AND MTMAL.[current_non_current] = ''@current_non_current'' AND MTMAL.[transaction_type] = ''@transaction_type'')' AS where_part, 0
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd 
			ON rd.report_id = CASE WHEN 'e ' = 'p' 
									Then 11680 
									ELSE @report_id_dest 
			                  END
			AND rd.[alias] = 'MTMAL'
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 0 AS optional, 0 AS hidden,1 AS logical_operator, 0 AS param_order, 0 AS param_depth, 'As of Date' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'as_of_date'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,0 AS logical_operator, 1 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 9 AS param_order, 0 AS param_depth, 'Current Non Current' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'current_non_current'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '1' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 2 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'period_from'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 3 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'period_to'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 8 AS param_order, 0 AS param_depth, 'Counterparty' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'source_counterparty_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 4 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'stra_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 5 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_book_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 9 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 6 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'sub_id'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 1 AS hidden,1 AS logical_operator, 7 AS param_order, 0 AS param_depth, NULL AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'to_as_of_date'	
	

		INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator,
					initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
		SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id, rd.report_dataset_id AS dataset_id , dsc.data_source_column_id AS column_id, 1 AS operator, '' AS initial_value, '' AS initial_value2, 1 AS optional, 0 AS hidden,1 AS logical_operator, 10 AS param_order, 0 AS param_depth, 'Transaction Type' AS label
		FROM sys.objects o
		INNER JOIN report_paramset rp 
			ON rp.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rp.page_id
			AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd_root 
			ON rd_root.report_id = @report_id_dest 
			AND rd_root.[alias] = 'MTMAL'
		INNER JOIN report_dataset_paramset rdp 
			ON rdp.paramset_id = rp.report_paramset_id
			AND rdp.root_dataset_id = rd_root.report_dataset_id
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id
			AND rd.[alias] = 'MTMAL'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	
			AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id
			AND dsc.[name] = 'transaction_type'	
	

		INSERT INTO report_page_tablix(page_id,root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)
		SELECT TOP 1 rpage.report_page_id AS page_id, rd.report_dataset_id AS root_dataset_id, 'MTM Assets and Liabilities Report by Counterparty' [name], '8.613333333333333' width, '2.6666666666666665' height, '0.14666666666666667' [top], '0.3333333333333333' [left],0 AS group_mode,1 AS border_style,0 AS page_break,1 AS type_id,2 AS cross_summary,2 AS no_header,NULL export_table_name, 1 AS is_global
		FROM sys.objects o
		INNER JOIN report_page rpage 
		ON rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id 
			AND rd.[alias] = 'MTMAL' 
	

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 1 column_order,NULL aggregation, NULL functions, 'Counterparty' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, 1 default_sort_order, 1 sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,1 mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'MTMAL' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'counterparty_name' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 2 column_order,NULL aggregation, NULL functions, 'Current/Non-Current' [alias], 1 sortable, NULL rounding, NULL thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Left' text_align, '#000000' text_color, '#ffffff' background, 2 default_sort_order, 1 sort_direction, 0 custom_field, 0 render_as,-1 column_template,NULL negative_mark,NULL currency,NULL date_format,-1 cross_summary_aggregation,0 mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'MTMAL' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'current_non_current' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 3 column_order,NULL aggregation, NULL functions, 'Asset ($)' [alias], 1 sortable, 2 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Right' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,13 cross_summary_aggregation,0 mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'MTMAL' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Asset' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 4 column_order,NULL aggregation, NULL functions, 'Liability ($)' [alias], 1 sortable, 2 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Right' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,13 cross_summary_aggregation,0 mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'MTMAL' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Liability' 

		INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, placement, column_order, aggregation
					, functions, [alias], sortable, rounding, thousand_seperation, font
					, font_size, font_style, text_align, text_color, background, default_sort_order
					, default_sort_direction, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation)
		SELECT TOP 1 rpt.report_page_tablix_id tablix_id, rd.report_dataset_id dataset_id, dsc.data_source_column_id column_id,1 placement, 5 column_order,NULL aggregation, NULL functions, 'Fair Value ($)' [alias], 1 sortable, 2 rounding, 0 thousand_seperation, 'Tahoma' font, '8' font_size, '0,0,0' font_style, 'Right' text_align, '#000000' text_color, '#ffffff' background, NULL default_sort_order, NULL sort_direction, 0 custom_field, 2 render_as,-1 column_template,0 negative_mark,NULL currency,NULL date_format,13 cross_summary_aggregation,0 mark_for_total,NULL sql_aggregation
		FROM sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON rpt.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON rpage.report_page_id = rpt.page_id 
			AND rpage.[name] ='MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON r.report_id = rpage.report_id
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_dataset rd 
			ON rd.report_id = r.report_id AND rd.[alias] = 'MTMAL' 	
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'dis_fair_value' 
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Center' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Asset' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Center' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'counterparty_name' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Center' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'current_non_current' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Center' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'dis_fair_value' 
		INNER JOIN report_tablix_column rtc 
			on rtc.tablix_id = rpt.report_page_tablix_id
			AND rtc.column_id = dsc.data_source_column_id
	
 INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id)
	  SELECT TOP 1 
			rpt.report_page_tablix_id tablix_id, dsc.data_source_column_id column_id,
			'Tahoma' font,
			'8' font_size,
			'1,0,0' font_style,
			'Center' text_align,
			'#ffffff' text_color,
			'#458bc1' background,
			rtc.report_tablix_column_id			 		       
		FROM   sys.objects o
		INNER JOIN report_page_tablix rpt 
			ON  rpt.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report_page rpage 
			ON  rpage.report_page_id = rpt.page_id 
		AND rpage.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN report r 
			ON  r.report_id = rpage.report_id 
			AND r.[name] = 'MTM Assets and Liabilities Report by Counterparty'
		INNER JOIN data_source ds 
			ON ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id	AND ds.[name] = 'MTM Assets and Liabilities Couterparty SQL' 	
		INNER JOIN data_source_column dsc 
			ON dsc.source_id = ds.data_source_id AND dsc.[name] = 'Liability' 
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
	