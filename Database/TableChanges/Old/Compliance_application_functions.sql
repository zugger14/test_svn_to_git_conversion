if not exists (select 'x' from application_functions where function_id = 11000002)
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	 Values
	(11000002,'Holiday Calendar','Holiday Calendar',10101000,'windowMaintainHolidayCalendar')

if not exists (select 'x' from application_functions where function_id = 11000001)
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call) 
	Values
	(11000001,'Working Days Properties','Working Days Properties',10101000,'windowMaintainWorkingDays')