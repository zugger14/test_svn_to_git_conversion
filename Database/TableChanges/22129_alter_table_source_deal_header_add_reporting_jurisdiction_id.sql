IF COL_LENGTH('source_deal_header', 'reporting_jurisdiction_id') IS NULL 

BEGIN 
    ALTER TABLE source_deal_header ADD reporting_jurisdiction_id INT 

END 