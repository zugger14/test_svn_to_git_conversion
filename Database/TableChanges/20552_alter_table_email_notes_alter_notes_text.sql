-- Dropped the full search index to alter the column size and then again created the full search index

IF EXISTS (SELECT * FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[email_notes]'))
    DROP FULLTEXT INDEX ON [dbo].[email_notes]
GO

IF COL_LENGTH('email_notes', 'notes_text') IS NOT NULL 
	ALTER TABLE email_notes ALTER COLUMN notes_text VARCHAR(MAX)
GO

IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[email_notes]'))
	CREATE FULLTEXT INDEX ON [dbo].[email_notes](
	FS_Data TYPE COLUMN type_column_name LANGUAGE [English], 
	notes_object_name LANGUAGE [English], 
	notes_subject LANGUAGE [English], 
	notes_text LANGUAGE [English], 
	attachment_file_name LANGUAGE [English], 
	notes_description LANGUAGE [English], 
	send_from LANGUAGE [English], 
	send_to LANGUAGE [English], 
	send_cc LANGUAGE [English], 
	send_bcc LANGUAGE [English],
	create_user LANGUAGE [English]
	)
	KEY INDEX [PK_email_notes] ON ([TRMTrackerFTI], FILEGROUP [PRIMARY])
	--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO