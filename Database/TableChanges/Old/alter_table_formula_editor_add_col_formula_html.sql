IF COL_LENGTH('formula_editor', 'formula_html') IS NULL
BEGIN
    ALTER TABLE formula_editor ADD formula_html VARCHAR(MAX)
END
GO