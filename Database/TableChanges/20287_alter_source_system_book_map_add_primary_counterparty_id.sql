
IF NOT EXISTS(
       SELECT 'X'
       FROM   INFORMATION_SCHEMA.COLUMNS
       WHERE  TABLE_NAME          = 'source_system_book_map'
              AND COLUMN_NAME     = 'primary_counterparty_id'
   )
BEGIN
    ALTER TABLE source_system_book_map ADD primary_counterparty_id INT NULL
END