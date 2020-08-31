IF COL_LENGTH('general_assest_info_virtual_storage', 'include_non_standard_deals') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage ADD include_non_standard_deals CHAR(1)
END
ELSE
	PRINT('Column include_non_standard_deals already exists.')