IF COL_LENGTH('internal_deal_type_subtype_types', 'create_user') IS NULL
BEGIN
    ALTER TABLE internal_deal_type_subtype_types ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('internal_deal_type_subtype_types', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE internal_deal_type_subtype_types ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('internal_deal_type_subtype_types', '[update_user]') IS NULL
BEGIN
    ALTER TABLE internal_deal_type_subtype_types ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('internal_deal_type_subtype_types', 'update_ts') IS NULL
BEGIN
    ALTER TABLE internal_deal_type_subtype_types ADD [update_ts] DATETIME NULL
END