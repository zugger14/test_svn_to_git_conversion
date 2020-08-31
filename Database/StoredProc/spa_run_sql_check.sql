IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_sql_check]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_sql_check]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec spa_run_sql_check 'select  notes_subject [Notes] from vwApplicationNotes where   content_type=''@content_type'' Internal_type_value_id=''@Internal_type_value_id''','content_type=''1'' and internal_type_value_id=''21'''
CREATE PROCEDURE [dbo].[spa_run_sql_check]
@sql_stmt nvarchar(max),
@criteria varchar(5000) = NULL,
@vw_table_name varchar(100) = NULL
AS
--declare @st varchar(5000)
--declare @st2 varchar(5000)
--		--select @st= report_sql_statement from Report_record where report_id=@report_id 
--declare @next_param  varchar(1000)
--declare @value varchar(1000)
--declare @parameter varchar(1000)
--declare @index_equal int 
--declare @str_batch_table varchar(max)
--
----set @criteria = 'content_type=abc,internal_type_value_id=21'
----set @sql = 'select  notes_subject [Notes] from vwApplicationNotes where   content_type=''@content_type'' and Internal_type_value_id=''@Internal_type_value_id'''
--
--declare @index int
--declare @index_next int
--
--set @index = 1
--set @index_equal = 1
--set @index_next = 1
--set @criteria = replace(@criteria, ' ', '') -- get rid of white spaces
--
--If @criteria IS NOT NULL
--BEGIN
--	while (@index <> 0)
--	BEGIN
--
--		set @index = CHARINDEX(',', @criteria, @index)
--		
--		If @index = 0 
--		begin
--			set @next_param = @criteria
--			set @index_equal = CHARINDEX('=', @next_param, @index)
--			set @value = SUBSTRING(@next_param, @index_equal+1, len(@next_param))
--			set @parameter = '@' + SUBSTRING(@next_param, 1, @index_equal-1)
--			set @sql_stmt = replace(@sql_stmt, @parameter, @value)
--			break
--		end
--
--
--		set @next_param = SUBSTRING(@criteria, 1, @index-1)
--		set @criteria = SUBSTRING(@criteria, @index+1, len(@criteria))
--
--		set @index_equal = CHARINDEX('=', @next_param, 1)
--		set @value = SUBSTRING(@next_param, @index_equal+1, len(@next_param))
--
--		set @parameter = '@' + SUBSTRING(@next_param, 1, @index_equal-1)
--
--		set @sql_stmt = replace(@sql_stmt, @parameter, @value)
--
--		set @index = 1 
--	END
--END
--
--
--declare @next_index int
--set @next_index=0
--If @sql_stmt IS NOT NULL
--BEGIN
--	while (@index <> 0)
--	BEGIN
--
--	
--		set @index = CHARINDEX('@', @sql_stmt, @next_index)
--		if @index=0
--		break		
--
--		set @next_index=CHARINDEX('''', @sql_stmt, @index)	
--		set @value=SUBSTRING(@sql_stmt, @index, @next_index-@index)
--	
--		set @sql_stmt=replace(@sql_stmt,@value,'1900')
--	
--	END
--END
--
--if charindex(' where ',@sql_stmt,0)>0
--	BEGIN	
--		if charindex('Group By',@sql_stmt,0)>0
--			set @sql_stmt=replace(@sql_stmt,'Group By',' and 1=2 Group By')
--		else if charindex('Order By',@sql_stmt,0)>0
--			set @sql_stmt=replace(@sql_stmt,'Order By',' and 1=2 Order By')
--		else
--			set @sql_stmt=@sql_stmt+' and 1=2 '
--	END
--else
--	BEGIN	
--		if charindex('Group By',@sql_stmt,0)>0
--			set @sql_stmt=replace(@sql_stmt,'Group By',' where 1=2 Group By')
--		else if charindex('Order By',@sql_stmt,0)>0
--			set @sql_stmt=replace(@sql_stmt,'Order By',' and 1=2 Order By')
--		else
--			set @sql_stmt=@sql_stmt+' where 1=2 '
--	
--	END
--
--declare @vw_sql varchar(max),@sql_run varchar(max)
--if @vw_table_name is not null
--BEGIN
--	select @vw_sql=vw_sql from report_writer_table where table_name=@vw_table_name
--	set @sql_stmt=replace(@sql_stmt,@vw_table_name,'('+ @vw_sql +') vwSqlTable ')
--END


DECLARE @sql_out varchar(MAX)
DECLARE @where_index int
DECLARE @loop_count smallint

SET @loop_count = 0

BEGIN TRY
	EXEC spa_build_rw_query NULL, @criteria, NULL, NULL, NULL, @vw_table_name, @sql_stmt, @sql_out OUTPUT

	--add a false condition 1=2 to prevent returning data as we just need validation
	--but not data. Another way to do it using SET FMTONLY ON, but it failed
	--in case of reports using temp table as turing FMTONLY ON doesn't create
	--any temp table and thus validation fails as that temp won't be recognized
	SET @sql_out = REPLACE(@sql_out, 'WHERE', 'WHERE 1 = 2 AND ')
	DECLARE @type CHAR(1)

	SET @type = SUBSTRING(@sql_stmt, 1, 1)
	
	-- if the query string starts with a [, then parse into a table first
	IF @type = '['
	BEGIN
	    SET @sql_out = [dbo].[FNAParseStringIntoTable](@sql_out)
		SET @sql_out = replace(replace(@sql_out,''' ''', '''') ,'''''','''') --Check for extra commas in the array at the end
	END
	
	--SET Value to ON to fix incorrect setting 'QUOTED_IDENTIFIER'
	SET @sql_out = 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + @sql_out

	EXEC spa_print '****************************************Final Check SQL Started****************************************:' 
		, @sql_out , '****************************************Final Check SQL Ended****************************************:'


	EXEC(@sql_out)
	
	EXEC spa_ErrorHandler 0,'spa_run_sql_check', 
		'spa_run_sql_check','Success', 
		'Report Writer query is valid.','Success'
END TRY
BEGIN CATCH
	DECLARE @error_msg VARCHAR(1000)
	SET @error_msg = ERROR_MESSAGE()

	EXEC spa_ErrorHandler -1, 'spa_run_sql_check', 
			'spa_run_sql_check', 'Error', 
			@error_msg, 'Error'
END CATCH












