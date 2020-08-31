IF (SELECT is_nullable FROM sys.columns c  INNER JOIN sys.tables t ON 
c.object_id = t.object_id where t.name = 'application_ui_template_fields'
AND c.name = 'application_ui_field_id') = 0 
BEGIN 
	ALTER table application_ui_template_fields
	Alter Column application_ui_field_id INT NULL
END 
ELSE 
	PRINT 'Its already a null'

IF NOT EXISTS(SELECT 1 FROM sys.columns c  INNER JOIN sys.tables t ON 
c.object_id = t.object_id where t.name = 'application_ui_template_fields'
AND c.name = 'udf_template_id')
	BEGIN
		ALTER table application_ui_template_fields
		ADD  udf_template_id INT NULL
	END
ELSE 
	BEGIN 
		PRINT 'Column Already exist'
	END



IF EXISTS(SELECT 1 FROM sys.columns c  INNER JOIN sys.tables t ON 
c.object_id = t.object_id where t.name = 'maintain_udf_detail_values'
AND c.name = 'maintain_udf_detail_id')
BEGIN 
	BEGIN TRY
		AlTER TABLE maintain_udf_detail_values
		DROP Constraint FK__maintain___maint__1C041C1D
	END TRY
	BEGIN CATCH
		PRINT 'Try changing constraint name according to your database'
	END CATCH
	
	EXEC sp_rename 'dbo.maintain_udf_detail_values.maintain_udf_detail_id', 'application_field_id', 'COLUMN'
	
END
ELSE 
 PRINT 'NAME already changed'