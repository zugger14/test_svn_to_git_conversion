IF OBJECT_ID('FNARRelativePeriod', 'FN') IS NOT NULL 
	DROP FUNCTION dbo.FNARRelativePeriod 
	
/****** Object:  UserDefinedFunction [dbo].[FNARRelativePeriod]    Script Date: 10/30/2009 10:24:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select dbo.FNARPriorCurve('3/2/2004', 99, 14)
CREATE FUNCTION [dbo].[FNARRelativePeriod] (		
		@maturity_date datetime, 
		@as_of_date DATETIME,
		@curve_source_value_id int,
		@curve_id INT,
		@period INT -- 0 Day, 1 Month, 2 year
	)
RETURNS float AS  
BEGIN 
	declare @x as INT

	IF @period=0
		select @x = DATEDIFF(day,@as_of_date,@maturity_date) 
	IF @period=1
		select @x = DATEDIFF(MONTH,@as_of_date,@maturity_date) 
	IF @period=2
		select @x = DATEDIFF(YEAR,@as_of_date,@maturity_date) 


	return ISNULL(@x,0)
END














