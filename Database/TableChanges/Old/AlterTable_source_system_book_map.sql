IF COL_LENGTH('source_system_book_map', 'logical_name') IS NULL
BEGIN
    ALTER TABLE source_system_book_map ADD logical_name VARCHAR(200) NULL
END
GO