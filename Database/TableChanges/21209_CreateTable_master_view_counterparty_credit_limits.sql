SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[master_view_counterparty_credit_limits]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[master_view_counterparty_credit_limits] (
    	[master_view_counterparty_credit_limits_id]	INT IDENTITY(1, 1) CONSTRAINT PK_master_view_counterparty_credit_limits PRIMARY KEY NOT NULL,
		[counterparty_credit_limit_id] INT REFERENCES counterparty_credit_limits(counterparty_credit_limit_id) NOT NULL,
		[counterparty_credit_info_id]  INT REFERENCES counterparty_credit_info(counterparty_credit_info_id) NOT NULL,
		[counterparty_id] VARCHAR(500),
		[internal_counterparty_id] VARCHAR(500),
		[contract_id]  VARCHAR(500),
		[limit_status] VARCHAR(500)
    )
END
ELSE
BEGIN
    PRINT 'Table master_view_counterparty_credit_limits EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_credit_limits]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_limits] (
		counterparty_id,internal_counterparty_id,contract_id,limit_status
	) KEY INDEX PK_master_view_counterparty_credit_limits;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_limits created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_limits Already Exists.'
GO