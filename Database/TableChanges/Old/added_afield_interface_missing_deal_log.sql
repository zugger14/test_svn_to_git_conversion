

IF COL_LENGTH('interface_missing_deal_log', '[create_user]') IS NULL
BEGIN
    ALTER TABLE interface_missing_deal_log ADD create_user DATETIME DEFAULT GETDATE()
END

