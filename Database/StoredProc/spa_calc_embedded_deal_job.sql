
IF OBJECT_ID('spa_calc_embedded_deal_job') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_calc_embedded_deal_job]
GO



--/****** Object:  StoredProcedure [dbo].[spa_calc_embedded_deal_job]    Script Date: 08/26/2008 12:53:34 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--
----
----
----
----spa_calc_embedded_deal_job NULL,NULL,NULL,'2008-11-28','xxxx1234','farrms_admin'
CREATE PROC [dbo].[spa_calc_embedded_deal_job]
	@sub_entity_id VARCHAR(150)=NULL,
	@strategy_entity_id VARCHAR(150)=NULL,
	@book_entity_id VARCHAR(150)=NULL,
	@pnl_as_of_date VARCHAR(20),
	@process_id VARCHAR(150)=NULL,
	@user_login_id VARCHAR(100)=NULL,
	@batch_process_id VARCHAR(50)=NULL,
	@batch_report_param VARCHAR(1000)=NULL
AS
--
--drop table #temp_buf
--DROP TABLE #Temp_MTM_Curr
--drop table #Temp_POS_Leg
--drop table #Temp_MTM_Start
--drop table #calc_embd
--drop table #temp_deal_by_price
--drop table #temp_deal_by_leg
--declare @pnl_as_of_date varchar(20),@user_login_id varchar(50),@process_id varchar(150)
--set @process_id='123'
--set @user_login_id='farrms_admin'
--set @pnl_as_of_date='2008-07-31'


DECLARE @source_deal_pnl VARCHAR(150)
DECLARE @sql VARCHAR(5000)

--If process_id is passed null create one]
------ Added
DECLARE @is_batch TINYINT
SET @is_batch=1
SET @process_id=@batch_process_id
IF @batch_process_id IS NULL
BEGIN
	SET @process_id = REPLACE(NEWID(),'-','_')
	SET @is_batch=0
END
--------
--IF @process_id IS NULL
--	SET @process_id = REPLACE(newid(),'-','_')

CREATE TABLE #temp_buf(
source_deal_header_id INT,
leg INT,
deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
Buf_deal_Id VARCHAR(50) COLLATE DATABASE_DEFAULT,
buf_deal_date DATETIME,
Buf_header_id INT,
term_start DATETIME,
term_end DATETIME,
position_volume FLOAT,
org_position_volume FLOAT
)


INSERT #temp_buf(source_deal_header_id,leg,deal_id,Buf_deal_Id,buf_deal_date,Buf_header_id,term_start,
term_end,position_volume,org_position_volume)
SELECT ed.source_deal_header_id,ed.leg,sdh.deal_id,
bdh.deal_id Buf_deal_Id,
bdh.deal_date buf_deal_date,bdh.source_deal_header_id Buf_header_id,
sdd_bif.term_start,sdd_bif.term_end,sdd_bif.deal_volume,sdd_org.deal_volume
FROM embedded_deal ed JOIN
source_deal_header sdh  ON ed.source_deal_header_id=sdh.source_deal_header_id
JOIN source_deal_header bdh 
ON bdh.source_deal_header_id=ed.bif_source_deal_header_id
JOIN source_deal_detail sdd_bif ON sdd_bif.source_deal_header_id=ed.bif_source_deal_header_id
JOIN source_deal_detail sdd_org ON sdd_org.source_deal_header_id=sdh.source_deal_header_id
AND sdd_bif.term_start=sdd_org.term_start AND sdd_bif.term_end=sdd_org.term_end AND 
ed.leg=sdd_org.leg


-------############ Finding Deal Leg #----------------------
CREATE TABLE #temp_deal_by_price(
temp_id INT IDENTITY(1,1),
deal_num VARCHAR(50) COLLATE DATABASE_DEFAULT,
price_region VARCHAR(250) COLLATE DATABASE_DEFAULT,
fx_flt VARCHAR(50) COLLATE DATABASE_DEFAULT,
settlement_type VARCHAR(100) COLLATE DATABASE_DEFAULT
)

INSERT INTO #temp_deal_by_price(deal_num,price_region,fx_flt,settlement_type)
SELECT deal_num,price_region,fx_flt,settlement_type 
FROM ssis_mtm_formate2_archive t  
WHERE pnl_as_of_date= @pnl_as_of_date
AND deal_num IN(SELECT deal_id FROM #temp_buf)
GROUP BY deal_num,price_region,fx_flt,settlement_type
ORDER BY deal_num,settlement_type DESC,price_region


CREATE TABLE #temp_deal_by_leg(
temp_id INT IDENTITY(1,1),
deal_num VARCHAR(50) COLLATE DATABASE_DEFAULT,
price_region VARCHAR(250) COLLATE DATABASE_DEFAULT,
fx_flt VARCHAR(50) COLLATE DATABASE_DEFAULT,
settlement_type VARCHAR(100) COLLATE DATABASE_DEFAULT,
leg INT
)
INSERT INTO #temp_deal_by_leg(deal_num,price_region,fx_flt,settlement_type,leg)
SELECT sdh.deal_id,pcd.curve_id price_region ,
CASE WHEN fixed_float_leg='t' THEN 'Float' ELSE 'Fixed' END fx_flt,
block_description settlement_type,sdd.leg
FROM source_deal_detail sdd JOIN source_deal_header  sdh ON
sdd.source_deal_header_id=sdh.source_deal_header_id 
JOIN source_price_curve_def pcd ON source_curve_def_id=sdd.curve_id
WHERE sdh.deal_id IN (SELECT deal_id FROM #temp_buf)
AND sdd.block_description IN('Cash Settlement','Physical Settlement')
GROUP BY sdh.deal_id,pcd.curve_id,fixed_float_leg,block_description,
sdd.leg

--select deal_num,price_region,fx_flt,settlement_type,(select count(*) from 
--#temp_deal_by_price where deal_num=g.deal_num  and temp_id<=g.temp_id
--) leg
--from #temp_deal_by_price g

---- GET Current MTM by Leg wise from AS_OF_DATE
CREATE TABLE #Temp_POS_Leg(
	temp_id INT IDENTITY(1,1),
	[deal_num] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	[time_bucket] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	[price_region] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	mtm_disc_eur FLOAT,
	pnl_as_of_date DATETIME,
	settlement_type VARCHAR(100) COLLATE DATABASE_DEFAULT,
	fx_flt VARCHAR(50) COLLATE DATABASE_DEFAULT
) ON [PRIMARY]
EXEC spa_print '1 ########'
--EXEC spa_print CONVERT(VARCHAR,GETDATE(),109)
---------------
--select @as_of_date,@source_system_id,@default_uom,@default_deal_id,@adhoc_call,@staging_table_name
--set @sql='
--insert #Temp_POS_Leg([deal_num],[time_bucket],
--		[price_region],mtm_disc_eur,settlement_type)
--select deal_num,time_bucket,price_region,
--sum(cast(mtm_disc_eur as float)) mtm_disc_eur,settlement_type
--from ssis_mtm_formate2_archive
--where pnl_as_of_date='''+ @pnl_as_of_date +'''
--and deal_num in(select deal_id from #temp_buf)
--group by deal_num,time_bucket,price_region,settlement_type
--order by deal_num,time_bucket,settlement_type desc'
--print(@sql);
--exec(@sql);
--

EXEC spa_print 'End ########'
--EXEC spa_print CONVERT(VARCHAR,GETDATE(),109)
-- Adjusting Leg for Deal
CREATE TABLE #Temp_MTM_Curr(
	temp_id INT IDENTITY(1,1),
	[deal_num] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	[time_bucket] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	[deal_side] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	[price_region] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	mtm_disc_eur FLOAT,
	pnl_as_of_date DATETIME
	
) ON [PRIMARY] 

INSERT #Temp_MTM_Curr([deal_num],[time_bucket],[deal_side]
      ,[price_region] ,mtm_disc_eur,pnl_as_of_date
)
SELECT a.deal_num,time_bucket,d_leg.leg,
a.price_region,SUM(CAST(mtm_disc_eur AS FLOAT)) mtm_disc_eur,@pnl_as_of_date
FROM ssis_mtm_formate2_archive a JOIN #temp_deal_by_leg d_leg ON
a.deal_num=d_leg.deal_num AND 
a.price_region=d_leg.price_region AND 
a.settlement_type=d_leg.settlement_type 
--and a.fx_flt=d_leg.fx_flt  
WHERE a.pnl_as_of_date=@pnl_as_of_date
AND a.deal_num IN(SELECT deal_id FROM #temp_buf)
GROUP BY a.deal_num,time_bucket,a.price_region,d_leg.leg,a.settlement_type
ORDER BY a.deal_num,time_bucket,a.settlement_type DESC

--select [deal_num],[time_bucket],(select count(*) from 
--#Temp_POS_Leg where deal_num=g.deal_num and time_bucket=g.time_bucket and temp_id<=g.temp_id
--) [deal_side],[price_region] ,mtm_disc_eur,@pnl_as_of_date
--from #Temp_POS_Leg g 
--order by deal_num,time_bucket,settlement_type desc 
--
--select * from #Temp_MTM_Curr
--
--return
DELETE #temp_deal_by_price

INSERT INTO #temp_deal_by_price(deal_num,price_region,fx_flt,settlement_type)
SELECT deal_num,price_region,fx_flt,settlement_type 
FROM ssis_mtm_formate2_archive arh JOIN 
(SELECT DISTINCT deal_id,buf_deal_date FROM #temp_buf) BUF
ON arh.deal_num=buf.deal_id AND arh.pnl_as_of_date=buf.buf_deal_date 
GROUP BY deal_num,price_region,fx_flt,settlement_type
ORDER BY deal_num,settlement_type DESC,price_region

DELETE #temp_deal_by_leg

INSERT INTO #temp_deal_by_leg(deal_num,price_region,fx_flt,settlement_type,leg)
SELECT deal_num,price_region,fx_flt,settlement_type,(SELECT COUNT(*) FROM 
#temp_deal_by_price WHERE deal_num=g.deal_num  AND temp_id<=g.temp_id
) leg
FROM #temp_deal_by_price g


EXEC spa_print 'GET MTM by Leg wise of Starting point'
DELETE #Temp_POS_Leg
--EXEC spa_print CONVERT(VARCHAR,GETDATE(),109)
---------------
--set @sql='
--insert #Temp_POS_Leg([deal_num],[time_bucket],
--		[price_region],mtm_disc_eur,pnl_as_of_date)
--select deal_num,time_bucket,price_region,
--sum(cast(mtm_disc_eur as float)) mtm_disc_eur,max(arh.pnl_as_of_date)
--from ssis_mtm_formate2_archive arh join 
--(select distinct deal_id,buf_deal_date from #temp_buf) BUF
--on arh.deal_num=buf.deal_id and arh.pnl_as_of_date=buf.buf_deal_date
--group by deal_num,time_bucket,price_region,settlement_type
--order by deal_num,time_bucket,settlement_type desc'
--print(@sql);
--exec(@sql);



EXEC spa_print 'End ########'
--EXEC spa_print CONVERT(VARCHAR,GETDATE(),109)
-- Adjusting Leg for Deal
CREATE TABLE #Temp_MTM_Start(
	temp_id INT IDENTITY(1,1),
	[deal_num] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	[time_bucket] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	[deal_side] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	[price_region] [VARCHAR](255) COLLATE DATABASE_DEFAULT  NULL,
	mtm_disc_eur FLOAT,
	pnl_as_of_date DATETIME
) ON [PRIMARY] 

INSERT #Temp_MTM_Start([deal_num],[time_bucket],[deal_side]
      ,[price_region] ,mtm_disc_eur,pnl_as_of_date
)
SELECT a.deal_num,time_bucket,d_leg.leg,
a.price_region,SUM(CAST(mtm_disc_eur AS FLOAT)) mtm_disc_eur,MAX(pnl_as_of_date)
FROM ssis_mtm_formate2_archive a JOIN #temp_deal_by_leg d_leg ON
a.deal_num=d_leg.deal_num AND 
a.price_region=d_leg.price_region AND 
a.settlement_type=d_leg.settlement_type 
--and a.fx_flt=d_leg.fx_flt  
JOIN (SELECT DISTINCT deal_id,buf_deal_date FROM #temp_buf) BUF
ON a.deal_num=buf.deal_id AND a.pnl_as_of_date=buf.buf_deal_date
GROUP BY a.deal_num,time_bucket,a.price_region,d_leg.leg,a.settlement_type
ORDER BY a.deal_num,time_bucket,a.settlement_type DESC

--select [deal_num],[time_bucket],(select count(*) from 
--#Temp_POS_Leg where deal_num=g.deal_num and time_bucket=g.time_bucket and temp_id<=g.temp_id
--) [deal_side],[price_region] ,mtm_disc_eur,pnl_as_of_date
--from #Temp_POS_Leg g 
--order by deal_num,time_bucket 
--Print 'GET MTM by Leg wise of Starting point End'

EXEC spa_print 'Insert BUF Deal in to Source_PNL_Table'



SELECT buf_header_id,CAST('01-'+CU.time_bucket AS DATETIME) term_start,
dbo.FNALastDayInDate('01-'+CU.time_bucket) term_end,
1 Leg,@pnl_as_of_date pnl_as_of_date,SUM((CU.mtm_disc_eur-ISNULL(st.mtm_disc_eur,0))*(bf.position_volume/bf.org_position_volume)) und_pnl,
SUM((CU.mtm_disc_eur-ISNULL(st.mtm_disc_eur,0))*(bf.position_volume/bf.org_position_volume)) und_intrinsic_pnl,
775 pnl_source_value_id,2 pnl_currency_id,1 pnl_conversion_factor,1 deal_volume,
bf.source_deal_header_id source_deal_header_id,buf_deal_id,SUM(st.mtm_disc_eur) Curr_und_pnl
INTO #calc_embd
FROM #Temp_MTM_Curr CU LEFT OUTER JOIN #Temp_MTM_start ST
ON cu.deal_num=st.deal_num AND CAST('1-'+cu.time_bucket AS DATETIME)=CAST('1-'+st.time_bucket  AS DATETIME)
AND ST.deal_side=CU.deal_side
--and ST.price_region=CU.price_region
JOIN #temp_buf BF ON BF.deal_id=CU.deal_NUm
AND BF.leg=CU.deal_side AND BF.term_start=CAST('1-'+cu.time_bucket AS DATETIME)
WHERE  CAST('1-'+cu.time_bucket AS DATETIME) > @pnl_as_of_date
GROUP BY buf_header_id,CU.time_bucket,cu.deal_side,bf.source_deal_header_id,buf_deal_id
--return

DECLARE @pnl_table_name VARCHAR(200)
SET @pnl_table_name=dbo.FNAGetProcessTableName(@pnl_as_of_date, 'source_deal_pnl') 
EXEC spa_print 'delete existing Buf Deal'
EXEC('delete '+@pnl_table_name +'
from '+@pnl_table_name +' pnl, #calc_embd ed
where  pnl.source_deal_header_id=ed.buf_header_id and pnl.term_start=ed.term_start
and pnl.term_end=ed.term_end and pnl.pnl_as_of_date='''+@pnl_as_of_date+'''')


/*
* Update [2010-05-20 @ bbajracharya@pioneersolutionsglobal.com]:

* Make sure following holds true
* dis_pnl = und_pnl
* dis_intrinsic_pnl = und_intrinsic_pnl
* dis_extrinisic_pnl = und_extrinisc_pnl = 0
* */
DECLARE @row_count INT,@total_row INT
EXEC spa_print 'insert Buf Deal in PNL'
EXEC('
insert '+@pnl_table_name +'(source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date,
und_pnl,und_intrinsic_pnl,und_extrinsic_pnl,dis_pnl,dis_intrinsic_pnl,dis_extrinisic_pnl,
pnl_source_value_id,pnl_currency_id,pnl_conversion_factor,deal_volume,
create_user,create_ts,update_user,update_ts
)
select buf_header_id,term_start,term_end,Leg,pnl_as_of_date,
und_pnl,und_intrinsic_pnl,0,und_pnl,und_intrinsic_pnl,0,pnl_source_value_id,pnl_currency_id,
pnl_conversion_factor,deal_volume,'''+@user_login_id+''',getdate(),'''+@user_login_id+''',getdate()
from #calc_embd')


--- Update Embedded Derivative Bifur Deal
EXEC('
update '+@pnl_table_name +' set und_pnl=pnl_curr.Curr_und_pnl-ed.und_pnl,
und_intrinsic_pnl=pnl_curr.Curr_und_pnl-ed.und_pnl,
und_extrinsic_pnl = 0, dis_pnl = pnl_curr.Curr_und_pnl - ed.und_pnl
, dis_intrinsic_pnl = pnl_curr.Curr_und_pnl - ed.und_pnl, dis_extrinisic_pnl = 0
, update_user='''+@user_login_id+''',update_ts=getdate()
from '+@pnl_table_name +' pnl,
(select source_deal_header_id,term_start,term_end,sum(und_pnl) und_pnl from #calc_embd 
group by source_deal_header_id,term_start,term_end) ed,
(select sdh.source_deal_header_id,cast(''01-''+mtm_cc.time_bucket as datetime) term_start,
dbo.FNALastDayInDate(''01-''+mtm_cc.time_bucket) term_end,sum(mtm_disc_eur) Curr_und_pnl
 from #Temp_MTM_Curr mtm_cc join source_deal_header sdh
on mtm_cc.deal_num=sdh.deal_id
group by sdh.source_deal_header_id,mtm_cc.time_bucket) pnl_curr
where pnl.source_deal_header_id=ed.source_deal_header_id 
and pnl.source_deal_header_id=pnl_curr.source_deal_header_id
and pnl.term_start=pnl_curr.term_start
and pnl.term_end=pnl_curr.term_end
and pnl.term_start=ed.term_start
and pnl.term_end=ed.term_end and pnl.pnl_as_of_date='''+@pnl_as_of_date+'''
')

--- Update Embedded Derivative NOT Bifur Deal
EXEC('
update '+@pnl_table_name +' set und_pnl=ed.und_pnl,
und_intrinsic_pnl=ed.und_pnl, und_extrinsic_pnl = 0, dis_pnl = ed.und_pnl
, dis_intrinsic_pnl = ed.und_pnl, dis_extrinisic_pnl = 0
, update_user='''+@user_login_id+''',update_ts=getdate()
from '+@pnl_table_name +' pnl,
(select mtm.source_deal_header_id,mtm.term_start,mtm.term_end,
mtm.pnl_as_of_date,mtm.und_pnl
 from (
select sdh.source_deal_header_id,cast(''01-''+CU.time_bucket as datetime) term_start,
dbo.FNALastDayInDate(''01-''+CU.time_bucket) term_end,pnl_as_of_date,
sum(mtm_disc_eur) und_pnl from #Temp_MTM_Curr CU join source_deal_header sdh
on CU.deal_num=sdh.deal_id 
group by sdh.source_deal_header_id,pnl_as_of_date,time_bucket) MTM left outer join
#calc_embd ed on ed.source_deal_header_id=mtm.source_deal_header_id
and ed.term_start=mtm.term_start and ed.term_end=mtm.term_end
where ed.buf_header_id is null) ed
where pnl.source_deal_header_id=ed.source_deal_header_id 
and pnl.term_start=ed.term_start
and pnl.term_end=ed.term_end and pnl.pnl_as_of_date='''+@pnl_as_of_date+'''
')

-- DELETE PNL Settlement BIF Deal
DELETE source_deal_pnl_settlement
FROM  #calc_embd  a INNER JOIN 
source_deal_pnl_settlement b ON a.buf_header_id = b.source_deal_header_id 
AND	CAST(a.term_start AS DATETIME) = b.term_start AND 
CAST(a.term_end AS DATETIME) = b.term_end 
AND b.pnl_as_of_date <= CAST(a.pnl_as_of_date AS DATETIME)

-- INSERT PNL Settlement BIF Deal
INSERT source_deal_pnl_settlement(source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date,
und_pnl,und_intrinsic_pnl,und_extrinsic_pnl,dis_pnl,dis_intrinsic_pnl,dis_extrinisic_pnl,
pnl_source_value_id,pnl_currency_id,pnl_conversion_factor,deal_volume,
create_user,create_ts,update_user,update_ts)
SELECT buf_header_id,term_start,term_end,Leg,pnl_as_of_date,
und_pnl,und_intrinsic_pnl,0,und_pnl,und_intrinsic_pnl,0,pnl_source_value_id,pnl_currency_id,
pnl_conversion_factor,deal_volume,@user_login_id,GETDATE(),@user_login_id,GETDATE()
FROM #calc_embd 
ORDER BY buf_header_id,term_start

-- DELETE PNL Settlement HOST Deal (Matched in BIF )
DELETE source_deal_pnl_settlement
FROM  (SELECT source_deal_header_id,term_start,term_end,SUM(und_pnl) und_pnl,pnl_as_of_date 
FROM #calc_embd 
GROUP BY source_deal_header_id,pnl_as_of_date,term_start,term_end)  a INNER JOIN 
source_deal_pnl_settlement b ON a.source_deal_header_id = b.source_deal_header_id AND	
CAST(a.term_start AS DATETIME) = b.term_start AND 
CAST(a.term_end AS DATETIME) = b.term_end 
AND b.pnl_as_of_date <= CAST(a.pnl_as_of_date AS DATETIME)

-- DELETE PNL Settlement HOST Deal (NOT Matched in BIF )
DELETE source_deal_pnl_settlement
FROM source_deal_pnl_settlement pnl,
(SELECT mtm.source_deal_header_id,mtm.term_start,mtm.term_end,
mtm.pnl_as_of_date,mtm.und_pnl
 FROM (
SELECT sdh.source_deal_header_id,CAST('01-'+CU.time_bucket AS DATETIME) term_start,
dbo.FNALastDayInDate('01-'+CU.time_bucket) term_end,pnl_as_of_date,
SUM(mtm_disc_eur) und_pnl FROM #Temp_MTM_Curr CU JOIN source_deal_header sdh
ON CU.deal_num=sdh.deal_id 
GROUP BY sdh.source_deal_header_id,pnl_as_of_date,time_bucket) MTM LEFT OUTER JOIN
#calc_embd ed ON ed.source_deal_header_id=mtm.source_deal_header_id
AND ed.term_start=mtm.term_start AND ed.term_end=mtm.term_end
WHERE ed.buf_header_id IS NULL) ed
WHERE pnl.source_deal_header_id=ed.source_deal_header_id 
AND pnl.term_start=ed.term_start
AND pnl.term_end=ed.term_end AND pnl.pnl_as_of_date<=@pnl_as_of_date

-- Insert PNL Settlement HOST Deal (Matched in BIF )
SET @sql='
insert source_deal_pnl_settlement(source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date,
und_pnl,und_intrinsic_pnl,und_extrinsic_pnl,dis_pnl,dis_intrinsic_pnl,dis_extrinisic_pnl,
pnl_source_value_id,pnl_currency_id,pnl_conversion_factor,deal_volume,create_user,create_ts,update_user,update_ts)
select pnl.source_deal_header_id,pnl.term_start,pnl.term_end,pnl.Leg,pnl.pnl_as_of_date,
pnl.und_pnl,pnl.und_intrinsic_pnl,0,pnl.und_pnl,pnl.und_intrinsic_pnl,0,pnl.pnl_source_value_id,pnl_currency_id,
pnl_conversion_factor,deal_volume,'''+@user_login_id+''',getdate(),'''+@user_login_id+''',getdate()
from '+@pnl_table_name +' pnl join (select source_deal_header_id,term_start,term_end,sum(und_pnl) und_pnl,pnl_as_of_date 
from #calc_embd 
group by source_deal_header_id,pnl_as_of_date,term_start,term_end)  a
on pnl.source_deal_header_id=a.source_deal_header_id
and pnl.term_start=a.term_start and pnl.term_end=a.term_end
where pnl.pnl_as_of_date='''+CAST(@pnl_as_of_date AS VARCHAR)+'''
order by pnl.source_deal_header_id,pnl.term_start,pnl.term_end'

EXEC(@sql)
-- Insert PNL Settlement HOST Deal (NOT Matched in BIF )
SET @sql='insert source_deal_pnl_settlement(source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date,
und_pnl,und_intrinsic_pnl,und_extrinsic_pnl,dis_pnl,dis_intrinsic_pnl,dis_extrinisic_pnl,
pnl_source_value_id,pnl_currency_id,pnl_conversion_factor,deal_volume,
create_user,create_ts,update_user,update_ts)
select pnl.source_deal_header_id,pnl.term_start,pnl.term_end,Leg,pnl.pnl_as_of_date,
pnl.und_pnl,pnl.und_intrinsic_pnl,pnl.und_extrinsic_pnl, pnl.und_pnl, pnl.und_intrinsic_pnl, pnl.und_extrinsic_pnl,
pnl.pnl_source_value_id,pnl.pnl_currency_id,pnl.pnl_conversion_factor,pnl.deal_volume,
''' + @user_login_id + ''',getdate(),''' + @user_login_id + ''',getdate()
 from '+@pnl_table_name +'  pnl,
(select mtm.source_deal_header_id,mtm.term_start,mtm.term_end,
mtm.pnl_as_of_date,mtm.und_pnl
 from (
select sdh.source_deal_header_id,cast(''01-''+CU.time_bucket as datetime) term_start,
dbo.FNALastDayInDate(''01-''+CU.time_bucket) term_end,pnl_as_of_date,
sum(mtm_disc_eur) und_pnl from #Temp_MTM_Curr CU join source_deal_header sdh
on CU.deal_num=sdh.deal_id 
group by sdh.source_deal_header_id,pnl_as_of_date,time_bucket) MTM left outer join
#calc_embd ed on ed.source_deal_header_id=mtm.source_deal_header_id
and ed.term_start=mtm.term_start and ed.term_end=mtm.term_end
where ed.buf_header_id is null) ed
where pnl.source_deal_header_id=ed.source_deal_header_id 
and pnl.term_start=ed.term_start
and pnl.term_end=ed.term_end and pnl.pnl_as_of_date='+@pnl_as_of_date
EXEC(@sql)


--Bifurcation Deal Message
	INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,TYPE,
	[description],recommendation,create_user,create_ts,update_user,update_ts) 
	SELECT @process_id,'Success','Calc Embedded','Bifurcation',
	'Bifurcation','Total bifurcation deal found:'+ 
		CAST(COUNT(DISTINCT BUF_DEAL_ID ) AS VARCHAR) ,'N/A.',
	@user_login_id,GETDATE(),@user_login_id,GETDATE()
	 FROM #temp_buf

	INSERT INTO source_system_data_import_status_detail
	(process_id,source,TYPE,[description],type_error,create_user,create_ts,update_user,update_ts)
	SELECT @process_id,'Bifurcation','Bifurcation','Bifurcation DealID:'+ Buf_deal_Id,'Bifurcation',
	@user_login_id,GETDATE(),@user_login_id,GETDATE()
	FROM #temp_buf
	GROUP BY BUF_DEAL_ID
--Current PNL Not found
	INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,TYPE,
	[description],recommendation,create_user,create_ts,update_user,update_ts) 
	SELECT @process_id,'Error','Calc Embedded','CurrentPNL',
	'CurrentPNL','PNL value for bifurcation deal id:'+ Buf_deal_id +' dated '+ 
	@pnl_as_of_date +' not found,MTM calculation can not be completed' ,'N/A.',
	@user_login_id,GETDATE(),@user_login_id,GETDATE()
 FROM 
	#Temp_MTM_Curr CU RIGHT OUTER JOIN #temp_buf BF ON BF.deal_id=CU.deal_NUm
	WHERE cu.deal_NUm IS NULL

--Starting Data Point PNL Not found
	INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,TYPE,
	[description],recommendation,create_user,create_ts,update_user,update_ts) 
	SELECT @process_id,'Warning','Calc Embedded','InceptionPNL',
	'InceptionPNL','Inception date '+ dbo.FNADateFormat(buf_deal_date)+
	' PNL for bifurcation deal id:'+ Buf_deal_id +' not found,Value of 0 is used.' ,
	'N/A.',	@user_login_id,GETDATE(),@user_login_id,GETDATE() FROM 
	ssis_mtm_formate2_archive arh RIGHT OUTER JOIN 
(SELECT DISTINCT deal_id,buf_deal_id,buf_deal_date FROM #temp_buf) BUF
ON arh.deal_num=buf.deal_id AND arh.pnl_as_of_date=buf.buf_deal_date
WHERE arh.deal_num IS NULL ORDER BY deal_num

-- Total Row Effected
--insert into source_system_data_import_status(process_id,code,module,source,type,
--	[description],recommendation) 
--	select @process_id,'Success','Calc Embedded','Calculated',
--	'Calculated','Total bifurcation deal calc for MTM :'+ cast(count(distinct buf_deal_id) as varchar) ,'N/A.' from #calc_embd
--
--	insert into source_system_data_import_status_detail(process_id,source,type,[description],type_error)
--	select distinct @process_id,'Calculated','Calculated','Bifurcation DealID:'+ buf_deal_id,'Calculated'  from #calc_embd
--

DECLARE @url VARCHAR(1000),@desc VARCHAR(1000)

SET @user_login_id=dbo.FNADBUser()

SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

DECLARE @temptablequery VARCHAR(500)
SET @temptablequery ='exec '+DB_NAME()+'.dbo.spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''
		
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
				'MTM of embedded derivative calculation completed as of date '+ dbo.FNADateformat(@pnl_as_of_date) +'. Please check the status.</a>'
	EXEC  spa_message_board 'u', @user_login_id,
				NULL, 'Run Calc Embedded Derivative',
				@desc, '', '', 's', @batch_process_id,NULL,@batch_process_id,NULL,'n',@temptablequery,'y'

GO
