

/****** Object:  Table [dbo].[credit_exposure_detail]    Script Date: 01/10/2013 14:36:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_pfe_simulation_whatif]') AND type in (N'U'))
DROP TABLE [dbo].[source_deal_pfe_simulation_whatif]
GO

/****** Object:  Table [dbo].[credit_exposure_detail]    Script Date: 01/10/2013 14:36:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[source_deal_pfe_simulation_whatif](
	run_date datetime NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[Netting_Parent_Group_ID] [int] NULL,
	[Netting_Parent_Group_Name] [varchar](100) NULL,
	[Netting_Group_ID] [int] NULL,
	[Netting_Group_Name] [varchar](100) NULL,
	[Netting_Group_Detail_ID] [int] NULL,
	[fas_subsidiary_id] [int] NULL,
	[fas_strategy_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[Source_Deal_Header_ID] [int] NULL,
	[Source_Counterparty_ID] [int] NULL,
	[term_start] [datetime] NULL,
	[agg_term_start] [varchar](20) NULL,
	[Final_Und_Pnl] [float] NULL,
	[Final_Dis_Pnl] [float] NULL,
	[legal_entity] [int] NULL,
	[exp_type_id] [varchar](10) NULL,
	[exp_type] [varchar](20) NULL,
	[gross_exposure] [float] NULL,
	[d_gross_exposure] [float] NULL,
	[invoice_due_date] [datetime] NULL,
	[aged_invoice_days] [float] NULL,
	[netting_counterparty_id] [int] NULL,
	[counterparty_name] [varchar](250) NULL,
	[parent_counterparty_name] [varchar](250) NULL,
	[counterparty_type] [varchar](50) NULL,
	[risk_rating] [varchar](50) NULL,
	[debt_rating] [varchar](50) NULL,
	[industry_type1] [varchar](50) NULL,
	[industry_type2] [varchar](50) NULL,
	[sic_code] [varchar](100) NULL,
	[account_status] [varchar](50) NULL,
	[currency_name] [varchar](50) NULL,
	[watch_list] [varchar](1) NULL,
	[int_ext_flag] [varchar](1) NULL,
	[tenor_limit] [int] NULL,
	[tenor_days] [int] NULL,
	[total_limit_provided] [float] NULL,
	[total_limit_received] [float] NULL,
	[net_exposure_to_us] [float] NULL,
	[net_exposure_to_them] [float] NULL,
	[total_net_exposure] [float] NULL,
	[limit_to_us_avail] [float] NULL,
	[limit_to_them_avail] [float] NULL,
	[limit_to_us_violated] [int] NULL,
	[limit_to_them_violated] [int] NULL,
	[tenor_limit_violated] [int] NULL,
	[limit_to_us_variance] [float] NULL,
	[limit_to_them_variance] [float] NULL,
	[d_net_exposure_to_us] [float] NULL,
	[d_net_exposure_to_them] [float] NULL,
	[d_total_net_exposure] [float] NULL,
	[d_limit_to_us_avail] [float] NULL,
	[d_limit_to_them_avail] [float] NULL,
	[d_limit_to_us_variance] [float] NULL,
	[d_limit_to_them_variance] [float] NULL,
	[risk_rating_id] [int] NULL,
	[debt_rating_id] [int] NULL,
	[industry_type1_id] [int] NULL,
	[industry_type2_id] [int] NULL,
	[sic_code_id] [int] NULL,
	[counterparty_type_id] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


