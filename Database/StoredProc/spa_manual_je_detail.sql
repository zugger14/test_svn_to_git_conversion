IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_manual_je_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_manual_je_detail]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE proc [dbo].[spa_manual_je_detail] 
	@flag char(1),
	@manual_je_detail_id int=null,
	@manual_je_id int=null,
	@gl_account_id int=null,
	@volume float=null,
	@uom int=null,
	@debit_amount float=null,
	@credit_amount float=null,
	@frequency char(1)=null,
	@until_date datetime=null,
	@create_inventory char(1)=null,
	@generator_id int=null,
	@gl_number_id int= null

 AS 

DECLARE @msg_err VARCHAR(2000) 
DECLARE @sub_id INT
DECLARE @xcel_sub_id INT
DECLARE @as_of_date DATETIME
DECLARE @strategy_name VARCHAR(20)
DECLARE @xcel_owned_counterparty INT
DECLARE @default_uom INT
DECLARE @trader VARCHAR(50)

SET @xcel_sub_id=-1
SET @strategy_name='PPA'
set @xcel_owned_counterparty=201
set @default_uom=24
set @trader='Xcelgen'

Begin try

-- When inserting and updating, check if the Accounting book is already closed
	SELECT @as_of_date=as_of_date FROM manual_je_header WHERE manual_je_id=@manual_je_id

	IF @flag='i' OR @flag='u'
	BEGIN
			SELECT @sub_id=max(legal_entity_value_id) from 	rec_generator where generator_id=@generator_id

			if exists(select * from close_measurement_books where 
				dbo.FNAContractMonthFormat(as_of_date)=dbo.FNAContractMonthFormat(@as_of_date) and (sub_id=@sub_id or sub_id=@xcel_sub_id))
			BEGIN
					
				Exec spa_ErrorHandler 1, "Accounting Book already Closed for the Accounting Period ", 
						"spa_calc_invoice_volume_input", "DB Error", 
						"Accounting Book already Closed for the Accounting Period", ''

				RETURN
			END
	END

----
	If @flag='c'

	BEGIN
		SELECT dr_cr_match from manual_je_header WHERE manual_je_id=@manual_je_id
	END

----



	If @flag='i'

	BEGIN
		insert into [manual_je_detail] 
				(manual_je_id, gl_account_id, volume, uom, debit_amount, credit_amount, frequency, until_date, create_inventory, generator_id, gl_number_id) 
		values (@manual_je_id, @gl_account_id, @volume, @uom, @debit_amount, @credit_amount, @frequency, @until_date, @create_inventory, @generator_id, @gl_number_id)

		SET @manual_je_detail_id=SCOPE_IDENTITY()
	END
	else If @flag='u'

		update [manual_je_detail] 
		set 
			manual_je_id=@manual_je_id,
			gl_account_id=@gl_account_id,
			volume=@volume,
			uom=@uom,
			debit_amount=@debit_amount,
			credit_amount=@credit_amount,
			frequency=@frequency,
			until_date=@until_date,
			create_inventory=@create_inventory,
			generator_id=@generator_id,
			gl_number_id=@gl_number_id
			 
		where 
			manual_je_detail_id=@manual_je_detail_id

	else If @flag='d'

		delete [manual_je_detail]  where manual_je_detail_id=@manual_je_detail_id

	else If @flag='a'

		select 
			a.manual_je_detail_id,
			a.manual_je_id,
			a.gl_account_id,
			a.volume,
			a.uom,
			a.debit_amount,
			a.credit_amount,
			a.frequency,
			dbo.FNADATEFORMAT(a.until_date),
			a.create_inventory,
			a.generator_id,
			a.gl_number_id,
			iat.account_type_name,
			gsm.gl_account_number+'('+gsm.gl_account_name 
		from 
			[manual_je_detail]  a LEFT JOIN inventory_account_type iat 
			ON iat.gl_account_id=a.gl_account_id
			LEFT JOIN gl_system_mapping gsm on a.gl_number_id=gsm.gl_number_id
		where 
			manual_je_detail_id=@manual_je_detail_id

	else If @flag='s'

		select 
			manual_je_detail_id, 
			manual_je_id, 
			iat.account_type_name AS [Account Name], 
			volume AS Volume, 
			su.uom_name AS [UOM],
			debit_amount AS [Dr Amount], 
			credit_amount AS [Cr Amount], 
			CASE frequency WHEN 'o' THEN 'One Time' ELSE 'Reoccurance' END  AS [Frequency], 
			dbo.FNADATEFORMAT(until_date) AS [Occur Until], 
			CASE create_inventory WHEN 'n' THEN 'No' ELSE 'Yes' END AS [Create Inventory], 
			rg.name AS [Generator]
			--gsm.gl_account_name [GL Number ID]
			from [manual_je_detail] a
			 LEFT JOIN inventory_account_type iat ON iat.gl_account_id=a.gl_account_id
			 LEFT JOIN rec_generator rg ON rg.generator_id=a.generator_id
			 LEFT JOIN source_uom su ON su.source_uom_id=a.uom
			 --LEFT JOIN gl_system_mapping gsm on a.gl_number_id=gsm.gl_number_id
		WHERE
			manual_je_id=@manual_je_id


IF @create_inventory='y' AND @generator_id IS NOT NULL AND (@flag='i' OR @flag='u') -- Create inventory
	BEGIN
		DECLARE @user_login_id VARCHAR(100)
		DECLARE @process_id VARCHAR(100)
		DECLARE @tempTable VARCHAR(128)
		DECLARE @sql VARCHAR(5000)

		set @user_login_id=dbo.FNADBUser()
		set @process_id=REPLACE(newid(),'-','_')
		set @tempTable=dbo.FNAProcessTableName('deal_adjustment', @user_login_id,@process_id)
		
		set @sql='create table '+ @tempTable+'( 
		 [Book] [varchar] (255)  NULL ,      
		 [Feeder_System_ID] [varchar] (255)  NULL ,      
		 [Gen_Date_From] [varchar] (50)  NULL ,      
		 [Gen_Date_To] [varchar] (50)  NULL ,      
		 [Volume] [varchar] (255)  NULL ,      
		 [UOM] [varchar] (50)  NULL ,      
		 [Price] [varchar] (255)  NULL ,      
		 [Formula] [varchar] (255)  NULL ,      
		 [Counterparty] [varchar] (50)  NULL ,      
		 [Generator] [varchar] (50)  NULL ,      
		 [Deal_Type] [varchar] (10)  NULL ,      
		 [Deal_Sub_Type] [varchar] (10)  NULL ,      
		 [Trader] [varchar] (100)  NULL ,      
		 [Broker] [varchar] (100)  NULL ,      
		 [Rec_Index] [varchar] (255)  NULL ,      
		 [Frequency] [varchar] (10)  NULL ,      
		 [Deal_Date] [varchar] (50)  NULL ,      
		 [Currency] [varchar] (255)  NULL ,      
		 [Category] [varchar] (20)  NULL ,      
		 [buy_sell_flag] [varchar] (10)  NULL,
		 [leg] [varchar] (20)  NULL ,
		 [settlement_volume] varchar(100),
		 [settlement_uom] varchar(100))
	'
		exec(@sql)

	set @sql=
		'
		INSERT INTO '+@tempTable+'
			(BOOK,
			[feeder_system_id],
			[Gen_Date_From],
			[Gen_Date_To],
			Volume,
			UOM,
			Price,
			Counterparty,
			Generator,
			[Deal_Type],
			Frequency,
			trader,
			[deal_date],
			currency,
			buy_sell_flag,
			leg,
	 		settlement_volume,
			settlement_uom  
			)
		SELECT 
			s.entity_name+''_''+case when rg.ppa_counterparty_id='+cast(@xcel_owned_counterparty as varchar)+' then ''Owned'' else ''PPA'' end +''_''+sd1.code, 
			''ADJ_'+CAST(@manual_je_detail_id AS VARCHAR)+'_''+cast(rg.generator_id as varchar),
			dbo.FNAGetSQLStandardDate(dbo.FNAGetContractMonth('''+cast(@as_of_date as varchar)+''')),
			dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate('''+cast(@as_of_date as varchar)+''')),
			FLOOR('+CAST(@volume AS VARCHAR)+'*ISNULL(conv.conversion_factor,1)),
			'+cast(@default_uom as varchar)+',
			NULL,
			rg.ppa_counterparty_id,
			rg.generator_id,
			''Rec Energy'',
			''m'',
			'''+@trader+''',
			dbo.FNAGetSQLStandardDate(dbo.FNAGetContractMonth('''+cast(@as_of_date as varchar)+''')),
			''USD'',
			''b'',
			1,	
			'+CAST(@volume AS VARCHAR)+' AS settlement_volume,
			'+CAST(@uom AS VARCHAR)+'
		FROM
			contract_group cg 	
			LEFT JOIN rec_generator rg on rg.ppa_contract_id=cg.contract_id
			INNER JOIN static_data_value sd on rg.state_value_id=sd.value_id
			INNER JOIN portfolio_hierarchy s on s.entity_id=rg.legal_entity_value_id
			LEFT JOIN static_data_value sd1 on sd1.value_id=rg.state_value_id
			LEFT JOIN rec_volume_unit_conversion conv on '+CAST(@uom AS VARCHAR)+'=conv.from_source_uom_id and conv.to_source_uom_id='+cast(@default_uom as varchar)+'
				AND conv.state_value_id is null 
				AND conv.assignment_type_value_id is null
				AND conv.curve_id is null 
				AND to_curve_id IS NULL
		WHERE 1=1
			AND generator_id='+CAST(@generator_id AS VARCHAR)
		
		EXEC(@sql)
		EXEC spb_process_transactions @user_login_id,@tempTable,'n','n'

	END


	DECLARE @msg varchar(2000)
	SELECT @msg=''
	if @flag='i'
		SET @msg='Data Successfully Inserted.'
	ELSE if @flag='u'
		SET @msg='Data Successfully Updated.'
	ELSE if @flag='d'
		SET @msg='Data Successfully Deleted.'

	IF @msg<>''
		select 'Success', 'manual_je_detailtable', 
				'spa_manual_je_detail', 'Success', 
				@msg, ''
END try
begin catch
	DECLARE @error_number int
	SET @error_number=error_number()
	SET @msg_err=''


	if @flag='i'
		SET @msg_err='Fail Insert Data.'
	ELSE if @flag='u'
		SET @msg_err='Fail Update Data.'
	ELSE if @flag='d'
		SET @msg_err='Fail Delete Data.'
	SET @msg_err='Fail Delete Data (' + error_message() +')'
		select 'Error', @msg_err, 
				'spa_manual_je_header', 'DB Error', 
				@msg_err, ''


END catch

