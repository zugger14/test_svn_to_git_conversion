IF NOT EXISTS(
       SELECT 'x'
       FROM   information_schema.columns
       WHERE  table_name LIKE 'fas_books_audit'
              AND column_name LIKE 'fun_cur_value_id'
   )
    ALTER TABLE [dbo].[fas_books_audit] ADD fun_cur_value_id INT 
GO

IF NOT EXISTS(
       SELECT 'x'
       FROM   information_schema.columns
       WHERE  table_name LIKE 'fas_books_audit'
              AND column_name LIKE 'hedge_item_same_sign'
   )
    ALTER TABLE [dbo].[fas_books_audit] ADD hedge_item_same_sign VARCHAR(1) 
GO

IF NOT EXISTS(
       SELECT 'x'
       FROM   information_schema.columns
       WHERE  table_name LIKE 'fas_strategy_audit'
              AND column_name LIKE 'fun_cur_value_id'
   )
    ALTER TABLE [dbo].[fas_strategy_audit] ADD fun_cur_value_id INT 
GO

IF NOT EXISTS(
       SELECT 'X'
       FROM   INFORMATION_SCHEMA.COLUMNS
       WHERE  TABLE_NAME = 'fas_subsidiaries_audit'
              AND COLUMN_NAME = 'counterparty_id'
   )
BEGIN
    ALTER TABLE fas_subsidiaries_audit ADD counterparty_id INT
END

