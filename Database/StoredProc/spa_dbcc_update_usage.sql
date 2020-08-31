/* 
Author : Santosh Gupta 
Date: 26th Jan 2012
Purpose: To Update the Database integrity

*/
IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_dbcc_update_usage]')AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_dbcc_update_usage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_dbcc_update_usage]
@dbname varchar(100)
AS

BEGIN

declare @servername varchar(50), --variable to hold the servername
  --  @dbname varchar(100), --variable to hold the database name
    @command varchar(1000) --variable to hold the sql command

-- set variables
select @servername= CONVERT(VARCHAR(200), SERVERPROPERTY('ServerName'))

-- declare the cursor
declare dbccuu cursor for
select name from master.dbo.sysdatabases
    where  (status & 32 <> 32 and status & 128 <> 128 and status & 512 <> 512 and status & 1024 <> 1024 and status & 4096 <> 4096 and status & 2048 <> 2048)  and (name not in ('Northwind', 'Pubs'))

-- open the cursor
open dbccuu

-- fetch the first record into the cursor
fetch dbccuu into @dbname

-- while the fetch was successful
while @@fetch_status=0
begin
    -- EXEC spa_print the header for each database
    EXEC spa_print ''
    EXEC spa_print '***************************'
    EXEC spa_print 'DBCC UPDATEUSAGE Report For ', @DBNAME
    EXEC spa_print '***************************'
    EXEC spa_print ''

    -- set the command to execute
    set @command='dbcc updateusage('+@dbname+')'

    -- execute the command
    exec(@command)

    -- fetch the next record into the cursor
    fetch dbccuu into @dbname
end

-- close the cursor
close dbccuu

-- deallocate the cursor
deallocate dbccuu

-- tell user when the script was last run
select 'This script was executed on ' + cast(getdate() as varchar(50))

END
