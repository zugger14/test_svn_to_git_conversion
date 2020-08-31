SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[master_view_counterparty_contract_address]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[master_view_counterparty_contract_address] (
		[master_view_id]                   INT IDENTITY(1, 1) CONSTRAINT PK_master_view_counterparty_contract_address PRIMARY KEY NOT NULL,
		[counterparty_contract_address_id] INT REFERENCES counterparty_contract_address(counterparty_contract_address_id) NOT NULL,
		[address1]                         VARCHAR(500) NULL,
		[address2]                         VARCHAR(500) NULL,
		[address3]                         VARCHAR(500) NULL,
		[address4]                         VARCHAR(500) NULL,
		[contract_id]                      VARCHAR(500) NULL,
		[email]                            VARCHAR(500) NULL,
		[fax]                              VARCHAR(500) NULL,
		[telephone]                        VARCHAR(500) NULL,
		[counterparty_id]                  VARCHAR(500) NULL,
		[counterparty_full_name]           VARCHAR(500) NULL,
		[contract_start_date]              VARCHAR(500) NULL,
		[contract_end_date]                VARCHAR(500) NULL,
		[contract_date]                    VARCHAR(500) NULL,
		[contract_status]                  VARCHAR(500) NULL,
		[contract_active]                  VARCHAR(500) NULL,
		[cc_mail]                          VARCHAR(500) NULL,
		[bcc_mail]                         VARCHAR(500) NULL,
		[remittance_to]                    VARCHAR(500) NULL,
		[cc_remittance]                    VARCHAR(500) NULL,
		[bcc_remittance]                   VARCHAR(500) NULL,
		[internal_counterparty_id]         VARCHAR(500) NULL,
		[analyst]                          VARCHAR(500) NULL,
		[comments]                         VARCHAR(500) NULL,
		[counterparty_trigger]			   VARCHAR(500) NULL,
		[company_trigger]				   VARCHAR(500) NULL,
		[margin_provision]				   VARCHAR(500) NULL,
		[counterparty_name]				   VARCHAR(500) NULL
	)
END
ELSE
BEGIN
    PRINT 'Table master_view_counterparty_contract_address EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_contract_address]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_contract_address] (
		[address1],[address2],[address3],[address4],[contract_id],[email],[fax],[telephone],[counterparty_id],[counterparty_full_name],[contract_start_date],[contract_end_date],[contract_date],[contract_status],[contract_active],[cc_mail],[bcc_mail],[remittance_to],[cc_remittance],[bcc_remittance],[internal_counterparty_id],[analyst],[comments], [counterparty_trigger], [company_trigger],[margin_provision],[counterparty_name]
	) KEY INDEX PK_master_view_counterparty_contract_address;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_contract_address created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_contract_address Already Exists.'
GO