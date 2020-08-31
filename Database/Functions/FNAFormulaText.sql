IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNAFormulaText]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAFormulaText]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAFormulaText] (	
					@maturity_date VARCHAR(20),
					@as_of_date VARCHAR(20), 
					@volume MONEY,
					@sum_volume MONEY,
					@formula VARCHAR(8000),
					@he INT,
					@half INT,
					@qtr INT,
					@curve_source_value_id INT,
					@contract_id INT = NULL
			) 
				
--RETURNS float AS  
RETURNS VARCHAR(8000) AS  
BEGIN

	IF @curve_source_value_id=0
		SET @curve_source_value_id=4500

	DECLARE @formula_stmt VARCHAR(8000)


	SET @formula = REPLACE(@formula, '', '') 
	SET @formula = REPLACE(@formula, 'SumVolume', CAST(@sum_volume AS VARCHAR)) 
	SET @formula = REPLACE(@formula, 'Volume', CAST(@volume AS VARCHAR)) 
	--monthly curve

	--yearly curve
	SET @formula = REPLACE(@formula, 'dbo.FNACurveY(', 'dbo.FNARECCurve(' +  '''' + 
					dbo.FNAGetContractMonth(CAST(CAST(YEAR(@maturity_date) AS VARCHAR)+'-01-01' AS DATETIME)) + '''' +','''+dbo.FNAGetContractMonth(CAST(CAST(YEAR(@maturity_date) AS VARCHAR)+'-01-01' AS DATETIME))+''''+ ',')
	--Daily curve
	SET @formula = REPLACE(@formula, 'dbo.FNACurveD(', 'dbo.FNARECCurve(' +  '''' + 
					@maturity_date + '''' +','''+@as_of_date+''''+ ',')
	
	--hourly curve
	SET @formula = REPLACE(@formula, 'dbo.FNACurveH(', 'dbo.FNAHRECCurve(' + CAST(ISNULL(@he, 1) AS VARCHAR) + ','  +  '''' + 
					dbo.FNAGetSQLStandardDate(@maturity_date) + '''' + ',')

	--15 minute curve
	SET @formula = REPLACE(@formula, 'dbo.FNACurve15(', 'dbo.FNARCurve15(' + CAST(ISNULL(@he, 1) AS VARCHAR) + ',' 
					+ CAST(ISNULL(@qtr, 1) AS VARCHAR) + ','  +  '''' + 
					dbo.FNAGetSQLStandardDate(@maturity_date) + '''' + ',')
	
	--30 minute curve
	SET @formula = REPLACE(@formula, 'dbo.FNACurve30(', 'dbo.FNARCurve30(' + CAST(ISNULL(@he, 1) AS VARCHAR) + ',' 
					+ CAST(ISNULL(@half, 1) AS VARCHAR) + ','  +  '''' + 
					dbo.FNAGetSQLStandardDate(@maturity_date) + '''' + ',')


	-- Added By Gyan
	
	
	SET @formula = REPLACE(@formula, 'dbo.FNACurve(', 'dbo.FNARECCurve(' +  '''' + 
					dbo.FNAGetContractMonth(@maturity_date) + '''' +','''+@as_of_date+''''+ ',')

	SET @formula = REPLACE(@formula, 'dbo.FNALagCurve(', 'dbo.FNARLagCurve(' +  '''' + 
					dbo.FNAGetContractMonth(@maturity_date) + '''' +','''+@as_of_date+''''+ ','+CAST(@curve_source_value_id AS VARCHAR) +',' + CAST(@contract_id AS VARCHAR(100)) + ',') 

	SET @formula = REPLACE(@formula, 'dbo.FNAPriorCurve(', 'dbo.FNARPriorCurve(' +  '''' + 
						(@maturity_date) + '''' +','''+@as_of_date+''''+ ','+CAST(@he AS VARCHAR)+ ','+CAST(@curve_source_value_id AS VARCHAR) +',')

	SET @formula = REPLACE(@formula, 'dbo.FNAWACOG_Buy(', 'dbo.FNARWACOG_Buy(' +  '''' + 
					@as_of_date+'''' + ',')

	SET @formula = REPLACE(@formula, 'dbo.FNAWACOG_Sale(', 'dbo.FNARWACOG_Sale(' + 
					@as_of_date+'''' + ',')
	
	SET @formula = REPLACE(@formula, 'dbo.FNARelativePeriod(', 'dbo.FNARRelativePeriod(' +  '''' + 
						(@maturity_date) + '''' +','''+@as_of_date+''''+ ','+CAST(@curve_source_value_id AS VARCHAR) +',')
						
	/* added to add parameter forFNARECCurve start */
	DECLARE @udf_function VARCHAR(100)
	DECLARE @added_values VARCHAR(1200)
	DECLARE @check_function_fnareccurve INT
	DECLARE @check_function_fnahreccurve INT 
	
	SELECT @check_function_fnahreccurve = CHARINDEX('FNAHRECCurve', @formula)
	SELECT @check_function_fnareccurve = CHARINDEX('FNARECCurve', @formula)
	DECLARE @added_arg VARCHAR(5000), @arg VARCHAR(5000)
		
	IF @check_function_fnareccurve > 0
	BEGIN
		SET @udf_function = 'dbo.FNARECCurve' 	
		SET @added_values = ', 0, 0, NULL, NULL' 
		
		DECLARE @a TABLE (n INT , na INT , [added_arg] VARCHAR(5000), arg VARCHAR(5000))
		INSERT INTO @a
		SELECT * FROM dbo.seq pos_param_name 
		--find the parameter value of udf_function and udf_function end index
		OUTER APPLY (
			SELECT TOP 1 (n + LEN(@udf_function) -1) [na]
				, LEFT(SUBSTRING(@formula, (n + LEN(@udf_function) - 1), LEN(@formula)), CHARINDEX(')', SUBSTRING(@formula, (n + LEN(@udf_function)) - 1, LEN(@formula)))) + @added_values [added_arg]
				, LEFT(SUBSTRING(@formula, (n + LEN(@udf_function) - 1), LEN(@formula)), CHARINDEX(')', SUBSTRING(@formula, (n + LEN(@udf_function)) - 1, LEN(@formula))))  [arg]
			FROM dbo.seq
			WHERE n <= LEN(@formula)
				AND n > pos_param_name.n	--index must be greater than start_index
			ORDER BY n
		) pos_param_value_start	
		WHERE  pos_param_name.n <= LEN(@formula)
			AND SUBSTRING(@formula, pos_param_name.n, LEN(@udf_function)) = @udf_function
		
		DECLARE cur_status CURSOR LOCAL FOR
		SELECT DISTINCT [added_arg], arg
		FROM @a
		OPEN cur_status;
		FETCH NEXT FROM cur_status INTO @added_arg, @arg
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @formula = REPLACE(@formula, @arg, @added_arg) 
			FETCH NEXT FROM cur_status INTO @added_arg, @arg
		END;
		CLOSE cur_status;
		DEALLOCATE cur_status;	
	END
	
	IF @check_function_fnahreccurve > 0
	BEGIN
		SET @udf_function = 'dbo.FNAHRECCurve' 
		SET @added_values = ', NULL, NULL)' 
		
		DECLARE @b TABLE (n INT , na INT , [added_arg] VARCHAR(5000), arg VARCHAR(5000))
		INSERT INTO @b
		SELECT * FROM dbo.seq pos_param_name 
		--find the parameter value of udf_function and udf_function end index
		OUTER APPLY (
			SELECT TOP 1 (n + LEN(@udf_function) -1) [na]
				, LEFT(SUBSTRING(@formula, (n + LEN(@udf_function) - 1), LEN(@formula)), CHARINDEX(')', SUBSTRING(@formula, (n + LEN(@udf_function)), LEN(@formula)))) + @added_values [added_arg]
				, LEFT(SUBSTRING(@formula, (n + LEN(@udf_function) - 1), LEN(@formula)), CHARINDEX(')', SUBSTRING(@formula, (n + LEN(@udf_function)) - 1, LEN(@formula))))  [arg]
				--,  SUBSTRING(@formula, (n + LEN(@udf_function)) + len(LEFT(SUBSTRING(@formula, (n + LEN(@udf_function) - 1), LEN(@formula)), CHARINDEX(')', SUBSTRING(@formula, (n + LEN(@udf_function)) - 1, LEN(@formula)))))
				--	, len(LEFT(SUBSTRING(@formula, (n + LEN(@udf_function) - 1), LEN(@formula)), CHARINDEX(')', SUBSTRING(@formula, (n + LEN(@udf_function)) - 1, LEN(@formula))))) 
				--) AS a
			FROM dbo.seq
			WHERE n <= LEN(@formula)
				AND n > pos_param_name.n	--index must be greater than start_index
			ORDER BY n
		) pos_param_value_start	
		WHERE  pos_param_name.n <= LEN(@formula)
			AND SUBSTRING(@formula, pos_param_name.n, LEN(@udf_function)) = @udf_function
		
		DECLARE cur_status CURSOR LOCAL FOR
		SELECT DISTINCT [added_arg], arg
		FROM @b
		OPEN cur_status;
		FETCH NEXT FROM cur_status INTO @added_arg, @arg
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @formula = REPLACE(@formula, @arg, @added_arg) 
			FETCH NEXT FROM cur_status INTO @added_arg, @arg
		END;
		CLOSE cur_status;
		DEALLOCATE cur_status;					
	END
	
	
	
	/* added to add parameter forFNARECCurve END */

	SET @formula_stmt=@formula
	SET @formula_stmt = REPLACE(@formula_stmt, 'Case', ' Case ') -- add white space
	SET @formula_stmt = REPLACE(@formula_stmt, 'Between', ' Between ') -- add white space
	SET @formula_stmt = REPLACE(@formula_stmt, 'AND', ' AND ') -- add white space
	SET @formula_stmt = REPLACE(@formula_stmt, 'Prior', 'Prir') -- to ignore "OR" Replacement
	SET @formula_stmt = REPLACE(@formula_stmt, 'OR', ' OR ') -- add white space
	SET @formula_stmt = REPLACE(@formula_stmt, 'Else', ' Else ') -- add white space
	SET @formula_stmt = REPLACE(@formula_stmt, 'Then', ' Then ') -- add white space
	SET @formula_stmt = REPLACE(@formula_stmt, 'When', ' When ') -- add white space
	SET @formula_stmt = REPLACE(@formula_stmt, 'End', ' End ') -- add white space
	SET @formula_stmt = REPLACE(@formula_stmt, 'Prir', 'Prior')


--uncomment this
	RETURN (@formula_stmt)

	--print  @formula
	
	--print @formula_stmt

-- 	SET @formula_stmt = replace(@formula_stmt, 'dbo.FNAFormula(', 'dbo.FNAFormulaText(' +  '''' +					
-- 					dbo.FNAGetContractMonth(@maturity_date) + '''' + ',' +
-- 					cast(@volume as varchar) + ', ')

	--SET @formula_stmt = @formula_stmt 

--comment these	
-- 	Select @formula_stmt
-- 	exec ('select ' + @formula_stmt)

END




























