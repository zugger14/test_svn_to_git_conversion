IF COL_LENGTH('pivot_report_view', 'excel_sheet_id') IS NULL
BEGIN
    ALTER TABLE pivot_report_view ADD excel_sheet_id INT NULL
    PRINT ('excel_sheet_id column added in table pivot_report_view.')
END
ELSE
BEGIN
	PRINT('excel_sheet_id column already exists in table pivot_report_view.')
END