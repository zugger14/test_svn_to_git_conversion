/****** Object:  UserDefinedFunction [dbo].[FNARDealFloatPrice]    Script Date: 09/15/2011 11:38:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDealFloatPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDealFloatPrice]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARDealSettlement]    Script Date: 09/15/2011 11:39:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- select [dbo].[FNARDealFloatPrice](NULL,'2012-01-31','2012-01-01',48425,34,4100) 
CREATE FUNCTION [dbo].[FNARDealFloatPrice] (
					@source_deal_detail_id INT,
					@as_of_date DATETIME,
					@prod_date DATETIME, 
					@source_deal_header_id INT,
					@curve_tou INT,
					@calc_aggregation_level INT,
					@contract_id INT									
				)
RETURNS float AS  
BEGIN 
/*
DECLARE @source_deal_detail_id INT,
		@as_of_date DATETIME,
		@prod_date DATETIME, 
		@source_deal_header_id INT,
		@deal_type INT,
		@fixation INT

	
	
	SET @source_deal_header_id=60280
	SET @as_of_date='2011-01-31'
	SET @prod_date='2011-01-01'
	SET @deal_type=34
	SET @fixation=4100
*/	
	
DECLARE @net_price FLOAT
			

	
	IF @calc_aggregation_level = 19001 
	BEGIN
		SELECT @net_price = AVG((sds.float_price) / ISNULL(conv.conversion_factor, 1))
		FROM   source_deal_settlement sds
        INNER JOIN source_deal_detail sdd
            ON  sdd.source_deal_header_id = sds.source_deal_header_id
            AND sdd.leg = sds.leg
            AND sdd.term_start = sds.term_start
            AND (sds.set_type = 'f' AND sds.as_of_date = @as_of_date OR (sds.set_type = 's' AND @as_of_date >= sds.term_end))
        INNER JOIN source_deal_header sdh ON  sds.source_deal_header_id = sdh.source_deal_header_id
        LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
			LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = sds.volume_uom
				AND conv.to_source_uom_id = cg.volume_uom
		WHERE  sdh.contract_id = @contract_id
		       AND YEAR(sds.term_start) = YEAR(@prod_date)
		       AND MONTH(sds.term_start) = MONTH(@prod_date)
	END
	ELSE
	BEGIN
		IF @source_deal_detail_id IS NOT NULL
			SELECT @net_price = SUM((sds.float_price) / ISNULL(conv.conversion_factor, 1))
			FROM 
				source_deal_settlement sds INNER JOIN
				source_deal_detail sdd on sdd.source_deal_header_id = sds.source_deal_header_id and
					sdd.leg = sds.leg
					AND sdd.term_start = sds.term_start
					AND (sds.set_type = 'f' AND sds.as_of_date = @as_of_date OR ( sds.set_type = 's' AND @as_of_date>= sds.term_end))
				INNER JOIN source_deal_header sdh ON sds.source_deal_header_id = sdh.source_deal_header_id
				LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
			LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = sds.volume_uom
				AND conv.to_source_uom_id = cg.volume_uom
			WHERE
				sdd.source_deal_detail_id = @source_deal_detail_id
				AND YEAR(sds.term_start) = YEAR(@prod_date)
				AND MONTH(sds.term_start) = MONTH(@prod_date)
		ELSE
		
		SELECT @net_price = SUM((sds.float_price) / ISNULL(conv.conversion_factor, 1))
			FROM 
				source_deal_settlement sds
				INNER JOIN source_deal_header sdh ON sds.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = sds.source_deal_header_id and
					sdd.leg = sds.leg
					AND sdd.term_start = sds.term_start
					AND (sds.set_type = 'f' AND sds.as_of_date = @as_of_date OR ( sds.set_type = 's' AND @as_of_date>= sds.term_end))
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
				LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
			LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = sds.volume_uom
				AND conv.to_source_uom_id = cg.volume_uom
			WHERE
				sds.source_deal_header_id = @source_deal_header_id
				AND YEAR(sds.term_start) = YEAR(@prod_date)
				AND MONTH(sds.term_start) = MONTH(@prod_date)
				AND ISNULL(spcd.curve_tou,18900) = @curve_tou
	END	
	RETURN isnull(@net_price, 0)
	
	--SELECT @net_price
END




GO


