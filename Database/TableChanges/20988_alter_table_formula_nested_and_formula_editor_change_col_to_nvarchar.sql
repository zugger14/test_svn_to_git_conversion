IF COL_LENGTH('formula_nested', 'description1') IS NOT NULL
BEGIN
    ALTER TABLE formula_nested ALTER COLUMN description1 NVARCHAR(200);
	PRINT 'changed to nvarchar'
END

IF COL_LENGTH('formula_editor', 'formula_name') IS NOT NULL
BEGIN
    ALTER TABLE formula_editor ALTER COLUMN formula_name NVARCHAR(200);
	PRINT 'changed to nvarchar'
END

GO