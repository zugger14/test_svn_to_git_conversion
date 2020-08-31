/* 
Author : Santosh Gupta 
Date: 26th Jan 2012
Purpose: This table is for Maintenance Script to log the Maintenance Works conducted on Any database

*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[Commandlog]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[CommandLog](
[ID] int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_CommandLog] PRIMARY KEY CLUSTERED,
[DatabaseName] sysname NULL,
[SchemaName] sysname NULL,
[ObjectName] sysname NULL,
[ObjectType] char(2) NULL,
[IndexName] sysname NULL,
[IndexType] tinyint NULL,
[StatisticsName] sysname NULL,
[PartitionNumber] int NULL,
[ExtendedInfo] xml NULL,
[Command] nvarchar(max) NOT NULL,
[CommandType] nvarchar(60) NOT NULL,
[StartTime] datetime NOT NULL,
[EndTime] datetime NULL,
[ErrorNumber] int NULL,
[ErrorMessage] nvarchar(max) NULL
)
END
ELSE
BEGIN
    PRINT 'Table table_name EXISTS'
END

GO
