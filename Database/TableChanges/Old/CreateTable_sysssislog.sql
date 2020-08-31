-- SSIS Log table
IF OBJECT_ID(N'sysssislog', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.[sysssislog](
      [id] [INT] IDENTITY(1,1) NOT NULL,
      [event] [sysname] NOT NULL,
      [computer] [NVARCHAR](128) NOT NULL,
      [operator] [NVARCHAR](128) NOT NULL,
      [source] [NVARCHAR](1024) NOT NULL,
      [sourceid] [UNIQUEIDENTIFIER] NOT NULL,
      [executionid] [UNIQUEIDENTIFIER] NOT NULL,
      [starttime] [DATETIME] NOT NULL,
      [endtime] [DATETIME] NOT NULL,
      [datacode] [INT] NOT NULL,
      [databytes] [IMAGE] NULL,
      [message] [NVARCHAR](2048) NOT NULL,
	PRIMARY KEY CLUSTERED
	(
		  [id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	
	PRINT 'Table [sysssislog] created.'
END
ELSE
BEGIN
	PRINT 'Table [sysssislog] already exists.'
END
GO


