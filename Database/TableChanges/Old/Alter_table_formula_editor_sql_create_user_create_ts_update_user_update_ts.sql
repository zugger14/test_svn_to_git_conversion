IF COL_LENGTH('formula_editor_sql', 'create_user') IS NOT NULL
BEGIN
	ALTER TABLE formula_editor_sql ALTER COLUMN create_user VARCHAR(50) NULL	
END

IF COL_LENGTH('formula_editor_sql', 'create_ts') IS NOT NULL
BEGIN
	ALTER TABLE formula_editor_sql ALTER COLUMN create_ts DATETIME NULL	
END


IF COL_LENGTH('formula_editor_sql', 'update_user') IS NOT NULL
BEGIN
	ALTER TABLE formula_editor_sql ALTER COLUMN update_user VARCHAR(50) NULL	
END

IF COL_LENGTH('formula_editor_sql', 'update_ts') IS NOT NULL
BEGIN
	ALTER TABLE formula_editor_sql ALTER COLUMN update_ts DATETIME NULL	
END