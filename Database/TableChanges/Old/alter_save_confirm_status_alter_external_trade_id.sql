IF NOT EXISTS(  SELECT 1 FROM   sys.columns WHERE  [name] = 'external_trade_id'AND [object_id] = OBJECT_ID('save_confirm_status') )
BEGIN
	ALTER TABLE save_confirm_status ALTER COLUMN external_trade_id VARCHAR(50)	
END
   
   
   
    
    
