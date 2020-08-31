-- Modify foreign key constraint to delete data from child table before deleting parent data

-- Drop existing constraint
DECLARE @foreign_key_name VARCHAR(100)

SELECT @foreign_key_name = f.name
FROM sys.foreign_keys AS f,
     sys.foreign_key_columns AS fc,
     sys.tables t 
WHERE f.OBJECT_ID = fc.constraint_object_id
AND t.OBJECT_ID = fc.referenced_object_id
AND OBJECT_NAME(t.object_id) = 'application_users'
AND COL_NAME(t.object_id,fc.referenced_column_id) = 'application_users_id'
AND OBJECT_NAME(f.parent_object_id) = 'license_agreement'
AND COL_NAME(fc.parent_object_id,fc.parent_column_id) = 'application_users_id'

EXEC ('ALTER TABLE license_agreement DROP CONSTRAINT ' + @foreign_key_name)

-- Add new constraint
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_license_agreement_application_users')
BEGIN
	ALTER TABLE license_agreement 
	ADD CONSTRAINT FK_license_agreement_application_users 
	FOREIGN KEY (application_users_id) 
	REFERENCES application_users(application_users_id) 
	ON DELETE CASCADE;
END
