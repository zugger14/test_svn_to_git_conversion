/****** Object:  UserDefinedFunction [dbo].[FNARCptCollateral]    Script Date: 12/07/2010 16:46:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARCptCollateral]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARCptCollateral]
/****** Object:  UserDefinedFunction [dbo].[FNARCptCollateral]    Script Date: 12/07/2010 16:47:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT [dbo].[FNARCptCollateral]('2012-01-01',42)
CREATE FUNCTION [dbo].[FNARCptCollateral](@as_of_date DATETIME,@counterparty_id INT)
RETURNS FLOAT AS  
BEGIN 
	DECLARE @collateral_amount FLOAT
	
	SELECT @collateral_amount = SUM(amount)
	FROM
		source_counterparty sc 
		INNER JOIN counterparty_credit_info cci ON cci.counterparty_id = sc.source_counterparty_id
		INNER JOIN counterparty_credit_enhancements cce ON cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
	WHERE
		sc.source_counterparty_id = @counterparty_id
		AND @as_of_date BETWEEN ISNULL(cce.eff_date,'1900-01-01') AND ISNULL(cce.expiration_date,'9999-01-01')
			
	RETURN @collateral_amount	
	
	
END
