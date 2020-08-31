SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[source_price_curve_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_price_curve_audit]
    (
    	[audit_id]                        [INT] IDENTITY(1, 1) NOT NULL,
    	[source_curve_def_id]             [int] NOT NULL,
    	[as_of_date]                      [datetime] NOT NULL,
    	[Assessment_curve_type_value_id]  [int] NOT NULL,
    	[curve_source_value_id]           [int] NOT NULL,
    	[maturity_date]                   [datetime] NOT NULL,
    	[curve_value]                     [float] NOT NULL,
    	[create_user]                     [varchar](50) NULL,
    	[create_ts]                       [datetime] NULL,
    	[update_user]                     [varchar](50) NULL,
    	[update_ts]                       [datetime] NULL,
    	[bid_value]                       [float] NULL,
    	[ask_value]                       [float] NULL,
    	[is_dst]                          [int] NOT NULL,
    	[user_action]                     [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table source_price_curve_audit EXISTS'
END

GO

