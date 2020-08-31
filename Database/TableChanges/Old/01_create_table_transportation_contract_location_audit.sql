SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[transportation_contract_location_audit]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[transportation_contract_location_audit](
	[audit_id] INT IDENTITY(1, 1) NOT NULL,
	[id] [int] NOT NULL,
	[contract_id] [int] NOT NULL,
	[type] [int] NULL,
	[location_id] [int] NOT NULL,
	[rec_del] [int] NULL,
	[effective_date] [datetime] NULL,
	[mdq] [numeric](38, 20) NULL,
	[rank] [int] NULL,
	[surcharge] [numeric](38, 20) NULL,
	[fuel] [numeric](38, 20) NULL,
	[fuel_group] [int] NULL,
	[rate] [numeric](38, 20) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[user_action] [varchar](50) NULL
) ON [PRIMARY]

END
ELSE
BEGIN
    PRINT 'Table transportation_contract_location_audit EXISTS'
END

SET ANSI_PADDING OFF
GO




