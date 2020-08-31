UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_source_minor_location @flag =''o'', @is_active = ''y'', @location_name_group = ''1'''
WHERE farrms_field_id = 'location_id'

