IF OBJECT_ID(N'[dbo].[spa_resolve_function_parameter]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_resolve_function_parameter]
GO
   
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Formula Function related operations. Resolve formula function parameters.
	Parameters
	@flag : Operation flag
	@formula_name : Formula Name
	@formula_id : Formula Id
	@process_id : Process Id
	@formula_group_id : Formula Group Id
	@tsql : Formula sql
	@formula_type : Formula Type
*/

CREATE PROCEDURE [dbo].[spa_resolve_function_parameter]
	@flag CHAR(1),
	@formula_name AS VARCHAR(MAX) = NULL,
	@formula_id VARCHAR(MAX) = NULL,
	@process_id VARCHAR(200) = NULL,
	@formula_group_id INT = NULL,
	@tsql VARCHAR(MAX) = NULL,
	@formula_type AS CHAR(1) = 'd'
AS

SET NOCOUNT ON

DECLARE @formula_new VARCHAR(MAX)
		,@index INT
		,@index_child_begin INT
		,@index_child_end INT
		,@search_start INT = 0
		,@previous_index INT
		,@newid VARCHAR(100)
		,@nearest_index_comma_operand INT
		,@nearest_index_bracket INT
		,@index_start INT
		,@sql VARCHAR(MAX)
		,@level_count INT
		,@data_source_id INT
		,@validation_status INT = 1
		,@formula_org_name VARCHAR(500)
		,@formula_id1 INT
SET @index = 1
/* To map parameter of functions */
IF OBJECT_ID('tempdb..#temp_formula_editor_data') IS NOT NULL
			DROP TABLE #temp_formula_editor_data
CREATE TABLE #temp_formula_editor_data(
	formula_id INT,
	formula_name VARCHAR(MAX)
)

IF OBJECT_ID('tempdb..#formula_index') IS NOT NULL
			DROP TABLE #formula_index
CREATE TABLE #formula_index(
	formula_index_id INT IDENTITY(1,1),
	formula VARCHAR(1000),
	[level] INT,
	[id] VARCHAR(100)
)

IF OBJECT_ID('tempdb..#formula_operands') IS NOT NULL
			DROP TABLE #formula_operands
CREATE TABLE #formula_operands(
	item CHAR(1)
)

/* Each operand is enclosed with # to identify the position of formula */
INSERT INTO #formula_operands(item)
SELECT '+' UNION ALL
SELECT '-' UNION ALL
SELECT '*' UNION ALL
SELECT '\' UNION ALL
SELECT '/'

IF @flag = 's'
BEGIN
DECLARE @user_name VARCHAR(100) = dbo.fnadbuser()
DECLARE @process_table	VARCHAR(300) = dbo.FNAProcessTableName('formula_editor', @user_name, @process_id)
SET @sql = 'INSERT INTO #temp_formula_editor_data(formula_id,formula_name)
			SELECT fe.formula_id,fe.formula
			FROM formula_editor fe '
IF @formula_id IS NOT NULL
	SET @sql += 'INNER JOIN dbo.SplitCommaSeperatedValues(''' + @formula_id + ''') temp 
					ON temp.item = fe.formula_id 
				'
SET @sql += ' LEFT JOIN formula_nested fn
			ON fn.formula_id = fe.formula_id
			WHERE 1 = 1   
	'
--IF @formula_id IS NOT NULL
--	SET @sql = @sql + ' and fe.formula_id= ' +CAST(@formula_id AS VARCHAR(20))
IF @formula_name IS NOT NULL AND CHARindex('%',@formula_name) = 0
	SET @sql = @sql + ' and fe.formula_name = ''' + @formula_name+''''
IF @formula_group_id IS NOT NULL
	SET @sql = @sql + ' and fn.formula_group_id= ' +CAST(@formula_group_id AS VARCHAR(20))
IF @formula_type = 'n' 
		SET @sql = @sql + ' AND fn.formula_id IS NULL'
ELSE IF @formula_type = 'b'
	SET @sql = @sql + ' AND (istemplate =''y'' OR (fn.formula_id IS NULL AND istemplate is NULL))'
ELSE IF @formula_type = 't'
		SET @sql = @sql + ' AND istemplate =''y'''
ELSE IF @formula_type = 'n'
	SET @sql = @sql + ' AND istemplate is NULL'	
IF @formula_type = 'b'
	SET @sql = @sql + ' AND fe.formula_type <> ''n'''
EXEC(@sql)
IF OBJECT_ID('tempdb..#temp_formula_data') IS NOT NULL
	DROP TABLE #temp_formula_data

CREATE TABLE #temp_formula_data(
	sql_string VARCHAR(500),
	[sequence] INT,
	[parameter] VARCHAR(1000),
	[parameter_data] VARCHAR(200)
)

IF OBJECT_ID('tempdb..#temp_parameter_mapping') IS NOT NULL
	DROP TABLE #temp_parameter_mapping

CREATE TABLE #temp_parameter_mapping(
	value_id VARCHAR(100),
	code VARCHAR(500)
)

IF OBJECT_ID('tempdb..#temp_parameter_mapping1') IS NOT NULL
	DROP TABLE #temp_parameter_mapping1

CREATE TABLE #temp_parameter_mapping1(
	value_id VARCHAR(100),
	code VARCHAR(500),
	state VARCHAR(100)
)

DECLARE cursor_formula_editor CURSOR FOR
SELECT formula_id,formula_name
FROM #temp_formula_editor_data
OPEN cursor_formula_editor
	FETCH NEXT FROM cursor_formula_editor INTO @formula_id1, @formula_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
	SET @formula_new = REPLACE(REPLACE(REPLACE(@formula_name,'dbo.FNA',''),' ',''),  CHAR(160), '')
	SELECT @formula_new = REPLACE(@formula_new, item, '#'+item+'#') FROM #formula_operands

	SET @level_count = 0
	IF CHARINDEX('(', @formula_new,@search_start) <> 0
	BEGIN
	/* Get all the function present in the formula query string */
	WHILE (@index <> 0)
	BEGIN
		BEGIN TRY
		SET @newid = NEWID()          
		SELECT @index = CHARINDEX('(', @formula_new,@search_start)
		SELECT @index_child_begin  = CHARINDEX('(', @formula_new,@index + 1)
		SELECT @index_child_end  = CHARINDEX(')', @formula_new,@index + 1)
		IF (LEN(@formula_new) - LEN(REPLACE(@formula_new,'(',''))) = 1 -- Get the final formula left in the query
		BEGIN
			SET @index_start = len(@formula_new) - CHARINDEX('#',reverse(@formula_new),len(@formula_new) - @index +2) + 1
			IF (@index_start - 1) = len(@formula_new) --For the case when function is present at the beginning of the string
				SET @index_start = 0

			INSERT INTO #formula_index(formula,[level],id) -- Insert the function into table
			SELECT REPLACE(SUBSTRING(@formula_new,(@index_start + 1),CHARINDEX(')', @formula_new)-@index_start),' ',''),@level_count,@newid
			SELECT @formula_new = STUFF(@formula_new,(@index_start + 1),CHARINDEX(')', @formula_new)-@index_start, @newid) -- Replace the function with the unique id
			SET @index = 0
		END
		ELSE IF @index_child_end < @index_child_begin OR @index_child_begin = 0 -- Get each function from the formula string, insert into temp table and replace it with unique id
		BEGIN
			IF CHARINDEX(',',reverse(@formula_new),len(@formula_new) - @index +2) <> 0
				SET  @nearest_index_comma_operand = len(@formula_new) - CHARINDEX(',',reverse(@formula_new),len(@formula_new) - @index +2) + 1
			ELSE IF CHARINDEX('#',reverse(@formula_new),len(@formula_new) - @index +2) <> 0
				SET  @nearest_index_comma_operand = len(@formula_new) - CHARINDEX('#',reverse(@formula_new),len(@formula_new) - @index +2) + 1
			ELSE -- For case of function with single parameter
				SET  @nearest_index_comma_operand = 0
			SET  @nearest_index_bracket = len(@formula_new) - CHARINDEX('(',reverse(@formula_new),len(@formula_new) - @index + 2) + 1
			/* Checking wether , or ( is near to find the beginning of function name*/
			IF ABS(@index - @nearest_index_bracket) < ABS(@index - @nearest_index_comma_operand)
				SET @index_start = @nearest_index_bracket
			ELSE
				SET @index_start = @nearest_index_comma_operand
		
			-- For cases when only single level function are present in the query string
			IF @level_count = 0
			BEGIN
				SET @index_start = len(@formula_new) - CHARINDEX('#',reverse(@formula_new),len(@formula_new) - @index +2) + 1
				IF (@index_start - 1) = len(@formula_new)
					SET @index_start = 0
				INSERT INTO #formula_index(formula,[level],id)
				SELECT REPLACE(SUBSTRING(@formula_new,(@index_start + 1),CHARINDEX(')', @formula_new)-@index_start),' ',''),@level_count,@newid
				SELECT @formula_new = STUFF(@formula_new,(@index_start + 1),CHARINDEX(')', @formula_new)-@index_start, @newid)
			END
			ELSE -- Get children function data
			BEGIN
			INSERT INTO #formula_index(formula,[level],id)
			SELECT REPLACE(SUBSTRING(@formula_new, @index_start + 1,  @index_child_end  - @index_start),' ',''),@level_count,@newid
				SELECT @formula_new = STUFF(@formula_new, @index_start + 1,  @index_child_end  - @index_start, @newid)
			END
		
			SET @index = 1
			SET @search_start = 1
			SET @previous_index = @index
			SET @level_count = 0
		END
		ELSE
		BEGIN
			SET @search_start = @index_child_begin
			SET @previous_index = @index
			SET @level_count += 1
		END
		END TRY
		BEGIN CATCH
			SET @index = 0
			EXEC spa_print 'Invalid query'
		END CATCH
	END

	--select * from #formula_index

	/* Mapping of parameter with corresponding value */

	DECLARE @function_name  VARCHAR(100),
			@parameter_string VARCHAR(500),
			@mapped_value VARCHAR(1000),
			@sequence INT,
			@sql_string VARCHAR(1000),
			@parameter VARCHAR(100)
	IF OBJECT_ID('tempdb..#temp_formula_data') IS NOT NULL
		TRUNCATE TABLE #temp_formula_data
	IF OBJECT_ID('tempdb..#temp_parameter_mapping') IS NOT NULL
		TRUNCATE TABLE #temp_parameter_mapping
	IF OBJECT_ID('tempdb..#temp_parameter_mapping1') IS NOT NULL
		TRUNCATE TABLE #temp_parameter_mapping1

	DECLARE cursor_formula CURSOR FOR
	SELECT formula,id
	FROM #formula_index
	OPEN cursor_formula
			FETCH NEXT FROM cursor_formula INTO @formula_name, @newid
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @function_name = SUBSTRING(@formula_name, 0, CHARINDEX('(', @formula_name))
				SET @formula_org_name = @function_name
				SELECT @function_name = REPLACE(@function_name,'''','')
				SET @parameter_string = SUBSTRING( LEFT(@formula_name, charindex(')', @formula_name)-1), CHARINDEX('(', @formula_name) + len('('), LEN(@formula_name))

				IF OBJECT_ID('tempdb..#temp_parameters') IS NOT NULL
				DROP TABLE #temp_parameters

				CREATE TABLE #temp_parameters(
					[sequence] INT IDENTITY(1,1) NOT NULL,
					parameter VARCHAR(1000)
				)

				INSERT INTO #temp_parameters (parameter)
				SELECT item FROM dbo.SplitCommaSeperatedValues(@parameter_string)
				
				IF EXISTS(SELECT 1 FROM #temp_parameters )
				BEGIN
					/* Get information about the parameter */
					IF EXISTS (SELECT 1 FROM data_source WHERE [name] = @function_name AND category = 106501)
					BEGIN
						-- For user defined view
						EXEC('
							INSERT INTO #temp_formula_data(sql_string,sequence)
							SELECT param_data_source,  ROW_NUMBER() OVER(ORDER BY data_source_column_id)
							FROM data_source ds
							INNER JOIN data_source_column dsc
								ON dsc.source_id = ds.data_source_id
							WHERE required_filter = 1 
							AND ds.name = ''' + @function_name + '''
						')
					END
					ELSE
					BEGIN
						-- For standard functions
						EXEC('
							INSERT INTO #temp_formula_data(sql_string,sequence)
							SELECT sql_string,sequence 
							FROM formula_editor_parameter
							WHERE function_name = ''' + @function_name + '''
							ORDER BY sequence
						')
					END
				
					/* Map query with the parameters got from the function present in string */
					IF EXISTS(SELECT 1 FROM #temp_formula_data)
					BEGIN
						UPDATE tfd
							SET tfd.parameter = tp.parameter
						FROM #temp_formula_data tfd
						inner join #temp_parameters tp
							ON tfd.sequence = tp.sequence
					END
					ELSE
					BEGIN --Insert same parameter for standard functions such as MIN,MAX
						INSERT INTO #temp_formula_data(sql_string,[sequence],parameter)
						SELECT NULL,[sequence],parameter
						FROM #temp_parameters
					END
			
					/* For each parameter execute the query and get corresponding value.
					   The value is mapped with coressponding paraemter values.	
					*/
					DECLARE cursor_tbl CURSOR FOR
					SELECT sql_string,parameter,sequence
					FROM #temp_formula_data
					WHERE sql_string IS NOT NULL AND sql_string <> ''
					OPEN cursor_tbl
							FETCH NEXT FROM cursor_tbl INTO @sql_string, @parameter, @sequence
							WHILE @@FETCH_STATUS = 0
							BEGIN
								IF @sql_string like '%spa_StaticDataValues%' -- Exception added to include query which returns three fields 
								BEGIN
									INSERT INTO #temp_parameter_mapping1(value_id,code,[state])
									EXEC (@sql_string)

									INSERT INTO #temp_parameter_mapping(value_id,code)
									SELECT value_id,code
									FROM #temp_parameter_mapping1
								END
								ELSE 
								BEGIN
									BEGIN TRY
									INSERT INTO #temp_parameter_mapping(value_id,code)
									EXEC (@sql_string)
									END TRY
									BEGIN CATCH
										EXEC spa_print 'Invalid query'
									END CATCH
								END
								IF EXISTS(SELECT 1 FROM #temp_parameter_mapping where value_id = REPLACE(@parameter, '#-#', '-'))
								BEGIN
									SELECT @mapped_value = code 
									FROM #temp_parameter_mapping where value_id = REPLACE(@parameter, '#-#', '-')
								END
								ELSE
								BEGIN
									SET @mapped_value = @parameter
								END 

								UPDATE #temp_formula_data
								SET parameter_data = @mapped_value
								WHERE sequence = @sequence

								DELETE FROM #temp_parameter_mapping
								DELETE FROM #temp_parameter_mapping1
								FETCH NEXT FROM cursor_tbl INTO @sql_string, @parameter, @sequence
							END
					CLOSE cursor_tbl
					DEALLOCATE cursor_tbl
					SELECT  @mapped_value = STUFF((SELECT ',' + REPLACE(CAST(ISNULL(parameter_data,parameter) AS VARCHAR(200)),'.','$$$$') 
						FROM #temp_formula_data 
						ORDER BY sequence		                       
					FOR XML PATH('')), 1, 1, '')
					--DBCC CHECKIDENT ('#temp_parameters', RESEED, 0);
					SET @function_name = @formula_org_name
					UPDATE #formula_index
					SET formula = @function_name + '(' + @mapped_value + ')'
					WHERE id = @newid
				END
				DELETE FROM #temp_parameter_mapping
				DELETE FROM #temp_parameter_mapping1
				DROP TABLE #temp_parameters
				DELETE FROM #temp_formula_data
		
			FETCH NEXT FROM cursor_formula INTO @formula_name, @newid
			END
	CLOSE cursor_formula
	DEALLOCATE cursor_formula

	--select @formula_new
	--SELECT * FROM #formula_index
	/* Replace unique id with corresponding formula
	   Begin with the parent function and their childs
	   0 -> Parent
	   1- > Child
	*/
	SELECT @formula_new = REPLACE(@formula_new,id,formula)
	FROM #formula_index
	ORDER BY level, formula_index_id DESC
	END
	SELECT @formula_new = REPLACE(@formula_new,'#','')
	
	UPDATE #temp_formula_editor_data
	SET formula_name = @formula_new
	WHERE formula_id = @formula_id1

	DELETE FROM #formula_index
	DELETE FROM #temp_formula_data
	DELETE FROM #temp_parameter_mapping
	DELETE FROM #temp_parameter_mapping1

	SET @index = 1
	SET @nearest_index_comma_operand = 0
	SET @nearest_index_bracket = 0
	SET @index_start = 0
	SET @search_start = 0
	SET @index_child_begin = 0
	SET @index_child_end = 0

FETCH NEXT FROM cursor_formula_editor INTO @formula_id1, @formula_name
		END
CLOSE cursor_formula_editor
DEALLOCATE cursor_formula_editor
--SELECT * from #temp_formula_editor_data

UPDATE #temp_formula_editor_data
SET formula_name = dbo.FNAFormulaResolveParamSeperator(formula_name, 'v')

EXEC('SELECT * 
     INTO ' + @process_table + ' 
	 FROM #temp_formula_editor_data'
)

END

/* To check if user defined query exists */
ELSE IF @flag = 'c'
BEGIN
	SET @formula_new = REPLACE(@tsql,'dbo.FNA','')
	SET @formula_new = REPLACE(REPLACE(REPLACE(@formula_new,'dbo.FNA',''),' ',''),  CHAR(160), '')
	SELECT @formula_new = Replace(@formula_new, item, '#'+item+'#') FROM #formula_operands

	SET @level_count = 0
	IF CHARINDEX('(', @formula_new,@search_start) <> 0
	BEGIN
	/* Get all the function present in the formula query string */
	WHILE (@index <> 0)
	BEGIN
		SET @newid = NEWID()          
		SELECT @index = CHARINDEX('(', @formula_new,@search_start)
		SELECT @index_child_begin  = CHARINDEX('(', @formula_new,@index + 1)
		SELECT @index_child_end  = CHARINDEX(')', @formula_new,@index + 1)
		IF (LEN(@formula_new) - LEN(REPLACE(@formula_new,'(',''))) = 1 -- Get the final formula left in the query
		BEGIN
			SET @index_start = len(@formula_new) - CHARINDEX('#',reverse(@formula_new),len(@formula_new) - @index +2) + 1
			IF (@index_start - 1) = len(@formula_new) --For the case when function is present at the beginning of the string
				SET @index_start = 0

			INSERT INTO #formula_index(formula,[level],id) -- Insert the function into table
			SELECT REPLACE(SUBSTRING(@formula_new,(@index_start + 1),CHARINDEX(')', @formula_new)-@index_start),' ',''),@level_count,@newid
			SELECT @formula_new = STUFF(@formula_new,(@index_start + 1),CHARINDEX(')', @formula_new)-@index_start, @newid) -- Replace the function with the unique id
			SET @index = 0
		END
		ELSE IF @index_child_end < @index_child_begin OR @index_child_begin = 0 -- Get each function from the formula string, insert into temp table and replace it with unique id
		BEGIN
			IF CHARINDEX(',',reverse(@formula_new),len(@formula_new) - @index +2) <> 0
				SET  @nearest_index_comma_operand = len(@formula_new) - CHARINDEX(',',reverse(@formula_new),len(@formula_new) - @index +2) + 1
			ELSE IF CHARINDEX('#',reverse(@formula_new),len(@formula_new) - @index +2) <> 0
				SET  @nearest_index_comma_operand = len(@formula_new) - CHARINDEX('#',reverse(@formula_new),len(@formula_new) - @index +2) + 1
			ELSE -- For case of function with single parameter
				SET  @nearest_index_comma_operand = 0
			SET  @nearest_index_bracket = len(@formula_new) - CHARINDEX('(',reverse(@formula_new),len(@formula_new) - @index + 2) + 1
			/* Checking wether , or ( is near to find the beginning of function name*/
			IF ABS(@index - @nearest_index_bracket) < ABS(@index - @nearest_index_comma_operand)
				SET @index_start = @nearest_index_bracket
			ELSE
				SET @index_start = @nearest_index_comma_operand
		
			-- For cases when only single level function are present in the query string
			IF @level_count = 0
			BEGIN
				SET @index_start = len(@formula_new) - CHARINDEX('#',reverse(@formula_new),len(@formula_new) - @index +2) + 1
				IF (@index_start - 1) = len(@formula_new)
					SET @index_start = 0
				INSERT INTO #formula_index(formula,[level],id)
				SELECT REPLACE(SUBSTRING(@formula_new,(@index_start + 1),CHARINDEX(')', @formula_new)-@index_start),' ',''),@level_count,@newid
				SELECT @formula_new = STUFF(@formula_new,(@index_start + 1),CHARINDEX(')', @formula_new)-@index_start, @newid)
			END
			ELSE -- Get children function data
			BEGIN
			INSERT INTO #formula_index(formula,[level],id)
			SELECT REPLACE(SUBSTRING(@formula_new, @index_start + 1,  @index_child_end  - @index_start),' ',''),@level_count,@newid
				SELECT @formula_new = STUFF(@formula_new, @index_start + 1,  @index_child_end  - @index_start, @newid)
			END
		
			SET @index = 1
			SET @search_start = 1
			SET @previous_index = @index
			SET @level_count = 0
		END
		ELSE
		BEGIN
			SET @search_start = @index_child_begin
			SET @previous_index = @index
			SET @level_count += 1
		END
	END
	END

	--SELECT * FROM #formula_index
	
	IF OBJECT_ID('tempdb..#temp_function_parameters') IS NOT NULL
					    DROP TABLE #temp_function_parameters

	CREATE TABLE #temp_function_parameters(
		[sequence] INT IDENTITY(1,1) NOT NULL,
		parameter VARCHAR(100)
	)

	IF EXISTS(SELECT 1 FROM #formula_index fi
				INNER JOIN data_source ds
					ON REPLACE(ds.name,' ','') = LEFT(fi.formula,CHARINDEX ('(',fi.formula) - 1)
					AND ds.category = 106501
			 )
	BEGIN
		DECLARE cursor_formula CURSOR FOR
		SELECT fi.formula,fi.id,ds.data_source_id
		FROM #formula_index fi
		INNER JOIN data_source ds
			ON REPLACE(ds.name,' ','') = LEFT(fi.formula,CHARINDEX ('(',fi.formula) - 1)
			AND ds.category = 106501
		OPEN cursor_formula
				FETCH NEXT FROM cursor_formula INTO @formula_name, @newid, @data_source_id
				WHILE @@FETCH_STATUS = 0 AND @validation_status = 1
				BEGIN
					SET @function_name = SUBSTRING(@formula_name, 0, CHARINDEX('(', @formula_name))
					SET @parameter_string = SUBSTRING( LEFT(@formula_name, charindex(')', @formula_name)-1), CHARINDEX('(', @formula_name) + len('('), LEN(@formula_name))
					
					INSERT INTO #temp_function_parameters (parameter)
					SELECT item FROM dbo.SplitCommaSeperatedValues(@parameter_string)
					
					--SELECT * FROM #temp_function_parameters
					/* Validation begin for user defined function */
						-- Check if same number of paramter exists
						IF (SELECT COUNT(*) FROM #temp_function_parameters) <> (SELECT COUNT(*) 
						                                                       FROM data_source_column 
																			   WHERE source_id = @data_source_id
																			   AND required_filter = 1
																			   )
							SET @validation_status = 0

					/* Validation End */
					DELETE FROM #temp_function_parameters
					--DBCC CHECKIDENT ('#temp_parameters', RESEED, 0)
				FETCH NEXT FROM cursor_formula INTO @formula_name, @newid, @data_source_id
				END
		CLOSE cursor_formula
		DEALLOCATE cursor_formula
	END

	IF @validation_status = 1
	BEGIN
		/* Replace user defined function with number to allow combination of exisitng function 
		   and user defined function to be validated                                       */
		UPDATE fi
		SET fi.formula = 1
		FROM #formula_index fi
		INNER JOIN data_source ds
			ON REPLACE(ds.name,' ','') = LEFT(fi.formula,CHARINDEX ('(',fi.formula) - 1)
			AND ds.category = 106501

		--UPDATE #formula_index
		--SET formula = 'dbo.FNA' + formula
		--WHERE formula <> '1'
	END
	SELECT @formula_new = REPLACE(@formula_new,id,formula)
	FROM #formula_index
	ORDER BY level,formula_index_id DESC

	SET @formula_new = dbo.FNAFormulaFormat(@formula_new,'d')
	SELECT @formula_new = REPLACE(@formula_new,'#','')

	SET @formula_new='DECLARE @result VARCHAR(8000)
						SELECT @result = '+ @formula_new 
    EXEC( @formula_new)

END