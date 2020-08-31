IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARContractFixPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARContractFixPrice]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARContractFixPrice]
(
	@product_type	INT, 
	@price_option	INT,
	@contract_id	INT,
	@effective_date	DATETIME,
	@as_of_date		DATETIME,
	@prod_date		DATETIME,
	@he				INT,
	@mins			INT,
	@is_dst			INT
)
RETURNS FLOAT 
AS  
BEGIN 
	DECLARE @return_value FLOAT
	DECLARE @curve_id INT
	
	IF @price_option = 0 -- Return Price Curve Value
	BEGIN
		SELECT	@curve_id = cp.curve_id
		FROM contract_price cp
		INNER JOIN source_price_curve_def spcd ON cp.curve_id = spcd.source_curve_def_id
		OUTER APPLY(SELECT MAX(effective_date) effective_date FROM contract_price WHERE contract_id=cp.contract_id
		AND product = cp.product AND effective_date <= ISNULL(@effective_date,'9999-01-01')) cp1
		WHERE cp.contract_id = @contract_id
			AND product = @product_type
			AND cp.effective_date = cp1.effective_date

		--SELECT @return_value = dbo.FNARContractPriceValue(@as_of_date, @as_of_date,@contract_id, @curve_id,NULL, NULL)
		SELECT @return_value = dbo.[FNARGetCurveValue] (@prod_date ,@as_of_date , @curve_id , 1 ,@he ,@mins,@is_dst ,0 ,1)
	END
	ELSE IF @price_option = 1 -- Return Adder
	BEGIN
		SELECT @return_value = cp.adder
		FROM contract_price cp
		OUTER APPLY(SELECT MAX(effective_date) effective_date FROM contract_price WHERE contract_id=cp.contract_id
		AND product = cp.product AND effective_date <= ISNULL(@effective_date,'9999-01-01')) cp1
		WHERE cp.contract_id = @contract_id
		AND product = @product_type
		AND cp.effective_date = cp1.effective_date
	END
	ELSE IF @price_option = 2 -- Return Fix Price
	BEGIN
		SELECT @return_value = cp.fix_price
		FROM contract_price cp
		OUTER APPLY(SELECT MAX(effective_date) effective_date FROM contract_price WHERE contract_id=cp.contract_id
		AND product = cp.product AND effective_date <= ISNULL(@effective_date,'9999-01-01')) cp1
		WHERE cp.contract_id = @contract_id
		AND product = @product_type
		AND cp.effective_date = cp1.effective_date
	END
	
	RETURN @return_value
END
