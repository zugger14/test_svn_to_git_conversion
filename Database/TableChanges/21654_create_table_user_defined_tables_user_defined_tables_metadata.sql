SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_tables]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_defined_tables](
	[udt_id] [int] IDENTITY(1,1) NOT NULL,
	[udt_name] [varchar](200) NOT NULL,
	[udt_descriptions] [varchar](200) NOT NULL,
	[create_user] [varchar](50) NULL DEFAULT ([dbo].[FNADBUser]()),
	[create_ts] [datetime] NULL DEFAULT (getdate()),
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[udt_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_udt_name] UNIQUE NONCLUSTERED 
(
	[udt_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[user_defined_tables_metadata]    Script Date: 7/11/2018 2:36:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_tables_metadata]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_defined_tables_metadata](
	[udtm_id] [int] IDENTITY(1,1) NOT NULL,
	[udt_id] [int] NOT NULL,
	[column_name] [varchar](200) NOT NULL,
	[column_descriptions] [varchar](500) NOT NULL,
	[column_type] [varchar](50) NOT NULL,
	[column_length] [int] NOT NULL,
	[column_prec] [int] NULL,
	[column_scale] [int] NULL,
	[column_nullable] [char](3) NOT NULL,
	[is_primary] [bit] NOT NULL,
	[is_identity] [bit] NOT NULL,
	[static_data_type_id] [int] NULL,
	[create_user] [varchar](50) NULL DEFAULT ([dbo].[FNADBUser]()),
	[create_ts] [datetime] NULL DEFAULT (getdate()),
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[has_value] [bit] NULL DEFAULT ((0)),
	[use_as_filter] [bit] NULL,
	[sequence_no] [int] NULL,
	[rounding] [int] NULL,
	[unique_combination] [int] NULL,
	[custom_validation] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[udtm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__user_defi__udt_i__08DD3631]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_defined_tables_metadata]'))
ALTER TABLE [dbo].[user_defined_tables_metadata]  WITH CHECK ADD FOREIGN KEY([udt_id])
REFERENCES [dbo].[user_defined_tables] ([udt_id])
GO
