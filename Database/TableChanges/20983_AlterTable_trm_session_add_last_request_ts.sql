IF COL_LENGTH('trm_session', 'last_request_ts') IS NULL
BEGIN
    ALTER TABLE trm_session ADD last_request_ts DATETIME
END
GO