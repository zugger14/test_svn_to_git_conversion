/*
 * [stmt_apply_cash] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_apply_cash]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_apply_cash]
    (
		stmt_apply_cash_id			INT IDENTITY(1, 1)	NOT NULL,
		stmt_invoice_detail_id		INT					NOT NULL,
		received_date				DATETIME			NOT NULL,
		cash_received				NUMERIC(32,20),
		comments					VARCHAR(MAX),
		invoice_type				CHAR(1),
		settle_status				CHAR(1),
		variance_amount				NUMERIC(32,20),
		create_user					VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),
		create_ts					DATETIME DEFAULT GETDATE(),
		update_user					VARCHAR(128) NULL,
		update_ts					DATETIME NULL,
		CONSTRAINT [PK_stmt_apply_cash] PRIMARY KEY CLUSTERED([stmt_apply_cash_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_apply_cash EXISTS'
END
GO



/*
 * [stmt_apply_cash_audit] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_apply_cash_audit]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_apply_cash_audit]
    (
		audit_id					INT IDENTITY(1, 1)	NOT NULL,
		stmt_apply_cash_id			INT 				NOT NULL,
		stmt_invoice_detail_id		INT					NOT NULL,
		received_date				DATETIME			NOT NULL,
		cash_received				NUMERIC(32,20),
		comments					VARCHAR(MAX),
		invoice_type				CHAR(1),
		settle_status				CHAR(1),
		variance_amount				NUMERIC(32,20),
		user_action					CHAR(16),
		create_user					VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),
		create_ts					DATETIME DEFAULT GETDATE(),
		update_user					VARCHAR(128) NULL,
		update_ts					DATETIME NULL,
		CONSTRAINT [PK_stmt_apply_cash_audit] PRIMARY KEY CLUSTERED([audit_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_apply_cash_audit EXISTS'
END
GO

IF COL_LENGTH('stmt_apply_cash','transaction_process_id') IS NULL
	ALTER TABLE stmt_apply_cash ADD transaction_process_id VARCHAR(200)
GO

IF COL_LENGTH('stmt_apply_cash_audit','transaction_process_id') IS NULL
	ALTER TABLE stmt_apply_cash_audit ADD transaction_process_id VARCHAR(200)
GO


/*
 * [stmt_apply_cash] - Insert Trigger
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_stmt_apply_cash]'))
    DROP TRIGGER [dbo].[TRGINS_stmt_apply_cash]
GO
 
CREATE TRIGGER [dbo].[TRGINS_stmt_apply_cash]
ON [dbo].[stmt_apply_cash]
FOR INSERT
AS
BEGIN
	INSERT INTO stmt_apply_cash_audit
	  (
	    stmt_apply_cash_id,
		stmt_invoice_detail_id,
		received_date,
		cash_received,
		comments,
		invoice_type,
		settle_status,
		variance_amount,
		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts,
		transaction_process_id
	 )
	SELECT 
		stmt_apply_cash_id,
		stmt_invoice_detail_id,
		received_date,
		cash_received,
		comments,
		invoice_type,
		settle_status,
		variance_amount,
		'insert',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts],
		transaction_process_id
	FROM  INSERTED
END
GO



/*
 * [stmt_apply_cash] - Update Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_apply_cash]'))
    DROP TRIGGER [dbo].[TRGUPD_stmt_apply_cash]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_apply_cash]
ON [dbo].[stmt_apply_cash]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.stmt_apply_cash
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.stmt_apply_cash sc
	       INNER JOIN DELETED u ON  sc.stmt_apply_cash_id = u.stmt_apply_cash_id  
	
	INSERT INTO stmt_apply_cash_audit
	  (
	    stmt_apply_cash_id,
		stmt_invoice_detail_id,
		received_date,
		cash_received,
		comments,
		invoice_type,
		settle_status,
		variance_amount,
		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts,
		transaction_process_id
	 )
	SELECT 
		stmt_apply_cash_id,
		stmt_invoice_detail_id,
		received_date,
		cash_received,
		comments,
		invoice_type,
		settle_status,
		variance_amount,
		'update' [user_action],
		[create_user],
		[create_ts],
	    @update_user,
		@update_ts,
		transaction_process_id
	FROM   INSERTED
END
GO



/*
 * [stmt_apply_cash] - Delete Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_stmt_apply_cash]'))
    DROP TRIGGER [dbo].[TRGDEL_stmt_apply_cash]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_stmt_apply_cash]
ON [dbo].[stmt_apply_cash]
FOR DELETE
AS
BEGIN
	INSERT INTO stmt_apply_cash_audit
	  (
	    stmt_apply_cash_id,
		stmt_invoice_detail_id,
		received_date,
		cash_received,
		comments,
		invoice_type,
		settle_status,
		variance_amount,
		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts,
		transaction_process_id
	 )
	SELECT 
		stmt_apply_cash_id,
		stmt_invoice_detail_id,
		received_date,
		cash_received,
		comments,
		invoice_type,
		settle_status,
		variance_amount,
		'delete',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts],
		transaction_process_id
	FROM    DELETED
END