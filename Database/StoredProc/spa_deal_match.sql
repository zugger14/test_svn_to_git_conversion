
/********************************************************************
 * Create date: 2017-06-14											*
 * Description: Insert update match for deals						*
 * Params:															*
 * @flag			->	i: insert									*
 *						u: update mode							*
 * ******************************************************************/
 
IF EXISTS (
       SELECT 1
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_deal_match]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_deal_match]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_deal_match]
	@flag CHAR(1),
	@link_id INT = NULL,
	@xmlValue TEXT = NULL,
	@set CHAR(1) = NULL,
	@source_deal_header_id VARCHAR(2000) = NULL,
	@ignore_source_deal_header_id VARCHAR(2000) = NULL,
	@volume_min FLOAT = NULL,
	@volume_max FLOAT = NULL,
	@technology VARCHAR(MAX) = NULL,
	@country VARCHAR(MAX) = NULL,
	@label VARCHAR(MAX) = NULL,
	@not_technology VARCHAR(MAX) = NULL,
	@not_country VARCHAR(MAX) = NULL,
	@region_id VARCHAR(MAX) = NULL,
	@not_region_id VARCHAR(MAX) = NULL
AS 
	/********Debug Code*********
	DECLARE	@flag CHAR(1),
			@link_id INT = NULL,
			@xmlValue NVARCHAR(MAX) = NULL,
			@set CHAR(1) = NULL
	SELECT @flag='s'
	--*************************/
	SET NOCOUNT ON
	
	DECLARE @sql VARCHAR(MAX)
	DECLARE @DESC VARCHAR(500)
	DECLARE @err_no INT
	DECLARE @link_id_from VARCHAR(10)
	DECLARE @link_id_to VARCHAR(10)
	DECLARE @effective_date_from VARCHAR(10)
	DECLARE @effective_date_to VARCHAR(10)
	DECLARE @deal_id VARCHAR(10)
	DECLARE @ref_id VARCHAR(100)
	DECLARE @filter_group1 VARCHAR(10)
	DECLARE @filter_group2 VARCHAR(10)
	DECLARE @filter_group3 VARCHAR(10)
	DECLARE @filter_group4 VARCHAR(10)
	DECLARE @is_mismatch char(1)

	IF @flag = 's'
	BEGIN 
		
		DECLARE @idoc3 INT

		EXEC sp_xml_preparedocument @idoc3 OUTPUT, @xmlValue
			
		IF OBJECT_ID('tempdb..#temp_deal_match_filter') IS NOT NULL
			DROP TABLE #temp_deal_match_filter
		
		SELECT	
				NULLIF(link_id_from, '')					[link_id_from],
				NULLIF(link_id_to, '')						[link_id_to],
				NULLIF(effective_date_from, '')				[effective_date_from],
				NULLIF(effective_date_to, '')				[effective_date_to],
				NULLIF(deal_id, '')							[deal_id],
				NULLIF(ref_id, '')							[ref_id],
				NULLIF(filter_group1, '')						[filter_group1],
				NULLIF(filter_group2, '')						[filter_group2],
				NULLIF(filter_group3, '')						[filter_group3],
				NULLIF(filter_group4, '')						[filter_group4],
				NULLIF(is_mismatch, '')						[is_mismatch]
		INTO #temp_deal_match_filter
		FROM OPENXML(@idoc3, '/Root/FormXML', 1)
		WITH (
			link_id_from				VARCHAR(10),
			link_id_to					VARCHAR(10),
			[effective_date_from]		VARCHAR(10),
			[effective_date_to]			VARCHAR(10),
			[deal_id]					VARCHAR(10),
			[ref_id]					VARCHAR(100),
			[filter_group1]					VARCHAR(10),
			[filter_group2]					VARCHAR(10),
			[filter_group3]					VARCHAR(10),
			[filter_group4]					VARCHAR(10),
			[is_mismatch]					CHAR(1)
		)

			SELECT 
				@link_id_from = link_id_from,
				@link_id_to = link_id_to,
				@effective_date_from = effective_date_from,
				@effective_date_to = effective_date_to,
				@deal_id = deal_id,
				@ref_id = ref_id,
				@filter_group1 = filter_group1,
				@filter_group2 = filter_group2,
				@filter_group3 = filter_group3,
				@filter_group4 = filter_group4,
				@is_mismatch = is_mismatch

			FROM #temp_deal_match_filter

		SET @sql = '
					SELECT source_deal_header_id, MAX(pnl_as_of_date) pnl_as_of_date INTO #temp_max_date_pnl2 FROM source_deal_pnl GROUP BY source_deal_header_id
					CREATE NONCLUSTERED INDEX idx_temp_max_date_pnl_pnl_as_of_date2 ON #temp_max_date_pnl2 (pnl_as_of_date)
					CREATE NONCLUSTERED INDEX idx_temp_max_date_pnl_source_deal_header_id2 ON #temp_max_date_pnl2 (source_deal_header_id)

					SELECT 
						mh.link_id,
						isnull(nullif(mh.link_description,''''),mh.link_id) [description],
						dbo.FNADateFormat(mh.link_effective_date) [mh.effective_date],
						mh.group1,
						mh.group2,
						mh.group3,
						mh.group4,
						MAX(mh.total_matched_volume) total_matched_volume,
						[dbo].[FNARemoveTrailingZeroes](CASE WHEN CAST(MAX(s1.term_start) AS DATETIME) > CAST(MAX(s2.term_start) AS DATETIME) THEN MAX(s2.price - s1.price) ELSE MAX(s1.price - s2.price) END) price,
						MAX(scu.currency_id) currency_id
						, MAX(sdv_ms.code)

					from matching_header mh

					inner join matching_detail md ON mh.link_id = md.link_id ' + CASE WHEN @deal_id is not null then ' AND md.source_deal_header_id = ' + @deal_id ELSE '' END + '
					inner join source_deal_header sdh on sdh.source_deal_header_id = md.source_deal_header_id ' + CASE WHEN @ref_id is not null then ' AND sdh.deal_id like ''%' + @ref_id + '%'''  ELSE '' END + '
					outer apply
					(
						SELECT MAX(sdh2.entire_term_start) max_term_start, MIN(sdh2.entire_term_start) min_term_start, MAX(deal_volume_uom_id) deal_volume_uom_id
						FROM matching_detail md2
						inner join source_deal_header sdh2 on sdh2.source_deal_header_id = md2.source_deal_header_id 
						left join source_deal_detail sdd2 on sdd2.source_deal_header_id = md2.source_deal_header_id
	
						WHERE md2.link_id = mh.link_id
					) sdh_min_max					
					outer apply
					(
						SELECT MAX(sdh2.entire_term_start) term_start,
								MAX(sdd2.fixed_price_currency_id) fixed_price_currency_id,
								AVG(ABS(ISNULL(sdd2.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))))) [price]
							FROM matching_detail md02
							inner join source_deal_header sdh2 on sdh2.source_deal_header_id = md02.source_deal_header_id 
							OUTER APPLY (
							SELECT TOP(1) 
										sdd.fixed_price,
										sdd.fixed_price_currency_id
								FROM source_deal_detail sdd 
								WHERE sdd.leg = 1 and sdd.source_deal_header_id = md02.source_deal_header_id
								order by sdd.term_start
							) sdd2 
							LEFT JOIN (
								SELECT sds.source_deal_header_id, 
										sum(settlement_amount) settlement_amount,
										SUM(volume) sds_volume
								FROM source_deal_settlement sds 
								GROUP BY sds.source_deal_header_id
							) ds ON ds.source_deal_header_id = md02.source_deal_header_id
							LEFT JOIN (
							SELECT sdp.source_deal_header_id, 
									sum(und_pnl_set) und_pnl_set,
									SUM(deal_volume) dp_volume
							FROM source_deal_pnl sdp 
							INNER JOIN #temp_max_date_pnl2 tmpnl 
								ON tmpnl.pnl_as_of_date = sdp.pnl_as_of_date
								AND tmpnl.source_deal_header_id = sdp.source_deal_header_id
									GROUP BY sdp.source_deal_header_id
							) dp ON dp.source_deal_header_id = md02.source_deal_header_id
							
							WHERE md02.link_id = mh.link_id AND md02.[set] = ''1''
							GROUP BY md02.[set]
							
					) s1

					outer apply
					(
						SELECT MAX(sdh2.entire_term_start) term_start,
								MAX(sdd2.fixed_price_currency_id) fixed_price_currency_id,
								AVG(ABS(ISNULL(sdd2.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))))) [price]
							FROM matching_detail md02
							inner join source_deal_header sdh2 on sdh2.source_deal_header_id = md02.source_deal_header_id 
							OUTER APPLY (
							SELECT TOP(1) 
										sdd.fixed_price,
										sdd.fixed_price_currency_id
								FROM source_deal_detail sdd 
								WHERE sdd.leg = 1 and sdd.source_deal_header_id = md02.source_deal_header_id
								order by sdd.term_start
							) sdd2 
							LEFT JOIN (
								SELECT sds.source_deal_header_id, 
										sum(settlement_amount) settlement_amount,
										SUM(volume) sds_volume
								FROM source_deal_settlement sds 
								GROUP BY sds.source_deal_header_id
							) ds ON ds.source_deal_header_id = md02.source_deal_header_id
							LEFT JOIN (
							SELECT sdp.source_deal_header_id, 
									sum(und_pnl_set) und_pnl_set,
									SUM(deal_volume) dp_volume
							FROM source_deal_pnl sdp 
							INNER JOIN #temp_max_date_pnl2 tmpnl 
								ON tmpnl.pnl_as_of_date = sdp.pnl_as_of_date
								AND tmpnl.source_deal_header_id = sdp.source_deal_header_id
									GROUP BY sdp.source_deal_header_id
							) dp ON dp.source_deal_header_id = md02.source_deal_header_id
							
							WHERE md02.link_id = mh.link_id AND md02.[set] = ''2''
							GROUP BY md02.[set]
							
					) s2
					LEFT JOIN source_currency scu ON scu.source_currency_id = ISNULL(s1.fixed_price_currency_id,s1.fixed_price_currency_id)
					LEFT JOIN static_data_value sdv_ms ON sdv_ms.value_id = mh.match_status
					WHERE 1 = 1
					'
		if @link_id_from is not null					
			SET @sql += ' AND mh.link_id >= ' + @link_id_from
		if @link_id_to is not null					
			SET @sql += ' AND mh.link_id <= ' + @link_id_to
		if @effective_date_from is not null					
			SET @sql += ' AND mh.link_effective_date >= ''' + @effective_date_from + ''''
		if @effective_date_to is not null					
			SET @sql += ' AND mh.link_effective_date <= ''' + @effective_date_to + ''''

		if @is_mismatch = 'y'
			SET @sql += ' and sdh_min_max.max_term_start <> sdh_min_max.min_term_start '
		

		SET @sql += '
					GROUP BY
					mh.link_id,
						mh.link_description,
						mh.link_effective_date,
						mh.group1,
						mh.group2,
						mh.group3,
						mh.group4,
						mh.update_ts,mh.create_ts
					order by isnull(mh.update_ts,mh.create_ts) DESC
					'
		
		--print(@sql)
			EXEC(@sql)

	END

	ELSE IF @flag = 'a'
	BEGIN 
		SELECT 
			link_id,
			isnull(nullif(link_description,''),link_id) [description],
			link_effective_date [effective_date],
			group1,
			group2,
			group3,
			group4,
			match_status
		from matching_header
		WHERE link_id = @link_id
	END

	ELSE IF @flag = 'g'
	BEGIN 

		DECLARE @grid_process_table VARCHAR(100)
		
		create table #tmp_deal_match_grid (grid_process_table VARCHAR(100))

		insert into #tmp_deal_match_grid (grid_process_table)
		--EXEC spa_source_deal_header  @flag='t',@filter_xml='<Root><FormXML  counterparty_id="4468,4465" commodity_id="" deal_date_from="2017-06-01" deal_date_to="2017-06-30" term_start="2017-06-01" term_end="" create_ts_from="2017-06-01" create_ts_to="" buy_sell_id="" sub_book_ids="8,7,6" template_id="2624,2611" deal_volume_uom_id="" filter_mode="a"  trader_id="" contract_id="" broker_id="" source_deal_header_id_from="" source_deal_header_id_to="" deal_id="" view_deleted="n" show_unmapped_deals="n" generator_id="" location_group_id="" location_id="" curve_id="" Index_group_id="" formula_curve_id="" formula_id="" deal_type_id="" deal_sub_type_id="" field_template_id="" physical_financial_id="" product_id="" internal_desk_id=""  settlement_date_from="" settlement_date_to="" payment_date_from="" payment_date_to="" deal_status="" confirm_status_type="" calc_status="" invoice_status="" deal_locked="" update_ts_from="" update_ts_to="" update_user="" create_user = ""></FormXML></Root>',@trans_type=NULL,@call_from=NULL
		EXEC spa_source_deal_header  @flag='t',@filter_xml=@xmlValue ,@trans_type=NULL,@call_from=''

		select @grid_process_table = grid_process_table from #tmp_deal_match_grid

		DECLARE @country_codes VARCHAR(MAX) = ''''''
		DECLARE @not_country_codes VARCHAR(MAX) = ''''''

		IF @country IS NOT NULL
		begin
			select distinct sdv01.code
			into #tmp_country_codes_deal_match
			from dbo.FNASplit(@country,',') i
					inner join rec_gen_eligibility rge on rge.state_value_id = i.item
					inner join static_data_value sdv01 on sdv01.value_id = rge.state_value_id
			select @country_codes = @country_codes + ',''' + code + '''' from #tmp_country_codes_deal_match
					
		end

		IF @not_country IS NOT NULL
		begin
			select distinct sdv01.code
				into #tmp_state_codes_deal_match
				from dbo.FNASplit(@not_country,',') i
						inner join rec_gen_eligibility rge on rge.state_value_id = i.item
						inner join static_data_value sdv01 on sdv01.value_id = rge.state_value_id
				select @not_country_codes = @not_country_codes + ',''' + code + '''' from #tmp_state_codes_deal_match

		end
		
		SET @sql = '
						SELECT sp.state_value_id, 
							t.item AS region_id
						INTO #state_properties
						from state_properties sp
						OUTER APPLY(SELECT item FROM dbo.SplitCommaSeperatedValues(sp.region_id)) t

						SELECT DISTINCT sp1.state_value_id
						INTO #not_filter
						FROM #state_properties sp1
						WHERE 1 = 1 ' +
						CASE WHEN @not_region_id IS NOT NULL AND @not_country IS NOT NULL THEN ' AND (sp1.region_id IN (' + @not_region_id + ') OR sp1.state_value_id IN (' + @not_country + '))'
							WHEN @not_region_id IS NOT NULL THEN ' AND sp1.region_id IN (' + @not_region_id + ')'						
							WHEN @not_country IS NOT NULL THEN ' AND sp1.state_value_id IN (' + @not_country + ')'
							ELSE '' 
						END + '
						
						
						SELECT DISTINCT sp.state_value_id
						INTO #filter
						FROM #state_properties sp
						WHERE 1 = 1 ' +
						CASE WHEN @region_id IS NOT NULL AND  @country IS NOT NULL THEN ' AND (sp.region_id IN (' + @region_id + ') OR sp.state_value_id IN (' + @country + '))'
							WHEN @region_id IS NOT NULL THEN ' AND sp.region_id IN (' + @region_id + ')'						
							WHEN @country IS NOT NULL THEN ' AND sp.state_value_id IN (' + @country + ')'
							ELSE '' 
						END + '

						select 
							f1.state_value_id
						into #still_exists_not_filter
						from #filter f1
						left join #not_filter nf1 on f1.state_value_id = nf1.state_value_id
						where nf1.state_value_id is null
						
						--select * from #filter
						--select * from #not_filter
						--select * from #still_exists_not_filter

						SELECT
							 ISNULL(sdh2.ext_deal_id,sdh.id) ext_deal_id
							, sdh.id [source_deal_header_id]
							, sdh.deal_id [ref_id]
							, sdh.[location_index] [product]
							, sdh.[commodity] [commodity]
							, sdh.buy_sell [buy_sell]
							, sdh.counterparty [counterparty]
							, sdh.deal_date [deal_date]
							, sdh.term_start [term_start]
							, sdh.term_end [term_end]
							, FORMAT(sdd.expiration_date, ''MMM yyyy'') AS [expiration_date]
							--, dbo.FNADateFormat(sdd.expiration_date) [expiration_date]
							, [dbo].[FNARemoveTrailingZeroes](isnull(sdd.total_volume,0)) [actual_volume]
							, [dbo].[FNARemoveTrailingZeroes](isnull(md.[matched_volume],0)) [matched]
							, [dbo].[FNARemoveTrailingZeroes](CAST(isnull(sdd.total_volume,0) AS NUMERIC(38,20)) - CAST(isnull(md.[matched_volume],0) AS NUMERIC(38,20))) [remaining]
							, sdh.deal_volume_uom_id [uom]
							, sdh.deal_price [price]
							, [dbo].[FNARemoveTrailingZeroes](isnull(sdd.total_volume,0) * sdh.deal_price) [vp_value]
							, sdh.currency [currency]
							, lab.[label] [Label]
							FROM
							'
							+ @grid_process_table +  ' AS sdh
							
							INNER JOIN source_deal_header sdh2 on sdh.id = sdh2.source_deal_header_id
														
							OUTER APPLY
							(
							SELECT SUM(total_volume) total_volume,
								MAX(contract_expiration_date) expiration_date
							FROM
							source_deal_detail 
							WHERE source_deal_header_id = sdh.id
							) sdd

							OUTER APPLY
							(
								SELECT 
									SUM(matched_volume) matched_volume
								FROM
								matching_detail 
								WHERE source_deal_header_id = sdh.id
							) md 
		'
			
			IF COALESCE(@region_id, @not_region_id, @country, @not_country) IS NOT NULL
                        BEGIN
                             SET @sql += '
								OUTER APPLY(SELECT COUNT(state_value_id) total FROM #filter) filter
                                OUTER APPLY(SELECT COUNT(state_value_id) total FROM #not_filter) not_filter
                                OUTER APPLY(SELECT COUNT(d.state_value_id) total,
								SUM(CASE WHEN d.state_value_id IS NOT NULL THEN 0 ELSE 1 END) tot
							FROM(
								(SELECT 
									sp.state_value_id
								FROM gis_product gp
								INNER JOIN #state_properties sp ON sp.region_id = gp.region_id
								WHERE gp.source_deal_header_id = sdh.id AND gp.in_or_not = 1
								UNION
								SELECT 
									f1.state_value_id
								FROM gis_product gp
								left join #filter f1 on 1=1
								WHERE gp.source_deal_header_id = sdh.id 
								AND gp.in_or_not = 1 
								AND gp.jurisdiction_id IS NULL AND gp.region_id IS NULL
								UNION 
								SELECT 
									gp.jurisdiction_id
								FROM gis_product gp
								WHERE gp.source_deal_header_id = sdh.id 
								AND gp.in_or_not = 1 AND gp.jurisdiction_id IS NOT NULL)
								EXCEPT
								(SELECT 
									sp.state_value_id
								FROM gis_product gp
								INNER JOIN #state_properties sp ON sp.region_id = gp.region_id
								WHERE gp.source_deal_header_id = sdh.id AND gp.in_or_not = 0
								UNION 
								SELECT 
									gp.jurisdiction_id
								FROM gis_product gp 
								WHERE gp.source_deal_header_id = sdh.id 
								AND gp.in_or_not = 0 AND gp.jurisdiction_id IS NOT NULL)) d
							INNER JOIN #filter f ON (d.state_value_id IS NULL OR f.state_value_id = d.state_value_id)) deal
					
					
						outer apply (
							SELECT SUM(CASE WHEN d.jurisdiction_id IS NOT NULL THEN 1 ELSE 0 END) tot
							from
							(
							select 
								gp.jurisdiction_id
								from gis_product gp
								INNER JOIN #state_properties sp ON sp.region_id = gp.region_id
										WHERE gp.source_deal_header_id = sdh.id AND gp.in_or_not = 0
							UNION 
								SELECT 
									gp.jurisdiction_id
								FROM gis_product gp
								WHERE gp.source_deal_header_id = sdh.id 
								AND gp.in_or_not = 0 AND gp.jurisdiction_id IS NOT NULL
							) d							
								inner join #still_exists_not_filter f on f.state_value_id = d.jurisdiction_id
						) check_in_for_not

					OUTER APPLY(SELECT COUNT(d.state_value_id) total2, SUM(CASE WHEN f.state_value_id IS NOT NULL THEN 1 ELSE 0 END) total,
								SUM(CASE WHEN d.state_value_id IS NOT NULL THEN 0 ELSE 1 END) tot
							FROM(
								(SELECT 
									sp.state_value_id
								FROM gis_product gp
								INNER JOIN #state_properties sp ON sp.region_id = gp.region_id
								WHERE gp.source_deal_header_id = sdh.id AND gp.in_or_not = 0
								UNION
								SELECT 
									gp.jurisdiction_id
								FROM gis_product gp
								WHERE gp.source_deal_header_id = sdh.id 
								AND gp.in_or_not = 0
								AND gp.jurisdiction_id IS NULL AND gp.region_id IS NULL
								UNION 
								SELECT 
									gp.jurisdiction_id
								FROM gis_product gp
								WHERE gp.source_deal_header_id = sdh.id 
								AND gp.in_or_not = 0 AND gp.jurisdiction_id IS NOT NULL)
								) d
							left JOIN #not_filter f ON (f.state_value_id = d.state_value_id)) deal2
					              '

                        END

			IF COALESCE(@region_id, @not_region_id, @country, @not_country,@technology,@not_technology) IS NOT NULL
			BEGIN
				SET @sql += '
					OUTER APPLY (
						SELECT MIN(gt01.in_or_not) in_or_not
						from gis_product gt01 where gt01.source_deal_header_id = sdh.id
						group by gt01.source_deal_header_id)	in_out_not
					OUTER APPLY(SELECT 
									MAX(in_or_not) jurisdiction_in_or_not
								FROM Gis_Product gpss
								WHERE gpss.source_deal_header_id = sdh.id AND gpss.jurisdiction_id <> 0 ) jur_gp
					 OUTER APPLY(SELECT 
									MAX(in_or_not) tier_in_or_not
								FROM Gis_Product gpss2
								WHERE gpss2.source_deal_header_id = sdh.id AND gpss2.tier_id <> 0 ) tier_gp
					OUTER APPLY (SELECT 
									top 1
									rge.state_value_id,
									rge.technology
								FROM rec_gen_eligibility rge
								LEFT JOIN Gis_Product gps on rge.state_value_id = NULLIF(gps.jurisdiction_id,0) 
									AND gps.in_or_not = jur_gp.jurisdiction_in_or_not 
									AND gps.source_deal_header_id = sdh.id
								LEFT JOIN Gis_Product gps2	on rge.technology = NULLIF(gps2.tier_id,0) 
									AND gps2.in_or_not = tier_gp.tier_in_or_not 
									AND  gps2.source_deal_header_id = sdh.id
								LEFT JOIN static_data_value gps_sdv1 on gps_sdv1.value_id = rge.state_value_id
								LEFT JOIN static_data_value gps_sdv2 on gps_sdv2.value_id = rge.gen_state_value_id
								WHERE ((jur_gp.jurisdiction_in_or_not =1 AND gps.in_or_not is not null) OR 
										(gps.in_or_not is null AND jur_gp.jurisdiction_in_or_not = 0) OR jur_gp.jurisdiction_in_or_not IS NULL)
								AND ((tier_gp.tier_in_or_not =1 AND gps2.in_or_not is not null) OR 
									(gps2.in_or_not is null AND tier_gp.tier_in_or_not = 0) OR tier_gp.tier_in_or_not IS NULL) '
						
						IF @country IS NOT NULL
						begin
							SET @sql += ' AND (gps_sdv1.code IN (' + @country_codes + ') OR gps_sdv2.code IN (' + @country_codes + ')) '
						end

						IF @not_country IS NOT NULL
						begin
							SET @sql += ' AND (gps_sdv1.code NOT IN (' + @not_country_codes + ') AND gps_sdv2.code NOT IN (' + @not_country_codes + ')) '
						end

						IF @technology IS NOT NULL
						begin
							SET @sql += ' AND rge.technology IN (' + @technology + ') '
						end

						IF @not_technology IS NOT NULL
						begin
							SET @sql += ' AND rge.technology NOT IN (' + @not_technology + ') '
						end

						SET @sql += ' ) country_tech '
			END

			SET @sql += '	OUTER APPLY (
								SELECT uddf.udf_value [label_id], sdv1.code [label]
								FROM user_defined_deal_fields uddf
								INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id AND uddft.template_id = sdh2.template_id
								INNER JOIN user_defined_fields_template udft ON uddft.udf_user_field_id = udft.udf_template_id
								INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_name AND uddft.field_name = sdv.value_id AND sdv.type_id = 5500 AND sdv.code = ''label'' 
								LEFT JOIN static_data_value sdv1 ON CAST(sdv1.value_id AS VARCHAR(20)) = uddf.udf_value
								WHERE sdh2.source_deal_header_id = uddf.source_deal_header_id							
							) lab
							
							WHERE (md.[matched_volume] IS NULL OR [dbo].[FNARemoveTrailingZeroes](md.[matched_volume]) <> [dbo].[FNARemoveTrailingZeroes](sdd.total_volume))
							
							AND sdh.deal_id LIKE  CASE WHEN sdh.counterparty LIKE ''%Market Maker%'' THEN ''%_copy%'' ELSE sdh.deal_id END
			'
		IF @volume_max IS NOT NULL
		BEGIN
			SET @sql += '
				AND CAST(ISNULL(sdd.total_volume, 0) AS NUMERIC(38,20)) - CAST(isnull(md.[matched_volume],0) AS NUMERIC(38,20)) <= ' + CAST(@volume_max AS VARCHAR(MAX)) + '
			'
		END

		IF @volume_min IS NOT NULL
		BEGIN
			SET @sql += '
				AND CAST(ISNULL(sdd.total_volume, 0) AS NUMERIC(38,20)) - CAST(isnull(md.[matched_volume],0) AS NUMERIC(38,20)) >= ' + CAST(@volume_min AS VARCHAR(MAX)) + '
			'
		END

		IF @technology IS NOT NULL OR @not_technology IS NOT NULL
		begin
			SET @sql += ' AND [country_tech].state_value_id is not null AND sdh.deal_type = ''RECs'' '
		end

		IF COALESCE(@region_id, @not_region_id, @country, @not_country) IS NOT NULL
		begin
			IF COALESCE(@not_region_id, @not_country) IS NOT NULL
			BEGIN
				SET @sql += ' AND in_out_not.in_or_not = 0'
			END

			IF COALESCE(@region_id, @country) IS NOT NULL AND COALESCE(@not_region_id, @not_country) IS NOT NULL
			BEGIN
				SET @sql += ' AND ISNULL(check_in_for_not.tot,0) = 0 AND  not_filter.total = deal2.total2'
			END

			SET @sql += ' AND ((deal.total = filter.total AND deal.total > 0) OR ((deal2.total >= not_filter.total) AND deal.total > 0)) '
		end

		IF @label IS NOT NULL
		BEGIN
			SET @sql += ' AND lab.[label_id] IN (' + @label + ') '
		END
							
		
		SET @sql += ' ORDER BY sdh2.deal_date, source_deal_header_id
						
					  DROP TABLE ' + @grid_process_table + '
					'

		EXEC(@sql)
		drop table #tmp_deal_match_grid
	END

	ELSE IF @flag = 't'
	BEGIN
	-- load grid for update
		IF @xmlValue IS NOT NULL
		BEGIN
			DECLARE @idoc_t INT
			EXEC sp_xml_preparedocument @idoc_t OUTPUT, @xmlValue
			SELECT * INTO #temp_deal_matched_rem
			FROM   OPENXML(@idoc_t, 'Root/Grid/GridRow', 3)
					WITH (
						source_deal_header_id INT '@source_deal_header_id',
						[matched] NUMERIC(18,12) '@matched',
						[remaining] NUMERIC(18,12) '@remaining'
					)
		END		
			

	SET @sql = '

		SELECT source_deal_header_id, MAX(pnl_as_of_date) pnl_as_of_date INTO #temp_max_date_pnl1 FROM source_deal_pnl GROUP BY source_deal_header_id
		CREATE NONCLUSTERED INDEX idx_temp_max_date_pnl_pnl_as_of_date1 ON #temp_max_date_pnl1 (pnl_as_of_date)
		CREATE NONCLUSTERED INDEX idx_temp_max_date_pnl_source_deal_header_id1 ON #temp_max_date_pnl1 (source_deal_header_id)
		'
	SET @sql += '
	SELECT 
		ISNULL(sdh.ext_deal_id,sdh.source_deal_header_id) ext_deal_id,
		sdh.source_deal_header_id [source_deal_header_id],
		sdh.deal_id [ref_id],
		dd.location_index [product],
		ISNULL(sdd_co.commodity_name, sco.commodity_name) [commodity],		
		CASE WHEN sdh.header_buy_sell_flag = ''b'' THEN ''Buy'' ELSE ''Sell''END buy_sell,
		sct.counterparty_name [counterparty],
		dbo.FNADateFormat(sdh.deal_date) deal_date,
		dbo.FNADateFormat(sdh.entire_term_start) term_start,
		dbo.FNADateFormat(sdh.entire_term_end) term_end,
		FORMAT(tv.[expiration_date], ''MMM yyyy'') AS [expiration_date],
		--dbo.FNADateFormat(tv.[expiration_date]) expiration_date,

		[dbo].[FNARemoveTrailingZeroes](isnull(tv.total_volume,0)) [actual_volume],
		'		
	IF @source_deal_header_id is NULL OR @source_deal_header_id = ''
	begin
	SET @sql +='
		[dbo].[FNARemoveTrailingZeroes](md.matched_volume) [matched],
		[dbo].[FNARemoveTrailingZeroes](CAST(ABS(isnull(tv.total_volume,0) - mdt.total_matched_volume) AS NUMERIC(38,4))) [remaining],
		'
	end
	ELSE IF @xmlValue is not null
	begin
	SET @sql +='
		[dbo].[FNARemoveTrailingZeroes](tdmr.matched) [matched],
		[dbo].[FNARemoveTrailingZeroes](CAST(tdmr.remaining AS NUMERIC(38,4))) [remaining],
		'
	end
	ELSE
	begin
	SET @sql +='
		0 [matched],
		[dbo].[FNARemoveTrailingZeroes](CAST(ABS(isnull(tv.total_volume,0) - isnull(mdt.total_matched_volume,0)) AS NUMERIC(38,4))) [remaining],
		'
	end

	SET @sql +='
		su.uom_name [uom],
		[dbo].[FNARemoveTrailingZeroes](ABS(ISNULL(dd.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))))) [price],
		[dbo].[FNARemoveTrailingZeroes](isnull(tv.total_volume,0) * ABS(ISNULL(dd.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))))) [vp_value],
		CASE WHEN ISNULL(dd.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))) IS NULL THEN NULL ELSE scu.currency_name END [currency]
		, tech.[Technology]
		, country.[Country]
		, lab.[label] [Label]
		'
	IF @source_deal_header_id is NULL OR @source_deal_header_id = ''
	begin
	SET @sql +='
		from matching_header mh
		inner join matching_detail md on md.link_id = mh.link_id and md.link_id = ' + CAST(@link_id AS VARCHAR(10)) + ' and md.[set] = ''' + @set + '''
		inner join source_deal_header sdh on sdh.source_deal_header_id = md.source_deal_header_id
		'
	end
	ELSE
	begin
	SET @sql +='
		from dbo.SplitCommaSeperatedValues(''' + @source_deal_header_id + ''') md
		inner join source_deal_header sdh on sdh.source_deal_header_id = md.item AND sdh.source_deal_header_id not in (' + ISNULL(NULLIF(@ignore_source_deal_header_id,''),0) + ')
		'
	end
	SET @sql += '
		OUTER APPLY ( 
			SELECT TOP(1) CASE WHEN sdh.physical_financial_flag =''p'' THEN sml.location_Name ELSE spcd.curve_name END [location_index],
					sc.commodity_name,
					sml.source_major_location_ID,
					sml.source_minor_location_id,
					sdd.deal_volume_uom_id,
					sdd.fixed_price,
					sdd.fixed_price_currency_id,
					sdd.detail_commodity_id,
					sdd.leg
			FROM source_deal_detail sdd 
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			LEFT JOIN source_commodity sc ON sc.source_commodity_id = spcd.commodity_id
			WHERE sdd.leg = 1 and sdd.source_deal_header_id = sdh.source_deal_header_id
			order by sdd.term_start
		) dd 

		INNER JOIN source_counterparty sct ON sdh.counterparty_id = sct.source_counterparty_id AND sct.int_ext_flag <> ''b''
		LEFT JOIN source_uom su ON su.source_uom_id = dd.deal_volume_uom_id
		LEFT JOIN source_commodity sco ON sco.source_commodity_id = sdh.commodity_id	
		OUTER APPLY (
			SELECT commodity_name 
			FROM source_commodity sc 
			WHERE sc.source_commodity_id = dd.detail_commodity_id 
			AND dd.leg = 1						  	
		) sdd_co
		LEFT JOIN (
			SELECT sds.source_deal_header_id, 
					sum(settlement_amount) settlement_amount,
					SUM(volume) sds_volume
			FROM source_deal_settlement sds 
			GROUP BY sds.source_deal_header_id
		) ds ON ds.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN (
				SELECT sdp.source_deal_header_id, 
						sum(und_pnl_set) und_pnl_set,
						SUM(deal_volume) dp_volume
				FROM source_deal_pnl sdp 
				INNER JOIN #temp_max_date_pnl1 tmpnl 
					ON tmpnl.pnl_as_of_date = sdp.pnl_as_of_date
					AND tmpnl.source_deal_header_id = sdp.source_deal_header_id
				GROUP BY sdp.source_deal_header_id
		) dp ON dp.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_currency scu ON scu.source_currency_id = dd.fixed_price_currency_id
		OUTER APPLY
			(
			SELECT SUM(total_volume) total_volume, MAX(contract_expiration_date) [expiration_date]
			FROM
			source_deal_detail 
			WHERE source_deal_header_id = sdh.source_deal_header_id
		) tv
		OUTER APPLY
			(
			SELECT SUM(matched_volume) total_matched_volume
			FROM
			matching_detail 
			WHERE source_deal_header_id = sdh.source_deal_header_id
		) mdt

		OUTER APPLY (
			SELECT uddf.udf_value [Technology_id], sdv1.code [Technology]
			FROM user_defined_deal_fields uddf
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id AND uddft.template_id = sdh.template_id
			INNER JOIN user_defined_fields_template udft ON uddft.udf_user_field_id = udft.udf_template_id
			INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_name AND uddft.field_name = sdv.value_id AND sdv.type_id = 5500 AND sdv.code = ''Technology'' 
			LEFT JOIN static_data_value sdv1 ON CAST(sdv1.value_id AS VARCHAR(20)) = uddf.udf_value
			WHERE sdh.source_deal_header_id = uddf.source_deal_header_id						
		) tech

		OUTER APPLY (
			SELECT uddf.udf_value [Country_id], sdv1.code [Country]
			FROM user_defined_deal_fields uddf
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id AND uddft.template_id = sdh.template_id
			INNER JOIN user_defined_fields_template udft ON uddft.udf_user_field_id = udft.udf_template_id
			INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_name AND uddft.field_name = sdv.value_id AND sdv.type_id = 5500 AND sdv.code = ''Country'' 
			LEFT JOIN static_data_value sdv1 ON CAST(sdv1.value_id AS VARCHAR(20)) = uddf.udf_value
			WHERE sdh.source_deal_header_id = uddf.source_deal_header_id							
		) country

		OUTER APPLY (
			SELECT uddf.udf_value [label_id], sdv1.code [label]
			FROM user_defined_deal_fields uddf
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id AND uddft.template_id = sdh.template_id
			INNER JOIN user_defined_fields_template udft ON uddft.udf_user_field_id = udft.udf_template_id
			INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_name AND uddft.field_name = sdv.value_id AND sdv.type_id = 5500 AND sdv.code = ''label'' 
			LEFT JOIN static_data_value sdv1 ON CAST(sdv1.value_id AS VARCHAR(20)) = uddf.udf_value
			WHERE sdh.source_deal_header_id = uddf.source_deal_header_id							
		) lab
	'

	IF @xmlValue is not NULL
	begin
		SET @sql += '
					LEFT JOIN #temp_deal_matched_rem tdmr on tdmr.source_deal_header_id = sdh.source_deal_header_id 
					'
	end
	
	IF @source_deal_header_id is NULL OR @source_deal_header_id = ''
	begin	
	SET @sql += '
		where mh.link_id = ' + cast(@link_id as varchar(10)) + ' and md.[set] = ''' + @set + '''
		ORDER BY ext_deal_id
		'
	end
	EXEC(@sql)	
		
	END


	ELSE IF @flag = 'i'
	BEGIN
		BEGIN TRY 
			BEGIN TRAN

			DECLARE @idoc INT
			declare @new_link_id int
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue
			
			IF OBJECT_ID('tempdb..#temp_deal_match_header') IS NOT NULL
				DROP TABLE #temp_deal_match_header
		
			SELECT	
					--NULLIF(link_id, '')					[link_id],
					NULLIF([description], '')				[link_description],
					NULLIF(effective_date, '')				[link_effective_date],
					NULLIF(total_matched_volume, '')		[total_matched_volume],
					NULLIF(group1, '')						[group1],
					NULLIF(group2, '')						[group2],
					NULLIF(group3, '')						[group3],
					NULLIF(group4, '')						[group4],
					NULLIF(hedging_relationship_type, '')	[hedging_relationship_type],
					NULLIF(link_type, '')					[link_type]
			INTO #temp_deal_match_header
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				--link_id					INT,
				[description]		VARCHAR(1000),
				[effective_date]	datetime,
				[total_matched_volume]		FLOAT,
				[group1]				INT,
				[group2]				INT,
				[group3]				INT,
				[group4]				INT,
				[hedging_relationship_type]	INT,
				[link_type]				INT
			)

			SELECT * INTO #temp_deal_match_detail
			FROM   OPENXML(@idoc, 'Root/Grid/GridRow', 3)
					WITH (
						source_deal_header_id INT '@source_deal_header_id',
						matched_volume NUMERIC(18,12) '@matched_volume',
						[set] CHAR(1) '@set'
					)
	
			--select * from #temp_deal_match_header
			--select * from #temp_deal_match_detail

			INSERT INTO matching_header(
										[link_description],
										[link_effective_date],
										[total_matched_volume],
										[group1],
										[group2],
										[group3],
										[group4],
										match_status
										)
				SELECT 
					[link_description],
					[link_effective_date],
					[total_matched_volume],
					[group1],
					[group2],
					[group3],
					[group4],
					27203 -- NEW
				FROM #temp_deal_match_header

				SET @new_link_id = SCOPE_IDENTITY()

			INSERT INTO matching_detail(
									[link_id],
									[source_deal_header_id],
									[matched_volume],
									[set])
				SELECT 
					@new_link_id,
					[source_deal_header_id],
					[matched_volume],
					[set]
				FROM #temp_deal_match_detail
			
			DECLARE @process_table VARCHAR(500), @sql_stmt VARCHAR(MAX), @process_id VARCHAR(200)
	
			SET @process_id = dbo.FNAGetNewID()  
			SET @process_table = 'adiha_process.dbo.alert_deal_match_' + @process_id + '_adm'
			SET @sql_stmt = 'CREATE TABLE ' + @process_table + ' ( 
								link_id INT
							)
						INSERT INTO ' + @process_table + '(link_id)
						VALUES(' + CAST(@new_link_id AS VARCHAR(20)) + ')'

			EXEC(@sql_stmt)
			
			EXEC spa_register_event 20616, 20553, @process_table, 1, @process_id

			EXEC spa_ErrorHandler 0
				, 'deal_match'
				, 'spa_deal_match'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @new_link_id
		   COMMIT TRAN
		END TRY
		BEGIN CATCH	
			IF @@TRANCOUNT > 0
			ROLLBACK

			SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

			SELECT @err_no = ERROR_NUMBER()

			EXEC spa_ErrorHandler @err_no
			, 'deal_match'
			, 'spa_deal_match'
			, 'Error'
			, @DESC
			, ''

		END CATCH
	
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRY
			BEGIN TRAN

			DECLARE @idoc2 INT
				EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xmlValue
			
				IF OBJECT_ID('tempdb..#temp_deal_match_header2') IS NOT NULL
					DROP TABLE #temp_deal_match_header2
		
				SELECT	
						--NULLIF(link_id, '')					[link_id],
						NULLIF([description], '')				[link_description],
						NULLIF(effective_date, '')				[link_effective_date],
						NULLIF(total_matched_volume, '')		[total_matched_volume],
						NULLIF(group1, '')						[group1],
						NULLIF(group2, '')						[group2],
						NULLIF(group3, '')						[group3],
						NULLIF(group4, '')						[group4],
						NULLIF(hedging_relationship_type, '')	[hedging_relationship_type],
						NULLIF(link_type, '')					[link_type],
						NULLIF(match_status, '')				[match_status]
				INTO #temp_deal_match_header2
				FROM OPENXML(@idoc2, '/Root/FormXML', 1)
				WITH (
					--link_id					INT,
					[description]		VARCHAR(1000),
					[effective_date]	datetime,
					[total_matched_volume]		FLOAT,
					[group1]				INT,
					[group2]				INT,
					[group3]				INT,
					[group4]				INT,
					[hedging_relationship_type]	INT,
					[link_type]				INT,
					[match_status]				INT
				)

				SELECT * INTO #temp_deal_match_detail2
				FROM   OPENXML(@idoc2, 'Root/Grid/GridRow', 3)
						WITH (
							source_deal_header_id INT '@source_deal_header_id',
							matched_volume NUMERIC(18,12) '@matched_volume',
							[set] CHAR(1) '@set'
						)

			--if exists (select 1 from matching_header mh inner join #temp_deal_match_header2 th2 on 
			--			mh.[link_description] = th2.[link_description]
			--			AND mh.[link_effective_date] = th2.[link_effective_date]
			--			AND mh.[total_matched_volume] = th2.[total_matched_volume]
			--			AND mh.[group1] = th2.[group1]
			--			AND mh.[group2] = th2.[group2]
			--			AND mh.[group3] = th2.[group3]
			--			AND mh.[group4] = th2.[group4]
			--		  where mh.link_id = @link_id)

			--begin
			--		EXEC spa_ErrorHandler -1
			--			, 'deal_match'
			--			, 'spa_deal_match'
			--			, 'Error'
			--			, 'Data already exists.'
			--			, ''

			--			RETURN
			--end
			
			update mh
				SET mh.[link_description] = isnull(nullif(th2.[link_description],''),@link_id)
					, mh.[link_effective_date] = th2.[link_effective_date]
					, mh.[total_matched_volume] = th2.[total_matched_volume]
					, mh.[group1] = th2.[group1]
					, mh.[group2] = th2.[group2]
					, mh.[group3] = th2.[group3]
					, mh.[group4] = th2.[group4]
					, mh.match_status = th2.match_status
			FROM
			matching_header AS mh
			inner join #temp_deal_match_header2 th2 on  1 = 1
			WHERE mh.link_id = @link_id

			update md
				SET md.matched_volume = tdmd.[matched_volume],
					md.[set] = tdmd.[set]
				FROM matching_detail md
				inner join #temp_deal_match_detail2 tdmd on md.source_deal_header_id = tdmd.source_deal_header_id
				WHERE md.link_id = @link_id

			DELETE
				md
			FROM
			matching_detail md
			LEFT JOIN #temp_deal_match_detail2 tdmd on md.source_deal_header_id = tdmd.source_deal_header_id
				WHERE md.link_id = @link_id AND tdmd.source_deal_header_id IS NULL
				
			EXEC spa_ErrorHandler 0
				, 'deal_match'
				, 'spa_deal_match'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @link_id

		   COMMIT TRAN
		END TRY
		BEGIN CATCH	
			IF @@TRANCOUNT > 0
			ROLLBACK

			SET @DESC = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'

			SELECT @err_no = ERROR_NUMBER()

			EXEC spa_ErrorHandler @err_no
			, 'deal_match'
			, 'spa_deal_match'
			, 'Error'
			, @DESC
			, ''

		END CATCH
	
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN

		DELETE FROM matching_detail where link_id = @link_id
		
		DELETE FROM matching_header where link_id = @link_id
		
		EXEC spa_ErrorHandler 0
				, 'deal_match'
				, 'spa_deal_match'
				, 'Success' 
				, 'Delete successfully.'
				, @link_id		 

		COMMIT TRAN
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT > 0
		ROLLBACK

		SET @DESC = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
		, 'deal_match'
		, 'spa_deal_match'
		, 'Error'
		, @DESC
		, ''

	END CATCH
END