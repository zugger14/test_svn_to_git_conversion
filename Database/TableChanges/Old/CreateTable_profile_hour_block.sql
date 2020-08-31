
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_profile_hour_block_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[profile_hour_block]'))
ALTER TABLE [dbo].[profile_hour_block] DROP CONSTRAINT [FK_profile_hour_block_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_profile_hour_block_static_data_value1]') AND parent_object_id = OBJECT_ID(N'[dbo].[profile_hour_block]'))
ALTER TABLE [dbo].[profile_hour_block] DROP CONSTRAINT [FK_profile_hour_block_static_data_value1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_profile_hour_block_static_data_value2]') AND parent_object_id = OBJECT_ID(N'[dbo].[profile_hour_block]'))
ALTER TABLE [dbo].[profile_hour_block] DROP CONSTRAINT [FK_profile_hour_block_static_data_value2]
GO
 
GO
/****** Object:  Table [dbo].[profile_hour_block]    Script Date: 12/04/2010 22:16:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[profile_hour_block]') AND type in (N'U'))
DROP TABLE [dbo].[profile_hour_block]
/****** Object:  Table [dbo].[profile_hour_block]    Script Date: 12/04/2010 22:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[profile_hour_block](
	[profile_hour_block_id] [int] IDENTITY(1,1) NOT NULL,
	[profile_id] [int] NULL,
	[block_type] [int] NULL,
	[block_define_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [nchar](10) NULL,
 CONSTRAINT [PK_profile_hour_block] PRIMARY KEY CLUSTERED 
(
	[profile_hour_block_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[profile_hour_block]  WITH CHECK ADD  CONSTRAINT [FK_profile_hour_block_static_data_value] FOREIGN KEY([profile_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[profile_hour_block] CHECK CONSTRAINT [FK_profile_hour_block_static_data_value]
GO
ALTER TABLE [dbo].[profile_hour_block]  WITH CHECK ADD  CONSTRAINT [FK_profile_hour_block_static_data_value1] FOREIGN KEY([block_define_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[profile_hour_block] CHECK CONSTRAINT [FK_profile_hour_block_static_data_value1]
GO
ALTER TABLE [dbo].[profile_hour_block]  WITH CHECK ADD  CONSTRAINT [FK_profile_hour_block_static_data_value2] FOREIGN KEY([block_type])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[profile_hour_block] CHECK CONSTRAINT [FK_profile_hour_block_static_data_value2]
Go
INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(-6,12002,291443)
INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(-6,12000,291366)
INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(-6,12001,291366)

INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(-7,12002,291443)
INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(-7,12000,291366)
INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(-7,12001,291366)

INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(291713,12002,291443)
INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(291713,12000,291366)
INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(291713,12001,291366)

INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(291707,12002,291443)
INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(291707,12000,291366)
INSERT INTO profile_hour_block(profile_id,block_type,block_define_id) values(291707,12001,291366)
