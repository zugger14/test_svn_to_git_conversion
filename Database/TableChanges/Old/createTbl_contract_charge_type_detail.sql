
/****** Object:  Table [dbo].[contract_charge_type_detail]    Script Date: 12/12/2008 15:05:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[contract_charge_type_detail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[contract_charge_type_id] [int] NOT NULL,
	[invoice_line_item_id] [int] NULL,
	[default_gl_id] [int] NULL,
	[price] [float] NULL,
	[formula_id] [int] NULL,
	[manual] [char](1) NULL,
	[currency] [int] NULL,
	[volume_granularity] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[Prod_type] [char](1) NULL,
	[sequence_order] [int] NULL,
	[inventory_item] [char](1) NULL,
	[default_gl_id_estimates] [int] NULL,
 CONSTRAINT [PK_contract_charge_type_detail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_contract_charge_type_detail] UNIQUE NONCLUSTERED 
(
	[contract_charge_type_id] ASC,
	[invoice_line_item_id] ASC,
	[Prod_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[contract_charge_type_detail]  WITH CHECK ADD  CONSTRAINT [FK_contract_charge_type_detail_contract_charge_type] FOREIGN KEY([contract_charge_type_id])
REFERENCES [dbo].[contract_charge_type] ([contract_charge_type_id])
GO
ALTER TABLE [dbo].[contract_charge_type_detail] CHECK CONSTRAINT [FK_contract_charge_type_detail_contract_charge_type]