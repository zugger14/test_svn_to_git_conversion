IF   OBJECT_ID('[adiha_process].[dbo].[memcache_log]') IS NOT NULL AND COL_LENGTH('[adiha_process].[dbo].[memcache_log]', 'source_object') IS NULL
BEGIN
    DROP TABLE [adiha_process].[dbo].[memcache_log]
END
