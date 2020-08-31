IF OBJECT_ID(N'adiha_grid_columns_definition', N'U') IS NOT NULL AND COL_LENGTH('adiha_grid_columns_definition', 'data_type') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		data_type : Added to define grid column type
	*/
		adiha_grid_columns_definition ADD data_type NVARCHAR(100)
END
GO



