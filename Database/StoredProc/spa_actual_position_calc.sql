
IF OBJECT_ID(N'spa_actual_position_calc', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_actual_position_calc]
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 /**
	Retrieve actual position data for report

	Parameters : 
	@process_id : Process id for filtering process table to process
	

  */



CREATE PROCEDURE [dbo].[spa_actual_position_calc]
	@process_id VARCHAR(100)
AS
	
BEGIN

	DECLARE @user_login_id VARCHAR(30)

	IF @user_login_id IS NULL
		SET @user_login_id = dbo.fnadbuser()
	IF @process_id IS NULL
		set @process_id=dbo.FNAGetNewID()

	DECLARE @sql VARCHAR(MAX)
	DECLARE @baseload_block_definition  VARCHAR(10),@effected_deals VARCHAR(300)

	SELECT @baseload_block_definition = CAST(value_id AS VARCHAR(10))
	FROM   static_data_value
	WHERE  [type_id] = 10018
		   AND code LIKE 'Base Load' -- External Static Data


	SET @user_login_id=ISNULL(@user_login_id,dbo.FNADBUser())

	SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
--select @effected_deals

	--set @sql='select source_deal_header_id into '+@effected_deals+' from source_deal_header'
	--EXEC(@sql)

	IF OBJECT_ID('tempdb..#unpvt') IS NOT NULL
		DROP TABLE #unpvt
	    
	IF OBJECT_ID('tempdb..#temp_deals_v') IS NOT NULL
		DROP TABLE #temp_deals_v
	IF OBJECT_ID('tempdb..#tmp_pos_detail') IS NOT NULL
		DROP TABLE #tmp_pos_detail  
	IF OBJECT_ID('tempdb..#temp_pos') IS NOT NULL
		DROP TABLE #temp_pos
	    
	IF OBJECT_ID('tempdb..#meter_data_15min') IS NOT NULL
		DROP TABLE #meter_data_15min
	
	IF OBJECT_ID('tempdb..#meter_data_hr') IS NOT NULL
		DROP TABLE #meter_data_hr		    
	
	IF OBJECT_ID('tempdb..#meter_data_hr_gas') IS NOT NULL
		DROP TABLE #meter_data_hr_gas

	    
	CREATE TABLE #temp_deals_v 
	(
		source_deal_detail_id INT,
		source_deal_header_id INT,
		term_start DATETIME,term_end DATETIME,
		location_id INT,
		meter_id INT,
		curve_id INT,term_1st_day_month DATETIME,commodity_id INT,recorderid VARCHAR(50) COLLATE DATABASE_DEFAULT,buy_sell_flag VARCHAR(1) COLLATE DATABASE_DEFAULT
	)

	SET @sql = '
	INSERT INTO #temp_deals_v
	(
		source_deal_detail_id,
		source_deal_header_id,
		location_id,
		meter_id,
		curve_id,
		term_start,term_end,term_1st_day_month,commodity_id,recorderid,buy_sell_flag
	)
	SELECT distinct sdd.source_deal_detail_id,
		sdd.source_deal_header_id,
		sdd.location_id,
		isnull(sdd.meter_id,smlm.meter_id),
		sdd.curve_id,
		sdd.term_start,sdd.term_end,convert(varchar(8),sdd.term_start,120)+''01'',spcd.commodity_id,mi.recorderid,sdd.buy_sell_flag
	FROM   source_deal_header sdh inner join
		source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id 
		inner join source_Deal_header_template sdht on sdht.template_id=sdh.template_id and isnull(sdht.calculate_position_based_on_actual,''n'')=''y''
		inner join ' +@effected_deals+' f on sdd.source_deal_header_id=f.source_deal_header_id 
		INNER JOIN deal_status_group dsg ON dsg.status_value_id=sdh.deal_status						
		inner JOIN source_minor_location_meter smlm ON  smlm.source_minor_location_id = sdd.location_id
		inner join meter_id mi on mi.meter_id=smlm.meter_id
		left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
		
	'

	exec spa_print @sql
	EXEC(@sql)

	select  mi.source_deal_header_id,mi.location_id,mi.curve_id,mdm.prod_date term_start,
		Sum(ISNULL( mdm.Hr1_15, 0)) + Sum(ISNULL(mdm.Hr1_30,0)) +Sum(ISNULL(mdm.Hr1_45, 0)) + Sum(ISNULL(mdm.Hr1_60, 0)) [hr1],
		Sum(ISNULL(mdm.Hr2_15, 0)) + Sum(ISNULL(mdm.Hr2_30, 0)) + Sum(ISNULL(mdm.Hr2_45, 0)) + Sum(ISNULL(mdm.Hr2_60, 0)) [hr2],
		Sum(ISNULL(mdm.Hr3_15, 0)) + Sum(ISNULL(mdm.Hr3_30, 0))+ Sum(ISNULL(mdm.Hr3_45, 0)) + Sum(ISNULL(mdm.Hr3_60, 0)) [hr3], 
		Sum(ISNULL(mdm.Hr4_15, 0)) + Sum(ISNULL(mdm.Hr4_30, 0)) + Sum(ISNULL(mdm.Hr4_45, 0)) + Sum(ISNULL(mdm.Hr4_60, 0)) [hr4],
		Sum(ISNULL(mdm.Hr5_15, 0)) + Sum(ISNULL(mdm.Hr5_30, 0)) + Sum(ISNULL(mdm.Hr5_45, 0)) + Sum(ISNULL(mdm.Hr5_60, 0)) [hr5],
		Sum(ISNULL(mdm.Hr6_15, 0)) + Sum(ISNULL(mdm.Hr6_30, 0)) + Sum(ISNULL(mdm.Hr6_45, 0)) + Sum(ISNULL(mdm.Hr6_60, 0)) [hr6], 
		Sum(ISNULL(mdm.Hr7_15,0)) + Sum(ISNULL(mdm.Hr7_30, 0)) + Sum(ISNULL(mdm.Hr7_45, 0)) + Sum(ISNULL(mdm.Hr7_60, 0)) [hr7], 
		Sum(ISNULL(mdm.Hr8_15, 0)) + Sum(ISNULL(mdm.Hr8_30, 0)) + Sum(ISNULL(mdm.Hr8_45, 0)) + Sum(ISNULL(mdm.Hr8_60, 0)) [hr8],
		Sum(ISNULL(mdm.Hr9_15, 0)) + Sum(ISNULL(mdm.Hr9_30,0)) + Sum(ISNULL(mdm.Hr9_45, 0)) + Sum(ISNULL(mdm.Hr9_60, 0)) [hr9], 
		Sum(ISNULL(mdm.Hr10_15, 0)) + Sum(ISNULL(mdm.Hr10_30, 0)) + Sum(ISNULL(mdm.Hr10_45, 0)) + Sum(ISNULL(mdm.Hr10_60, 0)) [hr10],
		Sum(ISNULL(mdm.Hr11_15, 0)) + Sum(ISNULL(mdm.Hr11_30,0)) + Sum(ISNULL(mdm.Hr11_45, 0)) + Sum(ISNULL(mdm.Hr11_60, 0)) [hr11],
		Sum(ISNULL(mdm.Hr12_15,0)) + Sum(ISNULL(mdm.Hr12_30, 0)) + Sum(ISNULL(mdm.Hr12_45, 0)) + Sum(ISNULL(mdm.Hr12_60, 0)) [hr12], 
		Sum(ISNULL(mdm.Hr13_15, 0)) + Sum(ISNULL(mdm.Hr13_30, 0)) + Sum(ISNULL(mdm.Hr13_45, 0)) + Sum(ISNULL(mdm.Hr13_60, 0)) [hr13],
		Sum(ISNULL(mdm.Hr14_15, 0)) + Sum(ISNULL(mdm.Hr14_30, 0)) + Sum(ISNULL(mdm.Hr14_45, 0)) + Sum(ISNULL(mdm.Hr14_60,0)) [hr14],
		Sum(ISNULL(mdm.Hr15_15, 0)) + Sum(ISNULL(mdm.Hr15_30, 0)) + Sum(ISNULL(mdm.Hr15_45, 0)) + Sum(ISNULL(mdm.Hr15_60, 0)) [hr15], 
		Sum(ISNULL(mdm.Hr16_15, 0)) + Sum(ISNULL(mdm.Hr16_30, 0)) + Sum(ISNULL(mdm.Hr16_45, 0)) + Sum(ISNULL(mdm.Hr16_60, 0)) [hr16],
		Sum(ISNULL(mdm.Hr17_15, 0)) + Sum(ISNULL(mdm.Hr17_30, 0)) + Sum(ISNULL(mdm.Hr17_45,0)) + Sum(ISNULL(mdm.Hr17_60, 0)) [hr17],
		Sum(ISNULL(mdm.Hr18_15, 0)) + Sum(ISNULL(mdm.Hr18_30, 0)) + Sum(ISNULL(mdm.Hr18_45, 0)) + Sum(ISNULL(mdm.Hr18_60,0)) [hr18], 
		Sum(ISNULL(mdm.Hr19_15, 0)) + Sum(ISNULL(mdm.Hr19_30, 0)) + Sum(ISNULL(mdm.Hr19_45, 0)) + Sum(ISNULL(mdm.Hr19_60, 0)) [hr19],
		Sum(ISNULL(mdm.Hr20_15, 0)) + Sum(ISNULL(mdm.Hr20_30, 0)) + Sum(ISNULL(mdm.Hr20_45, 0)) + Sum(ISNULL(mdm.Hr20_60, 0)) [hr20], 
		Sum(ISNULL(mdm.Hr21_15, 0)) + Sum(ISNULL(mdm.Hr21_30, 0)) + Sum(ISNULL(mdm.Hr21_45, 0)) + Sum(ISNULL(mdm.Hr21_60, 0)) [hr21], 
		Sum(ISNULL(mdm.Hr22_15, 0)) + Sum(ISNULL(mdm.Hr22_30, 0)) + Sum(ISNULL(mdm.Hr22_45, 0)) + Sum(ISNULL(mdm.Hr22_60, 0)) [hr22],
		Sum(ISNULL(mdm.Hr23_15, 0)) + Sum(ISNULL(mdm.Hr23_30, 0)) + Sum(ISNULL(mdm.Hr23_45, 0)) + Sum(ISNULL(mdm.Hr23_60, 0)) [hr23],
		Sum(ISNULL(mdm.Hr24_15, 0)) + Sum(ISNULL(mdm.Hr24_30, 0)) + Sum(ISNULL(mdm.Hr24_45, 0)) + Sum(ISNULL(mdm.Hr24_60,0)) [hr24] ,
		Sum(ISNULL(mdm.Hr25_15, 0)) + Sum(ISNULL(mdm.Hr25_30, 0)) + Sum(ISNULL(mdm.Hr25_45, 0)) + Sum(ISNULL(mdm.Hr25_60,0)) [hr25] 
		into #meter_data_15min     
	FROM #temp_deals_v mi
	inner JOIN mv90_data mv ON mv.meter_id = mi.meter_id and mv.from_date=term_1st_day_month
	inner JOIN mv90_data_mins mdm ON mdm.meter_data_id = mv.meter_data_id 
	group by 	mi.source_deal_header_id,mi.location_id,mi.curve_id,mdm.prod_date
		
	--SELECT * FROM #meter_data_15min

	SELECT             
		td.source_deal_header_id,td.location_id,td.curve_id,mvh.prod_date term_start,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.HR7) hr1,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr8 ) hr2,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.HR9 ) hr3,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.HR10 ) hr4,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr11 ) hr5,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.HR12)  hr6,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr13 ) hr7,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr14 ) hr8,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr15 ) hr9,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr16 ) hr10,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr17 ) hr11,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr18 ) hr12,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr19 ) hr13,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr20 ) hr14,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr21 ) hr15,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr22 ) hr16,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr23 ) hr17,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr24 ) hr18,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * COALESCE(mvh2.Hr1,mvh1.Hr1)) hr19,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * COALESCE(mvh2.Hr2,mvh1.Hr2)) hr20,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * COALESCE(mvh2.Hr3,mvh1.Hr3)) hr21,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * COALESCE(mvh2.Hr4,mvh1.Hr4)) hr22,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * COALESCE(mvh2.Hr5,mvh1.Hr5)) hr23,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * COALESCE(mvh2.Hr6,mvh1.Hr6)) hr24,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr25 ) hr25
	INTO  #meter_data_hr_gas
	 FROM #temp_deals_v td
	inner JOIN mv90_data mv
		ON  mv.meter_id = td.meter_id AND td.term_1st_day_month = mv.from_date
	inner JOIN mv90_data_hour mvh
		ON  mv.meter_data_id = mvh.meter_data_id
	LEFT JOIN mv90_data mv1
		ON  mv1.meter_id = mv.meter_id
		AND mv1.from_date = DATEADD(m, 1, mv.from_date)
	LEFT JOIN mv90_data_hour mvh2
		ON  mvh2.meter_data_id = mv.meter_data_id
		AND mvh2.prod_date -1 = mvh.prod_date
	LEFT JOIN mv90_data_hour mvh1
		ON  mvh1.meter_data_id = mv1.meter_data_id AND DAY(mvh1.prod_date) = 1
	WHERE td.commodity_id=-1
	GROUP BY   td.source_deal_header_id,td.location_id,td.curve_id,mvh.prod_date

	--SELECT * FROM #meter_data_hr_gas

	SELECT             
		td.source_deal_header_id,td.location_id,td.curve_id,mvh.prod_date term_start,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.HR1) hr1,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr2) hr2,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.HR3) hr3,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.HR4) hr4,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr5) hr5,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.HR6) hr6,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr7) hr7,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr8) hr8,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr9) hr9,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr10) hr10,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr11) hr11,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr12) hr12,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr13) hr13,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr14) hr14,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr15) hr15,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr16) hr16,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr17) hr17,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr18) hr18,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr19) hr19,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr20) hr20,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr21) hr21,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr22) hr22,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr23) hr23,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr24) hr24,
		min(CASE WHEN (td.buy_sell_flag='s') THEN -1 ELSE 1 END * mvh.Hr25) hr25
	INTO  #meter_data_hr
	FROM #temp_deals_v td
	inner JOIN mv90_data mv
		ON  mv.meter_id = td.meter_id AND td.term_1st_day_month = mv.from_date
	inner JOIN mv90_data_hour mvh
		ON  mv.meter_data_id = mvh.meter_data_id
	WHERE td.commodity_id<>-1
	GROUP BY   td.source_deal_header_id,td.location_id,td.curve_id,mvh.prod_date

	UPDATE p
	SET 
		hr1 =COALESCE(m15.hr1,h.hr1,gas.hr1,p.hr1),
		hr2 =COALESCE(m15.hr2,h.hr2,gas.hr2,p.hr2),
		hr3 =COALESCE(m15.hr3,h.hr3,gas.hr3,p.hr3),
		hr4 =COALESCE(m15.hr4,h.hr4,gas.hr4,p.hr4),
		hr5 =COALESCE(m15.hr5,h.hr5,gas.hr5,p.hr5),
		hr6 =COALESCE(m15.hr6,h.hr6,gas.hr6,p.hr6),
		hr7 =COALESCE(m15.hr7,h.hr7,gas.hr7,p.hr7),
		hr8 =COALESCE(m15.hr8,h.hr8,gas.hr8,p.hr8), 
		hr9 =COALESCE(m15.hr9,h.hr9,gas.hr9,p.hr9),
		hr10 =COALESCE(m15.hr10,h.hr10,gas.hr10,p.hr10),
		hr11 =COALESCE(m15.hr11,h.hr11,gas.hr11,p.hr11),
		hr12 =COALESCE(m15.hr12,h.hr12,gas.hr12,p.hr12),
		hr13 =COALESCE(m15.hr13,h.hr13,gas.hr13,p.hr13),
		hr14 =COALESCE(m15.hr14,h.hr14,gas.hr14,p.hr14),
		hr15 =COALESCE(m15.hr15,h.hr15,gas.hr15,p.hr15),
		hr16 =COALESCE(m15.hr16,h.hr16,gas.hr16,p.hr16),
		hr17 =COALESCE(m15.hr17,h.hr17,gas.hr17,p.hr17),
		hr18 =COALESCE(m15.hr18,h.hr18,gas.hr18,p.hr18),
		hr19 =COALESCE(m15.hr19,h.hr19,gas.hr19,p.hr19),
		hr20 =COALESCE(m15.hr20,h.hr20,gas.hr20,p.hr20),
		hr21 =COALESCE(m15.hr21,h.hr21,gas.hr21,p.hr21),
		hr22 =COALESCE(m15.hr22,h.hr22,gas.hr22,p.hr22),
		hr23 =COALESCE(m15.hr23,h.hr23,gas.hr23,p.hr23),
		hr24 =COALESCE(m15.hr24,h.hr24,gas.hr24,p.hr24),
		hr25 =COALESCE(m15.hr25,h.hr25,gas.hr25,p.hr25),
		create_ts =GETDATE(),create_user =dbo.fnadbuser()
	FROM report_hourly_position_deal_main p 
	inner join dbo.position_report_group_map g on g.rowid=p.rowid
	inner join #temp_deals_v mi  on p.term_start BETWEEN mi.term_start AND mi.term_end 
		AND p.source_deal_detail_id=mi.source_deal_detail_id
	LEFT JOIN #meter_data_15min m15 ON m15.source_deal_header_id=p.source_deal_header_id AND m15.location_id=g.location_id AND  	m15.curve_id=g.curve_id AND m15.term_start=p.term_start
	LEFT JOIN #meter_data_hr h ON h.source_deal_header_id=p.source_deal_header_id AND h.location_id=g.location_id AND  h.curve_id=g.curve_id AND h.term_start	=p.term_start
	LEFT JOIN #meter_data_hr_gas gas ON gas.source_deal_header_id=p.source_deal_header_id AND gas.location_id=g.location_id AND  gas.curve_id=g.curve_id AND gas.term_start=p.term_start
		
		

	delete source_deal_detail_position from #temp_deals_v t inner join source_deal_detail_position sddp on t.source_deal_detail_id=sddp.source_deal_detail_id


	insert into dbo.source_deal_detail_position(source_deal_detail_id,total_volume)
	 select sdd.source_deal_detail_id,pos.total_volume
	FROM source_deal_detail sdd inner join #temp_deals_v t on t.source_deal_detail_id=sdd.source_deal_detail_id
	cross apply
	(
		SELECT SUM(hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24) total_volume 
		from  report_hourly_position_deal p  	
		WHERE term_start BETWEEN sdd.term_start AND sdd.term_end
			AND source_deal_detail_id = sdd.source_deal_detail_id
	) pos

	insert into dbo.source_deal_detail_position(source_deal_detail_id,total_volume)
	 select sdd.source_deal_detail_id,pos.total_volume
	FROM source_deal_detail sdd  inner join #temp_deals_v t on t.source_deal_detail_id=sdd.source_deal_detail_id
	cross apply
	(
		SELECT SUM(hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24) total_volume 
		from  report_hourly_position_profile p  	
		WHERE  term_start BETWEEN sdd.term_start AND sdd.term_end
			AND source_deal_detail_id = sdd.source_deal_detail_id
	) pos
END	
