IF OBJECT_ID(N'[dbo].[spa_udf_groups]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_udf_groups]
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
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_udf_groups]
    @flag CHAR(1),
	@template_id INT = NULL,
	@deal_id VARCHAR(50) = NULL,
	@udf_process_id VARCHAR(200) = NULL,
	@udf_ids VARCHAR(MAX) = NULL,
	@udf_type VARCHAR(10) = NULL,
	@udf_xml  XML = NULL,
	@detail_id VARCHAR(MAX) = NULL,
	@term_start VARCHAR(10) = NULL,
	@term_end VARCHAR(10) = NULL,
	@leg INT = NULL
AS
/*------------------Debug Section-------------------
DECLARE @flag CHAR(1),
		@template_id INT = NULL,
		@deal_id VARCHAR(50) = NULL,
		@udf_process_id VARCHAR(200) = NULL,
		@udf_ids VARCHAR(MAX) = NULL,
		@udf_type VARCHAR(10) = NULL,
		@udf_xml VARCHAR(MAX) = NULL,
		@detail_id VARCHAR(MAX) = NULL,
		@term_start VARCHAR(10) = NULL,
		@term_end VARCHAR(10) = NULL,
		@leg INT = NULL

SELECT @flag='u',@udf_process_id='F4DA8550_DFDD_47E2_9140_4127C921F013',@deal_id='224888',@udf_xml='<GridXML><GridRow detail_id="2317566" cost_id="-1508" cost_name="UOM Divider" udf_value="3" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317566" cost_id="-1755" cost_name="Postage Stamp Rates" udf_value="4" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317566" cost_id="-1779" cost_name="AAA New Data" udf_value="5" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317566" cost_id="385" cost_name="Utility Cost" udf_value="6" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317567" cost_id="-1508" cost_name="UOM Divider" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317567" cost_id="-1755" cost_name="Postage Stamp Rates" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317567" cost_id="-1779" cost_name="AAA New Data" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317567" cost_id="385" cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317568" cost_id="-1508" cost_name="UOM Divider" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317568" cost_id="-1755" cost_name="Postage Stamp Rates" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317568" cost_id="-1779" cost_name="AAA New Data" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317568" cost_id="385" cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317569" cost_id="-1508" cost_name="UOM Divider" udf_value="" internal_field_type_id="18723" 
internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317569" cost_id="-1755" cost_name="Postage Stamp Rates" udf_value="" internal_field_type_id="18723" internal_field_type="Broker 
Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317569" cost_id="-1779" cost_name="AAA New Data" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" 
contract_id="" receive_pay="" /><GridRow detail_id="2317569" cost_id="385" cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317570" 
cost_id="-1508" cost_name="UOM Divider" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317570" cost_id="-1755" cost_name="Postage 
Stamp Rates" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317570" cost_id="-1779" cost_name="AAA New Data" udf_value="" 
internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317570" cost_id="385" cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" 
uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317571" cost_id="-1508" cost_name="UOM Divider" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" 
contract_id="" receive_pay="" /><GridRow detail_id="2317571" cost_id="-1755" cost_name="Postage Stamp Rates" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" 
/><GridRow detail_id="2317571" cost_id="-1779" cost_name="AAA New Data" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317571" cost_id="385" 
cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317572" cost_id="-1508" cost_name="UOM Divider" udf_value="" 
internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317572" cost_id="-1755" cost_name="Postage Stamp Rates" udf_value="" internal_field_type_id="18723" 
internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317572" cost_id="-1779" cost_name="AAA New Data" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" 
counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317572" cost_id="385" cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow 
detail_id="2317573" cost_id="-1508" cost_name="UOM Divider" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317573" cost_id="-1755" 
cost_name="Postage Stamp Rates" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317573" cost_id="-1779" cost_name="AAA New Data" 
udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317573" cost_id="385" cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" 
currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317574" cost_id="-1508" cost_name="UOM Divider" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" 
counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317574" cost_id="-1755" cost_name="Postage Stamp Rates" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" 
receive_pay="" /><GridRow detail_id="2317574" cost_id="-1779" cost_name="AAA New Data" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317574" cost_id="385" 
cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317575" cost_id="-1508" cost_name="UOM Divider" udf_value="" 
internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317575" cost_id="-1755" cost_name="Postage Stamp Rates" udf_value="" internal_field_type_id="18723" 
internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317575" cost_id="-1779" cost_name="AAA New Data" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" 
counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317575" cost_id="385" cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow 
detail_id="2317576" cost_id="-1508" cost_name="UOM Divider" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317576" cost_id="-1755" cost_name="Postage Stamp Rates" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317576" cost_id="-1779" cost_name="AAA New Data" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317576" cost_id="385" cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317577" cost_id="-1508" cost_name="UOM Divider" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="1082" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317577" cost_id="-1755" cost_name="Postage Stamp Rates" udf_value="" internal_field_type_id="18723" internal_field_type="Broker Fees" currency_id="1109" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317577" cost_id="-1779" cost_name="AAA New Data" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /><GridRow detail_id="2317577" cost_id="385" cost_name="Utility Cost" udf_value="" internal_field_type_id="" internal_field_type="" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay="" /></GridXML>',@udf_type='dc'
--------------------------------------------------*/
SET NOCOUNT ON

DECLARE @sql       VARCHAR(MAX),
		@user_name VARCHAR(100) = dbo.FNADBUser(),
		@desc      VARCHAR(500),
		@err_no    INT

IF @template_id IS NULL AND @deal_id IS NOT NULL
BEGIN
	SELECT @template_id = sdh.template_id
	FROM source_deal_header sdh	
	WHERE CAST(sdh.source_deal_header_id AS VARCHAR(50)) = @deal_id
END 

IF @udf_process_id IS NOT NULL
BEGIN
	DECLARE @udf_table VARCHAR(2000)

	IF @udf_type = 'hc'
		SET @udf_table = dbo.FNAProcessTableName('header_costs_table', @user_name, @udf_process_id)
	ELSE IF @udf_type = 'hu'
		SET @udf_table = dbo.FNAProcessTableName('header_udf_table', @user_name, @udf_process_id)
	ELSE IF @udf_type = 'dc'
		SET @udf_table = dbo.FNAProcessTableName('detail_cost_table', @user_name, @udf_process_id)
	ELSE IF @udf_type = 'du'
		SET @udf_table = dbo.FNAProcessTableName('detail_udf_table', @user_name, @udf_process_id)
END

IF @flag = 's'
BEGIN
    SET @sql = 'SELECT DISTINCT ISNULL(sdv.code, ''General'') udf_group, uddft.Field_label udf_name, uddft.udf_template_id [id]
				FROM user_defined_deal_fields_template uddft
				LEFT JOIN udf_group ug ON ug.udf_template_id = ABS(uddft.udf_template_id)
				LEFT JOIN static_data_value sdv ON sdv.value_id = ug.group_id
				LEFT JOIN ' + @udf_table + ' udf_temp ON udf_temp.udf_id = uddft.udf_template_id
				WHERE 1 = 1
				'

	SET @sql += '	AND ' + IIF (@template_id IS NOT NULL, 'uddft.template_id ', '-1') + ' = ' + ISNULL(CAST(@template_id AS VARCHAR(20)), '-1') + '
					AND uddft.udf_template_id < 0
					AND udf_temp.udf_id IS NULL
				'

	IF @udf_type = 'hc' OR @udf_type = 'dc'
		SET @sql += '	AND uddft.deal_udf_type = ''c'''
	ELSE	
		SET @sql += '	AND ISNULL(uddft.deal_udf_type, ''x'') <> ''c'''
	
	IF @udf_type = 'hc' OR @udf_type = 'hu'
		SET @sql += '	AND uddft.udf_type = ''h'''
	ELSE
		SET @sql += '	AND uddft.udf_type = ''d'''

	SET @sql += ' ORDER BY ISNULL(sdv.code, ''General''), uddft.Field_label '
	
	EXEC(@sql)			
END
IF @flag = 'x'
BEGIN
    SET @sql = 'SELECT DISTINCT udf_name udf_name, udf_id [id], seq_no
				FROM ' + @udf_table + ' udf_temp 
				WHERE udf_id < 0
				ORDER BY seq_no
				'
	EXEC(@sql)			
END
IF @flag = 'z'
BEGIN
	IF @udf_type = 'dc'
	BEGIN
		SET @sql = '
			SELECT DISTINCT 
				[detail_id], dbo.FNAUserDateFormat(sdd.[term_start], ''' + @user_name + ''') term_start, dbo.FNAUserDateFormat(sdd.[term_end], ''' + @user_name + ''') term_end, sdd.[leg],
				[udf_id], [udf_name], [udf_value], [internal_field_type_id], sdv.code [charge_type], [counterparty_id], [contract_id], [currency_id], [uom_id], [receive_pay]
			FROM ' + @udf_table + ' a
			LEFT JOIN static_data_value sdv ON sdv.code = a.charge_type 
				AND sdv.type_id = 18700
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = a.detail_id
			WHERE 1 = 1 '
			+ IIF (NULLIF(@detail_id, '') IS NOT NULL, ' AND detail_id = ''' + CAST(@detail_id AS VARCHAR(20)) + '''', '') + 
			+ IIF (NULLIF(@term_start, '') IS NOT NULL AND NULLIF(@term_end, '') IS NULL, ' AND CONVERT(VARCHAR(10), sdd.term_start, 120)  = ''' + @term_start + '''', '') + 
			+ IIF (NULLIF(@term_start, '') IS NULL AND NULLIF(@term_end, '') IS NOT NULL, ' AND CONVERT(VARCHAR(10), sdd.term_end, 120)  <= ''' + @term_end + '''', '') + 
			+ IIF (NULLIF(@term_start, '') IS NOT NULL AND NULLIF(@term_end, '') IS NOT NULL, ' AND CONVERT(VARCHAR(10), sdd.term_start, 120) BETWEEN ''' + @term_start + ''' AND ''' + @term_end + '''', '') + 
			+ IIF (NULLIF(@leg, '') IS NOT NULL, ' AND sdd.leg = ''' + CAST(@leg AS VARCHAR(10)) + '''', '') + 
			' ORDER BY [detail_id] '

		EXEC(@sql)
	END
	ELSE
	BEGIN
		SET @sql = 'SELECT udf_id, udf_name,internal_type_id, charge_type, udf_value, currency_id, uom_id, counterparty_id,  contract_id, receive_pay, udf_field_type
					FROM ' + @udf_table + ' 
					ORDER BY seq_no
					'
			
		EXEC(@sql)
	END			
END
IF @flag = 'i'
BEGIN
	BEGIN TRY
		IF @udf_ids IS NOT NULL
		BEGIN
			 IF OBJECT_ID('tempdb..#temp_udf_lists') IS NOT NULL
				DROP TABLE #temp_udf_lists

			CREATE TABLE #temp_udf_lists (
				id INT IDENTITY(1, 1),
				udf_id INT
			)

			INSERT INTO #temp_udf_lists
			SELECT scsv.item
			FROM dbo.SplitCommaSeperatedValues(@udf_ids) scsv
		
			SET @sql = '
				UPDATE udf_temp
				SET seq_no = 1000 + temp.id
				FROM ' + @udf_table + ' udf_temp 
				INNER JOIN #temp_udf_lists temp
					ON temp.udf_id = udf_temp.udf_id
			'

			EXEC(@sql)
			
			IF @detail_id IS NULL
			BEGIN
				SELECT @detail_id = ISNULL(@detail_id + ',', '') + CAST(source_deal_detail_id AS VARCHAR(10))
				FROM source_deal_detail
				WHERE source_deal_header_id = @deal_id
			END
			
			IF @udf_type = 'dc' OR @udf_type = 'du'
			BEGIN
				IF OBJECT_ID('tempdb..#temp_detail_ids') IS NOT NULL
					DROP TABLE #temp_detail_ids

				CREATE TABLE #temp_detail_ids (
					detail_id VARCHAR(20) COLLATE DATABASE_DEFAULT
				)

				SET @sql = '
					INSERT INTO #temp_detail_ids (detail_id)
					SELECT DISTINCT detail_id 
					FROM ' + @udf_table + ' 
					WHERE detail_id IS NOT NULL
					UNION
					SELECT CAST(source_deal_detail_id AS VARCHAR(20))
					FROM source_deal_detail
					WHERE source_deal_header_id = ' + CAST(ISNULL(@deal_id, -1) AS VARCHAR(20)) + '
					UNION
					SELECT DISTINCT item FROM dbo.SplitCommaSeperatedValues(''' + @detail_id + ''')
				'
				
				EXEC(@sql)
				
				SET @sql = '
					INSERT INTO ' + @udf_table + ' (detail_id, udf_id, udf_name, udf_value, seq_no, charge_type)
					SELECT sdd.detail_id,
						   temp.udf_id,
						   udft.Field_label,
						   udft.default_value,
						   1000 + temp.id,
						   udft.internal_field_type
					FROM #temp_udf_lists temp
					INNER JOIN user_defined_fields_template udft
						ON udft.udf_template_id = ABS(temp.udf_id)
					OUTER APPLY (
						SELECT DISTINCT detail_id 
						FROM #temp_detail_ids
					) sdd
					LEFT JOIN ' + @udf_table + ' udf_temp
						ON temp.udf_id = udf_temp.udf_id
							AND udf_temp.detail_id = sdd.detail_id
					WHERE udf_temp.udf_id IS NULL
						AND udft.udf_type = ''d''
				'
		
				EXEC(@sql)
			END
			ELSE
			BEGIN
				IF @udf_type = 'hc'
				BEGIN
					SET @sql = '
						INSERT INTO ' + @udf_table + ' (udf_id, udf_name, udf_value, seq_no, charge_type, udf_field_type)
						SELECT temp.udf_id,
							   udft.Field_label,
							   IIF(udft.field_type = ''w'', CAST(fe.formula_id AS VARCHAR(10)) + ''^'' + fe.formula, udft.default_value),
							   1000 + temp.id,
							   udft.internal_field_type,
							   udft.Field_type
						FROM #temp_udf_lists temp
						INNER JOIN user_defined_fields_template udft
							ON udft.udf_template_id = ABS(temp.udf_id)
						LEFT JOIN ' + @udf_table + ' udf_temp
							ON temp.udf_id = udf_temp.udf_id
						LEFT JOIN formula_editor fe ON fe.formula_id = udft.default_value
						WHERE udf_temp.udf_id IS NULL
							AND udft.udf_type = ''h''
					'
				
					EXEC(@sql)
				END 
				ELSE
				BEGIN
				SET @sql = '
					INSERT INTO ' + @udf_table + ' (udf_id, udf_name, udf_value, seq_no, charge_type)
					SELECT temp.udf_id,
						   udft.Field_label,
						   udft.default_value,
						   1000 + temp.id,
						   udft.internal_field_type
					FROM #temp_udf_lists temp
					INNER JOIN user_defined_fields_template udft
						ON udft.udf_template_id = ABS(temp.udf_id)
					LEFT JOIN ' + @udf_table + ' udf_temp
						ON temp.udf_id = udf_temp.udf_id
					WHERE udf_temp.udf_id IS NULL
						AND udft.udf_type = ''h''
				'
				
				EXEC(@sql)
			END
			END
			
			SET @sql = '
				DELETE udf_temp
				FROM ' + @udf_table + ' udf_temp
				LEFT JOIN #temp_udf_lists temp
				ON temp.udf_id = udf_temp.udf_id
				WHERE udf_temp.udf_id < 0
				AND temp.udf_id IS NULL
			'

			EXEC(@sql)
		END

		EXEC spa_ErrorHandler 0, 'source_deal_header', 'spa_udf_groups', 'Success', 'Successfully saved data.', ''
	END TRY
	BEGIN CATCH 
 		IF @@TRANCOUNT > 0
 			ROLLBACK
  
 		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
  
 		SELECT @err_no = ERROR_NUMBER()
  
 		EXEC spa_ErrorHandler @err_no
 			, 'source_deal_header'
 			, 'spa_udf_groups'
 			, 'Error'
 			, @DESC
 			, ''
	END CATCH
END
IF @flag = 'u'
BEGIN
	BEGIN TRY
		IF @udf_xml IS NOT NULL
 		BEGIN
			DECLARE @process_table VARCHAR(300)
 			SET @process_table = dbo.FNAProcessTableName('xml_process_table', @user_name, @udf_process_id)
 			EXEC spa_parse_xml_file 'b', NULL, @udf_xml, @process_table
 			
			IF @udf_type = 'hc'
			BEGIN
				SET @sql = ' UPDATE a
							SET udf_Value = udf_Value + ''^''+ ISNULL(NULLIF(formula_name,''), formula)
							FROM ' + @process_table + ' a
							LEFT JOIN formula_editor fe ON a.udf_value = fe.formula_id
							WHERE a.udf_field_type = ''w'''

				EXEC(@sql)
			END

 			SET @sql = '
				UPDATE udf_temp
 				SET udf_value = NULLIF(hct.udf_value, ''''),
 					currency_id = NULLIF(hct.currency_id, ''''),
 					uom_id = NULLIF(hct.uom_id, ''''),
 					counterparty_id = NULLIF(hct.counterparty_id, ''''),
					contract_id = NULLIF(hct.contract_id, ''''),
					receive_pay = NULLIF(hct.receive_pay, '''')
 				FROM ' + @udf_table + ' udf_temp
				INNER JOIN ' + @process_table + ' hct ON hct.cost_id = udf_temp.udf_id
					AND hct.detail_id = udf_temp.detail_id
 			'

			IF (@udf_type = 'dc' OR @udf_type = 'du') AND @detail_id IS NOT NULL
				SET @sql += ' WHERE udf_temp.detail_id = ' + CAST(@detail_id AS VARCHAR(20))

			EXEC(@sql)
			
			IF OBJECT_ID(@process_table) IS NOT NULL
				EXEC('DROP TABLE ' +  @process_table)
 		END

		EXEC spa_ErrorHandler 0
 				, 'source_deal_header'
 				, 'spa_udf_groups'
 				, 'Success'
 				, 'Successfully saved data.'
 				, ''
	END TRY
	BEGIN CATCH 
 		IF @@TRANCOUNT > 0
 			ROLLBACK
  
 		SET @desc = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'
  
 		SELECT @err_no = ERROR_NUMBER()
  
 		EXEC spa_ErrorHandler @err_no
 			, 'source_deal_header'
 			, 'spa_udf_groups'
 			, 'Error'
 			, @DESC
 			, ''
	END CATCH
END
IF @flag = 'k'
BEGIN
	IF OBJECT_ID('tempdb..#temp_deal_header_fields') IS NOT NULL
 		DROP TABLE #temp_deal_header_fields
 	
	CREATE TABLE #temp_deal_header_fields(
 		[name]               VARCHAR(200) COLLATE DATABASE_DEFAULT,
 		group_id             VARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[label]              VARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[type]               VARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[data_type]          VARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[default_validation] VARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[header_detail]		 VARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[required]           VARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[sql_string]         VARCHAR(2000) COLLATE DATABASE_DEFAULT,
 		[dropdown_json]      VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
 		[disabled]           VARCHAR(20) COLLATE DATABASE_DEFAULT,
 		window_function_id	 VARCHAR(100) COLLATE DATABASE_DEFAULT,
 		[inputWidth]         VARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[labelWidth]         VARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[udf_or_system]      CHAR(1) COLLATE DATABASE_DEFAULT,
 		[seq_no]             INT,
 		[hidden]             VARCHAR(10) COLLATE DATABASE_DEFAULT,
 		[deal_value]		 VARCHAR(5000) COLLATE DATABASE_DEFAULT,
 		[field_id]			 VARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[update_required]	 VARCHAR(10) COLLATE DATABASE_DEFAULT,
 		[value_required]     VARCHAR(10) COLLATE DATABASE_DEFAULT,
 		[block]				 INT,
 		[connector]			 VARCHAR(5000) COLLATE DATABASE_DEFAULT
	)

	DECLARE @default_field_size INT
		, @default_column_num_per_row INT
		, @default_offsetleft INT
		, @default_fieldset_offsettop INT
		, @default_filter_field_size INT
		, @default_fieldset_width INT =1000

	-- Set Default Values
	SELECT @default_field_size = var_value
	FROM adiha_default_codes_values 
	WHERE default_code_id = 86 
		AND instance_no = 1 
		AND seq_no = 1

	SELECT @default_offsetleft = var_value 
	FROM adiha_default_codes_values 
	WHERE default_code_id = 86 
		AND seq_no = 3 
		AND instance_no = 1

	SET @sql = '
	INSERT INTO #temp_deal_header_fields ([name], group_id, [label], [type], [data_type], [default_validation], [header_detail], [required], [sql_string], [inputWidth], [labelWidth],  [disabled], window_function_id, [udf_or_system], [seq_no], [hidden], [deal_value], [field_id], [update_required], [value_required], [block])
 	SELECT *, ROW_NUMBER() OVER(PARTITION BY field_group_id ORDER BY ISNULL(seq_no, 10000), default_label)%50
 	FROM   (
		SELECT ''UDF___'' + CAST(tduf.udf_id AS VARCHAR) udf_template_id,
 				0 field_group_id,
 				CASE WHEN NULLIF(udf_temp.window_id, '''') IS NOT NULL THEN 
 				''<a id=''''UDF___''+CAST(udf_temp.udf_template_id AS VARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(udf_temp.window_id AS VARCHAR(20))+'',this.id);''''>''+udf_temp.Field_label+''</a>''
 				ELSE udf_temp.Field_label
 				END default_label,
 				ISNULL(udf_temp.field_type, ''t'') field_type,
 				udf_temp.[data_type],
 				NULL [default_validation],
 				''h'' header_detail,
 				ISNULL(udf_temp.is_required, ''n'') required,
 				ISNULL(NULLIF(udf_temp.sql_string, ''''), uds.sql_string) sql_string,
 				ISNULL(udf_temp.field_size,' + CAST(@default_field_size AS CHAR(3)) + ') field_size,			
 				CAST(udf_temp.[field_size] AS INT) labelWidth,
 				''n'' is_disable,
 				udf_temp.window_id window_function_id,
 				''u'' udf_or_system,
 				1000 + seq_no seq_no,
 				''n'' hide_control,
 				tduf.udf_value,
 				''u--'' + cast(tduf.udf_id as varchar) field_id,
 				''y'' update_required,
 				CASE WHEN udf_temp.is_required = ''y'' THEN ''true'' ELSE ''false'' END value_required
		FROM ' + @udf_table + ' tduf
		INNER JOIN user_defined_fields_template udf_temp ON udf_temp.udf_template_id = ABS(tduf.udf_id)
		LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udf_temp.data_source_type_id
		WHERE tduf.udf_id < 0 '
		
	
	IF @udf_type = 'hu'
		SET @sql += '	AND udf_temp.udf_type = ''h'''
	ELSE IF @udf_type = 'du'
		SET @sql += '	AND udf_temp.udf_type = ''d'''
	
	IF @udf_type = 'du' AND @detail_id IS NOT NULL
		SET @sql += ' AND tduf.detail_id = ''' + CAST(@detail_id AS VARCHAR(20)) + ''''

	SET @sql += ' ) a  ORDER BY field_group_id,ISNULL(a.seq_no, 10000), default_label '
	--PRINT(@sql)
	EXEC(@sql)

	UPDATE #temp_deal_header_fields
	SET connector = 'js_dropdown_connector_v2_url+"&call_from=deal&deal_id=' + ISNULL(CAST(@deal_id AS VARCHAR(50)), '') + '&template_id=' + ISNULL(CAST(@template_id AS VARCHAR(50)), '') + '&farrms_field_id=' + [name] + '&default_value=' + ISNULL(CAST(deal_value AS VARCHAR(50)), '') + '&is_udf=' + udf_or_system + '&required=' + ISNULL([required], '') + '&deal_type_id=&commodity_id="'
	WHERE [type] IN ('d', 'c')

	DECLARE @tab_form_json VARCHAR(MAX) = '',
			@tab_xml       VARCHAR(MAX)

	DECLARE @setting_xml VARCHAR(2000)
 	SET @setting_xml = (
 						SELECT 'settings' [type],
 								'label-top' [position],
 								'230' labelWidth,
 								'230' inputWidth
 						FOR xml RAW('formxml'), ROOT('root'), ELEMENTS
 	)
 	SELECT @tab_form_json = '[' + dbo.FNAFlattenedJSON(@setting_xml)

	DECLARE @block_id INT
 	DECLARE block_cursor CURSOR FORWARD_ONLY READ_ONLY 
 	FOR
 		SELECT block         
 		FROM #temp_deal_header_fields
 		WHERE group_id = 0
 		GROUP BY block
 		ORDER BY ISNULL(NULLIF(block, 0), 100)
 	OPEN block_cursor
 	FETCH NEXT FROM block_cursor INTO @block_id                                      
 	WHILE @@FETCH_STATUS = 0
 	BEGIN
		DECLARE @form_xml VARCHAR(MAX)			
 		DECLARE @block_json VARCHAR(2000) = '{type:"block", blockOffset:0, offsetLeft:' + CAST(@default_offsetleft AS CHAR(3)) + ', list:'

		SET @form_xml = (   
 						SELECT CASE [type]
 									WHEN 'c' THEN 'combo'
 									WHEN 'd' THEN 'combo'
 									WHEN 'l' THEN 'input'
 									WHEN 't' THEN CASE WHEN data_type IN ('numeric(38,20)', 'int','price','number') THEN 'numeric' ELSE 'input' END
								WHEN 'e' THEN 'time'
 									WHEN 'a' THEN 'calendar'
 									WHEN 'w' THEN 'input'
 									WHEN 'm' THEN 'input'
 								END [type],
 								CASE [type]
 									WHEN 'c' THEN 'true'
 									WHEN 'd' THEN 'true'
 									ELSE NULL
 								END filtering,
 								CASE [type]
 									WHEN 'c' THEN 'between'
 									WHEN 'd' THEN 'between'
 									ELSE NULL
 								END filtering_mode,
 								name,
 								REPLACE(label, '"', '\"') label,
 								CASE 
 									WHEN [required] = 'y' THEN 'true'
 									ELSE 'false'
 								END [required],
 								dropdown_json AS [options],
 								connector AS [connector],
 								CASE 
 									WHEN [disabled] = 'y' OR [type] = 'w' THEN 'true'
 									ELSE 'false'
 								END [disabled],
 								inputWidth,
 								labelWidth,
								0 as offsetLeft,
 								CASE 
 									WHEN [hidden] = 'y' THEN 'true'
 									ELSE 'false'
 								END [hidden],
 								REPLACE(CASE WHEN name IN ('update_ts', 'create_ts') THEN dbo.FNAGetSQLStandardDateTime(NULLIF(deal_value, '')) ELSE CASE WHEN [type] = 'a' THEN dbo.FNAGetSQLStandardDate(NULLIF(deal_value, '')) ELSE CASE WHEN data_type IN ('price','number') THEN dbo.FNARemoveTrailingZero(NULLIF(deal_value, '')) ELSE NULLIF(deal_value, '') END END END, '"', '\"') AS [value],
 								NULL [position],
 								seq_no,
 								CASE WHEN [type] = 'a' THEN '%Y-%m-%d' ELSE NULL END + CASE WHEN name IN ('update_ts', 'create_ts') THEN ' %H:%i:%s' ELSE '' END [serverDateFormat],
 								CASE WHEN [type] = 'a' THEN COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d') ELSE NULL END + CASE WHEN name IN ('update_ts', 'create_ts') THEN ' %H:%i:%s' ELSE '' END [dateFormat],
 								CASE WHEN value_required = 'true' THEN 'NotEmptywithSpace' ELSE NULL END + CASE WHEN data_type = 'int' THEN ',ValidInteger' WHEN data_type IN ('price','number') THEN ',ValidNumeric' ELSE '' END [validate],
 								CASE WHEN value_required = 'true' THEN '{"validation_message": "Invalid data"}' ELSE NULL END [userdata],
 								CASE WHEN [type] = 'm' THEN 3 ELSE NULL END [rows]
 						FROM #temp_deal_header_fields
 						WHERE group_id = 0
 						AND block = @block_id	
 						ORDER BY seq_no								
 						FOR xml RAW('formxml'), ROOT('root'), ELEMENTS
		)
 			
		DECLARE @temp_form_json VARCHAR(MAX) = dbo.FNAFlattenedJSON(@form_xml)
		IF SUBSTRING(@temp_form_json, 1, 1) <> '['
		BEGIN
 			SET @temp_form_json = '[' + @temp_form_json + ']'
		END
 			
		SET @tab_form_json = COALESCE(@tab_form_json + ',', '') + @block_json + @temp_form_json + '},{type:"newcolumn"}'
		FETCH NEXT FROM block_cursor INTO @block_id   
 	END
 	CLOSE block_cursor
 	DEALLOCATE block_cursor

	SET @tab_form_json = @tab_form_json + ']'

	SELECT @tab_form_json [form_json]

END
