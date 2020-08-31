

/****** Object:  StoredProcedure [dbo].[spa_auto_matching_limit_validation]    Script Date: 11/12/2012 11:16:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_auto_matching_limit_validation]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_auto_matching_limit_validation]
GO

/****** Object:  StoredProcedure [dbo].[spa_auto_matching_limit_validation]    Script Date: 11/12/2012 11:16:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_auto_matching_limit_validation]
	 @as_of_date DATETIME
	,@user_login_id VARCHAR(30)
	,@process_id VARCHAR(250)
	,@forecated_tran VARCHAR(1)='n'--@forecated_tran=y for hypo (gen_deal_header_id) and n for perfect hedge(source_deal_header_id)
	,@call_from CHAR(1) = 'g'
	,@sub_ids VARCHAR(100)=2
	,@limit_bucketing VARCHAR(3)=NULL
AS

/*
declare  @as_of_date datetime='2012-12-31'
,@user_login_id varchar(30) = 'RE64581'
,@process_id varchar(250)='6F1248E1_65B5_4253_BF00_313D4C80AB54',@forecated_tran varchar(1)='n',@sub_ids varchar(800)='2',@limit_bucketing varchar(3)='DE'
	CLOSE link_term
	DEALLOCATE link_term
	CLOSE link_term1
	DEALLOCATE link_term1

drop table adiha_process.dbo.hedge_capacity_RE64582_test
CLOSE hedge_under
DEALLOCATE hedge_under
--select * from adiha_process.dbo.hedge_capacity_farrms_admin_3839D78A_9713_4182_BE73_ED19B070D23B

--*/

EXEC spa_print 'ttttttttttttttttttttttttttttttttttttttttttt'
EXEC spa_print 'Start spa_auto_matching_limit_validation'
EXEC spa_print 'ttttttttttttttttttttttttttttttttttttttttttt'


IF OBJECT_ID('tempdb..#link_used_vol') IS NOT NULL
DROP TABLE #link_used_vol

IF OBJECT_ID('tempdb..#tmp_uder_limit_links') IS NOT NULL
DROP TABLE #tmp_uder_limit_links

IF OBJECT_ID('tempdb..#tmp_links') IS NOT NULL
DROP TABLE #tmp_links

IF OBJECT_ID('tempdb..#hedge_under') IS NOT NULL
DROP TABLE #hedge_under

IF OBJECT_ID('tempdb..#limit_applied_link') IS NOT NULL
DROP TABLE #limit_applied_link

IF OBJECT_ID('tempdb..#dice_link') IS NOT NULL
DROP TABLE #dice_link

IF OBJECT_ID('tempdb..#hedge_capacity_check') IS NOT NULL
DROP TABLE #hedge_capacity_check

DECLARE  @limit_check_vol NUMERIC(12,2)
SET @limit_check_vol=100

DECLARE @url VARCHAR(500)
DECLARE @desc VARCHAR(500)
DECLARE @errorMsg VARCHAR(200)
DECLARE @errorcode VARCHAR(1)
DECLARE @url_desc VARCHAR(500),@st VARCHAR(MAX)
DECLARE @max_month_term DATETIME
DECLARE @total_used_vol FLOAT,@total_deal_vol FLOAT,@perfect_hedge VARCHAR(1)

DECLARE @fas_sub_id INT,@fas_stra_id INT ,@fas_book_id INT,@term_start DATETIME,@term_end DATETIME
	,@term_match_criteria VARCHAR(1),@abs_net_vol NUMERIC(26,10),@net_vol  NUMERIC(26,10),@dedesignate_frequency  VARCHAR(1),@sort_order  VARCHAR(1)
	,@dedesignate_look_in  VARCHAR(1),@buy_sell  VARCHAR(1),@FIFO_LIFO  VARCHAR(1),@link_id INT ,@run_total NUMERIC(28,12)
	,@deal_volume NUMERIC(28,12),@delta_per NUMERIC(16,2),@used_vol NUMERIC(26,10),@no_term INT,@apply_limit FLOAT

DECLARE @hedge_capacity   VARCHAR(250), @curve_id INT,@entity_id INT,@no_month INT
SET @hedge_capacity= dbo.FNAProcessTableName('hedge_capacity', @user_login_id, @process_id)
SET @sort_order='f'
SET @dedesignate_look_in='i'
SET @FIFO_LIFO='f'

IF OBJECT_ID(@hedge_capacity) IS NULL
BEGIN
	EXEC spa_print @hedge_capacity
	CREATE TABLE #hedge_capacity_check(
		fas_sub_id INT,
		fas_str_id INT,
		fas_book_id INT,
		curve_id INT,
		fas_sub VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
		fas_str VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
		fas_book VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
		IndexName VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
		TenorBucket VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
		TenorStart DATETIME,
		TenorEnd DATETIME,
		vol_frequency VARCHAR(50) COLLATE DATABASE_DEFAULT,
		vol_uom VARCHAR(100) COLLATE DATABASE_DEFAULT,
		net_asset_vol NUMERIC(38,20),
		net_item_vol NUMERIC(38,20),
		net_available_vol NUMERIC(38,20),
		over_hedge VARCHAR(3) COLLATE DATABASE_DEFAULT  ,net_vol NUMERIC(26,10)
	)
	--set @sub_ids='2'
	
	DECLARE @st_as_of_date VARCHAR(10)
	SET @st_as_of_date=CONVERT(VARCHAR(10),@as_of_date ,120)

	INSERT INTO #hedge_capacity_check (fas_sub_id ,fas_str_id ,fas_book_id ,curve_id ,fas_sub ,fas_str ,fas_book ,IndexName ,
		TenorBucket,TenorStart ,TenorEnd  ,vol_frequency ,vol_uom ,net_asset_vol ,net_item_vol ,net_available_vol ,over_hedge)
	EXEC spa_Create_Available_Hedge_Capacity_Exception_Report @st_as_of_date,@sub_ids, NULL, NULL,'c','l',NULL,'a',402,'f','b',@forecated_tran,@limit_bucketing

	UPDATE #hedge_capacity_check SET net_vol=ABS(ABS(ISNULL(net_asset_vol,0))-ABS(ISNULL(net_item_vol,0)))	* CASE WHEN ISNULL(net_asset_vol,0)<0 THEN -1 ELSE 1 END	

	--update #hedge_capacity_check set net_vol=abs(isnull(net_asset_vol,0)-isnull(net_item_vol,0))

	SET @st	='select *  into '+@hedge_capacity+ ' from #hedge_capacity_check  where over_hedge=''No'' and isnull(net_vol,0)<>0 '
	EXEC(@st)
	
	IF @@ROWCOUNT<1
		GOTO end_command
END


SET @fas_sub_id=NULL
SET @fas_stra_id =NULL
SET @entity_id=NULL

SET @dedesignate_frequency='t'
			
SELECT DISTINCT link_id INTO #dice_link FROM gen_fas_link_detail_dicing --where link_id=@link_id


EXEC spa_print '@@@@@@@@@@@@@@loop for under hedge @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

CREATE TABLE #tmp_uder_limit_links(ROWID INT IDENTITY(1,1),link_id INT,deal_volume NUMERIC(26,10),run_total  NUMERIC(26,10),term_start DATETIME ,term_end DATETIME)
CREATE TABLE #tmp_links  (ROWID INT IDENTITY(1,1),gen_link_id INT,deal_number INT ,used_vol NUMERIC(26,12),d_vol NUMERIC(26,12),d_date DATETIME)
CREATE TABLE #hedge_under (ROWID INT IDENTITY(1,1),entity_id INT,curve_id INT,term_start DATETIME, term_end DATETIME,net_vol NUMERIC(26,10),available_vol NUMERIC(26,10))
CREATE TABLE #limit_applied_link(link_id INT)

CREATE TABLE #link_used_vol (term_start DATETIME,used_vol NUMERIC(26,10) ,available_vol  NUMERIC(26,10),percentage_included  NUMERIC(6,4),deal_vol  NUMERIC(26,10) ) 




exec spa_print 'insert into #hedge_under (entity_id ,curve_id ,term_start,term_end, net_vol ,available_vol
SELECT fas_sub_id, curve_id ,tenorstart,tenorEnd, sum(net_vol) net_vol,sum(net_vol) net_vol FROM ', @hedge_capacity, ' 
where over_hedge=''No'' and isnull(net_vol,0)<>0  --and curve_id=345
group by fas_sub_id,curve_id ,tenorstart,tenorEnd'

EXEC('insert into #hedge_under (entity_id ,curve_id ,term_start,term_end, net_vol ,available_vol)
SELECT fas_sub_id, curve_id ,tenorstart,tenorEnd, sum(net_vol) net_vol,sum(net_vol) net_vol
 FROM '+ @hedge_capacity+ ' where over_hedge=''No'' and isnull(net_vol,0)<>0  --and curve_id=742
group by fas_sub_id,curve_id ,tenorstart,tenorEnd')

--SELECT *  FROM #hedge_under 
DECLARE @run_within VARCHAR(1)
--loop for under hedge
DECLARE hedge_under CURSOR FOR 
	SELECT DISTINCT entity_id, curve_id   FROM #hedge_under  --where curve_id=742
OPEN hedge_under
FETCH NEXT FROM hedge_under INTO @entity_id, @curve_id 
WHILE @@FETCH_STATUS = 0
BEGIN
	
		--SELECT curve_id,term_start ,term_end, datediff(month,term_start ,term_end) no_month,net_vol  FROM #hedge_under 
		--where entity_id=@entity_id and  curve_id=@curve_id and term_start='2013-04-01' order by term_start,term_end

	DECLARE link_term CURSOR FOR 
		SELECT term_start ,term_end, DATEDIFF(MONTH,term_start ,term_end) no_month,net_vol  FROM #hedge_under 
		WHERE entity_id=@entity_id AND  curve_id=@curve_id AND DATEDIFF(MONTH,term_start ,term_end)<>0  --and term_start='2014-01-01'  
		ORDER BY term_end DESC,term_start
	OPEN link_term
	FETCH NEXT FROM link_term INTO @term_start ,@term_end,@no_month,@net_vol
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @run_within='y'
		SET @term_match_criteria='p'
		
		EXEC spa_print '@net_vol:' 
		EXEC spa_print @net_vol	
		
		IF @net_vol<0 
			SET @buy_sell='b'
		ELSE
			SET @buy_sell='s'
			
		SET @term_end=DATEADD(MONTH,1,@term_end)-1
		
		
uder_limit_links:
		EXEC spa_print '@term_match_criteria:', @term_match_criteria

		SET @abs_net_vol=ABS(@net_vol)

	
		--select  @fas_sub_id,@fas_stra_id ,@fas_book_id,@term_start,@term_end,@term_match_criteria,@abs_net_vol,
		--	@dedesignate_frequency,null,@sort_order,@dedesignate_look_in,@buy_sell,@process_id,@forecated_tran
		--EXEC spa_print 'exec spa_get_uder_limit_links ' + ISNULL(CAST(@entity_id AS VARCHAR),'null')+','+ISNULL(CAST(@fas_stra_id AS VARCHAR),'null')
		 --+','+ ISNULL(CAST(@fas_book_id AS VARCHAR),'null')+','''+CONVERT(VARCHAR(10),@term_start,120)+''',''' +CONVERT(VARCHAR(10),@term_end,120)
		 -- +''',''' +@term_match_criteria +''',' +LTRIM(STR(@abs_net_vol ,30,10))+','''+@dedesignate_frequency+''','
		--  + ISNULL(CAST(@curve_id AS VARCHAR),'null')+',''' +@sort_order+''','''+@dedesignate_look_in+''','''+ @buy_sell+''','''+ @process_id
		--  +''','''+@forecated_tran+''''

		INSERT INTO #tmp_uder_limit_links 
		EXEC spa_get_uder_limit_links @entity_id,@fas_stra_id ,@fas_book_id,@term_start,@term_end,@term_match_criteria,@abs_net_vol,
			@dedesignate_frequency,@curve_id,@sort_order,@dedesignate_look_in,@buy_sell,@process_id,@forecated_tran

		IF @@ROWCOUNT>0
		BEGIN
			EXEC spa_print ' #limit_applied_link'
			--select *  from #tmp_uder_limit_links
			INSERT INTO #limit_applied_link(link_id) SELECT DISTINCT link_id FROM #tmp_uder_limit_links
			
			SELECT @link_id=link_id ,@run_total=run_total,@deal_volume=deal_volume FROM #tmp_uder_limit_links t INNER  JOIN 
			(
				SELECT MAX(rowid) rowid FROM #tmp_uder_limit_links
			) mx ON mx.rowid=t.rowid
				
			EXEC spa_print '@curve_id:'
			EXEC spa_print @curve_id
			EXEC spa_print @term_start 
			EXEC spa_print @term_end
				
			EXEC spa_print '@run_total:'
			EXEC spa_print @run_total
			EXEC spa_print '@deal_volume:'
			EXEC spa_print @deal_volume
			EXEC spa_print '@abs_net_vol:'
			EXEC spa_print @abs_net_vol
			
			IF @run_total<@abs_net_vol 
			BEGIN
				EXEC spa_print '@run_total<@abs_net_vol '
				SET @run_within='y'
				UPDATE #hedge_under  SET available_vol=(@abs_net_vol-@run_total)*CASE WHEN @net_vol<0 THEN -1 ELSE 1 END  WHERE  entity_id=@entity_id AND curve_id=@curve_id AND term_start=@term_start
			END
			ELSE IF @run_total=@abs_net_vol 
			BEGIN
				EXEC spa_print '@run_total=@abs_net_vol'
				SET @run_within='n'
				UPDATE #hedge_under  SET available_vol=0  WHERE  entity_id=@entity_id AND curve_id=@curve_id AND term_start=@term_start
			END
			
			ELSE --@run_total>@abs_net_vol 
			BEGIN
				IF (@run_total-@deal_volume<@abs_net_vol AND @abs_net_vol<@run_total) 
				BEGIN
					IF (@run_total=@deal_volume ) --when found only one deal/link
					BEGIN
							EXEC spa_print '@run_total=@deal_volume'
							SET @used_vol=@abs_net_vol
							SET @run_within='n'
							
							UPDATE #hedge_under  SET available_vol=0  WHERE  entity_id=@entity_id AND curve_id=@curve_id AND term_start=@term_start
											
							EXEC spa_modify_per_gen_link @link_id, @used_vol,@FIFO_LIFO ,'i',@forecated_tran 
						
					END
					ELSE IF @run_total-@deal_volume=@abs_net_vol --is not possible case
					BEGIN
							EXEC spa_print '@run_total-@deal_volume=@abs_net_vol (b:  need to check this condition)'
							SET @run_within='n'
							DELETE #tmp_uder_limit_links WHERE  link_id=@link_id

							UPDATE #hedge_under  SET available_vol=0  WHERE  entity_id=@entity_id AND curve_id=@curve_id AND term_start=@term_start
					END
					ELSE
					BEGIN
						EXEC spa_print '@run_total-@deal_volume<@abs_net_vol'
						SET @run_within='n'

						SET @used_vol=@abs_net_vol-(@run_total-@deal_volume)
						
						--update #hedge_under  set available_vol=(@abs_net_vol-(@run_total-@deal_volume))*case when @net_vol<0 then -1 else 1 end where  entity_id=@entity_id and curve_id=@curve_id and term_start=@term_start
						UPDATE #hedge_under  SET available_vol= 0 WHERE  entity_id=@entity_id AND curve_id=@curve_id AND term_start=@term_start
		
						EXEC spa_modify_per_gen_link @link_id, @used_vol,@FIFO_LIFO ,'i',@forecated_tran 
					END
				
				END --@run_total>@abs_net_vol 

			END
		END		--if @@ROWCOUNT>0
		
--select * from  #hedge_under where  entity_id=@entity_id and curve_id=@curve_id and term_start=@term_start
--		return
		
		TRUNCATE TABLE #tmp_uder_limit_links
		
		IF  @run_within='y'
		BEGIN

			IF @term_match_criteria<>'w'
			BEGIN
				SELECT @net_vol=ISNULL(available_vol,0) FROM #hedge_under  WHERE  entity_id=@entity_id AND curve_id=@curve_id AND term_start=@term_start
				IF ABS(@net_vol)>1
				BEGIN
					SET @term_match_criteria='w'
					GOTO uder_limit_links
				END
			END
		END
		
		EXEC spa_print '===================loop cursor link_term==============================================================================='
		
		FETCH NEXT FROM link_term INTO @term_start ,@term_end,@no_month,@net_vol
			
	END
	CLOSE link_term
	DEALLOCATE link_term

---end  apply limit to single term link		
	
-- start apply limit for multi term link

--/*
	EXEC spa_print '===================start multi term bucket limit==============================================================================='
	
	SELECT @max_month_term=MAX(term_start) FROM #hedge_under  
			WHERE  ABS(available_vol)>0 AND entity_id=@entity_id AND curve_id=@curve_id 
			AND CONVERT(VARCHAR(7),term_start,120)=CONVERT(VARCHAR(7),term_end,120) 
	
--select * from #hedge_under


		SET @st='
		select h.gen_link_id,gen.term_start ,gen.term_end,gen.no_term,gen.buy_sell_flag,used_vol ,gen.total_used_vol,gen.total_deal_vol,gen.perfect_hedge
		from 
			 gen_fas_link_header h inner join portfolio_hierarchy ph on ph.entity_id=h.fas_book_id 
			 inner join portfolio_hierarchy ph1 on ph1.entity_id=ph.parent_entity_id and ph1.parent_entity_id='+CAST(@entity_id AS VARCHAR) 
			 +'	inner join 
			 (
				select gfld.gen_link_id,min(sdd.term_start) term_start, max(sdd.term_end) term_end,count(1) no_term
					,max(sdd.buy_sell_flag) buy_sell_flag ,max(sdd.deal_volume * gfld.percentage_included) used_vol
					,sum(sdd.deal_volume * gfld.percentage_included) total_used_vol,sum(sdd.deal_volume) total_deal_vol,max(gflh.perfect_hedge) perfect_hedge
				from  source_deal_detail sdd inner join gen_fas_link_detail gfld 
					on gfld.deal_number= sdd.source_deal_header_id and sdd.Leg=1 
					inner join  gen_fas_link_header gflh on gfld.gen_link_id=gflh.gen_link_id and gfld.hedge_or_item=case when gflh.perfect_hedge=''y'' then ''h'' else ''i'' end
				 left join #dice_link dl on dl.link_id=gfld.gen_link_id
					left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
					where  dl.link_id is null and isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+CAST(@curve_id AS VARCHAR) +'
					 group by gfld.gen_link_id having max(sdd.term_start)<='''+CONVERT(VARCHAR(10),ISNULL(@max_month_term,'2099-01-01'),120) +'''
				union all						
				select gfld.gen_link_id,min(sdd.term_start) term_start, max(sdd.term_end) term_end,count(1) no_term
					,max(sdd.buy_sell_flag) buy_sell_flag ,max(sdd.deal_volume * gfld.percentage_included) used_vol
					,sum(sdd.deal_volume * gfld.percentage_included) total_used_vol,sum(sdd.deal_volume) total_deal_vol,max(gflh.perfect_hedge) perfect_hedge
				from  gen_deal_detail sdd inner join gen_fas_link_detail gfld on gfld.deal_number= sdd.gen_deal_header_id and sdd.Leg=1
					inner join  gen_fas_link_header gflh on gfld.gen_link_id=gflh.gen_link_id and gfld.hedge_or_item=case when gflh.perfect_hedge=''y'' then ''h'' else ''i'' end
					left join #dice_link dl on dl.link_id=gfld.gen_link_id
					left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
					where  dl.link_id is null and isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+CAST(@curve_id AS VARCHAR) +' 
				 group by gfld.gen_link_id having max(sdd.term_start)<='''+CONVERT(VARCHAR(10),ISNULL(@max_month_term,'2099-01-01'),120) +''''
				+CASE WHEN ISNULL(@forecated_tran,'n')='n'	THEN ' union all
					select gfldd.link_id,min(sdd.term_start) term_start, max(sdd.term_end) term_end,count(1) no_term,max(sdd.buy_sell_flag) buy_sell_flag
					,max(sdd.deal_volume * gfldd.percentage_used) used_vol
					,sum(sdd.deal_volume * gfldd.percentage_used) total_used_vol,sum(sdd.deal_volume) total_deal_vol,''n'' perfect_hedge
					 from gen_fas_link_detail_dicing gfldd inner join  #dice_link dl on dl.link_id=gfldd.link_id
					 inner join  '+CASE WHEN ISNULL(@forecated_tran,'n')='n' THEN ' source_deal_detail ' ELSE ' gen_deal_detail ' END +' sdd 
					 on gfldd.source_deal_header_id='+CASE WHEN ISNULL(@forecated_tran,'n')='n' THEN ' sdd.source_deal_header_id  ' ELSE ' sdd.gen_deal_header_id ' END+' and gfldd.term_start=sdd.term_start and sdd.leg=1  
					left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
					where  isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+CAST(@curve_id AS VARCHAR) +' 
				 group by gfldd.link_id having max(sdd.term_start)<='''+CONVERT(VARCHAR(10),ISNULL(@max_month_term,'2099-01-01'),120) +''''
				ELSE '' END
			+ ') gen on gen.gen_link_id=h.gen_link_id 
			left join #limit_applied_link l on h.gen_link_id=l.link_id
			where h.process_id ='''+@process_id+'''  and l.link_id is null
			--	and gen.term_start = ''2013-09-01''  and gen.term_end=''2014-03-31''
			order by gen.term_end desc,gen.no_term desc,h.link_effective_date ,h.gen_link_id
	'		
--exec(@st)

	--select @entity_id,@curve_id,@buy_sell,CONVERT(varchar(10),isnull(@max_month_term,'2099-01-01'),120),@process_id
	SET @st='
		DECLARE multi_term_link CURSOR FOR 
		select h.gen_link_id,gen.term_start ,gen.term_end,gen.no_term,gen.buy_sell_flag,used_vol ,gen.total_used_vol,gen.total_deal_vol,gen.perfect_hedge
		from 
			 gen_fas_link_header h inner join portfolio_hierarchy ph on ph.entity_id=h.fas_book_id 
			 inner join portfolio_hierarchy ph1 on ph1.entity_id=ph.parent_entity_id and ph1.parent_entity_id='+CAST(@entity_id AS VARCHAR) 
			 +'	inner join 
			 (
				select gfld.gen_link_id,min(sdd.term_start) term_start, max(sdd.term_end) term_end,count(1) no_term
					,max(sdd.buy_sell_flag) buy_sell_flag ,max(sdd.deal_volume * gfld.percentage_included) used_vol
					,sum(sdd.deal_volume * gfld.percentage_included) total_used_vol,sum(sdd.deal_volume) total_deal_vol,max(gflh.perfect_hedge) perfect_hedge
				from  source_deal_detail sdd inner join gen_fas_link_detail gfld 
					on gfld.deal_number= sdd.source_deal_header_id and sdd.Leg=1 
					inner join  gen_fas_link_header gflh on gfld.gen_link_id=gflh.gen_link_id and gfld.hedge_or_item=case when gflh.perfect_hedge=''y'' then ''h'' else ''i'' end
				 left join #dice_link dl on dl.link_id=gfld.gen_link_id
					left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
					where  dl.link_id is null and isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+CAST(@curve_id AS VARCHAR) +'
					 group by gfld.gen_link_id having max(sdd.term_start)<='''+CONVERT(VARCHAR(10),ISNULL(@max_month_term,'2099-01-01'),120) +'''
				union all						
				select gfld.gen_link_id,min(sdd.term_start) term_start, max(sdd.term_end) term_end,count(1) no_term
					,max(sdd.buy_sell_flag) buy_sell_flag ,max(sdd.deal_volume * gfld.percentage_included) used_vol
					,sum(sdd.deal_volume * gfld.percentage_included) total_used_vol,sum(sdd.deal_volume) total_deal_vol,max(gflh.perfect_hedge) perfect_hedge
				from  gen_deal_detail sdd inner join gen_fas_link_detail gfld on gfld.deal_number= sdd.gen_deal_header_id and sdd.Leg=1
					inner join  gen_fas_link_header gflh on gfld.gen_link_id=gflh.gen_link_id and gfld.hedge_or_item=case when gflh.perfect_hedge=''y'' then ''h'' else ''i'' end
					left join #dice_link dl on dl.link_id=gfld.gen_link_id
					left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
					where  dl.link_id is null and isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+CAST(@curve_id AS VARCHAR) +' 
				 group by gfld.gen_link_id having max(sdd.term_start)<='''+CONVERT(VARCHAR(10),ISNULL(@max_month_term,'2099-01-01'),120) +''''
				+CASE WHEN ISNULL(@forecated_tran,'n')='n'	THEN ' union all
					select gfldd.link_id,min(sdd.term_start) term_start, max(sdd.term_end) term_end,count(1) no_term,max(sdd.buy_sell_flag) buy_sell_flag
					,max(sdd.deal_volume * gfldd.percentage_used) used_vol
					,sum(sdd.deal_volume * gfldd.percentage_used) total_used_vol,sum(sdd.deal_volume) total_deal_vol,''n'' perfect_hedge
					 from gen_fas_link_detail_dicing gfldd inner join  #dice_link dl on dl.link_id=gfldd.link_id
					 inner join  '+CASE WHEN ISNULL(@forecated_tran,'n')='n' THEN ' source_deal_detail ' ELSE ' gen_deal_detail ' END +' sdd 
					 on gfldd.source_deal_header_id='+CASE WHEN ISNULL(@forecated_tran,'n')='n' THEN ' sdd.source_deal_header_id  ' ELSE ' sdd.gen_deal_header_id ' END+' and gfldd.term_start=sdd.term_start and sdd.leg=1  
					left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
					where  isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+CAST(@curve_id AS VARCHAR) +' 
				 group by gfldd.link_id having max(sdd.term_start)<='''+CONVERT(VARCHAR(10),ISNULL(@max_month_term,'2099-01-01'),120) +''''
				ELSE '' END
			+ ') gen on gen.gen_link_id=h.gen_link_id 
			left join #limit_applied_link l on h.gen_link_id=l.link_id
			where h.process_id ='''+@process_id+'''  and l.link_id is null
			--	and gen.term_start = ''2013-09-01''  and gen.term_end=''2014-03-31''
			order by gen.term_end desc,gen.no_term desc,h.link_effective_date ,h.gen_link_id
	'		

	EXEC spa_print '----------------------------------------------------------------'
	EXEC spa_print @st
	EXEC spa_print '----------------------------------------------------------------'
	--return
	EXEC(@st)
	OPEN multi_term_link
	FETCH NEXT FROM multi_term_link INTO @link_id,@term_start,@term_end ,@no_term,@buy_sell,@used_vol,@total_used_vol,@total_deal_vol,@perfect_hedge
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		TRUNCATE TABLE #link_used_vol
		
		IF (SELECT COUNT(1) FROM #hedge_under WHERE  ABS(available_vol)>@limit_check_vol AND entity_id=@entity_id AND curve_id=@curve_id AND term_start BETWEEN @term_start AND @term_end
			AND CONVERT(VARCHAR(7),term_start,120)=CONVERT(VARCHAR(7),term_end,120) 
			AND CASE WHEN @perfect_hedge='y' THEN @buy_sell ELSE CASE WHEN @buy_sell='b' THEN 's' ELSE 'b' END END=CASE WHEN available_vol <0 THEN 'b' ELSE 's' END)=@no_term
		BEGIN
		

		--	apply_whole_check_caller:
		
			IF OBJECT_ID('tempdb..#apply_whole_test') IS NOT NULL
				DROP TABLE #apply_whole_test
			
			SELECT gen.gen_link_id INTO #apply_whole_test FROM
			(
				SELECT gfld.gen_link_id,MIN(CASE WHEN ABS(available_vol)>=(sdd.deal_volume * gfld.percentage_included) THEN 1 ELSE 0 END) apply_whole
				FROM  source_deal_detail sdd INNER JOIN gen_fas_link_detail gfld 
					ON gfld.deal_number= sdd.source_deal_header_id AND sdd.Leg=1  AND gfld.gen_link_id=@link_id 
					INNER JOIN  gen_fas_link_header gflh ON gfld.gen_link_id=gflh.gen_link_id AND gfld.hedge_or_item=CASE WHEN gflh.perfect_hedge='y' THEN 'h' ELSE 'i' END
					LEFT JOIN #hedge_under hu ON sdd.term_start=hu.term_start AND hu.entity_id=@entity_id AND hu.curve_id=@curve_id 
						AND CONVERT(VARCHAR(7),hu.term_start,120)=CONVERT(VARCHAR(7),hu.term_end,120)
					 LEFT JOIN #dice_link dl ON dl.link_id=gfld.gen_link_id
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id 
					WHERE  dl.link_id IS NULL AND ISNULL(spcd.proxy_source_curve_def_id,sdd.curve_id)=@curve_id AND hu.entity_id IS NOT NULL
					 GROUP BY gfld.gen_link_id HAVING MAX(sdd.term_start)<=ISNULL(@max_month_term,'2099-01-01')
					 AND MIN(ISNULL(hu.entity_id,-9999))<>-9999
				UNION ALL						
				SELECT gfld.gen_link_id,MIN(CASE WHEN ABS(available_vol)>=(sdd.deal_volume * gfld.percentage_included) THEN 1 ELSE 0 END) apply_whole
				FROM  gen_deal_detail sdd INNER JOIN gen_fas_link_detail gfld ON gfld.deal_number= sdd.gen_deal_header_id AND sdd.Leg=1 AND gfld.gen_link_id=@link_id 
					INNER JOIN  gen_fas_link_header gflh ON gfld.gen_link_id=gflh.gen_link_id AND gfld.hedge_or_item=CASE WHEN gflh.perfect_hedge='y' THEN 'h' ELSE 'i' END
					LEFT JOIN #hedge_under hu ON sdd.term_start=hu.term_start AND hu.entity_id=@entity_id AND hu.curve_id=@curve_id
						AND CONVERT(VARCHAR(7),hu.term_start,120)=CONVERT(VARCHAR(7),hu.term_end,120)
					LEFT JOIN #dice_link dl ON dl.link_id=gfld.gen_link_id
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id 
					WHERE  dl.link_id IS NULL AND ISNULL(spcd.proxy_source_curve_def_id,sdd.curve_id)=@curve_id  AND hu.entity_id IS NOT NULL
				 GROUP BY gfld.gen_link_id HAVING MAX(sdd.term_start)<=ISNULL(@max_month_term,'2099-01-01')	
				 AND MIN(ISNULL(hu.entity_id,-9999))<>-9999	
			) gen WHERE gen.apply_whole=1
	
			IF @@ROWCOUNT<1
			BEGIN
			
				SELECT @apply_limit=MIN(ABS(hu.available_vol))  FROM #hedge_under hu 
					WHERE  hu.term_start BETWEEN @term_start AND @term_end
						AND  ABS(hu.available_vol)>0 AND hu.entity_id=@entity_id AND hu.curve_id=@curve_id
		
				SET @delta_per=NULL

				IF @apply_limit<@used_vol
					SET @delta_per=@apply_limit/@used_vol
				

			--	select @link_id,@term_start,@term_end ,@no_term,@buy_sell,@used_vol,@apply_limit
				EXEC spa_print '@apply_limit:'
				EXEC spa_print @apply_limit
				EXEC spa_print '@curve_id:'	
				EXEC spa_print @curve_id
				EXEC spa_print '@delta_per:'	
				EXEC spa_print @delta_per
				EXEC spa_print '@used_vol:'	
				EXEC spa_print @used_vol	
				
				IF @delta_per IS NOT NULL
				BEGIN
					IF @apply_limit<@used_vol
					BEGIN 
						EXEC spa_print 'edit link'
						--it will overwrite for hedge_or_item='i'   in isnull(@forecated_tran,'n')='n'	
						UPDATE gen_fas_link_detail SET percentage_included=percentage_included*@delta_per  WHERE gen_link_id=@link_id --and hedge_or_item='h'
												
						IF ISNULL(@forecated_tran,'n')='y'
						BEGIN
							
							UPDATE  sdd SET deal_volume= @apply_limit
							FROM  gen_deal_detail sdd INNER JOIN gen_fas_link_detail gfld 
								ON gfld.deal_number= sdd.gen_deal_header_id  AND sdd.Leg=1  AND gen_link_id=@link_id
						END
						ELSE 
						BEGIN
							UPDATE gen_fas_link_detail SET percentage_included=@delta_per  WHERE gen_link_id=@link_id AND hedge_or_item='i'
						END 
					END
				END
			END --  @apply_whole=0
			
			SET @st='
					insert into #link_used_vol(term_start ,used_vol )
					select gen.term_start,max(gen.used_vol) used_vol
					from (
						select gfld.gen_link_id,deal_number ,sdd.term_start,sdd.term_end,sdd.deal_volume * gfld.percentage_included used_vol,percentage_included,sdd.deal_volume from source_deal_detail
						 sdd inner join gen_fas_link_detail gfld 
							on gfld.deal_number= sdd.source_deal_header_id
							 and sdd.Leg=1 and gfld.gen_link_id='+CAST(@link_id AS VARCHAR) +'
							 inner join  gen_fas_link_header gflh on gfld.gen_link_id=gflh.gen_link_id and gfld.hedge_or_item=case when gflh.perfect_hedge=''y'' then ''h'' else ''i'' end
							left join #dice_link dl on dl.link_id=gfld.gen_link_id
							left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
							where  dl.link_id is null and isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+CAST(@curve_id AS VARCHAR)+'
						union all
						select gfld.gen_link_id,deal_number ,sdd.term_start,sdd.term_end,sdd.deal_volume * gfld.percentage_included used_vol,percentage_included,sdd.deal_volume from  gen_deal_detail 
						 sdd inner join gen_fas_link_detail gfld on gfld.deal_number= sdd.gen_deal_header_id 
							 and sdd.Leg=1 and gfld.gen_link_id='+CAST(@link_id AS VARCHAR) +'
							 inner join  gen_fas_link_header gflh on gfld.gen_link_id=gflh.gen_link_id and gfld.hedge_or_item=case when gflh.perfect_hedge=''y'' then ''h'' else ''i'' end
							 left join #dice_link dl on dl.link_id=gfld.gen_link_id
							left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
							where  dl.link_id is null and isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+CAST(@curve_id AS VARCHAR)
						+CASE WHEN ISNULL(@forecated_tran,'n')='n'	THEN ' 
							union all
							select dl.link_id,gfldd.source_deal_header_id ,gfldd.term_start,gfldd.term_start,sdd.deal_volume * gfldd.percentage_used used_vol,percentage_used,sdd.deal_volume
							 from gen_fas_link_detail_dicing gfldd inner join  #dice_link dl on dl.link_id=gfldd.link_id
							inner join  '+CASE WHEN ISNULL(@forecated_tran,'n')='n' THEN ' source_deal_detail ' ELSE ' gen_deal_detail ' END +
							' sdd on gfldd.source_deal_header_id='+CASE WHEN ISNULL(@forecated_tran,'n')='n' THEN ' sdd.source_deal_header_id  ' ELSE ' sdd.gen_deal_header_id ' END+' and gfldd.term_start=sdd.term_start and sdd.leg=1
							left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
							where  isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+CAST(@curve_id AS VARCHAR)+' and dl.link_id='+CAST(@link_id AS VARCHAR)
						ELSE '' END
					+ '
				) gen
				 group by gen.term_start	
				'		
				
			EXEC spa_print @st
			EXEC(@st)	

			--select * from #link_used_vol
			--select * from #hedge_under where curve_id=742
--return
			UPDATE hu SET available_vol =CASE WHEN ABS(hu.available_vol)<ABS(u.used_vol) THEN 0 ELSE (ABS(hu.available_vol)-ABS(u.used_vol)) *CASE WHEN hu.available_vol<0 THEN -1 ELSE 1 END  END
			FROM #hedge_under hu
			INNER JOIN #link_used_vol u ON u.term_start=hu.term_start
				AND  hu.term_start BETWEEN  @term_start AND @term_end 
				AND hu.entity_id=@entity_id AND hu.curve_id=@curve_id 			
					
			--select * from #hedge_under where curve_id=742

			INSERT INTO #limit_applied_link(link_id) SELECT @link_id 
			
		END
		
		--select * from #hedge_under
		EXEC spa_print '===================loop cursor multi_term_link==============================================================================='

		FETCH NEXT FROM multi_term_link INTO @link_id,@term_start,@term_end ,@no_term,@buy_sell,@used_vol,@total_used_vol,@total_deal_vol,@perfect_hedge
			
	END
	CLOSE multi_term_link
	DEALLOCATE multi_term_link
	
	
--*/
	EXEC spa_print '===================loop cursor hedge_under==============================================================================='
	
	FETCH NEXT FROM hedge_under INTO @entity_id, @curve_id 

END
CLOSE hedge_under
DEALLOCATE hedge_under


 --select distinct * from #limit_applied_link
--return
---cleaning the transactiond data had made by auto forecasted transaction
DELETE gen_fas_link_detail FROM gen_fas_link_detail fld 
	INNER JOIN  gen_fas_link_header flh ON fld.gen_link_id=flh.gen_link_id AND flh.process_id=@process_id
	LEFT JOIN #limit_applied_link v ON v.link_id=fld.gen_link_id
WHERE   v.link_id IS NULL

DELETE gen_fas_link_detail WHERE   percentage_included =0

DELETE flh FROM gen_fas_link_detail fld 
	RIGHT JOIN  gen_fas_link_header flh ON fld.gen_link_id=flh.gen_link_id
 WHERE  flh.process_id=@process_id  AND fld.gen_link_id IS NULL
 
DELETE sdd FROM gen_deal_header sdh 
	INNER JOIN gen_deal_detail sdd ON sdd.gen_deal_header_id=sdh.gen_deal_header_id AND ISNULL(sdh.process_id,@process_id)=@process_id
	LEFT JOIN gen_fas_link_header flh ON sdh.gen_hedge_group_id=flh.gen_hedge_group_id
WHERE flh.gen_hedge_group_id IS NULL

DELETE sdh FROM gen_deal_header sdh LEFT JOIN gen_fas_link_header flh  ON sdh.gen_hedge_group_id=flh.gen_hedge_group_id 
	WHERE ISNULL(sdh.process_id,@process_id)=@process_id AND flh.gen_hedge_group_id IS NULL

DELETE d FROM gen_hedge_group_detail d LEFT JOIN gen_fas_link_header flh ON d.gen_hedge_group_id=flh.gen_hedge_group_id 
	WHERE ISNULL(d.process_id,@process_id)=@process_id AND flh.gen_hedge_group_id IS NULL

DELETE h FROM gen_hedge_group h LEFT JOIN gen_fas_link_header flh ON h.gen_hedge_group_id=flh.gen_hedge_group_id 
	WHERE ISNULL(h.process_id,@process_id)=@process_id AND flh.gen_hedge_group_id IS NULL

DELETE h FROM gen_transaction_status h LEFT JOIN gen_fas_link_header flh ON h.gen_hedge_group_id=flh.gen_hedge_group_id 
	WHERE ISNULL(h.process_id,@process_id)=@process_id AND flh.gen_hedge_group_id IS NULL AND error_code IN('Success','Warning')

 							
end_command:
SET @url_desc = '' 
EXEC spa_print 'end spa_auto_matching_limit_validation'

GO
