IF OBJECT_ID(
       N'[dbo].[spa_maintain_rec_assignment_priority_order]',
       N'P'
   ) IS NOT NULL
    DROP PROCEDURE [dbo].[spa_maintain_rec_assignment_priority_order]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_maintain_rec_assignment_priority_order]
	@flag CHAR(1),
	@order_id INT = NULL,
	@priority_id INT = NULL,
	@detail_id INT = NULL,
	@priority_value_id INT = NULL,
	@order_number INT = NULL,
	@cost_order_type INT = NULL,
	@vintage_order_type INT = NULL,
	@form_xml VARCHAR(MAX) = NULL,
	@grid_xml VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON

DECLARE @idoc INT,
	@priority_type INT 

	IF (@flag = 's')
	BEGIN
	    DECLARE @sql VARCHAR(MAX)
	    
	    SET @sql = 'SELECT ' +
	        CASE 
	             WHEN @priority_id = 20900 THEN 
	                  'rapo.rec_assignment_priority_order_id [Priority Order ID], x.NAME [Product Type], rapo.order_number [Order]'
	             WHEN @priority_id = 10009 THEN 
	                  'rapo.rec_assignment_priority_order_id [Priority Order ID], sdv.code [Technology Type], rapo.order_number [Order]'
	             WHEN @priority_id = 13000 THEN 
	                  'rapo.rec_assignment_priority_order_id [Priority Order ID], sdv.code [Technology Sub Type], rapo.order_number [Order]'
	             WHEN @priority_id = 15000 THEN 
	                  'rapo.rec_assignment_priority_order_id [Priority Order ID], sdv.code [Tier Type], rapo.order_number [Order]'
	             WHEN @priority_id = 21000 THEN 
	                  'rapo.rec_assignment_priority_order_id [Priority Order ID], sdt.[type_name] [Type], sdv.code [Order]'
	             ELSE 
	                  'rapo.rec_assignment_priority_order_id [Priority Order ID], sdt.[type_name] [Type], sdv.code [Order]'
	        END +
	        ' FROM rec_assignment_priority_order rapo ' 
	        IF (@priority_id = 20900)
	        BEGIN
	        	SET @sql = @sql + 'INNER JOIN (
									SELECT source_curve_def_id AS [CurveId],
										   curve_name AS [NAME],
										   curve_des AS [DESCRIPTION]
									FROM   source_price_curve_def
								WHERE  source_price_curve_def.obligation IS NOT NULL
										   AND source_price_curve_def.obligation = ''y''
								) AS x
							ON  rapo.priority_type_value_id = x.CurveId'
	        END	
	        ELSE
	        BEGIN
	        	SET @sql = @sql + 
	        
					'INNER JOIN static_data_value sdv ON sdv.value_id = ' +
	        CASE 
	             WHEN @priority_id = 21000 THEN 'rapo.cost_order_type'
	             WHEN @priority_id = 21100 THEN 'rapo.vintage_order_type'
	             ELSE 'rapo.priority_type_value_id'
	        END +
	        ' INNER JOIN static_data_type sdt ON sdv.[type_id] = sdt.[type_id] '
	        
	        END 
		    
		   SET @sql = @sql +  ' WHERE  rapo.rec_assignment_priority_detail_id = ' + CAST(@detail_id AS VARCHAR(100))
	    
	    IF (@priority_id <> 21000 OR @priority_id <> 21100)
	    BEGIN
	    	set @sql = @sql + ' ORDER BY rapo.order_number'
	    END
	    
	    EXEC spa_print @sql
	    EXEC (@sql)
	END 
	
	IF (@flag = 'a')
	BEGIN
	    SELECT rapo.rec_assignment_priority_detail_id,
	           rapo.order_number,
	           rapo.cost_order_type,
	           rapo.vintage_order_type,
	           rapo.priority_type_value_id,
	           rapd.priority_type
	    FROM   rec_assignment_priority_order rapo
	           INNER JOIN rec_assignment_priority_detail rapd
	                ON  rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
	    WHERE  rapo.rec_assignment_priority_order_id = @order_id
	END
	
	IF (@flag = 'i')

	BEGIN 
		BEGIN TRY
		DECLARE @group_name AS VARCHAR(100)
		DECLARE @group_id INT
		DECLARE @msg AS VARCHAR(100)
		
			EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
			IF OBJECT_ID('tempdb..#temp_rec_assignment_priority_order') IS NOT NULL
				DROP TABLE #temp_rec_assignment_priority_order
			SELECT
				rec_assignment_priority_order_id,
				priority_type_value_id,
				rec_assignment_priority_detail_id			
				INTO #temp_rec_assignment_priority_order
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				rec_assignment_priority_order_id INT,
				priority_type_value_id INT,
				rec_assignment_priority_detail_id INT
			)
			
			IF EXISTS (SELECT 1 FROM rec_assignment_priority_order ng INNER JOIN #temp_rec_assignment_priority_order tsn
						 ON ng.priority_type_value_id = tsn.priority_type_value_id AND ng.rec_assignment_priority_detail_id = tsn.rec_assignment_priority_detail_id)
			BEGIN 
				SET @group_id = (SELECT priority_type FROM #temp_rec_assignment_priority_order trapo
									INNER JOIN rec_assignment_priority_detail rapd	
										ON rapd.rec_assignment_priority_detail_id = trapo.rec_assignment_priority_detail_id) 
				IF (@group_id = 20900)
				BEGIN
					SELECT @group_name = spcd.curve_id
					FROM   source_price_curve_def spcd
				       INNER JOIN #temp_rec_assignment_priority_order tsn 
						ON spcd.source_curve_def_id = tsn.priority_type_value_id
				END
				ELSE
				BEGIN
					SELECT @group_name = sdv.code
					FROM   rec_assignment_priority_order ng
				       INNER JOIN #temp_rec_assignment_priority_order tsn
				            ON  ng.priority_type_value_id = tsn.priority_type_value_id
				            AND ng.rec_assignment_priority_detail_id = tsn.rec_assignment_priority_detail_id
				       LEFT JOIN static_data_value sdv
				            ON  sdv.value_id = tsn.priority_type_value_id 
				END
				
				
				SET @msg = 'Duplicate data (' + @group_name + 
				    ') in Priority Type.'
						 
				EXEC spa_ErrorHandler 1,
					 'Maintain Rec Assignment Priority',
					 'rec_assignment_priority_order',
					 'DB Error',
					 @msg,
					 ''	        
				RETURN
			END		
			
			SELECT @order_number = ISNULL(MAX(rec.order_number),0) FROM rec_assignment_priority_order rec
				INNER JOIN #temp_rec_assignment_priority_order recd ON recd.rec_assignment_priority_detail_id = rec.rec_assignment_priority_detail_id				
			
			INSERT INTO rec_assignment_priority_order
				(priority_type_value_id,
					rec_assignment_priority_detail_id,
					order_number)
				SELECT
					priority_type_value_id,
					rec_assignment_priority_detail_id,
					@order_number + 1
				FROM #temp_rec_assignment_priority_order
				
			DECLARE @recommend_rec_assignment_priority_order_id VARCHAR(20)
			SET @recommend_rec_assignment_priority_order_id = SCOPE_IDENTITY()
						
			DECLARE @recommend_rec_assignment_priority_detail_id VARCHAR(20)
			DECLARE @recommend_rec_assignment_priority_group_id VARCHAR(20)
			SELECT @recommend_rec_assignment_priority_detail_id = rec_assignment_priority_detail_id FROM #temp_rec_assignment_priority_order
			SELECT @recommend_rec_assignment_priority_group_id = MAX(rec_assignment_priority_group_id) FROM rec_assignment_priority_detail WHERE rec_assignment_priority_detail_id = @recommend_rec_assignment_priority_detail_id 
	
			SET @recommend_rec_assignment_priority_order_id = @recommend_rec_assignment_priority_group_id + '_' + @recommend_rec_assignment_priority_detail_id + '_' + @recommend_rec_assignment_priority_order_id	
					
			 EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_order',
	             'Success',
	             'Data inserted sucessfully.',
	             @recommend_rec_assignment_priority_order_id
				
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_order',
	             'DB Error',
	             'Error on inserting data.',
	             ''
		END CATCH
	END 
	
	IF (@flag = 'u')

	BEGIN 
		BEGIN TRY		
			EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
			IF OBJECT_ID('tempdb..#temp_rec_assignment_priority_order2') IS NOT NULL
				DROP TABLE #temp_rec_assignment_priority_order2
			SELECT
				rec_assignment_priority_order_id,
				priority_type_value_id,
				rec_assignment_priority_detail_id			
				INTO #temp_rec_assignment_priority_order2
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				rec_assignment_priority_order_id INT,
				priority_type_value_id INT,
				rec_assignment_priority_detail_id INT
			)
			
			IF EXISTS (SELECT 1 FROM rec_assignment_priority_order ng INNER JOIN #temp_rec_assignment_priority_order2 tsn
						 ON ng.priority_type_value_id = tsn.priority_type_value_id 
							AND ng.rec_assignment_priority_detail_id = tsn.rec_assignment_priority_detail_id
							AND ng.rec_assignment_priority_order_id <> tsn.rec_assignment_priority_order_id)
			BEGIN
				SELECT @group_name = sdv.code
				FROM   rec_assignment_priority_order ng
				       INNER JOIN #temp_rec_assignment_priority_order tsn
				            ON  ng.priority_type_value_id = tsn.priority_type_value_id
				            AND ng.rec_assignment_priority_detail_id = tsn.rec_assignment_priority_detail_id
				       LEFT JOIN static_data_value sdv
				            ON  sdv.value_id = tsn.priority_type_value_id
				
				SET @msg = 'Duplicate data (' + @group_name + 
				    ') in Priority Type.'
				    
				EXEC spa_ErrorHandler 1,
					 'Maintain Rec Assignment Priority',
					 'rec_assignment_priority_order',
					 'DB Error',
					 @msg,
					 ''	        
				RETURN
			END	
			
			UPDATE rapd
			SET rapd.priority_type_value_id = trapd.priority_type_value_id
				, rapd.rec_assignment_priority_detail_id = trapd.rec_assignment_priority_detail_id
			FROM rec_assignment_priority_order rapd
			INNER JOIN #temp_rec_assignment_priority_order2 trapd ON trapd.rec_assignment_priority_order_id = rapd.rec_assignment_priority_order_id			
					
			 EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_order',
	             'Success',
	             'Data update sucessfully.',
	             ''				
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_order',
	             'DB Error',
	             'Error on updating data.',
	             ''
		END CATCH
	END 
	
	--IF (@flag = 'u')
	--BEGIN	    
	--    IF EXISTS (
	--           SELECT 1
	--           FROM   rec_assignment_priority_order
	--           WHERE  rec_assignment_priority_detail_id = @detail_id
	--                  AND priority_type_value_id = @priority_value_id	  
	--                  AND rec_assignment_priority_order_id <> @order_id              
	--    )
	    
	--    BEGIN
	--        EXEC spa_ErrorHandler 1,
	--             'Maintain Rec Assignment Priority',
	--             'rec_assignment_priority_order',
	--             'DB Error',
	--             'Priority Type already exists.',
	--             ''	        
	--        RETURN
	--    END
	    
	--    IF EXISTS (
	--           SELECT 1
	--           FROM   rec_assignment_priority_order
	--           WHERE rec_assignment_priority_order_id = @order_id  
	--                  AND order_number <> (@order_number+1)              
	--    )/*For checking if the order number is same for update*/
	    
	--    BEGIN
	--		IF EXISTS (
	--			   SELECT 1
	--			   FROM   rec_assignment_priority_order
	--			   WHERE  rec_assignment_priority_detail_id = @detail_id
	--					  AND rec_assignment_priority_order_id = @order_id  
	--					  AND order_number < @order_number
	--		)/*if updated to a larger order*/
	    
	--		BEGIN
	--			DECLARE @order_number_curr INT 
	--			SELECT @order_number_curr = order_number FROM rec_assignment_priority_order WHERE rec_assignment_priority_order_id = @order_id
							   
	--			UPDATE  rec_assignment_priority_order 
	--			set order_number = order_number - 1
	--			WHERE rec_assignment_priority_detail_id = @detail_id
	--			AND order_number > @order_number_curr AND order_number <= @order_number		
	--		END
	--		ELSE /*if updated to a smaller order*/
	--		BEGIN
	--			DECLARE @order_number_curr3 INT 
	--			SELECT @order_number_curr3 = order_number FROM rec_assignment_priority_order WHERE rec_assignment_priority_order_id = @order_id
								
 --   			UPDATE  rec_assignment_priority_order 
	--			set order_number = order_number + 1
	--			WHERE order_number < @order_number_curr3 and order_number > @order_number
	--			AND rec_assignment_priority_detail_id = @detail_id
				
	--			SET @order_number = @order_number + 1
	--		END
			
	--		/*Actual update query*/
	--		UPDATE rec_assignment_priority_order
	--		SET    priority_type_value_id = @priority_value_id,
	--			   order_number = @order_number,
	--			   cost_order_type = @cost_order_type,
	--			   vintage_order_type = @vintage_order_type
	--		WHERE  rec_assignment_priority_order_id = @order_id
			
	--    END
	--    ELSE
	--    BEGIN
	--    	UPDATE rec_assignment_priority_order
	--		SET    priority_type_value_id = @priority_value_id,
	--			   order_number = @order_number + 1,
	--			   cost_order_type = @cost_order_type,
	--			   vintage_order_type = @vintage_order_type
	--		WHERE  rec_assignment_priority_order_id = @order_id
	--    END
	    
	--     IF @@ERROR <> 0
	--	BEGIN
	--		EXEC spa_ErrorHandler @@ERROR,
	--			 'Maintain Rec Assignment Priority',
	--             'rec_assignment_priority_order',
	--             'DB Error',
	--             'Error on updating data.',
	--             ''	     
	--	END
	--	ELSE
	--    BEGIN
	--        EXEC spa_ErrorHandler 0,
	--             'Maintain Rec Assignment Priority',
	--             'rec_assignment_priority_order',
	--             'Success',
	--             'Data updated sucessfully.',
	--             ''	        
	--        RETURN
	--    END
	--END
	
	IF (@flag = 'd')
	BEGIN		
		DECLARE @order_number_curr2 INT 
		SELECT @order_number_curr2 = order_number FROM rec_assignment_priority_order WHERE rec_assignment_priority_order_id = @order_id
		
		UPDATE rec_assignment_priority_order 
			set order_number = order_number - 1
			WHERE rec_assignment_priority_detail_id = @detail_id
			AND order_number > @order_number_curr2
		
	    DELETE 
	    FROM   rec_assignment_priority_order
	    WHERE  rec_assignment_priority_order_id = @order_id	    
	    
	    IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_order',
	             'DB Error',
	             'Error on deleting data.',
	             ''	     
		END
		ELSE
	    BEGIN
	        EXEC spa_ErrorHandler 0,
	             'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_order',
	             'Success',
	             'Data deleted sucessfully.',
	             ''	        
	        RETURN
	    END
	END
	IF (@flag = 'n')
	BEGIN	
		
		IF (@priority_id = 20900)
		BEGIN
		SET @sql='  SELECT 
					rapo.order_number,
						   x.[NAME]
					FROM   rec_assignment_priority_order rapo
						   INNER JOIN (
									SELECT source_curve_def_id AS [CurveId],
										   curve_name AS [NAME],
										   curve_des AS [DESCRIPTION]
									FROM   source_price_curve_def
									WHERE  source_price_curve_def.obligation IS NOT NULL
										   AND source_price_curve_def.obligation = ''y''
								) x
								ON  x.CurveId = rapo.priority_type_value_id
					WHERE rapo.rec_assignment_priority_detail_id = ' + cast(@detail_id AS VARCHAR(100)) 
			IF (@order_id IS NOT NULL)
			BEGIN
				set @sql = @sql + ' AND rapo.rec_assignment_priority_order_id NOT IN (' + cast(@order_id AS VARCHAR(100)) + ') '
			END
								
			set @sql = @sql + ' ORDER BY rapo.order_number '
		END	
		ELSE
		BEGIN 
			set @sql = 'SELECT 
					rapo.order_number, sdv.code
			FROM   rec_assignment_priority_order rapo
				   INNER JOIN static_data_value sdv ON sdv.value_id = rapo.priority_type_value_id		
			WHERE rapo.rec_assignment_priority_detail_id = ' + cast(@detail_id AS VARCHAR(100))		   				   
			
			IF (@order_id IS NOT NULL)
			BEGIN
				set @sql = @sql + ' AND rapo.rec_assignment_priority_order_id NOT IN (' + cast(@order_id AS VARCHAR(100)) + ') '
			END
			
			set @sql = @sql + ' ORDER BY rapo.order_number '
					
		END
		
		exec spa_print @sql
		EXEC(@sql)		
	END
	
	IF (@flag = 'l')
	BEGIN
		SET @priority_type = (SELECT priority_type
					          FROM rec_assignment_priority_detail 
		                      WHERE rec_assignment_priority_detail_id = @detail_id)
		IF @priority_type = 20900
		BEGIN
			EXEC spa_source_price_curve_def_maintain @flag = 'l', @obligation = 'y'
		END
		ELSE
		BEGIN
			SELECT sdv.value_id, sdv.code 
			FROM static_data_value AS sdv 
			WHERE sdv.[type_id] = @priority_type
		END
		
	END
	
	IF (@flag = 'y')
	BEGIN 
		BEGIN TRY
			EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
			IF OBJECT_ID('tempdb..#temp_rec_assignment_priority_order3') IS NOT NULL
				DROP TABLE #temp_rec_assignment_priority_order3
			SELECT
				rec_assignment_priority_detail_id,
				rec_assignment_priority_order_id,
				trailing_order_id		
				INTO #temp_rec_assignment_priority_order3
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				rec_assignment_priority_detail_id INT,
				rec_assignment_priority_order_id INT,
				trailing_order_id INT
			)
			
			DECLARE @curr_order_id INT
			DECLARE @curr_order_number INT
			DECLARE @trailing_order_id INT
			DECLARE @trailing_order_number INT
						
			SELECT 
				@curr_order_id = rapo.rec_assignment_priority_order_id
				,@curr_order_number = rapo.order_number
				,@detail_id = rapo.rec_assignment_priority_detail_id
				,@trailing_order_id = trapo.trailing_order_id
				--,@trailing_order_number =
			FROM #temp_rec_assignment_priority_order3 trapo
				INNER JOIN rec_assignment_priority_order AS rapo 
					ON trapo.rec_assignment_priority_order_id = rapo.rec_assignment_priority_order_id
					AND trapo.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
			
			--SELECT * FROM rec_assignment_priority_order WHERE rec_assignment_priority_detail_id = @detail_id
						
			IF @trailing_order_id <> 0
			BEGIN
				SELECT 
					@trailing_order_id = trapo.trailing_order_id
					,@trailing_order_number = rapo.order_number
				FROM #temp_rec_assignment_priority_order3 trapo
					INNER JOIN rec_assignment_priority_order AS rapo 
						ON rapo.rec_assignment_priority_order_id = trapo.trailing_order_id
						AND trapo.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
				
									
				IF @trailing_order_number > @curr_order_number
				BEGIN							   
					UPDATE rec_assignment_priority_order 
					SET order_number = order_number - 1
					WHERE rec_assignment_priority_detail_id = @detail_id
					AND order_number < @trailing_order_number AND order_number > @curr_order_number	
					
				END 
				ELSE
				BEGIN
					UPDATE  rec_assignment_priority_order 
					set order_number = order_number + 1
					WHERE rec_assignment_priority_detail_id = @detail_id
					AND order_number >= @trailing_order_number AND order_number < @curr_order_number
				END
				
				UPDATE  rec_assignment_priority_order 
					set order_number = @trailing_order_number - 1
					WHERE rec_assignment_priority_detail_id = @detail_id
					AND rec_assignment_priority_order_id = @curr_order_id					
				
			END
			ELSE
			BEGIN
				SELECT 
					@trailing_order_number = MAX(rapo.order_number)
				FROM rec_assignment_priority_order rapo 
				WHERE rapo.rec_assignment_priority_detail_id = @detail_id
				
				
				UPDATE  rec_assignment_priority_order 
					set order_number = order_number - 1
					WHERE rec_assignment_priority_detail_id = @detail_id
					AND order_number > @curr_order_number
				
				UPDATE  rec_assignment_priority_order 
					set order_number = @trailing_order_number
					WHERE rec_assignment_priority_detail_id = @detail_id
					AND rec_assignment_priority_order_id = @curr_order_id
				
			END
			 EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_order',
	             'Success',
	             'Data update sucessfully.',
	             ''				
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_order',
	             'DB Error',
	             'Error on updating data.',
	             ''
		END CATCH
	END