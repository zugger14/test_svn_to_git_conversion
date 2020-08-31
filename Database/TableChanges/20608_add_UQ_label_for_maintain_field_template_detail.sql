IF EXISTS (SELECT * 
     FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
     WHERE CONSTRAINT_NAME = 'UQ_field_label' AND TABLE_NAME = 'maintain_field_template_detail'    
)
BEGIN 
 ALTER TABLE dbo.maintain_field_template_detail 
 DROP CONSTRAINT UQ_field_label;
END

ALTER TABLE dbo.maintain_field_template_detail
ADD CONSTRAINT UQ_field_label UNIQUE (field_template_id, field_group_id, field_caption)