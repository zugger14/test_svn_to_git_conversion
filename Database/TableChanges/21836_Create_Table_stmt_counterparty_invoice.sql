/*
 * [stmt_counterparty_invoice] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_counterparty_invoice]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_counterparty_invoice]
    (
		stmt_counterparty_invoice_id	INT IDENTITY(1, 1)	NOT NULL,
		stmt_invoice_id					INT					NOT NULL,
		invoice_ref_no					VARCHAR(1024),
		invoice_date					DATETIME,
		invoice_due_date				DATETIME,
		description1					VARCHAR(MAX),
		description2					VARCHAR(MAX),
		description3					VARCHAR(MAX),
		description4					VARCHAR(MAX),
		[status]						VARCHAR(128),		create_user						VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts						DATETIME DEFAULT GETDATE(),		update_user						VARCHAR(128) NULL,
		update_ts						DATETIME NULL,		CONSTRAINT [PK_stmt_counterparty_invoice]	PRIMARY KEY CLUSTERED([stmt_counterparty_invoice_id] ASC),
		CONSTRAINT [FK_stmt_counterparty_invoice_stmt_invoice_id] FOREIGN KEY (stmt_invoice_id) REFERENCES dbo.stmt_invoice (stmt_invoice_id) ON DELETE CASCADE, 
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_counterparty_invoice EXISTS'
END
GO



/*
 * [stmt_counterparty_invoice_audit] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_counterparty_invoice_audit]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_counterparty_invoice_audit]
    (
		audit_id						INT IDENTITY(1, 1)	NOT NULL,
		stmt_counterparty_invoice_id	INT					NOT NULL,
		stmt_invoice_id					INT					NOT NULL,
		invoice_ref_no					VARCHAR(1024),
		invoice_date					DATETIME,
		invoice_due_date				DATETIME,
		description1					VARCHAR(MAX),
		description2					VARCHAR(MAX),
		description3					VARCHAR(MAX),
		description4					VARCHAR(MAX),
		[status]						VARCHAR(128),		user_action						CHAR(16),		create_user						VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts						DATETIME DEFAULT GETDATE(),		update_user						VARCHAR(128) NULL,
		update_ts						DATETIME NULL,		CONSTRAINT [PK_stmt_counterparty_invoice_audit] PRIMARY KEY CLUSTERED([audit_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_counterparty_invoice_audit EXISTS'
END
GO



/*
 * [stmt_counterparty_invoice] - Insert Trigger
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_stmt_counterparty_invoice]'))
    DROP TRIGGER [dbo].[TRGINS_stmt_counterparty_invoice]
GO
 
CREATE TRIGGER [dbo].[TRGINS_stmt_counterparty_invoice]
ON [dbo].[stmt_counterparty_invoice]
FOR INSERT
AS
BEGIN
	INSERT INTO stmt_counterparty_invoice_audit
	  (
	    stmt_counterparty_invoice_id,
		stmt_invoice_id,
		invoice_ref_no,
		invoice_date,
		invoice_due_date,
		description1,
		description2,
		description3,
		description4,
		[status],		user_action,		create_user,		create_ts,		update_user,		update_ts	  )
	SELECT 
		stmt_counterparty_invoice_id,
		stmt_invoice_id,
		invoice_ref_no,
		invoice_date,
		invoice_due_date,
		description1,
		description2,
		description3,
		description4,
		[status],
		'insert',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts]
	FROM  INSERTED
END
GO



/*
 * [stmt_counterparty_invoice] - Update Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_counterparty_invoice]'))
    DROP TRIGGER [dbo].[TRGUPD_stmt_counterparty_invoice]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_counterparty_invoice]
ON [dbo].[stmt_counterparty_invoice]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.stmt_counterparty_invoice
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.stmt_counterparty_invoice sc
	       INNER JOIN DELETED u ON  sc.stmt_counterparty_invoice_id = u.stmt_counterparty_invoice_id  
	
	INSERT INTO stmt_counterparty_invoice_audit
	  (
	    stmt_counterparty_invoice_id,
		stmt_invoice_id,
		invoice_ref_no,
		invoice_date,
		invoice_due_date,
		description1,
		description2,
		description3,
		description4,
		[status],		user_action,		create_user,		create_ts,		update_user,		update_ts	  )
	SELECT 
		stmt_counterparty_invoice_id,
		stmt_invoice_id,
		invoice_ref_no,
		invoice_date,
		invoice_due_date,
		description1,
		description2,
		description3,
		description4,
		[status],
		'update' [user_action],
		[create_user],
		[create_ts],
	    @update_user,
		@update_ts
	FROM   INSERTED
END
GO



/*
 * [stmt_counterparty_invoice] - Delete Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_stmt_counterparty_invoice]'))
    DROP TRIGGER [dbo].[TRGDEL_stmt_counterparty_invoice]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_stmt_counterparty_invoice]
ON [dbo].[stmt_counterparty_invoice]
FOR DELETE
AS
BEGIN
	INSERT INTO stmt_counterparty_invoice_audit
	  (
	    stmt_counterparty_invoice_id,
		stmt_invoice_id,
		invoice_ref_no,
		invoice_date,
		invoice_due_date,
		description1,
		description2,
		description3,
		description4,
		[status],		user_action,		create_user,		create_ts,		update_user,		update_ts	  )
	SELECT 
		stmt_counterparty_invoice_id,
		stmt_invoice_id,
		invoice_ref_no,
		invoice_date,
		invoice_due_date,
		description1,
		description2,
		description3,
		description4,
		[status],
		'delete',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts]
	FROM    DELETED
END