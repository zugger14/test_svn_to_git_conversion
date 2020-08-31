--available,header_used,total_match_vol,create_user,create_ts

IF COL_LENGTH('gen_fas_link_detail_dicing', 'available') IS NULL
BEGIN
    ALTER TABLE gen_fas_link_detail_dicing ADD available INT
END
GO

IF COL_LENGTH('gen_fas_link_detail_dicing', 'header_used') IS NULL
BEGIN
    ALTER TABLE gen_fas_link_detail_dicing ADD header_used VARCHAR(500)
END
GO


IF COL_LENGTH('gen_fas_link_detail_dicing', 'total_match_vol') IS NULL
BEGIN
    ALTER TABLE gen_fas_link_detail_dicing ADD total_match_vol INT
END
GO


IF COL_LENGTH('gen_fas_link_detail_dicing', 'create_user') IS NULL
BEGIN
    ALTER TABLE gen_fas_link_detail_dicing ADD create_user varchar(50)
END
GO


IF COL_LENGTH('gen_fas_link_detail_dicing', 'create_ts') IS NULL
BEGIN
    ALTER TABLE gen_fas_link_detail_dicing ADD create_ts DATETIME
END
GO

