
/****** Object:  Table [dbo].[deal_transport_detail]    Script Date: 01/20/2009 17:46:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[deal_transport_detail](
	[deal_transport_deatail_id] [int] IDENTITY(1,1) NOT NULL,
	[deal_transport_id] [int] NULL,
	[source_deal_detail_id_from] [int] NULL,
	[source_deal_detail_id_to] [int] NULL,
 CONSTRAINT [PK_deal_transport_detail] PRIMARY KEY CLUSTERED 
(
	[deal_transport_deatail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[deal_transport_detail]  WITH CHECK ADD  CONSTRAINT [FK_deal_transport_detail_deal_transport_header] FOREIGN KEY([deal_transport_id])
REFERENCES [dbo].[deal_transport_header] ([deal_transport_id])
GO
ALTER TABLE [dbo].[deal_transport_detail] CHECK CONSTRAINT [FK_deal_transport_detail_deal_transport_header]