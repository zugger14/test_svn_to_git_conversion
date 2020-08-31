UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_staticDataValues @flag=''e'', @type_id=10092'
WHERE farrms_field_id='vintage' 
	AND field_type = 'd'