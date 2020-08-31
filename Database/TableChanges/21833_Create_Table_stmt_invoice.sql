/*
 * [stmt_invoice] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_invoice]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_invoice]
    (
		stmt_invoice_id			INT IDENTITY(1, 1)	NOT NULL,
		as_of_date				DATETIME,
		counterparty_id			INT					NOT NULL,
		contract_id				INT,
		prod_date_from			DATETIME			NOT NULL,
		prod_date_to			DATETIME			NOT NULL,	
		invoice_number			VARCHAR(1024)		NOT NULL,
		is_finalized			CHAR(1),
		finalized_date			DATETIME,
		is_locked				CHAR(1),
		invoice_status			INT,
		invoice_type			CHAR(1),
		invoice_note			VARCHAR(MAX),
		invoice_template_id		INT,
		payment_date			DATETIME,
		netting_invoice_id		INT,
		invoice_file_name		VARCHAR(1024),
		netting_file_name		VARCHAR(1024),
		is_voided				CHAR(1),
		description1			VARCHAR(MAX),
		description2			VARCHAR(MAX),
		description3			VARCHAR(MAX),
		description4			VARCHAR(MAX),
		description5			VARCHAR(MAX),
		create_user				VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts				DATETIME DEFAULT GETDATE(),		update_user				VARCHAR(128) NULL,
		update_ts				DATETIME NULL,		CONSTRAINT [PK_stmt_invoice] PRIMARY KEY CLUSTERED([stmt_invoice_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_invoice EXISTS'
END
GO



/*
 * [stmt_invoice_audit] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_invoice_audit]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_invoice_audit]
    (
		audit_id				INT IDENTITY(1, 1)	NOT NULL,
		stmt_invoice_id			INT					NOT NULL,
		as_of_date				DATETIME,
		counterparty_id			INT					NOT NULL,
		contract_id				INT,
		prod_date_from			DATETIME			NOT NULL,
		prod_date_to			DATETIME			NOT NULL,	
		invoice_number			VARCHAR(1024)		NOT NULL,
		is_finalized			CHAR(1),
		finalized_date			DATETIME,
		is_locked				CHAR(1),
		invoice_status			INT,
		invoice_type			CHAR(1),
		invoice_note			VARCHAR(MAX),
		invoice_template_id		INT,
		payment_date			DATETIME,
		netting_invoice_id		INT,
		invoice_file_name		VARCHAR(1024),
		netting_file_name		VARCHAR(1024),
		is_voided				CHAR(1),
		description1			VARCHAR(MAX),
		description2			VARCHAR(MAX),
		description3			VARCHAR(MAX),
		description4			VARCHAR(MAX),
		description5			VARCHAR(MAX),		user_action				CHAR(16),		create_user				VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts				DATETIME DEFAULT GETDATE(),		update_user				VARCHAR(128) NULL,
		update_ts				DATETIME NULL,		CONSTRAINT [PK_stmt_invoice_audit] PRIMARY KEY CLUSTERED([audit_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_invoice_audit EXISTS'
END
GO

IF COL_LENGTH('stmt_invoice','invoice_date') IS NULL
	ALTER TABLE stmt_invoice ADD invoice_date DATETIME
GO

IF COL_LENGTH('stmt_invoice_audit','invoice_date') IS NULL
	ALTER TABLE stmt_invoice_audit ADD invoice_date DATETIME
GO


/*
 * [stmt_invoice] - Insert Trigger
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_stmt_invoice]'))
    DROP TRIGGER [dbo].[TRGINS_stmt_invoice]
GO
 
CREATE TRIGGER [dbo].[TRGINS_stmt_invoice]
ON [dbo].[stmt_invoice]
FOR INSERT
AS
BEGIN
	INSERT INTO stmt_invoice_audit
	  (
	    stmt_invoice_id,
		as_of_date,
		counterparty_id,
		contract_id,
		prod_date_from,
		prod_date_to,
		invoice_number,
		is_finalized,
		finalized_date,
		is_locked,
		invoice_status,
		invoice_type,
		invoice_note,
		invoice_template_id,
		payment_date,
		netting_invoice_id,
		invoice_file_name,
		netting_file_name,
		is_voided,
		description1,
		description2,
		description3,
		description4,
		description5,
		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts,		invoice_date	  )
	SELECT 
		stmt_invoice_id,
		as_of_date,
		counterparty_id,
		contract_id,
		prod_date_from,
		prod_date_to,
		invoice_number,
		is_finalized,
		finalized_date,
		is_locked,
		invoice_status,
		invoice_type,
		invoice_note,
		invoice_template_id,
		payment_date,
		netting_invoice_id,
		invoice_file_name,
		netting_file_name,
		is_voided,
		description1,
		description2,
		description3,
		description4,
		description5,
		'insert',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts],
		invoice_date
	FROM  INSERTED
END
GO



/*
 * [stmt_invoice] - Update Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_invoice]'))
    DROP TRIGGER [dbo].[TRGUPD_stmt_invoice]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_invoice]
ON [dbo].[stmt_invoice]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.stmt_invoice
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.stmt_invoice sc
	       INNER JOIN DELETED u ON  sc.stmt_invoice_id = u.stmt_invoice_id  
	
	INSERT INTO stmt_invoice_audit
	  (
	    stmt_invoice_id,
		as_of_date,
		counterparty_id,
		contract_id,
		prod_date_from,
		prod_date_to,
		invoice_number,
		is_finalized,
		finalized_date,
		is_locked,
		invoice_status,
		invoice_type,
		invoice_note,
		invoice_template_id,
		payment_date,
		netting_invoice_id,
		invoice_file_name,
		netting_file_name,
		is_voided,
		description1,
		description2,
		description3,
		description4,
		description5,
		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts,		invoice_date	  )
	SELECT 
		stmt_invoice_id,
		as_of_date,
		counterparty_id,
		contract_id,
		prod_date_from,
		prod_date_to,
		invoice_number,
		is_finalized,
		finalized_date,
		is_locked,
		invoice_status,
		invoice_type,
		invoice_note,
		invoice_template_id,
		payment_date,
		netting_invoice_id,
		invoice_file_name,
		netting_file_name,
		is_voided,
		description1,
		description2,
		description3,
		description4,
		description5,
		'update' [user_action],
		[create_user],
		[create_ts],
	    @update_user,
		@update_ts,
		invoice_date
	FROM   INSERTED
END
GO



/*
 * [stmt_invoice] - Delete Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_stmt_invoice]'))
    DROP TRIGGER [dbo].[TRGDEL_stmt_invoice]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_stmt_invoice]
ON [dbo].[stmt_invoice]
FOR DELETE
AS
BEGIN
	INSERT INTO stmt_invoice_audit
	  (
	    stmt_invoice_id,
		as_of_date,
		counterparty_id,
		contract_id,
		prod_date_from,
		prod_date_to,
		invoice_number,
		is_finalized,
		finalized_date,
		is_locked,
		invoice_status,
		invoice_type,
		invoice_note,
		invoice_template_id,
		payment_date,
		netting_invoice_id,
		invoice_file_name,
		netting_file_name,
		is_voided,
		description1,
		description2,
		description3,
		description4,
		description5,
		user_action,
		create_user,
		create_ts,
		update_user,
		update_ts,		invoice_date	  )
	SELECT 
		stmt_invoice_id,
		as_of_date,
		counterparty_id,
		contract_id,
		prod_date_from,
		prod_date_to,
		invoice_number,
		is_finalized,
		finalized_date,
		is_locked,
		invoice_status,
		invoice_type,
		invoice_note,
		invoice_template_id,
		payment_date,
		netting_invoice_id,
		invoice_file_name,
		netting_file_name,
		is_voided,
		description1,
		description2,
		description3,
		description4,
		description5,
		'delete',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts],
		invoice_date
	FROM    DELETED
END