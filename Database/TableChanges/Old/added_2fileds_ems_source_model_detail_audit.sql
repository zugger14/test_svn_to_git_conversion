

IF COL_LENGTH('ems_source_model_detail_audit', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE ems_source_model_detail_audit ADD [create_ts] DATETIME DEFAULT GETDATE()
END