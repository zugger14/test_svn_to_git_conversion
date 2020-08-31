IF EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'upstream_contract')
BEGIN
	UPDATE maintain_field_deal
		SET field_type = 't', data_type = 'varchar', sql_string = NULL
	WHERE farrms_field_id = 'upstream_contract'
END 
GO
