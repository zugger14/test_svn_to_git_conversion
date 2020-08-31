IF COL_LENGTH('adjustment_default_gl_codes_detail', 'debit_gl_number_minus') IS NULL
BEGIN
    ALTER TABLE adjustment_default_gl_codes_detail ADD debit_gl_number_minus INT
END
ELSE PRINT 'debit_gl_number_minus - Field already exists'
GO

IF COL_LENGTH('adjustment_default_gl_codes_detail', 'credit_gl_number_minus') IS NULL
BEGIN
    ALTER TABLE adjustment_default_gl_codes_detail ADD credit_gl_number_minus INT
END
ELSE PRINT 'credit_gl_number_minus - Field already exists'
GO