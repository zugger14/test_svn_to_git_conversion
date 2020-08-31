
/****** Object:  StoredProcedure [dbo].[spa_ems_source_model]    Script Date: 07/06/2009 17:34:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_source_model]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_source_model]
/****** Object:  StoredProcedure [dbo].[spa_ems_source_model]    Script Date: 07/06/2009 17:34:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_ems_source_model]
@flag CHAR(1),
@ems_source_model_id INT=NULL,
@ems_source_model_name VARCHAR(100)=NULL,
@input_frequency INT=NULL,
@forecast_input_frequency INT=NULL,
@default_inventory_id INT=NULL,
@source_model_type INT=NULL,
@keyword1 VARCHAR(200)=NULL,
@keyword2 VARCHAR(200)=NULL,
@keyword3 VARCHAR(200)=NULL,
@keyword4 VARCHAR(200)=NULL,
@company_type_id INT=NULL
AS
DECLARE @temp_ems_source_model_id INT
DECLARE @temp_ems_source_model_detail_id INT
BEGIN
	DECLARE @sql VARCHAR(8000)
	DECLARE @ems_source_model_id_new INT
	IF @flag='s'	
	BEGIN
	SET @sql='
		select distinct esm.ems_source_model_id [Source ID],esm.ems_source_model_name [Emission Source]
		from 	ems_source_model esm
				 left join company_type_source_model ctsm on  esm.ems_source_model_id=ctsm.source_model_id 
		where 1=1 '
		+CASE WHEN @source_model_type IS NOT NULL THEN ' and source_model_type='+CAST(@source_model_type AS VARCHAR) ELSE '' END
		+CASE WHEN @keyword1 IS NOT NULL THEN ' and esm.keyword1 like ''%'+CAST(@keyword1 AS VARCHAR)+'%''' ELSE '' END
		+CASE WHEN @keyword2 IS NOT NULL THEN ' and esm.keyword2 like ''%'+CAST(@keyword2 AS VARCHAR)+'%''' ELSE '' END
		+CASE WHEN @keyword3 IS NOT NULL THEN ' and esm.keyword3 like ''%'+CAST(@keyword3 AS VARCHAR)+'%''' ELSE '' END
		+CASE WHEN @keyword4 IS NOT NULL THEN ' and esm.keyword4 like ''%'+CAST(@keyword4 AS VARCHAR)+'%''' ELSE '' END
		+CASE WHEN @company_type_id IS NOT NULL THEN ' and company_type_id='+CAST(@company_type_id AS VARCHAR) ELSE '' END
		+' order by ems_source_model_name'
	EXEC (@sql)
	END


	ELSE IF @flag='a'
	BEGIN
		SELECT ems_source_model_id , ems_source_model_name, input_frequency,forecast_input_frequency,default_inventory_id,source_model_type,
		keyword1,keyword2,keyword3,keyword4
		FROM 	ems_source_model WHERE ems_source_model_id=@ems_source_model_id
	END

	ELSE IF @flag='i'
	BEGIN
		IF EXISTS (SELECT 1 FROM ems_source_model WHERE ems_source_model_name = @ems_source_model_name)
		BEGIN
		Exec spa_ErrorHandler -1, 'Cannot insert duplicate source model.', 
				'spa_ems_source_model', 'DB Error', 
				'Cannot insert duplicate source model.', ''
				RETURN
		END
		INSERT INTO ems_source_model(ems_source_model_name,
			input_frequency,
			forecast_input_frequency,default_inventory_id,source_model_type,keyword1,keyword2,keyword3,keyword4)
		SELECT @ems_source_model_name,
			@input_frequency,
			@forecast_input_frequency,
			@default_inventory_id,
			@source_model_type,
			@keyword1,@keyword2,@keyword3,@keyword4
		SET @ems_source_model_id_new=SCOPE_IDENTITY()
			

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, "Ems Source Model", 
			"spa_ems_source_model", "DB Error", 
			"Error Inserting Ems Source Model Information.", ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Ems Source Model', 
			'spa_meter', 'Success', 
			'Ems Source Model Information successfully inserted.',@ems_source_model_id_new
			

	END

	ELSE IF @flag='u'
	BEGIN
		IF EXISTS (SELECT 1 FROM ems_source_model WHERE  ems_source_model_name = @ems_source_model_name AND ems_source_model_id <> @ems_source_model_id)
			BEGIN
			Exec spa_ErrorHandler -1, 'Cannot insert duplicate source model.', 
					'spa_ems_source_model', 'DB Error', 
					'Cannot insert duplicate source model.', ''
				RETURN
			END
		UPDATE	 
			ems_source_model
		SET	
			ems_source_model_name=@ems_source_model_name,
			input_frequency=@input_frequency,
			forecast_input_frequency=@forecast_input_frequency,
			default_inventory_id=@default_inventory_id,
			source_model_type=@source_model_type,
			keyword1=@keyword1,
			keyword2=@keyword2,
			keyword3=@keyword3,
			keyword4=@keyword4
			
		WHERE
			ems_source_model_id=@ems_source_model_id


			IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, "Ems Source Model", 
			"spa_ems_source_model", "DB Error", 
			"Error Updating Ems Source Model Information.", ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Ems Source Model', 
			'spa_meter', 'Success', 
			'Ems Source Model Information successfully Updated.',''

	END
	ELSE IF @flag='d'
	BEGIN
		DELETE  FROM  ems_source_model_detail 
			WHERE ems_source_model_id=@ems_source_model_id

		DELETE FROM 
			ems_source_model
		WHERE ems_source_model_id=@ems_source_model_id

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, "Ems Source Model", 
			"spa_ems_source_model", "DB Error", 
			"Error Deleting Ems Source Model Information.", ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Ems Source Model', 
			'spa_meter', 'Success', 
			'Ems Source Model Information successfully Deleted.',''
	END
	
	----------New Copy Logic
	ELSE IF @flag = 'c'
	BEGIN
		DECLARE @copy_status varchar(100)
		DECLARE @old_ems_source_model_detail_id int 
		DECLARE @old_source_formula_id int
		DECLARE @new_ems_source_formula_id int
		DECLARE @new_ems_source_model_name VARCHAR(500)
		CREATE TABLE #tmp_formula_copy_status
		(
			error_code			varchar(100) COLLATE DATABASE_DEFAULT
			, module			varchar(100) COLLATE DATABASE_DEFAULT			
			, area				varchar(100) COLLATE DATABASE_DEFAULT
			, [status]			varchar(100) COLLATE DATABASE_DEFAULT
			, [message]			varchar(1000) COLLATE DATABASE_DEFAULT
			, recommendation	varchar(1000) COLLATE DATABASE_DEFAULT
		)
		
		BEGIN TRY 
		
		IF EXISTS (SELECT 1 FROM ems_source_model WHERE  ems_source_model_name = @ems_source_model_name)
			BEGIN
			Exec spa_ErrorHandler -1, 'Cannot insert duplicate source model.', 
					'spa_ems_source_model', 'DB Error', 
					'Cannot insert duplicate source model.', ''
				RETURN
			END
			BEGIN TRAN
			SET @copy_status = 'Source Model'
			BEGIN TRY 
				BEGIN TRANSACTION 
				
				SELECT @new_ems_source_model_name=ems_source_model_name FROM ems_source_model WHERE ems_source_model_id = @ems_source_model_id
				EXEC [spa_GetUniqueCopyName] @new_ems_source_model_name,'ems_source_model_name','ems_source_model',NULL,@new_ems_source_model_name OUTPUT
				--copy souce model
				INSERT INTO ems_source_model (ems_source_model_name, input_frequency, forecast_input_frequency
						, default_inventory_id, source_model_type, keyword1, keyword2, keyword3, keyword4)					 
					SELECT @new_ems_source_model_name, input_frequency, forecast_input_frequency, default_inventory_id
						   , source_model_type, keyword1, keyword2, keyword3, keyword4
					FROM ems_source_model
					WHERE ems_source_model_id = @ems_source_model_id

				SET @temp_ems_source_model_id = SCOPE_IDENTITY()
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH 
				 IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION 
			END CATCH

			--copy input map
			SET @copy_status = 'Input map'
			INSERT INTO ems_input_map (source_model_id,input_id)
				SELECT	
					@temp_ems_source_model_id,input_id
				FROM ems_input_map
					WHERE source_model_id = @ems_source_model_id
					
			--get all source model details for original source model
			DECLARE cur_source_model CURSOR LOCAL FOR			
			SELECT  ems_source_model_detail_id
					FROM ems_source_model_detail
					WHERE ems_source_model_id = @ems_source_model_id
			
			OPEN cur_source_model;

			FETCH NEXT FROM cur_source_model INTO @old_ems_source_model_detail_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				--copying Source Model Detail				
				SET @copy_status = 'Source Model Detail'
				INSERT INTO ems_source_model_detail (ems_source_model_id,curve_id,uom_id,estimation_type_value_id,
													rating_value_id,formula_reporting_period,formula_forcast_reporting,
													use_as_reporting_period,program_scope_value_id,credit_env_product,
													credit_product_uom_id)
					SELECT  @temp_ems_source_model_id,curve_id,uom_id,estimation_type_value_id,rating_value_id,formula_reporting_period,
							formula_forcast_reporting,use_as_reporting_period,program_scope_value_id,credit_env_product,credit_product_uom_id
					FROM ems_source_model_detail
					WHERE ems_source_model_detail_id = @old_ems_source_model_detail_id
				
				SET @temp_ems_source_model_detail_id = SCOPE_IDENTITY()
				
				--get all source formula for original source model detail
				DECLARE cur_source_formula CURSOR LOCAL FOR	
				SELECT 	
				ems_source_formula_id
				FROM ems_source_formula esf 
				WHERE ems_source_model_detail_id = @old_ems_source_model_detail_id	
				
				OPEN cur_source_formula;

				FETCH NEXT FROM cur_source_formula INTO @old_source_formula_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @copy_status = 'Nested Formula'	
					
					EXEC spa_copy_source_formula_core @old_source_formula_id, @temp_ems_source_model_detail_id, @temp_ems_source_model_id, @new_ems_source_formula_id OUTPUT

					FETCH NEXT FROM cur_source_formula INTO @old_source_formula_id
				END
				
				CLOSE cur_source_formula;
				DEALLOCATE cur_source_formula;
				
				FETCH NEXT FROM cur_source_model INTO @old_ems_source_model_detail_id
			END;

			CLOSE cur_source_model;
			DEALLOCATE cur_source_model;
			
			EXEC spa_ErrorHandler 0, 'ems_source_model', 
							 'spa_ems_source_model', 'Success', 
							 'spa_ems_source_model successfully Copied.',@temp_ems_source_model_id
			COMMIT TRANSACTION 
		
		END TRY 
		BEGIN CATCH	
			DECLARE @error_number INT 
			DECLARE @error_msg VARCHAR(50) 
			
			SET @error_msg = 'Error Copying ' + @copy_status + '.'
			SET @error_number = ERROR_NUMBER() 
			
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION 
			
			IF CURSOR_STATUS('local', 'cur_source_formula') >= 0 
			BEGIN
				CLOSE cur_source_formula
				DEALLOCATE cur_source_formula;
			END	
			
			IF CURSOR_STATUS('local', 'cur_source_model') >= 0 
			BEGIN
				CLOSE cur_source_model
				DEALLOCATE cur_source_model;
			END	
			EXEC spa_ErrorHandler @error_number, @copy_status,
									@copy_status, 'DB Error',
									@error_msg, ''
									
		END CATCH
	END 
END
