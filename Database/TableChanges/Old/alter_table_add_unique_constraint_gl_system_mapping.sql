IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'gl_account_type')
BEGIN
 ALTER TABLE TRMTracker_New_Framework.dbo.gl_system_mapping 
 ADD CONSTRAINT gl_account_type UNIQUE (gl_account_number,estimated_actual); 
END