/****** Object:  UserDefinedFunction [dbo].[FNARAllocVolm]    Script Date: 09/15/2011 11:38:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARAllocVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARAllocVolm]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARAllocVolm]    Script Date: 09/15/2011 11:39:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- select [dbo].[FNARAllocVolm](NULL,'2012-01-31','2012-01-01','s',48425,341) 
CREATE FUNCTION [dbo].[FNARAllocVolm] (
				@as_of_date DATETIME,
				@prod_date DATETIME, 
				@counterparty_id INT,
				@contract_id INT,
				@commodity_id INT,
				@curve_tou INT,
				@aggregation_level INT,
				@source_deal_header_id INT
				)
RETURNS float AS  
BEGIN 
	DECLARE @alloc_vol FLOAT
	
	
	IF @aggregation_level = 19000 -- deal level
	SELECT @alloc_vol = SUM(sds.allocation_volume)
		FROM 
			source_deal_settlement sds				
			INNER JOIN source_deal_header sdh ON sds.source_deal_header_id = sdh.source_deal_header_id
			AND (sds.set_type = 'f' AND sds.as_of_date = @as_of_date OR ( sds.set_type = 's' AND @as_of_date>= sds.term_end))
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sds.source_deal_header_id
				AND sdd.term_start = sds.term_start
				AND sdd.leg = sds.leg
			LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sdd.location_id
			LEFT JOIN meter_counterparty mc ON mc.meter_id = smlm.meter_id
				AND sds.term_start BETWEEN mc.term_start AND ISNULL(mc.term_end,'9999-01-01')	
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id				
		WHERE
			YEAR(sds.term_start) = YEAR(@prod_date)
			AND MONTH(sds.term_start) = MONTH(@prod_date)
			AND ISNULL(mc.counterparty_id,sdh.counterparty_id) = @counterparty_id
			AND sdh.contract_id = @contract_id
			AND ISNULL(spcd.curve_tou,18900) = @curve_tou
			AND sds.source_deal_header_id = @source_deal_header_id
	
	ELSE IF @aggregation_level = 19002 -- deal detail level
	SELECT @alloc_vol = SUM(sds.allocation_volume)
		FROM 
			source_deal_settlement sds				
			INNER JOIN source_deal_header sdh ON sds.source_deal_header_id = sdh.source_deal_header_id
			AND (sds.set_type = 'f' AND sds.as_of_date = @as_of_date OR ( sds.set_type = 's' AND @as_of_date>= sds.term_end))
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sds.source_deal_header_id
				AND sdd.term_start = sds.term_start
				AND sdd.leg = sds.leg
			LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sdd.location_id
			LEFT JOIN meter_counterparty mc ON mc.meter_id = smlm.meter_id
				AND sds.term_start BETWEEN mc.term_start AND ISNULL(mc.term_end,'9999-01-01')	
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id				
		WHERE
			YEAR(sds.term_start) = YEAR(@prod_date)
			AND MONTH(sds.term_start) = MONTH(@prod_date)
			AND ISNULL(mc.counterparty_id,sdh.counterparty_id) = @counterparty_id
			AND sdh.contract_id = @contract_id
			--AND ISNULL(spcd.curve_tou,18900) = @curve_tou
			AND sdd.source_deal_detail_id = @source_deal_header_id

	ELSE IF @aggregation_level = 19001 -- Contract Level
	SELECT @alloc_vol = SUM(sds.allocation_volume)
		FROM 
			source_deal_settlement sds				
			INNER JOIN source_deal_header sdh ON sds.source_deal_header_id = sdh.source_deal_header_id
			AND (sds.set_type = 'f' AND sds.as_of_date = @as_of_date OR ( sds.set_type = 's' AND @as_of_date>= sds.term_end))
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sds.source_deal_header_id
				AND sdd.term_start = sds.term_start
				AND sdd.leg = sds.leg
			INNER JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sdd.location_id
			LEFT JOIN meter_counterparty mc ON mc.meter_id = smlm.meter_id
				AND sds.term_start BETWEEN mc.term_start AND ISNULL(mc.term_end,'9999-01-01')	
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id				
		WHERE
			YEAR(sds.term_start) = YEAR(@prod_date)
			AND MONTH(sds.term_start) = MONTH(@prod_date)
			AND ISNULL(mc.counterparty_id,sdh.counterparty_id) = @counterparty_id
			AND sdh.contract_id = @contract_id
			AND ISNULL(spcd.curve_tou,18900) = @curve_tou
		
	RETURN isnull(@alloc_vol, 0)
END




GO


