IF COL_LENGTH('payment_details', 'formula_name') IS NULL
BEGIN
    ALTER TABLE payment_details
	/**
	Columns 
	formula_name : column that stores the formula name
	*/
	ADD formula_name NVARCHAR(250)
END
GO