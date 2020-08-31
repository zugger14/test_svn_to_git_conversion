SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER TRIGGER [dbo].[TRGUPD_stmt_invoice]
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
		update_ts,		invoice_date,		payment_status	  )
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
		invoice_date,		payment_status
	FROM   INSERTED
END
