
IF OBJECT_ID('[dbo].[spa_pnl_explain_wrapper]') IS NOT NULL
	DROP PROC [dbo].[spa_pnl_explain_wrapper]
GO
/****** Object:  StoredProcedure [dbo].[spa_pnl_explain_wrapper]    Script Date: 12/30/2016 2:34:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		pamatya@pioneersolutionsglobal.com
-- Create date: 2015-12-21
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[spa_pnl_explain_wrapper]
		@_as_of_date_from         DATETIME = NULL,
		@_as_of_date_to           DATETIME = NULL,
		@_sub                     VARCHAR(MAX) = NULL,
		@_str                     VARCHAR(MAX) = NULL,
		@_term_start              DATETIME     = NULL,
		@_term_end                DATETIME     = NULL,
		@_book                    VARCHAR(MAX) = NULL,
		@_source_deal_header_ids  VARCHAR(5000) = NULL,
		@_index                   VARCHAR(200) = NULL,
		@_round                   VARCHAR(1)   = NULL,
		@_batch_process_id        VARCHAR(50)  = NULL,
		@_batch_report_param      VARCHAR(1000)= NULL,
		@_enable_paging           INT = 0      ,
		@_page_size               INT = NULL   ,
		@_page_no                 INT = NULL  ,
		@_option_param_table	  VARCHAR(250) = NULL
AS
/*
DECLARE 
		@_as_of_date_from         DATETIME = NULL,
		@_as_of_date_to           DATETIME = '2016-06-30',
		@_sub                     VARCHAR(MAX) = NULL,
		@_str                     VARCHAR(MAX) = NULL,
		@_term_start              DATETIME     = NULL,
		@_term_end                DATETIME     = NULL,
		@_book                    VARCHAR(MAX) = NULL,
		@_source_deal_header_ids  VARCHAR(5000) = '50004',
		@_index                   VARCHAR(200) = NULL,
		@_round                   VARCHAR(1)   = NULL,
		@_batch_process_id        VARCHAR(50)  = NULL,
		@_batch_report_param      VARCHAR(1000)= NULL,
		@_enable_paging           INT = 0      ,
		@_page_size               INT = NULL   ,
		@_page_no                 INT = NULL  ,
		@_option_param_table	  VARCHAR(250) = ' adiha_process.dbo.option_param_co__farrms_admin_F359963E_B0D6_4AB3_AADC_B79EB605D01F'
		--*/
BEGIN
	DECLARE @include_option CHAR(1) 
	DECLARE @source_deal_header_ids VARCHAR(MAX)
	DECLARE @source_deal_without_option VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)
	DECLARE @process_id VARCHAR(250) 
	DECLARE @db_user VARCHAR(200) 
	DECLARE @output_process_table VARCHAR(500)
	DECLARE @input_process_table VARCHAR(500)
	DECLARE @source_deal_header_id VARCHAR(MAX)
	SELECT @process_id = dbo.FNAGETnewID()
	SELECT @db_user = dbo.FNADBUser()
	SELECT @output_process_table = dbo.FNAProcessTableName('pnl_output_approx',dbo.FNAdbUser(),@process_id)
	SELECT @input_process_table = dbo.FNAProcessTableName('pnl_input_approx',dbo.FNAdbUser(),@process_id)
	DECLARE @as_of_date_to VARCHAR(12)
	DECLARE @attribute_type VARCHAR(1) 
	DECLARE @method INT 
	SELECT @include_option = var_value 
	FROM adiha_default_codes_values 
	WHERE default_code_id = 85
	
	IF OBJECT_ID('tempdb..#attribute_type') IS NOT NULL 
		DROP TABLE #attribute_type


	SELECT @as_of_date_to = CAST(@_as_of_date_to AS VARCHAR(12))
	IF @_as_of_date_from IS NULL 
	BEGIN	
		
		SELECT @_as_of_date_from = MAX(pnl_as_of_date) 
		FROM source_deal_pnl 
		WHERE pnl_as_of_date < @_as_of_date_to

	END
	
	CREATE TABLE #attribute_type(Method INT,attribute_type VARCHAR(1) COLLATE DATABASE_DEFAULT)
	
EXEC('INSERT INTO #attribute_type(method,attribute_type)
	SELECT method,attribute_type FROM '+@_option_param_table)

	SELECT @method = method,@attribute_type = attribute_type FROM #attribute_type

	IF OBJECT_ID('tempdb..#source_deal_header') IS NOT NULL 
			DROP TABLE #source_deal_header
			
		CREATE TABLE #source_deal_header
		(source_deal_header_id INT)
	
	IF @_source_deal_header_ids IS NOT NULL 
		BEGIN 
			INSERT  INTO #source_deal_header
			SELECT *
			FROM SplitCommaSeperatedValues(@_source_deal_header_ids) d
		END
		ELSE 
			INSERT INTO #source_deal_header
			SELECT source_deal_header_id FROM source_deal_header
		
		
	IF OBJECT_ID('tempdb..#option_flag') IS NOT NULL
		DROP TABLE #option_flag

	SELECT sdh1.option_flag
		,sdh.source_deal_header_id
	INTO #option_flag
	FROM #source_deal_header sdh
	INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh1.option_flag = 'y'
	
	SELECT @source_deal_header_id = STUFF((
				SELECT ',' + CAST([source_deal_header_id] as VARCHAR(100))
				FROM #option_flag sdh
				WHERE sdh.option_flag = 'y'
				FOR XML PATH('')
				), 1, 1, '')
			
	SELECT @source_deal_without_option = STUFF((
				SELECT ',' + CAST([source_deal_header_id] as VARCHAR(100))
				FROM #option_flag sdh
				WHERE sdh.option_flag = 'n'
				FOR XML PATH('')
				), 1, 1, '')


	IF  @include_option = 0 OR @include_option = 1 AND (NULLIF(@method,0) IS  NULL OR NULLIF(@attribute_type,'') IS NULL)
	BEGIN 
			EXEC spa_pnl_explain_view @as_of_date_from=@_as_of_date_from,@as_of_date_to=@_as_of_date_to,@sub=@_sub,@str=@_str,@term_start = @_term_start,@term_end = @_term_end,@book=@_book,@source_deal_header_ids  = @_source_deal_header_ids,@index = @_index,@round = @_round,@current_included= @include_option
		END
		ELSE
		BEGIN 
			IF (NULLIF(@method,0) IS  NULL OR NULLIF(@attribute_type,'') IS NULL)
			BEGIN
				EXEC spa_pnl_explain_view @as_of_date_from=@_as_of_date_from,@as_of_date_to=@_as_of_date_to,@sub=@_sub,@str=@_str,@term_start = @_term_start,@term_end = @_term_end,@book=@_book,@source_deal_header_ids  = @_source_deal_header_ids,@index = @_index,@round = @_round,@current_included= 0
				EXEC spa_pnl_explain_view @as_of_date_from=@_as_of_date_from,@as_of_date_to=@_as_of_date_to,@sub=@_sub,@str=@_str,@term_start = @_term_start,@term_end = @_term_end,@book=@_book,@source_deal_header_ids  = @_source_deal_header_ids,@index = @_index,@round = @_round,@current_included= 1
			END
	END

	--FOR deals with option_type

	IF OBJECT_ID('tempdb..#current_day_data') IS NOT NULL 
			DROP TABLE #current_day_data
	IF OBJECT_ID('tempdb..#source_deal_header_option') IS NOT NULL 
			DROP TABLE #source_deal_header_option
	
	CREATE TABLE #source_deal_header_option
		(source_deal_header_id INT)

		INSERT  INTO #source_deal_header_option
			SELECT *
			FROM SplitCommaSeperatedValues(@source_deal_header_id) d

		EXEC('CREATE TABLE ' +@output_process_table +' (
			row_id INT
			,source_deal_header_id INT
			,source_deal_detail_id INT
			,curve_id INT
			,term_start varchar(12)
			,Begin_MTM FLOAT
			,New_MTM FLOAT
			,Modify_MTM FLOAT
			,Deleted_MTM FLOAT
			,Delivered_MTM FLOAT
			,Price_changed_MTM FLOAT
			,PnL_Delta1 FLOAT
			,PnL_Delta2 FLOAT
			,PnL_Gamma1 FLOAT
			,PnL_Gamma2 FLOAT
			,PnL_Vega1 FLOAT
			,PnL_Vega2 FLOAT
			,PnL_Theta FLOAT
			,PnL_Rho FLOAT
			,Unexplained_MTM FLOAT
			,Ending_MTM FLOAT
			,Currency VARCHAR(10)
			,Method VARCHAR(20)
			,Attribute_type VARCHAR(1)
			,IDT int
			,excercise_type varchar(1)
			)')
--			
		CREATE TABLE #current_day_data  (
			source_deal_header_id INT
			,source_deal_detail_id INT
			,curve_id INT
			,term_start DATETIME
			,spot_price_1 FLOAT
			,PREMIUM FLOAT
			,DELTA FLOAT
			,DELTA2 FLOAT
			,gamma FLOAT
			,vega FLOAT
			,theta FLOAT
			,rho FLOAT
			,volatility_1 FLOAT
			,discount_rate FLOAT
			,days_expiry FLOAT
			,deal_volume FLOAT
			,option_type VARCHAR(10) COLLATE DATABASE_DEFAULT
			,strike_price VARCHAR(10) COLLATE DATABASE_DEFAULT
			,Method VARCHAR(10) COLLATE DATABASE_DEFAULT
			,Attribute_type VARCHAR(1) COLLATE DATABASE_DEFAULT
			,spot_prev_2 FLOAT
			,v_prev_2 FLOAT
			,gamma_prev_2 FLOAT
			,vega_prev_2 FLOAT
			,rho_prev_2 FLOAT
			,theta_prev_2 FLOAT
			
			)
			INSERT INTO #current_day_data
			SELECT s.source_deal_header_id
			,sdd.source_deal_detail_id
			,sdd.curve_id
			,sdd.term_start
			,spot_price_1
			,PREMIUM
			,DELTA
			,DELTA2
			,gamma
			,vega
			,theta
			,rho
			,volatility_1
			,discount_rate
			,days_expiry
			,s.deal_volume
			,option_type
			,strike_price
			,Method
			,Attribute_type
			,spot_price_2 spot_prev_2 
			,volatility_2 v_prev_2 
			,gamma2 gamma_prev_2
			,vega2 vega_prev_2
			,rho2 rho_prev_2
			, theta2  theta_prev_2
			FROM source_deal_pnl_detail_options s
			   INNER JOIN source_deal_detail sdd 
				ON sdd.source_deal_header_id = s.source_deal_header_id 
				AND sdd.term_start = s.term_start
			   AND sdd.curve_id = s.curve_1
			WHERE as_of_date = @_as_of_date_from
		
		
		
		
			EXEC('SELECT 
			row_number() OVER (order by c.source_deal_header_id,c.term_start) row_id,
			c.source_deal_header_id 
			,sdd.source_deal_detail_id
			,sdd.curve_id 
			,c.term_start
			,p.deal_volume vol_prev
			,c.PREMIUM prem_cur
			,p.PREMIUM prem_prev
			,c.spot_price_1 spot_cur
			,p.spot_price_1 spot_prev
			,p.DELTA del_1_prev
			,p.DELTA2 del_2_prev
			,p.GAMMA gamma_prev
			,p.vega vega_prev
			,p.Theta theta_prev
			,p.rho rho_prev
			,p.volatility_1 v_prev
			,c.volatility_1 v_cur
			,p.days_expiry exp_time_prev
			,c.days_expiry exp_time_cur
			,p.discount_rate r_prev
			,p.discount_rate r_cur
			,p.strike_price strike_prev
			,c.option_type cp
			,c.method Method
			,c.curve_2
			,c.Attribute_type Attribute_type 
			,c.spot_price_2 spot_cur_2 
			,c.volatility_2 v_cur_2 
			,c.gamma2 gamma_cur_2
			,c.vega2 vega_cur_2
			,c.rho2 rho_cur_2
			,c.theta2  theta_cur_2
			,p.spot_prev_2
			,p.v_prev_2
			,p.gamma_prev_2
			,p.vega_prev_2
			,p.rho_prev_2
			,o.correlation
			,p.theta_prev_2
			,c.internal_deal_type_value_id idt
			,c.excercise_type

			INTO '
			+@input_process_table +
			' FROM source_deal_pnl_detail_options c
			INNER JOIN #source_deal_header_option sdh ON sdh.source_deal_header_id = c.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND c.term_start = sdd.term_start AND c.curve_1 =sdd.curve_id
			LEFT JOIN #current_day_data p ON c.source_deal_header_id = p.source_deal_header_id
			AND c.term_start = p.term_start
			INNER JOIN '+ @_option_param_table + ' o ON o.source_deal_header_id = c.source_deal_header_id AND o.as_of_date = c.as_of_date
			AND o.term_start = p.term_start
			WHERE c.as_of_date = '''+@as_of_date_to  +'''')
	

	--EXEC spa_calculate_pnl_using_R @input_process_table,@output_process_table
	--EXEC spa_calculate_pnl_using_R_Spread @input_process_table,@output_process_table



IF @source_deal_header_id IS NOT NULL
BEGIN 
DECLARE @insert VARCHAR(MAX)
EXEC('DELETE pnl FROM '+@output_process_table+' a
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = a.source_deal_header_id
	INNER JOIN Source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		AND sdd.term_start = a.term_start
		AND a.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN pnl_explain_view pnl ON pnl.source_deal_header_id = a.source_deal_header_id 
		AND pnl.term_start = a.term_start AND pnl.term_end = sdd.term_end 
		AND pnl.curve_id = a.curve_id
		')

	SET @insert = 'INSERT INTO pnl_explain_view
		(source_deal_header_id
	,term_start
	,term_end
	,curve_id
	,leg
	,deal_status_id
	,begin_mtm
	,new_mtm
	,modify_MTM
	,deleted_mtm
	,delivered_mtm
	,price_changed_mtm
	,end_mtm
	,begin_vol
	,new_vol
	,modify_vol
	,deleted_vol
	,end_vol
	,delta_price
	,delivered_vol
	,price_to
	,price_from
	,pnl_currency_id
	,charge_type
	,create_ts
	,unexplained_vol
	,unexplained_mtm
	,source_curve_def_id
	,source_currency_id
	,as_of_date_from
	,as_of_date_to
	,book_id
	,Strategy_id
	,Sub_id
	,source_counterparty_id
	,reference_id
	,transaction_type_id
	,transaction_type_name
	,commodity_id
	,sub_book_id
	,deal_sub_type
	,current_included,
	total_change_mtm,
	total_change_vol
	,PnL_Delta1
	,pnl_Delta2
	,pnl_Gamma1
	,pnl_Gamma2
	,pnl_Vega1
	,pnl_Vega2
	,pnl_Theta
	,pnl_Rho
	,Method
	,attribute_type)
	SELECT a.source_deal_header_id
		,a.term_start
		,sdd.term_end
		,a.curve_id
		,sdd.leg
		,sdh.deal_status
		,begin_mtm
		,new_mtm
		,modify_mtm
		,deleted_mtm
		,delivered_mtm
		,price_changed_mtm
		,ending_mtm
		,0 begin_vol
		, 0 new_vol
		,0 modify_vol
		, 0 deleted_vol
		, 0 end_vol
		,0 delta_price
		,0 delivered_vol
		,0 price_to
		,0 price_from
		,sc.source_currency_id
		,291905 charge_type
		,CONVERT(VARCHAR, GETDATE(), 120)
		,0 unexplained_vol
		,unexplained_mtm
		,a.curve_id
		,source_currency_id
		,'''+CAST(@_as_of_date_from AS VARCHAR(12))+'''
		,'''+CAST(@_as_of_date_to AS VARCHAR(12))+'''
		--,'+ISNULL(@_book,'')+' 
		--,'+ISNULL(@_str,'')+' 
		--,'+ISNULL(@_sub,'')+' 
		,book.entity_id
		,stra.entity_id
		,sb.entity_id
				,sdh.counterparty_id
		,sdh.deal_id
		,ssbm.fas_deal_type_value_id
		,  sdv.code transaction_type_name
		,commodity_id
		,sdh.sub_book
		,sdh.source_deal_type_id 
		,'+ISNULL(@include_option,0)+'
		,begin_mtm - ending_mtm total_change_mtm
		, 0 total_change_vol
		,PnL_Delta1
		,pnl_Delta2
		,pnl_Gamma1
		,pnl_Gamma2
		,pnl_Vega1
		,pnl_Vega2
		,pnl_Theta
		,pnl_Rho
		,Method
		,attribute_type
	FROM '+@output_process_table+' a
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = a.source_deal_header_id
	INNER JOIN Source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		AND sdd.term_start = a.term_start
		AND a.source_deal_detail_id = sdd.source_deal_detail_id
	INNER JOIN source_currency sc ON sc.currency_id = a.currency
	  INNER JOIN source_system_book_map ssbm
    ON  ssbm.source_system_book_id1 = sdh.source_system_book_id1
    AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
    AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
    AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	 INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=ssbm.fas_book_id
	 INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
	INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id
	LEFT JOIN static_data_value sdv ON sdv.[type_id] = 400 AND ssbm.fas_deal_type_value_id = sdv.value_id
	'
	
	EXEC(@insert)
END

END




