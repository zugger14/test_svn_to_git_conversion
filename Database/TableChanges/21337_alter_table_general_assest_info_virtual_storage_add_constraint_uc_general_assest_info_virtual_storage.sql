IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_general_assest_info_virtual_storage') 
BEGIN
	DELETE FROM virtual_storage_constraint
	DELETE FROM storage_ratchet
	DELETE FROM general_assest_info_virtual_storage

	ALTER TABLE general_assest_info_virtual_storage ADD CONSTRAINT UC_general_assest_info_virtual_storage UNIQUE (storage_location,agreement)
END
ELSE 
	PRINT 'Unique Key UC_general_assest_info_virtual_storage already exists.'
