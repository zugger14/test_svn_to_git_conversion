IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_counterparty_history]') AND type in (N'P', N'PC'))
DROP PROCEDURE spa_counterparty_history
 GO 

SET ANSI_NULLS ON
 GO
  
SET QUOTED_IDENTIFIER ON
 GO 

-- =============================================================================================================================
-- Author: bmanandhar@pioneersolutionsglobal.com
-- Create date: 2016-09-29
-- Description: Generic SP to insert/update values in the table defined in the application_ui_template_definition
 
-- Params:
-- @flag CHAR(1)        -  flag 
--						- 'i' - Insert Data 
--						- 's' -  Select
--						- 'u' - update Data
-- grid_id in the xml is the source_counterparty_history_id                     
-- @xml  VARCHAR(MAX) - @xml string of the Data to be inserted/updated
--  @source_counterparty_id is source_counterparty_id of the tab
-- ===================================================================

CREATE PROC spa_counterparty_history
	@flag CHAR(1),
	@xml	VARCHAR(MAX) = NULL,
	@source_counterparty_id INT = NUll,
	@counterparty_histoty_id INT = NULL
AS 

SET NOCOUNT ON
/*

DECLARE @flag CHAR(1),	
	@xml VARCHAR(MAX) = NULL,
	@counterparty_id INT = NULL

	select @flag='u',
	@xml='<Root><GridSave counterparty_history_id = "" effective_date="Thu Oct 06 2016 09:52:00 GMT+0545 (Nepal Standard Time)" counterparty_name="daa" counterparty_id="4706" 
			counterparty_desc="asdfsd" parent_counterparty="" ></GridSave></Root>'

--*/
DECLARE @idoc INT,
		@function_id VARCHAR(100),
		@desc VARCHAR(MAX),
		@check_update_id INT

IF @flag='s'
	SELECT source_counterparty_history_id,
		   effective_date,		  
		   source_counterparty_id,
		   [type],
		   counterparty_name,		   
		   counterparty_id, 		   
		   counterparty_desc,			      
		   parent_counterparty,
		   counterparty		   
	FROM   source_counterparty_history sch 		
	WHERE  source_counterparty_id = @source_counterparty_Id
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			DELETE FROM source_counterparty_history WHERE source_counterparty_id IN (
				SELECT NULLIF(source_counterparty_id, '')
				FROM   OPENXML (@idoc, '/Root/GridSave', 2)
				WITH (	
					source_counterparty_id VARCHAR(100) '@source_counterparty_id'
				)
			)
		
			INSERT INTO source_counterparty_history(						
						source_counterparty_id,
						counterparty_name,					
						counterparty_id,
						effective_date,
						counterparty_desc,			      
						parent_counterparty,
						[type],
						counterparty		   	
			)
			SELECT 
					NULLIF(source_counterparty_id, '')
					,NULLIF(counterparty_name, '')								
					,NULLIF(counterparty_id, '')
					,NULLIF(effective_date, '')								
					,NULLIF(counterparty_desc, '')
					,NULLIF(parent_counterparty, '')
					,NULLIF([type], '')
					,NULLIF(counterparty, '')					
			FROM   OPENXML (@idoc, '/Root/GridSave', 2)
			WITH (					
					source_counterparty_id VARCHAR(100) '@source_counterparty_id',
					counterparty_name NVARCHAR(1000) '@counterparty_name',
					counterparty_id VARCHAR(100) '@counterparty_id',
					effective_date VARCHAR(50) '@effective_date',
					counterparty_desc VARCHAR(220) '@counterparty_desc',					
					parent_counterparty VARCHAR(50) '@parent_counterparty',		
					[type] VARCHAR(50) '@type',
					counterparty VARCHAR(50) '@counterparty'										
			)


			EXEC spa_ErrorHandler @@ERROR,
					'Counterparty History',
					'spa_counterparty_history',
					'Success',
					'Changes have been saved successfully.',
					@source_counterparty_id
		COMMIT
	END TRY
	BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK			
			
			SET @desc = dbo.FNAHandleDBError(@function_id)

			EXEC spa_ErrorHandler -1,
					'Counterparty History',
					'spa_counterparty_history',
					'Error'
					,@desc
					, NULL
		END CATCH	
END	
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY		
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml	
		
		DELETE sch FROM source_counterparty_history sch
			INNER JOIN (			
				SELECT NULLIF(grid_id, '') grid_id
				FROM   OPENXML (@idoc, '/Root/GridDelete', 2)
				WITH (	
					grid_id VARCHAR(100) '@grid_id'
				)
			) sub
				ON sch.source_counterparty_history_id = sub.grid_id
			
			EXEC spa_ErrorHandler @@ERROR,
					'Counterparty History Delete',
					'spa_counterparty_history',
					'Success',
					'Changes have been saved successfully.',
					@source_counterparty_id

		--COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK			
		
		SET @desc = dbo.FNAHandleDBError(@function_id)

		EXEC spa_ErrorHandler -1,
				'Counterparty History',
				'spa_counterparty_history',
				'Error'
				,@desc
				, NULL
	END CATCH	
END






