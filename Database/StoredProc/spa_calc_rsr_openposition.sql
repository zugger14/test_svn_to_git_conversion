IF OBJECT_ID(N'dbo.spa_calc_rsr_openposition', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_calc_rsr_openposition]
GO 

CREATE PROCEDURE [dbo].[spa_calc_rsr_openposition]
	@as_of_date DATETIME, --'2012-05-31'
	@line_item INT = 1, -- 1:rsr , 2: open position
	@counterparty_id INT = NULL,
	@book_ids VARCHAR(MAX) = NULL,
	@tou INT = NULL,
	@gran CHAR(1) = 'm' -- m or h
AS

/*
declare 	@as_of_date DATETIME = '2012-02-29',
	@line_item INT = 1, -- 1:rsr , 2: open position
	@counterparty_id INT = NULL,
	@book_ids VARCHAR(1000) = NULL,
	@tou INT = NULL,
	@gran CHAR(1) = 'h'
*/	

-- get position of next month
--DECLARE @as_of_date VARCHAR(25) = '2012-05-31'

IF object_id('tempdb..#udt') is not null
drop table #udt
IF object_id('tempdb..#avg_pos') is not null
drop table #avg_pos
IF object_id('tempdb..#open_position') is not null
drop table #open_position
IF object_id('tempdb..#book') is not null
drop table #book
IF object_id('tempdb..#fx_curve_spot') is not null
drop table #fx_curve_spot


--select * from open_position order by term_start, Hr

--select spcd.udf_block_group_id,o.* from open_position o 
--left join source_price_curve_def spcd on spcd.source_curve_def_id = o.curve_id



------ udf
create table #udt(udf_block_group_id  int,block_id int, term_start date, Hr tinyint,counterparty_id INT,book_id INT)

INSERT INTO #udt(udf_block_group_id,block_id,term_start,Hr,counterparty_id,book_id)
select distinct upv.udf_block_group_id ,upv.hourly_block_id, upv.term_start,cast(substring(upv.hr,3,2) AS INT) Hr,counterparty_id,book_id
from (
select p.udf_block_group_id,p.hourly_block_id ,p.term_start ,
	hb.hr1,hb.hr2,hb.hr3,hb.hr4,hb.hr5,hb.hr6,hb.hr7,hb.hr8,hb.hr9,hb.hr10,hb.hr11,hb.hr12,hb.hr13,hb.hr14,hb.hr15,hb.hr16
	,hb.hr17,hb.hr18,hb.hr19,hb.hr20,hb.hr21,hb.hr22,hb.hr23,hb.hr24,counterparty_id,book_id
 from (
		select distinct grp.id udf_block_group_id,spcd.udf_block_group_id block_id, a.term_start term_start,hourly_block_id,counterparty_id,book_id
		 from open_position a  
		 LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = a.curve_id -- to do..
		inner join block_type_group grp ON spcd.udf_block_group_id=grp.block_type_group_id 
		and spcd.udf_block_group_id is NOT NULL AND a.as_of_date = @as_of_date
			
	) p
	inner join  hour_block_term hb  ON hb.block_define_id=p.hourly_block_id and isnull(hb.block_type,12000)=12000
			and p.term_start=hb.term_date
		
) s
	UNPIVOT
	(on_off for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)	
) upv	
where on_off=1



SELECT ISNULL(t.block_id, 292037) block_id, t.udf_block_group_id,
f.source_deal_header_id,f.counterparty_id,f.curve_id,f.term_start,f.Hr,f.deal_volume_uom_id,f.formula_breakdown,f.book_id, f.position, f.maturity_hr, f.maturity_mnth,f.maturity_qtr,f.maturity_semi,f.maturity_yr,
f.commodity_id, f.dst, f.source_system_book_id1, f.source_system_book_id2, f.source_system_book_id3, f.source_system_book_id4, f.location_id
INTO #open_position
FROM open_position f 
--LEFT JOIN source_price_curve_def spcd on spcd.source_curve_def_id = f.curve_id
LEFT JOIN #udt t on  f.term_start=t.term_start and f.hr=t.hr  --and spcd.udf_block_group_id =t.block_id 
	AND f.counterparty_id=t.counterparty_id 
	AND f.book_id=t.book_id 
WHERE f.as_of_date = @as_of_date




CREATE TABLE #avg_pos ( book_id INT, user_toublock_id INT, counterparty_id INT, position_avg NUMERIC(26,10) )
 

--SELECT f.book_id, f.block_id, f.counterparty_id, AVG(f.position)
--FROM #open_position f
--GROUP BY  f.book_id, f.block_id, f.counterparty_id
--order by f.book_id, f.block_id, f.counterparty_id


INSERT INTO #avg_pos ( book_id, user_toublock_id, counterparty_id, position_avg )
SELECT f.book_id, f.block_id, f.counterparty_id, AVG(f.position)
FROM #open_position f
GROUP BY  f.book_id, f.block_id, f.counterparty_id
--select * from #avg_pos


DECLARE @sql1 VARCHAR(MAX)
DECLARE @next_month_start DATETIME = CAST(CONVERT(CHAR(7), DATEADD(m,1,@as_of_date), 126) + '-01' AS DATETIME)
DECLARE @sub VARCHAR(1000) = NULL, @str VARCHAR(1000) = NULL,@book VARCHAR(1000) = null
DECLARE @curve_source_id INT=4500
CREATE TABLE #book (book_id int,book_deal_type_map_id int,source_system_book_id1 int,source_system_book_id2 int,source_system_book_id3 int,source_system_book_id4 int,func_cur_id INT)		
	
SET @sql1 = 'INSERT INTO #book (book_id,book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4,func_cur_id )		
	SELECT book.entity_id, book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,fs.func_cur_value_id
	FROM source_system_book_map sbm            
		INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
		INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
		INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
		left join fas_subsidiaries fs on sb.entity_id=fs.fas_subsidiary_id
	WHERE 1=1  '
		+CASE WHEN  @sub IS NULL THEN '' ELSE ' and sb.entity_id in ('+@sub+')' END
		+CASE WHEN  @str IS NULL THEN '' ELSE ' and stra.entity_id in ('+@str+')' END
		+CASE WHEN  @book IS NULL THEN '' ELSE ' and book.entity_id in ('+@book+')' END		
		
EXEC(@sql1)


--select * from #open_position

DECLARE @fx_sql VARCHAR(5000)
CREATE TABLE #fx_curve_spot (curve_value FLOAT, source_curve_def_id INT, curve_source_value_id INT, source_currency_to_id INT,
source_currency_id INT, fx_maturity_yr INT, fx_maturity_mn INT)

SET @fx_sql = '
INSERT INTO  #fx_curve_spot(curve_value, source_curve_def_id, curve_source_value_id, source_currency_to_id,
source_currency_id, fx_maturity_yr, fx_maturity_mn)

SELECT AVG(spc_sp.curve_value) fx_mon_avg_value, spc_sp_max_aod.source_curve_def_id,
				spc_sp.curve_source_value_id, spc_sp_max_aod.source_currency_to_id,spc_sp_max_aod.source_currency_id,
			YEAR(spc_sp_max_aod.maturity_date) fx_maturity_year, MONTH(spc_sp_max_aod.maturity_date) fx_maturity_month
			  FROM source_price_curve spc_sp
	   INNER JOIN
	   (
		   SELECT MAX(s.as_of_date) max_as_of_date, s.maturity_date, d.source_currency_to_id , d.source_currency_id, s.source_curve_def_id
		   FROM source_price_curve s
		   INNER JOIN source_price_curve_def d ON d.source_curve_def_id = s.source_curve_def_id 
		   AND d.source_curve_type_value_id = 576 AND d.Granularity = 981
		   INNER JOIN #open_position o ON o.term_start = s.maturity_date
					   
		   GROUP BY s.source_curve_def_id, s.maturity_date, d.source_currency_to_id, d.source_currency_id
	       
	   ) spc_sp_max_aod ON spc_sp.as_of_date = spc_sp_max_aod.max_as_of_date
		   AND spc_sp.source_curve_def_id = spc_sp_max_aod.source_curve_def_id
		   AND spc_sp.maturity_date = spc_sp_max_aod.maturity_date
	       
	   GROUP BY spc_sp_max_aod.source_curve_def_id,spc_sp.curve_source_value_id,spc_sp_max_aod.source_currency_to_id, spc_sp_max_aod.source_currency_id,YEAR(spc_sp_max_aod.maturity_date), MONTH(spc_sp_max_aod.maturity_date)
'
EXEC(@fx_sql)

IF @gran = 'm'
BEGIN
	EXEC spa_print 'monthly aggregated'
	SET @sql1 = '
	SELECT 
	' + CASE @line_item WHEN 1 THEN '20301' WHEN 2 THEN '20302' END + ' item_type
	,'''+ CONVERT(VARCHAR(10),@as_of_date, 126) +''' as_of_date
	,'''+CAST(@next_month_start AS VARCHAR)+'''  term
	,f.book_id,f.counterparty_id,f.block_id
	' +CASE WHEN @line_item = 1 THEN '
	,''Residual Shaped Risk'' line_item
	,SUM((f.position - a.position_avg) * (
	( spc1.curve_value * ISNULL(sc_v1.factor,1) 
					* CAST(ISNULL(conv_v1.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v2.curve_value,(1/nullif(fx_fnuc_v3.curve_value,0)),1)/cast(ISNULL(conv_price1.conversion_factor,1) as numeric(21,16)) )
	-
	( spc.curve_value * ISNULL(sc_v.factor,1) 
					* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v.curve_value,(1/nullif(fx_fnuc_v1.curve_value,0)),1)/cast(ISNULL(conv_price.conversion_factor,1) as numeric(21,16)) ) )) rsr'
			WHEN @line_item = 2 THEN '
	,''Open Position Risk'' line_item
	,SUM((a.position_avg) * ( ( spc1.curve_value * ISNULL(sc_v1.factor,1) 
					* CAST(ISNULL(conv_v1.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v2.curve_value,(1/nullif(fx_fnuc_v3.curve_value,0)),1)/cast(ISNULL(conv_price1.conversion_factor,1) as numeric(21,16)) )
	-
	( spc.curve_value * ISNULL(sc_v.factor,1) 
					* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v.curve_value,(1/nullif(fx_fnuc_v1.curve_value,0)),1)/cast(ISNULL(conv_price.conversion_factor,1) as numeric(21,16)) ) )) open_pos'
	   ELSE '' END + ', ''' 
	+ (CASE @line_item WHEN 1 THEN 'Residual Shaped Risk' WHEN 2 THEN 'Open Position Risk' ELSE '' END) + ''' line_item_type 
	FROM #open_position f
	LEFT JOIN (select distinct book_id, func_cur_id from  #book) b on f.book_id=b.book_id
	INNER JOIN #avg_pos a ON a.book_id = f.book_id AND a.counterparty_id = f.counterparty_id AND a.user_toublock_id = f.block_id
	LEFT JOIN source_minor_location sml on sml.source_minor_location_id = f.location_id
	LEFT JOIN valuation_curve_mapping vcm ON ISNULL(ISNULL(vcm.country,sml.country), -1) = ISNULL(sml.country, -1)
		AND ISNULL(ISNULL(vcm.grid,sml.grid_value_id), -1) = ISNULL(sml.grid_value_id, -1)
		AND	ISNULL(ISNULL(vcm.region,sml.region), -1) = ISNULL(sml.region, -1) 
		AND	ISNULL(vcm.book_id,f.book_id) = f.book_id 
		AND	ISNULL(vcm.commodity_id,f.commodity_id) = f.commodity_id
	
	--forward
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = vcm.forward_curve
	LEFT JOIN source_currency sc_v on spcd.source_currency_id=sc_v.source_currency_id AND sc_v.currency_id_to IS NOT NULL
	LEFT JOIN source_price_curve_def fx_v on fx_v.source_currency_id = ISNULL(sc_v.currency_id_to,spcd.source_currency_id) and fx_v.source_currency_to_id=b.func_cur_id and fx_v.Granularity=980
	LEFT JOIN source_price_curve fx_fnuc_v ON fx_v.source_curve_def_id=fx_fnuc_v.source_curve_def_id
	AND fx_fnuc_v.curve_Source_value_id='+cast(@curve_source_id as varchar)+'	AND fx_fnuc_v.as_of_date = '''+convert(varchar(10),@as_of_date,120)+'''
	and fx_fnuc_v.maturity_date= f.maturity_mnth
	LEFT JOIN source_price_curve_def fx_v1 on fx_v1.source_currency_id =b.func_cur_id and fx_v1.source_currency_to_id= isnull(sc_v.currency_id_to,spcd.source_currency_id) and fx_v1.Granularity=980
	LEFT JOIN source_price_curve fx_fnuc_v1 ON fx_v1.source_curve_def_id=fx_fnuc_v1.source_curve_def_id
	AND fx_fnuc_v1.curve_Source_value_id='+cast(@curve_source_id as varchar)+'	AND fx_fnuc_v1.as_of_date = '''+convert(varchar(10),@as_of_date,120)+'''
	and fx_fnuc_v1.maturity_date=f.maturity_mnth
	LEFT JOIN rec_volume_unit_conversion conv_v (nolock) ON conv_v.from_source_uom_id = f.deal_volume_uom_id
		AND conv_v.to_source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)
	LEFT JOIN rec_volume_unit_conversion conv_price (nolock) ON conv_price.from_source_uom_id = spcd.uom_id
		AND conv_price.to_source_uom_id = ISNULL(spcd.display_uom_id,spcd.uom_id)
	LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id 
		AND YEAR(spc.maturity_date) = YEAR(f.term_start) 
		AND	MONTH(spc.maturity_date) = MONTH(f.term_start) 
		AND	CASE WHEN spcd.granularity IN(981,982) THEN DAY(spc.maturity_date) ELSE -1 END = CASE WHEN spcd.granularity IN(981,982) THEN DAY(f.term_start) ELSE -1 END 
		AND	CASE WHEN spcd.granularity = 982 THEN spc.maturity_date ELSE -1 END = CASE WHEN spcd.granularity = 982 THEN f.maturity_hr ELSE -1 END 
		AND	spc.as_of_date = ''' + CONVERT(VARCHAR(10),@as_of_date, 126) +'''

	--settle
	LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = vcm.spot_price_curve
	LEFT JOIN rec_volume_unit_conversion conv_v1 (nolock) ON conv_v1.from_source_uom_id = f.deal_volume_uom_id
		AND conv_v1.to_source_uom_id = ISNULL(spcd1.display_uom_id, spcd1.uom_id)
	LEFT JOIN rec_volume_unit_conversion conv_price1 (nolock) ON conv_price1.from_source_uom_id = spcd1.uom_id
		AND conv_price1.to_source_uom_id = ISNULL(spcd1.display_uom_id,spcd1.uom_id)
	OUTER APPLY (SELECT MAX(as_of_date) as_of_date FROM source_price_curve s WHERE 
		s.source_curve_def_id = vcm.spot_price_curve 
		AND YEAR(s.maturity_date) = YEAR(f.maturity_hr) 
		AND	MONTH(s.maturity_date) = MONTH(f.maturity_hr) 
		AND	CASE WHEN spcd1.granularity IN(981,982) THEN DAY(s.maturity_date) ELSE -1 END = CASE WHEN spcd1.granularity IN(981,982) THEN DAY(f.maturity_hr) ELSE -1 END 
		AND	CASE WHEN spcd1.granularity = 982 THEN s.maturity_date ELSE -1 END = CASE WHEN spcd1.granularity = 982 THEN f.maturity_hr ELSE -1 END 
		) p
	LEFT JOIN source_price_curve spc1 ON spc1.source_curve_def_id = spcd1.source_curve_def_id 
		AND YEAR(spc1.maturity_date) = YEAR(f.term_start) 
		AND	MONTH(spc1.maturity_date) = MONTH(f.term_start) 
		AND	CASE WHEN spcd1.granularity IN(981,982) THEN DAY(spc1.maturity_date) ELSE -1 END = CASE WHEN spcd1.granularity IN(981,982) THEN DAY(f.term_start) ELSE -1 END 
		AND	CASE WHEN spcd1.granularity = 982 THEN spc1.maturity_date ELSE -1 END = CASE WHEN spcd1.granularity = 982 THEN f.maturity_hr ELSE -1 END 
		AND spc1.as_of_date = p.as_of_date	
	LEFT JOIN source_currency sc_v1 on spcd1.source_currency_id=sc_v1.source_currency_id AND sc_v1.currency_id_to IS NOT NULL
	
	-- fx curve	
	LEFT JOIN #fx_curve_spot fx_fnuc_v2 ON fx_fnuc_v2.curve_Source_value_id = ' + CAST(@curve_source_id as varchar) + ' 
		AND fx_fnuc_v2.source_currency_id = ISNULL(sc_v1.currency_id_to,spcd1.source_currency_id) 
		AND fx_fnuc_v2.source_currency_to_id=b.func_cur_id 
		AND fx_fnuc_v2.fx_maturity_yr = YEAR(f.term_start) AND fx_fnuc_v2.fx_maturity_mn = MONTH(f.term_start)  

	LEFT JOIN #fx_curve_spot fx_fnuc_v3 ON fx_fnuc_v3.curve_Source_value_id = ' + CAST(@curve_source_id as varchar) + ' 
		AND fx_fnuc_v3.source_currency_id = b.func_cur_id 
		AND fx_fnuc_v3.source_currency_to_id = ISNULL(sc_v1.currency_id_to,spcd1.source_currency_id)
		AND fx_fnuc_v3.fx_maturity_yr = YEAR(f.term_start) AND fx_fnuc_v3.fx_maturity_mn = MONTH(f.term_start)  

	WHERE 1 = 1  '
	+CASE WHEN @counterparty_id IS NOT NULL THEN ' AND f.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(10)) ELSE '' END+
	+CASE WHEN @book_ids IS NOT NULL THEN ' AND f.book_id IN (' + @book_ids + ')'  ELSE '' END+
	+CASE WHEN @tou IS NOT NULL THEN ' AND f.block_id = ' + CAST(@tou AS VARCHAR(10)) ELSE '' END+

	' 
	GROUP BY f.book_id,f.counterparty_id,f.block_id
	ORDER BY f.book_id, f.block_id, f.counterparty_id	'

END

IF @gran = 'h'
BEGIN
	EXEC spa_print 'hourly level'
	
	SET @sql1 = '
	SELECT 
	'''+CAST(@next_month_start AS VARCHAR)+'''  term
	,f.book_id,f.counterparty_id,f.block_id,
	sml.country, sml.grid_value_id, sml.region, f.curve_id,
	f.maturity_hr, f.maturity_mnth,f.maturity_qtr,f.maturity_semi,f.maturity_yr,
	f.commodity_id, f.dst, f.source_system_book_id1, f.source_system_book_id2, f.source_system_book_id3, f.source_system_book_id4,f.location_id,
	f.term_start,f.Hr,f.deal_volume_uom_id,f.formula_breakdown,
	f.position,a.position_avg,(f.position - a.position_avg) pos_difference,
	spc.curve_value fc_beforeconvert,
	spc.curve_value * ISNULL(sc_v.factor,1) 
					* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v.curve_value,(1/nullif(fx_fnuc_v1.curve_value,0)),1)/cast(ISNULL(conv_price.conversion_factor,1) as numeric(21,16)) fc,

	spc1.curve_value sp_beforeconvert,
	spc1.curve_value * ISNULL(sc_v1.factor,1) 
					* CAST(ISNULL(conv_v1.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v2.curve_value,(1/nullif(fx_fnuc_v3.curve_value,0)),1)/cast(ISNULL(conv_price1.conversion_factor,1) as numeric(21,16)) sp,

	( spc1.curve_value * ISNULL(sc_v1.factor,1) 
					* CAST(ISNULL(conv_v1.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v2.curve_value,(1/nullif(fx_fnuc_v3.curve_value,0)),1)/cast(ISNULL(conv_price1.conversion_factor,1) as numeric(21,16)) )
	-
	( spc.curve_value * ISNULL(sc_v.factor,1) 
					* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v.curve_value,(1/nullif(fx_fnuc_v1.curve_value,0)),1)/cast(ISNULL(conv_price.conversion_factor,1) as numeric(21,16)) )
	sp_fc	

	' +CASE WHEN @line_item = 1 THEN '
	,''Residual Shaped Risk'' line_item
	,(f.position - a.position_avg) * (spc1.curve_value-spc.curve_value) rsr_old
	,(f.position - a.position_avg) * 
	( ( spc1.curve_value * ISNULL(sc_v1.factor,1) 
					* CAST(ISNULL(conv_v1.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v2.curve_value,(1/nullif(fx_fnuc_v3.curve_value,0)),1)/cast(ISNULL(conv_price1.conversion_factor,1) as numeric(21,16)) )
	-
	( spc.curve_value * ISNULL(sc_v.factor,1) 
					* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v.curve_value,(1/nullif(fx_fnuc_v1.curve_value,0)),1)/cast(ISNULL(conv_price.conversion_factor,1) as numeric(21,16)) ) ) rsr'
			WHEN @line_item = 2 THEN '
	,''Open Position Risk'' line_item
	,(a.position_avg) * (spc1.curve_value-spc.curve_value) open_pos_old
	,(a.position_avg) * ( ( spc1.curve_value * ISNULL(sc_v1.factor,1) 
					* CAST(ISNULL(conv_v1.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v2.curve_value,(1/nullif(fx_fnuc_v3.curve_value,0)),1)/cast(ISNULL(conv_price1.conversion_factor,1) as numeric(21,16)) )
	-
	( spc.curve_value * ISNULL(sc_v.factor,1) 
					* CAST(ISNULL(conv_v.conversion_factor,1) AS NUMERIC(21,16)) 
					* COALESCE(fx_fnuc_v.curve_value,(1/nullif(fx_fnuc_v1.curve_value,0)),1)/cast(ISNULL(conv_price.conversion_factor,1) as numeric(21,16)) ) ) open_pos'
	   ELSE '' END + ', ''' 
	+ (CASE @line_item WHEN 1 THEN 'Residual Shaped Risk' WHEN 2 THEN 'Open Position Risk' ELSE '' END) + ''' line_item_type 
	FROM #open_position f
	LEFT JOIN (select distinct book_id, func_cur_id from  #book) b on f.book_id=b.book_id
	INNER JOIN #avg_pos a ON a.book_id = f.book_id AND a.counterparty_id = f.counterparty_id AND a.user_toublock_id = f.block_id
	LEFT JOIN source_minor_location sml on sml.source_minor_location_id = f.location_id
	LEFT JOIN valuation_curve_mapping vcm ON ISNULL(ISNULL(vcm.country,sml.country), -1) = ISNULL(sml.country, -1)
		AND ISNULL(ISNULL(vcm.grid,sml.grid_value_id), -1) = ISNULL(sml.grid_value_id, -1)
		AND	ISNULL(ISNULL(vcm.region,sml.region), -1) = ISNULL(sml.region, -1) 
		AND	ISNULL(vcm.book_id,f.book_id) = f.book_id 
		AND	ISNULL(vcm.commodity_id,f.commodity_id) = f.commodity_id
	
	--forward
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = vcm.forward_curve
	LEFT JOIN source_currency sc_v on spcd.source_currency_id=sc_v.source_currency_id AND sc_v.currency_id_to IS NOT NULL
	LEFT JOIN source_price_curve_def fx_v on fx_v.source_currency_id = ISNULL(sc_v.currency_id_to,spcd.source_currency_id) and fx_v.source_currency_to_id=b.func_cur_id and fx_v.Granularity=980
	LEFT JOIN source_price_curve fx_fnuc_v ON fx_v.source_curve_def_id=fx_fnuc_v.source_curve_def_id
	AND fx_fnuc_v.curve_Source_value_id='+cast(@curve_source_id as varchar)+'	AND fx_fnuc_v.as_of_date = '''+convert(varchar(10),@as_of_date,120)+'''
	and fx_fnuc_v.maturity_date= f.maturity_mnth
	LEFT JOIN source_price_curve_def fx_v1 on fx_v1.source_currency_id =b.func_cur_id and fx_v1.source_currency_to_id= isnull(sc_v.currency_id_to,spcd.source_currency_id) and fx_v1.Granularity=980
	LEFT JOIN source_price_curve fx_fnuc_v1 ON fx_v1.source_curve_def_id=fx_fnuc_v1.source_curve_def_id
	AND fx_fnuc_v1.curve_Source_value_id='+cast(@curve_source_id as varchar)+'	AND fx_fnuc_v1.as_of_date = '''+convert(varchar(10),@as_of_date,120)+'''
	and fx_fnuc_v1.maturity_date=f.maturity_mnth
	LEFT JOIN rec_volume_unit_conversion conv_v (nolock) ON conv_v.from_source_uom_id = f.deal_volume_uom_id
		AND conv_v.to_source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)
	LEFT JOIN rec_volume_unit_conversion conv_price (nolock) ON conv_price.from_source_uom_id = spcd.uom_id
		AND conv_price.to_source_uom_id = ISNULL(spcd.display_uom_id,spcd.uom_id)
	LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id 
		AND YEAR(spc.maturity_date) = YEAR(f.term_start) 
		AND	MONTH(spc.maturity_date) = MONTH(f.term_start) 
		AND	CASE WHEN spcd.granularity IN(981,982) THEN DAY(spc.maturity_date) ELSE -1 END = CASE WHEN spcd.granularity IN(981,982) THEN DAY(f.term_start) ELSE -1 END 
		AND	CASE WHEN spcd.granularity = 982 THEN spc.maturity_date ELSE -1 END = CASE WHEN spcd.granularity = 982 THEN f.maturity_hr ELSE -1 END 
		AND	spc.as_of_date = ''' + CONVERT(VARCHAR(10),@as_of_date, 126) +'''

	--settle
	LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = vcm.spot_price_curve
	LEFT JOIN rec_volume_unit_conversion conv_v1 (nolock) ON conv_v1.from_source_uom_id = f.deal_volume_uom_id
		AND conv_v1.to_source_uom_id = ISNULL(spcd1.display_uom_id, spcd1.uom_id)
	LEFT JOIN rec_volume_unit_conversion conv_price1 (nolock) ON conv_price1.from_source_uom_id = spcd1.uom_id
		AND conv_price1.to_source_uom_id = ISNULL(spcd1.display_uom_id,spcd1.uom_id)
	OUTER APPLY (SELECT MAX(as_of_date) as_of_date FROM source_price_curve s WHERE 
		s.source_curve_def_id = vcm.spot_price_curve 
		AND YEAR(s.maturity_date) = YEAR(f.maturity_hr) 
		AND	MONTH(s.maturity_date) = MONTH(f.maturity_hr) 
		AND	CASE WHEN spcd1.granularity IN(981,982) THEN DAY(s.maturity_date) ELSE -1 END = CASE WHEN spcd1.granularity IN(981,982) THEN DAY(f.maturity_hr) ELSE -1 END 
		AND	CASE WHEN spcd1.granularity = 982 THEN s.maturity_date ELSE -1 END = CASE WHEN spcd1.granularity = 982 THEN f.maturity_hr ELSE -1 END 
		) p
	LEFT JOIN source_price_curve spc1 ON spc1.source_curve_def_id = spcd1.source_curve_def_id 
		AND YEAR(spc1.maturity_date) = YEAR(f.term_start) 
		AND	MONTH(spc1.maturity_date) = MONTH(f.term_start) 
		AND	CASE WHEN spcd1.granularity IN(981,982) THEN DAY(spc1.maturity_date) ELSE -1 END = CASE WHEN spcd1.granularity IN(981,982) THEN DAY(f.term_start) ELSE -1 END 
		AND	CASE WHEN spcd1.granularity = 982 THEN spc1.maturity_date ELSE -1 END = CASE WHEN spcd1.granularity = 982 THEN f.maturity_hr ELSE -1 END 
		AND spc1.as_of_date = p.as_of_date	
	LEFT JOIN source_currency sc_v1 on spcd1.source_currency_id=sc_v1.source_currency_id AND sc_v1.currency_id_to IS NOT NULL
	
	-- fx curve	
	LEFT JOIN #fx_curve_spot fx_fnuc_v2 ON fx_fnuc_v2.curve_Source_value_id = ' + CAST(@curve_source_id as varchar) + ' 
		AND fx_fnuc_v2.source_currency_id = ISNULL(sc_v1.currency_id_to,spcd1.source_currency_id) 
		AND fx_fnuc_v2.source_currency_to_id=b.func_cur_id 
		AND fx_fnuc_v2.fx_maturity_yr = YEAR(f.term_start) AND fx_fnuc_v2.fx_maturity_mn = MONTH(f.term_start)  

	LEFT JOIN #fx_curve_spot fx_fnuc_v3 ON fx_fnuc_v3.curve_Source_value_id = ' + CAST(@curve_source_id as varchar) + ' 
		AND fx_fnuc_v3.source_currency_id = b.func_cur_id 
		AND fx_fnuc_v3.source_currency_to_id = ISNULL(sc_v1.currency_id_to,spcd1.source_currency_id)
		AND fx_fnuc_v3.fx_maturity_yr = YEAR(f.term_start) AND fx_fnuc_v3.fx_maturity_mn = MONTH(f.term_start)  

	WHERE 1 = 1  '
	+CASE WHEN @counterparty_id IS NOT NULL THEN ' AND f.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(10)) ELSE '' END+
	+CASE WHEN @book_ids IS NOT NULL THEN ' AND f.book_id IN (' + @book_ids + ')'  ELSE '' END+
	+CASE WHEN @tou IS NOT NULL THEN ' AND f.block_id = ' + CAST(@tou AS VARCHAR(10)) ELSE '' END+

	' 
	--GROUP BY f.book_id,f.counterparty_id,f.block_id
	order by f.book_id, f.block_id, f.counterparty_id
	'

END

exec spa_print @sql1
EXEC (@sql1)
