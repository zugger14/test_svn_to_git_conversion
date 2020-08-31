/*
 * [stmt_apply_cash_detail] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_apply_cash_detail]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_apply_cash_detail]
    (
		stmt_apply_cash_detail_id	INT IDENTITY(1, 1)	NOT NULL,
		stmt_invoice_detail_id		INT					NOT NULL,
		stmt_checkout_id			INT					NOT NULL,
		cash_received				NUMERIC(32,20),
		settle_status				CHAR(1),
		variance_amount				NUMERIC(32,20),		create_user					VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts					DATETIME DEFAULT GETDATE(),		update_user					VARCHAR(128) NULL,
		update_ts					DATETIME NULL,		CONSTRAINT [PK_stmt_apply_cash_detail] PRIMARY KEY CLUSTERED([stmt_apply_cash_detail_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_apply_cash_detail EXISTS'
END
GO



/*
 * [stmt_apply_cash_detail_audit] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_apply_cash_detail_audit]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_apply_cash_detail_audit]
    (
		audit_id					INT IDENTITY(1, 1)	NOT NULL,
		stmt_apply_cash_detail_id	INT					NOT NULL,
		stmt_invoice_detail_id		INT					NOT NULL,
		stmt_checkout_id			INT					NOT NULL,
		cash_received				NUMERIC(32,20),
		settle_status				CHAR(1),
		variance_amount				NUMERIC(32,20),		user_action					CHAR(16),		create_user					VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts					DATETIME DEFAULT GETDATE(),		update_user					VARCHAR(128) NULL,
		update_ts					DATETIME NULL,		CONSTRAINT [PK_stmt_apply_cash_detail_audit] PRIMARY KEY CLUSTERED([audit_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_apply_cash_detail_audit EXISTS'
END
GO



/*
 * [stmt_apply_cash_detail] - Insert Trigger
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_stmt_apply_cash_detail]'))
    DROP TRIGGER [dbo].[TRGINS_stmt_apply_cash_detail]
GO
 
CREATE TRIGGER [dbo].[TRGINS_stmt_apply_cash_detail]
ON [dbo].[stmt_apply_cash_detail]
FOR INSERT
AS
BEGIN
	INSERT INTO stmt_apply_cash_detail_audit
	  (
	    stmt_apply_cash_detail_id,
		stmt_invoice_detail_id,
		stmt_checkout_id,
		cash_received,
		settle_status,
		variance_amount,		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts
	 )
	SELECT 
		stmt_apply_cash_detail_id,
		stmt_invoice_detail_id,
		stmt_checkout_id,
		cash_received,
		settle_status,
		variance_amount,
		'insert',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts]
	FROM  INSERTED
END
GO



/*
 * [stmt_apply_cash_detail] - Update Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_apply_cash_detail]'))
    DROP TRIGGER [dbo].[TRGUPD_stmt_apply_cash_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_apply_cash_detail]
ON [dbo].[stmt_apply_cash_detail]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.stmt_apply_cash_detail
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.stmt_apply_cash_detail sc
	       INNER JOIN DELETED u ON  sc.stmt_apply_cash_detail_id = u.stmt_apply_cash_detail_id  
	
	INSERT INTO stmt_apply_cash_detail_audit
	  (
		stmt_apply_cash_detail_id,
		stmt_invoice_detail_id,
		stmt_checkout_id,
		cash_received,
		settle_status,
		variance_amount,		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts
	 )
	SELECT 
		stmt_apply_cash_detail_id,
		stmt_invoice_detail_id,
		stmt_checkout_id,
		cash_received,
		settle_status,
		variance_amount,		'update' [user_action],
		[create_user],
		[create_ts],
	    @update_user,
		@update_ts
	FROM   INSERTED
END
GO



/*
 * [stmt_apply_cash_detail] - Delete Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_stmt_apply_cash_detail]'))
    DROP TRIGGER [dbo].[TRGDEL_stmt_apply_cash_detail]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_stmt_apply_cash_detail]
ON [dbo].[stmt_apply_cash_detail]
FOR DELETE
AS
BEGIN
	INSERT INTO stmt_apply_cash_detail_audit
	  (
	    stmt_apply_cash_detail_id,
		stmt_invoice_detail_id,
		stmt_checkout_id,
		cash_received,
		settle_status,
		variance_amount,
		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts
	 )
	SELECT 
		stmt_apply_cash_detail_id,
		stmt_invoice_detail_id,
		stmt_checkout_id,
		cash_received,
		settle_status,
		variance_amount,
		'delete',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts]
	FROM    DELETED
END