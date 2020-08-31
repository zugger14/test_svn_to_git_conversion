

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_Create_Hedges_Measurement_Report]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Hedges_Measurement_Report]
GO
/****** Object:  StoredProcedure [dbo].[spa_Create_Hedges_Measurement_Report]    Script Date: 10/16/2010 23:30:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec spa_Create_Hedges_Measurement_Report '2009-08-31', '58', NULL, NULL, 'd', 'a', 'c', 'm', NULL,'2',NULL,'n',NULL,NULL

--exec spa_Create_Hedges_Measurement_Report '2009-07-31', '36', NULL, NULL, 'd', 'a', 'c', 'm', NULL,'2',NULL,'n'
--exec spa_Create_Hedges_Measurement_Report '2004-12-31', '30', '208', '223', 'd', 'a', 'c', 'd', NULL
--exec spa_Create_Hedges_Measurement_Report '2005-10-31', '30', NULL, NULL, 'd', 'a', 'f', 'd', NULL

--01/17/2006 CHANGED THE SETTLEMENT LOGIC TO BRING FROM RMV AND NOT FROM NETTING TABLES...

--exec spa_Create_Hedges_Measurement_Report '2006-01-30', NULL, NULL, NULL, 'd', 'c', 'a', 'd', 511

-- exec spa_Create_hedges_Measurement_Report '7/30/2004', NULL, null, null, 'd', 'f', 'a', 'd', 186
-- EXEC spa_Create_Hedges_Measurement_Report  '7/31/2003', '1,2,20', null, null, 'd', 'f', 'c', 'd'
-- EXEC spa_Create_Hedges_Measurement_Report  '1/31/2003', '1', null, null, 'd', 'f', 'f', 'd'

--===========================================================================================
--This Procedure create Measuremetnt Reports
--Input Parameters
--@as_of_date - effective date
--@sub_entity_id - subsidiary Id
--@strategy_entity_id - strategy Id
--@book_entity_id - book Id
--@discount_option - takes two values 'd' or 'u', corresponding to 'discounted', 'undiscounted' 
--@settlement_option -  takes 'f','c','s','a' corrsponding to 'forward', 'current & forward', 'current & settled', 'all' transactions
--@report_type - takes 'f', 'c',  corresponding to 'fair value', 'cash flow'
--@summary_option - takes 'd', 's' corresponding to 'detail' , 'summary' report, 'm' detail by deal
--===========================================================================================
 CREATE PROC [dbo].[spa_Create_Hedges_Measurement_Report] 
	@as_of_date VARCHAR(50), 
	@sub_entity_id VARCHAR(MAX), 
 	@strategy_entity_id VARCHAR(MAX) = NULL, 
	@book_entity_id VARCHAR(MAX) = NULL, 
	@discount_option CHAR(1), 
	@settlement_option CHAR(1), 
	@report_type CHAR(1), 
	@summary_option CHAR(1), --'s' for summary 'd' for detail and 'l' link level, 'm' deatil deal
	@link_id VARCHAR(500) = NULL,
	@round_value VARCHAR(1) = '0',
	@legal_entity VARCHAR(50) = NULL,
	@hypothetical VARCHAR(1) = 'n',  --n means do not show hypothetical, o means only hypothetical and a means both
	@source_deal_header_id VARCHAR(500)=NULL,
	@deal_id VARCHAR(500)=NULL,	
	@term_start DATETIME=NULL,
	@term_end DATETIME=NULL,
	@link_id_to VARCHAR(500) = NULL,
	@link_desc VARCHAR(500)=NULL,
	@batch_process_id VARCHAR(50)=NULL,	
	@batch_report_param VARCHAR(1000)=NULL,
	@enable_paging INT=0,  --'1'=enable, '0'=disable
	@page_size INT =NULL,
	@page_no INT=NULL

 AS
 SET NOCOUNT ON
/*
-- 
--exec spa_Create_Hedges_Measurement_Report '2011-12-31', '4', NULL, NULL, 'd', 'f', 'c', 'm', '30496','2',NULL,'n',NULL,NULL,NULL,NULL,NULL,NULL

 declare 	@as_of_date varchar(50)='2011-12-31', 
	@sub_entity_id varchar(200)='4', 
 	@strategy_entity_id varchar(500) = NULL, 
	@book_entity_id varchar(500) = NULL, 
	@discount_option char(1)='d', 
	@settlement_option char(1)='f', 
	@report_type char(1)='c', 
	@summary_option char(1)='m', --'s' for summary 'd' for detail and 'l' link level, 'm' deatil deal
	@link_id varchar(500) = '30496',
	@round_value varchar(1) = '2',
	@legal_entity varchar(50) = NULL,
	@hypothetical varchar(1) = 'n',  --n means do not show hypothetical, o means only hypothetical and a means both
	@source_deal_header_id varchar(500)=NULL,
	@deal_id varchar(500)=NULL,	
	@term_start DATETIME=NULL,
	@term_end DATETIME=NULL,
	@link_id_to varchar(500) = null,
	@link_desc VARCHAR(500)=null,
	@batch_process_id varchar(50)=NULL,	
	@batch_report_param varchar(1000)=NULL,
	@enable_paging int=0,  --'1'=enable, '0'=disable
	@page_size int =NULL,
	@page_no int=NULL

drop table #links
drop table #dol_offset
drop table #RMV
drop table #aaaaaa
--*/
DECLARE @Sql_Select VARCHAR(MAX)
DECLARE @Sql_From VARCHAR(5000)

DECLARE @Sql_Where VARCHAR(5000)
DECLARE @Sql_Where1 VARCHAR(5000)

DECLARE @Sql_GpBy VARCHAR(5000)

DECLARE @Sql_OrderBy VARCHAR(5000)

DECLARE @Sql1 VARCHAR(8000)
DECLARE @Sql2 VARCHAR(8000)
--*****************For batch processing********************************   

--If @term_start IS NOT NULL and @term_end IS NULL
--	SET @term_end=@term_start
--If @term_start IS NULL and @term_end IS NOT NULL
--	SET @term_start=@term_end

--////////////////////////////Paging_Batch///////////////////////////////////////////
EXEC spa_print	'@batch_process_id:', @batch_process_id 
EXEC spa_print	'@batch_report_param:',	@batch_report_param

DECLARE @str_batch_table VARCHAR(MAX),@str_get_row_number VARCHAR(100)
DECLARE @temptablename VARCHAR(100),@user_login_id VARCHAR(50),@flag CHAR(1)
DECLARE @is_batch BIT
DECLARE @sql_paging VARCHAR(MAX)



DECLARE @sql_stmt VARCHAR(5000)

SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
 
IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()
 
   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
 
   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END

--////////////////////////////End_Batch///////////////////////////////////////////



IF @link_id IS NOT NULL AND @link_id_to IS NULL
	SET @link_id_to=@link_id

IF @link_id IS NULL AND @link_id_to IS NOT NULL
	SET @link_id=@link_id_to

IF @hypothetical IS NULL
	SET @hypothetical = 'n'

--If @link_id is not null and sub_id is not  pased
IF @report_type = 'a' AND (@link_id IS NOT NULL OR @link_desc IS NOT NULL)
BEGIN
	CREATE TABLE #tmpRType
	(
	  hedge_type_value_id INT
	)
	
	SET @Sql_Select=
	'insert into #tmpRType 
	select min(ISNULL(flh.hedge_type_value_id, stra.hedge_type_value_id) as hedge_type_value_id 
	from 
		fas_strategy stra inner join
		portfolio_hierarchy book on book.parent_entity_id = stra.fas_strategy_id inner join
		fas_link_header flh on flh.fas_book_id = book.entity_id 
	where 1=1 '
	+CASE WHEN @link_id IS NOT NULL THEN ' AND (flh.link_id BETWEEN '+@link_id+' AND '+@link_id_to+' OR flh.link_id BETWEEN '+@link_id+' AND '+@link_id_to+')' ELSE '' END
	+CASE WHEN @link_desc IS NOT NULL THEN ' AND flh.link_description like '''+@link_desc+'%''' ELSE '' END

	EXEC(@Sql_Select)
	

	SELECT @report_type = CASE WHEN (hedge_type_value_id = 150) THEN  'c' 
			      WHEN (hedge_type_value_id = 151) THEN  'f'
			      ELSE 'm' END 

	FROM  #tmpRType

END


CREATE TABLE #links
(
link_id VARCHAR(500) COLLATE DATABASE_DEFAULT  
)

----include deals that are dedsignated 
IF (@link_id IS NOT NULL OR @link_desc IS NOT NULL)
BEGIN

	SET @Sql_Select=
	'insert into #links
	select cast(source_deal_header_id as varchar) + ''d'' 
	from fas_link_detail fld 
	INNER JOIN fas_link_header flh ON fld.link_id=flh.link_id
	where hedge_or_item = ''h'''
		+CASE WHEN @link_id IS NOT NULL THEN ' AND (flh.link_id BETWEEN '+@link_id+' AND '+@link_id_to+' OR flh.original_link_id BETWEEN '+@link_id+' AND '+@link_id_to+')' ELSE '' END
		+ CASE WHEN @link_desc IS NOT NULL THEN ' AND flh.link_description like '''+@link_desc+'%''' ELSE '' END

	+' and percentage_included <> 0
	union
	select cast(link_id as varchar) + ''l'' from 
	fas_link_header flh 
	WHERE 1=1 '+
	+CASE WHEN @link_id IS NOT NULL THEN ' AND (flh.link_id BETWEEN '+@link_id+' AND '+@link_id_to+' OR flh.original_link_id BETWEEN '+@link_id+' AND '+@link_id_to+')' ELSE '' END
	+CASE WHEN @link_desc IS NOT NULL THEN ' AND flh.link_description like '''+@link_desc+'%''' ELSE '' END
	
	EXEC(@Sql_Select)


END
ELSE IF @source_deal_header_id IS NOT NULL OR @deal_id IS NOT NULL
BEGIN
	DECLARE @deal_id1 VARCHAR(1000)

	IF @deal_id = '' OR @deal_id IS NULL
		SET @deal_id1 = NULL
	ELSE
	BEGIN
		--SET @deal_id1 = REPLACE(@deal_id, ' ', '')
		SET @deal_id1 = @deal_id
		SET @deal_id1 = '''' + REPLACE(@deal_id1, ',', ''',''') + ''''
	END

	SET @Sql_Select =
	'
	insert into #links
	select	cast(link_id as varchar) + ''l''
	from	fas_link_detail fld inner join
		source_deal_header sdh on sdh.source_deal_header_id = fld.source_deal_header_id 
	where   1 = 1  
	' +
	CASE WHEN (@source_deal_header_id IS NOT NULL) THEN ' AND sdh.source_deal_header_id in (' + @source_deal_header_id + ')' ELSE '' END +
	CASE WHEN (@deal_id1 IS NOT NULL) THEN ' AND sdh.deal_id in (' + @deal_id1 + ')' ELSE '' END + 
	' UNION
	select cast(sdh.source_deal_header_id as varchar) + ''d''
	from source_deal_header sdh where 1 = 1 ' +
	CASE WHEN (@source_deal_header_id IS NOT NULL) THEN ' AND sdh.source_deal_header_id in (' + @source_deal_header_id + ')' ELSE '' END +
	CASE WHEN (@deal_id1 IS NOT NULL) THEN ' AND sdh.deal_id in (' + @deal_id1 + ')' ELSE '' END 

	EXEC(@Sql_Select)
END


CREATE TABLE #dol_offset
(link_id INT, dol_offset FLOAT NULL)

IF @summary_option = 'l'
BEGIN

SET @Sql_Select =
	'insert into #dol_offset
	select link_id, max(dol_offset) dol_offset from ' + dbo.FNAGetProcessTableName(@as_of_date,'calcprocess_deals') + ' 
	where link_type = ''link'' and as_of_date = ''' + @as_of_date + '''' +
	CASE WHEN (@sub_entity_id IS NOT NULL) THEN ' AND (fas_subsidiary_id IN(' + @sub_entity_id + ' ))' ELSE '' END	+
	CASE WHEN (@strategy_entity_id IS NOT NULL) THEN ' AND (fas_strategy_id IN(' + @strategy_entity_id + ' ))' ELSE '' END	+
	CASE WHEN (@book_entity_id IS NOT NULL) THEN ' AND (fas_book_id IN(' + @book_entity_id + ' ))' ELSE '' END	+		
	' group by link_id '

EXEC(@Sql_Select)
END



SELECT RMV.as_of_date
, RMV.sub_entity_id
, RMV.strategy_entity_id
, RMV.book_entity_id
, RMV.link_id
, RMV.link_deal_flag
, RMV.term_month
, RMV.hedge_item_flag
, RMV.assessment_type
, RMV.assessment_value
, RMV.u_hedge_mtm
, RMV.u_item_mtm
, RMV.u_hedge_st_asset
, RMV.u_hedge_lt_asset
, RMV.u_hedge_st_liability
, RMV.u_hedge_lt_liability
, RMV.u_item_st_asset
, RMV.u_item_lt_asset
, RMV.u_item_st_liability
, RMV.u_item_lt_liability
, RMV.u_laoci
, RMV.u_aoci
, RMV.u_total_aoci
, RMV.u_pnl_extrinsic
, RMV.u_pnl_dedesignation
, RMV.u_pnl_ineffectiveness
, RMV.u_pnl_mtm
, RMV.u_pnl_settlement
, RMV.u_total_pnl
, RMV.U_cash
, RMV.discount_factor
, RMV.d_hedge_mtm
, RMV.d_item_mtm
, RMV.d_hedge_st_asset
, RMV.d_hedge_lt_asset
, RMV.d_hedge_st_liability
, RMV.d_hedge_lt_liability
, RMV.d_item_st_asset
, RMV.d_item_lt_asset
, RMV.d_item_st_liability
, RMV.d_item_lt_liability
, RMV.d_laoci
, RMV.d_aoci
, RMV.d_total_aoci
, RMV.d_pnl_extrinsic
, RMV.d_pnl_dedesignation
, RMV.d_pnl_ineffectiveness
, RMV.d_pnl_mtm
, RMV.d_pnl_settlement
, RMV.d_total_pnl
, RMV.d_cash
, RMV.currency_unit
, RMV.gl_code_hedge_st_asset
, RMV.gl_code_hedge_st_liability
, RMV.gl_code_hedge_lt_asset
, RMV.gl_code_hedge_lt_liability
, RMV.gl_code_item_st_asset
, RMV.gl_code_item_st_liability
, RMV.gl_code_item_lt_asset
, RMV.gl_code_item_lt_liability
, RMV.gl_aoci
, RMV.gl_pnl
, RMV.gl_settlement
, RMV.gl_cash
, RMV.assessment_date
, RMV.settled_test
, RMV.assessment_test
, RMV.cfv_test
, RMV.hedge_type_value_id
, RMV.hedge_asset_test
, RMV.item_asset_test
, RMV.u_unlinked_pnl_ineffectiveness
, RMV.u_current_pnl_ineffectiveness
, RMV.d_unlinked_pnl_ineffectiveness
, RMV.d_current_pnl_ineffectiveness
, RMV.u_des_pnl_ineffectiveness
, RMV.d_des_pnl_ineffectiveness
, RMV.gl_inventory
, RMV.u_pnl_inventory
, RMV.d_pnl_inventory
, RMV.u_aoci_released
, RMV.aoci_asset_test
, RMV.u_st_tax_asset
, RMV.u_lt_tax_asset
, RMV.u_st_tax_liability
, RMV.u_lt_tax_liability
, RMV.u_tax_reserve
, RMV.d_st_tax_asset
, RMV.d_lt_tax_asset
, RMV.d_st_tax_liability
, RMV.d_lt_tax_liability
, RMV.d_tax_reserve
, RMV.gl_id_st_tax_asset
, RMV.gl_id_st_tax_liab
, RMV.gl_id_lt_tax_asset
, RMV.gl_id_lt_tax_liab
, RMV.gl_id_tax_reserve
, RMV.link_type_value_id
, RMV.create_user
, RMV.create_ts
, RMV.valuation_date
, RMV.d_aoci_released INTO #RMV FROM report_measurement_values RMV WHERE 1 = 2

SET @Sql_Select = '

	INSERT INTO #RMV (
RMV.as_of_date
, RMV.sub_entity_id
, RMV.strategy_entity_id
, RMV.book_entity_id
, RMV.link_id
, RMV.link_deal_flag
, RMV.term_month
, RMV.hedge_item_flag
, RMV.assessment_type
, RMV.assessment_value
, RMV.u_hedge_mtm
, RMV.u_item_mtm
, RMV.u_hedge_st_asset
, RMV.u_hedge_lt_asset
, RMV.u_hedge_st_liability
, RMV.u_hedge_lt_liability
, RMV.u_item_st_asset
, RMV.u_item_lt_asset
, RMV.u_item_st_liability
, RMV.u_item_lt_liability
, RMV.u_laoci
, RMV.u_aoci
, RMV.u_total_aoci
, RMV.u_pnl_extrinsic
, RMV.u_pnl_dedesignation
, RMV.u_pnl_ineffectiveness
, RMV.u_pnl_mtm
, RMV.u_pnl_settlement
, RMV.u_total_pnl
, RMV.U_cash
, RMV.discount_factor
, RMV.d_hedge_mtm
, RMV.d_item_mtm
, RMV.d_hedge_st_asset
, RMV.d_hedge_lt_asset
, RMV.d_hedge_st_liability
, RMV.d_hedge_lt_liability
, RMV.d_item_st_asset
, RMV.d_item_lt_asset
, RMV.d_item_st_liability
, RMV.d_item_lt_liability
, RMV.d_laoci
, RMV.d_aoci
, RMV.d_total_aoci
, RMV.d_pnl_extrinsic
, RMV.d_pnl_dedesignation
, RMV.d_pnl_ineffectiveness
, RMV.d_pnl_mtm
, RMV.d_pnl_settlement
, RMV.d_total_pnl
, RMV.d_cash
, RMV.currency_unit
, RMV.gl_code_hedge_st_asset
, RMV.gl_code_hedge_st_liability
, RMV.gl_code_hedge_lt_asset
, RMV.gl_code_hedge_lt_liability
, RMV.gl_code_item_st_asset
, RMV.gl_code_item_st_liability
, RMV.gl_code_item_lt_asset
, RMV.gl_code_item_lt_liability
, RMV.gl_aoci
, RMV.gl_pnl
, RMV.gl_settlement
, RMV.gl_cash
, RMV.assessment_date
, RMV.settled_test
, RMV.assessment_test
, RMV.cfv_test
, RMV.hedge_type_value_id
, RMV.hedge_asset_test
, RMV.item_asset_test
, RMV.u_unlinked_pnl_ineffectiveness
, RMV.u_current_pnl_ineffectiveness
, RMV.d_unlinked_pnl_ineffectiveness
, RMV.d_current_pnl_ineffectiveness
, RMV.u_des_pnl_ineffectiveness
, RMV.d_des_pnl_ineffectiveness
, RMV.gl_inventory
, RMV.u_pnl_inventory
, RMV.d_pnl_inventory
, RMV.u_aoci_released
, RMV.aoci_asset_test
, RMV.u_st_tax_asset
, RMV.u_lt_tax_asset
, RMV.u_st_tax_liability
, RMV.u_lt_tax_liability
, RMV.u_tax_reserve
, RMV.d_st_tax_asset
, RMV.d_lt_tax_asset
, RMV.d_st_tax_liability
, RMV.d_lt_tax_liability
, RMV.d_tax_reserve
, RMV.gl_id_st_tax_asset
, RMV.gl_id_st_tax_liab
, RMV.gl_id_lt_tax_asset
, RMV.gl_id_lt_tax_liab
, RMV.gl_id_tax_reserve
, RMV.link_type_value_id
, RMV.create_user
, RMV.create_ts
, RMV.valuation_date
, RMV.d_aoci_released)
 select 
 RMV.as_of_date
, RMV.sub_entity_id
, RMV.strategy_entity_id
, RMV.book_entity_id
, RMV.link_id
, RMV.link_deal_flag
, RMV.term_month
, RMV.hedge_item_flag
, RMV.assessment_type
, RMV.assessment_value
, RMV.u_hedge_mtm
, RMV.u_item_mtm
, RMV.u_hedge_st_asset
, RMV.u_hedge_lt_asset
, RMV.u_hedge_st_liability
, RMV.u_hedge_lt_liability
, RMV.u_item_st_asset
, RMV.u_item_lt_asset
, RMV.u_item_st_liability
, RMV.u_item_lt_liability
, RMV.u_laoci
, RMV.u_aoci
, RMV.u_total_aoci
, RMV.u_pnl_extrinsic
, RMV.u_pnl_dedesignation
, RMV.u_pnl_ineffectiveness
, RMV.u_pnl_mtm
, RMV.u_pnl_settlement
, RMV.u_total_pnl
, RMV.U_cash
, RMV.discount_factor
, RMV.d_hedge_mtm
, RMV.d_item_mtm
, RMV.d_hedge_st_asset
, RMV.d_hedge_lt_asset
, RMV.d_hedge_st_liability
, RMV.d_hedge_lt_liability
, RMV.d_item_st_asset
, RMV.d_item_lt_asset
, RMV.d_item_st_liability
, RMV.d_item_lt_liability
, RMV.d_laoci
, RMV.d_aoci
, RMV.d_total_aoci
, RMV.d_pnl_extrinsic
, RMV.d_pnl_dedesignation
, RMV.d_pnl_ineffectiveness
, RMV.d_pnl_mtm
, RMV.d_pnl_settlement
, RMV.d_total_pnl
, RMV.d_cash
, RMV.currency_unit
, RMV.gl_code_hedge_st_asset
, RMV.gl_code_hedge_st_liability
, RMV.gl_code_hedge_lt_asset
, RMV.gl_code_hedge_lt_liability
, RMV.gl_code_item_st_asset
, RMV.gl_code_item_st_liability
, RMV.gl_code_item_lt_asset
, RMV.gl_code_item_lt_liability
, RMV.gl_aoci
, RMV.gl_pnl
, RMV.gl_settlement
, RMV.gl_cash
, RMV.assessment_date
, RMV.settled_test
, RMV.assessment_test
, RMV.cfv_test
, RMV.hedge_type_value_id
, RMV.hedge_asset_test
, RMV.item_asset_test
, RMV.u_unlinked_pnl_ineffectiveness
, RMV.u_current_pnl_ineffectiveness
, RMV.d_unlinked_pnl_ineffectiveness
, RMV.d_current_pnl_ineffectiveness
, RMV.u_des_pnl_ineffectiveness
, RMV.d_des_pnl_ineffectiveness
, RMV.gl_inventory
, RMV.u_pnl_inventory
, RMV.d_pnl_inventory
, RMV.u_aoci_released
, RMV.aoci_asset_test
, RMV.u_st_tax_asset
, RMV.u_lt_tax_asset
, RMV.u_st_tax_liability
, RMV.u_lt_tax_liability
, RMV.u_tax_reserve
, RMV.d_st_tax_asset
, RMV.d_lt_tax_asset
, RMV.d_st_tax_liability
, RMV.d_lt_tax_liability
, RMV.d_tax_reserve
, RMV.gl_id_st_tax_asset
, RMV.gl_id_st_tax_liab
, RMV.gl_id_lt_tax_asset
, RMV.gl_id_lt_tax_liab
, RMV.gl_id_tax_reserve
, RMV.link_type_value_id
, RMV.create_user
, RMV.create_ts
, RMV.valuation_date
, RMV.d_aoci_released
 FROM ' + dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + ' RMV 
	INNER JOIN fas_books fb ON fb.fas_book_id = RMV.book_entity_id 
	INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id 
'

SET @Sql_Where1 = ' WHERE 1 = 1 AND (RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) '

SET @Sql_Where = ''
IF @sub_entity_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (RMV.sub_entity_id IN(' + @sub_entity_id + ' ))'			
IF @strategy_entity_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
IF @book_entity_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '

IF @legal_entity IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (fb.legal_entity IN(' + @legal_entity + ')) '

IF @link_id IS NOT NULL OR @source_deal_header_id IS NOT NULL OR @deal_id IS NOT NULL OR @link_desc IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND ((cast(RMV.link_id as varchar) + RMV.link_deal_flag) IN (select link_id from #links)) ' 	

--For Cash Flow
IF @report_type = 'c'
	SET @Sql_Where = @Sql_Where + ' AND ISNULL(fb.hedge_type_value_id, FS.hedge_type_value_id) = 150'
ELSE
	SET @Sql_Where = @Sql_Where + ' AND ISNULL(fb.hedge_type_value_id, FS.hedge_type_value_id) = 151'

IF @settlement_option = 'f' -- f
   SET @Sql_Where = @Sql_Where + ' and term_month > ''' +  CAST(@as_of_date AS VARCHAR) + ''''
ELSE IF @settlement_option = 'c' -- c, f
   SET @Sql_Where = @Sql_Where + ' and term_month >= ''' +  dbo.FNAGetContractMonth(@as_of_date)  + ''''
ELSE IF @settlement_option = 's' -- c, s
   SET @Sql_Where = @Sql_Where + ' and term_month <= ''' +  dbo.FNAGetContractMonth(@as_of_date) + ''''

IF @hypothetical = 'n'
	SET @Sql_Where = @Sql_Where + ' AND (fb.no_link IS NULL OR fb.no_link = ''n'') '
IF @hypothetical = 'o'
	SET @Sql_Where = @Sql_Where + ' AND (fb.no_link = ''y'') '


IF (@term_start IS NOT NULL)
	SET @Sql_Where = @Sql_Where +' AND convert(varchar(10),term_month,120) >='''+CONVERT(VARCHAR(10),@term_start,120) +''''

IF (@term_end IS NOT NULL)
	SET @Sql_Where = @Sql_Where +' AND convert(varchar(10),term_month,120)<='''+CONVERT(VARCHAR(10),@term_end,120) +''''

EXEC spa_print @Sql_Select, @Sql_Where1, @Sql_Where

EXEC (@Sql_Select + @Sql_Where1 + @Sql_Where)





SET @Sql_Select = 'insert into #RMV 
(RMV.as_of_date
, RMV.sub_entity_id
, RMV.strategy_entity_id
, RMV.book_entity_id
, RMV.link_id
, RMV.link_deal_flag
, RMV.term_month
, RMV.hedge_item_flag
, RMV.assessment_type
, RMV.assessment_value
, RMV.u_hedge_mtm
, RMV.u_item_mtm
, RMV.u_hedge_st_asset
, RMV.u_hedge_lt_asset
, RMV.u_hedge_st_liability
, RMV.u_hedge_lt_liability
, RMV.u_item_st_asset
, RMV.u_item_lt_asset
, RMV.u_item_st_liability
, RMV.u_item_lt_liability
, RMV.u_laoci
, RMV.u_aoci
, RMV.u_total_aoci
, RMV.u_pnl_extrinsic
, RMV.u_pnl_dedesignation
, RMV.u_pnl_ineffectiveness
, RMV.u_pnl_mtm
, RMV.u_pnl_settlement
, RMV.u_total_pnl
, RMV.U_cash
, RMV.discount_factor
, RMV.d_hedge_mtm
, RMV.d_item_mtm
, RMV.d_hedge_st_asset
, RMV.d_hedge_lt_asset
, RMV.d_hedge_st_liability
, RMV.d_hedge_lt_liability
, RMV.d_item_st_asset
, RMV.d_item_lt_asset
, RMV.d_item_st_liability
, RMV.d_item_lt_liability
, RMV.d_laoci
, RMV.d_aoci
, RMV.d_total_aoci
, RMV.d_pnl_extrinsic
, RMV.d_pnl_dedesignation
, RMV.d_pnl_ineffectiveness
, RMV.d_pnl_mtm
, RMV.d_pnl_settlement
, RMV.d_total_pnl
, RMV.d_cash
, RMV.currency_unit
, RMV.gl_code_hedge_st_asset
, RMV.gl_code_hedge_st_liability
, RMV.gl_code_hedge_lt_asset
, RMV.gl_code_hedge_lt_liability
, RMV.gl_code_item_st_asset
, RMV.gl_code_item_st_liability
, RMV.gl_code_item_lt_asset
, RMV.gl_code_item_lt_liability
, RMV.gl_aoci
, RMV.gl_pnl
, RMV.gl_settlement
, RMV.gl_cash
, RMV.assessment_date
, RMV.settled_test
, RMV.assessment_test
, RMV.cfv_test
, RMV.hedge_type_value_id
, RMV.hedge_asset_test
, RMV.item_asset_test
, RMV.u_unlinked_pnl_ineffectiveness
, RMV.u_current_pnl_ineffectiveness
, RMV.d_unlinked_pnl_ineffectiveness
, RMV.d_current_pnl_ineffectiveness
, RMV.u_des_pnl_ineffectiveness
, RMV.d_des_pnl_ineffectiveness
, RMV.gl_inventory
, RMV.u_pnl_inventory
, RMV.d_pnl_inventory
, RMV.u_aoci_released
, RMV.aoci_asset_test
, RMV.u_st_tax_asset
, RMV.u_lt_tax_asset
, RMV.u_st_tax_liability
, RMV.u_lt_tax_liability
, RMV.u_tax_reserve
, RMV.d_st_tax_asset
, RMV.d_lt_tax_asset
, RMV.d_st_tax_liability
, RMV.d_lt_tax_liability
, RMV.d_tax_reserve
, RMV.gl_id_st_tax_asset
, RMV.gl_id_st_tax_liab
, RMV.gl_id_lt_tax_asset
, RMV.gl_id_lt_tax_liab
, RMV.gl_id_tax_reserve
, RMV.link_type_value_id
, RMV.create_user
, RMV.create_ts
, RMV.valuation_date
, RMV.d_aoci_released)
select
RMV.as_of_date
, RMV.sub_entity_id
, RMV.strategy_entity_id
, RMV.book_entity_id
, RMV.link_id
, RMV.link_deal_flag
, RMV.term_month
, RMV.hedge_item_flag
, RMV.assessment_type
, RMV.assessment_value
, RMV.u_hedge_mtm
, RMV.u_item_mtm
, RMV.u_hedge_st_asset
, RMV.u_hedge_lt_asset
, RMV.u_hedge_st_liability
, RMV.u_hedge_lt_liability
, RMV.u_item_st_asset
, RMV.u_item_lt_asset
, RMV.u_item_st_liability
, RMV.u_item_lt_liability
, RMV.u_laoci
, RMV.u_aoci
, RMV.u_total_aoci
, RMV.u_pnl_extrinsic
, RMV.u_pnl_dedesignation
, RMV.u_pnl_ineffectiveness
, RMV.u_pnl_mtm
, RMV.u_pnl_settlement
, RMV.u_total_pnl
, RMV.U_cash
, RMV.discount_factor
, RMV.d_hedge_mtm
, RMV.d_item_mtm
, RMV.d_hedge_st_asset
, RMV.d_hedge_lt_asset
, RMV.d_hedge_st_liability
, RMV.d_hedge_lt_liability
, RMV.d_item_st_asset
, RMV.d_item_lt_asset
, RMV.d_item_st_liability
, RMV.d_item_lt_liability
, RMV.d_laoci
, RMV.d_aoci
, RMV.d_total_aoci
, RMV.d_pnl_extrinsic
, RMV.d_pnl_dedesignation
, RMV.d_pnl_ineffectiveness
, RMV.d_pnl_mtm
, RMV.d_pnl_settlement
, RMV.d_total_pnl
, RMV.d_cash
, RMV.currency_unit
, RMV.gl_code_hedge_st_asset
, RMV.gl_code_hedge_st_liability
, RMV.gl_code_hedge_lt_asset
, RMV.gl_code_hedge_lt_liability
, RMV.gl_code_item_st_asset
, RMV.gl_code_item_st_liability
, RMV.gl_code_item_lt_asset
, RMV.gl_code_item_lt_liability
, RMV.gl_aoci
, RMV.gl_pnl
, RMV.gl_settlement
, RMV.gl_cash
, RMV.assessment_date
, RMV.settled_test
, RMV.assessment_test
, RMV.cfv_test
, RMV.hedge_type_value_id
, RMV.hedge_asset_test
, RMV.item_asset_test
, RMV.u_unlinked_pnl_ineffectiveness
, RMV.u_current_pnl_ineffectiveness
, RMV.d_unlinked_pnl_ineffectiveness
, RMV.d_current_pnl_ineffectiveness
, RMV.u_des_pnl_ineffectiveness
, RMV.d_des_pnl_ineffectiveness
, RMV.gl_inventory
, RMV.u_pnl_inventory
, RMV.d_pnl_inventory
, RMV.u_aoci_released
, RMV.aoci_asset_test
, RMV.u_st_tax_asset
, RMV.u_lt_tax_asset
, RMV.u_st_tax_liability
, RMV.u_lt_tax_liability
, RMV.u_tax_reserve
, RMV.d_st_tax_asset
, RMV.d_lt_tax_asset
, RMV.d_st_tax_liability
, RMV.d_lt_tax_liability
, RMV.d_tax_reserve
, RMV.gl_id_st_tax_asset
, RMV.gl_id_st_tax_liab
, RMV.gl_id_lt_tax_asset
, RMV.gl_id_lt_tax_liab
, RMV.gl_id_tax_reserve
, RMV.link_type_value_id
, RMV.create_user
, RMV.create_ts
, RMV.valuation_date
, RMV.d_aoci_released
from report_measurement_values_expired RMV INNER JOIN
							fas_books fb ON fb.fas_book_id = RMV.book_entity_id INNER JOIN 
							fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id' 

--print @Sql_Select + @Sql_Where
EXEC spa_print @Sql_Select
SET @Sql_Where1 = ' WHERE (RMV.as_of_date < CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) '
--print (@Sql_Select + @Sql_Where1 + @Sql_Where)
EXEC (@Sql_Select + @Sql_Where1 + @Sql_Where)


--return

------------------------------
--

IF @summary_option = 'm' 
BEGIN
CREATE TABLE #aaaaaa(
	[Valuation DATE] [VARCHAR] (20) COLLATE DATABASE_DEFAULT  ,
	[Sub] [VARCHAR](100) COLLATE DATABASE_DEFAULT   NOT NULL,
	[Strategy] [VARCHAR](100) COLLATE DATABASE_DEFAULT   NOT NULL,
	[Book] [VARCHAR](100) COLLATE DATABASE_DEFAULT   NOT NULL,
	[Der/Item] [VARCHAR](4) COLLATE DATABASE_DEFAULT   NOT NULL,
	[Deal REF ID] [VARCHAR](50) COLLATE DATABASE_DEFAULT   NULL,
	[Deal ID] [VARCHAR](500) COLLATE DATABASE_DEFAULT   NULL,
	[Rel ID] [VARCHAR](500) COLLATE DATABASE_DEFAULT   NULL,
	[DeDesig Rel ID] [VARCHAR](500) COLLATE DATABASE_DEFAULT   NULL,
	[Rel TYPE] [VARCHAR](500) COLLATE DATABASE_DEFAULT   NULL,
	[Counterparty] [VARCHAR](100) COLLATE DATABASE_DEFAULT   NOT NULL,
	[Deal DATE] [VARCHAR](50) COLLATE DATABASE_DEFAULT   NULL,
	[Rel Eff DATE] [VARCHAR](50) COLLATE DATABASE_DEFAULT   NULL,
	[DeDesig DATE] [VARCHAR](50) COLLATE DATABASE_DEFAULT   NULL,
	[Term] [VARCHAR](50) COLLATE DATABASE_DEFAULT   NULL,
	[%] [FLOAT] NOT NULL,
	[Total Volume] [FLOAT] NOT NULL,
	[Volume Used] [FLOAT] NOT NULL,
	[UOM] [VARCHAR](100) COLLATE DATABASE_DEFAULT   NULL,
	[INDEX] [VARCHAR](100) COLLATE DATABASE_DEFAULT   NULL,
	[DF] [FLOAT] NOT NULL,
	[Deal Price] [FLOAT] NULL,
	[Market Price] [FLOAT] NULL,
	[Inception Price] [FLOAT] NULL,
	[Currency] [VARCHAR](100) COLLATE DATABASE_DEFAULT   NULL,
	[Cum FV] [FLOAT] NULL,
	[Cum INT FV] [FLOAT] NULL,
	[Incpt FV] [FLOAT] NULL,
	[Incpt INT FV] [FLOAT] NULL,
	[Cum Hedge FV] [FLOAT] NULL,
	[Hedge AOCI Ratio] [FLOAT] NULL,
	[Dollar Offset Ratio] [FLOAT] NULL,
	[Test] [VARCHAR](509) COLLATE DATABASE_DEFAULT   NULL,
	[AOCI] [FLOAT] NULL,
	[PNL] [FLOAT] NULL,
	[AOCI Released] [FLOAT] NOT NULL,
	[PNL Settled] [FLOAT] NULL)

--select @discount_option, @as_of_date, NULL, @settlement_option, @sub_entity_id, 
--					@strategy_entity_id, @book_entity_id, @round_value, @legal_entity, @hypothetical,  
--					@link_id, @source_deal_header_id, @deal_id, @report_type,'n', NULL, @term_start, @term_end

	INSERT INTO #aaaaaa 
	EXEC spa_msmt_link_drill_down  @discount_option, @as_of_date, NULL, @settlement_option, @sub_entity_id, 
					@strategy_entity_id, @book_entity_id, @round_value, @legal_entity, @hypothetical,  
					@link_id, @source_deal_header_id, @deal_id, @report_type,'n', NULL, @term_start, @term_end,@link_desc,@link_id_to
	exec spa_print 'select * ', @str_get_row_number, ' ', @str_batch_table, ' from #aaaaaa' 
	EXEC('select * ' + @str_get_row_number+' '+ @str_batch_table +  ' from #aaaaaa' )
--	return
END
--==================================================================================================

ELSE IF @report_type = 'c' 

BEGIN
--				--dbo.FNAHyperLinkText(61, cast(cd.link_id as varchar), cast(cd.link_id as varchar)) 
--				dbo.FNAHyperLinkText(10233710, cast(cd.link_id as varchar), cast(cd.link_id as varchar)) 
--			--dbo.FNAHyperLinkText(120, cast(cd.source_deal_header_id as varchar), cast(cd.source_deal_header_id as varchar)) [Deal ID], 
--			dbo.FNAHyperLinkText(10131010, cast(cd.source_deal_header_id as varchar), cast(cd.source_deal_header_id as varchar)) [Deal ID],

	--==========================Get all Linked hedges=========================================================================
	SET @Sql_Select = 'SELECT     dbo.FNADateFormat(RMV.valuation_date) valuation_date, PH.entity_name AS Sub, PH1.entity_name AS Strategy, PH2.entity_name AS Book, '
	
	IF @summary_option IN ('d' , 'l')
		SET @Sql_Select = @Sql_Select  + ' RMV.link_id AS [ID],  UPPER(RMV.link_deal_flag) AS [Group],

						  case  when (isnull(RMV.link_deal_flag, ''d'') = ''d'') then 
						  dbo.FNATRMWinHyperlink(''a'', 10131010, ''Deal'', ABS(RMV.link_id),null,null,null,null,null,null,null,null,null,null,null,0) 
						  else 
						  dbo.FNATRMWinHyperlink(''a'', 10233700, case when (RMV.link_type_value_id = 450) then ''Designation''
										 when (RMV.link_type_value_id = 451) then ''DeDesig Prob'' + ''('' + cast(flh.original_link_id as VARCHAR(50)) + '')''
									else ''DeDesig Not Prob'' + ''('' + cast(flh.original_link_id as VARCHAR(50)) + '')'' end, ABS(RMV.link_id),null,null,null,null,null,null,null,null,null,null,null,0) 
						  end AS [Type], 

				case when (RMV.link_deal_flag <> ''d'') then RMV.assessment_type + '': '' else '''' end + 
				case when (RMV.link_deal_flag = ''d'') then ''N/A'' when (RMV.assessment_test = 1) then ''Pass'' else ''Fail'' end AS [Test],
				RMV.term_month AS [Expiration], round(isnull(RMV.cfv_test, 0), 2) cfv_ratio, do.dol_offset, '

-- select * from fas_Books
--	
--	IF @discount_option='u'
		SET @Sql_Select = @Sql_Select  + '	
					RMV.' + @discount_option + '_hedge_mtm AS [Hedge Amount], 
					RMV.' + @discount_option + '_item_mtm AS [Item Amount], 
					RMV.' + @discount_option + '_hedge_st_asset AS [ST Ast (Db)],  
					RMV.' + @discount_option + '_hedge_st_liability AS [ST Liab (Cr)], 
					RMV.' + @discount_option + '_hedge_lt_asset AS [LT Ast (Db)], 
					RMV.' + @discount_option + '_hedge_lt_liability AS [LT Liab (Cr)], 
					RMV.' + @discount_option + '_total_aoci AS [AOCI (+Cr/-Db)], 
					RMV.' + @discount_option + '_total_pnl AS [PNL (+Cr/-Db)], 
					RMV.' + @discount_option + '_pnl_settlement AS [Earnings (+Cr/-Db)],
					RMV.' + @discount_option + '_total_pnl + RMV.' + @discount_option + '_pnl_settlement AS [Total Earnings (+Cr/-Db)],
					RMV.' + @discount_option + '_cash AS [Cash (-Cr/+Db)]'

	SET @Sql_From = ' FROM         portfolio_hierarchy PH2 INNER JOIN
		                      portfolio_hierarchy PH1 INNER JOIN
		                      #RMV  RMV INNER JOIN
		                      portfolio_hierarchy PH ON RMV.sub_entity_id = PH.entity_id ON PH1.entity_id = RMV.strategy_entity_id ON 
		                      PH2.entity_id = RMV.book_entity_id 
					LEFT OUTER JOIN
					#dol_offset do on do.link_id = rmv.link_id LEFT OUTER JOIN
					fas_link_header flh ON flh.link_id = RMV.link_id AND RMV.link_deal_flag=''l'' LEFT OUTER JOIN
					source_deal_header sdh ON sdh.source_deal_header_id = RMV.link_id AND RMV.link_deal_flag=''d'' 
					' 


	SET @Sql1 = @Sql_Select + @Sql_From 
		
	--=================SUMMARIZE======================================================
	SET @Sql_Select = 'SELECT      max(valuation_date) [Valuation Date], Sub,  Strategy,  Book, '
	
	IF @summary_option = 'd'
		SET @Sql_Select = @Sql_Select  + '  [ID],   [Group],
	                      [Type],  
						  max(Test) + '' ('' + cast(max(cfv_ratio) as varchar) + '')'' as [Test (Eff Ratio)],
						dbo.FNAContractMonthFormat(Expiration) AS [Expiration], '

	IF @summary_option = 'l'
		SET @Sql_Select = @Sql_Select  + ' case when ([Group] = ''d'') then ''MTM'' else cast([ID] as varchar) end [ID],  case when round(max(dol_offset), 4)=0 then null else round(max(dol_offset), 4) end [H/HI Ratio],
	                      [Type],  
						  max(Test) + '' ('' + cast(max(cfv_ratio) as varchar) + '')'' as [Test (Eff Ratio)],
						  dbo.FNAContractMonthFormat(min(Expiration)) + '' - '' +  dbo.FNAContractMonthFormat(max(Expiration)) AS [Tenor], '

	
	SET @Sql_Select = @Sql_Select  + ' 
			round(SUM([Hedge Amount]), ' + @round_value + ') AS [Hedge Amount], 
			round(SUM([Item Amount]), ' + @round_value + ') AS [Item Amount], 
			round(SUM([ST Ast (Db)]), ' + @round_value + ') AS [ST Ast (Db)], 
			round(SUM([ST Liab (Cr)]), ' + @round_value + ')  AS [ST Liab (Cr)], 
			round(SUM([LT Ast (Db)]), ' + @round_value + ')  AS [LT Ast (Db)], 
			round(SUM([LT Liab (Cr)]), ' + @round_value + ')  AS [LT Liab (Cr)], 
			round(SUM([AOCI (+Cr/-Db)]), ' + @round_value + ')  AS [AOCI  (+Cr/-Db)], 
            round(SUM([PNL (+Cr/-Db)]), ' + @round_value + ') AS [PNL (+Cr/-Db)], 
			round(SUM([Earnings (+Cr/-Db)]), ' + @round_value + ')  AS [Earnings (+Cr/-Db)],
			round(SUM([PNL (+Cr/-Db)] + [Earnings (+Cr/-Db)]), ' + @round_value + ') AS [Total Earnings (+Cr/-Db)],
			round(SUM([Cash (-Cr/+Db)]), ' + @round_value + ')  AS [Cash (-Cr/+Db)]'


	SET @sQL_fROM = ' FROM (' + @Sql1 +  ') AS A '


	SET @Sql_GpBy = ' GROUP BY Sub, Strategy, Book '
	
	IF @summary_option = 'd'
			SET @Sql_GpBy = @Sql_GpBy  + ', [ID],   [Group],
	                      [Type],  [Expiration]'
	IF @summary_option = 'l'
			SET @Sql_GpBy = @Sql_GpBy  + ', case when ([Group] = ''d'') then ''MTM'' else cast([ID] as varchar) end, [Type]'

	IF @summary_option = 'd'
		SET @Sql_OrderBy =  ' ORDER BY Sub, Strategy, Book, [Group] DESC, [Type], ID,  
									cast((dbo.FNAContractMonthFormat(Expiration) + ''-01'') AS datetime) '
	ELSE IF @summary_option = 'l'
		SET @Sql_OrderBy =  ' ORDER BY Sub, Strategy, Book, ID '
	ELSE
		SET @Sql_OrderBy =  ' ORDER BY Sub, Strategy, Book '

	EXEC spa_print @Sql_Select, @str_get_row_number, ' ', @str_batch_table, @Sql_From, @Sql_GpBy, @Sql_OrderBy

	 
	EXEC(@Sql_Select + @str_get_row_number+' '+ @str_batch_table +  @Sql_From + @Sql_GpBy + @Sql_OrderBy)
	

END


--=============================Fair Value Report==================================================================
ELSE IF @report_type = 'f' 
	BEGIN
	--=============================Get all linked hedges==================================================================
	SET @Sql_Select = 'SELECT     dbo.FNADateFormat(RMV.valuation_date) valuation_date, PH.entity_name AS Sub, PH1.entity_name AS Strategy, PH2.entity_name AS Book, '
	
	IF @summary_option = 'd'
		SET @Sql_Select = @Sql_Select  + ' RMV.link_id AS [ID],  UPPER(RMV.link_deal_flag) AS [Group],
	                      RMV.assessment_type AS [Type], 
				case when (RMV.link_deal_flag = ''d''  OR settled_test = 1) then ''N/A'' when (RMV.assessment_test = 1) then ''Pass'' else ''Fail'' end AS [Test],
				RMV.term_month AS [Expiration], '

--
--	IF @discount_option='u'
		SET @Sql_Select = @Sql_Select  + ' 
					RMV.' + @discount_option + '_hedge_mtm AS [Hedge Amount], 
					RMV.' + @discount_option + '_item_mtm AS [Item Amount], 
					RMV.' + @discount_option + '_hedge_st_asset AS [H ST Ast (Db)], 
		            RMV.' + @discount_option + '_hedge_st_liability AS [H ST Liab (Cr)], 
					RMV.' + @discount_option + '_hedge_lt_asset AS [H LT Ast (Db)], 
					RMV.' + @discount_option + '_hedge_lt_liability AS [H LT Liab (Cr)], 
					RMV.' + @discount_option + '_item_st_asset  AS [I ST Ast (Db)], 
					RMV.' + @discount_option + '_item_st_liability AS [I ST Liab  (Cr)], 
					RMV.' + @discount_option + '_item_lt_asset AS [I LT Ast (Db)], 
					RMV.' + @discount_option + '_item_lt_liability AS [I LT Liab (Cr)], 
					RMV.' + @discount_option + '_total_pnl AS [PNL (+Cr/-Db)], 
					RMV.' + @discount_option + '_pnl_settlement  AS [Earnings (+Cr/-Db)],
					RMV.' + @discount_option + '_cash AS [Cash (-Cr/+Db)] '

	
	SET @Sql_From = ' FROM         portfolio_hierarchy PH2 INNER JOIN
		                      portfolio_hierarchy PH1 INNER JOIN
		                     #RMV  RMV INNER JOIN
		                      portfolio_hierarchy PH ON RMV.sub_entity_id = PH.entity_id ON PH1.entity_id = RMV.strategy_entity_id ON 
		                      PH2.entity_id = RMV.book_entity_id 
'
	
	SET @Sql1 = @Sql_Select + @Sql_From 


 	--=====================SUMMARIZE=========================================
	SET @Sql_Select = 'SELECT    max(valuation_date) [Valuation Date], Sub, Strategy, Book, '
	
	IF @summary_option = 'd'
		SET @Sql_Select = @Sql_Select  + ' [ID],  [Group],
				            [Type], 
							max(Test) as Test,
							dbo.FNAContractMonthFormat(Expiration) as [Expiration], '

	SET @Sql_Select = @Sql_Select  + ' 
					round(SUM([Hedge Amount]), ' + @round_value + ') AS [Hedge Amount], 
					round(SUM([Item Amount]), ' + @round_value + ') AS [Item Amount], 
					round(SUM([H ST Ast (Db)]), ' + @round_value + ')  AS [H ST Ast (Db)], 
		            round(SUM([H ST Liab (Cr)]), ' + @round_value + ')  AS [H ST Liab (Cr)], 
					round(SUM([H LT Ast (Db)]), ' + @round_value + ')  AS [H LT Ast (Db)], 
					round(SUM([H LT Liab (Cr)]), ' + @round_value + ') AS [H LT Liab (Cr)], 
					round(SUM([I ST Ast (Db)]), ' + @round_value + ') AS [I ST Ast (Db)], 
					round(SUM([I ST Liab  (Cr)]), ' + @round_value + ')  AS [I ST Liab  (Cr)], 
					round(SUM([I LT Ast (Db)]), ' + @round_value + ')  AS [I LT Ast (Db)], 
					round(SUM([I LT Liab (Cr)]), ' + @round_value + ')  AS [I LT Liab (Cr)], 
					round(SUM([PNL (+Cr/-Db)]), ' + @round_value + ')  AS [PNL (+Cr/-Db)], 
					round(SUM([Earnings (+Cr/-Db)]), ' + @round_value + ')  AS [Earnings (+Cr/-Db)],
					round(SUM([Cash (-Cr/+Db)]), ' + @round_value + ')  AS [Cash (-Cr/+Db)] '

--COMMENTED by ub on 06/13/04 to get rid of duplicate issues for links	
--	set @sQL_fROM = 'FROM (' + @Sql1 + ' UNION ALL ' + @Sql2 + ') AS A '
	SET @sQL_fROM = 'FROM (' + @Sql1 + ') AS A '
	
		
	SET @Sql_GpBy = ' GROUP BY  Sub, Strategy, Book'
	
	IF @summary_option = 'd'
			SET @Sql_GpBy = @Sql_GpBy  + ', [ID],  [Group],
	                      [Type], [Test], 
						[Expiration]'
	 
	--Set @Sql_OrderBy =  ' ORDER BY Sub, Strategy, Book, [Group] DESC, ID, Expiration '
	 
	IF @summary_option = 'd'
		SET @Sql_OrderBy =  ' ORDER BY Sub, Strategy, Book, [Group] DESC, [Type], ID, cast((dbo.FNAContractMonthFormat(Expiration) + ''-01'') AS datetime)'
	ELSE
		SET @Sql_OrderBy =  ' ORDER BY Sub, Strategy, Book '
EXEC spa_print '***********'

	exec spa_print @Sql_Select, @str_get_row_number, ' ', @str_batch_table, ' ',  @Sql_From, @Sql_GpBy, @Sql_OrderBy

	EXEC(@Sql_Select + @str_get_row_number+' '+ @str_batch_table + ' '+ @Sql_From + @Sql_GpBy + @Sql_OrderBy)
--	EXEC(@Sql_Select + @Sql_From + @Sql_GpBy)


	END


/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_Create_Hedges_Measurement_Report', 'Run Measurement Report')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
GO
