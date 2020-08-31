/****** Object:  Table [dbo].[search_meta_data]    Script Date: 12/07/2011 09:27:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[search_meta_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[search_meta_data](
	[ID] [int] NOT NULL,
	[tableName] [varchar](150) NULL,
	[columnName] [varchar](150) NULL,
	[displayColumns] [varchar](8000) NULL,
	[table_display_name] [varchar](100) NULL,
	[column_display_name] [varchar](50) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[master_deal_view]    Script Date: 12/07/2011 09:27:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[master_deal_view]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[master_deal_view](
	[master_deal_id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[source_system_id] [int] NOT NULL,
	[deal_id] [varchar](50) NOT NULL,
	[deal_date] [datetime] NOT NULL,
	[ext_deal_id] [varchar](50) NULL,
	[physical_financial] [varchar](9) NOT NULL,
	[structured_deal_id] [varchar](50) NULL,
	[counterparty] [varchar](100) NULL,
	[parent_counterparty] [varchar](100) NULL,
	[entire_term_start] [datetime] NOT NULL,
	[entire_term_end] [datetime] NOT NULL,
	[deal_type] [varchar](50) NULL,
	[deal_sub_type] [varchar](50) NULL,
	[option_flag] [varchar](100) NULL,
	[option_type] [varchar](100) NULL,
	[option_excercise_type] [varchar](100) NULL,
	[source_system_book_id1] [varchar](50) NULL,
	[source_system_book_id2] [varchar](50) NULL,
	[source_system_book_id3] [varchar](50) NULL,
	[source_system_book_id4] [varchar](50) NULL,
	[subsidiary] [varchar](100) NULL,
	[strategy] [varchar](100) NULL,
	[Book] [varchar](100) NULL,
	[description1] [varchar](100) NULL,
	[description2] [varchar](50) NULL,
	[description3] [varchar](50) NULL,
	[deal_category] [varchar](500) NULL,
	[trader] [varchar](100) NULL,
	[internal_deal_type] [varchar](50) NULL,
	[internal_deal_subtype] [varchar](50) NULL,
	[template] [varchar](250) NULL,
	[broker] [varchar](100) NULL,
	[generator] [varchar](250) NULL,
	[deal_status_date] [datetime] NULL,
	[assignment_type] [varchar](500) NULL,
	[compliance_year] [int] NULL,
	[state_value] [varchar](500) NULL,
	[assigned_date] [datetime] NULL,
	[assigned_user] [varchar](50) NULL,
	[contract] [varchar](50) NULL,
	[create_user] [varchar](151) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](151) NULL,
	[update_ts] [datetime] NULL,
	[legal_entity] [varchar](500) NULL,
	[deal_profile] [varchar](500) NULL,
	[fixation_type] [varchar](500) NULL,
	[internal_portfolio] [varchar](500) NULL,
	[commodity] [varchar](100) NULL,
	[reference] [varchar](250) NULL,
	[locked_deal] [char](1) NULL,
	[close_reference_id] [int] NULL,
	[block_type] [varchar](500) NULL,
	[block_definition] [varchar](500) NULL,
	[granularity] [varchar](500) NULL,
	[pricing] [varchar](500) NULL,
	[deal_reference_type] [int] NULL,
	[deal_status] [varchar](500) NULL,
	[confirm_status_type] [varchar](500) NULL,
	[term_start] [datetime] NULL,
	[term_end] [datetime] NULL,
	[contract_expiration_date] [datetime] NULL,
	[fixed_float] [varchar](5) NOT NULL,
	[buy_sell] [varchar](4) NOT NULL,
	[index_name] [varchar](100) NULL,
	[index_commodity] [varchar](100) NULL,
	[index_currency] [varchar](100) NULL,
	[index_uom] [varchar](100) NULL,
	[index_proxy1] [varchar](100) NULL,
	[index_proxy2] [varchar](100) NULL,
	[index_proxy3] [varchar](100) NULL,
	[index_settlement] [varchar](100) NULL,
	[expiration_calendar] [varchar](500) NULL,
	[deal_formula] [varchar](8000) NULL,
	[location] [varchar](100) NULL,
	[location_region] [varchar](500) NULL,
	[location_grid] [varchar](500) NULL,
	[location_country] [varchar](500) NULL,
	[location_group] [varchar](100) NULL,
	[forecast_profile] [varchar](50) NULL,
	[forecast_proxy_profile] [varchar](50) NULL,
	[profile_type] [varchar](500) NULL,
	[proxy_profile_type] [varchar](500) NULL,
	[meter] [varchar](100) NULL,
	[profile_code] [varchar](500) NULL,
	[Pr_party] [varchar](500) NULL,
 CONSTRAINT [PK_master_deal_view] PRIMARY KEY CLUSTERED 
(
	[master_deal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO




