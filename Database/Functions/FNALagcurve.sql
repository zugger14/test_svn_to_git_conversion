IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNALagcurve]') AND [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNALagcurve]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNALagcurve](
	@curve_id INT,
	@Relative_Year INT, --( could be 0 or negative values. Negative value will use the prior year values)
	@Strip_Month_From TINYINT, --(i.e., 6)
	@Lag_Months tinyint, --(i.e., 2)
	@Strip_Month_To TINYINT, --(i.e., 6)
	@Convert_to_currency INT=null, -- (if passed null then don’t convert)
	@price_adder FLOAT,
	@volume_multiplier FLOAT,
	@expiration_type VARCHAR(30), 
	@expiration_value VARCHAR(30)	
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1.0
END