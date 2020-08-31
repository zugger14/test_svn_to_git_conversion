SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[counterparty_contacts_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[counterparty_contacts_audit](
			[counterparty_contacts_audit_id] [INT] IDENTITY(1, 1)  PRIMARY KEY NOT NULL,
			[counterparty_contact_id] [INT] ,
			[counterparty_id] [INT] NULL,
			[contact_type] [INT] NULL,
			[title] [NVARCHAR](200) NULL,
			[name] [NVARCHAR](100) NULL,
			[id] [NVARCHAR](100) NULL,
			[address1] [NVARCHAR](255) NULL,
			[address2] [NVARCHAR](255) NULL,
			[city] [NVARCHAR](100) NULL,
			[state] [INT] NULL,
			[zip] [NVARCHAR](100) NULL,
			[telephone] [NVARCHAR](20) NULL,
			[fax] [NVARCHAR](50) NULL,
			[email] [NVARCHAR](MAX) NULL,
			[country] [INT] NULL,
			[region] [INT] NULL,
			[comment] [NVARCHAR](MAX) NULL,
			[is_active] [NCHAR](1) NULL,
			[is_primary] [NCHAR](1) NULL,
			[create_user] [NVARCHAR](50) NULL,
			[create_ts] [DATETIME] NULL,
			[update_user] [NVARCHAR](50) NULL,
			[update_ts] [DATETIME] NULL,
			[cell_no] [NVARCHAR](20) NULL,
			[email_cc] [NVARCHAR](MAX) NULL,
			[email_bcc] [NVARCHAR](100) NULL,
			[last_name] [NVARCHAR](250) NULL,
			[date_of_birth] [NVARCHAR](250) NULL,
			[national_id] [NVARCHAR](200) NULL,
			[user_action] [NVARCHAR](50)
 )
END
ELSE
BEGIN
    PRINT 'Table counterparty_contacts_audit EXISTS'
END
