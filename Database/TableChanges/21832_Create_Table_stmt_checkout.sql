/*
 * [stmt_checkout] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_checkout]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_checkout]
    (
		stmt_checkout_id			INT IDENTITY(1, 1) NOT NULL,
		source_deal_detail_id		INT,		shipment_id					INT,		ticket_id					INT,		deal_charge_type_id			INT,		contract_charge_type_id		INT,		counterparty_id				INT				NOT NULL,		counterparty_name			VARCHAR(1024),		contract_id					INT,			as_of_date					DATETIME		NOT NULL,		term_start					DATETIME		NOT NULL,		term_end					DATETIME		NOT NULL,		currency_id					INT,		uom_id						INT,		settlement_amount			NUMERIC(32,20)	NOT NULL,		settlement_volume			NUMERIC(32,20)	NOT NULL,		settlement_price			NUMERIC(32,20)	NOT NULL,		scheduled_volume			NUMERIC(32,20),		acutal_volume				NUMERIC(32,20),		is_reverted					CHAR(1),		[status]					VARCHAR(128),				index_fees_id				INT				NOT NULL,		debit_gl_number				VARCHAR(1024),		credit_gl_number			VARCHAR(1024),		pnl_line_item_id			INT,		charge_type_alias			INT,		invoicing_charge_type_id	INT,		accrual_or_final			CHAR(1),		invoice_frequency			VARCHAR(128),		stmt_invoice_detail_id		INT,		create_user					VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts					DATETIME DEFAULT GETDATE(),		update_user					VARCHAR(128) NULL,
		update_ts					DATETIME NULL,		[type]						VARCHAR(100) NULL,		CONSTRAINT [PK_stmt_checkout] PRIMARY KEY CLUSTERED([stmt_checkout_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_checkout EXISTS'
END
GO



/*
 * [stmt_checkout_audit] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_checkout_audit]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_checkout_audit]
    (
		audit_id					INT IDENTITY(1, 1) NOT NULL,
		stmt_checkout_id			INT				NOT NULL, 
		source_deal_detail_id		INT,		shipment_id					INT,		ticket_id					INT,		deal_charge_type_id			INT,		contract_charge_type_id		INT,		counterparty_id				INT				NOT NULL,		counterparty_name			VARCHAR(1024),		contract_id					INT,			as_of_date					DATETIME		NOT NULL,		term_start					DATETIME		NOT NULL,		term_end					DATETIME		NOT NULL,		currency_id					INT,		uom_id						INT,		settlement_amount			NUMERIC(32,20)	NOT NULL,		settlement_volume			NUMERIC(32,20)	NOT NULL,		settlement_price			NUMERIC(32,20)	NOT NULL,		scheduled_volume			NUMERIC(32,20),		acutal_volume				NUMERIC(32,20),		is_reverted					CHAR(1),		[status]					VARCHAR(128),				index_fees_id				INT				NOT NULL,		debit_gl_number				VARCHAR(1024),		credit_gl_number			VARCHAR(1024),		pnl_line_item_id			INT,		charge_type_alias			INT,		invoicing_charge_type_id	INT,		accrual_or_final			CHAR(1),		invoice_frequency			VARCHAR(128),		stmt_invoice_detail_id		INT,		user_action					CHAR(16),		create_user					VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts					DATETIME DEFAULT GETDATE(),		update_user					VARCHAR(128) NULL,
		update_ts					DATETIME NULL,		[type]						VARCHAR(100) NULL,		CONSTRAINT [PK_stmt_checkout_audit] PRIMARY KEY CLUSTERED([audit_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_checkout_audit EXISTS'
END
GO


IF COL_LENGTH('stmt_checkout', 'type') IS NULL
BEGIN
    ALTER TABLE stmt_checkout ADD [type] VARCHAR(100) NULL
END
GO


IF COL_LENGTH('stmt_checkout_audit', 'type') IS NULL
BEGIN
    ALTER TABLE stmt_checkout_audit ADD [type] VARCHAR(100) NULL
END
GO

IF COL_LENGTH('stmt_checkout', 'match_info_id') IS NULL
BEGIN
	ALTER TABLE stmt_checkout ADD match_info_id INT
END

GO
IF COL_LENGTH('stmt_checkout_audit', 'match_info_id') IS NULL
BEGIN
	ALTER TABLE stmt_checkout_audit ADD match_info_id INT
END
GO


/*
 * [stmt_checkout] - Insert Trigger
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_stmt_checkout]'))
    DROP TRIGGER [dbo].[TRGINS_stmt_checkout]
GO
 
CREATE TRIGGER [dbo].[TRGINS_stmt_checkout]
ON [dbo].[stmt_checkout]
FOR INSERT
AS
BEGIN
	INSERT INTO stmt_checkout_audit
	  (
	    stmt_checkout_id,		source_deal_detail_id,		shipment_id,		ticket_id,		deal_charge_type_id,		contract_charge_type_id,		counterparty_id,		counterparty_name,		contract_id,		as_of_date,		term_start,		term_end,		currency_id,		uom_id,		settlement_amount,		settlement_volume,		settlement_price,		scheduled_volume,		acutal_volume,		is_reverted,		[status],		index_fees_id,		debit_gl_number,		credit_gl_number,		pnl_line_item_id,		charge_type_alias,		invoicing_charge_type_id,		accrual_or_final,		invoice_frequency,		stmt_invoice_detail_id,		user_action,		create_user,		create_ts,		update_user,		update_ts,		[type],		match_info_id	  )
	SELECT 
		stmt_checkout_id,
		source_deal_detail_id,		shipment_id,		ticket_id,		deal_charge_type_id,		contract_charge_type_id,		counterparty_id,		counterparty_name,		contract_id,		as_of_date,		term_start,		term_end,		currency_id,		uom_id,		settlement_amount,		settlement_volume,		settlement_price,		scheduled_volume,		acutal_volume,		is_reverted,		[status],		index_fees_id,		debit_gl_number,		credit_gl_number,		pnl_line_item_id,		charge_type_alias,		invoicing_charge_type_id,		accrual_or_final,		invoice_frequency,		stmt_invoice_detail_id,
		'insert',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts],
		[type],
		match_info_id
	FROM  INSERTED
END
GO



/*
 * [stmt_checkout] - Update Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_checkout]'))
    DROP TRIGGER [dbo].[TRGUPD_stmt_checkout]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_checkout]
ON [dbo].[stmt_checkout]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.stmt_checkout
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.stmt_checkout sc
	       INNER JOIN DELETED u ON  sc.stmt_checkout_id = u.stmt_checkout_id  
	
	INSERT INTO stmt_checkout_audit
	  (
		stmt_checkout_id,
	    source_deal_detail_id,		shipment_id,		ticket_id,		deal_charge_type_id,		contract_charge_type_id,		counterparty_id,		counterparty_name,		contract_id,		as_of_date,		term_start,		term_end,		currency_id,		uom_id,		settlement_amount,		settlement_volume,		settlement_price,		scheduled_volume,		acutal_volume,		is_reverted,		[status],		index_fees_id,		debit_gl_number,		credit_gl_number,		pnl_line_item_id,		charge_type_alias,		invoicing_charge_type_id,		accrual_or_final,		invoice_frequency,		stmt_invoice_detail_id,		user_action,		create_user,		create_ts,		update_user,		update_ts,
		[type],
		match_info_id
	  )
	SELECT 
		stmt_checkout_id,
		source_deal_detail_id,		shipment_id,		ticket_id,		deal_charge_type_id,		contract_charge_type_id,		counterparty_id,		counterparty_name,		contract_id,		as_of_date,		term_start,		term_end,		currency_id,		uom_id,		settlement_amount,		settlement_volume,		settlement_price,		scheduled_volume,		acutal_volume,		is_reverted,		[status],		index_fees_id,		debit_gl_number,		credit_gl_number,		pnl_line_item_id,		charge_type_alias,		invoicing_charge_type_id,		accrual_or_final,		invoice_frequency,		stmt_invoice_detail_id,
		'update' [user_action],
		[create_user],
		[create_ts],
	    @update_user,
		@update_ts,
		[type],
		match_info_id
	FROM   INSERTED
END
GO



/*
 * [stmt_checkout] - Delete Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_stmt_checkout]'))
    DROP TRIGGER [dbo].[TRGDEL_stmt_checkout]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_stmt_checkout]
ON [dbo].[stmt_checkout]
FOR DELETE
AS
BEGIN
	INSERT INTO stmt_checkout_audit
	  (
		stmt_checkout_id,
	    source_deal_detail_id,		shipment_id,		ticket_id,		deal_charge_type_id,		contract_charge_type_id,		counterparty_id,		counterparty_name,		contract_id,		as_of_date,		term_start,		term_end,		currency_id,		uom_id,		settlement_amount,		settlement_volume,		settlement_price,		scheduled_volume,		acutal_volume,		is_reverted,		[status],		index_fees_id,		debit_gl_number,		credit_gl_number,		pnl_line_item_id,		charge_type_alias,		invoicing_charge_type_id,		accrual_or_final,		invoice_frequency,		stmt_invoice_detail_id,		user_action,		create_user,		create_ts,		update_user,		update_ts,		[type],		match_info_id	  )
	SELECT 
		stmt_checkout_id,
		source_deal_detail_id,		shipment_id,		ticket_id,		deal_charge_type_id,		contract_charge_type_id,		counterparty_id,		counterparty_name,		contract_id,		as_of_date,		term_start,		term_end,		currency_id,		uom_id,		settlement_amount,		settlement_volume,		settlement_price,		scheduled_volume,		acutal_volume,		is_reverted,		[status],		index_fees_id,		debit_gl_number,		credit_gl_number,		pnl_line_item_id,		charge_type_alias,		invoicing_charge_type_id,		accrual_or_final,		invoice_frequency,		stmt_invoice_detail_id,
		'delete',
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts],
		[type],
		match_info_id
	FROM    DELETED
END