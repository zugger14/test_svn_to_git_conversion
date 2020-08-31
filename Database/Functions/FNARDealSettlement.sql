/****** Object:  UserDefinedFunction [dbo].[FNARDealSettlement]    Script Date: 09/15/2011 11:38:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDealSettlement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDealSettlement]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARDealSettlement]    Script Date: 09/15/2011 11:39:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- select [dbo].[FNARDealSettlement](NULL,'2012-01-31','2012-01-01','s',48425,341) 
CREATE FUNCTION [dbo].[FNARDealSettlement] (
				@source_deal_detail_id INT,
				@as_of_date DATETIME,
				@prod_date DATETIME, 
				@settlemnt_type CHAR(1), -- 's' settled, 'e' Estimate
				@source_deal_header_id INT,
				@deal_type INT
				)
RETURNS float AS  
BEGIN 
	DECLARE @settled_value FLOAT
	
	
	
	IF @source_deal_detail_id IS NULL
		SELECT @source_deal_detail_id= MAX(source_deal_detail_id) from source_deal_detail sdd
			WHERE source_deal_header_id=@source_deal_header_id
				AND YEAR(sdd.term_start) = YEAR(@prod_date)
				AND MONTH(sdd.term_start) = MONTH(@prod_date)
	
	

	
		SELECT @settled_value = SUM(sds.settlement_amount)
		FROM 
			source_deal_settlement sds INNER JOIN
			source_deal_detail sdd on sdd.source_deal_header_id = sds.source_deal_header_id and
				sdd.leg = sds.leg
			AND (sds.set_type = 'f' AND sds.as_of_date = @as_of_date OR ( sds.set_type = 's' AND @as_of_date>= sds.term_end))	
			INNER JOIN source_deal_header sdh ON sds.source_deal_header_id = sdh.source_deal_header_id
		WHERE
			sdd.source_deal_detail_id = @source_deal_detail_id
			AND YEAR(sds.term_start) = YEAR(@prod_date)
			AND MONTH(sds.term_start) = MONTH(@prod_date)
			--AND sdh.source_deal_type_id = @deal_type


	IF convert(varchar(8),@as_of_date, 120)+'01' = convert(varchar(8),@prod_date, 120)+'01'  -- for the current month add current and forward value
		SELECT @settled_value = @settled_value+ ISNULL(SUM(sdp.und_pnl_set),0)
		FROM 
			source_deal_pnl sdp 
			INNER JOIN source_deal_header sdh ON sdp.source_deal_header_id = sdh.source_deal_header_id 
				AND sdh.source_deal_header_id=@source_deal_header_id
		WHERE
			sdp.pnl_as_of_date = @as_of_date
			AND YEAR(sdp.term_start) = YEAR(@prod_date)
			AND MONTH(sdp.term_start) = MONTH(@prod_date)
			AND sdh.source_deal_type_id = @deal_type					
			
		
	RETURN isnull(@settled_value, 0)
END




GO


