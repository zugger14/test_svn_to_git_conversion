if object_id('dbo.[spa_exclude_deal_auto_matching]') is not null
drop proc dbo.[spa_exclude_deal_auto_matching]
 go 
Create proc dbo.[spa_exclude_deal_auto_matching] @flag char(1),@rowid int=null, @source_deal_header_id1 int=null,
 @source_deal_header_id2 int=null, @exclude_flag varchar(1)=null,@deal_id varchar(150)=null,@deal_id_filter_option varchar(1)='y'

 AS 
SET NOCOUNT ON
/*
exec spa_exclude_deal_auto_matching
@flag='i'
,@rowid=null
, @source_deal_header_id1=11358
,@source_deal_header_id2=null
, @exclude_flag ='r'
,@deal_id=null
,@deal_id_filter_option='y'


--*/


declare @msg_err varchar(2000),@sql varchar(max)
declare @exclude_curve_id varchar(50)
set @exclude_curve_id='FX_EUR'

Begin try
	If @flag='i'
		insert into [exclude_deal_auto_matching] (source_deal_header_id1, source_deal_header_id2, exclude_flag, create_user, create_ts) values (@source_deal_header_id1, @source_deal_header_id2, @exclude_flag, dbo.FNADBUser(), GETDATE())
	else If @flag='u'
		update [exclude_deal_auto_matching] set source_deal_header_id1=@source_deal_header_id1, source_deal_header_id2=@source_deal_header_id2, exclude_flag=@exclude_flag, update_user = dbo.FNADBUser(), update_ts =  GETDATE() where rowid=@rowid
	else If @flag='d'
		delete [exclude_deal_auto_matching]  where rowid=@rowid
	else If @flag='a'
		select rowid, source_deal_header_id1, source_deal_header_id2, exclude_flag from [exclude_deal_auto_matching]  where rowid=@rowid
	else If @flag='s'
	begin
		set @sql=''

		if @source_deal_header_id1 is not null or  @deal_id is not null
		begin
			if @source_deal_header_id1 is not null
				set @sql=@sql+ ' and (ex.source_deal_header_id1='+cast(@source_deal_header_id1 as varchar) +' or ex.source_deal_header_id2='+cast(@source_deal_header_id1 as varchar) +')'
			
			if @deal_id is not null
			begin
				set @sql=@sql+ ' and (sdh1.deal_id' +case when isnull(@deal_id_filter_option,'n')='n' then '='''+ @deal_id + '''' ELSE ' like ''' + @deal_id +'%''' END 
				+ ' OR sdh2.deal_id' +case when isnull(@deal_id_filter_option,'n')='n' then '='''+ @deal_id + '''' else ' like ''' + @deal_id +'%''' END + ')'
			
			end
		end
		else
		begin
			 if  isnull(@exclude_flag ,'b')<>'b' 
				set @sql=@sql+ ' and exclude_flag='''+ @exclude_flag+ ''''
		END
		create table #used_percentage (source_deal_header_id int,used_percentage FLOAT)
		insert into #used_percentage (source_deal_header_id,used_percentage)
		select source_deal_header_id,sum(percentage_use) from (
				select 	dh.source_deal_header_id,sum(gfld.percentage_included) as  percentage_use,max('o') src
				from 	source_deal_header dh 
				INNER JOIN
					gen_fas_link_detail gfld ON gfld.deal_number = dh.source_deal_header_id 
				INNER JOIN
					gen_fas_link_header gflh ON gflh.gen_link_id = gfld.gen_link_id
					 AND gflh.gen_status = 'a'
				GROUP BY dh.source_deal_header_id, dh.deal_date
			union all
				select source_deal_header_id
				, sum(percentage_included) percentage_included,max('f') 
				from fas_link_detail inner join fas_link_header
				on  fas_link_detail.link_id=fas_link_header.link_id group by source_deal_header_id
			union all
				select a.source_deal_header_id , sum(a.[per_dedesignation]) [per_dedesignation],max('l') src from 
				(
					select distinct process_id ,source_deal_header_id ,[per_dedesignation] from [dbo].[dedesignated_link_deal]
				) a group by a.source_deal_header_id

		) used_per group by used_per.source_deal_header_id
		
		select source_deal_header_id,sum(isnull(deal_volume,0)) vol into #deal_volume from source_deal_detail sdd1
		inner join source_price_curve_def on sdd1.curve_id=source_price_curve_def.source_curve_def_id and source_price_curve_def.curve_id<>@exclude_curve_id
		where sdd1.curve_id is not null
		group by sdd1.source_deal_header_id
		
		set @sql='
			select rowid, source_deal_header_id1 [Der. Deal ID], sdh1.deal_id [Der. Ref. Deal ID] ,round(isnull(dv1.vol,0) * (1-isnull(up1.used_percentage,0)),2) [Available Der. Volume],
				source_deal_header_id2 [Exp. Deal ID], sdh2.deal_id [Exp. Ref. Deal ID], round(isnull(dv2.vol,0) *(1-isnull(up2.used_percentage,0)),2) [Available Exp. Volume]
				, case when exclude_flag=''m'' then ''No Match'' else ''No Process'' end [Exclude Option] 				
				from [exclude_deal_auto_matching] ex 
				left join source_deal_header sdh1 on sdh1.source_deal_header_id=ex.source_deal_header_id1
				left join source_deal_header sdh2 on sdh2.source_deal_header_id=ex.source_deal_header_id2
				left join #used_percentage up1 on up1.source_deal_header_id=ex.source_deal_header_id1
				left join #used_percentage up2 on up2.source_deal_header_id=ex.source_deal_header_id2
				left join #deal_volume dv1 on dv1.source_deal_header_id=ex.source_deal_header_id1
				left join #deal_volume dv2 on dv2.source_deal_header_id=ex.source_deal_header_id2

			 where 1=1 ' + @sql
		--print @sql
		exec(@sql)
	end
	DECLARE @msg varchar(2000)
	SELECT @msg=''
	if @flag='i'
		SET @msg='The selected record(s) are successfully unmatched/unprocessed.'
	ELSE if @flag='u'
		SET @msg='Data Successfully Updated.'
	ELSE if @flag='d'
		SET @msg=' The selected record is successfully deleted.'

	IF @msg<>''
		select 'Success' ErrorCode, 'exclude_deal_auto_matchingtable' Module, 
				'spa_exclude_deal_auto_matching' Area, 'Success' [Status], 
				@msg [Message], '' Recommendation

END try
begin catch
	DECLARE @error_number int
	SET @error_number=error_number()
	SET @msg_err=''


	if @flag='i'
		SET @msg_err='Fail Insert Data.'
	ELSE if @flag='u'
		SET @msg_err='Fail Update Data.'
	ELSE if @flag='d'
		SET @msg_err='Fail Delete Data.'
	SET @msg_err='Fail Delete Data (' + error_message() +')'
		select -1 ErrorCode, 'exclude_deal_auto_matchingtable' Module, 
				'spa_exclude_deal_auto_matching' Area, 'DB Error' [Status], 
				@msg_err [Message], '' Recommendation


END catch
