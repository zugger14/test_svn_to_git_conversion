IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_flow_optimization_match]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_flow_optimization_match]
	
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Wrapper stored procedure for calling spa_schedule_deal_flow_optimization. This is used in matching deal of dedicated receipt and delivery locations

	Parameters 
	@flag : 
			-m - Compile and prepare data to call spa_schedule_deal_flow_optimization
	@xml_text : Xml Text containing information of receipt and delivery deal/location, term date, path loss, volumns...
	@process_id : Process Id
	@call_from : Call From flag
	
*/

CREATE PROC [dbo].[spa_flow_optimization_match]
	@flag			CHAR(1),
	@xml_text		VARCHAR(MAX) = null,
	@process_id		VARCHAR(50) = NULL,
	@call_from		VARCHAR(200) = null


AS 
SET NOCOUNT ON


/*
SET NOCOUNT ON
DECLARE @flag			CHAR(1),
	@xml_text		VARCHAR(MAX) = null,
	@process_id		VARCHAR(50) = NULL,
	@call_from varchar(200) = null

--SELECT @flag='m',@xml_text='<Root rec_deals="48807" del_deals="51369" rec_location="1267" del_location="1267" flow_date_from="2017-06-01" flow_date_to="2017-06-01" uom="MMBTU" storage_type="" storage_asset_id=""><PSRecordset path_id="-1" contract="8068" sub_book_id="3980" single_path_id="-1" term_start="2017-06-01" rec_vol="3700" del_vol="3700" loss_factor="0" counterparty_id="7496" /> </Root>',@process_id='619295BA_E0D6_4967_B1DC_8D9FD3E5800B',@call_from='opt_book_out'


--select @flag='m',@xml_text='<Root rec_deals="2296" del_deals="2163" rec_location="2996" del_location="2998" flow_date_from="2019-10-15" flow_date_to="2019-10-15" uom="1082" storage_type="" storage_asset_id=""><PSRecordset path_id="157" contract="8216" sub_book_id="73" single_path_id="157" term_start="2019-10-15" rec_vol="150000" del_vol="150000" loss_factor="0" counterparty_id="" /> </Root>',@process_id='67FD7535_C7F3_4CAB_BD09_6FAF1A476D15',@call_from='Deal_Detail'
--EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'dmanandhar';
EXEC sys.sp_set_session_context @key = N'B_USER', @value = 'snepal'

--exec spa_exec_call N'EXEC sys.sp_set_session_context @key = N''DB_USER'', @value = ''dmanandhar'';EXEC spa_flow_optimization_match  @flag=@P1,@xml_text=@P2,@process_id=@P3,@call_from=@P4',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'm',N'<Root rec_deals="146" del_deals="113" rec_location="3128" del_location="3128" flow_date_from="2019-11-11" flow_date_to="2019-11-11" uom="" storage_type="" storage_asset_id=""><PSRecordset path_id="-1" contract="-1" sub_book_id="-1" single_path_id="" term_start="2019-11-11" rec_vol="100" del_vol="100" loss_factor="0" counterparty_id="-1" /> </Root>',N'1590728805998_storage_pool',N'opt_book_out'

SELECT @flag = 'm', @xml_text = '<Root rec_deals="146" del_deals="113" rec_location="3128" del_location="3128" flow_date_from="2019-11-11" flow_date_to="2019-11-11" uom="" storage_type="" storage_asset_id=""><PSRecordset path_id="-1" contract="-1" sub_book_id="-1" single_path_id="" term_start="2019-11-11" rec_vol="100" del_vol="100" loss_factor="0" counterparty_id="-1" /> </Root>', @process_id = '1590728805998_storage_pool', @call_from = 'opt_book_out'

--*/


BEGIN TRY
	BEGIN TRAN
	IF @flag = 'm'
	BEGIN
		SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())

		DECLARE @user_login_id VARCHAR(100) = dbo.FNADBUser()
		DECLARE @contractwise_detail_mdq VARCHAR(500) = dbo.FNAProcessTableName('contractwise_detail_mdq', @user_login_id, @process_id)
		DECLARE @contractwise_detail_mdq_fresh VARCHAR(500) = dbo.FNAProcessTableName('contractwise_detail_mdq_fresh', @user_login_id, @process_id)
		DECLARE @opt_deal_detail_pos VARCHAR(500) = dbo.FNAProcessTableName('opt_deal_detail_pos', @user_login_id, @process_id)
		DECLARE @dest_deal_info VARCHAR(500) = dbo.FNAProcessTableName('dest_deal_info', @user_login_id, @process_id)

		IF OBJECT_ID(@contractwise_detail_mdq) IS NOT NULL
			EXEC('DROP TABLE ' + @contractwise_detail_mdq)
		IF OBJECT_ID(@opt_deal_detail_pos) IS NOT NULL
			EXEC('DROP TABLE ' + @opt_deal_detail_pos)
		IF OBJECT_ID(@dest_deal_info) IS NOT NULL
			EXEC('DROP TABLE ' + @dest_deal_info)

		DECLARE @sql VARCHAR(MAX)

		DECLARE @idoc INT
		IF OBJECT_ID('tempdb..#xml_data') IS NOT NULL 
			DROP TABLE #xml_data
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_text
	
		SELECT 
			rec_deals,		
			del_deals,	
			rec_location,	
			del_location,	
			flow_date_from,
			flow_date_to,	
			su.source_uom_id uom,		
			path_id,		
			[contract],	
			sub_book_id,
			single_path_id,	
			term_start,		
			rec_vol,			
			del_vol,		
			loss_factor,
			storage_type, 
			storage_asset_id,
			counterparty_id
		INTO #xml_data --SELECT * FROM #xml_data
		FROM OPENXML(@idoc,'/Root/PSRecordset',2) 
		WITH (
			rec_deals			VARCHAR(300)		'../@rec_deals',
			del_deals			VARCHAR(300)		'../@del_deals',
			rec_location		VARCHAR(300)		'../@rec_location',
			del_location		VARCHAR(300)		'../@del_location',
			flow_date_from		VARCHAR(300)		'../@flow_date_from',
			flow_date_to		VARCHAR(300)		'../@flow_date_to',
			uom					VARCHAR(300)		'../@uom',		
			path_id				VARCHAR(300)		'@path_id',
			[contract]			VARCHAR(300)		'@contract',
			sub_book_id			VARCHAR(300)		'@sub_book_id',
			single_path_id		VARCHAR(300)		'@single_path_id',
			term_start			VARCHAR(300)		'@term_start',
			rec_vol				VARCHAR(300)		'@rec_vol',
			del_vol				VARCHAR(300)		'@del_vol',
			loss_factor			VARCHAR(300)		'@loss_factor',
			storage_type		VARCHAR(300)		'../@storage_type',
			storage_asset_id	VARCHAR(300)		'../@storage_asset_id',
			counterparty_id		VARCHAR(300)		'@counterparty_id'
		) x
		LEFT JOIN source_uom su 
			ON su.uom_name = x.uom

		UPDATE x
			SET del_location = ISNULL(NULLIF(del_location, ''), dp.to_location)
		
		FROM #xml_data x
		INNER JOIN delivery_path dp
			ON x.path_id = dp.path_id

		DECLARE @check VARCHAR(200), 
				@sub_book_id_new VARCHAR(200)

		SELECT @check = sub_book_id
		FROM #xml_data
			
		IF (@check IN( '', -1))
		BEGIN

			IF @call_from = 'opt_book_out'
			BEGIN 
				DECLARE @template_name VARCHAR(100) = 'Transportation NG'
				DECLARE @field_template_id INT

				SELECT @field_template_id = field_template_id
				FROM source_deal_header_template 
				WHERE template_name = @template_name

				SELECT @sub_book_id_new = default_value 
				FROM maintain_field_template_detail 
				WHERE field_template_id =  @field_template_id
					AND field_id = 3  --sub_book
					AND udf_or_system = 's'		
	
			END 
			ELSE 
			BEGIN
				SELECT @sub_book_id_new = gmv.clm2_value

				FROM generic_mapping_header gmh 
				INNER JOIN generic_mapping_values gmv
					ON gmh.mapping_table_id = gmv.mapping_table_id 
					AND gmh.mapping_name = 'Flow Optimization Mapping'
				INNER JOIN delivery_path dp
					ON CAST(dp.counterParty AS VARCHAR(15))  =  gmv.clm1_value
				INNER JOIN #xml_data xd
					ON dp.path_id = xd.path_id
			END 

		END

			
		ELSE
		BEGIN
			SET @sub_book_id_new = @check
		END

	
		IF NULLIF(@sub_book_id_new, '') IS NULL
		BEGIN
			EXEC spa_ErrorHandler -1, 
				'Path MDQ', 
				'spa_flow_optimization_match', 
				'Error', 
				'Book mapping not found for the pipeline, please select appropriate book.', 
				''
			ROLLBACK
			RETURN
		END
		--ELSE
		--BEGIN
		--	SET @sub_book_id_new = @check
		--END


		DECLARE @flow_date_from DATETIME
		DECLARE @flow_date_to DATETIME
		DECLARE @from_location VARCHAR(300)
		DECLARE @to_location VARCHAR(300)
		DECLARE @uom VARCHAR(10)
		DECLARE @rec_deals VARCHAR(200)
		DECLARE @del_deals VARCHAR(200)
		DECLARE @match_term_start DATETIME
		DECLARE @match_term_end DATETIME
		DECLARE @storage_type CHAR(1)
		DECLARE @storage_asset_id INT
		DECLARE @contract_id INT
		DECLARE @delivery_path INT
		DECLARE @loss_factor VARCHAR(50)
		DECLARE @counterparty_id int
	
		SELECT 
			@flow_date_from = xd.flow_date_from,
			@flow_date_to = xd.flow_date_to,
			@from_location = xd.rec_location,
			@to_location = xd.del_location,
			@uom = xd.uom,
			@rec_deals = xd.rec_deals,
			@del_deals = xd.del_deals,
			@storage_type = xd.storage_type,
			@storage_asset_id = xd.storage_asset_id,
			@contract_id = xd.contract,
			@delivery_path = xd.path_id,
			@loss_factor = xd.loss_factor,
			@counterparty_id = xd.counterparty_id
		FROM #xml_data xd

		SELECT @match_term_start = MIN(xd.term_start), 
				@match_term_end = MAX(xd.term_start)
		FROM #xml_data xd
	

		IF NULLIF(NULLIF(@contract_id, -1), '') IS NULL
		BEGIN
			SELECT @contract_id = MAX(contract_id)
			FROM contract_group
		
		END 


		UPDATE #xml_data SET contract = @contract_id
		WHERE contract = -1

		IF NULLIF(NULLIF(@counterparty_id, -1), '') IS NULL
		BEGIN
			SELECT @counterparty_id = pipeline 
			FROM source_minor_location 
			WHERE source_minor_location_id = @from_location
				
		END 

		UPDATE #xml_data SET counterparty_id = @counterparty_id
		WHERE counterparty_id = -1

		IF OBJECT_ID('tempdb..#flag_c_result') IS NOT NULL 
			DROP TABLE #flag_c_result

		CREATE TABLE #flag_c_result (
			box_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
			from_loc_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
			from_loc VARCHAR(200) COLLATE DATABASE_DEFAULT,
			to_loc_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
			to_loc VARCHAR(200) COLLATE DATABASE_DEFAULT,
			from_rank VARCHAR(200) COLLATE DATABASE_DEFAULT,
			to_rank VARCHAR(200) COLLATE DATABASE_DEFAULT,
			received VARCHAR(200) COLLATE DATABASE_DEFAULT,
			delivered VARCHAR(200) COLLATE DATABASE_DEFAULT,
			mdq VARCHAR(200) COLLATE DATABASE_DEFAULT,
			rmdq VARCHAR(200) COLLATE DATABASE_DEFAULT,
			ormdq VARCHAR(200) COLLATE DATABASE_DEFAULT,
			path_exists VARCHAR(200) COLLATE DATABASE_DEFAULT,
			path_mdq VARCHAR(200) COLLATE DATABASE_DEFAULT,
			path_rmdq VARCHAR(200) COLLATE DATABASE_DEFAULT,
			path_ormdq VARCHAR(200) COLLATE DATABASE_DEFAULT,
			process_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
			from_loc_grp_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
			from_loc_grp_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
			to_loc_grp_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
			to_loc_grp_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
			box_type VARCHAR(50) COLLATE DATABASE_DEFAULT,
			from_proxy_loc_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
			to_proxy_loc_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
			from_is_agg VARCHAR(10) COLLATE DATABASE_DEFAULT,
			to_is_agg VARCHAR(10) COLLATE DATABASE_DEFAULT
		)

		declare @path_id_param int = iif(@call_from in ('opt_book_out','opt_book_out_b2b'), null, @delivery_path)

		INSERT INTO #flag_c_result
		EXEC spa_flow_optimization 
			@flag='c',
			@flow_date_from=@flow_date_from,
			@flow_date_to=@flow_date_to,
			@from_location=@from_location,
			@to_location=@to_location,
			@uom=@uom,
			@process_id=@process_id,
			@contract_id=@contract_id,
			@delivery_path = @path_id_param
			,@call_from = 'flow_match'
			,@receipt_deals_id= @rec_deals
			,@delivery_deals_id= @del_deals

		--book out path create logic start
		DECLARE @path_id INT = null
		if @call_from in ('opt_book_out','opt_book_out_b2b')
		begin
			declare @dummy_path_name varchar(100) = @process_id
		
			IF NOT EXISTS(
				SELECT 1 FROM delivery_path 
				WHERE from_location = @from_location 
					AND to_location = @to_location
					AND counterparty = @counterparty_id 
					AND contract = @contract_id
			)
			BEGIN
				DECLARE @form_xml VARCHAR(MAX) 
				DECLARE @label_location VARCHAR(200)
			

				SELECT @label_location = location_name 
				FROM source_minor_location
				WHERE source_minor_location_id = @from_location
		
				SET @form_xml = '<FormXML  groupPath="n" rateSchedule="" path_id="" CONTRACT="' + CAST(@contract_id AS VARCHAR(10)) + '" counterParty="' + CAST(@counterparty_id AS VARCHAR(10)) + '" priority="-31400" from_location="' + CAST(@from_location AS VARCHAR(10)) + '" label_from_location="' + @label_location + '" to_location="' + CAST(@from_location AS VARCHAR(10)) + '" label_to_location="' + @label_location + '" path_name="' + @dummy_path_name + '" path_code="" mdq="0" logical_name="" isactive="y" deal_link=""></FormXML>'
		
				EXEC spa_setup_delivery_path  @flag='i',@form_xml=@form_xml,@rate_schedule_xml='<GridGroup></GridGroup>',@fuel_loss_xml='<GridGroup></GridGroup>',@group_path_xml=NULL,@mdq_grid_xml='<GridGroup></GridGroup>',@is_confirm='0', @is_bookout = 1, @show_message= 0

				--EXEC spa_setup_delivery_path  @flag='i',@form_xml='<FormXML  groupPath="n" rateSchedule="" path_id="" CONTRACT="11325" counterParty="7828" priority="303954" from_location="2739" label_from_location="Permian pool" to_location="2739" label_to_location="Permian pool" path_name="22B38146_7205_4BB4_9857_980A90508BE8" path_code="" mdq="0" logical_name="" isactive="y" deal_link=""></FormXML>',@rate_schedule_xml='<GridGroup></GridGroup>',@fuel_loss_xml='<GridGroup></GridGroup>',@group_path_xml=NULL,@mdq_grid_xml='<GridGroup></GridGroup>',@is_confirm='0', @is_bookout = 1
			
				SELECT @path_id = path_id  
				FROM delivery_path 
				WHERE from_location = @from_location 
					AND to_location = @to_location
					AND counterparty = @counterparty_id 
					AND contract = @contract_id					
					
			END
			ELSE 
			BEGIN
				SELECT @path_id = path_id  
				FROM delivery_path 
				WHERE from_location = @from_location 
					AND to_location = @to_location
					AND counterparty = @counterparty_id 
					AND contract = @contract_id
			END
		end


		--book out path create logic end
	

		--udpate receipt and delivery deals on process table
		SET @sql = '
		UPDATE cd
			SET cd.receipt_deals = ''' + @rec_deals + ''',
				cd.delivery_deals = ''' + @del_deals + ''',
				cd.match_term_start = ''' + CAST(@flow_date_from AS VARCHAR(50))+ ''',
				cd.storage_deal_type = '''  + @storage_type + ''',
				cd.storage_asset_id  = '''  + CAST(@storage_asset_id AS VARCHAR(10)) + ''',
				cd.storage_volume = '  + CASE  WHEN @storage_type IN ('i', 'w') THEN ' cd.delivered '  ELSE ' cd.storage_volume ' END + ',
				cd.match_term_end = ''' + CAST(@flow_date_to AS VARCHAR(50)) + ''',
				cd.contract_id = ''' + CAST(@contract_id AS VARCHAR(50)) + ''',
				cd.loss_factor = ''' + @loss_factor + '''
				' + isnull(',cd.path_id = ' + CAST(@path_id AS VARCHAR(50)),'') + '
		FROM ' + @contractwise_detail_mdq + ' cd
		'
		EXEC(@sql)

		SET @sql = '
		UPDATE cd
			SET cd.receipt_deals = ''' + @rec_deals + ''',
				cd.delivery_deals = ''' + @del_deals + ''',
				cd.match_term_start = ''' + CAST(@flow_date_from AS VARCHAR(50))+ ''',
				cd.storage_deal_type = '''  + @storage_type + ''',
				cd.storage_asset_id  = '''  + CAST(@storage_asset_id AS VARCHAR(10)) + ''',
				cd.storage_volume = '  + CASE  WHEN @storage_type IN ('i', 'w') THEN ' cd.delivered '  ELSE ' cd.storage_volume ' END + ',
				cd.match_term_end = ''' + CAST(@flow_date_to AS VARCHAR(50)) + ''',
				cd.contract_id = ''' + CAST(@contract_id AS VARCHAR(50)) + ''',
				cd.loss_factor = ''' + @loss_factor + '''
				' + isnull(',cd.path_id = ' + CAST(@path_id AS VARCHAR(50)),'') + '
		FROM ' + @contractwise_detail_mdq_fresh + ' cd
		'
		EXEC(@sql)

		if nullif(@path_id,'') is not null
		begin
			update #xml_data set single_path_id= @path_id,path_id=@path_id
		end
		

		----filter only concerned deals with receipt/delivery deals
		--SET @sql = '
		--DELETE od FROM ' + @opt_deal_detail_pos + ' od
		--WHERE location_type <> ''Storage''' + CASE WHEN NULLIF(@rec_deals, '') IS NOT NULL THEN ' AND od.source_deal_header_id NOT IN (' + @rec_deals + ')' ELSE '' END
		--				+ CASE WHEN NULLIF(@del_deals, '') IS NOT NULL THEN ' AND od.source_deal_header_id NOT IN (' + ISNULL(@del_deals, '''''') + ')' ELSE '' END
						
		--EXEC(@sql) 	
				
		--insert destination deal information
		SET @sql = ' SELECT ''' + @process_id + ''' [process_id], 
							''' + @sub_book_id_new + ''' [sub_book_id], 
							xd.[contract], 
							xd.path_id [group_path_id], 
							xd.single_path_id,
							xd.term_start, 
							xd.rec_vol, 
							xd.del_vol, 
							xd.loss_factor, 
							xd.rec_deals, 
							xd.del_deals
						INTO ' + @dest_deal_info + '
					FROM #xml_data xd
		'

		EXEC(@sql)
		
		--RECEIVED AND DELIVERY VOLUME SHOULD NOT BE ZERO FOR FURTHER PROCESSING IN spa_schedule_deal_flow_optimization
		--SO UPDATED RECEIVED AND DELIVERED VOLUME RANDOMLY WITH 100
		SET @sql = 'UPDATE cd
						SET cd.received = xd.rec_vol, 
							cd.delivered = xd.del_vol,
							cd.loss_factor = xd.loss_factor
					FROM ' + @contractwise_detail_mdq + ' cd 
					inner join #xml_data xd on xd.path_id = cd.path_id
						and xd.[contract] = cd.contract_id
						and xd.term_start = cd.match_term_start
					'			
		EXEC(@sql) 
	
		----dummy path table delivery_path
		--declare @delivery_path_dummy varchar(500) = dbo.FNAProcessTableName('delivery_path_dummy', @user_login_id, @process_id)
		--if object_id(@delivery_path_dummy) is not null exec('drop table ' + @delivery_path_dummy)
		--set @sql = '
		--select -1 [path_id],''Dummy Path'' [path_name], cd.from_loc_id [from_location],to_loc_id [to_location],0 [loss_factor],''n'' [groupPath]
		--into ' + @delivery_path_dummy + '
		--from ' + @contractwise_detail_mdq + ' cd'
		--exec(@sql)
		
		--select	
		--	'@flag'='i',
		--	'@box_ids'='1',
		--	'@flow_date_from' = @match_term_start,
		--	'@flow_date_to' = @match_term_end,
		--	'@contract_process_id' = @process_id,
		--	'@call_from'='flow_match',
		--	'@sub_book' = @sub_book_id_new
		
		EXEC spa_schedule_deal_flow_optimization
			@flag = 'i',
			@box_ids = '1',
			@flow_date_from = @match_term_start,
			@flow_date_to = @match_term_end,
			@contract_process_id = @process_id,
			@call_from = 'flow_match',
			@sub_book = @sub_book_id_new

		----delete dummy path
		delete from delivery_path where path_name = @process_id
	END
	COMMIT
	
END TRY
BEGIN CATCH
	ROLLBACK
	DECLARE @err_msg VARCHAR(3000) = ERROR_MESSAGE()
	EXEC spa_ErrorHandler 1
	, 'Flow Optimization Match'
	, 'spa_flow_optimization_match'
	, 'Error'
	, @err_msg
	, ''

END CATCH

GO