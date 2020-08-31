
/****** Object:  Table [dbo].[partition_config_info]    Script Date: 02/16/2012 14:24:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID('dbo.[partition_config_info]',N'U') IS  NULL 
BEGIN 
CREATE TABLE [dbo].[partition_config_info](
	[part_id]				NUMERIC(18, 0)		 IDENTITY(1,1) NOT NULL,
	[table_name]			VARCHAR(100) NULL,
	[no_partitions]			NUMERIC(18, 0) NULL,
	[partition_nature]		VARCHAR(5) NULL,
	[partition_key]			VARCHAR(25) NULL,
	[function_name]			VARCHAR(100) NULL,
	[scheme_name]			VARCHAR(100) NULL,
	[frequency]				VARCHAR(1) NULL,
	[filegroup]				VARCHAR(20) NULL,
	[archive_status]		VARCHAR(1) NULL,
	[stage_table_name]		VARCHAR(100) NULL,
	[archive_table_name]	VARCHAR(100) NULL,
	[archive_db_name]		VARCHAR(100) NULL,
	[archive_server]		VARCHAR(150) NULL,
	[del_flg]				VARCHAR(1) NULL,
	[create_user]			VARCHAR(100) NULL,
	[create_ts]				DATE NULL,
	[update_user]			VARCHAR(100) NULL,
	[update_ts]				DATE NULL,
 CONSTRAINT [pk_partition_info] PRIMARY KEY CLUSTERED 
(
	[part_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[df_partition_info_del_flg]') AND parent_object_id = OBJECT_ID(N'[dbo].[partition_config_info]'))
ALTER TABLE [dbo].[partition_config_info] ADD  CONSTRAINT [df_partition_info_del_flg]  DEFAULT ('N') FOR [del_flg]

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[df_partition_info_archive_status]') AND parent_object_id = OBJECT_ID(N'[dbo].[partition_config_info]'))
ALTER TABLE [dbo].[partition_config_info] ADD  CONSTRAINT [df_partition_info_archive_status]  DEFAULT ('Y') FOR [archive_status]

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[df_partition_info_create_ts]') AND parent_object_id = OBJECT_ID(N'[dbo].[partition_config_info]'))
ALTER TABLE [dbo].[partition_config_info] ADD  CONSTRAINT [df_partition_info_create_ts]  DEFAULT (GETDATE()) FOR [create_ts]



END 



