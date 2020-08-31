IF EXISTS (SELECT * 
     FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
     WHERE CONSTRAINT_NAME = 'UQ_index_source_book_mapping' AND TABLE_NAME = 'source_system_book_map'    
)
BEGIN 
 ALTER TABLE dbo.source_system_book_map 
 DROP CONSTRAINT UQ_index_source_book_mapping;
END

IF EXISTS (SELECT 1
     FROM sys.indexes 
     WHERE name = 'UQ_index_source_book_mapping' AND object_id = OBJECT_ID('source_system_book_map')
)
BEGIN 
	DROP INDEX UQ_index_source_book_mapping ON dbo.source_system_book_map
END

IF object_id('tempdb..#temp_data') IS NOT null		
	DROP TABLE #temp_data
CREATE TABLE #temp_data(book_deal_type_map_id INT)

INSERT INTO #temp_data
SELECT book_deal_type_map_id
FROM (
SELECT book_deal_type_map_id
,row_number() over(partition by source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4,effective_start_date,end_date order by create_ts) rnk
FROM source_system_book_map) a
WHERE a.rnk > 1

DELETE sbmgc
FROM   source_book_map_GL_codes sbmgc
INNER JOIN #temp_data td
	ON td.book_deal_type_map_id = sbmgc.source_book_map_id

DELETE sb 
FROM source_book sb
	INNER JOIN source_system_book_map  ssbm
		ON ssbm.source_system_book_id1 = sb.source_book_id
	INNER JOIN #temp_data td
			ON td.book_deal_type_map_id = ssbm.book_deal_type_map_id

DELETE ssbm
FROM   source_system_book_map ssbm
INNER JOIN #temp_data td
			ON td.book_deal_type_map_id = ssbm.book_deal_type_map_id

CREATE UNIQUE INDEX UQ_index_source_book_mapping
ON source_system_book_map (source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4,effective_start_date,end_date)

