IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARContractFees]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARContractFees]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARContractFees]
(
	@product_type	INT,
	@charges		INT,
	@contract_id	INT,
	@effective_date	DATETIME
)
RETURNS FLOAT 
AS  
BEGIN 
	DECLARE @value FLOAT

	SELECT TOP(1)  @value = value 
	FROM contract_fees cf
	OUTER APPLY(SELECT MAX(effective_date) effective_date FROM contract_fees WHERE contract_id=cf.contract_id
		AND product_type = cf.product_type AND charges = cf.charges AND effective_date <= ISNULL(@effective_date,'9999-01-01')) cf1
	WHERE contract_id = @contract_id
		AND product_type = @product_type
		AND charges = @charges
		AND	cf.effective_date = cf1.effective_date
	

	RETURN @value
END
