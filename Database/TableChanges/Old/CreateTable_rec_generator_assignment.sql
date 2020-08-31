IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_rec_generator_assignment_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[rec_generator_assignment]'))
ALTER TABLE [dbo].[rec_generator_assignment] DROP CONSTRAINT [FK_rec_generator_assignment_rec_generator]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_rec_generator_assignment_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[rec_generator_assignment]'))
ALTER TABLE [dbo].[rec_generator_assignment] DROP CONSTRAINT [FK_rec_generator_assignment_source_counterparty]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_rec_generator_assignment_source_traders]') AND parent_object_id = OBJECT_ID(N'[dbo].[rec_generator_assignment]'))
ALTER TABLE [dbo].[rec_generator_assignment] DROP CONSTRAINT [FK_rec_generator_assignment_source_traders]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_rec_generator_assignment_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[rec_generator_assignment]'))
ALTER TABLE [dbo].[rec_generator_assignment] DROP CONSTRAINT [FK_rec_generator_assignment_source_uom]
GO

/****** Object:  Table [dbo].[rec_generator_assignment]    Script Date: 10/27/2009 16:25:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rec_generator_assignment]') AND type in (N'U'))
DROP TABLE [dbo].[rec_generator_assignment]
/****** Object:  Table [dbo].[rec_generator_assignment]    Script Date: 10/27/2009 16:25:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[rec_generator_assignment](
	[generator_assignment_id] [int] IDENTITY(1,1) NOT NULL,
	[generator_id] [int] NOT NULL,
	[auto_assignment_type] [int] NOT NULL,
	[auto_assignment_per] [float] NULL,
	[term_start] [datetime] NULL,
	[term_end] [datetime] NULL,
	[counterparty_id] [int] NULL,
	[trader_id] [int] NULL,
	[sold_price] [float] NULL,
	[exclude_inventory] [char](1) NULL,
	[max_volume] [float] NULL,
	[uom_id] [int] NULL,
	[use_market_price] [char](1) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_rec_generator_assignment] PRIMARY KEY CLUSTERED 
(
	[generator_assignment_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[rec_generator_assignment]  WITH NOCHECK ADD  CONSTRAINT [FK_rec_generator_assignment_rec_generator] FOREIGN KEY([generator_id])
REFERENCES [dbo].[rec_generator] ([generator_id])
GO
ALTER TABLE [dbo].[rec_generator_assignment] CHECK CONSTRAINT [FK_rec_generator_assignment_rec_generator]
GO
ALTER TABLE [dbo].[rec_generator_assignment]  WITH NOCHECK ADD  CONSTRAINT [FK_rec_generator_assignment_source_counterparty] FOREIGN KEY([counterparty_id])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
GO
ALTER TABLE [dbo].[rec_generator_assignment] CHECK CONSTRAINT [FK_rec_generator_assignment_source_counterparty]
GO
ALTER TABLE [dbo].[rec_generator_assignment]  WITH NOCHECK ADD  CONSTRAINT [FK_rec_generator_assignment_source_traders] FOREIGN KEY([trader_id])
REFERENCES [dbo].[source_traders] ([source_trader_id])
GO
ALTER TABLE [dbo].[rec_generator_assignment] CHECK CONSTRAINT [FK_rec_generator_assignment_source_traders]
GO
ALTER TABLE [dbo].[rec_generator_assignment]  WITH CHECK ADD  CONSTRAINT [FK_rec_generator_assignment_source_uom] FOREIGN KEY([uom_id])
REFERENCES [dbo].[source_uom] ([source_uom_id])
GO
ALTER TABLE [dbo].[rec_generator_assignment] CHECK CONSTRAINT [FK_rec_generator_assignment_source_uom]