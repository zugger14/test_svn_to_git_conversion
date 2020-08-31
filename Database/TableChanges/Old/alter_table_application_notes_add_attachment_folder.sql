IF COL_LENGTH('application_notes', 'attachment_folder') IS NULL
BEGIN
    ALTER TABLE application_notes ADD attachment_folder VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'attachment_folder Already Exists.'
END 
GO