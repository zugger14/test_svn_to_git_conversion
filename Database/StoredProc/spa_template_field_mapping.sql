IF OBJECT_ID(N'[dbo].[spa_template_field_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_template_field_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- ===============================================================================================================
/**
	It is used to get the options of dependent combos in deal UI after handling the privilege

	Parameters
	@flag : Operation flag mandatory
	@template_id : Deal Template Id
	@process_id : Process Id
	@sub_flag : Sub flag
	@mapping_id : Mapping Id
	@selected_id : Selected Id
	@grid_name : Grid Name
	@call_from : Call From
	@grid_xml : Grid XML
*/

CREATE PROCEDURE [dbo].[spa_template_field_mapping]
    @flag CHAR(1) = 's',
    @template_id INT = NULL,
    @process_id VARCHAR(200) = NULL,
    @sub_flag CHAR(1) = NULL,
    @mapping_id VARCHAR(100) = NULL,
    @selected_id VARCHAR(100) = NULL,
    @grid_name VARCHAR(200) = NULL,
    @call_from VARCHAR(10) = NULL,
    @grid_xml XML = NULL
AS
SET NOCOUNT ON
 
DECLARE @sql VARCHAR(MAX), @sql1 VARCHAR(MAX)

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()

DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()

DECLARE @deal_fields_mapping VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping', @user_name, @process_id)
DECLARE @deal_fields_mapping_locations VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping_locations', @user_name, @process_id)
DECLARE @deal_fields_mapping_contracts VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping_contracts', @user_name, @process_id)
DECLARE @deal_fields_mapping_curves VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping_curves', @user_name, @process_id)
DECLARE @deal_fields_mapping_formula_curves VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping_formula_curves', @user_name, @process_id)
DECLARE @deal_fields_mapping_commodity VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping_commodity', @user_name, @process_id)
DECLARE @deal_fields_mapping_counterparty VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping_counterparty', @user_name, @process_id)
DECLARE @deal_fields_mapping_trader VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping_trader', @user_name, @process_id)
DECLARE @deal_fields_mapping_detail_status VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping_detail_status', @user_name, @process_id)
DECLARE @deal_fields_mapping_uom VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping_uom', @user_name, @process_id)
DECLARE @deal_fields_mapping_sub_book VARCHAR(300) = dbo.FNAProcessTableName('deal_fields_mapping_sub_book', @user_name, @process_id)

DECLARE @table_name VARCHAR(300)

IF @grid_name IS NULL AND @sub_flag IS NOT NULL
BEGIN
	SET @grid_name =  CASE @sub_flag
	                    WHEN 'l' THEN 'deal_fields_mapping_locations'
	                    WHEN 'c' THEN 'deal_fields_mapping_contracts'
	                    WHEN 'i' THEN 'deal_fields_mapping_curves'
	                    WHEN 'f' THEN 'deal_fields_mapping_formula_curves'
	                    WHEN 'o' THEN 'deal_fields_mapping_commodity'
	                    WHEN 'p' THEN 'deal_fields_mapping_counterparty'
						WHEN 'q' THEN 'deal_fields_mapping_trader'
						WHEN 'r' THEN 'deal_fields_mapping_detail_status'
						WHEN 's' THEN 'deal_fields_mapping_uom'
						WHEN 't' THEN 'deal_fields_mapping_sub_book'
	                END
END

IF @grid_name IS NOT NULL
BEGIN
	SET @table_name = CASE @grid_name
							WHEN 'deal_fields_mapping_locations' THEN @deal_fields_mapping_locations
							WHEN 'deal_fields_mapping_contracts' THEN @deal_fields_mapping_contracts
							WHEN 'deal_fields_mapping_curves' THEN @deal_fields_mapping_curves
							WHEN 'deal_fields_mapping_formula_curves' THEN @deal_fields_mapping_formula_curves
							WHEN 'deal_fields_mapping_commodity' THEN @deal_fields_mapping_commodity
							WHEN 'deal_fields_mapping_counterparty' THEN @deal_fields_mapping_counterparty
							WHEN 'deal_fields_mapping' THEN @deal_fields_mapping
							WHEN 'deal_fields_mapping_trader' THEN @deal_fields_mapping_trader
							WHEN 'deal_fields_mapping_detail_status' THEN @deal_fields_mapping_detail_status
							WHEN 'deal_fields_mapping_uom' THEN @deal_fields_mapping_uom
							WHEN 'deal_fields_mapping_sub_book' THEN @deal_fields_mapping_sub_book
	                  END
END

IF @flag = 'x'
BEGIN
	SET @sql = '
		CREATE TABLE ' + @deal_fields_mapping + '(
			deal_fields_mapping_id     VARCHAR(200),
			template_id                INT NULL,
			deal_type_id               INT NULL,
			commodity_id               INT NULL,
			counterparty_id            INT NULL,
			trader_id		           INT NULL
		)

		CREATE TABLE ' + @deal_fields_mapping_locations + '(
			deal_fields_mapping_locations_id VARCHAR(200),
			deal_fields_mapping_id     VARCHAR(200),
			location_group             INT NULL,
			commodity_id               INT NULL,
			location_id                INT NULL
		)

		CREATE TABLE ' + @deal_fields_mapping_contracts + '(
			deal_fields_mapping_contracts_id VARCHAR(200),
			deal_fields_mapping_id     VARCHAR(200),
			subsidiary_id              INT NULL,
			contract_id                INT NULL
		)

		CREATE TABLE ' + @deal_fields_mapping_curves + '(
			deal_fields_mapping_curves_id VARCHAR(200),
			deal_fields_mapping_id     VARCHAR(200),
			source_curve_type_value_id				   INT NULL,
			curve_id                   INT NULL,
			commodity_id               INT NULL,
			index_group                INT NULL,
			market                     INT NULL


		)

		CREATE TABLE ' + @deal_fields_mapping_formula_curves + '(
			deal_fields_mapping_formula_curves_id VARCHAR(200),
			deal_fields_mapping_id     VARCHAR(200),
			source_curve_type_value_id				   INT NULL,
			formula_curve_id           INT NULL,
			commodity_id               INT NULL,
			index_group                INT NULL,
			market                     INT NULL
		)

		CREATE TABLE ' + @deal_fields_mapping_commodity + '(
			deal_fields_mapping_commodity_id VARCHAR(200),
			deal_fields_mapping_id     VARCHAR(200),
			detail_commodity_id        INT NULL
		)

		CREATE TABLE ' + @deal_fields_mapping_counterparty + '(
			deal_fields_mapping_counterparty_id VARCHAR(200),
			deal_fields_mapping_id     VARCHAR(200),
			entity_type                INT NULL,
			counterparty_type          CHAR(1) NULL,
			counterparty_id            INT NULL
		)

		CREATE TABLE ' + @deal_fields_mapping_trader + '(
			deal_fields_mapping_trader_id VARCHAR(200),
			deal_fields_mapping_id     VARCHAR(200),
			trader_id                INT NULL
		)

		CREATE TABLE ' + @deal_fields_mapping_detail_status + '(
			deal_fields_mapping_detail_status_id VARCHAR(200),
			deal_fields_mapping_id     VARCHAR(200),
			detail_status_id            INT NULL
		)

		CREATE TABLE ' + @deal_fields_mapping_uom + '(
			deal_fields_mapping_uom_id VARCHAR(200),
			deal_fields_mapping_id     VARCHAR(200),
			uom_id                INT NULL
		)

		CREATE TABLE ' + @deal_fields_mapping_sub_book + '(
			deal_fields_mapping_sub_book_id VARCHAR(200),
			deal_fields_mapping_id     VARCHAR(200),
			sub_book_id                INT NULL
		)
	'
	EXEC(@sql)

	SELECT @process_id [process_id]
END
IF @flag = 'y'
BEGIN
	-- delete from process table data for patrticular template is present
	IF @call_from IS NULL
	BEGIN
		EXEC [spa_template_field_mapping] @flag='d', @template_id = @template_id, @process_id = @process_id, @grid_name = 'deal_fields_mapping', @call_from = 'r'
		RETURN
	END

	SET @sql = '
		INSERT INTO ' + @deal_fields_mapping + ' (deal_fields_mapping_id, template_id, deal_type_id, commodity_id, counterparty_id, trader_id)
		SELECT dfm.deal_fields_mapping_id, dfm.template_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id, dfm.trader_id
		FROM deal_fields_mapping dfm
		LEFT JOIN ' + @deal_fields_mapping + ' dfm2 ON dfm2.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_id IS NULL

		INSERT INTO ' + @deal_fields_mapping_locations + ' (deal_fields_mapping_locations_id, deal_fields_mapping_id, location_id, location_group, commodity_id)
		SELECT dfml.deal_fields_mapping_locations_id, dfml.deal_fields_mapping_id, dfml.location_id, dfml.location_group, dfml.commodity_id
		FROM deal_fields_mapping_locations dfml
		INNER JOIN ' + @deal_fields_mapping + ' dfm ON dfml.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		LEFT JOIN ' + @deal_fields_mapping_locations + ' dfm2 ON dfm2.deal_fields_mapping_locations_id = dfml.deal_fields_mapping_locations_id
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_locations_id IS NULL

		INSERT INTO ' + @deal_fields_mapping_contracts + ' (deal_fields_mapping_contracts_id, deal_fields_mapping_id, contract_id, subsidiary_id)
		SELECT dfml.deal_fields_mapping_contracts_id, dfml.deal_fields_mapping_id, dfml.contract_id, dfml.subsidiary_id
		FROM deal_fields_mapping_contracts dfml
		INNER JOIN ' + @deal_fields_mapping + ' dfm ON dfml.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		LEFT JOIN ' + @deal_fields_mapping_contracts + ' dfm2 ON dfm2.deal_fields_mapping_contracts_id = dfml.deal_fields_mapping_contracts_id
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_contracts_id IS NULL

		INSERT INTO ' + @deal_fields_mapping_curves + ' (deal_fields_mapping_curves_id, deal_fields_mapping_id,source_curve_type_value_id, curve_id, commodity_id, index_group, market)
		SELECT dfml.deal_fields_mapping_curves_id, dfml.deal_fields_mapping_id, dfml.source_curve_type_value_id , dfml.curve_id, dfml.commodity_id, dfml.index_group, dfml.market
		FROM deal_fields_mapping_curves dfml
		INNER JOIN ' + @deal_fields_mapping + ' dfm ON dfml.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		LEFT JOIN ' + @deal_fields_mapping_curves + ' dfm2 ON dfm2.deal_fields_mapping_curves_id = dfml.deal_fields_mapping_curves_id
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_curves_id IS NULL

		INSERT INTO ' + @deal_fields_mapping_formula_curves + ' (deal_fields_mapping_formula_curves_id, deal_fields_mapping_id,source_curve_type_value_id, formula_curve_id, commodity_id, index_group, market)
		SELECT dfml.deal_fields_mapping_formula_curves_id, dfml.deal_fields_mapping_id, dfml.source_curve_type_value_id, dfml.formula_curve_id, dfml.commodity_id, dfml.index_group, dfml.market
		FROM deal_fields_mapping_formula_curves dfml
		INNER JOIN ' + @deal_fields_mapping + ' dfm ON dfml.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		LEFT JOIN ' + @deal_fields_mapping_formula_curves + ' dfm2 ON dfm2.deal_fields_mapping_formula_curves_id = dfml.deal_fields_mapping_formula_curves_id
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_formula_curves_id IS NULL

		INSERT INTO ' + @deal_fields_mapping_commodity + ' (deal_fields_mapping_commodity_id, deal_fields_mapping_id, detail_commodity_id)
		SELECT dfml.deal_fields_mapping_commodity_id, dfml.deal_fields_mapping_id, dfml.detail_commodity_id
		FROM deal_fields_mapping_commodity dfml
		INNER JOIN ' + @deal_fields_mapping + ' dfm ON dfml.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		LEFT JOIN ' + @deal_fields_mapping_commodity + ' dfm2 ON dfm2.deal_fields_mapping_commodity_id = dfml.deal_fields_mapping_commodity_id
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_commodity_id IS NULL

		INSERT INTO ' + @deal_fields_mapping_counterparty + ' (deal_fields_mapping_counterparty_id, deal_fields_mapping_id, counterparty_type, entity_type, counterparty_id)
		SELECT dfml.deal_fields_mapping_counterparty_id, dfml.deal_fields_mapping_id, dfml.counterparty_type, dfml.entity_type, dfml.counterparty_id
		FROM deal_fields_mapping_counterparty dfml
		INNER JOIN ' + @deal_fields_mapping + ' dfm ON dfml.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		LEFT JOIN ' + @deal_fields_mapping_counterparty + ' dfm2 ON dfm2.deal_fields_mapping_counterparty_id = dfml.deal_fields_mapping_counterparty_id
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_counterparty_id IS NULL

		INSERT INTO ' + @deal_fields_mapping_trader + ' (deal_fields_mapping_trader_id, deal_fields_mapping_id, trader_id)
		SELECT dfml.deal_fields_mapping_trader_id, dfml.deal_fields_mapping_id, dfml.trader_id
		FROM deal_fields_mapping_trader dfml
		INNER JOIN ' + @deal_fields_mapping + ' dfm ON dfml.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		LEFT JOIN ' + @deal_fields_mapping_trader + ' dfm2 ON dfm2.deal_fields_mapping_trader_id = dfml.deal_fields_mapping_trader_id
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_trader_id IS NULL

		INSERT INTO ' + @deal_fields_mapping_detail_status + ' (deal_fields_mapping_detail_status_id, deal_fields_mapping_id, detail_status_id)
		SELECT dfml.deal_fields_mapping_detail_status_id, dfml.deal_fields_mapping_id, dfml.detail_status_id
		FROM deal_fields_mapping_detail_status dfml
		INNER JOIN ' + @deal_fields_mapping + ' dfm ON dfml.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		LEFT JOIN ' + @deal_fields_mapping_detail_status + ' dfm2 ON dfm2.deal_fields_mapping_detail_status_id = dfml.deal_fields_mapping_detail_status_id
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_detail_status_id IS NULL
		'
	SET @sql += '
		INSERT INTO ' + @deal_fields_mapping_uom + ' (deal_fields_mapping_uom_id, deal_fields_mapping_id, uom_id)
		SELECT dfml.deal_fields_mapping_uom_id, dfml.deal_fields_mapping_id, dfml.uom_id
		FROM deal_fields_mapping_uom dfml
		INNER JOIN ' + @deal_fields_mapping + ' dfm ON dfml.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		LEFT JOIN ' + @deal_fields_mapping_uom + ' dfm2 ON dfm2.deal_fields_mapping_uom_id = dfml.deal_fields_mapping_uom_id
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_uom_id IS NULL

		INSERT INTO ' + @deal_fields_mapping_sub_book + ' (deal_fields_mapping_sub_book_id, deal_fields_mapping_id, sub_book_id)
		SELECT dfml.deal_fields_mapping_sub_book_id, dfml.deal_fields_mapping_id, dfml.sub_book_id
		FROM deal_fields_mapping_sub_book dfml
		INNER JOIN ' + @deal_fields_mapping + ' dfm ON dfml.deal_fields_mapping_id = dfm.deal_fields_mapping_id
		LEFT JOIN ' + @deal_fields_mapping_sub_book + ' dfm2 ON dfm2.deal_fields_mapping_sub_book_id = dfml.deal_fields_mapping_sub_book_id
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND dfm2.deal_fields_mapping_sub_book_id IS NULL

	'
	IF @call_from = 'r'
	BEGIN
		SET @sql += ' SELECT deal_fields_mapping_id, template_id, deal_type_id, commodity_id, counterparty_id, trader_id FROM ' + @deal_fields_mapping + ' WHERE template_id = ' + CAST(@template_id AS VARCHAR(20))
	END
	--PRINT(RIGHT(@sql, 8000))
	EXEC(@sql)
END

ELSE IF @flag = 's'
BEGIN
	DECLARE @column_string VARCHAR(200)
	SELECT @column_string = COALESCE(@column_string + ',', '') + agcd.column_name
	FROM adiha_grid_columns_definition agcd
	INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
	WHERE agd.grid_name = @grid_name
	ORDER BY agcd.column_order

	SET @sql = 'SELECT ' + @column_string + '
				FROM   ' + @table_name + '
				WHERE deal_fields_mapping_id = ''' + @mapping_id + ''''
	--PRINT(@sql)
	EXEC(@sql)
END

ELSE IF @flag = 'd'
BEGIN
	IF @grid_name = 'deal_fields_mapping'
	BEGIN
		IF OBJECT_ID('tempdb..#temp_deleted_mapping') IS NOT NULL
			DROP TABLE #temp_deleted_mapping

		CREATE TABLE #temp_deleted_mapping (mapping_id VARCHAR(200) COLLATE DATABASE_DEFAULT )

		SET @sql = 'DELETE a
		            OUTPUT DELETED.deal_fields_mapping_id INTO #temp_deleted_mapping(mapping_id)
		            FROM ' + @table_name + ' a
					WHERE 1 = 1 '

		IF @selected_id IS NOT NULL
		BEGIN
			SET @sql += ' AND a.deal_fields_mapping_id = ''' + @selected_id + ''''
		END
		ELSE
		BEGIN
			IF @template_id IS NOT NULL
			BEGIN
				SET @sql += ' AND a.template_id = ''' + CAST(@template_id AS VARCHAR(20)) + ''''
			END
			ELSE
			BEGIN
				-- donot delete anything if template id or selected_id is not provided
				SET @sql = ''
			END
		END

		--PRINT(@sql)
		EXEC(@sql)

		IF EXISTS(SELECT 1 FROM #temp_deleted_mapping)
		BEGIN
			SET @sql = '
					DELETE t1
					FROM ' + @deal_fields_mapping_locations + ' t1
					INNER JOIN #temp_deleted_mapping t2 ON t2.mapping_id = t1.deal_fields_mapping_id

					DELETE t1
					FROM ' + @deal_fields_mapping_contracts + ' t1
					INNER JOIN #temp_deleted_mapping t2 ON t2.mapping_id = t1.deal_fields_mapping_id

					DELETE t1
					FROM ' + @deal_fields_mapping_curves + ' t1
					INNER JOIN #temp_deleted_mapping t2 ON t2.mapping_id = t1.deal_fields_mapping_id

					DELETE t1
					FROM ' + @deal_fields_mapping_formula_curves + ' t1
					INNER JOIN #temp_deleted_mapping t2 ON t2.mapping_id = t1.deal_fields_mapping_id

					DELETE t1
					FROM ' + @deal_fields_mapping_commodity + ' t1
					INNER JOIN #temp_deleted_mapping t2 ON t2.mapping_id = t1.deal_fields_mapping_id

					DELETE t1
					FROM ' + @deal_fields_mapping_counterparty + ' t1
					INNER JOIN #temp_deleted_mapping t2 ON t2.mapping_id = t1.deal_fields_mapping_id

					DELETE t1
					FROM ' + @deal_fields_mapping_trader + ' t1
					INNER JOIN #temp_deleted_mapping t2 ON t2.mapping_id = t1.deal_fields_mapping_id

					DELETE t1
					FROM ' + @deal_fields_mapping_detail_status + ' t1
					INNER JOIN #temp_deleted_mapping t2 ON t2.mapping_id = t1.deal_fields_mapping_id

					DELETE t1
					FROM ' + @deal_fields_mapping_uom + ' t1
					INNER JOIN #temp_deleted_mapping t2 ON t2.mapping_id = t1.deal_fields_mapping_id

					DELETE t1
					FROM ' + @deal_fields_mapping_sub_book + ' t1
					INNER JOIN #temp_deleted_mapping t2 ON t2.mapping_id = t1.deal_fields_mapping_id
			'
			EXEC(@sql)

			-- insert data for related template id if call from refresh --- selected_id is NULL when called from refresh
			IF @template_id IS NOT NULL AND @selected_id IS NULL AND ISNULL(@call_from, 'd') <> 'x'
			BEGIN
				SET @call_from = ISNULL(@call_from, 'd')
				EXEC spa_template_field_mapping @flag = 'y', @template_id = @template_id, @process_id = @process_id, @call_from = @call_from
			END
		END
		ELSE
		BEGIN
			IF @call_from = 'r'
				EXEC spa_template_field_mapping @flag = 'y', @template_id = @template_id, @process_id = @process_id, @call_from = @call_from
		END
	END
	ELSE
	BEGIN
		SET @sql = 'DELETE FROM ' + @table_name + '
					WHERE ' + @grid_name + '_id = ''' + @selected_id + ''''
		--PRINT(@sql)
		EXEC(@sql)
	END

	IF @call_from <> 's' AND @call_from <> 'r'
		EXEC spa_ErrorHandler 0
			, 'Deal Transfer'
			, 'spa_deal_transfer_new'
			, 'Success'
			, 'Changes saved successfully.'
			, @template_id

END
IF @flag = 'i'
BEGIN
	IF @grid_xml IS NOT NULL
	BEGIN
		DECLARE @xml_process_table VARCHAR(200)
		DECLARE @new_process_id VARCHAR(200) = dbo.FNAGetNewID()

 		SET @xml_process_table = dbo.FNAProcessTableName('xml_process_table', @user_name, @new_process_id)

 		EXEC spa_parse_xml_file 'b', NULL, @grid_xml, @xml_process_table

 		IF OBJECT_ID('tempdb..#grid_names') IS NOT NULL
 			DROP TABLE #grid_names
 		CREATE TABLE #grid_names(grid_name VARCHAR(200) COLLATE DATABASE_DEFAULT )

 		SET @sql = 'INSERT INTO #grid_names(grid_name)
 					SELECT DISTINCT grid_name FROM ' + @xml_process_table + '
 					'
 		EXEC(@sql)

 		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping
 			SET @sql = '
 				UPDATE t1
 				SET template_id = t2.template_id,
 					deal_type_id = NULLIF(t2.deal_type_id, 0),
 					commodity_id = NULLIF(t2.commodity_id,0),
 					counterparty_id = NULLIF(t2.counterparty_id, 0),
					trader_id = NULLIF(t2.trader_id, 0)
 				FROM ' + @deal_fields_mapping + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id
 				WHERE t2.grid_name = ''deal_fields_mapping''

 				INSERT INTO ' + @deal_fields_mapping + '(deal_fields_mapping_id, template_id, deal_type_id, commodity_id, counterparty_id)
 				SELECT t2.deal_fields_mapping_id, t2.template_id, NULLIF(t2.deal_type_id, 0), NULLIF(t2.commodity_id, 0), NULLIF(t2.counterparty_id, 0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id
 				WHERE t2.grid_name = ''deal_fields_mapping'' AND t1.deal_fields_mapping_id IS NULL
 			'

 			EXEC(@sql)
 		END

 		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping_locations')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping_locations
 			SET @sql = '
 				UPDATE t1
 				SET location_group = NULLIF(t2.location_group, 0),
 					commodity_id = NULLIF(t2.commodity_id, 0),
 					location_id = NULLIF(t2.location_id, 0)
 				FROM ' + @deal_fields_mapping_locations + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_locations_id = t2.deal_fields_mapping_locations_id
 				WHERE t2.grid_name = ''deal_fields_mapping_locations''

 				INSERT INTO ' + @deal_fields_mapping_locations + '(deal_fields_mapping_locations_id, deal_fields_mapping_id, location_group, commodity_id, location_id)
 				SELECT t2.deal_fields_mapping_locations_id, t2.deal_fields_mapping_id, NULLIF(t2.location_group, 0), NULLIF(t2.commodity_id, 0), NULLIF(t2.location_id, 0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping_locations + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_locations_id = t2.deal_fields_mapping_locations_id
 				WHERE t2.grid_name = ''deal_fields_mapping_locations'' AND t1.deal_fields_mapping_locations_id IS NULL
 			'

 			EXEC(@sql)
 		END

 		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping_contracts')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping_contracts
 			SET @sql = '
 				UPDATE t1
 				SET subsidiary_id = NULLIF(t2.subsidiary_id, 0),
 					contract_id = NULLIF(t2.contract_id, 0)
 				FROM ' + @deal_fields_mapping_contracts + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_contracts_id = t2.deal_fields_mapping_contracts_id
 				WHERE t2.grid_name = ''deal_fields_mapping_contracts''

 				INSERT INTO ' + @deal_fields_mapping_contracts + '(deal_fields_mapping_contracts_id,deal_fields_mapping_id,subsidiary_id,contract_id)
 				SELECT t2.deal_fields_mapping_contracts_id, t2.deal_fields_mapping_id, NULLIF(t2.subsidiary_id, 0), NULLIF(t2.contract_id, 0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping_contracts + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_contracts_id = t2.deal_fields_mapping_contracts_id
 				WHERE t2.grid_name = ''deal_fields_mapping_contracts'' AND t1.deal_fields_mapping_contracts_id IS NULL
 			'

 			EXEC(@sql)
 		END

 		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping_curves')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping_curves
 			SET @sql = '
 				UPDATE t1
 				SET curve_id = NULLIF(t2.curve_id, 0),
 					commodity_id = NULLIF(t2.commodity_id, 0),
 					index_group = NULLIF(t2.index_group, 0),
 					market = NULLIF(t2.market, 0),
					source_curve_type_value_id = NULLIF(t2.source_curve_type_value_id,0)
 				FROM ' + @deal_fields_mapping_curves + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_curves_id = t2.deal_fields_mapping_curves_id
 				WHERE t2.grid_name = ''deal_fields_mapping_curves''

 				INSERT INTO ' + @deal_fields_mapping_curves + '(deal_fields_mapping_curves_id, deal_fields_mapping_id, curve_id, commodity_id, index_group, market, source_curve_type_value_id)
 				SELECT t2.deal_fields_mapping_curves_id, t2.deal_fields_mapping_id, NULLIF(t2.curve_id, 0), NULLIF(t2.commodity_id, 0), NULLIF(t2.index_group, 0), NULLIF(t2.market, 0), NULLIF(t2.source_curve_type_value_id,0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping_curves + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_curves_id = t2.deal_fields_mapping_curves_id
 				WHERE t2.grid_name = ''deal_fields_mapping_curves'' AND t1.deal_fields_mapping_curves_id IS NULL
 			'

 			EXEC(@sql)
 		END

 		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping_formula_curves')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping_formula_curves
 			SET @sql = '
 				UPDATE t1
 				SET formula_curve_id = NULLIF(t2.formula_curve_id, 0),
 					commodity_id = NULLIF(t2.commodity_id, 0),
 					index_group = NULLIF(t2.index_group, 0),
 					market = NULLIF(t2.market, 0),
					source_curve_type_value_id = NULLIF(t2.source_curve_type_value_id,0)
 				FROM ' + @deal_fields_mapping_formula_curves + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_formula_curves_id = t2.deal_fields_mapping_formula_curves_id
 				WHERE t2.grid_name = ''deal_fields_mapping_formula_curves''

 				INSERT INTO ' + @deal_fields_mapping_formula_curves + '(deal_fields_mapping_formula_curves_id, deal_fields_mapping_id, formula_curve_id, commodity_id, index_group, market, source_curve_type_value_id)
 				SELECT t2.deal_fields_mapping_formula_curves_id, t2.deal_fields_mapping_id, NULLIF(t2.formula_curve_id, 0), NULLIF(t2.commodity_id, 0), NULLIF(t2.index_group, 0), NULLIF(t2.market, 0), NULLIF(t2.source_curve_type_value_id,0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping_formula_curves + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_formula_curves_id = t2.deal_fields_mapping_formula_curves_id
 				WHERE t2.grid_name = ''deal_fields_mapping_formula_curves'' AND t1.deal_fields_mapping_formula_curves_id IS NULL
 			'

 			EXEC(@sql)
 		END

 		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping_commodity')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping_commodity
 			SET @sql = '
 				UPDATE t1
 				SET detail_commodity_id = NULLIF(t2.detail_commodity_id, 0)
 				FROM ' + @deal_fields_mapping_commodity + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_commodity_id = t2.deal_fields_mapping_commodity_id
 				WHERE t2.grid_name = ''deal_fields_mapping_commodity''

 				INSERT INTO ' + @deal_fields_mapping_commodity + '(deal_fields_mapping_commodity_id, deal_fields_mapping_id, detail_commodity_id)
 				SELECT t2.deal_fields_mapping_commodity_id, t2.deal_fields_mapping_id, NULLIF(t2.detail_commodity_id, 0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping_commodity + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_commodity_id = t2.deal_fields_mapping_commodity_id
 				WHERE t2.grid_name = ''deal_fields_mapping_commodity'' AND t1.deal_fields_mapping_commodity_id IS NULL
 			'

 			EXEC(@sql)
 		END

 		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping_counterparty')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping_formula_curves
 			SET @sql = '
 				UPDATE t1
 				SET entity_type = NULLIF(t2.entity_type, 0),
 					counterparty_type = NULLIF(t2.counterparty_type, ''0''),
 					counterparty_id = NULLIF(t2.counterparty_id, 0)
 				FROM ' + @deal_fields_mapping_counterparty + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_counterparty_id = t2.deal_fields_mapping_counterparty_id
 				WHERE t2.grid_name = ''deal_fields_mapping_counterparty''

 				INSERT INTO ' + @deal_fields_mapping_counterparty + '(deal_fields_mapping_counterparty_id, deal_fields_mapping_id, entity_type, counterparty_type, counterparty_id)
 				SELECT t2.deal_fields_mapping_counterparty_id, t2.deal_fields_mapping_id, NULLIF(t2.entity_type, 0), NULLIF(t2.counterparty_type, ''0''), NULLIF(t2.counterparty_id, 0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping_counterparty + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_counterparty_id = t2.deal_fields_mapping_counterparty_id
 				WHERE t2.grid_name = ''deal_fields_mapping_counterparty'' AND t1.deal_fields_mapping_counterparty_id IS NULL
 			'
 			--PRINT(@sql)
			EXEC(@sql)
 		END

		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping_trader')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping_trader
 			SET @sql = '
 				UPDATE t1
 				SET trader_id = NULLIF(t2.trader_id, 0)
 				FROM ' + @deal_fields_mapping_trader + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_trader_id = t2.deal_fields_mapping_trader_id
 				WHERE t2.grid_name = ''deal_fields_mapping_trader''

 				INSERT INTO ' + @deal_fields_mapping_trader + '(deal_fields_mapping_trader_id, deal_fields_mapping_id, trader_id)
 				SELECT t2.deal_fields_mapping_trader_id, t2.deal_fields_mapping_id, NULLIF(t2.trader_id, 0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping_trader + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_trader_id = t2.deal_fields_mapping_trader_id
 				WHERE t2.grid_name = ''deal_fields_mapping_trader'' AND t1.deal_fields_mapping_trader_id IS NULL
 			'

 			EXEC(@sql)
 		END

		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping_detail_status')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping_detail_status
 			SET @sql = '
 				UPDATE t1
 				SET detail_status_id = NULLIF(t2.detail_status_id, 0)
 				FROM ' + @deal_fields_mapping_detail_status + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_detail_status_id = t2.deal_fields_mapping_detail_status_id
 				WHERE t2.grid_name = ''deal_fields_mapping_detail_status''

 				INSERT INTO ' + @deal_fields_mapping_detail_status + '(deal_fields_mapping_detail_status_id, deal_fields_mapping_id, detail_status_id)
 				SELECT t2.deal_fields_mapping_detail_status_id, t2.deal_fields_mapping_id, NULLIF(t2.detail_status_id, 0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping_detail_status + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_detail_status_id = t2.deal_fields_mapping_detail_status_id
 				WHERE t2.grid_name = ''deal_fields_mapping_detail_status'' AND t1.deal_fields_mapping_detail_status_id IS NULL
 			'

 			EXEC(@sql)
 		END

		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping_uom')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping_uom
 			SET @sql = '
 				UPDATE t1
 				SET uom_id = NULLIF(t2.uom_id, 0)
 				FROM ' + @deal_fields_mapping_uom + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_uom_id = t2.deal_fields_mapping_uom_id
 				WHERE t2.grid_name = ''deal_fields_mapping_uom''

 				INSERT INTO ' + @deal_fields_mapping_uom + '(deal_fields_mapping_uom_id, deal_fields_mapping_id, uom_id)
 				SELECT t2.deal_fields_mapping_uom_id, t2.deal_fields_mapping_id, NULLIF(t2.uom_id, 0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping_uom + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_uom_id = t2.deal_fields_mapping_uom_id
 				WHERE t2.grid_name = ''deal_fields_mapping_uom'' AND t1.deal_fields_mapping_uom_id IS NULL
 			'

 			EXEC(@sql)
 		END

		IF EXISTS(SELECT 1 FROM #grid_names WHERE grid_name = 'deal_fields_mapping_sub_book')
 		BEGIN
 			-- UPDATE/INSERT deal_fields_mapping_sub_book
 			SET @sql = '
 				UPDATE t1
 				SET sub_book_id = NULLIF(t2.sub_book_id, 0)
 				FROM ' + @deal_fields_mapping_sub_book + ' t1
 				INNER JOIN ' + @xml_process_table + ' t2 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_sub_book_id = t2.deal_fields_mapping_sub_book_id
 				WHERE t2.grid_name = ''deal_fields_mapping_sub_book''

 				INSERT INTO ' + @deal_fields_mapping_sub_book + '(deal_fields_mapping_sub_book_id, deal_fields_mapping_id, sub_book_id)
 				SELECT t2.deal_fields_mapping_sub_book_id, t2.deal_fields_mapping_id, NULLIF(t2.sub_book_id, 0)
 				FROM ' + @xml_process_table + ' t2
 				LEFT JOIN ' + @deal_fields_mapping_sub_book + ' t1 ON t1.deal_fields_mapping_id = t2.deal_fields_mapping_id AND t1.deal_fields_mapping_sub_book_id = t2.deal_fields_mapping_sub_book_id
 				WHERE t2.grid_name = ''deal_fields_mapping_sub_book'' AND t1.deal_fields_mapping_sub_book_id IS NULL
 			'

 			EXEC(@sql)
 		END
 	END

 	BEGIN TRY
 		BEGIN TRAN

 		IF @call_from = 's'
 		BEGIN
 			-- delete blank data from process table
 			SET @sql = '
 				DELETE FROM ' + @deal_fields_mapping_counterparty + ' WHERE NULLIF(counterparty_type, ''0'') IS NULL AND NULLIF(entity_type, 0) IS NULL AND NULLIF(counterparty_id, 0) IS NULL
 				DELETE FROM ' + @deal_fields_mapping_commodity + ' WHERE NULLIF(detail_commodity_id, 0) IS NULL
 				DELETE FROM ' + @deal_fields_mapping_formula_curves + ' WHERE NULLIF(formula_curve_id, 0) IS NULL AND NULLIF(commodity_id, 0) IS NULL AND NULLIF(index_group, 0) IS NULL AND NULLIF(market, 0) IS NULL AND NULLIF(source_curve_type_value_id, 0) IS NULL
 				DELETE FROM ' + @deal_fields_mapping_curves + ' WHERE NULLIF(curve_id, 0) IS NULL AND NULLIF(commodity_id, 0) IS NULL AND NULLIF(index_group, 0) IS NULL AND NULLIF(market, 0) IS NULL AND NULLIF(source_curve_type_value_id, 0) IS NULL
 				DELETE FROM ' + @deal_fields_mapping_contracts + ' WHERE NULLIF(contract_id, 0) IS NULL AND NULLIF(subsidiary_id, 0) IS NULL
 				DELETE FROM ' + @deal_fields_mapping_locations + ' WHERE NULLIF(location_id, 0) IS NULL AND NULLIF(location_group, 0) IS NULL AND NULLIF(commodity_id, 0) IS NULL
				DELETE FROM ' + @deal_fields_mapping_trader + ' WHERE NULLIF(trader_id, 0) IS NULL
				DELETE FROM ' + @deal_fields_mapping_trader + ' WHERE NULLIF(trader_id, 0) IS NULL
				DELETE FROM ' + @deal_fields_mapping_detail_status + ' WHERE NULLIF(detail_status_id, 0) IS NULL
				DELETE FROM ' + @deal_fields_mapping_uom + ' WHERE NULLIF(uom_id, 0) IS NULL
				DELETE FROM ' + @deal_fields_mapping_sub_book + ' WHERE NULLIF(sub_book_id, 0) IS NULL
 			'
 			EXEC(@sql)

 			-- delete deleted data
 			SET @sql = '
 				DELETE dfmc
 				FROM deal_fields_mapping dfm
 				INNER JOIN deal_fields_mapping_counterparty dfmc ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
 				LEFT JOIN ' + @deal_fields_mapping_counterparty + ' t1 ON CAST(dfmc.deal_fields_mapping_counterparty_id AS VARCHAR(20)) = t1.deal_fields_mapping_counterparty_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_counterparty_id IS NULL

 				DELETE dfmc
 				FROM deal_fields_mapping dfm
 				INNER JOIN deal_fields_mapping_commodity dfmc ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
 				LEFT JOIN ' + @deal_fields_mapping_commodity + ' t1 ON CAST(dfmc.deal_fields_mapping_commodity_id AS VARCHAR(20)) = t1.deal_fields_mapping_commodity_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_commodity_id IS NULL

 				DELETE dfmc
 				FROM deal_fields_mapping dfm
 				INNER JOIN deal_fields_mapping_formula_curves dfmc ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
 				LEFT JOIN ' + @deal_fields_mapping_formula_curves + ' t1 ON CAST(dfmc.deal_fields_mapping_formula_curves_id AS VARCHAR(20)) = t1.deal_fields_mapping_formula_curves_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_formula_curves_id IS NULL

 				DELETE dfmc
 				FROM deal_fields_mapping dfm
 				INNER JOIN deal_fields_mapping_curves dfmc ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
 				LEFT JOIN ' + @deal_fields_mapping_curves + ' t1 ON CAST(dfmc.deal_fields_mapping_curves_id AS VARCHAR(20)) = t1.deal_fields_mapping_curves_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_curves_id IS NULL

 				DELETE dfmc
 				FROM deal_fields_mapping dfm
 				INNER JOIN deal_fields_mapping_contracts dfmc ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
 				LEFT JOIN ' + @deal_fields_mapping_contracts + ' t1 ON CAST(dfmc.deal_fields_mapping_contracts_id AS VARCHAR(20)) = t1.deal_fields_mapping_contracts_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_contracts_id IS NULL

 				DELETE dfmc
 				FROM deal_fields_mapping dfm
 				INNER JOIN deal_fields_mapping_locations dfmc ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
 				LEFT JOIN ' + @deal_fields_mapping_locations + ' t1 ON CAST(dfmc.deal_fields_mapping_locations_id AS VARCHAR(20)) = t1.deal_fields_mapping_locations_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_locations_id IS NULL

				DELETE dfmc
 				FROM deal_fields_mapping dfm
 				INNER JOIN deal_fields_mapping_trader dfmc ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
 				LEFT JOIN ' + @deal_fields_mapping_trader + ' t1 ON CAST(dfmc.deal_fields_mapping_trader_id AS VARCHAR(20)) = t1.deal_fields_mapping_trader_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_trader_id IS NULL

				DELETE dfmc
 				FROM deal_fields_mapping dfm
 				INNER JOIN deal_fields_mapping_detail_status dfmc ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
 				LEFT JOIN ' + @deal_fields_mapping_detail_status + ' t1 ON CAST(dfmc.deal_fields_mapping_detail_status_id AS VARCHAR(20)) = t1.deal_fields_mapping_detail_status_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_detail_status_id IS NULL

				DELETE dfmc
 				FROM deal_fields_mapping dfm
 				INNER JOIN deal_fields_mapping_uom dfmc ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
 				LEFT JOIN ' + @deal_fields_mapping_uom + ' t1 ON CAST(dfmc.deal_fields_mapping_uom_id AS VARCHAR(20)) = t1.deal_fields_mapping_uom_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_uom_id IS NULL

				DELETE dfmc
 				FROM deal_fields_mapping dfm
 				INNER JOIN deal_fields_mapping_sub_book dfmc ON dfm.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
 				LEFT JOIN ' + @deal_fields_mapping_sub_book + ' t1 ON CAST(dfmc.deal_fields_mapping_sub_book_id AS VARCHAR(20)) = t1.deal_fields_mapping_sub_book_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_sub_book_id IS NULL

 				DELETE dfm
 				FROM deal_fields_mapping dfm
 				LEFT JOIN ' + @deal_fields_mapping + ' t1 ON CAST(dfm.deal_fields_mapping_id AS VARCHAR(20)) = t1.deal_fields_mapping_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + ' AND t1.deal_fields_mapping_id IS NULL
 			'
 			EXEC(@sql)

 			-- update data
 			SET @sql = '
 				UPDATE t1
 				SET template_id = t2.template_id,
 					deal_type_id = NULLIF(t2.deal_type_id, 0),
 					commodity_id = NULLIF(t2.commodity_id,0),
 					counterparty_id = NULLIF(t2.counterparty_id, 0),
					trader_id = NULLIF(t2.trader_id, 0)
 				FROM deal_fields_mapping t1
 				INNER JOIN ' + @deal_fields_mapping + ' t2 ON CAST(t1.deal_fields_mapping_id AS VARCHAR(20)) = t2.deal_fields_mapping_id
 				WHERE t1.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

 				UPDATE t1
 				SET location_group = NULLIF(t2.location_group, 0),
 					commodity_id = NULLIF(t2.commodity_id, 0),
 					location_id = NULLIF(t2.location_id, 0)
 				FROM deal_fields_mapping_locations t1
 				INNER JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = t1.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping_locations + ' t2 ON CAST(t1.deal_fields_mapping_locations_id AS VARCHAR(20))  = t2.deal_fields_mapping_locations_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

 				UPDATE t1
 				SET subsidiary_id = NULLIF(t2.subsidiary_id, 0),
 					contract_id = NULLIF(t2.contract_id, 0)
 				FROM deal_fields_mapping_contracts t1
 				INNER JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = t1.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping_contracts + ' t2 ON CAST(t1.deal_fields_mapping_contracts_id AS VARCHAR(20))  = t2.deal_fields_mapping_contracts_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

 				UPDATE t1
 				SET curve_id = NULLIF(t2.curve_id, 0),
 					commodity_id = NULLIF(t2.commodity_id, 0),
 					index_group = NULLIF(t2.index_group, 0),
 					market = NULLIF(t2.market, 0),
					source_curve_type_value_id = NULLIF(t2.source_curve_type_value_id,0)
 				FROM deal_fields_mapping_curves t1
 				INNER JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = t1.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping_curves + ' t2 ON CAST(t1.deal_fields_mapping_curves_id AS VARCHAR(20)) = t2.deal_fields_mapping_curves_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

 				UPDATE t1
 				SET formula_curve_id = NULLIF(t2.formula_curve_id, 0),
 					commodity_id = NULLIF(t2.commodity_id, 0),
 					index_group = NULLIF(t2.index_group, 0),
 					market = NULLIF(t2.market, 0),
					source_curve_type_value_id = NULLIF(t2.source_curve_type_value_id,0)
 				FROM deal_fields_mapping_formula_curves t1
 				INNER JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = t1.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping_formula_curves + ' t2 ON CAST(t1.deal_fields_mapping_formula_curves_id AS VARCHAR(20)) = t2.deal_fields_mapping_formula_curves_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

 				UPDATE t1
 				SET detail_commodity_id = NULLIF(t2.detail_commodity_id, 0)
 				FROM deal_fields_mapping_commodity t1
 				INNER JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = t1.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping_commodity + ' t2 ON CAST(t1.deal_fields_mapping_commodity_id AS VARCHAR(20)) = t2.deal_fields_mapping_commodity_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

 				UPDATE t1
 				SET entity_type = NULLIF(t2.entity_type, 0),
 					counterparty_type = NULLIF(t2.counterparty_type, ''0''),
 					counterparty_id = NULLIF(t2.counterparty_id, 0)
 				FROM deal_fields_mapping_counterparty t1
 				INNER JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = t1.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping_counterparty + ' t2 ON CAST(t1.deal_fields_mapping_counterparty_id AS VARCHAR(20)) = t2.deal_fields_mapping_counterparty_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

				UPDATE t1
 				SET trader_id = NULLIF(t2.trader_id, 0)
 				FROM deal_fields_mapping_trader t1
 				INNER JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = t1.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping_trader + ' t2 ON CAST(t1.deal_fields_mapping_trader_id AS VARCHAR(20)) = t2.deal_fields_mapping_trader_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

				UPDATE t1
 				SET detail_status_id = NULLIF(t2.detail_status_id, 0)
 				FROM deal_fields_mapping_detail_status t1
 				INNER JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = t1.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping_detail_status + ' t2 ON CAST(t1.deal_fields_mapping_detail_status_id AS VARCHAR(20)) = t2.deal_fields_mapping_detail_status_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

				UPDATE t1
 				SET uom_id = NULLIF(t2.uom_id, 0)
 				FROM deal_fields_mapping_uom t1
 				INNER JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = t1.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping_uom + ' t2 ON CAST(t1.deal_fields_mapping_uom_id AS VARCHAR(20)) = t2.deal_fields_mapping_uom_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

				UPDATE t1
 				SET sub_book_id = NULLIF(t2.sub_book_id, 0)
 				FROM deal_fields_mapping_sub_book t1
 				INNER JOIN deal_fields_mapping dfm ON dfm.deal_fields_mapping_id = t1.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping_sub_book + ' t2 ON CAST(t1.deal_fields_mapping_sub_book_id AS VARCHAR(20)) = t2.deal_fields_mapping_sub_book_id
 				WHERE dfm.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '
 			'
 			EXEC(@sql)

 			IF OBJECT_ID('tempdb..#temp_new_old_mapping_id') IS NOT NULL
 				DROP TABLE #temp_new_old_mapping_id

 			CREATE TABLE #temp_new_old_mapping_id (new_id INT, old_id VARCHAR(500) COLLATE DATABASE_DEFAULT  )

 			-- insert data
 			SET @sql = '
 				INSERT INTO deal_fields_mapping(template_id, deal_type_id, commodity_id, counterparty_id, trader_id)
 				OUTPUT INSERTED.deal_fields_mapping_id INTO #temp_new_old_mapping_id(new_id)
 				SELECT t2.template_id, NULLIF(t2.deal_type_id, 0), NULLIF(t2.commodity_id, 0), NULLIF(t2.counterparty_id, 0), NULLIF(t2.trader_id, 0)
 				FROM ' + @deal_fields_mapping + ' t2
 				LEFT JOIN deal_fields_mapping t1 ON CAST(t1.deal_fields_mapping_id AS VARCHAR(20)) = t2.deal_fields_mapping_id
 				WHERE t1.deal_fields_mapping_id IS NULL AND t2.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

 				UPDATE t1
 				SET old_id = t2.deal_fields_mapping_id
 				FROM #temp_new_old_mapping_id t1
 				INNER JOIN deal_fields_mapping dfm ON t1.new_id = dfm.deal_fields_mapping_id
 				INNER JOIN ' + @deal_fields_mapping + ' t2
 					ON dfm.template_id = t2.template_id
 					AND ISNULL(dfm.deal_type_id, 0) = ISNULL(t2.deal_type_id, 0)
 					AND ISNULL(dfm.commodity_id, 0) = ISNULL(t2.commodity_id, 0)
 					AND ISNULL(dfm.counterparty_id, 0) = ISNULL(t2.counterparty_id, 0)

 				INSERT INTO #temp_new_old_mapping_id (old_id, new_id)
 				SELECT t1.deal_fields_mapping_id, t1.deal_fields_mapping_id
 				FROM deal_fields_mapping t1
 				INNER JOIN ' + @deal_fields_mapping + ' t2 ON CAST(t1.deal_fields_mapping_id AS VARCHAR(20)) = t2.deal_fields_mapping_id
 				WHERE t1.template_id = ' + CAST(@template_id AS VARCHAR(20)) + '

 				INSERT INTO deal_fields_mapping_locations(deal_fields_mapping_id, location_group, commodity_id, location_id)
 				SELECT t1.new_id, NULLIF(t2.location_group, 0), NULLIF(t2.commodity_id, 0), NULLIF(t2.location_id, 0)
 				FROM ' + @deal_fields_mapping_locations + ' t2
 				INNER JOIN #temp_new_old_mapping_id t1 ON t1.old_id = t2.deal_fields_mapping_id
 				LEFT JOIN deal_fields_mapping_locations dfm ON dfm.deal_fields_mapping_id = t1.new_id AND t2.deal_fields_mapping_locations_id = CAST(dfm.deal_fields_mapping_locations_id AS VARCHAR(50))
 				WHERE dfm.deal_fields_mapping_locations_id IS NULL

 				INSERT INTO deal_fields_mapping_contracts(deal_fields_mapping_id,subsidiary_id,contract_id)
 				SELECT t1.new_id, NULLIF(t2.subsidiary_id, 0), NULLIF(t2.contract_id, 0)
 				FROM ' + @deal_fields_mapping_contracts + ' t2
 				INNER JOIN #temp_new_old_mapping_id t1 ON t1.old_id = t2.deal_fields_mapping_id
 				LEFT JOIN deal_fields_mapping_contracts dfm ON dfm.deal_fields_mapping_id = t1.new_id AND t2.deal_fields_mapping_contracts_id = CAST(dfm.deal_fields_mapping_contracts_id AS VARCHAR(50))
 				WHERE dfm.deal_fields_mapping_contracts_id IS NULL

 				INSERT INTO deal_fields_mapping_curves (deal_fields_mapping_id, curve_id, commodity_id, index_group, market,source_curve_type_value_id)
 				SELECT t1.new_id, NULLIF(t2.curve_id, 0), NULLIF(t2.commodity_id, 0), NULLIF(t2.index_group, 0), NULLIF(t2.market, 0), NULLIF(t2.source_curve_type_value_id, 0)
 				FROM ' + @deal_fields_mapping_curves + ' t2
 				INNER JOIN #temp_new_old_mapping_id t1 ON t1.old_id = t2.deal_fields_mapping_id
 				LEFT JOIN deal_fields_mapping_curves dfm ON dfm.deal_fields_mapping_id = t1.new_id AND t2.deal_fields_mapping_curves_id = CAST(dfm.deal_fields_mapping_curves_id AS VARCHAR(50))
 				WHERE dfm.deal_fields_mapping_curves_id IS NULL

 				INSERT INTO deal_fields_mapping_formula_curves(deal_fields_mapping_id, formula_curve_id, commodity_id, index_group, market,source_curve_type_value_id)
 				SELECT t1.new_id, NULLIF(t2.formula_curve_id, 0), NULLIF(t2.commodity_id, 0), NULLIF(t2.index_group, 0), NULLIF(t2.market, 0), NULLIF(t2.source_curve_type_value_id, 0)
 				FROM ' + @deal_fields_mapping_formula_curves + ' t2
 				INNER JOIN #temp_new_old_mapping_id t1 ON t1.old_id = t2.deal_fields_mapping_id
 				LEFT JOIN deal_fields_mapping_formula_curves dfm ON dfm.deal_fields_mapping_id = t1.new_id AND t2.deal_fields_mapping_formula_curves_id = CAST(dfm.deal_fields_mapping_formula_curves_id AS VARCHAR(50))
 				WHERE dfm.deal_fields_mapping_formula_curves_id IS NULL

 				INSERT INTO deal_fields_mapping_commodity(deal_fields_mapping_id, detail_commodity_id)
 				SELECT t1.new_id, NULLIF(t2.detail_commodity_id, 0)
 				FROM ' + @deal_fields_mapping_commodity + ' t2
 				INNER JOIN #temp_new_old_mapping_id t1 ON t1.old_id = t2.deal_fields_mapping_id
 				LEFT JOIN deal_fields_mapping_commodity dfm ON dfm.deal_fields_mapping_id = t1.new_id AND t2.deal_fields_mapping_commodity_id = CAST(dfm.deal_fields_mapping_commodity_id AS VARCHAR(50))
 				WHERE dfm.deal_fields_mapping_commodity_id IS NULL

 				INSERT INTO deal_fields_mapping_counterparty(deal_fields_mapping_id, entity_type, counterparty_type, counterparty_id)
 				SELECT t1.new_id, NULLIF(t2.entity_type, 0), NULLIF(t2.counterparty_type, ''0''), NULLIF(t2.counterparty_id, 0)
 				FROM ' + @deal_fields_mapping_counterparty + ' t2
 				INNER JOIN #temp_new_old_mapping_id t1 ON t1.old_id = t2.deal_fields_mapping_id
 				LEFT JOIN deal_fields_mapping_counterparty dfm ON dfm.deal_fields_mapping_id = t1.new_id AND t2.deal_fields_mapping_counterparty_id = CAST(dfm.deal_fields_mapping_counterparty_id AS VARCHAR(50))
 				WHERE dfm.deal_fields_mapping_counterparty_id IS NULL

				INSERT INTO deal_fields_mapping_trader(deal_fields_mapping_id, trader_id)
 				SELECT t1.new_id, NULLIF(t2.trader_id, 0)
 				FROM ' + @deal_fields_mapping_trader + ' t2
 				INNER JOIN #temp_new_old_mapping_id t1 ON t1.old_id = t2.deal_fields_mapping_id
 				LEFT JOIN deal_fields_mapping_trader dfm ON dfm.deal_fields_mapping_id = t1.new_id AND t2.deal_fields_mapping_trader_id = CAST(dfm.deal_fields_mapping_trader_id AS VARCHAR(50))
 				WHERE dfm.deal_fields_mapping_trader_id IS NULL '

				SET @sql1 = 'INSERT INTO deal_fields_mapping_detail_status(deal_fields_mapping_id, detail_status_id)
 				SELECT t1.new_id, NULLIF(t2.detail_status_id, 0)
 				FROM ' + @deal_fields_mapping_detail_status + ' t2
 				INNER JOIN #temp_new_old_mapping_id t1 ON t1.old_id = t2.deal_fields_mapping_id
 				LEFT JOIN deal_fields_mapping_detail_status dfm ON dfm.deal_fields_mapping_id = t1.new_id AND t2.deal_fields_mapping_detail_status_id = CAST(dfm.deal_fields_mapping_detail_status_id AS VARCHAR(50))
 				WHERE dfm.deal_fields_mapping_detail_status_id IS NULL

				INSERT INTO deal_fields_mapping_uom(deal_fields_mapping_id, uom_id)
 				SELECT t1.new_id, NULLIF(t2.uom_id, 0)
 				FROM ' + @deal_fields_mapping_uom + ' t2
 				INNER JOIN #temp_new_old_mapping_id t1 ON t1.old_id = t2.deal_fields_mapping_id
 				LEFT JOIN deal_fields_mapping_uom dfm ON dfm.deal_fields_mapping_id = t1.new_id AND t2.deal_fields_mapping_uom_id = CAST(dfm.deal_fields_mapping_uom_id AS VARCHAR(50))
 				WHERE dfm.deal_fields_mapping_uom_id IS NULL

				INSERT INTO deal_fields_mapping_sub_book(deal_fields_mapping_id, sub_book_id)
 				SELECT t1.new_id, NULLIF(t2.sub_book_id, 0)
 				FROM ' + @deal_fields_mapping_sub_book + ' t2
 				INNER JOIN #temp_new_old_mapping_id t1 ON t1.old_id = t2.deal_fields_mapping_id
 				LEFT JOIN deal_fields_mapping_sub_book dfm ON dfm.deal_fields_mapping_id = t1.new_id AND t2.deal_fields_mapping_sub_book_id = CAST(dfm.deal_fields_mapping_sub_book_id AS VARCHAR(50))
 				WHERE dfm.deal_fields_mapping_sub_book_id IS NULL
 			'
 			--PRINT(@sql)
 			EXEC(@sql + @sql1)
 			
 			EXEC [spa_template_field_mapping] @flag='d', @template_id = @template_id, @process_id = @process_id, @grid_name = 'deal_fields_mapping', @call_from = 's'
 		END
 		
 		COMMIT TRAN
 		
 		EXEC spa_ErrorHandler 0
 			, 'Deal Field Mapping'
 			, 'spa_template_field_mapping'
 			, 'Success' 
 			, 'Changes have been saved successfully.'
 			, ''
	END TRY
 	BEGIN CATCH
 		DECLARE @desc VARCHAR(500)
 		DECLARE @err_no INT
  
 		IF @@TRANCOUNT > 0
 			ROLLBACK
 	
		SET @desc = dbo.FNAHandleDBError(10106400)
		
 		SELECT @err_no = ERROR_NUMBER()
  
 		EXEC spa_ErrorHandler -1
 			, 'Deal Field Mapping'
 			, 'spa_template_field_mapping'
 			, 'Error'
 			, @desc
 			, ''
 	END CATCH
END