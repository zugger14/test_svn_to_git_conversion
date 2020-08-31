  BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'jeev'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'jeev' and name <> 'Journal Entry Extract View')
	begin
		select top 1 @new_ds_alias = 'jeev' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'jeev' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Journal Entry Extract View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Journal Entry Extract View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Journal Entry Extract View' AS [name], @new_ds_alias AS ALIAS, 'JE Extract View' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'1' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'JE Extract View'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'SET NOCOUNT ON;
DECLARE @_sql VARCHAR(MAX)  
DECLARE @_sub_id VARCHAR(MAX) 
DECLARE @_stra_id VARCHAR(MAX) 
DECLARE @_book_id VARCHAR(MAX) 
DECLARE @_sub_book_id VARCHAR(MAX) 
DECLARE @_as_of_date VARCHAR(50)
DECLARE @_link_id VARCHAR(500) = NULL  
DECLARE @_as_of_date_from VARCHAR(50) = NULL
DECLARE @_hedge_type	  VARCHAR(50) = NULL
DECLARE @_tenor_option	  VARCHAR(50) = NULL
DECLARE @_discount_option VARCHAR(50) =  NULL 
DECLARE @_whe_re_stmt  VARCHAR(MAX) = NULL
DECLARE @_sql_from VARCHAR(MAX) = NULL

SET @_sub_id = NULLIF(ISNULL(@_sub_id, NULLIF(''@sub_id'', REPLACE(''@_sub_id'', ''@_'', ''@''))), ''NULL'') 
SET @_stra_id = NULLIF(ISNULL(@_stra_id, NULLIF(''@stra_id'', REPLACE(''@_stra_id'', ''@_'', ''@''))), ''NULL'') 
SET @_book_id = NULLIF(ISNULL(@_book_id, NULLIF(''@book_id'', REPLACE(''@_book_id'', ''@_'', ''@''))), ''NULL'') 
SET @_sub_book_id = NULLIF(ISNULL(@_sub_book_id, NULLIF(''@sub_book_id'', REPLACE(''@_sub_book_id'', ''@_'', ''@''))), ''NULL'') 
SET @_as_of_date = NULLIF(ISNULL(@_as_of_date, NULLIF(''@as_of_date'', REPLACE(''@_as_of_date'', ''@_'', ''@''))), ''NULL'') 
SET @_link_id = NULLIF(ISNULL(@_link_id, NULLIF(''@link_id'', REPLACE(''@_link_id'', ''@_'', ''@''))), ''NULL'') 
SET @_as_of_date_from = NULLIF(ISNULL(@_as_of_date_from, NULLIF(''@as_of_date_from'', REPLACE(''@_as_of_date_from'', ''@_'', ''@''))), ''NULL'')  
SET @_hedge_type = NULLIF(ISNULL(@_hedge_type, NULLIF(''@hedge_type'', REPLACE(''@_hedge_type'', ''@_'', ''@''))), ''NULL'') 
SET @_tenor_option = NULLIF(ISNULL(@_tenor_option, NULLIF(''@tenor_option'', REPLACE(''@_tenor_option'', ''@_'', ''@''))), ''NULL'') 
SET @_discount_option = NULLIF(ISNULL(@_discount_option, NULLIF(''@discount_option'', REPLACE(''@_discount_option'', ''@_'', ''@''))), ''NULL'') 

--Default GL code for undefined ones
DECLARE @_st_asset_gl_id VARCHAR(3)
DECLARE @_st_liability_gl_id VARCHAR(3)
DECLARE @_lt_asset_gl_id VARCHAR(3)
DECLARE @_lt_liability_gl_id VARCHAR(3)
DECLARE @_st_item_asset_gl_id VARCHAR(3)
DECLARE @_st_item_liability_gl_id VARCHAR(3)
DECLARE @_lt_item_asset_gl_id VARCHAR(3)
DECLARE @_lt_item_liability_gl_id VARCHAR(3)
DECLARE @_st_tax_asset_gl_id VARCHAR(3)
DECLARE @_st_tax_liability_gl_id VARCHAR(3)
DECLARE @_lt_tax_asset_gl_id VARCHAR(3)
DECLARE @_lt_tax_liability_gl_id VARCHAR(3)
DECLARE @_un_st_asset_gl_id VARCHAR(3) 
DECLARE @_un_st_liability_gl_id VARCHAR(3)
DECLARE @_un_lt_asset_gl_id VARCHAR(3)
DECLARE @_un_lt_liability_gl_id VARCHAR(3)
DECLARE @_tax_reserve VARCHAR(3)
DECLARE @_pnl_set VARCHAR(3)
DECLARE @_aoci VARCHAR(3)
DECLARE @_total_pnl VARCHAR(3)
DECLARE @_inventory VARCHAR(3)
DECLARE @_cash VARCHAR(3)
DECLARE @_cashS VARCHAR(3)
DECLARE @_interestA VARCHAR(3)
DECLARE @_interestE VARCHAR(3)
DECLARE @_amortization VARCHAR(3)

SET @_st_asset_gl_id = ''-1'' 
SET @_st_liability_gl_id = ''-2''
SET @_lt_asset_gl_id = ''-3''
SET @_lt_liability_gl_id = ''-4''
SET @_st_item_asset_gl_id = ''-5''
SET @_st_item_liability_gl_id = ''-6''
SET @_lt_item_asset_gl_id = ''-7''
SET @_lt_item_liability_gl_id = ''-8''
SET @_st_tax_asset_gl_id = ''-9''
SET @_st_tax_liability_gl_id = ''-10''
SET @_lt_tax_asset_gl_id = ''-11''
SET @_lt_tax_liability_gl_id = ''-12''
SET @_tax_reserve = ''-13''
SET @_pnl_set = ''-14''
SET @_aoci = ''-15''
SET @_total_pnl = ''-16''
SET @_inventory = ''-17''
SET @_cash = ''-18''
SET @_cashS = ''-19''
SET @_interestA = ''-20''
SET @_interestE = ''-21''
SET @_amortization = ''-22''
SET @_un_st_asset_gl_id = ''-23'' 
SET @_un_st_liability_gl_id = ''-24''
SET @_un_lt_asset_gl_id = ''-25''
SET @_un_lt_liability_gl_id = ''-26''
SET @_sql_from = '' FROM #temp RMV ''

DECLARE @_aoci_tax_asset_liab VARCHAR(1)
SELECT @_aoci_tax_asset_liab = var_value FROM adiha_default_codes_values
WHERE instance_no = 1 AND seq_no = 1 AND default_code_id = 39

IF @_aoci_tax_asset_liab IS NULL
	SET @_aoci_tax_asset_liab = ''0''
   
IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL 
	DROP TABLE #books  

CREATE TABLE #books ( sub_id INT 
					, stra_id INT ,book_id INT ,sub_name VARCHAR(100) ,stra_name VARCHAR(100) 
					, book_name VARCHAR(100) ,source_system_book_id1 INT ,source_system_book_id2 INT ,source_system_book_id3 INT ,source_system_book_id4 INT 
					, logical_name VARCHAR(100) ,fas_deal_type_value_id INT  ,sub_book_id INT ,transaction_type INT ,report_group_1 VARCHAR(100) 
					, report_group_2 VARCHAR(100) ,report_group_3 VARCHAR(100) ,report_group_4 VARCHAR(100) ,transaction_type_name VARCHAR(100) ,link_id INT 
					, percentage_linked VARCHAR(100) ,tag_1 VARCHAR(100) ,tag_2 VARCHAR(100) ,tag_3 VARCHAR(100) ,tag_4 VARCHAR(100)
					, gl_dedesig_aoci VARCHAR(100), gl_grouping_value_id	VARCHAR(100), fas_book_id INT, legal_entity VARCHAR(100)
					) 
SET @_sql = '' 
			INSERT INTO #books 
			SELECT sub.entity_id sub_id, 
				stra.entity_id stra_id, 
				book.entity_id book_id, 
				sub.entity_name AS sub_name, 
				stra.entity_name AS stra_name, 
				book.entity_name AS book_name, 
				MAX(ssbm.source_system_book_id1) source_system_book_id1,  
				MAX(ssbm.source_system_book_id2) source_system_book_id2,  
				MAX(ssbm.source_system_book_id3) source_system_book_id3,  
				MAX(ssbm.source_system_book_id4) source_system_book_id4, 
				MAX(ssbm.logical_name) fas_deal_type_value_id, 
				MAX(ssbm.fas_deal_type_value_id) fas_deal_type_value_id, 
				MAX(ssbm.book_deal_type_map_id) [sub_book_id], 
				MAX(ssbm.fas_deal_type_value_id) [transaction_type], 
				MAX(sdv_rg1.code) [report_group_1],  
				MAX(sdv_rg2.code) [report_group_2],  
				MAX(sdv_rg3.code) [report_group_3],  
				MAX(sdv_rg4.code) [report_group_4], 
				MAX(sdv.code) [transaction_type_name], 
				flh.link_id [link_id], 
				MAX(flh.dedesignated_percentage) [percentage_linked], 
				MAX(sb1.source_book_name) [tag_1], 
				MAX(sb2.source_book_name) [tag_2], 
				MAX(sb3.source_book_name) [tag_3], 
				MAX(sb4.source_book_name) [tag_4],				 
				MAX(COALESCE(fb.gl_number_id_expense, fb.gl_number_id_aoci, fs.gl_number_id_aoci)) gl_dedesig_aoci,
				MAX(fs.gl_grouping_value_id) gl_grouping_value_id,
				MAX(ssbm.fas_book_id) fas_book_id,
				MAX(fb.legal_entity) legal_entity
			FROM   portfolio_hierarchy book(NOLOCK) 
			INNER JOIN Portfolio_hierarchy stra(NOLOCK)  ON  book.parent_entity_id = stra.entity_id 
			INNER JOIN portfolio_hierarchy sub (NOLOCK) ON  stra.parent_entity_id = sub.entity_id 
			INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id 
			INNER JOIN source_book sb1 ON sb1.source_book_id = ssbm.source_system_book_id1 
			INNER JOIN source_book sb2 ON sb2.source_book_id = ssbm.source_system_book_id2 
			INNER JOIN source_book sb3 ON sb3.source_book_id = ssbm.source_system_book_id3 
			INNER JOIN source_book sb4 ON sb4.source_book_id = ssbm.source_system_book_id4 
			INNER JOIN fas_strategy fs ON  stra.entity_id = fs.fas_strategy_id 
			INNER JOIN fas_books fb on fb.fas_book_id = book.entity_id 
			LEFT JOIN static_data_value sdv  ON sdv.[type_id] = 400  
				AND ssbm.fas_deal_type_value_id = sdv.value_id	 
			LEFT JOIN fas_link_header flh  ON flh.fas_book_id = book.entity_id  
			LEFT JOIN static_data_value sdv_rg1 ON sdv_rg1.value_id = ssbm.sub_book_group1 
			LEFT JOIN static_data_value sdv_rg2 ON sdv_rg2.value_id = ssbm.sub_book_group2 
			LEFT JOIN static_data_value sdv_rg3 ON sdv_rg3.value_id = ssbm.sub_book_group3 
			LEFT JOIN static_data_value sdv_rg4 ON sdv_rg4.value_id = ssbm.sub_book_group4 
			WHERE 1 = 1 
			'' 
+ CASE WHEN @_sub_id IS NULL THEN '''' ELSE '' AND sub.entity_id IN ( '' + @_sub_id + '') '' END  
+ CASE WHEN @_stra_id IS NULL THEN '''' ELSE '' AND (stra.entity_id IN ('' + @_stra_id + '' ))'' END  
+ CASE WHEN @_book_id IS NULL THEN '''' ELSE '' AND (book.entity_id IN ('' + @_book_id + '')) '' END 
+ CASE WHEN @_sub_book_id IS NULL THEN '''' ELSE '' AND (ssbm.book_deal_type_map_id IN ('' + @_sub_book_id + '')) '' END  
+ CASE WHEN @_link_id IS NOT NULL  THEN  '' AND flh.link_id IN( '' + @_link_id + '')''  ELSE '''' END 
+ CASE WHEN @_hedge_type = ''c'' THEN '' AND fs.hedge_type_value_id = 150'' 
		WHEN @_hedge_type = ''f'' THEN '' AND fs.hedge_type_value_id = 151'' 
		WHEN @_hedge_type = ''m'' THEN '' AND fs.hedge_type_value_id = 152'' 
		WHEN @_hedge_type = ''a'' THEN '' AND fs.hedge_type_value_id BETWEEN 150 AND 152'' ELSE '''' END 
+ '' GROUP BY sub.entity_id, 
		stra.entity_id, 
		book.entity_id, 
		sub.entity_name, 
		stra.entity_name, 
		book.entity_name,
		flh.link_id
				''
EXEC spa_print @_sql
EXEC(@_sql)  
IF OBJECT_ID(N''tempdb..#links'') IS NOT NULL 
	DROP TABLE #links  
CREATE TABLE #links(link_id VARCHAR(500) COLLATE DATABASE_DEFAULT, source_deal_header_id INT)

SET @_sql=
	''INSERT INTO #links
	SELECT DISTINCT CAST(source_deal_header_id AS VARCHAR) + ''''d'''' , fld.source_deal_header_id
	FROM fas_link_detail fld 
	INNER JOIN fas_link_header flh ON fld.link_id = flh.link_id
	WHERE hedge_or_item = ''''h''''''
	+ CASE WHEN @_link_id IS NOT NULL THEN '' AND flh.link_id IN(SELECT link_id FROM #books) OR flh.original_link_id IN (SELECT link_id FROM #books)'' ELSE '''' END
	+ '' AND percentage_included <> 0 
	UNION 
	SELECT CAST(fld.link_id AS VARCHAR) + ''''l''''  , MAX(fld.source_deal_header_id) source_deal_header_id
	FROM fas_link_detail fld 
	INNER JOIN fas_link_header flh ON fld.link_id = flh.link_id
	WHERE hedge_or_item = ''''h''''''
	+ CASE WHEN @_link_id IS NOT NULL THEN '' AND flh.link_id IN(SELECT link_id FROM #books) OR flh.original_link_id IN (SELECT link_id FROM #books)'' ELSE '''' END
	+ '' AND percentage_included <> 0
	GROUP BY   CAST(fld.link_id AS VARCHAR) + ''''l''''''
  
EXEC spa_print @_sql 
EXEC(@_sql)

DECLARE @_link_filter CHAR(1) = ''y''
IF @_hedge_type = ''m''
BEGIN 
	SET @_link_filter = ''n''
END 

--negative links
SET @_sql = '' 
			INSERT INTO #links
			SELECT CAST(cd.link_id AS VARCHAR(100)) + SUBSTRING(link_type, 1, 1), MAX(cd.source_deal_header_id) source_deal_header_id
			FROM  calcprocess_deals cd 
			INNER JOIN fas_strategy fs ON fs.fas_strategy_id = cd.fas_strategy_id 
			INNER JOIN fas_books fb ON fb.fas_book_id = cd.fas_book_id 
			WHERE cd.calc_type = ''''m'''' 
				AND (fb.no_link IS NULL OR fb.no_link = ''''n'''')  
				AND cd.link_id < 0 
				AND cd.link_type = ''''link''''
				AND cd.as_of_date = '''''' + @_as_of_date + '''''''' 
									 
+ CASE WHEN @_sub_id IS NULL THEN '''' ELSE '' AND cd.fas_subsidiary_id  IN ( '' + @_sub_id + '') '' END  
+ CASE WHEN @_stra_id IS NULL THEN '''' ELSE '' AND (cd.fas_strategy_id  IN ('' + @_stra_id + '' ))'' END  
+ CASE WHEN @_book_id IS NULL THEN '''' ELSE '' AND (cd.fas_book_id  IN ('' + @_book_id + '')) '' END 
+ CASE WHEN @_hedge_type = ''c'' THEN '' AND fs.hedge_type_value_id = 150'' 
		WHEN @_hedge_type = ''f'' THEN '' AND fs.hedge_type_value_id = 151'' 
		WHEN @_hedge_type = ''m'' THEN '' AND fs.hedge_type_value_id = 152'' 
		WHEN @_hedge_type = ''a'' THEN '' AND fs.hedge_type_value_id BETWEEN 150 AND 152'' ELSE '''' END 

SET @_sql = @_sql + '' GROUP BY CAST(cd.link_id AS VARCHAR(100)) + SUBSTRING(link_type, 1, 1)''

EXEC spa_print @_sql
EXEC (@_sql) 

IF OBJECT_ID(''tempdb..#calcprocess_deals'') IS NOT NULL
	DROP TABLE #calcprocess_deals  

SELECT *, CAST(NULL AS INT) gl_dedesig_aoci INTO #calcprocess_deals FROM [calcprocess_deals] a WHERE 1 = 2


SET @_sql = ''INSERT INTO #calcprocess_deals
			SELECT cd.*, gl_dedesig_aoci 
			FROM '' + dbo.FNAGetProcessTableName(@_as_of_date,''calcprocess_deals'') + '' cd 
			INNER JOIN (SELECT DISTINCT fas_book_id, gl_dedesig_aoci
					    FROM #books 
					    ) books ON books.fas_book_id = cd.fas_book_id 
			WHERE 1 = 1 AND cd.as_of_date = '''''' + @_as_of_date + '''''''' 
			+ CASE WHEN @_hedge_type <> ''f'' THEN '' AND hedge_or_item = ''''h'''''' ELSE '''' END 
			+ CASE WHEN @_link_filter = ''y'' 
					THEN '' AND ((CAST(cd.link_id AS VARCHAR) + SUBSTRING(cd.link_type, 1, 1)) IN (SELECT DISTINCT link_id FROM #links)) '' ELSE '''' END 

EXEC spa_print @_sql
EXEC (@_sql)

IF OBJECT_ID(''tempdb..#temp'') IS NOT NULL
	DROP TABLE #temp  
 
 CREATE TABLE #temp (
  as_of_date					DATETIME
, gl_code_hedge_st_asset		INT
, gl_code_hedge_st_liability	INT
, gl_code_hedge_lt_asset		INT
, gl_code_hedge_lt_liability	INT
, gl_code_item_st_asset			INT
, gl_code_item_st_liability		INT
, gl_code_item_lt_asset			INT
, gl_code_item_lt_liability		INT
, gl_aoci						INT
, gl_pnl						INT
, gl_settlement					INT
, gl_cash						INT
, gl_inventory					INT
, gl_id_st_tax_asset			INT
, gl_id_st_tax_liab				INT
, gl_id_lt_tax_asset			INT
, gl_id_lt_tax_liab				INT
, gl_id_tax_reserve				INT
, link_id						INT
, term_month					DATETIME
, gl_tenor_option				INT
, legal_entity					INT
, gl_dedesig_aoci				INT
, source_book_map_id			INT
, source_deal_header_id			INT
)
 
SET @_sql = '' INSERT INTO #temp
			SELECT as_of_date
				, rmv.gl_code_hedge_st_asset
				, rmv.gl_code_hedge_st_liability
				, rmv.gl_code_hedge_lt_asset
				, rmv.gl_code_hedge_lt_liability
				, rmv.gl_code_item_st_asset
				, rmv.gl_code_item_st_liability
				, rmv.gl_code_item_lt_asset
				, rmv.gl_code_item_lt_liability
				, rmv.gl_aoci
				, rmv.gl_pnl
				, rmv.gl_settlement
				, rmv.gl_cash
				, rmv.gl_inventory
				, rmv.gl_id_st_tax_asset
				, rmv.gl_id_st_tax_liab
				, rmv.gl_id_lt_tax_asset
				, rmv.gl_id_lt_tax_liab
				, rmv.gl_id_tax_reserve
				, rmv.link_id
				, rmv.term_month
				, books.gl_tenor_option, books.legal_entity, books.gl_dedesig_aoci,NULL source_book_map_id, rmv.link_id source_deal_header_id				
			FROM '' + dbo.FNAGetProcessTableName(@_as_of_date, ''report_measurement_values'') + '' rmv   
			INNER JOIN (SELECT DISTINCT fas_book_id gl_tenor_option , gl_dedesig_aoci, legal_entity, fas_book_id
					FROM #books 
					WHERE gl_grouping_value_id IN ('' + CASE WHEN @_hedge_type = ''m'' THEN ''352'' ELSE ''350, 351'' END + '') --strategy--book
				) books ON books.fas_book_id = rmv.book_entity_id ''
				+ CASE WHEN @_link_filter = ''y'' 
					THEN  ''INNER JOIN (SELECT link_id, source_deal_header_id FROM #links) ll ON ll.link_id = (CAST(rmv.link_id AS VARCHAR) + rmv.link_deal_flag)''
					ELSE '''' END + ''
			WHERE 1 = 1 AND rmv.as_of_date = '''''' + @_as_of_date + ''''''''
			 + CASE WHEN @_tenor_option = ''f'' THEN  '' AND  rmv.term_month > '''''' +  CAST(@_as_of_date AS VARCHAR) + ''''''''
					WHEN @_tenor_option = ''c'' THEN '' AND  rmv.term_month >= '''''' +  dbo.FNAGetContractMonth(@_as_of_date)  + ''''''''
					WHEN @_tenor_option = ''s'' THEN '' AND  rmv.term_month <= '''''' +  dbo.FNAGetContractMonth(@_as_of_date) + '''''''' ELSE '''' END

EXEC spa_print @_sql
EXEC (@_sql)

IF OBJECT_ID(''tempdb..#calcprocess_aoci_release'') IS NOT NULL
	DROP TABLE #calcprocess_aoci_release  
	
SELECT * INTO #calcprocess_aoci_release FROM [calcprocess_aoci_release] WHERE 1 = 2

SET @_sql = ''INSERT INTO #calcprocess_aoci_release
			SELECT car.* FROM [calcprocess_aoci_release] car 
			INNER JOIN (SELECT distinct link_id 
					    FROM #calcprocess_deals 
					    WHERE link_type = ''''link'''') l ON l.link_id = car.link_id
					    AND car.as_of_date = '''''' + @_as_of_date + ''''''''
EXEC spa_print @_sql
EXEC (@_sql)
 
IF OBJECT_ID(''tempdb..#fas_book_id_flh'') IS NOT NULL 
	DROP TABLE #fas_book_id_flh
 
CREATE TABLE #fas_book_id_flh(link_id INT, fas_book_id INT, source_deal_header_id INT)
IF @_hedge_type = ''m''
BEGIN 
	INSERT INTO #fas_book_id_flh
	SELECT cd.source_deal_header_id, b.fas_book_id, cd.source_deal_header_id
	FROM #calcprocess_deals  cd
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = cd.source_deal_header_id
	INNER JOIN #books b ON b.sub_book_id = sdh.sub_book
	GROUP BY cd.source_deal_header_id, b.fas_book_id
END 
ELSE
BEGIN 
	INSERT INTO #fas_book_id_flh
	SELECT flh.link_id , MAX(flh.fas_book_id) fas_book_id, fld.source_deal_header_id 
	FROM #calcprocess_deals  cdd		 
	INNER JOIN fas_link_detail  fld ON CASE WHEN cdd.link_type = ''link'' THEN fld.link_id ELSE fld.source_deal_header_id END = cdd.link_id
	INNER JOIN fas_link_header flh ON flh.link_id = fld.link_id 
	GROUP BY  flh.link_id, fld.source_deal_header_id  
	UNION 
	SELECT cd.link_id, MAX(fas_book_id), cd.source_deal_header_id
	FROM #calcprocess_deals cd
	WHERE link_id < 0
	GROUP BY cd.link_id, cd.source_deal_header_id
END
 
IF OBJECT_ID(''tempdb..#cd'') IS NOT NULL
	DROP TABLE #cd  

IF OBJECT_ID(''tempdb..#deals'') IS NOT NULL
	DROP TABLE #deals  

SELECT cdd.link_id, cdd.source_deal_header_id, link_type, as_of_date, term_start, MAX(hedge_or_item) hedge_or_item,
		MAX(cdd.link_type_value_id) link_type_value_id,
		MAX(u_aoci) u_aoci, 
		MAX(d_aoci) d_aoci, 
		MAX(test_settled) settled_test,
		MAX(final_und_pnl_remaining) final_und_pnl_remaining, 
		MAX(final_dis_pnl_remaining) final_dis_pnl_remaining, 
		MAX(u_pnl_ineffectiveness) u_pnl_ineffectiveness, 
		MAX(d_pnl_ineffectiveness) d_pnl_ineffectiveness, 
		MAX(u_pnl_mtm) u_pnl_mtm, 
		MAX(d_pnl_mtm) d_pnl_mtm, 
		MAX(u_extrinsic_pnl) u_extrinsic_pnl, 
		MAX(d_extrinsic_pnl) d_extrinsic_pnl,
		CASE WHEN (term_start <= DATEADD(mm, MAX(long_term_months) - 1, @_as_of_date )) THEN 1 ELSE 0 END short_term_test,
		MAX(final_und_pnl_remaining) und_pnl, 
		MAX(final_dis_pnl_remaining) dis_pnl,
		MIN(hedge_type_value_id) hedge_type_value_id,
		MAX(gl_dedesig_aoci) gl_dedesig_aoci,
		MAX(deal_id) deal_id,
		MAX(flh.fas_book_id) fas_book_id
		INTO #deals
FROM #calcprocess_deals cdd 
INNER JOIN  #fas_book_id_flh flh ON flh.source_deal_header_id = cdd.source_deal_header_id
WHERE 1 = 1
	AND leg = 1 
	AND as_of_date = @_as_of_date 
	AND (@_tenor_option IS NULL OR @_tenor_option = ''a'' 
		OR (@_tenor_option = ''c'' AND term_end >= @_as_of_date) 
		OR (@_tenor_option = ''s'' AND term_start < @_as_of_date) 
		OR (@_tenor_option = ''f'' AND term_end > @_as_of_date))  
GROUP BY  cdd.link_id, cdd.source_deal_header_id, link_type, as_of_date, term_start

--/*
SELECT	deal.as_of_date, phs.parent_entity_id sub_entity_id, phs.entity_id strategy_entity_id, deal.fas_book_id book_entity_id,
		CASE WHEN (deal.link_type = ''link'') THEN ''l'' ELSE ''d'' END link_deal_flag,
		deal.deal_id link_id_or_deal_id,
		deal.source_deal_header_id, fb.legal_entity, 
		deal.term_start term_month, 
		CASE WHEN (ISNULL(total_val.u_mtm, 0) >= 0) THEN 1 ELSE 0 END hedge_asset_test,
		CASE WHEN (ISNULL(total_val.d_mtm, 0) >= 0) THEN 1 ELSE 0 END d_hedge_asset_test,
		CASE WHEN (item_settled > 0) THEN 0 ELSE u_aoci - ISNULL(ar.aoci_released, 0) END u_total_aoci,
		CASE WHEN (item_settled > 0) THEN 0 ELSE d_aoci - ISNULL(ar.d_aoci_released, 0) END d_total_aoci,
		deal.link_type_value_id,
		deal.settled_test,
		deal.short_term_test,
		hedge_or_item,
		ISNULL(sgl.gl_number_id_aoci,gl_dedesig_aoci) gl_dedesig_aoci,
		CASE WHEN (settled_test > 0) THEN 0 ELSE
			u_pnl_ineffectiveness+u_pnl_mtm+u_extrinsic_pnl END u_total_pnl,
		CASE WHEN (settled_test > 0) THEN 0 ELSE
			d_pnl_ineffectiveness+d_pnl_mtm+d_extrinsic_pnl  END d_total_pnl,
		ISNULL(ar.aoci_released, 0) u_aoci_released,
		ISNULL(ar.d_aoci_released, 0) d_aoci_released,
		CASE WHEN (deal.link_type=''deal'') THEN 
			COALESCE(sgl.gl_number_unhedged_der_st_asset, fb.gl_number_unhedged_der_st_asset, sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset) 
		ELSE  ISNULL(sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset) END gl_code_hedge_st_asset,
		CASE WHEN (deal.link_type=''deal'') THEN 
			COALESCE(sgl.gl_number_unhedged_der_st_liab, fb.gl_number_unhedged_der_st_liab, sgl.gl_number_id_st_liab, fb.gl_number_id_st_liab) 
		ELSE ISNULL(sgl.gl_number_id_st_liab, fb.gl_number_id_st_liab) END gl_code_hedge_st_liability,
		CASE WHEN (deal.link_type=''deal'') THEN 
			COALESCE(sgl.gl_number_unhedged_der_lt_asset, fb.gl_number_unhedged_der_lt_asset,sgl.gl_number_id_lt_asset, fb.gl_number_id_lt_asset)
		ELSE ISNULL(sgl.gl_number_id_lt_asset, fb.gl_number_id_lt_asset) END gl_code_hedge_lt_asset,
		CASE WHEN (deal.link_type=''deal'') THEN 	
			COALESCE(sgl.gl_number_unhedged_der_lt_liab, fb.gl_number_unhedged_der_lt_liab,sgl.gl_number_id_lt_liab, fb.gl_number_id_lt_liab) 
		ELSE ISNULL(sgl.gl_number_id_lt_liab, fb.gl_number_id_lt_liab) END gl_code_hedge_lt_liability,		
		ISNULL(sgl.gl_number_id_item_st_asset, fb.gl_number_id_item_st_asset) gl_code_item_st_asset,
		ISNULL(sgl.gl_number_id_item_st_liab, fb.gl_number_id_item_st_liab) gl_code_item_st_liability,
		ISNULL(sgl.gl_number_id_item_lt_asset, fb.gl_number_id_item_lt_asset) gl_code_item_lt_asset,
		ISNULL(sgl.gl_number_id_item_lt_liab, fb.gl_number_id_item_lt_liab) gl_code_item_lt_liability,
		ISNULL(sgl.gl_number_id_aoci, fb.gl_number_id_aoci) gl_aoci,
		ISNULL(sgl.gl_number_id_pnl, fb.gl_number_id_pnl) gl_pnl,
		ISNULL(sgl.gl_number_id_set, fb.gl_number_id_set) gl_settlement,
		ISNULL(sgl.gl_number_id_cash, fb.gl_number_id_cash) gl_cash,
		ISNULL(sgl.gl_number_id_inventory, fb.gl_number_id_inventory) gl_inventory,
		ISNULL(sgl.gl_number_id_expense, fb.gl_number_id_expense) gl_number_id_expense,
		ISNULL(sgl.gl_number_id_gross_set, fb.gl_number_id_gross_set) gl_number_id_gross_set,
		ISNULL(sgl.gl_id_amortization, fb.gl_id_amortization) gl_id_amortization,
		ISNULL(sgl.gl_id_interest, fb.gl_id_interest) gl_id_interest,
		sgl.gl_first_day_pnl gl_first_day_pnl,
		ISNULL(sgl.gl_id_st_tax_asset, fb.gl_id_st_tax_asset) gl_id_st_tax_asset,
		ISNULL(sgl.gl_id_st_tax_liab, fb.gl_id_st_tax_liab) gl_id_st_tax_liab,
		ISNULL(sgl.gl_id_lt_tax_asset, fb.gl_id_lt_tax_asset) gl_id_lt_tax_asset,
		ISNULL(sgl.gl_id_lt_tax_liab, fb.gl_id_lt_tax_liab) gl_id_lt_tax_liab,
		ISNULL(sgl.gl_id_tax_reserve, fb.gl_id_tax_reserve) gl_id_tax_reserve,
		und_pnl, dis_pnl, 
		
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = ''h'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) THEN ISNULL(und_pnl,0) ELSE 0 END
		END AS u_item_st_asset,		
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = ''h'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) THEN ISNULL(und_pnl,0) ELSE 0 END
		END AS u_item_lt_asset,
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = ''h'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) THEN ISNULL(und_pnl,0) ELSE 0 END
		END * -1 AS u_item_st_liability,		
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = ''h'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) THEN ISNULL(und_pnl,0) ELSE 0 END
		END * -1 AS u_item_lt_liability,
  
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = ''h'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) THEN ISNULL(dis_pnl,0) ELSE 0 END
		END AS d_item_st_asset,		
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = ''h'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) THEN ISNULL(dis_pnl,0) ELSE 0 END
		END AS d_item_lt_asset,
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = ''h'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) THEN ISNULL(dis_pnl,0) ELSE 0 END
		END * -1 AS d_item_st_liability,		
		CASE WHEN (settled_test > 0 OR deal.hedge_type_value_id <> 151 OR hedge_or_item = ''h'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) THEN ISNULL(dis_pnl,0) ELSE 0 END
		END * -1 AS d_item_lt_liability,
		ISNULL(fb.tax_perc, 0) tax_perc,
		(u_aoci - ISNULL(ar.aoci_released, 0)) * ISNULL(fb.tax_perc, 0) u_tax_reserve,
		(d_aoci - ISNULL(ar.d_aoci_released, 0)) * ISNULL(fb.tax_perc, 0) d_tax_reserve,
		CASE WHEN (item_settled > 0 OR hedge_or_item = ''i'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_u_aoci ELSE aoci_l.total_u_aoci END, 0) < 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) THEN -1 * (u_aoci - ISNULL(ar.aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END AS u_st_tax_asset,		
		CASE WHEN (item_settled > 0 OR hedge_or_item = ''i'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_u_aoci ELSE aoci_l.total_u_aoci END, 0) < 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) THEN -1 * (u_aoci - ISNULL(ar.aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END AS u_lt_tax_asset,
		CASE WHEN (item_settled > 0 OR hedge_or_item = ''i'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_u_aoci ELSE aoci_l.total_u_aoci END, 0) < 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) THEN (u_aoci - ISNULL(ar.aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END  AS u_st_tax_liability,		
		CASE WHEN (item_settled > 0 OR hedge_or_item = ''i'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_u_aoci ELSE aoci_l.total_u_aoci END, 0) < 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) THEN (u_aoci - ISNULL(ar.aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END  AS u_lt_tax_liability,
		CASE WHEN (item_settled > 0 OR hedge_or_item = ''i'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_d_aoci ELSE aoci_l.total_d_aoci END, 0) < 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) THEN -1 * (d_aoci - ISNULL(ar.d_aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END AS d_st_tax_asset,		
		CASE WHEN (item_settled > 0 OR hedge_or_item = ''i'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_d_aoci ELSE aoci_l.total_d_aoci END, 0) < 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) THEN -1 * (d_aoci - ISNULL(ar.d_aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END AS d_lt_tax_asset,
		CASE WHEN (item_settled > 0 OR hedge_or_item = ''i'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_d_aoci ELSE aoci_l.total_d_aoci END, 0) < 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) THEN (d_aoci - ISNULL(ar.d_aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END  AS d_st_tax_liability,		
		CASE WHEN (item_settled > 0 OR hedge_or_item = ''i'') THEN 0 ELSE			
				CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test=1) THEN aoci.total_d_aoci ELSE aoci_l.total_d_aoci END, 0) < 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) THEN (d_aoci - ISNULL(ar.d_aoci_released, 0)) * ISNULL(fb.tax_perc, 0) ELSE 0 END
		END  AS d_lt_tax_liability,
		CASE WHEN (settled_test > 0) THEN u_pnl_ineffectiveness+u_pnl_mtm+u_extrinsic_pnl+ISNULL(ar.aoci_released, 0) ELSE 0 END u_pnl_settlement,
		CASE WHEN (settled_test > 0) THEN final_und_pnl_remaining ELSE 0 END u_cash,
		CASE WHEN (settled_test > 0) THEN d_pnl_ineffectiveness+d_pnl_mtm+u_extrinsic_pnl+ISNULL(ar.d_aoci_released, 0) ELSE 0 END d_pnl_settlement,
		CASE WHEN (settled_test > 0) THEN final_dis_pnl_remaining  ELSE 0 END d_cash,                   
		ssbm.book_deal_type_map_id source_book_map_id   
		, CASE WHEN (deal.link_type = ''link'') THEN 
				COALESCE(sgl.gl_number_unhedged_der_st_asset, fb.gl_number_unhedged_der_st_asset, sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset) 
			ELSE  CASE WHEN (deal.link_type = ''deal'') THEN 
				COALESCE(sgl.gl_number_unhedged_der_st_asset, fb.gl_number_unhedged_der_st_asset, sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset) 
				ELSE  ISNULL(sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset)END END gl_code_un_hedge_st_asset,
		CASE WHEN (deal.link_type = ''link'') THEN 
			COALESCE(sgl.gl_number_unhedged_der_st_liab, fb.gl_number_unhedged_der_st_liab, sgl.gl_number_id_st_liab, fb.gl_number_id_st_liab) 
		ELSE CASE WHEN (deal.link_type=''deal'') THEN 
			COALESCE(sgl.gl_number_unhedged_der_st_liab, fb.gl_number_unhedged_der_st_liab, sgl.gl_number_id_st_liab, fb.gl_number_id_st_liab) 
		ELSE ISNULL(sgl.gl_number_id_st_liab, fb.gl_number_id_st_liab) END END gl_code_un_hedge_st_liability,
			--long term undefined
		CASE WHEN (deal.link_type=''link'') THEN 
			COALESCE(sgl.gl_number_unhedged_der_lt_asset, fb.gl_number_unhedged_der_lt_asset,sgl.gl_number_id_lt_asset, fb.gl_number_id_lt_asset)
		ELSE CASE WHEN (deal.link_type=''deal'') THEN 
			COALESCE(sgl.gl_number_unhedged_der_lt_asset, fb.gl_number_unhedged_der_lt_asset,sgl.gl_number_id_lt_asset, fb.gl_number_id_lt_asset) 
		ELSE  ISNULL(sgl.gl_number_id_st_asset, fb.gl_number_id_st_asset)END END gl_code_un_hedge_lt_asset,
		
		CASE WHEN (deal.link_type=''link'') THEN
			COALESCE(sgl.gl_number_unhedged_der_lt_liab, fb.gl_number_unhedged_der_lt_liab,sgl.gl_number_id_lt_liab, fb.gl_number_id_lt_liab) 
		ELSE CASE WHEN (deal.link_type=''deal'') THEN 
			COALESCE(sgl.gl_number_unhedged_der_lt_liab, fb.gl_number_unhedged_der_lt_liab,sgl.gl_number_id_lt_liab, fb.gl_number_id_lt_liab) 
		ELSE  ISNULL(sgl.gl_number_id_lt_liab, fb.gl_number_id_lt_liab) END END gl_code_un_hedge_lt_liability
		--get codes for undefined end 
		
		--take undiscounted aoci for link
			--asset
		 , CASE WHEN (settled_test > 0 OR hedge_or_item = ''i'') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) 
				THEN CASE WHEN (deal.link_type=''deal'') THEN ISNULL(u_aoci, 0) ELSE ISNULL(und_pnl,0) END ELSE 0 END  
		  END AS u_hedge_st_asset,    
		  CASE WHEN (settled_test > 0 OR hedge_or_item = ''i'') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) 
				THEN CASE WHEN (deal.link_type=''deal'') THEN ISNULL(u_aoci, 0) ELSE ISNULL(und_pnl,0) END ELSE 0 END  
		  END AS u_hedge_lt_asset,  
		  
			--lia
		  CASE WHEN (settled_test > 0 OR hedge_or_item = ''i'') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) 
				THEN CASE WHEN (deal.link_type=''deal'') THEN ISNULL(u_aoci, 0) ELSE ISNULL(und_pnl,0) END ELSE 0 END  
		  END * -1 AS u_hedge_st_liability,    
		  CASE WHEN (settled_test > 0 OR hedge_or_item = ''i'') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.u_mtm ELSE total_val_l.u_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) 
				THEN CASE WHEN (deal.link_type=''deal'') THEN ISNULL(u_aoci, 0) ELSE ISNULL(und_pnl,0) END ELSE 0 END  
		  END * -1 AS u_hedge_lt_liability
		
		--take discounted aoci  for link
			--asset
		, CASE WHEN (settled_test > 0 OR hedge_or_item = ''i'') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test > 0) 
				THEN CASE WHEN (deal.link_type=''deal'') THEN ISNULL(d_aoci, 0) ELSE ISNULL(dis_pnl,0) END ELSE 0 END  
		  END AS d_hedge_st_asset,    
		  CASE WHEN (settled_test > 0 OR hedge_or_item = ''i'') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END > 0 AND short_term_test = 0) 
				THEN CASE WHEN (deal.link_type=''deal'') THEN ISNULL(d_aoci, 0) ELSE ISNULL(dis_pnl,0) END ELSE 0 END  
		  END AS d_hedge_lt_asset,  
		  
			 --lia
		  CASE WHEN (settled_test > 0 OR hedge_or_item = ''i'') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test > 0) 
				THEN CASE WHEN (deal.link_type=''deal'') THEN ISNULL(d_aoci, 0) ELSE ISNULL(dis_pnl,0) END ELSE 0 END  
		  END * -1 AS d_hedge_st_liability,    
		  CASE WHEN (settled_test > 0 OR hedge_or_item = ''i'') THEN 0 ELSE     
			CASE WHEN(CASE WHEN (ISNULL(CASE WHEN (short_term_test = 1) THEN total_val.d_mtm ELSE total_val_l.d_mtm END, 0) >= 0) THEN 1 ELSE 0 END = 0 AND short_term_test = 0) 
				THEN CASE WHEN (deal.link_type=''deal'') THEN ISNULL(d_aoci, 0) ELSE ISNULL(dis_pnl,0) END ELSE 0 END  
		  END * -1 AS d_hedge_lt_liability,
		  

		  --take undiscounted aoci  for deal
			--asset
		  CASE WHEN (settled_test > 0 OR deal.link_type = ''link'') THEN 0 ELSE     
			CASE WHEN @_hedge_type = ''m'' 
			THEN 
				CASE WHEN(short_term_test = 1 AND (ISNULL(und_pnl, 0) - ISNULL(u_aoci, 0) >= 0)) 
					THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END 
			ELSE 
				CASE WHEN(short_term_test = 1 AND (ISNULL(ABS(und_pnl), 0) - ISNULL(ABS(u_aoci), 0) >= 0)) 
				THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END 
			END 
		  END AS u_un_hedge_st_asset,  
		  
		  CASE WHEN (settled_test > 0 OR deal.link_type = ''link'') THEN 0 ELSE     
			CASE WHEN @_hedge_type = ''m'' 
			THEN 
				CASE WHEN(short_term_test = 0 AND (ISNULL(und_pnl, 0) - ISNULL(u_aoci, 0) >= 0)) 
					THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END 
			ELSE 
				CASE WHEN(short_term_test = 1 AND (ISNULL(ABS(und_pnl), 0) - ISNULL(ABS(u_aoci), 0) >= 0)) 
				THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END 
			END 
		  END AS u_un_hedge_lt_asset, 
		  
			--lia
		  CASE WHEN (settled_test > 0 OR deal.link_type = ''link'') THEN 0 ELSE   
		  CASE WHEN @_hedge_type = ''m'' 
		  THEN 
			CASE WHEN(short_term_test = 1 AND (ISNULL(und_pnl, 0)- ISNULL(u_aoci, 0) < 0)) 
				THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END  
			ELSE 
				CASE WHEN(short_term_test = 1 AND (ISNULL(ABS(und_pnl), 0)- ISNULL(ABS(u_aoci), 0) < 0)) 
				THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END  
			END
		  END * -1 AS u_un_hedge_st_liability,  
	
		CASE WHEN (settled_test > 0 OR deal.link_type = ''link'') THEN 0 ELSE     
			CASE WHEN @_hedge_type = ''m'' 
			 THEN 
				CASE WHEN(short_term_test = 0 AND (ISNULL(und_pnl, 0)- ISNULL(u_aoci, 0) < 0)) 
				THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END  
			ELSE 
				CASE WHEN(short_term_test = 1 AND (ISNULL(ABS(und_pnl), 0)- ISNULL(ABS(u_aoci), 0) < 0)) 
				THEN ISNULL(und_pnl,0) - ISNULL(u_aoci, 0)  ELSE 0 END  
			END
		  END * -1 AS u_un_hedge_lt_liability, 
		  
		  --take discounted aoci  for deal
			--asset
		  CASE WHEN (settled_test > 0 OR deal.link_type = ''link'') THEN 0 ELSE     
			CASE WHEN @_hedge_type = ''m'' 
			THEN 
				CASE WHEN(short_term_test = 1 AND (ISNULL(dis_pnl, 0)- ISNULL(d_aoci, 0) >= 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0)  ELSE 0 END  
			ELSE 
				CASE WHEN(short_term_test = 1 AND (ISNULL(ABS(dis_pnl), 0)- ISNULL(ABS(d_aoci), 0) >= 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0)  ELSE 0 END  
			END
		  END AS d_un_hedge_st_asset,  
		  
		  CASE WHEN (settled_test > 0 OR deal.link_type = ''link'') THEN 0 ELSE     
			CASE WHEN @_hedge_type = ''m'' 
			THEN
				CASE WHEN(short_term_test = 0 AND (ISNULL(dis_pnl, 0)- ISNULL(d_aoci, 0) >= 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0) ELSE 0 END  
			ELSE 
				CASE WHEN(short_term_test = 0 AND (ISNULL(ABS(dis_pnl), 0)- ISNULL(ABS(d_aoci), 0) >= 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0) ELSE 0 END
			END
		  END AS d_un_hedge_lt_asset, 
		
			--lia
		  CASE WHEN (settled_test > 0 OR deal.link_type = ''link'') THEN 0 ELSE     
			CASE WHEN @_hedge_type = ''m'' 
			THEN 
				CASE WHEN(short_term_test = 1 AND (ISNULL(dis_pnl, 0) - ISNULL(d_aoci, 0) < 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0) ELSE 0 END  
			ELSE 
				CASE WHEN(short_term_test = 1 AND (ISNULL(ABS(dis_pnl), 0) - ISNULL(ABS(d_aoci), 0) < 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0) ELSE 0 END  
			END
		  END * -1 AS d_un_hedge_st_liability,  
		  
		  CASE WHEN (settled_test > 0 OR deal.link_type = ''link'') THEN 0 ELSE     
			CASE WHEN @_hedge_type = ''m'' 
			THEN
				CASE WHEN(short_term_test = 0 AND (ISNULL(dis_pnl, 0)- ISNULL(d_aoci, 0) < 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0) ELSE 0 END  
			ELSE 
				CASE WHEN(short_term_test = 0 AND (ISNULL(ABS(dis_pnl), 0)- ISNULL(ABS(d_aoci), 0) < 0)) 
				THEN ISNULL(dis_pnl,0) - ISNULL(d_aoci, 0) ELSE 0 END  
			END

		  END * -1 AS d_un_hedge_lt_liability
		  , deal.link_id link_id 
		/*Added section end*/
		, dis_pnl a, d_aoci b, und_pnl c, u_aoci d
		INTO #cd
FROM #deals deal   
LEFT OUTER JOIN (
				 SELECT source_deal_header_id, as_of_date, SUM(u_mtm) u_mtm, SUM(d_mtm) d_mtm 
					FROM (  
		SELECT source_deal_header_id, as_of_date, term_start, MAX(und_pnl) u_mtm, MAX(dis_pnl) d_mtm
		FROM #calcprocess_deals
						  WHERE (hedge_or_item = ''h'' OR (hedge_or_item = ''i'' AND hedge_type_value_id=151)) 
								AND term_start > @_as_of_date 
								AND term_start <= DATEADD(mm, long_term_months - 1, @_as_of_date ) 
								AND as_of_date = @_as_of_date  
		GROUP BY source_deal_header_id, as_of_date, term_start ) xx
	GROUP BY source_deal_header_id, as_of_date
				 ) total_val ON total_val.source_deal_header_id = deal.source_deal_header_id 
				 AND total_val.as_of_date = deal.as_of_date  
LEFT OUTER JOIN(
				SELECT source_deal_header_id, as_of_date, SUM(u_mtm) u_mtm, SUM(d_mtm) d_mtm 
				FROM (  
		SELECT source_deal_header_id, as_of_date, term_start, MAX(und_pnl) u_mtm, MAX(dis_pnl) d_mtm
		FROM #calcprocess_deals
					WHERE (hedge_or_item = ''h'' OR (hedge_or_item = ''i'' AND hedge_type_value_id=151))
						AND term_start > @_as_of_date 
						AND term_start > DATEADD(mm, long_term_months - 1, @_as_of_date) 
						AND as_of_date = @_as_of_date  
		GROUP BY source_deal_header_id, as_of_date, term_start ) xx
	GROUP BY source_deal_header_id, as_of_date
				) total_val_l ON total_val_l.source_deal_header_id = deal.source_deal_header_id 
				AND total_val_l.as_of_date = deal.as_of_date   
LEFT OUTER JOIN(
	SELECT	as_of_date, source_deal_header_id,  
		SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(aoci_allocation_pnl, 0) ELSE ISNULL(aoci_allocation_vol, 0) END) total_u_aoci,
		SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(d_aoci_allocation_pnl, 0) ELSE ISNULL(d_aoci_allocation_vol, 0) END) total_d_aoci
				 FROM #calcprocess_aoci_release 
				 WHERE oci_rollout_approach_value_id <> 502  
		AND as_of_date = @_as_of_date
		AND i_term > as_of_date
		AND i_term <= DATEADD(mm, long_term_months - 1, @_as_of_date ) 
				 GROUP BY as_of_date, source_deal_header_id) aoci ON aoci.source_deal_header_id = deal.source_deal_header_id 
					AND aoci.as_of_date = deal.as_of_date   
LEFT OUTER JOIN	(
	SELECT	as_of_date, source_deal_header_id,  
			SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(aoci_allocation_pnl, 0) ELSE ISNULL(aoci_allocation_vol, 0) END) total_u_aoci,
			SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(d_aoci_allocation_pnl, 0) ELSE ISNULL(d_aoci_allocation_vol, 0) END) total_d_aoci
				 FROM #calcprocess_aoci_release 
				 WHERE oci_rollout_approach_value_id <> 502  
	AND as_of_date = as_of_date
	AND i_term > DATEADD(mm, long_term_months - 1, @_as_of_date ) 
	GROUP BY as_of_date, source_deal_header_id) aoci_l ON aoci_l.source_deal_header_id = deal.source_deal_header_id AND aoci_l.as_of_date = deal.as_of_date 
LEFT OUTER JOIN(
				SELECT link_id, 
						source_deal_header_id, h_term, MAX(i_term) max_i_term, 
						CASE WHEN (MAX(i_term) <= @_as_of_date) THEN 1 ELSE 0 END item_settled,    
		SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(aoci_allocation_pnl, 0) ELSE ISNULL(aoci_allocation_vol, 0) END) aoci_released,
		SUM(CASE WHEN (rollout_per_type IN (521, 523)) THEN ISNULL(d_aoci_allocation_pnl, 0) ELSE ISNULL(d_aoci_allocation_vol, 0) END) d_aoci_released
				FROM #calcprocess_aoci_release 
				WHERE oci_rollout_approach_value_id <> 502  
		AND as_of_date = @_as_of_date
		AND i_term <= as_of_date
				GROUP BY as_of_date, link_id, source_deal_header_id, h_term) ar ON ar.source_deal_header_id=deal.source_deal_header_id 
					AND ar.h_term = deal.term_start AND ar.link_id = deal.link_id AND deal.link_type = ''link''  
LEFT OUTER JOIN source_deal_header sdh ON sdh.source_deal_header_id = deal.source_deal_header_id
LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
	AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
	AND ssbm.source_system_book_id3 = sdh.source_system_book_id3 
	AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
LEFT OUTER JOIN portfolio_hierarchy phb ON phb.entity_id = ssbm.fas_book_id 
LEFT OUTER JOIN portfolio_hierarchy phs ON phs.entity_id = phb.parent_entity_id
LEFT OUTER JOIN fas_books fb ON fb.fas_book_id = phb.entity_id
LEFT OUTER JOIN source_book_map_GL_codes sgl ON sgl.source_book_map_id = ssbm.book_deal_type_map_id  

DECLARE @_term_stmt VARCHAR(1000) = '' WHERE 1 = 1''
DECLARE @_term_stmt1 VARCHAR(1000)

IF OBJECT_ID(''tempdb..#temp_MTM_JEP'') IS NOT NULL
	DROP TABLE #temp_MTM_JEP  

 CREATE TABLE [#temp_MTM_JEP] (
	[as_of_date] [DATETIME] NOT NULL ,
	[sub_entity_id] [INT] NULL ,
	[strategy_entity_id] [INT] NULL ,
	[book_entity_id] [INT] NULL ,
	[link_id] VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
	[link_deal_flag] VARCHAR(1) COLLATE DATABASE_DEFAULT  ,
	[term_month] [DATETIME] NULL ,
	[legal_entity] [INT] NULL,
	source_book_map_id INT NULL, 
	[Gl_Number] [INT] NULL ,
	[Debit] [FLOAT] NOT NULL ,
	[Credit] [FLOAT] NULL, 
	source_deal_header_id INT )   

IF OBJECT_ID(''tempdb..#basis_adjustments'') IS NOT NULL
	DROP TABLE #basis_adjustments  
 
-------------------THE FOLLOWING ARE THE IR related Interest Entries--------------------------------
SELECT ba.*, 
		ISNULL(CASE WHEN(sb.gl_grouping_value_id = 350) THEN fs.gl_id_amortization ELSE fb.gl_id_amortization END, @_amortization) Gl_Amortization_Expense,
		CASE WHEN (dbo.FNAShortTermTest(@_as_of_date, sdh.entire_term_start, sub.long_term_months) < 1) THEN -- st term
			CASE WHEN (header_buy_sell_flag = ''b'') THEN --liability
				ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_item_st_liab ELSE fb.gl_number_id_item_st_liab END, @_st_item_liability_gl_id)			
			ELSE
				ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_item_st_asset ELSE fb.gl_number_id_item_st_asset END, @_st_item_asset_gl_id)			
			END
		ELSE
			CASE WHEN (header_buy_sell_flag = ''b'') THEN --liability
				ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_item_lt_liab ELSE fb.gl_number_id_item_lt_liab END, @_lt_item_liability_gl_id)				
			ELSE
				ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_item_lt_asset ELSE fb.gl_number_id_item_lt_asset END, @_lt_item_asset_gl_id)			
			END
		END  Gl_item,
		stra.parent_entity_id sub_entity_id,
		fs.fas_strategy_id strategy_entity_id,
		ssbm.fas_book_id book_entity_id,
		COALESCE(fb.legal_entity, sdh.legal_entity) legal_entity 
	INTO #basis_adjustments
FROM #books sb 
INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = sb.fas_book_id 
INNER JOIN source_deal_header sdh ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
	AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
	AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 
	AND sdh.source_system_book_id4 = ssbm.source_system_book_id4 
INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id 
INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
INNER JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id 
INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id 
INNER JOIN fas_subsidiaries sub ON sub.fas_subsidiary_id = stra.parent_entity_id 
INNER JOIN basis_adjustments ba ON ba.source_deal_header_id = sdh.source_deal_header_id 
LEFT OUTER JOIN (SELECT source_deal_header_id source_deal_header_id1 
				FROM fas_link_Detail WHERE CAST(link_id AS VARCHAR) + ''l'' = (SELECT link_id FROM #links) AND hedge_or_item = ''i''
				) link ON link.source_deal_header_id1 = sdh.source_deal_header_id
WHERE as_of_date <= @_as_of_date AND fs.hedge_type_value_id = 151 AND isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 401
	AND ((link.source_deal_header_id1 IS NULL AND @_link_id IS NULL) 
	OR (link.source_deal_header_id1 IS NOT NULL AND @_link_id IS NOT NULL))

INSERT INTO #temp_MTM_JEP
SELECT	@_as_of_date as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, 
		source_deal_header_id, ''d'' link_deal_flag, 
		dbo.FNAContractMonthFormat(as_of_date) + ''-01'' term_start,
		legal_entity, NULL source_book_map_id, Gl_Amortization_Expense Gl_Number, 
		CASE WHEN (PMT >= 0) THEN PMT ELSE 0 END Debit,
		CASE WHEN (PMT < 0) THEN -1 * PMT ELSE 0 END Credit,
		source_deal_header_id
FROM #basis_adjustments

INSERT INTO #temp_MTM_JEP
SELECT	@_as_of_date as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, 
		source_deal_header_id, ''d'' link_deal_flag, 
		dbo.FNAContractMonthFormat(as_of_date) + ''-01'' term_start,
		legal_entity, NULL source_book_map_id, Gl_Item Gl_Number, 
		CASE WHEN (PMT < 0) THEN -1 * PMT ELSE 0 END Debit,
		CASE WHEN (PMT >= 0) THEN PMT ELSE 0 END Credit,
		source_deal_header_id
FROM #basis_adjustments

---------------------THE FOLLOWING ARE THE CASH RECONCILLATION ENTRIES--------------------------------
IF OBJECT_ID(''tempdb..#temp_cash'') IS NOT NULL
	DROP TABLE #temp_cash  
 
SELECT  @_as_of_date as_of_date, sub.entity_id sub_entity_id, stra.entity_id strategy_entity_id, 
		book.entity_id book_entity_id, sdcs.source_deal_header_id link_id, sdcs.term_start term_month,
		COALESCE(fb.legal_entity, sdh.legal_entity) legal_entity, 
		NULL Gl_Number_Cash_Received,
		ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_gross_set ELSE fb.gl_number_id_gross_set END, @_pnl_set) Gl_Number_Earnings,
		ISNULL(CASE WHEN (sb.gl_grouping_value_id = 350) THEN fs.gl_number_id_cash ELSE fb.gl_number_id_cash END, @_cash) Gl_Number_Receivable,
		ISNULL(sdcs.cash_settlement, 0) cash_settlement, ISNULL(sdcs.cash_received, 0) cash_received, 
		ISNULL(sdcs.cash_variance, 0) cash_variance,
		sdh.source_deal_header_id
INTO #temp_cash		
FROM source_deal_cash_settlement sdcs 
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdcs.source_deal_header_id 
INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
	AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
	AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 
	AND sdh.source_system_book_id4 = ssbm.source_system_book_id4 
INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id 
INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
INNER JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id 
INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id 
INNER JOIN #books sb ON sb.fas_book_id = fb.fas_book_id 
WHERE isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 400 AND sdcs.as_of_date <= dbo.FNAGetContractMonth(@_as_of_date)
 
INSERT INTO #temp_MTM_JEP
SELECT	as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, ''d'' link_deal_flag, term_month,
		legal_entity, NULL source_book_map_id, Gl_Number_Receivable Gl_Number, 
		CASE WHEN (cash_variance >= 0) THEN cash_variance ELSE 0 END Debit,
		CASE WHEN (cash_variance < 0) THEN -1 * cash_variance ELSE 0 END Credit,
		source_deal_header_id
FROM #temp_cash

INSERT INTO #temp_MTM_JEP
SELECT	as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, ''d'' link_deal_flag, term_month,
		legal_entity, NULL source_book_map_id, Gl_Number_Earnings Gl_Number, 
		CASE WHEN (cash_variance < 0) THEN -1 * cash_variance ELSE 0 END Debit,
		CASE WHEN (cash_variance >= 0) THEN cash_variance ELSE 0 END Credit,
		source_deal_header_id
FROM #temp_cash

-----------------------------------END OF CASH RECONCILLATION ENTRIES ----------------------------
---------------------------------THE FOLLOWING ARE MANUAL ADJUSTEMENT ENTRIES --------------------
INSERT INTO #temp_MTM_JEP
SELECT	@_as_of_date as_of_date
, MAX(st.parent_entity_id) sub_entity_id
, MAX(st.entity_id) strategy_entity_id
, b.entity_id book_entity_id
, NULL link_id
, ''d'' link_deal_flag
, NULL term_month
, MAX(fb.legal_entity) legal_entity
, NULL source_book_map_id
, MAX(mjd.gl_number_id) Gl_Number
, MAX(ISNULL(debit_amount, 0)) Debit
, MAX(ISNULL(credit_amount, 0)) Credit
, NULL source_deal_heaer_id
FROM manual_je_header mjh 
INNER JOIN	manual_je_detail mjd ON mjd.manual_je_id = mjh.manual_je_id 
LEFT OUTER JOIN	portfolio_hierarchy b ON b.entity_id = mjh.book_id 
LEFT OUTER JOIN	fas_books fb ON fb.fas_book_id = b.entity_id 
LEFT OUTER JOIN	portfolio_hierarchy st ON st.entity_id = b.parent_entity_id
INNER JOIN #books boo ON boo.book_id = mjh.book_id
WHERE (mjh.as_of_date <= @_as_of_date AND ISNULL(mjd.frequency, mjh.frequency) = ''r'' 
	AND	@_as_of_date <= COALESCE(mjd.until_date, mjh.until_date, @_as_of_date)) 
	OR (mjh.as_of_date = @_as_of_date AND ISNULL(mjd.frequency, mjh.frequency) = ''o'')
GROUP BY manual_je_detail_id,  b.entity_id
 
-----------------------------------END OF MANUAL ADJUSTMENT ENTRIES ------------------------------
IF @_discount_option IN (''u'' , ''d'')
BEGIN
	--===============Get hedge_st_asset============================
	--only pick up asset and liabilities for non-netting rules
	IF  @_tenor_option <> ''s''
	BEGIN		
		SET @_sql = ''
					INSERT INTO #temp_MTM_JEP   
					SELECT	cd.as_of_date, 
							cd.sub_entity_id, 
							cd.strategy_entity_id, 
							cd.book_entity_id, 
							cd.link_id, 
							cd.link_deal_flag, 
							cd.term_month, 
							cd.legal_entity, 
							cd.source_book_map_id,
							COALESCE(z.gl_code_hedge_st_asset, cd.gl_code_hedge_st_asset, CASE WHEN d_total_aoci = 0 AND link_deal_flag = ''''d'''' THEN  '' + @_un_st_asset_gl_id + '' ELSE '' + @_st_asset_gl_id + '' END) AS Gl_Number,   
					CASE WHEN ('' + @_discount_option + ''_hedge_st_asset >= 0) THEN '' + @_discount_option + ''_hedge_st_asset ELSE 0 END AS Debit, 
							CASE WHEN ('' + @_discount_option + ''_hedge_st_asset < 0) THEN -1 * '' + @_discount_option + ''_hedge_st_asset ELSE 0 END AS Credit  
							, source_deal_header_id''  

		SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_hedge_st_asset <> 0'' 
		SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_code_hedge_st_asset, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

		EXEC spa_print @_sql 						
		EXEC(@_sql)
		  
		--	--Unhedged Split st asset
		SET @_sql = ''INSERT INTO #temp_MTM_JEP   
					SELECT  cd.as_of_date, 
							cd.sub_entity_id, 
							cd.strategy_entity_id, 
							cd.book_entity_id, 
							cd.link_id, 
							cd.link_deal_flag, 
							cd.term_month, 
							cd.legal_entity, 
							cd.source_book_map_id,  
							COALESCE(z.gl_code_hedge_st_asset, cd.gl_code_un_hedge_st_asset, '' + @_un_st_asset_gl_id + '') AS Gl_Number,   
							CASE WHEN ('' + @_discount_option + ''_un_hedge_st_asset >= 0) THEN '' + @_discount_option + ''_un_hedge_st_asset ELSE 0 END AS Debit,   
							CASE WHEN ('' + @_discount_option + ''_un_hedge_st_asset < 0) THEN -1 * '' + @_discount_option + ''_un_hedge_st_asset ELSE 0 END AS Credit 
							, source_deal_header_id''  
			
		SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_un_hedge_st_asset <> 0''  	
		SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_code_hedge_st_asset, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt
		EXEC spa_print @_sql 						
		EXEC (@_sql)
		  		   
		--================Get hedge_st_liability============================
		SET @_sql = ''INSERT INTO #temp_MTM_JEP  
					SELECT  cd.as_of_date, 
							cd.sub_entity_id, 
							cd.strategy_entity_id, 
							cd.book_entity_id, 
							cd.link_id, 
							cd.link_deal_flag, 
							cd.term_month, 
							cd.legal_entity,
							cd.source_book_map_id, --add bookmapid  
							COALESCE(z.gl_code_hedge_st_liability, cd.gl_code_hedge_st_liability, CASE WHEN d_total_aoci = 0 AND link_deal_flag = ''''d'''' THEN '' + @_un_st_liability_gl_id + '' ELSE '' + @_st_liability_gl_id + '' END ) AS Gl_Number,   
					CASE WHEN ('' + @_discount_option + ''_hedge_st_liability < 0) THEN -1 * '' + @_discount_option + ''_hedge_st_liability ELSE 0 END AS Debit,
							CASE WHEN ('' + @_discount_option + ''_hedge_st_liability >= 0) THEN '' + @_discount_option + ''_hedge_st_liability ELSE 0 END AS Credit 
							, source_deal_header_id''  
		SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_hedge_st_liability <> 0'' 		
		
		SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_code_hedge_st_liability, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

		EXEC spa_print @_sql 						
		EXEC(@_sql)
		  		   
		--Unhedged Split st lia
		SET @_sql = ''INSERT INTO #temp_MTM_JEP  
					SELECT  as_of_date, 
							sub_entity_id, 
							strategy_entity_id, 
							book_entity_id, 
							link_id, 
							link_deal_flag, 
							term_month, 
							legal_entity,
							source_book_map_id, --add bookmapid  
							ISNULL(gl_code_un_hedge_st_liability, '' + @_un_st_liability_gl_id + '' ) AS Gl_Number,   
							CASE WHEN ('' + @_discount_option + ''_un_hedge_st_liability < 0) THEN -1 * '' + @_discount_option + ''_un_hedge_st_liability ELSE 0 END AS Debit,  
							CASE WHEN ('' + @_discount_option + ''_un_hedge_st_liability >= 0) THEN '' + @_discount_option + ''_un_hedge_st_liability ELSE 0 END AS Credit 
							, source_deal_header_id''  
		SET @_whe_re_stmt = '' WHERE '' + @_discount_option + ''_un_hedge_st_liability <> 0''   
						
		EXEC (@_sql + '' FROM #cd cd '' + @_whe_re_stmt)

		--===========================Get hedge_lt_asset==========================
		SET @_sql = ''INSERT INTO #temp_MTM_JEP  
					SELECT cd.as_of_date, 
							cd.sub_entity_id, 
							cd.strategy_entity_id,
							cd.book_entity_id, 
							cd.link_id, 
							cd.link_deal_flag, 
							cd.term_month, 
							cd.legal_entity,
							cd.source_book_map_id,
							COALESCE(z.gl_code_hedge_lt_asset, cd.gl_code_hedge_lt_asset, CASE WHEN d_total_aoci = 0 AND link_deal_flag = ''''d'''' THEN ''  + @_un_lt_asset_gl_id  + '' ELSE ''  + @_lt_asset_gl_id  + '' END ) AS Gl_Number,   
							CASE WHEN ('' + @_discount_option + ''_hedge_lt_asset >= 0) THEN '' + @_discount_option + ''_hedge_lt_asset ELSE 0 END AS Debit, 
					CASE WHEN ('' + @_discount_option + ''_hedge_lt_asset < 0) THEN -1 * '' + @_discount_option + ''_hedge_lt_asset ELSE 0 END AS Credit	
					, source_deal_header_id''

		SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_hedge_lt_asset <> 0'' 
						
		SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_code_hedge_lt_asset, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

		EXEC spa_print @_sql 						
		EXEC(@_sql)

		--Unhedged Split lt asset
		SET @_sql = ''INSERT INTO #temp_MTM_JEP  
					SELECT cd.as_of_date, 
							cd.sub_entity_id, 
							cd.strategy_entity_id,
							cd.book_entity_id, 
							cd.link_id, 
							cd.link_deal_flag, 
							cd.term_month, 
							cd.legal_entity,
							cd.source_book_map_id,  
							ISNULL(gl_code_un_hedge_lt_asset, '' + @_un_lt_asset_gl_id  + '') AS Gl_Number,   
							CASE WHEN ('' + @_discount_option + ''_un_hedge_lt_asset >= 0) THEN '' + @_discount_option + ''_un_hedge_lt_asset ELSE 0 END AS Debit,   
							CASE WHEN ('' + @_discount_option + ''_un_hedge_lt_asset < 0) THEN -1 * '' + @_discount_option + ''_un_hedge_lt_asset ELSE 0 END AS Credit 
							, source_deal_header_id
							''  

		SET @_whe_re_stmt = '' WHERE '' + @_discount_option + ''_un_hedge_lt_asset <> 0''   
		EXEC (@_sql + '' FROM #cd cd '' + @_whe_re_stmt)

		--==========================Get hedge_lt_liability========================
		SET @_sql =  ''INSERT INTO #temp_MTM_JEP  
					SELECT cd.as_of_date, 
							cd.sub_entity_id, 
							cd.strategy_entity_id,
							cd.book_entity_id, 
							cd.link_id, 
							cd.link_deal_flag, 
							cd.term_month, 
							cd.legal_entity,
							cd.source_book_map_id,
							COALESCE(z.gl_code_hedge_lt_liability, cd.gl_code_hedge_lt_liability, CASE WHEN d_total_aoci = 0 AND link_deal_flag = ''''d'''' THEN '' + @_un_lt_liability_gl_id + '' ELSE '' + @_lt_liability_gl_id + '' END) AS Gl_Number,   
							CASE WHEN ('' + @_discount_option + ''_hedge_lt_liability < 0) THEN -1 * '' + @_discount_option + ''_hedge_lt_liability ELSE 0 END AS Debit,
									CASE WHEN ('' + @_discount_option + ''_hedge_lt_liability >= 0) THEN '' + @_discount_option + ''_hedge_lt_liability ELSE 0 END AS Credit 
									, source_deal_header_id ''  

		SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_hedge_lt_liability <> 0'' 

		SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_code_hedge_lt_liability, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

		EXEC spa_print @_sql 						
		EXEC(@_sql)

		--Unhedged Split lt lia
		SET @_sql =  ''INSERT INTO #temp_MTM_JEP  
					SELECT  cd.as_of_date, 
							cd.sub_entity_id, 
							cd.strategy_entity_id,
							cd.book_entity_id, 
							cd.link_id, 
							cd.link_deal_flag, 
							cd.term_month, 
							cd.legal_entity,
							cd.source_book_map_id, 
							ISNULL(gl_code_un_hedge_lt_liability, '' + @_un_lt_liability_gl_id + '') AS Gl_Number,   
							CASE WHEN ('' + @_discount_option + ''_un_hedge_lt_liability < 0) THEN -1 * '' + @_discount_option + ''_un_hedge_lt_liability ELSE 0 END AS Debit,  
							CASE WHEN ('' + @_discount_option + ''_un_hedge_lt_liability >= 0) THEN '' + @_discount_option + ''_un_hedge_lt_liability ELSE 0 END AS Credit 
							, source_deal_header_id ''  

		SET @_whe_re_stmt = '' WHERE '' + @_discount_option + ''_un_hedge_lt_liability <> 0''   
		EXEC (@_sql + '' FROM #cd cd '' + @_whe_re_stmt)  
	END   
	--==========================Tax Assets/Liabilities================================
	--===============Get st tax asset ============================

	SET @_sql = ''INSERT INTO #temp_MTM_JEP  
				SELECT cd.as_of_date, 
						cd.sub_entity_id, 
						cd.strategy_entity_id,
						cd.book_entity_id, 
						cd.link_id, 
						cd.link_deal_flag, 
						cd.term_month, 
						cd.legal_entity,
						cd.source_book_map_id,
						COALESCE(z.gl_id_st_tax_asset, cd.gl_id_st_tax_asset, '' + @_st_tax_asset_gl_id  + '') AS Gl_Number, 
						CASE WHEN ('' + @_discount_option + ''_st_tax_asset >= 0) THEN '' + @_discount_option + ''_st_tax_asset ELSE 0 END AS Debit, 
						CASE WHEN ('' + @_discount_option + ''_st_tax_asset < 0) THEN -1 * '' + @_discount_option + ''_st_tax_asset ELSE 0 END AS Credit 
						, source_deal_header_id''  
	
	SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_st_tax_asset <> 0 ''
			
	IF @_aoci_tax_asset_liab = ''0''
	BEGIN 
		SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_id_st_tax_asset, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

		EXEC spa_print @_sql 						
		EXEC(@_sql)
	END
	  
		--===============Get st tax liability ============================
	SET @_sql = ''INSERT INTO #temp_MTM_JEP  
				SELECT cd.as_of_date, 
						cd.sub_entity_id, 
						cd.strategy_entity_id,
						cd.book_entity_id, 
						cd.link_id, 
						cd.link_deal_flag, 
						cd.term_month, 
						cd.legal_entity,
						cd.source_book_map_id,
						COALESCE(z.gl_id_st_tax_liab, cd.gl_id_st_tax_liab, '' + @_st_tax_liability_gl_id  + '') AS Gl_Number, 
						CASE WHEN ('' + @_discount_option + ''_st_tax_liability < 0) THEN -1 * '' + @_discount_option + ''_st_tax_liability ELSE 0 END AS Debit,
						CASE WHEN ('' + @_discount_option + ''_st_tax_liability >= 0) THEN '' + @_discount_option + ''_st_tax_liability ELSE 0 END AS Credit
						, source_deal_header_id''   

	SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_st_tax_liability <> 0 '' 
				
	IF @_aoci_tax_asset_liab = ''0''
	BEGIN 
		SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_id_st_tax_liab, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

		EXEC spa_print @_sql 						
		EXEC(@_sql)
	END
	--===============Get lt tax asset ============================

	SET @_sql = ''INSERT INTO #temp_MTM_JEP  
				SELECT cd.as_of_date, 
						cd.sub_entity_id, 
						cd.strategy_entity_id,
						cd.book_entity_id, 
						cd.link_id, 
						cd.link_deal_flag, 
						cd.term_month, 
						cd.legal_entity,
						cd.source_book_map_id,
						COALESCE(z.gl_id_lt_tax_asset, cd.gl_id_lt_tax_asset, '' + @_lt_tax_asset_gl_id + '') AS Gl_Number, 
						CASE WHEN ('' + @_discount_option + ''_lt_tax_asset >= 0) THEN '' + @_discount_option + ''_lt_tax_asset ELSE 0 END AS Debit, 
						CASE WHEN ('' + @_discount_option + ''_lt_tax_asset < 0) THEN -1 * '' + @_discount_option + ''_lt_tax_asset ELSE 0 END AS Credit 
						, source_deal_header_id ''  
	
	SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_lt_tax_asset <> 0 '' 
		
	IF @_aoci_tax_asset_liab = ''0''
	BEGIN 
		SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_id_lt_tax_asset, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

		EXEC spa_print @_sql 						
		EXEC(@_sql)
	END
	  
		--===============Get lt tax liability ============================
	SET @_sql = ''INSERT INTO #temp_MTM_JEP  
				SELECT  cd.as_of_date, 
						cd.sub_entity_id, 
						cd.strategy_entity_id,
						cd.book_entity_id, 
						cd.link_id, 
						cd.link_deal_flag, 
						cd.term_month, 
						cd.legal_entity,
						cd.source_book_map_id,
						COALESCE(z.gl_id_lt_tax_liab, cd.gl_id_lt_tax_liab, '' + @_lt_tax_liability_gl_id  + '') AS Gl_Number, 
						CASE WHEN ('' + @_discount_option + ''_lt_tax_liability < 0) THEN -1 * '' + @_discount_option + ''_lt_tax_liability ELSE 0 END AS Debit,
						CASE WHEN ('' + @_discount_option + ''_lt_tax_liability >= 0) THEN '' + @_discount_option + ''_lt_tax_liability ELSE 0 END AS Credit
						, source_deal_header_id ''   

	SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_lt_tax_liability <> 0 '' 

	IF @_aoci_tax_asset_liab = ''0''
	BEGIN 
		SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_id_lt_tax_liab, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt
		EXEC spa_print @_sql 						
		EXEC(@_sql)
	END
	  
		--===============Get tax reserve ============================
	SET @_sql = ''INSERT INTO #temp_MTM_JEP  
			SELECT cd.as_of_date, 
					cd.sub_entity_id, 
					cd.strategy_entity_id,
					cd.book_entity_id, 
					cd.link_id, 
					cd.link_deal_flag, 
					cd.term_month, 
					cd.legal_entity,
					cd.source_book_map_id,
					COALESCE(z.gl_id_tax_reserve, cd.gl_id_tax_reserve, '' + @_tax_reserve + '') AS Gl_Number, 
					CASE WHEN ('' + @_discount_option + ''_tax_reserve > 0) THEN '' + @_discount_option + ''_tax_reserve ELSE 0 END AS Debit,
					CASE WHEN ('' + @_discount_option + ''_tax_reserve <= 0) THEN -1 * '' + @_discount_option + ''_tax_reserve ELSE 0 END AS Credit
					, source_deal_header_id ''   
				
	SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_tax_reserve <> 0 '' 
	SET @_sql = @_sql + '' FROM #cd cd 
					OUTER APPLY (SELECT DISTINCT gl_id_tax_reserve, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
						AND z.term_month = cd.term_month '' 
						+ @_whe_re_stmt

	EXEC spa_print @_sql 						
	EXEC(@_sql)		
	
	--==========================Get total_PNL================================
	SET @_sql = '' INSERT INTO #temp_MTM_JEP  
				SELECT cd.as_of_date, 
					cd.sub_entity_id, 
					cd.strategy_entity_id,
					cd.book_entity_id, 
					cd.link_id, 
					cd.link_deal_flag, 
					cd.term_month, 
					cd.legal_entity,
					cd.source_book_map_id,
					COALESCE(z.gl_pnl, cd.gl_pnl, '' + @_total_pnl + '') AS Gl_Number, 
		            CASE WHEN('' + @_discount_option + ''_total_pnl <0) THEN -1* '' + @_discount_option + ''_total_pnl ELSE 0 END AS Debit, 
					CASE WHEN('' + @_discount_option + ''_total_pnl >= 0) THEN '' + @_discount_option + ''_total_pnl ELSE 0 END AS Credit 
					, source_deal_header_id ''   
	
	SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_total_pnl <> 0 '' 	
	SET @_sql = @_sql + '' FROM #cd cd 
					OUTER APPLY (SELECT DISTINCT gl_pnl, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
						AND z.term_month = cd.term_month '' 
						+ @_whe_re_stmt

	EXEC spa_print @_sql 						
	EXEC(@_sql)
	--==========================Get total_AOCI================================

	 

	SET @_sql = ''INSERT INTO #temp_MTM_JEP  
				SELECT cd.as_of_date, 
					cd.sub_entity_id, 
					cd.strategy_entity_id,
					cd.book_entity_id, 
					cd.link_id, 
					cd.link_deal_flag, 
					cd.term_month, 
					cd.legal_entity,
					cd.source_book_map_id,
					CASE WHEN (ISNULL(z.'' + @_discount_option + ''_total_aoci, cd.'' + @_discount_option + ''_total_aoci) <> 0 AND link_type_value_id = 451) THEN COALESCE(z.gl_dedesig_aoci, cd.gl_dedesig_aoci, '' + @_aoci + '') ELSE   
					COALESCE(z.gl_aoci, cd.gl_aoci , '' + @_aoci + '') END AS Gl_Number, 
		            CASE WHEN(ISNULL(z.'' + @_discount_option + ''_total_aoci, cd.'' + @_discount_option + ''_total_aoci) <0) THEN -1* ISNULL(z.'' + @_discount_option + ''_total_aoci, cd.'' + @_discount_option + ''_total_aoci) ELSE 0 END AS Debit, 
					CASE WHEN(ISNULL(z.'' + @_discount_option + ''_total_aoci, cd.'' + @_discount_option + ''_total_aoci) >= 0) THEN ISNULL(z.'' + @_discount_option + ''_total_aoci, cd.'' + @_discount_option + ''_total_aoci) ELSE 0 END AS Credit 
					, source_deal_header_id ''  

	SET @_term_stmt1 = CASE WHEN(@_term_stmt = '''') THEN '' AND  ISNULL(z.'' + @_discount_option + ''_total_aoci, cd.'' + @_discount_option + ''_total_aoci) <> 0'' 
					ELSE '' AND ISNULL(z.'' + @_discount_option + ''_total_aoci, cd.'' + @_discount_option + ''_total_aoci) <> 0'' END  
		
	SET @_sql = @_sql + '' FROM #cd cd 
					OUTER APPLY (SELECT DISTINCT  '' + @_discount_option + ''_total_aoci, gl_dedesig_aoci, gl_aoci, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
						AND z.term_month = cd.term_month '' 
						+ @_term_stmt1

	EXEC spa_print @_sql 						
	EXEC(@_sql)

	--========================Get Settlement==================================
	SET @_sql = ''INSERT INTO #temp_MTM_JEP  
				SELECT cd.as_of_date, 
					cd.sub_entity_id, 
					cd.strategy_entity_id,
					cd.book_entity_id, 
					cd.link_id, 
					cd.link_deal_flag, 
					cd.term_month, 
					cd.legal_entity,
					cd.source_book_map_id,
					COALESCE(z.gl_settlement, cd.gl_settlement, '' + @_pnl_set + '') AS Gl_Number, 
		            CASE WHEN('' + @_discount_option + ''_pnl_settlement <0) THEN -1*'' + @_discount_option + ''_pnl_settlement ELSE 0 END AS Debit, 
					CASE WHEN('' + @_discount_option + ''_pnl_settlement >= 0) THEN '' + @_discount_option + ''_pnl_settlement ELSE 0 END AS Credit 
					, source_deal_header_id ''  

	SET @_term_stmt1 = CASE WHEN(@_term_stmt = '''') THEN '' AND '' + @_discount_option + ''_pnl_settlement <> 0'' 
					ELSE '' AND '' + @_discount_option + ''_pnl_settlement <> 0'' END  
			
	SET @_sql = @_sql + '' FROM #cd cd 
					OUTER APPLY (SELECT DISTINCT gl_settlement, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
						AND z.term_month = cd.term_month '' 
						+ @_term_stmt1

	EXEC spa_print @_sql 						
	EXEC(@_sql)

	--========================Get Inventory==================================
	SET @_sql = ''INSERT INTO #temp_MTM_JEP  
			SELECT cd.as_of_date, 
				cd.sub_entity_id, 
				cd.strategy_entity_id,
				cd.book_entity_id, 
				cd.link_id, 
				cd.link_deal_flag, 
				cd.term_month, 
				cd.legal_entity,
				cd.source_book_map_id,
				COALESCE(z.gl_inventory, cd.gl_inventory, '' + @_inventory + '') AS Gl_Number, 
		        CASE WHEN('' + @_discount_option + ''_pnl_inventory <0) THEN -1*'' + @_discount_option + ''_pnl_inventory ELSE 0 END AS Debit, 
				CASE WHEN('' + @_discount_option + ''_pnl_inventory >= 0) THEN '' + @_discount_option + ''_pnl_inventory ELSE 0 END AS Credit 
				, source_deal_header_id ''  
		
	SET @_term_stmt1 = CASE WHEN(@_term_stmt = '''') THEN '' AND '' + @_discount_option + ''_pnl_inventory <> 0'' 
					ELSE '' AND '' + @_discount_option + ''_pnl_inventory <> 0'' END  
		
	SET @_sql = @_sql + '' FROM #cd cd 
					OUTER APPLY (SELECT DISTINCT gl_inventory, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
						AND z.term_month = cd.term_month '' 
						+ @_term_stmt1

	--========================Get Cash==================================
	SET @_sql = ''INSERT INTO #temp_MTM_JEP  
			SELECT cd.as_of_date, 
				cd.sub_entity_id, 
				cd.strategy_entity_id,
				cd.book_entity_id, 
				cd.link_id, 
				cd.link_deal_flag, 
				cd.term_month, 
				cd.legal_entity,
				cd.source_book_map_id,
				COALESCE(z.gl_cash, cd.gl_cash, '' + @_cash + '') AS Gl_Number, 
		        CASE WHEN('' + @_discount_option + ''_cash >=0) THEN '' + @_discount_option + ''_cash ELSE 0 END AS Debit, 
				CASE WHEN('' + @_discount_option + ''_cash < 0) THEN -1*'' + @_discount_option + ''_cash ELSE 0 END AS Credit 
				, source_deal_header_id ''  

	SET @_term_stmt1 = CASE WHEN(@_term_stmt = '''') THEN '' AND '' + @_discount_option + ''_cash <> 0'' 
						ELSE '' AND '' + @_discount_option + ''_cash <> 0'' END  
		
	SET @_sql = @_sql + '' FROM #cd cd 
					OUTER APPLY (SELECT DISTINCT gl_cash, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
						AND z.term_month = cd.term_month '' 
						+ @_term_stmt1

	EXEC spa_print @_sql 						
	EXEC(@_sql)
END
 
IF @_hedge_type = ''f'' OR @_hedge_type = ''c''
BEGIN
	IF @_discount_option IN (''u'' , ''d'')
	BEGIN
 
		--===============Get item_st_asset============================
		--only pick up asset and liabilities for non-netting rules
		IF  @_tenor_option <> ''s''
		BEGIN				
			SET @_sql = ''INSERT INTO #temp_MTM_JEP  
				SELECT  cd.as_of_date, 
					cd.sub_entity_id, 
					cd.strategy_entity_id,
					cd.book_entity_id, 
					cd.link_id, 
					cd.link_deal_flag, 
					cd.term_month, 
					cd.legal_entity,
					cd.source_book_map_id,
					COALESCE(z.gl_code_item_st_asset, cd.gl_code_item_st_asset, '' + @_st_item_asset_gl_id + '') AS Gl_Number, 
			        CASE WHEN ('' + @_discount_option + ''_item_st_asset >= 0) THEN '' + @_discount_option + ''_item_st_asset ELSE 0 END AS Debit, 
					CASE WHEN ('' + @_discount_option + ''_item_st_asset < 0) THEN -1 * '' + @_discount_option + ''_item_st_asset ELSE 0 END AS Credit 
					, source_deal_header_id ''  

			SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_item_st_asset <> 0 '' 		
				
			SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_code_item_st_asset, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

			EXEC spa_print @_sql 						
			EXEC(@_sql)		

			--================Get item_st_liability============================
			SET @_sql = ''INSERT INTO #temp_MTM_JEP  
					SELECT cd.as_of_date, 
						cd.sub_entity_id, 
						cd.strategy_entity_id,
						cd.book_entity_id, 
						cd.link_id, 
						cd.link_deal_flag, 
						cd.term_month, 
						cd.legal_entity,
						cd.source_book_map_id,
						COALESCE(z.gl_code_item_st_liability, cd.gl_code_item_st_liability, '' + @_st_item_liability_gl_id + '') AS Gl_Number, 
			            CASE WHEN ('' + @_discount_option + ''_item_st_liability < 0) THEN -1 * '' + @_discount_option + ''_item_st_liability ELSE 0 END AS Debit,
						CASE WHEN ('' + @_discount_option + ''_item_st_liability >= 0) THEN '' + @_discount_option + ''_item_st_liability ELSE 0 END AS Credit , source_deal_header_id ''  

			SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_item_st_liability <> 0 '' 			
			
			SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_code_item_st_liability, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

			EXEC spa_print @_sql 						
			EXEC(@_sql)		
			
			--===========================Get item_lt_asset==========================
			SET @_sql = ''INSERT INTO #temp_MTM_JEP  
					SELECT cd.as_of_date, 
						cd.sub_entity_id, 
						cd.strategy_entity_id,
						cd.book_entity_id, 
						cd.link_id, 
						cd.link_deal_flag, 
						cd.term_month, 
						cd.legal_entity,
						cd.source_book_map_id,
						COALESCE(z.gl_code_item_lt_asset, cd.gl_code_item_lt_asset, '' + @_lt_item_asset_gl_id + '') AS Gl_Number, 
			            CASE WHEN ('' + @_discount_option + ''_item_lt_asset >= 0) THEN '' + @_discount_option + ''_item_lt_asset ELSE 0 END AS Debit, 
						CASE WHEN ('' + @_discount_option + ''_item_lt_asset < 0) THEN -1 * '' + @_discount_option + ''_item_lt_asset ELSE 0 END AS Credit 
						, source_deal_header_id ''  

			SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_item_lt_asset <> 0 '' 						
			
			SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_code_item_lt_asset, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

			EXEC spa_print @_sql 						
			EXEC(@_sql)		

			--==========================Get item_lt_liability========================
			SET @_sql = ''INSERT INTO #temp_MTM_JEP  
						SELECT cd.as_of_date, 
							cd.sub_entity_id, 
							cd.strategy_entity_id,
							cd.book_entity_id, 
							cd.link_id, 
							cd.link_deal_flag, 
							cd.term_month, 
							cd.legal_entity,
							cd.source_book_map_id,
							COALESCE(z.gl_code_item_lt_liability, cd.gl_code_item_lt_liability, '' +  @_lt_item_liability_gl_id + '') AS Gl_Number, 
			                CASE WHEN ('' + @_discount_option + ''_item_lt_liability < 0) THEN -1 * '' + @_discount_option + ''_item_lt_liability ELSE 0 END AS Debit,
							CASE WHEN ('' + @_discount_option + ''_item_lt_liability >= 0) THEN '' + @_discount_option + ''_item_lt_liability ELSE 0 END AS Credit , source_deal_header_id ''  

			SET @_whe_re_stmt = '' AND '' + @_discount_option + ''_item_lt_liability <> 0 '' 			
			
			SET @_sql = @_sql + '' FROM #cd cd 
						OUTER APPLY (SELECT DISTINCT gl_code_item_lt_liability, link_id, term_month FROM #temp) z WHERE z.link_id = cd.link_id 
							AND z.term_month = cd.term_month '' 
							+ @_whe_re_stmt

			EXEC spa_print @_sql 						
			EXEC(@_sql)		

		END
	END
END
 
DECLARE @_pty_cpty VARCHAR(1000)
SELECT @_pty_cpty = [entity_name] FROM portfolio_hierarchy WHERE [entity_id] = -1

SELECT 
	  MAX(bb.sub_name) sub_name
	, MAX(bb.stra_name) stra_name
	, MAX(bb.book_name) book_name	
	, MAX(bb.logical_name) logical_name		
	, MAX(bb.tag_1) tag_1	
	, MAX(bb.tag_2) tag_2	
	, MAX(bb.tag_3) tag_3	
	, MAX(bb.tag_4) tag_4
	, ISNULL(gsm.gl_account_number, temp_rmv.Gl_Number) AS [GLNumber]
	, ISNULL(gsm.gl_account_name,
	CASE WHEN (temp_rmv.Gl_Number = -1) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.HSTAsset''   
		WHEN (temp_rmv.Gl_Number = -2) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.HSTLiab'' 
		WHEN (temp_rmv.Gl_Number = -3) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.HLTAsset'' 
		WHEN (temp_rmv.Gl_Number = -4) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.HLTLiab'' 
		WHEN (temp_rmv.Gl_Number = -5) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.ISTAsset'' 
		WHEN (temp_rmv.Gl_Number = -6) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.ISTLiab'' 
		WHEN (temp_rmv.Gl_Number = -7) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.ILTAsset'' 
		WHEN (temp_rmv.Gl_Number = -8) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.ILTLiab'' 
		WHEN (temp_rmv.Gl_Number = -9) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTAsset'' 
		WHEN (temp_rmv.Gl_Number = -10) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTLiab'' 
		WHEN (temp_rmv.Gl_Number = -11) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTAsset'' 
		WHEN (temp_rmv.Gl_Number = -12) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTLiab'' 
		WHEN (temp_rmv.Gl_Number = -13) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.TaxReserve'' 
		WHEN (temp_rmv.Gl_Number = -14) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.PNLSettlement'' 
		WHEN (temp_rmv.Gl_Number = -15) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.AOCI'' 
		WHEN (temp_rmv.Gl_Number = -16) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.PNLIneffectiveness'' 
		WHEN (temp_rmv.Gl_Number = -17) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.Inventory'' 
		WHEN (temp_rmv.Gl_Number = -18) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.Receivables'' 
		WHEN (temp_rmv.Gl_Number = -19) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.Cash'' 
		WHEN (temp_rmv.Gl_Number = -20) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.AccruedInterest'' 
		WHEN (temp_rmv.Gl_Number = -21) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.Interest'' 
		WHEN (temp_rmv.Gl_Number = -22) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.Amortization'' 
		WHEN (temp_rmv.Gl_Number = -23) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTAsset'' 
		WHEN (temp_rmv.Gl_Number = -24) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTLiab'' 
		WHEN (temp_rmv.Gl_Number = -25) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTAsset'' 
		WHEN (temp_rmv.Gl_Number = -26) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTLiab''  
		ELSE CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Unknown.GL.Code'' END) AS [AccountName]
	, temp_rmv.source_deal_header_id
	, sdh.deal_id
	, temp_rmv.link_id link_id_display
	, MAX(cg.[contract_name]) [contract_name]
	, MAX(sc.counterparty_name) counterparty_name
	, MAX(sco.commodity_name) commodity_name
	, SUM(temp_rmv.Debit) Debit
	, SUM(temp_rmv.Credit) Credit
	, @_pty_cpty [parent_counterparty]
	, NULL [Adjustment Amount]
	, ''@sub_id'' sub_id		
	, ''@stra_id'' stra_id		
	, ''@book_id'' book_id	 	
	, ''@sub_book_id'' sub_book_id
	, ''@as_of_date''	 as_of_date	
	, ''@hedge_type'' hedge_type
	, ''@discount_option'' discount_option	
	, ''@tenor_option'' tenor_option
	, MAX(CASE WHEN link_deal_flag = ''l'' THEN ''Link'' ELSE ''Deal'' END) link_deal_flag
	, term_month
	, MAX(sle.legal_entity_name) legal_entity
	, @_link_id link_id
--[__batch_report__]
FROM #temp_mtm_jep temp_rmv
LEFT JOIN gl_system_mapping gsm(NOLOCK) ON temp_rmv.Gl_Number = gsm.gl_number_id 
LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = temp_rmv.source_deal_header_id 
LEFT JOIN #books bb ON bb.fas_book_id = temp_rmv.book_entity_id
LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
LEFT JOIN source_commodity sco ON sco.source_commodity_id = sdh.commodity_id
LEFT JOIN source_legal_entity sle ON sle.source_legal_entity_id = temp_rmv.legal_entity
GROUP BY temp_rmv.source_deal_header_id,temp_rmv.term_month
	, sdh.deal_id
	, temp_rmv.link_id
	, ISNULL(temp_rmv.legal_entity, -1) 
	, ISNULL(gsm.gl_account_number, temp_rmv.Gl_Number)
	, ISNULL(gsm.gl_account_name,
	CASE WHEN (temp_rmv.Gl_Number = -1) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.HSTAsset''   
	WHEN (temp_rmv.Gl_Number = -2) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.HSTLiab'' 
	WHEN (temp_rmv.Gl_Number = -3) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.HLTAsset'' 
	WHEN (temp_rmv.Gl_Number = -4) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.HLTLiab'' 
	WHEN (temp_rmv.Gl_Number = -5) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.ISTAsset'' 
	WHEN (temp_rmv.Gl_Number = -6) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.ISTLiab'' 
	WHEN (temp_rmv.Gl_Number = -7) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.ILTAsset'' 
	WHEN (temp_rmv.Gl_Number = -8) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.ILTLiab'' 
	WHEN (temp_rmv.Gl_Number = -9) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTAsset'' 
	WHEN (temp_rmv.Gl_Number = -10) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.TaxSTLiab'' 
	WHEN (temp_rmv.Gl_Number = -11) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTAsset'' 
	WHEN (temp_rmv.Gl_Number = -12) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.TaxLTLiab'' 
	WHEN (temp_rmv.Gl_Number = -13) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.TaxReserve'' 
	WHEN (temp_rmv.Gl_Number = -14) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.PNLSettlement'' 
	WHEN (temp_rmv.Gl_Number = -15) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.AOCI'' 
	WHEN (temp_rmv.Gl_Number = -16) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.PNLIneffectiveness'' 
	WHEN (temp_rmv.Gl_Number = -17) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.Inventory'' 
	WHEN (temp_rmv.Gl_Number = -18) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.Receivables'' 
	WHEN (temp_rmv.Gl_Number = -19) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.Cash'' 
	WHEN (temp_rmv.Gl_Number = -20) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.AccruedInterest'' 
	WHEN (temp_rmv.Gl_Number = -21) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.Interest'' 
	WHEN (temp_rmv.Gl_Number = -22) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.Amortization'' 
	WHEN (temp_rmv.Gl_Number = -23) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTAsset'' 
	WHEN (temp_rmv.Gl_Number = -24) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.UnHSTLiab'' 
	WHEN (temp_rmv.Gl_Number = -25) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTAsset'' 
	WHEN (temp_rmv.Gl_Number = -26) THEN  CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Undefined.UnHLTLiab''  
	ELSE CAST(temp_rmv.book_entity_id AS VARCHAR) + ''.Unknown.GL.Code'' END)  
	, term_month

 
 ', report_id = @report_id_data_source_dest,
	system_defined = '1'
	,category = '106500' 
	WHERE [name] = 'Journal Entry Extract View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'AccountName'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Account Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'AccountName'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'AccountName' AS [name], 'Account Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'Adjustment Amount'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Adjustment Amount'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'Adjustment Amount'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Adjustment Amount' AS [name], 'Adjustment Amount' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = NULL, widget_id = 5, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'Book ID' AS ALIAS, NULL AS reqd_param, 5 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'book_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'book_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_name' AS [name], 'Book Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'commodity_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'commodity_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_name' AS [name], 'Commodity Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'contract_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'contract_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_name' AS [name], 'Contract Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'Counterparty' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'Credit'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Credit'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'Credit'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Credit' AS [name], 'Credit' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reference ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'deal_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_id' AS [name], 'Reference ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'Debit'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Debit'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'Debit'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Debit' AS [name], 'Debit' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'discount_option'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Discount Option'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'select ''d'' as id, ''Present Value'' code UNION ALL ' + CHAR(10) + 'select ''u'' as id, ''Future Value'' code', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'discount_option'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'discount_option' AS [name], 'Discount Option' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'select ''d'' as id, ''Present Value'' code UNION ALL ' + CHAR(10) + 'select ''u'' as id, ''Future Value'' code' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'GLNumber'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'GL Number'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'GLNumber'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'GLNumber' AS [name], 'GL Number' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'legal_entity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Legal Entity'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'legal_entity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'legal_entity' AS [name], 'Legal Entity' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'link_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Link ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'link_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'link_id' AS [name], 'Link ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'logical_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Logical Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'logical_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'logical_name' AS [name], 'Logical Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'parent_counterparty'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Parent Counterparty'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'parent_counterparty'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'parent_counterparty' AS [name], 'Parent Counterparty' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy ID'
			   , reqd_param = NULL, widget_id = 4, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'Strategy ID' AS ALIAS, NULL AS reqd_param, 4 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'stra_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Stra Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'stra_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_name' AS [name], 'Stra Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'sub_book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book ID'
			   , reqd_param = NULL, widget_id = 8, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'sub_book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_id' AS [name], 'Sub Book ID' AS ALIAS, NULL AS reqd_param, 8 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = NULL, widget_id = 3, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'Subsidiary ID' AS ALIAS, NULL AS reqd_param, 3 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'sub_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'sub_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_name' AS [name], 'Sub Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'tag_1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Tag 1'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'tag_1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'tag_1' AS [name], 'Tag 1' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'tag_2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Tag 2'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'tag_2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'tag_2' AS [name], 'Tag 2' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'tag_3'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Tag 3'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'tag_3'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'tag_3' AS [name], 'Tag 3' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'tag_4'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Tag 4'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'tag_4'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'tag_4' AS [name], 'Tag 4' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'tenor_option'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Tenor Option'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT * FROM (SELECT ''a'' AS [Value], ''All'' AS [Label] UNION ALL SELECT ''s'' AS [Value], ''Settlement Values'' AS [Label] UNION ALL SELECT ''c'' AS [Value], ''Current and Forward Months'' AS [Label] UNION ALL SELECT ''f'' AS [Value], ''Forward Months'' AS [Label]) a', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'tenor_option'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'tenor_option' AS [name], 'Tenor Option' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT * FROM (SELECT ''a'' AS [Value], ''All'' AS [Label] UNION ALL SELECT ''s'' AS [Value], ''Settlement Values'' AS [Label] UNION ALL SELECT ''c'' AS [Value], ''Current and Forward Months'' AS [Label] UNION ALL SELECT ''f'' AS [Value], ''Forward Months'' AS [Label]) a' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'hedge_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Hedge Type'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT * FROM ( SELECT ''c'' AS [Value], ''Cash Flow'' AS [Label] UNION ALL SELECT ''f'' AS [Value], ''Fair Value'' AS [Label] UNION ALL SELECT ''m'' AS [Value], ''MTM'' AS [Label] ) a', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'hedge_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'hedge_type' AS [name], 'Hedge Type' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT * FROM ( SELECT ''c'' AS [Value], ''Cash Flow'' AS [Label] UNION ALL SELECT ''f'' AS [Value], ''Fair Value'' AS [Label] UNION ALL SELECT ''m'' AS [Value], ''MTM'' AS [Label] ) a' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'link_deal_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Link Deal'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'link_deal_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'link_deal_flag' AS [name], 'Link Deal' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'term_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Month'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'term_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_month' AS [name], 'Term Month' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Journal Entry Extract View'
	            AND dsc.name =  'link_id_display'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Link ID Display'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Journal Entry Extract View'
			AND dsc.name =  'link_id_display'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'link_id_display' AS [name], 'Link ID Display' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Journal Entry Extract View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Journal Entry Extract View'
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
 