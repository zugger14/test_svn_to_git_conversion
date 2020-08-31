SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[hourly_block_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[hourly_block_audit]
    (
    	[audit_id]          [INT] IDENTITY(1, 1) NOT NULL,
    	[block_value_id]    [INT] NOT NULL,
    	[week_day]          [INT] NOT NULL,
    	[onpeak_offpeak]    [CHAR](1) NOT NULL,
    	[holiday_value_id]  [INT] NULL,
    	[Hr1]               [INT] NULL,
    	[Hr2]               [INT] NULL,
    	[Hr3]               [INT] NULL,
    	[Hr4]               [INT] NULL,
    	[Hr5]               [INT] NULL,
    	[Hr6]               [INT] NULL,
    	[Hr7]               [INT] NULL,
    	[Hr8]               [INT] NULL,
    	[Hr9]               [INT] NULL,
    	[Hr10]              [INT] NULL,
    	[Hr11]              [INT] NULL,
    	[Hr12]              [INT] NULL,
    	[Hr13]              [INT] NULL,
    	[Hr14]              [INT] NULL,
    	[Hr15]              [INT] NULL,
    	[Hr16]              [INT] NULL,
    	[Hr17]              [INT] NULL,
    	[Hr18]              [INT] NULL,
    	[Hr19]              [INT] NULL,
    	[Hr20]              [INT] NULL,
    	[Hr21]              [INT] NULL,
    	[Hr22]              [INT] NULL,
    	[Hr23]              [INT] NULL,
    	[Hr24]              [INT] NULL,
    	[create_user]       [VARCHAR](50) NULL,
    	[create_ts]         [DATETIME] NULL,
    	[update_user]       [VARCHAR](50) NULL,
    	[update_ts]         [DATETIME] NULL,
    	[dst_applies]       [CHAR](1) NULL,
    	[user_action]       [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table hourly_block_audit EXISTS'
END

GO

