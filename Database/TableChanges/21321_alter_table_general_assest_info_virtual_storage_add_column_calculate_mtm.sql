IF COL_LENGTH('general_assest_info_virtual_storage', 'calculate_mtm') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD calculate_mtm VARCHAR(1)
END

GO