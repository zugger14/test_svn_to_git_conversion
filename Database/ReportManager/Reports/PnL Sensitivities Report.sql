BEGIN TRY
	BEGIN TRAN      
	DECLARE @report_id_dest INT         
	IF 'e ' = 'p'
	BEGIN
	    SET @report_id_dest = NULL
	END
	
	IF EXISTS (
	       SELECT 1
	       FROM   dbo.report
	       WHERE  NAME = 'PnL Sensitivities Report'
	   )
	BEGIN
	    EXEC spa_rfx_report 'd',
	         NULL,
	         8863,
	         NULL,
	         NULL,
	         NULL,
	         NULL,
	         NULL
	END
	
	DECLARE @report_id_dest_old INT       
	SELECT @report_id_dest_old = report_id
	FROM   report r
	WHERE  r.[name] = 'PnL Sensitivities Report'
	
	IF OBJECT_ID(N'tempdb..#pages_dest', 'U') IS NOT NULL
	    DROP TABLE #pages_dest
	
	IF OBJECT_ID(N'tempdb..#paramset_dest', 'U') IS NOT NULL
	    DROP TABLE #paramset_dest
	
	IF OBJECT_ID(N'tempdb..#del_report_page', 'U') IS NOT NULL
	    DROP TABLE #del_report_page
	
	IF OBJECT_ID(N'tempdb..#del_report_paramset', 'U') IS NOT NULL
	    DROP TABLE #del_report_paramset
	
	CREATE TABLE #pages_dest
	(
		page_name VARCHAR(500)
	)        
	INSERT INTO #pages_dest
	  (
	    page_name
	  )
	SELECT item
	FROM   dbo.splitcommaseperatedvalues('') UNION
	SELECT rp.[name]
	FROM   report_page rp
	       INNER JOIN report r
	            ON  r.report_id = rp.report_id
	WHERE  r.report_id = @report_id_dest_old
	       AND '' = ''
	
	CREATE TABLE #paramset_dest
	(
		paramset_name VARCHAR(500)
	)        
	INSERT INTO #paramset_dest
	  (
	    paramset_name
	  )
	SELECT item
	FROM   dbo.splitcommaseperatedvalues('') UNION
	SELECT rp.[name]
	FROM   report_paramset rp
	       INNER JOIN report_page rpage
	            ON  rp.page_id = rpage.report_page_id
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	WHERE  r.report_id = @report_id_dest_old
	       AND '' = ''
	
	SELECT rp.report_page_id,
	       rp.[name] INTO #del_report_page
	FROM   report_page rp
	       INNER JOIN report r
	            ON  r.report_id = rp.report_id
	       INNER JOIN #pages_dest tpd
	            ON  tpd.page_name = rp.name
	WHERE  r.report_id = @report_id_dest_old
	
	SELECT rp.report_paramset_id,
	       rp.[name] INTO #del_report_paramset
	FROM   report_paramset rp
	       INNER JOIN #paramset_dest dpd
	            ON  dpd.paramset_name = rp.name
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rp.page_id /*********************************************Table and Chart Deletion START *********************************************/ /*    * The data of the tables(report_page_tablix, report_tablix_column, report_page_chart, report_chart_column) relating to the pages present in the #del_report_page    * are deleted unconditionally as well ,as there might be changes made in these table in the new report that is exported.    * */    
	DELETE rtc
	FROM   report_tablix_column rtc
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.report_page_tablix_id = rtc.tablix_id
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpt.page_id
	
	DELETE rth
	FROM   report_tablix_header rth
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.report_page_tablix_id = rth.tablix_id
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpt.page_id
	
	DELETE rpt
	FROM   report_page_tablix rpt
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpt.page_id
	
	DELETE rcc
	FROM   report_chart_column rcc
	       INNER JOIN report_page_chart rpc
	            ON  rpc.report_page_chart_id = rcc.chart_id
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpc.page_id
	
	DELETE rpc
	FROM   report_page_chart rpc
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpc.page_id
	
	DELETE rgcs
	FROM   report_gauge_column_scale rgcs
	       INNER JOIN report_gauge_column rgc
	            ON  rgc.report_gauge_column_id = rgcs.report_gauge_column_id
	       INNER JOIN report_page_gauge rpg
	            ON  rpg.report_page_gauge_id = rgc.gauge_id
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpg.page_id
	
	DELETE rgc
	FROM   report_gauge_column rgc
	       INNER JOIN report_page_gauge rpg
	            ON  rpg.report_page_gauge_id = rgc.gauge_id
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpg.page_id
	
	DELETE rpg
	FROM   report_page_gauge rpg
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpg.page_id
	
	DELETE rpi
	FROM   report_page_image rpi
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpi.page_id
	
	DELETE rpt
	FROM   report_page_textbox rpt
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpt.page_id
	
	DELETE rpl
	FROM   report_page_line rpl
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rpl.page_id /*********************************************Table and Chart Deletion END *********************************************/ /*********************************************Paramter Deletion START*********************************************/ /* The parameters are deleted unconditionally. (i.e data of the report_param. report_dataset_paramset, report_paramset) */        
	DELETE rp
	FROM   report_param rp
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.report_dataset_paramset_id = rp.dataset_paramset_id
	       INNER JOIN #del_report_paramset drp
	            ON  drp.report_paramset_id = rdp.paramset_id
	
	DELETE rdp
	FROM   report_dataset_paramset rdp
	       INNER JOIN #del_report_paramset drp
	            ON  drp.report_paramset_id = rdp.paramset_id
	
	DELETE rp
	FROM   report_paramset rp
	       INNER JOIN #del_report_paramset drp
	            ON  drp.report_paramset_id = rp.report_paramset_id /*********************************************Paramter Deletion END*********************************************/ /*********************************************Page Deletion START*********************************************/ /*Delete pages from #del_report_page, that have other paramset defined. These pages shouldnt be deleted*/    
	DELETE #del_report_page
	FROM   #del_report_page drp
	WHERE  EXISTS (
	           SELECT 1
	           FROM   report_paramset
	           WHERE  page_id = drp.report_page_id
	       )
	
	DELETE rp
	FROM   report_page rp
	       INNER JOIN #del_report_page drp
	            ON  drp.report_page_id = rp.report_page_id
	WHERE  report_id = @report_id_dest_old /*********************************************Page Deletion END*********************************************/ /*Delete report only if doesnt have any page left Else set the destination report_id to the old report_id */    
	IF EXISTS (
	       SELECT 1
	       FROM   report r
	       WHERE  r.report_id = @report_id_dest_old
	              AND NOT EXISTS (
	                      SELECT 1
	                      FROM   report_page
	                      WHERE  report_id = r.report_id
	                  )
	   )
	BEGIN
	    DELETE rdr
	    FROM   report_dataset_relationship rdr
	           INNER JOIN report_dataset rd
	                ON  rd.report_dataset_id = rdr.dataset_id
	    WHERE  rd.report_id = @report_id_dest_old
	    
	    DELETE 
	    FROM   report_dataset
	    WHERE  report_id = @report_id_dest_old
	    
	    DELETE 
	    FROM   report
	    WHERE  report_id = @report_id_dest_old
	    
	    DELETE dsc
	    FROM   data_source_column dsc
	           INNER JOIN data_source ds
	                ON  ds.data_source_id = dsc.source_id
	    WHERE  ds.[type_id] = 2
	           AND ds.report_id = @report_id_dest_old
	    
	    DELETE ds
	    FROM   data_source ds
	    WHERE  ds.[type_id] = 2
	           AND ds.report_id = @report_id_dest_old
	END
	ELSE
	BEGIN
	    SET @report_id_dest = @report_id_dest_old
	END PRINT '@report_id_dest' + ISNULL(CAST(@report_id_dest AS VARCHAR(100)), 'NULL')
	IF @report_id_dest IS NULL
	BEGIN
	    INSERT INTO report
	      (
	        [name],
	        [owner],
	        is_system,
	        report_hash,
	        [description],
	        category_id
	      )
	    SELECT TOP 1 'PnL Sensitivities Report' [name],
	           'farrms_admin' [owner],
	           0 is_system,
	           '80180B8C_57C6_42CE_8754_0C84FE6EADA2' report_hash,
	           'Commodity Shift' [description],
	           CAST(sdv_cat.value_id AS VARCHAR(10)) category_id
	    FROM   sys.objects o
	           LEFT JOIN static_data_value sdv_cat
	                ON  sdv_cat.code = 'Market Risk'
	                AND sdv_cat.type_id = 10008
	    
	    SET @report_id_dest = SCOPE_IDENTITY()
	END
	
	BEGIN TRY
		BEGIN TRAN   
		DECLARE @report_id_data_source_dest INT       
		SELECT @report_id_data_source_dest = report_id
		FROM   report r
		WHERE  r.[name] = 'PnL Sensitivities Report'
		
		IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		    DROP TABLE #data_source_column
		
		CREATE TABLE #data_source_column
		(
			column_id INT
		) 
		COMMIT TRAN
	END TRY   
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		    ROLLBACK TRAN;         
		DECLARE @error_msg VARCHAR(1000)                
		SET @error_msg = ERROR_MESSAGE() RAISERROR (@error_msg, 16, 1);
	END CATCH   
	IF NOT EXISTS(
	       SELECT 1
	       FROM   report_dataset rd
	       WHERE  rd.report_id = @report_id_dest
	              AND rd.[alias] = 'csv1'
	   )
	BEGIN
	    INSERT INTO report_dataset
	      (
	        source_id,
	        report_id,
	        [alias],
	        root_dataset_id,
	        is_free_from,
	        relationship_sql
	      )
	    SELECT TOP 1 ds.data_source_id    AS source_id,
	           @report_id_dest            AS report_id,
	           'csv1' [alias],
	           rd_root.report_dataset_id  AS root_dataset_id,
	           0                          AS is_free_from,
	           'NULL' AS                     relationship_sql
	    FROM   sys.objects o
	           INNER JOIN data_source ds
	                ON  ds.[name] = 'Commodity Shift View'
	                AND ISNULL(ds.report_id, @report_id_dest) = @report_id_dest
	           LEFT JOIN report_dataset rd_root
	                ON  rd_root.[alias] = NULL
	                AND rd_root.report_id = @report_id_dest
	END
	
	IF NOT EXISTS(
	       SELECT 1
	       FROM   report_page rp
	       WHERE  rp.report_id = CASE 
	                                  WHEN 'e ' = 'p' THEN 8863
	                                  ELSE @report_id_dest
	                             END
	              AND rp.name = 'PnL Sensitivities Report'
	   )
	BEGIN
	    INSERT INTO report_page
	      (
	        report_id,
	        [name],
	        report_hash,
	        width,
	        height
	      )
	    SELECT CASE 
	                WHEN 'e ' = 'p' THEN 8863
	                ELSE @report_id_dest
	           END  AS report_id,
	           'PnL Sensitivities Report' [name],
	           '80180B8C_57C6_42CE_8754_0C84FE6EADA2' report_hash,
	           8       width,
	           8       height
	END
	
	INSERT INTO report_paramset
	  (
	    page_id,
	    [name],
	    paramset_hash,
	    report_status_id
	  )
	SELECT TOP 1 rpage.report_page_id,
	       'PnL Sensitivities Report',
	       'B37FBAC8_0C3C_4C33_937E_3989DA566B3D',
	       3
	FROM   sys.objects o
	       INNER JOIN report_page rpage
	            ON  rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	
	INSERT INTO report_dataset_paramset
	  (
	    paramset_id,
	    root_dataset_id,
	    where_part,
	    advance_mode
	  )
	SELECT TOP 1 rp.report_paramset_id  AS paramset_id,
	       rd.report_dataset_id         AS root_dataset_id,
	       '(  csv1.[shift_one] IN ( @shift_one ) AND csv1.[shift_two] IN ( @shift_two ))' AS 
	       where_part,
	       0
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = CASE 
	                                    WHEN 'e ' = 'p' THEN 8863
	                                    ELSE @report_id_dest
	                               END
	            AND rd.[alias] = 'csv1'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       9                          AS operator,
	       '' AS                         initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       0                          AS hidden,
	       0                          AS logical_operator,
	       1                          AS param_order,
	       0                          AS param_depth,
	       NULL                       AS label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'sub_book_id'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       1                          AS operator,
	       '6/25/2015' AS                initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       0                          AS hidden,
	       1                          AS logical_operator,
	       0                          AS param_order,
	       0                          AS param_depth,
	       'As of Date' AS               label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'as_of_date'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       9                          AS operator,
	       '' AS                         initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       0                          AS hidden,
	       1                          AS logical_operator,
	       14                         AS param_order,
	       0                          AS param_depth,
	       NULL                       AS label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'book_id'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       1                          AS operator,
	       'y' AS                        initial_value,
	       '' AS                         initial_value2,
	       1                          AS optional,
	       1                          AS hidden,
	       1                          AS logical_operator,
	       13                         AS param_order,
	       0                          AS param_depth,
	       NULL                       AS label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'delta'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       1                          AS operator,
	       '' AS                         initial_value,
	       '' AS                         initial_value2,
	       1                          AS optional,
	       1                          AS hidden,
	       1                          AS logical_operator,
	       12                         AS param_order,
	       0                          AS param_depth,
	       'Portfolio ID' AS             label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'portfolio_group_id'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       9                          AS operator,
	       '' AS                         initial_value,
	       '' AS                         initial_value2,
	       1                          AS optional,
	       1                          AS hidden,
	       1                          AS logical_operator,
	       17                         AS param_order,
	       0                          AS param_depth,
	       NULL                       AS label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_one'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       9                          AS operator,
	       '' AS                         initial_value,
	       '' AS                         initial_value2,
	       1                          AS optional,
	       1                          AS hidden,
	       1                          AS logical_operator,
	       18                         AS param_order,
	       0                          AS param_depth,
	       NULL                       AS label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_two'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       9                          AS operator,
	       '' AS                         initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       0                          AS hidden,
	       1                          AS logical_operator,
	       15                         AS param_order,
	       0                          AS param_depth,
	       NULL                       AS label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'stra_id'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       9                          AS operator,
	       '' AS                         initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       0                          AS hidden,
	       1                          AS logical_operator,
	       16                         AS param_order,
	       0                          AS param_depth,
	       NULL                       AS label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'sub_id'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       1                          AS operator,
	       '12/31/2015' AS               initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       1                          AS hidden,
	       1                          AS logical_operator,
	       3                          AS param_order,
	       0                          AS param_depth,
	       'Term End' AS                 label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'term_end'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       1                          AS operator,
	       '7/1/2015' AS                 initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       1                          AS hidden,
	       1                          AS logical_operator,
	       2                          AS param_order,
	       0                          AS param_depth,
	       'Term Start' AS               label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'term_start'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       1                          AS operator,
	       '123' AS                      initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       1                          AS hidden,
	       1                          AS logical_operator,
	       4                          AS param_order,
	       0                          AS param_depth,
	       'Commodity One' AS            label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'commodity_one'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       1                          AS operator,
	       '50' AS                       initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       1                          AS hidden,
	       1                          AS logical_operator,
	       8                          AS param_order,
	       0                          AS param_depth,
	       'Commodity Two' AS            label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'commodity_two'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id           AS dataset_id,
	       dsc.data_source_column_id      AS column_id,
	       1                              AS operator,
	       '-40' AS                          initial_value,
	       '' AS                             initial_value2,
	       0                              AS optional,
	       1                              AS hidden,
	       1                              AS logical_operator,
	       5                              AS param_order,
	       0                              AS param_depth,
	       'Shift From Commodity One' AS     label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_from_commodity_one'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id           AS dataset_id,
	       dsc.data_source_column_id      AS column_id,
	       1                              AS operator,
	       '-40' AS                          initial_value,
	       '' AS                             initial_value2,
	       0                              AS optional,
	       1                              AS hidden,
	       1                              AS logical_operator,
	       9                              AS param_order,
	       0                              AS param_depth,
	       'Shift From Commodity Two' AS     label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_from_commodity_two'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       1                          AS operator,
	       '10' AS                       initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       1                          AS hidden,
	       1                          AS logical_operator,
	       7                          AS param_order,
	       0                          AS param_depth,
	       'Shift Increment Commodity One' AS label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_increment_commodity_one'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id       AS dataset_id,
	       dsc.data_source_column_id  AS column_id,
	       1                          AS operator,
	       '10' AS                       initial_value,
	       '' AS                         initial_value2,
	       0                          AS optional,
	       1                          AS hidden,
	       1                          AS logical_operator,
	       11                         AS param_order,
	       0                          AS param_depth,
	       'Shift Increment Commodity Two' AS label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_increment_commodity_two'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id         AS dataset_id,
	       dsc.data_source_column_id    AS column_id,
	       1                            AS operator,
	       '40' AS                         initial_value,
	       '' AS                           initial_value2,
	       0                            AS optional,
	       1                            AS hidden,
	       1                            AS logical_operator,
	       6                            AS param_order,
	       0                            AS param_depth,
	       'Shift To Commodity One' AS     label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_to_commodity_one'
	
	INSERT INTO report_param
	  (
	    dataset_paramset_id,
	    dataset_id,
	    column_id,
	    operator,
	    initial_value,
	    initial_value2,
	    optional,
	    hidden,
	    logical_operator,
	    param_order,
	    param_depth,
	    label
	  )
	SELECT TOP 1 rdp.report_dataset_paramset_id AS dataset_paramset_id,
	       rd.report_dataset_id         AS dataset_id,
	       dsc.data_source_column_id    AS column_id,
	       1                            AS operator,
	       '40' AS                         initial_value,
	       '' AS                           initial_value2,
	       0                            AS optional,
	       1                            AS hidden,
	       1                            AS logical_operator,
	       10                           AS param_order,
	       0                            AS param_depth,
	       'Shift To Commodity Two' AS     label
	FROM   sys.objects o
	       INNER JOIN report_paramset rp
	            ON  rp.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rp.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd_root
	            ON  rd_root.report_id = @report_id_dest
	            AND rd_root.[alias] = 'csv1'
	       INNER JOIN report_dataset_paramset rdp
	            ON  rdp.paramset_id = rp.report_paramset_id
	            AND rdp.root_dataset_id = rd_root.report_dataset_id
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_to_commodity_two'
	
	INSERT INTO report_page_tablix
	  (
	    page_id,
	    root_dataset_id,
	    [name],
	    width,
	    height,
	    [top],
	    [left],
	    group_mode,
	    border_style,
	    page_break,
	    TYPE_ID,
	    cross_summary,
	    no_header,
	    export_table_name,
	    is_global
	  )
	SELECT TOP 1 rpage.report_page_id  AS page_id,
	       rd.report_dataset_id        AS root_dataset_id,
	       'PnL Sensitivities Report' [name],
	       '7.946666666666666' width,
	       '7.973333333333334' height,
	       '0.013333333333333334' [top],
	       '0.05333333333333334' [left],
	       0                           AS group_mode,
	       1                           AS border_style,
	       0                           AS page_break,
	       2                           AS TYPE_ID,
	       1                           AS cross_summary,
	       2                           AS no_header,
	       NULL                           export_table_name,
	       1                           AS is_global
	FROM   sys.objects o
	       INNER JOIN report_page rpage
	            ON  rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	
	INSERT INTO report_tablix_column
	  (
	    tablix_id,
	    dataset_id,
	    column_id,
	    placement,
	    column_order,
	    aggregation,
	    functions,
	    [alias],
	    sortable,
	    rounding,
	    thousand_seperation,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    default_sort_order,
	    default_sort_direction,
	    custom_field,
	    render_as,
	    column_template,
	    negative_mark,
	    currency,
	    date_format,
	    cross_summary_aggregation,
	    mark_for_total,
	    sql_aggregation
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       rd.report_dataset_id          dataset_id,
	       dsc.data_source_column_id     column_id,
	       4                             placement,
	       4                             column_order,
	       NULL                          aggregation,
	       NULL                          functions,
	       'Commodity One Name' [alias],
	       1                             sortable,
	       NULL                          rounding,
	       NULL                          thousand_seperation,
	       'Tahoma' font,
	       '8' font_size,
	       '0,0,0' font_style,
	       'Center' text_align,
	       '#000000' text_color,
	       '#ffffff' background,
	       NULL                          default_sort_order,
	       NULL                          sort_direction,
	       0                             custom_field,
	       0                             render_as,
	       -1                            column_template,
	       NULL                          negative_mark,
	       NULL                          currency,
	       NULL                          date_format,
	       NULL                          cross_summary_aggregation,
	       NULL                          mark_for_total,
	       NULL                          sql_aggregation
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'commodity_one_name'
	
	INSERT INTO report_tablix_column
	  (
	    tablix_id,
	    dataset_id,
	    column_id,
	    placement,
	    column_order,
	    aggregation,
	    functions,
	    [alias],
	    sortable,
	    rounding,
	    thousand_seperation,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    default_sort_order,
	    default_sort_direction,
	    custom_field,
	    render_as,
	    column_template,
	    negative_mark,
	    currency,
	    date_format,
	    cross_summary_aggregation,
	    mark_for_total,
	    sql_aggregation
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       rd.report_dataset_id          dataset_id,
	       dsc.data_source_column_id     column_id,
	       3                             placement,
	       2                             column_order,
	       NULL                          aggregation,
	       NULL                          functions,
	       'Commodity Two Name' [alias],
	       1                             sortable,
	       NULL                          rounding,
	       NULL                          thousand_seperation,
	       'Tahoma' font,
	       '8' font_size,
	       '0,0,0' font_style,
	       'Center' text_align,
	       '#000000' text_color,
	       '#ffffff' background,
	       NULL                          default_sort_order,
	       NULL                          sort_direction,
	       0                             custom_field,
	       0                             render_as,
	       -1                            column_template,
	       NULL                          negative_mark,
	       NULL                          currency,
	       NULL                          date_format,
	       NULL                          cross_summary_aggregation,
	       NULL                          mark_for_total,
	       NULL                          sql_aggregation
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'commodity_two_name'
	
	INSERT INTO report_tablix_column
	  (
	    tablix_id,
	    dataset_id,
	    column_id,
	    placement,
	    column_order,
	    aggregation,
	    functions,
	    [alias],
	    sortable,
	    rounding,
	    thousand_seperation,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    default_sort_order,
	    default_sort_direction,
	    custom_field,
	    render_as,
	    column_template,
	    negative_mark,
	    currency,
	    date_format,
	    cross_summary_aggregation,
	    mark_for_total,
	    sql_aggregation
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       rd.report_dataset_id          dataset_id,
	       dsc.data_source_column_id     column_id,
	       4                             placement,
	       5                             column_order,
	       NULL                          aggregation,
	       NULL                          functions,
	       'Shift One' [alias],
	       1                             sortable,
	       0                             rounding,
	       NULL                          thousand_seperation,
	       'Tahoma' font,
	       '8' font_size,
	       '0,0,0' font_style,
	       'Center' text_align,
	       '#000000' text_color,
	       '#ffffff' background,
	       NULL                          default_sort_order,
	       2                             sort_direction,
	       0                             custom_field,
	       5                             render_as,
	       -1                            column_template,
	       NULL                          negative_mark,
	       NULL                          currency,
	       NULL                          date_format,
	       NULL                          cross_summary_aggregation,
	       NULL                          mark_for_total,
	       NULL                          sql_aggregation
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_one'
	
	INSERT INTO report_tablix_column
	  (
	    tablix_id,
	    dataset_id,
	    column_id,
	    placement,
	    column_order,
	    aggregation,
	    functions,
	    [alias],
	    sortable,
	    rounding,
	    thousand_seperation,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    default_sort_order,
	    default_sort_direction,
	    custom_field,
	    render_as,
	    column_template,
	    negative_mark,
	    currency,
	    date_format,
	    cross_summary_aggregation,
	    mark_for_total,
	    sql_aggregation
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       rd.report_dataset_id          dataset_id,
	       dsc.data_source_column_id     column_id,
	       3                             placement,
	       3                             column_order,
	       NULL                          aggregation,
	       NULL                          functions,
	       'Shift Two' [alias],
	       1                             sortable,
	       0                             rounding,
	       NULL                          thousand_seperation,
	       'Tahoma' font,
	       '8' font_size,
	       '0,0,0' font_style,
	       'Center' text_align,
	       '#000000' text_color,
	       '#ffffff' background,
	       NULL                          default_sort_order,
	       2                             sort_direction,
	       0                             custom_field,
	       5                             render_as,
	       -1                            column_template,
	       NULL                          negative_mark,
	       NULL                          currency,
	       NULL                          date_format,
	       NULL                          cross_summary_aggregation,
	       NULL                          mark_for_total,
	       NULL                          sql_aggregation
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_two'
	
	INSERT INTO report_tablix_column
	  (
	    tablix_id,
	    dataset_id,
	    column_id,
	    placement,
	    column_order,
	    aggregation,
	    functions,
	    [alias],
	    sortable,
	    rounding,
	    thousand_seperation,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    default_sort_order,
	    default_sort_direction,
	    custom_field,
	    render_as,
	    column_template,
	    negative_mark,
	    currency,
	    date_format,
	    cross_summary_aggregation,
	    mark_for_total,
	    sql_aggregation
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       rd.report_dataset_id          dataset_id,
	       dsc.data_source_column_id     column_id,
	       1                             placement,
	       1                             column_order,
	       13                            aggregation,
	       'csv1.Total_Value/1' functions,
	       'Total Value' [alias],
	       1                             sortable,
	       -1                            rounding,
	       0                             thousand_seperation,
	       'Tahoma' font,
	       '8' font_size,
	       '0,0,0' font_style,
	       'Right' text_align,
	       '#000000' text_color,
	       '#ffffff' background,
	       NULL                          default_sort_order,
	       NULL                          sort_direction,
	       0                             custom_field,
	       2                             render_as,
	       -1                            column_template,
	       1                             negative_mark,
	       NULL                          currency,
	       NULL                          date_format,
	       -1                            cross_summary_aggregation,
	       NULL                          mark_for_total,
	       13                            sql_aggregation
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'total_value'
	
	INSERT INTO report_tablix_column
	  (
	    tablix_id,
	    dataset_id,
	    column_id,
	    placement,
	    column_order,
	    aggregation,
	    functions,
	    [alias],
	    sortable,
	    rounding,
	    thousand_seperation,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    default_sort_order,
	    default_sort_direction,
	    custom_field,
	    render_as,
	    column_template,
	    negative_mark,
	    currency,
	    date_format,
	    cross_summary_aggregation,
	    mark_for_total,
	    sql_aggregation
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       rd.report_dataset_id          dataset_id,
	       dsc.data_source_column_id     column_id,
	       3                             placement,
	       1                             column_order,
	       NULL                          aggregation,
	       'year(csv1.term_start)' functions,
	       'Term' [alias],
	       1                             sortable,
	       NULL                          rounding,
	       NULL                          thousand_seperation,
	       'Tahoma' font,
	       '8' font_size,
	       '0,0,0' font_style,
	       'Center' text_align,
	       '#000000' text_color,
	       '#ffffff' background,
	       NULL                          default_sort_order,
	       NULL                          sort_direction,
	       0                             custom_field,
	       0                             render_as,
	       -1                            column_template,
	       NULL                          negative_mark,
	       NULL                          currency,
	       NULL                          date_format,
	       NULL                          cross_summary_aggregation,
	       NULL                          mark_for_total,
	       NULL                          sql_aggregation
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_dataset rd
	            ON  rd.report_id = r.report_id
	            AND rd.[alias] = 'csv1'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'term_start'
	
	INSERT INTO report_tablix_header
	  (
	    tablix_id,
	    column_id,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    report_tablix_column_id
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       dsc.data_source_column_id column_id,
	       'Tahoma' font,
	       '8' font_size,
	       '1,0,0' font_style,
	       'Center' text_align,
	       '#ffffff' text_color,
	       '#458bc1' background,
	       rtc.report_tablix_column_id
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_one'
	       INNER JOIN report_tablix_column rtc
	            ON  rtc.tablix_id = rpt.report_page_tablix_id
	            AND rtc.column_id = dsc.data_source_column_id
	
	INSERT INTO report_tablix_header
	  (
	    tablix_id,
	    column_id,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    report_tablix_column_id
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       dsc.data_source_column_id column_id,
	       'Tahoma' font,
	       '8' font_size,
	       '1,0,0' font_style,
	       'Center' text_align,
	       '#ffffff' text_color,
	       '#458bc1' background,
	       rtc.report_tablix_column_id
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'shift_two'
	       INNER JOIN report_tablix_column rtc
	            ON  rtc.tablix_id = rpt.report_page_tablix_id
	            AND rtc.column_id = dsc.data_source_column_id
	
	INSERT INTO report_tablix_header
	  (
	    tablix_id,
	    column_id,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    report_tablix_column_id
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       dsc.data_source_column_id column_id,
	       'Tahoma' font,
	       '8' font_size,
	       '1,0,0' font_style,
	       'Center' text_align,
	       '#ffffff' text_color,
	       '#458bc1' background,
	       rtc.report_tablix_column_id
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'term_start'
	       INNER JOIN report_tablix_column rtc
	            ON  rtc.tablix_id = rpt.report_page_tablix_id
	            AND rtc.column_id = dsc.data_source_column_id
	
	INSERT INTO report_tablix_header
	  (
	    tablix_id,
	    column_id,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    report_tablix_column_id
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       dsc.data_source_column_id column_id,
	       'Tahoma' font,
	       '8' font_size,
	       '1,0,0' font_style,
	       'Center' text_align,
	       '#ffffff' text_color,
	       '#458bc1' background,
	       rtc.report_tablix_column_id
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'total_value'
	       INNER JOIN report_tablix_column rtc
	            ON  rtc.tablix_id = rpt.report_page_tablix_id
	            AND rtc.column_id = dsc.data_source_column_id
	
	INSERT INTO report_tablix_header
	  (
	    tablix_id,
	    column_id,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    report_tablix_column_id
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       dsc.data_source_column_id column_id,
	       'Tahoma' font,
	       '8' font_size,
	       '1,0,0' font_style,
	       'Center' text_align,
	       '#ffffff' text_color,
	       '#458bc1' background,
	       rtc.report_tablix_column_id
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'commodity_one_name'
	       INNER JOIN report_tablix_column rtc
	            ON  rtc.tablix_id = rpt.report_page_tablix_id
	            AND rtc.column_id = dsc.data_source_column_id
	
	INSERT INTO report_tablix_header
	  (
	    tablix_id,
	    column_id,
	    font,
	    font_size,
	    font_style,
	    text_align,
	    text_color,
	    background,
	    report_tablix_column_id
	  )
	SELECT TOP 1 rpt.report_page_tablix_id tablix_id,
	       dsc.data_source_column_id column_id,
	       'Tahoma' font,
	       '8' font_size,
	       '1,0,0' font_style,
	       'Center' text_align,
	       '#ffffff' text_color,
	       '#458bc1' background,
	       rtc.report_tablix_column_id
	FROM   sys.objects o
	       INNER JOIN report_page_tablix rpt
	            ON  rpt.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report_page rpage
	            ON  rpage.report_page_id = rpt.page_id
	            AND rpage.[name] = 'PnL Sensitivities Report'
	       INNER JOIN report r
	            ON  r.report_id = rpage.report_id
	            AND r.[name] = 'PnL Sensitivities Report'
	       INNER JOIN data_source ds
	            ON  ISNULL(NULLIF(ds.report_id, 0), r.report_id) = r.report_id
	            AND ds.[name] = 'Commodity Shift View'
	       INNER JOIN data_source_column dsc
	            ON  dsc.source_id = ds.data_source_id
	            AND dsc.[name] = 'commodity_two_name'
	       INNER JOIN report_tablix_column rtc
	            ON  rtc.tablix_id = rpt.report_page_tablix_id
	            AND rtc.column_id = dsc.data_source_column_id
	
	COMMIT
END TRY  
BEGIN CATCH
	IF @@TRANCOUNT > 0
	    ROLLBACK TRAN; PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + 
	') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
END CATCH  