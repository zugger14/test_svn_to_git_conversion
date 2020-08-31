
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bid_offer_formulator_detail_bid_offer_formulator_header]') AND parent_object_id = OBJECT_ID(N'[dbo].[bid_offer_formulator_detail]'))
ALTER TABLE [dbo].[bid_offer_formulator_detail] DROP CONSTRAINT [FK_bid_offer_formulator_detail_bid_offer_formulator_header]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bid_offer_formulator_detail_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[bid_offer_formulator_detail]'))
ALTER TABLE [dbo].[bid_offer_formulator_detail] DROP CONSTRAINT [FK_bid_offer_formulator_detail_formula_editor]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bid_offer_formulator_detail_formula_editor1]') AND parent_object_id = OBJECT_ID(N'[dbo].[bid_offer_formulator_detail]'))
ALTER TABLE [dbo].[bid_offer_formulator_detail] DROP CONSTRAINT [FK_bid_offer_formulator_detail_formula_editor1]
GO
/****** Object:  Table [dbo].[bid_offer_formulator_detail]    Script Date: 05/18/2009 16:28:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bid_offer_formulator_detail]') AND type in (N'U'))
DROP TABLE [dbo].[bid_offer_formulator_detail]
/****** Object:  Table [dbo].[bid_offer_formulator_detail]    Script Date: 05/18/2009 16:29:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[bid_offer_formulator_detail](
	[bid_offer_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[bid_offer_id] [int] NOT NULL,
	[block_id] [int] NOT NULL,
	[volume_formula_id] [int] NULL,
	[price_formula_id] [int] NULL,
	[create_user] [varchar](50) NOT NULL,
	[create_ts] [datetime] NOT NULL,
	[update_user] [varchar](50) NOT NULL,
	[update_ts] [datetime] NOT NULL,
 CONSTRAINT [PK_bid_offer_formulator_detail] PRIMARY KEY CLUSTERED 
(
	[bid_offer_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[bid_offer_formulator_detail]  WITH CHECK ADD  CONSTRAINT [FK_bid_offer_formulator_detail_bid_offer_formulator_header] FOREIGN KEY([bid_offer_id])
REFERENCES [dbo].[bid_offer_formulator_header] ([bid_offer_id])
GO
ALTER TABLE [dbo].[bid_offer_formulator_detail] CHECK CONSTRAINT [FK_bid_offer_formulator_detail_bid_offer_formulator_header]
GO
ALTER TABLE [dbo].[bid_offer_formulator_detail]  WITH CHECK ADD  CONSTRAINT [FK_bid_offer_formulator_detail_formula_editor] FOREIGN KEY([volume_formula_id])
REFERENCES [dbo].[formula_editor] ([formula_id])
GO
ALTER TABLE [dbo].[bid_offer_formulator_detail] CHECK CONSTRAINT [FK_bid_offer_formulator_detail_formula_editor]
GO
ALTER TABLE [dbo].[bid_offer_formulator_detail]  WITH CHECK ADD  CONSTRAINT [FK_bid_offer_formulator_detail_formula_editor1] FOREIGN KEY([price_formula_id])
REFERENCES [dbo].[formula_editor] ([formula_id])
GO
ALTER TABLE [dbo].[bid_offer_formulator_detail] CHECK CONSTRAINT [FK_bid_offer_formulator_detail_formula_editor1]