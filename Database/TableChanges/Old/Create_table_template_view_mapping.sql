SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[template_view_mapping]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[template_view_mapping](
	[id] INT IDENTITY(1, 1) NOT NULL,
	[contract_template_views_id] [int] NOT NULL,
	[columns_id] [int] NOT NULL,
	[tag_name] VARCHAR(500) NULL,
	[recursive] CHAR(1) NULL DEFAULT 0,
	[create_user] [varchar](50) NULL DEFAULT dbo.FNADBUSER(),
	[create_ts] [datetime] NULL DEFAULT GETDATE(),
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[user_action] [varchar](50) NULL
) ON [PRIMARY]

END
ELSE
BEGIN
    PRINT 'Table template_view_mapping EXISTS'
END

SET ANSI_PADDING OFF
GO

