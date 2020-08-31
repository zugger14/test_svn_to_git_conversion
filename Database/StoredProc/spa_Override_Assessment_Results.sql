IF OBJECT_ID(N'spa_Override_Assessment_Results', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Override_Assessment_Results] 
GO 

--===========================================================================================
--This Procedure overrides (insert) or delete a value by the user
--Input Parameters:
--@hedge_relationship_type_id - hedge relationship type id
--@as_of_date - as of date
--@result_value - value to overide with
--@additional_result_value - additional value to overide with

--===========================================================================================

-- drop proc spa_Override_Assessment_Results
-- exec spa_Override_Assessment_Results  'i', 18, 429, '3/31/02','o', 0.96

CREATE PROCEDURE [dbo].[spa_Override_Assessment_Results] 
	@flag CHAR,
	@hedge_relationship_type_id VARCHAR(20) = NULL,
	@eff_test_result_id VARCHAR(2000) = NULL,
	@as_of_date VARCHAR(20) = NULL,
	@initial_ongoing CHAR,
	@result_value FLOAT = NULL,
	@additional_result_value FLOAT = NULL,
	@rel_id INT = NULL,
	@link_id INT = NULL,
	@calc_level INT = NULL
	
AS
SET NOCOUNT ON
DECLARE @errorCode Int

IF @flag = 'i' 
BEGIN

INSERT INTO fas_eff_ass_test_results VALUES(@rel_id, 
@as_of_date, @initial_ongoing, @result_value, @additional_result_value, 'y', @link_id, @calc_level, 
		303, NULL, dbo.FNADBUser(), GETDATE(),dbo.FNADBUser(),GETDATE())

-- INSERT INTO fas_eff_ass_test_results VALUES(@hedge_relationship_type_id, 
-- @as_of_date, @initial_ongoing, @result_value, @additional_result_value, 'y', null, null, null, null)
	Set @errorCode = @@ERROR
	If @errorCode <> 0
		Exec spa_ErrorHandler @errorCode, 'HedgeAssessemnt', 
				'spa_Override_Assessment_Results', 'DB Error', 
				'Failed to insert a value.', ''
	Else
		Exec spa_ErrorHandler 0, 'HedgeAssessemnt', 
				'spa_Override_Assessment_Results', 'Success', 
				'Assessment value has been saved.', ''
	
END
Else if @flag='d'
BEGIN
BEGIN TRANSACTION
	DELETE rs1
	FROM fas_eff_ass_test_results_profile rs1
	INNER JOIN dbo.SplitCommaSeperatedValues(@eff_test_result_id) item ON item.item = rs1.eff_test_result_id
	
	DELETE rs1
	FROM fas_eff_ass_test_results_process_detail rs1
	INNER JOIN dbo.SplitCommaSeperatedValues(@eff_test_result_id) item ON item.item = rs1.eff_test_result_id
	
	Set @errorCode = @@ERROR
	If @errorCode <> 0
		BEGIN
		Exec spa_ErrorHandler @errorCode, 'HedgeAssessemnt', 
			'spa_Override_Assessment_Results', 'DB Error', 
			'Failed to delete a value.', ''
		ROLLBACK TRANSACTION
		END	
	Else
		BEGIN
		DELETE rs1
		FROM fas_eff_ass_test_results_process_header rs1
		INNER JOIN dbo.SplitCommaSeperatedValues(@eff_test_result_id) item ON item.item = rs1.eff_test_result_id
		
		If @errorCode <> 0
			BEGIN
			Exec spa_ErrorHandler @errorCode, 'HedgeAssessemnt', 
				'spa_Override_Assessment_Results', 'DB Error', 
				'Failed to delete a value.', ''
			ROLLBACK TRANSACTION
			END
		else
			BEGIN
			DELETE rs1
			FROM fas_eff_ass_test_results rs1
			INNER JOIN dbo.SplitCommaSeperatedValues(@eff_test_result_id) item ON item.item = rs1.eff_test_result_id
			
			Set @errorCode = @@ERROR
			If @errorCode <> 0
				BEGIN
				Exec spa_ErrorHandler @errorCode, 'HedgeAssessemnt', 
					'spa_Override_Assessment_Results', 'DB Error', 
					'Failed to delete a value.', ''
				ROLLBACK TRANSACTION	
				END		
			Else
				BEGIN
				Exec spa_ErrorHandler 0, 'HedgeAssessemnt', 
					'spa_Override_Assessment_Results', 'Success', 
					'Assessment value has been deleted.', ''
				COMMIT TRANSACTION
				END
			END
	
		END
	
END








