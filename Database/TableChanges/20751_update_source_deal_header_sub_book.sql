UPDATE sdh SET sdh.sub_book = ssbm.book_deal_type_map_id
FROM source_deal_header sdh
INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
	AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
	AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
	AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
WHERE sdh.sub_book IS NULL