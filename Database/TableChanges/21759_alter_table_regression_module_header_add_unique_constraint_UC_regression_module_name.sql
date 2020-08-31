-- Checking the duplicate key
SELECT MAX(rmh.regression_module_header_id) AS regression_module_header_id,
       rmh.module_name,
       COUNT(*) AS num_of_entity
INTO   #temp_check_duplicate
FROM   regression_module_header AS rmh
GROUP BY
       rmh.module_name


-- Deleting the duplicate key
DELETE 
FROM   regression_module_header
WHERE  regression_module_header_id IN (SELECT regression_module_header_id
                                       FROM   #temp_check_duplicate
                                       WHERE  num_of_entity > 1)
       

-- Deleting the temp table 
DROP TABLE #temp_check_duplicate
 
-- Add Unique constraints.
IF NOT EXISTS(
       SELECT 'X'
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS
       WHERE  CONSTRAINT_NAME = 'UC_regression_module_name'
   )
BEGIN
    ALTER TABLE regression_module_header
    ADD CONSTRAINT UC_regression_module_name UNIQUE(module_name)
END