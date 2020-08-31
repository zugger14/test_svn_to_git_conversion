IF OBJECT_ID('dbo.spa_calc_Credit_Risks') IS NOT NULL
DROP PROC dbo.spa_calc_Credit_Risks

GO

CREATE PROC dbo.spa_calc_Credit_Risks @as_of_date DATETIME
as

if  object_id('tempdb..#temp_leg_mtm') IS NOT NULL
BEGIN

	update #temp_leg_mtm SET map_months=dbo.FNAGetMapMonthNo(curve_id, term_start,@as_of_date)
	
	--calcculate adjustment value for  hedge deal
	update #temp_leg_mtm SET adjustment_value=ABS([leg_mtm]*dbo.FNAGetProbabilityDefault(SC.debt_rating,map_months,@as_of_date)  *(1-dbo.FNAGetRecoveryRate(debt_rating, map_months,@as_of_date))) * -1
--	SELECT sbm.book_deal_type_map_id,SC.debt_rating,map_months,[leg_mtm],dbo.FNAGetProbabilityDefault(SC.debt_rating,map_months,'2009-11-30') ProbabilityDefault ,dbo.FNAGetRecoveryRate(debt_rating, map_months,'2009-11-30') RecoveryRate, ABS([leg_mtm]*dbo.FNAGetRecoveryRate(SC.debt_rating,map_months,'2009-11-30')  *(1-dbo.FNAGetRecoveryRate(debt_rating, map_months,'2009-11-30'))) * -1,*
		FROM #temp_leg_mtm t INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=t.source_deal_header_id
		INNER JOIN
			   source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
			   sdh.source_system_book_id2 = sbm.source_system_book_id2 AND sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
			   sdh.source_system_book_id4 = sbm.source_system_book_id4 AND sbm.fas_deal_type_value_id=400
	   INNER JOIN
           portfolio_hierarchy book ON sbm.fas_book_id = book.entity_id 
       INNER JOIN
           portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id 
       INNER JOIN
           fas_subsidiaries sub1 ON stra.parent_entity_id = sub1.fas_subsidiary_id 
       INNER JOIN (
       	SELECT source_deal_header_id, sum([leg_mtm]) sum_mtm FROM #temp_leg_mtm 
       	GROUP BY source_deal_header_id
       ) pnl ON pnl.source_deal_header_id=t.source_deal_header_id
		LEFT JOIN counterparty_credit_info sc ON sc.counterparty_id = 
			case when 
				pnl.sum_mtm<0 
				then sub1.counterparty_id 
				else sdh.counterparty_id 
			END 
					
					
	--calcculate adjustment value for  hedge item deal
	
	select fld.source_deal_header_id,max(cva) cva,max(fld.link_id) link_id 
	into 
		#deal_link_cva
	from 
			#temp_leg_mtm t inner join fas_link_detail fld ON fld.source_deal_header_id=t.source_deal_header_id AND fld.hedge_or_item='i'
	CROSS APPLY
	( --Taking sum CVA, if the same item deal is existed in multiple links
		select max(cva) cva FROM fas_link_detail fld 
		INNER JOIN 
		(	--link level CVA of hedge deal
			SELECT link_i.link_id,cva_link.cva
				FROM 
				( select fld.link_id from #temp_leg_mtm t INNER JOIN
					fas_link_detail fld ON fld.source_deal_header_id=t.source_deal_header_id AND fld.hedge_or_item='i'
				  GROUP BY fld.link_id
				) link_i
			CROSS APPLY 
			(  
				SELECT  SUM(adjustment_value) cva from fas_link_detail link_h  
				INNER JOIN #temp_leg_mtm t1 ON  t1.source_deal_header_id=link_h.source_deal_header_id 
					and link_h.LINK_ID=link_i.LINK_ID 
					AND link_h.hedge_or_item='h'
			 ) cva_link --where link_i.link_id=64
		) link_cva 
		ON fld.link_id=link_cva.link_id  
		where 
		fld.source_deal_header_id=t.source_deal_header_id 
				AND fld.hedge_or_item='i'
	) cva_deal 
	--where t.source_deal_header_id=394
	  group by fld.source_deal_header_id
	
	
	
	select t.id,t.source_deal_header_id,deal_cva.cva * ABS(cast(volume AS FLOAT)/nullif(cast(SUM(volume) over (PARTITION BY deal_cva.LINK_ID) AS FLOAT),0)) adjustment_value
	INTO #tmp_adjustment_value_item
--	select deal_cva.LINK_ID,t.id,t.source_deal_header_id,deal_cva.cva ,volume,SUM(volume) over (PARTITION BY deal_cva.LINK_ID) sum_vol ,deal_cva.cva * ABS(cast(volume AS FLOAT)/nullif(cast(SUM(volume) over (PARTITION BY deal_cva.LINK_ID) AS FLOAT),0)) adjustment_value
	 FROM #temp_leg_mtm t 
		INNER JOIN #deal_link_cva deal_cva on t.source_deal_header_id=deal_cva.source_deal_header_id
	inner join (
		select source_deal_header_id, term_start, term_end from #temp_leg_mtm
			group by source_deal_header_id, term_start, term_end 
			having sum(leg_mtm) IS NOT NULL
	) nonnull ON	nonnull.source_deal_header_id=t.source_deal_header_id
		and nonnull.term_start=t.term_start AND  nonnull.term_end=t.term_end
	
			
	update #temp_leg_mtm SET  adjustment_value=a.adjustment_value FROM #temp_leg_mtm t INNER join #tmp_adjustment_value_item a 
	ON a.id=t.id

			  
END
