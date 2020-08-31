IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_search_engine]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_search_engine]
GO
 
 /****** Object:  StoredProcedure [dbo].[spa_search_engine]    Script Date: 12/07/2011 09:41:11 ******/
 SET ANSI_NULLS ON
 GO
 
 SET QUOTED_IDENTIFIER ON
 GO
 
 
 CREATE PROC [dbo].[spa_search_engine] (
	 @flag CHAR(1),
	 @searchString VARCHAR(8000) = NULL,
	 @searchTables VARCHAR(1000) = NULL,
	 @searchColumns VARCHAR(8000) = NULL,
	 @searchOnSearch VARCHAR(2000) = NULL,
	 @callFrom CHAR(1) = NULL,
	 @filter_text VARCHAR(MAX) = NULL,
	 @process_table VARCHAR(2000) = NULL,
	 @batch_process_id VARCHAR(250) = NULL,
	 @batch_report_param VARCHAR(500) = NULL, 
	 @enable_paging INT = 0,  --'1' = enable, '0' = disable
	 @page_size INT = NULL,
	 @page_no INT = NULL,
	 @debug_mode BIT = 0
 )
 
 AS
 /*
 declare @flag CHAR(1),
	 @searchString VARCHAR(8000) = NULL,
	 @searchTables VARCHAR(1000) = NULL,
	 @searchColumns VARCHAR(8000) = NULL,
	 @searchOnSearch VARCHAR(2000) = NULL,
	 @callFrom CHAR(1) = NULL,
	 @filter_text VARCHAR(MAX) = NULL,
	 @process_table VARCHAR(2000) = NULL,
	 @batch_process_id VARCHAR(250) = NULL,
	 @batch_report_param VARCHAR(500) = NULL, 
	 @enable_paging INT = 0,  --'1' = enable, '0' = disable
	 @page_size INT = NULL,
	 @page_no INT = NULL,
	 @debug_mode BIT = 1

select 
 @flag='s', @searchString='ANNAVO', @searchTables='credit info', @callFrom='s'

--*/
SET NOCOUNT ON
 DECLARE @sql VARCHAR(MAX)
 DECLARE @user_login_id VARCHAR(50) = dbo.FNADBUser()
 DECLARE @sql_paging VARCHAR(8000)
 DECLARE @is_batch bit
 DECLARE @processTable VARCHAR(200)
 
DECLARE @original_search_string VARCHAR(8000) = @searchString
 
IF OBJECT_ID('tempdb..#temp_search_tables') IS NOT NULL
	DROP TABLE #temp_search_tables
CREATE TABLE #temp_search_tables (table_name VARCHAR(500) COLLATE DATABASE_DEFAULT , table_label VARCHAR(500) COLLATE DATABASE_DEFAULT )

IF OBJECT_ID('tempdb..#temp_search_string') IS NOT NULL
	DROP TABLE #temp_search_string

CREATE TABLE #temp_search_string(
	clmn              VARCHAR(500) COLLATE DATABASE_DEFAULT ,
	search_string     VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	operator          CHAR(2) COLLATE DATABASE_DEFAULT ,
	table_name		  VARCHAR(100) COLLATE DATABASE_DEFAULT 
)
 
 IF @searchTables IS NOT NULL
 BEGIN

 	INSERT INTO #temp_search_tables(table_name, table_label)
 	SELECT smd.tableName, smd.table_display_name
 	FROM  dbo.SplitCommaSeperatedValues(@searchTables) scsv
 	INNER JOIN search_meta_data smd ON scsv.item = smd.table_display_name
	
 	GROUP BY smd.tableName, smd.table_display_name
 END
 ELSE 
 BEGIN
 	INSERT INTO #temp_search_tables(table_name, table_label)
 	SELECT DISTINCT tablename, table_display_name FROM dbo.search_meta_data
 END
 
 DECLARE @sql_flag CHAR(1)
 
 
 IF (CHARINDEX(';', @searchString) <> 0 OR CHARINDEX('=', @searchString) <> 0 OR CHARINDEX('<', LTRIM(@searchString)) <> 0 OR CHARINDEX('>', LTRIM(@searchString)) <> 0) --AND ISDATE(LTRIM(RTRIM(SUBSTRING((@searchString), CHARINDEX('=', @searchString) + 1, LEN(@searchString)))))  <> 1))
 BEGIN
 	--SELECT 'here'
 	SET @sql_flag = 'y'
 	INSERT INTO #temp_search_string(clmn, search_string, operator, table_name)
 	SELECT clmn, search_string, operator, 'master_deal_view' 
 	FROM dbo.FNASearchParser(@searchString, 'master_deal_view')
 	UNION ALL
 	SELECT clmn, search_string, operator, 'source_counterparty' 
 	FROM dbo.FNASearchParser(@searchString, 'source_counterparty')
	UNION ALL
 	SELECT clmn, search_string, operator, 'application_notes' 
 	FROM dbo.FNASearchParser(@searchString, 'application_notes')
	UNION ALL
 	SELECT clmn, search_string, operator, 'counterparty_bank_info' 
 	FROM dbo.FNASearchParser(@searchString, 'counterparty_bank_info')
	UNION ALL
 	SELECT clmn, search_string, operator, 'VW_counterparty_certificate' 
 	FROM dbo.FNASearchParser(@searchString, 'VW_counterparty_certificate')
	UNION ALL
 	SELECT clmn, search_string, operator, 'master_view_counterparty_products' 
 	FROM dbo.FNASearchParser(@searchString, 'master_view_counterparty_products')
	UNION ALL
 	SELECT clmn, search_string, operator, 'master_view_counterparty_contacts' 
 	FROM dbo.FNASearchParser(@searchString, 'master_view_counterparty_contacts')
	UNION ALL
 	SELECT clmn, search_string, operator, 'email_notes' 
 	FROM dbo.FNASearchParser(@searchString, 'email_notes')
	UNION ALL
 	SELECT clmn, search_string, operator, 'contract_group' 
 	FROM dbo.FNASearchParser(@searchString, 'contract_group')
 END
 ELSE
 BEGIN
 	--SET @searchString = dbo.FNAReplaceSpecialChars(@searchString, ' ')
 	SET @searchString = REPLACE(REPLACE(REPLACE(@searchString,' ','<>'),'><',''),'<>',' ')
 	IF (CHARINDEX(' OR ', @searchString) = 0) AND (CHARINDEX(' AND ', @searchString) = 0)
 	BEGIN
 		IF (CHARINDEX(' ', LTRIM(RTRIM(@searchString))) <> 0) AND (@searchString NOT LIKE '%[^a-zA-Z0-9 ]%')
 		BEGIN
 			SET @searchString = REPLACE(LTRIM(RTRIM(@searchString)), ' ', ' and ')
 			SET @searchString = '*' + RTRIM(LTRIM(@searchString)) + '*'	
 		END
 		ELSE IF (@searchString LIKE '%[^a-zA-Z0-9 ]%')
 		BEGIN
 			SET @searchString = REPLACE(LTRIM(RTRIM(@searchString)), ' ', ' and ')
 			SET @searchString = '*' + RTRIM(LTRIM(@searchString)) + '*'
 		END
 		ELSE
 		BEGIN
 			SET @searchString = '"*' + RTRIM(LTRIM(@searchString)) + '*"'	
 		END				
 			
 	END
 	ELSE IF (CHARINDEX(' OR ', @searchString) <> 0) OR (CHARINDEX(' AND ', @searchString) <> 0)
 	BEGIN
 		SET @searchString = RTRIM(LTRIM(@searchString))
 		SET @searchString = REPLACE(@searchString, ' ', ' and ')
 		SET @searchString = REPLACE(@searchString, 'and or and', 'or')
 		SET @searchString = REPLACE(@searchString, 'and and and', 'AND')
 	END
 	
 	INSERT INTO #temp_search_string(clmn, search_string, operator, table_name)
 	SELECT NULL, @searchString, NULL, 'master_deal_view'
 	UNION ALL
 	SELECT NULL, @searchString, NULL, 'source_counterparty'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'application_notes'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'counterparty_bank_info'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'VW_counterparty_certificate'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'master_view_counterparty_products'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'master_view_counterparty_contacts'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'email_notes'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'contract_group'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'master_view_counterparty_contract_address'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'master_view_counterparty_credit_info'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'master_view_counterparty_credit_enhancements'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'master_view_counterparty_credit_limits'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'master_view_counterparty_epa_account'
	UNION ALL
	SELECT NULL, @searchString, NULL, 'master_view_counterparty_credit_migration'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'master_view_incident_log'
	UNION ALL
 	SELECT NULL, @searchString, NULL, 'master_view_incident_log_detail'
 END	
 --select * from #temp_search_string

 IF @flag = 't' -- for selecting tables from database
 BEGIN
     SELECT DISTINCT 
            tableName,
            table_display_name
     FROM search_meta_data
     WHERE tableName <> 'workflow_activities_audit_summary' --Not need for this phase table does not contains any data.
     ORDER BY table_display_name
 END
 ELSE 
 IF @flag = 'c' -- selecting clumns from tables
 BEGIN
     IF @searchTables IS NULL
     BEGIN
         RETURN
     END
     ELSE
     BEGIN
 		SELECT DISTINCT columnName, column_display_name
 		FROM search_meta_data s
 		WHERE  s.tableName IN (SELECT a.Item FROM dbo.SplitCommaSeperatedValues(@searchTables) a)
 		ORDER BY s.column_display_name
     END
 END
 ELSE IF @flag = 's'
 BEGIN
 	--drop proc [dbo].[spa_search_engine]
 	--exec spa_search_engine 's', 'trader=bjulsing; counterparty=apx swap delivery;', NULL, NULL, NULL, 's'
 	--exec spa_search_engine 's', 'gas', '''master_deal_view''', NULL, NULL, 'd'
 	DECLARE @date_search        CHAR(1)
 	DECLARE @operator           CHAR(2)
 	DECLARE @sqlSELECT          VARCHAR(MAX)
 	DECLARE @sql_select_deal    VARCHAR(MAX)
 	DECLARE @search_column      VARCHAR(100)
 	DECLARE @columns			VARCHAR(MAX)
 	
 	DECLARE @displayColumns     VARCHAR(8000)
 	DECLARE @batch_process_id1  VARCHAR(200)
 	--DECLARE @user_login_id     AS VARCHAR(200)
 	DECLARE @temptablename      VARCHAR(200)
 	
 	
 	--SELECT @searchString
 	
 	----Test Block
 	--declare @searchString as varchar(8000)
 	--declare @searchTables as varchar(8000)
 	--declare @searchColumns as varchar(8000)
 	--declare @searchOnSearch as varchar (500)
 	--set @searchTables = '''source_counterparty'''--,''portfolio_hierarchy'''
 	--set @searchString = 'power or gas'
 	--set @searchColumns = NULL -- 'counterparty_id, counterparty_name'--,counterparty_desc'
 	--set @searchOnSearch = 'adiha_process.dbo.batch_report_BA5BCE1D_1EDC_444C_8458_6A98F879B842' --NULL
 	IF @debug_mode = 1
		EXEC spa_print 'New Search'
 	
 	SET @batch_process_id1 = REPLACE(NEWID(), '-', '_') 
 	SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id1) 
 	SET @sql =  'CREATE TABLE ' + @temptablename + '(
 						[SNO] [int] IDENTITY(1,1) NOT NULL,
 						[Object] [varchar](50) NOT NULL,
 						[Details] [varchar](8000) NULL,
 						[TableName] [varchar](50) NOT NULL,
 						[detail_table] [VARCHAR](200) NULL
 				 ) ON [PRIMARY]'
 	--PRINT(@sql)
 	EXEC(@sql)
 	
 	IF EXISTS (SELECT 1 FROM dbo.SplitCommaSeperatedValues(@searchTables) a WHERE a.item = '''master_deal_view''' OR a.item = 'master_deal_view' OR a.item = '''master_deal_view' OR a.item = 'master_deal_view''')
 	BEGIN
 		--SELECT 'here'
 		DECLARE @batch_process_id_deal VARCHAR(500)
 		DECLARE @tempTableDeal VARCHAR(500)
 		DECLARE @columnListDeal VARCHAR(MAX)
 		SET @columnListDeal = 'source_deal_header_id, source_system_id, deal_id, deal_date, ext_deal_id, physical_financial, structured_deal_id, counterparty, parent_counterparty, entire_term_start, entire_term_end, deal_type, deal_sub_type, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, subsidiary, strategy, Book, description1, description2, description3, deal_category, trader, internal_deal_type, internal_deal_subtype, template, broker, generator, deal_status_date, assignment_type, compliance_year, state_value, assigned_date, assigned_user, contract, create_user, create_ts, update_user, update_ts, legal_entity, deal_profile, fixation_type, internal_portfolio, commodity, reference, locked_deal, close_reference_id, block_type, block_definition, granularity, pricing, deal_reference_type, deal_status, confirm_status_type, term_start, term_end, contract_expiration_date, fixed_float, buy_sell, index_name, index_commodity, index_currency, index_uom, index_proxy1, index_proxy2, index_proxy3, index_settlement, expiration_calendar, deal_formula, location, location_region, location_grid, location_country, location_group, forecast_profile, forecast_proxy_profile, profile_type, proxy_profile_type, meter, profile_code, Pr_party, UDF, deal_date_varchar, entire_term_start_varchar, entire_term_end_varchar, scheduler, inco_terms, detail_inco_terms, trader2, counterparty2, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5, governing_law, payment_term, arbitration, counterparty2_trader, counterparty_trader, batch_id, buyer_seller_option, crop_year, product_description,reporting_group1,reporting_group2,reporting_group3,reporting_group4,reporting_group5'
 		DECLARE @columnListfullText VARCHAR(MAX)
 		SET @columnListfullText = '[assigned_user], [assignment_type], [block_definition], [block_type], [Book], [broker], [buy_sell], [commodity], [confirm_status_type], [contract], [counterparty], [create_user], [deal_category], [deal_formula], [deal_id], [deal_profile], [deal_status], [deal_sub_type], [deal_type], [description1], [description2], [description3], [expiration_calendar], [ext_deal_id], [fixation_type], [fixed_float], [forecast_profile], [forecast_proxy_profile], [generator], [granularity], [index_commodity], [index_currency], [index_name], [index_proxy1], [index_proxy2], [index_proxy3], [index_settlement], [index_uom], [internal_deal_subtype], [internal_deal_type], [internal_portfolio], [legal_entity], [location], [location_country], [location_grid], [location_group], [location_region], [locked_deal], [meter], [option_excercise_type], [option_flag], [option_type], [parent_counterparty], [physical_financial], [Pr_party], [pricing], [profile_code], [profile_type], [proxy_profile_type], [reference], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4], [strategy], [structured_deal_id], [subsidiary], [template], [trader], [update_user], [deal_date_varchar],[entire_term_start_varchar], [entire_term_end_varchar], [scheduler], [inco_terms], [detail_inco_terms], [trader2], [counterparty2], [origin], [form], [organic], [attribute1], [attribute2], [attribute3], [attribute4], [attribute5], [governing_law], [payment_term], [arbitration], [counterparty2_trader], [counterparty_trader], [batch_id], [buyer_seller_option], [crop_year], [product_description],[reporting_group1],[reporting_group2],[reporting_group3],[reporting_group4],[reporting_group5]'
 		
 		SET @batch_process_id_deal = REPLACE(NEWID(), '-', '_')
 		SET @tempTableDeal = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id_deal)
 		
 		IF @debug_mode = 1
			EXEC spa_print 'Deal table - ', @tempTableDeal
 
 		EXEC('CREATE TABLE ' +  @tempTableDeal + '
                      (
                      	[SNO]					   [INT] IDENTITY(1,1) NOT NULL,	
                      	source_deal_header_id      INT,
                      	source_system_id           INT,
                      	deal_id                    VARCHAR(MAX),
                      	deal_date                  DATETIME,
                      	ext_deal_id                VARCHAR(MAX),
                      	physical_financial         VARCHAR(MAX),
                      	structured_deal_id         VARCHAR(MAX),
                      	counterparty               VARCHAR(MAX),
                      	parent_counterparty        VARCHAR(MAX),
                      	entire_term_start          DATETIME,
                      	entire_term_end            DATETIME,
                      	deal_type                  VARCHAR(MAX),
                      	deal_sub_type              VARCHAR(MAX),
                      	option_flag                VARCHAR(MAX),
                      	option_type                VARCHAR(MAX),
                      	option_excercise_type      VARCHAR(MAX),
                      	source_system_book_id1     VARCHAR(MAX),
                      	source_system_book_id2     VARCHAR(MAX),
                      	source_system_book_id3     VARCHAR(MAX),
                      	source_system_book_id4     VARCHAR(MAX),
                      	subsidiary                 VARCHAR(MAX),
                      	strategy                   VARCHAR(MAX),
                      	Book                       VARCHAR(MAX),
                      	description1               VARCHAR(MAX),
                      	description2               VARCHAR(MAX),
                      	description3               VARCHAR(MAX),
                      	deal_category              VARCHAR(MAX),
                      	trader                     VARCHAR(MAX),
                      	internal_deal_type         VARCHAR(MAX),
                      	internal_deal_subtype      VARCHAR(MAX),
                      	template                   VARCHAR(MAX),
                      	broker                     VARCHAR(MAX),
                      	generator                  VARCHAR(MAX),
                      	deal_status_date           DATETIME,
                      	assignment_type            VARCHAR(MAX),
                      	compliance_year            INT,
                      	state_value                VARCHAR(MAX),
                      	assigned_date              DATETIME,
                      	assigned_user              VARCHAR(MAX),
                      	CONTRACT                   VARCHAR(MAX),
                      	create_user                VARCHAR(MAX),
                      	create_ts                  DATETIME,
                      	update_user                VARCHAR(MAX),
                      	update_ts                  DATETIME,
                      	legal_entity               VARCHAR(MAX),
                      	deal_profile               VARCHAR(MAX),
                      	fixation_type              VARCHAR(MAX),
                      	internal_portfolio         VARCHAR(MAX),
                      	commodity                  VARCHAR(MAX),
                      	reference                  VARCHAR(MAX),
                      	locked_deal                CHAR,
                      	close_reference_id         INT,
                      	block_type                 VARCHAR(MAX),
                      	block_definition           VARCHAR(MAX),
                      	granularity                VARCHAR(MAX),
                      	pricing                    VARCHAR(MAX),
                      	deal_reference_type        INT,
                      	deal_status                VARCHAR(MAX),
                      	confirm_status_type        VARCHAR(MAX),
                      	term_start                 DATETIME,
                      	term_end                   DATETIME,
                      	contract_expiration_date   DATETIME,
                      	fixed_float                VARCHAR(MAX),
                      	buy_sell                   VARCHAR(MAX),
                      	index_name                 VARCHAR(MAX),
                      	index_commodity            VARCHAR(MAX),
                      	index_currency             VARCHAR(MAX),
                      	index_uom                  VARCHAR(MAX),
                      	index_proxy1               VARCHAR(MAX),
                      	index_proxy2               VARCHAR(MAX),
                      	index_proxy3               VARCHAR(MAX),
                      	index_settlement           VARCHAR(MAX),
                      	expiration_calendar        VARCHAR(MAX),
                      	deal_formula               VARCHAR(MAX),
                      	location                   VARCHAR(MAX),
                      	location_region            VARCHAR(MAX),
                      	location_grid              VARCHAR(MAX),
                      	location_country           VARCHAR(MAX),
                      	location_group             VARCHAR(MAX),
                      	forecast_profile           VARCHAR(MAX),
                      	forecast_proxy_profile     VARCHAR(MAX),
                      	profile_type               VARCHAR(MAX),
                      	proxy_profile_type         VARCHAR(MAX),
                      	meter                      VARCHAR(MAX),
                      	profile_code               VARCHAR(MAX),
                      	Pr_party                   VARCHAR(MAX),
                      	UDF                        VARCHAR(MAX),
                      	deal_date_varchar          VARCHAR(MAX),
                      	entire_term_start_varchar  VARCHAR(MAX),
                      	entire_term_end_varchar    VARCHAR(MAX),
						[scheduler]				   VARCHAR(MAX), 
						[inco_terms]			   VARCHAR(MAX), 
						[detail_inco_terms]		   VARCHAR(MAX), 
						[trader2]				   VARCHAR(MAX), 
						[counterparty2]			   VARCHAR(MAX), 
						[origin]				   VARCHAR(MAX), 
						[form]					   VARCHAR(MAX), 
						[organic]				   VARCHAR(MAX), 
						[attribute1]			   VARCHAR(MAX), 
						[attribute2]			   VARCHAR(MAX), 
						[attribute3]			   VARCHAR(MAX), 
						[attribute4]			   VARCHAR(MAX), 
						[attribute5]			   VARCHAR(MAX), 
						[governing_law]			   VARCHAR(MAX), 
						[payment_term]			   VARCHAR(MAX), 
						[arbitration]			   VARCHAR(MAX), 
						[counterparty2_trader]	   VARCHAR(MAX), 
						[counterparty_trader]	   VARCHAR(MAX), 
						[batch_id]				   VARCHAR(MAX), 
						[buyer_seller_option]	   VARCHAR(MAX), 
						[crop_year]				   VARCHAR(MAX), 
						[product_description]	   VARCHAR(MAX),
						[reporting_group1]		   VARCHAR(MAX),
						[reporting_group2]		   VARCHAR(MAX),  
						[reporting_group3]		   VARCHAR(MAX),
						[reporting_group4]		   VARCHAR(MAX), 
						[reporting_group5]		   VARCHAR(MAX) 
                      ) ON [PRIMARY]')
 	END
 	
 	
 	IF (@searchOnSearch IS NOT NULL)
 	BEGIN
 		DECLARE @sql_str VARCHAR(MAX)

 		SET @sql_str = 'INSERT INTO ' +@temptablename + ' (Object, Details, TableName) '
 		IF @searchTables = '''master_deal_view'''
 		BEGIN
 			SET @sql_select_deal = 'INSERT INTO ' + @tempTableDeal + ' (' + @columnListDeal + ')'	
 		END
 		
 		DECLARE string_cursor_sws CURSOR FOR 
 		SELECT search_string FROM #temp_search_string
 		OPEN string_cursor_sws
 		FETCH NEXT FROM string_cursor_sws INTO @searchString
 		WHILE @@FETCH_STATUS = 0
 		BEGIN	
 			EXEC('DELETE FROM ' + @temptablename)
 			IF (@searchTables = '''master_deal_view''')
 			BEGIN
 				IF ISDATE(@searchString) = 1
 				BEGIN
 					SET @date_search = 'y'
 					SELECT @search_column =  clmn FROM #temp WHERE search_string = @searchString
 					SELECT @operator = operator FROM #temp WHERE search_string = @searchString AND clmn = @search_column
 				END
 				
 				SELECT @displayColumns = displayColumns from  dbo.search_meta_data where tableName = 'master_deal_view'
 				IF @sql_flag = 'y'
 				BEGIN
 					SELECT @columns = COALESCE(@columns + ',' ,'') + smd.columnName FROM dbo.search_meta_data smd WHERE smd.tableName = 'master_deal_view' AND smd.columnName IN (SELECT clmn FROM #temp WHERE search_string = @searchString)
 				END
 				ELSE
 				BEGIN
 					SELECT @columns = COALESCE(@columns + ',' ,'') + smd.columnName FROM dbo.search_meta_data smd WHERE smd.tableName = 'master_deal_view' AND smd.columnName IN (SELECT a.Item FROM dbo.SplitCommaSeperatedValues(@searchColumns) a)	
 				END
 				
 				IF @debug_mode = 1
					EXEC spa_print @columns
 
 				--EXEC('DELETE FROM ' + @temptablename)
 				SET @sql_str =  @sql_str + ' SELECT DISTINCT ''master_deal_view'' AS Object, ' + @displayColumns + ' AS Details, ''Deal'' AS TableName '
 								+ ' from ' + @searchOnSearch + 
 								CASE WHEN (@columns IS NOT NULL)
 								THEN
 									CASE 
 										WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @searchString + ''''
 										ELSE ' where contains((' + @columns + '),''' + @searchString + ''')' 
 									END  
 								ELSE
 									CASE 
 										WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @searchString + ''''
 										ELSE ' where contains(*,''' + @searchString + ''')'
 									END 
 								END
 				IF @debug_mode = 1
					EXEC spa_print 'deal_select_sws'
 				
 				SET @sql_select_deal = @sql_select_deal + ' SELECT DISTINCT ' + @columnListDeal + ' FROM ' + @searchOnSearch +
 										CASE WHEN (@columns IS NOT NULL)
 										THEN
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @searchString + ''''
 												ELSE ' where contains((' + @columns + '),''' + @searchString + ''')' 
 											END  
 										ELSE
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @searchString + ''''
 												ELSE ' where contains(*,''' + @searchString + ''')'
 											END 
 										END  
 			
 			END
 			ELSE
 			BEGIN
 				SET @sql_str = @sql_str + 'SELECT Object, Details, TableName'+ '  FROM ' + @searchOnSearch + ' where contains(*,'''  + @searchString + ''')' + CASE WHEN @searchTables IS NOT NULL THEN ' AND Object IN (SELECT a.Item FROM dbo.SplitCommaSeperatedValues(' + @searchTables +') a )' ELSE '' END
 			END
 			
 			FETCH NEXT FROM string_cursor_sws INTO @searchString
 			IF @@FETCH_STATUS = 0 
 			BEGIN
 				
 				IF (@searchTables = '''master_deal_view''')
 				BEGIN
 					SET @sql_str = @sql_str + ' INTERSECT '
 					SET @sql_select_deal = @sql_select_deal + ' INTERSECT '
 					SET @date_search = NULL
 				END
 				ELSE
 				BEGIN
 					SET @sql_str = @sql_str + ' UNION '
 				END
 				SET @columns = NULL
 				SET @date_search = NULL
 			END
 			
 		END
 		CLOSE string_cursor_sws
 		DEALLOCATE string_cursor_sws
 		
 		IF @debug_mode = 1
 		BEGIN
			EXEC spa_print @sql_str
			exec spa_print @sql_select_deal
 		END
 			
 		EXEC(@sql_str)	
 		EXEC(@sql_select_deal)
 		
 		IF @callFrom = 'h'
 		BEGIN
 			EXEC('IF EXISTS ( SELECT 1 FROM   ' + @temptablename + ' ) BEGIN SELECT [Details] AS [Search Results]  FROM ' + @temptablename + ' ORDER BY [TableName] END ElSE BEGIN SELECT ''No Matching Data.'' AS [Search Results] END')
 			--EXEC ('SELECT [Details]'  + @str_batch_table + ' FROM ' + @temptablename)	
 		END					
 		IF @callFrom = 'x'
 		BEGIN
 			EXEC ('SELECT TOP 1 ''' + @batch_process_id1 + ''' AS ProcessID FROM ' + @temptablename)
 		END
 		IF @callFrom = 's'
 		BEGIN
 			EXEC('IF EXISTS (SELECT 1 FROM ' + @temptablename + ')
 			      BEGIN
 			          SELECT ''' + @temptablename + ''' AS [ProcessTable],
 			                 COUNT([Object]) AS [Record Number],
 			                 [Object] AS [Object ID],
 			                 CAST(ROW_NUMBER() OVER(ORDER BY [Object] DESC) AS VARCHAR(10)) + ''. '' +
 			                 CASE [Object]
 			                      WHEN ''master_deal_view'' THEN ''Deal''
 			                      WHEN ''portfolio_hierarchy'' THEN ''Portfolio Hierarchy''
 			                      WHEN ''source_commodity'' THEN ''Commodity''
 			                      WHEN ''source_counterparty'' THEN ''Counterparty''
 			                      WHEN ''source_minor_location'' THEN ''Location''
 			                      WHEN ''workflow_activities_audit_summary'' THEN ''Workflow Activities Audit''
 			                      ELSE [Object]
 			                 END AS [Object Name],
 			                 MAX(SUBSTRING([Details], 0, 500)) AS [Details],
 			                 CASE [Object]
 			                      WHEN ''master_deal_view'' THEN ''' + @tempTableDeal + '''
 			                      ELSE ''NULL''
 			                 END AS [Search within Search]
 			          FROM   ' + @temptablename + '
 			          GROUP BY [Object]
 			      END
 			      ELSE
 			      BEGIN
 			          SELECT NULL, NULL, NULL, NULL, ''No Matching Data.'' AS [Search Results]
 			      END')
 		END
 		
 		IF @callFrom <> 'd'
 		BEGIN
 			IF @debug_mode = 1			
				EXEC spa_print 'Creating FTI'
 			EXEC ( 'CREATE UNIQUE INDEX idx ON ' + @temptablename + '(SNO)')
 			EXEC ( 'CREATE fulltext INDEX ON ' + @temptablename + '(Details) KEY INDEX idx ON TRMTrackerFTI')
 			EXEC ( 'CREATE UNIQUE INDEX idx ON ' + @tempTableDeal + '(SNO)')
 			EXEC ( 'CREATE fulltext INDEX ON ' + @tempTableDeal + '(' + @columnListfulltext + ') KEY INDEX idx ON TRMTrackerFTI')
 			IF @debug_mode = 1
 			BEGIN
				EXEC spa_print @temptablename
				EXEC spa_print @tempTableDeal
 			END
 		END
 		
 	END
 	ELSE
 	BEGIN 
 		DECLARE @detail_table VARCHAR(300)
 		DECLARE @search_table VARCHAR(300)
 		DECLARE @table_label VARCHAR(300)
 		
 		IF OBJECT_ID('tempdb..#temp_search_results') IS NOT NULL
 			DROP TABLE #temp_search_results
 		
 		CREATE TABLE #temp_search_results (
 			[process_table] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
 			[record_number] INT,
 			[object_id] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
 			[object_name] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
 			[Details] VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
 			[search_within_search] VARCHAR(200) COLLATE DATABASE_DEFAULT ,
 			[detail_table] VARCHAR(500) COLLATE DATABASE_DEFAULT 
 		)
 		
 		IF @debug_mode = 1
 			EXEC spa_print @searchString
 		
 		SET @sqlSELECT = 'INSERT INTO ' + @temptablename + ' (Object, Details, TableName) '
 		SET @sql_select_deal = 'INSERT INTO ' + @tempTableDeal + ' (' + @columnListDeal + ')'
 		 		
 		DECLARE tableCursor CURSOR FOR 
 		SELECT t1.table_name, t1.table_label 	
 		FROM #temp_search_tables t1  --select * from #temp_search_tables select * from #temp_search_string
 		INNER JOIN #temp_search_string t2 ON t1.table_name = t2.table_name 	
 		GROUP BY t1.table_name, t1.table_label 		
 		OPEN tableCursor
 		FETCH NEXT FROM tableCursor INTO @search_table, @table_label
 
 		WHILE @@FETCH_STATUS = 0
 		BEGIN
 			SET @detail_table = NULL
 			SET @detail_table = dbo.FNAProcessTableName(@search_table, @user_login_id, @batch_process_id1)
 			
 			DECLARE @detail_column_list VARCHAR(MAX) = NULL,
 					@detail_column_create_list VARCHAR(MAX) = NULL
 					
 			IF @search_table = 'master_deal_view'
 			BEGIN
 				SET @detail_column_list = 'source_deal_header_id,source_system_id,deal_id,deal_date,ext_deal_id,physical_financial,structured_deal_id,counterparty,parent_counterparty,entire_term_start,entire_term_end,deal_type,deal_sub_type,option_flag,option_type,option_excercise_type,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,subsidiary,strategy,Book,description1,description2,description3,deal_category,trader,internal_deal_type,internal_deal_subtype,template,broker,generator,deal_status_date,assignment_type,compliance_year,state_value,assigned_date,assigned_user,CONTRACT,create_user,create_ts,update_user,update_ts,legal_entity,deal_profile,fixation_type,internal_portfolio,commodity,reference,locked_deal,close_reference_id,block_type,block_definition,granularity,pricing,deal_reference_type,deal_status,confirm_status_type,term_start,term_end,contract_expiration_date,fixed_float,buy_sell,index_name,index_commodity,index_currency,index_uom,index_proxy1,index_proxy2,index_proxy3,index_settlement,expiration_calendar,deal_formula,location,location_region,location_grid,location_country,location_group,forecast_profile,forecast_proxy_profile,profile_type,proxy_profile_type,meter,profile_code,Pr_party,UDF,deal_date_varchar,entire_term_start_varchar,entire_term_end_varchar, scheduler, inco_terms, detail_inco_terms, trader2, counterparty2, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5, governing_law, payment_term, arbitration, counterparty2_trader, counterparty_trader, batch_id, buyer_seller_option, crop_year, product_description,reporting_group1,reporting_group2,reporting_group3,reporting_group4,reporting_group5'
 			END
 			ELSE IF @search_table = 'application_notes'
 			BEGIN
 				SET @detail_column_list = 'notes_id,internal_type_value_id,category_value_id,notes_object_name,notes_object_id,notes_subject,notes_text,attachment_file_name,notes_attachment,fas_subsidiary_id,content_type,create_user,create_ts,update_user,update_ts,source_system_id,notes_share_email_enable,url,user_category,workflow_process_id,workflow_message_id,attachment_folder,parent_object_id,UI,FS_Data,type_column_name'
 			END
			ELSE IF @search_table = 'email_notes'
 			BEGIN
 				SET @detail_column_list = 'notes_id,internal_type_value_id,category_value_id,notes_object_name,notes_object_id,notes_subject,notes_text,attachment_file_name,notes_attachment,send_from,send_to,send_cc,send_bcc,send_status,active_flag,create_user,create_ts,update_user,update_ts,process_id,notes_description,email_type,UI,FS_Data,type_column_name,user_category,attachment_folder,document_type'
 			END
			ELSE IF @search_table IN ('master_view_counterparty_epa_account', 'source_counterparty', 'counterparty_bank_info', 'VW_counterparty_certificate', 'master_view_counterparty_products', 'master_view_counterparty_contacts', 'master_view_counterparty_contract_address')
 			BEGIN
				SET @detail_table = dbo.FNAProcessTableName('source_counterparty', @user_login_id, @batch_process_id1)
 				SET @detail_column_list = 'source_counterparty_id, counterparty_id,counterparty_name,counterparty_desc'
 			END 					
 			ELSE IF @search_table IN ('contract_group')
 			BEGIN
 				SET @detail_column_list = 'contract_id,contract_name,contract_desc,name,company,address,address2'
 			END
			ELSE IF @search_table IN ('master_view_counterparty_credit_info', 'master_view_counterparty_credit_enhancements', 'master_view_counterparty_credit_limits', 'master_view_counterparty_credit_migration')
			BEGIN
				SET @detail_table = dbo.FNAProcessTableName('credit_info', @user_login_id, @batch_process_id1)
				SET @detail_column_list = 'counterparty_credit_info_id,counterparty_id,counterparty_name,counterparty_desc'
			END 
			ELSE IF @search_table IN ('master_view_incident_log', 'master_view_incident_log_detail')
			BEGIN
				SET @detail_table = dbo.FNAProcessTableName('incident_log', @user_login_id, @batch_process_id1)
				SET @detail_column_list = 'incident_log_id,incident_type,incident_description,incident_status'			
			END
			ELSE IF @search_table = 'master_view_incident_log_detail'
			BEGIN
				SET @detail_column_list = 'incident_log_id,incident_status,incident_update_date,comments'
			END

 			SELECT @detail_column_create_list = COALESCE(@detail_column_create_list + ', ', '') + scsv.item + case when @search_table IN ('application_notes','email_notes') and scsv.item = 'FS_Data' then ' VARBINARY(MAX)' else ' VARCHAR(MAX)' end
 			FROM dbo.SplitCommaSeperatedValues(@detail_column_list) scsv
 			
 			IF @detail_column_create_list IS NOT NULL 			
 				SET @detail_column_create_list = 'sno INT IDENTITY(1,1), ' + @detail_column_create_list
 					
 			SET @sql = NULL

			IF OBJECT_ID(@detail_table) IS NULL
			BEGIN
 				SET @sql = 'CREATE TABLE ' + @detail_table + ' ( ' + @detail_column_create_list + ')'
 			
 				EXEC(@sql)
			END
 			
 			DECLARE @sql_detail VARCHAR(MAX)
 			SET @sql_detail = ' INSERT INTO ' + @detail_table + ' (' + @detail_column_list + ')'
 			SET @sqlSELECT = 'INSERT INTO ' + @temptablename + ' (Object, Details, TableName) '
 			
 			SELECT @displayColumns = displayColumns from  dbo.search_meta_data where tableName = @search_table
 			 			
 			DECLARE @search_string VARCHAR(5000) 
 			
 			DECLARE string_cursor CURSOR FOR 
 			SELECT search_string, clmn, operator FROM #temp_search_string
 			WHERE table_name = @search_table
 			OPEN string_cursor
 			FETCH NEXT FROM string_cursor INTO @search_string, @search_column, 	@operator					
 			WHILE @@FETCH_STATUS = 0
 			BEGIN
 				IF @debug_mode = 1
 					EXEC spa_print @search_string
 				
 				IF ISDATE(@search_string) = 1 AND @search_table = 'master_deal_view'
 				BEGIN
 					SET @date_search = 'y'
 				END
 				 				
 				IF @sql_flag = 'y'
 				BEGIN
 					SELECT @columns = COALESCE(@columns + ',', '') + clmn
 					FROM #temp_search_string t1
 					INNER JOIN search_meta_data smd 
 						ON t1.clmn = smd.columnName
 						AND t1.table_name = smd.tableName
 					WHERE search_string = @search_string
 					AND table_name = @search_table
 					GROUP BY clmn
 				END
 				ELSE
 				BEGIN
 					SELECT @columns = COALESCE(@columns + ',', '') + smd.columnName
 					FROM   dbo.search_meta_data smd
 					WHERE smd.tableName = @search_table
 					AND   smd.columnName IN (SELECT a.Item
 					                         FROM   dbo.SplitCommaSeperatedValues(@searchColumns) a)	
 				END
 				
 				IF @debug_mode = 1
 					EXEC spa_print @columns				
 				
				
 				--PRINT('DELETE FROM ' + @temptablename)
 				
 				if @search_table in ('master_view_counterparty_epa_account', 'counterparty_bank_info', 'VW_counterparty_certificate', 'master_view_counterparty_products', 'master_view_counterparty_contacts', 'master_view_counterparty_contract_address')
				begin
					IF @search_table IN ('master_view_counterparty_contract_address', 'master_view_counterparty_epa_account')
					BEGIN
						SET @sqlSELECT =  @sqlSELECT  
 									+ 'SELECT TOP(1) ''' + @search_table + ''' AS Object, ' + @displayColumns + ' AS Details, ''' + @table_label + ''' AS TableName '
 									+ ' from ' + @search_table + 
 									CASE WHEN (@columns IS NOT NULL)
 									THEN
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END  
 									ELSE
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END 
 									END
					END	
					ELSE
					BEGIN		
						SET @sqlSELECT =  @sqlSELECT + '
										SELECT TOP(1) ''' + @search_table + ''' AS Object, ' + @displayColumns + ' AS Details, ''' + @table_label + ''' AS TableName ' + '
										FROM source_counterparty sc
										where sc.source_counterparty_id in (
											select distinct counterparty_id
											from ' + @search_table + 
 										CASE WHEN (@columns IS NOT NULL)
 										THEN
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END  
 										ELSE
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END 
 										END +
										')'
					END
					SET @sql_detail =  @sql_detail + '
									SELECT ' + @detail_column_list + '
									FROM source_counterparty sc
									where sc.source_counterparty_id in (
										select distinct counterparty_id
										from ' + @search_table + 
									CASE WHEN (@columns IS NOT NULL)
 										THEN
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END  
 										ELSE
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END 
 									END +
									')'
				end
				ELSE IF @search_table IN ('master_view_counterparty_credit_info', 'master_view_counterparty_credit_enhancements', 'master_view_counterparty_credit_limits', 'master_view_counterparty_credit_migration')
				BEGIN
					SET @sqlSELECT =  @sqlSELECT  
 									+ 'SELECT TOP(1) ''' + @search_table + ''' AS Object, ' + @displayColumns + ' AS Details, ''' + @table_label + ''' AS TableName '
 									+ ' from ' + @search_table + 
 									CASE WHEN (@columns IS NOT NULL)
 									THEN
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END  
 									ELSE
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END 
 									END

					SET @sql_detail =  @sql_detail + '
									SELECT cci.Counterparty_id,sc.counterparty_id,sc.counterparty_name,sc.counterparty_desc
									FROM counterparty_credit_info cci
									INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id 
									where cci.counterparty_credit_info_id in (
										select distinct counterparty_credit_info_id
										from ' + @search_table + 
									CASE WHEN (@columns IS NOT NULL)
 										THEN
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END  
 										ELSE
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END 
 									END +
									')'
				END
				ELSE IF @search_table IN ('master_view_incident_log', 'master_view_incident_log_detail')
				BEGIN
					SET @sqlSELECT =  @sqlSELECT  
 									+ 'SELECT TOP(1) ''' + @search_table + ''' AS Object, ' + @displayColumns + ' AS Details, ''' + @table_label + ''' AS TableName '
 									+ ' from ' + @search_table + 
 									CASE WHEN (@columns IS NOT NULL)
 									THEN
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END  
 									ELSE
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END 
 									END

					SET @sql_detail =  @sql_detail + '
									SELECT ' + @detail_column_list + ' 
									FROM master_view_incident_log cci
									where cci.incident_log_id in (
										select distinct incident_log_id
										from ' + @search_table + 
									CASE WHEN (@columns IS NOT NULL)
 										THEN
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END  
 										ELSE
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END 
 									END +
									')'
				END
				else if @search_table in ('application_notes')
				begin
					SET @sqlSELECT =  @sqlSELECT  
 									+ 'SELECT TOP(1) ''' + @search_table + ''' AS Object, ' + @displayColumns + ' AS Details, ''' + @table_label + ''' AS TableName '
 									+ ' from ' + @search_table + 
 									CASE WHEN (@columns IS NOT NULL)
 									THEN
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END  
 									ELSE
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END 
 									END
									-- + 
									--'
									--union all
									--SELECT TOP(1) ''' + @search_table + ''' AS Object, ' + @displayColumns + ' AS Details, ''' + @table_label + ''' AS TableName 
									--from email_notes
									--' + 
									--CASE 
 								--		WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 								--		ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 								--	END
					SET @sql_detail =  @sql_detail + '
									SELECT ' + @detail_column_list + '
									FROM ' + @search_table + 
									CASE WHEN (@columns IS NOT NULL)
 										THEN
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END  
 										ELSE
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END 
 									END 
									--+ 
									--'
									--union all
									----select notes_id,internal_type_value_id,category_value_id,notes_object_name,notes_object_id,notes_subject,notes_text,attachment_file_name,notes_attachment,null fas_subsidiary_id,null content_type,create_user,create_ts,update_user,update_ts,null source_system_id,null notes_share_email_enable,null url,user_category,null workflow_process_id,null workflow_message_id,attachment_folder,null parent_object_id,UI,FS_Data,type_column_name
									----from email_notes
									--' + 
									--CASE 
 								--		WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 								--		ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 								--	END 

 									
				end
				else if @search_table in ('email_notes')
				begin
					SET @sqlSELECT =  @sqlSELECT  
 									+ 'SELECT TOP(1) ''' + @search_table + ''' AS Object, ' + @displayColumns + ' AS Details, ''' + @table_label + ''' AS TableName '
 									+ ' from ' + @search_table + 
 									CASE WHEN (@columns IS NOT NULL)
 									THEN
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END  
 									ELSE
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END 
 									END + 
									'
									union all
									SELECT TOP(1) ''' + @search_table + ''' AS Object, ' + @displayColumns + ' AS Details, ''' + @table_label + ''' AS TableName 
									from (
										select adt.*, en.email_type, en.notes_subject   
										from attachment_detail_info adt
										inner join email_notes en on en.notes_id = adt.email_id'
										+ 
										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains(adt.*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END + ' and adt.email_id is not null
									) a
									' 
					
					SET @sql_detail =  @sql_detail + '
									SELECT ' + @detail_column_list + '
									FROM ' + @search_table + 
									CASE WHEN (@columns IS NOT NULL)
 										THEN
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END  
 										ELSE
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END 
 									END 
									+ 
									'
									union all
									select adt.email_id notes_id
										,null internal_type_value_id,null category_value_id,null notes_object_name,null notes_object_id,null notes_subject
										,null notes_text,null attachment_file_name,null notes_attachment,null send_from,null send_to,null send_cc,null send_bcc
										,null send_status,null active_flag,null create_user,null create_ts,null update_user,null update_ts
										,null process_id,null notes_description,null email_type,null UI,null FS_Data,null type_column_name
										,null user_category,null attachment_folder,null document_type
									from attachment_detail_info adt
									' + 
									CASE 
 										WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 										ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 									END +
									' and adt.email_id is not null'

 									
				end
				else
				begin
					SET @sqlSELECT =  @sqlSELECT  
 									+ 'SELECT TOP(1) ''' + @search_table + ''' AS Object, ' + @displayColumns + ' AS Details, ''' + @table_label + ''' AS TableName '
 									+ ' from ' + @search_table + 
 									CASE WHEN (@columns IS NOT NULL)
 									THEN
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END  
 									ELSE
 										CASE 
 											WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 											ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 										END 
 									END
					SET @sql_detail =  @sql_detail + '
									SELECT ' + @detail_column_list + '
									FROM ' + @search_table + 
									CASE WHEN (@columns IS NOT NULL)
 										THEN
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains((' + @columns + '),''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END  
 										ELSE
 											CASE 
 												WHEN @date_search = 'y' THEN ' where ' + @search_column + @operator + '''' + @search_string + ''''
 												ELSE ' where contains(*,''' + @search_string + ''')' + ISNULL(@filter_text, '')
 											END 
 									END
				end
				
 				FETCH NEXT FROM string_cursor INTO @search_string, @search_column, @operator
 				IF @@FETCH_STATUS = 0
 				BEGIN
 					SET @sqlSELECT = @sqlSELECT + ' INTERSECT '
 					SET @sql_detail = @sql_detail + ' INTERSECT '
 				END 
 				
 				SET @columns = NULL
 				set @date_search = 'n'
 			END
 			CLOSE string_cursor
 			DEALLOCATE string_cursor
 			
 			IF @debug_mode = 1
 				EXEC spa_print @sql_detail
 				--print @sql_detail
 			EXEC(@sql_detail)
 				
 			IF @debug_mode = 1
 				EXEC spa_print @sqlSELECT
				--print @sqlSELECT	
 			EXEC(@sqlSELECT)
 			
 			DECLARE @detail_count INT = null, @detail_string VARCHAR(MAX) = null, @nsql NVARCHAR(MAX) = null
						
			--exec('select * from ' + @temptablename)
			--select @search_table, @detail_string
			
			--new code no highlight span
			SET @nsql = 'SELECT @detail_string = replace([Details],'''''''','''''''''''')
 							FROM ' + @temptablename + ' t
 							--OUTER APPLY (SELECT search_string, COUNT(1) st_count FROM #temp_search_string GROUP BY search_string) st
 							WHERE t.[Object] = ''' + @search_table + ''''
 			--print @nsql	
				if @debug_mode = 1
					EXEC spa_print @nsql
			--new code no highlight span
			
			/*
			if @search_table in('application_notes','counterparty_bank_info','VW_counterparty_certificate', 'master_view_counterparty_products', 'master_view_counterparty_contacts','email_notes')
			begin
 				SET @nsql = 'SELECT @detail_string = replace(COALESCE(@detail_string + '' '', '''') + [Details], REPLACE(REPLACE(st.search_string, ''"'', ''''), ''*'', ''''), ''<span class="highlight">'' + REPLACE(REPLACE(st.search_string, ''"'', ''''), ''*'', '''') + ''</span>'')
 							FROM ' + @temptablename + ' t
 							OUTER APPLY (SELECT search_string, COUNT(1) st_count FROM #temp_search_string GROUP BY search_string) st
 							WHERE t.[Object] = ''' + @search_table + ''''
 				if @debug_mode = 1
					EXEC spa_print @nsql
 				
 			end		
			else
			begin
				SET @nsql = 'SELECT @detail_string = case when CHARINDEX(REPLACE(REPLACE(st.search_string, ''"'', ''''), ''*'', ''''), dbo.FNAStripHTML([Details])) = 0
			then dbo.FNAStripHTML([Details]) else COALESCE(@detail_string + '' '', '''') +
 										RIGHT(LEFT(dbo.FNAStripHTML([Details]), CHARINDEX(REPLACE(REPLACE(st.search_string, ''"'', ''''), ''*'', ''''), dbo.FNAStripHTML([Details])) - 1), 500) + ''<span class="highlight">'' + REPLACE(REPLACE(st.search_string, ''"'', ''''), ''*'', '''') + ''</span>'' + LEFT(RIGHT(dbo.FNAStripHTML([Details]), LEN(dbo.FNAStripHTML([Details])) - CHARINDEX(REPLACE(REPLACE(st.search_string, ''"'', ''''), ''*'', ''''), dbo.FNAStripHTML([Details])) - LEN(REPLACE(REPLACE(st.search_string, ''"'', ''''), ''*'', ''''))), 500) end
 							FROM ' + @temptablename + ' t
 							OUTER APPLY (SELECT search_string, COUNT(1) st_count FROM #temp_search_string GROUP BY search_string) st
 							WHERE t.[Object] = ''' + @search_table + ''''
 				if @debug_mode = 1
					print @nsql
 				
				
			end
			
			--*/
			EXEC sp_executesql @nsql, N'@detail_string VARCHAR(MAX) output', @detail_string OUTPUT
			--select @search_table, @detail_string
			SET @nsql = 'SELECT @detail_count = COUNT(1) FROM ' + @detail_table
			EXEC sp_executesql @nsql , N'@detail_count INT output', @detail_count OUTPUT
 			
 			IF @detail_count <> 0
 			BEGIN
 				SET @sql = 'INSERT INTO #temp_search_results (process_table, record_number, object_id, object_name, Details, detail_table)
 							VALUES( ''' + @temptablename + ''',
 								   ' + CAST(@detail_count AS VARCHAR(20)) + ',
 								   ''' + @search_table + ''',
 								   ''' + @table_label + ''',
 								   ''' + REPLACE(@detail_string, '''','''''') + ''',
 								   ''' + @detail_table + '''
 							)
 						'
 			
 				EXEC(@sql)
 			END
 			
 			FETCH NEXT FROM tableCursor INTO @search_table, @table_label
 			SET @columns = NULL
 		END
 		CLOSE tableCursor
 		DEALLOCATE tableCursor
 		
 		IF @callFrom = 'h'
 		BEGIN
 			SET @sql = 'IF EXISTS ( SELECT 1 FROM   ' + @temptablename + ' ) BEGIN 
 							SELECT [Details] AS [Search Results] 
 							FROM ' + @temptablename + ' ORDER BY [TableName]
 						END 
 						ElSE 
 						BEGIN 
 							SELECT ''No Matching Data.'' AS [Search Results] 
 						END'
 		END 
 		IF @callFrom = 'x'
 		BEGIN
 			SET @sql = 'SELECT TOP 1 ''' + @temptablename + ''' AS ProcessTable  FROM ' + @temptablename
 		END
 		IF @callFrom = 's'
 		BEGIN
			declare @cpty_search_object_count int
			
			if OBJECT_ID(N'tempdb..#cpty_search_object_result', N'U') is not null drop table #cpty_search_object_result
			
			select * into #cpty_search_object_result --select * from #cpty_search_object_result
			from #temp_search_results t 
			where t.[object_id] in (
				'source_counterparty',
				'counterparty_bank_info',
				'master_view_counterparty_products',
				'counterparty_certificate',
				'master_view_counterparty_contacts'
			)
			select @cpty_search_object_count = count(1) from #cpty_search_object_result 
			--select @cpty_search_object_count
			if @cpty_search_object_count > 1 
			begin
				declare @cpty_final_result_table varchar(300) = dbo.FNAProcessTableName('cpty_final_result', @user_login_id, @batch_process_id1)
				declare @c_detail_table varchar(500)

				declare  cur_all_cpty_data cursor for
				select detail_table from #cpty_search_object_result
				OPEN cur_all_cpty_data
 				FETCH NEXT FROM cur_all_cpty_data INTO @c_detail_table				
 				WHILE @@FETCH_STATUS = 0
 				BEGIN
					if OBJECT_ID('tempdb..##tmp_cpty_all_data') is not null
					begin
						set @sql = '
						insert into ##tmp_cpty_all_data
						select source_counterparty_id, counterparty_id, counterparty_name, counterparty_desc from ' + @c_detail_table
						exec(@sql)
					end
					else
					begin
						set @sql = '
						select source_counterparty_id, counterparty_id, counterparty_name, counterparty_desc into ##tmp_cpty_all_data
						from ' + @c_detail_table
						exec(@sql)
					end
					FETCH NEXT FROM cur_all_cpty_data INTO @c_detail_table
				END
 				CLOSE cur_all_cpty_data
 				DEALLOCATE cur_all_cpty_data
				
				set @sql = '
				select row_number() over(order by a.source_counterparty_id) sno, * into ' + @cpty_final_result_table + '
				from ( select distinct * from ##tmp_cpty_all_data) a
				'
				exec(@sql)
				if OBJECT_ID('tempdb..##tmp_cpty_all_data') is not null
				drop table ##tmp_cpty_all_data

				declare @cpty_count_record int
				SET @nsql = 'SELECT @cpty_count_record = COUNT(1) FROM ' + @cpty_final_result_table
				EXEC sp_executesql @nsql , N'@cpty_count_record INT output', @cpty_count_record OUTPUT
				--select * from drop table ##tmp_cpty_all_data

				SELECT max(process_table) process_table,
 					@cpty_count_record record_number,
 					'source_counterparty' [object_id],
 					cr.[object_name],
 					max(Details) Details,
 					max(search_within_search) search_within_search,
					@cpty_final_result_table detail_table
 				FROM   #cpty_search_object_result cr
				group by cr.[object_name]
				
				union all
				SELECT process_table,
 					record_number,
 					object_id,
 					object_name,
 					Details,
 					search_within_search,
 					detail_table
 				FROM   #temp_search_results
				where object_id not in (
					'source_counterparty',
					'counterparty_bank_info',
					'master_view_counterparty_products',
					'counterparty_certificate',
					'master_view_counterparty_contacts'
				)
				ORDER BY record_number DESC
			end
			else
			begin
				SELECT process_table,
 					record_number,
 					object_id,
 					object_name,
 					Details,
 					search_within_search,
 					detail_table
 				FROM   #temp_search_results	
				ORDER BY record_number DESC
			end
				
 			
 			RETURN								 
 		END
 		IF @callFrom = 'd'
 		BEGIN
 			SET @sql = 'SELECT ''' + @detail_table + ''' [process_table],
 								source_deal_header_id [Deal ID],
 								NULL [Details]
 						FROM   ' + @detail_table + '
 						'
 		END
 		IF @callFrom = 'e'
 		BEGIN
 			SET @sql = 'SELECT source_deal_header_id [Deal ID],
 								NULL [Details]
 						FROM   ' + @detail_table + '
 						'
 		END
 		
 		IF @debug_mode = 1
 			PRINT @sql
 		
 		EXEC (@sql)
 
 		
 		
 		IF @callFrom <> 'd'
 		BEGIN
 			IF @debug_mode = 1
 			PRINT 'Creating FTI'
 
 			EXEC ( 'CREATE UNIQUE INDEX idx ON ' + @temptablename + '(SNO)')
 			EXEC ( 'CREATE fulltext INDEX ON ' + @temptablename + '(Details) KEY INDEX idx ON TRMTrackerFTI')
 			IF EXISTS (SELECT 1 FROM dbo.SplitCommaSeperatedValues(@searchTables) a WHERE a.item = 'master_deal_view')
 			BEGIN
 				EXEC ( 'CREATE UNIQUE INDEX idx ON ' + @tempTableDeal + '(SNO)')
 				EXEC ( 'CREATE fulltext INDEX ON ' + @tempTableDeal + '(' + @columnListfulltext + ') KEY INDEX idx ON TRMTrackerFTI')
 			END
 		END
 		
 	END
 END	
 ELSE IF @flag = 'l'
 BEGIN
 	DECLARE @sql_str2 VARCHAR(MAX)
 	SET @sql_str2 = 'DECLARE string_cursor_link CURSOR FOR ' + 
 					CASE WHEN @sql_flag = 'y' THEN 'SELECT search_string FROM #temp'
 					ELSE 'SELECT ''' + @searchString + '''' END
 	EXEC(@sql_str2)
 	OPEN string_cursor_link
 	FETCH NEXT FROM string_cursor_link INTO @searchString
 	WHILE @@FETCH_STATUS = 0
 	BEGIN
 		DECLARE @sqlStmt VARCHAR(MAX)
 		SET @sqlStmt = 'IF EXISTS (
 						   SELECT 1
 						   FROM   ' + @process_table + '
 					   )
 					BEGIN
 						SELECT DISTINCT [Details] AS [Search Results]
 						FROM   ' + @process_table + '
 						WHERE  1 = 1
 						AND [Object] = ''' + REPLACE(@searchTables,'''','') + '''
 						' + CASE WHEN @searchOnSearch IS NOT NULL then ' AND contains(*,''' + @searchString + ''')' ELSE '' END  + '
						ORDER BY [Details]
					END
					ELSE
					BEGIN
						SELECT ''No Matching DATA.'' AS [Search Results] 
					END'
		FETCH NEXT FROM string_cursor_link INTO @searchString
		IF @@FETCH_STATUS = 0 set @sqlStmt = @sqlStmt + ' UNION '
	END
	CLOSE string_cursor_link
	DEALLOCATE string_cursor_link
	EXEC(@sqlStmt)
	
	IF @debug_mode = 1
		PRINT(@sqlStmt)
END
ELSE IF @flag = 'r'
BEGIN
	EXEC('SELECT SNO,
	   source_deal_header_id,
	   deal_id,
	   dbo.FNAGetSQLStandardDate(deal_date) deal_date,
	   ext_deal_id,
	   physical_financial,
	   structured_deal_id,
	   counterparty,
	   parent_counterparty,
	   dbo.FNAGetSQLStandardDate(entire_term_start) entire_term_start,
	   dbo.FNAGetSQLStandardDate(entire_term_end) entire_term_end,
	   deal_type,
	   deal_sub_type,
	   option_flag,
	   option_type,
	   option_excercise_type,
	   source_system_book_id1,
	   source_system_book_id2,
	   source_system_book_id3,
	   source_system_book_id4,
	   subsidiary,
	   strategy,
	   Book,
	   description1,
	   description2,
	   description3,
	   deal_category,
	   trader,
	   internal_deal_type,
	   internal_deal_subtype,
	   template, 
	   broker,
	   generator,
	   deal_status_date,
	   assignment_type,
	   compliance_year,
	   state_value,
	   dbo.FNAGetSQLStandardDate(assigned_date) assigned_date,
	   assigned_user,
	   CONTRACT,
	   create_user,
	   dbo.FNAGetSQLStandardDate(create_ts) create_ts,
	   update_user,
	   dbo.FNAGetSQLStandardDate(update_ts) update_ts,
	   legal_entity,
	   deal_profile,
	   fixation_type,
	   internal_portfolio,
	   commodity,
	   reference,
	   CASE WHEN locked_deal = ''n'' THEN ''No'' ELSE ''Yes'' END locked_deal,
	   close_reference_id,
	   block_type,
	   block_definition,
	   granularity,
	   pricing,
	   deal_reference_type,
	   deal_status,
	   confirm_status_type,
	   dbo.FNAGetSQLStandardDate(term_start) term_start,
	   dbo.FNAGetSQLStandardDate(term_end) term_end,
	   dbo.FNAGetSQLStandardDate(contract_expiration_date) contract_expiration_date,
	   fixed_float,
	   buy_sell,
	   index_name,
	   index_commodity,
	   index_currency,
	   index_uom,
	   index_proxy1,
	   index_proxy2,
	   index_proxy3,
	   index_settlement,
	   expiration_calendar,
	   deal_formula,
	   location,
	   location_region,
	   location_grid,
	   location_country,
	   location_group,
	   forecast_profile,
	   forecast_proxy_profile,
	   profile_type,
	   proxy_profile_type,
	   meter,
	   profile_code,
	   Pr_party,
	   UDF,
	   dbo.FNAGetSQLStandardDate(deal_date_varchar) deal_date_varchar,
	   dbo.FNAGetSQLStandardDate(entire_term_start_varchar) entire_term_start_varchar,
	   dbo.FNAGetSQLStandardDate(entire_term_end_varchar) entire_term_end_varchar, 
	   --,[scheduler], 
	   [inco_terms], 
	   [detail_inco_terms], 
	   [trader2], 
	   [counterparty2], 
	   [origin], 
	   [form], 
	   [organic], 
	   [attribute1], 
	   [attribute2], 
	   [attribute3], 
	   [attribute4], 
	   [attribute5], 
	   --[governing_law], 
	   --[payment_term], 
	   --[arbitration], 
	   [counterparty2_trader], 
	   [counterparty_trader], 
	   --[batch_id], 
	   [buyer_seller_option], 
	   [crop_year], 
	   [product_description]
	   FROM  ' + @process_table)
END
ELSE IF @flag = 'z'
BEGIN
	EXEC('SELECT MIN(sno) sno, cast(source_counterparty_id as varchar(500)) + ''^javascript:fx_click_parent_object_id_link(37,'' + cast(source_counterparty_id as varchar(500))+ '')^_self'' source_counterparty_id, MAX(counterparty_id) counterparty_id, MAX(counterparty_name) counterparty_name, MAX(counterparty_desc) counterparty_desc
      FROM ' + @process_table + ' temp 
	  GROUP BY source_counterparty_id
		')
END
ELSE IF @flag = 'x'
BEGIN
	EXEC('SELECT MIN(sno) sno, cast(counterparty_credit_info_id as varchar(500)) + ''^javascript:fx_click_parent_object_id_link(101,'' + cast(counterparty_credit_info_id as varchar(500))+ '')^_self'' counterparty_credit_info_id, MAX(counterparty_id) counterparty_id, MAX(counterparty_name) counterparty_name, MAX(counterparty_desc) counterparty_desc
      FROM ' + @process_table + ' temp 
	  GROUP BY counterparty_credit_info_id
		')
END
ELSE IF @flag = 'q'
BEGIN
	EXEC('SELECT MIN(sno) sno, cast(incident_log_id as varchar(500)) + ''^javascript:fx_click_parent_object_id_link(102,'' + cast(incident_log_id as varchar(500))+ '')^_self'' incident_log_id, MAX(incident_type) incident_type, MAX(incident_description) incident_description, MAX(incident_status) incident_status
      FROM ' + @process_table + ' temp 
	  GROUP BY incident_log_id
		')
END
ELSE IF @flag = 'y' -- for contract search
BEGIN
	EXEC('SELECT sno, cast(contract_id as varchar(500)) + ''^javascript:fx_click_parent_object_id_link(40,'' + cast(contract_id as varchar(500))+ '')^_self'' contract_id,contract_name,contract_desc,name,company,address,address2
      FROM ' + @process_table + ' temp 
		')
END
IF @flag = 'g' --get contract type
BEGIN 
	SELECT CASE WHEN contract_type_def_id = 38401 THEN 10211300
				WHEN contract_type_def_id = 38402 THEN 10211400
				ELSE 10211200 END function_id, @filter_text id, contract_name
	FROM contract_group
	WHERE contract_id = @filter_text
END

IF @flag = 'j' --get contract type
BEGIN 
	SELECT CASE WHEN hierarchy_level = 2 AND @filter_text = 1 THEN 'Company'
				WHEN hierarchy_level = 2 AND @filter_text <> 1 THEN 'Subsidiary'
				WHEN hierarchy_level = 1 THEN 'Strategy'
				ELSE 'Book' END function_id, @filter_text id, entity_name
	FROM portfolio_hierarchy 
	WHERE entity_id = @filter_text
END
/*******************************************2nd Paging Batch START**********************************************/
	IF @is_batch = 1
	BEGIN
	   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@sql_paging)

	   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_search_engine', 'Search Result')
	   EXEC(@sql_paging)  

	   RETURN
	END

	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END
/*******************************************2nd Paging Batch END**********************************************/	
GO


