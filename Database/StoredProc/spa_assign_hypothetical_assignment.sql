

IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_assign_hypothetical_assignment]') AND [type] IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_assign_hypothetical_assignment]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_assign_hypothetical_assignment]
	@flag CHAR(1) = 'i',
	@table_name VARCHAR(100) = NULL,
	@deal_id VARCHAR(1000) = NULL,
	@assign_type INT = NULL,
	@compliance_yr INT = NULL,
	@group_id INT = NULL,
	@assign_state INT = NULL,
	@subsidiary VARCHAR(100) = NULL,
	@strategy VARCHAR(100) = NULL,
	@book VARCHAR(100) = NULL,
	@tier VARCHAR(100) = NULL,
	@technology_id INT  = NULL,
	@generator_id INT = NULL,
	@reference_id VARCHAR(100) = NULL,
	@vintage_id  DATETIME  = NULL,
	@display CHAR(1) = NULL,
	@gen_state_id INT = NULL,
	@group_gen_id INT = NULL,
	@book_deal_type_map_id VARCHAR(100)  = NULL,
	@select_all_deals INT = 0,
	@committed_recs_xml VARCHAR(MAX) = NULL,
	@rounding_option VARCHAR(1) = NULL,
	@commit_group_id INT = NULL,
	@selected_detail_deal_header_ids VARCHAR(MAX) = NULL,
	@commit_type CHAR(1) = NULL,
	@debug BIT = 0
AS

/**************************TEST CODE START************************				
DECLARE	@flag	CHAR(1)	=	'a'
DECLARE	@table_name	VARCHAR(100)	=	NULL
DECLARE	@deal_id	VARCHAR(1000)	=	NULL
DECLARE	@assign_type	INT	=	'5181'
DECLARE	@compliance_yr	INT	=	'2000'
DECLARE	@group_id	INT	=	NULL
DECLARE	@assign_state	INT	=	'309288'
DECLARE	@subsidiary	VARCHAR(100)	=	NULL
DECLARE	@strategy	VARCHAR(100)	=	NULL
DECLARE	@book	VARCHAR(100)	=	NULL
DECLARE	@tier	VARCHAR(100)	=	NULL
DECLARE	@technology_id	INT	=	NULL
DECLARE	@generator_id	INT	=	NULL
DECLARE	@reference_id	VARCHAR(100)	=	NULL
DECLARE	@vintage_id	DATETIME	=	NULL
DECLARE	@display	CHAR(1)	=	NULL
DECLARE	@gen_state_id	INT	=	NULL
DECLARE	@group_gen_id	INT	=	NULL
DECLARE	@book_deal_type_map_id	VARCHAR(100)	=	NULL
DECLARE	@select_all_deals	INT	=	NULL
DECLARE	@committed_recs_xml	VARCHAR(MAX)	=	NULL
DECLARE	@rounding_option	VARCHAR(1)	=	NULL
DECLARE	@commit_group_id	INT	= '12'	
DECLARE	@selected_detail_deal_header_ids	VARCHAR(MAX)	= NULL
DECLARE	@commit_type	CHAR(1)		=	'a'
DECLARE	@debug	BIT		
IF OBJECT_ID(N'tempdb..#temp_aggregated_deals', N'U') IS NOT NULL	DROP TABLE	#temp_aggregated_deals			
IF OBJECT_ID(N'tempdb..#temp_assignment_audit', N'U') IS NOT NULL	DROP TABLE	#temp_assignment_audit			
IF OBJECT_ID(N'tempdb..#temp_deleted_detail_assignment_deal_detail', N'U') IS NOT NULL	DROP TABLE	#temp_deleted_detail_assignment_deal_detail			
IF OBJECT_ID(N'tempdb..#temp_deleted_detail_assignment_deal_header', N'U') IS NOT NULL	DROP TABLE	#temp_deleted_detail_assignment_deal_header			
IF OBJECT_ID(N'tempdb..#temp_source_deal_detail_id', N'U') IS NOT NULL	DROP TABLE	#temp_source_deal_detail_id			
IF OBJECT_ID(N'tempdb..#temp_table_assignment', N'U') IS NOT NULL	DROP TABLE	#temp_table_assignment			
IF OBJECT_ID(N'tempdb..#ztbl_xml_value', N'U') IS NOT NULL	DROP TABLE	#ztbl_xml_value
	
SELECT @flag='f',@deal_id='43694',@commit_type='a'
--**************************TEST CODE END************************/				

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @sql_select VARCHAR(MAX) = ''
DECLARE @sql_from VARCHAR(MAX) = ''
DECLARE @sql_where VARCHAR(MAX) = ''
DECLARE @error_no INT
DECLARE @error_msg VARCHAR(8000) = ''
DECLARE @round TINYINT = 5
DECLARE @round_for_adjustment TINYINT = 2

IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 1 FROM hypothetical_assignment ha WHERE ha.hypo_group_id = @group_id AND (ha.assignment_type != @assign_type OR ha.assign_state != @assign_state OR ha.compliance_year != @compliance_yr))
	BEGIN
		EXEC spa_ErrorHandler -1, 'hypothetical_assignment table', 'spa_assign_hypothetical_assignment', 'DB Error', 'The selected hypothetical group is linked with another set of values of (Assignment Type, Assignment Juridiction, Compliance Year).', 'Failed Assigning deal'
		RETURN
	END
	
	INSERT INTO hypothetical_assignment(hypo_group_id, assignment_type, compliance_year, assign_state)
	VALUES (@group_id, @assign_type, @compliance_yr, @assign_state)
	
	EXEC spa_ErrorHandler 0, 'hypothetical_assignment table', 'spa_assign_hypothetical_assignment', 'Success', 'Successfully assigned deal to Hypothetical group.', 'Success Assigning deal'
END

IF @flag IN ('a', 'e', 'u', 'd')
BEGIN
	CREATE TABLE #temp_assignment_audit (
		assignment_id INT
		, detail_assign_deal_detail_id INT	--source_detal_detail_id of assignment deal created from detail deal (detal_assign_deal)
		, detail_deal_detail_id INT			--source_deal_detail_id of detail deal
		, agg_deal_header_id INT			--source_deal_header_id of aggregated deal
		, org_assigned_volume NUMERIC(38, 20)
		, assigned_volume NUMERIC(38, 20)
		, tier INT
		, state_value_id INT
		, assignment_type INT 
		, compliance_year INT 
		, commit_group_id INT
		, [committed] INT
	)
	
	
	IF @commit_type = 'a' 
	BEGIN
		SET @sql = '
		INSERT INTO #temp_assignment_audit (assignment_id, detail_assign_deal_detail_id, detail_deal_detail_id, agg_deal_header_id, org_assigned_volume, assigned_volume, tier, state_value_id, assignment_type, compliance_year, commit_group_id, [committed])
		SELECT aa.assignment_id, aa.source_deal_header_id, aa.source_deal_header_id_from
		, ' + (CASE WHEN @flag = 'd' THEN 'NULL agg_deal_header_id, NULL org_assigned_volume' 
					ELSE 'sdd_detail_recs.source_deal_header_id agg_deal_header_id, aa.org_assigned_volume' END) 
			+ ', aa.assigned_volume, aa.tier, aa.state_value_id, aa.assignment_type, aa.compliance_year, aa.compliance_group_id, aa.committed
		FROM assignment_audit aa
		' + (CASE WHEN @flag = 'd' THEN '' ELSE '
		INNER JOIN source_deal_detail sdd_detail_recs ON aa.source_deal_header_id_from = sdd_detail_recs.source_deal_detail_id
			' END) + '
		WHERE 1=1 --AND aa.[committed] = 1
			AND aa.assignment_type = ' + CAST(@assign_type AS VARCHAR(15)) + '
			AND aa.state_value_id = ' + CAST(@assign_state AS VARCHAR(15)) + '
			AND aa.compliance_year = ' + CAST(@compliance_yr AS VARCHAR(10))
	
	
	END
	ELSE 
	BEGIN
		SET @sql = '
		INSERT INTO #temp_assignment_audit (assignment_id, detail_assign_deal_detail_id, detail_deal_detail_id, agg_deal_header_id, org_assigned_volume, assigned_volume, tier, state_value_id, assignment_type, compliance_year, commit_group_id, [committed])
		SELECT aa.assignment_id, aa.source_deal_header_id, aa.source_deal_header_id_from
		, ' + (CASE WHEN @flag = 'd' THEN 'NULL agg_deal_header_id, NULL org_assigned_volume' 
					ELSE 'sdh_agg_offset.close_reference_id agg_deal_header_id, aa.org_assigned_volume' END) 
			+ ', aa.assigned_volume, aa.tier, aa.state_value_id, aa.assignment_type, aa.compliance_year, aa.compliance_group_id, aa.committed
		FROM assignment_audit aa
		' + (CASE WHEN @flag = 'd' THEN '' ELSE '
		INNER JOIN source_deal_detail sdd_detail_recs ON aa.source_deal_header_id_from = sdd_detail_recs.source_deal_detail_id
		INNER JOIN source_deal_header sdh_detail_recs ON sdh_detail_recs.source_deal_header_id = sdd_detail_recs.source_deal_header_id
		INNER JOIN source_deal_header sdh_agg_offset ON sdh_agg_offset.source_deal_header_id = sdh_detail_recs.close_reference_id
			' END) + '
		WHERE 1=1 -- AND aa.[committed] = 1
			AND aa.assignment_type = ' + CAST(@assign_type AS VARCHAR(15)) + '
			AND aa.state_value_id = ' + CAST(@assign_state AS VARCHAR(15)) + '
			AND aa.compliance_year = ' + CAST(@compliance_yr AS VARCHAR(10))
	
	
	END
	--IMP: source_deal_header_id AND source_deal_header_id_from in table assignment_audit actually stores deal detail ids.
	EXEC (@sql)
END

IF @flag IN ('a', 'e')
BEGIN
	--save aggregated deals and their aggregated volume
	SELECT sdd_agg.source_deal_header_id agg_deal_header_id
		, SUM(taa.org_assigned_volume) org_assigned_volume
		/*
		* To adjust rounding issues, CEILING and FLOOR are applied only when number is rounded to 2
		* , so that numbers like 26923.99999 becomes 26924 in both cases.
		* In case of ROUND, it is rounded to 0 decimal.
		* Same logic is used for adjusting numbers for display in grid.
		*/
		, (CASE @rounding_option
				WHEN 'n' THEN SUM(taa.assigned_volume)
				WHEN 'c' THEN CEILING(ROUND(SUM(taa.assigned_volume), @round_for_adjustment))
				WHEN 'f' THEN FLOOR(ROUND(SUM(taa.assigned_volume), @round_for_adjustment))
				WHEN 'r' THEN ROUND(SUM(taa.assigned_volume), 0)
			END) assigned_volume				--this is what is shown in grid (with rounding option applied if any)
	INTO #temp_aggregated_deals
	FROM #temp_assignment_audit taa
	INNER JOIN source_deal_detail sdd_agg ON sdd_agg.source_deal_header_id = taa.agg_deal_header_id
	GROUP BY sdd_agg.source_deal_header_id
	
	--add a new column to save assigned_volume prior to changing
	ALTER TABLE #temp_assignment_audit ADD assigned_volume_prev NUMERIC(38, 20)
	UPDATE #temp_assignment_audit SET assigned_volume_prev = assigned_volume
	
	IF @debug = 1
	BEGIN
		SELECT '#temp_aggregated_deals' tbl
		SELECT * FROM #temp_aggregated_deals
		
		SELECT '#temp_assignment_audit b4 updating volume' tbl
		SELECT * FROM #temp_assignment_audit taa ORDER BY taa.agg_deal_header_id, taa.detail_deal_detail_id
	END
	
	--update new committed volume to detail assigned deals by distributing the change in aggregated assigned volume due to rouding options in weighted fashion
	--TODO: play with precision, scale to fix truncation issue. For now, multiplication is done ahead of division to reduce chances of truncation.
	--If this doesn't fix the issue, using lesser (precision, scale) would be required before multiplication and division.
	--IF @rounding_option IN ('c', 'f', 'r')
	--BEGIN
	--	/*
	--	* Formula for volume distribution
	--	* 
	--	* New detail assigned volume	= (Ratio of detail to detail assign org assigned deal volume) * (Ratio of detail to aggregated org assigned deal volume) * New agg deal volume
	--	*								= (Org Assigned Deal Vol of Detail Assigned Deal / Org Assigned Deal Vol of Detail Deal) * (Org Assigned Deal Vol of Detail Deal / Org Deal Vol of Aggregated Deal) * New Committed Vol of Aggregated Deal (which is after applying rounding option)
	--	*								= (Org Assigned Deal Vol of Detail Assigned Deal * New Committed Vol of Aggregated Deal) / Org Assigned Deal Vol of Aggregated Deal
	--	*/
	--	UPDATE taa
	--	SET assigned_volume = (taa.org_assigned_volume * taggd.assigned_volume) / taggd.org_assigned_volume	--ratio for weighted volume distribution
	--	FROM #temp_assignment_audit taa
	--	INNER JOIN #temp_aggregated_deals taggd ON taggd.agg_deal_header_id = taa.agg_deal_header_id
		
	--	--select (taa.org_assigned_volume * taggd.assigned_volume) / taggd.org_assigned_volume,
	--	--taa.org_assigned_volume , taggd.assigned_volume , taggd.org_assigned_volume	--ratio for weighted volume distribution
	--	--, taa.assigned_volume
	--	--FROM #temp_assignment_audit taa
	--	--INNER JOIN #temp_aggregated_deals taggd ON taggd.agg_deal_header_id = taa.agg_deal_header_id
	--END
	
	IF @debug = 1
	BEGIN
		SELECT '#temp_assignment_audit after updating volume'
		SELECT * FROM #temp_assignment_audit taa ORDER BY taa.agg_deal_header_id, taa.detail_deal_detail_id
	END
	/*
	* Formula for detail deal volume_left
	* volume_left = volume_left + previously assigned volume (not originally assigned volume as multiple save can occur) - newly assigned volume
	* volume_left + previously assigned volume will bring back volume_left to its original value before commit. Deducting newly assigned volume 
	* will bring volume_left to actual value, which is volume_left after committ 
	*/
	
	/*
	* To adjust rounding issues, CEILING and FLOOR are applied only when number is rounded to 2
	* , so that numbers like 26923.99999 becomes 26924 in both cases.
	* In case of ROUND, it is rounded to 0 decimal.
	*/
	
	--min is required as multiple assigned deals created for different tiers for same deal reduces available volume
	--show 0 for -ve values as -ve values may appear due to rounding issues.
	
	--incase of aggregated deals, deduct whole assigned volume as aggregated deals are not updated prior to finalization
	
	--CASE WHEN @display = 'a' THEN ', MAX(gc.gis_certificate_number_from)  + '' to '' + CAST((CAST(SUBSTRING(MAX(gc.gis_certificate_number_from), LEN(MAX(gc.gis_certificate_number_from)) - CHARINDEX(''-'', REVERSE(MAX(gc.gis_certificate_number_from))) + 2, LEN(MAX(gc.gis_certificate_number_from))) AS FLOAT)+ dbo.FNARemoveTrailingZero(SUM(taa.assigned_volume)) - 1) AS VARCHAR) [Cert From/To]' 
	--ELSE '' END
	
	--don't put these columns in export
	SET @sql_select = '
		SELECT sdh.source_deal_header_id [Deal_ID]
				, MAX(sdh.deal_id) [Reference_ID]
				, MAX(sdv_tech.code) [Technology]
				, MAX(rg.[name]) [Generator]
				, dbo.FNADateFormat(MAX(sdh.entire_term_start)) [Vintage]
				, dbo.FNARemoveTrailingZero(ROUND(MAX(sdd.deal_volume), ' + CAST(@round AS VARCHAR(2)) + ')) [Deal_Volume]
				, dbo.FNARemoveTrailingZero(ROUND(' 
					+ CASE WHEN @display = 'd' THEN '
						CASE WHEN MIN(sdd.volume_left) + SUM(taa.assigned_volume_prev) - SUM(taa.assigned_volume) >= 0
						THEN MIN(sdd.volume_left) + SUM(taa.assigned_volume_prev) - SUM(taa.assigned_volume)
						ELSE CAST(0 AS NUMERIC(38, 20)) END'
					
					ELSE '
						CASE WHEN MIN(sdd.volume_left) >= SUM(taa.assigned_volume) 
						THEN CASE WHEN CAST(MIN(CAST(taa.committed AS INT)) AS BIT) = 1 THEN MIN(sdd.volume_left) - SUM(taa.assigned_volume)
						ELSE MIN(sdd.volume_left) END
						ELSE CAST(0 AS NUMERIC(38, 20)) END'
					END + '				
					, ' + CAST(@round AS VARCHAR(2)) + ')) [Available_Vol]
				
				, dbo.FNARemoveTrailingZero(' 
					+ CASE @display + @rounding_option 
							WHEN 'ac' THEN 'CEILING(ROUND(SUM(taa.assigned_volume), ' + CAST(@round_for_adjustment AS VARCHAR(2)) + '))' 
							WHEN 'af' THEN 'FLOOR(ROUND(SUM(taa.assigned_volume), ' + CAST(@round_for_adjustment AS VARCHAR(2)) + '))' 
							WHEN 'ar' THEN 'ROUND(SUM(taa.assigned_volume), 0)'
							ELSE 'ROUND(SUM(taa.assigned_volume), ' + CAST(@round AS VARCHAR(2)) + ')'
					  END + ') [Committed_Vol]
				, MAX(sub.entity_name) Subsidiary
				, MAX(stra.entity_name) Strategy
				, MAX(book.entity_name) Book 
				, MAX(ssbm.logical_name) [Sub_Book]
				, MAX(sdv_gen.code) [Gen_State]
				, MAX(sdv_assign_type.code)[Assignment_Type]
				, MAX(taa.compliance_year) [Compliance_Year]'
				+ CASE WHEN @flag <> 'e' THEN	
					', MAX(sub.entity_id) Subsidiary_id
					, MAX(stra.entity_id) Strategy_id
					, MAX(book.entity_id) Book_id
					, dbo.FNARemoveTrailingZero(ROUND(SUM(taa.org_assigned_volume), ' + CAST(@round AS VARCHAR(2)) + ')) [Initial_Committed_Vol]
					, dbo.FNARemoveTrailingZero(ROUND(SUM(taa.assigned_volume_prev), ' + CAST(@round AS VARCHAR(2)) + ')) [Previously_Committed_Vol]'
					ELSE
						CASE WHEN @display = 'a' THEN 
						', MAX(gc.gis_certificate_number_from) + '' to '' + SUBSTRING(MAX(gc.gis_certificate_number_to), LEN(MAX(gc.gis_certificate_number_to)) - CHARINDEX(''-'', REVERSE(MAX(gc.gis_certificate_number_to))) + 2, LEN(MAX(gc.gis_certificate_number_to))) [Cert From/To]' ELSE '' END 
					END + ',
					CASE WHEN MAX(taa.committed) = 0 THEN ROW_NUMBER() over(order by sdh.source_deal_header_id)-1 
					ELSE -1 END row_num,
					CASE WHEN MAX(taa.committed) = 1 THEN ROW_NUMBER() over(order by sdh.source_deal_header_id)-1 
					ELSE -1 END uncheck_row_num
				, taa.assignment_type [assignment_type_id]
				, rg.gen_state_value_id	
					'
	
	IF @display = 'd'
	BEGIN
		SET @sql_from = '
			--IMP:sdh here means detail deal.
			FROM #temp_assignment_audit taa
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = taa.detail_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			'
	END
	ELSE 
	BEGIN
		SET @sql_from = '
			--sdh here means aggregated deal
			FROM #temp_assignment_audit taa
			INNER JOIN source_deal_detail sdd_detail_recs ON taa.detail_assign_deal_detail_id = sdd_detail_recs.source_deal_detail_id
			INNER JOIN source_deal_header sdh_detail_recs ON sdh_detail_recs.source_deal_header_id = sdd_detail_recs.source_deal_header_id
			INNER JOIN source_deal_header sdh_agg_offset ON sdh_agg_offset.source_deal_header_id = sdh_detail_recs.close_reference_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdh_agg_offset.source_deal_header_id
			--INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = taa.agg_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			'
	END
	
	SET @sql_from = @sql_from + 
		'
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN static_data_value sdv_tech ON sdv_tech.value_id = rg.technology
			INNER JOIN static_data_value sdv_gen ON sdv_gen.value_id = rg.gen_state_value_id
			INNER JOIN static_data_value sdv_assign_type ON sdv_assign_type.value_id = taa.assignment_type
			INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
			LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
			LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
			LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
			WHERE 1 = 1
		'

	IF @commit_group_id IS NOT NULL
		SET @sql_where = @sql_where + ' AND taa.commit_group_id = ' + CAST(@commit_group_id AS VARCHAR(10))
	
	IF @deal_id IS NOT  NULL
		SET @sql_where = @sql_where + ' AND sdh.source_deal_header_id = ' + CAST(@deal_id AS VARCHAR(10))
	
	IF @reference_id IS NOT NULL
		SET @sql_where = @sql_where + ' AND sdh.deal_id LIKE ''' + @reference_id + ''''
	
	IF @generator_id IS NOT NULL 
		SET @sql_where =  @sql_where + ' AND sdh.generator_id = ' + CAST(@generator_id AS VARCHAR(10))
	
	IF @vintage_id IS NOT NULL
		SET @sql_where = @sql_where + ' AND YEAR(sdh.entire_term_start)= ' + CAST(YEAR(@vintage_id)  AS VARCHAR(10)) 
						+ ' AND  MONTH(sdh.entire_term_start)= ' + CAST (MONTH(@vintage_id) AS VARCHAR(10))
	
	IF @book IS NOT NULL
		SET @sql_where = @sql_where + ' AND book.entity_id IN ( ' + @book  + ')'
	IF @subsidiary IS NOT NULL
		SET @sql_where = @sql_where + ' AND sub.entity_id IN ( ' + @subsidiary + ')'
	IF @strategy IS NOT NULL
		SET @sql_where = @sql_where + ' AND stra.entity_id IN ( ' + @strategy + ')'
		
	IF @technology_id IS NOT NULL
		SET @sql_where = @sql_where + ' AND sdv_tech.value_id = ' + CAST(@technology_id AS VARCHAR(10))
	IF @gen_state_id IS NOT NULL
		SET @sql_where = @sql_where + ' AND rg.gen_state_value_id = ' + CAST(@gen_state_id AS VARCHAR(10))
	IF @group_gen_id IS NOT NULL
		SET @sql_where = @sql_where + ' AND rg.generator_group_name = ' + CAST(@group_gen_id AS VARCHAR(10))
	IF @book_deal_type_map_id IS NOT NULL
		SET @sql_where = @sql_where + ' AND ssbm.book_deal_type_map_id  IN (' + CAST(@book_deal_type_map_id AS VARCHAR(25)) + ')'
		
	SET @sql = @sql_select + @sql_from + @sql_where + ' GROUP BY sdh.source_deal_header_id , taa.assignment_type, rg.gen_state_value_id	'
	
	EXEC (@sql)	

END

IF @flag = 'f'
BEGIN
	BEGIN TRAN
	BEGIN TRY 	
		IF @commit_type = 'a'
		BEGIN
			DECLARE @process_table VARCHAR(300),@user_login_id VARCHAR(100), @process_id VARCHAR(100)

			SET @user_login_id = dbo.FNADBUser()
			SET @process_id = dbo.FNAGetNewID()
			SET @process_table = dbo.FNAProcessTableName('process_table', @user_login_id, @process_id)

			SET @sql = '
				CREATE TABLE ' + @process_table + '( 
					[ID] INT,
					[Volume Assign] FLOAT, 
					[cert_from] INT, 
					[cert_to] INT, 
					uom INT, 
					deal_volume_uom_id INT, 
					compliance_year VARCHAR(1000), 
					tier_value_id INT, 
					jurisdiction_state_id INT
				)'
		
			EXEC(@sql)

			SET @sql = '
			INSERT INTO ' + @process_table + ' ([ID], [Volume Assign], [cert_from], [cert_to], uom, deal_volume_uom_id, compliance_year, tier_value_id, jurisdiction_state_id) 
			SELECT MAX(sdd.source_deal_detail_id) source_deal_detail_id, 
				   SUM(aa.assigned_volume) assigned_volume, 
				   1, 
				   SUM(aa.assigned_volume) assigned_volume,
				   MAX(sdd.deal_volume_uom_id) uom, 
				   MAX(sdd.deal_volume_uom_id) deal_volume_uom_id, 
				   ' + CAST(@compliance_yr AS VARCHAR)+ ', 
				   MAX(aa.Tier) tier, 
				   MAX(aa.state_value_id) state_value_id
			FROM source_deal_header sdh 
			INNER JOIN source_deal_detail sdd 
				ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN dbo.SplitCommaSeperatedValues(''' + @deal_id + ''') scsv 
				ON scsv.item = sdh.source_deal_header_id
			INNER JOIN source_deal_header sdh_offset 
				ON sdh.source_deal_header_id = sdh_offset.close_reference_id
			INNER JOIN source_deal_header sdh_allocated 
				ON sdh_offset.source_deal_header_id = sdh_allocated.close_reference_id
			INNER JOIN source_deal_detail sdd_allocated 
				ON sdd_allocated.source_deal_header_id = sdh_allocated.source_deal_header_id
			INNER JOIN assignment_audit aa 
				ON aa.source_deal_header_id_from = sdd_allocated.source_deal_detail_id
			WHERE aa.committed = 1
			'
		
			EXEC(@sql)
		
			DECLARE @assigned_date DATETIME
		
			SELECT @assigned_date = dbo.FNAStdDate(CAST('12-31-' + CAST(@compliance_yr AS VARCHAR(10)) AS DATETIME))
			
			EXEC spa_assign_rec_deals @assignment_type = @assign_type, 
									  @assigned_state = @assign_state, 
									  @compliance_year = @compliance_yr, 
									  @assigned_date = @assigned_date, 
									  @table_name = @process_table, 
									  @unassign = 0, 
									  @select_all_deals = 0,
									  @committed = 0,
									  @commit_type = @commit_type

			UPDATE aa 
			SET aa.[committed] = 0
			FROM source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) scsv on scsv.item = sdh.source_deal_header_id
			INNER JOIN source_deal_header sdh_offset ON sdh.source_deal_header_id = sdh_offset.close_reference_id
			INNER JOIN source_deal_header sdh_allocated ON sdh_offset.source_deal_header_id = sdh_allocated.close_reference_id
			INNER JOIN source_deal_detail sdd_allocated ON sdd_allocated.source_deal_header_id = sdh_allocated.source_deal_header_id
			INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd_allocated.source_deal_detail_id
		
			UPDATE sdh 
			SET sdh.deal_locked = 'y'
			FROM source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) scsv on scsv.item = sdh.source_deal_header_id
		
			UPDATE sdh_allocated 
			SET sdh_allocated.deal_locked = 'y'
			FROM source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) scsv on scsv.item = sdh.source_deal_header_id
			INNER JOIN source_deal_header sdh_offset ON sdh.source_deal_header_id = sdh_offset.close_reference_id
			INNER JOIN source_deal_header sdh_allocated ON sdh_offset.source_deal_header_id = sdh_allocated.close_reference_id
			INNER JOIN source_deal_detail sdd_allocated ON sdd_allocated.source_deal_header_id = sdh_allocated.source_deal_header_id
			INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd_allocated.source_deal_detail_id
		END
		ELSE
		BEGIN
			UPDATE aa 
			SET aa.[committed] = 0
			FROM source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) scsv on scsv.item = sdh.source_deal_header_id
			--INNER JOIN source_deal_header sdh_offset ON sdh.source_deal_header_id = sdh_offset.close_reference_id
			--INNER JOIN source_deal_header sdh_allocated ON sdh_offset.source_deal_header_id = sdh_allocated.close_reference_id
			--INNER JOIN source_deal_detail sdd_allocated ON sdd_allocated.source_deal_header_id = sdh_allocated.source_deal_header_id
			INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
		
			UPDATE sdh 
			SET sdh.deal_locked = 'y'
			FROM source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) scsv on scsv.item = sdh.source_deal_header_id
			--INNER JOIN source_deal_header sdh_offset ON sdh.source_deal_header_id = sdh_offset.close_reference_id
			--INNER JOIN source_deal_header sdh_allocated ON sdh_offset.source_deal_header_id = sdh_allocated.close_reference_id
			--INNER JOIN source_deal_detail sdd_allocated ON sdd_allocated.source_deal_header_id = sdh_allocated.source_deal_header_id
			INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
		END
		COMMIT
	
		EXEC spa_ErrorHandler 0, 'hypothetical_assignment table', 'spa_assign_hypothetical_assignment', 'Success', 'Successfully finalized selected deal.', 'Success Finalizing deal'
	
	END TRY
	BEGIN CATCH
		ROLLBACK
		EXEC spa_ErrorHandler -1, 'hypothetical_assignment table', 'spa_assign_hypothetical_assignment', 'Failure', 'Finalizing deal failed.', 'Finalizing deal failed'
	END CATCH
END

IF @flag = 's'
BEGIN
	SELECT aa.assignment_type, aa.state_value_id, MAX(sdv_assign_type.code) [Assignment Type], MAX(sdv_assign_state.code) [Jurisdiction]
		, compliance_year [Compliance Year], dbo.FNADateFormat(ISNULL(MAX(aa.update_ts), MAX(aa.create_ts))) [Last Updated Date] 
	FROM assignment_audit aa
	LEFT JOIN static_data_value sdv_assign_type ON sdv_assign_type.value_id = aa.assignment_type
	LEFT JOIN static_data_value sdv_assign_state ON sdv_assign_state.value_id = aa.state_value_id
	WHERE aa.[committed] = 1
	GROUP BY aa.assignment_type, aa.state_value_id, compliance_year 
END

IF @flag = 'd'
BEGIN


	BEGIN TRY
		BEGIN TRANSACTION
		
		IF OBJECT_ID('tempdb..#temp_source_deal_detail_id') IS NOT NULL
			DROP TABLE #temp_source_deal_detail_id
		
		SELECT sdd_detail.source_deal_detail_id
		INTO #temp_source_deal_detail_id
		FROM dbo.SplitCommaSeperatedValues(@selected_detail_deal_header_ids) scsv
		INNER JOIN source_deal_detail sdd_detail ON sdd_detail.source_deal_header_id = scsv.item
		
		IF EXISTS(SELECT  1 FROM  assignment_audit aa 
		INNER JOIN #temp_source_deal_detail_id tddadd ON tddadd.source_deal_detail_id = aa.source_deal_header_id_from
		WHERE aa.committed = 0)
		BEGIN
			SET @error_msg = 'Deal has already been finalized'
			EXEC spa_ErrorHandler -1, 'hypothetical_assignment table', 
			'spa_assign_hypothetical_assignment', 'Error', @error_msg, 'Error deleting committed recs.'	
			ROLLBACK	
			RETURN
		END
		
		--add the committed detail assgined deal_volume in volume left of detail deal (detail recs)
		--update detail deal volume left
		UPDATE sdd_detail
		SET volume_left = ISNULL(volume_left, 0) + rs_assign.assigned_volume
		FROM dbo.SplitCommaSeperatedValues(@selected_detail_deal_header_ids) scsv
		INNER JOIN source_deal_detail sdd_detail ON sdd_detail.source_deal_header_id = scsv.item
		CROSS APPLY (
			--take updated volume from assignment_audit, not from #temp_assignment_audit
			SELECT SUM(aa.assigned_volume) assigned_volume
			FROM #temp_assignment_audit taa
			INNER JOIN assignment_audit aa ON aa.assignment_id = taa.assignment_id
			WHERE taa.detail_deal_detail_id = sdd_detail.source_deal_detail_id
		) rs_assign
		WHERE rs_assign.assigned_volume IS NOT NULL	--prevent updating for unchanged rows
		
	
			--save detail assignment deals to delete later, as audit should be deleted first before detail assignment deals
		SELECT taa.detail_assign_deal_detail_id
		INTO #temp_deleted_detail_assignment_deal_detail
		FROM dbo.SplitCommaSeperatedValues(@selected_detail_deal_header_ids) scsv
		INNER JOIN source_deal_detail sdd_detail ON sdd_detail.source_deal_header_id = scsv.item
		INNER JOIN #temp_assignment_audit taa ON taa.detail_deal_detail_id = sdd_detail.source_deal_detail_id
		
		--select * from #temp_assignment_audit
		
		--delete entries from assignment audit
		DELETE aa
		--limit search to combination (juridisction, assignment_type and complaince_year)
		FROM #temp_assignment_audit taa 
		INNER JOIN assignment_audit aa ON aa.assignment_ID = taa.assignment_id
		INNER JOIN source_deal_detail sdd_detail ON sdd_detail.source_deal_detail_id = aa.source_deal_header_id_from 
		INNER JOIN dbo.SplitCommaSeperatedValues(@selected_detail_deal_header_ids) scsv ON scsv.item = sdd_detail.source_deal_header_id
		
		--delete detail UDF
		DELETE udddf 
		FROM user_defined_deal_detail_fields udddf
		INNER JOIN #temp_deleted_detail_assignment_deal_detail tddadd ON tddadd.detail_assign_deal_detail_id = udddf.source_deal_detail_id
		
		--delete gis_certificate
		DELETE gis 
		FROM Gis_Certificate gis
		--IMP:gis_certificate.source_deal_header_id references to source_deal_detail_id
		INNER JOIN #temp_deleted_detail_assignment_deal_detail tddadd ON tddadd.detail_assign_deal_detail_id = gis.source_deal_header_id
		
		CREATE TABLE #temp_deleted_detail_assignment_deal_header (detail_assign_deal_header_id INT)
		--delete assignment deal detail
		DELETE sdd
		OUTPUT DELETED.source_deal_header_id INTO #temp_deleted_detail_assignment_deal_header (detail_assign_deal_header_id)
		FROM source_deal_detail sdd
		INNER JOIN #temp_deleted_detail_assignment_deal_detail tddad ON tddad.detail_assign_deal_detail_id = sdd.source_deal_detail_id
		
		--delete header UDF
		DELETE uddf
		FROM user_defined_deal_fields uddf
		INNER JOIN #temp_deleted_detail_assignment_deal_header tddadh ON tddadh.detail_assign_deal_header_id = uddf.source_deal_header_id
		
		--delete assignment deal header
		DELETE sdh
		FROM source_deal_header sdh
		INNER JOIN #temp_deleted_detail_assignment_deal_header tddadh ON tddadh.detail_assign_deal_header_id = sdh.source_deal_header_id		

		--Don't use spa_ErrorHandler as we need to persist the messagebox		
		--EXEC spa_ErrorHandler 0, 'hypothetical_assignment table', 
		--	'spa_assign_hypothetical_assignment', 'Success', 'Successfully deleted committed recs from hypothetical group.', 'Success deleting committed recs.'
		SELECT  'Deleted' ErrorCode, 'Hypothetical Assignment' Module, 'spa_assign_hypothetical_assignment' [Area]
			, 'Success' [Status], 'Successfully deleted committed recs.' [Message], '' [Recommendation]
		
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		
		SET @error_no = ERROR_NUMBER()
		SET @error_msg = ERROR_MESSAGE()
		PRINT 'Catch Error:' + CAST(@error_no AS VARCHAR(10)) + ' - ' + @error_msg
		
		SET @error_msg = 'Error in deleting committed recs from hypothetical group. (' + @error_msg + ')'
		
		EXEC spa_ErrorHandler @error_no, 'hypothetical_assignment table', 
			'spa_assign_hypothetical_assignment', 'Error', @error_msg, 'Error deleting committed recs.'		
	END CATCH
END

IF @flag = 'x'
BEGIN
	CREATE TABLE #temp_table_assignment(id INT IDENTITY(1,1),[Deal ID] INT, [Reference ID] VARCHAR(1000) COLLATE DATABASE_DEFAULT , [Techonology] VARCHAR(1000) COLLATE DATABASE_DEFAULT , Generator VARCHAR(1000) COLLATE DATABASE_DEFAULT , Vintage VARCHAR(1000) COLLATE DATABASE_DEFAULT , [Deal Volume] FLOAT, [Available Vol] FLOAT, [Committed Vol] NUMERIC(38,20), Subsidiary VARCHAR(500) COLLATE DATABASE_DEFAULT , Strategy VARCHAR(500) COLLATE DATABASE_DEFAULT , Book VARCHAR(500) COLLATE DATABASE_DEFAULT , [Sub Book] VARCHAR(500) COLLATE DATABASE_DEFAULT , [Gen State] VARCHAR(500) COLLATE DATABASE_DEFAULT , [Assignment Type] VARCHAR(500) COLLATE DATABASE_DEFAULT , [Compliance Year] INT, [Cert-FromTo] VARCHAR(1000) COLLATE DATABASE_DEFAULT )
	
	INSERT INTO #temp_table_assignment([Deal ID], [Reference ID], [Techonology], Generator, Vintage, [Deal Volume], [Available Vol], [Committed Vol], Subsidiary, Strategy, Book, [Sub Book], [Gen State], [Assignment Type], [Compliance Year], [Cert-FromTo] )
	EXEC spa_assign_hypothetical_assignment 'e' ,@table_name , @deal_id , @assign_type, @compliance_yr , @group_id , @assign_state , @subsidiary , @strategy , @book , @tier, @technology_id , @generator_id , @reference_id , @vintage_id , @display , @gen_state_id , @group_gen_id , @book_deal_type_map_id, @select_all_deals , @committed_recs_xml , @rounding_option , @selected_detail_deal_header_ids

	DECLARE @aaa varchar(max)
	
	SELECT @aaa=isnull(@aaa,'')+
	r1.col 
	FROM 
	(
		SELECT --rg.code,
		 tta.id row_id 
		FROM #temp_table_assignment tta
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tta.[Deal ID]
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	) b
	OUTER APPLY ( 
		SELECT (
				SELECT ([Cert-FromTo]) AS certificateSerialNumber, 
				dbo.FNARemoveTrailingZero([Committed Vol]) AS quantity
				FROM #temp_table_assignment tta
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tta.[Deal ID]
				INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
				WHERE tta.id = b.row_id
				FOR 
				XML PATH(''),
				TYPE 
				) 
		FOR XML PATH (''),
		ROOT('certificate') 
	) r1(col)
	select '<certificates>' + @aaa + '</certificates>' [certificates]
	
END

IF @flag = 'u'	--Saves committed deals with updated assigned volume
BEGIN

	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @committed_recs_xml
	
	SELECT 
		source_deal_header_id
		, dbo.FNAStdDate(vintage) vintage		
		, new_committed_vol AS new_assigned_volume
		, initial_committed_volume AS org_assigned_volume
	INTO #ztbl_xml_value
	FROM OPENXML (@idoc, '/Root/PSRecordset', 2)
		 WITH ( 
			source_deal_header_id INT '@source_deal_header_id'
			, vintage VARCHAR(20) '@vintage'
			, new_committed_vol NUMERIC(38, 20) '@new_committed_vol'
			, initial_committed_volume NUMERIC(38, 20) '@initial_committed_volume'
		 )
	
	EXEC sp_xml_removedocument @idoc
	
	--SELECT  * FROM  #ztbl_xml_value
	
	IF @commit_type = 'a'
	BEGIN
		IF EXISTS (SELECT sdd.volume_left - (zxv_agg.new_assigned_volume - taa.assigned_volume)
			FROM #ztbl_xml_value zxv_agg
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = zxv_agg.source_deal_header_id
				AND sdd.term_start = zxv_agg.vintage
			LEFT JOIN #temp_assignment_audit taa on taa.detail_deal_detail_id = sdd.source_deal_detail_id
			WHERE sdd.volume_left + 0.1 - (zxv_agg.new_assigned_volume - taa.assigned_volume) < 0 )
	BEGIN
		SET @error_msg = 'New committed volume exceeds maximum allowed volume.'
		EXEC spa_ErrorHandler -1, 'hypothetical_assignment table', 
			'spa_assign_hypothetical_assignment', 'Error', @error_msg, 'Error saving committed recs.'	
		RETURN
	END
	END
	ELSE
	BEGIN  --select * from #temp_assignment_audit
		IF  EXISTS (SELECT sdd_detail.volume_left - ((rga.auto_assignment_per * zxv_agg.new_assigned_volume) - taa.assigned_volume)
		--select *
			FROM #ztbl_xml_value zxv_agg
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = zxv_agg.source_deal_header_id
			INNER JOIN source_deal_header sdh_agg_offset ON sdh_agg_offset.close_reference_id = zxv_agg.source_deal_header_id
			INNER JOIN source_deal_header sdh_detail ON sdh_detail.close_reference_id = sdh_agg_offset.source_deal_header_id
			INNER JOIN source_deal_detail sdd_detail ON sdd_detail.source_deal_header_id = sdh_detail.source_deal_header_id
				AND sdd_detail.term_start = zxv_agg.vintage
			INNER JOIN rec_generator rg ON rg.generator_id = sdh_detail.generator_id
			LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
				AND rga.counterparty_id = sdh_agg_offset.counterparty_id
			LEFT JOIN #temp_assignment_audit taa on taa.detail_deal_detail_id = sdd_detail.source_deal_detail_id
			WHERE sdd_detail.volume_left + 0.1 - ((rga.auto_assignment_per * zxv_agg.new_assigned_volume) - taa.assigned_volume) < 0 )
		BEGIN
		SET @error_msg = 'New committed volume exceeds maximum allowed volume.'
		EXEC spa_ErrorHandler -1, 'hypothetical_assignment table', 
			'spa_assign_hypothetical_assignment', 'Error', @error_msg, 'Error saving committed recs.'	
		RETURN
	END
	END
	
	BEGIN TRY
		BEGIN TRANSACTION
	
		--update new committed volume to detail assigned deals by distributing the change in aggregated assigned volume due to rouding options in weighted fashion
		/*
		* Formula for volume distribution
		* 
		* New detail assigned volume	= (Ratio of detail to detail assign org assigned deal volume) * (Ratio of detail to aggregated org assigned deal volume) * New agg deal volume
		*								= (Org Assigned Deal Vol of Detail Assigned Deal / Org Assigned Deal Vol of Detail Deal) * (Org Assigned Deal Vol of Detail Deal / Org Deal Vol of Aggregated Deal) * New Committed Vol of Aggregated Deal (which is after applying rounding option)
		*								= (Org Assigned Deal Vol of Detail Assigned Deal * New Committed Vol of Aggregated Deal) / Org Assigned Deal Vol of Aggregated Deal
		*/
		--TODO: Can we prevent updating unchanged rows?
		
		--select (taa.org_assigned_volume * ( zxv_agg.new_assigned_volume)) / zxv_agg.org_assigned_volume	--ratio for weighted volume distribution
		--,taa.org_assigned_volume ,  zxv_agg.new_assigned_volume , zxv_agg.org_assigned_volume
		IF @commit_type = 'a'
		BEGIN
			UPDATE aa
			SET assigned_volume = zxv_agg.new_assigned_volume
			--select *
			FROM #temp_assignment_audit taa
			INNER JOIN assignment_audit aa ON aa.assignment_id = taa.assignment_id
			INNER JOIN #ztbl_xml_value zxv_agg ON zxv_agg.source_deal_header_id = taa.agg_deal_header_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = zxv_agg.source_deal_header_id
			WHERE zxv_agg.new_assigned_volume <> zxv_agg.org_assigned_volume
		END 
		ELSE
		BEGIN
			UPDATE aa
			SET assigned_volume = 
			zxv_agg.new_assigned_volume * rga.auto_assignment_per 
			--select *
			FROM #temp_assignment_audit taa
			INNER JOIN assignment_audit aa ON aa.assignment_id = taa.assignment_id
			INNER JOIN #ztbl_xml_value zxv_agg ON zxv_agg.source_deal_header_id = taa.agg_deal_header_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = zxv_agg.source_deal_header_id
			INNER JOIN source_deal_detail sdd_allocated ON sdd_allocated.source_deal_detail_id = taa.detail_deal_detail_id
			INNER JOIN source_deal_header sdh_allocated ON sdh_allocated.source_deal_header_id =  sdd_allocated.source_deal_header_id
			INNER JOIN source_deal_header sdh_offset ON sdh_offset.source_deal_header_id = sdh_allocated.close_reference_id
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
				AND rga.counterparty_id = sdh_offset.counterparty_id
			WHERE zxv_agg.new_assigned_volume <> zxv_agg.org_assigned_volume
		END
				
		--update detail assignment deal volume to match with audit volume
		UPDATE sdd_assign
		--take updated volume from assignment_audit, not from #temp_assignment_audit
		SET deal_volume = aa.assigned_volume
		FROM #temp_assignment_audit taa
		INNER JOIN assignment_audit aa ON aa.assignment_id = taa.assignment_id
		INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_detail_id = taa.detail_assign_deal_detail_id
		WHERE sdd_assign.deal_volume <> aa.assigned_volume	--prevent updating unchanged rows
		
		--update detail deal volume left
		/*
		* Formula for detail deal volume_left
		* volume_left = volume_left + previously assigned volume (not originally assigned volume as multiple save can occuer) - newly assigned volume
		* volume_left + previously assigned volume will bring back volume_left to its original value before commit. Deducting newly assigned volume 
		* will bring volume_left to actual value, which is volume_left after committ 
		*/
		
		--select * from #temp_assignment_audit
		
		IF @commit_type = 'a'
		BEGIN 
			UPDATE sdd_detail
			SET volume_left = (volume_left + rs_assign.assigned_volume_prev - zxv_agg.new_assigned_volume)
			FROM #ztbl_xml_value zxv_agg
			INNER JOIN source_deal_detail sdd_detail ON sdd_detail.source_deal_header_id = zxv_agg.source_deal_header_id
				--TODO: confirm on this join condition
				AND sdd_detail.term_start = zxv_agg.vintage
			OUTER APPLY (
				--take updated volume from assignment_audit, not from #temp_assignment_audit
				SELECT SUM(aa.org_assigned_volume) org_assigned_volume, SUM(aa.assigned_volume) assigned_volume, SUM(taa.assigned_volume) assigned_volume_prev
				FROM #temp_assignment_audit taa
				INNER JOIN assignment_audit aa ON aa.assignment_id = taa.assignment_id
				WHERE taa.detail_deal_detail_id = sdd_detail.source_deal_detail_id
			) rs_assign
			WHERE ISNULL(zxv_agg.new_assigned_volume, 0) <> ISNULL(rs_assign.assigned_volume_prev, 0)
			AND zxv_agg.new_assigned_volume <> zxv_agg.org_assigned_volume
			
		END
		ELSE
		BEGIN
			UPDATE sdd_detail
			SET volume_left = (volume_left + rs_assign.assigned_volume_prev - (rga.auto_assignment_per * zxv_agg.new_assigned_volume))
			FROM #ztbl_xml_value zxv_agg
			INNER JOIN source_deal_header sdh_agg_offset ON sdh_agg_offset.close_reference_id = zxv_agg.source_deal_header_id
			INNER JOIN source_deal_header sdh_detail ON sdh_detail.close_reference_id = sdh_agg_offset.source_deal_header_id
			INNER JOIN source_deal_detail sdd_detail ON sdd_detail.source_deal_header_id = sdh_detail.source_deal_header_id
				--TODO: confirm on this join condition
				AND sdd_detail.term_start = zxv_agg.vintage
			INNER JOIN rec_generator rg ON rg.generator_id = sdh_detail.generator_id
			LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
				AND rga.counterparty_id = sdh_agg_offset.counterparty_id
			OUTER APPLY (
				--take updated volume from assignment_audit, not from #temp_assignment_audit
				SELECT SUM(aa.org_assigned_volume) org_assigned_volume, SUM(aa.assigned_volume) assigned_volume, SUM(taa.assigned_volume) assigned_volume_prev
				FROM #temp_assignment_audit taa
				INNER JOIN assignment_audit aa ON aa.assignment_id = taa.assignment_id
				WHERE taa.detail_deal_detail_id = sdd_detail.source_deal_detail_id
			) rs_assign
			WHERE ISNULL(zxv_agg.new_assigned_volume, 0) <> ISNULL(rs_assign.assigned_volume_prev, 0)
			AND zxv_agg.new_assigned_volume <> zxv_agg.org_assigned_volume
		END
		
		
		----update aggregated deal volume left
		--TODO: use this code to finalize
		--UPDATE sdd_agg
		--SET volume_left = volume_left - (rs_detail.assigned_volume - rs_detail.org_assigned_volume)
		--FROM #ztbl_xml_value zxv_agg
		--INNER JOIN source_deal_detail sdd_agg ON sdd_agg.source_deal_header_id = zxv_agg.source_deal_header_id
		--OUTER APPLY (
		--	SELECT SUM(aa.org_assigned_volume) org_assigned_volume, SUM(aa.assigned_volume) assigned_volume
		--	FROM #temp_assignment_audit taa
		--	INNER JOIN assignment_audit aa ON aa.assignment_id = taa.assignment_id
		--	WHERE taa.agg_deal_header_id = zxv_agg.source_deal_header_id
		--) rs_detail
		
		EXEC spa_ErrorHandler 0, 'hypothetical_assignment table', 
			'spa_assign_hypothetical_assignment', 'Success', 
			'Successfully saved committed recs.', ''
			
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		
		SET @error_no = ERROR_NUMBER()
		SET @error_msg = ERROR_MESSAGE()
		PRINT 'Catch Error:' + CAST(@error_no AS VARCHAR(10)) + ' - ' + @error_msg
		
		SET @error_msg = 'Error saving committed recs. (' + @error_msg + ')'
		
		EXEC spa_ErrorHandler @error_no, 'hypothetical_assignment table', 
			'spa_assign_hypothetical_assignment', 'Error', @error_msg, 'Error saving committed recs.'		
	END CATCH
END
