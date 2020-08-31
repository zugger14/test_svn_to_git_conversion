IF OBJECT_ID('UC_Gis_Certificate', 'UQ') IS NOT NULL 
BEGIN   
 	ALTER TABLE gis_certificate 
	DROP CONSTRAINT UC_Gis_Certificate 
	
	ALTER TABLE gis_certificate 
	ADD CONSTRAINT UC_Gis_Certificate 
	UNIQUE (source_deal_header_id_from, source_deal_header_id, state_value_id, tier_type)	
	PRINT ('Unique key constraint updated')
END
ELSE
BEGIN 
	ALTER TABLE gis_certificate 
	ADD CONSTRAINT UC_Gis_Certificate 
	UNIQUE (source_deal_header_id_from, source_deal_header_id, state_value_id, tier_type)	
	PRINT ('Unique key constraint updated')
END