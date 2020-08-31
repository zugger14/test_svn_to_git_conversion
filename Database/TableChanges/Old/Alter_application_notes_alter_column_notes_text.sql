IF COL_LENGTH('application_notes', 'notes_text') IS NOT NULL
BEGIN
    ALTER TABLE application_notes ALTER COLUMN notes_text VARCHAR(MAX)
END
GO
