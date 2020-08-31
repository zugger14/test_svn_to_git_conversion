IF NOT EXISTS(
       SELECT 'X'
       FROM   INFORMATION_SCHEMA.COLUMNS
       WHERE  TABLE_NAME = 'rec_generator_assignment'
              AND COLUMN_NAME = 'frequency'
   )
BEGIN
    ALTER TABLE rec_generator_assignment ADD frequency INT
END


IF COL_LENGTH('rec_generator_assignment', 'source_book_map_id') IS NULL
BEGIN
    ALTER TABLE rec_generator_assignment ADD source_book_map_id INT NULL
END
GO

