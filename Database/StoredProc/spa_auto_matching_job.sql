SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].spa_auto_matching_job', N'P ') IS NOT NULL 
	DROP PROCEDURE [dbo].spa_auto_matching_job
GO

/**
	Auto match the hedge with Item to create link.

	Parameters:			
	@sub_id				: Sub book ids
	@str_id				: Strategy ids
	@book_id			: Book entity id
	@as_of_date_from	: Filter from as_of_date
	@as_of_date_to		: Filter to as_of_date
	@fifo_lifo			: Lifo Fifo flag
	@slicing_first		: h:first slicing hedge, i:first slicing item
	@perform_dicing		: TDB
	@v_curve_id			: TDB
	@h_or_i				: Hedge or Item
	@v_buy_sell			: TDB 
	@call_for_report	: y:call from auto matching as view report; l=call from limit calculation
	@slice_option		: m=multi;h=hedge one, i=item one
	@user_name			: User name
	@only_include_external_der : Include external derivatives
	@externalization	: Externalization flag 
	@process_id			: Unique identifier
	@book_map_ids		: Sub book mapping id
	@deal_dt_option		: i: i_dt>=h_dt;  h:h_dt>=i_dt;  a: not apply filter or ignor deal date filter
	@apply_limit		: Check limit volume before auto match.
	@limit_bucketing	: DE or UK
	@batch_process_id	: Batch process id
	@batch_report_param	: Batch parameter
*/

CREATE PROC [dbo].[spa_auto_matching_job] 
	@sub_id VARCHAR(1000) = NULL,
	@str_id VARCHAR(1000) = NULL,
	@book_id VARCHAR(1000) = NULL,
	@as_of_date_from VARCHAR(20) = NULL,
	@as_of_date_to VARCHAR(20) = NULL,
	@fifo_lifo CHAR(1) = NULL,
	@slicing_first CHAR(1) = 'h', --h:first slicing hedge, i:first slicing item
	@perform_dicing CHAR(1) = 'y', 
	@v_curve_id INT = NULL,
	@h_or_i CHAR(1) = NULL,
	@v_buy_sell CHAR(1) = NULL,
	@call_for_report VARCHAR(1) = NULL,  --y:call from auto matching as view report; l=call from limit calculation
	@slice_option VARCHAR(1) = 'm', --m=multi;h=hedge one, i=item one
	@user_name VARCHAR(50) = NULL,
	@only_include_external_der CHAR(1) = 'n', 
	@externalization CHAR(1) = 'n',
	@process_id VARCHAR(50) = NULL,
	@book_map_ids VARCHAR(MAX) = NULL,
	@deal_dt_option CHAR(1) = 'h', --i: i_dt>=h_dt;  h:h_dt>=i_dt;  a: not apply filter or ignor deal date filter
	@apply_limit CHAR(1) = NULL,
	@limit_bucketing VARCHAR(3) = NULL, --DE; UK
	@batch_process_id VARCHAR(50) = NULL, 
	@batch_report_param VARCHAR(1000) = NULL
AS
SET NOCOUNT ON

/*
DECLARE @book_id VARCHAR(1000),@sub_id VARCHAR(1000),@str_id VARCHAR(1000),@process_id VARCHAR(50)
	,@user_name VARCHAR(50),@fifo_lifo VARCHAR(1),@b_s_match_option VARCHAR(1),@call_for_report VARCHAR(1),
	@as_of_date_from VARCHAR(20),@as_of_date_to VARCHAR(20),
	@v_curve_id INT ,
	@h_or_i VARCHAR(1),
	@v_buy_sell VARCHAR(1),@slicing_first VARCHAR(1),@perform_dicing VARCHAR(1),
	@slice_option VARCHAR(1),@only_include_external_der VARCHAR(1)='n', 
	@externalization VARCHAR(1)='y',@applied_limit_vol  NUMERIC(26,10)=NULL,
	@book_map_ids VARCHAR(MAX)=NULL,
	@deal_dt_option VARCHAR(1)='a' --i: i_dt>=h_dt;  h:h_dt>=i_dt;  a: not apply filter or ignor deal date filter
	,@apply_limit VARCHAR(1) = 'y',@limit_bucketing VARCHAR(3) ='DE'
--select * from portfolio_hierarchy where entity_name='Dicing Test'
--select * from portfolio_hierarchy where entity_id in (41,76)
--EXEC spa_auto_matching_job '4',NULL,NULL,'2000-08-04','2012-09-04','l','i','y',NULL,'b','a','n','m','farrms_admin','y','n'
--,'dddd', NULL, 'a'
--EXEC FASTracker_Func.dbo.spa_auto_matching_job_t '109',NULL,NULL,'2010-01-01','2010-12-31','l','i','n',NULL,'b','a','n','i','farrms_admin','A85FCF89_70BB_45A2_9A79_35EDEEB5E50E'



--	@user_name VARCHAR(50)=NULL,
--	@only_include_external_der VARCHAR(1)='n', 
--	@externalization VARCHAR(1)='n',
--	@process_id VARCHAR(50)=NULL,
--	@book_map_ids VARCHAR(MAX)=NULL,
--	@deal_dt_option VARCHAR(1)='h' --i: i_dt>=h_dt;  h:h_dt>=i_dt;  a: not apply filter or ignor deal date filter
--	,@apply_limit VARCHAR(1) = NULL

SET @sub_id='2'
SET @str_id=NULL
SET @book_id ='176'
SET @as_of_date_from='2000-08-04'
SET @as_of_date_to='2012-12-31'
SET @fifo_lifo='f'
SET @slicing_first='i'
SET	@v_curve_id=NULL
SET @h_or_i='b' --h=hedge i=item b=both
SET	@v_buy_sell='a' --b=buy, s=sell, a=all/both
SET @call_for_report='n' --n=run for auto matching only;  y=for run for auto matching  and report
SET @user_name='re64582'
SET @only_include_external_der ='y'
SET @externalization ='n'
SET @perform_dicing='y'
SET @slice_option='i'
--SET @applied_limit_vol=1000
--exec spa_auto_matching_job NULL, NULL, NULL, '2009-02-26', '2010-02-26', 'l', 'h', 'n', NULL, 'b', 'a', 'y', 'farrms_admin'

 --NULL, NULL, '76', '2011-01-01', '2011-12-31', 'l', 'i', 'y', NULL, 'b', 'a', 'y', 'i', 'farrms_admin', 'n','n'
--SELECT * from gen_hedge_group --WHERE hedge_effective_date=@as_of_date_to --where CAST(floor(CAST(create_ts as FLOAT)) as DATETIME)='2008-05-12'

--SELECT * from [gen_fas_link_detail_dicing] --WHERE effective_date=@as_of_date_to --where CAST(floor(CAST(create_ts as FLOAT)) as DATETIME)='2008-05-12'
--WHERE gen_link_id IN (62659,62658,62657,62656)


--SELECT TOP 4* from [gen_fas_link_header] ORDER BY gen_link_id DESC  --WHERE link_effective_date=@as_of_date_to --where CAST(floor(CAST(create_ts as FLOAT)) as DATETIME)='2008-05-12'
	
--select * from [gen_fas_link_detail_dicing] --WHERE effective_date=@as_of_date_to --where CAST(floor(CAST(create_ts as FLOAT)) as DATETIME)='2008-05-12'
--select * from  [gen_fas_link_detail] 
delete gen_hedge_group --WHERE hedge_effective_date=@as_of_date_to --where CAST(floor(CAST(create_ts as FLOAT)) as DATETIME)='2008-05-12'
delete from [gen_fas_link_detail] --WHERE effective_date=@as_of_date_to --where CAST(floor(CAST(create_ts as FLOAT)) as DATETIME)='2008-05-12'
delete [gen_fas_link_header]  --WHERE link_effective_date=@as_of_date_to --where CAST(floor(CAST(create_ts as FLOAT)) as DATETIME)='2008-05-12'
delete from [gen_fas_link_detail_dicing] --WHERE effective_date=@as_of_date_to --where CAST(floor(CAST(create_ts as FLOAT)) as DATETIME)='2008-05-12'
--select *  from [gen_fas_link_detail_dicing]
--delete source_deal_detail from source_deal_detail sdd INNER JOIN (select source_deal_header_id from source_deal_header where deal_id like '%_off_auto_match') a
--on a.source_deal_header_id=sdd.source_deal_header_id
--delete source_deal_header where deal_id like '%_off_auto_match'
----select * from #hedge where source_deal_header_id=55571
--return
DROP TABLE #proxy_item_curve_id
DROP TABLE #hedge_under
DROP TABLE #used_percentage
DROP TABLE #books
DROP TABLE  #hedge_capacity
--UPDATE #item SET deal_date='2009-07-01 00:00:00.000',curve_id=30,term_end='2009-09-30 00:00:00.000',deal_volume=20000,buy_sell='s',volume=20000,used=0 where source_deal_header_id in(619,623)
--UPDATE #item SET used=0 
--UPDATE #hedge SET used=0 
--DROP TABLE #source_deal
DROP TABLE #hedge
DROP TABLE #item
DROP TABLE #used_i_source_deal_header_id
DROP TABLE #tmp_rel_type
DROP TABLE #no_index_in_deal
DROP TABLE #no_terms_in_index
DROP TABLE #netting_item
DROP TABLE #exclude_deals
DROP TABLE #tmp_rel_type_item
DROP TABLE #tmp_sdd1
DROP TABLE #tmp_sdd_vol
DROP TABLE #item_rel_type_index
DROP TABLE #hedge_rel_type_index
DROP TABLE  #perfect_match
DROP TABLE #perfect_match1
DROP TABLE #perfect_match1a
DROP TABLE #offset_deal
DROP TABLE #no_dice_deal
DROP TABLE #delete_link
DROP TABLE #modify_link
DROP TABLE #tmp_links
DROP TABLE #deal_vs_link
DROP TABLE #hedge_int
DROP TABLE #item_int
DROP TABLE #delete_link_h
DROP TABLE #modify_link_h
DROP TABLE #map_n_curve
DROP TABLE #books_rel_type
DROP TABLE #Deal_Available
DROP TABLE #perfect_match2
DROP TABLE #dicing_term_match
DROP TABLE #tmp_not_MA_deals
CLOSE perfect_match
	DEALLOCATE perfect_match
DROP TABLE 	#used_percentage_item
	
	
--*/

/*******************************************1st Paging Batch START**********************************************/
SET @limit_bucketing =ISNULL(@limit_bucketing, 'DE')

DECLARE @str_batch_table VARCHAR (8000)
SET @str_batch_table = ''        
IF @batch_process_id IS NOT NULL  
BEGIN      
	SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)   
	SET @str_batch_table = @str_batch_table
END
 
/*******************************************1st Paging Batch END**********************************************/

IF @process_id IS NULL 
	SET @process_id = @batch_process_id

IF OBJECT_ID('tempdb..#proxy_item_curve_id') IS NOT NULL
	DROP TABLE #proxy_item_curve_id
IF OBJECT_ID('tempdb..#hedge_under') IS NOT NULL
	DROP TABLE #hedge_under
IF OBJECT_ID('tempdb..#used_percentage') IS NOT NULL
	DROP TABLE #used_percentage
IF OBJECT_ID('tempdb..#books') IS NOT NULL
	DROP TABLE #books
IF OBJECT_ID('tempdb..#hedge_capacity') IS NOT NULL
	DROP TABLE  #hedge_capacity
IF OBJECT_ID('tempdb..#hedge') IS NOT NULL
	DROP TABLE #hedge
IF OBJECT_ID('tempdb..#item') IS NOT NULL
	DROP TABLE #item
IF OBJECT_ID('tempdb..#used_i_source_deal_header_id') IS NOT NULL
	DROP TABLE #used_i_source_deal_header_id
IF OBJECT_ID('tempdb..#tmp_rel_type') IS NOT NULL
	DROP TABLE #tmp_rel_type
IF OBJECT_ID('tempdb..#no_index_in_deal') IS NOT NULL
	DROP TABLE #no_index_in_deal
IF OBJECT_ID('tempdb..#no_terms_in_index') IS NOT NULL
	DROP TABLE #no_terms_in_index
IF OBJECT_ID('tempdb..#netting_item') IS NOT NULL
	DROP TABLE #netting_item
IF OBJECT_ID('tempdb..#exclude_deals') IS NOT NULL
	DROP TABLE #exclude_deals
IF OBJECT_ID('tempdb..#tmp_rel_type_item') IS NOT NULL
	DROP TABLE #tmp_rel_type_item
IF OBJECT_ID('tempdb..#tmp_sdd1') IS NOT NULL
	DROP TABLE #tmp_sdd1
IF OBJECT_ID('tempdb..#tmp_sdd_vol') IS NOT NULL
	DROP TABLE #tmp_sdd_vol
IF OBJECT_ID('tempdb..#item_rel_type_index') IS NOT NULL
	DROP TABLE #item_rel_type_index
IF OBJECT_ID('tempdb..#hedge_rel_type_index') IS NOT NULL
	DROP TABLE #hedge_rel_type_index
IF OBJECT_ID('tempdb..#perfect_match') IS NOT NULL
	DROP TABLE  #perfect_match
IF OBJECT_ID('tempdb..#perfect_match1') IS NOT NULL
	DROP TABLE #perfect_match1
IF OBJECT_ID('tempdb..#perfect_match1a') IS NOT NULL
	DROP TABLE #perfect_match1a
IF OBJECT_ID('tempdb..#offset_deal') IS NOT NULL
	DROP TABLE #offset_deal
IF OBJECT_ID('tempdb..#no_dice_deal') IS NOT NULL
	DROP TABLE #no_dice_deal
IF OBJECT_ID('tempdb..#delete_link') IS NOT NULL
	DROP TABLE #delete_link
IF OBJECT_ID('tempdb..#modify_link') IS NOT NULL
	DROP TABLE #modify_link
IF OBJECT_ID('tempdb..#tmp_links') IS NOT NULL
	DROP TABLE #tmp_links
IF OBJECT_ID('tempdb..#deal_vs_link') IS NOT NULL
	DROP TABLE #deal_vs_link
IF OBJECT_ID('tempdb..#hedge_int') IS NOT NULL
	DROP TABLE #hedge_int
IF OBJECT_ID('tempdb..#item_int') IS NOT NULL
	DROP TABLE #item_int
IF OBJECT_ID('tempdb..#delete_link_h') IS NOT NULL
	DROP TABLE #delete_link_h
IF OBJECT_ID('tempdb..#modify_link_h') IS NOT NULL
	DROP TABLE #modify_link_h
IF OBJECT_ID('tempdb..#map_n_curve') IS NOT NULL
	DROP TABLE #map_n_curve
IF OBJECT_ID('tempdb..#books_rel_type') IS NOT NULL
	DROP TABLE #books_rel_type
IF OBJECT_ID('tempdb..#Deal_Available') IS NOT NULL
	DROP TABLE #Deal_Available
IF OBJECT_ID('tempdb..#perfect_match2') IS NOT NULL
	DROP TABLE #perfect_match2
IF OBJECT_ID('tempdb..#dicing_term_match') IS NOT NULL
	DROP TABLE #dicing_term_match
IF OBJECT_ID('tempdb..#tmp_not_MA_deals') IS NOT NULL
	DROP TABLE #tmp_not_MA_deals
IF OBJECT_ID('tempdb..#used_percentage_item') IS NOT NULL
	DROP TABLE 	#used_percentage_item

DECLARE @url VARCHAR(500)
DECLARE @desc VARCHAR(500)
DECLARE @errorMsg VARCHAR(200)
DECLARE @errorcode VARCHAR(1)
DECLARE @url_desc VARCHAR(500), @exit_loop BIT, @exit_perfect BIT, @exit_slice_h BIT, @exit_slice_i BIT

DECLARE @Proposed_per_h FLOAT
DECLARE @Proposed_per_i FLOAT
DECLARE @process_id_tmp VARCHAR(1000)
SELECT @exit_perfect = 0, @exit_slice_h = 0, @exit_slice_i = 0 
SET @exit_loop = 0

IF @process_id IS NULL
	SET @process_id = REPLACE(NEWID(), '-', '_')

IF @user_name IS NULL
	SET @user_name = dbo.FNADBUser()
	
DECLARE @sql VARCHAR(8000)

DECLARE @run_time DATETIME
SET @run_time = GETDATE()
DECLARE @exclude_curve_id VARCHAR(50)
DECLARE @create_new_link CHAR(1)
SET @create_new_link = 'y'
SET @exclude_curve_id = 'FX_EUR'

/*
IF @sub_id IS NOT NULL
SET @sql_where=@sql_where+' and p_str.parent_entity_id in ('+@sub_id+')'
IF @str_id IS NOT NULL
SET @sql_where=@sql_where+' and p_str.entity_id in ('+@str_id+')'
IF @book_id IS NOT NULL
SET @sql_where=@sql_where+' and p_book.entity_id in ('+@book_id+')'
*/
--SET @str_id=NULL
--SET @book_id =304
DECLARE @no_item_in_link INT
SET @no_item_in_link=0
DECLARE @new_link_id INT
DECLARE @gen_hedge_group_id INT
DECLARE @eff_test_profile_id INT, @loop INT
--DECLARE @effctive_start_date DATETIME
--SET @eff_test_profile_id=98
---SET @effctive_start_date='2008-12-30'

SET @loop = 1

DECLARE @report_url VARCHAR(MAX), @p_link_effect_date DATETIME, @jump_for_exit VARCHAR(1), @limit_chcking INT


IF ISNULL(@call_for_report,'n') <> 'l'
BEGIN
	IF ISNULL(@apply_limit, 'n') = 'n'
		SET @limit_chcking = 0
	ELSE
		SET @limit_chcking = 1
END
ELSE 
	SET @limit_chcking = 1

SET @jump_for_exit = 'y'

DECLARE @new_book_id INT
DECLARE @curve_id INT
DECLARE @source_deal_header_id INT
DECLARE @deal_date DATETIME
--@term_start DATETIME,
--@term_end DATETIME,
DECLARE @volume FLOAT
DECLARE @per FLOAT
DECLARE @buy_sell CHAR(1)
DECLARE @deal_volume FLOAT
DECLARE @recent_per_used_h FLOAT
DECLARE @recent_per_used_i FLOAT

DECLARE @temp_per FLOAT
DECLARE @temp_vol FLOAT
DECLARE @need_insert_detail INT

DECLARE @h_no_term INT
DECLARE @match_no_term INT
DECLARE @new_source_deal_header_id INT
DECLARE @link_per FLOAT
DECLARE @temp_match_volume FLOAT
DECLARE @temp_match_per FLOAT
DECLARE @deal_volume_p FLOAT

DECLARE @c_curve_id INT
DECLARE @c_deal_date DATETIME
DECLARE @c_term_start DATETIME
DECLARE @c_term_end DATETIME
DECLARE @c_no_indx INT
DECLARE @c_volume FLOAT
DECLARE @c_sell_no_rec INT
DECLARE @c_buy_no_rec INT
DECLARE @p_source_deal_header_id_h INT
DECLARE @p_source_deal_header_id_i INT
DECLARE @source_deal_header_id_h INT
DECLARE @per_h FLOAT
DECLARE @source_deal_header_id_i INT
DECLARE @volume_h FLOAT
DECLARE @per_i FLOAT
DECLARE @volume_i FLOAT
DECLARE @link_effect_date DATETIME
DECLARE @ProcessTableName VARCHAR(250)
DECLARE @i_deal_id VARCHAR(100)
DECLARE @h_deal_id VARCHAR(100)
DECLARE @CurveName VARCHAR(250)
DECLARE @term_start DATETIME
DECLARE @term_end DATETIME
DECLARE @deal_volume_h FLOAT
DECLARE @deal_volume_i FLOAT
DECLARE @Sql_SelectB VARCHAR(MAX)
DECLARE @Sql_WhereB VARCHAR(MAX)

DECLARE @link_deal_term_used_per VARCHAR(200)
DECLARE @item_uom_id INT
DECLARE @hedge_capacity VARCHAR(250)	
DECLARE @settlement_option CHAR(1) = 'f'
DECLARE @include_gen_tranactions CHAR(1) = 'b'

DECLARE @report_type VARCHAR(1) = 'c'
DECLARE @summary_option VARCHAR(1) = 'l'
DECLARE @exception_flag char(1) = 'a'
DECLARE @asset_type_id INT = 402
DECLARE @entity_id INT
DECLARE @tmp_process_id VARCHAR(250)

IF ISNULL(@limit_chcking,0)=1
BEGIN
	CREATE TABLE #hedge_capacity (
		fas_sub_id INT,
		fas_str_id INT,
		fas_book_id INT,
		curve_id INT,
		fas_sub VARCHAR(250) COLLATE DATABASE_DEFAULT,
		fas_str VARCHAR(250) COLLATE DATABASE_DEFAULT,
		fas_book VARCHAR(250) COLLATE DATABASE_DEFAULT,
		IndexName VARCHAR(250) COLLATE DATABASE_DEFAULT,
		TenorBucket VARCHAR(250) COLLATE DATABASE_DEFAULT,
		TenorStart DATETIME,
		TenorEnd DATETIME,
		vol_frequency VARCHAR(50) COLLATE DATABASE_DEFAULT,
		vol_uom VARCHAR(100) COLLATE DATABASE_DEFAULT,
		net_asset_vol NUMERIC(38, 20),
		net_item_vol NUMERIC(38, 20),
		net_available_vol NUMERIC(38, 20),
		over_hedge VARCHAR(3) COLLATE DATABASE_DEFAULT,
		net_vol NUMERIC(26, 10)
	)

	SET @hedge_capacity = dbo.FNAProcessTableName('hedge_capacity', @user_name, @process_id)	
	
	IF ISNULL(@call_for_report,'n') <> 'l' OR OBJECT_ID(@hedge_capacity) IS NULL  -- not call from limit calculation
	BEGIN
		INSERT INTO #hedge_capacity (fas_sub_id, fas_str_id, fas_book_id, curve_id, fas_sub, fas_str, fas_book, IndexName
									, TenorBucket, TenorStart, TenorEnd, vol_frequency, vol_uom, net_asset_vol, net_item_vol, net_available_vol, over_hedge)
		EXEC spa_Create_Available_Hedge_Capacity_Exception_Report @as_of_date_to, @sub_id, NULL, NULL, @report_type ,@summary_option, NULL
			, @exception_flag, @asset_type_id, @settlement_option, @include_gen_tranactions, 'n', @limit_bucketing
			
		UPDATE #hedge_capacity SET net_vol = ABS(ABS(ISNULL(net_asset_vol,0)) - ISNULL(net_item_vol,0)) * CASE WHEN ISNULL(net_asset_vol,0) < 0 THEN -1 ELSE 1 END	
		
		IF OBJECT_ID(@hedge_capacity) IS NOT NULL
			EXEC('DROP TABLE '+@hedge_capacity)
			
		EXEC('SELECT * INTO ' + @hedge_capacity + ' FROM #hedge_capacity WHERE over_hedge = ''No'' AND ISNULL(net_vol,0) <> 0')
	END	
	
	IF @v_curve_id IS NOT NULL
	BEGIN
		SET @sql = 'DELETE ' + @hedge_capacity + ' WHERE curve_id <> ' + CAST(@v_curve_id AS VARCHAR)
		EXEC(@sql)	
	END
END

DECLARE @firest_time bit
SET @firest_time=1
CREATE TABLE #deal_vs_link (link_id INT, hedge_deal_id INT, item_deal_id INT)
CREATE TABLE #offset_deal (source_deal_id INT)
CREATE TABLE #no_index_in_deal (source_deal_id INT, indx_no INT)
CREATE TABLE #tmp_rel_type (fas_book_id INT, eff_test_profile_id INT, curve_id INT, matching_type CHAR(1) COLLATE DATABASE_DEFAULT)
CREATE TABLE #tmp_rel_type_item (fas_book_id INT,eff_test_profile_id INT,curve_id INT,matching_type CHAR(1) COLLATE DATABASE_DEFAULT)
CREATE TABLE #used_percentage (source_deal_header_id INT, term_start DATE, used_percentage FLOAT, link_end_date DATETIME)
CREATE TABLE #no_terms_in_index (source_deal_id INT, indx INT, no_terms INT)
CREATE TABLE #exclude_deals (source_deal_header_id INT, create_ts DATETIME)
CREATE TABLE #netting_item (curve_id INT, deal_date DATETIME, term_start DATETIME, term_end DATETIME,no_indx INT, volume FLOAT, sell_no_rec INT, buy_no_rec INT)
CREATE TABLE #used_i_source_deal_header_id (h_source_deal_header_id INT, i_source_deal_header_id INT)

INSERT INTO #no_index_in_deal (source_deal_id, indx_no)
SELECT aa.source_deal_header_id, COUNT(1) FROM (
	SELECT DISTINCT sdd.source_deal_header_id,sdd.curve_id FROM source_deal_detail sdd
	INNER JOIN source_price_curve_def ON sdd.curve_id=source_price_curve_def.source_curve_def_id AND sdd.Leg = 1 AND source_price_curve_def.curve_id <> @exclude_curve_id
	WHERE sdd.curve_id IS NOT NULL
) aa GROUP BY aa.source_deal_header_id

INSERT INTO #no_terms_in_index(source_deal_id, indx, no_terms)
SELECT sdd.source_deal_header_id,sdd.curve_id,COUNT(1) FROM source_deal_detail sdd
INNER JOIN source_price_curve_def ON sdd.curve_id=source_price_curve_def.source_curve_def_id 
	AND source_price_curve_def.curve_id<>@exclude_curve_id and sdd.Leg=1
WHERE sdd.curve_id IS NOT NULL 
GROUP BY sdd.source_deal_header_id,sdd.curve_id

CREATE TABLE #books (fas_book_id INT, fas_sub_id INT)
SET @Sql_WhereB = ''
SET @Sql_SelectB = 'INSERT INTO  #books (fas_book_id ,fas_sub_id )
					SELECT DISTINCT book.entity_id fas_book_id ,stra.parent_entity_id fas_sub_id FROM portfolio_hierarchy book (NOLOCK) 
					INNER JOIN portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
					WHERE 1 = 1 '   

IF @sub_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @sub_id + ') '         
IF @str_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN (' + @str_id + ' ))'        
IF @book_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN (' + @book_id + ')) '        
        
SET @Sql_SelectB=@Sql_SelectB+@Sql_WhereB        
     
EXEC spa_print @Sql_SelectB
EXEC (@Sql_SelectB)

CREATE INDEX indx_books ON #books(fas_book_id)

INSERT INTO #tmp_rel_type
SELECT h1.fas_book_id,h1.eff_test_profile_id,max_id.curve_id, ISNULL(h1.matching_type,'a') matching_type 
FROM fas_eff_hedge_rel_type h1 
INNER JOIN  (
	SELECT MIN(h.eff_test_profile_id) eff_test_profile_id,source_curve_def_id curve_id
	FROM fas_eff_hedge_rel_type h 
	INNER JOIN fas_eff_hedge_rel_type_detail d ON h.eff_test_profile_id=d.eff_test_profile_id 
	INNER JOIN #books b ON b.fas_book_id = h.fas_book_id
	WHERE  d.hedge_or_item = 'h' AND source_curve_def_id IS NOT NULL 
		AND (@as_of_date_to BETWEEN ISNULL(effective_start_date,'1900-01-01') AND ISNULL(effective_end_date, '9999-01-01')) 
		AND profile_active = 'y' AND profile_approved='y' AND ISNULL(externalization,'n') = ISNULL(@externalization, 'n')
	GROUP BY d.source_curve_def_id, h.fas_book_id
	) max_id 
ON max_id.eff_test_profile_id = h1.eff_test_profile_id AND ISNULL(h1.externalization,'n') = ISNULL(@externalization,'n')
	AND ISNULL(h1.matching_type,'a') in ('a', 'b')
		
INSERT INTO #tmp_rel_type_item
SELECT h1.fas_book_id,h1.eff_test_profile_id,max_id.curve_id, ISNULL(h1.matching_type,'a') matching_type 
FROM fas_eff_hedge_rel_type h1 
INNER JOIN (
	SELECT MIN(h.eff_test_profile_id) eff_test_profile_id,source_curve_def_id curve_id 
	FROM fas_eff_hedge_rel_type h 
	INNER JOIN fas_eff_hedge_rel_type_detail d ON h.eff_test_profile_id=d.eff_test_profile_id 
	INNER JOIN #books b ON b.fas_book_id = h.fas_book_id
	WHERE  d.hedge_or_item = 'i' AND source_curve_def_id IS NOT NULL 
		AND ( @as_of_date_to BETWEEN ISNULL(effective_start_date, '1900-01-01') AND ISNULL(effective_end_date, '9999-01-01')) 
		AND profile_active = 'y' AND profile_approved = 'y' AND ISNULL(externalization,'n') = ISNULL(@externalization, 'n')
	GROUP BY d.source_curve_def_id,h.fas_book_id
) max_id 
ON max_id.eff_test_profile_id = h1.eff_test_profile_id  AND ISNULL(h1.externalization,'n')=ISNULL(@externalization,'n')
	AND ISNULL(h1.matching_type,'a') in ('a', 'b')
	
-- not include 'MA_' in  deal_id deals
SELECT  sdh.source_deal_header_id 
	INTO #tmp_not_MA_deals
FROM source_deal_header sdh 
INNER JOIN source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 
	AND sdh.source_system_book_id2 = sbm.source_system_book_id2 
	AND sdh.source_system_book_id3 = sbm.source_system_book_id3
	AND sdh.source_system_book_id4 = sbm.source_system_book_id4 
	AND sdh.deal_id NOT LIKE 'MA[_]%'

CREATE INDEX idx_tmp_not_MA_deals on #tmp_not_MA_deals (source_deal_header_id)

SELECT DISTINCT sdh.source_deal_header_id 
	INTO #no_dice_deal 
FROM source_deal_header sdh 
INNER JOIN source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 
	AND sdh.source_system_book_id2 = sbm.source_system_book_id2 
	AND sdh.source_system_book_id3 = sbm.source_system_book_id3 
	AND sdh.source_system_book_id4 = sbm.source_system_book_id4 
INNER JOIN #books b ON b.fas_book_id=sbm.fas_book_id
LEFT JOIN fas_link_detail_dicing d ON sdh.source_deal_header_id=d.source_deal_header_id 
WHERE d.source_deal_header_id IS NULL
UNION
SELECT DISTINCT sdh.source_deal_header_id 
FROM source_deal_header sdh 
INNER JOIN source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 
AND sdh.source_system_book_id2 = sbm.source_system_book_id2
AND sdh.source_system_book_id3 = sbm.source_system_book_id3 
AND sdh.source_system_book_id4 = sbm.source_system_book_id4 
INNER JOIN #books b ON b.fas_book_id=sbm.fas_book_id
LEFT JOIN gen_fas_link_detail_dicing d on sdh.source_deal_header_id=d.source_deal_header_id  where d.source_deal_header_id IS NULL

CREATE INDEX idx_tmp_dice_deals ON #no_dice_deal (source_deal_header_id)

SELECT  i.curve_id i_curve_id,h.curve_id h_curve_id,i.book_map_id i_book_map_id,h.book_map_id h_book_map_id,i.fas_book_id, MIN(i.eff_test_profile_id) eff_test_profile_id
INTO #map_n_curve
FROM 
(
	SELECT d.eff_test_profile_id,source_curve_def_id curve_id,book_deal_type_map_id book_map_id,h.fas_book_id,b.fas_sub_id
	FROM fas_eff_hedge_rel_type h 
	INNER JOIN fas_eff_hedge_rel_type_detail d ON h.eff_test_profile_id = d.eff_test_profile_id 
	INNER JOIN portfolio_hierarchy book (NOLOCK) ON h.fas_book_id = book.entity_id 
	INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id
	INNER JOIN #books b ON b.fas_book_id = CASE WHEN @call_for_report = 'l' THEN b.fas_book_id ELSE h.fas_book_id END AND b.fas_sub_id = stra.parent_entity_id
	WHERE  d.hedge_or_item = 'i' AND source_curve_def_id IS NOT NULL 
		AND (@as_of_date_to BETWEEN ISNULL(effective_start_date, '1900-01-01') AND ISNULL(effective_end_date, '9999-01-01')) 
		AND profile_active = 'y' AND profile_approved = 'y' AND ISNULL(externalization, 'n')=ISNULL(@externalization, 'n') 
		AND ISNULL(h.matching_type, 'a') IN ('a', 'b')
)  i
INNER JOIN
(
	SELECT d.eff_test_profile_id,source_curve_def_id curve_id,book_deal_type_map_id book_map_id
	FROM fas_eff_hedge_rel_type h 
	INNER JOIN fas_eff_hedge_rel_type_detail d ON h.eff_test_profile_id=d.eff_test_profile_id 
	INNER JOIN portfolio_hierarchy book (NOLOCK) on h.fas_book_id = book.entity_id 
	INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id
	INNER JOIN #books b ON b.fas_book_id = CASE WHEN @call_for_report = 'l' THEN b.fas_book_id ELSE h.fas_book_id END AND b.fas_sub_id= stra.parent_entity_id
	WHERE  d.hedge_or_item = 'h' AND source_curve_def_id IS NOT NULL 
		AND (@as_of_date_to BETWEEN ISNULL(effective_start_date,'1900-01-01') AND ISNULL(effective_end_date, '9999-01-01')) 
		AND profile_active='y' AND profile_approved = 'y' AND ISNULL(externalization, 'n') = ISNULL(@externalization, 'n') 
		AND ISNULL(h.matching_type, 'a') IN ('a', 'b')
) h on i.eff_test_profile_id = h.eff_test_profile_id
GROUP BY i.curve_id,h.curve_id,i.book_map_id,h.book_map_id,i.fas_book_id

--inserting unlinked hedge
SELECT sdd1.source_deal_header_id,sdd1.curve_id, MIN(term_start) term_start, MAX(term_end) term_end, SUM(deal_volume) vol, MAX(buy_sell_flag) buy_sell, MAX(sdd1.deal_volume_uom_id) uom_id
	INTO #tmp_sdd1 
FROM source_deal_detail sdd1    
INNER JOIN source_price_curve_def ON sdd1.curve_id=source_price_curve_def.source_curve_def_id 
	AND source_price_curve_def.curve_id <> @exclude_curve_id  
WHERE sdd1.curve_id IS NOT NULL AND sdd1.leg = 1    
GROUP BY sdd1.source_deal_header_id, sdd1.curve_id    

CREATE INDEX idx_tmp_sdd1_1 ON #tmp_sdd1 (source_deal_header_id)

SELECT sdh.source_deal_header_id, SUM(ISNULL(deal_volume,0)) d_vol, MAX(sdh.deal_date) d_date
INTO #tmp_sdd_vol 
FROM source_deal_detail sdd1  
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=sdd1.source_deal_header_id  
INNER JOIN #tmp_not_MA_deals ma_d ON sdh.source_deal_header_id=ma_d.source_deal_header_id
INNER JOIN source_price_curve_def ON sdd1.curve_id=source_price_curve_def.source_curve_def_id AND source_price_curve_def.curve_id <> @exclude_curve_id  
WHERE sdd1.curve_id IS NOT NULL  AND sdd1.leg = 1    
GROUP BY sdh.source_deal_header_id   

CREATE NONCLUSTERED INDEX idx_no_terms_in_index11 ON [dbo].[#no_terms_in_index] ([source_deal_id]) INCLUDE ([indx])
CREATE NONCLUSTERED INDEX indx_no_index_in_deal ON [dbo].[#no_index_in_deal] ([source_deal_id])
CREATE INDEX idx_tmp_sdd_vol_1 ON #tmp_sdd_vol (source_deal_header_id)

INSERT INTO #exclude_deals (source_deal_header_id ,create_ts )
SELECT fld.source_deal_header_id, MAX(dld.create_ts) create_ts 
FROM [dedesignated_link_deal]  dld 
INNER JOIN fas_link_detail fld ON fld.link_id=dld.link_id WHERE fld.hedge_or_item='i'
GROUP BY fld.source_deal_header_id
UNION
SELECT dld.source_deal_header_id, MAX(dld.create_ts) create_ts 
FROM [dedesignated_link_deal]  dld 
GROUP BY dld.source_deal_header_id

SET @ProcessTableName = dbo.FNAProcessTableName('matching', @user_name, @process_id)
SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_name, @process_id)

IF OBJECT_ID(@ProcessTableName) IS NOT NULL
EXEC('DROP TABLE ' + @ProcessTableName)

SET @sql = 'CREATE TABLE '+@ProcessTableName+' (
												Rowid INT IDENTITY(1, 1),
												Match INT,
												[Hedged Item Product] VARCHAR(200)  ,
												[Tenor]	VARCHAR(50)  ,
												[Deal Date]	DATETIME,
												[Type] VARCHAR(20)  ,
												[Deal ID]  INT,
												[Deal REF ID]  VARCHAR(200)  ,
												[Volume % Avail]  FLOAT,
												[Volume Avail] FLOAT,
												[Volume matched] FLOAT,
												[% Matched] FLOAT,
												[UOM] VARCHAR(20)  ,
												[used_ass_profile_id] [INT] NOT NULL,
												[fas_book_id] [INT] NOT NULL,
												[perfect_hedge] [CHAR](1)  NOT NULL,
												[link_description] [VARCHAR](100)  ,
												[eff_test_profile_id] [INT] NOT NULL,
												[link_effective_date] [DATETIME] NOT NULL,
												[link_type_value_id] [INT] NOT NULL,
												[gen_status] [CHAR](1)  NOT NULL,
												deal_volume FLOAT,
												buy_sell VARCHAR(1)  ,
												curve_id INT,
												process_id VARCHAR(100) ,
												term_start DATETIME,
												term_end DATETIME,
												[create_ts] [DATETIME] NULL CONSTRAINT [DF_' + @process_id + '_create_ts]  DEFAULT (GETDATE()),
												source_uom_id INT,
												[Counterparty] VARCHAR(50)  
											)
											'
EXEC spa_print @sql
EXEC(@sql)

--------------Error Trapping Start***********************************************************************
BEGIN TRY
--BEGIN TRAN
loop_match_data_exist:

	--PRINT '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
	--PRINT 'START LOOP:'+ CAST(@loop AS VARCHAR)
	--PRINT '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
	
	TRUNCATE TABLE #netting_item
	TRUNCATE TABLE #used_percentage
	
	IF OBJECT_ID(@link_deal_term_used_per) IS NOT NULL
		EXEC('DROP TABLE ' + @link_deal_term_used_per)
		
	EXEC dbo.spa_get_link_deal_term_used_per @as_of_date = @as_of_date_to, @link_ids = NULL, @header_deal_id = NULL, @term_start = NULL
		, @no_include_link_id = NULL ,@output_type = 1, @include_gen_tranactions = 'b', @process_table = @link_deal_term_used_per

	SET @sql = 'INSERT INTO #used_percentage (source_deal_header_id ,used_percentage )	
				SELECT a.source_deal_header_id, SUM(a.percentage_used) percentage_used 
				FROM (
					SELECT ud.source_deal_header_id, term_start, SUM(ISNULL(percentage_used ,0)) percentage_used 
					FROM ' + @link_deal_term_used_per + ' ud 
					INNER JOIN #no_dice_deal ndd on ud.source_deal_header_id = ndd.source_deal_header_id
					GROUP BY ud.source_deal_header_id, term_start
				 ) a 
				 GROUP BY a.source_deal_header_id
	'
	EXEC spa_print @sql			
	EXEC(@sql)			
	
	CREATE TABLE #hedge(
		curve_id INT,
		source_deal_header_id INT,
		deal_date DATETIME,
		term_start DATETIME,
		term_end DATETIME,
		deal_volume FLOAT,
		buy_sell CHAR(1) COLLATE DATABASE_DEFAULT NULL,
		per FLOAT DEFAULT 0,
		volume FLOAT,
		used BIT DEFAULT 0,
		fas_book_id INT,
		eff_test_profile_id INT,
		idx_vol FLOAT, --for perfect match
		no_indx INT,
		no_terms INT,
		initial_vol_ava FLOAT,
		initial_per_ava FLOAT,
		operation_status CHAR(1) COLLATE DATABASE_DEFAULT NULL, --n:netting, m=matching
		deal_id1 VARCHAR(150) COLLATE DATABASE_DEFAULT,
		link_effect_date DATETIME,
		CurveName VARCHAR(250) COLLATE DATABASE_DEFAULT NULL,
		book_map_id INT,
		fas_sub_id INT,
		org_curve_id INT,
		uom_id INT)

	CREATE TABLE #item(
		curve_id INT,
		source_deal_header_id INT,
		deal_date DATETIME,
		term_start DATETIME,
		term_end DATETIME,
		deal_volume FLOAT,
		buy_sell VARCHAR(1) COLLATE DATABASE_DEFAULT NULL,
		per FLOAT DEFAULT 0,
		volume FLOAT,
		used BIT DEFAULT 0,
		idx_vol FLOAT,  --for perfect match
		no_indx INT,
		no_terms INT,
		initial_vol_ava FLOAT,
		initial_per_ava FLOAT,
		operation_status VARCHAR(1) COLLATE DATABASE_DEFAULT NULL, --n:netting, m=matching
		org_buy_sell CHAR(1) COLLATE DATABASE_DEFAULT,
		deal_id1 VARCHAR(150) COLLATE DATABASE_DEFAULT NULL,
		link_effect_date DATETIME
		,eff_test_profile_id INT
		,fas_book_id INT
		,org_curve_id INT,
		book_map_id INT,
		fas_sub_id INT,
		uom_id INT
	)

	SET @sql = ' INSERT INTO #hedge( curve_id,source_deal_header_id,deal_date,term_start,term_end,volume ,per,buy_sell,deal_volume
									, fas_book_id,eff_test_profile_id,idx_vol,no_indx,no_terms,initial_vol_ava
									, initial_per_ava,deal_id1,link_effect_date,CurveName,book_map_id,fas_sub_id,org_curve_id ,uom_id)
				SELECT    
					sdd.curve_id,dh.source_deal_header_id, dh.deal_date, MIN(sdd.term_start), MAX(sdd.term_end),
					vol * (1 - AVG(ISNULL(used_percentage,0))) Volume, 1 - AVG(ISNULL(up.used_percentage,0)) AS PercLinked,
					MAX(sdd.buy_sell),sdd_vol.d_vol,ISNULL(t.fas_book_id, -1), ISNULL(t.eff_test_profile_id,-1),
					vol,MAX(indx_no),t_no_terms.no_terms AS cnt, vol * (1-AVG(ISNULL(up.used_percentage, 0))) initial_vol_ava,
					1- AVG(ISNULL(used_percentage,0)) initial_per_ava, MAX(dh.deal_id) deal_id,
					MAX(dh.deal_date) link_effect_date
					,MAX(source_price_curve_def.curve_id) CurveName, MAX(sbmp.book_deal_type_map_id),MAX(b.fas_sub_id), sdd.curve_id, MAX(sdd.uom_id)
				FROM source_deal_header dh 
				INNER JOIN #tmp_sdd1 sdd on dh.source_deal_header_id = sdd.source_deal_header_id AND dh.deal_status <> 5607
				INNER JOIN (SELECT DISTINCT h_curve_id FROM #map_n_curve) map ON map.h_curve_id = sdd.curve_id
				INNER JOIN #tmp_not_MA_deals ma_d ON dh.source_deal_header_id = ma_d.source_deal_header_id
				INNER JOIN #tmp_sdd_vol sdd_vol ON dh.source_deal_header_id = sdd_vol.source_deal_header_id
				INNER JOIN #no_index_in_deal indx ON dh.source_deal_header_id = indx.source_deal_id
				INNER JOIN source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
					AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
					AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
					AND dh.source_system_book_id4 = sbmp.source_system_book_id4  
					AND ISNULL(dh.fas_deal_type_value_id,sbmp.fas_deal_type_value_id) = 400 '+ CASE WHEN @book_map_ids IS NOT NULL 
						THEN  ' AND sbmp.book_deal_type_map_id IN(' + @book_map_ids + ') '  ELSE '' END +'
				INNER JOIN #books b ON b.fas_book_id = sbmp.fas_book_id
				INNER JOIN #no_terms_in_index t_no_terms ON sdd.source_deal_header_id = t_no_terms.source_deal_id AND sdd.curve_id = t_no_terms.indx
				' + CASE WHEN ISNULL(@externalization, 'n') = 'y' OR ISNULL(@only_include_external_der, 'n') = 'y' THEN 
					' INNER JOIN source_counterparty sc ON dh.counterparty_id = sc.source_counterparty_id AND sc.int_ext_flag = ''e'''
					ELSE '' END + '	LEFT JOIN source_price_curve_def ON sdd.curve_id = source_price_curve_def.source_curve_def_id 
				LEFT JOIN #used_percentage up ON up.source_deal_header_id = dh.source_deal_header_id 
				LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
				LEFT JOIN fas_link_header flh ON fld.link_id = flh.link_id
				LEFT JOIN fas_eff_hedge_rel_type fehrt ON fehrt.eff_test_profile_id=flh.eff_test_profile_id and fehrt.profile_active = ''y'' 
					AND fehrt.profile_approved=''y'' AND ISNULL(fehrt.externalization,''n'') = ''' + ISNULL(@externalization, 'n') + '''
				LEFT JOIN #tmp_rel_type t ON sdd.curve_id = t.curve_id AND sbmp.fas_book_id=t.fas_book_id
				WHERE  dh.deal_date <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + '''' +CASE WHEN @as_of_date_from IS NULL THEN '' ELSE ' and dh.deal_date >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120) + '''' END + '
					AND ISNULL(fehrt.matching_type,''a'') in (''a'',''b'')
				GROUP BY sdd.curve_id,dh.deal_date,dh.source_deal_header_id,t.fas_book_id,t.eff_test_profile_id,d_vol,vol,t_no_terms.no_terms
				HAVING (1 - AVG(ISNULL(used_percentage, 0))) >= 0.01
		'

	EXEC spa_print @sql
	EXEC(@sql)

	--seems the is not used in below statement (LEFT JOIN fas_eff_hedge_rel_type fehrt on fehrt.eff_test_profile_id=flh.eff_test_profile_id and fehrt.profile_active=''y'' and fehrt.profile_approved=''y'' AND ISNULL(fehrt.externalization,''n'')='''+ISNULL(@externalization,'n') +''')
	--inserting unlinked item
	SET @sql = ' INSERT INTO #item(curve_id,source_deal_header_id,deal_date,term_start,term_end,volume,per,buy_sell,deal_volume,
									idx_vol,no_indx,no_terms,initial_vol_ava,initial_per_ava,org_buy_sell,deal_id1,link_effect_date,fas_book_id,eff_test_profile_id
									, org_curve_id,book_map_id,fas_sub_id,uom_id)
				SELECT sdd.curve_id, dh.source_deal_header_id,dh.deal_date, MIN(sdd.term_start), MAX(sdd.term_end),
					vol * (1 - AVG(ISNULL(used_percentage,0))) Volume, 1 - AVG(ISNULL(used_percentage,0)) AS PercLinked,
					CASE WHEN ISNULL(MAX(fbook.hedge_item_same_sign), ''n'') = ''n'' THEN
						CASE  MAX(sdd.buy_sell) when ''b'' then ''s'' when ''s'' then ''b'' ELSE MAX(sdd.buy_sell) END
					ELSE 
						MAX(sdd.buy_sell)
					END as [buy_sell],	d_vol,vol,indx_no,t_no_terms.no_terms cnt,
					vol*(1-AVG(ISNULL(used_percentage,0))) initial_vol_ava,1-AVG(ISNULL(used_percentage,0)) initial_per_ava,MAX(sdd.buy_sell) org_buy_sell,
					MAX(dh.deal_id) deal_id,
					MAX(dh.deal_date) link_effect_date
					, MAX(sbmp.fas_book_id) fas_book_id, MAX(t.eff_test_profile_id) eff_test_profile_id,sdd.curve_id, MAX(sbmp.book_deal_type_map_id)
					, MAX(b.fas_sub_id),MAX(sdd.uom_id)
				FROM source_deal_header dh 
				INNER JOIN #tmp_sdd1 sdd ON dh.source_deal_header_id=sdd.source_deal_header_id AND dh.deal_status <> 5607
				INNER JOIN (SELECT DISTINCT i_curve_id from #map_n_curve) map ON map.i_curve_id=sdd.curve_id
				INNER JOIN #tmp_not_MA_deals ma_d ON dh.source_deal_header_id = ma_d.source_deal_header_id
				INNER JOIN #tmp_sdd_vol sdd_vol ON dh.source_deal_header_id = sdd_vol.source_deal_header_id
				INNER JOIN #no_index_in_deal indx ON dh.source_deal_header_id = indx.source_deal_id
				INNER JOIN source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
					AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
					AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
					AND dh.source_system_book_id4 = sbmp.source_system_book_id4 ' + CASE WHEN @book_map_ids IS NOT NULL THEN  ' AND sbmp.book_deal_type_map_id IN(' + @book_map_ids + ') '  ELSE '' END +'
					AND ISNULL(dh.fas_deal_type_value_id,sbmp.fas_deal_type_value_id) = ' + CASE WHEN ISNULL(@externalization,'n')='y' THEN '400 '	ELSE '401 ' END + ' 
				INNER JOIN #books b ON b.fas_book_id = sbmp.fas_book_id
				INNER JOIN #no_terms_in_index t_no_terms ON sdd.source_deal_header_id = t_no_terms.source_deal_id and sdd.curve_id = t_no_terms.indx
				'+ CASE WHEN ISNULL(@externalization,'n') = 'y' THEN 
					' INNER JOIN source_counterparty sc ON dh.counterparty_id=sc.source_counterparty_id AND sc.int_ext_flag = ''i'''
					ELSE '' END + '
				LEFT JOIN fas_books fbook ON fbook.fas_book_id=b.fas_book_id
				LEFT JOIN source_price_curve_def ON sdd.curve_id=source_price_curve_def.source_curve_def_id
				LEFT JOIN #used_percentage ON #used_percentage.source_deal_header_id = dh.source_deal_header_id 
				LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
				LEFT JOIN fas_link_header flh ON fld.link_id=flh.link_id
				LEFT JOIN fas_eff_hedge_rel_type fehrt ON fehrt.eff_test_profile_id=flh.eff_test_profile_id and fehrt.profile_active=''y'' and fehrt.profile_approved=''y'' AND ISNULL(fehrt.externalization,''n'')='''+ISNULL(@externalization,'n') +'''
				LEFT JOIN #tmp_rel_type_item t ON sdd.curve_id=t.curve_id and sbmp.fas_book_id=t.fas_book_id
				WHERE  dh.deal_date <= ''' + CONVERT(VARCHAR(10), @as_of_date_to, 120) + '''' + CASE WHEN @as_of_date_from IS NULL THEN '' ELSE ' and dh.deal_date >= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 120) + '''' END + ' 
					AND ISNULL(fehrt.matching_type, ''a'') in (''a'', ''b'')
				GROUP BY sdd.curve_id,dh.deal_date,dh.source_deal_header_id,d_vol,indx_no,t_no_terms.no_terms,vol
				HAVING ( 1 - AVG(ISNULL(used_percentage, 0))) >= 0.01 
		'
	EXEC spa_print @sql
	EXEC(@sql)

	IF ISNULL(@call_for_report, 'n') = 'l' --  call from limit calculation
	BEGIN
		IF @v_curve_id IS NOT NULL
			DELETE #item 
			FROM #item i 
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = i.curve_id 
			WHERE ISNULL(spcd.proxy_source_curve_def_id,i.curve_id) <> @v_curve_id
	END

	CREATE INDEX indx_hedde_1 ON #hedge (curve_id,term_start,term_end,deal_date)
	CREATE INDEX indx_item_1 ON #item (curve_id,term_start,term_end,deal_date)
	CREATE INDEX indx_hedde_2 ON #hedge (source_deal_header_id)
	CREATE INDEX indx_item_2 ON #item (source_deal_header_id)

	--UPDATE relationship type those not found with in same book.
	/*
	UPDATE #item SET eff_test_profile_id = tmp.eff_test_profile_id  ,fas_book_id = tmp.fas_book_id
	FROM #item t CROSS apply 
		(SELECT top(1) curve_id, eff_test_profile_id ,fas_book_id
		   FROM #tmp_rel_type_item r where r.curve_id = t.curve_id order BY eff_test_profile_id)  tmp 
	WHERE t.eff_test_profile_id IS NULL 
	*/
	--UPDATE curve id of hegde relationship type curve that have  relationship type id for matching with hedge.
	/*
	UPDATE #item SET curve_id = tmp.source_curve_def_id
	 SELECT * FROM #item t cross  apply 
	(
		SELECT top(1) source_curve_def_id
			from fas_eff_hedge_rel_type h INNER JOIN fas_eff_hedge_rel_type_detail d 
			on h.eff_test_profile_id=d.eff_test_profile_id AND h.eff_test_profile_id=47--t.eff_test_profile_id
			AND d.hedge_or_item='h'
		ORDER BY source_curve_def_id
	) tmp
	WHERE t.eff_test_profile_id IS NOT NULL
	 */
	--END Fetching Hedge and Item Deals *******************************************************************************************
	--select sdh.deal_id,* from #hedge h INNER JOIN source_deal_header sdh ON h.source_deal_header_id=sdh.source_deal_header_id
	--select sdh.deal_id,* from #item h INNER JOIN source_deal_header sdh ON h.source_deal_header_id=sdh.source_deal_header_id

	--Excuding Deals **********************************************************************************************
	--IF ISNULL(@perform_dicing ,'y')='n'
	--BEGIN
	--	DELETE #hedge WHERE ABS(volume)<=10
	--	DELETE #item WHERE ABS(volume)<=10
	--END
	
	DELETE #hedge FROM #hedge h INNER JOIN exclude_deal_auto_matching a ON (h.source_deal_header_id=a.source_deal_header_id1 OR h.source_deal_header_id=a.source_deal_header_id2) AND a.exclude_flag='r'
	DELETE #item FROM #item i INNER JOIN exclude_deal_auto_matching a ON (i.source_deal_header_id=a.source_deal_header_id1 OR i.source_deal_header_id=a.source_deal_header_id2) AND a.exclude_flag='r'
	DELETE #item FROM #item i LEFT JOIN #exclude_deals e ON i.source_deal_header_id=e.source_deal_header_id
	WHERE e.source_deal_header_id IS NOT NULL
	
	/*
	INSERT INTO #netting_item (curve_id,deal_date,term_start,term_end,no_indx,volume,sell_no_rec,buy_no_rec)
	
	SELECT  curve_id,term_start,term_end,no_indx,volume,SUM(CASE WHEN buy_sell='s' THEN 1 ELSE 0 END) sell_no_rec,SUM(CASE WHEN buy_sell='b' THEN 1 ELSE 0 END) buy_no_rec
	FROM #item WHERE [used]=0 and term_start='2014-01-01'
	GROUP BY curve_id,term_start,term_end,no_indx,volume
	
	HAVING SUM(CASE WHEN buy_sell='s' THEN 1 ELSE -1 END*volume )=0

	UPDATE #item SET [used] = 1,operation_status='n' FROM #netting_item n INNER JOIN #item i
	ON n.curve_id=i.curve_id AND n.deal_date=i.deal_date AND n.term_start=i.term_start AND n.term_end=i.term_end AND n.no_indx=i.no_indx AND n.volume=i.volume

	TRUNCATE TABLE #netting_item
	select * from #item where 
	operation_status='n' and term_start='2013-01-01' and ddeal_date='2012-01-26 00:00:00.000'
	source_deal_header_id in(751950,752355,752357)
	*/
	INSERT INTO #netting_item (curve_id,deal_date,term_start,term_end,no_indx,volume,sell_no_rec,buy_no_rec)
	SELECT curve_id,deal_date ,term_start,term_end,no_indx,volume,SUM(CASE WHEN buy_sell='s' THEN 1 ELSE 0 END) sell_no_rec,SUM(CASE WHEN buy_sell='b' THEN 1 ELSE 0 END) buy_no_rec
	FROM #item WHERE [used]=0
	GROUP BY curve_id,term_start,term_end,no_indx,volume,deal_date
	HAVING SUM(CASE WHEN buy_sell='s' THEN 1 ELSE 0 END) > 0 AND SUM(CASE WHEN buy_sell='b' THEN 1 ELSE 0 END) > 0

	DECLARE netting CURSOR FOR 
	SELECT curve_id,deal_date,term_start,term_end,no_indx,volume,sell_no_rec,buy_no_rec FROM #netting_item  --where  term_start='2014-01-01'
	OPEN netting
	FETCH NEXT FROM netting INTO @c_curve_id ,@c_deal_date ,@c_term_start ,@c_term_end ,@c_no_indx ,@c_volume ,@c_sell_no_rec ,@c_buy_no_rec
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--PRINT 'b'
		--select  @c_curve_id ,@c_deal_date ,@c_term_start ,@c_term_end ,@c_no_indx ,@c_volume ,@c_sell_no_rec ,@c_buy_no_rec
		UPDATE TOP(CASE WHEN  @c_sell_no_rec < @c_buy_no_rec THEN @c_sell_no_rec ELSE @c_buy_no_rec END) #item 
		SET [used] = 1,operation_status='n' 
		FROM #netting_item n 
		INNER JOIN #item i ON n.curve_id = i.curve_id AND n.deal_date = i.deal_date 
			AND n.term_start=i.term_start AND n.term_end = i.term_end AND n.no_indx = i.no_indx AND n.volume = i.volume
		WHERE i.buy_sell = 'b' 
			AND i.term_start = @c_term_start 
			AND i.term_end = @c_term_end
			AND i.curve_id = @c_curve_id
			AND i.volume = @c_volume 
			AND i.deal_date = @c_deal_date
 
		UPDATE TOP(CASE WHEN  @c_sell_no_rec <@c_buy_no_rec THEN @c_sell_no_rec ELSE @c_buy_no_rec END) #item 
		SET [used] = 1,operation_status='n' 
		FROM #netting_item n 
		INNER JOIN #item i ON n.curve_id = i.curve_id --AND n.deal_date=i.deal_date 
			AND n.term_start = i.term_start AND n.term_end = i.term_end AND n.no_indx=i.no_indx AND n.volume = i.volume
		WHERE i.buy_sell = 's' 
			AND i.term_start = @c_term_start 
			AND i.term_end = @c_term_end 
			AND i.curve_id = @c_curve_id
			AND i.volume = @c_volume
			AND i.deal_date = @c_deal_date
		
		FETCH NEXT FROM netting INTO @c_curve_id ,@c_deal_date ,@c_term_start ,@c_term_end ,@c_no_indx ,@c_volume ,@c_sell_no_rec ,@c_buy_no_rec
	END
	CLOSE netting
	DEALLOCATE netting
	--END Excuding Deals **********************************************************************************************
		
	IF ISNULL(@limit_chcking,0)=1
	BEGIN
		IF OBJECT_ID('tempdb..#proxy_item_curve_id') IS NOT NULL
		DROP TABLE #proxy_item_curve_id

		SELECT DISTINCT ISNULL(spcd.proxy_source_curve_def_id,i.curve_id) curve_id 
			INTO #proxy_item_curve_id 
		FROM #item i 
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=i.curve_id 

		SET @sql = 'DELETE h FROM ' + @hedge_capacity + ' h LEFT JOIN  #proxy_item_curve_id  i ON h.curve_id=i.curve_id WHERE i.curve_id IS NULL '
					+ CASE WHEN @sub_id IS NOT NULL THEN ' AND fas_sub_id in (' + @sub_id + ')' ELSE '' END
		EXEC spa_print @sql
		EXEC(@sql)

		CREATE TABLE #hedge_under (ROWID INT IDENTITY(1,1), [entity_id] INT,curve_id INT,term_start DATETIME,term_end DATETIME, net_vol NUMERIC(26,10),available_vol NUMERIC(26,10))

		SET @sql = 'INSERT INTO #hedge_under (entity_id ,curve_id ,term_start,term_end, net_vol ,available_vol)
					SELECT fas_sub_id, curve_id,TenorStart ,TenorEnd, SUM(net_vol) net_vol,SUM(net_vol) net_vol 
					FROM ' + @hedge_capacity  + ' 
					WHERE over_hedge=''No'' and ISNULL(net_vol,0) <> 0 ' + CASE WHEN @v_curve_id IS NULL THEN '' ELSE ' AND curve_id = ' + CAST(@v_curve_id AS VARCHAR) END + '
					GROUP BY fas_sub_id,curve_id ,TenorStart,TenorEnd'
		EXEC spa_print @sql
		EXEC(@sql)
		
		DELETE #item FROM #item i 
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = i.curve_id 
		LEFT JOIN #hedge_under u ON ISNULL(spcd.proxy_source_curve_def_id, i.curve_id) = u.curve_id
		WHERE u.curve_id IS NULL
	END			

	SET @p_source_deal_header_id_h = 0
	SET @p_source_deal_header_id_i = 0

	IF @firest_time = 1
	BEGIN
		SELECT * INTO #hedge_int FROM #hedge 
		SELECT * INTO #item_int FROM #item 
		SET @firest_time = 0
	END
	--goto Process_dicing
	--PRINT '2. All matched'

	SELECT h.deal_date h_date,i.deal_date i_date,h.source_deal_header_id source_deal_header_id_h,h.per per_h,i.source_deal_header_id source_deal_header_id_i,i.per per_i
		, COALESCE(map.fas_book_id,i.fas_book_id,h.fas_book_id,-1) fas_book_id
		,  COALESCE(map.eff_test_profile_id,i.eff_test_profile_id,h.eff_test_profile_id,-1)  eff_test_profile_id,h.no_indx,h.deal_id1 h_deal_id,i.deal_id1 i_deal_id
		, CASE WHEN h.link_effect_date>i.link_effect_date THEN h.link_effect_date ELSE i.link_effect_date END link_effect_date,h.CurveName,h.term_start,h.term_end
		INTO #perfect_match
	FROM #hedge h INNER JOIN #item i ON h.term_start=i.term_start
		AND h.term_end=i.term_end AND h.volume=i.volume AND h.buy_sell=i.buy_sell
		AND h.used=0 AND i.used=0 AND h.no_indx=i.no_indx AND h.no_terms=i.no_terms
		-- and h.fas_sub_id=CASE WHEN i.fas_sub_id IS NULL then h.fas_sub_id ELSE i.fas_sub_id END 
		AND h.initial_per_ava>=0.01 and i.initial_per_ava>=0.01
	INNER JOIN #no_dice_deal nd ON i.source_deal_header_id=nd.source_deal_header_id
	INNER JOIN (SELECT DISTINCT * FROM #map_n_curve) map ON h.curve_id=map.h_curve_id and i.curve_id=map.i_curve_id
		AND h.book_map_id = CASE WHEN map.h_book_map_id IS NULL THEN h.book_map_id ELSE map.h_book_map_id END  
		AND i.book_map_id = CASE WHEN map.i_book_map_id IS NULL THEN i.book_map_id ELSE map.i_book_map_id END
	--	WHERE ABS(h.volume)> 10 AND ABS(i.volume)>10;
	
	DELETE #perfect_match FROM #perfect_match p 
	INNER JOIN exclude_deal_auto_matching a ON p.source_deal_header_id_h = a.source_deal_header_id1 
		AND p.source_deal_header_id_i=a.source_deal_header_id2 AND a.exclude_flag='m'
	
	SET @sql = ' DECLARE perfect_match CURSOR GLOBAL FOR 
				SELECT source_deal_header_id_h,per_h,source_deal_header_id_i,per_i,MAX(fas_book_id) fas_book_id
					, MAX(eff_test_profile_id) eff_test_profile_id,MAX(link_effect_date) link_effect_date,i_deal_id,h_deal_id
					, MAX(CurveName) CurveName,MIN(term_start) term_start,MAX(term_end) term_end  from #perfect_match'
				 + CASE ISNULL(@deal_dt_option,'i') WHEN 'i' THEN ' WHERE h_date <= i_date'  WHEN 'h' THEN ' WHERE h_date >= i_date' ELSE '' END +'
				GROUP BY h_date,source_deal_header_id_h,i_date,source_deal_header_id_i,per_h,per_i,no_indx,i_deal_id,h_deal_id
				HAVING COUNT(*)=no_indx
				ORDER BY ' + CASE WHEN ISNULL(@fifo_lifo,'f')= 'f' 
								THEN 'h_date,source_deal_header_id_h,i_date,source_deal_header_id_i'
								ELSE 'h_date desc,source_deal_header_id_h desc,i_date desc,source_deal_header_id_i desc'
							END
					
	EXEC(@sql)
	OPEN perfect_match
	FETCH NEXT FROM perfect_match INTO @source_deal_header_id_h,@per_h,@source_deal_header_id_i ,@per_i,@new_book_id,@eff_test_profile_id,@link_effect_date,@i_deal_id,@h_deal_id,@CurveName,@term_start,@term_end
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @p_source_deal_header_id_h<>@source_deal_header_id_h  AND @p_source_deal_header_id_i <> @source_deal_header_id_i
		BEGIN
			IF NOT EXISTS(SELECT * FROM #used_i_source_deal_header_id WHERE h_source_deal_header_id=@source_deal_header_id_h OR i_source_deal_header_id=@source_deal_header_id_i)
			BEGIN
				--validate over allocation
					
				SELECT @recent_per_used_h = SUM(CASE WHEN used_per.source_deal_header_id=@source_deal_header_id_h THEN percentage_use ELSE 0 END) ,
						@recent_per_used_i = SUM(CASE WHEN used_per.source_deal_header_id=@source_deal_header_id_i THEN percentage_use ELSE 0 END) 
				FROM (
					SELECT 	gfld.deal_number source_deal_header_id, SUM(gfld.percentage_included) AS  percentage_use, MAX('o') src
					FROM gen_fas_link_detail gfld 	
					INNER JOIN	gen_fas_link_header gflh ON gflh.gen_link_id = gfld.gen_link_id
						AND gflh.gen_status = 'a' and gfld.deal_number in(@source_deal_header_id_i,@source_deal_header_id_h) 
					GROUP BY gfld.deal_number
					UNION ALL
					SELECT source_deal_header_id,SUM(CASE WHEN CONVERT(VARCHAR(10),@as_of_date_to,120) >=ISNULL(fas_link_header.link_end_date,'9999-01-01') THEN 0 ELSE percentage_included END) percentage_included,MAX('f') FROM fas_link_detail INNER JOIN fas_link_header
					ON  fas_link_detail.link_id=fas_link_header.link_id and source_deal_header_id in(@source_deal_header_id_i,@source_deal_header_id_h) and link_type_value_id =450 GROUP BY source_deal_header_id
					UNION ALL
					SELECT a.source_deal_header_id ,SUM(a.[per_dedesignation]) [per_dedesignation],MAX('l') src FROM 
						(SELECT DISTINCT process_id ,source_deal_header_id ,[per_dedesignation] 
						FROM [dbo].[dedesignated_link_deal] 
						WHERE source_deal_header_id IN (@source_deal_header_id_i,@source_deal_header_id_h)
						) a GROUP BY a.source_deal_header_id
				) used_per -- GROUP BY used_per.source_deal_header_id
					
				IF @recent_per_used_h + @per_h > 1.01001 OR @recent_per_used_i + @per_i > 1.01001
				BEGIN
					IF @recent_per_used_h+@per_h>1.01001
						INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, [source], [type], [description], nextsteps) 
						VALUES(@process_id,'Error', 'Auto Matching', 'Automatic Matching',
						'Database Error','Critical Error Found [ Over Allocation found in perfect for Source_Deal_Header_ID:'+ CAST(@source_deal_header_id_h AS VARCHAR) +'; Already_Used_per: '+CAST(@recent_per_used_h AS VARCHAR)+'; new_proposed_per:'+CAST(@per_h AS VARCHAR)+']' , 'Please contact support.')
					IF @recent_per_used_i+@per_i>1.01001
						INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, [source], [type], [description], nextsteps) 
						VALUES(@process_id,'Error', 'Auto Matching', 'Automatic Matching',
						'Database Error','Critical Error Found [ Over Allocation found in perfect for Source_Deal_Header_ID:'+ CAST(@source_deal_header_id_h AS VARCHAR) +'; Already_Used_per: '+CAST(@recent_per_used_i AS VARCHAR)+'; new_proposed_per:'+CAST(@per_i AS VARCHAR)+']' , 'Please contact support.')
				END
				ELSE
				BEGIN
					--making 100%
					IF @recent_per_used_h + @per_h > 1
						SET @Proposed_per_h = 1 - @recent_per_used_h --round(@recent_per_used_h,2)
					ELSE
						SET @Proposed_per_h = @per_h
					IF @recent_per_used_i + @per_i > 1
						SET @Proposed_per_i = 1 - @recent_per_used_i--round(@recent_per_used_i,2)
					ELSE
						SET @Proposed_per_i=@per_i

					INSERT INTO #used_i_source_deal_header_id (h_source_deal_header_id,i_source_deal_header_id) VALUES (@source_deal_header_id_h,@source_deal_header_id_i)
					INSERT INTO gen_hedge_group	(gen_hedge_group_name, link_type_value_id, hedge_effective_date, eff_test_profile_id,perfect_hedge, reprice_items_id,tenor_from, tenor_to, reprice_date,tran_type) 
					VALUES(@h_deal_id+'/'+@i_deal_id +'('+ @CurveName + ' '+CONVERT(VARCHAR(7),@term_start,120)+':'+CONVERT(VARCHAR(7),@term_end,120)+')'
							, 450, @link_effect_date, ISNULL(@eff_test_profile_id,-1),'n',NULL, NULL, NULL,NULL,'m')
					
					SET @gen_hedge_group_id=SCOPE_IDENTITY()

					INSERT INTO [gen_fas_link_header] ([gen_hedge_group_id],[gen_approved],[used_ass_profile_id],[fas_book_id],[perfect_hedge] ,[link_description]
								,[eff_test_profile_id] ,[link_effective_date],[link_type_value_id] ,[link_id],[gen_status],[process_id],create_user,create_ts)
							VALUES (@gen_hedge_group_id,'n',78,@new_book_id ,'n' ,@h_deal_id+'/'+@i_deal_id +'('+ @CurveName + ' '+CONVERT(VARCHAR(7),@term_start,120)+':'+CONVERT(VARCHAR(7),@term_end,120)+')'
								,ISNULL(@eff_test_profile_id,-1) ,@link_effect_date ,450 ,NULL ,'a' ,@process_id,@user_name,GETDATE())
						
					SET @new_link_id= SCOPE_IDENTITY()
					--SET @new_link_id= scope_identity() 
					INSERT INTO [gen_fas_link_detail] ([gen_link_id],[deal_number],[hedge_or_item] ,[percentage_included],effective_date)
					VALUES (@new_link_id,@source_deal_header_id_h,'h',@Proposed_per_h,@link_effect_date)
					INSERT INTO [gen_fas_link_detail] ([gen_link_id] ,[deal_number],[hedge_or_item] ,[percentage_included],effective_date)
					VALUES (@new_link_id,@source_deal_header_id_i,'i',@Proposed_per_i,@link_effect_date)
					UPDATE #hedge SET used=1 WHERE source_deal_header_id=@source_deal_header_id_h
					UPDATE #item SET used=1 WHERE source_deal_header_id=@source_deal_header_id_i
					SET @p_source_deal_header_id_h=@source_deal_header_id_h 
					SET @p_source_deal_header_id_i=@source_deal_header_id_i
					--INSERT INTO #deal_vs_link (link_id ,hedge_deal_id ,item_deal_id )select @new_link_id,@source_deal_header_id_h,@source_deal_header_id_i
				END
			END
		END
	FETCH NEXT FROM perfect_match INTO @source_deal_header_id_h,@per_h,@source_deal_header_id_i ,@per_i,@new_book_id,@eff_test_profile_id,@link_effect_date,@i_deal_id,@h_deal_id,@CurveName,@term_start,@term_end
	END
	CLOSE perfect_match
	DEALLOCATE perfect_match
	
	IF EXISTS(SELECT 1 FROM #used_i_source_deal_header_id ) 
		SET @exit_perfect =0
	ELSE 
		SET @exit_perfect =1
		
	DELETE #used_i_source_deal_header_id
	SET @p_source_deal_header_id_h = 0
	SET @p_source_deal_header_id_i = 0

	SET @link_per = 0

	IF ISNULL(@slicing_first, 'h') = 'i'
	BEGIN
		--PRINT '***********Process_slicing_I*********************************'
		GOTO Process_slicing_I
	END
	----------------------------------------------------------------------------------------------------------------------------------

	Process_slicing_H:
	--PRINT '4. matched by slicing (i.volume<=h.volume)'
	SET @p_source_deal_header_id_h=0
	SET @p_source_deal_header_id_i=0
	SET @deal_volume_p=0
	SET @new_link_id=NULL
	SET @create_new_link='y'
	SET @link_per=0	
	DELETE #used_i_source_deal_header_id
	
	SELECT h.deal_date h_date,i.deal_date i_date,h.source_deal_header_id source_deal_header_id_h,h.volume volume_h,h.deal_volume,h.per per_h,i.source_deal_header_id source_deal_header_id_i
		, i.volume volume_i,i.per per_i,COALESCE(map.fas_book_id,i.fas_book_id,h.fas_book_id,-1) fas_book_id
		, COALESCE(map.eff_test_profile_id,i.eff_test_profile_id,h.eff_test_profile_id,-1)  eff_test_profile_id,h.no_indx,h.deal_id1 h_deal_id,i.deal_id1 i_deal_id,i.deal_volume deal_volume_i
		, CASE WHEN h.link_effect_date>i.link_effect_date THEN h.link_effect_date ELSE i.link_effect_date END link_effect_date,h.CurveName,h.term_start,h.term_end
		INTO #perfect_match1 
	FROM #hedge h 
	INNER JOIN #item i ON h.term_start = i.term_start	
		AND h.term_end = i.term_end 	
		AND h.buy_sell = i.buy_sell 
		AND h.used = 0 
		AND i.used = 0 	
		AND h.no_indx  =i.no_indx 
		AND h.no_terms = i.no_terms -- AND h.deal_date<=i.deal_date
	--	AND h.fas_sub_id=CASE WHEN i.fas_sub_id IS NULL then h.fas_sub_id ELSE i.fas_sub_id END 
		AND h.initial_per_ava >= 0.01 
		AND i.initial_per_ava >= 0.01
	INNER JOIN (SELECT DISTINCT * from #map_n_curve)  map on h.curve_id=map.h_curve_id AND i.curve_id=map.i_curve_id
		AND h.book_map_id = CASE WHEN map.h_book_map_id IS NULL then h.book_map_id ELSE map.h_book_map_id END  
		AND i.book_map_id = CASE WHEN map.i_book_map_id IS NULL then i.book_map_id ELSE map.i_book_map_id END
	INNER JOIN #no_dice_deal nd on i.source_deal_header_id=nd.source_deal_header_id
			
	DELETE #perfect_match1 
	FROM #perfect_match1 p 
	INNER JOIN exclude_deal_auto_matching a ON p.source_deal_header_id_h = a.source_deal_header_id1 AND p.source_deal_header_id_i = a.source_deal_header_id2 AND a.exclude_flag='m'
	

	SET @sql = 'DECLARE perfect_match CURSOR GLOBAL FOR 
				SELECT source_deal_header_id_h,SUM(volume_h) volume_h,deal_volume, per_h,source_deal_header_id_i,
					SUM(volume_i) volume_i,per_i,fas_book_id,eff_test_profile_id,MAX(link_effect_date) link_effect_date,i_deal_id,h_deal_id,
					MAX(CurveName) CurveName,MIN(term_start) term_start,MAX(term_end) term_end,MAX(deal_volume_i) deal_volume_i
				FROM #perfect_match1'
				 + CASE ISNULL(@deal_dt_option, 'i') WHEN 'i' THEN ' WHERE h_date <= i_date'  WHEN 'h' THEN ' WHERE h_date >= i_date' ELSE '' END +'
				GROUP BY h_date,source_deal_header_id_h,i_date,source_deal_header_id_i,deal_volume, per_h,per_i,fas_book_id,eff_test_profile_id,no_indx ,i_deal_id,h_deal_id
				HAVING COUNT(*) = no_indx order by '+
	CASE WHEN ISNULL(@fifo_lifo, 'f') = 'f'
		THEN 'h_date,source_deal_header_id_h,i_date,source_deal_header_id_i'
		ELSE 'h_date desc,source_deal_header_id_h desc,i_date desc,source_deal_header_id_i desc'
	END
	EXEC(@sql)
	OPEN perfect_match
	FETCH NEXT FROM perfect_match INTO @source_deal_header_id_h ,@volume_h,@deal_volume,@per_h,@source_deal_header_id_i ,@volume_i,@per_i,@new_book_id,@eff_test_profile_id,@link_effect_date,@i_deal_id,@h_deal_id,@CurveName,@term_start,@term_end,@deal_volume_i
	WHILE @@FETCH_STATUS = 0
	BEGIN
	  IF CAST(@volume_i AS FLOAT) / NULLIF(@deal_volume, 0) >= .01
	  BEGIN
			IF NOT EXISTS(SELECT * FROM #used_i_source_deal_header_id WHERE  h_source_deal_header_id=@source_deal_header_id_h OR i_source_deal_header_id=@source_deal_header_id_i)
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM gen_fas_link_detail WHERE gen_link_id = @new_link_id AND deal_number = @p_source_deal_header_id_h AND hedge_or_item='h')					
				BEGIN
					-- at the first time of each hedge deal
					IF @p_source_deal_header_id_h <> @source_deal_header_id_h AND @p_source_deal_header_id_i <> @source_deal_header_id_i
					BEGIN
						
						IF @p_source_deal_header_id_h <> 0
						BEGIN 
							--PRINT '--------Previous Hedge------------------'
							--PRINT 'deal_id:'+CAST(@p_source_deal_header_id_h AS VARCHAR)
							--PRINT @link_per
							--PRINT 'link_id:'+CAST(@new_link_id AS VARCHAR)
							--PRINT 'Volume:'+CAST(@deal_volume_p AS VARCHAR)

							--PRINT '--------------------------'
							INSERT INTO [gen_fas_link_detail] ([gen_link_id],[deal_number],[hedge_or_item] ,[percentage_included],effective_date)
								VALUES (@new_link_id,@p_source_deal_header_id_h,'h',@link_per,@p_link_effect_date)
						END 				
						
						SET @temp_vol=@volume_h
						SET @temp_per=@per_h
						SET @create_new_link='y'

					END
				END
	--			IF (@temp_vol-@volume_i)>=0 --exclude item volume un match  with slice remaining hedge volume
				IF @temp_vol>0
				BEGIN	
						------validate over allocation
					SELECT @recent_per_used_h=SUM(CASE WHEN used_per.source_deal_header_id=@source_deal_header_id_h THEN percentage_use ELSE 0 END) ,
							@recent_per_used_i=SUM(CASE WHEN used_per.source_deal_header_id=@source_deal_header_id_i THEN percentage_use ELSE 0 END) 
					FROM (
						SELECT 	gfld.deal_number source_deal_header_id, SUM(gfld.percentage_included) AS  percentage_use,MAX('o') src
						FROM gen_fas_link_detail gfld 	
						INNER JOIN	gen_fas_link_header gflh ON gflh.gen_link_id = gfld.gen_link_id
							 AND gflh.gen_status = 'a' AND gfld.deal_number IN(@source_deal_header_id_i,@source_deal_header_id_h) 
						GROUP BY gfld.deal_number
						UNION ALL
						SELECT source_deal_header_id,SUM(CASE WHEN CONVERT(VARCHAR(10),@as_of_date_to,120) >=ISNULL(fas_link_header.link_end_date,'9999-01-01') THEN 0 ELSE percentage_included END) percentage_included,MAX('f') FROM fas_link_detail INNER JOIN fas_link_header
						ON  fas_link_detail.link_id=fas_link_header.link_id and source_deal_header_id in(@source_deal_header_id_i,@source_deal_header_id_h) and link_type_value_id =450 GROUP BY source_deal_header_id
						UNION ALL
						SELECT a.source_deal_header_id ,SUM(a.[per_dedesignation]) [per_dedesignation],MAX('l') src FROM 
						(
						SELECT DISTINCT process_id ,source_deal_header_id ,[per_dedesignation] FROM [dbo].[dedesignated_link_deal] where source_deal_header_id in (@source_deal_header_id_i,@source_deal_header_id_h)
						) a GROUP BY a.source_deal_header_id
					) used_per -- GROUP BY used_per.source_deal_header_id

					IF @volume_i > @temp_vol
					BEGIN
						--PRINT @volume_i
						--PRINT @temp_vol
						SET @temp_match_volume=@temp_vol
						SET @temp_match_per = (CAST(@temp_match_volume AS FLOAT) / NULLIF(@deal_volume_i, 0))
					END
					ELSE
					BEGIN
						SET @temp_match_volume=@volume_i
						SET @temp_match_per=@per_i
					END

					IF @recent_per_used_h + (CAST(@temp_match_volume AS FLOAT) / @deal_volume) > 1.01001 OR @recent_per_used_i + @temp_match_per > 1.01001
					BEGIN
						--PRINT '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
						--PRINT @recent_per_used_h
						--PRINT (CAST(@temp_match_volume AS FLOAT)/@deal_volume)
						--PRINT @recent_per_used_i
						--PRINT @temp_match_per
						--PRINT '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
						--PRINT 'h:'+ CAST(@source_deal_header_id_h AS VARCHAR)+ '          i:'+CAST(@source_deal_header_id_i AS VARCHAR)

						IF @recent_per_used_h+@temp_match_per>1.01001
							INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, [source], [type], [description], nextsteps) 
							VALUES(@process_id,'Error', 'Auto Matching', 'Automatic Matching',
							'Database Error','Critical Error Found [b Over Allocation foud in slicing (i.volume<=h.volume) for Hedge Source_Deal_Header_ID:'+ CAST(@source_deal_header_id_h AS VARCHAR) +'; Already_Used_per: '+CAST(@recent_per_used_h AS VARCHAR)+'; new_proposed_per:'+CAST((CAST(@temp_match_volume AS FLOAT)/NULLIF(@deal_volume, 0)) AS VARCHAR)+']' , 'Please contact support.')
						
						IF @recent_per_used_i+@temp_match_per>1.01001
						INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, [source], [type], [description], nextsteps) 
						VALUES(@process_id,'Error', 'Auto Matching', 'Automatic Matching',
						'Database Error','Critical Error Found [b Over Allocation foud in slicing (i.volume<=h.volume) for Item Source_Deal_Header_ID:'+ CAST(@source_deal_header_id_h AS VARCHAR) +'; Already_Used_per: '+CAST(@recent_per_used_i AS VARCHAR)+'; new_proposed_per:'+CAST(@temp_match_per AS VARCHAR)+']' , 'Please contact support.')
					END
					ELSE
					BEGIN
						--making 100%
						IF @recent_per_used_h + (CAST(@temp_match_volume AS FLOAT) / NULLIF(@deal_volume, 0)) > 1
							SET @Proposed_per_h = 1 - @recent_per_used_h ---round(@recent_per_used_h,2)
						ELSE
							SET @Proposed_per_h = (CAST(@temp_match_volume AS FLOAT) / NULLIF(@deal_volume, 0))
						IF @recent_per_used_i + @temp_match_per > 1
							SET @Proposed_per_i = 1 - @recent_per_used_i ---round(@recent_per_used_i,2)
						ELSE
							SET @Proposed_per_i = @temp_match_per							

						INSERT INTO #used_i_source_deal_header_id (h_source_deal_header_id,i_source_deal_header_id) 
						SELECT  CASE WHEN ISNULL(@slice_option,'m')='i' THEN @source_deal_header_id_h ELSE NULL END,@source_deal_header_id_i

						IF @volume_i <= @temp_vol
						BEGIN
							--PRINT '@volume_i<=@temp_vol'
							UPDATE #item SET used = 1 WHERE source_deal_header_id = @source_deal_header_id_i
						END
						ELSE
						BEGIN						
							UPDATE #item SET per = per - @Proposed_per_i WHERE source_deal_header_id = @source_deal_header_id_i
							UPDATE #item SET volume = per * idx_vol WHERE source_deal_header_id = @source_deal_header_id_i
						END
						SET @temp_vol=@temp_vol-@temp_match_volume
						SET @temp_per=@temp_per-@Proposed_per_h --round(CAST(@volume_i as FLOAT)/@deal_volume,2)

						--PRINT '@need_insert_detail1:'+CAST(@need_insert_detail AS  VARCHAR)
						IF @create_new_link = 'y'
						BEGIN
							INSERT INTO gen_hedge_group	(gen_hedge_group_name, link_type_value_id, hedge_effective_date, eff_test_profile_id,perfect_hedge, 
										reprice_items_id,tenor_from, tenor_to, reprice_date,tran_type) 
							VALUES(@h_deal_id+'/'+@i_deal_id +'('+ @CurveName + ' '+CONVERT(VARCHAR(7),@term_start,120)+':'+CONVERT(VARCHAR(7),@term_end,120)+')'
										, 450, @link_effect_date,ISNULL(@eff_test_profile_id,-1),'n',
										NULL, NULL, NULL,NULL,'m')
							SET @gen_hedge_group_id=SCOPE_IDENTITY()

							INSERT INTO [gen_fas_link_header] ([gen_hedge_group_id],[gen_approved],[used_ass_profile_id],[fas_book_id],[perfect_hedge] ,[link_description]
									   ,[eff_test_profile_id] ,[link_effective_date],[link_type_value_id] ,[link_id],[gen_status],[process_id],create_user,create_ts)
							VALUES (@gen_hedge_group_id,'n',78,@new_book_id ,'n' ,@h_deal_id+'/'+@i_deal_id +'('+ @CurveName + ' '+CONVERT(VARCHAR(7),@term_start,120)+':'+CONVERT(VARCHAR(7),@term_end,120)+')'
								,ISNULL(@eff_test_profile_id,-1) ,@link_effect_date ,450 ,NULL ,'a' ,@process_id,@user_name,GETDATE())
							
							SET @new_link_id= SCOPE_IDENTITY()
							--SET @new_link_id= scope_identity() 
							SET @create_new_link='n'
						END
						
						INSERT INTO [gen_fas_link_detail] ([gen_link_id] ,[deal_number],[hedge_or_item] ,[percentage_included],effective_date)
						VALUES (@new_link_id,@source_deal_header_id_i,'i',@Proposed_per_i,@link_effect_date)
					
						UPDATE #hedge SET per = per - @Proposed_per_h WHERE source_deal_header_id=@source_deal_header_id_h
						UPDATE #hedge SET volume = @temp_per * idx_vol WHERE source_deal_header_id=@source_deal_header_id_h
						SET @link_per = @per_h - @temp_per

						SET @p_link_effect_date = @link_effect_date
						
						--PRINT '-------Item------------'
						--PRINT 'deal_id:'+CAST(@source_deal_header_id_i AS VARCHAR)
						--PRINT @Proposed_per_i
						--PRINT 'link_id:'+CAST(@new_link_id AS VARCHAR)
						--PRINT 'Deal Volume:'+CAST(@volume_i AS VARCHAR)
						--PRINT 'Volume match:'+CAST(@temp_match_volume AS VARCHAR)
						--PRINT '--------------------------'

						IF @temp_per < .01
						BEGIN
							--PRINT 'IF @temp_per<.01'
							UPDATE #hedge SET used=1 WHERE source_deal_header_id=@source_deal_header_id_h
							INSERT INTO #used_i_source_deal_header_id (h_source_deal_header_id,i_source_deal_header_id) VALUES (@source_deal_header_id_h,NULL)
						END
						
						SET @p_source_deal_header_id_h=@source_deal_header_id_h 
						SET @p_source_deal_header_id_i=@source_deal_header_id_i
						SET @deal_volume_p=@deal_volume
						
						INSERT INTO #deal_vs_link (link_id ,hedge_deal_id ,item_deal_id )
						SELECT @new_link_id,@source_deal_header_id_h,@source_deal_header_id_i						
					END --validation
				END --(@temp_vol>0
			END --not exists
		END --CAST(@volume_i as FLOAT)/@deal_volume>=.01
		FETCH NEXT FROM perfect_match INTO @source_deal_header_id_h ,@volume_h,@deal_volume,@per_h,@source_deal_header_id_i ,@volume_i,@per_i,@new_book_id,@eff_test_profile_id,@link_effect_date,@i_deal_id,@h_deal_id,@CurveName,@term_start,@term_end,@deal_volume_i
	END
	CLOSE perfect_match
	DEALLOCATE perfect_match

	IF EXISTS(SELECT 1	FROM #perfect_match1
			GROUP BY h_date,source_deal_header_id_h,i_date,source_deal_header_id_i,deal_volume, per_h,per_i,fas_book_id,eff_test_profile_id,no_indx,i_deal_id,h_deal_id
			HAVING COUNT(*)=no_indx )
	BEGIN 
		IF @new_link_id IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM [gen_fas_link_detail] WHERE gen_link_id=@new_link_id AND deal_number=@p_source_deal_header_id_h AND hedge_or_item='h')
			BEGIN
				--PRINT '--------Last Hedge------------------'
				--PRINT 'deal_id:'+CAST(@source_deal_header_id_h AS VARCHAR)
				--PRINT @temp_per
				--PRINT @per_h-@temp_per
				--PRINT 'link_id:'+CAST(@new_link_id AS VARCHAR)
				--PRINT 'Volume:'+CAST(@deal_volume_p AS VARCHAR)

				--PRINT '--------------------------'
				
				INSERT INTO [gen_fas_link_detail] ([gen_link_id],[deal_number],[hedge_or_item] ,[percentage_included],effective_date)
				VALUES (@new_link_id,@p_source_deal_header_id_h,'h',@link_per,@p_link_effect_date)
			END 
		END
	END 				

	IF EXISTS(SELECT 1 FROM #used_i_source_deal_header_id) 
		SET @exit_slice_h = 0
	ELSE 
		SET @exit_slice_h = 1
		
	DELETE #used_i_source_deal_header_id
	--DROP TABLE #perfect_match1

	SET @p_source_deal_header_id_h = 0
	SET @p_source_deal_header_id_i = 0
	SET @link_per = 0

	IF ISNULL(@slicing_first, 'h') = 'i'
	BEGIN
		--PRINT '***********Process_dicing*********************************'
		GOTO Process_dicing
	END

	Process_slicing_I:
	--PRINT '4a. matched by slicing (i.volume>=h.volume)'
	SET @p_source_deal_header_id_h = 0
	SET @p_source_deal_header_id_i = 0

	SET @temp_match_volume = 0
	SET @deal_volume_p = 0
	
	SET @new_link_id = NULL
	SET @create_new_link = 'y'
	SET @link_per = 0
	
	SELECT h.deal_date h_date,i.deal_date i_date,h.source_deal_header_id source_deal_header_id_h,h.volume volume_h,i.deal_volume,h.per per_h,i.source_deal_header_id source_deal_header_id_i
		, i.volume volume_i,i.per per_i,COALESCE(map.fas_book_id,i.fas_book_id,h.fas_book_id,-1) fas_book_id
		, COALESCE(map.eff_test_profile_id,i.eff_test_profile_id,h.eff_test_profile_id,-1)  eff_test_profile_id,h.no_indx,h.deal_id1 h_deal_id,i.deal_id1 i_deal_id
		, CASE WHEN h.link_effect_date>i.link_effect_date THEN h.link_effect_date ELSE i.link_effect_date END link_effect_date,h.CurveName,h.term_start,h.term_end,h.deal_volume deal_volume_h
	INTO #perfect_match1a
	FROM #hedge h 
	INNER JOIN #item i ON h.term_start = i.term_start	
		AND h.term_end = i.term_end 
		AND h.buy_sell = i.buy_sell
		AND h.used = 0 
		AND i.used = 0 
		AND h.no_indx = i.no_indx 
		AND h.no_terms = i.no_terms
		-- and h.fas_sub_id=CASE WHEN i.fas_sub_id IS NULL then h.fas_sub_id ELSE i.fas_sub_id END 
		AND h.initial_per_ava >= 0.01 
		AND i.initial_per_ava >= 0.01
		INNER JOIN (SELECT DISTINCT * FROM #map_n_curve) map on h.curve_id = map.h_curve_id AND i.curve_id=map.i_curve_id
			AND h.book_map_id=CASE WHEN map.h_book_map_id IS NULL THEN h.book_map_id ELSE map.h_book_map_id END  
			AND i.book_map_id=CASE WHEN map.i_book_map_id IS NULL THEN i.book_map_id ELSE map.i_book_map_id END
		INNER JOIN #no_dice_deal nd on i.source_deal_header_id=nd.source_deal_header_id
		--INNER JOIN #item_rel_type_index i_r ON i_r.curve_id=i.curve_id
		--INNER JOIN #hedge_rel_type_index h_r ON h_r.curve_id=h.curve_id	AND i_r.eff_test_profile_id = h_r.eff_test_profile_id	
		--WHERE ABS(h.volume)> 10 AND ABS(i.volume)>10

	DELETE #perfect_match1a FROM #perfect_match1a p 
	INNER JOIN exclude_deal_auto_matching a  ON p.source_deal_header_id_h=a.source_deal_header_id1
		AND p.source_deal_header_id_i=a.source_deal_header_id2
		AND a.exclude_flag='m'

	SET @sql = 'DECLARE perfect_match CURSOR GLOBAL FOR 
				SELECT source_deal_header_id_h,SUM(volume_h) volume_h,deal_volume, per_h,source_deal_header_id_i
						, SUM(volume_i) volume_i,per_i,fas_book_id,eff_test_profile_id,MAX(link_effect_date) link_effect_date,i_deal_id,h_deal_id
						, MAX(CurveName) CurveName,MIN(term_start) term_start,MAX(term_end) term_end,MAX(deal_volume_h) deal_volume_h
				FROM #perfect_match1a'
			+ CASE ISNULL(@deal_dt_option,'i') WHEN 'i' THEN ' WHERE h_date <= i_date' WHEN 'h' THEN ' WHERE h_date >= i_date' ELSE '' END +'
				GROUP BY h_date,source_deal_header_id_h,i_date,source_deal_header_id_i,deal_volume, per_h,per_i,fas_book_id,eff_test_profile_id,no_indx ,i_deal_id,h_deal_id
				HAVING COUNT(*) = no_indx 
				ORDER BY '+
			CASE WHEN ISNULL(@fifo_lifo,'f')= 'f'
				THEN 'i_date,source_deal_header_id_i,h_date,source_deal_header_id_h'
				ELSE 'i_date desc,source_deal_header_id_i desc,h_date desc,source_deal_header_id_h desc'
			END 
	EXEC(@sql)
	OPEN perfect_match
	FETCH NEXT FROM perfect_match INTO @source_deal_header_id_h,@volume_h,@deal_volume,@per_h,@source_deal_header_id_i,@volume_i,@per_i,@new_book_id,@eff_test_profile_id,@link_effect_date,@i_deal_id,@h_deal_id,@CurveName,@term_start,@term_end,@deal_volume_h
	WHILE @@FETCH_STATUS = 0
	BEGIN
	  IF CAST(@volume_h AS FLOAT)/NULLIF(@deal_volume, 0)>=.01
	  BEGIN
			IF NOT EXISTS(SELECT * FROM #used_i_source_deal_header_id WHERE h_source_deal_header_id=@source_deal_header_id_h OR i_source_deal_header_id=@source_deal_header_id_i)
			BEGIN
					-- at the first time of each hedge deal
				IF NOT EXISTS(SELECT 1 FROM gen_fas_link_detail where gen_link_id = @new_link_id AND deal_number=@p_source_deal_header_id_i AND hedge_or_item ='i')					
				BEGIN
				IF @p_source_deal_header_id_h<>@source_deal_header_id_h AND @p_source_deal_header_id_i <> @source_deal_header_id_i
				BEGIN
					IF @p_source_deal_header_id_i<>0
					BEGIN 
						--PRINT '--------Previous Item------------------'
						--PRINT 'deal_id:'+CAST(@source_deal_header_id_i AS VARCHAR)
						--PRINT @temp_per
						--PRINT @per_i-@temp_per
						--PRINT 'link_id:'+CAST(@new_link_id AS VARCHAR)
						--PRINT 'Volume:'+CAST(@deal_volume_p AS VARCHAR)
						--PRINT '--------------------------'
						INSERT INTO [gen_fas_link_detail] ([gen_link_id],[deal_number],[hedge_or_item] ,[percentage_included],effective_date)
						VALUES (@new_link_id,@p_source_deal_header_id_i,'i',@link_per,@p_link_effect_date)
					END 
					
					SET @temp_vol=@volume_i
					SET @temp_per=@per_i
					SET @create_new_link='y'
				END
				END
				IF @temp_vol>0
				BEGIN
					------------validate over allocation
					SELECT @recent_per_used_h=SUM(CASE WHEN used_per.source_deal_header_id = @source_deal_header_id_h THEN percentage_use ELSE 0 END) ,
							@recent_per_used_i=SUM(CASE WHEN used_per.source_deal_header_id = @source_deal_header_id_i THEN percentage_use ELSE 0 END) 
					FROM (
						SELECT 	gfld.deal_number source_deal_header_id, SUM(gfld.percentage_included) AS  percentage_use,MAX('o') src
						FROM gen_fas_link_detail gfld 	
						INNER JOIN	gen_fas_link_header gflh ON gflh.gen_link_id = gfld.gen_link_id
							 AND gflh.gen_status = 'a' and gfld.deal_number in(@source_deal_header_id_i,@source_deal_header_id_h) 
						GROUP BY gfld.deal_number
						UNION ALL
						SELECT source_deal_header_id,SUM(CASE WHEN CONVERT(VARCHAR(10),@as_of_date_to,120) >=ISNULL(fas_link_header.link_end_date,'9999-01-01') THEN 0 ELSE percentage_included END) percentage_included,MAX('f') FROM fas_link_detail INNER JOIN fas_link_header
						ON  fas_link_detail.link_id=fas_link_header.link_id and source_deal_header_id in(@source_deal_header_id_i,@source_deal_header_id_h) and link_type_value_id =450 GROUP BY source_deal_header_id
						UNION ALL
						SELECT a.source_deal_header_id ,SUM(a.[per_dedesignation]) [per_dedesignation],MAX('l') src FROM 
						(
						SELECT DISTINCT process_id ,source_deal_header_id ,[per_dedesignation] FROM [dbo].[dedesignated_link_deal] where source_deal_header_id in (@source_deal_header_id_i,@source_deal_header_id_h)
						) a GROUP BY a.source_deal_header_id
					) used_per  --GROUP BY used_per.source_deal_header_id

					IF @volume_h>@temp_vol
					BEGIN
						SET @temp_match_volume=@temp_vol
						--SET @temp_match_per=(CAST(@temp_match_volume as FLOAT)/@volume_h)
						SET @temp_match_per=(CAST(@temp_match_volume AS FLOAT)/NULLIF(@deal_volume_h, 0))
					END
					ELSE
					BEGIN
						SET @temp_match_volume=@volume_h
						SET @temp_match_per=@per_h
					END
				
					IF @recent_per_used_i+(CAST(@temp_match_volume AS FLOAT)/NULLIF(@deal_volume, 0))>1.01001 OR @recent_per_used_h+@temp_match_per>1.01001
					BEGIN
						IF @recent_per_used_h+@temp_match_per>1.01001
							INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, [source], [type], [description], nextsteps) 
							VALUES(@process_id,'Error', 'Auto Matching', 'Automatic Matching',
							'Database Error','Critical Error Found [a Over Allocation foud in slicing (h.volume<=i.volume) for Hedge Source_Deal_Header_ID:'+ CAST(@source_deal_header_id_h AS VARCHAR) +'; Already_Used_per: '+CAST(@recent_per_used_h AS VARCHAR)+'; new_proposed_per:'+CAST(@temp_match_per AS VARCHAR)+']' , 'Please contact support.')
						IF @recent_per_used_i+(CAST(@temp_match_volume AS FLOAT)/NULLIF(@deal_volume, 0))>1.01001
							INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, [source], [type], [description], nextsteps) 
							VALUES(@process_id,'Error', 'Auto Matching', 'Automatic Matching',
							'Database Error','Critical Error Found [a Over Allocation foud in slicing (h.volume<=i.volume) for Item Source_Deal_Header_ID:'+ CAST(@source_deal_header_id_h AS VARCHAR) +'; Already_Used_per: '+CAST(@recent_per_used_i AS VARCHAR)+'; new_proposed_per:'+CAST((CAST(@temp_match_volume AS FLOAT)/NULLIF(@deal_volume, 0)) AS VARCHAR)+']' , 'Please contact support.')
					END ----------------END validation
					ELSE
					BEGIN
						IF @recent_per_used_h + @temp_match_per > 1
							SET @Proposed_per_h = 1 - @recent_per_used_h ---round(@recent_per_used_h,2)
						ELSE
							SET @Proposed_per_h = @temp_match_per

						IF @recent_per_used_i + (CAST(@temp_match_volume AS FLOAT) / NULLIF(@deal_volume, 0)) > 1
							SET @Proposed_per_i = 1 - @recent_per_used_i --round(CAST(@volume_h as FLOAT)/@deal_volume,2)
						ELSE
							SET @Proposed_per_i = CAST(@temp_match_volume AS FLOAT) / NULLIF(@deal_volume, 0)

						INSERT INTO #used_i_source_deal_header_id (h_source_deal_header_id,i_source_deal_header_id) 
						SELECT  @source_deal_header_id_h,CASE WHEN ISNULL(@slice_option,'m') = 'h' THEN @source_deal_header_id_i ELSE NULL END

						IF @volume_h <= @temp_vol
						BEGIN
							UPDATE #hedge SET used = 1 WHERE source_deal_header_id=@source_deal_header_id_h
						END
						ELSE
						BEGIN
							UPDATE #hedge SET per = per - @Proposed_per_h WHERE source_deal_header_id = @source_deal_header_id_h
							UPDATE #hedge SET volume = per * idx_vol WHERE source_deal_header_id = @source_deal_header_id_h
						END

						SET @temp_vol = @temp_vol - @temp_match_volume
						SET @temp_per = @temp_per - @Proposed_per_i
						SET @deal_volume_p = @deal_volume
		
						IF @create_new_link='y'
						BEGIN
							INSERT INTO gen_hedge_group	(gen_hedge_group_name, link_type_value_id, hedge_effective_date, eff_test_profile_id,perfect_hedge, 
											reprice_items_id,tenor_from, tenor_to, reprice_date,tran_type) 
							VALUES(@h_deal_id+'/'+@i_deal_id +'('+ @CurveName + ' '+CONVERT(VARCHAR(7),@term_start,120)+':'+CONVERT(VARCHAR(7),@term_end,120)+')'
									, 450, @link_effect_date,ISNULL(@eff_test_profile_id,-1),'n', NULL, NULL, NULL,NULL,'m')
							
							SET @gen_hedge_group_id=SCOPE_IDENTITY()

							INSERT INTO [gen_fas_link_header] ([gen_hedge_group_id],[gen_approved],[used_ass_profile_id],[fas_book_id],[perfect_hedge] ,[link_description]
										   ,[eff_test_profile_id] ,[link_effective_date],[link_type_value_id] ,[link_id],[gen_status],[process_id],create_user,create_ts)
							VALUES (@gen_hedge_group_id,'n',78,@new_book_id ,'n' ,@h_deal_id+'/'+@i_deal_id +'('+ @CurveName + ' '+CONVERT(VARCHAR(7),@term_start,120)+':'+CONVERT(VARCHAR(7),@term_end,120)+')'
								,ISNULL(@eff_test_profile_id,-1) ,@link_effect_date ,450 ,NULL ,'a' ,@process_id,@user_name,GETDATE())
							
							SET @new_link_id= SCOPE_IDENTITY()
								--SET @new_link_id= scope_identity() 
								
							SET @create_new_link = 'n'
						END
						INSERT INTO [gen_fas_link_detail] ([gen_link_id] ,[deal_number],[hedge_or_item] ,[percentage_included],effective_date)
						VALUES (@new_link_id,@source_deal_header_id_h,'h',@Proposed_per_h,@link_effect_date)
							
						SET @p_link_effect_date=@link_effect_date

						--PRINT '-------hedge------------'
						--PRINT 'deal_id:'+CAST(@source_deal_header_id_h AS VARCHAR)
						--PRINT @Proposed_per_h
						--PRINT 'link_id:'+CAST(@new_link_id AS VARCHAR)
						--PRINT 'volume:'+CAST(@temp_match_volume AS VARCHAR)
						--PRINT '--------------------------'

						UPDATE #item SET per = per - @Proposed_per_i WHERE source_deal_header_id = @source_deal_header_id_i
						UPDATE #item SET volume = @temp_per * idx_vol WHERE source_deal_header_id = @source_deal_header_id_i
						SET @link_per = @per_i - @temp_per
						IF @temp_per < .01
						BEGIN
							UPDATE #item SET used = 1 WHERE source_deal_header_id = @source_deal_header_id_i
							INSERT INTO #used_i_source_deal_header_id (h_source_deal_header_id,i_source_deal_header_id) VALUES (NULL,@source_deal_header_id_i)
						END
						
						SET @p_source_deal_header_id_h = @source_deal_header_id_h 
						SET @p_source_deal_header_id_i = @source_deal_header_id_i
						
						INSERT INTO #deal_vs_link (link_id ,hedge_deal_id ,item_deal_id )
						SELECT @new_link_id,@source_deal_header_id_h,@source_deal_header_id_i						
					END --validation
				END --(@temp_vol-@volume_h)>=0
			END	--not exists
		END --CAST(@volume_h as FLOAT)/@deal_volume>=.01
		FETCH NEXT FROM perfect_match INTO @source_deal_header_id_h ,@volume_h,@deal_volume,@per_h,@source_deal_header_id_i ,@volume_i,@per_i,@new_book_id,@eff_test_profile_id,@link_effect_date,@i_deal_id,@h_deal_id,@CurveName,@term_start,@term_end,@deal_volume_h
	END
	CLOSE perfect_match
	DEALLOCATE perfect_match

	IF EXISTS (SELECT 1	FROM #perfect_match1a
			GROUP BY h_date,source_deal_header_id_h,i_date,source_deal_header_id_i,deal_volume, per_h,per_i,fas_book_id,eff_test_profile_id,no_indx,i_deal_id,h_deal_id
			HAVING COUNT(*)=no_indx )
	BEGIN 
		IF @new_link_id IS NOT NULL
		BEGIN
			IF not exists(select 1 from [gen_fas_link_detail] where gen_link_id=@new_link_id and deal_number=@p_source_deal_header_id_i and hedge_or_item='i')
			BEGIN
				--PRINT '--------Last Item------------------'
				--PRINT 'deal_id:'+CAST(@source_deal_header_id_i AS VARCHAR)
				--PRINT @temp_per
				--PRINT @per_i-@temp_per
				--PRINT 'link_id:'+CAST(@new_link_id AS VARCHAR)
				--PRINT 'Volume:'+CAST(@deal_volume_p AS VARCHAR)

				--PRINT '--------------------------'
				INSERT INTO [gen_fas_link_detail] ([gen_link_id],[deal_number],[hedge_or_item] ,[percentage_included],effective_date)
				VALUES (@new_link_id,@p_source_deal_header_id_i,'i',@link_per,@p_link_effect_date)
			END 
		END
	END 

	IF EXISTS(SELECT 1 FROM #used_i_source_deal_header_id ) 
		SET @exit_slice_i =0
	ELSE 
		SET @exit_slice_i =1

	DELETE #used_i_source_deal_header_id
	--DROP TABLE #perfect_match1a

	SET @p_source_deal_header_id_h = 0
	SET @p_source_deal_header_id_i = 0
	SET @link_per = 0
	SET @temp_match_volume = 0
	IF ISNULL(@slicing_first, 'h') = 'i'
	BEGIN
		--PRINT '***********Process_slicing_H*********************************'
		GOTO Process_slicing_H
	END

	SET @new_link_id = NULL
	DELETE #used_i_source_deal_header_id
	SET @create_new_link = 'y'
	SET @p_source_deal_header_id_h = 0
	SET @p_source_deal_header_id_i = 0
	SET @link_per=0
	--PRINT '<<<<<<<<<<<<<<END LOOP :'+CAST(@loop AS VARCHAR)
	--PRINT '@exit_slice_h:'+CAST(@exit_slice_h AS VARCHAR) +'   @exit_slice_i:'+ CAST(@exit_slice_i AS VARCHAR) +'   @exit_perfect:'+  CAST(@exit_perfect AS VARCHAR)
	
	UPDATE #item_int  
	SET used=1 
	FROM #item_int ii 
	INNER JOIN #item i ON i.source_deal_header_id = ii.source_deal_header_id
		AND i.used=1 
		
	UPDATE #item_int  
	SET operation_status = 'n' 
	FROM #item_int ii 
	INNER JOIN #item i ON i.source_deal_header_id = ii.source_deal_header_id
		AND  ISNULL(i.operation_status,'m' ) = 'n'
		
	UPDATE #hedge_int  
	SET used = 1 
	from #hedge_int ii 
	INNER JOIN #hedge i ON i.source_deal_header_id = ii.source_deal_header_id
		AND i.used=1 
		
	SET @loop = @loop + 1

	IF 	@exit_slice_h = 0 OR @exit_slice_i = 0 OR @exit_perfect = 0
	BEGIN
		TRUNCATE TABLE #used_percentage
		DROP TABLE #perfect_match1
		DROP TABLE #perfect_match1a
		DROP TABLE #perfect_match
		DROP TABLE #hedge
		DROP TABLE #item
	
		GOTO loop_match_data_exist
	END
	
	--------------------------------------------------------------------------------------------------------------------------
	--Dicing
	Process_dicing:

	SET @loop=1

	TRUNCATE TABLE #used_percentage

	IF OBJECT_ID(@link_deal_term_used_per) IS NOT NULL
		EXEC('DROP TABLE '+@link_deal_term_used_per)
	
	EXEC dbo.spa_get_link_deal_term_used_per @as_of_date =@as_of_date_to,@link_ids=NULL,@header_deal_id =NULL,@term_start=NULL
		,@no_include_link_id =NULL,@output_type =1,@include_gen_tranactions = 'b',@process_table=@link_deal_term_used_per

	SET @sql = 'INSERT INTO #used_percentage (source_deal_header_id ,used_percentage )	
				SELECT ud.source_deal_header_id, SUM(ISNULL(percentage_used ,0)) percentage_used from ' + @link_deal_term_used_per + ' ud
				 INNER JOIN #hedge h ON ud.source_deal_header_id=h.source_deal_header_id
				 GROUP BY ud.source_deal_header_id '
	EXEC spa_print @sql			
	EXEC(@sql)			

	CREATE TABLE #used_percentage_item (source_deal_header_id INT ,term_start DATETIME,used_percentage FLOAT)

	SET @sql = 'INSERT INTO #used_percentage_item (source_deal_header_id ,term_start,used_percentage )	
				SELECT ud.source_deal_header_id, ud.term_start,SUM(ISNULL(percentage_used ,0)) percentage_used from ' + @link_deal_term_used_per + ' ud
				 INNER JOIN #item h ON ud.source_deal_header_id=h.source_deal_header_id
				 GROUP BY ud.source_deal_header_id,ud.term_start
			'
	EXEC spa_print @sql			
	EXEC(@sql)			

	Process_dicing_loop:

	--PRINT 'loop:'+CAST(@loop as VARCHAR)	
	TRUNCATE TABLE #used_i_source_deal_header_id

	SET @p_source_deal_header_id_h = 0
	SET @p_source_deal_header_id_i = 0

	SET @temp_match_volume = 0
	SET @deal_volume_p = 0

	SET @new_link_id = NULL
	SET @create_new_link = 'y'
	SET @link_per = 0
	IF ISNULL(@perform_dicing, 'y') = 'y'
	BEGIN
		SET @jump_for_exit = 'y'
		IF OBJECT_ID('tempdb..#perfect_match2') IS NOT NULL
			DROP TABLE #perfect_match2
		
		IF OBJECT_ID('tempdb..#Deal_Available') IS NOT NULL
			DROP TABLE #Deal_Available	
		
		IF OBJECT_ID('tempdb..#deal_vs_link') IS NOT NULL
			DROP TABLE #deal_vs_link	

		CREATE TABLE #Deal_Available(source_deal_header_id INT,term_start date,per_avail FLOAT,h_i VARCHAR(1) COLLATE DATABASE_DEFAULT)
		DECLARE @total_vol_avail_h FLOAT,@total_vol_avail_i FLOAT,@matched_vol FLOAT,@delta_per_i FLOAT

		--PRINT 'Start matching by dicing (i.term_start<=h.term_start and i.term_end>=h.term_end)'

		SELECT h.deal_date h_date,i.deal_date i_date,h.source_deal_header_id source_deal_header_id_h,h.deal_volume volume_h
			, i.source_deal_header_id source_deal_header_id_i,i.deal_volume volume_i,h.no_indx ,COALESCE(i.fas_book_id,h.fas_book_id,-1) fas_book_id
			, COALESCE(map.eff_test_profile_id,i.eff_test_profile_id,h.eff_test_profile_id,-1)  eff_test_profile_id
			, CASE WHEN h.link_effect_date>i.link_effect_date THEN h.link_effect_date ELSE i.link_effect_date END link_effect_date
			, h.deal_id1 h_deal_id,i.deal_id1 i_deal_id,h.CurveName,i.term_start,i.term_end
			INTO #perfect_match2
		FROM #hedge h 
		INNER JOIN #item i ON h.buy_sell= i.buy_sell  AND h.used <> 1 AND i.used <> 1 --and h.per=1 and i.per=1 AND h.no_indx=i.no_indx 
		INNER JOIN (SELECT DISTINCT * from #map_n_curve) map on h.curve_id=map.h_curve_id and i.curve_id=map.i_curve_id
			AND h.book_map_id=CASE WHEN map.h_book_map_id IS NULL then h.book_map_id ELSE map.h_book_map_id END  
			AND i.book_map_id=CASE WHEN map.i_book_map_id IS NULL then i.book_map_id ELSE map.i_book_map_id END
		WHERE h.term_start >= i.term_start AND h.term_end <= i.term_end AND NOT (h.term_start=i.term_start AND h.term_end = i.term_end)

		SET @sql = 'DECLARE perfect_match CURSOR GLOBAL FOR 
					SELECT source_deal_header_id_h,SUM(volume_h) volume_h,source_deal_header_id_i,SUM(volume_i) volume_i 
						, fas_book_id,eff_test_profile_id,MAX(link_effect_date) link_effect_date,h_deal_id,i_deal_id	
						, MAX(CurveName) CurveName,MIN(term_start) term_start,MAX(term_end) term_end FROM #perfect_match2'
					+ case ISNULL(@deal_dt_option,'i') WHEN 'i' THEN ' WHERE h_date<=i_date'  WHEN 'h' THEN ' WHERE h_date>=i_date' ELSE '' END +'
					GROUP BY h_date,source_deal_header_id_h,i_date,source_deal_header_id_i ,no_indx,fas_book_id,eff_test_profile_id,h_deal_id,i_deal_id
					HAVING COUNT(*)=no_indx
					ORDER BY '
					+ CASE WHEN ISNULL(@fifo_lifo,'f')= 'f'
						THEN 'h_date,source_deal_header_id_h,i_date,source_deal_header_id_i'
						ELSE 'h_date desc,source_deal_header_id_h desc,i_date desc,source_deal_header_id_i desc'
					END
		--PRINT @sql
		EXEC(@sql)
	
		OPEN perfect_match
		FETCH NEXT FROM perfect_match INTO @source_deal_header_id_h ,@volume_h,@source_deal_header_id_i ,@volume_i,@new_book_id,@eff_test_profile_id,@link_effect_date,@h_deal_id,@i_deal_id,@CurveName,@term_start,@term_end
		WHILE @@FETCH_STATUS = 0
		BEGIN
			TRUNCATE TABLE #deal_Available	
			--IF not exists(select 1 from #used_i_source_deal_header_id  where h_source_deal_header_id=@source_deal_header_id_h or i_source_deal_header_id=@source_deal_header_id_i)
			--BEGIN		
				INSERT INTO #deal_Available (source_deal_header_id,per_avail,h_i )	
				SELECT source_deal_header_id, 1-SUM(ISNULL(used_percentage ,0)) percentage_avail,'h' from #used_percentage where source_deal_header_id=@source_deal_header_id_h
				GROUP BY source_deal_header_id

				INSERT INTO #deal_Available (source_deal_header_id,term_start,per_avail,h_i )	
				SELECT source_deal_header_id,term_start, 1-SUM(ISNULL(used_percentage ,0)) percentage_avail,'i' from #used_percentage_item where source_deal_header_id=@source_deal_header_id_i
				GROUP BY source_deal_header_id,term_start	

				IF OBJECT_ID('tempdb..#dicing_term_match') IS NOT NULL
					DROP TABLE #dicing_term_match

				SELECT h.source_deal_header_id deal_header_id_h,i.source_deal_header_id deal_header_id_i,h.term_start,ISNULL(da_i.per_avail,1) per_avail
					, ABS(h.deal_volume)*ISNULL(da_h.per_avail,1) available_vol_h,ABS(i.deal_volume)*ISNULL(da_i.per_avail,1) available_vol_i
				INTO #dicing_term_match
				FROM source_deal_detail h 
				INNER JOIN source_deal_detail i ON h.term_start= i.term_start and i.leg=1	AND h.Leg=1 AND h.source_deal_header_id = @source_deal_header_id_h AND i.source_deal_header_id =@source_deal_header_id_i
				LEFT JOIN #deal_Available da_h ON h.source_deal_header_id=da_h.source_deal_header_id	-- and h.term_start=da_h.term_start
				LEFT JOIN #deal_Available da_i ON i.source_deal_header_id=da_i.source_deal_header_id and i.term_start=da_i.term_start	
				--LEFT JOIN volume_unit_conversion conv on conv.from_source_uom_id=h.deal_volume_uom_id
				--	AND conv.to_source_uom_id=@item_uom_id	
				WHERE ISNULL(da_h.per_avail,1)>.0001 AND ISNULL(da_i.per_avail,1) > .0001
			 
				IF @@ROWCOUNT>0
				BEGIN 
					SET @jump_for_exit='n'
					SELECT @total_vol_avail_h=SUM(available_vol_h),@total_vol_avail_i=SUM(available_vol_i) from #dicing_term_match
				 
					--PRINT '@total_vol_avail_h:' +CAST(@total_vol_avail_h as VARCHAR)+'@total_vol_avail_i:' +CAST(@total_vol_avail_i as VARCHAR)
					IF ISNULL(@total_vol_avail_h,0)<>0
					BEGIN
						---------------start inserting gen link record	
						INSERT INTO gen_hedge_group	(gen_hedge_group_name, link_type_value_id, hedge_effective_date, eff_test_profile_id,perfect_hedge, reprice_items_id,tenor_from, tenor_to, reprice_date,tran_type) 
						VALUES(@h_deal_id+'/'+@i_deal_id +'('+ @CurveName + ' '+CONVERT(VARCHAR(7),@term_start,120)+':'+CONVERT(VARCHAR(7),@term_end,120)+')'
								, 450, @link_effect_date
								, ISNULL(@eff_test_profile_id,-1),'n',NULL, NULL, NULL,NULL,'m')
						SET @gen_hedge_group_id=SCOPE_IDENTITY()

						INSERT INTO [gen_fas_link_header] ([gen_hedge_group_id],[gen_approved],[used_ass_profile_id],[fas_book_id],[perfect_hedge] ,[link_description]
								   ,[eff_test_profile_id] ,[link_effective_date],[link_type_value_id] ,[link_id],[gen_status],[process_id],create_user,create_ts)
						 VALUES (@gen_hedge_group_id,'n',78,ISNULL(@new_book_id,-1) ,'n' ,@h_deal_id+'/'+@i_deal_id +'('+ @CurveName + ' '+CONVERT(VARCHAR(7),@term_start,120)+':'+CONVERT(VARCHAR(7),@term_end,120)+')'
							   , ISNULL(@eff_test_profile_id,-1) ,@link_effect_date ,450 ,NULL ,'a' ,@process_id,@user_name,GETDATE())

						SET @new_link_id = SCOPE_IDENTITY()
					
						IF 	@total_vol_avail_i >= @total_vol_avail_h
						BEGIN
							SET @matched_vol = @total_vol_avail_h
							SET @delta_per_i = @matched_vol / NULLIF(@total_vol_avail_i, 0)
						END
						ELSE
						BEGIN
							SET @matched_vol  =@total_vol_avail_i
							SET @delta_per_i = 1 --@matched_vol/@total_vol_avail_i
						END
					
						INSERT INTO [gen_fas_link_detail] ([gen_link_id],[deal_number],[hedge_or_item] ,[percentage_included],effective_date)
						OUTPUT inserted.deal_number,inserted.percentage_included into #used_percentage(source_deal_header_id, used_percentage)
						VALUES (@new_link_id,@source_deal_header_id_h,'h',@matched_vol/NULLIF(@volume_h, 0),@link_effect_date)
				
						INSERT INTO [gen_fas_link_detail] ([gen_link_id] ,[deal_number],[hedge_or_item] ,[percentage_included],effective_date)
						VALUES (@new_link_id,@source_deal_header_id_i,'i',1,@link_effect_date) --always  [percentage_included]=1 as handled by dicing table 
 
						IF @matched_vol=@total_vol_avail_i
						BEGIN
							UPDATE #item SET used = 1 WHERE source_deal_header_id = @source_deal_header_id_i
							INSERT INTO #used_i_source_deal_header_id(i_source_deal_header_id) VALUES (@source_deal_header_id_i)
						END
						IF @matched_vol=@total_vol_avail_h
						BEGIN
							UPDATE #hedge SET used=1 WHERE source_deal_header_id=@source_deal_header_id_h
							INSERT INTO #used_i_source_deal_header_id(h_source_deal_header_id) VALUES (@source_deal_header_id_h)
						END
					
						---------------END inserting gen link record	
						--PRINT 'dicing insert:'+CAST(@source_deal_header_id_i as VARCHAR)
					
						INSERT INTO dbo.gen_fas_link_detail_dicing(link_id,source_deal_header_id,term_start,percentage_used,effective_date,available,header_used,total_match_vol,create_user,create_ts)
						OUTPUT inserted.source_deal_header_id,inserted.term_start,inserted.percentage_used into #used_percentage_item(source_deal_header_id,term_start, used_percentage)
						SELECT @new_link_id,sdd.source_deal_header_id,sdd.term_start, ISNULL(d.per_avail,1)*@delta_per_i per_used,@link_effect_date,ISNULL(d.per_avail,1),@delta_per_i,@matched_vol,@user_name,GETDATE()
						FROM source_deal_detail sdd 
						INNER JOIN #dicing_term_match d on sdd.source_deal_header_id=d.deal_header_id_i and sdd.term_start=d.term_start and sdd.leg=1
					END --ISNULL(@total_vol_avail_h,0)<>0
				END--@@rowcount>0
	--		END
			FETCH NEXT FROM perfect_match INTO @source_deal_header_id_h ,@volume_h,@source_deal_header_id_i ,@volume_i,@new_book_id,@eff_test_profile_id,@link_effect_date,@h_deal_id,@i_deal_id,@CurveName,@term_start,@term_end
		END
		CLOSE perfect_match
		DEALLOCATE perfect_match
	
		IF  @jump_for_exit='y'
			GOTO exit_matching
		ELSE
			SET @jump_for_exit='y'
	
		SET @loop = @loop + 1
		
		goto Process_dicing_loop ---reprocess dicing
	END

	exit_matching:

	IF ISNULL(@limit_chcking,0)=1
	BEGIN
		IF EXISTS(SELECT 1 FROM gen_fas_link_header WHERE process_id=@process_id)
			EXEC dbo.spa_auto_matching_limit_validation @as_of_date_to ,@user_name,@process_id,'n',@sub_id,@limit_bucketing

	END
	--PRINT 'finish matching '

	IF ISNULL(@call_for_report,'n') = 'l'
		RETURN

	UPDATE #item SET buy_sell = org_buy_sell
	UPDATE #item SET curve_id = org_curve_id

	SET @sql = 'SELECT sdd.source_deal_header_id,sdd.curve_id,MAX(deal_volume_uom_id) deal_volume_uom_id ,MIN(sdd.term_start) term_start
					, MAX(sdd.term_end) term_end ,SUM(deal_volume) deal_volume,	MAX(buy_sell_flag) buy_sell into  #tmp_deal_detail
				FROM source_deal_detail sdd	INNER JOIN	#tmp_sdd1 sdd1 on sdd.source_deal_header_id=sdd1.source_deal_header_id and sdd.leg=1
				INNER JOIN source_deal_header dh on sdd.source_deal_header_id=dh.source_deal_header_id
				INNER JOIN #tmp_not_MA_deals ma_d on dh.source_deal_header_id=ma_d.source_deal_header_id
				INNER JOIN source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
					dh.source_system_book_id2 = sbmp.source_system_book_id2 AND dh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
					dh.source_system_book_id4 = sbmp.source_system_book_id4 '+ CASE WHEN ISNULL(@externalization, 'n') = 'y' THEN ' AND ISNULL(dh.fas_deal_type_value_id,sbmp.fas_deal_type_value_id)= 400 '	ELSE '' END + ' 
				INNER JOIN #books b ON b.fas_book_id = sbmp.fas_book_id
				'+ CASE WHEN ISNULL(@externalization, 'n') = 'y' OR  ISNULL(@only_include_external_der, 'n') = 'y' THEN 
					' INNER JOIN source_counterparty sc ON dh.counterparty_id=sc.source_counterparty_id AND sc.int_ext_flag=''e'''
					ELSE '' END + '	
				GROUP BY sdd.source_deal_header_id,sdd.curve_id;
			
			INSERT INTO  ' + @ProcessTableName + ' (
				Match,[Hedged Item Product],[Tenor],[Deal Date],[Type],[Deal ID],[Deal REF ID],[Volume % Avail],[Volume Avail],
				[Volume matched] ,[% Matched] ,[UOM],[used_ass_profile_id],[fas_book_id],[perfect_hedge],[link_description],[eff_test_profile_id],
				[link_effective_date],[link_type_value_id] ,[gen_status],deal_volume,buy_sell,curve_id,process_id ,term_start ,term_end	,source_uom_id, [Counterparty] 
			)
			SELECT 	flh.gen_link_id,spcd.curve_name,convert(VARCHAR(7), sdd.term_start,120) +'' : '' +convert(VARCHAR(7), sdd.term_end,120) Tenor,
				sdh.deal_date,fld.[hedge_or_item] ,tmp.source_deal_header_id ,
				CASE WHEN  off_d.source_deal_id IS NOT NULL then ''Offset_deal'' ELSE sdh.deal_id END deal_id,ISNULL(tmp.initial_per_ava,1) initial_per_ava,
				CASE WHEN tmp.buy_sell=''s'' then -1 ELSE 1 END * ISNULL(tmp.initial_vol_ava,sdd.deal_volume) [Volume Avail] ,
				CASE WHEN tmp.buy_sell=''s'' then -1 ELSE 1 END * ISNULL(dic.total_match_vol,fld.[percentage_included]*ISNULL(tmp.deal_volume,sdd.deal_volume)) [Volume matched] ,
				fld.[percentage_included],su.uom_name,flh.used_ass_profile_id,flh.fas_book_id,	flh.perfect_hedge,	flh.link_description,
				flh.eff_test_profile_id,ISNULL(tmp.link_effect_date,sdh.deal_date) link_effect_date, ---flh.link_effective_date,
				flh.link_type_value_id,	flh.gen_status,	ISNULL( tmp.deal_volume,sdd.deal_volume) deal_volume,
				ISNULL(tmp.buy_sell,sdd.buy_sell) buy_sell ,tmp.curve_id,	flh.process_id,ISNULL(tmp.term_start,sdd.term_start) term_start
				,ISNULL(tmp.term_end,sdd.term_end) term_end	,su.source_uom_id	,sc.Counterparty_id
			FROM [gen_fas_link_header] flh INNER JOIN [gen_fas_link_detail] fld on flh.[gen_link_id]=fld.[gen_link_id] and flh.process_id= ''' + @process_id + '''
			INNER JOIN source_deal_header sdh on sdh.source_deal_header_id=fld.[deal_number] 
			INNER JOIN #tmp_not_MA_deals ma_d on sdh.source_deal_header_id=ma_d.source_deal_header_id
			INNER JOIN #tmp_deal_detail sdd	 on sdd.source_deal_header_id=sdh.source_deal_header_id
			INNER JOIN source_price_curve_def spcd on spcd.source_curve_def_id=	sdd.curve_id
			LEFT JOIN (	SELECT DISTINCT link_id,source_deal_header_id,CAST(total_match_vol AS NUMERIC(28, 4)) total_match_vol FROM [gen_fas_link_detail_dicing]) dic 
				ON dic.link_id = fld.[gen_link_id] and dic.source_deal_header_id = fld.[deal_number]
			LEFT JOIN  #offset_deal off_d ON off_d.source_deal_id=sdh.source_deal_header_id
			LEFT JOIN
			(
				SELECT source_deal_header_id,deal_date,MAX(curve_id) curve_id,MIN(term_start) term_start,MAX(term_end) term_end,MAX(deal_volume) deal_volume,MAX(buy_sell) buy_sell,
					MAX(per) per,SUM(volume) remain_vol,MAX(CASE WHEN used=1 then 1 ELSE 0 END) used,MAX(fas_book_id) fas_book_id
					,MAX(eff_test_profile_id) eff_test_profile_id,SUM(initial_vol_ava) initial_vol_ava,MAX(initial_per_ava) initial_per_ava,MAX(link_effect_date) link_effect_date
				FROM
				(
					SELECT curve_id,source_deal_header_id,deal_date,term_start,term_end,deal_volume,buy_sell,
						per,volume,used,fas_book_id,eff_test_profile_id ,idx_vol,no_indx,no_terms,initial_vol_ava,initial_per_ava,link_effect_date from #hedge_int
					UNION all
					SELECT curve_id,source_deal_header_id,deal_date,term_start,term_end,deal_volume,org_buy_sell,
						per,volume,used,NULL fas_book_id,NULL eff_test_profile_id,idx_vol,no_indx,no_terms,initial_vol_ava,initial_per_ava,link_effect_date from #item_int
				) tmp1 
				--where source_deal_header_id = 321244 --and 
				GROUP BY source_deal_header_id,deal_date
			) tmp
			ON tmp.source_deal_header_id=sdd.source_deal_header_id  and sdd.curve_id=tmp.curve_id
			--where tmp.source_deal_header_id IS NULL
			LEFT JOIN source_uom su on sdd.deal_volume_uom_id=su.source_uom_id
			LEFT JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id 
			ORDER BY flh.gen_link_id,fld.[hedge_or_item] 	
		'

	EXEC(@sql)

	IF OBJECT_ID(@link_deal_term_used_per) IS NOT NULL
		EXEC('DROP TABLE '+@link_deal_term_used_per)
	
	EXEC dbo.spa_get_link_deal_term_used_per @as_of_date = @as_of_date_to,@link_ids = NULL,@header_deal_id = NULL,@term_start = NULL
		,@no_include_link_id = NULL,@output_type =1	,@include_gen_tranactions  = 'b',@process_table = @link_deal_term_used_per

	TRUNCATE TABLE #used_percentage

	SET @sql = 'INSERT INTO #used_percentage (source_deal_header_id ,used_percentage )	
				SELECT source_deal_header_id ,MAX(percentage_used) percentage_used 
				FROM (
					SELECT source_deal_header_id, term_start, SUM(ISNULL(percentage_used ,0)) percentage_used 
					FROM ' + @link_deal_term_used_per
				 + ' GROUP BY source_deal_header_id, term_start
				 ) a GROUP BY source_deal_header_id '

	EXEC spa_print @sql
	EXEC(@sql)

	SET @sql = 'SELECT source_deal_header_id,deal_date,MAX(curve_id) curve_id,MIN(term_start) term_start,MAX(term_end) term_end,MAX(deal_volume) deal_volume,MAX(buy_sell) buy_sell,
					MAX(per) per,SUM(volume) remain_vol,MAX(CASE WHEN used=1 then 1 ELSE 0 END) used,MAX(fas_book_id) fas_book_id
					, MAX(eff_test_profile_id) eff_test_profile_id,SUM(initial_vol_ava) initial_vol_ava,MAX(initial_per_ava) initial_per_ava
					, MAX(h_or_i) h_or_i,MAX(link_effect_date) link_effect_date into  #tmp_deal_detail1
				FROM (
				SELECT curve_id,source_deal_header_id,deal_date,term_start,term_end,deal_volume,buy_sell,
					per,volume,used,fas_book_id,eff_test_profile_id ,idx_vol,no_indx,no_terms,initial_vol_ava
					,''h'' h_or_i,initial_per_ava,link_effect_date from #hedge_int where used=0
				UNION all
				SELECT curve_id,source_deal_header_id,deal_date,term_start,term_end,deal_volume,org_buy_sell,
					per,volume,used,NULL fas_book_id,NULL eff_test_profile_id,idx_vol,no_indx,no_terms,initial_vol_ava
					,''i'' h_or_i,initial_per_ava,link_effect_date from #item_int  where used=0 or ISNULL(operation_status,''m'') = ''n'' 
				) tmp1 GROUP BY source_deal_header_id, deal_date	;
	
			INSERT INTO  '+ @ProcessTableName+' (
				Match,[Hedged Item Product],[Tenor],[Deal Date],[Type],[Deal ID],[Deal REF ID],[Volume % Avail],[Volume Avail],
				[Volume matched] ,[% Matched] ,[UOM],[used_ass_profile_id],[fas_book_id],[perfect_hedge],[link_description],[eff_test_profile_id],
				[link_effective_date],[link_type_value_id] ,[gen_status],deal_volume,buy_sell,curve_id,process_id ,term_start ,term_end,source_uom_id,
				[Counterparty]
				)
			SELECT 	NULL,spcd.curve_name,convert(VARCHAR(7), tmp.term_start,120) + '' : ''  + CONVERT(VARCHAR(7), tmp.term_end,120) Tenor,
				sdh.deal_date,tmp.h_or_i ,sdh.source_deal_header_id,sdh.deal_id,(1-ISNULL(pu.used_percentage,0)) avail_per
				,CASE WHEN tmp.buy_sell=''s'' then -1 ELSE 1 END * (1-ISNULL(pu.used_percentage,0)) *  tmp.deal_volume [Volume Avail] ,
				0 ,0,su.uom_name,78,ISNULL(tmp.fas_book_id,-1),	''n'',	''Not match'',	ISNULL(tmp.eff_test_profile_id,-1),
				tmp.link_effect_date,450,''a'',	tmp.deal_volume,tmp.buy_sell,tmp.curve_id,	'''+ @process_id +'''
				,tmp.term_start	,tmp.term_end	,su.source_uom_id		,sc.counterparty_id
			FROM #tmp_deal_detail1 tmp
			INNER JOIN source_deal_header sdh on sdh.source_deal_header_id=tmp.source_deal_header_id 
			INNER JOIN #tmp_not_MA_deals ma_d on sdh.source_deal_header_id=ma_d.source_deal_header_id
			INNER JOIN 
			(
				SELECT source_deal_header_id,MAX(deal_volume_uom_id) deal_volume_uom_id FROM source_deal_detail where Leg = 1 GROUP BY source_deal_header_id
			) sdd on sdd.source_deal_header_id = tmp.source_deal_header_id
			INNER JOIN source_uom su on sdd.deal_volume_uom_id=su.source_uom_id
			INNER JOIN source_price_curve_def spcd on spcd.source_curve_def_id=	tmp.curve_id	
			LEFT JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id 
			LEFT JOIN #used_percentage pu on pu.source_deal_header_id=tmp.source_deal_header_id 
			WHERE  ISNULL(pu.used_percentage,0)<.999
			ORDER BY h_or_i, sdh.deal_date, sdh.deal_id
		'
	--PRINT @sql
	EXEC(@sql)

	EXEC('CREATE INDEX indx_ProcessTableName' + @process_id + '_1 ON '+ @ProcessTableName+ '([deal id]) ')
	EXEC('CREATE INDEX indx_ProcessTableName' + @process_id + '_2 ON '+ @ProcessTableName+ '([rowid]) ')

	IF ISNULL(@call_for_report,'n')='y'
	BEGIN
		DELETE [gen_fas_link_detail_dicing]
		FROM [gen_fas_link_detail_dicing] fldd INNER JOIN [gen_fas_link_detail] fld 
		ON fldd.link_id=fld.gen_link_id
		INNER JOIN [gen_fas_link_header] flh ON fld.gen_link_id=flh.gen_link_id WHERE flh.process_id = @process_id --create_ts>=@run_time

		DELETE [gen_fas_link_detail] FROM [gen_fas_link_detail] fld 
		INNER JOIN [gen_fas_link_header] flh ON fld.gen_link_id=flh.gen_link_id 
		WHERE flh.process_id=@process_id --create_ts>=@run_time

		DELETE gen_hedge_group FROM gen_hedge_group flg 
		INNER JOIN [gen_fas_link_header] flh ON flg.gen_hedge_group_id=flh.gen_hedge_group_id 
		WHERE flh.process_id=@process_id --create_ts>=@run_time

		DELETE [gen_fas_link_header] WHERE process_id=@process_id

		UPDATE message_board SET url_desc = STUFF(url_desc,CHARINDEX(',', url_desc, 1) + 2, 36, @process_id) WHERE source = 'Auto Matching' AND user_login_id  =@user_name

	--	EXEC [dbo].[spa_auto_matching_report] 	@process_id,@v_curve_id ,@h_or_i,@v_buy_sell,@user_name
		EXEC spa_ErrorHandler 0, 'Auto Matching', 
						'spa_auto_matching_job', 'Success', 
						'Auto Matching.', @process_id
	
		--IF @@TRANCOUNT>0
		--COMMIT
		RETURN
	END

	SET @url_desc = '' 
	IF EXISTS(SELECT 1 FROM fas_eff_ass_test_run_log  WHERE process_id = @process_id)
	BEGIN
		SET @errorcode='e'
		IF EXISTS(SELECT [gen_hedge_group_id] FROM [gen_fas_link_header] WHERE process_id = @process_id)
			SET @url_desc = ''--dbo.FNAHyperLinkText(10234500,'View Result...',1)
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT [gen_hedge_group_id] FROM [gen_fas_link_header] WHERE process_id = @process_id)
		BEGIN
			SET @errorcode = 'a'
			SET @report_url = ''

			SELECT @desc = dbo.FNATrmHyperlink('a',10234500,'Automatic matching process is completed for ' + dbo.FNAUserDateFormat(@as_of_date_to, @user_name)+'.',1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
		END
		ELSE
		BEGIN
			SET @errorcode = 'e'
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, [source], [type], [description], nextsteps) 
				VALUES(@process_id,'Error', 'Auto Matching', 'Automatic Matching',
				'Application Error','No matching deals were found as of date '+ dbo.FNAUserDateFormat(@as_of_date_to, @user_name) , 'Please make sure.')
		END
	END

	SELECT @process_id_tmp = '''' + @process_id + ''''

	--SELECT  @url_desc = dbo.FNATrmHyperlink('e',10234411,'View Result...',@process_id_tmp,@sub_id,@h_or_i,@v_buy_sell,default,default,default,default,default,default,default,default)
	SELECT  @url_desc = ''--- dbo.FNATrmHyperlink('j',10234411,'View Result...',@process_id_tmp,@sub_id,@h_or_i,@v_buy_sell,@str_id,@book_id,@fifo_lifo,'a',@v_curve_id,'msg_board',@as_of_date_from,@as_of_date_to)

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
				'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''''
	IF @errorcode <> 'a'
		SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
					'Automatic matching process is completed for ' + dbo.FNAUserDateFormat(@as_of_date_to, @user_name) + 
				CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found)' ELSE '' END +
				'.</a>'

	IF @errorcode = 'a'
	BEGIN
		DECLARE @source VARCHAR(50)
	
		SET @source =  @as_of_date_from + '|' + ISNULL(@as_of_date_to, 'NULL') 
		EXEC spa_compliance_workflow 116, 'i', @process_id, @source
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM message_board WHERE process_id = @process_id AND [source] = 'Auto Matching')
		EXEC  spa_message_board 'i', @user_name,NULL, 'Auto Matching',@desc, @url_desc, '', @errorcode, 'AutoMatching',NULL,@process_id
	ELSE 
	BEGIN
		IF @errorcode='e'
			UPDATE message_board SET [type]='e' WHERE process_id=@process_id AND [source] = 'Auto Matching'
	END 
-------------------END error Trapping--------------------------------------------------------------------------
END TRY
BEGIN CATCH
----PRINT @@TRANCOUNT
--IF @@TRANCOUNT>0
--	ROLLBACK

	--PRINT 'Error description :['+ERROR_MESSAGE()+'].'
	--PRINT ERROR_NUMBER()
	SET @url_desc = '' 
	SET @errorcode = 'e'

	IF ISNULL(@call_for_report, 'n') = 'y'
	BEGIN
		SELECT @url_desc = ERROR_MESSAGE()
		EXEC spa_ErrorHandler -1, 'Auto Matching', 
						'spa_auto_matching_job', 'Error', 
						@url_desc, @process_id
		RETURN
	END
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
				'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''''
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
				'Automatic matching process is completed for ' + dbo.FNAUserDateFormat(@as_of_date_to, @user_name) + 
				CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found)' ELSE '' END + '.</a>'

	EXEC  spa_message_board 'i', @user_name,
				NULL, 'Auto Matching',
				@desc, @url_desc, '', @errorcode, 'AutoMatching',NULL,@process_id
	
	SET @url_desc = '' 
	SET @errorcode = 'e'

	INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, [source], [type], [description], nextsteps) 
	VALUES(@process_id,'Error', 'Auto Matching', 'Automatic Matching',
		'Database Error','Critical Error Found [ '+ ERROR_MESSAGE()+']' , 'Please contact support.')
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
				'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''''
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
				'Automatic matching process is completed for ' + dbo.FNAUserDateFormat(@as_of_date_to, @user_name) + 
			CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found)' ELSE '' END + '.</a>'
END CATCH

/*******************************************2nd Paging Batch START**********************************************/
IF  @batch_process_id IS NOT NULL        
BEGIN        
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)
	EXEC(@str_batch_table)     
END        
/*******************************************2nd Paging Batch END**********************************************/
 
GO