/****** Object:  UserDefinedFunction [dbo].[FNARContractPriceCurve]    Script Date: 09/15/2011 11:41:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARContractPriceValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARContractPriceValue]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARContractPriceCurve]    Script Date: 09/15/2011 11:41:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNARContractPriceValue](
		@prod_date DATETIME,
		@as_of_date DATETIME,
		@contract_id INT,
		@curve_id INT,
		@granularity INT,
		@index_group INT		
	)
	RETURNS float AS  
	BEGIN 
	DECLARE @value float

	SELECT 
			@granularity = spcd.granularity 
		FROM 
			source_price_curve_def spcd
		WHERE
			source_curve_def_id = @curve_id

	IF @index_group IS NOT NULL
	BEGIN
		SELECT 
			@curve_id = source_curve_def_id,
			@granularity = spcd.granularity 
		FROM 
			source_price_curve_def spcd
		WHERE
			contract_id = @contract_id
			AND index_group = @index_group
	END
	
		IF @granularity = 993
		SELECT @as_of_date = MAX(as_of_date) , @prod_date=MAX(maturity_date)
				FROM source_price_curve 
			WHERE 
				source_curve_def_id = @curve_id
				AND as_of_date<=	@as_of_date
				AND YEAR(maturity_date) = YEAR(@prod_date)

		ELSE IF @granularity = 980
			SELECT @as_of_date = MAX(spc.as_of_date) , @prod_date=MAX(spc.maturity_date)
				FROM source_price_curve spc
				CROSS APPLY(SELECT MAX(maturity_date) maturity_date FROM source_price_curve WHERE source_curve_def_id = spc.source_curve_def_id
					AND maturity_date <= @prod_date) spc1 
			WHERE 
				spc.source_curve_def_id = @curve_id
				AND as_of_date<=	@as_of_date
				AND spc.maturity_date = spc1.maturity_date




		SELECT @value=curve_value FROM source_price_curve WHERE source_curve_def_id = @curve_id
			AND as_of_date = @as_of_date
			AND maturity_date = @prod_date
	
		
		RETURN @value
	END
















GO


