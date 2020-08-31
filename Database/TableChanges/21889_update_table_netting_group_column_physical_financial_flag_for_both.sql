-- update value for column physical_financial_flag from 'b' to 'a'
if col_length('netting_group', 'physical_financial_flag') is not null
begin
	update netting_group set physical_financial_flag = 'a' where physical_financial_flag = 'b'
	print 'Column value for ''physical_financial_flag'' updated to ''b'' for all value ''a'''
end
else print 'Column ''physical_financial_flag'' does not exist.'