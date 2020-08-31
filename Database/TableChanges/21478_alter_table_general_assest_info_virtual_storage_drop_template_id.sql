IF COL_LENGTH('general_assest_info_virtual_storage', 'template_id') IS NOT NULL
	AND COL_LENGTH('general_assest_info_virtual_storage', 'injection_template_id') IS NOT NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage 
	DROP column template_id 
END
GO