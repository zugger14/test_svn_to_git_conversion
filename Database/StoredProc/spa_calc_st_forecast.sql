/****** Object:  StoredProcedure [dbo].[spa_calc_st_forecast]    Script Date: 04/18/2012 18:19:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_st_forecast]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_calc_st_forecast]
GO



/****** Object:  StoredProcedure [dbo].[spa_calc_st_forecast]    Script Date: 04/18/2012 18:19:48 ******/


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




 /**
	Calculate Short Term Forecast.

	Parameters : 
	@group_id : Group Id filter to process
	@process_table : Process Table
	@term_start : Term Start filter to process
	@term_end : Term End filter to process

  */



CREATE PROC [dbo].[spa_calc_st_forecast]
	@group_id VARCHAR(5000),
	@process_table VARCHAR(500) = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL
AS
/*
DECLARE @group_id VARCHAR(5000),@process_table VARCHAR(500)
IF OBJECT_ID(N'tempdb..#deal', N'U') IS NOT NULL
	DROP TABLE #deal
IF OBJECT_ID(N'tempdb..#calculated_deal_values_gas', N'U') IS NOT NULL
	DROP TABLE #calculated_deal_values_gas
IF OBJECT_ID(N'tempdb..#total_postion_deals', N'U') IS NOT NULL
	DROP TABLE #total_postion_deals	
IF OBJECT_ID(N'tempdb..#imported_deals_term_start', N'U') IS NOT NULL
	DROP TABLE #imported_deals_term_start	

IF OBJECT_ID(N'tempdb..#pivoted_calculated_deal_values_gas', N'U') IS NOT NULL
	DROP TABLE #pivoted_calculated_deal_values_gas	

IF OBJECT_ID(N'tempdb..#shifted_hr_gas_deal', N'U') IS NOT NULL
	DROP TABLE #shifted_hr_gas_deal	

IF OBJECT_ID(N'tempdb..#shifted_hr_gas_deals', N'U') IS NOT NULL
	DROP TABLE #shifted_hr_gas_deals	

IF OBJECT_ID(N'tempdb..#ds_date_total', N'U') IS NOT NULL
	DROP TABLE #ds_date_total

IF OBJECT_ID(N'tempdb..#calculated_deal_values_power', N'U') IS NOT NULL
	DROP TABLE #calculated_deal_values_power

IF OBJECT_ID(N'tempdb..#pivoted_calculated_deal_values_power', N'U') IS NOT NULL
	DROP TABLE #pivoted_calculated_deal_values_power

IF OBJECT_ID(N'tempdb..#final_deal_calculate', N'U') IS NOT NULL
	DROP TABLE #final_deal_calculate

IF OBJECT_ID(N'tempdb..#impact_groups', N'U') IS NOT NULL
	DROP TABLE #impact_groups

SET @group_id = '292425'
--*/
--select * from st_forecast_group_header
--select * from static_data_value where type_id=19600
--select * from short_term_forecast_allocation
DECLARE @sql VARCHAR(MAX)
DECLARE @group_ids VARCHAR(5000)
DECLARE @impact_deal_header_ids VARCHAR(MAX)

-- Remove SET @group_name = 'e,w' later as group id will come for the imported data  
CREATE TABLE #impact_groups(group_id INT)

IF @group_id IS NOT NULL
	INSERT INTO #impact_groups
	SELECT  sdv.value_id
	FROM dbo.SplitCommaSeperatedValues(@group_id) scsv
	INNER JOIN static_data_value sdv ON scsv.item = sdv.value_id AND sdv.type_id = 19600
ELSE
	INSERT INTO #impact_groups
	SELECT sdv.value_id
	FROM static_data_value sdv
	WHERE sdv.[type_id] = 19600

/*Get term start of deals from imported data start*/
--added yesterday
CREATE TABLE #imported_deals_term_start (term_start DATETIME)
IF @term_start IS NULL AND @term_end IS NULL
BEGIN
	INSERT INTO #imported_deals_term_start(term_start)
	SELECT DISTINCT term_start 
	FROM 
		st_forecast_hour sfh
		INNER JOIN #impact_groups scsv ON scsv.group_id = sfh.st_forecast_group_id
		
		
	INSERT INTO #imported_deals_term_start (term_start)
	SELECT 
		DISTINCT(term_start) 
	FROM st_forecast_mins sfm
		 INNER JOIN #impact_groups scsv ON scsv.group_id = sfm.st_forecast_group_id	
END
ELSE 
BEGIN
	INSERT INTO #imported_deals_term_start(term_start)
	--SELECT 'tem_start'
	SELECT DATEADD(DAY, (n - 1), @term_start) daily_term_date 
	FROM dbo.seq
	WHERE n <= DATEDIFF(DAY, @term_start, @term_end) + 1
	-- break term start and term_end and insert in term_start ..(daily date break down)
END



--SELECT  * FROM #imported_deals_term_start ORDER BY term_start
/*
* Get term start of deals from imported data end 
* Insert deal id for location
* */
SELECT DISTINCT sdd.source_deal_detail_id, sdh.source_deal_header_id,sfgh.st_forecast_group_id,sdd.location_id,sdd.curve_id
	INTO #deal
FROM source_deal_header sdh 
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN short_term_forecast_mapping stfm ON stfm.location = sdd.location_id
--INNER JOIN #imported_deals_term_start imdts ON imdts.term_start = sdd.term_start
INNER JOIN st_forecast_group_header sfgh ON sfgh.st_forecast_group_header_id = stfm.st_forecast_group_header_id
INNER JOIN #impact_groups scsv ON scsv.group_id = sfgh.st_forecast_group_id
INNER JOIN #imported_deals_term_start idts ON idts.term_start BETWEEN sdd.term_start AND sdd.term_end
INNER JOIN deal_status_group dsg ON dsg.status_value_id = sdh.deal_status
LEFT JOIN short_term_forecast_allocation stfa On stfa.source_deal_header_id = sdh.source_deal_header_id
WHERE
	sdd.physical_financial_flag ='p'
	AND sdh.deal_id NOT LIKE 'Target%'
	AND stfa.source_deal_header_id IS NULL
	
-- Insert deal id for other combination
INSERT INTO #deal(source_deal_detail_id,source_deal_header_id,st_forecast_group_id,location_id,curve_id)
SELECT DISTINCT sdd.source_deal_detail_id,sdh.source_deal_header_id,sfgh.st_forecast_group_id,sdd.location_id,sdd.curve_id
FROM source_deal_header sdh 
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN user_defined_deal_fields uddfs ON uddfs.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN #imported_deals_term_start imdts ON imdts.term_start BETWEEN sdd.term_start AND sdd.term_end
INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddfs.udf_template_id
	AND uddft.field_name = '-5564'--Isprofiled
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id	
INNER JOIN short_term_forecast_mapping stfm ON stfm.commodity_id = spcd.commodity_id
	AND stfm.counterparty_id = sdh.counterparty_id
	AND stfm.IsProfiled = ISNULL(uddfs.udf_value,'n')
	AND stfm.location IS NULL
INNER JOIN st_forecast_group_header sfgh ON sfgh.st_forecast_group_header_id = stfm.st_forecast_group_header_id
INNER JOIN #impact_groups scsv ON scsv.group_id = sfgh.st_forecast_group_id
--INNER JOIN #imported_deals_term_start idts ON idts.term_start BETWEEN sdd.term_start AND sdd.term_end
INNER JOIN deal_status_group dsg ON dsg.status_value_id = sdh.deal_status
LEFT JOIN #deal d ON d.source_deal_header_id = sdh.source_deal_header_id
LEFT JOIN short_term_forecast_mapping stfm1 ON stfm1.location = sdd.location_id
LEFT JOIN short_term_forecast_allocation stfa On stfa.source_deal_header_id = sdh.source_deal_header_id
WHERE --NOT EXISTS (SELECT source_deal_header_id FROM #deal WHERE source_deal_header_id = sdh.source_deal_header_id)
	d.source_deal_header_id IS NULL
	AND sdd.physical_financial_flag ='p'
	AND sdh.deal_id NOT LIKE 'Target%'
	AND stfm1.location IS NULL
	AND stfa.source_deal_header_id IS NULL
	
CREATE INDEX INDX_1 ON #deal(source_deal_header_id,location_id,curve_id)





--RETURN
/*
* Get deals from report_hourly_position_deal
* Insert into #calculated_deal_values temp table	 
*/
SELECT  rhpd.term_start,
		SUM(rhpd.hr1) [hr1],
		SUM(rhpd.hr2) [hr2],
		SUM(rhpd.hr3) [hr3],
		SUM(rhpd.hr4) [hr4],
		SUM(rhpd.hr5) [hr5],
		SUM(rhpd.hr6) [hr6],
		SUM(rhpd.hr7) [hr7],
		SUM(rhpd.hr8) [hr8],
		SUM(rhpd.hr9) [hr9],
		SUM(rhpd.hr10) [hr10],
		SUM(rhpd.hr11) [hr11],
		SUM(rhpd.hr12) [hr12],
		SUM(rhpd.hr13) [hr13],
		SUM(rhpd.hr14) [hr14],
		SUM(rhpd.hr15) [hr15],
		SUM(rhpd.hr16) [hr16],
		SUM(rhpd.hr17) [hr17],
		SUM(rhpd.hr18) [hr18],
		SUM(rhpd.hr19) [hr19],
		SUM(rhpd.hr20) [hr20],
		SUM(rhpd.hr21) [hr21],
		SUM(rhpd.hr22) [hr22],
		SUM(rhpd.hr23) [hr23],
		SUM(rhpd.hr24) [hr24],
		SUM(rhpd.hr25) [hr25],
		MAX(rhpd.deal_volume_uom_id) [uom],
		st_forecast_group_id
INTO #total_postion_deals 
FROM report_hourly_position_deal rhpd 
INNER JOIN #deal d ON rhpd.source_deal_detail_id = d.source_deal_detail_id
INNER JOIN source_deal_detail sdd ON rhpd.term_start BETWEEN sdd.term_start AND sdd.term_end 
	AND rhpd.source_deal_detail_id=sdd.source_deal_detail_id
INNER JOIN #imported_deals_term_start idts ON idts.term_start = rhpd.term_start

GROUP BY rhpd.term_start,st_forecast_group_id



/* 
* GET DEALS FROM report_hourly_position_profile
* Insert into #calculated_deal_values temp table
*/	
INSERT INTO #total_postion_deals
SELECT	rhpd.term_start,
		SUM(rhpd.hr1) [hr1],
		SUM(rhpd.hr2) [hr2],
		SUM(rhpd.hr3) [hr3],
		SUM(rhpd.hr4) [hr4],
		SUM(rhpd.hr5) [hr5],
		SUM(rhpd.hr6) [hr6],
		SUM(rhpd.hr7) [hr7],
		SUM(rhpd.hr8) [hr8],
		SUM(rhpd.hr9) [hr9],
		SUM(rhpd.hr10) [hr10],
		SUM(rhpd.hr11) [hr11],
		SUM(rhpd.hr12) [hr12],
		SUM(rhpd.hr13) [hr13],
		SUM(rhpd.hr14) [hr14],
		SUM(rhpd.hr15) [hr15],
		SUM(rhpd.hr16) [hr16],
		SUM(rhpd.hr17) [hr17],
		SUM(rhpd.hr18) [hr18],
		SUM(rhpd.hr19) [hr19],
		SUM(rhpd.hr20) [hr20],
		SUM(rhpd.hr21) [hr21],
		SUM(rhpd.hr22) [hr22],
		SUM(rhpd.hr23) [hr23],
		SUM(rhpd.hr24) [hr24],
		SUM(rhpd.hr25) [hr25],
		MAX(rhpd.deal_volume_uom_id) [uom],
		st_forecast_group_id		
FROM report_hourly_position_profile rhpd 
INNER JOIN #deal d ON rhpd.source_deal_detail_id = d.source_deal_detail_id
INNER JOIN source_deal_detail sdd ON rhpd.term_start BETWEEN sdd.term_start AND sdd.term_end 
	AND rhpd.source_deal_detail_id=sdd.source_deal_detail_id
INNER JOIN #imported_deals_term_start idts ON idts.term_start = rhpd.term_start
GROUP BY rhpd.term_start,st_forecast_group_id




SELECT  rhpd.term_start,
		stfa.source_deal_header_id,
		((MAX(sfh.hr1) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr1)) * MAX(stfa.percentage_allocation) [Hr1],
		((MAX(sfh.hr2) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr2)) * MAX(stfa.percentage_allocation) [Hr2],
		((MAX(sfh.hr3) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr3)) * MAX(stfa.percentage_allocation) [Hr3],
		((MAX(sfh.hr4) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr4)) * MAX(stfa.percentage_allocation) [Hr4],
		((MAX(sfh.hr5) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr5)) * MAX(stfa.percentage_allocation) [Hr5],
		((MAX(sfh.hr6) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr6)) * MAX(stfa.percentage_allocation) [Hr6],
		((MAX(sfh.hr7) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr7)) * MAX(stfa.percentage_allocation) [Hr7],
		((MAX(sfh.hr8) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr8)) * MAX(stfa.percentage_allocation) [Hr8],
		((MAX(sfh.hr9) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr9)) * MAX(stfa.percentage_allocation) [Hr9],
		((MAX(sfh.hr10) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr10)) * MAX(stfa.percentage_allocation) [Hr10],
		((MAX(sfh.hr11) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr11)) * MAX(stfa.percentage_allocation) [Hr11],
		((MAX(sfh.hr12) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr12)) * MAX(stfa.percentage_allocation) [Hr12],
		((MAX(sfh.hr13) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr13)) * MAX(stfa.percentage_allocation) [Hr13],
		((MAX(sfh.hr14) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr14)) * MAX(stfa.percentage_allocation) [Hr14],
		((MAX(sfh.hr15) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr15)) * MAX(stfa.percentage_allocation) [Hr15],
		((MAX(sfh.hr16) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr16)) * MAX(stfa.percentage_allocation) [Hr16],
		((MAX(sfh.hr17) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr17)) * MAX(stfa.percentage_allocation) [Hr17],
		((MAX(sfh.hr18) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr18)) * MAX(stfa.percentage_allocation) [Hr18],
		((MAX(sfh.hr19) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr19)) * MAX(stfa.percentage_allocation) [Hr19],
		((MAX(sfh.hr20) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr20)) * MAX(stfa.percentage_allocation) [Hr20],
		((MAX(sfh.hr21) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr21)) * MAX(stfa.percentage_allocation) [Hr21],
		((MAX(sfh.hr22) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr22)) * MAX(stfa.percentage_allocation) [Hr22],
		((MAX(sfh.hr23) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr23)) * MAX(stfa.percentage_allocation) [Hr23],
		((MAX(sfh.hr24) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.hr24)) * MAX(stfa.percentage_allocation) [Hr24],
		((MAX(sfh.hr25) * MAX(ISNULL(rvuc.conversion_factor,1)) * MAX(sfgh.multiplier)) - MAX(rhpd.Hr25)) * MAX(stfa.percentage_allocation) [Hr25],
		MAX(add_dst_hour) AS add_dst_hour, 
		stfa.percentage_allocation AS percentage_allocation,
		--, ISNULL(rvuc.conversion_factor,1)
		--, sfgh.uom_id
		--, rhpd.uom
		-1 AS commodity_id -- gas
	INTO #calculated_deal_values_gas	
FROM #total_postion_deals rhpd 
OUTER APPLY(SELECT add_dst_hour 
            FROM hour_block_term hbt 
			INNER JOIN source_price_curve_def spcd ON hbt.block_define_id = spcd.block_define_id	
				AND hbt.block_type = 12000
			WHERE DATEADD(day,-1,hbt.term_date) = rhpd.term_start) hbt 
INNER JOIN st_forecast_group_header sfgh ON sfgh.st_forecast_group_id = rhpd.st_forecast_group_id
INNER JOIN st_forecast_hour sfh ON sfh.term_start = rhpd.term_start AND sfh.st_forecast_group_id = sfgh.st_forecast_group_id
INNER JOIN short_term_forecast_allocation stfa ON stfa.st_forecast_group_id = sfh.st_forecast_group_id
INNER JOIN rec_volume_unit_conversion rvuc ON rvuc.from_source_uom_id = sfgh.uom_id AND rvuc.to_source_uom_id = rhpd.uom
GROUP BY rhpd.term_start
		--, add_dst_hour
		, stfa.source_deal_header_id
		, stfa.percentage_allocation
		, ISNULL(rvuc.conversion_factor,1)
		--, sfgh.multiplier
		--, sfgh.uom_id
		--, rhpd.uom

/* pivot table for calculated gas deals start */
SELECT term_start, REPLACE(Hr, 'hr', '') Hr, total, add_dst_hour, percentage_allocation, source_deal_header_id,commodity_id
	INTO #pivoted_calculated_deal_values_gas
FROM (SELECT term_start, Hr1, Hr2, Hr3, Hr4
			, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10
			, Hr11, Hr12, Hr13, Hr14, Hr15
			, Hr16, Hr17, Hr18, Hr19, Hr20
			, (Hr21-ISNULL(Hr25,0)) Hr21, Hr22, Hr23, Hr24, Hr25, add_dst_hour, percentage_allocation, source_deal_header_id,commodity_id
		FROM #calculated_deal_values_gas
	) p
	UNPIVOT
	(total FOR Hr IN (Hr1, Hr2, Hr3, Hr4, Hr5
					, Hr6, Hr7, Hr8, Hr9, Hr10
					, Hr11, Hr12, Hr13, Hr14, Hr15
					, Hr16, Hr17, Hr18, Hr19, Hr20
					, Hr21, Hr22, Hr23, Hr24, Hr25)
	) AS unpvt	




/* for DST calculation total shift */
CREATE TABLE #ds_date_total (dst_term_start DATETIME,term_start DATETIME, total NUMERIC(30, 18))
INSERT INTO #ds_date_total(dst_term_start, term_start, total)
SELECT DATEADD(DAY, 1, term_start), term_start,total FROM #pivoted_calculated_deal_values_gas WHERE Hr = 25 AND total <> 0



--RETURN
/* shift hr for gas data end */	
/* pivot table for calculated gas deals end */	
/* for hourly data end -gas */

/* for min data start*/
SELECT  rhpd.term_start,
		stfa.source_deal_header_id,
		(MAX((sfm.hr1_15 + sfm.hr1_30 + sfm.hr1_45 + sfm.hr1_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr1)) * MAX(stfa.percentage_allocation) [Hr1],
		(MAX((sfm.hr2_15 + sfm.hr2_30 + sfm.hr2_45 + sfm.hr2_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr2)) * MAX(stfa.percentage_allocation) [Hr2],
		(MAX((sfm.hr3_15 + sfm.hr3_30 + sfm.hr3_45 + sfm.hr3_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr3)) * MAX(stfa.percentage_allocation) [Hr3],
		(MAX((sfm.hr4_15 + sfm.hr4_30 + sfm.hr4_45 + sfm.hr4_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr4)) * MAX(stfa.percentage_allocation) [Hr4],
		(MAX((sfm.hr5_15 + sfm.hr5_30 + sfm.hr5_45 + sfm.hr5_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr5)) * MAX(stfa.percentage_allocation) [Hr5],
		(MAX((sfm.hr6_15 + sfm.hr6_30 + sfm.hr6_45 + sfm.hr6_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr6)) * MAX(stfa.percentage_allocation) [Hr6],
		(MAX((sfm.hr7_15 + sfm.hr7_30 + sfm.hr7_45 + sfm.hr7_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr7)) * MAX(stfa.percentage_allocation) [Hr7],
		(MAX((sfm.hr8_15 + sfm.hr8_30 + sfm.hr8_45 + sfm.hr8_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr8)) * MAX(stfa.percentage_allocation) [Hr8],
		(MAX((sfm.hr9_15 + sfm.hr9_30 + sfm.hr9_45 + sfm.hr9_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr9)) * MAX(stfa.percentage_allocation) [Hr9],
		(MAX((sfm.hr10_15 + sfm.hr10_30 + sfm.hr10_45 + sfm.hr10_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr10)) * MAX(stfa.percentage_allocation) [Hr10],
		(MAX((sfm.hr11_15 + sfm.hr11_30 + sfm.hr11_45 + sfm.hr11_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr11)) * MAX(stfa.percentage_allocation) [Hr11],
		(MAX((sfm.hr12_15 + sfm.hr12_30 + sfm.hr12_45 + sfm.hr12_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr12)) * MAX(stfa.percentage_allocation) [Hr12],
		(MAX((sfm.hr13_15 + sfm.hr13_30 + sfm.hr13_45 + sfm.hr13_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr13)) * MAX(stfa.percentage_allocation) [Hr13],
		(MAX((sfm.hr14_15 + sfm.hr14_30 + sfm.hr14_45 + sfm.hr14_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr14)) * MAX(stfa.percentage_allocation) [Hr14],
		(MAX((sfm.hr15_15 + sfm.hr15_30 + sfm.hr15_45 + sfm.hr15_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr15)) * MAX(stfa.percentage_allocation) [Hr15],
		(MAX((sfm.hr16_15 + sfm.hr16_30 + sfm.hr16_45 + sfm.hr16_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr16)) * MAX(stfa.percentage_allocation) [Hr16],
		(MAX((sfm.hr17_15 + sfm.hr17_30 + sfm.hr17_45 + sfm.hr17_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr17)) * MAX(stfa.percentage_allocation) [Hr17],
		(MAX((sfm.hr18_15 + sfm.hr18_30 + sfm.hr18_45 + sfm.hr18_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr18)) * MAX(stfa.percentage_allocation) [Hr18],
		(MAX((sfm.hr19_15 + sfm.hr19_30 + sfm.hr19_45 + sfm.hr19_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr19)) * MAX(stfa.percentage_allocation) [Hr19],
		(MAX((sfm.hr20_15 + sfm.hr20_30 + sfm.hr20_45 + sfm.hr20_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr20)) * MAX(stfa.percentage_allocation) [Hr20],
		(MAX((sfm.hr21_15 + sfm.hr21_30 + sfm.hr21_45 + sfm.hr21_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr21)) * MAX(stfa.percentage_allocation) [Hr21],
		(MAX((sfm.hr22_15 + sfm.hr22_30 + sfm.hr22_45 + sfm.hr22_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr22)) * MAX(stfa.percentage_allocation) [Hr22],
		(MAX((sfm.hr23_15 + sfm.hr23_30 + sfm.hr23_45 + sfm.hr23_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr23)) * MAX(stfa.percentage_allocation) [Hr23],
		(MAX((sfm.hr24_15 + sfm.hr24_30 + sfm.hr24_45 + sfm.hr24_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.hr24)) * MAX(stfa.percentage_allocation) [Hr24],
		(MAX((sfm.hr25_15 + sfm.hr25_30 + sfm.hr25_45 + sfm.hr25_60) / 4) * (MAX(ISNULL(rvuc.conversion_factor,1))) * (MAX(sfgh.multiplier)) - MAX(rhpd.Hr25)) * MAX(stfa.percentage_allocation) [Hr25],
		MAX(add_dst_hour) AS add_dst_hour, 
		stfa.percentage_allocation AS percentage_allocation,
		-2 AS commodity_id
	INTO #calculated_deal_values_power
	FROM #total_postion_deals rhpd 
	OUTER APPLY(SELECT add_dst_hour FROM  hour_block_term hbt 
				INNER JOIN source_price_curve_def spcd ON hbt.block_define_id = spcd.block_define_id	
					AND hbt.block_type = 12000
				WHERE hbt.term_date = rhpd.term_start) hbt 
	INNER JOIN st_forecast_group_header sfgh ON sfgh.st_forecast_group_id = rhpd.st_forecast_group_id
	INNER JOIN st_forecast_mins sfm ON sfm.term_start = rhpd.term_start AND sfm.st_forecast_group_id = sfgh.st_forecast_group_id
	INNER JOIN short_term_forecast_allocation stfa ON stfa.st_forecast_group_id = sfm.st_forecast_group_id
	LEFT JOIN rec_volume_unit_conversion rvuc ON rvuc.from_source_uom_id = sfgh.uom_id AND rvuc.to_source_uom_id = rhpd.uom
	GROUP BY rhpd.term_start
			--, add_dst_hour
			, stfa.source_deal_header_id
			, stfa.percentage_allocation
/* for min data end */



SELECT term_start, REPLACE(Hr, 'hr', '') Hr, total, add_dst_hour, percentage_allocation, source_deal_header_id,commodity_id
	INTO #pivoted_calculated_deal_values_power
FROM (SELECT term_start, Hr1, Hr2, (Hr3-ISNULL(Hr25,0)) Hr3, Hr4
			, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10
			, Hr11, Hr12, Hr13, Hr14, Hr15
			, Hr16, Hr17, Hr18, Hr19, Hr20
			, Hr21, Hr22, Hr23, Hr24, Hr25, add_dst_hour, percentage_allocation, source_deal_header_id,commodity_id
		FROM #calculated_deal_values_power
	) p
	UNPIVOT
	(total FOR Hr IN (Hr1, Hr2, Hr3, Hr4, Hr5
					, Hr6, Hr7, Hr8, Hr9, Hr10
					, Hr11, Hr12, Hr13, Hr14, Hr15
					, Hr16, Hr17, Hr18, Hr19, Hr20
					, Hr21, Hr22, Hr23, Hr24, Hr25)
	) AS unpvt

/* pivot table for calculated deals end */	

/* Join gas and power into same table start */
SELECT * 
INTO #final_deal_calculate
FROM #pivoted_calculated_deal_values_power
UNION ALL
SELECT * FROM #pivoted_calculated_deal_values_gas



/* Join gas and power into same table end */
--select * from #final_deal_calculate where source_deal_header_id=131845
/* Delete and Insert in source_deal_detail_hour table */
--EXEC  spa_calc_st_forecast 'e', 'dbo.adiha.process_123321123'
DELETE sddh 
FROM #final_deal_calculate fdc
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = fdc.source_deal_header_id
INNER JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
WHERE  sddh.term_date =  fdc.term_start
	AND fdc.hr = sddh.hr




---#### For Gas Hour, extra hour will be added in the 21 hour instead of 3rd hour

INSERT INTO source_deal_detail_hour(source_deal_detail_id, term_date, hr, is_dst, volume, price, formula_id)
SELECT	sdd.source_deal_detail_id,
		fdc.term_start,
		CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN CASE WHEN mv.id IS NOT NULL THEN 3 ELSE 21 END ELSE fdc.Hr END [hr],
		CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN 1 ELSE 0 END AS [is_dst],
		SUM(fdc.total) [volume],
		NULL AS [price],
		NULL AS [formula_id]
FROM #final_deal_calculate fdc
INNER JOIN source_deal_detail sdd ON 
	YEAR(sdd.term_start) = YEAR(fdc.term_start)
	AND MONTH(sdd.term_start) = MONTH(fdc.term_start) and fdc.source_deal_header_id = sdd.source_deal_header_id
LEFT JOIN mv90_DST mv ON mv.date = fdc.term_start	
	AND mv.insert_delete = 'i' AND commodity_id <> -1
LEFT JOIN mv90_DST mv1 ON mv1.date = DATEADD(DAY,1,fdc.term_start)
	AND mv1.insert_delete = 'i' AND commodity_id = -1
	
WHERE ((add_dst_hour > 0 AND fdc.Hr = 25) OR (fdc.Hr <> 25))
GROUP BY sdd.source_deal_detail_id,
		fdc.term_start,
		CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN CASE WHEN mv.id IS NOT NULL THEN 3 ELSE 21 END ELSE fdc.Hr END,
		CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN 1 ELSE 0 END
	
	



--######## Calculate the Position

DECLARE @spa VARCHAR(MAX)
DECLARE	@job_name VARCHAR(150)
DECLARE	@user_login_id VARCHAR(30)
DECLARE	@effected_deals VARCHAR(150)
DECLARE	@st VARCHAR(MAX)
DECLARE	@process_id VARCHAR(100) 

SET @user_login_id = dbo.FNADBUser()
SET @process_id = dbo.FNAGetNewID()
SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
SET @st = 'CREATE TABLE ' + @effected_deals + '(source_deal_header_id INT, [action] VARCHAR(1)) '
exec spa_print @st
EXEC(@st)

--Change here to select the required deals
SET @st = 'INSERT INTO ' + @effected_deals  
			+ ' SELECT DISTINCT stfa.source_deal_header_id, ''u'' 
			FROM  st_forecast_group_header sfgh
			INNER JOIN short_term_forecast_allocation stfa ON sfgh.st_forecast_group_id = stfa.st_forecast_group_id
			INNER JOIN #impact_groups scsv ON scsv.group_id = sfgh.st_forecast_group_id'
exec spa_print @st
EXEC(@st)

SET @job_name = 'calc_short_term_forecast' + @process_id
--RETURN -- remove return later, kept for now as [spa_deal_position_breakdown] is displaying error
EXEC [dbo].[spa_deal_position_breakdown] 'i', NULL, @user_login_id, @process_id

SET @spa = 'spa_update_deal_total_volume NULL, ''' + @process_id + ''', 0, 1, ''' + @user_login_id + ''''	
EXEC spa_print @spa
EXEC (@spa)



