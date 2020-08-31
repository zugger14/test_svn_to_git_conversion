IF OBJECT_ID(N'spa_Calc_Netting_Measurement', N'P') IS NOT NULL
	DROP PROC [dbo].[spa_Calc_Netting_Measurement]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
This SP Nets the GL value of portfolio according to different netting group level.
	
	Parameters: 
	@process_id						: Unique Identifier
	@sub_id							: Subsidiary Entity ID
	@as_of_date						: Calculation run date
	@print_diagnostic				: Allow to PRINT statements for debuging
	@user_login_id					: User name
	@drill_tbl_output				: TBD
	@drill_netting_parent_group_id	: TBD
	@drill_discount_option			: TBD
	@drill_gl_number				: TBD
	@drill_counterparty_id			: TBD

*/

CREATE PROC [dbo].[spa_Calc_Netting_Measurement] 
	@process_id						VARCHAR(50), 
	@sub_id							VARCHAR(MAX),
	@as_of_date						VARCHAR(15), 
	@print_diagnostic				INT = 0,
	@user_login_id					VARCHAR(50),
	@drill_tbl_output				VARCHAR(100) = NULL,
	@drill_netting_parent_group_id	INT = NULL,
	@drill_discount_option			VARCHAR(1) = NULL,
	@drill_gl_number				VARCHAR(5000) = NULL,
	@drill_counterparty_id			INT=null
		
 AS

/*
 DECLARE @as_of_date VARCHAR(20)
 DECLARE @process_id VARCHAR(50)
 DECLARE @sub_id VARCHAR(500)
 DECLARE @print_diagnostic INT 
 DECLARE @user_login_id VARCHAR(100)
 DECLARE @drill_tbl_output VARCHAR(100) -- provide table name for output
 DECLARE @drill_discount_option VARCHAR(1)
 DECLARE @drill_gl_number VARCHAR(2000)
 DECLARE @drill_netting_parent_group_id INT, @drill_counterparty_id INT
  
 SET @user_login_id = 'farrms_admin'
 SET @sub_id = '1'
 SET @print_diagnostic = 1
 SET @as_of_date = '2011-04-29'
 SET @process_id  = '1234'
 SET @drill_tbl_output = NULL --'adiha_process.dbo.drill_net_gl_farrms_admin_9F9F9699_7D56_4E69_957E_C270F594A867'
 SET @drill_netting_parent_group_id = NULL--18 -- null --10
 SET @drill_discount_option = 'd' --null --'u'
 SET @drill_gl_number = null --'''1-10-20-20'', ''1-10-20-19'''
 SET @drill_counterparty_id = NULL--29
 drop table  #cpd 

-- SELECT top 400 u_aoci_tax_per, u_AOci, final_und_pnl, * FROM adiha_process.dbo.calcprocess_netting_one_farrms_admin_1234 where u_Aoci<>0
-- SELECT * FROM adiha_process.dbo.calcprocess_netting_two_farrms_admin_1234
-- select * from adiha_process.dbo.calcprocess_netting_final_farrms_admin_1234

 drop table adiha_process.dbo.calcprocess_netting_deals_farrms_admin_1234
 drop table adiha_process.dbo.calcprocess_netting_one_farrms_admin_1234
 drop table adiha_process.dbo.calcprocess_netting_two_farrms_admin_1234
 -----drop table adiha_process.dbo.calcprocess_netting_final_farrms_admin_1234
 drop table adiha_process.dbo.#net_parent_group 
 drop table #tmp_cpd
 drop table #subs 
 drop table #d_other_gl_entries
 drop table #u_other_gl_entries
 drop table #process_parent_group
 IF @drill_tbl_output is not null drop table #drill_other_gl_entries
 IF @drill_tbl_output is not null drop table #t_ddetail
*/
---------------end of test this
SET STATISTICS IO OFF
SET NOCOUNT OFF
SET ROWCOUNT 0

DECLARE @sql_stmt VARCHAR(8000)
DECLARE @NettingProcessTableOneName VARCHAR(100)
DECLARE @NettingProcessTableTwoName VARCHAR(100)
--DECLARE @NettingProcessTableFinalName VARCHAR(100)
DECLARE @NettingDealProcessTableName VARCHAR(100)
DECLARE @log_increment 	INT
DECLARE @drill_gl_number_quote VARCHAR(5000)
DECLARE @sqlSelect VARCHAR(8000)
DECLARE @sqlSelect2 VARCHAR(8000)

DECLARE @pr_name VARCHAR(100)
DECLARE @log_time DATETIME

SET @NettingDealProcessTableName = dbo.FNAProcessTableName('calcprocess_netting_deals', @user_login_id, @process_id)
SET @NettingProcessTableOneName = dbo.FNAProcessTableName('calcprocess_netting_one', @user_login_id, @process_id)
SET @NettingProcessTableTwoName = dbo.FNAProcessTableName('calcprocess_netting_two', @user_login_id, @process_id)
--SET @NettingProcessTableFinalName = dbo.FNAProcessTableName('calcprocess_netting_Final', @user_login_id, @process_id)

IF @drill_gl_number = '' 
	SET @drill_gl_number  = NULL

IF @drill_gl_number is not null 
	SET @drill_gl_number_quote = '''' + REPLACE (REPLACE(@drill_gl_number, ' ', ''), ',' , ''',''') + ''''

IF @print_diagnostic = 1
BEGIN
	SET @log_increment = 1
	PRINT '******************************************************************************************'
	PRINT '********************START &&&&&&&&&[spa_Calc_Netting_Measurement]**********'
END

DECLARE @aoci_tax_asset_liab CHAR(1)
SELECT @aoci_tax_asset_liab = var_value FROM adiha_default_codes_values
WHERE instance_no = 1 AND seq_no = 1 AND default_code_id = 39

IF @aoci_tax_asset_liab IS NULL
	SET @aoci_tax_asset_liab = '0'

CREATE TABLE #net_parent_group(netting_parent_group_id INT, fas_subsidiary_id INT, legal_entity INT, Netting_Parent_Group_Name VARCHAR(1000) COLLATE DATABASE_DEFAULT)
--select * from #net_parent_group
INSERT INTO #net_parent_group
SELECT ngp.netting_parent_group_id, fs.fas_subsidiary_id, ngp.legal_entity, ngp.Netting_Parent_Group_Name
FROM  (SELECT 1 jid, * FROM netting_group_parent) ngp
		LEFT OUTER JOIN netting_group_parent_subsidiary ngps ON ngps.netting_parent_group_id = ngp.netting_parent_group_id 
		FULL OUTER JOIN (SELECT 1 jid, * from fas_subsidiaries WHERE fas_subsidiary_id <> -1) fs 
ON fs.jid= ngp.jid
WHERE ngp.active = 'y' AND ngps.netting_parent_group_id IS NULL

--Collect Subs to process
CREATE TABLE #subs (fas_subsidiary_id INT)
SET @sqlSelect = 'INSERT INTO #subs SELECT fas_subsidiary_id FROM fas_subsidiaries WHERE fas_subsidiary_id <> -1 AND fas_subsidiary_id IN (' + @sub_id + ')'
EXEC (@sqlSelect)

INSERT INTO #net_parent_group
SELECT DISTINCT ngp.netting_parent_group_id, ngps.fas_subsidiary_id, ngp.legal_entity, ngp.Netting_Parent_Group_Name 
FROM    netting_group_parent ngp INNER JOIN
	netting_group_parent_subsidiary ngps ON ngps.netting_parent_group_id = ngp.netting_parent_group_id INNER JOIN
	#subs s ON s.fas_subsidiary_id = ngps.fas_subsidiary_id
WHERE ngp.active = 'y' 

SELECT DISTINCT netting_parent_group_id INTO #process_parent_group FROM #net_parent_group

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

EXEC('
CREATE TABLE ' + @NettingDealProcessTableName + ' (
	[source_deal_header_id] [INT] NOT NULL,
	[item_match_term_month] [DATETIME] NOT NULL,
	[physical_financial_flag] [char](1)  NULL,
	[deal_type] [INT] NULL,
	[deal_sub_type] [INT] NULL,
	[hedge_type_value_id] [INT] NULL,
	[hedge_or_item] [VARCHAR](1)  NULL,
	[source_counterparty_id] [INT] NULL,
	[Final_Und_Pnl] [FLOAT] NULL,
	[Final_Dis_Pnl] [FLOAT] NULL,
	[Long_Term_Months] [INT] NULL,
	[curve_id] [INT] NULL,
	[discount_factor] [FLOAT] NULL,
	[contract_id] [INT] NULL,
	[legal_entity] [INT] NULL,
	[all_short_term] [VARCHAR] (1) NULL,
	[G_GL_Number_ID_St_Asset] [INT] NULL ,
	[G_GL_Number_ID_ST_Liab] [INT] NULL ,
	[G_GL_Number_ID_Lt_Asset] [INT] NULL ,
	[G_GL_Number_ID_Lt_Liab][INT] NULL,
	[orig_source_counterparty_id] [INT] NULL,
	[sub_id] INT NULL,
	[u_aoci] FLOAT NULL,
	[d_aoci] FLOAT NULL,
	[gl_id_st_tax_asset] [INT] NULL,
	[gl_id_st_tax_liab] [INT] NULL,
	[gl_id_lt_tax_asset] [INT] NULL,
	[gl_id_lt_tax_liab] [INT] NULL,
	[tax_perc] [FLOAT] NULL
) ON [PRIMARY]
')

-----------------------POPULATE CALCPROCESS DEALS---------------------------------------------------
IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************End of Collecting Calcprocess deals *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

-----------------------RETRIEVE ALL PARTICIPATING DEALS FIRST---------------------------------------------------
SET @sql_stmt = 'INSERT INTO ' + @NettingDealProcessTableName + 
				'
SELECT		cd.source_deal_header_id,
			cd.term_start item_match_term_month,
			MAX(cd.physical_financial_flag) physical_financial_flag,
			MAX(cd.deal_type) deal_type,
			MAX(cd.deal_sub_type) deal_sub_type,
			MAX(cd.hedge_type_value_id) hedge_type_value_id,
			MAX(cd.hedge_or_item) hedge_or_item,
			MAX(COALESCE(sc.netting_parent_counterparty_id, cd.source_counterparty_id)) as source_counterparty_id,
			ISNULL(MAX(cd.und_pnl), 0) AS [Final_Und_Pnl],
			ISNULL(MAX(cd.dis_pnl), 0) AS [Final_Dis_Pnl],
			MAX(cd.long_term_months) AS [Long_Term_Months],
			MAX(cd.curve_id) As curve_id,
			MAX(cd.discount_factor) as discount_factor,
			MAX(sdh.contract_id) contract_id,
			MAX(coalesce(sdh.legal_entity, fb.legal_entity)) legal_entity,
			MAX(ISNULL(fs.no_links, ''n'')) all_short_term,		 
			MAX(CASE WHEN (fs.gl_grouping_value_id = 350) THEN fs.gl_number_id_st_asset ELSE  fb.gl_number_id_st_asset END) [G_GL_Number_ID_St_Asset],
			MAX(CASE WHEN (fs.gl_grouping_value_id = 350) THEN fs.gl_number_id_st_liab ELSE  fb.gl_number_id_st_liab END) [G_GL_Number_ID_ST_Liab],
			MAX(CASE WHEN (fs.gl_grouping_value_id = 350) THEN fs.gl_number_id_lt_asset ELSE  fb.gl_number_id_lt_asset END) [G_GL_Number_ID_Lt_Asset],
			MAX(CASE WHEN (fs.gl_grouping_value_id = 350) THEN fs.gl_number_id_lt_liab ELSE  fb.gl_number_id_lt_liab END) [G_GL_Number_ID_Lt_Liab],
			MAX(cd.source_counterparty_id) as orig_source_counterparty_id,
			MAX(cd.fas_subsidiary_id) sub_id,
			ISNULL(MAX(cd.u_aoci), 0) u_aoci, ISNULL(MAX(cd.d_aoci), 0) d_aoci,
			ISNULL(MAX(CASE WHEN (fs.gl_grouping_value_id = 350) THEN fs.gl_id_st_tax_asset ELSE  fb.gl_id_st_tax_asset END), -9) [gl_id_st_tax_asset],
			ISNULL(MAX(CASE WHEN (fs.gl_grouping_value_id = 350) THEN fs.gl_id_st_tax_liab ELSE  fb.gl_id_st_tax_liab END), -10) [gl_id_st_tax_liab],
			ISNULL(MAX(CASE WHEN (fs.gl_grouping_value_id = 350) THEN fs.gl_id_lt_tax_asset ELSE  fb.gl_id_lt_tax_asset END), -11) [gl_id_lt_tax_asset],
			ISNULL(MAX(CASE WHEN (fs.gl_grouping_value_id = 350) THEN fs.gl_id_lt_tax_liab ELSE  fb.gl_id_lt_tax_liab END), -12) [gl_id_lt_tax_liab],
			MAX(CASE WHEN(cd.hedge_type_value_id<>150) THEN 0 ELSE COALESCE(sub.tax_perc, fb.tax_perc, 0) END) tax_perc 

  '
+ ' 
FROM ' +    dbo.FNAGetProcessTableName(dbo.FNAGetContractMonth(@as_of_date), 'calcprocess_deals') + ' cd INNER JOIN 
			source_deal_header sdh ON cd.source_deal_header_id = sdh.source_deal_header_id INNER JOIN
			source_counterparty sc ON sc.source_counterparty_id = cd.source_counterparty_id INNER JOIN
			portfolio_hierarchy ph_book on ph_book.entity_id = cd.fas_book_id INNER JOIN
			fas_strategy fs ON fs.fas_strategy_id = cd.fas_strategy_id INNER JOIN
			fas_books fb ON fb.fas_book_id = ph_book.entity_id INNER JOIN
			portfolio_hierarchy ph_stra on ph_stra.entity_id = ph_book.parent_entity_id INNER JOIN
			fas_subsidiaries sub ON sub.fas_subsidiary_id = ph_stra.parent_entity_id
WHERE cd.as_of_date = CONVERT(DATETIME, ''' + @as_of_date + ''', 102) and cd.leg = 1 and
			cd.calc_type = ''m'' and cd.include = ''y'' and cd.term_start > CONVERT(DATETIME, ''' + @as_of_date + ''', 102)
			and ((cd.hedge_type_value_id = 150 AND cd.hedge_or_item = ''h'') OR cd.hedge_type_value_id = 151 OR cd.hedge_type_value_id = 152)
		--WhatIf Changes (Only process non hypothetical links
		AND (cd.no_link IS NULL OR cd.no_link = ''n'')
GROUP BY cd.source_deal_header_id, cd.term_start 
'
EXEC (@sql_stmt)

--exec ('select * from ' + @NettingDealProcessTableName + ' where legal_entity is not null order by source_deal_header_id, item_match_term_month')

EXEC('CREATE INDEX INDX_NETTINGDEALPROCESSTABLENAME_1 ON ' + @NettingDealProcessTableName + ' (sub_id)')
EXEC('CREATE INDEX INDX_NETTINGDEALPROCESSTABLENAME_2 ON ' + @NettingDealProcessTableName + ' (legal_entity)')
EXEC('CREATE INDEX INDX_NETTINGDEALPROCESSTABLENAME_3 ON ' + @NettingDealProcessTableName + ' (orig_source_counterparty_id)')
EXEC('CREATE INDEX INDX_NETTINGDEALPROCESSTABLENAME_4 ON ' + @NettingDealProcessTableName + ' (source_counterparty_id)')
EXEC('CREATE INDEX INDX_NETTINGDEALPROCESSTABLENAME_5 ON ' + @NettingDealProcessTableName + ' (curve_id)')
EXEC('CREATE INDEX INDX_NETTINGDEALPROCESSTABLENAME_6 ON ' + @NettingDealProcessTableName + ' (contract_id)')
EXEC('CREATE INDEX INDX_NETTINGDEALPROCESSTABLENAME_7 ON ' + @NettingDealProcessTableName + ' (source_deal_header_id)')
EXEC('CREATE INDEX INDX_NETTINGDEALPROCESSTABLENAME_8 ON ' + @NettingDealProcessTableName + ' (item_match_term_month)')

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Collecting deals from calcprocess deals for netting *****************************'	
END

-----------------------END OF RETRIEVE ALL PARTICIPATING DEALS FIRST--------------------------------------------
DECLARE @netting_parent_group_id VARCHAR(10),
	@netting_parent_group_name VARCHAR(100),
	@netting_group_id VARCHAR(10),
	@netting_group_name VARCHAR(100),
	@netting_group_detail_id VARCHAR(10),
	@source_commodity_id VARCHAR(10),
	@physical_financial_flag char(1),
	@source_deal_type_id VARCHAR(10),
	@source_deal_sub_type_id VARCHAR(10),
	@hedge_type_value_id VARCHAR(10),
	@source_counterparty_id VARCHAR(10),
	@gl_number_id_st_asset VARCHAR(10),
	@gl_number_id_st_liab VARCHAR(10),
	@gl_number_id_lt_asset VARCHAR(10),
	@gl_number_id_lt_liab VARCHAR(10),
	@source_contract VARCHAR(500),
	@source_contract_id INT,
	@legal_entity VARCHAR(10)

EXEC('CREATE TABLE ' + @NettingProcessTableOneName + '
	(
	[Netting_Parent_Group_ID] [INT] NOT NULL ,
	[Netting_Parent_Group_Name] [VARCHAR] (100) NOT NULL ,
	[Netting_Group_ID] [INT] NOT NULL ,
	[Netting_Group_Name] [VARCHAR] (100) NOT NULL ,
	[Netting_Group_Detail_ID] [INT] NOT NULL ,
	[Source_Deal_Header_ID] [INT] NULL,
	[Source_Counterparty_ID] [INT] NULL,
	[GL_Number_ID_St_Asset] [INT] NULL ,
	[GL_Number_ID_ST_Liab] [INT] NULL ,
	[GL_Number_ID_Lt_Asset] [INT] NULL ,
	[GL_Number_ID_Lt_Liab][INT] NULL ,
	[item_match_term_month] [DATETIME] NULL ,
	[Final_Und_Pnl] [FLOAT] NULL ,
	[Final_Dis_Pnl] [FLOAT] NULL ,
	[Long_Term_Months] [INT] NULL,
	[hedge_asset_test] [INT] NULL,
	[all_short_term] [CHAR] (1) NULL,
	[legal_entity] [INT] NULL,
	[short_term] [INT] NULL, -- 1 means short term and 1 means long term
	[d_hedge_asset_test] [INT] NULL,
	[u_aoci] FLOAT NULL,
	[d_aoci] FLOAT NULL,
	[gl_id_st_tax_asset] [INT] NULL,
	[gl_id_st_tax_liab] [INT] NULL,
	[gl_id_lt_tax_asset] [INT] NULL,
	[gl_id_lt_tax_liab] [INT] NULL,
	[u_aoci_tax_per] [FLOAT] NULL,
	[d_aoci_tax_per] [FLOAT] NULL,
	[tax_perc] [FLOAT] NULL
) ON [PRIMARY] ')

CREATE TABLE #tmp_cpd 
(
source_deal_header_id INT,
item_match_term_month DATETIME,
source_counterparty_id INT,
final_und_pnl FLOAT,
final_dis_pnl FLOAT,
long_term_months INT,
all_short_term CHAR(1) COLLATE DATABASE_DEFAULT,
legal_entity [INT] NULL,
G_GL_Number_ID_St_Asset INT,
G_GL_Number_ID_ST_Liab INT,
G_GL_Number_ID_Lt_Asset INT,
G_GL_Number_ID_Lt_Liab INT, 
[u_aoci] FLOAT NULL,
[d_aoci] FLOAT NULL,
[gl_id_st_tax_asset] [INT] NULL,
[gl_id_st_tax_liab] [INT] NULL,
[gl_id_lt_tax_asset] [INT] NULL,
[gl_id_lt_tax_liab] [INT] NULL,
[tax_perc] [FLOAT] NULL
)
																					    
EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_1 ON ' + @NettingProcessTableOneName + ' (Netting_Parent_Group_ID)')
EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_2 ON ' + @NettingProcessTableOneName + ' (source_deal_header_id)')
EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_3 ON ' + @NettingProcessTableOneName + ' (item_match_term_month)')

DECLARE netting_group CURSOR FOR 
SELECT  ngp.netting_parent_group_id, 
		ngp.netting_parent_group_name, 
		ng.netting_group_id, 
		ng.netting_group_name, 
		ngd.netting_group_detail_id, 
		ng.source_commodity_id, 
		ng.physical_financial_flag, 
		ng.source_deal_type_id, 
		ng.source_deal_sub_type_id, 
		ng.hedge_type_value_id, 
		ngp.legal_entity,
		COALESCE(sc.netting_parent_counterparty_id, ngd.source_counterparty_id, NULL) as source_counterparty_id, 
		ngd.gl_number_id_st_asset, 
		ngd.gl_number_id_st_liab, 
		ngd.gl_number_id_lt_asset, 
		ngd.gl_number_id_lt_liab
FROM	#process_parent_group ppg INNER JOIN
		netting_group_parent ngp ON ngp.netting_parent_group_id = ppg.netting_parent_group_id INNER JOIN
		netting_group ng  ON ng.netting_parent_group_id  = ngp.netting_parent_group_id INNER JOIN
		netting_group_detail ngd  ON ngd.netting_group_id = ng.netting_group_id LEFT OUTER JOIN
		source_counterparty sc ON sc.source_counterparty_id = ngd.source_counterparty_id 	
WHERE	(ng.gain_loss_flag = 'n' OR ng.gain_loss_flag IS NULL) AND
		CONVERT(DATETIME, @as_of_date, 102) BETWEEN ng.effective_date AND ISNULL(ng.end_date, CONVERT(DATETIME, @as_of_date, 102))
ORDER BY ngp.netting_parent_group_id, ngd.source_counterparty_id DESC, ng.netting_group_id, ngd.netting_group_detail_id,
		 ng.source_commodity_id DESC, 
		 ng.physical_financial_flag desc, ng.source_deal_type_id DESC, ng.source_deal_sub_type_id DESC, ng.hedge_type_value_id DESC 
OPEN netting_group
FETCH NEXT FROM netting_group 
INTO 	@netting_parent_group_id,
		@netting_parent_group_name,
		@netting_group_id,
		@netting_group_name,
		@netting_group_detail_id,
		@source_commodity_id,
		@physical_financial_flag,
		@source_deal_type_id,
		@source_deal_sub_type_id,
		@hedge_type_value_id,
		@legal_entity,
		@source_counterparty_id,
		@gl_number_id_st_asset,
		@gl_number_id_st_liab,
		@gl_number_id_lt_asset,
		@gl_number_id_lt_liab 
WHILE @@FETCH_STATUS = 0
BEGIN
	-- delete from temporary table and if index exist drop it
	TRUNCATE TABLE #tmp_cpd
	--	if exists(SELECT * FROM sysindexes where [name]='ix_tmp_cpd')
	--		drop index ix_tmp_cpd on #tmp_cpd

	--	SET @next_id = @next_id + 1

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time = GETDATE()
		PRINT @pr_name + ' Running..............'
	END

	----Find contracts concanted by , for a given netting group detail

	-- End of finding contracts for a given netting group detail
	SET @sqlSelect = ' INSERT INTO #tmp_cpd
		SELECT cd.source_deal_header_id,
			cd.item_match_term_month,
			cd.source_counterparty_id,
			SUM(cd.Final_Und_Pnl) AS final_und_pnl,
			SUM(cd.Final_Dis_Pnl) AS final_dis_pnl,
			cd.long_term_months,
			MAX(cd.all_short_term) all_short_term,
			MAX(cd.legal_entity) legal_entity,
			MAX(cd.G_GL_Number_ID_St_Asset) G_GL_Number_ID_St_Asset,
			MAX(cd.G_GL_Number_ID_ST_Liab) G_GL_Number_ID_ST_Liab,
			MAX(cd.G_GL_Number_ID_Lt_Asset) G_GL_Number_ID_Lt_Asset,
			MAX(cd.G_GL_Number_ID_Lt_Liab) G_GL_Number_ID_Lt_Liab,
			SUM(cd.u_aoci) u_aoci, SUM(cd.d_aoci) d_aoci,
			MAX(cd.gl_id_st_tax_asset) gl_id_st_tax_asset, 
			MAX(cd.gl_id_st_tax_liab) gl_id_st_tax_liab,
			MAX(cd.gl_id_lt_tax_asset) gl_id_lt_tax_asset,
			MAX(cd.gl_id_lt_tax_liab) gl_id_lt_tax_liab,
			MAX(cd.tax_perc) tax_perc 
		FROM #net_parent_group npg INNER JOIN ' + @NettingDealProcessTableName +  ' cd ' +
		' ON npg.netting_parent_group_id = ' + @netting_parent_group_id + ' AND npg.fas_subsidiary_id = cd.sub_id
		' + CASE WHEN ((SELECT COUNT(1) FROM netting_group_detail_contract WHERE netting_group_detail_id = @netting_group_id) > 0) THEN
		'
		 INNER JOIN netting_group_detail_contract con on netting_group_detail_id = ' + CAST(@netting_group_id AS VARCHAR) + ' and contract_id = con.source_contract_id 			
		'
		ELSE '' END +
		' LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = cd.curve_id
		LEFT JOIN  ' + @NettingProcessTableOneName + ' ex on ex.Netting_Parent_Group_ID = ' + @netting_parent_group_id + ' AND cd.source_deal_header_id = ex.source_deal_header_id
		WHERE 1 = 1 
			AND ex.source_deal_header_id IS NULL ' + 
			(CASE WHEN (@source_commodity_id IS NOT NULL) THEN ' AND (spcd.commodity_id = ' + @source_commodity_id + ')' ELSE '' END) +
			(CASE WHEN (@physical_financial_flag IS NOT NULL AND @physical_financial_flag <> 'a') THEN ' AND (cd.physical_financial_flag = ''' + @physical_financial_flag + ''')' ELSE '' END) +
			(CASE WHEN (@source_deal_type_id IS NOT NULL) THEN ' AND (cd.deal_type = ' + @source_deal_type_id + ')' ELSE '' END) + 
			(CASE WHEN (@source_deal_sub_type_id IS NOT NULL) THEN ' AND (cd.deal_sub_type = ' + @source_deal_sub_type_id + ')' ELSE '' END) + 
			(CASE WHEN (@hedge_type_value_id IS NOT NULL) THEN ' AND (cd.hedge_type_value_id = ' + @hedge_type_value_id + ')' ELSE '' END) + 
			(CASE WHEN (@source_counterparty_id IS NOT NULL) THEN ' AND (cd.source_counterparty_id = ' + @source_counterparty_id + ')' ELSE '' END) +
			(CASE WHEN (@legal_entity IS NOT NULL) THEN ' AND (cd.legal_entity = ' + @legal_entity + ')' ELSE '' END) 
		+ ' GROUP BY cd.source_deal_header_id, cd.item_match_term_month, cd.source_counterparty_id, cd.long_term_months '

	EXEC (@sqlSelect)

	EXEC('ALTER INDEX INDX_NETTINGPROCESSTABLEONENAME_1 ON ' + @NettingProcessTableOneName + ' DISABLE')
	EXEC('ALTER INDEX INDX_NETTINGPROCESSTABLEONENAME_2 ON ' + @NettingProcessTableOneName + ' DISABLE')
	EXEC('ALTER INDEX INDX_NETTINGPROCESSTABLEONENAME_3 ON ' + @NettingProcessTableOneName + ' DISABLE')

   	SET @sqlSelect = '
	INSERT INTO ' + @NettingProcessTableOneName + '
	SELECT  ' + @netting_parent_group_id + ' AS [Netting_Parent_Group_ID] ,'''
		+ @netting_parent_group_name + ''' AS [Netting_Parent_Group_Name] ,'
		+ @netting_group_id + ' AS [Netting_Group_ID],'''
		+ @netting_group_name + ''' AS [Netting_Group_Name],'
		+ @netting_group_detail_id + ' AS [Netting_Group_Detail_ID],
		cpd.source_deal_header_id,
		source_counterparty_id,
		COALESCE(' + CASE WHEN (@gl_number_id_st_asset is null) then 'NULL' else CAST(@gl_number_id_st_asset AS VARCHAR) end + ', G_GL_Number_ID_St_Asset, -1)  AS [GL_Number_ID_St_Asset],
		COALESCE(' + CASE WHEN (@gl_number_id_st_liab is null) then 'NULL' else CAST(@gl_number_id_st_liab AS VARCHAR) end + ', G_GL_Number_ID_ST_Liab, -2)  AS [GL_Number_ID_ST_Liab],
		COALESCE(' + CASE WHEN (@gl_number_id_lt_asset is null) then 'NULL' else CAST(@gl_number_id_lt_asset AS VARCHAR) end + ', G_GL_Number_ID_Lt_Asset, -3)  AS [GL_Number_ID_Lt_Asset],
		COALESCE(' + CASE WHEN (@gl_number_id_lt_liab is null) then 'NULL' else CAST(@gl_number_id_lt_liab AS VARCHAR) end + ', G_GL_Number_ID_Lt_Liab, -4)  AS [GL_Number_ID_Lt_Liab],
		cpd.item_match_term_month,
		cpd.final_und_pnl,
		cpd.final_dis_pnl,
		cpd.long_term_months,
		NULL as hedge_asset_test,
		all_short_term all_short_term, 
		legal_entity,
		0 short_term,
		NULL as d_hedge_asset_test,
		cpd.u_aoci, cpd.d_aoci,
		cpd.gl_id_st_tax_asset gl_id_st_tax_asset, 
		cpd.gl_id_st_tax_liab gl_id_st_tax_liab,
		cpd.gl_id_lt_tax_asset gl_id_lt_tax_asset,
		cpd.gl_id_lt_tax_liab gl_id_lt_tax_liab,
		NULL u_aoci_tax_per,
		NULL d_aoci_tax_per,
		cpd.tax_perc
	FROM #tmp_cpd cpd '

	EXEC (@sqlSelect)
	
	EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_1 ON ' + @NettingProcessTableOneName+' (Netting_Parent_Group_ID) WITH (FILLFACTOR = 80, PAD_INDEX = ON,DROP_EXISTING = ON)')
	EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_2 ON ' + @NettingProcessTableOneName+' (source_deal_header_id) WITH (FILLFACTOR = 80, PAD_INDEX = ON,DROP_EXISTING = ON)')
	EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_3 ON ' + @NettingProcessTableOneName+' (item_match_term_month) WITH (FILLFACTOR = 80, PAD_INDEX = ON,DROP_EXISTING = ON)')

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************Process next netting filter *****************************'	
	END

   -- Get the next group.
   FETCH NEXT FROM netting_group 
   INTO @netting_parent_group_id,
	@netting_parent_group_name,
	@netting_group_id,
	@netting_group_name,
	@netting_group_detail_id,
	@source_commodity_id,
	@physical_financial_flag,
	@source_deal_type_id,
	@source_deal_sub_type_id,
	@hedge_type_value_id,
	@legal_entity,
	@source_counterparty_id,
	@gl_number_id_st_asset,
	@gl_number_id_st_liab,
	@gl_number_id_lt_asset,
	@gl_number_id_lt_liab 
END
CLOSE netting_group
DEALLOCATE netting_group

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

-------------THE FOLLOWING IS FOR GROSS ENTRIES -----------------------
CREATE TABLE #cpd (
	[source_deal_header_id] [INT] NOT NULL,
	[item_match_term_month] [DATETIME] NOT NULL,
	[source_counterparty_id] [INT] NULL,
	[final_und_pnl] [FLOAT] NULL,
	[final_dis_pnl] [FLOAT] NULL,
	[long_term_months] [INT] NULL,
	[netting_parent_group_id] [INT] NOT NULL,
	[netting_parent_group_name] [VARCHAR](100) COLLATE DATABASE_DEFAULT NOT NULL,
	[all_short_term] [VARCHAR](1) COLLATE DATABASE_DEFAULT NULL,
	[legal_entity] [INT] NULL,
	[G_GL_Number_ID_St_Asset] [INT] NOT NULL,
	[G_GL_Number_ID_ST_Liab] [INT] NOT NULL,
	[G_GL_Number_ID_Lt_Asset] [INT] NOT NULL,
	[G_GL_Number_ID_Lt_Liab] [INT] NOT NULL,
	[sub_id] [INT] NULL,
	[u_aoci] FLOAT NULL,
	[d_aoci] FLOAT NULL,
	[gl_id_st_tax_asset] [INT] NULL,
	[gl_id_st_tax_liab] [INT] NULL,
	[gl_id_lt_tax_asset] [INT] NULL,
	[gl_id_lt_tax_liab] [INT] NULL,
	[tax_perc] [FLOAT] NULL
)

SET @sqlSelect = 'insert into #cpd ([source_deal_header_id],
	[item_match_term_month],
	[source_counterparty_id],
	[final_und_pnl],
	[final_dis_pnl],
	[long_term_months],
	[netting_parent_group_id],
	[netting_parent_group_name],
	[all_short_term],
	[legal_entity] ,
	[G_GL_Number_ID_St_Asset],
	[G_GL_Number_ID_ST_Liab],
	[G_GL_Number_ID_Lt_Asset],
	[G_GL_Number_ID_Lt_Liab],
	[sub_id],
	[u_aoci],
	[d_aoci],
	[gl_id_st_tax_asset],
	[gl_id_st_tax_liab],
	[gl_id_lt_tax_asset],
	[gl_id_lt_tax_liab],
	[tax_perc]
) 
SELECT source_deal_header_id,
			item_match_term_month,
			source_counterparty_id,
			SUM(Final_Und_Pnl) AS final_und_pnl,
			SUM(Final_Dis_Pnl) AS final_dis_pnl,
			long_term_months,
			npg.netting_parent_group_id,
			MAX(npg.netting_parent_group_name) netting_parent_group_name,
			MAX(all_short_term) all_short_term,
			MAX(npg.legal_entity) legal_entity,
			ISNULL(MAX([G_GL_Number_ID_St_Asset]), -5)  [G_GL_Number_ID_St_Asset],
			ISNULL(MAX([G_GL_Number_ID_ST_Liab]), -6)  [G_GL_Number_ID_ST_Liab],
			ISNULL(MAX([G_GL_Number_ID_Lt_Asset]), -7)  [G_GL_Number_ID_Lt_Asset],
			ISNULL(MAX([G_GL_Number_ID_Lt_Liab]), -8)  [G_GL_Number_ID_Lt_Liab],
			MAX(ndp.sub_id) sub_id,
			SUM(ndp.u_aoci) u_aoci, SUM(ndp.d_aoci) d_aoci,
			MAX([gl_id_st_tax_asset])  [gl_id_st_tax_asset],
			MAX([gl_id_st_tax_liab])  [gl_id_st_tax_liab],
			MAX([gl_id_lt_tax_asset]) [gl_id_lt_tax_asset],
			MAX([gl_id_lt_tax_liab])  [gl_id_lt_tax_liab],
			MAX(ndp.tax_perc) tax_perc
		FROM ' + @NettingDealProcessTableName + ' ndp (NOLOCK)
		CROSS JOIN (SELECT DISTINCT netting_parent_group_id, netting_parent_group_name, legal_entity 
				FROM netting_group_parent where active = ''y'') npg 
		WHERE (npg.legal_entity IS NULL OR npg.legal_entity = ndp.legal_entity)
		GROUP BY source_deal_header_id,
			item_match_term_month,
			source_counterparty_id,
			long_term_months,
			npg.netting_parent_group_id
			--,	npg.netting_parent_group_name'

EXEC(@sqlSelect)

CREATE INDEX INDX_CPD ON #cpd (sub_id,netting_parent_group_id)

EXEC('ALTER INDEX INDX_NETTINGPROCESSTABLEONENAME_1 ON ' + @NettingProcessTableOneName + ' DISABLE')
EXEC('ALTER INDEX INDX_NETTINGPROCESSTABLEONENAME_2 ON ' + @NettingProcessTableOneName + ' DISABLE')
EXEC('ALTER INDEX INDX_NETTINGPROCESSTABLEONENAME_3 ON ' + @NettingProcessTableOneName + ' DISABLE')

SET @sqlSelect = 
	'INSERT INTO ' + @NettingProcessTableOneName + '
	SELECT  
		cpd.netting_parent_group_id  AS [Netting_Parent_Group_ID] ,
		cpd.netting_parent_group_name  AS [Netting_Parent_Group_Name] ,
		-1  AS [Netting_Group_ID],
		''Unselected''  AS [Netting_Group_Name],
		-1 AS [Netting_Group_Detail_ID],
		cpd.source_deal_header_id,
		cpd.source_counterparty_id,
		[G_GL_Number_ID_St_Asset],
		[G_GL_Number_ID_ST_Liab],
		[G_GL_Number_ID_Lt_Asset],
		[G_GL_Number_ID_Lt_Liab],
		cpd.item_match_term_month,
		(cpd.final_und_pnl) AS [Final_Und_Pnl],
		(cpd.final_dis_pnl) AS [Final_Dis_Pnl],
		(cpd.long_term_months) AS [Long_Term_Months],
		 NULL as hedge_asset_test,
		cpd.all_short_term,
		cpd.legal_entity,
		0 short_term,
		NULL as d_hedge_asset_test,
		cpd.u_aoci, cpd.d_aoci,
		cpd.gl_id_st_tax_asset, 
		cpd.gl_id_st_tax_liab,
		cpd.gl_id_lt_tax_asset,
		cpd.gl_id_lt_tax_liab, 		
		NULL u_aoci_tax_per,
		NULL d_aoci_tax_per,
		cpd.tax_perc
	FROM #cpd cpd 
	INNER JOIN #net_parent_group npg ON npg.netting_parent_group_id = cpd.netting_parent_group_id AND npg.fas_subsidiary_id = cpd.sub_id
	LEFT OUTER JOIN  ' + @NettingProcessTableOneName + ' ex ON cpd.source_deal_header_id = ex.source_deal_header_id 
		AND cpd.netting_parent_group_id = ex.netting_parent_group_id
	WHERE ex.source_deal_header_id IS NULL '

EXEC(@sqlSelect)

EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_1 ON ' + @NettingProcessTableOneName + ' (Netting_Parent_Group_ID) WITH (FILLFACTOR = 80, PAD_INDEX = ON,DROP_EXISTING = ON)')
EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_2 ON ' + @NettingProcessTableOneName + ' (source_deal_header_id) WITH (FILLFACTOR = 80, PAD_INDEX = ON,DROP_EXISTING = ON)')
EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_3 ON ' + @NettingProcessTableOneName + ' (item_match_term_month) WITH (FILLFACTOR = 80, PAD_INDEX = ON,DROP_EXISTING = ON)')
EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_4 ON ' + @NettingProcessTableOneName + ' (source_counterparty_id)')
EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLEONENAME_5 ON ' + @NettingProcessTableOneName + ' (netting_group_id)')

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Process next netting filter for GROSS calculation*****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

-- For all netting buckets find out whether SHORT term is asset (1) or not (0 is liability) 
SET @sqlSelect = '
				UPDATE ' + @NettingProcessTableOneName + ' 
				SET hedge_asset_test = st.hedge_asset_test1, 
					d_hedge_asset_test = st.d_hedge_asset_test1, short_term = 1
					--,u_aoci_tax_per = u_total_aoci/ISNULL(NULLIF(total_pnl, 0), 1), d_aoci_tax_per = u_total_aoci/ISNULL(NULLIF(total_pnl, 0), 1) --d_total_aoci/d_total_pnl
				FROM ' + @NettingProcessTableOneName + ' npt 
				INNER JOIN (SELECT	netting_group_id, source_counterparty_id, SUM(Final_Und_Pnl) total_pnl, SUM(Final_Dis_Pnl) d_total_pnl,
							SUM(u_aoci) u_total_aoci, SUM(d_aoci) d_total_aoci, 
							CASE WHEN (SUM(Final_Und_Pnl) >= 0) THEN 1 ELSE 0 END hedge_asset_test1,
							CASE WHEN (SUM(Final_Dis_Pnl) >= 0) THEN 1 ELSE 0 END d_hedge_asset_test1
						FROM ' + @NettingProcessTableOneName + '
						WHERE netting_group_id <> -1 and (all_short_term = ''y'' OR item_match_term_month <= DATEADD(mm, long_term_months - 1, ''' + @as_of_date + '''))
						group by netting_group_id, source_counterparty_id) st ON st.netting_group_id = npt.netting_group_id 
					AND st.source_counterparty_id = npt.source_counterparty_id
					AND (npt.all_short_term = ''y'' OR npt.item_match_term_month <= DATEADD(mm, npt.long_term_months - 1, ''' + @as_of_date + '''))' 	

EXEC(@sqlSelect)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': '+CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************SHORT TERM assets/liabilities test*****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

-- For all netting buckets find out whether LONG term is asset (1) or not (0 is liability) 
SET @sqlSelect = '
				UPDATE ' + @NettingProcessTableOneName + ' set hedge_asset_test = st.hedge_asset_test1, 
						d_hedge_asset_test = st.d_hedge_asset_test1, short_term = 0
						--,u_aoci_tax_per = u_total_aoci/ISNULL(NULLIF(total_pnl, 0), 1), d_aoci_tax_per = u_total_aoci/ISNULL(NULLIF(total_pnl, 0), 1) --d_total_aoci/d_total_pnl
				FROM ' + @NettingProcessTableOneName + ' npt 
				INNER JOIN (SELECT	netting_group_id, source_counterparty_id, SUM(Final_Und_Pnl) total_pnl, SUM(Final_Dis_Pnl) d_total_pnl,
								SUM(u_aoci) u_total_aoci, SUM(d_aoci) d_total_aoci, 
								CASE WHEN (SUM(Final_Und_Pnl) >= 0) then 1 else 0 end hedge_asset_test1,
								CASE WHEN (SUM(Final_Dis_Pnl) >= 0) then 1 else 0 end d_hedge_asset_test1
							FROM ' + @NettingProcessTableOneName + '
							WHERE netting_group_id <> -1 and (item_match_term_month > DATEADD(mm, long_term_months - 1, ''' + @as_of_date + ''') AND all_short_term = ''n'')
							GROUP BY netting_group_id, source_counterparty_id) st ON st.netting_group_id = npt.netting_group_id 
					AND st.source_counterparty_id = npt.source_counterparty_id
					AND (npt.item_match_term_month > DATEADD(mm, npt.long_term_months - 1, ''' + @as_of_date + ''') AND npt.all_short_term = ''n'')'
EXEC(@sqlSelect)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) + '*************************************'
	PRINT '****************LONG TERM assets/liabilities test*****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

-- For all non-netting buckets find out whether SHORT term is asset (1) or not (0 is liability) 
SET @sqlSelect = '
				UPDATE ' + @NettingProcessTableOneName + ' set hedge_asset_test = st.hedge_asset_test1, 
						d_hedge_asset_test = st.d_hedge_asset_test1, short_term = 1
						--,u_aoci_tax_per = u_total_aoci/ISNULL(NULLIF(total_pnl, 0), 1), d_aoci_tax_per = u_total_aoci/ISNULL(NULLIF(total_pnl, 0), 1) --d_total_aoci/d_total_pnl	
				FROM ' + @NettingProcessTableOneName + ' npt 
				INNER JOIN (select	netting_group_id, source_deal_header_id, source_counterparty_id, SUM(Final_Und_Pnl) total_pnl, SUM(Final_Dis_Pnl) d_total_pnl,
									SUM(u_aoci) u_total_aoci, SUM(d_aoci) d_total_aoci, 
									CASE WHEN (SUM(Final_Und_Pnl) >= 0) then 1 else 0 end hedge_asset_test1,
									CASE WHEN (SUM(Final_Dis_Pnl) >= 0) then 1 else 0 end d_hedge_asset_test1
							FROM ' + @NettingProcessTableOneName + '
							WHERE netting_group_id = -1 and (all_short_term = ''y'' OR item_match_term_month <= DATEADD(mm, long_term_months - 1, ''' + @as_of_date + '''))
							GROUP BY netting_group_id, source_deal_header_id, source_counterparty_id) st ON st.netting_group_id = npt.netting_group_id 
					AND st.source_counterparty_id = npt.source_counterparty_id
					AND st.source_deal_header_id = npt.source_deal_header_id
					AND (npt.all_short_term = ''y'' OR npt.item_match_term_month <= DATEADD(mm, npt.long_term_months - 1, ''' + @as_of_date + '''))'
	
EXEC(@sqlSelect)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************SHORT TERM assets/liabilities test FOR GROSS BUCKET*****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

-- For all non-netting buckets find out whether LONG term is asset (1) or not (0 is liability) 
SET @sqlSelect = '
				UPDATE ' + @NettingProcessTableOneName + ' set hedge_asset_test = st.hedge_asset_test1, 
						d_hedge_asset_test = st.d_hedge_asset_test1, short_term = 0
						--,u_aoci_tax_per = u_total_aoci/ISNULL(NULLIF(total_pnl, 0), 1), d_aoci_tax_per = u_total_aoci/ISNULL(NULLIF(total_pnl, 0), 1) --d_total_aoci/d_total_pnl
				FROM ' + @NettingProcessTableOneName + ' npt INNER JOIN 
				(SELECT	netting_group_id, source_deal_header_id, source_counterparty_id, SUM(Final_Und_Pnl) total_pnl, SUM(Final_Dis_Pnl) d_total_pnl,
						SUM(u_aoci) u_total_aoci, SUM(d_aoci) d_total_aoci, 
						CASE WHEN (SUM(Final_Und_Pnl) >= 0) then 1 else 0 end hedge_asset_test1,
						CASE WHEN (SUM(Final_Dis_Pnl) >= 0) then 1 else 0 end d_hedge_asset_test1
				FROM ' + @NettingProcessTableOneName + '
				WHERE netting_group_id = -1 and (item_match_term_month > DATEADD(mm, long_term_months - 1, ''' + @as_of_date + ''') AND all_short_term = ''n'')
				GROUP BY netting_group_id, source_deal_header_id, source_counterparty_id) st ON
				st.netting_group_id = npt.netting_group_id AND st.source_counterparty_id = npt.source_counterparty_id
				AND st.source_deal_header_id = npt.source_deal_header_id
				AND (npt.item_match_term_month > DATEADD(mm, npt.long_term_months - 1, ''' + @as_of_date + ''') AND npt.all_short_term = ''n'')'
EXEC(@sqlSelect)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************LONG TERM assets/liabilities test for GROSS BUCKET*****************************'	
END

--exec ('select * into test_netting_min from ' + @NettingProcessTableOneName)

SET @sqlSelect = 'CREATE TABLE ' + @NettingProcessTableTwoName + ' (
		[Netting_Parent_Group_ID] [INT] NOT NULL,
		[Netting_Parent_Group_Name] [VARCHAR] (100) COLLATE DATABASE_DEFAULT NULL,
		[Netting_Group_ID] [INT] NOT NULL,
		[Netting_Group_Name] [VARCHAR] (100)  COLLATE DATABASE_DEFAULT NULL,
		[Netting_Group_Detail_ID] [INT] NOT NULL,
		[source_deal_header_id] [INT] NOT NULL,
		[item_match_term_month] [DATETIME] NULL,
		[source_counterparty_id] INT NULL,
		[counterparty_name] [VARCHAR] (40) COLLATE DATABASE_DEFAULT NULL,
		[Final_Pnl] [FLOAT] NULL,
		[Long_Term_Months] [INT] NULL,
		[GL_Number_ID_St_Asset] [INT] NULL,
		[GL_Number_ID_ST_Liab] [INT] NULL,
		[GL_Number_ID_Lt_Asset] [INT] NULL,
		[GL_Number_ID_Lt_Liab] [INT] NULL,
		[discount_option] [CHAR](1) COLLATE DATABASE_DEFAULT NULL, 
		[GL_Number_ID] [INT] NULL,
		[Debit_Amount] [FLOAT] NULL,
		[Credit_Amount] [FLOAT] NULL,
		hedge_asset_test INT,
		short_term INT,
		[Tax_GL_Number_ID] [INT] NULL,
		[Tax_Debit_Amount] [FLOAT] NULL,
		[Tax_Credit_Amount] [FLOAT] NULL
	) ON [PRIMARY]'

EXEC(@sqlSelect)

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

SET @sqlSelect = 'INSERT INTO ' + @NettingProcessTableTwoName + '
		SELECT 
		npt.Netting_Parent_Group_ID, 
		MAX(npt.Netting_Parent_Group_Name) Netting_Parent_Group_Name,
		npt.Netting_Group_ID, 
		MAX(npt.Netting_Group_Name) Netting_Group_Name,
		npt.Netting_Group_Detail_ID, 
		npt.source_deal_header_id,
		npt.item_match_term_month, 
		npt.source_counterparty_id,
		MAX(sc.counterparty_name) AS counterparty_name,
		SUM(npt.Final_Und_Pnl) AS Final_Pnl, 
        MAX(npt.Long_Term_Months) AS Long_Term_Months,
		MAX(npt.GL_Number_ID_St_Asset) AS GL_Number_ID_St_Asset,
		MAX(npt.GL_Number_ID_ST_Liab) AS GL_Number_ID_ST_Liab,
		MAX(npt.GL_Number_ID_Lt_Asset) As GL_Number_ID_Lt_Asset,
		MAX(npt.GL_Number_ID_Lt_Liab) As GL_Number_ID_Lt_Liab,
		''u'' AS Discount_Option,
		CASE WHEN(MAX(npt.hedge_asset_test) = 0) THEN 
			CASE WHEN (MAX(npt.short_term) = 1) THEN
				MAX(npt.GL_Number_ID_ST_Liab )
			ELSE
				MAX(npt.GL_Number_ID_Lt_Liab )
			END
		ELSE
			CASE WHEN (MAX(npt.short_term) = 1) THEN
				MAX(npt.GL_Number_ID_ST_Asset )
			ELSE
				MAX(npt.GL_Number_ID_Lt_Asset )
			END
		END AS GL_Number_ID,
		CASE WHEN(MAX(npt.hedge_asset_test) > 0) THEN SUM(npt.Final_Und_Pnl) ELSE 0 END AS Debit_Amount,
		CASE WHEN(MAX(npt.hedge_asset_test) > 0) THEN 0 ELSE SUM(-1 * npt.Final_Und_Pnl) END AS Credit_Amount,
		MAX(npt.hedge_asset_test) hedge_asset_test,
		MAX(npt.short_term) short_term,
		CASE WHEN(MAX(npt.hedge_asset_test) = 0) THEN 
			CASE WHEN (MAX(npt.short_term) = 1) THEN
				MAX(npt.gl_id_st_tax_asset)
			ELSE
				MAX(npt.gl_id_lt_tax_asset)
			END
		ELSE
			CASE WHEN (MAX(npt.short_term) = 1) THEN
				MAX(npt.gl_id_st_tax_liab)
			ELSE
				MAX(npt.gl_id_lt_tax_liab)
			END
		END AS Tax_GL_Number_ID,
		CASE WHEN(MAX(npt.hedge_asset_test) = 0) THEN SUM(-1 * npt.Final_Und_Pnl) * MAX(npt.u_aoci)/MAX(ISNULL(NULLIF(npt.final_und_pnl, 0), 1)) * MAX(tax_perc) ELSE 0 END AS Tax_Debit_Amount,
		CASE WHEN(MAX(npt.hedge_asset_test) = 0) THEN 0 ELSE SUM(npt.Final_Und_Pnl) * MAX(npt.u_aoci)/MAX(ISNULL(NULLIF(npt.final_und_pnl, 0), 1)) * MAX(tax_perc) END AS Tax_Credit_Amount	
FROM  ' + @NettingProcessTableOneName + ' npt 
INNER JOIN source_counterparty sc on sc.source_counterparty_id = npt.source_counterparty_id
GROUP BY npt.Netting_Parent_Group_ID, 
	npt.Netting_Group_ID, 
	npt.Netting_Group_Detail_ID, npt.source_deal_header_id, 
	npt.item_match_term_month, npt.source_counterparty_id
' 

EXEC(@sqlSelect)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Netting of assets/liabities...*****************************'	
END

--IF @print_diagnostic = 1
--	PRINT (@sqlSelect)
IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

SET @sqlSelect = 'INSERT INTO ' + @NettingProcessTableTwoName + '
		SELECT 
		npt.Netting_Parent_Group_ID, 
		MAX(npt.Netting_Parent_Group_Name) Netting_Parent_Group_Name,
		npt.Netting_Group_ID, 
		MAX(npt.Netting_Group_Name) Netting_Group_Name,
		npt.Netting_Group_Detail_ID, 
		npt.source_deal_header_id,
		npt.item_match_term_month, 
		npt.source_counterparty_id,
		MAX(sc.counterparty_name) AS counterparty_name,
		SUM(npt.Final_Dis_Pnl) AS Final_Pnl, 
        MAX(npt.Long_Term_Months) AS Long_Term_Months,
		MAX(npt.GL_Number_ID_St_Asset) AS GL_Number_ID_St_Asset,
		MAX(npt.GL_Number_ID_ST_Liab) AS GL_Number_ID_ST_Liab,
		MAX(npt.GL_Number_ID_Lt_Asset) As GL_Number_ID_Lt_Asset,
		MAX(npt.GL_Number_ID_Lt_Liab) As GL_Number_ID_Lt_Liab,
		''d'' AS Discount_Option,
		CASE WHEN(MAX(npt.d_hedge_asset_test) = 0) THEN 
			CASE WHEN (MAX(npt.short_term) = 1) THEN
				MAX(npt.GL_Number_ID_ST_Liab )
			ELSE
				MAX(npt.GL_Number_ID_Lt_Liab )
			END
		ELSE
			CASE WHEN (MAX(npt.short_term) = 1) THEN
				MAX(npt.GL_Number_ID_ST_Asset )
			ELSE
				MAX(npt.GL_Number_ID_Lt_Asset )
			END
		END AS GL_Number_ID,
		CASE WHEN(MAX(npt.d_hedge_asset_test) > 0) THEN SUM(npt.Final_Dis_Pnl) ELSE 0 END AS Debit_Amount,
		CASE WHEN(MAX(npt.d_hedge_asset_test) > 0) THEN 0 ELSE SUM(-1 * npt.Final_Dis_Pnl) END AS Credit_Amount,
		MAX(npt.d_hedge_asset_test) hedge_asset_test,
		MAX(npt.short_term) short_term,
		CASE WHEN(MAX(npt.d_hedge_asset_test) = 0) THEN 
			CASE WHEN (MAX(npt.short_term) = 1) THEN
				MAX(npt.gl_id_st_tax_asset)
			ELSE
				MAX(npt.gl_id_lt_tax_asset)
			END
		ELSE
			CASE WHEN (MAX(npt.short_term) = 1) THEN
				MAX(npt.gl_id_st_tax_liab)
			ELSE
				MAX(npt.gl_id_lt_tax_liab)
			END
		END AS Tax_GL_Number_ID,
		CASE WHEN(MAX(npt.hedge_asset_test) = 0) THEN SUM(-1*npt.Final_Dis_Pnl)*MAX(npt.u_aoci)/MAX(ISNULL(NULLIF(npt.final_und_pnl, 0), 1))*MAX(tax_perc) ELSE 0 END AS Tax_Debit_Amount,
		CASE WHEN(MAX(npt.hedge_asset_test) = 0) THEN 0 ELSE SUM(npt.Final_Dis_Pnl)*MAX(npt.u_aoci)/MAX(ISNULL(NULLIF(npt.final_und_pnl, 0), 1))*MAX(tax_perc) END AS Tax_Credit_Amount	
FROM  ' + @NettingProcessTableOneName + ' npt 
INNER JOIN source_counterparty sc on sc.source_counterparty_id = npt.source_counterparty_id
GROUP BY npt.Netting_Parent_Group_ID
	, npt.Netting_Group_ID
	, npt.Netting_Group_Detail_ID, npt.source_deal_header_id, 
	npt.item_match_term_month, npt.source_counterparty_id
' 

EXEC(@sqlSelect)

EXEC('CREATE INDEX INDX_NETTINGPROCESSTABLETWONAME_11 ON ' + @NettingProcessTableTwoName+' (Netting_Parent_Group_ID, netting_group_id, GL_Number_ID)')

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Netting of assets/liabities 2 ...*****************************'	
END

IF @drill_tbl_output IS NOT NULL
BEGIN
	--get deal detail info	
	CREATE TABLE #t_ddetail
	(
	source_deal_header_id INT,
	deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
	counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
	netting_counterparty_id INT,
	netting_counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
	counterparty_type VARCHAR(100) COLLATE DATABASE_DEFAULT, 
	source_deal_type_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
	source_deal_sub_type_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
	curve_name VARCHAR(50) COLLATE DATABASE_DEFAULT, 
	commodity_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
	legal_entity_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
	contract_name VARCHAR(50) COLLATE DATABASE_DEFAULT
	)

	EXEC(
	'
	INSERT INTO #t_ddetail
	SELECT d.source_deal_header_id, MAX(sdh.deal_id) deal_id, 
		MAX(nsc.counterparty_name) counterparty_name,
		MAX(COALESCE(sc.netting_parent_counterparty_id, sc.source_counterparty_id)) netting_counterparty_id,
		MAX(sc.counterparty_name) netting_counterparty_name,
		MAX(sdv_et.code) counterparty_type, MAX(sdt.source_deal_type_name) source_deal_type_name,
		MAX(sdts.source_deal_type_name) source_deal_sub_type_name,
		MAX(spcd.curve_name) curve_name, 
		MAX(commodity_name) commodity_name,
		MAX(sle.legal_entity_name) legal_entity_name,
		MAX(cg.contract_name) contract_name
	FROM ' + @NettingDealProcessTableName + ' d INNER JOIN
	source_deal_header sdh on sdh.source_deal_header_id = d.source_deal_header_id LEFT OUTER JOIN
	source_counterparty sc on sc.source_counterparty_id = d.source_counterparty_id LEFT OUTER JOIN
	source_counterparty nsc on nsc.source_counterparty_id = d.orig_source_counterparty_id LEFT OUTER JOIN
	static_data_value sdv_et on sdv_et.value_id = sc.type_of_entity LEFT OUTER JOIN
	source_deal_type sdt on sdt.source_deal_type_id = d.deal_type LEFT OUTER JOIN
	source_deal_type sdts on sdt.source_deal_type_id = d.deal_sub_type LEFT OUTER JOIN
	source_price_curve_def spcd on spcd.source_curve_def_id = d.curve_id LEFT OUTER JOIN 
	source_legal_entity sle on sle.source_legal_entity_id = d.legal_entity LEFT OUTER JOIN 
	contract_group cg on cg.contract_id = d.contract_id LEFT OUTER JOIN
	source_commodity scom on scom.source_commodity_id = spcd.commodity_id
	GROUP BY d.source_deal_header_id
	')

	CREATE INDEX INDX_T_DDETAIL ON #t_ddetail (source_deal_header_id)
	
	CREATE TABLE #drill_other_gl_entries (
	[sub_entity_id] INT,
	[legal_entity] INT,
	[legal_entity_name] VARCHAR(50) COLLATE DATABASE_DEFAULT,
	[Subsidiary] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[Strategy] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[Book] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[gl_number_id] INT,
	[gl_account_number] VARCHAR(150) COLLATE DATABASE_DEFAULT,
	[gl_account_name] VARCHAR(250) COLLATE DATABASE_DEFAULT,
	[link_id] INT,
	[link_deal_flag] VARCHAR(1) COLLATE DATABASE_DEFAULT,
	[term_month] DATETIME, 
	[debit_amount] FLOAT,
	[credit_amount] FLOAT
	) 

	DECLARE @drill_legal_entity INT
	SELECT @drill_legal_entity = legal_entity FROM netting_group_parent WHERE netting_parent_group_id = @drill_netting_parent_group_id

	INSERT #drill_other_gl_entries
	EXEC  spa_Create_MTM_Journal_Entry_Report @as_of_date, NULL , NULL, NULL, @drill_discount_option, 'a', NULL, 'z', 1, NULL, 2, @drill_legal_entity, @drill_gl_number
	
	SET @sqlSelect = '
	SELECT * INTO ' + @drill_tbl_output + '
	FROM (
	SELECT 	cpn.source_deal_header_id [id],
			''d'' link_deal_flag,
			td.deal_id deal_ref_id,
			cpn.item_match_term_month term_month, 
			cpn.Netting_Parent_Group_ID, 
			cpn.Netting_Parent_Group_Name,
			cpn.Netting_Group_Name,
			CASE WHEN (cpn.GL_Number_ID = -1) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.STAsset''' + '
			     WHEN (cpn.GL_Number_ID = -2) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.STLiab''' + '
			     WHEN (cpn.GL_Number_ID = -3) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.LTAsset''' + '
			     WHEN (cpn.GL_Number_ID = -4) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.LTLiab''' + '
			     WHEN (cpn.GL_Number_ID = -5) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.STAsset''' + '
			     WHEN (cpn.GL_Number_ID = -6) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.STLiab''' + '
			     WHEN (cpn.GL_Number_ID = -7) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.LTAsset''' + '
			     WHEN (cpn.GL_Number_ID = -8) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.LTLiab''' + '
			ELSE gsm.gl_account_number END AS gl_account_number,
			substring(CASE WHEN (cpn.GL_Number_ID = -1) THEN  ' + '''STAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -2) THEN  ' + '''STLiab.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -3) THEN  ' + '''LTAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -4) THEN  ' + '''LTLiab.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -5) THEN  ' + '''U.STAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -6) THEN  ' + '''U.STLiab.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -7) THEN  ' + '''U.LTAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -8) THEN  ' + '''U.LTLiab.''' + ' + cpn.counterparty_name
			ELSE gsm.gl_account_name END, 1, 250) AS gl_account_name,
			cpn.Final_Pnl deal_mtm,
			cpn.Debit_amount AS Debit_Amount,
			cpn.Credit_amount AS Credit_Amount,
			hedge_asset_test,
			short_term as short_term_test, 
			td.counterparty_name,
			td.netting_counterparty_name,
			td.counterparty_type, 
			td.source_deal_type_name,
			td.source_deal_sub_type_name,
			td.curve_name, 
			td.commodity_name,
			td.legal_entity_name,
			td.contract_name agreement_name,
			cpn.GL_Number_ID, td.netting_counterparty_id
		FROM ' + @NettingProcessTableTwoName + ' cpn (NOLOCK) INNER JOIN
			#t_ddetail td on td.source_deal_header_id = cpn.source_deal_header_id LEFT OUTER JOIN
			gl_system_mapping gsm ON cpn.GL_Number_ID = gsm.gl_number_id
		WHERE cpn.Discount_Option = ''' + @drill_discount_option + ''' AND cpn.Netting_Parent_Group_ID = ' + CAST(@drill_netting_parent_group_id AS VARCHAR)  + 	
	'
	UNION
	SELECT	g.link_id [id], g.link_deal_flag, d.deal_id deal_ref_id, g.term_month, NULL Netting_Parent_Group_ID, NULL Netting_Parent_Group_Name, NULL Netting_Group_Name, 
			g.gl_account_number, g.gl_account_name, NULL deal_mtm, g.debit_amount, g.credit_amount, NULL hedge_asset_test, NULL short_term_test, 
			d.counterparty_name, d.netting_counterparty_name, d.counterparty_type, d.source_deal_type_name, d.source_deal_sub_type_name,
			d.curve_name, d.commodity_name, ISNULL(d.legal_entity_name, g.legal_entity_name), d.contract_name agreement_name, g.gl_number_id GL_Number_ID,d.netting_counterparty_id
	FROM #net_parent_group npg INNER JOIN 
		 #drill_other_gl_entries g ON npg.netting_parent_group_id = ' + CAST(@drill_netting_parent_group_id AS VARCHAR)  + ' AND npg.fas_subsidiary_id = g.sub_entity_id LEFT OUTER JOIN
		 #t_ddetail d on g.link_id = d.source_deal_header_id and g.link_deal_flag = ''d''
	) x WHERE 1=1 ' +
	CASE WHEN (@drill_counterparty_id IS NOT NULL) THEN ' and x.netting_counterparty_id = ' + CAST(@drill_counterparty_id AS VARCHAR) ELSE '' END
	+ CASE WHEN(@drill_gl_number IS NULL) THEN '' ELSE ' and  gl_account_number IN (' + @drill_gl_number_quote + ')' END
	+ ' ORDER BY  gl_account_number, deal_ref_id'

--	PRINT @sqlSelect
	EXEC(@sqlSelect)
	RETURN
END


--IF @print_diagnostic = 1
--	PRINT (@sqlSelect)

-- move up code block of delete
IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

SET @sqlSelect =
'
	DELETE report_netted_gl_entry 
    FROM report_netted_gl_entry  rnge 
	INNER JOIN #process_parent_group ppg ON ppg.netting_parent_group_id = rnge.netting_parent_group_id 
		AND rnge.as_of_date BETWEEN CONVERT(DATETIME, ''' + dbo.FNAGetContractMonth(@as_of_date) + ''', 102) 
		AND CONVERT(DATETIME, ''' + dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(@as_of_date)) + ''', 102) 
'

EXEC(@sqlSelect)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Deleting from result table (report_netted_gl_entry)...*****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

SET @sqlSelect = '
		INSERT INTO report_netted_gl_entry (as_of_date, netting_parent_group_id, netting_parent_group_name, 
			netting_group_name, gl_number, gl_account_name, debit_amount, credit_amount, 
                      discount_option, create_user, create_ts)
		SELECT '''+ @as_of_date + ''', cpn.Netting_Parent_Group_ID, 
			MAX(cpn.Netting_Parent_Group_Name) Netting_Parent_Group_Name,
			MAX(cpn.Netting_Group_Name) Netting_Group_Name,
			CASE WHEN (cpn.GL_Number_ID = -1) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.STAsset''' + '
			     WHEN (cpn.GL_Number_ID = -2) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.STLiab''' + '
			     WHEN (cpn.GL_Number_ID = -3) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.LTAsset''' + '
			     WHEN (cpn.GL_Number_ID = -4) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.LTLiab''' + '
			     WHEN (cpn.GL_Number_ID = -5) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.STAsset''' + '
			     WHEN (cpn.GL_Number_ID = -6) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.STLiab''' + '
			     WHEN (cpn.GL_Number_ID = -7) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.LTAsset''' + '
			     WHEN (cpn.GL_Number_ID = -8) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.LTLiab''' + '
			ELSE gsm.gl_account_number END AS gl_account_number,
			substring(CASE WHEN (cpn.GL_Number_ID = -1) THEN  ' + '''STAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -2) THEN  ' + '''STLiab.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -3) THEN  ' + '''LTAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -4) THEN  ' + '''LTLiab.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -5) THEN  ' + '''U.STAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -6) THEN  ' + '''U.STLiab.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -7) THEN  ' + '''U.LTAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -8) THEN  ' + '''U.LTLiab.''' + ' + cpn.counterparty_name
			ELSE gsm.gl_account_name END, 1, 250) AS gl_account_name,
			SUM(cpn.Debit_amount) AS Debit_Amount,
			SUM(cpn.Credit_amount) AS Credit_Amount,
			cpn.Discount_Option,
			''' + @user_login_id + ''' AS create_user,
			GETDATE() create_ts 
		FROM ' +
			@NettingProcessTableTwoName + ' cpn (NOLOCK)
			LEFT OUTER JOIN
			gl_system_mapping gsm
			ON cpn.GL_Number_ID = gsm.gl_number_id
		GROUP BY
			cpn.Netting_Parent_Group_ID, 
			cpn.netting_group_id,
			CASE WHEN (cpn.GL_Number_ID = -1) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.STAsset''' + '
			     WHEN (cpn.GL_Number_ID = -2) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.STLiab''' + '
			     WHEN (cpn.GL_Number_ID = -3) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.LTAsset''' + '
			     WHEN (cpn.GL_Number_ID = -4) THEN  CAST(cpn.source_counterparty_id AS VARCHAR)  + 
					''.'' + CAST(cpn.Netting_Group_ID AS VARCHAR) + ''' + '.LTLiab''' + '
			     WHEN (cpn.GL_Number_ID = -5) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.STAsset''' + '
			     WHEN (cpn.GL_Number_ID = -6) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.STLiab''' + '
			     WHEN (cpn.GL_Number_ID = -7) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.LTAsset''' + '
			     WHEN (cpn.GL_Number_ID = -8) THEN  CAST(cpn.source_counterparty_id AS VARCHAR) + ''.U.LTLiab''' + '
			ELSE gsm.gl_account_number END,
			CASE WHEN (cpn.GL_Number_ID = -1) THEN  ' + '''STAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -2) THEN  ' + '''STLiab.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -3) THEN  ' + '''LTAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -4) THEN  ' + '''LTLiab.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -5) THEN  ' + '''U.STAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -6) THEN  ' + '''U.STLiab.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -7) THEN  ' + '''U.LTAsset.''' + ' + cpn.counterparty_name
			     WHEN (cpn.GL_Number_ID = -8) THEN  ' + '''U.LTLiab.''' + ' + cpn.counterparty_name
			ELSE gsm.gl_account_name END,
			cpn.Discount_Option'

EXEC (@sqlSelect)

---This is AOCI tax asset/liabilities entries
SET @sqlSelect = '
		INSERT INTO report_netted_gl_entry (as_of_date, netting_parent_group_id, netting_parent_group_name, 
			netting_group_name, gl_number, gl_account_name, debit_amount, credit_amount, 
                      discount_option, create_user, create_ts)
		SELECT '''+ @as_of_date + ''', cpn.Netting_Parent_Group_ID, 
			MAX(cpn.Netting_Parent_Group_Name) Netting_Parent_Group_Name,
			MAX(cpn.Netting_Group_Name) Netting_Group_Name,
			CASE WHEN (cpn.Tax_GL_Number_ID = -9) THEN  ''9.Unknown.TaxSTAsset''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -10) THEN  ''10.Unknown.TaxSTLiab''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -11) THEN  ''11.Unknown.TaxLTAsset''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -12) THEN  ''12.Unknown.TaxLTLiab''' + '
			ELSE gsm.gl_account_number END AS gl_account_number,
			CASE WHEN (cpn.Tax_GL_Number_ID = -9) THEN  ''9.Unknown.TaxSTAsset''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -10) THEN  ''10.Unknown.TaxSTLiab''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -11) THEN  ''11.Unknown.TaxLTAsset''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -12) THEN  ''12.Unknown.TaxLTLiab''
			ELSE gsm.gl_account_name END AS gl_account_name,
			SUM(cpn.Tax_Debit_amount) AS Debit_Amount,
			SUM(cpn.Tax_Credit_amount) AS Credit_Amount,
			cpn.Discount_Option,
			''' + @user_login_id + ''' AS create_user,
			GETDATE() create_ts 
		FROM ' +
			@NettingProcessTableTwoName + ' cpn (NOLOCK)
			LEFT OUTER JOIN
			gl_system_mapping gsm
			ON cpn.Tax_GL_Number_ID = gsm.gl_number_id
		GROUP BY
			cpn.Netting_Parent_Group_ID, 
			cpn.netting_group_id,
			CASE WHEN (cpn.Tax_GL_Number_ID = -9) THEN  ''9.Unknown.TaxSTAsset''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -10) THEN  ''10.Unknown.TaxSTLiab''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -11) THEN  ''11.Unknown.TaxLTAsset''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -12) THEN  ''12.Unknown.TaxLTLiab''' + '
			ELSE gsm.gl_account_number END,
			CASE WHEN (cpn.Tax_GL_Number_ID = -9) THEN  ''9.Unknown.TaxSTAsset''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -10) THEN  ''10.Unknown.TaxSTLiab''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -11) THEN  ''11.Unknown.TaxLTAsset''' + '
			     WHEN (cpn.Tax_GL_Number_ID = -12) THEN  ''12.Unknown.TaxLTLiab''
			ELSE gsm.gl_account_name END,
			cpn.Discount_Option
		HAVING 	SUM(cpn.Tax_Debit_amount) <> 0 OR
				SUM(cpn.Tax_Credit_amount) <> 0
			'

IF @aoci_tax_asset_liab = '1'
	EXEC (@sqlSelect)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************Netting of assets/liabities FINAL1 ...*****************************'	
END

--IF @print_diagnostic = 1
--	PRINT (@sqlSelect)
-- 
-- drop table #d_other_gl_entries
-- drop table #u_other_gl_entries

CREATE TABLE #d_other_gl_entries
(
	[sub_entity_id] INT,
	[legal_entity] INT,
	[gl_account_number] VARCHAR(150) COLLATE DATABASE_DEFAULT,
	[gl_account_name] VARCHAR(250) COLLATE DATABASE_DEFAULT,
	[debit_amount] FLOAT,
	[credit_amount] FLOAT
) 

CREATE TABLE #u_other_gl_entries
(
	[sub_entity_id] INT,
	[legal_entity] INT,
	[gl_account_number] VARCHAR(150) COLLATE DATABASE_DEFAULT,
	[gl_account_name] VARCHAR(250) COLLATE DATABASE_DEFAULT,
	[debit_amount] FLOAT,
	[credit_amount] FLOAT
) 

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
end

INSERT #u_other_gl_entries
EXEC  spa_Create_MTM_Journal_Entry_Report @as_of_date, NULL , NULL, NULL, 'u', 'a', NULL, 's', 1

IF @print_diagnostic = 1
BEGIN
		PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************Retrieve undiscounted journal entry value...*****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

INSERT #d_other_gl_entries
EXEC  spa_Create_MTM_Journal_Entry_Report @as_of_date, NULL , NULL, NULL, 'd', 'a', NULL, 's', 1

--select * from #u_other_gl_entries
--select * from #d_other_gl_entries

IF @print_diagnostic = 1
BEGIN
		PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************Retrieve discounted journal entry value...*****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

CREATE INDEX IX_D_OTHER_GL_ENTRIES  ON #d_other_gl_entries (legal_entity)
CREATE INDEX IX_U_OTHER_GL_ENTRIES  ON #u_other_gl_entries (legal_entity)


INSERT INTO report_netted_gl_entry (as_of_date, netting_parent_group_id, netting_parent_group_name, 
									netting_group_name, gl_number, gl_account_name, debit_amount, 
									credit_amount, discount_option, create_user, create_ts)
SELECT @as_of_date, npg.Netting_Parent_Group_ID, 
		npg.Netting_Parent_Group_Name,
		NULL AS Netting_Group_Name,
		gsm.gl_account_number,
		substring(gsm.gl_account_name, 1, 250) gl_account_name,
		ISNULL(gsm.Debit_Amount, 0) Debit_Amount,
		ISNULL(gsm.Credit_Amount, 0) Credit_Amount,
		'u',@user_login_id ,GETDATE() create_ts 
FROM #net_parent_group npg 
INNER JOIN #u_other_gl_entries gsm ON gsm.sub_entity_id = npg.fas_subsidiary_id 
	AND  (npg.legal_entity IS NULL OR ISNULL(gsm.legal_entity, -1) = ISNULL(npg.legal_entity, -2))

IF @print_diagnostic = 1
BEGIN
		PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************Inserting undiscounted values in final netting table...*****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

INSERT INTO report_netted_gl_entry (as_of_date, netting_parent_group_id, netting_parent_group_name, 
		netting_group_name, gl_number, gl_account_name, debit_amount, credit_amount, 
                    discount_option, create_user, create_ts)
	SELECT @as_of_date, npg.Netting_Parent_Group_ID, 
	npg.Netting_Parent_Group_Name,
	NULL as Netting_Group_Name,
	gsm.gl_account_number,
	substring(gsm.gl_account_name, 1, 250) gl_account_name,
	ISNULL(gsm.Debit_Amount, 0) Debit_Amount,
	ISNULL(gsm.Credit_Amount, 0) Credit_Amount,
	'd', @user_login_id,
	GETDATE() create_ts 
FROM #net_parent_group npg 
INNER JOIN #d_other_gl_entries gsm ON gsm.sub_entity_id = npg.fas_subsidiary_id 
	AND  (npg.legal_entity IS NULL OR ISNULL(gsm.legal_entity, -1) = ISNULL(npg.legal_entity, -2))

IF @print_diagnostic = 1
BEGIN
		PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************Inserting discounted values in final netting table...*****************************'	
END

-----DROP ALL PROCESS TABLES -----------
IF @print_diagnostic = 0
BEGIN
	DECLARE @deleteStmt VARCHAR(500)

	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@NettingProcessTableOneName)
	--PRINT(@deleteStmt)
	EXEC (@deleteStmt)
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@NettingProcessTableTwoName)
	--PRINT(@deleteStmt)
	--	exec (@deleteStmt)
	--	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@NettingProcessTableFinalName)
	--PRINT(@deleteStmt)
	EXEC (@deleteStmt)

	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@NettingDealProcessTableName)
	--PRINT(@deleteStmt)
	EXEC(@deleteStmt)
END

GO