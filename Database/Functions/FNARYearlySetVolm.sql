/****** Object:  UserDefinedFunction [dbo].[FNARYearlySetVolm]    Script Date: 04/07/2009 17:17:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARYearlySetVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARYearlySetVolm]
/****** Object:  UserDefinedFunction [dbo].[FNARYearlySetVolm]    Script Date: 04/07/2009 17:17:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select [dbo].[FNARYearlySetVolm]('2012-01-31','2012-01-01',NULL,NULL,NULL,48425,19002) 
CREATE FUNCTION [dbo].[FNARYearlySetVolm](
	@as_of_date DATETIME,
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
      SELECT @deal_volume=SUM(sdd.volume)
      FROM 
            source_deal_settlement sdd 
            join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id   
      WHERE 1=1
            AND sdd.as_of_date=@as_of_date
            AND sdh.contract_id=@contract_id
            AND sdh.counterparty_id=@counterparty_id
            AND YEAR(sdd.term_start) = YEAR(@term_start) 
            AND (sdd.set_type = 'f' AND sdd.as_of_date = @as_of_date OR ( sdd.set_type = 's' AND @as_of_date>= sdd.term_end))
			--AND leg=1
			
	ELSE IF @aggregation_level=19000
      SELECT @deal_volume=SUM(sdd.volume)+ISNULL(SUM(sdp.deal_volume*CASE WHEN sdp.buy_sell_flag='s' THEN -1 ELSE 1 END),0)
      FROM 
            source_deal_settlement sdd 
            LEFT JOIN source_deal_pnl_detail sdp ON sdd.source_deal_header_id=sdp.source_deal_header_id
				AND sdp.term_start=sdd.term_start
				AND sdp.leg=sdd.leg
				AND sdp.pnl_as_of_date=@as_of_date
				AND convert(varchar(8),@as_of_date, 120)+'01' = convert(varchar(8),@term_start, 120)+'01'
				
      WHERE 1=1
			AND sdd.source_deal_header_id=@source_deal_header_id
            AND YEAR(sdd.term_start) = YEAR(@term_start) 
            AND (sdd.set_type = 'f' AND sdd.as_of_date = @as_of_date OR ( sdd.set_type = 's' AND @as_of_date>= sdd.term_end))

	ELSE IF @aggregation_level=19002
      SELECT @deal_volume=SUM(sds.volume)+ISNULL(SUM(sdp.deal_volume*CASE WHEN sdp.buy_sell_flag='s' THEN -1 ELSE 1 END),0)
      FROM 
            source_deal_settlement sds
            INNER JOIN source_deal_detail sdd ON sds.source_deal_header_id=sdd.source_deal_header_id
				AND sds.term_start=sdd.term_start
				AND sdd.leg=sds.leg		
			AND (sds.set_type = 'f' AND sds.as_of_date = @as_of_date OR ( sds.set_type = 's' AND @as_of_date>= sdd.term_end))			
            LEFT JOIN source_deal_pnl_detail sdp ON sdd.source_deal_header_id=sdp.source_deal_header_id
				AND sdp.term_start=sdd.term_start
				AND sdp.leg=sdd.leg
				AND sdp.pnl_as_of_date=@as_of_date
				AND convert(varchar(8),@as_of_date, 120)+'01' = convert(varchar(8),@term_start, 120)+'01'	 
      WHERE 1=1
            AND sdd.source_deal_detail_id=@source_deal_detail_id
            AND YEAR(sdd.term_start) = YEAR(@term_start) 
	
			
	return @deal_volume
END


