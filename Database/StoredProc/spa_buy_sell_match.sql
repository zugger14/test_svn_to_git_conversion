IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_buy_sell_match]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_buy_sell_match]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Match deals based on Jurisdiction, Tier, Vintage in deal detail level and return result. Also, include logic to Insert, Update and Delete deal match data

	Parameters : 
	@flag : i - insert, t - select, i with link_id - update, c - 
	@link_id : For matched deals to select or update matched detail
	@xmlValue : Input date from Grid
	@set : 1-Sale, 2-Buy
	@source_deal_header_id : Sale deal header id
	@sell_deal_detail_id : Sale deal detail id
	@source_deal_header_id_from : Buy deal header id
	@source_deal_detail_id_from : Buy deal detail id
	@ignore_source_deal_header_id : Deal ID(s) to be ignored from the selection list
	@effective_date : Deal's effective date to filter data
	@delivery_date_from : Delivery from date to filter data
	@delivery_date_to : Delivery to date to filter data
	@region_id : Region to filter data
	@not_region_id : Not Region to filter data
	@jurisdiction : Jurisdiction to filter data
	@not_jurisdiction : Not Jurisdiction to filter data
	@tier_type : Tier to filter data
	@nottier_type : Not Tier to filter data
	@technology : Technology to filter data
	@not_technology : Not Technology to filter data
	@vintage_year : Vintage to filter data
	@deal_detail_status : Deal's status to filter data
	@description : Match Description to save
	@volume_match : Volume to be matched
	@include_expired_deals : y - Include, n - Exclude
	@show_all_deals : y - Yes, n - No
	@product_classification : Product classification value to filter data
	@process_id : To run the match under same proces id  
	@return_process_table : To return result in the table

**/
CREATE PROCEDURE [dbo].[spa_buy_sell_match]
	@flag CHAR(1),
	@link_id INT = NULL,
	@xmlValue TEXT = NULL,
	@set CHAR(1) = NULL,
	@source_deal_header_id VARCHAR(2000) = NULL,
	@sell_deal_detail_id VARCHAR(2000) = NULL,
	@source_deal_header_id_from VARCHAR(MAX) = NULL,
	@source_deal_detail_id_from VARCHAR(MAX) = NULL,
	@ignore_source_deal_header_id VARCHAR(2000) = NULL,
	@effective_date DATE=NULL,
	@delivery_date_from DATE = NULL,
	@delivery_date_to DATE = NULL,
	@region_id VARCHAR(70)= NULL,
	@not_region_id VARCHAR(70)= NULL,
	@jurisdiction  VARCHAR(MAX) = NULL,
	@not_jurisdiction  VARCHAR(MAX) = NULL,
	@tier_type VARCHAR(MAX) = NULL,
	@nottier_type VARCHAR(MAX) = NULL,
	@technology VARCHAR(MAX) = NULL,
	@not_technology VARCHAR(MAX) = NULL,
	@vintage_year VARCHAR(MAX) = NULL,
	@deal_detail_status VARCHAR(MAX) = NULL,
	@description VARCHAR(500) = NULL,
	@volume_match CHAR(1) = NULL,
	@include_expired_deals CHAR(1) = 'n',
	@show_all_deals CHAR(1) = NULL,
    @product_classification INT = NULL,
	@process_id VARCHAR(70)= NULL,
	@return_process_table VARCHAR(2000) = NULL
AS 

/********Debug Code*********
DECLARE @flag CHAR(1),
		@link_id INT = NULL,
		@xmlValue VARCHAR(MAX) = NULL,
		@set CHAR(1) = NULL,
		@source_deal_header_id VARCHAR(2000) = NULL,
		@sell_deal_detail_id VARCHAR(2000) = NULL,
		@source_deal_header_id_from VARCHAR(2000) = NULL,
		@source_deal_detail_id_from VARCHAR(MAX) = NULL,
		@ignore_source_deal_header_id VARCHAR(2000) = NULL,
		@effective_date DATE=NULL,
		@delivery_date_from DATE = NULL,
		@delivery_date_to DATE = NULL,
		@region_id VARCHAR(70)= NULL,
		@not_region_id VARCHAR(70)= NULL,
		@jurisdiction  VARCHAR(MAX) = NULL,
		@not_jurisdiction  VARCHAR(MAX) = NULL,
		@tier_type VARCHAR(MAX) = NULL,
		@nottier_type VARCHAR(MAX) = NULL,
		@technology VARCHAR(MAX) = NULL,
		@not_technology VARCHAR(MAX) = NULL,
		@vintage_year VARCHAR(MAX) = NULL,
		@deal_detail_status VARCHAR(MAX) = NULL,
		@description VARCHAR(500) = NULL,
		@volume_match CHAR(1) = NULL,
		@include_expired_deals CHAR(1) = 'n',
		@show_all_deals CHAR(1) = NULL,
		@product_classification INT = NULL,
		@process_id VARCHAR(70)= NULL,
		@return_process_table VARCHAR(2000) = NULL

SELECT @flag='g',@source_deal_header_id='224694',@source_deal_header_id_from='224067'

--*************************/
	SET NOCOUNT ON
	
	DECLARE @sql VARCHAR(MAX)
	DECLARE @DESC VARCHAR(500)
	DECLARE @err_no INT
	DECLARE @link_id_from VARCHAR(10)
	DECLARE @link_id_to VARCHAR(10)
	DECLARE @effective_date_from VARCHAR(10)
	DECLARE @effective_date_to VARCHAR(10)
	DECLARE @deal_id VARCHAR(10)
	DECLARE @ref_id VARCHAR(100)
	DECLARE @filter_group1 VARCHAR(10)
	DECLARE @filter_group2 VARCHAR(10)
	DECLARE @filter_group3 VARCHAR(10)
	DECLARE @filter_group4 VARCHAR(10)
	DECLARE @is_mismatch char(1)
	DECLARE @match_status VARCHAR(15)
	DECLARE @assignment_type VARCHAR(15)
	DECLARE @fiscal_start_date DATE
	DECLARE @fiscal_end_date DATE
	DECLARE @counterparty_id VARCHAR(MAX)

	--Matching Logic Variables and Tables--
	SET @link_id = NULLIF(NULLIF(@link_id, ''), '0')

	IF OBJECT_ID(N'tempdb..#matching_detail', N'U') IS NOT NULL
	DROP TABLE #matching_detail

	IF OBJECT_ID(N'tempdb..#matching_detail_t', N'U') IS NOT NULL
	DROP TABLE #matching_detail_t

	IF OBJECT_ID(N'tempdb..#deal_detail', N'U') IS NOT NULL
		DROP TABLE #deal_detail

	IF OBJECT_ID(N'tempdb..#assigned_deals', N'U') IS NOT NULL
		DROP TABLE #assigned_deals

	IF OBJECT_ID(N'tempdb..#tmp_country_codes_deal_match', N'U') IS NOT NULL
		DROP TABLE #tmp_country_codes_deal_match
	
	IF OBJECT_ID(N'tempdb..#tmp_deal_match_grid', N'U') IS NOT NULL
		DROP TABLE #tmp_deal_match_grid

	IF OBJECT_ID(N'tempdb..#tmp_state_codes_deal_match', N'U') IS NOT NULL
		DROP TABLE #tmp_state_codes_deal_match

	IF OBJECT_ID(N'tempdb..#tmp_multiple_jurisdiction', N'U') IS NOT NULL
		DROP TABLE #tmp_multiple_jurisdiction
		
	DECLARE @user VARCHAR(150), 
		@sql_r VARCHAR(8000),
		@sql_u NVARCHAR(4000),  
		@table_name VARCHAR(150), 
		@assign_process_id VARCHAR(100), 
		@link_effective_dt DATE, 
		@compliance_yr INT,
		@new_link_id INT = NULL,
		@sql_stmt VARCHAR(MAX) 
	

	DECLARE @source_deal_id INT,
		@source_detail_id INT, 
		@matched_volume INT,
		@deal_header_id INT, 
		@deal_detail_id INT,
		@remaining_vol INT, 
		@assigned_vol INT, 
		@vintage INT,
		@total_matched_vol INT,
		@total_assigned_vol INT,
		@term VARCHAR(7),
		@match_type CHAR(1),
		@vintage_yr INT,
		@expiration_dt DATE,
		@sequence_from INT,
		@sequence_to INT

	CREATE TABLE #deal_detail (
		id INT IDENTITY(1,1), 
		source_deal_header_id INT, 
		source_deal_detail_id INT, 
		deal_volume INT, 
		remaining_vol INT, 
		matched_volume INT, 
		assigned_vol INT,
		term_start VARCHAR(10) COLLATE DATABASE_DEFAULT,
		expiration_date DATE,
		vintage INT,
		set_id CHAR(1) COLLATE DATABASE_DEFAULT,
		match_type CHAR(1) COLLATE DATABASE_DEFAULT,
		vintage_yr INT,
		expiration_dt DATE,
		sequence_from INT,
		sequence_to INT,
		term DATE,
		leg INT)

	CREATE TABLE #assigned_deals(
		id INT IDENTITY(1,1),
		source_deal_header_id INT, 
		source_deal_detail_id INT, 
		source_deal_header_id_from INT, 
		source_deal_detail_id_from INT, 
		assigned_vol INT,
		state_value_id INT,
		tier_value_id INT,
		vintage_yr INT,
		expiration_dt DATE,
		sequence_from INT,
		sequence_to INT)
	--END--

	CREATE TABLE #tmp_multiple_jurisdiction(
		sell_header_id INT,
		sell_deal_detail_id INT, 
		sell_reference_id VARCHAR(500) COLLATE DATABASE_DEFAULT,
		buy_header_id INT,
		buy_deal_detail_id INT, 
		buy_reference_id VARCHAR(500) COLLATE DATABASE_DEFAULT,
		state_value_id INT, 
		jurisdiction VARCHAR(500) COLLATE DATABASE_DEFAULT,
		tier_value_id INT,
		tier VARCHAR(500) COLLATE DATABASE_DEFAULT,
		leg INT,
		process_id VARCHAR(150) COLLATE DATABASE_DEFAULT,
		sequence_from INT,
		sequence_to INT
		)

	IF NULLIF(@process_id, '') IS NULL
	BEGIN
		SET @process_id = REPLACE(NEWID(), '-', '_')
	END
	
	DECLARE @DealMatchTable VARCHAR(150), @process_table VARCHAR(500), @user_name VARCHAR(100), 
		@DealsProductInfo VARCHAR(150), @grid_process_table VARCHAR(150), @tmpMatchAllRecs VARCHAR(150)

	SET @user_name = dbo.FNADBUser()
	SET @DealMatchTable = dbo.FNAProcessTableName('DealMatchTable', @user_name, @process_id)
	SET @DealsProductInfo = dbo.FNAProcessTableName('DealsProductInfo', @user_name, @process_id)
	SET @process_table = 'adiha_process.dbo.alert_deal_match_' + @process_id + '_adm'
	SET @grid_process_table = dbo.FNAProcessTableName('GridProcessTable', @user_name, @process_id)
	SET @tmpMatchAllRecs = dbo.FNAProcessTableName('tmpMatchAllRecs', @user_name, @process_id)
	
	IF @flag = 'i' OR @flag = 'j' --Common logic stated here to avoid code duplication
	BEGIN
		--START LOGIC--
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue
		SELECT source_deal_header_id, 
			NULLIF(source_deal_detail_id,0) AS source_deal_detail_id,
			set_id AS set_id, 
			matched AS matched_volume,
			NULLIF(state_value_id, 0) AS state_value_id,
			NULLIF(tier_value_id, 0) AS tier_value_id,
			NULLIF(vintage_year, 0) AS vintage_year, 
			NULLIF(expiration_date, '1900-01-01') AS expiration_date,
			NULLIF(sequence_from, 0) AS sequence_from,
			NULLIF(sequence_to, 0) AS sequence_to,
			NULLIF(actual_volume, 0) AS actual_volume,
			NULLIF(remaining, 0) AS remaining
		INTO #matching_detail
		FROM OPENXML(@idoc, 'Root/Grid/GridRow', 3)
		WITH (
			source_deal_header_id INT '@source_deal_header_id',
			source_deal_detail_id INT '@source_deal_detail_id',
			[matched] NUMERIC(18,12) '@matched',
			set_id INT '@set_id',
			state_value_id INT '@state_value_id',
			tier_value_id INT '@tier_value_id',
			vintage_year INT '@vintage_year',
			expiration_date DATE '@expiration_date',
			sequence_from INT '@sequence_from',
			sequence_to INT '@sequence_to',
			actual_volume NUMERIC(18,12) '@actual_volume',
			remaining NUMERIC(18,12) '@remaining')

		EXEC sp_xml_removedocument @idoc

		IF NOT EXISTS(SELECT 1 FROM #matching_detail WHERE set_id = 2)
		BEGIN
			IF OBJECT_ID(@tmpMatchAllRecs) IS NOT NULL
			SET @sql_u = '
			INSERT INTO #matching_detail
			SELECT DISTINCT source_deal_header_id, 
				source_deal_detail_id, 
				2 AS set_id, 
				actual_volume AS matched_volume,
				NULL AS state_value_id,
				NULL AS tier_value_id,
				vintage_year,
				expiration_date,
				sequence_from,
				sequence_to,
				actual_volume,
				0 AS remaining
				FROM ' + @tmpMatchAllRecs
			
			EXEC(@sql_u)
		END

		INSERT INTO #matching_detail
		SELECT md.source_deal_header_id,
			sdd.source_deal_detail_id,
			md.set_id,
			md.matched_volume,
			md.state_value_id,
			md.tier_value_id,
			md.vintage_year,
			md.expiration_date,
			md.sequence_from,
			md.sequence_to,
			md.actual_volume,
			md.remaining
		FROM #matching_detail md
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = md.source_deal_header_id
		WHERE NOT EXISTS(SELECT 1 
						FROM #matching_detail md1 
						WHERE md1.source_deal_header_id = md.source_deal_header_id 
						AND md1.source_deal_detail_id > 0)
		AND md.source_deal_detail_id IS NULL

		DELETE md
		FROM #matching_detail md
		WHERE md.source_deal_detail_id IS NULL
		
		IF OBJECT_ID ('tempdb..#temp_fiscal_year_detail') IS NOT NULL
			DROP TABLE #temp_fiscal_year_detail

		CREATE TABLE #temp_fiscal_year_detail (
			state_value_id INT,
			fiscal_start_date DATE,
			fiscal_end_date DATE
		)

		IF OBJECT_ID(@DealsProductInfo) IS NOT NULL
		BEGIN
			EXEC('
				INSERT INTO #temp_fiscal_year_detail
				SELECT DISTINCT state_value_id, [start], [end]
				FROM ' + @DealsProductInfo
			)

			--EXEC('
			--DELETE md
			--FROM #matching_detail md
			--LEFT JOIN ' + @DealsProductInfo + ' tfyd ON tfyd.buy_detail_id = md.source_deal_detail_id
			--WHERE tfyd.buy_detail_id IS NULL AND md.set_id = 2
			--AND EXISTS(SELECT 1 FROM ' + @DealsProductInfo + ' tfyd WHERE tfyd.buy_deal_id = md.source_deal_header_id)')
		END

		SET @sql_u = '
		INSERT INTO #deal_detail
		SELECT DISTINCT sdd.source_deal_header_id, 
			sdd.source_deal_detail_id, ROUND(' +
			CASE WHEN @flag = 'i' THEN ' md.matched_volume' ELSE ' md.actual_volume' END + ',0),ROUND(' +
			CASE WHEN @flag = 'i' THEN ' md.matched_volume' ELSE ' md.actual_volume' END + ',0), 
			md.matched_volume,
			NULL,
			CASE sdh.match_type
				WHEN ''m'' THEN CONVERT(VARCHAR(7), sdd.term_start, 126)
				WHEN ''y'' THEN CONVERT(VARCHAR(4), sdd.term_start, 126)
				ELSE CONVERT(VARCHAR(10), sdd.term_start, 126) END,
			sdd.contract_expiration_date,
			sdd.vintage, 
			md.set_id,
			sdh.match_type,
			md.vintage_year,
			md.expiration_date,
			md.sequence_from,
			md.sequence_to,
			sdd.term_start,
			sdd.leg
		FROM source_deal_header sdh
		INNER JOIN #matching_detail md ON md.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = md.source_deal_detail_id
		OUTER APPLY(SELECT ISNULL(SUM(assigned_vol), 0) AS [matched] 
					FROM matching_header_detail_info mhdi 
					WHERE mhdi.source_deal_detail_id = sdd.source_deal_detail_id) m'

		EXEC(@sql_u)
		
		DELETE FROM #deal_detail WHERE deal_volume <= 0
		
		SELECT TOP 1 @total_matched_vol = SUM(deal_volume) FROM #deal_detail WHERE set_id = '1'
		
		DECLARE cur_select_deal_detail CURSOR LOCAL FOR
		SELECT source_deal_header_id,
			source_deal_detail_id, 
			deal_volume, 
			vintage,
			term_start,
			match_type
		FROM #deal_detail 
		WHERE set_id = '1'
		ORDER BY expiration_date
		OPEN cur_select_deal_detail; 

		FETCH NEXT FROM cur_select_deal_detail INTO @source_deal_id, @source_detail_id, @matched_volume, @vintage, @term, @match_type
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			WHILE @matched_volume > 0
			BEGIN
				SELECT @remaining_vol = 0, @assigned_vol = 0
				
				SELECT TOP 1 
					@deal_header_id = source_deal_header_id,
					@deal_detail_id = source_deal_detail_id, 
					@remaining_vol = remaining_vol,
					@vintage_yr = vintage_yr,
					@expiration_dt = expiration_dt,
					@sequence_from = sequence_from, 
					@sequence_to = sequence_to
				FROM #deal_detail
				WHERE remaining_vol > 0 
					AND IIF(@match_type = 'm', LEFT(@term, 7), '1900-01-01') = IIF(@match_type = 'm', LEFT(term_start, 7), '1900-01-01')
					--AND IIF(@match_type = 'y', term_start, '1900-01-01') >= IIF(@match_type = 'y', @fiscal_start_date, '1900-01-01')
					--AND IIF(@match_type = 'y', term_end, '1900-01-01') <= IIF(@match_type = 'y', @fiscal_end_date, '1900-01-01')
					AND set_id = '2' 
				ORDER BY expiration_dt, 
					source_deal_header_id, 
					term_start, 
					sequence_from ASC
				
				IF @deal_header_id IS NULL OR @remaining_vol = 0
				SET @matched_volume = 0

				IF @matched_volume > 0
				BEGIN
					SELECT @assigned_vol = CASE WHEN @matched_volume >= @remaining_vol THEN @remaining_vol ELSE @matched_volume END

					SELECT @total_assigned_vol = ISNULL(SUM(assigned_vol), 0) FROM #assigned_deals
					SELECT @assigned_vol = CASE WHEN @total_matched_vol >= (@total_assigned_vol+@assigned_vol) THEN 
												@assigned_vol 
											ELSE @total_matched_vol END

					SET @matched_volume = (@matched_volume-@assigned_vol)

					UPDATE #deal_detail SET 
						remaining_vol = (remaining_vol - @assigned_vol), 
						assigned_vol = ISNULL(assigned_vol, 0)+@assigned_vol
					WHERE source_deal_detail_id = @deal_detail_id 
					AND ISNULL(sequence_from, -1) = ISNULL(@sequence_from, -1)
					AND set_id = '2'

					IF (@sequence_to-@sequence_from)+1 > @assigned_vol AND @sequence_from IS NOT NULL
						SET @sequence_to = (@sequence_from+@assigned_vol)-1

					IF (@sequence_from+@assigned_vol) < @sequence_to
						SET @sequence_to = (@sequence_from+@assigned_vol)-1

					INSERT INTO #assigned_deals(
						source_deal_header_id,
						source_deal_detail_id,
						source_deal_header_id_from,
						source_deal_detail_id_from,
						assigned_vol,
						vintage_yr,
						expiration_dt,
						sequence_from,
						sequence_to)
					SELECT  
						@source_deal_id, 
						@source_detail_id, 
						@deal_header_id, 
						@deal_detail_id, 
						@assigned_vol,
						@vintage_yr,
						@expiration_dt,
						@sequence_from,
						@sequence_to

					SELECT @total_assigned_vol = SUM(ISNULL(assigned_vol, 0)) FROM #assigned_deals

					IF (@total_matched_vol <= @total_assigned_vol)
						BREAK
				END
		 
			END

			FETCH NEXT FROM cur_select_deal_detail INTO @source_deal_id, @source_detail_id, @matched_volume, @vintage, @term, @match_type
		END;
		CLOSE cur_select_deal_detail;
		DEALLOCATE cur_select_deal_detail;

		IF NOT EXISTS(SELECT TOP 1 1 FROM #assigned_deals)
		BEGIN
			IF OBJECT_ID(N'tempdb..#tmp_calc_status_from_auto_match', N'U') IS NOT NULL
				BEGIN
					INSERT INTO #tmp_calc_status_from_auto_match
					SELECT 
					'Error' AS ErrorCode
					, 'buysell_match' AS Module
					, 'spa_buy_sell_match' AS Area
					, 'Warning' AS [Status]
					, 'Product details of deals do not match. Please check the deals.' AS [Message]
					, '' AS Recommendation
				END
			ELSE
			BEGIN
				SELECT 
				'Error' AS ErrorCode
				, 'buysell_match' AS Module
				, 'spa_buy_sell_match' AS Area
				, 'Warning' AS [Status]
				, 'Product details of deals do not match. Please check the deals.' AS [Message]
				, '' AS Recommendation
			END
			RETURN
		END

		IF @flag = 'j'
		BEGIN
			SET @sql_r = '
			SELECT
				ad.source_deal_header_id,
				ad.source_deal_detail_id,
				ad.source_deal_header_id_from,
				ad.source_deal_detail_id_from,
				ad.assigned_vol,
				ad.state_value_id,
				ad.tier_value_id,
				ad.vintage_yr,
				ad.expiration_dt,
				ad.sequence_from,
				ad.sequence_to,
				(md.actual_volume-ad.assigned_vol) remaining,
				md.actual_volume,
				''' + @process_id + ''' AS process_id
			INTO ' + @DealMatchTable + '
			FROM #assigned_deals ad
			INNER JOIN #matching_detail md ON md.source_deal_detail_id = ad.source_deal_detail_id_from
				AND ISNULL(md.sequence_from, -1) = ISNULL(ad.sequence_from, -1)'

			EXEC(@sql_r)

			--Set all NULL it is not required 
			SELECT @process_id AS process_id
		END

		IF OBJECT_ID(@DealsProductInfo) IS NOT NULL AND @flag = 'i' 
			AND NOT EXISTS(SELECT 1 FROM #matching_detail WHERE state_value_id IS NOT NULL AND set_id = 2)
		BEGIN
			--SET @sql = '
			--	;WITH product AS (
			--		SELECT DISTINCT 
			--			sdh.source_deal_header_id AS sell_header_id,
			--			sdh.source_deal_detail_id sell_deal_detail_id, 
			--			sdh.source_deal_header_id_from AS buy_header_id,
			--			sdh.source_deal_detail_id_from buy_deal_detail_id, 
			--			gc.state_value_id, 
			--			gc.tier_type AS tier_value_id
			--		FROM #assigned_deals sdh 
			--		INNER JOIN gis_certificate gc ON gc.source_deal_header_id = sdh.source_deal_detail_id_from
			--		INNER JOIN ' + @DealsProductInfo + ' sl ON sl.source_deal_detail_id = sdh.source_deal_detail_id
			--		WHERE ISNULL(sl.state_value_id, gc.state_value_id) = gc.state_value_id
			--			AND ISNULL(sl.tier_value_id, gc.tier_type) = gc.tier_type
			--	)
			--	INSERT INTO #tmp_multiple_jurisdiction
			--	SELECT DISTINCT 
			--		p.sell_header_id,
			--		p.sell_deal_detail_id, 
			--		sdh_s.deal_id AS sell_reference_id,
			--		p.buy_header_id,
			--		p.buy_deal_detail_id, 
			--		sdh_b.deal_id AS buy_reference_id,
			--		p.state_value_id, 
			--		jur.code,
			--		p.tier_value_id, 
			--		tier.code,
			--		''' + @process_id + ''' AS process_id
			--	FROM product p
			--	LEFT JOIN source_deal_header sdh_s ON sdh_s.source_deal_header_id = p.sell_header_id
			--	LEFT JOIN source_deal_header sdh_b ON sdh_b.source_deal_header_id = p.buy_header_id
			--	LEFT JOIN static_data_value jur ON jur.value_id = p.state_value_id
			--		AND jur.type_id = 10002
			--	LEFT JOIN static_data_value tier ON tier.value_id = p.tier_value_id
			--		AND tier.type_id = 15000
			--	WHERE EXISTS(SELECT 1 FROM product p1 WHERE p1.buy_deal_detail_id = p.buy_deal_detail_id 
			--	GROUP BY buy_deal_detail_id HAVING COUNT(*) > 1)'

			----PRINT(@sql)
			--EXEC(@sql)
			SET @sql = '
			DELETE p1
			FROM ' + @DealsProductInfo + ' p1
			LEFT JOIN #matching_detail md ON md.source_deal_detail_id = p1.buy_detail_id
			INNER JOIN source_deal_detail sdd_b ON sdd_b.source_deal_detail_id = md.source_deal_detail_id
			LEFT JOIN #temp_fiscal_year_detail fyd ON fyd.state_value_id = p1.state_value_id
				AND sdd_b.term_start >= fyd.fiscal_start_date
				AND sdd_b.term_end <= fyd.fiscal_end_date
			WHERE fyd.state_value_id IS NULL
				AND p1.match_type = ''y''
			
			INSERT INTO #tmp_multiple_jurisdiction
			SELECT DISTINCT 
				p.source_deal_header_id AS sell_header_id,
				p.source_deal_detail_id AS sell_deal_detail_id, 
				sdh_s.deal_id AS sell_reference_id,
				p.buy_deal_id AS buy_header_id,
				p.buy_detail_id AS buy_deal_detail_id, 
				sdh_b.deal_id AS buy_reference_id,
				p.state_value_id, 
				jur.code,
				p.tier_value_id, 
				tier.code,
				sdd.leg,
				''' + @process_id + ''' AS process_id,
				p.sequence_from,
				p.sequence_to
			FROM ' + @DealsProductInfo + ' p
			INNER JOIN #assigned_deals sdh ON sdh.source_deal_detail_id_from = p.buy_detail_id
				AND sdh.source_deal_detail_id = p.source_deal_detail_id
				AND ISNULL(sdh.sequence_from, -1) = ISNULL(p.sequence_from, -1)
			LEFT JOIN source_deal_header sdh_s ON sdh_s.source_deal_header_id = p.source_deal_header_id
			LEFT JOIN source_deal_header sdh_b ON sdh_b.source_deal_header_id = p.buy_deal_id
			LEFT JOIN static_data_value jur ON jur.value_id = p.state_value_id
				AND jur.type_id = 10002
			LEFT JOIN static_data_value tier ON tier.value_id = p.tier_value_id
				AND tier.type_id = 15000
			LEFT JOIN source_deal_detail sdd on sdd.source_deal_detail_id = p.buy_detail_id
			WHERE EXISTS(SELECT 1 FROM ' + @DealsProductInfo + ' p1 
						WHERE p1.buy_detail_id = p.buy_detail_id 
							AND p1.source_deal_detail_id = p.source_deal_detail_id
						GROUP BY buy_detail_id, start, sequence_from HAVING COUNT(*) > 1) '

			--PRINT (@sql)
			EXEC (@sql)
		 
			DELETE tmj
			FROM #tmp_multiple_jurisdiction tmj
			INNER JOIN matching_header_detail_info mhdi ON tmj.buy_deal_detail_id = mhdi.source_deal_detail_id_from
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mhdi.source_deal_detail_id_from
			WHERE mhdi.link_id = @link_id AND sdd.volume_left < 1

			--IF EXISTS(SELECT TOP 1 1 FROM #tmp_multiple_jurisdiction) --Commented for not displaying multiple common product, please uncomment it if required in future
			--BEGIN
			--	SELECT tmj.*,dbo.FNADateFormat(sdd.term_start) term_start ,dbo.FNADateFormat(sdd.term_end) term_end
			--	FROM #tmp_multiple_jurisdiction tmj
			--	INNER JOIN source_deal_detail sdd 
			--	ON sdd.source_deal_detail_id = tmj.buy_deal_detail_id
			--	RETURN --To return product for selection before saving detail
			--END
		END 
	END

	IF @flag = 's'
	BEGIN 
		
		DECLARE @idoc3 INT

		EXEC sp_xml_preparedocument @idoc3 OUTPUT, @xmlValue
			
		IF OBJECT_ID('tempdb..#temp_deal_match_filter') IS NOT NULL
			DROP TABLE #temp_deal_match_filter
		
		SELECT	
				NULLIF(link_id_from, '')					[link_id_from],
				NULLIF(link_id_to, '')						[link_id_to],
				NULLIF(effective_date_from, '')				[effective_date_from],
				NULLIF(effective_date_to, '')				[effective_date_to],
				NULLIF(deal_id, '')							[deal_id],
				NULLIF(ref_id, '')							[ref_id],
				NULLIF(filter_group1, '')					[filter_group1],
				NULLIF(filter_group2, '')					[filter_group2],
				NULLIF(filter_group3, '')					[filter_group3],
				NULLIF(filter_group4, '')					[filter_group4],
				NULLIF(is_mismatch, '')						[is_mismatch],
				NULLIF(match_status, '')					[match_status],
				NULLIF(assignment_type, '')					[assignment_type],
				NULLIF(counterparty_id, '')					[counterparty_id]
		INTO #temp_deal_match_filter
		FROM OPENXML(@idoc3, '/Root/FormXML', 1)
		WITH (
			link_id_from				VARCHAR(10),
			link_id_to					VARCHAR(10),
			[effective_date_from]		VARCHAR(10),
			[effective_date_to]			VARCHAR(10),
			[deal_id]					VARCHAR(10),
			[ref_id]					VARCHAR(100),
			[filter_group1]				VARCHAR(10),
			[filter_group2]				VARCHAR(10),
			[filter_group3]				VARCHAR(10),
			[filter_group4]				VARCHAR(10),
			[is_mismatch]				CHAR(1),
			[match_status]				VARCHAR(15),
			[assignment_type]			VARCHAR(15),
			[counterparty_id]			VARCHAR(MAX)
		)

			SELECT 
				@link_id_from = link_id_from,
				@link_id_to = link_id_to,
				@effective_date_from = effective_date_from,
				@effective_date_to = effective_date_to,
				@deal_id = deal_id,
				@ref_id = ref_id,
				@filter_group1 = filter_group1,
				@filter_group2 = filter_group2,
				@filter_group3 = filter_group3,
				@filter_group4 = filter_group4,
				@is_mismatch = is_mismatch,
				@match_status = match_status,
				@assignment_type = assignment_type,
				@counterparty_id = counterparty_id
			FROM #temp_deal_match_filter

			--select top 1 * from matching_detail
			--select top 1 * from source_deal_header
			--select top 1 * from matching_header
		SET @sql = '
					SELECT source_deal_header_id, 
						MAX(pnl_as_of_date) pnl_as_of_date 
					INTO #temp_max_date_pnl2 
					FROM source_deal_pnl 
					GROUP BY source_deal_header_id

					CREATE NONCLUSTERED INDEX idx_temp_max_date_pnl_pnl_as_of_date2 ON #temp_max_date_pnl2 (pnl_as_of_date)
					CREATE NONCLUSTERED INDEX idx_temp_max_date_pnl_source_deal_header_id2 ON #temp_max_date_pnl2 (source_deal_header_id)

					SELECT 
						mh.link_id,
						isnull(nullif(mh.link_description,''''),mh.link_id) [description],
						dbo.FNADateFormat(mh.link_effective_date) [mh.effective_date],
						mh.group1,
						mh.group2,
						mh.group3,
						mh.group4,
						MAX(mh.total_matched_volume) total_matched_volume,
						[dbo].[FNARemoveTrailingZeroes](CASE WHEN CAST(MAX(s1.term_start) AS DATETIME) > CAST(MAX(s2.term_start) AS DATETIME) THEN MAX(s2.price - s1.price) ELSE MAX(s1.price - s2.price) END) price,
						MAX(scu.currency_id) currency_id
						, MAX(sdv_ms.code) AS match_status
						, MAX(sdv_at.code) AS assignment_type
						' +	CASE WHEN @return_process_table IS NOT NULL THEN ' INTO ' + @return_process_table ELSE '' END +
					' from matching_header mh
					inner join matching_detail md ON mh.link_id = md.link_id ' + CASE WHEN @deal_id is not null then ' AND md.source_deal_header_id = ' + @deal_id ELSE '' END + '
					inner join source_deal_header sdh on sdh.source_deal_header_id = md.source_deal_header_id ' + CASE WHEN @ref_id is not null then ' AND sdh.deal_id like ''%' + @ref_id + '%'''  ELSE '' END + '
					outer apply
					(
						SELECT MAX(sdh2.entire_term_start) max_term_start, MIN(sdh2.entire_term_start) min_term_start, MAX(deal_volume_uom_id) deal_volume_uom_id
						FROM matching_detail md2
						inner join source_deal_header sdh2 on sdh2.source_deal_header_id = md2.source_deal_header_id 
						left join source_deal_detail sdd2 on sdd2.source_deal_header_id = md2.source_deal_header_id
	
						WHERE md2.link_id = mh.link_id
					) sdh_min_max					
					outer apply
					(
						SELECT MAX(sdh2.entire_term_start) term_start,
								MAX(sdd2.fixed_price_currency_id) fixed_price_currency_id,
								AVG(ABS(ISNULL(sdd2.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))))) [price]
							FROM matching_detail md02
							inner join source_deal_header sdh2 on sdh2.source_deal_header_id = md02.source_deal_header_id 
							OUTER APPLY (
							SELECT TOP(1) 
										sdd.fixed_price,
										sdd.fixed_price_currency_id
								FROM source_deal_detail sdd 
								WHERE sdd.leg = 1 and sdd.source_deal_header_id = md02.source_deal_header_id
								order by sdd.term_start
							) sdd2 
							LEFT JOIN (
								SELECT sds.source_deal_header_id, 
										sum(settlement_amount) settlement_amount,
										SUM(volume) sds_volume
								FROM source_deal_settlement sds 
								GROUP BY sds.source_deal_header_id
							) ds ON ds.source_deal_header_id = md02.source_deal_header_id
							LEFT JOIN (
							SELECT sdp.source_deal_header_id, 
									sum(und_pnl_set) und_pnl_set,
									SUM(deal_volume) dp_volume
							FROM source_deal_pnl sdp 
							INNER JOIN #temp_max_date_pnl2 tmpnl 
								ON tmpnl.pnl_as_of_date = sdp.pnl_as_of_date
								AND tmpnl.source_deal_header_id = sdp.source_deal_header_id
									GROUP BY sdp.source_deal_header_id
							) dp ON dp.source_deal_header_id = md02.source_deal_header_id
							
							WHERE md02.link_id = mh.link_id AND md02.[set] = ''2''
							GROUP BY md02.[set]
							
					) s1

					outer apply
					(
						SELECT MAX(sdh2.entire_term_start) term_start,
								MAX(sdd2.fixed_price_currency_id) fixed_price_currency_id,
								AVG(ABS(ISNULL(sdd2.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))))) [price]
						FROM matching_detail md02
						inner join source_deal_header sdh2 on sdh2.source_deal_header_id = md02.source_deal_header_id 
						OUTER APPLY (
							SELECT TOP(1) 
									sdd.fixed_price,
									sdd.fixed_price_currency_id
							FROM source_deal_detail sdd 
							WHERE sdd.leg = 1 and sdd.source_deal_header_id = md02.source_deal_header_id
							ORDER BY sdd.term_start
						) sdd2 
						LEFT JOIN (
							SELECT sds.source_deal_header_id, 
									sum(settlement_amount) settlement_amount,
									SUM(volume) sds_volume
							FROM source_deal_settlement sds 
							GROUP BY sds.source_deal_header_id
						) ds ON ds.source_deal_header_id = md02.source_deal_header_id
						LEFT JOIN (
							SELECT sdp.source_deal_header_id, 
									sum(und_pnl_set) und_pnl_set,
									SUM(deal_volume) dp_volume
							FROM source_deal_pnl sdp 
							INNER JOIN #temp_max_date_pnl2 tmpnl ON tmpnl.pnl_as_of_date = sdp.pnl_as_of_date
								AND tmpnl.source_deal_header_id = sdp.source_deal_header_id
							GROUP BY sdp.source_deal_header_id ) dp ON dp.source_deal_header_id = md02.source_deal_header_id
							
						WHERE md02.link_id = mh.link_id AND md02.[set] = ''1''
						GROUP BY md02.[set] ) s2
					LEFT JOIN source_currency scu ON scu.source_currency_id = ISNULL(s1.fixed_price_currency_id,s1.fixed_price_currency_id)
					LEFT JOIN static_data_value sdv_ms ON sdv_ms.value_id = mh.match_status
					LEFT JOIN static_data_value sdv_at ON sdv_at.value_id = mh.assignment_type
					WHERE 1 = 1
						AND EXISTS(SELECT 1 FROM matching_header_detail_info mhdi WHERE mhdi.link_id = md.link_id) '
		if @link_id_from is not null					
			SET @sql += ' AND mh.link_id >= ' + @link_id_from
		if @link_id_to is not null					
			SET @sql += ' AND mh.link_id <= ' + @link_id_to
		if @effective_date_from is not null					
			SET @sql += ' AND CAST(mh.link_effective_date AS DATE) >= ''' + @effective_date_from + ''''
		if @effective_date_to is not null					
			SET @sql += ' AND CAST(mh.link_effective_date AS DATE) <= ''' + @effective_date_to + ''''
		IF @match_status IS NOT NULL 
			SET @sql += ' AND mh.match_status = ' + @match_status + ''
		if @is_mismatch = 'y'
			SET @sql += ' and sdh_min_max.max_term_start <> sdh_min_max.min_term_start '
		IF @counterparty_id IS NOT NULL
			SET @sql += ' and sdh.counterparty_id IN(' + @counterparty_id + ')'
		IF @assignment_type IS NOT NULL 
			SET @sql += ' AND mh.assignment_type = ' + @assignment_type
			
		
		
		SET @sql += '
			GROUP BY 
				mh.link_id,
				mh.link_description,
				mh.link_effective_date,
				mh.group1,
				mh.group2,
				mh.group3,
				mh.group4,
				mh.update_ts,mh.create_ts
			ORDER BY mh.link_id DESC'
		
		EXEC(@sql)
	END

	ELSE IF @flag = 'a'
	BEGIN 
		SELECT 
			link_id,
			isnull(nullif(link_description,''),link_id) [description],
			link_effective_date [effective_date],
			assignment_type,
			group1,
			group2,
			group3,
			group4,
			match_status
		from matching_header
		WHERE link_id = @link_id
	END

	ELSE IF @flag IN ('g', 'm', 'c')
	BEGIN 
		DECLARE @sale_volume_to_match INT, @auto_match_flag CHAR(1) = 'g', @ps_multiplier FLOAT
		
		IF @flag = 'c'
		BEGIN
			SET @auto_match_flag = 'c' 
			SET @flag = 'g'
		END

		CREATE TABLE #tmp_deal_match_grid (grid_process_table VARCHAR(100) COLLATE DATABASE_DEFAULT)

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue

		DECLARE @sdh_sub_book_ids VARCHAR(MAX),
			@sdh_term_start VARCHAR(40),
			@sdh_term_end VARCHAR(40),
			@sdh_counterparty_id VARCHAR(MAX),
			@sdh_deal_date_from VARCHAR(40),
			@sdh_deal_date_to VARCHAR(40),
			@sdh_create_ts_from VARCHAR(40),
			@sdh_create_ts_to VARCHAR(40),
			@sdh_buy_sell_id VARCHAR(10),
			@sdh_deal_id VARCHAR(1000),
			@sdh_generator_id VARCHAR(5000),
			@sdh_deal_locked VARCHAR(100),
			@sdh_filter_mode VARCHAR(1),
			@leg  VARCHAR(1)	
		SELECT @sdh_sub_book_ids = NULLIF(sub_book_ids, ''),
			@sdh_term_start = NULLIF(term_start, ''),
			@sdh_term_end = NULLIF(term_end, ''),
			@sdh_counterparty_id = NULLIF(counterparty_id, ''),
			@sdh_deal_date_from = NULLIF(deal_date_from, ''),
			@sdh_deal_date_to = NULLIF(deal_date_to, ''),
			@sdh_create_ts_from = NULLIF(create_ts_from, ''),
			@sdh_create_ts_to = NULLIF(create_ts_to, ''),
			@sdh_buy_sell_id = NULLIF(buy_sell_id, ''),
			@sdh_deal_id = NULLIF(deal_id, ''),
			@sdh_generator_id = NULLIF(generator_id, ''),
			@sdh_deal_locked = NULLIF(deal_locked, ''),
			@sdh_filter_mode = NULLIF(filter_mode, ''),
			@leg = NULLIF(leg,'')
		FROM OPENXML (@idoc, '/Root/FormXML', 2)
		WITH(
			sub_book_ids				VARCHAR(MAX)	'@sub_book_ids',
			term_start					VARCHAR(40)		'@term_start',
			term_end					VARCHAR(40)		'@term_end',
			counterparty_id				VARCHAR(MAX)	'@counterparty_id',
			deal_date_from				VARCHAR(40)		'@deal_date_from',
			deal_date_to				VARCHAR(40)		'@deal_date_to',
			create_ts_from				VARCHAR(40)		'@create_ts_from',
			create_ts_to				VARCHAR(40)		'@create_ts_to',
			buy_sell_id					VARCHAR(1000)	'@buy_sell_id',
			deal_id						VARCHAR(50)		'@deal_id',
			generator_id				VARCHAR(1000)	'@generator_id',
			deal_locked					VARCHAR(100)	'@deal_locked',
			filter_mode					VARCHAR(100)	'@filter_mode',
			leg							VARCHAR(100)	'@leg'
		)
		
		DECLARE @exec_sql_sdh VARCHAR(MAX)

		IF @sdh_generator_id IS NULL AND @auto_match_flag = 'c'
		BEGIN
			SELECT @sdh_generator_id = COALESCE(@sdh_generator_id + ',', '') + CAST(udgm.generator_id AS VARCHAR)
			FROM udt_deal_generator_mapping udgm
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) t ON t.item = udgm.source_deal_header_id
			GROUP BY udgm.generator_id
			
			IF @sdh_generator_id IS NOT NULL
			SELECT @ps_multiplier = ISNULL(multiplier, 1)
			FROM dbo.SplitCommaSeperatedValues(@source_deal_header_id) t 
			LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = t.item
		END

		IF OBJECT_ID('tempdb..#grid_process_table') IS NOT NULL
			DROP TABLE #grid_process_table

		CREATE TABLE #grid_process_table (id INT, detail_id INT, deal_id VARCHAR(4000) COLLATE DATABASE_DEFAULT, deal_date DATETIME, counterparty VARCHAR(4000) COLLATE DATABASE_DEFAULT, deal_price VARCHAR(100) COLLATE DATABASE_DEFAULT, leg int, volume_left FLOAT)
		
		SET @exec_sql_sdh = 'INSERT INTO #grid_process_table
		SELECT DISTINCT sdh.source_deal_header_id AS id,
			sdd.source_deal_detail_id,
			sdh.deal_id,
			sdh.deal_date,
			sc.counterparty_name [counterparty],
			NULL deal_price,
			sdd.leg,
			sdd.deal_volume*' + CAST(ISNULL(@ps_multiplier, 1) AS VARCHAR) + ' AS volume_left
		FROM source_deal_header sdh 
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id ' +
		CASE WHEN @flag = 'm' THEN 
		'INNER JOIN #non_expired_deals ned ON ned.source_deal_header_id = sdh.source_deal_header_id ' ELSE '' END + '
		WHERE 1 = 1
		AND sdh.is_environmental = ''y'' ' +
		CASE WHEN @sdh_counterparty_id IS NOT NULL THEN ' AND sc.source_counterparty_id IN (' + @sdh_counterparty_id + ')' ELSE '' END +
		CASE WHEN @sdh_generator_id IS NOT NULL THEN ' AND sdh.generator_id IN (' + @sdh_generator_id + ')' ELSE '' END +
		CASE WHEN @sdh_buy_sell_id IS NOT NULL THEN ' AND sdh.header_buy_sell_flag = ''' + @sdh_buy_sell_id + '''' ELSE '' END +
		CASE WHEN @sdh_deal_locked IS NOT NULL THEN ' AND sdh.deal_locked = ''' + @sdh_deal_locked + ''''ELSE '' END +
		CASE WHEN @sdh_create_ts_from IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), sdh.create_ts, 120) >= ''' + CONVERT(VARCHAR(10), @sdh_create_ts_from, 120) + '''' ELSE '' END +
		CASE WHEN @sdh_create_ts_to IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), sdh.create_ts, 120) <= ''' + CONVERT(VARCHAR(10), @sdh_create_ts_to, 120) + '''' ELSE '' END +
		CASE WHEN @sdh_deal_date_from IS NOT NULL THEN ' AND sdh.deal_date >= ''' + CONVERT(VARCHAR(10), @sdh_deal_date_from, 120) + '''' ELSE '' END +
		CASE WHEN @sdh_deal_date_to IS NOT NULL THEN ' AND sdh.deal_date <= ''' + CONVERT(VARCHAR(10), @sdh_deal_date_to, 120) + '''' ELSE '' END +
		CASE WHEN @sdh_deal_id IS NOT NULL THEN ' AND sdh.deal_id LIKE ''%' + @sdh_deal_id + '%''' ELSE '' END +
		CASE WHEN @sdh_term_start IS NOT NULL THEN ' AND sdd.term_start >= ''' + CONVERT(VARCHAR(10), @sdh_term_start, 120) + '''' ELSE '' END +
		CASE WHEN @sdh_term_end IS NOT NULL THEN ' AND sdd.term_end <= ''' + CONVERT(VARCHAR(10), @sdh_term_end, 120) + '''' ELSE '' END +
		CASE WHEN @sdh_sub_book_ids IS NOT NULL THEN ' AND sdh.sub_book IN (' + @sdh_sub_book_ids + ')' ELSE '' END +
		CASE WHEN @source_deal_header_id_from IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @source_deal_header_id_from + ')' ELSE '' END +
		CASE WHEN @source_deal_detail_id_from IS NOT NULL THEN ' AND sdd.source_deal_detail_id IN (' + @source_deal_detail_id_from + ')' ELSE '' END

		EXEC (@exec_sql_sdh)

		------------------#####################----NEW FILTER LOGIC START----########################------------------------
		IF OBJECT_ID('tempdb..#tmp_deals') IS NOT NULL DROP TABLE #tmp_deals
		IF OBJECT_ID('tempdb..#tmp_selected_deals') IS NOT NULL DROP TABLE #tmp_selected_deals
		IF OBJECT_ID('tempdb..#tmp_state_properties') IS NOT NULL DROP TABLE #tmp_state_properties
		IF OBJECT_ID('tempdb..#tmp_gis_product') IS NOT NULL DROP TABLE #tmp_gis_product
		IF OBJECT_ID('tempdb..#tmp_state_properties_detail') IS NOT NULL DROP TABLE #tmp_state_properties_detail
		IF OBJECT_ID('tempdb..#tmp_state_properties_in') IS NOT NULL DROP TABLE #tmp_state_properties_in
		IF OBJECT_ID('tempdb..#tmp_eligible_deals') IS NOT NULL DROP TABLE #tmp_eligible_deals
		
		----For Selecting Matching Perfect or Partial matching deals
		IF OBJECT_ID('tempdb..#tmp_filter_product') IS NOT NULL DROP TABLE #tmp_filter_product
		CREATE TABLE #tmp_filter_product(source_deal_header_id INT,
			source_deal_detail_id INT,
			region_id INT,
			state_value_id INT,
			tier_value_id INT,
			technology_id INT,
			term_start DATE,
			term_end DATE,
			vintage INT,
			match_type CHAR(1) COLLATE DATABASE_DEFAULT)
		
		/* Finding sale deals product to retrieve the buy deals of the same product */
		IF @source_deal_header_id IS NOT NULL
		BEGIN
			INSERT INTO #tmp_filter_product
			EXEC spa_return_products 
				@source_deal_header_id = @source_deal_header_id, 
				@sell_deal_detail_id = @sell_deal_detail_id,
				@jurisdiction = NULL,	
				@not_jurisdiction = NULL, 
				@tier_type = NULL, 
				@nottier_type = NULL, 
				@technology = NULL, 
				@not_technology = NULL,
				@region_id = NULL, 
				@not_region_id = NULL, 
				@vintage_year = NULL

			SELECT @region_id = COALESCE(@region_id + ',', '') + CAST(region_id AS VARCHAR)
			FROM #tmp_filter_product tsp
			GROUP BY region_id

			SELECT @jurisdiction = COALESCE(@jurisdiction + ',', '') + CAST(state_value_id AS VARCHAR)
			FROM #tmp_filter_product tsp
			GROUP BY state_value_id

			SELECT @tier_type = COALESCE(@tier_type + ',', '') + CAST(tier_value_id AS VARCHAR)
			FROM #tmp_filter_product tsp
			GROUP BY tier_value_id

			SELECT @technology = COALESCE(@technology + ',', '') + CAST(technology_id AS VARCHAR)
			FROM #tmp_filter_product tsp
			GROUP BY technology_id

			SELECT @sale_volume_to_match = SUM(volume_left) 
			FROM source_deal_detail
			WHERE source_deal_header_id = @source_deal_header_id
			AND (@sell_deal_detail_id IS NULL OR source_deal_detail_id = @sell_deal_detail_id)

			IF ISNULL(@sale_volume_to_match, 0) < 1
				RETURN

		END

		--Storing sale deals product in the process table to check in the next transaction of matching process
		CREATE TABLE #tmp_deals(source_deal_header_id INT) --to store final filtered deal ids
		CREATE TABLE #tmp_eligible_deals(source_deal_header_id INT,
			source_deal_detail_id INT,
			vintage_year INT, 
			banking_years INT,
			state_value_id INT,
			tier_value_id INT)
		
		CREATE TABLE #tmp_selected_deals(source_deal_header_id INT, 
			source_deal_detail_id INT,
			vintage_year INT, 
			banking_years INT)

		EXEC('INSERT INTO #tmp_deals 
			SELECT DISTINCT id FROM #grid_process_table')

		SELECT DISTINCT t.item region_id,
			sp.state_value_id AS jurisdiction_id,
			spd.tier_id,
			spd.technology_id
		INTO #tmp_state_properties
		FROM state_properties sp
		INNER JOIN state_properties_details spd ON spd.state_value_id = sp.state_value_id
		OUTER APPLY (SELECT item FROM dbo.SplitCommaSeperatedValues(sp.region_id)) t

		SELECT td.source_deal_header_id, 
			gp.tier_id,
			gp.jurisdiction_id,
			region_id,
			gp.technology_id,
			gp.in_or_not,
			sdv.code AS vintage
		INTO #tmp_gis_product
		FROM #tmp_deals td
		INNER JOIN gis_product gp ON gp.source_deal_header_id = td.source_deal_header_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = gp.vintage
			AND sdv.type_id = 10092

		SELECT tgp.source_deal_header_id,
			sp.tier_id,
			sp.jurisdiction_id,
			sp.region_id,
			sp.technology_id,
			tgp.in_or_not,
			tgp.vintage
		INTO #tmp_state_properties_detail
		FROM #tmp_gis_product tgp
		INNER JOIN #tmp_state_properties sp ON sp.region_id = tgp.region_id
			AND ISNULL(tgp.jurisdiction_id, sp.jurisdiction_id) = sp.jurisdiction_id
			AND ISNULL(tgp.tier_id, sp.tier_id) = sp.tier_id
			AND COALESCE(tgp.technology_id, sp.technology_id, -1) = ISNULL(sp.technology_id, -1)
		UNION
		SELECT tgp.source_deal_header_id,
			ISNULL(tgp.tier_id, sp.tier_id),
			ISNULL(tgp.jurisdiction_id, sp.jurisdiction_id),
			sp.region_id,
			ISNULL(tgp.technology_id, sp.technology_id),
			tgp.in_or_not,
			tgp.vintage 
		FROM #tmp_gis_product tgp
		INNER JOIN #tmp_state_properties sp ON ISNULL(tgp.jurisdiction_id, sp.jurisdiction_id) = sp.jurisdiction_id
		AND ISNULL(tgp.tier_id, sp.tier_id) = sp.tier_id
		AND COALESCE(tgp.technology_id, sp.technology_id, -1) = ISNULL(sp.technology_id, -1)
		AND tgp.region_id IS NULL

		SELECT DISTINCT
			tspi.source_deal_header_id,
			tspi.tier_id tier_id,
			tspi.jurisdiction_id,
			tspi.region_id region_id,
			tspi.technology_id,
			tspi.in_or_not,
			tspi.vintage
		INTO #tmp_state_properties_in
		FROM #tmp_state_properties_detail tspi

		SET @sql = '
			INSERT INTO #tmp_eligible_deals(source_deal_header_id, 
				source_deal_detail_id,
				banking_years, 
				state_value_id, 
				tier_value_id)
			SELECT DISTINCT sdh.source_deal_header_id, 
				sdd.source_deal_detail_id,
				MIN(COALESCE(cer.banking_years, pro.banking_years, deal.banking_years,  gen.banking_years)) AS banking_yr, 
				COALESCE(cer.state_id, pro.state_id, deal.state_id,  gen.state_id) state_id,
				COALESCE(cer.tier_type, pro.tier_type, deal.tier_type,  gen.tier_type) tier_type
			FROM #tmp_deals td 
			INNER JOIN #grid_process_table gpt ON gpt.id = td.source_deal_header_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				AND sdd.source_deal_detail_id = gpt.detail_id
				AND sdd.volume_left >= 1
			OUTER APPLY (SELECT DISTINCT 1 cnt 
						FROM Gis_Certificate gc 
						WHERE gc.source_deal_header_id = sdd.source_deal_detail_id 
						AND sdd.buy_sell_flag = ''b'') gc

			OUTER APPLY (SELECT DISTINCT 1 AS total, 
							gc.state_value_id state_id, 
							gc.tier_type, 
							spd.banking_years
				FROM Gis_Certificate gc
				OUTER APPLY(SELECT ISNULL(MAX(spd.effective_date), '''') eff_dt
							FROM state_properties_details spd 
							WHERE spd.tier_id = gc.tier_type 
							AND spd.state_value_id = gc.state_value_id
							AND spd.effective_date <= sdd.term_start) eff
				OUTER APPLY(SELECT MIN(spd.banking_years) banking_years
							FROM state_properties_details spd 
							WHERE spd.tier_id = gc.tier_type 
							AND spd.state_value_id = gc.state_value_id 
							AND ISNULL(spd.effective_date, '''') = eff.eff_dt) spd
				LEFT JOIN #tmp_state_properties tsp ON tsp.jurisdiction_id = gc.state_value_id
					AND tsp.tier_id = gc.tier_type
				LEFT JOIN static_data_value vin ON vin.value_id = gc.year
					AND vin.type_id = 10092
				WHERE gc.source_deal_header_id = sdd.source_deal_detail_id 
				AND sdd.buy_sell_flag = ''b'' ' +
				CASE WHEN @region_id IS NOT NULL THEN ' AND (tsp.region_id IS NULL OR tsp.region_id IN  (' + @region_id + '))' ELSE '' END + 
				CASE WHEN @not_region_id IS NOT NULL THEN ' AND ISNULL(tsp.region_id, -1) NOT IN(' + @not_region_id + ')' ELSE '' END + 
				CASE WHEN @jurisdiction IS NOT NULL THEN ' AND gc.state_value_id IN (' + @jurisdiction + ')' ELSE '' END +
				CASE WHEN @not_jurisdiction IS NOT NULL THEN ' AND ISNULL(gc.state_value_id, -1) NOT IN (' + @not_jurisdiction + ')' ELSE '' END +
				CASE WHEN @tier_type IS NOT NULL THEN ' AND gc.tier_type IN (' + @tier_type + ')' ELSE '' END +
				CASE WHEN @nottier_type IS NOT NULL THEN ' AND ISNULL(gc.tier_type, -1) NOT IN (' + @nottier_type + ')' ELSE '' END +
				CASE WHEN @technology IS NOT NULL THEN ' AND tsp.technology_id IN  (' + @technology + ')' ELSE '' END + 
				CASE WHEN @not_technology IS NOT NULL THEN ' AND ISNULL(tsp.technology_id, -1) NOT IN  (' + @not_technology + ')' ELSE '' END + 
				CASE WHEN @vintage_year IS NOT NULL THEN ' AND vin.code IN ( ' + @vintage_year + ')' ELSE '' END + ') cer
					
			OUTER APPLY (SELECT DISTINCT 1 cnt 
						FROM #tmp_state_properties_in tspn 
						WHERE tspn.source_deal_header_id = td.source_deal_header_id) gis
				
			OUTER APPLY(SELECT DISTINCT 1 AS total, 
						gp.jurisdiction_id AS state_id, 
						gp.tier_id AS tier_type,
						spdd.banking_years
				FROM #tmp_state_properties_in gp
				OUTER APPLY(SELECT ISNULL(MAX(spd.effective_date), '''') eff_dt
							FROM state_properties_details spd 
							WHERE spd.tier_id = gp.tier_id 
							AND spd.state_value_id = gp.jurisdiction_id
							AND spd.effective_date <= sdd.term_start) eff
				OUTER APPLY(SELECT MIN(spd.banking_years) banking_years 
							FROM state_properties_details spd 
							WHERE spd.tier_id = gp.tier_id 
							AND spd.state_value_id = gp.jurisdiction_id
							AND ISNULL(spd.effective_date, '''') = eff.eff_dt) spdd
				WHERE gp.source_deal_header_id = td.source_deal_header_id
				AND NOT EXISTS(SELECT DISTINCT 1 total
								FROM #tmp_state_properties_in gp1
								WHERE gp1.source_deal_header_id = gp.source_deal_header_id 
								AND (gp1.region_id IS NULL OR gp1.region_id = gp.region_id)
								AND (gp1.jurisdiction_id IS NULL OR gp1.jurisdiction_id = gp.jurisdiction_id) 
								AND (gp1.tier_id IS NULL OR gp1.tier_id = gp.tier_id) 
								AND (gp1.technology_id IS NULL OR gp1.technology_id = gp.technology_id) 
								AND gp1.in_or_not = 0)
				AND gc.cnt IS NULL
				AND gp.in_or_not = 1 ' +
				CASE WHEN @region_id IS NOT NULL THEN ' AND (gp.region_id IS NULL OR gp.region_id IN (' + @region_id + '))' ELSE '' END +
				CASE WHEN @not_region_id IS NOT NULL THEN ' AND ISNULL(gp.region_id, -1) NOT IN (' + @not_region_id + ')' ELSE '' END +
				CASE WHEN @jurisdiction IS NOT NULL THEN ' AND gp.jurisdiction_id IN (' + @jurisdiction + ')' ELSE '' END +
				CASE WHEN @not_jurisdiction IS NOT NULL THEN ' AND ISNULL(gp.jurisdiction_id, -1) NOT IN (' + @not_jurisdiction + ')' ELSE '' END +
				CASE WHEN @tier_type IS NOT NULL THEN ' AND gp.tier_id IN (' + @tier_type + ')' ELSE '' END +
				CASE WHEN @nottier_type IS NOT NULL THEN ' AND ISNULL(gp.tier_id, -1) NOT IN (' + @nottier_type + ')' ELSE '' END +
				CASE WHEN @technology IS NOT NULL THEN ' AND gp.technology_id IN (' + @technology + ')' ELSE '' END +
				CASE WHEN @not_technology IS NOT NULL THEN ' AND ISNULL(gp.technology_id, -1) NOT IN (' + @not_technology + ')' ELSE '' END +
				CASE WHEN @vintage_year IS NOT NULL THEN ' AND (gp.vintage IS NULL OR gp.vintage IN (' + @vintage_year + '))' ELSE '' END + 
				') pro
	
			OUTER APPLY(SELECT 1 cnt 
				FROM source_deal_header sdhh 
				WHERE sdhh.source_deal_header_id = td.source_deal_header_id 
				AND COALESCE(sdhh.state_value_id, sdhh.tier_value_id) IS NOT NULL) head

			OUTER APPLY(SELECT DISTINCT 1 AS total, 
						sd.state_value_id AS state_id, 
						sd.tier_value_id AS tier_type,
						spd.banking_years
				FROM source_deal_header sd
				OUTER APPLY(SELECT ISNULL(MAX(spd.effective_date), '''') eff_dt
							FROM state_properties_details spd 
							WHERE spd.tier_id = sd.tier_value_id 
							AND spd.state_value_id = sd.state_value_id 
							AND spd.effective_date <= sdd.term_start) eff
				OUTER APPLY(SELECT MIN(spd.banking_years) banking_years
							FROM state_properties_details spd 
							WHERE spd.tier_id = sd.tier_value_id 
							AND spd.state_value_id = sd.state_value_id
							AND ISNULL(spd.effective_date, '''') = eff.eff_dt) spd
				LEFT JOIN #tmp_state_properties tsp ON tsp.jurisdiction_id = sd.state_value_id
					AND tsp.tier_id = sd.tier_value_id
				LEFT JOIN static_data_value vin ON vin.value_id = sdd.vintage
					AND vin.type_id = 10092
				WHERE sd.source_deal_header_id = td.source_deal_header_id
				AND COALESCE(gc.cnt, gis.cnt) IS NULL
				AND COALESCE(sd.state_value_id, sd.tier_value_id) IS NOT NULL ' +
				CASE WHEN @region_id IS NOT NULL THEN ' AND (tsp.region_id IS NULL OR tsp.region_id IN  (' + @region_id + '))' ELSE '' END + 
				CASE WHEN @not_region_id IS NOT NULL THEN ' AND ISNULL(tsp.region_id, -1) NOT IN  (' + @not_region_id + ')' ELSE '' END + 
				CASE WHEN @jurisdiction IS NOT NULL THEN ' AND sd.state_value_id IN (' + @jurisdiction + ')' ELSE '' END +
				CASE WHEN @not_jurisdiction IS NOT NULL THEN ' AND ISNULL(sd.state_value_id, -1) NOT IN (' + @not_jurisdiction + ')' ELSE '' END +
				CASE WHEN @tier_type IS NOT NULL THEN ' AND sd.tier_value_id IN (' + @tier_type + ')' ELSE '' END +
				CASE WHEN @nottier_type IS NOT NULL THEN ' AND ISNULL(sd.tier_value_id, -1) NOT IN (' + @nottier_type + ')' ELSE '' END + 
				CASE WHEN @technology IS NOT NULL THEN ' AND tsp.technology_id IN (' + @technology + ')' ELSE '' END +
				CASE WHEN @not_technology IS NOT NULL THEN ' AND ISNULL(tsp.technology_id, -1) NOT IN (' + @not_technology + ')' ELSE '' END +
				CASE WHEN @vintage_year IS NOT NULL THEN ' AND (vin.code IN (' + @vintage_year + ') OR YEAR(sdd.term_start) IN (' + @vintage_year + '))' 
				ELSE '' END + 
				') deal

			OUTER APPLY(SELECT DISTINCT 1 AS total, 
						emtd.state_value_id state_id, 
						emtd.tier_id tier_type,
						spd.banking_years
				FROM rec_generator rg
				LEFT JOIN eligibility_mapping_template_detail emtd ON emtd.template_id = rg.eligibility_mapping_template_id
				OUTER APPLY(SELECT ISNULL(MAX(spd.effective_date), '''') eff_dt
							FROM state_properties_details spd 
							WHERE spd.tier_id = emtd.tier_id 
							AND spd.state_value_id = emtd.state_value_id
							AND spd.effective_date <= sdd.term_start) eff
				OUTER APPLY(SELECT MIN(spd.banking_years) banking_years 
							FROM state_properties_details spd 
							WHERE spd.tier_id = emtd.tier_id 
							AND spd.state_value_id = emtd.state_value_id
							AND ISNULL(spd.effective_date, '''') = eff.eff_dt) spd
				LEFT JOIN #tmp_state_properties tsp ON tsp.jurisdiction_id = emtd.state_value_id
					AND tsp.tier_id = emtd.tier_id
				WHERE rg.generator_id = sdh.generator_id
				AND COALESCE(gc.cnt, gis.cnt, head.cnt) IS NULL ' +
				CASE WHEN @region_id IS NOT NULL THEN ' AND (tsp.region_id IS NULL OR tsp.region_id IN  (' + @region_id + '))' ELSE '' END + 
				CASE WHEN @not_region_id IS NOT NULL THEN ' AND ISNULL(tsp.region_id, -1) NOT IN  (' + @not_region_id + ')' ELSE '' END + 
				CASE WHEN @jurisdiction IS NOT NULL THEN ' AND emtd.state_value_id IN (' + @jurisdiction + ')' ELSE '' END +
				CASE WHEN @not_jurisdiction IS NOT NULL THEN ' AND ISNULL(emtd.state_value_id, -1) NOT IN (' + @not_jurisdiction + ')' ELSE '' END +
				CASE WHEN @tier_type IS NOT NULL THEN ' AND emtd.tier_id IN (' + @tier_type + ')' ELSE '' END +
				CASE WHEN @nottier_type IS NOT NULL THEN ' AND ISNULL(emtd.tier_id, -1) NOT IN (' + @nottier_type + ')' ELSE '' END +
				CASE WHEN @technology IS NOT NULL THEN ' AND tsp.technology_id IN (' + @technology + ')' ELSE '' END +
				CASE WHEN @not_technology IS NOT NULL THEN ' AND ISNULL(tsp.technology_id, -1) NOT IN (' + @not_technology + ')' ELSE '' END + ') gen

			OUTER APPLY(SELECT TOP 1 
						source_deal_header_id AS deal
						FROM #tmp_filter_product) sdeal

			WHERE 1 = 1 
			AND NOT EXISTS(SELECT 1 
							FROM matching_header_detail_info mhdi
							WHERE mhdi.source_deal_detail_id = sdd.source_deal_detail_id
							AND sdd.buy_sell_flag = ''s'' AND ''' + @flag + '''=''g'')
			AND COALESCE(cer.total, pro.total, deal.total, gen.total) > 0
			GROUP BY sdh.source_deal_header_id,
			sdd.source_deal_detail_id,
			COALESCE(cer.state_id, pro.state_id, deal.state_id,  gen.state_id),
			COALESCE(cer.tier_type, pro.tier_type, deal.tier_type,  gen.tier_type)'

		--PRINT(@sql)
		EXEC(@sql)

		INSERT INTO #tmp_selected_deals
		SELECT source_deal_header_id, 
			source_deal_detail_id, 
			vintage_year, 
			MIN(banking_years) banking_years 
		FROM #tmp_eligible_deals
		GROUP BY source_deal_header_id, source_deal_detail_id, vintage_year

		SET @sql = '
		UPDATE tsd SET tsd.vintage_year = vin.vintage_year
		FROM #tmp_selected_deals tsd
		INNER JOIN (
					SELECT tsd.source_deal_header_id, 
						sdd.source_deal_detail_id,
						COALESCE(sdv.code, YEAR(sdd.term_start)) vintage_year
					FROM #tmp_selected_deals tsd
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = tsd.source_deal_detail_id
					LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					LEFT JOIN gis_product gp ON gp.source_deal_header_id = tsd.source_deal_header_id
						AND gp.in_or_not = 1
					LEFT JOIN static_data_value sdv ON sdv.value_id = COALESCE(gc.year, gp.vintage, sdd.vintage)
						AND sdv.type_id = 10092) vin ON vin.source_deal_detail_id = tsd.source_deal_detail_id' +
					CASE WHEN @vintage_year IS NOT NULL THEN ' AND vin.vintage_year IN (' + @vintage_year + ')' ELSE '' END 

		EXEC(@sql)

		UPDATE ted SET ted.vintage_year = tsd.vintage_year
		FROM #tmp_eligible_deals ted 
		INNER JOIN #tmp_selected_deals tsd ON tsd.source_deal_detail_id = ted.source_deal_detail_id
		
		IF @flag = 'm'
		BEGIN
			IF OBJECT_ID('tempdb..#tmp_product_info') IS NOT NULL
				DROP TABLE #tmp_product_info

			SELECT ted.source_deal_header_id,
				ted.source_deal_detail_id,
				sdd.term_start,
				tsd.vintage_year,
				--ted.banking_years,
				ted.state_value_id,
				ted.tier_value_id,
				gc.contract_expiration_date,
				DATEADD(YEAR, ISNULL(ted.banking_years, 1)-1, CAST(YEAR(sdd.term_start) AS VARCHAR) + '-12-31') banking_exp_date
			INTO #tmp_product_info
			FROM #tmp_selected_deals tsd
			INNER JOIN #tmp_eligible_deals ted ON ted.source_deal_detail_id = tsd.source_deal_detail_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tsd.source_deal_header_id
				AND sdd.source_deal_detail_id = ted.source_deal_detail_id
			LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND gc.state_value_id = ted.state_value_id
				AND gc.tier_type = ted.tier_value_id

			-- @return_process_table is passed and used in spa_calc_mtm_job
			-- Used this logic due to nested insert exec issue. 
			IF @return_process_table IS NOT NULL
			BEGIN
				SET @sql = ' IF OBJECT_ID(N''' + @return_process_table + ''') IS NOT NULL
					DROP TABLE ' + @return_process_table
				EXEC(@sql)
				EXEC(' SELECT * INTO ' + @return_process_table + ' FROM #tmp_product_info')
			END
			ELSE
			BEGIN
				SELECT * FROM #tmp_product_info
			END
			
			RETURN
		END

		------------------#####################----NEW FILTER LOGIC END----########################------------------------
		----Find Fiscal year start end dates start
		IF OBJECT_ID ('tempdb..#tmp_fiscal_year_detail') IS NOT NULL
			DROP TABLE #tmp_fiscal_year_detail

			IF OBJECT_ID ('tempdb..#tmp_filter') IS NOT NULL
				DROP TABLE #tmp_filter
			
			SELECT DISTINCT NULL AS source_deal_detail_id, vintage, state_value_id
			INTO #tmp_filter
			FROM #tmp_filter_product
			WHERE vintage IS NOT NULL AND @source_deal_header_id IS NOT NULL
			UNION
			SELECT DISTINCT ted.source_deal_detail_id, ted.vintage_year, ted.state_value_id 
			FROM #tmp_eligible_deals ted
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ted.source_deal_detail_id
			AND sdd.buy_sell_flag = 'b'
			WHERE vintage_year IS NOT NULL

			SELECT DISTINCT
					sp.source_deal_detail_id,
				   state_value_id,
				   state_value,
				   CAST((CAST(vintage AS VARCHAR(10))+ '-' + CAST(calendar_from_month AS VARCHAR(10)) + '-01') AS DATE) [start],
				   EOMONTH(CAST(IIF(calendar_to_month <> 12, vintage + 1, vintage) AS VARCHAR(10)) + '-' + CAST(calendar_to_month AS VARCHAR(10)) + '-01') [end]
			INTO #tmp_fiscal_year_detail
			FROM (
			SELECT	i.source_deal_detail_id,
					i.state_value_id,
					sdv.code state_value,
					sp1.calendar_from_month,
					sp1.calendar_to_month,
					sp1.current_next_year
			FROM #tmp_filter i
			INNER JOIN state_properties sp1 ON sp1.state_value_id = i.state_value_id
			INNER JOIN static_data_value sdv ON sdv.value_id = i.state_value_id 
				AND sdv.[type_id] = 10002
			WHERE NULLIF(sp1.calendar_from_month, 0) IS NOT NULL
				AND NULLIF(sp1.calendar_to_month, 0) IS NOT NULL
			) sp
			OUTER APPLY (
				SELECT CASE WHEN calendar_from_month = 1 OR ISNULL(sp.current_next_year, 'c') = 'c' THEN 
							CAST((tf.vintage) AS INT)
						ELSE
							CAST((tf.vintage) AS INT)-1
						END vintage
				FROM #tmp_filter tf
				WHERE tf.state_value_id = sp.state_value_id
				AND ISNULL(tf.source_deal_detail_id, -1) = ISNULL(sp.source_deal_detail_id, -1)
			) v

		----Find Fiscal year start end dates end

		--Start logic of retrieving available sequences
		IF OBJECT_ID ('tempdb..#tmp_volume_detail') IS NOT NULL
			DROP TABLE #tmp_volume_detail

		CREATE TABLE #tmp_volume_detail(
			source_deal_detail_id INT, volume INT, sequence_from INT, sequence_to INT
		)

		DECLARE @TmpEligibleDeals VARCHAR(150)
		SET @TmpEligibleDeals = dbo.FNAProcessTableName('TmpEligibleDeals', @user_name, @process_id)

		EXEC('SELECT DISTINCT source_deal_header_id, 
				source_deal_detail_id 
			INTO ' + @TmpEligibleDeals + ' 
			FROM #tmp_eligible_deals ')

		INSERT INTO #tmp_volume_detail
		EXEC spa_return_certificate_volume_detail 's', NULL, @process_id

		--END logic of retrieving available sequences

		CREATE INDEX indx_tmp_selected_deals ON #tmp_selected_deals (source_deal_header_id)
		CREATE INDEX indx_tmp_eligible_deals ON #tmp_eligible_deals (source_deal_header_id)
		CREATE INDEX indx_tmp_volume_detail ON #tmp_volume_detail (source_deal_detail_id)


		SET @sql = '	
				SELECT DISTINCT
					sdh.id [source_deal_header_id]
					, dbo.[FNATRMWinHyperlink](''a'',''10131010'',sdh.deal_id,sdh2.source_deal_header_id,''n'',NULL,NULL,NULL,NULL,CASE WHEN sdh2.header_buy_sell_flag = ''b'' THEN ''Buy'' WHEN sdh2.header_buy_sell_flag = ''s'' THEN ''Sell'' ELSE NULL END,NULL,NULL,NULL,NULL,NULL,0) [ref_id]
					--, sdh.deal_id AS [ref_id]
					, sdh.counterparty [counterparty]
					, td.vintage_year AS [vintage_year]
					, CAST(COALESCE(cer.expiration_date, tfyd.expiration_date, exp.expiration_date) AS DATE) AS [expiration_date]
					, sdd1.term_start [term_start]
					, sdd1.term_end [term_end]
					, sdh.leg
					, sdd1.delivery_date AS [delivery_date]
					, sdd1.source_deal_detail_id [source_deal_detail_id]
					, sdh.deal_date [deal_date]
					--, [dbo].[FNARemoveTrailingZeroes](isnull(sdd1.deal_volume,0)) [actual_volume]
					--, [dbo].[FNARemoveTrailingZeroes](COALESCE(md.[matched_volume],md1.[matched_volume],0)) [matched]
					, ' + CASE WHEN @sdh_generator_id IS NOT NULL THEN ' sdh.volume_left ' ELSE 'isnull(tvd.volume,sdd1.volume_left) ' END + ' [actual_volume]
					, 0 AS [matched]
					, ' + CASE WHEN @sdh_generator_id IS NOT NULL THEN ' sdh.volume_left ' ELSE 'isnull(tvd.volume,sdd1.volume_left) ' END + ' [remaining]
					, [dbo].[FNARemoveTrailingZeroes](ISNULL(sdd1.fixed_price,0)) [price]
					, [dbo].[FNARemoveTrailingZeroes](ISNULL(sdd1.total_volume,0) * ISNULL(sdh.deal_price,0)) [vp_value]
					, sdv_status.code [detail_status]
					, pc.value_id [product_class]
					
					, tvd.sequence_from
					, tvd.sequence_to
					--, tvd.is_transferred
				INTO ' + @grid_process_table + '
				FROM #tmp_selected_deals td
				INNER JOIN #grid_process_table AS sdh ON sdh.id = td.source_deal_header_id
				INNER JOIN source_deal_header sdh2 on sdh.id = sdh2.source_deal_header_id
				INNER JOIN #tmp_eligible_deals ted ON ted.source_deal_detail_id = td.source_deal_detail_id
				INNER JOIN source_deal_detail sdd1 on ted.source_deal_detail_id = sdd1.source_deal_detail_id and sdd1.leg = sdh.leg
					AND sdh.detail_id = sdd1.source_deal_detail_id
				LEFT JOIN #tmp_volume_detail tvd ON tvd.source_deal_detail_id = sdd1.source_deal_detail_id
				LEFT JOIN static_data_value sdv_status ON sdv_status.value_id = sdd1.status
				OUTER APPLY(SELECT value_id 
							FROM source_deal_header sd
							INNER JOIN static_data_value pc ON pc.value_id = sd.product_classification
							WHERE pc.type_id = 107400	AND pc.value_id = 107400
							AND sd.source_deal_header_id = sdh2.source_deal_header_id) pc

				OUTER APPLY(SELECT SUM(total_volume) total_volume,
								MAX(contract_expiration_date) expiration_date
							FROM source_deal_detail 
							WHERE source_deal_header_id = sdh.id) sdd

				OUTER APPLY(SELECT 
								COUNT(*) total,
								MIN(contract_expiration_date) AS expiration_date
							FROM gis_certificate 
							WHERE source_deal_header_id = sdd1.source_deal_detail_id ) cer

				OUTER APPLY (SELECT 
								CASE WHEN sdd1.term_start < tfyd.start THEN 
									DATEADD(YEAR, ISNULL(td.banking_years, 1)-2, [end]) 
								ELSE 
									DATEADD(YEAR, ISNULL(td.banking_years, 1)-1, [end]) 
								END expiration_date
							FROM #tmp_fiscal_year_detail tfyd 
							OUTER APPLY(SELECT source_deal_detail_id, MIN(start) [start]
										FROM #tmp_fiscal_year_detail tfyd1
										WHERE tfyd1.source_deal_detail_id = tfyd.source_deal_detail_id
										GROUP BY source_deal_detail_id) tfyd1
							WHERE tfyd.state_value_id = ted.state_value_id
							AND tfyd.source_deal_detail_id = ted.source_deal_detail_id
							AND tfyd1.[start] = tfyd.[start]) tfyd

				OUTER APPLY(SELECT 
								ISNULL(MIN(contract_expiration_date), ' +
								CASE WHEN @sdh_buy_sell_id = 's' THEN 'NULL' ELSE 
								'DATEADD(YEAR, ISNULL(td.banking_years, 1)-1, CAST(YEAR(sdd1.term_start) AS VARCHAR) + ''-12-31'')' END + ') expiration_date
							FROM gis_certificate 
							WHERE source_deal_header_id = sdd1.source_deal_detail_id
							AND cer.total <= 0 ' +
							CASE WHEN (@effective_date IS NOT NULL AND @include_expired_deals = 'n') THEN 
							' AND ((pc.value_id IS NULL AND ''' + @sdh_filter_mode + ''' = ''a'') 
									OR COALESCE(contract_expiration_date, 
									DATEADD(YEAR, ISNULL(td.banking_years, 1)-1, td.vintage_year),
									''' + CAST(@effective_date AS VARCHAR) + ''') >= ''' + CAST(@effective_date AS VARCHAR) + ''')' 
							ELSE '' END + ') exp

				OUTER APPLY(SELECT 
								SUM(assigned_vol) matched_volume
							FROM matching_header_detail_info  mhdi
							WHERE mhdi.source_deal_detail_id_from = sdd1.source_deal_detail_id 
							GROUP BY mhdi.source_deal_detail_id_from) md 

				OUTER APPLY (SELECT 
								SUM(assigned_vol) matched_volume
							FROM matching_header_detail_info  mhdi
							WHERE mhdi.source_deal_detail_id = sdd1.source_deal_detail_id 
							GROUP BY mhdi.source_deal_detail_id) md1

			
				'
			IF EXISTS (SELECT 1 FROM #tmp_filter_product WHERE match_type = 'y')
			BEGIN
				SET @sql += '
					OUTER APPLY(SELECT TOP 1 state_value_id 
								FROM #tmp_filter_product WHERE state_value_id = ted.state_value_id 
								AND vintage IS NOT NULL) tfpa
					LEFT JOIN (SELECT DISTINCT state_value_id, tier_value_id, vintage 
								FROM #tmp_filter_product) tfp ON tfp.state_value_id = ted.state_value_id
								AND tfp.tier_value_id = ted.tier_value_id
					INNER JOIN #tmp_fiscal_year_detail tfyd2 ON ted.state_value_id = tfyd2.state_value_id
						AND ((sdd1.term_start >= tfyd2.[start] AND sdd1.term_end <= tfyd2.[end]) OR tfpa.state_value_id IS NULL)
						AND tfyd2.source_deal_detail_id IS NULL
				'
			END
			SET @sql += '		
				WHERE 1 = 1 
				' +
				CASE WHEN @source_deal_header_id_from IS NULL THEN ' AND ISNULL(sdd1.[volume_left], 0) >= 1 ' ELSE '' END + '
				--(md.[matched_volume] IS NULL OR 
				--[dbo].[FNARemoveTrailingZeroes](ISNULL(md.[matched_volume],0)) <> [dbo].[FNARemoveTrailingZeroes](ISNULL(sdd.total_volume,0)))
					AND sdh.deal_id LIKE  CASE WHEN sdh.counterparty LIKE ''%Market Maker%'' THEN ''%_copy%'' ELSE sdh.deal_id END ' +

			CASE WHEN @deal_detail_status IS NOT NULL THEN ' AND sdd1.status = ' + @deal_detail_status + '' ELSE '' END +
			CASE WHEN (@effective_date IS NOT NULL AND @include_expired_deals = 'n') THEN 
				' AND ((pc.value_id IS NULL AND ''' + @sdh_filter_mode + ''' = ''a'') 
						OR (ISNULL(cer.expiration_date, exp.expiration_date) >= ''' + CAST(@effective_date AS VARCHAR) + ''') 
						OR ISNULL(cer.expiration_date, exp.expiration_date) IS NULL)'
			ELSE '' END +
			CASE WHEN @delivery_date_from IS NOT NULL THEN ' AND sdd1.delivery_date >= ''' + CAST(@delivery_date_from AS VARCHAR) + '''' ELSE '' END +
			CASE WHEN @delivery_date_to IS NOT NULL THEN ' AND sdd1.delivery_date <= ''' + CAST(@delivery_date_to AS VARCHAR) + '''' ELSE '' END +
			CASE WHEN @description IS NOT NULL THEN ' AND sdh2.description1 LIKE ''%' + @description + '%''' ELSE '' END +
			CASE WHEN @product_classification IS NOT NULL THEN ' AND sdh2.product_classification = ' + CAST(@product_classification AS VARCHAR) + '' ELSE '' END +
			CASE WHEN @vintage_year IS NOT NULL THEN ' AND td.vintage_year IN (' + @vintage_year + ')' ELSE '' END +
			CASE WHEN @sdh_term_start IS NOT NULL THEN ' AND sdd1.term_start >= ''' + CONVERT(VARCHAR(10), @sdh_term_start, 120) + '''' ELSE '' END +
			CASE WHEN @sdh_term_end IS NOT NULL THEN ' AND sdd1.term_end <= ''' + CONVERT(VARCHAR(10), @sdh_term_end, 120) + '''' ELSE '' END 
		
			--Filtering the deals @volume_match type wise 1.Partial = 'p' 2.Perfect = 'c'
			IF EXISTS(SELECT 1 FROM #tmp_filter_product WHERE match_type = 'm')
			BEGIN
				SET @sql+= ' 
					AND EXISTS(SELECT 1 
						FROM #tmp_filter_product tfp  
						WHERE (tfp.match_type IS NULL OR tfp.match_type = ''f'' OR 
						((tfp.match_type = ''m'' AND YEAR(tfp.term_start)*100+MONTH(tfp.term_start) = YEAR(sdd1.term_start)*100+MONTH(sdd1.term_start)) 
						OR 
						(tfp.match_type = ''y'' AND YEAR(tfp.term_start) = YEAR(sdd1.term_start))))) ' 
			END

	--PRINT (@sql)
	EXEC (@sql)

	SET @sql = '
	;WITH quantityCheck AS (
		SELECT tt.*,
			SUM(CAST(remaining AS INT)) OVER (ORDER BY CAST(ISNULL(expiration_date, ''9999-12-31'') AS DATE), source_deal_header_id, term_start, leg, sequence_from) AS volumeCheck
		FROM ' + @grid_process_table + ' tt)
		SELECT ID = identity(int, 1, 1), 
			quantityCheck.*, 
			''' + @process_id + ''' AS process_id 
		INTO #tmp_final_output
		FROM quantityCheck
		OUTER APPLY(SELECT TOP 1 volumeCheck AS vol 
					FROM quantityCheck 
					WHERE ' + CAST(ISNULL(@sale_volume_to_match, 0) AS VARCHAR) + ' <= volumeCheck ORDER BY volumeCheck) t
		OUTER APPLY(SELECT TOP 1 volumeCheck AS vol 
					FROM quantityCheck 
					WHERE volumeCheck <= ' + CAST(ISNULL(@sale_volume_to_match, 0) AS VARCHAR) + ' ORDER BY volumeCheck DESC) t1
		OUTER APPLY(SELECT TOP 1 source_deal_detail_id
					FROM quantityCheck 
					WHERE remaining = ' + CAST(ISNULL(@sale_volume_to_match, 0) AS VARCHAR) + ' ORDER BY expiration_date ASC) t2
		WHERE 1 = 1 ' +
		CASE WHEN @volume_match IS NULL THEN '' ELSE 
		CASE WHEN @volume_match IN ('p') THEN 
			' AND volumeCheck <= ISNULL(t.vol, t1.vol) ' 
		ELSE ' AND quantityCheck.source_deal_detail_id = t2.source_deal_detail_id' 
		END END +  ' 

		INSERT INTO #tmp_final_output
		SELECT 
			*,
			NULL AS volumeCheck,
			''' + @process_id + ''' AS process_id 
		FROM ' + @grid_process_table + ' t
		WHERE NOT EXISTS(SELECT 1 
						FROM #tmp_final_output t1 
						WHERE t1.source_deal_header_id = t.source_deal_header_id
							AND t1.source_deal_detail_id = t.source_deal_detail_id)
		AND ''' + ISNULL(@show_all_deals, 'n') + ''' = ''y'''

		+ CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tmp_filter_product) THEN '
		SELECT DISTINCT tfp.source_deal_header_id,
			tfp.source_deal_detail_id,
			tfp.state_value_id,
			ted.tier_value_id,
			tfp.term_start,
			tfp.term_end,
			tfp.vintage,
			tfp.match_type,
			tfo.source_deal_header_id buy_deal_id,
			ted.source_deal_detail_id buy_detail_id,
			fyd.[start],
			fyd.[end],
			tfo.sequence_from,
			tfo.sequence_to
		INTO ' + @DealsProductInfo + '
		FROM #tmp_final_output tfo
		INNER JOIN #tmp_eligible_deals ted ON ted.source_deal_detail_id = tfo.source_deal_detail_id
		INNER JOIN #tmp_filter_product tfp ON tfp.state_value_id = ted.state_value_id
			AND tfp.tier_value_id = ted.tier_value_id
		LEFT JOIN source_deal_detail sdd_b ON sdd_b.source_deal_detail_id = ted.source_deal_detail_id
		LEFT JOIN #tmp_fiscal_year_detail fyd ON fyd.state_value_id = tfp.state_value_id
			AND fyd.source_deal_detail_id IS NULL
		WHERE 1 = 1
		' + IIF(EXISTS(SELECT 1 FROM #tmp_filter_product WHERE match_type = 'y'),'
			AND sdd_b.term_start >= fyd.[start]
			AND sdd_b.term_end <= fyd.[end]
		', '') + '
		' ELSE '' END + '

		SELECT tfo.source_deal_header_id,
			tfo.ref_id,
			tfo.counterparty,
			tfo.vintage_year,
			tfo.expiration_date AS expiration_date,
			dbo.FNADateFormat(tfo.term_start) [term_start],
			dbo.FNADateFormat(tfo.term_end) [term_end],
			ISNULL(tfo.leg,sdd.leg) leg,
			dbo.FNADateFormat(tfo.delivery_date) AS [delivery_date],
			tfo.source_deal_detail_id,
			dbo.FNADateFormat(deal_date) AS [deal_date],
			tfo.sequence_from,
			tfo.sequence_to,
			tfo.actual_volume,
			tfo.matched,
			[dbo].[FNARemoveTrailingZeroes](tfo.remaining) remaining,
			tfo.price,
			tfo.vp_value,
			tfo.detail_status, 
			NULL transfer_status,	
			NULL id,
			tfo.process_id,
			tfo.product_class
		INTO ' + @tmpMatchAllRecs + '
		FROM #tmp_final_output tfo
		LEFT JOIN source_deal_detail sdd on sdd.source_deal_detail_id = '''+ ISNULL(@sell_deal_detail_id, '')+''''

		--PRINT (@sql)
		EXEC (@sql)

		IF @auto_match_flag = 'g'
			EXEC('SELECT * 
			FROM ' + @tmpMatchAllRecs + '
			ORDER BY expiration_date, 
			source_deal_header_id, 
			term_start, 
			sequence_from')
		ELSE
		BEGIN
			IF OBJECT_ID(N'tempdb..#check_row_exists', N'U') IS NOT NULL
			DROP TABLE #check_row_exists

			CREATE TABLE #check_row_exists(deal_id INT)
			EXEC('INSERT INTO #check_row_exists
				SELECT TOP 1 source_deal_header_id FROM ' + @tmpMatchAllRecs)

			IF NOT EXISTS(SELECT TOP 1 1 FROM #check_row_exists)
			BEGIN
				IF OBJECT_ID(N'tempdb..#tmp_calc_status_from_auto_match', N'U') IS NOT NULL
				BEGIN
					INSERT INTO #tmp_calc_status_from_auto_match
					SELECT 
					'Error' AS ErrorCode
					, 'buysell_match' AS Module
					, 'spa_buy_sell_match' AS Area
					, 'Warning' AS [Status]
					, 'No RECs found for the selected sell deal.' AS [Message]
					, '' AS Recommendation
				END
				ELSE
				BEGIN
					SELECT 
					'Error' AS ErrorCode
					, 'buysell_match' AS Module
					, 'spa_buy_sell_match' AS Area
					, 'Warning' AS [Status]
					, 'No RECs found for the selected sell deal.' AS [Message]
					, '' AS Recommendation
				END
				RETURN
			END
		END
	END
	ELSE IF @flag = 't'
	BEGIN
			DECLARE @column_name VARCHAR(50)
			SET @column_name = CASE WHEN @set = 2 THEN '_from' ELSE '' END

			IF OBJECT_ID(N'tempdb..#temp_max_date_pnl1', N'U') IS NOT NULL
			DROP TABLE #temp_max_date_pnl1

			IF OBJECT_ID(N'tempdb..#tmp_match_results', N'U') IS NOT NULL
			DROP TABLE #tmp_match_results

			CREATE TABLE #temp_max_date_pnl1(source_deal_header_id INT, pnl_as_of_date DATE)

			SET @sql_r = 'INSERT INTO #temp_max_date_pnl1 
				SELECT source_deal_header_id, 
					MAX(pnl_as_of_date) pnl_as_of_date 
				FROM source_deal_pnl 
				GROUP BY source_deal_header_id'

			EXEC(@sql_r)

			SET @sql_r = '
				SELECT 
					ad.source_deal_header_id' + @column_name + ' AS source_deal_header_id, 
					sdh.deal_id AS ref_id,
					scc.counterparty_name AS counterparty,
					ad.vintage_yr AS [vintage_year],
					ad.expiration_dt AS [expiration_date],
					dbo.FNADateFormat(sdd.term_start) AS [term_start],
					dbo.FNADateFormat(sdd.term_end) AS [term_end],
					sdd.leg,
					dbo.FNADateFormat(ISNULL(ad.d_date,sdd.delivery_date)) AS [delivery_date],
					ad.source_deal_detail_id' + @column_name + ' AS [source_deal_detail_id],
					dbo.FNADateFormat(sdh.deal_date) AS [deal_date],
					ad.sequence_from,
					ad.sequence_to,
					ISNULL(sdd.deal_volume, 0) AS [actual_volume],
					ISNULL(ad.assigned_vol, 0) AS [matched],
					ISNULL(sdd.volume_left, 0) ' + CASE WHEN @link_id IS NULL THEN '-ISNULL(ad.assigned_vol, 0)' ELSE '' END + ' AS remaining,
					[dbo].[FNARemoveTrailingZeroes](ISNULL(sdd.fixed_price,0)) AS [price],	
					[dbo].[FNARemoveTrailingZeroes](isnull(sdd.total_volume,0) * ABS(ISNULL(sdd.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))))) AS [vp_value],	
					sdv_status.code [detail_status],
					ad.t_status AS transfer_status,
					ad.id,
					NULL process_id,
					actual_for_seq,
					remaining_for_seq
				INTO #tmp_match_results
				FROM source_deal_header sdh
				INNER JOIN (
						SELECT source_deal_header_id' + @column_name + ',
							source_deal_detail_id' + @column_name + ',
							SUM(assigned_vol) AS assigned_vol,
							MAX(vintage_yr) AS vintage_yr,'
							+ CASE WHEN ISNULL(@set, 0) = 1 THEN 
								'NULL AS expiration_dt,
								 MIN(sequence_from) AS sequence_from,
								 MAX(sequence_to) AS sequence_to,' 
							ELSE ' 
								 MAX(expiration_dt) AS expiration_dt,
								 sequence_from,
								 sequence_to, ' 
							END +
							CASE WHEN ISNULL(@set, 0) = 2 AND @link_id IS NOT NULL THEN 
								'id,
								MAX(delivery_date) d_date,
								MAX(sdv.code) t_status, ' 
							ELSE '
								NULL AS id,
								NULL AS d_date,
								NULL AS t_status, ' 
							END + 
							CASE WHEN ISNULL(@set, 0) = 2 AND @link_id IS NULL THEN '
								SUM(actual_volume) AS actual_for_seq,
								SUM(remaining) AS remaining_for_seq ' 
							ELSE '
								NULL AS actual_for_seq,
								NULL AS remaining_for_seq ' 
							END + '
						FROM ' + CASE WHEN @link_id IS NOT NULL THEN 'matching_header_detail_info
						LEFT JOIN static_data_value sdv ON sdv.value_id = transfer_status ' ELSE @DealMatchTable END + '
						WHERE 1 = 1 ' + 
						CASE WHEN @link_id IS NOT NULL THEN ' AND link_id = ' + CAST(@link_id AS VARCHAR) + '' ELSE '' END + '
						GROUP BY source_deal_header_id' + @column_name + ', 
							source_deal_detail_id' + @column_name + 
							+ CASE WHEN ISNULL(@set, 0) = 1 THEN '' ELSE ',sequence_from,sequence_to' END + 
							+ CASE WHEN ISNULL(@set, 0) = 2 AND @link_id IS NOT NULL THEN ',id' ELSE '' END + ') ad ON ad.source_deal_header_id' + @column_name + ' = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ad.source_deal_detail_id' + @column_name + '
				LEFT JOIN source_counterparty scc ON scc.source_counterparty_id = sdh.counterparty_id
				LEFT JOIN static_data_value sdv_status ON sdv_status.value_id = sdd.status
				
				LEFT JOIN (
							SELECT sds.source_deal_header_id, 
								SUM(settlement_amount) settlement_amount,
								SUM(volume) sds_volume
							FROM source_deal_settlement sds 
							GROUP BY sds.source_deal_header_id) ds ON ds.source_deal_header_id = sdh.source_deal_header_id
				LEFT JOIN (SELECT sdp.source_deal_header_id, 
								SUM(und_pnl_set) und_pnl_set,
								SUM(deal_volume) dp_volume
							FROM source_deal_pnl sdp 
							INNER JOIN #temp_max_date_pnl1 tmpnl 
								ON tmpnl.pnl_as_of_date = sdp.pnl_as_of_date
								AND tmpnl.source_deal_header_id = sdp.source_deal_header_id
							GROUP BY sdp.source_deal_header_id) dp ON dp.source_deal_header_id = sdh.source_deal_header_id 

						 SELECT source_deal_header_id,
							ref_id,
							counterparty,
							vintage_year,
							expiration_date,
							term_start,
							term_end,
							leg,
							delivery_date,
							source_deal_detail_id,
							deal_date,
							sequence_from,
							sequence_to,
							[dbo].[FNARemoveTrailingZeroes](
							CASE WHEN id IS NOT NULL AND sequence_from IS NOT NULL THEN matched ELSE ISNULL(actual_for_seq, actual_volume) END) AS actual_volume,
							[dbo].[FNARemoveTrailingZeroes](matched) AS matched,
							[dbo].[FNARemoveTrailingZeroes](
							CASE WHEN id IS NOT NULL AND sequence_from IS NOT NULL THEN 0 ELSE ISNULL(remaining_for_seq, remaining) END) AS remaining,
							price,
							vp_value,
							detail_status,
							transfer_status,
							id,
							process_id 
						 FROM #tmp_match_results
						 ORDER BY expiration_date, 
							source_deal_header_id, 
							term_start, 
							sequence_from '

			--PRINT(@sql_r)
			EXEC (@sql_r)
	END
	ELSE IF @flag = 'i'
	BEGIN
		BEGIN TRY 
			BEGIN TRAN

			IF @link_id IS NOT NULL
				BEGIN
					DELETE aa 
					FROM matching_header_detail_info mhdi
					INNER JOIN assignment_audit aa ON aa.source_deal_header_id = mhdi.source_deal_detail_id
						AND aa.source_deal_header_id_from = mhdi.source_deal_detail_id_from
					WHERE mhdi.link_id = @link_id
				END

				DECLARE @idoc_t INT
				EXEC sp_xml_preparedocument @idoc_t OUTPUT, @xmlValue
			
				IF OBJECT_ID('tempdb..#temp_deal_match_header') IS NOT NULL
					DROP TABLE #temp_deal_match_header
		
				SELECT	
					NULLIF([description], '')				[link_description],
					NULLIF(effective_date, '')				[link_effective_date],
					NULLIF(total_matched_volume, '')		[total_matched_volume],
					NULLIF(group1, '')						[group1],
					NULLIF(group2, '')						[group2],
					NULLIF(group3, '')						[group3],
					NULLIF(group4, '')						[group4],
					NULLIF(hedging_relationship_type, '')	[hedging_relationship_type],
					NULLIF(link_type, '')					[link_type],
					NULLIF(match_status, '')				[match_status],
					NULLIF(assignment_type, '')				[assignment_type],
					@link_id AS link_id
				INTO #temp_deal_match_header
				FROM OPENXML(@idoc_t, '/Root/FormXML', 1)
				WITH (
					[description]			VARCHAR(1000),
					[effective_date]		DATETIME,
					[total_matched_volume]	FLOAT,
					[group1]				INT,
					[group2]				INT,
					[group3]				INT,
					[group4]				INT,
					[hedging_relationship_type]	INT,
					[link_type]				INT,
					[match_status]			INT,
					[assignment_type]		INT
				)

				IF @link_id IS NOT NULL
				BEGIN
					UPDATE mh SET
						mh.[link_description] = tdmh.[link_description],
						mh.[link_effective_date] = tdmh.[link_effective_date],
						mh.[total_matched_volume] = t.vol,
						mh.[group1] = tdmh.[group1],
						mh.[group2] = tdmh.[group2],
						mh.[group3] = tdmh.[group3],
						mh.[group4] = tdmh.[group4],
						mh.match_status = tdmh.[match_status],
						mh.assignment_type = tdmh.[assignment_type],
						mh.update_user = @user_name,
						mh.update_ts = GETDATE()
					FROM matching_header mh
					INNER JOIN #temp_deal_match_header tdmh ON tdmh.link_id = mh.link_id
					OUTER APPLY(SELECT SUM(assigned_vol) vol FROM #assigned_deals) t
				END
				ELSE
				BEGIN
					INSERT INTO matching_header(
						[link_description],
						[link_effective_date],
						[total_matched_volume],
						[group1],
						[group2],
						[group3],
						[group4],
						match_status,
						assignment_type,
						create_ts,
						update_user
						)
					SELECT 
						[link_description],
						[link_effective_date],
						t.vol AS [total_matched_volume],
						[group1],
						[group2],
						[group3],
						[group4],
						[match_status],
						[assignment_type],
						GETDATE(),
						@user_name
					FROM #temp_deal_match_header
					OUTER APPLY(SELECT source_deal_detail_id,
									SUM(assigned_vol) vol 
								FROM #assigned_deals
								GROUP BY source_deal_detail_id) t

					SELECT @new_link_id = SCOPE_IDENTITY()

					UPDATE mh 
						SET mh.link_description = mh.link_id
					FROM matching_header mh
					WHERE mh.link_id = @new_link_id AND mh.link_description IS NULL


				END

				SELECT @new_link_id = ISNULL(@new_link_id, @link_id)
				
				DELETE md
				FROM matching_detail md
				LEFT JOIN #deal_detail dd ON dd.source_deal_header_id = md.source_deal_header_id
				WHERE md.link_id = @new_link_id AND dd.source_deal_header_id IS NULL

				UPDATE md SET
					md.matched_volume = ISNULL(dd.assigned_vol, dd.vol),
					md.[set] = dd.[set_id],
					md.update_user = @user_name,
					md.update_ts = GETDATE()
				FROM matching_detail md
				INNER JOIN (SELECT dd.source_deal_header_id, set_id, SUM(dd.assigned_vol) assigned_vol, MAX(t.vol) vol
							FROM #deal_detail dd 
							OUTER APPLY(SELECT SUM(assigned_vol) vol FROM #deal_detail) t
							GROUP BY dd.source_deal_header_id, set_id) dd ON dd.source_deal_header_id = md.source_deal_header_id
				WHERE md.link_id = @new_link_id AND md.matched_volume <> ISNULL(dd.assigned_vol, dd.vol)

				INSERT INTO matching_detail(
					[link_id],
					[source_deal_header_id],
					[matched_volume],
					[set],
					create_user,
					create_ts)
				SELECT 
					@new_link_id,
					dd.source_deal_header_id,
					ISNULL(SUM(assigned_vol), MAX(t.vol)) matched_vol,
					set_id,
					@user_name,
					GETDATE()
				FROM #deal_detail dd
				LEFT JOIN matching_detail md ON md.source_deal_header_id = dd.source_deal_header_id
					AND md.link_id = @new_link_id
				OUTER APPLY(SELECT SUM(assigned_vol) vol FROM #deal_detail) t
				WHERE md.source_deal_header_id IS NULL
				GROUP BY dd.source_deal_header_id, set_id

				UPDATE ad SET 
					ad.state_value_id = ISNULL(md.state_value_id, mds.state_value_id) ,
					ad.tier_value_id = ISNULL(md.tier_value_id, mds.tier_value_id)
				FROM #assigned_deals ad
				INNER JOIN #matching_detail md ON md.source_deal_detail_id = ad.source_deal_detail_id_from
				LEFT JOIN #matching_detail mds ON mds.source_deal_detail_id = ad.source_deal_detail_id

				UPDATE ad SET 
					ad.state_value_id = ISNULL(ad.state_value_id, mhdi.state_value_id),
					ad.tier_value_id = ISNULL(ad.tier_value_id, mhdi.tier_value_id)
				FROM #assigned_deals ad
				INNER JOIN matching_header_detail_info mhdi ON mhdi.source_deal_detail_id_from = ad.source_deal_detail_id_from
					AND mhdi.source_deal_detail_id = ad.source_deal_detail_id
				WHERE mhdi.link_id = @new_link_id

				IF OBJECT_ID(@DealsProductInfo) IS NOT NULL
				BEGIN
					EXEC('
						WITH proUpdate (rno, buy_detail_id)
						AS(
							select rno = row_number() over (partition by buy_detail_id order by buy_detail_id,sequence_from),
							buy_detail_id
							from ' + @DealsProductInfo + ' 
						)
						UPDATE ad SET
							ad.state_value_id = ISNULL(ad.state_value_id, pro.state_value_id),
							ad.tier_value_id = ISNULL(ad.tier_value_id,pro.tier_value_id)
						FROM #assigned_deals ad
						INNER JOIN ' + @DealsProductInfo + ' pro ON pro.buy_detail_id = ad.source_deal_detail_id_from
						INNER JOIN proUpdate pu ON pu.buy_detail_id = pro.buy_detail_id
						WHERE pu.rno = 1

						UPDATE ad SET
							ad.state_value_id = COALESCE(ad.state_value_id, ada.state_value_id, gc.state_value_id),
							ad.tier_value_id = COALESCE(ad.tier_value_id, ada.tier_value_id, gc.tier_type)
						FROM #assigned_deals ad
						INNER JOIN ' + @DealsProductInfo + ' ada ON ada.buy_detail_id = ad.source_deal_detail_id_from
						LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = ada.buy_detail_id
							AND ada.state_value_id = gc.state_value_id
							AND COALESCE(ada.tier_value_id, gc.tier_type, -1) = ISNULL(gc.tier_type, -1)')
				END

				IF EXISTS(SELECT 1 FROM #assigned_deals WHERE COALESCE(state_value_id, tier_value_id) IS NULL)
				BEGIN
					UPDATE ad SET 
						ad.state_value_id = gc.state_value_id,
						ad.tier_value_id = gc.tier_type
					FROM #assigned_deals ad
					INNER JOIN gis_certificate gc ON gc.source_deal_header_id = ad.source_deal_detail_id_from
					WHERE COALESCE(ad.state_value_id, ad.tier_value_id) IS NULL
				END

				--Deleting Certificate when deal removed from update screen
				DELETE gc
				FROM gis_certificate gc
				INNER JOIN matching_header_detail_info mhdi ON mhdi.source_deal_detail_id = gc.source_deal_header_id
					AND mhdi.source_deal_detail_id_from = gc.source_deal_header_id_from
					AND mhdi.state_value_id = gc.state_value_id
					AND mhdi.tier_value_id = gc.tier_type
				LEFT JOIN #assigned_deals ad ON ad.source_deal_header_id = mhdi.source_deal_header_id
					AND ad.source_deal_detail_id = mhdi.source_deal_detail_id
					AND ad.source_deal_header_id_from = mhdi.source_deal_header_id_from
					AND ad.source_deal_detail_id_from = mhdi.source_deal_detail_id_from
				WHERE ad.source_deal_header_id IS NULL AND mhdi.link_id = @new_link_id

				DELETE mhdi
				FROM matching_header_detail_info mhdi
				LEFT JOIN #assigned_deals ad ON ad.source_deal_header_id = mhdi.source_deal_header_id
					AND ad.source_deal_detail_id = mhdi.source_deal_detail_id
					AND ad.source_deal_header_id_from = mhdi.source_deal_header_id_from
					AND ad.source_deal_detail_id_from = mhdi.source_deal_detail_id_from
					AND ISNULL(mhdi.sequence_from, -1) = ISNULL(ad.sequence_from, -1)
				WHERE ad.source_deal_header_id IS NULL 
				AND mhdi.link_id = @new_link_id

				UPDATE mhdi SET
					mhdi.assigned_vol = ad.assigned_vol,
					mhdi.state_value_id = ad.state_value_id,
					mhdi.tier_value_id = ad.tier_value_id,
					mhdi.update_ts = GETDATE(),
					mhdi.update_user = @user_name,
					mhdi.vintage_yr = ad.vintage_yr,
					mhdi.expiration_dt = ad.expiration_dt
				FROM matching_header_detail_info mhdi
				INNER JOIN #assigned_deals ad ON ad.source_deal_header_id = mhdi.source_deal_header_id
					AND ad.source_deal_detail_id = mhdi.source_deal_detail_id
					AND ad.source_deal_header_id_from = mhdi.source_deal_header_id_from
					AND ad.source_deal_detail_id_from = mhdi.source_deal_detail_id_from
					AND ISNULL(mhdi.sequence_from, -1) = ISNULL(ad.sequence_from, -1)
				WHERE mhdi.link_id = @new_link_id

				INSERT INTO matching_header_detail_info(
					link_id,
					source_deal_header_id,
					source_deal_detail_id,
					source_deal_header_id_from,
					source_deal_detail_id_from,
					assigned_vol,
					state_value_id,
					tier_value_id,
					vintage_yr,
					expiration_dt,
					sequence_from,
					sequence_to,
					create_ts,
					create_user
					)
				SELECT @new_link_id,
					ad.source_deal_header_id,
					ad.source_deal_detail_id,
					ad.source_deal_header_id_from,
					ad.source_deal_detail_id_from,
					ad.assigned_vol,
					ad.state_value_id,
					ad.tier_value_id,
					ad.vintage_yr,
					ad.expiration_dt,
					ad.sequence_from,
					ad.sequence_to,
					GETDATE(),
					@user_name
				FROM #assigned_deals ad
				LEFT JOIN matching_header_detail_info mhdi ON mhdi.source_deal_header_id = ad.source_deal_header_id
					AND mhdi.source_deal_detail_id = ad.source_deal_detail_id
					AND mhdi.source_deal_header_id_from = ad.source_deal_header_id_from
					AND mhdi.source_deal_detail_id_from = ad.source_deal_detail_id_from
					AND ISNULL(mhdi.sequence_from, -1) = ISNULL(ad.sequence_from, -1)
					AND mhdi.link_id = @new_link_id 
				WHERE mhdi.source_deal_header_id IS NULL 

				UPDATE mda SET mda.header_audit_id = mha.audit_id
				FROM matching_detail_audit mda
				OUTER APPLY(SELECT MAX(audit_id) audit_id
							FROM matching_header_audit mha
							WHERE mha.link_id = mda.link_id) mha
				WHERE mda.link_id = @new_link_id 
				AND mda.header_audit_id IS NULL

				--Save data in assignment_audit and inserting certificate in gis_certificate
				--Start--
				SELECT @link_effective_dt = link_effective_date FROM matching_header WHERE link_id = @new_link_id

				IF @compliance_yr IS NULL
				SET @compliance_yr = YEAR(@link_effective_dt)

				INSERT INTO assignment_audit
					(
					assignment_type, 
					assigned_volume, 
					source_deal_header_id, 
					source_deal_header_id_from, 
					compliance_year, 
					state_value_id,
					assigned_date, 
					assigned_by, 
					tier, 
					org_assigned_volume,
					create_user,
					create_ts
					)
				SELECT DISTINCT
					5173 assignment_type, 
					assigned_vol, 
					source_deal_detail_id sale_detail_id,
					source_deal_detail_id_from rec_detail_id, 
					@compliance_yr, 
					state_value_id,
					dbo.FNAGetSQLStandardDate(@link_effective_dt), 
					dbo.FNADBUser(),
					tier_value_id, 
					[assigned_vol] org_assigned_volume,
					dbo.FNADBUser(),
					GETDATE()
				FROM matching_header_detail_info
				WHERE link_id = @new_link_id

				UPDATE mh 
					SET match_status = ISNULL([match_status], CASE WHEN sdd.volume_left > 0 THEN
					 27207 
									WHEN sdd.volume_left < 0 THEN 27209
								ELSE 27201 END),
					assignment_type = ISNULL([assignment_type], CASE WHEN ISNULL(sdh.product_classification, 10013) = 107400 THEN 5146 ELSE 10013 END)
				FROM matching_header mh
				INNER JOIN (SELECT DISTINCT link_id, source_deal_header_id,
							source_deal_detail_id
							FROM matching_header_detail_info
							WHERE link_id = @new_link_id) mhdi ON mhdi.link_id = mh.link_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = mhdi.source_deal_header_id 
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				AND sdd.source_deal_detail_id = mhdi.source_deal_detail_id
				WHERE mh.link_id = @new_link_id

				---End---
				----Ending of the logic--
				IF OBJECT_ID(@process_table) IS NOT NULL EXEC ('DROP TABLE ' + @process_table)

				SET @sql_stmt = 'CREATE TABLE ' + @process_table + ' ( 
									link_id INT
								)
							INSERT INTO ' + @process_table + '(link_id)
							VALUES(' + CAST(@new_link_id AS VARCHAR(20)) + ')'

				EXEC(@sql_stmt)
			
				EXEC spa_register_event 20616, 20553, @process_table, 1, @process_id

			IF OBJECT_ID(N'tempdb..#tmp_calc_status_from_auto_match', N'U') IS NOT NULL
			BEGIN
				INSERT INTO #tmp_calc_status_from_auto_match
				SELECT 
					'Success' AS ErrorCode
					, 'buysell_match' AS Module
					, 'spa_buy_sell_match' AS Area
					, 'Success' AS [Status]
					, 'Changes have been saved successfully.' AS [Message]
					, @new_link_id AS Recommendation
			END
			ELSE
			BEGIN
				SELECT 
					'Success' AS ErrorCode
					, 'buysell_match' AS Module
					, 'spa_buy_sell_match' AS Area
					, 'Success' AS [Status]
					, 'Changes have been saved successfully.' AS [Message]
					, @new_link_id AS Recommendation
			END
		   COMMIT TRAN
		   UPDATE matching_header SET link_description =  link_id WHERE link_description IS NULL
		END TRY
		BEGIN CATCH	
			IF @@TRANCOUNT > 0
            ROLLBACK
 
            SET @err_no = ERROR_NUMBER()
 
            IF ERROR_NUMBER() = 2627
            SET @DESC = 'Duplicate data in <b>Description</b>.'
            ELSE
            SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
            
 
            EXEC spa_ErrorHandler -1
            , 'deal_match'
            , 'spa_buy_sell_match'
            , 'Error'
            , @DESC
            , ''
		END CATCH
	
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRY
			BEGIN TRAN

			DECLARE @idoc2 INT
				EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xmlValue
			
				IF OBJECT_ID('tempdb..#temp_deal_match_header2') IS NOT NULL
					DROP TABLE #temp_deal_match_header2
		
				SELECT	
						--NULLIF(link_id, '')					[link_id],
						NULLIF([description], '')				[link_description],
						NULLIF(effective_date, '')				[link_effective_date],
						NULLIF(total_matched_volume, '')		[total_matched_volume],
						NULLIF(group1, '')						[group1],
						NULLIF(group2, '')						[group2],
						NULLIF(group3, '')						[group3],
						NULLIF(group4, '')						[group4],
						NULLIF(hedging_relationship_type, '')	[hedging_relationship_type],
						NULLIF(link_type, '')					[link_type],
						NULLIF(match_status, '')				[match_status]
				INTO #temp_deal_match_header2
				FROM OPENXML(@idoc2, '/Root/FormXML', 1)
				WITH (
					--link_id					INT,
					[description]		VARCHAR(1000),
					[effective_date]	datetime,
					[total_matched_volume]		FLOAT,
					[group1]				INT,
					[group2]				INT,
					[group3]				INT,
					[group4]				INT,
					[hedging_relationship_type]	INT,
					[link_type]				INT,
					[match_status]				INT
				)

				IF OBJECT_ID('tempdb..#temp_deal_match_detail2') IS NOT NULL
					DROP TABLE #temp_deal_match_detail2

				SELECT * INTO #temp_deal_match_detail2
				FROM   OPENXML(@idoc2, 'Root/Grid/GridRow', 3)
						WITH (
							source_deal_header_id INT '@source_deal_header_id',
							matched_volume NUMERIC(18,12) '@matched_volume',
							[set] CHAR(1) '@set'
						)
			
			update mh
				SET mh.[link_description] = isnull(nullif(th2.[link_description],''),@link_id)
					, mh.[link_effective_date] = th2.[link_effective_date]
					, mh.[total_matched_volume] = th2.[total_matched_volume]
					, mh.[group1] = th2.[group1]
					, mh.[group2] = th2.[group2]
					, mh.[group3] = th2.[group3]
					, mh.[group4] = th2.[group4]
					, mh.match_status = th2.match_status
			FROM
			matching_header AS mh
			inner join #temp_deal_match_header2 th2 on  1 = 1
			WHERE mh.link_id = @link_id

			update md
				SET md.matched_volume = tdmd.[matched_volume],
					md.[set] = tdmd.[set]
				FROM matching_detail md
				inner join #temp_deal_match_detail2 tdmd on md.source_deal_header_id = tdmd.source_deal_header_id
				WHERE md.link_id = @link_id

			DELETE
				md
			FROM
			matching_detail md
			LEFT JOIN #temp_deal_match_detail2 tdmd on md.source_deal_header_id = tdmd.source_deal_header_id
				WHERE md.link_id = @link_id AND tdmd.source_deal_header_id IS NULL
				
			EXEC spa_ErrorHandler 0
				, 'deal_match'
				, 'spa_buy_sell_match'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @link_id

		   COMMIT TRAN
		END TRY
		BEGIN CATCH	
			IF @@TRANCOUNT > 0
			ROLLBACK

			SET @DESC = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'

			SELECT @err_no = ERROR_NUMBER()

			EXEC spa_ErrorHandler @err_no
			, 'deal_match'
			, 'spa_buy_sell_match'
			, 'Error'
			, @DESC
			, ''

		END CATCH
	
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN

		DELETE gc 
		FROM matching_header_detail_info mhdi
		INNER JOIN gis_certificate gc ON gc.source_deal_header_id = mhdi.source_deal_detail_id
			AND gc.source_deal_header_id_FROM = mhdi.source_deal_detail_id_from
		WHERE mhdi.link_id = @link_id

		UPDATE sdh
		SET sdh.assignment_type_value_id = NULL
		FROM source_deal_header sdh
		INNER JOIN (SELECT DISTINCT source_deal_header_id 
					FROM matching_header_detail_info WHERE link_id = @link_id) mhdi ON mhdi.source_deal_header_id = sdh.source_deal_header_id

		UPDATE sdd SET
			[status] = ISNULL(t.[status], sdd.[status])
		FROM source_deal_detail sdd
		INNER JOIN matching_header_detail_info mhdi ON mhdi.source_deal_detail_id_from = sdd.source_deal_detail_id
		OUTER APPLY (SELECT TOP 1 sdda.status 
					FROM source_deal_detail_audit sdda 
					WHERE sdda.source_deal_detail_id = sdd.source_deal_detail_id ORDER BY sdda.audit_id DESC) t	
		WHERE mhdi.link_id = @link_id

		DELETE aa 
		FROM matching_header_detail_info mhdi
		INNER JOIN assignment_audit aa ON aa.source_deal_header_id = mhdi.source_deal_detail_id
			AND aa.source_deal_header_id_FROM = mhdi.source_deal_detail_id_from
		WHERE mhdi.link_id = @link_id

		DELETE FROM matching_header_detail_info WHERE link_id = @link_id

		DELETE FROM matching_detail where link_id = @link_id
		
		DELETE FROM matching_header where link_id = @link_id

		UPDATE mda SET mda.header_audit_id = mha.audit_id
		FROM matching_detail_audit mda
		OUTER APPLY(SELECT MAX(audit_id) audit_id
					FROM matching_header_audit mha
					WHERE mha.link_id = mda.link_id) mha
		WHERE mda.link_id = @link_id 
		AND mda.header_audit_id IS NULL
		
		EXEC spa_ErrorHandler 0
				, 'deal_match'
				, 'spa_buy_sell_match'
				, 'Success' 
				, 'Delete successfully.'
				, @link_id		 

		COMMIT TRAN
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT > 0
		ROLLBACK

		SET @DESC = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
		, 'deal_match'
		, 'spa_buy_sell_match'
		, 'Error'
		, @DESC
		, ''

	END CATCH
END

ELSE IF @flag = 'v'
BEGIN
	SET @sql_r = '
		SELECT source_deal_header_id, 
			MAX(pnl_as_of_date) pnl_as_of_date 
		INTO #temp_max_date_pnl1 
		FROM source_deal_pnl 
		GROUP BY source_deal_header_id

		SELECT 
			sdd.source_deal_header_id AS [Deal ID], 
			sdh.deal_id AS [Reference ID],
			scc.counterparty_name AS [Counterparty],
			sdv.code AS [Vintage Year],
			dbo.FNADateFormat(sdd.contract_expiration_date) AS [Expiration Date],
			dbo.FNADateFormat(sdd.term_start) AS [Term Start],
			dbo.FNADateFormat(sdd.term_end) AS [Term End],
			sdd.delivery_date AS [delivery_date],
			sdd.source_deal_detail_id AS [Detail ID],
			dbo.FNADateFormat(sdh.deal_date) AS [Deal Date],
			[dbo].[FNARemoveTrailingZeroes](ISNULL(sdd.deal_volume, 0)) AS [Actual Volume],
			0 AS [Matched],
			[dbo].[FNARemoveTrailingZeroes](ISNULL(sdd.volume_left, 0)-m.matched) AS [Remaining],
			[dbo].[FNARemoveTrailingZeroes](sdd.fixed_price) AS [Price],	
			[dbo].[FNARemoveTrailingZeroes](isnull(sdd.total_volume,0) * ABS(ISNULL(sdd.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))))) AS [Value],
			sdv_status.code [detail_status]
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = sdd.vintage
		LEFT JOIN static_data_value sdv_status ON sdv_status.value_id = sdd.status
		LEFT JOIN source_counterparty scc ON scc.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN source_commodity sc ON sc.source_commodity_id = sdh.commodity_id
		LEFT JOIN source_currency cur ON cur.source_currency_id = sdd.fixed_price_currency_id
		LEFT JOIN (
					SELECT sds.source_deal_header_id, 
						SUM(settlement_amount) settlement_amount,
						SUM(volume) sds_volume
					FROM source_deal_settlement sds 
					GROUP BY sds.source_deal_header_id) ds ON ds.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN (SELECT sdp.source_deal_header_id, 
						SUM(und_pnl_set) und_pnl_set,
						SUM(deal_volume) dp_volume
					FROM source_deal_pnl sdp 
					INNER JOIN #temp_max_date_pnl1 tmpnl 
						ON tmpnl.pnl_as_of_date = sdp.pnl_as_of_date
						AND tmpnl.source_deal_header_id = sdp.source_deal_header_id
					GROUP BY sdp.source_deal_header_id) dp ON dp.source_deal_header_id = sdh.source_deal_header_id
		OUTER APPLY(SELECT ISNULL(SUM(assigned_vol), 0) AS [matched] 
					FROM matching_header_detail_info mhdi 
					WHERE mhdi.source_deal_detail_id = sdd.source_deal_detail_id) m
		OUTER APPLY (
			SELECT uddf.udf_value [Technology_id], sdv1.code [Technology]
			FROM user_defined_deal_fields uddf
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id AND uddft.template_id = sdh.template_id
			INNER JOIN user_defined_fields_template udft ON uddft.udf_user_field_id = udft.udf_template_id
			INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_name AND uddft.field_name = sdv.value_id AND sdv.type_id = 5500 AND sdv.code = ''Technology'' 
			LEFT JOIN static_data_value sdv1 ON CAST(sdv1.value_id AS VARCHAR(20)) = uddf.udf_value
			WHERE sdh.source_deal_header_id = uddf.source_deal_header_id						
			) tech

		OUTER APPLY (
			SELECT uddf.udf_value [Country_id], sdv1.code [Country]
			FROM user_defined_deal_fields uddf
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id AND uddft.template_id = sdh.template_id
			INNER JOIN user_defined_fields_template udft ON uddft.udf_user_field_id = udft.udf_template_id
			INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_name AND uddft.field_name = sdv.value_id AND sdv.type_id = 5500 AND sdv.code = ''Country'' 
			LEFT JOIN static_data_value sdv1 ON CAST(sdv1.value_id AS VARCHAR(20)) = uddf.udf_value
			WHERE sdh.source_deal_header_id = uddf.source_deal_header_id							
			) country

		OUTER APPLY (
			SELECT uddf.udf_value [label_id], sdv1.code [label]
			FROM user_defined_deal_fields uddf
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id AND uddft.template_id = sdh.template_id
			INNER JOIN user_defined_fields_template udft ON uddft.udf_user_field_id = udft.udf_template_id
			INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_name AND uddft.field_name = sdv.value_id AND sdv.type_id = 5500 AND sdv.code = ''label'' 
			LEFT JOIN static_data_value sdv1 ON CAST(sdv1.value_id AS VARCHAR(20)) = uddf.udf_value
			WHERE sdh.source_deal_header_id = uddf.source_deal_header_id							
			) lab 
		WHERE 1 = 1 
		AND sdh.source_deal_header_id IN ('''+ @source_deal_header_id + ''') ' +
		CASE WHEN @ignore_source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id NOT IN ('+ @ignore_source_deal_header_id + ')' ELSE '' END 

	EXEC(@sql_r)
END

ELSE IF @flag = 'r'
BEGIN
	--IF @xmlValue IS NOT NULL
			/*-- header information */
		IF OBJECT_ID(N'tempdb..#collects_je_header') IS NOT NULL DROP TABLE #collects_je_header
		DECLARE @idoc1 INT
		
		EXEC sp_xml_preparedocument @idoc1 OUTPUT, @xmlValue
		
		SELECT delivery_date ,
			id		
		INTO #collects_je_header 
		FROM   OPENXML(@idoc1, '/Grid/GridRow', 2)
				WITH (
					delivery_date VARCHAR(20)	'@delivery_date',
					id	INT						'@id'
				)
				
		UPDATE mhd
		SET mhd.delivery_date  = CAST(cjh.delivery_date AS DATE)
			, mhd.transfer_status = 112102
			FROM matching_header_detail_info AS mhd 
			INNER JOIN  #collects_je_header AS cjh ON mhd.id = cjh.id
			--WHERE mhd.id = cjh.id
		
END 
