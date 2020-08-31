-- Checking the duplicate key
IF OBJECT_ID('tempdb..#temp_check_duplicate') IS NOT NULL
DROP TABLE #temp_check_duplicate
go

SELECT MAX(rg.generator_id) AS generator_id,
       rg.id,
       COUNT(*) AS num_generator_id
INTO   #temp_check_duplicate
FROM   rec_generator  AS rg
GROUP BY
       rg.id
       
-- Deleting the duplicate key
     
DELETE 
FROM   rec_generator
WHERE  generator_id IN (SELECT generator_id
                   FROM   #temp_check_duplicate
                   WHERE  num_generator_id > 1)

       

-- Deleting the temp table 
      
 DROP TABLE #temp_check_duplicate
 
 
-- Add Unique constraints.

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_rec_generator_id')
BEGIN
	ALTER TABLE rec_generator
	ADD CONSTRAINT UC_rec_generator_id UNIQUE (id)
END


--*****************************************************************
IF OBJECT_ID('tempdb..#temp_check_duplicate') IS NOT NULL
DROP TABLE #temp_check_duplicate
go
-- Checking the duplicate key
SELECT MAX(rg.generator_id) AS generator_id,
       rg.code,
       COUNT(*) AS num_generator_id
INTO   #temp_check_duplicate
FROM   rec_generator  AS rg
GROUP BY
       rg.code
       
-- Deleting the duplicate key
     
DELETE 
FROM   rec_generator
WHERE  generator_id IN (SELECT generator_id
                   FROM   #temp_check_duplicate
                   WHERE  num_generator_id > 1)

       

-- Deleting the temp table 
      
 DROP TABLE #temp_check_duplicate
 
 
-- Add Unique constraints.

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_rec_generator_code')
BEGIN
	ALTER TABLE rec_generator
	ADD CONSTRAINT UC_rec_generator_code UNIQUE (code)
END



