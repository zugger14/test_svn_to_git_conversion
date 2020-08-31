-- ===============================================================================================================
-- Create date:2012-03-01
-- Description:	This script will rename existing source_price_curve table to Source_price_curve_non_part.
--  It will then create partitioned table and insert data from non_partitioned table
-- ===============================================================================================================

/****** Object:  Table [dbo].[source_price_curve]    Script Date: 02/10/2012 11:08:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
SP_RENAME source_price_curve , source_price_curve_non_part
CREATE TABLE [dbo].[source_price_curve](
	[source_curve_def_id]				INT NOT NULL,
	[as_of_date]						DATETIME NOT NULL,
	[Assessment_curve_type_value_id]	INT NOT NULL,
	[curve_source_value_id]				INT NOT NULL,
	[maturity_date]						DATETIME NOT NULL,
	[curve_value]						FLOAT NOT NULL,
	[create_user]						VARCHAR (50) NULL,
	[create_ts]							DATETIME NULL,
	[update_user]						VARCHAR (50) NULL,
	[update_ts]							DATETIME NULL,
	[bid_value]							FLOAT NULL,
	[ask_value]							FLOAT NULL,
	[is_dst]							INT NOT NULL
) ON ps_price_curve(as_of_date)
GO

INSERT INTO source_price_curve SELECT * FROM source_price_curve_non_part 

SET ANSI_PADDING OFF
GO


---- For cached curve 


/****** Object:  Table [dbo].[cached_curves_value]    Script Date: 06/15/2012 17:44:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
SP_RENAME cached_curves_value , cached_curves_value_non_part
CREATE TABLE [dbo].[cached_curves_value](
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
) ON ps_cached_curve(as_of_date)

GO
INSERT INTO cached_curves_value SELECT * FROM cached_curves_value_non_part 

SET ANSI_PADDING OFF
GO


