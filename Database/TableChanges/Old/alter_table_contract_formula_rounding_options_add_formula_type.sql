IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE  object_id = OBJECT_ID(N'[dbo].[contract_formula_rounding_options]') AND name = 'formula_type')
BEGIN
	ALTER TABLE contract_formula_rounding_options add formula_type varchar(20) collate SQL_Latin1_General_CP1_CI_AS
END
ELSE
	PRINT 'Column already exists.'
