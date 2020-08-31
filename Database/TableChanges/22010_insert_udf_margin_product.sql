BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @value_id INT
	
	SELECT @value_id = value_id 
	FROM static_data_value 
	WHERE code = 'Margin Product'
		AND [type_id] = 5500
	
	IF @value_id < 0
	BEGIN
		SELECT 'UDF "Margin Product" already exists.' [Alert Message] 
		ROLLBACK
		RETURN
	END

	DELETE uddf 
	FROM user_defined_deal_fields_template_main  uddftm
	INNER JOIN user_defined_fields_template udft ON uddftm.field_id=udft.field_id
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = uddftm.template_id
	INNER JOIN source_deal_header sdh ON sdh.template_id = sdht.template_id
	INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id
	WHERE uddftm.field_id = @value_id

	DELETE uddftm 
	FROM user_defined_deal_fields_template_main  uddftm
	INNER JOIN user_defined_fields_template udft ON uddftm.field_id=udft.field_id
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = uddftm.template_id
	INNER JOIN source_deal_header sdh ON sdh.template_id = sdht.template_id
	WHERE uddftm.field_id = @value_id

	DELETE FROM maintain_field_template_detail 
	WHERE field_caption = 'Margin Product'
		AND udf_or_system = 'u'

	DELETE 
	FROM user_defined_fields_template 
	WHERE field_id = @value_id

	DELETE FROM static_data_value 
	WHERE value_id = @value_id

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000229)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (5500, -10000229, 'Margin Product', 'Margin Product', NULL, 'farrms_admin', GETDATE())
		PRINT 'Inserted static data value -10000229 - Margin Product.'
	END
	ELSE
	BEGIN
		PRINT 'Static data value -10000229 - Margin Product already EXISTS.'
	END
	SET IDENTITY_INSERT static_data_value OFF        
	
	IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000229)
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
		VALUES (-10000229, 'Margin Product', 'd', 'NVARCHAR(250)', 'n', 'SELECT value_id, code FROM static_data_value WHERE type_id = 108100', 'h', 180, -10000229)
	END
	
	COMMIT
	SELECT 'UDF "Margin Product" created successfully.' [Success Message] 
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 1
		ROLLBACK

	SELECT 'Error occurred: Error: ' + ERROR_MESSAGE() [Error Message]
END CATCH
GO