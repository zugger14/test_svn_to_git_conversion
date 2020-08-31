--removing existing data with duplicate (tier_type,state_value_id)
WITH dups (duplicate)
AS (
    SELECT ROW_NUMBER() OVER (PARTITION BY source_deal_header_id,state_value_id ORDER BY Gis_Certificate.state_value_id) AS duplicate
    FROM Gis_Certificate)

DELETE FROM dups WHERE duplicate>1;

IF OBJECT_ID('UC_Gis_Certificate', 'UQ') IS NOT NULL 
BEGIN   
 	ALTER TABLE gis_certificate 
	DROP CONSTRAINT UC_Gis_Certificate 
	
	ALTER TABLE gis_certificate 
	ADD CONSTRAINT UC_Gis_Certificate 
	UNIQUE (source_deal_header_id,state_value_id)	
	PRINT ('Unique key constraint updated')
END
ELSE
BEGIN 
	ALTER TABLE gis_certificate 
	ADD CONSTRAINT UC_Gis_Certificate 
	UNIQUE (source_deal_header_id,state_value_id)	
	PRINT ('Unique key constraint added')
END
    
    
    
    
     
    
