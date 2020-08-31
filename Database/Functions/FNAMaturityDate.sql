IF OBJECT_ID('[dbo].[FNAMaturityDate]','fn') IS NOT NULL
DROP FUNCTION [dbo].[FNAMaturityDate]
go
/*
	Author:Pawan KC
	TimeStamp:16 March, 2009 4:30PM
	Purpose:This Function returns the Maturity Date of any Curve with its respective Granularity in the View Price Module.
	
*/
CREATE FUNCTION [dbo].[FNAMaturityDate](@as_of_date DATETIME,@curve_id INT)
RETURNS Varchar(50)
AS
BEGIN
	DECLARE @MaturityDate AS VARCHAR(50)
	DECLARE @tmp_value_id AS INT
	DECLARE @tmpMaturityDate AS DATETIME
	
	SELECT @tmp_value_id = value_id 
	FROM source_price_curve_def spcd
	JOIN static_data_value sdv ON sdv.value_id=spcd.granularity
	WHERE source_curve_def_id=@curve_id

	--Daily
	IF(@tmp_value_id=981)
	SET @MaturityDate= DATEADD(Day,1,@as_of_date)
	
	--Weekly
	ELSE IF(@tmp_value_id=990)
	BEGIN
		SET @tmpMaturityDate=DATEADD(wk, DATEDIFF(wk,0,@as_of_date), 0)
		SET @MaturityDate= DATEADD(wk,1,@tmpMaturityDate)  
	END

	--Monthly,Hourly,30Mins,15Mins
	ELSE IF(@tmp_value_id=980 OR @tmp_value_id=982 OR @tmp_value_id=989 OR @tmp_value_id=987)
	BEGIN
	
		SET @tmpMaturityDate=DATEADD(mm,DATEDIFF(mm,0,@as_of_date), 0)	
		SET @MaturityDate = DATEADD(Month,1,@tmpMaturityDate)
	END

	--Quaterly
	ELSE IF(@tmp_value_id=991)
	BEGIN
		SET @tmpMaturityDate= DATEADD(Quarter,DATEDIFF(Quarter,1,@as_of_date),0)
		SET @MaturityDate=DATEADD(Quarter,1,@tmpMaturityDate)
	END
	--Semi Annually
	ELSE IF(@tmp_value_id=992)
	BEGIN
		SET	@MaturityDate=
				(CASE 
					WHEN (DATEPART(mm,@as_of_date) BETWEEN 1 and 6 ) 
						THEN CAST(DATEPART(yy,@as_of_date)AS VARCHAR)+'-07-01'
					ELSE  CAST(DATEPART(yy,@as_of_date)+1 AS VARCHAR)+'-01-01' 
				 END
				)	 
	END	
	--Annually
	ELSE IF(@tmp_value_id=993)
	BEGIN
		SET @tmpMaturityDate= DATEADD(YEAR,DATEDIFF(YEAR,1,@as_of_date),0)
		SET @MaturityDate=DATEADD(YEAR,1,@tmpMaturityDate)
	END

	RETURN(dbo.FNADateFormat(@MaturityDate))
END

