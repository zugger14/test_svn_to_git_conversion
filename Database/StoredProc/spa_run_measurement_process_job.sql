IF OBJECT_ID(N'spa_run_measurement_process_job', N'P') IS NOT NULL
	DROP PROCEDURE spa_run_measurement_process_job
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**

This procedure runs the measurement process. The first call should pass process_id as NULL
The second call will have process_id as not null since the first one will return the process_id
If assessment_date is null it is understood that the procedures is to use the most recent 

	Parameters: 
	@sub_entity_id 			: Subsidiary Entity IDs
	@strategy_entity_id  	: Strategy Entity IDs
	@book_entity_id  		: Book Entity IDs
	@as_of_date  			: Date to Run
	@assessment_date 		: Assessment Run Date
	@process_id  			: Unique identifier
	@job_name  				: JobName
	@user_login_id  		: Username
	@print_diagnostic  		: Print statement for debug mode
	@what_if 				: TBD
	@link_filter_id   		: Links ids 
	@production_month_from  : Production month from 
	@production_month_to  	: Production month to
	@delete_prior_values  	: Delete previous values flag
	@eff_pnl_all 			: TBD
	@batch_process_id  		: Batch Unique identifier
	@batch_report_param		: Batch paramaters
*/

CREATE PROCEDURE [dbo].[spa_run_measurement_process_job] 
	@sub_entity_id VARCHAR(MAX) = NULL,
	@strategy_entity_id VARCHAR(MAX) = NULL,
	@book_entity_id VARCHAR(MAX) = NULL,
	@as_of_date VARCHAR(20),
	@assessment_date VARCHAR(20) = NULL,
	@process_id VARCHAR(100) = NULL,
	@job_name VARCHAR(100),
	@user_login_id VARCHAR(50),
	@print_diagnostic INT = 0,
	@what_if CHAR(1) = 'n',
	@link_filter_id  VARCHAR(5000) = NULL,
	@production_month_from VARCHAR(20) = NULL,
	@production_month_to VARCHAR(20) = NULL,
	@delete_prior_values VARCHAR(1) = 'n',
	@eff_pnl_all VARCHAR(1) = 'n',
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(1000) = NULL
	
AS
SET NOCOUNT ON

--DECLARE @dedesignation_calc char(1)
DECLARE @discountTableName VARCHAR(100)
DECLARE @closed_book_count INT
DECLARE @total_status INT
DECLARE @step VARCHAR(5)
DECLARE @type CHAR(1)
DECLARE @deleteStmt VARCHAR(500)
DECLARE @url VARCHAR(500)
DECLARE @urlP VARCHAR(500)
DECLARE @url_desc VARCHAR(8000)
DECLARE @user_name VARCHAR(25)
DECLARE @desc VARCHAR(8000)
DECLARE @inventory_accounting INT -- greater than 0 means Yes
DECLARE @hedge_accounting INT -- greater than 0 means Yes
DECLARE @print_times INT
DECLARE @begin_time DATETIME

BEGIN TRY
	SET @begin_time = GETDATE()
	SET @print_times = 0 -- 0 means no print 1 means print time to track performance
	SET @inventory_accounting = 0
	SET @hedge_accounting = 0

	--If process_id is passed null create one
	IF @process_id IS NULL
	BEGIN
		SET @process_id = REPLACE(newid(),'-','_')
		SET @job_name = 'mes_' + ISNULL(@batch_process_id,@process_id)
	END
	--conver to sql std date

	SET @as_of_date = dbo.FNAGetSQLStandardDate(@as_of_date)

	IF @what_if IS NULL
		SET @what_if = 'n'
	IF @sub_entity_id = ''
		SET @sub_entity_id = NULL
	IF @strategy_entity_id = ''
		SET @strategy_entity_id  = NULL
	IF @book_entity_id = ''
		SET @book_entity_id = NULL
	IF @assessment_date = ''
		SET @assessment_date = NULL
	IF @production_month_from = ''
		SET @production_month_from = NULL
	IF @production_month_to = ''
		SET @production_month_to = NULL
	IF @delete_prior_values = '' OR @delete_prior_values IS NULL
		SET @delete_prior_values = 'n'

	--====Grab accounting types -----------------
	DECLARE @sql_stmt VARCHAR(8000)
	--drop table #accounting_types

	IF @print_times = 1  
		EXEC spa_print '1*****beginning of sp:' --+ dbo.FNAGetSQLStandardDateTime(getdate())

	CREATE TABLE #accounting_types (hedge_type_value_id INT)

	SET @sql_stmt = 'INSERT INTO #accounting_types
					SELECT DISTINCT hedge_type_value_id
					FROM portfolio_hierarchy book 
					INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
					INNER JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id 
					INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
					where book.entity_id IN(' + ISNULL(@book_entity_id, 'book.entity_id') + ') AND
						stra.entity_id IN(' + ISNULL(@strategy_entity_id, 'stra.entity_id') + ') AND
						sub.entity_id IN(' + ISNULL(@sub_entity_id, 'sub.entity_id') + ')'

	EXEC spa_print @sql_stmt
	EXEC (@sql_stmt)
  
	SELECT @inventory_accounting = ISNULL(COUNT(*), 0) FROM #accounting_types WHERE hedge_type_value_id = 154
	SELECT @hedge_accounting = ISNULL(COUNT(*), 0) FROM #accounting_types WHERE hedge_type_value_id <> 154

	----====Grab accounting types -----------------
	--SET @user_name = dbo.FNADBUser()
	SET @user_name = @user_login_id
	SET @url_desc = ''
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
				'&spa=exec spa_get_run_measurement_process_status ''' + @process_id + ''''
	SET @desc = '<a target="_blank" href="' + @url + '">' + 
				'Error(s) encountered while running Measurement process for as of ' + @as_of_date + '</a>'
	--'"<a target='_blank' href=\"' + @url + '\">Detail...</a>"'

	--select * from close_measurement_books
	--SELECT     @closed_book_count  = COUNT(*) 
	--FROM         close_measurement_books
	--WHERE     (as_of_date >= CONVERT(DATETIME, @as_of_date, 102))

	CREATE TABLE #close_books (as_of_date DATETIME, archive_type_id INT)

	SET @sql_stmt = 'INSERT INTO #close_books
					 SELECT as_of_date, archive_type_id
					 FROM close_measurement_books
					 WHERE (as_of_date >= dbo.FNAGetContractMonth(''' + @as_of_date + '''))'

	EXEC(@sql_stmt)

	SELECT @closed_book_count  = COUNT(*) 
	FROM #close_books

	--It always starts with step 0 for real  measuremnet. For whatif we ignore dedesignation calc logic
	SET @step = '2'

	-- Check if book is already closed
	If @what_if = 'n' AND @closed_book_count > 0 
	BEGIN
		INSERT INTO measurement_process_status(status_code, status_description, run_as_of_date, assessment_values, 
					assessment_date, subsidiary_entity_id, strategy_entity_id, book_entity_id, 
                    can_proceed, process_id, create_user)
		VALUES('Error', 'Accounting Period already closed for run as of date ' + @as_of_date, 
				@as_of_date, '', @assessment_date, @sub_entity_id, 
                @strategy_entity_id, @book_entity_id, 'n', @process_id, @user_login_id)

		IF @what_if = 'n' AND @link_filter_id IS NULL
			EXEC  spa_message_board 'i', @user_name, NULL, 'Measurement', @desc, @url_desc, '', 'e', @job_name

		RETURN
	END

	--------------===================Calculate Inventory Accounting Entries==================
	-- EXEC spa_print 'production month from:' + @production_month_from
	-- EXEC spa_print 'production month to:' + @production_month_to

	IF @print_times = 1  
	BEGIN
		EXEC spa_print @inventory_accounting
		EXEC spa_print '2*****beginning of calc inventory sp:' --+ dbo.FNAGetSQLStandardDateTime(getdate())
	END

	IF @inventory_accounting > 0 AND @link_filter_id IS NULL
		EXEC spa_calc_inventory_accounting_entries 	@sub_entity_id, @strategy_entity_id, @book_entity_id,
			NULL, @link_filter_id, @as_of_date, @process_id, @job_name, @user_login_id, NULL, 
			@production_month_from, @production_month_to

	IF @hedge_accounting < 1
		RETURN

	-- if y delete all prior values to fresh start
	IF @delete_prior_values = 'y'
	BEGIN
		EXEC spa_purge_all_measurement_values @as_of_date, @sub_entity_id
		--	EXEC spa_print 'All prior values purged for given as of date.'
	END
  
	--------------===================Calculate Hedge and MTM Accounting Entries==================
	IF @print_times = 1  
		EXEC spa_print '3*****Before Creating discount factor table:' --+ dbo.FNAGetSQLStandardDateTime(getdate())

	SET @discountTableName = dbo.FNAProcessTableName('calcprocess_discount_factor', @user_login_id, @process_id)
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@discountTableName)

	--Collect discount rates and calculate discount factors...
	EXEC spa_Calc_Discount_Factor @as_of_date, null, null, null, @discountTableName

	IF @print_times = 1  
		EXEC spa_print '3*****After creating discount factor table:' --+ dbo.FNAGetSQLStandardDateTime(getdate())
	 
	IF @step = '2'
	BEGIN
  		EXEC spa_Collect_Link_Deals_PNL_OffSetting_Links @as_of_date, @assessment_date, @sub_entity_id, 
				@strategy_entity_id, @book_entity_id, @process_id, 'm', @print_diagnostic, 
				@user_login_id, @what_if, @link_filter_id, NULL, @eff_pnl_all, @production_month_from, @production_month_to 

		/*
		EXEC spa_print 'EXEC spa_Collect_Link_Deals_PNL_OffSetting_Links '
		EXEC spa_print @as_of_date
		EXEC spa_print @assessment_date
		EXEC spa_print @sub_entity_id
		EXEC spa_print @strategy_entity_id
		EXEC spa_print @book_entity_id
		EXEC spa_print @process_id
		EXEC spa_print 'm'
		EXEC spa_print @print_diagnostic
		EXEC spa_print @user_login_id
		EXEC spa_print @what_if
		EXEC spa_print @link_filter_id
		-*/

		--check if any error/warning received
		SELECT     @total_status  = COUNT(*) 
		FROM         measurement_process_status
		WHERE     (process_id = @process_id and calc_type = 'm' and can_proceed = 'n')
	--	WHERE     (process_id = @process_id and calc_type = 'm')
	
		IF @total_status > 0 
		BEGIN
			EXEC (@deleteStmt)

			IF @what_if = 'n'
				EXEC  spa_message_board 'i', @user_name,
					NULL, 'Measurement',
					@desc, @url_desc, '', 'e', @job_name
			RETURN
		END
		ELSE
			SET @step = '3'
	END		

	IF @print_times = 1  
		EXEC spa_print '4*****after collect deals for de-designation:' --+ dbo.FNAGetSQLStandardDateTime(getdate())

	--print 'STEP 2 COMPLETED.'
	IF @step = '3'
	BEGIN
		EXEC spa_Calculate_Accrual_Entries @process_id, 'm' , @as_of_date, @print_diagnostic, 
			@user_login_id, @what_if, @link_filter_id

		SELECT @total_status  = COUNT(*) 
		FROM measurement_process_status_completed
		WHERE (process_id = @process_id and calc_type = 'm' and code = 'Success')
	 
		SET @type = 's'	

	-- 	EXEC spa_print 'link id == ' + cast(@link_filter_id  as varchar)
	-- 	EXEC spa_print 'what if == ' + @what_if 
	-- 	EXEC spa_print 'Total status == ' + cast(@total_status as varchar)

		IF @total_status > 0 
		BEGIN
			--Run netting logic
			IF @link_filter_id IS NULL AND @what_if = 'n'
			BEGIN
				EXEC spa_Calc_Netting_Measurement @process_id, @sub_entity_id, @as_of_date, @print_diagnostic, @user_login_id
				--PRINT 'After calling calc netting logic...'
			END
		END
		ELSE
			SET @type = 'e'

		--Delete the discount table 
		EXEC (@deleteStmt)

 		SELECT @total_status  = COUNT(*) 
		FROM measurement_process_status
		WHERE (process_id = @process_id and can_proceed = 'y')

		IF (SELECT COUNT(*) FROM measurement_process_status
			WHERE process_id = @process_id AND can_proceed = 'n' AND subsidiary_entity_id = -100) > 0
			SET @type = 'e'

		DECLARE @e_time INT
		DECLARE @e_time_text VARCHAR(100)

		SET @e_time = DATEDIFF(ss, @begin_time, GETDATE())
		SET @e_time_text = CAST(CAST(@e_time/60 AS INT) AS VARCHAR) + ' Mins ' + CAST(@e_time - CAST(@e_time/60 AS INT) * 60 AS VARCHAR) + ' Secs'

		IF @total_status > 0
			SET @desc = '<a target="_blank" href="' + @url + '">' + 
				'Measurement process ran with WARNINGS as of ' + dbo.FNADateFormat(@as_of_date) + 
				'. Please review the warnings. ' + '(Elapse time: ' + @e_time_text + ')'	+ '</a>' 
		Else
			SET @desc = '<a target="_blank" href="' + @url + '">' + 
				'Measurement process ran without errors as of ' + dbo.FNADateFormat(@as_of_date) + 
				'. (Elapse time: ' + @e_time_text +  ')'	+ '.</a> '

		SET @urlP = './dev/spa_perform_process.php?as_of_date=' + @as_of_date + 					'&process_id=68&process_attachment=Run Measurement Process ran on ' +
					dbo.FNAUserDateTimeFormat(getdate(), 1, @user_login_id) +
					'&spa=exec spa_get_run_measurement_process_status ''' + @process_id + '''' +
					'&__user_name__=' + @user_login_id

		DECLARE @url_m_report VARCHAR(1000)
		SET @url_m_report = './dev/spa_html.php?spa= EXEC spa_Create_Hedges_Measurement_Report 	''' + 	@as_of_date + ''', ' + 
							CASE WHEN (@sub_entity_id IS NULL) THEN 'NULL, ' ELSE + '''' +  @sub_entity_id + ''',' END +
							CASE WHEN (@strategy_entity_id IS NULL) THEN 'NULL, ' ELSE + '''' +  @strategy_entity_id + ''',' END +
							CASE WHEN (@book_entity_id IS NULL) THEN 'NULL, ' ELSE + '''' +  @book_entity_id + ''',' END +
							'''d'', ''a'', ''c'', ''l'', null, ''2''' +
							'&__user_name__=' + @user_login_id

		IF (SELECT COUNT(1) FROM #accounting_types) = 1 AND -- ONLY if cash flow hedges
			(SELECT MIN(hedge_type_value_id) from 	#accounting_types) = 150
			SET @url_desc = '<a target="_blank" href="' + @url_m_report + '">' + 'Run Measurement Report...' + '</a> ' 
		ELSE
			SET @url_desc = ''
		--	SET @desc = 'Measurement process ran without errors as of ' + @as_of_date

		DECLARE @mode VARCHAR(1)
		SET @mode = 'i'

		IF (SELECT COUNT(1) FROM message_board WHERE job_name = @job_name) > 0
			SET @mode = 'u'

		IF @what_if = 'n' --AND @link_filter_id IS NULL 
	--		EXEC  spa_message_board 'i', @user_name,
			EXEC  spa_message_board @mode, @user_name, NULL, 'Measurement', @desc, @url_desc, '', @type, @job_name

	--print 'STEP 3 COMPLETED.'
	IF @print_times = 1  
		EXEC spa_print '5*****after calc all:' --+ dbo.FNAGetSQLStandardDateTime(getdate())
		RETURN
	END
END TRY
BEGIN CATCH
	EXEC spa_print 'Error Found in Catch: ' 
	--select ERROR_MESSAGE()
	
	INSERT INTO measurement_process_status
	SELECT 	'Error' as status_code, 
		'SQL Error found: '''  + dbo.FNADateFormat(@as_of_date) + ''' (' + ERROR_MESSAGE() + ')' as status_description, 
		@as_of_date as run_as_of_date,
		'' as assessment_values, 
		NULL assessment_date, 
		NULL sub_entity_id, 
		NULL strategy_entity_id, 
		NULL book_entity_id,
		'n' as can_proceed, 
		@process_id,
		'm', 
		NULL as create_user, NULL as create_ts

		EXEC  spa_message_board 'i', @user_name, NULL, 'Measurement',  @desc, '', '', 'e', @job_name
END CATCH
GO