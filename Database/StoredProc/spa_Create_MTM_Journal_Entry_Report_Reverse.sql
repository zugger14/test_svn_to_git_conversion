
IF OBJECT_ID(N'spa_Create_MTM_Journal_Entry_Report_Reverse', N'P') IS NOT NULL
	DROP PROCEDURE spa_Create_MTM_Journal_Entry_Report_Reverse
GO 

CREATE PROC [dbo].[spa_Create_MTM_Journal_Entry_Report_Reverse]
	@as_of_date VARCHAR(50), 
	@subsidiary_id VARCHAR(MAX), 
	@strategy_id VARCHAR(MAX) = NULL, 
	@book_id VARCHAR(MAX) = NULL, 
	@discount_option CHAR(1), 
	@settlement_option CHAR(1), 
	@report_type CHAR(1), 
	@summary_option CHAR(1),
 	@reverse_entries VARCHAR(1) = 'n',
	@link_id VARCHAR(500) = NULL,
	@output_table_name VARCHAR(300) = NULL,
	@return_value VARCHAR(50)=NULL,
	@round_value CHAR(2) = '0',
	@legal_entity INT = NULL,
	@drill_gl_number VARCHAR(5000) = NULL,
	@sap_export INT = NULL,
	@batch_process_id VARCHAR(100)=NULL,
	@batch_report_param VARCHAR(1000)=NULL,
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS

SET NOCOUNT ON
/*
--test case start
--exec spa_Create_MTM_Journal_Entry_Report_Reverse '2004-12-31', '291,30,1,257,258,256', NULL, NULL, 'd', NULL, 'a', 's', 'n', NULL, NULL,NULL, '0',NULL
-- exec spa_Create_MTM_Journal_Entry_Report_Reverse '2005-10-31', '30', '122', NULL, 'd', NULL, 'a', 's', 'n', NULL, NULL,NULL, '2'
-- exec spa_Create_MTM_Journal_Entry_Report_Reverse '2004-12-31', '291,257', NULL, NULL, 'd', NULL, 'a', 's', 'n', NULL, NULL,NULL, '2'
--spa_Create_MTM_Journal_Entry_Report_Reverse '2004-10-30', '1', null, NULL, 'd', 'a', 'a', 's', 'y', 356
--exec spa_Create_MTM_Journal_Entry_Report_Reverse '2013-05-31', '5,74,208,209,207,4,3,2,1', NULL, NULL, 'd', 'f', 'a', 's', 'n', NULL, NULL,NULL, 2,NULL,NULL,1377 --sandbox 2
DECLARE 
@as_of_date VARCHAR(50), 
	@subsidiary_id VARCHAR(100), 
	@strategy_id VARCHAR(100), 
	@book_id VARCHAR(100), 
	@discount_option CHAR(1), 
	@settlement_option CHAR(1), 
	@report_type CHAR(1), 
	@summary_option CHAR(1),
 	@reverse_entries VARCHAR(1),
	@link_id VARCHAR(500) ,
	@output_table_name VARCHAR(150),
	@return_value VARCHAR(50),
	@round_value CHAR(2),
	@legal_entity INT = NULL,
	@drill_gl_number VARCHAR(5000) ,
	@sap_export INT,
	@batch_process_id VARCHAR(100),
	@batch_report_param VARCHAR(1000)
	
IF (OBJECT_ID('tempdb..#prior_entries_summary')) IS NOT NULL
DROP TABLE #prior_entries_summary

IF (OBJECT_ID('tempdb..#prior_entries_sap')) IS NOT NULL
DROP TABLE #prior_entries_sap

IF (OBJECT_ID('tempdb..#prior_entries_detail')) IS NOT NULL
DROP TABLE #prior_entries_detail

IF (OBJECT_ID('tempdb..#current_entries_summary')) IS NOT NULL
DROP TABLE #current_entries_summary

IF (OBJECT_ID('tempdb..#current_entries_sap')) IS NOT NULL
DROP TABLE #current_entries_sap

IF (OBJECT_ID('tempdb..#current_entries_detail')) IS NOT NULL
DROP TABLE #current_entries_detail

IF (OBJECT_ID('tempdb..#sub_ids')) IS NOT NULL
DROP TABLE #sub_ids

IF (OBJECT_ID('tempdb..#ssbm')) IS NOT NULL
DROP TABLE #ssbm

SET @as_of_date = '2013-05-31'
SET @subsidiary_id = '5,74,208,209,207,4,3,2,1'

SET @discount_option = 'd' 
SET @settlement_option = 'f' 
SET @report_type   = 'a'
SET @summary_option = 's'
SET @reverse_entries = 'n'
SET @sap_export = 1377
set @round_value = 2
--test case end

*/
--IF @sap_export IS NOT NULL
--	SET @summary_option = 'd'
	
/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR (8000) 
DECLARE @user_login_id VARCHAR (50) 
DECLARE @sql_paging VARCHAR (8000) 
DECLARE @is_batch BIT
 
SET @str_batch_table = '' 
SET @user_login_id = dbo.FNADBUser()  
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1 
BEGIN 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id) 
END

IF @enable_paging = 1 --paging processing 
BEGIN 
	IF @batch_process_id IS NULL 
	BEGIN
 		SET @batch_process_id = dbo.FNAGetNewID()
	END

	SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no)	
 
	--retrieve data from paging table instead of main table
 
	IF @page_no IS NOT NULL  
	BEGIN 
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no)  
		EXEC (@sql_paging)  
		RETURN  
	END 
END
 
/*******************************************1st Paging Batch END**********************************************/  

DECLARE @process_id VARCHAR(50)
DECLARE @tmp_process_table VARCHAR(200)
DECLARE @report_name VARCHAR(100)  

SET @process_id = REPLACE(NEWID(),'-','_')
SET @tmp_process_table = dbo.FNAProcessTableName('tmp_process_table', @user_login_id, @process_id)

DECLARE @period_entry VARCHAR(1)
DECLARE @prior_as_of_date VARCHAR(20)
DECLARE @prior_settlement_option VARCHAR(1)
DECLARE @sql_stmt VARCHAR(MAX)
DECLARE @sql_stmt1 VARCHAR(8000)

SET @prior_as_of_date  = NULL
SET @period_entry = 'n'
--set @prior_settlement_option = 'f'
SET @prior_settlement_option = @settlement_option

--If @link_id IS NOT NULL 
--BEGIN
--
--	CREATE TABLE #last_run_date(last_run_date varchar(20) COLLATE DATABASE_DEFAULT)
--
--	DECLARE @passed_as_of_date varchar(20)
--	SET @passed_as_of_date = @as_of_date
--	set @sql_stmt1='INSERT INTO #last_run_date
--	SELECT isnull(dbo.FNAGetSQLStandardDate(max(as_of_date)), ''' + @as_of_date + ''') 
--		FROM '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'report_measurement_values') + ' report_measurement_values where as_of_date <=  ''' + @as_of_date + '''
--			and link_id IN (' + @link_id  + ')
--			and link_deal_flag = ''l'''
--
--	EXEC(@sql_stmt1)
--
--	SELECT @as_of_date = isnull(last_run_date, @as_of_date) FROM  #last_run_date
--
--	--SELECT @as_of_date
-- 	--print 'here...'
--	IF @passed_as_of_date <> @as_of_date
--	BEGIN
--		SET @prior_as_of_date = @as_of_date
--		IF @reverse_entries <> 'n' SET @reverse_entries = 'p'
--		SET @prior_settlement_option = @settlement_option
--	END
--
--	--SELECT @passed_as_of_date, @prior_as_of_date, @reverse_entries, @prior_settlement_option
--END

-- EXEC spa_print @prior_as_of_date
-- EXEC spa_print @reverse_entries
-- EXEC spa_print @prior_settlement_option

IF @drill_gl_number IS NOT NULL
BEGIN

	EXEC spa_Create_MTM_Journal_Entry_Report @as_of_date, @subsidiary_id, 
	@strategy_id, @book_id, @discount_option, @settlement_option, @report_type, 'z', 0 ,@link_id, 
	@round_value, @legal_entity, @drill_gl_number, @str_batch_table			

	SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
	EXEC(@str_batch_table)        

	SET @report_name='Run Journal Entry Report Drill Down Batch'        
	    
	SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_Create_MTM_Journal_Entry_Report_Reverse',@report_name)         
	EXEC(@str_batch_table) 

	RETURN
END




IF @reverse_entries = 'p'
BEGIN
	SET @reverse_entries = 'y'
	SET @period_entry = 'y'
END

CREATE TABLE #prior_entries_summary
(
	GLNumber VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	AccountName VARCHAR(250) COLLATE DATABASE_DEFAULT ,
	Debit FLOAT,
	Credit FLOAT,
)
CREATE TABLE #prior_entries_sap
(
	GLNumberID VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	SourceBookMapID VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	GLNumber VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	AccountName VARCHAR(250) COLLATE DATABASE_DEFAULT ,
	Debit FLOAT,
	Credit FLOAT,
)

CREATE TABLE #prior_entries_detail
(
	Subsidiary VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Strategy VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Book VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	GLNumber VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	AccountName VARCHAR(250) COLLATE DATABASE_DEFAULT ,
	Debit FLOAT,
	Credit FLOAT,
)

CREATE TABLE #current_entries_summary
(
	GLNumber VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	AccountName VARCHAR(250) COLLATE DATABASE_DEFAULT ,
	Debit FLOAT,
	Credit FLOAT,
)
CREATE TABLE #current_entries_sap
(
	GLNumberID VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	SourceBookMapID VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	GLNumber VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	AccountName VARCHAR(250) COLLATE DATABASE_DEFAULT ,
	Debit FLOAT,
	Credit FLOAT,
)


CREATE TABLE #current_entries_detail
(
	Subsidiary VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Strategy VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Book VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	GLNumber VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	AccountName VARCHAR(250) COLLATE DATABASE_DEFAULT ,
	Debit FLOAT,
	Credit FLOAT,
)

CREATE TABLE #sub_ids(sub_id INT)

--print 'here 1'

--If @link_id is not null and sub_id is not  pased
IF @subsidiary_id IS NULL AND @link_id IS NOT NULL
BEGIN
	CREATE TABLE #tmpS(sub_entity_id VARCHAR(100) COLLATE DATABASE_DEFAULT )
	
	EXEC('INSERT into #tmpS 
		SELECT CAST(MIN(sub.entity_id) AS VARCHAR) 
		FROM portfolio_hierarchy sub 
		INNER JOIN portfolio_hierarchy stra on stra.parent_entity_id = sub.entity_id 
		INNER JOIN portfolio_hierarchy book on book.parent_entity_id = stra.entity_id 
		INNER JOIN fas_link_header flh on flh.fas_book_id = book.entity_id 
		WHERE flh.link_id in (' + @link_id + ')')

	SELECT @subsidiary_id = sub_entity_id FROM #tmpS
	--print '****' + @subsidiary_id + '***'
END

--print 'here 2'
--print @reverse_entries

IF @reverse_entries ='y'
BEGIN 

	IF @prior_as_of_date IS NULL
	BEGIN
-- 		exec ('insert into #sub_ids SELECT fas_subsidiary_id FROM fas_subsidiaries where fas_subsidiary_id in (' + 
-- 				@subsidiary_id +')')
-- 		SELECT @prior_as_of_date  = dbo.FNAGetSQLStandardDate(max(as_of_date)) FROM report_measurement_values where as_of_date <  @as_of_date 
-- 				and sub_entity_id in (SELECT sub_id FROM #sub_ids)
-- 				and (link_id = CASE WHEN (@link_id IS NULL) THEN link_id else @link_id end)
-- 				and (link_deal_flag = CASE WHEN (@link_id IS NULL) THEN link_deal_flag else 'l' end)

--		CREATE TABLE #prior_run_date(last_run_date varchar(20) COLLATE DATABASE_DEFAULT)

		SELECT @prior_as_of_date = dbo.FNAGetSQLStandardDate(MAX(as_of_date)) 
		FROM measurement_run_dates WHERE as_of_Date < @as_of_Date

--		set @sql_stmt = 'INSERT INTO #prior_run_date
--		SELECT dbo.FNAGetSQLStandardDate(max(as_of_date))
--			FROM '+ dbo.FNAGetProcessTableInternal(@as_of_date, 'report_measurement_values') + ' report_measurement_values where as_of_date <  ''' + @as_of_date + '''
--				and link_id IN (' + CASE WHEN (@link_id IS NULL) THEN ' link_id)' else @link_id + ')' end +
--				' and link_deal_flag = ' + CASE WHEN (@link_id IS NULL) THEN ' link_deal_flag ' else '''l''' end
--
--		EXEC spa_print @sql_stmt
--		EXEC(@sql_stmt)
--
--		
--		SELECT @prior_as_of_date = last_run_date FROM  #prior_run_date
		--print @prior_as_of_date 
	END

	--SELECT @prior_as_of_date

	IF @prior_as_of_date  IS NOT NULL 
	BEGIN
		IF @sap_export IS NOT NULL
		BEGIN 
			INSERT #prior_entries_sap
			EXEC spa_Create_MTM_Journal_Entry_Report @prior_as_of_date, @subsidiary_id, 
			@strategy_id, @book_id, @discount_option, 'f', 
			@report_type, 'v', 0, @link_id, @round_value, @legal_entity
		END 
		ELSE
		BEGIN 
			IF @summary_option = 's'
				INSERT #prior_entries_summary
				EXEC spa_Create_MTM_Journal_Entry_Report @prior_as_of_date, @subsidiary_id, 
				@strategy_id, @book_id, @discount_option, @prior_settlement_option, 
				@report_type, @summary_option, 0, @link_id, @round_value, @legal_entity			
			ELSE
				INSERT #prior_entries_detail
				EXEC spa_Create_MTM_Journal_Entry_Report @prior_as_of_date, @subsidiary_id, 
				@strategy_id, @book_id, @discount_option, @prior_settlement_option, 
				@report_type, @summary_option, 0, @link_id, @round_value, @legal_entity 
		END 				
	END	 
END		

 --SELECT @as_of_date, @subsidiary_id, 
 --	@strategy_id, @book_id, @discount_option, @settlement_option, @report_type, @summary_option, 0 ,@link_id

IF @sap_export IS NOT NULL
BEGIN 
	INSERT INTO #current_entries_sap
	EXEC spa_Create_MTM_Journal_Entry_Report @as_of_date, @subsidiary_id, 
	@strategy_id, @book_id, @discount_option, 'f', 
	@report_type, 'v', 0, @link_id, @round_value, @legal_entity
END 
ELSE
BEGIN 
	IF @summary_option = 's'
		INSERT #current_entries_summary
		EXEC spa_Create_MTM_Journal_Entry_Report @as_of_date, @subsidiary_id, 
		@strategy_id, @book_id, @discount_option, @settlement_option, @report_type, @summary_option, 0 ,@link_id, @round_value, @legal_entity			
	ELSE
		INSERT #current_entries_detail
		EXEC spa_Create_MTM_Journal_Entry_Report @as_of_date, @subsidiary_id, 
		@strategy_id, @book_id, @discount_option, @settlement_option, @report_type, @summary_option, 0 , @link_id, @round_value, @legal_entity
END 						

--EXEC spa_Create_MTM_Journal_Entry_Report '12/01/2005', '96', null, null, 'u', 'f', 'a', 's', 0 ,null		
--SELECT @as_of_date, @prior_as_of_date
--SELECT * FROM #current_entries_summary
-- SELECT * FROM #prior_entries_summary

--DECLARE @sql_stmt varchar(8000)
-- 
 --SELECT * FROM #prior_entries_summary
 --SELECT * FROM #current_entries_detail

SET @sql_stmt = ''

IF OBJECT_ID('tempdb..#tmp_process_table') IS NOT NULL
	DROP TABLE #tmp_process_table
	
CREATE TABLE #tmp_process_table(
	GLNumberID VARCHAR(100) COLLATE DATABASE_DEFAULT  
	, SourceBookMapID VARCHAR(100) COLLATE DATABASE_DEFAULT , Subsidiary VARCHAR(100) COLLATE DATABASE_DEFAULT 
	, Strategy VARCHAR(100) COLLATE DATABASE_DEFAULT 
	, Book VARCHAR(100) COLLATE DATABASE_DEFAULT 
	, GLNumber VARCHAR(50) COLLATE DATABASE_DEFAULT 
	, AccountName VARCHAR(500) COLLATE DATABASE_DEFAULT 
	, Debit FLOAT
	, Credit FLOAT
) 
	
IF @sap_export IS NOT NULL
BEGIN
	
	SET @sql_stmt = ' INSERT INTO #tmp_process_table (GLNumberID, SourceBookMapID, GLNumber, AccountName, Debit, Credit)
					SELECT	GLNumberID	--TODO: Verify if this column is required
							, SourceBookMapID
							, GLNumber
							, AccountName
							, Debit [Debit]
							, Credit [Credit]  
					FROM (
						SELECT	MAX(GLNumberID) GLNumberID
								, SourceBookMapID
								, GLNumber
								, AccountName
								, CASE WHEN (''' + @period_entry + ''' = ''n'') THEN
									SUM(Debit)
								ELSE
									CASE WHEN(max(Debit) >= MAX(Credit)) THEN MAX(Debit) - MAX(Credit)
									ELSE	0
									END
								END AS [Debit],
								CASE WHEN (''' + @period_entry + ''' = ''n'') THEN
									SUM(Credit)
								ELSE
									CASE WHEN(max(Debit) >= MAX(Credit)) THEN 0
									ELSE MAX(Credit) - MAX(Debit)
									END
								END AS [Credit]
						FROM (
							SELECT	GLNumberID, 
									SourceBookMapID, 
									GLNumber,
									AccountName,
									Credit As [Debit],
									Debit As [Credit]
							FROM #prior_entries_sap
							UNION
							SELECT	GLNumberID, 
									SourceBookMapID,	
									GLNumber,
									AccountName,
									Debit,
									Credit
							FROM #current_entries_sap) entries
						GROUP BY SourceBookMapID, GLNumber, AccountName
						) xx
					WHERE  (Debit <> Credit AND ((Debit > 0.51) OR (Credit > 0.51)))'
END
ELSE
BEGIN 
	IF @summary_option = 's'
	BEGIN
		SET @sql_stmt = ' INSERT INTO #tmp_process_table (GLNumber,AccountName, Debit,Credit)
						SELECT	GLNumber, 
								AccountName, 
								Debit [Debit],  
								Credit [Credit]  
						FROM  (
							SELECT  GLNumber,
									AccountName,
									CASE WHEN  (''' + @period_entry + ''' = ''n'') THEN
										SUM(Debit)
									ELSE
										CASE WHEN(SUM(Debit) >= SUM(Credit)) THEN SUM(Debit) - SUM(Credit)
										ELSE	0
										END
									END AS [Debit],
									CASE WHEN  (''' + @period_entry + ''' = ''n'') THEN
										SUM(Credit)
									ELSE
										CASE WHEN(SUM(Debit) >= SUM(Credit)) THEN 0
										ELSE SUM(Credit) - SUM(Debit)
										END
									END
								 AS [Credit]
							FROM (
									SELECT	GLNumber,
											AccountName,
											Credit As [Debit],
											Debit As [Credit]
									FROM #prior_entries_summary
									UNION
									SELECT	GLNumber,
											AccountName,
											Debit,
											Credit
									FROM #current_entries_summary
									) entries
						GROUP BY GLNumber, AccountName ) xx
						WHERE  (Debit <> Credit AND ((Debit > 0.51) OR (Credit > 0.51)))'
	END
	ELSE
	BEGIN
		SET @sql_stmt = ' INSERT INTO #tmp_process_table (Subsidiary, Strategy, Book, GLNumber, AccountName, Debit,Credit)
						SELECT	Subsidiary, 
								Strategy, 
								Book, 
								GLNumber,
								AccountName, 
								Debit  [Debit],  
								Credit [Credit]
						FROM (
							SELECT	Subsidiary, 
									Strategy, 
									Book, 
									GLNumber,
									AccountName,
									CASE WHEN  (''' + @period_entry + ''' = ''n'') THEN
										SUM(Debit)
									ELSE
										CASE WHEN(SUM(Debit) >= SUM(Credit)) THEN SUM(Debit) - SUM(Credit) ELSE 0  END
									END AS [Debit],
									CASE WHEN  (''' + @period_entry + ''' = ''n'') THEN
										SUM(Credit)
									ELSE
										CASE WHEN(SUM(Debit) >= SUM(Credit)) THEN 0
										ELSE SUM(Credit) - SUM(Debit)
										END
									END AS [Credit]
							FROM 	(
								SELECT	Subsidiary, 
										Strategy, 
										Book,
										GLNumber,
										AccountName,
										Credit As [Debit],
										Debit As [Credit]
								FROM #prior_entries_detail
								UNION
								SELECT	Subsidiary, 
										Strategy, 
										Book,
										GLNumber,
										AccountName,
										Debit,
										Credit
								FROM #current_entries_detail
								) entries
						GROUP BY Subsidiary, Strategy, Book, GLNumber, AccountName) XX
						WHERE (Debit <> Credit AND ((Debit > 0.51) OR (Credit > 0.51)))'
	END
END 
EXEC (@sql_stmt)

DECLARE @dif FLOAT
SELECT  @dif = SUM(debit)-SUM(credit) FROM #tmp_process_table

IF @dif > 0 AND @dif < 0.99
	UPDATE TOP (1) #tmp_process_table SET debit = debit - @dif WHERE debit > @dif
ELSE IF @dif > -0.99 AND @dif < 0 
	UPDATE TOP (1) #tmp_process_table SET credit = credit + @dif WHERE credit > (-1 * @dif)

IF @sap_export IS NOT NULL
BEGIN 
	SET @sql_stmt='SELECT  GLNumberID as [GL Number], SourceBookMapID as [Source Book Map ID], GLNumber as [GL Number], AccountName as [Account Name], Debit, Credit FROM #tmp_process_table'
END 
ELSE
BEGIN
	SET @sql_stmt = 'SELECT '+CASE WHEN @summary_option = 's' THEN 'GLNumber as [GL Number], AccountName as [Account Name], Debit,Credit' ELSE 'Subsidiary , Strategy, Book, GLNumber, AccountName, Debit,Credit ' END 
					+ @str_batch_table + ' FROM #tmp_process_table'
END

IF @sap_export IS NULL 
BEGIN 
	IF @output_table_name IS NULL
		EXEC (@sql_stmt)
	ELSE IF @output_table_name = 'fas_journal_entry_temp_table'
	BEGIN
		SET @output_table_name = dbo.FNAProcessTableName('journal_entry_posting', dbo.FNADBUser(), @output_table_name)
		EXEC ('INSERT INTO ' + @output_table_name + '(subsidiary, strategy, book, gl_number, account_name, debit_amount, credit_amount) ' + @sql_stmt)
	END
	ELSE
	BEGIN
		SET @output_table_name = dbo.FNAProcessTableName('journal_entry_posting', dbo.FNADBUser(), @output_table_name)
		
		EXEC('DELETE ' + @output_table_name + ' WHERE entry_type = ''s''')
		EXEC ('INSERT INTO ' + @output_table_name + '(gl_number, account_name, debit_amount, credit_amount) ' + @sql_stmt)
		
		IF @return_value IS NULL
		BEGIN
			IF @@ERROR <> 0
				EXEC spa_ErrorHandler @@ERROR
					, 'spa_Create_MTM_Journal_Entry_Report_Reverse'
					, 'spa_Create_MTM_Journal_Entry_Report_Reverse'
					, 'DB Error'
					, 'Failed to Updated Temp Table.'
					, ''
			ELSE
				EXEC spa_ErrorHandler 0
					, 'spa_Create_MTM_Journal_Entry_Report_Reverse'
					, 'spa_Create_MTM_Journal_Entry_Report_Reverse'
					, 'Success'
					, 'Updated Temp Table.'
					, ''
		END
	END
END 
ELSE 
BEGIN
	CREATE TABLE #ssbm(fas_book_id INT)
	DECLARE @sql_stmt2 VARCHAR(8000)
	
	SET @sql_stmt2 = ' INSERT INTO #ssbm       
						SELECT	distinct book.entity_id
						FROM portfolio_hierarchy book (nolock) 
						INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id 
						INNER JOIN fas_strategy fs on fs.fas_strategy_id = stra.entity_id 
						INNER JOIN fas_books fb on fb.fas_book_id = book.entity_id '   

	IF @subsidiary_id IS NOT NULL        
		SET @sql_stmt2 = @sql_stmt2 + ' AND stra.parent_entity_id IN  ( ' + @subsidiary_id + ') '   
		      
	IF @strategy_id IS NOT NULL        
		SET @sql_stmt2 = @sql_stmt2 + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'    
		    
	IF @book_id IS NOT NULL        
		SET @sql_stmt2 = @sql_stmt2 + ' AND (book.entity_id IN(' + @book_id + ')) ' 
	  
	EXEC spa_print @sql_stmt2
	EXEC(@sql_stmt2)
	
	IF OBJECT_ID('tempdb..#temp') IS NOT NULL 
		DROP TABLE #temp
		
	CREATE TABLE #temp(GLNumberID VARCHAR(250) COLLATE DATABASE_DEFAULT , SourceBookMapID VARCHAR(100) COLLATE DATABASE_DEFAULT  , GLNumber VARCHAR(100) COLLATE DATABASE_DEFAULT  , AccountName VARCHAR(100) COLLATE DATABASE_DEFAULT  , Debit NUMERIC(38,20), Credit NUMERIC(38,20))
	INSERT INTO #temp
	EXEC(@sql_stmt)
	
	--SELECT 'temp'
	--SELECT * FROM #temp
	
	--select DISTINCT gl_account_number from gl_system_mapping

	--SELECT gl_account_number, MAX(first_dot_pos.n), MAX(second_dot_pos.n)
	--, ISNULL(SUBSTRING(ISNULL(gl_account_number, ''''), 1, MAX(first_dot_pos.n) - 1), '''') first_block
	--, ISNULL(SUBSTRING(ISNULL(gl_account_number, ''''), MAX(first_dot_pos.n) + 1, ISNULL(MAX(second_dot_pos.n) - MAX(first_dot_pos.n) - 1, LEN(MAX(first_dot_pos.n)))), '''') second_block
	--, ISNULL(SUBSTRING(ISNULL(gl_account_number, ''''), MAX(second_dot_pos.n) + 1, LEN(gl_account_number)), '''') third_block
	--	FROM gl_system_mapping gsm
		
	--	--find the first occurence of param_value after param_name
	--	OUTER APPLY (
	--		SELECT TOP 1 n
	--		FROM dbo.seq
	--		WHERE 
	--			n <= LEN(gsm.gl_account_number)
	--			AND SUBSTRING(gsm.gl_account_number, n, 1) = ''.'' 
	--		ORDER BY n
	--	) first_dot_pos
	--	OUTER APPLY (
	--		SELECT TOP 1 n
	--		FROM dbo.seq
	--		WHERE 
	--			n > first_dot_pos.n	--index must be greater than first dot position
	--			AND n <= LEN(gsm.gl_account_number)
	--			AND SUBSTRING(gsm.gl_account_number, n, 1) = ''.'' 
				
	--		ORDER BY n
	--	) second_dot_pos

	
	
		
	SET @sql_stmt = 'SELECT ROW_NUMBER() OVER(ORDER BY gl_account_number) AS Number
							--,t.AccountName, mAX(t.GLNumber) GLNUmber
							, CASE WHEN max(debit) = 0 THEN 50 WHEN max(credit) = 0 THEN 40 END [Posting Code]
							--grab the first chunk, i.e 1 to first_dot_pos.n - 1
							, CASE WHEN SUBSTRING(ISNULL(gl_account_number, ''''), 1, MAX(first_dot_pos.n) - 1) = ''''
							THEN ''/''
							ELSE ISNULL(SUBSTRING(ISNULL(gl_account_number, ''''), 1, MAX(first_dot_pos.n) - 1), MAX(t.GLNumber)) END [Account]
							--grab the second chunk
							--CASE 1: second_dot_pos is NULL THEN first_dot_pos.n + 1 to end of the string
							--CASE 2: second_dot_pos is not NULL THEN first_dot_pos.n + 1 to difference between first dot pos and second dot pos - 1
							, CASE WHEN SUBSTRING(ISNULL(gl_account_number, ''''), MAX(first_dot_pos.n) + 1, ISNULL(MAX(second_dot_pos.n) - MAX(first_dot_pos.n) - 1, LEN(MAX(first_dot_pos.n))))= '''' 
							THEN ''/'' ELSE ISNULL(SUBSTRING(ISNULL(gl_account_number, ''''), MAX(first_dot_pos.n) + 1, ISNULL(MAX(second_dot_pos.n) - MAX(first_dot_pos.n) - 1, LEN(MAX(first_dot_pos.n)))), ''/'') END [Internal Order]
							, CAST(MAX(sb_id1.source_system_book_id) as VARCHAR)+ '';'' + max(sb_id2.source_book_name) [Assignment]
							--grab the third chunk, i.e. second dot pos to end of the string
							, CASE WHEN SUBSTRING(ISNULL(gl_account_number, ''''), MAX(second_dot_pos.n) + 1, LEN(gl_account_number)) = ''''
							THEN ''/'' 
							ELSE ISNULL(SUBSTRING(ISNULL(gl_account_number, ''''), MAX(second_dot_pos.n) + 1, LEN(gl_account_number)), ''/'') END [Partner Code]
							, COALESCE(max(sdv.code), MAX(gsm.gl_account_desc1), ''/'') [Flow Code]
							, MAX(ph2.entity_name) + '';'' + MAX(sb_id4.source_book_name) + '';'' + MAX(sb_id3.source_book_name) [Text]
							, CASE WHEN MAX(debit) = 0 THEN MAX(credit) WHEN max(credit) = 0 THEN MAX(debit) END [Amount] 
							' + @str_batch_table + '
					FROM    portfolio_hierarchy ph 
					INNER JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ph.parent_entity_id
					INNER JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph1.parent_entity_id 
					INNER JOIN fas_books fb ON fb.fas_book_id = ph.entity_id
					INNER JOIN #ssbm s ON s.fas_book_id = fb.fas_book_id
					INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = fb.fas_book_id
					INNER JOIN source_book sb_id1 ON sb_id1.source_book_id = ssbm.source_system_book_id1
					INNER JOIN source_book sb_id2 ON sb_id2.source_book_id = ssbm.source_system_book_id2
					INNER JOIN source_book sb_id3 ON sb_id3.source_book_id = ssbm.source_system_book_id3
					INNER JOIN source_book sb_id4 ON sb_id4.source_book_id = ssbm.source_system_book_id4
					LEFT JOIN 
					(
						SELECT source_book_map_id,gl_number_id,gl_codes FROM
						(
							SELECT source_book_map_id,gl_number_id_st_asset,gl_number_id_st_liab,gl_number_id_lt_asset,gl_number_id_lt_liab,gl_number_id_item_st_asset,gl_number_id_item_st_liab,gl_number_id_item_lt_asset,gl_number_id_item_lt_liab,gl_number_id_aoci,gl_number_id_pnl,gl_number_id_set,gl_number_id_cash,gl_number_id_inventory,gl_number_id_expense,gl_number_id_gross_set,gl_id_amortization,gl_id_interest,gl_first_day_pnl,gl_id_st_tax_asset,gl_id_st_tax_liab,gl_id_lt_tax_asset,gl_id_lt_tax_liab,gl_id_tax_reserve,gl_number_unhedged_der_st_asset,gl_number_unhedged_der_lt_asset,gl_number_unhedged_der_st_liab,gl_number_unhedged_der_lt_liab FROM 
							source_book_map_GL_codes 
						) p
						UNPIVOT
						(
							gl_number_id FOR gl_codes IN (gl_number_id_st_asset,gl_number_id_st_liab,gl_number_id_lt_asset,gl_number_id_lt_liab,gl_number_id_item_st_asset,gl_number_id_item_st_liab,gl_number_id_item_lt_asset,gl_number_id_item_lt_liab,gl_number_id_aoci,gl_number_id_pnl,gl_number_id_set,gl_number_id_cash,gl_number_id_inventory,gl_number_id_expense,gl_number_id_gross_set,gl_id_amortization,gl_id_interest,gl_first_day_pnl,gl_id_st_tax_asset,gl_id_st_tax_liab,gl_id_lt_tax_asset,gl_id_lt_tax_liab,gl_id_tax_reserve,gl_number_unhedged_der_st_asset,gl_number_unhedged_der_lt_asset,gl_number_unhedged_der_st_liab,gl_number_unhedged_der_lt_liab)
						) as unpvt
					) q ON q.source_book_map_id = ssbm.book_deal_type_map_id
					LEFT JOIN #temp t ON (t.glnumberid = q.gl_number_id OR t.GLNumberID < 0)
						AND t.SourceBookMapId = ssbm.book_deal_type_map_id 
					LEFT JOIN gl_system_mapping gsm ON gsm.gl_number_id = t.glnumberid
					LEFT JOIN static_data_value sdv ON ph.entity_id = sdv.entity_id
					OUTER APPLY (
						SELECT TOP 1 n
						FROM dbo.seq
						WHERE 
							n <= LEN(gsm.gl_account_number)
							AND SUBSTRING(gsm.gl_account_number, n, 1) = ''.'' 
						ORDER BY n
					) first_dot_pos
					OUTER APPLY (
						SELECT TOP 1 n
						FROM dbo.seq
						WHERE 
							n > first_dot_pos.n	--index must be greater than first dot position
							AND n <= LEN(gsm.gl_account_number)
							AND SUBSTRING(gsm.gl_account_number, n, 1) = ''.'' 
							
						ORDER BY n
					) second_dot_pos
					WHERE ph.hierarchy_level = 0 --AND t.GLNumberID < 0
					GROUP BY t.SourceBookMapId, t.AccountName, gl_account_number'
	--PRINT @sql_stmt
	EXEC(@sql_stmt)
END

/*****************FOR BATCH PROCESSING**********************************/            
/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1 
BEGIN 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)  
	EXEC (@str_batch_table) 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_Create_Reconciliation_Report', 'Journal Entry Report') --TODO: modify sp and report name 
	EXEC (@str_batch_table) 
	RETURN 
END


IF @enable_paging = 1 AND @page_no IS NULL 
BEGIN 
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no) 
	EXEC (@sql_paging) 
END

/*******************************************2nd Paging Batch END**********************************************/    

GO