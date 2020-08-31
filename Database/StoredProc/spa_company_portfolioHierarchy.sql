
IF OBJECT_ID('[dbo].[spa_company_portfolioHierarchy]','p') IS NOT NULL 
	DROP PROCEDURE [dbo].[spa_company_portfolioHierarchy]
 GO 


/*
Modified By: Poojan Shrestha
Modified On: 09-22-2008

*/

CREATE proc [dbo].[spa_company_portfolioHierarchy]
	@flag VARCHAR(1),
	@company_type_id INT=null,
	@company_id INT=null,
	@process_id VARCHAR(500)=null
AS
BEGIN

---##### Testing parameters. Uncomment these to test
--DECLARE  @company_type_id INT, @process_id VARCHAR(200), @flag VARCHAR(1)
--SET @flag = 'i'
--SET @company_type_id = 3700
--SET @process_id = 'parent_id_1221258129Q'
--
--DROP TABLE #portfolio_hierarcy_tmp
--DROP TABLE #subs
--DROP TABLE #strat
--DROP TABLE #BOOK
---#################

DECLARE @subs_parent_process_id VARCHAR(500),@strat_parent_process_id VARCHAR(500),@book_parent_process_id VARCHAR(500)
DECLARE @sql_stmt VARCHAR(max), @sql_stmt2 VARCHAR(max),@cols NVARCHAR(2000), @cols2 NVARCHAR(2000),@book_identity_id INT
DECLARE @emissions_reporting_group_id INT
DECLARE @fas_deal_type_value_id INT
DECLARE @source_system_book_type_value_id INT
DECLARE @source_system_id INT
DECLARE @type_of_entity INT
DECLARE @sub_id INT
DECLARE @hedge_type_value_id INT
DECLARE @func_cur_value_id INT

SET @emissions_reporting_group_id=5244
SET @fas_deal_type_value_id=409
SET @source_system_book_type_value_id=50
SET @source_system_id=2
SET @type_of_entity=NULL --5231
SET @hedge_type_value_id=150
SET @func_cur_value_id=2

-- First get the hierarchy and insert in the the temporary table
	CREATE TABLE #portfolio_hierarcy_tmp(
		entity_id INT,
		ph_entity_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		have_rights INT,
		hierarchy_level INT,
		sb INT,
		st INT,
		bk INT,
		process_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
		parent_process_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
		cur_entity_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		ph_entity_id int
	)

	SET @sql_stmt='	
				insert INTo #portfolio_hierarcy_tmp
				( 
					entity_id ,
					ph_entity_name,
					have_rights,
					hierarchy_level,
					sb,
					st,
					bk,
					process_id,
					parent_process_id,
					cur_entity_name
				)
				EXEC spa_getPortfolioHierarchyEmsWiz ''s'',''' + cast(@process_id AS VARCHAR(500)) + ''''
	 
				 
	EXEC(@sql_stmt)


	
BEGIN TRANSACTION

-- Now Insert the Data in the Portfolio Hierarchy table
	DECLARE @sub_entity_id INT, @stra_entity_id INT,@sub_entity_name VARCHAR(100),@stra_entity_name VARCHAR(100),@sub_entity_id_ident int,@entity_id_ident INT,@book_entity_id INT,@book_entity_name VARCHAR(100)
	DECLARE  cur_port_hier_sub CURSOR FOR
	SELECT entity_id,cur_entity_name FROM #portfolio_hierarcy_tmp WHERE hierarchy_level=2 ORDER BY entity_id
	OPEN cur_port_hier_sub
	FETCH next FROM cur_port_hier_sub INTO 	@sub_entity_id,@sub_entity_name
	WHILE @@FETCH_STATUS=0
		BEGIN
				INSERT INTO portfolio_hierarchy(
						entity_type_value_id,entity_name,hierarchy_level
					)
				SELECT	525,@sub_entity_name,2
				
				SET @sub_entity_id_ident=SCOPE_IDENTITY()

				UPDATE #portfolio_hierarcy_tmp SET ph_entity_id=@sub_entity_id_ident WHERE entity_id=@sub_entity_id


				DECLARE cur_port_hier_stra CURSOR  for
				SELECT entity_id,cur_entity_name FROM #portfolio_hierarcy_tmp WHERE hierarchy_level=1 and sb=@sub_entity_id ORDER BY entity_id
				OPEN cur_port_hier_stra
				FETCH next FROM cur_port_hier_stra INTO 	@stra_entity_id,@stra_entity_name
				WHILE @@FETCH_STATUS=0
					BEGIN
						
						INSERT INTO portfolio_hierarchy(
								entity_type_value_id,entity_name,hierarchy_level,parent_entity_id
							)
						SELECT	526,@stra_entity_name,1,@sub_entity_id_ident
						

						SET @entity_id_ident=SCOPE_IDENTITY()

						UPDATE #portfolio_hierarcy_tmp SET ph_entity_id=@entity_id_ident WHERE entity_id=@stra_entity_id

						DECLARE cur_port_hier_book CURSOR for
						SELECT entity_id,cur_entity_name FROM #portfolio_hierarcy_tmp WHERE hierarchy_level=0 and st=@stra_entity_id ORDER BY entity_id
						OPEN cur_port_hier_book
						FETCH next FROM cur_port_hier_book INTO 	@book_entity_id,@book_entity_name
					
						WHILE @@FETCH_STATUS=0
							BEGIN
							
								INSERT INTO portfolio_hierarchy(
										entity_type_value_id,entity_name,hierarchy_level,parent_entity_id
									)
								SELECT	527,@book_entity_name,0,@entity_id_ident
								
								SET @book_identity_id=SCOPE_IDENTITY()
								
								UPDATE #portfolio_hierarcy_tmp SET ph_entity_id=@book_identity_id WHERE entity_id=@book_entity_id

								FETCH next FROM cur_port_hier_book INTO 	@book_entity_id,@book_entity_name
							END
						CLOSE cur_port_hier_book
						DEALLOCATE cur_port_hier_book	

						FETCH next FROM cur_port_hier_stra INTO 	@stra_entity_id,@stra_entity_name	
					END
				CLOSE cur_port_hier_stra
				DEALLOCATE cur_port_hier_stra	
	
			FETCH next FROM cur_port_hier_sub INTO 	@sub_entity_id,@sub_entity_name
		END
	CLOSE cur_port_hier_sub
	DEALLOCATE cur_port_hier_sub
------select * from #portfolio_hierarcy_tmp;





-- Now Insert the Data in the fas Subssidiaries, fas_strategy and fas_book Table


	 create table #subs(
				company_type_id INT,
				company_type_template_id INT,
				section VARCHAR(50) COLLATE DATABASE_DEFAULT,
				entity_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
				entity_type_value_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				disc_source_value_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				disc_type_value_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				func_cur_value_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				days_in_year VARCHAR(100) COLLATE DATABASE_DEFAULT,
				long_term_months VARCHAR(100) COLLATE DATABASE_DEFAULT,
				address1 VARCHAR(100) COLLATE DATABASE_DEFAULT,
				address2 VARCHAR(100) COLLATE DATABASE_DEFAULT,
				city VARCHAR(100) COLLATE DATABASE_DEFAULT,
				state_value_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				zip_code VARCHAR(100) COLLATE DATABASE_DEFAULT,
				country_value_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				entity_url VARCHAR(100) COLLATE DATABASE_DEFAULT,
				tax_payer_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				contact_user_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				primary_naics_code_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				secondary_naics_code_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				entity_category_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				entity_sub_category_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				utility_type_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				ticker_symbol_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				ownership_status VARCHAR(100) COLLATE DATABASE_DEFAULT,
				partners VARCHAR(100) COLLATE DATABASE_DEFAULT,
				holding_company VARCHAR(100) COLLATE DATABASE_DEFAULT,
				domestic_vol_initiatives VARCHAR(100) COLLATE DATABASE_DEFAULT,
				domestic_registeries VARCHAR(100) COLLATE DATABASE_DEFAULT,
				INTernational_registeries VARCHAR(100) COLLATE DATABASE_DEFAULT,
				confidentiality_info VARCHAR(100) COLLATE DATABASE_DEFAULT,
				exclude_indirect_emissions VARCHAR(100) COLLATE DATABASE_DEFAULT,
				organization_boundaries VARCHAR(100) COLLATE DATABASE_DEFAULT,
				base_year_from VARCHAR(100) COLLATE DATABASE_DEFAULT,
				base_year_to VARCHAR(100) COLLATE DATABASE_DEFAULT,
				process_id VARCHAR(100) COLLATE DATABASE_DEFAULT,parent_process_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
				entity_id INT
		)


		
		SELECT  @cols = COALESCE(@cols + ',[' + ctp.parameter_name + ']',
							 '[' + ctp.parameter_name + ']')
			FROM company_template_parameter ctp 
			join company_type_template ctt ON ctt.company_type_template_id = ctp.company_type_template_id
			WHERE ctt.company_type_id = @company_type_id and ctt.section=2 
			
		SET @sql_stmt = '
			insert INTo #subs
			( company_type_id ,company_type_template_id ,section ,' +
				@cols +',process_id,parent_process_id
			)
			EXEC spa_company_template_parameter_value_tmp ''s'',' + cast(@company_type_id AS VARCHAR) + ',''' + cast(@process_id AS VARCHAR(500)) + ''',2,NULL,NULL'
	
		--PRINT @sql_stmt
		EXEC(@sql_stmt)
------select * from #subs;


		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Level 1", ''

				ROLLBACK TRANSACTION
				RETURN

			END



		--Insert in table fas_subsidiaries
		-- Columns for Subsidiary table
		SELECT  @cols2 = COALESCE(@cols2 + '[' + ctp.parameter_name + '],','[' + ctp.parameter_name + '],')
				FROM company_template_parameter ctp 
				join company_type_template ctt ON ctt.company_type_template_id = ctp.company_type_template_id
				WHERE ctt.company_type_id = @company_type_id and ctt.section=2 


		SET @cols2 = left(@cols2,len(@cols2)-1)
		
		SET @sql_stmt = '
			insert INTo fas_subsidiaries 
				(
					fas_subsidiary_id,' + @cols2 + '
				)
		
			select ph.ph_entity_id, ' + @cols2 + '
				from #portfolio_hierarcy_tmp ph
				join #subs subs ON subs.process_id = ph.process_id '

		--PRINT @sql_stmt
		EXEC(@sql_stmt)

		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Level 1", ''

				ROLLBACK TRANSACTION
				RETURN

			END




		-- Finish inserting in fas subsidiaries
		-- Insert in table fas_strategy

		create table #strat
		(
			company_type_id INT,
			company_type_template_id INT,
			section VARCHAR(50) COLLATE DATABASE_DEFAULT,
			entity_name VARCHAR(250) COLLATE DATABASE_DEFAULT,
			test_range_from float, 
			test_range_to float,
			fas_strategy_id INT,
			hedge_type_value_id INT, 
			fx_hedge_flag char,
			gl_grouping_value_id INT,
			no_links char,
			mes_cfv_value_id INT, 
			mes_cfv_values_value_id INT,
			mismatch_tenor_value_id INT, 
			strip_trans_value_id INT, 
			asset_liab_calc_value_id INT,
			include_unlinked_hedges char, 
			include_unlinked_items char,
			oci_rollout_approach_value_id INT, 
			base_year_from INT, 
			base_year_to INT,
			subentity_desc VARCHAR(100) COLLATE DATABASE_DEFAULT,
			process_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
			parent_process_id VARCHAR(100) COLLATE DATABASE_DEFAULT
		)

		SET @cols = null
		
--		select distinct @strat_parent_process_id = process_id FROM company_template_parameter_value_tmp WHERE
--						parent_process_id = @process_id





--select @strat_parent_process_id;

		SELECT  @cols = COALESCE(@cols + ',[' + ctp.parameter_name + ']',
									 '[' + ctp.parameter_name + ']')
					FROM company_template_parameter ctp 
					join company_type_template ctt ON ctt.company_type_template_id = ctp.company_type_template_id
					WHERE ctt.company_type_id = @company_type_id and ctt.section=1  


----------------------------------------------------------------------------------
		declare cur_strat_parent_process_id cursor for 
		select distinct process_id FROM company_template_parameter_value_tmp WHERE
						parent_process_id = @process_id

		--	select distinct process_id as ctpvt_process_id FROM company_template_parameter_value_tmp WHERE
		--					parent_process_id = @process_id

		OPEN cur_strat_parent_process_id
		FETCH next FROM cur_strat_parent_process_id INTO @strat_parent_process_id


		WHILE @@FETCH_STATUS=0
			BEGIN

				SET @sql_stmt = '
					insert INTo #strat
					(
						company_type_id ,
						company_type_template_id ,
						section ,
						' + @cols +
						',
						process_id ,
						parent_process_id
						
					)
					EXEC spa_company_template_parameter_value_tmp ''s'',' + cast(@company_type_id as VARCHAR) + ',''' + cast(@strat_parent_process_id as VARCHAR(500)) + ''',1,NULL,NULL'

				------print (@sql_stmt);
				EXEC (@sql_stmt)
				FETCH next FROM cur_strat_parent_process_id INTO @strat_parent_process_id
			END
		CLOSE cur_strat_parent_process_id
		DEALLOCATE cur_strat_parent_process_id
			



		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Level 2", ''

				ROLLBACK TRANSACTION
				RETURN

			END




		------	select distinct @book_parent_process_id = process_id FROM company_template_parameter_value_tmp WHERE
		------												  parent_process_id = @strat_parent_process_id
		------
		------	select distinct process_id as poojan FROM company_template_parameter_value_tmp WHERE
		------												  parent_process_id = @strat_parent_process_id

		SET @cols2 = ''

		SELECT  @cols2 = COALESCE(@cols2 + '[' + ctp.parameter_name + '],','')
				FROM company_template_parameter ctp 
				join company_type_template ctt ON ctt.company_type_template_id = ctp.company_type_template_id
				WHERE ctt.company_type_id = @company_type_id and ctt.section=1 and ctp.is_entity_name=0
				and ctp.parameter_name!='hedge_type_value_id'

		SET @cols2 = left(@cols2,len(@cols2)-1)
		

		SET @sql_stmt = '
				insert INTo fas_strategy 
				(
					hedge_type_value_id,fas_strategy_id,' + @cols2 +
					'
				)'
		SET @sql_stmt2 = '
				select 
					'+cast(@hedge_type_value_id as varchar)+',ph.ph_entity_id,' + @cols2 +
					'
				from #portfolio_hierarcy_tmp ph
				join #strat strat ON strat.process_id = ph.process_id '

		--PRINT @sql_stmt + @sql_stmt2
		EXEC (@sql_stmt + @sql_stmt2)

		

		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Level 2", ''

				ROLLBACK TRANSACTION
				RETURN

			END



		-- Finish inserting in fas_strategy
		-- Insert in table fas_books


		create table #book
		(
				company_type_id INT,
				company_type_template_id INT,
				section VARCHAR(50) COLLATE DATABASE_DEFAULT,
				entity_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
				fas_book_id INT,
				no_link char(1) COLLATE DATABASE_DEFAULT,
				no_links_fas_eff_test_profile_id INT,
				gl_number_id_st_asSET INT,
				gl_number_id_st_liab INT,
				gl_number_id_lt_asSET INT,
				gl_number_id_lt_liab INT,
				gl_number_id_item_st_asSET INT,
				gl_number_id_item_st_liab INT,
				gl_number_id_item_lt_asSET INT,
				gl_number_id_item_lt_liab INT,
				gl_number_id_aoci INT,
				gl_number_id_pnl INT,
				gl_number_id_SET INT,
				gl_number_id_cash INT,
				gl_number_id_inventory INT,
				gl_number_id_expense INT,
				gl_number_id_gross_SET INT,
				gl_id_amortization INT,
				gl_id_INTerest INT,
				convert_uom_id INT,
				cost_approach_id INT,
				process_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
				parent_process_id VARCHAR(200) COLLATE DATABASE_DEFAULT
		)


		SET @cols = null
		SELECT  @cols = COALESCE(@cols + ',[' + ctp.parameter_name + ']',
								 '[' + ctp.parameter_name + ']')
					FROM company_template_parameter ctp 
					join company_type_template ctt ON ctt.company_type_template_id = ctp.company_type_template_id
					WHERE ctt.company_type_id = @company_type_id and ctt.section=0

		declare cur_bk_parent_process_id cursor for
			select distinct process_id from #strat;
		
		declare @bk_parent_process_id as VARCHAR(500);
		open cur_bk_parent_process_id;
		fetch next from cur_bk_parent_process_id into @bk_parent_process_id;
		while @@FETCH_STATUS = 0
			begin
				SET @sql_stmt = '
				insert INTo #book
				(
					company_type_id ,
					company_type_template_id ,
					section ,' + @cols + ',	
					process_id ,
					parent_process_id
				)
				EXEC spa_company_template_parameter_value_tmp ''s'',' + cast(@company_type_id as VARCHAR) + ',''' + cast(@bk_parent_process_id as VARCHAR(500)) + ''',0,NULL,NULL'

				EXEC spa_print @sql_stmt
				EXEC(@sql_stmt)

				fetch next from cur_bk_parent_process_id into @bk_parent_process_id;
			end
		close cur_bk_parent_process_id;
		deallocate cur_bk_parent_process_id;


		--select * from #book;		

		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Level 3", ''

				ROLLBACK TRANSACTION
				RETURN

			END


		SET @cols2 = ''

		SELECT  @cols2 = COALESCE(ISNULL(@cols2,'') + '[' + ctp.parameter_name + '],','')
						FROM company_template_parameter ctp 
						left join company_type_template ctt ON ctt.company_type_template_id = ctp.company_type_template_id
						and ctp.is_entity_name=0
						WHERE ctt.company_type_id = @company_type_id and ctt.section=0  

		
		if @cols2<>''
			SET @cols2 = left(@cols2,len(@cols2)-1)
				
		SET @sql_stmt = '
				insert INTo fas_books
				(
					fas_book_id' + case when @cols2='' then '' else ',' end+ @cols2 + '
				)'

		SET @sql_stmt2 = '
				select
					ph.ph_entity_id' +case when @cols2='' then '' else ',' end+@cols2 + '
				from #portfolio_hierarcy_tmp ph
				join #book book ON book.process_id = ph.process_id '


		--PRINT @sql_stmt + @sql_stmt2
		EXEC (@sql_stmt + @sql_stmt2)

		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Level 3", ''

				ROLLBACK TRANSACTION
				RETURN

			END




----########################### FOR TEST
		Update fas_strategy 
			set source_system_id=@source_system_id,
				hedge_type_value_id=@hedge_type_value_id
		
		Update fas_subsidiaries
			   set func_cur_value_id=@func_cur_value_id

		---------------------------------------------------------------------------
		-- Insert data from a temporary table company_source_sink_type_value to	 --
		-- tables rec_generator, source_sink_type and ems_source_model_effective --
		---------------------------------------------------------------------------
		--select * from #portfolio_hierarcy_tmp;


-----**************** Insert a new counterparty for each Sub
		INSERT INTO source_counterparty(
					source_system_id,counterparty_id,counterparty_name,counterparty_desc,
					int_ext_flag,type_of_entity
			)
		SELECT DISTINCT
			@source_system_id,
			cast(cur_entity_name+'_Counterparty' AS VARCHAR(50)),
			cast(cur_entity_name+'_Counterparty' AS VARCHAR(50)),
			cast(cur_entity_name+'_Counterparty' AS VARCHAR(50)),
			'e',
			@type_of_entity
		FROM
			#portfolio_hierarcy_tmp 
		WHERE 1=1
			  AND hierarchy_level=2		


		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Source/Sink", ''

				ROLLBACK TRANSACTION
				RETURN

			END


-----**************** Insert a new contract for each Sub
--for each sub insert one contract


DECLARE @cur_entity_name VARCHAR(100)
DECLARE @contract_id INT
		
		SELECT @contract_id=MIN(contract_id) from contract_group --########## Select one contract to copy
		
		DECLARE cur1 CURSOR FOR
		SELECT DISTINCT ph2.entity_name,ph2.entity_id FROM 
					 #portfolio_hierarcy_tmp ph 
					join portfolio_hierarchy ph0 
						ON ph0.entity_id=ph.ph_entity_id AND ph0.hierarchy_level=0 
					join portfolio_hierarchy ph1 
						ON ph1.entity_id=ph0.parent_entity_id AND ph1.hierarchy_level=1
					join portfolio_hierarchy ph2 
						ON ph2.entity_id=ph1.parent_entity_id AND ph2.hierarchy_level=2
		OPEN cur1
			FETCH NEXT FROM cur1 INTO @cur_entity_name,@sub_id
			WHILE @@FETCH_STATUS=0
				BEGIN
					EXEC spa_contract_group 'c',@sub_id,@contract_id,@cur_entity_name
					
			FETCH NEXT FROM cur1 INTO @cur_entity_name,@sub_id	
			END
			
			CLOSE cur1
			DEALLOCATE cur1



		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Source/Sink", ''

				ROLLBACK TRANSACTION
				RETURN

			END


--*********** Insert Source/Sinks

		INSERT INTO rec_generator
			(
					[name],
					id,
					id2,
					source_sink_type,
					reduc_start_date,
					registered,
					fas_book_id,
					ems_source_model_id,
					generator_type,
					gis_value_id,
					technology,
					fuel_value_id,state_value_id,
					legal_entity_value_id,
					ppa_counterparty_id,
					ppa_contract_id,
					create_obligation_deal --------------- Remove this
			
				)
			select 
					cs.source_sink_name,
					cs.source_sink_facility_id,
					source_sink_unit_id,
					cs.source_sink_type,
					cs.source_start_date,
					cs.registered,
					ph0.entity_id,
					cs.ems_source_model_id,
					'e',
					cs.certification_id,
					cs.technology,
					cs.fuel_type,
					cs.jurisdiction,
					ph2.entity_id,
					sc.source_counterparty_id,
					cg.contract_id,
					'y' --------------- Remove this,
			FROM 
					company_source_sink_type_value cs 
					join #portfolio_hierarcy_tmp ph 
						ON cs.fas_book_id=ph.entity_id and ph.hierarchy_level=0
					join portfolio_hierarchy ph0 
						ON ph0.entity_id=ph.ph_entity_id AND ph0.hierarchy_level=0
					join portfolio_hierarchy ph1 
						ON ph1.entity_id=ph0.parent_entity_id AND ph1.hierarchy_level=1
					join portfolio_hierarchy ph2 
						ON ph2.entity_id=ph1.parent_entity_id AND ph2.hierarchy_level=2
					LEFT OUTER JOIN source_counterparty sc 
						ON LTRIM(RTRIM(sc.counterparty_id))=LTRIM(RTRIM(ph2.entity_name))+'_Counterparty' 
						
					LEFT OUTER JOIN contract_group cg
						ON LTRIM(RTRIM(cg.contract_name))=LTRIM(RTRIM(ph2.entity_name)) +' Contract' 
						
			 WHERE 
					cs.process_id=@process_id;




		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Source/Sink", ''

				ROLLBACK TRANSACTION
				RETURN

			END





-----########### Now Insert the values in source_book and source_system_book_map table

--******** Source_book

			
		INSERT INTO source_book(
				source_system_id,
				source_system_book_id,
				source_system_book_type_value_id,
				source_book_name,source_book_desc
			)
		SELECT 
				2,
				cast(ph2.entity_name+'_'+ph1.entity_name+'_'+ph0.entity_name as varchar(50)),
				50,
				cast(ph2.entity_name+'_'+ph1.entity_name+'_'+ph0.entity_name as varchar(50)),
				cast(ph2.entity_name+'_'+ph1.entity_name+'_'+ph0.entity_name as varchar(50)) 
		FROM
			#portfolio_hierarcy_tmp ph 
			JOIN portfolio_hierarchy ph0 
				ON ph0.entity_id=ph.ph_entity_id AND ph0.hierarchy_level=0
			JOIN portfolio_hierarchy ph1 
				ON ph1.entity_id=ph0.parent_entity_id AND ph1.hierarchy_level=1
			JOIN portfolio_hierarchy ph2 
				ON ph2.entity_id=ph1.parent_entity_id AND ph2.hierarchy_level=2


		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Level 2", ''

				ROLLBACK TRANSACTION
				RETURN

			END


		INSERT INTO source_system_book_map(
					fas_book_id,
					source_system_book_id1,
					source_system_book_id2,
					source_system_book_id3,
					source_system_book_id4,		
					fas_deal_type_value_id
				)
		SELECT
			ph.Ph_entity_id as [BookID],
			sb.source_book_id as [source_system_book_id1],
			-2 as [source_system_book_id2],
			-3 as [source_system_book_id3],
			-4 as [source_system_book_id4],
			@fas_deal_type_value_id
		FROM
			#portfolio_hierarcy_tmp ph 
			JOIN portfolio_hierarchy ph0 
				ON ph0.entity_id=ph.ph_entity_id AND ph0.hierarchy_level=0
			JOIN portfolio_hierarchy ph1 
				ON ph1.entity_id=ph0.parent_entity_id AND ph1.hierarchy_level=1
			JOIN portfolio_hierarchy ph2 
				ON ph2.entity_id=ph1.parent_entity_id AND ph2.hierarchy_level=2
			JOIN source_book sb on sb.source_system_book_id=cast(ph2.entity_name+'_'+ph1.entity_name+'_'+ph0.entity_name as varchar(50))
			

	
		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Level 2", ''

				ROLLBACK TRANSACTION
				RETURN

			END


		EXEC spa_ErrorHandler 0, 'Emissions Wizard Setup', 
						'spa_data_transfer_to_physical_tables', 'Success', 
						'Data Successfully Transfered', ''
		
		COMMIT TRANSACTION





-- Insert Company Information into "company_subsidiaries"; Mukesh	
	insert into company_subsidiaries(company_id,fas_subsidiary_id)
	select @company_id,ph_entity_id from #portfolio_hierarcy_tmp where hierarchy_level=2;

---########################## Insert into source_sink_type
		INSERT INTO source_sink_type(
				generator_id, source_sink_type_id, emissions_reporting_group_id
				)
		SELECT 
				rg.generator_id,csstv.ems_book_id, @emissions_reporting_group_id 
		FROM 
				company_source_sink_type_value csstv 
				JOIN #portfolio_hierarcy_tmp ph 
						ON csstv.fas_book_id=ph.entity_id
				JOIN rec_generator rg 
						ON csstv.source_sink_facility_id = rg.id
						   AND ISNULL(csstv.source_sink_unit_id,-1) = ISNULL(rg.id2,-1)
						   AND 	ph.ph_entity_id=rg.fas_book_id
		WHERE 
			csstv.process_id=@process_id
				

		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Source/Sink", ''

				--ROLLBACK TRANSACTION
				RETURN

			END



---#################################### Insert into ems_source_model
		INSERT INTO 
				ems_source_model_effective(generator_id, ems_source_model_id, effective_date)
		SELECT 
				rg.generator_id, csstv.ems_source_model_id, csstv.source_start_date 
		FROM 
				company_source_sink_type_value csstv 
				JOIN #portfolio_hierarcy_tmp ph 
						ON csstv.fas_book_id=ph.entity_id
				JOIN rec_generator rg 
						ON csstv.source_sink_facility_id = rg.id
						   AND ISNULL(csstv.source_sink_unit_id,-1) = ISNULL(rg.id2,-1)
						   AND 	ph.ph_entity_id=rg.fas_book_id
		WHERE 
			csstv.process_id=@process_id
		


		IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_portfolioHierarchy", "DB Error", 
						"Errors Founnd While Transferring Data to Level 2", ''

				--ROLLBACK TRANSACTION
				RETURN

			END

---##############################################
		-----------------------------------------------------------
		-- Clear temporary tables company_source_sink_type_value, --
		-- company_source_sink_type_temp                         --
		-- and company_template_parameter_value_tmp,             --
		-----------------------------------------------------------


		delete from company_source_sink_type_value WHERE process_id = @process_id;

		If @@ERROR <> 0
			begin
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_clear_temp_tables", "DB Error", 
						"Delete of source sink type value  failed.", ''
				return
			end

		delete from company_source_sink_type_temp WHERE process_id=@process_id;


		If @@ERROR <> 0
			begin
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_clear_temp_tables", "DB Error", 
						"delete of source sink value  failed.", ''
				return
			end



		delete from company_template_parameter_value_tmp WHERE process_id in (
			select distinct bk.process_id
			from	company_template_parameter_value_tmp sb,
					company_template_parameter_value_tmp st,
					company_template_parameter_value_tmp bk
			where	st.parent_process_id = sb.process_id
				and	bk.parent_process_id = st.process_id
			and	sb.parent_process_id = @process_id
		);

		If @@ERROR <> 0
			begin
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_clear_temp_tables", "DB Error", 
						"Delete of reporting structure book value  failed.", ''
				return
			end


		delete from company_template_parameter_value_tmp WHERE process_id in (
			select distinct st.process_id from company_template_parameter_value_tmp sb,company_template_parameter_value_tmp st 
			WHERE st.parent_process_id = sb.process_id
			and	sb.parent_process_id = @process_id
		);

		If @@ERROR <> 0
			begin
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_clear_temp_tables", "DB Error", 
						"Delete of reporting structure strategy value  failed.", ''
				return
			end

		delete from company_template_parameter_value_tmp WHERE parent_process_id = @process_id;

		If @@ERROR <> 0
			begin
				EXEC spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_clear_temp_tables", "DB Error", 
						"Delete of reporting structure subsidiary value  failed.", ''
				return
			end



		EXEC spa_ErrorHandler 0, 'Emissions Wizard Setup', 
					'spa_clear_temp_tables', 'Success', 
					'Reporting Group Structure value  successfully inserted.', ''


END


























