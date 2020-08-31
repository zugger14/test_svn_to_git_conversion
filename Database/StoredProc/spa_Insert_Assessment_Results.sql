IF OBJECT_ID(N'spa_Insert_Assessment_Results', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Insert_Assessment_Results]
GO 

--===========================================================================================
--This Procedure inserts an assessment value by the assessment module that calculates values
--Input Parameters:
--@hedge_relationship_type_id - hedge relationship type id
--@as_of_date - as of date
--@result_value - value to overide with


--===========================================================================================

--  drop proc spa_Insert_Assessment_Results

CREATE PROCEDURE [dbo].[spa_Insert_Assessment_Results] 
	@hedge_relationship_type_id INT,
	@as_of_date DATETIME,
	@initial_ongoing CHAR,
	@result_value FLOAT,
	@additional_result_value FLOAT,
	@additional_result_value2 FLOAT,
	@link_id INT,
	@calc_level INT,
	@eff_test_approach_value_id INT
	
AS

DECLARE @errorCode Int

INSERT INTO fas_eff_ass_test_results
VALUES
  (
    @hedge_relationship_type_id,
    @as_of_date,
    @initial_ongoing,
    @result_value,
    @additional_result_value,
    'n',
    @link_id,
    @calc_level,
    @eff_test_approach_value_id,
    @additional_result_value2,
    NULL,
    NULL,
    NULL,
    NULL
  )

	SET @errorCode = @@ERROR
	IF @errorCode <> 0
	    SELECT -1 AS eff_test_result_id
	ELSE
	    SELECT SCOPE_IDENTITY() AS eff_test_result_id