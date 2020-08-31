SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[counterparty_contract_address_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[counterparty_contract_address_audit](
		[counterparty_contract_address_audit_id] [int] IDENTITY(1, 1)  PRIMARY KEY NOT NULL,
		[counterparty_contract_address_id] [int],
		[address1] [NVARCHAR](100) NULL,
		[address2] [NVARCHAR](100) NULL,
		[address3] [NVARCHAR](100) NULL,
		[address4] [NVARCHAR](100) NULL,
		[contract_id] [int] NULL,
		[email] [NVARCHAR](1000) NULL,
		[fax] [NVARCHAR](50) NULL,
		[telephone] [NVARCHAR](20) NULL,
		[create_user] [NVARCHAR](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [NVARCHAR](50) NULL,
		[update_ts] [datetime] NULL,
		[counterparty_id] [int] NULL,
		[counterparty_full_name] [NVARCHAR](400) NULL,
		[contract_start_date] [datetime] NULL,
		[contract_end_date] [datetime] NULL,
		[apply_netting_rule] [char](1) NULL,
		[contract_date] [datetime] NULL,
		[contract_status] [int] NULL,
		[contract_active] [char](1) NULL,
		[cc_mail] [NVARCHAR](MAX) NULL,
		[bcc_mail] [NVARCHAR](MAX) NULL,
		[remittance_to] [NVARCHAR](MAX) NULL,
		[cc_remittance] [NVARCHAR](MAX) NULL,
		[bcc_remittance] [NVARCHAR](MAX) NULL,
		[billing_start_month] [int] NULL,
		[internal_counterparty_id] [int] NULL,
		[rounding] [bigint] NULL,
		[margin_provision] [int] NULL,
		[time_zone] [int] NULL,
		[offset_method] [int] NULL,
		[interest_rate] [int] NULL,
		[interest_method] [NVARCHAR](200) NULL,
		[payment_days] [int] NULL,
		[invoice_due_date] [int] NULL,
		[holiday_calendar_id] [int] NULL,
		[counterparty_trigger] [int] NULL,
		[company_trigger] [int] NULL,
		[payables] [int] NULL,
		[receivables] [int] NULL,
		[confirmation] [int] NULL,
		[payment_rule] [int] NULL,
		[bank_account] [int] NULL,
		[negative_interest] [int] NULL,
		[no_of_days] [int] NULL,
		[secondary_counterparty] [int] NULL,
		[threshold_provided] [float] NULL,
		[threshold_received] [float] NULL,
		[analyst] [NVARCHAR](200) NULL,
		[min_transfer_amount] [float] NULL,
		[comments] [NVARCHAR](200) NULL,
		[allow_all_products] [char](1) NULL,
		[credit] [NVARCHAR](max) NULL,
		[amendment_date] [datetime] NULL,
		[amendment_description] [NVARCHAR](1000) NULL,
		[external_counterparty_id] [NVARCHAR](500) NULL,
		[description] [NVARCHAR](500) NULL,
		[ferc_id] [NVARCHAR](150) NULL,
		[user_action] [NVARCHAR](50)
 )
END
ELSE
BEGIN
    PRINT 'Table counterparty_contract_address_audit EXISTS'
END
