/****** Object:  UserDefinedFunction [dbo].[FNARAverageMnthlyPrice] ******/
IF EXISTS (SELECT * FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNARAverageMnthlyPrice]') AND TYPE IN (N'FN' ,N'IF' ,N'TF' ,N'FS' ,N'FT'))
    DROP FUNCTION [dbo].[FNARAverageMnthlyPrice]
GO


CREATE FUNCTION [dbo].[FNARAverageMnthlyPrice]
(
	@source_deal_detail_id  INT
   ,@maturity_date          DATETIME
   ,@as_of_date             DATETIME
   ,@source_deal_header_id  INT
   ,@curve_id               INT
   ,@block_define_id        INT
   ,@process_id             VARCHAR(100)
   ,@param					INT
)
RETURNS FLOAT
AS

BEGIN  
	DECLARE @granularity            INT
		   ,@contract_id            INT
		   ,@avg_price              FLOAT
		   ,@block_type             INT
		   ,@baseload_block         INT	   

	--SET @source_deal_detail_id = 889205 
	--SET @maturity_date = '2013-01-01'
	--SET @as_of_date = '2013-01-01'
	--SET @curve_id = 824
	SET @block_type = 12000		
	           
	 SELECT @baseload_block = value_id
		FROM   static_data_value
		WHERE  [TYPE_ID] = 10018
			   AND code LIKE 'Base Load'
	    
		IF @block_define_id IS NULL
			SELECT @block_define_id = ISNULL(block_define_id ,@baseload_block)
			FROM   source_price_curve_def spcd
			WHERE  spcd.source_curve_def_id = @curve_id
		
		
	IF @param=0
	BEGIN
	IF @process_id IS NOT NULL
	BEGIN
			SELECT @avg_price = curve_value
			FROM   dbo.source_price_curve_cache
			WHERE  as_of_date = @as_of_date
				   AND maturity_date = @maturity_date
				   AND Curve_id = @curve_id
				   AND process_id = @process_id
				   AND block_define_id = ISNULL(@block_define_id ,@baseload_block)
	END	
	IF @avg_price IS NULL
		BEGIN			
			;WITH CTE AS (
				SELECT unpvt.term_date
					  ,CAST(REPLACE(unpvt.[hour] ,'hr' ,'') AS INT) [HOUR]
					  ,unpvt.hr_mult
				FROM   (
						   SELECT hb.term_date
								 ,hb.block_type
								 ,hb.block_define_id
								 ,hr1
								 ,hr2
								 ,hr3
								 ,hr4
								 ,hr5
								 ,hr6
								 ,hr7
								 ,hr8
								 ,hr9
								 ,hr10
								 ,hr11
								 ,hr12
								 ,hr13
								 ,hr14
								 ,hr15
								 ,hr16
								 ,hr17
								 ,hr18
								 ,hr19
								 ,hr20
								 ,hr21
								 ,hr22
								 ,hr23
								 ,hr24
						   FROM   hour_block_term hb
						   WHERE  block_type = @block_type
								  AND block_define_id = @block_define_id
								  AND YEAR(term_date) = YEAR(@maturity_date)
								  AND MONTH(term_date) = MONTH(@maturity_date)
					   )p
	                   
					   UNPIVOT(
						   hr_mult FOR [HOUR] IN (hr1
												 ,hr2
												 ,hr3
												 ,hr4
												 ,hr5
												 ,hr6
												 ,hr7
												 ,hr8
												 ,hr9
												 ,hr10
												 ,hr11
												 ,hr12
												 ,hr13
												 ,hr14
												 ,hr15
												 ,hr16
												 ,hr17
												 ,hr18
												 ,hr19
												 ,hr20
												 ,hr21
												 ,hr22
												 ,hr23
												 ,hr24)
					   ) AS unpvt
				WHERE  unpvt.[hr_mult]<>0
			)
	      
			SELECT @avg_price = AVG(curve_value)
			FROM   (
					   SELECT spc.curve_value*ISNULL(hr_mult ,0) curve_value
					   FROM   source_price_curve spc
							  INNER JOIN CTE td
								   ON  CAST(
										   CONVERT(VARCHAR(10) ,td.term_date ,120)+
										   ' '+
										   CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' 
										   AS 
										   DATETIME
									   ) = spc.maturity_date
									   AND spc.source_curve_def_id = @curve_id
									   AND YEAR(maturity_date) = YEAR(@maturity_date)
									   AND MONTH(maturity_date) = MONTH(@maturity_date)
	                   
					   UNION ALL
					   SELECT spc.curve_value curve_value
					   FROM   source_price_curve_def spcd
							  INNER JOIN source_price_curve_def spcd1
								   ON  spcd1.source_curve_def_id = spcd.proxy_source_curve_def_id
									   AND spcd.source_curve_def_id = @curve_id
							  INNER JOIN source_price_curve spc
								   ON  spc.source_curve_def_id = spcd1.source_curve_def_id
									   AND spc.as_of_date = @as_of_date
									   AND YEAR(spc.maturity_date) = YEAR(@maturity_date)
									   AND MONTH(spc.maturity_date) = MONTH(@maturity_date)
									   AND spc.maturity_date>@as_of_date+' 23:59:59.000'
									   AND DAY(@as_of_date)<>dbo.FNALastDayInMonth(@as_of_date)
				   ) a
		END
	END 

	IF @param=1
	BEGIN
		SELECT @granularity = granularity
		FROM   source_price_curve_def spcd
		WHERE  spcd.source_curve_def_id = @curve_id

		SELECT  @avg_price = SUM(ABS(unpvt.hr_mult)*spc.curve_value)/SUM(ABS(unpvt.hr_mult))
		FROM   (
				   SELECT m_dt.as_of_date,
						 ISNULL(sdd.source_deal_detail_id ,pos.source_deal_detail_id) source_deal_detail_id
						 ,ISNULL(sdd.curve_id ,pos.curve_id) curve_id
						 ,ISNULL(mdh.prod_date ,pos.term_start) term_start
						 ,ISNULL(hb.hr1,0) * COALESCE(mdh.hr1,md.volume,pos.hr1) hr1
						 ,ISNULL(hb.hr2,0) * COALESCE(mdh.hr2,md.volume,pos.hr2) hr2
						 ,ISNULL(hb.hr3,0) * COALESCE(mdh.hr3,md.volume,pos.hr3) hr3
						 ,ISNULL(hb.hr4,0) * COALESCE(mdh.hr4,md.volume,pos.hr4) hr4
						 ,ISNULL(hb.hr5,0) * COALESCE(mdh.hr5,md.volume,pos.hr5) hr5
						 ,ISNULL(hb.hr6,0) * COALESCE(mdh.hr6,md.volume,pos.hr6) hr6
						 ,ISNULL(hb.hr7,0) * COALESCE(mdh.hr7,md.volume,pos.hr7) hr7
						 ,ISNULL(hb.hr8,0) * COALESCE(mdh.hr8,md.volume,pos.hr8) hr8
						 ,ISNULL(hb.hr9,0) * COALESCE(mdh.hr9,md.volume,pos.hr9) hr9
						 ,ISNULL(hb.hr10,0)* COALESCE(mdh.hr10,md.volume,pos.hr10) hr10
						 ,ISNULL(hb.hr11,0) * COALESCE(mdh.hr11,md.volume,pos.hr11) hr11
						 ,ISNULL(hb.hr12,0) * COALESCE(mdh.hr12,md.volume,pos.hr12) hr12
						 ,ISNULL(hb.hr13,0) * COALESCE(mdh.hr13,md.volume,pos.hr13) hr13
						 ,ISNULL(hb.hr14,0) * COALESCE(mdh.hr14,md.volume,pos.hr14) hr14
						 ,ISNULL(hb.hr15,0) * COALESCE(mdh.hr15,md.volume,pos.hr15) hr15
						 ,ISNULL(hb.hr16,0) * COALESCE(mdh.hr16,md.volume,pos.hr16) hr16
						 ,ISNULL(hb.hr17,0) * COALESCE(mdh.hr17,md.volume,pos.hr17) hr17
						 ,ISNULL(hb.hr18,0) * COALESCE(mdh.hr18,md.volume,pos.hr18) hr18
						 ,ISNULL(hb.hr19,0) * COALESCE(mdh.hr19,md.volume,pos.hr19) hr19
						 ,ISNULL(hb.hr20,0) * COALESCE(mdh.hr20,md.volume,pos.hr20) hr20
						 ,ISNULL(hb.hr21,0) * COALESCE(mdh.hr21,md.volume,pos.hr21) hr21
						 ,ISNULL(hb.hr22,0) * COALESCE(mdh.hr22,md.volume,pos.hr22) hr22
						 ,ISNULL(hb.hr23,0) * COALESCE(mdh.hr23,md.volume,pos.hr23) hr23
						 ,ISNULL(hb.hr24,0) * COALESCE(mdh.hr24,md.volume,pos.hr24) hr24
							     
				   FROM   source_deal_detail sdd
						  INNER JOIN source_minor_location sml
							   ON  sdd.location_id = sml.source_minor_location_id AND sdd.source_deal_detail_id=@source_deal_detail_id
						  LEFT  JOIN source_minor_location_meter smlm
							  ON  sml.source_minor_location_id = smlm.source_minor_location_id 
						  LEFT JOIN  hour_block_term hb ON hb.block_type = 12000
								AND hb.block_define_id = ISNULL(@block_define_id, @baseload_block) 
								AND  hb.term_date BETWEEN  sdd.term_start AND sdd.term_end
						  LEFT  JOIN mv90_data md
							   ON  md.meter_id = smlm.meter_id  
						  LEFT JOIN mv90_data_hour mdh
							  ON  md.meter_data_id = mdh.meter_data_id AND @granularity IN  (982)
							  AND hb.term_date = mdh.prod_date							     
						  LEFT JOIN (
								   SELECT rp.source_deal_detail_id
										 ,rp.curve_id
										 ,rp.term_start
										 ,hr1
										 ,hr2
										 ,hr3
										 ,hr4
										 ,hr5
										 ,hr6
										 ,hr7
										 ,hr8
										 ,hr9
										 ,hr10
										 ,hr11
										 ,hr12
										 ,hr13
										 ,hr14
										 ,hr15
										 ,hr16
										 ,hr17
										 ,hr18
										 ,hr19
										 ,hr20
										 ,hr21
										 ,hr22
										 ,hr23
										 ,hr24
								   FROM   report_hourly_position_profile rp
										  where rp.term_start BETWEEN CONVERT(VARCHAR(8),@maturity_date,120)+'01'
												 AND dateadd(month,1,CONVERT(VARCHAR(8),@maturity_date,120)+'01')-1
												 AND rp.source_deal_detail_id = @source_deal_detail_id
												    
								   UNION ALL
								   SELECT rp.source_deal_detail_id
										 ,rp.curve_id
										 ,rp.term_start
										 ,hr1
										 ,hr2
										 ,hr3
										 ,hr4
										 ,hr5
										 ,hr6
										 ,hr7
										 ,hr8
										 ,hr9
										 ,hr10
										 ,hr11
										 ,hr12
										 ,hr13
										 ,hr14
										 ,hr15
										 ,hr16
										 ,hr17
										 ,hr18
										 ,hr19
										 ,hr20
										 ,hr21
										 ,hr22
										 ,hr23
										 ,hr24
								   FROM   report_hourly_position_deal rp
										  where rp.term_start BETWEEN CONVERT(VARCHAR(8),@maturity_date,120)+'01'
												 AND dateadd(month,1,CONVERT(VARCHAR(8),@maturity_date,120)+'01')-1
												 AND rp.source_deal_detail_id = @source_deal_detail_id
								   UNION ALL
								   SELECT rp.source_deal_detail_id
										 ,rp.curve_id
										 ,rp.term_start
										 ,hr1
										 ,hr2
										 ,hr3
										 ,hr4
										 ,hr5
										 ,hr6
										 ,hr7
										 ,hr8
										 ,hr9
										 ,hr10
										 ,hr11
										 ,hr12
										 ,hr13
										 ,hr14
										 ,hr15
										 ,hr16
										 ,hr17
										 ,hr18
										 ,hr19
										 ,hr20
										 ,hr21
										 ,hr22
										 ,hr23
										 ,hr24
								   FROM   report_hourly_position_fixed rp
										  where rp.term_start BETWEEN CONVERT(VARCHAR(8),@maturity_date,120)+'01'
												 AND dateadd(month,1,CONVERT(VARCHAR(8),@maturity_date,120)+'01')-1
												 AND rp.source_deal_detail_id = @source_deal_detail_id
							   ) pos
							   ON  sdd.source_deal_detail_id = pos.source_deal_detail_id
								   AND mdh.prod_date = pos.term_start
						OUTER APPLY (
							SELECT source_curve_def_id
							,MAX(as_of_date) as_of_date, CONVERT(VARCHAR(10) ,s.maturity_date ,120) maturity_date 
							FROM source_price_curve s WHERE s.source_curve_def_id = @curve_id
										AND CONVERT(VARCHAR(7),s.maturity_date,120) =CONVERT(VARCHAR(7),@maturity_date,120) 
								AND CONVERT(VARCHAR(10) ,s.maturity_date ,120) = ISNULL(mdh.prod_date ,pos.term_start)
							AND s.as_of_date<=ISNULL(@as_of_date,s.as_of_date)
				             GROUP BY     source_curve_def_id, CONVERT(VARCHAR(10) ,s.maturity_date ,120)
						                			   
						) m_dt 								   
				   WHERE  CONVERT(VARCHAR(7),ISNULL(mdh.prod_date ,pos.term_start),120)=CONVERT(VARCHAR(7),@maturity_date,120)		   
								   
								   
			   ) p
		       
			   UNPIVOT(
				   hr_mult FOR [HOUR] IN (hr1
										 ,hr2
										 ,hr3
										 ,hr4
										 ,hr5
										 ,hr6
										 ,hr7
										 ,hr8
										 ,hr9
										 ,hr10
										 ,hr11
										 ,hr12
										 ,hr13
										 ,hr14
										 ,hr15
										 ,hr16
										 ,hr17
										 ,hr18
										 ,hr19
										 ,hr20
										 ,hr21
										 ,hr22
										 ,hr23
										 ,hr24)
			   ) AS unpvt
			  
			  LEFT JOIN source_price_curve spc
					ON  spc.source_curve_def_id = @curve_id
						AND spc.as_of_date = unpvt.as_of_date
                AND CONVERT(VARCHAR(10) ,spc.maturity_date ,120) = unpvt.term_start
                AND DATEPART(HOUR ,spc.maturity_date) =  CAST(REPLACE(unpvt.[Hour],'hr','') AS INT) - 1
	END	
	RETURN @avg_price			
END