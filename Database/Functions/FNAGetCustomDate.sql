--select code,value_id from static_data_value where type_id=45600
/*

Current Business Day				45601 -
Current Day							45600 -
First Business Day of the Month		45604 -
First Business Day of the Week		45608 -
First Day of the Month				45602 -
First Day of the Week				45606 -
Last Business Day of the Month		45605 -
Last Business Day of the Week		45609 -
Last Day of the Month				45603 -
Last Day of the Week				45607 -
Use Report Setting					45610

*/

--select dbo.fnagetcustomdate(45600,'d',2,307350)

IF OBJECT_ID('dbo.FNAGetCustomDate') IS NOT NULL
	DROP FUNCTION dbo.FNAGetCustomDate
go

CREATE FUNCTION dbo.FNAGetCustomDate(@custom_date_type  int, @adjustment_number int, @holiday_calendar_id int)
RETURNS datetime AS  
BEGIN 
	--set @custom_date_type = 45605
	--set @adjustment_number = 0

	declare @return_value datetime

	declare @date_reference datetime = getdate()
	set @holiday_calendar_id = ISNULL(nullif(@holiday_calendar_id, ''),307350)

	set @return_value = DATEADD (day, @adjustment_number, 
		case @custom_date_type
			when 45600 then @date_reference --current day
			when 45602 then dbo.FNAGetFirstLastDayOfMonth(@date_reference, 'f') --first day of month
			when 45603 then dbo.FNAGetFirstLastDayOfMonth(@date_reference, 'l') --last day of month
			when 45606 then DATEADD(DAY, 1-DATEPART(WEEKDAY, @date_reference), @date_reference) --first day of week
			when 45607 then DATEADD(wk, 1, DATEADD(DAY, 0-DATEPART(WEEKDAY, @date_reference), DATEDIFF(dd, 0, @date_reference))) --last day of week
			when 45601 then 
				case when DATENAME(DW, @date_reference) in ('saturday','sunday') or exists(select top 1 1 from holiday_group where hol_group_value_id=@holiday_calendar_id and hol_date = @date_reference)
					 then dbo.FNAGetBusinessDay('p', @date_reference, @holiday_calendar_id) else @date_reference
				end --current business day (if current day is holiday , return previous business day)
			when 45604 then 
				case when DATENAME(DW, dbo.FNAGetFirstLastDayOfMonth(@date_reference, 'f')) in ('saturday','sunday') or exists(select top 1 1 from holiday_group where hol_group_value_id=@holiday_calendar_id and hol_date = dbo.FNAGetFirstLastDayOfMonth(@date_reference, 'f'))
					 then dbo.FNAGetBusinessDay('n', dbo.FNAGetFirstLastDayOfMonth(@date_reference, 'f'), @holiday_calendar_id) else dbo.FNAGetFirstLastDayOfMonth(@date_reference, 'f')
				end --First Business Day of the Month
			when 45605 then 
				case when DATENAME(DW, dbo.FNAGetFirstLastDayOfMonth(@date_reference, 'l')) in ('saturday','sunday') or exists(select top 1 1 from holiday_group where hol_group_value_id=@holiday_calendar_id and hol_date = dbo.FNAGetFirstLastDayOfMonth(@date_reference, 'l'))
					 then dbo.FNAGetBusinessDay('p', dbo.FNAGetFirstLastDayOfMonth(@date_reference, 'l'), @holiday_calendar_id) else dbo.FNAGetFirstLastDayOfMonth(@date_reference, 'l')
				end --Last Business Day of the Month
			when 45608 then dbo.FNAGetBusinessDay('n', DATEADD(DAY, 1-DATEPART(WEEKDAY, @date_reference), @date_reference), @holiday_calendar_id) --First Business Day of the Week
			when 45609 then dbo.FNAGetBusinessDay('p', DATEADD(wk, 1, DATEADD(DAY, 0-DATEPART(WEEKDAY, @date_reference), DATEDIFF(dd, 0, @date_reference))), @holiday_calendar_id) --Last Business Day of the Week
			

		end
		)

	--select @return_value
	return @return_value
end
--select datediff(WW, 0, getdate())
--SELECT  dateadd(ww, datediff(ww, 0, getdate()), 6)
--select * from holiday_group where hol_group_value_id=307350 and hol_date='2017-10-19'
--select * from static_data_value where type_id=10017

--select name from sys.tables where name like '%holiday%'
--select * from adiha_default_codes
--select * from adiha_default_codes_values where default_code_id=52
--select * from adiha_default_codes_values_possible where default_code_id=52
--select * from adiha_default_codes_params where default_code_id=52

--select * from default_holiday_calendar

--select * from excel_sheet where report_id is not null

