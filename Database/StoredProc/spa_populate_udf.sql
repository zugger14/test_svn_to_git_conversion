 IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_populate_udf]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_populate_udf]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Stored procedure for UDF template related operations.

	Parameters
	@flag: Operation flag
			's' - List static data (UDF Group)
			'a' - List UDF templates
			'i' - Insert UDF template
			'u' - Update UDF template
			'l' - Get data type for UDF template
	@xml: UDF XML (for insert/update)
	@udf_template_id: UDF template id
*/

CREATE PROCEDURE [dbo].[spa_populate_udf]
	@flag char(1),
	@xml VARCHAR(MAX) = NULL,
	@udf_template_id INT = NULL
AS
SET NOCOUNT ON
BEGIN
	DECLARE @sql_stmt varchar(8000)
	if @flag ='s'
	BEGIN
		SET @sql_stmt ='select type_id,type_name from static_data_type where type_id in (14450,14500,14550)'
		exec(@sql_stmt)
	END
	IF @flag ='a'
	BEGIN
		SET @sql_stmt ='SELECT  udft.udf_template_id		[udf_template_id], 
								sdv.code					[field_name], 
								udft.field_label			[field_label],
								CASE WHEN udft.field_type = ''t'' THEN ''Text Field''
									 WHEN udft.field_type = ''d'' THEN ''Dropdown''
									 WHEN udft.field_type = ''c'' THEN ''Checkbox''
									 WHEN udft.field_type = ''m'' THEN ''Multi Line''
									 WHEN udft.field_type = ''a'' THEN ''Date Field''
									 WHEN udft.field_type = ''w'' THEN ''Formula''
									 WHEN udft.field_type = ''e'' THEN ''Time''
								END							[field_type],								
								CASE WHEN udft.udf_type = ''d'' THEN ''Deal Detail''
									 WHEN udft.udf_type = ''h'' THEN ''Deal Header''
									 WHEN udft.udf_type = ''o'' THEN ''Others''
								END							[udf_type],								
								udft.data_type				[data_type],
								sdv_ift.code				[internal_field_type],
								udft.leg					[leg],																
								sdv_uc.code			[udf_category],
								CASE WHEN udft.deal_udf_type = ''c'' THEN ''Cost''
									 WHEN udft.deal_udf_type = ''u'' THEN ''UDF''
								END		[deal_udf_type],
								udft.include_in_credit_exposure,
                                udft.is_active
						FROM user_defined_fields_template udft 
						INNER JOIN static_data_value sdv 
							ON sdv.value_id = udft.field_name
						LEFT JOIN static_data_value sdv_ift 
							ON sdv_ift.value_id = udft.internal_field_type 
							AND sdv_ift.type_id = 18700
						LEFT JOIN static_data_value sdv_uc 
							ON sdv_uc.value_id = udft.udf_category 
							AND sdv_ift.type_id = 101900						
						'
		EXEC(@sql_stmt)
	END
	IF @flag IN ('i', 'u')  
	BEGIN 
		DECLARE @idoc INT, @desc VARCHAR(MAX)
		DECLARE @field_name INT
			  , @field_id INT
			  , @field_label VARCHAR(100)
			  , @field_type VARCHAR(100)
			  , @data_type VARCHAR(100)
			  , @data_source_type_id VARCHAR(100)
			  , @window_id VARCHAR(100)
			  , @formula_id VARCHAR(100)
			  , @sql_string VARCHAR(500)
			  , @udf_type VARCHAR(100)
			  , @default_value VARCHAR(100)
			  , @default_value_date VARCHAR(100)
			  , @udf_category VARCHAR(100)
			  , @deal_udf_type VARCHAR(100)			  
			  , @internal_field_type VARCHAR(100)
			  , @leg INT
			  , @function_id INT
			  , @include_in_credit_exposure VARCHAR(100)
              , @is_active CHAR(1)
          

		IF OBJECT_ID('tempdb..#temp_setup_udf') IS NOT NULL
			DROP TABLE #temp_setup_udf

		CREATE TABLE #temp_setup_udf(			
				udf_template_id		VARCHAR(100) COLLATE database_default, 
				field_name			VARCHAR(100) COLLATE database_default, 
				field_id			VARCHAR(100) COLLATE database_default, 
				field_label			VARCHAR(100) COLLATE database_default, 
				field_type			VARCHAR(100) COLLATE database_default, 
				data_type			VARCHAR(50) COLLATE database_default, 
				data_source_type_id	VARCHAR(500) COLLATE database_default, 
				window_id			VARCHAR(100) COLLATE database_default, 
				formula_id			VARCHAR(100) COLLATE database_default, 
				sql_string			VARCHAR(500) COLLATE database_default, 
				udf_type			VARCHAR(100) COLLATE database_default, 
				default_value		VARCHAR(250) COLLATE database_default,	
				default_value_date	VARCHAR(250) COLLATE database_default,	
				udf_category		VARCHAR(100) COLLATE database_default,	
				deal_udf_type		VARCHAR(100) COLLATE database_default,				
				internal_field_type	VARCHAR(100) COLLATE database_default,
				leg					VARCHAR(100) COLLATE database_default,
				include_in_credit_exposure VARCHAR(100) COLLATE database_default,
                is_active           CHAR(1)  COLLATE database_default
		)
		
	
		
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml		
		
		INSERT INTO #temp_setup_udf(
				  udf_template_id		
				, field_name			
				, field_id
				, field_label	
				, field_type			
				, data_type			
				, data_source_type_id
				, window_id			
				, formula_id			
				, sql_string			
				, udf_type			
				, default_value
				, default_value_date	
				, udf_category		
				, deal_udf_type							
				, internal_field_type	
				, leg
				, include_in_credit_exposure
                , is_active
		)
		SELECT 
				  NULLIF(udf_template_id, '')
				, NULLIF(field_name, '')
				, NULLIF(field_id, '')
				, NULLIF(field_label, '')	
				, NULLIF(field_type, '')	
				, NULLIF(data_type, '')		
				, NULLIF(data_source_type_id, '')	
				, NULLIF(window_id, '')		
				, NULLIF(formula_id, '')	
				, NULLIF(sql_string, '')	
				, NULLIF(udf_type, '')	
				, NULLIF(default_value, '')
				, NULLIF(default_value_date, '')		
				, NULLIF(udf_category, '')
				, NULLIF(deal_udf_type, '')					
				, NULLIF(internal_field_type, '')
				, NULLIF(leg, '')
				, NULLIF(include_in_credit_exposure, '')
                , NULLIF(is_active, '')
		FROM   OPENXML (@idoc, '/Root/FormXML', 2)
		WITH (							
				udf_template_id		VARCHAR(100) '@udf_template_id',
				field_name			VARCHAR(100) '@field_name', 
				field_id			VARCHAR(100) '@field_id',
				field_label			VARCHAR(100) '@field_label',
				field_type			VARCHAR(100) '@field_type',
				data_type			VARCHAR(50)  '@data_type',
				data_source_type_id	VARCHAR(500) '@data_source_type_id',
				window_id			VARCHAR(100) '@window_id',
				formula_id			VARCHAR(100) '@formula_id',
				sql_string			VARCHAR(500) '@sql_string',
				udf_type			VARCHAR(100) '@udf_type',
				default_value		VARCHAR(250) '@default_value',	
				default_value_date	VARCHAR(250) '@default_value_date',	
				udf_category		VARCHAR(100) '@udf_category',	
				deal_udf_type		VARCHAR(100) '@deal_udf_type',				
				internal_field_type VARCHAR(100) '@internal_field_type',								
				leg					VARCHAR(100) '@leg',
				include_in_credit_exposure VARCHAR(100) '@include_in_credit_exposure',
                is_active CHAR(1) '@is_active'
		)

		SELECT @udf_template_id = udf_template_id
			 , @field_name	= field_name
			 , @field_id = field_id
			 , @field_label = field_label
			 , @field_type = field_type
			 , @data_type = data_type
			 , @data_source_type_id	= data_source_type_id
			 , @window_id = window_id
			 , @formula_id	= formula_id
			 , @sql_string	= sql_string
			 , @udf_type = udf_type
			 , @default_value = default_value
			 , @default_value_date = default_value_date
			 , @udf_category = udf_category
			 , @deal_udf_type = deal_udf_type			 
			 , @internal_field_type = internal_field_type
			 , @leg = leg
			 , @include_in_credit_exposure = include_in_credit_exposure
             , @is_active = is_active
		FROM #temp_setup_udf
		
		DECLARE @udf_data_source_id INT

		SELECT @udf_data_source_id = udf_data_source_id 
		FROM udf_data_source 
		WHERE udf_data_source_name = 'custom'

		IF (@flag = 'i')
		BEGIN	
			BEGIN TRY
				BEGIN TRAN 
				INSERT INTO user_defined_fields_template(
						field_name
					   ,field_id
					   ,field_label
					   ,field_type
					   ,data_type
					   ,data_source_type_id
					   ,window_id
					   ,formula_id
					   ,sql_string
					   ,udf_type
					   ,default_value					   
					   ,udf_category
					   ,deal_udf_type					   
					   ,internal_field_type
					   ,leg	
					   ,include_in_credit_exposure
                       ,is_active
				)
				VALUES( 
						@field_name
					   ,ISNULL(@field_id, @field_name)
					   ,@field_label
					   ,@field_type
					   ,@data_type
					   ,CASE WHEN @field_type = 'd' THEN @data_source_type_id ELSE NULL END
					   ,@window_id
					   ,CASE WHEN @field_type = 'w' THEN @formula_id ELSE NULL END					   
					   ,CASE 
							WHEN @data_source_type_id = @udf_data_source_id AND @field_type = 'd' THEN @sql_string 
							WHEN @field_type = 'c' THEN 'SELECT ''y'' code, ''Yes'' value UNION select ''n'',''No'''
							ELSE '' 
						END
					   ,@udf_type
					   ,CASE WHEN @field_type = 'w' THEN @formula_id 
							 WHEN @field_type = 'a' THEN @default_value_date  
						ELSE @default_value END
					   ,@udf_category
					   ,@deal_udf_type					   
					   ,@internal_field_type
					   ,@leg
					   ,@include_in_credit_exposure
                       ,@is_active
				)
				
				SET @udf_template_id = SCOPE_IDENTITY()

				EXEC spa_ErrorHandler @@ERROR,
							'Setup UDF Template',
							'spa_populate_udf',
							'Success',
							'Changes have been saved successfully.',
							@udf_template_id

				COMMIT TRAN
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK			
				
				SET @desc = dbo.FNAHandleDBError(@function_id)

				EXEC spa_ErrorHandler -1,
						'Setup UDF Template',
						'spa_populate_udf',
						'Error'
						,@desc
						, ''
			END CATCH
		END
		ELSE IF (@flag = 'u')
		BEGIN
			BEGIN TRY
				BEGIN TRAN
				UPDATE user_defined_fields_template
				SET field_name = @field_name
				   ,field_id = ISNULL(@field_id, @field_name)
				   ,field_label = @field_label
				   ,field_type = @field_type
				   ,data_type = @data_type
				   ,data_source_type_id = CASE WHEN @field_type = 'd' THEN @data_source_type_id ELSE NULL END
				   ,window_id = @window_id
				   ,formula_id = CASE WHEN @field_type = 'w' THEN @formula_id ELSE NULL END					   				   
				   ,sql_string = CASE 
						WHEN @data_source_type_id = @udf_data_source_id AND @field_type = 'd' THEN @sql_string 
						WHEN @field_type = 'c' THEN 'SELECT ''y'' code, ''Yes'' value UNION select ''n'',''No'''
						ELSE '' 
					END
				   ,udf_type = @udf_type
				   ,default_value = CASE WHEN @field_type = 'w' THEN @formula_id 
										 WHEN @field_type = 'a' THEN @default_value_date  
									ELSE @default_value END
				   ,udf_category = @udf_category
				   ,deal_udf_type = @deal_udf_type				   
				   ,internal_field_type = @internal_field_type
				   ,leg = @leg
				   ,include_in_credit_exposure = @include_in_credit_exposure
                   ,is_active = @is_active
				WHERE udf_template_id = @udf_template_id

				-- Added to update label of field in maintain_field_template_detail 
				-- after updating UDF.(To update label of field in Setup Deal Template menu.)
				UPDATE mftd
				SET field_caption = @field_label
				-- SELECT *
				FROM maintain_field_template_detail mftd
				WHERE field_id = @udf_template_id

				EXEC spa_ErrorHandler 0,
							'Setup UDF Template',
							'spa_populate_udf',
							'Success',
							'Changes have been saved successfully.',
							NULL
				COMMIT
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK			
				
				SET @desc = dbo.FNAHandleDBError(@function_id)

				EXEC spa_ErrorHandler -1,
						'Setup UDF Template',
						'spa_populate_udf',
						'Error'
						,@desc
						, NULL
			END CATCH
		END
	END

	IF @flag = 'l'
	BEGIN
		SELECT data_type
		FROM user_defined_fields_template
		WHERE udf_template_id = @udf_template_id
	END
END
GO
