/* 
Author : Santosh Gupta 
Date: 16th  Feb 2012
Purpose: To Create File Group for Partitioning on any database 
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DECLARE @dbname				VARCHAR(100) = 'TRMtracker_Essent' --TODO Change
DECLARE @partition_nature	VARCHAR(5)   = 'DATE'	---- Nature of Parition Nature default value = "NUM" or "DATE" --TODO Change
DECLARE @no_partitions		INT			 = 25						--TODO Change
DECLARE @file_location		VARCHAR(MAX) = 'D:\'		--TODO Change
DECLARE @init_size			VARCHAR(20)  = '1MB'				--TODO Change
DECLARE @max_size			VARCHAR(20)  = '1GB'				--TODO Change
DECLARE @growth				VARCHAR(20)  = '100MB'				--TODO Change
BEGIN
SET NOCOUNT, XACT_ABORT ON;
DECLARE @error		INT
DECLARE @rowcount	BIGINT
DECLARE @errorline	INT
DECLARE @message	VARCHAR(255)
DECLARE @st			VARCHAR(MAX) 
DECLARE @i			INT
SET @i = 1
	WHILE @i < @no_partitions + 1 
	BEGIN 
		--' +  CAST(@i as INT)  +'		
			--SET @st='ALTER DATABASE '+ @dbname + ' REMOVE FILE  FG_' + @partition_nature  + '_00' + CAST(@i as VARCHAR(10)) +''
		
			--RAISERROR(@st, 0, 1) WITH NOWAIT;
			--exec(@st)
			
			--SET @st='ALTER DATABASE '+ @dbname + ' REMOVE FILEGROUP [FG_' + @partition_nature  + '_00' + CAST(@i as VARCHAR(2)) +']'
			--RAISERROR(@st, 0, 1) WITH NOWAIT;
			--exec(@st)
			
			SET @st = 'ALTER DATABASE ' + @dbname + ' ADD FILEGROUP [FG_' + @partition_nature  + '_' + RIGHT('000' + CAST(@i AS VARCHAR), 3) + ']'
			RAISERROR(@st, 0, 1) WITH NOWAIT;
			EXEC (@st)
			
			SET @st='ALTER DATABASE ' + @dbname + ' ADD FILE  (NAME = N''FG_' + @partition_nature  + '_' + RIGHT('000' + CAST(@i AS VARCHAR), 3) + ''',FILENAME = N''' +@file_location +  '\FG_' + @partition_nature + '_' + RIGHT('000' + CAST(@i AS VARCHAR), 3) + 
			'.ndf'', SIZE = ' + @init_size + ', MAXSIZE = ' + @max_size + ', FILEGROWTH = ' + @growth + 
			') TO FILEGROUP [FG_' + @partition_nature + '_' + RIGHT('000' + CAST(@i AS VARCHAR), 3) + ']'
			RAISERROR(@st, 0, 1) WITH NOWAIT;
			EXEC (@st)
			RAISERROR(@message, 0, 1) WITH NOWAIT;
			SET @i = @i + 1
   END
END
	   
	   
