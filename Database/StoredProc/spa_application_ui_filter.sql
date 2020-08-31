SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].spa_application_ui_filter', N'P ') IS NOT NULL 
	DROP PROCEDURE [dbo].spa_application_ui_filter
GO

/**
	Manipulating filter details for application UI

	Parameters
	@flag	:	Operation Flag
	@xml_string	:	FilterForm XML String
	@function_id	:	Application function id
	@filter_id	:	Application UI Filter ID
*/

CREATE PROCEDURE [dbo].[spa_application_ui_filter] 
	@flag char(1) = NULL,
	@xml_string xml = NULL,
	@function_id VARCHAR(10)= NULL,
	@filter_id INT = NULL
AS
/*
declare  @flag char(1) = NULL, @xml_string xml = NULL,
@function_id VARCHAR(10)= NULL,
@filter_id INT = NULL

--select   @flag='i',@xml_string='<ApplicationFilter name="full_filter" application_function_id="10202600" report_id="141" paramset_id="17702,17736"><Filter name="book_structure" value="MLGW||Diesel||Hedge||DSL-H,Scheduling and Storage"/><Filter name="subsidiary_id" value="2"/><Filter name="strategy_id" value="12"/><Filter name="book_id" value="13"/><Filter name="subbook_id" value="11,17"/><Filter name="from_as_of_date" value="2018-02-01,,"/><Filter name="source_deal_header_id" value="2356"/><Filter name="deal_ref_id" value="1111"/><Filter name="period_from" value=""/><Filter name="period_to" value=""/><Filter name="term_start" value="2018-02-01,,"/><Filter name="term_end" value="2018-02-02,,"/><Filter name="trader_id" value="160,153"/><Filter name="label_trader_id" value="ashrestha,David Hopkins"/><Filter name="source_counterparty_id" value="4335,4513"/><Filter name="label_source_counterparty_id" value="1 - MLGW,2468 - Waste Pro"/><Filter name="contract_id" value="3753,3754"/><Filter name="label_contract_id" value="Case 1,Case 2"/><Filter name="location_id" value="1498,1497"/><Filter name="label_location_id" value="164-QGC Wasatch Front,35-Powder Wash MM"/><Filter name="index_id" value="4651,4652"/><Filter name="label_index_id" value="15 min,5 min"/><Filter name="buy_sell_flag" value="b"/><Filter name="physical_financial_flag" value="f"/><Filter name="commodity_id" value="266"/><Filter name="source_deal_type_id" value="144"/><Filter name="charge_type_id" value="-5500"/><Filter name="pnl_source_value_id" value="4500"/></ApplicationFilter>'
select @flag='p',@filter_id='19459',@xml_string ='<ApplicationFilter><UserRole user_login_id="abc22" role_id="" /><UserRole user_login_id="" role_id="65" /><UserRole user_login_id="" role_id="1236" /><UserRole user_login_id="" role_id="1242" /></ApplicationFilter>'

--*/
SET NOCOUNT ON

DECLARE @user varchar(50) = dbo.FNADBUser()
DECLARE @application_ui_filter_name nvarchar(50)
DECLARE @application_group_id int
DECLARE @report_id int
DECLARE @current_identity_filter_id int
DECLARE @application_function_id int
DECLARE @is_public BIT = 0
DECLARE @filter_created_user VARCHAR(50)

	IF OBJECT_ID('tempdb..#filterTemp') IS NOT NULL
		DROP TABLE #filterTemp
     
	--IF OBJECT_ID('tempdb..#filterTemp_tree') IS NOT NULL
	--	DROP TABLE #filterTemp_tree

	IF OBJECT_ID('tempdb..#filterTemp_grid') IS NOT NULL
		DROP TABLE #filterTemp_grid
 
	IF OBJECT_ID('tempdb..#filterTemp1') IS NOT NULL
		DROP TABLE #filterTemp1

	IF OBJECT_ID('tempdb..#filterTemp2') IS NOT NULL
		DROP TABLE #filterTemp2
	IF OBJECT_ID('tempdb..#filterTemp3') IS NOT NULL
		DROP TABLE #filterTemp3
	IF OBJECT_ID('tempdb..#filterTemp4') IS NOT NULL
		DROP TABLE #filterTemp4

	IF OBJECT_ID('tempdb..#temp_columns') IS NOT NULL
		DROP TABLE #temp_columns

	IF OBJECT_ID('tempdb..#temp_columns1') IS NOT NULL
		DROP TABLE #temp_columns1

	SELECT @is_public = IIF(CHARINDEX('(Public)', application_ui_filter_name ) = 0, 0, 1)
	FROM application_ui_filter 
	WHERE application_ui_filter_id = @filter_id

	SELECT @filter_created_user = create_user 
	FROM application_ui_filter 
	WHERE application_ui_filter_id = @filter_id

IF @flag = 'i'
BEGIN
BEGIN TRY
	SELECT
		T.c.value('../@name', 'nvarchar(50)') AS application_ui_filter_name,
		T.c.value('../@application_group_id', 'int') AS application_group_id,
		T.c.value('../@report_id', 'int') AS report_id,
		T.c.value('../@application_function_id', 'int') AS application_function_id,
		T.c.value('@name', 'varchar(50)') AS column_name,
		T.c.value('@value', 'nvarchar(max)') AS field_value, 
		T.c.value('../@paramset_id', 'varchar(300)') AS paramset_id 
		INTO #filterTemp
	FROM @xml_string.nodes('/ApplicationFilter/Filter') AS T (c)
     
	SELECT
		T.c.value('../@name', 'nvarchar(50)') AS application_ui_filter_name,
		T.c.value('../@application_group_id', 'int') AS application_group_id,
		T.c.value('../@report_id', 'int') AS report_id,
		T.c.value('../@application_function_id', 'int') AS application_function_id,
		T.c.value('@layout_grid_id', 'varchar(50)') AS layout_grid_id,
		T.c.value('@value', 'nvarchar(max)') AS field_value,
		T.c.value('@book_level', 'varchar(1000)') AS book_level 
	INTO #filterTemp_grid
	FROM @xml_string.nodes('/ApplicationFilter/GridFilter') AS T (c)
     
	--SELECT
	--  T.c.value('../@name', 'varchar(50)') AS application_ui_filter_name,
	--  T.c.value('../@application_group_id', 'int') AS application_group_id,
	--  T.c.value('../@report_id', 'int') AS report_id,
	--  T.c.value('../@application_function_id', 'int') AS application_function_id,
	--  T.c.value('@name', 'varchar(50)') AS column_name,
	--  T.c.value('@value', 'varchar(1000)') AS field_value INTO #filterTemp_tree
	--FROM @xml_string.nodes('/ApplicationFilter/Filter_tree') AS T (c)
	
	--INSERT INTO #filterTemp SELECT * FROM #filterTemp_tree
   


SELECT TOP 1
	@application_ui_filter_name = application_ui_filter_name,
	@report_id = report_id,
	@application_group_id = application_group_id,
	@application_function_id = application_function_id
FROM #filterTemp
	
	SELECT @filter_created_user = create_user 
	FROM application_ui_filter 
	WHERE application_ui_filter_name = @application_ui_filter_name
		AND user_login_id = @user

   DECLARE @new_update_id INT

	DECLARE @can_update BIT = 1
	SELECT @can_update = IIF(CHARINDEX('(Public)', @application_ui_filter_name ) <> 0 
						AND @user <> ISNULL(@filter_created_user, '-1'), 0, 1)
	IF @can_update = 0
	BEGIN 		
		EXEC spa_ErrorHandler -1,
						'Filter publish.',
						'spa_application_ui_filter',
						'DB Error',
						'Fail to update public filter.',
						''

		RETURN;
	END 


IF @application_function_id IS NULL AND EXISTS(SELECT 1 FROM #filterTemp_grid)
BEGIN
	SELECT TOP 1
	@application_ui_filter_name = application_ui_filter_name,
	@report_id = report_id,
	@application_group_id = application_group_id,
	@application_function_id = application_function_id
	FROM #filterTemp_grid
END

IF @application_function_id IS NOT NULL AND @report_id IS NOT NULL
BEGIN
	if @application_function_id = 10201700
	begin
		IF EXISTS (
			SELECT 1
			FROM application_ui_filter AS auf
			WHERE auf.application_ui_filter_name = @application_ui_filter_name
			AND auf.report_id = @report_id AND auf.application_function_id = @application_function_id
			AND auf.user_login_id = @user
		)
		BEGIN
			UPDATE application_ui_filter_details
				SET field_value = ft.field_value
			FROM #filterTemp ft
			INNER JOIN application_ui_filter AS auf
				ON ft.application_function_id = auf.application_function_id
			INNER JOIN application_ui_template_definition AS autd
				ON autd.field_id = ft.column_name
			INNER JOIN application_ui_template_fields AS autf
				ON autf.application_ui_field_id = autd.application_ui_field_id
			WHERE auf.user_login_id = @user
			AND auf.application_function_id = @application_function_id
			AND auf.application_ui_filter_name = @application_ui_filter_name
			AND auf.report_id = @report_id
			AND auf.application_ui_filter_id = application_ui_filter_details.application_ui_filter_id
			AND autd.field_id = ft.column_name
			AND application_ui_filter_details.application_field_id = autf.application_field_id
		END
		ELSE
		BEGIN
			INSERT INTO application_ui_filter (application_group_id, application_function_id, report_id, user_login_id, application_ui_filter_name)
			SELECT TOP 1
				application_group_id,
				application_function_id,
				report_id,
				dbo.FNADBUser(),
				application_ui_filter_name
			FROM #filterTemp

			SET @current_identity_filter_id = SCOPE_IDENTITY()

			INSERT INTO application_ui_filter_details (
				application_ui_filter_id,
				application_field_id,
				report_column_id,
				field_value
			)
			SELECT
				@current_identity_filter_id,
				autf.application_field_id,
				NULL,
				ft.field_value
			FROM #filterTemp ft
			INNER JOIN application_ui_template_definition AS autd ON autd.field_id = ft.column_name
			INNER JOIN application_ui_template_fields AS autf ON autf.application_ui_field_id = autd.application_ui_field_id
			INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
			WHERE autd.application_function_id = @application_function_id
		END
	end
	else if @application_function_id = 10202600  OR @application_function_id = 10202700 --excel addin reports OR power bi reports
	begin
		declare @concerned_paramset_ids nvarchar(300)
		select @concerned_paramset_ids = ft.field_value from #filterTemp ft where ft.column_name = 'report_paramset_id'

		if nullif(@concerned_paramset_ids, '') is null
		begin
			select top 1 @concerned_paramset_ids = ft.paramset_id from #filterTemp ft
		end

		--if COL_LENGTH('tempdb..#filterTemp','paramset_id') is null
		--begin
		--	alter table #filterTemp add paramset_id int
			--select * from #filterTemp

			update ft set ft.paramset_id = rdp.paramset_id
			from #filterTemp ft
			--inner join data_source_column dsc on dsc.name = ft.column_name or dsc.name = replace(ft.column_name, 'label_','')
			inner join data_source_column dsc on dsc.name = 
						case  
							when ft.column_name='subsidiary_id' then 'sub_id'
							when ft.column_name='strategy_id' then 'stra_id'
							when ft.column_name='subbook_id' then 'sub_book_id'
							when ft.column_name like '2_%' then REPLACE(ft.column_name, '2_', '')
							else ft.column_name
						end
			inner join report_param rp on rp.column_id = dsc.data_source_column_id
			inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
			inner join dbo.SplitCommaSeperatedValues(@concerned_paramset_ids) scsv on scsv.item = rdp.paramset_id


			--update paramset_id for book_structure and label fields with corresponding column (take paramset_id of subbook_id incase of book_structure)
			update ft 
				set ft.paramset_id = 
					case 
						when ft.column_name = 'book_structure' then book_str_paramset_id.paramset_id 
						when ft.column_name like 'label_%' then label_paramset_id.paramset_id
						else ft.paramset_id
					end
			--select book_str_paramset_id.paramset_id, label_paramset_id.paramset_id, ft.*
			from #filterTemp ft
			outer apply (
				select top 1 ft1.paramset_id
				from #filterTemp ft1
				where ft1.column_name = 'subbook_id' and ft.column_name = 'book_structure'
			) book_str_paramset_id
			outer apply (
				select top 1 ft2.paramset_id
				from #filterTemp ft2
				where ft2.column_name = replace(ft.column_name, 'label_', '') and ft.column_name like 'label_%'
			) label_paramset_id
			where charindex(',', ft.paramset_id) > 0
		--end
					
		IF EXISTS (
			SELECT 1
			FROM application_ui_filter AS auf
			WHERE auf.application_ui_filter_name = @application_ui_filter_name
			AND auf.report_id = @report_id and auf.application_function_id = @application_function_id
			AND auf.user_login_id = @user
		)
		BEGIN

			DECLARE @update_id1 INT
			SELECT
				@update_id1 = auf.application_ui_filter_id
			FROM application_ui_filter AS auf
			WHERE auf.application_ui_filter_name = @application_ui_filter_name
			AND auf.report_id = @report_id and auf.application_function_id = @application_function_id
			AND auf.user_login_id = @user

			--UPDATE EXISTING FILTER DETAILS
        
			--store to update filter details
			if OBJECT_ID('tempdb..#to_update_filter_detail1') is not null
				drop table #to_update_filter_detail1
			select dsc.application_ui_filter_details_id,ft.column_name,ft.field_value
			into #to_update_filter_detail1
			--ft.*,dsc.*
			FROM #filterTemp ft
			INNER JOIN application_ui_filter AS auf
				ON ft.report_id = auf.report_id 
		
			cross apply (
				select aufd.application_ui_filter_details_id,dsc1.data_source_column_id, iif(aufd.book_level='parameter_value2','2_'+dsc1.name,dsc1.name) name
				from application_ui_filter_details aufd
				inner join data_source_column dsc1 on dsc1.data_source_column_id = aufd.report_column_id
				inner join report_param rp on rp.column_id = dsc1.data_source_column_id
				inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id and rdp.paramset_id = ft.paramset_id
				where aufd.application_ui_filter_id = auf.application_ui_filter_id 
					and iif(aufd.book_level='parameter_value2','2_'+dsc1.name,dsc1.name) = 
					case  
						when ft.column_name='subsidiary_id' then 'sub_id'
						when ft.column_name='strategy_id' then 'stra_id'
						when ft.column_name='subbook_id' then 'sub_book_id'
						else ft.column_name
					end
				

			) dsc
			where auf.application_ui_filter_id = @update_id1

			UPDATE aufd
				SET field_value = tufd.field_value
			from application_ui_filter_details aufd
			inner join #to_update_filter_detail1 tufd on tufd.application_ui_filter_details_id = aufd.application_ui_filter_details_id

		
			UPDATE aufd
			SET aufd.field_value = ft.field_value
			from application_ui_filter_details aufd
			INNER JOIN data_source_column dsc ON dsc.data_source_column_id * -1 = aufd.report_column_id
			INNER JOIN #filterTemp ft  
			ON dsc.name = 
					case 
						when ft.column_name  = 'book_structure' then 'sub_book_id'
						when  ft.column_name like 'label_%' then Replace(ft.column_name, 'label_', '')
					end
		
			where aufd.application_ui_filter_id = @update_id1

		END
		ELSE
		BEGIN

			--INSERT FILTER DETAILS
			INSERT INTO application_ui_filter (
				application_group_id,
				report_id,
				user_login_id,
				application_ui_filter_name,
				application_function_id
			)
			SELECT TOP 1
				application_group_id,
				report_id,
				dbo.FNADBUser(),
				application_ui_filter_name,
				application_function_id
			FROM #filterTemp
				
			SET @current_identity_filter_id = SCOPE_IDENTITY()

			SELECT
				@current_identity_filter_id [id],
				NULL [application_field_id],
				dsc.data_source_column_id,
				ft.field_value,
				ft.column_name,
				case when rpm.operator = 8 and ft.column_name like '2_%' then 'parameter_value2' else null end [book_level]
			INTO #temp_columns1
			--select *
			FROM #filterTemp ft
			INNER JOIN report_paramset rps ON rps.report_paramset_id = ft.paramset_id
			INNER JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
			INNER JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id
			INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rpm.column_id
			AND dsc.name = 
				case  
					when ft.column_name='subsidiary_id' then 'sub_id'
					when ft.column_name='strategy_id' then 'stra_id'
					when ft.column_name='subbook_id' then 'sub_book_id'
					when rpm.operator = 8 then REPLACE(ft.column_name, '2_', '')
					else ft.column_name
				end
			--WHERE rps.report_paramset_id = @report_id
		  
			INSERT INTO application_ui_filter_details (
				application_ui_filter_id,
				application_field_id,
				report_column_id,
				field_value,
				book_level
			)
			SELECT id,
				NULL,
				data_source_column_id,
				field_value,book_level
			FROM #temp_columns1

			DECLARE @subbook_column_id1 INT
			SELECT @subbook_column_id1 = tc.data_source_column_id * -1
			FROM #temp_columns1 tc WHERE tc.column_name = 'subbook_id'

			INSERT INTO application_ui_filter_details (
				application_ui_filter_id,
				application_field_id,
				report_column_id,
				field_value
			)
			select @current_identity_filter_id,
				NULL, @subbook_column_id1 ,ft.field_value 
			from #filterTemp ft 
			where ft.column_name = 'book_structure'

			INSERT INTO application_ui_filter_details (
				application_ui_filter_id,
				application_field_id,
				report_column_id,
				field_value
			)
			SELECT @current_identity_filter_id,
				NULL, tc.data_source_column_id * -1 ,ft.field_value FROM #filterTemp ft
			INNER JOIN #temp_columns1 tc ON 'Label_' + tc.column_name = ft.column_name
		 
		END
	end
END

ELSE IF @application_group_id IS NOT NULL
BEGIN
	IF EXISTS (
		SELECT 1
		FROM application_ui_filter AS auf
		WHERE auf.application_ui_filter_name = @application_ui_filter_name
		AND auf.application_group_id = @application_group_id
		AND auf.user_login_id = @user
	)
	BEGIN
		--UPDATE EXISTING FILTER DETAILS FOR SAME FILTERNAME, USER, GROUP
		--IF USER DOES `SAVE AS` AND ENTERS EXISTING FILTERNAME, IT ALSO ACTS AS UPDATE
		UPDATE application_ui_filter_details
		SET field_value = ft.field_value
		FROM #filterTemp ft
		INNER JOIN application_ui_filter AS auf ON ft.application_group_id = auf.application_group_id
		INNER JOIN application_ui_template_definition AS autd ON autd.field_id = ft.column_name
		INNER JOIN application_ui_template_fields AS autf ON autf.application_ui_field_id = autd.application_ui_field_id
		WHERE auf.user_login_id = @user
			AND auf.application_group_id = @application_group_id
			AND auf.application_ui_filter_name = @application_ui_filter_name
			AND auf.application_ui_filter_id = application_ui_filter_details.application_ui_filter_id
			AND autd.field_id = ft.column_name
			AND application_ui_filter_details.application_field_id = autf.application_field_id

	END
	ELSE
	BEGIN

		--INSERT FILTER DETAILS
		INSERT INTO application_ui_filter (
			application_group_id,
			report_id,
			user_login_id,
			application_ui_filter_name
		)
		SELECT TOP 1
			application_group_id,
			report_id,
			dbo.FNADBUser(),
			application_ui_filter_name
		FROM #filterTemp

		SET @current_identity_filter_id = SCOPE_IDENTITY()

		INSERT INTO application_ui_filter_details (
			application_ui_filter_id,
			application_field_id,
			report_column_id,
			field_value
		)
		SELECT
			@current_identity_filter_id,
			autf.application_field_id,
			NULL,
			ft.field_value
		FROM #filterTemp ft
		INNER JOIN application_ui_template_definition AS autd ON autd.field_id = ft.column_name
		INNER JOIN application_ui_template_fields AS autf ON autf.application_ui_field_id = autd.application_ui_field_id
		INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
		WHERE autg.application_group_id = @application_group_id

	END
END
ELSE
IF @report_id IS NOT NULL
BEGIN
	IF EXISTS (
		SELECT 1
		FROM application_ui_filter AS auf
		WHERE auf.application_ui_filter_name = @application_ui_filter_name
			AND auf.report_id = @report_id
			AND auf.user_login_id = @user
	)
	BEGIN

		DECLARE @update_id INT
		SELECT @update_id = auf.application_ui_filter_id
		FROM application_ui_filter AS auf
		WHERE auf.application_ui_filter_name = @application_ui_filter_name
			AND auf.report_id = @report_id
			AND auf.user_login_id = @user

		--UPDATE EXISTING FILTER DETAILS
        
		--store to update filter details
		if OBJECT_ID('tempdb..#to_update_filter_detail') is not null
			drop table #to_update_filter_detail
		select dsc.application_ui_filter_details_id,ft.column_name,ft.field_value
		into #to_update_filter_detail
		--ft.*,dsc.*
		FROM #filterTemp ft
		INNER JOIN application_ui_filter AS auf ON ft.report_id = auf.report_id 
		cross apply (
			select aufd.application_ui_filter_details_id,dsc1.data_source_column_id, iif(aufd.book_level='parameter_value2','2_'+dsc1.name,dsc1.name) name
			from application_ui_filter_details aufd
			inner join data_source_column dsc1 on dsc1.data_source_column_id = aufd.report_column_id
			inner join report_param rp on rp.column_id = dsc1.data_source_column_id
			inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id and rdp.paramset_id = auf.report_id
			where aufd.application_ui_filter_id = auf.application_ui_filter_id 
				and iif(aufd.book_level='parameter_value2','2_'+dsc1.name,dsc1.name) = 
				case  
					when ft.column_name='subsidiary_id' then 'sub_id'
					when ft.column_name='strategy_id' then 'stra_id'
					when ft.column_name='subbook_id' then 'sub_book_id'
					else ft.column_name
				end
				

		) dsc
		where auf.application_ui_filter_id = @update_id

		UPDATE aufd
			SET field_value = tufd.field_value
		from application_ui_filter_details aufd
		inner join #to_update_filter_detail tufd on tufd.application_ui_filter_details_id = aufd.application_ui_filter_details_id

		
		UPDATE aufd
		SET aufd.field_value = ft.field_value
		from application_ui_filter_details aufd
		INNER JOIN data_source_column dsc ON dsc.data_source_column_id * -1 = aufd.report_column_id
		INNER JOIN #filterTemp ft  
		ON dsc.name = 
				case 
					when ft.column_name  = 'book_structure' then 'sub_book_id'
					when  ft.column_name like 'label_%' then Replace(ft.column_name, 'label_', '')
				end
		
		where aufd.application_ui_filter_id = @update_id

	END
	ELSE
	BEGIN

		--INSERT FILTER DETAILS
		INSERT INTO application_ui_filter (
			application_group_id,
			report_id,
			user_login_id,
			application_ui_filter_name
		)
		SELECT TOP 1
			application_group_id,
			report_id,
			dbo.FNADBUser(),
			application_ui_filter_name
		FROM #filterTemp

		SET @current_identity_filter_id = SCOPE_IDENTITY()

		SELECT @current_identity_filter_id [id],
			NULL [application_field_id],
			dsc.data_source_column_id,
			ft.field_value,
			ft.column_name,
			case when rpm.operator = 8 and ft.column_name like '2_%' then 'parameter_value2' else null end [book_level]
		INTO #temp_columns
		FROM #filterTemp ft
		INNER JOIN report_paramset rps ON rps.report_paramset_id = ft.report_id --here application_ui_filter (report_id) holds paramset_id, previously hold report_id changed later when view report made paramset level for report manager reports
		INNER JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
		inner join report_dataset rd on rd.report_dataset_id = rdp.root_dataset_id
		INNER JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id
		INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rpm.column_id and rd.source_id = dsc.source_id
		AND dsc.name = 
			case  
				when ft.column_name='subsidiary_id' then 'sub_id'
				when ft.column_name='strategy_id' then 'stra_id'
				when ft.column_name='subbook_id' then 'sub_book_id'
				when rpm.operator = 8 then REPLACE(ft.column_name, '2_', '')
				else ft.column_name
			end
		WHERE rps.report_paramset_id = @report_id


		  
		INSERT INTO application_ui_filter_details (
			application_ui_filter_id,
			application_field_id,
			report_column_id,
			field_value,
			book_level
		)
		SELECT id,
			NULL,
			data_source_column_id,
			field_value,book_level
		FROM #temp_columns

		DECLARE @subbook_column_id INT
		SELECT @subbook_column_id = tc.data_source_column_id * -1
		FROM #temp_columns tc WHERE tc.column_name = 'subbook_id'

		INSERT INTO application_ui_filter_details (
			application_ui_filter_id,
			application_field_id,
			report_column_id,
			field_value
		)
		select @current_identity_filter_id,
			NULL, @subbook_column_id ,ft.field_value 
		from #filterTemp ft 
		where ft.column_name = 'book_structure'

		INSERT INTO application_ui_filter_details (
			application_ui_filter_id,
			application_field_id,
			report_column_id,
			field_value
		)
		SELECT @current_identity_filter_id,
			NULL, tc.data_source_column_id * -1 ,ft.field_value 
		FROM #filterTemp ft
		INNER JOIN #temp_columns tc ON 'Label_' + tc.column_name = ft.column_name
		 
	END
END
ELSE IF @application_function_id IS NOT NULL
BEGIN
	IF EXISTS (
		SELECT 1
		FROM application_ui_filter AS auf
		WHERE auf.application_ui_filter_name = @application_ui_filter_name
		AND auf.application_function_id = @application_function_id
		AND auf.user_login_id = @user
	)
	BEGIN
		SELECT @new_update_id = auf.application_ui_filter_id
		 FROM application_ui_filter AS auf
        WHERE auf.application_ui_filter_name = @application_ui_filter_name
        AND auf.application_function_id = @application_function_id
        AND auf.user_login_id = @user

       	-- INSERT missing field for old filters
		INSERT INTO application_ui_filter_details (
			application_ui_filter_id,
			application_field_id,
			report_column_id,
			field_value
		)
		SELECT auf.application_ui_filter_id,autf.application_field_id,NULL,autd.field_id 
		FROM #filterTemp ft
		INNER JOIN application_ui_filter AS auf ON auf.application_function_id = ft.application_function_id
		INNER JOIN application_ui_template_definition autd ON autd.field_id = ft.column_name AND autd.application_function_id = ft.application_function_id
		INNER JOIN application_ui_template_fields AS autf ON autf.application_ui_field_id = autd.application_ui_field_id
		LEFT JOIN application_ui_filter_details aufd ON aufd.application_field_id = autf.application_field_id AND aufd.application_ui_filter_id = auf.application_ui_filter_id
		WHERE auf.application_ui_filter_name = @application_ui_filter_name
			AND auf.application_function_id = @application_function_id
			AND auf.user_login_id = @user
			AND aufd.application_field_id IS NULL
		
			--UPDATE EXISTING FILTER DETAILS
		UPDATE application_ui_filter_details
		SET field_value = ft.field_value
		FROM #filterTemp ft
		INNER JOIN application_ui_filter AS auf ON ft.application_function_id = auf.application_function_id
		INNER JOIN application_ui_filter_details aufd ON aufd.application_ui_filter_id = auf.application_ui_filter_id
		INNER JOIN application_ui_template_definition AS autd ON autd.field_id = ft.column_name
		INNER JOIN application_ui_template_fields AS autf ON autf.application_ui_field_id = autd.application_ui_field_id
		WHERE auf.user_login_id = @user
			AND auf.application_function_id = @application_function_id
			AND auf.application_ui_filter_name = @application_ui_filter_name
			AND auf.application_ui_filter_id = aufd.application_ui_filter_id
			AND autd.field_id = ft.column_name
			AND aufd.application_field_id = autf.application_field_id

		UPDATE aufd
			SET field_value = ft.field_value
		FROM #filterTemp ft
		LEFT JOIN application_ui_template_definition AS autd ON ft.column_name = autd.field_id 
			AND autd.application_function_id = @application_function_id			
		CROSS APPLY(
			SELECT autf.application_field_id, ft.application_ui_filter_name
			FROM #filterTemp ft
			LEFT JOIN application_ui_template_definition AS autd ON ft.column_name = autd.field_id AND autd.application_function_id = @application_function_id
			INNER JOIN application_ui_template_fields AS autf ON autf.application_ui_field_id = autd.application_ui_field_id
			WHERE ft.column_name = 'book_structure'
		) a
		INNER JOIN application_ui_filter_details aufd ON aufd.application_field_id = a.application_field_id
			AND ft.column_name = aufd.book_level
		INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id
		WHERE autd.application_function_id IS NULL AND a.application_ui_filter_name = auf.application_ui_filter_name
			AND ft.column_name IN('subsidiary_id', 'strategy_id', 'book_id', 'subbook_id')

		UPDATE application_ui_filter_details
		SET field_value = tmp.field_value
		FROM #filterTemp_grid tmp
		INNER JOIN application_ui_filter AS auf ON tmp.application_function_id = auf.application_function_id AND tmp.application_ui_filter_name = auf.application_ui_filter_name
		INNER JOIN application_ui_filter_details aufd ON auf.application_ui_filter_id = aufd.application_ui_filter_id 
			AND tmp.layout_grid_id = aufd.layout_grid_id 
			AND ISNULL(aufd.book_level,'') = ISNULL(tmp.book_level,'')

		INSERT INTO application_ui_filter_details (
			application_ui_filter_id,
			layout_grid_id,
			field_value,
			book_level
		)
		SELECT auf.application_ui_filter_id,
			tmp.layout_grid_id,
			tmp.field_value,
			tmp.book_level	
		FROM #filterTemp_grid tmp
		INNER JOIN application_ui_filter AS auf ON tmp.application_function_id = auf.application_function_id AND tmp.application_ui_filter_name = auf.application_ui_filter_name
		LEFT JOIN application_ui_filter_details aufd  ON auf.application_ui_filter_id = aufd.application_ui_filter_id 
			AND tmp.layout_grid_id = aufd.layout_grid_id 
			AND ISNULL(aufd.book_level,'') = ISNULL(tmp.book_level,'')
		WHERE aufd.application_ui_filter_id  IS NULL	

	END
	ELSE

	BEGIN
		--INSERT FILTER DETAILS
		INSERT INTO application_ui_filter (
			application_group_id,
			application_function_id,
			user_login_id,
			application_ui_filter_name
		)
		SELECT TOP 1
			application_group_id,
			application_function_id,
			dbo.FNADBUser(),
			application_ui_filter_name
		FROM #filterTemp

		IF NOT EXISTS(SELECT 1 FROM #filterTemp)
		BEGIN
			INSERT INTO application_ui_filter (
				application_group_id,
				application_function_id,
				user_login_id,
				application_ui_filter_name
			)
			SELECT TOP 1
				application_group_id,
				application_function_id,
				dbo.FNADBUser(),
				application_ui_filter_name
			FROM #filterTemp_grid
		END

		SET @current_identity_filter_id = SCOPE_IDENTITY()

		INSERT INTO application_ui_filter_details (
			application_ui_filter_id,
			application_field_id,
			report_column_id,
			field_value
		)
		SELECT
			@current_identity_filter_id,
			autf.application_field_id,
			NULL,
			ft.field_value
		FROM #filterTemp ft
		INNER JOIN application_ui_template_definition AS autd ON autd.field_id = ft.column_name
		INNER JOIN application_ui_template_fields AS autf ON autf.application_ui_field_id = autd.application_ui_field_id
		INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
		WHERE autd.application_function_id = @application_function_id
		
		INSERT INTO application_ui_filter_details (application_ui_filter_id, application_field_id, report_column_id, field_value, book_level)
		SELECT	@current_identity_filter_id, 
			a.application_field_id,
			NULL,
			ft.field_value,
			ft.column_name
		FROM #filterTemp ft
		LEFT JOIN application_ui_template_definition AS autd ON ft.column_name = autd.field_id AND autd.application_function_id = @application_function_id
		CROSS APPLY (
			SELECT autf.application_field_id
			FROM #filterTemp ft
			LEFT JOIN application_ui_template_definition AS autd ON ft.column_name = autd.field_id AND autd.application_function_id = @application_function_id
			INNER JOIN application_ui_template_fields AS autf ON autf.application_ui_field_id = autd.application_ui_field_id
			WHERE ft.column_name = 'book_structure'
		) a
		WHERE autd.application_function_id IS NULL
			AND ft.column_name IN('subsidiary_id', 'strategy_id', 'book_id', 'subbook_id')

		INSERT INTO application_ui_filter_details (
			application_ui_filter_id,
			layout_grid_id,
			field_value,
			book_level
		)
		SELECT
			@current_identity_filter_id,
			layout_grid_id,
			tmp.field_value,
			tmp.book_level
		FROM #filterTemp_grid tmp
     
	END
END
declare @recommendation int 
set @recommendation = isnull(@current_identity_filter_id, @new_update_id)

EXEC spa_ErrorHandler 0,
	'Filter update.',
	'spa_application_ui_filter',
	'Success',
	'Changes have been saved successfully.',
	@recommendation
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
	ROLLBACK
	print error_message()

EXEC spa_ErrorHandler -1,
						'Filter update.',
						'spa_application_ui_filter',
						'DB Error',
						'Fail to update Filter.',
						''
END CATCH
END
ELSE
IF @flag = 's'
BEGIN
SELECT
	T.c.value('@name', 'nvarchar(50)') AS application_ui_filter_name,
	T.c.value('@application_group_id', 'int') AS application_group_id,
	T.c.value('@report_id', 'int') AS report_id,
	T.c.value('@application_function_id', 'int') AS application_function_id INTO #filterTemp1
FROM @xml_string.nodes('/ApplicationFilter') AS T (c)
SELECT TOP 1
	@application_ui_filter_name = application_ui_filter_name,
	@report_id = report_id,
	@application_group_id = application_group_id,
	@application_function_id = application_function_id
FROM #filterTemp1

IF @application_function_id IS NOT NULL AND @report_id IS NOT NULL
BEGIN
	SELECT
		application_ui_filter_id [value],
		application_ui_filter_name [text],
		'2' [order]
	FROM application_ui_filter AS auf
	WHERE auf.application_function_id = @application_function_id 
		AND  auf.report_id = @report_id 
		AND (auf.user_login_id = @user OR CHARINDEX('(Public)', application_ui_filter_name ) <> 0 )
	UNION ALL 
	SELECT '-1', 'DEFAULT','1'
	ORDER BY [order],application_ui_filter_name
		
	RETURN;
END

	IF @application_group_id IS NOT NULL
	BEGIN
		SELECT
			application_ui_filter_id [value],
			application_ui_filter_name [text],
			'2' [order]
		FROM application_ui_filter AS auf
		WHERE auf.application_group_id = @application_group_id
		AND (auf.user_login_id = @user OR CHARINDEX('(Public)', application_ui_filter_name ) <> 0 )
		UNION ALL 
		SELECT '-1', 'DEFAULT','1'
		ORDER BY [order],application_ui_filter_name
	END
	IF @report_id IS NOT NULL
	BEGIN
		SELECT
			application_ui_filter_id [value],
			application_ui_filter_name [text],
			'2' [order]
		FROM application_ui_filter AS auf
		WHERE auf.report_id = @report_id
		AND (auf.user_login_id = @user OR CHARINDEX('(Public)', application_ui_filter_name ) <> 0 )
		UNION ALL 
		SELECT '-1', 'DEFAULT','1'
		ORDER BY [order],auf.application_ui_filter_name
	END

	IF @application_function_id IS NOT NULL
	BEGIN
		SELECT
			application_ui_filter_id [value],
			application_ui_filter_name [text],
			'2' [order]
		FROM application_ui_filter AS auf
		WHERE auf.application_function_id = @application_function_id
		AND (auf.user_login_id = @user OR CHARINDEX('(Public)', application_ui_filter_name ) <> 0 )

		UNION ALL 
		SELECT '-1', 'DEFAULT','1'
		ORDER BY [order],application_ui_filter_name
	
	END
END
ELSE
IF @flag = 'a'
BEGIN
	SELECT
	T.c.value('@name', 'nvarchar(50)') AS application_ui_filter_name,
	T.c.value('@application_group_id', 'int') AS application_group_id,
	T.c.value('@report_id', 'int') AS report_id,
	T.c.value('@application_function_id', 'int') AS application_function_id,
	T.c.value('@paramset_id', 'varchar(300)') AS paramset_id 
	INTO #filterTemp2
	FROM @xml_string.nodes('/ApplicationFilter') AS T (c)

	declare @paramset_id varchar(300)
	SELECT TOP 1
	@application_ui_filter_name = application_ui_filter_name,
	@report_id = report_id,
	@application_group_id = application_group_id,
	@application_function_id = application_function_id,
	@paramset_id = paramset_id
	FROM #filterTemp2
	--select * from #filterTemp2
	--return
	
	SELECT @is_public = IIF(CHARINDEX('(Public)', @application_ui_filter_name ) = 0, 0, 1)

IF @application_function_id IS NOT NULL AND @application_ui_filter_name IS NOT NULL AND @report_id IS NOT NULL
BEGIN
	if @application_function_id = 10201700
	begin

		SELECT
			autd.farrms_field_id,
			aufd.field_value
		FROM application_ui_filter AS auf
		INNER JOIN application_ui_filter_details aufd
			ON auf.application_ui_filter_id = aufd.application_ui_filter_id
		INNER JOIN application_ui_template_fields autf
			ON autf.application_field_id = aufd.application_field_id
		INNER JOIN application_ui_template_definition autd
			ON autd.application_ui_field_id = autf.application_ui_field_id
		WHERE auf.application_function_id = @application_function_id
			AND auf.report_id = @report_id
			AND auf.application_ui_filter_name = @application_ui_filter_name
			AND (auf.user_login_id = @user OR @is_public = 1 )
	end

	else if @application_function_id = 10202600 OR @application_function_id = 10202700 --for excel addin reports OR power bi reports
	begin
		SELECT
			case  
 			when dsc.name = 'sub_id' then 'subsidiary_id'
 			when dsc.name = 'stra_id' then 'strategy_id'
 			when aufd.report_column_id < 0 then CASE WHEN dsc.name = 'sub_book_id' THEN 'book_structure' ELSE 'label_' + dsc.name END
 			when dsc.name = 'sub_book_id' then 'subbook_id'
			when aufd.book_level = 'parameter_value2' then '2_' + dsc.name else dsc.name end AS [farrms_field_id],
			aufd.field_value
		FROM application_ui_filter AS auf
		INNER JOIN application_ui_filter_details aufd
			ON auf.application_ui_filter_id = aufd.application_ui_filter_id
			
		INNER JOIN data_source_column dsc
			ON dsc.data_source_column_id = CASE WHEN aufd.report_column_id < 0 THEN aufd.report_column_id * -1 ELSE aufd.report_column_id END
		inner join report_dataset_paramset rdp on rdp.paramset_id in (select scsv.item from dbo.SplitCommaSeperatedValues(@paramset_id) scsv)
		inner join report_param rp on rp.dataset_paramset_id = rdp.report_dataset_paramset_id and rp.column_id = dsc.data_source_column_id
		WHERE auf.report_id = @report_id
			AND auf.application_ui_filter_name = @application_ui_filter_name
			AND (auf.user_login_id = @user OR @is_public = 1 )
			and auf.application_function_id = @application_function_id
	end
	RETURN;

END

	IF (@application_group_id IS NOT NULL)
	AND (@application_ui_filter_name IS NOT NULL)
	BEGIN
	SELECT
		autd.farrms_field_id,
		aufd.field_value
	FROM application_ui_filter AS auf
	INNER JOIN application_ui_filter_details aufd
		ON auf.application_ui_filter_id = aufd.application_ui_filter_id
	INNER JOIN application_ui_template_fields autf
		ON autf.application_field_id = aufd.application_field_id
	INNER JOIN application_ui_template_definition autd
		ON autd.application_ui_field_id = autf.application_ui_field_id
	WHERE auf.application_group_id = @application_group_id
	AND auf.application_ui_filter_name = @application_ui_filter_name
	AND (auf.user_login_id = @user OR @is_public = 1 )
	END
	IF (@report_id IS NOT NULL)
	AND (@application_ui_filter_name IS NOT NULL)
	BEGIN
	SELECT
		case  
 		when dsc.name = 'sub_id' then 'subsidiary_id'
 		when dsc.name = 'stra_id' then 'strategy_id'
 		when aufd.report_column_id < 0 then CASE WHEN dsc.name = 'sub_book_id' THEN 'book_structure' ELSE 'label_' + dsc.name END
 		when dsc.name = 'sub_book_id' then 'subbook_id'
		when aufd.book_level = 'parameter_value2' then '2_' + dsc.name else dsc.name end AS [farrms_field_id],
		aufd.field_value
	FROM application_ui_filter AS auf
	INNER JOIN application_ui_filter_details aufd
		ON auf.application_ui_filter_id = aufd.application_ui_filter_id
	INNER JOIN report_paramset rps
		ON rps.report_paramset_id = auf.report_id
	INNER JOIN data_source_column dsc
		ON dsc.data_source_column_id = CASE WHEN aufd.report_column_id < 0 THEN aufd.report_column_id * -1 ELSE aufd.report_column_id END
	inner join report_dataset_paramset rdp on rdp.paramset_id = rps.report_paramset_id
	inner join report_param rp on rp.dataset_paramset_id = rdp.report_dataset_paramset_id and rp.column_id = dsc.data_source_column_id
	WHERE auf.report_id = @report_id
	AND auf.application_ui_filter_name = @application_ui_filter_name
	AND (auf.user_login_id = @user OR @is_public = 1 )

	END
	IF (@application_function_id IS NOT NULL)
	AND (@application_ui_filter_name IS NOT NULL)
	BEGIN
	--drop table #temp_filter_data
	CREATE TABLE #temp_filter_data(application_field_id INT, farrms_field_id VARCHAR(255) COLLATE DATABASE_DEFAULT, field_value VARCHAR(MAX) COLLATE DATABASE_DEFAULT, default_format VARCHAR(200) COLLATE DATABASE_DEFAULT, grid_id VARCHAR(255) COLLATE DATABASE_DEFAULT, field_type VARCHAR(255) COLLATE DATABASE_DEFAULT)
       
	IF @application_ui_filter_name = 'DEFAULT'
	BEGIN
		INSERT INTO #temp_filter_data(application_field_id, farrms_field_id, field_value, default_format, grid_id, field_type)
		SELECT
			autf.application_field_id,
			autd.farrms_field_id,
			ISNULL(autd.default_value,''),
			autf.default_format,
			autf.grid_id,
			autf.field_type 
		FROM application_ui_template_fields autf
		INNER JOIN application_ui_template_definition autd
			ON autd.application_ui_field_id = autf.application_ui_field_id
		WHERE autd.application_function_id = @application_function_id
	END
	ELSE
	BEGIN
		INSERT INTO #temp_filter_data(application_field_id, farrms_field_id, field_value, default_format, grid_id, field_type)
		SELECT
			autf.application_field_id,
			CASE WHEN autd.farrms_field_id = 'book_structure' THEN CASE WHEN aufd.book_level IS NOT NULL THEN aufd.book_level ELSE autd.farrms_field_id END
				ELSE autd.farrms_field_id END [farrms_field_id],
			aufd.field_value,
			autf.default_format,
			autf.grid_id,
			autf.field_type 
		FROM application_ui_filter AS auf
		INNER JOIN application_ui_filter_details aufd
			ON auf.application_ui_filter_id = aufd.application_ui_filter_id
		INNER JOIN application_ui_template_fields autf
			ON autf.application_field_id = aufd.application_field_id
		INNER JOIN application_ui_template_definition autd
			ON autd.application_ui_field_id = autf.application_ui_field_id
		WHERE auf.application_function_id = @application_function_id
		AND auf.application_ui_filter_name = @application_ui_filter_name
		AND (auf.user_login_id = @user OR @is_public = 1 )
	END
	   

	-- Resolve Book Structure Browser Label
	DECLARE	@field_id VARCHAR(50)
			, @field_value NVARCHAR(MAX) 
			, @book_structure VARCHAR(MAX) = ''

	SELECT @field_id = tfd.farrms_field_id, @field_value = tfd.field_value
	FROM #temp_filter_data tfd
	WHERE tfd.field_type = 'browser' AND (tfd.grid_id = 'book' OR tfd.grid_id IS NULL)
		AND tfd.farrms_field_id IN ('book_id', 'subbook_id')
		AND NULLIF(tfd.field_value, '') IS NOT NULL

	IF @field_id IS NOT NULL AND @field_value IS NOT NULL
	BEGIN
		EXEC spa_getBookStructureLabel @field_id, @field_value, @book_structure OUTPUT

		UPDATE tfd
			SET field_value = @book_structure
		FROM #temp_filter_data tfd
		WHERE tfd.field_type = 'browser' AND tfd.farrms_field_id = 'book_structure'
	END

	-- Resolve the Grid Browser Labels
	DECLARE @farrms_field_id VARCHAR(255), @grid_id VARCHAR(100), @application_field_id INT
	DECLARE fields_cursor CURSOR FOR
		SELECT
			tfd.application_field_id,
			tfd.farrms_field_id,
			tfd.field_value,
			tfd.grid_id
		FROM #temp_filter_data tfd
		WHERE tfd.grid_id NOT IN ('book', 'deal_search') AND tfd.field_type = 'browser'
			AND NULLIF(tfd.field_value, '') IS NOT NULL
	OPEN fields_cursor
	FETCH NEXT FROM fields_cursor INTO @application_field_id, @farrms_field_id, @field_value, @grid_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE  @grid_sql	VARCHAR(500)
				, @grid_cols VARCHAR(1000) = NULL
				, @grid_col_label VARCHAR(500)
				, @grid_col1	VARCHAR(50)
				, @grid_col2	VARCHAR(50)
				, @tbl VARCHAR(255)
				, @grid_name VARCHAR(255)
				, @grid_label VARCHAR(255)
				, @sql NVARCHAR(MAX)

		SELECT
			@grid_name = agd.grid_name,
			@grid_label = agd.grid_label,
			@grid_sql = agd.load_sql,
			@grid_cols = COALESCE(@grid_cols + ', ', '') + CAST(agc.column_name AS VARCHAR(50)) + ' VARCHAR(max) COLLATE DATABASE_DEFAULT '						 
		FROM application_ui_template_fields autf
		INNER JOIN adiha_grid_definition agd
			ON (CAST(autf.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)) OR (CAST(autf.grid_id AS VARCHAR) = CAST(agd.grid_name AS VARCHAR))
		INNER JOIN adiha_grid_columns_definition agc ON CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
		WHERE autf.application_field_id = @application_field_id
		ORDER BY agc.column_order ASC
									
		SELECT @grid_col1 = c1.column_name
		FROM (SELECT ROW_NUMBER() 
				OVER (ORDER BY agc.column_order) AS Row,  agc.column_name
		FROM application_ui_template_fields autf
		INNER JOIN adiha_grid_definition agd
			ON (CAST(autf.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)) OR (CAST(autf.grid_id AS VARCHAR) = CAST(agd.grid_name AS VARCHAR))
		INNER JOIN adiha_grid_columns_definition agc ON agc.grid_id = agd.grid_id
		WHERE autf.application_field_id = @application_field_id) c1 WHERE c1.row = 1
						
		SELECT @grid_col2 = c2.column_name
		FROM (SELECT ROW_NUMBER() 
				OVER (ORDER BY agc.column_order) AS Row,  agc.column_name
		FROM application_ui_template_fields autf
		INNER JOIN adiha_grid_definition agd
			ON (CAST(autf.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)) OR (CAST(autf.grid_id AS VARCHAR) = CAST(agd.grid_name AS VARCHAR))
		INNER JOIN adiha_grid_columns_definition agc ON agc.grid_id = agd.grid_id
		WHERE autf.application_field_id = @application_field_id) c2 WHERE c2.row = 2
		
		SET @tbl = dbo.FNAProcessTableName('grid_data', @user, dbo.FNAGetNewID())
		EXEC ('CREATE TABLE ' + @tbl + '(row_id INT IDENTITY(1,1),' + @grid_cols + ')')
		
		SET @sql = 'INSERT INTO ' + @tbl + '
					EXEC(''' + REPLACE(REPLACE(@grid_sql, '''', ''''''), '<FILTER_VALUE>', @field_value)  + ''')'
		EXEC(@sql)
		
		SET @sql = '
					DECLARE @browser_label VARCHAR(MAX)
					SELECT @browser_label = ISNULL(@browser_label + '','', '''') + a.' + @grid_col2 + ' 
					FROM ' + @tbl + 
					' a	 WHERE  1 = 1'
		IF @field_value is NOT NULL
			SET @sql += ' AND ' +  @grid_col1 + ' IN (' + @field_value + ')
				  SELECT ''label_' + @farrms_field_id + ''' farrms_field_id, @browser_label field_value, NULL default_format
				'
	    INSERT INTO #temp_filter_data(farrms_field_id, field_value, default_format)
		EXEC(@sql)

		FETCH NEXT FROM fields_cursor INTO @application_field_id, @farrms_field_id, @field_value, @grid_id
	END
	CLOSE fields_cursor
	DEALLOCATE fields_cursor

	SELECT farrms_field_id, field_value, default_format FROM #temp_filter_data

	END
END
ELSE
IF @flag = 'd'
BEGIN

SELECT
	T.c.value('@name', 'nvarchar(50)') AS application_ui_filter_name,
	T.c.value('@application_group_id', 'int') AS application_group_id,
	T.c.value('@report_id', 'int') AS report_id,
	T.c.value('@application_function_id', 'int') AS application_function_id INTO #filterTemp3
FROM @xml_string.nodes('/ApplicationFilter') AS T (c)
SELECT TOP 1
	@application_ui_filter_name = nullif(application_ui_filter_name,''),
	@report_id = nullif(report_id,''),
	@application_group_id = nullif(application_group_id,''),
	@application_function_id = nullif(application_function_id,'')
FROM #filterTemp3

SELECT @filter_created_user = create_user 
FROM application_ui_filter 
WHERE application_ui_filter_name = @application_ui_filter_name
	AND user_login_id = @user


DECLARE @can_delete BIT = 1
SELECT @can_delete = IIF(CHARINDEX('(Public)', @application_ui_filter_name ) <> 0 
					AND @user <> ISNULL(@filter_created_user, '-1'), 0, 1)


IF @can_delete = 0
BEGIN 		
	EXEC spa_ErrorHandler -1,
					'Filter publish.',
					'spa_application_ui_filter',
					'DB Error',
					'Fail to delete public filter.',
					''

	RETURN;
END 

IF (@application_ui_filter_name IS NOT NULL)
BEGIN
BEGIN TRY
		
	--excel addin reports apply filter delete
	IF ISNULL(@application_function_id,0) = 10202600 and @report_id is not null
	begin
		DECLARE @delete_id1 INT
		SELECT @delete_id1 = auf.application_ui_filter_id
		FROM application_ui_filter AS auf
		WHERE auf.application_ui_filter_name = @application_ui_filter_name
		AND auf.report_id = @report_id
		AND auf.user_login_id = @user
		and auf.application_function_id = 10202600

		DELETE aufd
		FROM application_ui_filter AS auf
		INNER JOIN application_ui_filter_details aufd ON auf.application_ui_filter_id = aufd.application_ui_filter_id
		WHERE auf.application_ui_filter_id = @delete_id1

		DELETE FROM application_ui_filter
		WHERE application_ui_filter_id = @delete_id1
	end
	
	if isnull(@application_function_id,0) = 10202700 and @report_id is not null
	begin
		DECLARE @delete_id2 INT
		SELECT @delete_id2 = auf.application_ui_filter_id
		FROM application_ui_filter AS auf
		WHERE auf.application_ui_filter_name = @application_ui_filter_name
		AND auf.report_id = @report_id
		AND auf.user_login_id = @user
		and auf.application_function_id = 10202700

		DELETE aufd
		FROM application_ui_filter AS auf
		INNER JOIN application_ui_filter_details aufd ON auf.application_ui_filter_id = aufd.application_ui_filter_id
		WHERE auf.application_ui_filter_id = @delete_id2

		DELETE FROM application_ui_filter
		WHERE application_ui_filter_id = @delete_id2
	end
		
	ELSE IF (@application_group_id IS NOT NULL AND @report_id IS NULL AND @application_function_id IS NULL) --menu forms apply filter delete
	BEGIN
		DELETE aufd
		FROM application_ui_filter AS auf
		INNER JOIN application_ui_filter_details aufd
			ON auf.application_ui_filter_id = aufd.application_ui_filter_id
		--INNER JOIN application_ui_template_fields autf
		--  ON autf.application_field_id = aufd.application_field_id
		--INNER JOIN application_ui_template_definition autd
		--  ON autd.application_ui_field_id = autf.application_ui_field_id
		WHERE auf.application_group_id = @application_group_id
		AND auf.application_ui_filter_name = @application_ui_filter_name
		AND auf.user_login_id = @user

		DELETE FROM application_ui_filter
		WHERE application_group_id = @application_group_id
		AND application_ui_filter_name = @application_ui_filter_name
		AND user_login_id = @user
	END

	ELSE IF (@report_id IS NOT NULL AND @application_function_id IS NULL) --report manager reports apply filter delete
	BEGIN
		DECLARE @delete_id INT
		SELECT @delete_id = auf.application_ui_filter_id
		FROM application_ui_filter AS auf
		WHERE auf.application_ui_filter_name = @application_ui_filter_name
		AND auf.report_id = @report_id
		AND auf.user_login_id = @user

		DELETE aufd
		FROM application_ui_filter AS auf
		INNER JOIN application_ui_filter_details aufd ON auf.application_ui_filter_id = aufd.application_ui_filter_id
		WHERE auf.application_ui_filter_id = @delete_id

		DELETE FROM application_ui_filter
		WHERE application_ui_filter_id = @delete_id
	END

	ELSE IF (@application_function_id IS NOT NULL AND @report_id IS NULL) --standards reports apply filter delete
	BEGIN
		DELETE aufd
		FROM application_ui_filter AS auf
		INNER JOIN application_ui_filter_details aufd
			ON auf.application_ui_filter_id = aufd.application_ui_filter_id
		--INNER JOIN application_ui_template_fields autf
		--  ON autf.application_field_id = aufd.application_field_id
		--INNER JOIN application_ui_template_definition autd
		--  ON autd.application_ui_field_id = autf.application_ui_field_id
		WHERE auf.application_function_id = @application_function_id
		AND auf.application_ui_filter_name = @application_ui_filter_name
		AND auf.user_login_id = @user

		DELETE FROM application_ui_filter
		WHERE application_function_id = @application_function_id
		AND application_ui_filter_name = @application_ui_filter_name
		AND user_login_id = @user
	END
	EXEC spa_ErrorHandler 0,
			'Filter update.',
			'spa_application_ui_filter',
			'Success',
			'Changes have been saved successfully.',
				''
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK

	EXEC spa_ErrorHandler -1,
						'Filter update.',
						'spa_application_ui_filter',
						'DB Error',
						'Fail to delete Filter.',
						''
END CATCH
END  
END

IF @flag = 'g'
BEGIN
SELECT application_ui_layout_grid_id [layout_grid_id], grid_object_name [grid_object], grid_object_unique_column [column_name]  
FROM application_ui_layout_grid aulg
INNER JOIN application_ui_template_group autg ON autg.application_group_id = aulg.group_id
INNER JOIN application_ui_template aut ON autg.application_ui_template_id = aut.application_ui_template_id
WHERE aut.application_function_id = @function_id AND grid_object_name IS NOT NULL
END


IF @flag = 'b'
BEGIN
	SELECT
	T.c.value('@name', 'nvarchar(50)') AS application_ui_filter_name,
	T.c.value('@application_function_id', 'int') AS application_function_id INTO #filterTemp4
	FROM @xml_string.nodes('/ApplicationFilter') AS T (c)
	SELECT TOP 1
	@application_ui_filter_name = application_ui_filter_name,
	@application_function_id = application_function_id
	FROM #filterTemp4


	--SELECT aulg.grid_object_name, 
	--	CASE WHEN aulg.grid_object_unique_column = 'book' THEN aufd.book_level ELSE aulg.grid_object_unique_column END [grid_object_unique_column], 
	--	aufd.field_value,
	--	CASE WHEN aulg.grid_object_unique_column = 'book' THEN 'y' ELSE 'n' END [is_book]
	--FROM application_ui_filter_details aufd
	--INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id 
	--AND auf.application_function_id = @application_function_id AND auf.application_ui_filter_name = @application_ui_filter_name
	--INNER JOIN application_ui_layout_grid aulg ON aulg.application_ui_layout_grid_id = aufd.layout_grid_id
	--WHERE aufd.layout_grid_id IS NOT NULL 

		
	SELECT TOP 1 aulg.grid_object_name, 
			aufd.book_level  [grid_object_unique_column], 
			IIF(@application_ui_filter_name = 'DEFAULT', '', aufd.field_value) [field_value],
			'y'  [is_book]
	INTO #book_filter
	FROM application_ui_filter_details aufd
	INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id 
		AND auf.application_function_id = @application_function_id AND auf.application_ui_filter_name = IIF(@application_ui_filter_name = 'DEFAULT', auf.application_ui_filter_name, @application_ui_filter_name)
	INNER JOIN application_ui_layout_grid aulg ON aulg.application_ui_layout_grid_id = aufd.layout_grid_id
	WHERE aufd.layout_grid_id IS NOT NULL  AND aulg.grid_object_unique_column = 'book'
	AND aufd.book_level IN ('book','subbook') AND (NULLIF(aufd.field_value, '') IS NOT NULL OR aufd.book_level <> 'subbook')
	ORDER BY [grid_object_unique_column] DESC

	SELECT grid_object_name,
		grid_object_unique_column,
		field_value,
		is_book
	FROM #book_filter
	UNION
	SELECT aulg.grid_object_name, 
		aulg.grid_object_unique_column, 
		IIF(@application_ui_filter_name = 'DEFAULT', '', aufd.field_value) [field_value],
		'n'  [is_book]
	FROM application_ui_filter_details aufd
	INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id 
	AND auf.application_function_id = @application_function_id AND auf.application_ui_filter_name = IIF(@application_ui_filter_name = 'DEFAULT', auf.application_ui_filter_name, @application_ui_filter_name)
	INNER JOIN application_ui_layout_grid aulg ON aulg.application_ui_layout_grid_id = aufd.layout_grid_id
	WHERE aufd.layout_grid_id IS NOT NULL  AND aulg.grid_object_unique_column <> 'book'
END

IF @flag = 'p'
BEGIN

IF EXISTS ( 
				SELECT 1 
				FROM application_ui_filter 
				WHERE application_ui_filter_id = @filter_id
					AND @is_public = 1 
					AND @user <> create_user				
			)
BEGIN 		
	EXEC spa_ErrorHandler -1,
					'Filter publish.',
					'spa_application_ui_filter',
					'DB Error',
					'Only owner of the filter can update it.',
					'Not Owner'

	RETURN;
END 


	IF EXISTS ( 
				SELECT 1 
				FROM application_ui_filter 
				WHERE application_ui_filter_id = @filter_id
					AND @is_public = 1 
					AND @user = create_user				
			)
	BEGIN
		UPDATE application_ui_filter
		SET application_ui_filter_name = REPLACE(application_ui_filter_name, ' (Public)', '') 
		WHERE application_ui_filter_id = @filter_id
	END	

	SELECT
		T.c.value('@user_login_id', 'varchar(500)') AS user_login_id,
		T.c.value('@role_id', 'varchar(500)') AS role_id
	INTO #filterPublish
	FROM @xml_string.nodes('/ApplicationFilter/UserRole') AS T (c)

	INSERT INTO #filterPublish (user_login_id, role_id)
	SELECT aru.user_login_id,aru.role_id FROM #filterPublish tmp
	INNER JOIN application_role_user aru ON tmp.role_id = aru.role_id

	DECLARE @filter_name NVARCHAR(200), @app_function_id VARCHAR(10), @app_report_id INT, @group_id INT, @role_id INT
	DECLARE @new_filter_id INT
	DECLARE @publish_user VARCHAR(200)

	SELECT	@group_id = auf.application_group_id,
				@app_report_id = auf.report_id,
				@filter_name = auf.application_ui_filter_name,
				@app_function_id = auf.application_function_id		
		FROM application_ui_filter auf WHERE auf.application_ui_filter_id = @filter_id
		

	CREATE TABLE #temp_delete_filters(application_ui_filter_id int )
	
	IF NOT EXISTS(SELECT 1 FROM #filterPublish)
	BEGIN
		INSERT INTO #temp_delete_filters(application_ui_filter_id)
		SELECT auf.application_ui_filter_id  
		FROM application_ui_filter auf 
		
		WHERE 
			 (auf.application_function_id = @app_function_id OR auf.report_id = @app_report_id )
			AND  auf.application_ui_filter_name = @filter_name
			AND auf.create_user <> auf.user_login_id
	END

	ELSE
	BEGIN
	DECLARE publish_cursor CURSOR FOR
		SELECT
			fp.user_login_id, NULLIF(fp.role_id,0)
		FROM #filterPublish fp
		WHERE fp.user_login_id <> ''
	OPEN publish_cursor
	FETCH NEXT FROM publish_cursor INTO @publish_user, @role_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @new_filter_id = '';
			
		IF NOT EXISTS(SELECT 1 FROM application_ui_filter
		WHERE application_ui_filter_name = @filter_name AND user_login_id = @publish_user AND ISNULL(role_id,'') = ISNULL(@role_id,'')
		AND (application_function_id = @app_function_id OR report_id = @app_report_id OR application_group_id = @group_id))
		BEGIN

			INSERT INTO application_ui_filter(application_group_id, report_id, user_login_id, application_ui_filter_name,application_function_id, role_id) 
			SELECT	@group_id,
					@app_report_id,
					@publish_user,
					@filter_name,
					@app_function_id,
					@role_id

			SET @new_filter_id = SCOPE_IDENTITY()


			INSERT INTO application_ui_filter_details (application_ui_filter_id, application_field_id, report_column_id, field_value, layout_grid_id, book_level)
			SELECT	@new_filter_id,
					aufd.application_field_id,
					aufd.report_column_id,
					aufd.field_value,
					aufd.layout_grid_id,
					aufd.book_level
			FROM application_ui_filter_details aufd WHERE aufd.application_ui_filter_id = @filter_id

		END
		FETCH NEXT FROM publish_cursor INTO @publish_user, @role_id
	END
	CLOSE publish_cursor
	DEALLOCATE publish_cursor


	INSERT INTO #temp_delete_filters(application_ui_filter_id)
	SELECT auf.application_ui_filter_id 
		FROM application_ui_filter auf 
		LEFT JOIN #filterPublish fp ON auf.user_login_id = fp.user_login_id AND NULLIF(fp.role_id,'') IS NULL
		WHERE fp.user_login_id IS NULL 
					AND (auf.application_function_id = @app_function_id OR auf.report_id = @app_report_id )
			AND auf.application_ui_filter_name = @filter_name
			AND auf.create_user <> auf.user_login_id 
			AND NULLIF(auf.role_id,'') IS NULL
	
			UNION

	SELECT auf.application_ui_filter_id 
		FROM application_ui_filter auf 
		LEFT JOIN #filterPublish fp ON auf.role_id = fp.role_id
		WHERE fp.user_login_id IS NULL 
					AND (auf.application_function_id = @app_function_id OR auf.report_id = @app_report_id )
			AND auf.application_ui_filter_name = @filter_name
			--AND auf.create_user <> auf.user_login_id 
			AND NULLIF(auf.role_id,'') IS not NULL

	END
	
	DELETE aufd FROM #temp_delete_filters tdf 
		INNER JOIN application_ui_filter_details aufd 
		ON tdf.application_ui_filter_id = aufd.application_ui_filter_id

	DELETE auf FROM #temp_delete_filters tdf 
		INNER JOIN application_ui_filter auf 
		ON tdf.application_ui_filter_id = auf.application_ui_filter_id
	 

	EXEC spa_ErrorHandler 0,
						'Filter publish.',
						'spa_application_ui_filter',
						'Success',
						'Changes have been saved successfully.',
						''

END

IF @flag = 'k'
BEGIN
	DECLARE @application_filter_name VARCHAR(200)
	SELECT  @application_filter_name =  application_ui_filter_name FROM application_ui_filter WHERE  application_ui_filter_id = @filter_id
	
	SELECT auf.user_login_id
		, au.user_f_name + ' ' + ISNULL(au.user_m_name, '') + ' ' + au.user_l_name AS name 
		FROM application_ui_filter auf INNER JOIN application_users au ON auf.user_login_id = au.user_login_id
	WHERE (auf.application_function_id = @function_id OR auf.report_id = @function_id ) AND auf.application_ui_filter_name = @application_filter_name AND auf.user_login_id <> auf.create_user AND auf.role_id IS NULL
END

IF @flag = 'l'
BEGIN
	DECLARE @app_filter_name VARCHAR(200)
	SELECT  @app_filter_name =  application_ui_filter_name FROM application_ui_filter WHERE  application_ui_filter_id = @filter_id

	SELECT asr.role_id, asr.role_name 
	FROM application_ui_filter auf INNER JOIN application_security_role asr ON auf.role_id = asr.role_id 
	WHERE auf.role_id IS NOT NULL AND (auf.application_function_id = @function_id OR auf.report_id = @function_id) AND auf.application_ui_filter_name = @app_filter_name GROUP BY asr.role_id ,asr.role_name
END

IF @flag = 'e'
BEGIN
	IF EXISTS ( 
				SELECT 1 
				FROM application_ui_filter 
				WHERE application_ui_filter_id = @filter_id
					AND @is_public = 1 
			)
	BEGIN
		EXEC spa_ErrorHandler -1,
						'Filter publish.',
						'spa_application_ui_filter',
						'DB Error',
						'The filter has already been made public.',
						@is_public
		RETURN
	END 
	ELSE
	BEGIN
	UPDATE application_ui_filter
		SET application_ui_filter_name = application_ui_filter_name + ' (Public)'
	WHERE application_ui_filter_id = @filter_id 
	AND CHARINDEX('(Public)', application_ui_filter_name ) = 0
	
	EXEC spa_ErrorHandler 0,
						'Filter publish.',
						'spa_application_ui_filter',
						'Success',
						'Changes have been saved successfully.',
						''
	END
END


GO
