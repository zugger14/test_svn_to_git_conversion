IF COL_LENGTH('delete_source_deal_header', 'reporting_jurisdiction_id') IS NULL 

BEGIN 

    ALTER TABLE delete_source_deal_header ADD reporting_jurisdiction_id INT 

END 