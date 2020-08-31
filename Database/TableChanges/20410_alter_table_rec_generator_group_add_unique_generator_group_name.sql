-- Checking the duplicate key
IF OBJECT_ID('tempdb..#temp_check_duplicate') IS NOT NULL
DROP TABLE #temp_check_duplicate
go

SELECT MAX(rg.generator_group_id) AS generator_group_id,
       rg.generator_group_name,
       COUNT(*) AS num_generator_group_id
INTO   #temp_check_duplicate
FROM   rec_generator_group  AS rg
GROUP BY
       rg.generator_group_name
       
-- Deleting the duplicate key
     
DELETE 
FROM   rec_generator_group
WHERE  generator_group_id IN (SELECT generator_group_id
                   FROM   #temp_check_duplicate
                   WHERE  num_generator_group_id > 1)

       

-- Deleting the temp table 
      
 DROP TABLE #temp_check_duplicate
 
 
-- Add Unique constraints.

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_rec_generator_group_generator_group_name')
BEGIN
	ALTER TABLE rec_generator_group
	ADD CONSTRAINT UC_rec_generator_group_generator_group_name UNIQUE (generator_group_name)
END






