IF COL_LENGTH('source_deal_header', 'governing_law') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD governing_law INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'governing_law') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD governing_law INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'governing_law') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD governing_law INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'governing_law') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD governing_law INT
END
GO