/****** Object:  UserDefinedFunction [dbo].[FNARDynamicCurve]    Script Date: 09/15/2011 11:41:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDynamicCurve]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDynamicCurve]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARDynamicCurve]    Script Date: 09/15/2011 11:41:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNARDynamicCurve](
		@prod_date DATETIME,
		@as_of_date DATETIME,
		@curve_id INT,
		@granularity INT
	
	)
	RETURNS float AS  
	BEGIN 
	DECLARE @value float

		SELECT @as_of_date = MAX(as_of_date) , @prod_date=MAX(maturity_date)
			FROM source_price_curve 
		WHERE 
			source_curve_def_id = @curve_id
			AND as_of_date<	@as_of_date
		
		SELECT @value=curve_value FROM source_price_curve WHERE source_curve_def_id = @curve_id
			AND as_of_date = @as_of_date
			AND maturity_date = @prod_date
	
		
		RETURN @value
	END
















GO


