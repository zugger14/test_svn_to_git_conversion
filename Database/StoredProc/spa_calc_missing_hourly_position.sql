--IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_calc_missing_hourly_position]') AND TYPE IN (N'P', N'PC'))
--DROP PROCEDURE [dbo].[spa_calc_missing_hourly_position]
	
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--create proc [dbo].[spa_calc_missing_hourly_position] @sub_id int=null
--as

--/*

if object_id('tempdb..#books') is not null
drop table #books

declare @sub_id int


--select * from process_deal_position_breakdown 
--delete process_deal_position_breakdown


--*/


declare @report_position varchar(250),@process_id varchar(50),@st varchar(max),@db_usr varchar(30)
set @db_usr= dbo.FNADBUser()
set @process_id=dbo.FNAGetNewID()
SET @report_position = dbo.FNAProcessTableName('report_position', @db_usr, @process_id)


--print('create table '+@report_position+' (source_deal_header_id int, [action] varchar(1))')
--exec('create table '+@report_position+' (source_deal_header_id int, [action] varchar(1))')

-- Taking deals that mapped to imported profile through location.

CREATE TABLE #books (fas_book_id INT, source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT) 

set @st='
	INSERT INTO  #books
	SELECT  distinct 
	ssbm.fas_book_id,ssbm.source_system_book_id1,ssbm.source_system_book_id2,ssbm.source_system_book_id3,ssbm.source_system_book_id4
	FROM portfolio_hierarchy book (nolock) INNER JOIN
	Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
	source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id           
	where 1=1' +case when @sub_id is null then '' else ' stra.parent_entity_id='+cast(@sub_id as varchar) end

exec(@st)

set @st='
	SELECT DISTINCT sdh.source_deal_header_id, ''i'' action
	--INTO '+@report_position+'
	FROM source_deal_header sdh (nolock) 
	inner join #books ssbm on 
		ssbm.source_system_book_id1=sdh.source_system_book_id1 and ssbm.source_system_book_id2=sdh.source_system_book_id2
		and ssbm.source_system_book_id3=sdh.source_system_book_id3 and ssbm.source_system_book_id4=sdh.source_system_book_id4
	inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join report_hourly_position_deal s on sdh.source_deal_header_id=s.source_deal_header_id
	where (s.source_deal_header_id is null or sdd.total_volume is null)
	and  isnull(sdh.internal_desk_id,17300) in (17300,17302) and  isnull(sdh.product_id,4101) = 4101
	union
	SELECT DISTINCT sdh.source_deal_header_id, ''i'' action
	FROM source_deal_header sdh (nolock) 
	inner join #books ssbm on 
		ssbm.source_system_book_id1=sdh.source_system_book_id1 and ssbm.source_system_book_id2=sdh.source_system_book_id2
		and ssbm.source_system_book_id3=sdh.source_system_book_id3 and ssbm.source_system_book_id4=sdh.source_system_book_id4
	inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join report_hourly_position_profile s on sdh.source_deal_header_id=s.source_deal_header_id
	where (s.source_deal_header_id is null or sdd.total_volume is null)
	and  sdh.internal_desk_id in (17301) and  isnull(sdh.product_id,4101) = 4101
	union
	SELECT DISTINCT sdh.source_deal_header_id, ''i'' action
	FROM source_deal_header sdh (nolock)
	inner join #books ssbm on 
		ssbm.source_system_book_id1=sdh.source_system_book_id1 and ssbm.source_system_book_id2=sdh.source_system_book_id2
		and ssbm.source_system_book_id3=sdh.source_system_book_id3 and ssbm.source_system_book_id4=sdh.source_system_book_id4
	inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join report_hourly_position_fixed s on sdh.source_deal_header_id=s.source_deal_header_id
	where (s.source_deal_header_id is null or sdd.total_volume is null)
	and  sdh.product_id =4100'

print(@st)
exec(@st)
--if @@ROWCOUNT>0
--	EXEC dbo.spa_update_deal_total_volume NULL, @process_id, 0,1,@db_usr,'n',2
