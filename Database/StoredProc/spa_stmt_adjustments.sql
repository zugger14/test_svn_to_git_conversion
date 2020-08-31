IF OBJECT_ID(N'[dbo].[spa_stmt_adjustments]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_stmt_adjustments]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 /**
	Calculation of the Settlement Adjustment

	Parameters :
	@flag : Flag 'd' - Run Adjustment
	@counterparty_id : Counterparty Id Filter
	@prod_date_from : Prod Date From Filter
	@prod_date_to : Prod Date To Filter
	@sub_id : Sub Id Filter
	@strategy_id : Strategy Id Filter
	@book_id : Book Id Filter
	@subbook_id : Subbook Id Filter
	@contract_ID : Contract ID Filter
	@deal_set_calc : always 'n' (n - dont calc deal settlement, y - calc deal settlement also)
	@deal_id : Deal Id Filter
	@batch_process_id : Batch Process Id
	@batch_report_param : Batch Report Param
 */

CREATE PROC [dbo].[spa_stmt_adjustments]
	@flag char(1),
	@counterparty_id VARCHAR(MAX) = null,
	@prod_date_from datetime = null,
	@prod_date_to datetime = null,
	@sub_id VARCHAR(1000)=NULL,
	@strategy_id VARCHAR(1000) = NULL,
	@book_id VARCHAR(1000) = NULL,
	@subbook_id VARCHAR(1000) =NULL,
	@contract_ID VARCHAR(MAX)=NULL,
	@deal_set_calc CHAR(1) = 'n',
	@deal_id VARCHAR(MAX) = NULL,
	@batch_process_id    VARCHAR(50) = NULL, 
	@batch_report_param  VARCHAR(1000) = NULL
AS
/*
--EXEC spa_settlement_adjustments @flag = 'd',@counterparty_id = '7722',@prod_date_from = '2018-10-01',@prod_date_to = '2018-10-31',@sub_id = '2975',@strategy_id = '2976',@book_id = '2979',@subbook_id = '3977,3956,3955,3981,3960,3957',@contract_ID = ''
 
-- Test Data

	DECLARE 
		@flag char(1)= 'd',
		@counterparty_id VARCHAR(MAX) = '7789,4319,7504',
		@prod_date_from datetime = '2018-09-01',
		@prod_date_to datetime = '2018-09-30',
		@contract_ID VARCHAR(MAX)=NULL,
		@deal_set_calc CHAR(1) = 'n',
		@deal_id VARCHAR(MAX) = '64888',
		@batch_process_id    VARCHAR(50) = 'asdadasdfdfdfdfsdfdas', 
		@batch_report_param  VARCHAR(1000) = NULL,
		@sub_id VARCHAR(1000)= '2975,2983',
		@strategy_id VARCHAR(1000) = '2976,2986',
		@book_id VARCHAR(1000) = '2979,2996,2994,2995,3006',
		@subbook_id VARCHAR(1000) ='3977,3956,3955,3981,3960,3957,3971,3976,3970,3975,3972,3990,3992,3991'

--*/




	DECLARE @sql VARCHAR(MAX),@user_login_id VARCHAR(50)

	SET @user_login_id=dbo.FNADBUser()

IF @flag = 'd'
BEGIN
	IF @batch_process_id IS NULL
		SET @batch_process_id =  REPLACE(newid(),'-','_')
	
	DECLARE @as_of_date VARCHAR(10), @deal_settlement_table VARCHAR(200),@index_fees_settlement_table VARCHAR(200),@deal_list_table VARCHAR(200)


	SET @deal_list_table = dbo.FNAProcessTableName('deal_list', @user_login_id, @batch_process_id)
	SET @deal_settlement_table = dbo.FNAProcessTableName('deal_settlement', @user_login_id, @batch_process_id)
	SET @index_fees_settlement_table =  dbo.FNAProcessTableName('index_fees_settlement', @user_login_id, @batch_process_id)
	
	SET @as_of_date = CONVERT(VARCHAR(10),@prod_date_to,120)
	
	EXEC('CREATE TABLE '+@deal_list_table+' (source_deal_header_id INT)')
	
	IF OBJECT_ID('tempdb..#books') IS NOT NULL
		DROP TABLE #books

	CREATE TABLE #books(sub_id INT,strtegy_id INT,book_id INT,subbook_id INT,source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT,logical_name VARCHAR(100))

	SET @sql = '
		INSERT INTO #books
		SELECT 
		   sub.entity_id,
		   stra.entity_id,
		   book.entity_id,
		   ssbm.book_deal_type_map_id,
		   ssbm.source_system_book_id1,
		   ssbm.source_system_book_id2,
		   ssbm.source_system_book_id3,
		   ssbm.source_system_book_id4,
		   ssbm.logical_name
		FROM   
			PORTFOLIO_HIERARCHY book(nolock) INNER JOIN PORTFOLIO_HIERARCHY stra(nolock)
				   ON book.parent_entity_id = stra.entity_id INNER JOIN PORTFOLIO_HIERARCHY sub(nolock)
				   ON stra.parent_entity_id = sub.entity_id INNER JOIN SOURCE_SYSTEM_BOOK_MAP ssbm
				   ON ssbm.fas_book_id = book.entity_id INNER JOIN FAS_SUBSIDIARIES fs
				   ON fs.fas_subsidiary_id = sub.entity_id LEFT JOIN fas_strategy fst
				   ON fst.fas_strategy_id =  stra.entity_id LEFT JOIN fas_books fb ON fb.fas_book_id =  stra.entity_id 
		WHERE  1 = 1  '
		   +CASE WHEN NULLIF(@sub_id,'') IS NOT NULL THEN ' AND sub.entity_id IN ('+@sub_id+')' ELSE '' END
		   +CASE WHEN NULLIF(@strategy_id,'') IS NOT NULL THEN ' AND stra.entity_id IN ('+@strategy_id+')' ELSE '' END
		   +CASE WHEN NULLIF(@book_id,'') IS NOT NULL THEN ' AND book.entity_id IN ('+@book_id+')' ELSE '' END
		   +CASE WHEN NULLIF(@subbook_id,'') IS NOT NULL THEN ' AND ssbm.book_deal_type_map_id IN ('+@subbook_id+')' ELSE '' END

	EXEC(@sql)

	--####### Collect finalized Deals
	SET @sql = '
	INSERT INTO '+@deal_list_table+'
	SELECT 
		DISTINCT sdh.source_deal_header_id 
	FROM 
		source_deal_header sdh 
		INNER JOIN #books bk ON bk.source_system_book_id1 = sdh.source_system_book_id1
			AND bk.source_system_book_id2 = sdh.source_system_book_id2
			AND bk.source_system_book_id3 = sdh.source_system_book_id3
			AND bk.source_system_book_id4 = sdh.source_system_book_id4
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN stmt_checkout sc ON sdd.source_deal_detail_id = sc.source_deal_detail_id AND sc.stmt_invoice_detail_id IS NOT NULL
	WHERE 1=1 '
	+CASE WHEN @prod_date_from IS NOT NULL THEN ' AND sc.term_start >= '''+CONVERT(VARCHAR(10),@prod_date_from,120)+'''' ELSE '' END
	+CASE WHEN @prod_date_to IS NOT NULL THEN ' AND sc.term_end <= '''+CONVERT(VARCHAR(10),@prod_date_to,120)+'''' ELSE '' END
	+CASE WHEN NULLIF(@counterparty_id,'') IS NOT NULL THEN ' AND sdh.counterparty_id IN('+@counterparty_id+')' ELSE '' END
	+CASE WHEN NULLIF(@contract_id,'') IS NOT NULL THEN ' AND sdh.contract_id IN('+@contract_id+')' ELSE '' END
	+CASE WHEN NULLIF(@deal_id,'') IS NOT NULL THEN ' AND sdh.source_deal_header_id IN('+@deal_id+')' ELSE '' END
	EXEC spa_print @sql
	EXEC(@sql)

	SET @sql = 'EXEC  spa_calc_mtm_job NULL,NULL,NULL,NULL,NULL,''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''',4500,NULL,''b'',''' + @batch_process_id + ''',NULL,'''+@user_login_id+''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''n'',''' + CONVERT(VARCHAR(10),@prod_date_from,120) +''',''' + CONVERT(VARCHAR(10),@prod_date_to,120) +''',''s'',NULL,NULL,'''+@deal_list_table+''',NULL,NULL,NULL,NULL,NULL,0,0,1'
	EXEC spa_print @sql
	EXEC(@sql)

	IF OBJECT_ID(@deal_settlement_table)IS NOT NULL
	BEGIN
			if OBJECT_ID('tempdb..#temp_deal_settlement_adjustment') is not null drop table #temp_deal_settlement_adjustment
			CREATE TABLE #temp_deal_settlement_adjustment(
					as_of_date	 DATETIME,
					source_deal_header_id INT,
					leg INT,
					term_start DATETIME,
					term_end DATETIME,
					charge_type_id INT,
					shipment_id INT,
					ticket_detail_id INT,
					settlement_amount_pre FLOAT,
					settlement_amount_new FLOAT,
					settlement_amount FLOAT,
					volume_pre FLOAT,
					volume_new FLOAT,
					volume FLOAT,
					price_pre FLOAT,
					price_new FLOAT,
					price FLOAT,
					match_info_id INT
			)



			SET @sql = 'INSERT INTO #temp_deal_settlement_adjustment(as_of_date,source_deal_header_id,leg,term_start,term_end,charge_type_id,settlement_amount_pre,settlement_amount_new,settlement_amount,volume_pre,volume_new,volume,price_pre,price_new,price,shipment_id,ticket_detail_id,match_info_id)
				SELECT
					dst.as_of_date,dst.source_deal_header_id,dst.leg,dst.term_start,dst.term_end,-5500,
					ifbs.Value, dst.settlement_amount
					
					,  ROUND( dst.settlement_amount -  ifbs.Value, 6) ,
					
					ifbs.Volume, dst.volume
					
					, dst.volume -ifbs.Volume,
					
					ifbs.price , dst.net_price, dst.net_price - ifbs.price ,dst.shipment_id,dst.ticket_detail_id, dst.match_info_id
				FROM '+@deal_settlement_table+' dst
				INNER JOIN (
					SELECT source_deal_header_id, term_start, ticket_detail_id, field_id, SUM(volume) Volume, SUM([value]) [Value] , SUM(price) price
					FROM vwIndexFeesBreakdownStmt 
					--WHERE source_deal_header_id = 44012
					GROUP BY source_deal_header_id, term_start, ticket_detail_id, field_id
				) ifbs ON dst.source_deal_header_id = ifbs.source_deal_header_id
				AND dst.term_start = ifbs.term_start
				AND ISNULL(dst.ticket_detail_id, -1) = ISNULL(ifbs.ticket_detail_id, -1)
				AND ifbs.field_id = -5500
				--where dst.source_deal_header_id = 44012

				UNION ALL 
	
				SELECT
					dst.as_of_date,dst.source_deal_header_id,dst.leg,dst.term_start,dst.term_end,dst.field_id,
					ifbs.value, dst.value
					
					,ROUND(dst.value- ifbs.value, 6),
					
					ifbs.volume, dst.volume
					
					,dst.volume - ifbs.volume,
					
					ifbs.price, dst.price, dst.price - ifbs.price,
					dst.shipment_id,dst.ticket_detail_id, dst.match_info_id
				FROM
					'+@index_fees_settlement_table+' dst
					INNER JOIN (
					SELECT source_deal_header_id, term_start, ticket_detail_id, field_id, SUM(volume) Volume, SUM([value]) [Value] , SUM(price) price
					FROM vwIndexFeesBreakdownStmt 
					--WHERE source_deal_header_id = 44012
					GROUP BY source_deal_header_id, term_start, ticket_detail_id, field_id
				) ifbs ON dst.source_deal_header_id = ifbs.source_deal_header_id
				AND dst.term_start = ifbs.term_start
				AND ISNULL(dst.ticket_detail_id, -1) = ISNULL(ifbs.ticket_detail_id, -1)
				AND ifbs.field_id = dst.field_id	
				--where dst.source_deal_header_id = 44012
				
				'
				
				
				
			EXEC spa_print @sql
			EXEC(@sql)

			DELETE dst FROM 
			stmt_adjustments dst
			INNER  JOIN #temp_deal_settlement_adjustment tdsa ON dst.source_deal_header_id = tdsa.source_deal_header_id AND dst.leg=tdsa.leg AND dst.term_start=tdsa.term_start
				AND ISNULL(DST.shipment_id,-1) = ISNULL(tdsa.shipment_id,-1)
				AND ISNULL(dst.ticket_detail_id,-1) = ISNULL(tdsa.shipment_id,-1)
				AND ISNULL(dst.match_info_id,-1) = ISNULL(tdsa.match_info_id,-1)
			LEFT JOIN stmt_checkout sc ON sc.index_fees_id = dst.stmt_adjustments_id AND sc.[type] = 'Adjustment'
			WHERE sc.stmt_checkout_id IS NULL
			

			INSERT INTO stmt_checkout (
				source_deal_detail_id
				,shipment_id
				,ticket_id
				,deal_charge_type_id
				,contract_charge_type_id
				,counterparty_id
				,counterparty_name
				,contract_id
				,as_of_date
				,term_start
				,term_end
				,currency_id
				,uom_id
				,settlement_amount
				,settlement_volume
				,settlement_price
				,scheduled_volume
				,acutal_volume
				,is_reverted
				,status
				,index_fees_id
				,debit_gl_number
				,credit_gl_number
				,pnl_line_item_id
				,charge_type_alias
				,invoicing_charge_type_id
				,accrual_or_final
				,invoice_frequency
				,stmt_invoice_detail_id
				,create_user
				,create_ts
				,update_user
				,update_ts
				,type
				,accounting_month
				,is_ignore
				,reversal_stmt_checkout_id
				,match_info_id
			)
			SELECT DISTINCT 
				scf.source_deal_detail_id
				, scf.shipment_id
				, scf.ticket_id
				, scf.deal_charge_type_id
				, scf.contract_charge_type_id
				, scf.counterparty_id
				, scf.counterparty_name
				, scf.contract_id
				, scf.as_of_date
				, scf.term_start
				, scf.term_end
				, scf.currency_id
				, scf.uom_id
				, scf.settlement_amount * -1 [settlement_amount]
				, scf.settlement_volume * -1 [settlement_volume]
				, scf.settlement_price
				, scf.scheduled_volume
				, scf.acutal_volume
				, scf.is_reverted
				, scf.status
				, scf.index_fees_id
				, scf.credit_gl_number
				, scf.debit_gl_number
				, scf.pnl_line_item_id
				, scf.charge_type_alias
				, scf.invoicing_charge_type_id
				, 'd' [accrual_or_final]
				, scf.invoice_frequency
				, scf.stmt_invoice_detail_id
				, scf.create_user
				, scf.create_ts
				, scf.update_user
				, scf.update_ts
				, scf.type
				, DATEADD(mm,1,scf.accounting_month) [accoutning_month]
				, scf.is_ignore
				, scf.stmt_checkout_id
				, scf.match_info_id
			FROM #temp_deal_settlement_adjustment tmp
			INNER JOIN stmt_adjustments sta ON tmp.source_deal_header_id = sta.source_deal_header_id
				AND sta.term_start = tmp.term_start
				AND tmp.charge_type_id = sta.charge_type_id
				AND ISNULL(tmp.shipment_id,-1) = ISNULL(sta.shipment_id,-1)
				AND ISNULL(tmp.ticket_detail_id,-1) = ISNULL(sta.ticket_detail_id,-1)
				AND ISNULL(tmp.match_info_id,-1) = ISNULL(sta.match_info_id,-1)
			INNER JOIN stmt_checkout sc ON sc.index_fees_id = sta.stmt_adjustments_id AND sc.[type] = 'Adjustment' AND ISNULL(sc.is_ignore,0) = 0 AND ISNULL(sc.is_reversal_required,'n') = 'y'
			INNER JOIN stmt_invoice_detail sid ON sid.stmt_invoice_detail_id = sc.stmt_invoice_detail_id
			INNER JOIN stmt_invoice si ON si.stmt_invoice_id = sid.stmt_invoice_id
			INNER JOIN stmt_invoice_detail sidf ON sidf.stmt_invoice_id = si.stmt_invoice_id
			INNER JOIN stmt_checkout scf ON scf.stmt_invoice_detail_id = sidf.stmt_invoice_detail_id AND scf.accrual_or_final = 'f'
			LEFT JOIN stmt_checkout scr ON scr.reversal_stmt_checkout_id = scf.stmt_checkout_id
			WHERE scr.stmt_checkout_id IS NULL
			AND tmp.settlement_amount <> 0

			INSERT INTO stmt_checkout (
				source_deal_detail_id
				,shipment_id
				,ticket_id
				,deal_charge_type_id
				,contract_charge_type_id
				,counterparty_id
				,counterparty_name
				,contract_id
				,as_of_date
				,term_start
				,term_end
				,currency_id
				,uom_id
				,settlement_amount
				,settlement_volume
				,settlement_price
				,scheduled_volume
				,acutal_volume
				,is_reverted
				,status
				,index_fees_id
				,debit_gl_number
				,credit_gl_number
				,pnl_line_item_id
				,charge_type_alias
				,invoicing_charge_type_id
				,accrual_or_final
				,invoice_frequency
				,stmt_invoice_detail_id
				,create_user
				,create_ts
				,update_user
				,update_ts
				,type
				,accounting_month
				,is_ignore
				,reversal_stmt_checkout_id
				,match_info_id
			)
			SELECT DISTINCT 
				scf.source_deal_detail_id
				, scf.shipment_id
				, scf.ticket_id
				, scf.deal_charge_type_id
				, scf.contract_charge_type_id
				, scf.counterparty_id
				, scf.counterparty_name
				, scf.contract_id
				, scf.as_of_date
				, scf.term_start
				, scf.term_end
				, scf.currency_id
				, scf.uom_id
				, scf.settlement_amount * -1 [settlement_amount]
				, scf.settlement_volume * -1 [settlement_volume]
				, scf.settlement_price
				, scf.scheduled_volume
				, scf.acutal_volume
				, scf.is_reverted
				, scf.status
				, scf.index_fees_id
				, scf.credit_gl_number
				, scf.debit_gl_number
				, scf.pnl_line_item_id
				, scf.charge_type_alias
				, scf.invoicing_charge_type_id
				, 'd' [accrual_or_final]
				, scf.invoice_frequency
				, scf.stmt_invoice_detail_id
				, scf.create_user
				, scf.create_ts
				, scf.update_user
				, scf.update_ts
				, scf.type
				, DATEADD(mm,1,scf.accounting_month) [accoutning_month]
				, scf.is_ignore 
				, scf.stmt_checkout_id
				, scf.match_info_id
			FROM #temp_deal_settlement_adjustment tmp
			LEFT JOIN stmt_adjustments sta ON tmp.source_deal_header_id = sta.source_deal_header_id
				AND sta.term_start = tmp.term_start
				AND tmp.charge_type_id = sta.charge_type_id
				AND ISNULL(tmp.shipment_id,-1) = ISNULL(sta.shipment_id,-1)
				AND ISNULL(tmp.ticket_detail_id,-1) = ISNULL(sta.ticket_detail_id,-1)
				AND ISNULL(tmp.match_info_id,-1) = ISNULL(sta.match_info_id,-1)
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tmp.source_deal_header_id AND sdd.term_start = tmp.term_start
			INNER JOIN stmt_checkout sc ON sc.source_deal_detail_id = sdd.source_deal_detail_id
					AND sc.deal_charge_type_id = tmp.charge_type_id
					AND ISNULL(sc.shipment_id,-1) = ISNULL(tmp.shipment_id,-1)
					AND ISNULL(sc.match_info_id,-1) = ISNULL(tmp.match_info_id,-1)
					--AND ISNULL(sc.ticket_id,-1) = ISNULL(tmp.ticket_detail_id,-1)
					AND sc.[type] <> 'Adjustment'
					AND accrual_or_final = 'f'
					AND ISNULL(sc.is_ignore,0) = 0
					AND ISNULL(sc.is_reversal_required,'n') = 'y'
			INNER JOIN stmt_invoice_detail sid ON sid.stmt_invoice_detail_id = sc.stmt_invoice_detail_id
			INNER JOIN stmt_invoice si ON si.stmt_invoice_id = sid.stmt_invoice_id
			INNER JOIN stmt_invoice_detail sidf ON sidf.stmt_invoice_id = si.stmt_invoice_id
			INNER JOIN stmt_checkout scf ON scf.stmt_invoice_detail_id = sidf.stmt_invoice_detail_id AND scf.accrual_or_final = 'f'
			LEFT JOIN stmt_checkout scr ON scr.reversal_stmt_checkout_id = scf.stmt_checkout_id
			WHERE sta.stmt_adjustments_id IS NULL
			AND scr.stmt_checkout_id IS NULL
			AND tmp.settlement_amount <> 0

			INSERT INTO stmt_adjustments(as_of_date,source_deal_header_id,leg,term_start,term_end,charge_type_id,shipment_id,ticket_detail_id,settlement_amount_pre,settlement_amount_new,settlement_amount,volume_pre,volume_new,volume,price_pre,price_new,price,match_info_id)
				SELECT ISNULL(mx_as_of_date, as_of_date)
				, source_deal_header_id
				, leg
				, term_start
				, term_end
				, charge_type_id
				, shipment_id
				, ticket_detail_id
				, settlement_amount_pre
				, settlement_amount_new
				, settlement_amount
				, volume_pre
				, volume_new
				, volume
				, price_pre
				, price_new
				, price
				, match_info_id
				FROM #temp_deal_settlement_adjustment tdsa
				OUTER APPLY (
					SELECT max(vw.as_of_date) [mx_as_of_date]
					FROM vwIndexFeesBreakdownStmt vw
					WHERE tdsa.source_deal_header_id = vw.source_deal_header_id
					AND tdsa.term_start = vw.term_start
					GROUP BY vw.term_start, vw.source_deal_header_id
				) af
				WHERE settlement_amount <> 0

		END


END
	DECLARE @model_name VARCHAR(100),@desc VARCHAR(500)
	BEGIN
		SET @model_name = 'Run Settlement Adjustment'
		SET @desc = 'Run Settlement Adjustmen.'
	END		
	 Exec spa_ErrorHandler 0, @model_name, 
				@model_name, 'job', 
				@model_name, 
				'Plese check/refresh your message board.'




