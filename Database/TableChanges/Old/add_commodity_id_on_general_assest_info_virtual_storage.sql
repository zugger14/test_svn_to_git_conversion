IF COL_LENGTH('general_assest_info_virtual_storage', 'commodity_id') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD commodity_id int
END
