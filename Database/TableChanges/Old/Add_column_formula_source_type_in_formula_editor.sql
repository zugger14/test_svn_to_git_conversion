IF COL_LENGTH('formula_editor', 'formula_source_type') IS NULL
BEGIN
	ALTER TABLE formula_editor ADD formula_source_type CHAR(1) NULL
END
