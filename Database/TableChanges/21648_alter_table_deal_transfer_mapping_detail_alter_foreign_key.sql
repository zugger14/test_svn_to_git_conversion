DECLARE @fk_name VARCHAR(100)
DECLARE @sql VARCHAR(1000)

IF EXISTS(SELECT 'X' FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID(N'deal_transfer_mapping') AND parent_object_id = OBJECT_ID(N'deal_transfer_mapping_detail'))
BEGIN
	SELECT @fk_name = name 
	FROM sys.foreign_keys
	WHERE referenced_object_id = OBJECT_ID(N'deal_transfer_mapping') AND parent_object_id = OBJECT_ID(N'deal_transfer_mapping_detail')

	SET @sql = '
	ALTER TABLE deal_transfer_mapping_detail DROP CONSTRAINT ' + @fk_name + '
	ALTER TABLE deal_transfer_mapping_detail 
	ADD CONSTRAINT FK_deal_transfer_mapping_detail_deal_transfer_mapping FOREIGN KEY (deal_transfer_mapping_id) REFERENCES dbo.deal_transfer_mapping(deal_transfer_mapping_id) ON DELETE CASCADE'
	EXEC(@sql)
END