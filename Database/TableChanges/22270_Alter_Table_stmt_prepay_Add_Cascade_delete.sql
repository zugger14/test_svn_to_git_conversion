IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_stmt_invoice_detail' AND parent_object_id = OBJECT_ID(N'[dbo].[stmt_prepay]'))
BEGIN
	ALTER TABLE stmt_prepay ADD CONSTRAINT FK_stmt_invoice_detail FOREIGN KEY (stmt_invoice_detail_id) REFERENCES stmt_invoice_detail(stmt_invoice_detail_id) ON DELETE CASCADE
END	