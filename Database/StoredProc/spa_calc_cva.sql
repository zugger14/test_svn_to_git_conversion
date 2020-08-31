

if OBJECT_ID('dbo.spa_calc_cva') is not null
drop proc dbo.spa_calc_cva
go

--select * from default_probability
--select * from default_recovery_rate

--select * from static_data_value
--select * from counterparty_credit_info
--select * from source_deal_pfe_simulation
--select * from credit_exposure_detail where as_of_date='2012-06-22'

create proc dbo.spa_calc_cva 
 @as_of_date varchar(10)
,@counterparty_ids varchar(MAX) =null
,@term_start  varchar(10)=null
,@term_end  varchar(10)=null
,@curve_source_id varchar(10)=4500
,@use_simulated_exposures varchar(1)= NULL
,@no_of_simulation int=null
,@exposure CHAR(1) = NULL
,@batch_process_id VARCHAR(150)=NULL
,@batch_report_param VARCHAR(5000) = NULL
,@user_name VARCHAR(50)=null
As
/*


declare  
 @as_of_date varchar(10)='2017-06-15'
,@counterparty_ids varchar(1000) ='4251,4260,4261,7520,7525'
,@term_start  varchar(10)=null
,@term_end  varchar(10)=null
,@curve_source_id varchar(10)=4500
,@use_simulated_exposures varchar(1)='n'
,@no_of_simulation int=null
,@exposure CHAR(1) = 'p'
,@batch_report_param VARCHAR(5000) = NULL
,@batch_process_id VARCHAR(150)=null
,@user_name VARCHAR(50)=null
 
 
 --*/
 
SET @user_name = isnull(@user_name,dbo.fnadbuser())
DECLARE @url        VARCHAR(500)
DECLARE @desc       VARCHAR(500)
DECLARE @errorMsg   VARCHAR(200)
DECLARE @errorcode  VARCHAR(1)
DECLARE @url_desc   VARCHAR(500)
DECLARE @total INT, @warning INT, @failure INT, @count INT, @msg_desc VARCHAR(5000), @counterparty_name VARCHAR(MAX)

SET @url = ''
SET @desc = ''
SET @errorMsg = ''
SET @errorcode = 'e'
SET @url_desc = ''

SET @total = 0
SET @warning = 0
SET @failure = 0
SET @count = 0
SET @msg_desc = ''
SET @counterparty_name = ''

IF @term_start = ''
	SET @term_start = NULL
IF @term_end = ''
	SET @term_end = NULL

IF @batch_process_id IS NULL
    SET @batch_process_id = REPLACE(NEWID(), '-', '_')
    
IF @counterparty_ids IS NULL
BEGIN
	SELECT DISTINCT sc.source_counterparty_id
	INTO #tmp_counterparty_id	
	FROM portfolio_hierarchy ph 
		INNER JOIN fas_strategy fs ON ph.parent_entity_id = fs.fas_strategy_id 
		INNER JOIN source_system_description ssd on ssd.source_system_id = fs.source_system_id 
		INNER JOIN source_counterparty sc on sc.source_system_id = ssd.source_system_id 		
	WHERE 1=1  AND sc.int_ext_flag IN('i','e')
	
	SELECT @counterparty_ids = COALESCE(@counterparty_ids + ', ','') + CAST(source_counterparty_id AS VARCHAR(3000))
	FROM #tmp_counterparty_id			
END

declare @st varchar(max),@st1 varchar(max), @st1A varchar(max), @st2 varchar(max),@st11 varchar(max) = null, @st12 varchar(max) = null, @as_of_date_to  varchar(10),@distination_table_name varchar(50),@st_as_of_date varchar(200)
set @distination_table_name='source_deal_cva'
set @st_as_of_date =' src.as_of_date='''+@as_of_date+''''

if ISNULL(@use_simulated_exposures,'n')='y'
begin
	set @as_of_date_to=case when @no_of_simulation is null then null else CONVERT(varchar(10),dateadd(day,@no_of_simulation,'1900-01-01'),120) end
	set @curve_source_id=4505
	set @distination_table_name='source_deal_cva_simulation'
	set @st_as_of_date =' src.run_date='''+@as_of_date+''''+case when @no_of_simulation is null then '' else ' and src.as_of_date<='''+@as_of_date_to+'''' end

end

set @st=@st_as_of_date + case when @counterparty_ids is not null then ' and src.Source_Counterparty_ID in ('+@counterparty_ids+')' else '' end
	+case when @term_start is not null then ' and src.term_start>='''+@term_start+'''' else '' end
	+case when @term_end is not null then ' and src.term_start<='''+@term_end+'''' else '' end
	+case when @curve_source_id is not null then ' and src.curve_source_value_id ='+@curve_source_id else '' END
	--+ ' AND src.exp_type_id IN (1,2)'



begin try


set @st1=' delete '+@distination_table_name+' where '+case when ISNULL(@use_simulated_exposures,'n')='y' then 'run_date=' else 'as_of_date=' end + ''''+@as_of_date+'''' + case when @counterparty_ids is null then '' else ' and Source_Counterparty_ID  in ('+@counterparty_ids+')' end

exec(@st1)

if OBJECT_ID('tempdb..#source_deal_cva') is not null
drop table #source_deal_cva

create table #source_deal_cva
(
run_date datetime,as_of_date datetime
,Source_Counterparty_ID int
,source_deal_header_id int,term_start datetime,
rating_id int, curve_source_value_id int ,exposure_to_us float,exposure_to_them FLOAT,
d_exposure_to_us FLOAT,d_exposure_to_them FLOAT,
effective_exposure_to_us  FLOAT,effective_exposure_to_them FLOAT,
d_effective_exposure_to_us FLOAT,d_effective_exposure_to_them FLOAT,
cva_with_collateral float,dva_with_collateral float,
d_cva_with_collateral float,d_dva_with_collateral FLOAT
,cva float,dva float,create_ts datetime,create_user varchar(30) COLLATE DATABASE_DEFAULT,dva_Counterparty_ID int,Final_Und_Pnl float,currency_name varchar(50) COLLATE DATABASE_DEFAULT, d_cva FLOAT, d_dva FLOAT, credit_adjustment_mtm FLOAT, adjusted_discounted_mtm FLOAT, dis_final_und_pnl FLOAT, probability FLOAT, recovery FLOAT,internal_counterparty_id INT
)

if ISNULL(@use_simulated_exposures,'n')='y'
begin
	set @st1='
	insert into #source_deal_cva
	(
	run_date,as_of_date,Source_Counterparty_ID, source_deal_header_id, term_start,rating_id, curve_source_value_id ,exposure_to_us,exposure_to_them,cva,dva ,create_ts,create_user,dva_Counterparty_ID 
	) 
	select '''+@as_of_date+''' run_date,MAX(s.as_of_date) as_of_date,s.Source_Counterparty_ID, s.source_deal_header_id, s.term_start
	,max(s.rating_id) rating_id,s.curve_source_value_id,
	avg(s.exposure_to_us) exposure_to_us,avg(s.exposure_to_them) exposure_to_them,avg(s.cva) * -1 cva,avg(s.dva) * -1 dva, getdate() create_ts,'''+@user_name +''' create_user, 1
	from (
		select '''+@as_of_date+''' run_date,MAX(src.as_of_date) as_of_date,src.Source_Counterparty_ID, src.source_deal_header_id, src.term_start
		,src.curve_source_value_id,max(cif_d.ratinng_id) rating_id,sum(src.net_exposure_to_us) exposure_to_us ,sum(src.net_exposure_to_them) exposure_to_them
		 ,sum(net_exposure_to_us* dbo.FNAGetProbabilityDefault( cif_d.ratinng_id, DATEDIFF(month,term_start,'''+@as_of_date+''') ,+'''+@as_of_date+''')
			* ( 1 - dbo.FNAGetRecoveryRate(cif_d.ratinng_id, DATEDIFF(month,term_start,'''+@as_of_date+''') ,'''+@as_of_date+''') )
		 ) cva,
		sum(src.net_exposure_to_them* dbo.FNAGetProbabilityDefault(cif_d.ratinng_id, DATEDIFF(month,term_start,'''+@as_of_date+''') ,'''+@as_of_date+''')
			* ( 1 - dbo.FNAGetRecoveryRate(cif_d.ratinng_id, DATEDIFF(month,term_start,'''+@as_of_date+''') ,'''+@as_of_date+''') )
		 ) dva
		from dbo.source_deal_pfe_simulation src  inner join source_counterparty sc on src.Source_Counterparty_ID=sc.Source_Counterparty_ID
		outer apply
		( select distinct case isnull(cif.cva_data,1) when 1 then cif.Debt_rating when 2 then cif.Debt_rating2 when 3 then cif.Debt_rating3
				when 4 then cif.Debt_rating4 when 5 then cif.Debt_rating5 when 6 then cif.Risk_rating when 7 then sdv.value_id
			end ratinng_id from source_deal_header sdh inner join Source_Counterparty sc on sdh.Counterparty_id=sc.Source_Counterparty_ID and sdh.Counterparty_id=src.Source_Counterparty_ID
			inner join source_system_book_map ssbm on sdh.source_system_book_id1 = ssbm.source_system_book_id1
						AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
						AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
						AND sdh.source_system_book_id4 = ssbm.source_system_book_id4 
			left JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=ssbm.fas_book_id
			left JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
			left JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
			left join fas_subsidiaries fs on sb.entity_id=fs.fas_subsidiary_id
	 		left join counterparty_credit_info cif on src.Source_Counterparty_ID=cif.Counterparty_id
			left join static_data_value sdv on sdv.code=sc.Counterparty_ID and sdv.type_id=23000 and isnull(cif.cva_data,1)=7
		) cif_d
		where '+ @st+ '
		group by src.Source_Counterparty_ID,src.term_start,src.curve_source_value_id,src.as_of_date,src.source_deal_header_id
	) s 
		group by s.Source_Counterparty_ID,s.term_start,s.curve_source_value_id,s.source_deal_header_id
	'

END
else 
begin
set @st1A = '
	insert into #source_deal_cva
	(
		as_of_date,Source_Counterparty_ID,source_deal_header_id,term_start,rating_id, curve_source_value_id 
		,exposure_to_us,exposure_to_them,	
		d_exposure_to_us,d_exposure_to_them,
		effective_exposure_to_us,effective_exposure_to_them,
		d_effective_exposure_to_us,d_effective_exposure_to_them,
		cva_with_collateral,dva_with_collateral,
		d_cva_with_collateral,d_dva_with_collateral,		
		cva,dva ,create_ts,create_user,dva_Counterparty_ID,Final_Und_Pnl,currency_name, d_cva, d_dva, dis_final_und_pnl,
		probability, recovery, internal_counterparty_id
	)
	select '''+@as_of_date+'''  as_of_date,src.Source_Counterparty_ID,src.source_deal_header_id,src.term_start
	,max(case isnull(cif.cva_data,1) 
		when 1 then cif.Debt_rating 
		when 2 then cif.Debt_rating2 
		when 3 then cif.Debt_rating3
		when 4 then cif.Debt_rating4
		when 5 then cif.Debt_rating5
		when 6 then cif.Risk_rating 
		when 7 then sdv.value_id
	 end) rating_id
	,src.curve_source_value_id
	,sum(src.net_exposure_to_us) exposure_to_us
	,sum(src.net_exposure_to_them) exposure_to_them 
	,sum(src.d_exposure_to_us) d_exposure_to_us
	,sum(src.d_exposure_to_them) d_exposure_to_them
	,sum(src.effective_exposure_to_us) effective_exposure_to_us
	,sum(src.effective_exposure_to_them) effective_exposure_to_them
	,sum(src.d_effective_exposure_to_us) d_effective_exposure_to_us
	,sum(src.d_effective_exposure_to_them) d_effective_exposure_to_them	
	,sum(effective_exposure_to_us*
	CASE WHEN ISNULL(cif.cva_data, 1) = 8 THEN
	 (1 - EXP(- (ISNULL(dbo.FNAGetProbabilityDefault(sdv.value_id, DATEDIFF(month,src.term_start, ''' + @as_of_date + ''') ,+''' + @as_of_date + '''), 0) / 10000)
		/ (1 - ISNULL(dbo.FNAGetRecoveryRate(sdv.value_id, DATEDIFF(month, src.term_start,''' + @as_of_date + '''), ''' + @as_of_date + '''), 0)) 
		* (DATEDIFF(day, ''' + @as_of_date + ''', src.term_start) / CAST(365 AS FLOAT))))  
	ELSE 
	 ISNULL(dbo.FNAGetProbabilityDefault(case isnull(cif.cva_data,1) when 1 then cif.Debt_rating when 2 then cif.Debt_rating2 when 3 then cif.Debt_rating3
			when 4 then cif.Debt_rating4 when 5 then cif.Debt_rating5 when 6 then cif.Risk_rating when 7 then sdv.value_id 
		end, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,+''' + @as_of_date + '''), 0)
	END	
		* ( 1 - ISNULL(dbo.FNAGetRecoveryRate(
		case isnull(cif.cva_data,1) when 1 then cif.Debt_rating when 2 then cif.Debt_rating2 when 3 then cif.Debt_rating3
			when 4 then cif.Debt_rating4 when 5 then cif.Debt_rating5 when 6 then cif.Risk_rating when 7 then sdv.value_id
			when 8 then sdv.value_id
		end, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,''' + @as_of_date + '''), 0) )
	 ) * -1 cva_with_collateral,

	SUM(src.effective_exposure_to_them *
	CASE WHEN COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) = 8 THEN
	(1 - EXP(- (ISNULL(dbo.FNAGetProbabilityDefault(COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id), DATEDIFF(month,src.term_start,''' + @as_of_date + ''') , + ''' + @as_of_date + '''), 0) / 10000)
		/ (1 - ISNULL(dbo.FNAGetRecoveryRate(COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id), DATEDIFF(month,src.term_start,'''+ @as_of_date + ''') ,''' + @as_of_date + '''), 0)) 
		* (DATEDIFF(day, ''' + @as_of_date + ''', src.term_start) / CAST(365 AS FLOAT))))
	ELSE 
	ISNULL(dbo.FNAGetProbabilityDefault(
		CASE COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) 
			WHEN 1 THEN COALESCE(cif1.Debt_rating, cif2.Debt_rating, cif3.Debt_rating, cif4.Debt_rating) 
			WHEN 2 THEN COALESCE(cif1.Debt_rating2, cif2.Debt_rating2, cif3.Debt_rating2, cif4.Debt_rating2) 
			WHEN 3 THEN COALESCE(cif1.Debt_rating3, cif2.Debt_rating3, cif3.Debt_rating3, cif4.Debt_rating3)
			WHEN 4 THEN COALESCE(cif1.Debt_rating4, cif2.Debt_rating4, cif3.Debt_rating4, cif4.Debt_rating4)
			WHEN 5 THEN COALESCE(cif1.Debt_rating5, cif2.Debt_rating5, cif3.Debt_rating5, cif4.Debt_rating5) 
			WHEN 6 THEN COALESCE(cif1.Risk_rating, cif2.Risk_rating, cif3.Risk_rating, cif4.Risk_rating)
			WHEN 7 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
		END, DATEDIFF(month,src.term_start, ''' + @as_of_date + ''') , ''' + @as_of_date + '''), 0)
	END	
		* ( 1 - ISNULL(dbo.FNAGetRecoveryRate(
		CASE COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) 
			WHEN 1 THEN COALESCE(cif1.Debt_rating, cif2.Debt_rating, cif3.Debt_rating, cif4.Debt_rating) 
			WHEN 2 THEN COALESCE(cif1.Debt_rating2, cif2.Debt_rating2, cif3.Debt_rating2, cif4.Debt_rating2) 
			WHEN 3 THEN COALESCE(cif1.Debt_rating3, cif2.Debt_rating3, cif3.Debt_rating3, cif4.Debt_rating3)
			WHEN 4 THEN COALESCE(cif1.Debt_rating4, cif2.Debt_rating4, cif3.Debt_rating4, cif4.Debt_rating4)
			WHEN 5 THEN COALESCE(cif1.Debt_rating5, cif2.Debt_rating5, cif3.Debt_rating5, cif4.Debt_rating5) 
			WHEN 6 THEN COALESCE(cif1.Risk_rating, cif2.Risk_rating, cif3.Risk_rating, cif4.Risk_rating)
			WHEN 7 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
			WHEN 8 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
		END, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,''' + @as_of_date + '''), 0) )
	 ) * -1 dva_with_collateral, '
	 
	SET @st1 = @st1A + '
	SUM(d_effective_exposure_to_us*
	CASE WHEN ISNULL(cif.cva_data, 1) = 8 THEN
	 (1 - EXP(- (ISNULL(dbo.FNAGetProbabilityDefault(sdv.value_id, DATEDIFF(month,src.term_start, ''' + @as_of_date + ''') ,+''' + @as_of_date + '''), 0) / 10000)
		/ (1 - ISNULL(dbo.FNAGetRecoveryRate(sdv.value_id, DATEDIFF(month, src.term_start,''' + @as_of_date + '''), ''' + @as_of_date + '''), 0)) 
		* (DATEDIFF(day, ''' + @as_of_date + ''', src.term_start) / CAST(365 AS FLOAT))))  
	ELSE 
	 ISNULL(dbo.FNAGetProbabilityDefault(case isnull(cif.cva_data,1) when 1 then cif.Debt_rating when 2 then cif.Debt_rating2 when 3 then cif.Debt_rating3
			when 4 then cif.Debt_rating4 when 5 then cif.Debt_rating5 when 6 then cif.Risk_rating when 7 then sdv.value_id 
		end, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,+''' + @as_of_date + '''), 0)
	END	
		* ( 1 - ISNULL(dbo.FNAGetRecoveryRate(
		case isnull(cif.cva_data,1) when 1 then cif.Debt_rating when 2 then cif.Debt_rating2 when 3 then cif.Debt_rating3
			when 4 then cif.Debt_rating4 when 5 then cif.Debt_rating5 when 6 then cif.Risk_rating when 7 then sdv.value_id
			when 8 then sdv.value_id
		end, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,''' + @as_of_date + '''), 0) )
	 ) * -1 d_cva_with_collateral,
	SUM(src.d_effective_exposure_to_them *
	CASE WHEN COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) = 8 THEN
	(1 - EXP(- (ISNULL(dbo.FNAGetProbabilityDefault(COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id), DATEDIFF(month,src.term_start,''' + @as_of_date + ''') , + ''' + @as_of_date + '''), 0) / 10000)
		/ (1 - ISNULL(dbo.FNAGetRecoveryRate(COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id), DATEDIFF(month,src.term_start,'''+ @as_of_date + ''') ,''' + @as_of_date + '''), 0)) 
		* (DATEDIFF(day, ''' + @as_of_date + ''', src.term_start) / CAST(365 AS FLOAT))))
	ELSE 
	ISNULL(dbo.FNAGetProbabilityDefault(
		CASE COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) 
			WHEN 1 THEN COALESCE(cif1.Debt_rating, cif2.Debt_rating, cif3.Debt_rating, cif4.Debt_rating) 
			WHEN 2 THEN COALESCE(cif1.Debt_rating2, cif2.Debt_rating2, cif3.Debt_rating2, cif4.Debt_rating2) 
			WHEN 3 THEN COALESCE(cif1.Debt_rating3, cif2.Debt_rating3, cif3.Debt_rating3, cif4.Debt_rating3)
			WHEN 4 THEN COALESCE(cif1.Debt_rating4, cif2.Debt_rating4, cif3.Debt_rating4, cif4.Debt_rating4)
			WHEN 5 THEN COALESCE(cif1.Debt_rating5, cif2.Debt_rating5, cif3.Debt_rating5, cif4.Debt_rating5) 
			WHEN 6 THEN COALESCE(cif1.Risk_rating, cif2.Risk_rating, cif3.Risk_rating, cif4.Risk_rating)
			WHEN 7 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
		END, DATEDIFF(month,src.term_start, ''' + @as_of_date + ''') , ''' + @as_of_date + '''), 0)
	END	
		* ( 1 - ISNULL(dbo.FNAGetRecoveryRate(
		CASE COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) 
			WHEN 1 THEN COALESCE(cif1.Debt_rating, cif2.Debt_rating, cif3.Debt_rating, cif4.Debt_rating) 
			WHEN 2 THEN COALESCE(cif1.Debt_rating2, cif2.Debt_rating2, cif3.Debt_rating2, cif4.Debt_rating2) 
			WHEN 3 THEN COALESCE(cif1.Debt_rating3, cif2.Debt_rating3, cif3.Debt_rating3, cif4.Debt_rating3)
			WHEN 4 THEN COALESCE(cif1.Debt_rating4, cif2.Debt_rating4, cif3.Debt_rating4, cif4.Debt_rating4)
			WHEN 5 THEN COALESCE(cif1.Debt_rating5, cif2.Debt_rating5, cif3.Debt_rating5, cif4.Debt_rating5) 
			WHEN 6 THEN COALESCE(cif1.Risk_rating, cif2.Risk_rating, cif3.Risk_rating, cif4.Risk_rating)
			WHEN 7 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
			WHEN 8 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
		END, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,''' + @as_of_date + '''), 0) )
	 ) * -1 d_dva_with_collateral,'
	 
	 set @st12 ='sum(net_exposure_to_us*
	CASE WHEN ISNULL(cif.cva_data, 1) = 8 THEN
	 (1 - EXP(- (ISNULL(dbo.FNAGetProbabilityDefault(sdv.value_id, DATEDIFF(month,src.term_start, ''' + @as_of_date + ''') ,+''' + @as_of_date + '''), 0) / 10000)
		/ (1 - ISNULL(dbo.FNAGetRecoveryRate(sdv.value_id, DATEDIFF(month, src.term_start,''' + @as_of_date + '''), ''' + @as_of_date + '''), 0)) 
		* (DATEDIFF(day, ''' + @as_of_date + ''', src.term_start) / CAST(365 AS FLOAT))))  
	ELSE 
	 ISNULL(dbo.FNAGetProbabilityDefault(case isnull(cif.cva_data,1) when 1 then cif.Debt_rating when 2 then cif.Debt_rating2 when 3 then cif.Debt_rating3
			when 4 then cif.Debt_rating4 when 5 then cif.Debt_rating5 when 6 then cif.Risk_rating when 7 then sdv.value_id 
		end, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,+''' + @as_of_date + '''), 0)
	END	
		* ( 1 - ISNULL(dbo.FNAGetRecoveryRate(
		case isnull(cif.cva_data,1) when 1 then cif.Debt_rating when 2 then cif.Debt_rating2 when 3 then cif.Debt_rating3
			when 4 then cif.Debt_rating4 when 5 then cif.Debt_rating5 when 6 then cif.Risk_rating when 7 then sdv.value_id
			when 8 then sdv.value_id
		end, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,''' + @as_of_date + '''), 0) )
	 ) * -1 cva,


	SUM(src.net_exposure_to_them *
	CASE WHEN COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) = 8 THEN
		(1 - EXP(- (ISNULL(dbo.FNAGetProbabilityDefault(COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id), DATEDIFF(month,src.term_start,''' + @as_of_date + ''') , + ''' + @as_of_date + '''), 0) / 10000)
		/ (1 - ISNULL(dbo.FNAGetRecoveryRate(COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id), DATEDIFF(month,src.term_start,'''+ @as_of_date + ''') ,''' + @as_of_date + '''), 0)) 
		* (DATEDIFF(day, ''' + @as_of_date + ''', src.term_start) / CAST(365 AS FLOAT))))
	ELSE 
	ISNULL(dbo.FNAGetProbabilityDefault(
		CASE COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) 
			WHEN 1 THEN COALESCE(cif1.Debt_rating, cif2.Debt_rating, cif3.Debt_rating, cif4.Debt_rating) 
			WHEN 2 THEN COALESCE(cif1.Debt_rating2, cif2.Debt_rating2, cif3.Debt_rating2, cif4.Debt_rating2) 
			WHEN 3 THEN COALESCE(cif1.Debt_rating3, cif2.Debt_rating3, cif3.Debt_rating3, cif4.Debt_rating3)
			WHEN 4 THEN COALESCE(cif1.Debt_rating4, cif2.Debt_rating4, cif3.Debt_rating4, cif4.Debt_rating4)
			WHEN 5 THEN COALESCE(cif1.Debt_rating5, cif2.Debt_rating5, cif3.Debt_rating5, cif4.Debt_rating5) 
			WHEN 6 THEN COALESCE(cif1.Risk_rating, cif2.Risk_rating, cif3.Risk_rating, cif4.Risk_rating)
			WHEN 7 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
		END, DATEDIFF(month, src.term_start, ''' + @as_of_date + ''') , ''' + @as_of_date + '''), 0)
	END	
		* ( 1 - ISNULL(dbo.FNAGetRecoveryRate(
		CASE COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) 
			WHEN 1 THEN COALESCE(cif1.Debt_rating, cif2.Debt_rating, cif3.Debt_rating, cif4.Debt_rating) 
			WHEN 2 THEN COALESCE(cif1.Debt_rating2, cif2.Debt_rating2, cif3.Debt_rating2, cif4.Debt_rating2) 
			WHEN 3 THEN COALESCE(cif1.Debt_rating3, cif2.Debt_rating3, cif3.Debt_rating3, cif4.Debt_rating3)
			WHEN 4 THEN COALESCE(cif1.Debt_rating4, cif2.Debt_rating4, cif3.Debt_rating4, cif4.Debt_rating4)
			WHEN 5 THEN COALESCE(cif1.Debt_rating5, cif2.Debt_rating5, cif3.Debt_rating5, cif4.Debt_rating5) 
			WHEN 6 THEN COALESCE(cif1.Risk_rating, cif2.Risk_rating, cif3.Risk_rating, cif4.Risk_rating)
			WHEN 7 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
			WHEN 8 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
		END, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,''' + @as_of_date + '''), 0) )
	 ) * -1 dva, 
	 
	 
	 getdate() create_ts,''' + @user_name + ''' create_user,fs.Counterparty_id,sum(sdp1.und_pnl) Final_Und_Pnl,max(src.currency_name) currency_name,
	 
	sum(d_net_exposure_to_us*
	CASE WHEN ISNULL(cif.cva_data, 1) = 8 THEN
	 (1 - EXP(- (ISNULL(dbo.FNAGetProbabilityDefault(sdv.value_id, DATEDIFF(month,src.term_start, ''' + @as_of_date + ''') ,+''' + @as_of_date + '''), 0) / 10000)
		/ (1 - ISNULL(dbo.FNAGetRecoveryRate(sdv.value_id, DATEDIFF(month, src.term_start,''' + @as_of_date + '''), ''' + @as_of_date + '''), 0)) 
		* (DATEDIFF(day, ''' + @as_of_date + ''', src.term_start) / CAST(365 AS FLOAT))))  
	ELSE 
	 ISNULL(dbo.FNAGetProbabilityDefault(case isnull(cif.cva_data,1) when 1 then cif.Debt_rating when 2 then cif.Debt_rating2 when 3 then cif.Debt_rating3
			when 4 then cif.Debt_rating4 when 5 then cif.Debt_rating5 when 6 then cif.Risk_rating when 7 then sdv.value_id 
		end, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,+''' + @as_of_date + '''), 0)
	END	
		* ( 1 - ISNULL(dbo.FNAGetRecoveryRate(
		case isnull(cif.cva_data,1) when 1 then cif.Debt_rating when 2 then cif.Debt_rating2 when 3 then cif.Debt_rating3
			when 4 then cif.Debt_rating4 when 5 then cif.Debt_rating5 when 6 then cif.Risk_rating when 7 then sdv.value_id
			when 8 then sdv.value_id
		end, DATEDIFF(month,src.term_start,''' + @as_of_date + ''') ,''' + @as_of_date + '''), 0) )
	 ) * -1 d_cva, '
	 
	SET @st11 = @st12 + '
	sum(src.d_net_exposure_to_them *
	CASE WHEN COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) = 8 THEN
	(1 - EXP(- (ISNULL(dbo.FNAGetProbabilityDefault(COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1), DATEDIFF(month,src.term_start,''' + @as_of_date + ''') , + ''' + @as_of_date + '''), 0) / 10000)
		/ (1 - ISNULL(dbo.FNAGetRecoveryRate(COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1), DATEDIFF(month,src.term_start,'''+ @as_of_date + ''') ,''' + @as_of_date + '''), 0)) 
		* (DATEDIFF(day, ''' + @as_of_date + ''', src.term_start) / CAST(365 AS FLOAT))))
	ELSE 
	ISNULL(dbo.FNAGetProbabilityDefault(
		CASE COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) 
			WHEN 1 THEN COALESCE(cif1.Debt_rating, cif2.Debt_rating, cif3.Debt_rating, cif4.Debt_rating) 
			WHEN 2 THEN COALESCE(cif1.Debt_rating2, cif2.Debt_rating2, cif3.Debt_rating2, cif4.Debt_rating2) 
			WHEN 3 THEN COALESCE(cif1.Debt_rating3, cif2.Debt_rating3, cif3.Debt_rating3, cif4.Debt_rating3)
			WHEN 4 THEN COALESCE(cif1.Debt_rating4, cif2.Debt_rating4, cif3.Debt_rating4, cif4.Debt_rating4)
			WHEN 5 THEN COALESCE(cif1.Debt_rating5, cif2.Debt_rating5, cif3.Debt_rating5, cif4.Debt_rating5) 
			WHEN 6 THEN COALESCE(cif1.Risk_rating, cif2.Risk_rating, cif3.Risk_rating, cif4.Risk_rating)
			WHEN 7 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
		END, DATEDIFF(month, src.term_start, ''' + @as_of_date + ''') , ''' + @as_of_date + '''), 0)
	END	
		* ( 1 - ISNULL(dbo.FNAGetRecoveryRate(
		CASE COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) 
			WHEN 1 THEN COALESCE(cif1.Debt_rating, cif2.Debt_rating, cif3.Debt_rating, cif4.Debt_rating) 
			WHEN 2 THEN COALESCE(cif1.Debt_rating2, cif2.Debt_rating2, cif3.Debt_rating2, cif4.Debt_rating2) 
			WHEN 3 THEN COALESCE(cif1.Debt_rating3, cif2.Debt_rating3, cif3.Debt_rating3, cif4.Debt_rating3)
			WHEN 4 THEN COALESCE(cif1.Debt_rating4, cif2.Debt_rating4, cif3.Debt_rating4, cif4.Debt_rating4)
			WHEN 5 THEN COALESCE(cif1.Debt_rating5, cif2.Debt_rating5, cif3.Debt_rating5, cif4.Debt_rating5) 
			WHEN 6 THEN COALESCE(cif1.Risk_rating, cif2.Risk_rating, cif3.Risk_rating, cif4.Risk_rating)
			WHEN 7 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
			WHEN 8 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
		END, DATEDIFF(month, src.term_start, ''' + @as_of_date + ''') , ''' + @as_of_date + '''), 0) )
	 ) * -1 d_dva, 
	 
	sum(sdp1.dis_pnl) Dis_Final_Und_Pnl,
	
	SUM(dbo.FNAGetProbabilityDefault(
		CASE COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) 
			WHEN 1 THEN COALESCE(cif1.Debt_rating, cif2.Debt_rating, cif3.Debt_rating, cif4.Debt_rating) 
			WHEN 2 THEN COALESCE(cif1.Debt_rating2, cif2.Debt_rating2, cif3.Debt_rating2, cif4.Debt_rating2) 
			WHEN 3 THEN COALESCE(cif1.Debt_rating3, cif2.Debt_rating3, cif3.Debt_rating3, cif4.Debt_rating3)
			WHEN 4 THEN COALESCE(cif1.Debt_rating4, cif2.Debt_rating4, cif3.Debt_rating4, cif4.Debt_rating4)
			WHEN 5 THEN COALESCE(cif1.Debt_rating5, cif2.Debt_rating5, cif3.Debt_rating5, cif4.Debt_rating5) 
			WHEN 6 THEN COALESCE(cif1.Risk_rating, cif2.Risk_rating, cif3.Risk_rating, cif4.Risk_rating)
			WHEN 7 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
			WHEN 8 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
		END, DATEDIFF(month,src.term_start, ''' + @as_of_date + ''') , ''' + @as_of_date + ''')) probability,
		
	SUM(dbo.FNAGetRecoveryRate(
		CASE COALESCE(cif1.cva_data, cif2.cva_data, cif3.cva_data, cif4.cva_data, 1) 
			WHEN 1 THEN COALESCE(cif1.Debt_rating, cif2.Debt_rating, cif3.Debt_rating, cif4.Debt_rating) 
			WHEN 2 THEN COALESCE(cif1.Debt_rating2, cif2.Debt_rating2, cif3.Debt_rating2, cif4.Debt_rating2) 
			WHEN 3 THEN COALESCE(cif1.Debt_rating3, cif2.Debt_rating3, cif3.Debt_rating3, cif4.Debt_rating3)
			WHEN 4 THEN COALESCE(cif1.Debt_rating4, cif2.Debt_rating4, cif3.Debt_rating4, cif4.Debt_rating4)
			WHEN 5 THEN COALESCE(cif1.Debt_rating5, cif2.Debt_rating5, cif3.Debt_rating5, cif4.Debt_rating5) 
			WHEN 6 THEN COALESCE(cif1.Risk_rating, cif2.Risk_rating, cif3.Risk_rating, cif4.Risk_rating)
			WHEN 7 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
			WHEN 8 THEN COALESCE(sdv1.value_id, sdv2.value_id, sdv3.value_id, sdv4.value_id)
		END, DATEDIFF(month, src.term_start, ''' + @as_of_date + '''), ''' + @as_of_date + ''')) recovery,

	MAX(src.internal_counterparty_id) internal_counterparty_id'

SET @st2 = '					
	from source_deal_pnl sdp
	INNER JOIN dbo.credit_exposure_detail src ON sdp.pnl_as_of_date = src.as_of_date
		and sdp.source_deal_header_id = src.source_deal_header_id
		and sdp.pnl_source_value_id = src.curve_source_value_id
		and sdp.term_start = src.term_start
	left join source_deal_pnl sdp1 ON sdp1.pnl_as_of_date = src.as_of_date
		and sdp1.source_deal_header_id = src.source_deal_header_id
		and sdp1.pnl_source_value_id = src.curve_source_value_id
		and sdp1.term_start = src.term_start
		and src.exp_type_id in (1,2)
	inner join source_counterparty sc on src.Source_Counterparty_ID=sc.Source_Counterparty_ID
	 inner join counterparty_credit_info cif on src.Source_Counterparty_ID=cif.Counterparty_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=src.source_deal_header_id
	left join source_system_book_map ssbm on sdh.source_system_book_id1 = ssbm.source_system_book_id1
						AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
						AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
						AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
	left JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=ssbm.fas_book_id
	left JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
	left JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
	left join fas_subsidiaries fs on sb.entity_id=fs.fas_subsidiary_id
	left join counterparty_credit_info cif_d on src.Source_Counterparty_ID=cif_d.Counterparty_id
	--left join counterparty_credit_info cif_d1 on src.internal_counterparty_id=cif_d1.Counterparty_id	 	
	left join static_data_value sdv on sdv.code=sc.counterparty_id and sdv.type_id=23000 and isnull(cif.cva_data,1)=7
	left join source_counterparty sc_d on fs.Counterparty_id=sc_d.Source_Counterparty_ID
	--left join static_data_value sdv_d on sdv_d.code=sc_d.counterparty_id 
	--	and sdv_d.type_id=23000 
	--	and isnull(cif_d.cva_data,1)=7

	--Debt Rating Enhancement
	LEFT JOIN counterparty_credit_enhancements cce ON cce.counterparty_credit_info_id = cif.counterparty_credit_info_id
		AND cce.is_primary = 1  
	LEFT JOIN source_system_book_map ssbm1 ON ssbm1.book_deal_type_map_id = sdh.sub_book

	LEFT JOIN counterparty_credit_info cif1 ON cif1.counterparty_id = cce.guarantee_counterparty
	LEFT JOIN counterparty_credit_info cif2 ON cif2.counterparty_id = sdh.internal_counterparty
	LEFT JOIN counterparty_credit_info cif3 ON cif3.counterparty_id = ssbm1.primary_counterparty_id
	LEFT JOIN counterparty_credit_info cif4 ON cif4.counterparty_id = fs.counterparty_id

	LEFT JOIN static_data_value sdv1 ON sdv1.code = [dbo].[FNAGetCounterpartyName](cce.guarantee_counterparty)
		AND sdv1.type_id = 23000 
		AND ISNULL(cif1.cva_data,1) = 7
	LEFT JOIN static_data_value sdv2 ON sdv2.code = [dbo].[FNAGetCounterpartyName](sdh.internal_counterparty)
		AND sdv2.type_id = 23000 
		AND ISNULL(cif2.cva_data,1) = 7
	LEFT JOIN static_data_value sdv3 ON sdv3.code = [dbo].[FNAGetCounterpartyName](ssbm1.primary_counterparty_id)
		AND sdv3.type_id = 23000 
		AND ISNULL(cif3.cva_data,1) = 7
	LEFT JOIN static_data_value sdv4 ON sdv4.code = [dbo].[FNAGetCounterpartyName](fs.counterparty_id)  
		AND sdv4.type_id = 23000 
		AND ISNULL(cif4.cva_data,1) = 7

	where '+ @st+ '
	group by src.Source_Counterparty_ID,src.term_start,src.curve_source_value_id,src.source_deal_header_id,fs.Counterparty_id
'
end

exec spa_print @st1

IF @st11 IS NOT NULL
	exec spa_print @st11
	
exec spa_print @st2

IF @st11 IS NOT NULL
BEGIN
	exec(@st1 + @st11 +@st2)	
END
ELSE
BEGIN
	exec(@st1 + @st2)
END

  
IF (SELECT COUNT(source_counterparty_id) FROM #source_deal_cva) < 1
BEGIN
    INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
    SELECT @batch_process_id,'Error','CVA.Calculation','CVA Calculation','data_not_found','Exposure is not found.','Please check data.'
    RAISERROR ('CatchError', 16, 1)
END

SELECT @count = COUNT(item) FROM dbo.SplitCommaSeperatedValues(@counterparty_ids)
SELECT @total = COUNT(DISTINCT Source_Counterparty_ID) FROM #source_deal_cva
SELECT @warning = COUNT(DISTINCT source_counterparty_id) FROM #source_deal_cva WHERE probability IS NULL OR recovery IS NULL OR rating_id IS NULL

SELECT @failure = @count-@total

IF @failure > 0
BEGIN
	SET @counterparty_name = NULL
	SELECT @counterparty_name = COALESCE(@counterparty_name + ', ','') + replace(sc.counterparty_name, '''', '') 
	FROM dbo.SplitCommaSeperatedValues(@counterparty_ids) mc
    INNER JOIN source_counterparty sc ON mc.item = sc.source_counterparty_id
    WHERE NOT EXISTS(SELECT DISTINCT sdc.source_counterparty_id FROM #source_deal_cva sdc WHERE sdc.Source_Counterparty_ID = mc.item)
  
	INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
    SELECT @batch_process_id,'Error','CVA.Calculation','CVA Calculation','data_not_found','Exposure is not found for the Counterprty(s):' + @counterparty_name + '.',
    'Please check data.'
END

SET @counterparty_name = NULL
SELECT @counterparty_name = COALESCE(@counterparty_name + ', ','')+ sc.counterparty_name
from  (
select distinct Source_Counterparty_ID from  #source_deal_cva where dva_Counterparty_ID is null
) s inner join source_counterparty sc on s.Source_Counterparty_ID=sc.source_counterparty_id

IF @counterparty_name IS NOT NULL
INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
    SELECT @batch_process_id,'Error','CVA.Calculation','CVA Calculation','rating_not_found','Primary counterprty is not found for the Counterprty(s):' + @counterparty_name +'.','Please check data.'


delete  #source_deal_cva where dva_Counterparty_ID is null


--SET @counterparty_name = NULL
--SELECT @counterparty_name = COALESCE(@counterparty_name + ', ','')+ sc.counterparty_name
--from  (
--select distinct Source_Counterparty_ID from  #source_deal_cva where rating_id is null
--) s inner join source_counterparty sc on s.Source_Counterparty_ID=sc.source_counterparty_id

--IF @counterparty_name IS NOT NULL
--INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
--    SELECT @batch_process_id,'Error','CVA.Calculation','CVA Calculation','rating_not_found','Risk/Debt rating is not defined for the Counterprty(s):' + @counterparty_name +'.','Please check data.'

--delete  #source_deal_cva where rating_id is null

SET @counterparty_name = NULL
SELECT @counterparty_name = COALESCE(@counterparty_name + ', ','')+ sc.counterparty_name
from  (
select distinct Source_Counterparty_ID from  #source_deal_cva where cva is null or dva is null
) s inner join source_counterparty sc on s.Source_Counterparty_ID=sc.source_counterparty_id

IF @counterparty_name IS NOT NULL
INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
    SELECT @batch_process_id,'Error','CVA.Calculation','CVA Calculation','rating_not_found','Risk/Debt rating is not found for the Counterprty(s):' + @counterparty_name +'.','Please check data.'

delete  #source_deal_cva where cva is null or dva is null

--Checked for probability and recovery rate

--Messaging Enhanced
SET @counterparty_name = NULL
SELECT @counterparty_name = COALESCE(@counterparty_name + ', ','')+ sc.counterparty_name
from  (
select distinct Source_Counterparty_ID from  #source_deal_cva where probability is null or recovery is null
) s inner join source_counterparty sc on s.Source_Counterparty_ID=sc.source_counterparty_id

IF @counterparty_name IS NOT NULL
INSERT INTO fas_eff_ass_test_run_log(process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
    SELECT @batch_process_id,'Warning','CVA.Calculation','CVA Calculation','rating_not_found','Risk/Debt rating is not found for the Counterprty(s):' + Cast(@counterparty_name AS VARCHAR(MAX)) +'.','Please check data.'


if ISNULL(@use_simulated_exposures,'n')='y'
begin

	insert into dbo.source_deal_cva_simulation
	(
		run_date,as_of_date,Source_Counterparty_ID, source_deal_header_id, term_start,rating_id, curve_source_value_id ,exposure_to_us,exposure_to_them,	
		d_exposure_to_us,d_exposure_to_them,
		effective_exposure_to_us,effective_exposure_to_them,
		d_effective_exposure_to_us,d_effective_exposure_to_them,
		cva_with_collateral,dva_with_collateral,
		d_cva_with_collateral,d_dva_with_collateral,		
		cva,dva ,create_ts,create_user
	) 
	select run_date,as_of_date,Source_Counterparty_ID, source_deal_header_id, term_start,rating_id, curve_source_value_id ,exposure_to_us,exposure_to_them,
			d_exposure_to_us,d_exposure_to_them,
			effective_exposure_to_us,effective_exposure_to_them,
			d_effective_exposure_to_us,d_effective_exposure_to_them,
			cva_with_collateral,dva_with_collateral,
			d_cva_with_collateral,d_dva_with_collateral,
			cva,dva ,create_ts,create_user 
	from #source_deal_cva

end
else 
BEGIN
	
	--calculating and updating credit_adjustment_mtm, adjusted_discounted_mtm
	--SELECT * FROM #source_deal_cva
	UPDATE cdc SET 
		credit_adjustment_mtm = Final_Und_Pnl + (cva + dva), 
		adjusted_discounted_mtm = Dis_Final_Und_Pnl + (d_cva + d_dva) 
	FROM #source_deal_cva cdc
	
	insert into dbo.source_deal_cva
	(
		as_of_date,Source_Counterparty_ID,source_deal_header_id,term_start,rating_id, curve_source_value_id 
		,exposure_to_us,exposure_to_them,		
		d_exposure_to_us,d_exposure_to_them,
		effective_exposure_to_us,effective_exposure_to_them,
		d_effective_exposure_to_us,d_effective_exposure_to_them,
		cva_with_collateral,dva_with_collateral,
		d_cva_with_collateral,d_dva_with_collateral,	
		cva,dva ,create_ts,create_user,Final_Und_Pnl,currency_name, d_cva, d_dva, credit_adjustment_mtm, adjusted_discounted_mtm,dva_counterparty_id
	)
	select as_of_date,Source_Counterparty_ID,source_deal_header_id,term_start,rating_id, curve_source_value_id 
		,exposure_to_us,exposure_to_them,		
		d_exposure_to_us,d_exposure_to_them,
		effective_exposure_to_us,effective_exposure_to_them,
		d_effective_exposure_to_us,d_effective_exposure_to_them,
		cva_with_collateral,dva_with_collateral,
		d_cva_with_collateral,d_dva_with_collateral,		
		cva,dva ,create_ts,create_user,Final_Und_Pnl ,currency_name, d_cva, d_dva, credit_adjustment_mtm, adjusted_discounted_mtm ,internal_counterparty_id
	from #source_deal_cva
END

EXEC spa_print 'finish CVA Calculation'
-- select dbo.FNAUserDateFormat(@as_of_date, @user_name) ,@as_of_date, @user_name

if exists(select 1 from fas_eff_ass_test_run_log where process_id=@batch_process_id and code='Error')
	SET @errorcode = 'e'
if exists(select 1 from fas_eff_ass_test_run_log where process_id=@batch_process_id and code='Warning')	
	SET @errorcode = 'w'
else
	SET @errorcode = 's'

SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name +
	       '&spa=exec spa_fas_eff_ass_test_run_log ''' + @batch_process_id +''''
	       
SET @desc = 'CVA Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) 
+case when @errorcode='e' then ' (ERRORS found)' WHEN @errorcode='w' THEN ' (Warnings found)' else '' end+ '.'
	       

END TRY
		
BEGIN CATCH
	EXEC spa_print 'Catch Error'
	IF @@TRANCOUNT > 0
	    ROLLBACK
	
	EXEC spa_print @batch_process_id
	SET @errorcode = 'e'
	--EXEC spa_print ERROR_LINE()
	IF ERROR_MESSAGE() = 'CatchError'
	BEGIN
	    SET @desc = 'CVA Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) 
	        + ' (ERRORS found).'
	    
	    EXEC spa_print @desc
	END
	ELSE
	BEGIN
	    SET @desc = 
	        'CVA Calculation critical error found ( Errr Description:' + 
	        ERROR_MESSAGE() + '; Line no: ' + CAST(ERROR_LINE() AS VARCHAR) 
	        + ').'
	    
	    EXEC spa_print @desc
	END
	
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name +'&spa=exec spa_fas_eff_ass_test_run_log ''' + @batch_process_id + ''''
	
END CATCH

SET @url_desc = ''
 
--IF @errorcode = 'e'
--BEGIN
--    SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'
    
--    SET @url_desc = '<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log ''' + @batch_process_id + '''">Click here...</a>'
    
--    SELECT 'Error' ErrorCode,
--          'CVA.Calculation' MODULE,
--           'spa_calc_CVA' Area,
--           'DB Error' STATUS,
--           'CVA Calculation completed with error, Please view this report.'
--           + @url_desc MESSAGE,
--           '' Recommendation
--END
--ELSE
--BEGIN
--    SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'
    
--    EXEC spa_ErrorHandler 0,
--         'CVA.Calculation',
--         'CVA_Calculation',
--         'Success',
--         @desc,
--         ''
--END

if @errorcode IN('e', 'w')
BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'

	IF @count > 0
	BEGIN
		set @msg_desc = 'CVA Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) +
		'  <b> Total Counterparty Processed</b>: (' + CAST(@count AS VARCHAR) + ')  <b>Error Count</b>: (' +
		 CAST(@failure AS VARCHAR)  + ') <b>Warning Count</b>: (' + CAST(@warning AS VARCHAR) + ').'
	 
		INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
		SELECT @batch_process_id,'Success','CVA.Calculation','CVA Calculation','Run CVA', @msg_desc, ''
	END
END
	
EXEC spa_message_board 'i',
     @user_name,
     NULL,
     CVA_Calculation,
     @desc,
     '',
     '',
     @errorcode,
     @batch_process_id
