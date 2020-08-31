BEGIN TRY
		BEGIN TRAN
	
	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Position Monthly View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'PDTV', description = ''
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL
    DROP TABLE #books

IF OBJECT_ID(N''tempdb..#term_date'') IS NOT NULL
    DROP TABLE #term_date

IF OBJECT_ID(N''tempdb..#temp_hourly_position_detail'') IS NOT NULL
    DROP TABLE #temp_hourly_position_detail

DECLARE @_term_start_from DATETIME
DECLARE @_term_start_to DATETIME,
        @_sql VARCHAR(MAX)

DECLARE @_block_type_group_id     INT,
        @_as_of_date              VARCHAR(25) = ''@as_of_date'',
        @_to_as_of_date           VARCHAR(25) = ''@as_of_date'',
        @_change_report				CHAR(1)		= ''@change_report'',	-- Used for to generate change report or standard report , by default hidden in report paramset
        @_tenor_option				CHAR(1)		= ''@tenor_option'', -- Forward  / Show All 
        @_period_from				VARCHAR(50)	= ''@period_from'',
        @_period_to					VARCHAR(50)	= ''@period_to'',
        @_source_deal_header_id		VARCHAR(max)= ''@source_deal_header_id''

IF @user_defined_block_id IS NOT NULL
    SET @_block_type_group_id = ''@user_defined_block_id''

DECLARE @_temp_date VARCHAR(25) = @_as_of_date

IF ''@to_as_of_date'' <> ''NULL''
    SET @_to_as_of_date = ''@to_as_of_date''
    
IF ''@as_of_date'' = ''NULL'' AND ''@to_as_of_date'' IS NOT NULL AND @_change_report = ''1''
BEGIN
	SELECT @_as_of_date = CONVERT(char(10),  MAX(sdp.pnl_as_of_date),126) FROM source_deal_pnl AS sdp WHERE sdp.pnl_as_of_date < ''@to_as_of_date''
END
ELSE IF ''@as_of_date'' = ''NULL'' 
BEGIN
	SELECT @_as_of_date = ''@to_as_of_date''
END
	


	    
IF @_to_as_of_date IS NOT NULL
    SET @_temp_date = @_to_as_of_date

-- If period is not specified term start from to as of date default to as of date
SET @_term_start_from = @_to_as_of_date    	
IF ''@period_from'' <> ''NULL''
    SET @_term_start_from = dbo.FNAGetTermStartDate(''m'', @_temp_date, ''@period_from'')

IF ''@period_to'' <> ''NULL''
    SET @_term_start_to = dbo.FNAGetTermENDDate(''m'', @_temp_date, ''@period_to'')
 
 
IF @_tenor_option = ''2''
	SET @_as_of_date = ''1900-01-01''

IF @_tenor_option = ''2'' AND ''NULL'' = ''NULL''
begin
	SET @_term_start_from = ''1900-01-01''
	set @_to_as_of_date = ''1900-01-01''
end
   
--check invalid date range.
DECLARE @_invalid_date_range BIT = 0


IF DATEDIFF(DAY, @_as_of_date, @_to_as_of_date) < 0
    SET @_invalid_date_range = 1

CREATE TABLE #books
(
	book_deal_type_map_id      INT,
	fas_book_id                INT,
	source_system_book_id1     INT,
	source_system_book_id2     INT,
	source_system_book_id3     INT,
	source_system_book_id4     INT
)
SET @_sql = 
    ''
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

--when single as_of_date is passed
IF @_to_as_of_date IS NULL
    SET @_to_as_of_date = @_as_of_date

IF OBJECT_ID(N''tempdb..#temp_report_hourly_position_breakdown'') IS NOT NULL
    DROP TABLE #temp_report_hourly_position_breakdown

CREATE TABLE #temp_report_hourly_position_breakdown
(
	block_define_id     INT,
	term_start          DATETIME,
	term_end            DATETIME
)

SET @_sql = 
    ''
INSERT INTO	#temp_report_hourly_position_breakdown(block_define_id,term_start,term_end)  
SELECT distinct isnull(spcd.block_define_id,304625) block_define_id,s.term_start,s.term_end 
FROM report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
	AND bk.source_system_book_id1=s.source_system_book_id1 
	AND bk.source_system_book_id2=s.source_system_book_id2 
	AND bk.source_system_book_id3=s.source_system_book_id3 
	AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
LEFT JOIN source_price_curve_def spcd WITH (nolock) 
ON spcd.source_curve_def_id=s.curve_id 
WHERE 1=1''

IF ''@exclude_sub_book_for_fin_pos'' <> ''NULL''
    SET @_sql += '' AND bk.book_deal_type_map_id NOT IN ('' +
        ''@exclude_sub_book_for_fin_pos'' + '')''

SET @_sql += ''
AND ('''''' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) +
    '''''' = ''''NULL'''' OR s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) 
    + '')) '' + CASE 
                   WHEN @_term_start_from IS NULL
                        AND @_term_start_to IS NULL THEN ''''
                   WHEN @_term_start_to IS NULL THEN 
                        '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
                        + '''''' as DATETIME)''
                   WHEN @_term_start_from IS NULL THEN 
                        '' AND s.term_start =< CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
                        + ''''''as DATETIME)''
                   ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
                        + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
                        + ''''''as DATETIME)''
              END

PRINT (@_sql)

EXEC (@_sql + '' OPTION (maxdop 1)'')

CREATE TABLE #term_date
(
	block_define_id     INT,
	term_date           DATE,
	term_start          DATE,
	term_end            DATE,
	hr1                 TINYINT,
	hr2                 TINYINT,
	hr3                 TINYINT,
	hr4                 TINYINT,
	hr5                 TINYINT,
	hr6                 TINYINT,
	hr7                 TINYINT,
	hr8                 TINYINT,
	hr9                 TINYINT,
	hr10                TINYINT,
	hr11                TINYINT,
	hr12                TINYINT,
	hr13                TINYINT,
	hr14                TINYINT,
	hr15                TINYINT,
	hr16                TINYINT,
	hr17                TINYINT,
	hr18                TINYINT,
	hr19                TINYINT,
	hr20                TINYINT,
	hr21                TINYINT,
	hr22                TINYINT,
	hr23                TINYINT,
	hr24                TINYINT,
	add_dst_hour        INT
)

INSERT INTO #term_date
  (
    block_define_id,
    term_date,
    term_start,
    term_end,
    hr1,
    hr2,
    hr3,
    hr4,
    hr5,
    hr6,
    hr7,
    hr8,
    hr9,
    hr10,
    hr11,
    hr12,
    hr13,
    hr14,
    hr15,
    hr16,
    hr17,
    hr18,
    hr19,
    hr20,
    hr21,
    hr22,
    hr23,
    hr24,
    add_dst_hour
  )
SELECT DISTINCT a.block_define_id,
       hb.term_date,
       a.term_start,
       a.term_end,
       hb.hr1,
       hb.hr2,
       hb.hr3,
       hb.hr4,
       hb.hr5,
       hb.hr6,
       hb.hr7,
       hb.hr8,
       hb.hr9,
       hb.hr10,
       hb.hr11,
       hb.hr12,
       hb.hr13,
       hb.hr14,
       hb.hr15,
       hb.hr16,
       hb.hr17,
       hb.hr18,
       hb.hr19,
       hb.hr20,
       hb.hr21,
       hb.hr22,
       hb.hr23,
       hb.hr24,
       hb.add_dst_hour
FROM   #temp_report_hourly_position_breakdown a
       OUTER APPLY (
    SELECT h.*
    FROM   hour_block_term h WITH (NOLOCK)
    WHERE  block_define_id = a.block_define_id
           AND h.block_type = 12000
           AND term_date BETWEEN a.term_start
               AND a.term_end --and term_date>''@as_of_date''
) hb
OPTION(MAXDOP 1)

----- hourly position deal start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_deal'') IS NOT NULL
    DROP TABLE #temp_hourly_position_deal

CREATE TABLE #temp_hourly_position_deal
(
	curve_id                    INT,
	location_id                 INT,
	term_start                  DATETIME,
	period                      INT,
	deal_date                   DATETIME,
	deal_volume_uom_id          DATETIME,
	physical_financial_flag     VARCHAR(2) COLLATE DATABASE_DEFAULT,
	hr1                         FLOAT,
	hr2                         FLOAT,
	hr3                         FLOAT,
	hr4                         FLOAT,
	hr5                         FLOAT,
	hr6                         FLOAT,
	hr7                         FLOAT,
	hr8                         FLOAT,
	hr9                         FLOAT,
	hr10                        FLOAT,
	hr11                        FLOAT,
	hr12                        FLOAT,
	hr13                        FLOAT,
	hr14                        FLOAT,
	hr15                        FLOAT,
	hr16                        FLOAT,
	hr17                        FLOAT,
	hr18                        FLOAT,
	hr19                        FLOAT,
	hr20                        FLOAT,
	hr21                        FLOAT,
	hr22                        FLOAT,
	hr23                        FLOAT,
	hr24                        FLOAT,
	hr25                        FLOAT,
	source_deal_header_id       INT,
	commodity_id                INT,
	counterparty_id             INT,
	fas_book_id                 INT,
	source_system_book_id1      INT,
	source_system_book_id2      INT,
	source_system_book_id3      INT,
	source_system_book_id4      INT,
	expiration_date             DATETIME,
	is_fixedvolume              VARCHAR(2) COLLATE DATABASE_DEFAULT,
	deal_status_id              INT,
	deal_volume_frequency       VARCHAR(2) COLLATE DATABASE_DEFAULT,
	term_end                    DATETIME
)

SET @_sql = 
    ''INSERT INTO #temp_hourly_position_deal (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)	
SELECT s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_end 
FROM report_hourly_position_deal s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id
LEFT JOIN source_deal_detail sdd 
	ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.source_deal_detail_id = s.source_deal_detail_id  
WHERE 1=1 

AND ('''''' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) +
    '''''' = ''''NULL'''' OR s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) 
    + ''))''
	+ CASE WHEN @_tenor_option = ''1'' THEN '' 
AND s.deal_date<='''''' 
    + @_to_as_of_date + ''''''  AND s.expiration_date > '''''' + @_as_of_date +
    '''''' AND s.term_start > '''''' + @_as_of_date + '''''''' ELSE '''' END
 + CASE 
         WHEN @_term_start_from IS NULL
              AND @_term_start_to IS NULL THEN '' AND s.term_start > '''''' + @_as_of_date 
              + '''''' ''
         WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
              + '''''' as DATETIME) ''
         WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' +
              CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
         ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
              + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
              + ''''''as DATETIME)''
    END
                                                                   
PRINT (@_sql) 
EXEC (@_sql + '' OPTION (maxdop 1)'')

----- hourly position deal END
----- hourly position profile start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_profile'') IS NOT NULL
    DROP TABLE #temp_hourly_position_profile

CREATE TABLE #temp_hourly_position_profile
(
	curve_id                    INT,
	location_id                 INT,
	term_start                  DATETIME,
	period                      INT,
	deal_date                   DATETIME,
	deal_volume_uom_id          DATETIME,
	physical_financial_flag     VARCHAR(2) COLLATE DATABASE_DEFAULT,
	hr1                         FLOAT,
	hr2                         FLOAT,
	hr3                         FLOAT,
	hr4                         FLOAT,
	hr5                         FLOAT,
	hr6                         FLOAT,
	hr7                         FLOAT,
	hr8                         FLOAT,
	hr9                         FLOAT,
	hr10                        FLOAT,
	hr11                        FLOAT,
	hr12                        FLOAT,
	hr13                        FLOAT,
	hr14                        FLOAT,
	hr15                        FLOAT,
	hr16                        FLOAT,
	hr17                        FLOAT,
	hr18                        FLOAT,
	hr19                        FLOAT,
	hr20                        FLOAT,
	hr21                        FLOAT,
	hr22                        FLOAT,
	hr23                        FLOAT,
	hr24                        FLOAT,
	hr25                        FLOAT,
	source_deal_header_id       INT,
	commodity_id                INT,
	counterparty_id             INT,
	fas_book_id                 INT,
	source_system_book_id1      INT,
	source_system_book_id2      INT,
	source_system_book_id3      INT,
	source_system_book_id4      INT,
	expiration_date             DATETIME,
	is_fixedvolume              VARCHAR(2) COLLATE DATABASE_DEFAULT,
	deal_status_id              INT,
	deal_volume_frequency       VARCHAR(2) COLLATE DATABASE_DEFAULT,
	term_end                    DATETIME
)

SET @_sql = 
    ''
INSERT INTO #temp_hourly_position_profile (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
SELECT s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_end 
FROM report_hourly_position_profile s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
AND bk.source_system_book_id1=s.source_system_book_id1	
AND bk.source_system_book_id2=s.source_system_book_id2	
AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id
LEFT JOIN source_deal_detail sdd 
	ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.source_deal_detail_id = s.source_deal_detail_id  
WHERE  1=1
AND s.deal_date<='''''' 
    + @_to_as_of_date + ''''''  AND s.expiration_date > '''''' + @_as_of_date +
    '''''' AND s.term_start > '''''' + @_as_of_date + ''''''
AND ('''''' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) +
    '''''' = ''''NULL'''' OR s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) 
    + ''))'' + CASE 
                  WHEN @_term_start_from IS NULL
                       AND @_term_start_to IS NULL THEN '' AND s.term_start > '''''' 
                       + @_as_of_date + '''''' ''
                  WHEN @_term_start_to IS NULL THEN 
                       '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
                       + '''''' as DATETIME) ''
                  WHEN @_term_start_from IS NULL THEN 
                       '' AND s.term_start =< CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
                       + ''''''as DATETIME) ''
                  ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
                       + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
                       + ''''''as DATETIME)''
             END

PRINT (@_sql)

EXEC (@_sql + '' OPTION (maxdop 1)'')

---- hourly position profile END
----- hourly position financial start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_financial'') IS NOT NULL
    DROP TABLE #temp_hourly_position_financial

CREATE TABLE #temp_hourly_position_financial
(
	curve_id                    INT,
	location_id                 INT,
	term_start                  DATETIME,
	period                      INT,
	deal_date                   DATETIME,
	deal_volume_uom_id          DATETIME,
	physical_financial_flag     VARCHAR(2) COLLATE DATABASE_DEFAULT,
	hr1                         FLOAT,
	hr2                         FLOAT,
	hr3                         FLOAT,
	hr4                         FLOAT,
	hr5                         FLOAT,
	hr6                         FLOAT,
	hr7                         FLOAT,
	hr8                         FLOAT,
	hr9                         FLOAT,
	hr10                        FLOAT,
	hr11                        FLOAT,
	hr12                        FLOAT,
	hr13                        FLOAT,
	hr14                        FLOAT,
	hr15                        FLOAT,
	hr16                        FLOAT,
	hr17                        FLOAT,
	hr18                        FLOAT,
	hr19                        FLOAT,
	hr20                        FLOAT,
	hr21                        FLOAT,
	hr22                        FLOAT,
	hr23                        FLOAT,
	hr24                        FLOAT,
	hr25                        FLOAT,
	source_deal_header_id       INT,
	commodity_id                INT,
	counterparty_id             INT,
	fas_book_id                 INT,
	source_system_book_id1      INT,
	source_system_book_id2      INT,
	source_system_book_id3      INT,
	source_system_book_id4      INT,
	expiration_date             DATETIME,
	is_fixedvolume              VARCHAR(2) COLLATE DATABASE_DEFAULT,
	deal_status_id              INT,
	deal_volume_frequency       VARCHAR(2) COLLATE DATABASE_DEFAULT,
	term_end                    DATETIME
)

SET @_sql = 
    ''INSERT INTO #temp_hourly_position_financial (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
SELECT s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
	,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_END 
FROM report_hourly_position_financial s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id
LEFT JOIN source_deal_detail sdd 
	ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.source_deal_detail_id = s.source_deal_detail_id  
WHERE 1=1''

IF ''@exclude_sub_book_for_fin_pos'' <> ''NULL''
    SET @_sql += '' AND bk.book_deal_type_map_id NOT IN ('' +
        ''@exclude_sub_book_for_fin_pos'' + '')''

SET @_sql += ''
AND ('''''' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) +
    '''''' = ''''NULL'''' OR s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) 
    + ''))
AND s.deal_date<='''''' + @_as_of_date + ''''''  AND s.expiration_date > '''''' + @_as_of_date 
    + '''''' AND s.term_start > '''''' + @_as_of_date + '''''' '' 
    + CASE 
           WHEN @_term_start_from IS NULL
                AND @_term_start_to IS NULL THEN ''''
           WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' +
                CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME)''
           WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' +
                CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
           ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
                + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
                + ''''''as DATETIME)''
      END

PRINT (@_sql)

EXEC (@_sql)

----- hourly position financial END
IF OBJECT_ID(N''tempdb..#temp_hourly_position_breakdown'') IS NOT NULL
    DROP TABLE #temp_hourly_position_breakdown

----- hourly position breakdown start
CREATE TABLE #temp_hourly_position_breakdown
(
	curve_id                    INT,
	location_id                 INT,
	term_start                  DATETIME,
	period                      INT,
	deal_date                   DATETIME,
	deal_volume_uom_id          DATETIME,
	physical_financial_flag     VARCHAR(2) COLLATE DATABASE_DEFAULT,
	hr1                         FLOAT,
	hr2                         FLOAT,
	hr3                         FLOAT,
	hr4                         FLOAT,
	hr5                         FLOAT,
	hr6                         FLOAT,
	hr7                         FLOAT,
	hr8                         FLOAT,
	hr9                         FLOAT,
	hr10                        FLOAT,
	hr11                        FLOAT,
	hr12                        FLOAT,
	hr13                        FLOAT,
	hr14                        FLOAT,
	hr15                        FLOAT,
	hr16                        FLOAT,
	hr17                        FLOAT,
	hr18                        FLOAT,
	hr19                        FLOAT,
	hr20                        FLOAT,
	hr21                        FLOAT,
	hr22                        FLOAT,
	hr23                        FLOAT,
	hr24                        FLOAT,
	hr25                        FLOAT,
	source_deal_header_id       INT,
	commodity_id                INT,
	counterparty_id             INT,
	fas_book_id                 INT,
	source_system_book_id1      INT,
	source_system_book_id2      INT,
	source_system_book_id3      INT,
	source_system_book_id4      INT,
	expiration_date             DATETIME,
	is_fixedvolume              VARCHAR(2) COLLATE DATABASE_DEFAULT,
	deal_status_id              INT,
	deal_volume_frequency       VARCHAR(2) COLLATE DATABASE_DEFAULT,
	term_end                    DATETIME
)

DECLARE @_sql1     VARCHAR(MAX),
        @_sql2     VARCHAR(MAX),
        @_sql3     VARCHAR(MAX)

SET @_sql = 
    ''
INSERT INTO #temp_hourly_position_breakdown (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
SELECT s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,0 period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    +
    @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
''

SET @_sql1 = 
    '',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
,(cast(cast(s.calc_volume as numeric(22,10))* cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0)) as numeric(22,10))) /cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date +
    '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''''dbo.FNACurveH'''',''''dbo.FNACurveD'''') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''''y'''' AS is_fixedvolume ,deal_status_id, ''''m'''' [deal_volume_frequency],s.term_end [term_end] --[deal_volume_frequency] for finalcial deals are always monthly  
''

SET @_sql2 = 
    ''FROM report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id
	AND bk.source_system_book_id1=s.source_system_book_id1 
	AND bk.source_system_book_id2=s.source_system_book_id2
	AND bk.source_system_book_id3=s.source_system_book_id3 
	AND bk.source_system_book_id4=s.source_system_book_id4
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd WITH (nolock) ON spcd.source_curve_def_id=s.curve_id 
LEFT JOIN source_price_curve_def spcd_proxy (nolock) ON spcd_proxy.source_curve_def_id=spcd.settlement_curve_id
outer apply (SELECT sum(volume_mult) term_no_hrs FROM hour_block_term hbt WHERE isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,304625)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END ) term_hrs
outer apply ( SELECT sum(volume_mult) term_no_hrs FROM hour_block_term hbt inner JOIN (SELECT distinct exp_date FROM holiday_group h WHERE  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex ON ex.exp_date=hbt.term_date
WHERE  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,304625)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END) term_hrs_exp
LEFT JOIN #term_date hb ON hb.block_define_id=isnull(spcd.block_define_id,304625) and hb.term_start = s.term_start
and hb.term_end=s.term_end 
outer apply  (SELECT MAX(exp_date) exp_date FROM holiday_group h WHERE h.hol_date=hb.term_date AND 
h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
outer apply  (SELECT MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  FROM holiday_group h WHERE 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''''REBD'''')) hg1   
outer apply  (SELECT count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''''' 
    + @_as_of_date +
    '''''' THEN 1 ELSE 0 END) remain_days FROM holiday_group h WHERE h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) 
AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
AND ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''''REBD'''')) remain_month  
WHERE ((ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''''9999-01-01'''')>'''''' 
    + @_as_of_date +
    '''''') OR COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800)
AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
AND s.deal_date<='''''' + @_to_as_of_date + ''''''
AND ('''''' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) +
    '''''' = ''''NULL'''' OR s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) 
    + ''))'' +
    --CASE
    --	WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN '' AND s.term_start > '''''' + @_as_of_date + '''''' ''
    --	WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) ''
    --	WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
    --	ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
    --END
    CASE 
         WHEN @_term_start_from IS NULL
              AND @_term_start_to IS NULL THEN '' AND hb.term_date > '''''' + @_as_of_date 
              + '''''' ''
         WHEN @_term_start_to IS NULL THEN '' AND hb.term_date >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
              + '''''' as DATETIME) ''
         WHEN @_term_start_from IS NULL THEN '' AND hb.term_date =< CAST('''''' +
              CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
         ELSE '' AND hb.term_date BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
              + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
              + ''''''as DATETIME)''
    END

PRINT (@_sql)
PRINT (@_sql1)
PRINT (@_sql2)

EXEC (@_sql + @_sql1 + @_sql2 + '' OPTION (loop join)'')

-- hourly position breakdown END
CREATE INDEX indxterm_dat ON #term_date(block_define_id, term_start, term_end)

IF OBJECT_ID(N''tempdb..#temp_position_table'') IS NOT NULL
    DROP TABLE #temp_position_table

SELECT *
       INTO     #temp_position_table
FROM   (
           SELECT *
           FROM   #temp_hourly_position_deal
           
           UNION ALL
           
           SELECT *
           FROM   #temp_hourly_position_profile
           
           UNION ALL
           
           SELECT *
           FROM   #temp_hourly_position_breakdown
           
           UNION ALL
           
           SELECT *
           FROM   #temp_hourly_position_financial
       )        pos

IF OBJECT_ID(N''tempdb..#temp_block_type_group_table'') IS NOT NULL
    DROP TABLE #temp_block_type_group_table

CREATE TABLE #temp_block_type_group_table
(
	block_type_group_id     INT,
	block_type_id           INT,
	block_name              VARCHAR(200) COLLATE DATABASE_DEFAULT,
	hourly_block_id         INT
)

IF (@_block_type_group_id IS NOT NULL)
    SET @_sql = 
        ''INSERT INTO #temp_block_type_group_table(block_type_group_id, block_type_id, block_name, hourly_block_id)
				SELECT block_type_group_id,block_type_id,block_name,hourly_block_id 				
				FROM block_type_group 
				WHERE block_type_group_id='' + CAST(@_block_type_group_id AS VARCHAR(100))
ELSE
    SET @_sql = 
        ''INSERT INTO #temp_block_type_group_table(block_type_group_id, block_type_id, block_name, hourly_block_id)
				SELECT NULL block_type_group_id, NULL block_type_id, ''''Baseload'''' block_name, 304625 hourly_block_id''

PRINT (@_sql)

EXEC (@_sql + '' OPTION (maxdop 1)'')

/*
--original index
CREATE INDEX ix_pt_tpt ON #temp_position_table (
	expiration_date
	, location_id
	, curve_id
	, fas_book_id
	) INCLUDE (
	source_system_book_id1
	, source_system_book_id2
	, source_system_book_id3
	, source_system_book_id4
	)
*/

--copied from Position View Hourly With Block Type
CREATE INDEX ix_pt_tpt ON #temp_position_table(
                                                  source_deal_header_id,
                                                  term_start,
                                                  location_id,
                                                  curve_id,
                                                  counterparty_id,
                                                  expiration_date
                                              ) INCLUDE(
                                                           source_system_book_id1,
                                                           source_system_book_id2,
                                                           source_system_book_id3,
                                                           source_system_book_id4
                                                       )

CREATE INDEX ix_pt_block ON #temp_block_type_group_table(hourly_block_id, block_type_id, block_type_group_id) 
INCLUDE(block_name)

IF OBJECT_ID(N''tempdb..#temp_hourly_position'') IS NOT NULL
    DROP TABLE #temp_hourly_position

SELECT CAST(@_as_of_date AS DATETIME)     as_of_date,
       CAST(@_to_as_of_date AS DATETIME)     to_as_of_date,
       sub.entity_id                         sub_id,
       stra.entity_id                        stra_id,
       book.entity_id                        book_id,
       sub.entity_name                       sub,
       stra.entity_name                      strategy,
       book.entity_name                      book,
       vw.source_deal_header_id,
       sdh.deal_id                           deal_id,
       (
           CASE 
                WHEN vw.physical_financial_flag = ''p'' THEN ''Physical''
                ELSE ''Financial''
           END
       )                                     physical_financial_flag,
       vw.deal_date                          deal_date,
       sml.Location_Name                     location,
       spcd.curve_name [index],
       spcd_proxy.curve_name                 proxy_index,
       sdv2.code                             region,
       sdv.code                              country,
       sdv1.code                             grid,
       mjr.location_name                     location_group,
       com.commodity_name                    commodity,
       sdv_deal_staus.code                   deal_status,
       sc.counterparty_name                  counterparty_name,
       sc.counterparty_name                  parent_counterparty,
       CONVERT(VARCHAR(7), vw.term_start, 120) term_year_month,
       vw.term_start                         term_start,
       sb1.source_book_name                  book_identifier1,
       sb2.source_book_name                  book_identifier2,
       sb3.source_book_name                  book_identifier3,
       sb4.source_book_name                  book_identifier4,
       ssbm.logical_name                  AS sub_book,
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr7 ELSE hb.hr1 END * vw.Hr1 [01],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr8 ELSE hb.hr2 END * vw.Hr2 [02],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr9 ELSE hb.hr3 END * vw.Hr3 [03],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr10 ELSE hb.hr4 END * vw.Hr4 [04],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr11 ELSE hb.hr5 END * vw.Hr5 [05],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr12 ELSE hb.hr6 END * vw.Hr6 [06],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr13 ELSE hb.hr7 END * vw.Hr7 [07],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr14 ELSE hb.hr8 END * vw.Hr8 [08],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr15 ELSE hb.hr9 END * vw.Hr9 [09],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr16 ELSE hb.hr10 END * vw.Hr10 [10],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr17 ELSE hb.hr11 END * vw.Hr11 [11],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr18 ELSE hb.hr12 END * vw.Hr12 [12],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr19 ELSE hb.hr13 END * vw.Hr13 [13],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr20 ELSE hb.hr14 END * vw.Hr14 [14],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr21 ELSE hb.hr15 END * vw.Hr15 [15],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr22 ELSE hb.hr16 END * vw.Hr16 [16],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr23 ELSE hb.hr17 END * vw.Hr17 [17],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr24 ELSE hb.hr18 END * vw.Hr18 [18],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr1 ELSE hb.hr19 END * vw.Hr19 [19],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr2 ELSE hb.hr20 END * vw.Hr20 [20],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr3 ELSE hb.hr21 END * vw.Hr21 [21],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr4 ELSE hb.hr22 END * vw.Hr22 [22],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr5 ELSE hb.hr23 END * vw.Hr23 [23],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr6 ELSE hb.hr24 END * vw.Hr24 [24],
       NULLIF(hb.hr3, 0) * vw.Hr25 [25],
       NULLIF(hb.hr3, 0) * vw.Hr25 [dst_25],
       su_uom.uom_name [uom],
       su_pos_uom.uom_name [postion_uom],
       spcd_monthly_index.curve_name + CASE 
                                            WHEN sssd.source_system_id = 2 THEN 
                                                 ''''
                                            ELSE ''.'' + sssd.source_system_name
                                       END AS [proxy_curve2],
       su_uom_proxy2.uom_name [proxy2_position_uom],
       spcd_proxy_curve3.curve_name + CASE 
                                           WHEN sssd2.source_system_id = 2 THEN 
                                                ''''
                                           ELSE ''.'' + sssd2.source_system_name
                                      END AS [proxy_curve3],
       su_uom_proxy3.uom_name [proxy3_position_uom],
       sdv_block.code [block_definition],
       CASE 
            WHEN vw.deal_volume_frequency = ''h'' THEN ''Hourly''
            WHEN vw.deal_volume_frequency = ''d'' THEN ''Daily''
            WHEN vw.deal_volume_frequency = ''m'' THEN ''Monthly''
            WHEN vw.deal_volume_frequency = ''t'' THEN ''Term''
            WHEN vw.deal_volume_frequency = ''a'' THEN ''Annually''
            WHEN vw.deal_volume_frequency = ''x'' THEN ''15 Minutes''
            WHEN vw.deal_volume_frequency = ''y'' THEN ''30 Minutes''
       END [deal_volume_frequency],
       spcd_proxy_curve_def.curve_name [proxy_curve],
       su_uom_proxy_curve_def.uom_name [proxy_curve_position_uom],
       YEAR(vw.term_start)                   term_year,
       vw.term_start                         term_end,
       sc.source_counterparty_id             counterparty_id,
       sml.source_minor_location_id          location_id,
       su_uom_proxy_curve.uom_name           proxy_index_position_uom,
       spcd.source_curve_def_id [index_id],
       vw.period,
       ssbm.book_deal_type_map_id [sub_book_id],
       spcd.proxy_curve_id3,
       vw.expiration_date,
       spcd.commodity_id,
       ISNULL(grp.block_name, spcd.curve_name) block_name,
       ISNULL(grp.hourly_block_id, spcd.source_curve_def_id) hourly_block_id,
       sdv_block_group.code [user_defined_block],
       sdv_block_group.value_id [user_defined_block_id],
       vw.is_fixedvolume
INTO #temp_hourly_position
FROM   #temp_position_table vw
       CROSS JOIN #temp_block_type_group_table grp
       LEFT JOIN source_minor_location sml WITH (NOLOCK)
            ON  sml.source_minor_location_id = vw.location_id
       INNER JOIN source_price_curve_def spcd WITH (NOLOCK)
            ON  spcd.source_curve_def_id = vw.curve_id
       LEFT JOIN source_price_curve_def spcd_proxy WITH (NOLOCK)
            ON  spcd_proxy.source_curve_def_id = spcd.proxy_curve_id
       LEFT JOIN source_price_curve_def spcd_proxy_curve3 WITH (NOLOCK)
            ON  spcd_proxy_curve3.source_curve_def_id = spcd.proxy_curve_id3
       LEFT JOIN source_price_curve_def spcd_monthly_index WITH (NOLOCK)
            ON  spcd_monthly_index.source_curve_def_id = spcd.monthly_index
       LEFT JOIN source_price_curve_def spcd_proxy_curve_def WITH (NOLOCK)
            ON  spcd_proxy_curve_def.source_curve_def_id = spcd.proxy_source_curve_def_id
       LEFT JOIN hour_block_term hb WITH (NOLOCK)
            ON  hb.block_define_id = COALESCE(grp.hourly_block_id, 304625)
            AND hb.block_type = COALESCE(grp.block_type_id, 12000)
            AND vw.term_start = hb.term_date
	   LEFT JOIN hour_block_term hb1 (nolock)  
			ON hb.block_define_id=hb1.block_define_id 
			AND  hb.block_type=hb1.block_type 
			AND hb.term_date=hb1.term_date-1
       LEFT JOIN source_system_description sssd WITH (NOLOCK)
            ON  sssd.source_system_id = spcd_monthly_index.source_system_id
       LEFT JOIN source_system_description sssd2 WITH (NOLOCK)
            ON  sssd.source_system_id = spcd_proxy_curve3.source_system_id
       LEFT JOIN static_data_value sdv1 WITH (NOLOCK)
            ON  sdv1.value_id = sml.grid_value_id
       LEFT JOIN static_data_value sdv WITH (NOLOCK)
            ON  sdv.value_id = sml.country
       LEFT JOIN static_data_value sdv2 WITH (NOLOCK)
            ON  sdv2.value_id = sml.region
       LEFT JOIN source_major_location mjr WITH (NOLOCK)
            ON  sml.source_major_location_ID = mjr.source_major_location_ID
       LEFT JOIN source_uom               AS su_pos_uom WITH (NOLOCK)
            ON  su_pos_uom.source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)
       LEFT JOIN source_uom su_uom WITH (NOLOCK)
            ON  su_uom.source_uom_id = spcd.uom_id
       LEFT JOIN source_uom su_uom_proxy3 WITH (NOLOCK)
            ON  su_uom_proxy3.source_uom_id = ISNULL(spcd_proxy_curve3.display_uom_id, spcd_proxy_curve3.uom_id) --spcd_proxy_curve3.display_uom_id
                
       LEFT JOIN source_uom su_uom_proxy2 WITH (NOLOCK)
            ON  su_uom_proxy2.source_uom_id = ISNULL(
                    spcd_monthly_index.display_uom_id,
                    spcd_monthly_index.uom_id
                )
       LEFT JOIN source_uom su_uom_proxy_curve_def WITH (NOLOCK)
            ON  su_uom_proxy_curve_def.source_uom_id = ISNULL(
                    spcd_proxy_curve_def.display_uom_id,
                    spcd_proxy_curve_def.uom_id
                ) --spcd_proxy_curve_def.display_uom_id
                
       LEFT JOIN source_uom su_uom_proxy_curve WITH (NOLOCK)
            ON  su_uom_proxy_curve.source_uom_id = ISNULL(spcd_proxy.display_uom_id, spcd_proxy.uom_id)
       LEFT JOIN source_counterparty sc WITH (NOLOCK)
            ON  sc.source_counterparty_id = vw.counterparty_id
       LEFT JOIN source_counterparty psc WITH (NOLOCK)
            ON  psc.source_counterparty_id = sc.parent_counterparty_id
       LEFT JOIN source_commodity com WITH (NOLOCK)
            ON  com.source_commodity_id = spcd.commodity_id
       LEFT JOIN portfolio_hierarchy book WITH (NOLOCK)
            ON  book.entity_id = vw.fas_book_id
       LEFT JOIN portfolio_hierarchy stra WITH (NOLOCK)
            ON  stra.entity_id = book.parent_entity_id
       LEFT JOIN portfolio_hierarchy sub WITH (NOLOCK)
            ON  sub.entity_id = stra.parent_entity_id
       LEFT JOIN source_deal_header sdh WITH (NOLOCK)
            ON  sdh.source_deal_header_id = vw.source_deal_header_id
       LEFT JOIN static_data_value sdv_deal_staus WITH (NOLOCK)
            ON  sdv_deal_staus.value_id = vw.deal_status_id
       LEFT JOIN source_system_book_map ssbm WITH (NOLOCK)
            ON  ssbm.source_system_book_id1 = vw.source_system_book_id1
            AND ssbm.source_system_book_id2 = vw.source_system_book_id2
            AND ssbm.source_system_book_id3 = vw.source_system_book_id3
            AND ssbm.source_system_book_id4 = vw.source_system_book_id4
       LEFT JOIN source_book sb1 WITH (NOLOCK)
            ON  sb1.source_book_id = vw.source_system_book_id1
       LEFT JOIN source_book sb2 WITH (NOLOCK)
            ON  sb2.source_book_id = vw.source_system_book_id2
       LEFT JOIN source_book sb3 WITH (NOLOCK)
            ON  sb3.source_book_id = vw.source_system_book_id3
       LEFT JOIN source_book sb4 WITH (NOLOCK)
            ON  sb4.source_book_id = vw.source_system_book_id4
       LEFT JOIN static_data_value sdv_block WITH (NOLOCK)
            ON  sdv_block.value_id = sdh.block_define_id
       LEFT JOIN static_data_value sdv_block_group WITH (NOLOCK)
            ON  sdv_block_group.value_id = grp.block_type_group_id
WHERE  vw.expiration_date > @_as_of_date
       AND vw.term_start > @_as_of_date
           OPTION(MAXRECURSION 32767)

IF OBJECT_ID(N''tempdb..#final_temp_position_value'') IS NOT NULL
    DROP TABLE #final_temp_position_value

CREATE INDEX ix_pt_test1 ON #temp_hourly_position(deal_date, source_deal_header_id) 
INCLUDE(
           [01],
           [02],
           [03],
           [04],
           [05],
           [06],
           [07],
           [08],
           [09],
           [10],
           [11],
           [12],
           [13],
           [14],
           [15],
           [16],
           [17],
           [18],
           [19],
           [20],
           [21],
           [22],
           [23],
           [24],
           [25]
       )


SELECT unpvt.as_of_date,
       to_as_of_date,
       sub_id,
       stra_id,
       book_id,
       sub,
       strategy [stra],
       book,
       unpvt.source_deal_header_id,
       unpvt.deal_id,
       unpvt.physical_financial_flag,
       unpvt.deal_date,
       location,
       [index]                       AS curve_name,
       proxy_index,
       region,
       country,
       grid,
       location_group,
       commodity,
       unpvt.deal_status,
       counterparty_name,
       parent_counterparty,
       term_year_month,
       unpvt.term_start,
       book_identifier1 [group1],
       book_identifier2 [group2],
       book_identifier3 [group3],
       book_identifier4 [group4],
       unpvt.sub_book,
       uom,
       postion_uom,
       proxy_curve2,
       proxy2_position_uom,
       proxy_curve3,
       proxy3_position_uom,
       block_definition,
       unpvt.deal_volume_frequency,
       proxy_curve,
       proxy_curve_position_uom,
       term_year,
       unpvt.term_end,
       unpvt.counterparty_id,
       unpvt.location_id,
       proxy_index_position_uom,
       index_id                      AS [curve_id],
       CASE 
            WHEN unpvt.Hours_from = 25 THEN dst.[hour]
            ELSE unpvt.Hours_from
       END                              Hours,
       (
           (
               CASE 
                    WHEN unpvt.deal_date <= @_as_of_date THEN unpvt.volume_from
                    ELSE 0
               END
           ) - CASE 
                    WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       )                                prior_volume,
       (
           CASE 
                WHEN unpvt.term_start > @_to_as_of_date
           AND unpvt.expiration_date > @_to_as_of_date
               THEN unpvt.volume_from
               ELSE 0
               END
       ) -(
           CASE 
                WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       )                                volume,
       (
           CASE 
                WHEN unpvt.deal_date <= @_as_of_date THEN unpvt.volume_from
                ELSE 0
           END
           - CASE 
                  WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       ) * ISNULL(
           CASE 
                WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo.DELTA)
                WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo.DELTA2)
                ELSE 1
           END,
           CASE 
                WHEN ISNULL(sdh.option_flag, ''n'') = ''y'' THEN 0
                ELSE 1
           END
       ) *
       CASE 
            WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
            ELSE 1
       END                              delta_prior_volume,
       (
           CASE 
                WHEN unpvt.term_start > @_to_as_of_date
           AND unpvt.expiration_date > @_to_as_of_date
               THEN unpvt.volume_from
               ELSE 0
               END
               - 
               CASE 
                    WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       ) * ISNULL(
           CASE 
                WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo1.DELTA)
                WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo1.DELTA2)
                ELSE 1
           END,
           CASE 
                WHEN ISNULL(sdh.option_flag, ''n'') = ''y'' THEN 0
                ELSE 1
           END
       ) *
       CASE 
            WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
            ELSE 1
       END                              delta_volume,
       CASE 
            WHEN unpvt.Hours_from = 25 THEN 1
            ELSE 0
       END                              is_dst,
       sub_book_id,
       proxy_curve_id3,
       unpvt.commodity_id,
       ''@period_from'' period_from,
       ''@period_to'' period_to,
       unpvt.period,
       block_name,
       hourly_block_id,
       [user_defined_block],
       [user_defined_block_id],
       (
           CASE 
                WHEN unpvt.term_start > @_to_as_of_date
           AND unpvt.expiration_date > @_to_as_of_date
               THEN unpvt.volume_from
               ELSE 0
               END
       ) -(
           CASE 
                WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       ) -(
           (
               CASE 
                    WHEN unpvt.deal_date <= @_as_of_date THEN unpvt.volume_from
                    ELSE 0
               END
           ) - CASE 
                    WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       )                                volume_change,
       (
           (
               CASE 
                    WHEN unpvt.term_start > @_to_as_of_date
               AND unpvt.expiration_date > @_to_as_of_date
                   THEN unpvt.volume_from
                   ELSE 0
                   END
                   - 
                   CASE 
                        WHEN dst.[hour] IS NOT NULL
               AND unpvt.Hours_from = dst.[hour]
                   THEN ISNULL(unpvt.dst_25, 0)
                   ELSE 0
                   END
           ) * ISNULL(
               CASE 
                    WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo.DELTA)
                    WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo.DELTA2)
                    ELSE 1
               END,
               CASE 
                    WHEN ISNULL(sdh.option_flag, ''n'') = ''y'' THEN 0
                    ELSE 1
               END
           ) *
           CASE 
                WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
                ELSE 1
           END
       )
       -(
           (
               CASE 
                    WHEN unpvt.deal_date <= @_as_of_date THEN unpvt.volume_from
                    ELSE 0
               END
               - CASE 
                      WHEN dst.[hour] IS NOT NULL
               AND unpvt.Hours_from = dst.[hour]
                   THEN ISNULL(unpvt.dst_25, 0)
                   ELSE 0
                   END
           ) * ISNULL(
               CASE 
                    WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo1.DELTA)
                    WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo1.DELTA2)
                    ELSE 1
               END,
               CASE 
                    WHEN ISNULL(sdh.option_flag, ''n'') = ''y'' THEN 0
                    ELSE 1
               END
           ) *
           CASE 
                WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
                ELSE 1
           END
       )                                delta_volume_change,
       CASE 
            WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo.DELTA)
            WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo.DELTA2)
            ELSE 0
       END *
       CASE 
            WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
            ELSE 1
       END                              delta,
       CASE 
            WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo1.DELTA)
            WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo1.DELTA2)
            ELSE 0
       END *
       CASE 
            WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
            ELSE 1
       END                              prior_delta,
       ''@exclude_sub_book_for_fin_pos'' exclude_sub_book_for_fin_pos,
       ''@change_report'' change_report,
       sdd.term_start deal_term_start
INTO #temp_hourly_position_detail       
FROM   #temp_hourly_position thp
       UNPIVOT(
           volume_from FOR Hours_from IN (thp.[01], thp.[02], thp.[03], thp.[04], 
                                         thp.[05], thp.[06], thp.[07], thp.[08], 
                                         thp.[09], thp.[10], thp.[11], thp.[12], 
                                         thp.[13], thp.[14], thp.[15], thp.[16], 
                                         thp.[17], thp.[18], thp.[19], thp.[20], 
                                         thp.[21], thp.[22], thp.[23], thp.[24], 
                                         thp.[25])
       )                             AS unpvt
       LEFT JOIN mv90_dst dst
            ON  dst.[date] = unpvt.term_start
            AND insert_delete = ''i''
       INNER JOIN source_deal_header sdh WITH(NOLOCK)
            ON  sdh.source_deal_header_id = unpvt.source_deal_header_id
       /*
        INNER JOIN vw_report_hourly_position_breakdown vw
            ON  vw.source_deal_header_id = sdh.source_deal_header_id
            AND ISNULL(unpvt.location_id, -1) = ISNULL(vw.location_id, -1)
		*/
       INNER JOIN source_deal_detail sdd WITH(NOLOCK)
            ON  sdd.source_deal_header_id = unpvt.source_deal_header_id
            AND unpvt.index_id = CASE 
                                      WHEN unpvt.is_fixedvolume = ''y'' THEN sdd.formula_curve_id
                                      ELSE sdd.curve_id
                                 END
            AND unpvt.term_start BETWEEN sdd.term_start AND sdd.term_end
            --AND ISNULL(unpvt.location_id, -1) = ISNULL(sdd.location_id, -1)
            AND unpvt.expiration_date > @_as_of_date
            AND unpvt.term_start >= @_term_start_from
       LEFT JOIN source_option_greeks_detail sdpdo WITH(NOLOCK)
            ON  sdpdo.as_of_date = @_as_of_date
            AND sdpdo.source_deal_header_id = unpvt.source_deal_header_id
            AND sdpdo.term_start = unpvt.term_start
            AND sdpdo.hr = unpvt.Hours_from
            AND sdpdo.is_dst = CASE 
                                    WHEN unpvt.Hours_from = 25 THEN 1
                                    ELSE 0
                               END
            AND sdpdo.period = unpvt.period
       LEFT JOIN source_option_greeks_detail sdpdo1 WITH(NOLOCK)
            ON  sdpdo1.as_of_date = @_to_as_of_date
            AND sdpdo1.source_deal_header_id = unpvt.source_deal_header_id
            AND sdpdo1.term_start = unpvt.term_start
            AND sdpdo1.hr = unpvt.Hours_from
            AND sdpdo1.is_dst = CASE 
                                     WHEN unpvt.Hours_from = 25 THEN 1
                                     ELSE 0
                                END
            AND sdpdo1.period = unpvt.period
WHERE  (
           unpvt.Hours_from < 25
           OR (unpvt.Hours_from = 25 AND dst.[hour] IS NOT NULL)
       )
       AND 1 = CASE @_invalid_date_range
                    WHEN 0 THEN 1
                    ELSE 2
               END
       AND unpvt.volume_from IS NOT     NULL
       
       
       
 SELECT 
	max(as_of_date) as_of_date,
	max(to_as_of_date) to_as_of_date,
	max(sub_id) sub_id,
	max(stra_id) stra_id,
	max(book_id) book_id,
	max(sub) sub,
	max(stra) stra,
	max(book) book,
	source_deal_header_id,
	max(deal_id) deal_id,
	max(physical_financial_flag) physical_financial_flag,
	max(deal_date) deal_date,
	max(location) location,
	max(curve_name) curve_name,
	max(proxy_index) proxy_index,
	max(region) region,
	max(country) country,
	max(grid) grid,
	max(location_group) location_group,
	max(commodity) commodity,
	max(deal_status) deal_status,
	max(counterparty_name) counterparty_name,
	max(parent_counterparty) parent_counterparty,
	max(term_year_month) term_year_month,
	deal_term_start term_start,
	max(group1) group1,
	max(group2) group2,
	max(group3) group3,
	max(group4) group4,
	max(sub_book) sub_book,
	max(uom) uom,
	max(postion_uom) postion_uom,
	max(proxy_curve2) proxy_curve2,
	max(proxy2_position_uom) proxy2_position_uom,
	max(proxy_curve3) proxy_curve3,
	max(proxy3_position_uom) proxy3_position_uom,
	max(block_definition) block_definition,
	max(deal_volume_frequency) deal_volume_frequency,
	max(proxy_curve) proxy_curve,
	max(proxy_curve_position_uom) proxy_curve_position_uom,
	max(term_year) term_year,
	max(term_end) term_end,
	max(counterparty_id) counterparty_id,
	max(location_id) location_id,
	max(proxy_index_position_uom) proxy_index_position_uom,
	max(curve_id) curve_id,
	max(Hours) Hours,
	sum(prior_volume) prior_volume,
	sum(volume) volume,
	sum(delta_prior_volume) delta_prior_volume,
	sum(delta_volume) delta_volume,
	max(is_dst) is_dst,
	max(sub_book_id) sub_book_id,
	max(proxy_curve_id3) proxy_curve_id3,
	max(commodity_id) commodity_id,
	max(period_from) period_from,
	max(period_to) period_to,
	max(period) period,
	hourly_block_id,
	max(block_name) block_name,
	max(user_defined_block) user_defined_block,
	max(user_defined_block_id) user_defined_block_id,
	sum(volume_change) volume_change,
	sum(delta_volume_change) delta_volume_change,
	(sum(delta_volume)/ CASE WHEN sum(volume) = 0 THEN 1 ELSE sum(volume) END) delta,
	(sum(delta_prior_volume)/CASE WHEN sum(volume) = 0 THEN 1 ELSE sum(volume) END)prior_delta,
	max(exclude_sub_book_for_fin_pos) exclude_sub_book_for_fin_pos,
	max(change_report) change_report,
	@_tenor_option [tenor_option]
--[__batch_report__]	
FROM #temp_hourly_position_detail
GROUP BY source_deal_header_id, deal_term_start, hourly_block_id', report_id = @report_id_data_source_dest 
		WHERE [name] = 'Position Monthly View'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Position Monthly View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'Position Monthly View' AS [name], 'PDTV' AS ALIAS, '' AS [description],'IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL
    DROP TABLE #books

IF OBJECT_ID(N''tempdb..#term_date'') IS NOT NULL
    DROP TABLE #term_date

IF OBJECT_ID(N''tempdb..#temp_hourly_position_detail'') IS NOT NULL
    DROP TABLE #temp_hourly_position_detail

DECLARE @_term_start_from DATETIME
DECLARE @_term_start_to DATETIME,
        @_sql VARCHAR(MAX)

DECLARE @_block_type_group_id     INT,
        @_as_of_date              VARCHAR(25) = ''@as_of_date'',
        @_to_as_of_date           VARCHAR(25) = ''@as_of_date'',
        @_change_report				CHAR(1)		= ''@change_report'',	-- Used for to generate change report or standard report , by default hidden in report paramset
        @_tenor_option				CHAR(1)		= ''@tenor_option'', -- Forward  / Show All 
        @_period_from				VARCHAR(50)	= ''@period_from'',
        @_period_to					VARCHAR(50)	= ''@period_to'',
        @_source_deal_header_id		VARCHAR(max)= ''@source_deal_header_id''

IF @user_defined_block_id IS NOT NULL
    SET @_block_type_group_id = ''@user_defined_block_id''

DECLARE @_temp_date VARCHAR(25) = @_as_of_date

IF ''@to_as_of_date'' <> ''NULL''
    SET @_to_as_of_date = ''@to_as_of_date''
    
IF ''@as_of_date'' = ''NULL'' AND ''@to_as_of_date'' IS NOT NULL AND @_change_report = ''1''
BEGIN
	SELECT @_as_of_date = CONVERT(char(10),  MAX(sdp.pnl_as_of_date),126) FROM source_deal_pnl AS sdp WHERE sdp.pnl_as_of_date < ''@to_as_of_date''
END
ELSE IF ''@as_of_date'' = ''NULL'' 
BEGIN
	SELECT @_as_of_date = ''@to_as_of_date''
END
	


	    
IF @_to_as_of_date IS NOT NULL
    SET @_temp_date = @_to_as_of_date

-- If period is not specified term start from to as of date default to as of date
SET @_term_start_from = @_to_as_of_date    	
IF ''@period_from'' <> ''NULL''
    SET @_term_start_from = dbo.FNAGetTermStartDate(''m'', @_temp_date, ''@period_from'')

IF ''@period_to'' <> ''NULL''
    SET @_term_start_to = dbo.FNAGetTermENDDate(''m'', @_temp_date, ''@period_to'')
 
 
IF @_tenor_option = ''2''
	SET @_as_of_date = ''1900-01-01''

IF @_tenor_option = ''2'' AND ''NULL'' = ''NULL''
begin
	SET @_term_start_from = ''1900-01-01''
	set @_to_as_of_date = ''1900-01-01''
end
   
--check invalid date range.
DECLARE @_invalid_date_range BIT = 0


IF DATEDIFF(DAY, @_as_of_date, @_to_as_of_date) < 0
    SET @_invalid_date_range = 1

CREATE TABLE #books
(
	book_deal_type_map_id      INT,
	fas_book_id                INT,
	source_system_book_id1     INT,
	source_system_book_id2     INT,
	source_system_book_id3     INT,
	source_system_book_id4     INT
)
SET @_sql = 
    ''
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

--when single as_of_date is passed
IF @_to_as_of_date IS NULL
    SET @_to_as_of_date = @_as_of_date

IF OBJECT_ID(N''tempdb..#temp_report_hourly_position_breakdown'') IS NOT NULL
    DROP TABLE #temp_report_hourly_position_breakdown

CREATE TABLE #temp_report_hourly_position_breakdown
(
	block_define_id     INT,
	term_start          DATETIME,
	term_end            DATETIME
)

SET @_sql = 
    ''
INSERT INTO	#temp_report_hourly_position_breakdown(block_define_id,term_start,term_end)  
SELECT distinct isnull(spcd.block_define_id,304625) block_define_id,s.term_start,s.term_end 
FROM report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
	AND bk.source_system_book_id1=s.source_system_book_id1 
	AND bk.source_system_book_id2=s.source_system_book_id2 
	AND bk.source_system_book_id3=s.source_system_book_id3 
	AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = s.deal_status_id  
LEFT JOIN source_price_curve_def spcd WITH (nolock) 
ON spcd.source_curve_def_id=s.curve_id 
WHERE 1=1''

IF ''@exclude_sub_book_for_fin_pos'' <> ''NULL''
    SET @_sql += '' AND bk.book_deal_type_map_id NOT IN ('' +
        ''@exclude_sub_book_for_fin_pos'' + '')''

SET @_sql += ''
AND ('''''' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) +
    '''''' = ''''NULL'''' OR s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) 
    + '')) '' + CASE 
                   WHEN @_term_start_from IS NULL
                        AND @_term_start_to IS NULL THEN ''''
                   WHEN @_term_start_to IS NULL THEN 
                        '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
                        + '''''' as DATETIME)''
                   WHEN @_term_start_from IS NULL THEN 
                        '' AND s.term_start =< CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
                        + ''''''as DATETIME)''
                   ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
                        + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
                        + ''''''as DATETIME)''
              END

PRINT (@_sql)

EXEC (@_sql + '' OPTION (maxdop 1)'')

CREATE TABLE #term_date
(
	block_define_id     INT,
	term_date           DATE,
	term_start          DATE,
	term_end            DATE,
	hr1                 TINYINT,
	hr2                 TINYINT,
	hr3                 TINYINT,
	hr4                 TINYINT,
	hr5                 TINYINT,
	hr6                 TINYINT,
	hr7                 TINYINT,
	hr8                 TINYINT,
	hr9                 TINYINT,
	hr10                TINYINT,
	hr11                TINYINT,
	hr12                TINYINT,
	hr13                TINYINT,
	hr14                TINYINT,
	hr15                TINYINT,
	hr16                TINYINT,
	hr17                TINYINT,
	hr18                TINYINT,
	hr19                TINYINT,
	hr20                TINYINT,
	hr21                TINYINT,
	hr22                TINYINT,
	hr23                TINYINT,
	hr24                TINYINT,
	add_dst_hour        INT
)

INSERT INTO #term_date
  (
    block_define_id,
    term_date,
    term_start,
    term_end,
    hr1,
    hr2,
    hr3,
    hr4,
    hr5,
    hr6,
    hr7,
    hr8,
    hr9,
    hr10,
    hr11,
    hr12,
    hr13,
    hr14,
    hr15,
    hr16,
    hr17,
    hr18,
    hr19,
    hr20,
    hr21,
    hr22,
    hr23,
    hr24,
    add_dst_hour
  )
SELECT DISTINCT a.block_define_id,
       hb.term_date,
       a.term_start,
       a.term_end,
       hb.hr1,
       hb.hr2,
       hb.hr3,
       hb.hr4,
       hb.hr5,
       hb.hr6,
       hb.hr7,
       hb.hr8,
       hb.hr9,
       hb.hr10,
       hb.hr11,
       hb.hr12,
       hb.hr13,
       hb.hr14,
       hb.hr15,
       hb.hr16,
       hb.hr17,
       hb.hr18,
       hb.hr19,
       hb.hr20,
       hb.hr21,
       hb.hr22,
       hb.hr23,
       hb.hr24,
       hb.add_dst_hour
FROM   #temp_report_hourly_position_breakdown a
       OUTER APPLY (
    SELECT h.*
    FROM   hour_block_term h WITH (NOLOCK)
    WHERE  block_define_id = a.block_define_id
           AND h.block_type = 12000
           AND term_date BETWEEN a.term_start
               AND a.term_end --and term_date>''@as_of_date''
) hb
OPTION(MAXDOP 1)

----- hourly position deal start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_deal'') IS NOT NULL
    DROP TABLE #temp_hourly_position_deal

CREATE TABLE #temp_hourly_position_deal
(
	curve_id                    INT,
	location_id                 INT,
	term_start                  DATETIME,
	period                      INT,
	deal_date                   DATETIME,
	deal_volume_uom_id          DATETIME,
	physical_financial_flag     VARCHAR(2) COLLATE DATABASE_DEFAULT,
	hr1                         FLOAT,
	hr2                         FLOAT,
	hr3                         FLOAT,
	hr4                         FLOAT,
	hr5                         FLOAT,
	hr6                         FLOAT,
	hr7                         FLOAT,
	hr8                         FLOAT,
	hr9                         FLOAT,
	hr10                        FLOAT,
	hr11                        FLOAT,
	hr12                        FLOAT,
	hr13                        FLOAT,
	hr14                        FLOAT,
	hr15                        FLOAT,
	hr16                        FLOAT,
	hr17                        FLOAT,
	hr18                        FLOAT,
	hr19                        FLOAT,
	hr20                        FLOAT,
	hr21                        FLOAT,
	hr22                        FLOAT,
	hr23                        FLOAT,
	hr24                        FLOAT,
	hr25                        FLOAT,
	source_deal_header_id       INT,
	commodity_id                INT,
	counterparty_id             INT,
	fas_book_id                 INT,
	source_system_book_id1      INT,
	source_system_book_id2      INT,
	source_system_book_id3      INT,
	source_system_book_id4      INT,
	expiration_date             DATETIME,
	is_fixedvolume              VARCHAR(2) COLLATE DATABASE_DEFAULT,
	deal_status_id              INT,
	deal_volume_frequency       VARCHAR(2) COLLATE DATABASE_DEFAULT,
	term_end                    DATETIME
)

SET @_sql = 
    ''INSERT INTO #temp_hourly_position_deal (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)	
SELECT s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_end 
FROM report_hourly_position_deal s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id
LEFT JOIN source_deal_detail sdd 
	ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.source_deal_detail_id = s.source_deal_detail_id  
WHERE 1=1 

AND ('''''' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) +
    '''''' = ''''NULL'''' OR s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) 
    + ''))''
	+ CASE WHEN @_tenor_option = ''1'' THEN '' 
AND s.deal_date<='''''' 
    + @_to_as_of_date + ''''''  AND s.expiration_date > '''''' + @_as_of_date +
    '''''' AND s.term_start > '''''' + @_as_of_date + '''''''' ELSE '''' END
 + CASE 
         WHEN @_term_start_from IS NULL
              AND @_term_start_to IS NULL THEN '' AND s.term_start > '''''' + @_as_of_date 
              + '''''' ''
         WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
              + '''''' as DATETIME) ''
         WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' +
              CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
         ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
              + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
              + ''''''as DATETIME)''
    END
                                                                   
PRINT (@_sql) 
EXEC (@_sql + '' OPTION (maxdop 1)'')

----- hourly position deal END
----- hourly position profile start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_profile'') IS NOT NULL
    DROP TABLE #temp_hourly_position_profile

CREATE TABLE #temp_hourly_position_profile
(
	curve_id                    INT,
	location_id                 INT,
	term_start                  DATETIME,
	period                      INT,
	deal_date                   DATETIME,
	deal_volume_uom_id          DATETIME,
	physical_financial_flag     VARCHAR(2) COLLATE DATABASE_DEFAULT,
	hr1                         FLOAT,
	hr2                         FLOAT,
	hr3                         FLOAT,
	hr4                         FLOAT,
	hr5                         FLOAT,
	hr6                         FLOAT,
	hr7                         FLOAT,
	hr8                         FLOAT,
	hr9                         FLOAT,
	hr10                        FLOAT,
	hr11                        FLOAT,
	hr12                        FLOAT,
	hr13                        FLOAT,
	hr14                        FLOAT,
	hr15                        FLOAT,
	hr16                        FLOAT,
	hr17                        FLOAT,
	hr18                        FLOAT,
	hr19                        FLOAT,
	hr20                        FLOAT,
	hr21                        FLOAT,
	hr22                        FLOAT,
	hr23                        FLOAT,
	hr24                        FLOAT,
	hr25                        FLOAT,
	source_deal_header_id       INT,
	commodity_id                INT,
	counterparty_id             INT,
	fas_book_id                 INT,
	source_system_book_id1      INT,
	source_system_book_id2      INT,
	source_system_book_id3      INT,
	source_system_book_id4      INT,
	expiration_date             DATETIME,
	is_fixedvolume              VARCHAR(2) COLLATE DATABASE_DEFAULT,
	deal_status_id              INT,
	deal_volume_frequency       VARCHAR(2) COLLATE DATABASE_DEFAULT,
	term_end                    DATETIME
)

SET @_sql = 
    ''
INSERT INTO #temp_hourly_position_profile (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
SELECT s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4 
,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_end 
FROM report_hourly_position_profile s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id 
AND bk.source_system_book_id1=s.source_system_book_id1	
AND bk.source_system_book_id2=s.source_system_book_id2	
AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id
LEFT JOIN source_deal_detail sdd 
	ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.source_deal_detail_id = s.source_deal_detail_id  
WHERE  1=1
AND s.deal_date<='''''' 
    + @_to_as_of_date + ''''''  AND s.expiration_date > '''''' + @_as_of_date +
    '''''' AND s.term_start > '''''' + @_as_of_date + ''''''
AND ('''''' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) +
    '''''' = ''''NULL'''' OR s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) 
    + ''))'' + CASE 
                  WHEN @_term_start_from IS NULL
                       AND @_term_start_to IS NULL THEN '' AND s.term_start > '''''' 
                       + @_as_of_date + '''''' ''
                  WHEN @_term_start_to IS NULL THEN 
                       '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
                       + '''''' as DATETIME) ''
                  WHEN @_term_start_from IS NULL THEN 
                       '' AND s.term_start =< CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
                       + ''''''as DATETIME) ''
                  ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
                       + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
                       + ''''''as DATETIME)''
             END

PRINT (@_sql)

EXEC (@_sql + '' OPTION (maxdop 1)'')

---- hourly position profile END
----- hourly position financial start
IF OBJECT_ID(N''tempdb..#temp_hourly_position_financial'') IS NOT NULL
    DROP TABLE #temp_hourly_position_financial

CREATE TABLE #temp_hourly_position_financial
(
	curve_id                    INT,
	location_id                 INT,
	term_start                  DATETIME,
	period                      INT,
	deal_date                   DATETIME,
	deal_volume_uom_id          DATETIME,
	physical_financial_flag     VARCHAR(2) COLLATE DATABASE_DEFAULT,
	hr1                         FLOAT,
	hr2                         FLOAT,
	hr3                         FLOAT,
	hr4                         FLOAT,
	hr5                         FLOAT,
	hr6                         FLOAT,
	hr7                         FLOAT,
	hr8                         FLOAT,
	hr9                         FLOAT,
	hr10                        FLOAT,
	hr11                        FLOAT,
	hr12                        FLOAT,
	hr13                        FLOAT,
	hr14                        FLOAT,
	hr15                        FLOAT,
	hr16                        FLOAT,
	hr17                        FLOAT,
	hr18                        FLOAT,
	hr19                        FLOAT,
	hr20                        FLOAT,
	hr21                        FLOAT,
	hr22                        FLOAT,
	hr23                        FLOAT,
	hr24                        FLOAT,
	hr25                        FLOAT,
	source_deal_header_id       INT,
	commodity_id                INT,
	counterparty_id             INT,
	fas_book_id                 INT,
	source_system_book_id1      INT,
	source_system_book_id2      INT,
	source_system_book_id3      INT,
	source_system_book_id4      INT,
	expiration_date             DATETIME,
	is_fixedvolume              VARCHAR(2) COLLATE DATABASE_DEFAULT,
	deal_status_id              INT,
	deal_volume_frequency       VARCHAR(2) COLLATE DATABASE_DEFAULT,
	term_end                    DATETIME
)

SET @_sql = 
    ''INSERT INTO #temp_hourly_position_financial (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
SELECT s.curve_id,s.location_id,s.term_start,s.period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2
	,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''''n'''' AS is_fixedvolume,deal_status_id,sdd.deal_volume_frequency,sdd.term_END 
FROM report_hourly_position_financial s  (nolock)  INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id AND bk.source_system_book_id1=s.source_system_book_id1	
AND bk.source_system_book_id2=s.source_system_book_id2 AND bk.source_system_book_id3=s.source_system_book_id3
AND bk.source_system_book_id4=s.source_system_book_id4 
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=s.curve_id
LEFT JOIN source_deal_detail sdd 
	ON s.term_start BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.source_deal_detail_id = s.source_deal_detail_id  
WHERE 1=1''

IF ''@exclude_sub_book_for_fin_pos'' <> ''NULL''
    SET @_sql += '' AND bk.book_deal_type_map_id NOT IN ('' +
        ''@exclude_sub_book_for_fin_pos'' + '')''

SET @_sql += ''
AND ('''''' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) +
    '''''' = ''''NULL'''' OR s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) 
    + ''))
AND s.deal_date<='''''' + @_as_of_date + ''''''  AND s.expiration_date > '''''' + @_as_of_date 
    + '''''' AND s.term_start > '''''' + @_as_of_date + '''''' '' 
    + CASE 
           WHEN @_term_start_from IS NULL
                AND @_term_start_to IS NULL THEN ''''
           WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' +
                CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME)''
           WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' +
                CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
           ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
                + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
                + ''''''as DATETIME)''
      END

PRINT (@_sql)

EXEC (@_sql)

----- hourly position financial END
IF OBJECT_ID(N''tempdb..#temp_hourly_position_breakdown'') IS NOT NULL
    DROP TABLE #temp_hourly_position_breakdown

----- hourly position breakdown start
CREATE TABLE #temp_hourly_position_breakdown
(
	curve_id                    INT,
	location_id                 INT,
	term_start                  DATETIME,
	period                      INT,
	deal_date                   DATETIME,
	deal_volume_uom_id          DATETIME,
	physical_financial_flag     VARCHAR(2) COLLATE DATABASE_DEFAULT,
	hr1                         FLOAT,
	hr2                         FLOAT,
	hr3                         FLOAT,
	hr4                         FLOAT,
	hr5                         FLOAT,
	hr6                         FLOAT,
	hr7                         FLOAT,
	hr8                         FLOAT,
	hr9                         FLOAT,
	hr10                        FLOAT,
	hr11                        FLOAT,
	hr12                        FLOAT,
	hr13                        FLOAT,
	hr14                        FLOAT,
	hr15                        FLOAT,
	hr16                        FLOAT,
	hr17                        FLOAT,
	hr18                        FLOAT,
	hr19                        FLOAT,
	hr20                        FLOAT,
	hr21                        FLOAT,
	hr22                        FLOAT,
	hr23                        FLOAT,
	hr24                        FLOAT,
	hr25                        FLOAT,
	source_deal_header_id       INT,
	commodity_id                INT,
	counterparty_id             INT,
	fas_book_id                 INT,
	source_system_book_id1      INT,
	source_system_book_id2      INT,
	source_system_book_id3      INT,
	source_system_book_id4      INT,
	expiration_date             DATETIME,
	is_fixedvolume              VARCHAR(2) COLLATE DATABASE_DEFAULT,
	deal_status_id              INT,
	deal_volume_frequency       VARCHAR(2) COLLATE DATABASE_DEFAULT,
	term_end                    DATETIME
)

DECLARE @_sql1     VARCHAR(MAX),
        @_sql2     VARCHAR(MAX),
        @_sql3     VARCHAR(MAX)

SET @_sql = 
    ''
INSERT INTO #temp_hourly_position_breakdown (curve_id,location_id,term_start,period,deal_date,deal_volume_uom_id,physical_financial_flag,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25,source_deal_header_id,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,expiration_date,is_fixedvolume,deal_status_id,deal_volume_frequency,term_END)
SELECT s.curve_id,ISNULL(s.location_id,-1) location_id,hb.term_date term_start,0 period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    +
    @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr1
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr2
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr3
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr4
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr5
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr6
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr7
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr8
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr9
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr10
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr11
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr12
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr13
''

SET @_sql1 = 
    '',(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr14
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr15
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr16
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr17
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr18
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr19
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr20
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr21
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr22
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr23
,(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date + '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date 
    +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  AS Hr24
,(cast(cast(s.calc_volume as numeric(22,10))* cast(CASE WHEN isnull(hb.add_dst_hour,0)<=0 THEN 0 ELSE 1 END as numeric(1,0)) as numeric(22,10))) /cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''''' 
    + @_as_of_date +
    '''''')) AS VARCHAR)+''''-''''+CAST(MONTH(DATEADD(m,1,'''''' + @_as_of_date +
    '''''')) AS VARCHAR)+''''-01'''' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) AS Hr25 
,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,CASE WHEN s.formula IN(''''dbo.FNACurveH'''',''''dbo.FNACurveD'''') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END expiration_date,''''y'''' AS is_fixedvolume ,deal_status_id, ''''m'''' [deal_volume_frequency],s.term_end [term_end] --[deal_volume_frequency] for finalcial deals are always monthly  
''

SET @_sql2 = 
    ''FROM report_hourly_position_breakdown s  (nolock)  
INNER JOIN #books bk ON bk.fas_book_id=s.fas_book_id
	AND bk.source_system_book_id1=s.source_system_book_id1 
	AND bk.source_system_book_id2=s.source_system_book_id2
	AND bk.source_system_book_id3=s.source_system_book_id3 
	AND bk.source_system_book_id4=s.source_system_book_id4
INNER JOIN [deal_status_group] dsg ON  dsg.status_value_id = s.deal_status_id 
LEFT JOIN source_price_curve_def spcd WITH (nolock) ON spcd.source_curve_def_id=s.curve_id 
LEFT JOIN source_price_curve_def spcd_proxy (nolock) ON spcd_proxy.source_curve_def_id=spcd.settlement_curve_id
outer apply (SELECT sum(volume_mult) term_no_hrs FROM hour_block_term hbt WHERE isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,304625)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END ) term_hrs
outer apply ( SELECT sum(volume_mult) term_no_hrs FROM hour_block_term hbt inner JOIN (SELECT distinct exp_date FROM holiday_group h WHERE  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex ON ex.exp_date=hbt.term_date
WHERE  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,304625)	and  hbt.block_type=COALESCE(spcd.block_type,12000) and hbt.term_date between s.term_start  and s.term_END) term_hrs_exp
LEFT JOIN #term_date hb ON hb.block_define_id=isnull(spcd.block_define_id,304625) and hb.term_start = s.term_start
and hb.term_end=s.term_end 
outer apply  (SELECT MAX(exp_date) exp_date FROM holiday_group h WHERE h.hol_date=hb.term_date AND 
h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
outer apply  (SELECT MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  FROM holiday_group h WHERE 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''''REBD'''')) hg1   
outer apply  (SELECT count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''''' 
    + @_as_of_date +
    '''''' THEN 1 ELSE 0 END) remain_days FROM holiday_group h WHERE h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd_proxy.exp_calendar_id) 
AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
AND ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''''REBD'''')) remain_month  
WHERE ((ISNULL(spcd_proxy.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''''9999-01-01'''')>'''''' 
    + @_as_of_date +
    '''''') OR COALESCE(spcd_proxy.ratio_option,spcd.ratio_option,-1) <> 18800)
AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
AND s.deal_date<='''''' + @_to_as_of_date + ''''''
AND ('''''' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) +
    '''''' = ''''NULL'''' OR s.source_deal_header_id IN ('' + CAST(@_source_deal_header_id AS VARCHAR(MAX)) 
    + ''))'' +
    --CASE
    --	WHEN @_term_start_from IS NULL AND @_term_start_to IS NULL THEN '' AND s.term_start > '''''' + @_as_of_date + '''''' ''
    --	WHEN @_term_start_to IS NULL THEN '' AND s.term_start >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) ''
    --	WHEN @_term_start_from IS NULL THEN '' AND s.term_start =< CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
    --	ELSE '' AND s.term_start BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) + '''''' as DATETIME) AND CAST('''''' +  CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME)''
    --END
    CASE 
         WHEN @_term_start_from IS NULL
              AND @_term_start_to IS NULL THEN '' AND hb.term_date > '''''' + @_as_of_date 
              + '''''' ''
         WHEN @_term_start_to IS NULL THEN '' AND hb.term_date >= CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
              + '''''' as DATETIME) ''
         WHEN @_term_start_from IS NULL THEN '' AND hb.term_date =< CAST('''''' +
              CAST(@_term_start_to AS VARCHAR(100)) + ''''''as DATETIME) ''
         ELSE '' AND hb.term_date BETWEEN CAST('''''' + CAST(@_term_start_from AS VARCHAR(100)) 
              + '''''' as DATETIME) AND CAST('''''' + CAST(@_term_start_to AS VARCHAR(100)) 
              + ''''''as DATETIME)''
    END

PRINT (@_sql)
PRINT (@_sql1)
PRINT (@_sql2)

EXEC (@_sql + @_sql1 + @_sql2 + '' OPTION (loop join)'')

-- hourly position breakdown END
CREATE INDEX indxterm_dat ON #term_date(block_define_id, term_start, term_end)

IF OBJECT_ID(N''tempdb..#temp_position_table'') IS NOT NULL
    DROP TABLE #temp_position_table

SELECT *
       INTO     #temp_position_table
FROM   (
           SELECT *
           FROM   #temp_hourly_position_deal
           
           UNION ALL
           
           SELECT *
           FROM   #temp_hourly_position_profile
           
           UNION ALL
           
           SELECT *
           FROM   #temp_hourly_position_breakdown
           
           UNION ALL
           
           SELECT *
           FROM   #temp_hourly_position_financial
       )        pos

IF OBJECT_ID(N''tempdb..#temp_block_type_group_table'') IS NOT NULL
    DROP TABLE #temp_block_type_group_table

CREATE TABLE #temp_block_type_group_table
(
	block_type_group_id     INT,
	block_type_id           INT,
	block_name              VARCHAR(200) COLLATE DATABASE_DEFAULT,
	hourly_block_id         INT
)

IF (@_block_type_group_id IS NOT NULL)
    SET @_sql = 
        ''INSERT INTO #temp_block_type_group_table(block_type_group_id, block_type_id, block_name, hourly_block_id)
				SELECT block_type_group_id,block_type_id,block_name,hourly_block_id 				
				FROM block_type_group 
				WHERE block_type_group_id='' + CAST(@_block_type_group_id AS VARCHAR(100))
ELSE
    SET @_sql = 
        ''INSERT INTO #temp_block_type_group_table(block_type_group_id, block_type_id, block_name, hourly_block_id)
				SELECT NULL block_type_group_id, NULL block_type_id, ''''Baseload'''' block_name, 304625 hourly_block_id''

PRINT (@_sql)

EXEC (@_sql + '' OPTION (maxdop 1)'')

/*
--original index
CREATE INDEX ix_pt_tpt ON #temp_position_table (
	expiration_date
	, location_id
	, curve_id
	, fas_book_id
	) INCLUDE (
	source_system_book_id1
	, source_system_book_id2
	, source_system_book_id3
	, source_system_book_id4
	)
*/

--copied from Position View Hourly With Block Type
CREATE INDEX ix_pt_tpt ON #temp_position_table(
                                                  source_deal_header_id,
                                                  term_start,
                                                  location_id,
                                                  curve_id,
                                                  counterparty_id,
                                                  expiration_date
                                              ) INCLUDE(
                                                           source_system_book_id1,
                                                           source_system_book_id2,
                                                           source_system_book_id3,
                                                           source_system_book_id4
                                                       )

CREATE INDEX ix_pt_block ON #temp_block_type_group_table(hourly_block_id, block_type_id, block_type_group_id) 
INCLUDE(block_name)

IF OBJECT_ID(N''tempdb..#temp_hourly_position'') IS NOT NULL
    DROP TABLE #temp_hourly_position

SELECT CAST(@_as_of_date AS DATETIME)     as_of_date,
       CAST(@_to_as_of_date AS DATETIME)     to_as_of_date,
       sub.entity_id                         sub_id,
       stra.entity_id                        stra_id,
       book.entity_id                        book_id,
       sub.entity_name                       sub,
       stra.entity_name                      strategy,
       book.entity_name                      book,
       vw.source_deal_header_id,
       sdh.deal_id                           deal_id,
       (
           CASE 
                WHEN vw.physical_financial_flag = ''p'' THEN ''Physical''
                ELSE ''Financial''
           END
       )                                     physical_financial_flag,
       vw.deal_date                          deal_date,
       sml.Location_Name                     location,
       spcd.curve_name [index],
       spcd_proxy.curve_name                 proxy_index,
       sdv2.code                             region,
       sdv.code                              country,
       sdv1.code                             grid,
       mjr.location_name                     location_group,
       com.commodity_name                    commodity,
       sdv_deal_staus.code                   deal_status,
       sc.counterparty_name                  counterparty_name,
       sc.counterparty_name                  parent_counterparty,
       CONVERT(VARCHAR(7), vw.term_start, 120) term_year_month,
       vw.term_start                         term_start,
       sb1.source_book_name                  book_identifier1,
       sb2.source_book_name                  book_identifier2,
       sb3.source_book_name                  book_identifier3,
       sb4.source_book_name                  book_identifier4,
       ssbm.logical_name                  AS sub_book,
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr7 ELSE hb.hr1 END * vw.Hr1 [01],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr8 ELSE hb.hr2 END * vw.Hr2 [02],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr9 ELSE hb.hr3 END * vw.Hr3 [03],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr10 ELSE hb.hr4 END * vw.Hr4 [04],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr11 ELSE hb.hr5 END * vw.Hr5 [05],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr12 ELSE hb.hr6 END * vw.Hr6 [06],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr13 ELSE hb.hr7 END * vw.Hr7 [07],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr14 ELSE hb.hr8 END * vw.Hr8 [08],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr15 ELSE hb.hr9 END * vw.Hr9 [09],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr16 ELSE hb.hr10 END * vw.Hr10 [10],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr17 ELSE hb.hr11 END * vw.Hr11 [11],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr18 ELSE hb.hr12 END * vw.Hr12 [12],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr19 ELSE hb.hr13 END * vw.Hr13 [13],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr20 ELSE hb.hr14 END * vw.Hr14 [14],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr21 ELSE hb.hr15 END * vw.Hr15 [15],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr22 ELSE hb.hr16 END * vw.Hr16 [16],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr23 ELSE hb.hr17 END * vw.Hr17 [17],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr24 ELSE hb.hr18 END * vw.Hr18 [18],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr1 ELSE hb.hr19 END * vw.Hr19 [19],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr2 ELSE hb.hr20 END * vw.Hr20 [20],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr3 ELSE hb.hr21 END * vw.Hr21 [21],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr4 ELSE hb.hr22 END * vw.Hr22 [22],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr5 ELSE hb.hr23 END * vw.Hr23 [23],
       CASE WHEN com.source_commodity_id= -1 AND vw.is_fixedvolume = ''n'' THEN hb1.hr6 ELSE hb.hr24 END * vw.Hr24 [24],
       NULLIF(hb.hr3, 0) * vw.Hr25 [25],
       NULLIF(hb.hr3, 0) * vw.Hr25 [dst_25],
       su_uom.uom_name [uom],
       su_pos_uom.uom_name [postion_uom],
       spcd_monthly_index.curve_name + CASE 
                                            WHEN sssd.source_system_id = 2 THEN 
                                                 ''''
                                            ELSE ''.'' + sssd.source_system_name
                                       END AS [proxy_curve2],
       su_uom_proxy2.uom_name [proxy2_position_uom],
       spcd_proxy_curve3.curve_name + CASE 
                                           WHEN sssd2.source_system_id = 2 THEN 
                                                ''''
                                           ELSE ''.'' + sssd2.source_system_name
                                      END AS [proxy_curve3],
       su_uom_proxy3.uom_name [proxy3_position_uom],
       sdv_block.code [block_definition],
       CASE 
            WHEN vw.deal_volume_frequency = ''h'' THEN ''Hourly''
            WHEN vw.deal_volume_frequency = ''d'' THEN ''Daily''
            WHEN vw.deal_volume_frequency = ''m'' THEN ''Monthly''
            WHEN vw.deal_volume_frequency = ''t'' THEN ''Term''
            WHEN vw.deal_volume_frequency = ''a'' THEN ''Annually''
            WHEN vw.deal_volume_frequency = ''x'' THEN ''15 Minutes''
            WHEN vw.deal_volume_frequency = ''y'' THEN ''30 Minutes''
       END [deal_volume_frequency],
       spcd_proxy_curve_def.curve_name [proxy_curve],
       su_uom_proxy_curve_def.uom_name [proxy_curve_position_uom],
       YEAR(vw.term_start)                   term_year,
       vw.term_start                         term_end,
       sc.source_counterparty_id             counterparty_id,
       sml.source_minor_location_id          location_id,
       su_uom_proxy_curve.uom_name           proxy_index_position_uom,
       spcd.source_curve_def_id [index_id],
       vw.period,
       ssbm.book_deal_type_map_id [sub_book_id],
       spcd.proxy_curve_id3,
       vw.expiration_date,
       spcd.commodity_id,
       ISNULL(grp.block_name, spcd.curve_name) block_name,
       ISNULL(grp.hourly_block_id, spcd.source_curve_def_id) hourly_block_id,
       sdv_block_group.code [user_defined_block],
       sdv_block_group.value_id [user_defined_block_id],
       vw.is_fixedvolume
INTO #temp_hourly_position
FROM   #temp_position_table vw
       CROSS JOIN #temp_block_type_group_table grp
       LEFT JOIN source_minor_location sml WITH (NOLOCK)
            ON  sml.source_minor_location_id = vw.location_id
       INNER JOIN source_price_curve_def spcd WITH (NOLOCK)
            ON  spcd.source_curve_def_id = vw.curve_id
       LEFT JOIN source_price_curve_def spcd_proxy WITH (NOLOCK)
            ON  spcd_proxy.source_curve_def_id = spcd.proxy_curve_id
       LEFT JOIN source_price_curve_def spcd_proxy_curve3 WITH (NOLOCK)
            ON  spcd_proxy_curve3.source_curve_def_id = spcd.proxy_curve_id3
       LEFT JOIN source_price_curve_def spcd_monthly_index WITH (NOLOCK)
            ON  spcd_monthly_index.source_curve_def_id = spcd.monthly_index
       LEFT JOIN source_price_curve_def spcd_proxy_curve_def WITH (NOLOCK)
            ON  spcd_proxy_curve_def.source_curve_def_id = spcd.proxy_source_curve_def_id
       LEFT JOIN hour_block_term hb WITH (NOLOCK)
            ON  hb.block_define_id = COALESCE(grp.hourly_block_id, 304625)
            AND hb.block_type = COALESCE(grp.block_type_id, 12000)
            AND vw.term_start = hb.term_date
	   LEFT JOIN hour_block_term hb1 (nolock)  
			ON hb.block_define_id=hb1.block_define_id 
			AND  hb.block_type=hb1.block_type 
			AND hb.term_date=hb1.term_date-1
       LEFT JOIN source_system_description sssd WITH (NOLOCK)
            ON  sssd.source_system_id = spcd_monthly_index.source_system_id
       LEFT JOIN source_system_description sssd2 WITH (NOLOCK)
            ON  sssd.source_system_id = spcd_proxy_curve3.source_system_id
       LEFT JOIN static_data_value sdv1 WITH (NOLOCK)
            ON  sdv1.value_id = sml.grid_value_id
       LEFT JOIN static_data_value sdv WITH (NOLOCK)
            ON  sdv.value_id = sml.country
       LEFT JOIN static_data_value sdv2 WITH (NOLOCK)
            ON  sdv2.value_id = sml.region
       LEFT JOIN source_major_location mjr WITH (NOLOCK)
            ON  sml.source_major_location_ID = mjr.source_major_location_ID
       LEFT JOIN source_uom               AS su_pos_uom WITH (NOLOCK)
            ON  su_pos_uom.source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)
       LEFT JOIN source_uom su_uom WITH (NOLOCK)
            ON  su_uom.source_uom_id = spcd.uom_id
       LEFT JOIN source_uom su_uom_proxy3 WITH (NOLOCK)
            ON  su_uom_proxy3.source_uom_id = ISNULL(spcd_proxy_curve3.display_uom_id, spcd_proxy_curve3.uom_id) --spcd_proxy_curve3.display_uom_id
                
       LEFT JOIN source_uom su_uom_proxy2 WITH (NOLOCK)
            ON  su_uom_proxy2.source_uom_id = ISNULL(
                    spcd_monthly_index.display_uom_id,
                    spcd_monthly_index.uom_id
                )
       LEFT JOIN source_uom su_uom_proxy_curve_def WITH (NOLOCK)
            ON  su_uom_proxy_curve_def.source_uom_id = ISNULL(
                    spcd_proxy_curve_def.display_uom_id,
                    spcd_proxy_curve_def.uom_id
                ) --spcd_proxy_curve_def.display_uom_id
                
       LEFT JOIN source_uom su_uom_proxy_curve WITH (NOLOCK)
            ON  su_uom_proxy_curve.source_uom_id = ISNULL(spcd_proxy.display_uom_id, spcd_proxy.uom_id)
       LEFT JOIN source_counterparty sc WITH (NOLOCK)
            ON  sc.source_counterparty_id = vw.counterparty_id
       LEFT JOIN source_counterparty psc WITH (NOLOCK)
            ON  psc.source_counterparty_id = sc.parent_counterparty_id
       LEFT JOIN source_commodity com WITH (NOLOCK)
            ON  com.source_commodity_id = spcd.commodity_id
       LEFT JOIN portfolio_hierarchy book WITH (NOLOCK)
            ON  book.entity_id = vw.fas_book_id
       LEFT JOIN portfolio_hierarchy stra WITH (NOLOCK)
            ON  stra.entity_id = book.parent_entity_id
       LEFT JOIN portfolio_hierarchy sub WITH (NOLOCK)
            ON  sub.entity_id = stra.parent_entity_id
       LEFT JOIN source_deal_header sdh WITH (NOLOCK)
            ON  sdh.source_deal_header_id = vw.source_deal_header_id
       LEFT JOIN static_data_value sdv_deal_staus WITH (NOLOCK)
            ON  sdv_deal_staus.value_id = vw.deal_status_id
       LEFT JOIN source_system_book_map ssbm WITH (NOLOCK)
            ON  ssbm.source_system_book_id1 = vw.source_system_book_id1
            AND ssbm.source_system_book_id2 = vw.source_system_book_id2
            AND ssbm.source_system_book_id3 = vw.source_system_book_id3
            AND ssbm.source_system_book_id4 = vw.source_system_book_id4
       LEFT JOIN source_book sb1 WITH (NOLOCK)
            ON  sb1.source_book_id = vw.source_system_book_id1
       LEFT JOIN source_book sb2 WITH (NOLOCK)
            ON  sb2.source_book_id = vw.source_system_book_id2
       LEFT JOIN source_book sb3 WITH (NOLOCK)
            ON  sb3.source_book_id = vw.source_system_book_id3
       LEFT JOIN source_book sb4 WITH (NOLOCK)
            ON  sb4.source_book_id = vw.source_system_book_id4
       LEFT JOIN static_data_value sdv_block WITH (NOLOCK)
            ON  sdv_block.value_id = sdh.block_define_id
       LEFT JOIN static_data_value sdv_block_group WITH (NOLOCK)
            ON  sdv_block_group.value_id = grp.block_type_group_id
WHERE  vw.expiration_date > @_as_of_date
       AND vw.term_start > @_as_of_date
           OPTION(MAXRECURSION 32767)

IF OBJECT_ID(N''tempdb..#final_temp_position_value'') IS NOT NULL
    DROP TABLE #final_temp_position_value

CREATE INDEX ix_pt_test1 ON #temp_hourly_position(deal_date, source_deal_header_id) 
INCLUDE(
           [01],
           [02],
           [03],
           [04],
           [05],
           [06],
           [07],
           [08],
           [09],
           [10],
           [11],
           [12],
           [13],
           [14],
           [15],
           [16],
           [17],
           [18],
           [19],
           [20],
           [21],
           [22],
           [23],
           [24],
           [25]
       )


SELECT unpvt.as_of_date,
       to_as_of_date,
       sub_id,
       stra_id,
       book_id,
       sub,
       strategy [stra],
       book,
       unpvt.source_deal_header_id,
       unpvt.deal_id,
       unpvt.physical_financial_flag,
       unpvt.deal_date,
       location,
       [index]                       AS curve_name,
       proxy_index,
       region,
       country,
       grid,
       location_group,
       commodity,
       unpvt.deal_status,
       counterparty_name,
       parent_counterparty,
       term_year_month,
       unpvt.term_start,
       book_identifier1 [group1],
       book_identifier2 [group2],
       book_identifier3 [group3],
       book_identifier4 [group4],
       unpvt.sub_book,
       uom,
       postion_uom,
       proxy_curve2,
       proxy2_position_uom,
       proxy_curve3,
       proxy3_position_uom,
       block_definition,
       unpvt.deal_volume_frequency,
       proxy_curve,
       proxy_curve_position_uom,
       term_year,
       unpvt.term_end,
       unpvt.counterparty_id,
       unpvt.location_id,
       proxy_index_position_uom,
       index_id                      AS [curve_id],
       CASE 
            WHEN unpvt.Hours_from = 25 THEN dst.[hour]
            ELSE unpvt.Hours_from
       END                              Hours,
       (
           (
               CASE 
                    WHEN unpvt.deal_date <= @_as_of_date THEN unpvt.volume_from
                    ELSE 0
               END
           ) - CASE 
                    WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       )                                prior_volume,
       (
           CASE 
                WHEN unpvt.term_start > @_to_as_of_date
           AND unpvt.expiration_date > @_to_as_of_date
               THEN unpvt.volume_from
               ELSE 0
               END
       ) -(
           CASE 
                WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       )                                volume,
       (
           CASE 
                WHEN unpvt.deal_date <= @_as_of_date THEN unpvt.volume_from
                ELSE 0
           END
           - CASE 
                  WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       ) * ISNULL(
           CASE 
                WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo.DELTA)
                WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo.DELTA2)
                ELSE 1
           END,
           CASE 
                WHEN ISNULL(sdh.option_flag, ''n'') = ''y'' THEN 0
                ELSE 1
           END
       ) *
       CASE 
            WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
            ELSE 1
       END                              delta_prior_volume,
       (
           CASE 
                WHEN unpvt.term_start > @_to_as_of_date
           AND unpvt.expiration_date > @_to_as_of_date
               THEN unpvt.volume_from
               ELSE 0
               END
               - 
               CASE 
                    WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       ) * ISNULL(
           CASE 
                WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo1.DELTA)
                WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo1.DELTA2)
                ELSE 1
           END,
           CASE 
                WHEN ISNULL(sdh.option_flag, ''n'') = ''y'' THEN 0
                ELSE 1
           END
       ) *
       CASE 
            WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
            ELSE 1
       END                              delta_volume,
       CASE 
            WHEN unpvt.Hours_from = 25 THEN 1
            ELSE 0
       END                              is_dst,
       sub_book_id,
       proxy_curve_id3,
       unpvt.commodity_id,
       ''@period_from'' period_from,
       ''@period_to'' period_to,
       unpvt.period,
       block_name,
       hourly_block_id,
       [user_defined_block],
       [user_defined_block_id],
       (
           CASE 
                WHEN unpvt.term_start > @_to_as_of_date
           AND unpvt.expiration_date > @_to_as_of_date
               THEN unpvt.volume_from
               ELSE 0
               END
       ) -(
           CASE 
                WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       ) -(
           (
               CASE 
                    WHEN unpvt.deal_date <= @_as_of_date THEN unpvt.volume_from
                    ELSE 0
               END
           ) - CASE 
                    WHEN dst.[hour] IS NOT NULL
           AND unpvt.Hours_from = dst.[hour]
               THEN ISNULL(unpvt.dst_25, 0)
               ELSE 0
               END
       )                                volume_change,
       (
           (
               CASE 
                    WHEN unpvt.term_start > @_to_as_of_date
               AND unpvt.expiration_date > @_to_as_of_date
                   THEN unpvt.volume_from
                   ELSE 0
                   END
                   - 
                   CASE 
                        WHEN dst.[hour] IS NOT NULL
               AND unpvt.Hours_from = dst.[hour]
                   THEN ISNULL(unpvt.dst_25, 0)
                   ELSE 0
                   END
           ) * ISNULL(
               CASE 
                    WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo.DELTA)
                    WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo.DELTA2)
                    ELSE 1
               END,
               CASE 
                    WHEN ISNULL(sdh.option_flag, ''n'') = ''y'' THEN 0
                    ELSE 1
               END
           ) *
           CASE 
                WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
                ELSE 1
           END
       )
       -(
           (
               CASE 
                    WHEN unpvt.deal_date <= @_as_of_date THEN unpvt.volume_from
                    ELSE 0
               END
               - CASE 
                      WHEN dst.[hour] IS NOT NULL
               AND unpvt.Hours_from = dst.[hour]
                   THEN ISNULL(unpvt.dst_25, 0)
                   ELSE 0
                   END
           ) * ISNULL(
               CASE 
                    WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo1.DELTA)
                    WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo1.DELTA2)
                    ELSE 1
               END,
               CASE 
                    WHEN ISNULL(sdh.option_flag, ''n'') = ''y'' THEN 0
                    ELSE 1
               END
           ) *
           CASE 
                WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
                ELSE 1
           END
       )                                delta_volume_change,
       CASE 
            WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo.DELTA)
            WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo.DELTA2)
            ELSE 0
       END *
       CASE 
            WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
            ELSE 1
       END                              delta,
       CASE 
            WHEN ISNULL(sdd.leg, -1) = 1 THEN ABS(sdpdo1.DELTA)
            WHEN ISNULL(sdd.leg, -1) = 2 THEN ABS(sdpdo1.DELTA2)
            ELSE 0
       END *
       CASE 
            WHEN ISNULL(sdh.option_type, ''c'') = ''p'' THEN -1
            ELSE 1
       END                              prior_delta,
       ''@exclude_sub_book_for_fin_pos'' exclude_sub_book_for_fin_pos,
       ''@change_report'' change_report,
       sdd.term_start deal_term_start
INTO #temp_hourly_position_detail       
FROM   #temp_hourly_position thp
       UNPIVOT(
           volume_from FOR Hours_from IN (thp.[01], thp.[02], thp.[03], thp.[04], 
                                         thp.[05], thp.[06], thp.[07], thp.[08], 
                                         thp.[09], thp.[10], thp.[11], thp.[12], 
                                         thp.[13], thp.[14], thp.[15], thp.[16], 
                                         thp.[17], thp.[18], thp.[19], thp.[20], 
                                         thp.[21], thp.[22], thp.[23], thp.[24], 
                                         thp.[25])
       )                             AS unpvt
       LEFT JOIN mv90_dst dst
            ON  dst.[date] = unpvt.term_start
            AND insert_delete = ''i''
       INNER JOIN source_deal_header sdh WITH(NOLOCK)
            ON  sdh.source_deal_header_id = unpvt.source_deal_header_id
       /*
        INNER JOIN vw_report_hourly_position_breakdown vw
            ON  vw.source_deal_header_id = sdh.source_deal_header_id
            AND ISNULL(unpvt.location_id, -1) = ISNULL(vw.location_id, -1)
		*/
       INNER JOIN source_deal_detail sdd WITH(NOLOCK)
            ON  sdd.source_deal_header_id = unpvt.source_deal_header_id
            AND unpvt.index_id = CASE 
                                      WHEN unpvt.is_fixedvolume = ''y'' THEN sdd.formula_curve_id
                                      ELSE sdd.curve_id
                                 END
            AND unpvt.term_start BETWEEN sdd.term_start AND sdd.term_end
            --AND ISNULL(unpvt.location_id, -1) = ISNULL(sdd.location_id, -1)
            AND unpvt.expiration_date > @_as_of_date
            AND unpvt.term_start >= @_term_start_from
       LEFT JOIN source_option_greeks_detail sdpdo WITH(NOLOCK)
            ON  sdpdo.as_of_date = @_as_of_date
            AND sdpdo.source_deal_header_id = unpvt.source_deal_header_id
            AND sdpdo.term_start = unpvt.term_start
            AND sdpdo.hr = unpvt.Hours_from
            AND sdpdo.is_dst = CASE 
                                    WHEN unpvt.Hours_from = 25 THEN 1
                                    ELSE 0
                               END
            AND sdpdo.period = unpvt.period
       LEFT JOIN source_option_greeks_detail sdpdo1 WITH(NOLOCK)
            ON  sdpdo1.as_of_date = @_to_as_of_date
            AND sdpdo1.source_deal_header_id = unpvt.source_deal_header_id
            AND sdpdo1.term_start = unpvt.term_start
            AND sdpdo1.hr = unpvt.Hours_from
            AND sdpdo1.is_dst = CASE 
                                     WHEN unpvt.Hours_from = 25 THEN 1
                                     ELSE 0
                                END
            AND sdpdo1.period = unpvt.period
WHERE  (
           unpvt.Hours_from < 25
           OR (unpvt.Hours_from = 25 AND dst.[hour] IS NOT NULL)
       )
       AND 1 = CASE @_invalid_date_range
                    WHEN 0 THEN 1
                    ELSE 2
               END
       AND unpvt.volume_from IS NOT     NULL
       
       
       
 SELECT 
	max(as_of_date) as_of_date,
	max(to_as_of_date) to_as_of_date,
	max(sub_id) sub_id,
	max(stra_id) stra_id,
	max(book_id) book_id,
	max(sub) sub,
	max(stra) stra,
	max(book) book,
	source_deal_header_id,
	max(deal_id) deal_id,
	max(physical_financial_flag) physical_financial_flag,
	max(deal_date) deal_date,
	max(location) location,
	max(curve_name) curve_name,
	max(proxy_index) proxy_index,
	max(region) region,
	max(country) country,
	max(grid) grid,
	max(location_group) location_group,
	max(commodity) commodity,
	max(deal_status) deal_status,
	max(counterparty_name) counterparty_name,
	max(parent_counterparty) parent_counterparty,
	max(term_year_month) term_year_month,
	deal_term_start term_start,
	max(group1) group1,
	max(group2) group2,
	max(group3) group3,
	max(group4) group4,
	max(sub_book) sub_book,
	max(uom) uom,
	max(postion_uom) postion_uom,
	max(proxy_curve2) proxy_curve2,
	max(proxy2_position_uom) proxy2_position_uom,
	max(proxy_curve3) proxy_curve3,
	max(proxy3_position_uom) proxy3_position_uom,
	max(block_definition) block_definition,
	max(deal_volume_frequency) deal_volume_frequency,
	max(proxy_curve) proxy_curve,
	max(proxy_curve_position_uom) proxy_curve_position_uom,
	max(term_year) term_year,
	max(term_end) term_end,
	max(counterparty_id) counterparty_id,
	max(location_id) location_id,
	max(proxy_index_position_uom) proxy_index_position_uom,
	max(curve_id) curve_id,
	max(Hours) Hours,
	sum(prior_volume) prior_volume,
	sum(volume) volume,
	sum(delta_prior_volume) delta_prior_volume,
	sum(delta_volume) delta_volume,
	max(is_dst) is_dst,
	max(sub_book_id) sub_book_id,
	max(proxy_curve_id3) proxy_curve_id3,
	max(commodity_id) commodity_id,
	max(period_from) period_from,
	max(period_to) period_to,
	max(period) period,
	hourly_block_id,
	max(block_name) block_name,
	max(user_defined_block) user_defined_block,
	max(user_defined_block_id) user_defined_block_id,
	sum(volume_change) volume_change,
	sum(delta_volume_change) delta_volume_change,
	(sum(delta_volume)/ CASE WHEN sum(volume) = 0 THEN 1 ELSE sum(volume) END) delta,
	(sum(delta_prior_volume)/CASE WHEN sum(volume) = 0 THEN 1 ELSE sum(volume) END)prior_delta,
	max(exclude_sub_book_for_fin_pos) exclude_sub_book_for_fin_pos,
	max(change_report) change_report,
	@_tenor_option [tenor_option]
--[__batch_report__]	
FROM #temp_hourly_position_detail
GROUP BY source_deal_header_id, deal_term_start, hourly_block_id' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'block_definition'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Definition'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'block_definition'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_definition' AS [name], 'Block Definition' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'block_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Block Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'block_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'block_name' AS [name], 'Block Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book' AS [name], 'Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = 1, widget_id = 5, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'Book ID' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'change_report'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Change Report'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'change_report'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'change_report' AS [name], 'Change Report' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity' AS [name], 'Commodity' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity ID'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_source_commodity_maintain ''a''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_id' AS [name], 'Commodity ID' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_commodity_maintain ''a''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = 'browse_counterparty', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'Counterparty ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_counterparty' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'country'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Country'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'country'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'country' AS [name], 'Country' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'curve_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Curve ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = 'browse_curve', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'curve_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_id' AS [name], 'Curve ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_curve' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'curve_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'curve_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_name' AS [name], 'Index' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'deal_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Date'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'deal_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_date' AS [name], 'Deal Date' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reference ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'deal_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_id' AS [name], 'Reference ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'deal_status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'deal_status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status' AS [name], 'Deal Status' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'deal_volume_frequency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Volume Frequency'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'deal_volume_frequency'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_volume_frequency' AS [name], 'Deal Volume Frequency' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'delta'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Delta'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'delta'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delta' AS [name], 'Delta' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'delta_prior_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Delta Prior Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'delta_prior_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delta_prior_volume' AS [name], 'Delta Prior Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'delta_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Delta Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'delta_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delta_volume' AS [name], 'Delta Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'delta_volume_change'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Delta Volume Change'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'delta_volume_change'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delta_volume_change' AS [name], 'Delta Volume Change' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'exclude_sub_book_for_fin_pos'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Exclude Sub Book for Fin Pos'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'exclude_sub_book_for_fin_pos'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'exclude_sub_book_for_fin_pos' AS [name], 'Exclude Sub Book for Fin Pos' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'grid'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Grid'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'grid'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'grid' AS [name], 'Grid' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'group1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Group1'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'group1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'group1' AS [name], 'Group1' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'group2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Group2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'group2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'group2' AS [name], 'Group2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'group3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Group3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'group3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'group3' AS [name], 'Group3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'group4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Group4'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'group4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'group4' AS [name], 'Group4' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'hourly_block_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hourly Block ID'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'hourly_block_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'hourly_block_id' AS [name], 'Hourly Block ID' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'Hours'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hours'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'Hours'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Hours' AS [name], 'Hours' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'is_dst'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Is Dst'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'is_dst'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'is_dst' AS [name], 'Is Dst' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'location'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location' AS [name], 'Location' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'location_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Group'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'location_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group' AS [name], 'Location Group' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'location_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = 'browse_location', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'location_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_id' AS [name], 'Location ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_location' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'parent_counterparty'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Parent Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'parent_counterparty'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'parent_counterparty' AS [name], 'Parent Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'period'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'period'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period' AS [name], 'Period' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'period_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period From'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'period_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_from' AS [name], 'Period From' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'period_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Period To'
			   , reqd_param = 1, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'period_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'period_to' AS [name], 'Period To' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'physical_financial_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Physical Financial'
			   , reqd_param = 0, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''Physical'',''Physical''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''Financial'',''Financial''', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'physical_financial_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial_flag' AS [name], 'Physical Financial' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''Physical'',''Physical''' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''Financial'',''Financial''' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'postion_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'postion_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'postion_uom' AS [name], 'Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'prior_delta'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Prior Delta'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'prior_delta'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'prior_delta' AS [name], 'Prior Delta' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'prior_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Prior Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'prior_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'prior_volume' AS [name], 'Prior Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'proxy_curve'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'proxy_curve'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve' AS [name], 'Proxy Curve' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'proxy_curve_id3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve ID3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'proxy_curve_id3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve_id3' AS [name], 'Proxy Curve ID3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'proxy_curve_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'proxy_curve_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve_position_uom' AS [name], 'Proxy Curve Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'proxy_curve2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve2'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'proxy_curve2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve2' AS [name], 'Proxy Curve2' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'proxy_curve3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Curve3'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'proxy_curve3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_curve3' AS [name], 'Proxy Curve3' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'proxy_index'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Index'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'proxy_index'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_index' AS [name], 'Proxy Index' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'proxy_index_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy Index Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'proxy_index_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy_index_position_uom' AS [name], 'Proxy Index Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'proxy2_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy2 Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'proxy2_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy2_position_uom' AS [name], 'Proxy2 Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'proxy3_position_uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Proxy3 Position UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'proxy3_position_uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'proxy3_position_uom' AS [name], 'Proxy3 Position UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'region'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'region'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region' AS [name], 'Region' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = 1, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, 1 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'stra'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'stra'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra' AS [name], 'Strategy' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = 1, widget_id = 4, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'Strategy ID' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'sub'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'sub'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub' AS [name], 'Subsidiary' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'sub_book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'sub_book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book' AS [name], 'Sub Book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = 1, widget_id = 8, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'Sub Book ID' AS ALIAS, 1 AS reqd_param, 8 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidairy ID'
			   , reqd_param = 1, widget_id = 3, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'Subsidairy ID' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'term_year'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'term_year'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_year' AS [name], 'Term Year' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'term_year_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Year Month'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'term_year_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_year_month' AS [name], 'Term Year Month' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'to_as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date To'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'to_as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'to_as_of_date' AS [name], 'As of Date To' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'UOM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'uom' AS [name], 'UOM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'user_defined_block'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'User Defined Block'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'user_defined_block'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'user_defined_block' AS [name], 'User Defined Block' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'user_defined_block_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'User Defined Block ID'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15001', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'user_defined_block_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'user_defined_block_id' AS [name], 'User Defined Block ID' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15001' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume' AS [name], 'Volume' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'volume_change'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume Change'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'volume_change'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume_change' AS [name], 'Volume Change' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Position Monthly View'
	            AND dsc.name =  'tenor_option'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Tenor Option'
			   , reqd_param = 1, widget_id = 2, datatype_id = 1, param_data_source = 'SELECT 1 , ''Forward''' + CHAR(10) + 'UNION ' + CHAR(10) + 'SElect 2, ''Show All''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Position Monthly View'
			AND dsc.name =  'tenor_option'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'tenor_option' AS [name], 'Tenor Option' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 1 AS datatype_id, 'SELECT 1 , ''Forward''' + CHAR(10) + 'UNION ' + CHAR(10) + 'SElect 2, ''Show All''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Position Monthly View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Position Monthly View'
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
	