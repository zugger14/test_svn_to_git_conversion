-- Include Product / Lot
IF NOT EXISTS (
	SELECT 1 
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_NAME = 'general_assest_info_virtual_storage' 
		AND COLUMN_NAME = 'include_product_lot'
) 
BEGIN
	ALTER TABLE general_assest_info_virtual_storage
	ADD include_product_lot CHAR(1)
END

-- Logical Name
IF NOT EXISTS (
	SELECT 1 
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_NAME = 'general_assest_info_virtual_storage' 
		AND COLUMN_NAME = 'logical_name'
) 
BEGIN
	ALTER TABLE general_assest_info_virtual_storage
	ADD logical_name VARCHAR(100)
END

IF COL_LENGTH('general_assest_info_virtual_storage', 'template_id') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD template_id INT
END
GO