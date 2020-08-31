
IF COL_LENGTH('source_deal_header_audit', 'reporting_jurisdiction_id') IS NULL 

BEGIN 

    ALTER TABLE source_deal_header_audit ADD reporting_jurisdiction_id INT 

END 
