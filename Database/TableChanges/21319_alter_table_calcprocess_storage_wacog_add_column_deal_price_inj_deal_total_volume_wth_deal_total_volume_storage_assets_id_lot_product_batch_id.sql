IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id = t.object_id
 where t.name = 'calcprocess_storage_wacog' AND c.name = 'deal_price')
 BEGIN 
	ALTER TABLE calcprocess_storage_wacog
	Add deal_price float
 END
 ELSE 
	PRINT 'Column is already present : deal_price'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id = t.object_id
 where t.name = 'calcprocess_storage_wacog' AND c.name = 'inj_deal_total_volume')
 BEGIN 
	ALTER TABLE calcprocess_storage_wacog
	Add inj_deal_total_volume numeric
 END
 ELSE 
	PRINT 'Column is already present : inj_deal_total_volume'


IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id = t.object_id
 where t.name = 'calcprocess_storage_wacog' AND c.name = 'wth_deal_total_volume')
 BEGIN 
	ALTER TABLE calcprocess_storage_wacog
	Add wth_deal_total_volume numeric
 END
 ELSE 
	PRINT 'Column is already present : wth_deal_total_volume'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id = t.object_id
 where t.name = 'calcprocess_storage_wacog' AND c.name = 'storage_assets_id')
 BEGIN 
	ALTER TABLE calcprocess_storage_wacog
	Add storage_assets_id INT
 END
 ELSE 
	PRINT 'Column is already present : storage_assets_id'


IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id = t.object_id
 where t.name = 'calcprocess_storage_wacog' AND c.name = 'lot')
 BEGIN 
	ALTER TABLE calcprocess_storage_wacog
	Add lot varchar(100)
 END
 ELSE 
	PRINT 'Column is already present : lot'


IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id = t.object_id
 where t.name = 'calcprocess_storage_wacog' AND c.name = 'product')
 BEGIN 
	ALTER TABLE calcprocess_storage_wacog
	Add product varchar(100)
 END
 ELSE 
	PRINT 'Column is already present : product'


IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on c.object_id = t.object_id
 where t.name = 'calcprocess_storage_wacog' AND c.name = 'batch_id')
 BEGIN 
	ALTER TABLE calcprocess_storage_wacog
	Add batch_id varchar(500)
 END
 ELSE 
	PRINT 'Column is already present : batch_id'


