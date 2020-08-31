IF COL_LENGTH('calcprocess_storage_wacog', 'Volume_adjustment_withdrawal') IS NULL
BEGIN
	ALTER TABLE
	/**
		Columns
		Volume_adjustment_withdrawal : Adjustment Withdrawal Volume
	*/
	dbo.calcprocess_storage_wacog ADD Volume_adjustment_withdrawal FLOAT
END
GO

