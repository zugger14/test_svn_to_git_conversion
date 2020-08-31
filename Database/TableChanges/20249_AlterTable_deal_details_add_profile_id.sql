IF COL_LENGTH('source_deal_detail', 'profile_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD profile_id INT REFERENCES forecast_profile(profile_id)
END
GO

IF COL_LENGTH('source_deal_detail_template', 'profile_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD profile_id INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'profile_id') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD profile_id INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'profile_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD profile_id INT
END
GO