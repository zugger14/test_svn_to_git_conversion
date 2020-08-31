DECLARE @source_deal_id VARCHAR(MAX)
SET @source_deal_id = (SELECT CAST((sdh.source_deal_header_id) AS VARCHAR(5)) + ',' FROM master_deal_view mdv 
							RIGHT JOIN source_deal_header sdh 
							ON sdh.source_deal_header_id = mdv.source_deal_header_id
							WHERE mdv.source_deal_header_id IS NULL
							FOR XML PATH(''))

SET @source_deal_id = LEFT(@source_deal_id,LEN(@source_deal_id) - 1)

EXEC spa_master_deal_view @flag = 'i', @source_deal_header_id = @source_deal_id, @deal_process_table = NULL
