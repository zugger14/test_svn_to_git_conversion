UPDATE ssbm
SET    ssbm.logical_name = ISNULL(source_book.source_book_name, 'SBM') + '_' + CAST(ssbm.book_deal_type_map_id AS VARCHAR(20))
FROM   source_system_book_map ssbm
       LEFT JOIN portfolio_hierarchy book ON  book.entity_id = ssbm.fas_book_id
       LEFT JOIN source_book ON  ssbm.source_system_book_id1 = source_book.source_book_id
       LEFT JOIN source_book source_book_1 ON  ssbm.source_system_book_id2 = source_book_1.source_book_id
       LEFT JOIN source_book source_book_2 ON  ssbm.source_system_book_id3 = source_book_2.source_book_id
       LEFT JOIN source_book source_book_3 ON  ssbm.source_system_book_id4 = source_book_3.source_book_id
       LEFT JOIN static_data_value deal_type ON  ssbm.fas_deal_type_value_id = deal_type.value_id
--WHERE source_book.source_system_book_type_value_id = 50