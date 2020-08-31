
/****** Object:  Table [dbo].[settlement_netting_group]    Script Date: 11/17/2012 10:53:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[settlement_netting_group]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[settlement_netting_group](
	[netting_group_id] [int] IDENTITY(1,1) NOT NULL,
	[netting_group_name] [varchar](100) NULL,
	[template_id] [int] NOT NULL,
	[counterparty_id] [int] NULL,
 CONSTRAINT [PK_settlement_netting_group] PRIMARY KEY CLUSTERED 
(
	[netting_group_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[settlement_netting_group_detail]    Script Date: 11/17/2012 10:53:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[settlement_netting_group_detail]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[settlement_netting_group_detail](
	[netting_group_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[netting_group_id] [int] NOT NULL,
	[contract_detail_id] [int] NOT NULL,
 CONSTRAINT [PK_settlement_netting_group_detail] PRIMARY KEY CLUSTERED 
(
	[netting_group_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  ForeignKey [FK_settlement_netting_group_Contract_report_template]    Script Date: 11/17/2012 10:53:42 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_settlement_netting_group_Contract_report_template]') AND parent_object_id = OBJECT_ID(N'[dbo].[settlement_netting_group]'))
ALTER TABLE [dbo].[settlement_netting_group]  WITH CHECK ADD  CONSTRAINT [FK_settlement_netting_group_Contract_report_template] FOREIGN KEY([template_id])
REFERENCES [dbo].[Contract_report_template] ([template_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_settlement_netting_group_Contract_report_template]') AND parent_object_id = OBJECT_ID(N'[dbo].[settlement_netting_group]'))
ALTER TABLE [dbo].[settlement_netting_group] CHECK CONSTRAINT [FK_settlement_netting_group_Contract_report_template]
GO
/****** Object:  ForeignKey [FK_settlement_netting_group_source_counterparty]    Script Date: 11/17/2012 10:53:42 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_settlement_netting_group_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[settlement_netting_group]'))
ALTER TABLE [dbo].[settlement_netting_group]  WITH CHECK ADD  CONSTRAINT [FK_settlement_netting_group_source_counterparty] FOREIGN KEY([counterparty_id])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_settlement_netting_group_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[settlement_netting_group]'))
ALTER TABLE [dbo].[settlement_netting_group] CHECK CONSTRAINT [FK_settlement_netting_group_source_counterparty]
GO
/****** Object:  ForeignKey [FK_settlement_netting_group_detail_contract_group_detail]    Script Date: 11/17/2012 10:53:42 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_settlement_netting_group_detail_contract_group_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[settlement_netting_group_detail]'))
ALTER TABLE [dbo].[settlement_netting_group_detail]  WITH CHECK ADD  CONSTRAINT [FK_settlement_netting_group_detail_contract_group_detail] FOREIGN KEY([contract_detail_id])
REFERENCES [dbo].[contract_group_detail] ([ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_settlement_netting_group_detail_contract_group_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[settlement_netting_group_detail]'))
ALTER TABLE [dbo].[settlement_netting_group_detail] CHECK CONSTRAINT [FK_settlement_netting_group_detail_contract_group_detail]
GO
/****** Object:  ForeignKey [fk_settlement_netting_group_detail_netting_group_id]    Script Date: 11/17/2012 10:53:42 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_settlement_netting_group_detail_netting_group_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[settlement_netting_group_detail]'))
ALTER TABLE [dbo].[settlement_netting_group_detail]  WITH CHECK ADD  CONSTRAINT [fk_settlement_netting_group_detail_netting_group_id] FOREIGN KEY([netting_group_id])
REFERENCES [dbo].[settlement_netting_group] ([netting_group_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_settlement_netting_group_detail_netting_group_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[settlement_netting_group_detail]'))
ALTER TABLE [dbo].[settlement_netting_group_detail] CHECK CONSTRAINT [fk_settlement_netting_group_detail_netting_group_id]
GO
