IF OBJECT_ID('FNARPriceCurve') IS NOT NULL
DROP FUNCTION dbo.FNARPriceCurve
GO

CREATE FUNCTION [dbo].[FNARPriceCurve](@as_of_date DATETIME, @maturity_date DATETIME,@he int,@mins int,@is_dst INT, @curve_id INT, @adder FLOAT, @multiplier FLOAT)
	RETURNS FLOAT
AS
BEGIN
	
	/*
	--TEST DATA
	DECLARE 
		@as_of_date	datetime = '2013-7-1'
		, @maturity_date	DATETIME = '2013-11-3'
		, @he	INT = 1
		, @mins	INT = 0
		, @is_dst	INT = 0
		, @curve_id	INT = 6
		, @adder	FLOAT = 2
		, @multiplier	FLOAT = 1
	 
	--*/
	
	DECLARE @granularity INT,@min_d VARCHAR(2),@act_maturity_date DATETIME
	
	IF @he>0
		SET @he=@he-1

	SET @min_d = '00'
		
	IF @mins = 1 or @mins=15
		SET @min_d = '00';
	ELSE IF @mins = 2 or @mins=30
		SET @min_d = '15';
	ELSE IF @mins = 3 or @mins=45
		SET @min_d = '30';
	ELSE IF @mins = 4 or @mins=60
		SET @min_d = '45';	
	
		
	SET @act_maturity_date =dbo.FNAGetSQLStandardDate(@maturity_date) + ' ' + 
										case when (@he < 10) then '0' else '' end +
										cast(@he as varchar) + ':'+@min_d+':00'	

	DECLARE @value					FLOAT	
	DECLARE @curve_source_value_id	INT 
	
	SET @curve_source_value_id = 4500
	
	--SELECT @act_maturity_date
	
	--SELECT  (curve_value*ISNULL(@multiplier, 1))+ISNULL(@adder, 0), *
	SELECT @value = (curve_value*ISNULL(@multiplier, 1))+ISNULL(@adder, 0)
	FROM   source_price_curve
	WHERE  source_curve_def_id = @curve_id
	       AND as_of_date = @as_of_date
	       AND maturity_date = @act_maturity_date
	       AND curve_source_value_id = @curve_source_value_id
	       AND is_dst = @is_dst
	
	
	RETURN @value
END
