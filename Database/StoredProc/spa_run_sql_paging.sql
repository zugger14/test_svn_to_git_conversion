IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_sql_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_sql_paging]
GO
/****** Object:  StoredProcedure [dbo].[spa_run_sql_paging]    Script Date: 05/25/2009 14:31:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spa_run_sql_paging]
	@report_id int,
    @criteria varchar(max) = NULL,
    @process_id varchar(200) = NULL, 
	@page_size int = NULL,
	@page_no int = NULL
AS
BEGIN

	DECLARE @user_login_id varchar(50), @tempTable varchar(300), @flag char(1)
	DECLARE @sqlStmt varchar(5000)

	SET @user_login_id = dbo.FNADBUser()

	IF @process_id IS NULL
	BEGIN
		SET @flag = 'i'
		SET @process_id = REPLACE(NEWID(),'-','_')
		exec spa_print @process_id
	END
	
	SET @tempTable = dbo.FNAProcessTableName('paging_temp_Run_Report', @user_login_id, @process_id)

	IF @flag = 'i'
	BEGIN
		EXEC spa_print @criteria
		SET @sqlStmt = 'EXEC  spa_run_sql ' +
			CAST(@report_id AS varchar) + ',' + 
   			dbo.FNASingleQuote(REPLACE(ISNULL(@criteria, ''), '''', '''''')) + ',' +   
			dbo.FNASingleQuote(@tempTable)
		
		exec spa_print @sqlStmt
		EXEC(@sqlStmt)

		--don't add sno column, as it has already been added
		--EXEC('ALTER TABLE ' + @tempTable + ' ADD sno int IDENTITY(1,1)')
		SET @sqlStmt = 'SELECT COUNT(*) TotalRow, ''' + @process_id + ''' process_id  FROM ' + @tempTable
		EXEC(@sqlStmt)
	END
	ELSE
	BEGIN
		DECLARE @row_to int, @row_from int
		SET @row_to = @page_no * @page_size
		IF @page_no > 1 
			SET @row_from = ((@page_no - 1) * @page_size) + 1
		ELSE
			SET @row_from = @page_no
	END

	DECLARE @cols VARCHAR(8000)	
	SELECT @cols = COALESCE(@cols + ',[' + [name] + ']', '[' + [name] + ']')  
	FROM adiha_process.sys.columns 
	WHERE [object_id] = OBJECT_ID(@tempTable) AND [name] <> 'sno'
	ORDER BY column_id	
	
	SET @sqlStmt = 'SELECT ' + @cols + '	
		FROM ' + @tempTable + ' WHERE sno BETWEEN ' + CAST(@row_from as varchar) + ' AND '
		+ CAST(@row_to AS varchar)+ ' ORDER BY sno ASC'

	--print @sqlStmt
	EXEC(@sqlStmt)

END

GO
