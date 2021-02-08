UPDATE dbo.working_days 
	SET val = 0
WHERE block_value_id= 292061
AND [weekday] IN (1,7)

UPDATE dbo.working_days 
	SET val = 1
WHERE block_value_id= 292061
AND [weekday] BETWEEN 2 AND 6
