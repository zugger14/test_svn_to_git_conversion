IF OBJECT_ID(N'[dbo].[spa_deal_pricing_detail]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].spa_deal_pricing_detail

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON 
GO

/**
	It is the SP responsible for Insert/Update/Delete the deal complex pricing data.

	Parameters
	@flag : Determines the actions of call for different process for the SP.
	@source_deal_detail_id : Acts as input, it is deal detail id.
	@xml : Form data in XML representation, which will be saved in corresponding tables on the basis of deal detail ID.
	@apply_to_xml : XML data for apply to all feature.
	@is_apply_to_all: Flag to check whether to apply the deal pricing data to all detail ID or not.
	@call_from : Determines where the SP is called from, whether it is for saving purpose in physical table or temporary process table.
	@process_id : It is process id which by which the naming of process table is done.
	@mode : Determines what is the mode of saving, whether it is for saving purpose in physical table or temporary process table.
	@xml_process_id : It is process id which by which the naming of process table of xml data is done.
	@ids_to_apply_price : It stores the deal detail ids to apply pricing.
	@update_status : Status check for process table wether it is updated from front end or not, used for deal copy feature.
	@output : Output variable which set returns the xml process id.
	@report_name : Name of the report.
	@sub_book_id : Sub book id.
*/

CREATE PROCEDURE [dbo].[spa_deal_pricing_detail]
	@flag CHAR(1),
	@source_deal_detail_id VARCHAR(100) = NULL,
	@xml VARCHAR(MAX) = NULL,
	@apply_to_xml VARCHAR(MAX) = NULL,
	@is_apply_to_all CHAR(1) = 'n',
	@call_from VARCHAR(50) = NULL,
	@process_id VARCHAR(200) = NULL,
	@mode CHAR(5) = NULL,
	@xml_process_id VARCHAR(200) = NULL,
	@ids_to_apply_price VARCHAR(MAX) = NULL,
	@update_status BIT = NULL,
	@output VARCHAR(100) = NULL OUTPUT,
	@report_name VARCHAR(100) = NULL,
	@sub_book_id INT = NULL
AS
SET NOCOUNT ON 

/*-----------------Debug Section-------------------
SET NOCOUNT ON
DECLARE @flag CHAR(1) ,
		@xml VARCHAR(MAX) = NULL,
		@apply_to_xml VARCHAR(MAX) = NULL,
		@source_deal_detail_id VARCHAR(100),
		@is_apply_to_all CHAR(1) = 'n',
		@call_from VARCHAR(50) = NULL,
		@process_id VARCHAR(200) = NULL,
		@xml_process_id VARCHAR(200) = NULL,
		@mode CHAR(5) = NULL,
		@ids_to_apply_price VARCHAR(MAX) = NULL,
		@update_status BIT = NULL,
		@output VARCHAR(100) = NULL,
		@report_name VARCHAR(100) = NULL,
		@sub_book_id INT = NULL

SELECT @flag='s',@mode='normal',@xml_process_id=NULL,@source_deal_detail_id='2238176'
----------------------------------------------------*/

DECLARE @source_deal_header_id INT,
		@user_name VARCHAR(100),
		@idoc INT,
		@leg VARCHAR(100),
		@sql VARCHAR(MAX)

SET @user_name = dbo.FNADBUser()

IF NULLIF(@source_deal_detail_id, '') IS NOT NULL AND @flag = 't' AND NULLIF(@ids_to_apply_price, '') IS NULL AND @mode <> 'save'
BEGIN
	EXEC spa_Errorhandler -1, 'Deal Pricing Detail', 'spa_deal_pricing_detail', 'Error', 'No details to apply price for these terms and legs.', @xml_process_id
	RETURN
END

IF OBJECT_ID('tempdb..#update_existing_detail') IS NOT NULL
	DROP TABLE #update_existing_detail

CREATE TABLE #update_existing_detail (
	existence_flag BIT DEFAULT 0
)

IF @xml_process_id IS NOT NULL
BEGIN
	EXEC ('
		INSERT INTO #update_existing_detail (existence_flag)
		SELECT 1
		FROM adiha_process.dbo.pricing_xml_' + @user_name + '_' + @xml_process_id + '
		WHERE source_deal_detail_id = ''' + @source_deal_detail_id + '''
			AND xml_value IS NOT NULL
	')

END

IF @mode = 'fetch'
BEGIN
	DECLARE @new_xml VARCHAR(MAX)
	SET @is_apply_to_all = IIF(@flag = 't', 'y', 'n')
		
	--Generate XML from Source Deal Detail ID
	IF @flag = 't' AND NULLIF(@xml, '') IS NULL AND NOT EXISTS (SELECT 1 FROM #update_existing_detail)
	BEGIN
		SET @new_xml = '<root>'
		
		--Quality Grid
		SELECT @new_xml +=  '<deal_price_qualities><deal_price_quality deal_price_quality_id="' + CAST(deal_price_quality_id AS VARCHAR(10)) + '" attribute="' + ISNULL(CAST(attribute AS VARCHAR(10)), '') + '" operator="' + ISNULL(CAST(operator AS VARCHAR(10)), '') + '", numeric_value="' + ISNULL(dbo.FNARemoveTrailingZero(numeric_value), '') + '" text_value="' + ISNULL(text_value, '') + '" uom="' + ISNULL(CAST(uom AS VARCHAR(10)), '') + '" basis="' + ISNULL(CAST(basis AS VARCHAR(10)), '') + '" /></deal_price_qualities>'
		FROM deal_price_quality 
		WHERE source_deal_detail_id = @source_deal_detail_id
		
		--Deal Pricing
		SELECT @new_xml += '<deal_pricing pricing_aggregation="' + ISNULL(CAST(pricing_type AS VARCHAR(10)), '') + '" tiered="' + IIF(tiered = 'y', 'true','false') + '" settlement_date="' + ISNULL(CONVERT(VARCHAR(10), settlement_date, 120), '') + '" settlement_uom="' + ISNULL(CAST(settlement_uom AS VARCHAR(10)), '') + '" settlement_currency="' + ISNULL(CAST(settlement_currency AS VARCHAR(10)), '') + '" fx_conversion_rate="' + ISNULL(CAST(fx_conversion_rate AS VARCHAR(50)) , '') + '" pricing_description="' + ISNULL(pricing_description, '') + '" />'
		FROM source_deal_detail 
		WHERE source_deal_detail_id = @source_deal_detail_id

		--Fixed Cost
		SELECT @new_xml += '<deal_fixed_cost rid="' + ISNULL(CAST(dpt.deal_price_type_id AS VARCHAR(10)), '')+ '" priority="' + ISNULL(CAST(dpt.priority AS VARCHAR(10)), '') + '" deal_price_type_id="" price_type="' + ISNULL(CAST(dpt.price_type_id AS VARCHAR(10)), '')+ '" price_type_description="' + ISNULL(CAST(description AS VARCHAR(10)), '')+ '" volume="' + ISNULL(dbo.FNARemoveTrailingZeroes(volume), '')+ '" volume_from="' + ISNULL(dbo.FNARemoveTrailingZeroes(volume_from), '')+ '" volume_uom="' + ISNULL(CAST(uom AS VARCHAR(10)), '')+ '" fixed_cost="' + ISNULL(dbo.FNARemoveTrailingZeroes(fixed_cost), '') + '" Fixed_cost_currency="' + ISNULL(CAST(fixed_cost_currency AS VARCHAR(10)), '')+ '" />'
		FROM deal_price_deemed dpd
		LEFT JOIN deal_price_type dpt
			ON dpd.deal_price_type_id = dpt.deal_price_type_id
		WHERE dpd.source_deal_detail_id = @source_deal_detail_id
			AND price_type_id = 103604
			
		--Fixed Price
		SELECT @new_xml += '<deal_fixed_price rid="' + ISNULL(CAST(dpt.deal_price_type_id AS VARCHAR(10)), '')+ '" priority="' + ISNULL(CAST(dpt.priority AS VARCHAR(10)), '') + '" deal_price_type_id="" price_type="' + ISNULL(CAST(dpt.price_type_id AS VARCHAR(10)), '')+ '" price_type_description="' + ISNULL(CAST(description AS VARCHAR(10)), '')+ '" volume="' + ISNULL(dbo.FNARemoveTrailingZeroes(NULLIF(CAST(dpd.volume AS FLOAT), '')), '') + '" volume_from="' + ISNULL(dbo.FNARemoveTrailingZeroes(NULLIF(CAST(dpd.volume_from AS FLOAT), '')), '') + '" volume_uom="' + ISNULL(CAST(uom AS VARCHAR(10)), '')+ '" fixed_price="' + ISNULL(dbo.FNARemoveTrailingZeroes(fixed_price), '') + '" pricing_currency="' + ISNULL(CAST(dpd.currency AS VARCHAR(50)), '') + '" pricing_uom="' + ISNULL(CAST(dpd.pricing_uom AS VARCHAR(50)), '') + '"  />'
		FROM deal_price_deemed dpd
		LEFT JOIN deal_price_type dpt
			ON dpd.deal_price_type_id = dpt.deal_price_type_id
		WHERE dpd.source_deal_detail_id = @source_deal_detail_id
			AND price_type_id = 103600
		
		DECLARE @formula_ids INT, @fmla_process_id VARCHAR(50)
		SET @fmla_process_id = dbo.FNAGetNewID()
		DECLARE @formula_process_table VARCHAR(300) = dbo.FNAProcessTableName('formula_editor', @user_name, @fmla_process_id)
	
		SELECT @formula_ids = dpd.formula_id  
		FROM deal_price_deemed  dpd
		WHERE dpd.source_deal_detail_id = @source_deal_detail_id
			AND dpd.formula_id IS NOT NULL
			
		IF OBJECT_ID ('tempdb..#resolve_formula') IS NOT NULL
			DROP TABLE #resolve_formula
			
		CREATE TABLE #resolve_formula (
			formula_id INT,
			formula_name VARCHAR(MAX)
		)
	
		IF @formula_ids IS NOT NULL
		BEGIN
			EXEC spa_resolve_function_parameter @flag = 's', @process_id = @fmla_process_id, @formula_id = @formula_ids
			INSERT INTO #resolve_formula
			EXEC ('SELECT * FROM ' + @formula_process_table + '') 
		END
		
		--Deal Formula
		SELECT @new_xml += '<deal_formula rid="' + ISNULL(CAST(dpt.deal_price_type_id AS VARCHAR(10)), '')+ '" priority="' + ISNULL(CAST(dpt.priority AS VARCHAR(10)), '') + '" deal_price_type_id="" price_type="' + ISNULL(CAST(dpt.price_type_id AS VARCHAR(10)), '')+ '" price_type_description="' + ISNULL(CAST(description AS VARCHAR(10)), '')+ '" volume="' + ISNULL(dbo.FNARemoveTrailingZeroes(NULLIF(CAST(dpd.volume AS FLOAT), '')), '') + '" volume_from="' + ISNULL(dbo.FNARemoveTrailingZeroes(NULLIF(CAST(dpd.volume_from AS FLOAT), '')), '') + '" volume_uom="' + ISNULL(CAST(uom AS VARCHAR(10)), '')+ '" formula_id="' + ISNULL(CAST(tf.formula_id AS VARCHAR(10)), '') + '" formula_name="' + ISNULL(tf.formula_name, (ISNULL(CAST(tf.formula_id AS VARCHAR(10)), ''))) + '" formula_currency="' + ISNULL(CAST(formula_currency AS VARCHAR(10)), '') + '"  />'
		FROM deal_price_deemed dpd
		LEFT JOIN deal_price_type dpt
			ON dpd.deal_price_type_id = dpt.deal_price_type_id
		LEFT JOIN #resolve_formula tf
					ON tf.formula_id = dpd.formula_id
		WHERE dpd.source_deal_detail_id = @source_deal_detail_id
			AND price_type_id = 103602
		
		--Deal Indexed
		SELECT @new_xml += '<deal_index rid="' + ISNULL(CAST(dpd.deal_price_deemed_id AS VARCHAR(10)), '')+ '" priority="' + ISNULL(CAST(dpt.priority AS VARCHAR(10)), '') + '" deal_price_type_id="" price_type="' + ISNULL(CAST(dpt.price_type_id AS VARCHAR(10)), '')+ '" price_type_description="' + ISNULL(CAST(description AS VARCHAR(10)), '')+ '" volume="' + ISNULL(dbo.FNARemoveTrailingZeroes(NULLIF(CAST(dpd.volume AS FLOAT), '')), '') + '" volume_from="' + ISNULL(dbo.FNARemoveTrailingZeroes(NULLIF(CAST(dpd.volume_from AS FLOAT), '')), '') + '" volume_uom="' + ISNULL(CAST(uom AS VARCHAR(10)), '')+ '" pricing_index="' + ISNULL(CAST(pricing_index AS VARCHAR(10)), '') + '" pricing_period="' + ISNULL(CAST(pricing_period AS VARCHAR(10)), '') + '" pricing_start="' + ISNULL(CONVERT(VARCHAR(10), pricing_start, 120), '') + '" pricing_end="' + ISNULL(CONVERT(VARCHAR(10), pricing_end, 120), '') + '" balmo_pricing="' + CAST(IIF(dpd.bolmo_pricing = 'y', 'true','false') AS VARCHAR(50)) + '" include_weekends="' + CAST(IIF(dpd.include_weekends = 'y', 'true','false') AS VARCHAR(50))  + '" multiplier="' + ISNULL(CAST(dpd.multiplier AS VARCHAR(50)), '')  + '" adder="' + ISNULL(CAST(dpd.adder AS VARCHAR(50)), '') + '" adder_currency="' + ISNULL(CAST(dpd.adder_currency AS VARCHAR(50)), '')  + '" rounding="' + ISNULL(CAST(dpd.rounding AS VARCHAR(50)), '') + '" />'
		FROM deal_price_deemed dpd
		LEFT JOIN deal_price_type dpt
			ON dpd.deal_price_type_id = dpt.deal_price_type_id
		WHERE dpd.source_deal_detail_id = @source_deal_detail_id
			AND price_type_id = 103601

		--Deal Std Event
		SELECT @new_xml += '<deal_std_event rid="' + ISNULL(CAST(s.deal_price_std_event_id AS VARCHAR(10)), '') + '" priority="' + ISNULL(CAST(dpt.priority AS VARCHAR(10)), '') + '" deal_price_type_id="" price_type="' + ISNULL(CAST(dpt.price_type_id AS VARCHAR(10)), '')+ '" price_type_description="' + ISNULL(CAST(description AS VARCHAR(10)), '')+ '" event_type="' + ISNULL(CAST(event_type AS VARCHAR(10)), '') + '" event_date="' + ISNULL(CONVERT(VARCHAR(10), event_date, 120), '') + '" pricing_index="' + ISNULL(CAST(pricing_index AS VARCHAR(10)), '') + '" adder="' + ISNULL(CAST(adder AS VARCHAR(10)), '') + '" adder_currency="' + ISNULL(CAST(currency AS VARCHAR(10)), '') + '" multiplier="' + ISNULL(CAST(multiplier AS VARCHAR(10)), '') + '" rounding="' + ISNULL(CAST(rounding AS VARCHAR(10)), '') + '" volume="' + ISNULL(dbo.FNARemoveTrailingZeroes(volume), '') + '" volume_from="' + ISNULL(dbo.FNARemoveTrailingZeroes(volume_from), '') + '" volume_uom="' + ISNULL(CAST(uom AS VARCHAR(10)), '') + '" pricing_month="' + ISNULL(CAST(pricing_month AS VARCHAR(10)), '') + '" />'
		FROM deal_price_std_event s
		INNER JOIN deal_price_type dpt
			ON s.deal_price_type_id = dpt.deal_price_type_id
		WHERE s.source_deal_detail_id = @source_deal_detail_id

		--Deal Custom Event
		SELECT @new_xml += '<deal_custom_event rid="' + ISNULL(CAST(c.deal_price_custom_event_id AS VARCHAR(10)), '') + '" priority="' + ISNULL(CAST(dpt.priority AS VARCHAR(10)), '') + '" deal_price_type_id="" price_type="' + ISNULL(CAST(dpt.price_type_id AS VARCHAR(10)), '')+ '" price_type_description="' + ISNULL(CAST(description AS VARCHAR(10)), '')+ '" event_type="' + ISNULL(CAST(event_type AS VARCHAR(10)), '') + '" event_date="' + ISNULL(CONVERT(VARCHAR(10), event_date, 120), '') + '" pricing_index="' + ISNULL(CAST(pricing_index AS VARCHAR(10)), '') + '" skip_days="' + ISNULL(CAST(skip_days AS VARCHAR(10)), '') + '" quotes_before="' + ISNULL(CAST(quotes_before AS VARCHAR(10)), '') + '" quotes_after="' + ISNULL(CAST(quotes_after AS VARCHAR(10)), '') + '" include_event_date="' +  CAST(IIF(c.include_event_date = 'y', 'true','false') AS VARCHAR(50)) + '" include_weekends="' + CAST(IIF(c.include_holidays = 'y', 'true','false') AS VARCHAR(50)) + '" adder="' + ISNULL(CAST(c.adder AS VARCHAR(50)), '') + '" adder_currency="' + ISNULL(CAST(c.currency AS VARCHAR(50)), '') + '" multiplier="' + ISNULL(CAST(c.multiplier AS VARCHAR(50)), '') + '" rounding="' +ISNULL(CAST(c.rounding AS VARCHAR(50)), '') + '" volume="' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(c.volume) AS VARCHAR(50)), '') + '" volume_from="' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(c.volume_from) AS VARCHAR(50)), '') + '" volume_uom="' +ISNULL(CAST(c.uom AS VARCHAR(50)), '') + '" pricing_month="' + CAST(ISNULL(CONVERT(VARCHAR(100), c.pricing_month, 120) , '') AS VARCHAR(50)) + '" skip_granularity="' + ISNULL(CAST(c.skip_granularity AS VARCHAR(50)), '') + '" />'
		FROM deal_price_custom_event c
		INNER JOIN deal_price_type dpt
			ON c.deal_price_type_id = dpt.deal_price_type_id
		WHERE c.source_deal_detail_id = @source_deal_detail_id

		--Predefined formula
		SELECT @new_xml += '<deal_predefined_formula rid="' + ISNULL(CAST(dpt.deal_price_type_id AS VARCHAR(10)), '') + '" priority="' + ISNULL(CAST(dpt.priority AS VARCHAR(10)), '') + '" deal_price_type_id="" price_type="' + ISNULL(CAST(dpt.price_type_id AS VARCHAR(10)), '')+ '" price_type_description="' + ISNULL(CAST(description AS VARCHAR(10)), '')+ '" formula_id="' + ISNULL(CAST(sub.formula_id AS VARCHAR(10)), '') + '"><udf ' + STUFF((SELECT ', ' + ' name="UDF___' +  ISNULL(CAST(udf_template_id AS VARCHAR(10)), '') + '" value="' + ISNULL(udf_value, '') + '"' FROM deal_detail_formula_udf ddfu WHERE ddfu.deal_price_type_id = dpt.deal_price_type_id FOR XML PATH('')), 1, 2, '') + ' /></deal_predefined_formula>'
		FROM deal_price_type dpt
		OUTER APPLY (
			SELECT DISTINCT formula_id 
			FROM deal_detail_formula_udf u 
			WHERE u.deal_price_type_id = dpt.deal_price_type_id
		) sub
		WHERE dpt.source_deal_detail_id = @source_deal_detail_id
		AND price_type_id = 103606 
		
		--Deal Price Adjustment
		SELECT @new_xml += '<deal_price_adjustment rid="' + ISNULL(CAST(dpt.deal_price_type_id AS VARCHAR(10)), '') + '" priority="' + ISNULL(CAST(dpt.priority AS VARCHAR(10)), '') + '" deal_price_type_id="" price_type="' + ISNULL(CAST(dpt.price_type_id AS VARCHAR(10)), '')+ '" price_type_description="' + ISNULL(CAST(description AS VARCHAR(10)), '')+ '" formula_id="' + ISNULL(CAST(sub.formula_id AS VARCHAR(10)), '') + '"><udf ' + STUFF((SELECT ', ' + ' name="UDF___' +  ISNULL(CAST(udf_template_id AS VARCHAR(10)), '') + '" value="' + ISNULL(udf_value, '') + '"' FROM deal_price_adjustment ddfu WHERE ddfu.deal_price_type_id = dpt.deal_price_type_id FOR XML PATH('')), 1, 2, '') + ' /></deal_price_adjustment>'
		FROM deal_price_type dpt
		OUTER APPLY (
			SELECT DISTINCT formula_id 
			FROM deal_price_adjustment u 
			WHERE u.deal_price_type_id = dpt.deal_price_type_id
		) sub
		WHERE dpt.source_deal_detail_id = @source_deal_detail_id
			AND price_type_id = 103607

		SET @new_xml += '</root>'
	END
	
	IF @xml_process_id IS NOT NULL
	BEGIN
		DECLARE @xml_from_process_table VARCHAR(MAX)
		
		IF OBJECT_ID ('tempdb..#get_xml') IS NOT NULL
			DROP TABLE #get_xml

		CREATE TABLE #get_xml (
			xml_value VARCHAR(MAX)
		)

		EXEC('
			INSERT INTO #get_xml
			SELECT xml_value 
			FROM adiha_process.dbo.pricing_xml_' + @user_name + '_' + @xml_process_id + '
			WHERE source_deal_detail_id = ''' + @source_deal_detail_id + '''
		')

		SELECT @xml_from_process_table = xml_value
		FROM #get_xml
	END
	
	IF OBJECT_ID('tempdb..#source_table') IS NOT NULL
		DROP TABLE #source_table

	CREATE TABLE #source_table (
		flag CHAR(1) COLLATE DATABASE_DEFAULT,
		source_deal_detail_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
		xml_value VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		apply_to_xml VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		is_apply_to_all	CHAR(1) COLLATE DATABASE_DEFAULT,
		call_from VARCHAR(50) COLLATE DATABASE_DEFAULT,
		process_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		update_status BIT
	)
	
	IF NULLIF(@ids_to_apply_price, '') IS NOT NULL
		INSERT INTO #source_table
		SELECT @flag, i.item, COALESCE(NULLIF(@xml, ''), NULLIF(@new_xml,''), @xml_from_process_table), @apply_to_xml, @is_apply_to_all, @call_from, @process_id, @update_status
		FROM dbo.SplitCommaSeperatedValues(@ids_to_apply_price) i
	ELSE
		INSERT INTO #source_table
		SELECT @flag, @source_deal_detail_id, @xml, @apply_to_xml, @is_apply_to_all, @call_from, @process_id, @update_status
	
	DECLARE @xml_process_table VARCHAR(100)	
	
	IF NULLIF(@xml_process_id, '') IS NULL
	BEGIN
		SET @xml_process_id = dbo.FNAGetNewID();
		SET @xml_process_table = 'adiha_process.dbo.pricing_xml_' + @user_name + '_' + @xml_process_id

		SET @sql = '
			IF OBJECT_ID(''' + @xml_process_table + ''') IS NOT NULL
				DROP TABLE ' + @xml_process_table + '

			CREATE TABLE ' + @xml_process_table + ' (
				flag CHAR(1) COLLATE DATABASE_DEFAULT,
				source_deal_detail_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				xml_value VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
				apply_to_xml VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
				is_apply_to_all	CHAR(1) COLLATE DATABASE_DEFAULT,
				call_from VARCHAR(50) COLLATE DATABASE_DEFAULT,
				process_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
				update_status BIT
			)
		'
		EXEC (@sql)
	END
	ELSE 
	BEGIN
		SET @xml_process_table = 'adiha_process.dbo.pricing_xml_' + @user_name + '_' + @xml_process_id
	END
	
	
	SET @sql = '
		MERGE ' + @xml_process_table + ' AS t
		USING (
			SELECT source_deal_detail_id, xml_value, apply_to_xml, is_apply_to_all, call_from, process_id, update_status
			FROM #source_table
			) AS s
		ON (t.source_deal_detail_id = s.source_deal_detail_id) 
		WHEN NOT MATCHED BY TARGET 
		THEN 
			INSERT(flag, source_deal_detail_id, xml_value, apply_to_xml, is_apply_to_all, call_from, process_id, update_status) 
			VALUES(''m'', s.source_deal_detail_id, s.xml_value, s.apply_to_xml, s.is_apply_to_all, s.call_from, s.process_id, s.update_status)
		WHEN MATCHED 
		THEN 
			UPDATE 
			SET flag = ''m'',
				xml_value = s.xml_value,
				apply_to_xml = s.apply_to_xml,
				is_apply_to_all = s.is_apply_to_all,
				call_from = s.call_from,
				process_id = s.process_id,
				update_status = s.update_status;		
	'
	
	EXEC (@sql)
	SET @output = @xml_process_id
	EXEC spa_Errorhandler 0, 'Deal Pricing Detail', 'spa_deal_pricing_detail', 'Success', 'Changes have been saved successfully.', @xml_process_id
	RETURN
END

SET @process_id = IIF(NULLIF(@process_id, '') IS NULL, dbo.FNAGetNewID(), @process_id) 

IF ISNUMERIC(@source_deal_detail_id) = 1
BEGIN
	SELECT @source_deal_header_id = source_deal_header_id 
	FROM source_deal_detail 
	WHERE source_deal_detail_id = @source_deal_detail_id
END

IF @flag = 'm' OR @flag = 'p' OR @flag = 'n' OR (@flag = 's' AND EXISTS (SELECT 1 FROM #update_existing_detail))
BEGIN
	IF @flag = 's'
	BEGIN
		IF @xml_process_id IS NULL
		BEGIN
			SELECT NULL form_json,
				   NULL grid_json,
				   NULL deemed_form_json,
				   NULL std_form_json,
				   NULL custom_form_json, 
				   NULL predefined_formula,
				   NULL enable_prev,
				   NULL enable_next,
				   NULL detail_info,
				   NULL price_adjustment,
				   NULL quality_grid_json
			RETURN
		END

		IF OBJECT_ID('tempdb..#pricing_xml_detail') IS NOT NULL
			DROP TABLE #pricing_xml_detail
	
		CREATE TABLE #pricing_xml_detail (
			source_deal_detail_id VARCHAR(100),
			xml_value VARCHAR(MAX)
		)
	
		EXEC('
			INSERT INTO #pricing_xml_detail
			SELECT source_deal_detail_id,
				   xml_value
			FROM adiha_process.dbo.pricing_xml_' + @user_name + '_' + @xml_process_id + '
			WHERE source_deal_detail_id = ''' + @source_deal_detail_id + '''
			'
		)
	
		SELECT @xml = xml_value
		FROM #pricing_xml_detail
	END
	
	IF OBJECT_ID('tempdb..#deal_price_quality') IS NOT NULL
		DROP TABLE #deal_price_quality
	IF OBJECT_ID('tempdb..#deal_pricing') IS NOT NULL
		DROP TABLE #deal_pricing
	IF OBJECT_ID('tempdb..#deal_price_type') IS NOT NULL
		DROP TABLE #deal_price_type		
	IF OBJECT_ID('tempdb..#deal_price_deemed') IS NOT NULL
		DROP TABLE #deal_price_deemed
	IF OBJECT_ID('tempdb..#deal_price_std_event') IS NOT NULL
		DROP TABLE #deal_price_std_event
	IF OBJECT_ID('tempdb..#deal_price_custom_event') IS NOT NULL
		DROP TABLE #deal_price_custom_event
	IF OBJECT_ID('tempdb..#deal_detail_formula_udf') IS NOT NULL
		DROP TABLE #deal_detail_formula_udf
	IF OBJECT_ID('tempdb..#deal_price_adjustment') IS NOT NULL
		DROP TABLE #deal_price_adjustment

	CREATE TABLE #deal_price_quality (
		deal_price_quality_id VARCHAR(200),
		attribute  VARCHAR(200),
		operator  VARCHAR(200),
		numeric_value  VARCHAR(200),
		text_value  VARCHAR(200),
		uom VARCHAR(200),
		basis VARCHAR(200)
	)
		
	CREATE TABLE #deal_pricing (
		pricing_aggregation  VARCHAR(200),
		is_tiered  VARCHAR(200),
		settlement_date  VARCHAR(200),
		settlement_uom  VARCHAR(200),
		settlement_currency  VARCHAR(200),
		fx_conversion_rate  VARCHAR(200),
		pricing_description VARCHAR(200)
	)

	CREATE TABLE #deal_price_type(
		rid VARCHAR(100),
		priority VARCHAR(100) NULL,
		deal_price_type_id INT,
		source_deal_detail_id VARCHAR(100),
		price_type INT,
		description VARCHAR(500)		
	)

	CREATE TABLE #deal_price_deemed(
		rid VARCHAR(100) NULL,
		price_type VARCHAR(200)  NULL,
		price_type_description  VARCHAR(200) NULL ,
		[deal_price_deemed_id] VARCHAR(200) NULL,
		[source_deal_detail_id] VARCHAR(200) NULL,
		[pricing_index] VARCHAR(200)NULL,
		[pricing_start] VARCHAR(200)NULL,
		[pricing_end] VARCHAR(200)NULL,
		[adder] VARCHAR(200) NULL,
		[currency] VARCHAR(200)NULL,
		[multiplier] VARCHAR(200) NULL,
		[volume] VARCHAR(200) NULL,
		[volume_from] VARCHAR(200) NULL,
		[uom] VARCHAR(200)NULL,
		[pricing_provisional] VARCHAR(200)  NULL,
		[pricing_type] VARCHAR(200) NULL,
		[pricing_period] VARCHAR(200)NULL,
		[fixed_price] VARCHAR(200) NULL,
		[pricing_uom] VARCHAR(200)NULL,
		[adder_currency] VARCHAR(200)NULL,
		[formula_id] VARCHAR(200)NULL,
		[priority] VARCHAR(200)NULL,
		[formula_currency] VARCHAR(200)NULL,
		[fixed_cost] VARCHAR(200) NULL,
		[fixed_cost_currency] VARCHAR(200)NULL,
		[deal_price_type_id] VARCHAR(200)NULL,
		[include_weekends] VARCHAR(200),
		[rounding] VARCHAR(200) NULL,
		[balmo_pricing] VARCHAR(20) NULL,
	)

	CREATE TABLE #deal_price_std_event(
		rid VARCHAR(100) NULL,
		priority VARCHAR(100) NULL,
		price_type VARCHAR(200)  NULL,
		price_type_description  VARCHAR(200) NULL ,
		[deal_price_std_event_id] VARCHAR(200) NULL,
		[source_deal_detail_id] VARCHAR(200) NULL,
		[event_type] VARCHAR(200)NULL,
		[event_date] VARCHAR(200)NULL,
		[event_pricing_type] VARCHAR(200)NULL,
		[pricing_index] VARCHAR(200)NULL,
		[adder] VARCHAR(200) NULL,
		[currency] VARCHAR(200)NULL,
		[multiplier] VARCHAR(200) NULL,
		[volume] VARCHAR(200) NULL,
		[volume_from] VARCHAR(200) NULL,
		[uom] VARCHAR(200)NULL,
		[pricing_provisional] VARCHAR(200) NULL,
		[pricing_type] VARCHAR(200) NULL,
		[deal_price_type_id] VARCHAR(200)NULL,
		adder_currency VARCHAR(200) NULL,
		rounding VARCHAR(200) NULL,
		pricing_month VARCHAR(200) NULL
	)

	CREATE TABLE #deal_price_custom_event (
		rid VARCHAR(100) NULL,
		priority VARCHAR(100) NULL,
		price_type VARCHAR(200)  NULL,
		price_type_description  VARCHAR(200) NULL ,
		[deal_price_custom_event_id] VARCHAR(200) NULL,
		[source_deal_detail_id] VARCHAR(200) NULL,
		[event_type] VARCHAR(200)NULL,
		[event_date] VARCHAR(200)NULL,
		[pricing_index] VARCHAR(200)NOT NULL,
		[skip_days] VARCHAR(200)NULL,
		[quotes_before] VARCHAR(200)NULL,
		[quotes_after] VARCHAR(200)NULL,
		[include_event_date] VARCHAR(200) NULL,
		[include_holidays] VARCHAR(200) NULL,
		[adder] VARCHAR(200) NULL,
		[currency] VARCHAR(200)NULL,
		[multiplier] VARCHAR(200) NULL,
		[volume] VARCHAR(200) NULL,
		[volume_from] VARCHAR(200) NULL,
		[uom] VARCHAR(200)NULL,
		[pricing_provisional] VARCHAR(200) NULL,
		[pricing_type] VARCHAR(200) NULL,
		[deal_price_type_id] VARCHAR(200)NULL,
		adder_currency VARCHAR(200) NULL,
		rounding VARCHAR(200),
		pricing_month VARCHAR(200) NULL,
		skip_granularity INT
	)

	CREATE TABLE #deal_detail_formula_udf (
		rid VARCHAR(100) NULL,
		priority VARCHAR(100) NULL,
		price_type VARCHAR(200)  NULL,
		price_type_description  VARCHAR(200) NULL ,
		formula_id VARCHAR(200) NULL,
		deal_detail_formula_udf_id VARCHAR(200) NULL,		
		deal_price_type_id VARCHAR(200) NULL,
		source_deal_detail_id VARCHAR(200) NULL,
		udf_template_id VARCHAR(200) NULL,
		udf_value VARCHAR(200) NULL
	)
	
	CREATE TABLE #deal_price_adjustment (
		rid VARCHAR(100) NULL,
		priority VARCHAR(100) NULL,
		price_type VARCHAR(200)  NULL,
		price_type_description  VARCHAR(200) NULL,		
		deal_price_adjustment_id VARCHAR(200) NULL,				
		source_deal_detail_id VARCHAR(200) NULL,
		udf_template_id VARCHAR(200) NULL,
		udf_value VARCHAR(200) NULL,
		formula_id VARCHAR(200) NULL,
		deal_price_type_id VARCHAR(200) NULL		
	)
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	INSERT INTO #deal_price_quality (
		deal_price_quality_id
		,attribute		
		,operator		
		,numeric_value	
		,text_value		
		,uom				
		,basis			
	)
	SELECT *	
	FROM OPENXML(@idoc, '/root/deal_price_qualities/deal_price_quality', 1)
	WITH (
		deal_price_quality_id VARCHAR(200),
		attribute VARCHAR(200),		
		operator VARCHAR(200),		
		numeric_value VARCHAR(200),	
		text_value	 VARCHAR(200),	
		uom VARCHAR(200),			
		basis VARCHAR(200)
	)	
	
	INSERT INTO #deal_pricing (
		pricing_aggregation ,
		is_tiered ,
		settlement_date ,
		settlement_uom ,
		settlement_currency ,
		fx_conversion_rate ,
		pricing_description 
	)
	SELECT *	
	FROM OPENXML(@idoc, '/root/deal_pricing', 1)
	WITH (
		pricing_aggregation VARCHAR(200), 
		tiered VARCHAR(200),
		settlement_date VARCHAR(200), 
		settlement_uom VARCHAR(200), 
		settlement_currency VARCHAR(200), 
		fx_conversion_rate VARCHAR(200), 
		pricing_description VARCHAR(200)
	)

	INSERT INTO #deal_price_deemed (
		rid			
		, priority			
		, deal_price_type_id		
		, price_type				
		, price_type_description	
		, fixed_cost				
		, Fixed_cost_currency		
		, volume					
		, volume_from					
		, uom	
		, source_deal_detail_id	
		, pricing_provisional		
	) 
	SELECT *, -100	, 'x'
	FROM OPENXML(@idoc, '/root/deal_fixed_cost', 1)
	WITH (
		rid VARCHAR(200),
		priority VARCHAR(200),
		deal_price_type_id VARCHAR(200),
		price_type VARCHAR(200), 
		price_type_description VARCHAR(200),
		fixed_cost VARCHAR(200), 
		Fixed_cost_currency VARCHAR(200), 
		volume VARCHAR(200), 
		volume_from VARCHAR(200), 
		volume_uom VARCHAR(200)
	)

	INSERT INTO #deal_price_deemed (
		rid				
		, priority
		, deal_price_type_id		
		, price_type				
		, price_type_description	
		, fixed_price				
		, currency
		, pricing_uom		
		, volume					
		, volume_from					
		, uom				
	) 
	SELECT *	
	FROM OPENXML(@idoc, '/root/deal_fixed_price', 1)
	WITH (
		rid VARCHAR(200),
		priority VARCHAR(200),
		deal_price_type_id VARCHAR(200),
		price_type VARCHAR(200), 
		price_type_description VARCHAR(200),
		fixed_price VARCHAR(200), 
		pricing_currency VARCHAR(200), 
		pricing_uom VARCHAR(200),
		volume VARCHAR(200), 
		volume_from VARCHAR(200), 
		volume_uom VARCHAR(200)
	)

	INSERT INTO #deal_price_deemed (
		rid		
		, priority				
		, deal_price_type_id		
		, price_type				
		, price_type_description	
		, formula_id  
		, formula_currency
		, volume					
		, volume_from					
		, uom				
	) 
	SELECT *	
	FROM OPENXML(@idoc, '/root/deal_formula', 1)
	WITH (
		rid VARCHAR(200),
		priority VARCHAR(200),
		deal_price_type_id VARCHAR(200),
		price_type VARCHAR(200), 
		price_type_description VARCHAR(200),
		formula_id VARCHAR(200), 
		formula_currency VARCHAR(200), 
		volume VARCHAR(200), 
		volume_from VARCHAR(200), 
		volume_uom VARCHAR(200)
	)

	INSERT INTO #deal_price_deemed (
		rid		
		, priority					
		, deal_price_type_id			
		, price_type					
		, price_type_description		
		, pricing_index				
		, pricing_period				
		, pricing_start				
		, pricing_end					
		, include_weekends			
		, multiplier					
		, adder						
		, adder_currency				
		, rounding					
		, volume						
		, volume_from						
		, uom					
		, balmo_pricing				
	) 
	SELECT rid	
		, priority						
		, deal_price_type_id			
		, price_type					
		, price_type_description		
		, pricing_index				
		, pricing_period				
		, pricing_start				
		, pricing_end					
		, CASE WHEN include_weekends = 'true' THEN 'y' ELSE 'N' END 			
		, multiplier					
		, adder						
		, adder_currency				
		, rounding					
		, volume						
		, volume_from						
		, volume_uom		
		, CASE WHEN balmo_pricing = 'true' THEN 'y' ELSE 'n' END 	
	FROM OPENXML(@idoc, '/root/deal_index', 1)
	WITH (
		rid VARCHAR(200),
		priority VARCHAR(200),
		deal_price_type_id VARCHAR(200),
		price_type VARCHAR(200), 
		price_type_description VARCHAR(200),
		pricing_index VARCHAR(200), 
		pricing_period VARCHAR(200), 
		pricing_start VARCHAR(200), 
		pricing_end VARCHAR(200),
		include_weekends VARCHAR(200), 
		multiplier VARCHAR(200),
		adder VARCHAR(200),
		adder_currency VARCHAR(200),
		rounding VARCHAR(200),
		volume VARCHAR(200),
		volume_from VARCHAR(200),
		volume_uom VARCHAR(200),
		balmo_pricing CHAR(200)
	)
	
	INSERT INTO #deal_price_std_event (
		rid		
		, priority				
		, deal_price_type_id		
		, price_type				
		, price_type_description	
		, event_type  
		, event_date
		, pricing_index
		, adder
		, adder_currency
		, multiplier
		, rounding
		, volume
		, volume_from
		, uom
		, pricing_month
	) 
	SELECT	*
	FROM OPENXML(@idoc, '/root/deal_std_event', 1)
	WITH (
		rid	 VARCHAR(200)			
		, priority VARCHAR(200)		
		, deal_price_type_id VARCHAR(200)
		, price_type VARCHAR(200)				
		, price_type_description VARCHAR(200)	
		, event_type VARCHAR(200)  
		, event_date VARCHAR(200)
		, pricing_index	VARCHAR(200)				
		, adder VARCHAR(200)
		, adder_currency VARCHAR(200)
		, multiplier VARCHAR(200)
		, rounding VARCHAR(200)
		, volume VARCHAR(200)
		, volume_from VARCHAR(200)
		, volume_uom VARCHAR(200)
		, pricing_month VARCHAR(200)
	)
		
	INSERT INTO #deal_price_custom_event (
		rid		
		, priority				
		, deal_price_type_id		
		, price_type				
		, price_type_description	
		, event_type  
		, event_date
		, pricing_index					
		, skip_days			
		, quotes_before
		, quotes_after	
		, include_event_date
		, include_holidays
		, adder
		, currency
		, multiplier
		, rounding
		, volume
		, volume_from
		, uom
		, pricing_month
		, skip_granularity
	) 
	SELECT	rid		
		, priority				
		, deal_price_type_id		
		, price_type				
		, price_type_description	
		, event_type  
		, event_date
		, pricing_index					
		, skip_days			
		, quotes_before	
		, quotes_after
		, CASE WHEN include_event_date = 'true' THEN 'y' ELSE 'N' END  
		, CASE WHEN include_weekends = 'true' THEN 'y' ELSE 'N' END 
		, adder
		, adder_currency
		, multiplier
		, rounding
		, volume
		, volume_from
		, volume_uom
		, pricing_month
		, skip_granularity
	FROM OPENXML(@idoc, '/root/deal_custom_event', 1)
	WITH (
		rid	 VARCHAR(200)	
		, priority VARCHAR(200)				
		, deal_price_type_id VARCHAR(200)
		, price_type VARCHAR(200)				
		, price_type_description VARCHAR(200)	
		, event_type VARCHAR(200)  
		, event_date VARCHAR(200)
		, pricing_index	VARCHAR(200)				
		, skip_days VARCHAR(200)			
		, quotes_before VARCHAR(200)
		, quotes_after VARCHAR(200)	
		, include_event_date VARCHAR(200)
		, include_weekends VARCHAR(200)
		, adder VARCHAR(200)
		, adder_currency VARCHAR(200)
		, multiplier VARCHAR(200)
		, rounding VARCHAR(200)
		, volume VARCHAR(200)
		, volume_from VARCHAR(200)
		, volume_uom VARCHAR(200)
		, pricing_month VARCHAR(200)
		, skip_granularity INT
	)

	INSERT INTO #deal_detail_formula_udf(
		rid,
		priority,
		price_type,
		price_type_description,
		formula_id,
		deal_price_type_id,
		source_deal_detail_id,
		udf_template_id,
		udf_value
		
	)
	SELECT rid
			, priority
			, price_type
			, price_type_description
			, formula_id
			, deal_price_type_id
			, @source_deal_detail_id
			, SUBSTRING(name, 7, LEN(name))
			, value 
	FROM OPENXML(@idoc, '/root/deal_predefined_formula/udf', 1)
	WITH (
		rid	 VARCHAR(200) '../@rid'	
		, priority VARCHAR(200) '../@priority'	
		, price_type VARCHAR(200) '../@price_type'	
		, price_type_description VARCHAR(200) '../@price_type_description'	
		, formula_id VARCHAR(200) '../@formula_id'	
		, deal_price_type_id VARCHAR(200) '../@deal_price_type_id'				
		, name VARCHAR(200)
		, value VARCHAR(200)
	)

	INSERT INTO #deal_price_adjustment(
		rid,
		priority,
		price_type,
		price_type_description,
		formula_id,
		deal_price_type_id,
		source_deal_detail_id,
		udf_template_id,
		udf_value

	)
	SELECT rid
			, priority
			, price_type
			, price_type_description
			, formula_id
			, deal_price_type_id
			, @source_deal_detail_id
			, SUBSTRING(name, 7, LEN(name))
			, value 
	FROM OPENXML(@idoc, '/root/deal_price_adjustment/udf', 1)
	WITH (
		rid	 VARCHAR(200) '../@rid'	
		, priority VARCHAR(200) '../@priority'	
		, price_type VARCHAR(200) '../@price_type'	
		, price_type_description VARCHAR(200) '../@price_type_description'	
		, formula_id VARCHAR(200) '../@formula_id'	
		, deal_price_type_id VARCHAR(200) '../@deal_price_type_id'				
		, name VARCHAR(200)
		, value VARCHAR(200)
	)

	IF @is_apply_to_all = 'y'
	BEGIN
		UPDATE #deal_price_deemed
		SET deal_price_type_id = NULL

		UPDATE #deal_price_std_event
		SET deal_price_type_id = NULL
		
		UPDATE #deal_price_custom_event
		SET deal_price_type_id = NULL

		UPDATE #deal_detail_formula_udf
		SET deal_price_type_id = NULL

		UPDATE #deal_price_adjustment
		SET deal_price_type_id = NULL
	END

	INSERT INTO #deal_price_type (
		rid,
		priority,
		deal_price_type_id,
		source_deal_detail_id,
		price_type,
		description
	)
	SELECT rid, priority, NULLIF(deal_price_type_id, ''), @source_deal_detail_id, price_type, price_type_description FROM #deal_price_deemed  UNION ALL
	SELECT rid, priority, NULLIF(deal_price_type_id, ''), @source_deal_detail_id, price_type, price_type_description  FROM #deal_price_std_event  UNION ALL
	SELECT rid, priority, NULLIF(deal_price_type_id, ''), @source_deal_detail_id, price_type, price_type_description  FROM #deal_price_custom_event UNION ALL	
	SELECT DISTINCT rid, priority, NULLIF(deal_price_type_id, ''), @source_deal_detail_id, price_type, price_type_description  FROM #deal_detail_formula_udf  UNION ALL
	SELECT DISTINCT rid, priority, NULLIF(deal_price_type_id, ''), @source_deal_detail_id, price_type, price_type_description  FROM #deal_price_adjustment
	
	IF @flag <> 's'
	BEGIN
		BEGIN TRY
		BEGIN TRAN

			DELETE ddfu  
			FROM deal_price_adjustment ddfu
			LEFT JOIN #deal_price_type t 
				ON ddfu.deal_price_type_id = t.deal_price_type_id
				AND t.deal_price_type_id IS NOT NULL 
			WHERE ddfu.source_deal_detail_id = @source_deal_detail_id
				AND t.deal_price_type_id IS NULL
		
			DELETE dpt  
			FROM deal_price_type dpt
			LEFT JOIN #deal_price_type t 
				ON dpt.deal_price_type_id = t.deal_price_type_id
				AND t.deal_price_type_id IS NOT NULL 
			WHERE dpt.source_deal_detail_id = @source_deal_detail_id
				AND t.deal_price_type_id IS NULL

			DELETE ddfu  
			FROM deal_detail_formula_udf ddfu
			LEFT JOIN #deal_price_type t 
				ON ddfu.deal_price_type_id = t.deal_price_type_id
				AND t.deal_price_type_id IS NOT NULL 
			WHERE ddfu.source_deal_detail_id = @source_deal_detail_id
				AND t.deal_price_type_id IS NULL

			UPDATE sdd
				SET pricing_type = NULLIF(dp.pricing_aggregation,''),
					tiered = CASE WHEN dp.is_tiered = 'true' THEN 'y' ELSE 'n' END,
					settlement_date = NULLIF(dp.settlement_date, ''),
					settlement_currency = NULLIF(dp.settlement_currency,''),
					settlement_uom = dp.settlement_uom,
					fx_conversion_rate = NULLIF(dp.fx_conversion_rate,''),
					pricing_description = dp.pricing_description
			FROM source_deal_detail sdd
			CROSS JOIN #deal_pricing dp
			WHERE sdd.source_deal_detail_id = @source_deal_detail_id

			DELETE dpq
			FROM deal_price_quality dpq
			LEFT JOIN #deal_price_quality t
				ON dpq.deal_price_quality_id = t.deal_price_quality_id
			WHERE t.deal_price_quality_id IS NULL
				AND dpq.source_deal_detail_id = @source_deal_detail_id	

			INSERT INTO deal_price_quality (
				source_deal_detail_id
				, attribute
				, operator
				, numeric_value
				, text_value
				, uom
				, basis
			)
			SELECT 
				 @source_deal_detail_id
				, attribute
				, operator
				, CAST(NULLIF(numeric_value, '') AS NUMERIC(38, 20)) 
				, NULLIF(text_value, '') 
				, NULLIF(uom, '')
				, NULLIF(basis, '')
			FROM #deal_price_quality t
			WHERE NULLIF(deal_price_quality_id, '') IS NULL
		
			UPDATE dpq
			SET  attribute = t.attribute
				, operator = t.operator
				, numeric_value = NULLIF(t.numeric_value, '')
				, text_value = NULLIF(t.text_value, '')
				, uom = NULLIF(t.uom, '')
				, basis = NULLIF(t.basis, '')	
			FROM deal_price_quality dpq
			INNER JOIN #deal_price_quality t
				ON dpq.deal_price_quality_id = t.deal_price_quality_id
		
				
		
			INSERT INTO  deal_price_type (
				source_deal_detail_id, price_type_id, description, priority
			)
			SELECT source_deal_detail_id, price_type, rid, priority  FROM #deal_price_type WHERE deal_price_type_id IS NULL

			INSERT INTO deal_price_deemed (	
				[source_deal_detail_id]		
				,[pricing_index]				
				,[pricing_start]				
				,[pricing_end]				
				,[adder]						
				,[currency]					
				,[multiplier]				
				,[volume]					
				,[volume_from]					
				,[uom] 						
				,[pricing_provisional]		
				,[pricing_type]				
				,[pricing_period]			
				,[fixed_price]				
				,[pricing_uom]				
				,[adder_currency]			
				,[formula_id]				
				,[priority]					
				,[formula_currency]			
				,[fixed_cost]				
				,[fixed_cost_currency]		
				,[deal_price_type_id]		
				,[include_weekends]			
				,[rounding]	
				,[bolmo_pricing]
			)
			SELECT 
				 NULLIF(dpt.source_deal_detail_id, '')	
				,NULLIF(dpd.[pricing_index], '')				
				,NULLIF(dpd.[pricing_start], '')				
				,NULLIF(dpd.[pricing_end], '')				
				,NULLIF(CAST(dpd.[adder] AS VARCHAR(10)), '')					
				,NULLIF(dpd.[currency], '')					
				,NULLIF(CAST(dpd.[multiplier] AS VARCHAR(10)), '') 			
				,NULLIF(CAST(dpd.[volume] AS VARCHAR(10)), '')  			
				,NULLIF(CAST(dpd.[volume_from] AS VARCHAR(10)), '')  			
				,NULLIF(dpd.[uom], '') 						
				,'p'	
				,NULLIF(dpd.[pricing_type], '')				
				,NULLIF(dpd.[pricing_period], '')			
				,NULLIF(dpd.[fixed_price], '')				
				,NULLIF(dpd.[pricing_uom], '')				
				,NULLIF(dpd.[adder_currency], '')			
				,NULLIF(dpd.[formula_id], '')				
				,NULLIF(dpd.[priority], '')					
				,NULLIF(dpd.[formula_currency], '')		
				,NULLIF(dpd.[fixed_cost], '')				
				,NULLIF(dpd.[fixed_cost_currency], '')			
				,NULLIF(dpt.[deal_price_type_id], '')		
				,dpd.[include_weekends]			
				,NULLIF(dpd.[rounding], '')	
				,dpd.balmo_pricing	
			FROM deal_price_type dpt
			INNER JOIN #deal_price_deemed dpd
				ON dpt.description = dpd.rid
			WHERE NULLIF(dpd.deal_price_type_id, '') IS NULL

			INSERT INTO deal_price_std_event(
				source_deal_detail_id
				, event_type  
				, event_date
				, pricing_index
				, adder
				, currency
				, multiplier
				, rounding
				, volume
				, volume_from
				, uom			
				, deal_price_type_id
				, pricing_provisional
				, pricing_month
			)
			SELECT 
				  NULLIF(dpt.source_deal_detail_id, '')
				, NULLIF(dpd.event_type, '')  
				, NULLIF(dpd.event_date, '')
				, NULLIF(dpd.pricing_index, '')
				, NULLIF(CAST(dpd.adder AS VARCHAR(10)), '')  
				, NULLIF(dpd.adder_currency, '')
				, NULLIF(CAST(dpd.multiplier AS VARCHAR(10)),'')
				, NULLIF(dpd.rounding, '')
				, CAST(NULLIF(dpd.volume, '') AS NUMERIC(38, 17))
				, CAST(NULLIF(dpd.volume_from, '') AS NUMERIC(38, 17))
				, NULLIF(dpd.uom, '')			
				, NULLIF(dpt.deal_price_type_id, '')
				, 'p'
				, NULLIF(dpd.pricing_month, '')
			FROM deal_price_type dpt
			INNER JOIN #deal_price_std_event dpd
				ON dpt.description = dpd.rid
			WHERE NULLIF(dpd.deal_price_type_id, '') IS NULL
	
			INSERT INTO deal_price_custom_event (
				source_deal_detail_id		
				, event_type  
				, event_date
				, pricing_index					
				, skip_days			
				, quotes_before	
				, quotes_after
				, include_event_date
				, include_holidays
				, adder
				, currency
				, multiplier
				, rounding
				, volume
				, volume_from
				, uom
				, deal_price_type_id
				, pricing_provisional
				, pricing_month
				, skip_granularity
			)
			SELECT 				
				  NULLIF(dpt.source_deal_detail_id, '')		
				, NULLIF(dpd.event_type, '')  
				, NULLIF(dpd.event_date, '')
				, NULLIF(dpd.pricing_index, '')					
				, NULLIF(dpd.skip_days, '')			
				, NULLIF(dpd.quotes_before, '')	
				, NULLIF(dpd.quotes_after, '')
				, dpd.include_event_date
				, dpd.include_holidays
				, NULLIF(CAST(dpd.adder AS VARCHAR(10)), '')
				, NULLIF(dpd.currency, '')
				, NULLIF(CAST(dpd.multiplier AS VARCHAR(10)), '')  
				, NULLIF(dpd.rounding, '')
				, CAST(NULLIF(dpd.volume, '') AS NUMERIC(38, 17)) 
				, CAST(NULLIF(dpd.volume_from, '') AS NUMERIC(38, 17)) 
				, NULLIF(dpd.uom, '')
				, NULLIF(dpt.deal_price_type_id, '')
				, 'p'
				, NULLIF(dpd.pricing_month, '')
				, skip_granularity
			FROM deal_price_type dpt
			INNER JOIN #deal_price_custom_event dpd
				ON dpt.description = dpd.rid
			WHERE NULLIF(dpd.deal_price_type_id, '') IS NULL

			DELETE f 
			FROM deal_detail_formula_udf f
			INNER JOIN #deal_detail_formula_udf t
				ON f.deal_price_type_id = t.deal_price_type_id
		
			INSERT INTO deal_detail_formula_udf ( 
				source_deal_detail_id,
				udf_template_id,
				udf_value,
				deal_price_type_id,
				formula_id
			)
			SELECT dpd.source_deal_detail_id,
					dpd.udf_template_id,
					dpd.udf_value,
					dpt.deal_price_type_id,
					dpd.formula_id	
			FROM deal_price_type dpt
			INNER JOIN #deal_detail_formula_udf dpd
				ON (dpt.description = dpd.rid or dpt.deal_price_type_id = dpd.deal_price_type_id)
			
			DELETE f 
			FROM deal_price_adjustment f
			INNER JOIN #deal_price_adjustment t
				ON f.deal_price_type_id = t.deal_price_type_id

			INSERT INTO deal_price_adjustment ( 
				source_deal_detail_id,
				udf_template_id,
				udf_value,
				deal_price_type_id,
				formula_id
			)
			SELECT dpd.source_deal_detail_id,
					dpd.udf_template_id,
					dpd.udf_value,
					dpt.deal_price_type_id,
					dpd.formula_id	
			FROM deal_price_type dpt
			INNER JOIN #deal_price_adjustment dpd
				ON (dpt.description = dpd.rid or dpt.deal_price_type_id = dpd.deal_price_type_id)

			UPDATE dpt
			SET description = sub.description
			FROM deal_price_type dpt
			INNER JOIN #deal_price_type sub
				ON dpt.description = CAST(sub.rid AS VARCHAR(500))

		
			UPDATE dpt 
				SET price_type_id = sub.price_type
					, description = sub.description
					, priority = sub.priority
			FROM deal_price_type dpt
			INNER JOIN #deal_price_type sub
				ON dpt.deal_price_type_id = sub.deal_price_type_id 

			UPDATE dpd 
			SET pricing_index  = NULLIF(t.pricing_index, '') 
				, pricing_start = NULLIF(t.pricing_start, '')
				, pricing_end = NULLIF(t.pricing_end, '')
				, adder = NULLIF(t.adder, '')
				, currency = NULLIF(t.currency, '')
				, multiplier = NULLIF(t.multiplier, '')
				, volume = NULLIF(t.volume, '')
				, volume_from = NULLIF(t.volume_from, '')
				, uom = NULLIF(t.uom, '')
				, pricing_provisional = ISNULL(t.pricing_provisional, 'p')
				, pricing_type = NULLIF(t.pricing_type, '')
				, pricing_period = NULLIF(t.pricing_period, '')
				, fixed_price = NULLIF(t.fixed_price, '')
				, pricing_uom = NULLIF(t.pricing_uom, '')
				, adder_currency = NULLIF(t.adder_currency, '')
				, formula_id = NULLIF(t.formula_id, '')
				, priority = NULLIF(t.priority, '')
				, formula_currency = NULLIF(t.formula_currency, '')
				, fixed_cost = NULLIF(t.fixed_cost, '')
				, fixed_cost_currency = NULLIF(t.fixed_cost_currency, '')
				, deal_price_type_id = NULLIF(t.deal_price_type_id, '')
				, include_weekends = t.include_weekends
				, rounding = NULLIF(t.rounding, '')
				, bolmo_pricing = t.balmo_pricing
			FROM deal_price_deemed dpd
			INNER JOIN #deal_price_deemed t
				ON dpd.deal_price_type_id = t.deal_price_type_id
		
			UPDATE s 
				SET event_type = NULLIF(t.event_type, '')
				, event_date = NULLIF(t.event_date, '')
				, event_pricing_type = NULLIF(t.event_pricing_type, '')
				, pricing_index = NULLIF(t.pricing_index, '')
				, adder = NULLIF(t.adder, '')
				, currency = NULLIF(t.adder_currency, '')
				, multiplier = NULLIF(t.multiplier, '')
				, volume = NULLIF(t.volume, '')
				, volume_from = NULLIF(t.volume_from, '')
				, uom = NULLIF(t.uom, '')
				, pricing_provisional = ISNULL(t.pricing_provisional, 'p')
				, pricing_type = NULLIF(t.pricing_type, '')
				, deal_price_type_id = NULLIF(t.deal_price_type_id, '')
				, rounding = NULLIF(t.rounding, '')
				, pricing_month = NULLIF(t.pricing_month, '')
			FROM deal_price_std_event s
			INNER JOIN #deal_price_std_event t
				ON s.deal_price_type_id = t.deal_price_type_id
			UPDATE c
				SET event_type = NULLIF(t.event_type, '')
					, event_date = NULLIF(t.event_date, '')
					, pricing_index = NULLIF(t.pricing_index, '')
					, skip_days = NULLIF(t.skip_days, '')
					, quotes_before = NULLIF(t.quotes_before, '')
					, quotes_after = NULLIF(t.quotes_after, '')
					, include_event_date = t.include_event_date
					, include_holidays = t.include_holidays
					, adder = NULLIF(t.adder, '')
					, currency = NULLIF(t.currency, '')
					, multiplier = NULLIF(t.multiplier, '')
					, volume = CAST(NULLIF(t.volume, '') AS VARCHAR(100))
					, volume_from = CAST(NULLIF(t.volume_from, '') AS VARCHAR(100))
					, uom = NULLIF(t.uom, '')
					, rounding = NULLIF(t.rounding, '') 
					, pricing_provisional = ISNULL( t.pricing_provisional, 'p') 
					, pricing_month = NULLIF( t.pricing_month, '') 
					, skip_granularity = t.skip_granularity
			FROM deal_price_custom_event c
			INNER JOIN #deal_price_custom_event t
				ON c.deal_price_type_id = t.deal_price_type_id

			EXEC spa_Errorhandler 0, 'Deal Pricing Detail', 'spa_deal_pricing_detail', 'Success', 'Changes have been saved successfully.', ''
		
			COMMIT TRAN
		END TRY
		BEGIN CATCH	
			IF @@TRANCOUNT > 0
			  ROLLBACK TRAN
	
			EXEC spa_ErrorHANDler -1, 'Deal Priceing Detail', 'spa_deal_pricing_detail', 'DB ERROR', 'Error on saving data.', '' 
		END CATCH
	END
END

IF @flag = 's'
BEGIN
	DECLARE @form_json VARCHAR(MAX)
	DECLARE @grid_json VARCHAR(MAX)
	DECLARE @quality_grid_json VARCHAR(MAX)
	DECLARE @deemed_form_json VARCHAR(MAX)
	DECLARE @custom_form_json VARCHAR(MAX)
	DECLARE @std_form_json VARCHAR(MAX)
	DECLARE @predefined_formula_form_json VARCHAR(MAX)
	DECLARE @price_adjustment_form_json VARCHAR(MAX)

	IF OBJECT_ID('tempdb..#deal_pricing') IS NOT NULL
	BEGIN
		SELECT @form_json = '{"pricing_aggregation": "' + ISNULL(CAST(pricing_aggregation AS VARCHAR(10)), '')
								+ '","tiered":"' + is_tiered
								+ '","settlement_date":"' +  ISNULL(CONVERT(VARCHAR(100), settlement_date, 120), '')
								+ '","settlement_uom":"' +  ISNULL(CAST(settlement_uom AS VARCHAR(10)), '')
								+ '","settlement_currency":"' +  ISNULL(CAST(settlement_currency AS VARCHAR(10)), '')
								+ '","fx_conversion_rate":"' +  ISNULL(CAST(fx_conversion_rate AS VARCHAR(50)) , '')
								+ '","pricing_description":"' +  ISNULL(pricing_description, '')
								+ '"}'
		FROM #deal_pricing
	END
	ELSE
	BEGIN
		SELECT @form_json = '{"pricing_aggregation": "' + ISNULL(CAST(pricing_type AS VARCHAR(10)), '')
								+ '","tiered":"' +  IIF(tiered = 'y', 'true','false')
								+ '","settlement_date":"' +  ISNULL(CONVERT(VARCHAR(100), settlement_date, 120), '')
								+ '","settlement_uom":"' +  ISNULL(CAST(settlement_uom AS VARCHAR(10)), '')
								+ '","settlement_currency":"' +  ISNULL(CAST(settlement_currency AS VARCHAR(10)), '')
								+ '","fx_conversion_rate":"' +  ISNULL(CAST(fx_conversion_rate AS VARCHAR(50)) , '')
								+ '","pricing_description":"' +  ISNULL(pricing_description, '')
								+ '"}'
		FROM source_deal_detail 
		WHERE source_deal_detail_id = @source_deal_detail_id
	END
	
	IF OBJECT_ID('tempdb..#deal_price_type') IS NOT NULL
	BEGIN
		SELECT @grid_json = ISNULL(@grid_json + ',' , '') 
							+  '{id:"' + ISNULL(NULLIF(CAST(price_type AS VARCHAR(100)), 0), rid) + '_' + ISNULL(NULLIF(CAST(deal_price_type_id AS VARCHAR(100)), 0), rid) + '"'
							+ ', data:["' + ISNULL(NULLIF(CAST(deal_price_type_id AS VARCHAR(10)), 0), '')
							+ '","' + ISNULL(NULLIF(CAST(price_type AS VARCHAR(10)), 0), rid)
							+ '","' + ISNULL(description, '') + '"]}'
		FROM #deal_price_type
	END
	ELSE
	BEGIN
		SELECT @grid_json = ISNULL(@grid_json + ',' , '') 
							+  '{id:' + CAST(deal_price_type_id AS VARCHAR(10)) 
							+ ', data:["' + CAST(deal_price_type_id AS VARCHAR(10)) 
							+ '","' + CAST(price_type_id AS VARCHAR(10))  
							+ '","' + ISNULL(description, '') + '"]}'
													
		FROM deal_price_type 
		WHERE source_deal_detail_id = @source_deal_detail_id 
		ORDER BY priority ASC
	END
	
	IF OBJECT_ID('tempdb..#deal_price_quality') IS NOT NULL
	BEGIN
		SELECT	@quality_grid_json = ISNULL(@quality_grid_json + ',' , '')
									+  '{id:' + ISNULL(CAST(attribute AS VARCHAR(10)), '')
									+ ', data:["' 
									+ ISNULL(CAST(attribute AS VARCHAR(10)), '')
									+ '","' + ISNULL(CAST(attribute AS VARCHAR(10)) , '')
									+ '","' + ISNULL(CAST(operator AS VARCHAR(10)), '')
									+ '","' + ISNULL(dbo.FNARemoveTrailingZero(numeric_value), '')  
									+ '","' + ISNULL(text_value, '') 
									+ '","' + ISNULL(CAST(uom AS VARCHAR(10)), '') 
									+ '","' + ISNULL(CAST(basis AS VARCHAR(10)), '')								
									+ '"]}'
		FROM #deal_price_quality
	END
	ELSE
	BEGIN
		SELECT	@quality_grid_json = ISNULL(@quality_grid_json + ',' , '')
									+  '{id:' + CAST(deal_price_quality_id AS VARCHAR(10)) 
									+ ', data:["' 
									+ CAST(deal_price_quality_id AS VARCHAR(10)) 
									+ '","' + CAST(attribute AS VARCHAR(10)) 
									+ '","' + CAST(operator AS VARCHAR(10))
									+ '","' + ISNULL(dbo.FNARemoveTrailingZero(numeric_value), '')  
									+ '","' + ISNULL(text_value, '') 
									+ '","' + ISNULL(CAST(uom AS VARCHAR(10)), '') 
									+ '","' + ISNULL(CAST(basis AS VARCHAR(10)), '')								
									+ '"]}'
		FROM deal_price_quality 
		WHERE source_deal_detail_id = @source_deal_detail_id
	END
	
	DECLARE @formula_id INT 
	DECLARE @process_table	VARCHAR(300) = dbo.FNAProcessTableName('formula_editor', @user_name, @process_id)
	
	IF OBJECT_ID('tempdb..#deal_price_deemed') IS NOT NULL
	BEGIN
		SELECT @formula_id = dpd.formula_id  
		FROM #deal_price_deemed dpd
		WHERE dpd.formula_id IS NOT NULL
	END
	ELSE
	BEGIN
		SELECT @formula_id = dpd.formula_id  
		FROM deal_price_deemed  dpd
		WHERE dpd.source_deal_detail_id = @source_deal_detail_id
			AND dpd.formula_id IS NOT NULL
	END

	IF OBJECT_ID ('tempdb..#temp_resolve_formula') IS NOT NULL
		DROP TABLE #temp_resolve_formula

	CREATE TABLE #temp_resolve_formula (
		formula_id INT,
		formula_name VARCHAR(MAX)
	)
	
	IF @formula_id IS NOT NULL
	BEGIN
		EXEC spa_resolve_function_parameter @flag = 's', @process_id = @process_id, @formula_id = @formula_id
		INSERT INTO #temp_resolve_formula
		EXEC ('SELECT * FROM ' + @process_table + '') 
	END
	
	IF OBJECT_ID('tempdb..#deal_price_deemed') IS NOT NULL
	BEGIN
		SELECT @deemed_form_json = ISNULL(@deemed_form_json + ',', '') 
								   + '"' + ISNULL(NULLIF(CAST(price_type AS VARCHAR(100)), 0), rid) + '_' + ISNULL(NULLIF(CAST(dpt.deal_price_type_id AS VARCHAR(100)), 0), rid)
								   + '":{"deal_price_type_id":"' + ISNULL(CAST(dpd.deal_price_type_id AS VARCHAR(10)), '')
								   + '","price_type":"' + ISNULL(CAST(dpd.price_type AS VARCHAR(50)), '') 
								   + '","price_type_description":"' + ISNULL(dpd.price_type_description, '') + '"'
								   + ',"volume":"' + ISNULL(dbo.FNARemoveTrailingZeroes(NULLIF(dpd.volume, '')), '') + '"'
								   + ',"volume_from":"' + ISNULL(dbo.FNARemoveTrailingZeroes(NULLIF(dpd.volume_from, '')), '') + '"'
								   + ',"volume_uom":"' + ISNULL(CAST(dpd.uom AS VARCHAR(50)), '') + '"'							
								   + CASE WHEN dpd.price_type IN (103600) THEN ',"fixed_price":"' + ISNULL(dbo.FNARemoveTrailingZeroes(dpd.fixed_price), '') + '"' ELSE '' END 
								   + CASE WHEN dpd.price_type IN (103600) THEN ',"pricing_currency":"' + ISNULL(CAST(dpd.currency AS VARCHAR(50)), '') + '"' ELSE '' END  
								   + CASE WHEN dpd.price_type IN (103600) THEN ',"pricing_uom":"' + ISNULL(CAST(dpd.pricing_uom AS VARCHAR(50)), '') + '"' ELSE '' END  							 
								   + CASE WHEN dpd.price_type IN (103601) THEN ',"pricing_index":"' + ISNULL(CAST(dpd.pricing_index AS VARCHAR(50)), '') + '"' ELSE '' END
								   + CASE WHEN dpd.price_type IN (103601) THEN ',"pricing_period":"' +ISNULL(CAST(dpd.pricing_period AS VARCHAR(50)), '')  + '"' ELSE '' END  
								   + CASE WHEN dpd.price_type IN (103601) THEN ',"pricing_start":"' + CAST(ISNULL(CONVERT(VARCHAR(100), dpd.pricing_start, 120), '') AS VARCHAR(50)) + '"' ELSE '' END 
								   + CASE WHEN dpd.price_type IN (103601) THEN ',"pricing_end":"' + CAST(ISNULL(CONVERT(VARCHAR(100), dpd.pricing_end, 120), '') AS VARCHAR(50)) + '"' ELSE '' END
								   + CASE WHEN dpd.price_type IN (103601) THEN ',"include_weekends":' + CAST(IIF(dpd.include_weekends = 'y', 'true','false') AS VARCHAR(50))  + '' ELSE '' END
								   + CASE WHEN dpd.price_type IN (103601) THEN ',"multiplier":"' + ISNULL(CAST(dpd.multiplier AS VARCHAR(50)), '')  + '"' ELSE '' END
								   + CASE WHEN dpd.price_type IN (103601) THEN ',"adder":"' + ISNULL(CAST(dpd.adder AS VARCHAR(50)), '') + '"' ELSE '' END
								   + CASE WHEN dpd.price_type IN (103601) THEN ',"adder_currency":"' +ISNULL(CAST(dpd.adder_currency AS VARCHAR(50)), '')  + '"'  ELSE '' END
								   + CASE WHEN dpd.price_type IN (103601) THEN ',"rounding":"' + ISNULL(CAST(dpd.rounding AS VARCHAR(50)), '') + '"' ELSE '' END 
								   + CASE WHEN dpd.price_type IN (103601) THEN ',"balmo_pricing":' + ISNULL(CAST(IIF(dpd.balmo_pricing = 'y', 'true','false') AS VARCHAR(50)), '')  + '' ELSE '' END
								   + CASE WHEN dpd.price_type IN (103602) THEN ',"formula_id":"' +ISNULL(CAST(dpd.formula_id AS VARCHAR(50)), '') + '"' ELSE '' END 
								   + CASE WHEN dpd.price_type IN (103602) THEN ',"formula_name":"' ++ISNULL(CAST(tf.formula_name AS VARCHAR(50)), '') + '"' ELSE '' END 
								   + CASE WHEN dpd.price_type IN (103602) THEN ',"formula_currency":"' + ISNULL(CAST(dpd.formula_currency AS VARCHAR(50)), '') + '"' ELSE '' END							
								   + CASE WHEN dpd.price_type IN (103604) THEN ',"fixed_cost":"' + ISNULL(dbo.FNARemoveTrailingZeroes(dpd.fixed_cost), '')  + '"' ELSE '' END
								   + CASE WHEN dpd.price_type IN (103604) THEN ',"Fixed_cost_currency":"' + ISNULL(CAST(dpd.Fixed_cost_currency AS VARCHAR(50)), '')  + '"' ELSE '' END  
								   + '}'
		FROM #deal_price_deemed  dpd
		LEFT JOIN deal_price_type dpt
			ON dpd.deal_price_type_id = dpt.deal_price_type_id
		LEFT JOIN #temp_resolve_formula tf
			ON tf.formula_id = dpd.formula_id
		END
	ELSE
	BEGIN
		SELECT @deemed_form_json = ISNULL(@deemed_form_json + ',', '') 
								   + '"' + CAST(dpd.deal_price_type_id AS VARCHAR(10)) 
								   + '":{"deal_price_type_id":"' + CAST(dpd.deal_price_type_id AS VARCHAR(10)) 
								   + '","price_type":"' + ISNULL(CAST(dpt.price_type_id AS VARCHAR(50)), '') 
								   + '","price_type_description":"' + ISNULL(dpt.description, '') + '"'
								   + ',"volume":"' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(dpd.volume) AS VARCHAR(50)), '') + '"'
								   + ',"volume_from":"' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(dpd.volume_from) AS VARCHAR(50)), '') + '"'
								   + ',"volume_uom":"' + ISNULL(CAST(dpd.uom AS VARCHAR(50)), '') + '"'								   
								   + CASE WHEN dpt.price_type_id IN (103600) THEN ',"fixed_price":"' + ISNULL(dbo.FNARemoveTrailingZeroes(dpd.fixed_price), '') + '"' ELSE '' END 
								   + CASE WHEN dpt.price_type_id IN (103600) THEN ',"pricing_currency":"' + ISNULL(CAST(dpd.currency AS VARCHAR(50)), '') + '"' ELSE '' END  
								   + CASE WHEN dpt.price_type_id IN (103600) THEN ',"pricing_uom":"' + ISNULL(CAST(dpd.pricing_uom AS VARCHAR(50)), '') + '"' ELSE '' END  
							 	   + CASE WHEN dpt.price_type_id IN (103601) THEN ',"pricing_index":"' + ISNULL(CAST(dpd.pricing_index AS VARCHAR(50)), '') + '"' ELSE '' END
								   + CASE WHEN dpt.price_type_id IN (103601) THEN ',"pricing_period":"' +ISNULL(CAST(dpd.pricing_period AS VARCHAR(50)), '')  + '"' ELSE '' END  
								   + CASE WHEN dpt.price_type_id IN (103601) THEN ',"pricing_start":"' + CAST(ISNULL(CONVERT(VARCHAR(100), dpd.pricing_start, 120), '') AS VARCHAR(50)) + '"' ELSE '' END 
								   + CASE WHEN dpt.price_type_id IN (103601) THEN ',"pricing_end":"' + CAST(ISNULL(CONVERT(VARCHAR(100), dpd.pricing_end, 120), '') AS VARCHAR(50)) + '"' ELSE '' END
								   + CASE WHEN dpt.price_type_id IN (103601) THEN ',"include_weekends":' + CAST(IIF(dpd.include_weekends = 'y', 'true','false') AS VARCHAR(50))  + '' ELSE '' END
								   + CASE WHEN dpt.price_type_id IN (103601) THEN ',"multiplier":"' + ISNULL(CAST(dpd.multiplier AS VARCHAR(50)), '')  + '"' ELSE '' END
								   + CASE WHEN dpt.price_type_id IN (103601) THEN ',"adder":"' + ISNULL(CAST(dpd.adder AS VARCHAR(50)), '') + '"' ELSE '' END
								   + CASE WHEN dpt.price_type_id IN (103601) THEN ',"adder_currency":"' +ISNULL(CAST(dpd.adder_currency AS VARCHAR(50)), '')  + '"'  ELSE '' END
								   + CASE WHEN dpt.price_type_id IN (103601) THEN ',"rounding":"' + ISNULL(CAST(dpd.rounding AS VARCHAR(50)), '') + '"' ELSE '' END 
								   + CASE WHEN dpt.price_type_id IN (103601) THEN ',"balmo_pricing":' + CAST(IIF(dpd.bolmo_pricing = 'y', 'true','false') AS VARCHAR(50))  + '' ELSE '' END
								   + CASE WHEN dpt.price_type_id IN (103602) THEN ',"formula_id":"' +ISNULL(CAST(dpd.formula_id AS VARCHAR(50)), '') + '"' ELSE '' END 
								   + CASE WHEN dpt.price_type_id IN (103602) THEN ',"formula_name":"' ++ISNULL(CAST(tf.formula_name AS VARCHAR(50)), '') + '"' ELSE '' END 
								   + CASE WHEN dpt.price_type_id IN (103602) THEN ',"formula_currency":"' + ISNULL(CAST(dpd.formula_currency AS VARCHAR(50)), '') + '"' ELSE '' END
								   + CASE WHEN dpt.price_type_id IN (103604) THEN ',"fixed_cost":"' + ISNULL(dbo.FNARemoveTrailingZeroes(dpd.fixed_cost), '')  + '"' ELSE '' END
								   + CASE WHEN dpt.price_type_id IN (103604) THEN ',"Fixed_cost_currency":"' + ISNULL(CAST(dpd.Fixed_cost_currency AS VARCHAR(50)), '')  + '"' ELSE '' END  
								   + '}'
		FROM deal_price_deemed  dpd
		INNER JOIN deal_price_type dpt
			ON dpd.deal_price_type_id = dpt.deal_price_type_id
		LEFT JOIN #temp_resolve_formula tf
			ON tf.formula_id = dpd.formula_id
		WHERE dpd.source_deal_detail_id = @source_deal_detail_id
	END

	IF OBJECT_ID('tempdb..#deal_price_custom_event') IS NOT NULL
	BEGIN
		SELECT  @custom_form_json = ISNULL(@custom_form_json + ',', '') 
									+ '"' + ISNULL(NULLIF(CAST(price_type AS VARCHAR(100)), 0), rid) + '_' + ISNULL(NULLIF(CAST(dpt.deal_price_type_id AS VARCHAR(100)), 0), rid)
									+ '":{"deal_price_type_id":"' + ISNULL(CAST(c.deal_price_type_id AS VARCHAR(10)) , '')
									+ '","price_type":"' + ISNULL(CAST(c.price_type AS VARCHAR(10)) , '')
									+ '","price_type_description":"' + ISNULL(c.price_type_description, '') + '"'
									+ ',"event_type":"' +  ISNULL(CAST(c.event_type AS VARCHAR(50)), '')  + '"'
									+ ',"event_date":"' + CAST(ISNULL(CONVERT(VARCHAR(100), c.event_date, 120) , '') AS VARCHAR(50)) + + '"'
									+ ',"pricing_index":"' + ISNULL(CAST(c.pricing_index AS VARCHAR(50)), '') + '"'
									+ ',"skip_days":"' + ISNULL(CAST(c.skip_days AS VARCHAR(50)), '') + '"'
									+ ',"quotes_before":"' + ISNULL(CAST(c.quotes_before AS VARCHAR(50)), '')  + '"'
									+ ',"quotes_after":"' + ISNULL(CAST(c.quotes_after AS VARCHAR(50)), '')  + '"'
									+ ',"include_event_date":' +  CAST(IIF(c.include_event_date = 'y', 'true','false') AS VARCHAR(50)) + ''
									+ ',"include_weekends":' + CAST(IIF(c.include_holidays = 'y', 'true','false') AS VARCHAR(50)) + ''
									+ ',"adder":"' + ISNULL(CAST(c.adder AS VARCHAR(50)), '') + '"'
									+ ',"adder_currency":"' + ISNULL(CAST(c.currency AS VARCHAR(50)), '') + '"'
									+ ',"multiplier":"' + ISNULL(CAST(c.multiplier AS VARCHAR(50)), '') + '"'
									+ ',"rounding":"' +ISNULL(CAST(c.rounding AS VARCHAR(50)), '') + '"'
									+ ',"volume":"' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(NULLIF(c.volume, '')) AS VARCHAR(50)), '') + '"'
									+ ',"volume_from":"' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(NULLIF(c.volume_from, '')) AS VARCHAR(50)), '') + '"'
									+ ',"volume_uom":"' +ISNULL(CAST(c.uom AS VARCHAR(50)), '') + '"'
									+ ',"pricing_month":"' + CAST(ISNULL(CONVERT(VARCHAR(100), c.pricing_month, 120) , '') AS VARCHAR(50)) + + '"'
									+ ',"skip_granularity":"' + ISNULL(CAST(c.skip_granularity AS VARCHAR(50)), '') + 
									'"}'
		FROM #deal_price_custom_event c
		LEFT JOIN deal_price_type dpt
			ON c.deal_price_type_id = dpt.deal_price_type_id
	END
	ELSE
	BEGIN
		SELECT  @custom_form_json = ISNULL(@custom_form_json + ',', '') 
									+ '"' + CAST(c.deal_price_type_id AS VARCHAR(10)) 
									+ '":{"deal_price_type_id":"' + CAST(c.deal_price_type_id AS VARCHAR(10)) 
									+ '","price_type":"' + CAST( dpt.price_type_id AS VARCHAR(10)) 
									+ '","price_type_description":"' + ISNULL(dpt.description, '') + '"'
									+ ',"event_type":"' +  ISNULL(CAST(c.event_type AS VARCHAR(50)), '')  + '"'
									+ ',"event_date":"' + CAST(ISNULL(CONVERT(VARCHAR(100), c.event_date, 120) , '') AS VARCHAR(50)) + + '"'
									+ ',"pricing_index":"' + ISNULL(CAST(c.pricing_index AS VARCHAR(50)), '') + '"'
									+ ',"skip_days":"' + ISNULL(CAST(c.skip_days AS VARCHAR(50)), '') + '"'
									+ ',"quotes_before":"' + ISNULL(CAST(c.quotes_before AS VARCHAR(50)), '')  + '"'
									+ ',"quotes_after":"' + ISNULL(CAST(c.quotes_after AS VARCHAR(50)), '')  + '"'
									+ ',"include_event_date":' +  CAST(IIF(c.include_event_date = 'y', 'true','false') AS VARCHAR(50)) + ''
									+ ',"include_weekends":' + CAST(IIF(c.include_holidays = 'y', 'true','false') AS VARCHAR(50)) + ''
									+ ',"adder":"' + ISNULL(CAST(c.adder AS VARCHAR(50)), '') + '"'
									+ ',"adder_currency":"' + ISNULL(CAST(c.currency AS VARCHAR(50)), '') + '"'
									+ ',"multiplier":"' + ISNULL(CAST(c.multiplier AS VARCHAR(50)), '') + '"'
									+ ',"rounding":"' +ISNULL(CAST(c.rounding AS VARCHAR(50)), '') + '"'
									+ ',"volume":"' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(c.volume) AS VARCHAR(50)), '') + '"'
									+ ',"volume_from":"' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(c.volume_from) AS VARCHAR(50)), '') + '"'
									+ ',"volume_uom":"' +ISNULL(CAST(c.uom AS VARCHAR(50)), '') + '"'
									+ ',"pricing_month":"' + CAST(ISNULL(CONVERT(VARCHAR(100), c.pricing_month, 120) , '') AS VARCHAR(50)) + + '"'
									+ ',"skip_granularity":"' + ISNULL(CAST(c.skip_granularity AS VARCHAR(50)), '') + 
									'"}'
		FROM deal_price_custom_event c
		INNER JOIN deal_price_type dpt
			ON c.deal_price_type_id = dpt.deal_price_type_id
		WHERE c.source_deal_detail_id = @source_deal_detail_id
	END

	IF OBJECT_ID('tempdb..#deal_price_std_event') IS NOT NULL
	BEGIN
		SELECT @std_form_json = ISNULL(@std_form_json + ',', '') 
									+ '"' + ISNULL(NULLIF(CAST(price_type AS VARCHAR(100)), 0), rid) + '_' + ISNULL(NULLIF(CAST(dpt.deal_price_type_id AS VARCHAR(100)), 0), rid)
									+ '":{"deal_price_type_id":"'
									+ '","price_type":"' + ISNULL(CAST(s.price_type AS VARCHAR(50)), '')
									+ '","price_type_description":"' + ISNULL(s.price_type_description, '') + '"'
									+ ',"event_type":"' + ISNULL(CAST(s.event_type AS VARCHAR(50)), '')   + '"'
									+ ',"event_date":"' + CAST(ISNULL(CONVERT(VARCHAR(100), s.event_date, 120) , '') AS VARCHAR(50)) + '"'
									+ ',"pricing_index":"' + ISNULL(CAST(s.pricing_index AS VARCHAR(50)), '') + '"'
									+ ',"adder":"' + ISNULL(CAST(s.adder AS VARCHAR(50)), '') + '"'
									+ ',"adder_currency":"' + ISNULL(CAST(s.currency AS VARCHAR(50)), '') + '"'
									+ ',"multiplier":"' + ISNULL(CAST(s.multiplier AS VARCHAR(50)), '') + '"'
									+ ',"rounding":"' + ISNULL(CAST(s.rounding AS VARCHAR(50)), '') + '"'
									+ ',"volume":"' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(NULLIF(s.volume, '')) AS VARCHAR(50)), '') + '"'
									+ ',"volume_from":"' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(NULLIF(s.volume_from, '')) AS VARCHAR(50)), '') + '"'
									+ ',"volume_uom":"' + ISNULL(CAST(s.uom AS VARCHAR(50)), '') + '"'
									+ ',"pricing_month":"' + CAST(ISNULL(CONVERT(VARCHAR(100), s.pricing_month, 120) , '') AS VARCHAR(50)) +
									 + '"}'
		FROM #deal_price_std_event s
		LEFT JOIN deal_price_type dpt
			ON s.deal_price_type_id = dpt.deal_price_type_id
	END
	ELSE
	BEGIN
		SELECT  @std_form_json = ISNULL(@std_form_json + ',', '') 
									+ '"' + CAST(s.deal_price_type_id AS VARCHAR(10)) 
									+ '":{"deal_price_type_id":"' + CAST(s.deal_price_type_id AS VARCHAR(10)) 
									+ '","price_type":"' + ISNULL(CAST(dpt.price_type_id AS VARCHAR(50)), '')
									+ '","price_type_description":"' + ISNULL(dpt.description, '') + '"'
									+ ',"event_type":"' + ISNULL(CAST(s.event_type AS VARCHAR(50)), '')   + '"'
									+ ',"event_date":"' + CAST(ISNULL(CONVERT(VARCHAR(100), s.event_date, 120) , '') AS VARCHAR(50)) + '"'
									+ ',"pricing_index":"' + ISNULL(CAST(s.pricing_index AS VARCHAR(50)), '') + '"'
									+ ',"adder":"' + ISNULL(CAST(s.adder AS VARCHAR(50)), '') + '"'
									+ ',"adder_currency":"' + ISNULL(CAST(s.currency AS VARCHAR(50)), '') + '"'
									+ ',"multiplier":"' + ISNULL(CAST(s.multiplier AS VARCHAR(50)), '') + '"'
									+ ',"rounding":"' + ISNULL(CAST(s.rounding AS VARCHAR(50)), '') + '"'
									+ ',"volume":"' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(s.volume) AS VARCHAR(50)), '') + '"'
									+ ',"volume_from":"' + ISNULL(CAST(dbo.FNARemoveTrailingZeroes(s.volume_from) AS VARCHAR(50)), '') + '"'
									+ ',"volume_uom":"' + ISNULL(CAST(s.uom AS VARCHAR(50)), '') + '"'
									+ ',"pricing_month":"' + CAST(ISNULL(CONVERT(VARCHAR(100), s.pricing_month, 120) , '') AS VARCHAR(50)) +
									 + '"}'
		FROM deal_price_std_event s
		INNER JOIN deal_price_type dpt
			ON s.deal_price_type_id = dpt.deal_price_type_id
		WHERE s.source_deal_detail_id = @source_deal_detail_id
	END
	
	IF OBJECT_ID ('tempdb..#deal_price_type') IS NOT NULL
	BEGIN
		SELECT @predefined_formula_form_json = ISNULL(@predefined_formula_form_json + ',', '') +
									 '"' + ISNULL(NULLIF(CAST(price_type AS VARCHAR(100)), 0), rid) + '_' + ISNULL(NULLIF(CAST(dpt.deal_price_type_id AS VARCHAR(100)), 0), rid)
								+ '":{"deal_price_type_id":"' +ISNULL(CAST( dpt.deal_price_type_id AS VARCHAR(10)), '')
									+ '","price_type":"' + ISNULL(CAST( dpt.price_type AS VARCHAR(10)), '')
									+ '","price_type_description":"' + ISNULL(dpt.description, '')  
									+ '","formula_id":"' + ISNULL(CAST(sub.formula_id AS VARCHAR(10)), '')  
									+ '", "formula_fields" : {' + ISNULL(STUFF((SELECT ', ' + '"UDF___' +  CAST(udf_template_id AS VARCHAR(10)) + '" : "' + udf_value + '"'
									   FROM #deal_detail_formula_udf ddfu
									  FOR XML PATH('')), 1, 2, ''), '') + '}}'
		FROM #deal_price_type dpt
		OUTER APPLY (SELECT DISTINCT formula_id FROM #deal_detail_formula_udf) sub
		WHERE price_type = 103606
	END
	ELSE
	BEGIN
		SELECT @predefined_formula_form_json = ISNULL(@predefined_formula_form_json + ',', '') +
									 '"' + CAST(dpt.deal_price_type_id AS VARCHAR(10)) 
									+ '":{"deal_price_type_id":"' + CAST(dpt.deal_price_type_id AS VARCHAR(10)) 
									+ '","price_type":"' + CAST( dpt.price_type_id AS VARCHAR(10)) 
									+ '","price_type_description":"' + ISNULL(dpt.description, '')  
									+ '","formula_id":"' + ISNULL(CAST(sub.formula_id AS VARCHAR(10)), '')  
									+ '", "formula_fields" : {' + STUFF((SELECT ', ' + '"UDF___' +  CAST(udf_template_id AS VARCHAR(10)) + '" : "' + udf_value + '"'
									   FROM deal_detail_formula_udf ddfu 
									   WHERE ddfu.deal_price_type_id = dpt.deal_price_type_id 
									  FOR XML PATH('')), 1, 2, '') + '}}'
		FROM deal_price_type dpt
		OUTER APPLY (SELECT DISTINCT formula_id FROM deal_detail_formula_udf u WHERE u.deal_price_type_id = dpt.deal_price_type_id ) sub
		WHERE dpt.source_deal_detail_id = @source_deal_detail_id
		AND price_type_id = 103606 --static_data_value for predefined_formula
	END

	IF OBJECT_ID('tempdb..#deal_price_adjustment') IS NOT NULL
	BEGIN
		SELECT @price_adjustment_form_json = ISNULL(@price_adjustment_form_json + ',', '') +
									 '"' + ISNULL(NULLIF(CAST(price_type AS VARCHAR(100)), 0), rid) + '_' + ISNULL(NULLIF(CAST(dpt.deal_price_type_id AS VARCHAR(100)), 0), rid)
									+ '":{"deal_price_type_id":"' + ISNULL(CAST(dpt.deal_price_type_id AS VARCHAR(10)), '')
									+ '","price_type":"' + ISNULL(CAST(dpt.price_type AS VARCHAR(10)), '')
									+ '","price_type_description":"' + ISNULL(dpt.description, '')  
									+ '","adjustment_id":"' + ISNULL(CAST(sub.formula_id AS VARCHAR(10)), '')  
									+ '", "adjustment_fields" : {' + ISNULL(STUFF((SELECT ', ' + '"UDF___' +  CAST(udf_template_id AS VARCHAR(10)) + '" : "' + udf_value + '"'
									   FROM #deal_price_adjustment ddfu
									  FOR XML PATH('')), 1, 2, ''), '') + '}}'
		FROM #deal_price_type dpt
		OUTER APPLY (SELECT DISTINCT formula_id FROM #deal_price_adjustment) sub
		WHERE dpt.source_deal_detail_id = @source_deal_detail_id
		AND price_type = 103607
	END
	ELSE
	BEGIN
		SELECT @price_adjustment_form_json = ISNULL(@price_adjustment_form_json + ',', '') +
									 '"' + CAST(dpt.deal_price_type_id AS VARCHAR(10)) 
									+ '":{"deal_price_type_id":"' + CAST(dpt.deal_price_type_id AS VARCHAR(10)) 
									+ '","price_type":"' + CAST( dpt.price_type_id AS VARCHAR(10)) 
									+ '","price_type_description":"' + ISNULL(dpt.description, '')  
									+ '","adjustment_id":"' + ISNULL(CAST(sub.formula_id AS VARCHAR(10)), '')  
									+ '", "adjustment_fields" : {' + STUFF((SELECT ', ' + '"UDF___' +  CAST(udf_template_id AS VARCHAR(10)) + '" : "' + udf_value + '"'
									   FROM deal_price_adjustment ddfu 
									   WHERE ddfu.deal_price_type_id = dpt.deal_price_type_id 
									  FOR XML PATH('')), 1, 2, '') + '}}'
		FROM deal_price_type dpt
		OUTER APPLY (SELECT DISTINCT formula_id FROM deal_price_adjustment u WHERE u.deal_price_type_id = dpt.deal_price_type_id ) sub
		WHERE dpt.source_deal_detail_id = @source_deal_detail_id
		AND price_type_id = 103607 --static_data_value for price_adjustment
	END
	
	DECLARE @enable_prev CHAR(1)
			, @enable_next CHAR(1)
	
	IF ISNUMERIC(@source_deal_detail_id) = 1
	BEGIN
		SELECT  @enable_prev = IIF(MAX(source_deal_detail_id) IS NULL, 'n', 'y')
		FROM source_deal_detail sdd
		WHERE source_deal_detail_id < @source_deal_detail_id
		AND source_deal_header_id = @source_deal_header_id

		SELECT @enable_next = IIF(MIN(source_deal_detail_id) IS NULL, 'n', 'y')
		FROM source_deal_detail sdd
		WHERE source_deal_detail_id > @source_deal_detail_id
		AND source_deal_header_id = @source_deal_header_id
	END
	
	DECLARE @detail_info VARCHAR(MAX)
	SELECT @detail_info = 
		'Price (' +
		CASE WHEN sdg.source_deal_groups_name IS NULL 
			THEN 
				CASE WHEN sml.Location_Name IS NOT NULL THEN CAST(ISNULL(sml.Location_Name, '') AS VARCHAR(500)) + ' - '  
					ELSE '' 
				END 
			  + CASE WHEN spcd.curve_name IS NOT NULL THEN CAST(spcd.curve_name AS VARCHAR(500)) + ' - ' 
					ELSE '' 
			    END
			+ CAST(dbo.FNADateFormat(term_start) AS VARCHAR(200)) + ' - ' + CAST(dbo.FNADateFormat(term_end)  AS VARCHAR(200)) 
			ELSE CAST(sdg.source_deal_groups_name AS VARCHAR(1000)) 
		END + ' | ' + 
		CAST(dbo.FNADateFormat(term_start) AS VARCHAR(200)) + ' | ' + 
		CAST(dbo.FNADateFormat(term_end)  AS VARCHAR(200)) + ' | ' + 
		CASE WHEN sml.Location_Name IS NOT NULL THEN CAST(ISNULL(sml.Location_Name, '') AS VARCHAR(500)) + ' | ' ELSE '' END + 
		CAST(dbo.FNARemoveTrailingZeroes(round(ISNULL(deal_volume, 0), 4)) AS VARCHAR(200)) + ' | ' + 
		CAST(su_uom.uom_name AS VARCHAR(200)) + ' | ' + 
		CAST(sdv_freq.code AS VARCHAR(200)) + ' | ' +  
		CASE WHEN total_volume IS NOT NULL THEN  CAST(dbo.FNARemoveTrailingZeroes(round(total_volume, 4)) AS VARCHAR(200)) + ' | ' ELSE '' END + 
		CAST(su_position_uom.uom_name AS VARCHAR(200)) + 
		CASE WHEN sc.currency_name IS NOT NULL THEN  ' | ' +  CAST(sc.currency_name AS VARCHAR(200)) ELSE '' END + ' | Leg ' + CAST(sdd.Leg AS VARCHAR(10)) + ' | Detail ID ' + CAST(sdd.source_deal_detail_id AS VARCHAR(10)) + ')'
	FROM source_deal_detail sdd
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	LEFT JOIN source_uom su_uom ON su_uom.source_uom_id = sdd.deal_volume_uom_id
	LEFT JOIN static_data_value sdv_freq ON sdv_freq.value_id = 
		CASE sdd.deal_volume_frequency WHEN 'x' THEN 987
										WHEN 'y' THEN 989
										WHEN 'a' THEN 993
										WHEN 'd' THEN 981
										WHEN 'h' THEN 982
										WHEN 'm' THEN 980 
		END
	LEFT JOIN source_uom su_position_uom ON su_position_uom.source_uom_id = sdd.position_uom
	LEFT JOIN source_currency sc ON sc.source_currency_id = sdd.fixed_price_currency_id
	LEFT JOIN source_deal_groups sdg ON sdg.source_deal_groups_id = sdd.source_deal_group_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
	WHERE sdd.source_deal_header_id = @source_deal_header_id 
		AND CAST(sdd.source_deal_detail_id AS VARCHAR(10)) = @source_deal_detail_id
	
	SELECT @form_json form_json
			, '{rows:[' +  @grid_json + ']}' grid_json 
			, '{' + @deemed_form_json + '}' deemed_form_json  
			, '{' + @std_form_json + '}' std_form_json
			, '{' + @custom_form_json + '}' custom_form_json
			, '{' + @predefined_formula_form_json + '}' predefined_formula
			, @enable_prev enable_prev
			, @enable_next enable_next
			, @detail_info detail_info --add deal detail info
			, '{' + @price_adjustment_form_json + '}' price_adjustment 
			,  '{rows:[' +  @quality_grid_json + ']}' quality_grid_json
			
END

ELSE IF @flag = 'c'
BEGIN
	SELECT gmv.generic_mapping_values_id AS ID
		, gmv.clm1_value AS VALUE 
	FROM generic_mapping_values gmv 
	INNER JOIN  generic_mapping_definition gmd 
		ON gmv.mapping_table_id = gmd.mapping_table_id
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmd.clm1_label = 'Logical Name' 
		AND  gmh.mapping_name = 'Event Pricing Method'
END

ELSE IF @flag = 'y'
BEGIN
    IF EXISTS(
        SELECT top 1 1 FROM deal_price_type WHERE source_deal_detail_id = @source_deal_detail_id 
    ) 
    BEGIN
        SELECT 'FALSE' AS status
    END ELSE
        SELECT 'TRUE' AS status
END
 
ELSE IF @flag = 'x'
BEGIN
    SELECT pricing_description FROM source_deal_detail 
        WHERE source_deal_detail_id = @source_deal_detail_id
END
 
ELSE IF @flag = 'z'-- Checked if deal has pricing details or not.
BEGIN 

    IF EXISTS (
        SELECT TOP 1 1 FROM source_deal_header sdh 
            INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
            INNER JOIN deal_price_type dpt ON dpt.source_deal_detail_id = sdd.source_deal_detail_id
        WHERE sdh.source_deal_header_id = @source_deal_header_id
    ) 
    BEGIN
        SELECT 'FALSE' AS status
    END ELSE
        SELECT 'TRUE' AS status
END

ELSE IF @flag = 'f' --for deal with formula and pricing_period
BEGIN
	DECLARE @deal_pricing_table VARCHAR(300)
 	
 	SET @deal_pricing_table = dbo.FNAProcessTableName('deal_pricing_table', @user_name, @process_id)	
 	
	SET @sql = '
		DECLARE @indexed_price_id INT = 103601
							
		INSERT INTO deal_price_type (source_deal_detail_id, price_type_id, priority)
		SELECT adpt.source_deal_detail_id, @indexed_price_id, 1 
		FROM ' + @deal_pricing_table + ' adpt 		
		LEFT JOIN deal_price_type dpt
			ON dpt.source_deal_detail_id = adpt.source_deal_detail_id 
		WHERE NULLIF(adpt.formula_curve_id, '''') IS NOT NULL 
			AND NULLIF(adpt.detail_pricing, '''') IS NOT NULL 
			AND dpt.source_deal_detail_id IS NULL
							
		INSERT INTO deal_price_deemed (	source_deal_detail_id
										, pricing_index
										, pricing_period
										, adder
										, adder_currency
										, deal_price_type_id
										, pricing_provisional
									)
		SELECT sdd.source_deal_detail_id											
				, ISNULL(sdd.formula_curve_id, adpt.formula_curve_id)
				, ISNULL(sdd.detail_pricing, adpt.detail_pricing)
				, ISNULL(sdd.price_adder, adpt.price_adder)
				, ISNULL(sdd.adder_currency_id, adpt.adder_currency_id)
				, dpt.deal_price_type_id
				, ''p''
		FROM ' + @deal_pricing_table + ' adpt
		LEFT JOIN deal_price_deemed dpd
			ON adpt.source_deal_detail_id = dpd.source_deal_detail_id
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_detail_id = adpt.source_deal_detail_id
		INNER JOIN deal_price_type dpt
			ON dpt.source_deal_detail_id = adpt.source_deal_detail_id
			AND dpt.price_type_id = @indexed_price_id
		WHERE dpd.source_deal_detail_id IS NULL
			AND NULLIF(adpt.detail_pricing, '''') IS NOT NULL 
			AND NULLIF(adpt.formula_curve_id, '''') IS NOT NULL 							
							
		UPDATE dpd
		SET pricing_index = dpt.formula_curve_id
			, pricing_period = dpt.detail_pricing
			, adder = dpt.price_adder
			, adder_currency = dpt.adder_currency_id
		FROM deal_price_deemed dpd 		
		INNER JOIN ' + @deal_pricing_table + ' dpt
			ON dpt.source_deal_detail_id = dpd.source_deal_detail_id 
		WHERE NULLIF(dpt.detail_pricing, '''') IS NOT NULL 
			AND NULLIF(dpt.formula_curve_id, '''') IS NOT NULL  

		DELETE dpt
		FROM deal_price_type dpt		
		INNER JOIN ' + @deal_pricing_table + ' adpt
			ON CAST(dpt.source_deal_detail_id AS VARCHAR(100)) = CAST(adpt.source_deal_detail_id AS VARCHAR(100))
		WHERE NULLIF(adpt.detail_pricing, '''') IS NULL 
		OR NULLIF(adpt.formula_curve_id, '''') IS NULL '
	EXEC(@sql)

END
 
ELSE IF @flag = 'j' -- Create price process table while coping deal
BEGIN
	DECLARE @first_detail_id INT, 
			@process_id_out VARCHAR(100)
	
	SELECT @first_detail_id = a.source_deal_detail_id
	FROM
	(
		SELECT TOP 1 *
		FROM source_deal_detail 
		WHERE source_deal_header_id = @source_deal_detail_id
	) a

	EXEC [dbo].[spa_deal_pricing_detail] @flag = 't', @source_deal_detail_id = @first_detail_id, @mode = 'fetch', @ids_to_apply_price = @first_detail_id, @output = @process_id_out OUTPUT
	
	SELECT @sql = ISNULL(@sql + ';', '') + 'EXEC [dbo].[spa_deal_pricing_detail] @flag = ''t'', @xml_process_id = ''' + @process_id_out + ''', @source_deal_detail_id = ' + CAST(source_deal_detail_id AS VARCHAR(10)) + ', @mode = ''fetch'', @ids_to_apply_price = ' + CAST(source_deal_detail_id AS VARCHAR(10)) + ';'
	FROM source_deal_detail 
	WHERE source_deal_header_id = @source_deal_detail_id
	AND source_deal_detail_id <> @first_detail_id

	EXEC(@sql)
END

ELSE IF @flag = 'k'
BEGIN
	DECLARE @idoc1 INT 
	EXEC sp_xml_preparedocument @idoc1 OUTPUT, @xml

	IF OBJECT_ID('tempdb..#temp_deal_detail') IS NOT NULL
		DROP TABLE #temp_deal_detail

	SELECT *
	INTO #temp_deal_detail
	FROM OPENXML(@idoc1, '/root/deal_details', 1)
	WITH (
		source_deal_detail_id VARCHAR(200),
		blotterleg VARCHAR(200),		
		term_start VARCHAR(200),		
		term_end VARCHAR(200)
	)

	EXEC('
		UPDATE p
		SET p.source_deal_detail_id = t.source_deal_detail_id
		FROM #temp_deal_detail t
		INNER JOIN source_deal_detail sdd 
			ON sdd.leg = t.blotterleg
				AND sdd.term_start >= t.term_start
				AND sdd.term_end <= t.term_end
				AND sdd.source_deal_header_id = ' + @source_deal_detail_id + '
		INNER JOIN adiha_process.dbo.pricing_xml_' + @user_name + '_' + @xml_process_id + ' p
			ON sdd.source_deal_detail_id = p.source_deal_detail_id
	')
END

ELSE IF @flag = 'e'
BEGIN
	DECLARE @items_combined VARCHAR(1000), @paramset_id VARCHAR(10)

	DECLARE @ProductTotals TABLE (
		tab_id INT,
		tab_json VARCHAR(MAX),
		form_json VARCHAR(MAX),
		layout_pattern VARCHAR(100),
		grid_json VARCHAR(MAX),
		seq INT,
		dependent_combo VARCHAR(MAX),
		filter_status CHAR(1)
	)

	INSERT INTO @ProductTotals 
	EXEC spa_view_report @flag= 'c'
		, @report_name= @report_name
		, @call_from= 'report_manager_dhx'

	SELECT @paramset_id = rpm.report_paramset_id, @items_combined = dbo.FNARFXGenerateReportItemsCombined(rpg.report_page_id)
	FROM report_paramset rpm 
	INNER JOIN report_page rpg ON rpg.report_page_id = rpm.page_id
	WHERE rpm.name = @report_name

	SELECT TOP 1 a.layout_pattern [process_id],
		@paramset_id [paramset_id],
		@items_combined [items_combined],
		sub.[entity_id] [sub_id],
		stra.[entity_id] [stra_id],
		book.[entity_id] [book_id],
		ssbm.book_deal_type_map_id [sub_book_id]
	FROM portfolio_hierarchy book(NOLOCK)
	INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON  book.parent_entity_id = stra.[entity_id]
	INNER JOIN portfolio_hierarchy sub(NOLOCK) ON  stra.parent_entity_id = sub.[entity_id]
	INNER JOIN source_system_book_map ssbm ON  ssbm.fas_book_id = book.[entity_id]
	OUTER APPLY (SELECT layout_pattern FROM @ProductTotals) a
	where ssbm.book_deal_type_map_id = @sub_book_id
END
GO