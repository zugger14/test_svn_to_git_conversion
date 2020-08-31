/****** Object:  StoredProcedure [dbo].[spa_formula_nested]    Script Date: 03/31/2009 21:12:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_formula_nested]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_formula_nested]
/****** Object:  StoredProcedure [dbo].[spa_formula_nested]    Script Date: 03/31/2009 21:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_formula_nested]
	@flag CHAR(1),
	@formula_group_id INT=NULL,	
	@nested_id INT=NULL,
	@after_seq INT=NULL,
	@description1 VARCHAR(255)=NULL,
	@description2 VARCHAR(255)=NULL,
	@formula_id INT=NULL,
	@granularity INT=NULL,
	@include_item CHAR(1)=NULL,
    @show_value_id INT=NULL,	
	@uom_id INT=NULL,
	@rate_id INT =NULL,
	@total_id INT=NULL,
	@time_bucket_formula_id INT=NULL

AS

DECLARE @sql VARCHAR(8000)
DECLARE @tot_row INT
DECLARE @error_no INT
DECLARE @formula_nested_id INT

IF @flag='s' 
BEGIN
	DECLARE @process_id	VARCHAR(200) = dbo.FNAGetNewId()
	DECLARE @user_name VARCHAR(50) = dbo.FNADBUser()
	DECLARE @process_table	VARCHAR(300) = dbo.FNAProcessTableName('formula_editor', @user_name, @process_id)
	EXEC spa_resolve_function_parameter @flag = 's',@process_id = @process_id, @formula_group_id = @formula_group_id

	SET @sql = ' SELECT ID AS [Nested ID],sequence_order  [Row],Description1 AS [Description 1],Description2 AS [Description 2],
				REPLACE(temp.formula_name,''<'',''&lt;'')  Formula,
				ISNULL(sd.code, ''Not Defined'') [Granularity],include_item [Include in Invoice]	 
				, sd1.code AS [Fuel Type],
				--REPLACE(dbo.FNAFormulaFormat(fe1.formula, ''r''),''<'',''&lt;'')  Formula
				n.formula_id AS [Formula ID],
				n.formula_group_id [Formula Group ID],
				ID AS [Nested IDD],
				ISNULL(sd2.code, ''Not Defined'') AS [volume]
				FROM formula_nested n 
				JOIN formula_editor fe 
					ON n.formula_id=fe.formula_id
				INNER JOIN '+ @process_table + ' temp
						ON temp.formula_id = fe.formula_id
				LEFT JOIN static_data_value sd ON sd.value_id=n.granularity
				LEFT JOIN static_data_value sd1 ON sd1.value_id=fe.static_value_id
				LEFT JOIN static_data_value sd2 ON sd2.value_id = n.show_value_id
				LEFT JOIN formula_editor fe1 ON fe1.formula_id=n.time_bucket_formula_id
				WHERE formula_group_id=' + CAST(@formula_group_id AS VARCHAR(20)) + '
				ORDER BY sequence_order
	'
	EXEC(@sql)
END
ELSE IF @flag='a'
BEGIN
	SELECT id,sequence_order [#ID],Description1 AS [Description 1],Description2 AS [Description 2],n.formula_id,dbo.FNAFormulaFormat(fe.formula, 'r') Formula,
	granularity,include_item,show_value_id,uom_id,rate_id,total_id,fe.static_value_id,time_bucket_formula_id,dbo.FNAFormulaFormat(fe1.formula, 'r') tips
	 FROM formula_nested n JOIN
	formula_editor fe ON n.formula_id=fe.formula_id
	LEFT JOIN formula_editor fe1 ON fe1.formula_id=n.time_bucket_formula_id
	
	WHERE id=@nested_id

END
ELSE IF @flag='p'
BEGIN
	SELECT sequence_order,sequence_order [#ID] FROM formula_nested 
	WHERE formula_group_id=@formula_group_id 
	AND id NOT IN(@nested_id)
	--and id not in(case when @nested_id is not null then @nested_id else '' end)
	ORDER BY sequence_order	
	--order by id
END
ELSE IF @flag = 'i'
BEGIN
	
	IF @formula_group_id IS NULL
	BEGIN 
		INSERT formula_editor(formula_type)
		VALUES('n')
		SET @formula_group_id = SCOPE_IDENTITY()
	END
	--print 'after_seq: ' + cast(@after_seq as varchar)

	BEGIN TRY
		BEGIN TRAN

		-- if @after_seq is null, append formula at last
		IF (@after_seq IS NULL)
		BEGIN
			SELECT @after_seq = ISNULL(MAX(sequence_order), 0)
			FROM formula_nested
			WHERE formula_group_id = @formula_group_id 
		END
		ELSE
		BEGIN
			EXEC spa_formula_nested_update_sequence @flag, @formula_group_id, @nested_id, @after_seq			
		END
			
		INSERT INTO formula_nested(
						sequence_order,
						description1,
						description2,
						formula_id,
						formula_group_id,
						granularity,
						show_value_id,
						uom_id,	
						rate_id,
						total_id,
						time_bucket_formula_id
					)
					SELECT 
						@after_seq + 1,
						@description1,
						@description2,
						@formula_id,
						@formula_group_id,
						@granularity,
						@show_value_id,
						@uom_id,
						@rate_id,
						@total_id,
						@time_bucket_formula_id

		SET @formula_nested_id = SCOPE_IDENTITY()
		
		UPDATE fb
		SET
			fb.formula_id=@formula_group_id,
			fb.nested_id=@after_seq + 1,
			fb.formula_nested_id=@formula_nested_id
		FROM
			formula_breakdown fb
			--INNER JOIN formula_nested fn ON fn.formula_id=fb.formula_id
		WHERE
			(fb.formula_id=@formula_group_id OR fb.formula_id=@formula_id)
			AND ISNULL(NULLIF(fb.nested_id,0),-1)=-1
			
		EXEC spa_ErrorHandler 0, 'Formula Nested', 
			'spa_formula_nested', 'Success', 
			'Formula Saved successfully.',@formula_group_id

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

		SELECT @error_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @error_no, "Formula Nested", 
			"spa_formula_nested", "DB ERROR", 
			"ERROR Inserting Formula Nested Inputs.", ''
	END CATCH	

END
ELSE IF @flag = 'u'
BEGIN
	
	IF (@after_seq IS NULL)
	BEGIN
		SELECT @after_seq = ISNULL(MAX(sequence_order), 0)
		FROM formula_nested  
		WHERE formula_group_id = @formula_group_id
	END

	BEGIN TRY
		BEGIN TRAN
		
		DECLARE @old_seq INT
		
		SELECT @old_seq = sequence_order
		FROM formula_nested WHERE [ID] = @nested_id
		
		
		EXEC spa_formula_nested_update_sequence @flag, @formula_group_id, @nested_id, @after_seq, @old_seq

		UPDATE	 
			formula_nested
		SET	
			sequence_order = CASE WHEN @old_seq > @after_seq --moving upward
								THEN @after_seq + 1 
								ELSE @after_seq END, --moving downward
			description1 = @description1,
			description2 = @description2,
			formula_id = @formula_id,
			granularity = @granularity,
			include_item = @include_item,
			show_value_id = @show_value_id,
			uom_id = @uom_id,
			rate_id = @rate_id,
			total_id = @total_id,
			time_bucket_formula_id = @time_bucket_formula_id
		WHERE
			id = @nested_id
		
		
		UPDATE  a
			SET a.nested_id=b.sequence_order
		FROM
			dbo.formula_breakdown a
			INNER JOIN formula_nested b ON a.formula_nested_id=b.[id]
		WHERE
			b.formula_group_id=@formula_group_id
			
			
		EXEC spa_ErrorHandler 0, 'Formula Nested', 
		'spa_formula_nested', 'Success', 
		'Formula Nested Inputs successfully Updated.',''

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF  @@TRANCOUNT > 0
			ROLLBACK TRAN
		
		SELECT @error_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @error_no, 'Formula Nested', 
		'spa_formula_nested', 'DB Error', 
		'Error Updating Formula Nested Inputs.', ''
			
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		SELECT @old_seq = sequence_order
		FROM   formula_nested
		WHERE  [ID] = @nested_id

		EXEC spa_formula_nested_update_sequence @flag, @formula_group_id, @nested_id, @after_seq

		CREATE TABLE #deleted_formula (
			formula_id        INT,
			formula_group_id  INT,
			sequence_order    INT
		)

		DELETE 
		FROM  formula_nested 
		OUTPUT DELETED.formula_id,
			   DELETED.formula_group_id,
			   DELETED.sequence_order
		INTO #deleted_formula
		WHERE  id = @nested_id	

		DECLARE @temp CHAR(1)
		SELECT @temp = istemplate
		FROM   formula_editor fe
		INNER JOIN #deleted_formula d ON  fe.formula_id = d.formula_id	

		IF ISNULL(@temp, '') <> 'y'
		BEGIN
			DELETE fb
			FROM   formula_breakdown fb
			INNER JOIN #deleted_formula d ON  fb.formula_id = d.formula_group_id
			WHERE  fb.formula_nested_id = @nested_id
			
			DELETE fes
			FROM formula_editor_sql fes 
			INNER JOIN formula_editor fe ON fes.formula_id = fe.formula_id  
			INNER JOIN #deleted_formula d ON  fe.formula_id = d.formula_id	
			
			DELETE fe
			FROM   formula_editor fe
			INNER JOIN #deleted_formula d ON  fe.formula_id = d.formula_id	 
		END

		UPDATE a
		SET  a.nested_id = b.sequence_order
		FROM  dbo.formula_breakdown a
		INNER JOIN formula_nested b ON a.formula_nested_id = b.[id]
		WHERE  b.formula_group_id = @formula_group_id

		EXEC spa_ErrorHandler 0,
			 'Formula Nested',
			 'spa_formula_nested',
			 'Success',
			 'Formula Nested Inputs successfully Deleted.',
			 ''

		COMMIT TRAN
	END TRY
	BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	SELECT @error_no = ERROR_NUMBER()


	EXEC spa_ErrorHandler 1,
		 'Formula Nested',
		 'spa_formula_nested',
		 'Error',
		 'Error Deleting Formula Nested Inputs.',
		 ''
END CATCH
END

IF @flag = 'c' --to get id of data where data has undefined values 
BEGIN
	SELECT ID NestedID,sequence_order  [ROW],Description1,Description2,
		REPLACE(dbo.FNAFormulaFormat(fe.formula, 'r'),'<','&lt;')  Formula,
		sd.code [Granularity],include_item [INCLUDE IN Invoice]	 
		, sd1.code AS [Fuel TYPE],REPLACE(dbo.FNAFormulaFormat(fe1.formula, 'r'), '<', '&lt;') Formula
	FROM formula_nested n JOIN
	formula_editor fe ON n.formula_id=fe.formula_id
	LEFT JOIN static_data_value sd ON sd.value_id=n.granularity
	LEFT JOIN static_data_value sd1 ON sd1.value_id=fe.static_value_id
	LEFT JOIN formula_editor fe1 ON fe1.formula_id=n.time_bucket_formula_id
	WHERE formula_group_id=@formula_group_id
		AND fe.formula LIKE '%undefined%'
	ORDER BY sequence_order
END
GO