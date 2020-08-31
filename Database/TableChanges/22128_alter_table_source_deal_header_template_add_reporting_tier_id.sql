IF COL_LENGTH('source_deal_header_template', 'reporting_tier_id') IS NULL 

BEGIN 

    ALTER TABLE source_deal_header_template ADD reporting_tier_id INT 

END 