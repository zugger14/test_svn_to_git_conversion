if COL_LENGTH('var_measurement_criteria_detail', 'use_market_value') is null --alter table 
begin
	alter table dbo.var_measurement_criteria_detail
	add use_market_value char(1)
	print 'Column ''use_market_value'' added.'
end
else print 'Column ''use_market_value'' already exists.'