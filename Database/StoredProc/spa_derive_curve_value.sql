/****** Object:  StoredProcedure [dbo].[spa_derive_curve_value]    Script Date: 03/03/2010 17:39:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_derive_curve_value]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_derive_curve_value]
GO
/****** Object:  StoredProcedure [dbo].[spa_derive_curve_value]    Script Date: 03/03/2010 17:39:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_derive_curve_value]
	@source_curve_def_id VARCHAR(MAX),
	@as_of_date_from DATETIME,
	@as_of_date_to DATETIME,
	@curve_source_value_id INT,
	@table_name VARCHAR(100) = NULL,
	@tenor_from VARCHAR(20) = NULL,
	@tenor_to VARCHAR(20)= null,
	@curve_pracess_table VARCHAR(250) = NULL

AS
/*



DECLARE @source_curve_def_id VARCHAR(200)= null,
	@as_of_date_from DATETIME= '2016-03-31',
	@as_of_date_to DATETIME='2016-03-31',
	@curve_source_value_id INT=4500,
	@table_name VARCHAR(100) = 'adiha_process.dbo.calc_result_derive_sa_C41931D8_FCFF_4782_9E25_3E341D0ADA37', --'#formulaData',
	@tenor_from VARCHAR(20) =  null,
	@tenor_to VARCHAR(20)= null,
	@curve_pracess_table VARCHAR(250) = 'adiha_process.dbo.curve_formula_derive_sa_C41931D8_FCFF_4782_9E25_3E341D0ADA37'

--delete source_price_curve where source_curve_def_id=10 and as_of_date='2013-07-31'
--AND maturity_date between '2023-09-01'and '2033-08-01'


DROP TABLE #temp_tenor
DROP TABLE #formula_value
DROP TABLE #source_curve_def_id
DROP TABLE #as_of_date
DROP TABLE  #term
DROP TABLE #curve_maturity_range

--*/


/*


	Required columns for table @curve_pracess_table:
	(
		source_curve_def_id,
		term_start,
		term_end
		as_of_date
		

	)


*/






SET NOCOUNT ON;
DECLARE @process_id     VARCHAR(50)
DECLARE @formula_id     INT
DECLARE @formula_str    VARCHAR(MAX)
DECLARE @maturity_date  DATETIME
DECLARE @formula_stmt   VARCHAR(MAX)
DECLARE @granularity    INT
DECLARE @as_of_date     DATETIME
DECLARE @curve_value    FLOAT
DECLARE @sql            VARCHAR(MAX)

-- Set varaiables			

create table #curve_maturity_range(
curve_id int,term_start datetime,term_end datetime
)



IF @as_of_date_to IS NULL 
	SET @as_of_date_to = @as_of_date_from

select * into #source_curve_def_id from dbo.SplitCommaSeperatedValues(@source_curve_def_id)

select term_start as_of_date,term_end as_of_date_to into #as_of_date from dbo.FNATermBreakdown('d', @as_of_date_from,@as_of_date_to)
--select * from static_data_value where type_id=978

--select * from #as_of_date
if @curve_pracess_table is null --breaking maturity date at granularity level
begin

	insert into #curve_maturity_range(curve_id ,term_start ,term_end) select  Item curve_id,@tenor_from term_start, @tenor_to term_end from #source_curve_def_id
end
else 	
begin
	set @sql='insert into #curve_maturity_range(curve_id ,term_start ,term_end) select source_curve_def_id,term_start,term_end from '+@curve_pracess_table
	exec spa_print @sql
	exec(@sql)
end	
 	

;WITH
cteTerm (source_curve_def_id,term,granularity,level_loop,is_dst,term_end)
  AS
  (
	select spcd.source_curve_def_id,cid.term_start term,spcd.granularity,0 level_loop,0 is_dst,cid.term_end
	from #curve_maturity_range cid
		 inner join  source_price_curve_def spcd
		ON  cid.curve_id = spcd.source_curve_def_id
	UNION ALL

	SELECT spcd.source_curve_def_id,cast(case  spcd.granularity
			when 987	then dateadd(mi,15,t.term)	--15Min
			when 989	then dateadd(mi,30,t.term)	--30Min
			when 993	then dateadd(yy,1,t.term)	--Annually
			when 981	then dateadd(dd,1,t.term)	--Daily
			when 982	then dateadd(hh,1,t.term)	--Hourly
			when 980	then dateadd(mm,1,t.term)	--Monthly
			when 991	then dateadd(mm,3,t.term)	--Quarterly
			when 992	then dateadd(mm,6,t.term)	--Semi-Annually
			when 990	then dateadd(dd,7,t.term)	--Weekly 
			when 10000289	then dateadd(mm,1,t.term)	--TOU Monthly
			when 10000290	then dateadd(dd,1,t.term)	--TOU Daily
		end  as datetime) term,spcd.granularity,
	  t.level_loop + 1 level_loop,0 is_dst,t.term_end
	FROM  cteTerm t
		 inner join  source_price_curve_def spcd
	ON  t.source_curve_def_id = spcd.source_curve_def_id
	where t.term<
		case  spcd.granularity
			when 987	then dateadd(dd,1,t.term_end)	--15Min
			when 989	then dateadd(dd,1,t.term_end)	--30Min
			when 982	then dateadd(dd,1,t.term_end)	--Hourly
			else t.term_end
		end  

  )
select * into #term from   cteTerm where convert(varchar(10),term,120)<=term_end
	option ( MaxRecursion 0 ) 
 
 
 insert into #term (source_curve_def_id,term,granularity,level_loop,is_dst)
 select t.source_curve_def_id,t.term,granularity,t.level_loop,1 is_dst 
 from #term t 
 inner join mv90_dst dst on convert(varchar(10),t.term,120)=dst.[date]
	 and datepart(hour,t.term)+1=dst.[hour] and dst.insert_delete='i'
	 and t.granularity in(987,989,982)
 
DECLARE @default_dst_group_value_id INT
SELECT @default_dst_group_value_id = dst_group_value_id FROM adiha_default_codes adc 
INNER JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id
INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
WHERE adc.code_def = 'Define System Time Zone'

 delete #term from #term t 
 inner join mv90_dst dst on convert(varchar(10),t.term,120)=dst.[date]
	 and datepart(hour,t.term)+1=dst.[hour] and dst.insert_delete='d'
	 and t.granularity in(987,989,982) AND dst.dst_group_value_id = @default_dst_group_value_id

--select * from #term
--return

   

DECLARE @formula_table      VARCHAR(100)
DECLARE @calc_result_table  VARCHAR(100)
DECLARE @user_login_id      VARCHAR(100)

SET @user_login_id = dbo.FNADBUser()	
SET @process_id = REPLACE(NEWID(), '-', '_')
SET @formula_table = dbo.FNAProcessTableName('curve_formula_table', @user_login_id, @process_id)
SET @calc_result_table = dbo.FNAProcessTableName('formula_calc_result', @user_login_id, @process_id)

SET @sql = 'CREATE TABLE ' + @formula_table + ' (
				rowid                     INT,
				counterparty_id           INT,
				contract_id               INT,
				curve_id                  INT,
				prod_date                 DATETIME,
				as_of_date                DATETIME,
				volume                    FLOAT,
				onPeakVolume              FLOAT,
				source_deal_detail_id     INT,
				formula_id                INT,
				invoice_Line_item_id      INT,
				invoice_line_item_seq_id  INT,
				price                     FLOAT,
				granularity               INT,
				volume_uom_id             INT,
				generator_id              INT,
				[Hour]                    INT,
				commodity_id              INT,
				meter_id                  INT,
				curve_source_value_id     INT,
				mins                      INT,
				is_dst					  INT	
			)	'
	
EXEC (@sql)		


SET @sql=' INSERT INTO '+@formula_table+'
	(rowid,counterparty_id,contract_id,curve_id,prod_date,as_of_date,formula_id,curve_source_value_id,granularity,[hour],invoice_Line_item_id,mins,is_dst)
	SELECT
		1,
		-1,
		-1,
		tsc.source_curve_def_id,tsc.term,aod.as_of_date ,spcd.formula_id,
		'+CAST(@curve_source_value_id AS VARCHAR)+',
		spcd.granularity,
		case when spcd.granularity IN(982,987,989,994,995) then datepart(hour,tsc.term)+1 else 0 end hr,
		-1,
		case when spcd.granularity=987 then --15Min
				case (DATEPART(mi,tsc.term)+1)/15 when 0 then 15 when 1 then 30 when 2 then 45  when 4 then 60 end
			when spcd.granularity=989 then --30Min
				case (DATEPART(mi,tsc.term)+1)/30 when 0 then 30 when 1 then 60 end
			else 0
		end
		,tsc.is_dst
	FROM #term tsc 
	cross join #as_of_date aod
	INNER JOIN source_price_curve_def spcd ON tsc.source_curve_def_id=spcd.source_curve_def_id
	
'	
			
exec spa_print @sql
EXEC (@sql)


--select @as_of_date_from,@formula_table,@process_id,@calc_result_table,NULL,'n','n','d',0,NULL,NULL,'y'
EXEC spa_calculate_formula	@as_of_date_from,@formula_table,@process_id,@calc_result_table,NULL,'n','n','d',0,NULL,NULL,'y',@as_of_date_to

--EXEC('select ''@calc_result_table'',* from ' + @calc_result_table+' order by as_of_date')

IF @table_name IS NULL
BEGIN
	SET @sql = 'SELECT curve_id, as_of_date, prod_date, formula_eval_value, formula_id, '+cast(@curve_source_value_id as varchar) +' curve_source_value_id
	            FROM ' + @calc_result_table --+' order by 3'
END
ELSE
BEGIN
	--SET @sql = 'SELECT curve_id, as_of_date, prod_date, formula_eval_value, formula_id, NULL FROM ' + @calc_result_table
	if object_id(@table_name) is null 
		SET @sql = ' SELECT curve_id, as_of_date, prod_date, formula_eval_value, formula_id, is_dst,'+cast(@curve_source_value_id as varchar) +' curve_source_value_id into '+ @table_name +' FROM   ' + @calc_result_table				
	else	
		SET @sql = 'INSERT INTO ' + @table_name + ' SELECT curve_id, as_of_date, prod_date, formula_eval_value, formula_id, '+cast(@curve_source_value_id as varchar) +' curve_source_value_id, is_dst FROM   ' + @calc_result_table				
END

EXEC spa_print @sql
EXEC (@sql)	
