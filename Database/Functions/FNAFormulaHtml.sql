IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAFormulaHtml]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAFormulaHtml]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAFormulaHtml](@formula INT)
RETURNS VARCHAR(8000)
AS
BEGIN 
	--DECLARE @formula INT = 1425
	
	DECLARE @nested_id INT
	DECLARE @formula_id INT

	IF EXISTS(SELECT 1
				FROM formula_editor fe
				INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_id
				WHERE fe.formula_id = @formula)
	BEGIN
		SELECT	@formula_id = fn.formula_group_id, 
				@nested_id = fn.sequence_order 
		FROM formula_editor fe
		INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_id
		WHERE fe.formula_id = @formula
	END
	ELSE
	BEGIN
		SET @formula_id = @formula
		SET @nested_id = ''
	END
	
	DECLARE @temp_fb_html TABLE (formula_breakdown_id	INT, formula_html VARCHAR(8000), formula_category CHAR(1))
	DECLARE @temp_fb_html_args TABLE (formula_breakdown_id	INT, formula_html VARCHAR(8000), formula_category CHAR(1), arg_no_for_next_func INT, level_func_sno INT, parent_level_func_sno INT)
	DECLARE @temp_fb_html_args_plus TABLE ([p_breakdown_id]	INT, [p_formula_html] VARCHAR(8000), [p_formula_category] CHAR(1), [p_arg_no_for_next_func] INT, [p_level_func_sno] INT, [p_parent_level_func_sno] INT,
										   [c_breakdown_id] INT, [c_formula_html] VARCHAR(8000), [c_formula_category] CHAR(1), [c_arg_no_for_next_func] INT, [c_level_func_sno] INT, [c_parent_level_func_sno] INT, row_id INT)

	/*
	Description - formula_cursor
	- Categorize the formula into formula with parameters, without parameters, operators or conditions
	- Build the formula and parameters html for the function (__<breakdown_id>_arg<argument_number>__ is used if the parameters are nested)
	- The formula and formula_category is inserted into #temp_fb_html
	- Formula categories are:
		-- 'p' formula with paramters
		-- 'u' formula without parameters
		-- 'o' operators
		-- 'c' conditions
	*/

	DECLARE @formula_html VARCHAR(200)
	DECLARE @formula_param_html VARCHAR(200)
	DECLARE @edit_icon_html VARCHAR(500)
	DECLARE @final_html VARCHAR(8000)
	DECLARE @formula_param_count INT

	DECLARE @formula_breakdown_id INT
	DECLARE @formula_name VARCHAR(100)
	DECLARE @formula_category CHAR(1)

	DECLARE formula_cursor CURSOR FOR 
	SELECT formula_breakdown_id FROM formula_breakdown WHERE formula_id = @formula_id AND nested_id = NULLIF(@nested_id, '') ORDER BY formula_level desc

	OPEN formula_cursor
	FETCH NEXT FROM formula_cursor 
	INTO @formula_breakdown_id

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @formula_html = ''
		SET	@formula_param_html = ''
		SET	@edit_icon_html = ''
		SET	@final_html = ''
		SELECT @formula_name = func_name FROM formula_breakdown WHERE formula_breakdown_id = @formula_breakdown_id

		/* Categorize the formula into formula with parameters, without parameters, operators or conditions */
		IF @formula_name IN ('+', '-', '*', '/', '>', '<', '=')
			SET @formula_category = 'o'
		ELSE IF @formula_name IN ('MAX', 'MIN', 'IF', 'IsNull' , 'AVG', 'POWER', 'Round', 'CEILING', 'SQRT', 'OR')
			SET @formula_category = 'c'
		ELSE 
		BEGIN
			SELECT @formula_param_count = COUNT(*) FROM formula_editor_parameter fep
			                              WHERE fep.function_name = @formula_name
			IF @formula_param_count > 0
				SET @formula_category = 'p'
			ELSE 
				SET @formula_category = 'u'
		END
		
		DECLARE @f_id VARCHAR(10)
		SET @f_id = CAST(@formula_breakdown_id AS VARCHAR)

		/* Build the formula and parameters html for the function (__<breakdown_id>_arg<argument_number>__  is used if the parameters are nested) */
		IF @formula_category = 'o'
			SELECT @final_html = ISNULL(arg1, ' __' + @f_id + '_arg1__ ') + @formula_name + ISNULL(arg2, ' __' + @f_id + '_arg2__ ') FROM formula_breakdown WHERE formula_breakdown_id = @formula_breakdown_id
		ELSE
		BEGIN
			SELECT @formula_html = '<span class="formula_span">' + @formula_name + '</span>'
			FROM formula_breakdown WHERE formula_id = @formula_id

			IF @formula_category = 'u'
			BEGIN
				IF @formula_name = 'parenthesis'
					SET @final_html = '(__' + @f_id + '_arg1__)'
				ELSE	
					SET @final_html = @formula_html + '()'
			END
			ELSE IF @formula_category = 'p'
			BEGIN
				-- There is string in parameter of GetLogicalValue function, so this is different condition
				IF (@formula_name = 'GetLogicalValue') 
				BEGIN
					SELECT @formula_param_html = ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL('''' + arg2 + '''', '__' + @f_id + '_arg2__') FROM formula_breakdown WHERE formula_breakdown_id = @formula_breakdown_id   
				END
				ELSE
				BEGIN
					SELECT @formula_param_html = 
							CASE 
								WHEN @formula_param_count = 1  THEN ISNULL(arg1, '__' + @f_id + '_arg1__')
								WHEN @formula_param_count = 2  THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__')  
								WHEN @formula_param_count = 3  THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__') + ',' + ISNULL(arg3, '__' + @f_id + '_arg3__') 
								WHEN @formula_param_count = 4  THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__') + ',' + ISNULL(arg3, '__' + @f_id + '_arg3__') + ',' + ISNULL(arg4, '__' + @f_id + '_arg4__') 
								WHEN @formula_param_count = 5  THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__') + ',' + ISNULL(arg3, '__' + @f_id + '_arg3__') + ',' + ISNULL(arg4, '__' + @f_id + '_arg4__') + ',' + ISNULL(arg5, '__' + @f_id + '_arg5__') 
								WHEN @formula_param_count = 6  THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__') + ',' + ISNULL(arg3, '__' + @f_id + '_arg3__') + ',' + ISNULL(arg4, '__' + @f_id + '_arg4__') + ',' + ISNULL(arg5, '__' + @f_id + '_arg5__') + ',' + ISNULL(arg6, '__' + @f_id + '_arg6__') 
								WHEN @formula_param_count = 7  THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__') + ',' + ISNULL(arg3, '__' + @f_id + '_arg3__') + ',' + ISNULL(arg4, '__' + @f_id + '_arg4__') + ',' + ISNULL(arg5, '__' + @f_id + '_arg5__') + ',' + ISNULL(arg6, '__' + @f_id + '_arg6__') + ',' + ISNULL(arg7, '__' + @f_id + '_arg7__') 
								WHEN @formula_param_count = 8  THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__') + ',' + ISNULL(arg3, '__' + @f_id + '_arg3__') + ',' + ISNULL(arg4, '__' + @f_id + '_arg4__') + ',' + ISNULL(arg5, '__' + @f_id + '_arg5__') + ',' + ISNULL(arg6, '__' + @f_id + '_arg6__') + ',' + ISNULL(arg7, '__' + @f_id + '_arg7__') + ',' + ISNULL(arg8, '__' + @f_id + '_arg8__') 
								WHEN @formula_param_count = 9  THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__') + ',' + ISNULL(arg3, '__' + @f_id + '_arg3__') + ',' + ISNULL(arg4, '__' + @f_id + '_arg4__') + ',' + ISNULL(arg5, '__' + @f_id + '_arg5__') + ',' + ISNULL(arg6, '__' + @f_id + '_arg6__') + ',' + ISNULL(arg7, '__' + @f_id + '_arg7__') + ',' + ISNULL(arg8, '__' + @f_id + '_arg8__') + ',' + ISNULL(arg9, '__' + @f_id + '_arg9__') 
								WHEN @formula_param_count = 10 THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__') + ',' + ISNULL(arg3, '__' + @f_id + '_arg3__') + ',' + ISNULL(arg4, '__' + @f_id + '_arg4__') + ',' + ISNULL(arg5, '__' + @f_id + '_arg5__') + ',' + ISNULL(arg6, '__' + @f_id + '_arg6__') + ',' + ISNULL(arg7, '__' + @f_id + '_arg7__') + ',' + ISNULL(arg8, '__' + @f_id + '_arg8__') + ',' + ISNULL(arg9, '__' + @f_id + '_arg9__') + ',' + ISNULL(arg10, '__' + @f_id + '_arg10__') 
								WHEN @formula_param_count = 11 THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__') + ',' + ISNULL(arg3, '__' + @f_id + '_arg3__') + ',' + ISNULL(arg4, '__' + @f_id + '_arg4__') + ',' + ISNULL(arg5, '__' + @f_id + '_arg5__') + ',' + ISNULL(arg6, '__' + @f_id + '_arg6__') + ',' + ISNULL(arg7, '__' + @f_id + '_arg7__') + ',' + ISNULL(arg8, '__' + @f_id + '_arg8__') + ',' + ISNULL(arg9, '__' + @f_id + '_arg9__') + ',' + ISNULL(arg10, '__' + @f_id + '_arg10__') + ',' + ISNULL(arg11, '__' + @f_id + '_arg11__') 
								WHEN @formula_param_count = 12 THEN ISNULL(arg1, '__' + @f_id + '_arg1__') + ',' + ISNULL(arg2, '__' + @f_id + '_arg2__') + ',' + ISNULL(arg3, '__' + @f_id + '_arg3__') + ',' + ISNULL(arg4, '__' + @f_id + '_arg4__') + ',' + ISNULL(arg5, '__' + @f_id + '_arg5__') + ',' + ISNULL(arg6, '__' + @f_id + '_arg6__') + ',' + ISNULL(arg7, '__' + @f_id + '_arg7__') + ',' + ISNULL(arg8, '__' + @f_id + '_arg8__') + ',' + ISNULL(arg9, '__' + @f_id + '_arg9__') + ',' + ISNULL(arg10, '__' + @f_id + '_arg10__') + ',' + ISNULL(arg11, '__' + @f_id + '_arg11__') + ',' + ISNULL(arg12, '__' + @f_id + '_arg12__') 
							END  FROM formula_breakdown WHERE formula_breakdown_id = @formula_breakdown_id 
				END
				SET @formula_param_html = '<span class="param_span">' + @formula_param_html + '</span>'
				SELECT @edit_icon_html = '<span contenteditable="false"><img id="' + @formula_name + '" class="plus_img" src="../../../adiha.php.scripts/adiha_pm_html/process_controls/TogglePlus.gif" onclick="create_formula_param(this, '''', ''reopen'');" style="margin-left: 2px;"></span>'
				FROM formula_breakdown WHERE formula_breakdown_id = @formula_breakdown_id
				SET @final_html =  @formula_html + '(' + @formula_param_html + @edit_icon_html + ')'
			END
			ELSE IF @formula_category = 'c'
			BEGIN
				IF @formula_name = 'MIN' OR @formula_name = 'MIN' OR @formula_name = 'IsNull' OR @formula_name = 'AVG' OR @formula_name = 'POWER' OR @formula_name = 'OR'
				BEGIN
					SET @final_html = @formula_html + '(__' + @f_id + '_arg1__, __' + @f_id + '_arg2__)'
				END
				ELSE IF @formula_name = 'IF'
				BEGIN
					SET @final_html = @formula_html + '(''__' + @f_id + '_arg1__'', __' + @f_id + '_arg2__, __' + @f_id + '_arg3__)'
				END
				ELSE IF @formula_name = 'Round' OR @formula_name = 'CEILING' OR @formula_name = 'SQRT'
				BEGIN
					SET @final_html = @formula_html + '(__' + @f_id + '_arg1__)'
				END
			END
		END

		/* The formula and formula_category is inserted into #temp_fb_html */
		INSERT INTO @temp_fb_html (formula_breakdown_id, formula_html, formula_category)
		SELECT @formula_breakdown_id, @final_html, @formula_category

		FETCH NEXT FROM formula_cursor 
		INTO @formula_breakdown_id
	END 
	CLOSE formula_cursor;
	DEALLOCATE formula_cursor;
	/* formula_cursor ends */

	/* Finding the levels, parents_levels and arguments levels and inserting into temp table */ 
	INSERT INTO @temp_fb_html_args (formula_breakdown_id, formula_html, formula_category, arg_no_for_next_func, level_func_sno, parent_level_func_sno)
	SELECT	tmp.formula_breakdown_id, 
			tmp.formula_html, 
			tmp.formula_category, 
			fb.arg_no_for_next_func, 
			fb.level_func_sno, 
			fb.parent_level_func_sno 
	FROM @temp_fb_html tmp
	INNER JOIN formula_breakdown fb ON tmp.formula_breakdown_id = fb.formula_breakdown_id

	/* Linking the function with arguments */ 
	INSERT INTO @temp_fb_html_args_plus ([p_breakdown_id], [p_formula_html], [p_formula_category], [p_arg_no_for_next_func], [p_level_func_sno], [p_parent_level_func_sno],
										   [c_breakdown_id], [c_formula_html], [c_formula_category], [c_arg_no_for_next_func], [c_level_func_sno], [c_parent_level_func_sno])
	SELECT	t1.formula_breakdown_id [p_breakdown_id],
			t1.formula_html [p_formula_html],
			t1.formula_category [p_formula_category],
			t1.arg_no_for_next_func [p_arg_no_for_next_func],
			t1.level_func_sno [p_level_func_sno],
			t1.parent_level_func_sno [p_parent_level_func_sno],
			t2.formula_breakdown_id [c_breakdown_id],
			t2.formula_html [c_formula_html],
			t2.formula_category [c_formula_category],
			t2.arg_no_for_next_func [c_arg_no_for_next_func],
			t2.level_func_sno [c_level_func_sno],
			t2.parent_level_func_sno [c_parent_level_func_sno]
	FROM @temp_fb_html_args t1
	LEFT JOIN @temp_fb_html_args t2 ON t1.level_func_sno = t2.parent_level_func_sno

	/*
	Description formula_plus_cursor
	- For the parameter formula and conditions, it will replace the __<breakdown_id>_arg<argument_number>__  with the argument matching the argument number.
	- Update the formula after the __<breakdown_id>_arg<argument_number>__  is replaced.
	*/
	DECLARE @c_breakdown_id INT
	DECLARE @p_breakdown_id INT
	DECLARE @p_formula_category CHAR(1)
	DECLARE @p_formula_html VARCHAR(8000)
	DECLARE @c_formula_html VARCHAR(8000)
	DECLARE @c_arg_no_for_next_func INT
	DECLARE @count INT = 1

	DECLARE formula_plus_cursor CURSOR FOR 
	SELECT c_breakdown_id, p_breakdown_id, p_formula_category, p_formula_html, c_formula_html, c_arg_no_for_next_func FROM @temp_fb_html_args_plus
	
	OPEN formula_plus_cursor
	FETCH NEXT FROM formula_plus_cursor 
	INTO @c_breakdown_id, @p_breakdown_id, @p_formula_category, @p_formula_html, @c_formula_html, @c_arg_no_for_next_func

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @f_id = CAST(@p_breakdown_id AS VARCHAR)
		
		SET @p_formula_html = REPLACE(@p_formula_html, '__' + @f_id + '_arg' + CAST(ISNULL(@c_arg_no_for_next_func,'') AS VARCHAR) + '__', ISNULL(@c_formula_html,''))
		
		UPDATE @temp_fb_html_args_plus
		SET p_formula_html = @p_formula_html
		WHERE p_breakdown_id =  @p_breakdown_id

		UPDATE @temp_fb_html_args_plus
		SET c_formula_html = @p_formula_html
		WHERE c_breakdown_id =  @p_breakdown_id
		
		FETCH NEXT FROM formula_plus_cursor 
		INTO @c_breakdown_id, @p_breakdown_id, @p_formula_category, @p_formula_html, @c_formula_html, @c_arg_no_for_next_func

		UPDATE @temp_fb_html_args_plus
		SET row_id = @count
		WHERE p_breakdown_id = @p_breakdown_id

		SET @count = @count+1

		--SELECT * FROM @temp_fb_html_args_plus
	END 
	CLOSE formula_plus_cursor;
	DEALLOCATE formula_plus_cursor;

	DECLARE @return_html VARCHAR(8000)
	SET @return_html = (SELECT TOP(1) p_formula_html FROM @temp_fb_html_args_plus
						ORDER BY row_id desc)
	
	
	/*
	Description replace_cursor
	- Replace the parameter argument with NULL
	- If argument has value then it is replaced in upper cursor, so remaining are made null here.
	*/
	DECLARE replace_cursor CURSOR FOR 
	SELECT p_breakdown_id FROM @temp_fb_html_args_plus
	
	OPEN replace_cursor
	FETCH NEXT FROM replace_cursor 
	INTO @p_breakdown_id

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @f_id = CAST(@p_breakdown_id AS VARCHAR)
		SELECT @return_html =	REPLACE(
									REPLACE(
										REPLACE(

											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(
																REPLACE(
																	REPLACE(
																		REPLACE(
																			REPLACE(@return_html, '__' + @f_id + '_arg12__', 'NULL'), 
																			'__' + @f_id + '_arg11__', 'NULL'), 
																		'__' + @f_id + '_arg10__', 'NULL'), 
																	'__' + @f_id + '_arg9__', 'NULL'), 
																'__' + @f_id + '_arg8__', 'NULL'), 
															'__' + @f_id + '_arg7__', 'NULL'),
														 '__' + @f_id + '_arg6__', 'NULL'),
													'__' + @f_id + '_arg5__', 'NULL'),
												'__' + @f_id + '_arg4__', 'NULL'),
											'__' + @f_id + '_arg3__', 'NULL'),
										'__' + @f_id + '_arg2__', 'NULL'),
								'__' + @f_id + '_arg1__', 'NULL')

		FETCH NEXT FROM replace_cursor 
		INTO @p_breakdown_id
	END 
	CLOSE replace_cursor;
	DEALLOCATE replace_cursor;

	RETURN @return_html
END