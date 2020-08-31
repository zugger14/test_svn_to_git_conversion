IF OBJECT_ID('[dbo].[FNAGetBusinessDayN]') IS NOT NULL 
	DROP FUNCTION [dbo].FNAGetBusinessDayN
GO 

-- select [dbo].[FNAGetBusinessDayN]('p','2018-01-02',null,5)


create FUNCTION [dbo].FNAGetBusinessDayN(
	@pre_next varchar(1)
	,@dt datetime
	,@holiday_calendar int
	,@no_point int
	)
RETURNS date AS
BEGIN
	

/*
BEGIN
	declare 
		@pre_next varchar(1)='p'
		,@dt datetime='2018-01-02'
		,@holiday_calendar int
		,@no_point int=5

--*/

	declare @BL_date datetime
	set @BL_date=@dt

	select @BL_date=dbo.FNAGetBusinessDay(@pre_next,@BL_date,@holiday_calendar) from seq where n<= @no_point
		
	return @BL_date
	--select @BL_date
END

		


