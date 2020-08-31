IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_major_location_detail_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[major_location_detail]'))
ALTER TABLE [dbo].[major_location_detail] DROP CONSTRAINT [FK_major_location_detail_contract_group]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_major_location_detail_source_major_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[major_location_detail]'))
ALTER TABLE [dbo].[major_location_detail] DROP CONSTRAINT [FK_major_location_detail_source_major_location]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_major_location_detail_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[major_location_detail]'))
ALTER TABLE [dbo].[major_location_detail] DROP CONSTRAINT [FK_major_location_detail_source_uom]
GO
/****** Object:  Table [dbo].[major_location_detail]    Script Date: 01/21/2009 16:57:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[major_location_detail]') AND type in (N'U'))
DROP TABLE [dbo].[major_location_detail]
GO
CREATE TABLE [dbo].[major_location_detail](
	[major_location_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[major_location_id] [int] NOT NULL,
	[owner] [varchar](100) NULL,
	[operator] [varchar](100) NULL,
	[counterparty] [int] NOT NULL,
	[contract] [int] NOT NULL,
	[volume] [float] NULL,
	[uom] [int] NULL,
 CONSTRAINT [PK_major_location_detail] PRIMARY KEY CLUSTERED 
(
	[major_location_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[major_location_detail]  WITH CHECK ADD  CONSTRAINT [FK_major_location_detail_contract_group] FOREIGN KEY([contract])
REFERENCES [dbo].[contract_group] ([contract_id])
GO
ALTER TABLE [dbo].[major_location_detail] CHECK CONSTRAINT [FK_major_location_detail_contract_group]
GO
ALTER TABLE [dbo].[major_location_detail]  WITH CHECK ADD  CONSTRAINT [FK_major_location_detail_source_major_location] FOREIGN KEY([major_location_id])
REFERENCES [dbo].[source_major_location] ([source_major_location_ID])
GO
ALTER TABLE [dbo].[major_location_detail] CHECK CONSTRAINT [FK_major_location_detail_source_major_location]
GO
ALTER TABLE [dbo].[major_location_detail]  WITH CHECK ADD  CONSTRAINT [FK_major_location_detail_source_uom] FOREIGN KEY([uom])
REFERENCES [dbo].[source_uom] ([source_uom_id])
GO
ALTER TABLE [dbo].[major_location_detail] CHECK CONSTRAINT [FK_major_location_detail_source_uom]