IF COL_LENGTH('source_minor_location', 'accounting_code') IS NULL
BEGIN
	 /**
	  Add column accounting_code
	*/
	 ALTER TABLE source_minor_location ADD accounting_code VARCHAR(500)
END
GO