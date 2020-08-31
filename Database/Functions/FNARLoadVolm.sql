IF OBJECT_ID('[dbo].[FNARLoadVolm]','fn') IS NOT NULL 
DROP FUNCTION [dbo].[FNARLoadVolm]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARLoadVolm]    Script Date: 02/08/2010 19:34:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================================================
-- Create date: 2010-01-29 12:50PM
-- Description:	Returns deal volume of load type deals associated with the given counterparty for the given bucket adjusted as_of_date
-- Param: 
--	@as_of_date datetime - as of date
--	@bucket_id int - risk bucket id
-- Returns: deal volume
-- =============================================================================================================
CREATE FUNCTION [dbo].[FNARLoadVolm](
	@as_of_date DATETIME
	,@bucket_id INT
)
RETURNS FLOAT
AS
BEGIN
DECLARE @volume FLOAT
	
	SELECT @volume= SUM(case when sdd.buy_sell_flag='b' then 1 else -1 end * sdp.deal_volume) 
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			INNER JOIN source_deal_pnl sdp ON sdp.source_deal_header_id=sdh.source_deal_header_id
					AND sdp.term_start=sdd.term_start
					AND sdp.leg=1			
			WHERE ssbm.fas_deal_type_value_id = 409 
				 AND sdp.pnl_as_of_date=@as_of_date	
				 AND sdd.term_start BETWEEN dbo.FNAGetRiskBucketAdjustedTerm(@as_of_date, @bucket_id, 1) 
										AND dbo.FNAGetRiskBucketAdjustedTerm(@as_of_date, @bucket_id, 0)
	
RETURN abs(ISNULL(@volume,0))
	
END


