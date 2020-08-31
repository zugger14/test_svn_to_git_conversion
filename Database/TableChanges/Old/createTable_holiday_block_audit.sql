SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[holiday_block_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[holiday_block_audit]
    (
    	[audit_id]          [INT] IDENTITY(1, 1) NOT NULL,
    	[holiday_block_id]  [INT] NOT NULL,
    	[block_value_id]    [INT] NOT NULL,
    	[Onpeak_offpeak]    [CHAR](1) NULL,
    	[Hr1]               [INT] NOT NULL,
    	[Hr2]               [INT] NOT NULL,
    	[Hr3]               [INT] NOT NULL,
    	[Hr4]               [INT] NOT NULL,
    	[Hr5]               [INT] NOT NULL,
    	[Hr6]               [INT] NOT NULL,
    	[Hr7]               [INT] NOT NULL,
    	[Hr8]               [INT] NOT NULL,
    	[Hr9]               [INT] NOT NULL,
    	[Hr10]              [INT] NOT NULL,
    	[Hr11]              [INT] NOT NULL,
    	[Hr12]              [INT] NOT NULL,
    	[Hr13]              [INT] NOT NULL,
    	[Hr14]              [INT] NOT NULL,
    	[Hr15]              [INT] NOT NULL,
    	[Hr16]              [INT] NOT NULL,
    	[Hr17]              [INT] NOT NULL,
    	[Hr18]              [INT] NOT NULL,
    	[Hr19]              [INT] NOT NULL,
    	[Hr20]              [INT] NOT NULL,
    	[Hr21]              [INT] NOT NULL,
    	[Hr22]              [INT] NOT NULL,
    	[Hr23]              [INT] NOT NULL,
    	[Hr24]              [INT] NOT NULL,
    	[create_user]       [VARCHAR](50) NOT NULL,
    	[create_ts]         [DATETIME] NOT NULL,
    	[update_user]       [VARCHAR](50) NOT NULL,
    	[update_ts]         [DATETIME] NOT NULL,
    	[user_action]       [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table holiday_block_audit EXISTS'
END

GO

