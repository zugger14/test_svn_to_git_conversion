
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_trader_ticket_template_source_commodity]') AND parent_object_id = OBJECT_ID(N'[dbo].[trader_ticket_template]'))
ALTER TABLE [dbo].[trader_ticket_template] DROP CONSTRAINT [FK_trader_ticket_template_source_commodity]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_trader_ticket_template_source_deal_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[trader_ticket_template]'))
ALTER TABLE [dbo].[trader_ticket_template] DROP CONSTRAINT [FK_trader_ticket_template_source_deal_type]
GO

/****** Object:  Table [dbo].[trader_ticket_template]    Script Date: 10/16/2009 14:48:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trader_ticket_template]') AND type in (N'U'))
DROP TABLE [dbo].[trader_ticket_template]

/****** Object:  Table [dbo].[trader_ticket_template]    Script Date: 10/16/2009 14:47:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[trader_ticket_template](
	[template_id] [int] NOT NULL,
	[template_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[template_desc] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[template_filename] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[commodity_id] [int] NULL,
	[deal_type] [int] NULL,
 CONSTRAINT [PK_trader_ticket_template] PRIMARY KEY CLUSTERED 
(
	[template_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_trader_ticket_template] UNIQUE NONCLUSTERED 
(
	[template_name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_trader_ticket_template_1] UNIQUE NONCLUSTERED 
(
	[template_filename] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[trader_ticket_template]  WITH CHECK ADD  CONSTRAINT [FK_trader_ticket_template_source_commodity] FOREIGN KEY([commodity_id])
REFERENCES [dbo].[source_commodity] ([source_commodity_id])
GO
ALTER TABLE [dbo].[trader_ticket_template]  WITH CHECK ADD  CONSTRAINT [FK_trader_ticket_template_source_deal_type] FOREIGN KEY([deal_type])
REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])