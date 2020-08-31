/****** Object:  StoredProcedure [dbo].[spa_contract_group]    Script Date: 04/12/2009 20:40:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_contract_group]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_contract_group]

/****** Object:  StoredProcedure [dbo].[spa_contract_group]    Script Date: 04/12/2009 20:40:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spa_contract_group]
	@flag char(1),
	@sub_id int=NULL,
	@contract_id VARCHAR(1000)=NULL,
	@contract_name varchar(100) =NULL,
	@contract_date datetime=NULL,
	@receive_invoice char(1) =NULL,
	@settlement_accountant varchar(50) =NULL,
	@billing_cycle int =NULL,
	@invoice_due_date int =NULL,
	@name varchar(50) =NULL,
	@company varchar(100) =NULL,
	@state int =NULL,
	@city varchar(20) =NULL,
	@zip varchar(20) =NULL,
	@address varchar(100) =NULL,
	@telephone varchar(20) =NULL,
	@email varchar(50) =NULL,
	@hourly_block int=NULL,
	@volume_granularity int=NULL,
	@currency int=NULL,
	@volume_mult float=NULL,
	@onpeak_mult float=NULL,
	@offpeak_mult float=NULL,
	@type char(1)=NULL,
	@reverse_entries char(1)=null,
	@volume_uom int=null,
	@rec_uom  int=null,
	@contract_specialist varchar(50)=null,
	@address2 varchar(100) =NULL,
	@fax varchar(100)=null,
	@name2 varchar(50) =NULL,
	@company2 varchar(100) =NULL,
	@telephone2 varchar(20) =NULL,
	@fax2 varchar(20)=null,
	@email2 varchar(50) =NULL,
	@term_start datetime=null,
	@term_end datetime=null,
	@energy_type varchar(1)=null,
	@book_id int=null,
	@area_engineer varchar(100)=null,
	@metering_contract varchar(100)=null,
	@miso_queue_number varchar(100)=null,
	@substation_name varchar(100)=null,
	@project_county varchar(100)=null,
	@voltage varchar(100)=null,
	@time_zone int=null,
	@contract_service_agreement_id varchar(50)=null,
	@contract_charge_type_id int=null,
	@billing_from_date int=null,
	@billing_to_date int=null,
	@contract_report_template int=null,
	@Subledger_code varchar(20)=null,
	@UD_Contract_id varchar(50)=null,	
	@extension_provision_description varchar(100)=null,
	@term_name varchar(10)=null,
	@increment_name varchar(10)=null,
	@ferct_tarrif_reference varchar(50)=null,
	@point_of_delivery_control_area varchar(100)=null,
	@point_of_delivery_specific_location varchar(100)=null,
	@contract_affiliate	varchar(1)=null,
	@point_of_receipt_control_area	varchar(100)=null,
	@point_of_receipt_specific_location	varchar(100)=null,
	@no_meterdata varchar(1)=null,
	@billing_start_month int=null,
	@increment_period int=null,
	@bookout_provision char(1)=null,
	@contract_status INT=NULL,
	@holiday_calendar_id int= null,
	@billing_from_hour INT=NULL,
	@billing_to_hour INT=NULL,
	@is_active CHAR(1) = NULL,
	@payment_calendar INT = NULL,
	@pnl_date INT = NULL,
	@pnl_calendar INT = NULL,
	@settlement_calendar INT = NULL,
	@settlement_date INT = NULL,
	@pipeline VARCHAR(1000) = NULL,
	@flow_start_date DATETIME = NULL,
	@flow_end_date DATETIME = NULL,
	@settlement_rule INT = NULL,
	@path INT = NULL,
	@capacity_release CHAR(1) = NULL,
	@deal VARCHAR(1000) = NULL,
	@interruptible CHAR(1) = NULL,
	@contract_type VARCHAR(100) = NULL,
	@maintain_rate_schedule INT = NULL,
	@transportation_contract CHAR(1) = NULL,
	@neting_rule CHAR(1) = NULL,
	@invoice_report_template INT= NULL,
	@payment_day INT = NULL,
	@settlement_day INT = NULL,
	@self_billing CHAR(1) = NULL,
	@netting_template INT = NULL,
	@source_system_id INT = NULL,
	@contract_type_def_id varchar(500) = NULL,
	@counterparty_id VARCHAR(8000) = NULL,
	@filter_value VARCHAR(1000) = NULL
AS
/*-----------------Debug Section------------------
DECLARE	@flag char(1),
		@sub_id int=NULL,
		@contract_id VARCHAR(1000)=NULL,
		@contract_name varchar(100) =NULL,
		@contract_date datetime=NULL,
		@receive_invoice char(1) =NULL,
		@settlement_accountant varchar(50) =NULL,
		@billing_cycle int =NULL,
		@invoice_due_date int =NULL,
		@name varchar(50) =NULL,
		@company varchar(100) =NULL,
		@state int =NULL,
		@city varchar(20) =NULL,
		@zip varchar(20) =NULL,
		@address varchar(100) =NULL,
		@telephone varchar(20) =NULL,
		@email varchar(50) =NULL,
		@hourly_block int=NULL,
		@volume_granularity int=NULL,
		@currency int=NULL,
		@volume_mult float=NULL,
		@onpeak_mult float=NULL,
		@offpeak_mult float=NULL,
		@type char(1)=NULL,
		@reverse_entries char(1)=null,
		@volume_uom int=null,
		@rec_uom  int=null,
		@contract_specialist varchar(50)=null,
		@address2 varchar(100) =NULL,
		@fax varchar(100)=null,
		@name2 varchar(50) =NULL,
		@company2 varchar(100) =NULL,
		@telephone2 varchar(20) =NULL,
		@fax2 varchar(20)=null,
		@email2 varchar(50) =NULL,
		@term_start datetime=null,
		@term_end datetime=null,
		@energy_type varchar(1)=null,
		@book_id int=null,
		@area_engineer varchar(100)=null,
		@metering_contract varchar(100)=null,
		@miso_queue_number varchar(100)=null,
		@substation_name varchar(100)=null,
		@project_county varchar(100)=null,
		@voltage varchar(100)=null,
		@time_zone int=null,
		@contract_service_agreement_id varchar(50)=null,
		@contract_charge_type_id int=null,
		@billing_from_date int=null,
		@billing_to_date int=null,
		@contract_report_template int=null,
		@Subledger_code varchar(20)=null,
		@UD_Contract_id varchar(50)=null,	
		@extension_provision_description varchar(100)=null,
		@term_name varchar(10)=null,
		@increment_name varchar(10)=null,
		@ferct_tarrif_reference varchar(50)=null,
		@point_of_delivery_control_area varchar(100)=null,
		@point_of_delivery_specific_location varchar(100)=null,
		@contract_affiliate	varchar(1)=null,
		@point_of_receipt_control_area	varchar(100)=null,
		@point_of_receipt_specific_location	varchar(100)=null,
		@no_meterdata varchar(1)=null,
		@billing_start_month int=null,
		@increment_period int=null,
		@bookout_provision char(1)=null,
		@contract_status INT=NULL,
		@holiday_calendar_id int= null,
		@billing_from_hour INT=NULL,
		@billing_to_hour INT=NULL,
		@is_active CHAR(1) = NULL,
		@payment_calendar INT = NULL,
		@pnl_date INT = NULL,
		@pnl_calendar INT = NULL,
		@settlement_calendar INT = NULL,
		@settlement_date INT = NULL,
		@pipeline VARCHAR(1000) = NULL,
		@flow_start_date DATETIME = NULL,
		@flow_end_date DATETIME = NULL,
		@settlement_rule INT = NULL,
		@path INT = NULL,
		@capacity_release CHAR(1) = NULL,
		@deal VARCHAR(1000) = NULL,
		@interruptible CHAR(1) = NULL,
		@contract_type VARCHAR(100) = NULL,
		@maintain_rate_schedule INT = NULL,
		@transportation_contract CHAR(1) = NULL,
		@neting_rule CHAR(1) = NULL,
		@invoice_report_template INT= NULL,
		@payment_day INT = NULL,
		@settlement_day INT = NULL,
		@self_billing CHAR(1) = NULL,
		@netting_template INT = NULL,
		@source_system_id INT = NULL,
		@counterparty_id VARCHAR(8000) = NULL
SELECT  @flag='c',@contract_id='8209'
------------------------------------------------------*/
SET NOCOUNT ON;
BEGIN	
	DECLARE @sql varchar(8000)
	
	DECLARE @Sql_Select VARCHAR(5000)
	SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')

	IF @source_system_id IS NULL
		SET @source_system_id=2
	--select sub_id from book
	IF OBJECT_ID('tempdb..#sub_book') IS NOT NULL
		DROP TABLE #sub_book
	CREATE TABLE #sub_book(
		sub_id INT,
		book_id INT
	)

	if @book_id is not null
		insert into #sub_book
		select 
				sub.entity_id sub_id,
				book.entity_id book_id
		from 
			portfolio_hierarchy book
			inner join portfolio_hierarchy stra on book.parent_entity_id=stra.entity_id
			inner join portfolio_hierarchy sub on stra.parent_entity_id=sub.entity_id
		where
			book.entity_id=@book_id
	
	/*
	*	Privilege Change
	*/
	IF @flag IN('r', 'b', 'p', 'n', 'o')
	BEGIN
		CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT)
		EXEC spa_static_data_privilege @flag = 'p', @source_object = 'contract'
	END
	-------------------------------------
	IF @flag='s'
	BEGIN
	set @sql='select contract_id [ID],
		contract_name '+CASE WHEN @contract_type = 'm' THEN '[Model Name]' ELSE '[Contract Name]' END+',
		ph.entity_name [Subsidiary],
		dbo.FNADateformat(contract_date) [Contract Date],
		case receive_invoice  when ''y'' then ''Yes'' else ''No'' end as [Receive Invoice],
		sd2.code as [Volume Granularity],
		sc.currency_name as Currency,
		su.uom_name as UOM,
		ISNULL(au2.user_l_name+'','','''')+isnull(au2.user_f_name,'''')+'' ''+isnull(au2.user_m_name,'''') as [Contract Specialist],
		dbo.FNADateformat(cg.term_start) as [Term Start],
		dbo.FNADateformat(cg.term_end) as [Term End],
		ISNULL(au.user_l_name+'','','''')+isnull(au.user_f_name,'''')+'' ''+isnull(au.user_m_name,'''') [Accountant],
		sd.code [Billing Cycle],sd1.code [Invoice Due Date],
		cg.name as [Contact Name],
		cg.company as [Company],
		cg.address as [Address1],
		cg.address2 as [Address2],
		states.code as [State],
		cg.city as [City],
		cg.Zip as [Zip],
		cg.telephone as [Telephone],
		cg.fax as [Fax],
		cg.email as [Email],
		cg.name2 as [Settlement Contact Name],
		cg.company2 as [Settlement Contact Company],
		cg.telephone2 as [Settlement Contact Telephone],
		cg.fax2 as [Settlement Contact Fax],
		cg.email2 as [Settlement Contact Email],
		cg.area_engineer as [Xcel Area Engineer],
		cg.metering_contract as [Xcel Metering Contact],
		cg.miso_queue_number as [MISO Queue Number],
		cg.substation_name as [Substation Name],
		cg.project_county as [Project County],
		cg.voltage as [Voltage],
		cg.time_zone as [Time zone],
		cg.contract_service_agreement_id as[ContractServiceAgreementId],
		cg.billing_from_date as [Billing From],
		cg.billing_to_date as [Billing To],
		cg.contract_report_template as [Contract Report Template],
		cg.Subledger_code as [Subledger_Code],
		cg.UD_Contract_id as [UD_Contract_ID],	
		cg.extension_provision_description as [Extension Provision Description],
		cg.term_name as [Term Name],
		cg.increment_name as [Increment Name], 
		cg.ferct_tarrif_reference as [Ferct Tarrif Reference],
		cg.point_of_delivery_control_area as [PointofDeliveryBalancingAuthority],
		cg.point_of_delivery_specific_location as [PointOfDeliverySpecificLocation],
		cg.contract_affiliate as [Contract Affiliate],
		cg.point_of_receipt_control_area as [PointOfReceiptBalancingAuthority],
		point_of_receipt_specific_location as [PointOfReceiptSpecificLocation],
		cg.no_meterdata as [No Meter Data],
		cg.billing_start_month as [Billing Start Month],
		cg.increment_period as [Increment Period],
		cg.bookout_provision [Bookout Provision],
		cstatus.code [Contract Status],
		cg.holiday_calendar_id [Holiday Calendar ID],
		cg.billing_from_hour [Billing From Hour],
		cg.billing_to_hour [Billing From Hour],
		cg.payment_calendar [Payment Calendar],
		cg.pnl_date [PNL Date],
		cg.pnl_calendar [PNL Calendar],
		cg.settlement_calendar [Settlement Calendar],
		cg.contract_desc AS [Description],
		cg.netting_template As [Netting Template]
	from 	contract_group cg
		left join static_data_value sd on
		cg.billing_cycle=sd.value_id 
		left join static_data_value sd1 on cg.invoice_due_date=sd1.value_id
		left join application_users au on  cg.settlement_accountant=au.user_login_id
		left join application_users au2 on  cg.contract_Specialist=au2.user_login_id
		left join static_data_value sd2 on cg.volume_granularity=sd2.value_id
		left join portfolio_hierarchy ph on ph.entity_id=cg.sub_id
		left join source_currency sc on sc.source_currency_id=cg.currency
		left join source_uom su on su.source_uom_id=cg.volume_uom
		left join static_data_value states ON states.value_Id=cg.state
		LEFT JOIN static_data_value cstatus ON cstatus.value_id=cg.contract_status
		where 1=1 '
		+ CASE WHEN @contract_type IS NOT NULL THEN ' AND cg.contract_type IN ('''+@contract_type+''')' ELSE '' END
		
		IF @is_active = 'y' 
			SET @sql = @sql + 'AND cg.is_active = ''y'''
		ELSE IF @is_active = 'n'
			SET @sql = @sql + 'AND cg.is_active = ''n'' OR cg.is_active IS NULL'
			
		IF @contract_name IS NOT NULL
			SET @sql = @sql + ' and contract_name like ''%' + @contract_name + '%'' '

		IF @sub_id IS NOT NULL
			SET @sql = @sql + ' and sub_id =' + CAST(@sub_id AS VARCHAR)

		IF @book_id IS NOT NULL
			SET @sql = @sql + ' and cg.sub_id in(select sub_id from #sub_book)'

		set @sql=@sql+' order by contract_name'		
	EXEC spa_print @sql
	exec(@sql) 	
	END
	ELSE IF @flag = 'p'
	BEGIN
		--List those contract whose contract_type_def_id is transportation and valid pipeline is mapped
		SET @sql = 'SELECT contract_id,
							CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + '' - '' + cg.[contract_name] ELSE cg.[contract_name] END 
							+ CASE WHEN cg.source_system_id=2 THEN '''' ELSE CASE WHEN cg.source_system_id IS NULL THEN '''' ELSE ''.'' + ssd.source_system_name END END AS Name,
							MIN(fpl.is_enable) [status]
				FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
			contract_group cg ON cg.contract_id = fpl.value_id
		LEFT JOIN source_system_description ssd on	ssd.source_system_id = cg.source_system_id
		INNER JOIN static_data_value sdv
		  ON sdv.value_id = cg.contract_type_def_id
		  AND sdv.type_id = 38400
		LEFT JOIN source_counterparty sc
		  ON sc.source_counterparty_id = cg.pipeline
		WHERE sdv.value_id IN( ''38402'', ''38404'')
			AND sc.source_counterparty_id IS NOT NULL
			AND cg.is_active = ''y''
			'
		SET @sql += 'GROUP BY cg.contract_id, cg.source_contract_id, cg.contract_name, cg.source_system_id, ssd.source_system_name ORDER BY Name'	
		EXEC(@sql)
	END
	else IF @flag = 'q'
	begin
		--SELECT contract_id, contract_name Name FROM contract_group WHERE contract_type_def_id = 38403
		SELECT contract_id,
			sc.source_counterparty_id pipeline,
			sdv1.value_id maintain_rate_schedule
		FROM contract_group cg 
		LEFT JOIN static_data_value sdv
		  ON sdv.value_id = cg.contract_type_def_id
		  AND sdv.type_id = 38400
		LEFT JOIN static_data_value sdv1
		  ON sdv1.value_id = cg.maintain_rate_schedule
		  AND sdv1.type_id = 1800
		LEFT JOIN source_counterparty sc
		  ON sc.source_counterparty_id = cg.pipeline
		WHERE sdv.value_id = '38403' 
			AND cg.contract_id = @contract_id
			AND sc.source_counterparty_id IS NOT NULL

	end
	else IF @flag = '1'
	begin
		--SELECT contract_id, contract_name Name FROM contract_group WHERE contract_type_def_id = 38403
		SELECT contract_id,
			sc.source_counterparty_id pipeline,
			sdv1.value_id maintain_rate_schedule
		FROM contract_group cg 
		LEFT JOIN static_data_value sdv
		  ON sdv.value_id = cg.contract_type_def_id
		  AND sdv.type_id = 38400
		LEFT JOIN static_data_value sdv1
		  ON sdv1.value_id = cg.maintain_rate_schedule
		  AND sdv1.type_id = 1800
		LEFT JOIN source_counterparty sc
		  ON sc.source_counterparty_id = cg.pipeline
		WHERE sdv.value_id = '38402' 
			AND cg.contract_id = @contract_id
			AND sc.source_counterparty_id IS NOT NULL


	end
	ELSE IF @flag = 'm'
	BEGIN
		-- used in contract drop down		
		SET @sql_select = 'SELECT cg.contract_id,
		       CASE WHEN cg.source_system_id = 2 THEN ''''
		            ELSE ssd.source_system_name + ''.''
		       END + COALESCE(cg.source_contract_id, cg.UD_Contract_id, cg.contract_name, cg.contract_desc) [contract_name]
		FROM   contract_group cg
		INNER JOIN source_system_description ssd  ON  cg.source_system_id = ssd.source_system_id'
		IF @filter_value IS NOT NULL AND @filter_value <> '-1'
		BEGIN
			 SET @sql_select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = cg.contract_id'
		END
		SET @sql_select +=  ' ORDER BY ssd.source_system_name, COALESCE(cg.source_contract_id, cg.UD_Contract_id, cg.contract_name, cg.contract_desc)'
		
		EXEC (@sql_select)
	END
	/* 
	*	Flag = 'r'
	*	Show Contract Dropdown List
	*	Modified to implement privilege in contract dropdown
	*/
	ELSE IF @flag IN('r', 'n')
	BEGIN
		SET @sql = 'SELECT DISTINCT cg.contract_id ID,
						CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + '' - '' + cg.[contract_name] ELSE cg.[contract_name] END 
						 + CASE WHEN cg.source_system_id=2 THEN '''' ELSE CASE WHEN cg.source_system_id IS NULL THEN '''' ELSE ''.'' + ssd.source_system_name END END AS Name,
						 MIN(fpl.is_enable) [status]
					FROM #final_privilege_list fpl
					' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
					 contract_group cg ON cg.contract_id = fpl.value_id
					' + CASE WHEN @flag = 'n' THEN ' INNER JOIN' ELSE ' LEFT JOIN' END + ' source_system_description ssd on	ssd.source_system_id = cg.source_system_id'
		
		IF @counterparty_id IS NOT NULL
			SET @sql += ' INNER JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id IN (' + @counterparty_id  + ')'
		
		IF @filter_value IS NOT NULL AND @filter_value <> '-1'
		BEGIN
			SET @sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = cg.contract_id'
		END
		
		SET @sql += ' WHERE 1=1 AND cg.is_active = ''y'''
		
		IF @contract_type IS NOT NULL
			SET @sql += ' AND cg.contract_type=''' + @contract_type + ''''
		
		IF @transportation_contract IS NOT NULL AND @transportation_contract = 'y'
			SET @sql += ' AND cg.contract_type_def_id = 38402'

		IF @pipeline IS NOT NULL
			SET @sql =  @sql + ' AND cg.pipeline IN (' + @pipeline + ')'
			
		IF @contract_name IS NOT NULL
			SET @sql += ' AND cg.contract_name like ''%' + @contract_name + '%'''	

		SET @sql =  @sql + 'GROUP BY cg.contract_id, cg.source_contract_id, cg.contract_name, cg.source_system_id, ssd.source_system_name ORDER BY Name'	
		EXEC(@sql)
	END
	ELSE IF @flag = 'o'
	BEGIN
		SET @sql = 'SELECT DISTINCT cg.contract_id,
						CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + '' - '' + cg.[contract_name] ELSE cg.[contract_name] END contract_name,
						MIN(fpl.is_enable) [status]
					FROM #final_privilege_list fpl
					' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
					 contract_group cg ON cg.contract_id = fpl.value_id
					INNER JOIN delivery_path dp on dp.contract = cg.contract_id
					GROUP BY cg.contract_id, cg.source_contract_id, cg.contract_name'
		
		EXEC(@sql)
	END
	ELSE IF @flag = 'b' --Contract Browser
	BEGIN
		SET @sql = 'SELECT DISTINCT cca.contract_id [contract_id], cg.[contract_name] [contract], sc.counterparty_name [counterparty],
							MIN(fpl.is_enable) [status]
					FROM #final_privilege_list fpl
					' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
					 contract_group cg ON cg.contract_id = fpl.value_id
					INNER JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id
					INNER JOIN source_counterparty sc ON cca.counterparty_id = sc.source_counterparty_id'
		SET @sql += ' GROUP BY cca.contract_id, sc.counterparty_name, cg.contract_name'	
		EXEC(@sql)
	END
	/*
	######## Commented  By Pawan KC as 'c' used in down the code################

	else if @flag = 'c'
		Begin
			
	--select cgd.id,cg.contract_id [Contract ID],cg.contract_name [Contract Name]
	--FROM contract_group_detail cgd
	--JOIN contract_group cg
	--on cg.contract_id = cgd.contract_id
	select DISTINCT(cg.contract_name) [Contract Name],cg.contract_id [Contract ID]
	FROM contract_group_detail cgd
	JOIN contract_group cg
	on cg.contract_id = cgd.contract_id

	End
	*/
	ELSE IF @flag='a'
	BEGIN
		SELECT contract_id,
			   contract_name,
			   CONVERT(VARCHAR(10), contract_date, 120),
			   receive_invoice,
			   settlement_accountant,
			   billing_cycle,
			   invoice_due_date,
			   [name],
			   company,
			   STATE,
			   city,
			   zip,
			   ADDRESS,
			   telephone,
			   email,
			   sub_id,
			   hourly_block,
			   volume_granularity,
			   currency,
			   volume_mult,
			   onpeak_mult,
			   offpeak_mult,
			   TYPE,
			   reverse_entries,
			   volume_uom,
			   rec_uom,
			   contract_specialist,
			   address2,
			   fax,
			   name2,
			   company2,
			   telephone2,
			   fax2,
			   email2,
			   create_user,
			   dbo.FNADateformat(create_ts),
			   CONVERT(VARCHAR(10), term_start, 120),
			   CONVERT(VARCHAR(10), term_end, 120),
			   --dbo.FNADateformat(term_start),
			   --dbo.FNADateformat(term_end),
			   energy_type,
			   area_engineer,
			   metering_contract,
			   miso_queue_number,
			   substation_name,
			   project_county,
			   voltage,
			   time_zone,
			   contract_service_agreement_id,
			   contract_charge_type_id,
			   cg.billing_from_date AS [Billing From],
			   cg.billing_to_date AS [Billing To],
			   contract_report_template,
			   Subledger_code,
			   UD_Contract_id,
			   extension_provision_description,
			   term_name,
			   increment_name,
			   ferct_tarrif_reference,
			   point_of_delivery_control_area,
			   point_of_delivery_specific_location,
			   contract_affiliate,
			   point_of_receipt_control_area,
			   point_of_receipt_specific_location,
			   no_meterdata,
			   billing_start_month,
			   increment_period,
			   bookout_provision,
			   contract_status,
			   holiday_calendar_id,
			   billing_from_hour,
			   billing_to_hour,
			   cg.is_active,
			   cg.payment_calendar,
			   cg.pnl_date,
			   cg.pnl_Calendar,
			   cg.settlement_calendar,
			   cg.settlement_date,
			   cg.invoice_report_template, 
			   cg.neting_rule,
			   cg.payment_days AS [Payment Day],
			   cg.settlement_days AS [Settlement Day],
			   cg.self_billing AS [Self Billing],
			   cg.netting_template AS [Netting Template],
			   cg.source_system_id AS [Source System ID]
		FROM   contract_group cg
		WHERE  contract_id = @contract_id


	END
	ELSE IF @flag='i'
	BEGIN
			BEGIN TRY
			IF EXISTS (SELECT 1 FROM contract_group WHERE source_contract_id = ISNULL(@UD_Contract_id, @contract_name))
			BEGIN
				EXEC spa_ErrorHandler -1
					, 'contract_group' 
					, 'spa_contract_group'   
					, 'Error'        
					, 'The Contract Name already exits.' 
					, '' 
				RETURN
			END
			
		insert into contract_group(
			sub_id,
			contract_name,
			contract_date,
			receive_invoice,
			settlement_accountant,
			billing_cycle,
			invoice_due_date,
			[name],
			company,
			state,
			city,
			zip,
			address,
			telephone,
			email,
			hourly_block,
			volume_granularity,
			currency,
			volume_mult,
			onpeak_mult,
			offpeak_mult,
			type,
			reverse_entries,
			volume_uom,
			rec_uom,
			contract_specialist,
			address2,
			fax,
			name2,
			company2,	
			telephone2,
			fax2,
			email2,
			term_start,
			term_end,
			energy_type,
			area_engineer,
			metering_contract,
			miso_queue_number,
			substation_name,
			project_county,
			voltage,
			time_zone,
			contract_service_agreement_id,
			contract_charge_type_id,
			billing_from_date,
			billing_to_date,
			contract_report_template,
			Subledger_code,
			UD_Contract_id,		
			extension_provision_description,
			term_name,
			increment_name,
			ferct_tarrif_reference,
			point_of_delivery_control_area,
			point_of_delivery_specific_location,
			contract_affiliate,
			point_of_receipt_control_area,
			point_of_receipt_specific_location,
			no_meterdata,
			billing_start_month, 
			increment_period,
			source_system_id,
			bookout_provision,	
			contract_status,
			holiday_calendar_id,
			billing_from_hour,
			billing_to_hour,
			is_active,
			payment_calendar,
			pnl_date,
			pnl_calendar,
			settlement_calendar,
			settlement_date,
			contract_type,
			invoice_report_template, 
			neting_rule,
			payment_days,
			settlement_days,
			self_billing,
			netting_template,
			source_contract_id			
		)
		select
			@sub_id,
			@contract_name,
			@contract_date,
			@receive_invoice,
			@settlement_accountant,
			@billing_cycle,
			@invoice_due_date,
			@name,
			@company,
			@state,
			@city,
			@zip,
			@address,
			@telephone,
			@email,
			@hourly_block,
			@volume_granularity,
			@currency,
			@volume_mult,
			@onpeak_mult,
			@offpeak_mult,
			@type,
			@reverse_entries,
			@volume_uom,
			@rec_uom,
			@contract_specialist,
			@address2,
			@fax,
			@name2,
			@company2,	
			@telephone2,
			@fax2,
			@email2,
			@term_start,
			@term_end,
			@energy_type,		
			@area_engineer,
			@metering_contract,
			@miso_queue_number,
			@substation_name,
			@project_county,
			@voltage,
			@time_zone,
			@contract_service_agreement_id,
			@contract_charge_type_id,		
			@billing_from_date,
			@billing_to_date,
			@contract_report_template,
			@Subledger_code,
			@UD_Contract_id,		
			@extension_provision_description,
			@term_name,
			@increment_name, 
			@ferct_tarrif_reference,
			@point_of_delivery_control_area,
			@point_of_delivery_specific_location,
			@contract_affiliate,
			@point_of_receipt_control_area,
			@point_of_receipt_specific_location,	
			@no_meterdata,
			@billing_start_month, 
			@increment_period,
			@source_system_id,
			@bookout_provision,
			@contract_status,
			@holiday_calendar_id,
			@billing_from_hour,
			@billing_to_hour,
			@is_active,
			@payment_calendar,
			@pnl_date,
			@pnl_calendar,
			@settlement_calendar,
			@settlement_date,
			@contract_type,
			@invoice_report_template, 
			@neting_rule,
			@payment_day,
			@settlement_day,
			@self_billing,
			@netting_template,		
			ISNULL(@UD_Contract_id, @contract_name)	
		
		SET @contract_id = SCOPE_IDENTITY() 
		
		EXEC spa_ErrorHandler 0,
					 'Contract Group',
					 'spa_contract_group',
					 'Success',
					 'Changes have been saved successfully.',
					 @contract_id
					 
		END TRY
		BEGIN CATCH
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler -1,
				 "Contract Group",
				 "spa_contract_group",
				 "DB Error",
				 "Error on Updating Contract Group.",
				 ''
		ELSE
			EXEC spa_ErrorHandler 0,
				 'Contract Group',
				 'spa_contract_group',
				 'Success',
				 'Changes have been saved successfully.',
				 @contract_id
			
		END CATCH
	END
	ELSE IF @flag='u'
	BEGIN
		IF EXISTS (SELECT 1 FROM contract_group WHERE source_contract_id = ISNULL(@UD_Contract_id, @contract_name) AND contract_id <> @contract_id)
		BEGIN
			EXEC spa_ErrorHandler -1
				, 'contract_group' 
				, 'spa_contract_group'   
				, 'Error'        
				, 'The Contract Name already exits.' 
				, '' 
			RETURN
		END	
		
		update contract_group
		set
			sub_id=@sub_id,
			contract_name=@contract_name,
			contract_date=@contract_date,
			receive_invoice=@receive_invoice,
			settlement_accountant=@settlement_accountant,
			billing_cycle=@billing_cycle,
			invoice_due_date=@invoice_due_date,
			[name]=@name,
			company=@company,
			state=@state,
			city=@city,
			zip=@zip,
			address=@address,
			telephone=@telephone,
			email=@email,
			hourly_block=@hourly_block,
			volume_granularity=@volume_granularity,
			currency=@currency,
			volume_mult=@volume_mult,
			onpeak_mult=@onpeak_mult,
			offpeak_mult=@offpeak_mult,
			type=@type,
			reverse_entries=@reverse_entries,
			volume_uom=@volume_uom,
			rec_uom=@rec_uom,
			contract_specialist=@contract_specialist,
			address2=@address2,
			fax=@fax,
			name2=@name2,
			company2=@company2,
			telephone2=@telephone2,
			fax2=@fax2,
			email2=@email2,
			term_start=@term_start,
			term_end=@term_end,
			energy_type=@energy_type,
			area_engineer=@area_engineer,
			metering_contract=@metering_contract,
			miso_queue_number=@miso_queue_number,
			substation_name=@substation_name,
			project_county=@project_county,
			voltage=@voltage,
			time_zone=@time_zone,
			contract_service_agreement_id=@contract_service_agreement_id,
			contract_charge_type_id=@contract_charge_type_id,
			billing_from_date=@billing_from_date,
			billing_to_date=@billing_to_date,
			contract_report_template=@contract_report_template,
			Subledger_code=@Subledger_code,
			UD_Contract_id=@UD_Contract_id,		
			extension_provision_description=@extension_provision_description,
			term_name =@term_name,
			increment_name=@increment_name,
			ferct_tarrif_reference = @ferct_tarrif_reference,
			point_of_delivery_control_area = @point_of_delivery_control_area,
			point_of_delivery_specific_location = @point_of_delivery_specific_location,
			contract_affiliate = @contract_affiliate,
			point_of_receipt_control_area = @point_of_receipt_control_area,
			point_of_receipt_specific_location = @point_of_receipt_specific_location,
			no_meterdata=@no_meterdata,
			billing_start_month=@billing_start_month, 
			increment_period=@increment_period,
			--source_system_id=@source_system_id,
			bookout_provision=@bookout_provision,
			contract_status=@contract_status,
			holiday_calendar_id=@holiday_calendar_id,
			billing_from_hour=@billing_from_hour,
			billing_to_hour=@billing_to_hour,
			is_active = @is_active,
			payment_calendar = @payment_calendar,
			pnl_date = @pnl_date,
			pnl_calendar = @pnl_calendar,
			settlement_calendar = @settlement_calendar,
			settlement_date = @settlement_date,
			invoice_report_template = @invoice_report_template, 
			neting_rule = @neting_rule,
			payment_days = @payment_day,
			settlement_days = @settlement_day,
			self_billing = @self_billing,
			netting_template = @netting_template,
			source_system_id = @source_system_id,
			source_contract_id  = ISNULL(@UD_Contract_id, @contract_name)
			
		WHERE contract_id=@contract_id
			
		DECLARE @process_table VARCHAR(500)
		DECLARE @sql_st VARCHAR(MAX)
		DECLARE @alert_process_id VARCHAR(200)
		SET @alert_process_id = dbo.FNAGetNewID()  
		SET @process_table = 'adiha_process.dbo.alert_contract_' + @alert_process_id + '_ac'
		
		SET @sql_st = 'CREATE TABLE ' + @process_table + ' (
         		contract_id    INT,
         		contract_name  VARCHAR(200),
         		contract_status INT,
         		hyperlink1 VARCHAR(5000), 
         		hyperlink2 VARCHAR(5000), 
         		hyperlink3 VARCHAR(5000), 
         		hyperlink4 VARCHAR(5000), 
         		hyperlink5 VARCHAR(5000)
			 )
			INSERT INTO ' + @process_table + '(
				contract_id,
				contract_name,
				contract_status,
				hyperlink1
			  )
			SELECT ' + CAST(@contract_id AS VARCHAR(20)) + ',
			       ''' + @contract_name + ''',
			       ' + CAST(@contract_status AS VARCHAR(20)) + ',
			       dbo.FNATrmHyperlink(''i'',10211010,''Review Contract - ' + @contract_name + ''',' + CAST(@contract_id AS VARCHAR(20)) + ',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)'
				

		EXEC(@sql_st)
		exec spa_print @sql_st
		
		EXEC spa_register_event 20603, 20510, @process_table, 0, @alert_process_id
		
		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Contract Group", 
			"spa_contract_group", "DB Error", 
			"Error on Updating Contract Group.", ''
		else
			Exec spa_ErrorHandler 0, 'Contract Group', 
			'spa_contract_group', 'Success', 
			'Changes have been saved successfully.',''
			

	END

	/******************* MODIFIED By: Pawan KC  Date: 03/03/2009******************************/
	ELSE IF @flag='c'
	BEGIN
		BEGIN TRAN
		DECLARE @new_contract_id INT,
				@copy_contract VARCHAR(500),
				@new_contract VARCHAR(300),
				@new_source_contract_id VARCHAR(500),
				@copy_source_contract_id VARCHAR(500)
			
		SELECT @copy_contract = contract_name,
			    @copy_source_contract_id = ISNULL(source_contract_id, UD_Contract_id)
		FROM contract_group
		WHERE contract_id = @contract_id

		EXEC [spa_GetUniqueCopyName] @copy_contract, 'contract_name', 'contract_group', NULL, @new_contract OUTPUT			
		EXEC [spa_GetUniqueCopyName] @copy_source_contract_id, 'source_contract_id', 'contract_group', NULL, @copy_source_contract_id OUTPUT
			
		INSERT INTO contract_group (
			source_system_id, sub_id, contract_name, contract_date, receive_invoice, settlement_accountant, billing_cycle, invoice_due_date, [name], company,
			state, city, zip, address, telephone, email, hourly_block, volume_granularity, currency, volume_mult, onpeak_mult, offpeak_mult, type, reverse_entries,
			volume_uom, rec_uom, contract_specialist, address2, fax, name2, company2, telephone2, fax2, email2, term_start, term_end, energy_type, area_engineer,
			metering_contract, miso_queue_number, substation_name, project_county, voltage, time_zone, contract_service_agreement_id, billing_from_date,
			billing_to_date, contract_report_template, Subledger_code, UD_Contract_id, extension_provision_description, term_name, increment_name.ferct_tarrif_reference,
			point_of_delivery_control_area, point_of_delivery_specific_location, contract_affiliate, point_of_receipt_control_area, point_of_receipt_specific_location,
			no_meterdata, billing_start_month, increment_period, bookout_provision, contract_status, holiday_calendar_id, billing_from_hour, billing_to_hour, is_active,
			payment_calendar, pnl_date, pnl_calendar, settlement_calendar, settlement_date, invoice_report_template, neting_rule, source_contract_id, contract_desc,
			contract_type_def_id, netting_template, contract_email_template, payment_days, settlement_days, flow_start_date, flow_end_date, maintain_rate_schedule,
			mdq, contract_type, capacity_release, pipeline, self_billing, segmentation, contract_charge_type_id, commodity
		)
		SELECT source_system_id, sub_id, @new_contract, contract_date, receive_invoice, settlement_accountant, billing_cycle, invoice_due_date, [name], company,
			    state, city, zip, address, telephone, email, hourly_block, volume_granularity, currency, volume_mult, onpeak_mult, offpeak_mult, type, reverse_entries,
			    volume_uom, rec_uom, contract_specialist, address2, fax, name2, company2, telephone2, fax2, email2, term_start, term_end, energy_type, area_engineer,
			    metering_contract, miso_queue_number, substation_name, project_county, voltage, time_zone, contract_service_agreement_id, billing_from_date,
			    billing_to_date, contract_report_template, Subledger_code, UD_Contract_id, extension_provision_description, term_name, increment_name ferct_tarrif_reference,
			    point_of_delivery_control_area, point_of_delivery_specific_location, contract_affiliate, point_of_receipt_control_area, point_of_receipt_specific_location,
			    no_meterdata, billing_start_month, increment_period, bookout_provision, contract_status, holiday_calendar_id, billing_from_hour, billing_to_hour, is_active,
			    payment_calendar, pnl_date, pnl_calendar, settlement_calendar, settlement_date, invoice_report_template, neting_rule, ISNULL(@copy_source_contract_id, @new_contract), contract_desc,
				contract_type_def_id, netting_template, contract_email_template, payment_days, settlement_days, flow_start_date, flow_end_date, maintain_rate_schedule,
				mdq, contract_type, capacity_release, pipeline, self_billing, segmentation, contract_charge_type_id, commodity
		FROM contract_group
		WHERE [contract_id] = @contract_id
		
		SET @new_contract_id = SCOPE_IDENTITY()

		INSERT INTO transportation_contract_mdq(contract_id, effective_date, mdq)
		SELECT @new_contract_id, effective_date, mdq
		FROM transportation_contract_mdq 
		WHERE contract_id = @contract_id

		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler -1, 'Maintain Contract Group', 'spa_contract_group', 'DB Error', 'Copying of Maintain Contract Group data failed.', ''
			ROLLBACK TRAN
		END
		ELSE
			INSERT INTO [contract_group_detail] (
				[contract_id], [invoice_line_item_id], [default_gl_id], [price], [formula_id], [manual], [currency], [Prod_type], [sequence_order], [inventory_item],
				[volume_granularity], [deal_type], time_bucket_formula_id, calc_aggregation, [payment_calendar], [pnl_date], [pnl_calendar], [timeofuse], [include_charges],
				[contract_template], [contract_component_template], [radio_automatic_manual], [settlement_date], [settlement_calendar], [effective_date], [product_type_name], 
				[group_by], [alias], [hideininvoice], [eqr_product_name], default_gl_id_estimates, Invoice_group, invoice_template_id, group1, group2, group3, group4, leg,
				location_id, true_up_charge_type_id, true_up_no_month, true_up_applies_to, is_true_up, buy_sell_flag, default_gl_code_cash_applied
			)
			SELECT @new_contract_id, [invoice_line_item_id], [default_gl_id], [price], [formula_id], [manual], [currency], [Prod_type], [sequence_order], [inventory_item],
					[volume_granularity], [deal_type], time_bucket_formula_id, calc_aggregation, [payment_calendar], [pnl_date], [pnl_calendar], [timeofuse], [include_charges],
					[contract_template], [contract_component_template], [radio_automatic_manual], [settlement_date], [settlement_calendar], [effective_date], [product_type_name],
					[group_by], [alias], [hideininvoice], [eqr_product_name], default_gl_id_estimates, Invoice_group, invoice_template_id, group1, group2, group3, group4,
					leg, location_id, true_up_charge_type_id, true_up_no_month, true_up_applies_to, is_true_up, buy_sell_flag, default_gl_code_cash_applied
			FROM [contract_group_detail] 
			WHERE [contract_id] = @contract_id

			IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler -1, 'Maintain Contract Detail', 'spa_contract_group', 'DB Error', 'Error Copying Contract Group Detail Data.', ''
				ROLLBACK TRAN
			END
			ELSE
				DECLARE @formula_id INT,
						@formula VARCHAR(8000),
						@formula_type VARCHAR(1),
						@formula_html VARCHAR(MAX),
						@new_formula_id INT,
						@sequence_order INT,
						@formula_nested_id INT

				DECLARE formula_cursor CURSOR FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
								
					SELECT fe.formula_id,
						   fe.formula,
						   fe.formula_type,
						   fe.formula_html
					FROM formula_editor fe 
					INNER JOIN contract_group_detail cgd 
						ON fe.formula_id = cgd.formula_id 
					WHERE cgd.formula_id IS NOT NULL 
						AND contract_id = @new_contract_id

				OPEN formula_cursor
				FETCH next FROM formula_Cursor INTO @formula_id, @formula, @formula_type, @formula_html
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @formula = dbo.FNAFormulaFormat(@formula, 'd')
					INSERT formula_editor (formula, formula_type, formula_html)
					VALUES (@formula, @formula_type, @formula_html)
					SET @new_formula_id = SCOPE_IDENTITY()
					
					IF @formula_type='n'
					BEGIN
						DECLARE @formula_id_n INT,
								@formula_id_n_new INT
						
						DECLARE formula_cursor1 CURSOR FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
						
							SELECT formula_id,
								   sequence_order
							FROM formula_nested
							WHERE formula_group_id = @formula_id
						
						OPEN formula_cursor1
						FETCH next FROM formula_Cursor1 INTO @formula_id_n, @sequence_order
						WHILE @@FETCH_STATUS = 0
						BEGIN
							INSERT formula_editor (formula, formula_type, formula_name, system_defined, static_value_id, istemplate, formula_source_type, formula_html)
							SELECT formula, formula_type, formula_name, system_defined, static_value_id, istemplate, formula_source_type, formula_html
							FROM formula_editor
							WHERE formula_id = @formula_id_n

							SET @formula_id_n_new = SCOPE_IDENTITY()
							
							INSERT INTO formula_nested (
								sequence_order, description1, description2, formula_id, formula_group_id, granularity, 
								include_item, show_value_id, uom_id, rate_id, total_id
							)
							SELECT sequence_order, description1, description2, @formula_id_n_new, @new_formula_id, granularity,
								   include_item, show_value_id, uom_id, rate_id, total_id
							FROM formula_nested
							WHERE formula_group_id = @formula_id
								AND formula_id = @formula_id_n
									
							SET @formula_nested_id = SCOPE_IDENTITY()						

							INSERT INTO formula_breakdown(
								formula_id, nested_id, formula_level, func_name, arg_no_for_next_func, parent_nested_id, level_func_sno, parent_level_func_sno,
								arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, eval_value, formula_nested_id
							)
							SELECT @new_formula_id, nested_id,formula_level, func_name, arg_no_for_next_func, parent_nested_id, level_func_sno, parent_level_func_sno,
								   arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, eval_value, @formula_nested_id
							FROM formula_breakdown
							WHERE formula_id = @formula_id
								AND nested_id = @sequence_order

							-- Insert UDSQL
							IF EXISTS (SELECT 1 FROM formula_editor
									   WHERE formula_id = @formula_id_n
									   AND  formula_type = 'd'
							)
							BEGIN
								INSERT INTO formula_editor_sql(formula_id,formula_sql)
								SELECT @formula_id_n_new,formula_sql
								FROM formula_editor_sql
								WHERE formula_id = @formula_id_n
							END

							FETCH NEXT FROM formula_Cursor1 INTO @formula_id_n, @sequence_order
						END
						CLOSE formula_cursor1
						DEALLOCATE formula_cursor1
					END

			UPDATE [contract_group_detail] 
			SET formula_id = @new_formula_id
			WHERE formula_id = @formula_id
				AND [contract_id] = @new_contract_id
			FETCH NEXT FROM formula_Cursor INTO @formula_id, @formula, @formula_type, @formula_html
			END
			CLOSE formula_cursor
			DEALLOCATE formula_cursor
								
			IF @@ERROR <> 0
				EXEC spa_ErrorHandler -1, 'Maintain Contract Detail', 'spa_contract_group', 'DB Error', 'Error Copying Formula.', ''
			ELSE
				EXEC spa_ErrorHandler 0, 'Contract Group', 'spa_contract_group', 'Success', 'Changes have been saved successfully.', @new_contract_id
					
			COMMIT TRAN
	END

	ELSE IF @flag='d'
	BEGIN
		SELECT s.item contract_id
		INTO #temp_contract
		FROM dbo.SplitCommaSeperatedValues(@contract_id) s
		
		IF EXISTS (
		       SELECT 1
		       FROM   source_deal_header sdh
			   INNER JOIN contract_group cg ON  cg.contract_id = sdh.contract_id
			   INNER JOIN #temp_contract tc ON tc.contract_id = cg.contract_id
		   )            
        BEGIN
			EXEC spa_ErrorHandler -1,
			     'Contract Group',
			     'spa_contract_group',
			     'DB Error',
			     'Failed to delete contract. Deal(s) is entered for this contract.',
			     ''
			RETURN
        END
		
		IF EXISTS (
		       SELECT 1
		       FROM   transportation_contract_location tcl
			   INNER JOIN contract_group cg ON  tcl.contract_id = cg.contract_id
		       INNER JOIN #temp_contract tc ON tc.contract_id = cg.contract_id
		   )            
        BEGIN
			EXEC spa_ErrorHandler -1,
			     'Contract Group',
			     'spa_contract_group',
			     'DB Error',
			     'Failed to delete contract. Transportation Contract Location is entered for this contract.',
			     ''
			RETURN
        END
        

        IF EXISTS (
		       SELECT 1
		       FROM   counterparty_contract_rate_schedule sdh
			   INNER JOIN #temp_contract tc ON tc.contract_id = sdh.contract_id
		   )            
        BEGIN
			EXEC spa_ErrorHandler -1,
			     'Contract Group',
			     'spa_contract_group',
			     'DB Error',
			     'Failed to delete contract. Delivery path(s) is setup for this contract..',
			     ''
			RETURN
		END
		
		 IF EXISTS (
		       SELECT 1
		       FROM   Calc_invoice_Volume_variance ih
		       INNER JOIN contract_group cg ON cg.contract_id = ih.contract_id
			   INNER JOIN #temp_contract tc ON tc.contract_id = cg.contract_id
		   )            
        BEGIN
			EXEC spa_ErrorHandler -1,
			     'Contract Group',
			     'spa_contract_group',
			     'DB Error',
			     'Failed to delete contract. Invoice(s) is Mapped to this Contract.',
			     ''
			RETURN
        END
        
		BEGIN TRY
		BEGIN TRAN	
			IF OBJECT_ID (N'#temp_formula_id', N'U') IS NOT NULL 
				DROP TABLE #temp_formula_id
			
			SELECT fn.formula_id
			INTO #temp_formula_id 
			FROM formula_nested fn
			INNER JOIN contract_group_detail s ON fn.formula_group_id = s.formula_id
			INNER JOIN #temp_contract tc ON tc.contract_id = s.contract_id

			DELETE b FROM formula_breakdown b 
			INNER JOIN formula_nested f ON f.formula_group_id=b.formula_id
			INNER JOIN contract_group_detail s ON f.formula_group_id=s.formula_id
			INNER JOIN #temp_contract tc ON tc.contract_id = s.contract_id

			DELETE f FROM formula_nested f 
			INNER JOIN contract_group_detail s ON f.formula_group_id=s.formula_id
			INNER JOIN #temp_contract tc ON tc.contract_id = s.contract_id

			DELETE f FROM formula_editor f 
			INNER JOIN #temp_formula_id tmp ON f.formula_id = tmp.formula_id

			DELETE f FROM formula_editor f 
			INNER JOIN contract_group_detail s ON f.formula_id=s.formula_id
			INNER JOIN #temp_contract tc ON tc.contract_id = s.contract_id

			DELETE an FROM application_notes an 
				INNER JOIN contract_group_detail cgd  ON cgd.contract_id = ISNULL(an.parent_object_id, an.notes_object_id)
				INNER JOIN #temp_contract tc ON tc.contract_id = cgd.contract_id
			WHERE an.internal_type_value_id = 40

			UPDATE en SET notes_object_id = NULL 			
			FROM email_notes en
				INNER JOIN contract_group_detail cgd  ON cgd.contract_id = en.notes_object_id
				INNER JOIN #temp_contract tc ON tc.contract_id = cgd.contract_id
			WHERE en.internal_type_value_id = 40

			DELETE cgd
			FROM   contract_group_detail cgd
			INNER JOIN #temp_contract tc ON tc.contract_id = cgd.contract_id
			
			IF EXISTS (SELECT 1 FROM rec_generator rg 
						INNER JOIN #temp_contract tc ON tc.contract_id = rg.ppa_contract_id
						)
			BEGIN
				DELETE rg
				FROM   rec_generator rg
				INNER JOIN #temp_contract tc ON tc.contract_id = rg.ppa_contract_id
			END
				
			DELETE gaivs
			FROM general_assest_info_virtual_storage gaivs
			INNER JOIN #temp_contract tc ON tc.contract_id = gaivs.agreement
				
			DELETE cg from contract_group cg
			INNER JOIN #temp_contract tc ON tc.contract_id = cg.contract_id

			COMMIT TRAN

			EXEC spa_ErrorHandler 0,
				'Contract Group',
				'spa_contract_group',
				'Success',
				'Changes have been saved successfully.',
				@contract_id
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN

			DECLARE @msg VARCHAR(MAX) = dbo.FNAHandleDBError(10211200)
				
			EXEC spa_ErrorHandler -1,
				'Contract Group',
				'spa_contract_group',
				'Error',
				@msg,
				@contract_id
		END CATCH
	END

	/*Select Flag for Transportation Contract*/
	IF @flag='t'
	BEGIN
	set @sql='select cg.contract_id [ID],
		cg.contract_name [Contract Name],
		sco.counterparty_name [Pipeline],
		dbo.FNADateformat(cg.flow_start_date) [Flow Start Date],
		dbo.FNADateformat(cg.flow_end_date) [Flow End Date],
		cg2.contract_name [Settlement Rule],
		sdh.deal_id [Deal],
		+ CASE WHEN cg.contract_type = ''f'' THEN ''Firm''
		  ELSE ''Interruptible''
		  END [Contract Type],
		sdv1.code [Maintain Rate Schedule]
		
	from 	contract_group cg
		left join source_counterparty sco on sco.source_counterparty_id=cg.pipeline
		left join contract_group cg2 on cg2.contract_id=cg.settlement_rule
	    left join delivery_path dp on dp.path_id=cg.path
	    left join static_data_value sdv1 on sdv1.value_id=cg.maintain_rate_schedule
	    LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = cg.deal
	    where 1=1 '
		
		SET @sql = @sql + ' AND cg.transportation_contract = ''t'' '
		IF @is_active = 'y' 
			SET @sql = @sql + 'AND cg.is_active = ''y'' AND cg.contract_name =' + ISNULL(''''+@contract_name+ '''', 'cg.contract_name') 
		
		ELSE IF @is_active = 'n' 
			SET @sql = @sql + 'AND cg.is_active = ''n'' AND cg.contract_name =' + ISNULL(''''+ @contract_name+ '''', 'cg.contract_name')

		SET @sql = @sql + ' ORDER BY cg.contract_name'
			
		EXEC spa_print @sql
		EXEC (@sql)
	END
	/*Select Flag for Transportation Contract which exists only in delivery path*/
	IF @flag='y'
	BEGIN
	set @sql='select distinct cg.contract_id [ID],
		cg.contract_name [Contract Name]		
	from 	contract_group cg
	    inner join delivery_path dp on dp.contract=cg.contract_id'
	    
		EXEC spa_print @sql
		EXEC (@sql)
	END
	/*Insert flag for Transportation Contract */
	ELSE IF @flag='v'
	BEGIN
		IF EXISTS (SELECT 1 FROM contract_group WHERE source_contract_id = ISNULL(@UD_Contract_id, @contract_name))
		BEGIN
			EXEC spa_ErrorHandler -1
				, 'contract_group' 
				, 'spa_contract_group'   
				, 'Error'        
				, 'The Contract Name already exits.' 
				, '' 
			RETURN
		END	
		BEGIN TRY
			insert into contract_group(
			sub_id,
			contract_name,
			contract_date,
			receive_invoice,
			settlement_accountant,
			billing_cycle,
			invoice_due_date,
			[name],
			company,
			state,
			city,
			zip,
			address,
			telephone,
			email,
			hourly_block,
			volume_granularity,
			currency,
			volume_mult,
			onpeak_mult,
			offpeak_mult,
			type,
			reverse_entries,
			volume_uom,
			rec_uom,
			contract_specialist,
			address2,
			fax,
			name2,
			company2,	
			telephone2,
			fax2,
			email2,
			term_start,
			term_end,
			energy_type,
			area_engineer,
			metering_contract,
			miso_queue_number,
			substation_name,
			project_county,
			voltage,
			time_zone,
			contract_service_agreement_id,
			contract_charge_type_id,
			billing_from_date,
			billing_to_date,
			contract_report_template,
			Subledger_code,
			UD_Contract_id,		
			extension_provision_description,
			term_name,
			increment_name,
			ferct_tarrif_reference,
			point_of_delivery_control_area,
			point_of_delivery_specific_location,
			contract_affiliate,
			point_of_receipt_control_area,
			point_of_receipt_specific_location,
			no_meterdata,
			billing_start_month, 
			increment_period,
			source_system_id,
			bookout_provision,	
			contract_status,
			holiday_calendar_id,
			billing_from_hour,
			billing_to_hour,
			is_active,
			payment_calendar,
			pnl_date,
			pnl_calendar,
			settlement_calendar,
			settlement_date,
			pipeline,
			flow_start_date,
			flow_end_date,
			settlement_rule,
			[path],
			capacity_release,
			deal ,
			interruptible,
			contract_type,
			maintain_rate_schedule,
			transportation_contract,
			invoice_report_template, 
			neting_rule,
			source_contract_id				
		)
		select
			@sub_id,
			@contract_name,
			@contract_date,
			@receive_invoice,
			@settlement_accountant,
			@billing_cycle,
			@invoice_due_date,
			@name,
			@company,
			@state,
			@city,
			@zip,
			@address,
			@telephone,
			@email,
			@hourly_block,
			@volume_granularity,
			@currency,
			@volume_mult,
			@onpeak_mult,
			@offpeak_mult,
			@type,
			@reverse_entries,
			@volume_uom,
			@rec_uom,
			@contract_specialist,
			@address2,
			@fax,
			@name2,
			@company2,	
			@telephone2,
			@fax2,
			@email2,
			@term_start,
			@term_end,
			@energy_type,		
			@area_engineer,
			@metering_contract,
			@miso_queue_number,
			@substation_name,
			@project_county,
			@voltage,
			@time_zone,
			@contract_service_agreement_id,
			@contract_charge_type_id,		
			@billing_from_date,
			@billing_to_date,
			@contract_report_template,
			@Subledger_code,
			@UD_Contract_id,		
			@extension_provision_description,
			@term_name,
			@increment_name, 
			@ferct_tarrif_reference,
			@point_of_delivery_control_area,
			@point_of_delivery_specific_location,
			@contract_affiliate,
			@point_of_receipt_control_area,
			@point_of_receipt_specific_location,	
			@no_meterdata,
			@billing_start_month, 
			@increment_period,
			@source_system_id,
			@bookout_provision,
			@contract_status,
			@holiday_calendar_id,
			@billing_from_hour,
			@billing_to_hour,
			'y',
			@payment_calendar,
			@pnl_date,
			@pnl_calendar,
			@settlement_calendar,
			@settlement_date,
			@pipeline,
			@flow_start_date,
			@flow_end_date,
			@settlement_rule,
			@path,
			@capacity_release,
			@deal ,
			@interruptible,
			@contract_type,
			@maintain_rate_schedule,
			@transportation_contract,
			@invoice_report_template, 
			@neting_rule,
			ISNULL(@UD_Contract_id, @contract_name)		
			
			SET @contract_id = SCOPE_IDENTITY() 
			EXEC spa_ErrorHandler 0,
				 'contract_group',
				 'spa_contract_group',
				 'Success',
				 'Changes have been saved successfully.',
				 @contract_id
		
		END TRY
		BEGIN CATCH
			
			IF @@ERROR <> 0
				EXEC spa_ErrorHandler -1,
					 'contract_group',
					 'spa_contract_group',
					 'DB Error',
					 'Error on Inserting Contract Group.',
					 ''	
		END CATCH
			
	END
	
	/*Update flag for transportation contract*/
	
	
	ELSE IF @flag='w'
	BEGIN
		IF EXISTS (SELECT 1 FROM contract_group WHERE contract_name = @contract_name 
				   AND contract_id <> @contract_id)
		BEGIN
			EXEC spa_ErrorHandler -1
				, 'contract_group' 
				, 'spa_contract_group'   
				, 'Error'        
				, 'The Contract Name already exits.' 
				, ''
			RETURN 
		END
		BEGIN TRY
			update contract_group  
			set
			sub_id=@sub_id,
			contract_name=@contract_name,
			contract_date=@contract_date,
			receive_invoice=@receive_invoice,
			settlement_accountant=@settlement_accountant,
			billing_cycle=@billing_cycle,
			invoice_due_date=@invoice_due_date,
			[name]=@name,
			company=@company,
			state=@state,
			city=@city,
			zip=@zip,
			address=@address,
			telephone=@telephone,
			email=@email,
			hourly_block=@hourly_block,
			volume_granularity=@volume_granularity,
			currency=@currency,
			volume_mult=@volume_mult,
			onpeak_mult=@onpeak_mult,
			offpeak_mult=@offpeak_mult,
			type=@type,
			reverse_entries=@reverse_entries,
			volume_uom=@volume_uom,
			rec_uom=@rec_uom,
			contract_specialist=@contract_specialist,
			address2=@address2,
			fax=@fax,
			name2=@name2,
			company2=@company2,
			telephone2=@telephone2,
			fax2=@fax2,
			email2=@email2,
			term_start=@term_start,
			term_end=@term_end,
			energy_type=@energy_type,
			area_engineer=@area_engineer,
			metering_contract=@metering_contract,
			miso_queue_number=@miso_queue_number,
			substation_name=@substation_name,
			project_county=@project_county,
			voltage=@voltage,
			time_zone=@time_zone,
			contract_service_agreement_id=@contract_service_agreement_id,
			contract_charge_type_id=@contract_charge_type_id,
			billing_from_date=@billing_from_date,
			billing_to_date=@billing_to_date,
			contract_report_template=@contract_report_template,
			Subledger_code=@Subledger_code,
			UD_Contract_id=@UD_Contract_id,		
			extension_provision_description=@extension_provision_description,
			term_name =@term_name,
			increment_name=@increment_name,
			ferct_tarrif_reference = @ferct_tarrif_reference,
			point_of_delivery_control_area = @point_of_delivery_control_area,
			point_of_delivery_specific_location = @point_of_delivery_specific_location,			
			contract_affiliate = @contract_affiliate,
			point_of_receipt_control_area = @point_of_receipt_control_area,
			point_of_receipt_specific_location = @point_of_receipt_specific_location,
			no_meterdata=@no_meterdata,
			billing_start_month=@billing_start_month, 
			increment_period=@increment_period,
			source_system_id=@source_system_id,
			bookout_provision=@bookout_provision,
			contract_status=@contract_status,
			holiday_calendar_id=@holiday_calendar_id,
			billing_from_hour=@billing_from_hour,
			billing_to_hour=@billing_to_hour,
			is_active = 'y',
			payment_calendar = @payment_calendar,
			pnl_date = @pnl_date,
			pnl_calendar = @pnl_calendar,
			settlement_calendar = @settlement_calendar,
			settlement_date = @settlement_date,
			pipeline = @pipeline,
			flow_start_date = @flow_start_date,
			flow_end_date = @flow_end_date,
			settlement_rule = @settlement_rule,
			[path] = @path,
			capacity_release = @capacity_release,
			deal = @deal ,
			interruptible = @interruptible,
			contract_type = @contract_type,
			maintain_rate_schedule = @maintain_rate_schedule,
			transportation_contract = @transportation_contract		

		where
			contract_id=@contract_id
 
			Exec spa_ErrorHandler 0, 
			'Contract Group', 
			'spa_contract_group', 
			'Success', 
			'Changes have been saved successfully.',
			@contract_id
			
		END TRY
		BEGIN CATCH
			if @@ERROR <> 0
			Exec spa_ErrorHandler -1,
			'Contract Group', 
			'spa_contract_group',
			'DB Error', 
			'Error on Updating Contract Group.',
			''
		END CATCH
		
	END		 		
	/*Select  a data relating to trasportation contract*/
	ELSE IF @flag='x'
	BEGIN
		SELECT sub_id,
			contract_name,
			contract_date,
			receive_invoice,
			settlement_accountant,
			billing_cycle,
			invoice_due_date,
			[name],
			company,
			state,
			city,
			zip,
			address,
			telephone,
			email,
			hourly_block,
			volume_granularity,
			currency,
			volume_mult,
			onpeak_mult,
			offpeak_mult,
			type,
			reverse_entries,
			volume_uom,
			rec_uom,
			contract_specialist,
			address2,
			fax,
			name2,
			company2,	
			telephone2,
			fax2,
			email2,
			term_start,
			term_end,
			energy_type,
			area_engineer,
			metering_contract,
			miso_queue_number,
			substation_name,
			project_county,
			voltage,
			time_zone,
			contract_service_agreement_id,
			contract_charge_type_id,
			billing_from_date,
			billing_to_date,
			contract_report_template,
			Subledger_code,
			UD_Contract_id,		
			extension_provision_description,
			term_name,
			increment_name,
			ferct_tarrif_reference,
			point_of_delivery_control_area,
			point_of_delivery_specific_location,
			contract_affiliate,
			point_of_receipt_control_area,
			point_of_receipt_specific_location,
			no_meterdata,
			billing_start_month, 
			increment_period,
			cg.source_system_id,
			bookout_provision,	
			contract_status,
			holiday_calendar_id,
			billing_from_hour,
			billing_to_hour,
			is_active,
			payment_calendar,
			pnl_date,
			pnl_calendar,
			settlement_calendar,
			settlement_date,
			pipeline,
			dbo.FNADateFormat(flow_start_date),
			dbo.FNADateFormat(flow_end_date),   
			settlement_rule,
			[path],
			capacity_release,
			deal ,
			interruptible,
			contract_type,
			maintain_rate_schedule,
			transportation_contract,
			sdh.deal_id	
		FROM   contract_group cg
		LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = cg.deal
		WHERE  cg.contract_id = @contract_id
		
	END
	
	ELSE IF @flag = 'k'
	BEGIN
		
		SELECT contract_id, transportation_contract
		FROM   contract_group
		WHERE  contract_id = @contract_id 
		
	END
	
	ELSE IF @flag = 'l'
	BEGIN
		SELECT crt.filename
		FROM   contract_group cg
		       INNER JOIN Contract_report_template crt
		            ON  crt.template_id = cg.invoice_report_template
		WHERE  cg.contract_id = @contract_id
	END
	ELSE IF @flag = 'z'
	BEGIN
		IF EXISTS (SELECT 1 FROM contract_group WHERE source_contract_id = ISNULL(@UD_Contract_id, @contract_name) AND contract_id <> @contract_id)
		BEGIN
			EXEC spa_ErrorHandler -1
				, 'contract_group' 
				, 'spa_contract_group'   
				, 'Error'        
				, 'The Contract Name already exits.' 
				, '' 
			RETURN
		END
		
		BEGIN TRY
		UPDATE contract_group
		SET    
		       contract_name = @contract_name,
		       pipeline = @pipeline,
		       [type] = @type,
		       flow_start_date = @flow_start_date,
		       flow_end_date = @flow_end_date,
		       capacity_release = @capacity_release,
			   deal = @deal ,
			   contract_type = @contract_type,
			   maintain_rate_schedule = @maintain_rate_schedule,
			   transportation_contract = @transportation_contract,
			   source_contract_id = ISNULL(@UD_Contract_id, @contract_name)
		WHERE  contract_id = @contract_id
		
		Exec spa_ErrorHandler 0, 
			'Contract Group', 
			'spa_contract_group', 
			'Success', 
			'Changes have been saved successfully.',
			@contract_id
			
		END TRY
		BEGIN CATCH
			if @@ERROR <> 0
			Exec spa_ErrorHandler -1,
			'Contract Group', 
			'spa_contract_group',
			'DB Error', 
			'Error on Updating Contract.',
			''
		END CATCH
	END
	else if @flag = 'j' --for contract dropdown filter only transportation contract (schedule deal menu)
	begin
		select cg.contract_id, cg.[contract_name]
		from contract_group cg
		where cg.contract_type_def_id = 38402 --only transportation contract
	end	
	ELSE IF @flag = 'e' --storage deal
	BEGIN
		SELECT NULL, '' 
		UNION
		SELECT cg.contract_id, cg.[contract_name]
		FROM contract_group cg
		WHERE contract_type = 's'
	END
	
	
	IF @flag='g'
	BEGIN
		UPDATE contract_group set is_lock = 'y' where contract_id = @contract_id
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler -1, 'Maintain Contract Detail', 
			'spa_contract_group', 'DB Error', 
			'Error Locking Contract.', ''
		ELSE
			Exec spa_ErrorHandler 0, 'Contract Group', 
			'spa_contract_group', 'Success', 
			'Contract successfully locked.',@contract_id
	END 
	
	IF @flag='h'
	BEGIN
		UPDATE contract_group set is_lock = 'n' where contract_id = @contract_id
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler -1, 'Maintain Contract Detail', 
			'spa_contract_group', 'DB Error', 
			'Error Unlocking Contract.', ''
		ELSE
			Exec spa_ErrorHandler 0, 'Contract Group', 
			'spa_contract_group', 'Success', 
			'Contract successfully unlocked.',@contract_id
	END 

	IF @flag='f'
	BEGIN
		SELECT is_lock FROM contract_group WHERE contract_id = @contract_id

	END 
	--get all the contract for dropdown of type 38404(Storage) used on UDF
	IF @flag='2'
	BEGIN
		SELECT contract_id [id], [contract_name] [value] FROM contract_group WHERE contract_type_def_id = 38404

	END 
	
END

