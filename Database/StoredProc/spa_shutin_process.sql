
if object_id('dbo.spa_shutin_process') is not null
drop proc dbo.spa_shutin_process

go

create proc [dbo].[spa_shutin_process]
 @flag varchar(1)='s'  --s=select
	,@nom_header_ids varchar(max)=null
	,@meter_ids 	 varchar(max)=null
	,@term_start datetime=null
	,@term_end datetime=null
	,@comments varchar(max)=null
	,@xml xml=null
	,@batch_process_id VARCHAR(100) = NULL
	,@batch_report_param VARCHAR(1000) = NULL

 AS
 SET NOCOUNT ON
/*

--EXEC spa_shutin_process  @flag='i',@nom_header_ids='309181',@term_start='2016-03-01',@term_end='2016-03-02',@comments=''

Declare 
	@flag varchar(1)='d'
	,@nom_header_ids varchar(max)='305835'
	,@meter_ids 	 varchar(max)='1010,2691,2692'
	,@term_start datetime='2016-03-03'
	,@term_end datetime='2016-03-05'
	,@comments varchar(max)=null
	,@xml xml=null
	,@batch_process_id VARCHAR(100) = NULL
	,@batch_report_param VARCHAR(1000) = NULL


--select  @flag='u',@xml='<Root><grid nom_groups_id="305835" meter_id="1010" comments="aaaaaa" process="r" term_start="2015-11-01 00:00:00.000" term_end="2015-11-05 00:00:00.000" /></Root>'

--select @flag='u',@xml='<Root><grid nom_groups_id="305835" meter_id="1010" comments="aaaaaafffffffffffffff" process="r" term_start="2015-11-01 00:00:00.000" term_end="2015-11-05 00:00:00.000" /></Root>'

--select @flag='s', @meter_ids=null, @term_start='2015-11-01', @term_end='2015-11-30'






--*/
 --select * from source_minor_location_nomination_group ng inner join 

Declare @st varchar(max) ,@channel_source varchar(5)='1' ,@channel_dist varchar(5)='2'
DECLARE  @job_name       VARCHAR(150),@user_name varchar(30)  ,@msg varchar(max)

SET @user_name= dbo.FNADBUser()		
SET @job_name = 'spa_shutin_process' + @batch_process_id

if object_id('tempdb..#shutin_detail') is not null
drop table #shutin_detail

if object_id('tempdb..#tmp_header') is not null
drop table #tmp_header

if object_id('tempdb..#exist_data_channel_2') is not null
drop table #exist_data_channel_2

if object_id('tempdb..#dist_meter_data_id') is not null
drop table  #dist_meter_data_id

if object_id('tempdb..#shutin_header') is not null
drop table  #shutin_header

if object_id('tempdb..#tmp_header_id') is not null
drop table  #tmp_header_id


 if object_id('tempdb..#save_xml') is not null
drop table  #save_xml


 if object_id('tempdb..#monthly_term') is not null
drop table  #monthly_term

  
select  scsv.item nom_group_id, @term_start flow_date_from,@term_end flow_date_to
into #tmp_header
from dbo.SplitCommaSeperatedValues(@nom_header_ids) scsv 

 -- select * from #tmp_header
 -- select @nom_header_ids

if @flag='s'
begin
	set @st=' 
		SELECT max(sdv.code) NomGroup,
			max(m.recorderid) + ''-'' + max(m.description) Meter,
			sd.nom_group_id,
			m.meter_id,
			dbo.FNADateFormat(sd.term_start) +'' ~ ''+  dbo.FNADateFormat(sd.term_end) Term,
			max(sd.comments) comments,
			max(sd.shutin_process) shutin_process
			, sd.term_start,sd.term_end
		from   dbo.shutin_detail sd
			inner join dbo.meter_id m  on sd.meter_id =m.meter_id
				and sd.term_start>='''+convert(varchar(10),	@term_start,120)+''' and sd.term_end<= '''+convert(varchar(10),	@term_end,120)+''''
			+case when @nom_header_ids is null then '' else ' inner join #tmp_header th on sd.nom_group_id=th.nom_group_id ' end +'
			INNER JOIN static_data_value  AS sdv
				ON  sdv.value_id = sd.nom_group_id '
		+case when @meter_ids is null then '' else '
				cross apply dbo.SplitCommaSeperatedValues('''+@meter_ids+''') scsv
			where  	scsv.item=sd.meter_id	  '
		end
		+ case when @comments is null then '' else ' and sd.comments like ''%' + @comments + '%''' end 
		+'
		Group by sd.nom_group_id,m.meter_id, sd.term_start,sd.term_end
		'
	EXEC spa_print @st
	exec(@st)

	return

end

CREATE TABLE #shutin_header
(
	shutin_header_id	INT ,
	nom_group_ids varchar(1000) COLLATE DATABASE_DEFAULT,
	flow_date_from datetime,
	flow_date_to datetime
)	

create table #tmp_header_id(shutin_header_id int)

create table #shutin_detail
(
	nom_group_id int,
	meter_id int,
	flow_date datetime,	
	shutin_process varchar(1) COLLATE DATABASE_DEFAULT,term_start datetime,comments varchar(max) COLLATE DATABASE_DEFAULT
)





Begin Try
	begin tran
	 if @xml is null and @flag<>'r'	and @flag not in ('d')   --shutin process
	 begin

		set @msg='Shutin'
		if exists(
			select top(1) 1 aa from dbo.shutin_detail sd inner join #tmp_header tih   on tih.nom_group_id=sd.nom_group_id
				and (tih.flow_date_from between sd.term_start and sd.term_end or  tih.flow_date_to  between sd.term_start and sd.term_end)
			)
		begin
		
			if @batch_process_id is null
				EXEC spa_ErrorHandler 1
					, 'Meter Shutin Process'
					, 'spa_shutin_process'
					, 'Error'
					, 'Nom Group is already shut in for the term. Please select other date range.'
					, ''		
			else
				EXEC spa_message_board 'u', @user_name, NULL, 'Run Shutin Process', 'Nom Group is already Shut In for the term. Please select any other date range. (Found Error).', '', '', 'c', @job_name, NULL, @batch_process_id	

			 return
		end

		select cast(convert(varchar(8),t.term_start,120)+'01' as datetime) term_start,  dbo.FNAGetTermEndDate('m',t.term_end,0) term_end 
		into #monthly_term
		from dbo.FNATermBreakdown('m',@term_start,@term_end) t

		insert into dbo.shutin_header
		(
			nom_group_ids,
			flow_date_from ,
			flow_date_to 	
		)	
		output inserted.shutin_header_id,inserted.nom_group_ids,inserted.flow_date_from,inserted.flow_date_to  into #shutin_header
		select 	 @nom_header_ids ,@term_start ,@term_end
		
		set @st='
			insert into dbo.shutin_detail
			(
				shutin_header_id,nom_group_id,meter_id,flow_date,comments,shutin_process,term_start,term_end
			)
			output inserted.nom_group_id,inserted.meter_id , inserted.flow_date ,inserted.shutin_process,inserted.term_start,inserted.comments 
			into #shutin_detail  (nom_group_id,meter_id,flow_date,shutin_process,term_start,comments)
			select a.shutin_header_id,a.nom_group_id,a.meter_id,a.term_start,a.comments,a.shutin_process,a.flow_date_from,a.flow_date_to
			from (
				select sh.shutin_header_id,tih.nom_group_id,ng.effective_date,smlm.meter_id
					, DENSE_RANK() over(partition by smlm.meter_id order by ng.effective_date desc) rnk
					,t.term_start,'''+isnull(@comments,'')+''' comments,''s'' shutin_process
					,sh.flow_date_from,sh.flow_date_to
				from #tmp_header tih cross join #shutin_header sh 
				inner join source_minor_location_nomination_group ng	on tih.nom_group_id=ng.group_id -- and sh.shutin_header_id=@shutin_header_id
				cross apply dbo.[FNATermBreakdown](''d'',tih.flow_date_from,tih.flow_date_to ) t
				inner join source_minor_location_meter smlm	 on ng.source_minor_location_id=smlm.source_minor_location_id  
			) a
			where a.rnk=1 
			'

		exec spa_print @st
		exec(@st)
		if not exists(select top 1 1 from #shutin_detail)
		begin
			raiserror('blank_shutin_detail', 16, 1)
		end
		--return

		select distinct d.meter_data_id,d.meter_id,d.from_date , d.to_date into #exist_data_channel_2 
		from  [dbo].mv90_data d 
		inner join #shutin_detail sd on sd.meter_id=d.meter_id and sd.flow_date between d.from_date and d.to_date
			and d.channel=2


		INSERT INTO [dbo].[mv90_data](
			[meter_id],[gen_date],[from_date],[to_date],[channel],[volume]
			,[uom_id],[descriptions],[create_user],[create_ts],[update_user],[update_ts]
		)
		select distinct
		 dmd.[meter_id],mt.term_start,mt.term_start,mt.term_end,2 [channel],isnull(mvh.[volume],0) [volume]
			,mvh.[uom_id],mvh.[descriptions],dbo.FNADBUser() [create_user],getdate() [create_ts],dbo.FNADBUser() [update_user],getdate() [update_ts] 
		
		--select *
		from #shutin_detail dmd
		outer apply (
				select 	 top(1)	  h.meter_data_id,d.gen_date,d.from_date,d.to_date
					,case when h2.[Hr1] <> 0 then h2.[Hr1] else h.[Hr1] end [volume]
					,d.[uom_id],d.[descriptions],d.[meter_id] 
				from   [dbo].mv90_data d 
				inner join [dbo].[mv90_data_hour] h on h.meter_data_id=d.meter_data_id
					--and h.prod_date<dmd.term_start 
					and h.prod_date = dateadd(dd, -1, dmd.term_Start)
					--and isnull(h.Hr1,0)<>0	 
					and d.channel=1
					and d.meter_id=dmd.meter_id
				LEFT JOIN [dbo].[mv90_data_hour] h2 on h2.meter_data_id=d.meter_data_id
					and h2.prod_date = dateadd(dd, -1, dmd.term_Start)
					--and isnull(h.Hr1,0)<>0
					and d.channel=2
					and d.meter_id=dmd.meter_id
				order by   h.prod_date desc
		)  mvh
		left join #monthly_term mt on dmd.flow_date between mt.term_start and mt.term_end
		left join #exist_data_channel_2 ex on mvh.meter_id=ex.meter_id AND ex.from_date = mt.term_start AND ex.to_date = mt.term_end
		where  ex.meter_data_id is null

		 --drop table #dist_meter_data_id

		select  d.meter_data_id,sd.meter_id,sd.flow_date,sd.term_start  
		into #dist_meter_data_id
		from #shutin_detail sd inner join [dbo].mv90_data d 
			on sd.meter_id=d.meter_id and sd.shutin_process='s'
			and sd.flow_date between d.from_date and d.to_date  and d.channel=2
		
		delete [dbo].[mv90_data_hour]
		from  #shutin_detail sd 
 			inner join [dbo].mv90_data mvd on mvd.meter_id=sd.meter_id and sd.shutin_process='s'  and mvd.channel=2
			inner join [dbo].[mv90_data_hour] s on s.meter_data_id=mvd.meter_data_id
				and s.prod_date=sd.flow_date   

		INSERT INTO [dbo].[mv90_data_hour]
		(
			[meter_data_id],[prod_date]
			,[Hr1],[Hr2],[Hr3],[Hr4],[Hr5],[Hr6],[Hr7]
			,[Hr8],[Hr9],[Hr10],[Hr11],[Hr12],[Hr13],[Hr14],[Hr15],[Hr16]
			,[Hr17],[Hr18],[Hr19],[Hr20],[Hr21],[Hr22],[Hr23],[Hr24],[Hr25]
			,[uom_id],[data_missing],[proxy_date],[source_deal_header_id],[period]
		)
		select 
			dmd.[meter_data_id],dmd.flow_date
			, COALESCE(NULLIF(s2.[Hr1], 0), s.[Hr1], 0),s.[Hr2],s.[Hr3],s.[Hr4],s.[Hr5],s.[Hr6],s.[Hr7]
			,s.[Hr8],s.[Hr9],s.[Hr10],s.[Hr11],s.[Hr12],s.[Hr13],s.[Hr14],s.[Hr15],s.[Hr16]
			,s.[Hr17],s.[Hr18],s.[Hr19],s.[Hr20],s.[Hr21],s.[Hr22],s.[Hr23],s.[Hr24],s.[Hr25]
			,s.[uom_id],s.[data_missing],s.[proxy_date],s.[source_deal_header_id],s.[period]
		-- select *
		from #dist_meter_data_id dmd
		outer apply (
			select 	 top(1)	   h.prod_date ,h.meter_data_id 
			from   [dbo].mv90_data d 
			inner join [dbo].[mv90_data_hour] h on h.meter_data_id=d.meter_data_id
				--and h.prod_date<dmd.term_start 
				and h.prod_date = dateadd(dd, -1, dmd.term_Start)
				--and isnull(h.Hr1,0)<>0	 
				and d.channel=1
				and d.meter_id=dmd.meter_id
			order by   h.prod_date desc
		) dt
		left join [dbo].[mv90_data_hour] s on s.meter_data_id=dt.meter_data_id
			and s.prod_date=dt.prod_date
		outer apply (
			select 	 top(1)	   h.prod_date ,h.meter_data_id 
			from   [dbo].mv90_data d 
			inner join [dbo].[mv90_data_hour] h on h.meter_data_id=d.meter_data_id
				--and h.prod_date<dmd.term_start 
				and h.prod_date = dateadd(dd, -1, dmd.term_Start)
				--and isnull(h.Hr1,0)<>0	 
				and d.channel=2
				and d.meter_id=dmd.meter_id
			order by   h.prod_date desc
		) dt2
		left join [dbo].[mv90_data_hour] s2 on s2.meter_data_id=dt2.meter_data_id
			and s2.prod_date=dt2.prod_date
		--where isnull(s.[Hr1],0)<>0	

		--return

	end
	else	 --save or undo shutin process
	begin

		set @msg='Undo Shutin'

		if @flag='r'	 --	manually run from backend undo shutin process
		begin

			set @st='
			insert into  #shutin_detail (nom_group_id,meter_id,flow_date,shutin_process,term_start,comments)
			select tih.nom_group_id,smlm.meter_id,t.term_start,''r'',tih.flow_date_from,'''+isnull(@comments,'')+'''
			from #tmp_header tih 
				inner join source_minor_location_nomination_group ng	on tih.nom_group_id=ng.group_id -- and sh.shutin_header_id=@shutin_header_id
				cross apply dbo.[FNATermBreakdown](''d'',tih.flow_date_from,tih.flow_date_to ) t
				inner join source_minor_location_meter smlm	 on ng.source_minor_location_id=smlm.source_minor_location_id  '
				+case when @meter_ids  is null then '' else ' and smlm.meter_id in ('''+ @meter_ids+''')' end

			exec spa_print @st
			exec(@st)

		end
		else	  -- undo shutin process call from frontend
		begin

			create table #save_xml
			( 
				nom_group_id int,
				meter_id int,
				term_start datetime,
				term_end datetime,	
				comments varchar(max) COLLATE DATABASE_DEFAULT,
				shutin_process	varchar(1) COLLATE DATABASE_DEFAULT,	--s=shutin; r=revert
			)


			--select * from #save_xml
			INSERT INTO #save_xml
			SELECT a.nom_group_id,a.meter_id,nullif(a.term_start,'1900-01-01') term_start,nullif(a.term_end,'1900-01-01') term_end,a.comments,a.shutin_process
			FROM 
			(
				SELECT
					doc.col.value('@nom_groups_id', 'int') nom_group_id
					,doc.col.value('@meter_id', 'int') meter_id
					,doc.col.value('@term_start', 'datetime') term_start 
					,doc.col.value('@term_end', 'datetime') term_end
					,doc.col.value('@comments', 'varchar(max)') comments 
					,doc.col.value('@process', 'varchar(1)') shutin_process 
				FROM @xml.nodes('/Root/grid') doc(col)
			) a

			if @flag = 'd'
			begin
				delete md
				--select md.*
				from mv90_data_hour md
				inner join mv90_data mh on md.meter_data_id = mh.meter_data_id and mh.channel = 2
				inner join dbo.SplitCommaSeperatedValues(@meter_ids) scsv on scsv.item = mh.meter_id
				where 1=1
					and md.prod_date between @term_start and @term_end
								
				delete sd
				--select *
				from shutin_detail sd
				inner join dbo.SplitCommaSeperatedValues(@meter_ids) scsv on scsv.item = sd.meter_id
				where 1=1 and sd.nom_group_id = @nom_header_ids and sd.flow_date between @term_start and @term_end

				update sh set sh.nom_group_ids = case when ca_exclude.nom_filter is null then '-1' else ca_exclude.nom_filter end
				--select sh.*, sh.nom_group_ids, ca_exclude.*
				from shutin_header sh 
				cross apply (
					select item 
					from dbo.SplitCommaSeperatedValues(sh.nom_group_ids) scsv 
					where scsv.item = @nom_header_ids
				) ca_filter
				outer apply (
					select stuff(
						(select ',' + item 
						from dbo.SplitCommaSeperatedValues(sh.nom_group_ids) scsv 
						where scsv.item <> @nom_header_ids
						for xml path('')
						)
					, 1, 1, '') nom_filter
				) ca_exclude
				where 1=1  
					and sh.flow_date_from = @term_start and sh.flow_date_to = @term_end

				delete shutin_header where nom_group_ids = '-1'
				commit
				EXEC spa_ErrorHandler 0
					, 'Meter Shutin Process'
					, 'spa_shutin_process'
					, 'Success'
					, 'Delete shutin success.'
					, ''
				return
			end

					insert into #shutin_detail(nom_group_id,meter_id,flow_date,shutin_process,term_start,comments)
			select sx.nom_group_id,sx.meter_id,t.term_start,sx.shutin_process, sx.term_start,sx.comments 
			from #save_xml sx
				cross apply dbo.FNATermBreakdown('d',sx.term_start,sx.term_end) t
			where  1=1
				--and sx.shutin_process='r'  
				and isnull(sx.meter_id,0)<>0	--and isnull(sx.nom_group_id,0) =0
				
			insert into #shutin_detail(nom_group_id,meter_id,flow_date,shutin_process,term_start,comments)
			select sx.nom_group_id,sd.meter_id,sd.flow_date,ISNULL(NULLIF(sx.shutin_process,''),sd.shutin_process), sd.term_start,sx.comments 
			from #save_xml sx
				inner join dbo.shutin_detail sd on sx.nom_group_id =sd.nom_group_id
					and   isnull(sx.term_start,sd.term_start)=sd.term_start and isnull(sx.term_end,sd.term_end)=sd.term_end
			where  1=1 
				--and sx.shutin_process='r' 
				and isnull(sx.meter_id,0)=0 and  isnull(sx.nom_group_id,0) <>0
			

		--  select * from #shutin_detail
		--select * from	  #save_xml
		--		select * from	  dbo.shutin_detail
		end

		update 	dbo.shutin_detail set shutin_process=case when sd.shutin_process = 'r' then 'r' else tsd.shutin_process end,comments=tsd.comments 
		--select *
		from dbo.shutin_detail sd inner join #shutin_detail tsd on sd.meter_id=tsd.meter_id
			and   sd.flow_date=tsd.flow_date   and sd.term_start=tsd.term_start

		
		 update [dbo].[mv90_data_hour] set 
			[Hr1]=0,[Hr2]=0,[Hr3]=0,[Hr4]=0,[Hr5]=0,[Hr6]=0,[Hr7]=0
			,[Hr8]=0,[Hr9]=0,[Hr10]=0,[Hr11]=0,[Hr12]=0,[Hr13]=0,[Hr14]=0,[Hr15]=0,[Hr16]=0
			,[Hr17]=0,[Hr18]=0,[Hr19]=0,[Hr20]=0,[Hr21]=0,[Hr22]=0,[Hr23]=0,[Hr24]=0,[Hr25]	=0
		 --select *
		 from  #shutin_detail sd 
 			inner join [dbo].mv90_data mvd on mvd.meter_id=sd.meter_id and sd.shutin_process='r'  and mvd.channel=2
			inner join [dbo].[mv90_data_hour] mvh on mvh.meter_data_id=mvd.meter_data_id
				and mvh.prod_date=sd.flow_date 
		where 1=1 
			and sd.shutin_process = 'r'

	end


	update [dbo].[mv90_data] set volume= mvh.volume
	--select mvd.meter_id , mvh.volume
	from 	[dbo].mv90_data mvd 
	inner join #shutin_detail ds on ds.meter_id=mvd.meter_id and ds.flow_date between mvd.from_date and mvd.to_date
	cross apply
	(
		select sum(isnull([Hr1],0)+isnull([Hr2],0)+isnull([Hr3],0)+isnull([Hr4],0)+isnull([Hr5],0)+isnull([Hr6],0)+isnull([Hr7],0)
			+isnull([Hr8],0)+isnull([Hr9],0)+isnull([Hr10],0)+isnull([Hr11],0)+isnull([Hr12],0)+isnull([Hr13],0)+isnull([Hr14],0)
			+isnull([Hr15],0)+isnull([Hr16],0)+isnull([Hr17],0)+isnull([Hr18],0)+isnull([Hr19],0)+isnull([Hr20],0)
			+isnull([Hr21],0)+isnull([Hr22],0)+isnull([Hr23],0)+isnull([Hr24],0)) volume
		from [dbo].[mv90_data_hour]  h
		where  h.meter_data_id=mvd.meter_data_id
			and h.prod_date between mvd.from_date and mvd.to_date
	)  mvh
	 where mvd.channel=2
		and ds.shutin_process = 'r'
	
	commit
	set @msg='Run '+@msg+' Process successfully completed.'	
	if @batch_process_id is null
		EXEC spa_ErrorHandler 0
			, 'Meter Shutin Process'
			, 'spa_shutin_process'
			, 'Success'
			, @msg
			, ''		
	else
		EXEC spa_message_board 'u', @user_name, NULL, 'Run Shutin Process', @msg, '', '', 'c', @job_name, NULL, @batch_process_id	
END TRY
BEGIN CATCH
	if(ERROR_MESSAGE() = 'blank_shutin_detail')
	begin
		set @msg = 'Run shutin process. Error found (No Meters mapped to this Nom Group).'
	end
	else
	begin
		set @msg='Run '+@msg+' Process successfully completed (Foud Error).'
	end
	EXEC spa_print 'Catch Error:' --+ ERROR_MESSAGE()
			
	rollback
	if @batch_process_id is null
		EXEC spa_ErrorHandler 1
			, 'Meter Shutin Process'
			, 'spa_shutin_process'
			, 'Error'
			, @msg
			, ''		
	
	else
		EXEC spa_message_board 'u', @user_name, NULL, 'Run Allocation Process', @msg, '', '', 'c', @job_name, NULL, @batch_process_id	

	--EXEC spa_ErrorHandler 1
	--, 'Volume Allocation Process'
	--, 'spa_calc_allocation_process'
	--, 'Error'
	--, 'Fail to Allocate Volume Process.'
	--, ''

END CATCH



/*


select * from  #shutin_detail where meter_id in	( 1010,2691 ,2692)
select * from [mv90_data_hour] where meter_data_id in (63716,63717,63718 )
-- delete  [mv90_data] where meter_data_id in (63719,
63722,63718,
63721,63717,
63720 )
select * from [mv90_data_hour] where meter_data_id in (64716 )

select * from [mv90_data] where --meter_id in ( 1010) and
 channel=2	

select * from #exist_data_channel_2

--delete dbo.shutin_header

delete mv90_data_hour where recid in (
2562014,
2562015,
2562016,
2562017	)

[mv90_data] where --meter_id in ( 1010) and
 channel=2	

delete mv90_data_hour where meter_data_id in (
63723 ,
63724,
64716	)

63723
63724
64716

   */
