IF COL_LENGTH('calcprocess_storage_wacog', 'commodity_id') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		commodity_id : Commodity ID referring to source_commodity table
	*/
	calcprocess_storage_wacog	ADD commodity_id INT
END
GO

 