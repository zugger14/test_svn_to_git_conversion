
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_source_price_curve_map_create_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_source_price_curve_map_create_user]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[pratos_source_price_curve_map] DROP CONSTRAINT [DF_source_price_curve_map_create_user]
END


End
GO
IF  EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_source_price_curve_map_create_ts]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
Begin
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_source_price_curve_map_create_ts]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[pratos_source_price_curve_map] DROP CONSTRAINT [DF_source_price_curve_map_create_ts]
END


End
GO
/****** Object:  Table [dbo].[pratos_source_price_curve_map]    Script Date: 09/26/2011 21:50:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_source_price_curve_map]
GO
/****** Object:  Table [dbo].[pratos_book_mapping]    Script Date: 09/26/2011 21:50:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_book_mapping]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_book_mapping]
GO
/****** Object:  Table [dbo].[pratos_formula_mapping]    Script Date: 09/26/2011 21:50:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_formula_mapping]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_formula_mapping]
GO
/****** Object:  Table [dbo].[pratos_formula_mapping]    Script Date: 09/26/2011 21:50:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_formula_mapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pratos_formula_mapping](
	id INT PRIMARY KEY IDENTITY (1, 1),
	source_formula VARCHAR(500) UNIQUE,
	[curve_id] [int] NULL,
	[relative_year] [int] NULL,
	[strip_month_from] [int] NULL,
	[lag_month] [int] NULL,
	[strip_month_to] [int] NULL,
	[currency_id] [int] NULL,
	[price_adder] [float] NULL,
	[exp_type] [varchar](20) NULL,
	[exp_value] [varchar](50) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[pratos_formula_mapping] ADD [curve_type] [varchar](100) NULL
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[pratos_book_mapping]    Script Date: 09/26/2011 21:50:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_book_mapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pratos_book_mapping](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[counterparty_id] [varchar](100) NULL,
	[country_id] [varchar](100) NULL,
	[grid_id] [varchar](100) NULL,
	[category] [varchar](100) NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
 CONSTRAINT [PK_pratos_book_mapping] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[pratos_source_price_curve_map]    Script Date: 09/26/2011 21:50:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pratos_source_price_curve_map](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[location_group_id] [varchar](100) NULL,
	[region] [varchar](100) NULL,
	[grid_value_id] [varchar](100) NULL,
	[block_type] [varchar](20) NULL,
	[curve_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_source_price_curve_map] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]') AND name = N'IX_pratos_source_price_curve_map')
CREATE NONCLUSTERED INDEX [IX_pratos_source_price_curve_map] ON [dbo].[pratos_source_price_curve_map] 
(
	[curve_id] ASC,
	[grid_value_id] ASC,
	[location_group_id] ASC,
	[region] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Default [DF_source_price_curve_map_create_user]    Script Date: 09/26/2011 21:50:35 ******/
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_source_price_curve_map_create_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_source_price_curve_map_create_user]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[pratos_source_price_curve_map] ADD  CONSTRAINT [DF_source_price_curve_map_create_user]  DEFAULT ([dbo].[FNADBUser]()) FOR [create_user]
END


End
GO
/****** Object:  Default [DF_source_price_curve_map_create_ts]    Script Date: 09/26/2011 21:50:35 ******/
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_source_price_curve_map_create_ts]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_source_price_curve_map_create_ts]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[pratos_source_price_curve_map] ADD  CONSTRAINT [DF_source_price_curve_map_create_ts]  DEFAULT (getdate()) FOR [create_ts]
END


End
GO
