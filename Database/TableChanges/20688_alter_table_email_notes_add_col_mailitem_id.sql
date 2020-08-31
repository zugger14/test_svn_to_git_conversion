--add column 'mailitem_id' on email_notes to bind with database mail and fetch failed mails
IF COL_LENGTH('email_notes', 'mailitem_id') IS NULL
BEGIN
	ALTER TABLE email_notes
	ADD mailitem_id INT NULL
	PRINT 'Column ''mailitem_id'' added.'
END
ELSE PRINT 'Column ''mailitem_id'' already exists.'
GO