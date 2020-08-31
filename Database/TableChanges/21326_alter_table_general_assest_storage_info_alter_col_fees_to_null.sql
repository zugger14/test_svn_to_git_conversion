IF COL_LENGTH('general_assest_info_virtual_storage', 'fees') IS NOT NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage
	ALTER COLUMN fees INT NULL
END