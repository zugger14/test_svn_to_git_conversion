IF OBJECT_ID(N'[dbo].[spa_get_dealblockdetail]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_dealblockdetail]
GO 

--spa_get_dealblockdetail NULL,301,2004
create procedure [dbo].[spa_get_dealblockdetail] 
	@source_deal_header_id varchar(1000) = null, 
	@book_deal_type_map_id varchar(100) = null,
	@source_deal_detail_id varchar(1000) = null,
	@assign_type int = null
As

-- declare @source_deal_header_id varchar(100),
-- @book_deal_type_map_id varchar(100),@source_deal_detail_id varchar(100)
-- --set @source_deal_header_id='2059'
-- set @book_deal_type_map_id='288'
-- drop table #temp_assign
-- drop table #temp_cert

declare @gis_deal_id int,@certificate_f int,@certificate_t int,@deal_volume int,
@cert_from int,@cert_to int,@bank_assignment int,@sql varchar(5000)
set @bank_assignment=5149


create TABLE #temp_assign(
source_deal_detail_id int,
cert_from int,
cert_to int,
assignment_type int,
total_volume int
)
create table #temp_cert(
source_deal_header_id int,
certificate_number_from_int int,
certificate_number_to_int int,
deal_volume int
)
set @sql='insert #temp_cert
	select gis.source_deal_header_id,gis.certificate_number_from_int,gis.certificate_number_to_int,deal_volume 
	from gis_certificate gis join source_deal_detail sdd on gis.source_deal_header_id=sdd.source_deal_detail_id
	join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id
	join source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND         
	 sdh.source_system_book_id2 = sbm.source_system_book_id2 AND         
	 sdh.source_system_book_id3 = sbm.source_system_book_id3 AND         
	 sdh.source_system_book_id4 = sbm.source_system_book_id4   
	where sdd.volume_left > 0 	   
	' + case when (@source_deal_header_id IS NULL) THEN ''         
	 else ' and sdh.source_deal_header_id in (' + @source_deal_header_id + ')' end         
	+ case when (@source_deal_detail_id IS NULL) THEN ''         
	 else ' and sdd.source_deal_detail_id in (' + @source_deal_detail_id + ')' end  
	+ case when (@book_deal_type_map_id IS NULL) THEN ''         
	 else ' and sbm.book_deal_type_map_id in (' + @book_deal_type_map_id + ')' end         
	
exec(@sql)
DECLARE cursor1 cursor FOR
	select source_deal_header_id,certificate_number_from_int,certificate_number_to_int,deal_volume from #temp_cert
 open cursor1
 fetch next from cursor1
 into  	@gis_deal_id,@certificate_f,@certificate_t,@deal_volume
 	

 WHILE @@FETCH_STATUS=0
 BEGIN

	DECLARE cursor2 cursor for 
		select cert_from,cert_to from assignment_audit where source_deal_header_id_from=@gis_deal_id and assigned_volume>0
		order by cert_from
	open cursor2
	fetch next from cursor2
	into @cert_from,@cert_to
	WHILE @@FETCH_STATUS=0
	BEGIN
		if @cert_from > @certificate_f 
			insert #temp_assign( source_deal_detail_id,cert_from,cert_TO,assignment_type,total_volume)
			values (@gis_deal_id, @certificate_f, @cert_from - 1,@bank_assignment,(@cert_from-@certificate_f) )

		set @certificate_f=@cert_to + 1
		
	fetch next from cursor2
	into @cert_from,@cert_to
	END
	if (@certificate_f - 1)	< @certificate_t
			insert #temp_assign( source_deal_detail_id,cert_from,cert_TO,assignment_type,total_volume)
			values (@gis_deal_id, @certificate_f, @certificate_t,@bank_assignment,(@certificate_t-@certificate_f+1))
	

fetch next from cursor1
into
 	@gis_deal_id,@certificate_f,@certificate_t,@deal_volume

CLOSE cursor2
DEALLOCATE cursor2	
	

 END	
CLOSE cursor1
DEALLOCATE cursor1	


select * from (
SELECT source_deal_detail_id,cert_from,cert_to,assignment_type,total_volume FROM #temp_assign
union all
select source_deal_header_id, null,null,@bank_assignment, deal_volume-(certificate_number_to_int-certificate_number_from_int+1) from #temp_cert
where (certificate_number_to_int-certificate_number_from_int+1) < deal_volume
union all
select a.source_deal_header_id_from,a.cert_from,a.cert_to,a.assignment_type,assigned_volume from assignment_audit a
where assigned_volume > 0  and source_deal_header_id_from in (select distinct source_deal_detail_id from #temp_assign)
) a 
order by a.source_deal_detail_id,a.cert_from





