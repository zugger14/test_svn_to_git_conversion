IF COL_LENGTH('contract_report_template', 'document_type') IS NULL
BEGIN
    ALTER TABLE contract_report_template ADD document_type CHAR(1) NULL
END
ELSE
BEGIN
    PRINT 'document_type Already Exists.'
END 
GO

IF COL_LENGTH('contract_report_template', 'xml_map_filename') IS NULL
BEGIN
    ALTER TABLE contract_report_template ADD xml_map_filename VARCHAR(200) NULL
END
ELSE
BEGIN
    PRINT 'xml_map_filename Already Exists.'
END 
GO