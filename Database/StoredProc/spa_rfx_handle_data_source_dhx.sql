IF OBJECT_ID(N'dbo.spa_rfx_handle_data_source_dhx', N'P') IS NOT NULL
      DROP PROCEDURE dbo.spa_rfx_handle_data_source_dhx
GO

 --============================================================================================================================
 --Create date: 2012-09-11
 --Author : ssingh@pioneersolutionsglobal.com
 --Description: Handles TSQL statements of data source and dumps the final select query into a process table. For Preview mode. 
               
 --Params:
 --	@data_source_tsql			VARCHAR(MAX) : sql statement passed from the application 
 --	@data_source_alias			VARCHAR(50) : alias given to the sql statement 
 --	@criteria					VARCHAR(5000) : parameter and their values 
 --	@data_source_process_id		VARCHAR(50) : process_id passed  
 --	@handle_single_line_sql		BIT : 1 = must dump single line query , 0 = no need to dump single line query
 --	@validate					BIT	: 1 = validation required, 0 = validation not required
 -- @paramset_id				INT : Paramset ID 
 -- @with_criteria              CHAR(1) : Flag to identify whether call is with or without criteria
 -- @process_id					VARCHAR(50) : Process ID used for process tables for preview mode
 --============================================================================================================================

CREATE PROCEDURE [dbo].[spa_rfx_handle_data_source_dhx]
	@data_source_tsql				VARCHAR(MAX)= NULL
	, @data_source_alias			VARCHAR(100) = NULL
	, @criteria						VARCHAR(5000) = NULL
	, @data_source_process_id		VARCHAR(100) = NULL
	, @handle_single_line_sql		BIT = 0
	, @validate						BIT	= 0 --validate required?
	, @paramset_id					INT = NULL
	--, @call_from					CHAR(1) = NULL
	, @with_criteria                CHAR(1) = NULL
	, @process_id					VARCHAR(50) = NULL
AS
/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
declare @data_source_tsql				VARCHAR(MAX)= 'select * from seq'
	, @data_source_alias			VARCHAR(100) = 'sq1'
	, @criteria						VARCHAR(5000) = 'sub_id=NULL,stra_id=NULL,book_id=NULL,sub_book_id=NULL,contract_id=NULL,counterparty_id=NULL,deal_status_id=NULL'
	, @data_source_process_id		VARCHAR(100) = '99_csv_99'
	, @handle_single_line_sql		BIT = 1
	, @validate						BIT	= 0 --validate required?
	, @paramset_id					INT = NULL
	, @with_criteria                CHAR(1) = 'y'
	, @process_id					VARCHAR(50) = 'B8A88A40_C14B_4274_B798_18B50D76F8F6'
	                     
--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/
SET NOCOUNT ON;
begin try
DECLARE @from_index				INT
DECLARE @batch_index			INT
DECLARE @batch_identifier		VARCHAR(100)
DECLARE @view_index				INT
DECLARE @view_identifier		VARCHAR(100)
DECLARE @sql_batch_table		VARCHAR(5000)
DECLARE @error_msg				VARCHAR(1000)
DECLARE @sql NVARCHAR(MAX)
DECLARE @required_cols			VARCHAR(MAX)  

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
	EXEC spa_rfx_get_view_datasource_sql_dhx
		 @data_source_tsql
		 , @data_source_process_id
		 , 1
		 , @criteria			
		 , @paramset_id
		 , @with_criteria
		 , @data_source_tsql OUTPUT 
		 , @required_cols OUTPUT
		 , @process_id
	
	IF @with_criteria = 'n'
	BEGIN 
	--	SELECT @data_source_tsql, @required_cols-- AS [data_source_tsql]
		RETURN
	END 
END 
ELSE IF @view_index > 0 AND @validate = 0
BEGIN 
	EXEC spa_print 'Run only'	
	EXEC spa_rfx_get_view_datasource_sql_dhx
		 @data_source_tsql
		 , @data_source_process_id
		 , 0
		 , @criteria			
		 , @paramset_id
		 , @with_criteria
		 , @data_source_tsql OUTPUT 
		 , @required_cols OUTPUT 
		 , @process_id
END 


--SELECT @data_source_tsql AS [data_source_tsql]
--RETURN

SET @batch_index = CHARINDEX(@batch_identifier, @data_source_tsql)
EXEC spa_print 'Batch Index: ', @batch_index 

--if datasource tsql is a multiline statement, execute it to save result in temp table
IF @batch_index > 0
BEGIN
	SET @from_index = dbo.FNACharIndexMatchWholeWord('FROM', @data_source_tsql, ISNULL(@batch_index, 0))
	EXEC spa_print 'Occurence of FROM after batch identifier: ', @from_index
	SET @error_msg = 'Query is malformed. A final SELECT ... FROM ... statement must be present in SQL after batch identifier(--[__batch_report__]).'
END
ELSE IF @batch_index = 0 AND @view_index > 0
BEGIN
	SET @from_index = dbo.FNACharIndexMatchWholeWord('FROM', @data_source_tsql, 1)
	EXEC spa_print 'Occurence of FROM after batch identifier: ', @from_index
	SET @error_msg = 'Query is malformed. A final SELECT ... FROM ... statement must be present in SQL after batch identifier(--[__batch_report__]).'
END
ELSE IF @handle_single_line_sql = 1
BEGIN
	--if no @batch_identifier found, the only best option is trying to find FROM from the end
	SET @from_index = dbo.FNACharIndexReverseMatchWholeWord('FROM', @data_source_tsql, 0)
	EXEC spa_print 'Last occurence of FROM: ', @from_index 
	SET @error_msg = 'Query is malformed. FROM clause is missing.'
END


IF @batch_index > 0 OR @handle_single_line_sql = 1  OR  @view_index > 0
BEGIN
	IF ISNULL(@from_index, 0) = 0
		RAISERROR (@error_msg, -- Message text.
				   16, -- Severity.
				   1 -- State.
				   );

	--CONVENTION: report_dataset_<alias>_<username>_<datasource_process_id>
	--this name is re-generated later
	
	SET @sql_batch_table = dbo.FNAProcessTableName('report_dataset_' + @data_source_alias, dbo.FNADBUser(), @data_source_process_id)
	
	
	--drop if the table already exists
	EXEC('IF (OBJECT_ID(N''' + @sql_batch_table + ''', N''U'') IS NOT NULL) DROP TABLE ' + @sql_batch_table)



	/** SELECT TOP 20 ROWS INCASE OF CSV GENERATION START **/
	-- replace multispaces by single space
	declare @spaced_tsql varchar(max)= RTRIM(LTRIM(replace(replace(replace(@data_source_tsql,' ','~^'),'^~',''),'~^',' ')))

	-- replace enter character with a space
	SET @spaced_tsql = REPLACE(@spaced_tsql,CHAR(10) +'top',' top')
	SET @spaced_tsql = REPLACE(@spaced_tsql,CHAR(10) +' top',' top')
	SET @spaced_tsql = REPLACE(@spaced_tsql,CHAR(10)+'distinct',' distinct')
	SET @spaced_tsql = REPLACE(@spaced_tsql,CHAR(10)+' distinct',' distinct')

	SET @spaced_tsql = REPLACE(@spaced_tsql,CHAR(13) +'top',' top')
	SET @spaced_tsql = REPLACE(@spaced_tsql,CHAR(13) +' top',' top')
	SET @spaced_tsql = REPLACE(@spaced_tsql,CHAR(13)+'distinct',' distinct')
	SET @spaced_tsql = REPLACE(@spaced_tsql,CHAR(13)+' distinct',' distinct')

	declare @reversed_tsql varchar(max) = reverse(@spaced_tsql)
		,@batch_identifier_reversed varchar(20)=reverse(@batch_identifier)
		,@to_find varchar(50)=''
		,@top_20_select_clause varchar(max)
		
	-- get sub string before batch identifier
	declare @sub_str varchar(max) = reverse(substring(@spaced_tsql, 0,CHARINDEX(@batch_identifier,@spaced_tsql)))

	-----------------Replace condition start----------------------
	DECLARE @comment1 VARCHAR(100), @comment2 VARCHAR(100), @startPosition INT, @top_to_find varchar(200), @sub_str1 varchar(max)
	DECLARE @batch_index_csv int  = CHARINDEX(@batch_identifier_reversed, @reversed_tsql)
	
	WHILE Patindex('% tceles%',@sub_str) <> 0
	BEGIN
		SET @startPosition = Patindex('% tceles%',@sub_str)
        SET @Comment1 = Substring(@sub_str,@startPosition,8)
		SET @Comment2 = Substring(@sub_str,@startPosition,9)				

		if @Comment1 <> reverse('(select ') AND @Comment2 <> reverse('( select ')
		begin
			select @sub_str1 = reverse(substring(@sub_str, 0,@startPosition))
			-- get three words after final select word
			select @top_to_find = SUBSTRING(@sub_str1, 0,CHARINDEX(' ', @sub_str1, CHARINDEX(' ',@sub_str1, CHARINDEX(' ', @sub_str1, 0)+1)+1))
						
			set @top_to_find = ' ' +  RTRIM(LTRIM(@top_to_find))
	
			IF CHARINDEX(' top ',@top_to_find) > 0
			begin
				if CHARINDEX(' distinct ',@top_to_find) > 0
				begin			
					SET @to_find = @top_to_find
				end
				else
				begin			
					SET @to_find = SUBSTRING(@top_to_find, 0,CHARINDEX(' ', @top_to_find, CHARINDEX(' ',@top_to_find, CHARINDEX(' ', @top_to_find, 0)+1)+1))				
				end
			end
			else if CHARINDEX(' top(',@top_to_find) > 0
			begin	
				if CHARINDEX(' distinct ',@top_to_find) > 0
				begin			
					SET @to_find = SUBSTRING(@top_to_find, 0,CHARINDEX(' ', @top_to_find, CHARINDEX(' ',@top_to_find, CHARINDEX(' ', @top_to_find, 0)+1)+1))
				end
				else
				begin
					SET @to_find = SUBSTRING(@top_to_find, 0, CHARINDEX(' ',@top_to_find, CHARINDEX(' ', @top_to_find, 0)+1))				
				end
			end
			else if CHARINDEX(' distinct ',@top_to_find) > 0
			begin
				SET @to_find = 'DISTINCT'
			end

			SET @to_find = reverse('SELECT' + @to_find)
		
			EXEC spa_print '@top_to_find:', @top_to_find
			EXEC spa_print '@to_find:', @to_find
	
			SELECT @top_20_select_clause = reverse(stuff(@reversed_tsql, charindex(@to_find, @reversed_tsql, CHARINDEX(@top_to_find,@sub_str,0) + @batch_index_csv + 1 - len(@top_to_find)),len(@to_find), reverse('SELECT TOP 20 ')))
			SET @sub_str = REPLACE(@sub_str,' tceles','>tcele_s<')
		end

		SET @sub_str = REPLACE(REPLACE(@sub_str,@Comment1,'>tcele_s(<'),@comment2,'>tcele_s(<')
		SET @reversed_tsql = REPLACE(REPLACE(@reversed_tsql,@Comment1,'>tcele_s(<'),@comment2,'>tcele_s(<')
	END

	SET @top_20_select_clause =REPLACE(@top_20_select_clause,'<(s_elect>','(select ')
	------------------Replace condition end------------
	
		
	--process_id 99_csv_99 is used for process tables to identify the case of csv generation
	--print isnull(@data_source_process_id,'null')
	if(@data_source_process_id = '99_csv_99')
	begin
        SET @data_source_tsql = @top_20_select_clause
		SET @batch_index = CHARINDEX(@batch_identifier, @data_source_tsql)
		SET @data_source_tsql = REPLACE(@data_source_tsql,@batch_identifier,' ')
		
        IF @batch_index > 0
        BEGIN
			set @from_index = dbo.FNACharIndexMatchWholeWord('FROM', @data_source_tsql, ISNULL(@batch_index, 0))
			EXEC spa_print '@from_index: ', @from_index
	
        END
        ELSE IF @batch_index = 0 AND @view_index > 0
        BEGIN
            SET @from_index = dbo.FNACharIndexMatchWholeWord('FROM', @data_source_tsql, 1)
        END
        ELSE IF @handle_single_line_sql = 1
        BEGIN
            --if no @batch_identifier found, the only best option is trying to find FROM from the end
            SET @from_index = dbo.FNACharIndexReverseMatchWholeWord('FROM', @data_source_tsql, 0)
        END
             
    end
	
	/** SELECT TOP 20 ROWS INCASE OF CSV GENERATION END **/
	
	EXEC spa_print 'Result temp table: ', @sql_batch_table
	SET @data_source_tsql = SUBSTRING(@data_source_tsql, 0, @from_index) + ' INTO ' + @sql_batch_table + ' ' +  SUBSTRING(@data_source_tsql, @from_index, LEN(@data_source_tsql))
	

	--Replace Params in datasource tsql if it is multiline statement
	--otherwise it will be done later after replacing view name with view definition
	SET @data_source_tsql = dbo.FNARFXReplaceReportParams(@data_source_tsql, @criteria,null)

	IF @validate = 1 
	BEGIN
		SET @data_source_tsql = REPLACE(@data_source_tsql, 'WHERE', 'WHERE 1 = 2 AND ')	
	END

	--SET Value to ON to fix incorrect setting 'QUOTED_IDENTIFIER'
	SET @data_source_tsql = 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + @data_source_tsql
		
	EXEC spa_print '****************************************Datasource SQL Started****************************************:' 
		, @data_source_tsql, '****************************************Datasource SQL Ended******************************************:'

	EXEC(@data_source_tsql)
END
end try
begin catch
	--LOG ERROR ON REPORT MANAGER ERROR LOG TABLE
	declare @err_msg varchar(max) = error_message()
	DECLARE @rfx_err_log VARCHAR(1000) = dbo.FNAProcessTableName('rfx_err_log', dbo.fnadbuser(), @process_id)
	set @sql = '
	insert into ' + @rfx_err_log + '
	select ''spa_rfx_handle_data_source_dhx'', ''' +  replace(@err_msg,'''','''''') + ''', getdate()
	'
	exec(@sql)
end catch

/******************************Datasource TSQL processing (if multiline) END*********************************/
