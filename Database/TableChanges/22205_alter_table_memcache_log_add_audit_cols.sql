IF OBJECT_ID(N'memcache_log', N'U') IS NOT NULL AND COL_LENGTH('memcache_log', 'update_user') IS NULL
BEGIN
    ALTER TABLE memcache_log ADD update_user VARCHAR(100)
END
GO
IF OBJECT_ID(N'memcache_log', N'U') IS NOT NULL AND COL_LENGTH('memcache_log', 'update_ts') IS NULL
BEGIN
    ALTER TABLE memcache_log ADD update_ts DATETIME
END
GO