IF COL_LENGTH('source_deal_header_template','timezone_id') IS NULL
	ALTER TABLE source_deal_header_template ADD timezone_id INT 
