UPDATE sdd
SET sdd.source_deal_group_id = sdg.source_deal_groups_id
FROM source_deal_Detail sdd
INNER JOIN source_deal_groups sdg ON sdg.source_Deal_header_id = sdd.source_Deal_header_id
WHERE sdd.source_deal_group_id IS NULL

IF EXISTS (SELECT 1 FROM sys.[columns] WHERE NAME = N'source_deal_group_id' AND [object_id] = OBJECT_ID(N'source_deal_detail'))
BEGIN
	ALTER TABLE source_deal_detail ALTER COLUMN source_deal_group_id INT NOT NULL  
END

