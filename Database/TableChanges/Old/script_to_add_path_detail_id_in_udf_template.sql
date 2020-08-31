DECLARE @field_template_id	INT, 
		@field_group_id		INT, 
		@udf_template_id	VARCHAR(20)


SELECT @field_template_id = mft.field_template_id
FROM maintain_field_template mft
WHERE mft.template_name = 'Transportation' 


SELECT @field_group_id = mftg.field_group_id
  FROM maintain_field_template_group mftg WHERE mftg.field_template_id = @field_template_id
AND mftg.group_name = 'Additional'

--Internal UDF field Path Detail ID -5606
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template udft WHERE field_name = -5606)
BEGIN
	INSERT INTO [dbo].[user_defined_fields_template]( [field_name], [Field_label], [Field_type], [data_type], [is_required], [sql_string], [create_user], [create_ts], [update_user], [update_ts], [udf_type], [sequence], [field_size], [field_id], [default_value], [book_id], [udf_group], [udf_tabgroup], [formula_id], [internal_field_type], [currency_field_id], [window_id], [leg])
	SELECT  -5606, N'Path Detail ID', N't', N'int', N'n', N'', NULL, NULL, NULL, NULL, N'h', NULL, 30, -5606, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
END


SELECT @udf_template_id = udf_template_id FROM user_defined_fields_template udft WHERE udft.field_name = -5606

IF EXISTS(SELECT 1 FROM maintain_field_template_detail mftd 
					WHERE mftd.field_template_id = @field_template_id
						AND mftd.udf_or_system = 'u' AND mftd.field_id = @udf_template_id)
BEGIN
	PRINT 'UDF ''Path Detail ID'' already exist.'
	RETURN
END

SET @udf_template_id = 'UDF___' + @udf_template_id

EXEC spa_maintain_field_properties 'i', NULL, @field_template_id, @field_group_id, @udf_template_id, NULL 
			, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'h'
			, NULL, NULL, NULL, NULL