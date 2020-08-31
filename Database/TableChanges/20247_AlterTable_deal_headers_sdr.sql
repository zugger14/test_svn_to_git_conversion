IF COL_LENGTH('source_deal_header', 'sdr') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD sdr CHAR(1)
END
GO

IF COL_LENGTH('source_deal_header_template', 'sdr') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD sdr CHAR(1)
END
GO

IF COL_LENGTH('delete_source_deal_header', 'sdr') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD sdr CHAR(1)
END
GO

IF COL_LENGTH('source_deal_header_audit', 'sdr') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD sdr CHAR(1)
END
GO