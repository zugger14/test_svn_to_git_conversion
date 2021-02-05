IF COL_LENGTH('pivot_report_view_columns', 'thou_sep') IS NOT NULL
BEGIN
	ALTER TABLE 
	/**
		Table : pivot_report_view_columns
		Column : thou_sep
	**/
	pivot_report_view_columns ALTER COLUMN [thou_sep] VARCHAR(2) NULL
END