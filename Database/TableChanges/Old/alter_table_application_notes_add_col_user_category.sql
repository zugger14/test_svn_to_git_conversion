/**
ALTER TABLE TO ADD URL TEXT FIELD
**/
IF COL_LENGTH(N'application_notes', 'user_category') IS NULL
BEGIN
	ALTER TABLE application_notes 
	ADD user_category INT NULL CONSTRAINT application_notes_user_category_static_data_value FOREIGN KEY (user_category) REFERENCES static_data_value(value_id) ON DELETE SET NULL
END
ELSE
	PRINT 'Column : user_category, already exists.'


