 
GO
/****** Object:  Table [dbo].[sap_trm_mapping]    Script Date: 10/02/2011 09:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sap_trm_mapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[sap_trm_mapping](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[curve_id] [int] NULL,
	[entity_id] [int] NULL,
	[deal_type_id] [int] NULL,
	[invoice_line_item_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[grid_id] [varchar](20) NULL,
	[material_id] [varchar](20) NULL,
	[profit_center_id] [varchar](20) NULL,
 CONSTRAINT [PK_sap_trm_mapping] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
