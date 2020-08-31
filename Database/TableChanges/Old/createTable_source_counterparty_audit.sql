SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[source_counterparty_audit]', N'U') IS NULL
BEGIN

CREATE TABLE [dbo].[source_counterparty_audit]
(
	[audit_id]          [int] IDENTITY(1, 1) NOT NULL,
	[source_counterparty_id]          [int] NOT NULL,
	[source_system_id]                [int] NOT NULL,
	[counterparty_id]                 [varchar](50) NOT NULL,
	[counterparty_name]               [varchar](100) NOT NULL,
	[counterparty_desc]               [varchar](250) NULL,
	[int_ext_flag]                    [char](1) NULL,
	[netting_parent_counterparty_id]  [int] NULL,
	[address]                         [varchar](255) NULL,
	[phone_no]                        [varchar](100) NULL,
	[mailing_address]                 [varchar](255) NULL,
	[fax]                             [varchar](100) NULL,
	[type_of_entity]                  [int] NULL,
	[contact_name]                    [varchar](100) NULL,
	[contact_title]                   [varchar](50) NULL,
	[contact_address]                 [varchar](50) NULL,
	[contact_address2]                [varchar](50) NULL,
	[contact_phone]                   [varchar](100) NULL,
	[contact_fax]                     [varchar](50) NULL,
	[instruction]                     [varchar](1000) NULL,
	[confirm_from_text]               [varchar](500) NULL,
	[confirm_to_text]                 [varchar](500) NULL,
	[confirm_instruction]             [varchar](500) NULL,
	[counterparty_contact_title]      [varchar](500) NULL,
	[counterparty_contact_name]       [varchar](500) NULL,
	[create_user]                     [varchar](50) NULL,
	[create_ts]                       [datetime] NULL,
	[update_user]                     [varchar](50) NULL,
	[update_ts]                       [datetime] NULL,
	[parent_counterparty_id]          [int] NULL,
	[customer_duns_number]            [varchar](50) NULL,
	[is_jurisdiction]                 [char](1) NULL,
	[counterparty_contact_id]         [int] NULL,
	[email]                           [varchar](100) NULL,
	[contact_email]                   [varchar](100) NULL,
	[city]                            [varchar](50) NULL,
	[state]                           [int] NULL,
	[zip]                             [varchar](50) NULL,
	[is_active]                       [char](1) NULL,
	[user_action]                       [VARCHAR] (50)
) ON [PRIMARY]

END
ELSE
BEGIN
    PRINT 'Table source_book_audit EXISTS'
END

GO
