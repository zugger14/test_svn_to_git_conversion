if OBJECT_ID('spa_modify_per_gen_link') is not null
drop proc dbo.spa_modify_per_gen_link

go


create proc dbo.spa_modify_per_gen_link
	@link_id int, @apply_vol numeric(26,10),@FIFO_LIFO varchar(1),@hedge_or_item varchar(1)='i',@forecated_tran varchar(1)='n'
as

/*
declare @link_id int=92, @apply_vol numeric(26,10)=10,@FIFO_LIFO varchar(1)='i',@hedge_or_item varchar(1)='i',@forecated_tran varchar(1)='n'

drop table #tmp_sdd_vol
drop table #tmp_links
drop table #delete_link
drop table #modify_link
drop table #modify_link_h
drop table #delete_link_h
drop table #tmp_links_h
drop table #dice_link
--*/
declare @sql varchar(max),@st varchar(max)

--set @user_name=ISNULL(@user_name,dbo.fnadbuser())

if isnull(@forecated_tran,'n')='y'
begin
	update sdd  set deal_volume=@apply_vol from gen_deal_detail sdd
	INNER JOIN	[gen_fas_link_detail] fld  on  fld.gen_link_id= @link_id and fld.hedge_or_item='i' and fld.deal_number=sdd.gen_deal_header_id
	
	update fld set percentage_included=@apply_vol/sdd.deal_volume from [gen_fas_link_detail] fld 
	inner join gen_deal_detail sdd  on fld.deal_number=sdd.gen_deal_header_id and fld.gen_link_id=@link_id	and hedge_or_item='h'  
	
	return
		
end


if exists(select 1 from gen_fas_link_header where gen_link_id=@link_id and perfect_hedge='y')
	set @hedge_or_item='h'


create table #tmp_links  (ROWID int identity(1,1),gen_link_id int,deal_number int
 ,used_vol numeric(26,12),d_vol numeric(26,12),d_date datetime)

create table #tmp_links_h  (ROWID int identity(1,1),gen_link_id int,deal_number int
 ,used_vol numeric(26,12),d_vol numeric(26,12),d_date datetime)

select distinct link_id into #dice_link from gen_fas_link_detail_dicing --where link_id=@link_id

set @st='
	insert into #tmp_links  (gen_link_id ,deal_number,used_vol,d_vol,d_date)
	select gen_link_id,source_deal_header_id, used_vol, d_vol, d_date from 
	(
	select gen_link_id,gfld.deal_number source_deal_header_id,sum(sdd.deal_volume * gfld.percentage_included) used_vol,sum(sdd.deal_volume) d_vol,max(sdh.deal_date) d_date  from '+case when isnull(@forecated_tran,'n')='n' then ' source_deal_detail ' else ' gen_deal_detail ' end +
		' sdd inner join gen_fas_link_detail gfld 
			on gfld.deal_number='+case when isnull(@forecated_tran,'n')='n' then '  sdd.source_deal_header_id ' else ' sdd.gen_deal_header_id ' end
			+' and sdd.Leg=1 and gfld.hedge_or_item='''+ @hedge_or_item+''' and gfld.gen_link_id=' + cast(@link_id as varchar)+'
			left join '+case when isnull(@forecated_tran,'n')='n'	then ' dbo.source_deal_header ' else ' gen_deal_header ' end +
			' sdh on gfld.deal_number='+case when isnull(@forecated_tran,'n')='n' then ' sdh.source_deal_header_id ' else ' sdh.gen_deal_header_id ' end
			+'	left join #dice_link dl on dl.link_id=gfld.gen_link_id
			left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
			where  dl.link_id is null 
			group by gfld.gen_link_id,gfld.deal_number'
		+case when isnull(@forecated_tran,'n')='n'	then 
			case when @hedge_or_item='i' then 
			' union all
				select gfldd.link_id,gfldd.source_deal_header_id,sum(sdd.deal_volume * gfldd.percentage_used) used_vol,sum(sdd.deal_volume) d_vol,max(sdh.deal_date) d_date 
				 from gen_fas_link_detail_dicing gfldd
				inner join  '+case when isnull(@forecated_tran,'n')='n' then ' source_deal_detail ' else ' gen_deal_detail ' end +
				' sdd on gfldd.source_deal_header_id='+case when isnull(@forecated_tran,'n')='n' then ' sdd.source_deal_header_id  ' else ' sdd.gen_deal_header_id ' end+
				' and gfldd.term_start=sdd.term_start and sdd.leg=1 and gfldd.link_id=' + cast(@link_id as varchar)+'
				left join '+case when isnull(@forecated_tran,'n')='n'	then ' dbo.source_deal_header ' else ' gen_deal_header ' end +
				' sdh on gfldd.source_deal_header_id='+case when isnull(@forecated_tran,'n')='n' then ' sdh.source_deal_header_id  ' else ' sdh.gen_deal_header_id ' end+'
				left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
				group by gfldd.link_id,gfldd.source_deal_header_id'
			else '' end
		else '' end +
	') a order by '
		+ case when @FIFO_LIFO='f' then 'd_date,gen_link_id,source_deal_header_id'
				else 'd_date desc,gen_link_id desc,source_deal_header_id desc'	end
		
EXEC spa_print @st
exec(@st)



select m.gen_link_id,m.deal_number 
into #delete_link
from #tmp_links m
cross apply (
	select SUM(used_vol) run_total from #tmp_links l where rowid<=m.rowid
) r
where r.run_total-used_vol>@apply_vol --or r.run_total=used_vol
	
create index idx_delete_link11 on #delete_link (deal_number,gen_link_id)
				
delete  g from [gen_fas_link_detail] g inner join #delete_link t on g.deal_number=t.deal_number and g.gen_link_id=t.gen_link_id
				

select m.gen_link_id,m.deal_number ,@apply_vol-(r.run_total-used_vol) modify_vol
into #modify_link 
from #tmp_links m
	cross apply (select SUM(used_vol) run_total from #tmp_links l where rowid<=m.rowid) r
	where  ( r.run_total-used_vol>@apply_vol and @apply_vol<=r.run_total) or r.run_total=used_vol

if @@ROWCOUNT>0
begin

	update fld set percentage_included=m.modify_vol/sdd_vol.d_vol  
	from [gen_fas_link_detail] fld inner join #modify_link m on  m.gen_link_id=fld.gen_link_id and m.deal_number=fld.deal_number
	INNER JOIN	#tmp_links sdd_vol on m.deal_number=sdd_vol.deal_number and sdd_vol.gen_link_id=fld.gen_link_id
	
	if exists(select 1 from gen_fas_link_header where gen_link_id=@link_id and perfect_hedge='y')	
			return ---only update in hedge deal and not required to update in item deal
end

if exists(select 1 from #modify_link)	or 	exists(select 1 from #delete_link)
begin 
	declare @tot_itm_vol numeric(26,10)
	select @tot_itm_vol = SUM(fld.percentage_included*sdd_vol.d_vol) from [gen_fas_link_detail] fld 
		left JOIN	#tmp_links sdd_vol on fld.deal_number=sdd_vol.deal_number and fld.gen_link_id=@link_id
		and fld.gen_link_id=sdd_vol.gen_link_id		--and fld.hedge_or_item='i'
			

	set @st='
		insert into #tmp_links_h  (gen_link_id ,deal_number,used_vol,d_vol,d_date)
		select gen_link_id,source_deal_header_id, used_vol, d_vol, d_date from 
		(
		select gen_link_id,gfld.deal_number source_deal_header_id,sum(sdd.deal_volume * gfld.percentage_included) used_vol,sum(sdd.deal_volume) d_vol,max(sdh.deal_date) d_date 
		 from '+case when isnull(@forecated_tran,'n')='n' then ' source_deal_detail ' else ' gen_deal_detail ' end + ' sdd inner join gen_fas_link_detail gfld 
				on gfld.deal_number='+case when isnull(@forecated_tran,'n')='n' then '  sdd.source_deal_header_id ' else ' sdd.gen_deal_header_id ' end
				+' and sdd.Leg=1 and gfld.hedge_or_item='''+ case when @hedge_or_item='i' then 'h' else 'i' end +''' and gfld.gen_link_id=' + cast(@link_id as varchar)+'
				left join '+case when isnull(@forecated_tran,'n')='n'	then ' dbo.source_deal_header ' else ' gen_deal_header ' end +
				' sdh on gfld.deal_number='+case when isnull(@forecated_tran,'n')='n' then ' sdh.source_deal_header_id ' else ' sdh.gen_deal_header_id ' end
				+'	left join #dice_link dl on dl.link_id=gfld.gen_link_id
				left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id 
				where  dl.link_id is null 
				group by gfld.gen_link_id,gfld.deal_number
		) a order by '
			+ case when @FIFO_LIFO='f' then 'd_date,gen_link_id,source_deal_header_id'
					else 'd_date desc,gen_link_id desc,source_deal_header_id desc'	end
			
	EXEC spa_print @st
	exec(@st)


	drop table  #delete_link 

	select m.gen_link_id, m.deal_number into #delete_link_h from #tmp_links_h m
	cross apply (
		select SUM(used_vol) run_total from #tmp_links_h l where rowid<=m.rowid
	) r	where r.run_total-m.used_vol>@tot_itm_vol

	create index idx_delete_link_h11 on #delete_link_h (deal_number,gen_link_id)

	delete  g from [gen_fas_link_detail] g inner join #delete_link_h t on g.deal_number=t.deal_number and g.gen_link_id=t.gen_link_id

	drop table #modify_link

	select m.gen_link_id,m.deal_number ,@tot_itm_vol-(r.run_total-used_vol) modify_vol
	into #modify_link_h
	from #tmp_links_h m
		cross apply (
			select SUM(used_vol) run_total from #tmp_links_h l where rowid<=m.rowid
		) r
		where  (r.run_total-used_vol>@tot_itm_vol and @tot_itm_vol<=r.run_total)  or r.run_total=used_vol
		
	if @@ROWCOUNT>0
		update fld set percentage_included=modify_vol/sdd_vol.d_vol from [gen_fas_link_detail] fld inner join #modify_link_h m 
				on  m.gen_link_id=fld.gen_link_id and m.deal_number=fld.deal_number
			INNER JOIN	#tmp_links sdd_vol on m.deal_number=sdd_vol.deal_number and fld.gen_link_id=sdd_vol.gen_link_id
		
			
end 


