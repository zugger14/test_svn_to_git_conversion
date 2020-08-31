SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[master_view_counterparty_credit_info]', N'U') IS NULL
BEGIN
   CREATE TABLE [dbo].[master_view_counterparty_credit_info] (
		[master_view_counterparty_credit_info_id] INT IDENTITY(1, 1) CONSTRAINT PK_master_view_counterparty_credit_info PRIMARY KEY NOT NULL,
		[counterparty_credit_info_id]             INT REFERENCES counterparty_credit_info(counterparty_credit_info_id) NOT NULL,
		[Counterparty_id]                         VARCHAR(500) NULL,
		[account_status]                          VARCHAR(500) NULL,
		[limit_expiration]                        VARCHAR(500) NULL,
		[curreny_code]                            VARCHAR(500) NULL,
		[Tenor_limit]                             VARCHAR(500) NULL,
		[Industry_type1]                          VARCHAR(500) NULL,
		[Industry_type2]                          VARCHAR(500) NULL,
		[SIC_Code]                                VARCHAR(500) NULL,
		[Duns_No]                                 VARCHAR(500) NULL,
		[Risk_rating]                             VARCHAR(500) NULL,
		[Debt_rating]                             VARCHAR(500) NULL,
		[Ticker_symbol]                           VARCHAR(500) NULL,
		[Date_established]                        VARCHAR(500) NULL,
		[Next_review_date]                        VARCHAR(500) NULL,
		[Last_review_date]                        VARCHAR(500) NULL,
		[Customer_since]                          VARCHAR(500) NULL,
		[Approved_by]                             VARCHAR(500) NULL,
		[Settlement_contact_name]                 VARCHAR(500) NULL,
		[Settlement_contact_address]              VARCHAR(500) NULL,
		[Settlement_contact_address2]             VARCHAR(500) NULL,
		[Settlement_contact_phone]                VARCHAR(500) NULL,
		[Settlement_contact_email]                VARCHAR(500) NULL,
		[payment_contact_name]                    VARCHAR(500) NULL,
		[payment_contact_address]                 VARCHAR(500) NULL,
		[contactfax]                              VARCHAR(500) NULL,
		[payment_contact_phone]                   VARCHAR(500) NULL,
		[payment_contact_email]                   VARCHAR(500) NULL,
		[Debt_Rating2]                            VARCHAR(500) NULL,
		[Debt_Rating3]                            VARCHAR(500) NULL,
		[Debt_Rating4]                            VARCHAR(500) NULL,
		[Debt_Rating5]                            VARCHAR(500) NULL,
		[payment_contact_address2]                VARCHAR(500) NULL,
		[analyst]                                 VARCHAR(500) NULL,
		[rating_outlook]                          VARCHAR(500) NULL
	)
END
ELSE
BEGIN
    PRINT 'Table master_view_counterparty_credit_info EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_credit_info]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_credit_info] (
		Counterparty_id,account_status,limit_expiration,curreny_code,Tenor_limit,Industry_type1,Industry_type2,SIC_Code,Duns_No,Risk_rating,Debt_rating,Ticker_symbol,Date_established,Next_review_date,Last_review_date,Customer_since,Approved_by,Settlement_contact_name,Settlement_contact_address,Settlement_contact_address2,Settlement_contact_phone,Settlement_contact_email,payment_contact_name,payment_contact_address,contactfax,payment_contact_phone,payment_contact_email,Debt_Rating2,Debt_Rating3,Debt_Rating4,Debt_Rating5,payment_contact_address2,analyst,rating_outlook
	) KEY INDEX PK_master_view_counterparty_credit_info;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_info created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_credit_info Already Exists.'
GO