IF COL_LENGTH('term_map_detail', 'dynamic_year') IS NULL
BEGIN
	ALTER TABLE 
	/**
		Table : term_map_detail
		Column : dynamic_year
	**/
	term_map_detail ADD dynamic_year CHAR(1) NULL
END
