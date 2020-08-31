IF COL_LENGTH('application_notes', 'notes_share_email_enable') IS NULL
BEGIN
    ALTER TABLE application_notes ADD notes_share_email_enable BIT NOT NULL DEFAULT 0
END
GO