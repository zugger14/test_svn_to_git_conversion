
/****** Object:  StoredProcedure [dbo].[spa_Create_MTM_Journal_Entry_Report]    Script Date: 09/26/2011 13:53:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_Create_MTM_Journal_Entry_Report]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_Create_MTM_Journal_Entry_Report]
GO

/****** Object:  StoredProcedure [dbo].[spa_Create_MTM_Journal_Entry_Report]    Script Date: 02/13/2012 20:59:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec spa_Create_MTM_Journal_Entry_Report_Reverse '2004-12-31', '30', '208', '223', 'd', NULL, 'a', 'z', 'n', NULL, NULL,NULL, '2',NULL,NULL, '1-10-20-19 ', 'into adiha_process.dbo.tt1123'
-- EXEC  spa_Create_MTM_Journal_Entry_Report '2005-03-31', NULL , NULL, NULL, 'u', 'a', NULL, 's', 1
--exec spa_Create_MTM_Journal_Entry_Report '2005-03-31', '30', NULL, '223', 'd', null, 'a', 's', 1, NULL, '2', NULL
-- exec spa_Create_MTM_Journal_Entry_Report '2005-10-31', '30', NULL, NULL, 'd', null, 'a', 's', 0, NULL, '2', 2
--select * from report_measurement_values where link_id = -294 and as_of_date = '2004-12-31'

----exec spa_Create_MTM_Journal_Entry_Report '2005-03-31', '30,1,257,258,256', NULL, NULL, 'd', 'a', 'a', 's', 'n', NULL

-- @called_from_netting= 0 means it is not called from netting, if 1 it means called from netting
-- and get all entries except for asset/liabilities, 2 means called from netting and get all entries
-- including assets/liabilties
CREATE PROC [dbo].[spa_Create_MTM_Journal_Entry_Report] 
	@as_of_date VARCHAR(50), 
	@sub_entity_id VARCHAR(8000), 
	@strategy_entity_id VARCHAR(8000) = NULL, 
	@book_entity_id VARCHAR(8000) = NULL, 
	@discount_option CHAR(1), 
	@settlement_option CHAR(1),  --'f' forward only,  'c' current and forward, 's' settled only, 'a' all, NULL use from strategy property
	@report_type CHAR(1), 
	@summary_option CHAR(1),
 	@called_from_netting INT = 0,
	@link_id VARCHAR(500) = NULL,	
	@round_value CHAR(1) = '0',
	@legal_entity INT = NULL,
	@drill_gl_number VARCHAR(5000) = NULL,
	@batch_table_name VARCHAR(128) = NULL

AS
SET NOCOUNT ON 
--==================================Begin of test cases-----------------------------
/*

IF OBJECT_ID('tempdb..#temp_MTM_JEP') IS NOT NULL
	DROP TABLE #temp_MTM_JEP  
	
IF OBJECT_ID('tempdb..#links') IS NOT NULL
	DROP TABLE #links  
	
IF OBJECT_ID('tempdb..#temp') IS NOT NULL
	DROP TABLE #temp  
	
IF OBJECT_ID('tempdb..#ssbm_b') IS NOT NULL
	DROP TABLE #ssbm_b  
	
IF OBJECT_ID('tempdb..#temp_cash') IS NOT NULL
	DROP TABLE #temp_cash  
	
 --drop table #interest_expense
IF OBJECT_ID('tempdb..#basis_adjustments') IS NOT NULL 
	DROP TABLE #basis_adjustments  
	
IF OBJECT_ID('tempdb..#calcprocess_deals') IS NOT NULL
	DROP TABLE #calcprocess_deals  
	
IF OBJECT_ID('tempdb..#calcprocess_aoci_release') IS NOT NULL
	DROP TABLE #calcprocess_aoci_release  
	
IF OBJECT_ID('tempdb..#cd') IS NOT NULL
	DROP TABLE #cd  
 
DECLARE @as_of_date VARCHAR(50), @sub_entity_id VARCHAR(100),   
		@strategy_entity_id VARCHAR(100),   
		@book_entity_id VARCHAR(100), @discount_option CHAR(1),   
		@settlement_option CHAR(1), @report_type CHAR(1), @summary_option CHAR(1),  
		@called_from_netting INT,  
		@link_id VARCHAR(500), @legal_entity INT, @round_value VARCHAR(1),  
		@drill_gl_number VARCHAR(2000), @batch_table_name VARCHAR(100)  
--EXEC spa_Create_MTM_Journal_Entry_Report	'2013-03-31',400,NULL,NULL,'d','f','a','d',0,5159,2,NULL
 
SET @as_of_date= '2013-7-31' --'2006-12-31'  
SET  @sub_entity_id ='4'--'78,118,91,168,75,52,24,4,82,128,72,164,69,88,104,85'  
SET @strategy_entity_id = NULL -- '803' --'317'  
SET @book_entity_id  = NULL --'224' --'209' --'224' --'223'   
SET @discount_option ='d'
SET @settlement_option = 'f'  
SET @report_type ='a'  
SET @summary_option ='d' --'z'
SET @called_from_netting = 0  
SET @link_id = '8928' -- '464,1183'
SET @legal_entity = NULL  
SET @round_value = '2'  
--set @drill_gl_number = NULL
SET @batch_table_name = NULL  
--*/
----==================================End of test cases-----------------------------

DECLARE @Sql_Select VARCHAR(8000)
DECLARE @Sql_Select1 VARCHAR(8000)
DECLARE @Sql_From VARCHAR(5000)
DECLARE @Sql_Where VARCHAR(5000)
DECLARE @Sql_Where1 VARCHAR(5000)
DECLARE @Sql_Where2 VARCHAR(5000)
DECLARE @Sql_Where3l VARCHAR(5000)
DECLARE @Sql_Where3d VARCHAR(5000)
DECLARE @drill_gl_number_quote VARCHAR(5000)
DECLARE @Sql_GpBy VARCHAR(5000)
DECLARE @Sql VARCHAR(5000)

IF @called_from_netting IS NULL
	SET @called_from_netting = 0

IF @settlement_option IS NULL
	SET @settlement_option = 'n'

IF @drill_gl_number IS NOT NULL
	SET @drill_gl_number_quote = '''' + REPLACE (REPLACE(@drill_gl_number, ' ', ''), ',' , ''',''') + ''''

--Default GL code for undefined ones
DECLARE @st_asset_gl_id VARCHAR(3)
DECLARE @st_liability_gl_id VARCHAR(3)
DECLARE @lt_asset_gl_id VARCHAR(3)
DECLARE @lt_liability_gl_id VARCHAR(3)
DECLARE @st_item_asset_gl_id VARCHAR(3)
DECLARE @st_item_liability_gl_id VARCHAR(3)
DECLARE @lt_item_asset_gl_id VARCHAR(3)
DECLARE @lt_item_liability_gl_id VARCHAR(3)
DECLARE @st_tax_asset_gl_id VARCHAR(3)
DECLARE @st_tax_liability_gl_id VARCHAR(3)
DECLARE @lt_tax_asset_gl_id VARCHAR(3)
DECLARE @lt_tax_liability_gl_id VARCHAR(3)
DECLARE @un_st_asset_gl_id VARCHAR(3) 
DECLARE @un_st_liability_gl_id VARCHAR(3)
DECLARE @un_lt_asset_gl_id VARCHAR(3)
DECLARE @un_lt_liability_gl_id VARCHAR(3)

DECLARE @tax_reserve VARCHAR(3)
DECLARE @pnl_set VARCHAR(3)
DECLARE @aoci VARCHAR(3)
DECLARE @total_pnl VARCHAR(3)
DECLARE @inventory VARCHAR(3)
DECLARE @cash VARCHAR(3)
DECLARE @cashS VARCHAR(3)
DECLARE @interestA VARCHAR(3)
DECLARE @interestE VARCHAR(3)
DECLARE @amortization VARCHAR(3)

SET  @st_asset_gl_id = '-1' 
SET  @st_liability_gl_id = '-2'
SET  @lt_asset_gl_id = '-3'
SET  @lt_liability_gl_id = '-4'
SET  @st_item_asset_gl_id = '-5'
SET  @st_item_liability_gl_id = '-6'
SET  @lt_item_asset_gl_id = '-7'
SET  @lt_item_liability_gl_id = '-8'
SET  @st_tax_asset_gl_id = '-9'
SET  @st_tax_liability_gl_id = '-10'
SET  @lt_tax_asset_gl_id = '-11'
SET  @lt_tax_liability_gl_id = '-12'
SET  @tax_reserve = '-13'
SET  @pnl_set = '-14'
SET  @aoci = '-15'
SET  @total_pnl = '-16'
SET  @inventory = '-17'
SET  @cash = '-18'
SET  @cashS = '-19'
SET  @interestA = '-20'
SET  @interestE = '-21'
SET  @amortization = '-22'

/* added for un headged */
  
SET  @un_st_asset_gl_id = '-23' 
SET  @un_st_liability_gl_id = '-24'
SET  @un_lt_asset_gl_id = '-25'
SET  @un_lt_liability_gl_id = '-26'

/* added for un headged */

DECLARE @aoci_tax_asset_liab VARCHAR(1)
SELECT @aoci_tax_asset_liab = var_value FROM adiha_default_codes_values
WHERE instance_no = 1 AND seq_no = 1 AND default_code_id = 39

IF @aoci_tax_asset_liab IS NULL
	SET @aoci_tax_asset_liab = '0'

DECLARE @Sql_SelectB VARCHAR(5000)        
DECLARE @Sql_WhereB VARCHAR(5000)        
DECLARE @assignment_type INT        
DECLARE @sql_stmt VARCHAR (MAX)

SET @Sql_WhereB = ''   

CREATE TABLE #ssbm_b(fas_book_id INT, gl_tenor_option VARCHAR(1) COLLATE DATABASE_DEFAULT   NULL, legal_entity INT NULL, gl_dedesig_aoci INT NULL, gl_grouping_value_id INT NULL)        

SET @Sql_SelectB = 'INSERT INTO #ssbm_b        
					SELECT	DISTINCT book.entity_id, gl_tenor_option fas_book_id, legal_entity, coalesce(fb.gl_number_id_expense
							, fb.gl_number_id_aoci, fs.gl_number_id_aoci), fs.gl_grouping_value_id
					FROM portfolio_hierarchy book (nolock) 
					INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id  
					INNER JOIN fas_strategy fs on fs.fas_strategy_id = stra.entity_id 
					 INNER JOIN fas_books fb on fb.fas_book_id = book.entity_id  '     
              
IF @sub_entity_id IS NOT NULL        
	SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '    
	     
IF @strategy_entity_id IS NOT NULL        
	SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        
	
IF @book_entity_id IS NOT NULL        
	SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        

--WhatIf Changes (Only include non-hypotheical for WHEN called from netting logic)
--For now journal entry will always remove hypothetical links
SET @Sql_WhereB = @Sql_WhereB + ' AND (fb.no_link IS NULL OR fb.no_link = ''n'') '        
SET @Sql_SelectB = @Sql_SelectB + @Sql_WhereB
        
--PRINT @Sql_SelectB       
EXEC (@Sql_SelectB)


CREATE TABLE [#temp_MTM_JEP] (
	[as_of_date] [DATETIME] NOT NULL ,
	[sub_entity_id] [INT] NULL ,
	[strategy_entity_id] [INT] NULL ,
	[book_entity_id] [INT] NULL ,
	--[link_id] [int] NULL,
	[link_id] VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
	[link_deal_flag] VARCHAR(1) COLLATE DATABASE_DEFAULT  ,
	[term_month] [DATETIME] NULL ,
	[legal_entity] [INT] NULL,
	source_book_map_id INT NULL, 
	[Gl_Number] [INT] NULL ,
	[Debit] [FLOAT] NOT NULL ,
							 [Credit] [FLOAT] NULL )   

CREATE TABLE #links(link_id VARCHAR(500) COLLATE DATABASE_DEFAULT  )

----include deals that are dedsignated 
IF @link_id IS NOT NULL
BEGIN
		EXEC ('INSERT INTO #links
				SELECT CAST(source_deal_header_id AS VARCHAR) + ''d'' 
				FROM source_deal_header where source_deal_header_id IN (' + @link_id + ')
				UNION
				SELECT CAST(source_deal_header_id AS VARCHAR) + ''d'' 
				FROM fas_link_detail where hedge_or_item = ''h'' AND link_id IN (' + @link_id + ')
				AND percentage_included <> 0
				UNION
				SELECT CAST(link_id AS VARCHAR) + ''l'' 
				FROM fas_link_header where link_id in (' + @link_id + ')')
END

-------------------THE FOLLOWING ARE THE IR related Interest Entries--------------------------------
SELECT ba.*, 
		ISNULL(CASE WHEN(sb.gl_grouping_value_id = 350) THEN fs.gl_id_amortization ELSE fb.gl_id_amortization END, @amortization) Gl_Amortization_Expense,
		CASE WHEN (dbo.FNAShortTermTest(@as_of_date, sdh.entire_term_start, sub.long_term_months) < 1) THEN -- st term
			CASE WHEN (header_buy_sell_flag = 'b') THEN --liability
				ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_item_st_liab ELSE fb.gl_number_id_item_st_liab END, @st_item_liability_gl_id)			
			ELSE
				ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_item_st_asset ELSE fb.gl_number_id_item_st_asset END, @st_item_asset_gl_id)			
			END
		ELSE
			CASE WHEN (header_buy_sell_flag = 'b') THEN --liability
				ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_item_lt_liab ELSE fb.gl_number_id_item_lt_liab END, @lt_item_liability_gl_id)				
			ELSE
				ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_item_lt_asset ELSE fb.gl_number_id_item_lt_asset END, @lt_item_asset_gl_id)			
			END
		END  Gl_item,
		stra.parent_entity_id sub_entity_id,
		fs.fas_strategy_id strategy_entity_id,
		ssbm.fas_book_id book_entity_id,
		COALESCE(fb.legal_entity, sdh.legal_entity) legal_entity
	INTO #basis_adjustments
FROM #ssbm_b sb 
INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = sb.fas_book_id 
INNER JOIN source_deal_header sdh ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
	AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
	AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 
	AND sdh.source_system_book_id4 = ssbm.source_system_book_id4 
INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id 
INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
INNER JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id 
INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id 
INNER JOIN fas_subsidiaries sub ON sub.fas_subsidiary_id = stra.parent_entity_id 
INNER JOIN basis_adjustments ba ON ba.source_deal_header_id = sdh.source_deal_header_id 
LEFT OUTER JOIN (SELECT source_deal_header_id source_deal_header_id1 
				FROM fas_link_Detail WHERE CAST(link_id AS VARCHAR) + 'l' = (SELECT link_id FROM #links) AND hedge_or_item = 'i'
				) link ON link.source_deal_header_id1 = sdh.source_deal_header_id
WHERE as_of_date <= @as_of_date AND fs.hedge_type_value_id = 151 AND isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 401
	AND ((link.source_deal_header_id1 IS NULL AND @link_id IS NULL) 
	OR (link.source_deal_header_id1 IS NOT NULL AND @link_id IS NOT NULL))


INSERT INTO #temp_MTM_JEP
SELECT	@as_of_date as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, 
		source_deal_header_id, 'd' link_deal_flag, 
		dbo.FNAContractMonthFormat(as_of_date) + '-01' term_start,
		legal_entity, NULL source_book_map_id, Gl_Amortization_Expense Gl_Number, 
		CASE WHEN (PMT >= 0) THEN PMT ELSE 0 END Debit,
		CASE WHEN (PMT < 0) THEN -1 * PMT ELSE 0 END Credit
FROM #basis_adjustments

INSERT INTO #temp_MTM_JEP
SELECT	@as_of_date as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, 
		source_deal_header_id, 'd' link_deal_flag, 
		dbo.FNAContractMonthFormat(as_of_date) + '-01' term_start,
		legal_entity, NULL source_book_map_id, Gl_Item Gl_Number, 
		CASE WHEN (PMT < 0) THEN -1 * PMT ELSE 0 END Debit,
		CASE WHEN (PMT >= 0) THEN PMT ELSE 0 END Credit
FROM #basis_adjustments


-------------------THE FOLLOWING ARE THE CASH RECONCILLATION ENTRIES--------------------------------

SELECT  @as_of_date as_of_date, sub.entity_id sub_entity_id, stra.entity_id strategy_entity_id, 
		book.entity_id book_entity_id, sdcs.source_deal_header_id link_id, sdcs.term_start term_month,
		COALESCE(fb.legal_entity, sdh.legal_entity) legal_entity, 
		NULL Gl_Number_Cash_Received,
		ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_gross_set ELSE fb.gl_number_id_gross_set END, @pnl_set) Gl_Number_Earnings,
		ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_cash ELSE fb.gl_number_id_cash END, @cash) Gl_Number_Receivable,
		ISNULL(sdcs.cash_settlement, 0) cash_settlement, ISNULL(sdcs.cash_received, 0) cash_received, 
		ISNULL(sdcs.cash_variance, 0) cash_variance
INTO #temp_cash		
FROM source_deal_cash_settlement sdcs 
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdcs.source_deal_header_id 
INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
	AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
	AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 
	AND sdh.source_system_book_id4 = ssbm.source_system_book_id4 
INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id 
INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
INNER JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id 
INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id 
INNER JOIN #ssbm_b sb ON sb.fas_book_id = fb.fas_book_id 
WHERE isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 400 AND sdcs.as_of_date <= dbo.FNAGetContractMonth(@as_of_date)

INSERT INTO #temp_MTM_JEP
SELECT	as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, 'd' link_deal_flag, term_month,
		legal_entity, NULL source_book_map_id, Gl_Number_Receivable Gl_Number, 
		CASE WHEN (cash_variance >= 0) THEN cash_variance ELSE 0 END Debit,
		CASE WHEN (cash_variance < 0) THEN -1 * cash_variance ELSE 0 END Credit
FROM #temp_cash

INSERT INTO #temp_MTM_JEP
SELECT	as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, 'd' link_deal_flag, term_month,
		legal_entity, NULL source_book_map_id, Gl_Number_Earnings Gl_Number, 
		CASE WHEN (cash_variance < 0) THEN -1 * cash_variance ELSE 0 END Debit,
		CASE WHEN (cash_variance >= 0) THEN cash_variance ELSE 0 END Credit
FROM #temp_cash

---------------------------------END OF CASH RECONCILLATION ENTRIES ----------------------------

-------------------------------THE FOLLOWING ARE MANUAL ADJUSTEMENT ENTRIES --------------------
INSERT INTO #temp_MTM_JEP
SELECT	@as_of_date as_of_date, st.parent_entity_id sub_entity_id, st.entity_id strategy_entity_id, 
		b.entity_id book_entity_id, NULL link_id, 'd' link_deal_flag, NULL term_month, fb.legal_entity, NULL source_book_map_id,
		mjd.gl_number_id Gl_Number, ISNULL(debit_amount, 0) Debit, ISNULL(credit_amount, 0) Credit
FROM manual_je_header mjh 
INNER JOIN	manual_je_detail mjd ON mjd.manual_je_id = mjh.manual_je_id 
LEFT OUTER JOIN	portfolio_hierarchy b ON b.entity_id = mjh.book_id 
LEFT OUTER JOIN	fas_books fb ON fb.fas_book_id = b.entity_id 
LEFT OUTER JOIN	portfolio_hierarchy st ON st.entity_id = b.parent_entity_id
WHERE (mjh.as_of_date <= @as_of_date AND ISNULL(mjd.frequency, mjh.frequency) = 'r' 
	AND	@as_of_date <= COALESCE(mjd.until_date, mjh.until_date, @as_of_date)) 
	OR (mjh.as_of_date = @as_of_date AND ISNULL(mjd.frequency, mjh.frequency) = 'o')
---------------------------------END OF MANUAL ADJUSTMENT ENTRIES ------------------------------

--SET @Sql_From = ' FROM report_measurement_values RMV INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id'	 				
SET @Sql_From = ' FROM #temp RMV '	 				
--=======Undiscounted==========================================================================================

--The following will retrieve the most recent cumulative values from  the report measurement values table
SELECT *, CAST(NULL AS VARCHAR) gl_tenor_option , CAST(NULL AS VARCHAR) legal_entity, CAST(NULL AS INT) gl_dedesig_aoci
		, CAST(NULL AS INT) source_book_map_id
	INTO #temp 
FROM report_measurement_values  WHERE 1 = 2  

DECLARE @insert_stmt VARCHAR(8000)
DECLARE @insert_stmt2 VARCHAR(8000)
DECLARE @term_stmt VARCHAR(1000)
DECLARE @term_stmt1 VARCHAR(1000)

SELECT *, CAST(NULL AS INT) gl_dedesig_aoci INTO #calcprocess_deals FROM calcprocess_deals WHERE 1 = 2
SELECT * INTO #calcprocess_aoci_release FROM calcprocess_aoci_release WHERE 1 = 2

SET @insert_stmt = 'INSERT INTO #calcprocess_deals
					SELECT rmv.*, gl_dedesig_aoci FROM '+ dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + '  rmv 
					INNER  JOIN (select fas_book_id, gl_tenor_option, legal_entity, gl_dedesig_aoci 
					             FROM #ssbm_b 
								 WHERE gl_grouping_value_id = 352
					            ) books ON books.fas_book_id = rmv.fas_book_id
									AND rmv.as_of_date = ''' + @as_of_date  + ''''	

SET @term_stmt = ' WHERE 1 = 1 ' 

SET @insert_stmt2 = ''
IF @link_id IS NOT NULL
	SET @insert_stmt2 = @insert_stmt2 + ' AND ((CAST(RMV.link_id AS VARCHAR) + SUBSTRING(RMV.link_type, 1,1)) IN (SELECT link_id FROM #links)) ' 	

IF @called_from_netting IN (1, 2) OR @report_type IS  NULL
BEGIN
	SET @insert_stmt2 = @insert_stmt2 + ' AND RMV.hedge_type_value_id BETWEEN 150 AND 152'
	SET @report_type = 'a'
END
ELSE
BEGIN
	IF @report_type = 'c' 
	  	SET @insert_stmt2 = @insert_stmt2 + ' AND RMV.hedge_type_value_id = 150'
	IF @report_type = 'f' 
	  	SET @insert_stmt2 = @insert_stmt2 + ' AND RMV.hedge_type_value_id = 151'
	IF @report_type = 'm' 
		SET @insert_stmt2 = @insert_stmt2 + ' AND RMV.hedge_type_value_id = 152'
	IF @report_type = 'a'
		SET @insert_stmt2 = @insert_stmt2 + ' AND RMV.hedge_type_value_id BETWEEN 150 AND 152'
END

IF @legal_entity IS NOT NULL
		SET @insert_stmt2 = @insert_stmt2 + ' AND  books.legal_entity = ' + CAST(@legal_entity AS VARCHAR)

-- Load from report_measurement_values table
EXEC (@insert_stmt + @insert_stmt2)

SET @insert_stmt = 'INSERT INTO #calcprocess_aoci_release
					SELECT car.* FROM ' + dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_aoci_release') + ' car 
					INNER JOIN (select distinct link_id 
					            FROM #calcprocess_deals 
					            WHERE link_type = ''link'') l ON l.link_id = car.link_id
					            AND car.as_of_date = ''' + @as_of_date + ''''
EXEC(@insert_stmt)

SELECT	deal.as_of_date, phs.parent_entity_id sub_entity_id, phs.entity_id strategy_entity_id, phb.entity_id book_entity_id,
		CASE WHEN (deal.link_type = 'link') THEN 'l' ELSE 'd' END link_deal_flag,
		deal.deal_id link_id,
		deal.source_deal_header_id, fb.legal_entity, 
		deal.term_start term_month, 
		CASE WHEN (ISNULL(total_val.u_mtm, 0) >= 0) THEN 1 ELSE 0 END hedge_asset_test,
		CASE WHEN (ISNULL(total_val.d_mtm, 0) >= 0) THEN 1 ELSE 0 END d_hedge_asset_test,
		CASE WHEN (item_settled > 0) THEN 0 ELSE u_aoci - ISNULL(ar.aoci_released, 0) END u_total_aoci,
		CASE WHEN (item_settled > 0) THEN 0 ELSE d_aoci - ISNULL(ar.d_aoci_released, 0) END d_total_aoci,
		deal.link_type_value_id,
		deal.settled_test,
		deal.short_term_test,
		hedge_or_item,
		ISNULL(sgl.gl_number_id_aoci,gl_dedesig_aoci) gl_dedesig_aoci,
		CASE WHEN (settled_test > 0) THEN 0 ELSE
			u_pnl_ineffectiveness+u_pnl_mtm+u_extrinsic_pnl END u_total_pnl,
		CASE WHEN (settled_test > 0) THEN 0 ELSE
			d_pnl_ineffectiveness+d_pnl_mtm+d_extrinsic_pnl  END d_total_pnl,
		ISNULL(ar.aoci_released, 0) u_aoci_released,
		ISNULL(ar.d_aoci_released, 0) d_aoci_released,
		CASE WHEN (deal.link_type='deal') THEN 
			COALESCE(sgl.gl_number_unhedged_der_st_asset, fb.gl_number_unhedged_der_st_asset, sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset) 
		ELSE  ISNULL(sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset) END gl_code_hedge_st_asset,
		CASE WHEN (deal.link_type='deal') THEN 
			COALESCE(sgl.gl_number_unhedged_der_st_liab, fb.gl_number_unhedged_der_st_liab, sgl.gl_number_id_st_liab, fb.gl_number_id_st_liab) 
		ELSE ISNULL(sgl.gl_number_id_st_liab, fb.gl_number_id_st_liab) END gl_code_hedge_st_liability,
		CASE WHEN (deal.link_type='deal') THEN 
			COALESCE(sgl.gl_number_unhedged_der_lt_asset, fb.gl_number_unhedged_der_lt_asset,sgl.gl_number_id_lt_asset, fb.gl_number_id_lt_asset)
		ELSE ISNULL(sgl.gl_number_id_lt_asset, fb.gl_number_id_lt_asset) END gl_code_hedge_lt_asset,
		CASE WHEN (deal.link_type='deal') THEN 	
			COALESCE(sgl.gl_number_unhedged_der_lt_liab, fb.gl_number_unhedged_der_lt_liab,sgl.gl_number_id_lt_liab, fb.gl_number_id_lt_liab) 
		ELSE ISNULL(sgl.gl_number_id_lt_liab, fb.gl_number_id_lt_liab) END gl_code_hedge_lt_liability,		
		ISNULL(sgl.gl_number_id_item_st_asset, fb.gl_number_id_item_st_asset) gl_code_item_st_asset,
		ISNULL(sgl.gl_number_id_item_st_liab, fb.gl_number_id_item_st_liab) gl_code_item_st_liability,
		ISNULL(sgl.gl_number_id_item_lt_asset, fb.gl_number_id_item_lt_asset) gl_code_item_lt_asset,
		ISNULL(sgl.gl_number_id_item_lt_liab, fb.gl_number_id_item_lt_liab) gl_code_item_lt_liability,
		ISNULL(sgl.gl_number_id_aoci, fb.gl_number_id_aoci) gl_aoci,
		ISNULL(sgl.gl_number_id_pnl, fb.gl_number_id_pnl) gl_pnl,
		ISNULL(sgl.gl_number_id_set, fb.gl_number_id_set) gl_settlement,
		ISNULL(sgl.gl_number_id_cash, fb.gl_number_id_cash) gl_cash,
		ISNULL(sgl.gl_number_id_inventory, fb.gl_number_id_inventory) gl_inventory,
		ISNULL(sgl.gl_number_id_expense, fb.gl_number_id_expense) gl_number_id_expense,
		ISNULL(sgl.gl_number_id_gross_set, fb.gl_number_id_gross_set) gl_number_id_gross_set,
		ISNULL(sgl.gl_id_amortization, fb.gl_id_amortization) gl_id_amortization,
		ISNULL(sgl.gl_id_interest, fb.gl_id_interest) gl_id_interest,
		sgl.gl_first_day_pnl gl_first_day_pnl,
		ISNULL(sgl.gl_id_st_tax_asset, fb.gl_id_st_tax_asset) gl_id_st_tax_asset,
		ISNULL(sgl.gl_id_st_tax_liab, fb.gl_id_st_tax_liab) gl_id_st_tax_liab,
		ISNULL(sgl.gl_id_lt_tax_asset, fb.gl_id_lt_tax_asset) gl_id_lt_tax_asset,
		ISNULL(sgl.gl_id_lt_tax_liab, fb.gl_id_lt_tax_liab) gl_id_lt_tax_liab,
		ISNULL(sgl.gl_id_tax_reserve, fb.gl_id_tax_reserve) gl_id_tax_reserve,
		und_pnl, dis_pnl, 
		
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = 'h') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) THEN ISNULL(und_pnl,0) ELSE 0 END
		END AS u_item_st_asset,		
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = 'h') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) THEN ISNULL(und_pnl,0) ELSE 0 END
		END AS u_item_lt_asset,
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = 'h') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) THEN ISNULL(und_pnl,0) ELSE 0 END
		END * -1 AS u_item_st_liability,		
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = 'h') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) THEN ISNULL(und_pnl,0) ELSE 0 END
		END * -1 AS u_item_lt_liability,
  
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = 'h') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) THEN ISNULL(dis_pnl,0) ELSE 0 END
		END AS d_item_st_asset,		
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = 'h') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) THEN ISNULL(dis_pnl,0) ELSE 0 END
		END AS d_item_lt_asset,
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = 'h') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) THEN ISNULL(dis_pnl,0) ELSE 0 END
		END * -1 AS d_item_st_liability,		
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = 'h') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) THEN ISNULL(dis_pnl,0) ELSE 0 END
		END * -1 AS d_item_lt_liability,
		ISNULL(fb.tax_perc, 0) tax_perc,
		(u_aoci - ISNULL(ar.aoci_released, 0)) * ISNULL(fb.tax_perc, 0) u_tax_reserve,
		(d_aoci - ISNULL(ar.d_aoci_released, 0)) * ISNULL(fb.tax_perc, 0) d_tax_reserve,
		CASE WHEN (item_settled > 0 OR hedge_or_item = 'i') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_u_aoci ELSE aoci_l.total_u_aoci END, 0) < 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) THEN -1 * (u_aoci - ISNULL(ar.aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END AS u_st_tax_asset,		
		CASE WHEN (item_settled > 0 OR hedge_or_item = 'i') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_u_aoci ELSE aoci_l.total_u_aoci END, 0) < 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) THEN -1 * (u_aoci - ISNULL(ar.aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END AS u_lt_tax_asset,
		CASE WHEN (item_settled > 0 OR hedge_or_item = 'i') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_u_aoci ELSE aoci_l.total_u_aoci END, 0) < 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) THEN (u_aoci - ISNULL(ar.aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END  AS u_st_tax_liability,		
		CASE WHEN (item_settled > 0 OR hedge_or_item = 'i') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_u_aoci ELSE aoci_l.total_u_aoci END, 0) < 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) THEN (u_aoci - ISNULL(ar.aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END  AS u_lt_tax_liability,
		CASE WHEN (item_settled > 0 OR hedge_or_item = 'i') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_d_aoci ELSE aoci_l.total_d_aoci END, 0) < 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) THEN -1 * (d_aoci - ISNULL(ar.d_aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END AS d_st_tax_asset,		
		CASE WHEN (item_settled > 0 OR hedge_or_item = 'i') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_d_aoci ELSE aoci_l.total_d_aoci END, 0) < 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) THEN -1 * (d_aoci - ISNULL(ar.d_aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END AS d_lt_tax_asset,
		CASE WHEN (item_settled > 0 OR hedge_or_item = 'i') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_d_aoci ELSE aoci_l.total_d_aoci END, 0) < 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) THEN (d_aoci - ISNULL(ar.d_aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END  AS d_st_tax_liability,		
		CASE WHEN (item_settled > 0 OR hedge_or_item = 'i') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_d_aoci ELSE aoci_l.total_d_aoci END, 0) < 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) THEN (d_aoci - ISNULL(ar.d_aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END  AS d_lt_tax_liability,
		CASE WHEN (settled_test > 0) THEN u_pnl_ineffectiveness+u_pnl_mtm+u_extrinsic_pnl+ISNULL(ar.aoci_released, 0) ELSE 0 END u_pnl_settlement,
		CASE WHEN (settled_test > 0) THEN final_und_pnl_remaining ELSE 0 END u_cash,
		CASE WHEN (settled_test > 0) THEN d_pnl_ineffectiveness+d_pnl_mtm+u_extrinsic_pnl+ISNULL(ar.d_aoci_released, 0) ELSE 0 END d_pnl_settlement,
		CASE WHEN (settled_test > 0) THEN final_dis_pnl_remaining  ELSE 0 END d_cash,                   ssbm.book_deal_type_map_id source_book_map_id --make sure this column name matches with source_book_map_id of #temp

		/* Added section start*/
		--get codes for undefined start
			--st codes undefined
		, CASE WHEN (deal.link_type = 'link') THEN 
				COALESCE(sgl.gl_number_unhedged_der_st_asset, fb.gl_number_unhedged_der_st_asset, sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset) 
			ELSE  CASE WHEN (deal.link_type = 'deal') THEN 
				COALESCE(sgl.gl_number_unhedged_der_st_asset, fb.gl_number_unhedged_der_st_asset, sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset) 
				ELSE  ISNULL(sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset)END END gl_code_un_hedge_st_asset,
		CASE WHEN (deal.link_type = 'link') THEN 
			COALESCE(sgl.gl_number_unhedged_der_st_liab, fb.gl_number_unhedged_der_st_liab, sgl.gl_number_id_st_liab, fb.gl_number_id_st_liab) 
		ELSE CASE WHEN (deal.link_type='deal') THEN 
			COALESCE(sgl.gl_number_unhedged_der_st_liab, fb.gl_number_unhedged_der_st_liab, sgl.gl_number_id_st_liab, fb.gl_number_id_st_liab) 
		ELSE ISNULL(sgl.gl_number_id_st_liab, fb.gl_number_id_st_liab) END END gl_code_un_hedge_st_liability,
		
			--long term undefined
		CASE WHEN (deal.link_type='link') THEN 
			COALESCE(sgl.gl_number_unhedged_der_lt_asset, fb.gl_number_unhedged_der_lt_asset,sgl.gl_number_id_lt_asset, fb.gl_number_id_lt_asset)
		ELSE CASE WHEN (deal.link_type='deal') THEN 
			COALESCE(sgl.gl_number_unhedged_der_lt_asset, fb.gl_number_unhedged_der_lt_asset,sgl.gl_number_id_lt_asset, fb.gl_number_id_lt_asset) 
		ELSE  ISNULL(sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset)END END gl_code_un_hedge_lt_asset,
		
		CASE WHEN (deal.link_type='link') THEN
			COALESCE(sgl.gl_number_unhedged_der_lt_liab, fb.gl_number_unhedged_der_lt_liab,sgl.gl_number_id_lt_liab, fb.gl_number_id_lt_liab) 
		ELSE CASE WHEN (deal.link_type='deal') THEN 
			COALESCE(sgl.gl_number_unhedged_der_lt_liab, fb.gl_number_unhedged_der_lt_liab,sgl.gl_number_id_lt_liab, fb.gl_number_id_lt_liab) 
		ELSE  ISNULL(sgl.gl_number_id_lt_liab, fb.gl_number_id_lt_liab) END END gl_code_un_hedge_lt_liability
		--get codes for undefined end 
		
		--take undiscounted aoci for link
			--asset
		 , CASE WHEN (settled_test > 0 OR hedge_or_item = 'i') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) 
				THEN CASE WHEN (deal.link_type='link') THEN ISNULL(u_aoci, 0) ELSE ISNULL(und_pnl,0) END ELSE 0 END  
		  END AS u_hedge_st_asset,    
		  CASE WHEN (settled_test > 0 OR hedge_or_item = 'i') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) 
				THEN CASE WHEN (deal.link_type='link') THEN ISNULL(u_aoci, 0) ELSE ISNULL(und_pnl,0) END ELSE 0 END  
		  END AS u_hedge_lt_asset,  
		  
			--lia
		  CASE WHEN (settled_test > 0 OR hedge_or_item = 'i') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) 
				THEN CASE WHEN (deal.link_type='link') THEN ISNULL(u_aoci, 0) ELSE ISNULL(und_pnl,0) END ELSE 0 END  
		  END * -1 AS u_hedge_st_liability,    
		  CASE WHEN (settled_test > 0 OR hedge_or_item = 'i') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) 
				THEN CASE WHEN (deal.link_type='link') THEN ISNULL(u_aoci, 0) ELSE ISNULL(und_pnl,0) END ELSE 0 END  
		  END * -1 AS u_hedge_lt_liability
		
		--take discounted aoci  for link
			--asset
		, CASE WHEN (settled_test > 0 OR hedge_or_item = 'i') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) 
				THEN CASE WHEN (deal.link_type='link') THEN ISNULL(d_aoci, 0) ELSE ISNULL(dis_pnl,0) END ELSE 0 END  
		  END AS d_hedge_st_asset,    
		  CASE WHEN (settled_test > 0 OR hedge_or_item = 'i') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) 
				THEN CASE WHEN (deal.link_type='link') THEN ISNULL(d_aoci, 0) ELSE ISNULL(dis_pnl,0) END ELSE 0 END  
		  END AS d_hedge_lt_asset,  
		  
			 --lia
		  CASE WHEN (settled_test > 0 OR hedge_or_item = 'i') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) 
				THEN CASE WHEN (deal.link_type='link') THEN ISNULL(d_aoci, 0) ELSE ISNULL(dis_pnl,0) END ELSE 0 END  
		  END * -1 AS d_hedge_st_liability,    
		  CASE WHEN (settled_test > 0 OR hedge_or_item = 'i') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) 
				THEN CASE WHEN (deal.link_type='link') THEN ISNULL(d_aoci, 0) ELSE ISNULL(dis_pnl,0) END ELSE 0 END  
		  END * -1 AS d_hedge_lt_liability,
		  
		  --take undiscounted aoci  for deal
			--asset
		  CASE WHEN (settled_test > 0 OR deal.link_type = 'deal') THEN 0 ELSE     
			CASE WHEN(short_term_test = 1 AND (ISNULL(und_pnl, 0)- ISNULL(u_aoci, 0) >= 0)) 
				THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END  
		  END AS u_un_hedge_st_asset,  
		  
		  CASE WHEN (settled_test > 0 OR deal.link_type = 'deal') THEN 0 ELSE     
			CASE WHEN(short_term_test = 0 AND (ISNULL(und_pnl, 0)- ISNULL(u_aoci, 0) >= 0)) 
				THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END  
		  END AS u_un_hedge_lt_asset, 
		  
			--lia
		  CASE WHEN (settled_test > 0 OR deal.link_type = 'deal') THEN 0 ELSE     
			CASE WHEN(short_term_test = 1 AND (ISNULL(und_pnl, 0)- ISNULL(u_aoci, 0) < 0)) 
				THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END  
		  END * -1 AS u_un_hedge_st_liability,  
		  
		   CASE WHEN (settled_test > 0 OR deal.link_type = 'deal') THEN 0 ELSE     
			CASE WHEN(short_term_test = 0 AND (ISNULL(und_pnl, 0)- ISNULL(u_aoci, 0) < 0)) 
				THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0) ELSE 0 END  
		  END * -1 AS u_un_hedge_lt_liability, 
		  
		  --take discounted aoci  for deal
			--asset
		  CASE WHEN (settled_test > 0 OR deal.link_type = 'deal') THEN 0 ELSE     
			CASE WHEN(short_term_test = 1 AND (ISNULL(dis_pnl, 0)- ISNULL(d_aoci, 0) >= 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0)  ELSE 0 END  
		  END AS d_un_hedge_st_asset,  
		  
		  CASE WHEN (settled_test > 0 OR deal.link_type = 'deal') THEN 0 ELSE     
			CASE WHEN(short_term_test = 0 AND (ISNULL(dis_pnl, 0)- ISNULL(d_aoci, 0) >= 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0) ELSE 0 END  
		  END AS d_un_hedge_lt_asset, 
		
			--lia
		  CASE WHEN (settled_test > 0 OR deal.link_type = 'deal') THEN 0 ELSE     
			CASE WHEN(short_term_test = 1 AND (ISNULL(dis_pnl, 0)- ISNULL(d_aoci, 0) < 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0) ELSE 0 END  
		  END * -1 AS d_un_hedge_st_liability,  
		  
		  CASE WHEN (settled_test > 0 OR deal.link_type = 'deal') THEN 0 ELSE     
			CASE WHEN(short_term_test = 0 AND (ISNULL(dis_pnl, 0)- ISNULL(d_aoci, 0) < 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0) ELSE 0 END  
		  END * -1 AS d_un_hedge_lt_liability
		/*Added section end*/
INTO #cd
FROM (
	SELECT link_id, source_deal_header_id, link_type, as_of_date, term_start, MAX(hedge_or_item) hedge_or_item,
		   MAX(link_type_value_id) link_type_value_id,
		   SUM(u_aoci) u_aoci, 
		   SUM(d_aoci) d_aoci, 
		   MAX(test_settled) settled_test,
		   SUM(final_und_pnl_remaining) final_und_pnl_remaining, 
		   SUM(final_dis_pnl_remaining) final_dis_pnl_remaining, 
		   SUM(u_pnl_ineffectiveness) u_pnl_ineffectiveness, 
		   SUM(d_pnl_ineffectiveness) d_pnl_ineffectiveness, 
		   SUM(u_pnl_mtm) u_pnl_mtm, 
		   SUM(d_pnl_mtm) d_pnl_mtm, 
		   SUM(u_extrinsic_pnl) u_extrinsic_pnl, 
		   SUM(d_extrinsic_pnl) d_extrinsic_pnl,
		   CASE WHEN (term_start <= DATEADD(mm, MAX(long_term_months) - 1, @as_of_date )) THEN 1 ELSE 0 END short_term_test,
		   SUM(final_und_pnl_remaining) und_pnl, 
		   SUM(final_dis_pnl_remaining) dis_pnl,
		   MIN(hedge_type_value_id) hedge_type_value_id,
		   MAX(gl_dedesig_aoci) gl_dedesig_aoci,
		   MAX(deal_id) deal_id
	FROM #calcprocess_deals
	WHERE (hedge_or_item = 'h' OR (hedge_or_item = 'i' AND hedge_type_value_id=151)) 
		AND leg = 1 
		AND as_of_date = @as_of_date 
		AND ISNULL(@called_from_netting, 0) <> 1 
		AND (@settlement_option IS NULL OR @settlement_option = 'a' 
			OR (@settlement_option = 'c' AND term_start >= @as_of_date) 
			OR (@settlement_option = 's' AND term_start < @as_of_date) 
			OR (@settlement_option = 's' AND term_start < @as_of_date) 
			OR (@settlement_option = 'f' AND term_start > @as_of_date))  
	GROUP BY link_id, source_deal_header_id, link_type, as_of_date, term_start) deal   
LEFT OUTER JOIN (
				 SELECT source_deal_header_id, as_of_date, SUM(u_mtm) u_mtm, SUM(d_mtm) d_mtm 
					FROM (  
		SELECT source_deal_header_id, as_of_date, term_start, MAX(und_pnl) u_mtm, MAX(dis_pnl) d_mtm
		FROM #calcprocess_deals
						  WHERE (hedge_or_item = 'h' OR (hedge_or_item = 'i' AND hedge_type_value_id=151)) 
								AND term_start > @as_of_date 
								AND term_start <= DATEADD(mm, long_term_months - 1, @as_of_date ) 
								AND as_of_date = @as_of_date  
		GROUP BY source_deal_header_id, as_of_date, term_start ) xx
	GROUP BY source_deal_header_id, as_of_date
				 ) total_val ON total_val.source_deal_header_id = deal.source_deal_header_id 
				 AND total_val.as_of_date = deal.as_of_date  
LEFT OUTER JOIN(
				SELECT source_deal_header_id, as_of_date, SUM(u_mtm) u_mtm, SUM(d_mtm) d_mtm 
				FROM (  
		SELECT source_deal_header_id, as_of_date, term_start, MAX(und_pnl) u_mtm, MAX(dis_pnl) d_mtm
		FROM #calcprocess_deals
					WHERE (hedge_or_item = 'h' OR (hedge_or_item = 'i' AND hedge_type_value_id=151))
						AND term_start > @as_of_date 
						AND term_start > DATEADD(mm, long_term_months - 1, @as_of_date) 
						AND as_of_date = @as_of_date  
		GROUP BY source_deal_header_id, as_of_date, term_start ) xx
	GROUP BY source_deal_header_id, as_of_date
				) total_val_l ON total_val_l.source_deal_header_id = deal.source_deal_header_id 
				AND total_val_l.as_of_date = deal.as_of_date   
LEFT OUTER JOIN(
	SELECT	as_of_date, source_deal_header_id,  
		SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(aoci_allocation_pnl, 0) ELSE ISNULL(aoci_allocation_vol, 0) END) total_u_aoci,
		SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(d_aoci_allocation_pnl, 0) ELSE ISNULL(d_aoci_allocation_vol, 0) END) total_d_aoci
				 FROM #calcprocess_aoci_release 
				 WHERE oci_rollout_approach_value_id <> 502  
		AND as_of_date = @as_of_date
		AND i_term > as_of_date
		AND i_term <= DATEADD(mm, long_term_months - 1, @as_of_date ) 
				 GROUP BY as_of_date, source_deal_header_id) aoci ON aoci.source_deal_header_id = deal.source_deal_header_id 
					AND aoci.as_of_date = deal.as_of_date   
LEFT OUTER JOIN	(
	SELECT	as_of_date, source_deal_header_id,  
			SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(aoci_allocation_pnl, 0) ELSE ISNULL(aoci_allocation_vol, 0) END) total_u_aoci,
			SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(d_aoci_allocation_pnl, 0) ELSE ISNULL(d_aoci_allocation_vol, 0) END) total_d_aoci
				 FROM #calcprocess_aoci_release 
				 WHERE oci_rollout_approach_value_id <> 502  
	AND as_of_date = as_of_date
	AND i_term > DATEADD(mm, long_term_months - 1, @as_of_date ) 
	GROUP BY as_of_date, source_deal_header_id) aoci_l ON aoci_l.source_deal_header_id = deal.source_deal_header_id AND aoci_l.as_of_date = deal.as_of_date 
LEFT OUTER JOIN(
				SELECT link_id, 
						source_deal_header_id, h_term, MAX(i_term) max_i_term, 
						CASE WHEN (MAX(i_term) <= @as_of_date) THEN 1 ELSE 0 END item_settled,    
		SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(aoci_allocation_pnl, 0) ELSE ISNULL(aoci_allocation_vol, 0) END) aoci_released,
		SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(d_aoci_allocation_pnl, 0) ELSE ISNULL(d_aoci_allocation_vol, 0) END) d_aoci_released
				FROM #calcprocess_aoci_release 
				WHERE oci_rollout_approach_value_id <> 502  
		AND as_of_date = @as_of_date
		AND i_term <= as_of_date
				GROUP BY as_of_date, link_id, source_deal_header_id, h_term) ar ON ar.source_deal_header_id=deal.source_deal_header_id 
					AND ar.h_term = deal.term_start AND ar.link_id = deal.link_id AND deal.link_type = 'link'  
LEFT OUTER JOIN source_deal_header sdh ON sdh.source_deal_header_id = deal.source_deal_header_id
LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
	AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
	AND ssbm.source_system_book_id3 = sdh.source_system_book_id3 
	AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
LEFT OUTER JOIN portfolio_hierarchy phb ON phb.entity_id = ssbm.fas_book_id 
LEFT OUTER JOIN portfolio_hierarchy phs ON phs.entity_id = phb.parent_entity_id
LEFT OUTER JOIN fas_books fb ON fb.fas_book_id = phb.entity_id
LEFT OUTER JOIN source_book_map_GL_codes sgl ON sgl.source_book_map_id = ssbm.book_deal_type_map_id    

-- select term_month, settled_test, * from #cd

SET @insert_stmt = 'INSERT INTO #temp
					SELECT rmv.*, books.gl_tenor_option, books.legal_entity, books.gl_dedesig_aoci,NULL source_book_map_id 
					FROM ' + dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  rmv 
					INNER JOIN (SELECT fas_book_id, gl_tenor_option, legal_entity, gl_dedesig_aoci 
					            FROM #ssbm_b 
					            WHERE gl_grouping_value_id <> 352) books ON books.fas_book_id = rmv.book_entity_id 
					            AND rmv.as_of_date = ''' + @as_of_date  + '''
					            AND (((' + CAST(ISNULL(@called_from_netting, 0) AS VARCHAR) + ' = 1  
									OR ''' + ISNULL(@settlement_option, 'n') + ''' = ''n'') 
									AND ((gl_tenor_option = ''f'' and term_month  > ''' + @as_of_date + ''') 
									OR (gl_tenor_option = ''c'' and term_month >= ''' + @as_of_date + ''') 
									OR (gl_tenor_option = ''s'' and term_month  < ''' + @as_of_date + ''') 
									OR (gl_tenor_option is null OR gl_tenor_option = ''a''))) 
									OR (' + CAST(ISNULL(@called_from_netting, 0) AS VARCHAR) + ' <> 1  
									AND ((''' + ISNULL(@settlement_option, 'n') + ''' = ''f'' and term_month  > ''' + @as_of_date + ''') 
									OR (''' + ISNULL(@settlement_option, 'n') + ''' = ''c'' and term_month >= ''' + @as_of_date + ''') 
									OR (''' + ISNULL(@settlement_option, 'n') + ''' = ''s'' and term_month  < ''' + @as_of_date + ''') 
					OR (''' + ISNULL(@settlement_option, 'n') + ''' = ''a'')))) '   

SET @term_stmt = ' WHERE 1 = 1 ' 
SET @insert_stmt2 = ''

IF @link_id IS NOT NULL
	SET @insert_stmt2 = @insert_stmt2 + ' AND ((CAST(RMV.link_id AS VARCHAR) + RMV.link_deal_flag) IN (SELECT link_id FROM #links)) ' 	

IF @called_from_netting IN (1, 2) OR @report_type IS NULL
BEGIN
	SET @insert_stmt2 = @insert_stmt2 + ' AND RMV.hedge_type_value_id BETWEEN 150 AND 152'
	SET @report_type = 'a'
END
ELSE
BEGIN
	IF @report_type = 'c' 
	  	SET @insert_stmt2 = @insert_stmt2 + ' AND RMV.hedge_type_value_id = 150'
	IF @report_type = 'f' 
	  	SET @insert_stmt2 = @insert_stmt2 + ' AND RMV.hedge_type_value_id = 151'
	IF @report_type = 'm' 
		SET @insert_stmt2 = @insert_stmt2 + ' AND RMV.hedge_type_value_id = 152'
	IF @report_type = 'a'
		SET @insert_stmt2 = @insert_stmt2 + ' AND RMV.hedge_type_value_id BETWEEN 150 AND 152'
END

IF @legal_entity IS NOT NULL
		SET @insert_stmt2 = @insert_stmt2 + ' AND books.legal_entity = ' + CAST(@legal_entity AS VARCHAR)

-- Load from report_measurement_values table
EXEC (@insert_stmt + @insert_stmt2)

-- Now Load from report_measurement_values_expired table
SET @insert_stmt = 'INSERT INTO #temp
					SELECT rmv.*, books.gl_tenor_option, books.legal_entity, books.gl_dedesig_aoci, NULL source_book_map_id 
					FROM report_measurement_values_expired  rmv 
					INNER  JOIN
					(SELECT fas_book_id, gl_tenor_option, legal_entity, gl_dedesig_aoci from #ssbm_b) books on books.fas_book_id = rmv.book_entity_id 
						AND rmv.as_of_date < ''' + @as_of_date  + '''
						AND (((' + CAST (ISNULL(@called_from_netting, 0) AS VARCHAR) + ' = 1  OR ''' + ISNULL(@settlement_option, 'n') + ''' = ''n'') AND
									(gl_tenor_option = ''f'' and term_month  > ''' + @as_of_date + ''') OR
									(gl_tenor_option = ''c'' and term_month >= ''' + @as_of_date + ''') OR
									(gl_tenor_option = ''s'' and term_month  < ''' + @as_of_date + ''') OR
									(gl_tenor_option is null OR gl_tenor_option = ''a'')  
							  ) OR
							 (	' + CAST (ISNULL(@called_from_netting, 0) AS VARCHAR) + ' <> 1  AND ((''' + ISNULL(@settlement_option, 'n') + ''' = ''f'' and term_month  > ''' + @as_of_date + ''') OR
								(''' + ISNULL(@settlement_option, 'n') + ''' = ''c'' and term_month >= ''' + @as_of_date + ''') OR
								(''' + ISNULL(@settlement_option, 'n') + ''' = ''s'' and term_month  < ''' + @as_of_date + ''') OR
								(''' + ISNULL(@settlement_option, 'n') + ''' = ''a'')  
							  ) )		
							)
					'	
--PRINT @insert_stmt + @insert_stmt2
EXEC (@insert_stmt + @insert_stmt2)

DECLARE	@where_stmt VARCHAR(500)

IF @discount_option IN ('u' , 'd')
	BEGIN
		--===============Get hedge_st_asset============================
		--only pick up asset and liabilities for non-netting rules
		IF @called_from_netting <> 1 AND @settlement_option <> 's'
		BEGIN		
		SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP   
						   SELECT	as_of_date, 
									sub_entity_id, 
									strategy_entity_id, 
									book_entity_id, 
									link_id, 
									link_deal_flag, 
									term_month, 
									legal_entity, 
source_book_map_id,
									ISNULL(gl_code_hedge_st_asset, CASE WHEN d_total_aoci = 0 AND link_deal_flag = ''d'' THEN  ' + @un_st_asset_gl_id + ' ELSE ' + @st_asset_gl_id + ' END) AS Gl_Number,   
			                CASE WHEN (' + @discount_option + '_hedge_st_asset >= 0) THEN ' + @discount_option + '_hedge_st_asset ELSE 0 END AS Debit, 
									CASE WHEN (' + @discount_option + '_hedge_st_asset < 0) THEN -1 * ' + @discount_option + '_hedge_st_asset ELSE 0 END AS Credit  '  

			SET @where_stmt = ' WHERE ' + @discount_option + '_hedge_st_asset <> 0' 
		EXEC (@Sql_Select + @Sql_From + @where_stmt)  
		 
		EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)  

		--Unhedged Split st asset
		SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP   
						   SELECT   as_of_date, 
									sub_entity_id, 
									strategy_entity_id, 
									book_entity_id, 
									link_id, 
									link_deal_flag, 
									term_month, 
									legal_entity, 
									source_book_map_id,  
									ISNULL(gl_code_un_hedge_st_asset, ' + @un_st_asset_gl_id + ') AS Gl_Number,   
									CASE WHEN (' + @discount_option + '_un_hedge_st_asset >= 0) THEN ' + @discount_option + '_un_hedge_st_asset ELSE 0 END AS Debit,   
									CASE WHEN (' + @discount_option + '_un_hedge_st_asset < 0) THEN -1 * ' + @discount_option + '_un_hedge_st_asset ELSE 0 END AS Credit '  
			
		SET @where_stmt = ' WHERE ' + @discount_option + '_un_hedge_st_asset <> 0'   
			EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)
		
  
			--================Get hedge_st_liability============================
		SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
							SELECT  as_of_date, 
									sub_entity_id, 
									strategy_entity_id, 
									book_entity_id, 
									link_id, 
									link_deal_flag, 
									term_month, 
									legal_entity,
									source_book_map_id, --add bookmapid  
									ISNULL(gl_code_hedge_st_liability, CASE WHEN d_total_aoci = 0 AND link_deal_flag = ''d'' THEN ' + @un_st_liability_gl_id + ' ELSE ' + @st_liability_gl_id + ' END ) AS Gl_Number,   
			                CASE WHEN (' + @discount_option + '_hedge_st_liability < 0) THEN -1 * ' + @discount_option + '_hedge_st_liability ELSE 0 END AS Debit,
									CASE WHEN (' + @discount_option + '_hedge_st_liability >= 0) THEN ' + @discount_option + '_hedge_st_liability ELSE 0 END AS Credit '  
			SET @where_stmt = ' WHERE ' + @discount_option + '_hedge_st_liability <> 0' 
					
			EXEC (@Sql_Select + @Sql_From + @where_stmt)
		EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)  
   
		--Unhedged Split st lia
		SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
							SELECT  as_of_date, 
									sub_entity_id, 
									strategy_entity_id, 
									book_entity_id, 
									link_id, 
									link_deal_flag, 
									term_month, 
									legal_entity,
									source_book_map_id, --add bookmapid  
									ISNULL(gl_code_un_hedge_st_liability, ' + @un_st_liability_gl_id + ' ) AS Gl_Number,   
									CASE WHEN (' + @discount_option + '_un_hedge_st_liability < 0) THEN -1 * ' + @discount_option + '_un_hedge_st_liability ELSE 0 END AS Debit,  
									CASE WHEN (' + @discount_option + '_un_hedge_st_liability >= 0) THEN ' + @discount_option + '_un_hedge_st_liability ELSE 0 END AS Credit '  
		SET @where_stmt = ' WHERE ' + @discount_option + '_un_hedge_st_liability <> 0'   
						
			EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)

			--===========================Get hedge_lt_asset==========================
		SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id,--add bookmapid
							ISNULL(gl_code_hedge_lt_asset, CASE WHEN d_total_aoci = 0 AND link_deal_flag = ''d'' THEN '  + @un_lt_asset_gl_id  + ' ELSE '  + @lt_asset_gl_id  + ' END ) AS Gl_Number,   
			                CASE WHEN (' + @discount_option + '_hedge_lt_asset >= 0) THEN ' + @discount_option + '_hedge_lt_asset ELSE 0 END AS Debit, 
					CASE WHEN (' + @discount_option + '_hedge_lt_asset < 0) THEN -1 * ' + @discount_option + '_hedge_lt_asset ELSE 0 END AS Credit		
			'

			SET @where_stmt = ' WHERE ' + @discount_option + '_hedge_lt_asset <> 0' 
						
			EXEC (@Sql_Select + @Sql_From + @where_stmt)
		EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)  

		--Unhedged Split lt asset
		SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
							SELECT  as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id,--add bookmapid  
									ISNULL(gl_code_un_hedge_lt_asset, ' + @un_lt_asset_gl_id  + ') AS Gl_Number,   
									CASE WHEN (' + @discount_option + '_un_hedge_lt_asset >= 0) THEN ' + @discount_option + '_un_hedge_lt_asset ELSE 0 END AS Debit,   
									CASE WHEN (' + @discount_option + '_un_hedge_lt_asset < 0) THEN -1 * ' + @discount_option + '_un_hedge_lt_asset ELSE 0 END AS Credit    
							'  

		SET @where_stmt = ' WHERE ' + @discount_option + '_un_hedge_lt_asset <> 0'   

			EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)

			--==========================Get hedge_lt_liability========================
		SET @Sql_Select =  'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity,source_book_map_id, --add bookmapid
									ISNULL(gl_code_hedge_lt_liability, CASE WHEN d_total_aoci = 0 AND link_deal_flag = ''d'' THEN ' + @un_lt_liability_gl_id + ' ELSE ' + @lt_liability_gl_id + ' END) AS Gl_Number,   
			                CASE WHEN (' + @discount_option + '_hedge_lt_liability < 0) THEN -1 * ' + @discount_option + '_hedge_lt_liability ELSE 0 END AS Debit,
									CASE WHEN (' + @discount_option + '_hedge_lt_liability >= 0) THEN ' + @discount_option + '_hedge_lt_liability ELSE 0 END AS Credit '  

			SET @where_stmt = ' WHERE ' + @discount_option + '_hedge_lt_liability <> 0' 
						
			EXEC (@Sql_Select + @Sql_From + @where_stmt)

			EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)
	
		--Unhedged Split lt lia
		SET @Sql_Select =  'INSERT INTO #temp_MTM_JEP  
							SELECT  as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity,source_book_map_id, --add bookmapid  
									ISNULL(gl_code_un_hedge_lt_liability, ' + @un_lt_liability_gl_id + ') AS Gl_Number,   
									CASE WHEN (' + @discount_option + '_un_hedge_lt_liability < 0) THEN -1 * ' + @discount_option + '_un_hedge_lt_liability ELSE 0 END AS Debit,  
									CASE WHEN (' + @discount_option + '_un_hedge_lt_liability >= 0) THEN ' + @discount_option + '_un_hedge_lt_liability ELSE 0 END AS Credit '  

		SET @where_stmt = ' WHERE ' + @discount_option + '_un_hedge_lt_liability <> 0'   

		EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)  
		/*added code start*/
		END

		--==========================Tax Assets/Liabilities================================
			--===============Get st tax asset ============================

	SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity,source_book_map_id, --add bookmapid
					ISNULL(gl_id_st_tax_asset, ' + @st_tax_asset_gl_id  + ') AS Gl_Number, 
			        CASE WHEN (' + @discount_option + '_st_tax_asset >= 0) THEN ' + @discount_option + '_st_tax_asset ELSE 0 END AS Debit, 
								CASE WHEN (' + @discount_option + '_st_tax_asset < 0) THEN -1 * ' + @discount_option + '_st_tax_asset ELSE 0 END AS Credit '  
	
			SET @where_stmt = ' WHERE ' + @discount_option + '_st_tax_asset <> 0 '
		
			IF @aoci_tax_asset_liab = '0'
				EXEC (@Sql_Select + @Sql_From + @where_stmt)
		
			IF @aoci_tax_asset_liab = '0'
				EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)

			--===============Get st tax liability ============================
	SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity,source_book_map_id, --add bookmapid
					ISNULL(gl_id_st_tax_liab, ' + @st_tax_liability_gl_id  + ') AS Gl_Number, 
			        CASE WHEN (' + @discount_option + '_st_tax_liability < 0) THEN -1 * ' + @discount_option + '_st_tax_liability ELSE 0 END AS Debit,
								CASE WHEN (' + @discount_option + '_st_tax_liability >= 0) THEN ' + @discount_option + '_st_tax_liability ELSE 0 END AS Credit '   

			SET @where_stmt = ' WHERE ' + @discount_option + '_st_tax_liability <> 0 ' 
				
			IF @aoci_tax_asset_liab = '0'
				EXEC (@Sql_Select + @Sql_From + @where_stmt)

			IF @aoci_tax_asset_liab = '0'
				EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)

			--===============Get lt tax asset ============================

	SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id,--add bookmapid
					ISNULL(gl_id_lt_tax_asset, ' + @lt_tax_asset_gl_id + ') AS Gl_Number, 
			        CASE WHEN (' + @discount_option + '_lt_tax_asset >= 0) THEN ' + @discount_option + '_lt_tax_asset ELSE 0 END AS Debit, 
						CASE WHEN (' + @discount_option + '_lt_tax_asset < 0) THEN -1 * ' + @discount_option + '_lt_tax_asset ELSE 0 END AS Credit '  
	
			SET @where_stmt = ' WHERE ' + @discount_option + '_lt_tax_asset <> 0 ' 
		
			IF @aoci_tax_asset_liab = '0'
				EXEC (@Sql_Select + @Sql_From + @where_stmt)
		
			IF @aoci_tax_asset_liab = '0'
				EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)

			--===============Get lt tax liability ============================
	SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
					ISNULL(gl_id_lt_tax_liab, ' + @lt_tax_liability_gl_id  + ') AS Gl_Number, 
			        CASE WHEN (' + @discount_option + '_lt_tax_liability < 0) THEN -1 * ' + @discount_option + '_lt_tax_liability ELSE 0 END AS Debit,
						CASE WHEN (' + @discount_option + '_lt_tax_liability >= 0) THEN ' + @discount_option + '_lt_tax_liability ELSE 0 END AS Credit '   

			SET @where_stmt = ' WHERE ' + @discount_option + '_lt_tax_liability <> 0 ' 
				
			IF @aoci_tax_asset_liab = '0'
				EXEC (@Sql_Select + @Sql_From + @where_stmt)

			IF @aoci_tax_asset_liab = '0'
				EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)

			--===============Get tax reserve ============================
	SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
					ISNULL(gl_id_tax_reserve, ' + @tax_reserve + ') AS Gl_Number, 
			        CASE WHEN (' + @discount_option + '_tax_reserve > 0) THEN ' + @discount_option + '_tax_reserve ELSE 0 END AS Debit,
						CASE WHEN (' + @discount_option + '_tax_reserve <= 0) THEN -1 * ' + @discount_option + '_tax_reserve ELSE 0 END AS Credit '   
				
			SET @where_stmt = ' WHERE ' + @discount_option + '_tax_reserve <> 0 ' 
			
			EXEC (@Sql_Select + @Sql_From + @where_stmt)
			EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)
			
		--==========================Get total_PNL================================
	SET @Sql_Select = ' INSERT INTO #temp_MTM_JEP  
		SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
				ISNULL(gl_pnl, ' + @total_pnl + ') AS Gl_Number, 
		                CASE WHEN(' + @discount_option + '_total_pnl <0) THEN -1* ' + @discount_option + '_total_pnl ELSE 0 END AS Debit, 
						CASE WHEN(' + @discount_option + '_total_pnl >= 0) THEN ' + @discount_option + '_total_pnl ELSE 0 END AS Credit '   
	
		SET @where_stmt = ' WHERE ' + @discount_option + '_total_pnl <> 0 ' 
	
		EXEC (@Sql_Select + @Sql_From + @where_stmt)
		EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)

		--==========================Get total_AOCI================================

	SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
		SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
						CASE WHEN (u_total_aoci <> 0 AND link_type_value_id = 451) THEN ISNULL(gl_dedesig_aoci, ' + @aoci + ') ELSE   
				ISNULL(gl_aoci, ' + @aoci + ') END AS Gl_Number, 
		                CASE WHEN(' + @discount_option + '_total_aoci <0) THEN -1* ' + @discount_option + '_total_aoci ELSE 0 END AS Debit, 
						CASE WHEN(' + @discount_option + '_total_aoci >= 0) THEN ' + @discount_option + '_total_aoci ELSE 0 END AS Credit '  

	SET @term_stmt1 = CASE WHEN(@term_stmt = '') THEN ' WHERE ' + @discount_option + '_total_aoci <> 0' 
						ELSE @term_stmt + ' AND ' + @discount_option + '_total_aoci <> 0' END  
		
		EXEC (@Sql_Select + @Sql_From + @term_stmt1)
		EXEC (@Sql_Select + ' FROM #cd cd ' + @term_stmt1)

	 
		--========================Get Settlement==================================
	SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
		SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
				ISNULL(gl_settlement, ' + @pnl_set + ') AS Gl_Number, 
		                CASE WHEN(' + @discount_option + '_pnl_settlement <0) THEN -1*' + @discount_option + '_pnl_settlement ELSE 0 END AS Debit, 
						CASE WHEN(' + @discount_option + '_pnl_settlement >= 0) THEN ' + @discount_option + '_pnl_settlement ELSE 0 END AS Credit '  

	SET @term_stmt1 = CASE WHEN(@term_stmt = '') THEN ' WHERE ' + @discount_option + '_pnl_settlement <> 0' 
						ELSE @term_stmt + ' AND ' + @discount_option + '_pnl_settlement <> 0' END  
			
		EXEC (@Sql_Select + @Sql_From + @term_stmt1)
		EXEC (@Sql_Select + ' FROM #cd cd ' + @term_stmt1)
				
		--========================Get Inventory==================================
	SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
		SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
				ISNULL(gl_inventory, ' + @inventory + ') AS Gl_Number, 
		                CASE WHEN(' + @discount_option + '_pnl_inventory <0) THEN -1*' + @discount_option + '_pnl_inventory ELSE 0 END AS Debit, 
						CASE WHEN(' + @discount_option + '_pnl_inventory >= 0) THEN ' + @discount_option + '_pnl_inventory ELSE 0 END AS Credit '  
		
	SET @term_stmt1 = CASE WHEN(@term_stmt = '') THEN ' WHERE ' + @discount_option + '_pnl_inventory <> 0' 
						ELSE @term_stmt + ' AND ' + @discount_option + '_pnl_inventory <> 0' END  
		
		EXEC (@Sql_Select + @Sql_From + @term_stmt1)

		--========================Get Cash==================================
	SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
		SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
				ISNULL(gl_cash, ' + @cash + ') AS Gl_Number, 
		                CASE WHEN(' + @discount_option + '_cash >=0) THEN ' + @discount_option + '_cash ELSE 0 END AS Debit, 
						CASE WHEN(' + @discount_option + '_cash < 0) THEN -1*' + @discount_option + '_cash ELSE 0 END AS Credit '  

	SET @term_stmt1 = CASE WHEN(@term_stmt = '') THEN ' WHERE ' + @discount_option + '_cash <> 0' 
						ELSE @term_stmt + ' AND ' + @discount_option + '_cash <> 0' END  
		
		EXEC (@Sql_Select + @Sql_From + @term_stmt1)
		EXEC (@Sql_Select + ' FROM #cd cd ' + @term_stmt1)
	END

IF @Report_Type = 'f' OR @Report_Type = 'a'
	BEGIN
	IF @discount_option IN ('u' , 'd')
	BEGIN
		--===============Get item_st_asset============================
		--only pick up asset and liabilities for non-netting rules
		IF @called_from_netting <> 1 AND @settlement_option <> 's'
		BEGIN		
		
		SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
					ISNULL(gl_code_item_st_asset, ' + @st_item_asset_gl_id + ') AS Gl_Number, 
			                CASE WHEN (' + @discount_option + '_item_st_asset >= 0) THEN ' + @discount_option + '_item_st_asset ELSE 0 END AS Debit, 
							CASE WHEN (' + @discount_option + '_item_st_asset < 0) THEN -1 * ' + @discount_option + '_item_st_asset ELSE 0 END AS Credit '  

			SET @where_stmt = ' WHERE ' + @discount_option + '_item_st_asset <> 0 ' 		
				
			EXEC (@Sql_Select + @Sql_From + @where_stmt)
			EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)

			--================Get item_st_liability============================
		SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
					ISNULL(gl_code_item_st_liability, ' + @st_item_liability_gl_id + ') AS Gl_Number, 
			                CASE WHEN (' + @discount_option + '_item_st_liability < 0) THEN -1 * ' + @discount_option + '_item_st_liability ELSE 0 END AS Debit,
							CASE WHEN (' + @discount_option + '_item_st_liability >= 0) THEN ' + @discount_option + '_item_st_liability ELSE 0 END AS Credit '  

			SET @where_stmt = ' WHERE ' + @discount_option + '_item_st_liability <> 0 ' 			
			
			EXEC (@Sql_Select + @Sql_From + @where_stmt)
			EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)
			
			--===========================Get item_lt_asset==========================
		SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
					ISNULL(gl_code_item_lt_asset, ' + @lt_item_asset_gl_id + ') AS Gl_Number, 
			                CASE WHEN (' + @discount_option + '_item_lt_asset >= 0) THEN ' + @discount_option + '_item_lt_asset ELSE 0 END AS Debit, 
							CASE WHEN (' + @discount_option + '_item_lt_asset < 0) THEN -1 * ' + @discount_option + '_item_lt_asset ELSE 0 END AS Credit '  

			SET @where_stmt = ' WHERE ' + @discount_option + '_item_lt_asset <> 0 ' 
						
			EXEC (@Sql_Select + @Sql_From + @where_stmt)
			EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)

			--==========================Get item_lt_liability========================
		SET @Sql_Select = 'INSERT INTO #temp_MTM_JEP  
			SELECT   as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, link_deal_flag, term_month, legal_entity, source_book_map_id, --add bookmapid
					ISNULL(gl_code_item_lt_liability, ' +  @lt_item_liability_gl_id + ') AS Gl_Number, 
			                CASE WHEN (' + @discount_option + '_item_lt_liability < 0) THEN -1 * ' + @discount_option + '_item_lt_liability ELSE 0 END AS Debit,
							CASE WHEN (' + @discount_option + '_item_lt_liability >= 0) THEN ' + @discount_option + '_item_lt_liability ELSE 0 END AS Credit '  

			SET @where_stmt = ' WHERE ' + @discount_option + '_item_lt_liability <> 0 ' 			
			
			EXEC (@Sql_Select + @Sql_From + @where_stmt)
			EXEC (@Sql_Select + ' FROM #cd cd ' + @where_stmt)
		END
	END
END

DECLARE @rounding_points INT
SET @rounding_points = CAST(@round_value AS INT)

--set @rounding_points = 0
IF @called_from_netting IN (1, 2)
	SET @rounding_points = 4

EXEC spa_print '****************'
EXEC spa_print @batch_table_name
EXEC spa_print '****************'

--This is drill down for one to many gl codes
IF @summary_option ='z'
BEGIN
	SET @Sql_Select = 'SELECT	tempRMV.sub_entity_id,  
			tempRMV.legal_entity,
			sle.legal_entity_name legal_entity_name,    
			PH.entity_name AS Subsidiary, PH1.entity_name AS Strategy, 
			PH2.entity_name AS Book, 
			gsm.gl_number_id,
			ISNULL(gsm.gl_account_number, tempRMV.Gl_Number) AS [GLNumber], 
			ISNULL(gsm.gl_account_name, 
				CASE	WHEN (tempRMV.Gl_Number = -1) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTAsset'' 
						WHEN (tempRMV.Gl_Number = -2) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTLiab'' 
						WHEN (tempRMV.Gl_Number = -3) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTAsset'' 
						WHEN (tempRMV.Gl_Number = -4) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTLiab'' 
						WHEN (tempRMV.Gl_Number = -5) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTAsset'' 
						WHEN (tempRMV.Gl_Number = -6) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTLiab'' 
						WHEN (tempRMV.Gl_Number = -7) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTAsset'' 
						WHEN (tempRMV.Gl_Number = -8) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTLiab'' 
						WHEN (tempRMV.Gl_Number = -9) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTAsset'' 
						WHEN (tempRMV.Gl_Number = -10) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTLiab'' 
						WHEN (tempRMV.Gl_Number = -11) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTAsset'' 
						WHEN (tempRMV.Gl_Number = -12) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTLiab'' 
						WHEN (tempRMV.Gl_Number = -13) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxReserve'' 
						WHEN (tempRMV.Gl_Number = -14) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLSettlement'' 
						WHEN (tempRMV.Gl_Number = -15) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AOCI'' 
						WHEN (tempRMV.Gl_Number = -16) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLIneffectiveness'' 
						WHEN (tempRMV.Gl_Number = -17) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Inventory'' 
						WHEN (tempRMV.Gl_Number = -18) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Receivables'' 
						WHEN (tempRMV.Gl_Number = -19) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Cash'' 
						WHEN (tempRMV.Gl_Number = -20) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AccruedInterest'' 
						WHEN (tempRMV.Gl_Number = -21) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Interest'' 
						WHEN (tempRMV.Gl_Number = -22) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Amortization'' 
								WHEN (tempRMV.Gl_Number = -23) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTAsset'' 
								WHEN (tempRMV.Gl_Number = -24) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTLiab'' 
								WHEN (tempRMV.Gl_Number = -25) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTAsset'' 
								WHEN (tempRMV.Gl_Number = -26) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTLiab''  
				ELSE CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Unknown.GL.Code'' END) AS [AccountName], 				
			link_id,
			link_deal_flag, 
			term_month term_month,
							CASE WHEN (tempRMV.Debit >= tempRMV.Credit) THEN ROUND(tempRMV.Debit - tempRMV.Credit, ' + CAST(@rounding_points AS VARCHAR) + ') ELSE 0 END AS Debit,   
							CASE WHEN (tempRMV.Debit <= tempRMV.Credit) THEN ROUND(tempRMV.Credit - tempRMV.Debit , ' + CAST(@rounding_points AS VARCHAR)+ ') ELSE 0 END AS Credit '  
	+ ISNULL(@batch_table_name, '') +  	
'	FROM    #temp_MTM_JEP tempRMV(NOLOCK) LEFT OUTER JOIN
		    gl_system_mapping gsm(NOLOCK) ON tempRMV.Gl_Number = gsm.gl_number_id LEFT OUTER JOIN
			portfolio_hierarchy PH2(NOLOCK) ON PH2.entity_id = tempRMV.book_entity_id LEFT OUTER JOIN		
		    portfolio_hierarchy PH1(NOLOCK) ON PH1.entity_id = tempRMV.strategy_entity_id LEFT OUTER JOIN
		    portfolio_hierarchy PH(NOLOCK) ON tempRMV.sub_entity_id = PH.entity_id LEFT OUTER JOIN
					source_legal_entity sle ON sle.source_legal_entity_id = tempRMV.legal_entity ' +  
	CASE WHEN(@drill_gl_number IS NULL) THEN '' ELSE ' WHERE ISNULL(gsm.gl_account_number, tempRMV.Gl_Number) IN (' + @drill_gl_number_quote + ')' END	

	--print @Sql_Select
	EXEC(@Sql_Select)
	RETURN
END
IF @summary_option ='d'
BEGIN
	SET @sql_stmt = ' SELECT  PH.entity_name AS Subsidiary, PH1.entity_name AS Strategy,   
			PH2.entity_name AS Book,  
			ISNULL(gsm.gl_account_number, tempRMV.Gl_Number) AS [GLNumber], 
			ISNULL(gsm.gl_account_name, 
				CASE	WHEN (tempRMV.Gl_Number = -1) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTAsset'' 
						WHEN (tempRMV.Gl_Number = -2) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTLiab'' 
						WHEN (tempRMV.Gl_Number = -3) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTAsset'' 
						WHEN (tempRMV.Gl_Number = -4) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTLiab'' 
						WHEN (tempRMV.Gl_Number = -5) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTAsset'' 
						WHEN (tempRMV.Gl_Number = -6) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTLiab'' 
						WHEN (tempRMV.Gl_Number = -7) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTAsset'' 
						WHEN (tempRMV.Gl_Number = -8) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTLiab'' 
						WHEN (tempRMV.Gl_Number = -9) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTAsset'' 
						WHEN (tempRMV.Gl_Number = -10) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTLiab'' 
						WHEN (tempRMV.Gl_Number = -11) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTAsset'' 
						WHEN (tempRMV.Gl_Number = -12) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTLiab'' 
						WHEN (tempRMV.Gl_Number = -13) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxReserve'' 
						WHEN (tempRMV.Gl_Number = -14) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLSettlement'' 
						WHEN (tempRMV.Gl_Number = -15) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AOCI'' 
						WHEN (tempRMV.Gl_Number = -16) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLIneffectiveness'' 
						WHEN (tempRMV.Gl_Number = -17) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Inventory'' 
						WHEN (tempRMV.Gl_Number = -18) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Receivables'' 
						WHEN (tempRMV.Gl_Number = -19) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Cash'' 
						WHEN (tempRMV.Gl_Number = -20) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AccruedInterest'' 
						WHEN (tempRMV.Gl_Number = -21) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Interest'' 
						WHEN (tempRMV.Gl_Number = -22) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Amortization'' 
							WHEN (tempRMV.Gl_Number = -23) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTAsset'' 
							WHEN (tempRMV.Gl_Number = -24) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTLiab'' 
							WHEN (tempRMV.Gl_Number = -25) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTAsset'' 
							WHEN (tempRMV.Gl_Number = -26) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTLiab''
							ELSE CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Unknown.GL.Code'' END) AS [AccountName],       
			CASE WHEN (SUM(tempRMV.Debit) >= SUM(tempRMV.Credit)) THEN (SUM(tempRMV.Debit) - SUM(tempRMV.Credit))
		 			ELSE 0 END AS Debit, 
				CASE WHEN (SUM(tempRMV.Debit) <= SUM(tempRMV.Credit)) THEN (SUM(tempRMV.Credit) - SUM(tempRMV.Debit)) 
					ELSE 0 END AS Credit
		FROM         #temp_MTM_JEP tempRMV(NOLOCK) LEFT OUTER JOIN
		             gl_system_mapping gsm(NOLOCK) ON tempRMV.Gl_Number = gsm.gl_number_id LEFT OUTER JOIN
			     portfolio_hierarchy PH2(NOLOCK) ON PH2.entity_id = tempRMV.book_entity_id LEFT OUTER JOIN		
		             portfolio_hierarchy PH1(NOLOCK) ON PH1.entity_id = tempRMV.strategy_entity_id LEFT OUTER JOIN
		             portfolio_hierarchy PH(NOLOCK) ON tempRMV.sub_entity_id = PH.entity_id 
	WHERE 1=1'
	
	SET @sql_stmt = @sql_stmt + CASE WHEN @sub_entity_id IS NOT NULL THEN  ' AND PH.entity_id IN (' + CAST (@sub_entity_id AS VARCHAR(8000)) + ')' ELSE '' END   
	SET @sql_stmt = @sql_stmt + CASE WHEN  @strategy_entity_id IS NOT NULL THEN ' AND PH1.entity_id IN (' + CAST (@strategy_entity_id AS VARCHAR(8000)) + ')' ELSE '' END  
	SET @sql_stmt = @sql_stmt + CASE WHEN @book_entity_id IS NOT NULL THEN ' AND PH2.entity_id IN (' + CAST (@book_entity_id AS VARCHAR(8000)) + ')' ELSE '' END   
	
	SET @sql_stmt = @sql_stmt + '
	GROUP BY   PH.entity_name, PH1.entity_name, PH2.entity_name, 
			ISNULL(gsm.gl_account_number, tempRMV.Gl_Number), 
			ISNULL(gsm.gl_account_name, 
				CASE	WHEN (tempRMV.Gl_Number = -1) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTAsset'' 
						WHEN (tempRMV.Gl_Number = -2) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTLiab'' 
						WHEN (tempRMV.Gl_Number = -3) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTAsset'' 
						WHEN (tempRMV.Gl_Number = -4) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTLiab'' 
						WHEN (tempRMV.Gl_Number = -5) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTAsset'' 
						WHEN (tempRMV.Gl_Number = -6) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTLiab'' 
						WHEN (tempRMV.Gl_Number = -7) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTAsset'' 
						WHEN (tempRMV.Gl_Number = -8) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTLiab'' 
						WHEN (tempRMV.Gl_Number = -9) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTAsset'' 
						WHEN (tempRMV.Gl_Number = -10) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTLiab'' 
						WHEN (tempRMV.Gl_Number = -11) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTAsset'' 
						WHEN (tempRMV.Gl_Number = -12) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTLiab'' 
						WHEN (tempRMV.Gl_Number = -13) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxReserve'' 
						WHEN (tempRMV.Gl_Number = -14) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLSettlement'' 
						WHEN (tempRMV.Gl_Number = -15) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AOCI'' 
						WHEN (tempRMV.Gl_Number = -16) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLIneffectiveness'' 
						WHEN (tempRMV.Gl_Number = -17) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Inventory'' 
						WHEN (tempRMV.Gl_Number = -18) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Receivables'' 
						WHEN (tempRMV.Gl_Number = -19) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Cash'' 
						WHEN (tempRMV.Gl_Number = -20) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AccruedInterest'' 
						WHEN (tempRMV.Gl_Number = -21) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Interest'' 
						WHEN (tempRMV.Gl_Number = -22) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Amortization'' 
						WHEN (tempRMV.Gl_Number = -23) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTAsset'' 
						WHEN (tempRMV.Gl_Number = -24) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTLiab'' 
						WHEN (tempRMV.Gl_Number = -25) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTAsset'' 
						WHEN (tempRMV.Gl_Number = -26) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTLiab''  
					ELSE CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Unknown.GL.Code'' END)  '  
	EXEC spa_print @sql_stmt  
	EXEC (@sql_stmt)
 END

IF @summary_option ='s' AND @called_from_netting = 0 -- not called from netting
BEGIN 
	
SET @sql_stmt = 'SELECT ISNULL(gsm.gl_account_number, tempRMV.Gl_Number) AS [GLNumber], 
			ISNULL(gsm.gl_account_name, 
				CASE	WHEN (tempRMV.Gl_Number = -1) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTAsset'' 
						WHEN (tempRMV.Gl_Number = -2) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTLiab'' 
						WHEN (tempRMV.Gl_Number = -3) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTAsset'' 
						WHEN (tempRMV.Gl_Number = -4) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTLiab'' 
						WHEN (tempRMV.Gl_Number = -5) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTAsset'' 
						WHEN (tempRMV.Gl_Number = -6) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTLiab'' 
						WHEN (tempRMV.Gl_Number = -7) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTAsset'' 
						WHEN (tempRMV.Gl_Number = -8) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTLiab'' 
						WHEN (tempRMV.Gl_Number = -9) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTAsset'' 
						WHEN (tempRMV.Gl_Number = -10) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTLiab'' 
						WHEN (tempRMV.Gl_Number = -11) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTAsset'' 
						WHEN (tempRMV.Gl_Number = -12) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTLiab'' 
						WHEN (tempRMV.Gl_Number = -13) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxReserve'' 
						WHEN (tempRMV.Gl_Number = -14) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLSettlement'' 
						WHEN (tempRMV.Gl_Number = -15) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AOCI'' 
						WHEN (tempRMV.Gl_Number = -16) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLIneffectiveness'' 
						WHEN (tempRMV.Gl_Number = -17) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Inventory'' 
						WHEN (tempRMV.Gl_Number = -18) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Receivables'' 
						WHEN (tempRMV.Gl_Number = -19) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Cash'' 
						WHEN (tempRMV.Gl_Number = -20) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AccruedInterest'' 
						WHEN (tempRMV.Gl_Number = -21) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Interest'' 
						WHEN (tempRMV.Gl_Number = -22) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Amortization'' 
								WHEN (tempRMV.Gl_Number = -23) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTAsset'' 
								WHEN (tempRMV.Gl_Number = -24) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTLiab'' 
								WHEN (tempRMV.Gl_Number = -25) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTAsset'' 
								WHEN (tempRMV.Gl_Number = -26) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTLiab''
							ELSE CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Unknown.GL.Code'' END) AS [AccountName],   
							CASE WHEN(SUM(tempRMV.Debit) >= SUM(tempRMV.Credit)) THEN (SUM(tempRMV.Debit) - SUM(tempRMV.Credit))  
		 			ELSE 0 END AS Debit, 
			CASE WHEN (SUM(tempRMV.Debit) < SUM(tempRMV.Credit)) THEN 
						(SUM(tempRMV.Credit) - SUM(tempRMV.Debit))
					ELSE 0 END AS Credit
	FROM         #temp_MTM_JEP tempRMV(NOLOCK) LEFT OUTER JOIN
	             gl_system_mapping gsm(NOLOCK) ON tempRMV.Gl_Number = gsm.gl_number_id LEFT OUTER JOIN
			     portfolio_hierarchy PH2(NOLOCK) ON PH2.entity_id = tempRMV.book_entity_id LEFT OUTER JOIN		
	             portfolio_hierarchy PH1(NOLOCK) ON PH1.entity_id = tempRMV.strategy_entity_id LEFT OUTER JOIN
	             portfolio_hierarchy PH(NOLOCK) ON tempRMV.sub_entity_id = PH.entity_id WHERE 1 = 1'

SET @sql_stmt = @sql_stmt + 
	CASE 
		WHEN @sub_entity_id IS NOT NULL 
		THEN  ' AND PH.entity_id IN (' + CAST ( @sub_entity_id AS VARCHAR(8000)) + ')' ELSE '' 
	END 
	SET @sql_stmt = @sql_stmt +
	CASE	
		WHEN  @strategy_entity_id IS NOT NULL
		THEN ' AND PH1.entity_id IN (' + CAST ( @strategy_entity_id AS VARCHAR(8000)) + ')' ELSE ''
	END
	SET @sql_stmt = @sql_stmt +
	CASE
		WHEN @book_entity_id IS NOT NULL
		THEN ' AND PH2.entity_id IN (' + CAST ( @book_entity_id AS VARCHAR(8000)) + ')' ELSE ''
	END	
	
SET @sql_stmt = @sql_stmt +  ' GROUP BY ISNULL(gsm.gl_account_number, tempRMV.Gl_Number), 
			ISNULL(gsm.gl_account_name, 
				CASE	WHEN (tempRMV.Gl_Number = -1) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTAsset'' 
						WHEN (tempRMV.Gl_Number = -2) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTLiab'' 
						WHEN (tempRMV.Gl_Number = -3) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTAsset'' 
						WHEN (tempRMV.Gl_Number = -4) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTLiab'' 
						WHEN (tempRMV.Gl_Number = -5) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTAsset'' 
						WHEN (tempRMV.Gl_Number = -6) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTLiab'' 
						WHEN (tempRMV.Gl_Number = -7) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTAsset'' 
						WHEN (tempRMV.Gl_Number = -8) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTLiab'' 
						WHEN (tempRMV.Gl_Number = -9) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTAsset'' 
						WHEN (tempRMV.Gl_Number = -10) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTLiab'' 
						WHEN (tempRMV.Gl_Number = -11) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTAsset'' 
						WHEN (tempRMV.Gl_Number = -12) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTLiab'' 
						WHEN (tempRMV.Gl_Number = -13) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxReserve'' 
						WHEN (tempRMV.Gl_Number = -14) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLSettlement'' 
						WHEN (tempRMV.Gl_Number = -15) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AOCI'' 
						WHEN (tempRMV.Gl_Number = -16) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLIneffectiveness'' 
						WHEN (tempRMV.Gl_Number = -17) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Inventory'' 
						WHEN (tempRMV.Gl_Number = -18) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Receivables'' 
						WHEN (tempRMV.Gl_Number = -19) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Cash'' 
						WHEN (tempRMV.Gl_Number = -20) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AccruedInterest'' 
						WHEN (tempRMV.Gl_Number = -21) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Interest'' 
						WHEN (tempRMV.Gl_Number = -22) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Amortization'' 
					WHEN (tempRMV.Gl_Number = -23) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTAsset'' 
					WHEN (tempRMV.Gl_Number = -24) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTLiab'' 
					WHEN (tempRMV.Gl_Number = -25) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTAsset'' 
					WHEN (tempRMV.Gl_Number = -26) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTLiab''  
					ELSE CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Unknown.GL.Code'' END)'  
	EXEC spa_print @sql_stmt  
		EXEC (@sql_stmt)
END 
		
IF @summary_option ='s' AND @called_from_netting = 1  -- called from netting
BEGIN 
	
	SET @sql_stmt = 'SELECT sub_entity_id,
			ISNULL(tempRMV.legal_entity, -1) legal_entity,
			ISNULL(gsm.gl_account_number, tempRMV.Gl_Number) AS [GLNumber], 
			ISNULL(gsm.gl_account_name, 
							CASE WHEN (tempRMV.Gl_Number = -1) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTAsset''   
					WHEN (tempRMV.Gl_Number = -2) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTLiab'' 
					WHEN (tempRMV.Gl_Number = -3) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTAsset'' 
					WHEN (tempRMV.Gl_Number = -4) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTLiab'' 
					WHEN (tempRMV.Gl_Number = -5) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTAsset'' 
					WHEN (tempRMV.Gl_Number = -6) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTLiab'' 
					WHEN (tempRMV.Gl_Number = -7) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTAsset'' 
					WHEN (tempRMV.Gl_Number = -8) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTLiab'' 
					WHEN (tempRMV.Gl_Number = -9) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTAsset'' 
					WHEN (tempRMV.Gl_Number = -10) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTLiab'' 
					WHEN (tempRMV.Gl_Number = -11) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTAsset'' 
					WHEN (tempRMV.Gl_Number = -12) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTLiab'' 
					WHEN (tempRMV.Gl_Number = -13) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxReserve'' 
					WHEN (tempRMV.Gl_Number = -14) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLSettlement'' 
					WHEN (tempRMV.Gl_Number = -15) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AOCI'' 
					WHEN (tempRMV.Gl_Number = -16) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLIneffectiveness'' 
					WHEN (tempRMV.Gl_Number = -17) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Inventory'' 
					WHEN (tempRMV.Gl_Number = -18) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Receivables'' 
					WHEN (tempRMV.Gl_Number = -19) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Cash'' 
					WHEN (tempRMV.Gl_Number = -20) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AccruedInterest'' 
					WHEN (tempRMV.Gl_Number = -21) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Interest'' 
					WHEN (tempRMV.Gl_Number = -22) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Amortization'' 
								WHEN (tempRMV.Gl_Number = -23) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTAsset'' 
								WHEN (tempRMV.Gl_Number = -24) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTLiab'' 
								WHEN (tempRMV.Gl_Number = -25) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTAsset'' 
								WHEN (tempRMV.Gl_Number = -26) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTLiab''  
								ELSE CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Unknown.GL.Code'' END) AS [AccountName],   
			CASE WHEN(SUM(tempRMV.Debit) >= SUM(tempRMV.Credit)) THEN 
						(SUM(tempRMV.Debit) - SUM(tempRMV.Credit))
		 			ELSE 0 END AS Debit, 
			CASE WHEN (SUM(tempRMV.Debit) < SUM(tempRMV.Credit)) THEN 
						(SUM(tempRMV.Credit) - SUM(tempRMV.Debit))
					ELSE 0 END AS Credit
	FROM         #temp_MTM_JEP tempRMV(NOLOCK) LEFT OUTER JOIN
	             gl_system_mapping gsm(NOLOCK) ON tempRMV.Gl_Number = gsm.gl_number_id  LEFT OUTER JOIN
			     portfolio_hierarchy PH2(NOLOCK) ON PH2.entity_id = tempRMV.book_entity_id LEFT OUTER JOIN		
	             portfolio_hierarchy PH1(NOLOCK) ON PH1.entity_id = tempRMV.strategy_entity_id LEFT OUTER JOIN
					portfolio_hierarchy PH(NOLOCK) ON tempRMV.sub_entity_id = PH.entity_id WHERE 1=1 '  
	             
	SET @sql_stmt = @sql_stmt + 
	CASE 
		WHEN @sub_entity_id IS NOT NULL 
		THEN  ' AND PH.entity_id IN (' + CAST ( @sub_entity_id AS VARCHAR(8000)) + ')' ELSE '' 
	END 
	SET @sql_stmt = @sql_stmt +
	CASE	
		WHEN  @strategy_entity_id IS NOT NULL
		THEN ' AND PH1.entity_id IN (' + CAST ( @strategy_entity_id AS VARCHAR(8000)) + ')' ELSE ''
	END
	SET @sql_stmt = @sql_stmt +
	CASE
		WHEN @book_entity_id IS NOT NULL
		THEN ' AND PH2.entity_id IN (' + CAST ( @book_entity_id AS VARCHAR(8000)) + ')' ELSE ''
	END	
	
	SET @sql_stmt = @sql_stmt + ' GROUP BY 	sub_entity_id, 
				ISNULL(tempRMV.legal_entity, -1),
				ISNULL(gsm.gl_account_number, tempRMV.Gl_Number), 
				ISNULL(gsm.gl_account_name, 
					CASE WHEN (tempRMV.Gl_Number = -1) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTAsset''   
						WHEN (tempRMV.Gl_Number = -2) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HSTLiab'' 
						WHEN (tempRMV.Gl_Number = -3) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTAsset'' 
						WHEN (tempRMV.Gl_Number = -4) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.HLTLiab'' 
						WHEN (tempRMV.Gl_Number = -5) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTAsset'' 
						WHEN (tempRMV.Gl_Number = -6) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ISTLiab'' 
						WHEN (tempRMV.Gl_Number = -7) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTAsset'' 
						WHEN (tempRMV.Gl_Number = -8) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.ILTLiab'' 
						WHEN (tempRMV.Gl_Number = -9) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTAsset'' 
						WHEN (tempRMV.Gl_Number = -10) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTLiab'' 
						WHEN (tempRMV.Gl_Number = -11) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTAsset'' 
						WHEN (tempRMV.Gl_Number = -12) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTLiab'' 
						WHEN (tempRMV.Gl_Number = -13) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.TaxReserve'' 
						WHEN (tempRMV.Gl_Number = -14) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLSettlement'' 
						WHEN (tempRMV.Gl_Number = -15) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AOCI'' 
						WHEN (tempRMV.Gl_Number = -16) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.PNLIneffectiveness'' 
						WHEN (tempRMV.Gl_Number = -17) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Inventory'' 
						WHEN (tempRMV.Gl_Number = -18) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Receivables'' 
						WHEN (tempRMV.Gl_Number = -19) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Cash'' 
						WHEN (tempRMV.Gl_Number = -20) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.AccruedInterest'' 
						WHEN (tempRMV.Gl_Number = -21) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Interest'' 
						WHEN (tempRMV.Gl_Number = -22) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.Amortization'' 
						WHEN (tempRMV.Gl_Number = -23) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTAsset'' 
						WHEN (tempRMV.Gl_Number = -24) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTLiab'' 
						WHEN (tempRMV.Gl_Number = -25) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTAsset'' 
						WHEN (tempRMV.Gl_Number = -26) THEN  CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTLiab''   
					ELSE CAST(tempRMV.book_entity_id AS VARCHAR) + ''.Unknown.GL.Code'' END)'  

	--PRINT @sql_stmt  
		EXEC (@sql_stmt)
END 

IF @summary_option = 'v'
BEGIN 
	
	SET @sql_stmt = 'SELECT MAX(tempRMV.Gl_Number) AS GLNumberID,tempRMV.source_book_map_id SourceBookMapID,  
							ISNULL(gsm.gl_account_number, MAX(tempRMV.Gl_Number)) AS [GLNumber],   
							ISNULL(MAX(gsm.gl_account_name),   
							CASE WHEN (MAX(tempRMV.Gl_Number) = -1) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.HSTAsset''   
							WHEN (MAX(tempRMV.Gl_Number) = -2) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.HSTLiab''   
							WHEN (MAX(tempRMV.Gl_Number) = -3) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.HLTAsset''   
							WHEN (MAX(tempRMV.Gl_Number) = -4) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.HLTLiab''   
							WHEN (MAX(tempRMV.Gl_Number) = -5) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.ISTAsset''   
							WHEN (MAX(tempRMV.Gl_Number) = -6) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.ISTLiab''   
							WHEN (MAX(tempRMV.Gl_Number) = -7) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.ILTAsset''   
							WHEN (MAX(tempRMV.Gl_Number) = -8) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.ILTLiab''   
							WHEN (MAX(tempRMV.Gl_Number) = -9) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.TaxSTAsset''   
							WHEN (MAX(tempRMV.Gl_Number) = -10) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.TaxSTLiab''   
							WHEN (MAX(tempRMV.Gl_Number) = -11) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.TaxLTAsset''   
							WHEN (MAX(tempRMV.Gl_Number) = -12) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.TaxLTLiab''   
							WHEN (MAX(tempRMV.Gl_Number) = -13) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.TaxReserve''   
							WHEN (MAX(tempRMV.Gl_Number) = -14) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.PNLSettlement''   
							WHEN (MAX(tempRMV.Gl_Number) = -15) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.AOCI''   
							WHEN (MAX(tempRMV.Gl_Number) = -16) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.PNLIneffectiveness''   
							WHEN (MAX(tempRMV.Gl_Number) = -17) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.Inventory''   
							WHEN (MAX(tempRMV.Gl_Number) = -18) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.Receivables''   
							WHEN (MAX(tempRMV.Gl_Number) = -19) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.Cash''   
							WHEN (MAX(tempRMV.Gl_Number) = -20) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.AccruedInterest''   
							WHEN (MAX(tempRMV.Gl_Number) = -21) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.Interest''   
							WHEN (MAX(tempRMV.Gl_Number) = -22) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.Amortization''   
							WHEN (MAX(tempRMV.Gl_Number) = -23) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.UnHSTAsset'' 
							WHEN (MAX(tempRMV.Gl_Number) = -24) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.UnHSTLiab'' 
							WHEN (MAX(tempRMV.Gl_Number) = -25) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.UnHLTAsset'' 
							WHEN (MAX(tempRMV.Gl_Number) = -26) THEN  CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Undefined.UnHLTLiab''
							ELSE CAST(MAX(tempRMV.book_entity_id) AS VARCHAR) + ''.Unknown.GL.Code'' END) AS [AccountName],   
				CASE WHEN(SUM(tempRMV.Debit) >= SUM(tempRMV.Credit)) THEN 
							(SUM(tempRMV.Debit) - SUM(tempRMV.Credit))
		 				ELSE 0 END AS Debit, 
				CASE WHEN (SUM(tempRMV.Debit) < SUM(tempRMV.Credit)) THEN 
							(SUM(tempRMV.Credit) - SUM(tempRMV.Debit))
						ELSE 0 END AS Credit
		FROM        #temp_MTM_JEP tempRMV(NOLOCK)
		--INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = tempRMV.book_entity_id 
		LEFT JOIN gl_system_mapping gsm(NOLOCK) ON tempRMV.Gl_Number = gsm.gl_number_id LEFT OUTER JOIN
			     portfolio_hierarchy PH2(NOLOCK) ON PH2.entity_id = tempRMV.book_entity_id LEFT OUTER JOIN		
	             portfolio_hierarchy PH1(NOLOCK) ON PH1.entity_id = tempRMV.strategy_entity_id LEFT OUTER JOIN
	             portfolio_hierarchy PH(NOLOCK) ON tempRMV.sub_entity_id = PH.entity_id WHERE 1 = 1 ' 
		
	SET @sql_stmt = @sql_stmt + 
	CASE 
		WHEN @sub_entity_id IS NOT NULL 
		THEN  ' AND PH.entity_id IN (' + CAST ( @sub_entity_id AS VARCHAR(8000)) + ')' ELSE '' 
	END 
	SET @sql_stmt = @sql_stmt +
	CASE	
		WHEN  @strategy_entity_id IS NOT NULL
		THEN ' AND PH1.entity_id IN (' + CAST ( @strategy_entity_id AS VARCHAR(8000)) + ')' ELSE ''
	END
	SET @sql_stmt = @sql_stmt +
	CASE
		WHEN @book_entity_id IS NOT NULL
		THEN ' AND PH2.entity_id IN (' + CAST (@book_entity_id AS VARCHAR(8000)) + ')' ELSE ''
	END	

	--VERIFY: whether GROUP BY should be done by tempRMV.source_book_map_id, tempRMV.Gl_Number as gsm.gl_account_number will be NULL for -ve GL_Number
	SET @sql_stmt = @sql_stmt +  ' GROUP BY tempRMV.source_book_map_id, tempRMV.Gl_Number, gsm.gl_account_number'
		--PRINT @sql_stmt
		EXEC (@sql_stmt)
		
END 
