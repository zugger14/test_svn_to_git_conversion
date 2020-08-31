IF OBJECT_ID(N'[dbo].[spa_get_assmt_rel_type_detail]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_assmt_rel_type_detail]
GO 

-- EXEC spa_get_assmt_rel_type_detail 1, 509, 75, 'h', 375, '2004-03-31'
-- EXEC spa_get_assmt_rel_type_detail 1, 509, 75, 'i', 375, '2004-03-31'
-- EXEC spa_get_assmt_rel_type_detail 2, 509, NULL, 'h', 375, '2004-03-31'
-- EXEC spa_get_assmt_rel_type_detail 2, 509, NULL, 'i', 375, '2004-03-31'
-- EXEC spa_get_assmt_rel_type_detail 2, -216, NULL, 'h', 375, '2004-03-31'  --book
-- EXEC spa_get_assmt_rel_type_detail 2, -216, NULL, 'i', 375, '2004-03-31'  --book
-- EXEC spa_get_assmt_rel_type_detail 2, -228, NULL, 'h', 375, '2004-03-31'  --strategy
-- EXEC spa_get_assmt_rel_type_detail 2, -228, NULL, 'i', 375, '2004-03-31'  --strategy

-- 
CREATE PROCEDURE [dbo].[spa_get_assmt_rel_type_detail]  
	@calc_level INT,
	@link_id INT,
	@eff_test_profile_id INT,
	@hedge_or_item VARCHAR(1),
	@assessmentPriceType INT, 
	@runDate DATETIME
AS

----UNCOMMENT THE FOLLOWING TO TEST
-- DECLARE @calc_level int
-- DECLARE @link_id int
-- DECLARE @eff_test_profile_id int
-- DECLARE @hedge_or_item varchar(1)
-- DECLARE @assessmentPriceType Int
-- DECLARE @runDate datetime
-- SET @calc_level = 2
-- SET @eff_test_profile_id = null
-- SET @link_id = -228
-- SET @hedge_or_item = 'i'
-- SET @assessmentPriceType = 375
-- SET @runDate= '2004-06-30'
-- drop table #temp
-- drop table #temp1
-- drop table #fas_link_detail
----UNCOMMENT THE ABOVE TO TEST

DECLARE @perfect_hedge VARCHAR(1)
SET @perfect_hedge ='n'
If @calc_level = 2 
BEGIN
	IF (SELECT COUNT(*)  FROM  fas_link_header 
		WHERE link_id = @link_id and perfect_hedge = 'y') = 1 
	BEGIN
		SET @perfect_hedge = 'y'
	END
END

IF @calc_level = 1 
BEGIN
	--drop table #temp

	SELECT 	 NULL eff_test_profile_detail_id, 
		eff_test_profile_id, 
		hedge_or_item, 
		NULL book_deal_type_map_id, 
		NULL source_deal_type_id, 
		NULL deal_sub_type_id, 
		fixed_float_flag, 
	        NULL deal_sequence_number, 
-- 		leg, 
		buy_sell_flag, 
		reDetail.source_curve_def_id, 
		dbo.FNACreateAssessmentFromToDate(strip_month_from, strip_month_to, 
			roll_forward_year, strip_year_overlap, @runDate, 1)  AS strip_month_from, 
		dbo.FNACreateAssessmentFromToDate(strip_month_from, strip_month_to, 
			roll_forward_year, strip_year_overlap, @runDate, 2)  AS strip_month_to, 
		strip_year_overlap, 
		roll_forward_year, 
		volume_mix_percentage, 
		uom_conversion_factor, 
		deal_xfer_source_book_id, 
		cur.source_currency_id, 
		cur.currency_name, 
	        uom.source_uom_id, 
		uom.uom_name, 
	        cDef.curve_name, 
		1.00 AS conversion_factor 
	INTO	#temp
	FROM 	fas_eff_hedge_rel_type_detail reDetail LEFT OUTER JOIN  
	        source_price_curve_def cDef ON reDetail.source_curve_def_id = cDef.source_curve_def_id LEFT OUTER JOIN  
	        source_currency cur ON cDef.source_currency_id = cur.source_currency_id LEFT OUTER JOIN  
	        source_uom uom ON cDef.uom_id = uom.source_uom_id
	WHERE 	eff_test_profile_id =  @eff_test_profile_id AND hedge_or_item = @hedge_or_item AND 
		reDetail.source_curve_def_id IS NOT NULL AND
		buy_sell_flag = CASE 	WHEN (@assessmentPriceType = 377) THEN 'b'
					WHEN (@assessmentPriceType = 378) THEN 's'
					ELSE  buy_sell_flag
				END
	

	--for cost less collar or collar
	IF (select count(*) from #temp
		where source_curve_def_id = (select min(source_curve_def_id) from  #temp)
		and (buy_sell_flag = 'b' or buy_sell_flag = 's')) = 2
	BEGIN
		DELETE FROM #temp where source_curve_def_id = (select min(source_curve_def_id) from  #temp)
		and (buy_sell_flag = 'b') 
	END	
	ELSE
	BEGIN
		--Delete offsetting price ids
		delete from #temp
		from #temp  inner join #temp t2 on
		#temp.source_curve_def_id = t2.source_curve_def_id and
		#temp.buy_sell_flag <> t2.buy_sell_flag and
		#temp.strip_month_from = t2.strip_month_from and
		#temp.strip_month_to = t2.strip_month_to
	END

	SELECT 	eff_test_profile_detail_id, 
		eff_test_profile_id, 
		hedge_or_item, 
		book_deal_type_map_id, 
		source_deal_type_id, 
		deal_sub_type_id, 
		fixed_float_flag, 
	    deal_sequence_number, 
		source_curve_def_id, 
		strip_month_from, 
		strip_month_to, 
		strip_year_overlap, 
		roll_forward_year, 
		volume_mix_percentage, 
		uom_conversion_factor, 
		deal_xfer_source_book_id, 
		source_currency_id, 
		currency_name, 
	        source_uom_id, 
		uom_name, 
	        curve_name, 
		conversion_factor
	FROM #temp 

	RETURN
END
ELSE IF @calc_level = 3 
BEGIN
	SELECT 	NULL eff_test_profile_detail_id, 
		eff_test_profile_id, 
		hedge_or_item, 
		NULL book_deal_type_map_id, 
		NULL source_deal_type_id, 
		NULL deal_sub_type_id, 
		't' fixed_float_flag, 
--	        eff_test_profile_detail_id as deal_sequence_number, 
	        NULL as deal_sequence_number, 
-- 		1 as leg, 
-- 		'b' buy_sell_flag, 
		reDetail.source_curve_def_id, 
		strip_month_from, 
		strip_month_to, 
		0 strip_year_overlap, 
		0 roll_forward_year, 
		volume_mix_percentage, 
		uom_conversion_factor, 
		NULL deal_xfer_source_book_id, 
		cur.source_currency_id, 
		cur.currency_name, 
	        uom.source_uom_id, 
		uom.uom_name, 
	        cDef.curve_name, 
		1.00 As conversion_factor 
	FROM 	fas_eff_hedge_rel_type_whatif_detail reDetail LEFT OUTER JOIN  
	        source_price_curve_def cDef ON reDetail.source_curve_def_id = cDef.source_curve_def_id LEFT OUTER JOIN  
	        source_currency cur ON cDef.source_currency_id = cur.source_currency_id LEFT OUTER JOIN  
	        source_uom uom ON cDef.uom_id = uom.source_uom_id
	WHERE 	eff_test_profile_id =  @eff_test_profile_id AND hedge_or_item = @hedge_or_item 
		
	RETURN
END
ELSE IF @calc_level = 2
BEGIN

	If (@eff_test_profile_id is null AND @link_id < 0)
	BEGIN
		select 	@eff_test_profile_id = coalesce(fb.no_links_fas_eff_test_profile_id, fs.no_links_fas_eff_test_profile_id),
				@assessmentPriceType = case when (@assessmentPriceType  is not null) then @assessmentPriceType 
						when (@hedge_or_item = 'h') then
							coalesce(rtype_book.hedge_test_price_option_value_id, rtype_strat.hedge_test_price_option_value_id)
						else
							coalesce(rtype_book.item_test_price_option_value_id, rtype_strat.item_test_price_option_value_id)
						end

		from	 portfolio_hierarchy book INNER JOIN
				 portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id INNER JOIN
				 fas_strategy fs on fs.fas_strategy_id = stra.entity_id INNER JOIN
				fas_books fb on fb.fas_book_id = book.entity_id LEFT OUTER JOIN
				fas_eff_hedge_rel_type rtype_book on rtype_book.eff_test_profile_id = fb.no_links_fas_eff_test_profile_id LEFT OUTER JOIN
				fas_eff_hedge_rel_type rtype_strat on rtype_strat.eff_test_profile_id = fs.no_links_fas_eff_test_profile_id 
				
		where (-1*fs.fas_strategy_id = @link_id OR -1*fb.fas_book_id = @link_id)	
	END
	If (@eff_test_profile_id is null AND @link_id > 0)
	BEGIN
		select 	@eff_test_profile_id = eff_test_profile_id
		from	fas_link_header 
		where	link_id = @link_id
	END

	EXEC spa_print @assessmentPriceType
	--DROP TABLE #temp1
	select * into #fas_link_detail from fas_link_detail where link_id = @link_id
	If @link_id < 0
	BEGIN	
		insert into #fas_link_detail 
		select 	@link_id link_id, sdh.source_deal_header_id, isnull(ssbm.percentage_included , 1) percentage_included, 
				case when (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)  = 400) then 'h' else 'i' end hedge_or_item, 
				ssbm.create_user, ssbm.create_ts, ssbm.update_user, ssbm.update_ts,ssbm.effective_start_date
		from	portfolio_hierarchy book INNER JOIN
				portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id INNER JOIN
				source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id INNER JOIN
				source_deal_header sdh ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
						sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND 
						sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
						sdh.source_system_book_id4 = ssbm.source_system_book_id4			
		where	(-1*book.entity_id = @link_id OR -1*stra.entity_id = @link_id) AND
				isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)  IN (400, 401)
	END

--	select * from #fas_link_detail
--	return

	SELECT 	DISTINCT NULL eff_test_profile_detail_id,
		reDetail.eff_test_profile_id,   		
		@hedge_or_item as hedge_or_item, --fld.hedge_or_item, 
		NULL AS book_deal_type_map_id, 
		NULL source_deal_type_id, 
		NULL deal_sub_type_id, 
		reDetail.fixed_float_leg AS fixed_float_flag, 
	    NULL as deal_sequence_number, 
 		reDetail.buy_sell_flag, 
		reDetail.curve_id as source_curve_def_id, 
		min(min_max_date.term_start) strip_month_from, 
		max(min_max_date.term_end) strip_month_to,
		0 strip_year_overlap, 
		0 roll_forward_year, 
		reDetail.volume_mix_percentage, 
		reDetail.uom_conversion_factor, 
		-1 deal_xfer_source_book_id, 
		cur.source_currency_id, 
		cur.currency_name, 
	    uom.source_uom_id, 
		uom.uom_name, 
	    cDef.curve_name, 
		1.00 As conversion_factor 
	INTO #temp1
	FROM 	(select 	deal.source_deal_header_id, 
				deal.fas_book_id, 
				deal.deal_sub_type_type_id, 
				deal.fixed_float_leg, 
				deal.buy_sell_flag, 
				deal.curve_id,
				@hedge_or_item hedge_or_item, 
				@eff_test_profile_id AS eff_test_profile_id,
				isnull(rel.volume_mix_percentage, 1) AS volume_mix_percentage, 
				isnull(rel.uom_conversion_factor, 1) AS uom_conversion_factor
		from  
		(SELECT 	source_deal_header.source_deal_header_id, 
				NULL AS fas_book_id, 
				source_system_book_map.book_deal_type_map_id, 
				isnull(source_deal_header.source_deal_type_id, -1) as source_deal_type_id, 
				isnull(source_deal_header.deal_sub_type_type_id, -1) as deal_sub_type_type_id, 
				source_deal_detail.fixed_float_leg, 
				source_deal_detail.Leg, source_deal_detail.buy_sell_flag, 
				isnull(source_deal_detail.curve_id, -1) as curve_id,
				max(source_deal_detail.term_start) as term_start
		FROM    	#fas_link_detail fld INNER JOIN
			        source_deal_header ON source_deal_header.source_deal_header_id = fld.source_deal_header_id INNER JOIN

		        	source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
		            source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1 AND 
	                source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2 AND 
	                source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3 AND 
	                source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4
		WHERE		fld.link_id = @link_id AND fld.hedge_or_item = case when (@perfect_hedge = 'y') then 'h' else @hedge_or_item end
				AND curve_id IS NOT NULL AND --fld.percentage_included <> 0  AND
				source_deal_detail.buy_sell_flag = CASE 	WHEN (@assessmentPriceType = 377) THEN 'b'
					WHEN (@assessmentPriceType = 378) THEN 's'
					ELSE  source_deal_detail.buy_sell_flag
					END
		GROUP BY 	source_deal_header.source_deal_header_id, source_system_book_map.book_deal_type_map_id, fld.link_id,  
		        	source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
		                source_deal_detail.fixed_float_leg, source_deal_detail.Leg, source_deal_detail.buy_sell_flag, source_deal_detail.curve_id
				
		) deal LEFT OUTER JOIN
		(SELECT  	eff_test_profile_detail_id, 
				book_deal_type_map_id, 
				isnull(source_deal_type_id, -1) as source_deal_type_id, 
				isnull(deal_sub_type_id, -1) as  deal_sub_type_id, 
				fixed_float_flag, 
			        deal_sequence_number, 
				leg, 
				buy_sell_flag, 
				isnull(source_curve_def_id, -1) source_curve_def_id, 
				strip_month_from, 
				strip_month_to, 
				strip_year_overlap, 
				roll_forward_year, 
				volume_mix_percentage, 
				uom_conversion_factor, 
				deal_xfer_source_book_id
		FROM    fas_eff_hedge_rel_type INNER JOIN
             	fas_eff_hedge_rel_type_detail ON fas_eff_hedge_rel_type.eff_test_profile_id = fas_eff_hedge_rel_type_detail.eff_test_profile_id INNER JOIN
				(SELECT     TOP 1 source_system_book_map.fas_book_id
				 FROM       #fas_link_detail fld INNER JOIN
		                 source_deal_header ON fld.source_deal_header_id = source_deal_header.source_deal_header_id INNER JOIN
		                 source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1 AND 
		                 source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2 AND 
		                 source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3 AND 
		                 source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4
				 WHERE     fld.link_id = @link_id) book_id on book_id.fas_book_id = fas_eff_hedge_rel_type.fas_book_id
		WHERE     	fas_eff_hedge_rel_type_detail.hedge_or_item = case when (@perfect_hedge = 'y') then 'h' else @hedge_or_item end
				AND fas_eff_hedge_rel_type.eff_test_profile_id = @eff_test_profile_id
				AND source_curve_def_id IS NOT NULL)  rel
		
		ON 		
				rel.book_deal_type_map_id = deal.book_deal_type_map_id AND
				rel.source_deal_type_id = deal.source_deal_type_id AND
		        	rel.deal_sub_type_id = deal.deal_sub_type_type_id AND
				rel.source_curve_def_id = deal.curve_id

		) reDetail
		
		LEFT OUTER JOIN  
	        source_price_curve_def cDef ON reDetail.curve_id = cDef.source_curve_def_id LEFT OUTER JOIN  
	        source_currency cur ON cDef.source_currency_id = cur.source_currency_id LEFT OUTER JOIN  
	        source_uom uom ON cDef.uom_id = uom.source_uom_id
		LEFT OUTER JOIN
		(SELECT 	distinct 
				source_deal_header.source_deal_header_id, curve_id, 	
				@hedge_or_item as hedge_or_item, dbo.FNAGetSQLStandardDate(min(term_start)) term_start, dbo.FNAGetSQLStandardDate(max(term_start)) term_end
		FROM    #fas_link_detail fld INNER JOIN
			        source_deal_header ON source_deal_header.source_deal_header_id = fld.source_deal_header_id INNER JOIN
		        	source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id 
		WHERE	--	fld.percentage_included <>  0 AND 
				fld.link_id = @link_id AND fld.hedge_or_item = case when (@perfect_hedge = 'y') then 'h' else @hedge_or_item end
		GROUP BY source_deal_header.source_deal_header_id, curve_id
		) min_max_date ON min_max_date.hedge_or_item = reDetail.hedge_or_item
		--==XX Changes added here (added the follwoin two  clms in  select and group by also
	          AND min_max_date.source_deal_header_id = reDetail.source_deal_header_id AND
		  min_max_date.curve_id = reDetail.curve_id
		GROUP BY reDetail.eff_test_profile_id, reDetail.fixed_float_leg, 
 			reDetail.buy_sell_flag, reDetail.curve_id, reDetail.volume_mix_percentage, reDetail.uom_conversion_factor, 
			cur.source_currency_id, cur.currency_name, uom.source_uom_id, uom.uom_name, cDef.curve_name

--	select * from #temp1

	--for cost less collar or collar
	IF (select count(*) from #temp1 
		where source_curve_def_id = (select min(source_curve_def_id) from  #temp1)
		and (buy_sell_flag = 'b' or buy_sell_flag = 's')) = 2
	BEGIN
		DELETE FROM #temp1 where source_curve_def_id = (select min(source_curve_def_id) from  #temp1)
		and (buy_sell_flag = 'b') 
	END	
	ELSE
	BEGIN
		--Delete offsetting price ids
		delete from #temp1
		from #temp1  inner join #temp1 t2 on
		#temp1.source_curve_def_id = t2.source_curve_def_id and
		#temp1.buy_sell_flag <> t2.buy_sell_flag and
		#temp1.strip_month_from = t2.strip_month_from and
		#temp1.strip_month_to = t2.strip_month_to
	END

	SELECT 	eff_test_profile_detail_id, 
		eff_test_profile_id, 
		hedge_or_item, 
		book_deal_type_map_id, 
		source_deal_type_id, 
		deal_sub_type_id, 
		fixed_float_flag, 
	        deal_sequence_number, 
		source_curve_def_id, 
		strip_month_from, 
		strip_month_to, 
		strip_year_overlap, 
		roll_forward_year, 
		volume_mix_percentage, 
		uom_conversion_factor, 
		deal_xfer_source_book_id, 
		source_currency_id, 
		currency_name, 
	        source_uom_id, 
		uom_name, 
	        curve_name, 
		conversion_factor
	FROM #temp1 


END











