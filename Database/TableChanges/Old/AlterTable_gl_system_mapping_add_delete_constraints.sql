IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'gl_account_name_constrant')
BEGIN
	ALTER TABLE TRMTracker_New_Framework.dbo.gl_system_mapping 
	DROP CONSTRAINT gl_account_name_constrant; 
END

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'gl_account_type')
BEGIN
	ALTER TABLE TRMTracker_New_Framework.dbo.gl_system_mapping 
	DROP CONSTRAINT gl_account_type;
END

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'IX_gl_system_mapping')
BEGIN
	ALTER TABLE TRMTracker_New_Framework.dbo.gl_system_mapping 
	DROP CONSTRAINT IX_gl_system_mapping;
END


IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'gl_account_number_name_estimated_actual')
BEGIN
	ALTER TABLE TRMTracker_New_Framework.dbo.gl_system_mapping 
	ADD CONSTRAINT gl_account_number_name_estimated_actual UNIQUE (gl_account_number,gl_account_name,estimated_actual); 
END