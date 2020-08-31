/*
 * [stmt_account_code_mapping] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_account_code_mapping]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_account_code_mapping]
    (
		stmt_account_code_mapping_id	INT IDENTITY(1, 1) NOT NULL,
		account_code_group_name			VARCHAR(1024),
		buy_sell_flag					CHAR(1),
		source_deal_type_id				INT,
		source_deal_sub_type_id			INT,
		commodity_id					INT,
		location_id						INT,
		location_group_id				INT,
		template_id						INT,
		currency_id						INT,
		contract_id						INT,
		counterparty_type				CHAR(1),
		counterparty_group				INT,
		region							INT,
		[priority]						INT,
		create_user						VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),
		create_ts						DATETIME DEFAULT GETDATE(),
		update_user						VARCHAR(128) NULL,
		update_ts						DATETIME NULL,
		CONSTRAINT [PK_stmt_account_code_mapping] PRIMARY KEY CLUSTERED([stmt_account_code_mapping_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_account_code_mapping EXISTS'
END
GO


IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='UQ_stmt_mapping')
BEGIN
	ALTER TABLE stmt_account_code_mapping ADD CONSTRAINT UQ_stmt_mapping UNIQUE (
		account_code_group_name,
		buy_sell_flag,
		source_deal_type_id,
		source_deal_sub_type_id,
		commodity_id,
		location_id,
		location_group_id,
		template_id,
		currency_id,
		contract_id,
		counterparty_type,
		counterparty_group,
		region,
		priority
	)
END
GO