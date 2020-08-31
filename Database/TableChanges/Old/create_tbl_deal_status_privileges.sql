/****** Object:  Table [dbo].[report_writer_privileges]    Script Date: 04/09/2012 10:54:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[deal_status_privileges]', N'U') IS NULL
BEGIN 
	CREATE TABLE [dbo].[deal_status_privileges](
		[deal_status_privilege_ID] [int] IDENTITY(1,1) NOT NULL,
		[user_id] [varchar](100) NULL,
		[role_id] [int] NULL,
		[deal_status_ID] [int] NULL,
		[create_user] [varchar](50) DEFAULT dbo.FNADBUser(),
		[create_ts] [datetime] DEFAULT GETDATE(),
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
	 CONSTRAINT [PK_deal_status_privileges] PRIMARY KEY CLUSTERED 
	(
		[deal_status_privilege_ID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END 
ELSE
BEGIN
    PRINT 'Table deal_status_privileges EXISTS'
END

GO


SET ANSI_PADDING OFF
GO


