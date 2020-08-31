/***************
Alter Table adjustment_default_gl_codes
**************/
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'adjustment_default_gl_codes' and column_name = 'debit_gl_number_minus')
	ALTER TABLE adjustment_default_gl_codes add debit_gl_number_minus INT

GO

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'adjustment_default_gl_codes' and column_name = 'credit_gl_number_minus')
	ALTER TABLE adjustment_default_gl_codes add credit_gl_number_minus INT

