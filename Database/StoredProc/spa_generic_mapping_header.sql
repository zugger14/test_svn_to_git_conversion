
IF OBJECT_ID(N'[dbo].[spa_generic_mapping_header]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_generic_mapping_header]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

	/**
	This proc will be used to perform select, insert, update and delete from generic_mapping_header table

	Parameters
	@flag : POperation flag 
			's' --> for selecting desired data to display	
			'a'	--> to display the data in details grid
			'i'	--> for inserting the data in generic_mapping_values table
			'r'	--> to populate the data from generic_mapping_values table
			'u'	--> to update the table generic_mapping_values	
	@mapping_table_id :Unique ID of the mapping table. 
	@clm1_value : TBD
	@clm2_value : TBD
	@clm3_value : TBD
	@clm4_value : TBD
	@clm5_value : TBD
	@clm6_value : TBD
	@clm7_value : TBD
	@clm8_value : TBD
	@clm9_value : TBD
	@clm10_value : TBD
	@clm11_value : TBD
	@clm12_value : TBD
	@clm13_value : TBD
	@clm14_value : TBD
	@clm15_value : TBD
	@clm16_value : TBD
	@clm17_value : TBD
	@clm18_value : TBD
	@clm19_value : TBD
	@clm20_value : TBD
	@values_id: TBD
	@combo_sql_stmt: TBD
	@xml_value_insert_update: xml value
	@deleting_ids : Unique id of generic mapping data to be deleted. 
	@function_ids : TBD
	@primary_column_value : TBD
	@is_system : TBD
	@mapping_name: TBD
	*/

 --===============================================================================================================
 --Author: rkhatiwada@pioneersolutionsglobal.com
 --Create date: 2012-11-20
 --Description: This proc will be used to perform select, insert, update and delete from generic_mapping_header table
 --Params:
 --@flag CHAR(1) - Operation flag 
	--	flags used:	's' --> for selecting desired data to display	
	--				'a'	--> to display the data in details grid
	--				'i'	--> for inserting the data in generic_mapping_values table
	--				'r'	--> to populate the data from generic_mapping_values table
	--				'u'	--> to update the table generic_mapping_values	
 --===============================================================================================================
CREATE PROCEDURE [dbo].[spa_generic_mapping_header]
	@flag CHAR(1),
	@mapping_table_id VARCHAR(10) = NULL,
	@clm1_value NVARCHAR(500) = NULL,
	@clm2_value NVARCHAR(500) = NULL,
	@clm3_value NVARCHAR(500) = NULL,
	@clm4_value NVARCHAR(500) = NULL,
	@clm5_value NVARCHAR(500) = NULL,
	@clm6_value NVARCHAR(500) = NULL,
	@clm7_value NVARCHAR(500) = NULL,
	@clm8_value NVARCHAR(500) = NULL,
	@clm9_value NVARCHAR(500) = NULL,
	@clm10_value NVARCHAR(500) = NULL,
	@clm11_value NVARCHAR(500) = NULL,
	@clm12_value NVARCHAR(500) = NULL,
	@clm13_value NVARCHAR(500) = NULL,
	@clm14_value NVARCHAR(500) = NULL,
	@clm15_value NVARCHAR(500) = NULL,
	@clm16_value NVARCHAR(500) = NULL,
	@clm17_value NVARCHAR(500) = NULL,
	@clm18_value NVARCHAR(500) = NULL,
	@clm19_value NVARCHAR(500) = NULL,
	@clm20_value NVARCHAR(500) = NULL,
	@values_id VARCHAR(10) = NULL,
	@combo_sql_stmt NVARCHAR(4000) = NULL,
	@xml_value_insert_update NVARCHAR(MAX) = NULL,
	@deleting_ids VARCHAR(1000) = NULL,
	@function_ids VARCHAR(500) = NULL,
	@primary_column_value NVARCHAR(100) = NULL,
	@is_system BIT = NULL,
	@mapping_name NVARCHAR(100) = NULL
AS
/*****************************************Debug code******************************************
	DECLARE @flag CHAR(1),
			@mapping_table_id VARCHAR(10) = NULL,
			@clm1_value VARCHAR(500) = NULL,
			@clm2_value VARCHAR(500) = NULL,
			@clm3_value VARCHAR(500) = NULL,
			@clm4_value VARCHAR(500) = NULL,
			@clm5_value VARCHAR(500) = NULL,
			@clm6_value VARCHAR(500) = NULL,
			@clm7_value VARCHAR(500) = NULL,
			@clm8_value VARCHAR(500) = NULL,
			@clm9_value VARCHAR(500) = NULL,
			@clm10_value VARCHAR(500) = NULL,
			@clm11_value VARCHAR(500) = NULL,
			@clm12_value VARCHAR(500) = NULL,
			@clm13_value VARCHAR(500) = NULL,
			@clm14_value VARCHAR(500) = NULL,
			@clm15_value VARCHAR(500) = NULL,
			@clm16_value VARCHAR(500) = NULL,
			@clm17_value VARCHAR(500) = NULL,
			@clm18_value VARCHAR(500) = NULL,
			@clm19_value VARCHAR(500) = NULL,
			@clm20_value VARCHAR(500) = NULL,
			@values_id VARCHAR(10) = NULL,
			@combo_sql_stmt VARCHAR(5000) = NULL,
			@xml_value_insert_update VARCHAR(MAX) = NULL,
			@deleting_ids VARCHAR(1000) = NULL

	SELECT  
	@flag='i',
	@mapping_table_id='50',
	@xml_value_insert_update='
	<Root>
		<PSRecordset mapping_table_id="50" clm0_value="708" clm1_value="4689" clm2_value="4163" clm3_value="test" clm4_value="" ></PSRecordset> 
		<PSRecordset mapping_table_id="50" clm0_value="709" clm1_value="4706" clm2_value="3926" clm3_value="test" clm4_value="" ></PSRecordset> 
		<PSRecordset mapping_table_id="50" clm0_value="710" clm1_value="4268" clm2_value="3793" clm3_value="r3" clm4_value="" ></PSRecordset> 
	</Root>',
	@deleting_ids='711'
--***********************************************************************************/
SET NOCOUNT ON
	
DECLARE @sql NVARCHAR(MAX), @column_header NVARCHAR(MAX)

IF @flag = 's'
BEGIN
	IF @mapping_table_id IS NOT NULL
	BEGIN
		SELECT mapping_table_id [Mapping Table ID],
		   mapping_name [Mapping Table],
		   CASE 
		       WHEN [system_defined] = 1 THEN 'Yes'
		       WHEN [system_defined] = 0 THEN 'No'
	       END [System Defined]
		FROM generic_mapping_header
		WHERE mapping_table_id = @mapping_table_id
	END
	ELSE IF @mapping_table_id IS NULL AND @is_system = 1
	BEGIN
		SELECT mapping_table_id [Mapping Table ID],
		   mapping_name [Mapping Table],
		   CASE 
		       WHEN [system_defined] = 1 THEN 'Yes'
		       WHEN [system_defined] = 0 THEN 'No'
	       END [System Defined]
		FROM generic_mapping_header
		WHERE system_defined = 1
	END
	ELSE
	BEGIN
		SELECT mapping_table_id [Mapping Table ID],
		   mapping_name [Mapping Table],
		   CASE 
		       WHEN [system_defined] = 1 THEN 'Yes'
		       WHEN [system_defined] = 0 THEN 'No'
	       END [System Defined]
		FROM generic_mapping_header
		WHERE CASE WHEN @function_ids IS NULL OR @function_ids = '' THEN '' ELSE function_ids END LIKE (ISNULL('%' + @function_ids + '%',''))
		AND system_defined = 0
	END
END	
ELSE IF @flag = 'a'
BEGIN
	IF @mapping_table_id IS NULL AND @mapping_name IS NOT NULL --Mapping name is passed when called from web service
	BEGIN
		SELECT @mapping_table_id = mapping_table_id
		FROM generic_mapping_header
		WHERE mapping_name = @mapping_name
	END
	DECLARE @no_of_cols INT, @tol_col INT, @list_of_label NVARCHAR(MAX), @list_of_value NVARCHAR(MAX), @sql_qry NVARCHAR(MAX)
	DECLARE @primary_column_index INT

	SELECT mapping_table_id,
	       label,
	       udf 
	INTO #temp
	FROM (
		SELECT mapping_table_id, clm1_label, clm2_label, clm3_label, clm4_label, clm5_label, clm6_label, clm7_label, clm8_label, clm9_label, clm10_label,
			   clm11_label, clm12_label, clm13_label, clm14_label, clm15_label, clm16_label, clm17_label, clm18_label, clm19_label, clm20_label
		FROM generic_mapping_definition
		WHERE mapping_table_id = @mapping_table_id
	) p UNPIVOT (
	    udf FOR label IN (clm1_label, clm2_label, clm3_label, clm4_label, clm5_label, clm6_label, clm7_label, clm8_label, clm9_label, clm10_label, 
						  clm11_label, clm12_label, clm13_label, clm14_label, clm15_label, clm16_label, clm17_label, clm18_label, clm19_label, clm20_label
						  )
	) AS unpvt
	    
	SELECT @column_header = COALESCE(@column_header + ', ', '') + REPLACE(label, 'label', 'value') + ' AS [' + udf + ']'
	FROM #temp
	
	SET @list_of_label = ''
	SET @list_of_value = ''

	SELECT @no_of_cols = total_columns_used
	FROM generic_mapping_header
	WHERE mapping_table_id = @mapping_table_id

	SELECT @primary_column_index = primary_column_index
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id

	SET @tol_col = @no_of_cols
	SET @no_of_cols = 1

	WHILE @no_of_cols <= @tol_col
	BEGIN
		SET @list_of_label = @list_of_label + 'clm' + CAST(@no_of_cols AS NVARCHAR(10)) + '_udf_id,'		    
		SET @list_of_value = @list_of_value + 'clm' + CAST(@no_of_cols AS NVARCHAR(10)) + '_value,'		    
		SET @no_of_cols = @no_of_cols + 1
	END

	SET @list_of_label = LEFT(@list_of_label, LEN(@list_of_label) - 1)
	SET @list_of_value = LEFT(@list_of_value, LEN(@list_of_value) - 1)
	
	SET @sql_qry = '
	CREATE TABLE #sql_string_value (
		value VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		label VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		state VARCHAR(156) COLLATE DATABASE_DEFAULT 
	)

	SELECT generic_mapping_values_id [Generic Mapping Values ID], 
		   ' + @column_header + ' 
	INTO #temp_value FROM generic_mapping_values 
	WHERE mapping_table_id = ' + @mapping_table_id
	
	IF @primary_column_index IS NOT NULL AND NULLIF('',@primary_column_value) IS NOT NULL
		SET @sql_qry += ' AND clm' + CAST(@primary_column_index AS NVARCHAR) + '_value = ''' + CAST(@primary_column_value AS NVARCHAR) + ''''


	SET @sql_qry += '

	/*
	-- Commented as its seems that code has no effect on final output. Running fine after commenting this code.
	SELECT ' + @list_of_label + ' 
	INTO #temp_clm
	FROM generic_mapping_definition 
	WHERE mapping_table_id = ' + @mapping_table_id + '

	DECLARE @udf_template_id INT, @field_type VARCHAR(10), @sql_string VARCHAR(MAX), @field_label VARCHAR(1000)      

	SELECT udf_id, label 
	INTO #temp_clm_unpivot
	FROM (
		SELECT ' + @list_of_label + '
		FROM #temp_clm
	) p UNPIVOT(udf_id FOR label IN (' + @list_of_label + ')) AS unpvt;
		    
	DECLARE mapping_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR      
		SELECT udft.udf_template_id,			
			   udft.field_type,
			   REPLACE(ISNULL(NULLIF(udft.sql_string, ''''), uds.sql_string),'''''''''''',''''''''),
			   ''['' + field_label + '']''
		FROM user_defined_fields_template udft
		INNER JOIN #temp_clm_unpivot tcu
			ON tcu.udf_id = udft.udf_template_id	
		LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id
		WHERE udft.field_type = ''d''
	OPEN mapping_cursor    
	FETCH NEXT FROM mapping_cursor INTO @udf_template_id,@field_type,@sql_string,@field_label                             
	WHILE @@FETCH_STATUS = 0
	BEGIN			
		BEGIN TRY
			INSERT INTO #sql_string_value(value, label) 
			EXEC spa_execute_query @sql_string
		END TRY
		BEGIN CATCH
			INSERT INTO #sql_string_value(value, label, state) 
			EXEC spa_execute_query @sql_string
		END CATCH 	
			  
		DELETE FROM #sql_string_value			
		
		FETCH NEXT FROM mapping_cursor INTO @udf_template_id, @field_type, @sql_string, @field_label    
	END
			
	CLOSE mapping_cursor
	DEALLOCATE mapping_cursor;
	*/		

	SELECT * FROM #temp_value
			           
	'
	
	EXEC(@sql_qry)
END
ELSE IF @flag = 'i'
BEGIN
	IF OBJECT_ID('tempdb..#temp_values') IS NOT NULL 
		DROP TABLE #temp_values
				
	CREATE TABLE #temp_values (
		mapping_table_id VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		id VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm1_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm2_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm3_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm4_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm5_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm6_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm7_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm8_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm9_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm10_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm11_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm12_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm13_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm14_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm15_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm16_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm17_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm18_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm19_value NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
		clm20_value NVARCHAR(500) COLLATE DATABASE_DEFAULT 				
	)
					
	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_value_insert_update
		  
	INSERT INTO #temp_values (mapping_table_id, id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value,
							  clm11_value, clm12_value, clm13_value, clm14_value, clm15_value, clm16_value, clm17_value, clm18_value, clm19_value, clm20_value) 
	SELECT mapping_table_id, clm0_value, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value,
		   clm11_value, clm12_value, clm13_value, clm14_value, clm15_value, clm16_value, clm17_value, clm18_value, clm19_value, clm20_value			
	FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
	WITH (mapping_table_id VARCHAR(500) '@mapping_table_id',
		  clm0_value NVARCHAR(500) '@clm0_value',
		  clm1_value NVARCHAR(500) '@clm1_value',
		  clm2_value NVARCHAR(500) '@clm2_value',
		  clm3_value NVARCHAR(500) '@clm3_value',
		  clm4_value NVARCHAR(500) '@clm4_value',
		  clm5_value NVARCHAR(500) '@clm5_value',
		  clm6_value NVARCHAR(500) '@clm6_value',
		  clm7_value NVARCHAR(500) '@clm7_value',
		  clm8_value NVARCHAR(500) '@clm8_value',
		  clm9_value NVARCHAR(500) '@clm9_value',
		  clm10_value NVARCHAR(500) '@clm10_value',
		  clm11_value NVARCHAR(500) '@clm11_value',
		  clm12_value NVARCHAR(500) '@clm12_value',
		  clm13_value NVARCHAR(500) '@clm13_value',
		  clm14_value NVARCHAR(500) '@clm14_value',
		  clm15_value NVARCHAR(500) '@clm15_value',
		  clm16_value NVARCHAR(500) '@clm16_value',
		  clm17_value NVARCHAR(500) '@clm17_value',
		  clm18_value NVARCHAR(500) '@clm18_value',
		  clm19_value NVARCHAR(500) '@clm19_value',
		  clm20_value NVARCHAR(500) '@clm20_value'
	)
		 
	UPDATE #temp_values 
	SET id = NULLIF(id, ''),
		clm1_value = NULLIF(clm1_value, ''),
		clm2_value = NULLIF(clm2_value, ''),
		clm3_value = NULLIF(clm3_value, ''),
		clm4_value = NULLIF(clm4_value, ''),
		clm5_value = NULLIF(clm5_value, ''),
		clm6_value = NULLIF(clm6_value, ''),
		clm7_value = NULLIF(clm7_value, ''),
		clm8_value = NULLIF(clm8_value, ''),
		clm9_value = NULLIF(clm9_value, ''),
		clm10_value = NULLIF(clm10_value, ''),
		clm11_value = NULLIF(clm11_value, ''),
		clm12_value = NULLIF(clm12_value, ''),
		clm13_value = NULLIF(clm13_value, ''),
		clm14_value = NULLIF(clm14_value, ''),
		clm15_value = NULLIF(clm15_value, ''),
		clm16_value = NULLIF(clm16_value, ''),
		clm17_value = NULLIF(clm17_value, ''),
		clm18_value = NULLIF(clm18_value, ''),
		clm19_value = NULLIF(clm19_value, ''),
		clm20_value = NULLIF(clm20_value, '')
		
	DECLARE @row_count INT, @compare_count INT
	SELECT @row_count = COUNT(1) 
	FROM #temp_values
		
	IF OBJECT_ID('tempdb..#compare_temp_values') IS NOT NULL 
		DROP TABLE #compare_temp_values
				
	SELECT clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value, 
		   clm11_value, clm12_value, clm13_value, clm14_value, clm15_value, clm16_value, clm17_value, clm18_value, clm19_value, clm20_value
	INTO #compare_temp_values 
	FROM #temp_values		
	WHERE clm1_value IS NULL
		AND clm2_value IS NULL
		AND clm3_value IS NULL
		AND clm4_value IS NULL
		AND clm5_value IS NULL
		AND clm6_value IS NULL
		AND clm7_value IS NULL
		AND clm8_value IS NULL
		AND clm9_value IS NULL
		AND clm10_value IS NULL
		AND clm11_value IS NULL
		AND clm12_value IS NULL
		AND clm13_value IS NULL
		AND clm14_value IS NULL
		AND clm15_value IS NULL
		AND clm16_value IS NULL
		AND clm17_value IS NULL
		AND clm18_value IS NULL
		AND clm19_value IS NULL
		AND clm20_value IS NULL
		
	IF EXISTS (SELECT 1 FROM #compare_temp_values)
	BEGIN
		EXEC spa_ErrorHandler -1 , 'spa_generic_mapping_header' , 'spa_generic_mapping_header' , 'DB Error' , 'Please fill data in the blank row.' , ''			
		RETURN
	END
		
	IF OBJECT_ID('tempdb..#stop_saving') IS NOT NULL 
		DROP TABLE #stop_saving
			
	SELECT 1 counts 
	INTO #stop_saving 
	FROM generic_mapping_values gmv 
		LEFT JOIN #temp_values tv 
		ON ISNULL(tv.id, 1) = ISNULL(gmv.generic_mapping_values_id, 1)
			AND ISNULL(tv.clm1_value, 1) = ISNULL(gmv.clm1_value, 1)
			AND ISNULL(tv.clm2_value, 1) = ISNULL(gmv.clm2_value, 1)
			AND ISNULL(tv.clm3_value, 1) = ISNULL(gmv.clm3_value, 1)
			AND ISNULL(tv.clm4_value, 1) = ISNULL(gmv.clm4_value, 1)
			AND ISNULL(tv.clm5_value, 1) = ISNULL(gmv.clm5_value, 1)
			AND ISNULL(tv.clm6_value, 1) = ISNULL(gmv.clm6_value, 1)
			AND ISNULL(tv.clm7_value, 1) = ISNULL(gmv.clm7_value, 1)
			AND ISNULL(tv.clm8_value, 1) = ISNULL(gmv.clm8_value, 1)
			AND ISNULL(tv.clm9_value, 1) = ISNULL(gmv.clm9_value, 1)
			AND ISNULL(tv.clm10_value, 1) = ISNULL(gmv.clm10_value, 1)
			AND ISNULL(tv.clm11_value, 1) = ISNULL(gmv.clm11_value, 1)
			AND ISNULL(tv.clm12_value, 1) = ISNULL(gmv.clm12_value, 1)
			AND ISNULL(tv.clm13_value, 1) = ISNULL(gmv.clm13_value, 1)
			AND ISNULL(tv.clm14_value, 1) = ISNULL(gmv.clm14_value, 1)
			AND ISNULL(tv.clm15_value, 1) = ISNULL(gmv.clm15_value, 1)
			AND ISNULL(tv.clm16_value, 1) = ISNULL(gmv.clm16_value, 1)
			AND ISNULL(tv.clm17_value, 1) = ISNULL(gmv.clm17_value, 1)
			AND ISNULL(tv.clm18_value, 1) = ISNULL(gmv.clm18_value, 1)
			AND ISNULL(tv.clm19_value, 1) = ISNULL(gmv.clm19_value, 1)
			AND ISNULL(tv.clm20_value, 1) = ISNULL(gmv.clm20_value, 1)
	WHERE tv.mapping_table_id = gmv.mapping_table_id 
		
	SELECT @compare_count = COUNT(1) 
	FROM #stop_saving
		
	DECLARE @total_rows_count_in_physical_table INT

	SELECT @total_rows_count_in_physical_table = COUNT(1) 
	FROM generic_mapping_values 
	WHERE mapping_table_id = @mapping_table_id
		
	IF @compare_count = @row_count AND @total_rows_count_in_physical_table = @row_count 
	BEGIN
		EXEC spa_ErrorHandler 0 , 'spa_generic_mapping_header' , 'spa_generic_mapping_header' , 'Success' , 'Changes have been saved successfully.' , ''
		RETURN
	END 
		
	---------------------------------------validation for Mapping table Framework Contract column Order Deadline--------------------
	DECLARE @mapping_table_name VARCHAR(150)
	SELECT @mapping_table_name = mapping_name FROM generic_mapping_header WHERE mapping_table_id = @mapping_table_id

	IF (@mapping_table_name = 'Framework Contract')
	BEGIN
		DECLARE @validate_flag INT
		DECLARE @order_deadline VARCHAR(150)
		DECLARE @validate_cursor CURSOR
		SET @validate_cursor = CURSOR FOR
			SELECT clm7_value FROM #temp_values
		OPEN @validate_cursor
		FETCH NEXT
		FROM @validate_cursor INTO @order_deadline
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT 	@validate_flag = CASE WHEN LEFT(@order_deadline, 2) > 23 OR RIGHT(@order_deadline, 2) > 59 OR LEN(@order_deadline) > 5 OR LEN(@order_deadline) < 5
										THEN 1
										ELSE 0  END
			IF (@validate_flag = 1)
			BEGIN
				EXEC spa_ErrorHandler -1, 'Generic Mapping', 'spa_generic_mapping_header', 'DB Error', 'Hour and Minute of Order Deadline should be less than 24 and 60 respectively', ''
				RETURN
			END

			FETCH NEXT
			FROM @validate_cursor INTO @order_deadline
		END
		CLOSE @validate_cursor
		DEALLOCATE @validate_cursor
	END
	ELSE IF (@mapping_table_name = 'Remit Invoice Date')
	BEGIN
		DECLARE @time VARCHAR(150)

		SELECT @time = clm4_value FROM #temp_values

		IF OBJECT_ID('tempdb..#temp_time') IS NOT NULL
			DROP TABLE #temp_time

		CREATE TABLE #temp_time (
			id INT IDENTITY (1, 1),
			item VARCHAR(10) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO #temp_time
		SELECT *
		FROM [dbo].[FNASplit](@time, ':')
			
		IF (SELECT DISTINCT ISNUMERIC(item) FROM #temp_time) = 0
		BEGIN
			EXEC spa_ErrorHandler -1, 'Generic Mapping', 'spa_generic_mapping_header', 'DB Error', 'Hour, Minute and Second of Time should be less than 24, 60, 60 respectively', ''
			RETURN
		END

		IF EXISTS (SELECT 1 FROM #temp_time WHERE id = 1 AND item > 23)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Generic Mapping', 'spa_generic_mapping_header', 'DB Error', 'Hour, Minute and Second of Time should be less than 24, 60, 60 respectively', ''
			RETURN
		END

		IF EXISTS (SELECT 1 FROM #temp_time WHERE id = 2 AND item > 59)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Generic Mapping', 'spa_generic_mapping_header', 'DB Error', 'Hour, Minute and Second of Time should be less than 24, 60, 60 respectively', ''
			RETURN
		END

		IF EXISTS (SELECT 1 FROM #temp_time WHERE id = 3 AND item > 59)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Generic Mapping', 'spa_generic_mapping_header', 'DB Error', 'Hour, Minute and Second of Time should be less than 24, 60, 60 respectively', ''
			RETURN
		END
	END
	--------------------------------------END validation for Mapping table Framekwork Contract--------------------	
       
	SELECT @values_id = id, @clm1_value = clm1_value, @clm2_value = clm2_value, @clm3_value = clm3_value, @clm4_value = clm4_value, @clm5_value = clm5_value, @clm6_value = clm6_value,
		   @clm7_value = clm7_value, @clm8_value = clm8_value, @clm9_value = clm9_value, @clm10_value = clm10_value, @clm11_value = clm11_value, @clm12_value = clm12_value,
		   @clm13_value = clm13_value, @clm14_value = clm14_value, @clm15_value = clm15_value, @clm16_value = clm16_value, @clm17_value = clm17_value, @clm18_value = clm18_value,
		   @clm19_value = clm19_value 
	FROM #temp_values

 	DECLARE @unique_columns_index VARCHAR(5000), @unique_columns VARCHAR(8000), @unique_columns_label VARCHAR(8000), @select_query NVARCHAR(MAX), 
			@return_message VARCHAR(MAX), @unique_combination NVARCHAR(MAX), @count VARCHAR(50) 
 		
 	SELECT @unique_columns_index = gmd.unique_columns_index
 	FROM generic_mapping_definition AS gmd
 	WHERE gmd.mapping_table_id = @mapping_table_id
 		
 	IF OBJECT_ID('tempdb..#uniqueness_voilated') IS NOT NULL
		DROP TABLE #uniqueness_voilated
			
 	CREATE TABLE #uniqueness_voilated (voilate_flag CHAR(1) COLLATE DATABASE_DEFAULT )

 	IF @unique_columns_index IS NOT NULL
 	BEGIN
 		SET @select_query = NULL
 			
 		SELECT @unique_columns = COALESCE(@unique_columns + ',', '') + 'clm' + CAST(scsv.item AS NVARCHAR(10)) + '_value'
 		FROM dbo.SplitCommaSeperatedValues(@unique_columns_index) AS scsv
 			
 		IF OBJECT_ID('tempdb..#count') IS NOT NULL
			DROP TABLE #count
			
 		CREATE TABLE #count (count_col VARCHAR(50) COLLATE DATABASE_DEFAULT )
 			
 		SET @select_query = 'INSERT INTO #count SELECT COUNT(1) FROM #temp_values GROUP BY ' + @unique_columns
 		EXEC (@select_query) 
 			
 		IF EXISTS (SELECT count_col FROM #count WHERE count_col > 1)
 		BEGIN
 			SELECT @return_message = NULL, @unique_columns_label = NULL, @unique_combination = NULL    
						
			SELECT @unique_columns_label = COALESCE(@unique_columns_label + '+ '', '' + ', '' ) + 'clm' + scsv.item + '_label'
			FROM dbo.SplitCommaSeperatedValues(@unique_columns_index) AS scsv
			
			SET @sql = 'SELECT @unique_combination = ' + @unique_columns_label + ' FROM generic_mapping_definition WHERE mapping_table_id = ' + CAST(@mapping_table_id AS VARCHAR(10))
			EXEC sp_executesql @sql, N'@unique_combination varchar(max) output', @unique_combination OUTPUT
			
			SELECT @return_message = 'Data Error in <b>Generic Mapping</b> grid. Combination of <b>' + @unique_combination + '</b> should be unique.'
			
			EXEC spa_ErrorHandler -1, 'Generic Mapping', 'spa_generic_mapping_header', 'DB Error', @return_message, ''
			RETURN
 		END
 	END 	
 	--- --------------------------------------------unique column validation ends
 		
 	------------------------------------------------- required column validation start 		
 	DECLARE @required_columns NVARCHAR(4000), @sql_str NVARCHAR(MAX), @required_columns_label VARCHAR(8000), @required_columns_value VARCHAR(8000), @reqd_individual_column VARCHAR(100)

	SELECT @required_columns = required_columns_index
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		
	SELECT @required_columns_value = COALESCE(@required_columns_value + ',','') + 'clm' + scsv.item + '_value', @required_columns_label = COALESCE(@required_columns_label + '+ '', '' + ', '') + 'clm' + scsv.item + '_label'
	FROM dbo.SplitCommaSeperatedValues(@required_columns) AS scsv			
	
	IF OBJECT_ID('tempdb..#validate') IS NOT NULL
			DROP TABLE #validate
			
 	CREATE TABLE #validate (validate VARCHAR(50) COLLATE DATABASE_DEFAULT )
		
	DECLARE @required_field_cursor CURSOR
	SET @required_field_cursor = CURSOR FOR
	
	SELECT item 
	FROM dbo.SplitCommaSeperatedValues(@required_columns_value)
	
	OPEN @required_field_cursor		
	FETCH NEXT
	FROM @required_field_cursor INTO @reqd_individual_column
	WHILE @@FETCH_STATUS = 0
	BEGIN			
		EXEC ('
			INSERT INTO #validate
			SELECT 1  FROM #temp_values WHERE ' +  @reqd_individual_column + ' IS NULL'
		)
			
		IF EXISTS (SELECT 1 FROM #validate)
		BEGIN
			SET @sql_str = 'SELECT @required_columns = ' + @required_columns_label + ' FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id'

			EXEC sp_executesql @sql_str, N'@mapping_table_id INT, @required_columns VARCHAR(MAX) OUTPUT', @mapping_table_id, @required_columns OUTPUT
				
			SELECT @return_message = 'Data Error in <b>Generic Mapping</b> grid.Please enter numeric data in <b> ' + @required_columns + '</b> column and resave.'
			
			EXEC spa_ErrorHandler -1 , 'Generic Mapping' , 'spa_generic_mapping_header' , 'DB Error' , @return_message , ''
			RETURN
		END
		FETCH NEXT
		FROM @required_field_cursor INTO @reqd_individual_column
	END
		
	CLOSE @required_field_cursor
	DEALLOCATE @required_field_cursor
	-----------------------------------------------------------required column validation ends
		
	-----------------------------------------------------------numeric column validation starts
	DECLARE @numeric_columns NVARCHAR(4000), @numeric_columns_label VARCHAR(8000), @numeric_columns_value VARCHAR(8000), @numeric_individual_column VARCHAR(1000)

	IF OBJECT_ID('tempdb..#temp_udf_cloumns') IS NOT NULL
		DROP TABLE #temp_udf_cloumns

	CREATE TABLE #temp_udf_cloumns (
		mapping_table_id INT,
		column_name VARCHAR(20) COLLATE DATABASE_DEFAULT ,
		udf_id INT
	)

	INSERT INTO #temp_udf_cloumns
	SELECT mapping_table_id, udf_id, udf 
	FROM (SELECT mapping_table_id, clm1_udf_id, clm2_udf_id, clm3_udf_id, clm4_udf_id, clm5_udf_id, clm6_udf_id, clm7_udf_id, clm8_udf_id, clm9_udf_id, clm10_udf_id,
					clm11_udf_id, clm12_udf_id, clm13_udf_id, clm14_udf_id, clm15_udf_id, clm16_udf_id, clm17_udf_id, clm18_udf_id, clm19_udf_id, clm20_udf_id
			FROM generic_mapping_definition
			WHERE mapping_table_id = @mapping_table_id
	) p
	UNPIVOT (udf FOR udf_id IN (clm1_udf_id, clm2_udf_id, clm3_udf_id, clm4_udf_id, clm5_udf_id, clm6_udf_id, clm7_udf_id, clm8_udf_id, clm9_udf_id, clm10_udf_id, 
								clm11_udf_id, clm12_udf_id, clm13_udf_id, clm14_udf_id, clm15_udf_id, clm16_udf_id, clm17_udf_id, clm18_udf_id, clm19_udf_id, clm20_udf_id
								)
			) AS unpvt;		
		
	SELECT @numeric_columns_value = ISNULL(@numeric_columns_value + ',', '') + column_name, @numeric_columns_label = ISNULL(@numeric_columns_label + ',', '') + Field_label
	FROM #temp_udf_cloumns tuc
	INNER JOIN user_defined_fields_template udft
		ON udft.udf_template_id = tuc.udf_id
	WHERE field_type = 't'
		AND data_type = 'int'
				
	IF OBJECT_ID('tempdb..#validate_numeric') IS NOT NULL
		DROP TABLE #validate_numeric
			
 	CREATE TABLE #validate_numeric (validate NVARCHAR(50) COLLATE DATABASE_DEFAULT )
		
	DECLARE @numeric_field_cursor CURSOR
	SET @numeric_field_cursor = CURSOR FOR
	
	SELECT item FROM 
	dbo.SplitCommaSeperatedValues(@numeric_columns_value)
	
	OPEN @numeric_field_cursor		
	FETCH NEXT
	FROM @numeric_field_cursor INTO @reqd_individual_column
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @reqd_individual_column = REPLACE(@reqd_individual_column, 'udf_id', 'value')		
		EXEC ('
			INSERT INTO #validate_numeric
			SELECT DISTINCT 1  FROM #temp_values WHERE ISNUMERIC(ISNULL(' +  @reqd_individual_column + ', 1)) = 0'
		)
			
		IF EXISTS (SELECT 1 FROM #validate_numeric)
		BEGIN
			SET @sql_str = 'SELECT @numeric_columns = ''' + @numeric_columns_label + ''' FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id'
				
			EXEC sp_executesql @sql_str, N'@mapping_table_id INT, @numeric_columns VARCHAR(MAX) OUTPUT', @mapping_table_id, @numeric_columns OUTPUT
				
			SELECT @return_message = 'Data Error in <b>Generic Mapping</b> grid. Please enter numeric data in <b>' + @numeric_columns + '</b> column and resave.'
			
			EXEC spa_ErrorHandler -1 , 'Generic Mapping' , 'spa_generic_mapping_header' , 'DB Error' , @return_message , ''
			RETURN
		END
		FETCH NEXT
		FROM @numeric_field_cursor INTO @reqd_individual_column
	END
		
	CLOSE @numeric_field_cursor
	DEALLOCATE @numeric_field_cursor
	-----------------------------------------------------------numeric column validation ends
		
	MERGE generic_mapping_values AS t
	USING (SELECT mapping_table_id, id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value,
				  clm11_value, clm12_value, clm13_value, clm14_value, clm15_value, clm16_value, clm17_value, clm18_value, clm19_value, clm20_value	
		   FROM #temp_values		
	) AS s
	ON (t.generic_mapping_values_id = S.id) 
	WHEN NOT MATCHED BY TARGET 
		THEN INSERT(mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value, clm6_value, clm7_value, clm8_value, clm9_value, clm10_value,
					clm11_value, clm12_value, clm13_value, clm14_value, clm15_value, clm16_value, clm17_value, clm18_value, clm19_value, clm20_value) 
		VALUES(s.mapping_table_id, s.clm1_value, s.clm2_value, s.clm3_value, s.clm4_value, s.clm5_value, s.clm6_value, s.clm7_value, s.clm8_value, s.clm9_value, s.clm10_value,
			   s.clm11_value, s.clm12_value, s.clm13_value, s.clm14_value, s.clm15_value, s.clm16_value, s.clm17_value, s.clm18_value, s.clm19_value, s.clm20_value)
	WHEN MATCHED 
	THEN UPDATE SET clm1_value = s.clm1_value, clm2_value = s.clm2_value, clm3_value = s.clm3_value, clm4_value = s.clm4_value, clm5_value = s.clm5_value, clm6_value = s.clm6_value,
					clm7_value = s.clm7_value, clm8_value = s.clm8_value, clm9_value = s.clm9_value, clm10_value = s.clm10_value, clm11_value = s.clm11_value, clm12_value = s.clm12_value,
					clm13_value = s.clm13_value, clm14_value = s.clm14_value, clm15_value = s.clm15_value, clm16_value = s.clm16_value, clm17_value = s.clm17_value, clm18_value = s.clm18_value,
					clm19_value = s.clm19_value, clm20_value = s.clm20_value;
									
	IF @deleting_ids IS NOT NULL AND @deleting_ids <> ''
		EXEC('DELETE FROM generic_mapping_values where generic_mapping_values_id IN ('+ @deleting_ids +')')
		
	IF @@Error <> 0
	BEGIN
		EXEC spa_ErrorHandler -1 , '' , 'spa_generic_mapping_header' , 'DB Error' , 'Failed to Save the data.' , ''
	END			
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, '', 'spa_generic_mapping_header', 'Success', 'Changes have been saved successfully.', ''
	END			
END
IF @flag = 'm' 
BEGIN	
	DECLARE @generic_mapping_id INT, @required_column_index VARCHAR(1000), @column_name_list NVARCHAR(2000), @column_label_list NVARCHAR(2000), 
			@column_type_list NVARCHAR(2000), @column_width VARCHAR(5000), @dropdown_columns NVARCHAR(2000), @combo_sql NVARCHAR(4000), 
			@column_id VARCHAR(8000), @id VARCHAR(8000), @validation_rule VARCHAR(MAX)

	SELECT @required_column_index = required_columns_index 
	FROM generic_mapping_definition 
	WHERE mapping_table_id = @mapping_table_id

	IF OBJECT_ID('tempdb..#temp_selection') IS NOT NULL
		DROP TABLE #temp_selection
		
	CREATE TABLE #temp_selection (
		generic_mapping_values_id INT,
		mapping_table_id INT,
		label NVARCHAR(100) COLLATE DATABASE_DEFAULT ,
		id INT,
		udf NVARCHAR(100) COLLATE DATABASE_DEFAULT 
	)

	INSERT INTO #temp_selection (generic_mapping_values_id, mapping_table_id, label, id)
	SELECT generic_mapping_values_id, 
		   mapping_table_id,
	       label,
	       id
	FROM (
	        SELECT @generic_mapping_id generic_mapping_values_id, gmd.mapping_table_id, clm1_udf_id, clm2_udf_id, clm3_udf_id, clm4_udf_id, clm5_udf_id, clm6_udf_id, clm7_udf_id, clm8_udf_id,
	                clm9_udf_id, clm10_udf_id, clm11_udf_id, clm12_udf_id, clm13_udf_id, clm14_udf_id, clm15_udf_id, clm16_udf_id, clm17_udf_id, clm18_udf_id, clm19_udf_id, clm20_udf_id
	        FROM generic_mapping_definition gmd
	        WHERE gmd.mapping_table_id =  @mapping_table_id
	) p UNPIVOT (id FOR label IN (clm1_udf_id, clm2_udf_id, clm3_udf_id, clm4_udf_id, clm5_udf_id, clm6_udf_id, clm7_udf_id, clm8_udf_id, clm9_udf_id, clm10_udf_id, 
								  clm11_udf_id, clm12_udf_id, clm13_udf_id, clm14_udf_id, clm15_udf_id, clm16_udf_id, clm17_udf_id, clm18_udf_id, clm19_udf_id, clm20_udf_id
	            )
	) AS unpvt;
	          
	UPDATE ts
	SET ts.udf = udft.field_label 
	FROM #temp_selection ts 
		INNER JOIN user_defined_fields_template udft 
		ON udft.udf_template_id = ts.id
		
	SELECT @column_name_list = 'Generic Mapping Values ID', @column_id = 'generic_mapping_values_id', @column_type_list = 'ro_int', @validation_rule = ''

	SELECT @column_name_list =  COALESCE(@column_name_list + ',', '') + ts.udf,
		   @column_id = COALESCE(@column_id + ',', '') + replace(lower(ts.udf), ' ', '_' ), 
		   @column_type_list = COALESCE(@column_type_list + ',', '') + (CASE WHEN udft.Field_type ='a' THEN 'dhxCalendarA' 
				WHEN udft.Field_type ='d' THEN 'combo' 
				WHEN udft.Field_type ='m' THEN 'txttxt'
				WHEN udft.Field_type ='t' THEN CASE WHEN udft.data_type IN ('int', 'float', 'numeric(38,20)') THEN 'ed_no' ELSE 'ed' END
				END ), 
		   @column_width = COALESCE(@column_width + ',', '') + CAST(ISNULL(udft.field_size, 120) AS VARCHAR(500))  , 
		   @validation_rule = COALESCE(@validation_rule + ',' , '') +  (CASE WHEN t.item IS NULL THEN '' ELSE 'NotEmpty' END)
	FROM #temp_selection ts  INNER JOIN user_defined_fields_template udft ON ts.id = udft.udf_template_id
		LEFT JOIN dbo.SplitCommaSeperatedValues(@required_column_index) t
		ON t.item = SUBSTRING(ts.label, 4, LEN(ts.label) - 10)
		          
	SELECT @dropdown_columns = COALESCE(@dropdown_columns + ',', '') + replace(lower(ts.udf), ' ', '_' ),  
		   @combo_sql = COALESCE(@combo_sql + ':', '') + ISNULL(ISNULL(NULLIF(udft.sql_string, ''''), uds.sql_string), '')
	FROM #temp_selection ts  
	INNER JOIN user_defined_fields_template udft 
		ON ts.udf = udft.Field_label 
	LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id
	WHERE udft.field_type = 'd'
			
	SELECT @column_name_list name_list, @column_id column_id, @column_type_list field_type, @column_width width, @dropdown_columns combo_columns, @combo_sql combo_sql, @validation_rule validation_rule
END
IF @flag = 'n' 
BEGIN
	IF OBJECT_ID('tempdb..#temp_combo') IS NOT NULL
	DROP TABLE #temp_combo
	
	CREATE TABLE #temp_combo ([value] NVARCHAR(500) COLLATE DATABASE_DEFAULT , [text] NVARCHAR(1000) COLLATE DATABASE_DEFAULT , [state] VARCHAR(156) COLLATE DATABASE_DEFAULT )
	DECLARE @type CHAR(1)
 	SET @type = SUBSTRING(@combo_sql_stmt, 1, 1)
	
 	IF @type = '['
 	BEGIN
 		SET @combo_sql_stmt = REPLACE(@combo_sql_stmt, CHAR(13), '')
 		SET @combo_sql_stmt = REPLACE(@combo_sql_stmt, CHAR(10), '')
 		SET @combo_sql_stmt = REPLACE(@combo_sql_stmt, CHAR(32), '')	
 		SET @combo_sql_stmt = [dbo].[FNAParseStringIntoTable](@combo_sql_stmt)  
 		EXEC('INSERT INTO #temp_combo([value], [text], [state])
 				SELECT value_id, code, ''enabled'' from (' + @combo_sql_stmt + ') a(value_id, code)');

 	END 
 	ELSE
 	BEGIN	
		BEGIN TRY
			INSERT INTO #temp_combo(value, text)
			EXEC(@combo_sql_stmt)
		END TRY
		BEGIN CATCH
			INSERT INTO #temp_combo(value, text, state)
			EXEC(@combo_sql_stmt)
		END CATCH
	END

	DECLARE @xml XML, @param NVARCHAR(100), @sql_statement NVARCHAR(4000)

	SET @param = N'@xml XML OUTPUT';
	
		SET @sql_statement = ' SET @xml = (SELECT [value], REPLACE([text], ''"'', ''\"'') text, state
					 FROM #temp_combo ORDER BY [text] ASC
					 FOR XML RAW (''row''), ROOT (''root''), ELEMENTS)'
	
	EXECUTE sp_executesql @sql_statement, @param,  @xml = @xml OUTPUT;	
		
	IF CHARINDEX('[', dbo.FNAFlattenedJSON(@xml)) = 0
		SELECT '{options:[' + dbo.FNAFlattenedJSON(@xml) + ']}' json_string
	ELSE 
		SELECT '{options:' + dbo.FNAFlattenedJSON(@xml) + '}' json_string 
END
GO
