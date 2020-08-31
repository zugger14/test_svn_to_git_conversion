IF COL_LENGTH('calc_invoice_volume','calculated_excel_file') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume ADD calculated_excel_file VARCHAR(1000)
END
