IF COL_LENGTH('excel_sheet','paramset_hash') IS NULL
	ALTER TABLE excel_sheet ADD paramset_hash VARCHAR(1000)