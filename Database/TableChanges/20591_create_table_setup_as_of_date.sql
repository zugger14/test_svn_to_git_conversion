SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[setup_as_of_date]', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.setup_as_of_date (
		setup_as_of_date_id  INT IDENTITY(1, 1),
		module_id			 INT,
		screen_id			 INT,
		as_of_date          INT,
		no_of_days			INT,
		custom_as_of_date	DATETIME,		
		[create_user] [varchar](50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] [datetime] NULL DEFAULT GETDATE(),
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL		
		CONSTRAINT [IX_ticket_cost] UNIQUE NONCLUSTERED([module_id] ASC, [screen_id] ASC)
		WITH (
			PAD_INDEX = OFF,
			STATISTICS_NORECOMPUTE = OFF,
			IGNORE_DUP_KEY = OFF,
			ALLOW_ROW_LOCKS = ON,
			ALLOW_PAGE_LOCKS = ON,
			FILLFACTOR = 90
	    ) ON [PRIMARY]
	)
END





