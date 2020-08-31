IF OBJECT_ID(N'[dbo].[spa_source_book_gl_codes_import]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_source_book_gl_codes_import]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 --===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
 --Create date: 2014-03-24
-- Description: omport data for source book and gl codes.
 
-- Params:
-- @temp_table_name	VARCHAR(100) -- table name ,  
--	@table_id			VARCHAR(100) -- table id,  
--	@job_name			VARCHAR(100) -- job name ,  
--	@process_id			VARCHAR(100) -- process id ,  
--	@user_login_id		VARCHAR(50)  -- user login name 
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_source_book_gl_codes_import]
	@temp_table_name	VARCHAR(400),  
	@table_id			VARCHAR(100),  
	@job_name			VARCHAR(100),  
	@process_id			VARCHAR(100),  
	@user_login_id		VARCHAR(50)  
  
AS

/*
DECLARE @temp_table_name	VARCHAR(100),  
	@table_id			VARCHAR(100),  
	@job_name			VARCHAR(100),  
	@process_id			VARCHAR(100),  
	@user_login_id		VARCHAR(50)  

	SET @temp_table_name =	'adiha_process.dbo.ixp_source_book_gl_codes_import_0_runaj_52D95C20_D77E_47E7_A582_553A02611864'
	SET @table_id	=		'ixp_source_book_gl_codes_import'  
	SET @job_name		=	'importdata_4063_84159BBD_FCF7_4955_9870_C79B63DB4F40'  
	SET @process_id		=	 dbo.FNAGetNewID() 
	SET @user_login_id	=	'runaj'  
  
  --select * from test_import
  --delete  from test_import where temp_id IN (21,22)
 -- BEGIN TRAN 
-- */


--SET @process_id		=	 dbo.FNAGetNewID() 
IF @user_login_id IS NULL OR @user_login_id = ''
	SET @user_login_id = dbo.FNADBUser()

DECLARE @table_name VARCHAR(400)
DECLARE @query VARCHAR(MAX)

DECLARE @begin_time DATETIME
	SET @begin_time = GETDATE()

SET @table_name = @temp_table_name
		
/* adiha process table start for error tracking*/
DECLARE @manditory_error_log VARCHAR(100)
DECLARE @collect_account_no VARCHAR(100)
DECLARE @combined_same_book_identifier VARCHAR(100)
DECLARE @collect_ac_name_ac_number VARCHAR(100)
DECLARE @collect_ac_name_ac_number_changed_named VARCHAR(200)
DECLARE @same_book_identifier_id VARCHAR(100)
DECLARE @effected_rows VARCHAR(100)
DECLARE @duplicate_ac_no_during_import VARCHAR(100)
DECLARE @accounting_treatment VARCHAR(100)
/* adiha process table end */
		
SET @manditory_error_log = dbo.FNAProcessTableName('manditory_error_log', @user_login_id, @process_id)
SET @collect_account_no = dbo.FNAProcessTableName('collect_account_no', @user_login_id, @process_id)
SET @combined_same_book_identifier = dbo.FNAProcessTableName('combined_same_book_identifier', @user_login_id, @process_id)
SET @collect_ac_name_ac_number = dbo.FNAProcessTableName('collect_ac_name_ac_number', @user_login_id, @process_id)
SET @collect_ac_name_ac_number_changed_named = dbo.FNAProcessTableName('collect_ac_name_ac_number_changed_named', @user_login_id, @process_id)
SET @same_book_identifier_id = dbo.FNAProcessTableName('same_book_identifier_id', @user_login_id, @process_id)
SET @effected_rows = dbo.FNAProcessTableName('effected_rows', @user_login_id, @process_id)
SET @duplicate_ac_no_during_import = dbo.FNAProcessTableName('duplicate_ac_no_during_import', @user_login_id, @process_id)
SET @accounting_treatment = dbo.FNAProcessTableName('accounting_treatment', @user_login_id, @process_id)
		
IF OBJECT_ID('tempdb..#check_file_error') IS NOT NULL 
	DROP TABLE #check_file_error 

IF OBJECT_ID('tempdb..#accounting_type_change') IS NOT NULL 
	DROP TABLE #accounting_type_change 

IF OBJECT_ID('tempdb..#already_exists_data') IS NOT NULL 
	DROP TABLE #already_exists_data 

IF OBJECT_ID('tempdb..#gl_mapping_system_codes') IS NOT NULL 
	DROP TABLE #gl_mapping_system_codes 
	
IF OBJECT_ID('tempdb..#total_rows') IS NOT NULL 
	DROP TABLE #total_rows 

IF OBJECT_ID('tempdb..#generic_mapping_names') IS NOT NULL 
	DROP TABLE #generic_mapping_names 


CREATE table #check_file_error([check] CHAR(1) COLLATE DATABASE_DEFAULT )
CREATE TABLE #already_exists_data(account_value VARCHAR(100) COLLATE DATABASE_DEFAULT , 
								real_name VARCHAR(100) COLLATE DATABASE_DEFAULT , temp_id INT)
CREATE TABLE #gl_mapping_system_codes(sub_id INT, account_value VARCHAR(100) COLLATE DATABASE_DEFAULT , 
									account_name VARCHAR(100) COLLATE DATABASE_DEFAULT , ac_desc1 VARCHAR(100) COLLATE DATABASE_DEFAULT , 
									ac_desc2 VARCHAR(100) COLLATE DATABASE_DEFAULT )  
CREATE TABLE #accounting_type_change(fas_deal_type_value_id_before VARCHAR(100) COLLATE DATABASE_DEFAULT , 
									[action] VARCHAR(100) COLLATE DATABASE_DEFAULT , fas_deal_type_value_id_after VARCHAR(100) COLLATE DATABASE_DEFAULT )
CREATE TABLE #total_rows (total_rows INT)

IF OBJECT_ID('tempdb..#book_structure') IS NOT NULL
	DROP TABLE #book_structure

CREATE TABLE #book_structure (
	subsidiary_name VARCHAR(500),
	strategy_name VARCHAR(500),
	book_name VARCHAR(500),
	logical_name VARCHAR(500),
	[level] VARCHAR(50)
)
EXEC('
	INSERT INTO #book_structure
	SELECT subsidiary_name,
		   strategy_name,
		   book_name,
		   logical_name,
		   [level]
	FROM ' + @table_name
)

/* total row for import start */
DECLARE @total_rows INT

SET @query = 'INSERT INTO #total_rows(total_rows)
				SELECT COUNT(1) total_rows 
				FROM ' + @table_name + '' 

exec spa_print @query
EXEC (@query)

SELECT @total_rows = total_rows 
FROM #total_rows

/* total row for import start end */	

SET @query = 'CREATE TABLE ' + @manditory_error_log + ' (column_name VARCHAR(100) , error_desc VARCHAR(5000) , error_type VARCHAR(5000) , temp_id INT)'
exec spa_print @query
EXEC (@query)

SET @query = 'CREATE TABLE ' + @combined_same_book_identifier + ' (Book_Identifier_ID1 VARCHAR(1000) , 
																	Book_Identifier_ID2 VARCHAR(1000) ,
																	Book_Identifier_ID3 VARCHAR(1000) ,
																	Book_Identifier_ID4 VARCHAR(1000) ,
																	[identifier] VARCHAR(1000) , 
																	temp_id INT)'
exec spa_print @query
EXEC (@query)

-- add seq no for temp table to track error line number
SET @query = 'IF COL_LENGTH(''' + @table_name +''', ''temp_id'') IS NULL
				BEGIN
					ALTER TABLE ' + @table_name + '
					ADD temp_id INT IDENTITY
				END '
exec spa_print @query
EXEC (@query)
		
--Manditory field error tracking
	--source system 
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT ''Source_System_ID'', ''Source_System_ID Is Empty'', ''Basic Information Missing'', temp_id
				FROM ' + @table_name + '
				WHERE Source_System_ID IS NULL'
exec spa_print @query
EXEC (@query)

	--subsidiary name 
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT ''Subsidiary_Name'', ''Subsidiary_Name Is Empty'', ''Basic Information Missing'', temp_id
				from ' + @table_name + '
				WHERE Subsidiary_Name IS NULL '
exec spa_print @query
EXEC (@query)

	--straregy name
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT ''Strategy_Name'', ''Strategy_Name Is Empty'', ''Basic Information Missing'', temp_id 
				FROM ' + @table_name + '
				WHERE Strategy_Name IS NULL'
exec spa_print @query
EXEC (@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT ''Book_name'', ''Book_name Is Empty'', ''Basic Information Missing'', temp_id 
				FROM ' + @table_name + '
				WHERE Book_name IS NULL'
exec spa_print @query
EXEC (@query)


	--Book_Identifier1
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT ''Book_Identifier1'', ''Book_Identifier1 Is Empty'', ''Basic Information Missing'', temp_id 
				FROM ' + @table_name + '
				WHERE Book_Identifier1 IS NULL'
exec spa_print @query
EXEC (@query)

	--Book_Identifier2
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT ''Book_Identifier2'', ''Book_Identifier2 Is Empty'', ''Basic Information Missing'', temp_id 
				FROM ' + @table_name + '
				WHERE Book_Identifier2 IS NULL'
exec spa_print @query
EXEC (@query)

	--Book_Identifier3
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT ''Book_Identifier3'', ''Book_Identifier3 Is Empty'', ''Basic Information Missing'', temp_id  
				FROM ' + @table_name + '
				WHERE Book_Identifier3 IS NULL'
exec spa_print @query
EXEC (@query)

	--Book_Identifier4
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT ''Book_Identifier4'', ''Book_Identifier4 Is Empty'', ''Basic Information Missing'', temp_id  
				FROM ' + @table_name + '
				WHERE Book_Identifier4 IS NULL'
exec spa_print @query
EXEC (@query)

	--Accounting_Treatment
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT ''Accounting_Treatment'', ''Accounting_Treatment Is Empty'', ''Basic Information Missing'', temp_id  
				FROM ' + @table_name + '
				WHERE Accounting_Treatment IS NULL'
exec spa_print @query
EXEC (@query)

	--table_code
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT ''table_code'', ''table_code Is Empty'', ''Basic Information Missing'', temp_id  
				FROM ' + @table_name + '
				WHERE table_code IS NULL'
exec spa_print @query
EXEC (@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT a.logical_name, ''Duplicate Logical Name not allowed ['' + a.logical_name + '']'' ,''Duplicate data error'', a.temp_id
				FROM  ' + @table_name + ' a 
				INNER JOIN (SELECT logical_name FROM ' + @table_name + '
							GROUP BY logical_name HAVING COUNT(logical_name) > 1) b 
				ON a.logical_name = b.logical_name'
EXEC (@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT a.logical_name, ''Duplicate Logical Name not allowed ['' + a.logical_name + '']'' ,''Duplicate data error'', a.temp_id
				FROM  ' + @table_name + ' a 
				INNER JOIN (SELECT logical_name FROM ' + @table_name + '
							GROUP BY logical_name HAVING COUNT(logical_name) > 1) b 
				ON a.logical_name = b.logical_name'
EXEC (@query)	

--SET @query = '  INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
--				SELECT bs.logical_name, ''Logical Name ['' + bs.logical_name + ''] already exists.'', ''Duplicate Data Error'', bs.temp_id
--				FROM ' + @table_name + ' bs
--				INNER JOIN source_system_book_map ssbm
--					ON bs.logical_name = ssbm.logical_name'
--EXEC(@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT a.logical_name, ''Duplicate Combination of Book Identifier1 ['' + a.book_identifier1 + ''], Book Identifier2 ['' + a.book_identifier2 + ''], Book Identifier3 ['' + a.book_identifier3 + ''], Book Identifier4 ['' + a.book_identifier4 + ''] and Accounting Treatment ['' + a.accounting_treatment + ''] is not allowed '' ,
				''Duplicate data error'', a.temp_id
				FROM ' + @table_name + ' a 
				INNER JOIN (SELECT book_identifier1, book_identifier2, book_identifier3, book_identifier4, accounting_treatment FROM ' + @table_name + '
							GROUP BY book_identifier1, book_identifier2, book_identifier3, book_identifier4, accounting_treatment HAVING COUNT(1) > 1) b 
				ON a.book_identifier1 = b.book_identifier1 AND a.book_identifier2 = b.book_identifier2 
				AND a.book_identifier3 = b.book_identifier3 AND a.book_identifier4 = b.book_identifier4 AND a.accounting_treatment = b.accounting_treatment'
EXEC (@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT b.book_identifier1, ''Book Identifier1 ['' + b.book_identifier1 + ''] cannot have multiple Book Identifier ID1 value'', ''Duplicate data error'', temp.temp_id
				FROM (SELECT book_identifier1
				FROM (
					SELECT book_identifier1, ISNULL(book_identifier_ID1, -1)book_identifier_ID1
					FROM ' + @table_name + '
					GROUP BY book_identifier1, book_identifier_ID1 ) a
				GROUP BY a.book_identifier1
				HAVING COUNT(a.book_identifier_ID1) > 1) b 
				INNER JOIN ' + @table_name + ' temp
				ON temp.book_identifier1 = b.book_identifier1'
EXEC(@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT b.book_identifier2, ''Book Identifier2 ['' + b.book_identifier2 + ''] cannot have multiple Book Identifier ID2 value'', ''Duplicate data error'', temp.temp_id
				FROM (SELECT book_identifier2
				FROM (
					SELECT book_identifier2, ISNULL(book_identifier_ID2, -1) book_identifier_ID2
					FROM ' + @table_name + '
					GROUP BY book_identifier2, book_identifier_ID2 ) a
				GROUP BY a.book_identifier2
				HAVING COUNT(a.book_identifier_ID2) > 1) b 
				INNER JOIN ' + @table_name + ' temp
				ON temp.book_identifier2 = b.book_identifier2'
EXEC(@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT b.book_identifier3, ''Book Identifier3 ['' + b.book_identifier3 + ''] cannot have multiple Book Identifier ID3 value'', ''Duplicate data error'', temp.temp_id
				FROM (SELECT book_identifier3
				FROM (
					SELECT book_identifier3, ISNULL(book_identifier_ID3, -1) book_identifier_ID3
					FROM ' + @table_name + '
					GROUP BY book_identifier3, book_identifier_ID3 ) a
				GROUP BY a.book_identifier3
				HAVING COUNT(a.book_identifier_ID3) > 1) b 
				INNER JOIN ' + @table_name + ' temp
				ON temp.book_identifier3 = b.book_identifier3'
EXEC(@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT b.book_identifier4, ''Book Identifier4 ['' + b.book_identifier4 + ''] cannot have multiple Book Identifier ID4 value'', ''Duplicate data error'', temp.temp_id
				FROM (SELECT book_identifier4
				FROM (
					SELECT book_identifier4, ISNULL(book_identifier_ID4, -1) book_identifier_ID4
					FROM ' + @table_name + '
					GROUP BY book_identifier4, book_identifier_ID4 ) a
				GROUP BY a.book_identifier4
				HAVING COUNT(a.book_identifier_ID4) > 1) b 
				INNER JOIN ' + @table_name + ' temp
				ON temp.book_identifier4 = b.book_identifier4'
EXEC(@query)
------------------------------------------------
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)						
				SELECT b.book_identifier_ID1, ''Book Identifier ID1 ['' + b.book_identifier_ID1 + ''] cannot have multiple Book Identifier1 value'' , ''Duplicate data error'', temp.temp_id
				FROM (SELECT book_identifier_ID1
					 FROM (
						SELECT book_identifier1, book_identifier_ID1
						FROM ' + @table_name + '
						GROUP BY book_identifier1, book_identifier_ID1 ) a
					GROUP BY book_identifier_ID1
					HAVING COUNT(book_identifier1) > 1) b 
				INNER JOIN ' + @table_name + ' temp
				ON temp.book_identifier_ID1 = b.book_identifier_ID1'
EXEC(@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)						
				SELECT b.book_identifier_ID2, ''Book Identifier ID2 ['' + b.book_identifier_ID2 + ''] cannot have multiple Book Identifier2 value'' , ''Duplicate data error'', temp.temp_id
				FROM (SELECT book_identifier_ID2
					 FROM (
						SELECT book_identifier2, book_identifier_ID2
						FROM ' + @table_name + '
						GROUP BY book_identifier2, book_identifier_ID2 ) a
					GROUP BY book_identifier_ID2
					HAVING COUNT(book_identifier2) > 1) b 
				INNER JOIN ' + @table_name + ' temp
				ON temp.book_identifier_ID2 = b.book_identifier_ID2'
EXEC(@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)						
				SELECT b.book_identifier_ID3, ''Book Identifier ID3 ['' + b.book_identifier_ID3 + ''] cannot have multiple Book Identifier3 value'' , ''Duplicate data error'', temp.temp_id
				FROM (SELECT book_identifier_ID3
					 FROM (
						SELECT book_identifier3, book_identifier_ID3
						FROM ' + @table_name + '
						GROUP BY book_identifier3, book_identifier_ID3 ) a
					GROUP BY book_identifier_ID3
					HAVING COUNT(book_identifier3) > 1) b 
				INNER JOIN ' + @table_name + ' temp
				ON temp.book_identifier_ID3 = b.book_identifier_ID3'
EXEC(@query)

SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)						
				SELECT b.book_identifier_ID4, ''Book Identifier ID4 ['' + b.book_identifier_ID4 + ''] cannot have multiple Book Identifier4 value'' , ''Duplicate data error'', temp.temp_id
				FROM (SELECT book_identifier_ID4
					 FROM (
						SELECT book_identifier4, book_identifier_ID4
						FROM ' + @table_name + '
						GROUP BY book_identifier4, book_identifier_ID4 ) a
					GROUP BY book_identifier_ID4
					HAVING COUNT(book_identifier4) > 1) b 
				INNER JOIN ' + @table_name + ' temp
				ON temp.book_identifier_ID4 = b.book_identifier_ID4'
EXEC(@query)
/*
--same combination for already exists
SET @query = '
			INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT  
					DISTINCT ti.Book_Identifier1 + '' : '' + ti.Book_Identifier2 + '' : '' + ti.Book_Identifier3 + '' : '' + ti.Book_Identifier4
						, ti.Book_Identifier1 + '' : '' + ti.Book_Identifier2 + '' : '' + ti.Book_Identifier3 + '' : '' + ti.Book_Identifier4 + '' Source Book Mapping Already Exists.''
						, ''Source Book Mapping Already Exists''
						, temp_id 
				FROM ' + @table_name + ' ti 
				INNER JOIN source_book sb1 ON sb1.source_book_name = ti.Book_Identifier1 and sb1.source_system_book_type_value_id = 50
				INNER JOIN source_book sb2 ON sb2.source_book_name = ti.Book_Identifier2 and sb2.source_system_book_type_value_id = 51
				INNER JOIN source_book sb3 ON sb3.source_book_name = ti.Book_Identifier3 and sb3.source_system_book_type_value_id = 52
				INNER JOIN source_book sb4 ON sb4.source_book_name = ti.Book_Identifier4 and sb4.source_system_book_type_value_id = 53
				LEFT JOIN source_system_book_map ssbm ON 1 = 1
					and ssbm.source_system_book_id1 = sb1.source_book_id
					AND ssbm.source_system_book_id2 = sb2.source_book_id
					AND ssbm.source_system_book_id3 = sb3.source_book_id
					AND ssbm.source_system_book_id4 = sb4.source_book_id
				LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
					AND book.hierarchy_level = 0
				WHERE book.entity_name <> ti.book_name
				' 
exec spa_print @query
EXEC (@query)
*/
--check accounting treatment
SET @query = ' SELECT Accounting_Treatment 
					INTO ' + @accounting_treatment + '
				FROM (SELECT Accounting_Treatment  Accounting_Treatment
					FROM ' + @table_name + ' 
					WHERE Accounting_Treatment IS NOT NULL 
					EXCEPT
					SELECT code Accounting_Treatment 
					FROM static_data_value 
					WHERE [type_id] = 400) a'
exec spa_print @query
EXEC (@query)

--source book error log
SET @query = 'INSERT INTO ' + @manditory_error_log + ' (column_name, error_desc, error_type, temp_id)
				SELECT at.Accounting_Treatment,  at.Accounting_Treatment + '' : Accounting Treatment Not Found'', ''Accounting Treatment Not Found'' , ti.temp_id
				FROM ' + @accounting_treatment + ' at 
				INNER JOIN ' + @table_name + ' ti ON ti.Accounting_Treatment = at.Accounting_Treatment'
			
exec spa_print @query
EXEC (@query)

--EXEC('select * from ' + @manditory_error_log)

--gl account number validation		
--get account names and numbers
SET @query = 'SELECT DISTINCT * 
					INTO  ' + @collect_ac_name_ac_number + ' 
				FROM (SELECT ti.subsidiary_name sub_name
								, ti.Hedge_ST_Asset
								, ti.Hedge_LT_Asset
								, ti.[Hedge_ST_Liab]
								, ti.[Hedge_LT_Liab]
								, ti.[AOCI/Hedge_Reserve]
								, ti.[Earnings] 
								, ti.Item_ST_Asset
								, ti.Item_ST_Liab
								, ti.Item_LT_Asset
								, ti.Item_LT_Liab
								, ti.Unrealized_Earnings
								, ti.Cash
								, ti.Inventory
								, ti.Expense
								, ti.Gross_Settlement
								, ti.Amortization
								, ti.Interest
								, ti.First_Day_PNL
								, ti.ST_Tax_Asset
								, ti.ST_Tax_Liab
								, ti.LT_Tax_Asset
								, ti.LT_Tax_Liab
								, ti.Tax_Reserve
								, ti.Unhedged_ST_Asset
								, ti.Unhedged_LT_Asset
								, ti.Unhedged_ST_Liab
								, ti.Unhedged_LT_Liab
								, [A/C_Description1] ac_desc1
								, [A/C_Description2] ac_desc2
								, temp_id
						FROM ' + @table_name + ' ti
						--INNER JOIN portfolio_hierarchy sub ON sub.entity_name = ti.subsidiary_name
						) t
						UNPIVOT (
							[account_value]
							FOR [account_name]
							IN (Hedge_ST_Asset
								, Hedge_LT_Asset
								, [Hedge_ST_Liab]
								, [Hedge_LT_Liab]
								, [AOCI/Hedge_Reserve]
								, [Earnings]
								, Item_ST_Asset
								, Item_ST_Liab
								, Item_LT_Asset
								, Item_LT_Liab
								, Unrealized_Earnings
								, Cash
								, Inventory
								, Expense
								, Gross_Settlement
								, Amortization
								, Interest
								, First_Day_PNL
								, ST_Tax_Asset
								, ST_Tax_Liab
								, LT_Tax_Asset
								, LT_Tax_Liab
								, Tax_Reserve
								, Unhedged_ST_Asset
								, Unhedged_LT_Asset
								, Unhedged_ST_Liab
								, Unhedged_LT_Liab)
						) AS unpvt		
				WHERE ISNULL([account_value], '''') <> '''''
exec spa_print @query
EXEC (@query)

SET @query = 'SELECT sub_name, canan.account_value
					, canan.account_name account_name
					, canan.account_name real_name
					, canan.ac_desc1
					, canan.ac_desc2
					, temp_id
					INTO ' + @collect_ac_name_ac_number_changed_named + ' 
				FROM ' + @collect_ac_name_ac_number + ' canan'
exec spa_print @query
EXEC (@query)

--delete error data
SET @query = 'DELETE ti
				FROM ' + @table_name + ' ti 
				INNER JOIN ' + @manditory_error_log + ' mel ON ti.temp_id = mel.temp_id'
																				
exec spa_print @query
EXEC (@query)

BEGIN TRY	
	BEGIN TRAN 
		--insert subs
		SET @query = 'MERGE portfolio_hierarchy AS T
						USING (SELECT DISTINCT subsidiary_name FROM ' + @table_name + ') AS S
						ON (T.entity_name = S.subsidiary_name) AND T.hierarchy_level = 2
						WHEN NOT MATCHED BY TARGET
							THEN INSERT(entity_name, entity_type_value_id, hierarchy_level, parent_entity_id)  
								VALUES (S.subsidiary_name, 525, 2, NULL);'
		exec spa_print @query
		EXEC (@query)	
		
		--insert stra
		SET @query = 'MERGE portfolio_hierarchy AS T
						USING (SELECT DISTINCT ti.subsidiary_name, ti.Strategy_Name, sub.entity_id sub_id 
								FROM ' + @table_name + ' ti
								INNER JOIN portfolio_hierarchy sub on sub.entity_name = sub.entity_name
									AND sub.entity_name = ti.subsidiary_name
									AND sub.hierarchy_level = 2) AS S 
						ON (T.entity_name = S.Strategy_Name) 
							AND T.hierarchy_level = 1 
							AND t.parent_entity_id = sub_id
						WHEN NOT MATCHED BY TARGET
							THEN INSERT(entity_name, entity_type_value_id, hierarchy_level, parent_entity_id)
								VALUES(s.Strategy_Name, 526, 1, s.sub_id);'
		exec spa_print @query
		EXEC (@query)
		
		--insert book
		SET @query = 'MERGE portfolio_hierarchy AS T
						USING (SELECT DISTINCT stra.entity_id stra_id, ti.Book_Name, ti.subsidiary_name, ti.Strategy_Name
								FROM ' + @table_name + ' ti
								INNER JOIN portfolio_hierarchy sub ON sub.entity_name = ti.subsidiary_name
									AND sub.hierarchy_level = 2
								INNER JOIN portfolio_hierarchy stra ON stra.parent_entity_id = sub.entity_id
									AND stra.hierarchy_level = 1
									AND stra.entity_name = ti.Strategy_Name
									) AS S 
						ON (T.entity_name = S.Book_Name) 
							AND T.hierarchy_level = 0 
							AND t.parent_entity_id = stra_id
						WHEN NOT MATCHED BY TARGET
							THEN INSERT(entity_name, entity_type_value_id, hierarchy_level, parent_entity_id)   
								VALUES(s.Book_Name, 527, 0, s.stra_id);'
		exec spa_print @query
		EXEC (@query)

		--insert fas_subsidiariess
		SET @query = 'INSERT INTO fas_subsidiaries(fas_subsidiary_id, entity_type_value_id, disc_source_value_id, disc_type_value_id, func_cur_value_id, days_in_year, long_term_months, entity_name, address1, address2, city, state_value_id, zip_code, country_value_id, entity_url, tax_payer_id, contact_user_id, primary_naics_code_id, secondary_naics_code_id, entity_category_id, entity_sub_category_id, utility_type_id, ticker_symbol_id, ownership_status, partners, holding_company, domestic_vol_initiatives, domestic_registeries, international_registeries, confidentiality_info, exclude_indirect_emissions, organization_boundaries, base_year_from, base_year_to, tax_perc, discount_curve_id, risk_free_curve_id, counterparty_id)
						SELECT DISTINCT sub.entity_id, 650, 100, 128, cur.source_currency_id, 365, 13, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, dbo.FNADBUser(), NULL, NULL, 1125, 1162, 1177, NULL, ''w'', NULL, ''Y'', NULL, NULL, NULL, ''n'', ''n'', 1102, NULL, NULL, NULL, NULL, NULL, NULL	
						FROM ' + @table_name + ' ti
						INNER JOIN portfolio_hierarchy sub ON sub.entity_name = ti.subsidiary_name
							AND sub.hierarchy_level = 2
						LEFT JOIN fas_subsidiaries fs on fs.fas_subsidiary_id = sub.entity_id
						CROSS JOIN (SELECT TOP 1 source_currency_id FROM source_currency WHERE currency_id = ''EUR'' AND source_system_id = 2) cur
						WHERE fs.fas_subsidiary_id IS NULL'
		exec spa_print @query
		EXEC (@query)
		
		--insert into fas_strategy
		SET @query = 'INSERT INTO fas_strategy(fas_strategy_id, source_system_id, hedge_type_value_id, fx_hedge_flag, mes_gran_value_id, gl_grouping_value_id, no_links, no_links_fas_eff_test_profile_id, mes_cfv_value_id, mes_cfv_values_value_id, mismatch_tenor_value_id, strip_trans_value_id, asset_liab_calc_value_id, test_range_from, test_range_to, additional_test_range_from, additional_test_range_to, include_unlinked_hedges, include_unlinked_items, gl_number_id_st_asset, gl_number_id_st_liab, gl_number_id_lt_asset, gl_number_id_lt_liab, gl_number_id_item_st_asset, gl_number_id_item_st_liab, gl_number_id_item_lt_asset, gl_number_id_item_lt_liab, gl_number_id_aoci, gl_number_id_pnl, gl_number_id_set, gl_number_id_cash, oci_rollout_approach_value_id, additional_test_range_from2, additional_test_range_to2, gl_number_id_inventory, gl_number_id_expense, options_premium_approach, gl_number_id_gross_set, gl_id_amortization, gl_id_interest, base_year_from, base_year_to, subentity_name, subentity_desc, relationship_to_entity, distinct_estimation_method, distinct_output_metrics, distinct_foreign_country, primary_naics_code_id, secondary_naics_code_id, organization_boundary_id, sub_entity, rollout_per_type, first_day_pnl_threshold, gl_first_day_pnl, gl_id_st_tax_asset, gl_id_st_tax_liab, gl_id_lt_tax_asset, gl_id_lt_tax_liab, gl_id_tax_reserve, gl_tenor_option, fun_cur_value_id)
						SELECT DISTINCT stra.entity_id ,2, 150, ''n'', 176, 352, ''n'', NULL, 200, 227, 252, 625, 277, 0.8, 1.25, NULL, NULL, ''y'', ''n'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 500, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1102, ''y'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ''f'', NULL	
						FROM ' + @table_name + ' ti 
						INNER JOIN portfolio_hierarchy sub ON sub.entity_name = ti.subsidiary_name 
							AND sub.hierarchy_level = 2
						INNER JOIN portfolio_hierarchy stra ON sub.entity_id = stra.parent_entity_id
							AND stra.hierarchy_level = 1
							AND stra.entity_name = ti.Strategy_Name
						LEFT JOIN fas_strategy fs on fs.fas_strategy_id = stra.entity_id
						WHERE fs.fas_strategy_id IS NULL'
		EXEC (@query)
		
		--insert fas_books
		SET @query = 'INSERT INTO fas_books(fas_book_id, no_link, no_links_fas_eff_test_profile_id, gl_number_id_st_asset, gl_number_id_st_liab, gl_number_id_lt_asset, gl_number_id_lt_liab, gl_number_id_item_st_asset, gl_number_id_item_st_liab, gl_number_id_item_lt_asset, gl_number_id_item_lt_liab, gl_number_id_aoci, gl_number_id_pnl, gl_number_id_set, gl_number_id_cash, gl_number_id_inventory, gl_number_id_expense, gl_number_id_gross_set, gl_id_amortization, gl_id_interest, convert_uom_id, cost_approach_id, gl_id_st_tax_asset, gl_id_st_tax_liab, gl_id_lt_tax_asset, gl_id_lt_tax_liab, gl_id_tax_reserve, legal_entity, tax_perc, hedge_item_same_sign, fun_cur_value_id, hedge_type_value_id, gl_first_day_pnl)
						SELECT  DISTINCT book.entity_id, ''n'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, uom.source_uom_id, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ''n'', NULL, NULL, NULL
						FROM ' + @table_name + ' ti 
						INNER JOIN portfolio_hierarchy sub ON sub.entity_name = ti.subsidiary_name 
							AND sub.hierarchy_level = 2
						INNER JOIN portfolio_hierarchy stra ON sub.entity_id = stra.parent_entity_id
							AND stra.hierarchy_level = 1
							AND stra.entity_name = ti.Strategy_Name
						INNER JOIN portfolio_hierarchy book ON stra.entity_id = book.parent_entity_id
							AND book.hierarchy_level = 0
							AND book.entity_name = ti.book_name
						LEFT JOIN fas_books fb on fb.fas_book_id = book.entity_id
						CROSS JOIN (SELECT TOP 1 source_uom_id FROM source_uom WHERE uom_name = ''MWh'' AND source_system_id = 2) uom
						WHERE fb.fas_book_id IS NULL'
		EXEC (@query)
		
		--source_book
			--50
		SET @query = 'MERGE source_book AS T
						USING (SELECT DISTINCT Book_Identifier1, Book_Identifier_ID1 FROM ' + @table_name + ') AS S
						ON (T.source_book_name = S.Book_Identifier1)  AND T.source_system_book_type_value_id = 50
						WHEN NOT MATCHED BY TARGET
							THEN INSERT(source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc, source_parent_book_id, source_parent_type)
								VALUES (2, ISNULL(s.Book_Identifier_ID1, s.Book_Identifier1), 50, s.Book_Identifier1, s.Book_Identifier1, NULL, NULL)
						WHEN MATCHED 
						THEN UPDATE SET T.source_system_book_id = ISNULL(s.Book_Identifier_ID1, s.Book_Identifier1);'
		exec spa_print @query
		EXEC (@query)

			--51
		SET @query = 'MERGE source_book AS T
						USING (SELECT DISTINCT Book_Identifier2, Book_Identifier_ID2 
								FROM ' + @table_name + ') AS S
						ON (T.source_book_name = s.Book_Identifier2)  AND T.source_system_book_type_value_id = 51
						WHEN NOT MATCHED BY TARGET
							THEN INSERT(source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc, source_parent_book_id, source_parent_type)
								VALUES (2, ISNULL(s.Book_Identifier_ID2, s.Book_Identifier2), 51, s.Book_Identifier2, s.Book_Identifier2, NULL, NULL)
						WHEN MATCHED 
							THEN UPDATE SET T.source_system_book_id = ISNULL(s.Book_Identifier_ID2, s.Book_Identifier2);'
		exec spa_print @query
		EXEC (@query)
			
		--52
		SET @query = 'MERGE source_book AS T
						USING (SELECT DISTINCT Book_Identifier3, Book_Identifier_ID3 FROM ' + @table_name + ') AS S
						ON (T.source_book_name = s.Book_Identifier3)  AND T.source_system_book_type_value_id = 52
						WHEN NOT MATCHED BY TARGET
							THEN INSERT(source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc, source_parent_book_id, source_parent_type)
								VALUES (2, ISNULL(s.Book_Identifier_ID3, s.Book_Identifier3), 52, s.Book_Identifier3, s.Book_Identifier3, NULL, NULL)
						--WHEN MATCHED 
						--	THEN UPDATE SET T.source_system_book_id = ISNULL(s.Book_Identifier_ID3, s.Book_Identifier3)
						;'
		exec spa_print @query
		EXEC (@query)
			
		--53
		SET @query = 'MERGE source_book AS T
						USING (SELECT DISTINCT Book_Identifier4, Book_Identifier_ID4 FROM ' + @table_name + ') AS S
						ON (T.source_book_name = s.Book_Identifier4)  AND T.source_system_book_type_value_id = 53
						WHEN NOT MATCHED BY TARGET
							THEN INSERT(source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc, source_parent_book_id, source_parent_type)
								VALUES (2, ISNULL(s.Book_Identifier_ID4, s.Book_Identifier4), 53, s.Book_Identifier4, s.Book_Identifier4, NULL, NULL)
						--WHEN MATCHED 
						--	THEN UPDATE SET T.source_system_book_id = ISNULL(s.Book_Identifier_ID4, s.Book_Identifier4)
						;'
		exec spa_print @query
		EXEC (@query)			

		--source_system_book_map
		SET @query = 'MERGE source_system_book_map AS T
						USING (SELECT 
								 sb.source_book_id source_book_id1, Book_Identifier1
									, sb1.source_book_id source_book_id2, Book_Identifier2
									, sb2.source_book_id source_book_id3, Book_Identifier3
									, sb3.source_book_id source_book_id4, Book_Identifier4
									, acc_type.value_id acc_type
									, MAX(book.entity_id) book_id
									, MAX(logical_name) logical_name
								FROM ' + @table_name + ' ti
								INNER JOIN source_book sb ON sb.source_book_name = ti.Book_Identifier1 AND sb.source_system_book_type_value_id = 50 
								INNER JOIN source_book sb1 ON sb1.source_book_name = ti.Book_Identifier2 AND sb1.source_system_book_type_value_id = 51
								INNER JOIN source_book sb2 ON sb2.source_book_name = ti.Book_Identifier3 AND sb2.source_system_book_type_value_id = 52
								INNER JOIN source_book sb3 ON sb3.source_book_name = ti.Book_Identifier4 AND sb3.source_system_book_type_value_id = 53
								INNER JOIN static_data_value acc_type ON acc_type.code = ti.Accounting_Treatment
								INNER JOIN portfolio_hierarchy book ON book.entity_name = ti.Book_Name
									AND book.hierarchy_level = 0
								INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
									AND stra.entity_name = ti.Strategy_Name
									AND stra.hierarchy_level = 1
								INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
									AND sub.entity_name = ti.Subsidiary_Name
									AND sub.hierarchy_level = 2
								GROUP BY sb.source_book_id , Book_Identifier1
									, sb1.source_book_id , Book_Identifier2
									, sb2.source_book_id , Book_Identifier3
									, sb3.source_book_id , Book_Identifier4
									, acc_type.value_id
									--, book.entity_id
									) AS S
						ON (T.source_system_book_id1 = S.source_book_id1  
							AND T.source_system_book_id2 = S.source_book_id2  
							AND T.source_system_book_id3 = S.source_book_id3  
							AND T.source_system_book_id4 = S.source_book_id4)  
						WHEN NOT MATCHED BY TARGET
							THEN INSERT(fas_book_id, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, fas_deal_type_value_id, logical_name)		
							VALUES (s.book_id, s.source_book_id1, s.source_book_id2, s.source_book_id3, s.source_book_id4, s.acc_type, s.logical_name)
						WHEN MATCHED 
							THEN UPDATE SET fas_book_id = s.book_id
											, fas_deal_type_value_id = s.acc_type
											, logical_name = s.logical_name
							OUTPUT deleted.fas_deal_type_value_id, $action, inserted.fas_deal_type_value_id INTO #accounting_type_change;'
		exec spa_print @query
		EXEC (@query)
		
		
		--gl_system_mapping
		SET @query = 'INSERT INTO #gl_mapping_system_codes(sub_id, account_value, account_name, ac_desc1, ac_desc2) 
						SELECT DISTINCT sub_id, account_value, account_name, ac_desc1, ac_desc2
						FROM (SELECT sub.entity_id sub_id
									, ti.Hedge_ST_Asset
									, ti.Hedge_LT_Asset
									, ti.[Hedge_ST_Liab]
									, ti.[Hedge_LT_Liab]
									, ti.[AOCI/Hedge_Reserve]
									, ti.[Earnings] 
									, ti.Item_ST_Asset
									, ti.Item_ST_Liab
									, ti.Item_LT_Asset
									, ti.Item_LT_Liab
									, ti.Unrealized_Earnings
									, ti.Cash
									, ti.Inventory
									, ti.Expense
									, ti.Gross_Settlement
									, ti.Amortization
									, ti.Interest
									, ti.First_Day_PNL
									, ti.ST_Tax_Asset
									, ti.ST_Tax_Liab
									, ti.LT_Tax_Asset
									, ti.LT_Tax_Liab
									, ti.Tax_Reserve
									, ti.Unhedged_ST_Asset
									, ti.Unhedged_LT_Asset
									, ti.Unhedged_ST_Liab
									, ti.Unhedged_LT_Liab
									, [A/C_Description1] ac_desc1
									, [A/C_Description2] ac_desc2
									, temp_id
							FROM ' + @table_name + ' ti
							INNER JOIN portfolio_hierarchy sub ON sub.entity_name = ti.subsidiary_name
								AND sub.hierarchy_level = 2
						) t
						UNPIVOT (
							[account_value]
							FOR [account_name]
							IN (Hedge_ST_Asset, Hedge_LT_Asset, [Hedge_ST_Liab], [Hedge_LT_Liab], [AOCI/Hedge_Reserve], [Earnings]
								, Item_ST_Asset
								, Item_ST_Liab
								, Item_LT_Asset
								, Item_LT_Liab
								, Unrealized_Earnings
								, Cash
								, Inventory
								, Expense
								, Gross_Settlement
								, Amortization
								, Interest
								, First_Day_PNL
								, ST_Tax_Asset
								, ST_Tax_Liab
								, LT_Tax_Asset
								, LT_Tax_Liab
								, Tax_Reserve
								, Unhedged_ST_Asset
								, Unhedged_LT_Asset
								, Unhedged_ST_Liab
								, Unhedged_LT_Liab)
						) AS unpvt		
				WHERE ISNULL([account_value], '''') <> '''''
		exec spa_print @query
		EXEC (@query)
		
		--insert into gl_system_mapping
		SET @query = 'MERGE gl_system_mapping AS T
						USING (SELECT MAX(sub_id) sub_id, account_value, ISNULL(clm2_value, CASE 
																								WHEN canan.account_name = ''Hedge_ST_Asset'' THEN ''Hedge ST Asset''
																								WHEN canan.account_name = ''Hedge_LT_Asset'' THEN ''Hedge LT Asset''
																								WHEN canan.account_name = ''Hedge_ST_Liab'' THEN ''Hedge ST Liability''
																								WHEN canan.account_name = ''Hedge_LT_Liab'' THEN ''Hedge LT Liability''
																								WHEN canan.account_name = ''Item_ST_Asset'' THEN ''Item ST Asset''
																								WHEN canan.account_name = ''Item_ST_Liab'' THEN ''Item ST Liab''
																								WHEN canan.account_name = ''Item_LT_Asset'' THEN ''Item LT Asset''
																								WHEN canan.account_name = ''Item_LT_Liab'' THEN ''Item LT Liab''
																								WHEN canan.account_name = ''AOCI/Hedge_Reserve'' THEN ''AOCI/Hedge Reserve''
																								WHEN canan.account_name = ''Unrealized_Earnings'' THEN ''Unrealized Earnings''
																								WHEN canan.account_name = ''Gross_Settlement'' THEN ''Gross Settlement''
																								WHEN canan.account_name = ''First_Day_PNL'' THEN ''First Day PNL''
																								WHEN canan.account_name = ''ST_Tax_Asset'' THEN ''ST Tax Asset''
																								WHEN canan.account_name = ''ST_Tax_Liab'' THEN ''ST Tax Liab''
																								WHEN canan.account_name = ''LT_Tax_Asset'' THEN ''LT Tax Asset''
																								WHEN canan.account_name = ''LT_Tax_Liab'' THEN ''LT Tax Liab''
																								WHEN canan.account_name = ''Tax_Reserve'' THEN ''Tax Reserve''
																								WHEN canan.account_name = ''Unhedged_ST_Asset'' THEN ''Unhedged ST Asset''
																								WHEN canan.account_name = ''Unhedged_LT_Asset'' THEN ''Unhedged LT Asset''
																								WHEN canan.account_name = ''Unhedged_ST_Liab'' THEN ''Unhedged ST Liab''
																								WHEN canan.account_name = ''Unhedged_LT_Liab'' THEN ''Unhedged LT Liab''
																							ELSE canan.account_name
																								END) account_name
								, max(ac_desc1) ac_desc1
								, max(ac_desc2) ac_desc2
							FROM #gl_mapping_system_codes canan 
							LEFT JOIN generic_mapping_values gmv ON clm1_value = canan.account_name
							LEFT JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
								AND gmh.mapping_name = ''Map GL Code''
							GROUP BY account_value, ISNULL(clm2_value, CASE WHEN canan.account_name = ''Hedge_ST_Asset'' THEN ''Hedge ST Asset''
																	WHEN canan.account_name = ''Hedge_LT_Asset'' THEN ''Hedge LT Asset''
																	WHEN canan.account_name = ''Hedge_ST_Liab'' THEN ''Hedge ST Liability''
																	WHEN canan.account_name = ''Hedge_LT_Liab'' THEN ''Hedge LT Liability''
																	WHEN canan.account_name = ''Item_ST_Asset'' THEN ''Item ST Asset''
																	WHEN canan.account_name = ''Item_ST_Liab'' THEN ''Item ST Liab''
																	WHEN canan.account_name = ''Item_LT_Asset'' THEN ''Item LT Asset''
																	WHEN canan.account_name = ''Item_LT_Liab'' THEN ''Item LT Liab''
																	WHEN canan.account_name = ''AOCI/Hedge_Reserve'' THEN ''AOCI/Hedge Reserve''
																	WHEN canan.account_name = ''Unrealized_Earnings'' THEN ''Unrealized Earnings''
																	WHEN canan.account_name = ''Gross_Settlement'' THEN ''Gross Settlement''
																	WHEN canan.account_name = ''First_Day_PNL'' THEN ''First Day PNL''
																	WHEN canan.account_name = ''ST_Tax_Asset'' THEN ''ST Tax Asset''
																	WHEN canan.account_name = ''ST_Tax_Liab'' THEN ''ST Tax Liab''
																	WHEN canan.account_name = ''LT_Tax_Asset'' THEN ''LT Tax Asset''
																	WHEN canan.account_name = ''LT_Tax_Liab'' THEN ''LT Tax Liab''
																	WHEN canan.account_name = ''Tax_Reserve'' THEN ''Tax Reserve''
																	WHEN canan.account_name = ''Unhedged_ST_Asset'' THEN ''Unhedged ST Asset''
																	WHEN canan.account_name = ''Unhedged_LT_Asset'' THEN ''Unhedged LT Asset''
																	WHEN canan.account_name = ''Unhedged_ST_Liab'' THEN ''Unhedged ST Liab''
																	WHEN canan.account_name = ''Unhedged_LT_Liab'' THEN ''Unhedged LT Liab''
																	ELSE canan.account_name
																	END)) AS s
							ON T.gl_account_name = s.account_name
								AND T.gl_account_number = s.account_value
						WHEN NOT MATCHED BY TARGET
							THEN INSERT(fas_subsidiary_id, gl_account_name, gl_account_number, gl_account_desc1, gl_account_desc2)
								VALUES (s.sub_id, s.account_name, s.account_value, ac_desc1, ac_desc2)
						WHEN MATCHED 
							THEN UPDATE SET gl_account_desc1 = ac_desc1, 
											gl_account_desc2 = ac_desc2;'

		
		exec spa_print @query
		EXEC (@query)
		
		SELECT DISTINCT  canan.account_name real_name, ISNULL(clm2_value, CASE WHEN canan.account_name = 'Hedge_ST_Asset' THEN 'Hedge ST Asset'
																	WHEN canan.account_name = 'Hedge_LT_Asset' THEN 'Hedge LT Asset'
																	WHEN canan.account_name = 'Hedge_ST_Liab' THEN 'Hedge ST Liability'
																	WHEN canan.account_name = 'Hedge_LT_Liab' THEN 'Hedge LT Liability'
																	WHEN canan.account_name = 'Item_ST_Asset' THEN 'Item ST Asset'
																	WHEN canan.account_name = 'Item_ST_Liab' THEN 'Item ST Liab'
																	WHEN canan.account_name = 'Item_LT_Asset' THEN 'Item LT Asset'
																	WHEN canan.account_name = 'Item_LT_Liab' THEN 'Item LT Liab'
																	WHEN canan.account_name = 'AOCI/Hedge_Reserve' THEN 'AOCI/Hedge Reserve'
																	WHEN canan.account_name = 'Unrealized_Earnings' THEN 'Unrealized Earnings'
																	WHEN canan.account_name = 'Gross_Settlement' THEN 'Gross Settlement'
																	WHEN canan.account_name = 'First_Day_PNL' THEN 'First Day PNL'
																	WHEN canan.account_name = 'ST_Tax_Asset' THEN 'ST Tax Asset'
																	WHEN canan.account_name = 'ST_Tax_Liab' THEN 'ST Tax Liab'
																	WHEN canan.account_name = 'LT_Tax_Asset' THEN 'LT Tax Asset'
																	WHEN canan.account_name = 'LT_Tax_Liab' THEN 'LT Tax Liab'
																	WHEN canan.account_name = 'Tax_Reserve' THEN 'Tax Reserve'
																	WHEN canan.account_name = 'Unhedged_ST_Asset' THEN 'Unhedged ST Asset'
																	WHEN canan.account_name = 'Unhedged_LT_Asset' THEN 'Unhedged LT Asset'
																	WHEN canan.account_name = 'Unhedged_ST_Liab' THEN 'Unhedged ST Liab'
																	WHEN canan.account_name = 'Unhedged_LT_Liab' THEN 'Unhedged LT Liab'
																ELSE canan.account_name
																END) account_name
			INTO #generic_mapping_names
		FROM #gl_mapping_system_codes canan 
		LEFT JOIN generic_mapping_values gmv ON clm1_value = canan.account_name 
		LEFT JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
			AND gmh.mapping_name = 'Map GL Code'
		
		DECLARE @hedge_st_asset             VARCHAR(100)
		DECLARE @hedge_lt_asset             VARCHAR(100)
		DECLARE @hedge_st_liab              VARCHAR(100)
		DECLARE @hedge_lt_liab              VARCHAR(100)
		
		DECLARE @item_st_asset              VARCHAR(100)
		DECLARE @item_st_liab               VARCHAR(100)
		DECLARE @item_lt_asset              VARCHAR(100)
		DECLARE @item_lt_liab               VARCHAR(100)
		
		DECLARE @aoci_hedge_reserve         VARCHAR(100)
		DECLARE @unrealized_earnings        VARCHAR(100)
		
		DECLARE @gross_settlement           VARCHAR(100)
		DECLARE @first_day_pnl              VARCHAR(100)
		
		DECLARE @st_tax_asset               VARCHAR(100)
		DECLARE @st_tax_liab                VARCHAR(100)
		DECLARE @lt_tax_asset               VARCHAR(100)
		DECLARE @lt_tax_liab                VARCHAR(100)
		DECLARE @tax_reserve               	VARCHAR(100)
		
		DECLARE @unhedged_st_asset          VARCHAR(100)
		DECLARE @unhedged_lt_asset          VARCHAR(100)
		DECLARE @unhedged_st_liab           VARCHAR(100)
		DECLARE @unhedged_lt_liab           VARCHAR(100)
		
		DECLARE @earnings					VARCHAR(100)
		DECLARE @cash						VARCHAR(100)
		DECLARE @inventory					VARCHAR(100)
		DECLARE @expense					VARCHAR(100)
		DECLARE @amortization				VARCHAR(100)
		DECLARE @interest					VARCHAR(100)	


		SELECT @hedge_st_asset      = ISNULL(account_name, 'Hedge ST Asset') FROM #generic_mapping_names WHERE real_name = 'hedge_st_asset'
		SELECT @hedge_lt_asset      = ISNULL(account_name, 'Hedge LT Asset') FROM #generic_mapping_names WHERE real_name = 'hedge_lt_asset'
		SELECT @hedge_st_liab       = ISNULL(account_name, 'Hedge ST Liability') FROM #generic_mapping_names WHERE real_name = 'hedge_st_liab'
		SELECT @hedge_lt_liab       = ISNULL(account_name, 'Hedge LT Liability') FROM #generic_mapping_names WHERE real_name = 'hedge_lt_liab'
		
		SELECT @item_st_asset       = ISNULL(account_name, 'Item ST Asset') FROM #generic_mapping_names WHERE real_name = 'item_st_asset'
		SELECT @item_st_liab        = ISNULL(account_name, 'Item ST Liab') FROM #generic_mapping_names WHERE real_name = 'item_st_liab'
		SELECT @item_lt_asset       = ISNULL(account_name, 'Item LT Asset') FROM #generic_mapping_names WHERE real_name = 'item_lt_asset'
		SELECT @item_lt_liab        = ISNULL(account_name, 'Item LT Liab') FROM #generic_mapping_names WHERE real_name = 'item_lt_liab'
		
		SELECT @aoci_hedge_reserve  = ISNULL(account_name, 'AOCI/Hedge Reserve') FROM #generic_mapping_names WHERE real_name = 'aoci_hedge_reserve'
		SELECT @unrealized_earnings = ISNULL(account_name, 'Unrealized Earnings') FROM #generic_mapping_names WHERE real_name = 'unrealized_earnings'
		
		SELECT @gross_settlement    = ISNULL(account_name, 'Gross Settlement') FROM #generic_mapping_names WHERE real_name = 'gross_settlement'
		SELECT @first_day_pnl       = ISNULL(account_name, 'First Day PNL') FROM #generic_mapping_names WHERE real_name = 'first_day_pnl'
		
		SELECT @st_tax_asset        = ISNULL(account_name, 'ST Tax Asset') FROM #generic_mapping_names WHERE real_name = 'st_tax_asset'
		SELECT @st_tax_liab         = ISNULL(account_name, 'ST Tax Liab') FROM #generic_mapping_names WHERE real_name = 'st_tax_liab'
		SELECT @lt_tax_asset        = ISNULL(account_name, 'LT Tax Asset') FROM #generic_mapping_names WHERE real_name = 'lt_tax_asset'
		SELECT @lt_tax_liab         = ISNULL(account_name, 'LT Tax Liab') FROM #generic_mapping_names WHERE real_name = 'lt_tax_liab'
		SELECT @tax_reserve         = ISNULL(account_name, 'Tax Reserve') FROM #generic_mapping_names WHERE real_name = 'tax_reserve'
		
		SELECT @unhedged_st_asset   = ISNULL(account_name, 'Unhedged ST Asset') FROM #generic_mapping_names WHERE real_name = 'unhedged_st_asset'
		SELECT @unhedged_lt_asset   = ISNULL(account_name, 'Unhedged LT Asset') FROM #generic_mapping_names WHERE real_name = 'unhedged_lt_asset'
		SELECT @unhedged_st_liab    = ISNULL(account_name, 'Unhedged ST Liab') FROM #generic_mapping_names WHERE real_name = 'unhedged_st_liab'
		SELECT @unhedged_lt_liab    = ISNULL(account_name, 'Unhedged LT Liab') FROM #generic_mapping_names WHERE real_name = 'unhedged_lt_liab'

		SELECT @earnings			= ISNULL(account_name, 'earnings') FROM #generic_mapping_names WHERE real_name = 'earnings'
		SELECT @cash				= ISNULL(account_name, 'cash') FROM #generic_mapping_names WHERE real_name = 'cash'
		SELECT @inventory           = ISNULL(account_name, 'inventory') FROM #generic_mapping_names WHERE real_name = 'inventory'
		SELECT @expense				= ISNULL(account_name, 'expense') FROM #generic_mapping_names WHERE real_name = 'expense'
		SELECT @amortization        = ISNULL(account_name, 'amortization') FROM #generic_mapping_names WHERE real_name = 'amortization'
		SELECT @interest			= ISNULL(account_name, 'interest') FROM #generic_mapping_names WHERE real_name = 'interest'

		SET @query = 'SELECT ssbm.book_deal_type_map_id
							, st_asset.gl_number_id gl_number_id_st_asset
							, lt_asset.gl_number_id gl_number_id_lt_asset
							, st_lia.gl_number_id gl_number_id_st_liab
							, lt_lia.gl_number_id gl_number_id_lt_liab
							, aoci.gl_number_id gl_number_id_aoci
							, earning.gl_number_id gl_number_id_pnl
							, MAX(un_st_asset.gl_number_id) gl_number_unhedged_der_st_asset
							, MAX(un_lt_asset.gl_number_id) gl_number_unhedged_der_lt_asset
							, MAX(un_st_lia.gl_number_id) gl_number_unhedged_der_st_liab
							, MAX(un_lt_lia.gl_number_id) gl_number_unhedged_der_lt_liab
							, MAX(item_st_asset.gl_number_id) item_st_asset
							, MAX(item_st_lia.gl_number_id) item_st_liab
							, MAX(item_lt_asset.gl_number_id) item_lt_asset
							, MAX(item_lt_lia.gl_number_id) item_lt_liab
							, MAX(gross_settlement.gl_number_id) gross_settlement
							, MAX(first_day_pnl.gl_number_id) first_day_pnl
							, MAX(st_tax_asset.gl_number_id) st_tax_asset
							, MAX(st_tax_lia.gl_number_id) st_tax_liab
							, MAX(lt_tax_asset.gl_number_id) lt_tax_asset
							, MAX(lt_tax_lia.gl_number_id) lt_tax_liab
							, MAX(tax_reserve.gl_number_id) tax_reserve
							, MAX(earnings.gl_number_id) earnings
							, MAX(cash.gl_number_id) cash
							, MAX(inventory.gl_number_id) inventory
							, MAX(expense.gl_number_id) expense
							, MAX(amortization.gl_number_id) amortization
							, MAX(interest.gl_number_id) interest
							INTO ' + @collect_account_no + '
						FROM ' + @table_name + ' ti 
						INNER JOIN source_book sb ON  sb.source_book_name = ti.Book_Identifier1 AND sb.source_system_book_type_value_id = 50 
						INNER JOIN source_book sb1 ON sb1.source_book_name = ti.Book_Identifier2 AND sb1.source_system_book_type_value_id = 51
						INNER JOIN source_book sb2 ON sb2.source_book_name = ti.Book_Identifier3 AND sb2.source_system_book_type_value_id = 52
						INNER JOIN source_book sb3 ON sb3.source_book_name = ti.Book_Identifier4 AND sb3.source_system_book_type_value_id = 53 
						INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sb.source_book_id
							AND ssbm.source_system_book_id2 = sb1.source_book_id
							AND ssbm.source_system_book_id3 = sb2.source_book_id
							AND ssbm.source_system_book_id4 = sb3.source_book_id
						INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
							AND book.entity_name = ti.book_name
						INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
							AND stra.entity_name = ti.Strategy_Name
						INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
							AND sub.entity_name = ti.Subsidiary_Name
						--st lt assets lia
						LEFT JOIN gl_system_mapping st_asset ON st_asset.gl_account_number = ti.Hedge_ST_Asset
							AND st_asset.gl_account_name = ''' + ISNULL(@hedge_st_asset, 'Hedge ST Asset') + '''
						LEFT JOIN gl_system_mapping lt_asset ON lt_asset.gl_account_number = ti.Hedge_LT_Asset
							AND lt_asset.gl_account_name = ''' + ISNULL(@hedge_lt_asset, 'Hedge LT Asset') + '''
						LEFT JOIN gl_system_mapping st_lia ON st_lia.gl_account_number = ti.[Hedge_ST_Liab]
							AND st_lia.gl_account_name = ''' + ISNULL(@hedge_st_liab, 'Hedge ST Liability') + '''
						LEFT JOIN gl_system_mapping lt_lia ON lt_lia.gl_account_number = ti.[Hedge_LT_Liab]
							AND lt_lia.gl_account_name = ''' + ISNULL(@hedge_lt_liab, 'Hedge LT Liability') + '''
						--aoci and earning
						LEFT JOIN gl_system_mapping aoci ON aoci.gl_account_number = ti.[AOCI/Hedge_Reserve]
							AND aoci.gl_account_name = ''' + ISNULL(@aoci_hedge_reserve, 'AOCI/Hedge Reserve') + '''
						LEFT JOIN gl_system_mapping earning ON earning.gl_account_number = ti.Unrealized_Earnings
							AND earning.gl_account_name = ''' + ISNULL(@unrealized_earnings, 'Unrealized Earnings') + '''
						--unhedged der
						LEFT JOIN gl_system_mapping un_st_asset ON un_st_asset.gl_account_number = ti.Unhedged_ST_Asset
							AND un_st_asset.gl_account_name = ''' + ISNULL(@unhedged_st_asset, 'Unhedged ST Asset') + '''
						LEFT JOIN gl_system_mapping un_st_lia ON un_st_lia.gl_account_number = ti.Unhedged_ST_Liab
							AND un_st_lia.gl_account_name = ''' + ISNULL(@unhedged_st_liab, 'Unhedged ST Liab') + '''
						LEFT JOIN gl_system_mapping un_lt_asset ON un_lt_asset.gl_account_number = ti.Unhedged_LT_Asset
							AND un_lt_asset.gl_account_name = ''' + ISNULL(@unhedged_lt_asset , 'Unhedged LT Asset') + '''
						LEFT JOIN gl_system_mapping un_lt_lia ON un_lt_lia.gl_account_number = ti.Unhedged_LT_Liab
							AND un_lt_lia.gl_account_name = ''' + ISNULL(@unhedged_lt_liab, 'Unhedged LT Liab') + '''
						--item
						LEFT JOIN gl_system_mapping item_st_asset ON item_st_asset.gl_account_number = ti.item_st_asset
							AND item_st_asset.gl_account_name = ''' + ISNULL(@item_st_asset, 'Item ST Asset') + '''
						LEFT JOIN gl_system_mapping item_st_lia ON item_st_lia.gl_account_number = ti.item_st_liab
							AND item_st_lia.gl_account_name = ''' + ISNULL(@item_st_liab, 'Item ST Liab') + '''
						LEFT JOIN gl_system_mapping item_lt_asset ON item_lt_asset.gl_account_number = ti.item_lt_asset
							AND item_lt_asset.gl_account_name = ''' + ISNULL(@item_lt_asset, 'Item LT Asset') + '''
						LEFT JOIN gl_system_mapping item_lt_lia ON item_lt_lia.gl_account_number = ti.item_lt_liab
							AND item_lt_lia.gl_account_name = ''' + ISNULL(@item_lt_liab, 'Item LT Liab') + '''
						
						--sett_pnl
						LEFT JOIN gl_system_mapping gross_settlement ON gross_settlement.gl_account_number = ti.gross_settlement
							AND gross_settlement.gl_account_name = ''' + ISNULL(@gross_settlement, 'Gross Settlement') + '''
						LEFT JOIN gl_system_mapping first_day_pnl ON first_day_pnl.gl_account_number = ti.first_day_pnl
							AND first_day_pnl.gl_account_name = ''' + ISNULL(@first_day_pnl, 'First Day PNL') + '''
						
						--tax
						LEFT JOIN gl_system_mapping st_tax_asset ON st_tax_asset.gl_account_number = ti.st_tax_asset
							AND st_tax_asset.gl_account_name = ''' + ISNULL(@st_tax_asset, 'ST Tax Asset') + '''
						LEFT JOIN gl_system_mapping st_tax_lia ON st_tax_lia.gl_account_number = ti.ST_Tax_Liab
							AND st_tax_lia.gl_account_name = ''' + ISNULL(@st_tax_liab, 'ST Tax Liab') + '''
						LEFT JOIN gl_system_mapping lt_tax_asset ON lt_tax_asset.gl_account_number = ti.lt_tax_asset
							AND lt_tax_asset.gl_account_name = ''' + ISNULL(@lt_tax_asset, 'LT Tax Asset') + '''
						LEFT JOIN gl_system_mapping lt_tax_lia ON lt_tax_lia.gl_account_number = ti.LT_Tax_Liab
							AND lt_tax_lia.gl_account_name = ''' + ISNULL(@lt_tax_liab, 'LT Tax Liab') + '''
						LEFT JOIN gl_system_mapping tax_reserve ON tax_reserve.gl_account_number = ti.tax_reserve
							AND tax_reserve.gl_account_name = ''' + ISNULL(@tax_reserve, 'Tax Reserve') + '''
						
						--others
						LEFT JOIN gl_system_mapping earnings ON earnings.gl_account_number = ti.earnings
							AND earnings.gl_account_name = ''' + ISNULL(@earnings, 'earnings') + '''
						LEFT JOIN gl_system_mapping cash ON cash.gl_account_number = ti.cash
							AND cash.gl_account_name = ''' + ISNULL(@cash, 'cash') + '''
						LEFT JOIN gl_system_mapping inventory ON inventory.gl_account_number = ti.inventory
							AND inventory.gl_account_name = ''' + ISNULL(@inventory, 'inventory') + '''
						LEFT JOIN gl_system_mapping expense ON expense.gl_account_number = ti.expense
							AND expense.gl_account_name = ''' + ISNULL(@expense, 'expense') + '''
						LEFT JOIN gl_system_mapping amortization ON amortization.gl_account_number = ti.amortization
							AND amortization.gl_account_name = ''' + ISNULL(@amortization, 'amortization') + '''
						LEFT JOIN gl_system_mapping interest ON interest.gl_account_number = ti.interest
							AND interest.gl_account_name = ''' + ISNULL(@interest, 'interest') + '''
						GROUP BY ssbm.book_deal_type_map_id,
							st_asset.gl_number_id,
							lt_asset.gl_number_id,
							st_lia.gl_number_id,
							lt_lia.gl_number_id,
							aoci.gl_number_id,
							earning.gl_number_id'
		EXEC spa_print @query
		EXEC (@query)
		
		SET @query = 'MERGE source_book_map_GL_codes AS T
						USING (SELECT * FROM ' + @collect_account_no + ') AS S
							ON (T.source_book_map_id = s.book_deal_type_map_id)  
						WHEN NOT MATCHED BY TARGET
							THEN INSERT(source_book_map_id
										, gl_number_unhedged_der_st_asset
										, gl_number_unhedged_der_lt_asset
										, gl_number_id_st_asset
										, gl_number_id_lt_asset
										, gl_number_unhedged_der_st_liab
										, gl_number_unhedged_der_lt_liab
										, gl_number_id_st_liab
										, gl_number_id_lt_liab
										, gl_number_id_aoci
										, gl_number_id_pnl
										, gl_number_id_item_st_asset
										, gl_number_id_item_st_liab
										, gl_number_id_item_lt_asset
										, gl_number_id_item_lt_liab
										, gl_number_id_set
										, gl_number_id_cash
										, gl_number_id_inventory
										, gl_number_id_expense
										, gl_number_id_gross_set
										, gl_id_amortization
										, gl_id_interest
										, gl_first_day_pnl
										, gl_id_st_tax_asset
										, gl_id_st_tax_liab
										, gl_id_lt_tax_asset
										, gl_id_lt_tax_liab
										, gl_id_tax_reserve
										)
								VALUES (s.book_deal_type_map_id
										, s.gl_number_unhedged_der_st_asset
										, s.gl_number_unhedged_der_lt_asset
										, s.gl_number_id_st_asset
										, s.gl_number_id_lt_asset
										, s.gl_number_unhedged_der_st_liab
										, s.gl_number_unhedged_der_lt_liab
										, s.gl_number_id_st_liab
										, s.gl_number_id_lt_liab
										, s.gl_number_id_aoci
										, s.gl_number_id_pnl
										, s.item_st_asset
										, s.item_st_liab
										, s.item_lt_asset
										, s.item_lt_liab
										, s.earnings
										, s.cash
										, s.inventory
										, s.expense
										, s.gross_settlement
										, s.amortization
										, s.interest
										, s.first_day_pnl
										, s.st_tax_asset
										, s.st_tax_liab
										, s.lt_tax_asset
										, s.lt_tax_liab
										, s.tax_reserve
										)
						WHEN MATCHED 
							THEN UPDATE SET t.gl_number_unhedged_der_st_asset = s.gl_number_unhedged_der_st_asset,
											t.gl_number_unhedged_der_lt_asset = s.gl_number_unhedged_der_lt_asset, 
											t.gl_number_id_st_asset = s.gl_number_id_st_asset, 
											t.gl_number_id_lt_asset = s.gl_number_id_lt_asset, 
											t.gl_number_unhedged_der_st_liab = s.gl_number_unhedged_der_st_liab, 
											t.gl_number_unhedged_der_lt_liab = s.gl_number_unhedged_der_lt_liab, 
											t.gl_number_id_st_liab = s.gl_number_id_st_liab, 
											t.gl_number_id_lt_liab = s.gl_number_id_lt_liab, 
											t.gl_number_id_aoci = s.gl_number_id_aoci, 
											t.gl_number_id_pnl = s.gl_number_id_pnl,
											t.gl_number_id_item_st_asset = s.item_st_asset,
											t.gl_number_id_item_st_liab = s.item_st_liab,
											t.gl_number_id_item_lt_asset = s.item_lt_asset,
											t.gl_number_id_item_lt_liab = s.item_lt_liab,
											t.gl_number_id_set = s.earnings,
											t.gl_number_id_cash = s.cash,
											t.gl_number_id_inventory = s.inventory,
											t.gl_number_id_expense = s.expense,
											t.gl_number_id_gross_set = s.gross_settlement,
											t.gl_id_amortization = s.amortization,
											t.gl_id_interest = s.interest,
											t.gl_first_day_pnl = s.first_day_pnl,
											t.gl_id_st_tax_asset = s.st_tax_asset,
											t.gl_id_st_tax_liab = s.st_tax_liab,
											t.gl_id_lt_tax_asset = s.lt_tax_asset,
											t.gl_id_lt_tax_liab = s.lt_tax_liab,
											t.gl_id_tax_reserve = s.tax_reserve;'
		exec spa_print @query
		EXEC (@query)
		
		--Logic to move the GL Code mapping corresponding to the Hierarchy levels
		DECLARE @gl_grouping_value_id INT, @fas_strategy_id INT

		UPDATE fs
		SET fs.gl_grouping_value_id = lvl.value_id
		FROM #book_structure bs
		INNER JOIN portfolio_hierarchy ph 
			ON ph.[entity_name] = bs.strategy_name
				AND ph.hierarchy_level = 1
		INNER JOIN fas_strategy fs
			ON fs.fas_strategy_id = ph.[entity_id]
		INNER JOIN static_data_value lvl
			ON lvl.[type_id] = 350
				AND lvl.code = CASE 
									WHEN bs.[level] = 'Strategy' THEN 'Grouped at Strategy'
									WHEN bs.[level] = 'Book' THEN 'Grouped at Book'
									WHEN bs.[level] IN ('Subbook', 'Sub Book') THEN 'Grouped at SBM'
								END

		DECLARE @map_gl_codes CURSOR
		SET @map_gl_codes = CURSOR FOR
		
		SELECT lvl.value_id gl_grouping_value_id, ph.entity_id fas_strategy_id
		FROM portfolio_hierarchy ph
		INNER JOIN #book_structure bs
			ON ph.[entity_name] = bs.strategy_name
				AND ph.hierarchy_level = 1
		INNER JOIN static_data_value lvl
			ON lvl.[type_id] = 350
				AND lvl.code = CASE 
									WHEN bs.[level] = 'Strategy' THEN 'Grouped at Strategy'
									WHEN bs.[level] = 'Book' THEN 'Grouped at Book'
									WHEN bs.[level] IN ('Subbook', 'Sub Book') THEN 'Grouped at SBM'
							   END
		OPEN @map_gl_codes
		FETCH NEXT
		FROM @map_gl_codes INTO @gl_grouping_value_id, @fas_strategy_id
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			EXEC [dbo].[spa_shift_map_gl_codes] @fas_strategy_id, @gl_grouping_value_id, NULL 
		FETCH NEXT
		FROM @map_gl_codes INTO @gl_grouping_value_id, @fas_strategy_id
		END
		CLOSE @map_gl_codes
		DEALLOCATE @map_gl_codes
		--

		SET @query = 'INSERT INTO #check_file_error
						SELECT 1 FROM ' + @manditory_error_log + ''
		exec spa_print @query
		EXEC (@query)

		-- message start
		DECLARE @error_succecss VARCHAR(100)
		DECLARE @desc VARCHAR(MAX)
		DECLARE @effected_row_count INT
		DECLARE @url VARCHAR(MAX)

		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
						'&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''

		SET @query = 'INSERT INTO #check_file_error
						SELECT 1 FROM ' + @manditory_error_log + ''
		exec spa_print @query
		EXEC (@query)

		--effected row count
		IF OBJECT_ID('tempdb..#effected_rows') IS NOT NULL 
			DROP TABLE #effected_rows 
		
		CREATE TABLE #effected_rows (effected_rows INT)
		SET @query = ' INSERT INTO #effected_rows(effected_rows)
						SELECT COUNT(1) effected_rows 
						FROM ' + @table_name + '' 

		exec spa_print @query
		EXEC (@query)

		SELECT @effected_row_count = effected_rows 
		FROM #effected_rows

		DECLARE @elasped_time VARCHAR(100) 
 		SELECT @elasped_time = CONVERT(CHAR(8),DATEADD(second,MAX(elapsed_time), 0), 108) FROM import_data_files_audit WHERE  process_id = @process_id
 	
		IF NOT EXISTS(SELECT 1 FROM #check_file_error)
		BEGIN
			SET @error_succecss = 's'
			DECLARE @combined_rules_names VARCHAR(MAX)
 			SELECT @combined_rules_names = COALESCE(@combined_rules_names + ' ', '') + '<li>' + +  replace(idfa.dir_path, 'Rules:', '') + '</li>'
 			FROM import_data_files_audit idfa
 			WHERE process_id = @process_id

			IF EXISTS (SELECT 1 FROM #accounting_type_change where [action] = 'update' AND fas_deal_type_value_id_before <> fas_deal_type_value_id_after)
			BEGIN 
				SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
							'<ul style="padding:0px;margin:0px;list-style-type:none;">' 
 						   + '<li style="border:none">Import process completed for as of date: ' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) + '<br /> Rules Executed:<ul style="padding:0px 0px 0px 10px;margin:0px 0px 0px 10px;list-style-type:square;">' + @combined_rules_names + '<ul/></li>Elasped Time: ' + @elasped_time + '. [Warning: Accounting Treatment Changed]</a>'
	
				SET @query = '
								INSERT INTO source_system_data_import_status_detail(process_id
																					, [source]
																					, [type]
																					, [description]
																					, [type_error])
								SELECT ''' + @process_id +  ''', ''Source Book And GL codes'', ''Source Book And GL code Import'',  
										''Accounting Type changed Prior: '' + sdv_old.code + '' Changed To : '' +  sdv_new.code, ''Accounting Treatment Changed''							
								FROM #accounting_type_change atc
								INNER JOIN static_data_value sdv_old ON sdv_old.value_id = atc.fas_deal_type_value_id_before
								INNER JOIN static_data_value sdv_new ON sdv_new.value_id = atc.fas_deal_type_value_id_after
								WHERE fas_deal_type_value_id_before <> fas_deal_type_value_id_after' 
				exec spa_print @query
				EXEC (@query)

				INSERT INTO source_system_data_import_status(Process_id
														, code
														, module
														, source
														, [type]
														, [description]
														, recommendation)
				SELECT @process_id, 'Success', 'Import Data', 'Source Book and GL Codes',  'Import', CAST(@effected_row_count AS VARCHAR(1000)) + ' Out of ' +  CAST(@total_rows AS VARCHAR(1000)) + ' Source Book and GL Codes records imported successfully.', 'Please Check your data'

				SET @query = 'INSERT INTO source_system_data_import_status(Process_id
																		, code
																		, module
																		, source
																		, [type]
																		, [description]
																		, recommendation)
							SELECT ''' + @process_id + ''', ''Warning'', ''Import Data'', ''Source Book and GL Codes'', ''Import'', type_error, ''Please Check your data'' 
							FROM source_system_data_import_status_detail
							WHERE process_id = ''' + @process_id + '''
							GROUP BY type_error'
			exec spa_print @query
			EXEC (@query)
			END
			ELSE 
			BEGIN 
				SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
					'<ul style="padding:0px;margin:0px;list-style-type:none;">' 
 						   + '<li style="border:none">Import process completed for as of date: ' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) + '<br /> Rules Executed:<ul style="padding:0px 0px 0px 10px;margin:0px 0px 0px 10px;list-style-type:square;">' + @combined_rules_names + '<ul/></li>Elasped Time: ' + @elasped_time + '.</a>'
 			
							--'Import completed for As of Date ' + dbo.FNADateFormat(GETDATE()) + ' (Elapse time: ' + CAST(DATEDIFF(ss, @begin_time, GETDATE()) AS VARCHAR) + ' seconds).</a>'
			
				INSERT INTO source_system_data_import_status(Process_id
														, code
														, module
														, source
														, [type]
														, [description]
														, recommendation)
				SELECT @process_id, 'Success', 'Import Data', 'Source Book and GL Codes',  'Import', CAST(@effected_row_count AS VARCHAR(1000)) + ' Out of ' +  CAST(@total_rows AS VARCHAR(1000)) + ' Source Book and GL Codes records imported successfully.', 'Please Check your data'
			END  
		END 
		ELSE 
		BEGIN
			IF EXISTS (SELECT 1 FROM #accounting_type_change WHERE [action] = 'update' AND fas_deal_type_value_id_before <> fas_deal_type_value_id_after)
			BEGIN 
				SET @query = 'INSERT INTO source_system_data_import_status_detail(process_id
																					, [source]
																					, [type]
																					, [description]
																					, [type_error])
								SELECT ''' + @process_id +  ''', ''Source Book And GL codes'', ''Source Book And GL code Import'',  
										''Accounting Type changed Prior '' + sdv_old.code + '' Changed To: '' +  sdv_new.code,  ''Accounting Treatment Changed''							
								FROM #accounting_type_change atc
								INNER JOIN static_data_value sdv_old ON sdv_old.value_id = atc.fas_deal_type_value_id_before
								INNER JOIN static_data_value sdv_new ON sdv_new.value_id = atc.fas_deal_type_value_id_after
								WHERE fas_deal_type_value_id_before <> fas_deal_type_value_id_after' 
				exec spa_print @query
				EXEC (@query)
			END 
		
			IF @effected_row_count > 0
			BEGIN
				INSERT INTO source_system_data_import_status(Process_id
														, code
														, module
														, source
														, [type]
														, [description]
														, recommendation)
				SELECT @process_id, 'Success', 'Import Data', 'Source Book and GL Codes',  'Import', CAST(@effected_row_count AS VARCHAR(1000)) + ' Out of ' +  CAST(@total_rows AS VARCHAR(1000)) + ' Source Book and GL Codes records imported successfully.', 'Please Check your data'
			END 

			SET @error_succecss = 'e'
			
			SELECT @combined_rules_names = COALESCE(@combined_rules_names + ' ', '') + '<li>' + +  replace(idfa.dir_path, 'Rules:', '') + '</li>'
 			FROM import_data_files_audit idfa
 			WHERE process_id = @process_id
			
			SELECT @desc = '<a target="_blank" href="' + @url + '"><ul style="padding:0px;margin:0px;list-style-type:none;">' 
 						   + '<li style="border:none">Import process completed for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) + '<br /> Rules Executed:<ul style="padding:0px 0px 0px 10px;margin:0px 0px 0px 10px;list-style-type:square;">' + @combined_rules_names + '<ul/></li><li style="border:none">Elasped Time: ' + @elasped_time + '.</li>'
 						   + '</li><font color="red">(Errors Found).</font></li></a>' 
 	    
			SET @query = 'INSERT INTO source_system_data_import_status_detail(process_id
																				, [source]
																				, [type]
																				, [description]
																				, [type_error])
							SELECT ''' + @process_id +  ''', ''Source Book And GL codes'', ''Source Book And GL code Import'',  
									error_desc + CASE WHEN temp_id IS NOT NULL THEN '' [Line No: '' +  CAST(temp_id AS VARCHAR(10)) + '']'' ELSE '''' END, error_type
							FROM ' + @manditory_error_log + '' 
			exec spa_print @query
			EXEC (@query)
			
			SET @query = 'INSERT INTO source_system_data_import_status(Process_id
																		, code
																		, module
																		, source
																		, [type]
																		, [description]
																		, recommendation)
							SELECT ''' + @process_id + ''', CASE WHEN type_error = ''Accounting Treatment Changed'' THEN ''Warning'' ELSE ''Error'' END, ''Import Data'', ''Source Book and GL Codes'', ''Import'', type_error, ''Please Check your data'' 
							FROM source_system_data_import_status_detail
							WHERE process_id = ''' + @process_id + '''
							GROUP BY type_error'
			exec spa_print @query
			EXEC (@query)
		END 

		EXEC spa_message_board 'i', @user_login_id,  NULL, 'ImportData', @desc, '', '', @error_succecss,  'Source Book And GL codes', NULL, @process_id, '', '', '', 'y'
		--rollback
		--return 
COMMIT TRAN
END TRY 
BEGIN CATCH	
	ROLLBACK
	EXEC  spa_message_board 'i', @user_login_id, NULL, 'Import Data', 'Error while importing data.', '', '', 'e', 'Source Book And GL codes', NULL, @process_id
END CATCH

GO
