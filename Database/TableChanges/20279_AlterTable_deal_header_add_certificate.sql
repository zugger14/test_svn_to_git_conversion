IF COL_LENGTH('source_deal_header', 'certificate') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD [certificate] CHAR(1)
END

IF COL_LENGTH('delete_source_deal_header', 'certificate') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD [certificate] CHAR(1)
END

IF COL_LENGTH('source_deal_header_audit', 'certificate') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD [certificate] CHAR(1)
END

