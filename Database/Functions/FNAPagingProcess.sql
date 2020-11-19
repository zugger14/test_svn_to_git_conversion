/****** Object:  UserDefinedFunction [dbo].[FNAPagingProcess]    Script Date: 02/24/2011 18:17:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAPagingProcess]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAPagingProcess]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Create date: 2011-02-24
-- Description:	Return paging related strings like table name, data retrieval query from paging table
-- Params:
--	@flag
--		p - prepare concatenation string to append in select queries to populate paging table
--		s - prepare select query to retrieve data from paging table
--		t - prepare select query to retreive total rows from paging table
-- ===============================================================================================================
CREATE FUNCTION dbo.FNAPagingProcess 
(
	@flag CHAR(1),
	@process_id VARCHAR(50),
	@page_size INT,
	@page_no INT
)
RETURNS varchar(8000)
AS
BEGIN
	DECLARE @str VARCHAR(8000)
	DECLARE @temp_table_name VARCHAR(128)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @id_col_name VARCHAR(20)
	
	SET @id_col_name = 'row_id'
	SET @user_login_id = dbo.FNADBUser()
	SET @temp_table_name = dbo.FNAProcessTableName('batch_report', @user_login_id, @process_id)
	
	IF @flag = 'p' -- prepare concatenation string to append in select queries to populate paging table
	BEGIN
		SET @str = ', IDENTITY(INT, 1, 1) AS row_id INTO ' + @temp_table_name 
	END
	ELSE IF @flag = 's' -- prepare select query to retrieve data from paging table
	BEGIN
		DECLARE @row_to INT, @row_from INT  
		SET @row_to = @page_no * @page_size  
						 
		IF @page_no > 1
		   SET @row_from = ((@page_no -1) * @page_size) + 1
		ELSE
		   SET @row_from = @page_no			   
	   
	   SELECT @str = COALESCE(@str + ',' + QUOTENAME([name]), QUOTENAME([name]))
	   FROM adiha_process.sys.columns  WITH(NOLOCK)
	   WHERE [OBJECT_ID] = OBJECT_ID(@temp_table_name)
			  AND [name] <> @id_col_name
	   ORDER BY column_id  
		
	   SET @str = 'SELECT ' + @str + '  
					  FROM ' + @temp_table_name + '   
					  WHERE ' + @id_col_name + ' BETWEEN ' + CAST(@row_from AS VARCHAR(10)) + ' AND ' + CAST(@row_to AS VARCHAR(10))
	END
	ELSE IF @flag = 't' -- prepare select query to retreive total rows from paging table
	BEGIN
		SET @str = 'SELECT COUNT(*) TotalRow, ''' + @process_id + ''' process_id  FROM ' + @temp_table_name
	END

	RETURN @str
END
GO

