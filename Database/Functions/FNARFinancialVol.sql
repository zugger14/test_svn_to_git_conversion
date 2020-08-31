/****** Object:  UserDefinedFunction [dbo].[FNARFinancialVol]    Script Date: 09/15/2011 11:39:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARFinancialVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARFinancialVol]
GO


/****** Object:  UserDefinedFunction [dbo].[FNARFinancialVol]    Script Date: 09/15/2011 11:39:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
select [dbo].FNARDealFixedVolm(123,1)
*/
CREATE FUNCTION [dbo].[FNARFinancialVol](
	@counterparty_id INT,
	@contract_id INT,
	@term_start DATETIME,
	@hr INT
)

RETURNS FLOAT AS
BEGIN

--RETURN 7.0

DECLARE @deal_volume FLOAT

	SELECT @deal_volume = 
			SUM(sdd.deal_volume* CASE WHEN sdd.buy_sell_flag='b' THEN 1 ELSE -1 END)
		FROM
				source_deal_detail sdd
				join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
		WHERE
				sdh.contract_id=@contract_id
				AND sdh.counterparty_id=@counterparty_id
				--AND sdd.term_start= dbo.FNAGetContractMonth(@term_start)
				AND YEAR(sdd.term_start) = YEAR(@term_start)
				AND MONTH(sdd.term_start) = MONTH(@term_start)
				AND sdd.physical_financial_flag ='f'
	
	RETURN (@deal_volume)

END



GO


