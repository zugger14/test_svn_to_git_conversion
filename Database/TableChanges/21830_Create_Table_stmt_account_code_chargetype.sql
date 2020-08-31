/*
 * [stmt_account_code_chargetype] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_account_code_chargetype]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_account_code_chargetype]
    (
		stmt_account_code_chargetype_id	INT IDENTITY(1, 1) NOT NULL,
		stmt_account_code_mapping_id	INT,
		deal_charge_type_id				INT,
		contract_charge_type_id			INT,
		invoicing_charge_type_id		INT,
		charge_type_alias				INT,
		pnl_line_item_id				INT,
		create_user						VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),
		create_ts						DATETIME DEFAULT GETDATE(),
		update_user						VARCHAR(128) NULL,
		update_ts						DATETIME NULL,
		CONSTRAINT [PK_stmt_account_code_chargetype] PRIMARY KEY CLUSTERED([stmt_account_code_chargetype_id] ASC),
		CONSTRAINT [FK_stmt_account_code_chargetype_mapping_id] FOREIGN KEY (stmt_account_code_mapping_id) REFERENCES dbo.stmt_account_code_mapping (stmt_account_code_mapping_id) ON DELETE CASCADE
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_account_code_chargetype EXISTS'
END
GO


IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='UQ_stmt_account_code_ct_mapping')
BEGIN
	ALTER TABLE stmt_account_code_chargetype ADD CONSTRAINT UQ_stmt_account_code_ct_mapping UNIQUE (
		stmt_account_code_mapping_id,
		deal_charge_type_id,
		contract_charge_type_id,
		invoicing_charge_type_id,
		charge_type_alias,
		pnl_line_item_id
	)
END
GO