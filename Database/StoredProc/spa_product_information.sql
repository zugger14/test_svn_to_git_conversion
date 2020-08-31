IF OBJECT_ID(N'spa_product_information', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_product_information]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	Used in the report to get the product information.

	Parameters
	@sub_id : Sub Id
	@stra_id : Stra Id
	@book_id : Book Id
	@sub_book_id : Sub Book Id
	@certificate_expiration_date_from : Certificate Expiration Date From
	@certificate_expiration_date_to : Certificate Expiration Date To
	@vintage_year_id : Vintage Year Id
	@tier_id : Tier Id
	@jurisdiction_id : Jurisdiction Id
	@source_deal_header_id : Source Deal Header Id
	@process_id : Process Id
	@term_start : Term Start
	@term_end : Term End
	@call_from : Call From
*/
CREATE PROC [dbo].[spa_product_information]
	@sub_id VARCHAR(MAX) = NULL,
	@stra_id VARCHAR(MAX) = NULL,
	@book_id VARCHAR(MAX) = NULL,
	@sub_book_id VARCHAR(MAX) = NULL,
	@certificate_expiration_date_from VARCHAR(10) = NULL,
	@certificate_expiration_date_to VARCHAR(1000) = NULL,
	@vintage_year_id VARCHAR(1000) = NULL,
	@tier_id VARCHAR(1000) = NULL,
	@jurisdiction_id VARCHAR(1000) = NULL,
	@source_deal_header_id VARCHAR(MAX) = NULL,
	@process_id VARCHAR(50),
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@call_from VARCHAR(20) = NULL
AS
/*--------------Debug Section----------------
DECLARE @sub_id VARCHAR(MAX) = NULL,
		@stra_id VARCHAR(MAX) = NULL,
		@book_id VARCHAR(MAX) = NULL,
		@sub_book_id VARCHAR(MAX) = NULL,
		@certificate_expiration_date_from VARCHAR(10) = NULL,
		@certificate_expiration_date_to VARCHAR(1000) = NULL,
		@vintage_year_id VARCHAR(1000) = NULL,
		@tier_id VARCHAR(1000) = NULL,
		@jurisdiction_id VARCHAR(1000) = NULL,
		@source_deal_header_id VARCHAR(MAX) = NULL,
		@process_id VARCHAR(50) = REPLACE(NEWID(),'-','_'),
		@term_start DATETIME = NULL,
		@term_end DATETIME = NULL,
		@call_from VARCHAR(20) = NULL

SELECT @sub_id=NULL,@stra_id=NULL,@book_id =NULL,@sub_book_id ='642',@source_deal_header_id =1190
-------------------------------------------*/
SET NOCOUNT ON

BEGIN
	DECLARE @_sql_string VARCHAR(MAX),
			@process_table VARCHAR(100)
	
	SET @process_table = dbo.FNAProcessTableName('product_view', dbo.FNADBUser(), @process_id)
	
	IF OBJECT_ID('tempdb..#books') IS NOT NULL
		DROP TABLE #books
	
	CREATE TABLE #books (
		sub_id INT,
		stra_id INT,
		book_id INT,
		sub_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
		stra_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
		book_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
		source_system_book_id1 INT,
		source_system_book_id2 INT,
		source_system_book_id3 INT,
		source_system_book_id4 INT,
		sub_book_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
		sub_book_id INT
	)

	SET @_sql_string = '
	INSERT INTO #books
	SELECT sub.[entity_id] sub_id,
		   stra.[entity_id] stra_id,
		   book.[entity_id] book_id,
		   sub.[entity_name] sub_name,
		   stra.[entity_name] stra_name,
		   book.[entity_name] book_name,
		   ssbm.source_system_book_id1,
		   ssbm.source_system_book_id2,
		   ssbm.source_system_book_id3,
		   ssbm.source_system_book_id4,
		   ssbm.logical_name sub_book_name,  
		   ssbm.book_deal_type_map_id [sub_book_id]
	FROM portfolio_hierarchy book(NOLOCK)
	INNER JOIN Portfolio_hierarchy stra(NOLOCK)
		ON  book.parent_entity_id = stra.[entity_id]
	INNER JOIN portfolio_hierarchy sub(NOLOCK)
		ON stra.parent_entity_id = sub.[entity_id]
	INNER JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.[entity_id]
	WHERE 1 = 1
	' +
	--CASE WHEN 49 IS NOT NULL THEN ' AND sub.[entity_id] IN (' + '49' + ')' ELSE '' END
	CASE WHEN @sub_id IS NOT NULL THEN ' AND sub.[entity_id] IN (' + @sub_id + ')' ELSE '' END +
	CASE WHEN @stra_id IS NOT NULL THEN ' AND stra.[entity_id] IN (' + @stra_id + ')' ELSE '' END +
	CASE WHEN @book_id IS NOT NULL THEN ' AND book.[entity_id] IN (' + @book_id + ')' ELSE '' END +
	CASE WHEN @sub_book_id IS NOT NULL THEN ' AND ssbm.book_deal_type_map_id IN (' + @sub_book_id + ')' ELSE '' END 

	EXEC (@_sql_string)

	IF OBJECT_ID('tempdb..#source_deal_header') IS NOT NULL
		DROP TABLE #source_deal_header

	CREATE TABLE #source_deal_header (source_deal_header_id INT, deal_id NVARCHAR(300) COLLATE DATABASE_DEFAULT, source_system_book_id1 INT,
		source_system_book_id2 INT, source_system_book_id3 INT, source_system_book_id4 INT, state_value_id INT, tier_value_id INT,
		generator_id INT, sub_id INT, stra_id INT, book_id INT, sub_book_id INT, sub NVARCHAR(100) COLLATE DATABASE_DEFAULT, stra NVARCHAR(100) COLLATE DATABASE_DEFAULT, book NVARCHAR(100) COLLATE DATABASE_DEFAULT, sub_book NVARCHAR(200) COLLATE DATABASE_DEFAULT)
	

	IF OBJECT_ID('tempdb..#deal_collection') IS NOT NULL
		DROP TABLE #deal_collection

	IF @call_from = 'import'
	BEGIN		
		SELECT sdh.source_deal_header_id
		INTO #deal_collection								
		FROM source_deal_header sdh		
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
		AND sdd.term_start >= @term_start AND sdd.term_end <= @term_end
		GROUP BY sdh.source_deal_header_id				
	END

	SET @_sql_string=
		'INSERT INTO #source_deal_header (
				   source_deal_header_id,
				   deal_id,
				   source_system_book_id1,
				   source_system_book_id2,
				   source_system_book_id3,
				   source_system_book_id4,
				   state_value_id,
				   tier_value_id,
				   generator_id,
				   sub_id,
				   stra_id,
				   book_id,
				   sub_book_id,
				   sub,
				   stra,
				   book,
				   sub_book	
			)
		SELECT sdh.source_deal_header_id,
			   sdh.deal_id,
			   sdh.source_system_book_id1,
			   sdh.source_system_book_id2,
			   sdh.source_system_book_id3,
			   sdh.source_system_book_id4,
			   sdh.state_value_id,
			   sdh.tier_value_id,
			   sdh.generator_id,
			   book.sub_id,
			   book.stra_id,
			   book.book_id,
			   book.sub_book_id,
			   book.sub_name sub,
			   book.stra_name stra,
			   book.book_name book,
			   book.sub_book_name sub_book
		FROM source_deal_header sdh '
		+
		CASE WHEN @call_from = 'import' THEN
			'INNER JOIN #deal_collection dc ON dc.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN #books book
				ON book.source_system_book_id1 = sdh.source_system_book_id1
				   AND book.source_system_book_id2 = sdh.source_system_book_id2
				   AND book.source_system_book_id3 = sdh.source_system_book_id3
				   AND book.source_system_book_id4 = sdh.source_system_book_id4'
		ELSE 
			'INNER JOIN #books book
				ON book.source_system_book_id1 = sdh.source_system_book_id1
				   AND book.source_system_book_id2 = sdh.source_system_book_id2
				   AND book.source_system_book_id3 = sdh.source_system_book_id3
				   AND book.source_system_book_id4 = sdh.source_system_book_id4
			' + CASE WHEN @source_deal_header_id IS NOT NULL THEN ' WHERE sdh.source_deal_header_id IN (' + @source_deal_header_id + ')' ELSE '' END 
		END
	EXEC(@_sql_string) 

	CREATE NONCLUSTERED INDEX idx_source_deal_header ON #source_deal_header(source_deal_header_id)
	CREATE NONCLUSTERED INDEX idx_state_value_id ON #source_deal_header(state_value_id)
	CREATE NONCLUSTERED INDEX idx_tier_value_id ON #source_deal_header(tier_value_id)
	CREATE NONCLUSTERED INDEX idx_generator_id ON #source_deal_header(generator_id)
	
	IF OBJECT_ID('tempdb..#tmp_state_properties_all') IS NOT NULL
		DROP TABLE #tmp_state_properties_all

	SELECT CAST(t.item AS INT) region_id,
		   sp.state_value_id,	   
		   spd.tier_id,
		   spd.technology_id,
		   NULL vintage
	INTO #tmp_state_properties_all
	FROM state_properties sp
	OUTER APPLY (
		SELECT item 
		FROM dbo.SplitCommaSeperatedValues(sp.region_id)
	
	) t
	LEFT JOIN state_properties_details spd
		ON spd.state_value_id = sp.state_value_id

	CREATE NONCLUSTERED INDEX idx_region_id ON #tmp_state_properties_all(region_id)
	CREATE NONCLUSTERED INDEX idx_state_value_id ON #tmp_state_properties_all(state_value_id)
	CREATE NONCLUSTERED INDEX idx_tier_id ON #tmp_state_properties_all(tier_id)
	CREATE NONCLUSTERED INDEX idx_technology_id ON #tmp_state_properties_all(technology_id)

	--From Certificate
	IF OBJECT_ID('tempdb..#from_certificate') IS NOT NULL
		DROP TABLE #from_certificate

	SELECT DISTINCT 
		   sdh.source_deal_header_id,
		   sdd.source_deal_detail_id,
		   sdd.term_start,
		   sdd.term_end,
		   spd.region_id,
		   gc.state_value_id,
		   gc.tier_type AS tier_id,
		   gc.year AS vintage,
		   gc.gis_cert_date,
		   gc.contract_expiration_date,
		   gc.gis_certificate_number_from,
		   gc.gis_certificate_number_to,
		   gc.certification_entity,
		   gc.certificate_number_from_int,
		   gc.certificate_number_To_int
	INTO #from_certificate
	FROM Gis_Certificate gc
	LEFT JOIN #tmp_state_properties_all spd
		ON spd.tier_id = gc.tier_type
			AND spd.state_value_id = gc.state_value_id	
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_detail_id = gc.source_deal_header_id
	INNER JOIN #source_deal_header sdh
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	
	IF NOT EXISTS (SELECT 1 FROM #from_certificate)
	BEGIN
		INSERT INTO #from_certificate
		SELECT a.sale_deal_id,
			   a.sale_detail_id,
			   sdd.term_start,
			   sdd.term_end,
			   NULL region_id,
			   gc.state_value_id,
			   gc.tier_type AS tier_id,
			   gc.year AS vintage,
			   gc.gis_cert_date,
			   gc.contract_expiration_date,
			   gc.gis_certificate_number_from,
			   gc.gis_certificate_number_to,
			   gc.certification_entity,
			   a.cert_from,
			   a.cert_to
		FROM #source_deal_header sdh
		OUTER APPLY (
			SELECT sale_deal_id, 
				   sale_detail_id,
				   detail_id,
				   tier,
				   state_value_id,
				   cert_from,
				   cert_to
			FROM [dbo].[FNAGetMatchProcessCertificate](sdh.source_deal_header_id)
		) a
		INNER JOIN Gis_Certificate gc ON gc.source_deal_header_id = a.detail_id
			AND a.tier = gc.tier_type
			AND a.state_value_id = gc.state_value_id
		INNER JOIN source_deal_detail sdd 
			ON sdd.source_deal_detail_id = a.sale_detail_id	
	END
		
	CREATE NONCLUSTERED INDEX idx_source_deal_header_id ON #from_certificate(source_deal_header_id)
	CREATE NONCLUSTERED INDEX idx_region_id ON #from_certificate(region_id)
	CREATE NONCLUSTERED INDEX idx_state_value_id ON #from_certificate(state_value_id)
	CREATE NONCLUSTERED INDEX idx_tier_id ON #from_certificate(tier_id)
	
	--Check product property
	BEGIN
		IF OBJECT_ID('tempdb..#check_product_property') IS NOT NULL
			DROP TABLE #check_product_property

		CREATE TABLE #check_product_property (
			product_property_id INT IDENTITY(1, 1) PRIMARY KEY,
			source_deal_header_id INT,
			region_id INT,
			state_value_id  INT,
			tier_id INT,
			technology_id INT,
			vintage INT
		)

		INSERT INTO #check_product_property
		SELECT gp.source_deal_header_id,
			   gp.region_id,
			   gp.jurisdiction_id state_value_id,
			   gp.tier_id,
			   gp.technology_id,
			   gp.vintage
		FROM gis_product gp 
		INNER JOIN #source_deal_header sdh
			ON sdh.source_deal_header_id = gp.source_deal_header_id
		WHERE gp.in_or_not = 1

		CREATE NONCLUSTERED INDEX idx_source_deal_header_id ON #check_product_property(source_deal_header_id)
		CREATE NONCLUSTERED INDEX idx_region_id ON #check_product_property(region_id)
		CREATE NONCLUSTERED INDEX idx_state_value_id ON #check_product_property(state_value_id)
		CREATE NONCLUSTERED INDEX idx_tier_id ON #check_product_property(tier_id)
		CREATE NONCLUSTERED INDEX idx_technology_id ON #check_product_property(technology_id)
	
		IF OBJECT_ID('tempdb..#from_product_in') IS NOT NULL
			DROP TABLE #from_product_in

		CREATE TABLE #from_product_in (
			source_deal_header_id INT,
			region_id INT,
			state_value_id INT,
			tier_id INT,
			technology_id INT,
			vintage INT
		)

		DECLARE @product_property_id INT
		DECLARE @get_product_info CURSOR
		SET @get_product_info = CURSOR FOR

		SELECT product_property_id 
		FROM #check_product_property

		OPEN @get_product_info
		FETCH NEXT
		FROM @get_product_info INTO @product_property_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF EXISTS(
				SELECT 1
				FROM #check_product_property 
				WHERE ((technology_id IS NULL AND region_id IS NOT NULL)
				OR (technology_id IS NOT NULL AND region_id IS NOT NULL AND state_value_id IS NOT NULL)
				OR (technology_id IS NOT NULL AND region_id IS NOT NULL AND state_value_id IS NOT NULL AND tier_id IS NOT NULL)
				OR (technology_id IS NOT NULL AND region_id IS NOT NULL))
				AND product_property_id = @product_property_id
			)
			BEGIN
				INSERT INTO #from_product_in
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   cpp.vintage vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #check_product_property cpp
					ON tsp.region_id = cpp.region_id
				WHERE ISNULL(cpp.state_value_id, -1) = IIF(cpp.state_value_id IS NULL, -1, tsp.state_value_id)
					AND ISNULL(cpp.tier_id, -1) = IIF(cpp.tier_id IS NULL, -1, tsp.tier_id)
					AND ISNULL(cpp.technology_id, -1) = IIF(cpp.technology_id IS NULL, -1, tsp.technology_id)
					AND product_property_id = @product_property_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #check_product_property 
				WHERE ((technology_id IS NOT NULL AND region_id IS NULL)
					OR (technology_id IS NOT NULL AND region_id IS NULL AND state_value_id IS NOT NULL)
					OR (technology_id IS NOT NULL AND region_id IS NULL AND tier_id IS NOT NULL)
					OR (technology_id IS NOT NULL AND region_id IS NULL AND state_value_id IS NOT NULL AND tier_id IS NOT NULL))
					AND product_property_id = @product_property_id
			)
			BEGIN
				INSERT INTO #from_product_in
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   cpp.vintage vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #check_product_property cpp
					ON cpp.technology_id = tsp.technology_id
				WHERE ISNULL(cpp.state_value_id, -1) = IIF(cpp.state_value_id IS NULL, -1, tsp.state_value_id )
					AND ISNULL(cpp.tier_id, -1) = IIF(cpp.tier_id IS NULL, -1, tsp.tier_id )
					AND product_property_id = @product_property_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #check_product_property 
				WHERE state_value_id IS NOT NULL
					AND region_id IS NULL
					AND tier_id IS NULL
					AND technology_id IS NULL
					AND product_property_id = @product_property_id
			)
			BEGIN
				INSERT INTO #from_product_in
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   cpp.vintage vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #check_product_property cpp
					ON cpp.state_value_id = tsp.state_value_id
				WHERE product_property_id = @product_property_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #check_product_property 
				WHERE state_value_id IS NULL
					AND region_id IS NULL
					AND tier_id IS NOT NULL
					AND technology_id IS NULL
					AND product_property_id = @product_property_id
			)
			BEGIN
				INSERT INTO #from_product_in
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   cpp.vintage vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #check_product_property cpp
					ON cpp.tier_id = tsp.tier_id
				WHERE product_property_id = @product_property_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #check_product_property 
				WHERE state_value_id IS NOT NULL
					AND region_id IS NULL
					AND tier_id IS NOT NULL
					AND technology_id IS NULL
					AND product_property_id = @product_property_id
			)
			BEGIN
				INSERT INTO #from_product_in
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   cpp.vintage vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #check_product_property cpp
					ON cpp.tier_id = tsp.tier_id
						AND cpp.state_value_id = tsp.state_value_id
				WHERE product_property_id = @product_property_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #check_product_property 
				WHERE state_value_id IS NULL
					AND region_id IS NOT NULL
					AND tier_id IS NOT NULL
					AND technology_id IS NOT NULL
					AND product_property_id = @product_property_id
			)
			BEGIN
				INSERT INTO #from_product_in
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   NULL vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #check_product_property cpp
					ON cpp.technology_id = tsp.technology_id
						AND cpp.tier_id = tsp.tier_id
						AND product_property_id = @product_property_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #check_product_property 
				WHERE state_value_id IS NULL
					AND region_id IS NULL
					AND tier_id IS NULL
					AND technology_id IS NULL
					AND product_property_id = @product_property_id
			)
			BEGIN
				INSERT INTO #from_product_in
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   NULL vintage
				FROM #tmp_state_properties_all tsp
				OUTER APPLY (
					SELECT source_deal_header_id
					FROM #check_product_property 
					WHERE product_property_id = @product_property_id
					GROUP BY source_deal_header_id
				) cpp
				GROUP BY cpp.source_deal_header_id, tsp.region_id, tsp.state_value_id, tsp.tier_id, tsp.technology_id
			END
		FETCH NEXT
		FROM @get_product_info INTO @product_property_id
		END
		CLOSE @get_product_info
		DEALLOCATE @get_product_info

		CREATE NONCLUSTERED INDEX idx_source_deal_header_id ON #from_product_in(source_deal_header_id)
		CREATE NONCLUSTERED INDEX idx_region_id ON #from_product_in(region_id)
		CREATE NONCLUSTERED INDEX idx_state_value_id ON #from_product_in(state_value_id)
		CREATE NONCLUSTERED INDEX idx_tier_id ON #from_product_in(tier_id)
		CREATE NONCLUSTERED INDEX idx_technology_id ON #from_product_in(technology_id)
	
		IF OBJECT_ID('tempdb..#out_table_property') IS NOT NULL
			DROP TABLE #out_table_property

		CREATE TABLE #out_table_property (
			out_id INT IDENTITY(1, 1) PRIMARY KEY,
			source_deal_header_id INT,
			region_id INT,
			state_value_id INT,	
			tier_id INT,
			technology_id INT,
			vintage INT
		)

		INSERT INTO #out_table_property
		SELECT gp.source_deal_header_id,
			   gp.region_id,
			   gp.jurisdiction_id state_value_id,
			   gp.tier_id,
			   gp.technology_id,
			   gp.vintage
		FROM gis_product gp
		INNER JOIN #source_deal_header sdh
			ON sdh.source_deal_header_id = gp.source_deal_header_id
		WHERE in_or_not = 0

		CREATE NONCLUSTERED INDEX idx_source_deal_header_id ON #out_table_property(source_deal_header_id)
		CREATE NONCLUSTERED INDEX idx_region_id ON #out_table_property(region_id)
		CREATE NONCLUSTERED INDEX idx_state_value_id ON #out_table_property(state_value_id)
		CREATE NONCLUSTERED INDEX idx_tier_id ON #out_table_property(tier_id)
		CREATE NONCLUSTERED INDEX idx_technology_id ON #out_table_property(technology_id)
	
		IF OBJECT_ID('tempdb..#from_product_out') IS NOT NULL
			DROP TABLE #from_product_out

		CREATE TABLE #from_product_out (
			source_deal_header_id INT,
			region_id INT,
			state_value_id INT,
			tier_id INT,
			technology_id INT,
			vintage INT
		)

		DECLARE @out_id INT
		DECLARE @get_out_info CURSOR
		SET @get_out_info = CURSOR FOR

		SELECT out_id 
		FROM #out_table_property

		OPEN @get_out_info
		FETCH NEXT
		FROM @get_out_info INTO @out_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF EXISTS(
				SELECT 1
				FROM #out_table_property 
				WHERE ((technology_id IS NULL AND region_id IS NOT NULL)
				OR (technology_id IS NOT NULL AND region_id IS NOT NULL AND state_value_id IS NOT NULL)
				OR (technology_id IS NOT NULL AND region_id IS NOT NULL AND state_value_id IS NOT NULL AND tier_id IS NOT NULL)
				OR (technology_id IS NOT NULL AND region_id IS NOT NULL))
				AND out_id = @out_id
			)
			BEGIN
				INSERT INTO #from_product_out
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   cpp.vintage vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #out_table_property cpp
					ON tsp.region_id = cpp.region_id
				WHERE ISNULL(cpp.state_value_id, -1) = IIF(cpp.state_value_id IS NULL, -1, tsp.state_value_id)
					AND ISNULL(cpp.tier_id, -1) = IIF(cpp.tier_id IS NULL, -1, tsp.tier_id)
					AND ISNULL(cpp.technology_id, -1) = IIF(cpp.technology_id IS NULL, -1, tsp.technology_id)
					AND out_id = @out_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #out_table_property 
				WHERE ((technology_id IS NOT NULL AND region_id IS NULL)
					OR (technology_id IS NOT NULL AND region_id IS NULL AND state_value_id IS NOT NULL)
					OR (technology_id IS NOT NULL AND region_id IS NULL AND tier_id IS NOT NULL)
					OR (technology_id IS NOT NULL AND region_id IS NULL AND state_value_id IS NOT NULL AND tier_id IS NOT NULL))
					AND out_id = @out_id
			)
			BEGIN
				INSERT INTO #from_product_out
				SELECT DISTINCT 
					   cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   cpp.vintage vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #out_table_property cpp
					ON cpp.technology_id = tsp.technology_id
				WHERE ISNULL(cpp.state_value_id, -1) = IIF(cpp.state_value_id IS NULL, -1, tsp.state_value_id )
					AND ISNULL(cpp.tier_id, -1) = IIF(cpp.tier_id IS NULL, -1, tsp.tier_id )
					AND out_id = @out_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #out_table_property 
				WHERE state_value_id IS NOT NULL
					AND region_id IS NULL
					AND tier_id IS NULL
					AND technology_id IS NULL
					AND out_id = @out_id
			)
			BEGIN
				INSERT INTO #from_product_out
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   cpp.vintage vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #out_table_property cpp
					ON cpp.state_value_id = tsp.state_value_id
				WHERE out_id = @out_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #out_table_property 
				WHERE state_value_id IS NULL
					AND region_id IS NULL
					AND tier_id IS NOT NULL
					AND technology_id IS NULL
					AND out_id = @out_id
			)
			BEGIN
				INSERT INTO #from_product_out
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   cpp.vintage vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #out_table_property cpp
					ON cpp.tier_id = tsp.tier_id
				WHERE out_id = @out_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #out_table_property 
				WHERE state_value_id IS NOT NULL
					AND region_id IS NULL
					AND tier_id IS NOT NULL
					AND technology_id IS NULL
					AND out_id = @out_id
			)
			BEGIN
				INSERT INTO #from_product_out
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   cpp.vintage vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #out_table_property cpp
					ON cpp.tier_id = tsp.tier_id
						AND cpp.state_value_id = tsp.state_value_id
				WHERE out_id = @out_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #out_table_property 
				WHERE state_value_id IS NULL
					AND region_id IS NOT NULL
					AND tier_id IS NOT NULL
					AND technology_id IS NOT NULL
					AND out_id = @out_id
			)
			BEGIN
				INSERT INTO #from_product_out
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   NULL vintage
				FROM #tmp_state_properties_all tsp
				INNER JOIN #out_table_property cpp
					ON cpp.technology_id = tsp.technology_id
						AND cpp.tier_id = tsp.tier_id
						AND out_id = @out_id
			END
			ELSE IF EXISTS (
				SELECT 1
				FROM #out_table_property 
				WHERE state_value_id IS NULL
					AND region_id IS NULL
					AND tier_id IS NULL
					AND technology_id IS NULL
					AND out_id = @out_id
			)
			BEGIN
				INSERT INTO #from_product_out
				SELECT cpp.source_deal_header_id,
					   tsp.region_id,
					   tsp.state_value_id,
					   tsp.tier_id,
					   tsp.technology_id,
					   NULL vintage
				FROM #tmp_state_properties_all tsp
				OUTER APPLY (
					SELECT source_deal_header_id
					FROM #out_table_property 
					where out_id = @out_id
					GROUP BY source_deal_header_id
				) cpp
				GROUP BY cpp.source_deal_header_id, tsp.region_id, tsp.state_value_id, tsp.tier_id, tsp.technology_id
			END
		FETCH NEXT
		FROM @get_out_info INTO @out_id
		END
		CLOSE @get_out_info
		DEALLOCATE @get_out_info

		CREATE NONCLUSTERED INDEX idx_source_deal_header_id ON #from_product_out(source_deal_header_id)
		CREATE NONCLUSTERED INDEX idx_region_id ON #from_product_out(region_id)
		CREATE NONCLUSTERED INDEX idx_state_value_id ON #from_product_out(state_value_id)
		CREATE NONCLUSTERED INDEX idx_tier_id ON #from_product_out(tier_id)
		CREATE NONCLUSTERED INDEX idx_technology_id ON #from_product_out(technology_id)
	
		IF OBJECT_ID ('tempdb..#from_product') IS NOT NULL
			DROP TABLE #from_product

		CREATE TABLE #from_product (
			source_deal_header_id INT,
			region_id INT,
			state_value_id INT,
			tier_id INT,
			vintage INT
		)

		INSERT INTO #from_product		
		SELECT DISTINCT 
				i.source_deal_header_id,
				i.region_id,
				i.state_value_id,
				i.tier_id,
				i.vintage
		FROM #from_product_in i			
		LEFT JOIN #from_product_out o
			ON i.state_value_id = o.state_value_id
				AND i.tier_id = o.tier_id 
				AND i.technology_id = o.technology_id
				AND i.source_deal_header_id = o.source_deal_header_id 
		WHERE o.state_value_id IS NULL
			AND o.tier_id IS NULL
			AND o.technology_id IS NULL

		
		CREATE NONCLUSTERED INDEX idx_source_deal_header_id ON #from_product(source_deal_header_id)
		CREATE NONCLUSTERED INDEX idx_region_id ON #from_product(region_id)
		CREATE NONCLUSTERED INDEX idx_state_value_id ON #from_product(state_value_id)
		CREATE NONCLUSTERED INDEX idx_tier_id ON #from_product(tier_id)
	END

	----From Deal
	--IF OBJECT_ID ('tempdb..#from_deal') IS NOT NULL
	--	DROP TABLE #from_deal

	--SELECT DISTINCT sdh.source_deal_header_id, 
	--		--sdd.source_deal_detail_id,
	--	   NULL region_id,
	--	   state_value_id,
	--	   tier_value_id tier_id--,
	--	   --sdv.value_id vintage
	--INTO #from_deal
	--FROM #source_deal_header sdh
	----INNER JOIN source_deal_detail sdd
	----	ON sdd.source_deal_header_id = sdh.source_deal_header_id
	----LEFT JOIN static_data_value sdv ON sdv.code = YEAR(sdd.term_start)
	----		AND sdv.type_id = 10092
	--WHERE sdh.state_value_id IS NOT NULL
	--	OR tier_value_id IS NOT NULL

	--CREATE NONCLUSTERED INDEX idx_source_deal_header_id ON #from_deal(source_deal_header_id)
	--CREATE NONCLUSTERED INDEX idx_state_value_id ON #from_deal(state_value_id)
	--CREATE NONCLUSTERED INDEX idx_tier_id ON #from_deal(tier_id)
	
	--From Generator
	IF OBJECT_ID ('tempdb..#from_generator') IS NOT NULL
		DROP TABLE #from_generator

	SELECT sdh.source_deal_header_id,
		   emtd.state_value_id,
		   emtd.tier_id
	INTO #from_generator
	FROM rec_generator rg
	LEFT JOIN eligibility_mapping_template_detail emtd
		ON emtd.template_id = rg.eligibility_mapping_template_id
	INNER JOIN #source_deal_header sdh
		ON rg.generator_id = sdh.generator_id

	CREATE NONCLUSTERED INDEX idx_source_deal_header_id ON #from_generator(source_deal_header_id)
	CREATE NONCLUSTERED INDEX idx_state_value_id ON #from_generator(state_value_id)
	CREATE NONCLUSTERED INDEX idx_tier_id ON #from_generator(tier_id)
	
	IF OBJECT_ID ('tempdb..#final_table') IS NOT NULL
		DROP TABLE #final_table

	CREATE TABLE #final_table (
		source_deal_header_id INT,
		source_deal_detail_id INT,
		term_start DATETIME,
		term_end DATETIME,
		leg INT,
		deal_id NVARCHAR(200) COLLATE DATABASE_DEFAULT,
		region_id INT,
		state_value_id INT,
		tier_value_id INT,
		vintage INT
	)

	INSERT INTO #final_table
	SELECT  DISTINCT
			sdh.source_deal_header_id,
			sdd.source_deal_detail_id,
			sdd.term_start,
			sdd.term_end,
			sdd.leg,
			sdh.deal_id,
			COALESCE(from_certificate.region_id, from_product.region_id) region_id,
			COALESCE(from_certificate.state_value_id, from_product.state_value_id, sdh.state_value_id, from_generator.state_value_id) state_value_id,
			COALESCE(from_certificate.tier_id, from_product.tier_id, sdh.tier_value_id, from_generator.tier_id) tier_id,
			COALESCE(from_certificate.vintage, from_product.vintage, vin.value_id) vintage
	FROM #source_deal_header sdh
	INNER JOIN source_deal_detail sdd
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN static_data_value vin ON vin.code = YEAR(sdd.term_start)
			AND vin.type_id = 10092
	OUTER APPLY (
		SELECT region_id,
				state_value_id,
				tier_id,
				vintage
		FROM #from_certificate
		WHERE source_deal_header_id = sdh.source_deal_header_id
			AND source_deal_detail_id = sdd.source_deal_detail_id
	) from_certificate
	OUTER APPLY (
		SELECT region_id,
				state_value_id,
				tier_id,
				vintage
		FROM #from_product
		WHERE source_deal_header_id = sdh.source_deal_header_id
	) from_product
	--OUTER APPLY (
	--	SELECT region_id,
	--			state_value_id,
	--			tier_id--,
	--			--vintage
	--	FROM #from_deal
	--	WHERE source_deal_header_id = sdh.source_deal_header_id
	--) from_deal	
	OUTER APPLY (
		SELECT state_value_id,
				tier_id
		FROM #from_generator
		WHERE source_deal_header_id = sdh.source_deal_header_id
	) from_generator
	
	CREATE NONCLUSTERED INDEX idx_source_deal_header_id ON #final_table(source_deal_header_id)
	CREATE NONCLUSTERED INDEX idx_region_id ON #final_table(region_id)
	CREATE NONCLUSTERED INDEX idx_state_value_id ON #final_table(state_value_id)
	CREATE NONCLUSTERED INDEX idx_tier_id ON #final_table(tier_value_id)
	
	SET @_sql_string = '
		SELECT DISTINCT 
			   ft.source_deal_header_id,
			   ft.source_deal_detail_id,
			   ft.term_start,
			   ft.term_end,
			   ft.leg,
			   ft.deal_id,
			   gc.gis_cert_date,
			   gc.contract_expiration_date certificate_expiration_date_from,
			   gc.gis_certificate_number_from gis_certificate_number_from,
			   gc.gis_certificate_number_to gis_certificate_number_to,
			   cert_entity.code certification_entity,
			   gc.certificate_number_from_int sequence_from,
			   gc.certificate_number_To_int sequence_to,
			   jurisdiction.code jurisdiction,
			   ft.state_value_id jurisdiction_id,
			   tier_type.code tier_type,
			   ft.tier_value_id tier_id,		   
			   ISNULL(sdv.code, sdv1.code) vintage_year,
			   ISNULL(sdv.value_id, sdv1.value_id) vintage_year_id,
			   NULLIF(''' + ISNULL(@certificate_expiration_date_to, '') + ''', '''') certificate_expiration_date_to,
			   sdh.sub_id,
			   sdh.stra_id,
			   sdh.book_id,
			   sdh.sub_book_id,
			   sdh.sub,
			   sdh.stra,
			   sdh.book,
			   sdh.sub_book	
		INTO ' + @process_table + '
		FROM #final_table ft
		INNER JOIN #source_deal_header sdh
			ON sdh.source_deal_header_id = ft.source_deal_header_id
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = ft.vintage
				AND sdv.type_id = 10092
		LEFT JOIN static_data_value sdv1
			ON sdv1.code = YEAR(ft.term_start)
				AND sdv1.type_id = 10092
		LEFT JOIN #from_certificate gc
			ON gc.source_deal_detail_id = ft.source_deal_detail_id
				AND gc.state_value_id = ft.state_value_id
				AND gc.tier_id = ft.tier_value_id
		LEFT JOIN static_data_value cert_entity
			ON cert_entity.value_id = gc.certification_entity
				AND cert_entity.type_id = 10011
		LEFT JOIN static_data_value jurisdiction
			ON jurisdiction.value_id = ft.state_value_id
				AND jurisdiction.type_id = 10002
		LEFT JOIN static_data_value tier_type
			ON tier_type.value_id = ft.tier_value_id
				AND tier_type.type_id = 15000
		LEFT JOIN static_data_value region
			ON region.value_id = ft.region_id
				AND region.type_id = 11150
		WHERE 1 = 1
	' +
	CASE 
		WHEN @certificate_expiration_date_from IS NOT NULL AND @certificate_expiration_date_to IS NULL THEN ' AND CONVERT(VARCHAR(10), gc.contract_expiration_date, 120) = ''' + CONVERT(VARCHAR(10), @certificate_expiration_date_from, 120) + ''''
		ELSE ''
	END
	+ 
	CASE 
		WHEN @certificate_expiration_date_to IS NOT NULL AND @certificate_expiration_date_from IS NULL THEN ' AND CONVERT(VARCHAR(10), gc.contract_expiration_date, 120) < ''' + CONVERT(VARCHAR(10), @certificate_expiration_date_to, 120) + ''''
		ELSE ''
	END
	+ 
	CASE 
		WHEN @certificate_expiration_date_to IS NOT NULL AND @certificate_expiration_date_from IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), gc.contract_expiration_date, 120) BETWEEN ''' + CONVERT(VARCHAR(10), @certificate_expiration_date_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @certificate_expiration_date_to, 120) + ''''
		ELSE ''
	END
	+ 
	CASE 
		WHEN @vintage_year_id IS NOT NULL THEN ' AND sdv.value_id IN (' + @vintage_year_id + ')'
		ELSE ''
	END
	+ 
	CASE 
		WHEN @tier_id IS NOT NULL THEN ' AND ft.tier_value_id IN (' + @tier_id + ')'
		ELSE ''
	END
	+ 
	CASE 
		WHEN @jurisdiction_id IS NOT NULL THEN ' AND ft.state_value_id IN (' + @jurisdiction_id + ')'
		ELSE ''
	END
	+ 
	CASE 
		WHEN @call_from = 'import' THEN ' AND ft.tier_value_id IS NOT NULL AND ft.state_value_id IS NOT NULL 
			AND jurisdiction.code IS NOT NULL AND tier_type.code IS NOT NULL '
		ELSE ''
	END	

	SET @_sql_string = @_sql_string + ' ORDER BY ft.term_start, ft.term_end'

	EXEC(@_sql_string)

	EXEC ('
		CREATE INDEX IDX_results_sdh_id ON ' + @process_table + ' (source_deal_header_id)
		CREATE NONCLUSTERED INDEX IDX_results_leg ON ' + @process_table + ' (leg)
		CREATE NONCLUSTERED INDEX IDX_results_term_start ON ' + @process_table + ' (term_start)
	')
END
GO

