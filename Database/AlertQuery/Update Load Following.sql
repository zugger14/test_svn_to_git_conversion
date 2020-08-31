IF EXISTS (SELECT * FROM adiha_process.sys.tables WHERE [name] = 'alert_deal_process_id_ad')
BEGIN
	IF EXISTS(SELECT 1 FROM staging_table.alert_deal_process_id_ad WHERE counterparty_id IN (4,5,6))
	BEGIN
			
		if OBJECT_ID('tempdb..#pivoted_position_calc') is not null
		drop table #pivoted_position_calc

		if OBJECT_ID('tempdb..#position_calc') is not null
		drop table #position_calc

		DECLARE @counterparty_load             INT = 6,
				@counterparty_EDF          INT = 4,
				@counterparty_CPS          INT = 5,
				@counterparty_following    INT = 3,
				@source_deal_header_id     INT,
				@baseload_block_type       INT,
				@baseload_block_define_id  INT

		SET @baseload_block_type = 12000	-- Internal Static Data
		SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

		select @source_deal_header_id=source_deal_header_id from source_deal_header where counterparty_id=@counterparty_following

		print ' @source_deal_header_id:'+cast( @source_deal_header_id as varchar)

		select pos.term_start,sum(pos.Hr1) Hr1, sum(pos.Hr2) Hr2, sum(pos.Hr3) Hr3, sum(pos.Hr4) Hr4
						, sum(pos.Hr5) Hr5, sum(pos.Hr6) Hr6, sum(pos.Hr7) Hr7, sum(pos.Hr8) Hr8, sum(pos.Hr9) Hr9, sum(pos.Hr10) Hr10
						, sum(pos.Hr11) Hr11, sum(pos.Hr12) Hr12, sum(pos.Hr13) Hr13, sum(pos.Hr14) Hr14, sum(pos.Hr15) Hr15
						, sum(pos.Hr16) Hr16, sum(pos.Hr17) Hr17, sum(pos.Hr18) Hr18, sum(pos.Hr19) Hr19, sum(pos.Hr20) Hr20
						, sum(pos.Hr21) Hr21, sum(pos.Hr22) Hr22, sum(pos.Hr23) Hr23, sum(pos.Hr24) Hr24, sum(pos.Hr25) Hr25,sum(pos.Hr25) dst_Hr_value
		into #position_calc
		from (
			select term_start,abs(hr1)hr1,abs(hr2)hr2,abs(hr3)hr3,abs(hr4)hr4,abs(hr5)hr5,abs(hr6)hr6,abs(hr7)hr7,abs(hr8)hr8,abs(hr9)hr9,abs(hr10)hr10,abs(hr11)hr11,abs(hr12)hr12,abs(hr13)hr13,abs(hr14)hr14,abs(hr15)hr15,
			abs(hr16)hr16,abs(hr17)hr17,abs(hr18)hr18,abs(hr19)hr19,abs(hr20)hr20,abs(hr21)hr21,abs(hr22)hr22,abs(hr23)hr23,abs(hr24)hr24,abs(hr25)hr25
			from report_hourly_position_deal
			where counterparty_id in (@counterparty_load)
			union all
			select term_start,abs(hr1)hr1,abs(hr2)hr2,abs(hr3)hr3,abs(hr4)hr4,abs(hr5)hr5,abs(hr6)hr6,abs(hr7)hr7,abs(hr8)hr8,abs(hr9)hr9,abs(hr10)hr10,abs(hr11)hr11,abs(hr12)hr12,abs(hr13)hr13,abs(hr14)hr14,abs(hr15)hr15,
			abs(hr16)hr16,abs(hr17)hr17,abs(hr18)hr18,abs(hr19)hr19,abs(hr20)hr20,abs(hr21)hr21,abs(hr22)hr22,abs(hr23)hr23,abs(hr24)hr24,abs(hr25)hr25
			from report_hourly_position_profile
			where counterparty_id in (@counterparty_load)
			union all
			select term_start,-1*sum(e.hr1) hr1,-1*sum(e.hr2) hr2 ,-1*sum(e.hr3) hr3 ,-1*sum(e.hr4) hr4 ,-1*sum(e.hr5) hr5 ,-1*sum(e.hr6) hr6 ,-1*sum(e.hr7) hr7 ,-1*sum(e.hr8) hr8
						,-1*sum(e.hr9) hr9 ,-1*sum(e.hr10) hr10 ,-1*sum(e.hr11) hr11 ,-1*sum(e.hr12) hr12 ,-1*sum(e.hr13) hr13 ,-1*sum(e.hr14) hr14 ,-1*sum(e.hr15) hr15 ,-1*sum(e.hr16) hr16
						,-1*sum(e.hr17) hr17 ,-1*sum(e.hr18) hr18 ,-1*sum(e.hr19) hr19 ,-1*sum(e.hr20) hr20 ,-1*sum(e.hr21 ) hr21 ,-1*sum(e.hr22 ) hr22 ,-1*sum(e.hr23) hr23 ,-1*sum(e.hr24) hr24,-1*sum(e.hr25) hr25
			from report_hourly_position_deal e
			where counterparty_id in (@counterparty_EDF,@counterparty_CPS)
			group by term_start
			union all
			select term_start,-1*sum(e.hr1) hr1,-1*sum(e.hr2) hr2 ,-1*sum(e.hr3) hr3 ,-1*sum(e.hr4) hr4 ,-1*sum(e.hr5) hr5 ,-1*sum(e.hr6) hr6 ,-1*sum(e.hr7) hr7 ,-1*sum(e.hr8) hr8
						,-1*sum(e.hr9) hr9 ,-1*sum(e.hr10) hr10 ,-1*sum(e.hr11) hr11 ,-1*sum(e.hr12) hr12 ,-1*sum(e.hr13) hr13 ,-1*sum(e.hr14) hr14 ,-1*sum(e.hr15) hr15 ,-1*sum(e.hr16) hr16
						,-1*sum(e.hr17) hr17 ,-1*sum(e.hr18) hr18 ,-1*sum(e.hr19) hr19 ,-1*sum(e.hr20) hr20 ,-1*sum(e.hr21 ) hr21 ,-1*sum(e.hr22 ) hr22 ,-1*sum(e.hr23) hr23 ,-1*sum(e.hr24) hr24,-1*sum(e.hr25) hr25
			from report_hourly_position_profile e
			where counterparty_id in (@counterparty_EDF,@counterparty_CPS)
			group by term_start
		) pos


		group by pos.term_start

		SELECT source_deal_detail_id,term_start,dst_Hr_value, REPLACE(Hr, 'hr', '') Hr, total
		INTO #pivoted_position_calc
		FROM (
			SELECT sdd.source_deal_detail_id,t.term_start,t.dst_Hr_value,
				cast(isnull(h.Hr1,0)* t.Hr1 as numeric(28,10)) Hr1, cast(isnull(h.Hr2,0)* t.Hr2 as numeric(28,10)) Hr2, cast(isnull(h.Hr3,0)* t.Hr3 as numeric(28,10)) Hr3
				, cast(isnull(h.Hr4,0)* t.Hr4 as numeric(28,10)) Hr4, cast(isnull(h.Hr5,0)* t.Hr5 as numeric(28,10)) Hr5, cast(isnull(h.Hr6,0)* t.Hr6 as numeric(28,10)) Hr6
				, cast(isnull(h.Hr7,0)* t.Hr7 as numeric(28,10)) Hr7, cast(isnull(h.Hr8,0)* t.Hr8 as numeric(28,10)) Hr8, cast(isnull(h.Hr9,0)* t.Hr9 as numeric(28,10)) Hr9
				, cast(isnull(h.Hr10,0)* t.Hr10 as numeric(28,10)) Hr10	, cast(isnull(h.Hr11,0)* t.Hr11 as numeric(28,10)) Hr11, cast(isnull(h.Hr12,0)* t.Hr12 as numeric(28,10)) Hr12
				, cast(isnull(h.Hr13,0)* t.Hr13 as numeric(28,10)) Hr13, cast(isnull(h.Hr14,0)* t.Hr14 as numeric(28,10)) Hr14, cast(isnull(h.Hr15,0)* t.Hr15 as numeric(28,10)) Hr15
				, cast(isnull(h.Hr16,0)* t.Hr16 as numeric(28,10)) Hr16	, cast(isnull(h.Hr17,0)* t.Hr17 as numeric(28,10)) Hr17, cast(isnull(h.Hr18,0)* t.Hr18 as numeric(28,10)) Hr18
				, cast(isnull(h.Hr19,0)* t.Hr19 as numeric(28,10)) Hr19, cast(isnull(h.Hr20,0)* t.Hr20 as numeric(28,10)) Hr20, cast(isnull(h.Hr21,0)* t.Hr21 as numeric(28,10)) Hr21
				, cast(isnull(h.Hr22,0)* t.Hr22 as numeric(28,10)) Hr22, cast(isnull(h.Hr23,0)* t.Hr23 as numeric(28,10)) Hr23, cast(isnull(h.Hr24,0)* t.Hr24 as numeric(28,10)) Hr24, cast(Hr25 as numeric(28,10)) Hr25
			FROM source_deal_detail sdd inner join #position_calc t on  t.term_start between sdd.term_start and sdd.term_end and sdd.source_deal_header_id = @source_deal_header_id
			left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id 
			left join hour_block_term h on  t.term_start=h.term_date and h.block_define_id=COALESCE(spcd.block_define_id,@baseload_block_define_id)
				and h.block_type=@baseload_block_type
		) p 
		UNPIVOT
		(total FOR Hr IN (Hr1, Hr2, Hr3, Hr4, Hr5
				, Hr6, Hr7, Hr8, Hr9, Hr10
				, Hr11, Hr12, Hr13, Hr14, Hr15
				, Hr16, Hr17, Hr18, Hr19, Hr20
				, Hr21, Hr22, Hr23, Hr24, Hr25)
		) AS unpvt


		DELETE sddh FROM source_deal_detail_hour sddh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
			and sdd.source_deal_header_id = @source_deal_header_id	--39

		INSERT INTO source_deal_detail_hour(source_deal_detail_id, term_date, hr, is_dst, volume,granularity)
		SELECT	fdc.source_deal_detail_id,fdc.term_start,
			case when mv.insert_delete='i' and fdc.Hr=25 then mv.[hour] else fdc.Hr end Hr ,
			case when mv.insert_delete='i' and fdc.Hr=25 then 1 else 0 end AS [is_dst],
			case when mv.insert_delete='i' and  mv.[hour]=fdc.Hr then ABS(fdc.total-isnull(dst_Hr_value,0)) else ABS(fdc.total) end  [volume],982
		FROM #pivoted_position_calc fdc
		LEFT JOIN mv90_DST mv ON mv.date = fdc.term_start	
			AND mv.insert_delete = 'i' 
		LEFT JOIN mv90_DST mv1 ON mv1.[date] =fdc.term_start
			AND mv1.insert_delete = 'd' and mv1.[hour]=fdc.Hr
		WHERE ((mv.insert_delete is not null AND fdc.Hr = 25) OR fdc.Hr <> 25)
		and isnull(mv1.insert_delete,'a')<>'d' ---exclude delete dst
		--order by 1,2,3

			--select * from mv90_dst
			/*delete and insert in source_deal_detail_hour start*/

			/** Calculate the Position **/
			
		exec spa_calc_deal_position_breakdown @source_deal_header_id
		
		
	END
END