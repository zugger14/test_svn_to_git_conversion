/****** Object:  UserDefinedFunction [dbo].[FNARCurve30]    Script Date: 02/14/2011 15:45:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARCurve30]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARCurve30]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARCurve30]    Script Date: 02/14/2011 15:45:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARCurve30] (@he int, @half int, @maturity_date datetime, @curve_source_value_id int, @volume_mult float,@curve_shift_val float ,@curve_shift_per float)
RETURNS float AS  
BEGIN 
	declare @x as float
	declare @maturity as varchar(30)
	declare @half_min as varchar(2);

	select @curve_shift_val=isnull(@curve_shift_val,0),@curve_shift_per=isnull(@curve_shift_per,1)


	if @half = 1
		set @half_min = '00';
	else if @half = 2
		set @half_min = '30';


	set @x = NULL

	If @he IS NULL
		Return NULL

	--set @he=@he-1
	SET @maturity = dbo.FNAGetSQLStandardDate(@maturity_date) + ' ' + 
			case when (@he < 10) then '0' else '' end +
			cast(@he as varchar) + ':'+@half_min+':00'		

	select @x = (curve_value+ @curve_shift_val) * @curve_shift_per 
	from source_price_curve
	where 	source_curve_def_id = @curve_source_value_id and
		as_of_date = @maturity_date and
		assessment_curve_type_value_id = 78 and --spot daily
		curve_source_value_id = 4500 and
		dbo.FNAGetSQLStandardDateTime(maturity_date) = @maturity
		
	--return isnull(@x, 0)
	return (@x* isnull(@volume_mult, 1))
END


















GO


