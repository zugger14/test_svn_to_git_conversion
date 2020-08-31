/****** Object:  UserDefinedFunction [dbo].[FNARAverageHourlyPrice]    Script Date: 06/15/2010 18:30:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARPriceMultiplier]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARPriceMultiplier]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARPriceMultiplier]    Script Date: 9/22/2015 11:22:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARPriceMultiplier](
	@term_start DATETIME,
	@counterparty_id INT,
	@contract_id INT,
	@source_deal_detail_id INT,
	@source_deal_header_id INT,
	@aggregation_level INT
)

RETURNS FLOAT AS
BEGIN


	DECLARE @price_multiplier FLOAT

	IF @aggregation_level=19001
      SELECT @price_multiplier=MAX(sdd.price_multiplier)
      FROM 
            source_deal_detail sdd 
            join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id   
      WHERE 1=1
            AND sdh.contract_id=@contract_id
            AND sdh.counterparty_id=@counterparty_id
            AND MONTH(sdd.term_start) = MONTH(@term_start) 
            AND YEAR(sdd.term_start) = YEAR(@term_start) 
			AND leg=1

	ELSE IF @aggregation_level=19000
      SELECT @price_multiplier=MAX(sdd.price_multiplier)
      FROM 
            source_deal_detail sdd 
      WHERE 1=1
            AND sdd.source_deal_header_id=@source_deal_header_id
           

	ELSE IF isnull(@aggregation_level,19002)=19002
      SELECT @price_multiplier=MAX(sdd.price_multiplier)
      FROM 
            source_deal_detail sdd 
      WHERE 1=1
            AND sdd.source_deal_detail_id=@source_deal_detail_id
			
			
	return @price_multiplier
END


