IF COL_LENGTH('transfer_mapping', 'sub_book') IS NULL
BEGIN
    ALTER TABLE transfer_mapping ADD sub_book INT REFERENCES source_system_book_map(book_deal_type_map_id)
END
GO