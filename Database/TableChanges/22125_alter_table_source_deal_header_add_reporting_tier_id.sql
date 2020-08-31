IF COL_LENGTH('source_deal_header', 'reporting_tier_id') IS NULL 

BEGIN 
    ALTER TABLE source_deal_header ADD reporting_tier_id INT 

END 