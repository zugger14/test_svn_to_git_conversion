/****** Object:  UserDefinedFunction [dbo].[FNARMnPrice]    Script Date: 06/15/2010 18:30:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARMnPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARMnPrice]
GO
CREATE FUNCTION [dbo].[FNARMnPrice](
	@deal_id int,
	@maturity_date DATETIME,
	@as_of_date DATETIME,
	@curve_id INT,
	@granularity INT
)
RETURNS float AS  
BEGIN 
DECLARE @avg_price FLOAT


IF @granularity=981
	select @avg_price=
			MIN(spc.curve_value)
	FROM
		source_price_curve_def spcd 
		INNER JOIN source_price_curve spc ON spc.source_curve_def_id=spcd.source_curve_def_id

	WHERE
		spcd.source_curve_def_id=@curve_id
		--AND spc.maturity_date=@maturity_date
		AND dbo.FNAGetContractMonth(spc.as_of_date)=dbo.FNAGetContractMonth(@as_of_date)
		AND dbo.FNAGetContractMonth(spc.maturity_date)=dbo.FNAGetContractMonth(@maturity_date)


ELSE IF @granularity=980
	select @avg_price=
			MIN(spc.curve_value)
	FROM
		source_price_curve_def spcd 
		INNER JOIN source_price_curve spc ON spc.source_curve_def_id=spcd.source_curve_def_id

	WHERE
		spcd.source_curve_def_id=@curve_id
		AND dbo.FNAGetContractMonth(spc.maturity_date)=dbo.FNAGetContractMonth(@maturity_date)
		AND spc.as_of_date=@as_of_date

ELSE IF @granularity=982
	select @avg_price=
			MIN(spc.curve_value)
	FROM
		source_price_curve_def spcd 
		INNER JOIN source_price_curve spc ON spc.source_curve_def_id=spcd.source_curve_def_id

	WHERE
		spcd.source_curve_def_id=@curve_id
		AND spc.maturity_date=@maturity_date
		AND spc.as_of_date=@as_of_date
		
ELSE IF @granularity=990
	SELECT @avg_price = MIN(spc.curve_value)
	FROM
		source_price_curve_def spcd 
		INNER JOIN source_price_curve spc ON spc.source_curve_def_id=spcd.source_curve_def_id

	WHERE
		spcd.source_curve_def_id=@curve_id
		AND DATEPART(w, spc.maturity_date) = DATEPART(w, @maturity_date)	
		AND spc.as_of_date=@as_of_date
				
	RETURN @avg_price
END
