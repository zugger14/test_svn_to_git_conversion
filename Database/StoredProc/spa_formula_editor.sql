/****** Object:  StoredProcedure [dbo].[spa_formula_editor]    Script Date: 06/07/2012 01:18:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_formula_editor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_formula_editor]
GO

/****** Object:  StoredProcedure [dbo].[spa_formula_editor]    Script Date: 06/07/2012 01:11:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_formula_editor]
	@flag CHAR(1),
	@formula_id INT = NULL,
	@formula AS VARCHAR(8000) = NULL,
	@formula_type AS CHAR(1) = 'd',
	@formula_name VARCHAR(200) = NULL,
	@system_defined CHAR(1) = NULL,
	@static_value_id INT = NULL,
	@template CHAR(1) = NULL,
	@formula_xmlValue VARCHAR(MAX) = NULL,
	@formula_group_id INT = NULL,
	@sequence_number INT = NULL,
	@formula_nested_id INT = NULL,
	@formula_source_type CHAR(1) = NULL,  --Functions = 'f' and User Defined Query = 'u'
	@udf_query VARCHAR(MAX) = NULL,
	@formula_html VARCHAR(MAX) = NULL,
	@del_formula_ids VARCHAR(MAX) = NULL
AS

/*-------------------Debug Section----------------------
DECLARE @flag CHAR(1),
		@formula_id INT = NULL,
		@formula AS VARCHAR(8000) = NULL,
		@formula_type AS CHAR(1) = 'd',
		@formula_name VARCHAR(200) = NULL,
		@system_defined CHAR(1) = NULL,
		@static_value_id INT = NULL,
		@template CHAR(1) = NULL,
		@formula_xmlValue VARCHAR(MAX) = NULL,
		@formula_group_id INT = NULL,
		@sequence_number INT = NULL,
		@formula_nested_id INT = NULL,
		@formula_source_type CHAR(1) = NULL,  --Functions = 'f' and User Defined Query = 'u'
		@udf_query VARCHAR(MAX) = NULL,
		@formula_html VARCHAR(MAX) = NULL
SELECT @flag='v',@formula='AveragePrice(GetLogicalValue(51,''Radiha_spaceK''),304625,980)adiha_spaceadiha_addadiha_space1'
--------------------------------------------------------*/
SET NOCOUNT ON

DECLARE @str_formula VARCHAR(8000)
DECLARE @sql VARCHAR(MAX)
DECLARE @count INT
DECLARE @url VARCHAR(MAX)
DECLARE @user_name VARCHAR(100),
	    @process_id	VARCHAR(200),
		@process_table VARCHAR(300)
--DECLARE @formula_hash_identifier VARCHAR(128)
--SET @formula_hash_identifier = dbo.FNAGetNewID()
SET @user_name = dbo.fnadbuser()
SET @url = './dev/formula.nested.php?__user_name__=' + @user_name
SET @udf_query = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@udf_query,'adiha_add','+'),'adiha_lessthan','<'),'adiha_greaterthan','>'),'adiha_minus','-'), 'adiha_space', ' ')
IF @formula_group_id = ''
	SET @formula_group_id = NULL

IF @flag='a'
BEGIN
	SET @process_id	= dbo.FNAGetNewId()
	SET @process_table = dbo.FNAProcessTableName('formula_editor', @user_name, @process_id)
	EXEC spa_resolve_function_parameter @flag = 's',@process_id = @process_id, @formula_id = @formula_id, @formula_name = @formula_name
	SET @sql = 'SELECT fe.formula_id,
	       CASE 
							WHEN fe.formula_source_type = ''u'' THEN dbo.FNAFormulaFormatMaxString(fes.formula_sql, ''c'')
							ELSE REPLACE(dbo.FNAFormulaFormatMaxString(fe.formula, ''c''),''<'',''&lt;'')
	       END AS formula,
	       CASE 
							WHEN fe.formula_source_type = ''u'' THEN dbo.FNAFormulaFormatMaxString(fes.formula_sql, ''c'')
							ELSE REPLACE(temp.formula_name,''<'',''&lt;'')
	       END AS formulatext,
	       fe.formula_name,
	       fe.static_value_id,
	       fe.istemplate,
	       fe.formula_source_type,
	       ISNULL(fe.formula_html, dbo.FNAFormulaHtml(fe.formula_id))
		   --dbo.FNAFormulaHtml(fe.formula_id)
	FROM   formula_editor fe
				INNER JOIN '+ @process_table + ' temp
						ON temp.formula_id = fe.formula_id
	       LEFT JOIN formula_editor_sql fes
	            ON  fes.formula_id = fe.formula_id
				WHERE  fe.formula_id = ' + CAST(@formula_id AS VARCHAR(20)) + ' 
	'
	EXEC(@sql)

END

--ELSE IF @flag='z' --Use this flag to get the formula tooltip for the deal grid.
--BEGIN
	
--	SELECT 'Success'		AS [ErrorCode],
--		   'Formula'	AS [Module],
--		   'spa_formula_editor'	AS [Area],
--		   formula_id	AS [Status],
--		   'Successfully.'   AS [Message],
--		   dbo.FNAFormulaFormatMaxString(formula, 'r') AS [Recommendation]
--		FROM   formula_editor
--		WHERE  formula_id = @formula_id
	

--END 


ELSE IF @flag='s'
BEGIN
	 
		SET @process_id	= dbo.FNAGetNewId()
		SET @process_table = dbo.FNAProcessTableName('formula_editor', @user_name, @process_id)
		EXEC spa_resolve_function_parameter @flag = 's',@process_id = @process_id, @formula_id = @formula_id, @formula_name = @formula_name, @formula_type = @formula_type
		SET @sql = '
					SELECT DISTINCT fe.formula_id [formula_id], fe.formula_name [formula_name],
					REPLACE(REPLACE(REPLACE((CASE WHEN fe.formula_type = ''n'' THEN dbo.FNAHyperLink(10211015,''Nested Formula'',fe.formula_id, -1)
					 +''</a>''  ELSE temp.formula_name END ),'''''''',''<>''),''><'',''''),''<>'','''''''') [formula],
					REPLACE(REPLACE(REPLACE(dbo.FNAFormulaFormatMaxString(fe.formula, ''c''),'''''''',''<>''),''><'',''''),''<>'','''''''') AS [formula_c], fe.formula_type [formula_type] 
					FROM   formula_editor fe
					INNER JOIN '+ @process_table + ' temp
						ON temp.formula_id = fe.formula_id
						LEFT JOIN formula_nested fn
								ON  fe.formula_id = fn.formula_id
					WHERE 1=1' --fe.formula_type = ''d'' '

		
	IF @formula_type = 'n' 
		SET @sql = @sql + ' AND fn.formula_id IS NULL'
	IF @formula_type = 'b'
		SET @sql = @sql + ' AND (istemplate =''y'' OR (fn.formula_id IS NULL AND istemplate is NULL))'
	IF @formula_id is not null
		set @sql = @sql + ' and fe.formula_id= ' +cASt(@formula_id AS VARCHAR)
	IF @formula_name is not null and CHARindex('%',@formula_name) = 0
		set @sql = @sql + ' and formula_name = ''' + @formula_name+''''
	ELSE IF @formula_name is not null and CHARindex('%',@formula_name) = 1 OR CHARindex('%',@formula_name,len(@formula_name)) = len(@formula_name)
		set @sql = @sql + ' and formula_name like ''' + @formula_name +''''
	ELSE IF @formula_name is not null and CHARindex('%',@formula_name,len(@formula_name)) = len(@formula_name)
	and CHARindex('%',@formula_name) = 1
		set @sql = @sql + ' and formula_name like ''' + @formula_name + ''''
	
	IF @formula is not null and CHARindex('%',@formula) = 0
		set @sql = @sql + ' and dbo.FNAFormulaFormatMaxString(formula,''r'') = ''' + @formula + ''''
	ELSE IF @formula is not null and CHARindex('%',@formula) = 1 OR CHARindex('%',@formula,len(@formula)) = len(@formula)
		set @sql = @sql + ' and dbo.FNAFormulaFormatMaxString(formula,''r'') like ''' + @formula + ''''
	ELSE IF @formula is not null and CHARindex('%',@formula,len(@formula)) = len(@formula) and  CHARindex('%',@formula) = 1
		set @sql = @sql + ' and dbo.FNAFormulaFormatMaxString(formula,''r'') like ''' + @formula + ''''

	IF @template IS NOT NULL
		SET @sql = @sql + ' AND istemplate ='''+ @template+''''
	IF @formula_type <> 'b' AND @formula_type = 't'
		SET @sql = @sql + ' AND istemplate =''y'''
	ELSE IF @formula_type <> 'b' AND @formula_type = 'n'
		SET @sql = @sql + ' AND istemplate is NULL'	
	IF @formula_type = 'b'
		SET @sql = @sql + ' AND fe.formula_type <> ''n'''
	--SET @sql = @sql + ' WHERE fe.formula NOT LIKE ''%FNAChannel%'' OR fe.formula IS null'
	--PRINT @sql
	exec(@sql)

END
ELSE IF @flag='v' 
BEGIN
	 -- Just to pASs the syntax check
	set @str_formula = @formula
--	set @str_formula = replace(@formula,'ContractValue','1')
	SET @str_formula = REPLACE(@str_formula, 'ActualVolume()', '1')
	SET @str_formula = REPLACE(@str_formula, 'BestAvailableVolume()', '1')
	SET @str_formula = REPLACE(@str_formula, 'ScheduleVolume()', '1')
	set @str_formula = replace(@str_formula,'SumVolume()','1')
	set @str_formula = replace(@str_formula,'OnPeakvolume()','1')
	set @str_formula = replace(@str_formula,'OffpeakVolume()','1')	
	set @str_formula = replace(@str_formula,'YTDVolume()','1')
	set @str_formula = replace(@str_formula,'Volume()','1')
	set @str_formula = replace(@str_formula,'OnPeakPeriodhour()','1')
	set @str_formula = replace(@str_formula,'OffPeakPeriodhour()','1')
	set @str_formula = replace(@str_formula,'OnPeakMxHour()','1')
	set @str_formula = replace(@str_formula,'OffPeakMxHour()','1')
	set @str_formula = replace(@str_formula,'TotalPeriodhour()','1')
	set @str_formula = replace(@str_formula,'TotalMxhour()','1')

	--PRINT @str_formula
	SET @str_formula =  dbo.[FNAFormulaResolveParamSeperator](@str_formula, 's');
	set @str_formula=dbo.FNAFormulaFormatMaxString(@str_formula,'d')
	--declare @index INT
	--SET @index = CHARINDEX('dbo',@str_formula) -1
	--PRINT (@index)
	--set @str_formula= RIGHT(@str_formula,LEN(@str_formula)-@index)
	--PRINT @str_formula
	
--	IF (SELECT LEFT(@str_formula,10))='dbo.FNARow'
--	BEGIN
--		IF (SELECT ISNUMERIC(REPLACE(REPLACE(REPLACE(@str_formula,'dbo.FNARow',''),')',''),'(',''))) <> 1
--		BEGIN 			
--		Exec spa_ErrorHandler -1, "Formula", 
--					"spa_formula_editor", "DB Error", 
--					"Invalid Syntax.", ''
--		RETURN
--		END	
--	END 

	SET @str_formula = REPLACE(@str_formula, 'adiha_space', ' ')
	-- replacing '-' by '+' to avoid divide by zero error	
	SET @str_formula = REPLACE (@str_formula, '-', '+')
	
	--PRINT @str_formula
	BEGIN TRY
		EXEC spa_resolve_function_parameter @flag='c',@tsql = @str_formula
		Exec spa_ErrorHandler 0, "Formula", 
					"spa_formula_editor", "DB Success", 
					"Valid Syntax.", ''
	END TRY
	BEGIN CATCH
		Exec spa_ErrorHandler -1, "Formula", 
					"spa_formula_editor", "DB Error", 
					"Invalid Syntax.", ''
	END CATCH			
END
ELSE IF @flag='i'
BEGIN
	BEGIN TRY
	BEGIN tran	
		--IF EXISTS (SELECT 1 FROM formula_editor fe WHERE fe.formula_hash_identifier = @formula_hash_identifier)	
		--BEGIN
		--	EXEC spa_ErrorHandler 1,
		--	     'Formula',
		--	     'spa_formula_editor',
		--	     'DB Error',
		--	     'Error on formula. Can not insert duplicate formula hash identifier.',
		--	     ''
		--	   RETURN
		--END
		SET @formula =  dbo.[FNAFormulaResolveParamSeperator](@formula, 's');
		SET @str_formula = dbo.FNAFormulaFormatMaxString(@formula, 'd')
		
		INSERT formula_editor
		  (
		    formula,
		    formula_type,
		    formula_name,
		    system_defined,
		    static_value_id,
		    istemplate,
		    formula_source_type,
		    --formula_hash_identifier,
		    formula_html
		  )
		VALUES
		  (
		   -- CAST(@str_formula AS VARCHAR(500)),
		    @str_formula,
		    @formula_type,
		    @formula_name,
		    @system_defined,
		    @static_value_id,
		    @template,
		    @formula_source_type,
		    --@formula_hash_identifier,
		    @formula_html
		  )
		
				
		DECLARE @new_formula_id INT
		SET @new_formula_id = SCOPE_IDENTITY()
		
		IF @formula_source_type = 'u'
		BEGIN
			INSERT INTO formula_editor_sql
			  (
				formula_id,
				formula_sql
			  )
			VALUES
			  (
				@new_formula_id,
				@udf_query
			  )
		END 
		
		SET @process_id	= dbo.FNAGetNewId()
		SET @process_table = dbo.FNAProcessTableName('formula_editor', @user_name, @process_id)
		EXEC spa_resolve_function_parameter @flag = 's',@process_id = @process_id, @formula_id = @new_formula_id
		IF OBJECT_ID('tempdb..#temp_process_table_result') IS NOT NULL
				DROP TABLE #temp_process_table_result
		CREATE TABLE #temp_process_table_result(
			formula_name VARCHAR(1000) COLLATE DATABASE_DEFAULT
		)
		EXEC ('INSERT INTO #temp_process_table_result(formula_name)
			   SELECT formula_name FROM ' + @process_table + '			
		      ')
		SELECT @str_formula = formula_name FROM #temp_process_table_result
		--SET @str_formula = dbo.FNAFormulaFormatMaxString(@str_formula, 'r')
		
		EXEC spa_formula_breakdown @flag,@new_formula_id,@sequence_number,@formula_xmlValue,@formula_group_id,@formula_nested_id
		
		SELECT @count = COUNT(*) FROM formula_breakdown fb WHERE fb.formula_id = @new_formula_id AND fb.arg_no_for_next_func IS NULL GROUP BY fb.nested_id HAVING COUNT(ISNULL(fb.nested_id,0)) > 1;

		--SELECT @count
		IF ISNULL(@count, 1) > 1
		BEGIN
			EXEC spa_ErrorHandler 1,
			     'Formula',
			     'spa_formula_editor',
			     'DB Error',
			     'Error on formula. Please check the brackets in the fromula.',
			     ''
			
			ROLLBACK TRAN 
			RETURN
		END	
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0,
			     "Formula",
			     "spa_formula_editor",
			     @new_formula_id,
			     "Changes have been saved successfully.",
			     @str_formula
			
			 
		END	
		COMMIT TRAN
			
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler 1,
		     "Formula",
		     "spa_formula_editor",
		     "DB Error",
		     "Fail to save formula.",
		     ''
		
		ROLLBACK TRAN 
		
		RETURN
	END CATCH 
			
END
ELSE IF @flag='u'
BEGIN
	BEGIN TRY
	BEGIN TRAN	
	
		DECLARE @report_position_process_id VARCHAR(100)
		DECLARE @user_login_id VARCHAR(100)
		DECLARE @job_name VARCHAR(100)
		
		SET @formula =  dbo.[FNAFormulaResolveParamSeperator](@formula, 's');
		set @str_formula=dbo.FNAFormulaFormatMaxString(@formula,'d')
		SET @user_login_id=dbo.FNADBUser()

		SET @str_formula  = REPLACE(REPLACE(REPLACE(@str_formula,'''','<>'),'><',''),'<>','''')
		
		UPDATE formula_editor
		SET    formula = @str_formula,
		       formula_name = @formula_name,
		       system_defined = @system_defined,
		       static_value_id = @static_value_id,
		       istemplate = @template,
		       formula_source_type = @formula_source_type,
		       formula_html = @formula_html
		WHERE  formula_id = @formula_id
		
		SET @str_formula = dbo.FNAFormulaFormatMaxString(@str_formula, 'r') 
		
		IF @formula_source_type = 'u'
		BEGIN
			UPDATE formula_editor_sql
			SET formula_sql = @udf_query
			WHERE formula_id = @formula_id
			
			INSERT INTO formula_editor_sql(formula_id, formula_sql)
			SELECT fe.formula_id, @udf_query
			FROM formula_editor fe
			LEFT JOIN formula_editor_sql fes ON  fes.formula_id = fe.formula_id 
			WHERE fes.formula_sql_id IS NULL AND fe.formula_id = @formula_id
		END
		ELSE 
		BEGIN
			DELETE fes 
			FROM formula_editor_sql fes WHERE fes.formula_id = @formula_id
		END 
		
		-- breakdown formula
		EXEC spa_formula_breakdown @flag,@formula_id,@sequence_number,@formula_xmlValue,@formula_group_id,@formula_nested_id
		
		DECLARE @report_position_deals VARCHAR(300)
		SET @report_position_process_id = REPLACE(newid(),'-','_')

		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@report_position_process_id)
		EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')
		
		SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id, action)
					SELECT DISTINCT source_deal_header_id,''f'' FROM source_deal_detail WHERE formula_id = ' + CAST(@formula_id AS VARCHAR)
					
		--PRINT @sql 
		EXEC (@sql)
		
		CREATE TABLE #handle_sp_return_update(
					[ErrorCode]	VARCHAR(100) COLLATE DATABASE_DEFAULT ,
					[Module]		VARCHAR(500) COLLATE DATABASE_DEFAULT ,
					[Area]		VARCHAR(100) COLLATE DATABASE_DEFAULT ,
					[Status]	VARCHAR(100) COLLATE DATABASE_DEFAULT ,
					[Message]	VARCHAR(500) COLLATE DATABASE_DEFAULT ,
					[RecommENDation] VARCHAR(500) COLLATE DATABASE_DEFAULT  	
				)		
				
		--PRINT 'EXEC spa_deal_position_breakdown ''u'',null,''' + @user_login_id+''',''' +@report_position_process_id+''''
		SET @sql = 'spa_deal_position_breakdown ''u'',null,''' + @user_login_id+''',''' +@report_position_process_id+''''
		SET @job_name = 'spa_deal_position_breakdown' + @report_position_process_id 
		EXEC spa_run_sp_AS_job @job_name, @sql, 'spa_deal_position_breakdown', @user_login_id
		--INSERT INTO #handle_sp_return_update EXEC spa_deal_position_breakdown 'u', NULL, @user_login_id,@report_position_process_id
		--IF EXISTS(SELECT 1 FROM #handle_sp_return_update WHERE [ErrorCode]='Error')
		--BEGIN
		--	DECLARE @msg_err VARCHAR(1000),@recom_err VARCHAR(1000)
		--	SELECT   @msg_err=[Message],	@recom_err=[RecommENDation] FROM #handle_sp_return_update WHERE [ErrorCode]='Error'
			
		--	EXEC spa_ErrorHandler -1,
		--			 'Source Deal Detail Table',
		--			 'spa_UpdateFromXml',
		--			 'DB Error',
		--			 @msg_err,
		--			 @recom_err	
		
		--	ROLLBACK TRAN
		
		--	RETURN
		--END	

		SET @sql = 'spa_update_deal_total_volume NULL,''' + CAST(@report_position_process_id AS VARCHAR(50)) + ''''
		SET @job_name = 'spa_update_deal_total_volume_' + @report_position_process_id 
		--EXEC spa_run_sp_AS_job @job_name, @sql, 'spa_update_deal_total_volume', @user_login_id
		
		SELECT @count = COUNT(*) 
		FROM formula_breakdown fb 
		WHERE fb.formula_id = @formula_id 
			AND fb.arg_no_for_next_func IS NULL 
			AND fb.nested_id IS NOT NULL
		GROUP BY fb.nested_id 
		HAVING COUNT(ISNULL(fb.nested_id,0)) > 1;

		--SELECT @count
		SET @process_id	= dbo.FNAGetNewId()
		SET @process_table = dbo.FNAProcessTableName('formula_editor', @user_name, @process_id)
		EXEC spa_resolve_function_parameter @flag = 's',@process_id = @process_id, @formula_id = @formula_id
		IF OBJECT_ID('tempdb..#temp_process_table_result1') IS NOT NULL
				DROP TABLE #temp_process_table_result1
		CREATE TABLE #temp_process_table_result1(
			formula_name VARCHAR(1000) COLLATE DATABASE_DEFAULT
		)
		EXEC ('INSERT INTO #temp_process_table_result1(formula_name)
			   SELECT formula_name FROM ' + @process_table + '			
		      ')
		SELECT @str_formula = formula_name FROM #temp_process_table_result1
		IF ISNULL(@count, 1) > 1
		BEGIN
			EXEC spa_ErrorHandler 1,
			     'Formula',
			     'spa_formula_editor',
			     'DB Error',
			     'Error on formula. Please check the brackets in the fromula.',
			     ''
			
			ROLLBACK TRAN 
			RETURN
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0,
				 "Formula",
				 "spa_formula_editor",
				 @formula_id,
				 "Changes have been saved successfully.",
				 @str_formula
		END	
		
	
		COMMIT TRAN 
	END TRY 
	BEGIN CATCH
		
		EXEC spa_ErrorHandler 1,
		     "Formula",
		     "spa_formula_editor",
		     "DB Error",
		     "Fail to update formula.",
		     ''
		
		ROLLBACK TRAN 
		
	END CATCH 
	
		
END
ELSE IF @flag='d'
BEGIN
	IF EXISTS(
		SELECT 1
		FROM formula_editor fe
		INNER JOIN source_price_curve_def spcd ON fe.formula_id = spcd.formula_id
		INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = fe.formula_id
	)
	BEGIN 
		EXEC spa_ErrorHandler -1, 'Formula Editor',
			'spa_formula_editor', 'DB Error',
			'The selected formula is in use and cannot be deleted.', ''
		RETURN
	END
	
	IF EXISTS(
		SELECT 1
		FROM formula_editor fe
		INNER JOIN source_deal_detail_template sddt ON fe.formula_id = sddt.formula
		INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = fe.formula_id
	)
	BEGIN 
		EXEC spa_ErrorHandler -1, 'Formula Editor',
			'spa_formula_editor', 'DB Error',
			'The selected formula is in use and cannot be deleted.', ''
		RETURN
	END 
	
	IF EXISTS(
		SELECT 1
		FROM formula_editor fe
		INNER JOIN source_deal_detail sdd ON fe.formula_id = sdd.formula_id
		INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = fe.formula_id
	)
	BEGIN 
		EXEC spa_ErrorHandler -1, 'Formula Editor',
			'spa_formula_editor', 'DB Error',
			'The selected formula is in use and cannot be deleted.', ''
		RETURN
	END 
		
	IF EXISTS(
		SELECT 1
		FROM formula_editor fe
		INNER JOIN contract_group_detail cgd ON fe.formula_id = cgd.formula_id
		INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = fe.formula_id
	)
	BEGIN 
		EXEC spa_ErrorHandler -1, 'Formula Editor',
			'spa_formula_editor', 'DB Error',
			'The selected formula is in use and cannot be deleted.', ''
		RETURN
	END 
	
	IF EXISTS(
		SELECT 1
		FROM formula_editor fe
		INNER JOIN user_defined_deal_fields_template uddft ON fe.formula_id = uddft.formula_id
		INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = fe.formula_id
	)
	BEGIN 
		EXEC spa_ErrorHandler -1, 'Formula Editor',
			'spa_formula_editor', 'DB Error',
			'The selected formula is in use and cannot be deleted.', ''
		RETURN
	END 
	
	IF EXISTS(
		SELECT 1
		FROM formula_editor fe
		INNER JOIN deal_transfer_mapping dtm ON fe.formula_id = dtm.formula_id
		INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = fe.formula_id
	)
	BEGIN 
		EXEC spa_ErrorHandler -1, 'Formula Editor',
			'spa_formula_editor', 'DB Error',
			'The selected formula is in use and cannot be deleted.', ''
		RETURN
	END 
	IF EXISTS(
		SELECT 1
		FROM formula_editor fe
		INNER JOIN  formula_nested fn ON fe.formula_id = fn.formula_id AND fe.istemplate = 'y'
		INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = fe.formula_id
	)
	BEGIN 
		EXEC spa_ErrorHandler -1, 'Formula Editor',
			'spa_formula_editor', 'DB Error',
			'The selected formula is in use and cannot be deleted.', ''
		RETURN
	END 
	IF EXISTS(
		SELECT 1
		FROM formula_editor fe
		INNER JOIN  formula_nested fn ON fe.formula_id = fn.time_bucket_formula_id
		INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = fe.formula_id)
	BEGIN 
		EXEC spa_ErrorHandler -1, 'Formula Editor',
			'spa_formula_editor', 'DB Error',
			'The selected formula is in use and cannot be deleted.', ''
		RETURN
	END

	DECLARE @id INT = 1,
			@count_ids INT = NULL
	
	IF OBJECT_ID(N'tempdb..#delete_lists') IS NOT NULL 
		DROP TABLE #delete_lists
			
	CREATE TABLE #delete_lists
	(
		id INT IDENTITY (1,1),
		formula_id INT
	)
		
	INSERT INTO #delete_lists
	(
		formula_id
	)
	SELECT a.item
	FROM dbo.FNASplit(@del_formula_ids,',') a
		
	SELECT @count_ids = COUNT(1) 
	FROM #delete_lists
		
	WHILE @count_ids >= @id
	BEGIN
		SELECT @formula_id = formula_id
		FROM #delete_lists
		WHERE id = @id

		EXEC spa_formula_breakdown 'd', @formula_id, @sequence_number, NULL, @formula_group_id

		--While terminationg condition
		SET @id += 1
	END

	BEGIN TRY
		BEGIN TRAN
			UPDATE sdd
			SET formula_id = NULL
			FROM source_deal_detail sdd
			INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = sdd.formula_id

			UPDATE cgd
			SET formula_id = NULL
			FROM contract_group_detail cgd
			INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = cgd.formula_id

			UPDATE rg
			SET rec_formula_id = NULL
			FROM rec_generator rg
			INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = rg.rec_formula_id

			UPDATE rg
			SET contract_formula_id = NULL
			FROM rec_generator rg
			INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = rg.contract_formula_id

			--Update deal_rec_properties set rec_formula_id=NULL where rec_formula_id=@formula_id

			UPDATE spcd
			SET formula_id = NULL
			FROM source_price_curve_def spcd
			INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = spcd.formula_id

			UPDATE sddt
			SET formula = NULL
			FROM source_deal_detail_template sddt
			INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = sddt.formula
	
			DELETE fes
			FROM formula_editor_sql fes
			INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = fes.formula_id

			DELETE fe
			FROM formula_editor fe
			INNER JOIN dbo.FNASplit(@del_formula_ids, ',') di ON di.item = fe.formula_id

		COMMIT TRAN

		EXEC spa_ErrorHandler 0, 'Formula Editor',
			'spa_formula_editor', 'Success',
			'Changes have been saved successfully.', @del_formula_ids
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

		EXEC spa_ErrorHandler @@ERROR, 'Formula Editor',
			'spa_formula_editor', 'DB Error',
			'Delete of Formula editor Data failed.', ''
	END CATCH
END
ELSE IF @flag = 't' --To show in tree
BEGIN
	SELECT	mfc.map_function_category_id [Formula Id], mfc.function_name AS [Formula],mfc.category_id [Category Id] ,sdv1.code AS [Category]
	FROM map_function_category mfc
	INNER JOIN static_data_value sdv1 ON sdv1.value_id = mfc.category_id 
	WHERE mfc.is_active = 1
	ORDER BY CASE WHEN sdv1.code <> 'Others' THEN sdv1.code ELSE 'zz' + sdv1.code END, mfc.function_name
END
ELSE IF @flag = 'r' --To show in tree when refreshed
BEGIN
	SET @sql = 'SELECT	mfc.map_function_category_id [Formula Id], 
						CASE WHEN mfc.function_name  = ''<'' THEN ''&lt;'' 
							--WHEN mfc.function_name  = ''<>'' THEN ''&neq;'' 
							--WHEN mfc.function_name  = ''='' THEN ''&eq;'' 
							WHEN mfc.function_name  = ''<='' THEN ''&le;'' 
							--WHEN mfc.function_name  = ''*'' THEN ''&mul;'' 
						ELSE mfc.function_name END AS [function_name],
						mfc.category_id [Category Id] ,sdv1.code AS [Category]
	INTO #temp_map_function_category
	FROM map_function_category mfc
	INNER JOIN static_data_value sdv1 ON sdv1.value_id = mfc.category_id 
	WHERE 1=1 AND mfc.is_active = 1 AND mfc.function_name IS NOT NULL 
	UNION
	SELECT ds.data_source_id,
		   ds.name,
		   106501,
		   ''User Defined Function''	 
	FROM data_source ds
	WHERE category = 106501
	
	SELECT [Formula Id],
		   [function_name] [Formula],
		   [Category Id],
		   [Category]
	FROM #temp_map_function_category tmfc
	'
	
	IF @formula != ''
	BEGIN
		SET @sql = @sql + ' AND tmfc.function_name LIKE ''%' + @formula + '%'''
	END
	SET @sql = @sql + ' ORDER BY CASE WHEN [Category] <> ''Others'' THEN [Category] ELSE ''zz'' + [Category] END, tmfc.function_name '
	EXEC(@sql)
END
ELSE IF @flag = 'w' --For dropdown in formula autocomplete
BEGIN
	--SELECT CASE WHEN sdv.code  = '<' THEN '&lt;'
	--			WHEN sdv.code  = '<>' THEN '&neq;' 
	--			WHEN sdv.code  = '=' THEN '&eq;'
	--			WHEN sdv.code  = '<=' THEN '&le;' 
	--			WHEN sdv.code  = '*' THEN '&mul;' 
	--		ELSE sdv.code END AS [Formula]
	--FROM static_data_value sdv WHERE sdv.type_id = 800
	
	SELECT mfc.function_name,mfc.category_id FROM map_function_category mfc
	WHERE
		mfc.function_name NOT IN ('(',')','*','/','+','-','<','<=','<>','=','>') AND mfc.is_active = 1 AND mfc.function_name IS NOT NULL
	UNION
	SELECT ds.name, 106501
	FROM data_source ds
	WHERE category = 106501
	ORDER by function_name
END
--ELSE IF @flag='g' -- For Refresh in formula builder grid
--BEGIN
	 
--		SET @sql = '
--					SELECT DISTINCT fe.formula_id [formula_id], fe.formula_name[formula_name],
--					(CASE WHEN fe.formula_type = ''n'' THEN dbo.FNAHyperLink(10211015,''Nested Formula'',fe.formula_id, -1)
--					 +''</a>''  ELSE REPLACE(dbo.FNAFormulaFormatMaxString(fe.formula, ''r''), '','', ''&comma;'') END ) [formula],
--					dbo.FNAFormulaFormatMaxString(fe.formula, ''c'') AS [formula_c], fe.formula_type [formula_type] 
--					FROM   formula_editor fe
--						LEFT JOIN formula_nested fn
--								ON  fe.formula_id = fn.formula_id
--					WHERE 1=1' --fe.formula_type = ''d'' '

		
--	IF @formula_type = 'n' 
--		SET @sql = @sql + ' AND fn.formula_id IS NULL'
--	IF @formula_type = 'b'
--		SET @sql = @sql + ' AND (istemplate =''y'' OR (fn.formula_id IS NULL AND istemplate is NULL))'
--	IF @formula_id is not null
--		set @sql = @sql + ' and fe.formula_id= ' +cASt(@formula_id AS VARCHAR)
--	IF @formula_name is not null and CHARindex('%',@formula_name) = 0
--		set @sql = @sql + ' and formula_name = ''' + @formula_name+''''
--	ELSE IF @formula_name is not null and CHARindex('%',@formula_name) = 1 OR CHARindex('%',@formula_name,len(@formula_name)) = len(@formula_name)
--		set @sql = @sql + ' and formula_name like ''' + @formula_name +''''
--	ELSE IF @formula_name is not null and CHARindex('%',@formula_name,len(@formula_name)) = len(@formula_name)
--	and CHARindex('%',@formula_name) = 1
--		set @sql = @sql + ' and formula_name like ''' + @formula_name + ''''
	
--	IF @formula is not null and CHARindex('%',@formula) = 0
--		set @sql = @sql + ' and dbo.FNAFormulaFormatMaxString(formula,''r'') = ''' + @formula + ''''
--	ELSE IF @formula is not null and CHARindex('%',@formula) = 1 OR CHARindex('%',@formula,len(@formula)) = len(@formula)
--		set @sql = @sql + ' and dbo.FNAFormulaFormatMaxString(formula,''r'') like ''' + @formula + ''''
--	ELSE IF @formula is not null and CHARindex('%',@formula,len(@formula)) = len(@formula) and  CHARindex('%',@formula) = 1
--		set @sql = @sql + ' and dbo.FNAFormulaFormatMaxString(formula,''r'') like ''' + @formula + ''''

--	IF @template IS NOT NULL
--		SET @sql = @sql + ' AND istemplate ='''+ @template+''''
--	IF @formula_type <> 'b' AND @formula_type = 't'
--		SET @sql = @sql + ' AND istemplate =''y'''
--	ELSE IF @formula_type <> 'b' AND @formula_type = 'n'
--		SET @sql = @sql + ' AND istemplate is NULL'	
--	--SET @sql = @sql + ' WHERE fe.formula NOT LIKE ''%FNAChannel%'' OR fe.formula IS null'
--	--PRINT @sql
--	exec(@sql)

--END

IF @flag = 'c'
BEGIN
	SELECT	dbo.FNAFormulaFormatMaxString(fe.formula, 'c') [formula_id],
		fn.description1 [formula_name], 
		dbo.FNAFormulaFormatMaxString(fe.formula, 'r') [formula], 
		cg.[contract_name] [formula_c],
		sdv.code [formula_type]
	FROM formula_editor fe
	LEFT JOIN formula_nested fn ON fe.formula_id = fn.formula_id
	LEFT JOIN contract_group_detail cgd ON fn.formula_group_id = cgd.formula_id
	INNER JOIN contract_group cg ON cgd.contract_id = cg.contract_id
	INNER JOIN static_data_value sdv ON sdv.value_id = cgd.invoice_line_item_id
	WHERE cgd.formula_id IS NOT NULL
	UNION ALL
	SELECT	dbo.FNAFormulaFormatMaxString(fe.formula, 'c') [formula_id],
		fn.description1 [formula_name], 
		dbo.FNAFormulaFormatMaxString(fe.formula, 'r') [formula], 
		cct.[contract_charge_desc] [formula_c],
		sdv.code [formula_type]
	FROM formula_editor fe
	LEFT JOIN formula_nested fn ON fe.formula_id = fn.formula_id
	LEFT JOIN contract_charge_type_detail cctd ON fn.formula_group_id = cctd.formula_id
	INNER JOIN contract_charge_type cct ON cct.contract_charge_type_id = cctd.contract_charge_type_id
	INNER JOIN static_data_value sdv ON sdv.value_id = cctd.invoice_line_item_id

END

IF @flag = 'e'
BEGIN
	SELECT DISTINCT fep.function_name 
	FROM formula_editor_parameter fep
	WHERE fep.function_name IS NOT NULL
	UNION
	SELECT ds.name 
	FROM data_source ds
	WHERE category = 106501

END
/************************************* Object: 'spa_formula_editor' END *************************************/

IF @flag = 'x'
BEGIN
	SELECT DISTINCT fe.formula_id, 
		   CAST(fe.formula_id AS VARCHAR(20)) + COALESCE(' - ' + NULLIF(fe.formula_name, ''), 
		   SUBSTRING(CASE 
	            WHEN fe.formula_source_type = 'u' THEN ' - TSQL'
	            ELSE REPLACE(' - ' + dbo.FNAFormulaFormatMaxString(fe.formula, 'c'),'<','&lt;')
	       END, 0, 50), '') AS formula
	FROM formula_editor fe	
	INNER JOIN formula_breakdown fb ON fb.formula_id = fe.formula_id
	WHERE fe.istemplate = 'y'
END