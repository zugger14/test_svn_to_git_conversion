IF COL_LENGTH('term_map_detail', 'sequence') IS NULL
BEGIN
    ALTER TABLE term_map_detail
	/**
	Columns 
	formula_name : column that stores the formula name
	*/
	ADD sequence INT
END
GO