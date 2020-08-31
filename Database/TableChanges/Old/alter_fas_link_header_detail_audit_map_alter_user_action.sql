
IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'fas_link_header_detail_audit_map' AND COLUMN_NAME = 'user_action')
BEGIN
	ALTER TABLE fas_link_header_detail_audit_map
	ALTER COLUMN user_action VARCHAR(50)
		
	UPDATE fas_link_header_detail_audit_map
		SET user_action = CASE WHEN user_action IS NULL THEN NULL ELSE RTRIM(LTRIM(user_action)) END
END

