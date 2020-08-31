/****** Object:  UserDefinedFunction [dbo].[FNARDMTMChange]    Script Date: 12/09/2010 17:08:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDMTMChange]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDMTMChange]
/****** Object:  UserDefinedFunction [dbo].[FNARDMTMChange]    Script Date: 12/09/2010 17:08:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
select dbo.[FNARDMTMChange]('2012-01-02',19,18,NULL,156786,19000)
select dbo.[FNARDMTMChange]('2012-01-02',19,73,NULL,156786,19001)

*/
CREATE FUNCTION [dbo].[FNARDMTMChange](
	@as_of_date DATETIME,
	@counterparty_id INT,
	@contract_id INT,
	@source_deal_detail_id INT,
	@source_deal_header_id INT,
	@aggregation_level INT
)

RETURNS FLOAT AS
BEGIN

--RETURN 7.0

DECLARE @mtm FLOAT,@prev_busines_day DATETIME

SELECT @prev_busines_day = dbo.FNAGetBusinessDay ('p',@as_of_date,291898)

	IF @aggregation_level=19001
		SELECT @mtm = 
				SUM(sdp.und_pnl) - ISNULL(SUM(sdp1.und_pnl),0)
						from 
							source_deal_pnl sdp
							INNER JOIN source_deal_header sdh on sdp.source_deal_header_id=sdh.source_deal_header_id	
							OUTER APPLY(
									SELECT und_pnl FROM source_deal_pnl  
									WHERE source_deal_header_id = sdp.source_deal_header_id
										  AND term_start = sdp.term_start
										  AND pnl_as_of_date = @prev_busines_day) sdp1	
							
						where 1=1
							AND sdh.contract_id=@contract_id
							AND sdh.counterparty_id=@counterparty_id
							AND sdp.pnl_as_of_date= @as_of_date	
	
	ELSE IF @aggregation_level=19000
      SELECT @mtm = 
				SUM(sdp.und_pnl) - ISNULL(SUM(sdp1.und_pnl),0) 
						from 
							source_deal_pnl sdp
							INNER JOIN source_deal_header sdh on sdp.source_deal_header_id=sdh.source_deal_header_id	
							OUTER APPLY(
									SELECT und_pnl FROM source_deal_pnl  
									WHERE source_deal_header_id = sdp.source_deal_header_id
										  AND term_start = sdp.term_start
									  AND pnl_as_of_date = @prev_busines_day) sdp1								
						WHERE 1=1
							AND sdh.source_deal_header_id=@source_deal_header_id
							AND sdp.pnl_as_of_date= @as_of_date	

	
	RETURN (@mtm)

END


