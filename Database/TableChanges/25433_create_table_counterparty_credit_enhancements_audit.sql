SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[counterparty_credit_enhancements_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[counterparty_credit_enhancements_audit](
	[counterparty_credit_enhancements_audit_id] [INT] IDENTITY(1,1) NOT NULL,
	[counterparty_credit_enhancement_id] [INT],
	[counterparty_credit_info_id] [INT] NULL,
	[enhance_type] [INT] NULL,
	[guarantee_counterparty] [INT] NULL,
	[comment] [VARCHAR](100) NULL,
	[amount] [FLOAT] NULL,
	[currency_code] [INT] NULL,
	[eff_date] [DATETIME] NULL,
	[margin] [CHAR](1) NULL,
	[rely_self] [CHAR](1) NULL,
	[approved_by] [VARCHAR](50) NULL,
	[expiration_date] [DATETIME] NULL,
	[create_user] [VARCHAR](50) NULL,
	[create_ts] [DATETIME] NULL,
	[update_user] [VARCHAR](50) NULL,
	[update_ts] [DATETIME] NULL,
	[exclude_collateral] [CHAR](1) NOT NULL,
	[contract_id] [INT] NULL,
	[internal_counterparty] [INT] NULL,
	[deal_id] [VARCHAR](50) NULL,
	[auto_renewal] [CHAR](1) NULL,
	[transferred] [CHAR](1) NULL,
	[is_primary] [bit] NULL,
	[collateral_status] [INT] NULL,
	[blocked] [CHAR](1) NULL,
	[user_action] [VARCHAR](20) NOT NULL
)
END
ELSE
BEGIN
    PRINT 'Table counterparty_contacts_audit EXISTS'
END
