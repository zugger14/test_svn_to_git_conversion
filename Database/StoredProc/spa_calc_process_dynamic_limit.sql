
if OBJECT_ID('spa_calc_process_dynamic_limit') is not null
drop proc spa_calc_process_dynamic_limit
go
---exec spa_calc_process_dynamic_limit '2','2012-01-01'
create proc [dbo].[spa_calc_process_dynamic_limit] @fas_sub_ids varchar(1000),@as_of_date varchar(10)
	--de-designation parameter
	,@sort_order varchar(1)='l'
	,@dedesignate_type INT=451

	--auto matching criteria parameter
	,@FIFO_LIFO VARCHAR(1)='l'
	,@slicing_first VARCHAR(1)='i' --h:first slicing hedge, i:first slicing item
	,@perform_dicing VARCHAR(1)='n' 
	,@h_or_i VARCHAR(1)='b'
	,@v_buy_sell VARCHAR(1)='a'
	,@slice_option VARCHAR(1)='i' --m=multi;h=hedge one, i=item one
	,@only_include_external_der VARCHAR(1)='y' 
	,@externalization VARCHAR(1)='n'
	,@book_map_ids varchar(max)=null
	,@deal_dt_option varchar(1)='h' --i: i_dt>=h_dt;  h:h_dt>=i_dt;  a: not apply filter or ignor deal date filter

	,@user_login_id varchar(30) = NULL
	,@process_id varchar(250)=null
	,@call_from varchar(3)='UK' -- u=uk, g=german

AS

/*

--select * from dedesignation_criteria
--select * from dedesignation_criteria_result
	--select CAST(entity_id as varchar) from portfolio_hierarchy	where entity_name in('RWEST UK','RWEST Participations','RWE Trading Services')
--exec dbo.spa_calc_process_dynamic_limit '35','2012-1-1',null,'farrms_admin',NULL
--need to be done
--Volume convertion
--Automatching proposed link

declare 
@fas_sub_ids varchar(1000)='197,198,199',@as_of_date varchar(10)='2012-12-31'
--de-designation parameter
,@sort_order varchar(1)='l'
,@dedesignate_type INT=451

--auto matching criteria parameter
,@FIFO_LIFO VARCHAR(1)='l'
,@slicing_first VARCHAR(1)='h' --h:first slicing hedge, i:first slicing item
,@perform_dicing VARCHAR(1)='n' 
,@h_or_i VARCHAR(1)='b'
,@v_buy_sell VARCHAR(1)='a'
,@slice_option VARCHAR(1)='i' --m=multi;h=hedge one, i=item one
,@only_include_external_der VARCHAR(1)='y' 
,@externalization VARCHAR(1)='n'
,@book_map_ids varchar(max)=null
,@deal_dt_option varchar(1)='h' --i: i_dt>=h_dt;  h:h_dt>=i_dt;  a: not apply filter or ignor deal date filter

,@user_login_id varchar(30) ='RE64582'
,@process_id varchar(250)='cccc'
,@call_from varchar(3)='UK'

--declare @fas_sub_ids varchar(1000)='2',@as_of_date varchar(10)='2012-01-02',@uom_id INT,@user_login_id varchar(30) ='farrms_admin'
--,@process_id varchar(250)


drop table #dedesignation_criteria_result
drop table #hedge_capacity_limit
drop table #tmp_dedesidnated_criteria
drop table #tmp_uder_limit_links
drop table #tmp_links 
drop table #hedge_under 
drop table #valid_link
drop table #hedge_deal
drop table #tmp_deals
drop table #used_percentage_limit

--*/

declare @fas_sub_id int,@fas_stra_id int,@fas_book_id int, @curve_id int,@term_start datetime,@term_end datetime
,@net_vol numeric(38,20),@de_criteria_id int,@row_id int,@buy_sell varchar(1),@entity_id int,@link_id int,@st varchar(max)


declare @abs_net_vol numeric(26,10),@used_vol numeric(26,10),@run_total numeric(26,10),@deal_volume numeric(26,10),@no_term int
declare @delta_per float,@link_deal_term_used_per varchar(250)


SET @user_login_id = ISNULL(@user_login_id , dbo.fnadbuser())

--dedegnation criteria parameter setting:
select 
	@sort_order =isnull(@sort_order,'l')
	,@dedesignate_type =isnull(@dedesignate_type,451)
--auto matching criteria parameter setting:
	,@slicing_first =isnull(@slicing_first,'h'), --h:first slicing hedge, i:first slicing item
	@perform_dicing =isnull(@perform_dicing,'n'), 
	@h_or_i =isnull(@h_or_i,'i'),
	@v_buy_sell =isnull(@v_buy_sell,'a'),
	@slice_option =isnull(@slice_option,'i'), --m=multi;h=hedge one, i=item one
	@only_include_external_der=isnull(@only_include_external_der,'n'), 
	@externalization =isnull(@externalization,'n'),
	@deal_dt_option =isnull(@deal_dt_option,'h'), --i: i_dt>=h_dt;  h:h_dt>=i_dt;  a: not apply filter or ignor deal date filter
	@FIFO_LIFO=ISNULL(@FIFO_LIFO,'l')

declare  @report_type varchar(1)='c',@summary_option varchar(1)='l'
	,@call_for_report VARCHAR(1)='l',@exception_flag char(1)='a'
	,@asset_type_id int = 402
	,@settlement_option char(1) = 'a'
	,@include_gen_tranactions char(1) = 'b'
	,@term_match_criteria varchar(1)='p'  --'w'
	,@dedesignate_frequency varchar(1)='t'
	,@dedesignate_look_in varchar(1) ='i'
	,@volume_split varchar(1)='y'
	,@dedesignate_buy_sell varchar(1)

DECLARE @url VARCHAR(500)
DECLARE @desc VARCHAR(500)
DECLARE @errorMsg VARCHAR(200)
DECLARE @errorcode VARCHAR(1)
DECLARE @url_desc VARCHAR(500)

declare @hedge_capacity   varchar(250), @sql varchar(max),@limit_chcking int

SELECT     @limit_chcking = var_value
FROM         adiha_default_codes_values
WHERE     (default_code_id = 86) AND (seq_no = 1) AND (instance_no = '1')		 


DECLARE @DE_participating_subsidiaries   VARCHAR(150)
set @DE_participating_subsidiaries='DE Participating Subsidiaries'


SELECT	cast([clm1_value] as int) AS sub_id   
INTO #DE_participating_subsidiaries
FROM generic_mapping_values  v INNER JOIN dbo.generic_mapping_header h ON  v.mapping_table_id=h.mapping_table_id
WHERE h.mapping_name = 'DE Participating Subsidiaries'


if @fas_sub_ids is null
	SELECT	@fas_sub_ids=isnull(@fas_sub_ids+',','')+ cast(sub_id as varchar) from  #DE_participating_subsidiaries


EXEC spa_print '@fas_sub_ids:', @fas_sub_ids


set @process_id=ISNULL(@process_id,dbo.fnagetnewid())
set @hedge_capacity= dbo.FNAProcessTableName('hedge_capacity', @user_login_id, @process_id)

if OBJECT_ID('tempdb..#used_percentage_limit') is null
	CREATE TABLE #used_percentage_limit (source_deal_header_id INT,term_start date,used_percentage FLOAT,link_end_date DATETIME)

CREATE TABLE #dedesignation_criteria_result 
(
	sno int 
	,link_id int 
	,recommended_per float
	,remaining_per float
	,available_per numeric(18,16)
	,effective_date varchar(10) COLLATE DATABASE_DEFAULT  
	,relationship_desc varchar(1000) COLLATE DATABASE_DEFAULT  
	,perfect_hedge varchar(1) COLLATE DATABASE_DEFAULT  
	,fas_book_id int
	,term_start  varchar(10) COLLATE DATABASE_DEFAULT 
	,term_end  varchar(10) COLLATE DATABASE_DEFAULT  
	,link_volume  numeric(30,10)
	,runing_total  numeric(30,10)
)

create table #hedge_capacity_limit(
	fas_sub_id int,
	fas_str_id int,
	fas_book_id int,
	curve_id int,
	fas_sub varchar(250) COLLATE DATABASE_DEFAULT ,
	fas_str varchar(250) COLLATE DATABASE_DEFAULT ,
	fas_book varchar(250) COLLATE DATABASE_DEFAULT ,
	IndexName varchar(250) COLLATE DATABASE_DEFAULT ,
	TenorBucket varchar(250) COLLATE DATABASE_DEFAULT ,
	TenorStart datetime,
	TenorEnd datetime,
	vol_frequency varchar(50) COLLATE DATABASE_DEFAULT ,
	vol_uom varchar(100) COLLATE DATABASE_DEFAULT,
	net_asset_vol numeric(38,20),
	net_item_vol numeric(38,20),
	net_available_vol numeric(38,20),
	over_hedge varchar(3) COLLATE DATABASE_DEFAULT ,net_vol numeric(26,10)
)
--exec spa_Create_Available_Hedge_Capacity_Exception_Report '2011-10-31','35', null, null,'c','l',null,'a'

--call hedge_capacity_report
SET @url_desc = '' 
declare @tmp_process_id varchar(150)
set @tmp_process_id='0001_'+@process_id


INSERT into #hedge_capacity_limit (fas_sub_id ,fas_str_id ,fas_book_id ,curve_id ,fas_sub ,fas_str ,fas_book ,IndexName ,
	TenorBucket,TenorStart ,TenorEnd  ,vol_frequency ,vol_uom ,net_asset_vol ,net_item_vol ,net_available_vol ,over_hedge)
EXEC spa_Create_Available_Hedge_Capacity_Exception_Report @as_of_date,@fas_sub_ids, null, null,@report_type,@summary_option,null,@exception_flag,@asset_type_id,@settlement_option,@include_gen_tranactions,'n',@call_from


if @@ROWCOUNT>0 
begin

	SET @errorcode='s'

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_hedge_capacity_report ''' + @fas_sub_ids + ''','''+@as_of_date +''','''+@call_from+''''

	SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
					'Hedge Capacity Exception Report for ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id) + 
				CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found)' ELSE '' END +
				'.</a>'
end
else
begin
	INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
		VALUES(@tmp_process_id,'Error', 'Limit.Hedge.Capacity', 'Hedge Capacity Exception',
		'Database Error','Hedge Capacity Exception data not found. ' , 'Please check data.')
		
	SET @errorcode='e'

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_fas_eff_ass_test_run_log ''' + @tmp_process_id + ''''

	SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
					'Hedge Capacity Exception Report for ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id) + 
				 ' (ERRORS found).</a>'
end


EXEC  spa_message_board 'i', @user_login_id,NULL, 'Limit.Hedge.Capacity',@desc, @url_desc, '', @errorcode, 'Limit.Hedge.Capacity',NULL, @tmp_process_id

if @errorcode='e'
return

exec('delete dbo.hedge_capacity_report where fas_sub_id in ('+@fas_sub_ids+') and as_of_date='''+@as_of_date+'''')

insert into dbo.hedge_capacity_report(
	as_of_date ,fas_sub_id ,fas_str_id ,fas_book_id ,curve_id ,fas_sub ,fas_str ,fas_book,
	IndexName ,TenorBucket ,term_start,term_end,vol_frequency,vol_uom,net_asset_vol,net_item_vol,net_available_vol ,over_hedge,create_ts,create_user
)
select @as_of_date ,fas_sub_id ,fas_str_id ,fas_book_id ,curve_id ,	fas_sub ,fas_str ,fas_book,IndexName ,
	TenorBucket,TenorStart ,TenorEnd,	vol_frequency,	vol_uom,net_asset_vol,	net_item_vol,net_available_vol ,over_hedge,GETDATE(),@user_login_id
from #hedge_capacity_limit

if @errorcode='e'
	return


update #hedge_capacity_limit set net_vol=abs(abs(isnull(net_asset_vol,0))-abs(isnull(net_item_vol,0)))	* case when isnull(net_asset_vol,0)<0 then -1 else 1 end	

--update #hedge_capacity_limit set net_vol=abs(isnull(net_asset_vol,0)-isnull(net_item_vol,0))

declare @tmp_tot_ded_vol numeric(26,10)

create table #tmp_dedesidnated_criteria (hedge_capacity_id int,de_criteria_id int,dedesignated_vol numeric(26,10))

EXEC spa_print '@@@@@@@@@@@@@@loop for over hedge @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

exec('delete dcr from dedesignation_criteria  dc inner join dedesignation_criteria_result dcr 
	on dc.dedesignation_criteria_id=dcr.dedesignation_criteria_id and dc.fas_sub_id in ('+@fas_sub_ids +') and dc.run_date='''+@as_of_date+'''')

exec('delete dedesignation_criteria where fas_sub_id in ('+@fas_sub_ids +') and run_date='''+@as_of_date+'''')

SET @url_desc = '' 
set @tmp_process_id='0002_'+@process_id


if exists (SELECT 1  FROM #hedge_capacity_limit where over_hedge='Yes' and round(net_vol,2)<>00)
begin

	--loop for over hedge
	DECLARE hedge_over CURSOR FOR 
	SELECT distinct fas_sub_id, curve_id,TenorStart ,dateadd(month,1,TenorEnd)-1 TenorEnd,net_vol,fas_str_id ,fas_book_id  FROM #hedge_capacity_limit where over_hedge='Yes' and round(net_vol,2)<>0
	order by fas_sub_id, curve_id,TenorStart ,4 desc
	OPEN hedge_over
	FETCH NEXT FROM hedge_over INTO @fas_sub_id, @curve_id,@term_start,@term_end ,@net_vol,@fas_stra_id ,@fas_book_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'

		EXEC spa_print '@fas_sub_id:', @fas_sub_id, ', @curve_id:', @curve_id, ',@term_start:', @term_start
		--print '@net_vol: ' +cast(@net_vol as varchar(max)) +',@fas_book_id:'+cast(@fas_book_id as varchar)
		set @dedesignate_buy_sell =case when @net_vol<0 then 'b' when @net_vol>0 then 's' else null end
		criteria_1:  --		@term_match_criteria='p'	

		set @term_match_criteria='p'
		--set @term_end=dateadd(month,1,@term_start)-1

		EXEC spa_print '3333333333333333333'
		--print 'exec spa_get_fifo_lifo_links ' + isnull(cast(@fas_sub_id as varchar),'null')+','+isnull(cast(@fas_stra_id as varchar),'null')
		--		 +','+ isnull(cast(@fas_book_id as varchar),'null')+','''+convert(varchar(10),@term_start,120)+''',''' +convert(varchar(10),@term_end,120)
		--		  +''',''' +@term_match_criteria +''',' +ltrim(str(@net_vol ,30,10))+',null,'''
		--					+@dedesignate_frequency+''',null,''' +@volume_split+''',''' +@sort_order+''',''' +@as_of_date+''',''' +@dedesignate_look_in+''',null,'''+@as_of_date+''''

		truncate table #dedesignation_criteria_result
		insert into #dedesignation_criteria_result exec spa_get_fifo_lifo_links @fas_sub_id,@fas_stra_id ,@fas_book_id,@term_start,@term_end
			,@term_match_criteria,@net_vol,null
					,@dedesignate_frequency,@curve_id,@volume_split,@sort_order,@as_of_date,@dedesignate_look_in,@dedesignate_buy_sell,@as_of_date


		if @@ROWCOUNT>0
			goto result_saving_process


		criteria_2: --@term_match_criteria='w'


		if exists( select 1 from #dedesignation_criteria_result) --check if data found on first criteria (criteria_1)
		begin
			select @tmp_tot_ded_vol=MAX(runing_total) from #dedesignation_criteria_result
				
			select @deal_volume=link_volume from #dedesignation_criteria_result where runing_total=@tmp_tot_ded_vol
			
			if round(abs(@net_vol),0)> @tmp_tot_ded_vol
				set @net_vol=abs(@net_vol)- @tmp_tot_ded_vol
			else 
				set @net_vol=0
		end
			
		if round(abs(@net_vol),0)<>0
		begin
			set @term_match_criteria='w'
/*
			EXEC spa_print 'exec spa_get_fifo_lifo_links ' + isnull(cast(@fas_sub_id as varchar),'null')+','+isnull(cast(@fas_stra_id as varchar),'null')
				 +','+ isnull(cast(@fas_book_id as varchar),'null')+','''+convert(varchar(10),@term_start,120)+''',''' +convert(varchar(10),@term_end,120)
				  +''',''' +@term_match_criteria +''',' +ltrim(str(@net_vol ,30,10))+',null'''
				  +@dedesignate_frequency+''',null,''' +@volume_split+''',''' +@sort_order+''',''' +@as_of_date+''',''' +@dedesignate_look_in+''',null,'''+@as_of_date+''''
*/

			truncate table #dedesignation_criteria_result
			insert into #dedesignation_criteria_result exec spa_get_fifo_lifo_links @fas_sub_id,@fas_stra_id ,@fas_book_id,@term_start,@term_end,@term_match_criteria,@net_vol,null
						,@dedesignate_frequency,@curve_id,@volume_split,@sort_order,@as_of_date,@dedesignate_look_in,null,@as_of_date
			
			if @@ROWCOUNT>0
				goto result_saving_process
				
		end 
		goto fetch_next_record  ---jump the process block( the instruction for the not matching both criteria)

		result_saving_process:  --this is common code for both criteria 
		 
		------------------------------------start result_saving_process-----------------------------------------------------------
		EXEC spa_print 'start result_saving_process'

		insert into  dedesignation_criteria (
			run_date,fas_sub_id,curve_id ,term_start,term_end ,term_match_criteria ,dedesignate_date
			 ,dedesignate_volume ,uom_id ,dedesignate_frequency 
			,sort_order,dedesignate_type ,dedesignate_look_in ,create_user,create_ts ,fas_stra_id ,fas_book_id ,volume_split
		)
		select @as_of_date,@fas_sub_id,@curve_id ,@term_start,dateadd(month,1,@term_start)-1 term_end ,@term_match_criteria ,@as_of_date
			,@net_vol ,null ,@dedesignate_frequency 
			,@sort_order,@dedesignate_type ,@dedesignate_look_in ,@user_login_id,GETDATE() ,@fas_stra_id ,@fas_book_id,@volume_split 

		set @de_criteria_id=SCOPE_IDENTITY()

			--exec spa_get_fifo_lifo_links '35',NULL,NULL,'2013-10-01','2013-10-31','p',74,null,'t',NULL,'y','f','2011-01-01','i', NULL

		insert into dedesignation_criteria_result 
		(
			dedesignation_criteria_id,link_id,recommended_per,available_per,effective_date,relationship_desc
			,perfect_hedge,term_start,link_volume,runing_total,create_user,create_ts,dedesignate_type
		) 
		select @de_criteria_id,link_id,recommended_per,available_per,dbo.FNAStdDate(effective_date) effective_date,relationship_desc
			,perfect_hedge,dbo.FNAStdDate(term_start) term_start,link_volume,runing_total,@user_login_id,GETDATE() create_ts,@dedesignate_type
		from #dedesignation_criteria_result

		if @term_match_criteria ='p'
			goto criteria_2 --to proceed @term_match_criteria ='w'
							
		------------------------------------end designation_process-----------------------------------------------------------


		fetch_next_record:

	FETCH NEXT FROM hedge_over INTO @fas_sub_id, @curve_id,@term_start,@term_end ,@net_vol,@fas_stra_id ,@fas_book_id
	END
	CLOSE hedge_over
	DEALLOCATE hedge_over
end


exec('select top 1 1 dt into #data_exist_check from dedesignation_criteria  where run_date='''+@as_of_date+''' and fas_sub_id in (' +@fas_sub_ids+')')
IF @@ROWCOUNT>0 
BEGIN

	SET @errorcode='s'
	BEGIN
		DECLARE @args VARCHAR(MAX)
		DECLARE @args2 VARCHAR(MAX)-- for tree structure
		
		/* added for multiple selection in tree start*/
		DECLARE @to_sub_select_ids VARCHAR(MAX)
		DECLARE @to_stra_select_ids VARCHAR(MAX)
		DECLARE @to_select_ids VARCHAR(MAX)
		
		SELECT @to_sub_select_ids = STUFF((
				SELECT ',' + CAST(f.item AS VARCHAR(10)) FROM dbo.FNASplit(@fas_sub_ids, ',') f
				INNER JOIN portfolio_hierarchy ph ON ph.entity_id = f.item 
				AND ph.hierarchy_level = 2 FOR XML PATH('')
			), 1, 1, '')
		
		SELECT @to_stra_select_ids = STUFF((
				SELECT ',' + CAST(f.item AS VARCHAR(10)) FROM dbo.FNASplit(@fas_sub_ids, ',') f
				INNER JOIN portfolio_hierarchy ph ON ph.entity_id = f.item 
				AND ph.hierarchy_level = 1
				FOR XML PATH('')
			), 1, 1, '')
			
		SELECT @to_select_ids = STUFF((
				SELECT ',' + CAST(f.item AS VARCHAR(10)) FROM dbo.FNASplit(@fas_sub_ids, ',') f
				INNER JOIN portfolio_hierarchy ph ON ph.entity_id = f.item 
				AND ph.hierarchy_level = 0
				FOR XML PATH('')
			), 1, 1, '') 		
		
		SET @args = '''' + CAST(@as_of_date AS VARCHAR(30)) + ''''   
		SET @args2 = ISNULL(@to_sub_select_ids, '') + '_' +  ISNULL(@to_stra_select_ids, '') + '_' +  ISNULL(@to_select_ids, '')--used _ to seperate hierarchy level
		/* added for multiple selection in tree start*/
		
		--SELECT @desc = dbo.FNAHyperLinkText(10242000,'Over Hedge De-designation is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id) + '.', @args)
		SELECT @desc = dbo.[FNAHyperLinkText3](10242000,'Over Hedge De-designation is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id) + '.', @args, @args2)
		
	END
END
ELSE
BEGIN
	INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
		VALUES(@tmp_process_id,'Error', 'Limit.De-designation', 'Limit.De-designation',
		'Database Error','De-designation data not found. ' , 'Please check data.')
		
	SET @errorcode='e'

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_fas_eff_ass_test_run_log ''' + @tmp_process_id + ''''

	SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
					'Over Hedge De-designation for ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id) + 
				 ' (ERRORS found).</a>'
end

EXEC  spa_message_board 'i', @user_login_id,NULL, 'Limit.De-designation',@desc, @url_desc, '', @errorcode, 'Limit.De-designation',NULL, @tmp_process_id
EXEC spa_print 'ooooooooooooooo'
--/*

EXEC spa_print '@@@@@@@@@@@@@@loop for under hedge @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

create table #tmp_uder_limit_links(ROWID INT IDENTITY(1,1),link_id int,deal_volume numeric(26,10),run_total  numeric(26,10),term_start datetime ,term_end datetime)

create table #tmp_links  (ROWID int identity(1,1),gen_link_id int,deal_number int ,used_vol numeric(26,12),d_vol numeric(26,12),d_date datetime)

create table #hedge_under (ROWID int identity(1,1),entity_id int,curve_id int,term_start datetime,term_end datetime, net_vol numeric(26,10),available_vol numeric(26,10))

create table #valid_link(link_id int)



insert into #hedge_under (entity_id ,curve_id ,term_start,term_end, net_vol ,available_vol)
SELECT fas_sub_id, curve_id ,TenorStart ,TenorEnd, sum(net_vol) net_vol,sum(net_vol) net_vol FROM #hedge_capacity_limit 
where over_hedge='No' and isnull(net_vol,0)<>0
group by fas_sub_id,curve_id ,TenorStart ,TenorEnd

set @fas_sub_id=null
set @fas_stra_id =null
set @entity_id=null


--loop for under hedge
DECLARE hedge_under_m CURSOR FOR 
	SELECT distinct entity_id, curve_id   FROM #hedge_under
OPEN hedge_under_m
FETCH NEXT FROM hedge_under_m INTO @entity_id, @curve_id ---,@term_start ,@net_vol
WHILE @@FETCH_STATUS = 0
BEGIN

	set @tmp_process_id=@process_id+'__'+right('000'+CAST(@entity_id as varchar),3)+'__'+right('0000'+CAST(@curve_id as varchar),4)
	EXEC spa_print @tmp_process_id


	set @hedge_capacity= dbo.FNAProcessTableName('hedge_capacity', @user_login_id, @tmp_process_id)

	
	if object_id(@hedge_capacity) is not null
		exec('drop table '+@hedge_capacity)
		
	set @st	='select *  into '+@hedge_capacity+ ' from #hedge_capacity_limit  where over_hedge=''No'' and isnull(net_vol,0)<>0 and fas_sub_id ='+CAST(@entity_id as varchar)+' and  curve_id='+CAST(@curve_id as varchar)
	exec(@st)

--- start generate link 
	/*exec spa_print 'exec [dbo].[spa_auto_matching_job] '''+	isnull(cast(@entity_id as varchar),'null' +''',null,null,''2000-01-01'','''+@as_of_date++''','''+@FIFO_LIFO+''','''+
			@slicing_first+''','''+	@perform_dicing+''','+isnull(cast(@curve_id as varchar),'null') +','''+@h_or_i+''','''+
			@v_buy_sell+''','''+@call_for_report+''','''+@slice_option +''','''+	@user_login_id+''','''+
			@only_include_external_der+''','''+	@externalization +''','''+@tmp_process_id +''',null,'''+@deal_dt_option+''',''y'','''+ isnull(@call_from ,'g')+'''')
*/
	exec dbo.spa_auto_matching_job @entity_id,null,null,'2000-01-01',@as_of_date,@FIFO_LIFO,@slicing_first,	@perform_dicing,@curve_id,@h_or_i,@v_buy_sell,
		@call_for_report,@slice_option ,@user_login_id,	@only_include_external_der, @externalization ,@tmp_process_id ,@book_map_ids,@deal_dt_option,'y',@call_from
		
----end generate link ----
	
	FETCH NEXT FROM hedge_under_m INTO @entity_id, @curve_id 
END
CLOSE hedge_under_m
DEALLOCATE hedge_under_m


SET @url_desc = '' 

if exists(select top 1 1 dt from gen_fas_link_header   where process_id like @process_id+'%')
begin

	SET @errorcode='s'
	SELECT @desc = dbo.FNAHyperLinkText(10234500,'Under Hedge auto-matching process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id)+'.',1)
end
else
begin
	INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
		VALUES(@tmp_process_id,'Error', 'Limit.Automatic', 'Limit.Automatic',
		'Database Error','Automatic data not found. ' , 'Please check data.')
		
	SET @errorcode='e'

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_fas_eff_ass_test_run_log ''' + @tmp_process_id + ''''

	SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
					'Under Hedge automatic for ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id) + 
				 ' (ERRORS found).</a>'
end

EXEC  spa_message_board 'i', @user_login_id,NULL, 'Limit.Automatic',@desc, @url_desc, '', @errorcode, 'Limit.Automatic',NULL, @tmp_process_id


if isnull(@call_from,'DE')='UK'
begin
	EXEC spa_print '*************************************************'
	EXEC spa_print 'start automation forecast transaction'
	EXEC spa_print '*************************************************'

	set @tmp_process_id='0003_'+@process_id
	
	exec dbo.spa_automation_forecasted_transaction @fas_sub_ids ,@as_of_date ,@tmp_process_id,@user_login_id ,'p'

	-------------------------------------------------------

	----if isnull(@limit_chcking,0)=1
	----begin
	--	EXEC spa_print '*************************************************'
	--	EXEC spa_print 'start call spa_auto_matching_limit_validation'
	--	EXEC spa_print '*************************************************'

	--	exec dbo.spa_auto_matching_limit_validation @as_of_date ,@user_login_id,@tmp_process_id,'y',@fas_sub_ids,@call_from


	--	EXEC spa_print '*************************************************'
	--	EXEC spa_print 'end call spa_auto_matching_limit_validation'
	--	EXEC spa_print '*************************************************'
	----end

end
