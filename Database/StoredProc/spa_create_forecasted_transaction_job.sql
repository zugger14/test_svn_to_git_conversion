IF OBJECT_ID('spa_create_forecasted_transaction_job','p') is not null
	DROP PROCEDURE spa_create_forecasted_transaction_job
GO 

/**
This procedure creates forecasted transactions. 
	Parameters: 
	@gen_flag  					:  The default value 'u' means create transactions only for the the logged on user
	 								'a' the default value  means for all users. l='u' with limit check applied.
	@outstanding_minutes  		:  30 which means also create transactions that have not been
								  created within last 30 minutes (i..e, gen groups that have
								  not been processed yet)
	@job_name  					: Job name
	@user_login_id				: User name
	@as_of_date 				: Date to run 
	@forecated_tran 			: values supplied for another SP ..TDB 
	@call_from 					: Call from
	@relation_hedge_group_ids  	: Hedge relation Ids
	@batch_process_id  			: Batch qnique identifer
	@batch_report_param			: Batch parameters 
*/

CREATE PROCEDURE [dbo].[spa_create_forecasted_transaction_job] 	
	@gen_flag VARCHAR(1) = 'u'
	, @outstanding_minutes INT = 30
	, @job_name VARCHAR(100)
	, @user_login_id VARCHAR(50)
	, @as_of_date DATETIME = NULL
	, @forecated_tran VARCHAR(1) = 'n'
	, @call_from CHAR(1) ='g'
	, @relation_hedge_group_ids VARCHAR(MAX) = NULL
	--, @is_script CHAR(1) =  'n'
	, @batch_process_id VARCHAR(50) = NULL 
	, @batch_report_param VARCHAR(1000) = NULL
	
AS

/*
declare 	@gen_flag VARCHAR(1) = 'l',
			@outstanding_minutes INT = 30,
			@job_name varchar(100)='cccc',
			@user_login_id varchar(50)='gkoju'
			,@as_of_date datetime='2013-03-01'
			,@forecated_tran varchar(1)='n' 
drop table #error_count
drop table #warning_count
--*/

DECLARE @gen_hedge_group_id INT
DECLARE @eff_test_profile_id INT
DECLARE @total_gen INT
DECLARE @process_id VARCHAR(50)
DECLARE @user_name VARCHAR(25)
DECLARE @hedge_groups VARCHAR(MAX)
DECLARE @auto_finalize_gen_trans INT
DECLARE @org_gen_flag VARCHAR(1)
DECLARE @hedge_capacity varchar(250)

EXEC spa_print '************************************start spa_create_forecasted_transaction_job'

--declare @limit_chcking int

--SELECT     @limit_chcking = var_value
--FROM         adiha_default_codes_values
--WHERE     (default_code_id = 86) AND (seq_no = 1) AND (instance_no = '1')		 

SET @job_name = ISNULL(@job_name, 'ftgen_' + ISNULL(@batch_process_id, dbo.FNAGetNewID()))

BEGIN TRY
	SET @org_gen_flag = @gen_flag

	IF @org_gen_flag = 'l'
	BEGIN
		SET @gen_flag='u'
		SET @process_id = @job_name
	END
	ELSE 
	BEGIN
		SET @process_id = REPLACE(NEWID(), '-', '_')

		IF OBJECT_ID('tempdb..#hedge_capacity') is not null
			DROP TABLE #hedge_capacity
		/*
		CREATE TABLE #hedge_capacity(
			fas_sub_id INT,
			fas_str_id INT,
			fas_book_id INT,
			curve_id INT,
			fas_sub VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
			fas_str VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
			fas_book VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
			IndexName VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
			TenorBucket VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
			TenorStart DATETIME,
			TenorEnd DATETIME,
			vol_frequency VARCHAR(50) COLLATE DATABASE_DEFAULT  ,
			vol_uom VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
			net_asset_vol NUMERIC(38,20),
			net_item_vol NUMERIC(38,20),
			net_available_vol NUMERIC(38,20),
			over_hedge VARCHAR(3) COLLATE DATABASE_DEFAULT  
			,net_vol NUMERIC(26,10)
		)


		EXEC spa_print '*************************************************'
		EXEC spa_print 'start call spa_Create_Available_Hedge_Capacity_Exception_Report'
		EXEC spa_print '*************************************************'
		*/
	END
 

	--SET @user_name = dbo.FNADBUser()
	SET @user_name = @user_login_id

	SET @total_gen = 0

	IF @gen_flag IS NULL 
		SET @gen_flag = 'u'

	IF @outstanding_minutes IS NULL 
		SET @outstanding_minutes = 30

	--If @auto_finalize_gen_trans = 1 then auto  finalize
	SELECT @auto_finalize_gen_trans = var_value
	FROM adiha_default_codes_values
	WHERE (default_code_id = 18) AND (seq_no = 1) AND (instance_no = '1')		 

	DECLARE @sql VARCHAR(MAX)
	--This select statement reutrns all the gen groups that require processing...
	CREATE TABLE #all_req_gen_groups(gen_hedge_group_id INT, eff_test_profile_id INT)
	SET @sql = 'INSERT INTO #all_req_gen_groups
				SELECT  ghg.gen_hedge_group_id,	
					ghg.eff_test_profile_id	
				FROM gen_hedge_group ghg
				LEFT OUTER JOIN gen_fas_link_header ON ghg.gen_hedge_group_id = gen_fas_link_header.gen_hedge_group_id '
			
	IF @relation_hedge_group_ids IS NOT NULL 
		SET @sql = @sql + ' INNER JOIN dbo.FNASplit(''' + @relation_hedge_group_ids + ''', '','') a ON a.item = ghg.gen_hedge_group_id'
			
	SET @sql = @sql + '
				WHERE  1 = 1 
				AND gen_fas_link_header.gen_link_id IS NULL 
				AND (ghg.create_user = CASE ''' + @gen_flag + ''' WHEN ''a'' THEN ghg.create_user ELSE ''' + @user_name + ''' END 
					OR ghg.create_ts <= CASE ''' + @gen_flag + ''' WHEN ''u'' THEN DATEADD(mi, -1 * ' + CAST(@outstanding_minutes AS VARCHAR(100)) + ',  CURRENT_TIMESTAMP) ELSE ghg.create_ts END) '

	EXEC spa_print @sql 
	EXEC(@sql)

	--select * from #all_req_gen_groups
	--return 

	DECLARE gen_groups CURSOR FOR
	SELECT gen_hedge_group_id, eff_test_profile_id
	FROM #all_req_gen_groups
	ORDER BY gen_hedge_group_id	
	OPEN gen_groups
	SET @hedge_groups = ''
	FETCH NEXT FROM gen_groups
	INTO @gen_hedge_group_id, @eff_test_profile_id
	WHILE @@FETCH_STATUS = 0   -- book
	BEGIN 
		--Select 'Group ID: ' + cast (@gen_hedge_group_id as varchar) + ' ==> Rel ID: ' + isnull(cast (@eff_test_profile_id as varchar), 'NULL')
		SET @total_gen = @total_gen + 1
		IF @total_gen > 1 SET @hedge_groups = @hedge_groups + ','
			SET @hedge_groups = @hedge_groups + CAST(@gen_hedge_group_id AS VARCHAR)
			
		EXEC spa_print 'Generate hedged items'
		--select @gen_hedge_group_id, @eff_test_profile_id, @user_login_id,@process_id, @is_script
		EXEC spa_gen_transaction @gen_hedge_group_id, @eff_test_profile_id, @user_login_id,@process_id
		--, @is_script

		FETCH NEXT FROM gen_groups
		INTO @gen_hedge_group_id, @eff_test_profile_id	
	END -- end book
	CLOSE gen_groups
	DEALLOCATE  gen_groups

	--if @org_gen_flag='l'
	--begin
	--if isnull(@limit_chcking,0)=1
	--begin
		EXEC spa_print '*************************************************'
		EXEC spa_print 'start call spa_auto_matching_limit_validation'
		EXEC spa_print '*************************************************'
		--select  @as_of_date ,@user_login_id,@process_id,'y'
		EXEC dbo.spa_auto_matching_limit_validation @as_of_date, @user_login_id, @process_id, @forecated_tran, @call_from

		EXEC spa_print '*************************************************'
		EXEC spa_print 'end call spa_auto_matching_limit_validation'
		EXEC spa_print '*************************************************'
	--end
	--Auto-finalize

	If @auto_finalize_gen_trans = 1 
	BEGIN
		EXEC spa_print '*************************************************'
		EXEC spa_print 'start call spa_finalize_approved_transactions_job'
		EXEC spa_print '*************************************************'
		DECLARE @hedge_groups_tmp varchar(250)
		SET @hedge_groups_tmp = NULLIF(@hedge_groups, '')
		EXEC spa_finalize_approved_transactions_job 'u', 30, @job_name, @user_login_id,	@process_id, @hedge_groups_tmp
		EXEC spa_print '*************************************************'
		EXEC spa_print 'end call spa_finalize_approved_transactions_job'
		EXEC spa_print '*************************************************'
	END

	--IF @@ERROR = 0
	--BEGIN
	DECLARE @desc varchar(MAX)
	DECLARE @url_path varchar(MAX)
	SELECT @total_gen=count(1) from gen_transaction_status s
	--cross apply dbo.SplitCommaSeperatedValues(@hedge_groups) h
	WHERE process_id=@process_id --  s.gen_hedge_group_id=h.Item  
		AND error_code IN ('Success','Warning')
		
	SET @url_path = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=EXEC spa_get_transaction_gen_status ''' + @hedge_groups + ''',''y'''
	SET @desc = 'Forecasted transactions automation process completed: ' + CAST(ISNULL(@total_gen,0) AS VARCHAR) + ' gen group(s) processed. Please go to View Outstanding Automation Results to verify and approve the generated transactions.'

	SET @desc = '<a target="_blank" href="' + @url_path + '">' + @desc + '</a>'
 
	CREATE TABLE #error_count(total_errors INT)
	CREATE TABLE #warning_count(total_warnings INT)

	IF @hedge_groups <> ''
	BEGIN
		EXEC('INSERT INTO #error_count SELECT COUNT(*) AS total_errors FROM  gen_transaction_status
			WHERE error_code = ''Error'' AND gen_hedge_group_id IN (' + @hedge_groups + ')')
	
		EXEC('INSERT INTO #warning_count SELECT COUNT(*) AS total_warnings FROM  gen_transaction_status
			WHERE error_code = ''Warning'' AND gen_hedge_group_id IN (' + @hedge_groups + ')')
	END	

	DECLARE @status_code varchar(1)
	SET @status_code = 's'

	IF (SELECT COUNT(1) FROM  #error_count) > 0 OR ISNULL(@total_gen, 0) = 0
		SET @status_code = 'e'

	IF (SELECT COUNT(1) FROM  #warning_count) > 0 
		SET @status_code = 'w'

	EXEC  spa_message_board 'i', @user_name,
			NULL, 'Automation',
			@desc, 
			'', '', @status_code, @job_name, NULL,@process_id
--END
END TRY
BEGIN CATCH
	--EXEC spa_print 'Error Found in Catch: ' + ERROR_MESSAGE()
	--select error_message()
	IF @@TRANCOUNT>0
		ROLLBACK
		
	DECLARE @desc1 VARCHAR(MAX)
	DECLARE @url_path1 VARCHAR(MAX)
	
	SET @url_path1 = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_transaction_gen_status '
					+ dbo.fnasinglequote(@hedge_groups)

	SET @desc1 = 'Forecasted transactions automation failed: ' + CAST(@total_gen as varchar) + ' gen group(s) processed. Error found: ' + ERROR_MESSAGE()

	SET @desc1 = '<a target="_blank" href="' + @url_path1 + '">' + @desc1 + '</a>'

	EXEC  spa_message_board 'i', @user_name, NULL , 'Forecasted Transactions' , @desc1 ,'', '', 'e', @job_name
END CATCH

GO


