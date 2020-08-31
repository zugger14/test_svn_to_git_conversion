IF COL_LENGTH('delivery_path', 'path_name') IS NOT NULL
BEGIN
    ALTER TABLE
	/**
		Columns 
		path_name: Path Name
	*/
	 delivery_path ALTER COLUMN path_name NVARCHAR(100)
END
GO

IF COL_LENGTH('delivery_path', 'path_code') IS NOT NULL
BEGIN
    ALTER TABLE
	/**
		Columns 
		path_name: Path Name
	*/
	 delivery_path ALTER COLUMN path_code NVARCHAR(100)
END
GO

