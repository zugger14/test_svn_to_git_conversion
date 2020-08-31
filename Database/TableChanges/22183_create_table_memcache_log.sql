IF OBJECT_ID(N'dbo.memcache_log', N'U') IS NULL 
BEGIN
CREATE TABLE [dbo].[memcache_log]
			(
    			[memcache_log_id]   INT IDENTITY(1, 1),
    			[db_name]			NVARCHAR(500),
				[post_url_address]	NVARCHAR(500),
    			[cache_key_prefix]	NVARCHAR(MAX),
    			[status]			NVARCHAR(MAX),
    			[create_user]		NVARCHAR(50),
    			[create_ts]			DATETIME NULL DEFAULT GETDATE(),
				[source_object]		NVARCHAR(1000)
			)
END
ELSE
BEGIN
    PRINT 'Table memcache_log EXISTS'
END
 
GO

/* Add or update extended property value of SP and its parameters. To add extended property value for SP put 'name' blank */
IF  EXISTS (SELECT 1 FROM sys.objects WHERE name = 'spa_object_documentation' AND TYPE IN (N'P', N'PC'))
BEGIN
	EXECUTE [spa_object_documentation] @json_string  = 
						N'						
						{
							"object_type" : "TABLE", "object_name" : "memcache_log",
							"parameter" : [
												{"name" : "", "desc" : "Memory cached keys releasing log. All passed and failed case are logged with key released status and source object from where it is triggered. Main purpose of this table is to debug memcache issue."},
												{"name" : "memcache_log_id", "desc" : "Identity column."},
												{"name" : "db_name", "desc" : "Name of database where cache clearing action is taken."},
												{"name" : "post_url_address", "desc" : "Address of php file (process_cached_data.php) which is resposible to clear cached key from web server."},
												{"name" : "cache_key_prefix", "desc" : "Prefix of cached key. Database name is also used as prefix to generate key. To clear all keys use database name."},												
												{"name" : "status", "desc" : "Output return from php file."},
												{"name" : "create_user", "desc" : "specifies the username who create the column"},
												{"name" : "create_ts", "desc" : "specifies the date when column was created"},
												{"name" : "source_object", "desc" : "Name of source object from where cache release process is triggered. This can be SP or trigger."}
										  ]
						}'
END

--View table documetation
--EXEC [spa_object_documentation] @flag = 'a', @object_type = 'TABLE', @object_name = 'memcache_log'
