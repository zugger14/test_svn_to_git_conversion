IF OBJECT_ID('spa_calc_deal_position_breakdown') IS NOT NULL
    DROP PROC [dbo].[spa_calc_deal_position_breakdown]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 /**
	Calculate position of deals in portfolio.

	Parameters : 
	@deal_header_ids : Deal Header Ids to process
	@process_id : Process Id for process table having prefix report_position that have list of deal to process
	@call_from : Source caller
	@scheduled_job : Scheduled Job name
	@batch_process_id : process id when run through batch
	@batch_report_param : paramater to run through barch

  */

CREATE PROC [dbo].[spa_calc_deal_position_breakdown] 
	@deal_header_ids VARCHAR(MAX) = NULL,
	@process_id VARCHAR(100)=NULL,
	@call_from VARCHAR(20) = NULL,
	@scheduled_job CHAR(1) = 'n',
	@trigger_workflow NCHAR(1) = 'y',
	@batch_process_id	VARCHAR(120) = NULL, -- 's' - Settlement, 't' Term
	@batch_report_param	VARCHAR(5000) = NULL
AS
SET NOCOUNT ON

/*

declare @deal_header_ids VARCHAR(MAX) = 221099,
	@process_id VARCHAR(100)=NULL,
	@call_from VARCHAR(20) = NULL,
	@scheduled_job CHAR(1) = 'n',
	@batch_process_id	VARCHAR(120) = NULL, -- 's' - Settlement, 't' Term
	@batch_report_param	VARCHAR(5000) = NULL


SET nocount off	
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

drop table #position_formula_deal
--*/

DECLARE @sql VARCHAR(MAX) = NULL
DECLARE @msg_error VARCHAR(MAX) = NULL
DECLARE @msg_success VARCHAR(MAX) = NULL

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
BEGIN
    DECLARE @str_batch_table VARCHAR(MAX) = '', @temp_table_name VARCHAR(200) = ''
    IF (@batch_process_id IS NULL)
        SET @batch_process_id = REPLACE(NEWID(), '-', '_')
END

DECLARE @spa            VARCHAR(MAX)
DECLARE @job_name       VARCHAR(150)
DECLARE @user_login_id  VARCHAR(30)
DECLARE @effected_deals VARCHAR(150)
DECLARE @st				VARCHAR(max)
DECLARE @deal_id		INT
		
SET @user_login_id = dbo.FNADBUser()
	
IF @process_id IS NULL        
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)

	SET @st='CREATE TABLE ' + @effected_deals + '(source_deal_header_id INT, [action] VARCHAR(1)) '
	EXEC(@st)

	SET @st='INSERT INTO ' + @effected_deals + ' SELECT a.item source_deal_header_id, ''i'' [action] FROM dbo.SplitCommaSeperatedValues(''' + @deal_header_ids +''') a'
	EXEC spa_print @st
	EXEC(@st)
END
ELSE 
BEGIN 
	SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
END
		
SET @job_name = 'calc_deal_position_breakdown' + @process_id

CREATE TABLE #position_formula_deal(source_deal_detail_id INT,rowid int)

SET @st='INSERT INTO #position_formula_deal
		SELECT DISTINCT sdd.source_deal_detail_id, NULL
		FROM ' + @effected_deals + ' ed 
		INNER JOIN source_deal_detail sdd ON ed.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd.position_formula_id IS NOT NULL'
EXEC spa_print @st
EXEC(@st)

DECLARE @formula_table VARCHAR(250)
DECLARE @calc_result_table VARCHAR(250)
DECLARE @calc_result_table_breakdown VARCHAR(250)
DECLARE @as_of_date VARCHAR(10) = CAST(GETDATE() AS DATE)

IF EXISTS(SELECT TOP 1 'X' FROM #position_formula_deal)
BEGIN
	SET @formula_table = dbo.FNAProcessTableName('curve_formula_table', @user_login_id, @process_id)

	SET @st='
		CREATE TABLE ' + @formula_table + '(
			rowid int IDENTITY(1,1),
			counterparty_id INT,
			contract_id INT,
			curve_id INT,
			prod_date DATETIME,
			as_of_date DATETIME,
			volume FLOAT,
			onPeakVolume FLOAT,
			source_deal_detail_id INT,
			formula_id INT,
			invoice_Line_item_id INT,			
			invoice_line_item_seq_id INT,
			price FLOAT,			
			granularity INT,
			volume_uom_id INT,
			generator_id INT,
			[Hour] INT,
			commodity_id INT,
			meter_id INT,
			curve_source_value_id INT,
			[mins] INT,
			source_deal_header_id INT,
			term_start DATETIME,
			term_end DATETIME,
			location_id INT
		)	'
	EXEC spa_print @st	
	EXEC(@st)	

	SET @st = ' 
		INSERT INTO ' + @formula_table + '(counterparty_id, contract_id, curve_id, prod_date, as_of_date, volume, onPeakVolume, source_deal_detail_id, formula_id, 
									invoice_Line_item_id, invoice_line_item_seq_id, price, granularity, volume_uom_id, generator_id, [Hour], commodity_id, meter_id, 
									curve_source_value_id, [mins], source_deal_header_id, term_start, term_end, location_id)
		SELECT 	sdh.counterparty_id, sdh.contract_id, sdd.curve_id, cast(t.term_start as date), sdh.deal_date, sdd.deal_volume, NULL onPeakVolume, sdd.source_deal_detail_id,
			sdd.position_formula_id, NULL invoice_Line_item_id, NULL invoice_line_item_seq_id, NULL price, sdht.hourly_position_breakdown granularity, NULL volume_uom_id,
			NULL generator_id, CASE WHEN sdht.hourly_position_breakdown IN (982, 987) THEN DATEPART(hh, t.term_start) + 1 ELSE NULL END [hour],
			sdh.commodity_id, NULL meter_id, 4500 curve_source_value_id,  
			CASE WHEN sdht.hourly_position_breakdown IN (987) THEN DATEPART(MINUTE, t.term_start) ELSE 0 END [mins], sdh.source_deal_header_id, sdd.term_start, sdd.term_end
			, sdd.location_id
		FROM  #position_formula_deal tx
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = tx.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
		CROSS APPLY [dbo].[FNATermBreakdown] (CASE sdht.hourly_position_breakdown WHEN 982 THEN ''h'' WHEN 980 THEN ''m'' 
		WHEN 987 THEN ''f'' WHEN 993 THEN ''a'' ELSE ''d'' END, sdd.term_start, CASE sdht.hourly_position_breakdown WHEN 982 THEN DATEADD(hh, 23, sdd.term_end) ELSE sdd.term_end END ) t
		WHERE sdd.position_formula_id IS NOT NULL'

	EXEC spa_print @st
	EXEC(@st)

	IF OBJECT_ID('tempdb..#position_report_group_map') IS NOT NULL
		DROP TABLE #position_report_group_map

	SELECT 
		sdd.source_deal_detail_id
		, ISNULL(sdd.curve_id,-1) curve_id
		, ISNULL(sdd.location_id,-1) location_id
		, COALESCE(spcd.commodity_id,sdh.commodity_id,-1) commodity_id
		, ISNULL(sdh.counterparty_id,-1) counterparty_id
		, ISNULL(sdh.trader_id,-1) trader_id
		, ISNULL(sdh.contract_id,-1) contract_id
		, ssbm.book_deal_type_map_id subbook_id
		, COALESCE(sdd.position_uom,spcd.display_uom_id,spcd.uom_id,-1) deal_volume_uom_id
		, ISNULL(sdh.deal_status,-1) deal_status_id
		, ISNULL(sdh.source_deal_type_id,-1) deal_type 
		, ISNULL(sdh.pricing_type,-1) pricing_type
		, ISNULL(sdh.internal_portfolio_id,-1) internal_portfolio_id
		, ISNULL(sdd.physical_financial_flag,'p') physical_financial_flag
	INTO #position_report_group_map
	FROM  source_deal_header sdh  
	INNER JOIN source_deal_detail sdd  ON sdh.source_deal_header_id=sdd.source_deal_header_id 
	INNER JOIN #position_formula_deal thdi ON thdi.source_deal_detail_id=sdd.source_deal_detail_id
	INNER JOIN source_system_book_map ssbm  ON sdh.source_system_book_id1=ssbm.source_system_book_id1
		AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
		AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
	LEFT JOIN source_price_curve_def spcd  ON spcd.source_curve_def_id=sdd.curve_id

	INSERT INTO dbo.position_report_group_map (
		curve_id
		, location_id
		, commodity_id
		, counterparty_id
		, trader_id
		, contract_id
		, subbook_id
		--,deal_volume_uom_id
		, deal_status_id
		, deal_type 
		, pricing_type
		, internal_portfolio_id
		, physical_financial_flag
	)
	SELECT DISTINCT 
		ISNULL(s.curve_id,-1)
		, ISNULL(s.location_id,-1)
		, ISNULL(s.commodity_id,-1)
		, ISNULL(s.counterparty_id,-1)
		, ISNULL(s.trader_id,-1)
		, ISNULL(s.contract_id,-1)
		, ISNULL(s.subbook_id,-1)
		--,s.deal_volume_uom_id
		, ISNULL(s.deal_status_id,-1)
		, ISNULL(s.deal_type,-1)
		, ISNULL(s.pricing_type,-1)
		, ISNULL(s.internal_portfolio_id,-1)
		, ISNULL(s.physical_financial_flag,'p')
	FROM #position_report_group_map s 
	LEFT JOIN position_report_group_map d ON s.curve_id = d.curve_id
		AND s.location_id=d.location_id
		AND s.commodity_id=d.commodity_id
		AND s.counterparty_id=d.counterparty_id
		AND s.trader_id=d.trader_id
		AND s.contract_id=d.contract_id
		AND s.subbook_id=d.subbook_id
		--And s.deal_volume_uom_id=d.deal_volume_uom_id
		AND s.deal_status_id=d.deal_status_id
		AND s.deal_type =d.deal_type
		AND s.pricing_type=d.pricing_type
		AND s.internal_portfolio_id=d.internal_portfolio_id
		AND s.physical_financial_flag=d.physical_financial_flag
	WHERE d.rowid IS NULL

	UPDATE thdi SET rowid=d.rowid
	FROM #position_formula_deal thdi 
	INNER JOIN #position_report_group_map s ON s.source_deal_detail_id=thdi.source_deal_detail_id
	INNER JOIN position_report_group_map d  ON s.curve_id=d.curve_id
		AND s.location_id=d.location_id
		AND s.commodity_id=d.commodity_id
		AND s.counterparty_id=d.counterparty_id
		AND s.trader_id=d.trader_id
		AND s.contract_id=d.contract_id
		AND s.subbook_id=d.subbook_id
		--And s.deal_volume_uom_id=d.deal_volume_uom_id
		AND s.deal_status_id=d.deal_status_id
		AND s.deal_type =d.deal_type
		AND s.pricing_type=d.pricing_type
		AND s.internal_portfolio_id=d.internal_portfolio_id
		AND s.physical_financial_flag=d.physical_financial_flag

	--EXEC('select * from ' + @formula_table)
	 
	EXEC spa_calculate_formula	@as_of_date, @formula_table,@process_id,@calc_result_table OUTPUT, @calc_result_table_breakdown OUTPUT,'n','n','m',null,NULL,null,'y'
 
	--EXEC('select * from ' + @calc_result_table)

 	SET @st = ' 
		CREATE TABLE #inserted_position(source_deal_detail_id INT,rowid int,position NUMERIC(38,17));

		DELETE rhpd FROM report_hourly_position_deal_main rhpd
		INNER JOIN ' + @calc_result_table + ' crt ON rhpd.source_deal_detail_id = crt.source_deal_detail_id;

		INSERT INTO report_hourly_position_deal_main(source_deal_header_id ,term_start ,deal_date ,deal_volume_uom_id ,hr1 ,hr2 ,hr3 ,hr4 ,hr5 ,hr6 ,hr7 ,hr8 ,hr9 ,hr10 ,hr11 ,hr12 ,hr13 ,hr14 ,hr15 ,hr16 ,hr17 ,hr18 ,hr19 ,hr20 ,hr21 ,hr22 ,hr23 ,hr24 ,hr25 ,expiration_date ,period ,granularity,source_deal_detail_id,rowid)
			OUTPUT inserted.source_deal_detail_id,inserted.rowid,
			ISNULL(inserted.[hr1],0)+ISNULL(inserted.[hr2],0)+ISNULL(inserted.[hr3],0)+ISNULL(inserted.[hr4],0)+ISNULL(inserted.[hr5],0)+ISNULL(inserted.[hr6],0)+ISNULL(inserted.[hr7],0)+ISNULL(inserted.[hr8],0)+ISNULL(inserted.[hr9],0)+ISNULL(inserted.[hr10],0)+ISNULL(inserted.[hr11],0)+ISNULL(inserted.[hr12],0)+ISNULL(inserted.[hr13],0)+ISNULL(inserted.[hr14],0)+ISNULL(inserted.[hr15],0)+ISNULL(inserted.[hr16],0)+ISNULL(inserted.[hr17],0)+ISNULL(inserted.[hr18],0)+ISNULL(inserted.[hr19],0)+ISNULL(inserted.[hr20],0)+ISNULL(inserted.[hr21],0)+ISNULL(inserted.[hr22],0)+ISNULL(inserted.[hr23],0)+ISNULL(inserted.[hr24],0)
		INTO #inserted_position
		SELECT source_deal_header_id,prod_date,deal_date,deal_volume_uom_id ,
		[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],contract_expiration_date,period,granularity,source_deal_detail_id,rowid
		FROM
			(SELECT 
				crt.source_deal_header_id ,crt.prod_date,sdh.deal_date,sdd.deal_volume_uom_id ,
				crt.formula_eval_value ,crt.hour,sdd.contract_expiration_date  ,0 period,crt.granularity
				,crt.source_deal_detail_id,pfd.rowid
			FROM ' + @calc_result_table + ' crt
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = crt.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON crt.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN #position_formula_deal pfd on pfd.source_deal_detail_id=sdd.source_deal_detail_id
			) AS src
		PIVOT
		(MAX(formula_eval_value) FOR Hour IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
		) AS Pivottable;

		DELETE sddp
		FROM source_deal_detail_position sddp 
		INNER JOIN source_deal_detail sdd on sdd.source_deal_detail_id=sddp.source_deal_detail_id
		CROSS APPLY(
			SELECT SUM(position) position FROM #inserted_position WHERE source_deal_detail_id = sdd.source_deal_detail_id 
		) ip
		WHERE ip.position IS NOT NULL;

		INSERT INTO source_deal_detail_position(source_deal_detail_id,total_volume, position_report_group_map_rowid)
		SELECT sdd.source_deal_detail_id, ABS(ip.position), ip.rowid  
		FROM source_deal_detail sdd
		CROSS APPLY( SELECT SUM(position) position, max(rowid) rowid   
					FROM #inserted_position WHERE source_deal_detail_id = sdd.source_deal_detail_id) ip
		WHERE ip.position IS NOT NULL
				' 
	EXEC spa_print @st
	EXEC(@st)
END

--EXEC('DELETE ed FROM '+@effected_deals+' ed INNER JOIN #position_formula_deal pfd ON pfd.source_deal_header_id = ed.source_deal_header_id') 
--return 

EXEC [dbo].[spa_deal_position_breakdown] 'i', @deal_header_ids, @user_login_id, @process_id

SET @spa = 'spa_update_deal_total_volume NULL,'''+@process_id+''',0,1,''' + @user_login_id + ''',NULL, ' + ISNULL('' + @call_from + '', 'NULL') + ', NULL,''' + @trigger_workflow + '''' 	

EXEC spa_print @spa
EXEC(@spa)	

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
BEGIN
    EXEC spa_message_board 'u', @user_login_id, NULL, '', 'Batch process completed. Position successfully calculated.', '', '', 's', @job_name, NULL, @batch_process_id, NULL, NULL, '', 'y', '', @batch_report_param , NULL, NULL,NULL, ''
    RETURN
END

GO