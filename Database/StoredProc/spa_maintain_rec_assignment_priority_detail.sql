IF OBJECT_ID(
       N'[dbo].[spa_maintain_rec_assignment_priority_detail]',N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_maintain_rec_assignment_priority_detail]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_maintain_rec_assignment_priority_detail]
	@flag CHAR(1),
	@detail_id INT =NULL,
	@group_id INT = NULL,
	@priority_type INT = NULL,
	@order_number INT = NULL,
	@form_xml VARCHAR(MAX) = NULL,
	@grid_xml VARCHAR(MAX) = NULL
	
AS

SET NOCOUNT ON

DECLARE @idoc INT

	IF (@flag = 'x')
	BEGIN
		SELECT [TYPE_ID] AS [Type ID], [TYPE_NAME] AS [Type Name] FROM static_data_type sdt WHERE sdt.[type_id] IN (21000,21100,10009,13000)
		UNION ALL
		SELECT 20900, 'Product'
		UNION ALL
		SELECT 15000, 'Tier' 		
		--As product is the curve name from source_price_curve_def
	END
	
	IF (@flag = 'a')
	BEGIN
	    SELECT rec_assignment_priority_detail_id [Detail ID],
			   rapg.rec_assignment_priority_group_name,           
			   priority_type,
			   rapd.order_number
	    FROM   rec_assignment_priority_detail rapd
	    INNER JOIN rec_assignment_priority_group rapg ON rapd.rec_assignment_priority_group_id = rapg.rec_assignment_priority_group_id
	    WHERE rapd.rec_assignment_priority_detail_id = @detail_id
	END
	
	IF (@flag = 's')
	BEGIN
	    SELECT rapd.rec_assignment_priority_detail_id [Detail ID],
	           rapd.rec_assignment_priority_group_id [Group ID], 
			   sdt.[type_name] [Type Name],
			   sdt.[type_id] [Type ID],
			   rapd.order_number [Order]
	    FROM   rec_assignment_priority_detail rapd
	    INNER JOIN static_data_type sdt ON sdt.[type_id] = priority_type 
	    WHERE rapd.rec_assignment_priority_group_id = @group_id ORDER BY rapd.order_number
	END
	
	IF (@flag = 'i')
	BEGIN 
		BEGIN TRY
		DECLARE @group_name AS VARCHAR(100)
		DECLARE @msg AS VARCHAR(100)
		
			EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
			IF OBJECT_ID('tempdb..#temp_rec_assignment_priority_detail') IS NOT NULL
				DROP TABLE #temp_rec_assignment_priority_detail
			SELECT
				rec_assignment_priority_detail_id,
				priority_type,
				rec_assignment_priority_group_id			
				INTO #temp_rec_assignment_priority_detail
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				rec_assignment_priority_detail_id INT,
				priority_type INT,
				rec_assignment_priority_group_id INT
			)
			
			IF EXISTS (SELECT 1 FROM rec_assignment_priority_detail ng INNER JOIN #temp_rec_assignment_priority_detail tsn
						 ON ng.priority_type = tsn.priority_type AND ng.rec_assignment_priority_group_id = tsn.rec_assignment_priority_group_id)
			BEGIN
				SELECT @group_name = sdt.[type_name]
				FROM   rec_assignment_priority_detail ng
				       INNER JOIN #temp_rec_assignment_priority_detail tsn
				            ON  ng.priority_type = tsn.priority_type
				            AND ng.rec_assignment_priority_group_id = tsn.rec_assignment_priority_group_id
				            LEFT JOIN static_data_type sdt
				            ON  sdt.[type_id] = tsn.priority_type
				
				SET @msg = 'Duplicate data (' + @group_name + 
				    ') in Priority Type.'
				    
				EXEC spa_ErrorHandler 1,
					 'Maintain Rec Assignment Detail',
					 'rec_assignment_priority_detail',
					 'DB Error',
					 @msg,
					 ''	        
				RETURN
			END		
			
			SELECT @order_number = ISNULL(MAX(rec.order_number),0) FROM rec_assignment_priority_detail rec
				INNER JOIN #temp_rec_assignment_priority_detail recd ON recd.rec_assignment_priority_group_id = rec.rec_assignment_priority_group_id				
			
			INSERT INTO rec_assignment_priority_detail
				(priority_type,
					rec_assignment_priority_group_id,
					order_number)
				SELECT
					priority_type,
					rec_assignment_priority_group_id,
					@order_number + 1
				FROM #temp_rec_assignment_priority_detail
				
			DECLARE @recommend_rec_assignment_priority_detail_id VARCHAR(20)
			SET @recommend_rec_assignment_priority_detail_id = SCOPE_IDENTITY()
			
			DECLARE @recommend_rec_assignment_priority_group_id VARCHAR(20)
			SELECT @recommend_rec_assignment_priority_group_id = rec_assignment_priority_group_id FROM #temp_rec_assignment_priority_detail
	
			SET @recommend_rec_assignment_priority_detail_id = @recommend_rec_assignment_priority_group_id + '_' + @recommend_rec_assignment_priority_detail_id + '_0'	
			
			 --   DECLARE @current_id INT
			 --   SET @current_id = IDENT_CURRENT('rec_assignment_priority_detail')
			 --   UPDATE  rec_assignment_priority_detail 
				--set order_number = order_number + 1
				--WHERE  order_number >= @order_number + 1
				--AND rec_assignment_priority_detail_id NOT IN (@current_id)
				--AND rec_assignment_priority_group_id = @group_id
		
			 EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Detail',
	             'rec_assignment_priority_detail',
	             'Success',
	             'Data inserted sucessfully.',
	             @recommend_rec_assignment_priority_detail_id
				
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Detail',
	             'rec_assignment_priority_detail',
	             'DB Error',
	             'Error on inserting data.',
	             ''
		END CATCH
	END 
	
	IF (@flag = 'u')
	BEGIN 
		BEGIN TRY
			EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
			IF OBJECT_ID('tempdb..#temp_rec_assignment_priority_detail2') IS NOT NULL
				DROP TABLE #temp_rec_assignment_priority_detail2
			SELECT
				rec_assignment_priority_detail_id,
				priority_type,
				rec_assignment_priority_group_id			
				INTO #temp_rec_assignment_priority_detail2
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				rec_assignment_priority_detail_id INT,
				priority_type INT,
				rec_assignment_priority_group_id INT
			)			
			
							 
			IF EXISTS (SELECT 1 FROM rec_assignment_priority_detail ng INNER JOIN #temp_rec_assignment_priority_detail2 tsn
						 ON ng.priority_type = tsn.priority_type AND ng.rec_assignment_priority_group_id = tsn.rec_assignment_priority_group_id AND ng.rec_assignment_priority_detail_id <> tsn.rec_assignment_priority_detail_id)
			BEGIN
				SELECT @group_name = sdt.[type_name]
				FROM   rec_assignment_priority_detail ng
				       INNER JOIN #temp_rec_assignment_priority_detail2 tsn
				            ON  ng.priority_type = tsn.priority_type
				            AND ng.rec_assignment_priority_group_id = tsn.rec_assignment_priority_group_id
				            AND ng.rec_assignment_priority_detail_id <> tsn.rec_assignment_priority_detail_id
				       LEFT JOIN static_data_type sdt
				            ON  sdt.[type_id] = tsn.priority_type
				
				SET @msg = 'Duplicate data (' + @group_name + 
				    ') in Priority Type.'
				    
				EXEC spa_ErrorHandler 1,
					 'Maintain Rec Assignment Detail',
					 'rec_assignment_priority_detail',
					 'DB Error',
					 @msg,
					 ''	        
				RETURN
			END	
			
			IF EXISTS (
				SELECT 1 FROM rec_assignment_priority_detail ng 
						INNER JOIN #temp_rec_assignment_priority_detail2 tsn
						ON ng.rec_assignment_priority_group_id = tsn.rec_assignment_priority_group_id AND ng.rec_assignment_priority_detail_id = tsn.rec_assignment_priority_detail_id
						 INNER JOIN rec_assignment_priority_order rapo ON rapo.rec_assignment_priority_detail_id = tsn.rec_assignment_priority_detail_id
				WHERE ng.priority_type <> tsn.priority_type 
			)			
			BEGIN
				EXEC spa_ErrorHandler 1,
					 'Maintain Rec Assignment Detail',
					 'rec_assignment_priority_detail',
					 'DB Error',
					 'Error on updating data. Priority order exists.',
					 ''	        
				RETURN
			END					
									
			UPDATE rapd
			SET rapd.priority_type = trapd.priority_type
				, rapd.rec_assignment_priority_group_id = trapd.rec_assignment_priority_group_id
			FROM rec_assignment_priority_detail rapd
			INNER JOIN #temp_rec_assignment_priority_detail2 trapd ON trapd.rec_assignment_priority_detail_id = rapd.rec_assignment_priority_detail_id
					
			 EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Detail',
	             'rec_assignment_priority_detail',
	             'Success',
	             'Data updated sucessfully.',
	             ''
				
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Detail',
	             'rec_assignment_priority_detail',
	             'DB Error',
	             'Error on updating data.',
	             ''
		END CATCH
	END 
	/*
	IF (@flag = 'u')
	BEGIN
		IF EXISTS (
	           SELECT 1
	           FROM   rec_assignment_priority_detail
	           WHERE  rec_assignment_priority_group_id = @group_id
	                  AND priority_type = @priority_type 
	                  AND rec_assignment_priority_detail_id <> @detail_id              
	    )
	    
	    BEGIN
	        EXEC spa_ErrorHandler 1,
	             'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_order',
	             'DB Error',
	             'Type already exists.',
	             ''	        
	        RETURN
	    END
	    
	    IF EXISTS ( 
					SELECT 1
					FROM rec_assignment_priority_detail
					WHERE rec_assignment_priority_detail_id = @detail_id  
	                AND order_number <> (@order_number + 1)              
	    )/*For checking if the order number is same for update*/
	    
	    BEGIN
			IF EXISTS (
				   SELECT 1
				   FROM   rec_assignment_priority_detail
				   WHERE  rec_assignment_priority_detail_id = @detail_id
						  AND order_number < @order_number
			)/*if updated to a larger order*/
	   
			BEGIN 
				DECLARE @order_number_curr INT 
				SELECT @order_number_curr = order_number FROM rec_assignment_priority_detail WHERE rec_assignment_priority_detail_id = @detail_id
							   
				UPDATE  rec_assignment_priority_detail 
				set order_number = order_number - 1
				WHERE rec_assignment_priority_group_id = @group_id
				AND order_number > @order_number_curr AND order_number <= @order_number		
			END
			ELSE /*if updated to a smaller order*/
			BEGIN
				DECLARE @order_number_curr3 INT 
				SELECT @order_number_curr3 = order_number FROM rec_assignment_priority_detail WHERE rec_assignment_priority_detail_id = @detail_id
								
    			UPDATE  rec_assignment_priority_detail 
				set order_number = order_number + 1
				WHERE order_number < @order_number_curr3 and order_number > @order_number
				AND rec_assignment_priority_group_id = @group_id
				
				SET @order_number = @order_number + 1
			END
			/*Actual update query*/
			UPDATE rec_assignment_priority_detail
			SET    priority_type = @priority_type,
				   order_number = @order_number
			WHERE  rec_assignment_priority_detail_id = @detail_id
		END
	    ELSE
	    BEGIN EXEC spa_print '#@'
	    	UPDATE rec_assignment_priority_detail 
			SET priority_type = @priority_type,
				order_number = @order_number + 1
			WHERE rec_assignment_priority_detail_id = @detail_id
				  
	    END
		
		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Detail',
	             'rec_assignment_priority_Detail',
	             'DB Error',
	             'Error on updating data.',
	             ''	     
		END
		ELSE
	    BEGIN
	        EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Detail',
	             'rec_assignment_priority_Detail',
	             'Success',
	             'Data updated sucessfully.',
	             ''	        
	        RETURN
	    END
	END	
	*/
	IF (@flag = 'd')
	BEGIN	
		 IF EXISTS (
	           SELECT *
	           FROM   rec_assignment_priority_order rapo
	           INNER JOIN rec_assignment_priority_detail rapd ON  rapo.rec_assignment_priority_detail_id = rapd.rec_assignment_priority_detail_id
	           WHERE rapd.rec_assignment_priority_detail_id = @detail_id 	                
	    )
	    
	    BEGIN
	        EXEC spa_ErrorHandler 1,
	             'Maintain Rec Assignment Detail',
	             'rec_assignment_priority_Detail',
	             'DB Error',
	             'Priority Order exists.',
	             ''	        
	        RETURN
	    END
	   
	    DECLARE @order_number_curr2 INT 
		SELECT @order_number_curr2 = order_number FROM rec_assignment_priority_detail WHERE rec_assignment_priority_detail_id = @detail_id
		
		UPDATE rec_assignment_priority_detail 
				set order_number = order_number - 1
				WHERE rec_assignment_priority_group_id = @group_id 
				AND order_number > @order_number_curr2 
				
		DELETE  FROM rec_assignment_priority_detail WHERE rec_assignment_priority_detail_id = @detail_id
		
		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Detail',
	             'rec_assignment_priority_Detail',
	             'DB Error',
	             'Error on deleting data.',
	             ''	     
		END
		ELSE
	    BEGIN
	        EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Detail',
	             'rec_assignment_priority_Detail',
	             'Success',
	             'Data deleted sucessfully.',
	             ''	        
	        RETURN
	    END
	END
	
	IF (@flag = 'n')
	BEGIN	
		SELECT rapd.order_number, sdt.[type_name] FROM rec_assignment_priority_detail rapd 
		INNER JOIN static_data_type sdt ON sdt.[TYPE_ID] = rapd.priority_type
		WHERE rec_assignment_priority_group_id = @group_id 
		AND rapd.order_number <> (ISNULL(@order_number , 0))
		ORDER BY rapd.order_number
			
	END
	
	IF (@flag = 'y')
	BEGIN 
		BEGIN TRY
			EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
			IF OBJECT_ID('tempdb..#temp_rec_assignment_priority_detail3') IS NOT NULL
				DROP TABLE #temp_rec_assignment_priority_detail3
			SELECT
				rec_assignment_priority_group_id,
				rec_assignment_priority_detail_id,
				trailing_detail_id		
				INTO #temp_rec_assignment_priority_detail3
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				rec_assignment_priority_group_id INT,
				rec_assignment_priority_detail_id INT,
				trailing_detail_id INT
			)
			
			DECLARE @curr_detail_id INT
			DECLARE @curr_order_number INT
			DECLARE @trailing_detail_id INT
			DECLARE @trailing_order_number INT
						
			SELECT 
				@curr_detail_id = rapo.rec_assignment_priority_detail_id
				,@curr_order_number = rapo.order_number
				,@group_id = rapo.rec_assignment_priority_group_id
				,@trailing_detail_id = trapo.trailing_detail_id
				
			FROM #temp_rec_assignment_priority_detail3 trapo
				INNER JOIN rec_assignment_priority_detail AS rapo 
					ON trapo.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
					AND trapo.rec_assignment_priority_group_id = rapo.rec_assignment_priority_group_id
									
			IF @trailing_detail_id <> 0
			BEGIN
				SELECT 
					@trailing_detail_id = trapo.trailing_detail_id
					,@trailing_order_number = rapo.order_number
				FROM #temp_rec_assignment_priority_detail3 trapo
					INNER JOIN rec_assignment_priority_detail AS rapo 
						ON rapo.rec_assignment_priority_detail_id = trapo.trailing_detail_id
						AND trapo.rec_assignment_priority_group_id = rapo.rec_assignment_priority_group_id
				
									
				IF @trailing_order_number > @curr_order_number
				BEGIN							   
					UPDATE rec_assignment_priority_detail 
					SET order_number = order_number - 1
					WHERE rec_assignment_priority_group_id = @group_id
					AND order_number < @trailing_order_number AND order_number > @curr_order_number	
					
				END 
				ELSE
				BEGIN
					UPDATE  rec_assignment_priority_detail
					set order_number = order_number + 1
					WHERE rec_assignment_priority_group_id = @group_id
					AND order_number >= @trailing_order_number AND order_number < @curr_order_number
				END
				
				UPDATE  rec_assignment_priority_detail 
					set order_number = @trailing_order_number - 1
					WHERE rec_assignment_priority_group_id = @group_id
					AND rec_assignment_priority_detail_id = @curr_detail_id					
				
			END
			ELSE
			BEGIN
				SELECT 
					@trailing_order_number = MAX(rapo.order_number)
				FROM rec_assignment_priority_detail rapo 
				WHERE rapo.rec_assignment_priority_group_id = @group_id
				
				
				UPDATE  rec_assignment_priority_detail 
					set order_number = order_number - 1
					WHERE rec_assignment_priority_group_id = @group_id
					AND order_number > @curr_order_number
				
				UPDATE  rec_assignment_priority_detail 
					set order_number = @trailing_order_number
					WHERE rec_assignment_priority_group_id = @group_id
					AND rec_assignment_priority_detail_id = @curr_detail_id
				
			END
			 EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_detail',
	             'Success',
	             'Data update sucessfully.',
	             ''				
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Priority',
	             'rec_assignment_priority_detail',
	             'DB Error',
	             'Error on updating data.',
	             ''
		END CATCH
	END