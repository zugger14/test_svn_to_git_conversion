IF COL_LENGTH('netting_group_detail_contract', '[update_user]') IS NULL
BEGIN
    ALTER TABLE netting_group_detail_contract ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('netting_group_detail_contract', 'update_ts') IS NULL
BEGIN
    ALTER TABLE netting_group_detail_contract ADD [update_ts] DATETIME NULL
END