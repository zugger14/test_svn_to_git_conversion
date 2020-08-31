SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[source_deal_type_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_deal_type_audit]
    (
    	[audit_id]                 [INT] IDENTITY(1, 1) NOT NULL,
    	[source_deal_type_id]      [int] NOT NULL,
    	[source_system_id]         [int] NOT NULL,
    	[deal_type_id]             [varchar](50) NOT NULL,
    	[source_deal_type_name]    [varchar](50) NOT NULL,
    	[source_deal_desc]         [varchar](50) NULL,
    	[sub_type]                 [varchar](1) NULL,
    	[expiration_applies]       [varchar](1) NULL,
    	[disable_gui_groups]       [varchar](1) NULL,
    	[break_individual_deal]    [varchar](1) NULL,
    	[seperate_rec_value_used]  [varchar](1) NULL,
    	[create_user]              [varchar](50) NULL,
    	[create_ts]                [datetime] NULL,
    	[update_user]              [varchar](50) NULL,
    	[update_ts]                [datetime] NULL,
    	[user_action]              [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table source_deal_type_audit EXISTS'
END

GO

