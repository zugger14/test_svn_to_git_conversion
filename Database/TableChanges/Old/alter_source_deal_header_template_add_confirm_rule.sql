IF COL_LENGTH('source_deal_header_template','confirm_rule') IS null
ALTER TABLE source_deal_header_template ADD confirm_rule INT 

