IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'shipper_code1' AND header_detail = 'd') 
BEGIN 
	INSERT INTO [dbo].[maintain_field_deal]( 
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
	SELECT N'shipper_code1', N'Shipper Code 1', N'd', N'varchar', NULL, N'd', NULL,
	'SELECT shipper_code_id, shipper_code FROM shipper_code_mapping ORDER BY 1 ASC',  
	NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'n' 
END 

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'shipper_code2' AND header_detail = 'd') 
BEGIN 
	INSERT INTO [dbo].[maintain_field_deal]( 
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
	SELECT N'shipper_code2', N'Shipper Code 2', N'd', N'varchar', NULL, N'd', NULL,
	'SELECT shipper_code_id, shipper_code FROM shipper_code_mapping ORDER BY 1 ASC',  
	NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'n' 

END 

IF COL_LENGTH('source_deal_detail', 'shipper_code1') IS NULL 
BEGIN 
	ALTER TABLE source_deal_detail ADD shipper_code1 INT 
END 

IF COL_LENGTH('source_deal_detail_template', 'shipper_code1') IS NULL 
BEGIN 
	ALTER TABLE source_deal_detail_template ADD shipper_code1 INT 
END 
 
IF COL_LENGTH('source_deal_detail_audit', 'shipper_code1') IS NULL 
BEGIN         
	ALTER TABLE source_deal_detail_audit ADD shipper_code1 INT 
END 

IF COL_LENGTH('delete_source_deal_detail', 'shipper_code1') IS NULL 
BEGIN 
    ALTER TABLE delete_source_deal_detail ADD shipper_code1 INT 
END 

IF COL_LENGTH('source_deal_detail', 'shipper_code2') IS NULL 
BEGIN 
	ALTER TABLE source_deal_detail ADD shipper_code2 INT 
END 

IF COL_LENGTH('source_deal_detail_template', 'shipper_code2') IS NULL 
BEGIN 
	ALTER TABLE source_deal_detail_template ADD shipper_code2 INT 
END 
 
IF COL_LENGTH('source_deal_detail_audit', 'shipper_code2') IS NULL 
BEGIN         
	ALTER TABLE source_deal_detail_audit ADD shipper_code2 INT 
END 

IF COL_LENGTH('delete_source_deal_detail', 'shipper_code2') IS NULL 
BEGIN 
    ALTER TABLE delete_source_deal_detail ADD shipper_code2 INT 
END 

UPDATE maintain_field_deal SET [sql_string] = 'SELECT shipper_code_id, shipper_code FROM shipper_code_mapping ORDER BY 1 ASC' WHERE farrms_field_id IN ('shipper_code1','shipper_code2') AND header_detail = 'd'