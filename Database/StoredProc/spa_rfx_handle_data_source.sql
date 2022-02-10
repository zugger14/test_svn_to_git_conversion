IF OBJECT_ID(N'dbo.spa_rfx_handle_data_source', N'P') IS NOT NULL
      DROP PROCEDURE dbo.spa_rfx_handle_data_source
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
 --============================================================================================================================
 --Create date: 2012-09-11
 --Author : ssingh@pioneersolutionsglobal.com
 --Description: Handles TSQL statements of data source and dumps the final select query into a process table. 
               
 --Params:
 --	@data_source_tsql			VARCHAR(MAX) : sql statement passed from the application 
 --	@data_source_alias			VARCHAR(50) : alias given to the sql statement 
 --	@criteria					VARCHAR(5000) : parameter and their values 
 --	@data_source_process_id		VARCHAR(50) : process_id passed  
 --	@handle_single_line_sql		BIT : 1 = must dump single line query , 0 = no need to dump single line query
 --	@validate					BIT	: 1 = validation required, 0 = validation not required
 -- @paramset_id				INT : Paramset ID 
 -- @with_criteria              CHAR(1) : Flag to identify whether call is with or without criteria
 --============================================================================================================================

CREATE PROCEDURE [dbo].[spa_rfx_handle_data_source]
	@data_source_tsql				VARCHAR(MAX)= NULL
	, @data_source_alias			VARCHAR(100) = NULL
	, @criteria						VARCHAR(MAX) = NULL
	, @data_source_process_id		VARCHAR(100) = NULL
	, @handle_single_line_sql		BIT = 0
	, @validate						BIT	= 0 --validate required?
	, @paramset_id					INT = NULL
	, @with_criteria                CHAR(1) = NULL
AS
/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
SET QUOTED_IDENTIFIER ON

DECLARE @contextinfo VARBINARY(128)= CONVERT(VARBINARY(128), 'DEBUG_MODE_ON');
SET CONTEXT_INFO @contextinfo;

 DECLARE @data_source_tsql				VARCHAR(MAX)= NULL
	, @data_source_alias			VARCHAR(100) = NULL
	, @criteria						VARCHAR(5000) = NULL
	, @data_source_process_id		VARCHAR(100) = NULL
	, @handle_single_line_sql		BIT = 0
	, @validate						BIT	= 0 --validate required?
	, @paramset_id					INT = NULL
	, @with_criteria                CHAR(1) = NULL
	
	
	SET @data_source_tsql = 
		'select * --[__batch_report__] from {st1}--replace seq by {st1}'	
		SET @data_source_alias = 	''		
	SET @criteria = 			''		
	SET @data_source_process_id = 	'D02E9D38_D4D0_4CB2_BA1C_41A065D2EE48'
	SET @handle_single_line_sql =	1	
	SET @validate = 			1		
	SET @paramset_id = 			null	
	SET @with_criteria =          'y'   

--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/
SET NOCOUNT ON;

DECLARE @from_index				INT
DECLARE @batch_index			INT
DECLARE @batch_identifier		VARCHAR(100)
DECLARE @view_index				INT
DECLARE @view_identifier		VARCHAR(100)
DECLARE @sql_batch_table		VARCHAR(5000)
DECLARE @error_msg				VARCHAR(1000)
DECLARE @sql NVARCHAR(MAX)
DECLARE @required_cols			VARCHAR(MAX)  
DECLARE @view_result_identifier varchar(100) = '<#PROCESS_TABLE#>'
DECLARE @view_result_identifier_index int = CHARINDEX(@view_result_identifier, @data_source_tsql)


SET @data_source_tsql = dbo.FNARemoveComment(@data_source_tsql)	


SET @batch_identifier = '--[__batch_report__]'	
SET @view_identifier = '{'
/******************************Datasource TSQL processing (if multiline) START*********************************/

/*
* IF the data source contains a refered view enclosed in {} and the criteria has not yet been processed (@with_criteria = n). 
* This execution block(@view_index > 0 AND @validate = 1)returns the refered view replaced with their actula view code along with the required parameters of the views.
* The return value is then returned to the php which process the criteria and recalls this sp with the with_criteria parameter set to 'y'
* along with the processed criteria
* In normal cases when the refered view is not used , In such case php will directly call this procedure with_criteria parameter set to 'y'.
* The  execution block(@view_index > 0 AND @validate = 0) replaces the refered view,executes the sql and dumps the data 
* to temp adiha_process table when neccesary.
*  */

SET @view_index = CHARINDEX(@view_identifier, @data_source_tsql)
EXEC spa_print 'View Index: ', @view_index

IF (@view_index > 0 AND @validate = 1) 
BEGIN 
	EXEC spa_print 'Validate only'
	EXEC spa_rfx_get_view_datasource_sql
		 @data_source_tsql
		 , @data_source_process_id
		 , 1
		 , @criteria			
		 , @paramset_id
		 , @with_criteria
		 , @data_source_tsql OUTPUT 
		 , @required_cols OUTPUT
	
	IF @with_criteria = 'n'
	BEGIN 
	--	SELECT @data_source_tsql, @required_cols-- AS [data_source_tsql]
		RETURN
	END 
END 
ELSE IF @view_index > 0 AND @validate = 0
BEGIN 
	EXEC spa_print 'Run only'	
	EXEC spa_rfx_get_view_datasource_sql
	 @data_source_tsql
		 , @data_source_process_id
		 , 0
		 , @criteria			
		 , @paramset_id
		 , @with_criteria
		 , @data_source_tsql OUTPUT 
		 , @required_cols OUTPUT 
END 


--SELECT @data_source_tsql AS [data_source_tsql]
--RETURN

SET @batch_index = CHARINDEX(@batch_identifier, @data_source_tsql)
SET @batch_index = IIF(@batch_index = 0, -1, @batch_index)

EXEC spa_print 'Batch Index: ', @batch_index

IF @handle_single_line_sql = 1  OR  @view_index > 0  OR  @batch_index > 0 OR @batch_index = -1 OR @view_result_identifier_index > 0
BEGIN TRY
	DECLARE @err_msg VARCHAR(MAX)
	DECLARE @err_line INT
	DECLARE @catch_sql VARCHAR(MAX)
	--CONVENTION: report_dataset_<alias>_<username>_<datasource_process_id>
	--this name is re-generated later
	EXEC spa_print 'Result temp table: ', @sql_batch_table
	SET @sql_batch_table = dbo.FNAProcessTableName('report_dataset_' + @data_source_alias, dbo.FNADBUser(), @data_source_process_id)
	
	----TODO added to delete process table created in view after its scope is completed.
	--DECLARE @unx_id VARCHAR(8) = RIGHT(CAST(RAND(CHECKSUM(NEWID())) AS DECIMAL(15, 15)), 8)
	--		, @unx_id1 VARCHAR(50) 
	--SET @unx_id1 =  '''' +   @unx_id  + '_'' +  dbo.FNAGETNEWID()'

	IF @view_result_identifier_index > 0 -- case when view result identifier used on view code, where sp will dump data to batch table directly (for performance optmization)
	BEGIN
		SET @data_source_tsql = REPLACE(@data_source_tsql, @view_result_identifier, @sql_batch_table)

		IF @validate = 1 
		BEGIN
			SET @data_source_tsql = REPLACE(@data_source_tsql, 'WHERE', 'WHERE 1 = 2 AND ')	
			SET @data_source_tsql += ' ;TRUNCATE TABLE ' + @sql_batch_table
		END

		--Replace Params in datasource tsql if it is multiline statement
		--otherwise it will be done later after replacing view name with view definition
		SET @data_source_tsql = dbo.FNARFXReplaceReportParams(@data_source_tsql, @criteria, NULL)

		--/*TODO added to delete process table created in view after its scope is completed.*/	
		----SET Value to ON to fix incorrect setting 'QUOTED_IDENTIFIER'
		--SET @data_source_tsql = CAST('' AS VARCHAR(MAX)) + 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + REPLACE(@data_source_tsql, ' dbo.FNAGETNEWID()', @unx_id1 )
		--SET @data_source_tsql += ' ; EXEC dbo.spa_clear_all_temp_table NULL, ''' + @unx_id + ''''
		----------------------------------------------
		SET @data_source_tsql = CAST('' AS VARCHAR(MAX)) + 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + @data_source_tsql
		
		EXEC spa_print '****************************************Datasource SQL Started****************************************:' 
			, @data_source_tsql, '****************************************Datasource SQL Ended******************************************:'
		EXEC spa_print @data_source_tsql

		EXEC(@data_source_tsql)

	END
	ELSE
	BEGIN

		EXEC('IF (OBJECT_ID(N''' + @sql_batch_table + ''', N''U'') IS NOT NULL) DROP TABLE ' + @sql_batch_table)	
	
		IF OBJECT_ID (N'tempdb..#from_index') IS NOT NULL  
		DROP TABLE 	#from_index

		CREATE TABLE #from_index(
			from_loc INT
		)

		DECLARE @from_index1 INT = 1
		IF @batch_index = -1 -- IF THERE IS NO "--[__batch_report__]" GET ALL POSITION OF "FROM"
		BEGIN
			WHILE @from_index1 <> 0
			BEGIN
				SET @from_index1 = dbo.FNACharIndexMatchWholeWord ('from', @data_source_tsql, @from_index1)
						
				INSERT INTO #from_index		
				SELECT @from_index1
				
			END
		END
		ELSE 
		BEGIN -- IF THERE IS "--[__batch_report__]" TAKE POSITION OF FIRST "from" AFTER "--[__batch_report__]"
			SET @from_index1 = dbo.FNACharIndexMatchWholeWord ('from', @data_source_tsql, @batch_index)

			INSERT INTO #from_index		
			SELECT @from_index1		
		END

		DELETE FROM #from_index WHERE from_loc IN (0)

		DECLARE @continue_loop BIT =1
		DECLARE @data_source_tsql1 VARCHAR(MAX)

		IF OBJECT_ID (N'tempdb..#from_index_new') IS NOT NULL  
		DROP TABLE 	#from_index_new

		SELECT from_loc, ROW_NUMBER() OVER (ORDER BY from_loc) row_num 
		INTO #from_index_new
		FROM #from_index

		DECLARE @max_id INT, @counter INT = 1
		SELECT @max_id = MAX(row_num) FROM #from_index_new

	
		WHILE(@Counter IS NOT NULL AND @Counter <= @max_id)
		BEGIN
		BEGIN TRY
			SELECT @from_index = from_loc FROM #from_index_new WHERE row_num = @Counter

			SET @data_source_tsql1 = @data_source_tsql

				SET @data_source_tsql1 = CAST('' AS VARCHAR(MAX)) 
										+  SUBSTRING(@data_source_tsql1, 0, @from_index) + ' INTO ' + @sql_batch_table + ' ' 
										+  SUBSTRING(@data_source_tsql1, @from_index, LEN(@data_source_tsql1))

				--Replace Params in datasource tsql if it is multiline statement
				--otherwise it will be done later after replacing view name with view definition
						SET @data_source_tsql1 = dbo.FNARFXReplaceReportParams(@data_source_tsql1, @criteria, null)

			
				IF @validate = 1 
				BEGIN
					SET @data_source_tsql1 = REPLACE(@data_source_tsql1, 'WHERE', 'WHERE 1 = 2 AND ')	
				END

				--/*TODO added to delete process table created in view after its scope is completed.*/	
				----SET Value to ON to fix incorrect setting 'QUOTED_IDENTIFIER'
				--SET @data_source_tsql1 = CAST('' AS VARCHAR(MAX)) + 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + REPLACE(@data_source_tsql1, ' dbo.FNAGETNEWID()', @unx_id1 )
				--SET @data_source_tsql1 += ' ; EXEC dbo.spa_clear_all_temp_table NULL, ''' + @unx_id + ''''
				SET @data_source_tsql1 = CAST('' AS VARCHAR(MAX)) + 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + @data_source_tsql1
				
				EXEC spa_print '****************************************Datasource SQL Started****************************************:' 
							, @data_source_tsql1, '****************************************Datasource SQL Ended******************************************:'
				EXEC spa_print @data_source_tsql1

				EXEC(@data_source_tsql1)
	
				IF OBJECT_ID(@sql_batch_table) IS NOT NULL
				BEGIN
					SET @continue_loop = 0
				END
			END TRY
			BEGIN CATCH
				SET @continue_loop = 1
				SET @err_msg = ERROR_MESSAGE()
				SET @err_line = ERROR_LINE()
			
				IF ERROR_NUMBER() = 156 AND @err_msg = 'Incorrect syntax near the keyword ''INTO''.'
				BEGIN
					SET @continue_loop = 1
				END
				ELSE 
				BEGIN
					SET @continue_loop = 0
				
					EXEC('IF (OBJECT_ID(N''' + @sql_batch_table + ''', N''U'') IS NOT NULL) DROP TABLE ' + @sql_batch_table)

					SET @catch_sql = 'SELECT ''Error'' [error_status], ''' + REPLACE(@err_msg,'''','''''') + ''' [error_msg], ' + CAST(@err_line AS VARCHAR(10)) +  ' [error_line] INTO ' + @sql_batch_table
					EXEC(@catch_sql)
			
				END
			
			END CATCH
			SET @Counter  = @Counter  + 1
		END 
	END
END TRY
BEGIN CATCH
	SET @err_msg = ERROR_MESSAGE()
	SET @err_line = ERROR_LINE()
	
	SET @catch_sql = 'SELECT ''Error'' [error_status], ''' + REPLACE(@err_msg,'''','''''') + ''' [error_msg], ' + CAST(@err_line AS VARCHAR(10)) +  ' [error_line] INTO ' + @sql_batch_table
	--print(@catch_sql)
	EXEC(@catch_sql)
	
END CATCH


/******************************Datasource TSQL processing (if multiline) END*********************************/
