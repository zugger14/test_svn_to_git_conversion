IF COL_LENGTH('general_assest_info_virtual_storage', 'effective_date') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD effective_date DATETIME DEFAULT GETDATE()
END
