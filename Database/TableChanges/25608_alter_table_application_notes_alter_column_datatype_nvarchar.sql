IF COL_LENGTH('application_notes', 'notes_subject') IS NOT NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        notes_subject : Notes Subject
    */
	application_notes ALTER COLUMN notes_subject NVARCHAR(250)
END

IF COL_LENGTH('application_notes', 'notes_text') IS NOT NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        notes_text : Notes text
    */
	application_notes ALTER COLUMN notes_text NVARCHAR(MAX)
END
IF COL_LENGTH('application_notes', 'attachment_file_name') IS NOT NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        attachment_file_name : Notes Attachment file name
    */
	application_notes ALTER COLUMN attachment_file_name NVARCHAR(MAX)
END

IF COL_LENGTH('application_notes', 'notes_attachment') IS NOT NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        notes_attachment : Notes attachment network path
    */
	application_notes ALTER COLUMN notes_attachment NVARCHAR(MAX)
END