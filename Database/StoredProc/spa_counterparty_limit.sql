IF OBJECT_ID('[dbo].[spa_counterparty_limit]','p') IS NOT NULL 
DROP PROC [dbo].[spa_counterparty_limit]
GO

--EXEC spa_counterparty_limit 's'
CREATE PROC [dbo].[spa_counterparty_limit]
	@flag CHAR(1),
	@counterparty_limit_id INT,
	@limit_type_id INT,		-- Volumetric / MTM / Tenor
	@applies_to CHAR(1),	-- Counterparty / Internal / All
	@counterparty_id INT,	
	@internal_rating_id INT,
	@volume_limit_type CHAR(1),
	@limit_value FLOAT,		-- Volume / Unsecured Limit / Limit (Months)
	@uom_id INT,
	@formula_id INT,
	@currency_id INT,
	@bucket_detail_id INT = NULL
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	
	SET @sql = '
	SELECT	 
		counterparty_limit_id [ID],
--		limit_type [Limit Type],
		sdv1.code [Limit Type],
--		applies_to,
--		counterparty_id [Counterparty],
		sc.counterparty_id [Counterparty],
--		internal_rating_id,
		sdv2.code [Internal Rating],
		rtbd.tenor_name [Tenor Bucket],'+
		CASE @limit_type_id
			when 5650 then 
				'
				CASE volume_limit_type 
					WHEN ''b'' THEN ''Buy''
					WHEN ''s'' THEN ''Sell''
					WHEN ''n'' THEN ''Net''
				END [Type], 
				'
			else ''
			end 

		+'
		limit_value as ['+ 
			CASE @limit_type_id 
				WHEN 5650 THEN 'Volume'
				WHEN 5651 THEN 'Unsecured Limit'
				WHEN 5652 THEN 'Limit (Month)'
			END 
		+'],
		'+
		CASE @limit_type_id 
			WHEN 5650 then 'uom.uom_id [UOM] '
			WHEN 5651 then 'cur.currency_id [Currency] '
			when 5652 then 'uom.uom_id [UOM] '
		end + '
		
	FROM counterparty_limits cl
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = cl.counterparty_id
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cl.limit_type
	LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cl.internal_rating_id
	LEFT JOIN source_uom uom ON uom.source_uom_id = cl.uom_id
	LEFT JOIN source_currency cur ON cur.source_currency_id = cl.currency_id
	LEFT JOIN risk_tenor_bucket_detail rtbd ON rtbd.bucket_detail_id = cl.bucket_detail_id
	WHERE 1 = 1
	'
	
	IF @limit_type_id IS NOT NULL 
		SET @sql = @sql + ' AND limit_type = ' + CAST(@limit_type_id AS VARCHAR)

	IF @counterparty_id IS NOT NULL 
		SET @sql = @sql + ' AND cl.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR)
	
	IF @internal_rating_id IS NOT NULL 
		SET @sql = @sql + ' AND cl.internal_rating_id = ' + CAST(@internal_rating_id AS VARCHAR)

	IF @bucket_detail_id IS NOT NULL 
		SET @sql = @sql + ' AND cl.bucket_detail_id = ' + CAST(@bucket_detail_id AS VARCHAR)
	
	EXEC spa_print @sql
	EXEC(@sql)
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
	INSERT INTO counterparty_limits(
			limit_type,
			applies_to,
			counterparty_id,
			internal_rating_id,
			volume_limit_type,
			limit_value,
			uom_id,
			formula_id,
			currency_id,
			bucket_detail_id 
		)
		VALUES(
			@limit_type_id,
			@applies_to,
			@counterparty_id,
			@internal_rating_id,
			@volume_limit_type,
			@limit_value,
			@uom_id,
			@formula_id,
			@currency_id,
			@bucket_detail_id
		)
	END TRY
	BEGIN CATCH

		IF @@ERROR =2627
			EXEC spa_ErrorHandler -1, 'Counterparty Limits Table', 
					'spa_counterparty_limits', 'DB Error', 
					'You are not allowed to insert duplicate limits.', ''
		
		ELSE IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, 'Counterparty Limits Table', 
					'spa_counterparty_limits', 'DB Error', 
					'Failed inserting data.', ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Counterparty Limits Table', 
					'spa_counterparty_limits', 'Success', 
					'Data insert Success', ''
	END CATCH
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
	UPDATE counterparty_limits
	SET 
		limit_type = @limit_type_id,
		applies_to = @applies_to,
		counterparty_id = @counterparty_id,
		internal_rating_id = @internal_rating_id,
		volume_limit_type = @volume_limit_type,
		limit_value = @limit_value,
		uom_id = @uom_id,
		formula_id = @formula_id,
		currency_id = @currency_id,
		bucket_detail_id = @bucket_detail_id
	WHERE counterparty_limit_id = @counterparty_limit_id
	END TRY
	BEGIN CATCH
	IF @@ERROR =2627
		EXEC spa_ErrorHandler -1, 'Counterparty Limits Table', 
				'spa_counterparty_limits', 'DB Error', 
				'You are not allowed to insert duplicate limits.', ''
	ELSE IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Counterparty Limits Table', 
				'spa_counterparty_limits', 'DB Error', 
				'Failed updating data.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Counterparty Limits Table', 
				'spa_counterparty_limits', 'Success', 
				'Data update Success', ''
	END CATCH
END

IF @flag = 'd'
BEGIN
	DELETE FROM counterparty_limits WHERE counterparty_limit_id = @counterparty_limit_id
			
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Counterparty Limits Table', 
				'spa_counterparty_limits', 'DB Error', 
				'Failed deleting data.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Counterparty Limits Table', 
				'spa_counterparty_limits', 'Success', 
				'Data delete Success', ''

END
IF @flag = 'a'
BEGIN
	SELECT 
--		counterparty_limit_id,
		limit_type,
		applies_to,
		counterparty_id,
		internal_rating_id,
		volume_limit_type,
		limit_value,
		uom_id,
		cl.formula_id,
		currency_id,
		cl.bucket_detail_id,
		formula_type,
		formula,
		rd.bucket_header_id
	FROM 
		counterparty_limits cl
		LEFT JOIN formula_editor fe ON cl.formula_id = fe.formula_id
		INNER JOIN risk_tenor_bucket_detail rd
		   ON rd.bucket_detail_id=cl.bucket_detail_id
	WHERE counterparty_limit_id = @counterparty_limit_id
END