SET IDENTITY_INSERT maintain_field_deal ON

DECLARE @field_id INT 

IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE header_detail = 'h' AND farrms_field_id = 'fixed_fx_rate') 
BEGIN
	SELECT @field_id = MAX(field_id) + 1 FROM maintain_field_deal 

	INSERT INTO [dbo].[maintain_field_deal](
		[field_id], 
		[farrms_field_id], 
		[default_label], 
		[field_type], 
		[data_type], 
		[default_validation], 
		[header_detail], 
		[system_required], 
		[sql_string], 
		[field_size], 
		[is_disable], 
		[window_function_id], 
		[is_hidden], 
		[default_value], 
		[insert_required], 
		[data_flag], 
		[update_required]
	)
	SELECT @field_id, N'fixed_fx_rate', N'Fx Rate', N't', N'int', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'n' 
END
ELSE 
BEGIN 
	UPDATE [maintain_field_deal] 
	SET [field_type]	= 't'
		, [data_type]	= 'int'
	WHERE  header_detail = 'h' AND farrms_field_id = 'fixed_fx_rate'
END

SET IDENTITY_INSERT maintain_field_deal OFF
GO


