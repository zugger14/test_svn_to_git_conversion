IF NOT EXISTS(
       SELECT 'x'
       FROM   information_schema.columns
       WHERE  table_name LIKE 'fas_strategy'
              AND column_name LIKE 'fun_cur_value_id'
   )
    ALTER TABLE [dbo].[fas_strategy] ADD fun_cur_value_id INT 
GO

IF NOT EXISTS(
       SELECT 'X'
       FROM   INFORMATION_SCHEMA.COLUMNS
       WHERE  TABLE_NAME = 'fas_subsidiaries'
              AND COLUMN_NAME = 'counterparty_id'
   )
BEGIN
    ALTER TABLE fas_subsidiaries ADD counterparty_id INT
END

IF NOT EXISTS(
       SELECT 'x'
       FROM   information_schema.columns
       WHERE  table_name LIKE 'fas_books'
              AND column_name LIKE 'fun_cur_value_id'
   )
    ALTER TABLE [dbo].[fas_books] ADD fun_cur_value_id INT 
GO

IF NOT EXISTS(
       SELECT 'x'
       FROM   information_schema.columns
       WHERE  table_name LIKE 'fas_books'
              AND column_name LIKE 'hedge_item_same_sign'
   )
    ALTER TABLE [dbo].[fas_books] ADD hedge_item_same_sign VARCHAR(1) 
GO

IF COL_LENGTH('source_price_curve_def', 'monte_carlo_model_parameter_id') IS NULL
BEGIN
    ALTER TABLE source_price_curve_def ADD monte_carlo_model_parameter_id INT
END
GO