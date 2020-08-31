UPDATE maintain_field_deal
SET field_type = 'd' ,
	sql_string = 'EXEC spa_StaticDataValues @flag = ''h'',@type_id = 10013 ,@license_not_to_static_value_id = ''5180,5149,5148,5144'''
WHERE farrms_field_id = 'assignment_type_value_id'
