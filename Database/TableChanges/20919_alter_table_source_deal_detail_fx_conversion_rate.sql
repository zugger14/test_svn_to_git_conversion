IF COL_LENGTH('source_deal_detail', 'fx_conversion_rate') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD fx_conversion_rate FLOAT
END
ELSE
BEGIN
	ALTER TABLE source_deal_detail
	ALTER COLUMN fx_conversion_rate FLOAT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'fx_conversion_rate') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_template
	ADD fx_conversion_rate FLOAT
END
ELSE
BEGIN
	ALTER TABLE source_deal_detail_template
	ALTER COLUMN fx_conversion_rate FLOAT
END

IF COL_LENGTH('source_deal_detail_audit', 'fx_conversion_rate') IS NULL
BEGIN
	ALTER TABLE source_deal_detail_audit
	ADD fx_conversion_rate FLOAT
END
ELSE
BEGIN
	ALTER TABLE source_deal_detail_audit
	ALTER COLUMN fx_conversion_rate FLOAT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'fx_conversion_rate') IS NULL
BEGIN
	ALTER TABLE delete_source_deal_detail
	ADD fx_conversion_rate FLOAT
END
ELSE
BEGIN
	ALTER TABLE delete_source_deal_detail
	ALTER COLUMN fx_conversion_rate FLOAT
END
GO

