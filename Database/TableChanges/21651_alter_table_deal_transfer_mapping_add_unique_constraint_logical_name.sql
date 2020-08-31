IF OBJECT_ID('tempdb..#temp_check_duplicate') IS NOT NULL
	DROP TABLE #temp_check_duplicate

SELECT MAX(rmh.deal_transfer_mapping_id) AS deal_transfer_mapping_id,
       logical_name,
       COUNT(*) AS num_of_entity
INTO   #temp_check_duplicate
FROM   deal_transfer_mapping AS rmh
GROUP BY
       rmh.logical_name

-- Deleting the duplicate key
DELETE 
FROM   deal_transfer_mapping
WHERE  deal_transfer_mapping_id IN (
	SELECT deal_transfer_mapping_id
	FROM   #temp_check_duplicate
	WHERE  num_of_entity > 1
)

-- Add Unique constraints.
IF NOT EXISTS(
       SELECT 'X'
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS
       WHERE  CONSTRAINT_NAME = 'UC_deal_transfer_mapping'
   )
BEGIN
    ALTER TABLE deal_transfer_mapping
    ADD CONSTRAINT UC_deal_transfer_mapping UNIQUE(logical_name)
END