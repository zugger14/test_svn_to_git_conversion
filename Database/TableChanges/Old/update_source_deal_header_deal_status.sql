-- SNWA specific change.DO NOT MERGE.

UPDATE source_deal_header set deal_status=5601 where deal_status=5602 
UPDATE source_deal_header set deal_status=5601 where deal_status=5600

UPDATE source_deal_header_template set deal_status=5601 where deal_status=5602 
UPDATE source_deal_header_template set deal_status=5601 where deal_status=5600