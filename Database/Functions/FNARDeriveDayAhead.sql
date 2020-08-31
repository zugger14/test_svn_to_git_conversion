--IF OBJECT_ID(N'FNARDAWA', N'FN') IS NOT NULL
--    DROP FUNCTION [dbo].[FNARDAWA]
--GO 

IF OBJECT_ID(N'FNARDeriveDayAhead', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARDeriveDayAhead]
GO 

CREATE FUNCTION [dbo].[FNARDeriveDayAhead]
(
	
	@source_curve_def_id1    INT,
	@source_curve_def_id2    INT,
	@default_holiday_id int,
	@as_of_date DATETIME
	
	
)
RETURNS FLOAT
AS

/*

	--select * from source_price_curve where source_curve_def_id=4499

	--update source_price_curve  set maturity_date ='2016-01-04' where  maturity_date ='2016-01-09 00:00:00.000' and source_curve_def_id=4499

	--update source_price_curve  set as_of_date ='2015-12-31' where  as_of_date ='2016-01-04' and source_curve_def_id=4499

	--select * from source_price_curve_def

	declare 	@source_curve_def_id1    INT=4498,
		@source_curve_def_id2    INT=4499,
		@as_of_date DATETIME='2016-01-01',
		@default_holiday_id int=null
	
--*/
BEGIN

	DECLARE @curve_value AS FLOAT

	select  @default_holiday_id=ISNULL(@default_holiday_id,[def_code_id]) from [dbo].[default_holiday_calendar]

	SELECT @curve_value = 
	  curve_value FROM
	(
		--weekday
		SELECT curve_value FROM source_price_curve
		WHERE  source_curve_def_id = @source_curve_def_id1
		AND as_of_date = dbo.FNAGetBusinessDay('p', @as_of_date, @default_holiday_id)
		AND maturity_date = @as_of_date 
		AND DATEPART(weekday,maturity_date) NOT IN (7,1) 
		
		UNION ALL
		--weekend non_holiday
		SELECT curve_value FROM source_price_curve  where 
				source_curve_def_id = @source_curve_def_id2
					AND maturity_date = @as_of_date
					AND DATEPART(weekday,maturity_date)  IN (7,1)
					and DATEPART(weekday,as_of_date)  IN (6) 
			 and dbo.FNAGetBusinessDay('p', as_of_date+1, @default_holiday_id)=as_of_date
		
		union all
		
		--weekend holiday
		SELECT curve_value FROM
		source_price_curve  where 
			source_curve_def_id = @source_curve_def_id2
				AND maturity_date = @as_of_date 
			AND DATEPART(weekday,maturity_date)  IN (6,7,1,2) 
		 and dbo.FNAGetBusinessDay('p', @as_of_date+1, @default_holiday_id)<>@as_of_date
		 and dbo.FNAGetBusinessDay('p', @as_of_date+1, @default_holiday_id)=as_of_date
		

		
	) c
	
	return ISNULL(@curve_value,0)
	
END
