/****** Object:  UserDefinedFunction [dbo].[FNARYearlyContractVolm]    Script Date: 12/09/2010 17:08:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARYearlyContractVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARYearlyContractVolm]
/****** Object:  UserDefinedFunction [dbo].[FNARYearlyContractVolm]    Script Date: 12/09/2010 17:08:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
select [dbo].FNARDealFixedVolm(123,1)
select dbo.FNARYearlyContractVolm('2012-01-01',19,18,NULL,NULL,1901,18001)
select dbo.FNARYearlyContractVolm(term_start,@counterparty_id,@contract_id,NULL,@source_deal_header_id,19000,18001)
*/
CREATE FUNCTION [dbo].[FNARYearlyContractVolm](
	@term_start DATETIME,
	@counterparty_id INT,
	@contract_id INT,
	@source_deal_detail_id INT,
	@source_deal_header_id INT,
	@aggregation_level INT,
	@curve_tou INT
)

RETURNS FLOAT AS
BEGIN

--RETURN 7.0

DECLARE @deal_volume FLOAT
DECLARE @fixation INT	
	-- if it is fixation deal then find the original deal id
	
	
	IF @aggregation_level=19001
		SELECT @deal_volume = 
				SUM(sdd.deal_volume*CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END*ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1) * ISNULL(conv.conversion_factor,1)) 
						from 
							source_deal_detail sdd 
							join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
							INNER JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id
							INNER JOIN deal_status_group dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,-1)
							LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
							LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = sdd.deal_volume_uom_id
								AND conv.to_source_uom_id = cg.volume_uom
						where 1=1
							AND sdh.contract_id=@contract_id
							AND sdh.counterparty_id=@counterparty_id
							AND YEAR(sdd.term_start)= YEAR(@term_start)		
							AND ISNULL(product_id,4101)=4101
							--AND ISNULL(spcd.curve_tou,18900) = @curve_tou
							--AND sdd.leg=1	
	
	ELSE IF @aggregation_level=19000
      SELECT @deal_volume=SUM(sdd.deal_volume*CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END*ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1) * ISNULL(conv.conversion_factor,1))
      FROM 
            source_deal_detail sdd 
            INNER JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id
            INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
            INNER JOIN deal_status_group dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,-1)
			LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
			LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = sdd.deal_volume_uom_id
				AND conv.to_source_uom_id = cg.volume_uom
            
      WHERE 1=1
            AND sdd.source_deal_header_id=@source_deal_header_id
            AND YEAR(sdd.term_start)= YEAR(@term_start)		
           -- AND ISNULL(spcd.curve_tou,18900) = @curve_tou

	ELSE IF @aggregation_level=19002
      SELECT @deal_volume=SUM(sdd.deal_volume*CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END*ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1) * ISNULL(conv.conversion_factor,1))
      FROM 
            source_deal_detail sdd 
            INNER JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id
            INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
            INNER JOIN deal_status_group dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,-1)            
			LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
			LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = sdd.deal_volume_uom_id
				AND conv.to_source_uom_id = cg.volume_uom

      WHERE 1=1
            AND sdd.source_deal_detail_id=@source_deal_detail_id
			AND YEAR(sdd.term_start)= YEAR(@term_start)			
			--AND ISNULL(spcd.curve_tou,18900) = @curve_tou
	RETURN abs(@deal_volume)

END


