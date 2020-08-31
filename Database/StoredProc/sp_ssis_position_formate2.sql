
IF OBJECT_ID('sp_ssis_position_formate2') IS NOT NULL
	DROP  PROCEDURE [dbo].[sp_ssis_position_formate2]
GO

CREATE PROC [dbo].[sp_ssis_position_formate2] 
@process_id		varchar(200),
@source_system	varchar(200) = NULL,
@as_of_date		varchar(20) = NULL,
@adhoc_call		char(1) = NULL
AS 
DECLARE @temptbl varchar(1000)
DECLARE @user_login_id varchar(100)
DECLARE @call_imp_engine varchar(1000)
DECLARE @tblname varchar(1000)
DECLARE @SQL varchar(5000),@staging_table_name varchar(200)

----
--drop table #temp_deal_by_price
--drop table #temp_deal_by_leg
--drop table #temp1
----drop table #temp_deal
--drop table #Temp_Position
----drop table #Temp_POS_Leg
--declare @process_id varchar(100),@source_system varchar(200),@as_of_date varchar(20),@adhoc_call char(1)
--set @process_id='22221'
--set @source_system='Endur'
--set @as_of_date='2008-07-31'

IF @adhoc_call IS NULL
	SET @staging_table_name = 'ssis_mtm_formate2'	
ELSE
	SET @staging_table_name = 'ssis_mtm_formate2_error_log'	


CREATE TABLE #temp1(
table_name varchar(200) COLLATE DATABASE_DEFAULT)
INSERT #temp1
EXEC spa_import_temp_table '4022'
DECLARE @tName varchar(500),@default_uom varchar(5),@default_deal_id varchar(5)

SELECT @tName=table_name FROM #temp1
SET @default_uom='-1'
SET @default_deal_id='-1'

--update ssis_position_formate2
--set deal_side=isNUll(deal_side,0)+1
--where deal_num in (select deal_num from ssis_position_formate2
--where (deal_side=0 or deal_side is null) and delivery_accounting not in('Delivery'))

declare @source_system_id varchar(20)
SELECT @source_system_id=source_system_id FROM source_system_description WHERE source_system_Name=@source_system
IF @source_system_id IS NULL
SET @source_system_id='-1'

-------############ Finding Deal Leg #----------------------

CREATE TABLE #temp_deal_by_price(
temp_id int IDENTITY(1,1),
deal_num varchar(50) COLLATE DATABASE_DEFAULT,
price_region varchar(250) COLLATE DATABASE_DEFAULT,
fx_flt varchar(50) COLLATE DATABASE_DEFAULT,
settlement_type varchar(100) COLLATE DATABASE_DEFAULT
)

INSERT INTO #temp_deal_by_price(deal_num,price_region,fx_flt,settlement_type)
SELECT deal_num,price_region,fx_flt,settlement_type 
FROM ssis_mtm_formate2 t  
WHERE CAST(CASE WHEN ISDATE(time_bucket) = 0 THEN dbo.FNALastDayInDate('01-' + time_bucket)
			  ELSE dbo.FNALastDayInDate(time_bucket) END AS datetime) > CAST(dbo.FNALastDayInDate(@as_of_date) AS datetime)
GROUP BY deal_num,price_region,fx_flt,settlement_type
ORDER BY deal_num,settlement_type DESC, price_region
			
CREATE TABLE #temp_deal_by_leg(
temp_id int IDENTITY(1,1),
deal_num varchar(50) COLLATE DATABASE_DEFAULT,
price_region varchar(250) COLLATE DATABASE_DEFAULT,
fx_flt varchar(50) COLLATE DATABASE_DEFAULT,
settlement_type varchar(100) COLLATE DATABASE_DEFAULT,
leg int
)
--don't load now
--insert into #temp_deal_by_leg(deal_num,price_region,fx_flt,settlement_type,leg)
--select deal_num,price_region,fx_flt,settlement_type,(select count(*) from 
--#temp_deal_by_price where deal_num=g.deal_num  and temp_id<=g.temp_id
--) leg
--from #temp_deal_by_price g
--select * from #temp_deal_by_leg

create TABLE #temp_deal_by_leg_exist(
temp_id int IDENTITY(1,1),
deal_num varchar(50) COLLATE DATABASE_DEFAULT,
price_region varchar(250) COLLATE DATABASE_DEFAULT,
fx_flt varchar(50) COLLATE DATABASE_DEFAULT,
settlement_type varchar(100) COLLATE DATABASE_DEFAULT,
leg int
)

INSERT INTO #temp_deal_by_leg_exist(deal_num,price_region,fx_flt,settlement_type,leg)
SELECT sdh.deal_id,pcd.curve_id price_region ,
CASE WHEN fixed_float_leg='t' THEN 'Float' ELSE 'Fixed' END fx_flt,
block_description settlement_type,MAX(sdd.leg)
FROM source_deal_detail sdd JOIN source_deal_header  sdh ON
sdd.source_deal_header_id=sdh.source_deal_header_id 
JOIN source_price_curve_def pcd ON source_curve_def_id=sdd.curve_id
AND sdd.block_description IN('Cash Settlement','Physical Settlement')
WHERE sdh.source_system_id = @source_system_id
GROUP BY sdh.deal_id,pcd.curve_id,fixed_float_leg,block_description

--since we don't load previously, no need to delete now
--delete #temp_deal_by_leg 
--from #temp_deal_by_leg l,#temp_deal_by_leg_exist n
--where l.deal_num=n.deal_num

--copy all existing legs
insert INTO #temp_deal_by_leg(deal_num,price_region,fx_flt,settlement_type,leg)
SELECT deal_num,price_region,fx_flt,settlement_type,leg FROM #temp_deal_by_leg_exist

-- insert only newly added legs. Newly added legs are those which are present in #temp_deal_by_price but absent in #temp_deal_by_leg_exist
-- Leg is calculated accordingly for the new leg incrementing the leg value from the max of previous value if available
INSERT INTO #temp_deal_by_leg(deal_num, price_region, fx_flt, settlement_type, leg)
SELECT new_leg.deal_num, new_leg.price_region, new_leg.fx_flt, new_leg.settlement_type, (new_leg.leg + ISNULL(existing_leg.leg, 0)) leg
FROM
(
	SELECT g.deal_num, g.price_region, g.fx_flt, g.settlement_type, ROW_NUMBER() OVER(PARTITION BY g.deal_num ORDER BY g.deal_num, g.settlement_type DESC, g.price_region) leg
	FROM #temp_deal_by_price g
	LEFT JOIN #temp_deal_by_leg_exist e ON g.deal_num = e.deal_num AND g.price_region = e.price_region 
		AND g.fx_flt = e.fx_flt AND g.settlement_type = e.settlement_type
	WHERE e.deal_num IS NULL AND e.price_region IS NULL AND e.fx_flt IS NULL AND e.settlement_type IS NULL
) new_leg
LEFT JOIN
(
	SELECT MAX(leg) leg, deal_num FROM #temp_deal_by_leg_exist le GROUP BY deal_num
) existing_leg
ON new_leg.deal_num = existing_leg.deal_num

-------############ Finding Deal Leg End #----------------------


EXEC spa_print 'End ########'
--EXEC spa_print CONVERT(varchar,GETDATE(),109)

-- Adjusting Leg for Deal
CREATE TABLE #Temp_Position(
	temp_id int IDENTITY(1,1),
	[deal_num] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[time_bucket] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[deal_side] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[fx_flt] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[buy_sell] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[price_region] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[settlement_currency] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[Position] [money] NULL,
	[unit_of_measure] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[block_description] [varchar](1) COLLATE DATABASE_DEFAULT  NOT NULL,
	[reference] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[trade_date] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[settlement_type] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[counterparty] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[ins_type] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[ins_sub_type] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[ias39_book] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[portfolio] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[commodity_balance] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[ias39_scope] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[trader] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	[header_buy_sell_flag] [varchar](1) COLLATE DATABASE_DEFAULT  NOT NULL,
	[broker_id] [int] NULL,
	[contract_id] [int] NULL,
	[legal_entity] [varchar](255) COLLATE DATABASE_DEFAULT  NULL,
	delivery_accounting varchar(250) COLLATE DATABASE_DEFAULT,
	source_system_id int,
--new added
	internal_desk [varchar](100) COLLATE DATABASE_DEFAULT,
	product [varchar](100) COLLATE DATABASE_DEFAULT,
	commodity [varchar](100) COLLATE DATABASE_DEFAULT
) ON [PRIMARY] 

SET @SQL='
INSERT #Temp_Position([deal_num],[time_bucket],[deal_side]
      ,[fx_flt] ,[buy_sell] ,[price_region] ,[settlement_currency]
      ,[Position],[unit_of_measure] ,[block_description]
      ,[reference] ,[trade_date]  ,[settlement_type]
      ,[counterparty]   ,[ins_type] ,[ins_sub_type]   ,[ias39_book] ,[portfolio]  ,[commodity_balance]
      ,[ias39_scope],[trader] ,[header_buy_sell_flag]  ,[broker_id]
      ,[contract_id] ,[legal_entity],delivery_accounting,source_system_id,
	internal_desk,
	product,
	commodity
)
SELECT t.deal_num,time_bucket,d_leg.leg deal_side,t.fx_flt,buy_sell,t.price_region,
CASE WHEN MAX(settlement_currency) IS NULL OR MAX(settlement_currency)='''' 
THEN ''EUR'' ELSE MAX(settlement_currency) END settlement_currency,
''1'' Position,
ISNULL(MAX(CASE WHEN unit_of_measure ='''' THEN NULL ELSE unit_of_measure END),'''+ @default_uom +''') unit_of_measure,
''-'' block_description,
MAX(t.reference) reference, trade_date, t.settlement_type, counterparty,
CASE WHEN ins_type='''' OR ins_type IS NULL THEN '''+ @default_deal_id +''' ELSE ins_type end,
ins_sub_type,ias39_book, portfolio, commodity_balance, ias39_scope,
max(trader) trader, ''b'' header_buy_sell_flag,
null broker_id, null contract_id, MAX(legal_entity) legal_entity, 
''1'' delivery_accounting, ' +
CASE WHEN @adhoc_call IS NOT NULL THEN ' t.source_system_id  ' 
	 ELSE '' + @source_system_id   + ''  END + ',
MAX(internal_desk) internal_desk,
MAX(product) product,
MAX(commodity) commodity
FROM ' + @staging_table_name + ' t  JOIN #temp_deal_by_leg d_leg on
t.deal_num = d_leg.deal_num and 
t.price_region = d_leg.price_region and 
t.settlement_type = d_leg.settlement_type and 
t.fx_flt = d_leg.fx_flt 
WHERE 
CAST(CASE WHEN ISDATE(time_bucket) = 0 THEN dbo.FNALastDayInDate(''01-'' + time_bucket) 
	 ELSE dbo.FNALastDayInDate(time_bucket) END AS datetime) > 
CAST(dbo.FNALastDayInDate('''+ @as_of_date +''') AS datetime)
GROUP BY t.deal_num, time_bucket, t.price_region, d_leg.leg, t.fx_flt, buy_sell, trade_date, t.settlement_type,
counterparty, ins_type, ins_sub_type, ias39_book, portfolio, commodity_balance, ias39_scope ' + 
CASE WHEN @adhoc_call IS NOT NULL THEN ', t.source_system_id  ' 
 	 ELSE '' END +'
ORDER BY t.deal_num, time_bucket, t.settlement_type DESC'
exec spa_print @SQL;
EXEC(@SQL);

--select * from #Temp_Position
EXEC spa_print '2 End ########'
--EXEC spa_print CONVERT(varchar,GETDATE(),109)
--return
--drop table #Temp_POS_Leg -- Release Memory space 

--Merge 2 Leg Deal to 1 Leg Deal

SET @SQL='insert '+@tName+'(deal_id,source_system_id,term_start,term_end,leg,
contract_expiration_date,fixed_float_leg,
buy_sell_flag,curve_id,
fixed_price,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,
deal_detail_description,formula_id,deal_date,ext_deal_id,physical_financial_flag,structured_deal_id,counterparty_id,
source_deal_type_id,source_deal_sub_type_id,option_flag,option_type,option_excercise_type,source_system_book_id1,source_system_book_id2,
source_system_book_id3,source_system_book_id4,description1,description2,description3,deal_category_value_id,trader_id,
header_buy_sell_flag,broker_id,contract_id,legal_entity,
internal_desk_id,product_id,commodity_id,reference, table_code
)
select p.deal_num, source_system_id,
''01-''+ p.time_bucket,
cast(dbo.FNALastDayInMonth(''01-''+ p.time_bucket) as varchar)+''-''+ p.time_bucket ,
1 deal_side,
cast(dbo.FNALastDayInMonth(''01-''+ p.time_bucket) as varchar)+''-''+ p.time_bucket ,
''t'' fixed_float_leg,
isNull(t.buy_sell_flag,''b''),
t.price_region,0 fixed_price,
ISNULL(f.settlement_currency, ''EUR''),0 option_strike_price,
1,
''m'' deal_volume_frequency,p.unit_of_measure,t.settlement_type block_description,
null,null formula_id,p.trade_date,
null ext_deal_id,
t.physical_financial_flag,
null structured_deal_id,p.counterparty,
p.source_deal_type_id,isNull(nullif(p.source_deal_sub_type_id ,''''),NULL) 
source_deal_sub_type_id,
''n'' option_flag,null option_type,null option_excercise_type,
p.ias39_book,p.portfolio,
p.commodity_balance,
p.ias39_scope
,null description1,null description2, null description3,476 deal_category_value_id,
p.trader,isNull(t.buy_sell_flag,''b'') header_buy_sell_flag,
null broker_id,null contract_id,p.legal_entity,
p.internal_desk,p.product,p.commodity, p.reference,
4005  table_code
from
(
select distinct deal_num,time_bucket,
max(position) position,
max(unit_of_measure) unit_of_measure,
max(reference) reference,
max(trade_date) trade_date,
max(counterparty) counterparty,
max(ins_type)  source_deal_type_id,
isNull(nullif(max(ins_sub_type) ,''''),NULL) source_deal_sub_type_id,
isNull(nullif(max(ias39_book),''''),''-1'') ias39_book,isNull(nullif(max(portfolio),''''),''-2'') portfolio,
isNull(nullif(max(commodity_balance),''''),''-3'') commodity_balance,
isNull(nullif(max(ias39_scope),''''),''-4'') ias39_scope,
max(trader) trader,
max(legal_entity) legal_entity,
max(source_system_id) source_system_id,
max(internal_desk) internal_desk,max(product) product,max(commodity) commodity
from #temp_position 
--where delivery_accounting <>(''Delivery'') or delivery_accounting is NULL
group by deal_num,time_bucket
having min(fx_flt)=''fixed'' and max(deal_side)=2 
	and case when max(fx_flt)=''Float'' then deal_num else null end is not null
) p
left outer join (
select flt.deal_num, flt.time_bucket,
	case when flt.buy_sell=''Buy'' then ''b'' else ''s'' end buy_sell_flag,
	flt.price_region,
	case when flt.settlement_type=''Physical Settlement'' then ''p'' else ''f'' end physical_financial_flag,
	flt.settlement_type settlement_type 
 from #temp_position fix 
join #temp_position flt on 
fix.deal_num=flt.deal_num 
and fix.time_bucket=flt.time_bucket
inner join (select deal_num from #temp_position
group by deal_num
having max(deal_side)=2) t1 on flt.deal_num=t1.deal_num
where fix.temp_id <> flt.temp_id
and fix.fx_flt=''fixed'' and flt.fx_flt=''float''
-- and flt.deal_num in (select deal_num from #temp_position
--group by deal_num
--having max(deal_side)=2) 

) t on p.deal_num=t.deal_num and p.time_bucket=t.time_bucket
left outer join (
	select  deal_num, time_bucket,
	max(settlement_currency) settlement_currency
	from #temp_position		
	where fx_flt=''Fixed'' --and delivery_accounting not in(''Delivery'')
	group by deal_num,time_bucket,buy_sell
	having min(fx_flt)=''fixed'' and max(deal_side)=2 
) f on p.deal_num=f.deal_num and p.time_bucket=f.time_bucket 

'
EXEC spa_print @sql
--select distinct * from #temp_deal'
exec(@sql)

--Insert deal except 2 Leg Deal 
set @sql='insert '+@tName+'(deal_id,source_system_id,term_start,term_end,leg,contract_expiration_date,fixed_float_leg,
buy_sell_flag,curve_id,
fixed_price,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,
deal_detail_description,formula_id,deal_date,ext_deal_id,physical_financial_flag,structured_deal_id,counterparty_id,
source_deal_type_id,source_deal_sub_type_id,option_flag,option_type,option_excercise_type,source_system_book_id1,source_system_book_id2,
source_system_book_id3,source_system_book_id4,description1,description2,description3,deal_category_value_id,trader_id,
header_buy_sell_flag,broker_id,contract_id,legal_entity,
internal_desk_id,product_id,commodity_id,reference, table_code)
select deal_num, p.source_system_id,
''01-''+time_bucket,
cast(dbo.FNALastDayInMonth(''01-''+time_bucket) as varchar) +''-''+ time_bucket,
deal_side,
cast(dbo.FNALastDayInMonth(''01-''+ time_bucket) as varchar) +''-''+ time_bucket,
case when fx_flt=''float'' then ''t'' else ''f'' end fixed_float_leg,
case when buy_sell=''Buy''  then ''b'' else ''s'' end buy_sell_flag,price_region,0 fixed_price,
settlement_currency,0 option_strike_price,1,
''m'' deal_volume_frequency,unit_of_measure,settlement_type block_description,
null,null formula_id,trade_date,null ext_deal_id,
case when settlement_type=''Physical Settlement'' then ''p'' else ''f'' end physical_financial_flag,
null structured_deal_id,counterparty,ins_type  source_deal_type_id,
isNull(nullif(ins_sub_type,''''),NULL)  source_deal_sub_type_id,''n'' option_flag,null option_type,null option_excercise_type,
isNull(nullif(ias39_book,''''),''-1'') ias39_book,isNull(nullif(portfolio,''''),''-2'') portfolio,
isNull(nullif(commodity_balance,''''),''-3'') commodity_balance,
isNull(nullif(ias39_scope,''''),''-4'') ias39_scope
,null description1,null description2, null description3,476 deal_category_value_id,
trader,''b'' header_buy_sell_flag,
null broker_id,null contract_id,p.legal_entity,
p.internal_desk,p.product,p.commodity,p.reference,
4005  table_code
from #temp_position p left outer join
'+ @tName +' t
on t.deal_id=p.deal_num and ''01-''+p.time_bucket=t.term_start
where t.deal_id is NULL '
EXEC spa_print  @sql
exec(@sql)
EXEC spa_print 'insert '--+ convert(varchar,getdate(),109)

--make fx_flt_flag to t(FLOAT) for those deal details that aren't merged & whose leg = 1 & is FIXED 
SET @sql = 'UPDATE ' + @tName + ' SET fixed_float_leg = ''t''
		   FROM ' + @tName + ' t
		   INNER JOIN (
				--get merged deals
				SELECT DISTINCT deal_num, time_bucket
				FROM #temp_position 
				GROUP BY deal_num, time_bucket
				HAVING MIN(fx_flt) = ''fixed'' AND MAX(deal_side) = 2 
				AND (CASE WHEN MAX(fx_flt) = ''Float'' THEN deal_num ELSE NULL END) IS NOT NULL
			) m ON t.deal_id = m.deal_num
			WHERE fixed_float_leg = ''f'' AND leg = 1'
exec spa_print 'Update Leg after deal merging', @sql
EXEC(@sql)

-- Insert Trader if not found
IF @adhoc_call IS NULL
BEGIN

--select * from #temp_position
	INSERT source_traders(source_system_id,trader_id,trader_name,trader_desc)
	SELECT DISTINCT t.source_system_id, trader,trader,trader FROM #temp_position t LEFT OUTER JOIN source_traders st
	ON st.trader_id=t.trader AND st.source_system_id=t.source_system_id
	WHERE st.trader_id IS NULL AND t.trader IS NOT NULL

	INSERT source_uom(source_system_id,uom_id,uom_name,uom_desc)
	SELECT DISTINCT t.source_system_id, unit_of_measure,unit_of_measure,unit_of_measure 
	FROM #temp_position t LEFT OUTER JOIN source_uom st
	ON st.uom_id=t.unit_of_measure AND st.source_system_id=t.source_system_id
	WHERE st.uom_id IS NULL AND t.unit_of_measure IS NOT NULL
	EXEC spa_print 'insert trader '--+ CONVERT(varchar,GETDATE(),109)

--Add for new added tables
--p.internal_desk,p.product,p.commodity
	INSERT source_internal_desk(source_system_id,internal_desk_id,internal_desk_name,internal_desk_desc)
	SELECT DISTINCT t.source_system_id, internal_desk,internal_desk,internal_desk FROM #temp_position t 
	LEFT OUTER JOIN source_internal_desk st
	ON st.internal_desk_id=t.internal_desk AND st.source_system_id=t.source_system_id
	WHERE st.internal_desk_id IS NULL AND t.internal_desk IS NOT NULL

	EXEC spa_print 'insert source_internal_desk '--+ CONVERT(varchar,GETDATE(),109)

	INSERT source_product(source_system_id,product_id,product_name,product_desc)
	SELECT DISTINCT t.source_system_id, product,product,product FROM #temp_position t 
	LEFT OUTER JOIN source_product st
	ON st.product_id=t.product AND st.source_system_id=t.source_system_id
	WHERE st.product_id IS NULL AND t.product IS NOT NULL
	EXEC spa_print 'insert source_product '--+ CONVERT(varchar,GETDATE(),109)

	INSERT source_commodity(source_system_id,commodity_id,commodity_name,commodity_desc)
	SELECT DISTINCT t.source_system_id, commodity,commodity,commodity FROM #temp_position t 
	LEFT OUTER JOIN source_commodity st
	ON st.commodity_id=t.commodity AND st.source_system_id=t.source_system_id
	WHERE st.commodity_id IS NULL AND t.commodity IS NOT NULL
	EXEC spa_print 'insert source_commodity '--+ CONVERT(varchar,GETDATE(),109)


END
-- Drop to release 
-- ANOOP
drop TABLE #temp_position
--


IF @process_id IS NULL
	SET @process_id = REPLACE(NEWID(),'-','_')
DECLARE @is_schedule varchar(1)
IF @adhoc_call IS NULL
	SET @is_schedule='y'
ELSE
	SET @is_schedule='n'
SET @user_login_id=dbo.FNADBUser()
SET @call_imp_engine='exec spa_import_data_job '''+@tName +''',4005,''Interface_Position'',
'''+@process_id+''','''+ @user_login_id+''','''+ @is_schedule +''',1,''formate2'','''+@as_of_date+''''
exec spa_print @call_imp_engine
EXEC(@call_imp_engine)

--set leg value to 1 whose min leg value is GT 1
UPDATE source_deal_detail SET leg = 1
FROM source_deal_detail sdd 
INNER JOIN
(
	SELECT sdd.source_deal_header_id, MIN(leg) leg1
	FROM source_deal_detail sdd 
	INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
	GROUP BY sdd.source_deal_header_id
	HAVING MIN(leg) > 1
) sdd1
ON sdd1.source_deal_header_id = sdd.source_deal_header_id
	AND sdd1.leg1 = sdd.leg

--if @adhoc_call is null
--	truncate table ssis_position_formate2

--delete source_deal_external where deal_id in (select deal_num from ssis_position_formate2)
DELETE source_deal_external FROM source_deal_external s INNER JOIN ssis_mtm_formate2 d ON s.deal_id = d.deal_num

INSERT INTO [source_deal_external]
   ([deal_id]
   , [price_region]
   , [deal_side]
   , [settlement_type]
   , [create_ts],fixed_float)
SELECT deal_num, price_region, deal_side, settlement_type, GETDATE(), fx_flt
FROM ssis_mtm_formate2
GROUP BY deal_num, price_region, deal_side, settlement_type, fx_flt

IF NOT EXISTS (SELECT status_id FROM source_system_data_import_status 
				WHERE process_id = @process_id AND code = 'Error')
	EXEC spa_ErrorHandler 0, 'Interface_Position', 
	'Interface_Position', 'Success', 
	'Imported Successful.', ''
ELSE
	EXEC spa_ErrorHandler -1, 'Interface_Position', 
	'Interface_Position', 'Error', 
	'Imported Failed.', ''







































GO
