SET IDENTITY_INSERT maintain_field_deal ON

DECLARE @field_id INT 

IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE header_detail = 'h' AND farrms_field_id = 'reporting_group1') 
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
	SELECT @field_id, N'reporting_group1', N'Reporting Group1', N'd', N'int', NULL, N'h', NULL, N'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113000', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'n' 
END
ELSE 
BEGIN 
	UPDATE [maintain_field_deal] 
	SET [field_type]	= 'd'
		, [data_type]	= 'int'
		, [sql_string] 	= 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113000'
	WHERE  header_detail = 'h' AND farrms_field_id = 'reporting_group1'
END
 
IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE header_detail = 'h' AND farrms_field_id = 'reporting_group2') 
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
	SELECT @field_id, N'reporting_group2', N'Reporting Group2', N'd', N'int', NULL, N'h', NULL, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113100', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'n' 
END
ELSE 
BEGIN 
	UPDATE [maintain_field_deal] 
	SET [field_type]	= 'd'
		, [data_type]	= 'int'
		, [sql_string] 	= 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113100'
	WHERE  header_detail = 'h' AND farrms_field_id = 'reporting_group2'
END

IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE header_detail = 'h' AND farrms_field_id = 'reporting_group3') 
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
	SELECT @field_id, N'reporting_group3', N'Reporting Group3', N'd', N'int', NULL, N'h', NULL, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113200', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'n' 
END
ELSE 
BEGIN 
	UPDATE [maintain_field_deal] 
	SET [field_type]	= 'd'
		, [data_type]	= 'int'
		, [sql_string] 	= 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113200'
	WHERE  header_detail = 'h' AND farrms_field_id = 'reporting_group3'
END

IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE header_detail = 'h' AND farrms_field_id = 'reporting_group4') 
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
	SELECT @field_id, N'reporting_group4', N'Reporting Group4', N'd', N'int', NULL, N'h', NULL, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113300', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'n' 
END
ELSE 
BEGIN 
	UPDATE [maintain_field_deal] 
	SET [field_type]	= 'd'
		, [data_type]	= 'int'
		, [sql_string] 	= 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113300'
	WHERE  header_detail = 'h' AND farrms_field_id = 'reporting_group4'
END
SET IDENTITY_INSERT maintain_field_deal ON
IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE header_detail = 'h' AND farrms_field_id = 'reporting_group5') 
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
	SELECT @field_id, N'reporting_group5', N'Reporting Group5', N'd', N'int', NULL, N'h', NULL, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113400', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'n' 
END
ELSE 
BEGIN 
	UPDATE [maintain_field_deal] 
	SET [field_type]	= 'd'
		, [data_type]	= 'int'
		, [sql_string] 	= 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 113400'
	WHERE  header_detail = 'h' AND farrms_field_id = 'reporting_group5'
END

SET IDENTITY_INSERT maintain_field_deal OFF
GO

