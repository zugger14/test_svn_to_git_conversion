IF COL_LENGTH('general_assest_info_virtual_storage', 'schedule_injection_id') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD schedule_injection_id INT NULL
    PRINT 'Column schedule_injection_id added.'
END
ELSE
BEGIN
	PRINT 'Column schedule_injection_id already exists.'
END
GO

IF COL_LENGTH('general_assest_info_virtual_storage', 'schedule_withdrawl_id') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD schedule_withdrawl_id INT NULL
    PRINT 'Column schedule_withdrawl_id added.'
END
ELSE
BEGIN
	PRINT 'Column schedule_withdrawl_id already exists.'
END
GO 

IF COL_LENGTH('general_assest_info_virtual_storage', 'nomination_injection_id') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD nomination_injection_id INT NULL
    PRINT 'Column nomination_injection_id added.'
END
ELSE
BEGIN
	PRINT 'Column nomination_injection_id already exists.'
END
GO 

IF COL_LENGTH('general_assest_info_virtual_storage', 'nomination_withdrawl_id') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD nomination_withdrawl_id INT NULL
    PRINT 'Column nomination_withdrawl_id added.'
END
ELSE
BEGIN
	PRINT 'Column nomination_withdrawl_id already exists.'
END
GO 

IF COL_LENGTH('general_assest_info_virtual_storage', 'actual_injection_id') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD actual_injection_id INT NULL
    PRINT 'Column actual_injection_id added.'
END
ELSE
BEGIN
	PRINT 'Column actual_injection_id already exists.'
END
GO 

IF COL_LENGTH('general_assest_info_virtual_storage', 'actual_withdrawl_id') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD actual_withdrawl_id INT NULL
    PRINT 'Column actual_withdrawl_id added.'
END
ELSE
BEGIN
	PRINT 'Column actual_withdrawl_id already exists.'
END
GO

