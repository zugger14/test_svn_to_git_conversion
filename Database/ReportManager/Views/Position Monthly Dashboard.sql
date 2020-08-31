BEGIN TRY
		BEGIN TRAN
	
	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Position Monthly Dashboard'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'PMD', description = 'Position  Monthly View for Dashboard Purpose'
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_as_of_date              VARCHAR(10) = ''@as_of_date'',
        @_tenor_option            CHAR(10) = ''@tenor_option'',	-- 1-Forward  / 2-Show All 
        @_term_start_from         VARCHAR(10) = ''@term_start_from'',
        @_term_start_to           VARCHAR(10) = ''@term_start_to'',
        @_commodity_id            VARCHAR(10) = ''@commodity_id'',
        @_counterparty_id         VARCHAR(1024) = ''@counterparty_id'',
        @_contract_id	         VARCHAR(1024) = ''@contract_id'',
        @_sql         VARCHAR(MAX)


IF @_term_start_to = ''NULL''
	SET @_term_start_to = null

IF @_tenor_option = ''1''
    SET @_term_start_from = @_as_of_date

IF @_tenor_option = ''2''  AND @_term_start_from= ''NULL''
BEGIN
    SET @_term_start_from = ''1900-01-01''
END

IF @_as_of_date IS NULL
   SET @_as_of_date = CONVERT(VARCHAR(10), GETDATE(), 126)


IF OBJECT_ID(N''tempdb..#books'', N''U'') IS NOT NULL
	DROP TABLE #books


IF OBJECT_ID(N''adiha_process.dbo.TRM_temp_position'', N''U'') IS NOT NULL
	DROP TABLE adiha_process.dbo.TRM_temp_position
IF OBJECT_ID(''tempdb..#books'') IS NOT NULL
	DROP TABLE tempdb..#books
	
CREATE TABLE #books
(
	book_deal_type_map_id      INT,
	fas_book_id                INT,
	source_system_book_id1     INT,
	source_system_book_id2     INT,
	source_system_book_id3     INT,
	source_system_book_id4     INT
)

SET @_sql =    ''
INSERT INTO #books
SELECT DISTINCT book_deal_type_map_id,
	book.entity_id
	, ssbm.source_system_book_id1
	, ssbm.source_system_book_id2
	, ssbm.source_system_book_id3
	, ssbm.source_system_book_id4 fas_book_id
FROM portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON book.parent_entity_id = stra.entity_id
INNER JOIN portfolio_hierarchy sub(NOLOCK) ON stra.parent_entity_id = sub.entity_id
INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id
WHERE ('''''' +
    CAST(''@sub_id'' AS VARCHAR(MAX)) + '''''' = ''''NULL''''
		OR sub.entity_id IN ('' + CAST(''@sub_id'' AS VARCHAR(MAX)) +
    '')
	) AND ('''''' + CAST(''@stra_id'' AS VARCHAR(MAX)) +
    '''''' = ''''NULL''''
		OR stra.entity_id IN ('' + CAST(''@stra_id'' AS VARCHAR(MAX)) +
    '')
	) AND ('''''' + CAST(''@book_id'' AS VARCHAR(MAX)) +
    ''''''= ''''NULL''''
		OR book.entity_id IN ('' + CAST(''@book_id'' AS VARCHAR(MAX)) +
    '')
	)AND ('''''' + CAST(''@sub_book_id'' AS VARCHAR(MAX)) +
    '''''' = ''''NULL''''
		OR ssbm.book_deal_type_map_id IN ('' + CAST(''@sub_book_id'' AS VARCHAR(MAX)) 
    + '')
		)
OPTION (MAXDOP 1)''

PRINT @_sql
EXEC (@_sql)
CREATE INDEX ix_pt_book ON #books(fas_book_id) INCLUDE(
                                                          source_system_book_id1,
                                                          source_system_book_id2,
                                                          source_system_book_id3,
                                                          source_system_book_id4
)



IF OBJECT_ID(''tempdb..#TRM_temp_position'') IS NOT NULL
	DROP TABLE tempdb..#TRM_temp_position

CREATE TABLE #TRM_temp_position
(
	term_start                DATETIME,
	book_deal_type_map_id     INT,
	commodity_id              INT,
	counterparty_id INT,
	contract_id INT,
	expiration_date           DATETIME,
	hr1                       NUMERIC(26, 10),
	hr2                       NUMERIC(26, 10),
	hr3                       NUMERIC(26, 10),
	hr4                       NUMERIC(26, 10),
	hr5                       NUMERIC(26, 10),
	hr6                       NUMERIC(26, 10),
	hr7                       NUMERIC(26, 10),
	hr8                       NUMERIC(26, 10),
	hr9                       NUMERIC(26, 10),
	hr10                      NUMERIC(26, 10),
	hr11                      NUMERIC(26, 10),
	hr12                      NUMERIC(26, 10),
	hr13                      NUMERIC(26, 10),
	hr14                      NUMERIC(26, 10),
	hr15                      NUMERIC(26, 10),
	hr16                      NUMERIC(26, 10),
	hr17                      NUMERIC(26, 10),
	hr18                      NUMERIC(26, 10),
	hr19                      NUMERIC(26, 10),
	hr20                      NUMERIC(26, 10),
	hr21                      NUMERIC(26, 10),
	hr22                      NUMERIC(26, 10),
	hr23                      NUMERIC(26, 10),
	hr24                      NUMERIC(26, 10),
	hr25                      NUMERIC(26, 10)
)

 SET @_sql=''INSERT INTO #TRM_temp_position(term_start,book_deal_type_map_id,commodity_id,counterparty_id,contract_id,expiration_date,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25) 
 SELECT s.term_start,
        bk.book_deal_type_map_id,
        s.commodity_id,
        s.counterparty_id,
        sdh.contract_id,
        s.expiration_date,
        CAST(SUM(s.hr1) AS NUMERIC(26, 10)) hr1,
        CAST(SUM(s.hr2) AS NUMERIC(26, 10)) hr2,
        CAST(SUM(s.hr3) AS NUMERIC(26, 10)) hr3,
        CAST(SUM(s.hr4) AS NUMERIC(26, 10)) hr4,
        CAST(SUM(s.hr5) AS NUMERIC(26, 10)) hr5,
        CAST(SUM(s.hr6) AS NUMERIC(26, 10)) hr6,
        CAST(SUM(s.hr7) AS NUMERIC(26, 10)) hr7,
        CAST(SUM(s.hr8) AS NUMERIC(26, 10)) hr8,
        CAST(SUM(s.hr9) AS NUMERIC(26, 10)) hr9,
        CAST(SUM(s.hr10) AS NUMERIC(26, 10)) hr10,
        CAST(SUM(s.hr11) AS NUMERIC(26, 10)) hr11,
        CAST(SUM(s.hr12) AS NUMERIC(26, 10)) hr12,
        CAST(SUM(s.hr13) AS NUMERIC(26, 10)) hr13,
        CAST(SUM(s.hr14) AS NUMERIC(26, 10)) hr14,
        CAST(SUM(s.hr15) AS NUMERIC(26, 10)) hr15,
        CAST(SUM(s.hr16) AS NUMERIC(26, 10)) hr16,
        CAST(SUM(s.hr17) AS NUMERIC(26, 10)) hr17,
        CAST(SUM(s.hr18) AS NUMERIC(26, 10)) hr18,
        CAST(SUM(s.hr19) AS NUMERIC(26, 10)) hr19,
        CAST(SUM(s.hr20) AS NUMERIC(26, 10)) hr20,
        CAST(SUM(s.hr21) AS NUMERIC(26, 10)) hr21,
        CAST(SUM(s.hr22) AS NUMERIC(26, 10)) hr22,
        CAST(SUM(s.hr23) AS NUMERIC(26, 10)) hr23,
        CAST(SUM(s.hr24) AS NUMERIC(26, 10)) hr24,
        CAST(SUM(s.hr25) AS NUMERIC(26, 10)) hr25
 FROM   report_hourly_position_profile s
        INNER JOIN [deal_status_group] dsg
        ON  dsg.status_value_id = s.deal_status_id --and 1=0
		INNER JOIN source_deal_header sdh on s.source_deal_header_id = sdh.source_deal_header_id                 
        INNER JOIN #books bk
             ON  bk.fas_book_id = s.fas_book_id
             AND bk.source_system_book_id1 = s.source_system_book_id1
             AND bk.source_system_book_id2 = s.source_system_book_id2
             AND bk.source_system_book_id3 = s.source_system_book_id3
             AND bk.source_system_book_id4 = s.source_system_book_id4
             where 1 = 1 ''
            + CASE WHEN @_tenor_option = ''1'' THEN '' AND s.term_start > '''''' + @_as_of_date + '''''''' ELSE '''' END
			+ CASE WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN '' AND s.term_start > '''''' + @_as_of_date + '''''' ''
				   WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) ''
				   WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
			       ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
			  END
			+ CASE WHEN @_commodity_id <> ''NULL'' THEN '' AND s.commodity_id = '' + @_commodity_id ELSE '''' END 
IF @_counterparty_id <> ''NULL''
	SET @_sql += '' AND s.counterparty_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_counterparty_id + '''''','''','''') f) ''
IF @_contract_id <> ''NULL''
	SET @_sql += '' AND sdh.contract_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_contract_id + '''''','''','''') f) ''
SET @_sql += '' GROUP BY
			s.commodity_id,
			s.[term_start],
			bk.book_deal_type_map_id,
			s.counterparty_id,
			sdh.contract_id,
			s.expiration_date''
PRINT (@_sql)
EXEC (@_sql)


 SET @_sql=''INSERT INTO #TRM_temp_position
            SELECT s.term_start,
                   bk.book_deal_type_map_id,
                   s.commodity_id,
                   s.counterparty_id,
                   sdh.contract_id,
                   s.expiration_date,
                   CAST(SUM(s.hr1) AS NUMERIC(26, 10)) hr1,
                   CAST(SUM(s.hr2) AS NUMERIC(26, 10)) hr2,
                   CAST(SUM(s.hr3) AS NUMERIC(26, 10)) hr3,
                   CAST(SUM(s.hr4) AS NUMERIC(26, 10)) hr4,
                   CAST(SUM(s.hr5) AS NUMERIC(26, 10)) hr5,
                   CAST(SUM(s.hr6) AS NUMERIC(26, 10)) hr6,
                   CAST(SUM(s.hr7) AS NUMERIC(26, 10)) hr7,
                   CAST(SUM(s.hr8) AS NUMERIC(26, 10)) hr8,
                   CAST(SUM(s.hr9) AS NUMERIC(26, 10)) hr9,
                   CAST(SUM(s.hr10) AS NUMERIC(26, 10)) hr10,
                   CAST(SUM(s.hr11) AS NUMERIC(26, 10)) hr11,
                   CAST(SUM(s.hr12) AS NUMERIC(26, 10)) hr12,
                   CAST(SUM(s.hr13) AS NUMERIC(26, 10)) hr13,
                   CAST(SUM(s.hr14) AS NUMERIC(26, 10)) hr14,
                   CAST(SUM(s.hr15) AS NUMERIC(26, 10)) hr15,
                   CAST(SUM(s.hr16) AS NUMERIC(26, 10)) hr16,
                   CAST(SUM(s.hr17) AS NUMERIC(26, 10)) hr17,
                   CAST(SUM(s.hr18) AS NUMERIC(26, 10)) hr18,
                   CAST(SUM(s.hr19) AS NUMERIC(26, 10)) hr19,
                   CAST(SUM(s.hr20) AS NUMERIC(26, 10)) hr20,
                   CAST(SUM(s.hr21) AS NUMERIC(26, 10)) hr21,
                   CAST(SUM(s.hr22) AS NUMERIC(26, 10)) hr22,
                   CAST(SUM(s.hr23) AS NUMERIC(26, 10)) hr23,
                   CAST(SUM(s.hr24) AS NUMERIC(26, 10)) hr24,
                   CAST(SUM(s.hr25) AS NUMERIC(26, 10)) hr25
            FROM   report_hourly_position_deal s
                   INNER JOIN [deal_status_group] dsg
                        ON  dsg.status_value_id = s.deal_status_id -- and 1=0
                   INNER JOIN source_deal_header sdh on s.source_deal_header_id = sdh.source_deal_header_id         
                   INNER JOIN #books bk
                        ON  bk.fas_book_id = s.fas_book_id
                        AND bk.source_system_book_id1 = s.source_system_book_id1
                        AND bk.source_system_book_id2 = s.source_system_book_id2
                        AND bk.source_system_book_id3 = s.source_system_book_id3
                        AND bk.source_system_book_id4 = s.source_system_book_id4
            where 1 = 1 ''
            + CASE WHEN @_tenor_option = ''1'' THEN '' AND s.term_start > '''''' + @_as_of_date + '''''''' ELSE '''' END
			+ CASE WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN '' AND s.term_start > '''''' + @_as_of_date + '''''' ''
				   WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) ''
				   WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
			       ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
			  END
			+ CASE WHEN @_commodity_id <> ''NULL'' THEN '' AND s.commodity_id = '' + @_commodity_id ELSE '''' END 
			
	IF @_counterparty_id <> ''NULL''
		SET @_sql += '' AND s.counterparty_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_counterparty_id + '''''','''','''') f) ''
	IF @_contract_id <> ''NULL''
		SET @_sql += '' AND sdh.contract_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_contract_id + '''''','''','''') f) ''	
    SET @_sql += '' GROUP BY
                s.term_start,
                bk.book_deal_type_map_id,
                s.commodity_id,
                s.counterparty_id,
                sdh.contract_id,
                s.expiration_date''

PRINT (@_sql)
EXEC (@_sql) 


-- For weighted average price 

IF OBJECT_ID (''tempdb..#weighted_price'') IS NOT NULL
	DROP TABLE tempdb..#weighted_price
	
CREATE TABLE #weighted_price
(
	 term_start DATETIME,
	 weighted_price NUMERIC(26, 10),
	 contract_id INT,
	 counterparty_id INT
	)
SET @_sql = ''
INSERT INTO #weighted_price
SELECT calc.term_start, CASE WHEN SUM(calc.Volume) <> 0 THEN  SUM(calc.Total) / SUM(calc.Volume) ELSE MAX(price) END  [weighted_avg_price],  calc.contract_id, calc.counterparty_id
FROM   (
           SELECT sdd.source_deal_header_id,
                  CONVERT(VARCHAR(07), sdd.term_start, 120) + ''''-01'''' [term_start],
                  SUM(sdd.total_volume * CASE sdd.buy_sell_flag WHEN ''''s'''' THEN -1 ELSE 1 END) Volume,
                  ISNULL(AVG(fixed_price), 0) price,SUM(sdd.total_volume * CASE sdd.buy_sell_flag WHEN ''''s'''' THEN -1 ELSE 1 END) * ISNULL(AVG(fixed_price), 0) [Total],
                  sdh.counterparty_id, sdh.contract_id
           FROM   source_deal_header sdh
                  INNER JOIN #books bk
                       ON  bk.source_system_book_id1 = sdh.source_system_book_id1
                       AND bk.source_system_book_id2 = sdh.source_system_book_id2
                       AND bk.source_system_book_id3 = sdh.source_system_book_id3
                       AND bk.source_system_book_id4 = sdh.source_system_book_id4
                  INNER JOIN source_system_book_map ssbm
                       ON  bk.fas_book_id = ssbm.fas_book_id
                  INNER JOIN deal_status_group dsg
                       ON  sdh.deal_status = dsg.status_value_id
                  INNER JOIN source_deal_detail sdd
                       ON  sdh.source_deal_header_id = sdd.source_deal_header_id
                  LEFT JOIN source_price_curve_def spcd
                       ON  sdd.curve_id = spcd.source_curve_def_id 
           WHERE 1 = 1 ''  + CASE WHEN @_tenor_option = ''1'' THEN '' AND sdd.term_start > '''''' + @_as_of_date + '''''''' ELSE '''' END
			+ CASE WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN '' AND sdd.term_start > '''''' + @_as_of_date + '''''' ''
				   WHEN @_term_start_to IS NULL THEN '' AND sdd.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) ''
				   WHEN @_term_start_from IS NULL THEN '' AND sdd.term_start =< CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
			       ELSE '' AND sdd.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
			  END
			  
            IF @_commodity_id <> ''NULL''
				SET @_sql += '' AND sdh.commodity_id = '' + @_commodity_id 
			
			IF @_counterparty_id <> ''NULL''
				SET @_sql += '' AND sdh.counterparty_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_counterparty_id + '''''','''','''') f) ''
			IF @_contract_id <> ''NULL''
				SET @_sql += '' AND sdh.contract_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_contract_id + '''''','''','''') f) ''
					
         SET @_sql += '' GROUP BY
                  sdd.source_deal_header_id,sdh.counterparty_id, sdh.contract_id,
                  CONVERT(VARCHAR(07), sdd.term_start, 120) + ''''-01''''
       ) calc
GROUP BY
       calc.term_start, calc.counterparty_id, calc.contract_id ''
       EXEC(@_sql)

CREATE INDEX  indx_temp_position_11 ON  #TRM_temp_position(term_start,expiration_date)
	INCLUDE (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)

SELECT sub.entity_name subsidairy,
       CONVERT(VARCHAR(7), unpvt.term_start, 120) + ''-01'' term_start,
       SUM(unpvt.Volume) [Position], ''@sub_id'' sub_id, ''@stra_id'' stra_id, ''@book_id'' book_id, ''@sub_book_id'' sub_book_id,
       @_tenor_option tenor_option, unpvt.commodity_id commodity_id, unpvt.counterparty_id counterparty_id,
       @_term_start_from term_start_from, @_term_start_to term_start_to,@_as_of_date as_of_date,  unpvt.contract_id [contract_id], contract_name,MAX(wp.weighted_price) [monthly_weighted_price]
 --[__batch_report__]
 FROM ( 
	SELECT 
		  s.commodity_id,
		  s.term_start,
		  s.book_deal_type_map_id,
		  s.counterparty_id,
		  s.contract_id,
		  cg.contract_name,
		  CAST(SUM( s.hr1) AS NUMERIC(38,20)) [1]	, CAST(SUM( s.hr2) AS NUMERIC(38,20)) [2],
		  CAST(SUM( s.hr3  - CASE WHEN NOT (s.commodity_id = -1) THEN ISNULL(s.hr25, 0) ELSE 0 END) AS NUMERIC(38,20)) [3],
		  CAST(SUM( s.hr4) AS NUMERIC(38,20)) [4]	, CAST(SUM( s.hr5) AS NUMERIC(38,20)) [5],
		  CAST(SUM( s.hr6 ) AS NUMERIC(38,20)) [6]	, CAST(SUM( s.hr7) AS NUMERIC(38,20)) [7],
		  CAST(SUM( s.hr8) AS NUMERIC(38,20)) [8]	, CAST(SUM( s.hr9) AS NUMERIC(38,20)) [9],
		  CAST(SUM( s.hr10) AS NUMERIC(38,20)) [10]	, CAST(SUM( s.hr11) AS NUMERIC(38,20)) [11],
		  CAST(SUM( s.hr12) AS NUMERIC(38,20)) [12]	, CAST(SUM( s.hr13) AS NUMERIC(38,20)) [13],
		  CAST(SUM( s.hr14) AS NUMERIC(38,20)) [14]	, CAST(SUM( s.hr15) AS NUMERIC(38,20)) [15],
		  CAST(SUM( s.hr16) AS NUMERIC(38,20)) [16]	, CAST(SUM( s.hr17) AS NUMERIC(38,20)) [17],
		  CAST(SUM( s.hr18) AS NUMERIC(38,20)) [18],
		  CAST(SUM( s.hr19) AS NUMERIC(38,20)) [19]	, CAST(SUM( s.hr20) AS NUMERIC(38,20)) [20],
		  CAST(SUM( s.hr21  - CASE WHEN s.commodity_id = -1 THEN ISNULL(s.hr25, 0) ELSE 0 END) AS NUMERIC(38,20)) [21],
		  CAST(SUM( s.hr22) AS NUMERIC(38,20)) [22]	, CAST(SUM( s.hr23) AS NUMERIC(38,20)) [23],
		  CAST(SUM( s.hr24) AS NUMERIC(38,20)) [24]	, CAST(SUM(s.hr25) AS NUMERIC(38,20)) [25]		
	FROM #TRM_temp_position s 
	LEFT JOIN contract_group cg ON s.contract_id = cg.contract_id
	 where s.term_start > @_term_start_from
	GROUP BY s.commodity_id,
		  s.term_start,
		  s.book_deal_type_map_id,
		  s.counterparty_id,
		  s.contract_id,
		  cg.contract_name
) p
UNPIVOT
	(Volume FOR [Hr] IN
		([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25])
	) AS unpvt
	
	LEFT JOIN mv90_DST dst ON dst.[date] = unpvt.term_start 
			AND dst.insert_delete = ''''''d''''''
	INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = unpvt.book_deal_type_map_id
	INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id AND book.hierarchy_level = 0
	INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
	INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2		
	LEFT JOIN #weighted_price wp ON CONVERT(VARCHAR(7), unpvt.term_start, 120) + ''-01'' = wp.term_start	
	AND wp.contract_id = unpvt.contract_id AND wp.counterparty_id = unpvt.counterparty_id
	WHERE  NOT (unpvt.hr=25 AND unpvt.Volume=0) 
		   AND ISNULL(dst.[hour],99) <> CASE WHEN unpvt.commodity_id=-1 THEN 1
           ELSE CASE WHEN unpvt.hr = 25 THEN 3 ELSE unpvt.hr END END
    GROUP BY 
            sub.entity_name 
          ,unpvt.counterparty_id
          ,unpvt.contract_id 
		  , unpvt.commodity_id
		  , CONVERT(VARCHAR(7),unpvt.term_start,120), contract_name
	ORDER BY   sub.entity_name , CONVERT(VARCHAR(7),unpvt.term_start,120)', report_id = @report_id_data_source_dest 
		WHERE [name] = 'Position Monthly Dashboard'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Position Monthly Dashboard'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'Position Monthly Dashboard' AS [name], 'PMD' AS ALIAS, 'Position  Monthly View for Dashboard Purpose' AS [description],'DECLARE @_as_of_date              VARCHAR(10) = ''@as_of_date'',
        @_tenor_option            CHAR(10) = ''@tenor_option'',	-- 1-Forward  / 2-Show All 
        @_term_start_from         VARCHAR(10) = ''@term_start_from'',
        @_term_start_to           VARCHAR(10) = ''@term_start_to'',
        @_commodity_id            VARCHAR(10) = ''@commodity_id'',
        @_counterparty_id         VARCHAR(1024) = ''@counterparty_id'',
        @_contract_id	         VARCHAR(1024) = ''@contract_id'',
        @_sql         VARCHAR(MAX)


IF @_term_start_to = ''NULL''
	SET @_term_start_to = null

IF @_tenor_option = ''1''
    SET @_term_start_from = @_as_of_date

IF @_tenor_option = ''2''  AND @_term_start_from= ''NULL''
BEGIN
    SET @_term_start_from = ''1900-01-01''
END

IF @_as_of_date IS NULL
   SET @_as_of_date = CONVERT(VARCHAR(10), GETDATE(), 126)


IF OBJECT_ID(N''tempdb..#books'', N''U'') IS NOT NULL
	DROP TABLE #books


IF OBJECT_ID(N''adiha_process.dbo.TRM_temp_position'', N''U'') IS NOT NULL
	DROP TABLE adiha_process.dbo.TRM_temp_position
IF OBJECT_ID(''tempdb..#books'') IS NOT NULL
	DROP TABLE tempdb..#books
	
CREATE TABLE #books
(
	book_deal_type_map_id      INT,
	fas_book_id                INT,
	source_system_book_id1     INT,
	source_system_book_id2     INT,
	source_system_book_id3     INT,
	source_system_book_id4     INT
)

SET @_sql =    ''
INSERT INTO #books
SELECT DISTINCT book_deal_type_map_id,
	book.entity_id
	, ssbm.source_system_book_id1
	, ssbm.source_system_book_id2
	, ssbm.source_system_book_id3
	, ssbm.source_system_book_id4 fas_book_id
FROM portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON book.parent_entity_id = stra.entity_id
INNER JOIN portfolio_hierarchy sub(NOLOCK) ON stra.parent_entity_id = sub.entity_id
INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id
WHERE ('''''' +
    CAST(''@sub_id'' AS VARCHAR(MAX)) + '''''' = ''''NULL''''
		OR sub.entity_id IN ('' + CAST(''@sub_id'' AS VARCHAR(MAX)) +
    '')
	) AND ('''''' + CAST(''@stra_id'' AS VARCHAR(MAX)) +
    '''''' = ''''NULL''''
		OR stra.entity_id IN ('' + CAST(''@stra_id'' AS VARCHAR(MAX)) +
    '')
	) AND ('''''' + CAST(''@book_id'' AS VARCHAR(MAX)) +
    ''''''= ''''NULL''''
		OR book.entity_id IN ('' + CAST(''@book_id'' AS VARCHAR(MAX)) +
    '')
	)AND ('''''' + CAST(''@sub_book_id'' AS VARCHAR(MAX)) +
    '''''' = ''''NULL''''
		OR ssbm.book_deal_type_map_id IN ('' + CAST(''@sub_book_id'' AS VARCHAR(MAX)) 
    + '')
		)
OPTION (MAXDOP 1)''

PRINT @_sql
EXEC (@_sql)
CREATE INDEX ix_pt_book ON #books(fas_book_id) INCLUDE(
                                                          source_system_book_id1,
                                                          source_system_book_id2,
                                                          source_system_book_id3,
                                                          source_system_book_id4
)



IF OBJECT_ID(''tempdb..#TRM_temp_position'') IS NOT NULL
	DROP TABLE tempdb..#TRM_temp_position

CREATE TABLE #TRM_temp_position
(
	term_start                DATETIME,
	book_deal_type_map_id     INT,
	commodity_id              INT,
	counterparty_id INT,
	contract_id INT,
	expiration_date           DATETIME,
	hr1                       NUMERIC(26, 10),
	hr2                       NUMERIC(26, 10),
	hr3                       NUMERIC(26, 10),
	hr4                       NUMERIC(26, 10),
	hr5                       NUMERIC(26, 10),
	hr6                       NUMERIC(26, 10),
	hr7                       NUMERIC(26, 10),
	hr8                       NUMERIC(26, 10),
	hr9                       NUMERIC(26, 10),
	hr10                      NUMERIC(26, 10),
	hr11                      NUMERIC(26, 10),
	hr12                      NUMERIC(26, 10),
	hr13                      NUMERIC(26, 10),
	hr14                      NUMERIC(26, 10),
	hr15                      NUMERIC(26, 10),
	hr16                      NUMERIC(26, 10),
	hr17                      NUMERIC(26, 10),
	hr18                      NUMERIC(26, 10),
	hr19                      NUMERIC(26, 10),
	hr20                      NUMERIC(26, 10),
	hr21                      NUMERIC(26, 10),
	hr22                      NUMERIC(26, 10),
	hr23                      NUMERIC(26, 10),
	hr24                      NUMERIC(26, 10),
	hr25                      NUMERIC(26, 10)
)

 SET @_sql=''INSERT INTO #TRM_temp_position(term_start,book_deal_type_map_id,commodity_id,counterparty_id,contract_id,expiration_date,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25) 
 SELECT s.term_start,
        bk.book_deal_type_map_id,
        s.commodity_id,
        s.counterparty_id,
        sdh.contract_id,
        s.expiration_date,
        CAST(SUM(s.hr1) AS NUMERIC(26, 10)) hr1,
        CAST(SUM(s.hr2) AS NUMERIC(26, 10)) hr2,
        CAST(SUM(s.hr3) AS NUMERIC(26, 10)) hr3,
        CAST(SUM(s.hr4) AS NUMERIC(26, 10)) hr4,
        CAST(SUM(s.hr5) AS NUMERIC(26, 10)) hr5,
        CAST(SUM(s.hr6) AS NUMERIC(26, 10)) hr6,
        CAST(SUM(s.hr7) AS NUMERIC(26, 10)) hr7,
        CAST(SUM(s.hr8) AS NUMERIC(26, 10)) hr8,
        CAST(SUM(s.hr9) AS NUMERIC(26, 10)) hr9,
        CAST(SUM(s.hr10) AS NUMERIC(26, 10)) hr10,
        CAST(SUM(s.hr11) AS NUMERIC(26, 10)) hr11,
        CAST(SUM(s.hr12) AS NUMERIC(26, 10)) hr12,
        CAST(SUM(s.hr13) AS NUMERIC(26, 10)) hr13,
        CAST(SUM(s.hr14) AS NUMERIC(26, 10)) hr14,
        CAST(SUM(s.hr15) AS NUMERIC(26, 10)) hr15,
        CAST(SUM(s.hr16) AS NUMERIC(26, 10)) hr16,
        CAST(SUM(s.hr17) AS NUMERIC(26, 10)) hr17,
        CAST(SUM(s.hr18) AS NUMERIC(26, 10)) hr18,
        CAST(SUM(s.hr19) AS NUMERIC(26, 10)) hr19,
        CAST(SUM(s.hr20) AS NUMERIC(26, 10)) hr20,
        CAST(SUM(s.hr21) AS NUMERIC(26, 10)) hr21,
        CAST(SUM(s.hr22) AS NUMERIC(26, 10)) hr22,
        CAST(SUM(s.hr23) AS NUMERIC(26, 10)) hr23,
        CAST(SUM(s.hr24) AS NUMERIC(26, 10)) hr24,
        CAST(SUM(s.hr25) AS NUMERIC(26, 10)) hr25
 FROM   report_hourly_position_profile s
        INNER JOIN [deal_status_group] dsg
        ON  dsg.status_value_id = s.deal_status_id --and 1=0
		INNER JOIN source_deal_header sdh on s.source_deal_header_id = sdh.source_deal_header_id                 
        INNER JOIN #books bk
             ON  bk.fas_book_id = s.fas_book_id
             AND bk.source_system_book_id1 = s.source_system_book_id1
             AND bk.source_system_book_id2 = s.source_system_book_id2
             AND bk.source_system_book_id3 = s.source_system_book_id3
             AND bk.source_system_book_id4 = s.source_system_book_id4
             where 1 = 1 ''
            + CASE WHEN @_tenor_option = ''1'' THEN '' AND s.term_start > '''''' + @_as_of_date + '''''''' ELSE '''' END
			+ CASE WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN '' AND s.term_start > '''''' + @_as_of_date + '''''' ''
				   WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) ''
				   WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
			       ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
			  END
			+ CASE WHEN @_commodity_id <> ''NULL'' THEN '' AND s.commodity_id = '' + @_commodity_id ELSE '''' END 
IF @_counterparty_id <> ''NULL''
	SET @_sql += '' AND s.counterparty_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_counterparty_id + '''''','''','''') f) ''
IF @_contract_id <> ''NULL''
	SET @_sql += '' AND sdh.contract_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_contract_id + '''''','''','''') f) ''
SET @_sql += '' GROUP BY
			s.commodity_id,
			s.[term_start],
			bk.book_deal_type_map_id,
			s.counterparty_id,
			sdh.contract_id,
			s.expiration_date''
PRINT (@_sql)
EXEC (@_sql)


 SET @_sql=''INSERT INTO #TRM_temp_position
            SELECT s.term_start,
                   bk.book_deal_type_map_id,
                   s.commodity_id,
                   s.counterparty_id,
                   sdh.contract_id,
                   s.expiration_date,
                   CAST(SUM(s.hr1) AS NUMERIC(26, 10)) hr1,
                   CAST(SUM(s.hr2) AS NUMERIC(26, 10)) hr2,
                   CAST(SUM(s.hr3) AS NUMERIC(26, 10)) hr3,
                   CAST(SUM(s.hr4) AS NUMERIC(26, 10)) hr4,
                   CAST(SUM(s.hr5) AS NUMERIC(26, 10)) hr5,
                   CAST(SUM(s.hr6) AS NUMERIC(26, 10)) hr6,
                   CAST(SUM(s.hr7) AS NUMERIC(26, 10)) hr7,
                   CAST(SUM(s.hr8) AS NUMERIC(26, 10)) hr8,
                   CAST(SUM(s.hr9) AS NUMERIC(26, 10)) hr9,
                   CAST(SUM(s.hr10) AS NUMERIC(26, 10)) hr10,
                   CAST(SUM(s.hr11) AS NUMERIC(26, 10)) hr11,
                   CAST(SUM(s.hr12) AS NUMERIC(26, 10)) hr12,
                   CAST(SUM(s.hr13) AS NUMERIC(26, 10)) hr13,
                   CAST(SUM(s.hr14) AS NUMERIC(26, 10)) hr14,
                   CAST(SUM(s.hr15) AS NUMERIC(26, 10)) hr15,
                   CAST(SUM(s.hr16) AS NUMERIC(26, 10)) hr16,
                   CAST(SUM(s.hr17) AS NUMERIC(26, 10)) hr17,
                   CAST(SUM(s.hr18) AS NUMERIC(26, 10)) hr18,
                   CAST(SUM(s.hr19) AS NUMERIC(26, 10)) hr19,
                   CAST(SUM(s.hr20) AS NUMERIC(26, 10)) hr20,
                   CAST(SUM(s.hr21) AS NUMERIC(26, 10)) hr21,
                   CAST(SUM(s.hr22) AS NUMERIC(26, 10)) hr22,
                   CAST(SUM(s.hr23) AS NUMERIC(26, 10)) hr23,
                   CAST(SUM(s.hr24) AS NUMERIC(26, 10)) hr24,
                   CAST(SUM(s.hr25) AS NUMERIC(26, 10)) hr25
            FROM   report_hourly_position_deal s
                   INNER JOIN [deal_status_group] dsg
                        ON  dsg.status_value_id = s.deal_status_id -- and 1=0
                   INNER JOIN source_deal_header sdh on s.source_deal_header_id = sdh.source_deal_header_id         
                   INNER JOIN #books bk
                        ON  bk.fas_book_id = s.fas_book_id
                        AND bk.source_system_book_id1 = s.source_system_book_id1
                        AND bk.source_system_book_id2 = s.source_system_book_id2
                        AND bk.source_system_book_id3 = s.source_system_book_id3
                        AND bk.source_system_book_id4 = s.source_system_book_id4
            where 1 = 1 ''
            + CASE WHEN @_tenor_option = ''1'' THEN '' AND s.term_start > '''''' + @_as_of_date + '''''''' ELSE '''' END
			+ CASE WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN '' AND s.term_start > '''''' + @_as_of_date + '''''' ''
				   WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) ''
				   WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
			       ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
			  END
			+ CASE WHEN @_commodity_id <> ''NULL'' THEN '' AND s.commodity_id = '' + @_commodity_id ELSE '''' END 
			
	IF @_counterparty_id <> ''NULL''
		SET @_sql += '' AND s.counterparty_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_counterparty_id + '''''','''','''') f) ''
	IF @_contract_id <> ''NULL''
		SET @_sql += '' AND sdh.contract_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_contract_id + '''''','''','''') f) ''	
    SET @_sql += '' GROUP BY
                s.term_start,
                bk.book_deal_type_map_id,
                s.commodity_id,
                s.counterparty_id,
                sdh.contract_id,
                s.expiration_date''

PRINT (@_sql)
EXEC (@_sql) 


-- For weighted average price 

IF OBJECT_ID (''tempdb..#weighted_price'') IS NOT NULL
	DROP TABLE tempdb..#weighted_price
	
CREATE TABLE #weighted_price
(
	 term_start DATETIME,
	 weighted_price NUMERIC(26, 10),
	 contract_id INT,
	 counterparty_id INT
	)
SET @_sql = ''
INSERT INTO #weighted_price
SELECT calc.term_start, CASE WHEN SUM(calc.Volume) <> 0 THEN  SUM(calc.Total) / SUM(calc.Volume) ELSE MAX(price) END  [weighted_avg_price],  calc.contract_id, calc.counterparty_id
FROM   (
           SELECT sdd.source_deal_header_id,
                  CONVERT(VARCHAR(07), sdd.term_start, 120) + ''''-01'''' [term_start],
                  SUM(sdd.total_volume * CASE sdd.buy_sell_flag WHEN ''''s'''' THEN -1 ELSE 1 END) Volume,
                  ISNULL(AVG(fixed_price), 0) price,SUM(sdd.total_volume * CASE sdd.buy_sell_flag WHEN ''''s'''' THEN -1 ELSE 1 END) * ISNULL(AVG(fixed_price), 0) [Total],
                  sdh.counterparty_id, sdh.contract_id
           FROM   source_deal_header sdh
                  INNER JOIN #books bk
                       ON  bk.source_system_book_id1 = sdh.source_system_book_id1
                       AND bk.source_system_book_id2 = sdh.source_system_book_id2
                       AND bk.source_system_book_id3 = sdh.source_system_book_id3
                       AND bk.source_system_book_id4 = sdh.source_system_book_id4
                  INNER JOIN source_system_book_map ssbm
                       ON  bk.fas_book_id = ssbm.fas_book_id
                  INNER JOIN deal_status_group dsg
                       ON  sdh.deal_status = dsg.status_value_id
                  INNER JOIN source_deal_detail sdd
                       ON  sdh.source_deal_header_id = sdd.source_deal_header_id
                  LEFT JOIN source_price_curve_def spcd
                       ON  sdd.curve_id = spcd.source_curve_def_id 
           WHERE 1 = 1 ''  + CASE WHEN @_tenor_option = ''1'' THEN '' AND sdd.term_start > '''''' + @_as_of_date + '''''''' ELSE '''' END
			+ CASE WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN '' AND sdd.term_start > '''''' + @_as_of_date + '''''' ''
				   WHEN @_term_start_to IS NULL THEN '' AND sdd.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) ''
				   WHEN @_term_start_from IS NULL THEN '' AND sdd.term_start =< CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
			       ELSE '' AND sdd.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
			  END
			  
            IF @_commodity_id <> ''NULL''
				SET @_sql += '' AND sdh.commodity_id = '' + @_commodity_id 
			
			IF @_counterparty_id <> ''NULL''
				SET @_sql += '' AND sdh.counterparty_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_counterparty_id + '''''','''','''') f) ''
			IF @_contract_id <> ''NULL''
				SET @_sql += '' AND sdh.contract_id IN (SELECT f.item FROM dbo.FNASplit('''''' + @_contract_id + '''''','''','''') f) ''
					
         SET @_sql += '' GROUP BY
                  sdd.source_deal_header_id,sdh.counterparty_id, sdh.contract_id,
                  CONVERT(VARCHAR(07), sdd.term_start, 120) + ''''-01''''
       ) calc
GROUP BY
       calc.term_start, calc.counterparty_id, calc.contract_id ''
       EXEC(@_sql)

CREATE INDEX  indx_temp_position_11 ON  #TRM_temp_position(term_start,expiration_date)
	INCLUDE (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)

SELECT sub.entity_name subsidairy,
       CONVERT(VARCHAR(7), unpvt.term_start, 120) + ''-01'' term_start,
       SUM(unpvt.Volume) [Position], ''@sub_id'' sub_id, ''@stra_id'' stra_id, ''@book_id'' book_id, ''@sub_book_id'' sub_book_id,
       @_tenor_option tenor_option, unpvt.commodity_id commodity_id, unpvt.counterparty_id counterparty_id,
       @_term_start_from term_start_from, @_term_start_to term_start_to,@_as_of_date as_of_date,  unpvt.contract_id [contract_id], contract_name,MAX(wp.weighted_price) [monthly_weighted_price]
 --[__batch_report__]
 FROM ( 
	SELECT 
		  s.commodity_id,
		  s.term_start,
		  s.book_deal_type_map_id,
		  s.counterparty_id,
		  s.contract_id,
		  cg.contract_name,
		  CAST(SUM( s.hr1) AS NUMERIC(38,20)) [1]	, CAST(SUM( s.hr2) AS NUMERIC(38,20)) [2],
		  CAST(SUM( s.hr3  - CASE WHEN NOT (s.commodity_id = -1) THEN ISNULL(s.hr25, 0) ELSE 0 END) AS NUMERIC(38,20)) [3],
		  CAST(SUM( s.hr4) AS NUMERIC(38,20)) [4]	, CAST(SUM( s.hr5) AS NUMERIC(38,20)) [5],
		  CAST(SUM( s.hr6 ) AS NUMERIC(38,20)) [6]	, CAST(SUM( s.hr7) AS NUMERIC(38,20)) [7],
		  CAST(SUM( s.hr8) AS NUMERIC(38,20)) [8]	, CAST(SUM( s.hr9) AS NUMERIC(38,20)) [9],
		  CAST(SUM( s.hr10) AS NUMERIC(38,20)) [10]	, CAST(SUM( s.hr11) AS NUMERIC(38,20)) [11],
		  CAST(SUM( s.hr12) AS NUMERIC(38,20)) [12]	, CAST(SUM( s.hr13) AS NUMERIC(38,20)) [13],
		  CAST(SUM( s.hr14) AS NUMERIC(38,20)) [14]	, CAST(SUM( s.hr15) AS NUMERIC(38,20)) [15],
		  CAST(SUM( s.hr16) AS NUMERIC(38,20)) [16]	, CAST(SUM( s.hr17) AS NUMERIC(38,20)) [17],
		  CAST(SUM( s.hr18) AS NUMERIC(38,20)) [18],
		  CAST(SUM( s.hr19) AS NUMERIC(38,20)) [19]	, CAST(SUM( s.hr20) AS NUMERIC(38,20)) [20],
		  CAST(SUM( s.hr21  - CASE WHEN s.commodity_id = -1 THEN ISNULL(s.hr25, 0) ELSE 0 END) AS NUMERIC(38,20)) [21],
		  CAST(SUM( s.hr22) AS NUMERIC(38,20)) [22]	, CAST(SUM( s.hr23) AS NUMERIC(38,20)) [23],
		  CAST(SUM( s.hr24) AS NUMERIC(38,20)) [24]	, CAST(SUM(s.hr25) AS NUMERIC(38,20)) [25]		
	FROM #TRM_temp_position s 
	LEFT JOIN contract_group cg ON s.contract_id = cg.contract_id
	 where s.term_start > @_term_start_from
	GROUP BY s.commodity_id,
		  s.term_start,
		  s.book_deal_type_map_id,
		  s.counterparty_id,
		  s.contract_id,
		  cg.contract_name
) p
UNPIVOT
	(Volume FOR [Hr] IN
		([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25])
	) AS unpvt
	
	LEFT JOIN mv90_DST dst ON dst.[date] = unpvt.term_start 
			AND dst.insert_delete = ''''''d''''''
	INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = unpvt.book_deal_type_map_id
	INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id AND book.hierarchy_level = 0
	INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
	INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2		
	LEFT JOIN #weighted_price wp ON CONVERT(VARCHAR(7), unpvt.term_start, 120) + ''-01'' = wp.term_start	
	AND wp.contract_id = unpvt.contract_id AND wp.counterparty_id = unpvt.counterparty_id
	WHERE  NOT (unpvt.hr=25 AND unpvt.Volume=0) 
		   AND ISNULL(dst.[hour],99) <> CASE WHEN unpvt.commodity_id=-1 THEN 1
           ELSE CASE WHEN unpvt.hr = 25 THEN 3 ELSE unpvt.hr END END
    GROUP BY 
            sub.entity_name 
          ,unpvt.counterparty_id
          ,unpvt.contract_id 
		  , unpvt.commodity_id
		  , CONVERT(VARCHAR(7),unpvt.term_start,120), contract_name
	ORDER BY   sub.entity_name , CONVERT(VARCHAR(7),unpvt.term_start,120)' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'book_id'
			   , reqd_param = 1, widget_id = 5, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'book_id' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'commodity_id'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_source_commodity_maintain ''a''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_id' AS [name], 'commodity_id' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_commodity_maintain ''a''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'counterparty_id'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_source_counterparty_maintain ''c''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'counterparty_id' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_counterparty_maintain ''c''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'Position'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Position'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'Position'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Position' AS [name], 'Position' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'stra_id'
			   , reqd_param = 1, widget_id = 4, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'stra_id' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_book_id'
			   , reqd_param = 1, widget_id = 8, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'sub_book_id' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_id'
			   , reqd_param = 1, widget_id = 3, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'sub_id' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'subsidairy'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'subsidairy'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'subsidairy'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'subsidairy' AS [name], 'subsidairy' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'tenor_option'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'tenor_option'
			   , reqd_param = 1, widget_id = 2, datatype_id = 1, param_data_source = 'SELECT 1 [id], ''Forward'' [options] UNION SELECT 2 [id], ''Show All'' [options]', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'tenor_option'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'tenor_option' AS [name], 'tenor_option' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 1 AS datatype_id, 'SELECT 1 [id], ''Forward'' [options] UNION SELECT 2 [id], ''Show All'' [options]' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'term_start'
			   , reqd_param = 0, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'term_start' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'term_start_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'term_start_from'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'term_start_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_from' AS [name], 'term_start_from' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'term_start_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'term_start_to'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'term_start_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_to' AS [name], 'term_start_to' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'as_of_date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'as_of_date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'contract_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'contract_id'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_contract_group ''r''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'contract_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_id' AS [name], 'contract_id' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_contract_group ''r''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'contract_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'contract_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'contract_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_name' AS [name], 'contract_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly Dashboard'
	            AND dsc.name =  'monthly_weighted_price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'monthly_weighted_price'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly Dashboard'
			AND dsc.name =  'monthly_weighted_price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'monthly_weighted_price' AS [name], 'monthly_weighted_price' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly Dashboard'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Position Monthly Dashboard'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	