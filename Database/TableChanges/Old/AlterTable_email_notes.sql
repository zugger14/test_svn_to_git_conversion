IF COL_LENGTH('email_notes', 'process_id') IS NULL
BEGIN
    ALTER TABLE email_notes ADD process_id VARCHAR(200)
END
GO

IF COL_LENGTH('email_notes', 'notes_description') IS NULL
BEGIN
    ALTER TABLE email_notes ADD notes_description VARCHAR(MAX)
END
GO