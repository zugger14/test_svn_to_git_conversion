/****** Object:  StoredProcedure [dbo].[spa_finalize_invoice]    Script Date: 04/09/2009 16:56:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_finalize_invoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_finalize_invoice]
/****** Object:  StoredProcedure [dbo].[spa_finalize_invoice]    Script Date: 04/09/2009 16:56:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_finalize_invoice] 
	@asofdate DATETIME
	,@counterparty_id INT = NULL
	,@contract_id INT = NULL
	,@prod_date DATETIME = NULL
	,@book_entries CHAR(1) = NULL
	,@finalize_invoice CHAR(1) = NULL
	,@calc_id INT = NULL
	,@charge_type VARCHAR(500) = NULL
	,@invoice_type CHAR(1) = NULL
    ,@settlement_date DATETIME = NULL
AS
BEGIN
	-- first create a deal
	---------------------------------------------------------
	DECLARE @sqlStmt VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @tempTable VARCHAR(300)
	DECLARE @process_id VARCHAR(50)
	DECLARE @deal_type INT
	DECLARE @count INT
	DECLARE @strategy_name VARCHAR(100)
	DECLARE @source_deal_header_id INT
	DECLARE @strategy_name_for_mv90 VARCHAR(100)
	DECLARE @trader VARCHAR(100)
	DECLARE @default_uom INT
	DECLARE @xcel_owned_counterparty INT
	DECLARE @sub_id INT
	DECLARE @xcel_sub_id INT

	SET @xcel_owned_counterparty = 201
	SET @strategy_name_for_mv90 = 'PPA'
	SET @trader = 'Xcelgen'
	SET @default_uom = 24
	SET @deal_type = 5149
	SET @xcel_sub_id = - 1

	-------------------------------------------------------
	-- update 
	-- 	calc_invoice_volume_variance
	-- set 
	-- 	book_entries=@book_entries
	-- where 
	-- 	counterparty_id=@counterparty_id and
	-- 	contract_id=@contract_id and
	-- 	dbo.FNAGetContractmonth(as_of_date)=dbo.FNAGetContractmonth(@asofdate) and
	-- 	dbo.FNAGetContractmonth(prod_date)=dbo.FNAGetContractmonth(@prod_date) 
	SELECT @sub_id = max(legal_entity_value_id)
	FROM rec_generator
	WHERE ppa_counterparty_id = @counterparty_id

	IF EXISTS (
			SELECT *
			FROM close_measurement_books
			WHERE dbo.FNAContractMonthFormat(as_of_date) = dbo.FNAContractMonthFormat(@asofdate)
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
			,"Accounting Book already Closed for the Accounting Period"
			,''

		RETURN
	END

	UPDATE invoice_header
	SET STATUS = @finalize_invoice
	WHERE counterparty_id = @counterparty_id
		AND contract_id = @contract_id
		AND
		--dbo.FNAGetContractmonth(as_of_date)=dbo.FNAGetContractmonth(@asofdate) and
		dbo.FNAGetContractmonth(production_month) = dbo.FNAGetContractmonth(@prod_date)

	-------------------------------------------------------------
	SELECT @count = count(DISTINCT generator_id)
	FROM recorder_generator_map
	WHERE meter_id IN (
			SELECT DISTINCT meter_id
			FROM recorder_generator_map
			WHERE meter_id IN (
					SELECT rgm.meter_id
					FROM recorder_generator_map rgm
					INNER JOIN rec_generator rg
						ON rg.generator_id = rgm.generator_id
					WHERE ppa_counterparty_id = @counterparty_id
					)
			)

	--if @count is null
	--  set @count=1 	
	--IF @count>1 	
	--BEGIN
	----	set @user_login_id=dbo.FNADBUser()
	----	set @process_id=REPLACE(newid(),'-','_')
	----	set @tempTable=dbo.FNAProcessTableName('deal_invoice', @user_login_id,@process_id)
	----	set @sqlStmt='create table '+ @tempTable+'( 
	----	 [Book] [varchar] (255)  NULL ,      
	----	 [Feeder_System_ID] [varchar] (255)  NULL ,      
	----	 [Gen_Date_From] [varchar] (50)  NULL ,      
	----	 [Gen_Date_To] [varchar] (50)  NULL ,      
	----	 [Volume] [varchar] (255)  NULL ,      
	----	 [UOM] [varchar] (50)  NULL ,      
	----	 [Price] [varchar] (255)  NULL ,      
	----	 [Formula] [varchar] (255)  NULL ,      
	----	 [Counterparty] [varchar] (50)  NULL ,      
	----	 [Generator] [varchar] (50)  NULL ,      
	----	 [Deal_Type] [varchar] (10)  NULL ,      
	----	 [Deal_Sub_Type] [varchar] (10)  NULL ,      
	----	 [Trader] [varchar] (100)  NULL ,      
	----	 [Broker] [varchar] (100)  NULL ,      
	----	 [Rec_Index] [varchar] (255)  NULL ,      
	----	 [Frequency] [varchar] (10)  NULL ,      
	----	 [Deal_Date] [varchar] (50)  NULL ,      
	----	 [Currency] [varchar] (255)  NULL ,      
	----	 [Category] [varchar] (20)  NULL ,      
	----	 [buy_sell_flag] [varchar] (10)  NULL,
	----	 [leg] [varchar] (20)  NULL ,
	----	 [settlement_volume] varchar(100),
	----	 [settlement_uom] varchar(100))
	----'
	----	exec(@sqlStmt)
	----set @sqlStmt=
	----	'
	----	INSERT INTO '+@tempTable+'
	----		(BOOK,
	----		[feeder_system_id],
	----		[Gen_Date_From],
	----		[Gen_Date_To],
	----		Volume,
	----		UOM,
	----		Price,
	----		Counterparty,
	----		Generator,
	----		[Deal_Type],
	----		Frequency,
	----		trader,
	----		[deal_date],
	----		currency,
	----		buy_sell_flag,
	----		leg,
	----	 	settlement_volume,
	----		settlement_uom  
	----		)
	----	SELECT 
	----		--s.entity_name+''_''+'''+@strategy_name_for_mv90+'''+''_''+sd1.code,
	----		s.entity_name+''_''+case when tmp.counterparty_id='+cast(@xcel_owned_counterparty as varchar)+' then ''Owned'' else ''PPA'' end +''_''+sd1.code, 
	----		''mv90_''+cast(rg.generator_id as varchar)+''_''+dbo.FNAContractMonthFormat('''+cast(@prod_date as varchar)+'''),
	----		dbo.FNAGetSQLStandardDate(dbo.FNAGetContractMonth('''+cast(@prod_date as varchar)+''')),
	----		dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate('''+cast(@prod_date as varchar)+''')),
	----		FLOOR(ISNULL(rg.contract_allocation,1)*tmp.allocationvolume*conv.conversion_factor),
	----		'+cast(@default_uom as varchar)+',
	----		NULL,
	----		tmp.counterparty_id,
	----		rg.generator_id,
	----		''Rec Energy'',
	----		''m'',
	----		'''+@trader+''',
	----		dbo.FNAGetSQLStandardDate(dbo.FNAGetContractMonth('''+cast(@prod_date as varchar)+''')),
	----		''USD'',
	----		''b'',
	----		  1,	
	----		  ISNULL(rg.contract_allocation,1)*tmp.allocationvolume as settlement_volume,
	----		  tmp.uom	
	----	from
	----		contract_group cg inner join 	
	----		rec_generator rg on rg.ppa_contract_id=cg.contract_id
	----		left join
	----		Calc_Invoice_Volume_variance tmp  on tmp.contract_id=cg.contract_id	
	----		inner join static_data_value sd on rg.state_value_id=sd.value_id
	----		join portfolio_hierarchy s on s.entity_id=rg.legal_entity_value_id
	----		left join static_data_value sd1 on sd1.value_id=rg.state_value_id
	----		left join rec_volume_unit_conversion conv on
	----		tmp.uom=conv.from_source_uom_id and conv.to_source_uom_id='+cast(@default_uom as varchar)+'
	----		and conv.state_value_id is null and conv.assignment_type_value_id is null
	----		and conv.curve_id is null 
	----		where tmp.counterparty_id='+cast(@counterparty_id as varchar)+' and
	----		tmp.contract_id='+cast(@contract_id as varchar)+' and
	----		dbo.FNAGetContractMonth(tmp.prod_date)=dbo.FNAGetContractMonth('''+cast(@prod_date as varchar)+''') 
	----		and dbo.FNAGetContractMonth(tmp.as_of_date)=dbo.FNAGetCOntractMonth('''+cast(@asofdate as varchar)+''') 
	----		and tmp.allocationvolume>0
	----	'	
	----	--print @sqlStmt
	----	EXEC(@sqlStmt)
	----	exec spb_process_transactions @user_login_id,@tempTable,'n','n'
	--END
	SELECT @source_deal_header_id = source_deal_header_id
	FROM source_deal_header
	WHERE deal_id = 'mv90_' + cast(@counterparty_id AS VARCHAR) + '_' + cast(dbo.FNAContractMonthFormat(@prod_date) AS VARCHAR)

	-------------------------------------------------------------------------------------------
	IF @@ERROR <> 0
		--WARNING! ERRORS ENCOUNTERED DURING SQL PARSING!
	BEGIN
		EXEC spa_ErrorHandler @@ERROR
			,'Finalize Invoice'
			,'spa_finalize_invoice'
			,'DB Error'
			,'Failed Finalizing Invoice.'
			,'Failed Finalizing Invoice'
	END
	ELSE
	BEGIN
		IF @finalize_invoice IS NOT NULL
		BEGIN
			IF @charge_type IS NOT NULL
			BEGIN
				SET @sqlStmt = 'update civ
					set civ.finalized=''' + @finalize_invoice + ''' 
					FROM
						Calc_Invoice_Volume civ
						JOIN calc_invoice_volume_variance civv ON civ.calc_id=civv.calc_id
					where 
						civv.counterparty_id=' + cast(@counterparty_id AS VARCHAR) + '
						AND civv.contract_id=' + cast(@contract_id AS VARCHAR) + '
						AND civv.prod_date=''' + cast(@prod_date AS VARCHAR) + '''
						AND civv.as_of_date=''' + cast(@asofdate AS VARCHAR) + '''	
						--calc_id=' + cast(@calc_id AS VARCHAR) + ' 
						and civ.invoice_line_item_id  in(' + @charge_type + ')
						AND civv.invoice_type=''' + @invoice_type + '''
                                                AND civv.settlement_date=''' + cast(@settlement_date AS VARCHAR)+''''

				EXEC spa_print @sqlStmt

				EXEC (@sqlStmt)

				IF NOT EXISTS (
						SELECT *
						FROM calc_invoice_volume civ
						JOIN calc_invoice_volume_variance civv
							ON civ.calc_id = civv.calc_id
						WHERE civv.counterparty_id = @counterparty_id
							AND civv.contract_id = @contract_id
							AND civv.prod_date = @prod_date
							AND civv.as_of_date = @asofdate
							--calc_id=@calc_id 
							AND isnull(civ.finalized, 'n') = 'n'
							AND civv.invoice_type = @invoice_type
                                                        AND civv.settlement_date = @settlement_date
						)
					UPDATE Calc_Invoice_Volume_variance
					SET finalized = 'y'
					WHERE
						--calc_id=@calc_id
						counterparty_id = @counterparty_id
						AND contract_id = @contract_id
						AND prod_date = @prod_date
						AND as_of_date = @asofdate
						AND invoice_type = @invoice_type
                                                AND settlement_date = @settlement_date

				ELSE
					UPDATE Calc_Invoice_Volume_variance
					SET finalized = 'n'
					WHERE
						--calc_id=@calc_id
						counterparty_id = @counterparty_id
						AND contract_id = @contract_id
						AND prod_date = @prod_date
						AND as_of_date = @asofdate
						AND invoice_type = @invoice_type
                                                AND settlement_date = @settlement_date	
			END
			ELSE
				UPDATE Calc_Invoice_Volume_variance
				SET finalized = @finalize_invoice
				WHERE counterparty_id = @counterparty_id
					AND contract_id = @contract_id
					AND dbo.FNAContractMonthFormat(prod_date) = dbo.FNAContractMonthFormat(@prod_date)
		END

		EXEC spa_ErrorHandler 0
			,'Finalize Invoice'
			,'spa_finalize_invoice'
			,'Success'
			,@source_deal_header_id
			,''
	END
END
