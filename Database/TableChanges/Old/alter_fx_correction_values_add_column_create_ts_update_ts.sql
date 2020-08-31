IF COL_LENGTH('fx_correction_values', 'create_ts') IS NULL
BEGIN
    ALTER TABLE fx_correction_values ADD create_ts DATETIME NOT NULL DEFAULT(GETDATE())
END
GO


IF COL_LENGTH('fx_correction_values', 'create_user') IS NULL
BEGIN
    ALTER TABLE fx_correction_values ADD create_user VARCHAR(1000) NOT NULL DEFAULT(dbo.FNADBUser())
END
GO


IF COL_LENGTH('fx_correction_values', 'update_ts') IS NULL
BEGIN
    ALTER TABLE fx_correction_values ADD update_ts DATETIME 
END
GO


IF COL_LENGTH('fx_correction_values', 'update_user') IS NULL
BEGIN
    ALTER TABLE fx_correction_values ADD update_user VARCHAR(1000)
END
GO