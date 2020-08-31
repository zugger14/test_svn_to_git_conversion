IF COL_LENGTH('fas_subsidiaries', 'accounting_code') IS NULL
BEGIN
	 /**
	  Add column accounting_code
	*/
	 ALTER TABLE fas_subsidiaries ADD accounting_code VARCHAR(500)
END
GO