
/****** Object:  Table [dbo].[deal_transport_header]    Script Date: 01/20/2009 17:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[deal_transport_header](
	[deal_transport_id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NULL
 CONSTRAINT [PK_deal_transport_header] PRIMARY KEY CLUSTERED 
(
	[deal_transport_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
