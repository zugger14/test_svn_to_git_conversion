
UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_source_price_curve_def_maintain @flag = ''l'', @is_active=''y'''
WHERE farrms_field_id = 'curve_id'
