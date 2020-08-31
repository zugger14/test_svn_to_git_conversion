IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_transfer_mapping_source_deal_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_transfer_mapping]'))
ALTER TABLE [dbo].[deal_transfer_mapping] DROP CONSTRAINT [FK_deal_transfer_mapping_source_deal_type]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_transfer_mapping_source_deal_type1]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_transfer_mapping]'))
ALTER TABLE [dbo].[deal_transfer_mapping] DROP CONSTRAINT [FK_deal_transfer_mapping_source_deal_type1]
GO
USE [TRMTracker]
GO
/****** Object:  Table [dbo].[deal_transfer_mapping]    Script Date: 06/08/2009 18:19:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deal_transfer_mapping]') AND type in (N'U'))
DROP TABLE [dbo].[deal_transfer_mapping]
GO

/****** Object:  Table [dbo].[deal_transfer_mapping]    Script Date: 06/08/2009 18:19:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[deal_transfer_mapping](
	[deal_transfer_mapping_id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_type_id] [int] NULL,
	[source_deal_sub_type_id] [int] NULL,
	[source_book_mapping_id_from] [int] NULL,
	[source_book_mapping_id_to] [int] NULL,
	[trader_id_from] [int] NULL,
	[trader_id_to] [int] NULL,
	[counterparty_id_from] [int] NULL,
	[counterparty_id_to] [int] NULL,
 CONSTRAINT [PK_deal_transfer_mapping] PRIMARY KEY CLUSTERED 
(
	[deal_transfer_mapping_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[deal_transfer_mapping]  WITH CHECK ADD  CONSTRAINT [FK_deal_transfer_mapping_source_deal_type] FOREIGN KEY([source_deal_type_id])
REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])
GO
ALTER TABLE [dbo].[deal_transfer_mapping]  WITH CHECK ADD  CONSTRAINT [FK_deal_transfer_mapping_source_deal_type1] FOREIGN KEY([source_deal_sub_type_id])
REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])
GO