/**
* update window_function_id for farrms_field_id = 'contract_id'
* 2/18/2013
**/

IF EXISTS (SELECT 1 FROM maintain_field_deal WHERE field_id = 47 AND farrms_field_id = 'contract_id')
BEGIN
	PRINT 'update contract_d window_function_id'
	UPDATE maintain_field_deal
	SET window_function_id = 10211010
	WHERE field_id= 47 AND farrms_field_id = 'contract_id'
END
ELSE 
	PRINT 'No record for field_id = 47 and farrms_field_id = ''contract_id'''