IF EXISTS (SELECT * FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_state_rec_requirement_detail]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_state_rec_requirement_detail]
GO
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================
-- Author:Yogendra Raj Sunuwar
-- Create date: 2016-07-05
-- Description: This proc will be used to perform select, insert, update and delete from state_rec_requirement_detail and state_rec_requirement_detail_constraint table
-- Params:
-- @flag CHAR(1) - Operation flag 
--		flags used:	's' --> to display the data in details grid
--					'i'	--> for inserting the data in state_rec_requirement_detail and state_rec_requirement_detail_constraint table
--					'u'	--> to update the table state_rec_requirement_detail and state_rec_requirement_detail_constraint
--					'd'	--> to delete the data from state_rec_requirement_detail		
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_state_rec_requirement_detail]
@flag								CHAR(1),
@state_rec_requirement_detail_id	VARCHAR(MAX) = NULL,	
@state_rec_requirement_data_id		INT = NULL,
@form_xml							XML = NULL,
@grid_xml							XML = NULL

AS 

SET NOCOUNT ON

IF @flag = 's' 
BEGIN
	DECLARE @query VARCHAR(MAX)
	
	SET @query =  'SELECT DISTINCT(srrdt.state_rec_requirement_detail_id) [id],
				          sdv.code [tier],
				          sdv1.code [sub_tier_value_id], 
				          (
				              SELECT code
				              FROM   static_data_value
				              WHERE  srrdt.requirement_type_id = value_id
				          ) AS [requirement_type],
				          CAST(srrdt.min_target AS NUMERIC(20, 2)) [min_requirement_per],
				          CAST(srrdt.min_absolute_target AS NUMERIC(20, 2)) [min_requirement_value],
				          CAST(srrdt.max_target AS NUMERIC(20, 2)) [not_to_exceed_per],
				          CAST(srrdt.max_absolute_target AS NUMERIC(20, 2)) [not_to_exceed_value]
				   FROM   state_rec_requirement_detail srrdt
				          INNER JOIN state_rec_requirement_data srrd
				               ON  srrd.state_value_id = srrdt.state_value_id
				          LEFT JOIN static_data_value sdv
				               ON  srrdt.tier_type = sdv.value_id    
				          LEFT JOIN static_data_value sdv1
				               ON  srrdt.sub_tier_value_id = sdv1.value_id  
				   WHERE  1 = 1 AND srrdt.state_rec_requirement_data_id = ' + CAST(@state_rec_requirement_data_id AS VARCHAR)
				   
	EXEC(@query)
									
END
ELSE IF @flag = 'i' OR @flag = 'u'
BEGIN
	BEGIN TRY
		DECLARE @idoc INT
		DECLARE @idoc2 INT
		DECLARE @idoc3 INT
		
		EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
		
		SELECT * INTO #ztbl_xmlvalue FROM OPENXML(@idoc, '/Root/PSRecordset', 2) WITH (
			[state_rec_requirement_detail_id]	VARCHAR(MAX)		'@state_rec_requirement_detail_id'
			,[state_value_id]					INT		'@state_value_id'
			,[compliance_year]					INT 	'@compliance_year'
			,[tier_type]						INT 	'@tier_type'
			,[sub_tier_value_id]				INT 	'@sub_tier_value_id'
			,[min_target]						FLOAT 	'@min_target'
			,[min_absolute_target]				FLOAT 	'@min_absolute_target'
			,[max_target]						FLOAT 	'@max_target'
			,[max_absolute_target]				FLOAT	'@max_absolute_target'		
			,[requirement_type_id]				INT		'@requirement_type_id'	 
			,[state_rec_requirement_data_id]	INT		'@state_rec_requirement_data_id'
		) 
					
		--SELECT * FROM #ztbl_xmlvalue
		
		EXEC sp_xml_preparedocument @idoc2 OUTPUT, @grid_xml
		
		SELECT * INTO #ztbl_xmlvalue2 FROM   OPENXML(@idoc2, '/GridGroup/Grid/GridRow', 2) WITH (
			[state_rec_requirement_detail_constraint_id]			INT '@state_rec_requirement_detail_constraint_id'
			,[sub_tier_value_id]										INT '@sub_tier_value_id'
			,[state_rec_requirement_detail_id]						VARCHAR(MAX) '@state_rec_requirement_detail_id'
			,[state_rec_requirement_applied_constraint_detail_id]	INT '@state_rec_requirement_applied_constraint_detail_id'
		)
			
		--SELECT * FROM #ztbl_xmlvalue2 return
		
		EXEC sp_xml_preparedocument @idoc3 OUTPUT, @grid_xml
		
		SELECT * INTO #delete_xmlvalue FROM OPENXML(@idoc3, '/GridGroup/Grid/GridDelete', 2) WITH (
			[state_rec_requirement_detail_constraint_id] INT '@state_rec_requirement_detail_constraint_id'
		)
		
		--SELECT * FROM #delete_xmlvalue	
		
		BEGIN TRAN 
		MERGE dbo.state_rec_requirement_detail AS srrdt USING (
			SELECT [state_rec_requirement_detail_id]
				,[state_value_id]				
				,[compliance_year]				
				,[tier_type]
				,[sub_tier_value_id]					
				,[min_target]					
				,[min_absolute_target]			
				,[max_target]					
				,[max_absolute_target]				
				,[requirement_type_id]			
				,[state_rec_requirement_data_id]
			FROM #ztbl_xmlvalue
		) zxv ON srrdt.state_rec_requirement_detail_id = zxv.[state_rec_requirement_detail_id]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				[state_value_id]				
				,[compliance_year]				
				,[tier_type]
				,[sub_tier_value_id]					
				,[min_target]					
				,[min_absolute_target]			
				,[max_target]					
				,[max_absolute_target]			
				,[requirement_type_id]			
				,[state_rec_requirement_data_id]
			) VALUES (
				zxv.[state_value_id]				
				,zxv.[compliance_year]				
				,CASE WHEN zxv.[tier_type] = '' THEN NULL ELSE zxv.[tier_type] END
				,CASE WHEN zxv.[sub_tier_value_id] = '' THEN NULL ELSE zxv.[sub_tier_value_id] END
				,CASE WHEN zxv.[min_target] = '' THEN NULL ELSE zxv.[min_target] END 					
				,CASE WHEN zxv.[min_absolute_target] = '' THEN NULL ELSE zxv.[min_absolute_target] END 			
				,CASE WHEN zxv.[max_target] = '' THEN NULL ELSE zxv.[max_target] END 					
				,CASE WHEN zxv.[max_absolute_target] = '' THEN NULL ELSE zxv.[max_absolute_target] END			
				,zxv.[requirement_type_id]			
				,zxv.[state_rec_requirement_data_id]	
			)
		WHEN MATCHED THEN
			UPDATE 
			SET srrdt.tier_type = CASE WHEN zxv.[tier_type] = '' THEN NULL ELSE zxv.[tier_type] END,
			 srrdt.sub_tier_value_id = CASE WHEN zxv.[sub_tier_value_id] = '' THEN NULL ELSE zxv.[sub_tier_value_id] END,
			 srrdt.min_target = CASE WHEN zxv.[min_target] = '' THEN NULL ELSE zxv.[min_target] END,
			 srrdt.min_absolute_target = CASE WHEN zxv.[min_absolute_target] = '' THEN NULL ELSE zxv.[min_absolute_target] END,
			 srrdt.max_target = CASE WHEN zxv.[max_target] = '' THEN NULL ELSE zxv.[max_target] END,
			 srrdt.max_absolute_target = CASE WHEN zxv.[max_absolute_target] = '' THEN NULL ELSE zxv.[max_absolute_target] END,
			 srrdt.requirement_type_id = zxv.[requirement_type_id];
			
		DECLARE @state_rec_requirement_detail_id1 VARCHAR(MAX) 
		SET @state_rec_requirement_detail_id1 = (
			SELECT zxv1.[state_rec_requirement_detail_id] FROM #ztbl_xmlvalue AS zxv1
		)
				
		IF @state_rec_requirement_detail_id1 = ''
			SET @state_rec_requirement_detail_id1 = SCOPE_IDENTITY()
			MERGE dbo.state_rec_requirement_detail_constraint AS srrdc USING (
				SELECT [state_rec_requirement_detail_constraint_id]
					   ,sub_tier_value_id
					   ,[state_rec_requirement_detail_id]					
					   ,[state_rec_requirement_applied_constraint_detail_id]
				FROM #ztbl_xmlvalue2
			) zxv2 ON srrdc.state_rec_requirement_detail_constraint_id = zxv2.[state_rec_requirement_detail_constraint_id]
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT (
					sub_tier_value_id
					,[state_rec_requirement_detail_id]					
					,[state_rec_requirement_applied_constraint_detail_id]
				) VALUES (
					NULLIF(zxv2.sub_tier_value_id,'')
					,zxv2.[state_rec_requirement_detail_id]					
					,zxv2.[state_rec_requirement_applied_constraint_detail_id]
				)
			WHEN MATCHED THEN 
				UPDATE 
				SET srrdc.[state_rec_requirement_applied_constraint_detail_id] = zxv2.[state_rec_requirement_applied_constraint_detail_id],
					srrdc.sub_tier_value_id = NULLIF(zxv2.sub_tier_value_id,'');
					
				
		DELETE FROM dbo.state_rec_requirement_detail_constraint WHERE state_rec_requirement_detail_constraint_id IN (
			SELECT state_rec_requirement_detail_constraint_id FROM #delete_xmlvalue
		)
		
		EXEC spa_ErrorHandler 0,
						 'State Properties Requirement Data',
						 'spa_state_rec_requirement_detail',
						 'Success',
						 'Changes have been saved successfully.',
						 '' 
		    
		COMMIT
		
	END TRY
	BEGIN CATCH
		/* 
			SELECT
				ERROR_NUMBER() AS ErrorNumber,
				ERROR_SEVERITY() AS ErrorSeverity,
				ERROR_STATE() AS ErrorState,
				ERROR_PROCEDURE() AS ErrorProcedure,
				ERROR_LINE() AS ErrorLine,
				ERROR_MESSAGE() AS ErrorMessage
		*/
		IF @@TRANCOUNT > 0
					ROLLBACK
					
		EXEC spa_ErrorHandler -1,
					 'State Properties Requirement Data',
					 'spa_state_rec_requirement_detail',
					 'DB Error',
					 'Error while saving data.',
					 'Failed Inserting Record'
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN  
	EXEC('IF EXISTS(SELECT 1 FROM state_rec_requirement_detail_constraint WHERE state_rec_requirement_detail_id IN (' + @state_rec_requirement_detail_id + ') OR state_rec_requirement_applied_constraint_detail_id IN (' + @state_rec_requirement_detail_id + '))
	BEGIN
		EXEC spa_ErrorHandler -1
				 ,''state_rec_requirement_detail''
				 ,''spa_state_rec_requirement_detail''
				 ,''DB Error''
				 ,''Please delete the data from <b>Requirement Detail Grid</b> first.''
				 ,''''
			RETURN
	END
	ELSE
	BEGIN
		DELETE FROM state_rec_requirement_detail 
					 WHERE state_rec_requirement_detail_id IN (' + @state_rec_requirement_detail_id + ') 
			
		
		EXEC spa_ErrorHandler 0
			 , ''state_rec_requirement_detail''
			 , ''spa_state_rec_requirement_detail''
			 , ''Success''
			 , ''Data deleted successfully''
			 , ''''	
	END')
END
ELSE IF @flag = 'x'
BEGIN
	SELECT sdv.value_id, sdv.code AS Tier  FROM static_data_value sdv WHERE sdv.[type_id] = 15000		
END
ELSE IF @flag = 'y'
BEGIN
	SET @query =  'SELECT DISTINCT(srrdt.state_rec_requirement_detail_id) [ID], sdv.code [Tier]
							FROM   state_rec_requirement_detail srrdt
							INNER JOIN state_rec_requirement_data srrd ON  srrd.state_value_id = srrdt.state_value_id
							INNER JOIN static_data_value sdv ON  srrdt.tier_type = sdv.value_id
							WHERE 1 = 1'	 
	EXEC (@query) 
END
ELSE IF @flag = 'o'
BEGIN
	SELECT state_rec_requirement_detail_constraint_id, state_rec_requirement_applied_constraint_detail_id,sub_tier_value_id FROM state_rec_requirement_detail_constraint 
		WHERE state_rec_requirement_detail_id = @state_rec_requirement_detail_id 
END