UPDATE a
SET a.window_id = 10106100
FROM user_defined_fields_template a WHERE Field_label IN('Online Indicator','Must Run Indicator','Fuel Type')

UPDATE a
SET a.window_id = 10161800
FROM user_defined_fields_template a WHERE Field_label = 'Outage/Derate'