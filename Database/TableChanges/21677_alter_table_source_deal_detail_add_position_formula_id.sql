/*************************************************************************
Step 1: Add columns with same name on source_deal_detail, source_deal_detail_template, source_deal_detail_audit, delete_source_deal_detail
*/

IF COL_LENGTH('source_deal_detail', 'position_formula_id') IS NULL
BEGIN
	ALTER TABLE source_deal_detail
	ADD position_formula_id INT NULL
END
/*
	SELECT position_formula_id, * FROM source_deal_detail
*/

IF COL_LENGTH('source_deal_detail_template', 'position_formula_id') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template
	ADD position_formula_id INT NULL
END
/*
	SELECT position_formula_id, * FROM source_deal_detail_template
*/

IF COL_LENGTH('source_deal_detail_audit', 'position_formula_id') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_audit
	ADD position_formula_id INT NULL
END
/*
	SELECT position_formula_id, * FROM source_deal_detail_audit
*/

IF COL_LENGTH('delete_source_deal_detail', 'position_formula_id') IS NULL
BEGIN
	ALTER TABLE delete_source_deal_detail
	ADD position_formula_id INT NULL
END
/*
	SELECT position_formula_id, * FROM delete_source_deal_detail
*/

/********************************************************************************************
Step 2: Insert data in maintain_field_deal with inserted column name on farrms_field_id
*/

DECLARE @field_id INT
SELECT @field_id = MAX(field_id) + 1 FROM maintain_field_deal

IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'position_formula_id')
BEGIN
	INSERT INTO [dbo].[maintain_field_deal] ( 
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
	SELECT @field_id, -- field_id
		N'position_formula_id', -- farrms_field_id
		N'Position Formula', -- default_label
		N'w', -- field_type
		N'int', -- data_type
		NULL, -- default validation
		N'd', -- header detail
		NULL, -- system_required
		N'SELECT fe.formula_id,dbo.FNAFormulaFormat(fe.formula,''r'') AS [Formula] FROM formula_nested fn INNER JOIN formula_editor fe ON fn.formula_id = fe.formula_id WHERE fe.istemplate =''y''', -- sql_string
		NULL, -- field_size
		NULL, -- is_disable
		NULL, -- window_function_id
		N'n', -- is_hidden
		NULL, -- default_value
		N'n', -- insert_required
		N'i', -- data_flag
		N'n' -- update_required
END

/*
	SELECT * FROM maintain_field_deal WHERE farrms_field_id = 'position_formula_id'
*/

GO