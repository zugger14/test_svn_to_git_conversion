/****** Object:  UserDefinedFunction [dbo].[FNARCounterpartyMTM]    Script Date: 02/10/2010 20:34:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARCounterpartyMTM]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARCounterpartyMTM]
/****** Object:  UserDefinedFunction [dbo].[FNARCounterpartyMTM]    Script Date: 02/10/2010 20:34:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ==================================================================================
-- Create date: 2010-01-29 12:50PM
-- Description:	Returns MTM of a counterparty for the given bucket
-- Param: 
--	@as_of_date datetime - as of date
--	@counterparty_id int - Counterparty ID
--	@bucket_id int - risk bucket id
-- Returns: Rating of a counterparty
-- ==================================================================================
CREATE FUNCTION [dbo].[FNARCounterpartyMTM](
	@as_of_date DATETIME
	,@counterparty_id INT
	,@bucket_id INT
)
RETURNS float
AS
BEGIN
	
	DECLARE @MTM Float

	SELECT @MTM=ISNULL(SUM(und_pnl),0)  FROM source_deal_header sdh
			INNER JOIN source_deal_pnl sdp ON sdh.source_deal_header_id = sdp.source_deal_header_id
			WHERE sdp.pnl_as_of_date = @as_of_date 
			AND ISNULL(sdh.counterparty_id, 0) = ISNULL(@counterparty_id, 0)
			AND ((sdp.term_start BETWEEN dbo.FNAGetRiskBucketAdjustedTerm(@as_of_date, @bucket_id, 1) 
										AND dbo.FNAGetRiskBucketAdjustedTerm(@as_of_date, @bucket_id, 0) AND @bucket_id IS NOT NULL) OR @bucket_id IS NULL) 
		

	RETURN ISNULL(@MTM,0)
	
END

