
IF OBJECT_ID ('spa_approved_counterparty','p') IS NOT NULL 
	DROP PROC spa_approved_counterparty 
GO 

CREATE PROC dbo.spa_approved_counterparty
	@flag CHAR(1),
	@counterparty_id INT = NULL,
	@approved_counterparty_id INT = NULL,
	@xml text = NULL
AS 
SET NOCOUNT ON
BEGIN
	DECLARE @idoc INT
	IF @flag = 's' --Approved Counterparty Grid
	BEGIN
		SELECT	sc.counterparty_name,
				cp.product_computed_name [product_string],
				CASE 
					WHEN cp.buy_sell = 'b' THEN 'Buys'
					WHEN cp.buy_sell = 's' THEN 'Sells'
					ELSE 'Buys + Sells'
				END [buy_sell],
				scc.commodity_name,
				sdv.code [origin],
				CASE
					WHEN cp.is_organic = 'y' THEN 'Yes'
					ELSE 'No'
				END [is_organic],
				ctf.commodity_form_name,
				sdv1.code [commodity_form_attribute1],
				sdv2.code [commodity_form_attribute2],
				sdv3.code [commodity_form_attribute3],
				sdv4.code [commodity_form_attribute4],
				sdv5.code [commodity_form_attribute5],
				dbo.FNADecodeXML(ca_trader.trader_name) [trader_id],
				CASE WHEN COUNT(an.attachment_file_name) = 0 THEN '<span style="cursor:pointer" onClick="setup_counterparty.attach_document('''+CAST(c.source_counterparty_id AS VARCHAR(100))+''',''42006'',''NULL'','''+CAST(ap.approved_product_id AS VARCHAR(100))+''')"><font color=#ff000000><u><l>Upload<l></u></font></span>'
				ELSE  '<span style="cursor:pointer" onClick="setup_counterparty.attach_document('''+CAST(c.source_counterparty_id AS VARCHAR(100))+''',''42006'','''+CAST(an.notes_id AS VARCHAR(100))+''','''+CAST(ap.approved_product_id AS VARCHAR(100))+''')"><font color=#ff000000><u><l>Upload<l></u></font></span> <span style="cursor:pointer" onClick="setup_counterparty.remove_document('''+CAST(an.notes_id AS VARCHAR(100))+''')"><font color=#ff000000><u><l>Remove<l></u></font></span> (' + ISNULL('<a href=../../adiha.php.scripts/force_download.php?path=' + REPLACE(notes_attachment, attachment_file_name, '') + item + ' download>' + item + '</a>', '<a href=' + url + ' target=_blank>' + url + '<a>') + ')'
				END [attachment],
				ac.approved_counterparty_id,
				ap.approved_product_id
		FROM approved_counterparty ac
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = ac.approved_counterparty
		LEFT JOIN approved_product ap ON ap.approved_counterparty_id = ac.approved_counterparty_id
		LEFT JOIN counterparty_products cp ON cp.counterparty_product_id = ap.counterparty_product_id AND cp.counterparty_id = ac.approved_counterparty
		LEFT JOIN source_counterparty c ON c.source_counterparty_id = ac.counterparty_id
		LEFT JOIN application_notes an ON ap.approved_product_id = an.notes_object_id AND ISNULL(an.internal_type_value_id, 37) = 37 AND ISNULL(an.category_value_id, 42006) = 42006
		CROSS APPLY (
			SELECT STUFF(
				(
					SELECT ', '  + '<span style="cursor:pointer" onClick="setup_counterparty.open_popup_window('''','''+CAST(cc.counterparty_contact_id AS VARCHAR(100))+''',''ct'','''','''','''')"><font color=#000000ff><u><l>' +  + CAST(cc.name AS VARCHAR) + '<l></u></font></span>'
					FROM dbo.SplitCommaSeperatedValues(cp.trader_id) scsv
					INNER JOIN counterparty_contacts cc ON cc.counterparty_contact_id = scsv.item
					FOR XML PATH('')
				)
			, 1, 1, '') [trader_name]
		) ca_trader
		OUTER APPLY dbo.fnasplit(attachment_file_name, ', ')
		LEFT JOIN source_commodity scc ON scc.source_commodity_id = cp.commodity_id
		LEFT JOIN commodity_origin co ON co.commodity_origin_id = cp.commodity_origin_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = co.origin
		LEFT JOIN commodity_form cf ON cf.commodity_form_id = cp.commodity_form_id
		LEFT JOIN commodity_type_form ctf ON ctf.commodity_type_form_id = cf.form
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
		WHERE ac.counterparty_id = @counterparty_id
		GROUP BY sc.counterparty_name, scc.commodity_name, sdv.code, cp.is_organic, ctf.commodity_form_name,sdv1.code,sdv2.code,sdv3.code,sdv4.code,sdv5.code,
				ca_trader.trader_name, cp.buy_sell, item,notes_attachment,attachment_file_name, ac.approved_counterparty_id, ap.approved_product_id, c.source_counterparty_id,an.notes_id,cp.product_computed_name,an.url
	END
	ELSE IF @flag = 'c' -- Add approved counterparty
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		IF OBJECT_ID('tempdb..#temp_approved_counterparty') IS NOT NULL
			DROP TABLE #temp_approved_counterparty

		SELECT
			approved_counterparty_id,
			counterparty_id
		INTO #temp_approved_counterparty
		FROM OPENXML(@idoc, '/Root/Grid', 1)
		WITH (
			approved_counterparty_id INT,
			counterparty_id INT
		)

		INSERT INTO approved_counterparty (approved_counterparty, counterparty_id)
		SELECT approved_counterparty_id, counterparty_id
		FROM #temp_approved_counterparty

		EXEC spa_ErrorHandler 0,
			'approved_counterparty',
			'spa_approved_counterparty',
			'Success',
			'Changes have been saved successfully.',
			''
	END
	ELSE IF @flag = 'd' --Delete Approved Counteparty
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		IF OBJECT_ID('tempdb..#temp_delete_detail') IS NOT NULL
			DROP TABLE #temp_delete_detail

		SELECT
			grid_id
		INTO #temp_delete_detail
		FROM OPENXML(@idoc, '/Root/GridDeleteProduct', 1)
		WITH (
			grid_id INT
		)

		DELETE an
		FROM approved_product ap
		INNER JOIN application_notes an on an.notes_object_id = ap.approved_product_id
		INNER JOIN #temp_delete_detail tdd ON ap.approved_product_id = tdd.grid_id

		DELETE ap
		FROM approved_product ap
		INNER JOIN #temp_delete_detail tdd ON ap.approved_product_id = tdd.grid_id
		
		IF OBJECT_ID('tempdb..#temp_delete_counterparty') IS NOT NULL
			DROP TABLE #temp_delete_counterparty

		SELECT
			grid_id
		INTO #temp_delete_counterparty
		FROM OPENXML(@idoc, '/Root/GridDelete', 1)
		WITH (
			grid_id INT
		)

		DELETE an
		FROM approved_counterparty ac
		INNER JOIN approved_product ap on ap.approved_counterparty_id = ac.approved_counterparty_id
		INNER JOIN application_notes an on an.notes_object_id = ap.approved_product_id
		INNER JOIN #temp_delete_counterparty tdd ON ac.approved_counterparty_id = tdd.grid_id

		DELETE ap
		FROM approved_counterparty ac
		INNER JOIN approved_product ap on ap.approved_counterparty_id = ac.approved_counterparty_id
		INNER JOIN #temp_delete_counterparty tdd ON ac.approved_counterparty_id = tdd.grid_id

		DELETE ac
		FROM approved_counterparty ac
		INNER JOIN #temp_delete_counterparty tdd ON ac.approved_counterparty_id = tdd.grid_id
		
		EXEC spa_ErrorHandler 0,
			'counterparty_products',
			'spa_counterparty_products',
			'Success',
			'Changes have been saved successfully.',
			''
	END
	ELSE IF @flag = 'p' -- Add Approved Products
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		IF OBJECT_ID('tempdb..#temp_approved_product') IS NOT NULL
			DROP TABLE #temp_approved_product

		SELECT
			approved_counterparty_id,
			approved_product_id
		INTO #temp_approved_product
		FROM OPENXML(@idoc, '/Root/Grid', 1)
		WITH (
			approved_counterparty_id INT,
			approved_product_id INT
		)

		INSERT INTO approved_product (approved_counterparty_id, counterparty_product_id)
		SELECT tap.approved_counterparty_id, tap.approved_product_id
		FROM #temp_approved_product tap
		LEFT JOIN approved_product ap ON ap.approved_counterparty_id = tap.approved_counterparty_id AND ap.counterparty_product_id = tap.approved_product_id
		WHERE ap.counterparty_product_id IS NULL AND ap.approved_counterparty_id IS NULL

		EXEC spa_ErrorHandler 0,
			'approved_products',
			'spa_approved_counterparty',
			'Success',
			'Changes have been saved successfully.',
			''
	END
	ELSE IF @flag = 'y' -- Approved Product Grid
	BEGIN
		SELECT
			cp.counterparty_product_id,
			cp.product_computed_name,
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
			ctf.commodity_form_name,
			sdv1.code [commodity_form_attribute1],
			sdv2.code [commodity_form_attribute2],
			sdv3.code [commodity_form_attribute3],
			sdv4.code [commodity_form_attribute4],
			sdv5.code [commodity_form_attribute5],
			dbo.FNADecodeXML(ca_trader.trader_name) [trader_id]
		FROM counterparty_products cp
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
		LEFT JOIN source_commodity sc ON sc.source_commodity_id = cp.commodity_id
		LEFT JOIN commodity_origin co ON co.commodity_origin_id = cp.commodity_origin_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = co.origin
		LEFT JOIN commodity_form cf ON cf.commodity_form_id = cp.commodity_form_id
		LEFT JOIN commodity_type_form ctf ON ctf.commodity_type_form_id = cf.form
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
		LEFT JOIN approved_product ap ON ap.counterparty_product_id = cp.counterparty_product_id AND ap.approved_counterparty_id = @approved_counterparty_id
		LEFT JOIN approved_counterparty ac ON ap.approved_counterparty_id = ac.approved_counterparty_id
		WHERE cp.counterparty_id = @counterparty_id AND ac.approved_counterparty_id IS NULL
		GROUP BY cp.counterparty_product_id,buy_sell,commodity_name,sdv.code,is_organic,ctf.commodity_form_name,sdv1.code,sdv2.code,sdv3.code,sdv4.code,sdv5.code,ca_trader.trader_name,cp.counterparty_id,cp.product_computed_name
	END
	ELSE IF @flag = 'z'
	BEGIN
		CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
		EXEC spa_static_data_privilege @flag = 'p', @source_object = 'counterparty'

		DECLARE @sql VARCHAR(2000)
		SET @sql = '
			SELECT	sc.source_counterparty_id, 
					sc.counterparty_id,
					sc.counterparty_name, 
					MIN(cp.is_enable) [status]
			FROM #final_privilege_list cp ' 
			+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
			 source_counterparty sc ON sc.source_counterparty_id = cp.value_id
			LEFT JOIN approved_counterparty ap ON sc.source_counterparty_id = ap.approved_counterparty AND ap.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(10)) + '
			WHERE is_active = ''y'' AND ap.approved_counterparty IS NULL AND source_counterparty_id <> ' + CAST(@counterparty_id AS VARCHAR(10))
		
		SET @sql +=	' GROUP BY sc.source_counterparty_id, sc.counterparty_name, sc.counterparty_id
						ORDER BY sc.counterparty_id ASC'
		EXEC(@sql)
	END
END
