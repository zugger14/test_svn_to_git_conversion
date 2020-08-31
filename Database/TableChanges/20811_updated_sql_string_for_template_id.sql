IF EXISTS (SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'template_id' AND field_type = 'd')
BEGIN
	UPDATE maintain_field_deal
	SET sql_string = 'EXEC spa_getDealTemplate @flag=''s'''
	WHERE farrms_field_id = 'template_id'
	AND field_type = 'd'
END