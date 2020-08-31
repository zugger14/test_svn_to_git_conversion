IF COL_LENGTH('trm_session', 'is_active') IS NULL
BEGIN
    ALTER TABLE trm_session ADD is_active INT DEFAULT (1)
END
GO