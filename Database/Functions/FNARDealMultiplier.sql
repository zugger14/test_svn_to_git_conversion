/****** Object:  UserDefinedFunction [dbo].[FNARDealMultiplier]    Script Date: 09/15/2011 11:38:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDealMultiplier]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDealMultiplier]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARDealSettlement]    Script Date: 09/15/2011 11:39:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARDealMultiplier] (
				@source_deal_detail_id INT,
				@source_deal_header_id INT
				)
RETURNS float AS  
BEGIN 
	DECLARE @multiplier_value FLOAT
	
	
	
	
	IF @source_deal_detail_id IS NOT NULL
		SELECT @multiplier_value=sdd.multiplier
		FROM
			source_deal_detail sdd
			INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id=sdh.source_deal_header_id
		WHERE
			sdd.source_deal_detail_id=@source_deal_detail_id
	
	ELSE
		SELECT @multiplier_value=sdd.multiplier
		FROM
			source_deal_detail sdd
			INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id=sdh.source_deal_header_id
		WHERE
			sdd.source_deal_header_id=@source_deal_header_id
	
	RETURN isnull(@multiplier_value, 1)
END




GO


