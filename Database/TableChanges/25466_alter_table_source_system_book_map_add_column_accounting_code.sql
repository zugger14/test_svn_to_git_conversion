IF COL_LENGTH('source_system_book_map', 'accounting_code') IS NULL
BEGIN
	 /**
	  Add column accounting_code
	*/
	 ALTER TABLE source_system_book_map ADD accounting_code VARCHAR(500)
END
GO