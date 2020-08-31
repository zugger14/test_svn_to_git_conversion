IF COL_LENGTH('source_deal_header_template', 'ignore_bom') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD ignore_bom char
END

IF COL_LENGTH('source_deal_header_template', 'year') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD year INTEGER NULL 
END

IF COL_LENGTH('source_deal_header_template', 'month') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD month INTEGER NULL 
END
