IF OBJECT_ID(N'[dbo].[spa_deal_volume_hierarchy]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_volume_hierarchy]
GO
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author: rgiri@pioneersolutionsglobal.com
-- Create date: 2013-10-07
-- Description: report operations for  deal_volume
 
-- Params: EXEC spa_deal_volume_hierarchy 7126, '2012-08-01', '2012-08-31', 982, 'f,d,a' 
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================

CREATE PROC [dbo].[spa_deal_volume_hierarchy]
	@source_deal_deatil VARCHAR(100) = NULL,
    @term_start VARCHAR(10) = NULL,
	@term_end VARCHAR(10) = NULL,
	@granularity VARCHAR(100) = NULL,
	@volume_type VARCHAR(100) = NULL,
	@flag char(1),
	@report_id INT = NULL,
	@report_type char(1) = NULL
	 
AS 

DECLARE @sql VARCHAR(MAX)
DECLARE @report_granularity INT

--SET @source_deal_deatil = 7126
--SET @term_start = '2012-08-01'
--SET @term_end = '2012-08-31'
--SET @granularity = 980
SET @report_granularity = @granularity
--SET @volume_type = 'f,d,a'


IF @flag = 'h'
BEGIN

IF @granularity NOT IN(987)
	SET @granularity = 982
IF OBJECT_ID(N'tempdb..#forecast_volume', N'U') IS NOT NULL 	DROP TABLE #forecast_volume

SELECT term_start, CAST(REPLACE(Hr, 'hr', '')-1 AS VARCHAR) Hr ,period mins, total,add_dst_hour,source_deal_header_id,period, granularity
INTO #forecast_volume
FROM (
		SELECT rhp.term_start, Hr1, Hr2, (Hr3-ISNULL(Hr25,0)) Hr3, Hr4
			, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10
			, Hr11, Hr12, Hr13, Hr14, Hr15
			, Hr16, Hr17, Hr18, Hr19, Hr20
			, Hr21 Hr21, Hr22, Hr23, Hr24, Hr25, dst.[hour] add_dst_hour
			,rhp.source_deal_header_id,rhp.period, rhp.granularity
		FROM report_hourly_position_profile rhp
			 INNER JOIN source_deal_detail	sdd ON sdd.source_deal_header_id = rhp.source_deal_header_id
				AND sdd.location_id = rhp.location_id
				AND sdd.curve_id = rhp.curve_id
				AND rhp.term_start BETWEEN sdd.term_start AND sdd.term_end		
			LEFT JOIN mv90_dst dst ON dst.[date] = rhp.term_start AND dst.insert_delete = 'i'							
		WHERE
			sdd.source_deal_detail_id IN(@source_deal_deatil)
			AND sdd.term_start >=@term_start AND sdd.term_end<=@term_end
			AND rhp.granularity = @granularity
	) p
	UNPIVOT
	(total FOR Hr IN (Hr1, Hr2, Hr3, Hr4, Hr5
					, Hr6, Hr7, Hr8, Hr9, Hr10
					, Hr11, Hr12, Hr13, Hr14, Hr15
					, Hr16, Hr17, Hr18, Hr19, Hr20
					, Hr21, Hr22, Hr23, Hr24, Hr25)
	) AS unpvt		


IF OBJECT_ID(N'tempdb..#deal_volume', N'U') IS NOT NULL 	DROP TABLE #deal_volume

SELECT term_start, CAST(REPLACE(Hr, 'hr', '')-1 AS VARCHAR) Hr ,period mins, total,add_dst_hour,source_deal_header_id,period, granularity
INTO #deal_volume
FROM (
	
	SELECT 
		hb.term_date term_start,
		hb.hr1* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr1,
		hb.hr2* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr2,
		hb.hr3* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr3,
		hb.hr4* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr4,
		hb.hr5* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr5,
		hb.hr6* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr6,
		hb.hr7* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr7,
		hb.hr8* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr8,
		hb.hr9* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr9,
		hb.hr10* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr10,
		hb.hr11* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr11,
		hb.hr12* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr12,
		hb.hr13* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr13,
		hb.hr14* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr14,
		hb.hr15* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr15,
		hb.hr16* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr16,
		hb.hr17* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr17,
		hb.hr18* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr18,
		hb.hr19* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr19,
		hb.hr20* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr20,
		hb.hr21* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr21,
		hb.hr22* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr22,
		hb.hr23* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr23,
		hb.hr24* CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr24,
		hb.hr3 * CASE sdd.deal_volume_frequency WHEN 'h' THEN sdd.deal_volume  WHEN 'd' THEN sdd.deal_volume/hb.volume_mult WHEN 'm' THEN sdd.deal_volume/(hb.volume_mult*DATEDIFF(dd,sdd.term_start,sdd.term_end)) END hr25,
		hb.add_dst_hour,sdh.source_deal_header_id,0 period, 982 granularity
 FROM  
			source_deal_header sdh  with (nolock) 
			INNER JOIN source_system_book_map ssbm  with (nolock) on sdh.source_system_book_id1=ssbm.source_system_book_id1
			and sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3
			 and sdh.source_system_book_id4=ssbm.source_system_book_id4
			INNER JOIN source_deal_detail sdd  with (nolock) ON sdh.source_deal_header_id=sdd.source_deal_header_id --  and sdd.curve_id is not null
			LEFT JOIN source_price_curve_def spcd  with (nolock) ON spcd.source_curve_def_id=sdd.curve_id
			LEFT JOIN source_price_curve_def spcd1 with (nolock) ON spcd1.source_curve_def_id=spcd.settlement_curve_id
			outer apply ( select nullif(sum(volume_mult),0) term_hours from hour_block_term (nolock) where
					term_date between sdd.term_start and sdd.term_end
					AND block_type = COALESCE(spcd.block_type,sdh.block_type,12000)
					AND block_define_id = COALESCE(spcd.block_define_id,300501)
				) hb_term		
			outer apply (
				select sum(volume_mult) term_no_hrs from hour_block_term hbt (nolock) inner join (select distinct exp_date from holiday_group h (nolock) where  h.hol_group_value_id=ISNULL(spcd1.exp_calendar_id,spcd.exp_calendar_id) and h.exp_date between sdd.term_start  and sdd.term_END ) ex on ex.exp_date=hbt.term_date
				where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and sdd.physical_financial_flag='f' and hbt.block_define_id=COALESCE(spcd.block_define_id,300501)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between sdd.term_start  and sdd.term_END
			) term_hrs_exp
			LEFT JOIN hour_block_term hb with (nolock) on hb.block_define_id=COALESCE(spcd.block_define_id,sdh.block_define_id,300501)  
				and  hb.block_type=COALESCE(spcd.block_type,sdh.block_type,12000)
				and hb.term_date between sdd.term_start and sdd.term_end
			left join rec_volume_unit_conversion conv (nolock) on conv.from_source_uom_id=sdd.deal_volume_uom_id
					and conv.to_source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)
			outer apply  (select distinct exp_date from holiday_group h (nolock) where h.exp_date=hb.term_date and h.hol_group_value_id=ISNULL(spcd1.exp_calendar_id,spcd.exp_calendar_id) and h.exp_date between sdd.term_start  and sdd.term_END ) hg  
			LEFT OUTER JOIN hour_block_term hb1 (nolock) ON hb1.block_type=hb.block_type
				AND hb1.block_define_id=hb.block_define_id
				AND hb1.term_date-1=hb.term_date
			LEFT JOIN  source_deal_header_template sdht (nolock) on sdh.template_id=sdht.template_id			
			where  1=1 
				AND sdd.source_deal_detail_id=10276 			
			AND sdd.term_start >=@term_start AND sdd.term_end<=@term_end
			
	) p
	UNPIVOT
	(total FOR Hr IN (Hr1, Hr2, Hr3, Hr4, Hr5
					, Hr6, Hr7, Hr8, Hr9, Hr10
					, Hr11, Hr12, Hr13, Hr14, Hr15
					, Hr16, Hr17, Hr18, Hr19, Hr20
					, Hr21, Hr22, Hr23, Hr24, Hr25)
	) AS unpvt		


IF OBJECT_ID(N'tempdb..#actual_volume', N'U') IS NOT NULL 	DROP TABLE #actual_volume
--select * from report_hourly_position_deal where granularity=987

-- for 15 minutes
SELECT term_start, CAST(CASE WHEN add_dst_hour>0 THEN add_dst_hour ELSE REPLACE(SUBSTRING(Hr,0,CHARINDEX('_',Hr,0)),'hr','') END -1 AS VARCHAR) Hr, CAST(SUBSTRING(hr,CHARINDEX('_',Hr,0)+1,2)-15 AS VARCHAR) mins, total,add_dst_hour,source_deal_header_id,SUBSTRING(hr,CHARINDEX('_',Hr,0)+1,2)-15 period
INTO #actual_volume
FROM (
		SELECT m.prod_date term_start, 		
			m.[Hr1_15], m.[Hr1_30],m.[Hr1_45], m.[Hr1_60],
			m.[Hr2_15], m.[Hr2_30], m.[Hr2_45], m.[Hr2_60], 
			m.[Hr3_15], m.[Hr3_30], m.[Hr3_45], m.[Hr3_60], 
			m.[Hr4_15], m.[Hr4_30], m.[Hr4_45], m.[Hr4_60], 
			m.[Hr5_15], m.[Hr5_30], m.[Hr5_45], m.[Hr5_60], 
			m.[Hr6_15], m.[Hr6_30], m.[Hr6_45], m.[Hr6_60], 
			m.[Hr7_15], m.[Hr7_30], m.[Hr7_45], m.[Hr7_60], 
			m.[Hr8_15], m.[Hr8_30], m.[Hr8_45], m.[Hr8_60], 
			m.[Hr9_15], m.[Hr9_30], m.[Hr9_45], m.[Hr9_60], 
			m.[Hr10_15], m.[Hr10_30], m.[Hr10_45], m.[Hr10_60], 
			m.[Hr11_15], m.[Hr11_30], m.[Hr11_45], m.[Hr11_60], 
			m.[Hr12_15], m.[Hr12_30], m.[Hr12_45], m.[Hr12_60], 
			m.[Hr13_15], m.[Hr13_30], m.[Hr13_45], m.[Hr13_60], 
			m.[Hr14_15], m.[Hr14_30], m.[Hr14_45], m.[Hr14_60], 
			m.[Hr15_15], m.[Hr15_30], m.[Hr15_45], m.[Hr15_60], 
			m.[Hr16_15], m.[Hr16_30], m.[Hr16_45], m.[Hr16_60], 
			m.[Hr17_15], m.[Hr17_30], m.[Hr17_45], m.[Hr17_60], 
			m.[Hr18_15], m.[Hr18_30], m.[Hr18_45], m.[Hr18_60], 
			m.[Hr19_15], m.[Hr19_30], m.[Hr19_45], m.[Hr19_60], 
			m.[Hr20_15], m.[Hr20_30], m.[Hr20_45], m.[Hr20_60], 
			m.[Hr21_15], m.[Hr21_30], m.[Hr21_45], m.[Hr21_60], 
			m.[Hr22_15], m.[Hr22_30], m.[Hr22_45], m.[Hr22_60], 
			m.[Hr23_15], m.[Hr23_30], m.[Hr23_45], m.[Hr23_60], 
			m.[Hr24_15], m.[Hr24_30], m.[Hr24_45], m.[Hr24_60], 
			m.[Hr25_15], m.[Hr25_30], m.[Hr25_45], m.[Hr25_60], dst.[hour] add_dst_hour
			,sdd.source_deal_header_id
		FROM	
			source_deal_detail	sdd 
			INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sdd.location_id
			INNER JOIN mv90_data mv ON mv.meter_id = ISNULL(sdd.meter_id, smlm.meter_id)			
			INNER JOIN recorder_properties rp ON rp.meter_id = mv.meter_id AND rp.channel = mv.channel
			INNER JOIN mv90_data_mins m ON m.meter_data_id = mv.meter_data_id	
				AND m.prod_date BETWEEN sdd.term_start AND sdd.term_end
			LEFT JOIN mv90_dst dst ON dst.[date] = m.prod_date AND dst.insert_delete = 'i'		
		WHERE
			sdd.source_deal_detail_id IN(@source_deal_deatil)
			AND sdd.term_start >=@term_start AND sdd.term_end<=@term_end
			AND @granularity = 987
	) p
	UNPIVOT
	(total FOR Hr IN (
		[Hr1_15], [Hr1_30],[Hr1_45], [Hr1_60],
		[Hr2_15], [Hr2_30], [Hr2_45], [Hr2_60], 
		[Hr3_15], [Hr3_30], [Hr3_45], [Hr3_60], 
		[Hr4_15], [Hr4_30], [Hr4_45], [Hr4_60], 
		[Hr5_15], [Hr5_30], [Hr5_45], [Hr5_60], 
		[Hr6_15], [Hr6_30], [Hr6_45], [Hr6_60], 
		[Hr7_15], [Hr7_30], [Hr7_45], [Hr7_60], 
		[Hr8_15], [Hr8_30], [Hr8_45], [Hr8_60], 
		[Hr9_15], [Hr9_30], [Hr9_45], [Hr9_60], 
		[Hr10_15], [Hr10_30], [Hr10_45], [Hr10_60], 
		[Hr11_15], [Hr11_30], [Hr11_45], [Hr11_60], 
		[Hr12_15], [Hr12_30], [Hr12_45], [Hr12_60], 
		[Hr13_15], [Hr13_30], [Hr13_45], [Hr13_60], 
		[Hr14_15], [Hr14_30], [Hr14_45], [Hr14_60], 
		[Hr15_15], [Hr15_30], [Hr15_45], [Hr15_60], 
		[Hr16_15], [Hr16_30], [Hr16_45], [Hr16_60], 
		[Hr17_15], [Hr17_30], [Hr17_45], [Hr17_60], 
		[Hr18_15], [Hr18_30], [Hr18_45], [Hr18_60], 
		[Hr19_15], [Hr19_30], [Hr19_45], [Hr19_60], 
		[Hr20_15], [Hr20_30], [Hr20_45], [Hr20_60], 
		[Hr21_15], [Hr21_30], [Hr21_45], [Hr21_60], 
		[Hr22_15], [Hr22_30], [Hr22_45], [Hr22_60], 
		[Hr23_15], [Hr23_30], [Hr23_45], [Hr23_60], 
		[Hr24_15], [Hr24_30], [Hr24_45], [Hr24_60], 
		[Hr25_15], [Hr25_30], [Hr25_45], [Hr25_60]
	)
	) AS unpvt		


-- For horuly
INSERT INTO #actual_volume
SELECT term_start, CAST(CASE WHEN add_dst_hour>0 THEN add_dst_hour ELSE REPLACE(Hr, 'hr', '') END-1 AS VARCHAR) Hr,0 mins, total,add_dst_hour,source_deal_header_id,0 period
FROM (
		SELECT m.prod_date term_start, 		
			Hr1, Hr2, (Hr3-ISNULL(Hr25,0)) Hr3, Hr4
			, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10
			, Hr11, Hr12, Hr13, Hr14, Hr15
			, Hr16, Hr17, Hr18, Hr19, Hr20
			, Hr21 Hr21, Hr22, Hr23, Hr24, Hr25, dst.[hour] add_dst_hour
			,sdd.source_deal_header_id
		FROM	
			source_deal_detail	sdd 
			INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sdd.location_id
			INNER JOIN mv90_data mv ON mv.meter_id = ISNULL(sdd.meter_id, smlm.meter_id)			
			INNER JOIN recorder_properties rp ON rp.meter_id = mv.meter_id AND rp.channel = mv.channel
			INNER JOIN mv90_data_hour m ON m.meter_data_id = mv.meter_data_id	
				AND m.prod_date BETWEEN sdd.term_start AND sdd.term_end
			LEFT JOIN mv90_dst dst ON dst.[date] = m.prod_date AND dst.insert_delete = 'i'	
		WHERE
			sdd.source_deal_detail_id IN(@source_deal_deatil)
			AND sdd.term_start >=@term_start AND sdd.term_end<=@term_end
	) p
	UNPIVOT
	(total FOR Hr IN (
		Hr1, Hr2,Hr3, Hr4
			, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10
			, Hr11, Hr12, Hr13, Hr14, Hr15
			, Hr16, Hr17, Hr18, Hr19, Hr20
			, Hr21, Hr22, Hr23, Hr24, Hr25	
	)		
	) AS unpvt		


 SET @sql = '
	 ;WITH CTE AS(
	  SELECT  
	  COALESCE(fv.term_start,dv.term_start,av.term_start) term_start, COALESCE(fv.Hr,dv.Hr,av.Hr) Hr,
	  COALESCE(fv.mins,dv.mins,av.mins) mins,ABS(SUM(fv.total)) [Forecast Volume],
	  ABS(SUM(dv.total)) [Deal Volume],ABS(SUM(av.total)) [Actual Volume],
	  COALESCE(fv.granularity,dv.granularity) granularity
	  FROM  
	   #forecast_volume fv
	   FULL JOIN #deal_volume dv ON fv.term_start = dv.term_start
		 AND fv.hr = dv.hr
		 AND fv.mins = dv.mins
	   FULL JOIN #actual_volume av ON av.term_start = ISNULL(fv.term_start,dv.term_start)
		 AND av.hr = ISNULL(fv.hr,dv.hr)
		 AND av.mins = ISNULL(fv.mins,dv.mins)
	  GROUP BY 
	   COALESCE(fv.term_start,dv.term_start,av.term_start), COALESCE(fv.Hr,dv.Hr,av.Hr),COALESCE(fv.mins,dv.mins,av.mins), COALESCE(fv.granularity,dv.granularity)    
	 )
	 SELECT 
	  dbo.fnadateformat('+CASE WHEN @report_granularity = 980 THEN  ' dbo.FNAGetContractMonth(term_start) ' ELSE 'term_start' END +') [Term],
	  '+CASE WHEN @report_granularity IN(980,981) THEN '0' ELSE 'hr' END + ' Hr,
	  '+CASE WHEN @report_granularity IN(980,981) THEN '0' ELSE 'mins' END + ' [Mins]'
	  +CASE WHEN @volume_type LIKE '%d%' THEN ',SUM([Deal Volume])[Deal Volume] ' ELSE '' END
	  +CASE WHEN @volume_type LIKE '%f%' THEN ',SUM([Forecast Volume])[Forecast Volume]' ELSE '' END
	  +CASE WHEN @volume_type LIKE '%a%' THEN ',SUM([Actual Volume])[Actual Volume] ' ELSE '' END+' 
	  INTO #chart_data 
	 FROM 
	  CTE 
	 WHERE
	  Hr<24 
	 GROUP BY 
	  dbo.fnadateformat('+CASE WHEN @report_granularity = 980 THEN  ' dbo.FNAGetContractMonth(term_start) ' ELSE 'term_start' END +')'  +
	  CASE WHEN @report_granularity IN(980,981) THEN '' ELSE ',hr' END+
	  CASE WHEN @report_granularity IN(980,981) THEN '' ELSE ',mins' END +'   
	  order by  dbo.fnadateformat('+CASE WHEN @report_granularity = 980 THEN  ' dbo.FNAGetContractMonth(term_start) ' ELSE 'term_start' END +')
	  '+CASE WHEN @report_granularity IN(980,981) THEN '' ELSE ',CAST([hr] AS INT)' END+
	   CASE WHEN @report_granularity IN(980,981) THEN '' ELSE ',CAST([mins] AS INT)' END +''
	   IF @report_type = 'p'
	   BEGIN
	   	set @sql = @sql + ' SELECT Term, volume_type, volume
			FROM
			(
			SELECT Term,  CAST([Deal Volume] AS NUMERIC(38,20)) [Deal Volume] , CAST([Forecast Volume] AS NUMERIC(38,20)) [Forecast Volume] , CAST([Actual Volume] AS NUMERIC(38,20)) [Actual Volume]
			FROM  #chart_data) up
			UNPIVOT
			(volume FOR volume_type IN ([Deal Volume], [Forecast Volume], [Actual Volume])
			) AS Unpvt'
			END
		ELSE 
	  	SET  @sql = @sql + ' select Term'
	  		+CASE WHEN @report_granularity IN(982,987) THEN ',Hr,Mins' ELSE '' END+ 
	  		+CASE WHEN @volume_type LIKE '%d%' THEN ', [Deal Volume]' ELSE '' END
	  		+CASE WHEN @volume_type LIKE '%f%' THEN ', [Forecast Volume]' ELSE '' END
	  		+CASE WHEN @volume_type LIKE '%a%' THEN ', [Actual Volume]' ELSE '' END 
	  	+' from #chart_data'
EXEC spa_print @sql
EXEC (@sql)
END	
IF @flag = 'd' 
BEGIN
SELECT report_id,name FROM report WHERE [name] LIKE '%Deal Volume Hierarchy%'
END
ELSE IF @flag = 'c' -- select report or a tab
BEGIN
    
    SELECT r.report_id,
           r.[name] + '_' + rp2.[name] AS [report_name],
           dbo.FNARFXGenerateReportItemsCombined(rp2.report_page_id) 
           [items_combined],
           rdp.paramset_id
    FROM   report r
           INNER JOIN report_page rp2
                ON  rp2.report_id = r.report_id
           INNER JOIN report_paramset rp
                ON  rp.page_id = rp2.report_page_id
           INNER JOIN report_dataset_paramset rdp
                ON  rdp.paramset_id = rp.report_paramset_id
    WHERE  r.report_id = @report_id
   
END






