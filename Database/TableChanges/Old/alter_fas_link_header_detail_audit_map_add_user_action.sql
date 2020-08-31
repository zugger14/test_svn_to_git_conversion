
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'fas_link_header_detail_audit_map' AND COLUMN_NAME = 'user_action')
BEGIN
	ALTER TABLE fas_link_header_detail_audit_map ADD user_action CHAR(50)
	PRINT 'Added user_action field'
END
GO


UPDATE fas_link_header_detail_audit_map
	SET user_action = fas_link_header_audit.user_action 
FROM fas_link_header_audit
WHERE 
	fas_link_header_detail_audit_map.header_audit_id = fas_link_header_audit.audit_id
	
	PRINT 'Updated fas_link_header_detail_audit_map table for header action'
	
GO

UPDATE fas_link_header_detail_audit_map
	SET user_action = fas_link_detail_audit.user_action 
FROM fas_link_detail_audit
WHERE 
	fas_link_header_detail_audit_map.detail_audit_id = fas_link_detail_audit.audit_id	

PRINT 'Updated fas_link_header_detail_audit_map table for detail action'