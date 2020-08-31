IF COL_LENGTH('adjustment_default_gl_codes', 'netting_debit_gl_number') IS NULL
BEGIN
    ALTER TABLE adjustment_default_gl_codes ADD netting_debit_gl_number INT
END
GO 

IF COL_LENGTH('adjustment_default_gl_codes', 'netting_credit_gl_number') IS NULL
BEGIN
    ALTER TABLE adjustment_default_gl_codes ADD netting_credit_gl_number INT
END
GO 

IF COL_LENGTH('adjustment_default_gl_codes', 'netting_debit_gl_number_minus') IS NULL
BEGIN
    ALTER TABLE adjustment_default_gl_codes ADD netting_debit_gl_number_minus INT
END
GO 

IF COL_LENGTH('adjustment_default_gl_codes', 'netting_credit_gl_number_minus') IS NULL
BEGIN
    ALTER TABLE adjustment_default_gl_codes ADD netting_credit_gl_number_minus INT
END
GO 