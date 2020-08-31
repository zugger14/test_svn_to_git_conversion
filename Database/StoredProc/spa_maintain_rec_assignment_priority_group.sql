IF OBJECT_ID(N'[dbo].[spa_maintain_rec_assignment_priority_group]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_maintain_rec_assignment_priority_group]
GO
 -- spa_maintain_rec_assignment_priority_group 's'
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_maintain_rec_assignment_priority_group]
	@flag CHAR(1),
	@group_id INT = NULL,
	@group_name VARCHAR(100) = NULL,
	@description VARCHAR(1000) = NULL,
	@form_xml VARCHAR(MAX) = NULL,
	@grid_xml VARCHAR(MAX) = NULL
AS	
	
SET NOCOUNT ON

DECLARE @idoc INT
	
	IF (@flag = 's')
	BEGIN
	    SELECT rapg.rec_assignment_priority_group_name AS [group_name],
	           sdt1.type_name [detail_type],
				CASE sdt1.type_name
					  WHEN 'Product' THEN spc.curve_id   
					  ELSE   sdv2.code 
				END [detail_order_value],         
	           
				CAST(rapg.rec_assignment_priority_group_id AS VARCHAR(10)) + '_0_0' AS [group_id],
				CAST(rapg.rec_assignment_priority_group_id AS VARCHAR(10)) + '_' + CAST(rapd.rec_assignment_priority_detail_id AS VARCHAR(10)) + '_0' [detail_id],
				CAST(rapg.rec_assignment_priority_group_id AS VARCHAR(10)) + '_' + CAST(rapd.rec_assignment_priority_detail_id AS VARCHAR(10)) + '_'+CAST(rapo.rec_assignment_priority_order_id AS VARCHAR(10)) [detail_order_id]
	           
	    FROM   rec_assignment_priority_group rapg
	    LEFT JOIN rec_assignment_priority_detail AS rapd ON rapd.rec_assignment_priority_group_id = rapg.rec_assignment_priority_group_id
	    LEFT JOIN static_data_type sdt1 ON sdt1.type_id = rapd.priority_type
	    LEFT JOIN rec_assignment_priority_order AS rapo ON rapo.rec_assignment_priority_detail_id = rapd.rec_assignment_priority_detail_id
	    LEFT JOIN static_data_value sdv2 ON sdv2.value_id = rapo.priority_type_value_id
	    LEFT JOIN source_price_curve_def spc ON spc.source_curve_def_id = rapo.priority_type_value_id
		ORDER BY rapg.rec_assignment_priority_group_name, rapd.order_number, rapo.order_number       
                
	END
	
	IF (@flag = 'b')
	BEGIN
		SELECT -1 AS group_id,'FIFO Vintage' AS group_name
		UNION ALL
	    SELECT rec_assignment_priority_group_id,
	           rec_assignment_priority_group_name
	    FROM   rec_assignment_priority_group
	    
	END
	
	IF (@flag = 'a')
		SELECT rec_assignment_priority_group_id AS [GROUP ID],
	           rec_assignment_priority_group_name AS [Group Name],
	           [description] AS [Description]
	    FROM   rec_assignment_priority_group WHERE rec_assignment_priority_group_id = @group_id
	
	IF (@flag = 'i')
	BEGIN 
		BEGIN TRY
		DECLARE @group_name_i AS VARCHAR(100)
		DECLARE @msg AS VARCHAR(100)
			EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
			IF OBJECT_ID('tempdb..#temp_rec_assignment_priority_group') IS NOT NULL
				DROP TABLE #temp_rec_assignment_priority_group
			SELECT
				rec_assignment_priority_group_id,
				rec_assignment_priority_group_name,
				[description]			
				INTO #temp_rec_assignment_priority_group
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				rec_assignment_priority_group_id INT,
				rec_assignment_priority_group_name VARCHAR(1000),
				[description] VARCHAR(1000)
			)
			
			IF EXISTS (SELECT 1 FROM rec_assignment_priority_group ng INNER JOIN #temp_rec_assignment_priority_group tsn
						 ON ng.rec_assignment_priority_group_name = tsn.rec_assignment_priority_group_name)
			BEGIN
				SET @group_name_i = (SELECT tsn.rec_assignment_priority_group_name FROM #temp_rec_assignment_priority_group tsn)
				
				SET @msg = 'Duplicate data (' + @group_name_i + 
				    ') in Group Name.'
				    
				EXEC spa_ErrorHandler 1,
					 'Maintain Rec Assignment Group',
					 'rec_assignment_priority_group',
					 'DB Error',
					 @msg,
					 ''	        
				RETURN
			END		
			
			INSERT INTO rec_assignment_priority_group
				(rec_assignment_priority_group_name,
					[description])
				SELECT
					rec_assignment_priority_group_name,
					ISNULL([description],rec_assignment_priority_group_name)
				FROM #temp_rec_assignment_priority_group
		
			DECLARE @recommend_rec_assignment_priority_group_id VARCHAR(20)
			SET @recommend_rec_assignment_priority_group_id = SCOPE_IDENTITY()
	
			SET @recommend_rec_assignment_priority_group_id = @recommend_rec_assignment_priority_group_id + '_0_0'
	
			 EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Group',
	             'rec_assignment_priority_group',
	             'Success',
	             'Data inserted sucessfully.',
	             @recommend_rec_assignment_priority_group_id
				
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Group',
	             'rec_assignment_priority_group',
	             'DB Error',
	             'Error on inserting data.',
	             ''
		END CATCH
	END   
	
	IF (@flag = 'u')
	BEGIN 
		BEGIN TRY
			EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
			IF OBJECT_ID('tempdb..#temp_rec_assignment_priority_group2') IS NOT NULL
				DROP TABLE #temp_rec_assignment_priority_group2
			SELECT
				rec_assignment_priority_group_id,
				rec_assignment_priority_group_name,
				[description]			
				INTO #temp_rec_assignment_priority_group2
			FROM OPENXML(@idoc, '/Root/FormXML', 1)
			WITH (
				rec_assignment_priority_group_id INT,
				rec_assignment_priority_group_name VARCHAR(1000),
				[description] VARCHAR(1000)
			)
			
			IF EXISTS (SELECT 1 FROM rec_assignment_priority_group ng INNER JOIN #temp_rec_assignment_priority_group2 tsn
						 ON ng.rec_assignment_priority_group_name = tsn.rec_assignment_priority_group_name AND ng.rec_assignment_priority_group_id <> tsn.rec_assignment_priority_group_id)
			BEGIN
				SET @group_name_i = (SELECT tsn.rec_assignment_priority_group_name FROM #temp_rec_assignment_priority_group2 tsn)
				
				SET @msg = 'Duplicate data (' + @group_name_i + 
				    ') in Group Name.'
				    
				EXEC spa_ErrorHandler 1,
					 'Maintain Rec Assignment Group',
					 'rec_assignment_priority_group',
					 'DB Error',
					 @msg,
					 ''	        
				RETURN
			END	
			
			UPDATE rapg
			SET rapg.rec_assignment_priority_group_name = trapg.rec_assignment_priority_group_name
				, rapg.[description] = ISNULL(trapg.[description], trapg.rec_assignment_priority_group_name)
			FROM rec_assignment_priority_group rapg
			INNER JOIN #temp_rec_assignment_priority_group2 trapg ON trapg.rec_assignment_priority_group_id = rapg.rec_assignment_priority_group_id	
					
			 EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Group',
	             'rec_assignment_priority_group',
	             'Success',
	             'Data updated sucessfully.',
	             ''
				
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Group',
	             'rec_assignment_priority_group',
	             'DB Error',
	             'Error on updating data.',
	             ''
		END CATCH
	END
	
	IF (@flag = 'd')
	BEGIN
		
		DELETE FROM rec_assignment_priority_detail WHERE rec_assignment_priority_group_id = @group_id
		DELETE FROM rec_assignment_priority_group WHERE rec_assignment_priority_group_id = @group_id
		
		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR,
				 'Maintain Rec Assignment Group',
	             'rec_assignment_priority_group',
	             'DB Error',
	             'Error on deleting data.',
	             ''	     
		END
		ELSE
	    BEGIN
	        EXEC spa_ErrorHandler 0,
	            'Maintain Rec Assignment Group',
	             'rec_assignment_priority_group',
	             'Success',
	             'Data deleted sucessfully.',
	             ''	        
	        RETURN
	    END
	END