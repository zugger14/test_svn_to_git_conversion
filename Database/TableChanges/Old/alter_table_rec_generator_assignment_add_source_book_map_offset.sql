IF COL_LENGTH('rec_generator_assignment', 'source_book_map_offset') IS NULL
BEGIN
    ALTER TABLE rec_generator_assignment ADD source_book_map_offset INT
END
GO