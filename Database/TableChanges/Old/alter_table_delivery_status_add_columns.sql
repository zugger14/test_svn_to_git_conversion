IF NOT EXISTS(SELECT 1 FROM information_schema.columns where table_name = 'delivery_status' 
				AND column_name = 'uom_id')
BEGIN
	ALTER TABLE delivery_status ADD uom_id INT	
END

IF NOT EXISTS(SELECT 1 FROM information_schema.columns where table_name = 'delivery_status' 
				AND column_name = 'source_deal_detail_id')
BEGIN
	ALTER TABLE delivery_status ADD source_deal_detail_id INT	
END

IF NOT EXISTS(SELECT 1 FROM information_schema.columns where table_name = 'delivery_status' 
				AND column_name = 'receive_delivery')
BEGIN
	ALTER TABLE delivery_status ADD receive_delivery CHAR(1)	
END


IF NOT EXISTS(SELECT 1 FROM information_schema.columns where table_name = 'delivery_status' 
				AND column_name = 'location_id')
BEGIN
	ALTER TABLE delivery_status ADD location_id INT	
END


IF NOT EXISTS(SELECT 1 FROM information_schema.columns where table_name = 'delivery_status' 
				AND column_name = 'meter_id')
BEGIN
	ALTER TABLE delivery_status ADD meter_id INT	
END


IF NOT EXISTS(SELECT 1 FROM information_schema.columns where table_name = 'delivery_status' 
				AND column_name = 'pipeline_id')
BEGIN
	ALTER TABLE delivery_status ADD pipeline_id INT	
END


IF NOT EXISTS(SELECT 1 FROM information_schema.columns where table_name = 'delivery_status' 
				AND column_name = 'contract_id')
BEGIN
	ALTER TABLE delivery_status ADD contract_id INT	
END
