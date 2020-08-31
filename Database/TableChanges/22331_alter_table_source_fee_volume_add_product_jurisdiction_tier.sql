IF OBJECT_ID(N'source_fee_volume', N'U') IS NOT NULL AND COL_LENGTH('source_fee_volume', 'product') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		product : Product id
	*/
		source_fee_volume ADD product INT
END
GO

IF OBJECT_ID(N'source_fee_volume', N'U') IS NOT NULL AND COL_LENGTH('source_fee_volume', 'jurisdiction') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		jurisdiction : jurisdiction id
	*/
		source_fee_volume ADD jurisdiction INT
END
GO

IF OBJECT_ID(N'source_fee_volume', N'U') IS NOT NULL AND COL_LENGTH('source_fee_volume', 'tier') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		tier : tier id
	*/
		source_fee_volume ADD tier INT
END
GO



