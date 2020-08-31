UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_staticDataValues @flag = ''h'', @type_id = 25000'
WHERE farrms_field_id = 'status'