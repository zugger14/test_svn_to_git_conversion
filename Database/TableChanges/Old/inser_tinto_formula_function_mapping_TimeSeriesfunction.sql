IF EXISTS(SELECT 'X' FROm formula_function_mapping WHERE function_name='GetTimeSeriesData')
	DELETE FROM  formula_function_mapping WHERE function_name='GetTimeSeriesData'

INSERT INTO formula_function_mapping(function_name,eval_string,arg1,arg2)
SELECT 'GetTimeSeriesData','dbo.FNARGetTimeSeriesData(cast(arg1  as INT),arg2)','arg1','convert(VARCHAR(20),t.as_of_date,120)'
