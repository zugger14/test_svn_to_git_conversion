IF  COL_LENGTH('user_defined_fields_template', 'split_positive_and_negative_commodity') IS NULL
BEGIN
	ALTER TABLE
	/**
		Columns
		split_positive_and_negative_commodity : Split Positive and Negative Commodity 
	*/
		user_defined_fields_template ADD split_positive_and_negative_commodity NVARCHAR(2) NULL
END
GO