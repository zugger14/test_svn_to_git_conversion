/****** Object:  Table [dbo].[gl_inventory_account_type]    Script Date: 08/27/2009 17:44:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[gl_inventory_account_type]') AND type in (N'U'))
DROP TABLE [dbo].[gl_inventory_account_type]
GO
/****** Object:  Table [dbo].[gl_inventory_book_map]    Script Date: 08/27/2009 17:44:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[gl_inventory_book_map]') AND type in (N'U'))
DROP TABLE [dbo].[gl_inventory_book_map]
/****** Object:  Table [dbo].[gl_inventory_account_type]    Script Date: 08/27/2009 17:44:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[gl_inventory_account_type](
	[gl_account_id] [int] IDENTITY(1,1) NOT NULL,
	[sub_entity_id] [int] NULL,
	[stra_entity_id] [int] NULL,
	[book_entity_id] [int] NULL,
	[jurisdiction] [int] NULL,
	[state_value_id] [int] NULL,
	[technology_value_id] [int] NULL,
	[account_type_value_id] [int] NULL,
	[account_type_name] [varchar](100) NULL,
	[gl_number_id] [int] NULL,
	[portfolio_id] [int] NULL,
	[assignment_type_id] [int] NULL,
	[assignment_gl_number_id] [int] NULL,
	[column_map_id1] [int] NULL,
	[value_id1] [int] NULL,
	[column_map_id2] [int] NULL,
	[value_id2] [int] NULL,
	[column_map_id3] [int] NULL,
	[value_id3] [int] NULL,
	[column_map_id4] [int] NULL,
	[value_id4] [int] NULL,
	[column_map_id5] [int] NULL,
	[value_id5] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[gl_inventory_book_map]    Script Date: 08/27/2009 17:44:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[gl_inventory_book_map](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[book_id] [int] NOT NULL,
	[group_name] [varchar](100) NOT NULL,
	[seq_number] [int] NOT NULL,
	[table_name] [varchar](100) NULL,
	[column_name] [varchar](50) NULL,
	[criteria] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF