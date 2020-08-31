IF COL_LENGTH('source_system_book_map', 'sub_book_group1') IS NULL
BEGIN
    ALTER TABLE source_system_book_map ADD sub_book_group1 INT
END
GO

IF COL_LENGTH('source_system_book_map', 'sub_book_group2') IS NULL
BEGIN
    ALTER TABLE source_system_book_map ADD sub_book_group2 INT
END
GO

IF COL_LENGTH('source_system_book_map', 'sub_book_group3') IS NULL
BEGIN
    ALTER TABLE source_system_book_map ADD sub_book_group3 INT
END
GO

IF COL_LENGTH('source_system_book_map', 'sub_book_group4') IS NULL
BEGIN
    ALTER TABLE source_system_book_map ADD sub_book_group4 INT
END

GO