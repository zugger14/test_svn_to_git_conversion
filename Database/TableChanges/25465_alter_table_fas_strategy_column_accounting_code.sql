IF COL_LENGTH('fas_strategy', 'accounting_code') IS NULL
BEGIN
	 /**
	  Add column accounting_code
	*/
	 ALTER TABLE fas_strategy ADD accounting_code VARCHAR(500)
END
GO