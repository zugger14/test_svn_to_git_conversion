IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDealStrikePrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDealStrikePrice]
/****** Object:  UserDefinedFunction [dbo].[FNARDealStrikePrice]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Created by: rgiri@pioneersolutionsglobal.com
-- Create date: 2013-04-27
-- Description: To show each hour deal strick price
-- select dbo.[FNARDealStrikePrice](315, NULL)
--select dbo.[FNARDealStrikePrice](NULL, 45)
-- ===========================================================================================================

CREATE FUNCTION [dbo].[FNARDealStrikePrice](
	@source_deal_detail_id INT,
	@source_deal_header_id INT
)

RETURNS FLOAT AS
BEGIN
	DECLARE @strike_price FLOAT
	IF @source_deal_detail_id IS NOT NULL
	SELECT  @strike_price =  option_strike_price FROM source_deal_detail sdd WHERE sdd.source_deal_detail_id = @source_deal_detail_id
	ELSE 
		BEGIN
		SELECT  @strike_price =  max(option_strike_price) FROM source_deal_detail sdd 
		LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		WHERE sdd.source_deal_header_id = @source_deal_header_id
		END	
	RETURN(@strike_price) 
END
 
 
