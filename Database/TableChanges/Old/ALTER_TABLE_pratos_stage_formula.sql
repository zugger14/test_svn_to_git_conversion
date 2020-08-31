
IF COL_LENGTH('pratos_stage_formula', 'value') IS  NOT NULL
	ALTER TABLE pratos_stage_formula ALTER COLUMN value NUMERIC(38,20)
GO
