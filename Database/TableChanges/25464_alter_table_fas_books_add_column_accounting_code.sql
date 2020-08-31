IF COL_LENGTH('fas_books', 'accounting_code') IS NULL
BEGIN
	 /**
	  Add column accounting_code
	*/
	 ALTER TABLE fas_books ADD accounting_code VARCHAR(500)
END
GO