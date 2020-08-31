IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARAverageQtrDailyPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARAverageQtrDailyPrice]
GO
CREATE FUNCTION [dbo].[FNARAverageQtrDailyPrice](@maturity_date DATETIME, @curve_id INT, @month INT)
RETURNS FLOAT AS  
BEGIN 
	--SELECT [dbo].[FNARAverageQtrDailyPrice]('2013-05-01',1788, 1)
	DECLARE @avg_price FLOAT
	DECLARE @new_maturity_date DATETIME = @maturity_date
	SET @month = @month * 3
	IF @month <> 0
	SET @new_maturity_date = DATEADD(MONTH, @month, @maturity_date)


	SELECT @avg_price = --spc.curve_value,flag,substring(a.hr,3,2)
	       AVG(spc.curve_value)
	FROM   source_price_curve_def spcd
	       INNER JOIN source_price_curve spc
	            ON  spc.source_curve_def_id = spcd.source_curve_def_id
	WHERE  spcd.source_curve_def_id = @curve_id
			AND DATEPART(qq, spc.maturity_date) =  DATEPART(qq, @new_maturity_date)
			AND DATEPART(yy, spc.maturity_date) =  DATEPART(yy, @new_maturity_date)
	         
	RETURN @avg_price 
	
END

