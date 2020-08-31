-- Checking the duplicate key

SELECT MAX(fm.forecast_model_id)     AS forecast_model_id,
       fm.forecast_model_name,
       COUNT(*)              AS num_of_entity
INTO   #temp_check_duplicate
FROM   forecast_model  AS fm
GROUP BY
       fm.forecast_model_name


-- Deleting the duplicate key
     
DELETE 
FROM   forecast_model
WHERE  forecast_model_id IN (SELECT forecast_model_id
                   FROM   #temp_check_duplicate
                   WHERE  num_of_entity > 1)
       

-- Deleting the temp table 
      
 DROP TABLE #temp_check_duplicate
 
 
-- Add Unique constraints.

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_forecast_model_name')
BEGIN
	ALTER TABLE forecast_model
	ADD CONSTRAINT UC_forecast_model_name UNIQUE (forecast_model_name)
END

