/****** Object:  UserDefinedFunction [dbo].[FNARCounterpartyNetPwrPurchase]    Script Date: 02/10/2010 20:33:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARCounterpartyNetPwrPurchase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARCounterpartyNetPwrPurchase]

/****** Object:  UserDefinedFunction [dbo].[FNARCounterpartyNetPwrPurchase]    Script Date: 02/10/2010 20:33:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================================================
-- Create date: 2010-01-29 12:50PM
-- Description:	Returns deal volume of physical deals associated with the given counterparty for the given bucket adjusted as_of_date
-- Param: 
--	@as_of_date datetime - as of date
--	@counterparty_id int - Counterparty ID
--	@bucket_id int - risk bucket id
-- Returns: deal volume
-- =============================================================================================================
CREATE FUNCTION [dbo].[FNARCounterpartyNetPwrPurchase](
	@as_of_date DATETIME
	,@counterparty_id INT
	,@bucket_id INT
)
RETURNS float
AS
BEGIN
	
	DECLARE @Volume Float

	SELECT @Volume=ISNULL(SUM(CASE WHEN (sdh.option_flag = 'y') THEN 
								CASE WHEN ISNULL(sdd.leg,-1) = 1 THEN 
									(CASE WHEN sdpd.buy_sell_flag = 'b' THEN 1 ELSE - 1 END) * sdpd.deal_volume * DELTA 
									--WHEN  ISNULL(sdd.leg,-1)=2 THEN sdpdo.deal_volume2 * DELTA2 
								ELSE 0 END 
							ELSE  
							(CASE WHEN sdpd.buy_sell_flag = 'b' THEN 1 ELSE - 1 END) * sdpd.deal_volume END),0) 
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4	
--			INNER JOIN source_deal_pnl sdp ON sdp.source_deal_header_id=sdh.source_deal_header_id
--				AND sdp.term_start = sdd.term_start
--				AND sdp.leg = sdd.leg
			LEFT JOIN source_deal_pnl_detail sdpd ON sdpd.source_deal_header_id = sdd.source_deal_header_id
				AND sdpd.term_start = sdd.term_start
				AND sdpd.leg = sdd.leg
				--AND sdpd.Leg = 1
			LEFT JOIN source_deal_pnl_detail_options sdpdo	
				ON sdpdo.source_deal_header_id=sdh.source_deal_header_id
				AND sdpdo.term_start=sdd.term_start
				AND sdpdo.as_of_date=sdpd.pnl_as_of_date
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
			LEFT JOIN source_commodity sc ON sc.source_commodity_id = spcd.commodity_id
			WHERE ssbm.fas_deal_type_value_id <> 409 
				AND sdpd.pnl_as_of_date = @as_of_date
				AND ISNULL(sdh.counterparty_id, 0) = ISNULL(@counterparty_id, 0)
				AND sc.commodity_name <> 'Natural Gas'
				AND sdd.physical_financial_flag = 'p'
				AND sdd.term_start BETWEEN dbo.FNAGetRiskBucketAdjustedTerm(@as_of_date, @bucket_id, 1) 
										AND dbo.FNAGetRiskBucketAdjustedTerm(@as_of_date, @bucket_id, 0)
	
	RETURN ISNULL(@Volume,0)
	
END


