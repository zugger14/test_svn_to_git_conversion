IF COL_LENGTH('source_fee_volume', 'aggressor_initiator') IS  NULL
BEGIN
	ALTER TABLE 
	/**
	Columns 
	aggressor_initiator: aggressor_initiator
	*/
	source_fee_volume ADD aggressor_initiator NCHAR(1)
END


