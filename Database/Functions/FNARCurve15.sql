
/****** Object:  UserDefinedFunction [dbo].[FNARCurve15]    Script Date: 09/15/2011 11:36:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARCurve15]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARCurve15]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARCurve15]    Script Date: 09/15/2011 11:36:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARCurve15] (@maturity_date DATETIME,@as_of_date DATETIME, @curve_source_value_id INT, @volume_mult FLOAT,@he int,@mins int,@curve_shift_val FLOAT ,@curve_shift_per FLOAT)
RETURNS float AS  
BEGIN 
	declare @x as float
	declare @maturity as varchar(30)
	declare @qtr_min as varchar(2);

	select @curve_shift_val=isnull(@curve_shift_val,0),@curve_shift_per=isnull(@curve_shift_per,1)



	if @mins = 1 or @mins=15
		set @qtr_min = '00';
	else if @mins = 2 or @mins=30
		set @qtr_min = '15';
	else if @mins = 3 or @mins=45
		set @qtr_min = '30';
	else if @mins = 4 or @mins=60
		set @qtr_min = '45';


	set @x = NULL

	If @he IS NULL
		Return NULL

	set @he=@he-1
	SET @maturity = dbo.FNAGetSQLStandardDate(@maturity_date) + ' ' + 
			case when (@he < 10) then '0' else '' end +
			cast(@he as varchar) + ':'+@qtr_min+':00'		

	SELECT @x = (curve_value+ @curve_shift_val) * @curve_shift_per 
	FROM 
		source_price_curve
	WHERE
		source_curve_def_id = @curve_source_value_id and
		as_of_date = @maturity_date and
		assessment_curve_type_value_id = 77 and --spot daily
		curve_source_value_id = 4500 and
		dbo.FNAGetSQLStandardDateTime(maturity_date) = @maturity


	RETURN (@x* isnull(@volume_mult, 1))
END


GO


