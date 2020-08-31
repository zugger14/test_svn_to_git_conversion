IF OBJECT_ID('spa_finalize_approved_transactions_job') IS NOT NULL
	DROP PROCEDURE spa_finalize_approved_transactions_job
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
This SP arpproves and finalize the gen links creating creating FAS links.
	Parameters: 
	@gen_flag 			  : The default value 'u' means create transactions only for the the logged on user
						    'a' the default value  means for all users
	@outstanding_minutes  :  30 which means also create transactions that have not been
							 created within last 30 minutes (i..e, transactions that have
							 not been processed yet)
	@user_login_id 		  : User name
	@gen_group_id  		  : Gen hedge group id
	@process_id			  :	Unqiue identifier
	@job_name		      : Job Name
*/

CREATE PROCEDURE [dbo].[spa_finalize_approved_transactions_job]
	@gen_flag VARCHAR(1) = 'u',
	@outstanding_minutes INT = 30,
	@job_name VARCHAR(100),
	@user_login_id VARCHAR(50),
	@process_id VARCHAR(50) = NULL,
	@gen_group_id VARCHAR(MAX) = NULL	
											
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON

/*
DECLARE 
	@gen_flag VARCHAR(1) ,
	@outstanding_minutes INT ,
	@job_name VARCHAR(100),
	@user_login_id VARCHAR(50),
	@process_id VARCHAR(50),
	@gen_group_id VARCHAR(max) 
select 
	@gen_flag = 'u',
	@outstanding_minutes  = 30,
	@job_name='aa' ,
	@user_login_id ='gkoju',
	@process_id ='aaaa',
	@gen_group_id  = '263382'
								
drop table #create_gen_link_header
drop table #create_risk_deal_header
drop table #create_risk_deal_detail
drop table #create_gen_link_detail
drop table #finalize_status
								

--*/

IF OBJECT_ID('tempdb..#finalize_status') IS NOT NULL
	DROP TABLE #finalize_status

IF OBJECT_ID('tempdb..#hedge_deal_value_populate') IS NOT NULL
	DROP TABLE #hedge_deal_value_populate	

DECLARE @url1 VARCHAR(250)
DECLARE @desc1 VARCHAR(500)
DECLARE @user_name VARCHAR(25)

SET @desc1 = ''
SET @url1 = ''
DECLARE @desc VARCHAR(500)
SET @desc = ''
SET @user_name = @user_login_id

BEGIN TRY	
	DECLARE @items_xfer_to_source_system INT
	DECLARE @current_date VARCHAR(20)

	SET @current_date = dbo.FNADateFormat(GETDATE())
	SET @user_name = @user_login_id

	IF @gen_flag IS NULL 
		SET @gen_flag = 'u'

	IF @outstanding_minutes IS NULL 
		SET @outstanding_minutes = 30

	SELECT @items_xfer_to_source_system = var_value
	FROM adiha_default_codes_values
	WHERE (default_code_id = 12) AND (seq_no = 1) AND (instance_no = '1')
	--Make sure use BEGIN TRANSACTION/COMMIT/ROLLBACK LOGIC--------------

	-------------------Step 1 ------------------------------------------------------------
	--Create entries in fas_link_header --> All rows in #create_gen_link_header should be created
	SELECT DISTINCT gen_hedge_group.reprice_items_id, 
			gen_fas_link_header.gen_link_id,
			gen_fas_link_header.gen_hedge_group_id,
			gen_fas_link_header.gen_approved,
			gen_fas_link_header.used_ass_profile_id,
			gen_fas_link_header.fas_book_id,
			gen_fas_link_header.perfect_hedge,
			gen_fas_link_header.link_description,
			gen_hedge_group.eff_test_profile_id,
			gen_fas_link_header.link_effective_date,
			gen_fas_link_header.link_type_value_id,
			gen_fas_link_header.link_id,
			gen_fas_link_header.gen_status,
			gen_deal_header.process_id,
			gen_fas_link_header.create_user,
			gen_fas_link_header.create_ts,
			gen_fas_link_header.approved_process_id,
			ISNULL(gen_hedge_group.tran_type, 'f') tran_type,   -- this line is added by Gyan
			gen_fas_link_detail.deal_number gen_deal_header_id
		INTO #create_gen_link_header
	FROM gen_fas_link_header 
	INNER JOIN gen_hedge_group ON gen_hedge_group.gen_hedge_group_id = gen_fas_link_header.gen_hedge_group_id
	INNER JOIN gen_fas_link_detail on gen_fas_link_detail.gen_link_id = gen_fas_link_header.gen_link_id 
		and gen_fas_link_detail.hedge_or_item = CASE WHEN ISNULL(gen_fas_link_header.perfect_hedge,'n') = 'y' then 'h' else 'i' end
	LEFT JOIN gen_deal_header on gen_deal_header.gen_deal_header_id = gen_fas_link_detail.deal_number
	WHERE 1 = 1 AND
		gen_hedge_group.gen_hedge_group_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@gen_group_id)) AND
		gen_approved = 'y' AND gen_fas_link_header.gen_status='a' AND
		(@gen_group_id IS NOT NULL OR 
		gen_fas_link_header.create_user = CASE @gen_flag WHEN 'a' 
			THEN gen_fas_link_header.create_user ELSE @user_name END OR
		gen_fas_link_header.create_ts <= CASE @gen_flag WHEN 'u' 
			THEN dateadd(mi, -1 * @outstanding_minutes,  CURRENT_TIMESTAMP) ELSE gen_fas_link_header.create_ts END)

	--select *  from #create_gen_link_header
	--return 

	-------------------Step 2 ------------------------------------------------------------
	--Create Deal headers - The data in #risk_deal_header should be moved to the source system
	SELECT	gen_deal_header.*,CAST(NULL AS VARCHAR(250)) description4
		INTO 	#create_risk_deal_header
	FROM gen_deal_header INNER JOIN #create_gen_link_header
	ON	gen_deal_header.gen_deal_header_id = #create_gen_link_header.gen_deal_header_id

	-------------------Step 3 ------------------------------------------------------------
	--Create Deal details - The data in #risk_deal_detail should be moved to the source system
	SELECT	gen_deal_detail.*, #create_risk_deal_header.gen_hedge_group_id
	INTO 	#create_risk_deal_detail
	FROM	gen_deal_detail INNER JOIN #create_risk_deal_header
	ON	gen_deal_detail.gen_deal_header_id = #create_risk_deal_header.gen_deal_header_id

	-------------------Step 4 ------------------------------------------------------------
	--------------------------------------------------------------------------------------
	--Create entries in fas_link_detail --> All rows in #create_gen_link_header should be created
	SELECT	gen_fas_link_detail.*, #create_gen_link_header.gen_hedge_group_id
	INTO #create_gen_link_detail
	FROM gen_fas_link_detail 
	INNER JOIN #create_gen_link_header ON gen_fas_link_detail.gen_link_id = #create_gen_link_header.gen_link_id

	/*
	-- select * from #create_gen_link_header
	 select * from #create_risk_deal_header
	 select * from #create_risk_deal_detail
	-- select * from #create_gen_link_detail
	return
	--*/
	CREATE TABLE #finalize_status
		(
		process_id VARCHAR(100) COLLATE DATABASE_DEFAULT   ,
		ErrorCode VARCHAR(50) COLLATE DATABASE_DEFAULT  ,
		Module VARCHAR(50) COLLATE DATABASE_DEFAULT  ,
		[Source] VARCHAR(50) COLLATE DATABASE_DEFAULT  ,
		[type] VARCHAR(50) COLLATE DATABASE_DEFAULT  ,
		[description] VARCHAR(1000) COLLATE DATABASE_DEFAULT  ,
		[nextstep] VARCHAR(250) COLLATE DATABASE_DEFAULT  	
		)

	IF NOT EXISTS (SELECT 1 FROM #create_gen_link_header)
	BEGIN
		SET @desc = 'No Gen Link Header found for processing Finalize Approved Transaction. '
		INSERT INTO #finalize_status VALUES(@process_id,'Error','Finalize Approved Transaction','Finalize Approved','Data Error',@desc,'')
		GOTO FinalStep_1
		RETURN
	END 

	DECLARE @alert_process_table VARCHAR(300), @sql VARCHAR(MAX)
	SET @alert_process_table = 'adiha_process.dbo.alert_measurement_' + @process_id + '_am'

	EXEC ('
	IF OBJECT_ID('''  + @alert_process_table + ''') IS NOT NULL
		DROP TABLE '  + @alert_process_table + '

	CREATE TABLE ' + @alert_process_table + ' (
		fas_book_id INT,
		link_id INT
	)')
  
	DECLARE @reprice_items_id INT, @gen_link_id AS INT, @gen_hedge_Group_id AS INT, @perfect_hedge VARCHAR(1), @tran_type VARCHAR(1), @link_description VARCHAR(1000)
 
	DECLARE link_header_cursor CURSOR FOR 
	SELECT DISTINCT reprice_items_id,gen_link_id,gen_hedge_Group_id, perfect_hedge,tran_type,link_description 
	FROM #create_gen_link_header --tran_type filrd is added by gyan
	OPEN link_header_cursor
	FETCH NEXT FROM link_header_cursor 
	INTO @reprice_items_id,@gen_link_id,@gen_hedge_Group_id, @perfect_hedge,@tran_type,@link_description
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC spa_print 'Testaaaa'
		BEGIN TRANSACTION

		IF @reprice_items_id IS NULL
		BEGIN
			EXEC spa_print '@reprice_items_id is null'
			DECLARE @link_id AS INT
		
			IF OBJECT_ID('tempdb..#finalized_links') IS NOT NULL
				DROP TABLE #finalized_links
			
			CREATE TABLE #finalized_links(fas_book_id INT, link_id INT)
		
			--step 1 insert 
			INSERT INTO fas_link_header (fas_book_id, perfect_hedge,fully_dedesignated,link_description,eff_test_profile_id,link_effective_date,
				link_type_value_id,
				link_active)
			OUTPUT INSERTED.fas_book_id, INSERTED.link_id 
			INTO #finalized_links
			SELECT DISTINCT fas_book_id,perfect_hedge,'n',link_description,eff_test_profile_id,
			link_effective_date,link_type_value_id,'y' 
			FROM #create_gen_link_header 
			WHERE gen_link_id = @gen_link_id

			-- alert call		
			SET @sql = 'INSERT INTO ' + @alert_process_table + ' (fas_book_id, link_id)
						SELECT fas_book_id, link_id
						FROM #finalized_links'
			EXEC(@sql)

			IF @@error <> 0
			BEGIN
 				--**ERROR**
				ROLLBACK TRAN 
				INSERT INTO #finalize_status
					SELECT @process_id,'Error','Finalize Approved Transaction','Finalize Approved','Application Error',
					'Failed to Insert Link Header','Please contact technical support'
				GOTO FinalStep
				RETURN
			END 	
			SET @link_id = SCOPE_IDENTITY()		
		END
		ELSE
		BEGIN
			SET @link_id = @reprice_items_id
		END 

		EXEC spa_print '@reprice_items_id: reprice_items_id'

		IF OBJECT_ID('tempdb..#tmp_header') IS NOT NULL 
			DROP TABLE #tmp_header

		CREATE TABLE #tmp_header (source_deal_header_id INT)
		-- Added by Gyan
		-- no need to add deals in the case of matching
		IF @tran_type<>'m' --existing logic for automation forcasted transaction
		BEGIN
		   IF @perfect_hedge = 'n' 
		   BEGIN
				--step 2 insert 
				IF NOT EXISTS (SELECT 1 FROM #create_risk_deal_header
					WHERE #create_risk_deal_header.gen_deal_header_id IN (SELECT deal_number FROM #create_gen_link_detail 
																		WHERE gen_link_id = @gen_link_id))
				BEGIN
					ROLLBACK TRAN 
					SET @desc='No Deal Detail found for processing Finalize Approved Transaction for Gen Link ID: '+ CAST(@gen_link_id as VARCHAR) +
					'. Futhur processing Terminated.'
					EXEC spa_print @DESC
					INSERT INTO #finalize_status VALUES(@process_id,'Error','Finalize Approved Transaction','Finalize Approved','Data Error',@desc,'')
					GOTO errorTran
				END
				ELSE
				BEGIN
					DECLARE @internal_deal_type_id INT,@template_id INT

					SET @internal_deal_type_id = 1
					DECLARE @hedge_source_deal_header_id INT
					--get template id of hedge
					SELECT @template_id = MAX(sdh.template_id), @hedge_source_deal_header_id = MAX(sdh.source_deal_header_id)
					FROM source_deal_header sdh 
					INNER JOIN gen_fas_link_detail gfld ON sdh.source_deal_header_id=gfld.deal_number
						AND gen_link_id=@gen_link_id 
						AND gfld.hedge_or_item='h'
				
					IF OBJECT_ID('tempdb..#hedge_deal_value_populate') IS NOT NULL 
						DROP TABLE #hedge_deal_value_populate

					CREATE TABLE #hedge_deal_value_populate(contract_id INT
															, commodity_id INT
															, fas_deal_type_value_id  INT
															, internal_desk_id INT
															, pricing_type INT
															, trader_id2 INT
															, internal_counterparty INT
															, timezone_id INT
															, confirm_status_type INT
															, term_frequency CHAR(1) COLLATE DATABASE_DEFAULT
															, block_define_id INT
															, internal_portfolio_id INT
															, broker_id INT)

					INSERT INTO #hedge_deal_value_populate(contract_id, commodity_id, fas_deal_type_value_id, internal_desk_id
															, pricing_type, trader_id2, internal_counterparty, timezone_id, confirm_status_type
															, term_frequency, block_define_id, internal_portfolio_id, broker_id)
					SELECT contract_id, commodity_id, fas_deal_type_value_id, internal_desk_id 
						, pricing_type, trader_id2, internal_counterparty, timezone_id, confirm_status_type
						, term_frequency, block_define_id, internal_portfolio_id, broker_id
					FROM source_deal_header 
					WHERE source_deal_header_id = @hedge_source_deal_header_id			 

					INSERT INTO source_deal_header (source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag,
						structured_deal_id, counterparty_id, entire_term_start, entire_term_end, 
						source_deal_type_id,deal_sub_type_type_id,option_flag,option_type,option_excercise_type,
						source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,
						description1, description2, description3, description4, deal_category_value_id, trader_id,				
						internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, deal_status
						, contract_id, commodity_id, fas_deal_type_value_id, internal_desk_id
						, pricing_type, trader_id2, internal_counterparty, timezone_id, confirm_status_type
						, term_frequency, block_define_id, internal_portfolio_id, broker_id
						)
						OUTPUT INSERTED.source_deal_header_id INTO #tmp_header(source_deal_header_id)
					SELECT source_system_id,
						deal_id,
						deal_date,
						null,physical_financial_flag, null, counterparty_id, entire_term_start, entire_term_end,
						source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type,
						source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4,
						description1, description2, description3, description4, deal_category_value_id, trader_id,
						@internal_deal_type_id, NULL,@template_id, gdd.buy_sell_flag
			--			, null,null,null,null,null
						, 5604 --New
						, aa.contract_id, aa.commodity_id, 401 fas_deal_type_value_id, aa.internal_desk_id
						, aa.pricing_type, aa.trader_id2, aa.internal_counterparty, aa.timezone_id, aa.confirm_status_type
						, aa.term_frequency, aa.block_define_id, aa.internal_portfolio_id, aa.broker_id
					FROM #create_risk_deal_header 
					CROSS APPLY #hedge_deal_value_populate aa
					INNER JOIN
						(SELECT  gen_deal_header_id gen_id,
							CASE WHEN  (MAX(fixed_float_leg) = 'f') THEN CASE WHEN (MAX(buy_sell_flag) = 'b') THEN 's' ELSE 'b' END
								 ELSE CASE WHEN (MAX(buy_sell_flag) = 'b') THEN 'b' ELSE 's' END
							END buy_sell_flag
					FROM gen_deal_detail				
					WHERE (Leg = 1)
					GROUP BY gen_deal_header_id) gdd ON gdd.gen_id = #create_risk_deal_header.gen_deal_header_id
					WHERE #create_risk_deal_header.gen_deal_header_id IN (SELECT deal_number FROM #create_gen_link_detail 
																			WHERE gen_link_id=@gen_link_id)
						AND  #create_risk_deal_header.gen_hedge_group_id = @gen_hedge_Group_id
					--rollback tran return
					IF @@error <> 0
					BEGIN
						--**ERROR**
						ROLLBACK TRANSACTION 

						INSERT INTO #finalize_status
							Select @process_id,'Error','Finalize Approved Transaction','Finalize Approved','Application Error',
							'Failed to Insert Source Deal Header  for Gen Link ID: '+ CAST(@gen_link_id as VARCHAR) ,'Please contact technical support'
						GOTO FinalStep
						RETURN
					END 	
			
					--step 3 insert		
					INSERT INTO source_deal_detail (source_deal_header_id, term_start, term_end, Leg, contract_expiration_date,
						fixed_float_leg, buy_sell_flag, curve_id, fixed_price, fixed_price_currency_id, 
						option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, 
						deal_detail_description, formula_id, price_adder, price_multiplier, physical_financial_flag)			
					SELECT sdh.source_deal_header_id,term_start, term_end, Leg, contract_expiration_date, 
						fixed_float_leg, t.buy_sell_flag, curve_id, fixed_price, fixed_price_currency_id, 
						option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, 
						block_description, deal_detail_description, null, price_adder, price_multiplier, 'f'  
					FROM #create_risk_deal_detail t 
					INNER JOIN gen_deal_header gdh ON t.gen_deal_header_id=gdh.gen_deal_header_id
					INNER JOIN source_deal_header sdh ON sdh.deal_id= gdh.deal_id
					INNER JOIN #create_gen_link_detail tl ON t.gen_deal_header_id = tl.deal_number 
						AND gen_link_id=@gen_link_id		
					WHERE t.gen_hedge_group_id = @gen_hedge_Group_id		
										
					IF @@error <> 0
					BEGIN
						ROLLBACK TRAN 
						INSERT INTO #finalize_status
							Select @process_id,'Error','Finalize Approved Transaction','Finalize Approved','Application Error',
							'Failed to Insert Source Deal Detail for Gen Link ID: '+ cast(@gen_link_id AS VARCHAR),'Please contact technical support'
						GOTO FinalStep
						RETURN
					END 	

					--step 4							
					UPDATE #create_gen_link_detail set deal_number =sdh.source_deal_header_id 
					FROM #create_gen_link_detail t INNER JOIN gen_deal_header gdh ON  t.deal_number=gdh.gen_deal_header_id
						and t.hedge_or_item='i'	and t.gen_link_id=@gen_link_id
					INNER JOIN source_deal_header sdh ON sdh.deal_id=gdh.deal_id
			
					INSERT INTO fas_link_detail (link_id, source_deal_header_id, percentage_included, hedge_or_item)
					SELECT @link_id,deal_number,percentage_included,hedge_or_item
					FROM #create_gen_link_detail WHERE gen_link_id=@gen_link_id

					IF @@error <> 0
					BEGIN
						ROLLBACK TRAN 
						INSERT INTO #finalize_status
						SELECT @process_id,'Error','Finalize Approved Transaction','Finalize Approved','Application Error',
							'Failed to Insert Link Detail  for Gen Link ID: '+ cast(@gen_link_id AS VARCHAR),'Please contact technical support'
						GOTO FinalStep
						RETURN
					END 	
				END
		   END
		   ELSE
		   BEGIN
				--For perfect hedge just need to update the fas link detail now
				INSERT INTO fas_link_detail (link_id, source_deal_header_id, percentage_included, hedge_or_item)
				SELECT @link_id,deal_number,percentage_included,hedge_or_item
				FROM #create_gen_link_detail WHERE gen_link_id=@gen_link_id
				
				IF @@error <> 0
				BEGIN
					ROLLBACK TRAN 
					INSERT INTO #finalize_status
					SELECT @process_id,'Error','Finalize Approved Transaction','Finalize Approved','Application Error',
						'Failed to Insert Link Detail  for Gen Link ID: '+ cast(@gen_link_id AS VARCHAR),'Please contact technical support'
					GOTO FinalStep
					RETURN
				END 	
			END

			IF @reprice_items_id is not null
			BEGIN
				--------Step 5 for repricing----------
				UPDATE fas_link_detail 
				SET percentage_included = 0 
				WHERE link_id = @link_id 
					AND hedge_or_item = 'i' 
					AND source_Deal_header_id  IN (SELECT source_Deal_header_id FROM gen_hedge_group_detail 
													WHERE gen_hedge_Group_id = @gen_hedge_Group_id)		
			END
		END
		ELSE -- logic for matching (added by gyan)
		BEGIN 
			EXEC spa_print 'yyyyyyyyyyyyyyyyyyyyyy'

			EXEC spa_print @gen_link_id
			INSERT INTO fas_link_detail (link_id, source_deal_header_id, percentage_included, hedge_or_item,effective_date)
			SELECT  @link_id ,[deal_number],[percentage_included],[hedge_or_item] ,effective_date
			FROM [gen_fas_link_detail] WHERE gen_link_id = @gen_link_id
		
			INSERT INTO fas_link_detail_dicing (link_id,source_deal_header_id,term_start,percentage_used,effective_date,create_user,create_ts,update_user,update_ts)
			SELECT  @link_id ,source_deal_header_id,term_start,percentage_used,effective_date,@user_login_id,GETDATE(),@user_login_id,GETDATE()
			FROM [gen_fas_link_detail_dicing] WHERE link_id = @gen_link_id
			
			EXEC spa_print 'yyyyyyyyyyyyyyyyyyyyyy'
		END

		UPDATE gen_fas_link_header SET gen_status = 'r' WHERE gen_link_id=@gen_link_id
		 -- Get the next Row.

		SET @desc = 'Finalize Approved Transaction done for Gen Link ID: '+ cast(@gen_link_id as VARCHAR) + '. New Hedging Relationship ID is ' + 
			dbo.FNATRMWinHyperlink('a', 10233700, CAST(@link_id AS VARCHAR(10)), CAST(@link_id AS VARCHAR(10)),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)
			+ ' (' + @link_description + ').'

		INSERT INTO #finalize_status VALUES(@process_id, 'Success', 'Finalize Approved Transaction', 'Finalize Approved', 'Successful', @desc, '')
		COMMIT TRANSACTION
		GOTO continueTran
	
		errorTran:

		IF @@TRANCOUNT > 0
			ROLLBACK
		SET @desc = 'Finalize Approved Transaction Fail for Gen Link ID: '+ cast(@gen_link_id AS VARCHAR)
		INSERT INTO #finalize_status VALUES(@process_id,'Error','Finalize Approved Transaction','Finalize Approved','Error',@desc,'')
	
		continueTran:	

		IF @@TRANCOUNT>0
			ROLLBACK
  		FETCH NEXT FROM link_header_cursor 
		INTO @reprice_items_id,@gen_link_id,@gen_hedge_Group_id, @perfect_hedge,@tran_type,@link_description
	END
	----------------------Step 10  log all error or succes message  ------------------------------
	IF EXISTS(SELECT 1 FROM #tmp_header)
	BEGIN
		DECLARE @spa VARCHAR(MAX)
		DECLARE @report_position VARCHAR(300)

		SELECT @report_position = dbo.FNAProcessTableName('report_position', dbo.FNADBUser(), @process_id)
						
		SET @sql  = '
			IF OBJECT_ID(''' + @report_position + ''') IS NULL
			BEGIN
				CREATE TABLE ' + @report_position + ' (source_deal_header_id INT, [action] CHAR(1))
			END'
		EXEC(@sql)

		SET @job_name = 'calc_deal_position_breakdown' + @process_id
				
		SET @spa = 'INSERT INTO ' + @report_position + '(source_deal_header_id,action) SELECT source_deal_header_id,''i'' from #tmp_header'
		EXEC spa_print @spa   
		EXEC (@spa)			

		SET @spa = 'spa_update_deal_total_volume NULL,''' + @process_id  + ''',0,1,''' + @user_login_id + ''', ''n'''
 
		--SET @spa = 'spa_update_deal_total_volume NULL,'''+@process_id+''',0,1,''' + @user_name + ''',NULL, NULL, ' + ISNULL('' + null + '', 'NULL') + '' 
		--print(@spa)
		EXEC spa_run_sp_as_job @job_name,  @spa, 'calc_deal_position', @user_name
	END	

	--end  of cursor
	FinalStep:

	IF @@TRANCOUNT>0
		ROLLBACK
	
	CLOSE link_header_cursor
	DEALLOCATE link_header_cursor
	FinalStep_1:

	IF @@TRANCOUNT>0
		ROLLBACK

	IF @process_id IS NULL 
	BEGIN
		SELECT errorcode,module,source,type,[description],nextstep FROM #finalize_status
		RETURN
	END
	ELSE
	BEGIN
		INSERT INTO finalize_approve_test_run_log(process_id,code,module,source,type,[description],nextsteps)  
		SELECT * FROM #finalize_status WHERE process_id = @process_id
		
		DECLARE @url VARCHAR(250)
		SET @url = './dev/spa_html.php?__user_name__=' + @user_name + 
			'&spa=exec spa_get_finaliza_approved_test_run_log ''' + @process_id + ''''
		
		DECLARE @error_count int
		DECLARE @type char
		
		SELECT  @error_count =   COUNT(*) 
		FROM    finalize_approve_test_run_log
		WHERE   process_id = @process_id AND type = 'Error'
		
		DECLARE @total_finalized INT
		SELECT  @total_finalized = COUNT(*) 
		FROM    finalize_approve_test_run_log
		WHERE   process_id = @process_id AND code = 'Success'
		
		DECLARE @all_finalized INT
		SELECT @all_finalized = COUNT(*) 
		FROM #create_gen_link_header
		
		IF @error_count > 0 
			SET @type = 'e'
		ELSE
			SET @type = 's'
		
		SET @desc = '<a target="_blank" href="' + @url + '">
				Finalization of automated forecasted transactions process ('+ cast(@all_finalized AS VARCHAR)+') completed: ' + 
				cast(@total_finalized AS VARCHAR) + ' gen relationship(s) finalized.'+
 				CASE WHEN (@type = 'e') THEN ' and '+ cast(@error_count as VARCHAR)+' (ERRORS found) ' ELSE '' END +
				'.</a>'	
		--		EXEC spa_print @desc
		
-- 		IF @gen_hedge_group_id IS NULL
-- 		BEGIN
		IF @type = 's'
		BEGIN
			--remove finalize message from message board				
			exec spa_compliance_workflow 4, NULL, NULL,NULL
		END
		
		EXEC  spa_message_board 'i', @user_name,
				'', 'Finalization',
				@desc, 
				'', '', @type, @job_name

		--END
		RETURN
	END
	-------------------------End of Step 10----------------------------------------
	EXEC spa_register_event 20612, 20533, @alert_process_table, 1, @process_id 
END TRY
BEGIN CATCH
	--EXEC spa_print 'Error Found in Catch: ' + ERROR_MESSAGE()
	SET @desc1=' '
	
	IF @@TRANCOUNT > 0
		ROLLBACK

	INSERT INTO #finalize_status
	SELECT @process_id,'Error','Finalize Approved Transaction','Finalize Approved','SQL Error',
	'SQL Error found while finalizing transactions: ' + ERROR_MESSAGE(),'Please contact support.'

	INSERT INTO finalize_approve_test_run_log(process_id,code,module,source,type,[description],nextsteps)  
	SELECT * FROM #finalize_status WHERE process_id=@process_id
	SET @url1 = './dev/spa_html.php?__user_name__=' + @user_name + 
			'&spa=exec spa_get_finaliza_approved_test_run_log ''' + @process_id + ''''
			
	SET @all_finalized = ISNULL(@all_finalized,0)
	SET @total_finalized = ISNULL(@total_finalized,0)
	
	SET @desc1 = '<a target="_blank" href="' + @url1 + '">
			    Finalization of automated forecasted transactions process ('+ CAST(@all_finalized AS VARCHAR)+') completed: ' + 
			    cast(@total_finalized as VARCHAR) + ' gen relationship(s) finalized. (ERRORS found).</a>'	
			    
	EXEC spa_print @all_finalized 
	EXEC spa_print @desc1
	
	EXEC  spa_message_board 'i', @user_name,
				'', 'Finalization',
				@desc1, 
				'', '', 'e', @job_name
	
END CATCH

GO
