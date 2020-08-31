UPDATE source_price_curve_def
SET block_type = NULL
WHERE block_type= 12001
GO
	
UPDATE source_deal_header
SET block_type = NULL
WHERE block_type= 12001
GO

UPDATE source_deal_header_audit
SET block_type = NULL
WHERE block_type= 12001
GO

UPDATE delete_source_deal_header
SET block_type = NULL
WHERE block_type= 12001
GO

UPDATE source_deal_header_template
SET block_type = NULL
WHERE block_type= 12001
GO

UPDATE contract_group
SET block_type = NULL
WHERE block_type= 12001
GO

--UPDATE hour_block_term
--SET block_type = NULL
--WHERE block_type= 12001
--GO

--UPDATE pratos_source_price_curve_map
--SET block_type = NULL
--WHERE block_type= 12001
--GO

UPDATE pratos_stage_deal_header
SET block_type = NULL
WHERE block_type= 12001
GO

UPDATE profile_hour_block
SET block_type = NULL
WHERE block_type= 12001
GO