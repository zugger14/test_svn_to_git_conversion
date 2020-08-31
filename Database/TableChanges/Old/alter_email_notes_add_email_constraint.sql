IF COL_LENGTH('email_notes', 'send_to') IS NOT NULL
BEGIN
    ALTER TABLE email_notes ALTER COLUMN send_to VARCHAR(5000) NULL
END
GO


IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'CHECK'			--CHECK Constraint type
                    AND tc.Table_Name = 'email_notes'           --table name
                    AND	tc.CONSTRAINT_NAME = 'CHK_email_notes_recipients'	--constraint name
                    AND ccu.COLUMN_NAME = 'send_to'          --column name where CHECK constaint is to be created
)
BEGIN	
	ALTER TABLE dbo.email_notes ADD CONSTRAINT CHK_email_notes_recipients CHECK (send_to IS NOT NULL OR send_bcc IS NOT NULL)
	--ALTER TABLE dbo.email_notes SET (LOCK_ESCALATION = TABLE)	
END
GO

