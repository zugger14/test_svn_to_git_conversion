IF OBJECT_ID(N'[dbo].[FNARFXGetReportParameterValue]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARFXGetReportParameterValue]
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: ssingh@pioneersolutionsglobal.com
-- Create date: 2011-06-15
-- Description: Function to Return the value of parameter of the report building query 
 
-- Params:
-- returns ReportParametersValue (varchar)
--================================================================================================================
CREATE FUNCTION [dbo].[FNARFXGetReportParameterValue](@string VARCHAR(MAX),@ReportParameters VARCHAR(8000))
    RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @ReportParametersValue VARCHAR(8000)
	DECLARE @temp_map TABLE (
		pameter_name				VARCHAR(1000)	--parameter name 
		, start_index				INT				--start index of parameter name                                                                                  
		, start_double_quote		VARCHAR(1000)	
		, param_value_start_index	INT 
		, end_double_quote			VARCHAR(1000)	
		, param_value_end_index		INT				
	)

	INSERT INTO @temp_map(
			pameter_name				
			, start_index				
			, start_double_quote		
			, param_value_start_index	
			, end_double_quote			
			, param_value_end_index		
	)

	SELECT 
		pameter_name,
		start_index,
		start_double_quote,
		param_value_start_index,
		end_double_quote,
		param_value_end_index
	FROM (
			SELECT pos_param_name.n AS start_index, SUBSTRING(@string, pos_param_name.n, LEN(@ReportParameters)) AS pameter_name
			FROM dbo.seq pos_param_name
			WHERE pos_param_name.n <= LEN(@string)
				AND SUBSTRING(@string, pos_param_name.n, LEN(@ReportParameters)) = @ReportParameters
	) pos_param_start
	--find the first occurence of "  before param_value       
	OUTER APPLY(
				SELECT TOP 1 n AS param_value_start_index, SUBSTRING(@string, n, 1) AS start_double_quote
				FROM dbo.seq
				WHERE n <= LEN(@string)
					AND SUBSTRING(@string, n, 1) ='"'
					AND n >= pos_param_start.start_index --index must be greater than pos_param_start.start_index
				ORDER BY n
	) pos_param_value_start
	--find the last occurence of " after param_value
	OUTER APPLY(
				SELECT TOP 1 n AS param_value_end_index, SUBSTRING(@string, n, 1) AS end_double_quote
				FROM dbo.seq
				WHERE n <= LEN(@string)
					AND SUBSTRING(@string, n, 1) IN ('"')
					AND n > pos_param_value_start.param_value_start_index--index must be greater than pos_param_value_start.param_value_start_index
				ORDER BY n
	) pos_param_value_end 

	--SELECT  * FROM @temp_map	
	SELECT @ReportParametersValue = SUBSTRING(@string, (t.param_value_start_index+1), (t.param_value_end_index - (t.param_value_start_index+1)))	
	FROM @temp_map t 

	RETURN @ReportParametersValue
   
END
GO