/****** Object:  Table [dbo].[post_je_report]    Script Date: 12/24/2008 16:07:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

DROP TABLE [dbo].[post_je_report]
GO

CREATE TABLE [dbo].[post_je_report](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[prod_date] [datetime] NOT NULL,
	[sub_id] [int] NOT NULL,
	[counterparty_id] [int] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_post_je_report] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[post_je_report]  WITH CHECK ADD  CONSTRAINT [FK_post_je_report_portfolio_hierarchy] FOREIGN KEY([sub_id])
REFERENCES [dbo].[portfolio_hierarchy] ([entity_id])
GO
ALTER TABLE [dbo].[post_je_report]  WITH CHECK ADD  CONSTRAINT [FK_post_je_report_source_counterparty] FOREIGN KEY([counterparty_id])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])