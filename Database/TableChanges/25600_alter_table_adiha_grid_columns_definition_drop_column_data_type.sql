IF OBJECT_ID(N'adiha_grid_columns_definition', N'U') IS NOT NULL AND COL_LENGTH('adiha_grid_columns_definition', 'data_type') IS NOT NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		data_type : NOT required
	*/
		adiha_grid_columns_definition DROP COLUMN data_type
END
GO



