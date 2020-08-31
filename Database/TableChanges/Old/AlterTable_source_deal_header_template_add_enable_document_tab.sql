IF COL_LENGTH('source_deal_header_template', 'enable_document_tab') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD enable_document_tab CHAR(1)
END
GO

UPDATE source_deal_header_template
SET enable_document_tab = 'n'
WHERE enable_document_tab IS NULL