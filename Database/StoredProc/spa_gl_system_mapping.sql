/****** Object:  StoredProcedure [dbo].[spa_gl_system_mapping]    Script Date: 09/24/2009 10:21:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_gl_system_mapping]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_gl_system_mapping]
 GO
--This proc will be used to perform select, insert, update and delete gl_system_mapping data
--TSelect can be performed by any of the combination of the three parameters, Category1, category2, category3 or For
--all the records in gl_system_mapping table.
--category1, category2 and category3 are drop down of static data values (call sp_staticDataValues to get this drop downs)
--For category1 - call sp_staticDataValues(s,10004) i:e: type of GL account code Type1
--For category2 - call sp_staticDataValues(s,10005) i:e: type of GL account code Type2
--For category2 - call sp_staticDataValues(s,10006) i:e: type of GL account code Type1
--To select all gl_system_mapping data, categories values should be set to NULL
--TO insert pass the parameters - (@flag, @category1,@category2,@category3,NULL, @fas_subsidiary_id, @gl_account_name,
--		@gl_account_desc1,@gl_account_desc2,@gl_account_number)
--TO update pass the parameters - (@flag, @category1,@category2,@category3,@gl_number_id, @fas_subsidiary_id, 
--		@gl_account_name,@gl_account_desc1,@gl_account_desc2,@gl_account_number)
--TO delete - Pass the flag as 'd' and the @gl_number_id and pass the othe parameters as NULL

-- drop proc spa_gl_system_mapping
-- exec spa_gl_system_mapping 's', 5073, null, null, null, 1


CREATE PROC [dbo].[spa_gl_system_mapping]
	@flag CHAR(1),
	@category1 INT = NULL,
	@category2 INT = NULL,
	@category3 INT = NULL,
	@gl_number_id INT = NULL,
	@fas_subsidiary_id INT = NULL,
	@gl_account_name VARCHAR(150) = NULL,
	@gl_account_desc1 VARCHAR(250) = NULL,
	@gl_account_desc2 VARCHAR(250) = NULL,
	@gl_account_number VARCHAR(250) = NULL,
	
	--added parameter for new ui
	@account_type VARCHAR(100) = NULL,
	@message VARCHAR(100) = NULL,
	@del_gl_number_id VARCHAR(MAX) = NULL
	
AS

DECLARE @errorCode INT
SET NOCOUNT ON
IF @flag = 's'
BEGIN
	DECLARE @SelectStr VARCHAR(5000)
	
--	set @SelectStr = 'Select * from gl_system_mapping WHERE fas_subsidiary_id = ' + cast(@fas_subsidiary_id as Varchar)
	DECLARE @gl_account_number_label VARCHAR(150),
			@gl_account_desc1_label VARCHAR(150),
			@gl_account_desc2_label VARCHAR(150),
			@gl_account_name_label VARCHAR(150)


	SELECT @gl_account_name_label = ISNULL(customer_label, our_label) 
	FROM column_label
	WHERE form_name = 'gl_system_mapping' AND field_name = 'gl_account_name'

	SELECT @gl_account_desc1_label = ISNULL(customer_label, our_label) 
	 FROM column_label
	WHERE form_name = 'gl_system_mapping' AND field_name = 'gl_account_desc1'

	SELECT @gl_account_desc2_label = ISNULL(customer_label, our_label) 
	 FROM column_label
	WHERE form_name = 'gl_system_mapping' AND field_name = 'gl_account_desc2'

	SELECT @gl_account_number_label = ISNULL(customer_label, our_label) 
	 FROM column_label
	WHERE form_name = 'gl_system_mapping' AND field_name = 'gl_account_number'



SET @SelectStr = 'SELECT  gl_system_mapping.gl_number_id AS ID, gl_code1.code AS [GL Group1], gl_code2.code AS [GL Group2], 
								gl_code3.code AS GLGoup3, gl_system_mapping.gl_account_number AS [' + @gl_account_number_LABEL + '],
								gl_system_mapping.gl_account_name AS [' + @gl_account_name_label + '], 
								gl_system_mapping.gl_account_desc1 AS [' + @gl_account_desc1_label + '], 
								gl_system_mapping.gl_account_desc2 AS [' + @gl_account_desc2_label + '],
								gl_system_mapping.create_user AS [Create By],
								gl_system_mapping.gl_number_id AS ID, portfolio_hierarchy.entity_name AS Subsidiary,  
								dbo.FNADateTimeFormat(gl_system_mapping.create_ts,1) AS [Create TS], gl_system_mapping.update_user AS [Update By], 
								dbo.FNADateTimeFormat(gl_system_mapping.update_ts,1) AS [Update TS]
					FROM gl_system_mapping 
					LEFT OUTER JOIN	portfolio_hierarchy ON gl_system_mapping.fas_subsidiary_id = portfolio_hierarchy.entity_id 
					LEFT OUTER JOIN	static_data_value gl_code3 ON gl_system_mapping.gl_code3_value_id = gl_code3.value_id 
					LEFT OUTER JOIN static_data_value gl_code2 ON gl_system_mapping.gl_code2_value_id = gl_code2.value_id 
					LEFT OUTER JOIN	static_data_value gl_code1 ON gl_system_mapping.gl_code1_value_id = gl_code1.value_id
					WHERE gl_system_mapping.fas_subsidiary_id = ' + CAST(@fas_subsidiary_id AS VARCHAR)

	IF @category1 IS NOT NULL 
		SET @SelectStr = @SelectStr + ' AND  gl_code1_value_id = ' + CAST(@category1 AS VARCHAR)

	IF @category2 IS NOT NULL 
		SET @SelectStr = @SelectStr + ' AND  gl_code2_value_id = ' + CAST(@category2 AS VARCHAR)

	IF @category3 IS NOT NULL 
		SET @SelectStr = @SelectStr + ' AND  gl_code3_value_id = ' + CAST(@category3 AS VARCHAR)

	SET @SelectStr = @SelectStr + ' ORDER BY gl_code1.code, gl_system_mapping.gl_number_id, gl_code2.code, gl_code3.code'

	--PRINT @SelectStr
	EXEC (@selectStr)
		
	SET @errorCode = @@ERROR
	IF @errorCode <> 0
	EXEC spa_ErrorHandler @errorCode
		, 'GL System Mapping'
		, 'spa_gl_system_mappint'
		, 'DB ERROR'
		, 'Failed TO SELECT GL Codes.'
		, ''
END	

IF @flag = 'a'
BEGIN
	SELECT gl_account_name,
			gl_account_number,
			fas_subsidiary_id,
			gl_account_desc1,
			gl_account_desc2,
			gl_code1_value_id,
			gl_code2_value_id,
			gl_code3_value_id
	FROM gl_system_mapping 
	WHERE gl_number_id = @gl_number_id
END	

IF @flag = 'f'
BEGIN
	SELECT *
	FROM gl_system_mapping 
	WHERE gl_number_id = @gl_number_id
END	
ELSE IF @flag = 'v'
BEGIN
	IF EXISTS (SELECT 1 FROM gl_system_mapping WHERE gl_account_name = @gl_account_name)
	SET @message = 'Account Name ' + @gl_account_name + ' already exists.'
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'GL System Mapping'
			, 'spa_gl_system_mapping'
			, 'DB Error'
			, @message
			, ''
		RETURN
	END
END	

ELSE IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 1 FROM gl_system_mapping WHERE gl_account_number = @gl_account_number
				AND gl_account_name = @gl_account_name)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'GL System Mapping'
			, 'spa_gl_system_mapping'
			, 'DB Error'
			, 'This combination of Account Name and Account Number already exists.'
			, ''
		RETURN
	END
	ELSE
	BEGIN
		--SET IDENTITY_INSERT gl_system_mapping ON
		INSERT INTO gl_system_mapping(fas_subsidiary_id, gl_code1_value_id,	gl_code2_value_id, gl_code3_value_id,
										gl_account_name, gl_account_desc1, gl_account_desc2, gl_account_number)
		VALUES(@fas_subsidiary_id, @category1, @category2, @category3,
				@gl_account_name, @gl_account_desc1, @gl_account_desc2, @gl_account_number)

		SET @errorCode = @@ERROR
		IF @errorCode <> 0
		EXEC spa_ErrorHandler @errorCode
			, 'GL System Mapping'
			, 'spa_gl_system_mapping'
			, 'DB ERROR'
			, 'Failed TO INSERT GL Code.'
			, ''
		ELSE
		EXEC spa_ErrorHandler 0
			, 'GL System Mapping'
			, 'spa_gl_system_mapping'
			, 'Success'
			, 'GL code inserted.'
			, ''
	END
END	
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS (SELECT 1 FROM gl_system_mapping WHERE gl_account_number = @gl_account_number
				AND gl_account_name = @gl_account_name AND gl_number_id <> @gl_number_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'GL System Mapping'
			, 'spa_gl_system_mapping'
			, 'DB Error'
			, 'This combination of Account Name and Account Number already exists.'
			, ''
		RETURN
	END
	ELSE
	BEGIN
		UPDATE	gl_system_mapping
		SET 	fas_subsidiary_id = @fas_subsidiary_id, 
				gl_code1_value_id = @category1,
				gl_code2_value_id = @category2,
				gl_code3_value_id = @category3,
				gl_account_name = @gl_account_name,
				gl_account_desc1 = @gl_account_desc1,
				gl_account_desc2 = @gl_account_desc2,
				gl_account_number = @gl_account_number
		WHERE	gl_number_id = @gl_number_id

		SET @errorCode = @@ERROR
		IF @errorCode <> 0
		EXEC spa_ErrorHandler @errorCode
			, 'GL System Mapping'
			, 'spa_gl_system_mapping'
			, 'DB ERROR'
			, 'Failed TO UPDATE GL Code.'
			, ''
		ELSE
		EXEC spa_ErrorHandler 0
			, 'GL System Mapping'
			, 'spa_gl_system_mapping'
			, 'Success'
			, 'GL code updated.'
			, ''
	END
END	
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE gsm
		FROM dbo.FNASplit(@del_gl_number_id,',') a
		INNER JOIN gl_system_mapping gsm
		ON gsm.gl_number_id = a.item
		
		EXEC spa_ErrorHandler 0
		, 'GL System Mapping'
		, 'spa_gl_system_mapping'
		, 'Success'
		, 'Changes have been successfully saved.'
		, @del_gl_number_id

	END TRY
	BEGIN CATCH
		SET @errorCode = @@ERROR
		EXEC spa_ErrorHandler -1
		, 'GL System Mapping'
		, 'spa_gl_system_mapping'
		, 'DB ERROR'
		, 'Failed TO DELETE GL Code.'
		, ''
	END CATCH
END 
ELSE IF @flag = 'g' -- to show in the drop down
BEGIN
	SELECT	gl_system_mapping.gl_number_id AS ID,
			gl_system_mapping.gl_account_name + '(' + gl_system_mapping.gl_account_number + ')' AS accountname
	FROM gl_system_mapping

END
--exec spa_gl_system_mapping 'n'
ELSE IF @flag = 'n' -- to show grid in new application ui
BEGIN
	SELECT	gsm.gl_number_id,
			ISNULL(gsm.gl_account_name, '') AS gl_account_name,
			ISNULL(sdv4.code, '') AS account_name,
			ISNULL(sdv5.code, '') AS account_type,
			gsm.gl_account_desc1 AS gl_account_desc1,
			gsm.gl_account_desc2 AS gl_account_desc2,
			gsm.gl_account_number AS gl_account_number,
			CASE 
				WHEN (gsm.estimated_actual = 'a') THEN 'Actual' 
				WHEN (gsm.estimated_actual = 'e') THEN 'Estimated' 
				ELSE 'Cash Applied' 
			END AS estimated_actual,
			ph.entity_name AS fas_subsidiary_id,
			sdv1.code AS gl_code1_value_id,
			sdv2.code AS gl_code2_value_id,
			sdv3.code AS gl_code3_value_id,
			CASE 
				WHEN (gsm.is_reversal = 'y') THEN 'Yes' 
				ELSE 'No' 
			END AS is_reversal,
			CASE 
				WHEN (gsm.is_active = 'y') THEN 'Yes' 
				ELSE 'No' 
			END AS is_active
	FROM gl_system_mapping gsm
	LEFT OUTER JOIN	portfolio_hierarchy ph ON gsm.fas_subsidiary_id = ph.entity_id 
	LEFT OUTER JOIN	static_data_value sdv1 ON gsm.gl_code1_value_id = sdv1.value_id 
	LEFT OUTER JOIN static_data_value sdv2 ON gsm.gl_code2_value_id = sdv2.value_id 
	LEFT OUTER JOIN	static_data_value sdv3 ON gsm.gl_code3_value_id = sdv3.value_id
	LEFT OUTER JOIN	static_data_value sdv4 ON gsm.chart_of_account_name = sdv4.value_id
	LEFT OUTER JOIN	static_data_value sdv5 ON gsm.chart_of_account_type = sdv5.value_id
	ORDER BY gl_account_name ASC
END

GO