IF OBJECT_ID('spa_calculate_fee') IS NOT NULL
DROP PROCEDURE [dbo].[spa_calculate_fee]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 /**
	Calculate VAT/TAX

	Parameters : 
	@sub_id : Subsidiary filter for deals to process
	@strategy_id : Strategy filter for deals to process
	@book_id : Book filter for deals to process
	@source_book_mapping_id : Sub-book filter for deals to process
	@source_deal_header_id : Deal filter to process
	@as_of_date : Date for processing
	@term_start : Term Start filter to process
	@term_end : Term end filter to process
	@criteria_id : WHATIF parameter changed criteria ID.
	@tmp_hourly_price_vol: Position table to access data and process
	@process_id: Process id when run through batch
  */


CREATE procedure [dbo].[spa_calculate_fee]
	@sub_id VARCHAR(MAX)=NULL,
	@strategy_id VARCHAR(MAX)=NULL,
	@book_id VARCHAR(MAX)=NULl,
	@source_book_mapping_id VARCHAR (MAX)=NULL,
	@source_deal_header_id VARCHAR (MAX) =NULL,
	@as_of_date VARCHAR(100),
	@term_start VARCHAR(100) =NULL,
	@term_end VARCHAR(100) =NULL,
	@criteria_id INT = NULL,
	@tmp_hourly_price_vol VARCHAR(220),
	@process_id VARCHAR(150)
AS 

SET STATISTICS IO off
SET NOCOUNT ON
SET ROWCOUNT 0

--SELECT @process_id
----BEGIN OF TESTING -------------------------
-----------------------------------------------------
/*

----DBCC DROPCLEANBUFFERS
------DBCC FREEPROCCACHE
------dbcc stackdump(1)
SET NOCOUNT OFF	
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

DECLARE	@sub_id VARCHAR(MAX),
	@strategy_id VARCHAR(MAX),
	@book_id varchar(MAX),
	@source_book_mapping_id VARCHAR (MAX),
	@source_deal_header_id VARCHAR (MAX),
	@as_of_date VARCHAR(100),
	@term_start VARCHAR(100) ,
	@term_end VARCHAR(100),
	@criteria_id INT = NULL,
	@tmp_hourly_price_vol VARCHAR(220),
	@process_id VARCHAR(100)

SELECT	
	@sub_id = NULL, 
	@strategy_id =NULL, 
	@book_id = NULL,
	@source_book_mapping_id = NULL,
	@source_deal_header_id = NULL, --'29,30,31,32,33,39',--,8,19',
	@as_of_date =   '2020-08-31', --'2017-02-15',
	@term_start = '2020-08-01',
	@term_end = '2020-08-31',
	@tmp_hourly_price_vol = 'adiha_process.dbo.tmp_hourly_price_vol_DEBUG_MODE_ON_F94212EB_CEAE_49AF_914E_D03532141C37',
	@criteria_id = NULL,
	@process_id = 'B1BE6DC1_5D7D_4793_9300_52FD566FD8D6'
--*/
	DECLARE @sql VARCHAR(MAX),
		@sqlstmt VARCHAR(MAX),
		@sqlstmt2 VARCHAR(MAX),
		@sqlstmt3 VARCHAR(MAX),
		@sqlstmt4 VARCHAR(MAX),
		@calc_type CHAR(1) = 's',
		@from_clause varchar(max),
		@from_clause1 varchar(max),
		@where_clause varchar(max),
		@trading_days INT = 252, 
		@no_days_left VARCHAR(1000), 
		@no_days_accrued VARCHAR(1000), 
		@curve_as_of_date VARCHAR(100) = NULL, 
		@assessment_curve_type_value_id INT = 77,
		@DiscountTableName VARCHAR(200),
		@is_discount_curve_a_factor INT,
		@cpt_type CHAR(1) = 'x',
		@counterparty_id VARCHAR(MAX) = NULL,
		@user_id VARCHAR(100) = dbo.FNADBUser(), 
		--@process_id VARCHAR(150) = REPLACE(newid(),'-','_'),
		@hypo_deal_header VARCHAR(150),
		@hedge_or_item char(1) = NULL, 
		@transaction_type VARCHAR(400) = '401,400',
		@deal_list_table VARCHAR(200) = NULL, 
		@ignore_deal_date BIT = 0, 
		@cancel_deal_status VARCHAR(10) = 5607,
		@default_holiday_id INT = 291898,
		--@tmp_hourly_price_vol VARCHAR(220),
		@hr_columns VARCHAR(MAX),
		@calc_explain_type CHAR(1) = NULL,
		@next_business_day VARCHAR(20),
		@baseload_block_definition INT,
		@curve_source_value_id INT = 4500,
		--@criteria_id INT = NULL, 
		@run_date VARCHAR(20) = NULL, 
		@time_zone_id INT,
		@calc_settlement_adjustment BIT = 0,
		@last_business_day VARCHAR(20)

	DECLARE @original_calc_type CHAR(1) = @calc_type,
		@run_type VARCHAR(50) = CASE WHEN @calc_settlement_adjustment=1 THEN 'Settlemet Adjustment' ELSE 'Deal Settlement' END

	DECLARE @qry1b VARCHAR(MAX)
		,@qry2b VARCHAR(MAX)
		,@qry3b VARCHAR(MAX)
		,@qry4b VARCHAR(MAX)
		,@qry5b VARCHAR(MAX)
		,@qry6b VARCHAR(MAX)
		,@qry7b VARCHAR(MAX)
		,@qry8b VARCHAR(MAX)
		,@qry9b VARCHAR(MAX)

	--Start tracking time for Elapse time
	DECLARE @begin_time DATETIME
	SET @begin_time = GETDATE()
	
	Declare @process_id1 VARCHAR(30)
	SET @process_id1=REPLACE(newid(),'-','_')

	-- FInd the Last business day of that month
	DECLARE @last_day_in_Month VARCHAR(20)
	SET @last_day_in_Month = CONVERT(VARCHAR(10),DATEADD(m,1,dbo.FNAGetContractMonth(@as_of_date)),120)
	SET @last_business_day = dbo.FNAGetBusinessDay ('p',@last_day_in_Month,@default_holiday_id)

	IF @as_of_date = @last_business_day
		SET @last_business_day =  CONVERT(VARCHAR(10),CAST(@last_day_in_Month AS DATETIME)-1,120)
	ELSE
		SET @last_business_day = @as_of_date

	SELECT @next_business_day =  dbo.FNAGetBusinessDay ('n',@as_of_date,@default_holiday_id)
	SELECT @baseload_block_definition = value_id FROM static_data_value WHERE type_id = 10018 AND code = 'Base Load'

	SELECT @time_zone_id = var_value   --26
	FROM dbo.adiha_default_codes_values(NOLOCK)
	WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1

if OBJECT_ID('tempdb..#fees_breakdown_tax') is not null drop table #fees_breakdown_tax

CREATE TABLE #fees_breakdown_tax
(
	as_of_date DATETIME,
	source_deal_header_id int,
	leg int,
	term_start DATETIME,
	term_end DATETIME,
	field_id int,
	field_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
	price_deal FLOAT,
	price FLOAT,
	price_inv FLOAT,
	total_price_deal FLOAT,
	total_price FLOAT,
	total_price_inv FLOAT,
	volume FLOAT,
	value_deal FLOAT,
	[value] FLOAT,
	value_inv FLOAT,
	deal_cur_id int,
	inv_cur_id int,
	contract_value_deal FLOAT,
	contract_value FLOAT,
	contract_value_inv FLOAT,
	internal_type int,
	tab_group_name int,
	udf_group_name int,
	[sequence] int,
	fee_currency_id int,
	currency_id int,
	contract_mkt_flag CHAR(1) COLLATE DATABASE_DEFAULT,
	source_deal_detail_id int
	,shipment_id INT,
	ticket_detail_id INT,
	match_info_id INT,
	counterparty_id int NULL,
	contract_id int NULL

)




	----###### Evaluate formula defined in UDF
	DECLARE  @formula_table5 VARCHAR(100),@calc_result_table5 VARCHAR(100),@calc_result_table_breakdown5 VARCHAR(100)
	SET @formula_table5 = dbo.FNAProcessTableName('udf_formula_tax', @user_id, @process_id)



	EXEC spa_calculate_formula	@as_of_date, @formula_table5,@process_id1,@calc_result_table5 output, @calc_result_table_breakdown5 output,'n','n',@calc_type, @criteria_id,NULL,@calc_type,'y'


	SET @qry1b='
	SELECT	'''+ @as_of_date+''' as_of_date, td.source_deal_header_id,td.leg,
	CASE WHEN '''+@cpt_type+'''=''b'' THEN CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME)
		WHEN --op.source_deal_header_id IS NOT NULL and 
			uddft.internal_field_type IN (18722) THEN 
				case when COALESCE(udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) is not null or ''s''=''' +@calc_type+''' then 
				--CAST(CONVERT(VARCHAR(7),ISNULL(sdh.option_settlement_date,sdh.deal_date),120)+''-01'' AS DATETIME) 
				ISNULL(sdh.option_settlement_date,sdh.deal_date) 
				else td.term_start  end 
		WHEN uddft.internal_field_type IN(18723,18724) THEN CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME) 
		ELSE td.term_start END term_start, 
	CASE WHEN '''+@cpt_type+'''=''b'' THEN DATEADD(m,1,CAST(CONVERT(VARCHAR(7),ISNULL(sdh.option_settlement_date,sdh.deal_date),120)+''-01'' AS DATETIME))-1
		WHEN --op.source_deal_header_id IS NOT NULL and 
			uddft.internal_field_type IN (18722) THEN 
				case when COALESCE(udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) is not null or ''s''=''' +@calc_type+''' then
				-- DATEADD(m,1,CAST(CONVERT(VARCHAR(7),ISNULL(sdh.option_settlement_date,sdh.deal_date),120)+''-01'' AS DATETIME))-1 
				 ISNULL(sdh.option_settlement_date,sdh.deal_date)
				else td.term_end  end 
		WHEN uddft.internal_field_type IN(18723,18724) THEN DATEADD(m,1,CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME))-1 ELSE td.term_end END term_end,	
	uddft.field_name field_id, 
	uddft.field_label field_name, 
	--CASE WHEN ISNUMERIC(uddf.udf_value)=1 THEN cast(uddf.udf_value as float) ELSE NULL END * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) price,
	--CASE WHEN ISNUMERIC(uddf.udf_value)=1 THEN cast(uddf.udf_value as float) ELSE NULL END * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) total_price,
		--volume should be + if sell - if buy as fee cashflow should be opposite
		MAX(CASE WHEN udft.internal_field_type IN(18705) THEN --Capacity based fee 18713 OffPeak
			CASE WHEN (td.curve_tou=18900) THEN --ONPEAK
				CASE WHEN ISNUMERIC( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value))=1 THEN cast( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float) ELSE NULL END * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1)				
			ELSE 0 END 
			WHEN udft.internal_field_type IN(18710) THEN 
			CASE WHEN (td.curve_tou=18901) THEN --ONPEAK
				CASE WHEN ISNUMERIC( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value))=1 THEN cast( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float) ELSE NULL END * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1)
			ELSE 0 END 
			WHEN udft.internal_field_type IN(18739,18741) THEN sfv.value
		END) total_price_deal,cast(0 as float) total_price,cast(0 as float) total_price_inv,
		abs(SUM( 
		CASE WHEN (udft.internal_field_type IN (18702, 18703)) THEN ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity))
				WHEN (udft.internal_field_type IN (18701, 18704)) THEN ABS(td.contract_volume)
		ELSE			
			CASE WHEN isnull(hv.curve_id,-1)=-1 THEN td.deal_volume  ELSE ABS(hv.volume) END 
	END)) volume
	,sum(CASE WHEN udft.internal_field_type IN(18705) THEN --Capacity based fee 18713 OffPeak
		CASE WHEN (td.curve_tou=18900) THEN --ONPEAK
			CASE WHEN ISNUMERIC( COALESCE(udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value))=1 THEN cast( COALESCE(udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float) ELSE NULL END * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1)				
		ELSE 0 END 
		WHEN udft.internal_field_type IN(18710) THEN 
		CASE WHEN (td.curve_tou=18901) THEN --ONPEAK
			CASE WHEN ISNUMERIC( COALESCE(udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value))=1 THEN cast( COALESCE(udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float) ELSE NULL END * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1)
		ELSE 0 END
		WHEN udft.internal_field_type IN(18739,18741) THEN sfv.value
	END) price_deal,cast(0 as float) price,cast(0 as float) price_inv,
	sum(CASE udft.internal_field_type 			
		WHEN 18700 THEN --Position based fee  BaseLoad Applies to All
			round(CASE WHEN isnull(hv.curve_id,-1)=-1 THEN  td.deal_volume  ELSE (hv.volume) END * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) 
				* ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1)
		WHEN 18731 THEN --Injection based Fee
			round(CASE WHEN isnull(hv.curve_id,-1)=-1 THEN  td.deal_volume  ELSE (hv.volume) END  * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100))* ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1)
			'

	SET @qry2b='
		WHEN 18705 THEN --Position based fee  18705 OnPeak 
			CASE WHEN (td.curve_tou=18900) THEN --ONPEAK
				round(CASE WHEN isnull(hv.curve_id,-1)=-1 THEN   td.deal_volume  ELSE (hv.volume) END * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) 
					* ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1)
			ELSE 0 END 
		WHEN 18710 THEN --Position based fee  18710 OffPeak
			CASE WHEN (td.curve_tou=18901) THEN --OFFPEAK
	round(CASE WHEN isnull(hv.curve_id,-1)=-1 THEN  td.deal_volume  ELSE hv.volume END  * cast(COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100))* ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) ELSE 0 END 
		WHEN 18701 THEN --Deal Volume monthly based fee BaseLoad Applies to All
			round(ABS(td.contract_volume) * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
		WHEN 18706 THEN --Deal Volume monthly based fee 18706 OnPeak 
			CASE WHEN (td.curve_tou=18900) THEN --ONPEAK
			round(ABS(td.contract_volume) * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
					ELSE 0 END 
		WHEN 18711 THEN --Deal Volume monthly based fee 18711 OffPeak
			CASE WHEN (td.curve_tou=18901) THEN --OFFPEAK
			round(ABS(td.contract_volume) * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
			ELSE 0 END 
		WHEN 18704 THEN --Deal Volume Annual based fee BaseLoad Applies to All
	round(ABS(td.contract_volume)/12 * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100))* ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
		WHEN 18709 THEN --Deal Volume Annual based fee 18709 OnPeak 
			CASE WHEN (td.curve_tou=18900) THEN --ONPEAK
	round(ABS(td.contract_volume)/12 * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
			ELSE 0 END 
		WHEN 18714 THEN --Deal Volume Annual based fee 18714 OffPeak
			CASE WHEN (td.curve_tou=18901) THEN --OFFPEAK
			round(ABS(td.contract_volume)/12 * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
					ELSE 0 END 
		'

	SET @qry3b='
		WHEN 18702 THEN --Capacity based Annual fee BaseLoad Applies to All
		round(ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity))/12 * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
		WHEN 18707 THEN --Capacity based Annual fee 18707 OnPeak 
			CASE WHEN (td.curve_tou=18900) THEN --ONPEAK
			round(ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity))/12 * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
					ELSE 0 END 
		WHEN 18712 THEN --Capacity based Annual fee 18712 OffPeak
			CASE WHEN (td.curve_tou=18901) THEN --OFFPEAK
			round(ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity))/12 * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
		ELSE 0 END 
		WHEN 18703 THEN --Capacity based fee BaseLoad Applies to All
		round(ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity)) * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100))* ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
		WHEN 18708 THEN --Capacity based fee 18708 OnPeak 
			CASE WHEN (td.curve_tou=18900) THEN --ONPEAK
		round(ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity)) * cast(COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
			ELSE 0 END 
		WHEN 18713 THEN --Capacity based fee 18713 OffPeak
			CASE WHEN (td.curve_tou=18900) THEN --ONPEAK
			round(ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity)) * cast(COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
					ELSE 0 END 
		WHEN 18715 THEN -- Lump sum Annual Applies to All
			CASE WHEN(td.leg=1) THEN
			round(cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float)/12, ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/nullif(totalhours,0),1)
			ELSE 0 END 
		WHEN 18716 THEN -- Lump sum Monthly Applies to All
				CASE WHEN(td.leg=1) THEN
			round(cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1)
				* case when td.term_frequency=''d'' then cast(1.0 as float)/day(eomonth(td.term_start)) else ISNULL(partialhours/nullif(totalhours,0),1) end
						ELSE 0 END 
				WHEN 18717 THEN --Capacity based on Term Fee
		round((ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity))*CAST((DATEDIFF(d,td.term_start,td.term_end)+1) AS FLOAT)/CAST((DATEDIFF(d,td.entire_term_start,td.entire_term_end)+1) AS FLOAT)) * cast (uddf.udf_value as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(partialhours/totalhours,1) 
		WHEN 18732 THEN-- Lump Sum Fixed
			ROUND(CAST(COALESCE(udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) 
					* ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1)
		WHEN 18737 THEN --Percentage - Fixed 
		((COALESCE(udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) * tlm.contract_value)/100) /ISNULL(fx.price_fx_conv_factor,1) '

	SET @qry4b='
		WHEN 18719 THEN --Deal Volume based daily fee 
		round(ABS(td.contract_volume) * cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(24/totalhours,1)
				WHEN 18720 THEN --Capacity based Daily fee BaseLoad Applies to All
		round(ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity)) * cast(COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) 
				* ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(24/totalhours,1)
		WHEN 18721 THEN -- Lump sum Daily Fee
			CASE WHEN(td.leg=1) THEN
			round(cast ( COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) as float), ISNULL(r.rounding, 100)) * ISNULL(sc.factor, 1) * ISNULL(fx_deal.price_fx_conv_factor, 1) * ISNULL(24/totalhours,1)
			ELSE 0 END 
		WHEN 18725 THEN 
			CASE WHEN '''+@calc_type+'''= ''s'' AND td.internal_deal_type_value_id = 11 THEN 0 ELSE COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) * fbvc.curve_value * ABS(hv.volume) END
		WHEN 18726 THEN 
			CASE WHEN '''+@calc_type+'''= ''s'' AND td.internal_deal_type_value_id = 11 THEN 0 ELSE COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value)  * ABS(hv.volume) END
		WHEN 18727 THEN 
			CASE WHEN td.internal_deal_type_value_id = 13 THEN 0 ELSE COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value)  * ABS(hv.volume) *(CAST(12 AS FLOAT)/cast(365 AS Float)) END '
	SET @qry5b='
		WHEN 18728 THEN 
			CASE WHEN td.internal_deal_type_value_id = 13 THEN 0 ELSE COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value)  * ABS(hv.volume) END
		WHEN 18729 THEN 
			CASE WHEN td.internal_deal_type_value_id = 13 THEN 0 ELSE COALESCE(sfv.value,udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value)* ABS(hv.volume) * (ISNULL(24/partialhours,1)) END
		WHEN 18739 THEN
			 td.deal_volume * sfv.value
		WHEN 18741 THEN
			 td.deal_volume * sfv.value
		WHEN 18742 THEN
				sddh.positive_vol
		WHEN 18743 THEN
				sddh.negative_vol
		WHEN 18744 THEN 
				udf_formula.formula_eval_value
		WHEN 18745 THEN 
				udf_formula.formula_eval_value
	ELSE NULL END) value_deal,cast(0 as float) value,cast(0 as float) value_inv,MAX(td.fixed_price_currency_id) deal_cur_id,
	MAX(td.settlement_currency) inv_cur_id,NULL contract_value,NULL contract_value_deal,NULL contract_value_inv,
	MAX(udft.internal_field_type) internal_type,MAX(uddft.udf_tabgroup) tab_group_name, MAX(uddft.udf_group) udf_group_name,
	MAX(uddft.sequence) sequence,MAX(td.func_cur_id) fee_currency_id,MAX(td.func_cur_id) currency_id,NULL contract_mkt_flag,
	MAX(td.source_deal_detail_id) source_deal_detail_id,MAX(ISNUMERIC(COALESCE(udddf.udf_value,uddf.udf_value,udf_formula.formula_eval_value,sfv.value,sddh.vol))) f_value,
			SUM(ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity)))  capacity,
	SUM(CASE WHEN (uddft.internal_field_type IN (18702, 18703,18717)) THEN ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity)) ELSE 1 END) filter1,MAX(sfv.minimum_value) minimum_value,MAX(sfv.maximum_value) maximum_value,
	MAX(isnull(udddf.counterparty_id,uddf.counterparty_id)) counterparty_id,
	MAX(isnull(udddf.contract_id,uddf.contract_id)) contract_id
	into  #tmp_fees_breakdown_000_tax --  select * from  #tmp_fees_breakdown 
	FROM	#temp_deals td 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.source_deal_header_id
		INNER JOIN #uddft uddft ON uddft.template_id=sdh.template_id	and td.leg= ISNULL(uddft.leg,td.leg)	
		INNER JOIN #udft udft ON udft.udf_template_id = uddft.udf_user_field_id and td.leg= ISNULL(udft.leg,td.leg)
		LEFT JOIN #uddf uddf ON uddf.source_deal_header_id = td.source_deal_header_id 
				AND uddf.udf_template_id = uddft.udf_template_id AND uddft.field_type<>''w''
		LEFT JOIN #udddf udddf ON udddf.udf_template_id = uddft.udf_template_id
				AND udddf.source_deal_detail_id = td.source_deal_detail_id AND uddft.field_type<>''w''
		OUTER APPLY (SELECT 
					SUM(CASE WHEN sddh.price < 0 THEN (volume*price) ELSE 0 END) negative_vol,
					SUM(CASE WHEN sddh.price >= 0 THEN (volume*price) ELSE 0 END) positive_vol,
					SUM(volume*price) vol
				FROM source_deal_detail_hour sddh
				WHERE sddh.source_deal_detail_id = td.source_deal_detail_id
				AND sddh.term_date between td.term_start and td.term_end
				AND udft.internal_field_type IN (18742,18743)) sddh
		outer apply
		( 
			select max(curve_id) curve_id, sum(volume) volume from '+@tmp_hourly_price_vol+' 
			where source_deal_header_id=td.source_deal_header_id AND curve_id=td.curve_id AND deal_term_start=td.term_start AND leg = td.leg 	
		) hv
		LEFT JOIN vol_value_rounding r ON r.contract_id = td.contract_id AND r.item_type = ''f'' AND r.field_id = uddft.field_id LEFT JOIN
			source_currency sc ON sc.source_currency_id = coalesce(CAST(uddft.currency_field_id AS INT), td.original_fixed_price_currency_id)
		LEFT JOIN #fx_curves fx ON fx.fx_currency_id = COALESCE(sc.currency_id_to, sc.source_currency_id) AND 
 			fx.func_cur_id = td.func_cur_id AND fx.source_system_id = td.source_system_id AND
 			fx.as_of_date= td.exp_curve_as_of_date AND fx.maturity_date= td.monthly_maturity 
			and fx.market_value_desc=td.fx_conversion_market '

	SET @qry6b='
	outer apply
	( select avg(price_fx_conv_factor) price_fx_conv_factor
		from #fx_curves  where fx_currency_id = ISNULL(sc.currency_id_to, sc.source_currency_id) AND 
			func_cur_id = td.fixed_price_currency_id AND source_system_id = td.source_system_id 
		--  AND fx_deal.as_of_date= td.exp_curve_as_of_date 
			AND  maturity_date between td.term_start and td.term_end
		and market_value_desc=td.fx_conversion_market'+
		case when @calc_type='s' then ' and as_of_date between ''' +@term_start+''' and ''' +@term_end+'''' else ' and as_of_date=''' +@curve_as_of_date+'''' end 
		+'
	) fx_deal
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = td.curve_id	
	OUTER APPLY(
		SELECT ISNULL(NULLIF(SUM(CAST(volume_mult AS FLOAT)),0),1) AS totalhours, 
		ISNULL(NULLIF(SUM(CASE WHEN '''+ @calc_type+''' =''s'' AND term_date <= '''+@as_of_date+''' THEN CAST(volume_mult AS FLOAT)
					WHEN '''+ @calc_type+''' <>''s'' AND '''+isnull(@calc_explain_type,'')+''' = ''d'' AND term_date > '''+@as_of_date +''' AND term_date<='''+isnull(@next_business_day,'') +''' THEN CAST(volume_mult AS FLOAT)
			WHEN '''+ @calc_type+'''<>''s'' AND '''+isnull(@calc_explain_type,'') +'''='''' AND term_date >'''+ @as_of_date+''' THEN CAST(volume_mult AS FLOAT)
		ELSE 0 END),0)
	,1) partialhours
		FROM hour_block_term
		WHERE block_type = case when udft.internal_field_type =18702 then 12000 else ISNULL(spcd.block_type,12000) end
			AND block_define_id = case when udft.internal_field_type =18702 then '+cast(@baseload_block_definition as varchar) +' else ISNULL(spcd.block_define_id,'+cast(@baseload_block_definition as varchar)+') end 
			AND term_date BETWEEN td.term_start AND td.term_end	
	) hbt	
	outer apply 
	( 
		select source_deal_header_id,max(option_premium) option_premium 
		from  #option_param where source_deal_header_id = td.source_deal_header_id
			and td.term_start=term_start AND udft.internal_field_type = 18722 
		group by source_deal_header_id
	)op 
	outer apply 
	(
		select source_deal_header_id, count( distinct source_deal_detail_id) count from #temp_deals 
		WHERE source_deal_header_id = td.source_deal_header_id GROUP BY source_deal_header_id 
	) count
	'

	SET @qry7b='
	LEFT JOIN '+@calc_result_table5+' udf_formula ON udf_formula.source_deal_detail_id = td.source_deal_detail_id
		and uddft.udf_template_id=udf_formula.source_id AND udf_formula.is_final_result = ''y'' 	
	LEFT JOIN user_defined_deal_fields_template ud ON ud.template_id = sdh.template_id
		AND ud.field_id = 305013
	LEFT JOIN user_defined_deal_fields_template ud1 on ud1.template_id = sdh.template_id
		AND ud1.field_id= 308062
	LEFT JOIN user_defined_deal_fields uddf1 on uddf1.udf_template_id = ud1.udf_template_id 
		AND uddf1.source_deal_header_id = td.source_deal_header_id
	LEFT JOIN user_defined_deal_fields uddf2 on uddf2.udf_template_id = ud.udf_template_id 
		AND uddf2.source_deal_header_id = td.source_deal_header_id
	LEFT JOIN delivery_path dp ON dp.path_id = uddf2.udf_value	
	left join #fuel_based_variable_charge fbvc on fbvc.location_id=td.location_id and fbvc.term_start=td.term_start
	--OUTER APPLY(SELECT try_cast(uddf.udf_value as int)	udf_value FROM user_defined_deal_fields uddf INNER JOIN user_defined_deal_fields_template udddft ON uddf.udf_template_id=udddft.udf_template_id WHERE uddf.source_deal_header_id=td.source_deal_header_id and udddft.field_id=-5604) uddf_broker
	LEFT JOIN #tmp_source_fees sfv ON sfv.source_deal_detail_id=td.source_deal_detail_id AND sfv.field_id=uddft.field_name
	LEFT JOIN contract_group cg ON cg.contract_id = td.contract_id
	outer apply (select top(1) storage_capacity,CASE WHEN ownership_type=45301 THEN ''s'' ELSE ''b'' END st_buy_sell_flag  from  general_assest_info_virtual_storage
			where agreement = td.contract_id
		) gaivs 		
	outer apply
	(
		select source_deal_header_id,source_deal_detail_id,leg, term_start, term_end
			,max(formula_rounding) formula_rounding, max(product_id) product_id,max(buy_sell_flag) buy_sell_flag
			,max(formula_conv_factor) formula_conv_factor,max(formula_conv_factor_deal) formula_conv_factor_deal
			,max(formula_conv_factor_inv) formula_conv_factor_inv
			,max( deal_cur_id) deal_cur_id, max(inv_cur_id) inv_cur_id,max(func_cur_id) func_cur_id
			,sum(volume) volume
			,sum(deal_volume) deal_volume
			,sum(contract_value_deal) contract_value_deal,sum(market_value_deal) market_value_deal
			,sum(contract_value) contract_value, sum(market_value) market_value
			,sum(contract_value_inv) contract_value_inv, sum(market_value_inv ) market_value_inv
		from #temp_leg_mtm  where source_deal_detail_id = td.source_deal_detail_id
		AND ISNULL(shipment_id, -1) = ISNULL(td.shipment_id, -1) AND ISNULL(ticket_detail_id, -1) = ISNULL(td.ticket_detail_id, -1)
		group by source_deal_header_id,source_deal_detail_id,leg, term_start, term_end
	) tlm	
	outer apply ( SELECT 
					CASE WHEN COALESCE(udddf.receive_pay,uddf.receive_pay,case when ISNULL(gaivs.st_buy_sell_flag,td.buy_sell_flag)=''b'' then ''p'' else ''r'' end)=''r'' THEN  
						1  
					ELSE -1 END sgn) sgn
		 '		

	SET @qry8b=	' 
	WHERE udft.internal_field_type IN(18744,18745) and	udft.internal_field_type IS NOT NULL AND COALESCE(sfv.value,udddf.udf_value,uddf.udf_value,cast(udf_formula.formula_eval_value as varchar), sddh.vol) is not null and
		(( udft.internal_field_type <> 18722 AND ISNUMERIC(COALESCE(sfv.value,udddf.udf_value,uddf.udf_value,cast(udf_formula.formula_eval_value as varchar), sddh.vol)) = 1) OR udft.internal_field_type = 18722)
			AND	udft.internal_field_type<>18718 and 
		CASE WHEN (udft.internal_field_type IN (18702, 18703,18717)) THEN ABS(coalesce(td.capacity, cg.mdq,gaivs.storage_capacity))
		ELSE			
			--CASE WHEN isnull(hv.curve_id,-1)=-1 THEN td.deal_volume  ELSE ABS(hv.volume) END 
			1
	END <> 0 and ((op.source_deal_header_id is not null and td.leg = 1) or op.source_deal_header_id is null)
	GROUP BY  
			td.source_deal_header_id,
			td.leg,
			CASE WHEN '''+@cpt_type+'''=''b'' THEN CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME)
		WHEN --op.source_deal_header_id IS NOT NULL and 
			uddft.internal_field_type IN (18722) THEN 
				case when COALESCE(udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) is not null or ''s''=''' +@calc_type+''' then 
				--CAST(CONVERT(VARCHAR(7),ISNULL(sdh.option_settlement_date,sdh.deal_date),120)+''-01'' AS DATETIME) 
				ISNULL(sdh.option_settlement_date,sdh.deal_date) 
				else td.term_start  end 
		WHEN uddft.internal_field_type IN(18723,18724) THEN CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME) 
		ELSE td.term_start END, 
	CASE WHEN '''+@cpt_type+'''=''b'' THEN DATEADD(m,1,CAST(CONVERT(VARCHAR(7),ISNULL(sdh.option_settlement_date,sdh.deal_date),120)+''-01'' AS DATETIME))-1
		WHEN --op.source_deal_header_id IS NOT NULL and 
			uddft.internal_field_type IN (18722) THEN 
				case when COALESCE(udf_formula.formula_eval_value,udddf.udf_value,uddf.udf_value) is not null or ''s''=''' +@calc_type+''' then
				-- DATEADD(m,1,CAST(CONVERT(VARCHAR(7),ISNULL(sdh.option_settlement_date,sdh.deal_date),120)+''-01'' AS DATETIME))-1 
				 ISNULL(sdh.option_settlement_date,sdh.deal_date)
				else td.term_end  end 
		WHEN uddft.internal_field_type IN(18723,18724) THEN DATEADD(m,1,CAST(CONVERT(VARCHAR(7),sdh.deal_date,120)+''-01'' AS DATETIME))-1 ELSE td.term_end END ,		
	uddft.field_name , uddft.field_label '+CASE WHEN @cpt_type ='b' THEN '' ELSE ',td.source_deal_detail_id' END 

	SET @qry9b = '

	--create index indx_tmp_fees_breakdown on #tmp_fees_breakdown (internal_type,f_value,filter1);


	INSERT INTO #fees_breakdown_tax(
		as_of_date, source_deal_header_id,leg,term_start, term_end,		
		field_id, field_name, price_deal,price,price_inv, total_price_deal,total_price
		,total_price_inv,volume,value,value_deal,value_inv,deal_cur_id,inv_cur_id
		,contract_value,contract_value_deal,contract_value_inv,internal_type,tab_group_name
		,udf_group_name,sequence,fee_currency_id,currency_id,contract_mkt_flag,source_deal_detail_id
		--,shipment_id,ticket_detail_id
	)  		
	SELECT as_of_date, source_deal_header_id,leg,term_start, term_end,		
		field_id, field_name, price_deal,price,price_inv, total_price_deal,total_price
		,total_price_inv,NULL,value,
		CASE WHEN minimum_value IS NOT NULL AND ABS(value_deal) < ABS(minimum_value) THEN minimum_value
			 WHEN maximum_value IS NOT NULL AND ABS(value_deal) > ABS(maximum_value) THEN maximum_value
			 ELSE value_deal
		END value_deal
		,value_inv,deal_cur_id,inv_cur_id
		,contract_value,contract_value_deal,contract_value_inv,internal_type,tab_group_name
		,udf_group_name,sequence,fee_currency_id,currency_id,contract_mkt_flag,source_deal_detail_id
		--,shipment_id,ticket_detail_id
	 from #tmp_fees_breakdown_000_tax 
	 where internal_type IS NOT NULL AND (( internal_type <> 18722 AND f_value = 1) OR internal_type = 18722)
			AND	internal_type<>18718 and filter1 <> 0 '


	exec spa_print @sqlstmt

	exec spa_print @qry1b
	exec spa_print @qry2b
	exec spa_print @qry3b
	exec spa_print @qry4b
	exec spa_print @qry5b
	exec spa_print @qry6b
	exec spa_print @qry7b
	exec spa_print @qry8b
	exec spa_print @qry9b

	EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;'
		+@qry1b+@qry2b+@qry3b+@qry4b+@qry5b+@qry6b+@qry7b+@qry8b+@qry9b)

	--SELECT * FROM #fees_breakdown_tax RETURN
	---------------------------------------------------------
	-- convert into invoice currency from deal currency------
	---------------------------------------------------------
	UPDATE #fees_breakdown_tax SET
		value_inv = value_deal * COALESCE(a.invoice_fx_rate, fx.price_fx_conv_factor, 1),
		price_inv = price_deal * COALESCE(a.invoice_fx_rate, fx.price_fx_conv_factor, 1),
		total_price_inv = total_price_deal * COALESCE(a.invoice_fx_rate, fx.price_fx_conv_factor, 1)
	FROM #fees_breakdown_tax f
	INNER JOIN #temp_deals a ON a.source_deal_detail_id = f.source_deal_detail_id
	OUTER APPLY
	(	
		SELECT ROUND(AVG(price_fx_conv_factor), a.fx_rounding)  price_fx_conv_factor 
		FROM #fx_curves 
		WHERE fx_currency_id = a.fixed_price_currency_id 
		AND func_cur_id = a.settlement_currency 
		AND source_system_id = a.source_system_id
		AND maturity_date BETWEEN a.term_start AND a.term_end
	) fx

	--------------------------------------------------------------	
	-- convert into functional currency from invoice currency 
	--------------------------------------------------------------

	UPDATE #fees_breakdown_tax SET
		[value] = value_deal * ISNULL(fx.price_fx_conv_factor, 1),
		price = price_deal * ISNULL(fx.price_fx_conv_factor, 1),
		total_price = total_price_deal * ISNULL(fx.price_fx_conv_factor, 1)
	FROM #fees_breakdown_tax f
	INNER JOIN #temp_deals a ON a.source_deal_detail_id = f.source_deal_detail_id
	OUTER APPLY
		(
		SELECT ROUND(AVG(price_fx_conv_factor), a.fx_rounding)  price_fx_conv_factor 
		FROM #fx_curves 
		WHERE fx_currency_id = a.fixed_price_currency_id 
		AND func_cur_id = a.func_cur_id AND source_system_id = a.source_system_id
		AND maturity_date BETWEEN a.term_start AND a.term_end) fx
	--------------------------------------------------------------------------------------

	IF @calc_settlement_adjustment = 0
	BEGIN
		SET @sql = 
		'DELETE  top(100000) sc
			from ' + dbo.FNAGetProcessTableName(@as_of_date, 'index_fees_breakdown_settlement') +  ' i 
			INNER JOIN stmt_checkout sc ON sc.index_fees_id = i.index_fees_id AND sc.type = ''Cost'' AND sc.accrual_or_final = ''f''
			inner join #fees_breakdown_tax f ON 
					i.source_deal_header_id=f.source_deal_header_id
					AND ISNULL(f.ticket_detail_id, -1) = coalesce(i.ticket_detail_id, f.ticket_detail_id,-1) 
					and i.term_start=f.term_start and i.term_end=f.term_end
					AND DATEADD(m,1,CAST(CAST(YEAR(i.term_end) AS VARCHAR)+''-''+CAST(MONTH(i.term_end) AS VARCHAR)+''-01'' AS DATETIME))-1<= '''+@last_business_day+''''
		+CASE WHEN @cpt_type='b' THEN ' AND f.internal_type IN(18723)' ELSE ' AND f.internal_type NOT IN(18723)' END + 

		'DELETE  top(100000) index_fees_breakdown_settlement
			from ' + dbo.FNAGetProcessTableName(@as_of_date, 'index_fees_breakdown_settlement') +  ' i 
			inner join #fees_breakdown_tax f ON 
					i.source_deal_header_id=f.source_deal_header_id AND i.internal_type=f.internal_type
					AND ISNULL(f.ticket_detail_id, -1) = coalesce(i.ticket_detail_id, f.ticket_detail_id,-1) 
					and ((i.term_start=f.term_start and i.term_end=f.term_end) or f.internal_type=18722)
							AND DATEADD(m,1,CAST(CAST(YEAR(i.term_end) AS VARCHAR)+''-''+CAST(MONTH(i.term_end) AS VARCHAR)+''-01'' AS DATETIME))-1<= '''+@last_business_day+'''
							and	f.value IS NOT NULL '
			
					
		WHILE 1 = 1
		BEGIN
			exec('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;'+@sql)
			IF @@rowcount < 100000 BREAK;
		END


		SET @sql = 
		'DELETE  top(100000) sc
			from ' + dbo.FNAGetProcessTableName(@as_of_date, 'index_fees_breakdown_settlement') +  ' i 
			INNER JOIN stmt_checkout sc ON sc.index_fees_id = i.index_fees_id AND sc.type = ''Cost'' AND sc.accrual_or_final = ''f''
			inner join #fees_breakdown_tax f ON 
				i.source_deal_header_id=f.source_deal_header_id
				AND ISNULL(f.ticket_detail_id, -1) = coalesce(i.ticket_detail_id, f.ticket_detail_id,-1) 
				and i.term_start=f.term_start and i.term_end=f.term_end
				AND DATEADD(m,1,CAST(CAST(YEAR(i.term_end) AS VARCHAR)+''-''+CAST(MONTH(i.term_end) AS VARCHAR)+''-01'' AS DATETIME))-1 > '''+@as_of_date+''' AND i.as_of_date = '''+@as_of_date+''''
		+CASE WHEN @cpt_type='b' THEN ' AND f.internal_type IN(18723)' ELSE ' AND f.internal_type NOT IN(18723)' END +
		
		'DELETE  top(100000) index_fees_breakdown_settlement
			from ' + dbo.FNAGetProcessTableName(@as_of_date, 'index_fees_breakdown_settlement') +  ' i 
			inner join #fees_breakdown_tax f ON 
				i.source_deal_header_id=f.source_deal_header_id AND i.internal_type=f.internal_type
				AND ISNULL(f.ticket_detail_id, -1) = coalesce(i.ticket_detail_id, f.ticket_detail_id,-1) 
				and ((i.term_start=f.term_start and i.term_end=f.term_end) or f.internal_type=18722)
				AND DATEADD(m,1,CAST(CAST(YEAR(i.term_end) AS VARCHAR)+''-''+CAST(MONTH(i.term_end) AS VARCHAR)+''-01'' AS DATETIME))-1 > '''+@as_of_date+''' AND i.as_of_date = '''+@as_of_date+''''
		+CASE WHEN @cpt_type='b' THEN ' AND f.internal_type IN(18723)' ELSE ' AND f.internal_type NOT IN(18723)' END

				WHILE 1 = 1
		BEGIN
			exec('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;'+@sql)
			IF @@rowcount < 100000 BREAK;
		END
	END


	SET @sql=
			'INSERT INTO index_fees_breakdown_settlement
				(
					as_of_date,
					source_deal_header_id,
					leg,
					term_start,
					term_end,
					field_id,
					field_name,
					price,
					total_price,
					volume,
					value,
					contract_value,
					internal_type,
					tab_group_name,
					udf_group_name,
					sequence,
					fee_currency_id,
					currency_id,
					create_user,
					create_ts,
					set_type,
					contract_mkt_flag,
					value_deal,
					value_inv,
					deal_cur_id,
					inv_cur_id,
					shipment_id,
					ticket_detail_id
				)
			SELECT f.as_of_date, 
					f.source_deal_header_id, 
					f.leg, 
					f.term_start, 
					f.term_end, 
					f.field_id, 
					f.field_name, 
					sum(f.price) price,
					sum(f.total_price) total_price, 
					sum(f.volume) volume, 
					sum(f.value) value, 
					sum(f.contract_value) contract_value, 
					f.internal_type, 
					f.tab_group_name, 
					f.udf_group_name,
					max(f.sequence) sequence, 
					max(f.fee_currency_id) fee_currency_id, 
					max(f.currency_id) currency_id,
					'''+@user_id+''' create_user, 
					GETDATE() create_ts,
					CASE WHEN f.term_end <= '''+@as_of_date+''' THEN ''s'' ELSE ''f'' END [set_type],
					f.contract_mkt_flag,
					sum(value_deal) [value_deal],
					sum(value_inv) [value_inv],
					max(deal_cur_id) [deal_cur_id],
					max(inv_cur_id) [inv_cur_id],
					f.shipment_id,
					f.ticket_detail_id
			FROM  #fees_breakdown_tax f 
			WHERE f.value IS NOT NULL								
			GROUP BY f.as_of_date, 
				f.source_deal_header_id, 
				f.leg, 
				f.term_start, 
				f.term_end, 
				f.field_id, 
				f.field_name,
				f.internal_type, 
				f.tab_group_name, 
				f.udf_group_name,
				f.contract_mkt_flag,
				f.shipment_id,
				f.ticket_detail_id
			OPTION (MAXRECURSION 32767, MAXDOP 8 )'

			EXEC spa_print @sql
			EXEC(@sql)

			--Deleted +/- commodity settlement after calculating VAT/TAX
			DELETE sds
			FROM source_deal_settlement sds
			INNER JOIN index_fees_breakdown_settlement ifbs ON ifbs.source_deal_header_id = sds.source_deal_header_id
				AND ifbs.as_of_date = sds.as_of_date
				AND ifbs.term_start = sds.term_start
			WHERE ifbs.internal_type IN (18742,18743)
			AND ifbs.as_of_date = @as_of_date