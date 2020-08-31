SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[rec_volume_unit_conversion_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[rec_volume_unit_conversion_audit]
    (
    	[audit_id]                       [INT] IDENTITY(1, 1) NOT NULL,
    	[rec_volume_unit_conversion_id]  [int] NOT NULL,
    	[state_value_id]                 [int] NULL,
    	[curve_id]                       [int] NULL,
    	[assignment_type_value_id]       [int] NULL,
    	[from_source_uom_id]             [int] NOT NULL,
    	[to_source_uom_id]               [int] NOT NULL,
    	[conversion_factor]              [float] NOT NULL,
    	[uom_label]                      [varchar](50) NULL,
    	[curve_label]                    [varchar](50) NULL,
    	[create_user]                    [varchar](50) NULL,
    	[create_ts]                      [datetime] NULL,
    	[update_user]                    [varchar](50) NULL,
    	[update_ts]                      [datetime] NULL,
    	[effective_date]                 [datetime] NULL,
    	[source]                         [int] NULL,
    	[to_curve_id]                    [int] NULL,
    	[user_action]                    [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table rec_volume_unit_conversion_audit EXISTS'
END

GO

