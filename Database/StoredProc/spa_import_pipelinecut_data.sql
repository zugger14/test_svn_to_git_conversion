
/****** Object:  StoredProcedure [dbo].[spa_import_pipelinecut_data]******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_pipelinecut_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_pipelinecut_data]
GO
/****** Object:  StoredProcedure [dbo].[spa_import_pipelinecut_data] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_import_pipelinecut_data]
	@flag CHAR(1),	-- c: create tables, p: process
	@process_id varchar(100),  
	@user_login_id varchar(50),
	@error_code INT = 0,
	@file_name VARCHAR(255) = NULL,
	@file_type VARCHAR(8) = NULL,
	@file_sub_type VARCHAR(8) = NULL,
	@final_table VARCHAR(400) = NULL

AS 

DECLARE @sql VARCHAR(MAX)

DECLARE @stage_purchase_report        VARCHAR(500),
        @stage_transport_report       VARCHAR(500),
        @stage_pipelinecut_header     VARCHAR(500),
        @final_staging_table          VARCHAR(500)

SET @user_login_id = ISNULL(@user_login_id, dbo.FNADBUser())
SELECT @stage_purchase_report = dbo.FNAProcessTableName('purchase_report', @user_login_id, @process_id)
SELECT @stage_transport_report = dbo.FNAProcessTableName('transport_report', @user_login_id, @process_id)
SELECT @stage_pipelinecut_header = dbo.FNAProcessTableName('pipelinecut_header', @user_login_id, @process_id)

IF @final_table IS NULL -- this condition is only for testing purpose, should never happen when running package
	SELECT @final_staging_table = dbo.FNAProcessTableName('final_staging_table', @user_login_id, @process_id)
ELSE 
	SET @final_staging_table = @final_table

IF @flag = 'c'
BEGIN
	SET @sql = 'IF OBJECT_ID(''' + @stage_purchase_report + ''') IS NOT NULL
	                DROP TABLE ' + @stage_purchase_report 
	EXEC(@sql)
	
	SET @sql = 'IF OBJECT_ID(''' + @stage_transport_report + ''') IS NOT NULL
	                DROP TABLE ' + @stage_transport_report 
	EXEC(@sql)	

	SET @sql = 'IF OBJECT_ID(''' + @stage_pipelinecut_header + ''') IS NOT NULL
	                DROP TABLE ' + @stage_pipelinecut_header
	EXEC(@sql)

	SET @sql = 'IF OBJECT_ID(''' + @final_staging_table + ''') IS NOT NULL
	                DROP TABLE ' + @final_staging_table
	EXEC(@sql)
	
	SET @sql = 'CREATE TABLE ' + @stage_pipelinecut_header + '
	            (
	            	[pipelinecut_header_id] [INT] IDENTITY(1, 1) NOT NULL,
	            	process_id        VARCHAR(100),
	            	FILE_NAME         VARCHAR(255),
	            	file_type         VARCHAR(8),
	            	file_sub_type     VARCHAR(8),
	            	error_code        INT,
	            	error_msg         VARCHAR(500),
	            	create_ts         DATETIME DEFAULT GETDATE()
	            )'
	EXEC(@sql)


	SET @sql = 'CREATE TABLE ' + @stage_purchase_report + ' (
					[purchase_report_id] [INT] IDENTITY(1,1) NOT NULL,
					svc_req VARCHAR(128),
					delivery_date_from VARCHAR(128),
					delivery_date_to VARCHAR(128),
					deal_date VARCHAR(128),
					nr1  VARCHAR(128),
					contract VARCHAR(128),
					package_id VARCHAR(128),
					transportation_contract VARCHAR(128),
					nr3 VARCHAR(128),
					nr4 VARCHAR(128),
					receipt_location_id VARCHAR(128),
					receipt_location VARCHAR(128),
					nominated_receipt VARCHAR(128),
					nominated_delivery VARCHAR(128),
					scheduled_receipt VARCHAR(128),
					scheduled_delivery VARCHAR(128),
					nr5 VARCHAR(128),
					cut_type1 VARCHAR(128),
					cut_value1 VARCHAR(128),
					cut_type2 VARCHAR(128),
					cut_value2 VARCHAR(128),
					cut_type3 VARCHAR(128),
					cut_value3 VARCHAR(128),
					cut_type4 VARCHAR(128),
					cut_value4 VARCHAR(128),
					nr6 VARCHAR(128),
					nr7 VARCHAR(128),
					nr8 VARCHAR(128),
					nr9 VARCHAR(128),
					nr10 VARCHAR(128),
					nr11 VARCHAR(128),
					nr12 VARCHAR(128),
					nr13 VARCHAR(128),
					nr14 VARCHAR(128),
					nr15 VARCHAR(128),
					nr16 VARCHAR(128),
					nr17 VARCHAR(128),
					nr18 VARCHAR(128),
					nr19 VARCHAR(128),
					nr20 VARCHAR(128),
					nr21 VARCHAR(128),
					nr22 VARCHAR(128),
					nr23 VARCHAR(128),
					nr24 VARCHAR(128),
					nr25 VARCHAR(128),
					nr26 VARCHAR(128),
					nr27 VARCHAR(128),
					nr28 VARCHAR(128),
					nr29 VARCHAR(128),
					nr30 VARCHAR(128),
					nr31 VARCHAR(128),
					nr32 VARCHAR(128),
					nr33 VARCHAR(128),
					nr34 VARCHAR(128),
					nr35 VARCHAR(128),
					nr36 VARCHAR(128),
					nr37 VARCHAR(128),
					nr38 VARCHAR(128),
					nr39 VARCHAR(128),
					nr40 VARCHAR(128),
					nr41 VARCHAR(128),
					nr42 VARCHAR(128),
					nr43 VARCHAR(128),
					nr44 VARCHAR(128),
					nr45 VARCHAR(128),
					nr46 VARCHAR(128),
					nr47 VARCHAR(128),
					nr48 VARCHAR(128),
					nr49 VARCHAR(128),
					nr50 VARCHAR(128),
					nr51 VARCHAR(128),
					nr52 VARCHAR(128),
					nr53 VARCHAR(128),
					cpty_duns_no VARCHAR(128),
					nr54 VARCHAR(128),
					nr55 VARCHAR(128),
					nr56 VARCHAR(128),
					counterparty VARCHAR(128),
					[filename] [varchar](128) NULL,
					[error] [varchar](128) NULL,
					create_ts DATETIME DEFAULT GETDATE()
				)'

	EXEC(@sql)
	
	SET @sql = 'CREATE TABLE ' + @stage_transport_report + ' (
					[transport_report_id] [INT] IDENTITY(1,1) NOT NULL,
					svc_req VARCHAR(128),
					delivery_date_from VARCHAR(128),
					delivery_date_to VARCHAR(128),
					deal_date VARCHAR(128),
					nr1  VARCHAR(128),
					up_pkg_id VARCHAR(128),
					nr2 VARCHAR(128),
					nr3 VARCHAR(128),
					nr4 VARCHAR(128),
					receipt_location_id VARCHAR(128),
					delivery_location_id VARCHAR(128),
					nominated_receipt VARCHAR(128),
					nominated_delivery VARCHAR(128),
					scheduled_receipt VARCHAR(128),
					scheduled_delivery VARCHAR(128),
					nr5 VARCHAR(128),
					nr6 VARCHAR(128),
					actual_receipt VARCHAR(128),
					nr7 VARCHAR(128),
					nr8 VARCHAR(128),
					mdq_original VARCHAR(128),
					mdq_available VARCHAR(128),
					nr9 VARCHAR(128),
					cut1 VARCHAR(128),
					cut1_value_receipt VARCHAR(128),
					cut1_value_del VARCHAR(128),
					cut2 VARCHAR(128),
					cut2_value_receipt VARCHAR(128),
					cut2_value_del VARCHAR(128),
					cut_type3 VARCHAR(128),
					cut3_value_receipt VARCHAR(128),
					cut3_value_del VARCHAR(128),
					cut_type4 VARCHAR(128),
					cut4_value_receipt VARCHAR(128),
					cut4_value_del VARCHAR(128),
					nr10 VARCHAR(128),
					nr11 VARCHAR(128),
					nr12 VARCHAR(128),
					nr13 VARCHAR(128),
					nr14 VARCHAR(128),
					nr15 VARCHAR(128),
					nr16 VARCHAR(128),
					nr17 VARCHAR(128),
					nr18 VARCHAR(128),
					nr19 VARCHAR(128),
					nr20 VARCHAR(128),
					nr21 VARCHAR(128),
					nr22 VARCHAR(128),
					nr23 VARCHAR(128),
					nr24 VARCHAR(128),
					nr25 VARCHAR(128),
					nr26 VARCHAR(128),
					nr27 VARCHAR(128),
					nr28 VARCHAR(128),
					nr29 VARCHAR(128),
					nr30 VARCHAR(128),
					nr31 VARCHAR(128),
					nr32 VARCHAR(128),
					nr33 VARCHAR(128),
					nr34 VARCHAR(128),
					nr35 VARCHAR(128),
					nr36 VARCHAR(128),
					nr37 VARCHAR(128),
					nr38 VARCHAR(128),
					nr39 VARCHAR(128),
					nr40 VARCHAR(128),
					nr41 VARCHAR(128),
					nr42 VARCHAR(128),
					nr43 VARCHAR(128),
					nr44 VARCHAR(128),
					nr45 VARCHAR(128),
					nr46 VARCHAR(128),
					nr47 VARCHAR(128),
					nr48 VARCHAR(128),
					nr49 VARCHAR(128),
					nr50 VARCHAR(128),
					nr51 VARCHAR(128),
					nr52 VARCHAR(128),
					nr53 VARCHAR(128),
					nr54 VARCHAR(128),
					nr55 VARCHAR(128),
					nr56 VARCHAR(128),
					nr57 VARCHAR(128),
					nr58 VARCHAR(128),
					nr59 VARCHAR(128),
					nr60 VARCHAR(128),
					nr61 VARCHAR(128),
					nr62 VARCHAR(128),
					nr63 VARCHAR(128),
					nr64 VARCHAR(128),
					nr65 VARCHAR(128),
					nr66 VARCHAR(128),
					nr67 VARCHAR(128),
					nr68 VARCHAR(128),
					nr69 VARCHAR(128),
					nr70 VARCHAR(128),
					nr71 VARCHAR(128),
					nr72 VARCHAR(128),
					nr73 VARCHAR(128),
					nr74 VARCHAR(128),
					nr75 VARCHAR(128),
					nr76 VARCHAR(128),
					nr77 VARCHAR(128),
					delivery_location VARCHAR(128),
					receipt_location VARCHAR(128),
					nr78 VARCHAR(128),
					nr79 VARCHAR(128),
					nr80 VARCHAR(128),
					nr81 VARCHAR(128),
					nr82 VARCHAR(128),
					nr83 VARCHAR(128),
					nr84 VARCHAR(128),
					nr85 VARCHAR(128),
					nr86 VARCHAR(128),
					nr87 VARCHAR(128),
					nr88 VARCHAR(128),
					nr89 VARCHAR(128),
					nr90 VARCHAR(128),
					nr91 VARCHAR(128),
					nr92 VARCHAR(128),
					nr93 VARCHAR(128),
					nr94 VARCHAR(128),
					nr95 VARCHAR(128),
					nr96 VARCHAR(128),
					nr97 VARCHAR(128),
					nr98 VARCHAR(128),
					nr99 VARCHAR(128),
					nr100 VARCHAR(128),
					nr101 VARCHAR(128),
					nr102 VARCHAR(128),
					nr103 VARCHAR(128),
					nr104 VARCHAR(128),
					nr105 VARCHAR(128),
					nr106 VARCHAR(128),
					nr107 VARCHAR(128),
					nr108 VARCHAR(128),
					nr109 VARCHAR(128),
					nr110 VARCHAR(128),
					nr111 VARCHAR(128),
					nr112 VARCHAR(128),
					nr113 VARCHAR(128),
					nr114 VARCHAR(128),
					[filename] [varchar](128) NULL,
					[error] [varchar](128) NULL,
					create_ts DATETIME DEFAULT GETDATE()
				)'

	EXEC(@sql)
	
	SET @sql = 'CREATE TABLE ' + @final_staging_table + ' (
					[purchase_report_id] INT,
					[transport_report_id] INT,
					[receipt_location_id] VARCHAR(128),
					[receipt_location] VARCHAR(128),
					[svc_req] VARCHAR(128),
					[delivery_date_from] VARCHAR(128),
					[delivery_date_to] VARCHAR(128),
					[deal_date] VARCHAR(128),
					[nominated_receipt] VARCHAR(128),
					[nominated_delivery] VARCHAR(128),
					[scheduled_receipt] VARCHAR(128),
					[scheduled_delivery] VARCHAR(128),
					[contract] VARCHAR(128),
					[package_id] VARCHAR(128),
					[transportation_contract] VARCHAR(128),
					[cpty_duns_no] VARCHAR(128),
					[counterparty] VARCHAR(128),
					[up_pkg_id] VARCHAR(128),
					[delivery_location_id] VARCHAR(128),
					[actual_receipt] VARCHAR(128),
					[delivery_location] VARCHAR(128),
					[nr1] VARCHAR(128),
					[nr2] VARCHAR(128),
					[nr3] VARCHAR(128),
					[nr4] VARCHAR(128),
					[nr5] VARCHAR(128),
					[nr6] VARCHAR(128),
					[nr7] VARCHAR(128),
					[nr8] VARCHAR(128),
					[nr9] VARCHAR(128),
					[nr10] VARCHAR(128),
					[nr11] VARCHAR(128),
					[nr12] VARCHAR(128),
					[nr13] VARCHAR(128),
					[nr14] VARCHAR(128),
					[nr15] VARCHAR(128),
					[nr16] VARCHAR(128),
					[nr17] VARCHAR(128),
					[nr18] VARCHAR(128),
					[nr19] VARCHAR(128),
					[nr20] VARCHAR(128),
					[nr21] VARCHAR(128),
					[nr22] VARCHAR(128),
					[nr23] VARCHAR(128),
					[nr24] VARCHAR(128),
					[nr25] VARCHAR(128),
					[nr26] VARCHAR(128),
					[nr27] VARCHAR(128),
					[nr28] VARCHAR(128),
					[nr29] VARCHAR(128),
					[nr30] VARCHAR(128),
					[nr31] VARCHAR(128),
					[nr32] VARCHAR(128),
					[nr33] VARCHAR(128),
					[nr34] VARCHAR(128),
					[nr35] VARCHAR(128),
					[nr36] VARCHAR(128),
					[nr37] VARCHAR(128),
					[nr38] VARCHAR(128),
					[nr39] VARCHAR(128),
					[nr40] VARCHAR(128),
					[nr41] VARCHAR(128),
					[nr42] VARCHAR(128),
					[nr43] VARCHAR(128),
					[nr44] VARCHAR(128),
					[nr45] VARCHAR(128),
					[nr46] VARCHAR(128),
					[nr47] VARCHAR(128),
					[nr48] VARCHAR(128),
					[nr49] VARCHAR(128),
					[nr50] VARCHAR(128),
					[nr51] VARCHAR(128),
					[nr52] VARCHAR(128),
					[nr53] VARCHAR(128),
					[nr54] VARCHAR(128),
					[nr55] VARCHAR(128),
					[nr56] VARCHAR(128),
					[nr57] VARCHAR(128),
					[nr58] VARCHAR(128),
					[nr59] VARCHAR(128),
					[nr60] VARCHAR(128),
					[nr61] VARCHAR(128),
					[nr62] VARCHAR(128),
					[nr63] VARCHAR(128),
					[nr64] VARCHAR(128),
					[nr65] VARCHAR(128),
					[nr66] VARCHAR(128),
					[nr67] VARCHAR(128),
					[nr68] VARCHAR(128),
					[nr69] VARCHAR(128),
					[nr70] VARCHAR(128),
					[nr71] VARCHAR(128),
					[nr72] VARCHAR(128),
					[nr73] VARCHAR(128),
					[nr74] VARCHAR(128),
					[nr75] VARCHAR(128),
					[nr76] VARCHAR(128),
					[nr77] VARCHAR(128),
					[nr78] VARCHAR(128),
					[nr79] VARCHAR(128),
					[nr80] VARCHAR(128),
					[nr81] VARCHAR(128),
					[nr82] VARCHAR(128),
					[nr83] VARCHAR(128),
					[nr84] VARCHAR(128),
					[nr85] VARCHAR(128),
					[nr86] VARCHAR(128),
					[nr87] VARCHAR(128),
					[nr88] VARCHAR(128),
					[nr89] VARCHAR(128),
					[nr90] VARCHAR(128),
					[nr91] VARCHAR(128),
					[nr92] VARCHAR(128),
					[nr93] VARCHAR(128),
					[nr94] VARCHAR(128),
					[nr95] VARCHAR(128),
					[nr96] VARCHAR(128),
					[nr97] VARCHAR(128),
					[nr98] VARCHAR(128),
					[nr99] VARCHAR(128),
					[nr100] VARCHAR(128),
					[nr101] VARCHAR(128),
					[nr102] VARCHAR(128),
					[nr103] VARCHAR(128),
					[nr104] VARCHAR(128),
					[nr105] VARCHAR(128),
					[nr106] VARCHAR(128),
					[nr107] VARCHAR(128),
					[nr108] VARCHAR(128),
					[nr109] VARCHAR(128),
					[nr110] VARCHAR(128),
					[nr111] VARCHAR(128),
					[nr112] VARCHAR(128),
					[nr113] VARCHAR(128),
					[nr114] VARCHAR(128),
					[cut_type1] VARCHAR(128),
					[cut_type2] VARCHAR(128),
					[cut_type3] VARCHAR(128),
					[cut_type4] VARCHAR(128),
					[cut_value1] VARCHAR(128),
					[cut_value2] VARCHAR(128),
					[cut_value3] VARCHAR(128),
					[cut_value4] VARCHAR(128),
					[cut1_value_del] VARCHAR(128),
					[cut2_value_del] VARCHAR(128),
					[cut3_value_del] VARCHAR(128),
					[cut4_value_del] VARCHAR(128),		
					[mdq_original] VARCHAR(128),
					[mdq_available] VARCHAR(128),
					[filename] VARCHAR(128) NULL,
					[error] VARCHAR(128) NULL,
					[create_ts] DATETIME,
					[file_type] CHAR(1) 
	            )
			'
	/* REFERENCE: file_type in @final_staging_table - 'p' for purchase, 't' for transport */
	
	EXEC(@sql)
	
	SELECT @stage_purchase_report	[TablePurchaseReport],
	       @stage_transport_report	[TableTransportReport],
	       @final_staging_table		[FinalStagingTable]
END

IF @flag = 'l'
BEGIN
	CREATE TABLE #error_map (
		code     INT,
		msg      VARCHAR(1000) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #error_map (code, msg)
	VALUES (0, 'No Error'),
			(1, 'Invalid File Format'), -- SSIS DFT component failure
			(2, 'Working Folder Empty'),
			(3, 'Invalid File name or extension') -- filename doesn't match criteria



	SET @sql = 'INSERT INTO ' + @stage_pipelinecut_header + ' (process_id, FILE_NAME, file_type, file_sub_type, error_code, error_msg)
				SELECT ''' + @process_id + ''',
					   ''' + @file_name + ''',
					   ''' + @file_type +  ''',
					   ''' + @file_sub_type + ''',
					   ' + CAST(@error_code AS VARCHAR(2)) + ',
					   msg
				FROM   #error_map WHERE code = ' + CAST(@error_code AS VARCHAR(2)) + '
				'

	EXEC (@sql)

	SELECT @error_code error_code
END

IF @flag = 'p'
BEGIN	
	DECLARE @type CHAR(2)
	DECLARE @url_desc VARCHAR(500)  
	DECLARE @url VARCHAR(250)
	DECLARE @desc VARCHAR(8000) = '', @file_desc VARCHAR(8000) = ''
	DECLARE @caught BIT = 0
	DECLARE @elapsed_sec INT, @elapse_sec_text VARCHAR(150)
	DECLARE @all_rpt VARCHAR(700), @each_rpt VARCHAR(255)
	
	SET @all_rpt = @stage_purchase_report + ',' + @stage_transport_report

	IF @error_code = 2  -- empty folder error
	BEGIN
		SET @type = 'e'
		EXEC spa_source_system_data_import_status_detail 'i', @process_id, '', 'Data Error', 'Data Folder Empty', 'Data Folder Empty', @user_login_id, 1 , 'Import Data'
	END	
	ELSE 
	BEGIN		
		IF OBJECT_ID(N'tempdb..#purchase_report_count') IS NOT NULL DROP TABLE #purchase_report_count
		IF OBJECT_ID(N'tempdb..#transport_report_count') IS NOT NULL DROP TABLE #transport_report_count
		IF OBJECT_ID(N'tempdb..#error_code') IS NOT NULL DROP TABLE #error_code
		IF OBJECT_ID(N'tempdb..#deal_vol') IS NOT NULL DROP TABLE #deal_vol
		IF OBJECT_ID(N'tempdb..#deal_vol_new') IS NOT NULL DROP TABLE #deal_vol_new
		IF OBJECT_ID(N'tempdb..#vol_diff') IS NOT NULL DROP TABLE #vol_diff
		IF OBJECT_ID(N'tempdb..#vol_diff_child') IS NOT NULL DROP TABLE #vol_diff_child
		IF OBJECT_ID(N'tempdb..#total_phy_deals') IS NOT NULL DROP TABLE #total_phy_deals
		IF OBJECT_ID(N'tempdb..#total_phy_deals_val') IS NOT NULL DROP TABLE #total_phy_deals_val
		IF OBJECT_ID(N'tempdb..#total_phy_deals_sum') IS NOT NULL DROP TABLE #total_phy_deals_sum
		IF OBJECT_ID(N'tempdb..#total_scheduled_deals') IS NOT NULL DROP TABLE #total_scheduled_deals
		IF OBJECT_ID(N'tempdb..#transport_deal_vol') IS NOT NULL DROP TABLE #transport_deal_vol
		IF OBJECT_ID(N'tempdb..#scheduled_deal_log') IS NOT NULL DROP TABLE #scheduled_deal_log
		IF OBJECT_ID(N'tempdb..#physical_deal_log') IS NOT NULL DROP TABLE #physical_deal_log
		IF OBJECT_ID(N'tempdb..#file_info') IS NOT NULL DROP TABLE #file_info
		IF OBJECT_ID(N'tempdb..#file_info_valid') IS NOT NULL DROP TABLE #file_info_valid
		IF OBJECT_ID(N'tempdb..#deal_vol_md_mr') IS NOT NULL DROP TABLE #deal_vol_md_mr
		IF OBJECT_ID(N'tempdb..#pipe_rs') IS NOT NULL DROP TABLE #pipe_rs
		IF OBJECT_ID(N'tempdb..#total_86T_deals') IS NOT NULL DROP TABLE #total_86T_deals
		IF OBJECT_ID(N'tempdb..#updated_deals') IS NOT NULL DROP TABLE #updated_deals
		IF OBJECT_ID(N'tempdb..#contract_mismatch_deals') IS NOT NULL DROP TABLE #contract_mismatch_deals
		IF OBJECT_ID(N'tempdb..#process_table') IS NOT NULL DROP TABLE #process_table
		IF OBJECT_ID(N'tempdb..#md_deal_inserted') IS NOT NULL DROP TABLE #md_deal_inserted
		
		--CREATE TABLE #pipeline_data_import_log (id INT IDENTITY(1, 1), deal_type CHAR(1) COLLATE DATABASE_DEFAULT, svc_req VARCHAR(150) COLLATE DATABASE_DEFAULT, pkg_id VARCHAR(150) COLLATE DATABASE_DEFAULT, flow_date VARCHAR(10) COLLATE DATABASE_DEFAULT,
		--	counterparty VARCHAR(250) COLLATE DATABASE_DEFAULT, receipt_location	VARCHAR(250) COLLATE DATABASE_DEFAULT, delivery_location	VARCHAR(250) COLLATE DATABASE_DEFAULT, deal_id INT, deal_template VARCHAR(100) COLLATE DATABASE_DEFAULT, remarks VARCHAR(500) COLLATE DATABASE_DEFAULT)

		CREATE TABLE #scheduled_deal_log (id INT IDENTITY(1, 1), svc_req VARCHAR(150) COLLATE DATABASE_DEFAULT, physical_deal VARCHAR(200) COLLATE DATABASE_DEFAULT, scheduled_deal VARCHAR(200) COLLATE DATABASE_DEFAULT, leg VARCHAR(2) COLLATE DATABASE_DEFAULT,
		 pkg_id VARCHAR(150) COLLATE DATABASE_DEFAULT, counterparty VARCHAR(100) COLLATE DATABASE_DEFAULT, receipt_location VARCHAR(1000) COLLATE DATABASE_DEFAULT, delivery_location VARCHAR(100) COLLATE DATABASE_DEFAULT, old_vol VARCHAR(100) COLLATE DATABASE_DEFAULT, new_vol VARCHAR(100) COLLATE DATABASE_DEFAULT)
		
		CREATE TABLE #physical_deal_log (id INT IDENTITY(1, 1), svc_req VARCHAR(150) COLLATE DATABASE_DEFAULT, phy_deal_id INT, physical_deal VARCHAR(200) COLLATE DATABASE_DEFAULT, counterparty VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		receipt_location VARCHAR(1000) COLLATE DATABASE_DEFAULT, old_vol VARCHAR(100) COLLATE DATABASE_DEFAULT, new_vol VARCHAR(100) COLLATE DATABASE_DEFAULT)


		CREATE TABLE #error_code ([type] CHAR(1) COLLATE DATABASE_DEFAULT)

		-- @stage_purchase_report 
		-- @stage_transport_report 
		-- @stage_pipelinecut_header 
		
		CREATE TABLE #purchase_report_count(row_count INT)
		CREATE TABLE #transport_report_count(row_count INT)
		EXEC('INSERT INTO #purchase_report_count SELECT COUNT(1) FROM ' + @stage_purchase_report)
		EXEC('INSERT INTO #transport_report_count SELECT COUNT(1) FROM ' + @stage_transport_report)

		IF EXISTS (SELECT 1 FROM #purchase_report_count WHERE row_count > 0) OR EXISTS (SELECT 1 FROM #transport_report_count WHERE row_count > 0)
		BEGIN
			--BEGIN TRAN
			
			CREATE TABLE #total_phy_deals(phy_deal_id INT, svc_req VARCHAR(50) COLLATE DATABASE_DEFAULT, package_id VARCHAR(50) COLLATE DATABASE_DEFAULT, delivery_date_from VARCHAR(25) COLLATE DATABASE_DEFAULT, counterparty VARCHAR(50) COLLATE DATABASE_DEFAULT, receipt_location VARCHAR(50) COLLATE DATABASE_DEFAULT, contract VARCHAR(30) COLLATE DATABASE_DEFAULT )
			SET @sql = '
			INSERT INTO #total_phy_deals(phy_deal_id, svc_req, package_id, delivery_date_from, counterparty, receipt_location, contract )
			SELECT ISNULL(MAX(uddf.source_deal_header_id), sdh.source_deal_header_id) phy_deal_id, main_tb.svc_req, MAX(uddf.udf_value) [package_id]
				, main_tb.delivery_date_from, MAX(main_tb.counterparty) counterparty, MAX(main_tb.receipt_location) receipt_location, MAX(main_tb.contract) up_k_id
			FROM ' + @stage_purchase_report + ' main_tb
			INNER JOIN pipeline_up_down_service_k imp_tbl ON imp_tbl. serv_req_k = main_tb.svc_req AND imp_tbl.up_k = main_tb.[contract]
			INNER JOIN source_deal_header sdh ON sdh.counterparty_id = imp_tbl.counterparty_id 
				AND sdh.entire_term_start = CAST(main_tb.delivery_date_from AS DATETIME) AND sdh.entire_term_end = CAST(main_tb.delivery_date_to AS DATETIME)
				AND sdh.header_buy_sell_flag = ''b'' AND sdh.source_deal_type_id = 2

			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				AND CONVERT(VARCHAR(8),sdd.term_start, 112) = main_tb.delivery_date_from
				AND sdd.buy_sell_flag = ''b'' 
				AND sdd.location_id = imp_tbl.receipt_point 
				AND sdd.Leg = 1
			LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
			LEFT JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
				AND uddf.source_deal_header_id = sdh.source_deal_header_id
				AND uddft.field_id = -5630 AND uddf.udf_value = main_tb.package_id	
				AND NULLIF(main_tb.package_id, '''') IS NOT NULL
			GROUP BY main_tb.svc_req, sdh.source_deal_header_id,main_tb.delivery_date_from '
			EXEC(@sql)
			--select * from #total_phy_deals
			
			CREATE TABLE #total_phy_deals_val(phy_deal_id INT, svc_req VARCHAR(50) COLLATE DATABASE_DEFAULT, leg_1 FLOAT, leg_2 FLOAT, delivery_date_from VARCHAR(25) COLLATE DATABASE_DEFAULT, delivery_date_to VARCHAR(25) COLLATE DATABASE_DEFAULT, package_id VARCHAR(50) COLLATE DATABASE_DEFAULT, counterparty VARCHAR(50) COLLATE DATABASE_DEFAULT )
			SET @sql = '
			INSERT INTO #total_phy_deals_val(phy_deal_id, svc_req, leg_1, leg_2, delivery_date_from, delivery_date_to, package_id, counterparty)
			SELECT phy.phy_deal_id, phy.svc_req, CAST(p.scheduled_receipt AS float) leg_1, CAST(p.scheduled_delivery AS float) leg_2,
			 p.delivery_date_from,  p.delivery_date_to, nullif(p.package_id, '''') package_id, p.counterparty
			FROM #total_phy_deals phy
			INNER JOIN ' + @stage_purchase_report + ' p ON p.svc_req = phy.svc_req AND ISNULL(nullif(p.package_id, ''''), -1) = ISNULL(phy.package_id, -1)
			AND p.counterparty = phy.counterparty AND p.delivery_date_from = phy.delivery_date_from '
			EXEC(@sql)

			--SELECT * FROM #total_phy_deals_val
			
			SELECT phy.phy_deal_id, phy.svc_req, SUM(phy.leg_1) leg_1_sum, SUM(phy.leg_2) leg_2_sum, phy.delivery_date_from,  phy.delivery_date_to
			INTO #total_phy_deals_sum
			FROM #total_phy_deals_val phy
			GROUP BY  phy.svc_req,phy.delivery_date_from,  phy.delivery_date_to,phy.phy_deal_id

			--select * from #total_phy_deals_sum
			

			DECLARE @sdv_from_deal INT 
			SELECT @sdv_from_deal = value_id
			FROM static_data_value
			WHERE [TYPE_ID] = 5500 AND code = 'From Deal'

			CREATE TABLE #total_scheduled_deals(contract VARCHAR(50) COLLATE DATABASE_DEFAULT, phy_deal_id INT, scheduled_deal_id INT, schedule_id INT, path_id INT, path_detail_id INT)

			SET @sql = '
			INSERT INTO #total_scheduled_deals(contract, phy_deal_id, scheduled_deal_id, schedule_id, path_id, path_detail_id)
			SELECT svc_req, phy_deal_id, scheduled_deal_id, [Scheduled ID] schedule_id, [Delivery Path] path_id, [Path Detail ID] path_detail_id
			FROM (
				SELECT t.svc_req, tpd.phy_deal_id, uddf_sch.source_deal_header_id [scheduled_deal_id], uddft_sch.Field_label, uddf_sch.udf_value udf_value --, tmp_tbl.delivery_poi , mi2.recorderid
				  FROM user_defined_deal_fields uddf
				INNER JOIN 	[user_defined_deal_fields_template] uddft ON uddft.udf_template_id = uddf.udf_template_id
					AND uddft.field_id = ' + CAST(@sdv_from_deal AS VARCHAR(20)) + '
				INNER JOIN #total_phy_deals tpd ON CAST(tpd.phy_deal_id AS VARCHAR) = uddf.udf_value
				INNER JOIN pipeline_up_down_service_k tmp_tbl ON tmp_tbl.serv_req_k = tpd.svc_req
				INNER JOIN ' + @stage_transport_report + ' t ON t.up_pkg_id = tmp_tbl.serv_req_k
					AND t.receipt_location_id = tmp_tbl.receipt_poi
					AND t.delivery_location_id =  tmp_tbl.delivery_poi
				INNER JOIN user_defined_deal_fields uddf_sch ON uddf_sch.source_deal_header_id = uddf.source_deal_header_id
				INNER JOIN source_deal_detail sdd_1 ON sdd_1.source_deal_header_id = uddf_sch.source_deal_header_id
					AND sdd_1.Leg = 1 AND tmp_tbl.receipt_point = sdd_1.location_id
					AND CONVERT(VARCHAR(8),sdd_1.term_start, 112) = t.delivery_date_from
					AND CONVERT(VARCHAR(8),sdd_1.term_end, 112) = t.delivery_date_to
		
				INNER JOIN source_minor_location_meter smlm1 on 	smlm1.source_minor_location_id = sdd_1.location_id
				INNER JOIN meter_id mi1 ON mi1.meter_id = smlm1.meter_id AND t.receipt_location_id = mi1.recorderid
				INNER JOIN source_deal_detail sdd_2 ON sdd_2.source_deal_header_id = uddf_sch.source_deal_header_id
					AND sdd_2.Leg = 2 AND tmp_tbl.delivery_point = sdd_2.location_id
				INNER JOIN source_minor_location_meter smlm2 on 	smlm2.source_minor_location_id = sdd_2.location_id
				INNER JOIN meter_id mi2 ON mi2.meter_id = smlm2.meter_id AND t.delivery_location_id = mi2.recorderid
				INNER JOIN user_defined_deal_fields_template uddft_sch ON uddft_sch.udf_template_id = uddf_sch.udf_template_id	
			) s1
			PIVOT(MAX(udf_value) FOR Field_label IN ([Scheduled ID],[Delivery Path], [Path Detail ID])) AS a '
			EXEC(@sql)	

			--SELECT * FROM #total_scheduled_deals
			
			--- update UDF values for scheduled deal as from physical deal

			--updating schedule deal's udf value  pkg ID(-5630) as defined in its physical deal.
			UPDATE uddf_scv	SET udf_value = tpd.package_id
			--SELECT tsd.phy_deal_id, tsd.scheduled_deal_id, uddft_pkg.Field_label, uddf_scv.udf_value, tpd.package_id
			FROM user_defined_deal_fields uddf_scv 
			INNER JOIN #total_scheduled_deals tsd ON tsd.scheduled_deal_id = uddf_scv.source_deal_header_id
			INNER JOIN #total_phy_deals tpd ON tpd.phy_deal_id = tsd.phy_deal_id
			INNER JOIN user_defined_deal_fields_template uddft_pkg ON uddft_pkg.udf_template_id = uddf_scv.udf_template_id	
				AND uddft_pkg.field_id = -5630

			--updating schedule deal's udf value scv req k(-5631) as defined in its physical deal.
			UPDATE uddf_scv	SET udf_value = tpd.svc_req	
			--SELECT tsd.phy_deal_id, tsd.scheduled_deal_id, uddft_pkg.Field_label, uddf_scv.udf_value, tpd.svc_req
			FROM user_defined_deal_fields uddf_scv 
			INNER JOIN #total_scheduled_deals tsd ON tsd.scheduled_deal_id = uddf_scv.source_deal_header_id
			INNER JOIN #total_phy_deals tpd ON tpd.phy_deal_id = tsd.phy_deal_id
			INNER JOIN user_defined_deal_fields_template uddft_pkg ON uddft_pkg.udf_template_id = uddf_scv.udf_template_id	
				 AND uddft_pkg.field_id = -5631 


			-- Update K ID in scheduled deal ( udf detail level)
			UPDATE udddf_scv SET udf_value = CASE sdd.leg WHEN 1 THEN tpd.contract WHEN 2 THEN tpd.svc_req ELSE NULL END
			--SELECT tsd.phy_deal_id, tsd.scheduled_deal_id, uddft_pkg.Field_label, tpd.svc_req, tpd.contract,  uddft_pkg.leg,
			-- udddf_scv.udf_value old_udf_value, CASE sdd.leg WHEN 1 THEN tpd.contract WHEN 2 THEN tpd.svc_req ELSE NULL END udf_value
			FROM #total_scheduled_deals tsd
			INNER JOIN #total_phy_deals tpd ON tpd.phy_deal_id = tsd.phy_deal_id 
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tsd.scheduled_deal_id
			INNER JOIN user_defined_deal_fields_template uddft_pkg ON uddft_pkg.template_id = sdh.template_id AND uddft_pkg.field_id = -5635 --AND uddft_pkg.leg = sdd.leg
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND sdd.leg = uddft_pkg.leg
			INNER JOIN user_defined_deal_detail_fields udddf_scv ON udddf_scv.source_deal_detail_id = sdd.source_deal_detail_id AND udddf_scv.udf_template_id = uddft_pkg.udf_template_id 

			-- update Up K Id and Down K Id in physical deal ( udf header level)
			UPDATE uddf SET uddf.udf_value = CASE uddft.Field_id WHEN -5634 THEN p.contract WHEN -5631 THEN p.svc_req ELSE NULL END
			--select uddft.Field_label ,uddft.Field_id, p.phy_deal_id, p.contract, p.svc_req, uddf.udf_value, CASE uddft.Field_id WHEN -5634 THEN p.contract WHEN -5631 THEN p.svc_req END new_udf_value
			FROM user_defined_deal_fields uddf 
			INNER JOIN #total_phy_deals p ON p.phy_deal_id = uddf.source_deal_header_id 
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = uddf.source_deal_header_id  
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id AND uddft.field_name IN (-5634,-5631) AND uddft.udf_template_id = uddf.udf_template_id 


			--SELECT * from adiha_process.dbo.purchase_report_farrms_admin_p123
			--SELECT * FROM #total_phy_deals
			--SELECT * FROM #total_scheduled_deals

			SELECT id = IDENTITY(INT, 1, 1), tsd.phy_deal_id, sdd.source_deal_header_id,  sdd.leg, deal_volume, phy.svc_req, phy.package_id, phy.counterparty, phy.delivery_date_from, cg.contract_name
			INTO #deal_vol
			FROM #total_scheduled_deals tsd
			INNER JOIN #total_phy_deals phy ON phy.phy_deal_id = tsd.phy_deal_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tsd.scheduled_deal_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id

			--SELECT * FROM  #deal_vol

			-- extract mismatch contract for scheduled deals
			SELECT id = IDENTITY(INT, 1, 1), MAX(dd.svc_req) svc_req, t.scheduled_deal_id, MAX(t.[contract]) transport_contract, MAX(dd.contract_name) deal_contract 
			INTO #contract_mismatch_deals
			FROM #total_scheduled_deals t
			LEFT JOIN #deal_vol d ON t.scheduled_deal_id = d.source_deal_header_id AND d.contract_name = t.contract
			LEFT JOIN #deal_vol dd ON dd.source_deal_header_id = t.scheduled_deal_id   
			WHERE d.id IS NULL
			GROUP BY t.scheduled_deal_id
			
			--SELECT * FROM #contract_mismatch_deals
		
			SELECT unpvt.phy_deal_id, unpvt.svc_req, dbo.FNAGetSplitPart(unpvt.leg,'_',2) leg, unpvt.diff sum_diff 
			INTO #vol_diff 
			FROM (
			SELECT (phy.leg_1_sum - l.leg1) leg_1 , (phy.leg_2_sum - l.leg2) leg_2, phy.svc_req, phy.phy_deal_id 
			FROM (
				SELECT phy_deal_id, svc_req, (SUM([1])) leg1, (SUM([2])) leg2 
				FROM #deal_vol AS s
				PIVOT (	SUM(deal_volume) FOR leg IN ([1],[2]) ) AS p  
				GROUP BY p.phy_deal_id, p.svc_req
			) l
			INNER JOIN #total_phy_deals_sum phy ON phy.svc_req = l.svc_req AND phy.phy_deal_id = l.phy_deal_id
			) p
			UNPIVOT(diff FOR leg IN (leg_1, leg_2) 
			) AS unpvt 
			--SELECT * FROM #vol_diff

	
			---- update scheduled deals ( using purchase file)
			UPDATE sdd SET sdd.deal_volume = CASE WHEN SUBSTRING(PARSENAME(sdd.deal_volume + (sdd.deal_volume/p.leg_sum * vd.sum_diff), 1), 1, 2) >= 50 
			THEN CEILING(sdd.deal_volume + (sdd.deal_volume/p.leg_sum * vd.sum_diff))
			ELSE FLOOR(sdd.deal_volume + (sdd.deal_volume/p.leg_sum * vd.sum_diff)) END

			--SELECT sdd.source_deal_header_id, sdd.leg, sdd.deal_volume deal_volume_old, sdd.deal_volume + (sdd.deal_volume/p.leg_sum * vd.sum_diff) deal_volume_new
			FROM #deal_vol d
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id AND sdd.leg = d.leg
			INNER JOIN #vol_diff vd ON vd.phy_deal_id = d.phy_deal_id AND vd.svc_req = d.svc_req AND vd.leg = d.Leg
			INNER JOIN 
			(
				SELECT svc_req, phy_deal_id, leg, sum(deal_volume) leg_sum FROM #deal_vol GROUP BY leg, svc_req, phy_deal_id 
			) p ON p.phy_deal_id = d.phy_deal_id AND p.leg = d.leg AND p.svc_req = d.svc_req
			LEFT JOIN #contract_mismatch_deals c ON c.svc_req = d.svc_req -- ignore all deals with mismatch contract svc_req
			WHERE vd.sum_diff <> 0 AND c.id IS NULL
			
			CREATE TABLE #transport_deal_vol(up_pkg_id VARCHAR(50) COLLATE DATABASE_DEFAULT, scheduled_receipt_sum FLOAT, scheduled_delivery_sum FLOAT, delivery_date_from VARCHAR(25) COLLATE DATABASE_DEFAULT, delivery_date_to VARCHAR(25) COLLATE DATABASE_DEFAULT, receipt_location VARCHAR(100) COLLATE DATABASE_DEFAULT, delivery_location VARCHAR(100) COLLATE DATABASE_DEFAULT)
			SET @sql = '
			INSERT INTO #transport_deal_vol(up_pkg_id, scheduled_receipt_sum, scheduled_delivery_sum, delivery_date_from, delivery_date_to, receipt_location, delivery_location)
			SELECT t.up_pkg_id, SUM(cast(t.scheduled_receipt AS FLOAT)) scheduled_receipt_sum, sum(cast(t.scheduled_delivery AS FLOAT)) scheduled_delivery_sum,
			t.delivery_date_from, t.delivery_date_to, MAX(receipt_location_id), MAX(delivery_location_id)
			FROM ' + @stage_transport_report + ' t
			INNER join(
			 SELECT svc_req, MAX(delivery_date_from) delivery_date_from, MAX(delivery_date_to) delivery_date_to  FROM #total_phy_deals_sum GROUP BY svc_req
			) phy
			 ON phy.svc_req = t.up_pkg_id 
			AND cast(phy.delivery_date_from AS DATETIME) = cast(t.delivery_date_from AS DATETIME) 
			AND cast(phy.delivery_date_to AS DATETIME) = cast(t.delivery_date_to AS DATETIME)
			GROUP BY t.up_pkg_id,t.delivery_date_from, t.delivery_date_to '
			EXEC(@sql)

			--SELECT * FROM #transport_deal_vol
			
			
			
			
			------------- Extract MD , MR deal with srv req, PIPE
			
			CREATE TABLE #pipe_rs(up_pkg_id VARCHAR(50) COLLATE DATABASE_DEFAULT, delivery_date_from VARCHAR(20) COLLATE DATABASE_DEFAULT, delivery_date_to VARCHAR(20) COLLATE DATABASE_DEFAULT, generic_mapping_value_id VARCHAR(50) COLLATE DATABASE_DEFAULT, transport_contract VARCHAR(50) COLLATE DATABASE_DEFAULT,
			scheduled_receipt FLOAT, scheduled_delivery FLOAT, receipt_location INT, delivery_location INT, term_pricing_index_leg1 INT, term_pricing_index_leg2 INT)
			
			EXEC('
			INSERT INTO #pipe_rs(up_pkg_id, delivery_date_from, delivery_date_to, generic_mapping_value_id, transport_contract, scheduled_receipt, scheduled_delivery, receipt_location, delivery_location, term_pricing_index_leg1, term_pricing_index_leg2)
			SELECT up_pkg_id, delivery_date_from, delivery_date_to, generic_mapping_value_id, MAX(svc_req), MAX(scheduled_receipt), MAX(scheduled_delivery), MAX(receipt_location), MAX(delivery_location), MAX(term_pricing_index_leg1), MAX(term_pricing_index_leg2)
			FROM (
				SELECT CASE 
						WHEN rs_t.up_pkg_id = ''pipe'' AND rs_t.delivery_location_id = 216821 THEN 5	--MR
						WHEN rs_t.up_pkg_id = ''pipe'' AND rs_t.delivery_location_id <> 216821 THEN 4	--MD
					END generic_mapping_value_id
					, rs_t.up_pkg_id
					, rs_t.delivery_date_from
					, rs_t.delivery_date_to
					, rs_t.delivery_location_id
					, MAX(rs_t.svc_req) svc_req
					, MAX(CAST(scheduled_receipt AS FLOAT)) scheduled_receipt 
					, MAX(CAST(scheduled_delivery AS FLOAT)) scheduled_delivery
					, MAX(smlm_r.source_minor_location_id) receipt_location
					, MAX(smlm_d.source_minor_location_id) delivery_location
					, MAX(sml_r.term_pricing_index) term_pricing_index_leg1
					, MAX(sml_d.term_pricing_index) term_pricing_index_leg2
				FROM ' + @stage_transport_report + ' rs_t
				LEFT JOIN meter_id mi_r_loc ON mi_r_loc.recorderid = rs_t.receipt_location_id
				LEFT JOIN source_minor_location_meter smlm_r ON smlm_r.meter_id = mi_r_loc.meter_id
				LEFT JOIN source_minor_location sml_r ON sml_r.source_minor_location_id = smlm_r.source_minor_location_id
				LEFT JOIN meter_id mi_d_loc ON mi_d_loc.recorderid = rs_t.delivery_location_id
				LEFT JOIN source_minor_location_meter smlm_d ON smlm_d.meter_id = mi_d_loc.meter_id 
				LEFT JOIN source_minor_location sml_d ON sml_d.source_minor_location_id = smlm_d.source_minor_location_id
				WHERE rs_t.up_pkg_id = ''pipe''
				GROUP BY  rs_t.up_pkg_id, rs_t.delivery_date_from, rs_t.delivery_date_to,rs_t.delivery_location_id
			) t
			GROUP BY generic_mapping_value_id,up_pkg_id,delivery_date_from,delivery_date_to
			HAVING COUNT(t.up_pkg_id) = 1')
			
			--SELECT * FROM #pipe_rs
			
			SELECT id = IDENTITY(INT, 1, 1), rs_t.up_pkg_id, rs_t.delivery_date_from, rs_t.delivery_date_to, MAX(uddf.udf_value) [from_deal_id], sdh.source_deal_header_id
					, MAX(sdht.template_id) template_id, MAX(sdht.template_name) template_name, MAX(rs_t.generic_mapping_value_id) generic_mapping_value_id, MAX(rs_t.transport_contract) transport_contract
			INTO #total_86T_deals
			FROM #pipe_rs rs_t
			INNER JOIN generic_mapping_header gmh ON 1 = 1 AND gmh.mapping_name = 'Imbalance Report'
			INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id 
				AND isnumeric(gmv.clm1_value)= 1 AND gmv.clm1_value = rs_t.generic_mapping_value_id 
			INNER JOIN source_deal_header_template sdht ON cast(sdht.template_id AS VARCHAR(100)) = gmv.clm3_value
			INNER JOIN source_deal_header sdh ON sdh.template_id = sdht.template_id	
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND CONVERT(VARCHAR(8), sdd.term_start , 112) = rs_t.delivery_date_from

			--INNER JOIN user_defined_deal_fields_template uddft_payback ON uddft_payback.template_id = sdh.template_id 
			--	AND uddft_payback.field_id = -5613
			--INNER JOIN user_defined_deal_fields uddf_payback ON uddf_payback.udf_template_id = uddft_payback.udf_template_id 	
			--	AND uddf_payback.source_deal_header_id = sdh.source_deal_header_id
			--	AND CONVERT(VARCHAR(8), CAST(uddf_payback.udf_value AS datetime) , 112) = rs_t.delivery_date_from

			LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
			LEFT JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
				AND uddft.field_id = @sdv_from_deal
				AND uddf.source_deal_header_id = sdh.source_deal_header_id
			WHERE rs_t.up_pkg_id = 'pipe' --AND rs_t.total_rs = 1
			GROUP BY rs_t.up_pkg_id 
				, rs_t.delivery_date_from  
				, rs_t.delivery_date_to 
				, sdh.source_deal_header_id
	
			--SELECT * FROM #total_86T_deals

			--------- logic to create MD Deals if not found ------------
			--DECLARE @require_md_deal_insert BIT = 0 
			DECLARE @md_template_id INT, @contract_deal INT
			
			SELECT TOP 1 @md_template_id =  gmv.clm3_value from generic_mapping_values gmv 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
			WHERE gmh.mapping_name = 'Imbalance Report' AND gmv.clm1_value = '4'
			
			--select @md_template_id template_id
			
			--SELECT TOP 1 @require_md_deal_insert = 1 FROM #pipe_rs p LEFT JOIN #total_86T_deals t  ON t.generic_mapping_value_id = p.generic_mapping_value_id 
			--WHERE p.generic_mapping_value_id = 4 AND t.id IS NULL

			--SELECT @require_md_deal_insert
		
			--IF (@require_md_deal_insert = 1)
			--BEGIN
				CREATE TABLE #md_deal_inserted(deals VARCHAR(1000) COLLATE DATABASE_DEFAULT)
				DECLARE @deal_sn INT = 1, @sub_process_id VARCHAR(100), @inserted_deal_tbl VARCHAR(255), @deal_table VARCHAR(255), @term_start DATETIME,	@term_end DATETIME,	@deal_date DATETIME, @sub_book INT, @contract_id INT,
				@leg1_vol FLOAT, @leg2_vol FLOAT, @receipt_location_id INT, @delivery_location_id INT, @term_pricing_index_leg1 INT, @term_pricing_index_leg2 INT

				--SET @sub_book = 78  -- dummy book -- 67
				--SET @term_start = '2014-05-01'
				--SET @term_end = '2014-05-31'
				--SET @deal_date = '2014-04-30'

				IF CURSOR_STATUS('local','pipeline_cursor') > = -1
				BEGIN
					DEALLOCATE pipeline_cursor
				END
				-- MD deal insertion for each MD deal in file
				DECLARE c CURSOR FOR 
					SELECT CONVERT(DATETIME, p.delivery_date_from, 120) deliver_date_from, CONVERT(DATETIME, p.delivery_date_to, 120) deliver_date_to, cg.contract_id, 
					p.scheduled_receipt, p.scheduled_delivery, p.receipt_location, p.delivery_location, p.term_pricing_index_leg1, p.term_pricing_index_leg2
					FROM #pipe_rs p LEFT JOIN #total_86T_deals t  ON t.generic_mapping_value_id = p.generic_mapping_value_id 
					LEFT JOIN contract_group cg ON cg.contract_name = p.transport_contract
					WHERE p.generic_mapping_value_id = 4 AND t.id IS NULL AND p.up_pkg_id IS NOT NULL
				OPEN c 
				FETCH NEXT FROM c INTO @term_start, @term_end, @contract_id, @leg1_vol, @leg2_vol, @receipt_location_id, @delivery_location_id, @term_pricing_index_leg1, @term_pricing_index_leg2

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @contract_deal = NULL
					SET @sub_book = NULL

					SELECT DISTINCT TOP 1 @contract_deal = sdh.source_deal_header_id FROM #pipe_rs p 
					INNER JOIN contract_group cg ON cg.contract_name = p.transport_contract
					INNER JOIN (
						SELECT clm5_value template_id, gmv.clm9_value contract_id from generic_mapping_values gmv 
						INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id 
						WHERE gmh.mapping_name = 'Imbalance Deal'
					) g ON g.contract_id = cg.contract_id
					INNER JOIN source_deal_header sdh ON sdh.contract_id = cg.contract_id AND sdh.template_id = g.template_id 
					--AND p.delivery_date_from BETWEEN sdh.entire_term_start AND sdh.entire_term_end
					WHERE cg.contract_id = @contract_id AND p.generic_mapping_value_id = 4		
			
					select DISTINCT TOP 1 @sub_book = ssbm.book_deal_type_map_id FROM source_deal_header sdh
					INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					 AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					 AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					 AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					WHERE sdh.source_deal_header_id = @contract_deal					

					CREATE TABLE #process_table (process_table_name VARCHAR(200) COLLATE DATABASE_DEFAULT)
					SET @deal_date = @term_start
					INSERT INTO #process_table(process_table_name)
						EXEC spa_blotter_deal 't', @md_template_id, 1, @term_start, @term_end, @deal_date

					SELECT @deal_table = process_table_name FROM #process_table
					
					-- Adding columns which may be hidden in template
					SET @sql = '
					IF NOT EXISTS(SELECT * FROM sys.columns WHERE [name] = N''d_curve_id'' AND [object_id] = OBJECT_ID(N''' + STUFF(@deal_table, 1, 18, '') + '''))
					BEGIN
						ALTER TABLE ' +  @deal_table + ' ADD d_curve_id INT NULL
					END

					IF NOT EXISTS(SELECT * FROM sys.columns WHERE [name] = N''d_settlement_date'' AND [object_id] = OBJECT_ID(N''' + STUFF(@deal_table, 1, 18, '') + '''))
					BEGIN
						ALTER TABLE ' +  @deal_table + ' ADD d_settlement_date DATETIME NULL
					END

					'
					EXEC(@sql)

					EXEC('ALTER TABLE ' +  @deal_table + ' ALTER COLUMN leg VARCHAR(10)')

					EXEC('UPDATE ' + @deal_table + ' SET row_id = leg, leg = ''1__'' + leg ')
					
					-- Update Deal Header
					SET @sql = 'UPDATE ' + @deal_table + ' SET 
						   h_sub_book = ' + CAST(@sub_book AS VARCHAR(20)) +		
						', h_deal_date = ''' + CONVERT(VARCHAR(10), @term_start, 120)  +
						''', h_contract_id = ''' + CONVERT(VARCHAR(10), @contract_id, 120) +
						''' '

					exec spa_print @sql
					EXEC(@sql)

					-- leg 1
					SET @sql = 'UPDATE ' + @deal_table + ' SET 
						     d_term_start = ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' ' + 
							 ', d_term_end = ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''' ' + 
						ISNULL(', d_settlement_date = ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''' ', '') + 
						ISNULL(', d_deal_volume = ' + CAST(@leg1_vol AS VARCHAR(50)), '') +
						ISNULL(', d_location_id = ' + CAST(@receipt_location_id AS VARCHAR(50)), '') +
						ISNULL(', d_curve_id = ' + CAST(@term_pricing_index_leg1 AS VARCHAR(50)), '') +						
			            ' WHERE leg = ''1__1'' '
					exec spa_print @sql
					EXEC(@sql)
					
					-- leg 2
					SET @sql = 'UPDATE ' + @deal_table + ' SET 
						     d_term_start = ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' ' + 
							 ', d_term_end = ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''' ' + 
						ISNULL(', d_settlement_date = ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''' ', '') + 
						ISNULL(', d_deal_volume = ' + CAST(@leg2_vol AS VARCHAR(50)), '') +
						ISNULL(', d_location_id = ' + CAST(@delivery_location_id AS VARCHAR(50)), '') +
						ISNULL(', d_curve_id = ' + CAST(@term_pricing_index_leg2 AS VARCHAR(50)), '') +
			           ' WHERE leg = ''1__2'' '
					exec spa_print @sql
					EXEC(@sql)

					SET @sub_process_id = @process_id + '_' + CAST(@deal_sn AS VARCHAR(3))
					EXEC spa_insert_template_deal @md_template_id, @sub_book, @deal_table, @sub_process_id
					SET @inserted_deal_tbl = dbo.FNAProcessTableName('deal_inserted', @user_login_id, @sub_process_id)

					EXEC('INSERT INTO #md_deal_inserted(deals) SELECT deals FROM ' + @inserted_deal_tbl)
					exec spa_print 'Inserted Deal', @deal_sn, ' table:', @inserted_deal_tbl
					--EXEC('select * from ' + @deal_table)

					DROP TABLE #process_table
					SET @deal_sn = @deal_sn + 1
					--COMMIT TRAN
					FETCH NEXT FROM c INTO @term_start, @term_end, @contract_id, @leg1_vol, @leg2_vol, @receipt_location_id, @delivery_location_id, @term_pricing_index_leg1, @term_pricing_index_leg2 
				END

				CLOSE c
				DEALLOCATE c
			 
			--select * from #md_deal_inserted 
			
			-- extract mismatch contract from md/mr deals
			INSERT INTO #contract_mismatch_deals(svc_req, scheduled_deal_id, transport_contract, deal_contract)
			SELECT t.up_pkg_id, sdh.source_deal_header_id, t.transport_contract, cg.contract_name FROM source_deal_header sdh
			INNER JOIN contract_group cg ON cg.contract_id = sdh.contract_id 
			INNER JOIN #total_86T_deals t ON t.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN #contract_mismatch_deals c ON c.scheduled_deal_id = t.source_deal_header_id AND c.svc_req = t.up_pkg_id
			WHERE t.transport_contract <> cg.contract_name --AND c.id IS NULL
			 
			--SELECT * FROM #contract_mismatch_deals 
			-----------------------------

			SELECT tsd.phy_deal_id, sdd.source_deal_header_id,  sdd.leg, deal_volume , phy.svc_req, phy.package_id, phy.counterparty, phy.delivery_date_from
			INTO #deal_vol_new
			FROM #total_scheduled_deals tsd
			INNER JOIN #total_phy_deals phy ON phy.phy_deal_id = tsd.phy_deal_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tsd.scheduled_deal_id
			LEFT JOIN #total_86T_deals mr ON mr.source_deal_header_id  = sdd.source_deal_header_id AND mr.generic_mapping_value_id = 5
			WHERE mr.id IS NULL		
											
			--SELECT * FROM #deal_vol_new
			

			SELECT unpvt.svc_req, unpvt.delivery_date_from, unpvt.leg_sum sum_diff, dbo.FNAGetSplitPart(leg, '_', 2) leg
			INTO  #vol_diff_child
			FROM (
				SELECT phy.svc_req, phy.delivery_date_from, t.scheduled_receipt_sum - phy.leg_1_sum leg_1_diff, t.scheduled_delivery_sum - phy.leg_2_sum leg_2_diff
				FROM (

					SELECT svc_req, (SUM([1])) leg_1_sum, (SUM([2])) leg_2_sum, delivery_date_from 
					FROM #deal_vol_new s
					PIVOT (	SUM(deal_volume) FOR leg IN ([1],[2]) ) AS p 
					GROUP BY p.svc_req, delivery_date_from		
					
				) phy 
				INNER JOIN #transport_deal_vol t ON t.up_pkg_id = phy.svc_req AND t.delivery_date_from = phy.delivery_date_from
			) pp
			UNPIVOT (leg_sum FOR leg IN (leg_1_diff, leg_2_diff)) AS unpvt 

			--SELECT * FROM #vol_diff_child
					
			
			---- update scheduled deal volume (comparing with transport file)
			UPDATE sdd SET sdd.deal_volume = CASE WHEN SUBSTRING(PARSENAME(sdd.deal_volume + (sdd.deal_volume/p.leg_sum * vd.sum_diff), 1), 1, 2) >= 50 
			THEN CEILING(sdd.deal_volume + (sdd.deal_volume/p.leg_sum * vd.sum_diff))
			ELSE FLOOR(sdd.deal_volume + (sdd.deal_volume/p.leg_sum * vd.sum_diff)) END
			
			--SELECT sdd.source_deal_header_id, sdd.leg, sdd.deal_volume deal_volume_old, sdd.deal_volume + (sdd.deal_volume/p.leg_sum * vd.sum_diff) deal_volume_new
			FROM #deal_vol_new d
			INNER JOIN #vol_diff_child vd ON vd.svc_req = d.svc_req AND vd.leg = d.Leg AND vd.delivery_date_from = d.delivery_date_from
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id AND sdd.leg = d.leg
			INNER JOIN 
			(
				SELECT d.phy_deal_id, d.source_deal_header_id, d.leg, d.svc_req, s.leg_sum FROM #deal_vol_new	d 
				INNER JOIN (
					SELECT svc_req, leg, sum(deal_volume) leg_sum FROM #deal_vol_new GROUP BY leg, svc_req 
				) s ON s.svc_req = d.svc_req AND s.Leg = d.Leg
			) p ON p.phy_deal_id = d.phy_deal_id AND p.leg = d.leg AND p.source_deal_header_id = d.source_deal_header_id
			LEFT JOIN #contract_mismatch_deals c ON c.svc_req = d.svc_req 
			WHERE vd.sum_diff <> 0 AND c.id IS NULL
			

			----scheduled deal logging			
			INSERT INTO #scheduled_deal_log(svc_req, physical_deal, scheduled_deal, leg,
			  pkg_id, counterparty, receipt_location, delivery_location, old_vol, new_vol)
			SELECT 
			svc_req, MAX(sdh_p.deal_id), sdh_s.deal_id, d.leg, d.package_id, MAX(sc.counterparty_name),MAX(sml_r.Location_Name), MAX(sml_d.Location_Name)
			, MAX(d.deal_volume), MAX(sdd.deal_volume) 
			FROM #deal_vol d
			INNER JOIN source_deal_header sdh_p ON sdh_p.source_deal_header_id = d.phy_deal_id
			INNER JOIN source_deal_header sdh_s ON sdh_s.source_deal_header_id = d.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh_s.source_deal_header_id AND sdd.leg = d.leg
			--INNER JOIN #transport_deal_vol t ON t.up_pkg_id = d.svc_req
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh_s.counterparty_id
			LEFT JOIN source_minor_location sml_r ON sml_r.source_minor_location_id = sdd.location_id AND sdd.leg = 1
			LEFT JOIN source_minor_location sml_d ON sml_d.source_minor_location_id = sdd.location_id AND sdd.leg = 2
			LEFT JOIN #total_86T_deals mr ON mr.source_deal_header_id  = sdd.source_deal_header_id AND mr.generic_mapping_value_id = 5
			WHERE mr.id IS NULL		
			GROUP BY svc_req,  sdh_s.deal_id, d.leg, d.package_id -- ,sdh_p.deal_id,
			
			--SELECT * FROM #scheduled_deal_log
			
								
			------------- Using MD , MR template to map deal with srv req, PIPE
		
			CREATE TABLE #deal_vol_md_mr(id INT IDENTITY(1,1), from_deal_id INT, template_name VARCHAR(250) COLLATE DATABASE_DEFAULT, source_deal_header_id INT, leg INT, 
			deal_vol NUMERIC(38,20), new_vol NUMERIC(38,20), location VARCHAR(500) COLLATE DATABASE_DEFAULT, delivery_date_from VARCHAR(20) COLLATE DATABASE_DEFAULT, up_pkg_id VARCHAR(25) COLLATE DATABASE_DEFAULT)

			EXEC('
			INSERT INTO #deal_vol_md_mr(from_deal_id, template_name, source_deal_header_id, leg, deal_vol, new_vol, location, delivery_date_from, up_pkg_id)
			SELECT t.from_deal_id, t.template_name, t.source_deal_header_id, ISNULL(d.leg, sdd.leg), MAX(ISNULL(d.deal_volume, sdd.deal_volume)), 
			CASE ISNULL(d.leg, sdd.leg) WHEN 1 THEN MAX(rs_t.scheduled_receipt) WHEN 2 THEN MAX(rs_t.scheduled_delivery) END new_vol, 
			CASE ISNULL(d.leg, sdd.leg) WHEN 1 THEN MAX(sml_r.Location_Name) WHEN 2 THEN MAX(sml_d.Location_Name) END, t.delivery_date_from, MAX(rs_t.up_pkg_id)
			FROM #total_86T_deals t
			inner join ' + @stage_transport_report + ' rs_t 
			 on rs_t.up_pkg_id = t.up_pkg_id
			 and rs_t.delivery_date_from = t.delivery_date_from
			 and rs_t.delivery_date_to = t.delivery_date_to
			 and ((t.generic_mapping_value_id = 5 and rs_t.delivery_location_id = 216821) 
			 or (t.generic_mapping_value_id = 4 and rs_t.delivery_location_id <> 216821))
			INNER JOIN source_deal_detail sdd2 on sdd2.source_deal_header_id = t.source_deal_header_id AND CONVERT(VARCHAR(8), sdd2.term_start, 112) = t.delivery_date_from AND CONVERT(VARCHAR(8), sdd2.term_end, 112) = t.delivery_date_to
			LEFT JOIN #deal_vol d ON d.source_deal_header_id = t.source_deal_header_id
				and d.delivery_date_from = t.delivery_date_from
			--INNER JOIN user_defined_deal_fields_template uddft_payback ON uddft_payback.template_id = t.template_id 
			--	AND uddft_payback.field_id = -5613
			--INNER JOIN user_defined_deal_fields uddf_payback ON uddf_payback.udf_template_id = uddft_payback.udf_template_id 	
			--	AND uddf_payback.source_deal_header_id = t.source_deal_header_id
			--	AND CONVERT(VARCHAR(8), CAST(uddf_payback.udf_value AS datetime) , 112) = t.delivery_date_from
			LEFT JOIN source_deal_detail sdd on sdd.source_deal_header_id = t.source_deal_header_id
			LEFT JOIN source_minor_location sml_r ON sml_r.source_minor_location_id = sdd.location_id AND sdd.leg = 1
			LEFT JOIN source_minor_location sml_d ON sml_d.source_minor_location_id = sdd.location_id AND sdd.leg = 2
			GROUP BY  t.from_deal_id, t.template_name, t.source_deal_header_id, ISNULL(d.leg, sdd.leg), t.delivery_date_from
			')			
			
			--SELECT * FROM #deal_vol_md_mr

			-- updating deal for MD/MR
			--SELECT sdd.deal_volume, CASE WHEN SUBSTRING(PARSENAME(d.new_vol, 1), 1, 2) >=50 
			--THEN CEILING(d.new_vol) ELSE FLOOR(d.new_vol) END new_vol, sdd.source_deal_header_id

			UPDATE sdd SET sdd.deal_volume = CASE WHEN SUBSTRING(PARSENAME(d.new_vol, 1), 1, 2) >=50 
			THEN CEILING(d.new_vol) ELSE FLOOR(d.new_vol) END 
			FROM source_deal_detail sdd
			INNER JOIN #deal_vol_md_mr d ON d.source_deal_header_id = sdd.source_deal_header_id AND d.leg = sdd.leg
			LEFT JOIN #contract_mismatch_deals c ON c.svc_req = d.up_pkg_id -- c.scheduled_deal_id = sdd.source_deal_header_id
			WHERE d.deal_vol <> d.new_vol AND c.id IS NULL
			
	
			----physical deal logging			
			INSERT INTO #physical_deal_log(svc_req, phy_deal_id, physical_deal, counterparty,
			            receipt_location, old_vol, new_vol)
			SELECT phy.svc_req, sdh.source_deal_header_id, sdh.deal_id, MAX(sc.counterparty_name), MAX(sml_r.Location_Name), MAX(sdd_phy.deal_volume),  MAX(p.new_phy_volume) 
			FROM(
			SELECT tsd.phy_deal_id, sdd.leg,  SUM(sdd.deal_volume) new_phy_volume 
			FROM #total_scheduled_deals tsd
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tsd.scheduled_deal_id AND leg = 1
			GROUP BY tsd.phy_deal_id, sdd.leg
			) p 
			INNER JOIN source_deal_detail sdd_phy ON sdd_phy.source_deal_header_id = p.phy_deal_id AND sdd_phy.leg = p.leg
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd_phy.source_deal_header_id
			INNER JOIN #total_phy_deals phy ON phy.phy_deal_id = p.phy_deal_id
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
			INNER JOIN source_minor_location sml_r ON sml_r.source_minor_location_id = sdd_phy.location_id AND sdd_phy.leg = 1
			GROUP BY phy.svc_req, sdh.source_deal_header_id, sdh.deal_id
			--INNER JOIN pipeline_up_down_service_k map ON map.receipt_poi = phy.receipt_location AND map.serv_req_k = phy.svc_req

			--SELECT * FROM #physical_deal_log
			
			---- update physical deal volume
			UPDATE sdd SET sdd.deal_volume = CASE WHEN SUBSTRING(PARSENAME(p.new_vol, 1), 1, 2) >= 50 THEN CEILING(p.new_vol) ELSE FLOOR(p.new_vol) END
			--SELECT sdd.source_deal_header_id, sdd.deal_volume,  p.new_vol
			FROM source_deal_detail sdd
			INNER JOIN #physical_deal_log p ON p.phy_deal_id = sdd.source_deal_header_id AND sdd.leg = 1
			
			
			-- updating physical deal for MR case
			UPDATE sdd SET sdd.deal_volume = CASE WHEN SUBSTRING(PARSENAME(d.new_vol, 1), 1, 2) >=50 
			THEN CEILING(d.new_vol) ELSE FLOOR(d.new_vol) END 
			--SELECT sdd.source_deal_header_id, sdd.deal_volume, d.new_vol
			FROM source_deal_detail sdd
			INNER JOIN #deal_vol_md_mr d ON d.from_deal_id = sdd.source_deal_header_id AND d.leg = 1
			LEFT JOIN #physical_deal_log phy ON phy.phy_deal_id = d.from_deal_id
			WHERE d.deal_vol <> d.new_vol AND phy.id IS NULL
	

			-- logging for MD deal insertion
			exec('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			SELECT DISTINCT ''' + @process_id + ''', ''Success'', ''Import Data'', ''Pipeline Cut Data'', ''Results'', 
			''MD deal :'' + ISNULL(sdh.deal_id, '''') + '' inserted successfully''
			FROM #md_deal_inserted d
			INNER JOIN source_deal_header sdh on sdh.source_deal_header_id = dbo.FNAGetSplitPart(d.deals, '','', 1)
			')


			-- logging for MD/MR deal update
			exec('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			SELECT DISTINCT ''' + @process_id + ''', ''Success'', ''Import Data'', ''Pipeline Cut Data'', ''Results'', 
			ISNULL(d.template_name,'''') + '' deal:'' + ISNULL(sdh.deal_id, '''') + '' Leg:'' + ISNULL(CAST(d.leg AS VARCHAR(2)), '''') + '' Term:'' + ISNULL(d.delivery_date_from, '''') + CASE d.leg WHEN 1 THEN '', Receipt location:'' WHEN 2 THEN '', Delivery location:''END + ISNULL(d.location, '''') + 
			''. Prior volume:'' + ISNULL(dbo.FNARemoveTrailingZero(deal_vol), '''') + '', Current volume: '' + ISNULL(dbo.FNARemoveTrailingZero(CASE WHEN SUBSTRING(PARSENAME(d.new_vol, 1), 1, 2) >=50 
			THEN CEILING(d.new_vol) ELSE FLOOR(d.new_vol) END), '''')
			FROM #deal_vol_md_mr d
			INNER JOIN source_deal_header sdh on sdh.source_deal_header_id = d.source_deal_header_id
			LEFT JOIN #contract_mismatch_deals c ON c.svc_req = d.up_pkg_id
			 WHERE d.deal_vol <> d.new_vol AND c.id IS NULL
			')
			
			--SELECT * FROM #deal_vol_md_mr
			-- logging for MR physical deal update
			exec('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			SELECT DISTINCT ''' + @process_id + ''', ''Success'', ''Import Data'', ''Pipeline Cut Data'', ''Results'', 
			''MR Physical deal:'' + ISNULL(sdh.deal_id, '''') + '' Leg:'' + ISNULL(CAST(d.leg AS VARCHAR(2)), '''') + ''. Prior volume:'' + ISNULL(dbo.FNARemoveTrailingZero(deal_vol), '''') + '', Current volume: '' + ISNULL(dbo.FNARemoveTrailingZero(CASE WHEN SUBSTRING(PARSENAME(d.new_vol, 1), 1, 2) >=50 
			THEN CEILING(d.new_vol) ELSE FLOOR(d.new_vol) END), '''')
			FROM #deal_vol_md_mr d
			INNER JOIN source_deal_header sdh on sdh.source_deal_header_id = d.from_deal_id
			LEFT JOIN #physical_deal_log p ON p.phy_deal_id = d.from_deal_id
			WHERE d.leg = 1 AND d.deal_vol <> d.new_vol AND p.id IS NULL  -- do not log MR phyiscal deal which has schedule deal as well
			')			
			
						
			-- logging for md/mr which doesn't update any deal	
			EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
				SELECT DISTINCT ''' + @process_id + ''', ''Warning'', ''Import Data'', ''Pipeline Cut Data'', ''Results'', 
				 '' No '' + CASE t.generic_mapping_value_id WHEN 4 THEN ''MD'' WHEN 5 THEN ''MR'' ELSE ''NULL'' END + '' deal updated for Term:'' + ISNULL(t.delivery_date_from, '''') 
				  FROM #total_86T_deals t 
				LEFT JOIN #deal_vol_md_mr d ON d.source_deal_header_id = t.source_deal_header_id AND d.deal_vol <> d.new_vol
				WHERE d.id IS NULL
				')


			-- logging for deals not updated due to contract mismatch
			EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
				SELECT DISTINCT ''' + @process_id + ''', ''Warning'', ''Import Data'', ''Pipeline Cut Data'', ''Results'', 
				 '' Contract mismatch for deal '' + sdh.deal_id + ''. Svc Req:'' + ISNULL(c.svc_req, NULL) + ''. Transport Contract:'' + ISNULL(c.transport_contract, ''NULL'') + '', Deal Contract:'' + ISNULL(c.deal_contract, ''NULL'') 
				FROM #contract_mismatch_deals c
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = c.scheduled_deal_id
				')
			
		----------------------------			
			
			-- scheduled deal update logging
			EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
				SELECT ''' + @process_id + ''', ''Success'', ''Import Data'', ''Pipeline Cut Data'', ''Results'', 
				 '' Scheduled deal updated for deal:'' + ISNULL(scheduled_deal, '''') + '', Leg:'' + ISNULL(leg, '''') + '', Respective physical deal:'' + ISNULL(physical_deal, '''') + '', package ID:'' + ISNULL(pkg_id, ''NULL'') + '', svc req:'' + ISNULL(svc_req, '''') + '', Counterparty:'' + ISNULL(counterparty, '''')
				+ CASE leg WHEN 1 THEN '', Receipt location:'' + ISNULL(receipt_location, '''') WHEN 2 THEN '', Delivery location:'' + ISNULL(delivery_location, '''') END 
				+ ''. Prior volume:'' + ISNULL(dbo.FNARemoveTrailingZero(old_vol), '''') + '', Current volume: '' + ISNULL(dbo.FNARemoveTrailingZero(new_vol), '''')
				FROM #scheduled_deal_log WHERE old_vol <> new_vol
				')
			
			-- physical deal update logging
			EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
				SELECT ''' + @process_id + ''', ''Success'', ''Import Data'', ''Pipeline Cut Data'', ''Results'', 
				 '' Physical deal updated for deal:'' + ISNULL(physical_deal, '''') + '' with respective svc req:'' + ISNULL(svc_req, '''') + '', Counterparty:'' + ISNULL(counterparty, '''') + '', receipt_location:'' + ISNULL(receipt_location, '''') 
				+ ''. Prior volume:'' + ISNULL(dbo.FNARemoveTrailingZero(old_vol), '''') + '', Current volume: '' + ISNULL(dbo.FNARemoveTrailingZero(new_vol), '''')
				FROM #physical_deal_log WHERE old_vol <> new_vol
				')


			-- logging for svc req where no records is found and which doesn't update any deal	
			EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
					SELECT DISTINCT ''' + @process_id + ''', CASE WHEN s.id IS NULL THEN ''Error'' ELSE ''Warning'' END, ''Import Data'', ''Pipeline Cut Data'', ''Results'',
					CASE WHEN s.old_vol = s.new_vol AND ss.id IS null THEN ''No records updated '' WHEN s.id IS NULL THEN ''No records found '' ELSE ''NULL'' END
					+ ''for Svc Req K:'' + p.svc_req + '', Term:'' + ISNULL(p.delivery_date_from, '''') 
				FROM ' + @stage_purchase_report + ' p 
				LEFT JOIN #scheduled_deal_log s ON s.svc_req = p.svc_req
				LEFT JOIN (
						SELECT MAX(id) id, MAX(svc_req) svc_req FROM #scheduled_deal_log s
					WHERE old_vol <> new_vol
					GROUP BY old_vol, new_vol 
				)  ss ON ss.svc_req = s.svc_req
				WHERE p.svc_req IS NOT NULL AND ss.id IS NULL
			  ')
			  
			  
				
			--COMMIT
			
			
			--SELECT * FROM source_system_data_import_status WHERE process_id = 'EA9B7B4C_B0C3_4C75_ACD2_48646A8C9293_53426a99ec82f'
			
			CREATE TABLE #file_info(file_name VARCHAR(255) COLLATE DATABASE_DEFAULT, file_type VARCHAR(8) COLLATE DATABASE_DEFAULT, error_code INT, p_row_count INT, t_row_count INT)

			EXEC('INSERT INTO #file_info(file_name, file_type, error_code, p_row_count, t_row_count)
				SELECT h.file_name, h.file_type, h.error_code, COUNT(p.purchase_report_id) p_row_count, COUNT(t.transport_report_id) t_row_count 
				FROM ' + @stage_pipelinecut_header + ' h
				LEFT JOIN ' + @stage_purchase_report +  ' p ON p.filename = h.file_name
				LEFT JOIN ' + @stage_transport_report +  ' t ON t.filename = h.file_name
				GROUP BY h.file_name, h.file_type, h.error_code	')
			
			SELECT file_type, STUFF((select ', ' + file_name from #file_info t where t.file_type = tt.file_type AND t.error_code = 0
			AND CASE file_type WHEN 'p' THEN p_row_count WHEN 't' THEN t_row_count END > 0
			ORDER BY file_name FOR XML PATH('')),1,2,'') as file_name
			INTO #file_info_valid
			FROM #file_info tt WHERE file_type IN('p', 't')
			GROUP BY file_type

			SELECT @file_desc = '<br/>Purchase files: ' + file_name + ' imported out of ' + CAST(( SELECT COUNT(FILE_NAME) FROM #file_info WHERE file_type = 'p' ) AS VARCHAR(5)) + ' files.<br/>'
			FROM #file_info_valid WHERE file_type = 'p'
			SELECT @file_desc = @file_desc + 'Transport files: ' + file_name + ' imported out of ' + CAST(( SELECT COUNT(FILE_NAME) FROM #file_info WHERE file_type = 't' ) AS VARCHAR(5)) + ' files.'
			FROM #file_info_valid WHERE file_type = 't'
			
			
			SELECT @type =  CASE WHEN (SELECT COUNT(1) FROM #file_info) = (SELECT COUNT(1) FROM #file_info WHERE file_type IN ('p', 't') AND error_code = 0
			AND CASE file_type WHEN 'p' THEN p_row_count WHEN 't' THEN t_row_count END > 0
			) THEN 's' ELSE 'e' END

	END

	
		-- log for error files
		EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			OUTPUT CASE WHEN INSERTED.[code] = ''Error'' THEN ''e'' ELSE ''s'' END  INTO #error_code
			SELECT ''' + @process_id + ''', ''Error'', ''Import Data'', ''Pipeline Cut Purchase Report Data Import ('' + s.file_name + '')'', ''Results'', s.error_msg
			FROM ' + @stage_pipelinecut_header + ' s 
			WHERE s.error_code <> ''0'' ')

		--END TRY
		--BEGIN CATCH
		--	SET @caught = 1
		--	SET @desc = ERROR_MESSAGE()

		--	IF @@TRANCOUNT > 0
		--		ROLLBACK		
		
		--END CATCH
	
		IF @caught = 1 
		BEGIN
			SET @type = 'e'
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT 1 FROM source_system_data_import_status WHERE Process_id = @process_id AND TYPE IN ('Error', 'Warning'))
				SET @type = 'e'	
			IF EXISTS (SELECT 1 FROM #error_code WHERE [type] = 'e')
				SET @type = 'e'
			ELSE 
				SET @type = 's'

		END
		
		
		--------------- Position CALC and Audit for deals ----------------------
	
		--Collects deal ids for audit,position,update deal volume calc
		CREATE TABLE #updated_deals (source_deal_header_id INT)
		INSERT INTO #updated_deals(source_deal_header_id)
			SELECT DISTINCT phy_deal_id FROM #total_phy_deals WHERE phy_deal_id IS NOT NULL
			UNION
			SELECT DISTINCT scheduled_deal_id FROM #total_scheduled_deals WHERE scheduled_deal_id IS NOT NULL
			UNION
			SELECT DISTINCT source_deal_header_id FROM #total_86T_deals WHERE source_deal_header_id IS NOT NULL
	
		DECLARE @total_deals VARCHAR(8000)
		SELECT @total_deals = COALESCE(@total_deals + ',', '') + cast(source_deal_header_id AS VARCHAR(10))
		FROM #updated_deals

		--Deal audit logic for update deals starts	  
		EXEC spa_insert_update_audit 'u', @total_deals

		--Position calc
		DECLARE @report_position_deals	VARCHAR(300), @spa VARCHAR(MAX), @job_name VARCHAR(MAX)

		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
		EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')
			
		SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT source_deal_header_id,''i''  from #updated_deals '
		EXEC (@sql)

		SET @spa = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(200)) + '''' 
		SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
		EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id

		---------------------------------------
		
	END


	SELECT @elapsed_sec = DATEDIFF(second, create_ts, GETDATE()) FROM import_data_files_audit idfa WHERE idfa.process_id = @process_id
	SET @elapse_sec_text = CAST(CAST(@elapsed_sec/60 AS INT) AS VARCHAR) + ' Mins ' + CAST(@elapsed_sec - CAST(@elapsed_sec/60 AS INT) * 60 AS VARCHAR) + ' Secs'
 
	SELECT @desc = CASE WHEN @caught = 0 THEN 
				   'Pipeline data imported successfully on as of date ' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) + '<br/>' + @file_desc
				   ELSE @desc END	
	  
	SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''        
	SET @url_desc = '<a target="_blank" href="' + @url + '">' +
					  @desc 
					+ '.</a> <br>' + CASE WHEN (@type = 'e') THEN ' (ERRORS found)' ELSE '' END + ' [Elapse time: ' + ISNULL(@elapse_sec_text, ' (Debug mode)') + ']'        

	  --audit table log update total execution time
    EXEC spa_import_data_files_audit 'u',NULL, NULL,@process_id, NULL, NULL, NULL, @type, @elapsed_sec

	EXEC spa_message_board 'i', @user_login_id, NULL, 'Import Data', @url_desc, '', '', @type, 'Import PipeLine Cut Data'	
	
	--removing Ad-hoc message
	DELETE mb FROM message_board mb WHERE mb.job_name = 'ImportData_' + @process_id 

END

IF @flag = 'q'
BEGIN
	SET @sql = 'INSERT INTO ' + @final_staging_table + ' (
					purchase_report_id, svc_req, delivery_date_from, delivery_date_to, deal_date, nr1, 
					contract, package_id, transportation_contract, nr3, nr4, receipt_location_id, 
					receipt_location, nominated_receipt, nominated_delivery, scheduled_receipt, 
					scheduled_delivery, nr5, cut_type1, cut_value1, cut_type2, cut_value2, 
					cut_type3, cut_value3, cut_type4, cut_value4, nr6, nr7, nr8, nr9, nr10, 
					nr11, nr12, nr13, nr14, nr15, nr16, nr17, nr18, nr19, nr20, nr21, nr22, 
					nr23, nr24, nr25, nr26, nr27, nr28, nr29, nr30, nr31, nr32, nr33, nr34, 
					nr35, nr36, nr37, nr38, nr39, nr40, nr41, nr42, nr43, nr44, nr45, nr46, 
					nr47, nr48, nr49, nr50, nr51, nr52, nr53, cpty_duns_no, nr54, nr55, nr56, 
					counterparty, filename, error, create_ts, file_type
				)
				SELECT 
					purchase_report_id, svc_req, delivery_date_from, delivery_date_to, deal_date, nr1, 
					contract, package_id, transportation_contract, nr3, nr4, receipt_location_id, 
					receipt_location, nominated_receipt, nominated_delivery, scheduled_receipt, 
					scheduled_delivery, nr5, cut_type1, cut_value1, cut_type2, cut_value2, 
					cut_type3, cut_value3, cut_type4, cut_value4, nr6, nr7, nr8, nr9, nr10, 
					nr11, nr12, nr13, nr14, nr15, nr16, nr17, nr18, nr19, nr20, nr21, nr22, 
					nr23, nr24, nr25, nr26, nr27, nr28, nr29, nr30, nr31, nr32, nr33, nr34, 
					nr35, nr36, nr37, nr38, nr39, nr40, nr41, nr42, nr43, nr44, nr45, nr46, 
					nr47, nr48, nr49, nr50, nr51, nr52, nr53, cpty_duns_no, nr54, nr55, nr56, 
					counterparty, filename, error, create_ts, ''p''
				FROM ' + @stage_purchase_report + '
				
				
				INSERT INTO ' + @final_staging_table + ' (
					transport_report_id, svc_req, delivery_date_from, delivery_date_to, 
					deal_date, nr1, up_pkg_id, nr2, nr3, nr4, receipt_location_id, delivery_location_id, 
					nominated_receipt, nominated_delivery, scheduled_receipt, scheduled_delivery, nr5, 
					nr6, actual_receipt, nr7, nr8, mdq_original, mdq_available, nr9, cut_type1, 
					cut_value1, cut1_value_del, cut_type2, cut_value2, cut2_value_del, cut_type3, 
					cut_value3, cut3_value_del, cut_type4, cut_value4, cut4_value_del, nr10, nr11, 
					nr12, nr13, nr14, nr15, nr16, nr17, nr18, nr19, nr20, nr21, nr22, nr23, nr24, 
					nr25, nr26, nr27, nr28, nr29, nr30, nr31, nr32, nr33, nr34, nr35, nr36, nr37, 
					nr38, nr39, nr40, nr41, nr42, nr43, nr44, nr45, nr46, nr47, nr48, nr49, nr50, 
					nr51, nr52, nr53, nr54, nr55, nr56, nr57, nr58, nr59, nr60, nr61, nr62, nr63, 
					nr64, nr65, nr66, nr67, nr68, nr69, nr70, nr71, nr72, nr73, nr74, nr75, nr76, 
					nr77, delivery_location, receipt_location, nr78, nr79, nr80, nr81, nr82, nr83, 
					nr84, nr85, nr86, nr87, nr88, nr89, nr90, nr91, nr92, nr93, nr94, nr95, nr96, 
					nr97, nr98, nr99, nr100, nr101, nr102, nr103, nr104, nr105, nr106, nr107, nr108, 
					nr109, nr110, nr111, nr112, nr113, nr114, filename, error, create_ts, file_type
				)
				SELECT 
					transport_report_id, svc_req, delivery_date_from, delivery_date_to, 
					deal_date, nr1, up_pkg_id, nr2, nr3, nr4, receipt_location_id, delivery_location_id, 
					nominated_receipt, nominated_delivery, scheduled_receipt, scheduled_delivery, nr5, 
					nr6, actual_receipt, nr7, nr8, mdq_original, mdq_available, nr9, cut1, 
					cut1_value_receipt, cut1_value_del, cut2, cut2_value_receipt, cut2_value_del, cut_type3, 
					cut3_value_receipt, cut3_value_del, cut_type4, cut4_value_receipt, cut4_value_del, nr10, nr11, 
					nr12, nr13, nr14, nr15, nr16, nr17, nr18, nr19, nr20, nr21, nr22, nr23, nr24, 
					nr25, nr26, nr27, nr28, nr29, nr30, nr31, nr32, nr33, nr34, nr35, nr36, nr37, 
					nr38, nr39, nr40, nr41, nr42, nr43, nr44, nr45, nr46, nr47, nr48, nr49, nr50, 
					nr51, nr52, nr53, nr54, nr55, nr56, nr57, nr58, nr59, nr60, nr61, nr62, nr63, 
					nr64, nr65, nr66, nr67, nr68, nr69, nr70, nr71, nr72, nr73, nr74, nr75, nr76, 
					nr77, delivery_location, receipt_location, nr78, nr79, nr80, nr81, nr82, nr83, 
					nr84, nr85, nr86, nr87, nr88, nr89, nr90, nr91, nr92, nr93, nr94, nr95, nr96, 
					nr97, nr98, nr99, nr100, nr101, nr102, nr103, nr104, nr105, nr106, nr107, nr108, 
					nr109, nr110, nr111, nr112, nr113, nr114, filename, error, create_ts, ''t''
				FROM ' + @stage_transport_report
	
	EXEC(@sql)
END
