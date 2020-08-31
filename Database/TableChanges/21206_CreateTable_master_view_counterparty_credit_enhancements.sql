SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[master_view_counterparty_credit_enhancements]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[master_view_counterparty_credit_enhancements] (
		[master_view_counterparty_credit_enhancements_id] INT IDENTITY(1, 1) CONSTRAINT PK_master_view_counterparty_credit_enhancements PRIMARY KEY NOT NULL,
		[counterparty_credit_enhancement_id]              INT REFERENCES counterparty_credit_enhancements(counterparty_credit_enhancement_id),
		[counterparty_credit_info_id]                     INT REFERENCES counterparty_credit_info(counterparty_credit_info_id) NULL,
		[enhance_type]                                    VARCHAR(500) NULL,
		[guarantee_counterparty]                          VARCHAR(500) NULL,
		[comment]                                         VARCHAR(500) NULL,
		[currency_code]                                   VARCHAR(500) NULL,
		[eff_date]                                        VARCHAR(500) NULL,
		[approved_by]                                     VARCHAR(500) NULL,
		[expiration_date]                                 VARCHAR(500) NULL,
		[contract_id]                                     VARCHAR(500) NULL,
		[internal_counterparty]                           VARCHAR(500) NULL,
		[collateral_status]                               VARCHAR(500) NULL
	)
END
ELSE
BEGIN
    PRINT 'Table master_view_counterparty_credit_enhancements EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_credit_enhancements]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_enhancements] (
		enhance_type,guarantee_counterparty,comment,currency_code,eff_date,approved_by,expiration_date,contract_id,internal_counterparty,collateral_status
	) KEY INDEX PK_master_view_counterparty_credit_enhancements;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_enhancements created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_enhancements Already Exists.'
GO