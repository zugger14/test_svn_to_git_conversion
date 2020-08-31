SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[counterparty_credit_info_audit]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[counterparty_credit_info_audit](
	[audit_id][int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[counterparty_credit_info_id] [int] NOT NULL,
	[Counterparty_id] [int] NULL,
	[account_status] [int] NULL,
	[limit_expiration] [datetime] NULL,
	[credit_limit] [float] NULL,
	[curreny_code] [int] NULL,
	[Tenor_limit] [int] NULL,
	[Industry_type1] [int] NULL,
	[Industry_type2] [int] NULL,
	[SIC_Code] [int] NULL,
	[Duns_No] [varchar](100) NULL,
	[Risk_rating] [int] NULL,
	[Debt_rating] [int] NULL,
	[Ticker_symbol] [varchar](100) NULL,
	[Date_established] [datetime] NULL,
	[Next_review_date] [datetime] NULL,
	[Last_review_date] [datetime] NULL,
	[Customer_since] [datetime] NULL,
	[Approved_by] [varchar](50) NULL,
	[Watch_list] [char](1) NULL,
	[Settlement_contact_name] [varchar](100) NULL,
	[Settlement_contact_address] [varchar](100) NULL,
	[Settlement_contact_address2] [varchar](100) NULL,
	[Settlement_contact_phone] [varchar](10) NULL,
	[Settlement_contact_email] [varchar](50) NULL,
	[payment_contact_name] [varchar](100) NULL,
	[payment_contact_address] [varchar](100) NULL,
	[contactfax] [varchar](100) NULL,
	[payment_contact_phone] [varchar](10) NULL,
	[payment_contact_email] [varchar](50) NULL,
	[Debt_Rating2] [int] NULL,
	[Debt_Rating3] [int] NULL,
	[Debt_Rating4] [int] NULL,
	[Debt_Rating5] [int] NULL,
	[credit_limit_from] [float] NULL,
	[payment_contact_address2] [varchar](100) NULL,
	[max_threshold] [float] NULL,
	[min_threshold] [float] NULL,
	[check_apply] [char](1) NULL,
	[cva_data] [int] NULL,
	[pfe_criteria] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[exclude_exposure_after] [int] NULL,
	[user_action][char]NOT NULL
 ) 
END
GO


