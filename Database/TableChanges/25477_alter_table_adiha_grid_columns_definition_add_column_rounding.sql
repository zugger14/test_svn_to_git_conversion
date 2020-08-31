IF OBJECT_ID(N'adiha_grid_columns_definition', N'U') IS NOT NULL AND COL_LENGTH('adiha_grid_columns_definition', 'rounding') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		rounding : Define roundin for grid columns
	*/
		adiha_grid_columns_definition ADD rounding INT
END
GO



