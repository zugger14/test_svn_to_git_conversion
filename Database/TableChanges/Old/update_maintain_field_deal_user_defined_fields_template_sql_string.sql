--price_uom_id -- price 
UPDATE maintain_field_deal SET sql_string = 'exec spa_getsourceuom @flag=''s'', @uom_type = 44301'
WHERE field_id = 128

--position_uom -- quantity 
UPDATE maintain_field_deal SET sql_string = 'exec spa_getsourceuom @flag=''s'', @uom_type = 44303'
WHERE field_id = 163

--deal_volume_uom_id -- quantity
UPDATE maintain_field_deal SET sql_string = 'exec spa_getsourceuom @flag=''s'', @uom_type = 44303'
WHERE field_id = 94

--contractual_uom_id -- quantity
UPDATE maintain_field_deal SET sql_string = 'exec spa_getsourceuom @flag=''s'', @uom_type = 44303'
WHERE field_id = 136

------udf field---------------------------------------------------------------------------------------------
UPDATE user_defined_fields_template
	SET sql_string = 'exec spa_getsourceuom @flag=''s'', @uom_type = 44302' --Package
WHERE udf_template_id = 2567 AND field_name = -5733



