IF EXISTS (
		SELECT * FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_invoice_volume_input]') AND type IN ( N'P' ,N'PC' ) )
	DROP PROCEDURE [dbo].[spa_calc_invoice_volume_input]
GO

CREATE PROCEDURE [dbo].[spa_calc_invoice_volume_input] 
	 @flag CHAR(1) = NULL
	,@counterparty_id INT = NULL
	,@calc_detail_id INT = NULL
	,@calc_id INT = NULL
	,@invoice_line_item_id INT = NULL
	,@prod_date DATETIME = NULL
	,@value FLOAT = NULL
	,@volume FLOAT = NULL
	,@default_gl_id INT = NULL
	,@uom_id INT = NULL
	,@sub_id INT = NULL
	,@remarks VARCHAR(100) = NULL
	,@as_of_date DATETIME = NULL
	,@finalized CHAR(1) = NULL
	,@adjustment_type CHAR(1) = NULL
	,@finalized_id INT = NULL
	,@inv_prod_date DATETIME = NULL
	,@include_volume CHAR(1) = NULL
	,@default_gl_id_estimate INT = NULL
	,@inventory CHAR(1) = 'n'
	,@invoice_type CHAR(1) = NULL
	,@contract_id INT = NULL
	,@apply_cash_calc_detail_id INT = NULL
	,@is_adjustment_entry CHAR(1) = 'n'
AS
SET NOCOUNT ON
BEGIN
	DECLARE @default_gl_id_new INT
	DECLARE @default_gl_id_new_estimate INT
	DECLARE @sql VARCHAR(5000)
	DECLARE @xcel_sub_id INT
	DECLARE @strategy_name_for_mv90 VARCHAR(100)
	DECLARE @trader VARCHAR(100)
	DECLARE @default_uom INT
	DECLARE @xcel_owned_counterparty INT
	DECLARE @deal_type INT
	DECLARE @generator_id INT
	
	
	SET @xcel_owned_counterparty = 201
	SET @strategy_name_for_mv90 = 'PPA'
	SET @trader = 'Xcelgen'
	SET @default_uom = 24
	SET @deal_type = 5149
	SET @xcel_sub_id = - 1

	SELECT @generator_id = generator_id
	FROM calc_invoice_volume_variance
	WHERE calc_id = @calc_id

	IF @flag = 'i'
		OR @flag = 'u'
	BEGIN
		IF EXISTS (
				SELECT *
				FROM close_measurement_books
				WHERE dbo.FNAContractMonthFormat(as_of_date) = dbo.FNAContractMonthFormat(@as_of_date)
					AND (
						sub_id = @sub_id
						OR sub_id = @xcel_sub_id
						)
				)
		BEGIN
			EXEC spa_ErrorHandler 1
				,"Accounting Book already Closed for the Accounting Period "
				,"spa_calc_invoice_volume_input"
				,"DB Error"
				,"Accounting Book already Closed for Accounting Period"
				,''

			RETURN
		END
	END

	IF @flag = 'd'
	BEGIN
		SELECT @calc_id = max(calc_id)
		FROM calc_invoice_volume
		WHERE calc_detail_id = @calc_detail_id

		SELECT @counterparty_id = counterparty_id
			,@as_of_date = as_of_date
		FROM calc_invoice_volume_variance
		WHERE calc_id = @calc_id

		SELECT @sub_id = max(legal_entity_value_id)
		FROM rec_generator
		WHERE ppa_counterparty_id = @counterparty_id

		IF EXISTS (
				SELECT *
				FROM close_measurement_books
				WHERE dbo.FNAContractMonthFormat(as_of_date) = dbo.FNAContractMonthFormat(@as_of_date)
					AND (
						sub_id = @sub_id
						OR sub_id = @xcel_sub_id
						)
				)
		BEGIN
			EXEC spa_ErrorHandler 1
				,"Accounting Book already Closed for the Accounting Period "
				,"spa_calc_invoice_volume_input"
				,"DB Error"
				,"Accounting Book already Closed for Accounting Period"
				,''

			RETURN
		END
	END

	SELECT @default_gl_id_new = default_gl_id
	FROM invoice_lineitem_default_glcode
	WHERE invoice_line_item_id = @invoice_line_item_id
		AND sub_id = @sub_id
		AND estimated_actual = 'a'

	SELECT @default_gl_id_new_estimate = default_gl_id
	FROM invoice_lineitem_default_glcode
	WHERE invoice_line_item_id = @invoice_line_item_id
		AND sub_id = @sub_id
		AND estimated_actual = 'e'

	IF @flag = 's'
	BEGIN
		SET @sql = 
			' select
		 civ.calc_detail_id,civ.calc_id,
		dbo.FNADateFormat(civv.as_of_date) [As of Date],
		dbo.FNADateFormat(civ.prod_date) [Prod Month],
		dbo.FNADateFormat(civ.inv_prod_date) [Inv Prod Month],
		sd.description [Contract Components],sd1.description [GL Account Actual],sd2.description [GL Account Estimates],
	    value [Value],Volume Volume,su.uom_name [UOM]
	from 
		calc_invoice_volume civ inner join calc_invoice_volume_variance civv
		on civ.calc_id=civv.calc_id left join
		static_data_value sd on sd.value_id=civ.invoice_Line_item_id
		left join adjustment_default_gl_codes adgc on civ.default_gl_id=adgc.default_gl_id
		left join adjustment_default_gl_codes adgc1 on civ.default_gl_id_estimate=adgc1.default_gl_id
		left join static_data_value sd1 on adgc.adjustment_type_id=sd1.value_id 
		left join static_data_value sd2 on adgc1.adjustment_type_id=sd2.value_id 
		left join source_uom su on su.source_uom_id=civ.uom_id
		--left join calc_invoice_volume civ1 on civ1.calc_detail_id=civ.calc_detail_id
	where
		civv.counterparty_id=' 
			+ cast(@counterparty_id AS VARCHAR) + '
		and manual_input=''y''
		and civv.as_of_date=''' + cast(@as_of_date AS VARCHAR) + '''
		and civ.finalized=''' + @adjustment_type + '''
		and civv.prod_date=''' + cast(@prod_date AS VARCHAR) + ''''
			--case when @adjustment_type='n' then ' 
			--AND civ.finalized_id is null and civ.calc_detail_id not in
			--(select isnull(finalized_id,'''') from calc_invoice_volume civ inner join calc_invoice_volume_variance civv 
			--	on civ.calc_id=civv.calc_id where  dbo.fnagetcontractmonth(civv.as_of_date)<=dbo.fnagetcontractmonth('''+cast(@as_of_date as varchar)+'''))
			--' else '  '  end
			+ CASE 
				WHEN @invoice_type IS NOT NULL
					THEN ' AND civv.invoice_type=''' + @invoice_type + ''''
				ELSE ''
				END + + CASE 
				WHEN @contract_id IS NOT NULL
					THEN ' AND civv.contract_id=''' + CAST(@contract_id AS VARCHAR) + ''''
				ELSE ''
				END + ' 
	order by civ.prod_date '

		--PRINT @sql

		EXEC (@sql)
	END
	ELSE
		IF @flag = 'a'
		BEGIN
			SELECT civ.calc_detail_id
				,civ.calc_id
				,CONVERT(VARCHAR(10), civ.prod_date, 120) [ Production Month]
				,civ.invoice_Line_item_id
				,value [Value]
				,volume
				,default_gl_id
				,uom_id
				,remarks
				,civ.finalized
				,CONVERT(VARCHAR(10), civ.inv_prod_date, 120) [ Production Month]
				,include_volume
				,CONVERT(VARCHAR(10), civv.as_of_date, 120) [ Production Month]
				,inventory
			FROM calc_invoice_volume civ
			INNER JOIN calc_invoice_volume_variance civv
				ON civ.calc_id = civv.calc_id
			WHERE civ.calc_detail_id = @calc_detail_id
		END
		ELSE
			IF @flag = 'i'
			BEGIN
				IF @finalized_id IS NOT NULL
				BEGIN
					-- check if production month is already finalized
					IF EXISTS (
							SELECT civ.*
							FROM calc_invoice_volume civ
							INNER JOIN calc_invoice_volume_variance civv
								ON civ.calc_id = civv.calc_id
							WHERE civ.finalized_id = @finalized_id
							)
					BEGIN
						EXEC spa_ErrorHandler 1
							,"Adjustment already finalized for the Month."
							,"spa_calc_invoice_volume_input"
							,"DB Error"
							,"Adjustment already Finalized for the Production Month."
							,''

						RETURN
					END

					--if exists(
					--select civ.* 
					--			  from calc_invoice_volume civ inner join calc_invoice_volume_variance civv
					--				on civ.calc_id=civv.calc_id
					--				where civ.calc_detail_id=@finalized_id and 
					--					  civv.as_of_date=@as_of_date and civv.prod_date=@prod_date
					--)
					--		delete from	calc_invoice_volume where calc_detail_Id=@finalized_id	
					UPDATE calc_invoice_volume
					SET invoice_line_item_id = @invoice_line_item_id
						,prod_date = dbo.fnagetcontractmonth(@prod_date)
						,value = @value
						,volume = @volume
						,default_gl_id = @default_gl_id
						,uom_id = @uom_id
						,remarks = @remarks
						,inv_prod_date = dbo.fnagetcontractmonth(@inv_prod_date)
						,include_volume = @include_volume
						,default_gl_id_estimate = @default_gl_id_estimate
						,inventory = @inventory
						,finalized = @finalized
						,is_adjustment_entry = @is_adjustment_entry
					WHERE calc_detail_id = @finalized_id
				END
				ELSE
					INSERT INTO calc_invoice_volume (
						calc_id
						,invoice_line_item_id
						,prod_date
						,value
						,manual_input
						,volume
						,default_gl_id
						,uom_id
						,remarks
						,finalized
						,finalized_id
						,inv_prod_date
						,include_volume
						,default_gl_id_estimate
						,inventory
						,apply_cash_calc_detail_id
						,is_adjustment_entry
						)
					SELECT @calc_id
						,@invoice_line_item_id
						,dbo.fnagetcontractmonth(@prod_date)
						,@value
						,'y'
						,@volume
						,ISNULL(@default_gl_id, @default_gl_id_new)
						,@uom_id
						,@remarks
						,@finalized
						,@finalized_id
						,dbo.fnagetcontractmonth(@inv_prod_date)
						,@include_volume
						,ISNULL(@default_gl_id_estimate, @default_gl_id_new_estimate)
						,@inventory
						,@apply_cash_calc_detail_id
						,@is_adjustment_entry
				
				IF @is_adjustment_entry = 'n'
				BEGIN
					IF @@ERROR <> 0
						EXEC spa_ErrorHandler @@ERROR
							,"calc invoice Volume"
							,"spa_calc_invoice_volume_input"
							,"DB Error"
							,"Error  Inserting Data."
							,''
					ELSE
						EXEC spa_ErrorHandler 0
							,'calc invoice Volume'
							,'spa_meter'
							,'Success'
							,'Data Inserted Successfully.'
							,''
				END
			END
			ELSE
				IF @flag = 'u'
				BEGIN
					UPDATE calc_invoice_volume
					SET invoice_line_item_id = @invoice_line_item_id
						,prod_date = dbo.fnagetcontractmonth(@prod_date)
						,value = @value
						,volume = @volume
						,default_gl_id = @default_gl_id
						,uom_id = @uom_id
						,remarks = @remarks
						,inv_prod_date = dbo.fnagetcontractmonth(@inv_prod_date)
						,include_volume = @include_volume
						,default_gl_id_estimate = @default_gl_id_estimate
						,inventory = @inventory
					WHERE calc_detail_id = @calc_detail_id

					IF @@ERROR <> 0
						EXEC spa_ErrorHandler @@ERROR
							,"calc invoice Volume"
							,"spa_calc_invoice_volume_input"
							,"DB Error"
							,"Error  Updating Data."
							,''
					ELSE
						EXEC spa_ErrorHandler 0
							,'calc invoice Volume'
							,'spa_meter'
							,'Success'
							,'Data Updated Successfully.'
							,''
				END
				ELSE
					IF @flag = 'd'
					BEGIN
						DELETE calc_invoice_volume
						WHERE calc_detail_id = @calc_detail_id

						IF @@ERROR <> 0
							EXEC spa_ErrorHandler @@ERROR
								,"calc invoice Volume"
								,"spa_calc_invoice_volume_input"
								,"DB Error"
								,"Error  Deleting Data."
								,''
						ELSE
							EXEC spa_ErrorHandler 0
								,'calc invoice Volume'
								,'spa_meter'
								,'Success'
								,'Data Deleted Successfully.'
								,''
					END

	-----######### logic to create adjustments deals if the inventory checkbox is clicked.
	IF @flag = 'i'
		OR @flag = 'u'
		AND @inventory = 'y'
		AND @volume <> 0
	BEGIN
		DECLARE @user_login_id VARCHAR(50)
		DECLARE @process_id VARCHAR(50)
		DECLARE @tempTable VARCHAR(128)

		SET @user_login_id = dbo.FNADBUser()
		SET @process_id = REPLACE(newid(), '-', '_')
		SET @tempTable = dbo.FNAProcessTableName('deal_invoice', @user_login_id, @process_id)
		SET @sql = 'create table ' + @tempTable + 
			'( 
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

		EXEC (@sql)

		SET @sql = '
		INSERT INTO ' + @tempTable + '
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
			s.entity_name+''_''+case when tmp.counterparty_id=' + cast(@xcel_owned_counterparty AS VARCHAR) + ' then ''Owned'' else ''PPA'' end +''_''+sd1.code, 
			''mv90_''+cast(rg.generator_id as varchar)+''_''+dbo.FNAContractMonthFormat(''' + cast(@prod_date AS VARCHAR) + '''),
			dbo.FNAGetSQLStandardDate(dbo.FNAGetContractMonth(''' + cast(@prod_date AS VARCHAR) + ''')),
			dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(''' + cast(@prod_date AS VARCHAR) + ''')),
			FLOOR(' + CAST(@volume AS VARCHAR) + '*conv.conversion_factor),
			' + cast(@default_uom AS VARCHAR) + ',
			NULL,
			tmp.counterparty_id,
			rg.generator_id,
			''Rec Energy'',
			''m'',
			''' + @trader + 
			''',
			dbo.FNAGetSQLStandardDate(dbo.FNAGetContractMonth(''' + cast(@prod_date AS VARCHAR) + ''')),
			''USD'',
			''b'',
			1,	
			' + CAST(@volume AS VARCHAR) + ' AS settlement_volume,
			' + CAST(@uom_id AS VARCHAR) + '
		FROM
			contract_group cg 	
			LEFT JOIN rec_generator rg on rg.ppa_contract_id=cg.contract_id
			LEFT JOIN calc_Invoice_Volume_variance tmp  on tmp.contract_id=cg.contract_id	
			INNER JOIN static_data_value sd on rg.state_value_id=sd.value_id
			INNER JOIN portfolio_hierarchy s on s.entity_id=rg.legal_entity_value_id
			LEFT JOIN static_data_value sd1 on sd1.value_id=rg.state_value_id
			LEFT JOIN rec_volume_unit_conversion conv on ' + CAST(@uom_id AS VARCHAR) + '=conv.from_source_uom_id and conv.to_source_uom_id=' + cast(@default_uom AS VARCHAR) + '
				AND conv.state_value_id is null 
				AND conv.assignment_type_value_id is null
				AND conv.curve_id is null 
		WHERE
			tmp.calc_id=' + cast(@calc_id AS VARCHAR) + ' 
			AND tmp.allocationvolume>0
		'

		EXEC (@sql)

		EXEC spb_process_transactions @user_login_id
			,@tempTable
			,'n'
			,'n'
	END
END
