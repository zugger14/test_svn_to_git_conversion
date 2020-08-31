/*
 * [stmt_account_code_gl] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_account_code_gl]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_account_code_gl]
    (
		stmt_account_code_gl_id				INT IDENTITY(1, 1) NOT NULL,
		stmt_account_code_chargetype_id		INT,
		effective_date						DATETIME,
		estimate_gl							INT,
		final_gl							INT,
		prior_period_gl						INT,
		applies_to							CHAR(1),
		create_user							VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),
		create_ts							DATETIME DEFAULT GETDATE(),
		update_user							VARCHAR(128) NULL,
		update_ts							DATETIME NULL,
		CONSTRAINT [PK_stmt_account_code_gl] PRIMARY KEY CLUSTERED([stmt_account_code_gl_id] ASC),
		CONSTRAINT [FK_stmt_account_code_gl_id] FOREIGN KEY (stmt_account_code_chargetype_id) REFERENCES dbo.stmt_account_code_chargetype (stmt_account_code_chargetype_id) ON DELETE CASCADE
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_account_code_gl EXISTS'
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='UQ_stmt_account_code_gl_mapping')
BEGIN
	ALTER TABLE stmt_account_code_gl ADD CONSTRAINT UQ_stmt_account_code_gl_mapping UNIQUE (
		stmt_account_code_chargetype_id,
		effective_date,
		estimate_gl,
		final_gl,
		prior_period_gl,
		applies_to
	)
END
GO

IF COL_LENGTH('stmt_account_code_gl', 'payment_gl_group') IS NULL
BEGIN
    ALTER TABLE stmt_account_code_gl ADD payment_gl_group INT
END
ELSE
	PRINT('payment_gl_group column already exists')
GO