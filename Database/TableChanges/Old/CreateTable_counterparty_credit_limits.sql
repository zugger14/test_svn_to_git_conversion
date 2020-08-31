SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[counterparty_credit_limits]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[counterparty_credit_limits](
		[counterparty_credit_limit_id] [int] IDENTITY(1,1) NOT NULL,
		[effective_Date] [datetime] NULL,
		[credit_limit] [float] NULL,
		[credit_limit_to_us] [float] NULL,
		[tenor_limit] [int] NULL,
		[max_threshold] [float] NULL,
		[min_threshold] [float] NULL,
		[counterparty_id] [int] NULL,
		[internal_counterparty_id] [int] NULL,
		[contract_id] [int] NULL,
		[currency_id] [int] NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL
	) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table counterparty_credit_limits already exists.'
END
 
GO


