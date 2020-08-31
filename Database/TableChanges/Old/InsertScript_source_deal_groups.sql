-- get deal groups value

IF OBJECT_ID('tempdb..#temp_deal_groups_update') IS NOT NULL
	DROP TABLE #temp_deal_groups_update
	
CREATE TABLE #temp_deal_groups_update (
	source_deal_groups_id INT,
	source_deal_header_id INT,
	leg	INT
)

INSERT INTO source_deal_groups ( 
	source_deal_header_id,
	term_from,
	term_to,
	location_id,
	curve_id,
	detail_flag,
	leg
)
OUTPUT INSERTED.source_deal_groups_id, INSERTED.source_deal_header_id, INSERTED.leg INTO #temp_deal_groups_update(source_deal_groups_id, source_deal_header_id, leg)	
SELECT sdd.source_deal_header_id, MIN(sdd.term_start), MAX(sdd.term_end), NULL, NULL, 0, sdd.Leg
FROM source_deal_detail sdd
LEFT JOIN source_deal_groups sdg ON sdd.source_deal_header_id = sdg.source_deal_header_id
WHERE sdg.source_deal_groups_id IS NULL 
GROUP by sdd.source_deal_header_id, sdd.Leg
ORDER by sdd.source_deal_header_id

UPDATE sdd
SET source_deal_group_id = temp.source_deal_groups_id
FROM source_deal_detail sdd
INNER JOIN #temp_deal_groups_update temp ON temp.source_deal_header_id = sdd.source_deal_header_id AND sdd.Leg = temp.leg
