
IF OBJECT_ID('[cached_curves_value]') IS NOT NULL
DROP TABLE [cached_curves_value]
GO

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
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


IF OBJECT_ID('cached_curves') IS NOT NULL
DROP TABLE [dbo].[cached_curves]
GO

CREATE TABLE [dbo].[cached_curves](
	[ROWID] [int] IDENTITY(1,1) NOT NULL,
	[curve_id] [int] NULL,
	[strip_month_from] [int] NULL,
	[lag_months] [int] NULL,
	[strip_month_to] [int] NULL,
	[expiration_type] [varchar](30) NULL,
	[expiration_value] [varchar](30) NULL,
	[index_round_value] [int] NULL,
	[fx_round_value] [int] NULL,
	[total_round_value] [int] NULL,
	[fx_curve_id] [int] NULL,
	[operation_type] [varchar](1) NULL,
	[bid_ask_round_value] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO





GO

/****** Object:  Index [unq_cur_indx_cached_curves_value]    Script Date: 07/19/2011 16:49:03 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[cached_curves_value]') AND name = N'unq_cur_indx_cached_curves_value')
DROP INDEX [unq_cur_indx_cached_curves_value] ON [dbo].[cached_curves_value] WITH ( ONLINE = OFF )
GO


/****** Object:  Index [unq_cur_indx_cached_curves_value]    Script Date: 07/19/2011 16:48:54 ******/
CREATE UNIQUE CLUSTERED INDEX [unq_cur_indx_cached_curves_value] ON [dbo].[cached_curves_value] 
(
	[Master_ROWID] ASC,
	[as_of_date] ASC,
	[term] ASC,
	[pricing_option] ASC,
	[curve_source_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO





IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.cached_curves') AND name = N'unq_indx_cached_curves1')
BEGIN
	CREATE UNIQUE INDEX unq_indx_cached_curves1 ON  dbo.cached_curves (curve_id,strip_month_from ,lag_months  ,strip_month_to ,expiration_type,expiration_value ,index_round_value ,fx_round_value ,total_round_value,fx_curve_id ,operation_type,bid_ask_round_value)
   PRINT 'Index unq_indx_cached_curves1 created.'
END
ELSE
BEGIN
	PRINT 'Index unq_indx_cached_curves1 already exists.'
END
GO





