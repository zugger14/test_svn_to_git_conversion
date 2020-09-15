IF COL_LENGTH('source_remit_standard', 'quantity_unit_field_40_and_41') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		quantity_unit_field_40_and_41 : Change column length
	*/
	source_remit_standard ALTER COLUMN quantity_unit_field_40_and_41 VARCHAR(30);
END

