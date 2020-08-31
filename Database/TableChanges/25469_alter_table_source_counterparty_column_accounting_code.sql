IF COL_LENGTH('source_counterparty', 'accounting_code') IS NULL
BEGIN
	 /**
	  Add column accounting_code
	*/
	 ALTER TABLE source_counterparty ADD accounting_code VARCHAR(500)
END
GO