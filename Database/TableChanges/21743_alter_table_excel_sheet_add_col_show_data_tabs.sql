IF COL_LENGTH('excel_sheet', 'show_data_tabs') IS NULL
BEGIN
  ALTER TABLE excel_sheet ADD show_data_tabs BIT 
END




