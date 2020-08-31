IF OBJECT_ID(N'fas_link_header_detail_audit_map', N'U') IS NOT NULL 
BEGIN
	 PRINT 'Table fas_link_header_detail_audit_map already exists.'
END
ELSE
BEGIN
	CREATE TABLE fas_link_header_detail_audit_map(
		map_id INT IDENTITY(1,1),
		header_audit_id INT,
		detail_audit_id INT,
		create_user	VARCHAR(50),
		create_ts	DATETIME, 
		update_user	VARCHAR(50),
		update_ts	DATETIME,
		changed_by	CHAR(1)
	)
	PRINT 'Table fas_link_header_detail_audit_map created.'
END


