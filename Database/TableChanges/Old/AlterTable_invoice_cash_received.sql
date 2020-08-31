/*
	Alter Table invoice_cash_received to add column type which identifies whether amount is received or paid
	Possible Values are r- receive and p- pay
*/
ALTER TABLE invoice_cash_received 
	Add  invoice_type CHAR(1)