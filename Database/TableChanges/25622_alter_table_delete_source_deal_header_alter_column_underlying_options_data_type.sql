UPDATE delete_source_deal_header
SET underlying_options = NULL
WHERE ISNUMERIC(underlying_options) = 0

IF COL_LENGTH('delete_source_deal_header', 'underlying_options') IS NOT NULL
BEGIN
	ALTER TABLE delete_source_deal_header
	/**
	Columns 
	underlying_options : Wrong data type was used
	*/
	ALTER COLUMN underlying_options INT
END
