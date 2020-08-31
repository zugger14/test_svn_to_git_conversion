IF EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id
WHERE t.name = 'maintain_udf_static_data_detail_values' AND c.name = 'static_data_module_object_id')
BEGIN 
PRINT 'Change name'
EXEC sp_rename 'maintain_udf_static_data_detail_values.static_data_module_object_id','primary_field_object_id','COLUMN'
END
ELSE 
PRINT 'Change not necessary'

IF EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id
WHERE t.name = 'maintain_udf_static_data_detail_values' AND c.name = 'maintain_udf_detail_id')
BEGIN 
PRINT 'Change name'
EXEC sp_rename 'maintain_udf_static_data_detail_values.maintain_udf_detail_id','application_field_id','COLUMN'
END
ELSE 
PRINT 'Change not necessary'

