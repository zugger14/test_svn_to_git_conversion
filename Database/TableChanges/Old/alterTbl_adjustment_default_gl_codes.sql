/*** Add a column ********/
ALTER TABLE dbo.adjustment_default_gl_codes ADD
	estimated_actual char(1) NULL
GO
COMMIT
