SELECT  uddf.source_deal_header_id [Id],
        (sdv.code + ': ''' + uddf.udf_value) + '''' [udf]
INTO #temp       
FROM   source_deal_header sdh
       INNER JOIN user_defined_deal_fields uddf ON  uddf.source_deal_header_id = sdh.source_deal_header_id
       INNER JOIN user_defined_deal_fields_template udft ON  udft.udf_template_id = uddf.udf_template_id
       INNER JOIN static_data_value sdv ON  sdv.value_id = udft.field_name
     
SELECT Main.id,
       LEFT(
           Main.fld,
           CASE 
                WHEN LEN(Main.fld) -1 > 0 THEN LEN(Main.fld) -1
                ELSE 0
           END
       ) AS [udf]
INTO #udf_table       
FROM   (SELECT DISTINCT tt.id,
			(
              SELECT ISNULL(udf, NULL) + ', ' AS [text()]
              FROM   #temp t
              WHERE  t.id = tt.id
              ORDER BY t.id
              FOR XML PATH('')
			) [fld]
        FROM   #temp tt
        ) [Main]
WHERE Main.fld IS NOT NULL  
       
UPDATE mdv
SET UDF = t.udf,
mdv.deal_date_varchar = CONVERT(VARCHAR(100), mdv.deal_date, 120),
mdv.entire_term_start_varchar = CONVERT(VARCHAR(100), mdv.entire_term_start, 120),
mdv.entire_term_end_varchar = CONVERT(VARCHAR(100), mdv.entire_term_end, 120)  
FROM master_deal_view mdv
LEFT JOIN #udf_table t ON t.id = mdv.source_deal_header_id


DROP TABLE #temp
DROP TABLE #udf_table
--SELECT * FROM master_deal_view mdv
