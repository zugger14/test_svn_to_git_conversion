/*
 * [stmt_invoice_detail] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_invoice_detail]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_invoice_detail]
    (
		stmt_invoice_detail_id			INT IDENTITY(1, 1)	NOT NULL,
		stmt_invoice_id					INT					NOT NULL,
		invoice_line_item_id			INT					NOT NULL,
		prod_date_from					DATETIME			NOT NULL,
		prod_date_to					DATETIME			NOT NULL,
		value							NUMERIC(32,20),
		volume							NUMERIC(32,20),
		show_volume_in_invoice			CHAR(1),
		show_charge_in_invoice			CHAR(1),
		description1					VARCHAR(MAX),
		description2					VARCHAR(MAX),
		description3					VARCHAR(MAX),
		description4					VARCHAR(MAX),
		description5					VARCHAR(MAX),
		create_user						VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts						DATETIME DEFAULT GETDATE(),		update_user						VARCHAR(128) NULL,
		update_ts						DATETIME NULL,		CONSTRAINT [PK_stmt_invoice_detail]	PRIMARY KEY CLUSTERED([stmt_invoice_detail_id] ASC),
		CONSTRAINT [FK_stmt_invoice_detail_stmt_invoice_id] FOREIGN KEY (stmt_invoice_id) REFERENCES dbo.stmt_invoice (stmt_invoice_id) ON DELETE CASCADE
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_invoice_detail EXISTS'
END
GO



/*
 * [stmt_invoice_detail_audit] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_invoice_detail_audit]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_invoice_detail_audit]
    (
		audit_id						INT IDENTITY(1, 1)	NOT NULL,
		stmt_invoice_detail_id			INT					NOT NULL,
		stmt_invoice_id					INT					NOT NULL,
		invoice_line_item_id			INT					NOT NULL,
		prod_date_from					DATETIME			NOT NULL,
		prod_date_to					DATETIME			NOT NULL,
		value							NUMERIC(32,20),
		volume							NUMERIC(32,20),
		show_volume_in_invoice			CHAR(1),
		show_charge_in_invoice			CHAR(1),
		description1					VARCHAR(MAX),
		description2					VARCHAR(MAX),
		description3					VARCHAR(MAX),
		description4					VARCHAR(MAX),
		description5					VARCHAR(MAX),
		user_action						VARCHAR(16),
		create_user						VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts						DATETIME DEFAULT GETDATE(),		update_user						VARCHAR(128) NULL,
		update_ts						DATETIME NULL,		CONSTRAINT [PK_stmt_invoice_detail_audit]	PRIMARY KEY CLUSTERED(audit_id ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_invoice_detail_audit EXISTS'
END
GO



/*
 * [stmt_invoice_detail] - Insert Trigger
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_stmt_invoice_detail]'))
    DROP TRIGGER [dbo].[TRGINS_stmt_invoice_detail]
GO
 
CREATE TRIGGER [dbo].[TRGINS_stmt_invoice_detail]
ON [dbo].[stmt_invoice_detail]
FOR INSERT
AS
BEGIN
	INSERT INTO stmt_invoice_detail_audit
	  (
	    stmt_invoice_detail_id,
		stmt_invoice_id,
		invoice_line_item_id,
		prod_date_from,
		prod_date_to,
		value,
		volume,
		show_volume_in_invoice,
		show_charge_in_invoice,
		description1,
		description2,
		description3,
		description4,
		description5,		user_action,		create_user,		create_ts,		update_user,		update_ts	  )
	SELECT 
		stmt_invoice_detail_id,
		stmt_invoice_id,
		invoice_line_item_id,
		prod_date_from,
		prod_date_to,
		value,
		volume,
		show_volume_in_invoice,
		show_charge_in_invoice,
		description1,
		description2,
		description3,
		description4,
		description5,
		'insert',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts]
	FROM  INSERTED
END
GO



/*
 * [stmt_invoice_detail] - Update Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_invoice_detail]'))
    DROP TRIGGER [dbo].[TRGUPD_stmt_invoice_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_invoice_detail]
ON [dbo].[stmt_invoice_detail]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.stmt_invoice_detail
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.stmt_invoice_detail sc
	       INNER JOIN DELETED u ON  sc.stmt_invoice_detail_id = u.stmt_invoice_detail_id  
	
	INSERT INTO stmt_invoice_detail_audit
	  (
	    stmt_invoice_detail_id,
		stmt_invoice_id,
		invoice_line_item_id,
		prod_date_from,
		prod_date_to,
		value,
		volume,
		show_volume_in_invoice,
		show_charge_in_invoice,
		description1,
		description2,
		description3,
		description4,
		description5,		user_action,		create_user,		create_ts,		update_user,		update_ts	  )
	SELECT 
		stmt_invoice_detail_id,
		stmt_invoice_id,
		invoice_line_item_id,
		prod_date_from,
		prod_date_to,
		value,
		volume,
		show_volume_in_invoice,
		show_charge_in_invoice,
		description1,
		description2,
		description3,
		description4,
		description5,
		'update' [user_action],
		[create_user],
		[create_ts],
	    @update_user,
		@update_ts
	FROM   INSERTED
END
GO



/*
 * [stmt_invoice_detail] - Delete Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_stmt_invoice_detail]'))
    DROP TRIGGER [dbo].[TRGDEL_stmt_invoice_detail]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_stmt_invoice_detail]
ON [dbo].[stmt_invoice_detail]
FOR DELETE
AS
BEGIN
	INSERT INTO stmt_invoice_detail_audit
	  (
	    stmt_invoice_detail_id,
		stmt_invoice_id,
		invoice_line_item_id,
		prod_date_from,
		prod_date_to,
		value,
		volume,
		show_volume_in_invoice,
		show_charge_in_invoice,
		description1,
		description2,
		description3,
		description4,
		description5,		user_action,		create_user,		create_ts,		update_user,		update_ts	  )
	SELECT 
		stmt_invoice_detail_id,
		stmt_invoice_id,
		invoice_line_item_id,
		prod_date_from,
		prod_date_to,
		value,
		volume,
		show_volume_in_invoice,
		show_charge_in_invoice,
		description1,
		description2,
		description3,
		description4,
		description5,
		'delete',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts]
	FROM    DELETED
END