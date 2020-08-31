IF COL_LENGTH('excel_sheet_snapshot','process_id') IS NULL
	ALTER TABLE excel_sheet_snapshot ADD process_id VARCHAR(1000)