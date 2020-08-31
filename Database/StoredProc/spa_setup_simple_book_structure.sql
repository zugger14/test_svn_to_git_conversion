IF OBJECT_ID(N'[dbo].[spa_setup_simple_book_structure]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_setup_simple_book_structure]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Stored procedure for Book Structure 
	Parameters
	@flag: Operation flag
			'a' - 
			'i' - Insert/Update
			'l' - Update strategy node level
			'm' - Update strategy node level
			'k' - Get subsidiary/strategy JSON
			'd' - Delete sub-book
	@xml: Book structure XML
	@function_id: Application function id
	@runtime_user: Runtime user
	@node_level: Book structure node level
	@fas_subsidiary_id: Subsidiary id
	@fas_strategy_id: Strategy id
	@source_book_id: Source book id
	@book_deal_type_map_id: Book deal map id
	@error_message: Message to be generated on error
*/
CREATE PROCEDURE [dbo].[spa_setup_simple_book_structure]
	@flag VARCHAR(1),
	@xml NVARCHAR(MAX) = null,
	@function_id INT = 10101200, --for test set default
	@runtime_user VARCHAR(100)  = NULL,
	@node_level INT = NULL,
	@fas_subsidiary_id VARCHAR(100) = NULL,
	@fas_strategy_id VARCHAR(MAX) = NULL,
	@source_book_id VARCHAR(MAX) = NULL,
	@book_deal_type_map_id VARCHAR(MAX) = NULL,
	@error_message NVARCHAR(MAX) = NULL OUTPUT
AS

/*
DECLARE @flag VARCHAR(1),
	@xml  NVARCHAR(MAX)  = null,
	@function_id INT = 10101200, --for test set default
	@runtime_user VARCHAR(100)  = NULL,
	@node_level INT = NULL,
	@fas_subsidiary_id NVARCHAR(100) = NULL,
	@fas_strategy_id NVARCHAR(MAX) = NULL,
	@source_book_id NVARCHAR(MAX) = NULL,
	@book_deal_type_map_id NVARCHAR(MAX) = NULL,
	@error_message NVARCHAR(MAX) = NULL

--select @flag='i',@xml='<Root function_id="10101200"> <GridRowCom><GridRow entity_name="Pioneer Solution" entity_id="1"></GridRow> </GridRowCom> <GridRowSubsidiary><GridRow entity_name="1. Power Sub (E)" entity_id="1341" parent_id="1"></GridRow> <GridRow entity_name="template" entity_id="1376" parent_id="1"></GridRow> </GridRowSubsidiary> <GridRowStrategy><GridRow entity_name="Netting" entity_id="1342" parent_id="1341"></GridRow> <GridRow entity_name="New Strategys" entity_id="3813" parent_id="1376"></GridRow> <GridRow entity_name="template" entity_id="1377" parent_id="1376"></GridRow> </GridRowStrategy> <GridRowBook><GridRow entity_name="Netting" entity_id="1372" parent_id="1342"></GridRow> <GridRow entity_name="New Book" entity_id="3814" parent_id="3813"></GridRow> <GridRow entity_name="New Book1" entity_id="3816" parent_id="3813"></GridRow> <GridRow entity_name="New Book88" entity_id="3817" parent_id="1377"></GridRow> <GridRow entity_name="template" entity_id="1378" parent_id="1377"></GridRow> <GridRow entity_name="template2" entity_id="1380" parent_id="1377"></GridRow> </GridRowBook> <GridRowSubBook><GridRow entity_name="Netting Hedge" entity_id="192" parent_id="1372"></GridRow> <GridRow entity_name="Netting Item" entity_id="193" parent_id="1372"></GridRow> <GridRow entity_name="template" entity_id="202" parent_id="1380"></GridRow> 
--<GridRow entity_name="New Sub Bookadasddsss" entity_id="" parent_id="1380"></GridRow> </GridRowSubBook></Root>'

--select @flag='i',@xml='<Root function_id="10101200"> <GridRowCom><GridRow entity_name="BROOKFIELD" entity_id="1"></GridRow> </GridRowCom> <GridRowSubsidiary></GridRowSubsidiary>
--<GridRowStrategy></GridRowStrategy> <GridRowBook></GridRowBook> <GridRowSubBook><GridRow entity_name="Test Value 10" entity_id="2574" parent_id="749" parent_stra_id="748" parent_sub_id="747"></GridRow> </GridRowSubBook></Root>'
----*/

SEt NOcount ON;
DECLARE @idoc INT
DECLARE @doc NVARCHAR(1000)
DECLARE @sql NVARCHAR(MAX)

IF @flag = 'a'
BEGIN
	SELECT 0 [row_id],
		   'Pioneer Solutionss' [name]
		   ,4 [hierarchy_level]	
END

ELSE IF @flag = 'i'
BEGIN
	DECLARE @disable_tagging BIT

	SELECT @disable_tagging = var_value
	FROM adiha_default_codes_values
	WHERE default_code_id = 104
		AND var_value = 1
		
	SET @disable_tagging = ISNULL(@disable_tagging, 0)
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	IF OBJECT_ID('tempdb..#temp_company') IS NOT NULL
		DROP TABLE #temp_company

	SELECT 
		  NULLIF(entity_name, '') [entity_name]
		, NULLIF(entity_id,'') [entity_id]
		, NULLIF([parent_id],'') [parent_id]
	INTO #temp_company
	
	FROM OPENXML (@idoc, '/Root/GridRowCom/GridRow', 2)
		 WITH (	[entity_name]				NVARCHAR(100) '@entity_name', 
		 		[entity_id]				INT  '@entity_id',
				[parent_id] NVARCHAR(100)	'@parent_id'
			)

	IF OBJECT_ID('tempdb..#temp_subsidiary') IS NOT NULL
		DROP TABLE #temp_subsidiary

	SELECT 
		  NULLIF(entity_name, '') [entity_name]
		, NULLIF(entity_id,'') [entity_id]
		, NULLIF([parent_id],'') [parent_id]
		, NULLIF([node_level],'') [node_level]
	INTO #temp_subsidiary
	
	FROM OPENXML (@idoc, '/Root/GridRowSubsidiary/GridRow', 2)
		 WITH (	[entity_name]				NVARCHAR(100) '@entity_name', 
		 		[entity_id]				INT  '@entity_id',
				[parent_id] NVARCHAR(100)	'@parent_id',
				[node_level] INT             '@node_level'
			)

	IF OBJECT_ID('tempdb..#temp_strategy') IS NOT NULL
		DROP TABLE #temp_strategy

	SELECT 
		  NULLIF(entity_name, '') [entity_name]
		, NULLIF(entity_id,'') [entity_id]
		, NULLIF([parent_id],'') [parent_id]
		, NULLIF([node_level],'') [node_level]
	INTO #temp_strategy
	
	FROM OPENXML (@idoc, '/Root/GridRowStrategy/GridRow', 2)
		 WITH (	[entity_name]				NVARCHAR(100) '@entity_name', 
		 		[entity_id]				INT  '@entity_id',
				[parent_id] NVARCHAR(100)	'@parent_id',
				[node_level] INT             '@node_level'
			)
	
	IF OBJECT_ID('tempdb..#temp_book') IS NOT NULL
		DROP TABLE #temp_book

	SELECT 
		  NULLIF(entity_name, '') [entity_name]
		, NULLIF(entity_id,'') [entity_id]
		, NULLIF([parent_id],'') [parent_id]
		, NULLIF([parent_stra_id],'') [parent_stra_id]
		, NULLIF([parent_sub_id],'') [parent_sub_id]
	INTO #temp_book
	
	FROM OPENXML (@idoc, '/Root/GridRowBook/GridRow', 2)
		 WITH (	[entity_name]			NVARCHAR(100) '@entity_name', 
		 		[entity_id]				INT  '@entity_id',
				[parent_id] NVARCHAR(100)	'@parent_id',
				[parent_stra_id] NVARCHAR(100) '@parent_stra_id',
				[parent_sub_id] NVARCHAR(100) '@parent_sub_id'
			)

	IF OBJECT_ID('tempdb..#temp_sub_book') IS NOT NULL
		DROP TABLE #temp_sub_book

	SELECT 
		  NULLIF(entity_name, '') [entity_name]
		, NULLIF(entity_id,'') [entity_id]
		, NULLIF([parent_id],'') [parent_id]
		, NULLIF([parent_stra_id],'') [parent_stra_id]
		, NULLIF([parent_sub_id],'') [parent_sub_id]
	INTO #temp_sub_book
	FROM OPENXML (@idoc, '/Root/GridRowSubBook/GridRow', 2)
		 WITH (	[entity_name]			NVARCHAR(200) '@entity_name', 
		 		[entity_id]				INT  '@entity_id',
				[parent_id] NVARCHAR(100)	'@parent_id',
				[parent_stra_id] NVARCHAR(100) '@parent_stra_id',
				[parent_sub_id] NVARCHAR(100) '@parent_sub_id'
			)
			
	--SELECT * FROM #temp_company
	--SELECT * FROM #temp_subsidiary
    --SELECT * FROM #temp_strategy
	--SELECT * FROM #temp_book
	--SELECT * FROM #temp_sub_book
	--RETURN

	IF @disable_tagging = 1 AND EXISTS (SELECT 1 FROM source_system_book_map ssbm INNER JOIN #temp_sub_book tsb ON tsb.entity_id = ssbm.book_deal_type_map_id WHERE tsb.entity_id IS NOT NULL)
	BEGIN
		UPDATE ssbm
		SET logical_name = tsb.entity_name
		FROM source_system_book_map ssbm
		INNER JOIN #temp_sub_book tsb ON tsb.entity_id = ssbm.book_deal_type_map_id

		EXEC spa_ErrorHandler 0, 'spa_setup_simple_book_structure', 'spa_setup_simple_book_structure', 'Success', 'Changes have been saved successfully.', @node_level

		RETURN
	END

	IF EXISTS (SELECT 1 FROM #temp_subsidiary
				GROUP BY entity_name
				HAVING COUNT(entity_name) > 1
				) OR EXISTS (
					SELECT 1 FROM #temp_subsidiary ts
					INNER JOIN portfolio_hierarchy ph
						ON ph.entity_name = ts.entity_name
						AND ph.entity_id <> -1
						AND ph.hierarchy_level = 2
						AND ph.entity_id <> ISNULL(ts.entity_id,-22) 
				)
		BEGIN
			SET @error_message = 'Duplicate data in Subsidiary.'
			EXEC spa_ErrorHandler -1, 
			'spa_setup_simple_book_structure', 
			'spa_setup_simple_book_structure', 
			'Error', 
			'Duplicate data in Subsidiary.',
			 ''
			 RETURN
		END

	IF EXISTS (SELECT 1 FROM #temp_strategy
				GROUP BY entity_name,parent_id
				HAVING COUNT(entity_name) > 1
				) OR EXISTS (
					SELECT 1 FROM #temp_strategy ts
					INNER JOIN portfolio_hierarchy ph
						ON ph.entity_name = ts.entity_name
						AND ph.entity_id <> -1
						AND ph.hierarchy_level = 1
						AND CAST(ph.parent_entity_id AS NVARCHAR(20)) = ts.parent_id
						AND ph.entity_id <> ISNULL(ts.entity_id,-22)
						) 
		BEGIN
			SET @error_message = 'Duplicate data in Strategy.'
			EXEC spa_ErrorHandler -1, 
			'spa_setup_simple_book_structure', 
			'spa_setup_simple_book_structure', 
			'Error', 
			'Duplicate data in Strategy.',
			 ''
			  RETURN
		END

	IF EXISTS (SELECT 1 FROM #temp_book
				GROUP BY entity_name,parent_id,parent_sub_id
				HAVING COUNT(entity_name) > 1
				) OR EXISTS (
					SELECT 1 FROM #temp_book tb
					INNER JOIN portfolio_hierarchy ph
						ON ph.entity_name = tb.entity_name
						AND ph.entity_id <> -1
						AND ph.hierarchy_level = 0
						AND CAST(ph.parent_entity_id AS NVARCHAR(20)) = tb.parent_id
						AND ph.entity_id <> ISNULL(tb.entity_id,-22) 
						)
		BEGIN
			SET @error_message = 'Duplicate data in Book.'
			EXEC spa_ErrorHandler -1, 
			'spa_setup_simple_book_structure', 
			'spa_setup_simple_book_structure', 
			'Error', 
			'Duplicate data in Book.',
			 ''
			  RETURN
		END

	IF EXISTS (SELECT 1 FROM #temp_sub_book
				GROUP BY entity_name
				HAVING COUNT(entity_name) > 1
				) OR EXISTS (
					SELECT 1 FROM #temp_sub_book tsb
					INNER JOIN source_system_book_map ssbm
						ON ssbm.logical_name = tsb.entity_name
						--AND CAST(ssbm.source_system_book_id1 AS NVARCHAR(20)) = tsb.parent_id
						AND ssbm.book_deal_type_map_id <> ISNULL(tsb.entity_id,-22)
						)
		BEGIN
			DECLARE @duplicate_sub_book NVARCHAR(MAX)
			DECLARE @duplicate_sub_book1 NVARCHAR(MAX)
			SELECT @duplicate_sub_book = STUFF((
			SELECT ', ' + CAST(tsb.entity_name as NVARCHAR(MAX))
			FROM #temp_sub_book tsb
					INNER JOIN source_system_book_map ssbm
						ON ssbm.logical_name = tsb.entity_name
						--AND CAST(ssbm.source_system_book_id1 AS NVARCHAR(20)) = tsb.parent_id
						AND ssbm.book_deal_type_map_id <> ISNULL(tsb.entity_id,-22)
			FOR XML PATH('')
			), 1, 2, '');

			SELECT @duplicate_sub_book1 = STUFF((
			SELECT ', ' + CAST(tsb.entity_name as NVARCHAR(MAX))
			FROM #temp_sub_book tsb
				GROUP BY entity_name
				HAVING COUNT(entity_name) > 1		
			FOR XML PATH('')
			), 1, 2, '');
			
			SET @duplicate_sub_book = 'Duplicate Sub Book :- <b>' + ISNULL(@duplicate_sub_book,'') + ISNULL(@duplicate_sub_book1,'') + '</b>.'
			SET @error_message = @duplicate_sub_book
			EXEC spa_ErrorHandler -1, 
			'spa_setup_simple_book_structure', 
			'spa_setup_simple_book_structure', 
			'Error', 
			@duplicate_sub_book,
			 ''
			  RETURN
		END
	
	BEGIN TRY
	BEGIN TRAN
	
		UPDATE ph
			SET ph.entity_name = tc.entity_name
		FROM #temp_company tc
		LEFT JOIN portfolio_hierarchy ph
			ON 1 =1
		WHERE ph.entity_id = -1

		-- Update/Insert Subsidiary

		UPDATE ph
			SET ph.entity_name = ts.entity_name
		FROM #temp_subsidiary ts
		LEFT JOIN portfolio_hierarchy ph
			ON ph.entity_id = ts.entity_id
		WHERE ts.entity_id IS NOT NULL

		IF OBJECT_ID('tempdb..#temp_sub_data') IS NOT NULL
			DROP TABLE #temp_sub_data

		CREATE TABLE #temp_sub_data ( entity_id int NOT NULL, 
							entity_name NVARCHAR(200) NOT NULL)

		INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level)
		OUTPUT inserted.entity_id, inserted.entity_name into #temp_sub_data
		SELECT ts.entity_name,525,2
		FROM #temp_subsidiary ts
		LEFT JOIN portfolio_hierarchy ph
			ON ph.entity_id = ts.entity_id
		WHERE ts.entity_id IS NULL


		INSERT INTO fas_subsidiaries (fas_subsidiary_id,entity_type_value_id,disc_source_value_id,days_in_year,long_term_months,disc_type_value_id,func_cur_value_id,node_level)
		SELECT tsd.entity_id,650,100,365,13,128,1, ts.node_level
		FROM #temp_subsidiary ts
		LEFT JOIN fas_subsidiaries fs
			ON fs.fas_subsidiary_id = ts.entity_id
		INNER JOIN #temp_sub_data tsd
			ON tsd.entity_name = ts.entity_name
		WHERE ts.entity_id IS NULL

	

		--select * from #temp_strategy
		-- Update/Insert Strategy
		--Update
		UPDATE ph
			SET ph.entity_name = ts.entity_name
		FROM #temp_strategy ts
		LEFT JOIN portfolio_hierarchy ph
			ON ph.entity_id = ts.entity_id
		WHERE ts.entity_id IS NOT NULL

		--Insert
		UPDATE ts
			SET ts.parent_id = ISNULL(pf.entity_id,pf1.entity_id)
		FROM #temp_strategy ts
		LEFT JOIN portfolio_hierarchy pf
			ON CAST(pf.entity_id AS NVARCHAR(100)) = ts.parent_id
			AND pf.hierarchy_level = 2
		LEFT JOIN portfolio_hierarchy pf1
			ON pf1.entity_name = ts.parent_id
			AND pf1.hierarchy_level = 2

		IF OBJECT_ID('tempdb..#temp_strategy_data') IS NOT NULL
			DROP TABLE #temp_strategy_data

		CREATE TABLE #temp_strategy_data ( entity_id int NOT NULL, 
							entity_name NVARCHAR(200) NOT NULL,
							parent_entity_id INT NOT NULL
							)

		INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id)
		OUTPUT inserted.entity_id, inserted.entity_name, inserted.parent_entity_id INTO #temp_strategy_data
		SELECT ts.entity_name,526,1, IIF(tsd.entity_name IS NULL,ts.parent_id,tsd.entity_id)
		FROM #temp_strategy ts
		LEFT JOIN portfolio_hierarchy ph
			ON ph.entity_id = ts.entity_id
		LEFT JOIN #temp_sub_data tsd
			ON tsd.entity_name = ts.parent_id
		WHERE ts.entity_id IS NULL

		INSERT INTO fas_strategy (
			fas_strategy_id,hedge_type_value_id,node_level,source_system_id,
			mes_gran_value_id, mismatch_tenor_value_id, gl_grouping_value_id, 
			rollout_per_type, mes_cfv_value_id, strip_trans_value_id, 
			mes_cfv_values_value_id, oci_rollout_approach_value_id
		)
		SELECT tsd.entity_id, 150, ts.node_level, 2,
			   176, 252, 351, 521, 201, 626, 225, 500 --Hardcoded Default values for strategy details
		FROM #temp_strategy_data tsd
		INNER JOIN portfolio_hierarchy pf
			ON pf.entity_id = tsd.parent_entity_id
		INNER JOIN #temp_strategy ts
			ON ts.entity_name = tsd.entity_name 
			AND ts.parent_id = tsd.parent_entity_id
		WHERE ts.entity_id IS NULL

	
		-- Update/Insert Book
		--Update
		UPDATE ph
			SET ph.entity_name = tb.entity_name
		FROM #temp_book tb
		LEFT JOIN portfolio_hierarchy ph
			ON ph.entity_id = tb.entity_id
		WHERE tb.entity_id IS NOT NULL
		
		
		--Insert
		UPDATE tb
			SET tb.parent_sub_id = ISNULL(pf.entity_id,pf1.entity_id)
		FROM #temp_book tb
		LEFT JOIN portfolio_hierarchy pf
			ON CAST(pf.entity_id AS NVARCHAR(100)) = tb.parent_sub_id
			AND pf.hierarchy_level = 2
		LEFT JOIN portfolio_hierarchy pf1
			ON pf1.entity_name = tb.parent_sub_id
			AND pf1.hierarchy_level = 2
		
		IF OBJECT_ID('tempdb..#temp_book_data') IS NOT NULL
			DROP TABLE #temp_book_data

		CREATE TABLE #temp_book_data ( entity_id int NOT NULL, 
							entity_name NVARCHAR(200) NOT NULL,
							parent_entity_id INT NOT NULL,
							parent_sub_entity_id NVARCHAR(20)
							)
	
		INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id)
		OUTPUT inserted.entity_id, inserted.entity_name, inserted.parent_entity_id, NULL INTO #temp_book_data
		SELECT tb.entity_name,527,0, IIF(tsd.entity_name IS NULL,tb.parent_id,tsd.entity_id)
		FROM #temp_book tb
		LEFT JOIN #temp_strategy_data tsd
			ON tsd.entity_name = tb.parent_id
			AND tsd.parent_entity_id = tb.parent_sub_id
		WHERE tb.entity_id IS NULL

		UPDATE tbd
			SET tbd.parent_sub_entity_id  = pf.parent_entity_id
		FROM #temp_book_data tbd
		INNER JOIN portfolio_hierarchy pf
			ON pf.entity_id = tbd.parent_entity_id

		INSERT INTO fas_books (fas_book_id)
		SELECT tbd.entity_id
		FROM #temp_book_data tbd
			
		-- Update/Insert Sub Book
		--UPDATE

		UPDATE ssbm
			SET ssbm.logical_name = tsb.entity_name
		FROM  #temp_sub_book tsb
		INNER JOIN source_system_book_map ssbm
			ON ssbm.book_deal_type_map_id = tsb.entity_id
		WHERE tsb.entity_id IS NOT NULL

		UPDATE sb
			SET sb.source_system_book_id = tsb.entity_name,
			sb.source_book_name = tsb.entity_name,
			sb.source_book_desc = tsb.entity_name
		FROM  #temp_sub_book tsb
		LEFT JOIN source_system_book_map ssbm
			ON ssbm.book_deal_type_map_id = tsb.entity_id
		LEFT JOIN source_book sb on sb.source_book_id = ssbm.source_system_book_id1
		WHERE tsb.entity_id IS NOT NULL
	
		IF OBJECT_ID('tempdb..#temp_sub_book_data') IS NOT NULL
			DROP TABLE #temp_sub_book_data

		CREATE TABLE #temp_sub_book_data ( source_book_id int NOT NULL, 
							entity_name NVARCHAR(200) NOT NULL)

		IF OBJECT_ID('tempdb..#temp_source_system_book_map') IS NOT NULL
			DROP TABLE #temp_source_system_book_map

		CREATE TABLE #temp_source_system_book_map( book_deal_type_map_id INT NOT NULL, 
							entity_name NVARCHAR(200) NOT NULL)

		IF EXISTS (	SELECT 1
							FROM #temp_sub_book tsb
								INNER JOIN source_book sb ON sb.source_system_book_id = tsb.entity_name
							WHERE sb.source_system_id = 2
			
		)
		BEGIN
			INSERT INTO #temp_sub_book_data (source_book_id,entity_name)
			SELECT source_book_id,tsb.entity_name
			FROM #temp_sub_book tsb
				INNER JOIN source_book sb ON sb.source_system_book_id = tsb.entity_name
			WHERE sb.source_system_id = 2
		END 
	
		INSERT INTO source_book (
		source_system_id, --2
		source_system_book_id, --code
		source_system_book_type_value_id, -- 50
		source_book_name, source_book_desc
		)
		OUTPUT inserted.source_book_id, inserted.source_system_book_id into #temp_sub_book_data
		SELECT 2, tsb.entity_name, 50, tsb.entity_name, tsb.entity_name
		FROM #temp_sub_book tsb
		LEFT JOIN source_book sb ON sb.source_system_book_id = tsb.entity_name
		WHERE sb.source_system_book_id IS NULL


		UPDATE tsb
			SET tsb.parent_sub_id = ISNULL(pf.entity_id,pf1.entity_id)
		FROM #temp_sub_book tsb
		LEFT JOIN portfolio_hierarchy pf
			ON CAST(pf.entity_id AS NVARCHAR(100)) = tsb.parent_sub_id
			AND pf.hierarchy_level = 2
		LEFT JOIN portfolio_hierarchy pf1
			ON pf1.entity_name = tsb.parent_sub_id
			AND pf1.hierarchy_level = 2

		UPDATE tsb
			SET tsb.parent_stra_id = ISNULL(pf.entity_id,pf1.entity_id)
		FROM #temp_sub_book tsb
		LEFT JOIN portfolio_hierarchy pf
			ON CAST(pf.entity_id AS NVARCHAR(100)) = tsb.parent_stra_id
			   AND pf.parent_entity_id = tsb.parent_sub_id
			   AND pf.hierarchy_level = 1
		LEFT JOIN portfolio_hierarchy pf1
			ON pf1.entity_name = tsb.parent_stra_id
				AND pf1.parent_entity_id = tsb.parent_sub_id
				AND pf1.hierarchy_level = 1

		INSERT INTO source_system_book_map (logical_name, 
											fas_book_id,
											source_system_book_id1,
											fas_deal_type_value_id,
											source_system_book_id2,
											source_system_book_id3,
											source_system_book_id4
					)
		OUTPUT inserted.book_deal_type_map_id, inserted.logical_name into #temp_source_system_book_map
		SELECT tsb.entity_name, IIF(tbd.entity_name IS NULL,tsb.parent_id,tbd.entity_id) , tsbd.source_book_id ,400, -2, -3, -4
		FROM #temp_sub_book tsb
		LEFT JOIN source_system_book_map ssbm
			ON ssbm.book_deal_type_map_id = tsb.entity_id
		LEFT JOIN #temp_book_data tbd
			ON tbd.entity_name = tsb.parent_id
			AND tbd.parent_sub_entity_id = tsb.parent_sub_id
			AND tbd.parent_entity_id = tsb.parent_stra_id
		LEFT JOIN #temp_sub_book_data tsbd
			ON tsbd.entity_name = tsb.entity_name
		WHERE tsb.entity_id IS NULL

		INSERT INTO source_book_map_GL_codes(source_book_map_id)
		SELECT tssbm.book_deal_type_map_id
		FROM #temp_sub_book tsb
		LEFT JOIN source_system_book_map ssbm
			ON ssbm.book_deal_type_map_id = tsb.entity_id
		LEFT JOIN #temp_source_system_book_map tssbm
			ON tssbm.entity_name = tsb.entity_name
		WHERE ssbm.book_deal_type_map_id IS NULL

		--INSERT INTO source_system_book_map (fas_book_id,source_system_book_id1,logical_name)
		--SELECT IIF(tbd.entity_name IS NULL,tsb.parent_id,tbd.entity_id),1,tsb.name
		--FROM  #temp_sub_book tsb
		--LEFT JOIN source_system_book_map ssbm
		--	ON ssbm.book_deal_type_map_id = tsb.entity_id
		--LEFT JOIN #temp_book_data tbd
		--	ON tbd.entity_name = tsb.parent_id
		--WHERE tsb.entity_id IS NULL

		--SELECT * FROM #temp_sub_data

		--SELECT * FROM #temp_company
		--SELECT * FROM #temp_subsidiary
		--SELECT * FROM #temp_strategy
		--SELECT * FROM #temp_book
		--SELECT * FROM #temp_sub_book
		--SELECT * FROM #temp_sub_book_data
		--SELECT * FROM #temp_source_system_book_map
		SET @error_message = 'Success'
		EXEC spa_ErrorHandler 0, 
			'spa_setup_simple_book_structure', 
			'spa_setup_simple_book_structure', 
			'Success', 
			'Changes have been saved successfully.', 
			@node_level

	COMMIT

		--Added to release Bookstructure cache key.
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='BookStructure', @source_object = 'spa_setup_simple_book_structure @flag=i'
		END

	END TRY
	BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
	
	SET @error_message = ERROR_MESSAGE()
	--print @error_message
	IF CHARINDEX('UQ_index_source_book_mapping',@error_message) > 0
		SET @error_message = 'Combination of book identifier should be unique.'
	ELSE
		SET @error_message = 'Error while saving.Try Again.'

	EXEC spa_ErrorHandler -1, 
		'spa_setup_simple_book_structure', 
		'spa_setup_simple_book_structure', 
		'Error', 
		 @error_message,
		 ''
	END CATCH
	
END

ELSE IF @flag = 'l'
BEGIN
	BEGIN TRY
		UPDATE fs
		SET fs.node_level = NULL
		FROM portfolio_hierarchy pf
		INNER JOIN fas_strategy fs
			ON fs.fas_strategy_id = pf.entity_id
			--AND fs.node_level = @node_level
		WHERE parent_entity_id = @fas_subsidiary_id
		AND @fas_subsidiary_id <> - 1

		UPDATE fas_subsidiaries
		SET node_level = NULLIF(@node_level,'')
		WHERE fas_subsidiary_id = @fas_subsidiary_id
		EXEC spa_setup_simple_book_structure  @flag='i', @xml = @xml, @node_level = @node_level
	
	END TRY

	BEGIN CATCH
		EXEC spa_ErrorHandler -1, 
			'spa_setup_simple_book_structure', 
			'spa_setup_simple_book_structure', 
			'Error', 
			'Error while saving.Try Again.',
			 ''
	END CATCH
	
END

ELSE IF @flag = 'm'
BEGIN
	BEGIN TRY
		UPDATE fas_strategy
		SET node_level = NULLIF(@node_level,'')
		WHERE fas_strategy_id = @fas_strategy_id
		EXEC spa_setup_simple_book_structure  @flag='i', @xml = @xml, @node_level = @node_level
	END TRY

	BEGIN CATCH
		EXEC spa_ErrorHandler -1, 
			'spa_setup_simple_book_structure', 
			'spa_setup_simple_book_structure', 
			'Error', 
			'Error while saving.Try Again.',
			 ''
	END CATCH
END

ELSE IF @flag = 'k'
BEGIN
	Declare @sub_level_json NVARCHAR(MAX), 
			@stra_level_json NVARCHAR(MAX) 
	SET @sub_level_json = (SELECT '[' + STUFF((
							SELECT 
								',{"subsidiary_id":' + '"a_' + CAST(fas_subsidiary_id AS NVARCHAR(20)) + '"'
								+ ',"node_level":' +  CAST(node_level AS NVARCHAR(20)) 
								+'}'

							FROM fas_subsidiaries fs
							WHERE fs.fas_subsidiary_id <> - 1
							FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(max)'), 1, 1, '') + ']') 

	SET @stra_level_json = (SELECT '[' + STUFF((
							SELECT 
								',{"strategy_id":' + '"b_' + CAST(fas_strategy_id AS NVARCHAR(20)) + '"'
								+ ',"node_level":' +  CAST(node_level AS NVARCHAR(20)) 
								+'}'

							FROM fas_strategy fs
							FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(max)'), 1, 1, '') + ']') 

	SELECT ISNULL(node_level,5) [node_level], ISNULL(@sub_level_json,'{}') [sub_level_json], ISNULL(@stra_level_json,'{}') [stra_level_json]
	FROM fas_subsidiaries
	WHERE fas_subsidiary_id = -1
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			--Delete Sub book
			IF EXISTS (
				SELECT 1 FROM source_deal_header dh 
				LEFT OUTER JOIN	source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
					AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
					AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
					AND dh.source_system_book_id4 = sbmp.source_system_book_id4
				INNER JOIN dbo.SplitCommaSeperatedValues(@book_deal_type_map_id) a ON a.item = sbmp.book_deal_type_map_id
				--WHERE sbmp.book_deal_type_map_id = @book_deal_type_map_id
				UNION ALL
				SELECT 1
				FROM deal_transfer_mapping dtm
				INNER JOIN deal_transfer_mapping_detail dtmd ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id
				INNER JOIN dbo.SplitCommaSeperatedValues(@book_deal_type_map_id) a ON a.item = dtm.source_book_mapping_id_from
					OR a.item = dtmd.transfer_sub_book
			)
			BEGIN
				EXEC spa_ErrorHandler -1,
				  'Source System Book Map',
				  'spa_sourcesystembookmap',
				  'DB Error',
				  'There are deals in this sub book. Please remove those deals to other sub book before deleting.',
				  ''       
				RETURN
			END
			
			EXEC spa_source_books_map_GL_codes 'd', @book_deal_type_map_id

			DELETE sb FROM source_book sb
			INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sb.source_book_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@book_deal_type_map_id) a ON a.item = ssbm.book_deal_type_map_id

			DELETE ssbm
			FROM source_system_book_map ssbm
			INNER JOIN dbo.SplitCommaSeperatedValues(@book_deal_type_map_id) a ON a.item = ssbm.book_deal_type_map_id

			--Delete Book
			--IF EXISTS(
			--               SELECT TOP 1 1
			--               FROM   source_system_book_map WITH(NOLOCK)
			--			INNER JOIN dbo.SplitCommaSeperatedValues(@source_book_id) a
			--				ON a.item = fas_book_id
			--           )
			--        BEGIN
			--            EXEC spa_ErrorHandler -1,
			--                 'Book Properties',
			--                 'spa_books',
			--                 'DB Error',
			--                 'Source book mapping(s) in the selected book should be deleted first.',
			--                 ''
             
			--            RETURN
			--        END

			DELETE an
			FROM application_notes an
			INNER JOIN fas_books fb ON fb.fas_book_id = ISNULL(an.parent_object_id, an.notes_object_id)
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_book_id) a ON a.item = fb.fas_book_id
			WHERE an.internal_type_value_id = 27
		
			UPDATE en SET notes_object_id = NULL
			FROM email_notes en
			INNER JOIN fas_books fb  ON CAST(fb.fas_book_id AS NVARCHAR(50)) = en.notes_object_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_book_id) a ON a.item = fb.fas_book_id
			WHERE en.internal_type_value_id = 27
	
			DELETE afu
			FROM application_functional_users afu
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_book_id) a ON a.item = afu.[entity_id]
			
			DELETE rmvu
			FROM report_manager_view_users rmvu
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_book_id) a ON a.item = rmvu.[entity_id]
	
			DELETE fb
			FROM fas_books fb
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_book_id) a ON a.item = fb.fas_book_id
        
			DELETE pf
			FROM portfolio_hierarchy pf
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_book_id) a ON a.item = pf.[entity_id]

			---- Delete Strategy
			--IF EXISTS(SELECT 1 FROM portfolio_hierarchy pf
			--INNER JOIN dbo.SplitCommaSeperatedValues(@fas_strategy_id) a
			--		ON a.item = pf.parent_entity_id
			--)
			--   BEGIN
			--       EXEC spa_ErrorHandler 1,
			--            'Strategy Properties Properties',
			--            'spa_strategy',
			--            'DB Error',
			--            'Please delete all books for the selected Strategy first.',
			--            ''
        
			--       RETURN
			--   END

			DELETE an
			FROM application_notes an
			INNER JOIN fas_strategy fs ON fs.fas_strategy_id = ISNULL(an.parent_object_id, an.notes_object_id)
			INNER JOIN dbo.SplitCommaSeperatedValues(@fas_strategy_id) a ON a.item = fs.fas_strategy_id
			WHERE an.internal_type_value_id = 26

			UPDATE en SET notes_object_id = NULL
			FROM email_notes en
			INNER JOIN fas_strategy fs ON CAST(fs.fas_strategy_id AS NVARCHAR(50)) = en.notes_object_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@fas_strategy_id) a ON a.item = fs.fas_strategy_id
			WHERE en.internal_type_value_id = 26

			DELETE afu
			FROM application_functional_users afu
			INNER JOIN dbo.SplitCommaSeperatedValues(@fas_strategy_id) a ON a.item = afu.[entity_id]

			DELETE rmvu
			FROM report_manager_view_users rmvu
			INNER JOIN dbo.SplitCommaSeperatedValues(@fas_strategy_id) a ON a.item = rmvu.[entity_id]
		
			DELETE fs
			FROM fas_strategy fs
			INNER JOIN dbo.SplitCommaSeperatedValues(@fas_strategy_id) a ON a.item = fs.fas_strategy_id

			DELETE pf
			FROM portfolio_hierarchy pf
			INNER JOIN dbo.SplitCommaSeperatedValues(@fas_strategy_id) a ON a.item = pf.[entity_id]

			--Delete Subsidiary
			DELETE FROM program_affiliations
			WHERE fas_subsidiary_id = @fas_subsidiary_id

			DELETE an FROM application_notes an
			INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = ISNULL(an.parent_object_id, an.notes_object_id)
			WHERE an.internal_type_value_id = 25 AND fs.fas_subsidiary_id = @fas_subsidiary_id

			UPDATE en SET notes_object_id = NULL
			FROM email_notes en
			INNER JOIN fas_subsidiaries fs ON CAST(fs.fas_subsidiary_id AS NVARCHAR(50)) = en.notes_object_id
			WHERE en.internal_type_value_id = 25 AND fs.fas_subsidiary_id = @fas_subsidiary_id
		
			DELETE FROM application_functional_users
			WHERE [entity_id] = @fas_subsidiary_id

			DELETE FROM report_manager_view_users
			WHERE [entity_id] = @fas_subsidiary_id

			DELETE FROM fas_subsidiaries
			WHERE fas_subsidiary_id = @fas_subsidiary_id
		
			DELETE FROM portfolio_hierarchy
			WHERE [entity_id] = @fas_subsidiary_id

			EXEC spa_ErrorHandler 0,
				'Book Structure',
				'spa_setup_simple_book_structure',
				'Success',
				'Changes have been saved successfully.',
				''

		COMMIT TRAN

		--Added to release Bookstructure cache key.
		IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='BookStructure', @source_object = 'spa_setup_simple_book_structure @flag = d'
		END
	END TRY
	BEGIN CATCH
		--PRINT error_message()
		DECLARE @error_msg NVARCHAR(MAX)

		IF @@TRANCOUNT > 0 ROLLBACK TRAN

		SET @error_msg = dbo.FNAHandleDBError(10101200)

		EXEC spa_ErrorHandler -1,
              'Book Structure',
              'spa_setup_simple_book_structure',
              'Error',
              @error_msg,
              ''
	END CATCH
END

GO