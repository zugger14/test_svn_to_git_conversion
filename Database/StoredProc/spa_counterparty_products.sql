IF OBJECT_ID(N'[dbo].[spa_counterparty_products]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_counterparty_products]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 

CREATE PROCEDURE [dbo].[spa_counterparty_products]
    @flag CHAR(1),
	@dependent_id VARCHAR(MAX) = NULL,
	@product_id INT = NULL,
	@xml VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX)

IF @dependent_id = 'NULL'	
	SET @dependent_id = NULL

IF @flag = 's'
BEGIN
	SELECT
		cp.counterparty_product_id,
		cp.product_computed_name [product_string],
		CASE 
	        WHEN buy_sell = 'b' THEN 'Buys'
			WHEN buy_sell = 's' THEN 'Sells'
	        ELSE 'Buys + Sells'
	    END [buy_sell],
		sc.commodity_name,
		sdv.code [origin],
		CASE
			WHEN is_organic = 'y' THEN 'Yes'
			ELSE 'No'
		END [is_organic],
		sd.code [commodity_form_name],
		sdv1.code [commodity_form_attribute1],
		sdv2.code [commodity_form_attribute2],
		sdv3.code [commodity_form_attribute3],
		sdv4.code [commodity_form_attribute4],
		sdv5.code [commodity_form_attribute5],
		dbo.FNADecodeXML(ca_trader.trader_name) [trader_id],
		--'<span style="cursor:pointer" onClick="setup_counterparty.open_document('''+CAST(cp.counterparty_product_id AS VARCHAR(100))+''',''42002'','''+CAST(counterparty_id AS VARCHAR(100))+''')"><font color=#0000ff><u><l>Documents<l></u></font></span> ('+ CAST(COUNT(an.attachment_file_name) AS VARCHAR(100)) +')' [Attachment]
		CASE WHEN COUNT(an.attachment_file_name) = 0 THEN '<span style="cursor:pointer" onClick="setup_counterparty.attach_document('''+CAST(cp.counterparty_id AS VARCHAR(100))+''',''42002'',''NULL'','''+CAST(cp.counterparty_product_id AS VARCHAR(100))+''')"><font color=#ff000000><u><l>Upload<l></u></font></span>'
		ELSE  '<span style="cursor:pointer" onClick="setup_counterparty.attach_document('''+CAST(cp.counterparty_id AS VARCHAR(100))+''',''42002'','''+CAST(an.notes_id AS VARCHAR(100))+''','''+CAST(cp.counterparty_product_id AS VARCHAR(100))+''')"><font color=#ff000000><u><l>Upload<l></u></font></span> <span style="cursor:pointer" onClick="setup_counterparty.remove_document('''+CAST(an.notes_id AS VARCHAR(100))+''')"><font color=#ff000000><u><l>Remove<l></u></font></span> (' + ISNULL(' <a href=../../adiha.php.scripts/force_download.php?path=' + REPLACE(notes_attachment, attachment_file_name, '') + item + ' download>' + item + '</a>', '<a href=' + url + ' target=_blank>' + url + '<a>') + ')'
		END [attachment]
	FROM counterparty_products cp
	LEFT JOIN application_notes an ON cp.counterparty_product_id = an.notes_object_id AND ISNULL(an.internal_type_value_id, 37) = 37 AND ISNULL(an.category_value_id, 42002) = 42002
	CROSS APPLY (
		SELECT STUFF(
			(
				SELECT ', '  + '<span style="cursor:pointer" onClick="setup_counterparty.open_popup_window('''+CAST(cp.counterparty_id AS VARCHAR(100))+''','''+CAST(cc.counterparty_contact_id AS VARCHAR(100))+''',''ct'','''','''','''')"><font color=#000000ff><u><l>' +  + CAST(cc.name AS VARCHAR) + '<l></u></font></span>'
				FROM dbo.SplitCommaSeperatedValues(cp.trader_id) scsv
				INNER JOIN counterparty_contacts cc ON cc.counterparty_contact_id = scsv.item
				FOR XML PATH('')
			)
		, 1, 1, '') [trader_name]
	) ca_trader
	OUTER APPLY dbo.fnasplit(attachment_file_name, ', ')
	LEFT JOIN source_commodity sc ON sc.source_commodity_id = cp.commodity_id
	LEFT JOIN commodity_origin co ON co.commodity_origin_id = cp.commodity_origin_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = co.origin
	LEFT JOIN commodity_form cf ON cf.commodity_form_id = cp.commodity_form_id
	LEFT JOIN commodity_type_form ctf ON ctf.commodity_type_form_id = cf.form
	LEFT JOIN static_data_value sd ON sd.value_id = ctf.commodity_form_value
	LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = cp.commodity_form_attribute1
	LEFT JOIN commodity_attribute_form caf on caf.commodity_attribute_form_id = cfa1.attribute_form_id
	LEFT JOIN static_data_value sdv1 ON caf.commodity_attribute_value = sdv1.value_id
	LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id = cp.commodity_form_attribute2
	LEFT JOIN commodity_attribute_form caf2 on caf2.commodity_attribute_form_id = cfa2.attribute_form_id
	LEFT JOIN static_data_value sdv2 ON caf2.commodity_attribute_value = sdv2.value_id
	LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = cp.commodity_form_attribute3
	LEFT JOIN commodity_attribute_form caf3 on caf3.commodity_attribute_form_id = cfa3.attribute_form_id
	LEFT JOIN static_data_value sdv3 ON caf3.commodity_attribute_value = sdv3.value_id
	LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = cp.commodity_form_attribute4
	LEFT JOIN commodity_attribute_form caf4 on caf4.commodity_attribute_form_id = cfa4.attribute_form_id
	LEFT JOIN static_data_value sdv4 ON caf4.commodity_attribute_value = sdv4.value_id
	LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = cp.commodity_form_attribute5
	LEFT JOIN commodity_attribute_form caf5 on caf5.commodity_attribute_form_id = cfa5.attribute_form_id
	LEFT JOIN static_data_value sdv5 ON caf5.commodity_attribute_value = sdv5.value_id
	WHERE cp.counterparty_id = @dependent_id
	GROUP BY counterparty_product_id,buy_sell,commodity_name,sdv.code,is_organic,sd.code,sdv1.code,sdv2.code,sdv3.code,sdv4.code,sdv5.code,ca_trader.trader_name,counterparty_id
	,item,notes_attachment,attachment_file_name,notes_id,cp.product_computed_name,an.url
END
ELSE IF @flag = 'd'
BEGIN
	DECLARE @idoc int
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_delete_detail') IS NOT NULL
		DROP TABLE #temp_delete_detail

	SELECT
		grid_id
	INTO #temp_delete_detail
	FROM OPENXML(@idoc, '/Root/GridDelete', 1)
	WITH (
		grid_id INT
	)

	DELETE an
	FROM counterparty_products cp
	INNER JOIN application_notes an on an.notes_object_id = cp.counterparty_product_id
	INNER JOIN #temp_delete_detail tdd ON cp.counterparty_product_id = tdd.grid_id

	DELETE cp
	FROM counterparty_products cp
	INNER JOIN #temp_delete_detail tdd ON cp.counterparty_product_id = tdd.grid_id
	
	EXEC spa_ErrorHandler 0,
		'counterparty_products',
		'spa_counterparty_products',
		'Success',
		'Changes have been saved successfully.',
		''
END
ELSE IF @flag = 'o'
BEGIN
	SET @sql = 'SELECT commodity_origin_id, sdv.code  
				FROM commodity_origin co 
				left join static_data_value sdv ON sdv.value_id = co.origin 
				 '
	
	IF @dependent_id IS NOT NULL			
		SET @sql += ' INNER JOIN  dbo.FNASplit(''' + @dependent_id + ''', '','') i ON i.item = co.source_commodity_id '
	
	SET @sql += ' ORDER BY sdv.code'
	
	EXEC(@sql)
END
ELSE IF @flag = 'f'
BEGIN
	SET @sql = 'SELECT commodity_form_id, sdv.code
				FROM commodity_form cf
				LEFT JOIN commodity_type_form ctf ON ctf.commodity_type_form_id = cf.form
				LEFT JOIN static_data_value sdv ON ctf.commodity_form_value = sdv.value_id
				'
	
	IF @dependent_id IS NOT NULL	 
		SET @sql += ' INNER JOIN  dbo.FNASplit(''' + @dependent_id + ''', '','') i ON i.item = cf.commodity_origin_id '
	
	SET @sql += ' ORDER BY commodity_form_name'
	
	EXEC(@sql)
END
ELSE IF @flag = 'a'
BEGIN
	SET @sql = 'SELECT c.commodity_form_attribute1_id, sdv.code
				FROM commodity_form_attribute1 c 
				LEFT JOIN commodity_attribute_form caf on caf.commodity_attribute_form_id = c.attribute_form_id
				INNER JOIN static_data_value sdv ON caf.commodity_attribute_value = sdv.value_id
				'
				
	IF @dependent_id IS NOT NULL			
		SET @sql += ' INNER JOIN  dbo.FNASplit(''' + @dependent_id + ''', '','') i ON i.item =  c.commodity_form_id ' 
	SET @sql += ' ORDER BY caf.commodity_form_name'
	EXEC(@sql)
END
ELSE IF @flag = 'b'
BEGIN
	SET @sql = 'SELECT c.commodity_form_attribute2_id, sdv.code
				FROM commodity_form_attribute2 c 
				LEFT JOIN commodity_attribute_form caf on caf.commodity_attribute_form_id = c.attribute_form_id
				INNER JOIN static_data_value sdv ON caf.commodity_attribute_value = sdv.value_id
				'
	
	IF @dependent_id IS NOT NULL			
		SET @sql += ' INNER JOIN  dbo.FNASplit(''' + @dependent_id + ''', '','') i ON i.item = c.commodity_form_attribute1_id '
	
	SET @sql += ' ORDER BY caf.commodity_form_name'
	EXEC(@sql)
END
ELSE IF @flag = 'c'
BEGIN
	SET @sql = 'SELECT c.commodity_form_attribute3_id, sdv.code 
				FROM commodity_form_attribute3 c 
				LEFT JOIN commodity_attribute_form caf on caf.commodity_attribute_form_id = c.attribute_form_id
				INNER JOIN static_data_value sdv ON caf.commodity_attribute_value = sdv.value_id
				'
				
	IF @dependent_id IS NOT NULL			
		SET @sql += ' INNER JOIN  dbo.FNASplit(''' + @dependent_id + ''', '','') i ON i.item = c.commodity_form_attribute2_id '
	
	SET @sql += ' ORDER BY caf.commodity_form_name'
	
	EXEC(@sql)
END
ELSE IF @flag = 'e'
BEGIN
	SET @sql = 'SELECT c.commodity_form_attribute4_id, sdv.code 
				FROM commodity_form_attribute4 c 
				LEFT JOIN commodity_attribute_form caf on caf.commodity_attribute_form_id = c.attribute_form_id
				INNER JOIN static_data_value sdv ON caf.commodity_attribute_value = sdv.value_id
				'
				
	IF @dependent_id IS NOT NULL			
		SET @sql += ' INNER JOIN  dbo.FNASplit(''' + @dependent_id + ''', '','') i ON i.item = c.commodity_form_attribute3_id '
	
	SET @sql += ' ORDER BY caf.commodity_form_name'
	EXEC(@sql)
END
ELSE IF @flag = 'g'
BEGIN
	SET @sql = 'SELECT c.commodity_form_attribute5_id, sdv.code
				FROM commodity_form_attribute5 c 
				LEFT JOIN commodity_attribute_form caf on caf.commodity_attribute_form_id = c.attribute_form_id
				INNER JOIN static_data_value sdv ON caf.commodity_attribute_value = sdv.value_id
				'
				
	IF @dependent_id IS NOT NULL			
		SET @sql += ' INNER JOIN  dbo.FNASplit(''' + @dependent_id + ''', '','') i ON i.item = c.commodity_form_attribute4_id '
	SET @sql += ' ORDER BY caf.commodity_form_name'
	
	EXEC(@sql)
END
ELSE IF @flag = 't'
BEGIN
	SELECT counterparty_contact_id, name 
	INTO #temp_contacts
	FROM counterparty_contacts cc
	WHERE cc.contact_type = -32200 AND cc.counterparty_id = @dependent_id 

	DECLARE @trader_id VARCHAR(1000)
	SELECT @trader_id = trader_id
	FROM counterparty_products 
	WHERE counterparty_id = @dependent_id AND counterparty_product_id = @product_id

	SELECT tc.counterparty_contact_id, tc.name, CASE WHEN s.item IS NOT NULL THEN 'true' ELSE 'false' END [select]
	FROM #temp_contacts tc
	LEFT JOIN dbo.SplitCommaSeperatedValues(@trader_id) s ON s.item = tc.counterparty_contact_id
	ORDER BY tc.name ASC

	DROP TABLE #temp_contacts
END
ELSE IF @flag = 'u'
BEGIN
	SELECT	commodity_origin_id,
			commodity_form_id,
			commodity_form_attribute1,
			commodity_form_attribute2,
			commodity_form_attribute3,
			commodity_form_attribute4,
			commodity_form_attribute5,
			trader_id,
			commodity_id
	FROM counterparty_products
	WHERE counterparty_product_id = @dependent_id
END
ELSE IF @flag = 'v'
BEGIN
	BEGIN TRY
		INSERT INTO counterparty_products(
				counterparty_id
				,buy_sell
				,commodity_id
				,commodity_origin_id
				,is_organic
				,commodity_form_id
				,commodity_form_attribute1
				,commodity_form_attribute2
				,commodity_form_attribute3
				,commodity_form_attribute4
				,commodity_form_attribute5
				,trader_id
		)
		SELECT	counterparty_id
				,buy_sell
				,commodity_id
				,commodity_origin_id
				,is_organic
				,commodity_form_id
				,commodity_form_attribute1
				,commodity_form_attribute2
				,commodity_form_attribute3
				,commodity_form_attribute4
				,commodity_form_attribute5
				,trader_id
		FROM counterparty_products
		WHERE counterparty_product_id = @dependent_id
	
		EXEC spa_ErrorHandler 0,
			'counterparty_products',
			'spa_counterparty_products',
			'Success',
			'Changes have been saved successfully.',
			''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		  ROLLBACK

		EXEC spa_ErrorHandler 0,
			'counterparty_products',
			'spa_counterparty_products',
			'Success',
			'Changes have been failed to save successfully.',
			''
	END CATCH
END
ELSE IF @flag = 'z'
BEGIN
	SET @sql = '
		SELECT MIN(counterparty_product_id), product_computed_name 
		FROM counterparty_products
		WHERE commodity_id IN (' + @dependent_id + ')
		GROUP BY product_computed_name
	'
	EXEC(@sql)
END

ELSE IF @flag = 'x'
BEGIN
	SELECT value_id, code FROM static_data_value WHERE type_id = 43200
END