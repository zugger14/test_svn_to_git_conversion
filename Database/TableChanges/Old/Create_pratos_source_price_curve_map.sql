 
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
/****** Object:  Table [dbo].[pratos_source_price_curve_map]    Script Date: 08/17/2011 23:16:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_source_price_curve_map]
GO
/****** Object:  Table [dbo].[pratos_book_mapping]    Script Date: 08/17/2011 23:16:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_book_mapping]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_book_mapping]
GO
/****** Object:  Table [dbo].[pratos_book_mapping]    Script Date: 08/17/2011 23:16:22 ******/
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
SET IDENTITY_INSERT [dbo].[pratos_book_mapping] ON
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (1, N'Essent B2B', N'NL', N'GtS', N'GGV', 38, -2, -3, -4)
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (2, N'Essent B2B', N'NL', N'GtS', N'GXX', 38, -2, -3, -4)
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (3, N'Essent Retail', N'NL', N'GtS', N'G1', 38, -2, -3, -4)
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (4, N'Westland Energie', N'NL', N'GtS', N'GXX', 38, -2, -3, -4)
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (5, N'Essent Belgium', N'BE', N'Fluxys H', N'AMRg', 38, -2, -3, -4)
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (6, N'Westland Energie', N'NL', N'GtS', N'GGV', 38, -2, -3, -4)
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (7, N'Essent B2B', N'NL', N'TenneT', N'TM', 38, -2, -3, -4)
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (8, N'Essent Belgium', N'BE', N'Elia', N'S11', 38, -2, -3, -4)
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (9, N'Essent Belgium', N'BE', N'Elia', N'S12', 38, -2, -3, -4)
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (10, N'Essent B2B', N'NL', N'TenneT', N'E3A', 38, -2, -3, -4)
SET IDENTITY_INSERT [dbo].[pratos_book_mapping] OFF
/****** Object:  Table [dbo].[pratos_source_price_curve_map]    Script Date: 08/17/2011 23:16:22 ******/
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
SET IDENTITY_INSERT [dbo].[pratos_source_price_curve_map] ON
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1, N'Profile Exit', N'GtS Metered', N'GtS', N'Onpeak', 76, N'Systrmtrackert', CAST(0x00009F42013674F6 AS DateTime), NULL, NULL)
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2, N'Profile Exit', N'Gts Profiled', N'GtS', N'Onpeak', 76, N'Systrmtrackert', CAST(0x00009F4201367508 AS DateTime), NULL, NULL)
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3, N'Profile Exit', N'GtS Metered', N'GtS', N'Offpeak', 76, N'Systrmtrackert', CAST(0x00009F4201367519 AS DateTime), NULL, NULL)
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (4, N'Profile Exit', N'Gts Profiled', N'GtS', N'Offpeak', 76, N'Systrmtrackert', CAST(0x00009F4201367526 AS DateTime), NULL, NULL)
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (5, N'541454827090000186', NULL, N'Fluxys H', N'Baseload', 97, N'Systrmtrackert', CAST(0x00009F4201367532 AS DateTime), N'Systrmtrackert', CAST(0x00009F4201367A80 AS DateTime))
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (6, N'871718518003002214', N'GtS Metered', N'GtS', N'Baseload', 5, N'Systrmtrackert', CAST(0x00009F420136753F AS DateTime), N'Systrmtrackert', CAST(0x00009F4201444396 AS DateTime))
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (7, N'871718518003002214', N'Gts Profiled', N'GtS', N'Baseload', 5, N'Systrmtrackert', CAST(0x00009F420136754C AS DateTime), N'Systrmtrackert', CAST(0x00009F420144574F AS DateTime))
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (8, N'871718518003005857', NULL, N'GtS', N'Baseload', 5, N'Systrmtrackert', CAST(0x00009F420136755F AS DateTime), N'Systrmtrackert', CAST(0x00009F4201367DC6 AS DateTime))
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (9, N'871718518003006694', NULL, N'GtS', N'Baseload', 5, N'Systrmtrackert', CAST(0x00009F420136756A AS DateTime), N'Systrmtrackert', CAST(0x00009F4201368083 AS DateTime))
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (10, NULL, N'Normal', N'Elia', N'Baseload', 77, N'Systrmtrackert', CAST(0x00009F4201367575 AS DateTime), N'Systrmtrackert', CAST(0x00009F4201368250 AS DateTime))
INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (11, NULL, N'Normal', N'TenneT', N'Baseload', 76, N'Systrmtrackert', CAST(0x00009F4201367581 AS DateTime), N'Systrmtrackert', CAST(0x00009F420136872C AS DateTime))
SET IDENTITY_INSERT [dbo].[pratos_source_price_curve_map] OFF
/****** Object:  Default [DF_source_price_curve_map_create_user]    Script Date: 08/17/2011 23:16:22 ******/
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_source_price_curve_map_create_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_source_price_curve_map_create_user]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[pratos_source_price_curve_map] ADD  CONSTRAINT [DF_source_price_curve_map_create_user]  DEFAULT ([dbo].[FNADBUser]()) FOR [create_user]
END


End
GO
/****** Object:  Default [DF_source_price_curve_map_create_ts]    Script Date: 08/17/2011 23:16:22 ******/
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_source_price_curve_map_create_ts]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_source_price_curve_map_create_ts]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[pratos_source_price_curve_map] ADD  CONSTRAINT [DF_source_price_curve_map_create_ts]  DEFAULT (getdate()) FOR [create_ts]
END


End
GO
