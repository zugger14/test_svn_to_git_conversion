IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_confirm_status_recent_confirm_status_recent]') AND parent_object_id = OBJECT_ID(N'[dbo].[confirm_status_recent]'))
ALTER TABLE [dbo].[confirm_status_recent] DROP CONSTRAINT [FK_confirm_status_recent_confirm_status_recent]
GO
/****** Object:  Table [dbo].[confirm_status_recent]    Script Date: 01/07/2009 11:29:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[confirm_status_recent]') AND type in (N'U'))
DROP TABLE [dbo].[confirm_status_recent]
GO
CREATE TABLE [dbo].[confirm_status_recent](
	[confirm_status_id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[type] [varchar](1) NULL,
	[as_of_date] [datetime] NOT NULL,
	[comment1] [varchar](255) NULL,
	[comment2] [varchar](250) NULL,
	[confirm_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_confirm_status_recent] PRIMARY KEY CLUSTERED 
(
	[confirm_status_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[confirm_status_recent]  WITH CHECK ADD  CONSTRAINT [FK_confirm_status_recent_confirm_status_recent] FOREIGN KEY([source_deal_header_id])
REFERENCES [dbo].[source_deal_header] ([source_deal_header_id])
GO
ALTER TABLE [dbo].[confirm_status_recent] CHECK CONSTRAINT [FK_confirm_status_recent_confirm_status_recent]