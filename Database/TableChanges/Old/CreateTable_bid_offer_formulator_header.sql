IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bid_offer_formulator_header_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[bid_offer_formulator_header]'))
ALTER TABLE [dbo].[bid_offer_formulator_header] DROP CONSTRAINT [FK_bid_offer_formulator_header_static_data_value]
GO
/****** Object:  Table [dbo].[bid_offer_formulator_header]    Script Date: 05/18/2009 16:29:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bid_offer_formulator_header]') AND type in (N'U'))
DROP TABLE [dbo].[bid_offer_formulator_header]
/****** Object:  Table [dbo].[bid_offer_formulator_header]    Script Date: 05/18/2009 16:30:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[bid_offer_formulator_header](
	[bid_offer_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](100) NULL,
	[product_type_id] [int] NOT NULL,
	[bid_offer_flag] [char](1) NOT NULL,
	[create_user] [varchar](50) NOT NULL,
	[create_ts] [datetime] NOT NULL,
	[update_user] [varchar](50) NOT NULL,
	[update_ts] [datetime] NOT NULL,
 CONSTRAINT [PK_bid_offer_formulator_header] PRIMARY KEY CLUSTERED 
(
	[bid_offer_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[bid_offer_formulator_header]  WITH CHECK ADD  CONSTRAINT [FK_bid_offer_formulator_header_static_data_value] FOREIGN KEY([product_type_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[bid_offer_formulator_header] CHECK CONSTRAINT [FK_bid_offer_formulator_header_static_data_value]