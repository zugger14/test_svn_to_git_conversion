IF COL_LENGTH('source_deal_header_template','deal_rules') IS NULL 
ALTER TABLE source_deal_header_template ADD deal_rules INT 