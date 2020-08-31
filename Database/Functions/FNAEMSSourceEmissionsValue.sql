/****** Object:  UserDefinedFunction [dbo].[FNAEMSSourceEmissionsValue]    Script Date: 06/17/2009 21:28:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSSourceEmissionsValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSSourceEmissionsValue]
/****** Object:  UserDefinedFunction [dbo].[FNAEMSSourceEmissionsValue]    Script Date: 06/17/2009 21:28:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select [dbo].[FNAEMSSourceInput](127,'2007-02-01',3264,14303,1)

CREATE FUNCTION [dbo].[FNAEMSSourceEmissionsValue](
		@term DATETIME,
		@curve_id INT,
		@generator_id INT,
		@series_type INT,
		@year INT,	
		@no_of_month INT

	)

Returns Float
AS
BEGIN

DECLARE @value float
DECLARE @term_year INT
--SELECT @term=DATEADD(MONTH,ISNULL(@no_of_month,0)*-1,@term)

IF @no_of_month=0
	SELECT @term_year=year(@term)
ELSE IF 	@no_of_month=1
	SELECT @term_year=@year
ELSE
SELECT @term_year=@year+ISNULL(NULLIF((YEAR(@term)-@year-@no_of_month),-1),0)

	SELECT 
		@value=SUM(ISNULL(volume,reduction_volume))
	FROM 
		emissions_inventory ei
	WHERE	
		generator_id=@generator_id
		AND curve_id=@curve_id
		AND forecast_type=@series_type
		AND YEAR(term_start)=(@term_year)
		--AND MONTH(Term_start)=Month(@term)
	return ISNULL(@value,0)

END















