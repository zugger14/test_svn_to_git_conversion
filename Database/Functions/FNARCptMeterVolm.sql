/****** Object:  UserDefinedFunction [dbo].[FNARCptMeterVolm]    Script Date: 04/07/2009 17:17:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARCptMeterVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARCptMeterVolm]

GO
/****** Object:  UserDefinedFunction [dbo].[FNARCptMeterVolm]    Script Date: 04/07/2009 17:17:31 ******/
CREATE FUNCTION [dbo].[FNARCptMeterVolm](
	@as_of_date DATETIME,
	@term_start DATETIME,
	@counterparty_id INT,
	@commodity_id INT,
	@country_id INT,
	@block_define_id INT 
)
RETURNS FLOAT AS

/*
--SELECT [dbo].[FNARCptMeterVolm]('2012-01-31','2012-01-01',19,-2,291997)
--select * from static_data_value where type_id=10018
--SELECT * FROM meter_id
DECLARE @as_of_date DATETIME,@term_start DATETIME,@counterparty_id INT,@commodity_id INT,@curve_tou INT,@block_define_id INT ,@country_id INT

SET @as_of_date='2012-03-31'
SET @term_start='2012-03-01'
SET @counterparty_id=19
SET @block_define_id=NULL

SET @commodity_id =-1
SET @country_id = 292068
--*/

BEGIN
	DECLARE @volume FLOAT,@baseload_block INT
	DECLARE @dst_group_value_id INT
	
	SELECT @baseload_block = value_id  FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load'

	SELECT @dst_group_value_id = tz.dst_group_value_id FROM dbo.adiha_default_codes_values (nolock) adcv INNER JOIN time_zones tz
		ON tz.TIMEZONE_ID = adcv.var_value WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1

	;WITH CTE AS (
			SELECT
					hb.term_date,
					hb.block_type,
					hb.block_define_id,
					hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
				FROM
					hour_block_term hb
				WHERE block_type=12000
					AND block_define_id=ISNULL(@block_define_id,@baseload_block)
					AND YEAR(term_date) = YEAR(@term_start)
					AND MONTH(term_date) = MONTH(@term_start)
					AND dst_group_value_id = @dst_group_value_id
		)

--SELECT * FROM CTE
	SELECT @volume=
		SUM(
		(ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr7 ELSE mvh.hr1 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr7,1) ELSE ISNULL(ct.hr1,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr8 ELSE mvh.hr2 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr8,1) ELSE ISNULL(ct.hr2,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr9 ELSE mvh.hr3 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr9,1) ELSE ISNULL(ct.hr3,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr10 ELSE mvh.hr4 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr10,1) ELSE ISNULL(ct.hr4,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr11 ELSE mvh.hr5 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr11,1) ELSE ISNULL(ct.hr5,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr12 ELSE mvh.hr6 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr12,1) ELSE ISNULL(ct.hr6,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr13 ELSE mvh.hr7 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr13,1) ELSE ISNULL(ct.hr7,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr14 ELSE mvh.hr8 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr14,1) ELSE ISNULL(ct.hr8,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr15 ELSE mvh.hr9 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr15,1) ELSE ISNULL(ct.hr9,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr16 ELSE mvh.hr10 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr16,1) ELSE ISNULL(ct.hr10,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr17 ELSE mvh.hr11 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr17,1) ELSE ISNULL(ct.hr11,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr18 ELSE mvh.hr12 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr18,1) ELSE ISNULL(ct.hr12,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr19 ELSE mvh.hr13 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr19,1) ELSE ISNULL(ct.hr13,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr20 ELSE mvh.hr14 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr20,1) ELSE ISNULL(ct.hr14,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr21 ELSE mvh.hr15 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr21,1) ELSE ISNULL(ct.hr15,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr22 ELSE mvh.hr16 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr22,1) ELSE ISNULL(ct.hr16,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr23 ELSE mvh.hr17 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr23,1) ELSE ISNULL(ct.hr17,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN mvh.hr24 ELSE mvh.hr18 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct.hr24,1) ELSE ISNULL(ct.hr18,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN CASE WHEN mvh2.prod_date IS NULL THEN mvh1.hr1 ELSE mvh2.hr1 END ELSE mvh.hr19 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct1.hr19,1) ELSE ISNULL(ct.hr19,1) END,0) +
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN CASE WHEN mvh2.prod_date IS NULL THEN mvh1.hr2 ELSE mvh2.hr2 END ELSE mvh.hr20 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct1.hr20,1) ELSE ISNULL(ct.hr20,1) END,0) +
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN CASE WHEN mvh2.prod_date IS NULL THEN mvh1.hr3 ELSE mvh2.hr3 END ELSE mvh.hr21 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct1.hr21,1) ELSE ISNULL(ct.hr21,1) END,0) +
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN CASE WHEN mvh2.prod_date IS NULL THEN mvh1.hr4 ELSE mvh2.hr4 END ELSE mvh.hr22 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct1.hr22,1) ELSE ISNULL(ct.hr22,1) END,0) +
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN CASE WHEN mvh2.prod_date IS NULL THEN mvh1.hr5 ELSE mvh2.hr5 END ELSE mvh.hr23 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct1.hr23,1) ELSE ISNULL(ct.hr23,1) END,0)+
			ISNULL(CASE WHEN mi.commodity_id=-1 THEN CASE WHEN mvh2.prod_date IS NULL THEN mvh1.hr6 ELSE mvh2.hr6 END ELSE mvh.hr24 END * CASE WHEN mi.commodity_id=-1 THEN ISNULL(ct1.hr24,1) ELSE ISNULL(ct.hr24,1) END,0))
			* (CASE WHEN mi.recorderid LIKE '%_R' THEN -1 ELSE 1 END)
		)
	FROM
		meter_id mi 
		INNER JOIN mv90_data mv	ON mi.meter_id=mv.meter_id
			AND YEAR(mv.from_date)=YEAR(@term_start)
			AND MONTH(mv.from_date)=MONTH(@term_start)
			AND ISNULL(mi.commodity_id,'')=@commodity_id	
			AND ISNULL(mi.granularity,'') <> 980
		INNER JOIN mv90_data_hour mvh ON mvh.meter_data_id=mv.meter_data_id
		LEFT JOIN mv90_data mv1 ON mv1.meter_id=mv.meter_id
				AND mv1.from_date=DATEADD(m,1,mv.from_date)
		LEFT JOIN mv90_data_hour mvh1 ON mvh1.meter_data_id=mv1.meter_data_id
			AND DAY(mvh1.prod_date)=1	
			AND mi.commodity_id=-1
		LEFT JOIN mv90_data_hour mvh2 ON mvh2.meter_data_id=mv.meter_data_id
			AND mvh2.prod_date-1=mvh.prod_date
			AND mi.commodity_id=-1
		LEFT JOIN meter_counterparty mc ON mc.meter_id = mi.meter_id
			AND ISNULL(mvh2.prod_date,mvh.prod_date) BETWEEN mc.term_start AND ISNULL(mc.term_end,'9999-01-01')

		LEFT JOIN CTE ct ON ct.term_date = mvh.prod_date
		LEFT JOIN CTE ct1 ON ct1.term_date -1= mvh.prod_date
	    LEFT JOIN (
			SELECT smlm.meter_id meter_id, MAX(sdd.counterparty_id) counterparty_id FROM source_minor_location_meter smlm 
				INNER JOIN ( 
					SELECT MAX(sdh.counterparty_id) counterparty_id, sdd.location_id location_id 
					FROM source_deal_detail sdd 
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN deal_status_group dsg ON dsg.status_value_id = sdh.deal_status
					WHERE sdd.term_start = CONVERT(VARCHAR(10), @term_start, 121) GROUP BY sdd.location_id 
				) sdd ON sdd.location_id = smlm.source_minor_location_id
				GROUP BY smlm.meter_id
			) smlm ON smlm.meter_id = mi.meter_id
		WHERE
		(COALESCE(mc.counterparty_id, mi.counterparty_id,'') = @counterparty_id OR smlm.counterparty_id = @counterparty_id)		
		AND ISNULL(mi.multiple_location,'n') = 'n'
		AND mi.country_id = @country_id
	
	-- included monthly meter as well in sum since later changes uses multiple location flag to know profiled meters
	SELECT @volume = @volume + (ISNULL(mv.volume, 0) * (CASE WHEN mi.recorderid LIKE '%_R' THEN -1 ELSE 1 END))
	FROM
		meter_id mi 
		INNER JOIN mv90_data mv	ON mi.meter_id=mv.meter_id
			AND YEAR(mv.from_date)=YEAR(@term_start)
			AND MONTH(mv.from_date)=MONTH(@term_start)
			AND ISNULL(mi.commodity_id,'')=@commodity_id	
			AND ISNULL(mi.granularity,'') = 980
		LEFT JOIN meter_counterparty mc ON mc.meter_id = mi.meter_id
			AND mv.from_date BETWEEN mc.term_start AND ISNULL(mc.term_end,'9999-01-01')
	    LEFT JOIN (
		SELECT smlm.meter_id meter_id, MAX(sdd.counterparty_id) counterparty_id FROM source_minor_location_meter smlm 
			INNER JOIN ( 
					SELECT MAX(sdh.counterparty_id) counterparty_id, sdd.location_id location_id 
					FROM source_deal_detail sdd 
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN deal_status_group dsg ON dsg.status_value_id = sdh.deal_status
					WHERE sdd.term_start = CONVERT(VARCHAR(10), @term_start, 121) GROUP BY sdd.location_id 
			) sdd ON sdd.location_id = smlm.source_minor_location_id
			GROUP BY smlm.meter_id
		) smlm ON smlm.meter_id = mi.meter_id	
	WHERE
		(COALESCE(mc.counterparty_id, mi.counterparty_id,'') = @counterparty_id OR smlm.counterparty_id = @counterparty_id)	
		AND ISNULL(mi.multiple_location,'n') = 'n'
		AND mi.country_id = @country_id

	RETURN ISNULL(@volume,0)
END