/****** Object:  UserDefinedFunction [dbo].[FNARDealLeg]    Script Date: 04/07/2009 17:17:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDealLeg]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDealLeg]
/****** Object:  UserDefinedFunction [dbo].[FNARDealLeg]    Script Date: 04/07/2009 17:17:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARDealLeg](
	@deal_id int -- @deal_id is @source_deal_detail_id
	
)

RETURNS INT AS
BEGIN

DECLARE @deal_leg INT

	select @deal_leg = (sdd.leg) 
	from 
		source_deal_detail sdd 
		join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	

	where 
		  sdd.source_deal_detail_id = @deal_id 
		  
	return @deal_leg
END


