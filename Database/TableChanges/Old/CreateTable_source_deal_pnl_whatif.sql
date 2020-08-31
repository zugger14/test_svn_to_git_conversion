
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_deal_pnl_whatif_source_currency]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_deal_pnl_whatif]'))
ALTER TABLE [dbo].[source_deal_pnl_whatif] DROP CONSTRAINT [FK_source_deal_pnl_whatif_source_currency]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_deal_pnl_whatif_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_deal_pnl_whatif]'))
ALTER TABLE [dbo].[source_deal_pnl_whatif] DROP CONSTRAINT [FK_source_deal_pnl_whatif_static_data_value]
GO


GO

/****** Object:  Table [dbo].[source_deal_pnl_whatif]    Script Date: 06/11/2011 20:30:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_pnl_whatif]') AND type in (N'U'))
DROP TABLE [dbo].[source_deal_pnl_whatif]
GO

/****** Object:  Table [dbo].[whatif_other]    Script Date: 06/11/2011 20:30:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[whatif_other]') AND type in (N'U'))
DROP TABLE [dbo].[whatif_other]
GO

/****** Object:  Table [dbo].[calc_whatif_scenario]    Script Date: 06/11/2011 20:30:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_whatif_scenario]') AND type in (N'U'))
DROP TABLE [dbo].[calc_whatif_scenario]
GO

/****** Object:  Table [dbo].[whatif_portfolio]    Script Date: 06/11/2011 20:30:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[whatif_portfolio]') AND type in (N'U'))
DROP TABLE [dbo].[whatif_portfolio]
GO

/****** Object:  Table [dbo].[whatif_deal]    Script Date: 06/11/2011 20:30:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[whatif_deal]') AND type in (N'U'))
DROP TABLE [dbo].[whatif_deal]
GO

/****** Object:  Table [dbo].[whatif_scenario_source]    Script Date: 06/11/2011 20:30:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[whatif_scenario_source]') AND type in (N'U'))
DROP TABLE [dbo].[whatif_scenario_source]
GO

/****** Object:  Table [dbo].[maintain_whatif_scenario]    Script Date: 06/11/2011 20:30:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[maintain_whatif_scenario]') AND type in (N'U'))
DROP TABLE [dbo].[maintain_whatif_scenario]
GO



GO

/****** Object:  Table [dbo].[source_deal_pnl_whatif]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[source_deal_pnl_whatif](
	[source_deal_pnl_id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[term_start] [datetime] NOT NULL,
	[term_end] [datetime] NOT NULL,
	[Leg] [int] NOT NULL,
	[pnl_as_of_date] [datetime] NOT NULL,
	[und_pnl] [float] NOT NULL,
	[und_intrinsic_pnl] [float] NOT NULL,
	[und_extrinsic_pnl] [float] NOT NULL,
	[dis_pnl] [float] NOT NULL,
	[dis_intrinsic_pnl] [float] NOT NULL,
	[dis_extrinisic_pnl] [float] NOT NULL,
	[pnl_source_value_id] [int] NOT NULL,
	[pnl_currency_id] [int] NOT NULL,
	[pnl_conversion_factor] [float] NOT NULL,
	[pnl_adjustment_value] [float] NULL,
	[deal_volume] [float] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[und_pnl_set] [float] NULL,
	[MTMC] [float] NULL,
	[MTMI] [float] NULL,
	[maintain_incremental_scenario_other_id] [int] NULL,
	[whatif_other_id] [int] NULL,
	[maintain_incremental_scenario_id] [int] NULL,
	[maintain_whatif_scenario_id] [int] NULL,
	[whatif_scenario_source_id] [int] NULL,
 CONSTRAINT [PK_source_deal_pnl_whatif_1] PRIMARY KEY CLUSTERED 
(
	[source_deal_pnl_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



/****** Object:  Index [IX_source_deal_pnl_whatif_1]    Script Date: 06/11/2011 20:30:18 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_source_deal_pnl_whatif_1] ON [dbo].[source_deal_pnl_whatif] 
(
	[maintain_incremental_scenario_id] ASC,
	[maintain_whatif_scenario_id] ASC,
	[whatif_scenario_source_id] ASC,
	[source_deal_header_id] ASC,
	[whatif_other_id] ASC,
	[maintain_incremental_scenario_other_id] ASC,
	[term_start] ASC,
	[term_end] ASC,
	[Leg] ASC,
	[pnl_as_of_date] ASC,
	[pnl_source_value_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


GO

/****** Object:  Table [dbo].[whatif_other]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[whatif_other](
	[whatif_other_id] [int] IDENTITY(1,1) NOT NULL,
	[maintain_whatif_scenario_id] [int] NULL,
	[curve_id] [int] NULL,
	[uom] [int] NULL,
	[volume] [float] NULL,
	[term] [datetime] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[term_end] [datetime] NULL,
	[curve_id_sell] [int] NULL,
	[uom_sell] [int] NULL,
	[volume_sell] [float] NULL,
	[term_start_sell] [datetime] NULL,
	[term_end_sell] [datetime] NULL,
	[price] [numeric](38, 20) NULL,
	[price_sell] [numeric](38, 20) NULL,
	[counterparty] [int] NULL,
	[buy] [char](1) NULL,
	[sell] [char](1) NULL,
 CONSTRAINT [PK_whatif_other] PRIMARY KEY CLUSTERED 
(
	[whatif_other_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


GO

/****** Object:  Table [dbo].[calc_whatif_scenario]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[calc_whatif_scenario](
	[calc_whatif_id] [int] IDENTITY(1,1) NOT NULL,
	[whatif_scenario_id] [int] NULL,
	[whatif_scenario_source_id] [int] NULL,
	[as_of_date] [datetime] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[term_start] [datetime] NOT NULL,
	[mtm] [float] NULL,
	[var] [float] NULL,
	[currency_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_calc_whatif_scenario] PRIMARY KEY CLUSTERED 
(
	[calc_whatif_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


GO

/****** Object:  Table [dbo].[whatif_portfolio]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[whatif_portfolio](
	[whatif_portfolio_id] [int] IDENTITY(1,1) NOT NULL,
	[maintain_whatif_scenario_id] [int] NULL,
	[portfolio_name] [varchar](50) NULL,
	[portfolio_desc] [varchar](255) NULL,
	[parameter_string] [varchar](1000) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_whatif_portfolio] PRIMARY KEY CLUSTERED 
(
	[whatif_portfolio_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


GO

/****** Object:  Table [dbo].[whatif_deal]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[whatif_deal](
	[whatif_deal_id] [int] IDENTITY(1,1) NOT NULL,
	[maintain_whatif_scenario_id] [int] NULL,
	[deal_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_whatif_deal] PRIMARY KEY CLUSTERED 
(
	[whatif_deal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


GO

/****** Object:  Table [dbo].[whatif_scenario_source]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[whatif_scenario_source](
	[whatif_scenario_source_id] [int] IDENTITY(1,1) NOT NULL,
	[maintain_whatif_scenario_id] [int] NULL,
	[logical_name] [varchar](100) NULL,
	[source] [int] NULL,
	[holding_period] [varchar](100) NULL,
	[confidence_interval] [int] NULL,
	[shift_val] [float] NULL,
	[shift_by] [char](1) NULL,
	[var_type] [char](1) NULL,
	[checkMTM] [char](1) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[calculate] [varchar](20) NULL,
	[price_series] [int] NULL,
	[simulation_days] [int] NULL,
	[no_of_data_points] [int] NULL,
	[netting_group] [int] NULL,
	[measurement_approach] [int] NULL,
 CONSTRAINT [PK_whatif_scenario_source] PRIMARY KEY CLUSTERED 
(
	[whatif_scenario_source_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


GO

/****** Object:  Table [dbo].[maintain_whatif_scenario]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[maintain_whatif_scenario](
	[maintain_whatif_scenario_id] [int] IDENTITY(1,1) NOT NULL,
	[code] [varchar](50) NULL,
	[long_description] [varchar](500) NULL,
	[publicChecked] [char](1) NULL,
	[activeChecked] [char](1) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_maintain_whatif_scenario] PRIMARY KEY CLUSTERED 
(
	[maintain_whatif_scenario_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Trigger [dbo].[TRGINS_whatif_other]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGINS_whatif_other]
ON [dbo].[whatif_other]
FOR INSERT
AS
BEGIN
	UPDATE whatif_other 
	SET create_user =  dbo.FNADBUser(), 
		create_ts = getdate() 
	WHERE  whatif_other.whatif_other_id 
	in (select whatif_other_id from inserted)
END


GO

/****** Object:  Trigger [dbo].[TRGUPD_whatif_other]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGUPD_whatif_other]
ON [dbo].[whatif_other]
FOR UPDATE
AS
BEGIN
	UPDATE whatif_other 
	SET update_user =  dbo.FNADBUser(), 
		update_ts = getdate() 
	WHERE whatif_other.whatif_other_id 
	in (select whatif_other_id  from deleted)
END
GO

/****** Object:  Trigger [dbo].[TRGINS_whatif_portfolio]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGINS_whatif_portfolio]
ON [dbo].[whatif_portfolio]
FOR INSERT
AS
BEGIN
	UPDATE whatif_portfolio 
	SET create_user =  dbo.FNADBUser(), 
		create_ts = getdate() 
	WHERE  whatif_portfolio.whatif_portfolio_id 
	in (select whatif_portfolio_id from inserted)
END


GO

/****** Object:  Trigger [dbo].[TRGUPD_whatif_portfolio]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGUPD_whatif_portfolio]
ON [dbo].[whatif_portfolio]
FOR UPDATE
AS
BEGIN
	UPDATE whatif_portfolio 
	SET update_user =  dbo.FNADBUser(), 
		update_ts = getdate() 
	WHERE whatif_portfolio.whatif_portfolio_id 
	in (select whatif_portfolio_id  from deleted)
END

GO

/****** Object:  Trigger [dbo].[TRGINS_whatif_deal]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGINS_whatif_deal]
ON [dbo].[whatif_deal]
FOR INSERT
AS
BEGIN
	UPDATE whatif_deal 
	SET create_user =  dbo.FNADBUser(), 
		create_ts = getdate() 
	WHERE  whatif_deal.whatif_deal_id 
	in (select whatif_deal_id from inserted)
END


GO

/****** Object:  Trigger [dbo].[TRGUPD_whatif_deal]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGUPD_whatif_deal]
ON [dbo].[whatif_deal]
FOR UPDATE
AS
BEGIN
	UPDATE whatif_deal 
	SET update_user =  dbo.FNADBUser(), 
		update_ts = getdate() 
	WHERE whatif_deal.whatif_deal_id 
	in (select whatif_deal_id  from deleted)
END
---------------------------------------------------END--------------------------------

GO

/****** Object:  Trigger [dbo].[TRGINS_whatif_scenario_source]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGINS_whatif_scenario_source]
ON [dbo].[whatif_scenario_source]
FOR INSERT
AS
BEGIN
	UPDATE whatif_scenario_source 
	SET create_user =  dbo.FNADBUser(), 
		create_ts = getdate() 
	WHERE  whatif_scenario_source.whatif_scenario_source_id 
	in (select whatif_scenario_source_id from inserted)
END


GO

/****** Object:  Trigger [dbo].[TRGUPD_whatif_scenario_source]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGUPD_whatif_scenario_source]
ON [dbo].[whatif_scenario_source]
FOR UPDATE
AS
BEGIN
	UPDATE whatif_scenario_source 
	SET update_user =  dbo.FNADBUser(), 
		update_ts = getdate() 
	WHERE whatif_scenario_source.whatif_scenario_source_id 
	in (select whatif_scenario_source_id  from deleted)
END

--------------------------------------------END-----------------------------------------

GO

/****** Object:  Trigger [dbo].[TRGINS_maintain_whatif_scenario]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGINS_maintain_whatif_scenario]
ON [dbo].[maintain_whatif_scenario]
FOR INSERT
AS
BEGIN
	UPDATE maintain_whatif_scenario 
	SET create_user =  dbo.FNADBUser(), 
		create_ts = getdate() 
	WHERE  maintain_whatif_scenario.maintain_whatif_scenario_id 
	in (select maintain_whatif_scenario_id from inserted)
END


GO

/****** Object:  Trigger [dbo].[TRGUPD_maintain_whatif_scenario]    Script Date: 06/11/2011 20:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGUPD_maintain_whatif_scenario]
ON [dbo].[maintain_whatif_scenario]
FOR UPDATE
AS
BEGIN
	UPDATE maintain_whatif_scenario 
	SET update_user =  dbo.FNADBUser(), 
		update_ts = getdate() 
	WHERE maintain_whatif_scenario.maintain_whatif_scenario_id 
	in (select maintain_whatif_scenario_id  from deleted)
END

---------------------------------END------------------------------------------

GO

ALTER TABLE [dbo].[source_deal_pnl_whatif]  WITH NOCHECK ADD  CONSTRAINT [FK_source_deal_pnl_whatif_source_currency] FOREIGN KEY([pnl_currency_id])
REFERENCES [dbo].[source_currency] ([source_currency_id])
GO

ALTER TABLE [dbo].[source_deal_pnl_whatif] CHECK CONSTRAINT [FK_source_deal_pnl_whatif_source_currency]
GO

ALTER TABLE [dbo].[source_deal_pnl_whatif]  WITH NOCHECK ADD  CONSTRAINT [FK_source_deal_pnl_whatif_static_data_value] FOREIGN KEY([pnl_source_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO

ALTER TABLE [dbo].[source_deal_pnl_whatif] CHECK CONSTRAINT [FK_source_deal_pnl_whatif_static_data_value]
GO


ALTER TABLE [var_measurement_criteria_detail] ADD  [measure] [int] NULL,	[parent_netting_group] [int] NULL,	[incremental_scenario_id] [int] NULL

GO
 
GO

/****** Object:  Table [dbo].[risks_criteria_detail]    Script Date: 06/11/2011 21:16:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[risks_criteria_detail]') AND type in (N'U'))
DROP TABLE [dbo].[risks_criteria_detail]
GO

/****** Object:  Table [dbo].[risks_criteria_detail_counterparty]    Script Date: 06/11/2011 21:16:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[risks_criteria_detail_counterparty]') AND type in (N'U'))
DROP TABLE [dbo].[risks_criteria_detail_counterparty]
GO




/****** Object:  Table [dbo].[risks_criteria_detail]    Script Date: 06/11/2011 21:16:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[risks_criteria_detail](
	[risks_criteria_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[whatif_scenario_source_id] [int] NULL,
	[measure] [int] NULL,
	[measurement_approach] [int] NULL,
	[confidence_interval] [int] NULL,
	[holding_period] [int] NULL,
	[parent_netting_group] [int] NULL,
	[at_risk_criteria] [int] NULL
) ON [PRIMARY]

GO

 
GO

/****** Object:  Table [dbo].[risks_criteria_detail_counterparty]    Script Date: 06/11/2011 21:16:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[risks_criteria_detail_counterparty](
	[risks_criteria_detail_id] [int] NOT NULL,
	[source_counterparty_id] [int] NOT NULL
) ON [PRIMARY]

GO


