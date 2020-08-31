IF COL_LENGTH('fas_link_header_detail_audit_map', 'create_user') IS NULL
BEGIN
    ALTER TABLE fas_link_header_detail_audit_map ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('fas_link_header_detail_audit_map', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE fas_link_header_detail_audit_map ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('fas_link_header_detail_audit_map', '[update_user]') IS NULL
BEGIN
    ALTER TABLE fas_link_header_detail_audit_map ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('fas_link_header_detail_audit_map', 'update_ts') IS NULL
BEGIN
    ALTER TABLE fas_link_header_detail_audit_map ADD [update_ts] DATETIME NULL
END