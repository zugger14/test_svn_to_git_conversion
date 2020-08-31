UPDATE udft
SET udft.field_id = field_name
--SELECT field_id,field_name 
FROM user_defined_fields_template udft
WHERE udft.field_id <> udft.field_name

DECLARE @fk_name VARCHAR(100)
DECLARE @sql VARCHAR(1000)

IF EXISTS(
	SELECT 1
	FROM sys.foreign_keys
	WHERE parent_object_id = OBJECT_ID(N'dbo.user_defined_fields_template') 
		AND referenced_object_id = OBJECT_ID(N'[dbo].[static_data_value]')		 
		AND OBJECT_ID = OBJECT_ID(N'dbo.FK_user_defined_fields_template_field_id')
 )
BEGIN
	SELECT @fk_name = name 
	FROM sys.foreign_keys
	WHERE parent_object_id = OBJECT_ID(N'dbo.user_defined_fields_template') 
		AND referenced_object_id = OBJECT_ID(N'[dbo].[static_data_value]')
		AND OBJECT_ID = OBJECT_ID(N'dbo.FK_user_defined_fields_template_field_id')

	SET @sql = '
	ALTER TABLE user_defined_fields_template DROP CONSTRAINT ' + @fk_name + '
	
	ALTER TABLE user_defined_fields_template 
	WITH NOCHECK ADD CONSTRAINT  ' + @fk_name + ' FOREIGN KEY (field_id) REFERENCES dbo.static_data_value(value_id)'
	--PRINT @sql
	EXEC(@sql)
END       

 /*
--Check for orphaned key data. Delete those data which doesnot exists in parent table. 
		DBCC CHECKCONSTRAINTS ('user_defined_fields_template')

		select *  
		-- DELETE fk
		from user_defined_fields_template fk  
		LEFT JOIN static_data_value pk ON pk.value_id = fk.field_name 
		LEFT JOIN static_data_value pk1 ON pk1.value_id = fk.field_id
		WHERE (fk.field_name is not null AND fk.field_id IS NOT NULL)  AND (pk.value_id is null  OR pk1.value_id is null)
		
		DBCC CHECKCONSTRAINTS ('user_defined_deal_fields_template')

		select *  
		-- DELETE fk
		from user_defined_deal_fields_template fk
		LEFT JOIN user_defined_fields_template pk ON pk.field_name = fk.field_name
		LEFT JOIN user_defined_fields_template pk1 ON pk1.field_name = fk.field_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = fk.field_name 
		WHERE (fk.field_name is not null OR fk.field_id is not null) 
			AND (pk.field_name is null OR pk1.field_name is null OR sdv.value_id is null)  


		select field_id,field_name,* from user_defined_fields_template where field_name in (
		-10000019
		, -5612
		, -5609
		, -5613
		, -5610
		, -5611
		, -10000020
		, 307518
		, 300843
		, -5743
		, -10000021
		)
*/