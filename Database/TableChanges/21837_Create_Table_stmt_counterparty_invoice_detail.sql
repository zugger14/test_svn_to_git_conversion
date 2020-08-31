/*
 * [stmt_counterparty_invoice_detail] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_counterparty_invoice_detail]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_counterparty_invoice_detail]
    (
		stmt_counterparty_invoice_detail_id	INT IDENTITY(1, 1)	NOT NULL,
		stmt_counterparty_invoice_id		INT					NOT NULL,
		prod_date_from						DATETIME,
		prod_date_to						DATETIME,
		invoice_amount						NUMERIC(32,20),
		currency_id							INT,
		invoice_volume						NUMERIC(32,20),
		invoice_volume_uom_id				INT,
		description1						VARCHAR(MAX),
		description2						VARCHAR(MAX),
		description3						VARCHAR(MAX),
		[status]							VARCHAR(128),	
		create_user							VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),
		create_ts							DATETIME DEFAULT GETDATE(),
		update_user							VARCHAR(128) NULL,
		update_ts							DATETIME NULL,
		CONSTRAINT [PK_stmt_counterparty_invoice_detail]		PRIMARY KEY CLUSTERED([stmt_counterparty_invoice_detail_id] ASC),
		CONSTRAINT [FK_stmt_counterparty_invoice_detail_stmt_counterparty_invoice_id] FOREIGN KEY (stmt_counterparty_invoice_id) REFERENCES dbo.stmt_counterparty_invoice (stmt_counterparty_invoice_id) ON DELETE CASCADE
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_counterparty_invoice_detail EXISTS'
END
GO



/*
 * [stmt_counterparty_invoice_detail_audit] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_counterparty_invoice_detail_audit]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_counterparty_invoice_detail_audit]
    (
		audit_id							INT IDENTITY(1, 1)	NOT NULL,
		stmt_counterparty_invoice_detail_id	INT					NOT NULL,
		stmt_counterparty_invoice_id		INT					NOT NULL,
		prod_date_from						DATETIME,
		prod_date_to						DATETIME,
		invoice_amount						NUMERIC(32,20),
		currency_id							INT,
		invoice_volume						NUMERIC(32,20),
		invoice_volume_uom_id				INT,
		description1						VARCHAR(MAX),
		description2						VARCHAR(MAX),
		description3						VARCHAR(MAX),
		[status]							VARCHAR(128),	
		user_action							CHAR(16),
		create_user							VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),
		create_ts							DATETIME DEFAULT GETDATE(),
		update_user							VARCHAR(128) NULL,
		update_ts							DATETIME NULL,
		CONSTRAINT [PK_stmt_counterparty_invoice_detail_audit] PRIMARY KEY CLUSTERED([audit_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_counterparty_invoice_detail_audit EXISTS'
END
GO



/*
 * [stmt_counterparty_invoice_detail] - Insert Trigger
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_stmt_counterparty_invoice_detail]'))
    DROP TRIGGER [dbo].[TRGINS_stmt_counterparty_invoice_detail]
GO
 
CREATE TRIGGER [dbo].[TRGINS_stmt_counterparty_invoice_detail]
ON [dbo].[stmt_counterparty_invoice_detail]
FOR INSERT
AS
BEGIN
	INSERT INTO stmt_counterparty_invoice_detail_audit
	  (
	    stmt_counterparty_invoice_detail_id,
		stmt_counterparty_invoice_id,
		prod_date_from,
		prod_date_to,
		invoice_amount,
		currency_id,
		invoice_volume,
		invoice_volume_uom_id,
		description1,
		description2,
		description3,
		[status],
		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts
	  )
	SELECT 
		stmt_counterparty_invoice_detail_id,
		stmt_counterparty_invoice_id,
		prod_date_from,
		prod_date_to,
		invoice_amount,
		currency_id,
		invoice_volume,
		invoice_volume_uom_id,
		description1,
		description2,
		description3,
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
 * [stmt_counterparty_invoice_detail] - Update Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_counterparty_invoice_detail]'))
    DROP TRIGGER [dbo].[TRGUPD_stmt_counterparty_invoice_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_counterparty_invoice_detail]
ON [dbo].[stmt_counterparty_invoice_detail]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.stmt_counterparty_invoice_detail
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.stmt_counterparty_invoice_detail sc
	       INNER JOIN DELETED u ON  sc.stmt_counterparty_invoice_detail_id = u.stmt_counterparty_invoice_detail_id  
	
	INSERT INTO stmt_counterparty_invoice_detail_audit
	  (
	    stmt_counterparty_invoice_detail_id,
		stmt_counterparty_invoice_id,
		prod_date_from,
		prod_date_to,
		invoice_amount,
		currency_id,
		invoice_volume,
		invoice_volume_uom_id,
		description1,
		description2,
		description3,
		[status],
		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts
	  )
	SELECT 
		stmt_counterparty_invoice_detail_id,
		stmt_counterparty_invoice_id,
		prod_date_from,
		prod_date_to,
		invoice_amount,
		currency_id,
		invoice_volume,
		invoice_volume_uom_id,
		description1,
		description2,
		description3,
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
 * [stmt_counterparty_invoice_detail] - Delete Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_stmt_counterparty_invoice_detail]'))
    DROP TRIGGER [dbo].[TRGDEL_stmt_counterparty_invoice_detail]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_stmt_counterparty_invoice_detail]
ON [dbo].[stmt_counterparty_invoice_detail]
FOR DELETE
AS
BEGIN
	INSERT INTO stmt_counterparty_invoice_detail_audit
	  (
	    stmt_counterparty_invoice_detail_id,
		stmt_counterparty_invoice_id,
		prod_date_from,
		prod_date_to,
		invoice_amount,
		currency_id,
		invoice_volume,
		invoice_volume_uom_id,
		description1,
		description2,
		description3,
		[status],
		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts
	  )
	SELECT 
		stmt_counterparty_invoice_detail_id,
		stmt_counterparty_invoice_id,
		prod_date_from,
		prod_date_to,
		invoice_amount,
		currency_id,
		invoice_volume,
		invoice_volume_uom_id,
		description1,
		description2,
		description3,
		[status],
		'delete',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts]
	FROM    DELETED
END