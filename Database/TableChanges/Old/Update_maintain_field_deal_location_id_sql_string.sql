--SELECT  * FROM maintain_field_deal WHERE field_id = 109 AND farrms_field_id = 'location_id'

IF EXISTS (SELECT 1 FROM maintain_field_deal WHERE field_id = 109 AND farrms_field_id = 'location_id')
BEGIN
	UPDATE maintain_field_deal
	SET    sql_string = 'EXEC spa_source_minor_location ''w'''
	WHERE  field_id = 109
	       AND farrms_field_id = 'location_id'
END