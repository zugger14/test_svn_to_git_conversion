IF COL_LENGTH('delete_source_deal_header', 'reporting_tier_id') IS NULL 

BEGIN 

    ALTER TABLE delete_source_deal_header ADD reporting_tier_id INT 

END 