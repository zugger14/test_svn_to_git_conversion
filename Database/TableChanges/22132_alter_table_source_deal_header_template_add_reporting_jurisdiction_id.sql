IF COL_LENGTH('source_deal_header_template', 'reporting_jurisdiction_id') IS NULL 

BEGIN 

    ALTER TABLE source_deal_header_template ADD reporting_jurisdiction_id INT 

END 