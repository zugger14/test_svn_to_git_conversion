IF OBJECT_ID(N'spa_run_sql_check2', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_run_sql_check2]
 GO 

--exec spa_run_sql_check 'select  notes_subject [Notes] from vwApplicationNotes where   content_type=''@content_type'' Internal_type_value_id=''@Internal_type_value_id''','content_type=''1'' and internal_type_value_id=''21'''
CREATE PROCEDURE [dbo].[spa_run_sql_check2]
	@sql_stmt VARCHAR(MAX),
	@criteria VARCHAR(5000) = NULL,
	@vw_table_name VARCHAR(100) = NULL
AS
	--declare @st varchar(5000)
	--declare @st2 varchar(5000)
	--		select @st= report_sql_statement from Report_record where report_id=@report_id 
	DECLARE @next_param       VARCHAR(1000)
	DECLARE @value            VARCHAR(1000)
	DECLARE @parameter        VARCHAR(1000)
	DECLARE @index_equal      INT 
	DECLARE @str_batch_table  VARCHAR(MAX)
	
	
	-- Code from spa_execute_query --------------------------------------
	DECLARE @type             CHAR(1)
	
	SET @sql_stmt = LTRIM(@sql_stmt)
	SET @type = SUBSTRING(@sql_stmt, 1, 1)
	
	-- if the query string starts with a [, then parse into a table first
	IF @type = '['
	BEGIN
	    SET @sql_stmt = [dbo].[FNAParseStringIntoTable](@sql_stmt)
	END
	----------------------------------------------------------------------
	
	
	--set @criteria = 'content_type=abc,internal_type_value_id=21'
	--set @sql = 'select  notes_subject [Notes] from vwApplicationNotes where   content_type=''@content_type'' and Internal_type_value_id=''@Internal_type_value_id'''
	
	DECLARE @index       INT
	DECLARE @index_next  INT
	
	SET @index = 1
	SET @index_equal = 1
	SET @index_next = 1
	SET @criteria = REPLACE(@criteria, ' ', '') -- get rid of white spaces
	
	--select @formula
	--
	BEGIN TRY
		IF @criteria IS NOT NULL
		BEGIN
			WHILE (@index <> 0)
			BEGIN
				SET @index = CHARINDEX(',', @criteria, @index)
		        
				IF @index = 0
				BEGIN
					SET @next_param = @criteria
					SET @index_equal = CHARINDEX('=', @next_param, @index)
					SET @value = SUBSTRING(@next_param, @index_equal + 1, LEN(@next_param))
					SET @parameter = '@' + SUBSTRING(@next_param, 1, @index_equal -1)
					SET @sql_stmt = REPLACE(@sql_stmt, @parameter, @value)
					BREAK
				END
		        
		        
				SET @next_param = SUBSTRING(@criteria, 1, @index -1)
				SET @criteria = SUBSTRING(@criteria, @index + 1, LEN(@criteria))
		        
				SET @index_equal = CHARINDEX('=', @next_param, 1)
				SET @value = SUBSTRING(@next_param, @index_equal + 1, LEN(@next_param))
		        
				SET @parameter = '@' + SUBSTRING(@next_param, 1, @index_equal -1)
		        
				SET @sql_stmt = REPLACE(@sql_stmt, @parameter, @value)
		        
				SET @index = 1
			END
		END

		DECLARE @next_index INT
		SET @next_index = 0
		
		IF @sql_stmt IS NOT NULL
		BEGIN
			WHILE (@index <> 0)
			BEGIN
				SET @index = CHARINDEX('@', @sql_stmt, @next_index)
				IF @index = 0
					BREAK		
		        
				SET @next_index = CHARINDEX('''', @sql_stmt, @index)	
				SET @value = SUBSTRING(@sql_stmt, @index, @next_index -@index)
		        
				SET @sql_stmt = REPLACE(@sql_stmt, @value, '1900')
			END
		END
		
		IF CHARINDEX(' where ', @sql_stmt, 0) > 0
		BEGIN
			IF CHARINDEX('Group By', @sql_stmt, 0) > 0
				SET @sql_stmt = REPLACE(@sql_stmt, 'Group By', ' and 1=2 Group By')
			ELSE 
			IF CHARINDEX('Order By', @sql_stmt, 0) > 0
				SET @sql_stmt = REPLACE(@sql_stmt, 'Order By', ' and 1=2 Order By')
			ELSE
				SET @sql_stmt = @sql_stmt + ' and 1=2 '
		END
		ELSE
		BEGIN
			IF CHARINDEX('Group By', @sql_stmt, 0) > 0
				SET @sql_stmt = REPLACE(@sql_stmt, 'Group By', ' where 1=2 Group By')
			ELSE 
			IF CHARINDEX('Order By', @sql_stmt, 0) > 0
				SET @sql_stmt = REPLACE(@sql_stmt, 'Order By', ' and 1=2 Order By')
			ELSE
				SET @sql_stmt = @sql_stmt + ' where 1=2 '
		END
		
		DECLARE @vw_sql   VARCHAR(MAX),
				@sql_run  VARCHAR(MAX)
		
		IF @vw_table_name IS NOT NULL
		BEGIN
			SELECT @vw_sql = vw_sql
			FROM   report_writer_table
			WHERE  table_name = @vw_table_name
		    
			SET @sql_stmt = REPLACE(@sql_stmt, @vw_table_name, '(' + @vw_sql + ') vwSqlTable ')
		END
		
		EXEC spa_print @sql_stmt	
		EXEC (@sql_stmt)
		
		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'Report_record',
				 'spa_Report_record',
				 'Error',
				 'Error',
				 'Error'
		END
		    
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0,
				 'Report_record',
				 'spa_Report_record',
				 'Success',
				 'Report_record Inputs successfully inserted.',
				 'Success'
		END
			    
	END TRY
	
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
		     'Report_record',
		     'spa_Report_record',
		     'Error',
		     'Error',
		     'Error'
		
	END CATCH



















