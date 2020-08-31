IF COL_LENGTH(N'general_assest_info_virtual_storage', 'accounting_type') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage 
		ADD accounting_type INT

	PRINT 'Added columns accounting_type.'
END

IF COL_LENGTH(N'general_assest_info_virtual_storage', 'ownership_type') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage 
		ADD ownership_type INT

	PRINT 'Added columns ownership_type.'
END

IF COL_LENGTH(N'general_assest_info_virtual_storage', 'injection_as_long') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage 
		ADD injection_as_long CHAR -- y, n

	PRINT 'Added columns injection_as_long.'
END

IF COL_LENGTH(N'general_assest_info_virtual_storage', 'include_fees') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage 
		ADD include_fees CHAR -- y, n

	PRINT 'Added columns include_fees.'
END

IF COL_LENGTH(N'general_assest_info_virtual_storage', 'storage_capacity') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage 
		ADD storage_capacity INT

	PRINT 'Added columns storage_capacity.'
END

IF COL_LENGTH(N'general_assest_info_virtual_storage', 'negative_inventory') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage 
		ADD negative_inventory INT

	PRINT 'Added columns negative_inventory.'
END



IF COL_LENGTH(N'general_assest_info_virtual_storage', 'injection_deal') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage 
		ADD injection_deal INT

	PRINT 'Added columns injection_deal.'
END
IF COL_LENGTH(N'general_assest_info_virtual_storage', 'withdrawal_deal') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage 
		ADD withdrawal_deal INT

	PRINT 'Added columns withdrawal_deal.'
END
IF COL_LENGTH(N'general_assest_info_virtual_storage', 'actualize_projection') IS NULL
BEGIN
	ALTER TABLE general_assest_info_virtual_storage 
		ADD actualize_projection CHAR

	PRINT 'Added columns actualize_projection.'
END