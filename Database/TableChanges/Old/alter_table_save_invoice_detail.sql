
IF COL_LENGTH('save_invoice_detail', 'invoice_line_item_id') IS  NULL
BEGIN
	
    ALTER TABLE save_invoice_detail ADD  invoice_line_item_id INT NULL
    
END
ELSE
	PRINT 'Column invoice_line_item_id already not exists table save_invoice_deatail'
GO


IF COL_LENGTH('save_invoice_detail', 'order_by') IS  NULL
BEGIN
	
    ALTER TABLE save_invoice_detail ADD  order_by INT NULL
    
END
ELSE
	PRINT 'Column order_by already not exists table save_invoice_deatail'
GO