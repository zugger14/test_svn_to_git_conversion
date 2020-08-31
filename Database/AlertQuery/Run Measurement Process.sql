select flh.link_id, flh.fas_book_id, rs_sdp.as_of_date 
INTO #fas_link_id
FROM staging_table.alert_link_process_id_al tmp
INNER JOIN fas_link_header flh ON flh.link_id = tmp.link_id
inner join fas_link_detail fld ON flh.link_id = fld.link_id
OUTER APPLY (
	SELECT source_deal_header_id, MAX(pnl_as_of_date) as_of_date from source_deal_pnl 
	where source_deal_header_id = fld.source_deal_header_id 
	GROUP BY source_deal_header_id
) rs_sdp
where 1 = 1
	AND fld.hedge_or_item = 'i'
	AND rs_sdp.as_of_date IS NOT NULL


SELECT  as_of_date, MAX(rs_link.link_id) link_id, MAX(rs_book.fas_book_id) fas_book_id
INTO #cur_link
FROM #fas_link_id rs_outer
OUTER APPLY (
	SELECT  STUFF((SELECT ',' + CAST(link_id AS VARCHAR(8)) FROM #fas_link_id rs_inner
				WHERE rs_inner.as_of_date = rs_outer.as_of_date
		        GROUP BY  rs_inner.link_id  
				ORDER BY rs_inner.link_id 		                       
	FOR XML PATH('')), 1, 1, '') link_id
) rs_link
OUTER APPLY (
	SELECT  STUFF((SELECT ',' + CAST(fas_book_id AS VARCHAR(8)) FROM #fas_link_id rs_inner
		WHERE rs_inner.as_of_date = rs_outer.as_of_date
		GROUP BY  rs_inner.fas_book_id  
		ORDER BY rs_inner.fas_book_id 		                       
	FOR XML PATH('')), 1, 1, '') fas_book_id
) rs_book
GROUP BY as_of_date


CREATE TABLE staging_table.alert_measurement_report_process_id_amr(
	[Valuation Date]				varchar(250),
	[Sub]							varchar(250),
	[Strategy]						varchar(250),	
	[Book]							varchar(250),	
	[Hedge Amount]					varchar(250),	
	[Item Amount]					varchar(250),	
	[ST Ast (Db)]					varchar(250),	
	[ST Liab (Cr)]					varchar(250),	
	[LT Ast (Db)]					varchar(250),	
	[LT Liab (Cr)]					varchar(250),	
	[AOCI  (+Cr/-Db)]				varchar(250),	
	[PNL (+Cr/-Db)]					varchar(250),	
	[Earnings (+Cr/-Db)]			varchar(250),		
	[Total Earnings (+Cr/-Db)]		varchar(250),	
	[Cash (-Cr/+Db)]				varchar(250)	
)
		

DECLARE @as_of_date DATETIME, @link_id VARCHAR(MAX), @fas_book_id VARCHAR(MAX)

DECLARE cursor1 CURSOR FOR 
	SELECT as_of_date, link_id, fas_book_id FROM #cur_link
OPEN cursor1
FETCH NEXT FROM cursor1 INTO @as_of_date, @link_id, @fas_book_id

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC spa_run_measurement_process_job NULL, 
		NULL, 
		@fas_book_id, 
		@as_of_date, NULL, NULL, NULL, 'farrms_admin', 0, 'n', @link_id

	INSERT INTO staging_table.alert_measurement_report_process_id_amr([Valuation Date]			
						, [Sub]						
						, [Strategy]					
						, [Book]						
						, [Hedge Amount]				
						, [Item Amount]				
						, [ST Ast (Db)]				
						, [ST Liab (Cr)]				
						, [LT Ast (Db)]				
						, [LT Liab (Cr)]				
						, [AOCI  (+Cr/-Db)]			
						, [PNL (+Cr/-Db)]				
						, [Earnings (+Cr/-Db)]		
						, [Total Earnings (+Cr/-Db)]	
						, [Cash (-Cr/+Db)]			
					)
	EXEC spa_Create_Hedges_Measurement_Report @as_of_date
		,NULL
		,NULL
		,@fas_book_id
		,'d',NULL,'c','s',@link_id,'2',NULL,'n',NULL,NULL,NULL,NULL,@link_id,NULL

FETCH NEXT FROM cursor1 
INTO @as_of_date, @link_id, @fas_book_id
		
END
CLOSE cursor1
DEALLOCATE cursor1


EXEC spa_insert_alert_output_status var_alert_sql_id, 'process_id', NULL, NULL, NULL