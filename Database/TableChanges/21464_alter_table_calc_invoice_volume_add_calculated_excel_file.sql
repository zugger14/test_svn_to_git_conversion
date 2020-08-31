IF COL_LENGTH('calc_invoice_volume','calculated_excel_file') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume ADD calculated_excel_file VARCHAR(1000)
END

-- Not needed because excel calc file will generate based on invoice for all line items
IF COL_LENGTH('calc_invoice_volume','calculated_excel_file') IS NOT NULL
BEGIN
	ALTER TABLE calc_invoice_volume DROP COLUMN calculated_excel_file	
END

IF COL_LENGTH('calc_invoice_volume_variance','calculated_excel_file') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD calculated_excel_file VARCHAR(1000)
END