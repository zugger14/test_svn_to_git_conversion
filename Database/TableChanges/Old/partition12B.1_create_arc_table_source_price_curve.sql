---- CREATE SOURCE_PRICE_CURVE_ARCH1

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve_arch1]') AND type in (N'U'))
BEGIN 
CREATE TABLE [dbo].[source_price_curve_arch1](
	[source_curve_def_id]				INT  NOT NULL,
	[as_of_date]						DATETIME NOT NULL,
	[Assessment_curve_type_value_id]	INT  NOT NULL,
	[curve_source_value_id]				INT  NOT NULL,
	[maturity_date]						DATETIME  NOT NULL,
	[curve_value]						FLOAT  NOT NULL,
	[create_user]						VARCHAR (50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]							DATETIME  NULL DEFAULT GETDATE(),
	[update_user]						VARCHAR (50) NULL,
	[update_ts]							DATETIME  NULL,
	[bid_value]							FLOAT  NULL,
	[ask_value]							FLOAT  NULL,
	[is_dst]							FLOAT  NOT NULL DEFAULT 0 
) 
END 
GO
SET ANSI_PADDING OFF
GO


---- CREATE SOURCE_PRICE_CURVE_ARCH2

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve_arch2]') AND type in (N'U'))
BEGIN 
CREATE TABLE [dbo].[source_price_curve_arch2](
	[source_curve_def_id]				INT  NOT NULL,
	[as_of_date]						DATETIME  NOT NULL,
	[Assessment_curve_type_value_id]	INT  NOT NULL,
	[curve_source_value_id]				INT  NOT NULL,
	[maturity_date]						DATETIME  NOT NULL,
	[curve_value]						FLOAT  NOT NULL,
	[create_user]						VARCHAR (50) NULL,
	[create_ts]							DATETIME  NULL,
	[update_user]						VARCHAR (50) NULL DEFAULT dbo.fnadbuser(),
	[update_ts]							DATETIME  NULL DEFAULT GETDATE(),
	[bid_value]							FLOAT  NULL,
	[ask_value]							FLOAT NULL,
	[is_dst]							INT  NOT NULL DEFAULT 0 
) 
 
END 

SET ANSI_PADDING OFF
GO


---- for cached curve_value
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cached_curves_value_arch1]') AND type in (N'U'))

CREATE TABLE [dbo].[cached_curves_value_arch1](
	[Master_ROWID] [int] NULL,
	[value_type] [varchar](1) NULL,
	[term] [datetime] NULL,
	[pricing_option] [tinyint] NULL,
	[curve_value] [float] NULL,
	[org_mid_value] [float] NULL,
	[org_ask_value] [float] NULL,
	[org_bid_value] [float] NULL,
	[org_fx_value] [float] NULL,
	[as_of_date] [datetime] NULL,
	[curve_source_id] [int] NULL,
	[create_ts] [datetime] NULL,
	[bid_ask_curve_value] [float] NULL
)

GO

SET ANSI_PADDING OFF
GO


--- ARCH2
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cached_curves_value_arch2]') AND type in (N'U'))

CREATE TABLE [dbo].[cached_curves_value_arch2](
	[Master_ROWID] [int] NULL,
	[value_type] [varchar](1) NULL,
	[term] [datetime] NULL,
	[pricing_option] [tinyint] NULL,
	[curve_value] [float] NULL,
	[org_mid_value] [float] NULL,
	[org_ask_value] [float] NULL,
	[org_bid_value] [float] NULL,
	[org_fx_value] [float] NULL,
	[as_of_date] [datetime] NULL,
	[curve_source_id] [int] NULL,
	[create_ts] [datetime] NULL,
	[bid_ask_curve_value] [float] NULL
)

GO

SET ANSI_PADDING OFF
GO