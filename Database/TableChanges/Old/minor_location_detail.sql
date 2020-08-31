
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_minor_location_detail_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[minor_location_detail]'))
ALTER TABLE [dbo].[minor_location_detail] DROP CONSTRAINT [FK_minor_location_detail_contract_group]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_minor_location_detail_source_minor_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[minor_location_detail]'))
ALTER TABLE [dbo].[minor_location_detail] DROP CONSTRAINT [FK_minor_location_detail_source_minor_location]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_minor_location_detail_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[minor_location_detail]'))
ALTER TABLE [dbo].[minor_location_detail] DROP CONSTRAINT [FK_minor_location_detail_source_uom]
GO

/****** Object:  Table [dbo].[minor_location_detail]    Script Date: 01/21/2009 16:56:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[minor_location_detail]') AND type in (N'U'))
DROP TABLE [dbo].[minor_location_detail]
GO
CREATE TABLE [dbo].[minor_location_detail](
	[minor_location_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[minor_location_id] [int] NOT NULL,
	[owner] [varchar](100) NULL,
	[operator] [varchar](100) NULL,
	[contract] [int] NOT NULL,
	[volume] [float] NULL,
	[uom] [int] NULL,
 CONSTRAINT [PK_minor_location_detail] PRIMARY KEY CLUSTERED 
(
	[minor_location_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[minor_location_detail]  WITH CHECK ADD  CONSTRAINT [FK_minor_location_detail_contract_group] FOREIGN KEY([contract])
REFERENCES [dbo].[contract_group] ([contract_id])
GO
ALTER TABLE [dbo].[minor_location_detail] CHECK CONSTRAINT [FK_minor_location_detail_contract_group]
GO
ALTER TABLE [dbo].[minor_location_detail]  WITH CHECK ADD  CONSTRAINT [FK_minor_location_detail_source_minor_location] FOREIGN KEY([minor_location_id])
REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
GO
ALTER TABLE [dbo].[minor_location_detail] CHECK CONSTRAINT [FK_minor_location_detail_source_minor_location]
GO
ALTER TABLE [dbo].[minor_location_detail]  WITH CHECK ADD  CONSTRAINT [FK_minor_location_detail_source_uom] FOREIGN KEY([uom])
REFERENCES [dbo].[source_uom] ([source_uom_id])
GO
ALTER TABLE [dbo].[minor_location_detail] CHECK CONSTRAINT [FK_minor_location_detail_source_uom]