IF OBJECT_ID(N'FNARMTMSettlement', N'FN') IS NOT NULL
DROP FUNCTION [FNARMTMSettlement]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARMTMSettlement]    Script Date: 11/23/2009 15:27:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARMTMSettlement](
	@deal_id int, -- @deal_id is @source_deal_detail_id
	@term_start datetime
)

RETURNS FLOAT AS
BEGIN

DECLARE @pnl FLOAT
DECLARE @as_of_date DATETIME

	select @as_of_date=max(pnl_as_of_date) from 	
			source_deal_pnl	sdp
			join source_deal_detail sdd on sdd.source_deal_header_id=sdp.source_deal_header_id	
	where sdd.source_deal_detail_id  = @deal_id and sdp.term_start=@term_start
				--AND month(sdp.pnl_as_of_date)=month(@term_start) and year(sdp.pnl_as_of_date)=YEAR(@term_start)

	select @pnl = sum(und_pnl_set) 
	from source_deal_pnl sdp
		 join source_deal_detail sdd on sdd.source_deal_header_id=sdp.source_deal_header_id	
	where sdd.source_deal_detail_id = @deal_id and sdp.term_start=@term_start
		  AND sdp.pnl_as_of_date=@as_of_date
		  
	return @pnl
END


