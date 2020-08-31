
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'fas_link_detail' AND COLUMN_NAME = 'fas_link_detail_id')
BEGIN
	ALTER TABLE fas_link_detail ADD fas_link_detail_id INT IDENTITY(1,1)
END
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'fas_link_detail_audit' AND COLUMN_NAME = 'fas_link_detail_id')
BEGIN
	ALTER TABLE fas_link_detail_audit ADD fas_link_detail_id INT 
END
GO

IF EXISTS (SELECT 1 FROM fas_link_detail_audit WHERE fas_link_detail_id IS NULL )
BEGIN
	
	UPDATE fas_link_detail_audit 
	SET fas_link_detail_audit.fas_link_detail_id =  fas_link_detail.fas_link_detail_id
	FROM fas_link_detail WHERE fas_link_detail_audit.source_deal_header_id = fas_link_detail.source_deal_header_id
	AND fas_link_detail_audit.fas_link_detail_id IS NULL	
END


