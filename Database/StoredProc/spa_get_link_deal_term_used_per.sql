
if OBJECT_ID('spa_get_link_deal_term_used_per') is not null
drop proc dbo.spa_get_link_deal_term_used_per

go
create proc dbo.spa_get_link_deal_term_used_per 
	@as_of_date date=null --while calling from measurement process ,@as_of_date parameter is passed as null
	,@link_ids varchar(max)=null
	,@header_deal_id varchar(max)=null
	,@term_start date=null
	,@no_include_link_id int=null --this parameter will be passed while calling from dicing term entry as the % allocation for deal in link is already saved before dicing term save
	,@output_type int =0 -- 0 is format for validation percent used deal and is called from dicing term entry. 1= from measurement process
	,@include_gen_tranactions char(1) = 'b' --n=not include; a=approved only; u=unapproved only; b=both approved and unapproved
	,@process_table varchar(500)=null,@call_from int=0 --1=from measurement ->collect
as

/*

declare @as_of_date date=null
	,@header_deal_id varchar(max)='592104'
	,@term_start date=null --'2012-06-01'
	,@no_include_link_id int=null
	,@output_type int =0

--*/


declare @st varchar(max),@st_fields varchar(max)

set @st='select ' +
	case  isnull(@output_type,0)
		when 0 then 'term_start,sum(percentage_used) percentage_used'
		when 1 then 'link_id,source_deal_header_id,term_start,sum(percentage_used) percentage_used,max(effective_date) effective_date'
		when 2 then 'avg(percentage_used) percentage_used'
	end
	+case when isnull(@process_table,'')<>'' then ' into '  +isnull(@process_table,'') else '' end +
	'
	from ( --all the term of link,deal that do not have dicing
		select fld.link_id,fld.source_deal_header_id,sdd.term_start,CASE WHEN '''+isnull(CONVERT(VARCHAR(10),@as_of_date,120),'1900-01-01') +''' >=ISNULL(flh.link_end_date,''9999-01-01'') THEN 0 ELSE isnull(fld.percentage_included,0) END  percentage_used,isnull(fld.effective_date,flh.link_effective_date) effective_date 
		from fas_link_detail fld
			inner join fas_link_header flh on flh.link_id=fld.link_id and flh.link_type_value_id in (450'+case when isnull(@call_from,0)=1 then  ',451,452' else '' end +')  ' +
			case when @no_include_link_id is not null then ' and flh.link_id<>'+CAST(@no_include_link_id as varchar) else '' end
			+case when @link_ids is not null then ' and flh.link_id in ('+@link_ids+')' else '' end	+'
			inner join source_deal_detail sdd on fld.source_deal_header_id=sdd.source_deal_header_id and sdd.leg=1'
			+case when @header_deal_id is not null then ' and sdd.source_deal_header_id in (' +@header_deal_id +')' else '' end
			+case when @term_start is not null then ' and sdd.term_start='''+convert(varchar(10),@term_start,120)+ '''' else '' end+'
			left join (select distinct link_id,source_deal_header_id from dbo.fas_link_detail_dicing ) fldd 
				on isnull(flh.original_link_id, flh.link_id)=fldd.link_id and  fld.source_deal_header_id =fldd.source_deal_header_id 
		where fldd.link_id is null '
		+case when isnull(@include_gen_tranactions,'b')<>'n' then 
			'union all
			select gfld.gen_link_id,sdd.source_deal_header_id,sdd.term_start,gfld.percentage_included  percentage_used,isnull(gfld.effective_date,gflh.link_effective_date) effective_date 
			from gen_fas_link_detail gfld
				inner join gen_fas_link_header gflh on gflh.gen_link_id=gfld.gen_link_id  '+
				case  isnull(@include_gen_tranactions,'b') 
					when 'b'  then ' AND gflh.gen_status = ''a''' 
					when 'a' then ' AND (gflh.gen_status = ''a'' AND gflh.gen_approved = ''y'' )'
					when 'u' then ' AND (gflh.gen_status = ''a'' AND gflh.gen_approved = ''n'' )'
					else '' 
				end
			+case when @no_include_link_id is not null then ' and gflh.gen_link_id<>'+CAST(@no_include_link_id as varchar) else '' end+'
			inner join source_deal_detail sdd on gfld.deal_number=sdd.source_deal_header_id  and sdd.leg=1'
			+case when @header_deal_id is not null then ' and sdd.source_deal_header_id in (' +@header_deal_id +')' else '' end
			+case when @term_start is not null then ' and sdd.term_start='''+convert(varchar(10),@term_start,120)+ '''' else '' end
			+' left join (select distinct link_id,source_deal_header_id from dbo.gen_fas_link_detail_dicing ) fldd 
				on  gflh.gen_link_id=fldd.link_id and  gfld.deal_number =fldd.source_deal_header_id 
				where fldd.link_id is null
			union all
			select gfld.gen_link_id,sdd.source_deal_header_id,sdd.term_start,isnull(fldd.percentage_used,1)*gfld.percentage_included percentage_used,isnull(gfld.effective_date,gflh.link_effective_date) effective_date 
			from gen_fas_link_detail gfld
				inner join gen_fas_link_header gflh on gflh.gen_link_id=gfld.gen_link_id  '+
				case  isnull(@include_gen_tranactions,'b') 
					when 'b'  then ' AND gflh.gen_status = ''a''' 
					when 'a' then ' AND (gflh.gen_status = ''a'' AND gflh.gen_approved = ''y'' )'
					when 'u' then ' AND (gflh.gen_status = ''a'' AND gflh.gen_approved = ''n'' )'
					else '' 
				end
			+case when @no_include_link_id is not null then ' and gflh.gen_link_id<>'+CAST(@no_include_link_id as varchar) else '' end+'
			inner join source_deal_detail sdd on gfld.deal_number=sdd.source_deal_header_id  and sdd.leg=1'
			+case when @header_deal_id is not null then ' and sdd.source_deal_header_id in (' +@header_deal_id +')' else '' end
			+case when @term_start is not null then ' and sdd.term_start='''+convert(varchar(10),@term_start,120)+ '''' else '' end
			+'inner join  dbo.gen_fas_link_detail_dicing fldd on gflh.gen_link_id=fldd.link_id 
				and  gfld.deal_number =fldd.source_deal_header_id and sdd.term_start=fldd.term_start 
			'
		else ''
		end +'
		union all ----all the term of link,deal that have dicing only.
		select fld.link_id,fld.source_deal_header_id,sdd.term_start,
		CASE WHEN '''+isnull(CONVERT(VARCHAR(10),@as_of_date,120),'1900-01-01') +'''>=ISNULL(flh.link_end_date,''9999-01-01'') THEN 0 ELSE isnull(fldd.percentage_used,0)*fld.percentage_included END  percentage_used,fldd.effective_date 
		from fas_link_detail fld
			inner join fas_link_header flh on flh.link_id=fld.link_id  and flh.link_type_value_id  in (450'+ case when isnull(@call_from,0)=1 then  ',451,452' else '' end +')' +
			case when @no_include_link_id is not null then ' and flh.link_id<>'+CAST(@no_include_link_id as varchar) else '' end
			+case when @link_ids is not null then ' and flh.link_id in ('+@link_ids+')' else '' end	+'
			inner join source_deal_detail sdd on fld.source_deal_header_id=sdd.source_deal_header_id and sdd.leg=1'
			+case when @header_deal_id is not null then ' and sdd.source_deal_header_id in (' +@header_deal_id +')' else '' end
			+case when @term_start is not null then ' and sdd.term_start='''+convert(varchar(10),@term_start,120)+ '''' else '' end+'
			inner join  dbo.fas_link_detail_dicing fldd on isnull(flh.original_link_id, flh.link_id)=fldd.link_id 
				and  fld.source_deal_header_id =fldd.source_deal_header_id 	and sdd.term_start=fldd.term_start 
	) src 
	group by '+
	case  isnull(@output_type,0)
		when 0 then 'source_deal_header_id,term_start'
		when 1 then 'link_id,source_deal_header_id,term_start'
		when 2 then 'source_deal_header_id'
	end 
	
exec spa_print @st
exec(@st)

