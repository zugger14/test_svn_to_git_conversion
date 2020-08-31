IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_settlement_dispute_save_invoice]') AND parent_object_id = OBJECT_ID(N'[dbo].[settlement_dispute]'))
ALTER TABLE [dbo].[settlement_dispute] DROP CONSTRAINT [FK_settlement_dispute_save_invoice]
GO
/****** Object:  Table [dbo].[settlement_dispute]    Script Date: 05/18/2009 20:05:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[settlement_dispute]') AND type in (N'U'))
DROP TABLE [dbo].[settlement_dispute]
GO
/****** Object:  Table [dbo].[settlement_dispute]    Script Date: 05/18/2009 20:05:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[settlement_dispute](
	[dispute_id] [int] IDENTITY(1,1) NOT NULL,
	[invoice_id] [int] NOT NULL,
	[billing_period] [datetime] NOT NULL,
	[dispute_date_time] [datetime] NOT NULL,
	[dispute_user] [varchar](50) NOT NULL,
	[dispute_comment] [varchar](100) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_settlement_dispute] PRIMARY KEY CLUSTERED 
(
	[dispute_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[settlement_dispute]  WITH CHECK ADD  CONSTRAINT [FK_settlement_dispute_save_invoice] FOREIGN KEY([invoice_id])
REFERENCES [dbo].[save_invoice] ([save_invoice_id])
GO
ALTER TABLE [dbo].[settlement_dispute] CHECK CONSTRAINT [FK_settlement_dispute_save_invoice]