IF OBJECT_ID(N'FNATestAssessment', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNATestAssessment]
GO 

CREATE FUNCTION [dbo].[FNATestAssessment]
(
	@on_eff_test_approach_value_id      INT,
	@use_assessment_values              FLOAT,
	@test_range_from                    FLOAT,
	@test_range_to                      FLOAT,
	@use_additional_assessment_values   FLOAT,
	@additional_test_range_from         FLOAT,
	@additional_test_range_to           FLOAT,
	@use_additional_assessment_values2  FLOAT,
	@additional_test_range_from2        FLOAT,
	@additional_test_range_to2          FLOAT
)
RETURNS INT
AS
BEGIN
	Declare @FNATestAssessment As INT
	Declare @round_to INT
	set @round_to = 2
	
	SET @use_assessment_values = round(@use_assessment_values,  @round_to)

	Set @FNATestAssessment = 
		CASE WHEN(@on_eff_test_approach_value_id = 304) THEN 1
		     WHEN(@on_eff_test_approach_value_id = 317) THEN cast(@use_assessment_values as INT)
		     WHEN(@on_eff_test_approach_value_id IN (315, 316)) THEN
			CASE WHEN((@use_assessment_values BETWEEN @test_range_from AND @test_range_to) 
				AND (@use_additional_assessment_values BETWEEN @additional_test_range_from AND @additional_test_range_to)) THEN
				--assessment  test passed for r2/cor and slope
				1
			ELSE
				0			
			END
		     WHEN (@on_eff_test_approach_value_id IN (300, 301, 302, 303) ) THEN
			CASE WHEN(@use_assessment_values BETWEEN @test_range_from AND @test_range_to) THEN
				1
			ELSE
				0
			END
		     WHEN (@on_eff_test_approach_value_id = 305) THEN -- t-test
			CASE WHEN(@use_assessment_values > @test_range_from OR 
				@use_assessment_values < (-1*@test_range_from)) THEN
				1
			ELSE
				0
			END
		     WHEN (@on_eff_test_approach_value_id = 306) THEN -- f-test
			CASE WHEN(@use_assessment_values > @test_range_from) THEN
				1
			ELSE
				0
			END
		     WHEN (@on_eff_test_approach_value_id IN(307, 309)) THEN -- T-test
			CASE WHEN(@use_assessment_values BETWEEN @test_range_from AND @test_range_to AND
					@use_additional_assessment_values > @additional_test_range_from OR 
					@use_additional_assessment_values < (-1*@additional_test_range_from)) THEN
				1
			ELSE
				0
			END
		     WHEN (@on_eff_test_approach_value_id IN(308, 310)) THEN -- F-test
			CASE WHEN(@use_assessment_values BETWEEN @test_range_from AND @test_range_to AND
					@use_additional_assessment_values > @additional_test_range_from) THEN
				1
			ELSE
				0
			END		
		     WHEN (@on_eff_test_approach_value_id IN(311, 313)) THEN -- T-test
			CASE WHEN(@use_assessment_values BETWEEN @test_range_from AND @test_range_to AND
					(@use_additional_assessment_values > @additional_test_range_from OR 
					@use_additional_assessment_values < (-1*@additional_test_range_from)) AND
					@use_additional_assessment_values2 BETWEEN @additional_test_range_from2 AND @additional_test_range_to2) THEN
				1
			ELSE
				0
			END
		     WHEN (@on_eff_test_approach_value_id IN(312, 314)) THEN -- F-test
			CASE WHEN(@use_assessment_values BETWEEN @test_range_from AND @test_range_to AND
					@use_additional_assessment_values > @additional_test_range_from AND
					@use_additional_assessment_values2 BETWEEN @additional_test_range_from2 AND @additional_test_range_to2) THEN
				1
			ELSE
				0
			END		
		ELSE
			0
		END


	RETURN(@FNATestAssessment)
END





















