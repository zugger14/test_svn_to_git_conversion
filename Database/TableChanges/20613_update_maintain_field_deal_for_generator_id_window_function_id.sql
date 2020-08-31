IF EXISTS (SELECT 1 FROM maintain_field_deal WHERE field_id = 33 AND farrms_field_id = 'generator_id')
BEGIN
	UPDATE maintain_field_deal
	SET window_function_id = 12101700
	WHERE field_id= 33 AND farrms_field_id = 'generator_id'

	PRINT 'generator_id window_function_id Updated.'
END
ELSE 
	PRINT 'No record for field_id = 33 and farrms_field_id = ''generator_id'''