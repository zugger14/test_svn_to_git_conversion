UPDATE si SET 
	si.payment_date = dbo.FNAInvoiceDueDate( CASE WHEN cg.invoice_due_date = '20023'  OR cg.invoice_due_date = '20024' THEN si.finalized_date ELSE si.prod_date_from END, cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days),
	si.invoice_date = dbo.FNAInvoiceDueDate( CASE WHEN cg.settlement_date = '20023'  OR cg.settlement_date = '20024' THEN si.finalized_date ELSE si.prod_date_from END, cg.settlement_date, cg.holiday_calendar_id, cg.settlement_days)
FROM stmt_invoice si
INNER JOIN contract_group cg ON  cg.contract_id = si.contract_id

