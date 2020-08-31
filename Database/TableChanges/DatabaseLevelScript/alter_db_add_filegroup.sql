
DECLARE @db_name AS VARCHAR(200) = DB_NAME()
/* Add a FileGroup that can be used for FILESTREAM */
IF NOT EXISTS (SELECT
        *
    FROM sys.filegroups
    WHERE name = 'TRMFileTable_FG')
BEGIN
	
    EXEC('ALTER DATABASE ' + @db_name + '
    ADD FILEGROUP TRMFileTable_FG
    CONTAINS FILESTREAM');

END
ELSE
    PRINT 'FILEGROUP TRMFileTable_FG already exists.'


/* Add the folder that needs to be used for the FILESTREAM filegroup. */
--make sure physical path 'D:\FARRMS_SPTFiles\DBFilestream\' exists on windows.
IF NOT EXISTS (SELECT
        1
    FROM sys.database_files
    WHERE name = 'TRMFileTable_File')
BEGIN
    EXEC('ALTER DATABASE ' + @db_name + '
    ADD FILE
    (
    NAME = ''TRMFileTable_File'',
    FILENAME = ''D:\FARRMS_SPTFiles\DBFilestream\FileStreamData''
    )
    TO FILEGROUP TRMFileTable_FG');
END
ELSE
    PRINT 'File TRMFileTable_File already exists on filegroup TRMFileTable_FG'
GO