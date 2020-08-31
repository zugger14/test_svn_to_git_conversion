IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id = t.object_id
 where t.name = 'calcprocess_storage_wacog' AND c.name = 'as_of_date')
 BEGIN 
	ALTER TABLE calcprocess_storage_wacog
	Add as_of_date Datetime
 END
 ELSE 
	PRINT 'Column is already present'