SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[transportation_contract_parties_audit]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[transportation_contract_parties_audit](
	[audit_id] INT IDENTITY(1, 1) NOT NULL,
	[id] [int] NOT NULL,
	[contract_id] [int] NOT NULL,
	[party] [int] NOT NULL,
	[type] [int] NOT NULL,
	[effective_date] [datetime] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[user_action] [varchar](50) NULL
) ON [PRIMARY]

END
ELSE
BEGIN
    PRINT 'Table transportation_contract_parties_audit EXISTS'
END

SET ANSI_PADDING OFF
GO


