IF EXISTS(SELECT 'x' FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'maintain_field_template_detail'
AND c.COLUMN_NAME = 'udf_of_system')
 exec sp_rename 'maintain_field_template_detail.udf_of_system','udf_or_system','COLUMN'; 