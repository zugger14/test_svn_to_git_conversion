IF COL_LENGTH('source_commodity', 'accounting_code') IS NULL
BEGIN
	 /**
	  Add column accounting_code
	*/
	 ALTER TABLE source_commodity ADD accounting_code VARCHAR(500)
END
GO