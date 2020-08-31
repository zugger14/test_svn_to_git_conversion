SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[master_view_counterparty_epa_account]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[master_view_counterparty_epa_account] (
		[master_view_counterparty_epa_account_id] INT IDENTITY(1, 1) CONSTRAINT PK_master_view_counterparty_epa_account PRIMARY KEY  NOT NULL,
		[counterparty_epa_account_id]             INT REFERENCES counterparty_epa_account(counterparty_epa_account_id) NOT NULL,
		[counterparty_id]                         INT,
		[counterparty_name]                       VARCHAR(500) NULL,
		[external_type_id]                        VARCHAR(500) NULL,
		[external_value]                          VARCHAR(500) NULL
	)
END
ELSE
BEGIN
    PRINT 'Table master_view_counterparty_epa_account EXISTS'
END
 
GO


SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_epa_account]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_epa_account] (
		counterparty_name,external_type_id,external_value
	) KEY INDEX PK_master_view_counterparty_epa_account;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_epa_account created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_epa_account Already Exists.'
GO