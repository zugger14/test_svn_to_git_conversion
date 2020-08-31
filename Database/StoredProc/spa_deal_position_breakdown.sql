IF OBJECT_ID(N'spa_deal_position_breakdown', N'P') IS NOT NULL
	DROP PROC [dbo].[spa_deal_position_breakdown]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 /**
	Prepare multiplying factors of simple formula for finalcial position calculation.
	
	Parameters : 
	@process_flag : Data manupulation type
						- 'd' - Delete data 
						- 'i' - Insert data 
						- 'u' - Update data 
	@source_deal_header_id : Source Deal Header Id filter to manupulate.
	@user_login_id : User Login Id of runner
	@process_id : Process Id for process table having prefix report_position for multiple deal manupulation 
*/
CREATE PROCEDURE [dbo].[spa_deal_position_breakdown] (
    @process_flag           VARCHAR(1) = 'i',
    @source_deal_header_id  VARCHAR(5000),
    @user_login_id          VARCHAR(50) = NULL,
    @process_id             VARCHAR(100) = NULL
)
AS
	
SET NOCOUNT ON
SET ANSI_WARNINGS OFF;  
	
-------------BEGIN OF TEST
/*


SET nocount off	
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
 
 exec dbo.spa_drop_all_temp_table

declare @source_deal_header_id int = null --1057
declare @process_flag VARCHAR(1) --d is delete otherwise insert
declare @process_id VARCHAR(100) -- if formula changed...
declare @user_login_id VARCHAR(50)
set @source_deal_header_id = null
set @process_flag = 'i'
set @user_login_id = 'dev_admin'
set @process_id = 'A86F66A5_985E_40DB_86F7_72155EA7F324'

if OBJECT_ID('tempdb..#function_lists') is not null drop table #function_lists
if OBJECT_ID('tempdb..#deal_legs') is not null drop table #deal_legs
if OBJECT_ID('tempdb..#factor_formula_value') is not null drop table #factor_formula_value
if OBJECT_ID('tempdb..#deal_position_break_down') is not null drop table #deal_position_break_down
if OBJECT_ID('tempdb..#deal_position_break_down_final') is not null drop table #deal_position_break_down_final
if OBJECT_ID('tempdb..#pv') is not null drop table #pv
if OBJECT_ID('tempdb..#deals') is not null drop table #deals
if OBJECT_ID('tempdb..#error_deals') is not null drop table #error_deals
if OBJECT_ID('tempdb..#simple_formula') is not null drop table #simple_formula
if OBJECT_ID('tempdb..#temp_curve_udf') is not null drop table #temp_curve_udf
if OBJECT_ID('tempdb..#tmp_adder_multiplier') is not null drop table #tmp_adder_multiplier
if OBJECT_ID('tempdb..#tmp_adder_multiplier1') is not null drop table #tmp_adder_multiplier1
if OBJECT_ID('tempdb..#price_dates') is not null drop table #price_dates
if OBJECT_ID('tempdb..#term_breakdown') is not null drop table #term_breakdown
if OBJECT_ID('tempdb..#factor_formula_value_lc') is not null drop table #factor_formula_value_lc

--CLOSE cursor0;
--DEALLOCATE cursor0;
--CLOSE cursor1;
--DEALLOCATE cursor1;

--*/
------------------END OF TEST
-- select * from deal_position_break_down  where source_deal_header_id = 223683

DECLARE @report_position_deals VARCHAR(300), @process_id2 VARCHAR(100), @error_process_tbl VARCHAR(300)
	,@multiplier2 float,@adder2 float,@function_part VARCHAR(max),@adder_multiplier VARCHAR(max),@i int,@sign_add_mult VARCHAR(1),@value_add_mult VARCHAR(20)
						
DECLARE @str_adder VARCHAR(1000),@str_multiplier VARCHAR(1000),@sql_str VARCHAR(MAX)

set @process_id2 = REPLACE(newid(),'-','_')
If @user_login_id IS NULL
	SET @user_login_id = dbo.FNADBUser()

SET @error_process_tbl = dbo.FNAProcessTableName('position_breakdown_error', @user_login_id,@process_id2)
SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)

declare @pricing_index varchar(10), @func_udf_curve  varchar(3000)
select @pricing_index=value_id from static_data_value 
where code = 'Pricing Index'

CREATE TABLE #deals (source_deal_header_id INT, process_flag VARCHAR(1) COLLATE DATABASE_DEFAULT)

CREATE TABLE #factor_formula_value (factor FLOAT)
CREATE TABLE  #factor_formula_value_lc (factor FLOAT,[type] VARCHAR(100) COLLATE DATABASE_DEFAULT)

CREATE TABLE #deal_position_break_down(
	[source_deal_header_id] [int] NULL,
	[source_deal_detail_id] [int] NULL,
	[leg] [int] NULL,
	[strip_from] [int] NULL,
	[lag] [int] NULL,
	[strip_to] [int] NULL,
	[curve_id] [int] NULL,
	[prior_year] [int] NULL,
	[multiplier] [float] NULL,
	[derived_curve_id] [float] NULL,
	[term_start] [datetime] NULL,
	[exp_date] [datetime] NULL,
	[pay_opposite] [VARCHAR](1) COLLATE DATABASE_DEFAULT NULL,
	[buy_sell_flag] [VARCHAR](1) COLLATE DATABASE_DEFAULT NULL,
	[exp_type] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
	[exp_value] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
	formula VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,formula_adder FLOAT,formula_multiplier FLOAT,complex_formula VARCHAR(1) COLLATE DATABASE_DEFAULT,divider int null,pricing_term datetime,density_mult float
	)

create table #pv (formula VARCHAR(8000) COLLATE DATABASE_DEFAULT, clm1 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm2 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm3 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm4 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm5 VARCHAR(500) COLLATE DATABASE_DEFAULT,
				clm6 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm7 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm8 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm9 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm10 VARCHAR(500) COLLATE DATABASE_DEFAULT,
				clm11 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm12 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm13 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm14 VARCHAR(500) COLLATE DATABASE_DEFAULT, clm15 VARCHAR(500) COLLATE DATABASE_DEFAULT)


EXEC('CREATE TABLE ' + @error_process_tbl + ' (source_deal_header_id INT, error_message VARCHAR(500))')


BEGIN TRY

If @process_id IS NULL
	INSERT INTO #deals
	SELECT source_deal_header_id,
	       ISNULL(@process_flag, 'i') process_flag
	FROM   source_deal_header sdh
	INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
	ON scsv.item = sdh.source_deal_header_id

Else
	EXEC('insert into #deals select source_deal_header_id, [action] from ' + @report_position_deals + ' 
	--where action = ''f'' OR action = ''i'''
	)

IF isnull(@process_flag, 'i') = 'd' 
BEGIN
	DELETE dpbd
	FROM   deal_position_break_down dpbd
	       INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
	            ON  scsv.item = dpbd.source_deal_header_id
	RETURN -- NO NEED TO PROCESS FURTHER IF THE DEAL HAS BEEN DELETED
END




select	sdd.source_deal_header_id, source_deal_detail_id, leg, 
		max(formula) formula, max(sdd.curve_id) derived_curve_id, term_start, 
		max(contract_expiration_date) exp_date, isnull(max(pay_opposite), 'n') pay_opposite,
		max(buy_sell_flag) buy_sell_flag, NULL formula_curve_id,MAX(spcd.formula_id) formula_id,max(sdd.apply_to_all_legs) apply_to_all_legs
into #deal_legs
from	#deals d INNER JOIN
		source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id LEFT JOIN
		source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id LEFT JOIN
		formula_editor fe on fe.formula_id = spcd.formula_id 
where	spcd.formula_id is not null
		AND sdd.physical_financial_flag = 'f'
group by sdd.source_deal_header_id, leg, term_start,source_deal_detail_id
UNION ALL
select  sdd.source_deal_header_id,  source_deal_detail_id, leg, 
		max(formula), NULL derived_curve_id, term_start, max(contract_expiration_date) exp_date,
		isnull(max(pay_opposite), 'n') pay_opposite, max(buy_sell_flag) buy_sell_flag, NULL formula_curve_id ,MAX(sdd.formula_id) formula_id,max(sdd.apply_to_all_legs) apply_to_all_legs
from	#deals d INNER JOIN
		source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id LEFT JOIN
		formula_editor fe on fe.formula_id = sdd.formula_id 
where	sdd.formula_id is not null
group by sdd.source_deal_header_id, leg, term_start,source_deal_detail_id
UNION ALL
select	sdd.source_deal_header_id, source_deal_detail_id, leg, 
		max(formula) formula, null derived_curve_id, term_start, 
		max(contract_expiration_date) exp_date, isnull(max(pay_opposite), 'n') pay_opposite,
		max(buy_sell_flag) buy_sell_flag, max(sdd.formula_curve_id) formula_curve_id,MAX(spcd.formula_id) formula_id
		,max(sdd.apply_to_all_legs) apply_to_all_legs
--select spcd.formula_id ,* 
from	#deals d INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id 
	inner JOIN source_price_curve_def spcd on spcd.source_curve_def_id = sdd.formula_curve_id
	inner JOIN formula_editor fe on fe.formula_id = spcd.formula_id 
where	spcd.formula_id is not null
		--AND sdd.physical_financial_flag = 'f'
group by sdd.source_deal_header_id, leg, term_start,source_deal_detail_id
union all
select  sdd.source_deal_header_id,  sdd.source_deal_detail_id, leg, 
		max(formula), NULL derived_curve_id, term_start, max(contract_expiration_date) exp_date,
		isnull(max(pay_opposite), 'n') pay_opposite, max(buy_sell_flag) buy_sell_flag, NULL formula_curve_id ,MAX(dpd.formula_id) formula_id,max(sdd.apply_to_all_legs) apply_to_all_legs
from	#deals d INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id 
	inner join deal_price_type dpt on sdd.source_deal_detail_id=dpt.source_deal_detail_id
	--  and sdd.source_deal_header_id=6597
	--	and dpt.source_deal_detail_id=212941  -- @deal_detail_id --
	cross apply
	(
		select formula_id from  deal_price_deemed where dpt.price_type_id=103602 and deal_price_type_id= dpt.deal_price_type_id
		union all
		select formula_id from  deal_detail_formula_udf where dpt.price_type_id=103606 and deal_price_type_id= dpt.deal_price_type_id
	) dpd
	LEFT JOIN formula_editor fe on fe.formula_id = dpd.formula_id 
where	dpd.formula_id is not null
group by sdd.source_deal_header_id, leg, term_start,sdd.source_deal_detail_id

--	 left join
--	 #error_deals e ON dp.source_deal_header_id = e.source_deal_header_id
--WHERE e.source_deal_header_id IS NULL

UPDATE source_deal_detail SET formula_curve_id = NULL 
FROM #deals d INNER JOIN source_deal_detail sdd 
	ON d.source_deal_header_id =sdd.source_deal_header_id AND sdd.formula_id IS NOT NULL 

--If (select count(*) from #deal_legs) < 1
--BEGIN
--	if exists(select 1	from #deals d INNER JOIN	source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id 
--		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = d.source_deal_header_id	
--		where	sdd.formula_id is null AND (sdd.formula_curve_id is not null AND ISNULL(sdh.internal_deal_type_value_id,-1) NOT IN(19,20,21)))
--		goto skip_loop

--	SELECT	'Success' ErrorCode, 'Deal Position Breakdown' Module, 'spa_deal_position_breakdown' Area, 
--			'Success' Status, 'Position calculated successfully.' [Message], 
--			'' Recommendation

--	RETURN
--END

--for testing
--update #deal_legs set formula='dbo.FNACurveH(6,dbo.FNAUDFValue(300603))*dbo.FNAUDFValue(300503)*1*2*3*dbo.FNAUDFValue(4)+dbo.FNAUDFValue(300502)+6+7+8+dbo.FNAUDFValue(9)'
--update #deal_legs set formula='dbo.FNACurveY(20) + dbo.FNALagCurve(7,0,0,0,1,NULL,0, dbo.FNAUOMCOnv(19,10)) '
--update #deal_legs set formula='dbo.FNACurveD(9, dbo.FNAUDFValue(291887))'
--update #deal_legs set formula='dbo.FNACurveD(7, 0.4)'
--update #deal_legs set formula='dbo.FNACurveH(9)'
--update #deal_legs set formula='dbo.FNACurveD(7)'
--dbo.FNAUDFValue(291624)
--select * from #deal_legs 
--return


declare @formula_str_o VARCHAR(8000)
declare @next_str VARCHAR(8000)
declare @index INT
declare @index2 INT
declare @index3 INT
declare @function_name VARCHAR(500)
declare @function_name_par VARCHAR(500)
declare @source_deal_detail_id int
declare @deal_header_id int
declare @leg int
declare @formula_str VARCHAR(8000)
declare @factor_value float
DECLARE @clm1 VARCHAR(8000), @clm2 VARCHAR(8000), @clm3 VARCHAR(8000), @clm4 VARCHAR(8000), @clm5 VARCHAR(8000), @clm6 VARCHAR(8000), @clm7 VARCHAR(8000), @clm8 VARCHAR(8000)
DECLARE @sql VARCHAR(5000),@first_time VARCHAR(1),@index_par INT,@formula_id int,@complex_formula VARCHAR(1),@no_rec_eff int,@BL_pricing_curve_id int ,@CFD_month datetime

declare @currency_factor float, @price_uom_factor float, @display_uom INT, @price_uom INT, @position_currency INT,@formula_currency int,@apply_to_all_legs VARCHAR(1)
DECLARE @density float,@density_multiplier float,@display_uom_to int,@call_from int

--INSERT ALL THE FUNCTIONS THAT REQUIRE POSITION BREAK DOWN
CREATE TABLE #function_lists(function_name VARCHAR(500) COLLATE DATABASE_DEFAULT)
insert into #function_lists values('dbo.FNALagCurve')
--insert into #function_lists values('dbo.FNACurve')
insert into #function_lists values('dbo.FNACurveD')
insert into #function_lists values('dbo.FNACurveY')
insert into #function_lists values('dbo.FNAAvg')
insert into #function_lists values('dbo.FNACurveH')
insert into #function_lists values('dbo.FNACurveM')
insert into #function_lists values('dbo.FNACurveQ')
insert into #function_lists values('dbo.FNACurve')
insert into #function_lists values('dbo.FNACurve15')
insert into #function_lists values('dbo.FNAAverageCurveValue')
insert into #function_lists values('dbo.FNAAverageMonthlyCurveValue')
insert into #function_lists values('dbo.FNAWACOGPrice')
insert into #function_lists values('dbo.FNAGetCurveValue')
insert into #function_lists values('dbo.FNAContractFixPrice')
insert into #function_lists values('dbo.FNAContractPriceValue')

CREATE TABLE #temp_curve_udf (tmp_value VARCHAR(100) COLLATE DATABASE_DEFAULT)

SET NOCOUNT ON;



DECLARE cursor10 CURSOR FOR 
SELECT source_deal_header_id,  source_deal_detail_id, max(leg), formula,max(formula_id),max(apply_to_all_legs) 
FROM #deal_legs
group by source_deal_header_id, source_deal_detail_id, formula
order by source_deal_header_id, source_deal_detail_id
OPEN cursor10;

FETCH NEXT FROM cursor10 INTO @deal_header_id, @source_deal_detail_id, @leg, @formula_str,@formula_id,@apply_to_all_legs;

WHILE @@FETCH_STATUS = 0
BEGIN
	--select @formula_str='dbo.FNACurveD(10,dbo.FNAUDFValue(-5556))*1.1*1.5+0.5+0.25-0.05'
	set @formula_str_o = @formula_str
	set @formula_str = replace(@formula_str, ' ', '')
	set @formula_str = replace(@formula_str, 'asfloat', ' as float')

	EXEC spa_print @formula_str_o
	set @first_time='y'

--SELECT @formula_str_o


	DECLARE cursor1 CURSOR FOR 
		SELECT function_name, function_name+'(' FROM #function_lists
	OPEN cursor1;

	FETCH NEXT FROM cursor1 INTO @function_name, @function_name_par;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @index = 1
		set @formula_str = @formula_str_o
		
		set @str_adder=null
		set @str_multiplier=null


		while (@index <> 0)
		BEGIN
			SELECT @index = CHARINDEX(@function_name_par, @formula_str, 1)
			
			If @index = 0 
				break

		--select @formula_str, @function_name_par, @index
			EXEC spa_print @formula_str
			exec spa_parse_function @formula_str, @function_name_par, @index, @next_str OUTPUT, @index2 OUTPUT

			--select @formula_str, @function_name_par, @index, @next_str , @index2
			set @function_part=@next_str
			
			If @index2 = 0 --formula not found any more
				break

			set @index = charindex('(', @next_str, 1)
			set @next_str = substring(@next_str, @index+1,  len(@next_str)-@index-1)
				--select @next_str
			--select @function_name, 'A', @next_str
			If @function_name = 'dbo.FNALagCurve'
			BEGIN

				delete from #pv
				delete from #factor_formula_value 
				INSERT into #pv select @formula_str_o, * from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)

				--select @clm8 = clm8 + isnull(',' + clm9, '') from #pv
				select @clm1 = clm1 from #pv
				select @clm2 = clm2 from #pv
				select @clm3 = clm3 from #pv
				select @clm4 = clm4 from #pv
				select @clm5 = clm5 from #pv
				select @clm6 = clm6 from #pv
				select @clm7 = clm7 from #pv
				select @clm8 = clm8 from #pv
			
				
								
				set @clm8 =  replace(@clm8, 'dbo.FNAUOMConv', 'dbo.FNAEMSUOMConv')
				set @clm1 =  replace(@clm1, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
				set @clm2 =  replace(@clm2, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
				set @clm3 =  replace(@clm3, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
				set @clm4 =  replace(@clm4, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
				set @clm5 =  replace(@clm5, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
				set @clm6 =  replace(@clm6, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
				set @clm7 =  replace(@clm7, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
				set @clm8 =  replace(@clm8, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')

				set @clm8 =  replace(@clm8, 'dbo.FNAFieldValue(', 'dbo.FNARFieldValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')

				--print  @clm8
				
				exec('insert into #factor_formula_value_lc select ' + @clm1+',''clm1''')
				exec('insert into #factor_formula_value_lc select ' + @clm2+',''clm2''')
				exec('insert into #factor_formula_value_lc select ' + @clm3+',''clm3''')
				exec('insert into #factor_formula_value_lc select ' + @clm4+',''clm4''')
				exec('insert into #factor_formula_value_lc select ' + @clm5+',''clm5''')
				exec('insert into #factor_formula_value_lc select ' + @clm6+',''clm6''')
				exec('insert into #factor_formula_value_lc select ' + @clm7+',''clm7''')
				exec('insert into #factor_formula_value_lc select ' + @clm8+',''clm8''')

				select @clm1 = factor from #factor_formula_value_lc where [type]='clm1'
				select @clm2 = factor from #factor_formula_value_lc where [type]='clm2'
				select @clm3 = factor from #factor_formula_value_lc where [type]='clm3'
				select @clm4 = factor from #factor_formula_value_lc where [type]='clm4'
				select @clm5 = factor from #factor_formula_value_lc where [type]='clm5'
				select @clm6 = factor from #factor_formula_value_lc where [type]='clm6'
				select @clm7 = factor from #factor_formula_value_lc where [type]='clm7'
				select @factor_value = factor from #factor_formula_value_lc where [type]='clm8'


				set @currency_factor=NULL
				set @price_uom_factor=NULL
				
				SELECT @display_uom = MAX(isnull(spcd.display_uom_id, spcd.uom_id)),
					   @price_uom = max(sdd.price_uom_id),
					   @position_currency = max(spcd.source_currency_id),
					   @formula_currency = max(sdd.formula_currency_id)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id 
				where source_deal_detail_id = @source_deal_detail_id
				
				select @currency_factor = max(sc.factor) from 
					source_deal_detail sdd inner join
					source_currency sc on sc.source_currency_id = sdd.formula_currency_id
				where source_deal_detail_id = @source_deal_detail_id
					and sdd.formula_currency_id is not null
					
				set @price_uom_factor=NULL
				select  @price_uom_factor = max(vuc.conversion_factor)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id inner join
					rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)   AND
									vuc.to_source_uom_id = sdd.price_uom_ID
				where source_deal_detail_id = @source_deal_detail_id
					and sdd.price_uom_id IS NOT NULL 
					and isnull(spcd.display_uom_id, spcd.uom_id) <> ISNULL(sdd.price_uom_id, -1) 
					
				INSERT INTO #deal_position_break_down
				SELECT	source_deal_header_id, source_deal_detail_id, leg, 
						cast(@clm3 as int) strip_from, cast(@clm4 as int) lag,
						cast(@clm5 as int) strip_to, cast(@clm1 as INT) curve_id, CAST(@clm2 as INT) prior_year,
						isnull(@factor_value, 1) * 
						CASE WHEN (@formula_currency IS NOT NULL AND @position_currency<>@formula_currency AND @display_uom<>isnull(spcd.display_uom_id, spcd.uom_id)) THEN ISNULL(@currency_factor, 1) ELSE 1 END * 												 
						CASE WHEN (@price_uom IS NOT NULL AND @display_uom<>isnull(spcd.display_uom_id, spcd.uom_id)) THEN ISNULL(@price_uom_factor, 1) ELSE 1 END multiplier, 
						derived_curve_id, term_start, exp_date, pay_opposite, buy_sell_flag,REPLACE(clm9,'''','') exp_type,REPLACE(clm10,'''','') exp_value,@function_name
					,0 formula_adder ,1 formula_multiplier,null complex_formula,1 divider,null pricing_term,null density_mult
				from #deal_legs inner join
					#pv ON #deal_legs.formula = #pv.formula left join
					source_price_curve_def spcd on spcd.source_curve_Def_id = cast(@clm1 as INT)
				where [source_deal_detail_id] = @source_deal_detail_id
								
			END
			
			else If @function_name = 'dbo.FNAAverageCurveValue'
			BEGIN
				EXEC spa_print @function_name, ' BLOCK'
				delete from #pv
				delete from #factor_formula_value 
				INSERT into #pv select @formula_str_o, * from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)

				--select @clm8 = clm8 + isnull(',' + clm9, '') from #pv
				select @clm8 = clm1 from #pv
								
				set @clm8 =  replace(@clm8, 'dbo.FNAUOMConv', 'dbo.FNAEMSUOMConv')
				set @clm8 =  replace(@clm8, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')

				if isnull(@clm8,'')<>''
				begin

					exec spa_print 'insert into #factor_formula_value select ', @clm8
					exec('insert into #factor_formula_value select ' + @clm8)

					select @factor_value = nullif(factor,0) from #factor_formula_value
				end
				else 
					set @factor_value=null
					
				set @currency_factor=NULL
				set @price_uom_factor=NULL
				
				SELECT @display_uom = MAX(isnull(spcd.display_uom_id, spcd.uom_id)),
					   @price_uom = max(sdd.price_uom_id),
					   @position_currency = max(spcd.source_currency_id),
					   @formula_currency = max(sdd.formula_currency_id)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id 
				where sdd.source_deal_detail_id = @source_deal_detail_id
				
				select @currency_factor = max(sc.factor) from 
					source_deal_detail sdd inner join
					source_currency sc on sc.source_currency_id = sdd.formula_currency_id
				where sdd.source_deal_detail_id = @source_deal_detail_id
					and sdd.formula_currency_id is not null
					
				set @price_uom_factor=NULL
				select  @price_uom_factor = max(vuc.conversion_factor),@display_uom_to=max(sdd.price_uom_ID)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id inner join
					rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)   AND
									vuc.to_source_uom_id = sdd.price_uom_ID
				where sdd.source_deal_detail_id = @source_deal_detail_id
					and sdd.price_uom_id IS NOT NULL 
					and isnull(spcd.display_uom_id, spcd.uom_id) <> ISNULL(sdd.price_uom_id, -1) 
							
				SELECT 	  @density=udddf.udf_value
				FROM user_defined_deal_detail_fields udddf 
					INNER JOIN user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
					  AND uddft.Field_id=-5619  and udddf.source_deal_detail_id = @source_deal_detail_id --'Density'
		
				SELECT 	  @density_multiplier=udddf.udf_value
					FROM user_defined_deal_detail_fields udddf 
						INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
						 AND uddft.Field_id=-5620 and udddf.source_deal_detail_id = @source_deal_detail_id --'UOM Conversion'
				SELECT 	  @density_multiplier=isnull(@density_multiplier,1.00)/nullif(cast(isnull(udddf.udf_value,1.00) as float),0.00)
				--SELECT 	  @density_multiplier=isnull(@density_multiplier,1)/nullif(isnull(udddf.udf_value,1),0)
					FROM user_defined_deal_detail_fields udddf 
						INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
						 AND uddft.Field_id=-5633 and udddf.source_deal_detail_id = @source_deal_detail_id --UOM_Conversion_div
			
				SELECT 	  @BL_pricing_curve_id=udddf.udf_value
					FROM user_defined_deal_detail_fields udddf 
						INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
						  AND uddft.Field_id= @pricing_index
							and udddf.source_deal_detail_id = @source_deal_detail_id

				SET @call_from =NULL
				if @BL_pricing_curve_id is not null
				begin
					IF object_id('tempdb..#bl_priceing_term') IS NOT NULL
							DROP TABLE #bl_priceing_term 

					SELECT a.* into #bl_priceing_term from dbo.FNAGetBLPricingTerm(@source_deal_detail_id,@call_from) a
					select @no_rec_eff=@@rowcount

				end 
				
				
				if isnull(@density_multiplier,1) =1 and isnull(@density,0)<>0 and isnull(@display_uom,-1)<>isnull(@display_uom_to,-1)
				begin
					select @density_multiplier=clm5_value
					 from generic_mapping_values g 
					inner join generic_mapping_header h on g.mapping_table_id=h.mapping_table_id
						and h.mapping_name= 'Density Conversion Mapping' 
						and @density between cast(clm3_value as numeric(18,10)) and cast(clm4_value as numeric(18,10))
						and clm1_value=cast(@display_uom as VARCHAR) and clm2_value=cast(@display_uom_to as VARCHAR)
					where ISNUMERIC(clm1_value)=1 and ISNUMERIC(clm2_value)=1 and ISNUMERIC(clm3_value)=1 and ISNUMERIC(clm4_value)=1

				end
				--select @price_uom_factor,@display_uom,@display_uom_to, @density_multiplier,@density
				 if isnull(@display_uom,-1)=isnull(@display_uom_to,-1)
					set @density_multiplier=1
				

				if OBJECT_ID('tempdb..#bl_priceing_term') is not null
					INSERT INTO #deal_position_break_down
					SELECT	source_deal_header_id, source_deal_detail_id, leg, 
							0 strip_from,0 lag,1 strip_to,bl.curve_id, 0 prior_year,isnull(@factor_value, 1) * 
							CASE WHEN (@formula_currency IS NOT NULL AND @position_currency<>@formula_currency AND @display_uom<>@price_uom) THEN ISNULL(@currency_factor, 1) ELSE 1 END * 												 
							 CASE WHEN (@price_uom IS NOT NULL AND @display_uom<>@price_uom) THEN isnull(@price_uom_factor, 1) ELSE 1 END*isnull(vuc.conversion_factor,1) multiplier, 
							derived_curve_id, l.term_start, exp_date, pay_opposite, buy_sell_flag,null exp_type,null exp_value,@function_name
						,0 formula_adder ,1 formula_multiplier,null formula_complex,@no_rec_eff divider,bl.term_start,isnull(nullif(@density_multiplier,0),1) density_mult
					from #bl_priceing_term bl 
					left join source_price_curve_def spcd on bl.curve_id=spcd.source_curve_def_id
					left join rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id =@display_uom    AND
							vuc.to_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id) and isnull(spcd.display_uom_id, spcd.uom_id)<>@display_uom
					cross join #deal_legs l
					where l.[source_deal_detail_id] = @source_deal_detail_id	
			
			END


			ELSE If @function_name = 'dbo.FNAAverageMonthlyCurveValue'
			BEGIN
				EXEC spa_print @function_name, ' BLOCK'
				delete from #pv
				delete from #factor_formula_value 
				INSERT into #pv select @formula_str_o, * from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)
				select @call_from=isnull(clm2,0) from #pv
				--select @clm8 = clm8 + isnull(',' + clm9, '') from #pv
				select @clm8 = clm1 from #pv
								
				set @clm8 =  replace(@clm8, 'dbo.FNAUOMConv', 'dbo.FNAEMSUOMConv')
				set @clm8 =  replace(@clm8, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
						',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')

				
				if isnull(@clm8,'')<>''
				begin

					exec spa_print 'insert into #factor_formula_value select ', @clm8
				exec('insert into #factor_formula_value select ' + @clm8)

					select @factor_value = nullif(factor,0) from #factor_formula_value
				end
				else 
					set @factor_value=null
	
				set @currency_factor=NULL
				set @price_uom_factor=NULL
				
				SELECT @display_uom = MAX(isnull(spcd.display_uom_id, spcd.uom_id)),
					   @price_uom = max(sdd.price_uom_id),
					   @position_currency = max(spcd.source_currency_id),
					   @formula_currency = max(sdd.formula_currency_id)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id 
				where sdd.source_deal_detail_id = @source_deal_detail_id
				
				select @currency_factor = max(sc.factor) from 
					source_deal_detail sdd inner join
					source_currency sc on sc.source_currency_id = sdd.formula_currency_id
				where sdd.source_deal_detail_id = @source_deal_detail_id
					and sdd.formula_currency_id is not null
					
				set @price_uom_factor=NULL
				select  @price_uom_factor = max(vuc.conversion_factor),@display_uom_to=max(sdd.price_uom_ID)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id inner join
					rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)   AND
									vuc.to_source_uom_id = sdd.price_uom_ID
				where sdd.source_deal_detail_id = @source_deal_detail_id
					and sdd.price_uom_id IS NOT NULL 
					and isnull(spcd.display_uom_id, spcd.uom_id) <> ISNULL(sdd.price_uom_id, -1) 

				SELECT 	  @density=udddf.udf_value
				FROM user_defined_deal_detail_fields udddf 
					INNER JOIN user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
					  AND uddft.Field_id=-5619  and udddf.source_deal_detail_id = @source_deal_detail_id --'Density'
		
				SELECT 	  @density_multiplier=udddf.udf_value
					FROM user_defined_deal_detail_fields udddf 
						INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
						 AND uddft.Field_id=-5620 and udddf.source_deal_detail_id = @source_deal_detail_id --'UOM Conversion'
				
				SELECT 	  @density_multiplier=isnull(@density_multiplier,1.00)/nullif(cast(isnull(udddf.udf_value,1.00) as float),0.00)
					FROM user_defined_deal_detail_fields udddf 
						INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
						 AND uddft.Field_id=-5633 and udddf.source_deal_detail_id = @source_deal_detail_id --UOM_Conversion_div
			
				SELECT 	  @BL_pricing_curve_id=udddf.udf_value
					FROM user_defined_deal_detail_fields udddf 
						INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
						  AND uddft.Field_id=-5637  and udddf.source_deal_detail_id = @source_deal_detail_id --'CFD Index'


				--SELECT 	  @CFD_month=udddf.udf_value
				--	FROM user_defined_deal_detail_fields udddf 
				--		INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
				--		  AND uddft.Field_id=-5636 and udddf.source_deal_detail_id = @source_deal_detail_id --'CFD Month'


				if isnull(@density_multiplier,1) =1 and isnull(@density,0)<>0 and isnull(@display_uom,-1)<>isnull(@display_uom_to,-1)
				begin
					select @density_multiplier=clm5_value
					 from generic_mapping_values g 
					inner join generic_mapping_header h on g.mapping_table_id=h.mapping_table_id
						and h.mapping_name= 'Density Conversion Mapping' 
						and @density between cast(clm3_value as numeric(18,10)) and cast(clm4_value as numeric(18,10))
						and clm1_value=cast(@display_uom as VARCHAR) and clm2_value=cast(@display_uom_to as VARCHAR)
					where ISNUMERIC(clm1_value)=1 and ISNUMERIC(clm2_value)=1 and ISNUMERIC(clm3_value)=1 and ISNUMERIC(clm4_value)=1

				end
				--select @price_uom_factor,@display_uom,@display_uom_to, @density_multiplier,@density
				 if isnull(@display_uom,-1)=isnull(@display_uom_to,-1)
					set @density_multiplier=1

				if @BL_pricing_curve_id is not null
				begin
					IF object_id('tempdb..#bl_priceing_term1') IS NOT NULL
							DROP TABLE #bl_priceing_term1 
		

					SELECT a.* into #bl_priceing_term1 from dbo.FNAGetBLPricingTerm(@source_deal_detail_id,@call_from) a
					select @no_rec_eff=@@rowcount

				end 
				--select * from source_uom
				

				if OBJECT_ID('tempdb..#bl_priceing_term1') is not null
				INSERT INTO #deal_position_break_down
				SELECT	source_deal_header_id, source_deal_detail_id, leg, 
							0 strip_from,0 lag,1 strip_to,@BL_pricing_curve_id, 0 prior_year,isnull(@factor_value, 1) * 
							CASE WHEN (@formula_currency IS NOT NULL AND @position_currency<>@formula_currency AND @display_uom<>@price_uom) THEN ISNULL(@currency_factor, 1) ELSE 1 END * 												 
							 CASE WHEN (@price_uom IS NOT NULL AND @display_uom<>@price_uom) THEN isnull(@price_uom_factor, 1) ELSE 1 END*isnull(vuc.conversion_factor,1) multiplier, 
							derived_curve_id, dateadd(day,ROW_NUMBER() OVER (ORDER BY exp_date)-1, l.term_start), bl.term_start exp_date, pay_opposite, buy_sell_flag,null exp_type,null exp_value,@function_name
						,0 formula_adder ,1 formula_multiplier,@no_rec_eff divider,
						 dateadd(day,ROW_NUMBER() OVER (partition by case when @call_from=2 then bl.maturity_date else l.term_start end ORDER BY bl.term_start)-1,case when @call_from=2 then bl.maturity_date else   l.term_start end )  term_start
						,isnull(nullif(@density_multiplier,0),1) density_mult
					from #bl_priceing_term1 bl
					left join source_price_curve_def spcd on bl.curve_id=spcd.source_curve_def_id
					left join rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id =@display_uom    AND
							vuc.to_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id) and isnull(spcd.display_uom_id, spcd.uom_id)<>@display_uom
					cross join #deal_legs l
					where l.[source_deal_detail_id] = @source_deal_detail_id
					
					--select * from #deal_position_break_down
					--select * from #deal_position_break_down_final
						
								
			END			
			

			ELSE If @function_name = 'dbo.FNAWACOGPrice'
			BEGIN
				--select @function_name
				EXEC spa_print @function_name, ' BLOCK'

				if (isnull(@apply_to_all_legs,'n')='n' and @leg<>1) or @leg=1
				begin
					delete from #pv
					delete from #factor_formula_value 
					INSERT into #pv select @formula_str_o, * from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)
					select @call_from=isnull(clm2,0) from #pv
					--select @clm8 = clm8 + isnull(',' + clm9, '') from #pv
				
					set @factor_value=null
					
					set @currency_factor=NULL
					set @price_uom_factor=NULL
				
					SELECT @display_uom = MAX(isnull(spcd.display_uom_id, spcd.uom_id)),
						   @price_uom = max(sdd.price_uom_id),
						   @position_currency = max(spcd.source_currency_id),
						   @formula_currency = max(sdd.formula_currency_id)
					from 
						source_deal_detail sdd inner join
						source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id 
					where sdd.source_deal_detail_id = @source_deal_detail_id
				
					select @currency_factor = max(sc.factor) from 
						source_deal_detail sdd inner join
						source_currency sc on sc.source_currency_id = sdd.formula_currency_id
					where sdd.source_deal_detail_id = @source_deal_detail_id
						and sdd.formula_currency_id is not null
					
					set @price_uom_factor=NULL
					select  @price_uom_factor = max(vuc.conversion_factor),@display_uom_to=max(sdd.price_uom_ID)
					from 
						source_deal_detail sdd inner join
						source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id inner join
						rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)   AND
										vuc.to_source_uom_id = sdd.price_uom_ID
					where sdd.source_deal_detail_id = @source_deal_detail_id
						and sdd.price_uom_id IS NOT NULL 
						and isnull(spcd.display_uom_id, spcd.uom_id) <> ISNULL(sdd.price_uom_id, -1) 
							
					SELECT 	  @density=udddf.udf_value
					FROM user_defined_deal_detail_fields udddf 
						INNER JOIN user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
						  AND uddft.Field_id=-5619  and udddf.source_deal_detail_id = @source_deal_detail_id --'Density'
		
					SELECT 	  @density_multiplier=udddf.udf_value
						FROM user_defined_deal_detail_fields udddf 
							INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
							 AND uddft.Field_id=-5620 and udddf.source_deal_detail_id = @source_deal_detail_id --'UOM Conversion'
				
					SELECT 	  @density_multiplier=isnull(@density_multiplier,1.00)/nullif(cast(isnull(udddf.udf_value,1.00) as float),0.00)
						FROM user_defined_deal_detail_fields udddf 
							INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
							 AND uddft.Field_id=-5633 and udddf.source_deal_detail_id = @source_deal_detail_id --UOM_Conversion_div
			

					if isnull(@density_multiplier,1) =1 and isnull(@density,0)<>0 and isnull(@display_uom,-1)<>isnull(@display_uom_to,-1)
					begin
						select @density_multiplier=clm5_value
						 from generic_mapping_values g 
						inner join generic_mapping_header h on g.mapping_table_id=h.mapping_table_id
							and h.mapping_name= 'Density Conversion Mapping' 
							and @density between cast(clm3_value as numeric(18,10)) and cast(clm4_value as numeric(18,10))
							and clm1_value=cast(@display_uom as VARCHAR) and clm2_value=cast(@display_uom_to as VARCHAR)
						where ISNUMERIC(clm1_value)=1 and ISNUMERIC(clm2_value)=1 and ISNUMERIC(clm3_value)=1 and ISNUMERIC(clm4_value)=1

					end
				
					if isnull(@display_uom,-1)=isnull(@display_uom_to,-1)
					set @density_multiplier=1

				
					IF object_id('tempdb..#bl_priceing_term2') IS NOT NULL
							DROP TABLE #bl_priceing_term2 
		

					SELECT a.* into #bl_priceing_term2 from dbo.FNAGetBLPricingTermRatio(@source_deal_detail_id) a

					if OBJECT_ID('tempdb..#bl_priceing_term2') is not null
						INSERT INTO #deal_position_break_down
						SELECT	source_deal_header_id, source_deal_detail_id, leg, 
								0 strip_from,0 lag,1 strip_to,bl.curve_id, 0 prior_year,isnull(@factor_value, 1) * 
								CASE WHEN (@formula_currency IS NOT NULL AND @position_currency<>@formula_currency AND @display_uom<>@price_uom) THEN ISNULL(@currency_factor, 1) ELSE 1 END * 												 
								cast( CASE WHEN (@price_uom IS NOT NULL AND @display_uom<>@price_uom) THEN isnull(@price_uom_factor, 1) ELSE 1 END as numeric(18,10))*ISNULL(bl.ratio,1) multiplier, 
								derived_curve_id, bl.term_start, bl.term_start exp_date, pay_opposite, buy_sell_flag,null exp_type,null exp_value,@function_name
							,0 formula_adder ,1 formula_multiplier,1 divider,bl.term_start term_start
							,isnull(nullif(@density_multiplier,0),1) density_mult
						from #bl_priceing_term2 bl
						left join source_price_curve_def spcd on bl.curve_id=spcd.source_curve_def_id
						cross join #deal_legs l
						where l.[source_deal_detail_id] = @source_deal_detail_id
					
				end 
			END
			Else If @function_name IN ('dbo.FNACurveH', 'dbo.FNACurveD', 'dbo.FNACurveM', 'dbo.FNACurveQ', 'dbo.FNACurveY','dbo.FNACurve','dbo.FNACurve15')
			BEGIN
				set @complex_formula=null
				If @function_name IN('dbo.FNACurveD','dbo.FNACurve','dbo.FNACurveH','dbo.FNACurveY','dbo.FNACurve15')
				BEGIN
					--check simple function is used under other function. If simple function is used under other function then no need to breakdown position
					-- And checking support only onle level
					if exists(
						SELECT * FROM ( 
							SELECT formula_id,parent_level_func_sno
							  FROM formula_breakdown WHEre formula_id=@formula_id AND func_name=case when @function_name='dbo.FNACurve' then 'CurveM' else replace(@function_name,'dbo.FNA','') end
							) c
							INNER JOIN  formula_breakdown p ON p.formula_id=c.formula_id AND p.level_func_sno=c.parent_level_func_sno
								AND len(p.func_name)>1 --except arithmatic operator.
					)
					break
					------------------------------------------					

					delete from #pv
					delete from #factor_formula_value 
					if object_id('tempdb..#tmp_adder_multiplier') is not null
						drop table #tmp_adder_multiplier
							
					INSERT into #pv select @formula_str_o, * from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)
					--SELECT @next_str
				--	select * from #pv
					select @clm8 = clm2 from #pv
					if @clm8 is not null
					begin			
					set @clm8 =  replace(@clm8, 'dbo.FNAUOMConv', 'dbo.FNAEMSUOMConv')
					set @clm8 =  replace(@clm8, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as VARCHAR) +
							',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
							
					set @clm8 =  replace(@clm8, 'dbo.FNAFieldValue(', 'dbo.FNARFieldValue(-' + cast(@source_deal_detail_id as VARCHAR) +
							',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
							
								--select  @clm8
					--select 'insert into #factor_formula_value select ' + @clm8
					exec('insert into #factor_formula_value select ' + @clm8)

					select @factor_value = factor from #factor_formula_value
					--	select @next_str = clm1 from #PV
						select @next_str = clm1 from #PV  -- it is uncommented as error found for CurveH
					end
					
					--SELECT @next_str,@clm8,@formula_str_o,@function_part
					
				--	select @adder_multiplier,@formula_str_o,@function_part
				
					set @adder_multiplier=null
					set @adder_multiplier=replace(@formula_str_o,@function_part,'')	--adder and multiplier part of the formula only , excluding simple function
					if isnull(CHARINDEX('dbo.',@adder_multiplier,1),0)<>0 -- check existance functions in adder and multiplier part
					begin
						if isnull(CHARINDEX('dbo.FNAUDFValue(',@adder_multiplier,1),0)<>0  or  isnull(CHARINDEX('dbo.FNAFieldValue(',@adder_multiplier,1),0)<>0 -- check existance functions in adder and multiplier part
						begin --not simple formula
					if @first_time='y'
					begin
						--- ^=-
								--select @formula_str_o,@adder_multiplier
								set @adder_multiplier =  replace(@adder_multiplier, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(^' + cast(@source_deal_detail_id as varchar) +',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')					
								set @adder_multiplier =  replace(@adder_multiplier, 'dbo.FNAFieldValue(', 'dbo.FNARFieldValue(^' + cast(@source_deal_detail_id as varchar) +',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')																		
						if object_id('tempdb..#tmp_adder_multiplier') is not null
							drop table #tmp_adder_multiplier
						
						set @first_time='n'
						
					end	
						end
						else 
						begin	
							set @adder_multiplier=''
							set @complex_formula='y'
						end
					end
					
				--	SELECT @adder_multiplier
					if isnull(rtrim(@adder_multiplier),'')<>''
					begin	
						set @adder_multiplier=REPLACE(@adder_multiplier,',-',',^') --to prevent negative value (-1,-2...) from seperating -
						
						select a.[sign],rowid,item into #tmp_adder_multiplier 
							from (
								select ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) rowid,'*' [sign],* from dbo.FNASplit(@adder_multiplier,'*')
								union all 
								select ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) rowid,'+' s,* from dbo.FNASplit(@adder_multiplier,'+')
								union all 
								select ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) rowid,'-' s,* from dbo.FNASplit(@adder_multiplier,'-')
							) a where a.rowid>1  
							
							--IF EXISTS(SELECT  * FROM #tmp_adder_multiplier WHERE charindex(')',item,1)<>0 or charindex('(',item,1)<>0)
							--begin
							--	CLOSE cursor1;
							--	DEALLOCATE cursor1;
							--	CLOSE cursor0;
							--	DEALLOCATE cursor0;
							--	goto message_level
							--end
							update #tmp_adder_multiplier SET item=stuff(item,CHARINDEX('+',item,1),LEN(item),'')  WHERE item LIKE '%+%'
							update #tmp_adder_multiplier SET item=stuff(item,CHARINDEX('-',item,1),LEN(item),'')  WHERE item LIKE '%-%'
						
							--select *  from #tmp_adder_multiplier 
							
							
							SELECT @str_multiplier= ISNULL(@str_multiplier + '*', '') + item FROM #tmp_adder_multiplier WHERE [sign]='*' 
							SELECT @str_adder= replace(ISNULL(@str_adder + [sign],CASE WHEN [sign]='-' THEN '-' else '' end),[sign] + item,'') + item 
							FROM #tmp_adder_multiplier WHERE [sign]<>'*' 
							
							set @adder_multiplier=REPLACE(@adder_multiplier,',^',',-')
							set @str_adder=REPLACE(@str_adder,',^',',-')
							set @str_adder=REPLACE(@str_adder,'(^','(-')
							set @str_multiplier=REPLACE(@str_multiplier,'(^','(-')
						
						--	SELECT @str_multiplier,@str_adder						
								
					end
				END
				ELSE
					SET @factor_value = null
					
				set @currency_factor=NULL
				set @price_uom_factor=NULL
				
				SELECT @display_uom = MAX(isnull(spcd.display_uom_id, spcd.uom_id)),
					   @price_uom = max(sdd.price_uom_id),
					   @position_currency = max(spcd.source_currency_id),
					   @formula_currency = max(sdd.formula_currency_id)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id 
				where source_deal_detail_id = @source_deal_detail_id
				
				select @currency_factor = max(sc.factor) from 
					source_deal_detail sdd inner join
					source_currency sc on sc.source_currency_id = sdd.formula_currency_id
				where source_deal_detail_id = @source_deal_detail_id
					and sdd.formula_currency_id is not null
					
				set @price_uom_factor=NULL
				select  @price_uom_factor = max(vuc.conversion_factor)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id inner join
					rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)   AND
									vuc.to_source_uom_id = sdd.price_uom_ID
				where source_deal_detail_id = @source_deal_detail_id
					and sdd.price_uom_id IS NOT NULL 
					and isnull(spcd.display_uom_id, spcd.uom_id) <> ISNULL(sdd.price_uom_id, -1) 

				SET @sql_str='INSERT INTO #deal_position_break_down
					SELECT	source_deal_header_id source_deal_header_id, source_deal_detail_id source_deal_detail_id, leg leg, 
					0 strip_from, 0 lag, 1 strip_to,'+@next_str +' curve_id, 0 as prior_year, 					
					'+cast(isnull(@factor_value, 1) as VARCHAR)+' * CASE WHEN '+isnull(cast(@formula_currency as VARCHAR),'null') +' IS NOT NULL AND '+isnull(cast(@position_currency as VARCHAR),'null')+'<>'+isnull(cast(@formula_currency as VARCHAR),'null')
						+' and '+cast(@display_uom as VARCHAR)+' <>isnull(spcd.display_uom_id, spcd.uom_id) THEN '+ cast(ISNULL(@currency_factor, 1) as VARCHAR) +' ELSE 1 END  
						 * CASE WHEN ' +isnull(cast(@price_uom as VARCHAR),'null')+' IS NOT NULL AND '+cast(@display_uom as VARCHAR)+'<>isnull(spcd.display_uom_id, spcd.uom_id)
						 THEN '+cast(ISNULL(@price_uom_factor , 1) as VARCHAR)+' ELSE 1 END multiplier, 
					derived_curve_id, term_start, exp_date, pay_opposite, buy_sell_flag, NULL exp_type,NULL exp_value,'''+@function_name+''','
					+isnull(@str_adder,'0') +' formula_adder,'
					+isnull(@str_multiplier,'1') +' formula_multiplier,'''+isnull(@complex_formula,'n') +''' complex_formula,1 divider,null pricing_term,null density_mult
					from #deal_legs left join
						source_price_curve_def spcd on spcd.source_curve_Def_id = '+@next_str+'
					where formula = '''+@formula_str_o +''' and source_deal_detail_id = '+cast(@source_deal_detail_id as VARCHAR)
					
				EXEC spa_print @sql_str
				exec(@sql_str)	
			END

			Else If @function_name IN ('dbo.FNAGetCurveValue')
			BEGIN
				--select @function_name
				set @complex_formula=null
				if object_id('tempdb..#tmp_adder_multiplier') is not null
							drop table #tmp_adder_multiplier

					--check simple function is used under other function. If simple function is used under other function then no need to breakdown position
					-- And checking support only onle level
				if exists(
						SELECT * FROM ( 
							SELECT formula_id,parent_level_func_sno
							  FROM formula_breakdown WHEre formula_id=@formula_id AND func_name=case when @function_name='dbo.FNACurve' then 'CurveM' else replace(@function_name,'dbo.FNA','') end
							) c
							INNER JOIN  formula_breakdown p ON p.formula_id=c.formula_id AND p.level_func_sno=c.parent_level_func_sno
								AND len(p.func_name)>1 --except arithmatic operator.
					)
					break
					------------------------------------------					
					--select @formula_str_o,@next_str, * from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)
				delete from #pv
				delete from #factor_formula_value 
				if object_id('tempdb..#tmp_adder_multiplier1') is not null
					drop table #tmp_adder_multiplier1
					
			-- select @formula_str_o, @next_str,* from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)	
			--	If @function_name IN('dbo.FNAGetCurveValue'
				--	select @next_str	
				INSERT into #pv select @formula_str_o, * from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)
				--SELECT @next_str
			--	select * from #pv
				
				select @func_udf_curve=clm1 from #pv

				if  charindex('dbo.FNAUDFValue(', @func_udf_curve, 1) is not null
				begin
						
					set @func_udf_curve =  replace(@func_udf_curve, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as varchar) +
							',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
						
				--	select  @func_udf_curve
					--select 'insert into #factor_formula_value select ' + @clm8
					exec('insert into #factor_formula_value select ' + @func_udf_curve)

					IF NOT EXISTS(SELECT 1 FROM #factor_formula_value WHERE factor <> 0 ) 
					BEGIN
						set @func_udf_curve =  replace(@func_udf_curve, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(' + cast(@source_deal_header_id as varchar) +
							',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
						
						exec('insert into #factor_formula_value select ' + @func_udf_curve)
					END

					select @next_str = factor from #factor_formula_value
					truncate table #factor_formula_value

				end
				else
					select @next_str = clm1 from #PV

					
			--select @next_str
				set  @factor_value=null
				select @clm8 = clm2 from #pv
				if @clm8 is not null
				begin			
					set @clm8 =  replace(@clm8, 'dbo.FNAUOMConv', 'dbo.FNAEMSUOMConv')
					set @clm8 =  replace(@clm8, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as varchar) +
							',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
							
					set @clm8 =  replace(@clm8, 'dbo.FNAFieldValue(', 'dbo.FNARFieldValue(-' + cast(@source_deal_detail_id as varchar) +
							',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
							
					--select  @clm8
					--select 'insert into #factor_formula_value select ' + @clm8
					exec('insert into #factor_formula_value select ' + @clm8)

					select @factor_value = factor from #factor_formula_value
				end					

					--SELECT @next_str,@clm8,@formula_str_o,@function_part
					
				--	select @adder_multiplier,@formula_str_o,@function_part
				
				set @adder_multiplier=null
				SET @str_adder = null
				/*
				set @adder_multiplier=replace(@formula_str_o,@function_part,'')	--adder and multiplier part of the formula only , excluding simple function
				if isnull(CHARINDEX('dbo.',@adder_multiplier,1),0)<>0 -- check existance functions in adder and multiplier part
				begin
					if isnull(CHARINDEX('dbo.FNAUDFValue(',@adder_multiplier,1),0)<>0  or  isnull(CHARINDEX('dbo.FNAFieldValue(',@adder_multiplier,1),0)<>0 -- check existance functions in adder and multiplier part
					begin --not simple formula
					if @first_time='y'
					begin
						--- ^=-
								--select @formula_str_o,@adder_multiplier
						set @adder_multiplier =  replace(@adder_multiplier, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(^' + cast(@source_deal_detail_id as varchar) +
													',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')					
						set @adder_multiplier =  replace(@adder_multiplier, 'dbo.FNAFieldValue(', 'dbo.FNARFieldValue(^' + cast(@source_deal_detail_id as varchar) +
													',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')																		
						
						if object_id('tempdb..#tmp_adder_multiplier1') is not null
							drop table #tmp_adder_multiplier1
						
						set @first_time='n'
						
					end	
					end
					else 
					begin	
						set @adder_multiplier=''
						set @complex_formula='y'
					end
				end
					
			--	SELECT @adder_multiplier
				if isnull(rtrim(@adder_multiplier),'')<>''
				begin	
					set @adder_multiplier=REPLACE(@adder_multiplier,',-',',^') --to prevent negative value (-1,-2...) from seperating -
						
					select a.[sign],rowid,item into #tmp_adder_multiplier1 
						from (
							select ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) rowid,'*' [sign],* from dbo.FNASplit(@adder_multiplier,'*')
							union all 
							select ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) rowid,'+' s,* from dbo.FNASplit(@adder_multiplier,'+')
							union all 
							select ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) rowid,'-' s,* from dbo.FNASplit(@adder_multiplier,'-')
						) a where a.rowid>1  
					update #tmp_adder_multiplier1 SET item=stuff(item,CHARINDEX('+',item,1),LEN(item),'')  WHERE item LIKE '%+%'
					update #tmp_adder_multiplier1 SET item=stuff(item,CHARINDEX('-',item,1),LEN(item),'')  WHERE item LIKE '%-%'
						
					SELECT @str_multiplier= ISNULL(@str_multiplier + '*', '') + item FROM #tmp_adder_multiplier1 WHERE [sign]='*' 
					SELECT @str_adder= replace(ISNULL(@str_adder + [sign],CASE WHEN [sign]='-' THEN '-' else '' end),[sign] + item,'') + item 
					FROM #tmp_adder_multiplier1 WHERE [sign]<>'*' 
							
					set @adder_multiplier=REPLACE(@adder_multiplier,',^',',-')
					set @str_adder=REPLACE(@str_adder,',^',',-')
					set @str_adder=REPLACE(@str_adder,'(^','(-')
					set @str_multiplier=REPLACE(@str_multiplier,'(^','(-')
						
					--	SELECT @str_multiplier,@str_adder						
								
				end
				*/
				
				
					
				set @currency_factor=NULL
				set @price_uom_factor=NULL
				
				SELECT @display_uom = MAX(isnull(spcd.display_uom_id, spcd.uom_id)),
					   @price_uom = max(sdd.price_uom_id),
					   @position_currency = max(spcd.source_currency_id),
					   @formula_currency = max(sdd.formula_currency_id)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id 
				where source_deal_detail_id = @source_deal_detail_id
				
				select @currency_factor = max(sc.factor) from 
					source_deal_detail sdd inner join
					source_currency sc on sc.source_currency_id = sdd.formula_currency_id
				where source_deal_detail_id = @source_deal_detail_id
					and sdd.formula_currency_id is not null
					
				set @price_uom_factor=NULL
				select  @price_uom_factor = max(vuc.conversion_factor)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id inner join
					rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)   AND
									vuc.to_source_uom_id = sdd.price_uom_ID
				where source_deal_detail_id = @source_deal_detail_id
					and sdd.price_uom_id IS NOT NULL 
					and isnull(spcd.display_uom_id, spcd.uom_id) <> ISNULL(sdd.price_uom_id, -1) 

				SET @sql_str='INSERT INTO #deal_position_break_down
					SELECT	source_deal_header_id source_deal_header_id, source_deal_detail_id source_deal_detail_id, leg leg, 
					0 strip_from, 0 lag, 1 strip_to,'+@next_str +' curve_id, 0 as prior_year, 					
					'+cast(isnull(@factor_value, 1) as varchar)+' * CASE WHEN '+isnull(cast(@formula_currency as varchar),'null') +' IS NOT NULL AND '+isnull(cast(@position_currency as varchar),'null')+'<>'+isnull(cast(@formula_currency as varchar),'null')
						+' and '+cast(@display_uom as varchar)+' <>isnull(spcd.display_uom_id, spcd.uom_id) THEN '+ cast(ISNULL(@currency_factor, 1) as varchar) +' ELSE 1 END  
						 * CASE WHEN ' +isnull(cast(@price_uom as varchar),'null')+' IS NOT NULL AND '+cast(@display_uom as varchar)+'<>isnull(spcd.display_uom_id, spcd.uom_id)
						 THEN '+cast(ISNULL(@price_uom_factor , 1) as varchar)+' ELSE 1 END multiplier, 
					derived_curve_id, term_start, exp_date, pay_opposite, buy_sell_flag, NULL exp_type,NULL exp_value,'''+@function_name+''','
					+isnull(@str_adder,'0') +' formula_adder,'
					+isnull(@str_multiplier,'1') +' formula_multiplier,'''+isnull(@complex_formula,'n') +''' complex_formula,1 divider,null pricing_term,null density_mult
					from #deal_legs left join
						source_price_curve_def spcd on spcd.source_curve_Def_id = '+@next_str+'
					where formula = '''+@formula_str_o +''' and source_deal_detail_id = '+cast(@source_deal_detail_id as varchar)
					
				EXEC spa_print @sql_str
				exec(@sql_str)	
				
			END
			Else If @function_name IN ('dbo.FNAAvg')
			BEGIN

				DECLARE @curve_id1 INT, @curve_id2 INT
				SELECT @curve_id1 = cast(clm1 AS INT), @curve_id2 = cast(clm2 AS INT)
				FROM dbo.SplitAndTransposeCommaSeperatedValues(@next_str)

				INSERT INTO #deal_position_break_down				
				SELECT	source_deal_header_id source_deal_header_id, source_deal_detail_id source_deal_detail_id, leg leg, 
						0 strip_from, 0 lag, 1 strip_to, @curve_id1 curve_id, 0 as prior_year, .5 multiplier,
						derived_curve_id, term_start, exp_date, pay_opposite, buy_sell_flag, NULL exp_type,NULL exp_value,@function_name
						,0 formula_adder ,1 formula_multiplier	,null complex_formula,1 divider,null pricing_term,null density_mult
				from #deal_legs 
				where formula = @formula_str_o and source_deal_detail_id = @source_deal_detail_id

				INSERT INTO #deal_position_break_down				
				SELECT	source_deal_header_id source_deal_header_id, source_deal_detail_id source_deal_detail_id, leg leg, 
						0 strip_from, 0 lag, 1 strip_to, @curve_id2 curve_id, 0 as prior_year, .5 multiplier,
						derived_curve_id, term_start, exp_date, pay_opposite, buy_sell_flag, NULL exp_type,NULL exp_value,@function_name	
						,0 formula_adder ,1 formula_multiplier	,null complex_formula,1 divider,null pricing_term,null density_mult	
				from #deal_legs 
				where formula = @formula_str_o and source_deal_detail_id = @source_deal_detail_id

			END
			Else If @function_name IN ('dbo.FNAContractPriceValue')
			BEGIN
				--select @function_name
				set @complex_formula=null
				if object_id('tempdb..#tmp_adder_multiplier') is not null
					drop table #tmp_adder_multiplier

				
					------------------------------------------					
					--select @formula_str_o,@next_str, * from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)
				delete from #pv
				delete from #factor_formula_value 
				if object_id('tempdb..#tmp_adder_multiplier1') is not null
					drop table #tmp_adder_multiplier1
					
			-- select @formula_str_o, @next_str,* from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)	
			--	If @function_name IN('dbo.FNAGetCurveValue'
				--	select @next_str	
				INSERT into #pv select @formula_str_o, * from dbo.SplitAndTransposeCommaSeperatedValues(@next_str)
				--SELECT @next_str
			--	select * from #pv
				
				select @func_udf_curve=clm1 from #pv

				if  charindex('dbo.FNAUDFValue(', @func_udf_curve, 1) is not null
				begin
						
					set @func_udf_curve =  replace(@func_udf_curve, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as varchar) +
							',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
						
				--	select  @func_udf_curve
					--select 'insert into #factor_formula_value select ' + @clm8
					exec('insert into #factor_formula_value select ' + @func_udf_curve)

					IF NOT EXISTS(SELECT 1 FROM #factor_formula_value WHERE factor <> 0 ) 
					BEGIN
						set @func_udf_curve =  replace(@func_udf_curve, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(' + cast(@source_deal_header_id as varchar) +
							',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
						
						exec('insert into #factor_formula_value select ' + @func_udf_curve)
					END

					select @next_str = factor from #factor_formula_value
					truncate table #factor_formula_value

				end
				else
					select @next_str = clm1 from #PV

			--select * from #pv
			--select @next_str
				set  @factor_value=null
			--	select @clm8 = clm2 from #pv
				--if @clm8 is not null
				--begin			
				--	set @clm8 =  replace(@clm8, 'dbo.FNAUOMConv', 'dbo.FNAEMSUOMConv')
				--	set @clm8 =  replace(@clm8, 'dbo.FNAUDFValue(', 'dbo.FNARUDFValue(-' + cast(@source_deal_detail_id as varchar) +
				--			',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
							
				--	set @clm8 =  replace(@clm8, 'dbo.FNAFieldValue(', 'dbo.FNARFieldValue(-' + cast(@source_deal_detail_id as varchar) +
				--			',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,')
							
				--	--select  @clm8
				--	--select 'insert into #factor_formula_value select ' + @clm8
				--	exec('insert into #factor_formula_value select ' + @clm8)

				--	select @factor_value = factor from #factor_formula_value
				--end					

				--	--SELECT @next_str,@clm8,@formula_str_o,@function_part
					
				----	select @adder_multiplier,@formula_str_o,@function_part
				
				set @adder_multiplier=null
				SET @str_adder = null
					
				set @currency_factor=NULL
				set @price_uom_factor=NULL
				
				SELECT @display_uom = MAX(isnull(spcd.display_uom_id, spcd.uom_id)),
					   @price_uom = max(sdd.price_uom_id),
					   @position_currency = max(spcd.source_currency_id),
					   @formula_currency = max(sdd.formula_currency_id)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id 
				where source_deal_detail_id = @source_deal_detail_id
				
				select @currency_factor = max(sc.factor) from 
					source_deal_detail sdd inner join
					source_currency sc on sc.source_currency_id = sdd.formula_currency_id
				where source_deal_detail_id = @source_deal_detail_id
					and sdd.formula_currency_id is not null
					
				set @price_uom_factor=NULL
				select  @price_uom_factor = max(vuc.conversion_factor)
				from 
					source_deal_detail sdd inner join
					source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id inner join
					rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)   AND
									vuc.to_source_uom_id = sdd.price_uom_ID
				where source_deal_detail_id = @source_deal_detail_id
					and sdd.price_uom_id IS NOT NULL 
					and isnull(spcd.display_uom_id, spcd.uom_id) <> ISNULL(sdd.price_uom_id, -1) 

				SET @sql_str='INSERT INTO #deal_position_break_down
					SELECT	source_deal_header_id source_deal_header_id, source_deal_detail_id source_deal_detail_id, leg leg, 
					0 strip_from, 0 lag, 1 strip_to,'+@next_str +' curve_id, 0 as prior_year, 					
					'+cast(isnull(@factor_value, 1) as varchar)+' * CASE WHEN '+isnull(cast(@formula_currency as varchar),'null') +' IS NOT NULL AND '+isnull(cast(@position_currency as varchar),'null')+'<>'+isnull(cast(@formula_currency as varchar),'null')
						+' and '+cast(@display_uom as varchar)+' <>isnull(spcd.display_uom_id, spcd.uom_id) THEN '+ cast(ISNULL(@currency_factor, 1) as varchar) +' ELSE 1 END  
						 * CASE WHEN ' +isnull(cast(@price_uom as varchar),'null')+' IS NOT NULL AND '+cast(@display_uom as varchar)+'<>isnull(spcd.display_uom_id, spcd.uom_id)
						 THEN '+cast(ISNULL(@price_uom_factor , 1) as varchar)+' ELSE 1 END multiplier, 
					derived_curve_id, term_start, exp_date, pay_opposite, buy_sell_flag, NULL exp_type,NULL exp_value,'''+@function_name+''','
					+isnull(@str_adder,'0') +' formula_adder,'
					+isnull(@str_multiplier,'1') +' formula_multiplier,'''+isnull(@complex_formula,'n') +''' complex_formula,1 divider,null pricing_term,null density_mult
					from #deal_legs left join
						source_price_curve_def spcd on spcd.source_curve_Def_id = '+@next_str+'
					where formula = '''+@formula_str_o +''' and source_deal_detail_id = '+cast(@source_deal_detail_id as varchar)
					
				EXEC spa_print @sql_str
				exec(@sql_str)	
					
			END


			--Else If @function_name IN ('dbo.FNAContractPriceValue')
			--BEGIN

			--	DECLARE @curve_id0 INT
			--	SELECT @curve_id0 = cast(clm1 AS INT)
			--	FROM dbo.SplitAndTransposeCommaSeperatedValues(@next_str)

			--	INSERT INTO #deal_position_break_down				
			--	SELECT	source_deal_header_id source_deal_header_id, source_deal_detail_id source_deal_detail_id, leg leg, 
			--			0 strip_from, 0 lag, 1 strip_to, @curve_id0 curve_id, 0 as prior_year, 1 multiplier,
			--			derived_curve_id, term_start, exp_date, pay_opposite, buy_sell_flag, NULL exp_type,NULL exp_value,@function_name
			--			,0 formula_adder ,1 formula_multiplier	,null complex_formula,1 divider,null pricing_term,null density_mult
			--	from #deal_legs 
			--	where formula = @formula_str_o and source_deal_detail_id = @source_deal_detail_id

			--END
		
			set @formula_str = substring(@formula_str, @index2+1, len(@formula_str) - @index2)
		--print @formula_str

		END

		FETCH NEXT FROM cursor1 
		INTO @function_name, @function_name_par;		

	END
	CLOSE cursor1;
	DEALLOCATE cursor1;

	FETCH NEXT FROM cursor10 INTO @deal_header_id, @source_deal_detail_id, @leg, @formula_str,@formula_id,@apply_to_all_legs;

END
CLOSE cursor10;
DEALLOCATE cursor10;

----jump to this level for  SIMPLE FORMULA WHERE formula_curve_id is defined but not formuala
skip_loop:


		
----THIS IS A LOGIC FOR SIMPLE FORMULA WHERE formula_curve_id is defined but not formuala

INSERT INTO #deal_position_break_down	
select sdd.source_deal_header_id, min(sdd.source_deal_detail_id) source_deal_detail_id, sdd.leg,
	0 strip_from, 0 lag, 1 strip_to, sdd.formula_curve_id curve_id, 0 as prior_year, 1 multiplier,
	null derived_curve_id, sdd.term_start, max(sdd.contract_expiration_date) exp_date, max(sdd.pay_opposite) 
	,max(sdd.buy_sell_flag) buy_sell_flag, NULL exp_type,NULL exp_value,NULL
	,0 formula_adder ,1 formula_multiplier	,null complex_formula,1 divider,null pricing_term,null density_mult			
from	#deals d INNER JOIN	source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id 
	left join deal_price_type dpt on sdd.source_deal_detail_id=dpt.source_deal_detail_id 
	left join #deal_legs dl on dl.source_deal_detail_id=sdd.source_deal_detail_id
where	sdd.formula_id is null and sdd.formula_curve_id is not null
	and dpt.source_deal_detail_id is null
	and dl.source_deal_detail_id is null
group by sdd.source_deal_header_id, sdd.leg, sdd.term_start, sdd.formula_curve_id 		
		
				
DECLARE @pricing_idex INT,@pricing_start DATETIME,@pricing_end DATETIME,@adder FLOAT,@multiplier FLOAT,@holiday_calendar INT,@pricing_period INT,@include_weekends CHAR(1)

SELECT  @holiday_calendar = calendar_desc   FROM default_holiday_calendar

CREATE TABLE #price_dates 
(
	source_deal_detail_id INT,
	[curve_id] int,
	[term_start] datetime,
	maturity_date datetime
)

CREATE TABLE #term_breakdown (term_date DATETIME)
--## New Logic to breakdown for the formula defined in deal_price_deemed
IF EXISTS(SELECT top 1 (d.source_deal_header_id) FROM #deals d INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id INNER JOIN deal_price_deemed dpd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id WHERE sdd.pricing_type2=103602)
BEGIN
	DECLARE cur1 CURSOR FOR
	SELECT sdd.source_deal_detail_id,dpd.pricing_index,COALESCE(dpd.pricing_start,hg.mn_exp_date,sdd.term_start),COALESCE(dpd.pricing_end,hg.mx_exp_date,sdd.term_end),dpd.adder,dpd.multiplier,dpd.pricing_period,dpd.include_weekends
	FROM #deals d INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id INNER JOIN deal_price_deemed dpd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id 
	OUTER APPLY(SELECT MAX(exp_date) mx_exp_date,MIN(exp_date) mn_exp_date  FROM source_price_curve_def spcd  
					INNER JOIN holiday_group hg ON hg.hol_group_value_id = spcd.exp_calendar_id and hg.hol_date>= sdd.term_start AND hg.hol_date_to>= sdd.term_end
					where spcd.source_curve_def_id = dpd.pricing_index
	) hg  WHERE sdd.pricing_type2=103602
	OPEN cur1;
	FETCH NEXT FROM cur1 INTO @source_deal_detail_id, @pricing_idex,@pricing_start,@pricing_end,@adder,@multiplier,@pricing_period,@include_weekends
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DELETE FROM #term_breakdown
		IF @pricing_period = 1610
		BEGIN
			INSERT INTO #price_dates(source_deal_detail_id,curve_id,term_start)
			SELECT @source_deal_detail_id,@pricing_idex,term_start
			FROM source_deal_detail WHERE source_deal_detail_id=@source_deal_detail_id
		END
		ELSE
		BEGIN
			IF @include_weekends = 'y'
			BEGIN
			;WITH CTE AS (
				SELECT CAST(DATEADD(DAY,1,DATEADD(DAY,-1,@pricing_start)) AS DATETIME) bl_date
				UNION ALL
				SELECT DATEADD(DAY,1,bl_date) FROM CTE WHERE DATEADD(DAY,1,bl_date) <= @pricing_end )
				
				INSERT INTO #term_breakdown
				SELECT bl_date FROM CTE
			END
			ELSE
			BEGIN
				;WITH CTE AS (
				SELECT CAST(dbo.FNAGetBusinessDay ('n',DATEADD(DAY,-1,@pricing_start),@holiday_calendar) AS DATETIME) bl_date
				UNION ALL
				SELECT CAST(dbo.FNAGetBusinessDay ('n',bl_date,@holiday_calendar) AS DATETIME) FROM CTE WHERE CAST(dbo.FNAGetBusinessDay('n',bl_date,@holiday_calendar) AS DATETIME) <= @pricing_end)
			
				INSERT INTO #term_breakdown
				SELECT bl_date FROM CTE

			END

			IF @pricing_period = 1609
			BEGIN
				INSERT INTO #price_dates(source_deal_detail_id,curve_id,term_start)
				SELECT @source_deal_detail_id,@pricing_idex,term_date
				FROM #term_breakdown
				cross apply
				( select exp_calendar_id from   source_price_curve_def where source_curve_def_id=@pricing_idex ) spcd 
				left JOIN holiday_group hg ON hg.hol_group_value_id = spcd.exp_calendar_id and hg.exp_date  =term_date
					where spcd.exp_calendar_id is NOT NULL
			END
			ELSE --IF @pricing_period = 1608
			BEGIN
				
				INSERT INTO #price_dates(source_deal_detail_id,curve_id,term_start)
				SELECT @source_deal_detail_id,@pricing_idex,term_date
				FROM #term_breakdown
				END


		END
	FETCH NEXT FROM cur1 INTO @source_deal_detail_id, @pricing_idex,@pricing_start,@pricing_end,@adder,@multiplier,@pricing_period,@include_weekends
	END
	CLOSE cur1
	DEALLOCATE cur1
END


INSERT INTO #deal_position_break_down([source_deal_header_id],[source_deal_detail_id],leg,strip_from,lag,strip_to,curve_id,prior_year,multiplier,[term_start],[exp_date],[pay_opposite],[buy_sell_flag],formula_adder,formula_multiplier,divider,pricing_term)
SELECT	
	d.source_deal_header_id, 
	sdd.source_deal_detail_id, 
	leg, 
	0 strip_from,0 lag,
	1 strip_to,
	dpd.pricing_index, 
	0 prior_year,
	CAST(1.00/dpd1.no_of_days AS FLOAT) factor, 
	sdd.term_start, pd.term_start exp_date, sdd.pay_opposite, sdd.buy_sell_flag
	,0 formula_adder ,1 formula_multiplier,1 divider,pd.term_start term_start				
FROM #deals d 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id 
	INNER JOIN deal_price_deemed dpd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
	INNER JOIN #price_dates pd ON pd.source_deal_detail_id = sdd.source_deal_detail_id AND pd.curve_id = dpd.pricing_index
	CROSS APPLY(SELECT COUNT(1) no_of_days FROM #price_dates WHERE pd.source_deal_detail_id = sdd.source_deal_detail_id AND pd.curve_id = dpd.pricing_index) dpd1



		
----logic when pricing type is Index Pricing - 103601

select distinct sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.leg,
	 sdd.term_start,  sdd.pay_opposite 
	,sdd.buy_sell_flag,sdh.deal_date
into #tmp_sdd_FNAGetFinancialTerm -- select * from #tmp_sdd_FNAGetFinancialTerm
FROM #deals d 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id 
	inner join dbo.source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id 
	cross apply
	( 
		select top(1) source_deal_detail_id from deal_price_type where  source_deal_detail_id=sdd.source_deal_detail_id
	) ex
where ex.source_deal_detail_id is not null



/* Copy here all the code of FNAGetFinancialTerm as it was too slow while the function is called for whole portfolio.
 This code block can be commented if use FNAGetFinancialTerm and uncomment below code after this block.
 */


------------------------------------------------------------------------------------------------------------------
-- Start Function (FNAGetFinancialTerm) code 


declare @time_zone_id int
declare @event_date datetime
declare @deal_date datetime

SELECT @time_zone_id=var_value   --26
  FROM dbo.adiha_default_codes_values(nolock)
  WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1


select term.pricing_index
	,isnull(term.fin_term_start,sdd.term_start) fin_term_start
	,isnull(term.fin_term_end,sdd.term_end) fin_term_end
	,coalesce(term.multiplier,cast(term.volume as float)/sdd.deal_volume,1) multiplier
	,coalesce(term.price_multiplier,1) price_multiplier
	,term.adder
	,term.volume
	,term.uom
	,isnull(exp_max.min_exp_date,sdd.term_start) min_exp_date
	,isnull(exp_max.max_exp_date,sdd.term_end) max_exp_date	
	,spcd.exp_calendar_id
	,spcd.holiday_calendar_id
	,term.pricing_period
	,isnull(term.include_weekends,'n') include_weekends
	,term.expiration_calendar 
	,isnull(tz.weekend_first_day,7) weekend_first_day
	,isnull(tz.weekend_second_day,1) weekend_second_day
	,term.event_date,term.include_event_date
	,term.skip_date
	,skip_granularity,skip_days,quotes_after,term.BOLMO_pricing
	,spcd.hourly_volume_allocation  
	,min(isnull(term.fin_term_start,sdd.term_start)) over(partition by pricing_index) fin_term_min
	,max(isnull(term.fin_term_end,sdd.term_end)) over(partition by pricing_index) fin_term_max
	,gft.deal_date --****
	,dpt.source_deal_detail_id 
into #TempTable
from source_deal_detail sdd 
	inner join deal_price_type dpt on sdd.source_deal_detail_id=dpt.source_deal_detail_id
	inner join #tmp_sdd_FNAGetFinancialTerm gft on gft.source_deal_detail_id=dpt.source_deal_detail_id  --****
		and dpt.price_type_id not in (103607,103604,103600)
	outer apply
	(
		select dateadd(mm, r.pricing_term, sdd.term_start) fin_term_start
			,CASE WHEN isnull(dpd.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE dateadd(mm, r.pricing_term+1, sdd.term_start)-1 END  fin_term_end
			,r.multiplier,dpd.volume,dpd.multiplier price_multiplier,dpd.adder,dpd.uom
			,dpd.pricing_period,dpd.include_weekends,pps.expiration_calendar 
			,dpd.pricing_index,null event_date,'y' include_event_date,null skip_date
			,null skip_granularity,null skip_days,null quotes_after,dpd.BOLMO_pricing
		from  deal_price_deemed dpd
			inner join [dbo].[pricing_period_setup] pps on pps.pricing_period_value_id=dpd.pricing_period
				and dpd.deal_price_type_id=dpt.deal_price_type_id
			inner join [dbo].position_break_down_rule r on r.strip_from=pps.average_period
				and r.lag=pps.skip_period 
				AND r.strip_to=pps.delivery_period
				AND month(sdd.term_start) = r.phy_month	
				and pps.period_type='m'
		union all
		select dpd.pricing_start fin_term_start
			,CASE WHEN isnull(dpd.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE isnull(dpd.pricing_end,dpd.pricing_start) END  fin_term_end
			,1 multiplier,dpd.volume,dpd.multiplier price_multiplier,dpd.adder,dpd.uom
			,dpd.pricing_period,isnull(dpd.include_weekends,'n') include_weekends,pps.expiration_calendar 
			,dpd.pricing_index,null event_date,'y' include_event_date,null skip_date
			,null skip_granularity,null skip_days,null quotes_after,dpd.BOLMO_pricing
		from  deal_price_deemed dpd
			inner join [dbo].[pricing_period_setup] pps on pps.pricing_period_value_id=dpd.pricing_period
				and dpd.deal_price_type_id=dpt.deal_price_type_id
				and pps.period_type='d'
		union all
		select isnull(dpd.pricing_start,sdd.term_start) fin_term_start
			,CASE WHEN isnull(dpd.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE isnull(dpd.pricing_end,sdd.term_end) END fin_term_end
			,1 multiplier,dpd.volume,dpd.multiplier price_multiplier,dpd.adder,dpd.uom
			,dpd.pricing_period,isnull(dpd.include_weekends,'n') include_weekends,0 expiration_calendar 
			,dpd.pricing_index,null event_date,'y' include_event_date,null skip_date
			,null skip_granularity,null skip_days,null quotes_after,dpd.BOLMO_pricing
		from  deal_price_deemed dpd 
		where dpd.pricing_period is null and nullif(dpd.pricing_dates,'') is null AND dpd.deal_price_type_id=dpt.deal_price_type_id

		union all
		select dt.item fin_term_start
			,CASE WHEN isnull(dpd.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE dt.item END fin_term_end
			,1 multiplier,dpd.volume,dpd.multiplier price_multiplier,dpd.adder,dpd.uom
			,dpd.pricing_period,isnull(dpd.include_weekends,'n') include_weekends,null expiration_calendar 
			,dpd.pricing_index,null event_date,'y' include_event_date,null skip_date
			,null skip_granularity,null skip_days,null quotes_after,dpd.BOLMO_pricing
		from  deal_price_deemed dpd
			cross apply dbo.FNASplit(dpd.pricing_dates,';') dt
		where nullif(dpd.pricing_dates,'') is not null  AND dpd.deal_price_type_id=dpt.deal_price_type_id
		union all
		select 
			dbo.FNAGetBusinessDayN('p',isnull(@event_date,dpce.event_date),spcd1.holiday_calendar_id,isnull(dpce.quotes_before,0)-case when isnull(dpce.include_event_date,'n')='n' then 0 else 1 end) fin_term_start,
			CASE WHEN isnull(dpce.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE case when dpce.skip_granularity in (990,980) then
				case when dpce.include_holidays='y' then
					dbo.FNAGetBusinessDayN('n',dbo.FNAGetSkippedDate(isnull(@event_date,dpce.event_date),dpce.skip_granularity,isnull(dpce.skip_days,0)),spcd1.holiday_calendar_id,isnull(dpce.quotes_after,0))
				else
					dbo.FNAGetBusinessDayN('n',dateadd(day,-1,dbo.FNAGetSkippedDate(isnull(@event_date,dpce.event_date),dpce.skip_granularity,isnull(dpce.skip_days,0))),spcd1.holiday_calendar_id,isnull(dpce.quotes_after,0)+1) 
				end 		
			else
				case when dpce.include_holidays='y' then
					dbo.FNAGetBusinessDayN('n',isnull(@event_date,dpce.event_date),spcd1.holiday_calendar_id,isnull(dpce.skip_days,0)+isnull(dpce.quotes_after,0)-case when isnull(dpce.include_event_date,'n')='n' then 0 else 1 end)
				else
					dbo.FNAGetBusinessDayN('n',isnull(@event_date,dpce.event_date)-1,spcd1.holiday_calendar_id,isnull(dpce.skip_days,0)+isnull(dpce.quotes_after,0)-case when isnull(dpce.include_event_date,'n')='n' then 0 else 1 end+1) end 
			end END fin_term_end
			,1 multiplier,dpce.volume,dpce.multiplier price_multiplier,dpce.adder,dpce.uom
			,null pricing_period,isnull(dpce.include_holidays,'n') include_weekends,0 expiration_calendar 
			,dpce.pricing_index,isnull(@event_date,dpce.event_date) event_date,isnull(dpce.include_event_date,'n') include_event_date
			,case when dpce.skip_granularity in (990,980) then
				dateadd(day,-1,dbo.FNAGetSkippedDate(isnull(@event_date,dpce.event_date),dpce.skip_granularity,isnull(dpce.skip_days,0)))
			else
				dbo.FNAGetBusinessDayN('n',dpce.event_date,spcd1.holiday_calendar_id,isnull(dpce.skip_days,0)-case when isnull(dpce.include_event_date,'n')='n' then 0 else 1 end) 
			end skip_date
			,dpce.skip_granularity,isnull(dpce.skip_days,0) skip_days
			,isnull(dpce.quotes_after,0) quotes_after,dpce.BOLMO_pricing
		from  deal_price_custom_event dpce
			left join source_price_curve_def spcd1 on spcd1.source_curve_def_id=dpce.pricing_index
		where dpce.deal_price_type_id=dpt.deal_price_type_id
		union all
		select 
			dbo.FNAGetBusinessDayN('p',isnull(@event_date,dpse.event_date),spcd2.holiday_calendar_id,cast(isnull(gmv.clm4_value,0) as int)-case when isnull(gmv.clm6_value,0)=0 then 0 else 1 end) fin_term_start,
			CASE WHEN isnull(dpse.BOLMO_pricing,'n')='y' THEN  sdd.term_end ELSE case when cast(gmv.clm8_value as int) in (990,980) then
				case when isnull(gmv.clm7_value,0)=1 then
					dbo.FNAGetBusinessDayN('n',dbo.FNAGetSkippedDate(isnull(@event_date,dpse.event_date),gmv.clm8_value,isnull(gmv.clm3_value,1)),spcd2.holiday_calendar_id,cast(isnull(gmv.clm5_value,0) as int))
				else 
					dbo.FNAGetBusinessDayN('n',dateadd(day,-1,dbo.FNAGetSkippedDate(isnull(@event_date,dpse.event_date),gmv.clm8_value,isnull(gmv.clm3_value,1))),spcd2.holiday_calendar_id,cast(isnull(gmv.clm5_value,0) as int)+1)
				end 
			else
				case when isnull(gmv.clm7_value,0)=1 then
					dbo.FNAGetBusinessDayN('n',isnull(@event_date,dpse.event_date),spcd2.holiday_calendar_id,cast(isnull(gmv.clm3_value,0) as int) +cast(isnull(gmv.clm5_value,0) as int)-case when isnull(gmv.clm6_value,0)=0 then 0 else 1 end)
				else 
					dbo.FNAGetBusinessDayN('n',isnull(@event_date,dpse.event_date)-1,spcd2.holiday_calendar_id,cast(isnull(gmv.clm3_value,0) as int) +cast(isnull(gmv.clm5_value,0) as int)-case when isnull(gmv.clm6_value,0)=0 then 0 else 1 end+1)
				end 
			end END fin_term_end
			,1 multiplier,dpse.volume,dpse.multiplier price_multiplier,dpse.adder,dpse.uom,null pricing_period
			,case when isnull(gmv.clm7_value,0)=0 then 'n' else 'y' end include_weekends
			,0 expiration_calendar ,dpse.pricing_index,isnull(@event_date,dpse.event_date) event_date
			,case when isnull(gmv.clm6_value,0)=0 then 'n' else 'y' end include_event_date
			,case when cast(gmv.clm8_value as int) in (990,980) then
				dateadd(day,-1,dbo.FNAGetSkippedDate(isnull(@event_date,dpse.event_date),gmv.clm8_value,isnull(gmv.clm3_value,1)) )
			else
				dbo.FNAGetBusinessDayN('n',isnull(@event_date,dpse.event_date),spcd2.holiday_calendar_id,cast(isnull(gmv.clm3_value,0) as int) -case when isnull(gmv.clm6_value,0)=0 then 0 else 1 end)
			end  skip_date
			,cast(gmv.clm8_value as int) skip_granularity,isnull(gmv.clm3_value,1) skip_days
			,cast(isnull(gmv.clm5_value,0) as int) quotes_after,dpse.BOLMO_pricing
		from  deal_price_std_event dpse
			inner join generic_mapping_values gmv on gmv.generic_mapping_values_id=dpse.event_type
			inner join generic_mapping_header gmh on gmh.mapping_table_id=gmv.mapping_table_id
				and gmh.mapping_name='Event Pricing Method'
			left join source_price_curve_def spcd2 on spcd2.source_curve_def_id=dpse.pricing_index
		where dpse.deal_price_type_id=dpt.deal_price_type_id
	) term
	left join source_price_curve_def spcd on spcd.source_curve_def_id=term.pricing_index
	left join time_zones tz on tz.TIMEZONE_ID=isnull(spcd.time_zone,@time_zone_id)	 -- 26 ---  
	outer apply
	(
		select min(exp_date) min_exp_date, max(exp_date) max_exp_date from holiday_group h
		where h.hol_group_value_id=spcd.exp_calendar_id
			and term.fin_term_start>= h.hol_date
			AND term.fin_term_end<=isnull(nullif(h.hol_date_to,'1900-01-01'),h.hol_date)
			and term.expiration_calendar =1
	) exp_max


select
	a.pricing_index
	,a.term_start
	,a.term_end
	,a.multiplier*
	case when a.hourly_volume_allocation=17601 then -- 17601:	Monthly Average Allocations	Monthly Average Allocations
		(1.0000/(a.no_months*max(a.month_sno) over(partition by pricing_index,a.fin_term_start)))
	else
		(1.0000/(max(sno) over(partition by pricing_index)))
	end  multiplier
	,a.price_multiplier
	,a.adder
	,a.volume
	,a.uom
	,a.source_deal_detail_id 
into #tt -- select * from #tt
from (
	select tt.pricing_index
		,tt.fin_term_start
		,tt.fin_term_end
		,tt.multiplier
		,tt.price_multiplier
		,tt.adder
		,tt.volume
		,tt.uom
		,coalesce(h_grp.term_date,d.term_date,tt.fin_term_start) term_start
		,coalesce(h_grp.term_date,d.term_date,tt.fin_term_end) term_end
		,sno=ROW_NUMBER() over(partition by tt.pricing_index  order by isnull(h_grp.term_date,d.term_date))
		,month_sno=ROW_NUMBER() over(partition by tt.pricing_index,tt.fin_term_start  order by isnull(h_grp.term_date,d.term_date))
		,tt.event_date,tt.include_event_date
		,datediff(month,tt.fin_term_min,tt.fin_term_max)+1 no_months
		,tt.hourly_volume_allocation
		,tt.source_deal_detail_id 
	from #TempTable tt
		outer apply
		(
			select exp_date term_date from holiday_group h
			where h.hol_group_value_id=tt.exp_calendar_id
				and tt.fin_term_start>= h.hol_date
				AND tt.fin_term_end<=isnull(nullif(h.hol_date_to,'1900-01-01'),h.hol_date)
				and tt.expiration_calendar =1
			union -- adding weekends and holiday
			select  t.term_date from seq s 
				outer apply
				(
					select tt.min_exp_date+(s.n-1) term_date
				) t	
				left join holiday_group hg on hg.hol_group_value_id=tt.holiday_calendar_id
					and hg.hol_date=t.term_date
			where t.term_date <=tt.max_exp_date
				and tt.expiration_calendar =1 and tt.include_weekends='y' 
				and (
					datepart(dw,t.term_date)=tt.weekend_first_day
					or datepart(dw,t.term_date)=tt.weekend_second_day
					or hg.hol_date is not null
				)
		) h_grp
		outer apply
		(
			select  tt.fin_term_start+(s1.n-1) term_date 
			from seq s1
				left join holiday_group h_day on h_day.hol_group_value_id=tt.holiday_calendar_id
					and h_day.hol_date=tt.fin_term_start+(s1.n-1)
			where
				--tt.fin_term_start+(s1.n-1)<>tt.skip_date and
				 not (
					 tt.fin_term_start+(s1.n-1)>isnull(tt.event_date, tt.fin_term_start) and tt.fin_term_start+(s1.n-1) <=isnull(tt.skip_date,tt.fin_term_start)
				 )
				and tt.expiration_calendar =0 
				and  tt.fin_term_start+(s1.n-1) <=tt.fin_term_end
				and
				((
					--isnull(tt.include_weekends,'y')='n' and
					not (
						datepart(dw,tt.fin_term_start+(s1.n-1))=tt.weekend_first_day
						or datepart(dw,tt.fin_term_start+(s1.n-1))=tt.weekend_second_day
						or h_day.hol_date is not null
					)
				) or tt.include_weekends='y')
		) d
	where ((isnull(tt.BOLMO_pricing,'n')='y' and coalesce(h_grp.term_date,d.term_date,tt.fin_term_start)>=@deal_date) or isnull(tt.BOLMO_pricing,'n')='n')
		and (tt.include_event_date='y' or  ( tt.include_event_date='n'  and coalesce(h_grp.term_date,d.term_date,tt.fin_term_start)<> tt.event_date))
	) a
	--where 
	--	(a.include_event_date='y' or  ( a.include_event_date='n'  and a.term_start<> a.event_date))


INSERT INTO #deal_position_break_down	
(
	[source_deal_header_id],
	[source_deal_detail_id],
	[leg],
	[strip_from],
	[lag],
	[strip_to],
	[curve_id],
	[prior_year],
	[multiplier],
	[derived_curve_id],
	[term_start],
	[exp_date],
	[pay_opposite],
	[buy_sell_flag],
	[exp_type],
	[exp_value],
	formula,
	formula_adder,formula_multiplier,
	complex_formula,divider,pricing_term,density_mult
)	
select sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.leg,
	0 strip_from, 0 lag, 1 strip_to, trm.pricing_index curve_id, 0 as prior_year, trm.multiplier*isnull(trm.price_multiplier,1),
	null derived_curve_id, sdd.term_start, trm.term_end, sdd.pay_opposite,sdd.buy_sell_flag, NULL exp_type,NULL exp_value,NULL
	,isnull(trm.adder,0) formula_adder ,isnull(trm.price_multiplier,1) formula_multiplier,null complex_formula,1 divider
	,case when trm.term_start=trm.term_end then trm.term_start else null end pricing_term,null density_mult	
FROM #tmp_sdd_FNAGetFinancialTerm sdd
	inner join #tt trm on trm.source_deal_detail_id=sdd.source_deal_detail_id


-- end Function code 
------------------------------------------------------------------------------------------------------------------



/* Use this code block for using FNAGetFinancialTerm

INSERT INTO #deal_position_break_down	
(
	[source_deal_header_id],
	[source_deal_detail_id],
	[leg],
	[strip_from],
	[lag],
	[strip_to],
	[curve_id],
	[prior_year],
	[multiplier],
	[derived_curve_id],
	[term_start],
	[exp_date],
	[pay_opposite],
	[buy_sell_flag],
	[exp_type],
	[exp_value],
	formula,
	formula_adder,formula_multiplier,
	complex_formula,divider,pricing_term,density_mult
)	
select sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.leg,
	0 strip_from, 0 lag, 1 strip_to, trm.pricing_index curve_id, 0 as prior_year, trm.multiplier*isnull(trm.price_multiplier,1),
	null derived_curve_id, sdd.term_start, trm.term_end, sdd.pay_opposite 
	,sdd.buy_sell_flag, NULL exp_type,NULL exp_value,NULL
	,isnull(trm.adder,0) formula_adder ,isnull(trm.price_multiplier,1) formula_multiplier,null complex_formula,1 divider,case when trm.term_start=trm.term_end then trm.term_start else null end pricing_term,null density_mult	
FROM #tmp_sdd_FNAGetFinancialTerm sdd
	outer apply [dbo].FNAGetFinancialTerm(sdd.source_deal_detail_id,null) trm

--*/


declare @url_m_report VARCHAR(5000), @desc VARCHAR(5000)
set @url_m_report = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=EXEC spa_execute_SQL ''select 
		dbo.FNAHyperLinkText(10131010, cast(source_deal_header_id as VARCHAR), cast(source_deal_header_id as VARCHAR)) [Deal ID],
		error_message [Message] from ' +  @error_process_tbl + ''''

If (select count(*) from #deal_position_break_down where multiplier is null) > 0
BEGIN
	--ERROR HANDLING
	--SELECT	'Error' ErrorCode, 'Deal Position Breakdown' Module, 'spa_deal_position_breakdown' Area, 
	--		'Error' Status, 
	--		'Deal Position Breakdown for formula based pricing or index failed. ' +
	--		'Multiplier is NULL due to missing values for CONV or UDF functions or invalid formula syntax.' [Message], 
	--		'Please review the formula and/or values exist if CONV or UDF functions used.' Recommendation
	

	EXEC spa_ErrorHandler -1
		, 'spa_deal_position_breakdown' -- Name the tables used in the query.
		, 'spa_deal_position_breakdown' -- Name the stored proc.
		, 'Error' -- Operations status.
		, 'Deal Position Breakdown for formula based pricing or index failed. Multiplier is NULL due to missing values for CONV or UDF functions or invalid formula syntax.' -- Success message.
		, 'Please review the formula and/or values exist if CONV or UDF functions used.' -- The reference of the data deleted.


	EXEC(' INSERT INTO ' + @error_process_tbl + '
		SELECT	source_deal_header_id, 
			''Multiplier is NULL due to missing values for CONV or UDF functions or invalid formula syntax. Please review the formula and/or values exist if CONV or UDF functions used.'' 
		FROM  #deal_position_break_down where multiplier is null
		GROUP BY source_deal_header_id '
		)

	SET @desc = '<a target="_blank" href="' + @url_m_report + '">' + 
				'Error found during position breakdown logic (NULL multiplier found).' +  
				'</a>'

	EXEC  spa_message_board 'u', @user_login_id, NULL, 'Position Breakdown',  @desc, '', '', 'e', @process_id2, NULL, NULL, NULL, 'n'

END

select	d.source_deal_header_id, d.source_deal_detail_id, d.leg, d.strip_from, d.lag, d.strip_to, 
	d.curve_id, d.prior_year, d.multiplier*isnull(d.density_mult,1)* isnull(conv.conversion_factor,1) multiplier,
	getdate() create_ts, dbo.FNADBUser() create_user, d.derived_curve_id,
	d.curve_id location_id, spcd.uom_id volume_uom_id, spcd.commodity_id, 'f' as phy_fin_flag,
	isnull(l.term_start,d.term_start) del_term_start, 
	case when d.pricing_term is null then  dbo.FNAGetTermStartDate('m', d.term_start, r.pricing_term) else  d.pricing_term end fin_term_start,	
	--CASE WHEN (d.strip_from=0 and d.lag=0 and d.strip_to=1) THEN d.exp_date	ELSE
	case when d.pricing_term is null then
		ISNULL(dbo.FNARelativeExpirationDate(DATEADD(M, r.pricing_term,d.term_start),d.curve_id,0,d.exp_type,NULLIF(d.exp_value,'NULL'))
			, dbo.FNAGetTermEndDate('m', d.term_start, r.pricing_term)) 
	else d.exp_date end
	--END 
	fin_expiration_date,	
	CASE WHEN (d.derived_curve_id is not null OR d.pay_opposite = 'n') THEN case when (d.buy_sell_flag='b') then 1 else -1 end
		 ELSE case when (d.buy_sell_flag='b') then -1 else 1 end
	END * (d.multiplier/ISNULL(nullif(d.strip_from, 0), 1))*ISNULL(r.multiplier,1)*(cast(1.00 as float)/d.divider) * isnull(conv.conversion_factor,1) del_vol_multiplier,
	case when d.pricing_term is null then  dbo.FNAGetTermEndDate('m', d.term_start, r.pricing_term) else  d.pricing_term end fin_term_end,
	CASE WHEN d.exp_type='REBD' THEN 'REBD' ELSE d.formula END formula,d.formula_adder ,d.formula_multiplier,d.complex_formula
into #deal_position_break_down_final
from #deal_position_break_down d 
inner join source_price_curve_def spcd on spcd.source_curve_def_id = d.curve_id 
left join #deal_legs l on l.source_deal_detail_id=d.source_deal_detail_id
left join position_break_down_rule r on r.strip_from = d.strip_from and r.lag = d.lag and 
	r.strip_to = d.strip_to and month(d.term_start) = r.phy_month
left join dbo.source_deal_detail sdd on sdd.source_deal_detail_id=d.source_deal_detail_id
	and sdd.position_uom is null
left join source_price_curve_def spcd1 on spcd1.source_curve_def_id = sdd.curve_id 
	and sdd.position_uom is null
LEFT JOIN rec_volume_unit_conversion conv (nolock) 
	ON conv.from_source_uom_id=COALESCE(spcd1.display_uom_id,spcd1.uom_id)
	AND to_source_uom_id=isnull(spcd.display_uom_id,spcd.uom_id)
	and sdd.position_uom is null


select source_deal_header_id 
into #error_deals
from #deal_position_break_down_final
where fin_term_start is null OR del_vol_multiplier is null
group by source_deal_header_id 

IF (select count(*) from #deal_position_break_down_final where fin_term_start is null) > 0 
BEGIN

	--ERROR HANDLING

	EXEC spa_ErrorHandler -1
				, 'spa_deal_position_breakdown' -- Name the tables used in the query.
				, 'spa_deal_position_breakdown' -- Name the stored proc.
				, 'Error' -- Operations status.
				, 'Deal Position Breakdown has NULL multiplier. Multiplier is NULL due to missing multiplier or position breakdown rules.' -- Success message.
				,  'Please review for missing multiplier or contact system admin for missing position breakdown rules.' -- The reference of the data deleted.


	--SELECT	'Error' ErrorCode, 'Deal Position Breakdown' Module, 'spa_deal_position_breakdown' Area, 
	--		'Error' Status, 
	--		'Deal Position Breakdown has NULL multiplier. ' +
	--		'Multiplier is NULL due to missing multiplier or position breakdown rules.' [Message], 
	--		'Please review for missing multiplier or contact system admin for missing position breakdown rules.' Recommendation


	EXEC(' INSERT INTO ' + @error_process_tbl + '
	SELECT	source_deal_header_id, 
		''Multiplier is NULL due to missing multiplier or position breakdown rules. Please review for missing multiplier or contact system admin for missing position breakdown rules.'' 
	FROM  #deal_position_break_down_final where fin_term_start is null
	GROUP BY source_deal_header_id ')

	SET @desc = '<a target="_blank" href="' + @url_m_report + '">' + 
				'Multiplier is NULL due to missing multiplier or position breakdown rules. (NULL multiplier found).' +  
				'</a>'

	EXEC  spa_message_board 'u', @user_login_id, NULL, 'Position Breakdown',  @desc, '', '', 'e', @process_id2, NULL, NULL, NULL, 'n'

	
END


-- select * from #simple_formula

--- Update formula_curve_id  of Deal detail
CREATE TABLE #simple_formula(formula_id INT,curve_id INT)
INSERT INTO #simple_formula(formula_id,curve_id)
SELECT 
		formula_id,dbo.FNACurveIDOfSimpleFormula(formula_id)
FROM
	(
		SELECT DISTINCT formula_id FROM #deals d INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id
	) a
			
		
IF EXISTS(SELECT 1 FROM  #simple_formula WHERE 	curve_id IS NOT NULL)
begin
	UPDATE sdd
		SET sdd.formula_curve_id=sf.curve_id
	FROM
		#deals d INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id
		INNER JOIN #simple_formula sf On sf.formula_id=sdd.formula_id
		cross apply (
				select 1 aaa FROM #deal_position_break_down_final f left join
					 #error_deals e ON d.source_deal_header_id = e.source_deal_header_id
				WHERE  e.source_deal_header_id IS NULL and f.source_deal_detail_id=sdd.source_deal_detail_id
				group by f.source_deal_detail_id having count(1)<2
			) filter --if simple function is used more than one, it is not simple and count as complex
				
	UPDATE sdd
		SET sdd.formula_curve_id=null
	FROM
		#deals d INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id
		inner join #deal_position_break_down_final f on f.source_deal_detail_id=sdd.source_deal_detail_id  and f.complex_formula='y'

	UPDATE t
		SET formula_adder=0 , formula_multiplier=1 --if the formula has multiple simple function then it count as complex formula and set multiplier,adder
	FROM
		#deals d INNER JOIN #deal_position_break_down_final t ON t.source_deal_header_id = d.source_deal_header_id
		cross apply (
			select 1 aaa FROM #deal_position_break_down_final f left join
				 #error_deals e ON d.source_deal_header_id = e.source_deal_header_id
			WHERE  e.source_deal_header_id IS NULL and f.source_deal_detail_id=t.source_deal_detail_id
			group by f.source_deal_detail_id having count(1)>1
		) filter --if simple function is used more than one, it is not simple and count as complex
				

	UPDATE sdda
			SET sdda.formula_curve_id=sf.curve_id
	FROM #deals d INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = d.source_deal_header_id
			INNER JOIN #simple_formula sf On sf.formula_id=sdd.formula_id
	cross apply (
		select source_deal_detail_id,max(audit_id) audit_id from source_deal_detail_audit
		 where  source_deal_detail_id=sdd.source_deal_detail_id group by source_deal_detail_id
	 ) a 
	 inner join source_deal_detail_audit sdda on sdda.source_deal_detail_id=a.source_deal_detail_id and sdda.audit_id= a.audit_id
	cross apply (
		select 1 aaa FROM #deal_position_break_down_final f left join
			 #error_deals e ON f.source_deal_header_id = e.source_deal_header_id
		WHERE  e.source_deal_header_id IS NULL and f.source_deal_detail_id=sdd.source_deal_detail_id
		group by f.source_deal_detail_id having count(1)<2
	) filter --if simple function is used more than one, it is not simple and count as complex

end


DELETE deal_position_break_down 
FROM deal_position_break_down dp inner join
	 #deals d ON d.source_deal_header_id = dp.source_deal_header_id --AND (d.process_flag = 'f' OR d.process_flag = 'u') 

SET @sql_str='
	INSERT INTO deal_position_break_down(source_deal_header_id, source_deal_detail_id, leg, strip_from, lag,
		strip_to, curve_id, prior_year, multiplier, create_ts, create_user, derived_curve_id,
		location_id, volume_uom_id, commodity_id, phy_fin_flag, del_term_start, fin_term_start, 
		fin_expiration_date, del_vol_multiplier, fin_term_end,formula,simple_for_adder , simple_for_multiplier)
	SELECT	d.source_deal_header_id, source_deal_detail_id, leg, strip_from, lag,
			strip_to, curve_id, prior_year, multiplier, create_ts, create_user, derived_curve_id,
			location_id, volume_uom_id, commodity_id, phy_fin_flag, del_term_start, fin_term_start, 
			fin_expiration_date, del_vol_multiplier, fin_term_end,formula,d.formula_adder ,d.formula_multiplier
	FROM #deal_position_break_down_final d left join
		 #error_deals e ON d.source_deal_header_id = e.source_deal_header_id
	WHERE e.source_deal_header_id IS NULL'

EXEC spa_print @sql_str
EXEC(@sql_str)


message_level:

EXEC spa_ErrorHandler 0
			, 'spa_deal_position_breakdown' -- Name the tables used in the query.
			, 'spa_deal_position_breakdown' -- Name the stored proc.
			, 'Success' -- Operations status.
			, 'Deal Position Breakdown successfully completed.' -- Success message.
			,  NULL -- The reference of the data deleted.


--SELECT	'Success' ErrorCode, 'Deal Position Breakdown' Module, 'spa_deal_position_breakdown' Area, 
--		'Success' Status, 'Deal Position Breakdown successfully completed.' [Message], 
--		'' Recommendation

END TRY
BEGIN CATCH
EXEC spa_print '*************************************************************'
EXEC spa_print 'Error Found (Catch error):'
	--EXEC spa_print ERROR_MESSAGE()
EXEC spa_print '*************************************************************'
END CATCH 

