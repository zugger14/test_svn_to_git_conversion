
--sp_helpfilegroup 
--sp_helpfilegroup @filegroupname='PRIMARY'
--ALTER DATABASE [TRMTracker_RELEASE] REMOVE FILE [primary]
-- ALTER DATABASE [TRMTracker_RELEASE] REMOVE FILEGROUP [reusa_Data]

DECLARE @dbname VARCHAR(200) = DB_NAME()

DECLARE @i INT = 1, @sql VARCHAR(500), @filegroup_name VARCHAR(100)
WHILE(@i <= 150)
BEGIN
	SET @filegroup_name  = 'FG_Farrms_' + RIGHT('000' + CAST(@i AS VARCHAR(5)), 3)

	SET @sql =  'IF EXISTS(SELECT 1 FROM sys.filegroups WHERE name = ''' + @filegroup_name + ''')
	BEGIN
		ALTER DATABASE [' + @dbname + '] REMOVE FILEGROUP [' + @filegroup_name + ']
		--PRINT ''' + @filegroup_name + ' removed.''
	END 
	ELSE 
		PRINT ''' + @filegroup_name + ' does not exist.''
	'
	EXEC(@sql)
	SET @i += 1
END
