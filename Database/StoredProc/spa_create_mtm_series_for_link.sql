
IF OBJECT_ID('spa_create_mtm_series_for_link') IS NOT null
drop proc spa_create_mtm_series_for_link
GO

--EXEC spa_create_mtm_series_for_link 2030, '2011-02-01', '2011-09-10', 0, 0
--select * from source_deal_pnl where source_deal_header_id in (9, 279)

--If @day_of_week is 0 or NULL then it takes all days in the range provided.
create PROCEDURE [dbo].[spa_create_mtm_series_for_link] (@rel_id VARCHAR(500), @as_of_date_from VARCHAR(20), @as_of_date_to VARCHAR(20), @day_of_week INT = 0,
		@calculate_MTM INT = 1) --If @calculate_MTM = 1 then calculate if not retrieve from source_deal_pnl 
AS
SET NOCOUNT ON

-------UNCOMMENT THE FOLLOWING TO TEST
/*
DROP TABLE #sdd
DROP TABLE #pnl
DROP TABLE #cum_pnl
DROP TABLE #eff_pnl
DROP TABLE #links

DECLARE @rel_id VARCHAR(500)
DECLARE @as_of_date_from VARCHAR(20)
DECLARE @as_of_date_to VARCHAR(20)
DECLARE @day_of_week INT
DECLARE @calculate_MTM INT

SET @rel_id = '2030'
SET @as_of_date_from = '2011-02-01'
SET @as_of_date_to = '2011-09-10'
set @day_of_week = 0 --Thursday
set @calculate_MTM = 0
--select * from source_deal_detail
--select datepart(dw,'2004-07-22')
--*/

--select * from fas_link_header where link_id = 2030

-------END OF TEST

CREATE TABLE #links
(link_id INT,
 link_effective_date DATETIME)

DECLARE @get_links varchar(1000)
set @get_links = 'INSERT INTO #links SELECT link_id, link_effective_date from fas_link_header where link_id IN (' + @rel_id + ')'
exec (@get_links) 

if @as_of_date_to IS NULL OR @as_of_date_to = ''
	set @as_of_date_to = @as_of_date_from

if @day_of_week = 0
	set @day_of_week = NULL

CREATE TABLE #sdd (
link_id INT,
source_deal_header_id INT, 
term_start DATETIME, 
term_end DATETIME, 
leg INT, 
buy_sell_flag VARCHAR(1) COLLATE DATABASE_DEFAULT, 
curve_id INT, 
fixed_price FLOAT, 
deal_volume FLOAT, 
deal_volume_frequency VARCHAR(1) COLLATE DATABASE_DEFAULT, 
price_adder FLOAT, 
price_multiplier FLOAT,
fixed_price_currency_id INT,
hedge_or_item varchar(1) COLLATE DATABASE_DEFAULT,
percentage_included float,
link_effective_date datetime,
deal_date DATETIME,
header_link_effective_date DATETIME,
detail_link_effective_date DATETIME
)


INSERT INTO #sdd
select	l.link_id, sdd.source_deal_header_id, sdd.term_start, sdd.term_end, sdd.leg, sdd.buy_sell_flag, sdd.curve_id, sdd.fixed_price, sdd.deal_volume, 
		sdd.deal_volume_frequency, sdd.price_adder, sdd.price_multiplier, sdd.fixed_price_currency_id,
		hedge_or_item, percentage_included, 
		dbo.FNAMaxDate(COALESCE(fld.effective_date, l.link_effective_date, sdh.deal_date), sdh.deal_date) AS link_effective_date,
		sdh.deal_date, l.link_effective_date header_link_effective_date, isnull(fld.effective_date, '1900-01-01') detail_link_effective_date

from	#links l INNER JOIN
		fas_link_detail fld ON fld.link_id = l.link_id INNER JOIN
		source_deal_detail sdd ON sdd.source_deal_header_id = fld.source_deal_header_id INNER JOIN
		source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id 


CREATE TABLE #cum_pnl (
link_id INT,
source_deal_header_id INT,
as_of_date DATETIME,
und_PNL FLOAT,
und_rel_PNL FLOAT,
dis_rel_PNL FLOAT,
hedge_or_item VARCHAR(1) COLLATE DATABASE_DEFAULT,
link_effective_date DATETIME, 
header_link_effective_date DATETIME, 
detail_link_effective_date DATETIME
)

CREATE TABLE #eff_pnl (
link_id INT,
source_deal_header_id INT,
as_of_date DATETIME,
und_PNL FLOAT,
und_rel_PNL FLOAT,
dis_rel_PNL FLOAT,
hedge_or_item VARCHAR(1) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #pnl (
link_id INT,
source_deal_header_id INT,
as_of_date DATETIME,
und_PNL FLOAT,
und_rel_PNL FLOAT,
dis_rel_PNL FLOAT,
hedge_or_item VARCHAR(1) COLLATE DATABASE_DEFAULT
)

--calculate cumulative PNL for as of date if 1 or else retrive it
If @calculate_MTM = 1
	insert into #cum_pnl
	select	link_id, source_deal_header_id, as_of_date as_of_date, 
			sum(CASE WHEN ((link_effective_date <= as_of_date) OR (header_link_effective_date = detail_link_effective_date)) then MTM else 0 end) und_PNL,
			sum(CASE WHEN ((link_effective_date <= as_of_date) OR (header_link_effective_date = detail_link_effective_date)) then MTM else 0 end*percentage_included) und_rel_PNL,
			sum(CASE WHEN ((link_effective_date <= as_of_date) OR (header_link_effective_date = detail_link_effective_date)) then MTM else 0 end*percentage_included) dis_rel_PNL,
			hedge_or_item,
			link_effective_date, header_link_effective_date, detail_link_effective_date
	FROM (
	select	sdd.link_id, spc.as_of_date, sdd.source_deal_header_id, 
			sdd.term_start, sdd.term_end, sdd.leg, 
			sdd.buy_sell_flag, sdd.curve_id, sdd.fixed_price, sdd.deal_volume, 
			sdd.deal_volume_frequency, sdd.price_adder, sdd.price_multiplier, spc.curve_value,
			CASE WHEN sdd.deal_volume_frequency ='d' THEN (datediff(day, sdd.term_start, sdd.term_end)+1) ELSE 1 END * 
			sdd.deal_volume	* 
			CASE WHEN (sdd.buy_sell_flag = 'b') THEN 1 ELSE -1 END *
			CASE WHEN (mleg.max_leg = 1) THEN
				ISNULL(spc.curve_value, 0) - ((ISNULL(sdd.fixed_price, 0) + ISNULL(sdd.price_adder, 0)) * ISNULL(sdd.price_multiplier, 1))  
			ELSE
				ISNULL(spc.curve_value, 0) + ((ISNULL(sdd.fixed_price, 0) + ISNULL(sdd.price_adder, 0)) * ISNULL(sdd.price_multiplier, 1))  	
			END MTM,
			sdd.fixed_price_currency_id,
			sdd.hedge_or_item,
			sdd.percentage_included,
			sdd.link_effective_date,
			sdd.header_link_effective_date,
			sdd.detail_link_effective_date	

	from #sdd sdd INNER JOIN
	(select source_deal_header_id, max(leg) max_leg from #sdd group by source_deal_header_id) mleg ON mleg.source_deal_header_id = sdd.source_deal_header_id INNER JOIN
	source_price_curve spc ON	spc.source_curve_def_id = sdd.curve_id AND
								spc.maturity_Date = sdd.term_start AND
								spc.curve_source_value_id = 4500 AND	
								spc.assessment_curve_type_value_id = 77 AND
								spc.as_of_date BETWEEN @as_of_date_from AND @as_of_date_to AND
								datepart(dw,spc.as_of_date) = isnull(@day_of_week, datepart(dw,spc.as_of_date))
	) m 
	GROUP BY source_deal_header_id, as_of_date, link_id, hedge_or_item, link_effective_date, header_link_effective_date, detail_link_effective_date
	ORDER BY as_of_date, link_id, source_deal_header_id
Else -- 0
	insert into #cum_pnl
	select	link_id, source_deal_header_id, as_of_date as_of_date, 
			sum(CASE WHEN ((link_effective_date <= as_of_date) OR (header_link_effective_date = detail_link_effective_date)) then MTM else 0 end) und_PNL,
			sum(CASE WHEN ((link_effective_date <= as_of_date) OR (header_link_effective_date = detail_link_effective_date)) then MTM else 0 end*percentage_included) und_rel_PNL,
			sum(CASE WHEN ((link_effective_date <= as_of_date) OR (header_link_effective_date = detail_link_effective_date)) then DMTM else 0 end*percentage_included) dis_rel_PNL,
			hedge_or_item,
			link_effective_date, header_link_effective_date, detail_link_effective_date
	FROM (
	select	sdd.link_id, sdp.pnl_as_of_date as_of_date, sdd.source_deal_header_id, 
			sdd.term_start, sdd.term_end, sdd.leg, 
			sdd.buy_sell_flag, sdd.curve_id, sdd.fixed_price, sdd.deal_volume, 
			sdd.deal_volume_frequency, sdd.price_adder, sdd.price_multiplier, 
			sdp.und_pnl MTM,						
			sdp.dis_pnl DMTM,						
			sdd.fixed_price_currency_id,
			sdd.hedge_or_item,
			sdd.percentage_included,
			sdd.link_effective_date,
			sdd.header_link_effective_date,
			sdd.detail_link_effective_date	

	from #sdd sdd INNER JOIN
		source_deal_pnl sdp ON sdd.source_deal_header_id = sdp.source_deal_header_id AND
					sdp.term_start = sdd.term_start AND sdp.term_end = sdd.term_end AND
					sdp.pnl_source_value_id IN  (775, 4500) AND
					datepart(dw,sdp.pnl_as_of_date) = isnull(NULL, datepart(dw,sdp.pnl_as_of_date))
		where	sdd.leg = 1
	) m
	GROUP BY source_deal_header_id, as_of_date, link_id, hedge_or_item, link_effective_date, header_link_effective_date, detail_link_effective_date
	ORDER BY as_of_date, link_id, source_deal_header_id

--select * from #sdd
--select * from #eff_pnl

--Calculate Effective Date PNL  if 1 or else retrive it
If @calculate_MTM = 1
	insert into #eff_pnl
	select	link_id, source_deal_header_id, as_of_date as_of_date,
			sum(CASE WHEN (link_effective_date > deal_date) then MTM else 0 end) und_PNL,
			sum(CASE WHEN (link_effective_date > deal_date) then MTM else 0 end*percentage_included) und_rel_PNL,
			sum(CASE WHEN (link_effective_date > deal_date) then MTM else 0 end*percentage_included) dis_rel_PNL,
			hedge_or_item
	FROM (
	select	sdd.link_id, spc.as_of_date, sdd.source_deal_header_id, 
			sdd.term_start, sdd.term_end, sdd.leg, sdd.deal_date, 
			sdd.buy_sell_flag, sdd.curve_id, sdd.fixed_price, sdd.deal_volume, 
			sdd.deal_volume_frequency, sdd.price_adder, sdd.price_multiplier, spc.curve_value,
			CASE WHEN sdd.deal_volume_frequency ='d' THEN (datediff(day, sdd.term_start, sdd.term_end)+1) ELSE 1 END * 
			sdd.deal_volume	* 
			CASE WHEN (sdd.buy_sell_flag = 'b') THEN 1 ELSE -1 END *
			CASE WHEN (mleg.max_leg = 1) THEN
				ISNULL(spc.curve_value, 0) - ((ISNULL(sdd.fixed_price, 0) + ISNULL(sdd.price_adder, 0)) * ISNULL(sdd.price_multiplier, 1))  
			ELSE
				ISNULL(spc.curve_value, 0) + ((ISNULL(sdd.fixed_price, 0) + ISNULL(sdd.price_adder, 0)) * ISNULL(sdd.price_multiplier, 1))  	
			END MTM,
			sdd.fixed_price_currency_id,
			sdd.hedge_or_item,
			sdd.percentage_included,
			sdd.link_effective_date,	
			sdd.header_link_effective_date,
			sdd.detail_link_effective_date	

	from #sdd sdd INNER JOIN
	(select source_deal_header_id, max(leg) max_leg from #sdd group by source_deal_header_id) mleg ON mleg.source_deal_header_id = sdd.source_deal_header_id INNER JOIN
	source_price_curve spc ON	spc.source_curve_def_id = sdd.curve_id AND
								spc.maturity_Date = sdd.term_start AND
								spc.curve_source_value_id = 4500 AND	
								spc.assessment_curve_type_value_id = 77 AND
								spc.as_of_date = sdd.link_effective_date
	) m 
	GROUP BY source_deal_header_id, as_of_date, link_id, hedge_or_item
	ORDER BY as_of_date, link_id, source_deal_header_id
Else -- 0
	insert into #eff_pnl
	select	link_id, source_deal_header_id, as_of_date as_of_date, 
			sum(CASE WHEN ((link_effective_date <= as_of_date) OR (header_link_effective_date = detail_link_effective_date)) then MTM else 0 end) und_PNL,
			sum(CASE WHEN ((link_effective_date <= as_of_date) OR (header_link_effective_date = detail_link_effective_date)) then MTM else 0 end*percentage_included) und_rel_PNL,
			sum(CASE WHEN ((link_effective_date <= as_of_date) OR (header_link_effective_date = detail_link_effective_date)) then DMTM else 0 end*percentage_included) dis_rel_PNL,
			hedge_or_item
	FROM (
	select	sdd.link_id, sdp.pnl_as_of_date as_of_date, sdd.source_deal_header_id, 
			sdd.term_start, sdd.term_end, sdd.leg, 
			sdd.buy_sell_flag, sdd.curve_id, sdd.fixed_price, sdd.deal_volume, 
			sdd.deal_volume_frequency, sdd.price_adder, sdd.price_multiplier, 
			sdp.und_pnl MTM,						
			sdp.dis_pnl DMTM,						
			sdd.fixed_price_currency_id,
			sdd.hedge_or_item,
			sdd.percentage_included,
			sdd.link_effective_date,
			sdd.header_link_effective_date,
			sdd.detail_link_effective_date	

	from #sdd sdd INNER JOIN
		source_deal_pnl sdp ON sdd.source_deal_header_id = sdp.source_deal_header_id AND
					sdp.pnl_source_value_id IN  (775, 4500) AND
					sdp.pnl_as_of_date = sdd.link_effective_date
	) m
	GROUP BY source_deal_header_id, as_of_date, link_id, hedge_or_item, link_effective_date, header_link_effective_date, detail_link_effective_date
	ORDER BY as_of_date, link_id, source_deal_header_id


--Get final pnl = cumulative pnl - effective pnl
insert into #pnl
select	cpnl.link_id, cpnl.source_deal_header_id, cpnl.as_of_date,
		cpnl.und_PNL - CASE WHEN ((link_effective_date <= cpnl.as_of_date) OR (header_link_effective_date = detail_link_effective_date)) THEN isnull(epnl.und_PNL, 0) ELSE 0 END und_PNL, 
		cpnl.und_rel_PNL - CASE WHEN ((link_effective_date <= cpnl.as_of_date) OR (header_link_effective_date = detail_link_effective_date)) THEN isnull(epnl.und_rel_PNL, 0) ELSE 0 END und_rel_PNL, 
		cpnl.dis_rel_PNL - CASE WHEN ((link_effective_date <= cpnl.as_of_date) OR (header_link_effective_date = detail_link_effective_date)) THEN isnull(epnl.dis_rel_PNL, 0) ELSE 0 END dis_rel_PNL, 
		cpnl.hedge_or_item
from	#cum_pnl cpnl LEFT OUTER JOIN
		#eff_pnl epnl ON epnl.link_id = cpnl.link_id AND epnl.source_deal_header_id = cpnl.source_deal_header_id
ORDER BY cpnl.as_of_date, cpnl.link_id, cpnl.source_deal_header_id

DELETE	cum_pnl_series 
FROM	cum_pnl_series c INNER JOIN
		#pnl p ON p.link_id = c.link_id AND
				  p.as_of_date = c.as_of_date 
	

INSERT INTO cum_pnl_series  ([as_of_date],[link_id],[u_h_mtm],[u_i_mtm],[d_h_mtm],[d_i_mtm],[create_user],[create_ts])
SELECT	coalesce(h.as_of_date, i.as_of_date) as_of_date, coalesce(h.link_id, i.link_id) link_id, 
		h.mtm u_h_mtm, i.mtm u_i_mtm, 
		h.dmtm d_h_mtm, i.dmtm d_i_mtm, 
		dbo.FNADBUser() create_user, getdate() create_ts
from 
(select as_of_date, link_id, sum(und_rel_PNL) mtm, sum(dis_rel_PNL) dmtm from #pnl where hedge_or_item = 'h' group by as_of_date, link_id) h FULL OUTER JOIN
(select as_of_date, link_id, sum(und_rel_PNL) mtm, sum(dis_rel_PNL) dmtm from #pnl where hedge_or_item = 'i' group by as_of_date, link_id) i ON
	h.as_of_date = i.as_of_date
--AND
WHERE h.mtm IS NOT NULL AND i.mtm IS NOT NULL AND h.mtm <> 0 AND i.mtm <> 0

SELECT	dbo.FNADateFormat(coalesce(h.as_of_date, i.as_of_date)) [As of Date], 
		coalesce(h.link_id, i.link_id) [Hedge Rel ID], 
		h.mtm [Hedge MTM], i.mtm [Item MTM], h.dmtm [Hedge DIS_MTM], i.dmtm [Item DIS_MTM]
from 
(select as_of_date, link_id, sum(und_rel_PNL) mtm, sum(dis_rel_PNL) dmtm from #pnl where hedge_or_item = 'h' group by as_of_date, link_id) h FULL OUTER JOIN
(select as_of_date, link_id, sum(und_rel_PNL) mtm, sum(dis_rel_PNL) dmtm from #pnl where hedge_or_item = 'i' group by as_of_date, link_id) i ON
	h.as_of_date = i.as_of_date
--AND
WHERE h.mtm IS NOT NULL AND i.mtm IS NOT NULL AND h.mtm <> 0 AND i.mtm <> 0
ORDER BY coalesce(h.as_of_date, i.as_of_date), coalesce(h.link_id, i.link_id) 


