IF COL_LENGTH('email_notes', 'internal_type_value_id') IS NOT NULL 
	ALTER TABLE email_notes ALTER COLUMN internal_type_value_id INT NULL
	
IF COL_LENGTH('email_notes', 'notes_object_id') IS NOT NULL 
	ALTER TABLE email_notes ALTER COLUMN notes_object_id VARCHAR(50) NULL

IF COL_LENGTH('email_notes', 'notes_object_name') IS NOT NULL 
	ALTER TABLE email_notes ALTER COLUMN notes_object_name VARCHAR(50) NULL

IF COL_LENGTH('email_notes', 'send_from') IS NOT NULL 
	ALTER TABLE email_notes ALTER COLUMN send_from VARCHAR(100) NULL
