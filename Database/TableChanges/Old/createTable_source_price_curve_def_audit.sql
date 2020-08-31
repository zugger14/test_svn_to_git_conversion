SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[source_price_curve_def_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_price_curve_def_audit]
    (
    	[audit_id]                        [INT] IDENTITY(1, 1) NOT NULL,
    	[source_curve_def_id]             [INT] NOT NULL,
    	[source_system_id]                [INT] NOT NULL,
    	[curve_id]                        [VARCHAR](100) NULL,
    	[curve_name]                      [VARCHAR](100) NOT NULL,
    	[curve_des]                       [VARCHAR](250) NULL,
    	[commodity_id]                    [INT] NOT NULL,
    	[market_value_id]                 [VARCHAR](50) NOT NULL,
    	[market_value_desc]               [VARCHAR](50) NULL,
    	[source_currency_id]              [INT] NOT NULL,
    	[source_currency_to_id]           [INT] NULL,
    	[source_curve_type_value_id]      [INT] NOT NULL,
    	[uom_id]                          [INT] NOT NULL,
    	[proxy_source_curve_def_id]       [INT] NULL,
    	[formula_id]                      [INT] NULL,
    	[obligation]                      [VARCHAR](50) NULL,
    	[sort_order]                      [INT] NULL,
    	[fv_level]                        [INT] NULL,
    	[create_user]                     [VARCHAR](50) NULL,
    	[create_ts]                       [DATETIME] NULL,
    	[update_user]                     [VARCHAR](50) NULL,
    	[update_ts]                       [DATETIME] NULL,
    	[Granularity]                     [INT] NULL,
    	[exp_calendar_id]                 [INT] NULL,
    	[risk_bucket_id]                  [INT] NULL,
    	[reference_curve_id]              [INT] NULL,
    	[monthly_index]                   [INT] NULL,
    	[program_scope_value_id]          [INT] NULL,
    	[curve_definition]                [VARCHAR](MAX) NULL,
    	[block_type]                      [INT] NULL,
    	[block_define_id]                 [INT] NULL,
    	[index_group]                     [INT] NULL,
    	[display_uom_id]                  [INT] NULL,
    	[proxy_curve_id]                  [INT] NULL,
    	[hourly_volume_allocation]        [INT] NULL,
    	[settlement_curve_id]             [INT] NULL,
    	[time_zone]                       [INT] NULL,
    	[udf_block_group_id]              [INT] NULL,
    	[is_active]                       [CHAR](1) NULL,
    	[ratio_option]                    [INT] NULL,
    	[curve_tou]                       [INT] NULL,
    	[proxy_curve_id3]                 [INT] NULL,
    	[asofdate_current_month]          [CHAR](1) NULL,
    	[monte_carlo_model_parameter_id]  [INT] NULL,
    	[user_action]                     [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table source_price_curve_def_audit EXISTS'
END

GO

