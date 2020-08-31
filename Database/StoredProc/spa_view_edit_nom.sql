IF OBJECT_ID(N'spa_view_edit_nom', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_view_edit_nom]
GO 

/**
	Script to view and edit nominatiom

	Parameters 
	@flag					: 'x' - used to view grid and sub grids
    @term_start				: 
    @term_end				: 
    @xml					: 
    @pipeline				: 
    @shipper				: 
    @contract_id			: 
    @process_id				: 
    @call_from				: 
    @source_deal_header_id	:  
    @receipt_delivery		: 
    @folder_path			: 
   			
*/

CREATE PROCEDURE [dbo].[spa_view_edit_nom]
	@flag CHAR(1),
	@term_start DATE = NULL,
	@term_end DATE = NULL,
	@xml varchar(4000) = NULL,
	@pipeline varchar(2000) = null,
	@shipper varchar(2000) = null,
	@contract_id varchar(2000) = null,
	@process_id varchar(100) = null,
	@call_from varchar(50) = null,
	@source_deal_header_id varchar(30) = null,
	@receipt_delivery varchar(100) = null,
	@folder_path VARCHAR(500) = NULL
AS
/*
declare 
@flag CHAR(1) = 'x',
	@term_start DATE = '2020-06-11',
	@term_end DATE = '2020-06-30',
	@xml varchar(4000) = NULL,
	@pipeline varchar(2000) = null,
	@shipper varchar(2000) = 10477,
	@contract_id varchar(2000) = NULL,
	@process_id varchar(100) = null,
	@call_from varchar(50) = null,
	@source_deal_header_id varchar(30) = null,
	@receipt_delivery varchar(100) = null,
	@folder_path VARCHAR(500) = NULL
--*/
SET NOCOUNT ON

DECLARE @date_range VARCHAR(1000)
DECLARE @sql VARCHAR(MAX)
declare @current_user varchar(100) = dbo.FNADBuser()
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT

set @process_id = isnull(@process_id, dbo.FNAGetNewID())
declare @tbl_grid_definition_info varchar(1000) = dbo.FNAProcessTableName('tbl_grid_definition_info', @current_user, @process_id)
declare @tbl_grid_data varchar(1000) = dbo.FNAProcessTableName('tbl_grid_data', @current_user, @process_id)
declare @tbl_sub_grid_data varchar(1000) = dbo.FNAProcessTableName('tbl_sub_grid_data', @current_user, @process_id)

if @flag = 'x'
begin
	/*
	EXEC spa_view_edit_nom  @flag='x',@term_start='2015-10-01',@term_end='2015-10-05',@pipeline=NULL,@shipper=5622,@contract_id=NULL
	EXEC spa_view_edit_nom @flag='y',@process_id='70E96173_867A_4A22_97B7_83459AD12323',@call_from='main_grid'
	EXEC spa_view_edit_nom  @call_from='sub_grid',@flag='y',@process_id='EC7AE2D1_EB62_4B36_856E_829C4B13F50A',@receipt_delivery='Rec',@source_deal_header_id='106752'
	*/

	--STORE DEAL UDF FIELD VALUES
	IF OBJECT_ID('tempdb..#deal_header_udf') IS NOT NULL 
		DROP TABLE #deal_header_udf
	select uddft.template_id, uddf.source_deal_header_id, uddft.udf_template_id, uddft.Field_label, uddf.udf_value
	into #deal_header_udf --select * from #deal_header_udf order by source_deal_header_id
	from user_defined_deal_fields_template uddft
	inner join source_deal_header_template sdht on sdht.template_id = uddft.template_id
	inner join user_defined_deal_fields uddf on uddf.udf_template_id = uddft.udf_template_id
	inner join source_deal_header sdh on sdh.source_deal_header_id = uddf.source_deal_header_id
	where 1=1 and uddft.Field_label IN ('Pipeline','Loss','Up Dn Party','From Deal')

	--STORE DEAL DETAIL UDF FIELD VALUES
	IF OBJECT_ID('tempdb..#deal_detail_udf') IS NOT NULL 
		DROP TABLE #deal_detail_udf
	SELECT  sdd.source_deal_detail_id,sdd.term_start, sdd.Leg, sdd.source_deal_header_id, uddft_pri.field_label, udddf.udf_value
	into #deal_detail_udf
	FROM  user_defined_deal_fields_template uddft_pri			
	LEFT JOIN user_defined_deal_detail_fields udddf
		ON uddft_pri.udf_template_id = udddf.udf_template_id	
	inner join source_deal_detail sdd on sdd.source_deal_detail_id = udddf.source_deal_detail_id
	WHERE  uddft_pri.field_label in ('Package ID')
		AND uddft_pri.leg = sdd.leg order by 1,2
	--select * from #deal_detail_udf

	--STORE CONTRACT RECEIPT/DELIVERY LOCATIONS IF NOT NULL
	declare @contract_locs varchar(5000)
	if @contract_id is not null
	begin
		SELECT @contract_locs = STUFF(
			(SELECT distinct ','  + cast(t.location_id AS varchar)
			from transportation_contract_location t
			inner join dbo.SplitCommaSeperatedValues(@contract_id) scsv on scsv.item = t.contract_id
			order by 1
			FOR XML PATH(''))
		, 1, 1, '')
		
	end
	--select @contract_locs
	--return

	--COLLECT DEALS TO BE CONSIDERED
	IF OBJECT_ID('tempdb..#collect_deals') IS NOT NULL 
		DROP TABLE #collect_deals
	create table #collect_deals (source_deal_header_id int)
	set @sql = '
	insert into #collect_deals
	select distinct sdh.source_deal_header_id
	from source_deal_detail sdd
	inner join source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
	inner join source_deal_type sdt on sdt.source_deal_type_id = sdh.source_deal_type_id
	left join #deal_header_udf udf on udf.source_deal_header_id = sdh.source_deal_header_id
	where 1=1 and sdt.deal_type_id <> ''Transportation'' and sdh.physical_financial_flag = ''p'' and sdh.counterparty_id = ' + @shipper
	+ case when @term_start is not null then ' and sdd.term_start >= ''' + cast(@term_start as varchar) + '''' else '' end
	+ case when @term_end is not null then ' and sdd.term_end <= ''' + cast(@term_end as varchar) + '''' else '' end
	+ case when @pipeline is not null then ' and udf.udf_value = ''' + @pipeline + '''' else '' end
	+ case when @contract_id is not null and @contract_locs is not null then ' and sdd.location_id IN (' + @contract_locs + ')' else '' end

	exec spa_print @sql
	exec(@sql)
	--select * from #collect_deals
	--return
		
	declare @header_col_name varchar(5000) = 'Process ID,Receipt/Delivery,Pipeline,Fuel,Contract,Counterparty ID,CounterpartyD,Counterparty,Location ID,Location,Rank,Reference ID,Package ID, ,Volume Type'
	, @header_col_id varchar(5000) = 'process_id,receipt_delivery,pipeline,fuel,contract,counterparty_id,counterparty,up_dn_counterparty,location_id,location,rank,ref_id,package_id,source_deal_header_id,vol_type'
	, @header_col_type varchar(5000) = 'ro,ro,combo,ro,combo,ro,ro,combo,ro,combo,ed,ro,ed,sub_row_grid,ro'
	, @header_col_width varchar(5000) = '200,120,180,100,180,100,100,150,100,200,60,100,100,35,100'
	, @header_col_visibility varchar(5000) = 'true,false,false,true,false,true,true,false,true,false,false,true,false,false,false'
	, @header_col_sorting varchar(5000) = 'str,str,str,int,str,str,str,str,str,str,str,str,str,int,str'
	, @header_col_filter varchar(5000) = '#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,,#text_filter'
	, @header_row_groupby varchar(5000) = ''''''''',''''#title'''','''''''','''''''','''''''','''''''','''''''','''''''','''''''','''''''','''''''','''''''','''''''','''''''','''''''''
	, @no_of_nulls varchar(5000)
	, @no_of_zeroes varchar(5000)
	
	declare @sub_grid_header_col_name varchar(5000) = 'receipt_delivery,source_deal_header_id,location_id,location,Vol Type'
	, @sub_grid_header_col_id varchar(5000) = 'receipt_delivery,source_deal_header_id,location_id,location,vol_type'
	, @sub_grid_header_col_type varchar(5000) = 'ro,ro,ro,ro,ro'
	, @sub_grid_header_col_sorting varchar(5000) = 'sr,int,str,str,str'
	, @sub_grid_header_col_width varchar(5000) = '100,200,100,100,96'
	, @sub_grid_header_col_visibility varchar(5000) = 'true,true,true,true,false'
	
	declare @term_start_range datetime, @term_end_range datetime

	if object_id('tempdb..#tmp_term_range') is not null
		drop table #tmp_term_range
	create table #tmp_term_range (term_start_range datetime, term_end_range datetime)

	set @sql = '
	insert into #tmp_term_range(term_start_range, term_end_range)
	select min(sdd.term_start), max(sdd.term_end)
	from source_deal_detail sdd
	inner join #collect_deals cd on cd.source_deal_header_id = sdd.source_deal_header_id
	where 1=1 '
	+ case when @term_start is not null then ' and sdd.term_start >= ''' + cast(@term_start as varchar) + '''' else '' end
	+ case when @term_end is not null then ' and sdd.term_end <= ''' + cast(@term_end as varchar) + '''' else '' end


	exec spa_print @sql
	exec(@sql)


	
	select @term_start_range = term_start_range, @term_end_range = term_end_range from #tmp_term_range
	
	declare @no_of_terms int
	set @no_of_terms = DATEDIFF(DAY, @term_start_range, @term_end_range) + 1
		
	
	SELECT @header_col_name = ISNULL(@header_col_name + ',', '')  + dbo.FNADateFormat(CAST(DATEADD(DAY, n - 1, @term_start_range)  AS VARCHAR(50)))
		, @header_col_id = ISNULL(@header_col_id + ',', '')  + cast(dbo.FNAGetSQLStandardDate(DATEADD(DAY, n - 1, @term_start_range))  AS VARCHAR(50))
		, @header_col_type = ISNULL(@header_col_type + ',', '')  + 'edn'
		, @header_col_width = ISNULL(@header_col_width + ',', '')  + '100'
		, @header_col_visibility = ISNULL(@header_col_visibility + ',', '')  + 'false'
		, @header_col_filter = ISNULL(@header_col_filter + ',', '')  + ' '
		, @header_row_groupby = ISNULL(@header_row_groupby + ',', '')  + '''''#stat_total'''''
		
		, @sub_grid_header_col_name = ISNULL(@sub_grid_header_col_name + ',', '')  + dbo.FNADateFormat(CAST(DATEADD(DAY, n - 1, @term_start_range)  AS VARCHAR(50)))
		, @sub_grid_header_col_id = ISNULL(@sub_grid_header_col_id + ',', '')   + cast(dbo.FNAGetSQLStandardDate(DATEADD(DAY, n - 1, @term_start_range))  AS VARCHAR(50))
		, @sub_grid_header_col_type = ISNULL(@sub_grid_header_col_type + ',', '')  + 'edn'
		, @sub_grid_header_col_width = ISNULL(@sub_grid_header_col_width + ',', '')   + '100'
		, @sub_grid_header_col_visibility = ISNULL(@sub_grid_header_col_visibility + ',', '')  + 'false'
		, @no_of_nulls = ISNULL(@no_of_nulls + ',', '')  + 'NULL'
		, @no_of_zeroes = ISNULL(@no_of_zeroes + ',', '')  + '0'
	FROM seq WHERE n <= @no_of_terms
	
	set @sql = '
	select ''grid'' [header_type]
		, ''' + @process_id + ''' [process_id] 
		, ''' + @header_col_name + ''' [header_col_name]
		, ''' + @header_col_id + ''' [header_col_id]
		, ''' + @header_col_type + ''' [header_col_type]
		, ''' + @header_col_sorting + ''' [header_col_sorting]
		, ''' + @header_col_width + ''' [header_col_width]
		, ''' + @header_col_visibility + '''[header_col_visibility]
		, ''' + @header_col_filter + '''[header_col_filter]
		, ''' + @header_row_groupby + '''[header_row_groupby]
		, ' + cast(isnull(@no_of_terms, 0) as varchar) + ' [no_of_terms]
		, ''' + isnull(cast(dbo.FNAGetSQLStandardDate(@term_start_range) as varchar(50)), '') + ''' [term_start_range]
		, ''' + isnull(cast(dbo.FNAGetSQLStandardDate(@term_end_range) as varchar(30)), '') + ''' [term_end_range]
	into ' + @tbl_grid_definition_info + '
	union all
	select ''sub_grid'' [header_type]
		, ''' + @process_id + ''' [process_id] 
		, ''' + @sub_grid_header_col_name + ''' [header_col_name]
		, ''' + @sub_grid_header_col_id + ''' [header_col_id]
		, ''' + @sub_grid_header_col_type + ''' [header_col_type]
		, ''' + @sub_grid_header_col_sorting + ''' [header_col_sorting]
		, ''' + @sub_grid_header_col_width + ''' [header_col_width]
		, ''' + @sub_grid_header_col_visibility + '''[header_col_visibility]
		, null [header_col_filter]
		, null [header_row_groupby]
		, ' + cast(isnull(@no_of_terms, 0) as varchar) + ' [no_of_terms]
		, ''' + isnull(cast(dbo.FNAGetSQLStandardDate(@term_start_range) as varchar(50)), '') + ''' [term_start_range]
		, ''' + isnull(cast(dbo.FNAGetSQLStandardDate(@term_end_range) as varchar(30)), '') + ''' [term_end_range]
	'

	exec spa_print @sql
	exec(@sql)
	
	
	--EXTRACT LOCATION RANK FOR LATEST EFFECTIVE DATE
	/*
	if OBJECT_ID('tempdb..#tmp_lr_eff_date') is not null 
	drop table #tmp_lr_eff_date

	select lr.location_id, max(lr.effective_date) effective_date
	into #tmp_lr_eff_date
	from location_ranking lr
	where lr.effective_date <= isnull(@term_start,lr.effective_date)
	group by lr.location_id

	if OBJECT_ID('tempdb..#tmp_lr') is not null 
		drop table #tmp_lr

	select t2.location_id, t2.effective_date, ca_lr.loc_rank
	into #tmp_lr
	from #tmp_lr_eff_date t2
	cross apply (
		select sdv.code [loc_rank] 
		from location_ranking t 
		LEFT JOIN static_data_value sdv on sdv.value_id = t.rank_id
		where t.location_id = t2.location_id and t.effective_date = t2.effective_date
	) ca_lr
	*/

	--STORE MAIN GRID DATA
	if OBJECT_ID('tempdb..#tmp_detail_data') is not null
		drop table #tmp_detail_data
	select cast(case sdd.buy_sell_flag when 'b' then 'Rec' else 'Del' end as varchar(100)) [receipt_delivery]
		, pl.counterparty_name pipeline
		, isnull(cast(loss.udf_value as float), 0) [fuel]
		, cg.[contract_name] [contract]
		, sc.source_counterparty_id [counterparty_id]
		, sc.counterparty_name counterparty
		, up_dn_cpty.counterparty_name [up_dn_counterparty]
		, mj.location_name location_group
		, sml.source_minor_location_id [location_id]
		, sml.Location_Name location
		, sdh.deal_id [ref_id]
		, sdh.description3 package_id
		, sdh.description2 [rank]
		, sdd.source_deal_header_id [source_deal_header_id]
		, cast('NOM' as varchar(100)) vol_type
		, case sdd.buy_sell_flag 
			when 'b' then cast(sdd.deal_volume as int)
			else cast(sdd.deal_volume / (1 - case when loss.udf_value is null or cast(loss.udf_value as float) = 1 then 0 else cast(loss.udf_value as float) end) as int)
			--else cast(sdd.deal_volume / (1 - 0.01) as int)
		  end
		  [volume]
		, cast(sdd.deal_volume as int) [deal_volume]
		, dbo.FNAGetSQLStandardDate(sdd.term_start) [term_start]
		--, 'aa' [term_start]
		into #tmp_detail_data
		--select *
	from source_deal_detail sdd
	inner join source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
	inner join #collect_deals cd on cd.source_deal_header_id = sdh.source_deal_header_id
	left join source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
	left join source_minor_location sml on sml.source_minor_location_id = sdd.location_id
	left join source_major_location mj on mj.source_major_location_ID = sml.source_major_location_ID
	left join #deal_header_udf udf_pl on udf_pl.Field_label = 'Pipeline' and udf_pl.source_deal_header_id = sdh.source_deal_header_id
	left join source_counterparty pl on pl.source_counterparty_id = udf_pl.udf_value
	--left join #deal_detail_udf pkg on pkg.Field_label = 'Package ID' and pkg.source_deal_detail_id = sdd.source_deal_detail_id
	left join #deal_header_udf loss on loss.Field_label = 'Loss' and loss.source_deal_header_id = sdh.source_deal_header_id
	left join #deal_header_udf udf_up_dn_cpty on udf_up_dn_cpty.Field_label = 'Up Dn Party' and udf_up_dn_cpty.source_deal_header_id = sdh.source_deal_header_id
	left join source_counterparty up_dn_cpty on up_dn_cpty.source_counterparty_id = udf_up_dn_cpty.udf_value
	left join contract_group cg on cg.contract_id = sdh.contract_id
	--left join #tmp_lr lr on lr.location_id = sdd.location_id
	where 1=1 --and sdd.location_id = 27383
		and sdd.term_start >= isnull(@term_start, sdd.term_start) and sdd.term_end <= isnull(@term_end, sdd.term_end)
	order by 1


	--select @no_of_terms
	if not exists(select top 1 1 from #tmp_detail_data where receipt_delivery = 'Rec')
	begin
		insert into #tmp_detail_data([receipt_delivery],[term_start], fuel, [volume], ref_id,source_deal_header_id, vol_type)
		select 'Rec', dbo.FNAGetSQLStandardDate(DATEADD(DAY, n - 1, @term_start_range)), 0, 0 [volume], '',-10,''
		from seq s where s.n <= @no_of_terms
	end 
	if not exists(select top 1 1 from #tmp_detail_data where receipt_delivery = 'Del')
	begin
		insert into #tmp_detail_data([receipt_delivery], [term_start], fuel, [volume], ref_id,source_deal_header_id, vol_type)
		select 'Del', dbo.FNAGetSQLStandardDate(DATEADD(DAY, n - 1, @term_start_range)), 0, 0 [volume], '',-11,''
		from seq s where s.n <= @no_of_terms
	end
	--order by [term_start]
	--select * from #tmp_detail_data select * from #deal_header_udf

	--return

	--STORE NET VALUE FOR REC DEL
	if OBJECT_ID('tempdb..#tmp_net_vol') is not null
		drop table #tmp_net_vol
	select 'Net' [receipt_delivery], rec_tot.term_start, abs(rec_tot.vol) - abs(del_tot.vol) [volume]
	into #tmp_net_vol
	from seq s
	cross apply (
		select t.receipt_delivery, t.term_start, sum(t.volume) [vol]
		from #tmp_detail_data t
		where t.receipt_delivery = 'Rec'
		group by t.receipt_delivery, t.term_start
	) rec_tot
	cross apply (
		select t.receipt_delivery,t.term_start, sum(t.deal_volume) [vol]
		from #tmp_detail_data t
		where t.receipt_delivery = 'Del' and t.term_start = rec_tot.term_start
		group by t.receipt_delivery,t.term_start
	) del_tot
	where s.n = 1
	--select * from #tmp_net_vol

	if OBJECT_ID('tempdb..#tmp_fuel_vol') is not null
		drop table #tmp_fuel_vol
	select 'Net' [receipt_delivery], del_nom_fuel.term_start, abs(del_nom_fuel.[del_nom]) - abs(del_nom_fuel.[fuel_nom]) [volume]
	into #tmp_fuel_vol
	from seq s
	cross apply (
		select t.receipt_delivery, t.term_start, sum(t.deal_volume) [del_nom], sum(t.volume) [fuel_nom]
		from #tmp_detail_data t
		where t.receipt_delivery = 'Del'
		group by t.receipt_delivery, t.term_start
	) del_nom_fuel
	where s.n = 1
	--select * from #tmp_fuel_vol
	
	insert into #tmp_detail_data([receipt_delivery], [term_start],fuel, [volume], ref_id,source_deal_header_id, vol_type)
	select t.receipt_delivery, t.term_start,0, t.volume [volume], '',-1,''
	from #tmp_net_vol t
	insert into #tmp_detail_data([receipt_delivery], [term_start],fuel, [volume], ref_id,source_deal_header_id, vol_type)
	select t.receipt_delivery, t.term_start,0, t.volume [volume], '',-2,''
	from #tmp_fuel_vol t
	
	declare @pivot_cols varchar(1000)
	
	SELECT @pivot_cols = STUFF(
		(SELECT distinct ',['  + cast(t.term_start AS varchar) + ']'
		from #tmp_detail_data t
		order by 1
		FOR XML PATH(''))
	, 1, 1, '')
	--select @process_id,@pivot_cols
	
	set @sql = '
	SELECT ''' + @process_id + ''' [process_id],receipt_delivery, pipeline, fuel, contract, counterparty_id, counterparty, up_dn_counterparty, location_id, location
		, [rank], ref_id, package_id, [source_deal_header_id], vol_type'
		+ isnull(',' + @pivot_cols,'') + '
		into ' + @tbl_grid_data + '
	FROM (
		SELECT ''' + @process_id + ''' [process_id],receipt_delivery, pipeline, fuel, contract, counterparty_id, counterparty, up_dn_counterparty, location_id, location
		, [rank], ref_id, package_id, [source_deal_header_id], vol_type, volume, term_start
		from #tmp_detail_data
	) pvt
	' + case when @pivot_cols is null then '' else '
	PIVOT
	(sum([volume]) FOR [term_start] IN (' + @pivot_cols + ')) AS t2
	'
	end

	exec spa_print @sql
	exec(@sql)
	
	/*
	set @sql = '
	select cast(''a'' as varchar(50)) [receipt_delivery]
		, null source_deal_header_id
		, 100 [location_id]
		, cast(''a'' as varchar(1000)) [location]
		, cast(''a'' as varchar(50)) [vol_type]' + isnull(',' + @pivot_cols, '') + '
	into ' + @tbl_sub_grid_data + ' 
	from ' + @tbl_grid_data + ' gd where 1=2
	
	insert into ' + @tbl_sub_grid_data + '
	select gd.receipt_delivery, gd.source_deal_header_id, ca_vt.vol_type [vol_type]' + isnull(',' + @no_of_zeroes, '') + '
	from ' + @tbl_grid_data + ' gd
	cross apply (
		select ''FNOM'' [vol_type] where 1 =  case gd.receipt_delivery when ''Del'' then 1 else 2 end 
		union all select ''SCHD'' [vol_type] 
		union all select ''ALLC''
	) ca_vt
	where gd.receipt_delivery <> ''Net''
	order by 1
	
	'
	*/
	set @sql = '
	select receipt_delivery,source_deal_header_id, location_id, location,vol_type' + isnull(',' + @pivot_cols, '') + '
	into ' + @tbl_sub_grid_data + ' 
	from (
		select t.receipt_delivery ,t.source_deal_header_id, t.location_id, t.location,ca_vt.vol_type
		, t.term_start
		, case ca_vt.vol_type
			when ''FNOM'' then cast(t.deal_volume as int)
			when ''SCHD'' then case when t.receipt_delivery = ''Rec'' then cast(ca_sch_rec.deal_volume as int) else cast(ca_sch_del.deal_volume as int) end
			when ''ALLC'' then case when t.receipt_delivery = ''Rec'' then cast(ca_sch_rec.deal_volume as int) else cast(ca_sch_del.deal_volume as int) end
			else 0
		  end vol
		from #tmp_detail_data t
		
		cross apply (
			select ''FNOM'' [vol_type] where 1 =  case t.receipt_delivery when ''Del'' then 1 else 2 end 
			union all select ''SCHD'' [vol_type] 
			union all select ''ALLC''
		) ca_vt
		outer apply (
			select sdt.source_deal_type_name,sdd.location_id, sml.Location_Name--, sdd.source_deal_header_id,sdd.Leg
				, sdd.term_start
				--, sdd.deal_volume, udf_fd.Field_label, udf_fd.udf_value
				, sum(sdd.deal_volume) deal_volume
			from source_deal_detail sdd
			inner join source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
			inner join source_deal_type sdt on sdt.source_deal_type_id = sdh.source_deal_type_id
			left join source_minor_location sml on sml.source_minor_location_id = sdd.location_id
			left join #deal_header_udf udf_fd on udf_fd.Field_label = ''From Deal'' and udf_fd.source_deal_header_id = sdh.source_deal_header_id
			where 1=1 and sdt.source_deal_type_name = ''Transport''
				and sdd.term_start = t.term_start
				and sdd.location_id = t.location_id
				and udf_fd.udf_value = cast(t.source_deal_header_id as varchar(50))
				and ca_vt.vol_type in (''SCHD'',''ALLC'')
				and t.location_id is not null
				and t.receipt_delivery = ''Rec''
				
			group by sdt.source_deal_type_name,sdd.location_id, sml.Location_Name
				, sdd.term_start
		) ca_sch_rec
		outer apply (
			select sdt.source_deal_type_name,sdd.location_id, sml.Location_Name--, sdd.source_deal_header_id,sdd.Leg
				, sdd.term_start
				--, sdd.deal_volume, udf_fd.Field_label, udf_fd.udf_value
				, sum(sdd.deal_volume) deal_volume
			from source_deal_detail sdd
			inner join source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
			inner join source_deal_type sdt on sdt.source_deal_type_id = sdh.source_deal_type_id
			left join source_minor_location sml on sml.source_minor_location_id = sdd.location_id
			left join contract_group cg on cg.contract_id = sdh.contract_id
			where 1=1 and sdt.source_deal_type_name = ''Transport''
				and sdd.term_start = t.term_start
				and sdd.location_id = t.location_id
				and cg.contract_name = t.contract
				and ca_vt.vol_type in (''SCHD'',''ALLC'')
				and t.location_id is not null
				and t.receipt_delivery = ''Del''
				
			group by sdt.source_deal_type_name,sdd.location_id, sml.Location_Name
				, sdd.term_start
		) ca_sch_del
		where t.location_id is not null
	) pvt
	' + case when @pivot_cols is null then '' else '
	PIVOT
	(sum([vol]) FOR [term_start] IN (' + @pivot_cols + ')) AS t2
	'
	end

	exec spa_print @sql
	exec(@sql)
	
	
	set @sql = 'select * from ' + @tbl_grid_definition_info
	exec spa_print @sql
	exec(@sql)

	
	/*
	select receipt_delivery,source_deal_header_id, location_id, location,vol_type,[2015-10-01]
	--into adiha_process.dbo.tbl_sub_grid_data_farrms_admin_ABE80FED_4991_4D47_8DE1_7736E7B36B4B 
	from (
		select * from #deal_header_udf where Field_label = 'from deal' and source_deal_header_id in (83662,83663) order by 2

		select t.receipt_delivery ,t.source_deal_header_id, t.location_id, t.location,ca_vt.vol_type
		, t.term_start
		, case ca_vt.vol_type
			when 'FNOM' then cast(t.deal_volume as int)
			when 'SCHD' then case when t.receipt_delivery = 'Rec' then cast(ca_sch_rec.deal_volume as int) else cast(ca_sch_del.deal_volume as int) end
			when 'ALLC' then case when t.receipt_delivery = 'Rec' then cast(ca_sch_rec.deal_volume as int) else cast(ca_sch_del.deal_volume as int) end
			else 0
		  end vol
		from #tmp_detail_data t
		
		cross apply (
			select 'FNOM' [vol_type] where 1 =  case t.receipt_delivery when 'Del' then 1 else 2 end 
			union all select 'SCHD' [vol_type] 
			union all select 'ALLC'
		) ca_vt
		outer apply (
			select sdt.source_deal_type_name,sdd.location_id, sml.Location_Name--, sdd.source_deal_header_id,sdd.Leg
				, sdd.term_start
				--, sdd.deal_volume, udf_fd.Field_label, udf_fd.udf_value
				, sum(sdd.deal_volume) deal_volume
			from source_deal_detail sdd
			inner join source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
			inner join source_deal_type sdt on sdt.source_deal_type_id = sdh.source_deal_type_id
			left join source_minor_location sml on sml.source_minor_location_id = sdd.location_id
			left join #deal_header_udf udf_fd on udf_fd.Field_label = 'From Deal' and udf_fd.source_deal_header_id = sdh.source_deal_header_id
			where 1=1 and sdt.source_deal_type_name = 'Transport'
				and sdd.term_start = t.term_start
				and sdd.location_id = t.location_id
				and udf_fd.udf_value = cast(t.source_deal_header_id as varchar(50))
				and ca_vt.vol_type in ('SCHD','ALLC')
				and t.location_id is not null
				and t.receipt_delivery = 'Rec'
				
			group by sdt.source_deal_type_name,sdd.location_id, sml.Location_Name
				, sdd.term_start
		) ca_sch_rec
		outer apply (
			select sdt.source_deal_type_name,sdd.location_id, sml.Location_Name--, sdd.source_deal_header_id,sdd.Leg
				, sdd.term_start
				--, sdd.deal_volume, udf_fd.Field_label, udf_fd.udf_value
				, sum(sdd.deal_volume) deal_volume
			from source_deal_detail sdd
			inner join source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id
			inner join source_deal_type sdt on sdt.source_deal_type_id = sdh.source_deal_type_id
			left join source_minor_location sml on sml.source_minor_location_id = sdd.location_id
			left join contract_group cg on cg.contract_id = sdh.contract_id
			where 1=1 and sdt.source_deal_type_name = 'Transport'
				and sdd.term_start = t.term_start
				and sdd.location_id = t.location_id
				and cg.contract_name = t.contract
				and ca_vt.vol_type in ('SCHD','ALLC')
				and t.location_id is not null
				and t.receipt_delivery = 'Del'
				
			group by sdt.source_deal_type_name,sdd.location_id, sml.Location_Name
				, sdd.term_start
		) ca_sch_del
		where t.location_id is not null
	) pvt
	
	PIVOT
	(sum([vol]) FOR [term_start] IN ([2015-10-01])) AS t2
	--*/

end
else if @flag = 'y' --extract grid data info
begin
	
	
	set @sql = '
	select * 
	from ' 
	+ case @call_from when 'main_grid' then @tbl_grid_data else @tbl_sub_grid_data end + 
	' d where 1=1 '
	+ case @call_from when 'main_grid' then '' else ' and d.receipt_delivery = ''' + @receipt_delivery + '''' end 
	+ case @call_from when 'main_grid' then '' else ' and d.source_deal_header_id = ' + @source_deal_header_id end + 
	+ case @call_from when 'main_grid' then ' order by case [receipt_delivery] when ''Rec'' then 0 when ''Del'' then 1 when ''Net Fuel'' then 3 else 4 end
	' else 'order by case [vol_type] when ''FNOM'' then 0 when ''SCH'' then 1 when ''ALLC'' then 3 else 4 end' end
	exec spa_print @sql
	exec(@sql)
end

ELSE IF @flag = 'z' -- send confirmation
BEGIN
	BEGIN TRY
		DECLARE @alert_process_table VARCHAR(300)
		DECLARE @alert_process_id VARCHAR(200) = dbo.FNAGetNewID()
		SET @alert_process_table = 'adiha_process.dbo.alert_nomination_' + @alert_process_id + '_an'
	
		EXEC('CREATE TABLE ' + @alert_process_table + ' (
				source_deal_header_id  VARCHAR(500),
				term_start             DATETIME,
				term_end			   DATETIME,
				counterparty_id        VARCHAR(MAX),
				location_id			   VARCHAR(MAX),
				contract_id			   VARCHAR(MAX),
				volume				   VARCHAR(500),
				uom					   INT,
				loss_volume			   VARCHAR(20),
				hyperlink1             VARCHAR(5000),
				hyperlink2             VARCHAR(5000),
				hyperlink3             VARCHAR(5000),
				hyperlink4             VARCHAR(5000),
				hyperlink5             VARCHAR(5000)
		)')

		DECLARE @xml_table VARCHAR(200)
		DECLARE @user_name VARCHAR(200) = dbo.FNADBUser()
		SET @xml_table = dbo.FNAProcessTableName('xml_table', @user_name, @alert_process_id)
		
		EXEC spa_parse_xml_file 'b', NULL, @xml, @xml_table

		SET @sql = 'INSERT INTO ' + @alert_process_table + ' (
						source_deal_header_id,
						term_start           ,
						term_end			 ,
						counterparty_id      ,
						location_id			 ,
						contract_id,
						volume,
						uom,
						loss_volume			 
					 )
					 SELECT temp.source_deal_header_id, 
						  ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''',
						  ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''',
						  sc.source_counterparty_id,
						  temp.location_id,
						  cg.contract_id,
						  dbo.FNARemoveTrailingZero(sdd.deal_volume),
						  sdd.uom_id,
						  ROUND(dbo.FNARemoveTrailingZero(sdd.deal_volume - (sdd.loss*sdd.deal_volume)), 0)
					 FROM ' + @xml_table + ' temp
					 INNER JOIN source_counterparty sc ON sc.counterparty_name = temp.up_dn_counterparty
					 INNER JOIN contract_group cg ON cg.contract_name = temp.contract
					 OUTER APPLY (
						SELECT MAX(deal_volume) deal_volume, MAX(sdd.deal_volume_uom_id) uom_id, MAX(CAST(udf_value AS FLOAT)) loss
						FROM source_deal_header sdh
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
						LEFT JOIN user_defined_deal_fields_template uddft
								ON  uddft.field_name = -5614
								AND uddft.template_id = sdh.template_id
						LEFT JOIN user_defined_deal_fields udddf
							ON  udddf.source_deal_header_id = sdh.source_deal_header_id
							AND uddft.udf_template_id = udddf.udf_template_id
						WHERE sdh.source_deal_header_id = temp.source_deal_header_id
						AND sdd.location_id = temp.location_id
						AND sdd.term_start BETWEEN ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @term_end, 120) + '''
					) sdd 
					 '
		exec spa_print @sql
		EXEC(@sql)

		EXEC spa_register_event 20608, 20523, @alert_process_table, 0, @alert_process_id

		EXEC spa_ErrorHandler 0
				, 'spa_view_edit_nom'
				, 'spa_view_edit_nom'
				, 'Success' 
				, 'Confirmation sent successfully.'
				, ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to send confirmation ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'source_deal_header'
		   , 'spa_deal_update_new'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END 

ELSE IF @flag = 'v' OR @flag = 'w'
BEGIN
	BEGIN TRY
		DECLARE @quantity_process_table VARCHAR(300),
				@submit_table VARCHAR(300),
				@column_header VARCHAR(5000)

		;WITH cte AS (
			SELECT @term_start DateValue
			UNION ALL
			SELECT  DATEADD(day, 1, DateValue)
			FROM    cte   
			WHERE   DATEADD(day, 1, DateValue) <= @term_end
		)
		SELECT  @column_header = COALESCE(@column_header + ',', '') + '[' + CONVERT(VARCHAR(10), DateValue, 120) + ']' + '[' + dbo.FNADateFormat(DateValue) + ']'
		FROM    cte
		OPTION (MAXRECURSION 0)

		SET @quantity_process_table = dbo.FNAProcessTableName('tbl_grid_data', @current_user, @process_id)

		SET @submit_table = dbo.FNAProcessTableName('submit_table', @current_user, @process_id)

		IF OBJECT_ID(@submit_table) IS NOT NULL
			EXEC('DROP TABLE ' + @submit_table)

		SET @sql = 'SELECT receipt_delivery [REC/DEL], pipeline [Pipeline], contract [Contract], counterparty [Shipper], up_dn_counterparty [UP/DN Party], location [Location], rank [Rank], package_id [Package ID], ' + @column_header + '
					INTO ' + @submit_table + '
					FROM ' + @quantity_process_table + ' 
					WHERE source_deal_header_id > 0 
					--AND vol_type = ''' + @flag + '''
					'
		exec spa_print @sql
		EXEC(@sql)

		DECLARE @email_address VARCHAR(200), 
				@output_filename VARCHAR(2000),
				@subject VARCHAR(200),
				@text VARCHAR(MAX),
				@shipper_name VARCHAR(500)		   

		SELECT @email_address = COALESCE(@email_address + ',', '') + cc.email
		FROM source_counterparty sc
		LEFT JOIN counterparty_contacts cc ON cc.counterparty_id = sc.source_counterparty_id
		WHERE sc.source_counterparty_id = @shipper

		SELECT @shipper_name = sc.counterparty_name,
			   @email_address = ISNULL(@email_address, sc.email)
		FROM source_counterparty sc
		WHERE sc.source_counterparty_id = @shipper
	
		SET @output_filename = @folder_path + '\' + CASE WHEN @flag = 'v' THEN 'SCHD_' ELSE 'ALLC_' END + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(100), GETDATE(), 120), '-', ''), ':', ''), '.', ''), ' ', '') + '.csv'
		SET @subject = 'TRMTracker - ' + CASE WHEN @flag = 'v' THEN 'Scheduled' ELSE 'Allocated' END + ' Quantity'
		SET @text = '<P>Dear ' + @shipper_name + ',</P>
					<P>Attached please find your ' + CASE WHEN @flag = 'v' THEN 'Scheduled' ELSE 'Allocated' END + ' Quantity for the flow date ' + CONVERT(VARCHAR(11), @term_start, 106) + ' - ' + CONVERT(VARCHAR(11), @term_end, 106) + '.</P>
					<P>&nbsp;</P>'

		EXEC spa_dump_csv
			@data_table_name = @submit_table,
			@file_path = @output_filename,
			@compress_file = NULL,
			@delim = ',',
			@is_header = '1'

		INSERT INTO email_notes (
			[send_status],
			[active_flag],
			[notes_subject],
			[notes_text],
			[send_from],
			[send_to],
			[attachment_file_name],
			[process_id]
		)
		SELECT 'n', 'y', @subject, @text, 'noreply@pioneersolutionsglobal.com', scsv.item, @output_filename, @process_id
		FROM dbo.SplitCommaSeperatedValues(@email_address) scsv

		SET @desc =  CASE WHEN @flag = 'v' THEN 'Schedule' ELSE 'Allocation' END + ' volume send successfully.'
		EXEC spa_ErrorHandler 0
			, 'spa_view_edit_nom'
			, 'spa_view_edit_nom'
			, 'Success' 
			, @desc
			, ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to send volume ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'source_deal_header'
		   , 'spa_deal_update_new'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END