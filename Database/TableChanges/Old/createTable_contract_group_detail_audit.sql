SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[contract_group_detail_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[contract_group_detail_audit]
    (
    	[audit_id]                 [INT] IDENTITY(1, 1) NOT NULL,
    	[ID]                       [int] NOT NULL,
    	[contract_id]              [int] NOT NULL,
    	[invoice_line_item_id]     [int] NULL,
    	[default_gl_id]            [int] NULL,
    	[price]                    [float] NULL,
    	[formula_id]               [int] NULL,
    	[manual]                   [char](1) NULL,
    	[currency]                 [int] NULL,
    	[Prod_type]                [char](1) NULL,
    	[sequence_order]           [int] NULL,
    	[create_user]              [varchar](50) NULL,
    	[create_ts]                [datetime] NULL,
    	[update_user]              [varchar](50) NULL,
    	[update_ts]                [datetime] NULL,
    	[inventory_item]           [char](1) NULL,
    	[class_name]               [varchar](100) NULL,
    	[increment_peaking_name]   [varchar](150) NULL,
    	[product_type_name]        [varchar](150) NULL,
    	[rate_description]         [varchar](150) NULL,
    	[units_for_rate]           [varchar](50) NULL,
    	[begin_date]               [datetime] NULL,
    	[end_date]                 [datetime] NULL,
    	[default_gl_id_estimates]  [int] NULL,
    	[eqr_product_name]         [int] NULL,
    	[group_by]                 [int] NULL,
    	[alias]                    [varchar](100) NULL,
    	[hideInInvoice]            [varchar](1) NULL,
    	[int_begin_month]          [int] NULL,
    	[int_end_month]            [int] NULL,
    	[volume_granularity]       [int] NULL,
    	[deal_type]                [int] NULL,
    	[time_bucket_formula_id]   [int] NULL,
    	[calc_aggregation]         [int] NULL,
    	[payment_date]             [int] NULL,
    	[payment_calendar]         [int] NULL,
    	[pnl_date]                 [int] NULL,
    	[pnl_calendar]             [int] NULL,
    	[timeofuse]                [int] NULL,
    	[include_charges]          [char](1) NULL,
    	[user_action]              [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table contract_group_detail_audit EXISTS'
END

GO

