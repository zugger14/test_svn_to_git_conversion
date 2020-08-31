if exists(select * from static_data_value where value_id = 45 and type_id=25)
begin
	update static_data_value set code = 'Schedule Match', description = 'Schedule Match' where value_id = 45 and type_id=25
	print 'Updated code/description as ''Schedule Match'' for value_id 45 of type_id 25.'
end
else print 'Record for value_id 45 of type_id 25 does not exists.'

if exists(select * from static_data_value where value_id = 43 and type_id=25)
begin
	update static_data_value set code = 'Ticket', description = 'Ticket' where value_id = 43 and type_id=25
	print 'Updated code/description as ''Ticket'' for value_id 43 of type_id 25.'
end
else print 'Record for value_id 43 of type_id 25 does not exists.'