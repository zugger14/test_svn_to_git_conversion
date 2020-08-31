IF OBJECT_ID(N'[dbo].[spa_stmt_invoice_audit]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_stmt_invoice_audit]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 /**
	Select data for Invoice Audit Report

	Parameters :
	@flag : Flag 's'-- Select data from audit
	@invoice_id : Invoice Id (stmt_invoice_id FROM stmt_invoice_audit)
 */
CREATE PROCEDURE [dbo].[spa_stmt_invoice_audit]
    @flag CHAR(1),
    @invoice_id VARCHAR(MAX)
AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
    SELECT 
		stmt_invoice_id [Invoice ID]
		,dbo.FNADateFormat(as_of_date) [As of Date]
		,sc.counterparty_name [Counterparty Name]
		,cg.[contract_name] [Contract Name]
		,dbo.FNADateFormat(prod_date_from) [Delivery Date]
		,dbo.FNADateFormat(prod_date_to) [Delivery Date To]
		,invoice_number [Invoice Number]
		,CASE WHEN is_finalized = 'n' THEN 'No' WHEN is_finalized = 'f' THEN 'Yes' ELSE '' END [Finalized]
		,CASE WHEN is_finalized = 'n' THEN NULL ELSE finalized_date END [Finalized Date]
		,CASE WHEN is_locked = 'n' THEN 'No' WHEN is_locked = 'y' THEN 'Yes' ELSE '' END [Locked]
		,sdv.code [Invoice Status]
		,CASE WHEN payment_status = 'u' THEN 'Unpaid' WHEN payment_status = 'p' THEN 'Paid' ELSE '' END [Payment Status]
		,CASE invoice_type WHEN 'i' THEN 'Invoice' ELSE 'Remittance' END [Invoice Type]
		,invoice_note [Invoice Note]
		,description1 [Description1]
		,description2 [Description2]
		,description3 [Description3]
		,description4 [Description4]
		,description5 [Description5]
		,sia.create_user [Create User]
		,dbo.FNADateTimeFormat(sia.create_ts, 1) [Create TS]
		,sia.update_user [Update User]
		,dbo.FNADateTimeFormat(sia.update_ts, 1) [Update TS]
	FROM stmt_invoice_audit sia
	LEFT JOIN contract_group cg ON cg.contract_id = sia.contract_id
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sia.counterparty_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = sia.invoice_status AND sdv.[type_id] = 20700 
	WHERE stmt_invoice_id IN (SELECT scsv.item FROM dbo.SplitCommaSeperatedValues(@invoice_id) scsv)
		ORDER BY sia.stmt_invoice_id 
END