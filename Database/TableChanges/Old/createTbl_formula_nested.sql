
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_formula_nested_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[formula_nested]'))
ALTER TABLE [dbo].[formula_nested] DROP CONSTRAINT [FK_formula_nested_formula_editor]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_formula_nested_formula_editor1]') AND parent_object_id = OBJECT_ID(N'[dbo].[formula_nested]'))
ALTER TABLE [dbo].[formula_nested] DROP CONSTRAINT [FK_formula_nested_formula_editor1]

GO
/****** Object:  Table [dbo].[formula_nested]    Script Date: 12/18/2008 14:59:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[formula_nested]') AND type in (N'U'))
DROP TABLE [dbo].[formula_nested]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[formula_nested](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sequence_order] [int] NULL,
	[description1] [varchar](200) NULL,
	[description2] [varchar](200) NULL,
	[formula_id] [int] NULL,
	[formula_group_id] [int] NULL,
	[granularity] [int] NULL,
	[include_item] [char](1) NULL,
	[show_value_id] [int] NULL,
	[uom_id] [int] NULL,
	[rate_id] [int] NULL,
	[total_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_formula_nested] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF