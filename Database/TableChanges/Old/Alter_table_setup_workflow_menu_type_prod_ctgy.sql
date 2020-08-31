IF COL_LENGTH(N'setup_workflow', 'product_category') IS NULL
BEGIN
	ALTER TABLE setup_workflow 
		ADD product_category INT 
		
END

IF COL_LENGTH(N'setup_workflow', 'menu_type') IS NULL
BEGIN
	ALTER TABLE setup_workflow 
		ADD menu_type BIT 
		
END