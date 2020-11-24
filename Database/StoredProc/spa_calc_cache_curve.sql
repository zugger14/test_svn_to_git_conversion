
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_cache_curve]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_cache_curve]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 /**
	Prepare all the price of lagging curves that require to mtm/settlement calculation as cached for performance
	
	Parameters : 
	@Delivery_from : Delivery from date
	@Delivery_to : Delivery to date
	@as_of_date : As Of Date for curve price
	@curve_source_id : Source Curve price
	@pricing_option : Pricing Option
	@expiration_type : Expiration Type
	@expiration_value : Expiration Value
	@run_mode : Run Mode
					- 0 - Calculation only 
					- 1 - Calculation and return data 
					- 2 - Return data without calculating
	@rowid : Rowid filter to process
	@batch_process_id : Batch Process Id for export output result
	@curve_ids : Curve Ids filter to process

*/


CREATE proc [dbo].[spa_calc_cache_curve]
	@Delivery_from DATETIME,
	@Delivery_to DATETIME,
	@as_of_date DATETIME,
	@curve_source_id INT,
	@pricing_option INT=NULL,
	@expiration_type VARCHAR(30)=null,
	@expiration_value VARCHAR(30)=NULL,
	@run_mode  int=0, --@run_mode = 0: Calculation only.
						-- @run_mode = 1: Calculation and return data.
						--@run_mode = 2: Return data without calculating.
	@rowid int=null,
	@batch_process_id varchar(100)=NULL,
	@curve_ids VARCHAR(MAX) = NULL

AS
/*
--------- select * from #curve_value where maturity_date = '2012-01-01' and as_of_date between '2011-01-01' and '2011-12-31' order by value_type, as_of_date 
-- select * from cached_curves_value  where Master_ROWID=19 and as_of_date = '2011-09-26' and term >= '2011-01-01' order by term
--select * from cached_curves where curve_id=105
-- select * from cached_curves  where rowid=27
 -- select * from cached_curves_value where as_of_date = '2011-09-26' and Master_ROWID=27 and term >= '2011-01-01' order by term
-- select * from source_price_curve_def where source_curve_def_id in (107) -- 187
--select * from holiday_group where hol_group_value_id=292049  and hol_date between '2011-07-01' and '2011-07-31' order by hol_date, exp_date
--select * from source_price_curve where source_curve_def_id in (138) and as_of_date between '2011-01-01' and '2011-12-31' and maturity_date = '2012-01-01'
-- update source_price_curve_def set settlement_curve_id=null where source_curve_def_id in (204,205)
-- select* from source_price_curve_def where curve_name like '%zbr%'

--EXEC [dbo].[spa_calc_cache_curve]
-- '2012-01-01'
-- , '2012-01-31'
-- , '2012-01-20'
-- , 4500 --@curve_source_id
-- , DEFAULT --@pricing_option
-- , DEFAULT --@expiration_type
-- , DEFAULT --@expiration_value
-- , 3	--@run_mode
-- , 22

--exec spa_run_sql  58,'as_of_date=2012-01-20,delivery_from=2013-04-01,delivery_to=2013-06-30,row_id=22'

SET nocount off	
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo


DECLARE @Delivery_from DATETIME='2013-01-01',
	@Delivery_to DATETIME=  '2013-12-31', --'2025-12-31',
	@as_of_date DATETIME='2013-7-1',
	@curve_source_id INT=4500,
	@pricing_option INT=null,
	@expiration_type VARCHAR(30)=null,
	@expiration_value VARCHAR(30)=NULL,
	@run_mode int=2,
	@rowid int=NULL,
	
	@curve_ids int = -1,
	@batch_process_id varchar(100)
	
	DROP TABLE  #delivery_month
	DROP TABLE #curve_value
	DROP TABLE #lag_term_curve_value
	DROP TABLE #lag_term_avg_value
	DROP TABLE #delivery_in_day
	DROP TABLE #price_curve_date_point
	DROP TABLE #curve_ids
	DROP TABLE #hourly_curves
	DROP TABLE #temp_block_define
	DROP TABLE  #tmp_curve

--*/
	
--Start tracking time for Elapse time


declare @status_type varchar(1)
declare @desc varchar(5000)
declare @error_count INT 
declare @saved_records INT
DECLARE @stmt varchar(8000)

DECLARE @st varchar(max)



DECLARE @begin_time DATETIME
SET @begin_time = getdate()

--DECLARE @curve_id INT 
--SET @curve_id = NULL


--if isnull(@rowid,-1)<>-1
--	select @curve_id=curve_id from cached_curves where rowid=@rowid

IF @curve_ids = '-1' SET @curve_ids = NULL

If @batch_process_id IS NULL
	SET @batch_process_id = dbo.FNAGetNewID()
		
DECLARE @baseload_block_type int,@baseload_block_define_id int

SET @baseload_block_type = 12000	-- Internal Static Data
SELECT @baseload_block_define_id = value_id FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load' -- External Static Data
			
CREATE TABLE  #delivery_month (curve_id INT,delivery_month DATETIME,lag_month DATETIME,RelativeExpirationDate DATETIME,lag_month_end DATETIME,fx_curve_id INT
	,strip_month_from INT ,lag_months INT ,strip_month_to INT )	
	
DECLARE @settle_date DATETIME,@as_of_date_end DATETIME--,@settle BIT

SET @as_of_date_end=dateadd(MONTH,1,cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME))-1

IF @as_of_date_end=@as_of_date
	SET @settle_date=@as_of_date_end
ELSE
	SET @settle_date=cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME)-1

If @Delivery_from IS NULL
	select @Delivery_from = @as_of_date

set @Delivery_from = cast(convert(varchar(8),@Delivery_from,120)+'01' AS DATETIME)

--print @Delivery_from 
create table #curve_ids (only_curve_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT)	

If @Delivery_to IS NULL
	select @Delivery_to = max(term_start) from source_deal_Detail sdd inner join
		source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
		where sdd.formula_id is not null OR sdh.pricing in (1601,1602)
	  
set @Delivery_to = dateadd(MONTH,1,cast(convert(varchar(8),@Delivery_to,120)+'01' AS DATETIME))-1 	  

--print @Delivery_to 	  

If @curve_ids is not null
	insert into #curve_ids 
	--select @curve_id UNION
	--select distinct fx_curve_id from cached_curves where curve_id = @curve_id and fx_curve_id is not null	  	
	 SELECT item FROM dbo.SplitCommaSeperatedValues(@curve_ids) scsv
	  	
SET @pricing_option=isnull(@pricing_option,0) 
set	@run_mode =isnull(@run_mode,0)



If @run_mode IN (3)
BEGIN

	set @st='
		select max(ROWID) rowid,curve_id,strip_month_from,lag_months,strip_month_to,max(fx_curve_id) fx_curve_id,max(operation_type) operation_type into #tmp_curve from cached_curves '+
		case when  @rowid is null then '' else ' where  rowid='+cast(@rowid as varchar) end +'
		group by curve_id,strip_month_from,lag_months,strip_month_to;

		create index indx_tmp_curve_ooo1 on #tmp_curve (ROWID);
		create index indx_tmp_curve_ooo2 on #tmp_curve (curve_id);
		create index indx_tmp_curve_ooo3 on #tmp_curve (fx_curve_id);
	
		 SELECT distinct spcd.curve_name [Index], ccv.as_of_date AsOfDate, ccv.term MaturityDate
			, ccv.curve_value MidValue ,ccv.org_bid_value*case when cc.operation_type=''m'' then ccv.org_fx_value else 1.00/ccv.org_fx_value end BidValue
			 ,ccv.org_ask_value*case when cc.operation_type=''m'' then ccv.org_fx_value else 1.00/ccv.org_fx_value end  AskValue,ccv.value_type ValueType 
			,cast(cc.strip_month_from as varchar(10))+''-''+cast(cc.lag_months as varchar(10))+''-''+cast(cc.strip_month_to as varchar(10)) Lagging,
			  sc.currency_name Currency,su.uom_name UOM
		from  #tmp_curve cc
		inner join 	cached_curves_value ccv on cc.ROWID=ccv.Master_ROWID
		and ccv.term between '''+CONVERT(varchar(10),@Delivery_from,120)+ ''' and '''+CONVERT(varchar(10),@Delivery_to,120)+''' and  ccv.as_of_date=case when  ccv.value_type =''f'' then  '''+convert(varchar(10), @as_of_date,120)+''' else ccv.as_of_date end
		 LEFT JOIN source_price_curve_def spcd ON cc.curve_id=spcd.source_curve_def_id
		 LEFT JOIN source_price_curve_def spcd1 ON spcd.proxy_curve_id=spcd1.source_curve_def_id
		 left join source_uom su on su.source_uom_id=spcd.uom_id
		 LEFT JOIN source_price_curve_def spcd2 ON cc.fx_curve_id=spcd2.source_curve_def_id
		left join source_currency sc on sc.source_currency_id=COALESCE(spcd2.source_currency_id,spcd1.source_currency_id,spcd.source_currency_id)
		ORDER BY 1, 2, 3,8'
	
	exec spa_print @st
	exec(@st)
	return

END



set @st='
	INSERT INTO #delivery_month (curve_id ,delivery_month,lag_month,RelativeExpirationDate,lag_month_end,fx_curve_id,strip_month_from ,lag_months ,strip_month_to )	
	SELECT	DISTINCT cc.curve_id,trm.term_start delivery_month,dateadd(mm, r.pricing_term, trm.term_start) lag_month,
		 cc.RelativeExpirationDate RelativeExpirationDate,dateadd(mm, r.pricing_term, trm.term_end) lag_month_end,fx_curve_id,strip_month_from,lag_months ,strip_month_to
	FROM [dbo].[FNATermBreakdown](''m'','''+convert(varchar(10),@Delivery_from,120)+''','''+convert(varchar(10),@Delivery_to,120)+''') trm
	CROSS apply
	(
		select distinct curve_Id, CASE WHEN(expiration_type is NULL AND expiration_value IS NULL) THEN NULL 
					ELSE  dbo.[FNARelativeExpirationDate](trm.term_start,curve_Id,0 ,expiration_type,expiration_value) END RelativeExpirationDate,
			strip_month_from ,lag_months ,strip_month_to,fx_curve_id
		 FROM cached_curves ' +	 case when @curve_ids is null then '' else '  inner join #curve_ids ON curve_id = only_curve_id ' end +'
		 --WHERE curve_id in(205)
	) cc 
	INNER JOIN 	position_break_down_rule r on r.strip_from=cc.strip_month_from
		AND r.lag=cc.lag_months AND r.strip_to=strip_month_to AND month(trm.term_start) = r.phy_month	
'

exec(@st)

CREATE INDEX indx_delivery_month_tmp1 ON #delivery_month (curve_id,lag_month,lag_month_end)

-- select * from #delivery_month
-- select * from #tmp_curve 

If @run_mode IN (4)
BEGIN

	set @st='
		select max(ROWID) rowid,curve_id,strip_month_from,lag_months,strip_month_to,max(fx_curve_id) fx_curve_id,max(operation_type) operation_type into #tmp_curve from cached_curves '+
		case when  @rowid is null then '' else ' where  rowid='+cast(@rowid as varchar) end +'
		group by curve_id,strip_month_from,lag_months,strip_month_to;

		create index indx_tmp_curve_ooo1 on #tmp_curve (ROWID);
		create index indx_tmp_curve_ooo2 on #tmp_curve (curve_id);
		create index indx_tmp_curve_ooo3 on #tmp_curve (fx_curve_id);
	
		 SELECT distinct spcd.curve_name [Index], ccv.as_of_date AsOfDate, ccv.term MaturityDate
			, ccv.curve_value MidValue ,ccv.org_bid_value*case when cc.operation_type=''m'' then ccv.org_fx_value else 1.00/ccv.org_fx_value end BidValue
			 ,ccv.org_ask_value*case when cc.operation_type=''m'' then ccv.org_fx_value else 1.00/ccv.org_fx_value end  AskValue,ccv.value_type ValueType 
			,cast(cc.strip_month_from as varchar(10))+''-''+cast(cc.lag_months as varchar(10))+''-''+cast(cc.strip_month_to as varchar(10)) Lagging,
			  sc.currency_name Currency,su.uom_name UOM
		from  #tmp_curve cc inner join
		(select distinct curve_id,strip_month_from,lag_months,strip_month_to,lag_month from  #delivery_month)  dm on cc.curve_id=dm.curve_id 
		and cc.strip_month_from=dm.strip_month_from and cc.lag_months=dm.lag_months and cc.strip_month_to=dm.strip_month_to
		inner join 	cached_curves_value ccv on cc.ROWID=ccv.Master_ROWID
		and ccv.term =dm.lag_month and  ccv.as_of_date=case when  ccv.value_type =''f'' then  '''+convert(varchar(10), @as_of_date,120)+''' else ccv.as_of_date end
		 LEFT JOIN source_price_curve_def spcd ON cc.curve_id=spcd.source_curve_def_id
		 LEFT JOIN source_price_curve_def spcd1 ON spcd.proxy_curve_id=spcd1.source_curve_def_id
		 left join source_uom su on su.source_uom_id=spcd.uom_id
		 LEFT JOIN source_price_curve_def spcd2 ON cc.fx_curve_id=spcd2.source_curve_def_id
		left join source_currency sc on sc.source_currency_id=COALESCE(spcd2.source_currency_id,spcd1.source_currency_id,spcd.source_currency_id)
		ORDER BY 1, 2, 3,8'
	
	exec spa_print @st
	exec(@st)
	return

END




--For FX curve always insert 1 month prior to what is picked up 	  	
insert into #delivery_month 
select d.curve_id, CONVERT(VARCHAR(8), dateadd(MM, -1, MIN(d.delivery_month)), 120)+'01' delivery_month, 
		CONVERT(VARCHAR(8), dateadd(MM, -1, MIN(d.lag_month)), 120)+'01' lag_month, NULL RelativeExpirationDate,
		dateadd(MM, -1, MIN(d.lag_month_end)) lag_month_end ,
		NULL fx_curve_Id, 0,0,1 
from source_price_curve_def spcd inner join
#delivery_month d ON d.curve_id = spcd.source_curve_def_id
where spcd.source_currency_id is not null and spcd.source_currency_to_id is not null
group by d.curve_id

CREATE TABLE  #delivery_in_day (curve_id INT,RelativeExpirationDate DATETIME,maturity_date DATETIME, o_fx_curve_id INT)

INSERT INTO #delivery_in_day (curve_id,RelativeExpirationDate ,maturity_date, o_fx_curve_id)
SELECT m.curve_id,re.RelativeExpirationDate,d.maturity_date, m.o_fx_curve_id
FROM 
(
	SELECT m.curve_id, max(m.RelativeExpirationDate) RelativeExpirationDate,
	MIN(CASE WHEN m.fx_curve_id IS NOT NULL  THEN  m.lag_month else lag.lag_month END  ) maturity_start, 
	max(CASE WHEN m.fx_curve_id IS NOT NULL THEN  m.lag_month_end else lag.lag_month_end  END ) maturity_end,
	MAX(m.fx_curve_id) o_fx_curve_id
	
	FROM 
		(SELECT DISTINCT curve_id ,delivery_month,lag_month,RelativeExpirationDate,lag_month_end,fx_curve_id FROM #delivery_month) m 
	CROSS JOIN 
		(SELECT min(lag_month) lag_month,max(lag_month_end) lag_month_end FROM #delivery_month) lag
	GROUP BY m.curve_id
) m
CROSS APPLY (
	SELECT term_date maturity_date FROM hour_block_term WHERE block_type=@baseload_block_type AND block_define_id =@baseload_block_define_id
	AND term_date BETWEEN m.maturity_start AND m.maturity_end 
) d 

LEFT  JOIN
(select DISTINCT curve_id, delivery_month, RelativeExpirationDate from #delivery_month) re on 
re.curve_id=m.curve_id and re.delivery_month = convert(varchar(8), d.maturity_date,120)+'01'

--select * from #delivery_month 
--select * from #delivery_in_day order by maturity_date
--return

CREATE TABLE  #price_curve_date_point(seqno INT IDENTITY, curve_id INT ,proxy_curve_id INT ,as_of_date datetime,maturity_date DATETIME,value_type varchar(1) COLLATE DATABASE_DEFAULT,
maturity_date_fx DATETIME, o_fx_curve_id INT, original_as_of_date datetime, RelativeExpirationDate datetime, primary_is_settlement_curve INT)


---- Insert data point upto current month
INSERT INTO #price_curve_date_point(curve_id, proxy_curve_id  ,as_of_date ,maturity_date ,value_type,maturity_date_fx, o_fx_curve_id, 
	original_as_of_date, primary_is_settlement_curve)
SELECT	DISTINCT r.curve_id,
		CASE WHEN (spcd3.source_curve_def_id IS NOT NULL and 
				((spcd.exp_calendar_id = spcd3.exp_calendar_id AND  hg.exp_date <= @as_of_date) OR
				 (hgs.exp_date <= @as_of_date))
				) THEN spcd3.source_curve_def_id
		ELSE r.curve_id END proxy_curve_id,
			
		CASE 
			 WHEN (spcd.asofdate_current_month = 'y' AND 
					CONVERT(varchar(7), hg.exp_date, 120)=CONVERT(varchar(7), @as_of_date, 120)) THEN @as_of_date 
			 WHEN (hgs.hol_date <= @as_of_date OR hgs.exp_date <= @as_of_date) THEN hgs.exp_date 
			 WHEN (hg.hol_date <= @as_of_date OR hg.exp_date <= @as_of_date) THEN hg.exp_date 
		ELSE @as_of_date END   as_of_date, 
		
		CASE WHEN (isnull(spcd3.Granularity, spcd.Granularity) in (980, 991, 993) OR hg.hol_date is null) then r.maturity_date else hg.hol_date  end maturity_date,
		 
		CASE	WHEN (spcd.asofdate_current_month = 'y' AND 
					CONVERT(varchar(7), hg.exp_date, 120)=CONVERT(varchar(7), @as_of_date, 120)) then 'f'
				WHEN (hg.hol_date <= @as_of_date OR hg.exp_date <= @as_of_date) THEN 's' 
				ELSE 'f' END value_type,
				
		CASE WHEN (r.o_fx_curve_id IS NULL) THEN NULL 
		when not (hg.hol_date <= @as_of_date OR hg.exp_date <= @as_of_date) then r.maturity_date
		ELSE 
			convert(varchar(8),CASE WHEN (hg.hol_date <= @as_of_date OR hg.exp_date <= @as_of_date OR ISNULL(spcd.ratio_option, -1) = 18800) 
				THEN hg.exp_date ELSE r.maturity_date END,120)+'01'   
		END MATURITY_DATE_FX, 
		r.o_fx_curve_id,
		hg.exp_date,
		CASE WHEN (spcd3.source_curve_def_id IS NULL OR 
			isnull(spcd3.source_curve_def_id, -1) = spcd.source_curve_def_id) THEN 1 ELSE 0 END primary_is_settlement_curve
			
FROM (
		SELECT	curve_id,max(RelativeExpirationDate) RelativeExpirationDate,convert(varchar(8),maturity_date,120)+'01' maturity_date, 
				MAX(o_fx_curve_id) o_fx_curve_id FROM #delivery_in_day 
		GROUP BY curve_id,convert(varchar(8),maturity_date,120)+'01'
	) r
	LEFT JOIN 	source_price_curve_def spcd ON spcd.source_curve_def_id=r.curve_id
	LEFT JOIN source_price_curve_def spcd3 ON spcd3.source_curve_def_id=spcd.settlement_curve_id
	LEFT JOIN holiday_group hg On hg.hol_group_value_id= ISNULL(spcd.exp_calendar_id, spcd3.exp_calendar_id) AND 
		CONVERT(VARCHAR(8), r.maturity_date, 120)+'01' BETWEEN CONVERT(VARCHAR(8), hg.hol_date, 120)+'01' AND 
			CONVERT(VARCHAR(8), ISNULL(hg.hol_date_to, hg.hol_date), 120)+'01'
	LEFT JOIN holiday_group hgs On hgs.hol_group_value_id= spcd3.exp_calendar_id AND 
		CONVERT(VARCHAR(8), r.maturity_date, 120)+'01' BETWEEN CONVERT(VARCHAR(8), hgs.hol_date, 120)+'01' AND 
			CONVERT(VARCHAR(8), ISNULL(hgs.hol_date_to, hgs.hol_date), 120)+'01'
		AND spcd.exp_calendar_id <> spcd3.exp_calendar_id
 where hg.exp_date is not null

create table #curve_value (curve_id INT,proxy_curve_id INT,as_of_date DATETIME,maturity_date DATETIME, curve_value FLOAT,bid_value FLOAT,ask_value 
			FLOAT,value_type varchar(1) COLLATE DATABASE_DEFAULT,maturity_date_fx DATETIME)	


--select * from #hourly_curves
--Collect price curves 
select pc.curve_id, spcd_s.source_curve_def_id settlement_curve_id, spcd.block_define_id 
into #hourly_curves
from 
(select distinct curve_id from  #delivery_month) pc inner join
source_price_curve_def spcd on spcd.source_curve_def_id = pc.curve_id left join
source_price_curve_def spcd_s on spcd_s.source_curve_def_id = spcd.settlement_curve_id
where spcd_s.Granularity = 982

-- Delete all settlemetn entries for curves with hourly settlement price curves
delete from #price_curve_date_point 
from #price_curve_date_point p inner join
#hourly_curves h on h.curve_id = p.curve_id AND p.value_type= 's'

CREATE TABLE #temp_block_define(block_define_id INT, term_date DATETIME,[Hour] INT,hr_mult FLOAT)

INSERT INTO #temp_block_define
SELECT unpvt.block_define_id, unpvt.term_date,CAST(REPLACE(unpvt.[hour],'hr','') AS INT) [Hour],unpvt.hr_mult FROM 
      (SELECT
            hb.term_date,
            hb.block_type,
            hb.block_define_id,
            hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
      FROM
            hour_block_term hb inner join
            #hourly_curves hc ON hc.block_define_id = hb.block_define_id
            WHERE block_type=12000
            --AND block_define_id=@block_define_id
      )p
      UNPIVOT
      (hr_mult FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
      ) AS unpvt  
WHERE
      unpvt.[hr_mult]<>0

-- select * from #price_curve_date_point where maturity_date between '2011-07-01' and '2011-07-31' order by maturity_date 
-- select * from #curve_value 

--INSERT SETTLED HOURLY AVG PRICES
insert into #curve_value 
SELECT 
    hc.curve_id curve_id, spc.source_curve_def_id proxy_curve_id,
    cast(YEAR(spc.maturity_date) as varchar) + '-' + cast(MONTH(spc.maturity_date) as varchar) + '-01' as_of_date,
    cast(YEAR(spc.maturity_date) as varchar) + '-' + cast(MONTH(spc.maturity_date) as varchar) + '-01' maturity_date,
    avg(spc.curve_value) curve_value,
    avg(spc.bid_value) bid_value,
    avg(spc.ask_value) ask_value,
    's' value_type, 
    cast(YEAR(spc.maturity_date) as varchar) + '-' + cast(MONTH(spc.maturity_date) as varchar) + '-01'  maturity_date_fx
FROM
    source_price_curve spc INNER JOIN 
    #hourly_curves hc ON hc.settlement_curve_id = spc.source_curve_def_id INNER JOIN 
    #temp_block_define td on CAST(CONVERT(VARCHAR(10),td.term_date,120)+' '+CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' AS DATETIME)  = spc.maturity_date
			AND hc.block_define_id = td.block_define_id
	LEFT JOIN 	source_price_curve_def spcd ON spcd.source_curve_def_id=spc.source_curve_def_id		
	LEFT JOIN holiday_group hg ON hg.hol_group_value_id = spcd.exp_calendar_id AND hg.exp_date = @as_of_date
WHERE
	spc.maturity_date BETWEEN @Delivery_from AND CASE WHEN hg.hol_date = @as_of_date_end THEN hg.hol_date ELSE  @settle_date + ' 23:00:00.000' END
GROUP BY hc.curve_id, spc.source_curve_def_id,
		 cast(YEAR(spc.maturity_date) as varchar) + '-' + cast(MONTH(spc.maturity_date) as varchar) + '-01'
		 
	

-- Insert Regular price curves
INSERT INTO #curve_value(curve_id ,proxy_curve_id ,as_of_date, maturity_date, curve_value ,bid_value ,ask_value,value_type,maturity_date_fx )
SELECT a.curve_id ,COALESCE(spc1.source_curve_def_id,spc2.source_curve_def_id,spc3.source_curve_def_id) proxy_curve_id, 
	a.as_of_date, a.maturity_date,
	COALESCE(spc1.curve_value * CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc1.factor,1) END,
			 spc2.curve_value * CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc2.factor,1) END,
			 spc3.curve_value * CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc3.factor,1) END,
			 spc4.curve_value * CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc4.factor,1) END
	) curve_value , 
	COALESCE(CASE WHEN (spc1.bid_value IS NULL OR spc1.ask_value IS NULL) THEN spc1.curve_value ELSE spc1.bid_value END 
				* CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc1.factor,1) END,
			 CASE WHEN (spc2.bid_value IS NULL OR spc2.ask_value IS NULL) THEN spc2.curve_value ELSE spc2.bid_value END  
				* CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc2.factor,1) END,
			 CASE WHEN (spc3.bid_value IS NULL OR spc3.ask_value IS NULL) THEN spc3.curve_value ELSE spc3.bid_value END 
				* CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc3.factor,1) END,
			 CASE WHEN (spc4.bid_value IS NULL OR spc4.ask_value IS NULL) THEN spc4.curve_value ELSE spc4.bid_value END  
				* CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc4.factor,1) END
	) bid_value, 
	COALESCE(CASE WHEN (spc1.bid_value IS NULL OR spc1.ask_value IS NULL) THEN spc1.curve_value ELSE spc1.ask_value END 
				* CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc1.factor,1) END,
			 CASE WHEN (spc2.bid_value IS NULL OR spc2.ask_value IS NULL) THEN spc2.curve_value ELSE spc2.ask_value END  
				* CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc2.factor,1) END,
			 CASE WHEN (spc3.bid_value IS NULL OR spc3.ask_value IS NULL) THEN spc3.curve_value ELSE spc3.ask_value END 
				* CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc3.factor,1) END,
			 CASE WHEN (spc4.bid_value IS NULL OR spc4.ask_value IS NULL) THEN spc4.curve_value ELSE spc4.ask_value END  
				* CASE WHEN(a.o_fx_curve_id IS NULL) THEN 1 ELSE ISNULL(sc4.factor,1) END
	) ask_value,
	a.value_type ,a.maturity_date_fx
FROM #price_curve_date_point a 
LEFT JOIN source_price_curve_def spcd1 ON a.proxy_curve_id=spcd1.source_curve_def_id
LEFT  JOIN source_price_curve_def spcd2 ON spcd1.proxy_source_curve_def_id=spcd2.source_curve_def_id
LEFT  JOIN source_price_curve_def spcd3 ON spcd1.monthly_index=spcd3.source_curve_def_id
LEFT  JOIN source_price_curve_def spcd4 ON spcd1.proxy_curve_id3=spcd4.source_curve_def_id
LEFT JOIN source_price_curve spc1 ON spcd1.source_curve_def_id=spc1.source_curve_def_id
	AND spc1.curve_Source_value_id=@curve_source_id
	AND spc1.as_of_date = a.as_of_date AND
	CASE WHEN spcd1.Granularity IN (980) THEN CONVERT(varchar(8),spc1.maturity_date,120) + '01'
		 WHEN spcd1.Granularity IN (981,982) THEN spc1.maturity_date
		 WHEN spcd1.Granularity IN (991) THEN 
			cast(Year(spc1.maturity_date) as varchar) + '-' + cast(case datepart(q, spc1.maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01' 
		 WHEN spcd1.Granularity IN (993) THEN cast(Year(spc1.maturity_date) as varchar) + '-01-01' 
	ELSE spc1.maturity_date END = 
	CASE WHEN spcd1.Granularity IN (980) THEN CONVERT(varchar(8),a.maturity_date,120) + '01'
		 WHEN spcd1.Granularity IN (981,982) THEN a.maturity_date
		 WHEN spcd1.Granularity IN (991) THEN 
			cast(Year(a.maturity_date) as varchar) + '-' + cast(case datepart(q, a.maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01' 
		 WHEN spcd1.Granularity IN (993) THEN cast(Year(a.maturity_date) as varchar) + '-01-01' 
	ELSE a.maturity_date END
	AND (a.primary_is_settlement_curve = 0 OR (a.primary_is_settlement_curve = 1 AND a.value_type = 's'))

LEFT JOIN source_price_curve spc2 ON spcd2.source_curve_def_id=spc2.source_curve_def_id
	AND spc2.curve_Source_value_id=@curve_source_id
	AND spc2.as_of_date = a.as_of_date AND
	CASE WHEN spcd2.Granularity IN (980) THEN CONVERT(varchar(8),spc2.maturity_date,120) + '01'
		 WHEN spcd2.Granularity IN (981,982) THEN spc2.maturity_date
		 WHEN spcd2.Granularity IN (991) THEN 
			cast(Year(spc2.maturity_date) as varchar) + '-' + cast(case datepart(q, spc2.maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01' 
		 WHEN spcd2.Granularity IN (993) THEN cast(Year(spc2.maturity_date) as varchar) + '-01-01' 
	ELSE spc2.maturity_date END = 
	CASE WHEN spcd2.Granularity IN (980) THEN CONVERT(varchar(8),a.maturity_date,120) + '01'
		 WHEN spcd2.Granularity IN (981,982) THEN a.maturity_date
		 WHEN spcd2.Granularity IN (991) THEN 
			cast(Year(a.maturity_date) as varchar) + '-' + cast(case datepart(q, a.maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01' 
		 WHEN spcd2.Granularity IN (993) THEN cast(Year(a.maturity_date) as varchar) + '-01-01' 
	ELSE a.maturity_date END

LEFT JOIN source_price_curve spc3 ON spcd3.source_curve_def_id=spc3.source_curve_def_id
	AND spc3.curve_Source_value_id=@curve_source_id
	AND spc3.as_of_date = a.as_of_date AND
	CASE WHEN spcd3.Granularity IN (980) THEN CONVERT(varchar(8),spc3.maturity_date,120) + '01'
		 WHEN spcd3.Granularity IN (981,982) THEN spc3.maturity_date
		 WHEN spcd3.Granularity IN (991) THEN 
			cast(Year(spc3.maturity_date) as varchar) + '-' + cast(case datepart(q, spc3.maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01' 
		 WHEN spcd3.Granularity IN (993) THEN cast(Year(spc3.maturity_date) as varchar) + '-01-01' 
	ELSE spc3.maturity_date END = 
	CASE WHEN spcd3.Granularity IN (980) THEN CONVERT(varchar(8),a.maturity_date,120) + '01'
		 WHEN spcd3.Granularity IN (981,982) THEN a.maturity_date
		 WHEN spcd3.Granularity IN (991) THEN 
			cast(Year(a.maturity_date) as varchar) + '-' + cast(case datepart(q, a.maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01' 
		 WHEN spcd3.Granularity IN (993) THEN cast(Year(a.maturity_date) as varchar) + '-01-01' 
	ELSE a.maturity_date END

LEFT JOIN source_price_curve spc4 ON spcd4.source_curve_def_id=spc4.source_curve_def_id
	AND spc4.curve_Source_value_id=@curve_source_id
	AND spc4.as_of_date = a.as_of_date AND
	CASE WHEN spcd4.Granularity IN (980) THEN CONVERT(varchar(8),spc4.maturity_date,120) + '01'
		 WHEN spcd4.Granularity IN (981,982) THEN spc4.maturity_date
		 WHEN spcd4.Granularity IN (991) THEN 
			cast(Year(spc4.maturity_date) as varchar) + '-' + cast(case datepart(q, spc4.maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01' 
		 WHEN spcd4.Granularity IN (993) THEN cast(Year(spc4.maturity_date) as varchar) + '-01-01' 
	ELSE spc4.maturity_date END = 
	CASE WHEN spcd4.Granularity IN (980) THEN CONVERT(varchar(8),a.maturity_date,120) + '01'
		 WHEN spcd4.Granularity IN (981,982) THEN a.maturity_date
		 WHEN spcd4.Granularity IN (991) THEN 
			cast(Year(a.maturity_date) as varchar) + '-' + cast(case datepart(q, a.maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01' 
		 WHEN spcd4.Granularity IN (993) THEN cast(Year(a.maturity_date) as varchar) + '-01-01' 
	ELSE a.maturity_date END

LEFT JOIN source_currency sc1 ON sc1.source_currency_id = spcd1.source_currency_id	
LEFT JOIN source_currency sc2 ON sc2.source_currency_id = spcd2.source_currency_id	
LEFT JOIN source_currency sc3 ON sc3.source_currency_id = spcd3.source_currency_id	
LEFT JOIN source_currency sc4 ON sc4.source_currency_id = spcd4.source_currency_id	
WHERE 
		COALESCE(spc1.curve_value,spc2.curve_value,spc3.curve_value,spc4.curve_value) IS NOT NULL

 create index indx_curve_value_ss1 on #curve_value (curve_id,as_of_date,maturity_date)

/*

SELECT *  FROM #curve_value WHERE maturity_date between '2011-10-01' and '2011-10-31' order by as_of_date, maturity_date
select * from source_price_curve where source_curve_def_id = 138 and as_of_date = '2011-08-31' order by as_of_date, MATURITY_DATE
SELECT avg(curve_value) FROM #curve_value  where curve_id=106 and maturity_date between '2011-12-01'  and '2011-12-31'

select * from #price_curve_date_point where maturity_date = '2011-9-01' and curve_id=107 order by original_as_of_date

*/




If @run_mode IN (0,1)
BEGIN 
			
	If @curve_ids IS NULL  -- DELETE ALL 
	BEGIN
		DELETE 	cached_curves_value 
		FROM	cached_curves_value s inner join 
				cached_curves cc on cc.ROWID = s.Master_ROWID 		
		WHERE	pricing_option=@pricing_option and term BETWEEN @Delivery_from AND @Delivery_to
				AND value_type='s'	AND  as_of_date <= @as_of_date
								
		--delete all forward values			
		DELETE 	cached_curves_value 
		FROM	cached_curves_value s inner join 
				cached_curves cc on cc.ROWID = s.Master_ROWID 		
		WHERE	pricing_option=@pricing_option and term BETWEEN @Delivery_from AND @Delivery_to
				AND value_type='f'	AND  as_of_date=@as_of_date					

	END 
	ELSE
	BEGIN
	
		DELETE 	cached_curves_value 
		FROM	cached_curves_value s inner join 
				cached_curves cc on cc.ROWID = s.Master_ROWID left join 
				#curve_ids c on c.only_curve_id = cc.curve_id 		
		WHERE	pricing_option=@pricing_option and term BETWEEN @Delivery_from AND @Delivery_to
				AND value_type='s'	AND  as_of_date <= @as_of_date
				AND c.only_curve_id IS NOT NULL
				
		--delete all forward values			
		DELETE 	cached_curves_value 
		FROM	cached_curves_value s inner join 
				cached_curves cc on cc.ROWID = s.Master_ROWID left join 
				#curve_ids c on c.only_curve_id = cc.curve_id 		
		WHERE	pricing_option=@pricing_option and term BETWEEN @Delivery_from AND @Delivery_to
				AND value_type='f'	AND  as_of_date=@as_of_date
				AND c.only_curve_id IS NOT NULL	
	END				
			

			
	--DELETE 	cached_curves_value FROM cached_curves_value s 
	--	where pricing_option=@pricing_option and term BETWEEN @Delivery_from AND @Delivery_to
	--		AND as_of_date=@as_of_date AND value_type='f'

	IF @pricing_option IN(0,1)
	BEGIN
		
		CREATE TABLE #lag_term_avg_value(curve_id INT ,lag_month DATETIME,curve_value FLOAT,bid_value FLOAT,ask_value FLOAT,maturity_date_fx DATETIME, value_type VARCHAR(1) COLLATE DATABASE_DEFAULT)

		INSERT INTO  #lag_term_avg_value(curve_id ,lag_month,curve_value,bid_value,ask_value,maturity_date_fx, value_type)
		SELECT cv.curve_id,convert(varchar(8),cv.maturity_date,120)+'01' lag_month, avg(cv.curve_value) curve_value 
			, avg(cv.bid_value) bid_value, avg(cv.ask_value) ask_value,min(cv.maturity_date_fx) maturity_date_fx, MIN(cv.value_type) value_type
		FROM #curve_value cv 
		group by cv.value_type,cv.curve_id ,convert(varchar(8),cv.maturity_date,120)+'01'--,cv.maturity_date_fx


	
			
		CREATE TABLE #lag_term_curve_value(ROWID INT,strip_month_from INT ,lag_months INT ,strip_month_to INT ,curve_id INT ,delivery_month DATETIME ,lag_month DATETIME
			,cv_value FLOAT, fx_value FLOAT	,bid_value FLOAT,ask_value FLOAT,bid_ask_value FLOAT, value_type VARCHAR(1) COLLATE DATABASE_DEFAULT)

		INSERT INTO #lag_term_curve_value(curve_id ,delivery_month ,lag_month,cv_value, fx_value,bid_value ,ask_value,bid_ask_value,strip_month_from ,lag_months ,strip_month_to,ROWID, value_type)
		SELECT 	a.curve_id,b.delivery_month,a.lag_month,  a.curve_value curve_value, 
			CASE WHEN b.fx_curve_id IS NULL THEN 1 ELSE fx.curve_value END fx_value
			, a.bid_value,a.ask_value,(round(a.bid_value,isnull(cc.bid_ask_round_value,20)) + round(a.ask_value,isnull(cc.bid_ask_round_value,20)))/2 bid_ask_value
			,b.strip_month_from ,b.lag_months ,b.strip_month_to,cc.ROWID, a.value_type
		FROM #lag_term_avg_value a INNER JOIN  #delivery_month b ON a.curve_id=b.curve_id AND a.lag_month=b.lag_month
			INNER JOIN cached_curves cc ON  cc.strip_month_from=b.strip_month_from AND cc.lag_months=b.lag_months AND cc.strip_month_to=b.strip_month_to AND cc.curve_id=b.curve_id
			LEFT JOIN  #lag_term_avg_value fx ON b.fx_curve_id=fx.curve_id and isnull(a.maturity_date_fx,b.lag_month) =fx.lag_month
	
			
			insert into MTM_TEST_RUN_LOG(process_id,code,module,source,type,[description],nextsteps)  
			select	@batch_process_id, '<font color="red">Error</font>', 'Derive Curve', 'spa_calc_cache_curve', 
					'Error',
					'Price curve calcuatlion failed due to missing FX price for ' +  
					' Curve: ' + spcd.curve_name + ' (ID: ' + CAST(spcd.source_curve_def_id as varchar) + ')' +
					' FX Curve: ' + spcd_f.curve_name + ' (ID: ' + CAST(spcd_f.source_curve_def_id as varchar) + ')' +
					' for Term: ' + ISNULL(dbo.FNADateFormat(d.lag_month), CONVERT(varchar(10),d.lag_month, 120))  description,
					'Please Import Price Curves'
			from #delivery_month d left join 
				 #lag_term_curve_value l on l.curve_id=d.curve_id and l.lag_month=d.lag_month left join
				 source_price_curve_def spcd on spcd.source_curve_def_id = d.curve_id left join
				 source_price_curve_def spcd_f on spcd_f.source_curve_def_id = d.fx_curve_id
			where d.fx_curve_id IS NOT NULL AND l.fx_value is null
		
			set @error_count = 	@@ROWCOUNT



			;WITH CTE AS(
			SELECT DISTINCT lv.curve_id,lv.lag_month,term_start,term_end
			
			FROM
				#delivery_month lv
				OUTER APPLY(SELECT curve_id,MIN(fin_term_start) term_start,MAX(fin_term_end) term_end FROM deal_position_break_down WHERE curve_id = lv.curve_id GROUP BY curve_Id
				) p
			WHERE
				lv.lag_month BETWEEN p.term_start AND p.term_End	
			)

	
			insert into MTM_TEST_RUN_LOG(process_id,code,module,source,type,[description],nextsteps)  
			select	@batch_process_id, '<font color="red">Error</font>', 'Derive Curve', 'spa_calc_cache_curve', 
					'Error',
					'Price curve calcuatlion failed due to missing price for ' +  
					' Curve: ' + spcd.curve_name + ' (ID: ' + CAST(spcd.source_curve_def_id as varchar) + ')' +
					' for Term: ' + ISNULL(dbo.FNADateFormat(d.lag_month), CONVERT(varchar(10),d.lag_month, 120))  description,
					'Please Import Price Curves'
			from #delivery_month d 
			     INNER JOIN CTE ct ON d.curve_id = ct.curve_id anD ct.lag_month = d.lag_month
				 left join 
				 #lag_term_curve_value l on l.curve_id=d.curve_id and l.lag_month=d.lag_month left join
				 source_price_curve_def spcd on spcd.source_curve_def_id = d.curve_id 
			where l.bid_ask_value IS NULL OR l.cv_value IS NULL	
		
			set @error_count = 	@error_count + @@ROWCOUNT
		
	    	
		set @st='
			insert into dbo.cached_curves_value (Master_ROWID,value_type,term,pricing_option,org_mid_value,as_of_date,curve_source_id,curve_value,bid_ask_curve_value,org_ask_value ,org_bid_value ,org_fx_value,create_ts)	
			select v.rowid,v.value_type value_type,
			delivery_month,'+ cast(@pricing_option AS VARCHAR) +' pricing_option
			,avg(v.cv_value) org_curve_value,'''+CONVERT(varchar(10),@as_of_date,120)+''' as_of_date,'+cast(@curve_source_id AS varchar)+' curve_source_id,'
			+ CASE @pricing_option when 1 THEN '
					round(avg(v.cv_value),isnull(cc.index_round_value ,20)) 
					* case when max(ISNULL(cc.operation_type,''m''))=''m'' then  round(avg(v.fx_value),isnull(cc.fx_round_value,20)) 
															else 1.00000/round(avg(v.fx_value),isnull(cc.fx_round_value,20)) 
					  END curve_value
					  ,round(avg(v.bid_ask_value) ,isnull(cc.bid_ask_round_value,20)) 
						* case when max(isnull(cc.operation_type,''m''))=''m'' then  round(avg(v.fx_value),isnull(cc.fx_round_value,20)) 
															else 1.00000/round(avg(v.fx_value),isnull(cc.fx_round_value,20)) 
					  END bid_ask_curve_value'
			 when 0 THEN '
					avg(round(round(cast(v.cv_value AS numeric(18,10)),isnull(cc.index_round_value,20)) * case when isnull(cc.operation_type,''m'')=''m'' then  round(v.fx_value,isnull(cc.fx_round_value,20)) 
																 else cast(cast(1 as numeric(18,10))/round(cast(v.fx_value as numeric(30,12)),isnull(cc.fx_round_value,20))  as numeric(18,10))
											end,isnull(cc.total_round_value,20))) curve_value
					,avg(round(round(cast(v.bid_ask_value AS numeric(18,10)),isnull(cc.index_round_value,20))	* case when isnull(cc.operation_type,''m'')=''m'' then  round(cast(v.fx_value AS numeric(18,10)),isnull(cc.fx_round_value,20)) 
																 else cast(cast(1 as numeric(18,10))/round(cast(v.fx_value as numeric(18,10)),isnull(cc.fx_round_value,20))  as numeric(18,10))
							end,isnull(cc.total_round_value,20))) bid_ask_curve_value
					  '
			END +' 
				,avg(v.ask_value) org_ask_value ,avg(v.bid_value) org_bid_value ,avg(v.fx_value) org_fx_value,getdate() create_ts
			from #lag_term_curve_value v INNER JOIN cached_curves cc ON v.rowid=cc.rowid
			where delivery_month BETWEEN ''' + convert(varchar(10),@Delivery_from,120) + ''' AND ''' + convert(varchar(10), @Delivery_to, 120) + '''
			group by v.rowid,v.delivery_month,index_round_value,fx_round_value,total_round_value,cc.bid_ask_round_value,v.value_type
		'
		
		EXEC spa_print @st
		exec(@st)		

		set @saved_records = @@ROWCOUNT		
	END
	ELSE IF @pricing_option IN(2,3)
	BEGIN
		

		set @st='
			insert into dbo.cached_curves_value (Master_ROWID,value_type,term,pricing_option,org_curve_value,as_of_date,curve_source_id,curve_value,bid_ask_curve_value,org_ask_value ,org_bid_value ,org_fx_value,create_ts)	
			select cv.rowid, case when cv.delivery_month>'''+CONVERT(varchar(10),@settle_date,120)+''' then ''f'' else ''s'' end value_type,
			cv.delivery_month,'+ cast(@pricing_option AS VARCHAR) +' pricing_option
			,avg(cv.curve_value) org_curve_value,'''+CONVERT(varchar(10),@as_of_date,120)+''' as_of_date,'+cast(@curve_source_id AS varchar)+' curve_source_id,'
			+ CASE @pricing_option when 2 THEN '
					avg(round(cv.curve_value,isnull(cv.index_round_value,20)) 
					* case when isnull(cv.operation_type,''m'')=''m'' then  round(fx.curve_value,isnull(cv.fx_round_value,20)) 
															else 1.00000/round(fx.curve_value,isnull(cv.fx_round_value,20)) 
					  end) curve_value
					,  avg(round((cv.bid_value + cv.ask_value)/2,isnull(cv.bid_ask_round_value,20)) 
					* case when isnull(cc.operation_type,''m'')=''m'' then  round(fx.curve_value,isnull(cv.fx_round_value,20)) 
															else 1.00000/round(fx.curve_value,isnull(cv.fx_round_value,20)) 
					  end) bid_ask_curve_value '
			 when 3 THEN '
					round(avg(v.curve_value),isnull(cc.index_round_value,20))
					* CASE WHEN max(isnull(cv.operation_type,''m''))=''m'' then  round(avg(fx.curve_value),isnull(cv.fx_round_value,20))
																 else 1.00000/round(avg(fx.curve_value),isnull(cv.fx_round_value,20))
					  END curve_value
					,  round(avg((cv.bid_value + cv.ask_value)/2),isnull(cv.bid_ask_round_value,20))
					* CASE  WHEN max(isnull(cv.operation_type,''m''))=''m'' then  isnull(round(avg(fx.curve_value),isnull(cv.fx_round_value,20)),1) 
																 else 1.00000/isnull(round(avg(fx.curve_value),isnull(cv.fx_round_value,20)),1)
					  END bid_ask_curve_value '
			END +'  
			,avg(cv.ask_value) org_ask_value ,avg(cv.bid_value) org_bid_value ,avg(cv.fx_value) org_fx_value,getdate() create_ts
			FROM 
			(
				SELECT cc.rowid,cc.curve_id,cc.strip_month_from , cc.lag_months,cc.strip_month_to,cc.index_round_value,cc.fx_round_value,cc.operation_type,cc.fx_curve_id,
				 cv.curve_value ,cv.bid_value ,cv.ask_value,b.lag_month,b.delivery_month
				 FROM #curve_value cv  INNER JOIN  #delivery_month b ON cv.curve_id=b.curve_id AND year(cv.maturity_date)=year(b.lag_month) AND month(cv.maturity_date)=month(b.lag_month)
				INNER JOIN cached_curves cc ON  cc.strip_month_from=b.strip_month_from AND cc.lag_months=b.lag_months AND cc.strip_month_to=b.strip_month_to and cc.curve_id=b.curve_id
			
			) cv
			full JOIN  
			(
				SELECT cc.rowid,cc.curve_id,cc.strip_month_from , cc.lag_months,cc.strip_month_to,cc.index_round_value,cc.fx_round_value,cc.operation_type,cc.fx_curve_id,
				 cv.curve_value ,cv.bid_value ,cv.ask_value,b.lag_month,b.delivery_month
				 FROM #curve_value cv  INNER JOIN  #delivery_month b ON cv.curve_id=b.curve_id AND year(cv.maturity_date)=year(b.lag_month) AND month(cv.maturity_date)=month(b.lag_month)
				INNER JOIN cached_curves cc ON  cc.strip_month_from=b.strip_month_from AND cc.lag_months=b.lag_months AND cc.strip_month_to=b.strip_month_to and cc.curve_id=b.curve_id
			
			)  fx ON cc.fx_curve_id=fx.curve_id and cv.lag_month=fx.lag_month and cv.delivery_month=fx.delivery_month
		where cv.delivery_month BETWEEN ''' + convert(varchar(10),@Delivery_from,120) + ''' AND ''' + convert(varchar(10), @Delivery_to, 120) + '''
			group by cv.rowid,cv.delivery_month,cv.index_round_value,cv.fx_round_value,cv.total_round_value,cv.bid_ask_round_value
		'
		
		EXEC spa_print @st
		exec(@st)	
		
		set @saved_records = @@ROWCOUNT
	END	
	
	--write status in message board only in calc only mode (called by EOD process)
	IF @run_mode = 0
	BEGIN
		If @error_count > 0 
			set @status_type = 'e'
		Else
			set @status_type = 's'

		declare @e_time_s int
		declare @e_time_text_s varchar(100)
		set @e_time_s = datediff(ss,@begin_time,getdate())
		set @e_time_text_s = cast(cast(@e_time_s/60 as int) as varchar) + ' Mins ' + cast(@e_time_s - cast(@e_time_s/60 as int) * 60 as varchar) + ' Secs'

		declare @user_login_id varchar(50)
		set @user_login_id = dbo.FNADBUser()

		If @status_type = 'e'
			SET @desc = '<a target="_blank" href="' +  './dev/spa_html.php?__user_name__=' + @user_login_id + 
				'&spa=exec spa_get_mtm_test_run_log ''' + @batch_process_id + '''' + '">' + 
			'Errors Found while calculating cached curves for as of date ' + isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) + 
			' Saved Records: ' + CAST(@saved_records as varchar) + '  Error Records: ' + CAST(@error_count as varchar) + 
			' [Elapse time: ' + @e_time_text_s + ']' + 
			'.</a>'
		Else
			SET @desc = 'Cached curve calculation process completed for as of date ' + isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) +
			' Saved Records: ' + CAST(@saved_records as varchar) + '  Error Records: ' + CAST(@error_count as varchar) + 
			' [Elapse time: ' + @e_time_text_s + ']' 

			
		declare @job_name varchar(250)
		set @job_name = 'cache_curve_'+@batch_process_id 
		EXEC  spa_message_board 'u', @user_login_id, NULL, 'Cached Curves', @desc, '', '', @status_type, @job_name,NULL, @batch_process_id,NULL,'n',NULL,'y'
	END
	 
END


If @run_mode IN (1,2)
BEGIN
	SELECT spcd.curve_name [Index],spcd1.curve_name [ProxyIndex], c.as_of_date AsOfDate, c.maturity_date MaturityDate
	, c.curve_value MidValue ,c.bid_value BidValue ,c.ask_value AskValue,c.value_type ValueType, spcd.source_curve_def_id [Curve_id]
	FROM #curve_value c LEFT JOIN source_price_curve_def spcd ON c.curve_id=spcd.source_curve_def_id
	LEFT JOIN source_price_curve_def spcd1 ON c.proxy_curve_id=spcd1.source_curve_def_id
	--WHERE c.curve_id=105
	ORDER BY 1, 2, 5,6
END