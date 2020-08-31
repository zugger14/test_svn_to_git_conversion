
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_source_major_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_map]'))
ALTER TABLE [dbo].[source_price_curve_map] DROP CONSTRAINT [FK_source_price_curve_map_source_major_location]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_source_price_curve_def]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_map]'))
ALTER TABLE [dbo].[source_price_curve_map] DROP CONSTRAINT [FK_source_price_curve_map_source_price_curve_def]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_map]'))
ALTER TABLE [dbo].[source_price_curve_map] DROP CONSTRAINT [FK_source_price_curve_map_static_data_value]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_static_data_value1]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_map]'))
ALTER TABLE [dbo].[source_price_curve_map] DROP CONSTRAINT [FK_source_price_curve_map_static_data_value1]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_static_data_value2]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_map]'))
ALTER TABLE [dbo].[source_price_curve_map] DROP CONSTRAINT [FK_source_price_curve_map_static_data_value2]
GO

--IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_source_price_curve_map_create_user]') AND type = 'D')
--BEGIN
--ALTER TABLE [dbo].[source_price_curve_map] DROP CONSTRAINT [DF_source_price_curve_map_create_user]
--END

--GO

--IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_source_price_curve_map_create_ts]') AND type = 'D')
--BEGIN
--ALTER TABLE [dbo].[source_price_curve_map] DROP CONSTRAINT [DF_source_price_curve_map_create_ts]
--END

GO

/****** Object:  Table [dbo].[pratos_stage_udf]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve_map]') AND type in (N'U'))
DROP TABLE [dbo].[source_price_curve_map]
GO


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
/****** Object:  ForeignKey [FK_pratos_source_price_curve_map_source_major_location]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_pratos_source_price_curve_map_source_major_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map] DROP CONSTRAINT [FK_pratos_source_price_curve_map_source_major_location]
GO
/****** Object:  ForeignKey [FK_pratos_source_price_curve_map_static_data_value]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_pratos_source_price_curve_map_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map] DROP CONSTRAINT [FK_pratos_source_price_curve_map_static_data_value]
GO
/****** Object:  ForeignKey [FK_source_price_curve_map_source_price_curve_def]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_source_price_curve_def]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map] DROP CONSTRAINT [FK_source_price_curve_map_source_price_curve_def]
GO
/****** Object:  ForeignKey [FK_source_price_curve_map_static_data_value]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map] DROP CONSTRAINT [FK_source_price_curve_map_static_data_value]
GO
/****** Object:  Table [dbo].[pratos_book_mapping]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_book_mapping]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_book_mapping]
GO
/****** Object:  Table [dbo].[pratos_formula_mapping]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_formula_mapping]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_formula_mapping]
GO
/****** Object:  Table [dbo].[pratos_source_price_curve_map]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_source_price_curve_map]
GO
/****** Object:  Table [dbo].[pratos_stage_deal_detail]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_deal_detail]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_stage_deal_detail]
GO
/****** Object:  Table [dbo].[pratos_stage_deal_header]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_deal_header]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_stage_deal_header]
GO
/****** Object:  Table [dbo].[pratos_stage_formula]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_formula]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_stage_formula]
GO
/****** Object:  Table [dbo].[pratos_stage_udf]    Script Date: 08/11/2011 17:12:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_udf]') AND type in (N'U'))
DROP TABLE [dbo].[pratos_stage_udf]
GO
/****** Object:  Table [dbo].[pratos_stage_udf]    Script Date: 08/11/2011 17:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_udf]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pratos_stage_udf](
	[source_system_id] [int] NULL,
	[source_deal_id] [varchar](50) NULL,
	[field] [varchar](500) NULL,
	[value] [varchar](8000) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[pratos_stage_formula]    Script Date: 08/11/2011 17:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_formula]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pratos_stage_formula](
	[row_id] [int] NULL,
	[source_system_id] [int] NULL,
	[source_deal_id] [varchar](50) NULL,
	[term_start] [varchar](20) NULL,
	[term_end] [varchar](20) NULL,
	[leg] [varchar](50) NULL,
	[formula] [varchar](500) NULL,
	[value] [float] NULL,
	[tariff] [varchar](100) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[pratos_stage_deal_header]    Script Date: 08/11/2011 17:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_deal_header]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pratos_stage_deal_header](
	[source_system_id] [int] NULL,
	[source_deal_id] [varchar](50) NULL,
	[block_type] [varchar](100) NULL,
	[block_description] [varchar](100) NULL,
	[description] [varchar](100) NULL,
	[deal_date] [varchar](20) NULL,
	[counterparty] [varchar](50) NULL,
	[deal_type] [varchar](50) NULL,
	[deal_sub_type] [varchar](50) NULL,
	[option_flag] [char](1) NULL,
	[source_book_id1] [varchar](50) NULL,
	[source_book_id2] [varchar](50) NULL,
	[source_book_id3] [varchar](50) NULL,
	[source_book_id4] [varchar](50) NULL,
	[description1] [varchar](100) NULL,
	[description2] [varchar](50) NULL,
	[description3] [varchar](50) NULL,
	[deal_category_id] [varchar](50) NULL,
	[trader_name] [varchar](50) NULL,
	[header_buy_sell_flag] [char](1) NULL,
	[broker_name] [varchar](50) NULL,
	[framework] [varchar](50) NULL,
	[legal_entity] [varchar](50) NULL,
	[template] [varchar](50) NULL,
	[deal_status] [varchar](50) NULL,
	[profile] [varchar](50) NULL,
	[fixing] [varchar](50) NULL,
	[confirm_status] [varchar](50) NULL,
	[reference_deal] [varchar](50) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[pratos_stage_deal_detail]    Script Date: 08/11/2011 17:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_deal_detail]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pratos_stage_deal_detail](
	[source_system_id] [int] NULL,
	[source_deal_id] [varchar](50) NULL,
	[term_start] [varchar](20) NULL,
	[term_end] [varchar](20) NULL,
	[leg] [varchar](50) NULL,
	[expiration_date] [varchar](20) NULL,
	[fixed_float_leg] [char](1) NULL,
	[buy_sell] [char](1) NULL,
	[source_curve] [varchar](50) NULL,
	[fixed_price] [numeric](38, 20) NULL,
	[deal_volume] [numeric](38, 20) NULL,
	[volume_frequency] [char](1) NULL,
	[volume_uom] [varchar](50) NULL,
	[physical_financial_flag] [char](1) NULL,
	[location] [varchar](50) NULL,
	[capacity] [numeric](38, 20) NULL,
	[fixed_cost] [numeric](38, 20) NULL,
	[fixed_cost_currency] [varchar](50) NULL,
	[formula_currency] [varchar](50) NULL,
	[adder_currency] [varchar](50) NULL,
	[price_currency] [varchar](50) NULL,
	[meter] [varchar](50) NULL,
	[syv] [float] NULL,
	[postal_code] [varchar](8) NULL,
	[province] [varchar](100) NULL,
	[physical_shipper] [varchar](50) NULL,
	[sicc_code] [varchar](50) NULL,
	[profile_code] [varchar](50) NULL,
	[nominatorsapcode] [varchar](50) NULL,
	[forecast_needed] [char](1) NULL,
	[forecasting_group] [varchar](50) NULL,
	[external_profile] [varchar](50) NULL,
	[calculation_method] [char](1) NULL,
	[country] [char](2) NULL,
	[region] [varchar](50) NULL,
	[grid] [varchar](50) NULL,
	[location_group] [varchar](20) NULL,
	[tou_tariff] [varchar](100) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[pratos_source_price_curve_map]    Script Date: 08/11/2011 17:12:50 ******/
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
	[location_group_id] [int] NULL,
	[region] [int] NULL,
	[grid_value_id] [int] NULL,
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
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_source_price_curve_map]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[TRGUPD_source_price_curve_map]
ON [dbo].[pratos_source_price_curve_map]
FOR UPDATE
AS
    UPDATE pratos_source_price_curve_map
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pratos_source_price_curve_map t
      INNER JOIN DELETED u ON t.id = u.id
'
GO
/****** Object:  Table [dbo].[pratos_formula_mapping]    Script Date: 08/11/2011 17:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_formula_mapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pratos_formula_mapping](
	[source_formula] [varchar](500) NULL,
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_book_mapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pratos_book_mapping](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[counterparty_id] [int] NOT NULL,
	[country_id] [int] NOT NULL,
	[grid_id] [int] NOT NULL,
	[category] [varchar](100) NULL,
	[source_system_book_id1] [int] NOT NULL,
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
INSERT [dbo].[pratos_book_mapping] ([id], [counterparty_id], [country_id], [grid_id], [category], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4]) VALUES (4, 37, 292086, 292033, NULL, 5, -2, -3, -4)
SET IDENTITY_INSERT [dbo].[pratos_book_mapping] OFF
/****** Object:  Default [DF_source_price_curve_map_create_user]    Script Date: 08/11/2011 17:12:50 ******/
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_source_price_curve_map_create_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_source_price_curve_map_create_user]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[pratos_source_price_curve_map] ADD  CONSTRAINT [DF_source_price_curve_map_create_user]  DEFAULT ([dbo].[FNADBUser]()) FOR [create_user]
END


End
GO
/****** Object:  Default [DF_source_price_curve_map_create_ts]    Script Date: 08/11/2011 17:12:50 ******/
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF_source_price_curve_map_create_ts]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_source_price_curve_map_create_ts]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[pratos_source_price_curve_map] ADD  CONSTRAINT [DF_source_price_curve_map_create_ts]  DEFAULT (getdate()) FOR [create_ts]
END


End
GO
/****** Object:  ForeignKey [FK_pratos_source_price_curve_map_source_major_location]    Script Date: 08/11/2011 17:12:50 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_pratos_source_price_curve_map_source_major_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map]  WITH CHECK ADD  CONSTRAINT [FK_pratos_source_price_curve_map_source_major_location] FOREIGN KEY([location_group_id])
REFERENCES [dbo].[source_major_location] ([source_major_location_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_pratos_source_price_curve_map_source_major_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map] CHECK CONSTRAINT [FK_pratos_source_price_curve_map_source_major_location]
GO
/****** Object:  ForeignKey [FK_pratos_source_price_curve_map_static_data_value]    Script Date: 08/11/2011 17:12:50 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_pratos_source_price_curve_map_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map]  WITH CHECK ADD  CONSTRAINT [FK_pratos_source_price_curve_map_static_data_value] FOREIGN KEY([region])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_pratos_source_price_curve_map_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map] CHECK CONSTRAINT [FK_pratos_source_price_curve_map_static_data_value]
GO
/****** Object:  ForeignKey [FK_source_price_curve_map_source_price_curve_def]    Script Date: 08/11/2011 17:12:50 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_source_price_curve_def]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map]  WITH CHECK ADD  CONSTRAINT [FK_source_price_curve_map_source_price_curve_def] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_source_price_curve_def]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map] CHECK CONSTRAINT [FK_source_price_curve_map_source_price_curve_def]
GO
/****** Object:  ForeignKey [FK_source_price_curve_map_static_data_value]    Script Date: 08/11/2011 17:12:50 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map]  WITH CHECK ADD  CONSTRAINT [FK_source_price_curve_map_static_data_value] FOREIGN KEY([grid_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_map_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]'))
ALTER TABLE [dbo].[pratos_source_price_curve_map] CHECK CONSTRAINT [FK_source_price_curve_map_static_data_value]
GO

--SET ANSI_PADDING OFF
--GO
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'NLEndexQ(4dpe03)OnPeak', 133, 0, 0, 0, 1, NULL, 0, N'REBD', N'-4')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'NLEndexQ(4dpe03)OffPeak', 134, 0, 0, 0, 1, NULL, 0, N'REBD', N'-4')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'APXOnPeak', 139, 0, 0, 0, 1, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'APXOffPeak', 138, 0, 0, 0, 1, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'NLEndexM(101)OnPeak', 140, 0, 0, 0, 1, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'NLEndexM(101)OffPeak', 141, 0, 0, 0, 1, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'Gasoil(626)', 92, 0, 6, 2, 6, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'HFO(603)', 94, 0, 6, 0, 3, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'Gasoil(603)', 92, 0, 6, 0, 3, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'TTF(101)', 5, 0, 1, 0, 1, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'Brent(101)', 136, 0, 1, 0, 1, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'Brent(303)', 136, 0, 3, 0, 3, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'HFO(303)', 94, 0, 3, 0, 3, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'Gasoil(303)', 92, 0, 3, 0, 3, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'HFO(603)', 94, 0, 6, 0, 3, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'Gasoil(603)', 92, 0, 6, 0, 3, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'Gasoil(626)', 92, 0, 6, 2, 6, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'TTFLEBA', 10, 0, 0, 0, 1, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'EndexYear', 148, 0, 0, 0, 1, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'Brent(303)OffPeak', 136, 0, 3, 0, 3, 2, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'APXOffPeak', 138, 0, 0, 0, 1, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'NLEndexQ(303)OffPeak', 134, 0, 3, 0, 3, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'NLEndexY(12012)OffPeak', 134, 0, 12, 0, 12, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'NLEndexY(4dpe012)OffPeak', 134, 0, 0, 0, 1, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'BelPexOffPeak', 82, 0, 0, 0, 1, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'Brent(303)OnPeak', 136, 0, 3, 0, 3, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'NLEndexQ(303)OnPeak', 133, 0, 3, 0, 3, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'NLEndexY(12012)OnPeak', 134, 0, 12, 0, 12, NULL, 0, N'', N'')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'NLEndexY(4dpe012)OnPeak', 134, 0, 0, 0, 1, NULL, 0, N'RDB', N'-4')
--INSERT [dbo].[pratos_formula_mapping] ([source_formula], [curve_id], [relative_year], [strip_month_from], [lag_month], [strip_month_to], [currency_id], [price_adder], [exp_type], [exp_value]) VALUES (N'BelPexOnPeak', 82, 0, 0, 0, 1, NULL, 0, N'', N'')
--/****** Object:  Table [dbo].[pratos_book_mapping]    Script Date: 08/11/2011 17:12:50 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--SET ANSI_PADDING ON
--GO

--SET ANSI_PADDING OFF
--GO
--SET IDENTITY_INSERT [dbo].[pratos_source_price_curve_map] ON
--INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (5, NULL, 292036, 292034, N'Onpeak', 76, N'Systrmtrackert', CAST(0x00009F3C00C1B5F5 AS DateTime), N'Systrmtrackert', CAST(0x00009F3C0107B387 AS DateTime))
--INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (6, NULL, 292036, 292034, N'Offpeak', 76, N'Systrmtrackert', CAST(0x00009F3C00C1BEDE AS DateTime), N'Systrmtrackert', CAST(0x00009F3C0107BAD6 AS DateTime))
--INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (7, NULL, 292035, 292033, N'Onpeak', 77, N'Systrmtrackert', CAST(0x00009F3C00C1C9A9 AS DateTime), N'Systrmtrackert', CAST(0x00009F3C0107C54F AS DateTime))
--INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (8, NULL, 292035, 292033, N'Offpeak', 77, N'Systrmtrackert', CAST(0x00009F3C00C1E36E AS DateTime), N'Systrmtrackert', CAST(0x00009F3C0107C892 AS DateTime))
--INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (9, NULL, 292042, 291990, NULL, 5, N'Systrmtrackert', CAST(0x00009F3C00C1F3A4 AS DateTime), N'Systrmtrackert', CAST(0x00009F3C0107D13A AS DateTime))
--INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (10, NULL, NULL, 291989, NULL, 97, N'Systrmtrackert', CAST(0x00009F3C00C200BA AS DateTime), NULL, NULL)
--INSERT [dbo].[pratos_source_price_curve_map] ([id], [location_group_id], [region], [grid_value_id], [block_type], [curve_id], [create_user], [create_ts], [update_user], [update_ts]) VALUES (11, NULL, 292041, 292045, NULL, 97, N'Systrmtrackert', CAST(0x00009F3C00C20805 AS DateTime), N'Systrmtrackert', CAST(0x00009F3C0107F1CA AS DateTime))
--SET IDENTITY_INSERT [dbo].[pratos_source_price_curve_map] OFF
--/****** Object:  Trigger [TRGUPD_source_price_curve_map]    Script Date: 08/11/2011 17:12:50 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO


-- Table Changes -------------------------------------------------------

IF COL_LENGTH('pratos_stage_deal_header', 'commodity') IS NULL
	ALTER TABLE pratos_stage_deal_header ADD commodity VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_header', 'percentage_fixed_bsld_onpeak') IS NULL
	ALTER TABLE pratos_stage_deal_header ADD percentage_fixed_bsld_onpeak NUMERIC(38,20)
GO

IF COL_LENGTH('pratos_stage_deal_header', 'percentage_fixed_offpeak') IS NULL
	ALTER TABLE pratos_stage_deal_header ADD percentage_fixed_offpeak NUMERIC(38,20)
GO

IF COL_LENGTH('pratos_stage_deal_header', 'broker_name') IS NOT NULL
	ALTER TABLE pratos_stage_deal_header DROP COLUMN broker_name 
GO

IF COL_LENGTH('pratos_stage_deal_header', 'parent_counterparty') IS NULL
	ALTER TABLE pratos_stage_deal_header ADD parent_counterparty VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_header', 'source_deal_id_old') IS NULL
	ALTER TABLE pratos_stage_deal_header ADD source_deal_id_old VARCHAR(50)
GO 

------------------------------------------------------------------------

IF COL_LENGTH('pratos_stage_deal_detail', 'postal_code') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD postal_code VARCHAR(8)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'province') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD province VARCHAR(100)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'physical_shipper') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD physical_shipper VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'sicc_code') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD sicc_code VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'profile_code') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD profile_code VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'nominatorsapcode') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD nominatorsapcode VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'forecast_needed') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD forecast_needed CHAR(1)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'forecasting_group') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD forecasting_group VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'external_profile') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD external_profile VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'calculation_method') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD calculation_method CHAR(1)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'country') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD country CHAR(2)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'region') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD region VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'grid') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD grid VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'location_group') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD location_group VARCHAR(20)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'category') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD category VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'tou_tariff') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD tou_tariff VARCHAR(100)
GO

IF COL_LENGTH('pratos_stage_deal_detail', 'percentage_fixed_bsld_onpeak') IS NOT NULL
	ALTER TABLE pratos_stage_deal_detail DROP COLUMN percentage_fixed_bsld_onpeak 
GO

IF COL_LENGTH('pratos_stage_deal_detail', 'percentage_fixed_offpeak') IS NOT NULL
	ALTER TABLE pratos_stage_deal_detail DROP COLUMN percentage_fixed_offpeak 
GO

IF COL_LENGTH('pratos_stage_formula', 'tariff') IS NULL
	ALTER TABLE pratos_stage_formula ADD tariff VARCHAR(100)
GO

IF COL_LENGTH('pratos_stage_deal_detail', 'volume_multiplier') IS  NULL
	ALTER TABLE pratos_stage_deal_detail ADD volume_multiplier FLOAT
GO

IF COL_LENGTH('pratos_stage_deal_header', 'product') IS  NULL
	ALTER TABLE pratos_stage_deal_header ADD product FLOAT
GO


