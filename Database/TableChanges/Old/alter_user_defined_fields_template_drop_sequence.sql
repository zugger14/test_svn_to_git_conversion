IF EXISTS(SELECT 'x' FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'user_defined_fields_template'
AND c.COLUMN_NAME = 'sequence')
ALTER TABLE user_defined_fields_template DROP COLUMN sequence