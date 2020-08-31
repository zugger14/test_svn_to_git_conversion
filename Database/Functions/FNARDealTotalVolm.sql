/****** Object:  UserDefinedFunction [dbo].[FNARDealTotalVolm]    Script Date: 04/07/2009 17:17:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDealTotalVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDealTotalVolm]
/****** Object:  UserDefinedFunction [dbo].[FNARDealTotalVolm]    Script Date: 04/07/2009 17:17:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARDealTotalVolm](
	@term_start DATETIME,
	@counterparty_id INT,
	@contract_id INT,
	@source_deal_detail_id INT,
	@source_deal_header_id INT,
	@aggregation_level INT
)

RETURNS FLOAT AS
BEGIN


	DECLARE @deal_volume FLOAT

	IF @aggregation_level=19001
      SELECT @deal_volume=SUM(sdd.total_volume)
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
      SELECT @deal_volume=SUM(sdd.total_volume)
      FROM 
            source_deal_detail sdd 
      WHERE 1=1
            AND sdd.source_deal_header_id=@source_deal_header_id
           

	ELSE IF isnull(@aggregation_level,19002)=19002
      SELECT @deal_volume=SUM(sdd.total_volume)
      FROM 
            source_deal_detail sdd 
      WHERE 1=1
            AND sdd.source_deal_detail_id=@source_deal_detail_id
			
			
	return @deal_volume
END


