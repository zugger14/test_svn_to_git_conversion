/****** Object:  UserDefinedFunction [dbo].[FNARContractualOnPeakVolm]    Script Date: 12/09/2010 17:08:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARContractualOnPeakVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARContractualOnPeakVolm]
/****** Object:  UserDefinedFunction [dbo].[FNARContractualVolm]    Script Date: 12/09/2010 17:08:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
select [dbo].FNARDealFixedVolm(123,1)
*/
CREATE FUNCTION [dbo].[FNARContractualOnPeakVolm](
	@term_start DATETIME,
	@counterparty_id INT,
	@contract_id INT
)

RETURNS FLOAT AS
BEGIN

DECLARE @deal_volume FLOAT

	SELECT @deal_volume = 
			SUM(sdd.total_volume*CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END*ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1)) 
					from 
						source_deal_detail sdd 
						join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
						join source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
					where 1=1
						AND sdh.contract_id=@contract_id
						AND sdh.counterparty_id=@counterparty_id
						AND sdd.term_start= dbo.FNAGETCONTRACTMONTH(@term_start)		
						AND ISNULL(product_id,4)=4
						AND sdd.leg=1	
						--AND spcd.block_type=12000
					
	
	RETURN abs(@deal_volume)

END


