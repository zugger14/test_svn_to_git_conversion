
DECLARE @db VARCHAR(100)
SELECT @db = db_name()

SELECT 'Before Setting Database:'+@db [Status],  is_read_committed_snapshot_on, snapshot_isolation_state_desc,snapshot_isolation_state FROM sys.databases WHERE name=@db

EXEC('

	ALTER DATABASE '+ @db +' SET allow_snapshot_isolation ON
	ALTER DATABASE '+ @db +' SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	ALTER DATABASE '+ @db +' SET read_committed_snapshot ON
	ALTER DATABASE '+ @db +' SET MULTI_USER
')

SELECT 'After Setting Database:'+@db [Status], is_read_committed_snapshot_on, snapshot_isolation_state_desc,snapshot_isolation_state FROM sys.databases WHERE name=@db