IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_rfx_run_sql_paging]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rfx_run_sql_paging]
GO
/****** Object:  StoredProcedure [dbo].[spa_rfx_run_sql_paging]    Script Date: 09/07/2012 14:31:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---- ============================================================================================================================
---- Create date: 2012-09-06 14:46
---- Author : ssingh@pioneersolutionsglobal.com
---- Description: Pagiing page for Builds a runnable SQL query  
               
----Params:
----@dataset_paramset_id	INT			 : Dataset Id of a parameter
----@criteria				VARCHAR(MAX) : parmater with their values
----@process_id			VARCHAR(200) : Process ID  
----@page_size			INT 		 : Number of rows to display
----@page_no				INT 		 : page number
----@display_type			CHAR(1)		 : t = Tabular Display, c = Chart Display 
---- ============================================================================================================================

CREATE PROCEDURE [dbo].[spa_rfx_run_sql_paging]
	@dataset_paramset_id	INT
    , @criteria				VARCHAR(MAX) = NULL
    , @process_id			VARCHAR(200) = NULL 
	, @page_size			INT 		 = NULL
	, @page_no				INT 		 = NULL
	, @display_type			CHAR(1)		 = 't' 
AS
/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
 DECLARE
 	@dataset_paramset_id	INT
    , @criteria				VARCHAR(MAX)
    , @process_id			VARCHAR(200)
	, @page_size			INT 		
	, @page_no				INT 		
	, @display_type			CHAR(1)		
	
	SET @dataset_paramset_id	= 2
	--SET @criteria	= 'source_deal_header_id = 3212,term_start= 2010-01-01,2_term_start = 2016-12-31,source_system_id = 2,physical_financial_flag =''p'' '
	SET @criteria = 'source_counterparty_id = NULL'
	SET @process_id	= '2C71F444_5192_43D5_83E5_FDBFE5C66198'
	--SET @process_id		= NULL
	SET @page_size		= 27	
	SET @page_no		= 1
	SET @display_type   = 'c' 
--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/
BEGIN

	DECLARE @user_login_id VARCHAR(50), @tempTable VARCHAR(300), @flag CHAR(1)
	DECLARE @sqlStmt VARCHAR(5000)

	SET @user_login_id = dbo.FNADBUser()

	IF @process_id IS NULL
	BEGIN
		SET @flag = 'i'
		SET @process_id = dbo.FNAGetNewID()
		exec spa_print @process_id
	END
	
	SET @tempTable = dbo.FNAProcessTableName('paging_temp_Run_Report', @user_login_id, @process_id)

	IF @flag = 'i'
	BEGIN
		EXEC spa_print @criteria
		SET @sqlStmt = 'EXEC  spa_rfx_run_sql ' +
			CAST(@dataset_paramset_id AS VARCHAR) + ',' + 
   			dbo.FNASingleQuote(REPLACE(ISNULL(@criteria, ''), '''', '''''')) + ',' +   
			dbo.FNASingleQuote(@tempTable) + ',' +
			dbo.FNASingleQuote(@display_type) + ',' +
			dbo.FNASingleQuote(@process_id)  
		
		exec spa_print @sqlStmt
		EXEC(@sqlStmt)

		--don't add sno column, as it has already been added
		--EXEC('ALTER TABLE ' + @tempTable + ' ADD sno int IDENTITY(1,1)')
		SET @sqlStmt = 'SELECT COUNT(*) TotalRow, ''' + @process_id + ''' process_id  FROM ' + @tempTable
		EXEC(@sqlStmt)
	END
	ELSE
	BEGIN
		DECLARE @row_to INT, @row_from INT
		SET @row_to = @page_no * @page_size
		IF @page_no > 1 
			SET @row_from = ((@page_no - 1) * @page_size) + 1
		ELSE
			SET @row_from = @page_no
	END

	DECLARE @cols VARCHAR(8000)	
	SELECT @cols = COALESCE(@cols + ',[' + [name] + ']', '[' + [name] + ']')  
	FROM adiha_process.sys.columns WITH(NOLOCK)
	WHERE [OBJECT_ID] = OBJECT_ID(@tempTable) AND [name] <> 'sno'
	ORDER BY column_id	
	
	SET @sqlStmt = 'SELECT ' + @cols + '	
		FROM ' + @tempTable + ' WHERE sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND '
		+ CAST(@row_to AS VARCHAR)+ ' ORDER BY sno ASC'

	--print @sqlStmt
	EXEC(@sqlStmt)

END

GO
