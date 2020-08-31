IF OBJECT_ID(N'[dbo].[spa_deal_pricing]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_pricing]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        -  Description of param2
-- @param1 VARCHAR(100) -  Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_deal_pricing]
    @flag CHAR(1),
    @source_deal_detail_id INT,
    @group_id INT = NULL,
    @pricing_provisional CHAR(1) = NULL,
    @pricing_process_id VARCHAR(200),
    @deemed_xml XML = NULL,
    @std_event_xml XML = NULL,
    @custom_event_xml XML = NULL,
    @pricing_type CHAR(1) = NULL,
    @escalation_xml XML = NULL,
    @pricing_type2 INT = NULL
AS
SET NOCOUNT ON

DECLARE @deemed_process_table VARCHAR(400)
DECLARE @std_event_process_table VARCHAR(400)
DECLARE @custom_event_process_table VARCHAR(400)
DECLARE @pricing_type_process_table varchar(400)
DECLARE @deal_escalation_process_table varchar(400)
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
DECLARE @process_id VARCHAR(200) = dbo.FNAGetNewId()
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT
	
SET @deemed_process_table = dbo.FNAProcessTableName('deemed_process_table', @user_name, @pricing_process_id)
SET @std_event_process_table = dbo.FNAProcessTableName('std_event_process_table', @user_name, @pricing_process_id)
SET @custom_event_process_table = dbo.FNAProcessTableName('custom_event_process_table', @user_name, @pricing_process_id)
SET @pricing_type_process_table = dbo.FNAProcessTableName('pricing_type_process_table', @user_name, @pricing_process_id)
SET @deal_escalation_process_table = dbo.FNAProcessTableName('deal_escalation_process_table', @user_name, @pricing_process_id)

IF OBJECT_ID('tempdb..#temp_collect_detail_ids') IS NOT NULL
		DROP TABLE #temp_collect_detail_ids
CREATE TABLE #temp_collect_detail_ids(source_deal_detail_id INT)

IF @group_id IS NOT NULL
BEGIN
	IF @flag IN ('s', 't')
	BEGIN		
		INSERT INTO #temp_collect_detail_ids(source_deal_detail_id)
		SELECT sdd.source_deal_detail_id
		FROM source_deal_detail sdd
		WHERE sdd.source_deal_group_id = @group_id		
	END
	ELSE
	BEGIN				
		INSERT INTO #temp_collect_detail_ids(source_deal_detail_id)
		SELECT TOP(1) sdd.source_deal_detail_id
		FROM source_deal_detail sdd
		WHERE sdd.source_deal_group_id = @group_id
	END
END
ELSE 
BEGIN
	INSERT INTO #temp_collect_detail_ids(source_deal_detail_id)
	SELECT @source_deal_detail_id
END
 
DECLARE @sql NVARCHAR(MAX)

IF @flag = 'p' -- find pricing type
BEGIN
	SET @sql = 'SELECT TOP(1) pricing_type, pricing_type2 
	            FROM ' + @pricing_type_process_table + '
	            WHERE 1 = 1'
	
	IF @group_id IS NOT NULL
		SET @sql += ' AND source_deal_group_id = ' + CAST(@group_id AS VARCHAR(20))
		
	IF @source_deal_detail_id IS NOT NULL
		SET @sql += ' AND source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(20))
	
	exec spa_print @sql
	EXEC(@sql)
END
 
IF @flag = 'x' -- deemed
BEGIN
	SET @sql = 'SELECT NULL id,
					   NULL id2,
					   dpd.fixed_price,
					   dpd.currency,
					   dpd.pricing_uom,					   					   
					   dpd.pricing_period,
					   dpd.pricing_index,
					   dpd.pricing_start,
					   dpd.pricing_end,
					   dpd.multiplier,
					   dpd.adder,
					   dpd.adder_currency,
					   CAST(dpd.formula_id AS VARCHAR(200)) + ''^'' + dbo.FNAFormulaFormatMaxString(fe.formula, ''r''),
					   dpd.formula_currency,
					   dpd.fixed_cost,
					   dpd.fixed_cost_currency,
					   dpd.volume,
					   dpd.uom
				FROM ' + @deemed_process_table + ' dpd
	            INNER JOIN #temp_collect_detail_ids temp 
					ON temp.source_deal_detail_id = dpd.source_deal_detail_id
				LEFT JOIN formula_editor fe On fe.formula_id = dpd.formula_id
	            WHERE dpd.pricing_provisional = ''' + @pricing_provisional + '''
				ORDER BY dpd.[priority]
				'

	exec spa_print @sql
	EXEC(@sql)
END

IF @flag = 'y' -- std events
BEGIN
	SET @sql = 'SELECT NULL id,
	                   NULL id2,
	                   dpse.event_type,
	                   dpse.event_date,
	                   dpse.event_pricing_type,
	                   dpse.pricing_index,
	                   dpse.adder,
	                   dpse.currency,
	                   dpse.multiplier,
	                   dpse.volume,
	                   dpse.uom
	            FROM   ' + @std_event_process_table + ' dpse
	            INNER JOIN #temp_collect_detail_ids temp 
					ON temp.source_deal_detail_id = dpse.source_deal_detail_id
	            WHERE dpse.pricing_provisional = ''' + @pricing_provisional + ''''
	EXEC(@sql)
END

IF @flag = 'z' -- custom events
BEGIN
	SET @sql = 'SELECT NULL id,
					   NULL id2,
					   dpce.event_type,
					   dpce.event_date,
					   dpce.pricing_index,
					   dpce.skip_days,
					   dpce.quotes_before,
					   dpce.quotes_after,
					   dpce.include_event_date,
					   dpce.include_holidays,
					   dpce.adder,
					   dpce.currency,
					   dpce.multiplier,
					   dpce.volume,
					   dpce.uom
				FROM  ' + @custom_event_process_table + ' dpce
	            INNER JOIN #temp_collect_detail_ids temp 
					ON temp.source_deal_detail_id = dpce.source_deal_detail_id
	            WHERE dpce.pricing_provisional = ''' + @pricing_provisional + ''''
	EXEC(@sql)
END

IF @flag = 'e'
BEGIN
	SET @sql = 'SELECT de.quality,
					   de.operator,
					   de.[reference],					   
					   de.range_from,
					   de.range_to,
					   de.increment,
					   de.cost_increment,
					   de.currency
				FROM ' + @deal_escalation_process_table + ' de
				INNER JOIN #temp_collect_detail_ids temp ON temp.source_deal_detail_id = de.source_deal_detail_id'
	EXEC(@sql)
END

IF @flag = 's'
BEGIN	
BEGIN TRY
	DECLARE @deemed_xml_table VARCHAR(300) = dbo.FNAProcessTableName('deemed_xml_table', @user_name, @process_id)
	DECLARE @std_event_xml_table VARCHAR(300) = dbo.FNAProcessTableName('std_event_xml_table', @user_name, @process_id)
	DECLARE @custom_event_xml_table VARCHAR(300) = dbo.FNAProcessTableName('custom_event_xml_table', @user_name, @process_id)
	
	SET @sql = 'UPDATE temp
				SET pricing_type = ''' + @pricing_type + ''',
					pricing_type2 = ' + CAST(@pricing_type2 AS VARCHAR(20)) + '
	            FROM ' + @pricing_type_process_table + ' temp
	            WHERE 1 = 1 '
	
	IF @group_id IS NOT NULL
		SET @sql += ' AND source_deal_group_id = ' + CAST(@group_id AS VARCHAR(20))
		
	IF @source_deal_detail_id IS NOT NULL
		SET @sql += ' AND source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(20))
	
	EXEC(@sql)
	
	IF @deemed_xml IS NOT NULL
	BEGIN
		EXEC spa_parse_xml_file 'b', NULL, @deemed_xml, @deemed_xml_table
		SET @sql = 'DELETE dpt
					FROM ' + @deemed_process_table + ' dpt
					INNER JOIN #temp_collect_detail_ids temp 
						ON temp.source_deal_detail_id = dpt.source_deal_detail_id
					WHERE dpt.pricing_provisional = ''' + @pricing_provisional + '''
		        
					INSERT INTO ' + @deemed_process_table + ' (
						source_deal_detail_id,
						pricing_index,
						pricing_start,
						pricing_end,
						adder,
						currency,
						multiplier,
						volume,
						uom,
						pricing_provisional,
						pricing_period,
						fixed_price,
						formula_id,
						[priority],
						adder_currency,
						pricing_uom,
  						formula_currency,
  						fixed_cost,
  						fixed_cost_currency
					)
					SELECT  sdd.source_deal_detail_id,
							NULLIF(dxt.pricing_index, ''''), 
							NULLIF(dxt.pricing_start, ''''),
							NULLIF(dxt.pricing_end, ''''),
							NULLIF(dxt.adder, ''''),
							NULLIF(dxt.currency, ''''),
							NULLIF(dxt.multiplier, ''''),
							NULLIF(dxt.volume, ''''),
							NULLIF(dxt.uom, ''''),
							''' + @pricing_provisional + ''',
							NULLIF(dxt.pricing_period, ''''),
							NULLIF(dxt.fixed_price, ''''),
							NULLIF(dxt.formula_id, ''''),
							NULLIF(dxt.[priority], ''''),
							NULLIF(dxt.adder_currency, ''''),
							NULLIF(dxt.pricing_uom, ''''),
  						    NULLIF(dxt.formula_currency, ''''),
  						    NULLIF(dxt.fixed_cost, ''''),
  						    NULLIF(dxt.fixed_cost_currency, '''')
					FROM ' + @deemed_xml_table + ' dxt
					OUTER APPLY (
						SELECT source_deal_detail_id FROM #temp_collect_detail_ids
					) sdd					
				'
		--PRINT(@sql)
		exec spa_print @sql
		EXEC(@sql)	
		
		IF @pricing_type2 = 103600
		BEGIN
			SET @sql = 'UPDATE dpt
						SET pricing_index = NULL,
							multiplier = NULL,
							pricing_period = NULL,
							pricing_start = NULL,
							pricing_end = NULL,
							formula_id = NULL,
							formula_currency = NULL
			            FROM ' + @deemed_process_table + ' dpt
			            INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpt.source_deal_detail_id			            
						'
			EXEC(@sql)
		END	
		ELSE IF @pricing_type2 = 103601
		BEGIN
			SET @sql = 'UPDATE dpt
						SET fixed_price = NULL,
							currency = NULL
			            FROM ' + @deemed_process_table + ' dpt
			            INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpt.source_deal_detail_id			            
						'
			EXEC(@sql)
		END
		ELSE IF @pricing_type2 = 103602
		BEGIN
			SET @sql = 'UPDATE dpt
						SET fixed_price = NULL,
							currency = NULL
			            FROM ' + @deemed_process_table + ' dpt
			            INNER JOIN #temp_collect_detail_ids sdd ON sdd.source_deal_detail_id = dpt.source_deal_detail_id			            
						'
			EXEC(@sql)
		END
	END
	ELSE
	BEGIN
		SET @sql = 'DELETE dpt
					FROM ' + @deemed_process_table + ' dpt
					INNER JOIN #temp_collect_detail_ids temp 
						ON temp.source_deal_detail_id = dpt.source_deal_detail_id
					WHERE dpt.pricing_provisional = ''' + @pricing_provisional + '''
					'
		--EXEC(@sql)
		EXEC(@sql)
	END
	
	IF @std_event_xml IS NOT NULL
	BEGIN		
		EXEC spa_parse_xml_file 'b', NULL, @std_event_xml, @std_event_xml_table
		
		SET @sql = 'DELETE spt
					FROM ' + @std_event_process_table + ' spt
					INNER JOIN #temp_collect_detail_ids temp 
						ON temp.source_deal_detail_id = spt.source_deal_detail_id
					WHERE spt.pricing_provisional = ''' + @pricing_provisional + '''
					
					INSERT INTO ' + @std_event_process_table + ' (
						source_deal_detail_id,
						event_type,
						event_date,
						event_pricing_type,
						pricing_index,
						adder,
						currency,
						multiplier,
						volume,
						uom,
						pricing_provisional
					)
					SELECT 
						sdd.source_deal_detail_id,
						NULLIF(event_type, ''''), 
						NULLIF(event_date, ''''), 
						NULLIF(event_pricing_type, ''''), 
						NULLIF(pricing_index, ''''), 
						NULLIF(adder, ''''), 
						NULLIF(currency, ''''), 
						NULLIF(multiplier, ''''), 
						NULLIF(volume, ''''), 
						NULLIF(uom, ''''), 
						''' + @pricing_provisional + '''
					FROM ' + @std_event_xml_table + ' dxt
					OUTER APPLY (
						SELECT source_deal_detail_id FROM #temp_collect_detail_ids
					) sdd					
				'
		exec spa_print @sql
		EXEC(@sql)
	END
	ELSE
	BEGIN
		SET @sql = 'DELETE spt
					FROM ' + @std_event_process_table + ' spt
					INNER JOIN #temp_collect_detail_ids temp 
						ON temp.source_deal_detail_id = spt.source_deal_detail_id
					WHERE spt.pricing_provisional = ''' + @pricing_provisional + ''''
		EXEC(@sql)
	END
	
	IF @custom_event_xml IS NOT NULL
	BEGIN		
		EXEC spa_parse_xml_file 'b', NULL, @custom_event_xml, @custom_event_xml_table
		
		SET @sql = 'DELETE cpt
					FROM ' + @custom_event_process_table + ' cpt
					INNER JOIN #temp_collect_detail_ids temp 
						ON temp.source_deal_detail_id = cpt.source_deal_detail_id
					WHERE cpt.pricing_provisional = ''' + @pricing_provisional + '''
		        
					INSERT INTO ' + @custom_event_process_table + ' (
						source_deal_detail_id,
						event_type,
						event_date,
						pricing_index,
						skip_days,
						quotes_before,
						quotes_after,
						include_event_date,
						include_holidays,
						adder,
						currency,
						multiplier,
						volume,
						uom,
						pricing_provisional
					)
					SELECT 
						sdd.source_deal_detail_id,
						NULLIF(event_type, ''''),
						NULLIF(event_date, ''''),
						NULLIF(pricing_index, ''''),
						NULLIF(skip_days, ''''),
						NULLIF(quotes_before, ''''),
						NULLIF(quotes_after, ''''),
						NULLIF(include_event_date, ''''),
						NULLIF(include_holidays, ''''),
						NULLIF(adder, ''''),
						NULLIF(currency, ''''),
						NULLIF(multiplier, ''''),
						NULLIF(volume, ''''),
						NULLIF(uom, ''''),
					''' + @pricing_provisional + '''
					FROM ' + @custom_event_xml_table + ' dxt
					OUTER APPLY (
						SELECT source_deal_detail_id FROM #temp_collect_detail_ids
					) sdd					
				'
		EXEC(@sql)
	END	
	ELSE
	BEGIN
		SET @sql = 'DELETE cpt
					FROM ' + @custom_event_process_table + ' cpt
					INNER JOIN #temp_collect_detail_ids temp 
						ON temp.source_deal_detail_id = cpt.source_deal_detail_id
					WHERE cpt.pricing_provisional = ''' + @pricing_provisional + ''''
		EXEC(@sql)
	END
	
	EXEC spa_ErrorHandler 0
		, 'spa_deal_pricing'
		, 'spa_deal_pricing'
		, 'Success' 
		, 'Successfully saved data.'
		, ''
END TRY
BEGIN CATCH 
	IF @@TRANCOUNT > 0
	   ROLLBACK
 
	SET @DESC = 'Errr Description:' + ERROR_MESSAGE() + '.'
 
	SELECT @err_no = ERROR_NUMBER()
 
	EXEC spa_ErrorHandler @err_no
	   , 'spa_deal_pricing'
	   , 'spa_deal_pricing'
	   , 'Error'
	   , @DESC
	   , ''
END CATCH
END

IF @flag = 't'
BEGIN
	BEGIN TRY
		DECLARE @escalation_xml_table VARCHAR(300) = dbo.FNAProcessTableName('deemed_xml_table', @user_name, @process_id)
		
		IF @escalation_xml IS NOT NULL
		BEGIN
			EXEC spa_parse_xml_file 'b', NULL, @escalation_xml, @escalation_xml_table
		
			SET @sql = 'DELETE dpt
						FROM ' + @deal_escalation_process_table + ' dpt
						INNER JOIN #temp_collect_detail_ids temp 
							ON temp.source_deal_detail_id = dpt.source_deal_detail_id
		        
						INSERT INTO ' + @deal_escalation_process_table + ' (
							source_deal_detail_id,
							quality,
							range_from,
							range_to,
							increment,
							cost_increment,
							operator,
							[REFERENCE],
							currency
						)
						SELECT  sdd.source_deal_detail_id,
								NULLIF(ext.quality, ''''), 
								NULLIF(ext.range_from, ''''),
								NULLIF(ext.range_to, ''''),
								NULLIF(ext.increment, ''''),
								NULLIF(ext.cost_increment, ''''),
								NULLIF(ext.operator, ''''),
								NULLIF(ext.[reference], ''''),
								NULLIF(ext.currency, '''')
						FROM ' + @escalation_xml_table + ' ext
						OUTER APPLY (
							SELECT source_deal_detail_id FROM #temp_collect_detail_ids
						) sdd					
					'
			exec spa_print @sql
			EXEC(@sql)
			
			EXEC spa_ErrorHandler 0
				, 'spa_deal_pricing'
				, 'spa_deal_pricing'
				, 'Success' 
				, 'Successfully saved data.'
				, ''	
		END
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Errr Description:' + ERROR_MESSAGE() + '.'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'spa_deal_pricing'
		   , 'spa_deal_pricing'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END