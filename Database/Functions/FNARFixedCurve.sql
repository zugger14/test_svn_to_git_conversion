/****** Object:  UserDefinedFunction [dbo].[FNARFixedCurve]    Script Date: 07/28/2009 18:07:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARFixedCurve]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARFixedCurve]
/****** Object:  UserDefinedFunction [dbo].[FNARFixedCurve]    Script Date: 07/28/2009 18:07:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select dbo.[FNARFixedCurve]('3/2/2004','3/2/2004',982,1,1)

CREATE FUNCTION [dbo].[FNARFixedCurve] (
	@maturity_date datetime,
	@as_of_date datetime, 
	@granularity INT,
	@he INT,
	@source_curve_def_id int
	)
RETURNS float AS  
BEGIN 
	declare @max_as_of_date DATETIME
	declare @max_maturity_date datetime
	declare @x as float

	SELECT @max_as_of_date=max(as_of_date),@max_maturity_date =max(maturity_date)
	FROM 
		source_price_curve
	WHERE
		source_curve_def_id = @source_curve_def_id and
		assessment_curve_type_value_id in (77,78) and 
		curve_source_value_id = 4500 		

	IF @he=0
		set @he=0
	ELSE
		set @he=@he-1
	SET @max_maturity_date = dbo.FNAGetSQLStandardDate(@max_maturity_date) + ' ' + 
			case when (@he < 10) then '0' else '' end +
			cast(@he as varchar) + ':00:00'		


	select 
		@x = MAX(curve_value) 
	from 
		source_price_curve
	where 	
		source_curve_def_id = @source_curve_def_id and
		as_of_date = @max_as_of_date and
		assessment_curve_type_value_id in (77,78) and 
		curve_source_value_id = 4500 and
		dbo.FNAGetSQLStandardDateTime(maturity_date) = @max_maturity_date
		--AND he=@he
	--return isnull(@x, 0)
	return @x
END








