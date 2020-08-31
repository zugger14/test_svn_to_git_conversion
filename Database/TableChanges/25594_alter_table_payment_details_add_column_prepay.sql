IF COL_LENGTH('payment_details', 'prepay') IS NULL
BEGIN
    ALTER TABLE payment_details
	/**
	Columns 
	prepay : column that stores the prepay value
	*/
	ADD prepay CHAR(1)
END
GO

