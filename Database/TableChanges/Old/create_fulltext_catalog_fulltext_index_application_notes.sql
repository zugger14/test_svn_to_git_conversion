-- create the full-text catalog and fulltext index  on application notes
IF NOT EXISTS (SELECT
        1
    FROM sys.fulltext_catalogs
    WHERE [name] = 'application_notes_FT')
BEGIN
    CREATE FULLTEXT CATALOG application_notes_FT AS DEFAULT
    PRINT 'FULLTEXT CATALOG application_notes_FT created.'
END
ELSE
    PRINT 'FULLTEXT CATALOG application_notes_FT exists'


IF NOT OBJECTPROPERTY(OBJECT_ID('application_notes'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON application_notes (FS_Data TYPE COLUMN type_column_name) KEY INDEX PK_application_notes;
END
ELSE
    PRINT 'FULLTEXT INDEX ON application_notes Already Exists.'
GO

--alter fulltext index on application_notes to add columns
DECLARE @value INT;
SELECT @value = COLUMNPROPERTY(OBJECT_ID('dbo.application_notes'), 'notes_subject', 'IsFulltextIndexed')

IF (@value = 0)
begin
	ALTER FULLTEXT INDEX ON application_notes ADD(notes_subject)
end
ELSE
begin
	print 'notes_subject is already fulltext column indexed.'
end
SELECT @value = COLUMNPROPERTY(OBJECT_ID('dbo.application_notes'), 'notes_text', 'IsFulltextIndexed')

IF (@value = 0)
begin
	ALTER FULLTEXT INDEX ON application_notes ADD(notes_text)
end
ELSE
begin
	print 'notes_text is already fulltext column indexed.'
end
SELECT @value = COLUMNPROPERTY(OBJECT_ID('dbo.application_notes'), 'attachment_file_name', 'IsFulltextIndexed')

IF (@value = 0)
begin
	ALTER FULLTEXT INDEX ON application_notes ADD(attachment_file_name)
end
ELSE
begin
	print 'attachment_file_name is already fulltext column indexed.'
end
SELECT @value = COLUMNPROPERTY(OBJECT_ID('dbo.application_notes'), 'create_user', 'IsFulltextIndexed')

IF (@value = 0)
begin
	ALTER FULLTEXT INDEX ON application_notes ADD(create_user)
end
ELSE
begin
	print 'create_user is already fulltext column indexed.'
end

  

