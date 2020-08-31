IF NOT EXISTS(SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'fas_books_audit' AND column_name LIKE 'fun_cur_value_id')
	ALTER TABLE [dbo].[fas_books_audit] ADD fun_cur_value_id INT 
GO
IF NOT EXISTS(SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'fas_books_audit' AND column_name LIKE 'hedge_item_same_sign')
	ALTER TABLE [dbo].[fas_books_audit] ADD hedge_item_same_sign varchar(1) 
GO

