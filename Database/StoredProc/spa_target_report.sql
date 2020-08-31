
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_target_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_target_report]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_target_report]
@summary_option VARCHAR(100) = 's',
@sub VARCHAR(max) = NULL,
@stra VARCHAR(max) = NULL,
@book VARCHAR(max) = NULL,
@comp_yr_from INT = NULL,
@comp_yr_to INT = NULL,
@assignment_type_value_id INT = NULL,
@assigned_state varchar(8000) = NULL,
@report_type CHAR(1) = 'i',
@compliance_yr INT = NULL,
@hypothetical CHAR(1) = 'n',
@group_id INT = NULL,
@deal_status varchar(1000) = NULL,
@tier varchar(8000) = NULL,
@assignment_priority INT = NULL,
@target_report CHAR(1) = NULL,
@round INT = 2,

@batch_process_id VARCHAR(250) = NULL,
@batch_report_param VARCHAR(500) = NULL, 
@enable_paging INT = 0,		--'1' = enable, '0' = disable
@page_size INT = NULL,
@page_no INT = NULL

AS

SET NOCOUNT ON

/*
--DROP TABLE tempdb..#temp_pt1
--DROP TABLE tempdb..#temp_pt2
--DROP TABLE tempdb..#temp_pt3
--DROP TABLE tempdb..#temp_pt4
--DROP TABLE tempdb..#temp_pt5
--exec spa_target_report 's', '124', '125', null,NULL,NULL, 5146, 300606,n, 2013, 'y
--EXEC spa_target_report 's','145',NULL,NULL,5530,5532,5146,'300675',i,NULL,NULL,NULL,NULL
--EXEC spa_target_report 's',NULL,'158',NULL,5528,5533,5146,'300797,300846,300851,300798,300855,293336,300881,300880,300867,300732,300709,300871,300627,300710,300843,300861,300727,300626,300849,300740,300731,300754,300841,300837,300833,300796,300824,300728,300675,300828,300821,300744,300708,300707,300820,300817,300636,300736,300745,300711,300713,300814,300813,300606,300801',i,NULL,NULL,NULL,NULL

DECLARE @assignment_type_value_id INT = 5146, @assigned_state varchar(8000) = '300626,300740,300731,300675,300745'--NULL-- '300740,300731'--'300797,300846,300851,300798,300855,293336,300881,300880,300867,300732,300709,300871,300627,300710,300843,300861,300849,300740,300731,300754,300841,300837,300833,300796,300824,300828,300821,300744,300708,300707,300820,300817,300636,300736,300745,300711,300713,300814,300813,300606,300801'--'300797,300846,300851,300798,300855,293336,300881,300880,300867,300732,300709,300871,300627,300710,300843,300861,300727,300626,300849,300740,300731,300754,300841,300837,300833,300796,300824,300728,300675,300828,300821,300744,300708,300707,300820,300817,300636,300736,300745,300711,300713,300814,300813,300606,300801' --'300740,300731'--'300727,300728'--293336,300732,300709,300627,300710,300727,300626,300740,300731,300728,300675,300744,300708,300707,300636,300736,300711,300713,300606--300727,300728--300626,300728 --'300727,300737,300728'--'300626,300728'--'300727,300737,300728'-- --'300727,300728,300736'--
, @deal_status varchar(1000) = NULL--'5604' --5604,5609,5605
DECLARE @sub VARCHAR(100) = NULL,
@stra VARCHAR(100) = NULL,
@book VARCHAR(100) = NULL
--DECLARE @deal_status VARCHAR(1000) = '5607,5606'
DECLARE @summary_option VARCHAR(100) = 's'	--s summary 
											--t technology 
											--p technology and gen_state 
											--g generator
											--h generator group
											--e environment product
DECLARE @report_type CHAR(1) = 'n'--'i','a','n'
DECLARE @group_id INT 
DECLARE @batch_process_id VARCHAR(250) = NULL,
@batch_report_param VARCHAR(500) = NULL, 
@enable_paging INT = 0,		--'1' = enable, '0' = disable
@page_size INT = NULL,
@page_no INT = NULL

--EXEC spa_target_report 's','134','136','139',5531,5531,5146,'300713',i,NULL,NULL,NULL,NULL
--EXEC spa_target_report 's','98','111','112',5531,5531,5146,'300626',i,NULL,NULL,NULL,NULL
--exec spa_target_report 's', '132,132,132,132', '153,153,153,153', null,NULL,NULL, 5146, 293423    ,n, 2013, 'y'
--exec spa_target_report 's', null, null, null,NULL,NULL, 5146, 293423,n, 2013, 'y'
--exec spa_target_report 's', '132', '133', '139',NULL,NULL, 5146, 293423,i, 2013, 'y'
--'300626,300675,300708,300707,300636,300711,300606'
--EXEC spa_target_report 's','98','111','112',5526,5530,5146,'300606',NULL,i
--EXEC spa_target_report 's','98',NULL,NULL,5528,5533,5146,'300626,300675',a,NULL,NULL,NULL,NULL
--EXEC spa_target_report 's',NULL,'158',NULL,5531,5532,5146,'300740,300731',i,NULL,NULL,NULL,NULL
--EXEC spa_target_report 's','124','131','133',5532,5532,5146,'300745',i,NULL,NULL,NULL,NULL
--EXEC spa_target_report 's',NULL,'158',NULL,5532,5532,5146,'300740,300731',i,NULL,NULL,NULL,NULL
--EXEC spa_target_report 's','98,124','111,131,158','159,133,112',5530,5532,5146,'300626,300740,300731,300675,300745',i,NULL,NULL,NULL,NULL
SET @sub = '98,124'--'98'--'9'  '117', ,  
SET @stra = '111,131,158'--'111'--'15'
SET @book = '159,133,112'--'126,129'--'112'--'139'
--SET @fas_book_id = '134,139' 
DECLARE @comp_yr_from INT ,@comp_yr_to INT 
SET @comp_yr_from = 5530
SET @comp_yr_to = 5532
DECLARE @compliance_yr INT = NULL
DECLARE @hypothetical CHAR(1) = 'n'
--*/
DECLARE @Sql_Select VARCHAR(MAX), @Sql_Where VARCHAR(max), @sql VARCHAR(MAX)
SET @Sql_Where = ''

IF @comp_yr_from IS NOT NULL 
	SELECT @comp_yr_from = code FROM static_data_value WHERE TYPE_ID = 10092 AND value_id = @comp_yr_from
ELSE 
	SET @comp_yr_from = 1900
IF @comp_yr_to IS NOT NULL 
	SELECT @comp_yr_to = code FROM static_data_value WHERE TYPE_ID = 10092 AND value_id = @comp_yr_to
ELSE 
	SET @comp_yr_to = 5000

IF @compliance_yr IS NOT NULL
BEGIN
	SET @comp_yr_from = @compliance_yr
	SET @comp_yr_to = @compliance_yr
END

IF OBJECT_ID('tempdb..#temp_pt1') is NOT NULL 
	DROP TABLE #temp_pt1
	
IF OBJECT_ID('tempdb..#temp_pt2') is NOT NULL 
	DROP TABLE #temp_pt2
	
IF OBJECT_ID('tempdb..#temp_pt3') is NOT NULL 
	DROP TABLE #temp_pt3
	
IF OBJECT_ID('tempdb..#temp_pt4') is NOT NULL 
	DROP TABLE #temp_pt4
	
IF OBJECT_ID('tempdb..#temp_pt5') is NOT NULL 
	DROP TABLE #temp_pt5
	
IF OBJECT_ID('tempdb..#temp_pt6') is NOT NULL 
	DROP TABLE #temp_pt6

IF OBJECT_ID('tempdb..#temp_pt7') is NOT NULL 
	DROP TABLE #temp_pt7
	
IF OBJECT_ID('tempdb..#tmp_pt8') is NOT NULL 
	DROP TABLE #tmp_pt8
	
IF OBJECT_ID('tempdb..#tmp_pt9') is NOT NULL 
	DROP TABLE #tmp_pt9

IF OBJECT_ID('tempdb..#tmp_pt10') is NOT NULL 
	DROP TABLE #tmp_pt10
	
IF OBJECT_ID('tempdb..#tmp_pt11') is NOT NULL 
	DROP TABLE #tmp_pt11
		
IF OBJECT_ID('tempdb..#ssbm') IS NOT NULL
	DROP TABLE #ssbm
		
CREATE TABLE #ssbm(    
	source_system_book_id1 INT,              
	source_system_book_id2 INT,              
	source_system_book_id3 INT,              
	source_system_book_id4 INT,              
	fas_deal_type_value_id INT,              
	book_deal_type_map_id INT,              
	fas_book_id INT,              
	stra_book_id INT,              
	sub_entity_id INT              
 )    
 
SET @Sql_Select=    
'INSERT INTO #ssbm              
SELECT source_system_book_id1,source_system_book_id2,source_system_book_id3,  
source_system_book_id4,fas_deal_type_value_id,              
book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id,  
stra.parent_entity_id sub_entity_id               
FROM source_system_book_map ssbm               
INNER JOIN portfolio_hierarchy book (nolock) ON ssbm.fas_book_id = book.entity_id               
INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id               
WHERE 1=1 '              

IF @sub IS NOT NULL              
SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @sub + ') ' 
              
IF @stra IS NOT NULL              
SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @stra + ' ))'    
         
IF @book IS NOT NULL              
SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book + ')) '         
     
SET @Sql_Select=@Sql_Select+@Sql_Where   

--PRINT @sql_select             
EXEC (@Sql_Select)    

/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR (8000)
 
DECLARE @user_login_id VARCHAR (50)
 
DECLARE @sql_paging VARCHAR (8000)
 
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
 
SET @user_login_id = dbo.FNADBUser() 
 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL  THEN 1 ELSE 0 END 
 
IF @batch_process_id IS NOT NULL
 
BEGIN
 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	
END

IF @enable_paging = 1 --paging processing
 
BEGIN
	
	IF @batch_process_id IS NULL
 
	BEGIN
 
		SET @batch_process_id = dbo.FNAGetNewID()
 
		SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no)
 
	END
 
	--retrieve data from paging table instead of main table
 
	IF @page_no IS NOT NULL 
 
	BEGIN
 
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no) 
 
		EXEC (@sql_paging) 
 
		RETURN 
 
	END
 
END
 --SELECT @str_batch_table
 
/*******************************************1st Paging Batch END**********************************************/


IF OBJECT_ID('tempdb..#tmp_state_rec_requirement_data') IS NOT NULL 
	DROP TABLE #tmp_state_rec_requirement_data

SELECT sdv_yr.code [Year] 
INTO #temp_pt1 
FROM static_data_value sdv_yr 
WHERE type_id = 10092 
	AND sdv_yr.code BETWEEN @comp_yr_from AND @comp_yr_to
GROUP BY sdv_yr.code

--find applicable priority group for each eligible years
SELECT t.[Year], srrd.state_rec_requirement_data_id, srrd.state_value_id
INTO #tmp_state_rec_requirement_data
FROM state_rec_requirement_data srrd
CROSS JOIN #temp_pt1 t 
INNER JOIN dbo.SplitCommaSeperatedValues(@assigned_state) scsv on scsv.item = srrd.state_value_id
--WHERE srrd.state_value_id = @assigned_state
WHERE 1=1
	AND srrd.assignment_type_id = @assignment_type_value_id
	AND t.[Year] BETWEEN srrd.from_year AND srrd.to_year
	
CREATE INDEX index_tmp_state_rec_requirement_data ON #tmp_state_rec_requirement_data([Year])
	
	--select * from #tmp_state_rec_requirement_data
--DECLARE @nearest_priority_group INT , @nearest_requirement_type_id INT
DECLARE @nearest_state_rec_requirement_data_id INT

if OBJECT_ID('tempdb..#nearest_state_rec_requirement_data_id') is not null
	drop table #nearest_state_rec_requirement_data_id
	
CREATE TABLE #nearest_state_rec_requirement_data_id(state_rec_requirement_data_id INT, state_value_id INT)

----if available, take the priority group of data closest to run date
--SELECT TOP 1 @nearest_state_rec_requirement_data_id = ttpg.state_rec_requirement_data_id --, @nearest_priority_group = ttpg.rec_assignment_priority_group_id
INSERT INTO #nearest_state_rec_requirement_data_id(state_rec_requirement_data_id, state_value_id)
SELECT t.state_rec_requirement_data_id, ttpg.state_value_id
FROM 
( SELECT DISTINCT state_value_id FROM #tmp_state_rec_requirement_data) ttpg
cross apply (
SELECT TOP 1 state_rec_requirement_data_id
 from #tmp_state_rec_requirement_data
WHERE state_value_id = ttpg.state_value_id
AND [year] <= YEAR(GETDATE())
--group by state_rec_requirement_data_id,state_value_id, ttpg.[year]
ORDER BY [year] DESC
) t



--select * from #nearest_state_rec_requirement_data_id

IF NOT EXISTS(SELECT 1 from #nearest_state_rec_requirement_data_id)
BEGIN
	--otherwise, choose priority group of minimium year
	INSERT INTO #nearest_state_rec_requirement_data_id(state_rec_requirement_data_id, state_value_id)
	SELECT t.state_rec_requirement_data_id, ttpg.state_value_id
	FROM 
	(SELECT DISTINCT state_value_id FROM #tmp_state_rec_requirement_data) ttpg
	CROSS APPLY (
	SELECT TOP 1 state_rec_requirement_data_id FROM #tmp_state_rec_requirement_data
	WHERE state_value_id = ttpg.state_value_id
	--group by state_rec_requirement_data_id,state_value_id, ttpg.[year]
	ORDER BY [year] ASC
	) t
END
--select * from #tmp_state_rec_requirement_data

IF OBJECT_ID('tempdb..#target_deal_volume') IS NOT NULL
	DROP TABLE #target_deal_volume

IF OBJECT_ID('tempdb..#target_deal_volume_sales') IS NOT NULL
	DROP TABLE #target_deal_volume_sales

SELECT code INTO #temp_pt2 FROM static_data_value WHERE TYPE_ID = 10092
--select @comp_yr_from , @comp_yr_to
--populate target deal volume grouped by term_start

SELECT SUM(case when ssbm.fas_deal_type_value_id = 405 then sdd.deal_volume else 0 end) deal_volume, sdv_comp_yr.code term_start, sdh.state_value_id 
,  SUM(case when ssbm.fas_deal_type_value_id = 409 then sdd.deal_volume else 0 end)  deal_volume1
INTO #target_deal_volume
FROM source_deal_header sdh   
INNER JOIN #temp_pt2 sdv_comp_yr ON sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to --and sdh.source_deal_header_id =43793
LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id  
	AND YEAR(sdd.term_start) = sdv_comp_yr.code
INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1  
	AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
	AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
	AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
WHERE  ssbm.fas_deal_type_value_id = 405  or ( ssbm.fas_deal_type_value_id=409 and sdd.buy_sell_flag='s')
GROUP BY sdv_comp_yr.code, sdh.state_value_id
	--AND YEAR(sdd.term_start) = @compliance_year
	
--select * from static_data_value where type_id=400	
	
--select * from #target_deal_volume

	
SELECT  sdv_comp_yr.code term_start, sdh.state_value_id , rg.tier_type
,  SUM(sdd.deal_volume)  deal_volume
INTO #target_deal_volume_sales
FROM source_deal_header sdh   
INNER JOIN #temp_pt2 sdv_comp_yr ON sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to --and sdh.source_deal_header_id =43793
LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id  
	AND YEAR(sdd.term_start) = sdv_comp_yr.code
INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1  
	AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
	AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
	AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  	
INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id 

WHERE ( ssbm.fas_deal_type_value_id=409 and sdd.buy_sell_flag='s')
GROUP BY sdv_comp_yr.code, sdh.state_value_id,rg.tier_type


-- select * from #target_deal_volume_sales
	
CREATE INDEX pt_test2 ON #ssbm(source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4)
CREATE INDEX pt_test1 ON #target_deal_volume(term_start)
CREATE INDEX pt_test5 ON #target_deal_volume(deal_volume)

IF OBJECT_ID('tempdb..#banked_deals_without_tier') IS NOT NULL
	DROP TABLE #banked_deals_without_tier
	
CREATE table #banked_deals_without_tier(total_volume FLOAT, term_yr INT, state_value_id INT, technology INT, gen_state_value_id INT, generator INT, generator_group INT, env_product INT)

IF OBJECT_ID('tempdb..#temp_banked_deals_without_tier') IS NOT NULL
	DROP TABLE #temp_banked_deals_without_tier
	
CREATE table #temp_banked_deals_without_tier(total_volume FLOAT, term_yr INT, state_value_id INT, term_start INT, rge_from_month INT, rge_to_month INT, technology INT, gen_state_value_id INT, generator INT, generator_group INT, env_product INT)

IF OBJECT_ID('tempdb..#banked_deals') IS NOT NULL
	DROP TABLE #banked_deals
	
IF OBJECT_ID('tempdb..#temp_banked_deals') IS NOT NULL
	DROP TABLE #temp_banked_deals
	
IF OBJECT_ID('tempdb..#banked_deals_without_operation') IS NOT NULL
	DROP TABLE #banked_deals_without_operation
	
CREATE TABLE #banked_deals(id INT IDENTITY(1,1), rank_id INT, volume_left FLOAT, original_volume_left FLOAT, assigned_volume FLOAT, state_value_id INT, deal_volume FLOAT, retired FLOAT, term_yr INT, tier_type INT, [target] FLOAT, technology INT, gen_state_value_id INT, generator INT, generator_group INT, env_product INT)

CREATE TABLE #banked_deals_without_operation(volume_left FLOAT, state_value_id INT, deal_volume FLOAT, retired FLOAT, term_yr INT, tier_type INT, [target] FLOAT, technology INT, gen_state_value_id INT, generator INT, generator_group INT, env_product INT)

if object_id('tempdb..#banked_deals_1') IS NOT NULL
	DROP TABLE #banked_deals_1
			
CREATE TABLE #banked_deals_1(rank_id INT, volume_left FLOAT,original_volume_left FLOAT, assigned_volume FLOAT, state_value_id INT, deal_volume FLOAT, term_yr INT, tier_type INT, technology INT, gen_state_value_id INT, [target] FLOAT, retired FLOAT, generator INT, generator_group INT, env_product INT)

CREATE TABLE #temp_banked_deals(id int IDENTITY(1,1), state_value_id INT, volume_left FLOAT, retired FLOAT, term_yr VARCHAR(100) COLLATE DATABASE_DEFAULT, term_start DATETIME, rge_from_month INT, rge_to_month INT, tier_type INT, [target] FLOAT, technology INT, gen_state_value_id INT, generator INT, generator_group INT, env_product INT)
--select * from #target
--select * from #banked_deals where tier_type  = 300472 and state_value_id = 300731


IF @summary_option = 's'
BEGIN
	IF @report_type = 'a'
	BEGIN
		--take volume left of buy deals with from and to month filter in eligibility
		SELECT SUM(sdd.volume_left) volume_left, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type,
		MAX(srrd.state_value_id) state_value_id, MAX(srrd.assignment_type_id) assignment_type_id, MAX(rg.generator_id) generator_id,
		ISNULL(COALESCE(nullif(MAX(srrde.min_absolute_target) * ISNULL(MAX(sdd2.multiplier),1),0), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume)* ISNULL(MAX(sdd2.multiplier),1)), MAX(srrde.max_absolute_target)* ISNULL(MAX(sdd2.multiplier),1), (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume)* ISNULL(MAX(sdd2.multiplier),1))),0) [target]
		, YEAR(MAX(sdd.term_start)) term_start, rge.technology, rge.gen_state_value_id, scsv.item state_value_id2
		INTO #temp_pt3	
		--select sdd.source_deal_header_id, sdd.volume_left, sdv_comp_yr.code
		FROM (select * from static_data_value sdv_comp_yr where sdv_comp_yr.type_id = 10092) sdv_comp_yr
		CROSS JOIN source_deal_header sdh     
		CROSS APPLY(
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
			WHERE scsv_status.item = sdh.deal_status
		) scsv_status
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
			AND sdd.buy_sell_flag = 'b'       
			AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
			OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
			THEN @comp_yr_from ELSE 1 END
			)
			AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		--ON sdv_comp_yr.code BETWEEN 2012 AND 2012 OR sdv_comp_yr.code < 2012    
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id   
		left join static_data_value sd on sd.value_id=@assignment_type_value_id  
		LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id  
			AND rge.technology = rg.technology     
			--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)     
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
		LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
		LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			AND gc.state_value_id = srrd.state_value_id
		OUTER APPLY (
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
		) scsv
		INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
			AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			AND srrd.state_value_id = srrde.state_value_id
		CROSS APPLY (
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
			THEN srrde.state_value_id  ELSE rge.state_value_id END
		) scsv2
		OUTER APPLY
		(
			SELECT max(sdd.multiplier) multiplier, state_value_id from source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			where sdh.state_value_id = srrde.state_value_id
			group by sdh.state_value_id
		) sdd2
		LEFT JOIN #target_deal_volume dv ON YEAR(dv.term_start) = sdv_comp_yr.code
			AND dv.state_value_id = srrde.state_value_id
		WHERE sdh.assignment_type_value_id IS NULL 
			--and srrde.tier_type = 300472 --and srrde.state_value_id = 300731
			--AND sdv_comp_yr.code <= 2013
			AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
			ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
			>= CAST(@comp_yr_from AS VARCHAR)
		------group by scsv.item
		GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rge.technology, rge.gen_state_value_id, scsv.item
		----OPTION (HASH JOIN)
		--return
		
		--SELECT * FROM #temp_pt3
		--select * from #temp_pt3 where tier_type = 300472 and state_value_id = 300731
		
		--take volume_left of buy deals with from and to month filter in eligibility grouped by term_start, tier_type, technology and gen_state_value_id
		-- extra group by of technology and gen_state is added to make sure the operation performed later takes correct value according to 
		-- technology and gen state as tier type is not enough.
		SELECT RANK() OVER(ORDER BY MAX(rank_id)) rank_id, SUM(volume_left) volume_left, SUM(deal_volume) deal_volume,
		term_yr, tier_type, MAX(state_value_id) state_value_id,
		MAX(assignment_type_id) assignment_type_id, MAX(generator_id) generator_id,
		MAX([target]) [target]
		, YEAR(MAX(term_start)) term_start, technology, gen_state_value_id, state_value_id2
	
		INTO #temp_pt6	 --  select * from #temp_pt4
		----select srrd.* , (dv.deal_volume), ISNULL((sdd2.multiplier),1)
		----select sdd.volume_left,sdd.source_deal_header_id,  COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, sdv_comp_yr.code
		----select  sdd2.multiplier,srrde.state_value_id, sdd2.*
		FROM
		(
		-- technology and gen state as tier type is not enough.
		SELECT RANK() OVER(ORDER BY (sdh.source_deal_header_id)) rank_id, MAX(sdd.volume_left) volume_left, MAX(sdd.deal_volume) deal_volume,
		(sdv_comp_yr.code) term_yr, COALESCE(MAX(gc.tier_type), MAX(rg.tier_type), MAX(rge.tier_type)) tier_type, MAX(srrd.state_value_id) state_value_id,
		MAX(srrd.assignment_type_id) assignment_type_id, MAX(rg.generator_id) generator_id,
		ISNULL(COALESCE(nullif(MAX(srrde.min_absolute_target)* ISNULL(MAX(sdd2.multiplier),1),0), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume)* ISNULL(MAX(sdd2.multiplier),1)), MAX(srrde.max_absolute_target)* ISNULL(MAX(sdd2.multiplier),1), (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume)* ISNULL(MAX(sdd2.multiplier),1))),0) [target]
		, YEAR(MAX(sdd.term_start)) term_start, MAX(rge.technology) technology, MAX(rge.gen_state_value_id) gen_state_value_id, MAX(scsv.item) state_value_id2
		
		--select MAX(srrde.min_target) / 100 , MAX(dv.deal_volume), ISNULL(MAX(sdd2.multiplier),1), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume)* ISNULL(MAX(sdd2.multiplier),1))
		--, MAX(sdv_comp_yr.code) term_yr, COALESCE(MAX(gc.tier_type), MAX(rg.tier_type), MAX(rge.tier_type)) tier_type
		FROM (select * from static_data_value sdv_comp_yr where sdv_comp_yr.type_id = 10092) sdv_comp_yr
		CROSS JOIN source_deal_header sdh     
		CROSS APPLY(
			SELECT item from dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
			where scsv_status.item = sdh.deal_status
		) scsv_status
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
			AND sdd.buy_sell_flag = 'b'       
			AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
			OR CAST(YEAR(sdd.term_start) AS VARCHAR) <=  CASE WHEN sdv_comp_yr.code = @comp_yr_from
			THEN @comp_yr_from ELSE 1 END
			)  
			AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		--ON sdv_comp_yr.code BETWEEN 2012 AND 2012 OR sdv_comp_yr.code < 2012    
		LEFT JOIN rec_generator rg ON rg.generator_id = sdh.generator_id   
		left join static_data_value sd on sd.value_id=@assignment_type_value_id    
		LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id  
			AND rge.technology = rg.technology     
			--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)     
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
		
		INNER JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id = ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
		CROSS APPLY (
			select item from dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
		) scsv
		LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			AND gc.state_value_id = srrd.state_value_id
		INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
			AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			AND srrd.state_value_id = srrde.state_value_id
		CROSS APPLY (
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
			THEN srrde.state_value_id  ELSE rge.state_value_id END
		) scsv2
		CROSS APPLY
		(
			SELECT (sdd1.source_deal_detail_id) source_deal_detail_id, max(sdd1.multiplier) multiplier, state_value_id from source_deal_header sdh1 
			INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id = sdh1.source_deal_header_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh1.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh1.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh1.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh1.source_system_book_id4
			where sdh1.state_value_id = srrde.state_value_id
			and YEAR(sdd1.term_start) between srrd.from_year and srrd.to_year
			group by sdh1.state_value_id, sdd1.source_deal_detail_id
		) sdd2
		LEFT JOIN #target_deal_volume dv ON YEAR(dv.term_start) = sdv_comp_yr.code	
			AND dv.state_value_id = srrde.state_value_id
		WHERE sdh.assignment_type_value_id IS NULL
		--and srrde.tier_type = 300472 and srrde.state_value_id = 300731
		--	AND sdv_comp_yr.code = 2013
			AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
			ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
			>= CAST(@comp_yr_from AS VARCHAR)
			--and srrde.tier_type = 300722 
		GROUP BY sdh.source_deal_header_id, srrde.tier_type, srrde.state_value_id,sdv_comp_yr.code
		) s
		GROUP BY term_yr, tier_type, technology, gen_state_value_id, state_value_id2
		--OPTION (HASH JOIN )
		
		--return
		--select * from #temp_pt6 where tier_type = 300677 and state_value_id = 300731
		
		--take deal volume of sell deals
		SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, rge.tier_type tier_type, scsv.item state_value_id
		INTO #temp_pt4
		FROM source_deal_header sdh    
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
			AND sdd.buy_sell_flag = 's'       
		INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
			AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
			AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		--ON sdv_comp_yr.code BETWEEN 2012 AND 2012 OR sdv_comp_yr.code < 2012    
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id   
		left join static_data_value sd on sd.value_id=@assignment_type_value_id  
		LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id  
			AND rge.technology = rg.technology     
			--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)     
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
		OUTER APPLY(
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv
			WHERE scsv.item = rge.state_value_id
		) scsv
		WHERE sdh.status_value_id = 5182
		GROUP BY sdv_comp_yr.code, rge.tier_type, scsv.item
		--OPTION (HASH JOIN)
		
			--select * from #temp_banked_deals
		--populate banked deals without from and to month filter for eligibility
		INSERT INTO #temp_banked_deals(volume_left, term_yr, tier_type, [target], retired, term_start, technology, gen_state_value_id, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.tier_type, b.[target], 
		ISNULL(sdh_aa.assigned_volume,0) + ISNULL(sdh_aa2.assigned_volume,0), b.term_start, b.technology, b.gen_state_value_id, b.state_value_id2
		FROM #temp_pt3 b
		OUTER APPLY 
		(
			 SELECT deal_volume,  term_yr,  tier_type
			 FROM #temp_pt4 WHERE 1 = 1 
				AND tier_type = b.tier_type 
				AND term_yr = b.term_yr
				and state_value_id= b.state_value_id2
			--GROUP BY sdv_comp_yr.code, rge.tier_type
		) s
		OUTER APPLY
		(
			SELECT SUM(aa.assigned_volume) assigned_volume
			FROM source_deal_header sdh 
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdh.generator_id = b.generator_id AND sdd.buy_sell_flag = 's'
				AND sdh.assignment_type_value_id IS NOT NULL 
				AND sdh.compliance_year = b.term_yr
			INNER JOIN assignment_audit aa ON aa.compliance_year = b.term_yr
				AND b.tier_type = aa.tier
				AND aa.assignment_type = b.assignment_type_id
				AND aa.state_value_id = b.state_value_id
				AND sdd.source_deal_detail_id = aa.source_deal_header_id
		) sdh_aa
		OUTER APPLY
		(
			SELECT SUM(sdd.deal_volume) assigned_volume
			FROM source_deal_header sdh 
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdh.generator_id = b.generator_id AND sdd.buy_sell_flag = 's'
				AND sdh.assignment_type_value_id IS NOT NULL 
				AND sdh.compliance_year = b.term_yr
			INNER JOIN source_deal_header offset_deal ON offset_deal.source_deal_header_id = sdh.close_reference_id
			INNER JOIN source_deal_header original_deal ON original_deal.source_deal_header_id = offset_deal.close_reference_id
			INNER JOIN source_deal_detail original_detail ON original_detail.source_deal_header_id = original_deal.source_deal_header_id
			INNER JOIN assignment_audit aa ON aa.compliance_year = b.term_yr
				AND b.tier_type = aa.tier
				AND aa.assignment_type = b.assignment_type_id
				AND aa.state_value_id = b.state_value_id
				AND original_detail.source_deal_detail_id = aa.source_deal_header_id
		) sdh_aa2
		
		CREATE INDEX Index_temp_banked_deals1 on #temp_banked_deals(term_start)
		CREATE INDEX Index_temp_banked_deals2 on #temp_banked_deals(rge_from_month)
		CREATE INDEX Index_temp_banked_deals3 on #temp_banked_deals(rge_to_month)
		--select * from #temp_banked_deals
		--select * from #banked_deals_1 where tier_type = 300677 and state_value_id = 300731
		
		
		--populate banked deals with from and to month filter in eligibility
		INSERT INTO #banked_deals_1(rank_id, volume_left, original_volume_left, assigned_volume, deal_volume, term_yr, tier_type, [target], retired, technology, gen_state_value_id, state_value_id)
		
		
		SELECT rank_id, ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0) + ISNULL(sdh_aa.assigned_volume,0) + ISNULL(sdh_aa2.assigned_volume,0), 
		ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0) original_volume_left, ISNULL(sdh_aa.assigned_volume,0) + ISNULL(sdh_aa2.assigned_volume,0) assigned_volume, ISNULL(b.deal_volume,0) deal_volume, b.term_yr, b.tier_type, b.[target], 
		ISNULL(sdh_aa.assigned_volume,0) + ISNULL(sdh_aa2.assigned_volume,0), b.technology, b.gen_state_value_id, b.state_value_id
		FROM #temp_pt6 b
		OUTER APPLY (
			SELECT deal_volume,  term_yr, tier_type
			FROM #temp_pt4 WHERE 1 = 1 
				AND tier_type = b.tier_type 
				AND term_yr = b.term_yr
				AND b.state_value_id = state_value_id
		) s
		OUTER APPLY(
			SELECT SUM(aa.assigned_volume) assigned_volume
			FROM source_deal_header sdh 
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdh.generator_id = b.generator_id AND sdd.buy_sell_flag = 's'
				AND sdh.assignment_type_value_id IS NOT NULL 
				AND sdh.compliance_year = b.term_yr
			INNER JOIN assignment_audit aa ON aa.compliance_year = b.term_yr
				AND b.tier_type = aa.tier
				AND aa.assignment_type = b.assignment_type_id
				AND aa.state_value_id = b.state_value_id
				AND sdd.source_deal_detail_id = aa.source_deal_header_id
		) sdh_aa
		OUTER APPLY(
			SELECT SUM(sdd.deal_volume) assigned_volume
			FROM source_deal_header sdh 
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdh.generator_id = b.generator_id AND sdd.buy_sell_flag = 's'
				AND sdh.assignment_type_value_id IS NOT NULL 
				AND sdh.compliance_year = b.term_yr
			INNER JOIN source_deal_header offset_deal ON offset_deal.source_deal_header_id = sdh.close_reference_id
			INNER JOIN source_deal_header original_deal ON original_deal.source_deal_header_id = offset_deal.close_reference_id
			INNER JOIN source_deal_detail original_detail ON original_detail.source_deal_header_id = original_deal.source_deal_header_id
			INNER JOIN assignment_audit aa ON aa.compliance_year = b.term_yr
				AND b.tier_type = aa.tier
				AND aa.assignment_type = b.assignment_type_id
				AND aa.state_value_id = b.state_value_id
				AND original_detail.source_deal_detail_id = aa.source_deal_header_id
		) sdh_aa2
			
		--return
		
			--select * from #banked_deals_without_operation
		--Populate into this table before performing update information to keep original information intact(later used)
		INSERT INTO #banked_deals_without_operation(volume_left, term_yr, tier_type, state_value_id)
		SELECT SUM(deal_volume) volume_left, term_yr, tier_type, state_value_id
		FROM #banked_deals_1 GROUP BY tier_type, term_yr, state_value_id
		
		-- update the banked (volume left) of row of first row with previous years banked i.e. the row with minimum term start 
		-- without filtering the from and to month of eligibility		
		-- extra join of technology and gen state is added so that correct value is taken to avoid wrong values in case of:
		-- technology1 may be from 2008 to 2050
		-- while technology2 may be from 2013 to 2050 
		
		--select * from #banked_deals_1
		UPDATE bd SET bd.volume_left = a.volume_left 
		FROM #banked_deals_1 bd
		OUTER APPLY (
			SELECT SUM(volume_left) volume_left 
			FROM #temp_banked_deals bd2 
			WHERE 1=1
				AND bd.tier_type = bd2.tier_type 
				AND bd2.term_yr <= bd.term_yr
				AND bd.technology = bd2.technology 
				AND bd.gen_state_value_id = bd2.gen_state_value_id
				AND bd.state_value_id = bd2.state_value_id
			GROUP BY bd2.tier_type
			) a
		CROSS APPLY(
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_1 
			WHERE tier_type = bd.tier_type
				AND bd.technology = technology 
				AND bd.gen_state_value_id = gen_state_value_id
				AND bd.state_value_id = state_value_id
			GROUP BY tier_type
			) bd3
		WHERE bd3.term_yr = bd.term_yr
		 --select * from #banked_deals order by tier_type,term_yr
		
		--populate into final banked table after grouping by tier type and term start
		INSERT INTO #banked_deals(rank_id, volume_left, original_volume_left, assigned_volume, term_yr, tier_type, [target], state_value_id)
		SELECT MAX(rank_id) rank_id, SUM(volume_left)  volume_left, SUM(original_volume_left) original_volume_left, sum(assigned_volume) assigned_volume, 
		term_yr, tier_type,  max([target]) [target], state_value_id
		FROM #banked_deals_1 GROUP BY tier_type, term_yr, state_value_id
		
		--select * from #banked_deals_1 where tier_type = 300722
		
		--select * from #banked_deals where tier_type = 300722
		
	
		IF OBJECT_ID('tempdb..#banked_deals_adjusted2') IS NOT NULL 
			DROP TABLE #banked_deals_adjusted2
		
		IF OBJECT_ID('tempdb..#banked_deals_adjusted3') IS NOT NULL 
			DROP TABLE #banked_deals_adjusted3
		
		IF OBJECT_ID('tempdb..#banked_deals_adjusted') IS NOT NULL 
			DROP TABLE #banked_deals_adjusted
			
		CREATE TABLE #banked_deals_adjusted2(id INT, priority INT, calc_target INT,  calc_banked INT,  rank_id INT, term_yr INT, tier_type INT, [target] FLOAT, banked FLOAT, total_banked FLOAT, carryover_bank FLOAT, assigned FLOAT, original_volume_left FLOAT, assigned_volume FLOAT, calc_assigned FLOAT)		
			--select * from #target
			--MAX(ISNULL(original_volume_left,0)) calc_banked
			--ISNULL(t.original_volume_left,0)
		-- use recursive CTE to populate banked deals adjusted table columns banked, total banked and carryover bank(ie cumulative sum grouped by tier type)
		;WITH Cntt AS 
		(
			SELECT MIN(t.id) id, NULL priority, MIN([TARGET]) calc_target,  MAX(ISNULL(original_volume_left,0)) calc_banked, rank_id, MIN(term_yr) term_yr,  tier_type, SUM([TARGET]) [TARGET],
			MAX(ISNULL(volume_left,0)) banked, MIN(ISNULL(volume_left,0)) total_banked, MIN(ISNULL(volume_left,0)) carryover_bank,  NULL assigned
			, MIN(original_volume_left) original_volume_left, MAX(assigned_volume) assigned_volume
			FROM #banked_deals t --WHERE tier_type = 300721 --and term_yr = 2011
			GROUP BY  term_yr,tier_type, rank_id
			
			UNION ALL
			SELECT t.id, NULL priority, t.[TARGET] calc_target, ISNULL(t.volume_left,0) calc_banked, t.rank_id, t.term_yr,  t.tier_type, t.[TARGET], ISNULL(t.volume_left,0) banked , ISNULL(t.volume_left,0) + ISNULL(Cntt.carryover_bank,0) total_bank,
			CASE WHEN ISNULL(t.volume_left,0) + ISNULL(Cntt.carryover_bank,0) - (ISNULL(t.[target],0) -ISNULL(t.retired,0)) > 0 THEN 
 			ISNULL(t.volume_left,0) + ISNULL(Cntt.carryover_bank,0) - (ISNULL(t.[target],0) -ISNULL(t.retired,0)) ELSE 0 END,  NULL assigned
			, Cntt.original_volume_left, Cntt.assigned_volume
			FROM Cntt 
			INNER JOIN #banked_deals t ON t.term_yr  = Cntt.term_yr + 1 
				AND t.tier_type = Cntt.tier_type
				and t.rank_id = Cntt.rank_id
				--and t.id <> Cntt.id
				--AND t.state_value_id = Cntt.state_value_id
		)
		
		
		
		INSERT INTO #banked_deals_adjusted2(id, priority, calc_target,  calc_banked,  rank_id, term_yr, tier_type, TARGET, banked, total_banked, carryover_bank, assigned, original_volume_left, assigned_volume)
		SELECT MAX(id), MAX(priority), MAX(calc_target), SUM(calc_banked), MAX(rank_id), term_yr, tier_type, MAX([target]), SUM(banked), SUM(total_banked), SUM(carryover_bank), SUM(assigned), SUM(original_volume_left), SUM(assigned_volume)
		FROM Cntt --where tier_type = 300677 
		group by tier_type, term_yr
		ORDER BY tier_type, term_yr
		
		
	
		
		--ALTER TABLE #banked_deals_adjusted2 ADD calc_assigned FLOAT
		--OPTION (MAXRECURSION 0);
		--select * from #banked_deals_adjusted2 order by term_yr,priority,rank_id
		--return
		UPDATE bda2 SET bda2.priority = rapo_prd.priority
		--select rapo_prd.priority
		FROM #banked_deals_adjusted2 bda2
		INNER JOIN (
			SELECT max(rapd.rec_assignment_priority_group_id) rec_assignment_priority_group_id,  priority_type_value_id tier_type, max(rapo.order_number) priority 
			FROM rec_assignment_priority_order rapo
			INNER JOIN rec_assignment_priority_detail rapd ON rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
			INNER JOIN state_rec_requirement_data srrd ON srrd.rec_assignment_priority_group_id = rapd.rec_assignment_priority_group_id
				--AND srrd.state_rec_requirement_data_id = @nearest_state_rec_requirement_data_id
			INNER JOIN #nearest_state_rec_requirement_data_id nsrrdi On nsrrdi.state_rec_requirement_data_id = srrd.state_rec_requirement_data_id
				AND nsrrdi.state_value_id = srrd.state_value_id
			GROUP BY priority_type_value_id
		) rapo_prd ON bda2.tier_type = rapo_prd.tier_type
		
		--select * from #banked_deals_adjusted2
		--return
		
		 
		
		
			 
	DECLARE @rank_id INT, @tier_type INT, @calc_banked FLOAT, @banked FLOAT, @priority INT, 
	@term_yr INT, @target FLOAT, @assigned FLOAT, @var FLOAT
	
	DECLARE year_cur_status CURSOR LOCAL FOR
	SELECT distinct term_yr from #banked_deals_adjusted2 --where tier_type = 300472
	 order by 1
	--group by rank_id, priority order by priority
		
	OPEN year_cur_status;

	FETCH NEXT FROM year_cur_status INTO @term_yr
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DECLARE rank_cur_status CURSOR LOCAL FOR
		SELECT rank_id, SUM(calc_banked) calc_banked 
		FROM ( SELECT distinct rank_id, calc_banked from #banked_deals_adjusted2 where 1=1 --banked <> 0
			and term_yr <= @term_yr
			--and tier_type = 300720
			) a --where rank_id = 1
		group by rank_id
			
		OPEN rank_cur_status;

		FETCH NEXT FROM rank_cur_status INTO @rank_id, @banked
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SET @calc_banked = @banked
			--select @calc_banked
			DECLARE tier_cur_status CURSOR LOCAL FOR
			SELECT distinct tier_type, priority, calc_target, assigned_volume from #banked_deals_adjusted2 
			where rank_id = @rank_id 
				and term_yr = @term_yr
				and calc_target <> 0
				--and tier_type = 300720
			--group by tier_type
			 order by priority, tier_type
			
			OPEN tier_cur_status;

			FETCH NEXT FROM tier_cur_status INTO @tier_type, @priority, @target, @assigned
			WHILE @@FETCH_STATUS = 0
			BEGIN
					
				--SELECT @calc_banked = banked from #banked_deals_adjusted2 where tier_type = @tier_type
				
				IF @target <= @calc_banked + @assigned
				BEGIN
					UPDATE #banked_deals_adjusted2 SET calc_assigned = [target] WHERE tier_type = @tier_type
					AND term_yr = @term_yr AND priority = @priority AND rank_id = @rank_id
					
					SET @calc_banked = @calc_banked + @assigned - @target
					
					UPDATE #banked_deals_adjusted2 SET calc_target = 0
					WHERE tier_type = @tier_type AND term_yr = @term_yr AND priority = @priority
					AND rank_id = @rank_id
					
				END
				ELSE
				BEGIN
				
					UPDATE #banked_deals_adjusted2 
					SET calc_assigned = @calc_banked +  @assigned 
					, calc_banked = 0
					, calc_target = calc_target - (@calc_banked + @assigned)
					WHERE tier_type = @tier_type
					AND term_yr = @term_yr --AND priority = @priority 
					
					 
					--and rank_id = @rank_id
					--select @var
					--select @calc_banked,@rank_id,@term_yr, @assigned
					--SELECT calc_banked,* FROM #banked_deals_adjusted2
				
					SET @calc_banked = 0
					
				END
				
				IF @calc_banked = 0
					break
				
				FETCH NEXT FROM tier_cur_status INTO @tier_type, @priority, @target, @assigned
				
			END;

			CLOSE tier_cur_status;
			DEALLOCATE tier_cur_status;	
			
				UPDATE #banked_deals_adjusted2 SET calc_banked = @calc_banked
				WHERE term_yr <= @term_yr and rank_id = @rank_id
		
			FETCH NEXT FROM rank_cur_status INTO @rank_id, @banked
		END;

		CLOSE rank_cur_status;
		DEALLOCATE rank_cur_status;	
	
		FETCH NEXT FROM year_cur_status INTO @term_yr
	
	END;

		CLOSE year_cur_status;
		DEALLOCATE year_cur_status;
		
		--return
		--SELECT  * FROM  #banked_deals_adjusted2
		
		SELECT MAX(calc_assigned) assigned, MAX(rank_id) rank_id, term_yr, tier_type, MAX([target]) [target],
		MAX(banked) banked, MAX(total_banked) total_banked, MAX(carryover_bank) carryover_bank 
		INTO #banked_deals_adjusted 
		FROM #banked_deals_adjusted2 group by term_yr, tier_type
		
		
	END
	ELSE 
	BEGIN
			--select * from #temp_pt5
		--select volume left of buy deals without from and to month filter in eligibility
		SELECT SUM(volume_left) volume_left, term_yr, tier_type
		, MAX(term_start) term_start, technology, gen_state_value_id, state_value_id
		INTO #temp_pt5
		FROM
		(	
		--select COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, sdd.* 
		--select (sdd.volume_left),sdd.source_deal_header_id,rge.tier_type rge_tier_type, rg.tier_type rg_tier_type,gc.tier_type gc_tier_type, srrde.tier_type srrde_tier_type, srrde.state_value_id
		--,gc.source_deal_header_id , sdd.source_deal_detail_id,YEAR(sdd.term_start),dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,NULL, srrde.assignment_type_id, srrde.state_value_id)
		--,gc.source_certificate_number
		SELECT MAX(sdd.volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, COALESCE((gc.tier_type), (rg.tier_type), (rge.tier_type)) tier_type
		, YEAR(MAX(sdd.term_start)) term_start, MAX(rge.technology) technology, MAX(rge.gen_state_value_id) gen_state_value_id, scsv.item state_value_id
		
		
		FROM (select * from static_data_value sdv_comp_yr where sdv_comp_yr.type_id = 10092) sdv_comp_yr
		CROSS JOIN source_deal_header sdh 
		CROSS APPLY(
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
			WHERE scsv_status.item = sdh.deal_status
		) scsv_status    
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
			AND sdd.buy_sell_flag = 'b'       
			AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
			OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
			THEN @comp_yr_from ELSE 1 END) 
			AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		----ON sdv_comp_yr.code BETWEEN 2012 AND 2012 OR sdv_comp_yr.code < 2012    
		
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id   
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
			 
		LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id  
			AND rge.technology = rg.technology     
			--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)     
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			--AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
				

		LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
		LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			AND gc.state_value_id = srrd.state_value_id
		CROSS APPLY (
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
		) scsv
			--INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
			--	AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			--	AND srrd.state_value_id = srrde.state_value_id
			--CROSS APPLY (
			--	SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
			--	THEN srrde.state_value_id  ELSE rge.state_value_id END
			--) scsv2
			--WHERE sdh.assignment_type_value_id IS NULL
			--AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
			--ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
			-->= CAST(@comp_yr_from AS VARCHAR)
			
			
			
			
			
			
			--AND srrde.tier_type = 300722 and sdv_comp_yr.code = 2012
		GROUP BY sdh.source_deal_header_id, scsv.item, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
		) s
			--and srrde.tier_type = 300472 and srrde.state_value_id = 300731 
			--and YEAR(sdd.term_start) = 2013
			--AND sdv_comp_yr.code = @comp_yr_from
		GROUP BY term_yr, tier_type, technology, gen_state_value_id, state_value_id
		--OPTION(HASH JOIN)
		--return
		
		--select * from #temp_pt5  srrde where srrde.tier_type = 300472 and srrde.state_value_id = 300731 
		
		--select deal volume of sell deals
		
		
		
		SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, max(sdh.status_value_id) status_value_id, scsv.item state_value_id
		INTO #tmp_pt11
		FROM source_deal_header sdh
		CROSS APPLY(
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
			WHERE scsv_status.item = sdh.deal_status
		) scsv_status      
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
			AND sdd.buy_sell_flag = 's'       
		INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
			AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
			AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		--ON sdv_comp_yr.code BETWEEN 2012 AND 2012 OR sdv_comp_yr.code < 2012    
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id   
		
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
		LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id  
			AND rge.technology = rg.technology     
			--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)     
			AND rge.assignment_type = ISNULL(sd.code , rge.assignment_type)
		LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			
		LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			AND gc.state_value_id = srrd.state_value_id
		OUTER APPLY (
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
		) scsv
		LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
			AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			AND srrd.state_value_id = srrde.state_value_id
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	
	
	
		GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), scsv.item
		--OPTION(HASH JOIN)
		
		--select * from #tmp_pt11
		
		--select * from #temp_banked_deals
		--populate banked deals without from and to month filter in eligibility
		INSERT INTO #temp_banked_deals(volume_left, term_yr, tier_type, term_start, technology, gen_state_value_id, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.tier_type, b.term_start
		, b.technology, b.gen_state_value_id, b.state_value_id
		FROM #temp_pt5 b
		OUTER APPLY 
		(
			SELECT deal_volume, term_yr, tier_type
			FROM #tmp_pt11 c
			WHERE c.status_value_id = 5182 
				AND c.tier_type = b.tier_type 
				AND c.term_yr = b.term_yr
				AND c.state_value_id = b.state_value_id
		) s ORDER BY tier_type, term_yr
		--OPTION(HASH JOIN)
		
		CREATE INDEX Index_temp_banked_deals1 ON #temp_banked_deals(term_start)
		CREATE INDEX Index_temp_banked_deals2 ON #temp_banked_deals(rge_from_month)
		CREATE INDEX Index_temp_banked_deals3 ON #temp_banked_deals(rge_to_month)
		
		--select @assigned_state
		--select volume left of buy deals with from and to month filter in eligibility
		SELECT SUM(volume_left) volume_left, SUM(deal_volume) deal_volume, term_yr, tier_type, MAX(status_value_id) status_value_id
		, technology, gen_state_value_id, state_value_id
		--SELECT SUM(sdd.volume_left) volume_left, SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, MAX(sdh.status_value_id) status_value_id
		--, rge.technology, rge.gen_state_value_id, scsv.item state_value_id
		INTO #tmp_pt10
		FROM
		(
		--SELECT (sdd.volume_left),sdd.source_deal_header_id,YEAR(sdd.term_start) term_start,srrd.state_value_id,rge.tier_type rge_tier_type, rg.tier_type rg_tier_type--,gc.tier_type gc_tier_type, srrde.tier_type srrde_tier_type, srrde.state_value_id
		--,gc.source_deal_header_id , sdd.source_deal_detail_id,YEAR(sdd.term_start), rge.technology, rge.gen_state_value_id, rge.state_value_id, srrde.state_value_id, rg.state_value_id, gc.state_value_id
		--select sdv_comp_yr.code,sdd.volume_left, sdd.source_deal_header_id,  COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type
		SELECT MAX(sdd.volume_left) volume_left, MAX(deal_volume) deal_volume, MAX(sdv_comp_yr.code) term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, MAX(sdh.status_value_id) status_value_id
		, MAX(rge.technology) technology, MAX(rge.gen_state_value_id) gen_state_value_id, scsv.item state_value_id
		FROM (select * from static_data_value sdv_comp_yr where sdv_comp_yr.type_id = 10092) sdv_comp_yr
		CROSS JOIN source_deal_header sdh   
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
		CROSS APPLY(
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
			WHERE scsv_status.item = sdh.deal_status
		) scsv_status
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
			AND sdd.buy_sell_flag = 'b'       
			AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
			OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
			THEN @comp_yr_from ELSE 1 END) 
			AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		--ON sdv_comp_yr.code BETWEEN 2012 AND 2012 OR sdv_comp_yr.code < 2012    
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id   
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
		LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id  
			AND rge.technology = rg.technology     
			--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)     
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
	
		INNER JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND ISNULL(srrd.state_value_id, rge.state_value_id) = ISNULL(rge.state_value_id,srrd.state_value_id)
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
		LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			AND gc.state_value_id = srrd.state_value_id
		
		CROSS APPLY (
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
		) scsv
		INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
			AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			AND srrd.state_value_id = srrde.state_value_id
		CROSS APPLY (
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
			THEN srrde.state_value_id  ELSE rge.state_value_id END
		) scsv2
		WHERE sdh.assignment_type_value_id IS NULL
			AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
			ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
			>= CAST(@comp_yr_from AS VARCHAR)
			--AND srrde.tier_type = 300722 and sdv_comp_yr.code = 2012
		GROUP BY sdh.source_deal_header_id, scsv.item, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
		) s 
		
		--and srrde.tier_type = 300472 and srrde.state_value_id = 300731 and YEAR(sdd.term_start) <= 2013
			--AND sdv_comp_yr.code = @comp_yr_from
		GROUP BY term_yr, tier_type, technology, gen_state_value_id, state_value_id
		--OPTION(HASH JOIN)
		--group by sdd.source_deal_detail_id
		--RETURN
		--select * from #tmp_pt10 where tier_type = 300472 and state_value_id = 300731
		 
		--select * from #banked_deals_1
		--populate banked deals with from and to month filter in eligibility
		INSERT INTO #banked_deals_1(volume_left, deal_volume, term_yr, tier_type, technology, gen_state_value_id, state_value_id)
		SELECT SUM(ISNULL(b.volume_left,0)) - SUM(ISNULL(s.deal_volume,0)), SUM(ISNULL(b.deal_volume,0)) deal_volume, b.term_yr, b.tier_type, b.technology, b.gen_state_value_id, b.state_value_id
		FROM #tmp_pt10 b
		OUTER APPLY (
			SELECT deal_volume, term_yr, tier_type
			FROM #tmp_pt11 c
			WHERE c.status_value_id = 5182 
				AND c.tier_type = b.tier_type 
				AND c.term_yr = b.term_yr
				AND c.state_value_id = b.state_value_id
		) s group by b.tier_type, b.term_yr, b.state_value_id,b.technology, b.gen_state_value_id
		ORDER BY tier_type, term_yr
		
		--RETURN
		
		--select * from #banked_deals
		--populate into this table before performing update operation
		INSERT INTO #banked_deals_without_operation(volume_left, term_yr, tier_type, state_value_id)
		SELECT SUM(deal_volume) volume_left, term_yr, tier_type, state_value_id
		FROM #banked_deals_1 GROUP BY tier_type, term_yr, state_value_id
		
		
	
		---update the volume of 1st year with sum of previous years banked
		--UPDATE bd SET bd.volume_left = a.volume_left FROM #banked_deals_1 bd
		--OUTER APPLY 
		--(
		--	SELECT SUM(volume_left) volume_left 
		--	FROM #banked_deals_1  bd2 
		--	WHERE 1=1
		--		AND bd.tier_type = bd2.tier_type 
		--		AND bd2.term_yr <= bd.term_yr
		--	GROUP BY bd2.tier_type
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		--return
		
		-- update the banked (volume left) of first row of data filtered by from and to month of eligibility i.e.#banked_deals_1
		-- with previous years banked i.e. the row with minimum term start 
		-- from banked without filtering the from and to month of eligibility(#temp_banked_deals)	
		-- extra join of technology and gen state is added so that correct value is taken to avoid wrong values in case of:
		-- technology1 may be from 2008 to 2050
		-- while technology2 may be from 2013 to 2050 
		UPDATE bd SET bd.volume_left = a.volume_left 
		--select a.volume_left,bd.*
		FROM #banked_deals_1 bd
		OUTER APPLY (
			SELECT MAX(ISNULL(volume_left,0)) volume_left FROM #temp_banked_deals bd2 
			WHERE 1=1
				AND bd.tier_type = bd2.tier_type 
				AND bd2.term_yr <= bd.term_yr
				AND bd2.technology = bd.technology
				AND bd2.gen_state_value_id = bd.gen_state_value_id
				and bd2.state_value_id = bd.state_value_id
			GROUP BY bd2.tier_type, technology, gen_state_value_id
		) a
		CROSS APPLY(
			SELECT MIN(term_yr) term_yr FROM #banked_deals_1 WHERE tier_type = bd.tier_type
				AND technology = bd.technology AND gen_state_value_id = bd.gen_state_value_id
				and state_value_id = bd.state_value_id
			GROUP BY tier_type, technology, gen_state_value_id
			) bd3
		WHERE bd3.term_yr = bd.term_yr
		
		--select * from #banked_deals
		-- populate into final banked deals table after grouping by tier type and term yr
		INSERT INTO #banked_deals(volume_left, term_yr, tier_type, state_value_id)
		SELECT SUM(volume_left) volume_left, term_yr, tier_type, state_value_id
		FROM #banked_deals_1 GROUP BY tier_type, term_yr,state_value_id
			
	END
	
	IF @report_type = 'a'
	BEGIN
		--select volume left of buy deals grouped only by term yr and without from and to month elgibility filter
		SELECT ISNULL(SUM(sdd.volume_left),0) volume_left, sdv_comp_yr.code term_yr, scsv.item state_value_id
		INTO #temp_pt7
		FROM source_deal_header sdh     
		CROSS APPLY(
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
			WHERE scsv_status.item = sdh.deal_status
		) scsv_status
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
			AND sdd.buy_sell_flag = 'b'       
		INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
			AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
			OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
			THEN @comp_yr_from ELSE 1 END)  
			AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		LEFT JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
			AND rge.technology = rg.technology
			--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(@assignment_type_value_id, rge.assignment_type)
		CROSS APPLY(
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv 
			WHERE scsv.item = rge.state_value_id
		) scsv
		LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			AND  srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id = rge.assignment_type
		LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			AND gc.state_value_id = srrd.state_value_id
		LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
			AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
		LEFT JOIN #target_deal_volume dv ON YEAR(dv.term_start) = sdv_comp_yr.code	
		WHERE sdh.assignment_type_value_id IS NULL
		GROUP BY sdv_comp_yr.code, scsv.item
		--OPTION (HASH JOIN)
		
		--select deal volume of sell deals grouped only term yr
		SELECT ISNULL(SUM(sdd.deal_volume),0) deal_volume, sdv_comp_yr.code term_yr, MAX(sdh.status_value_id) status_value_id, scsv.item state_value_id
		INTO #tmp_pt8
		FROM source_deal_header sdh     
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
			AND sdd.buy_sell_flag = 's'       
		INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
			AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
			AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		LEFT JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
			AND rge.technology = rg.technology
			--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(@assignment_type_value_id, rge.assignment_type)
		OUTER APPLY (
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv 
			WHERE scsv.item = rge.state_value_id
		) scsv
		LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			AND  srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id = rge.assignment_type
		LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			AND gc.state_value_id = srrd.state_value_id
		LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
			AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
		LEFT JOIN #target_deal_volume dv ON YEAR(dv.term_start) = sdv_comp_yr.code
		GROUP BY sdv_comp_yr.code, scsv.item
		--OPTION (HASH JOIN)
		
		--populate banked deals without tier
		INSERT INTO #temp_banked_deals_without_tier(total_volume, term_yr, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.state_value_id
		FROM #temp_pt7 b
		OUTER APPLY
		(
			SELECT deal_volume, term_yr
			FROM #tmp_pt8 c	
			WHERE c.status_value_id = 5182 
				AND c.term_yr = b.term_yr
				AND c.state_value_id = b.state_value_id
		) s 
		--OPTION (HASH JOIN)
		--select * from #tmp_pt9
		
		--select volume left of buy deals grouped by term yr only and with from and to month elgibility filter.
		SELECT ISNULL(SUM(sdd.volume_left),0) volume_left, sdv_comp_yr.code term_yr, scsv.item state_value_id
		INTO #tmp_pt9
		FROM source_deal_header sdh  
		CROSS APPLY(
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
			WHERE scsv_status.item = sdh.deal_status
		) scsv_status   
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
			AND sdd.buy_sell_flag = 'b'       
		INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
			AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
			OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
			THEN @comp_yr_from ELSE 1 END)  
			AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		LEFT JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
			AND rge.technology = rg.technology
			--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(@assignment_type_value_id, rge.assignment_type)
			AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
		OUTER APPLY
		(
			SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv 
			WHERE scsv.item = rge.state_value_id
		) scsv
		LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id = rge.assignment_type
		LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			AND gc.state_value_id = srrd.state_value_id
		LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
			AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
		LEFT JOIN #target_deal_volume dv ON YEAR(dv.term_start) = sdv_comp_yr.code	
		WHERE sdh.assignment_type_value_id IS NULL
		GROUP BY sdv_comp_yr.code, scsv.item
		--OPTION (HASH JOIN)
	
		--populate banked deals without tier and with from and to month eligibility filter
		INSERT INTO #banked_deals_without_tier(total_volume, term_yr, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.state_value_id
		FROM #tmp_pt9 b
		OUTER APPLY(
			SELECT deal_volume, term_yr
			FROM #tmp_pt8 c	
			WHERE c.status_value_id = 5182 
				AND c.term_yr = b.term_yr
				AND c.state_value_id = b.state_value_id
		) s 
		--OPTION (HASH JOIN)
		
		---update the volume of 1st year with sum of previous years banked
		UPDATE bd SET bd.total_volume = a.total_volume FROM #banked_deals_without_tier bd
		OUTER APPLY 
		(
			SELECT SUM(total_volume) total_volume 
			FROM #banked_deals_without_tier  bd2 
			WHERE 1=1
				AND bd2.term_yr <= bd.term_yr
			GROUP BY bd2.term_yr
		) a
		WHERE bd.term_yr = @comp_yr_from
		
		-- update the banked (volume left) of row of first row with previous years banked i.e. the row with minimum term start 
		-- without filtering the from and to month of eligibility		
		-- extra join of technology and gen state is added so that correct value is taken to avoid wrong values in case of:
		-- technology1 may be from 2008 to 2050
		-- while technology2 may be from 2013 to 2050 
		UPDATE bd SET bd.total_volume = a.total_volume 
		FROM #banked_deals_without_tier bd
		OUTER APPLY
		(
			SELECT SUM(total_volume) total_volume, bd2.term_yr 
			FROM #temp_banked_deals_without_tier bd2 
			WHERE 1=1
				AND bd2.term_yr <= bd.term_yr
			GROUP BY bd2.term_yr) a
		CROSS APPLY
		(
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_without_tier 
		) bd3
		WHERE bd3.term_yr = bd.term_yr
			AND bd.term_yr = a.term_yr
	 
	 --select * from #banked_deals_without_tier
	END
	ELSE
	BEGIN
		--select * from #temp_banked_deals_without_tier order by term_yr
		--populate banked deals without tier without from and to month filter in eligibility
		INSERT INTO #temp_banked_deals_without_tier(total_volume, term_yr--, state_value_id
		)
		select a.volume_left  - ISNULL(s.deal_volume,0) volume_left, a.term_yr--, a.state_value_id
		FROM (
			SELECT  SUM(volume_left)  volume_left, term_yr--, state_value_id
			FROM (
			select MAX(sdv_comp_yr.code) term_yr
			--, scsv.item state_value_id
			, MAX(volume_left) volume_left
			--select sdv_comp_yr.code,rge.from_year, rge.to_year,sdd.*
			FROM source_deal_header sdh     
			CROSS APPLY
			(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
				--and sdv_comp_yr.code <= @comp_yr_from
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			INNER JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdd.source_deal_header_id--, scsv.item
			) b group by term_yr--,state_value_id
		) a 
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr
			FROM source_deal_header sdh     
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 's'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = a.term_yr
			GROUP BY sdv_comp_yr.code
		)s 
		
		--OPTION (HASH JOIN)
		
		
		CREATE INDEX Index_temp_banked_deals_without_tier1 ON #temp_banked_deals_without_tier(term_start)
		CREATE INDEX Index_temp_banked_deals_without_tier2 ON #temp_banked_deals_without_tier(rge_from_month)
		CREATE INDEX Index_temp_banked_deals_without_tier3 ON #temp_banked_deals_without_tier(rge_to_month)
		
		
		--SELECT ISNULL(a.volume_left,0) - ISNULL(s.deal_volume,0), a.term_yr
		--FROM (
		--select a.volume_left  - ISNULL(s.deal_volume,0) volume_left, a.term_yr
		--FROM (
		--	SELECT  SUM(volume_left)  volume_left, term_yr
		--	 FROM (
			
		--	select sdv_comp_yr.code term_yr, scsv.item state_value_id, max(volume_left) volume_left
		--	FROM source_deal_header sdh     
		--	CROSS APPLY(
		--	SELECT item from dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
		--	where scsv_status.item = sdh.deal_status
		--	) scsv_status
		--	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
		--		AND sdd.buy_sell_flag = 'b'       
		--	INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
		--		AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
		--		AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		--	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--	INNER JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
		--		AND rge.technology = rg.technology
		--		--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
		--		AND rge.assignment_type = ISNULL(@assignment_type_value_id, rge.assignment_type)
		--		AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
		--	CROSS APPLY(
		--	SELECT item from dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) 
		--	where  item = rge.state_value_id
		--	) scsv 
		--	INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		--		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		--		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		--		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		--	WHERE sdh.assignment_type_value_id IS NULL
		--	GROUP BY sdv_comp_yr.code, scsv.item
		--	) b group by term_yr
		--) a 
		--OUTER APPLY (
		--	SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr
		--	FROM source_deal_header sdh     
		--	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
		--		AND sdd.buy_sell_flag = 's'       
		--	INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
		--		AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
		--		AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
		--	INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		--		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		--		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		--		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		--	WHERE sdh.status_value_id = 5182 
		--		AND sdv_comp_yr.code = a.term_yr
		--	GROUP BY sdv_comp_yr.code
		--)s 
		
		
		
		--return 
		--select * from #banked_deals_without_tier
		--populate banked deals without tier and with from and to month eligibility filter
		INSERT INTO #banked_deals_without_tier(total_volume, term_yr)--, state_value_id)
		select a.volume_left  - ISNULL(s.deal_volume,0) volume_left, a.term_yr--, a.state_value_id
		FROM (
			SELECT  SUM(volume_left)  volume_left, term_yr--, state_value_id
			--select sdd.source_deal_header_id, max(sdd.volume_left)
			FROM (			
			--select sdv_comp_yr.code term_yr--, scsv.item state_value_id
			--, SUM(volume_left) volume_left
			select  sdd.source_deal_header_id, MAX(sdd.volume_left) volume_left, MAX(YEAR(sdd.term_start)) term_yr
			FROM source_deal_header sdh     
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)  
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
			--AND sdv_comp_yr.code = @comp_yr_from
			group by sdd.source_deal_header_id
			--GROUP BY sdv_comp_yr.code--, scsv.item
			) b group by term_yr--, state_value_id
		) a 
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr
			FROM source_deal_header sdh     
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 's'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = a.term_yr
				
			GROUP BY sdv_comp_yr.code
		)s 
		--OPTION (HASH JOIN)
		
		--return
		--select * from #banked_deals_without_tier
		
		---update the volume of 1st year with sum of previous years banked
		--UPDATE bd SET bd.total_volume = a.total_volume 
		--FROM #banked_deals_without_tier bd
		--OUTER APPLY 
		--(
		--	SELECT SUM(ISNULL(total_volume,0)) total_volume 
		--	FROM #banked_deals_without_tier  bd2 
		--	WHERE 1=1
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd2.state_value_id = bd.state_value_id
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		
		--select SUM(ISNULL(total_volume,0)) total_volume FROM #temp_banked_deals_without_tier bd2 GROUP BY bd2.term_yr
		
		-- update the banked (volume left) of row of first row with previous years banked i.e. the row with minimum term start 
		-- without filtering the from and to month of eligibility		
		-- extra join of technology and gen state is added so that correct value is taken to avoid wrong values in case of:
		-- technology1 may be from 2008 to 2050
		-- while technology2 may be from 2013 to 2050 
		UPDATE bd SET bd.total_volume = a.total_volume 
		FROM #banked_deals_without_tier bd
		OUTER APPLY 
		(
			SELECT SUM(ISNULL(total_volume,0)) total_volume, bd2.term_yr 
			FROM #temp_banked_deals_without_tier bd2 
			WHERE 1=1
				AND bd2.term_yr <= bd.term_yr
				--and bd2.state_value_id = bd.state_value_id
			GROUP BY bd2.term_yr, state_value_id
		) a
		CROSS APPLY
		(
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_without_tier 
		) bd3
		WHERE bd3.term_yr = bd.term_yr
			AND bd.term_yr = a.term_yr
			
		--select * from #banked_deals
			
	END 
END

	IF @summary_option = 't'
	BEGIN
	--select * from #temp_banked_deals where tier_type = 300472 and state_value_id = 300731
		--populate banked deals without from and to month elgibility filter and extra grouping of gen state is added to avoid wrong values in case of:
		-- technology1 may be from 2008 to 2050
		-- while technology2 may be from 2013 to 2050 
		INSERT INTO #temp_banked_deals(volume_left, term_yr, tier_type, technology, term_start, gen_state_value_id, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.tier_type, b.technology, b.term_start, b.gen_state_value_id, b.state_value_id
		FROM
		(
			SELECT SUM(volume_left) volume_left, SUM(deal_volume) deal_volume, term_yr, tier_type
			, technology, MAX(term_start) term_start, gen_state_value_id, state_value_id
			FROM
			(
			SELECT MAX(sdd.volume_left) volume_left, MAX(deal_volume) deal_volume, MAX(sdv_comp_yr.code) term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type
			, MAX(rg.technology) technology, YEAR(MAX(sdd.term_start)) term_start, MAX(rg.gen_state_value_id) gen_state_value_id, scsv.item state_value_id
			--select sdh.source_deal_header_id, max(sdd.volume_left),COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type,  scsv.item, max(rg.technology)
			FROM source_deal_header sdh   
			CROSS APPLY(
				SELECT item from dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				where scsv_status.item = sdh.deal_status
			) scsv_status  
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)    
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN (SELECT gen_state_value_id, technology, (tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
				FROM rec_gen_eligibility rge 
				group by gen_state_value_id, technology, tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id) rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdh.source_deal_header_id, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type),  scsv.item
			) s
			GROUP BY term_yr, tier_type, technology, gen_state_value_id, state_value_id
		) b
		OUTER APPLY 
		(
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, rge.technology
			FROM source_deal_header sdh
			INNER JOIN (SELECT * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to OR sdv_comp_yr.code < @comp_yr_from
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start) = sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND rge.tier_type = b.tier_type 
				AND sdv_comp_yr.code = b.term_yr
				AND b.technology = rge.technology
			GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rge.technology
		) s ORDER BY tier_type, term_yr
		
		--RETURN
	
		--select * from #banked_deals_1
		--populate into banked deals with from and to month eligibility filter and extra grouping of gen state is added to avoid wrong values in case of:
		-- technology1 may be from 2008 to 2050
		-- while technology2 may be from 2013 to 2050 
		INSERT INTO #banked_deals_1(volume_left, deal_volume, term_yr, tier_type, technology, gen_state_value_id,
		 state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), ISNULL(b.deal_volume,0) deal_volume, b.term_yr
		, b.tier_type, b.technology, b.gen_state_value_id , b.state_value_id
		FROM (
			SELECT SUM(volume_left) volume_left, SUM(deal_volume) deal_volume, term_yr, 
			tier_type, technology, gen_state_value_id, state_value_id
			FROM
			(
			SELECT MAX(volume_left) volume_left, MAX(deal_volume) deal_volume, MAX(sdv_comp_yr.code) term_yr, 
			COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id, scsv.item state_value_id
			--select sdh.source_deal_header_id, sdd.volume_left, srrde.tier_type
			FROM source_deal_header sdh    
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)   
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN (SELECT gen_state_value_id, technology, (tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
				FROM rec_gen_eligibility rge 
				group by gen_state_value_id, technology, tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id) rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			OUTER APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
				--AND rge.technology = 300601 and sdv_comp_yr.code <= 2013
			GROUP BY sdh.source_deal_header_id, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), scsv.item
			) s
			GROUP BY term_yr, tier_type, technology, gen_state_value_id, state_value_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, rg.technology
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to OR sdv_comp_yr.code < @comp_yr_from
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start) = sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			OUTER APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND rge.tier_type = b.tier_type 
				AND sdv_comp_yr.code = b.term_yr
				AND b.technology = rge.technology
			GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rg.technology
		) s ORDER BY tier_type, term_yr
		
		--return
			--select * from #banked_deals_1
		--populate original values into this table before performing update operation
		INSERT INTO #banked_deals_without_operation(volume_left, term_yr, tier_type, technology)
		SELECT SUM(deal_volume) volume_left, term_yr, tier_type, technology
		FROM #banked_deals_1 GROUP BY tier_type, technology, term_yr
		
		---update the volume of 1st year with sum of previous years banked
		--UPDATE bd SET bd.volume_left = a.volume_left FROM #banked_deals_1 bd
		--OUTER APPLY 
		--(
		--	SELECT SUM(volume_left) volume_left 
		--	FROM #banked_deals_1 bd2 
		--	WHERE 1=1
		--		AND bd.tier_type = bd2.tier_type 
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd.technology = bd2.technology
		--		AND bd.gen_state_value_id = bd2.gen_state_value_id
		--	GROUP BY bd2.tier_type, bd2.technology
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		-- update the banked (volume left) of row of first row with previous years banked i.e. the row with minimum term start 
		-- without filtering the from and to month of eligibility		
		-- extra join of technology and gen state is added so that correct value is taken to avoid wrong values in case of:
		-- technology1 may be from 2008 to 2050
		-- while technology2 may be from 2013 to 2050
		UPDATE bd SET bd.volume_left = a.volume_left 
		FROM #banked_deals_1 bd
		OUTER APPLY 
		(
			SELECT SUM(volume_left) volume_left 
			FROM #temp_banked_deals bd2 
			WHERE 1=1
				AND bd.tier_type = bd2.tier_type 
				AND bd2.term_yr <= bd.term_yr
				AND bd.technology = bd2.technology
				AND bd.gen_state_value_id = bd2.gen_state_value_id
			GROUP BY bd2.tier_type, bd2.technology
		) a
		CROSS APPLY(
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_1 
			WHERE tier_type = bd.tier_type
				AND bd.technology = technology
				AND bd.gen_state_value_id = gen_state_value_id
			GROUP BY tier_type, technology
			) bd3
		WHERE bd3.term_yr = bd.term_yr
		
		--select * from #banked_deals
		--insert into final banked table after grouping by tier, technology and term yr
		INSERT INTO #banked_deals(volume_left, term_yr, tier_type, technology, state_value_id)
		SELECT sum(volume_left) volume_left, term_yr, tier_type, technology, state_value_id
		FROM #banked_deals_1 GROUP BY tier_type, technology, term_yr, state_value_id
		
		--select * from #temp_banked_deals_without_tier
		--populate into banked deals without tier without from and to month filter in eligibility and grouping by technology
		INSERT INTO #temp_banked_deals_without_tier(total_volume, term_yr, technology, term_start)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.technology, b.term_start
		FROM 
		(
			SELECT SUM(ISNULL(volume_left,0)) volume_left,  term_yr, technology, max(term_start) term_start
			FROM 
			(
			SELECT MAX(ISNULL(volume_left,0)) volume_left, MAX(sdv_comp_yr.code) term_yr, MAX(rg.technology) technology,
			YEAR(MAX(sdd.term_start)) term_start, MAX(rge.from_year) rge_from_month, MAX(rge.to_year) rge_to_month
			--SELECT sdh.source_deal_header_id, max(sdd.volume_left), max(srrd.state_value_id)
			FROM source_deal_header sdh  
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status   
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)    
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN (SELECT gen_state_value_id, technology, max(tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
				FROM rec_gen_eligibility rge 
				group by gen_state_value_id, technology, assignment_type, rge.from_year, rge.to_year, state_value_id) rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			INNER JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = ISNULL(rge.state_value_id, srrd.state_value_id)
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL 
				THEN srrde.state_value_id  WHEN rge.tier_type IS NOT NULL THEN rge.state_value_id  ELSE scsv.item END
			) scsv2
	
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
				--and sdv_comp_yr.code <= 2013 and  rg.technology = 300600
				group by sdh.source_deal_header_id
			) s
			GROUP BY term_yr, technology
		) b
		OUTER APPLY 
		(
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, rg.technology
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON (sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to) OR (sdv_comp_yr.code < @comp_yr_from)
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start)  =  sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = b.term_yr
				AND b.technology = rg.technology
			GROUP BY sdv_comp_yr.code, rg.technology
		) s
			
		--return
			
			--select * from #banked_deals_without_tier
		--populate banked deals without tier with from and to month filter in elgibility and grouping by technology
		INSERT INTO #banked_deals_without_tier(total_volume, term_yr, technology)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.technology
		FROM (
			SELECT SUM(ISNULL(volume_left,0)) volume_left, term_yr, technology
			FROM
			(
				SELECT MAX(ISNULL(volume_left,0)) volume_left, MAX(sdv_comp_yr.code) term_yr, MAX(rg.technology) technology
			--select sdh.source_deal_header_id, sdd.volume_left, rge.gen_state_value_id, rge.technology
				FROM source_deal_header sdh  
				INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				CROSS APPLY(
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
					WHERE scsv_status.item = sdh.deal_status
				) scsv_status   
				INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092
					AND sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
					AND sdd.buy_sell_flag = 'b'       
					AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
					OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
					THEN @comp_yr_from ELSE 1 END)    
					AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
				LEFT JOIN (SELECT gen_state_value_id, technology, max(tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
					FROM rec_gen_eligibility rge 
					group by gen_state_value_id, technology,  assignment_type, rge.from_year, rge.to_year, state_value_id) rge ON rge.gen_state_value_id = rg.gen_state_value_id
					AND rge.technology = rg.technology
					--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
					AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
				INNER JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND srrd.state_value_id = rge.state_value_id
				AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
				LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND gc.state_value_id = srrd.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
				) scsv
				INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
					AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
					AND srrd.state_value_id = srrde.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
					THEN srrde.state_value_id  ELSE rge.state_value_id END
				) scsv2
				
				WHERE sdh.assignment_type_value_id IS NULL
					AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
					ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
					>= CAST(@comp_yr_from AS VARCHAR)
					group by sdh.source_deal_header_id
				) s
				--and sdv_comp_yr.code <= 2013 and  rg.technology = 300601--and srrde.tier_type in (300472,300677)
			GROUP BY term_yr, technology
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, rg.technology
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON (sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to) OR (sdv_comp_yr.code < @comp_yr_from)
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start)  =  sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = b.term_yr
				AND b.technology = rg.technology
			GROUP BY sdv_comp_yr.code, rg.technology
		) s
		--return
				
		--UPDATE bd SET bd.total_volume = a.total_volume 
		--FROM #banked_deals_without_tier bd
		--OUTER APPLY 
		--(
		--	SELECT SUM(total_volume) total_volume 
		--	FROM #banked_deals_without_tier  bd2 WHERE 1=1
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd.technology = bd2.technology
		--	GROUP BY bd2.technology
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		
		
		UPDATE bd SET bd.total_volume = a.total_volume 
		FROM #banked_deals_without_tier bd
		OUTER APPLY 
		(
			SELECT SUM(total_volume) total_volume 
			FROM #temp_banked_deals_without_tier bd2 WHERE 1=1
				AND bd2.term_yr <= bd.term_yr
				AND bd.technology = bd2.technology
				--AND bd.state_value_id = bd2.state_value_id
			GROUP BY bd2.term_yr, bd2.technology, bd2.state_value_id
		) a
		CROSS APPLY
		(
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_without_tier WHERE technology = bd.technology
			GROUP BY technology
		) bd3
		WHERE bd3.term_yr = bd.term_yr
		
	END
	
	IF @summary_option = 'p'
	BEGIN
		
		INSERT INTO #temp_banked_deals(volume_left, term_yr, tier_type, technology, gen_state_value_id, term_start,
		 state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.tier_type, b.technology, b.gen_state_value_id
		, b.term_start, b.state_value_id
		FROM
		(
			SELECT SUM(volume_left) volume_left, term_yr, tier_type, technology, gen_state_value_id
			, MAX(term_start) term_start, state_value_id
			FROM
			(
			SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id
			, YEAR(MAX(sdd.term_start)) term_start, scsv.item state_value_id
			FROM source_deal_header sdh    
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)   
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from)) 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdh.source_deal_header_id, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), scsv.item
			) s
			GROUP BY term_yr, state_value_id, tier_type, technology, gen_state_value_id
		) b
		OUTER APPLY
		(
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, rg.technology, rg.gen_state_value_id
			FROM source_deal_header sdh
			INNER JOIN (SELECT * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to OR sdv_comp_yr.code < @comp_yr_from
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start) = sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			OUTER APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND rge.tier_type = b.tier_type 
				AND sdv_comp_yr.code = b.term_yr
				AND b.technology = rge.technology
				AND b.gen_state_value_id = rge.gen_state_value_id
			GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rg.technology, rg.gen_state_value_id
		) s ORDER BY tier_type, term_yr
		
		INSERT INTO #banked_deals_1(volume_left, deal_volume, term_yr, tier_type, technology, gen_state_value_id, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), ISNULL(b.deal_volume,0) deal_volume, b.term_yr,
		 b.tier_type, b.technology, b.gen_state_value_id, b.state_value_id
		FROM (
			SELECT SUM(volume_left) volume_left, SUM(deal_volume) deal_volume, term_yr,
			tier_type, technology, gen_state_value_id
			 , state_value_id
			FROM
			(
			SELECT MAX(volume_left) volume_left, MAX(deal_volume) deal_volume, MAX(sdv_comp_yr.code) term_yr,
			COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id
			, scsv.item state_value_id
			FROM source_deal_header sdh    
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)    
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdh.source_deal_header_id, scsv.item, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			) s
			GROUP BY term_yr, state_value_id, tier_type, technology, gen_state_value_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, rg.technology, rg.gen_state_value_id
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to OR sdv_comp_yr.code < @comp_yr_from
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start) = sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			OUTER APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND rge.tier_type = b.tier_type 
				AND sdv_comp_yr.code = b.term_yr
				AND b.technology = rge.technology
				AND b.gen_state_value_id = rge.gen_state_value_id
			GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rg.technology, rg.gen_state_value_id
		) s ORDER BY tier_type, term_yr
			
		INSERT INTO #banked_deals_without_operation(volume_left, term_yr, tier_type, technology, gen_state_value_id)
		SELECT SUM(deal_volume) volume_left, term_yr, tier_type, technology, gen_state_value_id
		FROM #banked_deals_1 group by tier_type, technology, gen_state_value_id, term_yr
			
		--select * from #banked_deals_1
			
		--UPDATE bd SET bd.volume_left = a.volume_left 
		--FROM #banked_deals bd
		--OUTER APPLY 
		--(
		--	SELECT SUM(volume_left) volume_left 
		--	FROM #banked_deals  bd2 
		--	WHERE 1=1
		--		AND bd.tier_type = bd2.tier_type 
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd.technology = bd2.technology
		--		AND bd.gen_state_value_id = bd2.gen_state_value_id
		--	GROUP BY bd2.tier_type, bd2.technology, bd2.gen_state_value_id
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		UPDATE bd SET bd.volume_left = a.volume_left 
		FROM #banked_deals bd
		OUTER APPLY 
		(
			SELECT SUM(volume_left) volume_left 
			FROM #temp_banked_deals bd2 
		    WHERE 1=1
				AND bd.tier_type = bd2.tier_type 
				AND bd2.term_yr <= bd.term_yr
				AND bd.technology = bd2.technology
				AND bd.gen_state_value_id = bd2.gen_state_value_id
			GROUP BY bd2.tier_type, bd2.technology, bd2.gen_state_value_id) a
		CROSS APPLY
		(
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals 
			WHERE tier_type = bd.tier_type
				AND bd.technology = technology
				AND bd.gen_state_value_id = gen_state_value_id
			GROUP BY tier_type,technology,gen_state_value_id
		) bd3
		WHERE bd3.term_yr = bd.term_yr
		
		INSERT INTO #banked_deals(volume_left, term_yr, tier_type, technology, gen_state_value_id, state_value_id)
		SELECT SUM(volume_left) volume_left, term_yr, tier_type, technology, gen_state_value_id, state_value_id
		FROM #banked_deals_1 GROUP BY tier_type, technology, gen_state_value_id, term_yr, state_value_id
		
		--select * from #temp_banked_deals_without_tier
		INSERT INTO #temp_banked_deals_without_tier(total_volume, term_yr, technology, gen_state_value_id, term_start)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.technology, b.gen_state_value_id
		, b.term_start
		FROM 
		(
			SELECT SUM(volume_left) volume_left, term_yr, technology, gen_state_value_id,
			MAX(term_start) term_start
			FROM
			(
				SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id,
				YEAR(MAX(sdd.term_start)) term_start
				FROM source_deal_header sdh     
				CROSS APPLY(
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
					WHERE scsv_status.item = sdh.deal_status
				) scsv_status
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
					AND sdd.buy_sell_flag = 'b'       
				INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
					AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
					OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
					THEN @comp_yr_from ELSE 1 END)     
					AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from)) 
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
				LEFT JOIN (
							SELECT gen_state_value_id, technology, max(tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
							FROM rec_gen_eligibility rge 
							group by gen_state_value_id, technology,  assignment_type, rge.from_year, rge.to_year, state_value_id
						) rge ON rge.gen_state_value_id = rg.gen_state_value_id
					AND rge.technology = rg.technology
					--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
					AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
				LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND srrd.state_value_id = rge.state_value_id
				AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
				LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND gc.state_value_id = srrd.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
				) scsv
				INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
					AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
					AND srrd.state_value_id = srrde.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
					THEN srrde.state_value_id  ELSE rge.state_value_id END
				) scsv2
				INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				WHERE sdh.assignment_type_value_id IS NULL
					AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
					ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
					>= CAST(@comp_yr_from AS VARCHAR)
				GROUP BY sdh.source_deal_header_id
			) s
			GROUP BY term_yr, technology, gen_state_value_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, rg.technology, rg.gen_state_value_id
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON (sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to) OR (sdv_comp_yr.code < @comp_yr_from)
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start)  =  sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = b.term_yr
				AND b.technology = rg.technology
				AND b.gen_state_value_id = rg.gen_state_value_id
			GROUP BY sdv_comp_yr.code, rg.technology, rg.gen_state_value_id
		) s
		
		--select * from #banked_deals_without_tier
		INSERT INTO #banked_deals_without_tier(total_volume, term_yr, technology, gen_state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.technology, b.gen_state_value_id 
		FROM (
			SELECT SUM(volume_left) volume_left, term_yr, technology, gen_state_value_id
			FROM
			(
				SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id
				FROM source_deal_header sdh     
				CROSS APPLY(
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
					WHERE scsv_status.item = sdh.deal_status
				) scsv_status
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
					AND sdd.buy_sell_flag = 'b'       
				INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
					AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
					OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
					THEN @comp_yr_from ELSE 1 END)     
					AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
				LEFT JOIN (
								SELECT gen_state_value_id, technology, max(tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
								FROM rec_gen_eligibility rge 
								group by gen_state_value_id, technology,  assignment_type, rge.from_year, rge.to_year, state_value_id
							) rge ON rge.gen_state_value_id = rg.gen_state_value_id
					AND rge.technology = rg.technology
					--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
					AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
				LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND srrd.state_value_id = rge.state_value_id
					AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
				LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND gc.state_value_id = srrd.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
				) scsv
				INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
					AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
					AND srrd.state_value_id = srrde.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
					THEN srrde.state_value_id  ELSE rge.state_value_id END
				) scsv2
				INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				WHERE sdh.assignment_type_value_id IS NULL
					AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
					ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
					>= CAST(@comp_yr_from AS VARCHAR)
				GROUP BY sdh.source_deal_header_id
				) s
			GROUP BY term_yr, technology, gen_state_value_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, rg.technology, rg.gen_state_value_id
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON (sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to) OR (sdv_comp_yr.code < @comp_yr_from)
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start)  =  sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = b.term_yr
				AND b.technology = rg.technology
				AND b.gen_state_value_id = rg.gen_state_value_id
			GROUP BY sdv_comp_yr.code, rg.technology, rg.gen_state_value_id
		) s
		
		--UPDATE bd SET bd.total_volume = a.total_volume 
		--FROM #banked_deals_without_tier bd
		--OUTER APPLY (
		--	SELECT SUM(total_volume) total_volume 
		--	FROM #banked_deals_without_tier bd2 
		--	WHERE 1=1
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd.technology = bd2.technology
		--		AND bd.gen_state_value_id = bd2.gen_state_value_id
		--	GROUP BY bd2.technology
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		UPDATE bd SET bd.total_volume = a.total_volume 
		FROM #banked_deals_without_tier bd
		OUTER APPLY (
			SELECT SUM(total_volume) total_volume 
			FROM #temp_banked_deals_without_tier bd2 
			WHERE 1=1
				AND bd2.term_yr <= bd.term_yr
				AND bd.technology = bd2.technology
				AND bd.gen_state_value_id = bd2.gen_state_value_id
				--AND bd.state_value_id = bd2.state_value_id
			GROUP BY bd2.term_yr, bd2.technology, bd2.gen_state_value_id, bd2.state_value_id
		) a
		CROSS APPLY (
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_without_tier 
			WHERE technology = bd.technology
				AND bd.gen_state_value_id = gen_state_value_id
			GROUP BY technology, gen_state_value_id
		) bd3
		WHERE bd3.term_yr = bd.term_yr
		
	END
	IF @summary_option ='g' 
	BEGIN
	--select * from #temp_banked_deals
		INSERT INTO #temp_banked_deals(volume_left, term_yr, tier_type, generator, term_start, technology, gen_state_value_id, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.tier_type, b.generator_id,
		b.term_start, b.technology, b.gen_state_value_id, b.state_value_id
		FROM (
			SELECT SUM(volume_left) volume_left, term_yr, tier_type, generator_id,
			MAX(term_start) term_start, technology, gen_state_value_id, state_value_id
			FROM
			(
			SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, MAX(rg.generator_id) generator_id,
			YEAR(MAX(sdd.term_start)) term_start, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id, scsv.item state_value_id
			FROM source_deal_header sdh     
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)     
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdh.source_deal_header_id, scsv.item, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			) s
			GROUP BY term_yr, state_value_id, tier_type, generator_id, technology, gen_state_value_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, rg.generator_id
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to OR sdv_comp_yr.code < @comp_yr_from
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start) = sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			OUTER APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND rge.tier_type = b.tier_type 
				AND sdv_comp_yr.code = b.term_yr
				AND b.generator_id = rg.generator_id
			GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rg.generator_id
		) s ORDER BY tier_type, term_yr
		
		--return
		
		--select * from #banked_deals_1
		INSERT INTO #banked_deals_1(volume_left, deal_volume, term_yr, tier_type, generator, technology, gen_state_value_id, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), ISNULL(b.deal_volume,0) deal_volume, 
		b.term_yr, b.tier_type, b.generator_id, b.technology, b.gen_state_value_id, b.state_value_id
		FROM (
			SELECT SUM(volume_left) volume_left, SUM(deal_volume) deal_volume, term_yr, tier_type,
			generator_id, technology, gen_state_value_id, state_value_id
			FROM
			(
			SELECT MAX(volume_left) volume_left, MAX(deal_volume) deal_volume, MAX(sdv_comp_yr.code) term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type,
			MAX(rg.generator_id) generator_id, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id, scsv.item state_value_id
			FROM source_deal_header sdh     
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)    
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdh.source_deal_header_id, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), scsv.item
			) s
			GROUP BY term_yr, state_value_id, tier_type, generator_id, technology, gen_state_value_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, rg.generator_id
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to OR sdv_comp_yr.code < @comp_yr_from
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start) = sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			OUTER APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND rge.tier_type = b.tier_type 
				AND sdv_comp_yr.code = b.term_yr
				AND b.generator_id = rg.generator_id
			GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rg.generator_id
		) s ORDER BY tier_type, term_yr
		
		INSERT INTO #banked_deals_without_operation(volume_left, term_yr, tier_type, generator)
		SELECT SUM(deal_volume) volume_left, term_yr, tier_type, generator
		FROM #banked_deals_1 group by tier_type, generator, term_yr
			
		--UPDATE bd SET bd.volume_left = a.volume_left FROM #banked_deals_1 bd
		--OUTER APPLY (
		--	SELECT SUM(volume_left) volume_left 
		--	FROM #banked_deals_1 bd2 
		--	WHERE 1=1
		--		AND bd.tier_type = bd2.tier_type 
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd.generator = bd2.generator
		--		AND bd.technology = bd2.technology
		--		AND bd.gen_state_value_id = bd2.gen_state_value_id
		--	GROUP BY bd2.generator
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		UPDATE bd SET bd.volume_left = a.volume_left FROM #banked_deals_1 bd
		OUTER APPLY (
			SELECT SUM(volume_left) volume_left 
			FROM #temp_banked_deals bd2 
			WHERE 1=1
				AND bd.tier_type = bd2.tier_type 
				AND bd2.term_yr <= bd.term_yr
				AND bd.generator = bd2.generator
				AND bd.technology = bd2.technology
				AND bd.gen_state_value_id = bd2.gen_state_value_id
			GROUP BY bd2.tier_type, bd2.generator
		) a
		CROSS APPLY(
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_1 
			WHERE tier_type = bd.tier_type
				AND bd.generator = generator
				AND bd.technology = technology
				AND bd.gen_state_value_id = gen_state_value_id
			GROUP BY tier_type,generator
		) bd3
		WHERE bd3.term_yr = bd.term_yr
		
		--select * from #banked_deals
		INSERT INTO #banked_deals(volume_left, term_yr, tier_type, generator, state_value_id)
		SELECT SUM(volume_left) volume_left, term_yr, tier_type, generator, state_value_id
		FROM #banked_deals_1 GROUP BY tier_type, generator, term_yr, state_value_id
			
		INSERT INTO #temp_banked_deals_without_tier(total_volume, term_yr, generator, term_start)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.generator_id,
		b.term_start
		FROM (
			SELECT SUM(volume_left) volume_left, term_yr, generator_id, MAX(term_start) term_start
			FROM
			(
				SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, MAX(rg.generator_id) generator_id,
				YEAR(MAX(sdd.term_start)) term_start
				FROM source_deal_header sdh    
				CROSS APPLY(
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
					WHERE scsv_status.item = sdh.deal_status
				) scsv_status 
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
					AND sdd.buy_sell_flag = 'b'       
				INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
					AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
					OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
					THEN @comp_yr_from ELSE 1 END)     
					AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
				LEFT JOIN (
								SELECT gen_state_value_id, technology, max(tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
								FROM rec_gen_eligibility rge 
								group by gen_state_value_id, technology,  assignment_type, rge.from_year, rge.to_year, state_value_id
							) rge ON rge.gen_state_value_id = rg.gen_state_value_id
					AND rge.technology = rg.technology
					--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
					AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
				LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND srrd.state_value_id = rge.state_value_id
				AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
				LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND gc.state_value_id = srrd.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
				) scsv
				INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
					AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
					AND srrd.state_value_id = srrde.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
					THEN srrde.state_value_id  ELSE rge.state_value_id END
				) scsv2
				INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				WHERE sdh.assignment_type_value_id IS NULL
					AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
					ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
					>= CAST(@comp_yr_from AS VARCHAR)
				group by sdh.source_deal_header_id
				) s
			GROUP BY term_yr, generator_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, rg.generator_id
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON (sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to) OR (sdv_comp_yr.code < @comp_yr_from)
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start)  =  sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = b.term_yr
				AND b.generator_id = rg.generator_id
			GROUP BY sdv_comp_yr.code, rg.generator_id
		) s
			
		INSERT INTO #banked_deals_without_tier(total_volume, term_yr, generator)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.generator_id
		FROM (
			SELECT SUM(volume_left) volume_left, term_yr, generator_id
			FROM
			(
				SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, MAX(rg.generator_id) generator_id
				FROM source_deal_header sdh     
				CROSS APPLY(
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
					WHERE scsv_status.item = sdh.deal_status
				) scsv_status
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
					AND sdd.buy_sell_flag = 'b'       
				INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
					AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
					OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
					THEN @comp_yr_from ELSE 1 END)     
					AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
				LEFT JOIN	(
								SELECT gen_state_value_id, technology, max(tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
								FROM rec_gen_eligibility rge 
								group by gen_state_value_id, technology,  assignment_type, rge.from_year, rge.to_year, state_value_id
							) rge ON rge.gen_state_value_id = rg.gen_state_value_id
					AND rge.technology = rg.technology
					--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
					AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
				LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND srrd.state_value_id = rge.state_value_id
				AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
				LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND gc.state_value_id = srrd.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
				) scsv
				INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
					AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
					AND srrd.state_value_id = srrde.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
					THEN srrde.state_value_id  ELSE rge.state_value_id END
				) scsv2
				INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				WHERE sdh.assignment_type_value_id IS NULL
					AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
					ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
					>= CAST(@comp_yr_from AS VARCHAR)
				group by sdh.source_deal_header_id
				) s
			GROUP BY term_yr, generator_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, rg.generator_id
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON (sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to) OR (sdv_comp_yr.code < @comp_yr_from)
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start)  =  sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = b.term_yr
				AND b.generator_id = rg.generator_id
			GROUP BY sdv_comp_yr.code, rg.generator_id
		) s
		
		--UPDATE bd SET bd.total_volume = a.total_volume 
		--FROM #banked_deals_without_tier bd
		--OUTER APPLY (
		--	SELECT SUM(total_volume) total_volume 
		--	FROM #banked_deals_without_tier bd2 
		--	WHERE 1=1
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd.generator = bd2.generator
		--	GROUP BY bd2.generator
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		UPDATE bd SET bd.total_volume = a.total_volume 
		FROM #banked_deals_without_tier bd
		OUTER APPLY (
			SELECT SUM(total_volume) total_volume 
			FROM #temp_banked_deals_without_tier bd2 
			WHERE 1=1
				AND bd2.term_yr <= bd.term_yr
				AND bd.generator = bd2.generator
				--AND bd.state_value_id = bd2.state_value_id
			GROUP BY bd2.term_yr, bd2.generator, bd2.state_value_id
		) a
		CROSS APPLY(
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_without_tier 
			WHERE bd.generator = generator
			GROUP BY generator
		) bd3
		WHERE bd3.term_yr = bd.term_yr
		
	END
	IF @summary_option = 'h'
	BEGIN
	--select * from #temp_banked_deals
		INSERT INTO #temp_banked_deals(volume_left, term_yr, tier_type, generator, generator_group, term_start, technology, gen_state_value_id, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.tier_type, b.generator_id, b.generator_group_id,
		b.term_start, b.technology, b.gen_state_value_id, b.state_value_id
		FROM (
			SELECT SUM(volume_left) volume_left, term_yr, tier_type, generator_id, ISNULL(generator_group_id,-1) generator_group_id,
			MAX(term_start) term_start, technology, gen_state_value_id, state_value_id
			FROM
			(
			SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, MAX(rg.generator_id) generator_id, MAX(ISNULL(rgg.generator_group_id,-1)) generator_group_id,
			YEAR(MAX(sdd.term_start)) term_start, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id, scsv.item state_value_id
			--select rg.generator_id,rgg.generator_group_id, sdh.source_deal_header_id, sdd.volume_left
			FROM #ssbm ssbm    
			INNER JOIN source_deal_header sdh ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.[type_id] = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)     
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from)) 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			LEFT JOIN rec_generator_group rgg ON ISNULL(rgg.generator_group_id,-1) = ISNULL(rg.generator_group_name,-1)
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE COALESCE(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdh.source_deal_header_id, scsv.item, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			) s
			GROUP BY term_yr, state_value_id, tier_type, generator_id, ISNULL(generator_group_id,-1), technology, gen_state_value_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, rg.generator_id, ISNULL(rgg.generator_group_id,-1) generator_group_id
			FROM #ssbm ssbm    
			INNER JOIN source_deal_header sdh ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 's'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			LEFT JOIN rec_generator_group rgg ON ISNULL(rgg.generator_group_id,-1) = ISNULL(rg.generator_group_name,-1)
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			OUTER APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			WHERE sdh.status_value_id = 5182 
				AND rge.tier_type = b.tier_type 
				AND sdv_comp_yr.code = b.term_yr
				AND b.generator_id = rg.generator_id
				AND ISNULL(b.generator_group_id,-1) = ISNULL(rgg.generator_group_id,-1)
			GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rg.generator_id, ISNULL(rgg.generator_group_id,-1)
		) s ORDER BY tier_type, term_yr
	
		--return
		
		--select * from #banked_deals_1
		INSERT INTO #banked_deals_1(volume_left, deal_volume, term_yr, tier_type, generator, generator_group, technology, gen_state_value_id, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), ISNULL(b.deal_volume,0) deal_volume, b.term_yr, b.tier_type,
		b.generator_id, b.generator_group_id, b.technology, b.gen_state_value_id, b.state_value_id
		FROM (
			SELECT SUM(volume_left) volume_left, SUM(deal_volume) deal_volume, term_yr, tier_type,
			generator_id, ISNULL(generator_group_id,-1) generator_group_id, technology, gen_state_value_id, state_value_id
			FROM
			(
			SELECT MAX(volume_left) volume_left, MAX(deal_volume) deal_volume, MAX(sdv_comp_yr.code) term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type,
			MAX(rg.generator_id) generator_id, MAX(ISNULL(rgg.generator_group_id,-1)) generator_group_id, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id, scsv.item state_value_id
			FROM #ssbm ssbm    
			INNER JOIN source_deal_header sdh ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)     
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			LEFT JOIN rec_generator_group rgg ON ISNULL(rgg.generator_group_id,-1) = ISNULL(rg.generator_group_name,-1)
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE COALESCE(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdh.source_deal_header_id, scsv.item, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			) s
			GROUP BY term_yr, state_value_id, tier_type, generator_id, ISNULL(generator_group_id,-1), technology, gen_state_value_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, rg.generator_id, ISNULL(rgg.generator_group_id,-1) generator_group_id
			FROM #ssbm ssbm    
			INNER JOIN source_deal_header sdh ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 's'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			LEFT JOIN rec_generator_group rgg ON ISNULL(rgg.generator_group_id,-1) = ISNULL(rg.generator_group_name,-1)
		left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			OUTER APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			WHERE sdh.status_value_id = 5182 
				AND rge.tier_type = b.tier_type 
				AND sdv_comp_yr.code = b.term_yr
				AND b.generator_id = rg.generator_id
				AND ISNULL(b.generator_group_id,-1) = ISNULL(rgg.generator_group_id,-1)
			GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rg.generator_id, ISNULL(rgg.generator_group_id,-1)
		) s ORDER BY tier_type, term_yr
		
		--RETURN
		
		INSERT INTO #banked_deals_without_operation(volume_left, term_yr, tier_type, generator, generator_group)
		SELECT SUM(deal_volume) volume_left, term_yr, tier_type, generator, generator_group
		FROM #banked_deals_1 GROUP BY tier_type, generator, generator_group, term_yr
		
		--UPDATE bd SET bd.volume_left = a.volume_left 
		--FROM #banked_deals_1 bd
		--OUTER APPLY (
		--	SELECT SUM(volume_left) volume_left FROM #banked_deals_1 bd2 
		--	WHERE 1=1
		--		AND bd.tier_type = bd2.tier_type 
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd2.generator = bd.generator
		--		AND bd2.technology = bd.technology
		--		AND bd2.gen_state_value_id = bd.gen_state_value_id
		--		AND ISNULL(bd.generator_group,-1) = ISNULL(bd2.generator_group,-1)
		--	GROUP BY bd2.generator_group
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		UPDATE bd SET bd.volume_left = a.volume_left 
		FROM #banked_deals_1 bd
		OUTER APPLY (
			SELECT SUM(volume_left) volume_left FROM #temp_banked_deals bd2 
			WHERE 1=1
				AND bd.tier_type = bd2.tier_type 
				AND bd2.term_yr <= bd.term_yr
				AND bd2.generator = bd.generator
				AND bd2.technology = bd.technology
				AND bd2.gen_state_value_id = bd.gen_state_value_id
				AND ISNULL(bd.generator_group,-1) = ISNULL(bd2.generator_group,-1)
			GROUP BY bd2.tier_type, bd2.generator_group
		) a
		CROSS APPLY(
			SELECT MIN(term_yr) term_yr FROM #banked_deals_1 
			WHERE tier_type = bd.tier_type
				AND generator = bd.generator
				AND technology = bd.technology
				AND gen_state_value_id = bd.gen_state_value_id
				AND ISNULL(bd.generator_group,-1) = ISNULL(generator_group,-1)
			GROUP BY tier_type,generator_group
		) bd3
		WHERE bd3.term_yr = bd.term_yr
		
		--select * from #banked_deals
		INSERT INTO #banked_deals(volume_left, term_yr, tier_type, generator, generator_group, state_value_id)
		SELECT SUM(volume_left) volume_left, term_yr, tier_type, generator, generator_group, state_value_id
		FROM #banked_deals_1 GROUP BY tier_type, generator, generator_group, term_yr, state_value_id
		
		--select * from #banked_deals where term_yr = 2008
		INSERT INTO #temp_banked_deals_without_tier(total_volume, term_yr, generator, generator_group, term_start)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.generator_id, b.generator_group_id,
		b.term_start
		FROM (
			SELECT SUM(volume_left) volume_left,  term_yr, generator_id, ISNULL(generator_group_id,-1) generator_group_id,
			MAX(term_start) term_start
			FROM
			(
				SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, MAX(rg.generator_id) generator_id, MAX(rgg.generator_group_id) generator_group_id ,
				YEAR(MAX(sdd.term_start)) term_start
				FROM #ssbm ssbm    
				INNER JOIN source_deal_header sdh ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				CROSS APPLY(
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
					WHERE scsv_status.item = sdh.deal_status
				) scsv_status
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
					AND sdd.buy_sell_flag = 'b'       
				INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
					AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
					OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
					THEN @comp_yr_from ELSE 1 END)     
					AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from)) 
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
				LEFT JOIN	(
								SELECT gen_state_value_id, technology, max(tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
								FROM rec_gen_eligibility rge 
								group by gen_state_value_id, technology,  assignment_type, rge.from_year, rge.to_year, state_value_id
							) rge ON rge.gen_state_value_id = rg.gen_state_value_id
					AND rge.technology = rg.technology
					--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
					AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
				LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND srrd.state_value_id = rge.state_value_id
				AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
				LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND gc.state_value_id = srrd.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
				) scsv
				INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
					AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
					AND srrd.state_value_id = srrde.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
					THEN srrde.state_value_id  ELSE rge.state_value_id END
				) scsv2
				LEFT JOIN rec_generator_group rgg ON rgg.generator_group_id = rg.generator_group_name
				WHERE sdh.assignment_type_value_id IS NULL
					AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
					ELSE ISNULL(YEAR(gc.contract_expiration_date),@comp_yr_from) END
					>= CAST(@comp_yr_from AS VARCHAR)
				GROUP BY sdh.source_deal_header_id
			) s
			GROUP BY term_yr, generator_id, ISNULL(generator_group_id,-1)
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, rg.generator_id, ISNULL(rgg.generator_group_id,-1) generator_group_id
			FROM #ssbm ssbm    
			INNER JOIN source_deal_header sdh ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 's'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			LEFT JOIN rec_generator_group rgg ON rgg.generator_group_id = rg.generator_group_name
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = b.term_yr
				AND b.generator_id = rg.generator_id
				AND COALESCE(b.generator_group_id,-1) = ISNULL(rgg.generator_group_id,-1)
			GROUP BY sdv_comp_yr.code, rg.generator_id, ISNULL(rgg.generator_group_id,-1)
		) s
		
		INSERT INTO #banked_deals_without_tier(total_volume, term_yr, generator, generator_group)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.generator_id, b.generator_group_id 
		FROM (
			SELECT SUM(volume_left) volume_left, term_yr, generator_id, ISNULL(generator_group_id,-1) generator_group_id
			FROM
			(
				SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, MAX(rg.generator_id) generator_id, MAX(ISNULL(rgg.generator_group_id,-1)) generator_group_id
				FROM #ssbm ssbm    
				INNER JOIN source_deal_header sdh ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				CROSS APPLY(
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
					WHERE scsv_status.item = sdh.deal_status
				) scsv_status
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
					AND sdd.buy_sell_flag = 'b'       
				INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
					AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
					OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
					THEN @comp_yr_from ELSE 1 END)     
					AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from)) 
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
				LEFT JOIN	(
								SELECT gen_state_value_id, technology, max(tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
								FROM rec_gen_eligibility rge 
								group by gen_state_value_id, technology,  assignment_type, rge.from_year, rge.to_year, state_value_id
							) rge ON rge.gen_state_value_id = rg.gen_state_value_id
					AND rge.technology = rg.technology
					--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
					AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
				LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND srrd.state_value_id = rge.state_value_id
				AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
				LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND gc.state_value_id = srrd.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
				) scsv
				INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
					AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
					AND srrd.state_value_id = srrde.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
					THEN srrde.state_value_id  ELSE rge.state_value_id END
				) scsv2
				LEFT JOIN rec_generator_group rgg ON rgg.generator_group_id = rg.generator_group_name
				WHERE sdh.assignment_type_value_id IS NULL
					AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
					ELSE COALESCE(YEAR(gc.contract_expiration_date),@comp_yr_from) END
					>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdh.source_deal_header_id
			) s
			GROUP BY term_yr, generator_id, ISNULL(generator_group_id,-1)
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, rg.generator_id, ISNULL(rgg.generator_group_id,-1) generator_group_id
			FROM #ssbm ssbm    
			INNER JOIN source_deal_header sdh ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 's'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code  
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			LEFT JOIN rec_generator_group rgg ON rgg.generator_group_id = rg.generator_group_name
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = b.term_yr
				AND b.generator_id = rg.generator_id
				AND ISNULL(b.generator_group_id,-1) = ISNULL(rgg.generator_group_id,-1)
			GROUP BY sdv_comp_yr.code, rg.generator_id, ISNULL(rgg.generator_group_id,-1)
		) s
		
		--UPDATE bd SET bd.total_volume = a.total_volume 
		--FROM #banked_deals_without_tier bd
		--OUTER APPLY (
		--	SELECT SUM(total_volume) total_volume 
		--	FROM #banked_deals_without_tier bd2 
		--	WHERE 1=1
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd.generator = bd2.generator
		--		AND ISNULL(bd.generator_group,-1) = ISNULL(bd2.generator_group,-1)
		--	GROUP BY bd2.generator_group
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		UPDATE bd SET bd.total_volume = a.total_volume 
		FROM #banked_deals_without_tier bd
		OUTER APPLY (
			SELECT SUM(total_volume) total_volume 
			FROM #temp_banked_deals_without_tier bd2 
			WHERE 1=1
				AND bd2.term_yr <= bd.term_yr
				AND bd.generator = bd2.generator
				AND ISNULL(bd.generator_group,-1) = ISNULL(bd2.generator_group,-1)
				--AND bd.state_value_id = bd2.state_value_id
			GROUP BY bd2.term_yr, bd2.generator_group, bd2.state_value_id
		) a
		CROSS APPLY (
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_without_tier 
			WHERE bd.generator = generator
				AND ISNULL(bd.generator_group,-1) = ISNULL(generator_group,-1)
			GROUP BY generator_group
		) bd3
		WHERE bd3.term_yr = bd.term_yr
	END

	IF @summary_option = 'e'
	BEGIN
	
	--select * from #temp_banked_deals
		INSERT INTO #temp_banked_deals(volume_left, term_yr, tier_type, generator, env_product, term_start, state_value_id, technology, gen_state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.tier_type, b.generator_id, b.source_curve_def_id,
		b.term_start, b.state_value_id, b.technology, b.gen_state_value_id
		FROM (
			SELECT SUM(volume_left) volume_left, term_yr, tier_type, MAX(generator_id) generator_id, source_curve_def_id,
			MAX(term_start) term_start, state_value_id, technology, gen_state_value_id
			FROM
			(
			SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, MAX(rg.generator_id) generator_id, MAX(rg.source_curve_def_id) source_curve_def_id,
			MAX(term_start) term_start, scsv.item state_value_id, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id
			FROM source_deal_header sdh     
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = CAST(@comp_yr_from AS VARCHAR)
				THEN CAST(@comp_yr_from AS VARCHAR) ELSE CAST(1 AS VARCHAR) END)    
				AND (YEAR(sdd.term_start) BETWEEN CAST(@comp_yr_from AS VARCHAR) AND CAST(@comp_yr_to AS VARCHAR) OR (YEAR(sdd.term_start) < CAST(@comp_yr_from AS VARCHAR))) 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE COALESCE(YEAR(gc.contract_expiration_date),CAST(@comp_yr_from AS VARCHAR)) END
				>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdh.source_deal_header_id, scsv.item, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			) s
			GROUP BY term_yr, state_value_id, technology, gen_state_value_id, tier_type, source_curve_def_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, max(rg.generator_id) generator_id, rg.source_curve_def_id
			--SELECT deal_volume
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON sdv_comp_yr.code BETWEEN CAST(@comp_yr_from AS VARCHAR) AND CAST(@comp_yr_to AS VARCHAR) OR sdv_comp_yr.code < CAST(@comp_yr_from AS VARCHAR)
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN CAST(srrd.from_year AS VARCHAR) AND CAST(srrd.to_year AS VARCHAR)
			--AND srrd.state_value_id = rge.state_value_id
				AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			OUTER APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND rge.tier_type = b.tier_type 
				AND sdv_comp_yr.code = b.term_yr
				AND b.source_curve_def_id = rg.source_curve_def_id
			GROUP BY sdv_comp_yr.code, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rg.source_curve_def_id
		) s ORDER BY tier_type, term_yr
		--return
		
		--select * from #banked_deals_1
		INSERT INTO #banked_deals_1(volume_left, deal_volume, term_yr, tier_type, generator, env_product, technology, gen_state_value_id, state_value_id)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), ISNULL(b.deal_volume,0) deal_volume, 
		b.term_yr, b.tier_type, b.generator_id, b.source_curve_def_id, b.technology, b.gen_state_value_id, b.state_value_id
		FROM (
			SELECT SUM(volume_left) volume_left, SUM(deal_volume) deal_volume, term_yr, tier_type,
			MAX(generator_id) generator_id, source_curve_def_id, technology, gen_state_value_id, state_value_id
			FROM
			(
			SELECT MAX(volume_left) volume_left, MAX(deal_volume) deal_volume, MAX(sdv_comp_yr.code) term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type,
			MAX(rg.generator_id) generator_id, MAX(rg.source_curve_def_id) source_curve_def_id, MAX(rg.technology) technology, MAX(rg.gen_state_value_id) gen_state_value_id, scsv.item state_value_id
			FROM source_deal_header sdh     
			CROSS APPLY(
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
				WHERE scsv_status.item = sdh.deal_status
			) scsv_status
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
				AND sdd.buy_sell_flag = 'b'       
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
				AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
				OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
				THEN @comp_yr_from ELSE 1 END)     
				AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			CROSS APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
				THEN srrde.state_value_id  ELSE rge.state_value_id END
			) scsv2
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.assignment_type_value_id IS NULL
				AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
				ELSE COALESCE(YEAR(gc.contract_expiration_date),@comp_yr_from) END
				>= CAST(@comp_yr_from AS VARCHAR)
			GROUP BY sdh.source_deal_header_id,  scsv.item, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
			) s
			GROUP BY term_yr, state_value_id, tier_type, source_curve_def_id, technology, gen_state_value_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type) tier_type, MAX(rg.generator_id) generator_id, rg.source_curve_def_id
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to OR sdv_comp_yr.code < @comp_yr_from
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start) = sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON rge.gen_state_value_id = rg.gen_state_value_id
				AND rge.technology = rg.technology
				--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = rge.state_value_id
			AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = srrd.state_value_id
			OUTER APPLY (
				SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
			) scsv
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
				AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
				AND srrd.state_value_id = srrde.state_value_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND rge.tier_type = b.tier_type 
				AND sdv_comp_yr.code = b.term_yr
				AND b.source_curve_def_id = rg.source_curve_def_id
			GROUP BY sdv_comp_yr.code, scsv.item, COALESCE(gc.tier_type, rg.tier_type, rge.tier_type), rg.source_curve_def_id
		) s ORDER BY tier_type, term_yr
		
		--RETURN
		
		INSERT INTO #banked_deals_without_operation(volume_left, term_yr, tier_type, env_product)
		SELECT SUM(deal_volume) volume_left, term_yr, tier_type, env_product
		FROM #banked_deals_1 GROUP BY tier_type, env_product, term_yr
		
		--UPDATE bd SET bd.volume_left = a.volume_left 
		--FROM #banked_deals_1 bd
		--OUTER APPLY (
		--	SELECT SUM(volume_left) volume_left 
		--	FROM #banked_deals_1 bd2 
		--	WHERE 1=1
		--		AND bd.tier_type = bd2.tier_type 
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd.env_product = bd2.env_product
		--		AND bd2.technology = bd.technology
		--		AND bd2.gen_state_value_id = bd.gen_state_value_id
		--	GROUP BY bd2.tier_type, bd2.env_product
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		
		
		UPDATE bd SET bd.volume_left = a.volume_left 
		FROM #banked_deals_1 bd
		OUTER APPLY (
			SELECT SUM(volume_left) volume_left
			FROM #temp_banked_deals bd2
			WHERE 1=1
				AND bd.tier_type = bd2.tier_type 
				AND bd2.term_yr <= bd.term_yr
				AND bd.env_product = bd2.env_product
				AND bd2.technology = bd.technology
				AND bd2.gen_state_value_id = bd.gen_state_value_id
			GROUP BY bd2.tier_type, bd2.env_product
		) a
		CROSS APPLY(
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_1 
			WHERE tier_type = bd.tier_type
				AND bd.env_product = env_product
				AND technology = bd.technology
				AND gen_state_value_id = bd.gen_state_value_id
			GROUP BY tier_type, env_product
			) bd3
		WHERE bd3.term_yr = bd.term_yr
		
		
		--select * from #temp_banked_deals
		
		--select * from #banked_deals
		INSERT INTO #banked_deals(volume_left, term_yr, tier_type, env_product, state_value_id)
		SELECT SUM(volume_left) volume_left, term_yr, tier_type, env_product, state_value_id
		FROM #banked_deals_1 GROUP BY tier_type, env_product, term_yr, state_value_id
		
		INSERT INTO #temp_banked_deals_without_tier(total_volume, term_yr, generator, env_product, term_start)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.generator_id, b.source_curve_def_id,
		b.term_start
		FROM (
			SELECT 
			SUM(volume_left) volume_left, term_yr, MAX(generator_id) generator_id, source_curve_def_id,
			MAX(term_start) term_start
			FROM
			(
				SELECT 
				MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr, MAX(rg.generator_id) generator_id, MAX(rg.source_curve_def_id) source_curve_def_id,
				YEAR(MAX(sdd.term_start)) term_start
				FROM source_deal_header sdh     
				CROSS APPLY(
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
					WHERE scsv_status.item = sdh.deal_status
				) scsv_status
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
					AND sdd.buy_sell_flag = 'b'       
				INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
					AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
					OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
					THEN @comp_yr_from ELSE 1 END)     
					AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
				left join static_data_value sd on sd.value_id=@assignment_type_value_id
				LEFT JOIN	(
								SELECT gen_state_value_id, technology, max(tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
								FROM rec_gen_eligibility rge 
								group by gen_state_value_id, technology,  assignment_type, rge.from_year, rge.to_year, state_value_id
							) rge ON rge.gen_state_value_id = rg.gen_state_value_id
					AND rge.technology = rg.technology
					--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
					AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
					AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
				LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND srrd.state_value_id = rge.state_value_id
				AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
				LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND gc.state_value_id = srrd.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
				) scsv
				INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
					AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
					AND srrd.state_value_id = srrde.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
					THEN srrde.state_value_id  ELSE rge.state_value_id END
				) scsv2
				INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				WHERE sdh.assignment_type_value_id IS NULL
					AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
					ELSE COALESCE(YEAR(gc.contract_expiration_date),@comp_yr_from) END
					>= CAST(@comp_yr_from AS VARCHAR)
				GROUP BY sdh.source_deal_header_id
			) s
			GROUP BY term_yr, source_curve_def_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, MAX(rg.generator_id) generator_id, rg.source_curve_def_id
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON (sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to) OR (sdv_comp_yr.code < @comp_yr_from)
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start)  =  sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = b.term_yr
				AND b.source_curve_def_id = rg.source_curve_def_id
			GROUP BY sdv_comp_yr.code, rg.source_curve_def_id
		) s
		
		INSERT INTO #banked_deals_without_tier(total_volume, term_yr, generator, env_product)
		SELECT ISNULL(b.volume_left,0) - ISNULL(s.deal_volume,0), b.term_yr, b.generator_id, b.source_curve_def_id
		FROM (
			SELECT SUM(volume_left) volume_left, term_yr,
			MAX(generator_id) generator_id, source_curve_def_id
			FROM
			(
				SELECT MAX(volume_left) volume_left, MAX(sdv_comp_yr.code) term_yr,
				MAX(rg.generator_id) generator_id, MAX(rg.source_curve_def_id) source_curve_def_id
				FROM source_deal_header sdh     
				CROSS APPLY(
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@deal_status,sdh.deal_status)) scsv_status 
					WHERE scsv_status.item = sdh.deal_status
				) scsv_status
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id     
					AND sdd.buy_sell_flag = 'b'       
				INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.type_id = 10092 
					AND (CAST(YEAR(sdd.term_start) AS VARCHAR) = sdv_comp_yr.code
					OR CAST(YEAR(sdd.term_start) AS VARCHAR) <= CASE WHEN sdv_comp_yr.code = @comp_yr_from
					THEN @comp_yr_from ELSE 1 END)    
					AND (YEAR(sdd.term_start) BETWEEN @comp_yr_from AND @comp_yr_to OR (YEAR(sdd.term_start) < @comp_yr_from))
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
				left join static_data_value sd on sd.value_id=@assignment_type_value_id
				LEFT JOIN	(
								SELECT gen_state_value_id, technology, max(tier_type) tier_type, assignment_type, rge.from_year, rge.to_year, state_value_id
								FROM rec_gen_eligibility rge 
								group by gen_state_value_id, technology,  assignment_type, rge.from_year, rge.to_year, state_value_id
							) rge  ON rge.gen_state_value_id = rg.gen_state_value_id
					AND rge.technology = rg.technology
					--AND rge.state_value_id = ISNULL(@assigned_state, rge.state_value_id)
					AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
					AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
				LEFT JOIN state_rec_requirement_data srrd ON sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND srrd.state_value_id = rge.state_value_id
				AND srrd.assignment_type_id =  ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
				LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND gc.state_value_id = srrd.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) scsv where scsv.item = srrd.state_value_id
				) scsv
				INNER JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = srrd.assignment_type_id
					AND srrde.tier_type = COALESCE(gc.tier_type, rg.tier_type, rge.tier_type)
					AND srrd.state_value_id = srrde.state_value_id
				CROSS APPLY (
					SELECT item FROM dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, rge.state_value_id)) scsv where scsv.item = CASE WHEN ISNULL(gc.tier_type, rg.tier_type) IS NOT NULL
					THEN srrde.state_value_id  ELSE rge.state_value_id END
				) scsv2
				INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				WHERE sdh.assignment_type_value_id IS NULL
					AND CASE WHEN gc.source_certificate_number IS NULL THEN YEAR(dbo.[FNADEALRECExpirationState](sdd.source_deal_detail_id,null, srrde.assignment_type_id, srrde.state_value_id))
					ELSE COALESCE(YEAR(gc.contract_expiration_date),@comp_yr_from) END
					>= CAST(@comp_yr_from AS VARCHAR)
				GROUP BY sdh.source_deal_header_id
			) s
			GROUP BY term_yr, source_curve_def_id
		) b
		OUTER APPLY (
			SELECT SUM(deal_volume) deal_volume, sdv_comp_yr.code term_yr, MAX(rg.generator_id) generator_id, rg.source_curve_def_id
			FROM source_deal_header sdh
			INNER JOIN (select * from static_data_value where [type_id] = 10092) sdv_comp_yr
			ON (sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to) OR (sdv_comp_yr.code < @comp_yr_from)
			LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.buy_sell_flag = 's'
				AND YEAR(sdd.term_start)  =  sdv_comp_yr.code 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			WHERE sdh.status_value_id = 5182 
				AND sdv_comp_yr.code = b.term_yr
				AND b.source_curve_def_id = rg.source_curve_def_id
			GROUP BY sdv_comp_yr.code, rg.source_curve_def_id
		) s
		
		--select * from #banked_deals_without_tier
		--UPDATE bd SET bd.total_volume = a.total_volume 
		--FROM #banked_deals_without_tier bd
		--OUTER APPLY (
		--	SELECT SUM(total_volume) total_volume 
		--	FROM #banked_deals_without_tier bd2
		--	WHERE 1=1
		--		AND bd2.term_yr <= bd.term_yr
		--		AND bd.env_product = bd2.env_product
		--	GROUP BY bd2.env_product
		--) a
		--WHERE bd.term_yr = @comp_yr_from
		
		UPDATE bd SET bd.total_volume = a.total_volume 
		FROM #banked_deals_without_tier bd
		OUTER APPLY (
			SELECT SUM(total_volume) total_volume 
			FROM #temp_banked_deals_without_tier bd2 
			WHERE 1=1
				AND bd2.term_yr <= bd.term_yr
				AND bd.env_product = bd2.env_product
				--AND bd.state_value_id = bd2.state_value_id
			GROUP BY bd2.term_yr, bd2.env_product, bd2.state_value_id) a
		CROSS APPLY(
			SELECT MIN(term_yr) term_yr 
			FROM #banked_deals_without_tier 
			WHERE bd.env_product = env_product
			GROUP BY env_product
		) bd3
		WHERE bd3.term_yr = bd.term_yr
		
	END

		IF OBJECT_ID('tempdb..#target') IS NOT NULL
			DROP TABLE #target

		IF OBJECT_ID('tempdb..#target_without_grouping') IS NOT NULL
			DROP TABLE #target_without_grouping
			
		CREATE TABLE #target(id int identity(1,1), assigned FLOAT, banked FLOAT, banked_without_operation FLOAT, Net FLOAT, technology VARCHAR(100) COLLATE DATABASE_DEFAULT, gen_state_value_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
		generator VARCHAR(100) COLLATE DATABASE_DEFAULT, generator_group VARCHAR(100) COLLATE DATABASE_DEFAULT, Env_product VARCHAR(100) COLLATE DATABASE_DEFAULT, [Year] varchar(100) COLLATE DATABASE_DEFAULT, tier_type INT, [Tier] VARCHAR(100) COLLATE DATABASE_DEFAULT, [Target] FLOAT,
		total_target FLOAT, requirement_id INT, banked_total FLOAT, priority INT, state_value_id INT, jurisdiction varchar(100) COLLATE DATABASE_DEFAULT)
			
			--select * from #banked_deals
			
		DECLARE @sql2 VARCHAR(MAX)
			--select * from #target
		--populate target table
		-- it contains assigned, banked columns which can be grouped according to the grouping options
		-- banked without operation column contains original banked without update operation of previous years banked
		SET @sql = 'INSERT INTO #target(assigned, banked, banked_without_operation, Net, technology, gen_state_value_id, generator, generator_group, env_product, [Year], tier_type, [Tier], [Target], total_target, requirement_id, banked_total, state_value_id, jurisdiction)
		SELECT 
		' + CASE WHEN @summary_option = 's' AND @report_type = 'a'  THEN ' bd2.assigned ' WHEN  @summary_option <> 's' THEN ' ad.assigned_volume ' ELSE ' SUM(ISNULL(ad.assigned_volume,0)) ' END + ' assigned,
		' + CASE WHEN @summary_option = 's' AND @report_type = 'a' OR @summary_option <> 's' THEN ' CASE WHEN (bd.volume_left) < 0 THEN 0 ELSE (ISNULL(bd.volume_left,0)) END '
		ELSE ' CASE WHEN MAX(bd.volume_left) < 0 THEN 0 ELSE MAX(ISNULL(bd.volume_left,0)) END ' END + 'banked, 
		' + CASE WHEN @summary_option = 's' AND @report_type = 'a' OR @summary_option <> 's' THEN ' (ISNULL(bd3.volume_left,0)) banked_without_operation,'
		 ELSE  ' MAX(ISNULL(bd3.volume_left,0)) banked_without_operation,' END +
		 CASE WHEN @summary_option = 's' AND @report_type = 'a'  THEN 'CASE WHEN (ISNULL(bd.volume_left,0)) + (ISNULL(bd2.carryover_bank,0)) >= (ad.[target] - (ISNULL(ad.assigned_volume,0))) THEN ad.[target]
		ELSE (ISNULL(bd.volume_left,0)) + (ISNULL(bd2.carryover_bank,0)) + (ad.[target] - (ISNULL(ad.assigned_volume,0))) END - ad.[target]' WHEN @summary_option <> 's' THEN '(Net) + (ISNULL(bd.volume_left,0))'
		 ELSE 'MAX(Net) + MAX(ISNULL(bd.volume_left,0))' END + ' AS Net,
		' + CASE WHEN @summary_option in('s','h','g','e') THEN 'NULL' ELSE 'technology' END + ' technology,
		' + CASE WHEN @summary_option = 's' AND @report_type = 'a' OR @summary_option <> 's' THEN ' (ISNULL(gen_state,0)) gen_state, (ISNULL(Generator,0)) Generator, generator_group_name, (ISNULL(Env_product,0)), ad.sdv_comp_yr [Year], ad.tier_type, [Tier],  
		(ISNULL(ad.[target],0)), NULL total_target, (ISNULL(ad.state_rec_requirement_detail_id,0)), (ISNULL(bdwt.total_volume,0)) total_volume, (ISNULL(ad.state_value_id,0)), (ISNULL(ad.jurisdiction,0)) '
		 ELSE  ' MAX(ISNULL(gen_state,0)) gen_state, MAX(ISNULL(Generator,0)) Generator, MAX(ISNULL(generator_group_name,0)) generator_group_name, MAX(ISNULL(Env_product,0)), ad.sdv_comp_yr [Year], ad.tier_type, [Tier],  
		MAX(ISNULL(ad.[target],0)), NULL total_target, MAX(ISNULL(ad.state_rec_requirement_detail_id,0)), MAX(ISNULL(bdwt.total_volume,0)) total_volume, MAX(ISNULL(ad.state_value_id,0)), MAX(ISNULL(ad.jurisdiction,0)) '
		 END + '
		FROM 
		(
			SELECT sdv_tier.value_id tier_type, sdv_comp_yr.code sdv_comp_yr,  ISNULL(MAX(sdh_aa.assigned_volume),0) + ISNULL(MAX(sdh_aa2.assigned_volume),0) assigned_volume, 
			MAX(sdv_tier.code) + CASE WHEN ISNULL(srrde_nearest.requirement_type_id, 23400) = 23400 THEN '''' ELSE ''-Constraint''  END [Tier],
			ISNULL(SUM(sdh_aa.assigned_volume),0)  - COALESCE(MAX(srrde.min_absolute_target), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume)), MAX(srrde.max_absolute_target), (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume))) Net
		, COALESCE(nullif(MAX(srrde.min_absolute_target) * ISNULL(MAX(sdd.multiplier),1),0), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume)  * ISNULL(MAX(sdd.multiplier),1) ), MAX(srrde.max_absolute_target)  * ISNULL(MAX(sdd.multiplier),1), (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume) * ISNULL(MAX(sdd.multiplier),1))) [target],
			MAX(srrde.state_rec_requirement_detail_id) state_rec_requirement_detail_id, MAX(rge.tier_type) rge_tier_type,
			' + CASE WHEN @summary_option = 't' OR @summary_option = 'p' THEN 'rg.technology' ELSE 'NULL' END +' tech_value_id, MAX(sdv_tech.code) technology, MAX(rg.gen_state_value_id) gen_state_value_id ,
			' + CASE WHEN @summary_option = 'p' THEN 'sdv_gen.code' ELSE 'NULL' END + ' gen_state, ' + CASE WHEN @summary_option = 'g' THEN 'rg.name' ELSE 'NULL' END + ' [Generator]
			, MAX(rg.generator_id) generator_id, ' + CASE WHEN @summary_option = 'h' THEN 'rgg.generator_group_name' ELSE 'NULL' END + ' generator_group_name
			, ' + CASE WHEN @summary_option = 'h' THEN 'MAX(rgg.generator_group_id)' ELSE 'NULL' END + ' generator_group_id, ' + CASE WHEN @summary_option = 'e' THEN 'spcd.curve_name' ELSE 'NULL' END + ' Env_product
			,' + CASE WHEN @summary_option = 'e' THEN 'rg.source_curve_def_id' ELSE 'NULL' END + ' source_curve_def_id, scsv.item state_value_id, sdv_state.code jurisdiction
			FROM state_rec_requirement_data srrd_nearest
			INNER JOIN rec_assignment_priority_detail rapd ON rapd.rec_assignment_priority_group_id = srrd_nearest.rec_assignment_priority_group_id
				AND rapd.priority_type = 15000
			INNER JOIN rec_assignment_priority_order rapo ON rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
			INNER JOIN state_rec_requirement_detail srrde_nearest ON srrde_nearest.assignment_type_id = srrd_nearest.assignment_type_id
				AND srrde_nearest.state_value_id = srrd_nearest.state_value_id
				AND srrde_nearest.tier_type = rapo.priority_type_value_id
			INNER JOIN static_data_value sdv_tier ON sdv_tier.value_id = rapo.priority_type_value_id
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.[type_id] = 10092
				AND sdv_comp_yr.code BETWEEN ' + CAST(@comp_yr_from AS VARCHAR) + ' AND ' + CAST(@comp_yr_to AS VARCHAR) + '
			LEFT JOIN state_rec_requirement_data srrd ON 
				sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND  srrd.state_value_id = ISNULL(' + CAST(@assigned_state AS VARCHAR) + ', srrd.state_value_id) 
				AND srrd.assignment_type_id = ISNULL(' + CAST(@assignment_type_value_id AS VARCHAR) + ', srrd.assignment_type_id)
			OUTER APPLY(
			select item from dbo.splitcommaseperatedvalues(ISNULL(''' + CAST(@assigned_state AS VARCHAR(8000)) + ''', srrd.state_value_id)) scsv
			where scsv.item = srrd.state_value_id) scsv
			INNER JOIN static_data_value sdv_state ON sdv_state.value_id = scsv.item
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.assignment_type_id = ISNULL(' + CAST(@assignment_type_value_id AS VARCHAR) + ', srrde.assignment_type_id)
				AND srrde.tier_type = rapo.priority_type_value_id
			CROSS JOIN source_deal_header sdh
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			--detail id is stored in source_deal_header_id in assignment_audit table.	
		left join static_data_value sd on sd.value_id=' + CAST(@assignment_type_value_id AS VARCHAR) + '
			LEFT JOIN rec_gen_eligibility rge ON srrd.state_value_id = rge.state_value_id
			AND rge.assignment_type =sd.code 
				AND srrde.tier_type = rge.tier_type
			--AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			--rg.technology = rge.technology
			--	AND rg.gen_state_value_id = rge.gen_state_value_id --AND rg.state_value_id = rge.state_value_id
			OUTER APPLY
			(
			SELECT max(sdd.multiplier) multiplier, state_value_id from source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			where sdh.state_value_id = srrde.state_value_id
				AND YEAR(sdd.term_start) between srrd.from_year and srrd.to_year
			group by sdh.state_value_id
			) sdd
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rg.source_curve_def_id
			LEFT JOIN static_data_value sdv_tech ON sdv_tech.value_id = rg.technology
			LEFT JOIN static_data_value sdv_gen ON sdv_gen.value_id = rg.gen_state_value_id '
					--detail id is stored in source_deal_header_id in assignment_audit table.
				
		
			IF @summary_option = 'h'
				SET @sql = @sql + ' LEFT JOIN rec_generator_group rgg ON rgg.generator_group_id = rg.generator_group_name'
			IF @summary_option = 's' 
			BEGIN
				SET @sql2 =  ' OUTER APPLY(
					SELECT SUM(aa.assigned_volume) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdh.generator_id = rg.generator_id
						AND sdd.buy_sell_flag = ''s''
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND sdd.source_deal_detail_id = aa.source_deal_header_id
				) sdh_aa
				OUTER APPLY(
					SELECT SUM(sdd.deal_volume) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdh.generator_id = rg.generator_id AND sdd.buy_sell_flag = ''s''
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN source_deal_header offset_deal ON offset_deal.source_deal_header_id = sdh.close_reference_id
					INNER JOIN source_deal_header original_deal ON original_deal.source_deal_header_id = offset_deal.close_reference_id
					INNER JOIN source_deal_detail original_detail ON original_detail.source_deal_header_id = original_deal.source_deal_header_id
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND original_detail.source_deal_detail_id = aa.source_deal_header_id
				) sdh_aa2'
			END
			ELSE IF @summary_option = 't'
			BEGIN
				set @sql2 =  ' OUTER APPLY (
						SELECT SUM(aa.assigned_volume) assigned_volume
						FROM source_deal_header sdh 
						INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
							AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
							AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
							AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
						INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh.generator_id
							AND rg2.technology = rg.technology
						INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
							AND sdh.generator_id = rg.generator_id
							AND sdd.buy_sell_flag = ''s''
							AND sdh.assignment_type_value_id IS NOT NULL 
							AND sdh.compliance_year = sdv_comp_yr.code
						INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
							AND srrde.tier_type = aa.tier
							AND aa.assignment_type = srrd.assignment_type_id
							AND aa.state_value_id = srrd.state_value_id
							AND sdd.source_deal_detail_id = aa.source_deal_header_id
					) sdh_aa
					OUTER APPLY (
						SELECT SUM(sdd.deal_volume) assigned_volume
						FROM source_deal_header sdh 
						INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
							AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
							AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
							AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
						INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
							AND sdh.generator_id = rg.generator_id
							AND sdd.buy_sell_flag = ''s''
							AND sdh.assignment_type_value_id IS NOT NULL 
							AND sdh.compliance_year = sdv_comp_yr.code
						INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh.generator_id
							AND rg2.technology = rg.technology
						INNER JOIN source_deal_header offset_deal ON offset_deal.source_deal_header_id = sdh.close_reference_id
						INNER JOIN source_deal_header original_deal ON original_deal.source_deal_header_id = offset_deal.close_reference_id
						INNER JOIN source_deal_detail original_detail ON original_detail.source_deal_header_id = original_deal.source_deal_header_id
						INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
							AND srrde.tier_type = aa.tier
							AND aa.assignment_type = srrd.assignment_type_id
							AND aa.state_value_id = srrd.state_value_id
							AND original_detail.source_deal_detail_id = aa.source_deal_header_id
					) sdh_aa2'
			END
			ELSE IF @summary_option = 'p' --gen_state
			BEGIN
				set @sql2 =  ' OUTER APPLY (
					SELECT SUM(aa.assigned_volume) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh.generator_id
						AND rg2.technology = rg.technology
						AND rg2.gen_state_value_id = rg.gen_state_value_id
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdh.generator_id = rg.generator_id AND sdd.buy_sell_flag = ''s''
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND sdd.source_deal_detail_id = aa.source_deal_header_id
				) sdh_aa
				OUTER APPLY (
					SELECT SUM(sdd.deal_volume) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdh.generator_id = rg.generator_id AND sdd.buy_sell_flag = ''s''
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh.generator_id
						AND rg2.technology = rg.technology
						AND rg2.gen_state_value_id = rg.gen_state_value_id
					INNER JOIN source_deal_header offset_deal ON offset_deal.source_deal_header_id = sdh.close_reference_id
					INNER JOIN source_deal_header original_deal ON original_deal.source_deal_header_id = offset_deal.close_reference_id
					INNER JOIN source_deal_detail original_detail ON original_detail.source_deal_header_id = original_deal.source_deal_header_id
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND original_detail.source_deal_detail_id = aa.source_deal_header_id
				) sdh_aa2 '
			END
			ELSE IF @summary_option = 'g' -- generator
			BEGIN
				SET @sql2 = ' OUTER APPLY (
					SELECT SUM(aa.assigned_volume) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdd.buy_sell_flag = ''s''
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND sdd.source_deal_detail_id = aa.source_deal_header_id
					WHERE sdh.generator_id = rg.generator_id
				) sdh_aa
				OUTER APPLY (
					SELECT SUM(sdd.deal_volume) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdd.buy_sell_flag = ''s''
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN source_deal_header offset_deal ON offset_deal.source_deal_header_id = sdh.close_reference_id
					INNER JOIN source_deal_header original_deal ON original_deal.source_deal_header_id = offset_deal.close_reference_id
					INNER JOIN source_deal_detail original_detail ON original_detail.source_deal_header_id = original_deal.source_deal_header_id
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND original_detail.source_deal_detail_id = aa.source_deal_header_id
					WHERE sdh.generator_id = rg.generator_id
				) sdh_aa2 '
			END
			ELSE IF @summary_option = 'h' -- generator group
			BEGIN
				SET @sql2 = ' OUTER APPLY (
					SELECT SUM(ISNULL(aa.assigned_volume,0)) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh.generator_id
					LEFT JOIN rec_generator_group rgg2 ON ISNULL(rgg2.generator_group_id,-1) = ISNULL(rg2.generator_group_name,-1)
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdd.buy_sell_flag = ''s''
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND sdd.source_deal_detail_id = aa.source_deal_header_id
					where ISNULL(rgg2.generator_group_id,-1) = ISNULL(rg.generator_group_name,-1)
				) sdh_aa
				OUTER APPLY (
					SELECT SUM(ISNULL(sdd.deal_volume,0)) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh.generator_id
					LEFT JOIN rec_generator_group rgg2 ON ISNULL(rgg2.generator_group_id,-1) = ISNULL(rg2.generator_group_name,-1)
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdd.buy_sell_flag = ''s''
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN source_deal_header offset_deal ON offset_deal.source_deal_header_id = sdh.close_reference_id
					INNER JOIN source_deal_header original_deal ON original_deal.source_deal_header_id = offset_deal.close_reference_id
					INNER JOIN source_deal_detail original_detail ON original_detail.source_deal_header_id = original_deal.source_deal_header_id
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND original_detail.source_deal_detail_id = aa.source_deal_header_id
					where ISNULL(rgg2.generator_group_id,-1) = ISNULL(rg.generator_group_name,-1)
				) sdh_aa2 '
			END
			ELSE IF @summary_option = 'e'
			BEGIN
				SET @sql2 = ' OUTER APPLY (
					SELECT SUM(aa.assigned_volume) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh.generator_id
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdd.buy_sell_flag = ''s''
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND sdd.source_deal_detail_id = aa.source_deal_header_id
					WHERE rg2.generator_id = rg.generator_id
				) sdh_aa
				OUTER APPLY (
					SELECT SUM(sdd.deal_volume) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh.generator_id
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdd.buy_sell_flag = ''s''
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN source_deal_header offset_deal ON offset_deal.source_deal_header_id = sdh.close_reference_id
					INNER JOIN source_deal_header original_deal ON original_deal.source_deal_header_id = offset_deal.close_reference_id
					INNER JOIN source_deal_detail original_detail ON original_detail.source_deal_header_id = original_deal.source_deal_header_id
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND original_detail.source_deal_detail_id = aa.source_deal_header_id
					WHERE rg2.generator_id = rg.generator_id
				) sdh_aa2 '
			END
			SET @sql2 = @sql2 + ' LEFT JOIN #target_deal_volume dv ON YEAR(dv.term_start) = sdv_comp_yr.code
									AND dv.state_value_id = srrde.state_value_id
			INNER JOIN #nearest_state_rec_requirement_data_id scsv_nearest ON scsv_nearest.state_value_id = scsv.item
				AND scsv_nearest.state_rec_requirement_data_id = srrd_nearest.state_rec_requirement_data_id'
		
			SET @sql2 = @sql2 + ' GROUP BY sdv_tier.value_id, sdv_comp_yr.code, srrde_nearest.requirement_type_id, srrde.tier_type, scsv.item, sdv_state.code'
			
			IF @summary_option = 's' and @report_type <> 'a'
			BEGIN
				SET @sql2 = @sql2 + ', rg.generator_id'
			END
			
			IF @summary_option = 't'
				SET @sql2 = @sql2 + ',sdv_tech.code, rg.technology'
			
			IF @summary_option = 'p'
				SET @sql2 = @sql2 + ',sdv_gen.code, sdv_tech.code, rg.technology, rg.gen_state_value_id'
				
			IF @summary_option = 'g'
				SET @sql2 = @sql2 + ',rg.name'
				
			IF @summary_option = 'h'
				SET @sql2 = @sql2 + ',rgg.generator_group_name'
				
			IF @summary_option = 'e'
				SET @sql2 = @sql2 + ',spcd.curve_name, rg.source_curve_def_id'
			
			IF @summary_option = 's' and @report_type = 'a'
			BEGIN
				SET @sql2 = @sql2 + ') ad
				OUTER APPLY (
					SELECT ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
					FROM #banked_deals WHERE tier_type = ad.tier_type
						AND term_yr = ad.sdv_comp_yr and state_value_id = ad.state_value_id
				) bd
				OUTER APPLY (
					select ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
					FROM #banked_deals_without_operation WHERE tier_type = ad.tier_type
						AND term_yr = ad.sdv_comp_yr
						AND state_value_id = ad.state_value_id
				) bd3
				OUTER APPLY(
					SELECT carryover_bank, total_banked, assigned
					FROM #banked_deals_adjusted bd2 
					WHERE bd2.tier_type = ad.tier_type 
						AND bd2.term_yr = ad.sdv_comp_yr
						--AND bd2.state_value_id = ad.state_value_id
				) bd2
				OUTER APPLY (
					SELECT ISNULL(SUM(total_volume),0) total_volume 
					FROM #banked_deals_without_tier 
					WHERE term_yr = YEAR(ad.sdv_comp_yr)
				) bdwt'
			END
			ELSE IF @summary_option = 's' and @report_type <> 'a'
			BEGIN
				SET @sql2 = @sql2 + ') ad
				OUTER APPLY (
					SELECT ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
					FROM #banked_deals WHERE tier_type = ad.tier_type
						AND term_yr = ad.sdv_comp_yr
						AND state_value_id = ad.state_value_id
				) bd
				OUTER APPLY (
					SELECT ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
					FROM #banked_deals_without_operation WHERE tier_type = ad.tier_type
						AND term_yr = ad.sdv_comp_yr
						AND state_value_id = ad.state_value_id
				) bd3
				OUTER APPLY (
					SELECT ISNULL(SUM(total_volume),0) total_volume 
					FROM #banked_deals_without_tier 
					WHERE term_yr < CASE WHEN YEAR(ad.sdv_comp_yr) = ' + CAST(@comp_yr_from AS VARCHAR)+ ' THEN YEAR(ad.sdv_comp_yr)
						ELSE 1 END
						OR term_yr = ad.sdv_comp_yr
					--and state_value_id = ad.state_value_id
				) bdwt'
			END
			ELSE IF @summary_option = 't' and @report_type <> 'a'
			BEGIN
				SET @sql2 = @sql2 +' ) ad 
				OUTER APPLY (
					SELECT SUM(volume_left) volume_left 
					FROM #banked_deals bd 
					WHERE term_yr = ad.sdv_comp_yr 
						AND bd.tier_type = ad.tier_type 
						AND bd.technology = ad.tech_value_id
						AND state_value_id = ad.state_value_id
				) bd
				OUTER APPLY (
					SELECT ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
					FROM #banked_deals_without_operation 
					WHERE tier_type = ad.tier_type
						AND technology = ad.tech_value_id
						AND  term_yr = ad.sdv_comp_yr
						AND state_value_id = ad.state_value_id
				) bd3
				OUTER APPLY (
					SELECT SUM(total_volume) total_volume 
					FROM #banked_deals_without_tier bdwt 
					WHERE bdwt.term_yr = ad.sdv_comp_yr
						AND bdwt.technology = ad.tech_value_id
						--AND bdwt.state_value_id = ad.state_value_id
				) bdwt'
			END 
			ELSE IF @summary_option = 'p' and @report_type <> 'a'
			BEGIN
				SET @sql2 = @sql2 + ') ad  
					OUTER APPLY (
						SELECT SUM(volume_left) volume_left 
						FROM #banked_deals bd 
						WHERE bd.tier_type = ad.tier_type
							AND bd.term_yr = ad.sdv_comp_yr 
							AND bd.gen_state_value_id = ad.gen_state_value_id 
							AND bd.technology = ad.tech_value_id
							AND bd.state_value_id = ad.state_value_id
					) bd
					OUTER APPLY (
						SELECT ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
						FROM #banked_deals_without_operation 
						WHERE tier_type = ad.tier_type
							AND technology = ad.tech_value_id
							AND gen_state_value_id = ad.gen_state_value_id
							AND term_yr = ad.sdv_comp_yr
							AND state_value_id = ad.state_value_id
					) bd3
					OUTER APPLY (
						SELECT SUM(total_volume) total_volume 
						FROM #banked_deals_without_tier bdwt 
						WHERE bdwt.term_yr = YEAR(ad.sdv_comp_yr)
							AND bdwt.gen_state_value_id = ad.gen_state_value_id 
							AND bdwt.technology = ad.tech_value_id
							--AND bdwt.state_value_id = ad.state_value_id
					) bdwt'
			END
			ELSE IF @summary_option = 'g' and @report_type <> 'a'
			BEGIN
				SET @sql2 = @sql2 + ' ) ad 
				OUTER APPLY (
					SELECT SUM(volume_left) volume_left 
					FROM #banked_deals bd 
					WHERE bd.tier_type = ad.tier_type
						AND bd.term_yr = sdv_comp_yr 
						AND bd.generator = ad.generator_id
						AND bd.state_value_id = ad.state_value_id
				) bd
				OUTER APPLY (
					SELECT ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
					FROM #banked_deals_without_operation 
					WHERE tier_type = ad.tier_type
						AND generator = ad.generator_id
						AND term_yr = ad.sdv_comp_yr
				) bd3
				OUTER APPLY (
					SELECT SUM(total_volume) total_volume 
					FROM #banked_deals_without_tier bdwt 
					WHERE bdwt.term_yr = YEAR(ad.sdv_comp_yr)
						AND bdwt.generator = ad.generator_id
						--AND bdwt.state_value_id = ad.state_value_id
				) bdwt'
			END
			ELSE IF @summary_option = 'h' AND @report_type <> 'a'
			BEGIN
				SET @sql2 = @sql2 + ' ) ad 
				OUTER APPLY (
					SELECT SUM(volume_left) volume_left 
					FROM #banked_deals bd 
					WHERE bd.tier_type = ad.tier_type
						AND bd.term_yr = sdv_comp_yr 
						AND ISNULL(bd.generator_group,-1) = ISNULL(ad.generator_group_id,-1)
						AND bd.state_value_id = ad.state_value_id
				) bd
				OUTER APPLY (
					SELECT
					ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
					FROM #banked_deals_without_operation 
					WHERE tier_type = ad.tier_type
						AND ISNULL(generator_group,-1) = ISNULL(ad.generator_group_id,-1)
						AND term_yr = ad.sdv_comp_yr
				) bd3
				OUTER APPLY (
					SELECT SUM(total_volume) total_volume 
					FROM #banked_deals_without_tier bdwt 
					WHERE bdwt.term_yr = YEAR(ad.sdv_comp_yr)
						AND ISNULL(bdwt.generator_group,-1) = ISNULL(ad.generator_group_id,-1)
						--AND bdwt.state_value_id = ad.state_value_id
				) bdwt'
			END
			ELSE IF @summary_option = 'e'
			BEGIN
			SET @sql2 = @sql2 + ' ) ad 
			OUTER APPLY (
				SELECT SUM(volume_left) volume_left 
				FROM #banked_deals 
				WHERE tier_type = ad.tier_type
					AND term_yr = ad.sdv_comp_yr 
					AND env_product = ad.source_curve_def_id
					AND state_value_id = ad.state_value_id
			) bd
			OUTER APPLY (
					SELECT ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
					FROM #banked_deals_without_operation 
					WHERE tier_type = ad.tier_type
						AND env_product = ad.source_curve_def_id
						AND term_yr = ad.sdv_comp_yr
			) bd3
			OUTER APPLY (
				SELECT SUM(total_volume) total_volume 
				FROM #banked_deals_without_tier bdwt 
				WHERE bdwt.term_yr = YEAR(ad.sdv_comp_yr)
					AND bdwt.env_product = ad.source_curve_def_id
					--AND bdwt.state_value_id = ad.state_value_id
			) bdwt'
			END
			IF @summary_option = 's' and @report_type <> 'a'
			BEGIN
					SET @sql2 = @sql2  +' GROUP BY ad.tier_type, ad.sdv_comp_yr, ad.[Tier],  ad.state_value_id'
			END
		
			
--PRINT @sql 
--PRINT @sql2
		EXEC(@sql + @sql2)
		 


update #target set [target]=[target] +s.[deal_volume] from #target  t inner join #target_deal_volume_sales s 
on s.term_start=t.[year] and  s.state_value_id=t.state_value_id and s.tier_type=t.tier_type




		
	--END
	--select * from #target
	--select * from #banked_deals_without_tier
	--select * from #banked_deals
	--select * from #banked_deals_adjusted
	--select * from #banked_deals_without_tier where term_yr = 2014
	
	
IF OBJECT_ID('tempdb..#assigned_total') IS NOT NULL
	DROP TABLE #assigned_total
	
CREATE TABLE #assigned_total(term_yr INT, assigned_total FLOAT, state_value_id INT)

CREATE TABLE #target_without_grouping(assigned FLOAT, banked FLOAT, Net FLOAT, technology VARCHAR(100) COLLATE DATABASE_DEFAULT, gen_state_value_id VARCHAR(100) COLLATE DATABASE_DEFAULT, generator VARCHAR(100) COLLATE DATABASE_DEFAULT,
generator_group VARCHAR(100) COLLATE DATABASE_DEFAULT, env_product VARCHAR(100) COLLATE DATABASE_DEFAULT, [Year] VARCHAR(100) COLLATE DATABASE_DEFAULT, tier_type INT, [Tier] VARCHAR(100) COLLATE DATABASE_DEFAULT, [target] FLOAT, total_target FLOAT, Net_total float, state_value_id INT, jurisdiction varchar(100) )

IF OBJECT_ID('tempdb..#target_without_grouping2') IS NOT NULL
	DROP TABLE #target_without_grouping2
	
CREATE TABLE #target_without_grouping2(assigned FLOAT, banked FLOAT, Net FLOAT, technology VARCHAR(100) COLLATE DATABASE_DEFAULT, gen_state_value_id VARCHAR(100) COLLATE DATABASE_DEFAULT, generator VARCHAR(100) COLLATE DATABASE_DEFAULT,
generator_group VARCHAR(100) COLLATE DATABASE_DEFAULT, env_product VARCHAR(100) COLLATE DATABASE_DEFAULT, [Year] VARCHAR(100) COLLATE DATABASE_DEFAULT, tier_type INT, [Tier] VARCHAR(100) COLLATE DATABASE_DEFAULT, [target] FLOAT, total_target FLOAT, Net_total float, state_value_id INT, jurisdiction varchar(100) COLLATE DATABASE_DEFAULT)
--select * from #target_deal_volume
--select * from #target_without_grouping
--return 
-- target without grouping contains columns like target,net ,total target and net total which don't need to be grouped according to 
-- grouping options in the final output
-- report type a is valid for allocate option only available in summary
-- all the other options use below query in else part
IF @report_type = 'a'
BEGIN
	INSERT INTO #target_without_grouping(assigned , banked , Net , technology , gen_state_value_id , generator ,generator_group ,
	env_product , [Year] , tier_type , [Tier] , [target] , total_target, Net_total, state_value_id, jurisdiction)
	SELECT bd2.assigned  assigned,
	ISNULL(bd.volume_left,0)  banked,
	ISNULL(ad.Net,0) + CASE WHEN @report_type <> 'n' 
	THEN ISNULL((bd.volume_left),0)  ELSE 0 END  Net, 
	CAST(NULL AS VARCHAR) technology,  CAST(NULL AS VARCHAR) gen_state_value_id,  CAST(NULL AS VARCHAR) generator,
	CAST(NULL AS VARCHAR) generator_group, CAST(NULL AS VARCHAR)  Env_product,
	CAST(sdv_comp_yr as varchar) [Year], ad.tier_type,
	[Tier] ,  [target], ISNULL(total_target,0) total_target, 
	ISNULL(at.assigned_total,0) - ISNULL(total_target,0), ad.state_value_id, ad.jurisdiction
	FROM 
	(
		SELECT sdv_tier.value_id tier_type, ISNULL(SUM(sdh_aa.assigned_volume),0) + ISNULL(SUM(sdh_aa2.assigned_volume),0)  assigned_volume, MAX(sdv_tier.code) + CASE WHEN ISNULL(srrde_nearest.requirement_type_id, 23400) = 23400 THEN '' ELSE '-Constraint'  END [Tier],
		ISNULL(SUM(sdh_aa.assigned_volume),0)  +  ISNULL(SUM(sdh_aa2.assigned_volume),0) - COALESCE(MAX(srrde.min_absolute_target), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume)), MAX(srrde.max_absolute_target), (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume))) Net
		, COALESCE(MAX(srrde.min_absolute_target)  * ISNULL(MAX(sdd.multiplier),1), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume)  * ISNULL(MAX(sdd.multiplier),1)), MAX(srrde.max_absolute_target) * ISNULL(MAX(sdd.multiplier),1), (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume) * ISNULL(MAX(sdd.multiplier),1))) [target],
		MAX(srrd.per_profit_give_back) / 100 * ISNULL(MAX(dv.deal_volume),1)* ISNULL(MAX(sdd.multiplier),1) total_target,		 
		MAX(srrde.state_rec_requirement_detail_id) state_rec_requirement_detail_id , cast(sdv_comp_yr.code as varchar) sdv_comp_yr,
		max(sdv_tier.code) sdv_tier , max(scsv.item) state_value_id, max(sdv_state.code) jurisdiction
		--,max(sdh.source_deal_header_id) source_deal_header_id
		--,ISNULL(SUM(sdh_aa.assigned_volume),0)  ,  ISNULL(SUM(sdh_aa2.assigned_volume),0) , COALESCE(MAX(srrde.min_absolute_target), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume)), MAX(srrde.max_absolute_target), (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume))) Net
		--select (max(srrde.min_target) / 100 * max(dv.deal_volume)  * ISNULL(max(sdd.multiplier),1)),max(sdv_tier.code) sdv_tier, sdv_comp_yr.code
		--, scsv.item
		FROM state_rec_requirement_data srrd_nearest
		INNER JOIN rec_assignment_priority_detail rapd ON rapd.rec_assignment_priority_group_id = srrd_nearest.rec_assignment_priority_group_id
			AND rapd.priority_type = 15000
		INNER JOIN rec_assignment_priority_order rapo ON rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
		INNER JOIN state_rec_requirement_detail srrde_nearest ON srrde_nearest.assignment_type_id = srrd_nearest.assignment_type_id
			AND srrde_nearest.state_value_id = srrd_nearest.state_value_id
			AND srrde_nearest.tier_type = rapo.priority_type_value_id
		INNER JOIN static_data_value sdv_tier ON sdv_tier.value_id = rapo.priority_type_value_id
		INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.[type_id] = 10092
			AND sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to
		--CROSS join source_deal_header sdh
		--INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		--		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		--		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		--		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		LEFT JOIN state_rec_requirement_data srrd ON  sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--AND srrd.state_value_id = ISNULL(@assigned_state, srrd.state_value_id) 
			AND srrd.assignment_type_id = ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
		CROSS APPLY(
		SELECT item from dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) 
		where  item = srrd.state_value_id
		) scsv 
		INNER JOIN static_data_value sdv_state ON sdv_state.value_id = scsv.item
		LEFT JOIN state_rec_requirement_detail srrde ON srrde.state_value_id = srrd.state_value_id
			AND srrde.assignment_type_id = ISNULL(@assignment_type_value_id, srrde.assignment_type_id)
			AND srrde.tier_type = rapo.priority_type_value_id
		----detail id is stored in source_deal_header_id in assignment_audit table.	
		left join static_data_value sd on sd.value_id=@assignment_type_value_id 
		LEFT JOIN rec_gen_eligibility rge ON srrd.state_value_id = rge.state_value_id
			AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
			AND srrde.tier_type = rge.tier_type
		LEFT JOIN rec_generator rg ON rg.technology = rge.technology
			AND rg.gen_state_value_id = rge.gen_state_value_id 
			--AND rg.state_value_id = rge.state_value_id
		OUTER APPLY
			(
			SELECT max(sdd.multiplier) multiplier, state_value_id from source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			where sdh.state_value_id = srrde.state_value_id
				AND YEAR(sdd.term_start) between srrd.from_year and srrd.to_year
			group by sdh.state_value_id
			) sdd
	----detail id is stored in source_deal_header_id in assignment_audit table.	
		OUTER APPLY(
			SELECT SUM(aa.assigned_volume) assigned_volume
			FROM source_deal_header sdh 
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				--AND sdh.generator_id = rg.generator_id 
				AND sdd.buy_sell_flag = 's'
				AND sdh.assignment_type_value_id IS NOT NULL 
				AND sdh.compliance_year = sdv_comp_yr.code
			INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
				AND srrde.tier_type = aa.tier
				AND aa.assignment_type = srrd.assignment_type_id
				AND aa.state_value_id = srrd.state_value_id
				AND sdd.source_deal_detail_id = aa.source_deal_header_id
		) sdh_aa
		OUTER APPLY(
			SELECT SUM(sdd.deal_volume) assigned_volume
			FROM source_deal_header sdh 
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND sdh.generator_id = rg.generator_id AND sdd.buy_sell_flag = 's'
				AND sdh.assignment_type_value_id IS NOT NULL 
				AND sdh.compliance_year = sdv_comp_yr.code
			INNER JOIN source_deal_header offset_deal ON offset_deal.source_deal_header_id = sdh.close_reference_id
			INNER JOIN source_deal_header original_deal ON original_deal.source_deal_header_id = offset_deal.close_reference_id
			INNER JOIN source_deal_detail original_detail ON original_detail.source_deal_header_id = original_deal.source_deal_header_id
			INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
				AND srrde.tier_type = aa.tier
				AND aa.assignment_type = srrd.assignment_type_id
				AND aa.state_value_id = srrd.state_value_id
				AND original_detail.source_deal_detail_id = aa.source_deal_header_id
		) sdh_aa2
		LEFT JOIN #target_deal_volume dv ON YEAR(dv.term_start) = sdv_comp_yr.code	
				AND dv.state_value_id = srrde.state_value_id
			--AND sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
		--INNER JOIN #nearest_state_rec_requirement_data_id scsv_nearest ON scsv_nearest.state_value_id = scsv.item
		--		AND scsv_nearest.state_rec_requirement_data_id = srrd_nearest.state_rec_requirement_data_id
		GROUP BY sdv_tier.value_id, scsv.item,sdv_comp_yr.code, srrde_nearest.requirement_type_id
	) Ad 
	OUTER APPLY (
		SELECT ISNULL(SUM(volume_left),0) volume_left, MAX(term_yr) term_yr
		FROM #banked_deals WHERE tier_type = ad.tier_type
			AND term_yr = ad.sdv_comp_yr
			AND state_value_id = ad.state_value_id
	) bd
	OUTER APPLY(
		SELECT carryover_bank volume_left, total_banked, assigned
		FROM #banked_deals_adjusted bd2 
		WHERE bd2.tier_type = ad.tier_type 
			AND bd2.term_yr = ad.sdv_comp_yr
			--AND bd2.state_value_id = ad.state_value_id
	) bd2
	OUTER APPLY (
		SELECT SUM(total_volume) total_volume 
		FROM #banked_deals_without_tier bdwt 
		WHERE bdwt.term_yr = ad.sdv_comp_yr
	) bdwt
	OUTER APPLY (
		SELECT SUM(assigned_total) assigned_total 
		FROM #assigned_total 
		WHERE term_yr = ad.sdv_comp_yr
	) at
--return
		
END
ELSE
BEGIN
		--select * from #banked_deals_adjusted
		--select * from #target
		--select * from #target_without_grouping
		INSERT INTO #target_without_grouping(assigned , banked , Net , technology , gen_state_value_id , generator ,generator_group ,
		env_product , [Year] , tier_type , [Tier] , [target] , total_target, Net_total, state_value_id, jurisdiction)
		SELECT ISNULL(ad.assigned_volume,0) assigned , ISNULL(bd.volume_left,0) banked, ISNULL(ad.Net,0) + CASE WHEN @report_type <> 'n' 
		THEN ISNULL((bd.volume_left),0)  ELSE 0 END  Net, 
		CAST(NULL AS VARCHAR) technology,  CAST(NULL AS VARCHAR) gen_state_value_id,  CAST(NULL AS VARCHAR) generator,
		CAST(NULL AS VARCHAR) generator_group, CAST(NULL AS VARCHAR)  Env_product,
		cast(sdv_comp_yr as varchar) [Year], ad.tier_type,
		[Tier] ,  [target], ISNULL(total_target,0) total_target, ISNULL(at.assigned_total,0) + ISNULL(bdwt.total_volume,0) - ISNULL(total_target,0), ad.state_value_id,ad.jurisdiction
		--, ISNULL(at.assigned_total,0) , ISNULL(bdwt.total_volume,0) , ISNULL(total_target,0)
		FROM 
		(
			SELECT sdv_tier.value_id tier_type, ISNULL(MAX(sdh_aa.assigned_volume),0) + ISNULL(MAX(sdh_aa2.assigned_volume),0)  assigned_volume, max(sdv_tier.code) + CASE WHEN ISNULL(srrde_nearest.requirement_type_id, 23400) = 23400 THEN '' ELSE '-Constraint'  END [Tier],
			ISNULL(SUM(sdh_aa.assigned_volume),0) +  ISNULL(SUM(sdh_aa2.assigned_volume),0) - COALESCE(MAX(srrde.min_absolute_target)* ISNULL(MAX(sdd.multiplier),1), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume)* ISNULL(MAX(sdd.multiplier),1)), MAX(srrde.max_absolute_target)* ISNULL(MAX(sdd.multiplier),1), (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume)* ISNULL(MAX(sdd.multiplier),1))) Net
			, COALESCE(nullif(MAX(srrde.min_absolute_target) * ISNULL(MAX(sdd.multiplier),1),0), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume) * ISNULL(MAX(sdd.multiplier),1)), MAX(srrde.max_absolute_target) * ISNULL(MAX(sdd.multiplier),1), (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume) * ISNULL(MAX(sdd.multiplier),1))) [target],
			MAX(srrd.per_profit_give_back) / 100 * MAX(dv.deal_volume) total_target,
			MAX(srrde.state_rec_requirement_detail_id) state_rec_requirement_detail_id , cast(sdv_comp_yr.code as varchar) sdv_comp_yr,
			max(sdv_tier.code) sdv_tier, (scsv.item) state_value_id, MAX(sdv_state.code) jurisdiction
			--,max(sdv_tier.code) tier,sdv_comp_yr.code
			--, max(srrde.min_target) / 100 , max(dv.deal_volume) , ISNULL(max(sdd.multiplier),1), max(srrde.min_target) / 100 * max(dv.deal_volume) * ISNULL(max(sdd.multiplier),1),scsv.item , max(sdv_tier.code) tier,sdv_comp_yr.code
			--, COALESCE(MAX(srrde.min_absolute_target) * ISNULL(MAX(sdd.multiplier),1), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume) * ISNULL(MAX(sdd.multiplier),1)), MAX(srrde.max_absolute_target) * ISNULL(MAX(sdd.multiplier),1), (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume) * ISNULL(MAX(sdd.multiplier),1)))
		
		
		
--declare 
--@summary_option VARCHAR(100) = 's',  
--@sub VARCHAR(max) = '1577',  
--@stra VARCHAR(max) = '1578,1580,1582',  
--@book VARCHAR(max) = '1579,1589,1581,1590,1583,1591',  
--@comp_yr_from INT = '5518',  
--@comp_yr_to INT = '5538',  
--@assignment_type_value_id INT = 5146,  
--@assigned_state varchar(8000) = '309371',  
--@report_type CHAR(1) = 'i',  
--@compliance_yr INT = NULL,  
--@hypothetical CHAR(1) = null ,--'n',  
--@group_id INT = NULL,  
--@deal_status varchar(1000) = 5604,  
--@tier varchar(8000) = NULL,  
--@batch_process_id VARCHAR(250) = NULL,  
--@batch_report_param VARCHAR(500) = NULL,   
--@enable_paging INT = 0,  --'1' = enable, '0' = disable  
--@page_size INT = NULL,  
--@page_no INT = NULL  
		
		
		
			--  select ISNULL(MAX(sdh_aa.assigned_volume),0), ISNULL(MAX(sdh_aa2.assigned_volume),0) 
			FROM 
			state_rec_requirement_data srrd_nearest
			INNER JOIN rec_assignment_priority_detail rapd ON rapd.rec_assignment_priority_group_id = srrd_nearest.rec_assignment_priority_group_id
				AND rapd.priority_type = 15000
			INNER JOIN rec_assignment_priority_order rapo ON rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
			INNER JOIN state_rec_requirement_detail srrde_nearest ON srrde_nearest.assignment_type_id = srrd_nearest.assignment_type_id
				AND srrde_nearest.state_value_id = srrd_nearest.state_value_id
				AND srrde_nearest.tier_type = rapo.priority_type_value_id
			INNER JOIN static_data_value sdv_tier ON sdv_tier.value_id = rapo.priority_type_value_id
			INNER JOIN static_data_value sdv_comp_yr ON sdv_comp_yr.[type_id] = 10092
				AND sdv_comp_yr.code BETWEEN @comp_yr_from AND @comp_yr_to
			LEFT JOIN state_rec_requirement_data srrd ON  sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
				--AND srrd.state_value_id = ISNULL(@assigned_state, srrd.state_value_id) 
				AND srrd.assignment_type_id = ISNULL(@assignment_type_value_id, srrd.assignment_type_id)
			CROSS APPLY(
				SELECT item from dbo.SplitCommaSeperatedValues(ISNULL(@assigned_state, srrd.state_value_id)) 
				where  item = srrd.state_value_id
				) scsv 
			INNER JOIN static_data_value sdv_state ON sdv_state.value_id = scsv.item
			LEFT JOIN state_rec_requirement_detail srrde ON srrde.state_value_id = srrd.state_value_id
				AND srrde.assignment_type_id = ISNULL(@assignment_type_value_id, srrde.assignment_type_id)
				AND srrde.tier_type = rapo.priority_type_value_id
			----detail id is stored in source_deal_header_id in assignment_audit table.	
			left join static_data_value sd on sd.value_id=@assignment_type_value_id
			LEFT JOIN rec_gen_eligibility rge ON srrd.state_value_id = rge.state_value_id
				AND rge.assignment_type = ISNULL(sd.code, rge.assignment_type)
				AND srrde.tier_type = rge.tier_type
				--AND sdv_comp_yr.code BETWEEN rge.from_year AND rge.to_year
			--INNER JOIN static_data_value sdv_tt ON sdv_tt.value_id = srrde.tier_type
			LEFT JOIN rec_generator rg ON rg.technology = rge.technology
				AND rg.gen_state_value_id = rge.gen_state_value_id --AND rg.state_value_id = rge.state_value_id
			CROSS APPLY
			(
			SELECT max(sdd.multiplier) multiplier, state_value_id from source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			where sdh.state_value_id = srrde.state_value_id
				AND YEAR(sdd.term_start) between srrd.from_year and srrd.to_year
			group by sdh.state_value_id
			) sdd
		----detail id is stored in source_deal_header_id in assignment_audit table.	
			OUTER APPLY(
					SELECT SUM(aa.assigned_volume) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						--AND sdh.generator_id = rg.generator_id
						AND sdd.buy_sell_flag = 's'
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND sdd.source_deal_detail_id = aa.source_deal_header_id
			) sdh_aa
			OUTER APPLY(
					SELECT SUM(sdd.deal_volume) assigned_volume
					FROM source_deal_header sdh 
					INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdh.generator_id = rg.generator_id AND sdd.buy_sell_flag = 's'
						AND sdh.assignment_type_value_id IS NOT NULL 
						AND sdh.compliance_year = sdv_comp_yr.code
					INNER JOIN source_deal_header offset_deal ON offset_deal.source_deal_header_id = sdh.close_reference_id
					INNER JOIN source_deal_header original_deal ON original_deal.source_deal_header_id = offset_deal.close_reference_id
					INNER JOIN source_deal_detail original_detail ON original_detail.source_deal_header_id = original_deal.source_deal_header_id
					INNER JOIN assignment_audit aa ON aa.compliance_year = sdv_comp_yr.code
						AND srrde.tier_type = aa.tier
						AND aa.assignment_type = srrd.assignment_type_id
						AND aa.state_value_id = srrd.state_value_id
						AND original_detail.source_deal_detail_id = aa.source_deal_header_id
			) sdh_aa2
		--	--detail id is stored in source_deal_header_id in assignment_audit table.	
			LEFT JOIN #target_deal_volume dv ON YEAR(dv.term_start) = sdv_comp_yr.code	
				AND dv.state_value_id = srrde.state_value_id
				--AND sdv_comp_yr.code BETWEEN srrd.from_year AND srrd.to_year
			--INNER JOIN #nearest_state_rec_requirement_data_id scsv_nearest ON scsv_nearest.state_value_id = scsv.item AND
			-- scsv_nearest.state_rec_requirement_data_id = srrd_nearest.state_rec_requirement_data_id
			GROUP BY sdv_tier.value_id, scsv.item, sdv_comp_yr.code, srrde_nearest.requirement_type_id
		) Ad 
		OUTER APPLY (
			SELECT ISNULL(SUM(volume_left),0) volume_left 
			FROM #banked_deals 
			WHERE tier_type = ad.tier_type
				AND term_yr = YEAR(ad.sdv_comp_yr)
				AND state_value_id = ad.state_value_id
		) bd
		OUTER APPLY (
			SELECT ISNULL(SUM(total_volume),0) total_volume 
			FROM #banked_deals_without_tier bdwt 
			WHERE bdwt.term_yr = YEAR(ad.sdv_comp_yr)
				AND bdwt.state_value_id = ad.state_value_id
		) bdwt
		OUTER APPLY (
			SELECT SUM(assigned_total) assigned_total 
			FROM #assigned_total 
			WHERE term_yr = YEAR(ad.sdv_comp_yr)
		) at
		
		--return
END

--return
--select * from #banked_deals_without_tier
--select * from #banked_deals where tier_type = 300472
--select * from #target_deal_volume
--select * from #target_without_grouping2
--SELECT  * FROM  #target order by year
if OBJECT_ID('tempdb..#inventory_table') IS NOT NULL  DROP TABLE #inventory_table  

--TODO: make tier name hardcoded instead of its id
SELECT YEAR(sdd.term_start) [Year], 'RECS' [Type], sum(sdd.deal_volume) volume, rge.tier_type value_id, sdv_tier.code [Tier], rge.state_value_id
INTO #inventory_table
--SELECT sdv_srrde.code,sdd.*
FROM source_deal_header sdh 
INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id 
inner join static_data_value sd on sd.value_id=@assignment_type_value_id
CROSS APPLY (
	SELECT state_value_id, assignment_type, tier_type
	FROM rec_gen_eligibility rge WHERE sdd.term_start BETWEEN rge.from_year AND rge.to_year
		AND rge.technology = rg.technology
		AND rge.gen_state_value_id = rg.gen_state_value_id
		AND rge.state_value_id = rg.state_value_id
		AND rge.assignment_type = sd.code
	GROUP BY state_value_id, assignment_type, tier_type
) rge  
INNER JOIN static_data_value sdv_tier ON sdv_tier.value_id = rge.tier_type
INNER JOIN static_data_value sdv_tech ON sdv_tech.value_id = rg.technology
INNER JOIN static_data_value sdv_gen_state ON sdv_gen_state.value_id = rg.gen_state_value_id 
WHERE sdd.buy_sell_flag = 'b'
	AND sdh.deal_id NOT LIKE 'allocated%' AND sdh.deal_id NOT LIKE 'offset%'
--AND sdv_srrde.code='Energy Efficiency'
GROUP BY YEAR(sdd.term_start), sdv_tier.code,rge.tier_type,rge.state_value_id

--update energy efficiency and in state column of #target_without_grouping table
-- as these target of these tiers are null so they have to be computed
	  
UPDATE r SET r.[target] = CASE WHEN [Target] = 0 THEN NULL WHEN (r.total_target-(a.volume-b.volume2))<0 THEN 0 ELSE r.total_target-(a.volume-b.volume2) END  
FROM 
--SELECT r.[Target],r.year,r.total_target, a.volume,b.volume2,r.total_target-(a.volume-b.volume2) FROM 
#target_without_grouping r
 CROSS APPLY (
	SELECT SUM(twg.[target]) volume 
	FROM #target_without_grouping twg
	WHERE twg.[YEAR] = r.[YEAR] 
		AND twg.state_value_id = r.state_value_id
		AND twg.[target] IS NOT NULL 
		AND twg.[Tier] NOT LIKE '%-Constraint' 
 ) a 
CROSS APPLY (
	SELECT SUM(twg2.[target]) volume2 
	FROM #target_without_grouping twg2 
	WHERE twg2.[YEAR] = r.[YEAR] 
		AND twg2.state_value_id = r.state_value_id
		AND twg2.[target] IS NOT NULL 
		AND twg2.[TIER] LIKE '%-Constraint'
) b
WHERE [Tier]='Energy Efficiency' 
	
UPDATE r SET [target]= CASE WHEN [target] = 0 THEN NULL ELSE it.banked END  
FROM
--SELECT sum(it.banked),sum(r.[target]),it.[year]  from
#target_without_grouping r 
INNER JOIN
(	SELECT SUM(it.banked_without_operation) banked,r.[year] [year],it.tier_type ,r.state_value_id
	FROM #target_without_grouping r 
	INNER JOIN #target it on r.[YEAR]=it.[YEAR]
		AND r.tier_type = it.tier_type 
		AND r.state_value_id = it.state_value_id
	WHERE  it.Tier = 'Energy Efficiency'  
		--AND it.banked_without_operation  <> 0
	GROUP BY it.tier_type,r.[year], r.state_value_id
	HAVING sum(it.banked_without_operation) < sum(r.[target]) 
) it ON it.[year] = r.[year] AND it.tier_type = r.tier_type 
	AND it.state_value_id = r.state_value_id

 --SELECT * FROM #target WHERE YEAR = 2013
UPDATE r SET r.[target] = case when (r.total_target-(a.volume-b.volume2))<0 THEN 0 ELSE r.total_target-(a.volume-b.volume2) END  
--SELECT r.[YEAR],total_target, a.volume,b.volume2,total_target-(a.volume-b.volume2)
FROM #target_without_grouping r 
CROSS APPLY (
 	SELECT SUM(twg.[target]) volume 
 	FROM #target_without_grouping twg
 	WHERE twg.[YEAR] = r.[YEAR] 
 		AND twg.state_value_id = r.state_value_id
		AND twg.[target] IS NOT NULL 
		AND twg.[Tier] NOT LIKE '%-Constraint' 
 ) a 
CROSS APPLY (
	SELECT SUM(twg2.[target]) volume2 
	FROM #target_without_grouping twg2 
	WHERE twg2.[YEAR] = r.[YEAR] 
		AND twg2.state_value_id = r.state_value_id
 		AND twg2.[target] IS NOT NULL 
 		AND twg2.[TIER] LIKE '%-Constraint'
) b
WHERE [Tier]='In State' 
--select * from #target
--return
--select * from  #target_without_grouping

IF @report_type = 'a'
BEGIN 


	/* temporary added by Gyan : To carrier over the banked value into next year*/
	---------------------------------------------------------
	UPDATE r SET r.assigned =
		
	--select	 ISNULL(s.[target],0) t,ISNULL(s.banked,0) b,ISNULL(abs(r.[banked]),0),( ISNULL(s.[target],0)-ISNULL(s.banked,0)),r.*,

	CASE WHEN ISNULL(s.banked,0)> ISNULL(s.[target],0) then  ISNULL(r.[target],0)
		else  ISNULL(abs(r.[target]),0)-( ISNULL(s.[target],0)-ISNULL(s.banked,0))
	  END
		FROM #target_without_grouping r
		OUTER APPLY (
					SELECT sum(abs(banked)) banked,sum([target]) [target]
					FROM #target_without_grouping 
					WHERE tier_type = r.tier_type
						AND [year] <= r.[Year]
						AND state_value_id = r.state_value_id
		) s
		
		UPDATE r SET r.assigned =r.assigned+(ISNULL(s.banked,0)-ISNULL(s.[assigned],0))
		FROM #target_without_grouping r
		OUTER APPLY (
					SELECT sum(abs(banked)) banked,sum(assigned) [assigned]
					FROM #target_without_grouping 
					WHERE tier_type = r.tier_type
						AND [year] <= r.[Year]
						AND state_value_id = r.state_value_id
		) s
		where ISNULL(s.banked,0)>ISNULL(s.[assigned],0)
		and r.[target]>= (r.assigned+(ISNULL(s.banked,0)-ISNULL(s.[assigned],0))) 
		
	-------------------------------------------------------------------------------------------------------


	-- assigned is computed using this logic after target has been calculated above
	UPDATE r SET r.assigned =
	CASE WHEN (ISNULL(bd.volume_left,0)) + (ISNULL(bda.carryover_bank,0)) >= (ISNULL(twg.[target],0) - (ISNULL(r.assigned,0)))
	THEN ISNULL(twg.[target],0) ELSE (ISNULL(bd.volume_left,0)) + (ISNULL(bda.carryover_bank,0)) + (ISNULL(r.assigned,0)) END
	FROM #target r
	INNER JOIN #target_without_grouping twg ON r.tier_type = twg.tier_type
		AND r.[Year] = twg.[YEAR]
		AND r.state_value_id = twg.state_value_id
	OUTER APPLY (
				SELECT ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
				FROM #banked_deals WHERE tier_type = r.tier_type
					AND term_yr = r.[Year]
					AND state_value_id = r.state_value_id
	) bd
	OUTER APPLY (
			SELECT carryover_bank 
			FROM #banked_deals_adjusted bd2 
			WHERE bd2.tier_type = r.tier_type 
				AND bd2.term_yr = r.[year]
				--AND bd2.state_value_id = r.state_value_id
	) bda
	WHERE r.[tier] IN ('Energy Efficiency','In State')

	UPDATE r SET r.assigned =
	CASE WHEN (ISNULL(bd.volume_left,0)) + (ISNULL(bd2.volume_left,0)) >= (ISNULL(r.[target],0) - (ISNULL(r.assigned,0)))
	THEN ISNULL(r.[target],0) ELSE (ISNULL(bd.volume_left,0)) + (ISNULL(bd2.volume_left,0)) + (ISNULL(r.assigned,0)) END
	FROM #target_without_grouping r
	OUTER APPLY (
				SELECT ISNULL(sum(volume_left),0) volume_left, max(term_yr) term_yr
				FROM #banked_deals 
				WHERE tier_type = r.tier_type
					AND term_yr = r.[Year]
					AND state_value_id = r.state_value_id
	) bd
	OUTER APPLY (
			SELECT carryover_bank volume_left 
			FROM #banked_deals_adjusted bd2 
			WHERE bd2.tier_type = r.tier_type 
				AND bd2.term_yr = r.[year]
				--AND bd2.state_value_id = r.state_value_id
	) bd2
	WHERE r.[tier] IN('Energy Efficiency','In State')
	
	
	
	--select * from #target_without_grouping
	

END


--select * from #target_without_grouping
--SELECT  * FROM  #target
--SELECT  * FROM  #assigned_total


--return
IF @report_type = 'a'
BEGIN
	INSERT INTO #target_without_grouping2(assigned , banked , Net , technology , gen_state_value_id , generator ,
	generator_group , env_product , [Year] , tier_type , [Tier] , [target] , total_target , Net_total , state_value_id , jurisdiction )
	SELECT	MAX(assigned) assigned , SUM(banked) banked , MAX(Net) Net, MAX(technology) technology, MAX(gen_state_value_id) gen_state_value_id , MAX(generator) generator,
	MAX(generator_group) generator_group, MAX(env_product) env_product, [Year] , tier_type , MAX([Tier]) [Tier], SUM([target]) [target], MAX(total_target) total_target, MAX(Net_total) Net_total, MAX(state_value_id) state_value_id, MAX(jurisdiction) jurisdiction
	FROM #target_without_grouping  WHERE [target] IS NOT NULL GROUP BY tier_type, [Year]
END
ELSE
BEGIN
	INSERT INTO #target_without_grouping2(assigned , banked , Net , technology , gen_state_value_id , generator ,
	generator_group , env_product , [Year] , tier_type , [Tier] , [target] , total_target , Net_total , state_value_id , jurisdiction )
	SELECT	SUM(assigned) assigned , SUM(banked) banked , MAX(Net) Net, MAX(technology) technology, MAX(gen_state_value_id) gen_state_value_id , MAX(generator) generator,
	MAX(generator_group) generator_group, MAX(env_product) env_product, [Year] , tier_type , MAX([Tier]) [Tier], SUM([target]) [target], MAX(total_target) total_target, MAX(Net_total) Net_total, MAX(state_value_id) state_value_id, MAX(jurisdiction) jurisdiction
	FROM #target_without_grouping  WHERE [target] IS NOT NULL GROUP BY tier_type, [Year]
END


--select * from #target_without_grouping2
--return
update #target_without_grouping2 set [target]=[target] +isnull(s.[deal_volume],0) from #target_without_grouping2  t 
cross apply
(
select sum([deal_volume]) [deal_volume] 
 from  #target_deal_volume_sales where  term_start=t.[year] and tier_type=t.tier_type and state_value_id is not null
) s

--update #target_without_grouping2 set [target]=[target] +isnull(s.[deal_volume],0) from #target_without_grouping2  t 
--cross apply
--(
--select sum([deal_volume]) [deal_volume] from  #target_deal_volume_sales where  term_start=t.[year] and tier_type=t.tier_type

--) s



DELETE from #target_without_grouping

INSERT INTO #target_without_grouping(assigned , banked , Net , technology , gen_state_value_id , generator ,
generator_group , env_product , [Year] , tier_type , [Tier] , [target] , total_target , Net_total , state_value_id , jurisdiction )
SELECT	assigned , banked , Net , technology , gen_state_value_id , generator ,
generator_group , env_product , [Year] , tier_type , [Tier] , [target] , total_target , Net_total , state_value_id , jurisdiction 
FROM #target_without_grouping2 

--total of assigned is populated here
INSERT INTO #assigned_total(term_yr, assigned_total)
SELECT t.[Year], SUM(t.assigned) assigned
FROM #target_without_grouping t
WHERE t.Tier NOT LIKE '%-Constraint'
GROUP BY t.[Year]


	--select * from #target_without_grouping where tier_type = 300722
--Net is calcalated here after target for energy efficiency and instate columns have been determined
SET @sql ='UPDATE r SET Net =  ISNULL(assigned,0) - ISNULL([target],0) + ' + CASE WHEN  @report_type = 'i' THEN 'banked' ELSE '0' END + '
FROM 
#target_without_grouping r'

EXEC(@sql)
--return
--select * from #target_without_grouping
--select * from #assigned_total
--select * from #banked_deals_without_tier
	--select * from #assigned_total
	
	--return
--Net total is also calculated here after assigned total and total target have been determined
--set @sql = 'UPDATE r SET Net_total =  ISNULL((assigned_total),0) - ISNULL((t.[total_target]),0) +
--+ CASE WHEN ''' + @report_type + '''= ''i'' THEN ISNULL((bdwt.total_volume),0)  ELSE 0 END 
----return
----select ISNULL((assigned_total),0) , ISNULL((t.[total_target]),0) ,bdwt.total_volume, r.[year]
--FROM 
--	 --SELECT assigned_total, t.[total_target],bdwt.total_volume,r.[year] from
--	 #target_without_grouping r 
--	 CROSS APPLY 
--	 (
--		SELECT SUM([target]) total_target from #target_without_grouping t
--		where t.[Year] = r.[year]
--		--and 
--		group by [Year]
--	 ) t
--	 INNER JOIN #assigned_total at ON at.term_yr = r.[year]
--	 LEFT JOIN (select SUM(total_volume) total_volume, term_yr 
--	 FROM #banked_deals_without_tier
--	 GROUP BY term_yr) bdwt ON bdwt.term_yr < CASE WHEN r.[year] = ' + CAST(@comp_yr_from AS VARCHAR) + ' THEN r.[year] 
--	 ELSE 1 END
--	 OR bdwt.term_yr = r.[year]'
--		--AND bdwt.state_value_id = r.state_value_id
--PRINT @sql
--EXEC(@sql)

--return

set @sql = 'UPDATE twg SET Net_total =  ISNULL((assigned_total),0) - ISNULL((a.[total_target]),0) +
+ CASE WHEN ''' + @report_type + '''= ''i'' THEN ISNULL((a.total_volume),0)  ELSE 0 END 
--return
FROM #target_without_grouping twg
INNER JOIN
(
SELECT ISNULL(max(assigned_total),0) assigned_total , ISNULL(max(t.[total_target]),0) [total_target] ,SUM(bdwt.total_volume) total_volume, r.[year]
--select r.[year],max(t.total_target), SUM(bdwt.total_volume)
--select t.*
FROM 
	 --SELECT assigned_total, t.[total_target],bdwt.total_volume,r.[year] from
	( select r.year from #target_without_grouping r group by r.year) r
	 CROSS APPLY 
	 (
		SELECT SUM([target]) total_target, t.[year] from #target_without_grouping t
		where t.[Year] = r.[year]
		--and 
		group by [Year]
	 ) t
	 INNER JOIN #assigned_total at ON at.term_yr = r.[year]
	 LEFT JOIN (
	 select sum(total_volume) total_volume,  term_yr from
	 (select SUM(total_volume) total_volume, term_yr
	 FROM #banked_deals_without_tier bdwt
	 GROUP BY term_yr) bdwt2 
	 GROUP BY term_yr )bdwt ON
	 bdwt.term_yr < CASE WHEN r.[year] = ' + CAST(@comp_yr_from AS VARCHAR) + ' THEN t.[year] 
	 ELSE 1 END
	 OR
	  bdwt.term_yr = r.[year]
	 group by r.[year]
) a ON a.[year] = twg.year'

--PRINT @sql
EXEC(@sql)

UPDATE r SET r.[target] = CASE WHEN (r.total_target-(a.volume-b.volume2))<0 THEN 0 ELSE r.total_target-(a.volume-b.volume2) END 
FROM 
--SELECT total_target, a.volume,total_target-a.volume FROM 
#target r
 CROSS APPLY (
 	SELECT SUM(twg.[target]) volume 
 	FROM #target twg
 	WHERE twg.[YEAR] = r.[YEAR] 
 		AND twg.state_value_id = r.state_value_id
		AND twg.[target] IS NOT NULL 
		AND twg.[Tier] NOT LIKE '%-Constraint' 
 ) a 
CROSS APPLY (
	SELECT SUM(twg2.[target]) volume2 
	FROM #target twg2 WHERE twg2.[YEAR] = r.[YEAR] 
		AND twg2.state_value_id = r.state_value_id
		AND twg2.[target] IS NOT NULL 
		AND twg2.[TIER] LIKE '%-Constraint'
) b WHERE [Tier] = 'Energy Efficiency'

UPDATE #target SET [target] = it.volume 
FROM #target r 
INNER JOIN #inventory_table it ON r.[YEAR]=it.[YEAR]
	AND r.tier_type = it.VALUE_id 
	AND r.state_value_id = it.state_value_id
WHERE it.volume < r.[target] 
	AND it.Tier = 'Energy Efficiency'

UPDATE r SET r.[target] = case when (r.total_target-(a.volume-b.volume2))<0 THEN 0 ELSE r.total_target-(a.volume-b.volume2) END 
FROM #target r
CROSS APPLY (
 	SELECT SUM(twg.[target]) volume 
 	FROM #target twg
 	WHERE twg.[YEAR] = r.[YEAR] 
 		AND twg.state_value_id = r.state_value_id
		AND twg.[target] IS NOT NULL 
		AND twg.[Tier] NOT LIKE '%-Constraint' 
 ) a 
CROSS APPLY (
	SELECT SUM(twg2.[target]) volume2 
	FROM #target twg2 
	WHERE twg2.[YEAR] = r.[YEAR] 
		AND twg2.state_value_id = r.state_value_id
 		AND twg2.[target] IS NOT NULL
 		AND twg2.[TIER] LIKE '%-Constraint'
) b 
WHERE [Tier] = 'In State'

DECLARE @tiers VARCHAR(1000), @tiers_with_banked VARCHAR(1000), @add_up_assign_tiers VARCHAR(1000), @tiers_with_isnull VARCHAR(8000), @tiers_with_isnull_check_zero VARCHAR(MAX)
	
-- update priority in target table according to state rec requirement data id determined from nearest priority to run date logic
-- calculated at the top of page
UPDATE td
SET priority = rapo_prd.priority
FROM #target td
INNER JOIN (
	SELECT rapd.rec_assignment_priority_group_id, rapo.priority_type_value_id tier_type, rapo.order_number priority 
	FROM rec_assignment_priority_order rapo
	INNER JOIN rec_assignment_priority_detail rapd ON rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
	INNER JOIN state_rec_requirement_data srrd ON srrd.rec_assignment_priority_group_id = rapd.rec_assignment_priority_group_id
		--AND srrd.state_rec_requirement_data_id = @nearest_state_rec_requirement_data_id
	INNER JOIN #nearest_state_rec_requirement_data_id nsrrdi On nsrrdi.state_rec_requirement_data_id = srrd.state_rec_requirement_data_id
		AND nsrrdi.state_value_id = srrd.state_value_id
) rapo_prd ON td.tier_type = rapo_prd.tier_type

--select * from #target
--select * from #banked_Deals
-- determine the tiers ordered by priority
SELECT @tiers = STUFF((
						(SELECT  '],['  + CAST(Tier AS VARCHAR(max))  
						FROM #target GROUP BY tier ORDER BY ISNULL(max(priority),99999) FOR XML PATH(''), root('MyString'), type 
			 ).value('/MyString[1]','varchar(max)')
					), 1, 2, '') 

--SELECT @tiers_with_banked = STUFF((
--					(SELECT  '],ISNULL([' + banked + '],0) ['  +  CAST(banked AS VARCHAR(max))  
--					FROM #target GROUP BY tier ORDER BY ISNULL(max(priority),99999) FOR XML PATH(''), root('MyString'), type 
--		 ).value('/MyString[1]','varchar(max)')
--				), 1, 2, '') 

select @tiers_with_banked = SUM(banked) FROM #target

-- populate variable with tiers ordered by priority and containing ISNULL
SELECT @tiers_with_isnull = STUFF((
					(SELECT  '],ISNULL([' + Tier + '],0) ['  +  CAST(Tier AS VARCHAR(max))  
					FROM #target GROUP BY tier ORDER BY ISNULL(max(priority),99999) FOR XML PATH(''), root('MyString'), type 
		 ).value('/MyString[1]','varchar(max)')
				), 1, 2, '') 

-- populate variable with tiers apart from constraint tiers ordered by priority
SELECT @add_up_assign_tiers = STUFF((
					(SELECT  '],0)+ISNULL([' + CAST(Tier AS VARCHAR(max)) 
					FROM #target where tier not like '%-Constraint' GROUP BY tier ORDER BY max(priority) FOR XML PATH(''), root('MyString'), type 
		 ).value('/MyString[1]','varchar(max)')
				), 1, 5, '') 
					
	--select * from #target_without_grouping
IF NOT EXISTS(SELECT 1 FROM #target) -- display only heading in case of no data
BEGIN
	SET @sql = 'SELECT [Year], NULL [Type] ' + @str_batch_table + ' FROM #target' 
	--PRINT @sql
	EXEC(@sql)
END
ELSE
BEGIN -- final output
	IF @summary_option = 's'
	BEGIN
		SET @sql = '
		SELECT CASE ROW_NUMBER() OVER (partition BY [Year2] order BY [Year2],[order])
		WHEN 1 THEN [Year2] ELSE NULL END 
		[Year] , Type
		' + CASE WHEN ISNULL(@summary_option, 'a') = 't' THEN ', [Technology] AS [Technology]' 
		WHEN ISNULL(@summary_option, 'a') = 'p' THEN ',[Technology] AS [Technology], [gen_state_value_id] as [Gen State]'
		WHEN ISNULL(@summary_option, 'a') = 'g' THEN ',[generator] as [Generator]' 
		WHEN ISNULL(@summary_option, 'a') = 'h' THEN ',[generator_group] as [Generator Group]'
		WHEN ISNULL(@summary_option, 'a') = 'e' THEN ',[Env_product] as [Env Product]' ELSE '' END + ' , 
		 ' + @tiers + '], Total 
		 ' + @str_batch_table + '
		 FROM(
		SELECT [Year] as Year2 , Type , NULL Technology, NULL gen_state_value_id, NULL generator, NULL generator_group,
		NULL env_product, ' + @tiers_with_isnull + '], total_target as total, 1 [order] 
		FROM 
		(SELECT [Year], [Target], ''Target/Sales'' [Type], Tier, ta.total_target total_target from #target_without_grouping twg
		CROSS APPLY
			( select ISNULL(t.total_target,0) total_target FROM
					(
						SELECT SUM([target]) total_target,year from #target_without_grouping group by [year]
					) t where t.year = twg.year
			) ta
		) AS sourceTable
		PIVOT
		(SUM([Target]) FOR Tier IN ( ' + @tiers + ']))
		AS PIVOTTable
		UNION ALL 
		SELECT [Year] as Year2, Type, Technology, gen_state_value_id, generator, generator_group, env_product,
		' + @tiers_with_isnull + '], ' + @add_up_assign_tiers  + '],0) total, 2 [order] 
		FROM 
		(SELECT [Year], [Assigned], ''Assigned/Transfer'' [Type], Technology, gen_state_value_id, generator, generator_group,
		env_product, Tier from #target_without_grouping where Assigned <> 0) as sourceTable2
		PIVOT
		' + CASE WHEN @report_type = 'a' THEN + '
		(MAX([Assigned]) FOR Tier IN ( ' + @tiers + ']))  '  ELSE + '
		(SUM([Assigned]) FOR Tier IN ( ' + @tiers + '])) '  END + '
		PIVOTTable2 ' + CASE WHEN @report_type = 'i' THEN '
		UNION ALL 
		SELECT [Year] as Year2, Type, Technology, gen_state_value_id, generator, generator_group, env_product,
		' + @tiers_with_isnull + '], total, 3 [order] 
		FROM 
		(SELECT [Year], [Banked], ''Banked/Purchases'' [Type], Technology, gen_state_value_id, generator, generator_group, env_product,ta.total total,
		Tier from #target twg CROSS APPLY
			( select ISNULL(t.total,0) total FROM
					(
						SELECT max(banked_total) total,[year] from #target group by [year]
					) t where t.[year] = twg.[year]
			) ta where Banked <> 0 ) AS sourceTable
		PIVOT
		(SUM([Banked]) FOR Tier IN ( ' + @tiers + ']))
		PIVOTTable2 ' ELSE '' END + '
		UNION ALL 
		SELECT  [Year] as Year2, ''<b>'' + Type + ''<b>'',  ''<b>'' + Technology +  ''</b>'', ''<b>'' + gen_state_value_id + ''</b>'',
		''<b>'' + generator + ''</b>'', ''<b>'' + generator_group + ''</b>'', ''<b>'' + env_product + ''</b>'',
		' + @tiers_with_isnull + '], total, 4 [order] 
		FROM 
		(SELECT [Year], [Net], ''Net'' [Type], Technology, gen_state_value_id, generator, generator_group,
		env_product, Tier, ta.Net_total total from #target_without_grouping twg
		CROSS APPLY
			( select ISNULL(t.Net_total,0) Net_total FROM
					(
						SELECT MAX(Net_total) Net_total, year  from #target_without_grouping group by [year]
					) t where t.year = twg.year
			) ta
		) as sourceTable2
		PIVOT
		(MAX([Net]) FOR Tier IN ( ' + @tiers + ']))
		PIVOTTable2) a ORDER BY [Year2],[order]
		'
	END
	ELSE
	BEGIN
		set @sql = '
		SELECT CASE ROW_NUMBER() OVER (partition BY [Year2] order BY [Year2],[order])
		WHEN 1 THEN [Year2] ELSE NULL END 
		[Year] , Type
		' + CASE WHEN ISNULL(@summary_option, 'a') = 't' THEN ', [Technology] AS [Technology]' 
		WHEN ISNULL(@summary_option, 'a') = 'p' THEN ',[Technology] AS [Technology], [gen_state_value_id] as [Gen State]'
		WHEN ISNULL(@summary_option, 'a') = 'g' THEN ',[generator] as [Generator]' 
		WHEN ISNULL(@summary_option, 'a') = 'h' THEN ',[generator_group] as [Generator Group]'
		WHEN ISNULL(@summary_option, 'a') = 'e' THEN ',[Env_product] as [Env Product]' ELSE '' END + ' , 
		' + @tiers + '], Total 
		' + @str_batch_table + '
		FROM(
		SELECT [Year] as Year2 , ''Target'' [Type] , NULL Technology, NULL gen_state_value_id, NULL generator, NULL generator_group,
		NULL env_product, ' + @tiers_with_isnull + '], total_target as total, 1 [order] FROM 
		(select [Year], [Target],  Tier, ta.total_target from #target_without_grouping twg
			CROSS APPLY
			( select ISNULL(t.total_target,0) total_target FROM
					(
						SELECT SUM([target]) total_target,year from #target_without_grouping group by [year]
					) t where t.year = twg.year
			) ta
		) AS sourceTable
		PIVOT
		(SUM([Target]) FOR Tier IN ( ' + @tiers + ']))
		AS PIVOTTable
		UNION ALL 
		SELECT [Year] as Year2, Type, Technology, gen_state_value_id, generator, generator_group, env_product,
		' + @tiers_with_isnull + '], ' + @add_up_assign_tiers  + '],0) total, 2 [order] 
		FROM 
		(SELECT [Year], [Assigned], ''Assigned'' [Type], Technology, gen_state_value_id, generator, generator_group,
		env_product, Tier FROM #target where Assigned <> 0) as sourceTable2
		PIVOT
		(SUM([Assigned]) FOR Tier IN ( ' + @tiers + ']))
		PIVOTTable2 ' + CASE WHEN @report_type = 'i' THEN '
		UNION ALL 
		SELECT [Year] as Year2, Type, Technology, gen_state_value_id, generator, generator_group, env_product,
		' + @tiers_with_isnull + '], total, 3 [order] 
		FROM 
		(SELECT [Year], [Banked], ''Banked'' [Type], Technology, gen_state_value_id, generator, generator_group, env_product,ta.total total,
		Tier from #target twg 
		' + CASE WHEN @summary_option = 't' THEN ' CROSS APPLY
			( select ISNULL(t.total,0) total FROM
					(
						SELECT MAX(banked_total) total, [year], technology from #target group by [year], technology--, state_value_id
					) t where t.[year] = twg.[year] and t.technology = twg.technology-- and t.state_value_id = twg.state_value_id
			) ta where Banked <> 0 ) AS sourceTable
		' WHEN @summary_option = 'p' THEN ' CROSS APPLY
			( select ISNULL(t.total,0) total FROM
					(
						SELECT max(banked_total) total, [year], technology, gen_state_value_id from #target group by [year], technology, gen_state_value_id
					) t where t.[year] = twg.[year] and t.technology = twg.technology
					and t.gen_state_value_id = twg.gen_state_value_id
			) ta where Banked <> 0 ) AS sourceTable'
		 WHEN @summary_option = 'g' THEN ' CROSS APPLY
			( select ISNULL(t.total,0) total FROM
					(
						SELECT max(banked_total) total, [year], generator from #target group by [year], generator
					) t where t.[year] = twg.[year] and t.generator = twg.generator
			) ta where Banked <> 0 ) AS sourceTable'
		WHEN @summary_option = 'h' THEN ' CROSS APPLY
			( select ISNULL(t.total,0) total FROM
					(
						SELECT max(banked_total) total, [year], generator_group from #target group by [year], generator_group
					) t where t.[year] = twg.[year] and ISNULL(t.generator_group,-1) = ISNULL(twg.generator_group,-1)
			) ta where Banked <> 0 ) AS sourceTable'
		WHEN @summary_option = 'e' THEN ' CROSS APPLY
			( select ISNULL(t.total,0) total FROM
					(
						SELECT max(banked_total) total, [year], env_product from #target group by [year], env_product
					) t where t.[year] = twg.[year] and t.env_product = twg.env_product
			) ta where Banked <> 0 ) AS sourceTable'
		ELSE '' END + '
		PIVOT
		(AVG([Banked]) FOR Tier IN ( ' + @tiers + ']))
		PIVOTTable2 ' ELSE '' END + '
		UNION ALL 
		SELECT  [Year] as Year2, ''<b>'' + Type + ''<b>'',  ''<b>'' + Technology +  ''</b>'', ''<b>'' + gen_state_value_id + ''</b>'',
		''<b>'' + generator + ''</b>'', ''<b>'' + generator_group + ''</b>'', ''<b>'' + env_product + ''</b>'',
		' + @tiers_with_isnull + '], total, 4 [order] 
		FROM 
		(SELECT [Year], [Net], ''Net'' [Type], Technology, gen_state_value_id, generator, generator_group,
		env_product, Tier, ta.Net_total total FROM #target_without_grouping twg
		CROSS APPLY
			( select ISNULL(t.Net_total,0) Net_total FROM
					(
						SELECT MAX(Net_total) Net_total, year  from #target_without_grouping group by [year]
					) t where t.year = twg.year
			) ta
		) as sourceTable2
		PIVOT
		(AVG([Net]) FOR Tier IN ( ' + @tiers + ']))
		PIVOTTable2) a ORDER BY [Year2],[order]
		'
	END
	--PRINT @sql
	EXEC(@sql)
END

--select * from #target_without_grouping

--select * from #target
/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1
 
BEGIN
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 
	EXEC (@str_batch_table)
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_target_report', 'Target Report') --TODO: modify sp and report name
 
	EXEC (@str_batch_table)
 
	RETURN
 
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
 
IF @enable_paging = 1 AND @page_no IS NULL
 
BEGIN
 
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no)
 
	EXEC (@sql_paging)
 
END
 
/*******************************************2nd Paging Batch END**********************************************/
