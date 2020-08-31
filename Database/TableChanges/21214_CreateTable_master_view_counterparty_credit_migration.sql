SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[master_view_counterparty_credit_migration]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[master_view_counterparty_credit_migration] (
		[master_view_counterparty_credit_migration_id] INT IDENTITY(1, 1) CONSTRAINT PK_master_view_counterparty_credit_migration PRIMARY KEY NOT NULL,
		[counterparty_credit_migration_id]             INT REFERENCES counterparty_credit_migration(counterparty_credit_migration_id) NOT NULL,
		[counterparty_credit_info_id]                  INT REFERENCES counterparty_credit_info(counterparty_credit_info_id) NOT NULL,
		[effective_date]                               VARCHAR(500),
		[counterparty]                                 VARCHAR(500),
		[internal_counterparty]                        VARCHAR(500),
		[contract]                                     VARCHAR(500),
		[rating]                                       VARCHAR(500)
	)
END
ELSE
BEGIN
    PRINT 'Table master_view_counterparty_credit_migration EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_credit_migration]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_migration] (
		effective_date,counterparty,internal_counterparty,[contract],rating
	) KEY INDEX PK_master_view_counterparty_credit_migration;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_migration created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_migration Already Exists.'
GO