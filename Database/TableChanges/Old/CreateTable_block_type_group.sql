GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_block_type_group_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[block_type_group]'))
ALTER TABLE [dbo].[block_type_group] DROP CONSTRAINT [FK_block_type_group_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_block_type_group_static_data_value1]') AND parent_object_id = OBJECT_ID(N'[dbo].[block_type_group]'))
ALTER TABLE [dbo].[block_type_group] DROP CONSTRAINT [FK_block_type_group_static_data_value1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_block_type_group_static_data_value2]') AND parent_object_id = OBJECT_ID(N'[dbo].[block_type_group]'))
ALTER TABLE [dbo].[block_type_group] DROP CONSTRAINT [FK_block_type_group_static_data_value2]
/****** Object:  Table [dbo].[block_type_group]    Script Date: 10/26/2009 09:05:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[block_type_group]') AND type in (N'U'))
DROP TABLE [dbo].[block_type_group]
/****** Object:  Table [dbo].[block_type_group]    Script Date: 10/26/2009 09:05:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[block_type_group](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[block_type_group_id] [int] NOT NULL,
	[block_type_id] [int] NOT NULL,
	[block_name] [varchar](100) NOT NULL,
	[hourly_block_id] [int] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_block_type_group] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[block_type_group]  WITH CHECK ADD  CONSTRAINT [FK_block_type_group_static_data_value] FOREIGN KEY([block_type_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[block_type_group] CHECK CONSTRAINT [FK_block_type_group_static_data_value]
GO
ALTER TABLE [dbo].[block_type_group]  WITH CHECK ADD  CONSTRAINT [FK_block_type_group_static_data_value1] FOREIGN KEY([hourly_block_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[block_type_group] CHECK CONSTRAINT [FK_block_type_group_static_data_value1]
GO
ALTER TABLE [dbo].[block_type_group]  WITH CHECK ADD  CONSTRAINT [FK_block_type_group_static_data_value2] FOREIGN KEY([block_type_group_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[block_type_group] CHECK CONSTRAINT [FK_block_type_group_static_data_value2]
GO

/****** Object:  Trigger [TRGINS_block_type_group]    Script Date: 10/26/2009 09:06:38 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_block_type_group]'))
DROP TRIGGER [dbo].[TRGINS_block_type_group]
/****** Object:  Trigger [dbo].[TRGINS_block_type_group]    Script Date: 10/26/2009 09:06:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGINS_block_type_group]
ON [dbo].[block_type_group]
FOR INSERT
AS
UPDATE block_type_group SET create_user =dbo.FNADBUser(), create_ts = getdate() where  block_type_group.[id] in (select [id] from inserted)
GO
/****** Object:  Trigger [TRGUPD_block_type_group]    Script Date: 10/26/2009 09:08:26 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_block_type_group]'))
DROP TRIGGER [dbo].[TRGUPD_block_type_group]
/****** Object:  Trigger [dbo].[TRGUPD_block_type_group]    Script Date: 10/26/2009 09:08:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGUPD_block_type_group]
ON [dbo].[block_type_group]
FOR UPDATE
AS
UPDATE block_type_group SET update_user = dbo.FNADBUser(), update_ts = getdate() where  block_type_group.[id] in (select [id] from deleted)

