IF NOT EXISTS(SELECT 1 FROM sysconstraints WHERE id = OBJECT_ID('formula_editor_parameter') AND COL_NAME(id, colid) = 'blank_option')
BEGIN
	ALTER TABLE formula_editor_parameter ADD blank_option BIT NOT NULL DEFAULT(0)	
END
ELSE 
	PRINT 'Column already exists.'